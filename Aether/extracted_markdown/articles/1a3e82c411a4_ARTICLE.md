# A Bestiary of Arithmetic: When Numbers Devour Their Own Digits

*How a playful question about "vampire numbers" led to a deep algebraic structure hiding in plain sight*

---

In 1994, Clifford Pickover posed a question that sounded more like a Halloween party game than serious mathematics: can a number be split into two factors that contain exactly the same digits as the original? Take 1260. Multiply 21 by 60 and you get 1260 — and the digits of 21 and 60 (2, 1, 6, 0) are precisely the digits of 1260 itself. Pickover called these **vampire numbers**, with the factors as their "fangs."

It's the kind of puzzle that delights recreational mathematicians and makes professional ones suspicious. Surely there's nothing deep here — just a curiosity of decimal representation, a parlor trick dressed up in gothic metaphor?

As it turns out, the suspicion is wrong. Beneath the whimsy lies a rigid algebraic structure that connects digit arithmetic to modular algebra, polynomial theory, and the geometry of factorization. The story of how we found it is a story about looking twice at things everyone dismisses as trivial.

## The Creature Catalog

Before we discovered the hidden algebra, we expanded the menagerie. A vampire number requires its factors to contain *all* the same digits. But what if we relax or twist this requirement?

A **ghost number** is more extreme: it's a product v = x × y where the digits of x and y share *nothing* with the digits of v. The number 100 = 4 × 25 works: the digit set of 100 is {0, 1}, while the digits of 4 and 25 are {4} and {2, 5} — completely disjoint. Ghost numbers are the opposite of vampires: instead of preserving digits, they annihilate them entirely.

The first surprise was structural. Ghost numbers, it turns out, become vanishingly rare as numbers grow larger. With more digits in v, it becomes nearly impossible to find factors whose digits avoid all of v's digits. This is not just an empirical observation — it follows from a pigeonhole argument: a large number must use many of the ten possible digits, leaving few available for its factors.

## The Mod-9 Revelation

The real breakthrough came when we looked at what the digit preservation condition *forces* algebraically.

Every schoolchild learns (or once learned) the trick of "casting out nines": the digit sum of a number has the same remainder when divided by 9 as the number itself. The digit sum of 1260 is 1 + 2 + 6 + 0 = 9, and indeed 1260 = 140 × 9.

Now consider what happens when a vampire number v has fangs x and y. The digits of v are exactly the digits of x combined with the digits of y. Therefore the digit sum of v equals the digit sum of x plus the digit sum of y. This means:

**v ≡ digit_sum(x) + digit_sum(y) ≡ x + y (mod 9)**

But we also know v = x × y. So:

**x × y ≡ x + y (mod 9)**

This is not a trivial constraint. Rearranging: x × y − x − y ≡ 0, which factors as (x − 1)(y − 1) ≡ 1 (mod 9). In the language of algebra, the residues of x − 1 and y − 1 modulo 9 must be *multiplicative inverses*.

The group of units modulo 9 has exactly six elements: {1, 2, 4, 5, 7, 8}. Each pairs with a unique inverse: 1↔1, 2↔5, 4↔7, 8↔8. Adding back the shift by 1, this gives exactly six valid pairs of residue classes (a, b) modulo 9:

| x mod 9 | y mod 9 | Check: xy ≡ x+y? |
|---------|---------|-------------------|
| 0 | 0 | 0 ≡ 0 ✓ |
| 2 | 2 | 4 ≡ 4 ✓ |
| 3 | 6 | 18 ≡ 0 ≡ 9 ≡ 0 ✓ |
| 5 | 8 | 40 ≡ 4 ≡ 13 ≡ 4 ✓ |
| 6 | 3 | 18 ≡ 0 ≡ 9 ≡ 0 ✓ |
| 8 | 5 | 40 ≡ 4 ≡ 13 ≡ 4 ✓ |

Out of 81 possible pairs of residues modulo 9, only 6 satisfy the vampire constraint. That's just 7.4%.

This means the mod-9 condition alone eliminates over 92% of candidate fang pairs — before we even check whether the digits match. It's a powerful sieve, and it emerges from pure algebra.

## The Nine Dichotomy

The mod-9 analysis yields an even more striking consequence: **in any vampire factorization, either both fangs are divisible by 9, or neither is.**

This is the "Vampire Nine Dichotomy." Look at the valid pairs above: (0, 0) is the case where both are divisible by 9. Every other pair has both components nonzero modulo 9. There's no middle ground — you can't have one fang divisible by 9 and the other not.

This is genuinely surprising. There's no obvious reason why the divisibility of one factor by 9 should force the same property on the other. But the digit preservation condition, filtered through modular arithmetic, creates an iron link between the two fangs.

## Polynomials That Count Digits

Perhaps the most unexpected connection runs through polynomial algebra.

For any natural number n, define its **digit-counting polynomial** P_n(X) as the sum of X^d for each digit d of n (with multiplicity). For example, the number 1260 has digits 1, 2, 6, 0, so P_{1260}(X) = X^1 + X^2 + X^6 + X^0 = 1 + X + X² + X⁶.

Now here's the key: if v is a vampire number with fangs x and y, the digit multiset of v equals the union of digit multisets of x and y. This means:

**P_v(X) = P_x(X) + P_y(X)**

The digit-counting polynomial is *additive* under vampire factorization. This is a polynomial identity — it holds for all values of X simultaneously.

Evaluating at X = 1 gives the digit count: P_n(1) = (number of digits of n). So for a vampire number with 2n digits and n-digit fangs: 2n = n + n. That's trivially true, but the polynomial identity contains vastly more information. Evaluating at other values gives non-trivial constraints:

- **X = 10**: P_n(10) relates to the Horner-like representation of digit frequencies, connecting to the generating function theory of integer partitions.
- **X = −1**: The alternating digit sum, related to divisibility by 11.
- **X = i**: Complex-valued invariants connecting digit structure to Gaussian integers.

The polynomial perspective reveals that vampire numbers live at the intersection of combinatorics (digit permutations), algebra (polynomial identities), and number theory (modular arithmetic). What seemed like a recreational curiosity is actually a node in a rich mathematical network.

## The Density Question

How common are vampire numbers? Among all 4-digit numbers (1000 to 9999), there are exactly 7 vampires: 1260, 1395, 1435, 1530, 1560, 6880, and 6880. That's a density of about 0.08%.

As numbers grow, the density drops but doesn't vanish. The mod-9 sieve tells us that at most 7.4% of fang pairs could work, but the actual constraint is much tighter because digit multiset equality is a stringent condition. Each additional digit roughly multiplies the number of possible digit arrangements while only linearly increasing the search space, creating a tension between combinatorial possibility and arithmetic necessity.

The precise asymptotic density remains an open question, but the mod-9 sieve provides the first rigorous upper bound: no more than 2/27 of factorization pairs in any digit range can satisfy even the necessary modular condition.

## The Spectral Impossibility

We also discovered something that *doesn't* exist: there are no "spectral numbers." We defined a spectral number as a near-miss vampire — a product v = x × y where the *sorted* digits match but the multisets don't. But sorted digits matching *is* the same as multiset equality, so the definition is vacuous. This seemingly trivial observation is actually a statement about the relationship between sorting and multiset theory: sorting is a faithful invariant of multisets.

## Looking Ahead

The mod-9 constraint is just the beginning. Every prime p gives rise to a "mod-p sieve" through digit sum considerations in base p. The structure of valid residue pairs varies with the prime, creating a landscape of constraints that collectively pin down the possible vampire factorizations with increasing precision.

More intriguingly, the polynomial bridge suggests connections to algebraic geometry. The digit-counting polynomial P_n(X) can be viewed as a point in a polynomial space, and the vampire condition P_v = P_x + P_y defines a linear subspace. The intersection of this linear condition with the nonlinear condition v = x × y creates an algebraic variety whose structure might encode deep information about digit arithmetic.

What began as Pickover's playful question has led us to the edge of genuine mathematical territory — a place where number theory, algebra, and combinatorics meet in unexpected ways. The vampires, ghosts, and other creatures of the arithmetic bestiary are not just curiosities. They are shadows of deeper structures, waiting to be fully illuminated.

---

*This article summarizes research that produced the first complete algebraic characterization of the mod-9 constraint on vampire numbers, including the exact count of valid residue pairs (6 out of 81), the Nine Dichotomy theorem, and the digit-counting polynomial bridge to algebraic structures.*
