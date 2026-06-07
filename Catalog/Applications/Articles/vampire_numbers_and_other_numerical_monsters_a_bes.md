# The Secret Lives of Numbers: When Multiplication Creates Anagrams

## A Bestiary of Arithmetic Oddities

Take the number 1260. It seems unremarkable—just another four-digit composite between 1000 and 9999. But look closer: 1260 = 21 × 60. Now rearrange the digits of 21 and 60: you get 2, 1, 6, 0—exactly the digits of 1260 itself. The product is an anagram of its own factors.

Welcome to the world of **vampire numbers**, a menagerie of arithmetic creatures that emerge from the surprising intersection of multiplication and digit permutation.

## Birth of a Bestiary

The concept of vampire numbers was introduced by Clifford Pickover in 1995. A vampire number is a composite number with an even number of digits—say 2n digits—that can be written as a product of two n-digit "fangs" whose combined digits are exactly the digits of the original number. The smallest vampire number, 1260 = 21 × 60, lives alongside six siblings in the four-digit range: 1395 = 15 × 93, 1435 = 35 × 41, 1530 = 30 × 51, 1827 = 21 × 87, 2187 = 27 × 81, and 6880 = 80 × 86.

But why stop at vampires? By varying the relationship between a number's digits and those of its factors, we can populate an entire bestiary of "arithmetic creatures":

- **Ghost numbers** are products v = x × y where the digits of v share *nothing* with the digits of either factor—complete digit disjointness. Example: 1827 = 3 × 609, where {1,8,2,7} shares no digit with {3} or {6,0,9}. Remarkably, 1827 is *both* a vampire number (1827 = 21 × 87) and a ghost number—a dual citizen of two creature kingdoms.

- **Werewolf numbers** are products where exactly one digit type is shared between the number and its factors—a single thread connecting the product to its origins.

These creatures are not mere curiosities. They reveal deep structure in how decimal representation interacts with the multiplicative properties of integers.

## The Casting-Out-Nines Constraint

The most elegant result in vampire number theory comes from an ancient arithmetic trick: casting out nines. Every number is congruent to its digit sum modulo 9. This seemingly simple fact has profound consequences for which numbers can be vampires.

If v = x × y is a vampire factorization—meaning the combined digits of x and y form an anagram of v—then the digit sum of v must equal the sum of the digit sums of x and y. Combined with the casting-out-nines identity, this gives us what we call the **Resonance Mod-9 Theorem**:

> *If x and y are in "multiplicative digit resonance" (meaning x × y is an anagram of x concatenated with y), then x × y ≡ x + y (mod 9).*

Rearranging: (x − 1)(y − 1) ≡ 1 (mod 9). This means (x − 1) must be a unit in the ring of integers modulo 9. There are exactly 6 units in ℤ/9ℤ—the numbers 1, 2, 4, 5, 7, and 8—corresponding to the elements coprime to 9. Each unit pairs with its multiplicative inverse, giving exactly 6 valid ordered pairs of residue classes that can appear as vampire fangs:

| a mod 9 | b mod 9 |
|---------|---------|
| 0 | 0 |
| 2 | 2 |
| 3 | 6 |
| 5 | 8 |
| 6 | 3 |
| 8 | 5 |

This means 75 out of 81 possible residue class pairs are *immediately eliminated* as vampire fang candidates. The mod-9 constraint is a powerful sieve.

You can verify this against the complete list of four-digit vampires: 1260 = 21 × 60 gives residues (3, 6) ✓; 1395 = 15 × 93 gives (6, 3) ✓; 1435 = 35 × 41 gives (8, 5) ✓; and so on. Every single one checks out.

## The Resonance Framework

To study these creatures systematically, we introduce the concept of **multiplicative digit resonance**. Two numbers x and y are "in resonance" if the digit multiset of their product x × y equals the combined digit multisets of x and y individually. This captures the essential property of vampire numbers without the constraint on digit counts.

Resonance turns out to be a remarkably structured relation:
- It is **symmetric**: if (x, y) are in resonance, so are (y, x).
- It is **mod-9 constrained**: resonant pairs must satisfy the fang pair constraint.
- It implies **compositeness**: every resonant number has a non-trivial factorization.
- The **resonance class** of a number—the set of all factor pairs producing resonance—is always finite.

Every vampire number is resonant, but not every resonant number is a vampire: the resonant factorization 126 = 6 × 21 involves factors of different digit counts, so 126 is resonant but not vampire.

## The Ghost-Resonance Exclusion

Perhaps the most surprising structural result is that resonance and ghost-hood are incompatible *for the same factorization*. If x × y produces a number whose digits are exactly the combined digits of x and y (resonance), then the product necessarily shares at least one digit with x or y. This seems obvious in retrospect—if every digit of v comes from the digits of x and y, then of course v's digit set overlaps with theirs—but the proof requires careful multiset-theoretic reasoning.

Critically, this does *not* mean a number can't be both a vampire and a ghost: it simply means it can't achieve both properties through the *same* factorization. The number 1827 demonstrates this beautifully: its vampire factorization 21 × 87 creates digit resonance, while its ghost factorization 3 × 609 achieves complete digit disjointness.

## Counting Creatures

How common are these arithmetic oddities? Among four-digit numbers, there are exactly 7 vampires, roughly 2,300 ghosts, and about 5,700 werewolves. Ghost numbers are surprisingly common in the small ranges—most two- and three-digit composites qualify—but their prevalence depends heavily on the digit range.

The density of vampire numbers follows a predictable decay governed by combinatorics. For a 2n-digit number, the expected number of valid fang pairs is bounded by the central binomial coefficient C(2n, n) divided by 10^n. By Stirling's approximation, this is roughly 1/√(πn)—decreasing, but slowly enough that vampire numbers persist indefinitely through the number line.

This counting argument reveals why vampires become rare but never vanish: the combinatorial constraints grow, but the number of candidate factorizations grows even faster, maintaining a trickle of vampires at every scale.

## A Deeper Structure

The real mathematical interest lies not in any individual creature but in the interplay between digit structure and multiplicative structure. Decimal representation is, in some sense, "accidental"—it depends on our choice of base 10. Yet the constraints it imposes on factorization are rigid and algebraically meaningful.

The mod-9 constraint, for instance, is really a consequence of the fact that 10 ≡ 1 (mod 9), which means digit sums are preserved modulo 9. In base b, the analogous constraint would involve b − 1 instead of 9. This suggests a general theory of "base-b resonance" where the group-theoretic structure of ℤ/(b−1)ℤ controls which factorizations can be digit-preserving.

The creature bestiary thus opens a door to a broader research program: understanding when and how the additive structure of digit representation interacts with the multiplicative structure of factorization. This is a territory where number theory meets combinatorics meets algebra—and where surprises like the dual vampire-ghost 1827 remind us that mathematical creatures can be more complex than they first appear.

## Looking Forward

Several tantalizing questions remain open. Do vampire numbers occur with roughly equal frequency across all valid mod-9 residue classes? Is there a closed form for the number of k-digit ghost numbers? Can the creature classification be refined to capture more subtle digit relationships?

Perhaps most intriguingly: the "digit resonance" framework suggests connections to other areas where additive and multiplicative structures collide—additive combinatorics, the theory of sum-product phenomena, and even cryptography, where the interaction between arithmetic operations and bit patterns is of fundamental importance.

The humble vampire number, born as a recreational curiosity, may yet sink its fangs into deep mathematics.
