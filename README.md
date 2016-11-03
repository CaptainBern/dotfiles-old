# Dotfiles

My dotfiles. Basically a copy of https://github.com/holman/dotfiles but with some
tweaks for me.

## Dependencies

### Mandatory dependencies

The following dependencies are mandatory (as in this entire repo is built around them).
When using the installation script, they will also be installed automatically.

- [ZSH](http://www.zsh.org/)
- [Oh-My-Zsh](https://github.com/robbyrussell/oh-my-zsh)

### Optional dependencies

The following dependencies are optional. The installation script will prompt you for confirmation.

- [i3](https://i3wm.org/)
- [i3blocks](https://github.com/vivien/i3blocks)
- [rxvt-unicode](http://software.schmorp.de/pkg/rxvt-unicode.html)
- [Golang](https://golang.org/)
- [Google Fonts](https://fonts.google.com/)
- [Hack](https://github.com/chrissimpkins/Hack)
- [FontAwesome](http://fontawesome.io/)

## Installation

(If you plan on installing i3 via the installation script, make sure you install xorg first if you haven't yet)

To install:
```sh
git clone https://github.com/CaptainBern/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
bootstrap/install.sh
```

## Todo

- [x] fonts (https://github.com/google/fonts)
- [x] install latest rxvt-unicode
- [x] colors (TODO: still gotta fix i3 mode colors)
- [x] fix power menu.
- [ ] network stuff in i3
- [ ] sound in i3bar
- [x] i3lock script
- [ ] firefox-developer installation option (download via wget and install stuff)
- [ ] weechat
- [ ] keybinds to open browser etc in specific workspaces
- [ ] vim
- [ ] pass
