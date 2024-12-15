# ShellSmith

**ShellSmith** is a streamlined tool designed to automate system configuration on Unix-like operating systems.

It offers a flexible framework for running user-defined scripts, whether for installing applications, managing configuration files, or executing custom tasks.

With built-in dependency management, ShellSmith ensures that the user-defined scripts are executed in the correct order based on specified prerequisites, simplifying even the most complex workflows.

## Getting Started

### 1. Clone the repository

To get started, clone the repository and run the installation script:

```bash
git clone https://github.com/marjohnsen/ShellSmith.git
cd ShellSmith
./setup.sh install
```

### 2. Setup your ShellSmith workspace

The default workspace path is `~/.config/shellsmith`. TO use a custom path, set the `SHELLSMITH_WORKSPACE` environment variable by adding the following line to your `.bashrc` (or equivalent):

```bash
export  SHELLSMITH_WORKSPACE=<desired path>
```

Ensure `SHELLSMITH_WORKSPACE` is set before proceeding if you do not want the default location. ShellSmith will back up any existing workspace before creating or cloning a new one. Note that the author is not responsible for data loss under any circumstances.

#### Create new workspace

First time users can create a new workspace using:

```bash
smith workspace create
```

This will create a workspace with the following structure:

- `apps/`: folder for your custom setup scripts.
- `utils/`: Folder for utility functions to assist script development in `apps/`.
- `init.sh`: a script that will always be executed first regardless of dependencies.
- `.gitignore`: Ensures utils/ is ignored if the workspace is version-controlled.

**You are encouraged to upload your workspace to github after creating it.**

#### Clone existing workspace from github

To use an existing ShellSmith workspace, clone it to your designated workspace location with:

```bash
smith workspace clone <url to your repo>
```

## Develop Setup Script

Below is an example of a script to install `neovim` with `pyenv.sh` and `node.sh` as dependencies.

### **Script Example:** `apps/neovim.sh`

Note that ShellSmith only look for scripts under `apps/*.sh` in your workspace. You can however source code from anywhere within your `apps/*.sh` script.

Dependencies are declared below the shebang using `//` followed by script names (excluding the .sh extension). The line `source utils/app_interface.sh` loads ShellSmith’s app interface for default behavior and utility functions like `safe_symlink`.

A good practice is to ensure scripts are idempotent, meaning they can be run repeatedly without causing issues. In this example, `neovim` is uninstalled before being reinstalled.

```bash
#!/bin/bash
// pyenv node

source ../utils/app_interface.sh

install_dependencies() {
  sudo apt install ripgrep fd-find texlive biber latexmk fuse -y
  sudo npm install -g neovim
}

install_neovim() {
  if [ -d "/opt/nvim" ]; then
    sudo rm -rf /opt/nvim ~/.local/share/nvim ~/.cache/nvim
  fi

  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
  chmod u+x nvim.appimage

  sudo mkdir -p /opt/nvim
  sudo mv nvim.appimage /opt/nvim/nvim
}

setup_lazyvim() {
  safe_symlink "$PWD/dotfiles/nvim" "$HOME/.config/nvim"
}

setup_nvim_pyenv() {
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

## Running ShellSmith

Once the script is added, you can view and execute it using:

```bash
smith run
```
