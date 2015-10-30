import std.stdio;
import std.conv;
import std.exception;
import std.net.curl;
import std.typecons;
import std.format;
import std.json;
import std.uri;

import jsonizer.fromjson;

import message;
import update;

class Bot
{
	private string endpoint;

	this(string token)
	{
		endpoint = format("https://api.telegram.org/bot%s/",token);
	}

	public string performRequest(string method,Tuple!(string,string)[] params = [])
	{
		string response;
		auto http = HTTP(endpoint ~ method ~ generateParameterList(params));
		http.onReceive = (ubyte[] data) { response = cast(string) data; return data.length; };
		http.perform();
		if (parseJSON(response)["ok"].type != std.json.JSON_TYPE.TRUE)
		{
			throw new TelegramAPIException("Request Unsuccessfull: " ~ parseJSON(response)["description"].str);
		}
		return response;
	}

	Update[] getUpdates(bool keepMessages = false)
	{
		Update[] updates;
		string response;
		response = performRequest("getUpdates");
		foreach (jsonUpdate; parseJSON(response)["result"].array)
		{
			Update update = fromJSON!Update(jsonUpdate);
			updates ~= update;
		}
		if (updates.length == 0)
			return updates;
		if (!keepMessages)
		{
			uint offset = updates[$-1].update_id + 1;
			response = performRequest("getUpdates",[tuple("offset",to!string(offset))]);
		}
		return updates;
	}

	Message sendMessage(T)(T recipient,string text)
	{
		text = encode(text);
		auto response = performRequest("sendMessage",[tuple("chat_id",to!string(recipient)),tuple("text",text)]);
		return fromJSON!Message(parseJSON(response)["result"]);
	}
}

class TelegramAPIException : Exception
{
	this(string msg)
	{
		super(msg);
	}
}

string generateParameterList(Tuple!(string,string)[] parameters = [])
{
	if (parameters.length == 0)
	{
		return "";
	}
	string kvpairs;
	foreach (kv;parameters)
	{
		kvpairs ~= format("&%s=%s",kv[0],kv[1]);
	}
	char[] pairs = kvpairs.dup;
	pairs[0] = '?';
	return pairs.dup;
}

unittest
{
	auto params = [tuple("a","b"),tuple("c","d"),tuple("e","f")];
	assert(generateParameterList(params) == "?a=b&c=d&e=f");
}

unittest
{
	Bot testbot = new Bot(environment["bottoken"]);
	assertThrown!TelegramAPIException(testbot.performRequest("getUpdate"));
	// Keep updates
	assertNotThrown(testbot.getUpdates(true));
	// Get updates again but discard them after the request
	assertNotThrown(testbot.getUpdates());
	// Empty response
	assert(testbot.getUpdates().length == 0,"Updates have not been cleared");
	assertNotThrown(testbot.sendMessage(environment["chatid"],"Test Message from your bot.\nURL Encoding 💅 %20"));
}
