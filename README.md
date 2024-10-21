# ShellSmith

**ShellSmith** is a streamlined tool designed to automate system configuration on Unix-like operating systems. It offers a flexible framework for running user-defined scripts, whether for installing applications, managing dotfiles, or executing custom tasks. With a terminal-based user interface (TUI) for selecting and managing installations, and a lightweight yet powerful dependency handler, ShellSmith ensures that all scripts are executed in the correct order, making it ideal for automating setups and maintaining consistent environments.

## Key Features

- **Intuitive TUI**: Provides a simple interface for selecting and managing user defined scripts, making the setup process fast and user-friendly.

- **Efficient Dependency Handler**: Ensures that the user-defined scripts are executed in the correct sequence, based on defined dependencies.

- **Flexible Scripting:** Enables users to fully customize how scripts handle installations. For example, users can (and should) manage existing installations by deciding whether to skip, overwrite, or apply specific logic tailored to their environment.

- **Centralized Dotfile Management**: Efficiently manage dotfiles by symlinking them from a centralized location. The `safe_symlink` function ensures secure linking, preventing overwriting of existing files, and providing a reliable solution for maintaining consistent system configurations.

## Application Structure

- **`apps/`**: Directory to place user-defined installation scripts.

  - **`packages.sh`**: Positioned to be executed first (all apps depend on it by default). It can be used to install utilities like `curl` early on.

  - **`apps/kitty.sh.example`**: A template to help users write their own installation scripts.

- **`dotfiles/`**: Central repository for user configuration files. Use `safe_symlink` to safely link dotfiles to their appropriate location.
  
- **`misc/`**: Houses additional scripts or files, such as themes, that do not fall under applications or dotfiles.

- **`utils/`**: Contains utility functions for ShellSmith.

- **`src/`**: Core ShellSmith logic and functionality.

## Getting Started

1. **Fork the repository**:

    ```bash
    git fork https://github.com/marjohnsen/ShellSmith.git
    cd ShellSmith
    ```

2. **Create a custom script in `apps/` and add relevant files to `dotfiles/` and `misc/`:**

   ```bash
    #!/bin/bash
    # Dependencies are read from the first line starting with double dash.
    # In this case, the dependency handler will make sure apps/pyenv.sh and apps/node.sh
    # are installed before executing this script
    // pyenv node
    
    # app interface contain default behaviour and safe_symlink
    source utils/app_interface.sh

    install_dependencies() {
      sudo apt install ripgrep fd-find texlive biber latexmk fuse -y
      sudo npm install -g neovim
    }

    install_neovim() {
      # Remove neovim if already installed (you can add any behaviour you like, this works for me)
      if [ -d "/opt/nvim" ]; then
        sudo rm -rf /opt/nvim ~/.local/share/nvim ~/.cache/nvim
      fi

      curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
      chmod u+x nvim.appimage

      sudo mkdir -p /opt/nvim
      sudo mv nvim.appimage /opt/nvim/nvim
    }

    setup_lazyvim() {
      # Use safe_symlink to link dotfiles to appropriate location 
      safe_symlink "$PWD/dotfiles/nvim" "$HOME/.config/nvim"
    }

    setup_nvim_pyenv() {
      # delete if it already exist
      if pyenv versions --bare | grep "^neovim$"; then
        pyenv virtualenv-delete -f neovim
      fi

      pyenv virtualenv 3.10 neovim

      "$(pyenv prefix neovim)/bin/python" -m pip install --upgrade pip
      "$(pyenv prefix neovim)/bin/python" -m pip install pynvim

    }

    install_dependencies
    install_neovim
    setup_lazyvim
    setup_nvim_pyenv
    ```

3. **Execute ShellSmith:**

    ```bash
    ./ShellSMith.sh
    ```
