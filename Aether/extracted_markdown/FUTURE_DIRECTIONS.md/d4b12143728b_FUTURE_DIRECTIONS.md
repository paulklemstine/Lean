# Future Directions: Computational Homological Algebra over ℤ

## Synthesis

The verified computation of Ext¹, Tor₁, and the exactness of induced Hom sequences over ℤ-modules opens a concrete computational pipeline for homological algebra. The torsion detection theorem (Tor₁(ℤ/nℤ, A) = 0 ⟺ A is n-torsion-free) provides a certified bridge between abstract homological invariants and concrete algebraic structure. The following directions extend this foundation toward higher derived functors, automated computation from presentations, full long exact sequences, and cross-domain applications in topology, coding theory, and physics. Each direction is designed to be falsifiable by computation and to build directly on the verified theorems in our catalog.

---

## Direction 1: Smith Normal Form Pipeline for Automated Ext/Tor Computation

**Conjecture**: For every finitely presented abelian group A ≅ ℤʳ ⊕ ⊕ᵢ ℤ/dᵢℤ (where dᵢ are the invariant factors from Smith Normal Form of the presentation matrix), the Lean-certified computation of Tor₁(ℤ/nℤ, A) and Ext¹(ℤ/nℤ, A) agrees canonically with the SNF formula:
```
Tor₁(ℤ/nℤ, A) ≅ ⊕ᵢ ℤ/gcd(n, dᵢ)ℤ
Ext¹(ℤ/nℤ, A) ≅ (ℤ/nℤ)ʳ ⊕ ⊕ᵢ ℤ/gcd(n, dᵢ)ℤ
```

**Test**: Implement a verified Smith Normal Form algorithm in Lean. For each test matrix M ∈ ℤᵐˣⁿ, compute the invariant factors, predict Tor₁ and Ext¹ via the formula, and compare with invariants extracted from the concrete resolution-based definitions. A counterexample (disagreement between SNF prediction and resolution computation) would expose either a bug in the formalization or a failure of the comparison theorem for resolutions.

**Impact**: This would transform the current manual computation into a fully automated pipeline: input a presentation matrix, output certified Ext/Tor invariants. This is the gateway to industrial-strength computational homological algebra.

**Catalog References**: `Algebra/Homology/DerivedFunctors/ExtTorBasic.lean` (Ext1_ZMod_ZMod_equiv, Tor1_ZMod_ZMod_equiv), `Algebra/Homology/DerivedFunctors/TorsionDetection.lean` (ext1_Zmod_eq_quotient, tor1_Zmod_eq_torsion)

**Proof Strategy**: Define `SmithNormalForm` as a structure with proof of equivalence to the original presentation. Prove that the direct sum decomposition commutes with Hom and tensor product. Use the existing cyclic case as the base case for induction on the number of invariant factors.

**Domain Bridges**: Algebraic topology (chain complex reduction), coding theory (syndrome classification), number theory (ideal class group computation).

**Lineage**: Extends Tor1_ZMod_ZMod_equiv and Ext1_ZMod_ZMod_equiv from cyclic modules to arbitrary finitely presented modules.

**Ambition**: Solid extension — the mathematics is well-understood, but the formalization requires substantial infrastructure (SNF algorithm + comparison theorem).

---

## Direction 2: Full Connecting Homomorphism and Six-Term Exact Sequence

**Conjecture**: For any short exact sequence 0 → M' → M → M'' → 0 of ℤ-modules, there exists a connecting homomorphism δ : Hom(M', A) → Ext¹(M'', A) such that the six-term sequence
```
0 → Hom(M'', A) → Hom(M, A) → Hom(M', A) →δ→ Ext¹(M'', A) → Ext¹(M, A) → Ext¹(M', A)
```
is exact at every term. Moreover, when M'' = ℤ/nℤ and the short exact sequence is the canonical resolution, the connecting morphism δ is identified with the natural map A/image(g*) → A/nA.

**Test**: Construct explicit short exact sequences (e.g., 0 → ℤ →(·2)→ ℤ → ℤ/2ℤ → 0) and verify exactness computationally at each of the six terms. A failure at any term would reveal an error in the connecting homomorphism construction.

**Impact**: This would complete the fundamental exact sequence in cohomology, making Lean the first proof assistant with a verified concrete long exact sequence for module categories.

**Catalog References**: `Algebra/Homology/DerivedFunctors/TorsionDetection.lean` (hom_left_exact_injective, hom_exact_at_middle), `Algebra/Homology/DerivedFunctors/LongExactSequence.lean` (connecting_homomorphism_exists, snake_lemma_ker_exact)

**Proof Strategy**: Define the connecting homomorphism by: given φ : M' → A, lift to M → A via the SES, then compose with the resolution map and project to Ext¹. Use the snake lemma (partially formalized in LongExactSequence.lean) for exactness.

**Domain Bridges**: Algebraic topology (Mayer-Vietoris sequences), representation theory (extension groups), algebraic K-theory.

**Lineage**: Directly extends hom_left_exact_injective and hom_exact_at_middle to the full six-term sequence.

**Ambition**: Grand challenge — the connecting homomorphism requires careful well-definedness arguments and naturality proofs.

---

## Direction 3: Universal Coefficient Theorem with Splitting

**Conjecture**: For any chain complex C of finitely generated free abelian groups and any abelian group A, the short exact sequence
```
0 → Hₙ(C) ⊗ A → Hₙ(C; A) → Tor₁(Hₙ₋₁(C), A) → 0
```
splits (non-naturally). Consequently:
```
Hₙ(C; A) ≅ (Hₙ(C) ⊗ A) ⊕ Tor₁(Hₙ₋₁(C), A)
```
as abelian groups.

**Test**: Construct explicit chain complexes (e.g., the cellular chain complex of RP² or Klein bottle) and verify computationally that the predicted splitting agrees with direct computation of homology with coefficients. A counterexample would challenge the splitting claim.

**Impact**: The UCT with splitting is the central computational tool of algebraic topology. Its formalization would enable verified computation of homology for all CW-complexes.

**Catalog References**: `Algebra/Homology/DerivedFunctors/UniversalCoefficient.lean` (uct_concrete_H0, uct_concrete_H1), `Algebra/Homology/DerivedFunctors/TorsionDetection.lean` (tor1_Zmod_eq_torsion)

**Proof Strategy**: Define `ConcreteChainComplex` as a sequence of free modules with boundary maps. Compute homology as quotient groups. Define homology with coefficients by tensoring the chain complex. Prove the UCT by constructing the explicit split via a choice of section (using the free module hypothesis).

**Domain Bridges**: Topological data analysis (persistent homology with coefficients), computational topology (simplicial/CW homology), algebraic topology.

**Lineage**: Extends uct_concrete_H0 and uct_concrete_H1 from the trivial chain complex to general chain complexes.

**Ambition**: Grand challenge — requires substantial chain complex infrastructure and careful handling of the non-natural splitting.

---

## Direction 4: Persistent Torsion Detection for TDA

**Conjecture**: For a filtered simplicial complex K with persistence module H_*(K; ℤ), the torsion detection theorem can be applied pointwise to identify intervals where torsion appears and disappears. Specifically, for each filtration parameter t and prime p:
```
Tor₁(ℤ/pℤ, Hₖ(Kₜ)) ≠ 0  ⟺  Kₜ has p-torsion in degree k
```
These torsion intervals form a "torsion barcode" that is invisible to standard persistent homology over fields.

**Test**: Implement torsion barcode computation for triangulated surfaces (torus, RP², Klein bottle) with explicit filtrations. Verify that the torsion barcode agrees with known homological structure. Compare with field-coefficient barcodes to demonstrate the additional information captured.

**Impact**: This would create the first verified torsion-aware persistent homology pipeline, addressing a major gap in topological data analysis.

**Catalog References**: `Algebra/Homology/DerivedFunctors/TorsionDetection.lean` (tor1_vanishes_iff_no_n_torsion, tor1_Zmod_free_vanishes_via_torsion)

**Proof Strategy**: Define persistence modules over ℤ. Apply the torsion detection theorem at each filtration step. Use the functoriality of Tor₁ to track torsion across filtration levels.

**Domain Bridges**: Topological data analysis, computational geometry, materials science.

**Lineage**: Applies tor1_vanishes_iff_no_n_torsion to families of spaces parametrized by a filtration.

**Ambition**: Solid extension — mathematically straightforward but computationally significant.

---

## Direction 5: Ext-Tor Duality and Classification of Extensions

**Conjecture**: For finitely generated abelian groups M and A, there is a natural bijection between:
1. Equivalence classes of extensions 0 → A → E → M → 0 (Baer sum structure)
2. Ext¹(M, A) as computed by the resolution-based definition

Moreover, this bijection is an isomorphism of abelian groups (where extensions have the Baer sum operation).

**Test**: For M = ℤ/nℤ and A = ℤ/mℤ, enumerate all extensions (there are gcd(n,m) of them up to equivalence) and verify that the enumeration agrees with our computed Ext¹(ℤ/nℤ, ℤ/mℤ) ≅ ℤ/gcd(n,m)ℤ. A mismatch would indicate an error in either the resolution-based definition or the extension classification.

**Impact**: This would bridge the "resolution" and "extension" perspectives on Ext, providing two independent verification paths for derived functor computations.

**Catalog References**: `Algebra/Homology/DerivedFunctors/ExtTorBasic.lean` (Ext1_ZMod_ZMod_equiv, Ext0_eq_nTorsion)

**Proof Strategy**: Define `Extension M A` as a structure with proof data. Define Baer sum explicitly. Construct the bijection by sending an extension 0 → A → E → ℤ/nℤ → 0 to the image of a chosen lift of 1 ∈ ℤ/nℤ in A/nA.

**Domain Bridges**: Representation theory (group extensions), algebraic number theory (class field theory), homological dimension theory.

**Lineage**: Provides an independent characterization of Ext1_ZMod that validates the resolution-based computation.

**Ambition**: Grand challenge — requires sophisticated quotient/setoid engineering and careful treatment of equivalence classes.
