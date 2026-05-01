import Mathlib

/-! # Tropical Trace Formula for 2×2 Matrices (Max-Plus Algebra)

We formalize the **tropical (max-plus) algebra** for 2×2 matrices and prove a
**tropical trace formula**: the maximum cycle mean of a weighted directed graph
on 2 vertices equals the normalized tropical power trace.

## Main Results

* `TropMat2.tropical_trace_formula` — The tropical trace formula:
  the maximum cycle mean equals `ttrace(M²) / 2`, which is the 2×2 specialization
  of the **Cycle-Time Theorem** (tropical Perron-Frobenius).

* `TropMat2.tdet_eq_max_matching` — The tropical determinant equals the
  max-weight perfect matching (i.e., the solution to the 2×2 assignment problem).

* `TropMat2.tmul_assoc` — Tropical matrix multiplication is associative.

* `TropMat2.ttrace_le_maxCycleMean` — The tropical trace is bounded by the
  maximum cycle mean.

* `TropMat2.spectral_geometric_equiv` — The spectral-geometric equivalence:
  the maximum over normalized power traces (spectral) equals the maximum
  cycle mean (geometric).

## Mathematical Context

In the classical Arthur–Selberg trace formula for GL₂, one equates:
- **Geometric side**: sums of orbital integrals over conjugacy classes
- **Spectral side**: traces of Hecke operators over representations

Our tropical analogue replaces:
- **Conjugacy classes** → cycles in the weighted directed graph of the matrix
- **Orbital integrals** → cycle means (average edge weight around a cycle)
- **Spectral data** → tropical eigenvalues (= maximum cycle mean by the Cycle-Time Theorem)

The identity `maxCycleMean M = ttrace(tsquare M) / 2` is precisely the
**geometric = spectral** equivalence in the tropical setting, specialized to GL₂.

## Connection to the Assignment Problem

The tropical determinant `tdet M = max(M.a₁₁ + M.a₂₂, M.a₁₂ + M.a₂₁)` computes
the maximum-weight perfect matching in the complete bipartite graph K_{2,2} with
edge weights given by the matrix entries. This is the 2×2 case of the fundamental
correspondence between tropical linear algebra and combinatorial optimization.

## References

* Butkovič, *Max-linear Systems: Theory and Algorithms*, Springer 2010
* Akian, Bapat, Gaubert, "Max-plus algebra", in *Handbook of Linear Algebra*, 2006
* Heidergott, Olsder, van der Woude, *Max Plus at Work*, Princeton 2006
-/

noncomputable section

namespace TropMat2

/-! ## Definitions -/

/-- A 2×2 matrix over ℚ, interpreted in the max-plus tropical semiring.
    Tropical addition is `max`, tropical multiplication is `+`. -/
structure Mat2 where
  a₁₁ : ℚ
  a₁₂ : ℚ
  a₂₁ : ℚ
  a₂₂ : ℚ
  deriving DecidableEq, Repr

/-- Tropical (max-plus) matrix multiplication for 2×2 matrices.
    Each entry is the tropical inner product of the corresponding row and column:
    `(M ⊗ N)ᵢⱼ = max_k (Mᵢₖ + Nₖⱼ)` -/
def tmul (M N : Mat2) : Mat2 where
  a₁₁ := max (M.a₁₁ + N.a₁₁) (M.a₁₂ + N.a₂₁)
  a₁₂ := max (M.a₁₁ + N.a₁₂) (M.a₁₂ + N.a₂₂)
  a₂₁ := max (M.a₂₁ + N.a₁₁) (M.a₂₂ + N.a₂₁)
  a₂₂ := max (M.a₂₁ + N.a₁₂) (M.a₂₂ + N.a₂₂)

/-- Tropical trace: the tropical sum (= max) of diagonal entries. -/
def ttrace (M : Mat2) : ℚ := max M.a₁₁ M.a₂₂

/-- Tropical determinant: the max-weight perfect matching in the
    complete bipartite graph K_{2,2}. This solves the 2×2 assignment problem. -/
def tdet (M : Mat2) : ℚ := max (M.a₁₁ + M.a₂₂) (M.a₁₂ + M.a₂₁)

/-- Tropical square: `M ⊗ M` in the max-plus algebra. -/
def tsquare (M : Mat2) : Mat2 := tmul M M

/-- Maximum cycle mean for a 2×2 matrix viewed as a weighted directed graph.
    - **Length-1 cycles**: self-loops at vertices 1 and 2, with means `a₁₁` and `a₂₂`
    - **Length-2 cycle**: the cycle 1→2→1, with mean `(a₁₂ + a₂₁) / 2`
    The maximum cycle mean is the tropical analogue of the spectral radius. -/
def maxCycleMean (M : Mat2) : ℚ :=
  max (max M.a₁₁ M.a₂₂) ((M.a₁₂ + M.a₂₁) / 2)

/-- The identity permutation matching: σ = id, weight = a₁₁ + a₂₂ -/
def identityMatchingWeight (M : Mat2) : ℚ := M.a₁₁ + M.a₂₂

/-- The swap permutation matching: σ = (12), weight = a₁₂ + a₂₁ -/
def swapMatchingWeight (M : Mat2) : ℚ := M.a₁₂ + M.a₂₁

/-! ## Core Theorems -/

/-- **Tropical determinant = assignment problem.**
    The tropical determinant equals the maximum over all perfect matchings. -/
theorem tdet_eq_max_matching (M : Mat2) :
    tdet M = max (identityMatchingWeight M) (swapMatchingWeight M) := by
  rfl

/-- **Diagonal entry of the tropical square.** The (1,1) entry of M² encodes
    all closed walks of length 2 starting and ending at vertex 1. -/
theorem tsquare_a₁₁ (M : Mat2) :
    (tsquare M).a₁₁ = max (2 * M.a₁₁) (M.a₁₂ + M.a₂₁) := by
  simp [tsquare, tmul]; ring_nf

/-- **Diagonal entry of the tropical square.** The (2,2) entry of M² encodes
    all closed walks of length 2 starting and ending at vertex 2. -/
theorem tsquare_a₂₂ (M : Mat2) :
    (tsquare M).a₂₂ = max (M.a₂₁ + M.a₁₂) (2 * M.a₂₂) := by
  simp [tsquare, tmul]; ring_nf

/-- **Tropical trace of the square.** Collects all closed walks of length ≤ 2. -/
theorem ttrace_tsquare (M : Mat2) :
    ttrace (tsquare M) = max (max (2 * M.a₁₁) (M.a₁₂ + M.a₂₁)) (max (M.a₂₁ + M.a₁₂) (2 * M.a₂₂)) := by
  unfold ttrace
  rw [tsquare_a₁₁, tsquare_a₂₂]

/-
**Key lemma**: The tropical trace of M² simplifies.
-/
theorem ttrace_tsquare_simplified (M : Mat2) :
    ttrace (tsquare M) = max (max (2 * M.a₁₁) (2 * M.a₂₂)) (M.a₁₂ + M.a₂₁) := by
  rw [ ttrace_tsquare ];
  grind

/-
**Scaling lemma**: `max(2a, 2b, c) / 2 = max(a, b, c/2)` for rationals.
-/
theorem max_div_two (a b c : ℚ) :
    max (max (2 * a) (2 * b)) c / 2 = max (max a b) (c / 2) := by
  grind

/-
### The Tropical Trace Formula (Cycle-Time Theorem for GL₂)

This is the main result. For a 2×2 matrix M in the max-plus algebra, the
**maximum cycle mean** (geometric side) equals the **normalized tropical trace
of the square** (spectral side):

  `maxCycleMean M = ttrace(M²) / 2`

This is the 2×2 specialization of the Cycle-Time Theorem, which states that
for an n×n matrix A, the maximum cycle mean equals `lim_{k→∞} tr⊕(A^k) / k`,
and for n=2 the limit is achieved at k=2.

**Geometric interpretation**: The LHS is the maximum average weight of any
directed cycle in the weighted graph. The RHS extracts this from the tropical
matrix power, which encodes all closed walks.

**Analogy to the Arthur–Selberg trace formula**: Just as the classical trace
formula equates orbital integrals (geometric) with spectral traces (spectral),
our formula equates cycle means (geometric/combinatorial) with tropical
eigenvalues computed from matrix powers (spectral/algebraic).
-/
theorem tropical_trace_formula (M : Mat2) :
    maxCycleMean M = ttrace (tsquare M) / 2 := by
  unfold maxCycleMean ttrace tsquare;
  unfold tmul; ring_nf;
  grind

/-
The tropical trace is bounded by the maximum cycle mean.
    This reflects that self-loops are particular cycles.
-/
theorem ttrace_le_maxCycleMean (M : Mat2) :
    ttrace M ≤ maxCycleMean M := by
  exact le_max_left _ _

/-
**Spectral-geometric equivalence.** The maximum over all normalized
    tropical power traces (spectral side) equals the maximum cycle mean
    (geometric side). For 2×2 matrices, we only need k = 1 and k = 2.
-/
theorem spectral_geometric_equiv (M : Mat2) :
    max (ttrace M) (ttrace (tsquare M) / 2) = maxCycleMean M := by
  rw [ ← tropical_trace_formula ];
  exact max_eq_right ( ttrace_le_maxCycleMean M )

/-! ## Tropical Multiplication Properties -/

/-
Tropical matrix multiplication is associative.
-/
theorem tmul_assoc (A B C : Mat2) : tmul (tmul A B) C = tmul A (tmul B C) := by
  unfold tmul;
  congr 1 <;> norm_num [ add_assoc, max_add_add_right ];
  · grind;
  · grind;
  · grind;
  · grind

/-
The tropical trace of the square is at least twice the tropical trace.
    This reflects that length-1 cycles are embedded in length-2 closed walks.
-/
theorem ttrace_tsquare_ge_twice_ttrace (M : Mat2) :
    ttrace (tsquare M) ≥ 2 * ttrace M := by
  grind +locals

/-
The tropical determinant equals the tropical trace of the square
    minus the tropical trace squared, in an appropriate sense:
    `tdet M = ttrace(M²)` when the off-diagonal cycle dominates.
-/
theorem tdet_le_ttrace_tsquare (M : Mat2) :
    tdet M ≤ ttrace (tsquare M) := by
  unfold tdet ttrace tsquare;
  unfold tmul;
  grind

/-! ## Concrete Computations -/

/-- Example: The matrix [[3,1],[2,4]] has tropical trace max(3,4) = 4. -/
example : ttrace ⟨3, 1, 2, 4⟩ = 4 := by native_decide

/-- Example: The matrix [[3,1],[2,4]] has tropical det max(3+4,1+2) = max(7,3) = 7. -/
example : tdet ⟨3, 1, 2, 4⟩ = 7 := by native_decide

/-- Example: Max cycle mean of [[3,1],[2,4]] = max(3, 4, (1+2)/2) = max(3, 4, 3/2) = 4. -/
example : maxCycleMean ⟨3, 1, 2, 4⟩ = 4 := by native_decide

/-- Example: A matrix where the 2-cycle dominates.
    [[0,5],[5,0]] has max cycle mean = max(0, 0, (5+5)/2) = 5. -/
example : maxCycleMean ⟨0, 5, 5, 0⟩ = 5 := by native_decide

/-- Verify the trace formula on a concrete example. -/
example : maxCycleMean ⟨0, 5, 5, 0⟩ = ttrace (tsquare ⟨0, 5, 5, 0⟩) / 2 := by native_decide

/-! ## Eigenvalue Characterization -/

/-- A rational number λ is a **tropical eigenvalue** of M if there exist
    x₁, x₂ (not both zero in a suitable sense) satisfying the tropical
    eigenvalue equation:
    - `max(a₁₁ + x₁, a₁₂ + x₂) = λ + x₁`
    - `max(a₂₁ + x₁, a₂₂ + x₂) = λ + x₂` -/
def IsTropicalEigenvalue (M : Mat2) (ev : ℚ) : Prop :=
  ∃ x₁ x₂ : ℚ, max (M.a₁₁ + x₁) (M.a₁₂ + x₂) = ev + x₁ ∧
                  max (M.a₂₁ + x₁) (M.a₂₂ + x₂) = ev + x₂

/-
The maximum cycle mean is always a tropical eigenvalue.
    This is the tropical analogue of "the spectral radius is an eigenvalue."
-/
theorem maxCycleMean_is_eigenvalue (M : Mat2) :
    IsTropicalEigenvalue M (maxCycleMean M) := by
  -- Let's consider the three cases based on the definition of `maxCycleMean`.
  by_cases h_case1 : maxCycleMean M = M.a₁₁;
  · -- In this case, we can choose $x₁ = 0$ and $x₂ = M.a₂₁ - M.a₁₁$.
    use 0, M.a₂₁ - M.a₁₁;
    grind +suggestions;
  · by_cases h_case2 : maxCycleMean M = M.a₂₂;
    · unfold maxCycleMean at *;
      use M.a₁₂ - M.a₂₂, 0;
      grind;
    · use 0, (M.a₂₁ - M.a₁₂) / 2;
      unfold maxCycleMean at *;
      grind

end TropMat2
end