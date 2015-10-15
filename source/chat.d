import jsonizer;
enum chatType { Private = "private",Group = "group", Channel = "channel" }

struct Chat
{
	mixin JsonizeMe;
	@jsonize uint id;
	string first_name;
	string last_name;
	string username;
	@jsonize chatType type;
}
