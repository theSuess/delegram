import jsonizer;
import message;
import chat;

struct Update
{
	mixin JsonizeMe;
	@jsonize int update_id;
	@jsonize Message message;
}
