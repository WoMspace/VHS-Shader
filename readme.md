# ARCHIVED REPO. REPLACEMENT REPO IS [HERE](https://github.com/WoMspace/Epoch-Shader)

A shaderpack that attempts to emulate an old VHS tape.

Todo
- Random glitches
- Occasional image transforms
- Tonemapping? aces? DYNAMIC EXPOSURE?
- Load in dimension rewind effect
- FILM MODE???
    - Customizable film grain
    - Film shake
    - Light Leaks o.O
    - color grading
- Anamorphic effects ( ͡° ͜ʖ ͡°)
    - And other lens effects
- Fix bokeh
    - Fix depth blending
    - Fix fog
    - Fix autofocus
- TAA..?


BUFFER USAGE:
- colortex0: gcolor
    Writes: composite0-2
    Reads: composite0-2
    Effects: 2-pass gaussian blur
    Holds: Main screen.
- colortex1:
    N/A
colortex2:
    Writes: composite1
    Reads: composite1
    Nonclearing
    Effects: Interlacing
    Holds: Main screen but a frame delayed.
colortex3:
    Writes: composite2
    Reads: composite2
    Nonclearing
    Effects: Ghosting
    Holds: Accumulated main screen.
colortex4:
    Writes: shaders.properties
    Reads: composite2
    Effects: texture-based CRT mode
    Holds: CRT RGB texture
