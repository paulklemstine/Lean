# The Number That Kills All Primes

## How a Lonely Integer Defeats Every Prime-Hunting Algorithm

There is a number — 78,557 — that possesses a remarkable and sinister property. Take this number, multiply it by any power of 2, add 1, and the result is *never* prime. Not for 2¹. Not for 2¹⁰⁰. Not for 2^(a googol). Not for any power of 2 at all, stretching out to infinity.

This makes 78,557 what mathematicians call a *Sierpiński number*, named after the Polish mathematician Wacław Sierpiński, who proved in 1960 that such numbers must exist. But proving existence is one thing. Actually finding the smallest such number — and proving it is the smallest — is a challenge that has consumed decades of computation and remains unresolved today.

## The Sieve That Catches Everything

How can you prove that an infinite sequence of numbers — 78,557 × 2 + 1, then 78,557 × 4 + 1, then 78,557 × 8 + 1, and so on forever — contains no primes at all? You obviously cannot check them one by one. The answer lies in one of the most elegant constructions in number theory: the *covering system*.

Imagine you are sorting mail into seven bins. Each bin has a rule: "accept every 2nd letter," "accept every 4th letter," "accept every 3rd letter," and so on. If your rules are designed so that every letter ends up in at least one bin, you have a covering system — every integer is "covered" by at least one rule.

For 78,557, mathematicians found seven bins with seven rules:

| Rule | Associated Prime |
|------|-----------------|
| Every even-numbered n | 3 |
| n ≡ 1 (mod 4) | 5 |
| n ≡ 1 (mod 3) | 7 |
| n ≡ 11 (mod 12) | 13 |
| n ≡ 15 (mod 18) | 19 |
| n ≡ 27 (mod 36) | 37 |
| n ≡ 3 (mod 9) | 73 |

The magic: every integer falls into at least one of these bins. And for each bin, the associated prime divides every number of the form 78,557 × 2^n + 1 when n falls into that bin. Since the bins cover everything, every value 78,557 × 2^n + 1 is divisible by one of these seven small primes — and since the values are much larger than 73, none of them can be prime.

## The Mathematical Machine

Why does this work? The trick exploits a deep connection between modular arithmetic and exponentiation. Consider the prime 73. The powers of 2, taken modulo 73, cycle with period 9:

2¹ ≡ 2, 2² ≡ 4, 2³ ≡ 8, 2⁴ ≡ 16, 2⁵ ≡ 32, 2⁶ ≡ 27, 2⁷ ≡ 54, 2⁸ ≡ 35, 2⁹ ≡ 1

After nine steps, we're back to 1, and the cycle repeats. This means that if 73 divides 78,557 × 2³ + 1, then it also divides 78,557 × 2¹² + 1, and 78,557 × 2²¹ + 1, and every value where the exponent is 3 more than a multiple of 9.

Each of the seven primes has its own cycle length — 2, 4, 3, 12, 18, 36, and 9 respectively. The covering system exploits these different periods to ensure that every possible exponent is "caught" by at least one prime's cycle.

This connection to the Chinese Remainder Theorem — the ancient result that says systems of modular equations with coprime moduli always have solutions — gives the construction its mathematical backbone. The moduli 2, 4, 3, 12, 18, 36, and 9 interleave so that their union covers all integers, while the Chinese Remainder Theorem guarantees that the overlapping regions behave consistently.

## The Smallest Sierpiński Number: An Open Problem

John Selfridge conjectured in 1962 that 78,557 is the *smallest* Sierpiński number. To prove this, one would need to show that every odd number less than 78,557 is *not* a Sierpiński number — meaning for each such k, at least one value k × 2^n + 1 must be prime.

For most numbers below 78,557, this is easy: the first few values k × 2 + 1, k × 4 + 1, k × 8 + 1 quickly yield a prime. But five stubborn candidates remain:

**21,181** · **22,699** · **24,737** · **55,459** · **67,607**

For each of these numbers, decades of computation — checking values of n into the tens of millions — have failed to find a single prime. The distributed computing project "Seventeen or Bust" (later "PrimeGrid") has been chipping away at candidates since 2002. They started with 17 candidates and have eliminated 12, but the last five have resisted every computational assault.

The irony is exquisite: to prove that 78,557 is the *smallest* number with a certain negative property (no primes exist), we need to find *positive* evidence (a specific prime) for each smaller candidate. It is the mathematical equivalent of proving you are the worst at something by finding a redeeming quality in everyone else.

## Density and Necessity

A beautiful constraint governs covering systems: the sum of the reciprocals of the moduli must be at least 1. Think of it as a "budget" — if each congruence class n ≡ r (mod m) covers a fraction 1/m of all integers, you need enough classes to cover everything. For 78,557's covering system, this sum is approximately 1.36, meaning there is about 36% "overlap" where multiple primes simultaneously divide the target.

This density constraint has deep implications. It means you cannot build a covering system from primes with very large multiplicative orders — you need enough small-order primes to accumulate sufficient density. This is why the covering primes for 78,557 are relatively small (3, 5, 7, 13, 19, 37, 73) rather than astronomically large.

## The Deeper Pattern

Covering systems are not just a tool for Sierpiński numbers. They appear throughout number theory as a way to transform infinite problems into finite ones. The same technique proves results about Riesel numbers (where k × 2^n − 1 is always composite), about perfect numbers, and about the distribution of primes in arithmetic progressions.

At their heart, covering systems embody a fundamental tension in mathematics: between the infinite (every integer must be covered) and the finite (only finitely many congruence classes are used). The Chinese Remainder Theorem serves as the bridge, translating the infinite coverage requirement into a finite verification — check just the 36 residues modulo the LCM, and you've checked them all.

The search for the smallest Sierpiński number is, in a sense, a search for the boundary between compositeness and primality. Below 78,557, the primes fight back — every candidate eventually yields a prime value. At 78,557, the primes lose: a small collection of seven primes conspires to block every attempt at primality. Understanding exactly where this transition occurs remains one of the charming open problems in computational number theory.

Whether the five remaining candidates will fall to computation — or whether some deeper theoretical insight will resolve the problem — remains to be seen. But the covering system for 78,557 stands as a monument to the interplay between abstract algebra and concrete computation, a proof that sometimes the most powerful arguments are also the most elegant.
