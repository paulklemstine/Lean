# Future Directions: Tropical Radon Transform Duality

## 1. Extension to Finite Polyhedral Complexes and Sheaf Covers

**Current state:** Our theory works on finite types `X` with a global family of tropical functionals `H`.

**Next step:** Replace the finite type `X` with a **finite polyhedral complex** Σ, where each cell σ carries its own local family of tropical affine functionals H_σ. The tropical Radon transform becomes a **presheaf morphism**: for each cell, one computes the local sup-plus transform, and the reconstruction/adjoint operator glues local data via tropical compatibility conditions on cell boundaries.

**Concrete formalization target:** Define a `TropicalMeasurementSheaf` structure on a finite simplicial complex, where:
- Local sections are tropical support data on each cell.
- Restriction maps are induced by the inclusion of functional families.
- The gluing axiom corresponds exactly to the `IsTropicalSupportData` fixed-point condition on overlaps.
- Prove a **tropical sheaf gluing theorem**: compatible local tropical support data glue to a unique global section (i.e., a globally reconstructable function).

**Impact:** This would be the first formalized connection between tropical geometry and sheaf cohomology, opening the door to obstruction-theoretic analysis of inconsistent measurement data (see Direction 5).

---

## 2. Tropical Helly–Carathéodory Theorem for Measurement Minimality

**Current state:** We proved existence of a subfamily B ⊆ H that preserves injectivity on normal forms.

**Next step:** Prove a **quantitative bound** on the size of the minimal determining subfamily B, analogous to Helly's theorem for convex sets. Specifically, if `X` has `n` points, prove that at most `n` functionals from `H` suffice to determine any tropical normal-form function — and that this bound is tight.

**Concrete formalization target:**
```
theorem tropical_helly_bound (H : Finset (X → ℤ)) (hH : H.Nonempty)
    (hsep : TropicallySeparates H) :
    ∃ B : Finset (X → ℤ), B ⊆ H ∧ B.card ≤ Fintype.card X ∧
      Function.Injective (fun f : { f // IsTropicalNormalForm B ... f } =>
        fun h : B => tropicalRadon B f.1 h)
```

Additionally, prove a **tropical Carathéodory theorem**: every normal-form function `f(x) = inf_{h ∈ H}(c_h - h(x))` can be represented using at most `n` terms from the infimum.

**Impact:** This gives a tight complexity bound for tropical tomography — the number of measurements needed scales linearly with the dimension, not with the size of the functional family.

---

## 3. Stability and Noise Bounds for Approximate Tropical Radon Data

**Current state:** Our reconstruction theorem assumes exact measurement data.

**Next step:** Develop a **quantitative stability theory** for the tropical Radon transform. Given approximate data F̃ with ‖F̃ - F‖_∞ ≤ ε (in the sup-norm on H), bound the reconstruction error:

  ‖reconstruct(F̃) - reconstruct(F)‖_∞ ≤ C · ε

for an explicit constant C depending on the geometry of H.

**Concrete formalization target:**
```
theorem tropical_reconstruction_stability
    (H : Finset (X → ℤ)) (hH : H.Nonempty)
    (F G : (X → ℤ) → ℤ) (ε : ℤ)
    (hclose : ∀ h ∈ H, |F h - G h| ≤ ε) :
    ∀ x, |tropicalAdjoint H hH F x - tropicalAdjoint H hH G x| ≤ ε
```

This follows relatively easily from our monotonicity results, since the adjoint is 1-Lipschitz in the sup-norm. But the more interesting question is **when the Radon transform itself is stable** — i.e., when small changes in the function produce bounded changes in the Radon data.

**Impact:** This creates a formal foundation for **robust tropical signal processing** — reconstructing signals from noisy tropical measurements with certified error guarantees.

---

## 4. Connection to Morphological Image Operators and Tropical Compressed Sensing

**Current state:** Our sup-plus Radon transform is, in signal processing terms, a **dilation operator** from mathematical morphology.

**Next step:** Make this connection explicit by:
1. Defining the **tropical erosion** (our adjoint/reconstruction operator) and proving it forms a morphological adjunction with dilation.
2. Defining **tropical openings** (Adjoint ∘ Radon) and **tropical closings** (Radon ∘ Adjoint) and proving they are idempotent, extensive/anti-extensive operators — i.e., morphological operators in the classical sense.
3. Proving that the normal-form class consists exactly of **morphologically open** elements.

Then connect to **compressed sensing over idempotent semirings**: if we sample the Radon transform at random directions from H, how many samples suffice to reconstruct a tropical signal with bounded complexity (e.g., representable by k terms)?

**Concrete formalization target:**
```
def tropicalOpening (H : Finset (X → ℤ)) (hH : H.Nonempty) (f : X → ℤ) : X → ℤ :=
  tropicalAdjoint H hH (tropicalRadon H f)

theorem tropicalOpening_idempotent :
    tropicalOpening H hH (tropicalOpening H hH f) = tropicalOpening H hH f
```

**Impact:** This bridges formal tropical geometry with mathematical morphology (a mature field in image processing) and creates a new formalization pathway for morphological signal analysis.

---

## 5. Semiring-Valued Sheaf Cohomology for Inconsistent Projection Data

**Current state:** Our `IsTropicalSupportData` predicate characterizes *consistent* projection data.

**Next step:** When measurement data F is *not* tropical support data (i.e., Radon(Adjoint(F)) ≠ F on some h ∈ H), define a **discrepancy measure** and interpret it cohomologically.

Specifically:
1. Define the **tropical discrepancy** δ(F)(h) = F(h) - Radon(Adjoint(F))(h) ≥ 0 for h ∈ H.
2. Show that δ = 0 iff F is consistent (already follows from our image characterization).
3. Interpret δ as a **first cohomology class** of a presheaf of tropical semimodules on the measurement complex.
4. Prove that the discrepancy satisfies a **cocycle condition** when measurements are organized into overlapping subfamilies.

**Concrete formalization target:**
```
def tropicalDiscrepancy (H : Finset (X → ℤ)) (hH : H.Nonempty)
    (F : (X → ℤ) → ℤ) (h : X → ℤ) : ℤ :=
  F h - tropicalRadon H (tropicalAdjoint H hH F) h

theorem discrepancy_nonneg (h ∈ H) : 0 ≤ tropicalDiscrepancy H hH F h

theorem discrepancy_zero_iff_supportData :
    (∀ h ∈ H, tropicalDiscrepancy H hH F h = 0) ↔ IsTropicalSupportData H hH F
```

**Impact:** This would be the first formalization of **sheaf cohomology over idempotent semirings**, with immediate applications to detecting and quantifying inconsistencies in multi-sensor measurement fusion. It connects tropical geometry to **topological data analysis** in a fundamentally new way.

---

## Summary

| Direction | Difficulty | Novelty | Mathlib Readiness |
|-----------|-----------|---------|-------------------|
| 1. Polyhedral sheaves | High | Very High | Medium (needs simplicial complex API) |
| 2. Helly–Carathéodory | Medium | High | High (finite combinatorics) |
| 3. Stability bounds | Low–Medium | Medium | High (follows from monotonicity) |
| 4. Morphological operators | Medium | High | High (clean algebraic definitions) |
| 5. Sheaf cohomology | Very High | Very High | Low (needs new infrastructure) |

The recommended order is **3 → 4 → 2 → 1 → 5**, progressing from immediate extensions to deep structural innovations. Direction 3 is almost immediate from our existing results and should be formalized first as a quick win. Direction 4 reinterprets our results in a new language and creates bridges to applied mathematics. Direction 2 is the most important combinatorial extension. Directions 1 and 5 are the long-term research program that would establish tropical Radon duality as a foundational theory.
