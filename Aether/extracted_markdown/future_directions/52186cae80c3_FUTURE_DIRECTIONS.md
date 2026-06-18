# Future Directions: Morita-Invariant Probe Complexity

## Synthesis

The establishment of κ as a Morita invariant opens a systematic research program at the intersection of finite category theory, topos theory, and computational complexity. The central theme is that probe complexity captures intrinsic observational structure — structure that is invariant under changes of presentation (site, basis, coordinate system). The directions below form a coherent arc: Direction 1 completes the topos-theoretic picture, Direction 2 provides the computational toolkit, Direction 3 connects to classical invariants, Direction 4 bridges to computer science, and Direction 5 reaches toward higher-categorical generalizations.

Each direction is grounded in the formally verified theorems `probeComplexity_eq_of_equivalence`, `probeComplexity_eq_karoubi`, and `kappa_eq_of_karoubi_equivalence` from `Pythagorean/ProbeComplexity/MoritaInvariance.lean`, and extends the foundation in `Pythagorean/ProbeComplexity/Defs.lean` and `Pythagorean/ProbeComplexity/Theorems.lean`.

---

## Direction 1: Topos-Generator Characterization (Grand Challenge)

**Conjecture:** For any finite category C with finite hom-sets, κ(C) equals the minimum cardinality of a finite separating family of representable presheaves in the presheaf category [C^op, Set].

**Test:** For finite categories with ≤ 4 objects and ≤ 12 morphisms, compute both κ(C) and the minimum separating family of representables in [C^op, Set]. Check equality. A counterexample would be a category where the internal topos-theoretic notion of separation diverges from the external probe-based notion.

**Impact:** If true, this gives κ a purely topos-internal characterization, completing its promotion from a category-level statistic to a topos-level invariant. It would establish κ as the first finitary, computable invariant of presheaf toposes with an explicit formula. This could reshape how algebraic geometers compare site presentations.

**Catalog References:**
- `Pythagorean/ProbeComplexity/MoritaInvariance.lean` — Morita invariance of κ
- `Pythagorean/ProbeComplexity/Defs.lean` — definition of separating probe families
- `Catalog/Pythagorean/ProbeComplexity/CategoricalDimension.lean` — separating families in module categories

**Proof Strategy:** Translate the probe separation condition into the language of presheaf categories. A probe Z ∈ Obj(C) induces the representable presheaf y(Z) = Hom(−, Z). The probe family P separates morphisms iff {y(Z) : Z ∈ P} jointly detects all natural transformations between representables. Use the Yoneda lemma to bridge the internal and external perspectives.

**Domain Bridges:** Algebraic geometry (site presentations), topos theory (generator complexity), mathematical logic (Beth definability)

**Lineage:** Extends `kappa_eq_of_karoubi_equivalence` by giving κ a coordinate-free definition

**Ambition:** Grand challenge — paradigm-shifting if solved

---

## Direction 2: Subadditivity and Dimension Theory of κ

**Conjecture:** For finite categories C and D, κ(C ⊔ D) = max(κ(C), κ(D)), where C ⊔ D is the coproduct (disjoint union) category.

**Test:** Exhaustive computation over pairs of finite categories with ≤ 3 objects each. A counterexample would show κ is not a "dimension-like" invariant but something more subtle.

**Impact:** Combined with the established product formula κ(C × D) = κ(C) + κ(D) (from the catalog), this would make κ satisfy the axioms of a generalized dimension function: additive on products, taking max on coproducts. This is the exact behavior of Krull dimension, global dimension, and other categorical dimensions, placing κ in their company.

**Catalog References:**
- `Catalog/Pythagorean/ProbeComplexity/CoproductSubadditivity.lean` — existing coproduct work
- `Catalog/Pythagorean/ProbeComplexity/ProductFormula.lean` — product formula for κ

**Proof Strategy:** For the upper bound κ(C ⊔ D) ≤ max(κ(C), κ(D)), embed separating families from C and D into C ⊔ D. For the lower bound, restrict separating families of C ⊔ D to each component. The key subtlety: morphisms in C ⊔ D only go within components, so probe families decompose cleanly.

**Domain Bridges:** Homological algebra (dimension theory), K-theory (additive invariants), combinatorics (matroid dimension)

**Lineage:** Extends `probeComplexity_eq_of_equivalence` via structural decomposition theorems

**Ambition:** Solid extension — directly testable and formally verifiable

---

## Direction 3: Retract-Profile Sufficiency (Grand Challenge)

**Conjecture:** κ(C) is determined by the multiset of retract profiles of representable objects in Kar(C). That is, if C and D have the same multiset of retract profiles (up to re-indexing), then κ(C) = κ(D).

**Test:** Search for pairs of finite categories with ≤ 4 objects that have identical retract-profile multisets but potentially different κ values. A counterexample would show that retract profiles are too coarse — the interaction structure between objects matters beyond their individual observation profiles.

**Impact:** This would give a complete combinatorial characterization of κ in terms of idempotent-splitting data. It would reduce the computation of κ to a matrix problem: given the retract-profile matrix, find the minimum number of rows needed to separate all columns.

**Catalog References:**
- `Pythagorean/ProbeComplexity/MoritaInvariance.lean` — definition of `retractProfile`
- `Pythagorean/ProbeComplexity/Theorems.lean` — profile capacity bounds

**Proof Strategy:** Define a formal "profile matrix" encoding the retract profiles. Show that κ equals the minimum set cover of the matrix's separation structure. This reduces the Morita invariance question to a combinatorial optimization problem with known algorithms.

**Domain Bridges:** Information theory (channel capacity), combinatorial optimization (set cover), database theory (functional dependencies)

**Lineage:** Extends `every_separating_is_split_stable` by characterizing exactly what data determines κ

**Ambition:** Grand challenge — would give algorithmic and theoretical closure to the κ theory

---

## Direction 4: Automata-Theoretic Probe Complexity

**Conjecture:** For a finite deterministic automaton A with transition monoid M, the probe complexity κ(M) (viewing M as a one-object category) equals 1 if M is nontrivial, and the Morita invariance theorem implies that idempotent completion of M (adjoining formal images of idempotent transformations) does not change this value. More generally, for the full category of states of A, κ captures the "observational dimension" of the automaton's behavior.

**Test:** Compute κ for categories derived from automata on ≤ 5 states with ≤ 3 input symbols. Compare with classical automata-theoretic complexity measures (state complexity, transformation semigroup depth).

**Impact:** This would establish a bridge between categorical probe complexity and the well-developed theory of automata complexity. If κ correlates with or bounds known measures, it provides a new categorical perspective on state minimization and observational equivalence.

**Catalog References:**
- `Catalog/Pythagorean/ProbeComplexity/MonoidCategory.lean` — κ for monoid categories
- `Pythagorean/ProbeComplexity/MoritaInvariance.lean` — `kappa_singleObj_eq_karoubi`

**Proof Strategy:** Use the classification κ(SingleObj M) = 0 or 1 from the monoid category theorem. Extend to multi-object categories of automata using the product/coproduct structure. Connect idempotent completion to the construction of "syntactic" or "minimal" automata.

**Domain Bridges:** Formal languages (Myhill-Nerode theory), verification (bisimulation), concurrency theory (process algebra)

**Lineage:** Extends `kappa_singleObj_eq_karoubi` to automata with multiple states

**Ambition:** Solid extension — connects to well-studied problems in CS

---

## Direction 5: Enriched and Higher-Categorical κ

**Conjecture:** The probe complexity κ can be extended to V-enriched categories for suitable monoidal categories V (e.g., V = Ab, V = Vect_k), and the Morita invariance theorem generalizes: κ_V(C) = κ_V(Kar_V(C)) where Kar_V is the V-enriched Karoubi envelope.

**Test:** Formalize κ_Ab for Ab-enriched categories (preadditive categories) and compute on small examples: matrix rings, path algebras of quivers with ≤ 4 vertices. Check that κ_Ab is invariant under additive Karoubi completion (= idempotent completion in the additive setting).

**Impact:** This would extend the entire theory from ordinary categories to enriched settings, where Morita equivalence has deep connections to Morita theory for rings, tilting theory, and derived categories. For V = Vect_k, this connects directly to the classical Morita theory of algebras.

**Catalog References:**
- `Pythagorean/ProbeComplexity/MoritaInvariance.lean` — the ordinary case
- `Catalog/Pythagorean/ProbeComplexity/CategoricalDimension.lean` — probe complexity for module categories (an enriched setting)

**Proof Strategy:** Abstract the proof of κ(C) = κ(Kar(C)) to the enriched setting. The key ingredients — absorption lemma, faithful embedding, probe transport — should generalize with V-enriched versions. The main technical challenge is defining "separating family" in the enriched context (replace "h ∘ f ≠ h ∘ g" with a V-internal notion of separation).

**Domain Bridges:** Homological algebra (derived Morita theory), representation theory (tilting modules), noncommutative geometry (Morita equivalence of algebras)

**Lineage:** Generalizes all theorems in this file to the enriched setting

**Ambition:** Grand challenge — would unify the combinatorial κ with classical algebraic Morita theory
