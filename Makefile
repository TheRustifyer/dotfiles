.PHONY: setup_zsh
zsh:
	git clone https://github.com/ohmyzsh/ohmyzsh .oh-my-zsh
	git clone https://github.com/zsh-users/zsh-completions.git
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k


.PHONY: gh_cli_windows
gh_cli_win:
	git clone https://github.com/cli/cli.git gh-cli
	cd gh-cli
	go run script\build.go

.PHONY: gh_cli_linux
gh_cli_linux:
	git clone https://github.com/cli/cli.git gh-cli
	cd gh-cli
	bin/gh version
