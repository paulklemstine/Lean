import Mathlib

/-!
# NET-53: why compensation works — GPTQ/OBS as a Schur complement

The NET-53 experiment found that sequential GPTQ (4-bit, group 128) lands at `ΔCE = +0.1512`,
about `2.1×` better than grouped round-to-nearest (RTN) on the same grid.  This file proves the
structural reason in the layer-wise quadratic model `L(δ) = δᵀ H δ`, with `H` the
(calibration) curvature, split into the *quantized* block (error `u`, fixed by rounding) and the
*free* block (update `v`, chosen to compensate):

`H = [[A, B], [Bᵀ, D]]`, `D ≻ 0`.

* `obs_split` — exact completion of the square:
  `L(u, v) = ‖D⁻¹Bᵀu + v‖²_D + uᵀ (A − B D⁻¹ Bᵀ) u`.
* `schur_le_loss`, `loss_vStar`, `loss_eq_schur_iff` — the best compensated loss is the Schur
  complement form, attained by the *unique* update `v* = −D⁻¹Bᵀu`.
* `schur_le_rtn`, `rtn_sub_schur`, `schur_lt_rtn_iff` — compensation never hurts, the gain is
  exactly `‖D⁻¹Bᵀu‖²_D`, and it is *strict iff* `Bᵀu ≠ 0` (error correlated with free weights).
* `inv_toBlocks₁₁`, `gptq_column_formula` — the quantized block of `H⁻¹` is the inverse Schur
  complement; for one column this is the GPTQ cost `e² / [H⁻¹]_qq`.
* `diag_mul_inv_diag_ge_one` — consequently `H_qq · [H⁻¹]_qq ≥ 1`.
* `schur_mono_window` — a wider compensation window never hurts (group-aligned lazy blocks).
* `tail_share_drops_iff` — compensation lowers a block's loss share iff its relative gain is
  larger than the rest's.
* `compensation_ratio_scale_invariant` — the GPTQ/RTN ratio is invariant under rescaling the
  error (changing the bit width at fixed error shape).

The `Net53` section records the measured ladder as exact rationals and checks the pre-registered
predictions.  A critic finding: the "P1 confirmed" verdict does not survive exact arithmetic
(`0.1512 > 0.15`, `p1_bar_missed`).  `no_rescaled_quadratic_model` connects data and theory: the
4-bit and 3-bit (grouped RTN, GPTQ) pairs cannot come from a single quadratic model with
rescaled errors.
-/

open Matrix

namespace GPTQSchur

variable {m n : Type*} [Fintype m] [Fintype n] [DecidableEq n]

/-- Quadratic layer-output loss `xᵀ H x`. -/
def qf {k : Type*} [Fintype k] (H : Matrix k k ℝ) (x : k → ℝ) : ℝ := x ⬝ᵥ (H *ᵥ x)

/-- Schur complement of the free block. -/
noncomputable def schur (A : Matrix m m ℝ) (B : Matrix m n ℝ) (D : Matrix n n ℝ) :
    Matrix m m ℝ := A - B * D⁻¹ * Bᵀ

/-- Optimal compensating update of the free weights. -/
noncomputable def vStar (B : Matrix m n ℝ) (D : Matrix n n ℝ) (u : m → ℝ) : n → ℝ :=
  -((D⁻¹ * Bᵀ) *ᵥ u)

theorem obs_split (A : Matrix m m ℝ) (B : Matrix m n ℝ) (D : Matrix n n ℝ)
    (hD : D.PosDef) (u : m → ℝ) (v : n → ℝ) :
    qf (fromBlocks A B Bᵀ D) (Sum.elim u v)
      = qf D ((D⁻¹ * Bᵀ) *ᵥ u + v) + qf (schur A B D) u := by
  haveI := hD.isUnit.invertible
  have h := schur_complement_eq₂₂ A B u v hD.1
  simp only [conjTranspose_eq_transpose_of_trivial, star_trivial] at h
  simp only [qf, schur, ← dotProduct_mulVec] at h ⊢
  rw [h]

omit [DecidableEq n] in
/-- The uncompensated (round-to-nearest) loss only sees the quantized block. -/
theorem qf_fromBlocks_zero (A : Matrix m m ℝ) (B : Matrix m n ℝ) (D : Matrix n n ℝ)
    (u : m → ℝ) : qf (fromBlocks A B Bᵀ D) (Sum.elim u 0) = qf A u := by
  simp [qf, fromBlocks_mulVec, dotProduct, Fintype.sum_sum_type]

theorem qf_nonneg_of_posDef {k : Type*} [Fintype k] {M : Matrix k k ℝ} (hM : M.PosDef)
    (x : k → ℝ) : 0 ≤ qf M x := by
  have := hM.posSemidef.dotProduct_mulVec_nonneg x
  simpa [qf] using this

theorem qf_pos_of_posDef {k : Type*} [Fintype k] {M : Matrix k k ℝ} (hM : M.PosDef)
    {x : k → ℝ} (hx : x ≠ 0) : 0 < qf M x := by
  have := hM.dotProduct_mulVec_pos hx
  simpa [qf] using this

theorem qf_eq_zero_iff_of_posDef {k : Type*} [Fintype k] {M : Matrix k k ℝ} (hM : M.PosDef)
    (x : k → ℝ) : qf M x = 0 ↔ x = 0 := by
  constructor
  · intro h
    by_contra hx
    exact (qf_pos_of_posDef hM hx).ne' h
  · rintro rfl
    simp [qf]

/-- Quadratic loss is homogeneous of degree two (rescaling of the error grid). -/
theorem qf_smul {k : Type*} [Fintype k] (M : Matrix k k ℝ) (t : ℝ) (x : k → ℝ) :
    qf M (t • x) = t ^ 2 * qf M x := by
  simp [qf, mulVec_smul, dotProduct_smul, smul_dotProduct, smul_eq_mul]
  ring

/-- **OBS lower bound.**  No compensating update of the free weights can do better than the
Schur-complement loss. -/
theorem schur_le_loss (A : Matrix m m ℝ) (B : Matrix m n ℝ) (D : Matrix n n ℝ)
    (hD : D.PosDef) (u : m → ℝ) (v : n → ℝ) :
    qf (schur A B D) u ≤ qf (fromBlocks A B Bᵀ D) (Sum.elim u v) := by
  rw [obs_split A B D hD u v]
  linarith [qf_nonneg_of_posDef hD ((D⁻¹ * Bᵀ) *ᵥ u + v)]

/-- **OBS attainment.**  The update `vStar` achieves the Schur-complement loss. -/
theorem loss_vStar (A : Matrix m m ℝ) (B : Matrix m n ℝ) (D : Matrix n n ℝ)
    (hD : D.PosDef) (u : m → ℝ) :
    qf (fromBlocks A B Bᵀ D) (Sum.elim u (vStar B D u)) = qf (schur A B D) u := by
  rw [obs_split A B D hD, vStar, add_neg_cancel]
  simp [qf]

/-- **Uniqueness.**  `vStar` is the *only* optimal compensating update. -/
theorem loss_eq_schur_iff (A : Matrix m m ℝ) (B : Matrix m n ℝ) (D : Matrix n n ℝ)
    (hD : D.PosDef) (u : m → ℝ) (v : n → ℝ) :
    qf (fromBlocks A B Bᵀ D) (Sum.elim u v) = qf (schur A B D) u ↔ v = vStar B D u := by
  rw [obs_split A B D hD]
  constructor
  · intro h
    have h0 : qf D ((D⁻¹ * Bᵀ) *ᵥ u + v) = 0 := by linarith
    rw [qf_eq_zero_iff_of_posDef hD] at h0
    rw [vStar, eq_neg_iff_add_eq_zero, add_comm]
    exact h0
  · rintro rfl
    rw [vStar, add_neg_cancel]
    simp [qf]

/-- **Exact compensation gain.**  The improvement of compensated quantization over plain
rounding is the `D`-energy of the optimal update. -/
theorem rtn_sub_schur (A : Matrix m m ℝ) (B : Matrix m n ℝ) (D : Matrix n n ℝ)
    (hD : D.PosDef) (u : m → ℝ) :
    qf A u - qf (schur A B D) u = qf D ((D⁻¹ * Bᵀ) *ᵥ u) := by
  have h := obs_split A B D hD u 0
  rw [qf_fromBlocks_zero, add_zero] at h
  linarith

/-- **Compensation never hurts.** -/
theorem schur_le_rtn (A : Matrix m m ℝ) (B : Matrix m n ℝ) (D : Matrix n n ℝ)
    (hD : D.PosDef) (u : m → ℝ) : qf (schur A B D) u ≤ qf A u := by
  linarith [rtn_sub_schur A B D hD u, qf_nonneg_of_posDef hD ((D⁻¹ * Bᵀ) *ᵥ u)]

/-- **Compensation strictly helps iff the error is correlated with the free weights.**
Strict improvement happens exactly when the cross-curvature `Bᵀ u` is nonzero. -/
theorem schur_lt_rtn_iff (A : Matrix m m ℝ) (B : Matrix m n ℝ) (D : Matrix n n ℝ)
    (hD : D.PosDef) (u : m → ℝ) : qf (schur A B D) u < qf A u ↔ Bᵀ *ᵥ u ≠ 0 := by
  haveI := hD.isUnit.invertible
  have hg := rtn_sub_schur A B D hD u
  have key : (D⁻¹ * Bᵀ) *ᵥ u = 0 ↔ Bᵀ *ᵥ u = 0 := by
    rw [← mulVec_mulVec]
    constructor
    · intro h
      have := congrArg (fun w => D *ᵥ w) h
      simpa [mulVec_mulVec, mul_inv_of_invertible] using this
    · intro h
      rw [h, mulVec_zero]
  constructor
  · intro hlt h0
    rw [← key] at h0
    rw [h0] at hg
    have hz : qf D 0 = 0 := by simp [qf]
    linarith
  · intro hne
    have hpos := qf_pos_of_posDef hD (x := (D⁻¹ * Bᵀ) *ᵥ u) (fun h => hne (key.mp h))
    linarith

/-- The compensated loss is nonnegative whenever the full curvature is positive semidefinite. -/
theorem schur_nonneg (A : Matrix m m ℝ) (B : Matrix m n ℝ) (D : Matrix n n ℝ)
    (hD : D.PosDef) (hH : (fromBlocks A B Bᵀ D).PosSemidef) (u : m → ℝ) :
    0 ≤ qf (schur A B D) u := by
  rw [← loss_vStar A B D hD u]
  have := hH.dotProduct_mulVec_nonneg (Sum.elim u (vStar B D u))
  simpa [qf] using this

/-- **Bit-width invariance of the compensation factor.**  Rescaling the error vector (changing
the grid step, i.e. changing the bit width at fixed error *shape*) leaves the ratio
`compensated / RTN` unchanged. -/
theorem compensation_ratio_scale_invariant (A : Matrix m m ℝ) (B : Matrix m n ℝ)
    (D : Matrix n n ℝ) (u : m → ℝ) {t : ℝ} (ht : t ≠ 0) :
    qf (schur A B D) (t • u) / qf A (t • u) = qf (schur A B D) u / qf A u := by
  rw [qf_smul, qf_smul]
  have : t ^ 2 ≠ 0 := pow_ne_zero 2 ht
  rw [mul_div_mul_left _ _ this]

/-- **Block inverse = inverse Schur complement.**  The quantized block of the inverse Hessian
is the inverse of the Schur complement. -/
theorem inv_toBlocks₁₁ [DecidableEq m] (A : Matrix m m ℝ) (B : Matrix m n ℝ)
    (D : Matrix n n ℝ) (hD : D.PosDef) (hH : IsUnit (fromBlocks A B Bᵀ D)) :
    ((fromBlocks A B Bᵀ D)⁻¹).toBlocks₁₁ = (schur A B D)⁻¹ := by
  letI := hD.isUnit.invertible
  letI := hH.invertible
  letI := invertibleOfFromBlocks₂₂Invertible A B Bᵀ D
  have h := invOf_fromBlocks₂₂_eq A B Bᵀ D
  rw [← invOf_eq_nonsing_inv, h, toBlocks_fromBlocks₁₁, schur, invOf_eq_nonsing_inv]
  simp only [invOf_eq_nonsing_inv]

omit [DecidableEq n] in
/-- The free block of a positive definite curvature is positive definite. -/
theorem posDef_of_fromBlocks {A : Matrix m m ℝ} {B : Matrix m n ℝ} {D : Matrix n n ℝ}
    (hH : (fromBlocks A B Bᵀ D).PosDef) : D.PosDef := by
  have hherm : D.IsHermitian := by
    have := hH.1
    rw [isHermitian_fromBlocks_iff] at this
    exact this.2.2.2
  refine PosDef.of_dotProduct_mulVec_pos hherm fun x hx => ?_
  have hne : (Sum.elim 0 x : m ⊕ n → ℝ) ≠ 0 := by
    intro h; apply hx; funext i; simpa using congrFun h (Sum.inr i)
  have := hH.dotProduct_mulVec_pos hne
  simpa [dotProduct, mulVec, fromBlocks, Fintype.sum_sum_type] using this

/-- **The GPTQ / OBS single-column formula.**  Quantizing one weight `q` with rounding error `e`
and optimally compensating all remaining weights costs exactly `e² / [H⁻¹]_{qq}`. -/
theorem gptq_column_formula (a : ℝ) (b : Matrix Unit n ℝ) (D : Matrix n n ℝ)
    (hH : (fromBlocks (of fun _ _ => a) b bᵀ D).PosDef) (e : ℝ) :
    qf (fromBlocks (of fun _ _ => a) b bᵀ D) (Sum.elim (fun _ => e) (vStar b D fun _ => e))
      = e ^ 2 / ((fromBlocks (of fun _ _ => a) b bᵀ D)⁻¹) (Sum.inl ()) (Sum.inl ()) := by
  have hD := posDef_of_fromBlocks hH
  set S := schur (of fun _ _ => a) b D with hS
  have hblk := inv_toBlocks₁₁ (of fun _ _ => a) b D hD hH.isUnit
  have hentry : ((fromBlocks (of fun _ _ => a) b bᵀ D)⁻¹) (Sum.inl ()) (Sum.inl ())
      = (S⁻¹) () () := by
    rw [← hblk]; rfl
  -- the Schur complement is a positive scalar
  have hSpos : 0 < S () () := by
    have h1 := qf_pos_of_posDef hH (x := Sum.elim (fun _ : Unit => (1:ℝ)) (vStar b D fun _ => 1))
      (by intro h; have := congrFun h (Sum.inl ()); simp at this)
    rw [loss_vStar _ _ _ hD] at h1
    simpa [qf, hS, mulVec, dotProduct] using h1
  have hinv : (S⁻¹) () () = (S () ())⁻¹ := by
    simp
  rw [loss_vStar _ _ _ hD, hentry, hinv]
  simp [qf, mulVec, dotProduct, ← hS]
  field_simp

/-- **Diagonal curvature inequality** `H_qq · [H⁻¹]_qq ≥ 1`, derived from "compensation never
hurts": the compensated per-column cost `e²/[H⁻¹]_qq` never exceeds the RTN cost `H_qq e²`. -/
theorem diag_mul_inv_diag_ge_one (a : ℝ) (b : Matrix Unit n ℝ) (D : Matrix n n ℝ)
    (hH : (fromBlocks (of fun _ _ => a) b bᵀ D).PosDef) :
    1 ≤ a * ((fromBlocks (of fun _ _ => a) b bᵀ D)⁻¹) (Sum.inl ()) (Sum.inl ()) := by
  have hD := posDef_of_fromBlocks hH
  have hf := gptq_column_formula a b D hH 1
  have hle := schur_le_rtn (of fun _ _ => a) b D hD (fun _ => 1)
  rw [← loss_vStar _ _ _ hD] at hle
  rw [hf] at hle
  have hA : qf (of fun _ _ => a : Matrix Unit Unit ℝ) (fun _ => 1) = a := by
    simp [qf, mulVec, dotProduct]
  rw [hA] at hle
  set h := ((fromBlocks (of fun _ _ => a) b bᵀ D)⁻¹) (Sum.inl ()) (Sum.inl ())
  have hpos : 0 < h := by
    have := hH.inv.diag_pos (i := Sum.inl ())
    simpa using this
  rw [one_pow, div_le_iff₀ hpos] at hle
  linarith

omit [DecidableEq n] in
/-- Freezing part of the free weights at zero is the same as working with the smaller block. -/
theorem qf_restrict {n₁ n₂ : Type*} [Fintype n₁] [Fintype n₂] (A : Matrix m m ℝ)
    (B : Matrix m (n₁ ⊕ n₂) ℝ) (D : Matrix (n₁ ⊕ n₂) (n₁ ⊕ n₂) ℝ) (u : m → ℝ) (v : n₁ → ℝ) :
    qf (fromBlocks A B Bᵀ D) (Sum.elim u (Sum.elim v 0))
      = qf (fromBlocks A (B.submatrix id Sum.inl) (B.submatrix id Sum.inl)ᵀ
          (D.submatrix Sum.inl Sum.inl)) (Sum.elim u v) := by
  simp [qf, dotProduct, Fintype.sum_sum_type, mulVec]

/-- **Wider compensation windows never hurt.**  Compensating with all free weights is at
least as good as compensating with any sub-window `n₁`. -/
theorem schur_mono_window {n₁ n₂ : Type*} [Fintype n₁] [Fintype n₂] [DecidableEq n₁]
    [DecidableEq n₂] (A : Matrix m m ℝ) (B : Matrix m (n₁ ⊕ n₂) ℝ)
    (D : Matrix (n₁ ⊕ n₂) (n₁ ⊕ n₂) ℝ) (hD : D.PosDef) (u : m → ℝ) :
    qf (schur A B D) u
      ≤ qf (schur A (B.submatrix id Sum.inl) (D.submatrix Sum.inl Sum.inl)) u := by
  have hD₁ : (D.submatrix Sum.inl Sum.inl).PosDef := by
    refine PosDef.of_dotProduct_mulVec_pos (hD.1.submatrix _) fun x hx => ?_
    have hne : (Sum.elim x 0 : n₁ ⊕ n₂ → ℝ) ≠ 0 := by
      intro h; apply hx; funext i; simpa using congrFun h (Sum.inl i)
    have := hD.dotProduct_mulVec_pos hne
    simpa [dotProduct, mulVec, Fintype.sum_sum_type] using this
  have h := schur_le_loss A B D hD u
    (Sum.elim (vStar (B.submatrix id Sum.inl) (D.submatrix Sum.inl Sum.inl) u) 0)
  rw [qf_restrict, loss_vStar _ _ _ hD₁] at h
  exact h


/-- **Tail-share compression criterion.**  Let a core block and a tail block have RTN costs
`a, b > 0` and compensation gains `gₐ, g_b` (each smaller than its cost, e.g. given by
`rtn_sub_schur`).  Compensation strictly lowers the tail's share of the total loss iff the
tail's *relative* gain exceeds the core's. -/
theorem tail_share_drops_iff {a b ga gb : ℝ} (ha : 0 < a) (hb : 0 < b) (hga : ga < a)
    (hgb : gb < b) :
    (b - gb) / ((a - ga) + (b - gb)) < b / (a + b) ↔ ga / a < gb / b := by
  rw [div_lt_div_iff₀ (by linarith) (by linarith), div_lt_div_iff₀ ha hb]
  constructor <;> intro h <;> nlinarith

/-! ## NET-53 lab notes: the measured ladder, checked against the theory -/

namespace Net53

/-- Measured ΔCE values (Qwen2.5-0.5B, ctx 512), NET-52 / NET-53. -/
def perChannel4 : ℚ := 788 / 1000
def groupedRTN4 : ℚ := 318 / 1000
def gptq4 : ℚ := 1512 / 10000
def gptq4Core : ℚ := 1235 / 10000
def perChannel3 : ℚ := 923 / 100
def groupedRTN3 : ℚ := 272 / 100
def gptq3 : ℚ := 11932 / 10000

/-- **Critic finding: P1 is not confirmed at the reported precision.**  The pre-registered bar
was `ΔCE ≤ 0.15`; the measurement `0.1512` exceeds it (by `0.0012`). -/
theorem p1_bar_missed : (15 : ℚ) / 100 < gptq4 ∧ gptq4 - 15 / 100 = 12 / 10000 := by
  constructor <;> norm_num [gptq4]

/-- The tail increment is exactly `ALL − CORE = 0.0277`. -/
theorem tail_increment : gptq4 - gptq4Core = 277 / 10000 := by norm_num [gptq4, gptq4Core]

/-- **P3 refuted.**  The L22/L23 tail share of the compensated total lies in `(1/6, 1/5)`,
well below the pre-registered `1/4`. -/
theorem tail_share_bounds :
    1 / 6 < (gptq4 - gptq4Core) / gptq4 ∧ (gptq4 - gptq4Core) / gptq4 < 1 / 5 := by
  constructor <;> norm_num [gptq4, gptq4Core]

/-- Compensation lever at 4 bits: grouped RTN / GPTQ `∈ [2.1, 2.11)`. -/
theorem lever4 : 21 / 10 ≤ groupedRTN4 / gptq4 ∧ groupedRTN4 / gptq4 < 211 / 100 := by
  constructor <;> norm_num [groupedRTN4, gptq4]

/-- **Compensation lever is nearly bit-invariant** (within 9 %), as the scale-invariance theorem
predicts in the quadratic regime. -/
theorem compensation_lever_nearly_invariant :
    1 < (groupedRTN3 / gptq3) / (groupedRTN4 / gptq4) ∧
      (groupedRTN3 / gptq3) / (groupedRTN4 / gptq4) < 109 / 100 := by
  constructor <;> norm_num [groupedRTN3, gptq3, groupedRTN4, gptq4]

/-- **The grouping lever is not bit-invariant** (it grows by more than 35 % from 4 to 3 bits):
grouping changes the *shape* of the error (outlier-driven scale), not just its size. -/
theorem grouping_lever_not_invariant :
    135 / 100 < (perChannel3 / groupedRTN3) / (perChannel4 / groupedRTN4) := by
  norm_num [perChannel3, groupedRTN3, perChannel4, groupedRTN4]

/-- **Bonus law, quantified.**  The compounded lever (per-channel RTN → grouped GPTQ) is
`> 5×` at 4 bits and `> 7.7×` at 3 bits. -/
theorem compounded_levers :
    5 < perChannel4 / gptq4 ∧ 77 / 10 < perChannel3 / gptq3 := by
  constructor <;> norm_num [perChannel4, gptq4, perChannel3, gptq3]

/-- **Falsification bridge.**  No single fixed quadratic curvature model in which the 3-bit
error vector is a rescaling of the 4-bit error vector can reproduce both measured
(grouped RTN, GPTQ) pairs: by `compensation_ratio_scale_invariant` the two ratios would have to
coincide, but they differ.  Hence the 8 % lever drift measures genuine change of error shape
(or non-quadratic loss) between 4 and 3 bits. -/
theorem no_rescaled_quadratic_model {m n : Type*} [Fintype m] [Fintype n] [DecidableEq n]
    (A : Matrix m m ℝ) (B : Matrix m n ℝ) (D : Matrix n n ℝ) (u : m → ℝ) (t : ℝ)
    (ht : t ≠ 0) :
    ¬ (qf A u = (groupedRTN4 : ℝ) ∧ qf (schur A B D) u = (gptq4 : ℝ) ∧
        qf A (t • u) = (groupedRTN3 : ℝ) ∧ qf (schur A B D) (t • u) = (gptq3 : ℝ)) := by
  rintro ⟨h1, h2, h3, h4⟩
  have h := compensation_ratio_scale_invariant A B D u ht
  rw [h1, h2, h3, h4] at h
  norm_num [groupedRTN4, gptq4, groupedRTN3, gptq3] at h

end Net53

end GPTQSchur