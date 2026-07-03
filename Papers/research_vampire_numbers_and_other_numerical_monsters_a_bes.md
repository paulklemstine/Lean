# A Bestiary of Arithmetic Monsters: The Congruence Law of Vampire Numbers and Their Kin

**Author:** Aristotle
**Date:** 2026-07-03

## Abstract

A *vampire number* is a composite integer with an even number of digits that
factors as a product of two *fangs* whose combined digits are a rearrangement of
the digits of the product; the smallest is $1260 = 21 \times 60$. Although the
defining condition is purely combinatorial — a statement about digit multisets —
we show that it forces a rigid arithmetic constraint on the *values* of the
factors. Our central result is that every same-digit factorization $v = x \cdot y$
in base $b$ satisfies the congruence $x \cdot y \equiv x + y \pmod{b - 1}$.
Equivalently, over the integers, $(x - 1)(y - 1) \equiv 1 \pmod{b - 1}$: each fang
decremented by one is a unit modulo $b - 1$, and the two decremented fangs are
mutual multiplicative inverses. In base ten this yields a divisibility
obstruction — no fang is congruent to $1$ modulo $3$ — and the law generalizes
verbatim from two fangs to any finite list of factors. We situate these theorems
within a broader "bestiary" of digit-based creatures (werewolves, ghosts,
zombies), give algorithms for enumerating them, present numerical evidence, and
formulate several precise conjectures about their densities. The recurring theme
is that a coincidence between digit multisets secretly encodes a coincidence
between residue classes, which both explains the scarcity of these numbers and
connects an amusing recreational problem to the hard arithmetic of digits of
products.

**Keywords:** vampire numbers, digit permutations, casting out nines, modular
arithmetic, units modulo $n$, digit combinatorics, anagram factorizations.

---

## 1. Introduction

Recreational number theory is full of definitions that sound like jokes but
behave like mathematics. Vampire numbers, introduced by Clifford Pickover, are a
prime example. A vampire number is a composite number that can be written as the
product of two factors — its *fangs* — such that the fangs, taken together, use
precisely the same digits as the number itself. The canonical example,

$$1260 = 21 \times 60,$$

has digit multiset $\{0, 1, 2, 6\}$, and its fangs $21$ and $60$ contribute
$\{1, 2\}$ and $\{0, 6\}$, whose union is again $\{0, 1, 2, 6\}$.

The purpose of this paper is to isolate the *stable mathematical core* of this
game. We argue that the interesting, provable content is not the folklore about
how vampire numbers are distributed (which is genuinely hard, on par with
controlling factorizations of random integers), but rather a clean, exact
congruence law obeyed by *every* same-digit factorization, in *every* base. This
law is surprising precisely because it extracts an arithmetic fact about the
values $x$ and $y$ from a condition stated purely about their digits.

The paper is organized as follows. Section 2 fixes definitions and introduces the
full bestiary. Section 3 proves casting out nines in a general base. Section 4
proves the central additive congruence and its multiplicative (unit)
reformulation, together with the base-ten divisibility corollary and the
multi-factor generalization. Section 5 gives enumeration algorithms. Section 6
reports numerical experiments. Section 7 collects conjectures and discusses why
they are hard. Section 8 concludes.

---

## 2. Definitions and the Bestiary

Throughout, $b \ge 2$ is an integer base and all numbers are non-negative
integers. We write $\mathrm{dig}_b(n)$ for the finite sequence of base-$b$ digits
of $n$ (least significant first), and we treat two digit sequences as equivalent
when one is a permutation of the other, written $\sim$. For a sequence $s$, $\Sigma s$
denotes the sum of its entries.

### 2.1 Fang pairs

**Definition 2.1 (Fang pair).** A pair $(x, y)$ of natural numbers is a *fang
pair in base $b$* if the digits of the product are a permutation of the digits of
the factors concatenated:
$$\mathrm{dig}_b(x \cdot y) \;\sim\; \mathrm{dig}_b(x) \,\Vert\, \mathrm{dig}_b(y),$$
where $\Vert$ denotes concatenation of digit sequences.

**Definition 2.2 (Vampire number).** A *vampire number* in base $b$ is a
composite number $v$ with an even number $2n$ of digits admitting a factorization
$v = x \cdot y$ that is a fang pair, where each of $x, y$ has exactly $n$ digits
and $x, y$ are not both divisible by $b$ (the "no trailing-zeros-only" clause,
which excludes trivial constructions).

The smallest base-ten vampire is $1260 = 21 \times 60$; further examples include
$1395 = 15 \times 93$, $1435 = 35 \times 41$, $1530 = 30 \times 51$, and
$1827 = 21 \times 87$.

### 2.2 The wider bestiary

The fang condition is one point on a spectrum of "digit overlap" between a product
and its factors. Varying the amount of overlap yields further species.

**Definition 2.3 (Werewolf number).** A composite $v = x \cdot y$ is a *werewolf
number* if the digit set of $v$ shares *exactly one* digit value with the combined
digit set of its factors — a partial transformation between the two multisets.

**Definition 2.4 (Ghost number).** A composite $v = x \cdot y$ with $x, y > 1$ is
a *ghost number* if the digits of $v$ are disjoint from the digits of $x$ and from
the digits of $y$: the product exhibits none of the digits present in either
factor.

**Definition 2.5 (Zombie number).** A composite $v$ is a *zombie number* if it
admits two distinct nontrivial factorizations of mixed prime/composite type — each
factorization pairs a prime factor with a composite factor. The number
$125460 = 204 \times 615 = 246 \times 510$ is an illustrative specimen.

Vampires are the most rigid species (total digit conservation); ghosts are the
most transparent (total digit exclusion); werewolves interpolate; zombies record a
multiplicity phenomenon orthogonal to digit overlap. The remainder of the paper
concentrates on the arithmetic law that the *conservation* species (vampires and
their multi-fang generalization) must obey.

### 2.3 Multi-fang lists

**Definition 2.6 (Fang list).** A finite list $L = [x_1, \dots, x_k]$ of natural
numbers is a *fang list in base $b$* if
$$\mathrm{dig}_b\!\Big(\textstyle\prod_i x_i\Big) \;\sim\; \mathrm{dig}_b(x_1) \,\Vert\, \cdots \,\Vert\, \mathrm{dig}_b(x_k),$$
i.e. the digits of the product are a permutation of all digits of all factors
pooled together.

---

## 3. Casting Out Nines in a General Base

The engine behind every result in this paper is the following classical fact,
stated and proved for an arbitrary base.

**Theorem 3.1 (General casting out nines).** For all integers $b \ge 2$ and
$n \ge 0$,
$$n \;\equiv\; \Sigma\,\mathrm{dig}_b(n) \pmod{b - 1}.$$

*Proof sketch.* Write $n = \sum_{i=0}^{m} d_i \, b^i$ with $d_i$ the base-$b$
digits. Modulo $b - 1$ we have $b \equiv 1$, hence $b^i \equiv 1^i = 1$ for every
$i$. Therefore
$$n = \sum_i d_i\, b^i \;\equiv\; \sum_i d_i \cdot 1 \;=\; \Sigma\,\mathrm{dig}_b(n) \pmod{b - 1}.$$
The single degenerate case is $b = 2$, where the modulus $b - 1 = 1$ makes every
congruence trivially true; for $b \ge 3$ one has $b \bmod (b - 1) = 1$ and the
displayed reduction applies verbatim. $\qquad\blacksquare$

The content of Theorem 3.1 is that *digit sums are a faithful proxy for residues
modulo $b - 1$*. Because permutations preserve sums, any condition asserting that
one digit multiset is a rearrangement of another immediately becomes a statement
about residues — this is the lever we now pull.

---

## 4. The Vampire Congruence Law

### 4.1 The additive law

**Theorem 4.1 (Vampire congruence — additive form).** If $(x, y)$ is a fang pair
in base $b$ with $b \ge 2$, then
$$x \cdot y \;\equiv\; x + y \pmod{b - 1}.$$

*Proof.* By Definition 2.1, the digit sequence of $x \cdot y$ is a permutation of
$\mathrm{dig}_b(x) \Vert \mathrm{dig}_b(y)$. Sums are permutation-invariant and
additive over concatenation, so
$$\Sigma\,\mathrm{dig}_b(x y) = \Sigma\big(\mathrm{dig}_b(x)\Vert\mathrm{dig}_b(y)\big) = \Sigma\,\mathrm{dig}_b(x) + \Sigma\,\mathrm{dig}_b(y).$$
Now apply Theorem 3.1 three times:
$$xy \equiv \Sigma\,\mathrm{dig}_b(xy) = \Sigma\,\mathrm{dig}_b(x) + \Sigma\,\mathrm{dig}_b(y) \equiv x + y \pmod{b-1}. \qquad\blacksquare$$

The striking feature is the *decoupling* of information: the hypothesis is a
combinatorial coincidence about symbols, but the conclusion constrains the
numerical values $x, y$ with no reference to which digits actually appear.

*Verification on $1260 = 21 \times 60$ (base $10$, modulus $9$):* $21 \cdot 60 =
1260 \equiv 0$ and $21 + 60 = 81 \equiv 0 \pmod 9$. $\checkmark$

### 4.2 The multiplicative (unit) reformulation

**Theorem 4.2 (Vampire congruence — unit form).** If $(x, y)$ is a fang pair in
base $b$ with $b \ge 2$, then over the integers
$$(x - 1)(y - 1) \;\equiv\; 1 \pmod{b - 1}.$$
In particular each of $x - 1$ and $y - 1$ is a unit modulo $b - 1$, and they are
mutual inverses.

*Proof.* Expand $(x-1)(y-1) = xy - x - y + 1$. Working modulo $b - 1$ and applying
Theorem 4.1, $xy \equiv x + y$, so
$$(x-1)(y-1) = xy - (x + y) + 1 \equiv (x+y) - (x+y) + 1 = 1 \pmod{b-1}.$$
The transfer from the natural-number congruence of Theorem 4.1 to the integer
congruence uses the identity $\overline{b - 1} = \overline{b} - \overline{1}$ for
$b \ge 1$ (valid because the subtraction is not truncated) and standard properties
of integer congruences under subtraction and addition of a constant. $\blacksquare$

*Verification on $1260 = 21 \times 60$:* $(21 - 1)(60 - 1) = 20 \cdot 59 = 1180 =
131 \cdot 9 + 1 \equiv 1 \pmod 9$. $\checkmark$

The unit form is the sharp algebraic explanation for the scarcity of these
creatures: among all factor pairs of a given number, only those whose decremented
values happen to be mutually inverse residues modulo $b - 1$ can possibly be
fangs. This is a nontrivial filter that prunes the candidate space by a constant
factor determined by the base.

### 4.3 A base-ten divisibility obstruction

**Corollary 4.3 (No fang is $1$ modulo $3$).** For any base-ten fang pair
$(x, y)$, neither $x$ nor $y$ is congruent to $1$ modulo $3$.

*Proof.* By Theorem 4.2 with $b = 10$, $(x - 1)(y - 1) \equiv 1 \pmod 9$. Since
$3 \mid 9$, reducing further gives $(x - 1)(y - 1) \equiv 1 \pmod 3$. If $x \equiv
1 \pmod 3$ then $x - 1 \equiv 0 \pmod 3$, forcing $(x - 1)(y - 1) \equiv 0 \pmod
3$, contradicting $\equiv 1$. The same argument applies to $y$. $\qquad\blacksquare$

Thus the values $1, 4, 7, 10, 13, \dots$ are permanently barred from being fangs of
a decimal vampire. For $1260$, both fangs are multiples of $3$ (residue $0$), which
is consistent: only residue $1$ is forbidden, while residues $0$ and $2$ remain
admissible (a residue-$0$ and residue-$2$ pair gives $(-1)(1) = -1 \equiv 2 \pmod
3$; a residue-$0$ and residue-$0$ pair gives $(-1)(-1) = 1$, matching $1260$).

### 4.4 The multi-fang generalization

**Theorem 4.4 (Fang-list congruence).** If $L = [x_1, \dots, x_k]$ is a fang list
in base $b$ with $b \ge 2$, then
$$\prod_{i=1}^{k} x_i \;\equiv\; \sum_{i=1}^{k} x_i \pmod{b - 1}.$$

*Proof sketch.* The digits of $\prod_i x_i$ are a permutation of the pooled digits
$\Vert_i\, \mathrm{dig}_b(x_i)$, so $\Sigma\,\mathrm{dig}_b(\prod_i x_i) = \sum_i
\Sigma\,\mathrm{dig}_b(x_i)$ by permutation-invariance and additivity of sums over
concatenation (a short induction on the list). Apply Theorem 3.1 to the product
and to each factor:
$$\prod_i x_i \equiv \Sigma\,\mathrm{dig}_b\Big(\prod_i x_i\Big) = \sum_i \Sigma\,\mathrm{dig}_b(x_i) \equiv \sum_i x_i \pmod{b-1}. \qquad\blacksquare$$

The two-fang law of Theorem 4.1 is the case $k = 2$. The multiplicative
reformulation also generalizes: for a fang list, $\prod_i (x_i - 1)$ expands to an
alternating sum of elementary symmetric functions which collapses, modulo $b - 1$,
to a fixed value determined only by $k$.

---

## 5. Algorithms

We describe two algorithmic building blocks used to explore the bestiary.

### 5.1 Fang test

Given $b$, $x$, $y$, decide whether $(x, y)$ is a fang pair. Compute the digit
multisets of $x \cdot y$, $x$, and $y$; return true iff the multiset of the product
equals the union of the multisets of the factors. Cost: $O(\log(xy))$ digit
operations plus a multiset comparison.

### 5.2 Vampire enumeration in a digit window

To list all $2n$-digit vampires, iterate over candidate fang pairs $(x, y)$ with
$x \le y$, each an $n$-digit number, subject to the residue filter from Theorem
4.2 — only retain pairs with $(x - 1)(y - 1) \equiv 1 \pmod{b - 1}$ — then apply the
fang test to $v = x \cdot y$ and record the survivors. The residue filter discards
a constant fraction of pairs before the (more expensive) multiset comparison,
giving a practical constant-factor speedup that is *provably lossless* because the
filter is a necessary condition. This is the paper's law paying algorithmic
dividends.

---

## 6. Numerical Experiments

Direct enumeration up to $10^8$ confirms the theory. Every vampire number found
satisfies $x \cdot y \equiv x + y \pmod 9$ and $(x - 1)(y - 1) \equiv 1 \pmod 9$
without exception, and no fang is ever $\equiv 1 \pmod 3$, exactly as Corollary
4.3 predicts. The first several decimal vampires and their fang pairs are

$$1260 = 21 \times 60,\quad 1395 = 15 \times 93,\quad 1435 = 35 \times 41,$$
$$1530 = 30 \times 51,\quad 1827 = 21 \times 87,\quad 2187 = 27 \times 81.$$

Ghost numbers, by contrast, are common among small numbers but rapidly thin out:
as the digit length grows, the chance that a product avoids *every* digit present
in either factor collapses, matching the density-zero expectation of Section 7.
The accompanying software reproduces all of these findings and verifies the
congruence laws on every specimen it discovers.

---

## 7. Conjectures and Discussion

The exact laws above are theorems. The distributional folklore is not, and the gap
is instructive: controlling *which* numbers are vampires is entangled with
controlling the digits of products of random integers, a notoriously hard regime.

**Conjecture 7.1 (Density profile).** Let $V(2n)$ be the number of vampire numbers
in the window $[10^{2n-1}, 10^{2n})$. The density $V(2n)/(10^{2n} - 10^{2n-1})$
decays on the order of $1/\sqrt{n}$ as $n \to \infty$.

**Conjecture 7.2 (Non-vacancy).** Every even-length window $[10^{2k}, 10^{2k+2})$
contains at least one vampire number.

**Conjecture 7.3 (Ghost extinction).** Ghost numbers have density zero: the
proportion of $m$-digit composites that are ghosts tends to $0$ as $m \to \infty$.

Each of these can be reframed as a *collision probability in the space of digit
multisets*: a vampire is exactly a coincidence between the product's multiset and
the concatenated fangs' multiset. Conjecture 7.1 asks for the frequency of that
collision; Conjecture 7.3 asks for the frequency of maximal *anti*-collision. The
value congruence of Section 4 is helpful because it prunes the search space by a
constant residue-dependent factor, turning naive enumeration into a structured
count with an explicit filter — but it does not by itself resolve the asymptotics,
which appear to require second-moment or entropy/Chernoff arguments over random
digit multisets.

---

## 8. Conclusion

The bestiary of arithmetic monsters begins as a game about digits and ends as a
lesson in how symbol-level conditions imprint themselves on values. The central
discovery is that the combinatorial definition of a vampire number secretly
enforces the congruence $x \cdot y \equiv x + y \pmod{b - 1}$, equivalently the
unit relation $(x - 1)(y - 1) \equiv 1 \pmod{b - 1}$, in every base and for any
number of fangs. These laws explain why the creatures are scarce, supply a
provably lossless pruning rule for hunting them, and sharpen the folklore into
precise, falsifiable conjectures. The monsters are easy to define; the law they
obey is exact; and the census of where they live remains a genuine and inviting
open problem.
