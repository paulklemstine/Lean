# A Non-Circular Subgroup-Index Telescope and the Multiplicativity of Group Order over Composition Factors

**Author:** Aristotle
**Date:** 2026-06-21
**Domain:** Algebra (group theory / foundations for Jordan–Hölder)

## Abstract

We present and formally verify an elementary "telescope" identity for the relative
indices of a finite monotone chain of subgroups of a group $G$. For a chain
$H_0 \le H_1 \le \cdots \le H_n$, the product of the adjacent relative indices
$[H_{i+1}:H_i]$ collapses to the single relative index $[H_n:H_0]$, and — when the chain
is anchored at the trivial and full subgroups — to the order $\lvert G\rvert$ of the group.
We package the identity in five mutually reinforcing forms: a pure relative-index version,
an index-with-tail version, a cardinality version valid even in the infinite case, and two
endpoint specializations. The development is **deliberately non-circular**: it uses no
Jordan–Hölder machinery and no lattice instance, relying only on multiplicativity of the
subgroup index. As an immediate corollary we obtain the *composition-factor mass law*: the
order of a finite group is the product of the orders of its composition factors, whence two
finite groups with the same multiset of composition factors necessarily have equal order —
the precise sense in which finite groups have **no isotopes**. We discuss the role of the
telescope as a reusable foundation for Schreier refinement, a numerical Jordan–Hölder
skeleton, and module-length analogues, and we provide algorithms and numerical
demonstrations.

## 1. Introduction

The classification of finite groups by their composition factors invites a chemical
analogy: composition factors play the role of atoms, a group's order plays the role of
atomic mass, and the Jordan–Hölder theorem plays the role of a conservation law fixing the
list of constituents. The analogy is fertile but breaks at exactly one place. In chemistry,
atomic number (which species) and atomic mass (which isotope) are independent: carbon-12 and
carbon-14 share a chemistry but differ in mass. In group theory, by contrast, mass is *not*
independent of the constituent list. There are **no isotopes**: the order of a finite group
is wholly determined by its multiset of composition factors.

The arithmetic engine behind this rigidity is a single, elementary identity about how
subgroup indices behave along a chain. This paper isolates that identity — the
**subgroup-index telescope** — proves it in full generality, and records the corollaries
that make the "no isotopes" phenomenon precise.

A guiding design principle is **non-circularity**. The telescope is intended to be a
foundational layer beneath a future formalization of the Jordan–Hölder theorem. We
therefore prove it using *only* multiplicativity of the index — `relIndex_mul_relIndex`,
`relIndex_mul_index`, and `card_mul_index` in the standard library — and no Jordan–Hölder
theorem, no composition-series API, and no lattice instance. The sole induction is the
structural induction on chain length, which recurses only on strictly shorter chains.

## 1.1 Background: composition series and the chemical analogy

A finite group $G$ is built from simpler pieces by iterated extension. A **subnormal series**
is a chain $\bot = H_0 \lhd H_1 \lhd \cdots \lhd H_n = \top$ in which each $H_i$ is normal in
$H_{i+1}$ (but not necessarily in $G$); the quotients $H_{i+1}/H_i$ are its **factors**. A
series is a **composition series** when it cannot be refined further without repetition,
equivalently when every factor is a **simple group** — one with no nontrivial proper normal
subgroup. Simple groups are the "atoms": by the classification of finite simple groups they
comprise the cyclic groups of prime order, the alternating groups $A_n$ for $n \ge 5$, the
groups of Lie type, and $26$ sporadic groups.

The **Jordan–Hölder theorem** asserts that, although a finite group may admit many composition
series, the multiset of composition factors (up to isomorphism) is an invariant of the group.
This is the conservation law underwriting the chemical analogy: composition factors are atoms,
the factor multiset is the molecular formula, and the order is the mass. The analogy is
productive — solvable groups (all factors abelian) behave like one class of substances,
groups with a nonabelian simple factor like another — but it has one decisive disanalogy,
isolated here: unlike atomic mass and atomic number, a group's mass is *not* an independent
degree of freedom. The telescope makes the dependence exact. The present paper does **not**
prove Jordan–Hölder; it proves the multiplicative numerical invariant on which the theorem's
mass-law corollary rests, in a form that could later serve as a lemma in a full
Jordan–Hölder formalization without circularity.

## 2. Preliminaries and Definitions

Throughout, $G$ is a group (finiteness is *not* assumed unless stated). We write subgroups
$H \le G$ and use the following standard notions.

**Definition 2.1 (Index).** For $H \le G$, the *index* $[G:H]$, denoted `Subgroup.index`,
is the number of left cosets of $H$ in $G$ (a natural number, taken to be $0$ when the
index is infinite).

**Definition 2.2 (Relative index).** For $K \le H \le G$, the *relative index* $[H:K]$,
denoted `Subgroup.relIndex K H`, is the index of $K$ regarded inside $H$. Concretely it is
the index of the *induced subgroup* $K \cap H$ pushed into $H$ (the `subgroupOf`
construction): $[H:K] = \big(K.\mathrm{subgroupOf}\,H\big).\mathrm{index}$.

**Definition 2.3 (Monotone chain).** A *monotone chain* of length $n$ is a function
$H : \mathrm{Fin}(n+1) \to \mathrm{Subgroup}\,G$ that is monotone, i.e.
$H_i \le H_j$ whenever $i \le j$. Equivalently (by `Fin.monotone_iff_le_succ`), it suffices
that $H_{i} \le H_{i+1}$ for every adjacent pair, i.e. $H(i.\mathrm{castSucc}) \le
H(i.\mathrm{succ})$ for all $i : \mathrm{Fin}\,n$.

We use three classical multiplicativity laws as black boxes:

- **(M1) Relative-index multiplicativity** (`relIndex_mul_relIndex`): for
  $K \le H \le L$, $[L:K] = [L:H]\cdot[H:K]$, i.e.
  $\mathrm{relIndex}(K,H)\cdot\mathrm{relIndex}(H,L) = \mathrm{relIndex}(K,L)$.
- **(M2) Index–relative-index multiplicativity** (`relIndex_mul_index`): for $K \le H$,
  $[H:K]\cdot[G:H] = [G:K]$.
- **(M3) Lagrange in cardinality form** (`card_mul_index`): for any $H \le G$,
  $\lvert H\rvert \cdot [G:H] = \lvert G\rvert$.

## 3. Main Results

### 3.1 The core telescope

**Theorem 3.1 (`relIndex_prod_telescope`).** *Let $H : \mathrm{Fin}(n+1) \to
\mathrm{Subgroup}\,G$ be a monotone chain. Then*
$$\prod_{i \in \mathrm{Fin}\,n}\,[\,H_{i+1} : H_i\,] \;=\; [\,H_n : H_0\,],$$
*where $H_n = H(\mathrm{Fin.last}\,n)$ and each factor is
$\mathrm{relIndex}(H(i.\mathrm{castSucc}),\,H(i.\mathrm{succ}))$.*

*Proof sketch.* Induct on $n$.

- **Base case $n=0$.** The product over the empty index type $\mathrm{Fin}\,0$ is $1$, and
  $[H_0:H_0] = 1$, so both sides agree. (Here $\mathrm{Fin.last}\,0 = 0$.)
- **Inductive step $n \mapsto n+1$.** Apply the inductive hypothesis to the truncated chain
  $H' := H \circ \mathrm{Fin.castSucc}$ of length $n$, which is monotone because $H$ is.
  This yields $\prod_{i\in\mathrm{Fin}\,n}[H'_{i+1}:H'_i] = [H_n:H_0]$. Split the
  length-$(n+1)$ product using `Fin.prod_univ_castSucc`, which peels off the last factor
  $[H_{n+1}:H_n]$:
  $$\prod_{i\in\mathrm{Fin}(n+1)}[H_{i+1}:H_i]
    = \Big(\prod_{i\in\mathrm{Fin}\,n}[H_{i+1}:H_i]\Big)\cdot[H_{n+1}:H_n]
    = [H_n:H_0]\cdot[H_{n+1}:H_n].$$
  Finally glue the two adjacent relative indices with (M1) applied to the inclusions
  $H_0 \le H_n \le H_{n+1}$ (both valid by monotonicity, via $0 \le \mathrm{last}$ and
  $\mathrm{last} \le \mathrm{last}$), giving $[H_n:H_0]\cdot[H_{n+1}:H_n] = [H_{n+1}:H_0]$.
  $\qquad\blacksquare$

The proof recurses only on the strictly shorter chain $H'$ and invokes no Jordan–Hölder
content; this is the non-circularity guarantee.

### 3.2 The index telescope with a tail

**Theorem 3.2 (`index_prod_telescope`).** *If $H_{i} \le H_{i+1}$ for all
$i : \mathrm{Fin}\,n$, then*
$$\Big(\prod_{i\in\mathrm{Fin}\,n}[\,H_{i+1}:H_i\,]\Big)\cdot[\,G:H_n\,] = [\,G:H_0\,].$$

*Proof sketch.* The adjacent-step hypothesis upgrades to monotonicity via
`Fin.monotone_iff_le_succ`. Apply Theorem 3.1 to rewrite the product as $[H_n:H_0]$. Then
(M2), applied to $H_0 \le H_n$, gives $[H_n:H_0]\cdot[G:H_n] = [G:H_0]$. $\qquad\blacksquare$

### 3.3 The cardinality telescope

**Theorem 3.3 (`card_telescope`).** *Under the same adjacent-step hypothesis,*
$$\lvert H_n\rvert \;=\; \lvert H_0\rvert \cdot \prod_{i\in\mathrm{Fin}\,n}[\,H_{i+1}:H_i\,].$$
*This holds with no finiteness assumption; if $H_0$ is infinite both sides are $0$.*

*Proof sketch.* Let $H_0 \le H_n$ by monotonicity. Rewrite the product as $[H_n:H_0]$ by
Theorem 3.1. The relative index $[H_n:H_0]$ equals the index of $H_0$ viewed inside $H_n$
(the `subgroupOf` subgroup), and the canonical equivalence
`subgroupOfEquivOfLe` identifies $H_0$ with that induced subgroup, preserving cardinality.
Then (M3) applied inside the group $H_n$ gives
$\lvert H_0\rvert \cdot [H_n:H_0] = \lvert H_n\rvert$. $\qquad\blacksquare$

### 3.4 Endpoint specializations

**Theorem 3.4 (`prod_relIndex_eq_index_of_top`).** *If $H_i \le H_{i+1}$ for all $i$ and
$H_n = \top$ (the whole group), then*
$$\prod_{i\in\mathrm{Fin}\,n}[\,H_{i+1}:H_i\,] = [\,G:H_0\,].$$

*Proof sketch.* From Theorem 3.2 the product equals $[G:H_0]/[G:H_n]$ once we note
$[G:\top]=1$; concretely, substitute $H_n=\top$ so that $[G:H_n]=[G:\top]=1$ and the tail
factor disappears. $\qquad\blacksquare$

**Theorem 3.5 (`prod_relIndex_eq_card_of_bot_top`).** *If $H_i \le H_{i+1}$ for all $i$,
$H_0 = \bot$ (the trivial subgroup), and $H_n = \top$, then*
$$\prod_{i\in\mathrm{Fin}\,n}[\,H_{i+1}:H_i\,] = \lvert G\rvert.$$

*Proof sketch.* By Theorem 3.4 the product equals $[G:H_0] = [G:\bot]$, and
$[G:\bot] = \lvert G\rvert$ (`index_bot`). $\qquad\blacksquare$

## 4. Corollary: the composition-factor mass law ("no isotopes")

A **composition series** of a finite group $G$ is a maximal chain
$\bot = H_0 \lhd H_1 \lhd \cdots \lhd H_n = \top$ of normal steps whose successive quotients
$S_i := H_{i+1}/H_i$ are simple. These quotients are the **composition factors**, and the
Jordan–Hölder theorem asserts that the multiset $\{S_1,\dots,S_n\}$ is an invariant of $G$.

**Corollary 4.1 (Composition-factor mass law).** *For a finite group $G$ with composition
factors $S_1,\dots,S_n$,*
$$\lvert G\rvert = \prod_{i=1}^{n}\lvert S_i\rvert.$$

*Proof.* Each step quotient $S_i = H_{i+1}/H_i$ has order equal to the relative index
$[H_{i+1}:H_i]$ (a normal subgroup's quotient order is the index). Apply Theorem 3.5 to the
chain $\bot = H_0 \le \cdots \le H_n = \top$:
$\prod_i [H_{i+1}:H_i] = \lvert G\rvert$, i.e. $\prod_i \lvert S_i\rvert = \lvert
G\rvert$. $\qquad\blacksquare$

**Corollary 4.2 (No isotopes).** *Two finite groups with the same multiset of composition
factors have equal order.*

*Proof.* By Corollary 4.1 the order of each equals the product of the orders of its
composition factors; equal multisets of factors give equal products. $\qquad\blacksquare$

Corollary 4.2 is the precise statement that the chemical analogy admits no isotopes: a
finite group's "atomic mass" is a deterministic function of its "chemical formula."

## 5. Worked examples

We illustrate the telescope and its corollaries on three concrete chains; each is reproduced
computationally in the accompanying demonstrations.

### 5.1 The symmetric group $S_4$ (non-abelian)

$S_4$, the group of the $24$ permutations of four points, possesses the normal chain
$$\bot \;\le\; \langle(1\,2)(3\,4)\rangle \;\le\; V_4 \;\le\; A_4 \;\le\; S_4,$$
where $V_4 = \{e,(1\,2)(3\,4),(1\,3)(2\,4),(1\,4)(2\,3)\}$ is the Klein four-group and $A_4$
is the alternating group of even permutations. The successive orders are
$1,2,4,12,24$, so the relative indices are
$$[Z_2:\bot]=2,\quad [V_4:Z_2]=2,\quad [A_4:V_4]=3,\quad [S_4:A_4]=2.$$
Theorem 3.1 gives $\prod = 2\cdot 2\cdot 3\cdot 2 = 24$, and Theorem 3.5 confirms this equals
$\lvert S_4\rvert$. The composition factors are $\mathbb{Z}_2,\mathbb{Z}_2,\mathbb{Z}_3,
\mathbb{Z}_2$; by Corollary 4.1 their orders multiply back to $24$.

### 5.2 Cyclic groups $\mathbb{Z}_n$ (abelian)

For $\mathbb{Z}_n = \langle c\rangle$ a maximal flag of subgroups corresponds to a maximal
chain of divisors $1 \mid d_1 \mid \cdots \mid n$ obtained from the prime factorization of
$n$; the subgroup of order $d$ is $\langle c^{n/d}\rangle$. For $n=30$ the flag
$1 \le 2 \le 6 \le 30$ yields relative indices $2,3,5$ whose product is $30 = \lvert
\mathbb{Z}_{30}\rvert$, the prime factorization read off as composition factors
$\mathbb{Z}_2,\mathbb{Z}_3,\mathbb{Z}_5$. This is the cardinality telescope (Theorem 3.3)
specialized to $H_0=\bot$.

### 5.3 The simple group $A_5$ (atomic)

$A_5$, of order $60$, is the smallest non-abelian simple group: its only composition series is
$\bot \le A_5$, of length one, with the single relative index $[A_5:\bot]=60$. The telescope
degenerates to the trivial statement $60 = 60$. Here the "formula" is a single atom, the
analogue of a noble gas, and the mass law reads $\lvert A_5\rvert = 60$ with no further
decomposition possible.

## 6. Degenerate cases and conventions

The statements are robust under the natural boundary cases.

- **Empty chain ($n=0$).** The product over $\mathrm{Fin}\,0$ is the empty product $1$, and
  $\mathrm{Fin.last}\,0 = 0$, so Theorem 3.1 reads $1 = [H_0:H_0] = 1$. This is the base case
  of the induction and requires no hypotheses beyond well-formedness.
- **Equal endpoints.** If $H_0 = H_n$ (a chain that does not actually grow), every relative
  index is $1$ and the telescope reads $1 = 1$.
- **Infinite groups.** Mathlib's `index` and `Nat.card` return $0$ for infinite objects. The
  cardinality telescope (Theorem 3.3) is stated and proved with no finiteness hypothesis: if
  $H_0$ is infinite, both sides evaluate to $0$, and the identity still holds. This is why we
  separate the cardinality form from the index forms.
- **Reindexing.** The adjacent-step hypothesis $H(i.\mathrm{castSucc}) \le H(i.\mathrm{succ})$
  is equivalent (`Fin.monotone_iff_le_succ`) to full monotonicity, so callers may supply
  either; the index-form theorems take the lighter adjacent hypothesis for convenience.

## 7. Relation to Lagrange's theorem

The telescope can be read as an $n$-fold, chain-aware Lagrange theorem. Classical Lagrange
(M3) is the case $n=1$ with $H_0 = H$, $H_1 = G$: $\lvert H\rvert\cdot[G:H]=\lvert G\rvert$.
The content of Theorem 3.1 is that the obvious termwise cancellation
$$\frac{\lvert H_1\rvert}{\lvert H_0\rvert}\cdot\frac{\lvert H_2\rvert}{\lvert H_1\rvert}\cdots\frac{\lvert H_n\rvert}{\lvert H_{n-1}\rvert} = \frac{\lvert H_n\rvert}{\lvert H_0\rvert}$$
is *legitimate at the level of indices* — not merely as a heuristic division of cardinalities,
which would fail in the infinite setting — because each step is governed by the genuine
subgroup-index multiplicativity (M1), which holds for the relative `subgroupOf` construction
whether or not the ambient group is finite. Carrying the identity at the level of `index`
(rather than dividing cardinalities) is precisely what keeps the development valid in the
infinite case and free of side conditions.

## 8. Algorithms

The identities translate directly into verification and construction procedures over
explicit finite groups (represented, e.g., by permutations).

**Algorithm A (Telescope verification).** Given a finite chain of subgroups
$H_0 \le \cdots \le H_n$ presented as element sets, compute each relative index as the
quotient $\lvert H_{i+1}\rvert / \lvert H_i\rvert$, take the product, and check it equals
$\lvert H_n\rvert / \lvert H_0\rvert$. Complexity $O(n)$ arithmetic operations once the
orders are known; computing the orders dominates.

**Algorithm B (Composition series factorization).** Given a finite group $G$, build a chain
from $\bot$ to $\top$ by repeatedly inserting a maximal proper normal subgroup; the
successive index ratios are the orders of the composition factors. The telescope guarantees
their product is $\lvert G\rvert$, providing a built-in correctness check.

**Algorithm C (Isotope test).** Given two finite groups via their multisets of composition
factors, compare the multisets; if equal, Corollary 4.2 certifies equal order without
recomputing it — and conversely a difference in order certifies different factor multisets.

## 9. Applications and Significance

- **A non-circular foundation for Jordan–Hölder.** The telescope supplies the multiplicative
  invariant (`product of relative indices = |G|`) on which a numerical Jordan–Hölder skeleton
  can rest, with no risk of circular dependence on the very theorem being built.
- **Built-in correctness checks.** Any computational pipeline that produces a subgroup chain
  can validate it instantly by confirming the index product matches the order.
- **Conceptual clarification of an analogy.** The mass law pinpoints the single joint at
  which the group/atom analogy fails, and shows the failure is a theorem (mass is a function
  of formula), not a modeling artifact.

## 10. Discussion: non-circularity by design

**Formalization notes.** The development is fully machine-checked. The five theorems are the
named results `relIndex_prod_telescope`, `index_prod_telescope`, `card_telescope`,
`prod_relIndex_eq_index_of_top`, and `prod_relIndex_eq_card_of_bot_top`, in the namespace
`JordanHolder.IndexTelescope`. Chains are modelled as functions
$H : \mathrm{Fin}(n+1) \to \mathrm{Subgroup}\,G$ so the length $n$ is a first-class natural
number available for induction; monotonicity is `Monotone H` or, in the lighter forms, the
equivalent adjacent hypothesis via `Fin.monotone_iff_le_succ`. The relative index
$[H_{i+1}:H_i]$ is `Subgroup.relIndex`, definitionally the index of the induced subgroup
produced by `subgroupOf`. The proofs invoke only `Subgroup.relIndex_mul_relIndex` (M1),
`Subgroup.relIndex_mul_index` (M2), `Subgroup.card_mul_index` (M3),
`Subgroup.subgroupOfEquivOfLe`, `Subgroup.index_bot`, `Fin.prod_univ_castSucc`, and standard
`Fin` lemmas. The single induction recurses on the truncated chain
$H \circ \mathrm{Fin.castSucc}$, strictly shorter, guaranteeing termination.

We emphasize what the development deliberately does *not* use. There is no
`CompositionSeries.jordan_holder`, no theorem named `jordan_holder`, and no
`JordanHolderLattice` instance for subgroups. The only inputs are (M1)–(M3) and standard
finite-index combinatorics (`Fin.prod_univ_castSucc`, `Fin.monotone_iff_le_succ`,
`subgroupOfEquivOfLe`, `index_bot`). The single recursion is structural on chain length and
terminates because it recurses on a strictly shorter chain. This austerity is the feature,
not a limitation: a foundation that secretly used Jordan–Hölder could not soundly support a
later proof of Jordan–Hölder.

## 10.1 Related formalized machinery

The standard library already provides the abstract scaffolding around this result but not the
result itself in chain form. Multiplicativity of the subgroup index is available pointwise
(`relIndex_mul_relIndex`, `relIndex_mul_index`) and Lagrange in cardinality form
(`card_mul_index`); an abstract `JordanHolderLattice` interface exists for stating uniqueness
of composition factors in a general modular lattice. What has been missing is the
group-level, chain-indexed *cardinality* statement that ties a monotone subgroup chain's
relative indices to the group order. The telescope fills exactly this gap, and does so without
entangling itself in the lattice interface, so that it can be consumed either by a future
lattice-based Jordan–Hölder proof or by direct, elementary arguments about explicit groups.
The deliberate separation of the cardinality form (no finiteness hypothesis) from the
index forms mirrors the library's own split between `Nat.card` and `Subgroup.index`, easing
reuse in both finite and infinite settings.

## 11. Future Directions

**Schreier refinement without the lattice instance.** Formalize that any two finite subgroup
chains admit equivalent refinements, *without* a `JordanHolderLattice` instance, by
intersecting each chain with the terms of the other and tracking the relative indices of the
inserted steps, then applying the telescope termwise. The key insight is that the product of
relative indices is invariant under refinement precisely because each inserted intermediate
subgroup splits one factor $[H_{i+1}:H_i]$ into a product of two whose product is unchanged
— itself the telescope applied to a length-two subchain.

**A numerical Jordan–Hölder skeleton.** Prove that any two composition series of a finite
group yield the same multiset of relative indices. Equality of the *products* is immediate
from the telescope (both equal $\lvert G\rvert$), so the residual difficulty is promoting
"equal products" to "equal multisets" — a finite combinatorial/number-theoretic statement
detached from group structure.

**Module-length and abelian-category analogues.** The same telescope governs chains of
submodules of a finite-length module, with relative index replaced by the length of a
subquotient. Recasting the proof so that "index" is an abstract additive (or multiplicative)
invariant satisfying tower additivity would unify the group and module cases, since the
argument uses only additivity along a tower plus endpoint normalizations.

**Minimal faithful permutation degree.** Refine the qualitative Cayley embedding into a
quantitative "reactivity degree" $\mu(G)$, the least $n$ with $G \hookrightarrow S_n$,
graded by index data of core-free subgroups.

## 12. Conclusion

A single elementary identity — the collapse of a product of adjacent relative indices to a
single endpoint index — anchors the order of a finite group to the product of its
composition-factor orders. The consequence is sharp and slightly surprising: finite groups
have no isotopes. By proving the identity in a deliberately non-circular form, we provide a
reusable foundation for refinement theorems, a numerical Jordan–Hölder, and module-length
analogues, each reachable without rebuilding the arithmetic core.
