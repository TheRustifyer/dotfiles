# The Rustifyer dotfiles configuration

Hi there everyone! This is my GitHub's repository for storing my more beloved configuration on certain
system or applications.

This allows me to quickly setup my full development environment (as I like to have it) just by cloning and pulling
this repository in any machine.

Also, I can share and have up-to-date all my configuration along my typically used machines.

## The tools

### Terminals

#### Wezterm

#### Alacritty + tmux

### Editor: Neovim

### Shell and Shell framework

#### ZSH + Starship

### Command line utilities

// TODO list them here

## Why?

On a regular job day (from Monday to Friday), I almost end using three different machines along the day. 
My main coding workstation (for personal projects), which is just an **MSi** laptop running exclusively a *Manjaro*,
my gaming and secondary code workstation, that runs on *Windows*, and my job workstation, a corporative laptop
that runs on *Windows* using native programs and some tools via *WSL2*.

So I always liked the idea of using the same tools, regarding which operating system I am using at a particular moment.
But that's a hard thing to acomplish, because I also tend to be happier using community-driver open source tools (or at least, open source), and the tools have
to be crossplatform by default or at least, be available in runtimes like `Cygwin` or `Msys2`, or at least, natively compilable in `Windows` via tools like `Mingw`.

The fact is that, all the tools presented below are easy to get, or they already come with your Linux installation. So simply.
Yet `Windows` is another thing.

## How?

This is a git bare repo. The technique consists in storing a Git bare repository in a "side" folder (like $HOME/.cfg or
whatever) using a specially crafted alias so that commands are run against that repository and not the usual `.git`
local folder, which would interfere with any other *Git* repositories around.

### The alias `config`

By having the **config** alias set, now I can invoke *Git* from any place, and it will now that I am interacting
with my configuration bare repository. So I can be in any place an directly add anything that I want to be track by
my configuration repository.

## The setup

// TODO explain it here, with all the tools used, and paste some nice screenshots

## Prerequisites:

These are the mandatory general prerequisites in order to succesfully install the dotfiles and all the tools described above
that conforms this setup

- `Git`
- `Rust` and `Cargo`

>[!CAUTION]
>
> Note for myself. Remember to create `Github` actions to check that the packages are installable without problem in
> all the supported OS

## Linux machines (`pacman` based)

>[!WARNING]
>
> This part is not yet tested completly in a fresh installation for the moment 

>[!WARNING]
>
> This documentation assumes that `Linux` distros will be any kind of `Arch` variants, or that they use (or they have installed)
> `Pacman` as package manager. If your distro doesn't have `pacman` you can download it.

Since almost any `Linux` flavour comes with a `Git` installation

>[!CAUTION]
>
> Note for myself. Remember to check in the bash script for the presence of `pacman` in the system.
> If not present, just install it, so we can make more kind of distros compatibles with this *setup*

## Windows

>[!TIP]
>
> If you plan to use this guide for install the *setup* only on `Linux`, just skip this [TODO, change skip this for a link]

Well, this setup is not exactly easy to replicate in a `Windows` machine. The fact is that requires a lot of configurations and tools that aren't
available in `Windows` by default, nor are easy to understand how to emulate it/natively compile them, since all the tools are `Unix` based.

As said, as developers we most of the time need the ***Microsoft's Visual Studio** tools at some point. And even that some of them are great tools
(for example, `MSVC` and the `C++` tools are comfortable, and `MS Studio` is really a great editor) the idea of this setup is to have a unique set of
tools sharable between any `OS` and completly **open source** based, as stated before.

### The key in Windows, [MSYS2](https://www.msys2.org/)

**MSYS2** is a collection of tools and libraries providing you with an easy-to-use environment for building, installing and running native Windows software.

For more details see ['What is MSYS2?'](https://www.msys2.org/docs/what-is-msys2/)

So basically, the first step to get everything running in Windows is to download the installer. So click on the hyperlink, download it
and then double click on your installer.

>[!NOTE]
>
> Installation extremely fast-forward process, the unique doubt could be the installation location. `MSYS2` is typically well placed directly
> under `C:\`. You can install it in other place, but this guide assumes that you will be using `C:\msys64`, as recommended in their documentation.

You'll see the in latest slide of the installation prompt a ticked checkbox asking you for execute `msys2` now. Discard it and close the installation prompt.

Now, on the `Windows` search bar, type msys2, and open the "purple" shell (msys2 msys), and type:

```bash
pacman -Syu
```

Obviously, type **[Y]** and hit `Enter`. This will update your `msys2` subsystem with the latest packages.

When ends, open the `mingw64` *msys2* shell and do the same. When it ends, run the following:

```bash
pacman -S --needed base-devel mingw-w64-x86_64-toolchain
```

> Don't miss this by any chance, since it will be required later to fully complete our `Rust` installation targeting the `GNU` ABI.

### Setting the **HOME** environmental variable and

Most of the `POSIX` compliant tools available via `MSYS2` will look for an environmental variable known as `$HOME` to resolve some
PATH when certain actions requires it. The quickest and universal way of solving this is to set a new `Windows` system variable
pointing directly to the user's root directory. Simply open a new `cmd` with administrator privileges and type:

```cmd
setx HOME "%USERPROFILE%"
```

This also will do a nice and neat thing, that will turbo overpower our `dotfiles` configuration. Use **HOME** as the *MSYS2* user's root directory.
Yes, this implies that now, instead of being `/home/user` the user's home directory from within `MSYS2`, it will be the *Windows* native
user's home directory.

That will allow us to avoid any kind of path conflicts with certain tools that are expecting to have their dotfiles at a certain place (based on Unix paths)
now pointing to the most logical place in Windows that are eventually the equivalent of the `Linux` ones.,lk

### 
In order to enhace how the dotfiles are easily shared among different `OS`, we can use our Windows *HOME* folder as the home folder for MSYS2
instead of the one that comes by default with the `MSYS2` installation. So, edit `/etc/nsswitch.conf` and write:

```
db_home: windows
```

`%USERPROFILE% will be resolved to your user's Windows directory, and will be permanently added to the Windows **PATH**

> Don't close yet this cmd shell, since you'll need it again briefly

### The `clang64` enviroment.

Now, type `clang64` on the Windows search bar, and open such prompt. Then, run again `pacman -Syu`.

You can learn more about this `msys2` enviroment and more about all of them [here](https://www.msys2.org/docs/environments/). I'll recommend you
to take your time to carefully read about them. Isn't an easy thing to grasp at first if you're not experienced in this kind of complex setups, 
so take a deep breath and just **read the docs**. // TODO pls insert meme here

The very key thing about here is that you'll have all the coolest environment configuration available to work with the `llvm-suite` compiler tech and build
amazing software with them. But for such thing we will need first to gather our `clang` compiling tools.
Open the `msys2 clang64` shell, and paste the following:

```bash
pacman -S mingw-w64-clang-x86_64-{make,cmake,ninja,clang,libunwind,clang-tools-extra,gcc-compat} 
```

> [!NOTE]
>
> // TODO can we change all the `clang` separated tools for the `[MSYS2 llvm-suite package`](https://packages.msys2.org/package/mingw-w64-x86_64-llvm)
> 
> // TODO explain why what one of the few things that we change about the general recommendations of `MSYS2` official docs is to use a different
> shell rather than the default one of the mingw one

### Git in Windows

`Git` is the fastest and universal version control system out there. There's no other rival in terms of what `git` is capable of doing, and is widely
adopted in all the open-source community as well as in the most of companies out there. Also, is the core "trick" of the *dotfiles* repo.

> [!WARNING]
>
> This step isn't easy to get it working. Be really cautious doing the steps described below, or you'll likely end running into issues and you'll
> need to start your work from scratch

> [!CAUTION]
>
> This guide is tested on fresh `Windows` installs and on `Windows` machines that already have a `Git` installation.
> If you already have `git` installed (most likely via `git-for-windows` and don't want to be scratching your head) you can skip it.
> If you plan to fully complete the guide, please remove any previous `Git` installation from your machine.

In order to install `git` on Windows from here, there's now three different options available:

1. Install the `Git for Windows` project. This uses a custom `msys2` self-contained `msys2` environment, slightly different from the upstream one. But it has some advantages, like a GUI installer, based on *click, accept, next* and it is ready to go. It is nice, and if you don't want to complicate thing you may consider it as you option.
2. Using the `msys2` git installation. Since we already have a `msys2` installation, and you don't care about performance, you could use the already embeed git (posix compliant) git installation on the `msys2 msys` base environment. But it has its flaws. Since is in the *msys* environemnt, it works on the *POSIX* emulation layer, using the `msys` runtime tools and shared libraries. This has the downside that it will introduce overheat to the git binary tools when you invoke it, specially noticeable when you work with medium to large *git* based projects.
3. Use the `mingw` based *git* installation. This is far the most complicated one to set up, but it has the best of both worlds. It is performant (since is natively compiled for *Windows*) and you can't avoid to install yet another `git` tool on your system, polluting your development environment with more and more binaries, potentially running into **PATH** issues when invoking tools and other stuff. **This guide will use this approach**, but feel free to use the one that better suits your purposes.

#### [Install GIT inside MSYS2 proper](https://github.com/git-for-windows/git/wiki/Install-inside-MSYS2-proper)

First of all, follow the hyperlink on the header above. They will have the latest known working documentation to understand and efficiently install
**Git** inside **MSYS2** properly. Is not exactly easy and you can run into some issues (even they are unlikely) so I warn you to read first all the documentation and then go again from the beggining, so you can jugde by yourself if this method really suits you.

After you read the documentation, you can go back here, and start working in the installation.

>[!NOTE]
>
> There's only one minor difference, I'll skip the usage of the *32 bits* `mingw32` installation.
> So, open the `msys2 mingw64` shell, and start to work in the points of the list below:

1. Make a backup for just in case if anything goes wrong, by typing ```bash cp /etc/pacman.conf /etc/pacman-bu.conf```
2. Run: ```bash sed -i '/^\[mingw32\]/{ s|^|[git-for-windows]\nServer = https://wingit.blob.core.windows.net/x86-64\n\n|; }' /etc/pacman.conf```
3. Ensure that everything went fine, by typing: ```cat /etc/pacman.conf``` and ensure that there's a new entry for `[git-for-windows]`
4. To avoid the future signature related issues, run the following commands first

```bash 
  rm -r /etc/pacman.d/gnupg/
  pacman-key --init
  pacman-key --populate msys2
```

5. Authorize the signing key with:

```bash
  curl -L https://raw.githubusercontent.com/git-for-windows/build-extra/HEAD/git-for-windows-keyring/git-for-windows.gpg |
  pacman-key --add - &&
  pacman-key --lsign-key E8325679DFFF09668AD8D7B67115A57376871B1C &&
  pacman-key --lsign-key 3B6D86A1BA7701CD0F23AED888138B9E1A9F3986
```

6. Then synchronize with new repositories with ```bash pacman -Syyuu```. This will install a different `msys2` runtime, and you'll probably see a `downgrade` version message. Don't worry at all, just press `[Y]` and proceed with the installation. Then, you'll be asked to shutdown your `msys2` tools, press `[Y]`.

7. Open again the `mingw64` environment shell, and ```bash pacman -Suu``` to syncronize the remaining tools.

8. And finally install the packages containing Git, its documentation and some extra things:

```bash
pacman -S mingw-w64-x86_64-{git,git-doc-html,git-doc-man} mingw-w64-x86_64-git-credential-manager
```

>[!CAUTION]
>
> I've modified the last step to remove the `git-extra` package, since it modifies the `MSYS2` instalation heavily, and doesn't bring any
> advantages to my workflow nor enhace my tools. Read the extra steps carefully if you think that is worth for you, and just run the installation
> command with `pacman`.

>[!TIP]
>
> Also, I added there the `git-credential-manager` package, since it's a **must have** for any comfortable workflow. 

And this would be all. Close you shell and re-open it again. Type:

```bash
  git --version
```
and if git shows version details without issues, the installation process will be complete.

### Adding `MSYS2` shells to the Windows Path

This is a critical and crucial step. You see how easy where installing software, but what about using it?

I won't use the `Mintty` term of `MSYS2` for anything but install software. I want to use other terminals, like `Wezterm` or `Alacritty`, and have
all my tools on path available. This is an easy one step. You can add the `/bin` folders where your `MSYS2` gathered tools lives via the **Windows GUI**
approach, or just open a `cmd` shell with **Administrator** privileges, and type the following:

```cmd
setx PATH "%PATH%;C:\msys64\usr\bin"
setx PATH "%PATH%;C:\msys64\usr\local\bin"
setx PATH "%PATH%;C:\msys64\bin"
setx PATH "%PATH%;C:\msys64\opt\bin"
setx PATH "%PATH%;C:\msys64\clang64\bin"
setx PATH "%PATH%;C:\msys64\mingw64\bin"
```

>[!NOTE]
>
> This is the magic step where everything makes sense. From now, any tool that you install via `MSYS2` (and should be any one available via *MSYS2* in this world)
> would be directly available from any point in your *Windows* installation. That's what will make you to be amazed, since you can have any tool that you like
> even the ones from `Linux` running natively or emulated if its only available in the msys2 runtime in your *Windows* installation.

## Setting the `SSH` agent to authenticate over SSH

>[!NOTE]
>
> It is recommended to follow the `GitHub` documentation in order to use GitHub remote actions with authentication via `SSH`. If you plan to stick
> with the legacy `HTTPS` way, you can skip this step.

> [The steps below are obtained from here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

1. Open a `cmd` shell without *elevated permissions* and paste the chunk below, replacing the email used in the example with your GitHub email address
```cmd
ssh-keygen -t ed25519 -C "your_email@example.com"
```
2. When you're prompted to "Enter a file in which to save the key", you can press Enter to accept the default file location. Please note that if you created SSH keys previously, ssh-keygen may ask you to rewrite another key, in which case we recommend creating a custom-named SSH key. To do so, type the default file location and replace id_ALGORITHM with your custom key name.
3. Open a new Powershell instance to ensure that the *ssh-agent* is active and running. If isn't the case, it will be spawned
```powershell
Get-Service -Name ssh-agent | Set-Service -StartupType Manual
Start-Service ssh-agent
```
4. Now come back to the previous `cmd` shell, and add the previous generated *ssh-key* to the *ssh agent*
```cmd
ssh-add "%USERPROFILE%"/.ssh/id_ed25519
```
5. If everything went correct, you'll see a message like this one:
```cmd
C:\Users\"YourWindowsUser">ssh-add "%USERPROFILE%"/.ssh/id_ed25519
Enter passphrase for C:\Users\"YourWindowsUser"/.ssh/id_ed25519:
Identity added: C:\Users\"YourWindowsUser"/.ssh/id_ed25519 (alex.vergara.dev@gmail.com)
```
> Remember to use the same identifier that you used to generate the *ssh key*

6. Copy the public ***SSH*** key to the clipboard

`Unix shells`

```bash
clip < ~/.ssh/id_ed25519.pub
```
`Windows CMD`

```cmd
clip < "%USERPROFILE%"/.ssh/id_ed25519.pub
```

7. Now follow the remaining steps directly from the [GitHub SSH documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) to add the generated key to your *GitHub* account

## Installing Rust

No secret for anyone. I just love `Rust`. But not only the language, the full ecosystem. And that's includes my favourite tool, `Cargo`.
As you may notice, now we have available a `Unix` like environment within `Windows` thanks to `MSYS2`. Also, we have a `bash` like terminal,
and all the typical command line utilities that we've expected to work, like `grep`, `awk`, `seed` and so on and so forth.

The thing is that, after years of using them, they are quite obsolete. They need hard syntax sometimes to acomplish a simple task, and they don't
look really modern nor are extremely productive to abrange a wide variety of levels of kwoledge of the command line utitiles.

So I thought one day, didn't someone rewrite these tools in `Rust`, make them modern, solving their issues, make them *cross-platform* by default
and available directly with a simple command like `cargo install "--args..."?`

The answer is a tremendous ***YES***, but first we need to have `Cargo`, so we will install `Rust`.

But, for having the full advantage of open-source tools, we will go further. `Rust` installation is managed via a command line utility known as `rustup`.
`rustup` let's you easily manage every aspect of your `Rust's` installation, and even install multiple different `toolchains` in your machine.

### `Rust` on Linux

Just go to the `Rust` home page, and follow the download/installation instructions. Accept everything by default. You're good to go.

### `Rust` on Windows using the `GNU` ABI via the `windows-pc-gnu` target triple

In `Windows`, by default `Rust` will need to have the `MSVC` tools to work. That means to use the `Windows` native API, the `MSVC` linked and others.
But, since we've installed `MSYS2`, we have all the `GCC GNU` utilities, and `Rust` has first class support (even in Windows) for using them.
And even more, we even can go further and avoid to use the `GCC` toolchain, and use the ones provided by the `llvm-project`, the umbrella project to which
`clang` (for example) belongs and the tools that created the `Rust` compiler itself.

Open the `mingw64` terminal or any of the `MSYS2` terminals and run the following:

```bash
$ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path
```

A prompt will appear. Do this in order:

    - choose "Continue? (y/N)" by typing y and hitting the Enter key.
    - choose "2) Customize installation" using the keyboard.
    - paste or type the option: x86_64-pc-windows-gnu .
    - Press enter for the rest of the options.
    - Finally type "1" as input in the console, then press Enter, to choose the option "1 to proceed" with the Current installation Options.

>[!NOTE]
>
> Technically, there's packages for the different flavours of `MSYS2` to download `Rust`, like [this](https://packages.msys2.org/package/mingw-w64-x86_64-rust)
> The problem is that misses one key component, [`rustup`](https://rust-lang.github.io/rustup), which allows us to quickly download and interchange between *toolchains*
> among other niceties, like installing `nightly` versions of the compiler to test the latest and/or unstable features.
> If you plan to stick with the `gnu` variant triple and the `stable` channel, it could be a better option to consider.

Last, but not least, here comes the trick. To use the gcc or clang linker and compiler from MSYS2 you have to create the `C:\Users\user\.cargo\config` file
and just paste the folowing:

```
[target.x86_64-pc-windows-gnu]
linker = "C:\\msys64\\mingw64\\bin\\clang++.exe"
ar = "C:\\msys64\\mingw64\\bin\\llvm-ar.exe"
```

We are here instructing `Cargo` to use the `llvm-suite` tools to compile our `Rust` code targeting the `GNU` ABI.

// TODO make a list talking about the advantages of using the `GNU ABI` and using `clang and lld` instead of their defaults
// TODO isn't clang and lld the default as of 2024 of `rustc`?

> ***And that's all. We can compile `Rust` code in `Windows` without requiring any of the `MSVC` Microsoft tools!***

>[!TIP]
>
> When targeting the GNU ABI, no additional software is strictly required for basic use. However, many library crates will not be able to compile until the full `MSYS2`
> with MinGW has been installed. That's why we installed the full `mingw-w64-x86_64-toolchain` previously.

## The ***dotfiles*** installation process

Assuming that you're on the **ROOT** of your users directory. `~` on **Unix** or `%USERPROFILE%` on **Windows**

### Make a backup of your *dotfiles*

You must do a full backup of any of your `dotfiles` before cloning and checkout the bare repo to avoid running into any merge conflict.
Take a look at the root of this repo and see what files you have per duplicated, and directly move them to any other place.
I recommend you to create a new folder in your home directory and move them there.

> The most important one that you must backup is your `.gitconfig` file, and later replace it again with the one cloned from this repo,
> or directly add your `user details` and save my configuration if it suits you

### Cloning and installing:

>[!TIP]
>
> Optional:
> If you're on *Windows*, as the time of writing your system most likely come with `Windows Terminal` by deafult.
> So pick a `cmd` shell and run `C:\msys64\usr\bin\env MSYSTEM=MINGW64 MSYS2_PATH_TYPE=inherit c:\msys64\usr\bin\bash -i -l`
> and you'll have a login bash shell powered with the `mingw64` *git for Windows* but from **MSYS2** installation

1. [Windows only] Ensure that you did everything properly before and run ```bash pwd``` and check if your opened shell points to your native *Windows* home directory
2. `git clone --bare git@github.com:TheRustifyer/dotfiles.git "$HOME"/.cfg` (replace the URL for the *HTTPS* variant if you need)
3. `git --git-dir="$HOME"/.cfg/ --work-tree="$HOME" checkout`

>[!NOTE]
>
> Just copy and paste the second point for checkout and directly "install" the configuration files.
> Other tutorials configure again the alias for the bare repo and the gitignore, which will cause merge conflicts, and it's completely unnecesary.
> As stated, use the provided commands above to cleanly install the dotfiles. The `config` alias will be set up later automatically.

## Completing the setup

We're finally here (if you're on Windows)!

Big news, everything from here is mostly automated! In your checkout bare repo there's a *shell* script, named `build.sh` that is ready to install all the
tools required to have the setup working. There's a lot of things here, but the script is ready to accept command line arguments, so we can better choose what
tools and suites we installed on our machine. So, instead of running the full setup, I'll be listing below the logical steps in order and invoking in different
iterations every set of tools, so we can better know what is happening and better understanding our final configuration.

> [!TIP]
>
> Take a moment to read the `build.sh` script and see what tools are available and how

### Getting the terminals

1. Alacritty
2. Wezterm
3. Windows Terminal (with the MSYS2 shells configuration) // TODO add the JSON config file to the dotfiles

### Neovim as editor

We will gather a fresh installation of `Neovim` via the `mingw64` package installation.
For having all the configuration of the editor up-to-date
// TODO choose both, from upstream of include add submodule
1. upstream
2. submodule

```bash
./build.sh -nv
```

### Changing the default shell to the `Z` shell

`ZSH`, also called the ***Z shell***, is an extended version of the Bourne Shell (sh), with new features and support for plugins and themes. Since it's based on the same shell as Bash, ZSH has many of the same features, and a lot of new ones no present in `bash` shells.

```bash
./build.sh --zsh
```

### Terminal tools

Remember when I told you about the `Unix` like tools that could have been rewrite in `Rust`? And that they look modern, have better syntaxs and that they are
***extremely performant***? Well, it's time to install them and have them in action.

From your user's root directory, invoke the `build` script passing as argument:

```bash
./build.sh -tt
```

### [ADVANCED] The `llvm-suite` from the last commit on main from upstream

// TODO

## Friendly reminder, starting from scratch your own `dotfiles` bare repo

If you haven't been tracking your configurations in a Git repository before, and you want to do it on your own from scratch, or copying the parts of this guide that you're interested, you can start using this technique easily with these lines:

```bash
git init --bare $HOME/.cfg
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config config --local status.showUntrackedFiles no
echo "alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'" >> $HOME/.zshrc
```

>[!NOTE]
>
> My configuration assumes that the base shell for the configuration uses [**starship**](https://starship.rs/). Obviously, feel free to use
> whatever shell suits you better.

## Acknowledges

// TODO
