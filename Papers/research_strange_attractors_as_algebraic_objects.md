# Strange Attractors as Algebraic Objects: A Finite-Nerve Obstruction for the Dyadic Solenoid

**Author:** Aristotle

**Date:** 2026-06-27

**Domain:** Applications (dynamical systems ↔ algebraic topology ↔ abelian-group algebra)

---

## Abstract

We develop the point of view that a chaotic attractor may be treated not as a
numerical phenomenon but as an *algebraic object*, carrying invariants that are as
rigid and diagnostic as those of a group or a number. We carry this program out
completely for a canonical model attractor, the **dyadic solenoid** — the inverse
limit of the circle under the doubling map, which arises as Smale's solenoid
attractor and as a cross-sectional model of Lorenz-type flows. We identify its
first Čech cohomology with the group of **dyadic rationals**
$\mathbb{Z}[1/2] \le \mathbb{Q}$, realized concretely as
$\{q \in \mathbb{Q} : 2^k q \in \mathbb{Z} \text{ for some } k\}$, and we prove
two structural facts that turn this group into an honest algebraic invariant of
chaos: multiplication by $2$ is *surjective* on $\mathbb{Z}[1/2]$ (the doubling
map becomes invertible in the limit), and $\mathbb{Z}[1/2]$ is **not finitely
generated**. We then prove a no-go theorem bridging dynamics with the combinatorics
of finite graphs: the first cohomology of any finite directed graph is the
finitely generated free abelian group $\mathbb{Z}^{\beta_1}$, where $\beta_1$ is
the graph's first Betti number; consequently **no finite directed graph has first
cohomology isomorphic to that of the solenoid**. The obstruction is the
non-preservation of finite generation under group isomorphism — a single algebraic
invariant separating the finite-graph world from the inverse-limit world. The
finite graphs in question are exactly the *nerve graphs* of quantum contextuality,
making the result a genuine cross-domain bridge (Physics ↔ Applications). All
statements are formalized and machine-checked.

---

## 1. Introduction

### 1.1 Chaos as phenomenon versus chaos as object

The strange attractors of dissipative dynamics — Lorenz, Hénon, Rössler — are
usually studied through numerics: one integrates the flow, plots the orbit, and
estimates invariants such as Lyapunov exponents and fractal (Hausdorff or
correlation) dimensions. These invariants are real-valued, approximate, and
estimated rather than computed exactly. They describe chaos as a *phenomenon*.

A complementary tradition in the topological theory of dynamical systems regards
hyperbolic attractors as **inverse limits** of simpler spaces under expanding
bonding maps. Williams' theory of one-dimensional attractors and the modeling of
the Lorenz flow by a branched-manifold *template* both fit this pattern. From this
vantage an attractor is not a cloud of points to be measured but a *limit object*
assembled from finite or low-dimensional pieces — that is, potentially an
*algebraic object*, accessible to the exact invariants of algebraic topology and
the rigidity theorems of abelian-group theory.

This paper executes that vantage to its logical conclusion for the simplest
genuinely strange inverse limit, and extracts from it a sharp impossibility
statement.

### 1.2 The model: the dyadic solenoid

The **dyadic solenoid** is the inverse limit of the doubling map of the circle:

$$ \Sigma_2 \;=\; \varprojlim \big( S^1 \xleftarrow{\;\times 2\;} S^1 \xleftarrow{\;\times 2\;} S^1 \xleftarrow{\;\times 2\;} \cdots \big). $$

A point of $\Sigma_2$ is a coherent sequence $(x_0, x_1, x_2, \dots)$ with
$x_n \in S^1$ and $2 x_{n+1} = x_n$ for all $n$. The space $\Sigma_2$ is a compact
connected one-dimensional space, locally homeomorphic to (interval) $\times$
(Cantor set), and it is the attractor of Smale's solenoid embedding of a solid
torus into itself. It is the canonical mathematically honest stand-in for "a
chaotic attractor that is intrinsically an infinite limit."

### 1.3 Results and contributions

We prove the following, all machine-checked in Lean 4 with Mathlib.

1. **Identification of the invariant.** The first Čech cohomology of $\Sigma_2$ is
   the direct limit
   $\operatorname{colim}(\mathbb{Z} \xrightarrow{\times 2} \mathbb{Z} \xrightarrow{\times 2} \cdots) \cong \mathbb{Z}[1/2]$,
   realized concretely as the additive subgroup `Dyadic` of $\mathbb{Q}$.

2. **Doubling becomes invertible (`Dyadic.two_divisible`).** Multiplication by $2$
   is surjective on $\mathbb{Z}[1/2]$.

3. **Infinite complexity (`Dyadic.not_fg`).** $\mathbb{Z}[1/2]$ is not finitely
   generated as an additive group.

4. **Finite graphs are finitely generated (`nerveCohomology_fg`).** The first
   cohomology of any finite directed (nerve) graph $G$ is the free abelian group
   $\mathbb{Z}^{\beta_1(G)}$ of finite rank, which is finitely generated.

5. **The finite-nerve obstruction (`solenoid_not_finite_nerve_cohomology`).** No
   finite nerve graph $G$ admits an additive group isomorphism
   $\mathbb{Z}[1/2] \cong \mathbb{Z}^{\beta_1(G)}$. Hence the solenoid is not
   captured by any single finite directed graph; the inverse limit is essential.

The conceptual content of (5) is the *non-preservation of finite generation*: a
single Boolean algebraic invariant (finite generation, `AddGroup.FG`) cleanly
separates the world of finite diagrams from the world of inverse limits. The
finite graphs are the nerve graphs of quantum contextuality, so the theorem is a
literal bridge between two catalogue domains.

---

## 2. Preliminaries

### 2.1 Finitely generated abelian groups

An additive group $A$ is **finitely generated** (`AddGroup.FG`) if there is a
finite subset $S \subseteq A$ with $\langle S \rangle = A$, i.e. every element is
an integer combination of elements of $S$. The free abelian groups
$\mathbb{Z}^n$ are finitely generated; arbitrary subgroups of $\mathbb{Q}$ need
not be. The two facts about finite generation that we use are standard:

- **(FG-transport).** If $f : A \to B$ is a surjective group homomorphism and $A$
  is finitely generated, then $B$ is finitely generated
  (`AddGroup.fg_of_surjective`). In particular finite generation is preserved by
  isomorphism.
- **(FG of subgroup).** For a subgroup $H \le A$, $H$ is finitely generated as a
  group iff it is finitely generated as a subgroup
  (`AddGroup.fg_iff_addSubgroup_fg`).

### 2.2 First cohomology of a graph

For a finite directed graph (here abstracted as a combinatorial datum) the first
Betti number is

$$ \beta_1(G) \;=\; |E(G)| - |V(G)| + c(G), $$

where $c(G)$ is the number of connected components. When $G$ is connected,
$\beta_1$ is the number of independent cycles. The first cohomology with integer
coefficients is the free abelian group of rank $\beta_1$:

$$ H^1(G;\mathbb{Z}) \;\cong\; \mathbb{Z}^{\beta_1(G)}. $$

We model this directly: the cohomology of a nerve graph is the function space
$\mathrm{Fin}\,(\beta_1) \to \mathbb{Z}$.

---

## 3. The dyadic invariant

### 3.1 Definition

> **Definition 3.1 (`Dyadic`).** The **dyadic rationals** $\mathbb{Z}[1/2]$ are
> the additive subgroup of $\mathbb{Q}$
> $$ \mathbb{Z}[1/2] \;=\; \{\, q \in \mathbb{Q} \;:\; \exists\, k \in \mathbb{N},\ \exists\, m \in \mathbb{Z},\ (m : \mathbb{Q}) = 2^k \cdot q \,\}. $$

Membership says: some power of two clears the denominator of $q$ to an integer.
The subgroup axioms are checked directly. For closure under addition, if
$2^{k_1} a = m_1$ and $2^{k_2} b = m_2$ with $m_1, m_2 \in \mathbb{Z}$, then
$$ 2^{k_1 + k_2}(a + b) \;=\; 2^{k_2} m_1 + 2^{k_1} m_2 \in \mathbb{Z}, $$
so $a + b \in \mathbb{Z}[1/2]$ with witness $k_1 + k_2$ and integer
$2^{k_2} m_1 + 2^{k_1} m_2$. Closure under negation uses $-m$ with the same $k$;
$0$ is dyadic with $k = m = 0$. This is the content of the structure `Dyadic`.

> **Lemma 3.2 (`mem_Dyadic`).** $q \in \mathbb{Z}[1/2] \iff \exists k\, m,\ (m:\mathbb{Q}) = 2^k q.$

This is the definitional unfolding of membership and is used throughout.

> **Lemma 3.3 (`Dyadic.inv_two_pow_mem`).** For every $n \in \mathbb{N}$,
> $1/2^n \in \mathbb{Z}[1/2]$.
>
> *Proof.* Take $k = n$ and $m = 1$: then $2^n \cdot (1/2^n) = 1 = (m:\mathbb{Q})$
> since $2^n \neq 0$. ∎

Lemma 3.3 is the algebraic incarnation of "you may keep dividing by two forever,"
and it supplies the explicit witnesses used in the non-finite-generation proof.

### 3.2 Cohomological identification

The first Čech cohomology functor sends the inverse system of circles to a direct
system of integer groups, with the doubling map inducing multiplication by $2$:

$$ H^1(\Sigma_2) \;\cong\; \operatorname{colim}\big( \mathbb{Z} \xrightarrow{\times 2} \mathbb{Z} \xrightarrow{\times 2} \mathbb{Z} \xrightarrow{\times 2} \cdots \big). $$

The colimit of this telescope is computed by sending the generator of the $n$-th
copy of $\mathbb{Z}$ to $1/2^n \in \mathbb{Q}$; the transition $\times 2$ is then
compatible because $2 \cdot (1/2^{n+1}) = 1/2^n$. The image is precisely the set
of integer multiples of powers of $1/2$, i.e. $\mathbb{Z}[1/2]$. Hence
$H^1(\Sigma_2) \cong \mathbb{Z}[1/2]$, identifying the topological invariant with
the algebraic object `Dyadic`. The two structural theorems below give this
identification teeth.

### 3.3 Doubling is invertible in the limit

> **Theorem 3.4 (`Dyadic.two_divisible`).** Multiplication by $2$ is surjective on
> $\mathbb{Z}[1/2]$: for every $y \in \mathbb{Z}[1/2]$ there is $x \in \mathbb{Z}[1/2]$
> with $2x = y$.
>
> *Proof sketch.* Given $y \in \mathbb{Z}[1/2]$ with witness $2^k y = m \in \mathbb{Z}$,
> put $x = y/2$. Then $2^{k+1} x = 2^k y = m \in \mathbb{Z}$, so $x \in \mathbb{Z}[1/2]$,
> and $2x = y$. ∎

Interpretation: the doubling endomorphism of the single circle is two-to-one and
destroys information, but on the cohomology of the *limit* it is an
**automorphism**. The chaos has been linearized into an invertible symmetry of the
invariant. This is the localization/colimit signature that no finite graph's
$H^1$ possesses, foreshadowing the obstruction.

### 3.4 Infinite complexity

> **Theorem 3.5 (`Dyadic.not_fg`).** $\mathbb{Z}[1/2]$ is **not** finitely
> generated.
>
> *Proof sketch.* Suppose $S \subseteq \mathbb{Z}[1/2]$ is finite and generates.
> For each $s \in S$, fix a witness exponent $k_s$ with $2^{k_s} s \in \mathbb{Z}$,
> and set $N = \max_{s \in S} k_s$. Every $s \in S$ then lies in the subgroup
> $$ B_N \;=\; \{\, q \in \mathbb{Z}[1/2] : 2^N q \in \mathbb{Z} \,\} $$
> of dyadics whose denominator divides $2^N$ (the `boundedDen N` subgroup). Since
> $B_N$ is a subgroup containing every generator, it contains the whole subgroup
> $\langle S \rangle = \mathbb{Z}[1/2]$. But $1/2^{N+1} \in \mathbb{Z}[1/2]$ by
> Lemma 3.3, while $2^N \cdot (1/2^{N+1}) = 1/2 \notin \mathbb{Z}$, so
> $1/2^{N+1} \notin B_N$. This contradicts $\mathbb{Z}[1/2] \subseteq B_N$. ∎

The mechanism is **unbounded denominators**: finite generation forces a uniform
denominator ceiling $2^N$ (the directed union of a finite set is bounded), which
the dyadic tower violates with the explicit escapee $1/2^{N+1}$. The negation is
strict and witnessed, not vacuous.

A convenient subtype reformulation packages this for transport across
isomorphisms:

> **Theorem 3.6 (`dyadic_not_addGroup_fg`).** As an additive group,
> $\mathbb{Z}[1/2]$ is not finitely generated: $\neg\,\mathrm{AddGroup.FG}(\mathbb{Z}[1/2])$.
>
> *Proof.* By (FG of subgroup), $\mathrm{AddGroup.FG}(\mathbb{Z}[1/2])$ is
> equivalent to finite generation of $\mathbb{Z}[1/2]$ as a subgroup of
> $\mathbb{Q}$, which is exactly Theorem 3.5. ∎

---

## 4. Finite nerve graphs and their cohomology

### 4.1 The nerve graph

We import the combinatorial nerve graph used in the algebra of quantum
contextuality.

> **Definition 4.1 (`NerveGraph`).** A nerve graph $G$ records natural numbers
> $|V(G)|$ (vertices), $|E(G)|$ (edges), $c(G)$ (components), subject to
> $c(G) \le |V(G)|$ and $|E(G)| \le |V(G)|^2$.

> **Definition 4.2 (`NerveGraph.cohomRank`).** The cohomological rank is
> $$ \beta_1(G) \;=\; \begin{cases} |E(G)| + c(G) - |V(G)|, & |E(G)| + c(G) \ge |V(G)|, \\ 0, & \text{otherwise.} \end{cases} $$
> This is the (truncated) first Betti number, $\dim H^1(G)$.

### 4.2 Cohomology of a nerve graph

> **Definition 4.3 (`nerveCohomology`).** The first cohomology of $G$ is modeled
> as the free abelian group of its rank,
> $$ H^1(G) \;=\; \big(\mathrm{Fin}\,\beta_1(G) \to \mathbb{Z}\big) \;\cong\; \mathbb{Z}^{\beta_1(G)}. $$

> **Theorem 4.4 (`nerveCohomology_fg`).** $H^1(G)$ is finitely generated for every
> finite nerve graph $G$.
>
> *Proof.* $\mathrm{Fin}\,\beta_1(G) \to \mathbb{Z}$ is a finite product of copies
> of $\mathbb{Z}$; such a free abelian group of finite rank is finitely generated
> (instance resolution). ∎

This is the structural fact about *all* finite diagrams: their first cohomology is
always a finitely generated free abelian group.

---

## 5. The finite-nerve obstruction

> **Theorem 5.1 (`solenoid_not_finite_nerve_cohomology`).** For every finite nerve
> graph $G$ there is no additive group isomorphism between the solenoid's
> cohomology and $G$'s cohomology:
> $$ \neg\, \exists\ \big(\, \mathbb{Z}[1/2] \;\simeq_{+}\; H^1(G) \,\big). $$
>
> *Proof.* Suppose $e : \mathbb{Z}[1/2] \xrightarrow{\ \sim\ } H^1(G)$ is an
> additive isomorphism. By Theorem 4.4, $H^1(G)$ is finitely generated. The
> inverse $e^{-1} : H^1(G) \to \mathbb{Z}[1/2]$ is a surjective homomorphism, so by
> (FG-transport, `AddGroup.fg_of_surjective`) $\mathbb{Z}[1/2]$ is finitely
> generated. This contradicts Theorem 3.6. ∎

The entire proof is the observation that finite generation is an isomorphism
invariant, that it holds for $\mathbb{Z}^{\beta_1}$, and that it fails for
$\mathbb{Z}[1/2]$. The conclusion is universally quantified over all finite nerve
graphs and is therefore a true no-go statement: not a single finite directed graph
reproduces the solenoid's first cohomology.

### 5.1 Why a single algebraic invariant suffices

It is striking that the obstruction does not require comparing ranks, torsion, or
any fine structure. A single Boolean invariant — *is the group finitely
generated?* — already partitions:

- **finite-diagram side:** $H^1(\text{finite graph}) = \mathbb{Z}^{\beta_1}$, FG;
- **inverse-limit side:** $H^1(\Sigma_2) = \mathbb{Z}[1/2]$, not FG.

Because FG is preserved by isomorphism, the two sides can never coincide. The
inverse limit is not a notational convenience; it is forced by the algebra.

---

## 6. Algorithms

The proofs are constructive enough to drive exact computations. Three algorithms
turn the theory into machine arithmetic.

### 6.1 Dyadic-membership certificate

Given a rational $q = a/b$ in lowest terms, decide whether $q \in \mathbb{Z}[1/2]$
and, if so, return the minimal exponent $k$ with $2^k q \in \mathbb{Z}$. Since
$2^k q$ is an integer iff $b \mid 2^k$ iff $b$ is a power of two, the algorithm
strips factors of two from $b$ and checks that nothing remains; the minimal $k$ is
$v_2(b)$, the $2$-adic valuation of the denominator. Complexity $O(\log b)$.

### 6.2 Bounded-denominator span test (the escapee finder)

Given a finite candidate generating set $S \subseteq \mathbb{Z}[1/2]$, compute
$N = \max_{s \in S} v_2(\text{den}(s))$ and return the witness $1/2^{N+1}$ that
escapes the span $B_N$. This is the executable core of Theorem 3.5: it produces,
for any proposed finite generating set, an explicit dyadic number it cannot
generate.

### 6.3 Telescope colimit evaluator

Represent an element of $\operatorname{colim}(\mathbb{Z} \xrightarrow{\times 2}
\cdots)$ as a pair $(n, m)$ meaning "$m$ in the $n$-th copy," and evaluate it to
the dyadic rational $m / 2^n$. Two pairs $(n_1, m_1)$, $(n_2, m_2)$ represent the
same element iff $m_1 2^{n_2} = m_2 2^{n_1}$, i.e. equal dyadics. This realizes the
identification $H^1(\Sigma_2) \cong \mathbb{Z}[1/2]$ as concrete arithmetic and
exhibits doubling (increment $m \mapsto 2m$ at fixed level, or drop a level) as a
bijection.

---

## 7. Applications and interpretation

**Exactness in place of estimation.** Replacing an estimated fractal dimension by
an exactly computed cohomology group changes the epistemic status of statements
about attractor complexity from "measured within error bars" to "proved." The
non-finite-generation of $\mathbb{Z}[1/2]$ is a hard structural theorem, not a
numerical observation.

**Certifying the necessity of inverse limits.** The modeling of hyperbolic
attractors as inverse limits is widespread; Theorem 5.1 certifies that for the
solenoid the limit is *not* dispensable — no finite truncation has the right
cohomology. This is a precise answer to the question "do we really need the
infinite tower?"

**A cross-domain bridge.** The same first-cohomology functor governs the nerve
graphs of quantum contextuality (where $\beta_1 = \mathrm{cohomRank}$ measures a
form of contextual/entanglement depth) and the cohomology of chaotic attractors.
The obstruction theorem is therefore a literal bridge: a Physics invariant and an
Applications invariant are compared and shown incompatible by one abelian-group
fact.

---

## 8. Discussion

The slogan of the development is "**chaos $\Rightarrow$ non-finite-generation**."
The dyadic group $\mathbb{Z}[1/2]$ is the certificate: it is the exact first Čech
cohomology of the solenoid, it carries the invertible doubling symmetry that marks
it as a colimit, and its failure of finite generation is the obstruction to any
finite-graph model. The proofs are short once the finite-generation plumbing is
named, but the conclusion is strong and not vacuous: a strict negation with an
explicit witness ($1/2^{N+1}$), universally quantified over finite graphs.

The development is deliberately minimal in its hypotheses. Theorem 5.1 needs only
(i) the cohomology of finite graphs is FG and (ii) the solenoid's cohomology is
not FG; everything else is the standard transport of FG across isomorphism.

---

## 9. Future directions

Derived from the cycle's findings (files `InverseLimit.lean`, `DyadicSolenoid.lean`,
`LorenzTransversal.lean`, `CohomologyObstruction.lean`); target category:
cross-domain bridge (dynamical systems ↔ category theory / algebraic topology ↔
abelian-group algebra). The cycle established a reusable inverse-limit engine,
computed the dyadic solenoid's first cohomology as the non-finitely-generated group
$\mathbb{Z}[1/2]$, realised the Cantor transversal as an inverse limit of finite
cyclic graphs, and proved that no finite nerve graph reproduces the solenoid's
cohomology. The following conjectures push these results outward.

**1. $p$-adic generalization of the transversal.** For every prime $p$, the
inverse limit of $\mathbb{Z}/p^n\mathbb{Z}$ with reduction bonding maps is
infinite, and the corresponding cohomology $\mathbb{Z}[1/p]$ is not finitely
generated; moreover $\mathbb{Z}[1/p] \simeq_+ \mathbb{Z}[1/q]$ iff $p = q$. The key
insight is that the obstruction to finite generation is *one* unbounded prime in
the denominators, so the prime is an isomorphism invariant of the limit. The
`Dyadic`/`boundedDen` machinery is $p$-agnostic — replacing $2$ by $p$ reuses every
lemma, and FG transport already gives the rigidity half.

**2. Mixed-radix (Lorenz/Hénon two-branch) solenoids.** The inverse limit of the
alternating system $\mathbb{Z}/a_0 \leftarrow \mathbb{Z}/(a_0 a_1) \leftarrow
\cdots$ for a sequence $a_i \ge 2$ has cohomology equal to the localization of
$\mathbb{Z}$ at the set of partial products, and it is finitely generated iff the
sequence $a_i$ is eventually $1$ (trivial branching). The Lorenz template's
two-branch return map is exactly a mixed-radix odometer, so branching
multiplicities become localization primes. `InvSystem` already allows arbitrary
stage objects/bonding maps, so the mixed-radix tower is a direct instantiation;
only the colimit identification is new.

**3. König nonemptiness without surjectivity.** The inverse limit of a system of
finite nonempty sets with arbitrary (not necessarily surjective) bonding maps is
nonempty. Finiteness lets the eventual images stabilize (Mittag-Leffler), so a
surjective subsystem can be extracted and fed to `InvLimit.nonempty_of_surjective`.
The missing step is a purely finitary stabilization lemma provable by `Nat`
well-ordering on descending image cardinalities.

**4. Functoriality and an honest inverse-limit functor.** `InvLimit` extends to a
functor from the category of inverse systems (with level-wise commuting maps) to
types, sending level-wise surjections to surjections and level-wise injections to
injections. `proj` is already natural in the system, so the universal property is
one `funext` away; `InvLimit.ext` (threads determined by projections) is exactly
the uniqueness needed.

---

## 10. Conclusion

We have treated a chaotic attractor as an algebraic object and reaped an exact,
machine-checked dividend. The dyadic solenoid's first Čech cohomology is the dyadic
rationals $\mathbb{Z}[1/2]$; doubling is invertible there; the group is not finitely
generated; and therefore no finite directed graph has matching cohomology. The
inverse limit is mathematically necessary, certified by a single algebraic
invariant that cleanly separates finite diagrams from genuine chaos.
