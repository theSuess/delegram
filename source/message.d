import jsonizer;
import chat;

struct Message
{
	mixin JsonizeMe;
	@jsonize Chat chat;
	@jsonize (JsonizeOptional.yes) User from;
	@jsonize string text;
}

struct User
{
	mixin JsonizeMe;
	@jsonize uint id;
	@jsonize string first_name;
	@jsonize (JsonizeOptional.yes) string last_name;
	@jsonize (JsonizeOptional.yes) string username;
}
