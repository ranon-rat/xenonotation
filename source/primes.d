module primes;
import consts;
import std.range : iota;
import std.array : array;
import std.algorithm.comparison : min;
import std.stdio;

import std.algorithm;

struct PrimeDiv
{
    size_t number = 0;
    size_t lastSeen = 0;
    this(size_t n, size_t ls)
    {
        this.number = n;
        this.lastSeen = ls;
    }

}

// i would like to be able to just call it from the memory and to get access to it directly without actually having to deal with a lot of issues
synchronized class PrimeGenerator
{
    /*
    TODO:

    Add thread secure mutation so this can be used for multiple people accessing the memory and other stuff
    */
private:
    size_t lastChecked = 0;
    PrimeDiv[] primes = [];
    // this will be checking it in batches of 100
public:
    size_t[] primesSnapshot()
    {
        return primes.map!(p => p.number).array;
    }

    void findMorePrimes(size_t to)
    {

        if ((to > maxnumber && lastChecked >= maxnumber + batchsize) ||
            (to < lastChecked))
            return;

        size_t[] numbers = iota(lastChecked, to).array;
        bool[] alreadyVisited = new bool[to - lastChecked];
        alreadyVisited[] = false;

        for (size_t i = 0; i < this.primes.length; i++)
        {
            auto prime = this.primes[i];
            // if it tries to get to the point of the to then it stops at that point
            if (prime.number + prime.lastSeen > to)
                continue;
            for (size_t j = prime.lastSeen + prime.number - lastChecked; j < numbers.length;
                j += prime.number)
            {
                alreadyVisited[j] = true;
                prime.lastSeen = lastChecked + j;
            }
            this.primes[i] = prime; //9885 is not a prime yet its being added WHY?
        }
        for (size_t i = 0; i < numbers.length; i++)
        {
            if (alreadyVisited[i] || numbers[i] <= 1)
                continue;
            auto currentPrime = PrimeDiv(numbers[i], lastChecked + i);
            for (size_t j = i + currentPrime.number; j < numbers.length; j += currentPrime.number)
            {
                alreadyVisited[j] = true;
                currentPrime.lastSeen = lastChecked + j;
            }
            this.primes ~= currentPrime;

        }
        this.lastChecked = to;

    }

    size_t getIndexPrime(size_t n)
    {
        for (size_t i = 0; i < this.primes.length; i++)
        {
            if (this.primes[i].number == n)
            {
                return i;
            }
        }
        throw new Exception("No prime found");

    }

    size_t getPrime(size_t i)
    {
        if (i < primes.length)
            return primes[i].number;
        if (lastChecked >= maxnumber)
            throw new Exception("this number is way too big");

        while (i >= this.primes.length)
        {

            size_t to = min(lastChecked + batchsize, maxnumber);
            if (to >= maxnumber)
                throw new Exception("big number"); //return this.primes[$ - 1].number;
            this.findMorePrimes(to);
        }

        return this.primes[i].number;
    }
}

/*
There might be a better way of doing this but i obviously prefer to just avoid increasing the complexity of this
*/
size_t[] factorizeNumber(shared(PrimeGenerator) generator, size_t n)
{
    synchronized
    {
        generator.findMorePrimes(min(n + batchsize, maxnumber));
    }
    size_t number = n;
    size_t[] factors;
    auto primes = generator.primesSnapshot();

    check_again: foreach (prime; primes)
    {
        if (number % prime == 0)
        {
            // the generator has found every prime that has come before that number
            // so when this happens the value of the number is decreased
            // so i know that i will end up adding it at some point i have all of the factors needed here
            number /= prime;
            factors ~= prime;
            goto check_again;
        }

    }
    // i would like to be able to go through a numer verifying that its a prime or not, once we generate all of these we need to do something simple, first lets try to do this
    // it will obviously return itself at some point :)
    return factors;
}
