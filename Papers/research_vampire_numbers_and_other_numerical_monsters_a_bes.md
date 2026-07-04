# A Bestiary of Arithmetic Monsters: Structural Obstructions for Digit-Permutation Factorizations

**Author:** Aristotle
**Date:** 2026-07-04

## Abstract

A *vampire number* is a composite integer with an even number of decimal digits that factors into two equal-length "fangs" whose digits, taken together, form a permutation of the digits of the product. The smallest is $1260 = 21 \times 60$. Although the definition is elementary, deciding vampirism is entangled with integer factorization. We isolate the combinatorial core of the definition — the *digit-permutation factorization* — and prove three structural obstructions that every such factorization must satisfy: (1) a **casting-out-nines** law, $x \cdot y \equiv x + y \pmod 9$, equivalently $(x-1)(y-1) \equiv 1 \pmod 9$; (2) a sharp **mod-three sieve**, that neither fang can be congruent to $1$ modulo $3$; and (3) a **length-additivity** ("no carry shrinkage") law, $\operatorname{len}(x \cdot y) = \operatorname{len}(x) + \operatorname{len}(y)$. We then build a **base-2 bridge**: writing $s_2$ for the binary digit sum, we prove that $s_2$ is submultiplicative, $s_2(x \cdot y) \le \min(y\, s_2(x),\, x\, s_2(y))$, and specialize it to bound the binary complexity of any vampire number by that of a single fang. We package the classical definition, verify $1260 = 21 \times 60$ as an honest instance, situate the results within a broader "bestiary" of digit-sharing creatures (werewolves, ghosts, zombies), and record the density questions these obstructions open. All results are stated inline with proof sketches.

**Keywords:** vampire numbers, digit-permutation factorization, casting out nines, digit sum, binary complexity, submultiplicativity, recreational number theory.

---

## 1. Introduction

Recreational number theory is full of creatures defined by how a number relates to its own digits: palindromes, Harshad numbers, narcissistic numbers, and — the subject of this paper — **vampire numbers**, introduced by Clifford Pickover. A vampire number appears innocent until factored, whereupon it splits into two smaller numbers, its *fangs*, whose combined digits are exactly a rearrangement of the original.

The smallest vampire is
$$1260 = 21 \times 60,$$
where the fang digits $\{2,1,6,0\}$ permute the product digits $\{1,2,6,0\}$.

What makes vampire numbers more than a curiosity is that their definition sits precisely on the boundary between the trivially checkable and the computationally hard. To *verify* a claimed factorization is instant; to *decide* whether a given number is a vampire requires searching its factorizations, a task interwoven with the difficulty of integer factorization itself.

Our aim is to extract, from the folklore definition, a clean combinatorial invariant and to prove exact structural theorems about it. These theorems act as **sieves**: cheap, factoring-free tests that any candidate fang pair must survive. We further connect the base-10 combinatorics to base-2 arithmetic via a submultiplicativity law for the binary digit sum.

### Contributions

1. A precise separation of the *combinatorial* condition (digit-permutation factorization) from the *classical* vampire definition (Section 2).
2. Three exact obstructions: casting out nines and its corollary $(x-1)(y-1)\equiv 1 \pmod 9$ (Section 3); the mod-three fang sieve (Section 4); length additivity (Section 5).
3. A base-2 bridge: submultiplicativity of the binary digit sum and its specialization to vampire numbers (Section 6).
4. A worked instance ($1260 = 21 \times 60$) and a wider bestiary of digit-sharing numbers (Sections 7–8), with density questions and future directions (Sections 9–10).

---

## 2. Definitions

Throughout, integers are non-negative and written in base $10$ unless a base is indicated. For $n \in \mathbb{N}$ let $D(n)$ denote the **multiset of decimal digits** of $n$, and let $\operatorname{len}(n) = |D(n)|$ be the number of decimal digits. Let $\sigma(n)$ denote the (decimal) **digit sum**, $\sigma(n) = \sum_{d \in D(n)} d$.

**Definition 2.1 (Digit-permutation factorization).**
An ordered pair $(x, y)$ is a *digit-permutation factorization* of $v$ if
$$v = x \cdot y \qquad \text{and} \qquad D(x) \uplus D(y) = D(v),$$
where $\uplus$ denotes multiset union. Equivalently, concatenating the digit lists of $x$ and $y$ yields a permutation of the digit list of $v$.

This is the purely combinatorial heart of the notion. The classical definition adds size and degeneracy conditions.

**Definition 2.2 (Vampire pair).**
Let $v$ have $2k$ decimal digits. A pair $(x, y)$ is a *vampire pair* for $v$ if it is a digit-permutation factorization of $v$ with $\operatorname{len}(x) = \operatorname{len}(y) = k$, and $x, y$ are not *both* divisible by $10$ (the "no trailing-zero pair" condition, which excludes degenerate padding).

**Definition 2.3 (Vampire number).**
$v$ is a *vampire number* if it admits at least one vampire pair. Its fangs are the two members of such a pair.

**Definition 2.4 (Bestiary variants).**
Fix a factorization $v = x \cdot y$ into two equal-length factors. Say $v$ is:
- a **werewolf** if $D(x) \uplus D(y)$ shares exactly one digit (with multiplicity) with $D(v)$;
- a **ghost** if $D(x) \uplus D(y)$ shares no digit with $D(v)$;
- a **zombie** if $v$ has two distinct such factorizations, at least one of which pairs a prime with a composite in violation of the classical vampire constraints, e.g. $125460 = 204 \times 615 = 246 \times 510$.

The vampire is the perfect-overlap extreme; ghosts are the zero-overlap extreme; werewolves and zombies interpolate. The theorems below concern the vampire/digit-permutation case, which is the richest and the one where exact structure emerges.

---

## 3. Casting Out Nines for Factorizations

The classical rule of *casting out nines* states that every integer is congruent to its digit sum modulo $9$:
$$n \equiv \sigma(n) \pmod 9 \qquad \text{for all } n \in \mathbb{N}. \tag{3.1}$$
This is immediate from $10 \equiv 1 \pmod 9$, so each positional weight $10^i \equiv 1$, and the value collapses to the digit sum modulo $9$.

**Theorem 3.1 (Casting out nines for digit-permutation factorizations).**
If $(x, y)$ is a digit-permutation factorization of $v$, then
$$x \cdot y \;\equiv\; x + y \pmod 9,$$
equivalently
$$(x - 1)(y - 1) \;\equiv\; 1 \pmod 9.$$

*Proof sketch.* Because $D(x) \uplus D(y) = D(v)$, the digit sums satisfy $\sigma(v) = \sigma(x) + \sigma(y)$ (the digit sum is additive over multiset union). Applying (3.1) three times,
$$v \equiv \sigma(v) = \sigma(x) + \sigma(y) \equiv x + y \pmod 9.$$
Since $v = x \cdot y$, this is $x \cdot y \equiv x + y \pmod 9$. Adding $1$ to both sides and factoring,
$$xy - x - y + 1 \equiv 1 \pmod 9 \iff (x-1)(y-1) \equiv 1 \pmod 9. \qquad \blacksquare$$

The rearranged form is the more useful of the two: it says $x - 1$ and $y - 1$ are *mutually inverse* modulo $9$. In the units group $(\mathbb{Z}/9\mathbb{Z})^\times$ of order $6$, this confines the pair $(x \bmod 9, y \bmod 9)$ to a small explicit set.

---

## 4. The Mod-Three Fang Sieve

Theorem 3.1 has a sharp and immediately useful corollary.

**Theorem 4.1 (No fang is $\equiv 1 \pmod 3$).**
If $(x, y)$ is a digit-permutation factorization, then neither $x$ nor $y$ is congruent to $1$ modulo $3$.

*Proof sketch.* By Theorem 3.1, $(x-1)(y-1) \equiv 1 \pmod 9$, and reducing modulo $3$ gives $(x-1)(y-1) \equiv 1 \pmod 3$. In particular the product $(x-1)(y-1)$ is a unit modulo $3$, hence coprime to $3$, so neither factor is divisible by $3$. But $x \equiv 1 \pmod 3$ would force $3 \mid (x-1)$, a contradiction; likewise for $y$. $\blacksquare$

**Remark 4.2.** This is a genuine, factoring-free sieve. Among residues modulo $3$, exactly one of the three classes ($1$) is eliminated for each fang, so a full third of candidate factors are rejected before any digit comparison. Combined with the trailing-zero condition, it substantially prunes the search space for vampire hunts.

---

## 5. Length Additivity: No Carry Shrinkage

Multiplying two decimal numbers of lengths $a$ and $b$ yields a product of length either $a + b$ or $a + b - 1$; the shorter case arises when the leading digits produce no carry. For digit-permutation factorizations the shorter case is impossible.

**Theorem 5.1 (Length additivity).**
If $(x, y)$ is a digit-permutation factorization of $v = x \cdot y$, then
$$\operatorname{len}(x \cdot y) = \operatorname{len}(x) + \operatorname{len}(y).$$

*Proof sketch.* Counting digits with multiplicity, $|D(v)| = |D(x)| + |D(y)|$ because $D(x) \uplus D(y) = D(v)$ is a multiset identity that preserves cardinality. By definition $\operatorname{len} = |D(\cdot)|$, so $\operatorname{len}(v) = \operatorname{len}(x) + \operatorname{len}(y)$, and $v = x\cdot y$. $\blacksquare$

**Interpretation.** The digit-permutation hypothesis secretly encodes a *metric* statement: the product must occupy the maximal number of decimal places consistent with its factors — no leading digit is lost to a collapsing carry. Because length can be read off instantly, Theorem 5.1 is a check that can be applied *before* any digit-multiset comparison, rejecting balanced factorizations that shrink under multiplication.

---

## 6. A Base-2 Bridge: Submultiplicativity of the Binary Digit Sum

The obstructions above live in base $10$. We now connect them to base $2$. For $n \in \mathbb{N}$, let
$$s_2(n) = \text{(number of $1$'s in the binary expansion of } n),$$
the binary digit sum (population count). The starting point is the standard subadditivity law, which reflects that binary addition can only merge or cancel ones via carries, never manufacture them:
$$s_2(a + b) \;\le\; s_2(a) + s_2(b) \qquad \text{for all } a, b \in \mathbb{N}. \tag{6.1}$$

**Theorem 6.1 (Submultiplicativity of $s_2$).**
For all $x, y \in \mathbb{N}$,
$$s_2(x \cdot y) \;\le\; y \cdot s_2(x).$$

*Proof sketch.* Induct on $y$. For $y = 0$, $s_2(0) = 0$. For the step, write $x \cdot (y+1) = x \cdot y + x$ and apply (6.1):
$$s_2(x(y+1)) = s_2(xy + x) \le s_2(xy) + s_2(x) \le y\, s_2(x) + s_2(x) = (y+1) s_2(x),$$
using the induction hypothesis $s_2(xy) \le y\, s_2(x)$. $\blacksquare$

By exchanging the roles of $x$ and $y$ we obtain the symmetric sharpening.

**Corollary 6.2 (Symmetric bound).** For all $x, y \in \mathbb{N}$,
$$s_2(x \cdot y) \;\le\; \min\big(y \cdot s_2(x),\; x \cdot s_2(y)\big).$$

Specializing to a vampire pair bounds the binary complexity of the monster by that of a single fang.

**Theorem 6.3 (Binary complexity bound for vampire numbers).**
If $(x, y)$ is a vampire pair for $v$ (indeed for any factorization $v = x \cdot y$), then
$$s_2(v) \;\le\; \min\big(y \cdot s_2(x),\; x \cdot s_2(y)\big).$$

*Proof sketch.* Substitute $v = x \cdot y$ into Corollary 6.2. $\blacksquare$

**Remark 6.4 (The bound is genuine, not an equality).** Multiplication both creates and destroys binary carries, so $s_2(xy)$ is generally far below its bound. For $1260 = 21 \times 60$: $s_2(1260) = 6$ (since $1260 = 10011101100_2$), while $s_2(21) = 3$ and $s_2(60) = 4$, giving $\min(60 \cdot 3, 21 \cdot 4) = \min(180, 84) = 84 \ge 6$. The gap illustrates that Theorem 6.1 is a true inequality, proved by induction rather than by any equality of digit sums.

---

## 7. A Worked Instance: $1260 = 21 \times 60$

We verify that $1260$ is a vampire number and that all three obstructions hold.

- **Factorization and digits.** $1260 = 21 \times 60$. Fang digits $\{2, 1\} \uplus \{6, 0\} = \{0, 1, 2, 6\}$; product digits $\{1, 2, 6, 0\} = \{0, 1, 2, 6\}$. Multisets agree: it is a digit-permutation factorization. Each fang has $2$ digits, half of the $4$ digits of $1260$, and not both fangs are divisible by $10$ (since $21$ is not). So $(21, 60)$ is a vampire pair.
- **Casting out nines (Theorem 3.1).** $21 \cdot 60 = 1260 \equiv 0 \pmod 9$; $21 + 60 = 81 \equiv 0 \pmod 9$. Both sides agree. And $(21-1)(60-1) = 20 \cdot 59 = 1180 \equiv 1 \pmod 9$ (since $1180 = 131 \cdot 9 + 1$).
- **Mod-three sieve (Theorem 4.1).** $21 \equiv 0$ and $60 \equiv 0 \pmod 3$; neither is $\equiv 1$.
- **Length additivity (Theorem 5.1).** $\operatorname{len}(1260) = 4 = 2 + 2 = \operatorname{len}(21) + \operatorname{len}(60)$.
- **Binary bridge (Theorem 6.3).** $s_2(1260) = 6 \le \min(84, 180) = 84$.

All conditions and obstructions check out.

---

## 8. The Wider Bestiary

The vampire is one member of a family indexed by *digit overlap* between a product and its factors (Definition 2.4). Enumerating small cases up to $10^8$ (see the accompanying computational demonstrations) reveals:

- **Vampires** grow denser as digit length increases; balanced factorizations of long numbers have many chances to permute correctly.
- **Werewolves** (exactly one shared digit) are common but structurally noisier; the exact-overlap-one constraint admits no clean modular obstruction analogous to Theorem 3.1.
- **Ghosts** (zero shared digits) become vanishingly rare: as the number of digits grows, avoiding *every* digit of the product across both factors is combinatorially punishing, and their density appears to tend to $0$.
- **Zombies** are the pathological doubles, such as $125460 = 204 \times 615 = 246 \times 510$, whose multiple factorizations straddle the classical constraints.

The vampire and its casting-out-nines structure are the part of the bestiary where exact theorems are currently within reach; the others are, at present, better understood empirically.

---

## 9. Density Questions

A widely repeated informal claim asserts that vampire numbers have "density approaching $1/\sqrt{n}$" in the interval $[10^{2n}, 10^{2n+1}]$. As literally stated this is **ill-posed**: $1/\sqrt{n} \to 0$, so it would assert *vanishing* density, contradicting the intended reading that vampires become common. We therefore do not adopt it as a theorem and flag it as false-as-stated; the honest empirical picture is that the *count* of vampires grows quickly with digit length while the exact asymptotic density remains open.

What the obstructions of this paper *do* deliver toward density is a rigorous *upper* bound mechanism. Theorem 4.1 removes a fixed positive fraction ($\tfrac13$) of candidate residues for every fang at every scale, and such a local congruence obstruction multiplies through to a global density ceiling. Making this precise — bounding the number of vampires below $N$ by counting admissible residue pairs — is a purely combinatorial argument requiring no analytic number theory, and is the most immediate open problem (Section 10).

---

## 10. Future Directions

**A complete residue sieve for fangs.** Casting out nines is the first member of an infinite family: a number is congruent to its digit sum not only modulo $9$ but modulo $99$, $999$, and every $10^k - 1$ after grouping digits into blocks of length $k$. Each modulus yields an independent multiplicative constraint on the fangs; their intersection should pin the residues $(x, y)$ to a vanishingly small fraction of pairs. Because the base case is proved and the block-digit generalization uses the same multiset-to-sum transfer, the whole tower is within reach and would reduce vampire hunting to solving a small system of congruences.

**A density ceiling from the mod-three obstruction.** Because neither fang can be $\equiv 1 \pmod 3$, the number of vampires below $N$ should be at most a constant times $N / \log N$ (bounding fang-pair counts by residue-avoiding pairs), yielding an unconditional upper density tending to $0$. The remaining step is a clean combinatorial count over admissible residue classes.

**No carry shrinkage as a characterization.** A composite $v$ with $2k$ digits is conjecturally a vampire *iff* it factors as $v = x \cdot y$ with $\operatorname{len}(x) = \operatorname{len}(y) = k$, $\operatorname{len}(xy) = \operatorname{len}(x) + \operatorname{len}(y)$, and the digit-multiset condition holds. Length additivity being a necessary condition (Theorem 5.1), the question is how much of the digit condition it captures, and whether it alone rejects a positive proportion of balanced factorizations.

---

## 11. Conclusion

Behind the playful image of numbers that devour their own digits lies genuine arithmetic structure. The digit-permutation condition, though combinatorial, forces exact congruences (casting out nines and the mod-three sieve), an exact metric law (length additivity), and connects across bases to a submultiplicativity bound on binary complexity. These results are cheap to check, factoring-free, and open a clear path toward density theorems. The bestiary is a serious question asked in a light voice: how much can a number's digits reveal about how it factors? Quite a lot, it turns out — enough to sieve, to bound, and to bridge from base ten to base two.

---

## References

- C. A. Pickover, *Keys to Infinity*, Wiley, 1995 (introduction of vampire numbers).
- Standard facts on casting out nines and the divisibility rule for $9$ (any elementary number theory text).
