# MASTER FUTURE DIRECTIONS — Accumulated Research Wisdom

*Last updated: 2026-05-04 20:06*

## Next Targets

### 1. Tropical Choquet Theory on Compact Spaces

**Goal**: Extend the representation theorem from finite discrete spaces to compact Hausdorff spaces.

**Approach**: Define the tropical capacity `μ_K(Λ) = inf{Λ(f) | f ≥ 0 on K}` for compact sets K, prove maxitivity `μ(K ∪ L) = max(μ(K), μ(L))` using Urysohn separation, and establish the representation `Λ(f) = sup_K (μ(K) + inf_{x ∈ K} f(x))`.

**Key challenge**: The upper-continuity hypothesis on functionals needs to be related to topological properties of the compact-open topology on `C(X, WithBot ℝ)`.

**Status**: Infrastructure for capacity (`muK`) and tropical integral (`tropicalIntegral`) is defined. The `UCTropicalFunctional` structure with upper-continuity is formalized. The functional extensionality theorem is stated but unproven.

### 2. Radon-Style Regularity for Maxitive Measures

**Goal**: Show that the maxitive capacity arising from a tropical functional is inner regular on open sets and outer regular on compact sets.

**Formalization target**:
```
∀ U : Set X, IsOpen U →
  μ(U) = sSup {μ(K) | K ⊆ U ∧ IsCompact K}
```

This would enable passage between the compact-set capacity and a full set function, paralleling the classical Riesz-Markov-Kakutani theorem.

### 3. Duality Between Tropical Ideals and Maxitive Measure Supports

**Goal**: Establish a Gelfand-type duality in the tropical setting: closed tropical ideals in `TropCont(X)` correspond to closed subsets of X via the support of maxitive measures.

**Formalization target**: Define the support of a maxitive measure as `supp(μ) = {x | μ({x}) ≠ ⊥}` and prove:
- The kernel of a tropical functional equals `{f | f|_{supp(w)} = ⊥}` in the discrete case.
- Two tropical functionals have the same support iff they agree up to tropical scalar multiple.

### 4. Categorical Functoriality of Λ ↦ μ_Λ

**Goal**: Show that the assignment sending a tropical functional to its representing measure is functorial with respect to continuous maps.

Given `φ : X → Y` continuous, define the pushforward `φ_* μ` and pullback `φ* Λ`, and prove:
- `μ_{φ* Λ} = φ_* (μ_Λ)` (the representing measure of the pullback functional is the pushforward measure).
- This is natural in the categorical sense.

### 5. Finite/Infinite Approximation with Certified Bounds

**Goal**: Given a tropical functional Λ on `C(X, WithBot ℝ)` for compact X, approximate it by finite-dimensional tropical functionals with explicit error bounds.

**Approach**: For a finite covering {U_1, ..., U_n} of X with mesh ε, construct a discrete functional Λ_ε and prove:
```
|Λ(f) - Λ_ε(f)| ≤ ω_f(ε)
```
where ω_f is the modulus of continuity of f. This gives certified reconstruction bounds.

**Application**: Certified algorithms for recovering maxitive measures from finitely many function evaluations.

## Next Theorems to Formalize

### 1. Functoriality of the Tropical Spectrum

Every continuous map `f : X → Y` between compact Hausdorff spaces induces a
pullback map `f* : A_Y → A_X` on function algebras, which in turn induces a
continuous map on tropical spectra. This should give a contravariant functor
from CompHaus to the category of tropical spectral spaces.

```
theorem tropSpec_functorial (f : C(X, Y)) :
    Continuous (tropSpecMap f) ∧ tropSpecMap (ContinuousMap.id X) = id
```

### 2. Spectral Compactness

The tropical evaluation spectrum of a compact space is compact.
This follows immediately from the homeomorphism theorem but could also
be proved directly from the definition, which would give an independent
proof of compactness of the congruence space.

```
theorem tropEvalSpec_compact [CompactSpace X] :
    @CompactSpace (TropEvalSpec A eval) (tropEvalSpecTopology A eval)
```

### 3. Spectral Semisimplicity

The intersection of all evaluation congruences is the diagonal (equality):
```
theorem tropSpec_semisimple
    (hsep : ∀ x y : X, x ≠ y → ∃ f, eval x f ≠ eval y f) :
    ⨅ x, evalCongr A eval x = ⊥
```
This formalizes the fact that the algebra detects all function-level distinctions.

### 4. Tropical Structure Sheaf

Define a structure presheaf on the tropical spectrum by assigning to each
open set the algebra of "tropical regular functions" — sections of the
natural projection from the function algebra. Prove it satisfies the sheaf
condition.

```
def tropStructureSheaf : TopCat.Presheaf (Type*) (tropSpecTop A eval)
theorem tropStructureSheaf_isSheaf : tropStructureSheaf.IsSheaf
```

### 5. Tropical Stone–Weierstrass on the Spectrum

Show that the density results from tropical Stone–Weierstrass translate
to a statement about the spectrum: every closed set in the spectrum is
an intersection of tropical vanishing loci. This connects approximation
theory to spectral geometry.

```
theorem tropVanishPair_generates_closed :
    ∀ s : Set (TropEvalSpec A eval),
      @IsClosed _ (tropEvalSpecTopology A eval) s ↔
        ∃ I : Set (A × A), s = ⋂ p ∈ I, tropVanishPair A eval p.1 p.2
```