#!/usr/bin/env bash
set -euo pipefail

find_blog_root() {
  local dir
  dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  while [[ "$dir" != "/" ]]; do
    if [[ -d "$dir/_posts" ]]; then
      printf '%s\n' "$dir"
      return 0
    fi

    dir="$(dirname "$dir")"
  done

  echo "Could not find blog root containing _posts" >&2
  exit 1
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

unquote() {
  local value
  value="$(trim "$1")"

  value="${value%,}"
  value="$(trim "$value")"

  if [[ "$value" == \"*\" && "$value" == *\" ]]; then
    value="${value:1:${#value}-2}"
  elif [[ "$value" == \'*\' && "$value" == *\' ]]; then
    value="${value:1:${#value}-2}"
  fi

  printf '%s' "$value"
}

slugify() {
  local value="$1"

  value="$(printf '%s' "$value" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"

  printf '%s' "$value"
}

yaml_escape() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '%s' "$value"
}

remove_inline_comment() {
  local value="$1"

  # Removes comments like:
  # tags: [azure, serverless] # comment
  #
  # This is intentionally simple and assumes comments are not inside quoted strings.
  value="$(printf '%s' "$value" | sed -E 's/[[:space:]]+#.*$//')"

  printf '%s' "$value"
}

update_taxonomy() {
  local root_dir
  root_dir="$(find_blog_root)"

  local posts_dir="$root_dir/_posts"
  local data_dir="$root_dir/_data"

  mkdir -p "$data_dir"

  declare -A tag_counts=()
  declare -A tag_names=()

  declare -A category_counts=()
  declare -A category_names=()

  add_tag() {
    local name
    name="$(unquote "$1")"
    [[ -z "$name" ]] && return

    name="$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]')"

    local slug
    slug="$(slugify "$name")"
    [[ -z "$slug" ]] && return

    tag_names["$slug"]="$name"
    tag_counts["$slug"]=$(( ${tag_counts["$slug"]:-0} + 1 ))
  }

  add_category() {
    local name
    name="$(unquote "$1")"
    [[ -z "$name" ]] && return

    local slug
    slug="$(slugify "$name")"
    [[ -z "$slug" ]] && return

    category_names["$slug"]="$name"
    category_counts["$slug"]=$(( ${category_counts["$slug"]:-0} + 1 ))
  }

  parse_inline_list() {
    local value="$1"
    local callback="$2"

    value="${value#\[}"
    value="${value%\]}"

    local item
    local items

    IFS=',' read -ra items <<< "$value"

    for item in "${items[@]}"; do
      "$callback" "$item"
    done
  }

  parse_scalar_or_list() {
    local key="$1"
    local value="$2"

    value="$(trim "$value")"
    value="$(remove_inline_comment "$value")"
    value="$(trim "$value")"

    [[ -z "$value" ]] && return

    if [[ "$value" == \[*\] ]]; then
      if [[ "$key" == "tags" ]]; then
        parse_inline_list "$value" add_tag
      else
        parse_inline_list "$value" add_category
      fi
    else
      if [[ "$key" == "tags" ]]; then
        add_tag "$value"
      else
        add_category "$value"
      fi
    fi
  }

  parse_post() {
    local file="$1"
    local in_front_matter=false
    local front_matter_started=false
    local current_key=""
    local line

    while IFS= read -r line || [[ -n "$line" ]]; do
      # Handle Windows line endings.
      line="${line%$'\r'}"

      if [[ "$line" == "---" ]]; then
        if [[ "$front_matter_started" == false ]]; then
          front_matter_started=true
          in_front_matter=true
          continue
        else
          break
        fi
      fi

      [[ "$in_front_matter" != true ]] && continue

      case "$line" in
        tags:*)
          current_key="tags"
          parse_scalar_or_list "tags" "${line#tags:}"
          ;;

        categories:*)
          current_key="categories"
          parse_scalar_or_list "categories" "${line#categories:}"
          ;;

        "  - "*|"- "*)
          local item
          item="${line#*- }"

          if [[ "$current_key" == "tags" ]]; then
            add_tag "$item"
          elif [[ "$current_key" == "categories" ]]; then
            add_category "$item"
          fi
          ;;

        "")
          ;;

        *)
          current_key=""
          ;;
      esac
    done < "$file"
  }

  local post
  local post_count=0

  shopt -s nullglob

  echo "Blog root: $root_dir"
  echo "Posts dir: $posts_dir"

  for post in "$posts_dir"/*.md "$posts_dir"/*.markdown; do
    post_count=$((post_count + 1))
    parse_post "$post"
  done

  echo "Parsed $post_count posts"

  {
    echo "---"

    for slug in "${!tag_names[@]}"; do
      printf '%s|%s|%s\n' "${tag_names[$slug]}" "$slug" "${tag_counts[$slug]}"
    done | sort | while IFS='|' read -r name slug count; do
      echo "- name: \"$(yaml_escape "$name")\""
      echo "  slug: \"$(yaml_escape "$slug")\""
      echo "  count: $count"
    done
  } > "$data_dir/tags.yml"

  {
    echo "---"

    for slug in "${!category_names[@]}"; do
      printf '%s|%s|%s\n' "${category_names[$slug]}" "$slug" "${category_counts[$slug]}"
    done | sort | while IFS='|' read -r name slug count; do
      echo "- name: \"$(yaml_escape "$name")\""
      echo "  slug: \"$(yaml_escape "$slug")\""
      echo "  count: $count"
    done
  } > "$data_dir/categories.yml"

  echo "Updated _data/tags.yml"
  echo "Updated _data/categories.yml"
}

read_taxonomy_names() {
  local file="$1"
  local output_array_name="$2"
  local -n output_array="$output_array_name"

  output_array=()

  [[ -f "$file" ]] || return 0

  local line
  local value

  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"

    case "$line" in
      "- name:"*|"  name:"*|*" name:"*)
        value="${line#*name:}"
        value="$(unquote "$value")"
        [[ -n "$value" ]] && output_array+=("$value")
        ;;
    esac
  done < "$file"
}

array_contains_case_insensitive() {
  local value="$1"
  local array_name="$2"
  local -n array="$array_name"

  local item
  for item in "${array[@]}"; do
    if [[ "${item,,}" == "${value,,}" ]]; then
      return 0
    fi
  done

  return 1
}

join_selected_for_display() {
  local array_name="$1"
  local -n array="$array_name"

  if (( ${#array[@]} == 0 )); then
    printf '(none)'
    return
  fi

  local result=""
  local item

  for item in "${array[@]}"; do
    if [[ -z "$result" ]]; then
      result="$item"
    else
      result="$result, $item"
    fi
  done

  printf '%s' "$result"
}

format_yaml_inline_array() {
  local array_name="$1"
  local -n array="$array_name"

  local result="["
  local item
  local first=true

  for item in "${array[@]}"; do
    if [[ "$first" == true ]]; then
      first=false
    else
      result+=", "
    fi

    result+="$item"
  done

  result+="]"

  printf '%s' "$result"
}

clear_rendered_block() {
  local lines="$1"

  if (( lines > 0 )); then
    printf '\033[%sA\033[J' "$lines"
  fi
}

choose_taxonomy_item() {
  local prompt="$1"
  local options_array_name="$2"
  local selected_array_name="$3"
  local lowercase="${4:-false}"

  local -n options="$options_array_name"
  local -n selected="$selected_array_name"

  local query=""
  local highlighted=-1
  local rendered_lines=0
  local key
  local rest

  CHOOSER_RESULT=""

  while true; do
    local choices=()
    local choice_types=()
    local lower_query="${query,,}"
    local exact_match=false
    local option

    for option in "${options[@]}"; do
      if [[ "${option,,}" == "$lower_query" ]]; then
        exact_match=true
      fi

      if array_contains_case_insensitive "$option" "$selected_array_name"; then
        continue
      fi

      if [[ -z "$query" || "${option,,}" == *"$lower_query"* ]]; then
        choices+=("$option")
        choice_types+=("existing")
      fi
    done

    if [[ -n "$query" ]] && array_contains_case_insensitive "$query" "$selected_array_name"; then
      exact_match=true
    fi

    if [[ -n "$query" && "$exact_match" == false ]]; then
      local new_value="$query"

      if [[ "$lowercase" == true ]]; then
        new_value="${new_value,,}"
      fi

      choices=("$new_value" "${choices[@]}")
      choice_types=("new" "${choice_types[@]}")
    fi

    if (( ${#choices[@]} == 0 )); then
      highlighted=-1
    elif (( highlighted >= ${#choices[@]} )); then
      highlighted=$(( ${#choices[@]} - 1 ))
    fi

    clear_rendered_block "$rendered_lines"
    rendered_lines=0

    printf '%s\n' "$prompt"
    rendered_lines=$((rendered_lines + 1))

    printf 'Selected: %s\n' "$(join_selected_for_display "$selected_array_name")"
    rendered_lines=$((rendered_lines + 1))

    printf 'Type to filter. Use ↑/↓ to select. Enter adds. Empty Enter finishes.\n'
    rendered_lines=$((rendered_lines + 1))

    printf '> %s\n' "$query"
    rendered_lines=$((rendered_lines + 1))

    local max_items=10
    local display_count="${#choices[@]}"

    if (( display_count > max_items )); then
      display_count="$max_items"
    fi

    local i
    for ((i = 0; i < display_count; i++)); do
      local label="${choices[$i]}"

      if [[ "${choice_types[$i]}" == "new" ]]; then
        label="Create new: $label"
      fi

      if (( i == highlighted )); then
        printf '\033[7m  %s\033[0m\n' "$label"
      else
        printf '  %s\n' "$label"
      fi

      rendered_lines=$((rendered_lines + 1))
    done

    if (( ${#choices[@]} > max_items )); then
      printf '  ... %s more\n' "$(( ${#choices[@]} - max_items ))"
      rendered_lines=$((rendered_lines + 1))
    fi

    IFS= read -rsn1 key

    case "$key" in
      $'\x1b')
        IFS= read -rsn2 -t 0.05 rest || true

        case "$rest" in
          "[A")
            if (( ${#choices[@]} > 0 )); then
              if (( highlighted <= 0 )); then
                highlighted=$(( ${#choices[@]} - 1 ))
              else
                highlighted=$((highlighted - 1))
              fi
            fi
            ;;

          "[B")
            if (( ${#choices[@]} > 0 )); then
              if (( highlighted < 0 || highlighted >= ${#choices[@]} - 1 )); then
                highlighted=0
              else
                highlighted=$((highlighted + 1))
              fi
            fi
            ;;
        esac
        ;;

      $'\x7f'|$'\b')
        query="${query%?}"

        if [[ -z "$query" ]]; then
          highlighted=-1
        else
          highlighted=0
        fi
        ;;

      "")
        if [[ -z "$query" && "$highlighted" -lt 0 ]]; then
          clear_rendered_block "$rendered_lines"
          return 1
        fi

        if (( highlighted >= 0 && highlighted < ${#choices[@]} )); then
          CHOOSER_RESULT="${choices[$highlighted]}"
        elif [[ -n "$query" ]]; then
          CHOOSER_RESULT="$query"
        else
          continue
        fi

        CHOOSER_RESULT="$(trim "$CHOOSER_RESULT")"

        if [[ "$lowercase" == true ]]; then
          CHOOSER_RESULT="${CHOOSER_RESULT,,}"
        fi

        clear_rendered_block "$rendered_lines"
        return 0
        ;;

      *)
        if [[ "$key" =~ [[:print:]] ]]; then
          query+="$key"
          highlighted=0
        fi
        ;;
    esac
  done
}

choose_taxonomy_items() {
  local prompt="$1"
  local options_array_name="$2"
  local output_array_name="$3"
  local lowercase="${4:-false}"

  local -n output="$output_array_name"
  output=()

  while choose_taxonomy_item "$prompt" "$options_array_name" "$output_array_name" "$lowercase"; do
    local value="$CHOOSER_RESULT"

    [[ -z "$value" ]] && continue

    if ! array_contains_case_insensitive "$value" "$output_array_name"; then
      output+=("$value")
    fi
  done
}

new_post() {
  local root_dir
  root_dir="$(find_blog_root)"

  local posts_dir="$root_dir/_posts"
  local data_dir="$root_dir/_data"

  mkdir -p "$posts_dir"

  local existing_categories=()
  local existing_tags=()

  read_taxonomy_names "$data_dir/categories.yml" existing_categories
  read_taxonomy_names "$data_dir/tags.yml" existing_tags

  local title

  printf 'Title: '
  IFS= read -r title

  title="$(trim "$title")"

  if [[ -z "$title" ]]; then
    echo "Title is required." >&2
    exit 1
  fi

  local selected_categories=()
  local selected_tags=()

  choose_taxonomy_items "Choose categories" existing_categories selected_categories false
  choose_taxonomy_items "Choose tags" existing_tags selected_tags true

  local today
  printf -v today '%(%F)T' -1

  local slug
  slug="$(slugify "$title")"

  if [[ -z "$slug" ]]; then
    slug="new-post"
  fi

  local file="$posts_dir/$today-$slug.md"
  local counter=2

  while [[ -e "$file" ]]; do
    file="$posts_dir/$today-$slug-$counter.md"
    counter=$((counter + 1))
  done

  cat > "$file" <<EOF
---
title: "$(yaml_escape "$title")"
date: $today
categories: $(format_yaml_inline_array selected_categories)
tags: $(format_yaml_inline_array selected_tags)
---

EOF

  echo "Created $file"
}

show_usage() {
  echo "Usage:"
  echo "  ./blog-tool.sh update"
  echo "  ./blog-tool.sh new-post"
}

case "${1:-}" in
  update)
    update_taxonomy
    ;;

  new-post)
    new_post
    ;;

  ""|help|--help|-h)
    show_usage
    ;;

  *)
    echo "Unknown command: $1" >&2
    show_usage
    exit 1
    ;;
esac