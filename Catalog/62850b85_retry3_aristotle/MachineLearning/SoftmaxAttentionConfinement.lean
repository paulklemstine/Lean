/-
  Softmax Attention Convex-Hull Confinement
  =========================================

  This file formalizes the basic "convex-hull confinement" property of a single
  softmax self-attention head: the output of attention is a convex combination
  of the value vectors, hence it is confined to the coordinate-wise interval
  (and thus the convex hull) spanned by the values.

  We model an attention head with:
  * a query vector `q : Fin d → ℝ`,
  * key vectors `ks : Fin n → Fin d → ℝ` (one key per token),
  * value vectors `vs : Fin n → Fin m → ℝ` (one value per token).

  The unnormalized score (kernel) of a key is `expKernel q k = exp ⟪q, k⟫`,
  the partition function `attnPartition` is the sum of the kernels, the
  attention weights `attnWeight` are the normalized kernels (a probability
  distribution over tokens), and the output `attnOutput` is the weighted
  average of the values.

  Main results:
  * `attnWeight_sum_one`     : the attention weights sum to one.
  * `convexCombo_mem_Icc`    : a convex combination stays in any interval
                               containing the points.
  * `attnOutput_mem_Icc`     : each output coordinate is confined to the
                               interval spanned by the value coordinates.
  * `logPartition_ge_term`   : the log-partition dominates every individual
                               score (a log-sum-exp lower bound).
-/

import Mathlib

open Finset
open scoped BigOperators

noncomputable section

variable {d n m : ℕ}

/-- Unnormalized exponential kernel (score) of a key relative to a query:
`exp ⟪q, k⟫`. -/
def expKernel (q : Fin d → ℝ) (k : Fin d → ℝ) : ℝ :=
  Real.exp (∑ i, q i * k i)

/-- The softmax partition function: the sum of the kernels over all tokens. -/
def attnPartition (q : Fin d → ℝ) (ks : Fin n → Fin d → ℝ) : ℝ :=
  ∑ j, expKernel q (ks j)

/-- The softmax attention weight assigned to token `j`. -/
def attnWeight (q : Fin d → ℝ) (ks : Fin n → Fin d → ℝ) (j : Fin n) : ℝ :=
  expKernel q (ks j) / attnPartition q ks

/-- The attention output's `i`-th coordinate: the weighted average of the
`i`-th coordinate of each value vector. -/
def attnOutput (q : Fin d → ℝ) (ks : Fin n → Fin d → ℝ)
    (vs : Fin n → Fin m → ℝ) (i : Fin m) : ℝ :=
  ∑ j, attnWeight q ks j * vs j i

/-! ### Basic positivity lemmas -/

theorem expKernel_pos (q : Fin d → ℝ) (k : Fin d → ℝ) : 0 < expKernel q k :=
  Real.exp_pos _

theorem attnPartition_pos [Nonempty (Fin n)] (q : Fin d → ℝ)
    (ks : Fin n → Fin d → ℝ) : 0 < attnPartition q ks := by
  unfold attnPartition
  apply Finset.sum_pos
  · intro j _; exact expKernel_pos q (ks j)
  · exact Finset.univ_nonempty

theorem attnWeight_pos [Nonempty (Fin n)] (q : Fin d → ℝ)
    (ks : Fin n → Fin d → ℝ) (j : Fin n) : 0 < attnWeight q ks j := by
  unfold attnWeight
  exact div_pos (expKernel_pos q (ks j)) (attnPartition_pos q ks)

theorem attnWeight_nonneg [Nonempty (Fin n)] (q : Fin d → ℝ)
    (ks : Fin n → Fin d → ℝ) (j : Fin n) : 0 ≤ attnWeight q ks j :=
  le_of_lt (attnWeight_pos q ks j)

/-! ### The four main theorems -/

/-
The softmax attention weights form a probability distribution: they sum to
one.
-/
theorem attnWeight_sum_one [Nonempty (Fin n)] (q : Fin d → ℝ)
    (ks : Fin n → Fin d → ℝ) : ∑ j, attnWeight q ks j = 1 := by
  rw [ Finset.sum_congr rfl fun j _ => show attnWeight q ks j = ( expKernel q ( ks j ) ) / ( ∑ j : Fin n, expKernel q ( ks j ) ) from rfl, ← Finset.sum_div, div_self <| ne_of_gt <| Finset.sum_pos ( fun _ _ => expKernel_pos _ _ ) Finset.univ_nonempty ]

/-
A convex combination of points lying in an interval `Icc lo hi` again lies
in `Icc lo hi`.
-/
theorem convexCombo_mem_Icc {lo hi : ℝ} (w : Fin n → ℝ) (x : Fin n → ℝ)
    (w_nonneg : ∀ j, 0 ≤ w j) (w_sum : ∑ j, w j = 1)
    (x_mem : ∀ j, x j ∈ Set.Icc lo hi) :
    (∑ j, w j * x j) ∈ Set.Icc lo hi := by
  constructor <;> nlinarith [ Set.mem_Icc.mp ( x_mem ⟨ 0, Nat.pos_of_ne_zero fun h => by subst h; norm_num at w_sum ⟩ ), show ∑ j, w j * x j ≥ ∑ j, w j * lo by exact Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( Set.mem_Icc.mp ( x_mem i ) |>.1 ) ( w_nonneg i ), show ∑ j, w j * x j ≤ ∑ j, w j * hi by exact Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( Set.mem_Icc.mp ( x_mem i ) |>.2 ) ( w_nonneg i ), show ∑ j, w j * lo = lo by rw [ ← Finset.sum_mul, w_sum, one_mul ], show ∑ j, w j * hi = hi by rw [ ← Finset.sum_mul, w_sum, one_mul ] ]

/-
Convex-hull confinement: each output coordinate is confined to the interval
`Icc lo hi` spanned by the corresponding value coordinates.
-/
theorem attnOutput_mem_Icc [Nonempty (Fin n)] {lo hi : ℝ} (q : Fin d → ℝ)
    (ks : Fin n → Fin d → ℝ) (vs : Fin n → Fin m → ℝ) (i : Fin m)
    (hlo : ∀ j, lo ≤ vs j i) (hhi : ∀ j, vs j i ≤ hi) :
    attnOutput q ks vs i ∈ Set.Icc lo hi := by
  convert convexCombo_mem_Icc ( fun j => attnWeight q ks j ) ( fun j => vs j i ) _ _ ( fun j => ⟨ hlo j, hhi j ⟩ );
  · exact fun j => le_of_lt ( attnWeight_pos q ks j );
  · convert attnWeight_sum_one q ks

/-
The log-partition function dominates each individual score: a log-sum-exp
lower bound.
-/
theorem logPartition_ge_term [Nonempty (Fin n)] (q : Fin d → ℝ)
    (ks : Fin n → Fin d → ℝ) (j : Fin n) :
    Real.log (attnPartition q ks) ≥ ∑ i, q i * ks j i := by
  -- By definition of `attnPartition`, we have `attnPartition q ks = ∑ j, expKernel q (ks j)`.
  have h_attnPartition : attnPartition q ks = ∑ j, Real.exp (∑ i, q i * ks j i) := by
    rfl;
  exact Real.le_log_iff_exp_le ( h_attnPartition ▸ Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) |>.2 ( h_attnPartition ▸ Finset.single_le_sum ( fun i _ => Real.exp_nonneg ( ∑ j, q j * ks i j ) ) ( Finset.mem_univ j ) )

end