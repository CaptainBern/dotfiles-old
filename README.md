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

**WARNING**: If you are not running on Debian, install `i3` and `urxvt-unicode` yourself.
The installation script will use jessie-backports to install the latest `i3` and the
Debian testing repository to install the latest version of `urxvt-unicode`.

To install:
```sh
git clone https://github.com/CaptainBern/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
bootstrap/install.sh
```

## Todo

x fonts (https://github.com/google/fonts)
x install latest rxvt-unicode
x colors (TODO: still gotta fix i3 mode colors)
- fix power menu.
- network stuff in i3
- sound in i3bar
- i3lock script
- firefox-developer installation option (download via wget and install stuff)
- weechat
- workspaces for browser, weechat etc
- vim
- pass
