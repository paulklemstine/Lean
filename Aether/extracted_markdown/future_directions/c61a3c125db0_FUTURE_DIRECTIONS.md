# Future Directions: Voice-Leading Geometry

## Overview

This document outlines five concrete research directions opened by the verified metric theory of four-voice harmonic motion. Each direction includes an exact theorem target, formalization strategy, and cross-domain connections.

---

## Direction 1: n-Voice Generalization

### Theorem Target

```lean
noncomputable def vlCostN {n : ℕ} (x y : Fin n → ℤ) : ℕ :=
  Finset.inf' Finset.univ ⟨1, Finset.mem_univ 1⟩
    (fun σ : Equiv.Perm (Fin n) => ∑ i, Int.natAbs (x i - y (σ i)))

theorem vlCostN_triangle {n : ℕ} (x y z : Fin n → ℤ) :
    vlCostN x z ≤ vlCostN x y + vlCostN y z

theorem vlCostN_sorted_optimal {n : ℕ} (x y : Fin n → ℤ)
    (hx : Monotone x) (hy : Monotone y) :
    vlCostN x y = ∑ i, Int.natAbs (x i - y i)
```

### Proof Strategy Ideas

1. **Direct generalization:** The proofs for Fin 4 already use abstract lemmas (`Equiv.sum_comp`, `Finset.inf'_le`, pointwise triangle inequality). Lift these to Fin n by replacing `Fin 4`-specific case analysis with induction or abstract permutation arguments. The triangle inequality proof generalizes directly. The sorted optimality proof requires replacing `fin_cases` with an inductive uncrossing argument: show that any permutation with a crossing (σ(i) > σ(j) for i < j) can be improved by a transposition, and iterate until the identity is reached.

2. **Bubble sort argument:** Prove that bubble sort on the permutation (swapping adjacent crossed pairs) monotonically decreases the cost. Since bubble sort terminates in O(n²) transpositions, this gives a constructive proof of sorted optimality. Each swap step uses `abs_swap_uncross`.

### Cross-Domain Connection

The n-voice generalization connects directly to the **Wasserstein-1 distance** on discrete measures with n atoms on the integers. The sorted matching theorem for general n is the discrete Monge optimality result, a cornerstone of optimal transport theory. This could lead to a formalized library of discrete optimal transport in Lean.

---

## Direction 2: Quotient Geometry of Chord Classes

### Theorem Target

```lean
-- Define chord equivalence: two chords are equivalent if one is a voice permutation of the other
def ChordEquiv (x y : Fin n → ℤ) : Prop :=
  ∃ σ : Equiv.Perm (Fin n), ∀ i, y i = x (σ i)

-- The quotient distance is well-defined
theorem vlCostN_quotient_well_defined {n : ℕ}
    (x₁ x₂ y₁ y₂ : Fin n → ℤ)
    (hx : ChordEquiv x₁ x₂) (hy : ChordEquiv y₁ y₂) :
    vlCostN x₁ y₁ = vlCostN x₂ y₂

-- The quotient space is a genuine metric (not just pseudometric)
theorem vlCostN_quotient_separates {n : ℕ}
    (x y : Fin n → ℤ) (h : vlCostN x y = 0) :
    ChordEquiv x y
```

### Proof Strategy Ideas

1. **Via permutation invariance:** `vlCost4_perm_invariant` already shows invariance under voice relabeling. For the quotient to be a metric (not pseudometric), we need that zero cost implies equivalence. This follows from: if vlCostN(x, y) = 0, there exists σ with Σᵢ |x(i) − y(σ(i))| = 0, hence x(i) = y(σ(i)) for all i.

2. **Sorted representative:** Define the canonical representative of a chord class as its sorted version. Show that vlCostN on sorted representatives equals vlCostN on the original chords, using permutation invariance and sorted optimality. This gives a concrete computational handle on the quotient.

### Cross-Domain Connection

The quotient space {chord classes} with the induced metric is an **orbifold** in the sense of Tymoczko's geometric music theory. Formalizing this quotient construction bridges combinatorial group theory (permutation group actions) with metric geometry, and could connect to formalized orbifold theory.

---

## Direction 3: Certified Optimal Matching Algorithm

### Theorem Target

```lean
-- A computable function that returns the optimal cost
def vlCostN_compute {n : ℕ} (x y : Fin n → ℤ) : ℕ :=
  let xs := List.mergeSort (List.ofFn x)
  let ys := List.mergeSort (List.ofFn y)
  (List.zip xs ys).foldl (fun acc (a, b) => acc + Int.natAbs (a - b)) 0

-- Correctness theorem
theorem vlCostN_compute_correct {n : ℕ} (x y : Fin n → ℤ) :
    vlCostN_compute x y = vlCostN x y
```

### Proof Strategy Ideas

1. **Sort-and-match:** Prove that sorting both inputs and matching in order gives the same result as the noncomputable infimum. This requires: (a) showing that sorting is a permutation, (b) applying permutation invariance to reduce to the sorted case, (c) applying sorted optimality. The main Lean challenge is connecting `List.mergeSort` with `Equiv.Perm` and `Finset.inf'`.

2. **Decision procedure:** For fixed small n (e.g., n = 4), use `native_decide` to verify the algorithm on all inputs up to some bound, then prove correctness abstractly for general inputs.

### Cross-Domain Connection

This connects to **certified algorithmics**: producing not just algorithms but machine-checked proofs of their correctness and complexity bounds. The O(n log n) sorting algorithm replaces the O(n!) brute force, and the correctness proof is a formal certificate. This is directly relevant to verified software for music production and algorithmic composition.

---

## Direction 4: Finite Harmonic Graph Diameter Theorem

### Theorem Target

```lean
-- Define a finite corpus of chord types (e.g., all major/minor triads + seventh chords in Fin 4 → ZMod 12)
def chordCorpus : Finset (Fin 4 → ZMod 12) := sorry -- enumerated

-- Define the chord graph: vertices = corpus, edges weighted by vlCost
-- Prove connectivity
theorem chord_graph_connected :
    ∀ x y ∈ chordCorpus, ∃ path : List (Fin 4 → ZMod 12),
      path.head? = some x ∧ path.getLast? = some y ∧
      ∀ i, (path.get? i, path.get? (i+1)) match with
        | (some a, some b) => vlCost4 a b ≤ threshold
        | _ => True

-- Prove an exact diameter bound
theorem chord_graph_diameter :
    ∀ x y ∈ chordCorpus,
      shortestPathCost x y ≤ D -- for some explicit constant D
```

### Proof Strategy Ideas

1. **Computational verification:** For small corpora (50-200 chords), compute all-pairs shortest paths by Floyd-Warshall, verify the diameter computationally, and certify the result via `native_decide` or explicit witness construction.

2. **Structural argument:** Prove that every chord in the corpus is reachable from a fixed "hub" chord (e.g., C major in root position) with bounded cost. Then the diameter is at most twice the maximum hub distance. This requires enumerating the corpus and checking reachability.

### Cross-Domain Connection

This connects to **graph theory** and **network science**. The chord graph is a small-world network (short diameter despite sparse local connectivity), and its structure encodes the navigability of harmonic space. Diameter bounds have applications in algorithmic composition (bounding the length of optimal harmonic paths) and music information retrieval (clustering chord vocabularies).

---

## Direction 5: Tropical Harmonic Composition Law

### Theorem Target

```lean
-- Define a tropical semiring of chord progression costs
-- The "product" of two progression costs is their sum
-- The "sum" of two alternatives is their minimum

-- Progression cost: minimum total voice-leading cost over a sequence of chords
noncomputable def progressionCost (chords : List Chord4) : ℕ :=
  (List.zip chords chords.tail).foldl
    (fun acc (x, y) => acc + vlCost4 x y) 0

-- Tropical composition: the cost of concatenating progressions
-- is bounded by the sum of their costs
theorem tropical_composition (p₁ p₂ : List Chord4)
    (h₁ : p₁ ≠ []) (h₂ : p₂ ≠ [])
    (hjoin : p₁.getLast h₁ = p₂.head h₂) :
    progressionCost (p₁ ++ p₂.tail) ≤
    progressionCost p₁ + progressionCost p₂

-- The tropical "shortest path" is subadditive
theorem tropical_path_subadditive (x y z : Chord4)
    (p₁ : List Chord4) (p₂ : List Chord4)
    (h₁ : p₁.head? = some x) (h₁' : p₁.getLast? = some y)
    (h₂ : p₂.head? = some y) (h₂' : p₂.getLast? = some z) :
    ∃ p : List Chord4,
      p.head? = some x ∧ p.getLast? = some z ∧
      progressionCost p ≤ progressionCost p₁ + progressionCost p₂
```

### Proof Strategy Ideas

1. **Direct concatenation:** The concatenated path p₁ ++ p₂.tail has cost equal to progressionCost(p₁) + progressionCost(p₂) minus the zero-cost self-transition at the join point. This gives a direct proof of subadditivity.

2. **Min-plus matrix formulation:** Represent the chord space as vertices of a weighted graph and define the tropical matrix product M₁ ⊗ M₂ where (M₁ ⊗ M₂)(i,j) = min_k (M₁(i,k) + M₂(k,j)). Prove that this product is associative (tropical matrix multiplication is associative in the min-plus semiring) and connects to multi-step progression costs.

### Cross-Domain Connection

This extends `tropPath_cost_compose_bound` from the existing tropical HoTT module to the voice-leading setting. The tropical semiring structure on progression costs connects to:
- **Tropical geometry:** algebraic geometry over the min-plus semifield
- **Dynamic programming:** the Bellman equation for shortest paths is tropical matrix multiplication
- **Formal language theory:** tropical semirings appear in weighted automata and the Viterbi algorithm

This direction could lead to a unified "tropical harmonic semiring" framework where chord progressions are elements of a tropical polynomial ring, and musical analysis becomes tropical algebraic geometry.

---

## Priority Ordering

1. **Direction 1** (n-voice generalization) — highest impact, most tractable
2. **Direction 3** (certified algorithm) — immediate practical value
3. **Direction 2** (quotient geometry) — conceptual depth
4. **Direction 5** (tropical composition) — novel cross-domain bridge
5. **Direction 4** (graph diameter) — requires significant computation

## Team Assignments

- **Team A (Formal Proofs):** Directions 1, 2, 3
- **Team B (Computation):** Directions 4, 5 (computational experiments)
- **Team C (Synthesis):** Cross-domain paper connecting all directions
