# Third-party notices

`xp_heli_assistent` builds against the components below. Their licences govern
those components and take precedence over the licence of this software for them.

**This file must accompany every copy of the software.** Dear ImGui's licence requires it
in so many words, and the plugin binary contains Dear ImGui.

---

## Dear ImGui 1.93.0

Immediate-mode GUI, compiled into the plugin binary. Every window this plugin draws is
drawn with it.

- Home: https://github.com/ocornut/imgui
- Licence: **MIT**
- Fetched by `make setup` into `vendor/imgui/`, licence text in `vendor/imgui/LICENSE.txt`

```
The MIT License (MIT)

Copyright (c) 2014-2026 Omar Cornut

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## X-Plane SDK 4.3.0 (XPSDK430)

Laminar Research's plugin SDK. The plugin links against `XPLM` and `XPWidgets`.

- Home: https://developer.x-plane.com/sdk/
- Licence: Laminar Research SDK terms, which permit commercial plugins
- Fetched by `make setup` into `sdk/`

The SDK's own licence text ships inside the downloaded archive. Redistributing the SDK
headers or libraries beyond what a plugin binary requires is not permitted; this plugin
does not redistribute them.

---

## Catch2 3.16.1

Unit test framework. **Not part of the plugin binary** — it is compiled only into
`xp_heli_assistent_tests`, which is not distributed.

- Home: https://github.com/catchorg/Catch2
- Licence: **Boost Software License 1.0**
- Fetched by `make setup` into `vendor/catch2/`, licence text in `vendor/catch2/LICENSE.txt`

Listed here for completeness rather than obligation: a component that never reaches the
user carries no attribution duty towards them. It is named so that anyone auditing the
build knows what went into it.

---

## What is not third-party

The aircraft profiles in `profiles/`, the tuning files in `basis/`, the analysis tools in
`tools/` and all source under `src/` are the work of the author. The measured constants in
the profiles were flown and recorded on the author's own installation; they describe the
behaviour of add-on aircraft, but contain nothing from those add-ons.
