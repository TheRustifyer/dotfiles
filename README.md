# The Rustifyer dotfiles configuration

Hi there everyone! This is my GitHub's repository for storing my more beloved configuration on certain
system or applications.

This allows me to quickly setup my full development environment (as I like to have it) just by cloning and pulling
this repository in any machine.

Also, I can share and have up-to-date all my configuration along my typically used machines.

## Why?

On a regular job day (from Monday to Friday), I almost end using three different machines along the day.
My main coding workstation (for personal projects), which is just an **MSi** laptop running exclusively a *Manjaro*,
my gaming and secondary code workstation, that runs on *Windows*, and my job workstation, a corporative laptop
that runs on *Windows* but I mostly use *WSL2* these days.

By having my `.dotfiles` in this repo, I can quickly go to another workstation and start to work as I like,
format my system without causing me too much trouble for losing my tools and having to reinstall them...

## How?

This is a git bare repo. The technique consists in storing a Git bare repository in a "side" folder (like $HOME/.cfg or
whatever) using a specially crafted alias so that commands are run against that repository and not the usual `.git`
local folder, which would interfere with any other *Git* repositories around.

## Friendly reminder, starting from scratch

If you haven't been tracking your configurations in a Git repository before, you can start using this technique easily with these lines:

```bash
git init --bare $HOME/.cfg
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config config --local status.showUntrackedFiles no
echo "alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'" >> $HOME/.zshrc
```

>[!NOTE]
>
> My configuration assumes that the base shell for the configuration uses `zsh`. Obviously, feel free to use
> whatever shell suits you better.

### The alias `config`

By having the **config** alias set, now I can invoke *Git* from any place, and it will now that I am interacting
with my configuration bare repository. So I can be in any place an directly add anything that I want to be track by
my configuration repository.

