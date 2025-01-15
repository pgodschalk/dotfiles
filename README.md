<!-- markdownlint-disable -->

<a id="readme-top"></a>

<!-- PROJECT SHIELDS -->

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">

<h3 align="center">@pgodschalk/dotfiles</h3>

  <p align="center">
    My collection of dotfiles
    <br />
    <a href="https://github.com/pgodschalk/dotfiles/blob/main/README.md"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/pgodschalk/dotfiles/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    ·
    <a href="https://github.com/pgodschalk/dotfiles/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About the project</a>
      <ul>
        <li><a href="#built-with">Built with</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## About the project

My collection of dotfiles. I mainly use this with
[Ghostty](https://ghostty.org) as a terminal emulator on macOS, and
[Windows Terminal](https://github.com/microsoft/terminal) on Windows.

[Zed](https://zed.dev) is my main editor, though I do keep
[Visual Studio Code](https://code.visualstudio.com) around mainly for Windows
support, Codespaces and remote development. And a debugger every now and then.
Though I'll likely use Zed instead when those features land there.

[DataGrip](https://www.jetbrains.com/datagrip/) is also around on my system,
which is technically an IDE. I just use it as a database browser most of the
time, because it supports most database engines I use.bash

[SourceGit](https://github.com/sourcegit-scm/sourcegit) is my default Git
client, but I also use [GitButler](https://github.com/gitbutlerapp/gitbutler)'s
virtual branch feature regularly when working on larger projects.

Other than that,

- [Dash](https://kapeli.com/dash) is my go-to documentation browser.
- [DevPod](https://devpod.io) is running development environments when I need
  more juice than my MacBook Pro can provide. Sometimes I run said environment
  on my Windows machine. Though I'll also use plain old Codespaces every now
  and then.
- [GitHub Desktop](https://desktop.github.com) is basically there to provide
  `gh`.
- [OrbStack](https://orbstack.dev) runs my Docker containers, since Docker
  Desktop is just slow, and gets in my way a lot. Though Docker Desktop is
  still around on Windows.
- [satyrn](https://satyrn.app) runs Jupyter notebooks. I'm eagerly waiting for
  them to add remote execution support, so I can run them on my DevPods.
- [SnippetsLab](https://www.renfei.org/snippets-lab/) is where I keep my code
  snippets.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built with

- [![GNU Bash][bash]][bash-url]
- [![Python][python]][python-url]
- [![Ruby][ruby]][ruby-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->

## Getting started

To get a local copy up and running follow these simple example steps.

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/pgodschalk/dotfiles.git
   ```
2. Change git remote url to avoid accidental pushes to base project
   ```sh
   git remote set-url origin pgodschalk/dotfiles
   git remote -v # confirm the changes
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->

## Usage

Symlink any dotfile you want to use.

```sh
rm ~/.something
ln -s ~/Code/for/all/dotfiles/.something ~/.something
```

_For more examples, please refer to the [Documentation](https://github.com/pgodschalk/dotfiles/blob/main/READE.md)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->

## Roadmap

See the [open issues](https://github.com/pgodschalk/dotfiles/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Top contributors:

<a href="https://github.com/pgodschalk/dotfiles/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=pgodschalk/dotfiles" alt="contrib.rocks image" />
</a>

<!-- LICENSE -->

## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->

## Contact

Patrick Godschalk - [@kernelpanics.nl](https://bsky.app/profile/kernelpanics.nl) - patrick@kernelpanics.nl

Project Link: [https://github.com/pgodschalk/dotfiles](https://github.com/pgodschalk/dotfiles)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->

## Acknowledgments

- [Gary Bernhardt's dotfiles](https://github.com/garybernhardt/dotfiles/tree/main)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/pgodschalk/dotfiles.svg?style=for-the-badge
[contributors-url]: https://github.com/pgodschalk/dotfiles/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/pgodschalk/dotfiles.svg?style=for-the-badge
[forks-url]: https://github.com/pgodschalk/dotfiles/network/members
[stars-shield]: https://img.shields.io/github/stars/pgodschalk/dotfiles.svg?style=for-the-badge
[stars-url]: https://github.com/pgodschalk/dotfiles/stargazers
[issues-shield]: https://img.shields.io/github/issues/pgodschalk/dotfiles.svg?style=for-the-badge
[issues-url]: https://github.com/pgodschalk/dotfiles/issues
[license-shield]: https://img.shields.io/github/license/pgodschalk/dotfiles?style=for-the-badge
[license-url]: https://github.com/pgodschalk/dotfiles/blob/main/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/patrick-godschalk
[bash]: https://img.shields.io/badge/gnubash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white
[bash-url]: https://www.gnu.org/software/bash/
[python]: https://img.shields.io/badge/python-3776AB?style=for-the-badge&logo=python&logoColor=white
[python-url]: https://www.python.org
[ruby]: https://img.shields.io/badge/ruby-CC342D?style=for-the-badge&logo=ruby&logoColor=white
[ruby-url]: https://www.ruby-lang.org/
