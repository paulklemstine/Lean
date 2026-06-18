# Future Directions: Observational Complexity of Categories

## Synthesis

The categorical compression number κ(C) opens a new axis of investigation connecting category theory, combinatorics, and information theory. We have established that κ is a genuine categorical invariant (invariant under equivalence), that it vanishes precisely on thin categories, and that it can be computed algorithmically on finite examples. The directions below form a coherent program: Direction 1 (Morita invariance) lifts the invariant from categories to their presheaf toposes; Direction 2 (product laws) connects it to the algebra of categorical constructions; Direction 3 (monoid characterization) bridges to classical algebra; Direction 4 (spectral bounds) connects to graph theory and linear algebra; Direction 5 (infinite generalization) pushes toward genuine topos-theoretic invariants.

---

## Direction 1: Morita Invariance of κ

**Conjecture:** If two finite categories C and D have equivalent presheaf categories [C^op, Set] ≃ [D^op, Set], then κ(C) = κ(D).

**Test:** Construct explicit pairs of Morita-equivalent finite categories (e.g., a category and its Cauchy completion / Karoubi envelope). Compute κ for both and compare. Start with categories having 2–4 objects and ≤ 10 morphisms. A single counterexample (κ(C) ≠ κ(D) with equivalent presheaf categories) would refute the conjecture.

**Impact:** If true, κ becomes a topos-theoretic invariant — it depends only on the presheaf topos, not on the presenting site. This would be the first known finitary invariant of this kind with an explicit computational formula. If false, the counterexample would reveal what additional structure beyond presheaf equivalence controls observational complexity.

**Catalog References:** `Pythagorean/ProbeComplexity/NonDiscreteCompression.lean` (compressionNumber_eq_of_equivalence)

**Proof Strategy:** Show that Cauchy completion preserves κ. A category and its Cauchy completion are Morita equivalent, and the Cauchy completion is obtained by splitting idempotents. Show that splitting an idempotent does not change κ by constructing explicit probe family bijections. Then use the fact that two categories are Morita equivalent iff their Cauchy completions are equivalent (Borceux–Dejean theorem).

**Domain Bridges:** Topos theory, algebraic geometry (site presentations), homological algebra

**Lineage:** Extends compressionNumber_eq_of_equivalence from category equivalence to Morita equivalence

**Ambition:** grand_challenge

---

## Direction 2: Product Formula for κ

**Conjecture:** For finite categories C, D:
κ(C × D) ≤ κ(C) · |Ob(D)| + κ(D) · |Ob(C)|

More specifically, computational experiments suggest:
- If C is thin, κ(C × D) = κ(D) · |Ob(C)| when D is not thin
- κ(C × D) = max(κ(C), κ(D)) appears to fail in general

**Test:** Exhaustively compute κ(C × D) for all pairs of categories with ≤ 4 objects. Compare against candidate formulas: max, sum, product, and the upper bound above. The product ParallelArrows(2) × Discrete(2) already shows κ(product) = 2 > max(1, 0), refuting the simple max formula.

**Impact:** A product formula would make κ computable for large composite categories without brute force. It would also reveal the structural content of κ: whether it behaves like a dimension (additive), like a rank (max), or like something more subtle.

**Catalog References:** `Pythagorean/ProbeComplexity/NonDiscreteCompression.lean` (YonedaSeparating, CompressionNumber)

**Proof Strategy:** Analyze the product category's hom-sets: Hom_{C×D}((X₁,X₂),(Y₁,Y₂)) = Hom_C(X₁,Y₁) × Hom_D(X₂,Y₂). A probe (Q₁,Q₂) in C×D separates a parallel pair (f₁,f₂) ≠ (g₁,g₂) iff some postcomposition distinguishes them. This splits into cases: if f₁ ≠ g₁, need a probe in the C-factor; if f₂ ≠ g₂, need a probe in the D-factor; if both differ, either suffices.

**Domain Bridges:** Combinatorics (covering designs), information theory (channel capacity)

**Lineage:** New direction building on basic κ theory

**Ambition:** solid_extension

---

## Direction 3: Complete Characterization for Monoid Categories

**Conjecture:** For a finite monoid M viewed as a one-object category BM:
- κ(BM) = 0 iff |M| = 1
- κ(BM) = 1 iff |M| > 1 and M has right-cancellation detection (for all a ≠ b, ∃ c with ac ≠ bc)
- κ(BM) is undefined (impossible) otherwise — but in fact, right-cancellation detection always holds for any monoid with more than one element

**Test:** Enumerate all monoids of order ≤ 6 (there are finitely many up to isomorphism). For each, compute κ(BM) and check whether right-cancellation detection holds. Search specifically for a monoid where two distinct elements a, b have identical right-multiplication tables (ac = bc for all c).

**Impact:** This would provide a clean algebraic characterization of κ for an important class of categories, connecting category theory to semigroup theory. The right-cancellation detection property is related to the faithful representation theory of monoids.

**Catalog References:** `Pythagorean/ProbeComplexity/NonDiscreteCompression.lean` (yonedaSeparating_univ, compressionNumber_eq_zero_of_thin)

**Proof Strategy:** In a one-object category, YonedaSeparating {*} is equivalent to: for all f ≠ g : * → *, ∃ h : * → * with fh ≠ gh. This is exactly right-cancellation detection. If it fails, there exist f ≠ g with fh = gh for all h, meaning {*} doesn't separate, and since there's only one object, κ > |Ob| = 1 — contradiction. So right-cancellation detection always holds when |M| > 1. Actually, this needs careful verification: can we have two elements with identical right-multiplication tables? In a group, no (multiply by inverses). In a monoid, consider {0, 1} with 0·x = 0 for all x and 1·x = x: then 0 ≠ 1 but 0·1 = 0 ≠ 1 = 1·1, so they're still separated. Need systematic search.

**Domain Bridges:** Semigroup theory, representation theory, automata theory (syntactic monoids)

**Lineage:** Cross-domain bridge from category theory to algebra

**Ambition:** solid_extension

---

## Direction 4: Spectral Bounds via Morphism Matrices

**Conjecture:** For a finite category C, κ(C) is bounded below by the number of distinct rows in the "morphism separation matrix" M where M_{(f,g), Q} = 1 iff some h : cod(f) → Q separates f from g. Specifically, κ(C) ≥ rank(M) over GF(2) in some appropriate formulation.

**Test:** For categories with 2–5 objects, construct the separation matrix M (rows = parallel pairs, columns = potential probe objects). Compute the GF(2)-rank and compare with κ. If rank < κ for some example, the bound is not tight; if rank = κ always, the bound is exact.

**Impact:** This would connect κ to linear algebra and spectral graph theory, enabling polynomial-time lower bounds even when exact computation is exponential. It could also reveal structural decompositions of categories into "independently observable" components.

**Catalog References:** `Pythagorean/ProbeComplexity/NonDiscreteCompression.lean` (YonedaSeparating)

**Proof Strategy:** The Yoneda-separation condition is equivalent to: the columns indexed by P must cover all rows of M. This is exactly a set cover problem. The GF(2)-rank of M gives a lower bound on any cover. Connect to results on the set cover LP relaxation.

**Domain Bridges:** Linear algebra, combinatorial optimization (set cover), spectral graph theory

**Lineage:** New direction connecting κ to matrix theory

**Ambition:** solid_extension

---

## Direction 5: Generalization to Infinite Categories via Pro-finite Approximation

**Conjecture:** For a locally finite category C (finitely many morphisms between any two objects, but possibly infinitely many objects), define κ(C) = sup{κ(C|_S) : S ⊆ Ob(C) finite, full subcategory}. This generalized κ is still invariant under equivalence and gives a meaningful invariant of the presheaf topos when finite.

**Test:** Compute κ for truncations of the simplex category Δ (Δ_n with objects [0],...,[n]) for increasing n. Observe whether κ(Δ_n) stabilizes or grows. If it stabilizes, the limit is κ(Δ). Compute similarly for the category of finite sets and injections, truncated to small cardinalities.

**Impact:** This would extend the theory from finite combinatorial category theory to genuine categorical geometry, where the invariant could distinguish sites used in algebraic geometry and homotopy theory. Even partial results would connect probe complexity to simplicial combinatorics.

**Catalog References:** `Pythagorean/ProbeComplexity/NonDiscreteCompression.lean` (all main theorems)

**Proof Strategy:** First establish that κ(C|_S) is monotone in S (larger full subcategories have higher or equal κ). Then show the supremum is well-defined (possibly infinite). For equivalence invariance, use the finite approximation + equivalence invariance of finite κ.

**Domain Bridges:** Simplicial homotopy theory, algebraic geometry (site presentations), topos theory

**Lineage:** Extends the entire κ theory from finite to infinite categories

**Ambition:** grand_challenge
