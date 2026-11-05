module xenonotation;

import consts;
import primes;

string number2xenonotation(shared(PrimeGenerator) generator, size_t n)
{
    if (n > maxnumber)
        throw new Exception("the value being passed is way too big");
    if (n <= 1)
        return "";

    if (n == 2)
        return "0";

    string output;
    size_t[] factors = factorizeNumber(generator, n);
    foreach (factor; factors)
    {
        if (factor == 2)
        {
            output ~= "0";
            continue;
        }
        size_t index = generator.getIndexPrime(factor);

        output ~= "(" ~ number2xenonotation(generator, index + 1) ~ ")";
    }
    return output;
}
// i could directly evaluate this // the (x) is a function that calls the position just the pure 0 just calls 2
size_t xenonotation2number(shared(PrimeGenerator) generator, string notation)
{
    if (notation == "")
        return 0;
    if (notation == "0")
        return 2;
    size_t position = 0;
    return evaluateXenonotation(generator, notation, &position);
}

// this will directly call the position
// would be ideal to first compute the biggest result that we could get 0000((0))((0))((0))((0))
size_t evaluateXenonotation(shared(PrimeGenerator) generator, string notation, size_t* index, size_t depth = 0)
{
    if (depth > maxdepth)
        return 0;
    size_t output = 1;
    mainLoop: while (*index < notation.length)
    {
        char current = notation[*index];
        switch (current)
        {
        case '(':

            (*index)++;
            size_t result = evaluateXenonotation(generator, notation, index, depth + 1);
            if (result == 0)
                return 0;
            if (output >= maxnumber / result)
                return 0;

            output *= generator.getPrime(result - 1);

            break;
        case ')':
            break mainLoop;
        case '0':
            if (output >= maxnumber / 2)
                return 0;
            output *= 2;
            break;
        default:
            throw new Exception("The fuck is this?");
        }
        if (output == 0)
            return 0;
        (*index)++;
    }
    return output;
}
