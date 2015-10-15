# delegram
dlang Telegram API Wrapper

## Usage

```d
import delegram;
import std.stdio;

void main()
{
  Bot b = new Bot("BOT TOKEN");
  auto updates = b.getUpdates();
  foreach (update;updates)
  {
    b.sendMessage(update.message.chat.id,"Hello there, you sent me: " ~ update.message.text);
  }
}
