# A Bestiary of Numerical Monsters: Digit-Congruence Invariants and a Conservation Law for Digit-Sharing Factorizations

## Abstract

A *vampire number* is a composite integer with an even number of digits that factors as $v = x \cdot y$, where the two factors ("fangs") together reuse exactly the multiset of digits of $v$. The smallest is $1260 = 21 \times 60$. Abstracting away the classical balance conditions, the combinatorial core of the whole family of digit-factorization creatures — vampires, *werewolves*, *ghosts*, and *zombies* — is a single relation: the digits of $x$ concatenated with the digits of $y$ form a permutation of the digits of $x \cdot y$ in base $b$. We call such a pair *digit-sharing*. We prove a suite of base-independent structural laws obeyed by every digit-sharing factorization. First, a **conservation law**: the digit length is exactly additive, $\operatorname{len}(x) + \operatorname{len}(y) = \operatorname{len}(x \cdot y)$, which forces the product to sit at the maximum of its length window and yields the sharp lower bound $b^{\operatorname{len}(x)+\operatorname{len}(y)-1} \le x \cdot y$. Second, a **casting-out-$(b{-}1)$s invariant**: $x + y \equiv x \cdot y \pmod{b-1}$, which in base $10$ sharpens to the *unit identity* $(x-1)(y-1) \equiv 1 \pmod 9$ and hence to an arithmetic **taboo**: no fang is $\equiv 1 \pmod 3$. Third, a **binary bridge**: via submultiplicativity of the binary digit sum, no fang of a base-$2$ digit-sharing factorization is a power of two. We formalize the wider bestiary, give witnesses for each creature, present enumeration algorithms exploiting the invariants as a sieve, and discuss density conjectures and open problems.

## 1. Introduction

Vampire numbers were introduced by Clifford Pickover in 1994 as a recreational curiosity: a composite number $v$ with an even number $2k$ of digits admits a *vampire factorization* $v = x \cdot y$ if $x$ and $y$ each have $k$ digits, they do not both end in a trailing zero, and the concatenated digits of $x$ and $y$ are a permutation of the digits of $v$. The smallest example is $1260 = 21 \times 60$; the sequence continues $1395, 1435, 1530, 1827, \dots$

Beneath the whimsical framing lies a hard combinatorial problem. Deciding whether a large number is a vampire requires searching its factorizations while enforcing a digit-permutation constraint — a task closely allied to integer factorization. This motivates the search for *necessary conditions*: cheap-to-verify invariants that a digit-sharing factorization must satisfy, which prune the search space before any expensive multiplication or factorization is attempted.

This paper isolates the combinatorial heart of the vampire definition and the broader *bestiary* of digit-factorization creatures, and proves base-independent invariants for all of them. The central object is the following relation.

**Definition 1.1 (Digit-sharing).** Fix a base $b \ge 2$. Write $\operatorname{dig}_b(n)$ for the list of base-$b$ digits of $n$ (least significant first) and $\operatorname{len}_b(n)$ for its length. The pair $(x, y)$ is **digit-sharing** in base $b$, written $\mathrm{SharesAllDigits}(b, x, y)$, if the concatenation $\operatorname{dig}_b(x) \mathbin{+\!+} \operatorname{dig}_b(y)$ is a permutation of $\operatorname{dig}_b(x \cdot y)$.

Equivalently, the multiset of digits of $x$ together with those of $y$ equals the multiset of digits of the product. A vampire number is (up to the balance and trailing-zero conditions) precisely a product $x \cdot y$ with a digit-sharing pair of equal-length factors.

Throughout, all quantities are non-negative integers. We use two standard facts about base-$b$ digits, valid for $b \ge 2$:

- **(D1) Base bound:** $b^{\operatorname{len}_b(m)} \le b \cdot m$ for $m \ge 1$.
- **(D2) Digit-sum congruence:** the digit sum $S_b(n) = \sum \operatorname{dig}_b(n)$ satisfies $n \equiv S_b(n) \pmod{b-1}$.

## 2. The bestiary

Let $\operatorname{D}_b(n)$ denote the *set* (not multiset) of distinct digit-values occurring in $n$ in base $b$; concretely $\operatorname{D}_b(n)$ is the underlying set of the list $\operatorname{dig}_b(n)$.

**Definition 2.1 (Vampires / digit-sharing core).** $(x, y)$ is *digit-sharing* (Definition 1.1). Adding the balance condition $\operatorname{len}_b(x) = \operatorname{len}_b(y)$ and the trailing-zero exclusion recovers Pickover's vampire numbers.

**Definition 2.2 (Werewolf pair).** $(x, y)$ is a **werewolf pair** in base $b$ if the factors share *exactly one* distinct digit-value with the product:
$$\bigl| \bigl(\operatorname{D}_b(x) \cup \operatorname{D}_b(y)\bigr) \cap \operatorname{D}_b(x \cdot y) \bigr| = 1.$$

**Definition 2.3 (Ghost pair).** $(x, y)$ is a **ghost pair** in base $b$ if the factors share *no* digit-value with the product:
$$\bigl(\operatorname{D}_b(x) \cup \operatorname{D}_b(y)\bigr) \cap \operatorname{D}_b(x \cdot y) = \varnothing.$$

**Definition 2.4 (Zombie pair).** $(x, y)$ is a **zombie pair** if *both factors are prime*: $x$ and $y$ are each prime. Zombies are "factorizations into primes" that masquerade as digit monsters; they are governed by multiplicative rather than digit structure and generally intersect the other classes only sporadically.

**Non-vacuity (witnesses).** Each creature is realized:
- Vampire core: $(21, 60)$ with $21 \cdot 60 = 1260$ is digit-sharing in base $10$ (digits $\{2,1\}, \{6,0\}$ permute $\{1,2,6,0\}$).
- Werewolf: $(3, 5)$ with $3 \cdot 5 = 15$: $\operatorname{D}_{10}(3) \cup \operatorname{D}_{10}(5) = \{3,5\}$ meets $\operatorname{D}_{10}(15) = \{1,5\}$ in the single value $5$.
- Ghost: $(7, 7)$ with $7 \cdot 7 = 49$: $\{7\}$ is disjoint from $\{4,9\}$.
- Zombie: $(3, 5)$, both prime, product $15$.

## 3. The conservation law

Our first main result is a conservation principle. In general the length of a product satisfies $\operatorname{len}_b(x \cdot y) \in \{\operatorname{len}_b(x) + \operatorname{len}_b(y) - 1,\ \operatorname{len}_b(x) + \operatorname{len}_b(y)\}$: the product either fills its top digit or loses one to lack of carry. Digit-sharing forbids the loss.

**Theorem 3.1 (Digit-Length Conservation).** If $(x, y)$ is digit-sharing in base $b$, then
$$\operatorname{len}_b(x) + \operatorname{len}_b(y) = \operatorname{len}_b(x \cdot y).$$

*Proof.* By definition $\operatorname{dig}_b(x) \mathbin{+\!+} \operatorname{dig}_b(y)$ is a permutation of $\operatorname{dig}_b(x \cdot y)$. A permutation preserves length, and the length of a concatenation is the sum of lengths, so $\operatorname{len}_b(x) + \operatorname{len}_b(y) = \operatorname{len}_b(x \cdot y)$. $\qquad\blacksquare$

**Theorem 3.2 (Digit-Length Extremality).** If $x, y \ge 1$ are digit-sharing in base $b \ge 2$, then the product attains the maximum size for its digit length:
$$b^{\,\operatorname{len}_b(x) + \operatorname{len}_b(y) - 1} \le x \cdot y.$$

*Proof.* Let $L = \operatorname{len}_b(x \cdot y)$. Since $x, y \ge 1$ we have $x \cdot y \ge 1$, so $L \ge 1$. By the base bound (D1), $b^{L} \le b \cdot (x \cdot y)$. Writing $b^{L} = b \cdot b^{L-1}$ and cancelling the positive factor $b$ gives $b^{L-1} \le x \cdot y$. Now substitute the conserved length $L = \operatorname{len}_b(x) + \operatorname{len}_b(y)$ from Theorem 3.1. $\qquad\blacksquare$

**Remark 3.3.** Theorem 3.2 says digit-sharing products are never "short": they lie in the top decade of their length class. For $(21, 60)$: $L = 4$, and $10^{3} = 1000 \le 1260$. The condition is necessary but not sufficient — $99 \times 99 = 9801$ satisfies $\operatorname{len}=4=2+2$ yet is not digit-sharing — so length equality is a genuine filter, not a characterization.

## 4. Congruence invariants and the mod-3 taboo

The digit-sharing relation conserves not just digit *count* but digit *sum*: since the multiset of digits is preserved, $S_b(x) + S_b(y) = S_b(x \cdot y)$. Combined with (D2) this yields an additive-multiplicative congruence.

**Theorem 4.1 (Casting-out-$(b{-}1)$s invariant).** If $(x, y)$ is digit-sharing in base $b \ge 2$, then
$$x + y \equiv x \cdot y \pmod{b - 1}.$$

*Proof.* By (D2), $x \equiv S_b(x)$, $y \equiv S_b(y)$, and $x \cdot y \equiv S_b(x \cdot y)$, all modulo $b - 1$. Digit-sharing gives $S_b(x) + S_b(y) = S_b(x \cdot y)$. Adding the first two congruences and substituting yields $x + y \equiv S_b(x) + S_b(y) = S_b(x\cdot y) \equiv x \cdot y \pmod{b-1}$. $\qquad\blacksquare$

Specializing to base $10$ ($b - 1 = 9$) and completing the product:

**Theorem 4.2 (Unit identity mod 9).** If $(x, y)$ is digit-sharing in base $10$, then
$$(x - 1)(y - 1) \equiv 1 \pmod 9,$$
i.e. in the ring $\mathbb{Z}/9\mathbb{Z}$ each of $x - 1$ and $y - 1$ is a unit, and the two are mutual inverses.

*Proof.* From Theorem 4.1 with $b = 10$, $x + y \equiv xy \pmod 9$. Hence $xy - x - y + 1 \equiv 1$, and the left side factors as $(x-1)(y-1)$. Since the product of the two residues is $1$, each is invertible. $\qquad\blacksquare$

**Theorem 4.3 (The mod-3 taboo).** If $(x, y)$ is digit-sharing in base $10$, then neither fang is $\equiv 1 \pmod 3$; that is, $x \not\equiv 1 \pmod 3$ and $y \not\equiv 1 \pmod 3$.

*Proof.* Reduce Theorem 4.2 modulo $3$ (a divisor of $9$): $(x-1)(y-1) \equiv 1 \pmod 3$. In $\mathbb{Z}/3\mathbb{Z}$ the residue $0$ is not invertible, so $x - 1 \not\equiv 0$ and $y - 1 \not\equiv 0 \pmod 3$; equivalently $x \not\equiv 1$ and $y \not\equiv 1 \pmod 3$. $\qquad\blacksquare$

**Corollary 4.4 (Sieve density).** The residue class $\{n : n \equiv 1 \pmod 3\}$ has natural density $1/3$ and consists entirely of integers that can never be a fang of a base-$10$ digit-sharing factorization. Consequently any enumeration may discard a $1/3$ fraction of candidate factors a priori.

## 5. A binary bridge: no power-of-two fangs

The invariants above are base-independent in origin but take their sharpest form in base $10$. In base $2$ the natural statistic is the binary digit sum (population count) $s_2(n) = S_2(n)$. Powers of two are exactly the numbers with $s_2 = 1$. A classical fact about the binary digit sum is submultiplicativity.

**Lemma 5.1 (Submultiplicativity of $s_2$).** For all $x, y$, $s_2(x \cdot y) \le s_2(x) \cdot s_2(y)$.

*Sketch.* Write $x = \sum_{i \in A} 2^i$ with $|A| = s_2(x)$. Then $x \cdot y = \sum_{i \in A} 2^i y$, a sum of $s_2(x)$ shifted copies of $y$. Each shift $2^i y$ has $s_2(2^i y) = s_2(y)$ one-bits (shifting only appends zeros), and the digit sum of a sum is at most the sum of the digit sums (subadditivity of $s_2$, since carries only remove one-bits). Hence $s_2(x \cdot y) \le \sum_{i \in A} s_2(y) = s_2(x)\, s_2(y)$. $\qquad\blacksquare$

**Theorem 5.2 (No power-of-two fangs).** If $(x, y)$ is digit-sharing in base $2$ with $x, y \ge 1$, then $s_2(x) \ge 2$ and $s_2(y) \ge 2$. In particular neither fang is a power of two.

*Proof.* Digit-sharing conserves the binary digit sum: $s_2(x) + s_2(y) = s_2(x \cdot y)$. By Lemma 5.1, $s_2(x) + s_2(y) \le s_2(x)\, s_2(y)$. Suppose $s_2(x) = 1$. Then $1 + s_2(y) \le s_2(y)$, i.e. $1 \le 0$, impossible (note $s_2(y) \ge 1$ for $y \ge 1$). Hence $s_2(x) \ge 2$, and symmetrically $s_2(y) \ge 2$. Since powers of two are exactly the numbers with $s_2 = 1$, no fang is a power of two. $\qquad\blacksquare$

**Remark 5.3.** Theorem 5.2 exiles the sparsest integers — the powers of two — from the binary bestiary, and gives the two-sided relation $s_2(x) + s_2(y) = s_2(x \cdot y) \le s_2(x)\, s_2(y)$, a natural starting point for asymptotic counting of binary monsters.

## 6. Algorithms

The invariants convert directly into pruning steps for an enumeration hunt. We describe the base-$10$ vampire hunt; the bestiary variants replace the digit-multiset test with the relevant set-intersection test.

**Algorithm A (Invariant-sieved vampire enumeration).** To enumerate vampire numbers up to $N = 10^{2k}$:

1. For each candidate fang length $k$, iterate over pairs $(x, y)$ with $\operatorname{len}(x) = \operatorname{len}(y) = k$.
2. **Mod-3 taboo prune (Theorem 4.3):** skip immediately if $x \equiv 1 \pmod 3$ or $y \equiv 1 \pmod 3$. (Removes $\approx 1/3$ of each factor.)
3. **Casting-out-nines prune (Theorem 4.1):** skip unless $x + y \equiv x \cdot y \pmod 9$.
4. **Trailing-zero exclusion:** skip if both $x$ and $y$ end in $0$.
5. **Digit test:** form $v = x \cdot y$; accept iff $\operatorname{dig}(x) \mathbin{+\!+} \operatorname{dig}(y)$ is a permutation of $\operatorname{dig}(v)$ (equivalently, sorted-digit equality).

Steps 2–4 are $O(1)$ arithmetic filters that eliminate the overwhelming majority of pairs before the $O(k \log k)$ digit-sort test of step 5. The extremality law (Theorem 3.2) is automatically satisfied by equal-length balanced pairs and can be used to prune unbalanced generalizations.

**Algorithm B (Bestiary classifier).** Given $(x, y)$, compute $v = x\cdot y$ and the digit sets $\operatorname{D}(x), \operatorname{D}(y), \operatorname{D}(v)$, and the shared set $S = (\operatorname{D}(x) \cup \operatorname{D}(y)) \cap \operatorname{D}(v)$. Classify: *ghost* if $|S| = 0$; *werewolf* if $|S| = 1$; test digit-multiset equality for *vampire*; test primality of $x, y$ for *zombie*. A single pass over the digits classifies the pair against all four species.

## 7. Applications and interpretation

- **Search-space reduction.** The congruence filters (Theorems 4.1, 4.3) are the arithmetic analogue of a sieve: they eliminate candidate factors and factor pairs at $O(1)$ cost, complementing the length filter of Theorem 3.2.
- **Cross-base robustness.** Theorems 3.1, 3.2, and 4.1 hold in every base $b \ge 2$, so the conservation and casting-out invariants are structural features of digit-sharing, not artifacts of base $10$.
- **Connection to factoring.** Membership testing for the bestiary is intertwined with integer factorization; the invariants show how far purely digit-theoretic constraints can prune such problems, echoing congruence obstructions used in real factoring sieves.

## 8. Density conjectures and open problems

The proven results are necessary conditions; the enumerative behavior of the bestiary remains largely conjectural.

1. **Vampire abundance.** The density of vampire numbers in $[10^{2n}, 10^{2n+1}]$ is conjectured to behave like $1/\sqrt{n}$ as $n \to \infty$, and every even-length interval $[10^{2k}, 10^{2k+2}]$ is conjectured to contain at least one vampire.
2. **Ghosts are exponentially rare.** As lengths grow, the digit set of a product saturates all $b$ values, so the probability a factor pool avoids every product digit should decay geometrically. Conjecturally the ghost fraction is $O(\rho^n)$ for some $\rho < 1$, giving natural density $0$.
3. **Unit spectrum (base $b \ge 3$).** Beyond the forward invariant $(x-1)(y-1) \equiv 1 \pmod{b-1}$, does every unit class modulo $b - 1$ arise from infinitely many digit-sharing factorizations (equidistribution of unit classes)?
4. **Binary count.** Turning the two-sided bound $s_2(x) + s_2(y) = s_2(v) \le s_2(x) s_2(y)$ into an asymptotic count: is the number of binary monsters below $2^n$ of order $c \cdot 2^n / n$?

## 9. Conclusion

Stripping the vampire definition down to its combinatorial core — the digit-sharing relation — reveals that whimsical digit games are governed by rigid structure. Digit-sharing factorizations conserve digit length and digit sum, forcing an extremal size bound, an additive-multiplicative congruence, a unit identity modulo $9$, an absolute taboo modulo $3$, and the banishment of powers of two in binary. These base-independent invariants both explain why the monsters are well-behaved and provide concrete, cheap filters for hunting them. The counting questions — how densely vampires crowd the number line, how quickly ghosts fade — remain enticing open problems at the boundary between recreational and serious number theory.
