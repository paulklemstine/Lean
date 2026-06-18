# Summary of changes for run 3560c877-6803-4b7e-bcba-506852175b9a
## Completed: Derived Persistence Theory — Secondary Torsion Obstructions

### Lean 4 Formalization (Pythagorean/DerivedPersistence/Basic.lean)

**Zero `sorry` statements — all proofs fully verified.** The file contains ~300 lines of Lean 4 code with Mathlib, defining the algebraic foundation for derived persistence theory and proving 8 theorems:

**Core Definitions:**
- `nTors n A` — the n-torsion subgroup of an abelian group A (≅ Tor₁(ℤ/nℤ, A))
- `SES A B C` — short exact sequences of abelian groups
- `liftableTorsion S n` — torsion elements of C that lift to torsion in B
- `hasSecondaryObstruction S n` — existence of non-liftable torsion
- `SESMorphism` — morphisms of short exact sequences

**Proven Theorems (all sorry-free, standard axioms only):**

1. **`torsion_restriction_injective`** — The restricted map ι: T_n(A) → T_n(B) is injective
2. **`torsion_seq_exact_at_middle`** — The sequence T_n(A) → T_n(B) → T_n(C) is exact at T_n(B)
3. **`split_implies_no_secondary_obstruction`** — Split SES ⟹ no secondary obstruction (Theorem A)
4. **`torsion_lift_functorial`** — Liftable torsion maps forward under SES morphisms (Theorem B / functoriality)
5. **`secondary_obstruction_Z4_nontrivial`** — The SES 0 → ℤ/2ℤ → ℤ/4ℤ → ℤ/2ℤ → 0 has nontrivial 2-torsion obstruction (Theorem C / computational witness)
6. **`Z4_SES_nonsplit`** — The ℤ/4ℤ extension does not split
7. **`split_torsion_decomposition`** — Split SES gives T_n(B) ≅ T_n(A) × T_n(C) decomposition (Theorem D)
8. **`no_obstruction_iff_torsion_surjective`** — Characterization: obstruction vanishes iff torsion lifts surjectively

### Deliverables Produced

1. **ARTICLE.md** — 2000+ word popular science article explaining derived persistence for general audiences (no mention of Lean or formal verification)
2. **RESEARCH_PAPER.md** — 5000+ word research paper with abstract, full theorem statements, proof sketches, algorithms, computational experiments, and references
3. **FUTURE_DIRECTIONS.md** — 5 structured research directions including 2 grand challenges (spectral sequence page-2 identification, primewise collapse criterion) and 3 extensions
4. **demo.py** — Interactive Python demonstration with 4 examples: ℤ/4ℤ extension, general p²-extensions, mapping torus analysis, systematic obstruction search
5. **algorithms.py** — 6 algorithms with complexity analysis: torsion subgroup computation, SES analysis, secondary obstruction detection, census, primewise decomposition, two-step filtered complex analysis
6. **applications.py** — 3 applications: torsion-sensitive TDA descriptors, extension classification, anomaly detection
7. **PACKAGE.json** — Complete JSON data package bundling all deliverables

### Mathematical Significance

The central result is that **persistent homology has a secondary derived layer**: the torsion of a filtered group is not determined by the torsion of its associated graded pieces. The secondary torsion obstruction captures this discrepancy, is functorial under filtered maps, and is computationally witnessed by the ℤ/4ℤ extension. This establishes the algebraic foundation for "derived TDA" — torsion-sensitive persistence that goes beyond first-order Tor₁ detection. The work builds on the catalog theorems `Tor1_ZMod_ZMod_equiv` and `Ext1_ZMod_ZMod_equiv` from `Catalog/Algebra/Homology/DerivedFunctors/`.