# Repository Structure

```
Initial-macOS-setup/
├── bootstrap.sh           # Main setup script
├── install.sh             # One-liner installer
├── config.sh              # User configuration
├── Brewfile               # Full package list
│
├── defaults/              # macOS system settings
│   ├── defaults.safe.sh   # Safe settings (no sudo)
│   ├── defaults.power.sh  # Advanced settings (requires sudo)
│   └── apply.sh           # Apply & restart services
│
├── dock/                  # Dock configuration
│   └── layout.sh          # Dock layout with dynamic Adobe detection
│
├── lib/                   # Shared libraries
│   └── backup.sh          # Backup/restore functions
│
├── hooks/                 # Customization hooks
│   ├── pre-bootstrap.sh   # Pre-setup checks
│   └── post-bootstrap.sh  # Post-setup tasks
│
├── profiles/              # Installation profiles
│   ├── minimal.Brewfile   # Essentials only (~500MB)
│   └── work.Brewfile      # Development setup (~2GB)
│
├── .github/
│   └── workflows/
│       └── validate.yml   # CI/CD validation
│
└── docs/
    ├── README.md          # Main documentation
    ├── INSTALL.md         # Installation guide
    ├── USAGE.md           # Usage instructions
    ├── STRUCTURE.md       # This file
    └── FAQ.md             # Frequently asked questions
```

## Key Design Principles

### Separation of Concerns
- **Safe vs Power defaults**: Security-relevant settings are explicit and require sudo
- **Modular scripts**: Each component can be run independently
- **Configuration externalized**: User settings in `config.sh`, not hardcoded

### Extensibility
- **Hooks system**: Pre/post-bootstrap customization without modifying core
- **Profiles**: Different installation levels (minimal/work/full)
- **Library functions**: Reusable backup/restore mechanisms

### Reliability
- **Idempotent**: Safe to run multiple times
- **Automatic backup**: System state saved before changes
- **CI/CD validation**: Every commit tested via GitHub Actions
- **Comprehensive logging**: All output saved to timestamped logs

## File Responsibilities

| File | Purpose | Requires sudo |
|------|---------|---------------|
| `bootstrap.sh` | Orchestrates entire setup | Partially |
| `config.sh` | User-editable configuration | No |
| `Brewfile` | Package definitions | No |
| `defaults/defaults.safe.sh` | UI/UX preferences | No |
| `defaults/defaults.power.sh` | System-level changes | Yes |
| `defaults/apply.sh` | Restart affected services | No |
| `dock/layout.sh` | Dock configuration | No |
| `lib/backup.sh` | Backup/restore utilities | No |
| `hooks/*.sh` | User customizations | Optional |

## Data Flow

```
bootstrap.sh
    ↓
[Load config.sh]
    ↓
[Pre-bootstrap hook]
    ↓
[System checks: Rosetta, Xcode, Homebrew]
    ↓
[Create backup]
    ↓
[Install packages: brew bundle]
    ↓
[Apply defaults: safe + power]
    ↓
[Configure dock]
    ↓
[Post-bootstrap hook]
    ↓
[Complete]
```

## Customization Points

1. **config.sh** - Change locale, timezone, feature flags
2. **Brewfile** - Add/remove applications
3. **profiles/** - Use different installation profiles
4. **hooks/pre-bootstrap.sh** - Add pre-flight checks
5. **hooks/post-bootstrap.sh** - Add post-install tasks
6. **defaults/*.sh** - Modify system preferences
7. **dock/layout.sh** - Customize dock applications

This architecture ensures scripts remain the source of truth while providing flexibility for personal customization.
