# Initial macOS Setup

Opinionated, reproducible macOS bootstrap for power users.

This repository automates the initial setup of a clean macOS system:
- system preferences (defaults)
- software installation (Homebrew + Brewfile)
- Dock layout
- shell initialization (zsh)
- Apple Silicon specifics (Rosetta)

The goal is **one command**, minimal manual work, and a system that can be rebuilt at any time.

---

## Quick start (recommended)

```bash
git clone https://github.com/mmtka/Initial-macOS-setup.git
cd Initial-macOS-setup
./bootstrap.sh
