What this does

The bootstrap.sh script performs the following steps:

Installs Rosetta (Apple Silicon only)

Installs Xcode Command Line Tools (if missing)

Installs Homebrew

Sets up zsh

.zprofile (Homebrew shellenv)

.zshrc (PATH de-duplication, history, completion, minimal prompt)

Installs software via Brewfile

CLI tools

GUI applications (casks)

Mac App Store apps (via mas)

Applies macOS system preferences

safe defaults

power / security-related defaults

Applies a predefined Dock layout

Restarts affected services (Finder, Dock, SystemUIServer)

The script is designed to be idempotent and can be re-run.

Expected prompts (important)
macOS user password (sudo)

You will be prompted for your macOS user password for:

Rosetta installation

power-related system defaults

firewall and power management settings

This typically happens once per run.

Mac App Store (MAS) login

The script checks whether you are signed in

If not, it opens the App Store and waits

You can choose:

Sign in now (recommended)

Skip MAS apps for this run

Abort

What will NOT be requested

iCloud credentials (never handled by the script)

Apple ID login via CLI

any stored or logged passwords

Repository structure
Initial-macOS-setup/
├── bootstrap.sh              # main entry point (run this)
├── Brewfile                  # all software definitions
│
├── defaults/
│   ├── defaults.safe.sh      # safe macOS defaults
│   ├── defaults.power.sh     # power / security defaults (sudo)
│   └── apply.sh              # apply + restart services
│
├── dock/
│   └── layout.sh             # Dock layout (dockutil)
│
├── README.md
└── USAGE.md

Customization

You are expected to customize this repo:

Software

edit Brewfile

System preferences

edit scripts in defaults/

Dock

edit dock/layout.sh

Re-run ./bootstrap.sh after changes.

Safety notes

No credentials are stored

No hidden background services are installed

Some settings may require logout or reboot to fully apply

Power defaults intentionally trade convenience vs. security — review them

License

MIT (or choose another, but define one)


---

# 📄 `USAGE.md`

```markdown
# Usage & Troubleshooting

This document explains how to use this repository beyond the initial run
and how to deal with common issues.

---

## Running everything again

```bash
./bootstrap.sh


Safe to run multiple times. Most steps are idempotent or best-effort.

Running individual parts
Install / update software only
brew bundle --file Brewfile


Useful after:

signing into the App Store later

editing Brewfile

Apply macOS defaults only
bash defaults/defaults.safe.sh
bash defaults/defaults.power.sh
bash defaults/apply.sh

Apply Dock layout only
bash dock/layout.sh


Requires dockutil to be installed.

Mac App Store (MAS) behaviour

MAS apps require you to be signed into the App Store

The bootstrap script detects login state

If skipped, MAS apps are not installed

After signing in later, simply run:

brew bundle --file Brewfile

Common issues
xcode-select --install says tools are already installed

This is normal. The script continues automatically.

Some cask installs fail with Gatekeeper / quarantine warnings

This is expected for certain applications.
Options:

approve manually in System Settings

re-run brew install --cask <app>

review Gatekeeper settings in defaults.power.sh

dock/layout.sh skips some apps

The script only adds apps that actually exist in /Applications.
Missing apps are skipped intentionally.

Completion warnings (compinit: insecure directories)

This usually means leftover permissions from previous setups.
Fix manually if needed:

compaudit

Design decisions (FAQ)
Why not everything via Homebrew?

Some applications:

have their own updaters

require manual configuration

are intentionally not auto-updated

They may still appear in Brewfile for inventory and initial install.

Why split defaults into safe and power?

To keep:

safe defaults usable everywhere

power defaults explicit and reviewable

This avoids accidental security changes.

Expected manual steps (cannot be automated)

App Store login (Apple limitation)

approving certain system permissions

occasional reboot or logout

Everything else is automated.

Final note

This setup is meant for your own machines.
It is not an MDM replacement and does not attempt to be.

If something feels surprising, read the scripts — they are the source of truth.
