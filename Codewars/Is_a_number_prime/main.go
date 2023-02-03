package kata

import (
	"errors"
	"math"
)

func IsPrime(n int) bool {
	return IsPrimeRecursion(n)
	// return IsPrimeIteration(n)
}

func IsPrimeIteration(n int) bool {
	if n < 2 {
		return false
	}

	// omit 0 and 1 then start at 2 with 0 index
	sieve := make([]bool, n-1)

	for i := range sieve {
		sieve[i] = true
	}

	for mp := 2; ; {
		multiples, err := getMultiples(mp, n)
		if err != nil {
			panic(err)
		}
		for _, v := range multiples {
			sieve[v-2] = false
		}

		if float64(mp) > math.Sqrt(float64(n)) {
			break
		}

		for i, v := range sieve {
			if i > mp-2 && v == true {
				mp = i + 2
				break
			}
		}
	}

	return sieve[n-2]
}

func IsPrimeRecursion(n int) bool {
	if n < 2 {
		return false
	}

	var primes []int
	sieve := make([]bool, n+1)

	for i := range sieve {
		if i == 0 || i == 1 {
			sieve[i] = false
		} else {
			sieve[i] = true
		}
	}

	result := crossOut(2, n, sieve)

	for i, v := range result {
		if v == true {
			primes = append(primes, i)
		}
	}

	for _, v := range primes {
		if n == v {
			return true
		}
	}

	return false
}

func crossOut(prime int, limit int, sieve []bool) []bool {
	_sieve := append([]bool{}, sieve...)

	multiples, err := getMultiples(prime, limit)
	if err != nil {
		panic(err)
	}
	for _, v := range multiples {
		_sieve[v] = false
	}

	var nextPrime int
	for i, v := range sieve {
		if i > prime && v == true {
			nextPrime = i
			break
		}
	}

	if nextPrime == 0 {
		return sieve
	}

	if float64(prime) > math.Sqrt(float64(limit)) {
		return sieve
	}

	return crossOut(nextPrime, limit, _sieve)
}

func getMultiples(n int, limit int) ([]int, error) {
	var result []int

	if n < 1 {
		return nil, errors.New("error")
	}

	for i := 1; true; {
		i++
		m := n * i
		if m > limit {
			break
		}
		result = append(result, m)
	}

	return result, nil
}
