import std.stdio;
import primes;
import consts;
import xenonotation;
import std.range : iota;
import std.array;
import std.algorithm;

void main()
{
	auto generator = new shared(PrimeGenerator);

	for (size_t i = 1; i < maxnumber; i++)
	{
		try
		{
			auto xenoNotation = number2xenonotation(generator, i);
			auto result = xenonotation2number(generator, xenoNotation);
			writeln(i, " xenonotation: ", xenoNotation, "\t\t conversion:", result);
		}
		catch (Exception e)
		{
			writeln("chill daddy");
			break;
		}
	}
}
