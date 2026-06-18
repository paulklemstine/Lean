# The Secret Algebra of Vampire Numbers

## How a Centuries-Old Number Theory Trick Reveals Hidden Structure in Digit-Preserving Factorizations

In 1994, computer scientist Clifford Pickover introduced an arresting concept to recreational mathematics: *vampire numbers*. Take 1260. Multiply 21 by 60, and you get 1260—but something uncanny happens with the digits. The number 1260 contains exactly the digits 1, 2, 6, 0, and its two "fangs" 21 and 60 together contain the same digits: 2, 1, 6, 0. The digits of the product are a perfect rearrangement of the digits of its factors.

Other examples abound: 6880 = 80 × 86. 125460 = 204 × 615. Each time, the digits of the product are a precise anagram of the combined digits of its two factors. These mathematical curiosities have entertained puzzle enthusiasts for three decades, spawning computer searches, online catalogs, and spirited forum debates about the "largest known vampire number."

But beneath the recreational surface lies a deep algebraic structure that connects vampire numbers to some of the most fundamental objects in number theory—and it was hiding in plain sight.

---

## Casting Out Nines: An Ancient Key

Every schoolchild who has learned arithmetic shortcuts knows a version of "casting out nines." Add the digits of any number, and the result is congruent to the original number modulo 9. The number 1260 has digit sum 1 + 2 + 6 + 0 = 9, and indeed 1260 ≡ 0 (mod 9). This works because 10 ≡ 1 (mod 9), so each power of 10 contributes just its coefficient when you reduce modulo 9.

Now suppose you have a vampire factorization: 1260 = 21 × 60. The digit multisets match, which means the digit sums must match too. So the digit sum of 1260 (which is 9) equals the digit sum of 21 (which is 3) plus the digit sum of 60 (which is 6). Check: 3 + 6 = 9. ✓

But this creates a powerful constraint. Since digit sums are preserved modulo 9, we have:

**x · y ≡ x + y (mod 9)**

for any vampire factorization v = x · y. Rearranging: x · y − x − y ≡ 0, which factors as (x − 1)(y − 1) ≡ 1 (mod 9).

This is a stunning restriction. It says that x − 1 and y − 1 must be *multiplicative inverses* modulo 9. In the group of units (ℤ/9ℤ)×, there are exactly φ(9) = 6 units: {1, 2, 4, 5, 7, 8}. So there are only 6 valid residue class pairs for vampire fangs. Out of the 81 possible pairs of residues modulo 9, only 6 can ever produce a vampire number.

---

## The Generalization: Digit-Morphic Factorizations

The key insight is that nothing about this argument depends on base 10. In any base b ≥ 2, the digit sum of a number n is congruent to n modulo b − 1. This is the generalized "casting out (b−1)s" rule: it works because b ≡ 1 (mod b − 1), so each digit position contributes only its face value.

This motivates a general definition. A **digit-morphic factorization** of v in base b is a factorization v = x · y where the multiset of base-b digits of v equals the combined multisets of digits of x and y. Vampire numbers are the special case b = 10 with balanced fang lengths.

The **Generalized Fang Residue Constraint** states: for *any* digit-morphic factorization v = x · y in base b,

**(x − 1)(y − 1) ≡ 1 (mod b − 1)**

The valid residue class pairs are precisely the elements of (ℤ/(b−1)ℤ)×—the multiplicative group of units modulo b − 1. Their count is Euler's totient function φ(b − 1).

---

## The Morphic Algebra

This realization opens a new perspective. Define the **morphic algebra** of modulus m as the set of pairs (a, c) in (ℤ/mℤ)² satisfying (a − 1)(c − 1) = 1. This set has remarkable structure:

**Cardinality**: Exactly φ(m) pairs. Each unit u in (ℤ/mℤ)× generates the pair (u + 1, u⁻¹ + 1). This map is a bijection.

**Involution**: The set carries a natural symmetry: if (a, c) is morphic, so is (c, a). This corresponds to swapping the two factors in a digit-morphic factorization.

**Fixed points**: A pair (a, a) is a fixed point of this involution precisely when (a − 1)² = 1, meaning a − 1 is a square root of unity in ℤ/mℤ. The number of such fixed points connects to the factorization structure of m—for m = p (prime), there are exactly 2 fixed points (corresponding to a − 1 = ±1), while for composite m, the count grows with the number of prime factors.

---

## The Morphic Density of a Base

Which base is "richest" in digit-morphic factorizations? The Fang Residue Constraint gives us a quantitative answer. The fraction of residue class pairs that satisfy the constraint is φ(b − 1)/(b − 1)², the **morphic density** of base b.

When b − 1 is prime (b = 3, 4, 6, 8, 12, 14, ...), the morphic density is (b − 2)/(b − 1)², approaching 1/(b − 1) for large b. When b − 1 is highly composite (b = 13, 25, 37, ..., where b − 1 = 12, 24, 36, ...), the density drops because φ(b − 1) is small relative to b − 1.

This creates an unexpected connection: the "vampire-friendliness" of a number base is governed by the arithmetic properties of b − 1. Base 10 (where b − 1 = 9 = 3²) has morphic density 6/81 ≈ 7.4%. Base 7 (where b − 1 = 6 = 2 × 3) has morphic density 2/36 ≈ 5.6%. The prime base b = 4 (where b − 1 = 3) has the highest possible density for its size: 2/9 ≈ 22.2%.

---

## The Digit Defect

Not every factorization is digit-morphic, but every factorization *almost* is, in a quantifiable sense. The **digit defect** measures the symmetric difference between the digit multiset of a product and the combined digit multisets of its factors. A defect of zero means a perfect digit-morphic factorization; larger defects mean the digits are more "scrambled" by multiplication.

A fundamental characterization theorem confirms intuition: a factorization has digit defect zero if and only if it is genuinely digit-morphic. The defect is symmetric in the factors (swapping x and y doesn't change the defect), and it provides a natural metric on the space of factorizations.

---

## A Surprising Negative Result

One might imagine that "almost-vampire" numbers could exist—numbers where the digits of v and the combined digits of x, y are close but not identical. Perhaps sorting the digits could reveal near-misses? This turns out to be a mathematical mirage. If the *sorted* digits of v match the *sorted* combined digits of x and y, then the digit multisets are identical. Sorting a multiset and comparing is the same as comparing multisets directly. There is no interesting notion of "spectral number" (near-miss by sorted digits) that differs from genuine vampires.

This negative result, proved rigorously, eliminates an entire class of potential research directions. Sometimes the most important mathematical discovery is learning that something cannot exist.

---

## What Vampire Numbers Teach Us About Number Systems

The digit-morphic framework reveals that vampire numbers are not isolated curiosities but manifestations of a deep interaction between multiplicative and additive structure in positional number systems. The "casting out nines" trick, known for centuries, is the tip of an iceberg: it implies that digit-preserving factorizations are constrained by the group theory of (ℤ/(b−1)ℤ)×, connecting recreational number theory to Euler's totient function, unit groups of modular rings, and the density of residue classes.

The next frontier is understanding how these algebraic constraints interact with the analytic distribution of digit-morphic numbers. How many n-digit numbers in base b admit digit-morphic factorizations? The residue constraint gives an upper bound proportional to φ(b − 1), but the true count depends on a delicate interplay between the constraint and the distribution of products of numbers with prescribed digit lengths. This is where number theory meets combinatorics meets analysis—and where the next surprises likely await.

---

*The author is grateful to the mathematicians who first noticed that 1260 = 21 × 60 has special digits—a simple observation that, three decades later, continues to reveal unexpected mathematical depth.*
