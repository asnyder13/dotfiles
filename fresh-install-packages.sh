#!/usr/bin/env bash

if [[ "$EUID" -eq 0 ]]; then
	echo 'Do not run as root'
	exit 1
fi

PACKAGES=(
	ImageMagick
	ShellCheck
	autoconf
	automake
	bat
	cc
	clang
	cmake
	curl
	difftastic
	fd-find
	fortune-mod
	fzf
	gcc
	gcc-c++
	gettext
	git
	iotop
	java-latest-openjdk
	keepassxc
	libtool
	make
	mediainfo
	ncdu
	neofetch
	ninja-build
	nload
	p7zip
	pv
	qalculate
	qrencode
	ripgrep
	rsync
	stow
	syncthing
	tig
	tldr
	tmux
	unzip
	watchman
	wireguard-tools
	zsh
)

DESKTOP_STUFF=(
	# kmod-nvidia
	ImageMagick
	adb
	alacritty
	btop
	chromium
	easyeffects
	flatpak
	gimp
	gitk
	go
	htop
	krita
	libreoffice
	mozilla-openh264
	openh264
	pdfgrep
	qalculate-qt
	qbittorrent
	samba-client
	telegram-desktop
	thunderbird
	virt-manager
	vlc
	xclip
	xev
	zathura
	zathura-plugins-all
	zathura-zsh-completion
	zeal
)

DEV_STUFF=(
	dotnet-sdk-7.0
	dotnet-sdk-8.0
	dotnet-sdk-9.0
	python3
	python3-pip
	ImageMagick-devel
)

SWAY_STUFF=(
	slurp
	sway-config-fedora
	waybar
	wl-clipboard
	wlsunset
	xev
)

# Naïve distro detection
if command -v dnf5 >/dev/null 2>&1; then
	installer='sudo dnf5 install --skip-broken'
	sudo dnf install -y \
		"https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
		"https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
elif command -v apt >/dev/null 2>&1; then
	installer='sudo apt install'
else
	echo "ERROR: Don't have dnf5 nor apt installed?"
	exit 1
fi

read -rp 'Install dev stuff? (rvm/nvm/dotnet/python) [Y/n]' installdevstuff
installdevstuff=${installdevstuff:-'Y'}
read -rp 'Using sway? (will also install desktop stuff) [Y/n]' installswaystuff
installswaystuff=${installswaystuff:-'Y'}
read -rp 'Compile neovim? [Y/n]' installneovim
installneovim=${installneovim:-'Y'}

dev_packs=()
case "$installdevstuff" in
	y|Y)
		dev_packs=( "${DEV_STUFF[@]}" )
esac

desktop_stuff=()
sway_packs=()
case "$installswaystuff" in
	y|Y)
		sway_packs=( "${SWAY_STUFF[@]}" )
		desktop_stuff=( "${DESKTOP_STUFF[@]}" )
esac

all_packs=("${PACKAGES[@]}" "${dev_packs[@]}" "${sway_packs[@]}" "${desktop_stuff[@]}")
install_cmd="$($installer) ${all_packs[*]}"
sudo bash -c "$($install_cmd)"


install_neovim() {
	if [[ -d "$HOME/Downloads" ]]; then
		downloaddir="$HOME/Downloads"
	elif [[ -d "$HOME/downloads" ]]; then
		downloaddir="$HOME/downloads"
	else
		echo 'No [Dd]ownloads dir'
		return
	fi

	cd "$HOME/$downloaddir/" || { echo "Could not cd into $HOME/$downloaddir/"; return; }
	if [[ ! -d "neovim" ]]; then
		git clone https://github.com/neovim/neovim.git
	fi
	cd neovim/ || { echo "Could not cd into $HOME/$downloaddir/neovim/"; return; }
	nvimversion=$(git branch --remotes | tail -1 | perl -pe 's%.+origin/(.+)%\1%')
	git checkout "$nvimversion"
	make CMAKE_BUILD_TYPE=Release
	sudo make install
	cd "$HOME" || { echo "Could not cd back to $HOME"; exit 1; }
}
case "$installneovim" in
	y|Y)
		install_neovim
esac

# RVM/Ruby
case "$installdevstuff" in
	y|Y)
		if [[ ! -d "$XDG_DATA_HOME/rvm" ]]; then
			\curl -sSL https://rvm.io/mpapis.asc | gpg --import -
			\curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
			\curl -sSL https://get.rvm.io | bash -s stable --path "$XDG_DATA_HOME/rvm"
			export PATH="$PATH:$XDG_DATA_HOME/rvm/bin"
			source "$XDG_DATA_HOME/rvm/scripts/rvm"
			read -rp 'What version of Ruby do you want to install? ex:: 3.3.0' rubyversion
			rvm install "ruby-$rubyversion"
		fi
esac

# fzf
# git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
# "$HOME/.fzf/install"

# youtube-dlp
sudo wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/local/bin/yt-dlp
sudo chmod a+rx /usr/local/bin/yt-dlp

# go packages: cliphist
go install go.senan.xyz/cliphist@latest
