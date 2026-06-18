# Future Directions: Tropical Riesz Representation Theory

## Completed Results

This project establishes the **Discrete Tropical Riesz Representation Theorem**: every max-plus linear functional on continuous functions over a finite discrete space is uniquely represented as a tropical (Shilkret) integral against a weight function. This is formally verified in Lean 4 with Mathlib.

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

## Connections to Broader Research

- **Tropical probability**: The representing weight function is a tropical probability measure (Maslov measure). This opens the door to tropical expectation, tropical entropy, and tropical information theory.
- **Dynamic programming**: Bellman operators are min-plus functionals. The Riesz theorem provides a canonical decomposition of value functions.
- **Optimization**: The theorem gives algorithmic normal forms for max-plus linear optimization problems.
- **Tropical geometry**: Maxitive measures on tropical varieties could provide a measure-theoretic approach to tropical intersection theory.
