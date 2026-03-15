#!/usr/bin/env node
// Usage: compile-userstyle.js <site.user.less> <palette-json>
// Compiles a catppuccin userstyle LESS file with a custom palette injected.

const less = require('/home/honey/.local/lib/node_modules/less');
const fs   = require('fs');
const path = require('path');

const [,, lessFile, paletteJson] = process.argv;
if (!lessFile || !paletteJson) {
  process.stderr.write('Usage: compile-userstyle.js <file.user.less> <palette.json>\n');
  process.exit(1);
}

const palette = JSON.parse(paletteJson);
const src     = fs.readFileSync(lessFile, 'utf8');
const libDir  = path.dirname(lessFile);

// We override the "mocha" flavor in @catppuccin with our theme colors.
// LESS uses lazy variable resolution, so a definition placed *after* the import wins.
// We also set @darkFlavor / @lightFlavor to mocha and lock @accentColor.
const paletteOverride = `
@darkFlavor:  mocha;
@lightFlavor: mocha;
@accentColor: ${palette.accentColor};

// Override mocha flavor with our custom theme colors
@catppuccin: {
  @latte:     { @rosewater: #f5e0dc; @flamingo: #f2cdcd; @pink: #f5c2e7; @mauve: #cba6f7; @red: #f38ba8; @maroon: #eba0ac; @peach: #fab387; @yellow: #f9e2af; @green: #a6e3a1; @teal: #94e2d5; @sky: #89dceb; @sapphire: #74c7ec; @blue: #89b4fa; @lavender: #b4befe; @text: #cdd6f4; @subtext1: #bac2de; @subtext0: #a6adc8; @overlay2: #9399b2; @overlay1: #7f849c; @overlay0: #6c7086; @surface2: #585b70; @surface1: #45475a; @surface0: #313244; @base: #1e1e2e; @mantle: #181825; @crust: #11111b; };
  @frappe:    { @rosewater: #f2d5cf; @flamingo: #eebebe; @pink: #f4b8e4; @mauve: #ca9ee6; @red: #e78284; @maroon: #ea999c; @peach: #ef9f76; @yellow: #e5c890; @green: #a6d189; @teal: #81c8be; @sky: #99d1db; @sapphire: #85c1dc; @blue: #8caaee; @lavender: #babbf1; @text: #c6d0f5; @subtext1: #b5bfe2; @subtext0: #a5adce; @overlay2: #949cbb; @overlay1: #838ba7; @overlay0: #737994; @surface2: #626880; @surface1: #51576d; @surface0: #414559; @base: #303446; @mantle: #292c3c; @crust: #232634; };
  @macchiato: { @rosewater: #f4dbd6; @flamingo: #f0c6c6; @pink: #f5bde6; @mauve: #c6a0f6; @red: #ed8796; @maroon: #ee99a0; @peach: #f5a97f; @yellow: #eed49f; @green: #a6da95; @teal: #8bd5ca; @sky: #91d7e3; @sapphire: #7dc4e4; @blue: #8aadf4; @lavender: #b7bdf8; @text: #cad3f5; @subtext1: #b8c0e0; @subtext0: #a5adcb; @overlay2: #939ab7; @overlay1: #8087a2; @overlay0: #6e738d; @surface2: #5b6078; @surface1: #494d64; @surface0: #363a4f; @base: #24273a; @mantle: #1e2030; @crust: #181926; };
  @mocha: {
    @rosewater: ${palette.rosewater};
    @flamingo:  ${palette.flamingo};
    @pink:      ${palette.pink};
    @mauve:     ${palette.mauve};
    @red:       ${palette.red};
    @maroon:    ${palette.maroon};
    @peach:     ${palette.peach};
    @yellow:    ${palette.yellow};
    @green:     ${palette.green};
    @teal:      ${palette.teal};
    @sky:       ${palette.sky};
    @sapphire:  ${palette.sapphire};
    @blue:      ${palette.blue};
    @lavender:  ${palette.lavender};
    @text:      ${palette.text};
    @subtext1:  ${palette.subtext1};
    @subtext0:  ${palette.subtext0};
    @overlay2:  ${palette.overlay2};
    @overlay1:  ${palette.overlay1};
    @overlay0:  ${palette.overlay0};
    @surface2:  ${palette.surface2};
    @surface1:  ${palette.surface1};
    @surface0:  ${palette.surface0};
    @base:      ${palette.base};
    @mantle:    ${palette.mantle};
    @crust:     ${palette.crust};
  };
};
`;

// Extract checkbox defaults from the ==UserStyle== header before stripping it
const checkboxDefaults = [];
const headerMatch = src.match(/\/\* ==UserStyle==([\s\S]*?)==\/UserStyle== \*\//m);
if (headerMatch) {
  for (const m of headerMatch[1].matchAll(/@var\s+checkbox\s+(\w+)\s+"[^"]*"\s+(\d)/g)) {
    checkboxDefaults.push(`@${m[1]}: ${m[2]};`);
  }
}

const checkboxVars = checkboxDefaults.join('\n');

// Strip ==UserStyle== header block, replace CDN import with local, strip stray @var lines
const cleaned = src
  .replace(/\/\* ==UserStyle==[\s\S]*?==\/UserStyle== \*\//m, '')
  .replace(/@import\s+"https:\/\/userstyles\.catppuccin\.com\/lib\/lib\.less";/,
           `@import "${libDir}/lib.less";\n${checkboxVars}\n${paletteOverride}`)
  .replace(/@preprocessor\s+\S+;?/g, '')
  .replace(/@var\s+\S+[^\n]*/g, '');

less.render(cleaned, { compress: false })
  .then(output => process.stdout.write(output.css))
  .catch(err   => { process.stderr.write(err.message + '\n'); process.exit(1); });
