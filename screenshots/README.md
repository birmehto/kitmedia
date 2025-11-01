# Screenshots Directory

This directory contains screenshots of the KitMedia Player app for documentation purposes.

## Screenshot Guidelines

When adding screenshots:

1. **Resolution**: Use high-quality screenshots (at least 1080p)
2. **Format**: Save as PNG for better quality
3. **Naming**: Use descriptive names (e.g., `video_list_dark.png`)
4. **Size**: Keep file sizes reasonable (< 2MB each)
5. **Content**: Ensure no personal/sensitive information is visible

## Required Screenshots

### Core Features
- [ ] `video_list_light.png` - Video library in light mode
- [ ] `video_list_dark.png` - Video library in dark mode
- [ ] `video_player.png` - Video player interface
- [ ] `video_controls.png` - Video player controls overlay
- [ ] `settings_screen.png` - Settings screen
- [ ] `theme_selection.png` - Theme selection interface

### Responsive Design
- [ ] `tablet_view.png` - Tablet/landscape layout
- [ ] `desktop_view.png` - Desktop layout (if applicable)

### Additional Features
- [ ] `search_functionality.png` - Search in action
- [ ] `video_details.png` - Video information screen
- [ ] `empty_state.png` - Empty state when no videos found

## Taking Screenshots

### Android
```bash
# Using ADB
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png
```

### iOS Simulator
- Use `Cmd + S` to save screenshot
- Or use `Device > Screenshot` from menu

### Physical iOS Device
- Use `Volume Up + Power Button` simultaneously

## Optimization

Before committing screenshots:
1. Optimize file sizes using tools like TinyPNG
2. Ensure consistent aspect ratios
3. Crop unnecessary UI elements (status bar, etc.)
4. Use consistent device frames if needed