# Repak Installer

A simple PowerShell installer for [Repak-X](https://github.com/XzantGaming/Repak-X).

I automate pretty much everything on my end, and since I use Repak-X across multiple PCs this script saves me from manually downloading releases and setting things up each time.

## What it does

- Fetches the latest release from GitHub automatically
- Extracts everything into `%LocalAppData%\Repak-X`
- Creates a Start Menu shortcut so you can search for it like any regular app

## Usage

Paste this into PowerShell and you're done:

```powershell
powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/omarnunezsiri/RepakInstaller/master/Install-RepakX.ps1 | iex"
```

## Thanks

All credit for Repak-X goes to the folks over at [XzantGaming/Repak-X](https://github.com/XzantGaming/Repak-X). This repo is just a convenience wrapper around their releases.
