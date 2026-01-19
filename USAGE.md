# Usage

## Run everything again

```bash
./bootstrap.sh
```

## Running individual parts

### Software only
```bash
brew bundle --file Brewfile
```

### macOS defaults only
```bash
bash defaults/defaults.safe.sh
bash defaults/defaults.power.sh
bash defaults/apply.sh
```

### Dock layout only
```bash
bash dock/layout.sh
```

### After App Store login
```bash
brew bundle --file Brewfile
```
