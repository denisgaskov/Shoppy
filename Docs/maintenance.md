# Maintenance

## How to rename the project

1. Close Xcode
2. Open project directory in any text editor (i. e. VS Code)
3. Use search / replace for entries "Minimal". Replace with new project name
  - If you change the bundle ID (however in production it should not be the case), don't forget to update:
    - Provisioning profiles
    - GoogleServices-Info.plist
    - etc
4. Open project directory in terminal. Execute `find . | grep Minimal` to find and replace all file names and paths
5. Rename GitHub repository
5. (Optional) Rename project in all other portals: AppStore Connect, Firebase, Leanplum, etc.
