# MASTER FUTURE DIRECTIONS — Accumulated Research Wisdom

*Last updated: 2026-05-04 19:01*

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

## 1. Congruence-Level Tropical Nullstellensatz

The current formalization establishes the set-theoretic tropical Nullstellensatz:
`tropRadical(I) = idealOfSet(tropZeroSet(I))`. The next step is to lift this to a
**congruence-level** statement. In classical algebra, the Nullstellensatz relates
ideals to varieties; in the tropical/idempotent world, the natural replacement for
ideals is **semiring congruences** (since tropical semirings lack additive inverses
and hence lack proper two-sided ideals in the classical sense).

**Concrete target**: Define a `radicalCongruence` on function semirings generated
by a finite family, and prove it equals the `vanishingCongr` of the common zero set.
The `vanishingCongr` is already defined in the current file; the missing piece is the
notion of *generated congruence* and the proof that the radical congruence is exactly
recovered from geometric data.

## 5. Algorithmic Extraction from Density Proofs

**Statement**: The constructive content of the density proof can be extracted into an explicit approximation algorithm: given f ∈ C(X × Y, ℝ) and ε > 0, compute a max-plus combination of pure tensors within ε of f.

**Approach**: The proof via the lattice Stone–Weierstrass theorem is inherently constructive — it builds approximants via two-point interpolation and finite coverings. Making this extraction explicit requires:
1. Bounding the number of terms in the tropical sum (related to covering numbers of X × Y).
2. Choosing the separating functions optimally (related to tropical rank minimization).
3. Implementing the construction as a certified algorithm in Lean with `#eval` support.

**Significance**: Bridges the gap between existence theorems and practical approximation, enabling verified numerical tropical computation.