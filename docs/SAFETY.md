# Safety Notes

`cleanroom` is designed around a hard lesson: app profile folders can contain irreplaceable local state.

Never delete these by default:

- `~/Library/Application Support/Google/Chrome`
- `~/Library/Application Support/BraveSoftware`
- `~/Library/Application Support/Arc`
- `~/Library/Keychains`
- `~/Pictures/Photos Library.photoslibrary`
- `~/Library/Mail`
- `~/Library/Mobile Documents`

The app cache cleaner only removes nested folders with names like:

- `Cache`
- `Code Cache`
- `GPUCache`
- `DawnCache`
- `ShaderCache`
- `CachedData`
- `Crashpad`

It must not remove the whole profile folder.
