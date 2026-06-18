# Future Directions: Sheaf-Theoretic Tropical Persistence

## Synthesis

The constructible sheaf framework for tropical persistence opens a systematic research program connecting three mathematical areas: (1) tropical combinatorics on finite graphs, (2) constructible sheaf theory on parameter spaces, and (3) topological data analysis via persistent homology. The key bridge is the identification of the tropical event profile with a cumulative sheaf-jump formula (Theorem 2 in `Pythagorean/TropicalBridge/SheafPersistence.lean`), which converts a computational observation into a functorial invariant.

The five directions below form a coherent program: Direction 1 (higher jumps) extends the degree-0 theory vertically; Direction 2 (multiparameter) extends it horizontally; Direction 3 (Möbius inversion) connects to algebra; Direction 4 (microlocal) bridges to analysis; Direction 5 (tropical six functors) provides the ultimate categorical framework. Each direction builds on the existing formal infrastructure and is testable on the path/cycle graph examples already verified in the Catalog.

---

## Direction 1: Higher Tropical Sheaf Jumps and Derived Persistence

**Conjecture.** For any finite graph filtration, define the *degree-k sheaf jump* at a critical value c as the rank of the k-th derived functor of the stalk-restriction map. For path and cycle graphs, all higher jumps (k ≥ 1) vanish at non-critical thresholds, and the degree-0 jumps fully determine the event profile.

**Test.** Construct explicit chain complexes from the graph Laplacian restricted to entering vertices. Compute higher homology for path graphs P_n (n ≤ 20) and cycle graphs C_n (n ≤ 20). If any higher jump is nonzero at a non-critical threshold, the conjecture fails. If all vanish, attempt a formal proof by induction on the critical value list.

**Impact.** If higher jumps vanish for trees and cycles, this characterizes these graph families sheaf-theoretically. If they don't, the higher jumps define new graph invariants that refine the event profile — potentially detecting features invisible to degree-weighted counts.

**Catalog References.** `Pythagorean/TropicalBridge/SheafPersistence.lean` (sheafJump, tropEvtProfile_eq_cumSheafJump); `Catalog/Pythagorean/TropicalBridge/FiltrationPersistence.lean` (tropicalKernelDim_step_decomposition).

**Proof Strategy.** Define a two-term chain complex at each critical value using the graph Laplacian principal minor. Show that for trees, the Laplacian minor is nonsingular (full rank), forcing higher homology to vanish. For cycles, the kernel of the Laplacian at the closing edge creates exactly one cycle, giving a single nonzero higher jump.

**Domain Bridges.** Homological algebra (derived functors), spectral graph theory (Laplacian kernel), tropical Hodge theory.

**Lineage.** Extends `tropEvtProfile_jump_at_critical` to higher degrees.

**Ambition.** Grand challenge — establishing derived tropical persistence as a new invariant theory.

The key insight is that the degree-0 sheaf jump is the *shadow* of a richer derived object, and the vanishing/non-vanishing of higher jumps classifies graph topology.

Why now? The formal infrastructure for constructible sheaves on finite posets exists in the Catalog, and the jump formula provides the computational foundation. The Laplacian-based approach is computationally accessible and formally verifiable.

---

## Direction 2: Multiparameter Tropical Persistence Sheaves

**Conjecture.** For filtrations indexed by ℝ² (e.g., vertex weight + edge weight), the tropical rank sheaf is constructible with respect to a finite stratification of the parameter plane. The critical locus is a finite arrangement of lines, and the sheaf is locally constant on each face of the arrangement.

**Test.** Implement biparameter filtrations on small graphs (K₄, P₅ × P₅). Compute stalk data on a grid of parameter values. Verify that the stalk is constant on each face of the critical arrangement. Disprove by finding a face where the stalk changes.

**Impact.** Multiparameter persistence is one of the central open problems in TDA. A sheaf-theoretic approach via tropical constructibility would provide a new structural framework, complementing the algebraic approaches of Carlsson-Zomorodian and the topological approaches of Lesnick-Wright.

**Catalog References.** `Pythagorean/TropicalBridge/SheafPersistence.lean` (sameCritGap, activeVerts_eq_of_sameCritGap, critVals).

**Proof Strategy.** Generalize `sameCritGap` to ℝ²: two parameters lie in the same gap if no critical *hyperplane* separates them. The constructibility proof should generalize: the active set changes only when crossing a critical hyperplane. Use Finset operations in 2D.

**Domain Bridges.** Multiparameter persistence (Carlsson-Zomorodian), arrangement theory (Orlik-Terao), constructible sheaves on stratified spaces (Kashiwara-Schapira).

**Lineage.** Extends `activeVerts_eq_of_sameCritGap` from 1D to higher dimensions.

**Ambition.** Solid extension — the 1D infrastructure is in place and the generalization is natural.

The key insight is that the critical values of a multiparameter filtration form a hyperplane arrangement, and constructibility with respect to this arrangement is the correct generalization of the 1D theory.

Why now? The 1D constructibility theorem is formally verified, and the proof technique (contradiction via gap-crossing) generalizes directly to higher dimensions. The main challenge is the combinatorial complexity of arrangements.

---

## Direction 3: Möbius Inversion and Incidence Algebra Bridge

**Conjecture.** The cumulative sheaf jump formula `P(t) = Σ_{c ≤ t} J(c)` is a zeta-convolution on the critical poset. The inverse formula `J(c) = Σ_{c' ≤ c} μ(c', c) P(c')` (Möbius inversion) recovers individual jumps from the cumulative profile. For filtrations with distinct entrance times, the Möbius function of the critical poset is the alternating sign function, and inversion reduces to finite differencing.

**Test.** Compute Möbius functions for critical posets of random filtrations on graphs with n ≤ 50 vertices. Verify the inversion formula by comparing recovered jumps with direct computation. Test whether the formula extends to filtrations with repeated entrance times (non-totally-ordered critical posets).

**Impact.** Connecting tropical persistence to incidence algebras would bridge to combinatorics (Stanley, Rota) and provide algebraic tools for computing and manipulating persistence data. The Möbius function of the critical poset would become a new graph invariant.

**Catalog References.** `Pythagorean/TropicalBridge/SheafPersistence.lean` (sheafJump, sheafEvtProfile, tropEvtProfile_eq_cumSheafJump, total_sheafJump_eq_total_profile).

**Proof Strategy.** Formalize the critical poset as a `LocallyFiniteOrder`. Apply `Finset.sum_mobius_apply` (if available in Mathlib) or prove a custom Möbius inversion for linearly ordered finite posets. The key step is showing that the jump function and profile function are related by the zeta function of the critical poset.

**Domain Bridges.** Incidence algebras (Rota, Stanley), Möbius inversion (number theory, combinatorics), lattice theory.

**Lineage.** Builds directly on `tropEvtProfile_eq_cumSheafJump`.

**Ambition.** Solid extension — the algebra is classical and the connection is natural.

The key insight is that the cumulative jump formula is literally a zeta-convolution, and Möbius inversion is the universal mechanism for recovering local from global data on posets.

Why now? The cumulative formula is formally verified, and Mathlib has growing support for locally finite orders and Möbius functions. The formalization is a direct application of existing infrastructure.

---

## Direction 4: Microlocal Singular Support and Propagation

**Conjecture.** The singular support of the tropical rank sheaf (= the set of entrance times) satisfies a tropical analogue of the *microlocal Morse lemma*: the sheaf jump at a critical value c equals the "microlocal stalk" of the sheaf at c, defined as the rank of a certain local cohomology object. For generic filtrations (distinct entrance times), the singular support is a discrete subset of ℝ with multiplicity data (the jump values), and the total multiplicity equals the total profile.

**Test.** Define microlocal stalks for the tropical rank sheaf using the jump formula. Verify the microlocal Morse lemma computationally for all graphs on ≤ 8 vertices. Search for a counterexample where the microlocal stalk differs from the sheaf jump.

**Impact.** This would create a direct bridge from tropical persistence to the Kashiwara-Schapira theory of microsupport. The microsupport is a powerful invariant in analysis and algebraic geometry; a tropical-combinatorial version would be both computable and formally verifiable.

**Catalog References.** `Pythagorean/TropicalBridge/SheafPersistence.lean` (sheafJump, critVals, tropEvtProfile_jump_at_critical); `Catalog/Pythagorean/TropicalBridge/Stability.lean` (tropicalEventProfile, stability theorems).

**Proof Strategy.** Define the microlocal stalk as the difference `P(c) - P(c⁻)` (the left limit). Show this equals `sheafJump G f c` using `tropEvtProfile_jump_at_critical`. The key subtlety is handling filtrations with coincident entrance times, where multiple vertices enter simultaneously.

**Domain Bridges.** Microlocal analysis (Kashiwara-Schapira), D-modules, symplectic geometry (via the cotangent bundle interpretation of microsupport).

**Lineage.** Extends `tropEvtProfile_jump_at_critical` to a microlocal interpretation.

**Ambition.** Grand challenge — establishing a tropical microlocal theory.

The key insight is that the sheaf jump at a critical value is the "microlocal stalk" of the sheaf at that singular point, providing a combinatorial model for the analytical concept of microsupport.

Why now? The formal jump formula provides the computational foundation, and the connection to Kashiwara-Schapira's work on persistent homology and microsupport [8] provides the conceptual framework.

---

## Direction 5: Tropical Six-Functor Formalism

**Conjecture.** There exists a six-functor formalism for tropical constructible sheaves on finite posets, with operations (f*, f_*, f!, f^!, ⊗, Hom) satisfying the standard adjunctions and base-change formulas. The tropical rank sheaf is the pushforward `f_*(𝟙)` of the constant sheaf along the filtration map `f : V → ℝ`, and the stability theorem is a consequence of proper base change.

**Test.** Define the six functors for sheaves on the critical poset of a path graph filtration. Verify the adjunction `f* ⊣ f_*` computationally. Check the base-change formula for a Cartesian square involving two different filtrations. Disprove by finding a base-change square where the formula fails.

**Impact.** A tropical six-functor formalism would be a major structural achievement, providing the ultimate categorical foundation for tropical persistence. It would connect tropical combinatorics to the mainstream of modern algebraic geometry (Grothendieck's legacy).

**Catalog References.** `Pythagorean/TropicalBridge/SheafPersistence.lean` (TropRankSheaf, mkTropRankSheaf, kernelRestriction, kernelRestriction_comp).

**Proof Strategy.** Start with the finite-poset case: define f_* as the direct image sheaf (pushforward of stalk data). Define f* as the inverse image (pullback). Verify adjunction for morphisms of finite posets. The base-change formula should follow from the finiteness of all involved sets.

**Domain Bridges.** Grothendieck's six-functor formalism, derived algebraic geometry, motivic integration, tropical Hodge theory.

**Lineage.** Extends the functoriality of `kernelRestriction` to a full categorical framework.

**Ambition.** Grand challenge (paradigm-shifting) — a tropical six-functor formalism would be a major new construction.

The key insight is that the restriction maps `kernelRestriction` already exhibit functoriality, and the full six-functor structure should emerge from packaging this functoriality categorically.

Why now? The formal proof of functoriality (`kernelRestriction_comp`) provides the foundation. The six-functor formalism for constructible sheaves on finite posets is well-understood classically, and the tropical setting provides concrete combinatorial models for all operations.
