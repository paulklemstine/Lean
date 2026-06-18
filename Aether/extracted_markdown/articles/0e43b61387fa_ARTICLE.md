# The Number That Defeats All Primes

*How a retired math teacher's 1960 discovery launched a sixty-year quest involving thousands of computers — and why five stubborn numbers refuse to cooperate.*

---

In 1960, the Polish mathematician Wacław Sierpiński made a startling announcement. He had found a number with an almost magical property: no matter what you do to it, it refuses to produce a prime.

Take the number 78,557. Multiply it by 2, add 1. You get 157,115 = 5 × 31,423. Composite. Multiply 78,557 by 4 instead, add 1: 314,229 = 3 × 104,743. Composite again. Try 78,557 × 8 + 1 = 628,457 = 17 × 36,968 + 1... still composite. Multiply by 16, 32, 64, 128 — keep going as long as you like — 78,557 times any power of two, plus one, will *always* be composite.

This isn't a conjecture. It's a mathematical certainty, as unbreakable as the laws of arithmetic. And the reason why involves one of the most elegant ideas in all of number theory.

## A Blanket Made of Arithmetic

Imagine the number line stretching out to infinity. Now imagine throwing a blanket over it — but not an ordinary blanket. This one is made of arithmetic patterns, each a simple rule like "every other number" or "every third number starting from 2."

Mathematicians call such a collection a **covering system**: a finite set of these arithmetic patterns that, together, cover every single integer. No gaps. No matter which number you point to, at least one pattern claims it.

Here's a simple example. Take three patterns:
- Every even number (0, 2, 4, 6, ...)
- Every third number starting from 1 (1, 4, 7, 10, ...)
- Every sixth number starting from 5 (5, 11, 17, 23, ...)

Wait — does this cover everything? Even numbers: covered. Among odd numbers, those leaving remainder 1 when divided by 3: covered. The rest — numbers like 5, 11, 17 — are caught by the third pattern. Check any number you like: at least one pattern catches it.

Now here's Sierpiński's brilliant insight: you can weaponize a covering system against primality.

## Primes Under Siege

The numbers that Sierpiński studied have the form *k* × 2ⁿ + 1, sometimes called **Proth numbers** after the French mathematician who studied them. For a fixed *k*, as *n* ranges over 1, 2, 3, ..., you get an infinite family of candidates for primality.

For most values of *k*, some member of this family turns out to be prime. Take *k* = 3: we get 3 × 2 + 1 = 7 (prime!). Take *k* = 5: we get 5 × 2 + 1 = 11 (prime!). Even for large values of *k*, a prime usually turns up sooner or later.

But Sierpiński showed that certain values of *k* are *immune*. For these special numbers, every single member of the family is composite — not because of some lucky coincidence, but because of a deep structural conspiracy.

The conspiracy works like this. You build a covering system — say seven arithmetic patterns that cover all positive integers. Then for each pattern, you find a small prime number that is guaranteed to divide *k* × 2ⁿ + 1 whenever *n* belongs to that pattern.

Why does this work? Because of a beautiful fact about modular arithmetic: if you know the remainder of *n* when divided by some number *m*, and if a prime *p* has the property that 2^*m* ≡ 1 (mod *p*), then you can predict 2ⁿ (mod *p*) exactly. It's as if the prime has a window into the exponent *n* — not a window that shows the whole exponent, but one that reveals its remainder modulo *m*, which is all the prime needs to decide divisibility.

So for each pattern in the covering system, there's a prime standing guard, ready to divide *k* × 2ⁿ + 1 whenever *n* falls into its pattern. And because the patterns cover *everything*, there's always a guard on duty. No value of *n* can slip through.

## The Race to the Bottom

Sierpiński's original paper showed that such numbers exist — infinitely many of them, in fact. But he didn't say which number was the smallest. That question turned out to be far harder than anyone expected.

In 1962, John Selfridge identified 78,557 as a Sierpiński number, using exactly the covering system strategy described above, with seven congruence classes and the primes 3, 5, 7, 13, 17, 97, and 257. He also conjectured that 78,557 was the *smallest* Sierpiński number.

Proving this conjecture requires showing that every odd number below 78,557 is *not* Sierpiński — that is, for each such *k*, you must find at least one *n* making *k* × 2ⁿ + 1 prime. For most values of *k*, this is easy: a prime shows up quickly. But some values of *k* are stubborn. They resist for thousands, millions, even billions of values of *n* before finally yielding a prime.

In 2002, a group of mathematicians and volunteers launched **"Seventeen or Bust,"** a distributed computing project to systematically eliminate the remaining candidates. At the time, seventeen candidates remained. By 2016, the project had eliminated twelve of them, often finding primes with millions of digits — numbers so large they would fill thousands of pages if written out.

Then disaster struck. In 2017, the project's main server suffered a catastrophic hardware failure, losing years of computational progress. Though the project was eventually revived under the banner of **PrimeGrid**, five candidates remain unresolved as of 2025:

- **21,181**
- **22,699**  
- **24,737**
- **55,459**
- **67,607**

For each of these numbers, no one has found a prime of the form *k* × 2ⁿ + 1 despite searching through exponents well into the millions.

## The Density Puzzle

One of the subtler aspects of covering systems is the **density constraint**. Each pattern "covers" a certain fraction of the integers: "every other number" covers 1/2, "every third number" covers 1/3, and so on. A basic counting argument shows that these fractions must add up to at least 1:

$$\frac{1}{m_1} + \frac{1}{m_2} + \cdots + \frac{1}{m_s} \geq 1$$

This isn't just a curiosity — it's a genuine obstruction. You can't build a covering system from patterns that are all too sparse. If you only use patterns like "every thousandth number," you'd need at least a thousand of them.

For Selfridge's covering system of 78,557, the density sum is approximately 1.014 — barely above the minimum. This near-tightness means the covering is remarkably efficient, with only slight overlap between the patterns.

## Why It Matters

The Sierpiński problem sits at a crossroads of number theory, combinatorics, and computation. It connects:

- **The distribution of primes**: How are primes scattered among the Proth numbers *k* × 2ⁿ + 1?
- **Covering systems**: What finite collections of arithmetic progressions can blanket all integers?
- **The Chinese Remainder Theorem**: How does knowing remainders modulo several numbers constrain an integer's identity?

The covering system approach reveals something profound about the structure of the integers. A small number of arithmetic facts — seven divisibility conditions — can permanently block an infinite family from ever producing a prime. It's as if the number 78,557 has found a way to barricade every exit.

And yet the conjecture that 78,557 is the *smallest* such number remains unproven. Each of the five remaining candidates might be Sierpiński too — in which case Selfridge's conjecture would be false — or each might eventually yield a prime, requiring only more computing power or a clever new search strategy.

## The Infinite Guard

There is something deeply satisfying about the covering system proof. It transforms an infinitary statement — "composite for *all* n" — into a finite verification. Seven primes, seven patterns, one airtight argument. The infinite is tamed by the finite.

Paul Erdős, who did more than anyone to develop the theory of covering systems, once said that mathematics is not yet ready for such problems. Perhaps the Sierpiński problem is approaching readiness. Five numbers stand between us and the answer.

Somewhere in the vast expanse of the integers, those five numbers are either hiding a prime or perpetually evading one. Either way, the answer will tell us something fundamental about how arithmetic progressions, primes, and powers of two dance together in the infinite ballroom of the integers.

---

*The five remaining candidates — 21181, 22699, 24737, 55459, and 67607 — are being tested by volunteers worldwide through the PrimeGrid project. Anyone with a computer can contribute.*
