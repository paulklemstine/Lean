# Future Directions: Tropical Dragon Decomposition Program

This document outlines the next concrete research theorems opened by the directional decomposition theorem for tropical dragon dynamics. Each direction includes an exact theorem statement, proof strategy, and cross-domain significance.

---

## Direction 1: Probabilistic Pushforward Along the Displacement Map

### Theorem Statement

Let `μ` be a probability measure on `List Bool` (turn sequences of bounded length). The pushforward measure `μ* = wordDisp_* μ` on `ℤ × ℤ` satisfies a Bayesian factorization:

```
P(Δ = δ) = ∑_{ds : wordDisp(d₀, ds) = δ} P(ds)
```

For independent, identically distributed turns with `P(R) = p`, the pushforward can be computed via a convolution formula:

```lean
theorem pushforward_iid_convolution
    (p : ℝ) (hp : 0 < p) (hp1 : p < 1) (n : ℕ) :
    ∀ δ : ℤ × ℤ,
      pushforwardProb p 0 n δ =
      ∑ counts in validCounts n δ,
        multinomial_weight p counts
```

where `validCounts n δ` is the set of direction-count vectors `(nE, nN, nW, nS)` with `nE + nN + nW + nS = n`, `nE - nW = δ.1`, `nN - nS = δ.2`, constrained by the turn-direction coupling.

### Proof Strategy

1. Define the pushforward measure using `Finset.sum` over preimages.
2. Factor the probability of a turn sequence into per-step contributions using i.i.d. structure.
3. Use `totalDisp_as_weighted_sum` to group terms by direction counts.
4. Apply multinomial coefficient identities from Mathlib.

### Cross-Domain Significance

- **Bayesian inference**: The posterior distribution over turn sequences given an observed displacement is computed by this formula — connecting `bayes_theorem` to the displacement map.
- **Statistical mechanics**: This is a partition function over lattice walks with a displacement constraint, connecting to polymer physics.
- **Information theory**: The entropy of the pushforward measures how much information the displacement retains about the full path.

---

## Direction 2: Finite Generation of the Displacement Semigroup

### Theorem Statement

The set of all attainable displacements from words of any length, starting from any initial direction, forms a finitely generated additive subgroup of `ℤ × ℤ`:

```lean
theorem displacement_subgroup_finitely_generated :
    ∃ S : Finset (ℤ × ℤ), S.card ≤ 4 ∧
      ∀ d₀ : Dir, ∀ ds : List Bool,
        ∃ n : ℤ × ℤ → ℤ,
          totalDisp d₀ ds = ∑ v in S, n v • v
```

More precisely, since all four direction vectors generate `ℤ × ℤ`, the displacement semigroup is exactly `ℤ × ℤ` itself for words of sufficient length.

### Proof Strategy

1. Show that `{dirVec d | d : Dir}` generates `ℤ × ℤ` as an additive group (since `(1,0)` and `(0,1)` are a basis).
2. Use `exists_count_representation` to show every displacement is a non-negative integer combination.
3. Show that negative combinations are also achievable (by choosing appropriate direction sequences).
4. Connect to `idempotent_hilbert_basis_theorem`: the direction vectors form a Hilbert basis for the cone of reachable displacements.

### Cross-Domain Significance

- **Hilbert basis theory**: The four direction vectors form a Hilbert basis for the cone of non-negative-count displacements, but the full reachability question requires accounting for the turn-direction coupling.
- **Algebraic dynamics**: The displacement map `wordDisp : Free(Bool) → ℤ²` is a monoid homomorphism. Its image is a finitely generated submonoid.
- **Tropical geometry**: In tropical terms, the direction vectors are the generators of a tropical linear space, and word evaluation is a tropical polynomial map.

---

## Direction 3: Periodicity Classification and Orbit Finiteness

### Theorem Statement

A turn sequence `ds` is positionally periodic (returns the walker to its starting position) if and only if its direction-count vector satisfies two linear equations:

```lean
theorem periodic_iff_balanced_counts (d₀ : Dir) (ds : List Bool) :
    (∀ p : ℤ × ℤ, (ds.foldl applyStep ⟨p, d₀⟩).pos = p) ↔
    (dirCount d₀ ds 0 = dirCount d₀ ds 2 ∧
     dirCount d₀ ds 1 = dirCount d₀ ds 3)
```

That is: periodicity holds iff East-count equals West-count AND North-count equals South-count.

### Proof Strategy

1. Apply `fold_fixed_iff_totalDisp_eq_zero` to reduce to `totalDisp = (0,0)`.
2. Apply `totalDisp_as_weighted_sum` to express displacement in terms of counts.
3. Substitute the concrete direction vectors: `(1,0), (0,1), (-1,0), (0,-1)`.
4. The system `nE - nW = 0, nN - nS = 0` is exactly the balanced-count condition.

### Cross-Domain Significance

- **Symbolic dynamics**: Periodicity of the position map factors through a simple linear condition on letter frequencies, reducing dynamics to combinatorics.
- **Lattice models**: In polymer physics, closed lattice walks are characterized by balanced step counts — this theorem formalizes that principle.
- **Automata theory**: The periodicity criterion is decidable in O(n) time, giving an efficient oracle for the halting problem of dragon-type walkers.

---

## Direction 4: Arithmetic Separation and Divisor Gap Connections

### Theorem Statement

If two turn sequences have direction-count vectors whose difference has a component with absolute value ≥ k, then their endpoints are separated by at least k in the corresponding coordinate:

```lean
theorem displacement_separation
    (d₀ : Dir) (ds₁ ds₂ : List Bool)
    (k : ℕ)
    (h : |∑ d' : Dir, ((dirCount d₀ ds₁ d').cast - (dirCount d₀ ds₂ d').cast) * (dirVec d').1| ≥ k) :
    ∀ p : ℤ × ℤ,
      |(ds₁.foldl applyStep ⟨p, d₀⟩).pos.1 - (ds₂.foldl applyStep ⟨p, d₀⟩).pos.1| ≥ k
```

### Proof Strategy

1. Apply `foldl_applyStep_eq_add_totalDisp` to both sequences.
2. Subtract to get the separation in terms of displacement difference.
3. Apply `totalDisp_as_weighted_sum` to express in terms of counts.
4. The bound follows directly from the triangle inequality.

### Cross-Domain Significance

- **Divisor gap theorem**: Connects to the arithmetic separation principle — large gaps in direction frequencies force large spatial separations, analogous to how gaps in divisor distributions force gaps in number-theoretic functions.
- **Coding theory**: The minimum distance between displacement classes gives a Hamming-type bound on distinguishability of instruction sequences.
- **Robotics**: Provides guaranteed separation bounds for robots executing different instruction tapes — useful for collision avoidance.

---

## Direction 5: Compressed Symbolic Dynamics and Complexity Bounds

### Theorem Statement

The endpoint map `ep : List Bool → ℤ × ℤ` (for fixed initial direction) factors through the direction-count map `cnt : List Bool → ℕ⁴`:

```lean
theorem endpoint_factors_through_counts (d₀ : Dir) :
    ∃ f : (Dir → ℕ) → ℤ × ℤ,
      ∀ ds : List Bool,
        totalDisp d₀ ds = f (dirCount d₀ ds)
```

This means:
- Two words with the same direction-count vector are position-equivalent.
- The number of distinct endpoints from length-n words is at most O(n³) despite 2ⁿ possible words.
- Verifying an endpoint claim requires only the 4-integer count certificate.

### Proof Strategy

1. Define `f` as the weighted sum `f(n) = ∑ d, n(d) * dirVec(d)`.
2. Apply `totalDisp_as_weighted_sum` to show `totalDisp = f ∘ dirCount`.
3. The O(n³) bound follows from the number of non-negative integer solutions to `nE + nN + nW + nS = n`, which is `C(n+3,3)`.

### Cross-Domain Significance

- **Complexity theory**: Exponential symbolic sequences compress to polynomial endpoint certificates. This is a formal demonstration of how additive structure enables exponential compression.
- **Quantum information**: Connects to the insufficient-qubits principle — if dynamics compress to O(log n) bits of displacement data, simulating the full path may require more qubits than computing the endpoint.
- **Database theory**: Path queries in grid networks can be answered from O(1)-size summaries rather than O(n)-size traces.

---

## Program Integration

These five directions form a coherent research program:

```
                    Displacement Map
                    (Decomposition Theorem)
                         │
          ┌──────────────┼──────────────┐
          │              │              │
    Probabilistic    Algebraic     Complexity
    (Direction 1)   (Directions    (Direction 5)
                     2 & 3)
          │              │              │
    Bayesian        Periodicity    Compression
    Inference       Classification  Certificates
          │              │              │
          └──────────────┼──────────────┘
                         │
                    Separation &
                    Rigidity
                    (Direction 4)
```

The decomposition theorem is the foundation. Each direction exploits a different aspect of the factorization `dynamics = automaton × accumulator`.

---

## Implementation Priority

1. **Direction 3** (Periodicity) — most concrete, uses existing infrastructure directly.
2. **Direction 5** (Compression) — high impact, straightforward from `totalDisp_as_weighted_sum`.
3. **Direction 4** (Separation) — clean statement, uses basic analysis.
4. **Direction 2** (Finite generation) — connects to algebraic infrastructure.
5. **Direction 1** (Probabilistic) — requires probability measure infrastructure.
