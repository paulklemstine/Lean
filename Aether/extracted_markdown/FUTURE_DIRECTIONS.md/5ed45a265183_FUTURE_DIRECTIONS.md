# Future Directions: Tropical Orbit Complexity

## Overview

This document outlines five concrete research directions opened by the formalization of tropical orbit complexity from spectral data. Each direction includes precise theorem statements, proof strategies, and cross-domain significance.

---

## Direction 1: Eventual Periodicity of Normalized Tropical Orbits

### Conjecture

**Theorem (Eventual Periodicity).** For every `n ≥ 1` and every irreducible tropical matrix `G : Matrix (Fin n) (Fin n) ℤ` with tropical spectral radius `ρ`, there exist `T, p ∈ ℕ` with `p ≥ 1` such that for all `k ≥ T`:

```
normalizedTropPow G ρ (k + p) = normalizedTropPow G ρ k
```

### Lean 4 Signature

```lean
theorem normalized_orbit_eventually_periodic
    {n : ℕ} [NeZero n]
    (G : Matrix (Fin n) (Fin n) ℤ)
    (ρ : ℤ)
    (hirr : TropIrreducible G)
    (hbound : ∀ k : ℕ, 1 ≤ k →
      ∀ i j : Fin n, |tropPow G k i j - (k : ℤ) * ρ| ≤ C) :
    ∃ T p : ℕ, 0 < p ∧ ∀ k : ℕ, T ≤ k →
      normalizedTropPow G ρ (k + p) = normalizedTropPow G ρ k
```

### Proof Strategy

1. By `orbit_card_bound_of_box_bound`, the normalized orbit is finite.
2. By the pigeonhole principle, there exist `k₁ < k₂` with `normalizedTropPow G ρ k₁ = normalizedTropPow G ρ k₂`.
3. Set `p = k₂ - k₁`. Show by induction that `normalizedTropPow G ρ (k + p) = normalizedTropPow G ρ k` for all `k ≥ k₁`.
4. The induction step uses the "tropical Cayley-Hamilton" property: if the normalized power repeats, then subsequent powers also repeat because tropical multiplication is determined by the preceding power.

### Cross-Domain Significance

- **Symbolic dynamics**: Eventually periodic orbits correspond to periodic points of the shift map, classifying the tropical matrix as a "finite-type" dynamical system.
- **Discrete event systems**: Periodic normalized orbit = periodic production schedule with constant cycle time.
- **Tropical Perron-Frobenius**: This is the tropical analogue of the classical theorem that primitive matrices have convergent normalized powers.

---

## Direction 2: Critical Graph Structure Determines Orbit Period

### Conjecture

**Theorem (Period from Critical Graph).** The period `p` in Direction 1 divides the lcm of the cyclicity indices of the strongly connected components of the critical graph of `G`.

The *critical graph* of `G` with spectral radius `ρ` consists of:
- Vertices: indices `i` participating in a cycle of mean exactly `ρ`
- Edges: arcs `(i,j)` belonging to such a critical cycle

### Lean 4 Signature

```lean
def criticalGraph {n : ℕ} [NeZero n] (G : Matrix (Fin n) (Fin n) ℤ) (ρ : ℤ) :
    SimpleGraph (Fin n) := sorry

def criticalCyclicity {n : ℕ} [NeZero n] (G : Matrix (Fin n) (Fin n) ℤ) (ρ : ℤ) : ℕ := sorry

theorem orbit_period_divides_critical_cyclicity
    {n : ℕ} [NeZero n]
    (G : Matrix (Fin n) (Fin n) ℤ) (ρ : ℤ) (p : ℕ)
    (hp : IsOrbitPeriod G ρ p) :
    p ∣ criticalCyclicity G ρ
```

### Proof Strategy

1. Define the critical graph as a `SimpleGraph (Fin n)`.
2. Compute its strongly connected components and their cyclicity (gcd of cycle lengths).
3. Show that the normalized power restricted to critical vertices has period dividing the cyclicity.
4. Extend to non-critical vertices using the "coupling time" argument: non-critical vertices eventually follow the critical component's periodic behavior.

### Cross-Domain Significance

- **Graph theory**: Connects tropical spectral theory to strongly connected component decomposition.
- **Scheduling**: Critical graph = bottleneck structure of a production network.
- **Number theory**: The cyclicity calculation involves gcd computations on cycle lengths, connecting to arithmetic of graphs.

---

## Direction 3: Tropical Topological Entropy for Matrix Semigroup Actions

### Definition and Theorem

Define the *tropical topological entropy* of a finite set of tropical matrices `{G₁, ..., Gₘ}`:

```
h_trop({G₁,...,Gₘ}) = lim sup_{N→∞} (1/N) log |{Gᵢ₁ ⊗ ... ⊗ Gᵢ_N : iⱼ ∈ {1,...,m}}|_normalized
```

where "normalized" means modding out the maximal entry.

**Theorem.** If all matrices in `{G₁, ..., Gₘ}` share a common tropical eigenvector, then `h_trop = 0`.

**Theorem.** In general, `h_trop ≤ log(m) · dim(residual state space)`.

### Lean 4 Signature

```lean
def tropSemigroupOrbit {n m : ℕ} [NeZero n]
    (generators : Fin m → Matrix (Fin n) (Fin n) ℤ) (N : ℕ) :
    Finset (Matrix (Fin n) (Fin n) ℤ) := sorry

def tropTopologicalEntropy {n m : ℕ} [NeZero n]
    (generators : Fin m → Matrix (Fin n) (Fin n) ℤ) : ℝ := sorry

theorem trop_entropy_zero_of_common_eigenvector
    {n m : ℕ} [NeZero n]
    (generators : Fin m → Matrix (Fin n) (Fin n) ℤ)
    (v : Fin n → ℤ)
    (heig : ∀ s : Fin m, ∀ i : Fin n,
      (tropMatVecMul (generators s) v) i = (eigenvalue s) + v i) :
    tropTopologicalEntropy generators = 0
```

### Proof Strategy

1. Each generator's powers are controlled by its eigenvector (Theorem B from our development).
2. Any product of generators is bounded entrywise by the sum of eigenvalues plus eigenvector gauge.
3. After normalizing by the total eigenvalue sum, entries are bounded.
4. Apply the box-counting argument (Theorem A).

### Cross-Domain Significance

- **Ergodic theory**: Tropical topological entropy is a new dynamical invariant for semigroup actions.
- **Information theory**: Measures the "surprise" or complexity of tropical matrix products.
- **Control theory**: Characterizes the complexity of switching max-plus linear systems.

---

## Direction 4: Discrete Event Systems Stability via Orbit Complexity

### Theorem

**Theorem (DES Stability from Spectral Data).** Consider a discrete event system modeled as `x(k+1) = G ⊗ x(k)` where `G` is an `n × n` tropical matrix with spectral radius `ρ` and tropical eigenvector `v`. Then:

1. The system is *asymptotically periodic*: there exist `T, p` such that `x(k+p) - x(k) = pρ · 1` for all `k ≥ T`.
2. The *transient length* `T` satisfies `T ≤ n · (2C+1)^(n²)` where `C` is the eigenvector gauge.
3. The *steady-state throughput* equals `ρ` regardless of initial condition `x(0)`.

### Lean 4 Signature

```lean
def tropDES {n : ℕ} [NeZero n] (G : Matrix (Fin n) (Fin n) ℤ) :
    ℕ → (Fin n → ℤ) → Fin n → ℤ
  | 0, x => x
  | k + 1, x => tropMatVecMul G (tropDES G k x)

theorem des_eventually_periodic
    {n : ℕ} [NeZero n]
    (G : Matrix (Fin n) (Fin n) ℤ) (v : Fin n → ℤ) (ρ : ℤ)
    (heig : ∀ i, (tropMatVecMul G v) i = ρ + v i) :
    ∀ x₀ : Fin n → ℤ, ∃ T p : ℕ, 0 < p ∧
      ∀ k ≥ T, ∀ i, tropDES G (k + p) x₀ i = tropDES G k x₀ i + p * ρ
```

### Proof Strategy

1. Extend Theorem B to state-space trajectories: `tropDES G k x₀ i ≤ kρ + C` where `C` depends on `x₀` and `v`.
2. The normalized state `x̃(k) = x(k) - kρ` lies in a bounded integer box.
3. By pigeonhole (Theorem A), the normalized state must repeat.
4. Once it repeats, periodicity follows by the deterministic nature of the dynamics.
5. Bound the transient by the box size.

### Cross-Domain Significance

- **Manufacturing**: Guarantees that production lines reach steady-state periodic operation.
- **Transportation**: Proves that timetables for synchronized systems are eventually periodic.
- **Control theory**: Provides a computable stability certificate for max-plus linear systems.

---

## Direction 5: Probabilistic Tropical Orbit Complexity via `tropical_entropy_search_bound`

### Connection to Existing Catalog

The catalog theorem `tropical_entropy_search_bound` states that for a probability distribution `p`, the reciprocal of the minimum probability equals the exponential of the tropical entropy: `1/min(p) = exp(H_⊕(p))`.

This can be extended to tropical matrix orbits by randomizing the initial condition or the matrix entries.

### Theorem

**Theorem (Random Tropical Orbit Complexity).** Let `G₁, G₂, ...` be i.i.d. random tropical matrices drawn from a distribution with finite support. Let `Π_N = G_N ⊗ ... ⊗ G₁`. Then:

1. The Lyapunov exponent `λ = lim (1/N) E[max_{i,j} Π_N(i,j)]` exists.
2. The residual complexity `h = lim sup (1/N) log |{normalized Π_N}|` satisfies `h ≤ H_⊕(support)`.
3. If the matrices share a common eigenvector, then `h = 0`.

### Lean 4 Signature

```lean
theorem random_tropical_orbit_bound
    {n m : ℕ} [NeZero n]
    (generators : Fin m → Matrix (Fin n) (Fin n) ℤ)
    (weights : Fin m → ℝ) (hpos : ∀ s, 0 < weights s)
    (hsum : ∑ s, weights s = 1) :
    ∀ N : ℕ,
      (tropSemigroupOrbit generators N).card ≤
        m ^ N * (2 * maxGauge generators + 1) ^ (n * n)
```

### Proof Strategy

1. The number of distinct products of length `N` from `m` generators is at most `m^N`.
2. Each normalized product has entries bounded by the maximum gauge.
3. The orbit is contained in the product of these sets.
4. Connect to `tropical_entropy_search_bound` by interpreting the minimum-probability event as the rarest production sequence.

### Cross-Domain Significance

- **Machine learning**: Random tropical matrix products arise in the analysis of ReLU neural networks (each layer is a tropical linear map). Our bounds control the expressivity.
- **Statistical mechanics**: The Lyapunov exponent is the free energy per site in a random max-plus polymer model. The entropy measures the number of metastable states.
- **Information theory**: Extends Shannon's entropy to tropical channel capacity.

---

## Research Team Directive

Each direction above is actionable. A research team should:

1. **Validate** each conjecture computationally on 2×2 and 3×3 examples before attempting formal proof.
2. **Build** the required infrastructure (critical graph definitions, semigroup orbit sets, DES trajectories) as Lean definitions with `sorry`-ed properties.
3. **Prove** the simplest instances first (2×2 eventual periodicity, single-generator entropy collapse).
4. **Connect** to existing Mathlib infrastructure for graph theory (connected components), combinatorics (pigeonhole), and analysis (limsup).
5. **Iterate** on failed proof attempts by decomposing into smaller lemmas, leveraging the modular structure established in this work.

The key insight enabling all five directions is the same: **tropical spectral data ↦ bounded normalized orbit ↦ finite-state dynamics**. This pipeline, now formalized, is the foundation for a complete theory of tropical dynamical complexity.
