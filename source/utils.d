import std.typecons;
import std.stdio;
import std.format;
import std.string;

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
