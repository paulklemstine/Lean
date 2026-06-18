# The Hidden Geometry of Prime Numbers: How Mathematicians Are Teaching Computers to Factor

*A journey through energy landscapes, perfect numbers, and the quest to break encryption — verified by machine*

---

## The Lock That Guards the Internet

Every time you buy something online, send a private message, or log into your bank account, your security depends on a simple mathematical fact: multiplying two large prime numbers is easy, but figuring out which primes were multiplied together is extraordinarily hard.

This is the factoring problem, and it's been the bedrock of internet security for over four decades. Take the number 15 — you can quickly see it's 3 times 5. But try factoring a 600-digit number, and even the world's fastest supercomputers would take longer than the age of the universe.

Now, a research program called "Gravitational Factoring" is approaching this ancient problem from a startling new angle — and using artificial intelligence to verify every step with mathematical certainty.

## Gravity Wells in Number Space

Imagine you're walking across a landscape of hills and valleys. At each position x, the ground height is determined by a simple rule: divide your target number N by x, and the height is the remainder.

"When you divide 30 by 5, the remainder is zero," explains the research program's documentation. "That means x = 5 is at the bottom of a valley — a zero-energy point."

Here's the beautiful part: the *only* positions at the bottom of valleys are the divisors of N. If N = 30, the valleys sit at x = 1, 2, 3, 5, 6, 10, 15, and 30 — exactly the divisors. This isn't just an observation; it's been formally proven by computer, verified down to the last logical step.

The researchers have shown that these divisor-valleys aren't just any minima — they're *global* minima. Nothing in the entire landscape sits lower. It's as if each divisor creates its own gravitational well, pulling nearby trajectories toward it.

## Perfect Numbers: A 2,300-Year Mystery, Solved by Computer

The ancient Greeks were fascinated by "perfect" numbers — numbers that equal the sum of their proper divisors. The number 6 is perfect because 1 + 2 + 3 = 6. The number 28 is perfect because 1 + 2 + 4 + 7 + 14 = 28. After that comes 496, then 8128.

Euclid proved around 300 BCE that if 2^p − 1 is prime, then 2^(p−1) × (2^p − 1) is perfect. But is the converse true? Must *every* even perfect number have this form?

Euler proved it does, but his proof was long and intricate. Now, for the first time, key steps of Euler's argument have been formally verified by computer. The research team proved that in any even perfect number decomposed as 2^k × m (with m odd), the odd part m must equal exactly 2^(k+1) − 1. They also verified that this number must be prime.

The proof uses a clever counting argument: if m had any other form, the sum of its divisors would be too large, creating a contradiction. The computer checked every logical step, leaving no room for error.

*What about odd perfect numbers?* Nobody knows if they exist. The team's computers have verified that none exist below 10^6, and other researchers have pushed the bound to 10^1500. Most mathematicians believe they don't exist — but nobody can prove it.

## The Fibonacci Connection

The Fibonacci sequence — 1, 1, 2, 3, 5, 8, 13, 21, 34, ... — appears everywhere from sunflower spirals to stock market patterns. But it also has a deep, formally verified connection to factoring.

The researchers proved that for any prime p (other than 2 and 5), the square of the p-th Fibonacci number leaves remainder 1 when divided by p. This simple-sounding result (F(p)² ≡ 1 mod p) turns the Fibonacci sequence into a primality test: if a number n fails this test, it's *definitely* composite.

Even more remarkably, the Fibonacci sequence is periodic modulo any number. This "Pisano period" can reveal information about factors through the Chinese Remainder Theorem — another result the team has formally verified.

## Wieferich Primes: The Rarest Numbers

Among all the prime numbers — and there are infinitely many — only *two* are known to satisfy a peculiar property: 2^(p−1) ≡ 1 (mod p²). These "Wieferich primes" are 1093 and 3511, and nobody knows if there are any others.

The research team has formally verified, with complete mathematical certainty, that both 1093 and 3511 are indeed Wieferich primes. They've also formalized the related "Wall-Sun-Sun conjecture" — that no prime p satisfies a similar condition for Fibonacci numbers — and verified it for all primes up to 29.

These exotic primes connect to one of mathematics' most celebrated results: Fermat's Last Theorem. If a Wall-Sun-Sun prime existed, it would provide a pathway (now blocked by Andrew Wiles' 1995 proof) to solutions of x^n + y^n = z^n.

## Teaching Machines Mathematics

What makes this research unusual isn't just the mathematics — it's the methodology. Every theorem is written in Lean 4, a programming language designed for mathematical proof. A "proof assistant" checks every logical step, from basic arithmetic to sophisticated number theory.

"The computer doesn't care about elegance or intuition," the documentation notes. "It only cares about logical validity."

The project now contains over 170 formally verified theorems spanning:
- **Energy landscape theory**: Proving divisors are global minima
- **Perfect number theory**: Completing Euler's direction
- **Fibonacci factoring**: Period analysis and pseudoprime detection
- **Lattice methods**: Connecting shortest vectors to factoring
- **Divisor sum functions**: σ₁ arithmetic and hardness reductions
- **Quadratic residues**: Foundations for modern factoring algorithms

## The Road Ahead

The biggest open questions remain tantalizingly out of reach:

**Can quaternion algebras factor numbers efficiently?** Every number can be written as a sum of four squares (Lagrange's theorem, formally verified). The multiplication of these representations — through Hurwitz quaternions — preserves this structure. Could this lead to a new factoring algorithm?

**Is there a polynomial-time classical factoring algorithm?** If one exists, it would break RSA encryption and reshape cybersecurity. Most experts believe the answer is no, but nobody has proven it.

**Do odd perfect numbers exist?** After 2,300 years, this remains one of the oldest unsolved problems in mathematics.

The Gravitational Factoring program may not answer these questions immediately. But by building a rigorous, machine-verified foundation, it ensures that when breakthroughs come, they'll be built on bedrock — not sand.

---

*The Gravitational Factoring Research Program is an open-source project using Lean 4 and Mathlib for formal mathematical verification. Version 8 contains 170+ verified theorems, 9 Python demonstrations, and 3 SVG visualizations.*
