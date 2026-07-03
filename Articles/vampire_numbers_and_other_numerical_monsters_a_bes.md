# Vampire Numbers and Other Numerical Monsters: A Bestiary of Arithmetic Oddities

In 1994, the science-fiction author and mathematician Clifford Pickover let loose a peculiar creature into the wild of number theory. He called it a *vampire number*. The idea is irresistibly simple. Take the number $1260$. Split it into two halves — not by cutting the numeral down the middle, but by finding two factors that, between them, reuse *every one of its digits*. Sure enough,

$$1260 = 21 \times 60,$$

and the digits of $21$ and $60$ — namely $2, 1, 6, 0$ — are exactly the digits of $1260$, merely shuffled. The product $1260$ is the "vampire," and its two factors $21$ and $60$ are its "fangs." Like a good movie monster, the vampire hides its true nature: multiply two innocent-looking numbers and out springs a creature wearing their digits as a disguise.

Vampire numbers are more than a curiosity. They belong to a whole *bestiary* of arithmetic creatures defined by how the digits of a product relate to the digits of its factors. In this article we meet the vampires and their cousins — **werewolves**, **ghosts**, and **zombies** — and we uncover the surprisingly rigid laws that govern where they can live. Some of these laws are conservation principles worthy of physics; one of them is an outright *taboo* that forbids certain numbers from ever being a fang at all.

## The heart of the matter: sharing digits

Every creature in the bestiary is built from a single relationship. Given a base $b \ge 2$ (base $10$ for everyday counting, base $2$ for computers), and two factors $x$ and $y$, we say that $x$ and $y$ **share all digits** with their product $x \cdot y$ if the list of digits of $x$ followed by the list of digits of $y$ is exactly a rearrangement — a permutation — of the digits of $x \cdot y$. Nothing is added, nothing is lost; the factors simply carry, between them, the exact multiset of digits that the product displays.

A vampire number is then, in essence, a product $x \cdot y$ whose two balanced fangs share all its digits (with the classical extra rules that each fang has half the digits and that the two do not both end in a trailing zero, to rule out cheap tricks like $10 \times 100$). The smallest is $1260$; the next are $1395 = 15 \times 93$, $1435 = 35 \times 41$, $1530 = 30 \times 51$, and $1827 = 21 \times 87$.

Once you have this "share all digits" relation, the rest of the bestiary writes itself by dialing the amount of digit-sharing up or down.

## A field guide to the monsters

**Vampires** share *all* their digits between the fangs and the body. They are the aristocrats of the bestiary — perfectly balanced, hiding in plain sight.

**Werewolves** are the halfway monsters. A werewolf is a product $x \cdot y$ whose factors, taken together, share *exactly one* digit-value with the product. For instance, $3 \times 5 = 15$: the digits appearing in the factors are $\{3, 5\}$, the digits of the product are $\{1, 5\}$, and the two sets meet in the single value $5$. One shared digit, one full moon.

**Ghosts** are the monsters that leave *no trace*. A ghost is a product $x \cdot y$ that shares *no* digit at all with its factors. Take $7 \times 7 = 49$: the factor digit is $\{7\}$, the product digits are $\{4, 9\}$, and they are completely disjoint. The factors have vanished from the answer, leaving only a spectral $49$ behind.

**Zombies** are the impostors. A zombie is a product $x \cdot y$ in which *both* factors are prime — a "factorization into primes" that shambles around masquerading as one of the digit monsters. The pair $15 = 3 \times 5$ is a zombie: both $3$ and $5$ are prime. Zombies remind us that the digit conditions and the multiplicative structure of a number are two different worlds that occasionally collide.

These four creatures are easy to *define* but, like factoring itself, potentially very hard to *hunt*. Deciding whether a given giant number is a vampire means searching through its factorizations and checking digits — a problem that smells a lot like integer factorization, one of the hardest problems we know how to state simply. And yet, remarkably, the creatures obey iron laws that we *can* prove, and those laws dramatically shrink the territory a hunter must search.

## The first law: conservation of digits

Here is the first and most fundamental law, and it reads like a conservation principle from physics.

> **Digit-Length Conservation Law.** If $x$ and $y$ share all their digits with the product $x \cdot y$ in base $b$, then the number of digits is conserved:
> $$\operatorname{len}(x) + \operatorname{len}(y) = \operatorname{len}(x \cdot y).$$

Why is this surprising? Because in ordinary arithmetic, digits are *not* conserved. When you multiply two two-digit numbers, the answer might have three digits or four: $12 \times 12 = 144$ (three digits) versus $99 \times 99 = 9801$ (four digits). In general the length of a product $x \cdot y$ is either $\operatorname{len}(x) + \operatorname{len}(y)$ or one less. The multiplication either "carries all the way" and fills the top digit, or it falls short and the product loses a digit to cancellation.

The conservation law says that a digit-sharing factorization *can never fall short*. The proof is almost a tautology once you see it: if the digit lists of $x$ and $y$ together form a permutation of the digit list of $x \cdot y$, then they must have the same *number* of entries. Permuting a list does not change its length. So the total digit count of the fangs equals the digit count of the body, exactly.

This immediately tells us something concrete and useful.

> **Digit-Length Extremality Law.** If $x, y \ge 1$ share all their digits with $x \cdot y$ in base $b \ge 2$, then the product is as large as its digit length allows:
> $$b^{\,\operatorname{len}(x) + \operatorname{len}(y) - 1} \le x \cdot y.$$

In words: a digit-sharing product always sits at the *very top* of the window of numbers with its digit length. There is no digit cancellation, so the product is never "short." For the smallest vampire, $\operatorname{len}(21) + \operatorname{len}(60) = 2 + 2 = 4$, so the law predicts $10^{4-1} = 1000 \le 1260$ — comfortably true. The proof is a short piece of arithmetic: from the classical bound $b^{\operatorname{len}(m)} \le b \cdot m$, substitute the conserved length and divide by $b$.

The extremality law is exactly the kind of cheap-to-check necessary condition that turns a brute-force hunt into a targeted one: it tells the hunter to ignore all the "short" products entirely.

## The second law: casting out nines, reborn

Every schoolchild who has ever checked an arithmetic sum by "casting out nines" has, without knowing it, been using digit sums modulo $9$. The rule is that a number and the sum of its digits leave the same remainder when divided by $9$ — and more generally, in base $b$, a number and its digit sum agree modulo $b - 1$.

Now recall that a digit-sharing factorization *conserves the digit sum*: the digits of $x$ and $y$ together are the digits of $x \cdot y$, so their digit sums add up. Feeding this through casting-out-nines gives a beautiful, base-independent invariant.

> **Casting-Out-$(b{-}1)$s Invariant.** If $x$ and $y$ share all digits with $x \cdot y$ in base $b \ge 2$, then
> $$x + y \equiv x \cdot y \pmod{b - 1}.$$
> In base $10$: $x + y \equiv x \cdot y \pmod 9$.

This is a genuine constraint linking the *sum* of the fangs to their *product* — a purely additive quantity forced to agree with a multiplicative one. And in base $10$ it hides an even prettier secret. Rearranging $x + y \equiv xy \pmod 9$ gives $xy - x - y + 1 \equiv 1$, that is,

$$(x - 1)(y - 1) \equiv 1 \pmod 9.$$

> **The Unit Identity.** In base $10$, each fang minus one is a *unit* modulo $9$, and the two units are inverses of each other: $(x-1)(y-1) = 1$ in the arithmetic of remainders mod $9$.

So the fangs are not free to be anything. Subtract one from each, and they must pair up as multiplicative inverses in the small clock-arithmetic world of the integers modulo $9$.

## The taboo: numbers that can never be fangs

The unit identity has a razor-sharp consequence. If $(x-1)(y-1) \equiv 1 \pmod 9$, then in particular $(x-1)(y-1) \equiv 1 \pmod 3$. The only residues modulo $3$ that have a multiplicative inverse are $1$ and $2$ — the residue $0$ is forbidden, because zero times anything is zero, never one. So $x - 1$ can never be $\equiv 0 \pmod 3$. Translating back:

> **The Mod-3 Taboo.** No fang of a base-$10$ digit-sharing factorization can be congruent to $1$ modulo $3$. That is, both $x \not\equiv 1 \pmod 3$ and $y \not\equiv 1 \pmod 3$.

This is a striking prohibition. A full one-third of all integers — those of the form $1, 4, 7, 10, 13, \dots$ — are *permanently barred* from ever serving as a fang of a vampire, werewolf, or any digit-sharing factorization in base $10$. Before a hunter multiplies a single pair of candidates, this taboo throws out a third of them. It is a sieve of pure arithmetic.

## Into the binary jungle: monsters made of bits

Everything so far lives in base $10$, but the bestiary thrives in every base — and base $2$, the language of computers, harbors its own peculiar species. Here the natural measure of a number is $s_2(n)$, the number of $1$-bits in its binary expansion (its "population count"). Because shifting a binary number left by one place — multiplying by two — merely appends a zero bit, powers of two are exactly the numbers with a single $1$-bit: $s_2(2^k) = 1$.

The binary sum of bits obeys a *submultiplicative* law: multiplying two numbers can never create more one-bits than the product of their individual one-bit counts,

$$s_2(x \cdot y) \le s_2(x) \cdot s_2(y).$$

Now combine this with digit conservation. In a base-$2$ digit-sharing factorization the bits are conserved, so $s_2(x) + s_2(y) = s_2(x \cdot y)$. Chaining the two facts gives $s_2(x) + s_2(y) \le s_2(x) \cdot s_2(y)$. If one fang were a power of two, it would contribute just a single bit, $s_2(x) = 1$, and the inequality would collapse to $1 + s_2(y) \le s_2(y)$ — an impossibility. Hence:

> **No Power-of-Two Fangs.** In base $2$, no fang of a digit-sharing factorization can be a power of two. Every binary fang carries at least two one-bits: $s_2(x) \ge 2$ and $s_2(y) \ge 2$.

The thin, sleek powers of two — the sparest numbers there are — are exiled from the binary bestiary entirely.

## How rare are the monsters?

Laws tell us where the creatures *cannot* live; counting them tells us how they *thrive*. Here the frontier is still partly conjectural, and that is part of the fun.

The vampires appear to be abundant: it is believed that the fraction of vampire numbers in the band $[10^{2n}, 10^{2n+1}]$ swells like $1/\sqrt{n}$, and that every even-length interval $[10^{2k}, 10^{2k+2}]$ harbors at least one. The ghosts, by contrast, are believed to be *exponentially rare*: as numbers grow longer, the digits of a typical product spread out to cover all ten possible values, so the chance that the factors avoid *every* product digit collapses geometrically. Ghost factorizations should make up a vanishing fraction — a density tending to zero — becoming ever harder to sight as the numbers stretch toward the horizon. The mod-3 taboo, meanwhile, is expected to eliminate a clean $1/3$ of all candidate fangs, exactly the density of the forbidden residue class.

## Why chase monsters?

At first glance this is recreational mathematics — a Halloween costume party for integers. But the bestiary is a genuine window onto deep questions. Deciding membership sits right next to integer factorization, the problem whose difficulty guards much of modern cryptography. The conservation and taboo laws are exactly the kind of *necessary conditions* that transform an intractable search into a feasible one, the same spirit in which sieves and congruence obstructions power real factoring algorithms.

And there is something delightful in the discovery that playful definitions hide rigid law. A vampire is a joke about digits; yet demanding that a product wear its factors' digits forces conservation of digit length, conservation of digit sum, a unit identity in modular arithmetic, an absolute taboo modulo $3$, and the banishment of powers of two from the binary world. The monsters, it turns out, are very well-behaved. They just have excellent disguises.
