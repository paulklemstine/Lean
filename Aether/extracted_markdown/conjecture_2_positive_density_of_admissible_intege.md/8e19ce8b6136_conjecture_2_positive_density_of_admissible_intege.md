# The Hidden Arithmetic of Missing Numbers

## Why Two Forbidden Remainders Shape One of Mathematics' Most Stubborn Puzzles

In 2019, mathematicians Andrew Booker and Andrew Sutherland made international headlines. After years of computation using hundreds of thousands of hours of processing time, they found three enormous numbers — each more than 16 digits long — whose cubes add up to 42. The equation looks innocuous enough:

$$(-80538738812075974)^3 + 80435758145817515^3 + 12602123297335631^3 = 42$$

You can verify it with a calculator, but finding those three numbers required an intellectual odyssey stretching back to 1954, when mathematicians first began asking a deceptively simple question: given an integer *k*, can you always write it as the sum of three perfect cubes?

The answer, it turns out, is no — and the reason is surprisingly beautiful.

---

## The Clock That Rules the Cubes

Imagine a clock with nine hours instead of twelve. Every time you cube a number — multiply it by itself twice — and look at where it lands on this nine-hour clock, something remarkable happens: no matter what number you start with, the cube always lands on one of exactly three positions: 0, 1, or 8.

This isn't a coincidence. It's a mathematical law. Take any integer you like — positive, negative, astronomically large — cube it, divide by 9, and check the remainder. You will always get 0, 1, or 8. Always.

To see why, notice that every integer, when divided by 9, leaves one of nine possible remainders: 0 through 8. Cube each of these nine values and check the remainder modulo 9:

| Remainder when divided by 9 | Cube | Cube's remainder mod 9 |
|:---:|:---:|:---:|
| 0 | 0 | **0** |
| 1 | 1 | **1** |
| 2 | 8 | **8** |
| 3 | 27 | **0** |
| 4 | 64 | **1** |
| 5 | 125 | **8** |
| 6 | 216 | **0** |
| 7 | 343 | **1** |
| 8 | 512 | **8** |

The pattern repeats with perfect regularity: 0, 1, 8, 0, 1, 8, 0, 1, 8. This is not a numerical accident — it's a structural feature of how cubing interacts with the number 9.

---

## The Forbidden Sums

Now comes the key insight. If you're adding three cubes together, each contributes a remainder of 0, 1, or 8 on our nine-hour clock. What remainders can the sum achieve?

You can work through all 27 combinations systematically: 0+0+0, 0+0+1, 0+0+8, all the way to 8+8+8. When you do, you find that the sum can produce remainders 0, 1, 2, 3, 6, 7, and 8. But two remainders are completely impossible: **4 and 5**.

No matter how cleverly you choose your three cubes — even if each number has a billion digits — their sum will never leave a remainder of 4 or 5 when divided by 9.

This means that the number 4 can never be written as a sum of three cubes. Neither can 5, 13, 14, 22, 23, or any other number that leaves a remainder of 4 or 5 when divided by 9. These numbers are permanently excluded. The door is locked, and no amount of computational power will ever open it.

---

## Seven Out of Nine

This obstruction carves a clean division through the integers. Of every nine consecutive numbers, exactly two are forbidden and seven are *admissible* — they pass the clock test and are at least eligible to be sums of three cubes.

The fraction 7/9 is exact, not approximate. If you count admissible numbers up to any cutoff *N*, you'll find approximately 77.8% of them pass the test. More precisely, the count differs from 7*N*/9 by at most a constant — the error never exceeds 8/9 no matter how large *N* grows. This is not a statistical observation; it is a proven theorem with a machine-verified proof.

The admissible numbers begin: 0, 1, 2, 3, 6, 7, 8, 9, 10, 11, 12, 15, 16, 17, 18, ...

You can see the pattern: two gaps (at positions 4–5, 13–14, 22–23, ...) appear with clockwork regularity, each separated by exactly 9 integers.

---

## The Mystery That Remains

Here is where the story deepens. Being admissible is necessary to be a sum of three cubes, but is it sufficient? Does every admissible number actually have a representation?

For small numbers with small solutions, it's easy to check:
- 0 = 0³ + 0³ + 0³
- 1 = 1³ + 0³ + 0³
- 2 = 1³ + 1³ + 0³
- 29 = 3³ + 1³ + 1³

But some admissible numbers are fantastically stubborn. The number 33 waited until 2019 for its first known representation, which uses integers with 16 digits. The number 42 fell the same year. As of recent years, 114 has been cracked. A handful of numbers below 1000 remain unresolved.

The prevailing conjecture — unproven and perhaps unprovable with current methods — is that *every* admissible number can be written as a sum of three cubes. The exceptions, if any, would be infinitely rare: a set of density zero, vanishingly sparse among the integers.

---

## A Filter for the Infinite

The modular obstruction is more than a curiosity. It serves as a computational sieve — a constant-time filter that eliminates 22.2% of all candidate numbers before any expensive search begins.

In practice, finding three cubes that sum to a given target requires searching through an enormous space of possibilities. The search grows cubically with the size of the numbers tried: checking all triples with absolute value up to *B* requires roughly *B*² operations (since the third number is determined by the first two). For numbers like 33, the search bound *B* exceeded 10¹⁶ — that's more than ten quadrillion possibilities examined per pair.

The mod-9 filter doesn't make this search faster in a deep algorithmic sense, but it does something important: it guarantees that you never waste time on impossible targets. It's a proof of impossibility that runs in nanoseconds.

---

## The Local-Global Gap

Mathematicians call this the **local-global** phenomenon. The mod-9 test is a *local* condition — it checks consistency with just one modular constraint. The actual question of whether a representation exists is the *global* condition — it requires finding specific integers anywhere in the infinite number line.

This gap between local conditions and global truth is one of the deepest themes in modern number theory. The Hasse-Minkowski theorem tells us that for quadratic equations, local conditions are sufficient: if an equation has solutions modulo every prime (and over the real numbers), then it has integer solutions. But for cubic equations and higher, this beautiful correspondence breaks down. Local admissibility does not guarantee global representability.

The sum-of-three-cubes problem lives precisely in this gap. The mod-9 obstruction is the only congruence obstruction — no other modulus produces additional forbidden residues that aren't already captured by mod 9. (You can check: cubes modulo 7 produce all residues, cubes modulo 4 produce 0 and 1, but every sum of three elements from {0,1} modulo 4 is achievable.) So the mod-9 filter is the *complete* local obstruction. Everything beyond it is genuinely global.

---

## Counting with Precision

The exact density result — that 7/9 of integers are admissible — can be proved with remarkable precision. Writing any positive integer *N* in the form 9*q* + *r* (where *r* is between 0 and 8), the count of admissible integers below *N* decomposes exactly:

**admissibleCount(*N*) = 7*q* + tail(*r*)**

where tail(*r*) counts how many of the residues 0, 1, ..., *r*−1 are admissible. Each complete block of 9 integers contributes exactly 7 admissible ones. The tail contributes a small correction. The entire formula is deterministic and exact — no estimation, no error terms, no asymptotics.

From this formula, a clean error bound follows:

**|9 × admissibleCount(*N*) − 7*N*| ≤ 8**

This bound holds for every *N*, from 1 to infinity. Divide both sides by 9*N* and you see the density converges to 7/9 at a rate proportional to 1/*N* — fast enough that for *N* = 1000, the density is already 0.778, indistinguishable from 7/9 to three decimal places.

---

## The Exceptional Set: Mathematics' Dark Matter

The most tantalizing object in this story is the *exceptional set* — the collection of admissible numbers for which no representation as a sum of three cubes is known (or might not exist). Call it *E*(*N*) for the number of such exceptions up to *N*.

If every admissible number truly has a representation, then *E*(*N*) is eventually zero for every *N*. But even if some admissible numbers genuinely lack representations, the conjecture is that they are so rare that *E*(*N*)/*N* → 0 as *N* grows.

Computationally, what we see is that increasing the search bound *B* steadily fills in more representations. With *B* = 10, most small admissible numbers can be represented. With *B* = 100, almost all numbers up to 100 are covered. The stubborn ones — numbers like 33, 42, 114 — require astronomically large cubes, but they eventually yield.

This pattern — local conditions easily verified, global conditions requiring vast computation — mirrors phenomena across mathematics and physics. It's reminiscent of how easy it is to check that a molecule satisfies conservation laws, versus how hard it is to determine whether that molecule can actually form. The conservation law is the local obstruction; the chemistry is the global reality.

---

## A Framework, Not Just a Fact

The deepest contribution of this line of research isn't the specific fraction 7/9. It's the *framework*: a rigorous, reusable architecture for studying modular obstructions and their density consequences in any additive Diophantine problem.

The same machinery applies to sums of four cubes (where there are no mod-9 forbidden residues, so the local density is 1), sums of fourth powers (where mod-16 constraints create new forbidden patterns), or any representation question of the form "can *k* be written as a sum of *s* values of a polynomial?"

In each case:
1. Compute the power residues modulo an appropriate modulus.
2. Determine which sums of *s* residues are achievable.
3. The forbidden residues define the local obstruction.
4. The fraction of achievable residues gives the exact local density.
5. The gap between local density and actual representability defines the exceptional set.

This five-step pipeline transforms each Diophantine representation question from an amorphous challenge into a structured investigation with precise, quantitative predictions.

---

## The View from the Bridge

Standing at the intersection of number theory, computation, and logic, the sum-of-three-cubes problem offers a rare vantage point. It connects elementary modular arithmetic — accessible to anyone who can divide by 9 — to questions that push the boundaries of both mathematics and computing.

The 7/9 density theorem is certain, proven, and absolute. The conjecture that every admissible number has a representation remains open, tantalizing, and perhaps forever out of reach by current methods. Between these two truths lies one of the richest territories in contemporary mathematics: a landscape where rigorous proof, massive computation, and informed conjecture work together to illuminate the hidden structure of the integers.

Two missing remainders on a nine-hour clock. That's all it takes to shape the boundaries of one of mathematics' most beautiful unsolved problems.
