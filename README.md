# claude-statusline

Renders a **Powerline-style status bar** for Claude Code sessions. Reads JSON from stdin (provided by Claude Code) and outputs colored segments separated by arrow glyphs, giving at-a-glance context about your session all with Dracula style colors. 


<img width="547" height="63" alt="Screenshot 2026-05-07 at 4 40 09 PM" src="https://github.com/user-attachments/assets/40d9d30b-6320-47c4-a439-a9fc3b05e098" />


## How to Use

1. Download the `statusline-command.sh` to your `~/.claude/` folder
2. Set it up to run
```bash
chmod +x ~/.claude/statusline-command.sh
```
3. Update your `~/.claude/settings.json` to use the file
```json
{
  "statusLine": {
    "type": "command",
    "command": "sh ~/.claude/statusline-command.sh"
  }
}
```
4. Restart Claude



### Segments (left to right)

**1. Directory** — `#BD93F9` Dracula Purple
Shows the current working directory. Deep paths under `$HOME` are abbreviated to `…/basename`. Home itself shows as `~`.

**2. Git Branch** — `#FF79C6` Dracula Pink
Only shown inside a git repo. Displays a git icon + branch name. Also tracks the count of modified/untracked files for use in the diff segment.

**3. Model** — `#8BE9FD` Dracula Cyan
Displays the active Claude model with a model-specific icon:
- Sonnet → 
- Haiku → 
- Opus → 

**4. Context Window** — `#50FA7B` Dracula Green
A 10-segment progress bar showing how full the context window is, followed by the percentage. Filled segments use the green foreground; unfilled segments fade through dark shades of Dracula's current-line color (`#44475A` → `#282A36`).

**5. Lines / Diff** — `#FFB86C` Dracula Orange
Shows lines added (`+`) and lines removed (`−`) for the session, plus a file-diff count if there are uncommitted git changes. Only shown when there is something to report.

### Trailing Fade

After the last segment, three progressively darker arrows fade to the terminal background using Dracula's neutral ramp:

| Step | Color | Hex |
|---|---|---|
| 1 | Comment purple | `#6272A4` |
| 2 | Current line | `#44475A` |
| 3 | Background | `#282A36` |

The same fade is used regardless of which segment is last.


### Dracula Color Palette Used

| Role | Hex | RGB |
|---|---|---|
| Directory bg | `#BD93F9` | `189;147;249` |
| Git branch bg | `#FF79C6` | `255;121;198` |
| Model bg | `#8BE9FD` | `139;233;253` |
| Context bg | `#50FA7B` | `80;250;123` |
| Lines/diff bg | `#FFB86C` | `255;184;108` |
| Text (all segs) | `#282A36` | `40;42;54` |
| Fade step 1 | `#6272A4` | `98;114;164` |
| Fade step 2 | `#44475A` | `68;71;90` |
| Fade step 3 | `#282A36` | `40;42;54` |
| Progress unfilled | `#44475A` tints | `68;71;90` → darker |
