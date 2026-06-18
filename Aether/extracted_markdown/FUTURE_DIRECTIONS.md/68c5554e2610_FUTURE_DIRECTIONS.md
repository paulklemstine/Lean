# Future Directions: Probe Complexity as Categorical Dimension

## Synthesis

The probe complexity framework established here opens a new axis of investigation in categorical algebra. The exact computation pc(Mod(k)) = 1 demonstrates that the invariant is nontrivial and computable, while the functorial transfer theorems provide tools for systematic exploration. The five directions below form a coherent program: Direction 1 extends the exact computation to semisimple categories (establishing the invariant's relationship to simple objects), Direction 2 explores the boundary where semisimplicity fails (probing the invariant's sensitivity to extensions), Direction 3 connects to representation theory (giving concrete applications to finite groups), Direction 4 studies behavior under categorical constructions (establishing algebraic properties of the invariant), and Direction 5 pushes toward a categorified information theory (connecting to compressed sensing and query complexity). Together, these directions would establish probe complexity as a fundamental invariant alongside global dimension and representation type, with applications spanning algebra, topology, physics, and information theory.

---

## Direction 1: Semisimple Exactness Theorem

**Conjecture:** In any semisimple abelian category C with finitely many simple isomorphism classes {S₁, ..., Sₙ}, the set {S₁, ..., Sₙ} is a precompose-separating family and pc(C) = n.

**Test:** Formalize the upper bound (simples separate) using the argument: if f ≠ g, then d = f − g ≠ 0, im(d) contains a simple subobject Sᵢ by semisimplicity, and a nonzero map from Sᵢ into the domain detects d. For the lower bound, show that omitting any simple Sⱼ from the probe set allows construction of morphisms that agree on all remaining probes but differ on the Sⱼ-isotypic component. Verify computationally for Rep(Cₙ) over splitting fields for n = 2, 3, 4, 5.

**Impact:** This would establish probe complexity as a representation-theoretic invariant equal to the number of irreducible representations in the semisimple case, connecting categorical tomography to character theory.

**Catalog References:** `Pythagorean/ProbeComplexity/CategoricalDimension.lean` — `ModuleCat_field_k_precompose_separates`, `categoryProbeComplexity_ModuleCat_eq_one`, `PrecomposeSeparatingFamily.superset`. Also `Catalog/Pythagorean/ProbeComplexity/Theorems.lean` — `probeComplexity_le_card`, `card_hom_le_profile_capacity`.

**Proof Strategy:** Strategy B (image-of-difference and simple subobject detection). Requires: (1) existence of image factorizations in abelian categories, (2) simple subobject detection in semisimple categories, (3) lifting of maps through semisimple decompositions.

**Domain Bridges:** Representation theory (character theory, Maschke's theorem), homological algebra (semisimple decomposition, Schur's lemma).

**Lineage:** Directly extends `ModuleCat_field_k_precompose_separates` from the one-simple case (vector spaces) to the n-simple case.

**Ambition:** Grand challenge — would be the first exact computation of probe complexity in a non-trivial multi-simple category, establishing the invariant as a genuine dimension theory.

---

## Direction 2: Non-Semisimple Boundary and Extension Sensitivity

**Conjecture:** In every finite-length abelian category with n simple isomorphism classes, pc(C) ≤ n. Furthermore, pc(C) = n if and only if C is semisimple.

**Test:** Compute pc for module categories over small Artinian rings: ℤ/p²ℤ (1 simple, not semisimple), 𝔽_q[x]/(x²) (1 simple, not semisimple), upper triangular matrices over 𝔽_q (2 simples, not semisimple), the group algebra 𝔽_p[Cₚ] (1 simple, not semisimple). If any non-semisimple category achieves pc = n, the second part of the conjecture is falsified. Current computational evidence from ℤ/4ℤ-modules (pc = 1 = n, not semisimple) suggests the "only if" direction is FALSE — disproof is expected.

**Impact:** Understanding how extensions affect probe complexity would reveal whether the invariant detects purely the simple spectrum or also the extension structure. A sharp characterization would connect probe complexity to ext groups and Hochschild cohomology.

**Catalog References:** `Pythagorean/ProbeComplexity/CategoricalDimension.lean` — `categoryProbeComplexity_eq_zero_iff`, `categoryProbeComplexity_pos_of_nontrivial`.

**Proof Strategy:** Computational search for small categories. For the upper bound, attempt to show that in a finite-length category, the simple composition factors of a generator provide enough probes. For the "if" direction (semisimple → pc = n), use Direction 1. For the "only if" direction, construct explicit counterexamples.

**Domain Bridges:** Module theory (Artinian rings, radical theory, Loewy length), homological algebra (ext groups, Auslander-Reiten theory).

**Lineage:** Extends Direction 1 beyond the semisimple boundary.

**Ambition:** Paradigm-shifting — if the "only if" direction fails (which evidence suggests), this reveals that probe complexity measures something fundamentally different from semisimplicity, opening an entirely new classification axis.

---

## Direction 3: Probe Complexity of Finite Group Representations

**Conjecture:** For a finite group G and a splitting field k with char(k) ∤ |G|, the probe complexity of Rep_k(G) equals the number of conjugacy classes of G (= the number of irreducible k-representations of G).

**Test:** Compute for specific groups: C₂ (expected: 2), C₃ (expected: 3), S₃ (expected: 3), D₄ (expected: 5), A₄ (expected: 4), S₄ (expected: 5). Use GAP or SageMath to enumerate irreducible representations, then verify computationally that the irreducible representations form a separating family and no proper subfamily does.

**Impact:** Would give the first representation-theoretic application of probe complexity, connecting it to the classical theory of characters and providing a new perspective on the role of irreducible representations as "measurement basis vectors."

**Catalog References:** `Pythagorean/ProbeComplexity/CategoricalDimension.lean` — `ModuleCat_singleton_separating`, `separatingFamily_pullback_faithful`, `separatingFamily_pushforward_full_faithful`.

**Proof Strategy:** Specialize the semisimple exactness theorem (Direction 1) using Maschke's theorem. The functor from Rep_k(G) to Mod(k) is faithful, so results can be transferred. Use character orthogonality to prove the lower bound: if an irreducible representation Vᵢ is missing from the probe set, construct two G-equivariant maps that agree on all other irreducible probes but differ on Vᵢ.

**Domain Bridges:** Finite group theory (conjugacy classes, character tables), number theory (over finite fields), mathematical physics (TQFT, particle classification).

**Lineage:** Applies Direction 1 to the specific semisimple category Rep_k(G).

**Ambition:** Solid extension — the mathematical content follows from Direction 1 plus Maschke's theorem, but the formalization requires connecting the abstract framework to concrete group representation machinery.

---

## Direction 4: Subadditivity and Categorical Constructions

**Conjecture:** For categories C, D with finite probe complexity:
(a) pc(C × D) ≤ pc(C) + pc(D) (product subadditivity).
(b) If C has finite biproducts, probe complexity is subadditive under biproduct decomposition of the "component theories."
(c) For a Deligne tensor product C ⊠ D of finite semisimple categories, pc(C ⊠ D) = pc(C) · pc(D).

**Test:** Verify (a) computationally for products of small categories. For (c), test with C = Rep(C₂) ⊠ Rep(C₃) over appropriate fields, expecting pc = 2 · 3 = 6.

**Impact:** Algebraic properties of probe complexity would establish it as a well-behaved invariant in the same league as dimension functions. Subadditivity under products corresponds to the physical principle that measurement complexity of composite systems is bounded by the sum of component complexities.

**Catalog References:** `Pythagorean/ProbeComplexity/CategoricalDimension.lean` — `categoryProbeComplexity_le_card`, `PrecomposeSeparatingFamily.superset`. Also `Catalog/Pythagorean/ProbeComplexity/CoproductSubadditivity.lean` (existing coproduct results).

**Proof Strategy:** For (a), if S separates C and T separates D, show that {(P, 0) : P ∈ S} ∪ {(0, Q) : Q ∈ T} separates C × D by testing each component separately. For (c), use the tensor product structure of simples in C ⊠ D.

**Domain Bridges:** Tensor categories (Deligne products, fusion categories), quantum information (composite system measurement), algebraic K-theory (additive invariants).

**Lineage:** Extends the structural theory of probe complexity beyond single-category computations.

**Ambition:** Solid extension — the product subadditivity should follow from straightforward categorical arguments, while the tensor product formula requires deeper structural theory.

---

## Direction 5: Categorical Compressed Sensing and Approximate Recovery

**Conjecture:** For a category C with pc(C) = n, using only k < n probes (a "compressed" probe set), the profile map has image of size at most ∏ᵢ |Hom(Pᵢ, Y)|^|Hom(Pᵢ, X)| (the capacity bound from `card_hom_le_profile_capacity`), and the fraction of morphism pairs that can still be distinguished is bounded below by a function of k/n.

**Test:** In Rep(S₃) over 𝔽₇ (pc = 3), measure the fraction of morphism pairs distinguished by probe sets of size 1 and 2. Plot the "discrimination curve" as a function of k/n for several groups.

**Impact:** This would initiate a theory of *categorical compressed sensing*: reconstructing morphisms from incomplete probe data. The discrimination curve would be the categorical analogue of the restricted isometry property in classical compressed sensing.

**Catalog References:** `Catalog/Pythagorean/ProbeComplexity/Theorems.lean` — `card_hom_le_profile_capacity`, `single_probe_capacity_bound`.

**Proof Strategy:** Use the information-theoretic capacity bound to establish upper bounds on distinguishing power. For lower bounds, use probabilistic arguments: a random morphism pair is distinguished by a random probe with probability at least 1/n (if probes are drawn from the simple probe basis and the category is semisimple).

**Domain Bridges:** Compressed sensing (restricted isometry, sparse recovery), information theory (channel capacity, rate-distortion), quantum tomography (incomplete measurements, shadow tomography).

**Lineage:** Extends the information-theoretic capacity bound from the catalog into a quantitative theory of partial reconstruction.

**Ambition:** Grand challenge — this would create a new subfield connecting categorical algebra to signal processing and information theory, with potential applications to quantum computing and machine learning.
