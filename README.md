# claude-statusline
Custom statusline for claude using dracula colors 


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
