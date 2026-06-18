# Future Directions: Tropical Convex Analysis

## Overview

The formal proof of the tropical Carathéodory theorem establishes the first machine-verified structural theorem for max-plus convexity. This opens a systematic program for formalizing tropical convex analysis, with implications for optimization, verification, game theory, and control.

---

## Direction 1: Tropical Fenchel–Moreau Biconjugation

### Statement

In classical convex analysis, the Fenchel–Moreau theorem states that a lower semicontinuous convex function equals its biconjugate. The tropical analogue states: a function f : ℝⁿ → ℝ ∪ {+∞} that is the supremum of a finite family of max-plus linear forms equals its tropical biconjugate.

**Precise theorem:** Let f : Fin n → ℝ be defined as f(i) = sup_j (c_j + V_j(i)). Define the tropical Legendre transform:

- f*(a) = inf_i (f(i) - a(i))
- f**(i) = sup_a (f*(a) + a(i))

Then f** = f.

### Expected Lean Signature

```lean
noncomputable def tropLegendre {n : ℕ} [NeZero n]
    (f : Fin n → ℝ) : (Fin n → ℝ) → ℝ :=
  fun a => Finset.univ.inf' Finset.univ_nonempty (fun i => f i - a i)

noncomputable def tropBiconj {n : ℕ} [NeZero n]
    (f : Fin n → ℝ) : Fin n → ℝ :=
  fun i => ⨆ (a : Fin n → ℝ), tropLegendre f a + a i

theorem tropical_fenchel_moreau {n m : ℕ} [NeZero n] [NeZero m]
    (V : Fin m → Fin n → ℝ) (c : Fin m → ℝ)
    (f : Fin n → ℝ) (hf : f = tropLinComb V c) :
    tropBiconj f = f := by sorry
```

### Proof Strategy

1. Show f* is the infimal convolution of the dual generators.
2. Show f** recovers the max envelope by duality.
3. The key step uses the tropical Young inequality (already in the catalog) as the bridge between primal and dual bounds.

### Cross-Domain Significance

- **Optimization:** Foundation for tropical LP duality (strong duality for max-plus linear programs).
- **Mirror symmetry:** Connects tropical Legendre transforms to the Legendre–Fenchel theory central to optimal transport.
- **Information theory:** Tropical Legendre transforms arise in rate-distortion theory and large deviation principles.

---

## Direction 2: Tropical Hahn–Banach Separation

### Statement

If x does not belong to a finitely generated tropical convex set C ⊆ ℝⁿ, then there exists a tropical linear functional separating x from C: a vector c ∈ ℝⁿ such that

max_i (c_i + y_i) ≤ max_i (c_i + x_i)  for all y ∈ C

with strict inequality possible.

### Expected Lean Signature

```lean
def tropHullSet {n m : ℕ} [NeZero m]
    (V : Fin m → Fin n → ℝ) : Set (Fin n → ℝ) :=
  {x | ∃ c : Fin m → ℝ, tropLinComb V c = x}

theorem tropical_separation {n m : ℕ} [NeZero n] [NeZero m]
    (V : Fin m → Fin n → ℝ) (x : Fin n → ℝ)
    (hx : x ∉ tropHullSet V) :
    ∃ c : Fin n → ℝ,
      ∀ y ∈ tropHullSet V,
        tropFunctional c y ≤ tropFunctional c x := by sorry
```

### Proof Strategy

1. Characterize tropical hull membership via feasibility of a system of max-plus inequalities.
2. If x ∉ tropHull, there exists a coordinate i and a "witness direction" where x exceeds all generators.
3. Construct the separating functional from the infeasibility certificate (dual of the max-plus LP).
4. The tropical Carathéodory theorem simplifies the argument by reducing to n+1 generators.

### Cross-Domain Significance

- **Verification:** Provides machine-checkable certificates of non-membership in tropical polyhedra.
- **Game theory:** Separation corresponds to existence of winning strategies in mean-payoff games.
- **Control theory:** Safety certificates for max-plus dynamical systems.

---

## Direction 3: Tropical Helly–Radon–Tverberg Hierarchy

### Statement

**Tropical Helly:** For a family of tropical halfspaces in ℝⁿ, if every n+1 of them have nonempty intersection, then the whole family does.

**Tropical Radon:** Any n+2 points in ℝⁿ can be partitioned into two sets whose tropical convex hulls intersect.

### Expected Lean Signatures

```lean
theorem tropical_helly {n m : ℕ} [NeZero n]
    (H : Fin m → Set (Fin n → ℝ))
    (hhalf : ∀ j, ∃ a b : Fin n → ℝ, H j = tropHalfspace a b)
    (hsmall : ∀ I : Finset (Fin m), I.card ≤ n + 1 →
      (⋂ j ∈ I, H j).Nonempty) :
    (⋂ j, H j).Nonempty := by sorry

theorem tropical_radon {n : ℕ} [NeZero n]
    (P : Fin (n + 2) → Fin n → ℝ) :
    ∃ (A B : Finset (Fin (n + 2))),
      A ∪ B = Finset.univ ∧ Disjoint A B ∧
      (tropHullFinset A P ∩ tropHullFinset B P).Nonempty := by sorry
```

### Proof Strategy

- **Helly:** Use the tropical Carathéodory theorem as the base case. Apply a dimension-reduction argument: intersect with coordinate hyperplanes to reduce to lower-dimensional tropical Helly.
- **Radon:** Apply tropical Carathéodory to a projective lifting. The n+2 bound comes from the pigeonhole principle on tropical active sets.

### Cross-Domain Significance

- **Combinatorial optimization:** Helly-type theorems give LP feasibility conditions.
- **Topology:** Tropical Radon/Tverberg connect to topological combinatorics (Borsuk–Ulam type results).
- **Machine learning:** Intersection theorems for tropical polyhedra relate to expressiveness of ReLU networks.

---

## Direction 4: Algorithmic Extraction of Sparse Tropical Certificates

### Statement

Given a tropical linear program max{⟨c, x⟩_trop : x ∈ P_trop}, where P_trop is a tropical polytope defined by m constraints in ℝⁿ, compute:
1. An optimal solution using at most n+1 active constraints (by Carathéodory).
2. A dual certificate using at most n+1 dual variables (by tropical Farkas).

### Expected Lean Signature

```lean
-- Decidable tropical LP feasibility
noncomputable def tropLP_feasible {n m : ℕ} [NeZero n]
    (A : Fin m → Fin n → ℝ) (b : Fin m → ℝ) : Prop :=
  ∃ x : Fin n → ℝ, ∀ j : Fin m,
    tropFunctional (A j) x ≤ b j

theorem tropLP_sparse_certificate {n m : ℕ} [NeZero n] [NeZero m]
    (A : Fin m → Fin n → ℝ) (b : Fin m → ℝ)
    (hfeas : tropLP_feasible A b) :
    ∃ x : Fin n → ℝ, ∃ I : Finset (Fin m),
      I.card ≤ n + 1 ∧
      (∀ j ∈ I, tropFunctional (A j) x ≤ b j) ∧
      (∀ j, tropFunctional (A j) x ≤ b j) := by sorry
```

### Proof Strategy

1. Show that the feasible region of a tropical LP is a tropical convex set.
2. Apply tropical Carathéodory to compress the feasibility witness.
3. For the dual certificate, construct a separating functional when infeasible.

### Cross-Domain Significance

- **Optimization:** Practical algorithms for tropical LP solving.
- **Complexity theory:** Tropical LP is connected to mean-payoff games (in NP ∩ coNP).
- **Formal verification:** Sparse certificates enable efficient proof checking.

---

## Direction 5: Invariant Tropical Convex Sets for Max-Plus Operators

### Statement

Given a max-plus linear operator T : ℝⁿ → ℝⁿ defined by T(x)_i = max_j (A_{ij} + x_j), a set C ⊆ ℝⁿ is **tropically invariant** under T if T(C) ⊆ C.

**Theorem target:** If T has tropical spectral radius ρ(T), then the tropical convex hull of any orbit {x, Tx, T²x, ...} is contained in a tropical cone with opening determined by ρ(T), and this cone can be represented using at most n+1 generators (by Carathéodory).

### Expected Lean Signature

```lean
noncomputable def maxPlusOperator {n : ℕ}
    (A : Fin n → Fin n → ℝ) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => Finset.univ.sup' Finset.univ_nonempty (fun j => A i j + x j)

noncomputable def tropSpectralRadius {n : ℕ} [NeZero n]
    (A : Fin n → Fin n → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i =>
    Finset.univ.sup' Finset.univ_nonempty (fun j => (A i j + A j i) / 2))

theorem invariant_tropical_cone_caratheodory {n : ℕ} [NeZero n]
    (A : Fin n → Fin n → ℝ) (x₀ : Fin n → ℝ)
    (orbit : ℕ → Fin n → ℝ)
    (horbit : orbit 0 = x₀ ∧ ∀ k, orbit (k + 1) = maxPlusOperator A (orbit k)) :
    ∃ (I : Finset (Fin n)) (hI : I.Nonempty),
      I.card ≤ n + 1 ∧
      ∀ k, ∃ c : Fin n → ℝ,
        ∀ i, orbit k i ≤ tropLinCombOn (fun j => orbit j) c I hI i +
          k • tropSpectralRadius A := by sorry
```

### Proof Strategy

1. Use the max-plus Perron–Frobenius theorem to bound orbit growth by ρ(T).
2. Apply tropical Carathéodory to the orbit points modulo the spectral growth.
3. Show the tropical cone is invariant under T up to spectral scaling.

### Cross-Domain Significance

- **Control theory:** Invariant cones provide safety certificates for discrete event systems.
- **Dynamical systems:** Max-plus Lyapunov functions from tropical spectral theory.
- **Nonlinear Perron–Frobenius:** Connects tropical convexity with spectral theory of nonnegative matrices.

---

## Research Program Summary

| Direction | Difficulty | Prerequisites | Impact |
|-----------|-----------|--------------|--------|
| 1. Fenchel–Moreau | Medium | Tropical Young ineq | Duality theory |
| 2. Hahn–Banach | Hard | Carathéodory + LP theory | Certificates |
| 3. Helly–Radon | Hard | Carathéodory + combinatorics | Feasibility |
| 4. Sparse certificates | Medium | Carathéodory + LP | Algorithms |
| 5. Invariant cones | Very Hard | All above + spectral theory | Control |

**Recommended order:** 1 → 4 → 2 → 3 → 5

Each direction builds on the tropical Carathéodory theorem established here. Together, they would constitute a comprehensive formally verified library for tropical convex analysis — the first of its kind in any proof assistant.
