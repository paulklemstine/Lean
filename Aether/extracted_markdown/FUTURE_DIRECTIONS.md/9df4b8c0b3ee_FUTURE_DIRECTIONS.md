# Future Directions: Non-Abelian Arithmetic Phase Classification

## Synthesis

The results in this work establish a clean two-layer structure for torsion classification of finite groups: degree-1 torsion is fully captured by the abelianization G^ab, while degree-2 torsion requires the Schur multiplier M(G) = H₂(G, ℤ). The Q₈ vs V₄ counterexample demonstrates that this second layer is non-trivial and necessary.

The five directions below explore whether this two-layer picture is *complete* (the Monotonicity Conjecture), whether it extends to broader classes of groups (profinite, nilpotent), how it interacts with representation theory (projective representations), and what computational tools are needed to verify these predictions at scale. Together, they form a coherent research program connecting homological algebra, representation theory, computational group theory, and mathematical physics.

Each direction builds directly on the formally verified theorems in this work and the torsion detection machinery from the Catalog.

---

## Direction 1: Schur-Torsion Monotonicity Conjecture

**Conjecture:** For any finite group G and prime p dividing |G|, the detectability boundary satisfies bd(G) ≤ 2. That is, all torsion invisible to G^ab is captured by the Schur multiplier M(G) = H₂(G, ℤ) at degree exactly 2.

**Test:** Compute H_n(G, ℤ/pℤ) for n = 1, 2, 3 for all 228 groups of order ≤ 32 using the GAP HAP package. If any group has degree-3 torsion invisible to both G^ab and M(G), the conjecture is falsified. Extend to all 93 groups of order 64 for a stronger test.

**Impact:** If true, the derived torsion profile (G^ab, M(G)) is a *complete* invariant for torsion classification. This would reduce the general torsion classification problem to two computable objects. If false, the counterexample reveals new homological structure beyond the Schur multiplier.

**Catalog References:**
- `Pythagorean/AbelianizationTorsion.lean`: `grand_classification_summary` — the degree-1 completeness theorem that this conjecture extends
- `Catalog/Algebra/TorsionDetection.lean`: `tor1_vanishes_iff_no_n_torsion` — the base torsion detection mechanism

**Proof Strategy:** Use the Lyndon-Hochschild-Serre spectral sequence for 1 → [G,G] → G → G^ab → 1. The E² page has E²_{p,q} = H_p(G^ab, H_q([G,G], ℤ/pℤ)). Show that the differential d²: E²_{2,0} → E²_{0,1} maps onto the Schur multiplier, and that E³_{3,0} = 0 for all finite groups.

**Domain Bridges:** Lattice gauge theory (completeness of topological phase classification), arithmetic topology (completeness of class field tower obstructions).

**Lineage:** Extends `abelianization_torsion_transfer` from degree 1 to degree 2 completeness.

**Ambition:** Grand challenge — would be a significant contribution to group homology if proven.

---

## Direction 2: Derived Torsion Profile as Complete Invariant for Nilpotent Groups of Class ≤ 2

**Conjecture:** For finite nilpotent groups G of nilpotency class ≤ 2, the derived torsion profile (G^ab, M(G)) is a complete isomorphism invariant. That is, if G₁ and G₂ are nilpotent of class ≤ 2 with G₁^ab ≅ G₂^ab and M(G₁) ≅ M(G₂), then G₁ ≅ G₂.

**Test:** Verify for all nilpotent groups of order ≤ 64. Enumerate using GAP's `SmallGroup` library, compute abelianizations and Schur multipliers, and check for counterexamples (non-isomorphic groups with identical derived profiles). Focus on p-groups of class 2, which are the hardest case.

**Impact:** Would establish a practical classification algorithm for an important class of groups. Nilpotent groups of class ≤ 2 include all abelian groups, extra-special p-groups, and Heisenberg groups — key objects in quantum information theory.

**Catalog References:**
- `Pythagorean/AbelianizationTorsion.lean`: `comm_group_abelianization_torsion_complete` — the abelian case (nilpotency class 1)
- `Pythagorean/AbelianizationTorsion.lean`: `derivedTorsionProfileDeg1_invariant` — degree-1 invariance

**Proof Strategy:** For class-2 nilpotent groups, [G,G] ≤ Z(G) and the commutator map induces a bilinear form G^ab × G^ab → [G,G]. Show this bilinear form is determined by (G^ab, M(G)). Use the classification of alternating bilinear forms over ℤ/p^kℤ.

**Domain Bridges:** Quantum error correction (extra-special p-groups define quantum codes), Heisenberg groups in harmonic analysis.

**Lineage:** Extends `comm_group_abelianization_torsion_complete` from class 1 to class 2.

**Ambition:** Solid extension — builds directly on established theory with clear proof strategy.

---

## Direction 3: Abelianization Torsion for Profinite Groups via Inverse Limits

**Conjecture:** For a profinite group G = lim←ᵢ Gᵢ (inverse limit of finite groups), the abelianization G^ab = lim←ᵢ Gᵢ^ab captures degree-1 torsion, and the Schur multiplier M(G) = lim←ᵢ M(Gᵢ) captures degree-2 torsion. The degree-1 completeness theorem extends: if G₁^ab ≅ G₂^ab as profinite abelian groups, then the p-torsion profiles coincide at every prime.

**Test:** Verify for the p-adic integers ℤₚ = lim←ₙ ℤ/pⁿℤ, the profinite completion of the integers ℤ̂ = ∏ₚ ℤₚ, and absolute Galois groups of small number fields. Compute inverse limits of torsion profiles and check consistency.

**Impact:** Would connect the abelianization torsion theory to class field theory and the Langlands program. The abelianization of the absolute Galois group Gal(Q̄/Q) is related to the idele class group, and degree-1 torsion corresponds to abelian extensions.

**Catalog References:**
- `Pythagorean/AbelianizationTorsion.lean`: `abelianization_torsion_transfer` — the finite group case
- `Catalog/Algebra/TorsionDetection.lean`: `torsion_invisible_wrong_characteristic` — characteristic sensitivity

**Proof Strategy:** Show that the degree-1 completeness theorem commutes with inverse limits. The key technical step is showing that Abelianization(lim←ᵢ Gᵢ) ≅ lim←ᵢ Abelianization(Gᵢ), which follows from the left-exactness of inverse limits and the right-exactness of abelianization.

**Domain Bridges:** Algebraic number theory (class field theory), arithmetic geometry (étale fundamental groups), p-adic Hodge theory.

**Lineage:** Extends `abelianization_torsion_transfer` from finite groups to profinite groups.

**Ambition:** Grand challenge — would bridge formal group theory with arithmetic geometry.

---

## Direction 4: Computational Schur Multiplier via the Hopf Formula

**Conjecture:** The Hopf formula M(G) = (R ∩ [F,F]) / [R,F] for a free presentation F/R → G provides a polynomial-time algorithm for computing M(G) given a finite group presentation, with complexity O(|G|⁴) in the worst case.

**Test:** Implement the Hopf formula algorithm and benchmark against the GAP HAP package for all groups of order ≤ 128. Verify correctness against known Schur multipliers. Measure computational complexity empirically.

**Impact:** Would provide a self-contained, efficient algorithm for the degree-2 component of the derived torsion profile, completing the computational pipeline begun in this work (which currently relies on literature values for M(G)).

**Catalog References:**
- `Pythagorean/AbelianizationTorsion.lean`: `abelianizationMap` — the functorial framework for abelianization
- `Pythagorean/AbelianizationTorsion.lean`: `commutator_is_normal` — structural facts about commutator subgroups

**Proof Strategy:** Formalize the Hopf formula in Lean 4: given a free presentation G = F/R, define M(G) := (R ∩ [F,F]) / [R,F] and prove it equals H₂(G, ℤ). Use the bar resolution to connect to group homology. For the algorithm, use Todd-Coxeter coset enumeration to compute the relevant subgroups.

**Domain Bridges:** Computational algebra (efficient group algorithms), formal verification (certified computation), software engineering (verified algebraic libraries).

**Lineage:** Extends `abelianizationMap` functoriality to the homological setting.

**Ambition:** Solid extension — combines existing Lean infrastructure with well-understood mathematics.

---

## Direction 5: p-Group Torsion Determination by the Schur Multiplier

**Conjecture:** For a finite p-group G, the Schur multiplier M(G) determines the p-primary torsion in H_n(G, ℤ) for all n ≥ 2. Specifically, the Poincaré series P(G, t) = Σₙ dim_𝔽ₚ H_n(G, 𝔽ₚ) · tⁿ is determined by (G^ab, M(G)).

**Test:** Compute P(G, t) for all p-groups of order ≤ p⁵ (for p = 2, 3, 5) using the Benson-Carlson algorithm. Check whether groups with identical (G^ab, M(G)) have identical Poincaré series. Focus on the groups of order 32 (51 groups) and 64 (267 groups) for p = 2.

**Impact:** Would establish that for p-groups — the building blocks of finite group theory — the two-layer invariant (G^ab, M(G)) captures *all* cohomological torsion, not just degrees 1 and 2. This would be a major structural result in group cohomology.

**Catalog References:**
- `Pythagorean/AbelianizationTorsion.lean`: `abelianization_exponent_dvd` — exponent transfer from G to G^ab
- `Pythagorean/AbelianizationTorsion.lean`: `product_pTorsion_iff` — torsion decomposition for products

**Proof Strategy:** For p-groups, use the central series and the associated spectral sequence. The key input is the Evens-Venkov theorem: H*(G, 𝔽ₚ) is a finitely generated 𝔽ₚ-algebra, and its Krull dimension equals the p-rank of G. Show that the generators in degrees 1 and 2 (from G^ab and M(G)) generate the entire cohomology ring.

**Domain Bridges:** Modular representation theory (cohomological invariants), algebraic topology (classifying spaces), mathematical physics (anomaly classification in p-group gauge theories).

**Lineage:** Extends `abelianization_exponent_dvd` from exponent bounds to full cohomological determination.

**Ambition:** Grand challenge — would require deep homological algebra and a novel approach to the Evens-Venkov theorem.
