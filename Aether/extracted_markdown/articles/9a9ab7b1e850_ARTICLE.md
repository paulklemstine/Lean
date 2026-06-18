# The Number That Kills Itself: How 163 Builds a Tower of Primes — Then Tears It Down

In 1772, Leonhard Euler noticed something peculiar. Take the formula *n² + n + 41*, and start plugging in numbers. When *n* = 0, you get 41 — a prime. When *n* = 1, you get 43 — also prime. When *n* = 2, you get 47 — prime again.

Keep going. The formula produces 53, 61, 71, 83, 97, 113, 131, 151, 173, 197, 223, 251, 281, 313, 347, 383, 421, 461, 503, 547, 593, 641, 691, 743, 797, 853, 911, 971, 1033, 1097, 1163, 1231, 1301, 1373, 1447, 1523, 1601.

That is *forty consecutive primes*, unbroken, from a single quadratic formula. No other polynomial of this form comes close.

But at *n* = 40, something remarkable happens. The formula gives 1681. And 1681 = 41². The formula produces the *square of its own constant term*. The tower of primes, built painstakingly over 40 steps, collapses when the polynomial generates a number divisible by the very prime it started with.

This is not a coincidence. It is an algebraic identity.

## The Self-Termination Identity

Here is a fact so simple it's easy to overlook: for *any* value of *q*, the expression (*q* − 1)² + (*q* − 1) + *q* equals *q*². Always. You can verify this by expanding the algebra: *q*² − 2*q* + 1 + *q* − 1 + *q* = *q*².

This means that for *every* quadratic of the form *n*² + *n* + *q*, the value at *n* = *q* − 1 is *q*² — guaranteed composite (for *q* ≥ 2), guaranteed to be divisible by *q* itself. The polynomial starts by producing *q* (at *n* = 0) and ends by producing *q*² (at *n* = *q* − 1). It generates its own executioner.

The maximum possible prime run for *n*² + *n* + *q* is therefore *q* − 1 steps. After that, the identity kicks in and the tower must fall. The question becomes: for which values of *q* does the tower actually reach this theoretical maximum?

## Six Lucky Numbers, and Only Six

Mathematicians call these values "Euler lucky numbers." They are the values of *q* for which *n*² + *n* + *q* is prime for every integer *n* from 0 to *q* − 2 — hitting the maximum before the self-termination identity destroys the run.

There are exactly six of them: 2, 3, 5, 11, 17, and 41.

Each builds a tower of consecutive primes whose height equals *q* − 1:

| Lucky *q* | Tower height | Primes generated | Termination |
|-----------|-------------|-------------------|-------------|
| 2 | 1 | 2 | 2² = 4 |
| 3 | 2 | 3, 5 | 3² = 9 |
| 5 | 4 | 5, 7, 11, 17 | 5² = 25 |
| 11 | 10 | 11, 13, 17, 23, 31, 41, 53, 67, 83, 101 | 11² = 121 |
| 17 | 16 | 17, 19, 23, 29, 37, 47, 59, 73, 89, 107, 127, 149, 173, 199, 227, 257 | 17² = 289 |
| 41 | 40 | 41, 43, 47, 53, ..., 1601 | 41² = 1681 |

The tower gets taller as *q* grows. And 41 builds the tallest tower by far — 40 consecutive primes, every single one checking out, before the inevitable collapse at 41².

Why these six and no others? The answer lies in one of the most beautiful connections in all of mathematics.

## The Heegner Connection

Compute 4*q* − 1 for each lucky number:

- 4 × 2 − 1 = **7**
- 4 × 3 − 1 = **11**
- 4 × 5 − 1 = **19**
- 4 × 11 − 1 = **43**
- 4 × 17 − 1 = **67**
- 4 × 41 − 1 = **163**

These are precisely the **Heegner numbers** — the positive integers *d* for which the imaginary quadratic field ℚ(√(−*d*)) has "class number one." In plain English, these are the numbers for which a certain type of number system based on √(−*d*) has the simplest possible arithmetic, where every number factors uniquely into primes.

The Stark-Heegner theorem, proved in the 1960s, established that there are exactly nine Heegner numbers: 1, 2, 3, 7, 11, 19, 43, 67, and 163. The first three (1, 2, 3) don't produce lucky numbers because the corresponding *q* values aren't integers or are too small. The remaining six give us exactly the six lucky numbers.

And 163 — the *largest* Heegner number — gives us 41, the champion prime generator.

## Completing the Square: Why Class Number Matters

There is a beautiful algebraic reason the class number 1 condition forces all tower values to be prime. Consider the identity:

4 × (*n*² + *n* + *q*) = (2*n* + 1)² + (4*q* − 1)

This "completing the square" identity shows that every value of the Euler polynomial, multiplied by 4, decomposes as a perfect square plus the discriminant *d* = 4*q* − 1.

When *d* is a Heegner number, the arithmetic of ℚ(√(−*d*)) is controlled by a single class — unique factorization holds. This severely constrains which primes can divide values of *n*² + *n* + *q*, because any such prime *p* would need the discriminant −*d* to be a quadratic residue modulo *p*. The class number 1 condition means that the only way *n*² + *n* + *q* can be composite is through the self-termination mechanism at *n* = *q* − 1.

For non-Heegner discriminants, the class number is at least 2, and "extra" ways to factor emerge. The tower crumbles early because new prime divisors become available that aren't blocked by the class number 1 condition.

## Ramanujan's Constant: The Shadow of Class Number 1

The number 163 appears in another famous context. The expression *e*^{π√163} is astonishingly close to an integer:

*e*^{π√163} = 262,537,412,640,768,743.99999999999925...

The error is less than 10⁻¹². This near-integer property is not numerological coincidence — it is a direct consequence of 163 being a Heegner number.

The connection goes through the *j*-function, a central object in the theory of elliptic curves and modular forms. For any Heegner number *d*, the value *j*((1 + √(−*d*))/2) is an algebraic integer — and *e*^{π√*d*} is essentially this *j*-value with small correction terms that decay exponentially.

For *d* = 163: *j*((1 + √(−163))/2) = −640,320³, and *e*^{π√163} ≈ 640,320³ + 744.

Each Heegner number produces a near-integer, with the approximation getting exponentially better as *d* grows:

| *d* | *e*^{π√*d*} error |
|-----|-------------------|
| 7 | ~10⁻¹ |
| 19 | ~10⁻² |
| 43 | ~10⁻⁴ |
| 67 | ~10⁻⁸ |
| 163 | ~10⁻¹² |

The progression is dramatic: each step up the Heegner ladder tightens the near-integer approximation by orders of magnitude. And 163, as the final step, produces the most spectacular near-miss in number theory.

## The Circular Architecture

What makes this story remarkable is its circular architecture. The number 163 is special because:

1. It is the largest Heegner number (the last class number 1 field).
2. Therefore *q* = 41 = (163 + 1)/4 produces the longest prime run.
3. The prime run terminates by producing 41² = 1681 — the square of its own seed.
4. The j-function at (1 + √(−163))/2 produces −640,320³, making *e*^{π√163} almost an integer.
5. All of these properties are shadows of a single deep fact: the unique factorization in ℚ(√(−163)).

The self-termination identity — the fact that every Euler polynomial eventually generates the square of its own constant term — provides the *upper bound* on how good a prime generator can be. The class number 1 condition determines *which* polynomials actually reach this bound.

163 is not magic. It is the climax of a mathematical structure that stretches from Euler's 18th-century observation through Gauss's theory of quadratic forms to Stark's 20th-century resolution of the class number problem. It is the last note of a symphony that began with the simplest question in number theory: which numbers are prime?

## Looking Forward

The Heegner towers reveal a principle that extends beyond number theory: self-terminating structures appear throughout mathematics — recursive processes that contain the seeds of their own completion. In dynamical systems, they manifest as fixed points; in logic, as self-referential propositions; in physics, as systems that dissipate their own driving force.

The tower built by *n*² + *n* + 41 is the perfect mathematical miniature of this phenomenon. For 40 steps, it generates nothing but primes. At step 41, it produces 41² — a composite number built from the very prime that started it all. The tower doesn't just fall; it falls *because of what it is*.

That, ultimately, is why 163 matters. Not because it is a large prime, or a lucky number, or a curiosity of transcendental approximation. It matters because it sits at the exact point where the deepest structure in algebraic number theory — class number 1 — meets the most elementary question in arithmetic — which quadratic polynomials generate primes.

The fact that this point exists at all, that there is a *last* Heegner number, that the list is finite and ends precisely at 163 — this is one of the great revelations of 20th-century mathematics. And like all great revelations, it makes the world seem both more mysterious and more inevitable.
