/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# A Quantitative Universal Approximation Theorem for 1D ReLU Networks

This file gives a fully verified, *quantitative* universal approximation result
for one-dimensional ReLU networks of a very explicit shape.

## Construction

Fix `n > 0` and a target function `f : ℝ → ℝ`.  We subdivide `[0,1]` into `n`
equal cells with nodes `grid n k = k / n`.  On each cell `[k/n, (k+1)/n]` the
*piecewise-linear interpolant* of `f` agrees with `f` at the two endpoints and is
affine in between.  Such an interpolant can be written as a single hidden-layer
ReLU network using `2n` ramp neurons.  Concretely, for each cell we use the
"ramp difference"

  `relu (x - k/n) - relu (x - (k+1)/n)`

which is `0` left of the cell, rises linearly with slope `1` inside the cell, and
saturates to the constant width `1/n` to the right of the cell.  Scaling the
`k`-th ramp difference by the cell slope `cellSlope f n k = n (f((k+1)/n) - f(k/n))`
and summing reproduces the interpolant exactly:

  `reluInterpNet f n x = f 0 + ∑_{k<n} cellSlope f n k · (relu(x-k/n) - relu(x-(k+1)/n))`.

## Main results

* `reluInterpNet_eq_on_cell` — the network equals the affine interpolant on each
  cell (the ramps with index `< k` telescope, the `k`-th ramp is active, the
  ramps with index `> k` vanish).
* `interp_error_le` — on a cell the affine interpolant differs from a function
  that is `L`-Lipschitz on `[0,1]` by at most `L / n` (it is a convex combination
  of two endpoint values, each within distance `1/n` of `x`).
* `quantitative_uat_cell` — the cellwise approximation bound `L / n`.
* `quantitative_uat_core` — the global statement: for every `x ∈ [0,1]`,
  `|reluInterpNet f n x - f x| ≤ L / n`.
* `quantitative_uat_width` — width/error tradeoff: width `2n` neurons suffice for
  error `ε` whenever `L ≤ ε n`, i.e. `width = O(1/ε)`.

The result is intentionally modest: it records only the upper bound `L/n` (not the
sharper `L/(2n)`) and contains no lower bounds, sharpness, or depth–width results.
-/
import Mathlib

namespace MachineLearning.UniversalApproximation

open Finset

/-- The ReLU activation `relu x = max x 0`. -/
noncomputable def relu (x : ℝ) : ℝ := max x 0

/-- Uniform grid node `k/n` on `[0,1]`. -/
noncomputable def grid (n k : ℕ) : ℝ := (k : ℝ) / (n : ℝ)

/-- Slope of `f` across the cell `[k/n, (k+1)/n]`, scaled by `n` (the reciprocal
of the cell width). -/
noncomputable def cellSlope (f : ℝ → ℝ) (n k : ℕ) : ℝ :=
  (n : ℝ) * (f (grid n (k + 1)) - f (grid n k))

/-- The ramp-difference ReLU network reproducing the uniform-grid piecewise-linear
interpolant of `f` using `2n` ramp neurons. -/
noncomputable def reluInterpNet (f : ℝ → ℝ) (n : ℕ) (x : ℝ) : ℝ :=
  f 0 + ∑ k ∈ Finset.range n,
    cellSlope f n k * (relu (x - grid n k) - relu (x - grid n (k + 1)))

/-- `f` is `L`-Lipschitz on the interval `[0,1]` (unbundled form). -/
def LipOn01 (f : ℝ → ℝ) (L : ℝ) : Prop :=
  ∀ x ∈ Set.Icc (0 : ℝ) 1, ∀ y ∈ Set.Icc (0 : ℝ) 1, |f x - f y| ≤ L * |x - y|

/-! ### A. Elementary ReLU ramp facts

A single ramp difference `relu (x-a) - relu (x-b)` (with `a ≤ b`) is `0` to the
left of `a`, equals `x - a` inside `[a,b]`, and saturates to `b - a` to the
right of `b`. -/

/-
Left of the cell the ramp difference vanishes.
-/
lemma ramp_left (a b x : ℝ) (hab : a ≤ b) (hx : x ≤ a) :
    relu (x - a) - relu (x - b) = 0 := by
      unfold relu; cases max_cases ( x - a ) 0 <;> cases max_cases ( x - b ) 0 <;> linarith;

/-
Inside the cell the ramp difference rises linearly with slope one.
-/
lemma ramp_mid (a b x : ℝ) (ha : a ≤ x) (hb : x ≤ b) :
    relu (x - a) - relu (x - b) = x - a := by
      unfold relu; rw [ max_eq_left ( by linarith ), max_eq_right ( by linarith ) ] ; ring;

/-
Right of the cell the ramp difference saturates to the cell width.
-/
lemma ramp_right (a b x : ℝ) (hab : a ≤ b) (hx : b ≤ x) :
    relu (x - a) - relu (x - b) = b - a := by
      unfold relu; rw [ max_eq_left ( by linarith ), max_eq_left ( by linarith ) ] ; ring;

/-! ### Grid arithmetic -/

/-
The grid starts at `0`.
-/
lemma grid_zero (n : ℕ) : grid n 0 = 0 := by
  unfold grid; norm_num;

/-
Consecutive grid nodes are `1/n` apart.
-/
lemma grid_succ_sub (n k : ℕ) :
    grid n (k + 1) - grid n k = 1 / (n : ℝ) := by
  unfold grid
  rw [div_sub_div_same]
  push_cast
  ring

/-
The grid is monotone in the index.
-/
lemma grid_mono (n : ℕ) {j k : ℕ} (h : j ≤ k) : grid n j ≤ grid n k := by
  exact div_le_div_of_nonneg_right ( mod_cast h ) ( Nat.cast_nonneg _ )

/-
A scaled cell-slope times the cell width recovers the endpoint difference.
-/
lemma cellSlope_mul_width (f : ℝ → ℝ) (n k : ℕ) (hn : 0 < n) :
    cellSlope f n k * (grid n (k + 1) - grid n k)
      = f (grid n (k + 1)) - f (grid n k) := by
        rw [ cellSlope, grid_succ_sub n ];
        rw [ mul_right_comm, mul_one_div_cancel ( by positivity ), one_mul ]

/-! ### B. The network equals the piecewise-linear interpolant on each cell -/

/-
On the cell `[k/n, (k+1)/n]` the network equals the affine interpolant
`f(k/n) + cellSlope f n k · (x - k/n)`.  Ramp terms with index `< k` saturate
and telescope to `f(k/n) - f 0`, the `k`-th ramp is active and contributes
`cellSlope f n k · (x - k/n)`, and ramp terms with index `> k` vanish.
-/
lemma reluInterpNet_eq_on_cell (f : ℝ → ℝ) (n k : ℕ) (hn : 0 < n) (hk : k < n)
    (x : ℝ) (hx : x ∈ Set.Icc (grid n k) (grid n (k + 1))) :
    reluInterpNet f n x = f (grid n k) + cellSlope f n k * (x - grid n k) := by
      have h_sum_range : ∑ j ∈ Finset.range k, cellSlope f n j * (relu (x - grid n j) - relu (x - grid n (j + 1))) = f (grid n k) - f (grid n 0) := by
        have h_sum_range : ∀ j ∈ Finset.range k, cellSlope f n j * (relu (x - grid n j) - relu (x - grid n (j + 1))) = f (grid n (j + 1)) - f (grid n j) := by
          intros j hj; rw [ ← cellSlope_mul_width f n j hn ] ; rw [ ramp_right ] ;
          · exact grid_mono _ ( Nat.le_succ _ );
          · exact le_trans ( grid_mono _ ( by linarith [ Finset.mem_range.mp hj ] ) ) hx.1;
        rw [ Finset.sum_congr rfl h_sum_range, Finset.sum_range_sub ( fun j => f ( grid n j ) ) ];
      have h_sum_Ico : ∑ j ∈ Finset.Ico (k + 1) n, cellSlope f n j * (relu (x - grid n j) - relu (x - grid n (j + 1))) = 0 := by
        refine Finset.sum_eq_zero fun j hj => ?_;
        rw [ ramp_left ] <;> norm_num;
        · exact grid_mono n ( Nat.le_succ _ );
        · exact hx.2.trans ( grid_mono _ <| by linarith [ Finset.mem_Ico.mp hj ] );
      convert congr_arg ( fun y => f 0 + y ) ( show ∑ j ∈ Finset.range n, cellSlope f n j * ( relu ( x - grid n j ) - relu ( x - grid n ( j + 1 ) ) ) = f ( grid n k ) - f ( grid n 0 ) + cellSlope f n k * ( x - grid n k ) from ?_ ) using 1;
      · rw [ show grid n 0 = 0 from grid_zero n ] ; ring;
      · rw [ ← h_sum_range, ← Finset.sum_range_add_sum_Ico _ ( by linarith : k + 1 ≤ n ) ];
        simp_all +decide [ Finset.sum_range_succ ];
        exact Or.inl ( ramp_mid _ _ _ hx.1 hx.2 )

/-! ### C. Local interpolation error bound `L / n` -/

/-
On a cell, the affine interpolant of an `L`-Lipschitz function differs from
the function by at most `L / n`.  The interpolant is a convex combination of the
two endpoint values, and every point of the cell is within `1/n` of each
endpoint.
-/
lemma interp_error_le (f : ℝ → ℝ) (n k : ℕ) (L : ℝ) (hn : 0 < n) (hk : k < n)
    (hL : 0 ≤ L) (hlip : LipOn01 f L) (x : ℝ)
    (hx : x ∈ Set.Icc (grid n k) (grid n (k + 1))) :
    |(f (grid n k) + cellSlope f n k * (x - grid n k)) - f x| ≤ L / (n : ℝ) := by
  -- Let $t := n * (x - grid n k) = (x - grid n k) / (1 / n)$. Since $grid n k ≤ x ≤ grid n (k + 1)$ and $grid n (k + 1) - grid n k = 1 / n$, we have $0 ≤ t ≤ 1$.
  set t := (x - grid n k) / (1 / n : ℝ)
  have ht0 : 0 ≤ t := by
    exact div_nonneg ( sub_nonneg.2 hx.1 ) ( by positivity )
  have ht1 : t ≤ 1 := by
    simp +zetaDelta at *;
    nlinarith [ show ( n : ℝ ) ≥ k + 1 by norm_cast, show ( grid n ( k + 1 ) : ℝ ) = ( k + 1 : ℝ ) / n by unfold grid; push_cast; ring, show ( grid n k : ℝ ) = ( k : ℝ ) / n by unfold grid; ring, mul_div_cancel₀ ( ( k : ℝ ) ) ( by positivity : ( n : ℝ ) ≠ 0 ), mul_div_cancel₀ ( ( k + 1 : ℝ ) ) ( by positivity : ( n : ℝ ) ≠ 0 ) ];
  -- So the interpolant minus f x is:
  -- (1 - t) * (f (grid n k) - f x) + t * (f (grid n (k + 1)) - f x).
  have h_interpolant : f (grid n k) + cellSlope f n k * (x - grid n k) = (1 - t) * f (grid n k) + t * f (grid n (k + 1)) := by
    have hn0 : (n : ℝ) ≠ 0 := by positivity
    unfold cellSlope t
    field_simp
    ring
  -- By LipOn01 hlip: |f (grid n k) - f x| ≤ L * |grid n k - x| and |f (grid n (k + 1)) - f x| ≤ L * |grid n (k + 1) - x|.
  have h_lip : |f (grid n k) - f x| ≤ L * |grid n k - x| ∧ |f (grid n (k + 1)) - f x| ≤ L * |grid n (k + 1) - x| := by
    apply And.intro;
    · apply hlip;
      · exact ⟨ div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ), div_le_one_of_le₀ ( mod_cast by linarith ) ( Nat.cast_nonneg _ ) ⟩;
      · exact ⟨ hx.1.trans' ( by exact div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ) ), hx.2.trans ( by rw [ grid ] ; rw [ div_le_iff₀ ( by positivity ) ] ; norm_cast; linarith ) ⟩;
    · apply hlip;
      · exact ⟨ div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ), div_le_one_of_le₀ ( by norm_cast ) ( Nat.cast_nonneg _ ) ⟩;
      · exact ⟨ hx.1.trans' ( by exact div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ) ), hx.2.trans ( by rw [ grid ] ; rw [ div_le_iff₀ ( by positivity ) ] ; norm_cast; linarith ) ⟩;
  -- Now |grid n k - x| = x - grid n k ≤ grid n (k + 1) - grid n k = 1 / n and |grid n (k + 1) - x| = grid n (k + 1) - x ≤ grid n (k + 1) - grid n k = 1 / n.
  have h_dist : |grid n k - x| ≤ 1 / n ∧ |grid n (k + 1) - x| ≤ 1 / n := by
    simp_all +decide [ abs_sub_comm, grid ];
    exact ⟨ abs_le.mpr ⟨ by ring_nf at *; linarith, by ring_nf at *; linarith ⟩, abs_le.mpr ⟨ by ring_nf at *; linarith, by ring_nf at *; linarith ⟩ ⟩;
  rw [ abs_le ];
  constructor <;> ring_nf at * <;> nlinarith [ abs_le.mp h_lip.1, abs_le.mp h_lip.2, mul_nonneg hL ( sub_nonneg.mpr ht0 ), mul_nonneg hL ( sub_nonneg.mpr ht1 ) ]

/-! ### Main theorems -/

/-- Cellwise quantitative universal approximation: on the cell `[k/n,(k+1)/n]`
the network approximates `f` with error at most `L/n`. -/
theorem quantitative_uat_cell (f : ℝ → ℝ) (n k : ℕ) (L : ℝ) (hn : 0 < n)
    (hk : k < n) (hL : 0 ≤ L) (hlip : LipOn01 f L) (x : ℝ)
    (hx : x ∈ Set.Icc (grid n k) (grid n (k + 1))) :
    |reluInterpNet f n x - f x| ≤ L / (n : ℝ) := by
  rw [reluInterpNet_eq_on_cell f n k hn hk x hx]
  exact interp_error_le f n k L hn hk hL hlip x hx

/-
Every point of `[0,1]` lies in some grid cell.
-/
lemma exists_cell (n : ℕ) (hn : 0 < n) (x : ℝ) (hx : x ∈ Set.Icc (0 : ℝ) 1) :
    ∃ k, k < n ∧ x ∈ Set.Icc (grid n k) (grid n (k + 1)) := by
      by_cases hx1 : x = 1;
      · refine' ⟨ n - 1, _, _ ⟩ <;> rcases n with ( _ | _ | n ) <;> norm_num [ grid ] at *;
        · tauto;
        · exact ⟨ by rw [ hx1, div_le_iff₀ ] <;> linarith, by rw [ hx1, le_div_iff₀ ] <;> linarith ⟩;
      · refine' ⟨ ⌊x * n⌋₊, _, _, _ ⟩;
        · rw [ Nat.floor_lt ] <;> cases lt_or_gt_of_ne hx1 <;> nlinarith [ hx.1, hx.2, show ( n : ℝ ) ≥ 1 by norm_cast ];
        · exact div_le_of_le_mul₀ ( by positivity ) ( by linarith [ hx.1 ] ) ( by nlinarith [ Nat.floor_le ( show 0 ≤ x * n by nlinarith [ hx.1 ] ) ] );
        · exact le_div_iff₀' ( by positivity ) |>.2 ( by push_cast; linarith [ Nat.lt_floor_add_one ( x * n ) ] )

/-- **Quantitative universal approximation theorem (global form).**
If `0 < n`, `0 ≤ L`, and `f` is `L`-Lipschitz on `[0,1]`, then the ramp-difference
ReLU network approximates `f` uniformly on `[0,1]` with error at most `L/n`. -/
theorem quantitative_uat_core (f : ℝ → ℝ) (n : ℕ) (L : ℝ) (hn : 0 < n)
    (hL : 0 ≤ L) (hlip : LipOn01 f L) (x : ℝ) (hx : x ∈ Set.Icc (0 : ℝ) 1) :
    |reluInterpNet f n x - f x| ≤ L / (n : ℝ) := by
  obtain ⟨k, hk, hxk⟩ := exists_cell n hn x hx
  exact quantitative_uat_cell f n k L hn hk hL hlip x hxk

/-! ### E. Width/error tradeoff

The network uses `2n` ramp neurons.  To reach error `ε` it suffices that
`L ≤ ε n`, i.e. `n ≥ L/ε` and `width = 2n = O(1/ε)`. -/

/-- Width/error tradeoff: if `L ≤ ε n` then the network approximates `f` to
within `ε` everywhere on `[0,1]`.  The positivity hypothesis `0 < ε` is kept to
match the intended statement, but the bound `L ≤ ε n` already forces the
conclusion, so the proof does not need it (hence the underscore). -/
theorem quantitative_uat_width (f : ℝ → ℝ) (n : ℕ) (L ε : ℝ) (hn : 0 < n)
    (_hε : 0 < ε) (hL : 0 ≤ L) (hLε : L ≤ ε * (n : ℝ)) (hlip : LipOn01 f L)
    (x : ℝ) (hx : x ∈ Set.Icc (0 : ℝ) 1) :
    |reluInterpNet f n x - f x| ≤ ε := by
  have hbound := quantitative_uat_core f n L hn hL hlip x hx
  have hnpos : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hle : L / (n : ℝ) ≤ ε := by
    rw [div_le_iff₀ hnpos]
    linarith [hLε]
  linarith [hbound, hle]

end MachineLearning.UniversalApproximation