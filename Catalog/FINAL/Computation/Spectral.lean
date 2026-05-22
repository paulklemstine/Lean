/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Spectral Theory for Circuit Lower Bounds

## Overview

This file develops the spectral side of tropical circuit complexity.
The minimum entry and diagonal structure of tropical powers provide
refined obstructions to shallow circuits beyond the raw tropical permanent.

## Main Results

1. **MinEntry lower bounds for tropical powers**: `(k+1) * minEntry M ≤ tropPow M k i j`
   — entries grow at least linearly with the number of edges.

2. **Diagonal composition bound**: `minDiag(tropMul A B) ≤ min_i (A i i + B i i)`
   — cycle costs compose pointwise at each vertex.

3. **Tropical permanent monotonicity**: entrywise ≤ implies `tropPerm ≤`.

4. **Spectral gap depth bound**: large minimum edge weight forces proportional
   path cost growth, yielding depth lower bounds.

## Counterexample Note

The "subadditivity" `minDiag(M^(k+l)) ≤ minDiag(M^k) + minDiag(M^l)` is FALSE
in general. Counterexample: `M = diag(2,1000,1000,1000)` with edges 1↔2 of weight 1.
Then `minDiag(M) = 2`, `minDiag(M²) = 2`, but `minDiag(M³) = 6 > 2+2 = 4`.
The failure occurs because different powers may achieve their minDiag at different vertices,
and cycle costs at a vertex don't decompose when the minimizing vertex changes.
-/

import Mathlib
import Computation.TropicalCircuitLowerBounds.Defs
import Computation.TropicalCircuitLowerBounds.Theorems

open Finset

namespace TropicalCircuit

variable {n : ℕ} [NeZero n]

/-! ## MinDiag and MinEntry Properties -/

/-- `minDiag M ≤ M i i` for any `i`. -/
theorem minDiag_le (M : Matrix (Fin n) (Fin n) ℕ) (i : Fin n) :
    minDiag M ≤ M i i :=
  Finset.inf'_le _ (Finset.mem_univ i)

/-- `minDiag M` equals some diagonal entry. -/
theorem minDiag_eq_diag (M : Matrix (Fin n) (Fin n) ℕ) :
    ∃ i, minDiag M = M i i := by
  simpa [eq_comm] using Finset.exists_mem_eq_inf' Finset.univ_nonempty fun i => M i i

/-- `minEntry M ≤ M i j` for any `i, j`. -/
theorem minEntry_le (M : Matrix (Fin n) (Fin n) ℕ) (i j : Fin n) :
    minEntry M ≤ M i j := by
  exact Finset.inf'_le _ (Finset.mem_univ i) |> le_trans <| Finset.inf'_le _ (Finset.mem_univ j)

/-- `minEntry M ≤ minDiag M`. -/
theorem minEntry_le_minDiag (M : Matrix (Fin n) (Fin n) ℕ) :
    minEntry M ≤ minDiag M := by
  obtain ⟨i, h_minDiag⟩ := minDiag_eq_diag M
  exact h_minDiag ▸ minEntry_le M i i

/-! ## Diagonal Composition Bound -/

/-- **Diagonal composition bound for tropical multiplication**.
For any vertex `i`, the `(i,i)` entry of `tropMul A B` is at most `A i i + B i i`.
This follows from choosing the intermediate vertex `m = i` in the inf'. -/
theorem tropMul_diag_le (A B : Matrix (Fin n) (Fin n) ℕ) (i : Fin n) :
    tropMul A B i i ≤ A i i + B i i :=
  tropMul_le A B i i i

/-
**MinDiag bound for tropical products**: the minimum diagonal entry of a
tropical product is at most `min_i (A i i + B i i)`.
-/
theorem minDiag_tropMul_le (A B : Matrix (Fin n) (Fin n) ℕ) :
    minDiag (tropMul A B) ≤ Finset.univ.inf' Finset.univ_nonempty (fun i => A i i + B i i) := by
  -- Note that $\minDiag (\tropMul A B)$ is the minimum of the diagonal entries of $\tropMul A B$.
  simp [minDiag];
  exact fun i => ⟨ i, tropMul_diag_le A B i ⟩

/-! ## Tropical Permanent Monotonicity -/

/-- If every entry of `A` is ≤ the corresponding entry of `B`, then
`tropPerm A ≤ tropPerm B`. -/
theorem tropPerm_mono {A B : Matrix (Fin n) (Fin n) ℕ}
    (h : ∀ i j, A i j ≤ B i j) :
    tropPerm A ≤ tropPerm B := by
  simp_all +decide [tropPerm]
  exact fun σ => ⟨σ, by exact Finset.sum_le_sum fun i _ => h i (σ i)⟩

/-! ## MinEntry Lower Bounds for Tropical Powers -/

/-- Every entry of `tropMul A B` is at least `minEntry A + minEntry B`. -/
theorem minEntry_add_le_tropMul (A B : Matrix (Fin n) (Fin n) ℕ) (i j : Fin n) :
    minEntry A + minEntry B ≤ tropMul A B i j := by
  exact Finset.le_inf' _ _ fun k _ => add_le_add (minEntry_le _ _ _) (minEntry_le _ _ _)

/-- **MinEntry growth for tropical powers**: every entry of `tropPow M k`
is at least `(k+1) * minEntry M`. This shows that walks in graphs with
large minimum entry must accumulate proportionally large costs. -/
theorem minEntry_mul_le_tropPow (M : Matrix (Fin n) (Fin n) ℕ) (k : ℕ) (i j : Fin n) :
    (k + 1) * minEntry M ≤ tropPow M k i j := by
  induction' k with k ih generalizing i j
  · simpa using minEntry_le M i j
  · have h_mul : tropPow M (k + 1) i j = tropMul (tropPow M k) M i j := rfl
    rw [h_mul, tropMul]
    simp +zetaDelta at *
    exact fun b => by linarith [ih i b, minEntry_le M b j]

/-
**MinDiag growth for tropical powers**: `minDiag(tropPow M k) ≥ (k+1) * minEntry M`.
-/
theorem minEntry_mul_le_minDiag_tropPow (M : Matrix (Fin n) (Fin n) ℕ) (k : ℕ) :
    (k + 1) * minEntry M ≤ minDiag (tropPow M k) := by
  exact Finset.le_inf' _ _ fun i _ => minEntry_mul_le_tropPow M k i i

/-! ## Spectral Gap Lower Bound on Path Cost -/

/-
**Spectral-gap depth lower bound**.
If `w ≤ minEntry M`, then every entry of `tropPow M d` is at least `(d+1) * w`.
This is the spectral-gap mechanism: a large minimum edge weight (spectral gap
surrogate) forces walks to accumulate cost linearly in the number of edges,
bounding the depth needed to achieve any given target cost.
-/
theorem spectral_gap_depth_bound (M : Matrix (Fin n) (Fin n) ℕ)
    {w : ℕ} (hw : w ≤ minEntry M)
    (d : ℕ) (i j : Fin n) :
    (d + 1) * w ≤ tropPow M d i j := by
  -- Apply the minEntry_mul_le_tropPow lemma with the given hw.
  have := minEntry_mul_le_tropPow M d i j;
  exact le_trans (by gcongr) this

/-
**Corollary: if a walk achieves cost ≤ B, then depth is bounded**.
If `tropPow M d i j ≤ B` and `minEntry M ≥ w > 0`, then `d ≤ B / w`.
-/
theorem depth_from_spectral_gap (M : Matrix (Fin n) (Fin n) ℕ)
    {w : ℕ} (hw : 0 < w) (hw' : w ≤ minEntry M)
    {d : ℕ} {i j : Fin n} (hcost : tropPow M d i j ≤ B) :
    d + 1 ≤ B / w + 1 := by
  exact Nat.le_succ_of_le ( Nat.le_div_iff_mul_le hw |>.2 <| by nlinarith [ spectral_gap_depth_bound M hw' d i j ] )

/-! ## MinDiag Composition at Single Vertex -/

/-
**Cycle composition at a single vertex**.
If `i₀` achieves `minDiag(tropPow M k)`, then
`minDiag(tropPow M (k+l+1)) ≤ minDiag(tropPow M k) + tropPow M l i₀ i₀`.
The right-hand side may be strictly larger than `minDiag(tropPow M k) + minDiag(tropPow M l)`,
because the vertex `i₀` optimal for one power may be suboptimal for another.
-/
theorem minDiag_tropPow_compose (M : Matrix (Fin n) (Fin n) ℕ)
    (k l : ℕ) (i₀ : Fin n) (hi₀ : tropPow M k i₀ i₀ = minDiag (tropPow M k)) :
    minDiag (tropPow M (k + l + 1)) ≤ minDiag (tropPow M k) + tropPow M l i₀ i₀ := by
  refine' le_trans ( minDiag_le _ _ ) _;
  exact i₀;
  convert tropMul_le ( tropPow M k ) ( tropPow M l ) i₀ i₀ i₀ using 1;
  · exact congr_arg ( fun f => f i₀ i₀ ) ( tropPow_add _ _ _ );
  · rw [ hi₀ ]

end TropicalCircuit