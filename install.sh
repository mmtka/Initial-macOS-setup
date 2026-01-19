echo 'Set macOS defaults...'
bash <(curl -s https://gist.githubusercontent.com/mmtka/5e547eadcf7a79dc80aa77e1d1ddbd54/raw/6e7c10b87f458063aefe701a5a628edf82e36b2d/defaults.sh)

echo 'Install base macOS software'
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

brew analytics off
export HOMEBREW_NO_ANALYTICS=1

cd ~
curl https://gist.githubusercontent.com/mmtka/5e547eadcf7a79dc80aa77e1d1ddbd54/raw/6e7c10b87f458063aefe701a5a628edf82e36b2d/Brewfile -o Brewfile
brew bundle

rm Brewfile

echo 'Finished. Some changes require a restart to take effect.'