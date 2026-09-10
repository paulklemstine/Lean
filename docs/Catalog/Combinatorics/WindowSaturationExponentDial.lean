/-
# Cycle 5: the exponent dial and the effective window size

The previous cycles measured a saturation edge `B*` for one *fixed* weight
(the harmonic one).  This file introduces the **exponent dial**

  `dial α i = i^{-α}`,   `α ≥ 0`,

which interpolates between the uniform weight (`α = 0`), the sqrt weight
(`α = 1/2`) and the harmonic weight (`α = 1`), and isolates the single scalar
through which the dial acts on the window statistic of
`Combinatorics.WindowSaturationMatchedFilter`:

  `ess w B = (∑_{i≤B} w i)² / (∑_{i≤B} w i²)`,

the **effective window size** (a Kish effective sample size).  The bridge
`uniformModel_R2` shows that on the canonical uniform orthonormal window model
of size `m` the catalog score is exactly

  `R²(w, B) = ess w B / m`,

so every statement about saturation of `R²` is a statement about `ess`, and the
window edge enters only through `ess`.

Structural results proved here:

* `ess_le_card` — `ess w B ≤ B` (Cauchy–Schwarz): the dial can only *lose*
  effective columns relative to the uniform weight.
* `ess_const` — the uniform dial `α = 0` attains the bound, `ess = B`.
* `ess_smul` — **`ess` is invariant under rescaling the weight**.  This is the
  formal version of "saturation is data-driven, not mass-driven": the total
  mass of the weight profile carries *no* information about the saturation
  edge, only its shape does.
* `ess_mono` — for an antitone positive weight the effective window size is
  nondecreasing in the window edge (false for general positive weights, see
  `ess_not_mono`), so a saturation threshold is crossed once and for all.
* `ess_dial` — squaring the dial shifts the exponent: `ess (dial α) B` is the
  ratio `P α B ^ 2 / P (2α) B` of two power sums.  All the analysis of the
  dial therefore reduces to power sums, carried out in
  `Combinatorics.WindowSaturationPowerSums`.
-/
import Combinatorics.WindowSaturationMatchedFilter

open Finset

namespace WindowSaturation

namespace Dial

/-! ## The effective window size -/

/-- The window mass `∑_{i=1}^{B} w i`. -/
def wsum (w : ℕ → ℝ) (B : ℕ) : ℝ := ∑ i ∈ range B, w (i + 1)

/-- The window square mass `∑_{i=1}^{B} (w i)²`. -/
def wsq (w : ℕ → ℝ) (B : ℕ) : ℝ := ∑ i ∈ range B, (w (i + 1)) ^ 2

/-- The **effective window size** `(∑ w)² / (∑ w²)` of the first `B` columns. -/
noncomputable def ess (w : ℕ → ℝ) (B : ℕ) : ℝ := (wsum w B) ^ 2 / wsq w B

@[simp] lemma wsum_zero (w : ℕ → ℝ) : wsum w 0 = 0 := by simp [wsum]

@[simp] lemma wsq_zero (w : ℕ → ℝ) : wsq w 0 = 0 := by simp [wsq]

lemma wsum_succ (w : ℕ → ℝ) (B : ℕ) : wsum w (B + 1) = wsum w B + w (B + 1) :=
  Finset.sum_range_succ _ _

lemma wsq_succ (w : ℕ → ℝ) (B : ℕ) : wsq w (B + 1) = wsq w B + (w (B + 1)) ^ 2 :=
  Finset.sum_range_succ _ _

lemma wsq_nonneg (w : ℕ → ℝ) (B : ℕ) : 0 ≤ wsq w B :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

lemma wsq_pos {w : ℕ → ℝ} {B : ℕ} (hB : 1 ≤ B) (hw : ∀ i, 1 ≤ i → i ≤ B → w i ≠ 0) :
    0 < wsq w B := by
  refine Finset.sum_pos' (fun i _ => sq_nonneg _) ⟨0, Finset.mem_range.mpr hB, ?_⟩
  exact sq_pos_of_ne_zero (hw 1 le_rfl hB)

lemma wsum_nonneg {w : ℕ → ℝ} {B : ℕ} (hw : ∀ i, 0 ≤ w i) : 0 ≤ wsum w B :=
  Finset.sum_nonneg fun _ _ => hw _

lemma ess_nonneg (w : ℕ → ℝ) (B : ℕ) : 0 ≤ ess w B :=
  div_nonneg (sq_nonneg _) (wsq_nonneg w B)

@[simp] lemma ess_zero (w : ℕ → ℝ) : ess w 0 = 0 := by simp [ess]

/-- **Cauchy–Schwarz bound.**  The effective window size never exceeds the number
of columns in the window: no dial can manufacture columns. -/
theorem ess_le_card (w : ℕ → ℝ) (B : ℕ) : ess w B ≤ B := by
  rcases eq_or_lt_of_le (wsq_nonneg w B) with h | h
  · rw [ess, ← h, div_zero]
    exact Nat.cast_nonneg B
  · rw [ess, div_le_iff₀ h]
    have := sq_sum_le_card_mul_sum_sq (s := range B) (f := fun i => w (i + 1))
    simpa [wsum, wsq, mul_comm] using this

/-- **Mass invariance.**  Rescaling the whole weight profile leaves the effective
window size unchanged: saturation is a property of the *shape* of the dial, not
of its total mass. -/
theorem ess_smul (c : ℝ) (hc : c ≠ 0) (w : ℕ → ℝ) (B : ℕ) :
    ess (fun i => c * w i) B = ess w B := by
  have h1 : wsum (fun i => c * w i) B = c * wsum w B := by
    simp [wsum, Finset.mul_sum]
  have h2 : wsq (fun i => c * w i) B = c ^ 2 * wsq w B := by
    simp [wsq, Finset.mul_sum, mul_pow]
  rw [ess, ess, h1, h2, mul_pow]
  rcases eq_or_lt_of_le (wsq_nonneg w B) with h | h
  · rw [← h]; simp
  · rw [mul_div_mul_left _ _ (pow_ne_zero 2 hc)]

/-- The uniform dial (`α = 0`) attains the Cauchy–Schwarz bound: every column in
the window counts in full. -/
theorem ess_const {c : ℝ} (hc : c ≠ 0) (B : ℕ) : ess (fun _ => c) B = B := by
  have h1 : wsum (fun _ => c) B = B * c := by simp [wsum, mul_comm]
  have h2 : wsq (fun _ => c) B = B * c ^ 2 := by simp [wsq]
  rcases Nat.eq_zero_or_pos B with hB | hB
  · simp [hB]
  · have hBne : (B : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
    rw [ess, h1, h2, mul_pow]
    field_simp

/-! ## Monotonicity in the window edge -/

/-- **One-step monotonicity for an antitone dial.**  If the weight is positive
and nonincreasing then opening the window by one column cannot decrease the
effective window size. -/
theorem ess_le_ess_succ {w : ℕ → ℝ} {B : ℕ} (hpos : ∀ i, 1 ≤ i → 0 < w i)
    (hanti : ∀ i j, 1 ≤ i → i ≤ j → w j ≤ w i) :
    ess w B ≤ ess w (B + 1) := by
  have hppos : 0 < w (B + 1) := hpos (B + 1) (by omega)
  have hSnn : 0 ≤ wsq w B := wsq_nonneg w B
  have hAnn : 0 ≤ wsum w B := Finset.sum_nonneg fun i _ => (hpos (i + 1) (by omega)).le
  -- the window mass dominates `B` copies of the newest (smallest) weight
  have hAB : (B : ℝ) * w (B + 1) ≤ wsum w B := by
    have hterm : ∀ i ∈ range B, w (B + 1) ≤ w (i + 1) := by
      intro i hi
      have hi' := Finset.mem_range.mp hi
      exact hanti (i + 1) (B + 1) (by omega) (by omega)
    calc (B : ℝ) * w (B + 1) = ∑ _i ∈ range B, w (B + 1) := by
          simp
      _ ≤ ∑ i ∈ range B, w (i + 1) := Finset.sum_le_sum hterm
      _ = wsum w B := rfl
  -- Cauchy–Schwarz inside the window
  have hCS : (wsum w B) ^ 2 ≤ (B : ℝ) * wsq w B := by
    have := sq_sum_le_card_mul_sum_sq (s := range B) (f := fun i => w (i + 1))
    simpa [wsum, wsq] using this
  rw [ess, ess, wsum_succ, wsq_succ]
  rcases eq_or_lt_of_le hSnn with h0 | h0
  · have hA0 : wsum w B = 0 := by nlinarith
    rw [hA0, ← h0, zero_pow (by norm_num), zero_div]
    positivity
  · rw [div_le_div_iff₀ h0 (by positivity)]
    have h1 : (wsum w B) ^ 2 * w (B + 1) ≤ (B : ℝ) * wsq w B * w (B + 1) :=
      mul_le_mul_of_nonneg_right hCS hppos.le
    have h2 : (B : ℝ) * w (B + 1) * wsq w B ≤ wsum w B * wsq w B :=
      mul_le_mul_of_nonneg_right hAB hSnn
    have key : (wsum w B) ^ 2 * w (B + 1)
        ≤ 2 * (wsum w B * wsq w B) + wsq w B * w (B + 1) := by
      nlinarith [mul_nonneg hAnn hSnn, mul_nonneg hSnn hppos.le]
    nlinarith [mul_le_mul_of_nonneg_right key hppos.le]

/-- The effective window size is nondecreasing in the window edge for an antitone
positive dial: a saturation threshold, once crossed, stays crossed. -/
theorem ess_mono {w : ℕ → ℝ} (hpos : ∀ i, 1 ≤ i → 0 < w i)
    (hanti : ∀ i j, 1 ≤ i → i ≤ j → w j ≤ w i) {B C : ℕ} (h : B ≤ C) :
    ess w B ≤ ess w C := by
  induction C with
  | zero => simp_all
  | succ k ih =>
      rcases Nat.lt_or_ge k B with hk | hk
      · have : B = k + 1 := by omega
        rw [this]
      · exact le_trans (ih hk) (ess_le_ess_succ hpos hanti)

/-! ## The exponent dial -/

/-- The **exponent dial**: the weight profile `i ↦ i^{-α}`.  `α = 0` is the
uniform weight, `α = 1/2` the sqrt weight, `α = 1` the harmonic weight. -/
noncomputable def dial (alpha : ℝ) (i : ℕ) : ℝ := (i : ℝ) ^ (-alpha)

lemma dial_pos {alpha : ℝ} {i : ℕ} (hi : 1 ≤ i) : 0 < dial alpha i :=
  Real.rpow_pos_of_pos (by exact_mod_cast hi) _

lemma dial_anti {alpha : ℝ} (ha : 0 ≤ alpha) {i j : ℕ} (hi : 1 ≤ i) (hij : i ≤ j) :
    dial alpha j ≤ dial alpha i :=
  Real.rpow_le_rpow_of_nonpos (by exact_mod_cast hi) (by exact_mod_cast hij)
    (neg_nonpos.mpr ha)

@[simp] lemma dial_one_apply {i : ℕ} (hi : 1 ≤ i) : dial 1 i = 1 / (i : ℝ) := by
  have : (0:ℝ) < i := by exact_mod_cast hi
  rw [dial, Real.rpow_neg_one, one_div]

/-- Squaring the dial doubles the exponent. -/
lemma dial_sq {alpha : ℝ} {i : ℕ} (hi : 1 ≤ i) : (dial alpha i) ^ 2 = dial (2 * alpha) i := by
  have hx : (0:ℝ) < i := by exact_mod_cast hi
  rw [dial, dial, ← Real.rpow_natCast ((i : ℝ) ^ (-alpha)) 2, ← Real.rpow_mul hx.le]
  ring_nf

/-- The square mass of the `α`-dial is the window mass of the `2α`-dial. -/
lemma wsq_dial (alpha : ℝ) (B : ℕ) : wsq (dial alpha) B = wsum (dial (2 * alpha)) B :=
  Finset.sum_congr rfl fun i _ => dial_sq (by omega)

/-- **The dial reduces to power sums**: `ess (dial α) B = P_α(B)² / P_{2α}(B)`. -/
theorem ess_dial (alpha : ℝ) (B : ℕ) :
    ess (dial alpha) B = (wsum (dial alpha) B) ^ 2 / wsum (dial (2 * alpha)) B := by
  rw [ess, wsq_dial]

lemma ess_dial_mono {alpha : ℝ} (ha : 0 ≤ alpha) {B C : ℕ} (h : B ≤ C) :
    ess (dial alpha) B ≤ ess (dial alpha) C :=
  ess_mono (fun _ hi => dial_pos hi) (fun _ _ hi hij => dial_anti ha hi hij) h

/-! ## The bridge to the catalog window statistic

The dial acts on the canonical *uniform orthonormal window model*: `m`
orthonormal columns, each carrying unit signal.  On that model the catalog score
`R²` of `Combinatorics.WindowSaturationMatchedFilter` is exactly the effective
window size, normalised by the number of columns. -/

/-- The standard basis of `ℝᵐ`, indexed by `ℕ`. -/
def stdCol (m : ℕ) (i : ℕ) : Fin m → ℝ := fun j => if (j : ℕ) = i then 1 else 0

lemma dot_stdCol {m i k : ℕ} (hi : i < m) :
    dot (stdCol m i) (stdCol m k) = if i = k then 1 else 0 := by
  simp only [dot, stdCol]
  rw [Finset.sum_eq_single (⟨i, hi⟩ : Fin m)]
  · by_cases h : i = k <;> simp [h]
  · intro b _ hb
    have : (b : ℕ) ≠ i := by
      intro hbi
      exact hb (Fin.ext hbi)
    simp [this]
  · intro h
    exact absurd (Finset.mem_univ _) h

/-- The **uniform orthonormal window model**: `m` orthonormal columns and the
all-ones response, so that every column carries unit signal and unit mass. -/
def uniformModel (m : ℕ) (hm : 0 < m) : Model m m where
  v := stdCol m
  y := fun _ => 1
  self_pos := by
    intro i hi
    rw [dot_stdCol hi, if_pos rfl]
    norm_num
  orth := by
    intro i hi k _ hik
    rw [dot_stdCol hi, if_neg hik]
  resp_pos := by
    simp only [dot, mul_one, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    exact_mod_cast hm

lemma uniformModel_a {m i : ℕ} (hm : 0 < m) (hi : i < m) : (uniformModel m hm).a i = 1 := by
  show dot (stdCol m i) (fun _ => 1) = 1
  simp only [dot, stdCol]
  rw [Finset.sum_eq_single (⟨i, hi⟩ : Fin m)]
  · simp
  · intro b _ hb
    have : (b : ℕ) ≠ i := fun hbi => hb (Fin.ext hbi)
    simp [this]
  · intro h
    exact absurd (Finset.mem_univ _) h

lemma uniformModel_s {m i : ℕ} (hm : 0 < m) (hi : i < m) : (uniformModel m hm).s i = 1 := by
  show dot (stdCol m i) (stdCol m i) = 1
  rw [dot_stdCol hi, if_pos rfl]

lemma uniformModel_yy {m : ℕ} (hm : 0 < m) :
    dot (uniformModel m hm).y (uniformModel m hm).y = m := by
  show dot (fun _ => (1:ℝ)) (fun _ => (1:ℝ)) = m
  simp [dot]

/-- **The bridge.**  On the uniform orthonormal window model the catalog window
score is the effective window size divided by the number of columns.  Saturation
of `R²` and saturation of `ess` are therefore the same phenomenon. -/
theorem uniformModel_R2 {m B : ℕ} (hm : 0 < m) (hBm : B ≤ m) (w : ℕ → ℝ) :
    (uniformModel m hm).R2 (fun i => w (i + 1)) B = ess w B / m := by
  have hnum : (uniformModel m hm).num (fun i => w (i + 1)) B = wsum w B := by
    refine Finset.sum_congr rfl fun i hi => ?_
    rw [uniformModel_a hm (lt_of_lt_of_le (Finset.mem_range.mp hi) hBm), mul_one]
  have hden : (uniformModel m hm).den (fun i => w (i + 1)) B = wsq w B := by
    refine Finset.sum_congr rfl fun i hi => ?_
    rw [uniformModel_s hm (lt_of_lt_of_le (Finset.mem_range.mp hi) hBm), mul_one]
  rw [Model.R2, hnum, hden, uniformModel_yy hm, ess, div_div]

end Dial

end WindowSaturation