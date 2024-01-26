  # Extend from the base image
    FROM bretfisher/jekyll-serve:stable-20231215-2119a31

    # Set bash as the default shell
    SHELL ["/bin/bash", "-c"]

    RUN echo "Building from SoftwareAs Dockerfile"

    # Install Vim and Tig
    RUN apt-get update && apt-get install -y vim tig

    RUN echo '[[ -f ~/.bash_profile ]] && source ~/.bash_profile' > /root/.bashrc

    RUN git clone https://github.com/mahemoff/dotfiles.git ~/dotfiles && \
        bash ~/dotfiles/make.sh

    COPY post-boot.sh /root/post-boot.sh