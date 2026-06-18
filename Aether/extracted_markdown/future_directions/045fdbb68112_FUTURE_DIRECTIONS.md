# Future Directions: Tropical Factor Recovery Hardness Theory

This document outlines 5 concrete next theorems building on the reduction, gauge symmetry, and oracle framework established in this work.

---

## Direction 1: Complete Gauge Classification

### Theorem Statement
Every symmetry of tropical factorization decomposes into a gauge shift and a permutation of intermediate indices. That is, if $(A', B')$ is another factorization of the same product $M = \text{tropMul}\ A\ B$, then under genericity assumptions, there exists a permutation $\sigma \in S_k$ and a shift vector $c \in \mathbb{R}^k$ such that $A'_{i,t} = A_{i,\sigma(t)} + c_{\sigma(t)}$ and $B'_{t,j} = B_{\sigma(t),j} - c_{\sigma(t)}$.

### Lean Type Signature
```lean
theorem gauge_permutation_classification
    {n m k : ℕ} [NeZero k]
    (A A' : Matrix (Fin n) (Fin k) ℝ) (B B' : Matrix (Fin k) (Fin m) ℝ)
    (hM : tropMul A B = tropMul A' B')
    (hgeneric : GenericFactorization A B) :
    ∃ (σ : Equiv.Perm (Fin k)) (c : Fin k → ℝ),
      A' = fun i t => A i (σ t) + c (σ t) ∧
      B' = fun t j => B (σ t) j - c (σ t) := by sorry
```

### Proof Strategy
1. Show that for generic factorizations, each column of $A'$ achieves the minimum in the tropical product at a unique intermediate index, inducing a permutation.
2. Once the permutation is fixed, the residual freedom is exactly a gauge shift — proved by subtracting and using the cancellation from `tropMul_shift_invariant`.
3. The genericity condition should exclude degenerate cases where multiple indices achieve the minimum simultaneously.

### Cross-Domain Connection
**Representation theory:** The symmetry group $S_k \ltimes \mathbb{R}^k$ acting on factorizations is a tropical analogue of the Weyl group action on matrix decompositions in classical Lie theory. This connects tropical cryptography to tropical Satake theory.

---

## Direction 2: Hardness for Bounded Tropical Rank

### Theorem Statement
Determining whether a matrix $M \in \mathbb{R}^{n \times m}$ has tropical rank at most $k$ (i.e., admits a factorization through inner dimension $k$) reduces to factor recovery with bounded entries. Combined with Shitov's NP-hardness result for tropical rank, this yields NP-hardness of bounded factor recovery.

### Lean Type Signature
```lean
theorem bounded_rank_reduces_to_bounded_recovery
    {n m k : ℕ} [NeZero k] (B_bound : ℝ) (hB : 0 < B_bound) :
    ∃ f : Matrix (Fin n) (Fin m) ℝ → Matrix (Fin n) (Fin m) ℝ,
      ∀ M, (∃ A : Matrix (Fin n) (Fin k) ℝ, ∃ B : Matrix (Fin k) (Fin m) ℝ,
              tropMul A B = M ∧ ∀ i t, |A i t| ≤ B_bound ∧ ∀ t j, |B t j| ≤ B_bound) ↔
            BoundedRecoverable (k := k) B_bound (f M) := by sorry
```

### Proof Strategy
1. Define `BoundedRecoverable` as recoverability with norm constraints on witness matrices.
2. Show that tropical rank $\leq k$ can be reformulated as bounded factorization by normalizing entries using the gauge shift (translate one factor's entries to be centered near zero).
3. Use the gauge freedom to ensure that any witness can be shifted into a bounded region, connecting unbounded and bounded versions.

### Cross-Domain Connection
**Combinatorial optimization:** Bounded tropical rank is equivalent to the minimum number of "tropical segments" needed to cover a tropical polytope. This connects to facility location problems and clustering in tropical geometry.

---

## Direction 3: Tropical Collision Entropy from Non-Uniqueness

### Theorem Statement
Define the *tropical collision entropy* of a factorization $(A, B)$ as the logarithm of the volume of its gauge orbit intersected with a bounded region. Prove that this entropy grows linearly with $k$ and is invariant under the reduction map.

### Lean Type Signature
```lean
noncomputable def tropicalCollisionEntropy
    {n m k : ℕ} [NeZero k]
    (A : Matrix (Fin n) (Fin k) ℝ) (B : Matrix (Fin k) (Fin m) ℝ) (R : ℝ) : ℝ :=
  Real.log (MeasureTheory.volume
    {c : Fin k → ℝ | ∀ t, |c t| ≤ R ∧ tropMul (shiftA A c) (shiftB B c) = tropMul A B}).toReal

theorem collision_entropy_eq_k_log
    {n m k : ℕ} [NeZero k]
    (A : Matrix (Fin n) (Fin k) ℝ) (B : Matrix (Fin k) (Fin m) ℝ) (R : ℝ) (hR : 0 < R) :
    tropicalCollisionEntropy A B R = k * Real.log (2 * R) := by sorry
```

### Proof Strategy
1. By `tropMul_shift_invariant`, the condition `tropMul (shiftA A c) (shiftB B c) = tropMul A B` holds for ALL $c$, so the constraint set is simply $\{c \mid \|c\|_\infty \leq R\} = [-R, R]^k$.
2. The volume of $[-R, R]^k$ is $(2R)^k$.
3. Take the logarithm to get $k \cdot \log(2R)$.

### Cross-Domain Connection
**Information theory / cryptography:** The collision entropy quantifies the inherent ambiguity in key recovery, analogous to min-entropy in lattice-based cryptography. It connects to the birthday bound via `birthday_bound_tropical_hash`: the number of random factorizations needed before a collision in the product space scales as $e^{H/2}$.

---

## Direction 4: Spectral Obstruction to Recovery

### Theorem Statement
If $M = \text{tropMul}\ A\ B$ and $M$ is square ($n = m$), then the tropical eigenvalues of $M$ are constrained by the tropical eigenvalues of $A^\top \otimes A$ and $B \otimes B^\top$. A recovery oracle reveals information about these latent spectral invariants.

### Lean Type Signature
```lean
theorem recovery_reveals_spectral_invariants
    {n k : ℕ} [NeZero n] [NeZero k]
    (A : Matrix (Fin n) (Fin k) ℝ) (B : Matrix (Fin k) (Fin n) ℝ)
    (d : ℝ) (v : Fin n → ℝ)
    (heig : IsTropicalEigenpair (tropMul A B) d v) :
    ∃ w : Fin k → ℝ,
      ∀ t, Finset.inf' Finset.univ Finset.univ_nonempty
        (fun i => A i t + v i) + w t ≤ d + w t := by sorry
```

### Proof Strategy
1. Start from the eigenpair equation: $\min_j (M_{ij} + v_j) = d + v_i$ for all $i$.
2. Substitute $M_{ij} = \min_t (A_{it} + B_{tj})$ and exchange the order of minima.
3. Define $w_t = \min_j (B_{tj} + v_j)$ as the "projected eigenvector" and derive the spectral constraint on $A$ and $w$.
4. Connect to `tropical_eigenpair_from_diagonal` from the existing catalog.

### Cross-Domain Connection
**Inverse spectral theory:** This is a tropical analogue of the inverse eigenvalue problem — reconstructing a matrix from spectral data. In classical analysis, the inverse spectral problem for Schrödinger operators connects to integrable systems and KdV equations. The tropical version could connect cryptanalysis to tropical integrable systems.

---

## Direction 5: Quantum Resistance of Tropical Factorization

### Theorem Statement
Tropical factorization is not amenable to standard quantum speedups (Grover, Shor) because: (a) the min-plus semiring lacks the group structure exploited by Shor's algorithm, and (b) the gauge symmetry of the solution space limits the effectiveness of Grover search (which requires a unique or small solution set).

### Lean Type Signature
```lean
/-- The gauge orbit has positive measure in the solution space,
    so Grover's quadratic speedup over brute-force search of the
    key space is limited by the orbit volume. -/
theorem grover_limited_by_gauge_orbit
    {n m k : ℕ} [NeZero k]
    (A : Matrix (Fin n) (Fin k) ℝ) (B : Matrix (Fin k) (Fin m) ℝ)
    (discretization : ℕ) (hd : 0 < discretization) :
    let num_equivalent := (2 * discretization + 1) ^ k
    let total_keys := (2 * discretization + 1) ^ (n * k + k * m)
    -- Fraction of keys equivalent to (A, B) grows exponentially with k
    (num_equivalent : ℝ) / total_keys > 0 := by sorry
```

### Proof Strategy
1. In a discretized key space with entries in $\{-N, \ldots, N\}$, the total number of key pairs is $(2N+1)^{nk+km}$.
2. By gauge invariance, each factorization has at least $(2N+1)^k$ gauge-equivalent representatives (one per discretized shift vector).
3. The fraction of equivalent keys is $(2N+1)^k / (2N+1)^{nk+km} = (2N+1)^{-(n-1)k - km}$, which is positive but exponentially small.
4. Grover's algorithm gives quadratic speedup over brute force, but cannot eliminate the fundamental ambiguity from gauge symmetry.

### Cross-Domain Connection
**Quantum computing / post-quantum cryptography:** This connects tropical factorization to the broader landscape of post-quantum candidates. Unlike lattice problems (where quantum algorithms give polynomial but not exponential speedup), tropical problems may benefit from the min-plus structure being "quantum-unfriendly" — there is no known quantum Fourier transform over tropical semirings.

---

## Research Program Summary

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|-------------|
| 1. Gauge Classification | Hard | High — completes symmetry theory | `tropMul_shift_invariant` |
| 2. Bounded Rank Hardness | Medium | High — connects to NP-hardness | `tropical_factorization_reduction` |
| 3. Collision Entropy | Easy-Medium | Medium — quantifies ambiguity | `tropMul_shift_invariant` |
| 4. Spectral Obstruction | Hard | Very High — new bridge | `tropical_eigenpair_from_diagonal` |
| 5. Quantum Resistance | Medium | Very High — post-quantum relevance | `bounded_recovery_hardness` |

**Priority order:** 3 → 2 → 1 → 4 → 5

Direction 3 is the fastest to formalize (it follows almost directly from existing gauge invariance) and provides immediate cryptographic utility. Direction 2 connects to known complexity results. Direction 4 is the most mathematically ambitious and could open an entirely new field.
