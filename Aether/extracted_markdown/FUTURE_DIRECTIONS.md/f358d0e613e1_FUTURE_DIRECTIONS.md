# Future Directions: Compression Complexity of Algebraic Categories

## Synthesis

The complete classification of probe complexity for one-object monoid categories ($\kappa(BM) \in \{0,1\}$, determined entirely by triviality of $M$) opens a new research program: understanding categorical compression invariants for algebraically structured categories. The key discovery — that the monoid identity serves as a universal separator — raises the question of what replaces this mechanism in richer algebraic settings.

The five directions below form a coherent progression: from extending the monoid result to semigroups and enriched structures (Directions 1–2), to attacking multi-object categories of genuine mathematical interest (Direction 3), to connecting probe complexity to established invariants (Direction 4), and finally to a grand challenge linking categorical compression to computational complexity (Direction 5).

All directions build on the formal infrastructure in `Pythagorean/ProbeComplexity/Defs.lean`, `Pythagorean/ProbeComplexity/Theorems.lean`, and the new `Pythagorean/ProbeComplexity/MonoidCategory.lean`.

---

## Direction 1: Semigroup Probe Complexity and the Identity Barrier

**Conjecture:** There exists a complete characterization of finite semigroups $S$ for which the right regular representation $\rho: S \to \text{End}(S)$ is injective. Specifically: $\rho$ is injective if and only if $S$ has a right identity element (an element $e$ with $a \cdot e = a$ for all $a$).

**Test:** Enumerate all semigroups of order $\leq 6$ and check whether right regular injectivity correlates perfectly with the existence of a right identity. A single semigroup with injective $\rho$ but no right identity would refute the conjecture; a single semigroup with a right identity but non-injective $\rho$ would also refute it.

**Impact:** Would give the exact algebraic boundary where the One-Probe Theorem fails. Currently we know monoids always satisfy right detection and right zero bands fail it, but the precise dividing line is unknown.

**Catalog References:**
- `Pythagorean/ProbeComplexity/MonoidCategory.lean` — `rightDetects_of_monoid`, `not_rightDetects_iff`
- `Pythagorean/ProbeComplexity/Defs.lean` — `ProbeFamily.IsSeparating`

**Proof Strategy:** Formalize semigroup categories (one-object categories where composition comes from a semigroup, using `Mul` instead of `Monoid`). Prove the forward direction ($\text{right identity} \implies \text{injective}$) using the same $c = e$ argument. For the reverse direction, use the GAP computational algebra system to search for counterexamples.

**Domain Bridges:** Semigroup theory → automata theory (syntactic semigroups of regular languages), category theory (semicategories).

**Lineage:** Direct extension of `rightDetects_of_monoid`. The proof technique (using the identity) immediately suggests the right identity hypothesis.

**Ambition:** Medium — computationally verifiable and theoretically clean.

---

## Direction 2: Enriched One-Object Categories (Rings and Algebras)

**Conjecture:** For a ring $R$ viewed as an $\text{Ab}$-enriched one-object category, the *additive probe complexity* (requiring probes to separate morphisms up to additive structure) satisfies $\kappa_{\text{Ab}}(BR) = 0$ iff $R$ is the zero ring, and $\kappa_{\text{Ab}}(BR) = 1$ iff $R$ is nonzero. Furthermore, the separating element can always be taken to be the multiplicative identity $1_R$.

**Test:** Verify for matrix rings $M_n(\mathbb{F}_q)$, polynomial quotient rings $\mathbb{F}_q[x]/(f)$, and group rings $\mathbb{F}_q[G]$ for small $q$, $n$, and $|G|$.

**Impact:** Would extend the monoid classification to the enriched setting, showing that the identity-as-separator principle is robust across enrichment levels. This connects probe complexity to ring theory and representation theory.

**Catalog References:**
- `Pythagorean/ProbeComplexity/MonoidCategory.lean` — `singleton_isSeparating_singleObj_iff`
- `Pythagorean/ProbeComplexity/Theorems.lean` — `probeComplexity_le_card`

**Proof Strategy:** Define Ab-enriched probe families requiring separation of group homomorphisms. The key step is showing that multiplicative identity $1_R$ separates: if $a \cdot 1 = b \cdot 1$ then $a = b$, identical to the monoid case.

**Domain Bridges:** Ring theory → algebraic K-theory, Morita theory, noncommutative geometry.

**Lineage:** Enriched generalization of the monoid theorem. Uses the same core insight.

**Ambition:** Medium-high — requires enriched category theory infrastructure but the core proof should be similar.

---

## Direction 3: Probe Complexity of Finite Group Action Categories

**Conjecture (Grand Challenge):** For a finite group $G$ acting on a finite set $X$, the probe complexity of the associated action category (objects: elements of $X$, morphisms: group elements acting between orbits) is equal to the number of orbits minus the number of orbits on which the action is faithful.

**Test:** Compute $\kappa$ for $S_3$ acting on $\{1,2,3\}$ (one orbit, faithful, expected $\kappa = 0$?), $S_3$ acting on $\{1,2,3\} \sqcup \{4\}$ (two orbits), and cyclic group actions on various sets.

**Impact:** Would be the first non-trivial probe complexity classification for multi-object categories. Would connect probe complexity to the orbit-stabilizer theorem and representation theory.

**Catalog References:**
- `Pythagorean/ProbeComplexity/Theorems.lean` — `probeComplexity_pos_iff`, `card_hom_le_profile_capacity`
- `Pythagorean/ProbeComplexity/MonoidCategory.lean` — `probeComplexity_singleObj_eq_one_iff` (base case)

**Proof Strategy:** Use the orbit decomposition to reduce to individual orbits. For each orbit, the endomorphism monoid is the stabilizer, so the monoid theorem applies. The challenge is understanding how probes from different orbits interact.

**Domain Bridges:** Group actions → combinatorics (Burnside's lemma), topology (covering spaces), physics (gauge theory).

**Lineage:** Multi-object generalization of the monoid classification. The monoid case handles single orbits.

**Ambition:** High — requires new proof techniques beyond the identity-separator argument.

---

## Direction 4: Probe Complexity as Categorical Dimension

**Conjecture:** For the category $\text{FVect}_k$ of finite-dimensional vector spaces over a field $k$, the probe complexity equals 1 (the one-dimensional space $k$ separates all linear maps by the Yoneda lemma).

More generally, for an abelian category $\mathcal{A}$, the probe complexity equals the number of isomorphism classes of simple objects needed to generate all objects via extensions and direct sums.

**Test:** Verify for $\text{FVect}_{\mathbb{F}_q}$ (expected $\kappa = 1$), for $\text{Rep}(G)$ over $\mathbb{F}_q$ where $q \nmid |G|$ (expected $\kappa = $ number of irreducible representations), and for $\text{Mod}_{R}$ for small rings $R$.

**Impact:** Would establish probe complexity as a new categorical invariant analogous to global dimension, Krull dimension, or representation type. The connection to simple objects would link probe complexity to the heart of representation theory.

**Catalog References:**
- `Pythagorean/ProbeComplexity/Theorems.lean` — `probeComplexity_le_card`, `card_hom_le_profile_capacity`

**Proof Strategy:** For $\text{FVect}_k$, show that $k$ separates: any linear map $f: V \to W$ is determined by its precompositions with linear maps $k \to V$ (which are just choices of vectors in $V$). For the general case, use Jordan-Hölder filtrations.

**Domain Bridges:** Category theory → homological algebra, algebraic geometry (sheaf categories), mathematical physics (TQFT).

**Lineage:** Grand generalization of the monoid case (monoid categories are the "rank 1" case).

**Ambition:** Very high — would require substantial new theory.

---

## Direction 5: Computational Complexity of Probe Complexity

**Conjecture (Grand Challenge):** Computing $\kappa(C)$ for a finite category $C$ given by its morphism table is NP-hard. Specifically, the decision problem "Is $\kappa(C) \leq k$?" is NP-complete for $k$ given as part of the input.

**Test:** Reduce from Set Cover: given a universe $U$ and a collection of sets $S_1, \ldots, S_m$, construct a category where objects are elements of $U \cup S$, morphisms encode membership, and probe complexity equals the minimum set cover size. Verify the reduction for instances with known set cover numbers.

**Impact:** Would establish the first computational complexity result for a categorical invariant. The contrast with the monoid case ($\kappa$ computable in $O(1)$) shows how algebraic structure can collapse computational complexity.

**Catalog References:**
- `Pythagorean/ProbeComplexity/Defs.lean` — `probeComplexity` (the invariant to classify)
- `Pythagorean/ProbeComplexity/MonoidCategory.lean` — `probeComplexity_singleObj_dichotomy` (tractable case)

**Proof Strategy:** The connection to Set Cover is natural: a separating probe family must "cover" all pairs of morphisms, analogous to covering all elements of a universe. The NP-hardness of Set Cover should transfer. Membership in NP follows from the finite witness (the probe family itself).

**Domain Bridges:** Computational complexity → approximation algorithms, parameterized complexity, category theory.

**Lineage:** Complexity-theoretic analysis of the invariant defined in the probe complexity framework.

**Ambition:** Very high — would bridge pure category theory and computational complexity theory.
