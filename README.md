# README

This repository hosts the source code for [karl-henrik.se](https://karl-henrik.se), a personal tech blog by Karl-Henrik. The blog covers a wide range of technical topics that Karl-Henrik has been curious about, showcasing experiments, explorations, and insights.

The blog is built with [Jekyll](https://jekyllrb.com/) using the [Chirpy theme](https://github.com/cotes2020/jekyll-theme-chirpy), and it is deployed via GitHub Pages. A development container is included for an easy and consistent local editing environment.

## Table of Contents
- [README](#readme)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [How to View the Blog](#how-to-view-the-blog)
  - [Getting Started](#getting-started)
  - [Development](#development)
    - [Using the Dev Container](#using-the-dev-container)
    - [Directory Structure](#directory-structure)
  - [Acknowledgments](#acknowledgments)

## Features
- **Jekyll Powered**: Built with Jekyll for easy content management using Markdown.
- **Chirpy Theme**: Modern, responsive, and feature-rich theme.
- **Dev Container**: A pre-configured development container for consistent local editing.
- **Dynamic Content**: Includes custom data files for contact information, talks, and sharing options.
- **Social Integration**: Easily share posts or connect via social media.
- **Custom Tabs**: Dedicated tabs for About, Archives, Categories, and Tags.

## How to View the Blog
The blog is live at [https://karl-henrik.se](https://karl-henrik.se). Changes made to the `main` branch of this repository are automatically deployed via GitHub Pages.

## Getting Started
To work on this blog locally:

1. Clone the repository:
   ```bash
   git clone https://github.com/karl-henrik/karl-henrik.github.io.git
   ```
2. Navigate to the project directory:
   ```bash
   cd karl-henrik.github.io
   ```
3. Install dependencies:
   ```bash
   bundle install
   ```
4. Start the local development server:
   ```bash
   bundle exec jekyll serve
   ```
   The blog will be accessible at `http://localhost:4000`.

## Development

### Using the Dev Container
This repository includes a development container for easy setup with consistent dependencies.

1. Install [VS Code](https://code.visualstudio.com/) and the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
2. Open the repository in VS Code.
3. When prompted, reopen the repository in the dev container.
4. The container will automatically install dependencies and provide a ready-to-use development environment.
5. > jekyll serve 

### Directory Structure
- **`_config.yml`**: Blog configuration file.
- **`_data/`**: Contains YAML files for dynamic content like `contact.yml`, `share.yml`, and `talks.yml`.
- **`_posts/`**: Markdown files for blog posts, organized by date in the filename.
- **`_tabs/`**: Custom tabs such as About, Archives, Categories, and Tags.
- **`assets/`**: Contains images, stylesheets, and other static files.
- **`tools/`**: Contains helper scripts like `run.sh` and `test.sh`.
- **`devcontainer.json`**: Configuration for the development container.

## Acknowledgments
- Theme: [Chirpy](https://github.com/cotes2020/jekyll-theme-chirpy) by Cotes Chung.
- Built with [Jekyll](https://jekyllrb.com/).
