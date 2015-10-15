import std.stdio;
import std.conv;
import std.exception;
import std.net.curl;
import std.typecons;
import std.format;
import std.json;

import jsonizer.fromjson;

import message;
import utils;
import update;

class Bot
{
	private string endpoint;
	private uint offset = 0;

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
		if (offset == 0)
			response = performRequest("getUpdates");
		else
			response = performRequest("getUpdates",[tuple("offset",to!string(offset))]);
		foreach (jsonUpdate; parseJSON(response)["result"].array)
		{
			Update update = fromJSON!Update(jsonUpdate);
			updates ~= update;
		}
		if (updates.length == 0)
			return updates;
		if (!keepMessages)
		{
			offset = updates[$-1].update_id +1;
		}
		return updates;
	}
}

class TelegramAPIException : Exception
{
	this(string msg)
	{
		super(msg);
	}
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
}
