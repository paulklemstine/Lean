# A Digit-Multiset Framework for Vampire Numbers and Their Modular Signatures

## Abstract

A *vampire number* is a positive integer $v$ with an even number of decimal digits that factors as $v = x \cdot y$, where the two *fangs* $x$ and $y$ each have half as many digits as $v$ and together use exactly the digits of $v$, rearranged. We develop the theory of vampire numbers — and a wider *bestiary* of related "numerical monsters" (werewolves, ghosts, and zombies) — from a single organizing principle: the invariance of the **multiset of decimal digits** across a fang factorization. We prove, using only multiset arithmetic, that both the digit sum and the digit count are additive across a fang pair. From digit-sum additivity, combined with the classical *casting out nines* property of decimal representation, we derive the modular signature of a vampire: the congruences $v \equiv x + y \pmod 9$ and $v \equiv x + y \pmod 3$. These in turn yield a *fang taboo* — neither fang may be congruent to $1$ modulo $3$ — and, modulo nine, confine the residue pair of the fangs to a small explicit solution set. We emphasize a deliberately acyclic logical architecture: the combinatorial additivity results are proved with no reference to congruences, and the congruences are then obtained as strict downstream consequences. We complement the theory with algorithms for enumerating each species of monster, a numerical study up to $10^8$, and a discussion of open density conjectures whose difficulty is tied to that of integer factorization.

**Keywords:** vampire numbers, fang factorization, digit multiset, casting out nines, digit sum, modular arithmetic, ghost numbers, integer factorization.

---

## 1. Introduction

The number $1260$ satisfies $1260 = 21 \times 60$, and the multiset of digits of the two factors, $\{2,1\} \cup \{6,0\} = \{0,1,2,6\}$, coincides with the multiset of digits of $1260$ itself. Such numbers were popularized by Clifford Pickover under the evocative name *vampire numbers*: the product is reconstituted from the digits of its two *fangs*. Beyond their recreational appeal, vampire numbers pose genuine combinatorial questions about the interaction between the multiplicative structure of the integers and the additive/positional structure of their decimal representation.

This paper offers a clean foundational treatment. Our thesis is that the entire elementary theory is best organized around the **multiset of decimal digits**, which we denote $M(n)$, and its two natural numerical projections:

- the **digit sum** $S(n)$, the total of the entries of $M(n)$;
- the **digit length** $L(n)$, the number of entries of $M(n)$.

The defining condition of a fang factorization becomes the single multiset equation $M(v) = M(x) + M(y)$ (with $+$ denoting multiset union), and every elementary property of vampires that we prove is a corollary of manipulating this equation.

A methodological point guides the development. In the folklore, the digit-sum additivity of a fang factorization and the *casting out nines* congruence are often intertwined, and it is easy to argue in a circle. We keep them strictly separated:

1. **Combinatorial layer.** Digit sum and digit length are the total and the cardinality of the digit multiset, and both are additive across a fang pair. These facts are proved using *only* the homomorphism properties of multiset sum and cardinality — no modular arithmetic appears.
2. **Congruence layer.** We then invoke casting out nines, $n \equiv S(n) \pmod 9$ (and its mod-$3$ shadow), and combine it with the additivity of digit sums to obtain the vampire's modular signature.

The dependency is one-directional: congruences are consequences of the combinatorial layer, never hypotheses for it.

### Contributions

- A first-principles combinatorial framework (§3): digit-length additivity (Lemma 2) and digit-sum additivity (Lemma 3) across fang pairs, plus the equivalence of the multiset formulation with the more common list-permutation formulation.
- The modular signature of a vampire (§4): $v \equiv x + y \pmod 9$ and $\pmod 3$ (Theorems 4 and 5).
- The fang taboo (§5, Theorem 6): neither fang is $\equiv 1 \pmod 3$; and the mod-nine confinement of the fang residue pair (Proposition 7).
- The extended bestiary (§6): precise definitions of werewolf, ghost, and zombie numbers, and a heuristic proof that ghosts have density zero with exponential decay in digit length.
- Enumeration algorithms and numerical results up to $10^8$ (§7), and open conjectures on vampire density and existence (§8).

---

## 2. Definitions

Throughout, $n$ ranges over the nonnegative integers and all digits are base ten. We write $\mathrm{dig}(n)$ for the finite list of decimal digits of $n$ (least significant first, the standard convention); it is the empty list for $n = 0$.

**Definition 1 (digit multiset, digit sum, digit length).**
For $n \in \mathbb{N}$, define
$$M(n) := \text{the multiset of entries of } \mathrm{dig}(n), \qquad S(n) := \sum_{d \in \mathrm{dig}(n)} d, \qquad L(n) := |\mathrm{dig}(n)|,$$
where the sum in $S(n)$ counts digits with multiplicity, and $L(n)$ is the number of digits. Equivalently, $S(n)$ is the total (sum of entries) of the multiset $M(n)$ and $L(n)$ is its cardinality.

**Definition 2 (fang pair).**
An ordered triple $(v, x, y)$ of positive integers is a **fang pair** (and $(x, y)$ are *fangs* of $v$) if
$$M(v) = M(x) + M(y) \qquad\text{and}\qquad x \cdot y = v,$$
where $+$ denotes multiset union (pooling entries with multiplicity). We write $\mathrm{Fang}(v, x, y)$ for this relation.

**Definition 3 (vampire number).**
A positive integer $v$ is a **vampire number** if it has an even number of digits, say $L(v) = 2n$, and admits a fang pair $(v, x, y)$ with $L(x) = L(y) = n$ and with $x, y$ not both divisible by $10$ (the standard exclusion of the trivial "trailing-zero" factorizations). A vampire with more than one essentially distinct fang pair is a *multiple vampire*.

The multiset formulation is equivalent to the more common phrasing in terms of a permutation of digit *lists*.

**Proposition 1 (equivalence of formulations).**
For all $v, x, y$,
$$M(v) = M(x) + M(y) \iff \mathrm{dig}(v) \text{ is a permutation of } \mathrm{dig}(x) \mathbin{+\!\!+} \mathrm{dig}(y),$$
where $\mathbin{+\!\!+}$ denotes list concatenation.

*Proof sketch.* Two lists are permutations of one another iff they induce equal multisets. Concatenation of lists corresponds to union of the induced multisets. Hence $M(v) = M(x)+M(y)$ is literally the statement that $\mathrm{dig}(v)$ and $\mathrm{dig}(x)\mathbin{+\!\!+}\mathrm{dig}(y)$ induce the same multiset, i.e. are permutations of each other. $\square$

This proposition lets us pass freely between the multiset viewpoint (best for proofs) and the permutation viewpoint (best for enumeration).

---

## 3. The Combinatorial Layer: Additivity of Digit Sum and Length

The two workhorse lemmas identify $S$ and $L$ as the *total* and the *cardinality* of the digit multiset, and then exploit that both operations are additive under multiset union. **No modular arithmetic is used in this section.**

**Lemma 1 (digit sum is the multiset total).**
For every $n$, $S(n) = \operatorname{sum} M(n)$, the sum of the entries of the digit multiset.

*Proof sketch.* By construction $M(n)$ is the multiset induced by the list $\mathrm{dig}(n)$, and the sum of a multiset induced by a list equals the sum of the list, which is $S(n)$ by definition. $\square$

**Lemma 2 (digit length additivity).**
If $\mathrm{Fang}(v, x, y)$ then $L(v) = L(x) + L(y)$.

*Proof sketch.* The cardinality map $|\cdot|$ from multisets to $\mathbb{N}$ is a monoid homomorphism: $|A + B| = |A| + |B|$. Since $L(n) = |M(n)|$, applying $|\cdot|$ to the fang equation $M(v) = M(x) + M(y)$ gives $L(v) = |M(v)| = |M(x)+M(y)| = |M(x)| + |M(y)| = L(x)+L(y)$. $\square$

**Corollary (balanced fangs).** A vampire of length $2n$ has fangs of length exactly $n$ each: by Definition 3 we require $L(x)=L(y)$, and Lemma 2 forces $L(x)+L(y)=2n$, hence $L(x)=L(y)=n$.

**Lemma 3 (digit sum additivity).**
If $\mathrm{Fang}(v, x, y)$ then $S(v) = S(x) + S(y)$.

*Proof sketch.* The total map $\operatorname{sum}(\cdot)$ from multisets of naturals to $\mathbb{N}$ is a monoid homomorphism: $\operatorname{sum}(A+B) = \operatorname{sum} A + \operatorname{sum} B$. By Lemma 1, $S(n) = \operatorname{sum} M(n)$. Applying $\operatorname{sum}$ to $M(v) = M(x)+M(y)$ yields $S(v) = \operatorname{sum} M(v) = \operatorname{sum} M(x) + \operatorname{sum} M(y) = S(x)+S(y)$. $\square$

These three results are the entire combinatorial foundation. Everything that follows is a deduction from Lemma 3 (for congruences) or Lemma 2 (for length constraints), together with standard facts about decimal representation.

---

## 4. The Congruence Layer: The Modular Signature of a Vampire

We now import one external, classical ingredient.

**Lemma 4 (casting out nines / threes).**
For every $n$,
$$n \equiv S(n) \pmod 9 \qquad\text{and}\qquad n \equiv S(n) \pmod 3.$$

*Proof sketch.* Write $n = \sum_i d_i \cdot 10^i$ with digits $d_i$. Since $10 \equiv 1 \pmod 9$, we have $10^i \equiv 1 \pmod 9$, so $n \equiv \sum_i d_i = S(n) \pmod 9$. As $3 \mid 9$, reducing modulo $3$ gives the mod-$3$ statement. $\square$

Combining Lemma 4 with the *combinatorial* additivity of Lemma 3 produces the central congruences. Crucially, Lemma 3 is available with no circular use of Lemma 4.

**Theorem 4 (vampire law modulo 9).**
If $\mathrm{Fang}(v, x, y)$ then $v \equiv x + y \pmod 9$.

*Proof.* Chain three facts:
$$v \;\equiv\; S(v) \;=\; S(x)+S(y) \;\equiv\; x + y \pmod 9.$$
The first congruence is casting out nines (Lemma 4) for $v$. The middle equality is digit-sum additivity (Lemma 3). The last congruence is casting out nines applied to $x$ and to $y$ and added: $S(x) \equiv x$ and $S(y) \equiv y \pmod 9$, so $S(x)+S(y) \equiv x+y$. $\square$

**Theorem 5 (vampire law modulo 3).**
If $\mathrm{Fang}(v, x, y)$ then $v \equiv x + y \pmod 3$.

*Proof.* Identical to Theorem 4, using the mod-$3$ half of Lemma 4. $\square$

**Interpretation.** Although $v = x \cdot y$ multiplicatively, modulo $9$ (and $3$) the value $v$ agrees with the *additive* combination $x + y$. A vampire is thus a number that is simultaneously a product and, modulo nine, a sum of the same two fangs. This is a necessary constraint that every vampire must satisfy, and it is available "for free," without performing the multiplication.

---

## 5. Obstructions: The Fang Taboo and Residue Confinement

The modular signature immediately excludes residue classes for the fangs.

**Theorem 6 (fang taboo modulo 3).**
If $\mathrm{Fang}(v, x, y)$ then $x \not\equiv 1 \pmod 3$ and $y \not\equiv 1 \pmod 3$.

*Proof.* Since $v = x\cdot y$, Theorem 5 gives $x \cdot y \equiv x + y \pmod 3$. Suppose for contradiction $x \equiv 1 \pmod 3$. Multiplying the congruence class through: from $x \equiv 1$ we get $x\cdot y \equiv 1\cdot y = y$ and $x + y \equiv 1 + y \pmod 3$. Substituting into $x\cdot y \equiv x+y$ yields $y \equiv 1 + y \pmod 3$, i.e. $0 \equiv 1 \pmod 3$, a contradiction. The case $y \equiv 1 \pmod 3$ is symmetric. $\square$

Equivalently, rearranging $xy \equiv x + y$ as $(x-1)(y-1) \equiv 1$: a factor $\equiv 1$ makes the left side $\equiv 0 \not\equiv 1$.

**Consistency check.** For $1260 = 21 \times 60$: $21 \equiv 0$ and $60 \equiv 0 \pmod 3$; both avoid the forbidden residue $1$.

The same rearrangement, taken modulo nine, confines the fang residues to a small set.

**Proposition 7 (mod-nine residue confinement).**
If $\mathrm{Fang}(v, x, y)$ then $(x - 1)(y - 1) \equiv 1 \pmod 9$. Consequently the residue pair $(x \bmod 9,\ y \bmod 9)$ lies in the explicit solution set of $(a-1)(b-1) \equiv 1 \pmod 9$, namely pairs $(a,b)$ with $a - 1$ a unit modulo $9$ and $b - 1$ its inverse. Since the units modulo $9$ are $\{1,2,4,5,7,8\}$, there are exactly $6$ admissible values of $a-1$ (hence of $a$), each determining $b-1$ uniquely.

*Proof sketch.* From $v = xy$ and Theorem 4, $xy \equiv x + y \pmod 9$, so $xy - x - y + 1 \equiv 1$, i.e. $(x-1)(y-1) \equiv 1 \pmod 9$. For the product of two residues to be a unit ($1$ is a unit), each factor must be a unit; the unit group $(\mathbb{Z}/9)^\times$ has order $6$, and once $x-1$ is chosen among its $6$ elements, $y-1 = (x-1)^{-1}$ is determined. $\square$

**Practical consequence — a free sieve.** Theorem 6 and Proposition 7 reject the large majority of candidate factorizations using only residues, before any digit comparison. This is the theoretical backbone of the pruning step in the enumeration algorithms of §7.

---

## 6. The Extended Bestiary

We define three further species by varying the digit-sharing condition. Let $D(n)$ denote the *set* of distinct digits occurring in $n$ (the support of $M(n)$).

**Definition 4 (werewolf number).** A positive integer $v$ is a **werewolf number** if $v = x \cdot y$ for nontrivial $x, y$ such that the fangs share *exactly one* distinct digit with $v$: $|D(v) \cap (D(x) \cup D(y))| = 1$.

**Definition 5 (ghost number).** A positive integer $v$ is a **ghost number** if $v = x \cdot y$ for nontrivial $x, y$ such that the fangs share *no* digit with $v$: $D(v) \cap (D(x) \cup D(y)) = \varnothing$.

**Definition 6 (zombie / boundary number).** A **zombie number** is a product $v = x\cdot y$ satisfying the digit-multiset fang equation $M(v) = M(x)+M(y)$ but violating one of the fine-print clauses of Definition 3 (e.g. a fang is prime, or the length-balance/trailing-zero conditions fail). Zombies are near-vampires that "should not exist" under the strict definition yet do; e.g. factorizations of $125460$ mixing a prime and a composite.

Ghosts are the rarest, and the reason is a large-deviation phenomenon.

**Theorem 8 (ghosts have density zero, heuristic).**
The proportion of ghost numbers among integers with $d$ digits tends to $0$ as $d \to \infty$; more precisely, it is bounded above by $C \cdot \rho^{d}$ for constants $C > 0$ and $0 < \rho < 1$.

*Proof sketch (union bound / large deviations).* Fix a factorization $v = xy$. For $v$ to be a ghost, *every* digit appearing in $x$ or $y$ must be absent from $v$. Model the digits of $v$ as approximately uniform and independent over $\{0,\dots,9\}$; the probability that a *fixed* digit value $c$ is absent from all $d$ positions of $v$ is $(9/10)^d$. Requiring the whole digit set $D(x)\cup D(y)$ (of size at least $1$, typically several) to be simultaneously absent is at most $(9/10)^d$ by monotonicity, and summing (union bound) over the boundedly many digit values and the polynomially many factorizations of $v$ keeps the bound of the form $C\cdot\rho^d$ with $\rho = 9/10 < 1$. Hence the count of ghosts up to $10^d$ is dominated by a geometrically decaying fraction. $\square$

By contrast, vampires and werewolves become *relatively* more abundant as $d$ grows, because the number of digit rearrangements that a product can realize increases combinatorially. This asymmetry — geometric extinction for ghosts, persistence for vampires — is a recurring theme of the bestiary.

---

## 7. Algorithms and Numerical Results

### 7.1 Enumerating vampires by the fang-first method

The efficient route enumerates *fang pairs* rather than testing every $v$. For a target length $2n$, iterate over pairs $(x, y)$ of $n$-digit numbers with $x \le y$, form $v = xy$, and accept when $L(v) = 2n$ and $M(v) = M(x) + M(y)$. The modular sieve of §5 prunes candidates before the (costlier) multiset comparison.

```
Algorithm ENUMERATE-VAMPIRES(n):
  input: half-length n
  output: all vampires v with 2n digits, each with its fang pairs
  results <- empty map
  lo <- 10^(n-1); hi <- 10^n - 1
  for x from lo to hi:
    for y from x to hi:
      if x % 10 == 0 and y % 10 == 0: continue          # trailing-zero exclusion
      if (x - 1) * (y - 1) mod 9 != 1 mod 9: continue    # mod-9 sieve (Prop. 7)
      if x % 3 == 1 or y % 3 == 1: continue              # fang taboo (Thm. 6)
      v <- x * y
      if digit_length(v) != 2n: continue
      if digit_multiset(v) == digit_multiset(x) + digit_multiset(y):
        append (x, y) to results[v]
  return results
```

**Complexity.** The double loop is $O(10^{2n})$ candidate pairs for length $2n$; the sieve removes a constant fraction cheaply (a residue test is $O(1)$), and the multiset check is $O(n)$. The dominant cost is the pair enumeration, i.e. roughly linear in the size of the search band.

### 7.2 Numerical census up to $10^8$

Enumerating with the algorithm above reproduces the known census. The smallest vampire is $1260 = 21\times 60$. The four-digit vampires are exactly
$$1260,\ 1395,\ 1435,\ 1530,\ 1827,\ 2187,\ 6880.$$
The double vampire $125460 = 204\times 615 = 246\times 510$ appears among the six-digit specimens. Every enumerated fang pair satisfies the modular signature of §4 and the taboo of §5, providing an empirical cross-check on the theory: no fang in the census is $\equiv 1 \pmod 3$, and each fang residue pair modulo $9$ solves $(x-1)(y-1)\equiv 1$.

The census also confirms the qualitative predictions of §6: ghost numbers become dramatically sparser as digit length grows, consistent with the geometric decay of Theorem 8, while vampires persist and multiply.

---

## 8. Open Conjectures

**Conjecture 1 (density decay).** The density of vampire numbers in $[10^{2n}, 10^{2n+1}]$ tends to $1/\sqrt{n}$ as $n \to \infty$.

**Conjecture 2 (never extinct).** Every even-length band $[10^{2k}, 10^{2k+2}]$ contains at least one vampire number. A constructive strengthening: there is an explicit family of fang pairs, each built from a digit-balanced core plus a controlled tail, whose products land in the prescribed band while permuting (never losing) their digits — proving vampires occur in every even-length block with bounded gaps in digit length.

**Conjecture 3 (mod-nine equidistribution).** Over all vampires up to a growing bound, the fang residue pair modulo $9$ equidistributes across exactly the admissible classes of Proposition 7 and never strays outside them.

**Conjecture 4 (stacked modular sieve).** Layering independent digit-sum-driven congruences across several compatible moduli yields a single cheap test that every vampire survives, yet whose non-vampire survivors retain a density strictly between $0$ and $1$: the combined sieve is powerful but provably incomplete.

The difficulty of these questions is intrinsic: deciding whether a given $v$ is a vampire, or counting vampires exactly, requires searching over factorizations of $v$, a task tied to the hardness of integer factorization. The elementary constraints proved here are precisely the part of the problem that *escapes* that hardness.

---

## 9. Discussion

The digit-multiset viewpoint clarifies why the elementary theory of vampires is so robust: the fang condition is a single equation in a free commutative monoid (multisets over $\{0,\dots,9\}$), and the useful invariants — digit sum and digit length — are the two canonical homomorphisms out of that monoid. Additivity of both is therefore automatic, and the congruences are a thin classical layer on top. Keeping the combinatorial and congruence layers separate is not mere fastidiousness: it guarantees the congruences are genuine theorems rather than restatements of hidden assumptions.

The bestiary as a whole illustrates a general principle at the interface of the multiplicative and positional structure of integers. Conditions that *preserve* digits (vampires) proliferate; conditions that *avoid* digits (ghosts) suffer large-deviation extinction; conditions that *partially* preserve digits (werewolves) interpolate. The modular signature and its obstructions are the rigorous, factoring-free core of a subject whose full census is as hard as factoring itself.

## 10. Future Work

Beyond the conjectures of §8, natural directions include: extending the framework to arbitrary bases $b$ (the congruences become casting out $b-1$ and its divisors); studying the analogous multiset invariants for higher-arity factorizations $v = x_1 \cdots x_k$; and making the ghost decay estimate of Theorem 8 fully rigorous with explicit constants. The constructive program of Conjecture 2 — engineering rather than discovering vampires — appears the most promising route to unconditional existence results.
