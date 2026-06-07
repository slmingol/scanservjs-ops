# Brother MFC-8480DN Mac Scanner Setup

## Menu Bar App (SwiftBar)

1. Install SwiftBar: https://swiftbar.app (free, open source)
2. When SwiftBar asks for a plugins folder, choose or create one (e.g. ~/SwiftBarPlugins)
3. Copy `Brother_Scan.1d.sh` into that folder
4. The 📄 Scan menu will appear in your menu bar immediately

## Finder Right-Click Quick Action

1. Open **Automator** (in /Applications)
2. Choose **New Document** → **Quick Action**
3. Set "Workflow receives" to **no input** in **any application**
4. Drag a **Run Shell Script** action into the workflow
5. Set Shell to `/bin/bash`, Pass input to `as arguments`
6. Paste the contents of `scan_quick_action.sh` into the script box
7. Save as **"Scan Document"**
8. It will now appear in **Finder → Services menu** and in right-click menus

## Usage

### Menu bar
- Click 📄 Scan in the menu bar
- Choose your format and resolution
- Scan saves to Downloads and opens automatically

### Right-click / Services
- Right-click anywhere in Finder (or use Finder menu → Services)
- Click "Scan Document"
- PDF saves to Downloads and opens automatically
