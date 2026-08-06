import Novelty.IITTensorNetworkWeightedGHZ

/-! # Integrated information of the W state

The `n`-qubit W state `|W⟩ = n^{-1/2} ∑ᵢ |0⋯1ᵢ⋯0⟩` is, like the GHZ state, a
matrix product state of bond dimension `2` with Schmidt rank `2` across every
bipartition.  Nevertheless its integrated information is strictly smaller, and
tends to `0` as the chain grows: cutting after site `l` gives the Schmidt
spectrum `{l/n, (n-l)/n}`, so the mutual information across that cut is
`2 H₂(l/n)`, and

`Φ(W_n) = 2 H₂(1/n) → 0`.

Main results:

* `wt_glue`, `card_wt_eq_one` — the Hamming-weight combinatorics of a cut;
* `chainCutMatrix_wState_schmidtForm` — the cut matrix of `W_n` in Schmidt form
  with coefficients `√(l/n)`, `√((n-l)/n)`;
* `mutualInformation_chainCutMatrix_wState` — `I_l = 2 H₂(l/n)`;
* `schmidtRank_chainCutMatrix_wState` — the Schmidt rank is `2` at every cut;
* `phi_wState` — `Φ(W_n) = 2 H₂(1/n)`;
* `phi_wState_lt_phi_ghz` — for `n ≥ 3` the W state has strictly less integrated
  information than the GHZ state of the same bond dimension and Schmidt rank.
-/

open Finset Matrix
open scoped ComplexOrder

namespace IITTensorNetwork

/-! ## Hamming weight combinatorics -/

section Weight

/-- The Hamming weight of a qubit-chain configuration. -/
def wt {k : ℕ} (f : Fin k → Fin 2) : ℕ := (Finset.univ.filter (fun i => f i = 1)).card

lemma wt_eq_sum {k : ℕ} (f : Fin k → Fin 2) : wt f = ∑ i, if f i = 1 then 1 else 0 := by
  rw [wt, Finset.card_filter]

lemma wt_eq_zero_iff {k : ℕ} (f : Fin k → Fin 2) : wt f = 0 ↔ ∀ i, f i = 0 := by
  rw [wt, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  constructor
  · intro h i
    have := h (Finset.mem_univ i)
    omega
  · intro h i _
    rw [h i]
    decide

/-- The one-hot configuration with a `1` at site `i`. -/
def oneHot {k : ℕ} (i : Fin k) : Fin k → Fin 2 := fun j => if j = i then 1 else 0

lemma wt_oneHot {k : ℕ} (i : Fin k) : wt (oneHot i) = 1 := by
  rw [wt, show (Finset.univ.filter (fun j => oneHot i j = 1)) = {i} from ?_]
  · exact Finset.card_singleton i
  · ext j
    by_cases h : j = i <;> simp [oneHot, h]

/-- There are exactly `k` configurations of weight one. -/
lemma card_wt_eq_one {k : ℕ} :
    (Finset.univ.filter (fun f : Fin k → Fin 2 => wt f = 1)).card = k := by
  have himage : (Finset.univ.filter (fun f : Fin k → Fin 2 => wt f = 1))
      = Finset.image oneHot Finset.univ := by
    ext f
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image]
    constructor
    · intro hf
      obtain ⟨i, hi⟩ := Finset.card_eq_one.mp hf
      refine ⟨i, ?_⟩
      funext j
      by_cases hj : j = i
      · subst hj
        have : j ∈ Finset.univ.filter (fun i => f i = 1) := by
          rw [hi]; exact Finset.mem_singleton_self j
        simp only [Finset.mem_filter] at this
        simp [oneHot, this.2]
      · have : j ∉ Finset.univ.filter (fun i => f i = 1) := by
          rw [hi, Finset.mem_singleton]
          exact hj
        simp only [Finset.mem_filter, Finset.mem_univ, true_and] at this
        simp [oneHot, hj]
        omega
    · rintro ⟨i, rfl⟩
      exact wt_oneHot i
  rw [himage, Finset.card_image_of_injective _ ?_, Finset.card_univ, Fintype.card_fin]
  intro a b hab
  have := congrFun hab a
  by_cases h : a = b
  · exact h
  · simp [oneHot, h] at this

/-- There is exactly one configuration of weight zero. -/
lemma card_wt_eq_zero {k : ℕ} :
    (Finset.univ.filter (fun f : Fin k → Fin 2 => wt f = 0)).card = 1 := by
  rw [show (Finset.univ.filter (fun f : Fin k → Fin 2 => wt f = 0))
      = {fun _ => 0} from ?_, Finset.card_singleton]
  ext f
  simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton]
  rw [wt_eq_zero_iff]
  constructor
  · intro h; funext i; exact h i
  · intro h i; rw [h]

/-- The weight of a glued configuration is the sum of the weights of the two
blocks. -/
lemma wt_glue {n l : ℕ} (hl : l ≤ n) (f : Fin l → Fin 2) (g : Fin (n - l) → Fin 2) :
    wt (glue l hl f g) = wt f + wt g := by
  classical
  set F : ℕ → ℕ := fun i => if h : i < n then (if glue l hl f g ⟨i, h⟩ = 1 then 1 else 0) else 0
    with hF
  set Gf : ℕ → ℕ := fun i => if h : i < l then (if f ⟨i, h⟩ = 1 then 1 else 0) else 0 with hGf
  set Gg : ℕ → ℕ := fun j => if h : j < n - l then (if g ⟨j, h⟩ = 1 then 1 else 0) else 0 with hGg
  have h1 : wt (glue l hl f g) = ∑ i ∈ Finset.range n, F i := by
    rw [wt_eq_sum, ← Fin.sum_univ_eq_sum_range F n]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [hF]
    simp [i.isLt]
  have hf1 : wt f = ∑ i ∈ Finset.range l, Gf i := by
    rw [wt_eq_sum, ← Fin.sum_univ_eq_sum_range Gf l]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [hGf]
    simp [i.isLt]
  have hg1 : wt g = ∑ j ∈ Finset.range (n - l), Gg j := by
    rw [wt_eq_sum, ← Fin.sum_univ_eq_sum_range Gg (n - l)]
    refine Finset.sum_congr rfl fun j _ => ?_
    rw [hGg]
    simp [j.isLt]
  have hsplit : ∑ i ∈ Finset.range n, F i
      = ∑ i ∈ Finset.range l, F i + ∑ j ∈ Finset.range (n - l), F (l + j) := by
    rw [Finset.range_eq_Ico, ← Finset.sum_Ico_consecutive F (Nat.zero_le l) hl]
    congr 1
    rw [Finset.sum_Ico_eq_sum_range, Finset.range_eq_Ico]
  have h2 : ∀ i ∈ Finset.range l, F i = Gf i := by
    intro i hi
    rw [Finset.mem_range] at hi
    have hin : i < n := lt_of_lt_of_le hi hl
    rw [hF, hGf]
    simp only [dif_pos hin, dif_pos hi, glue]
  have h3 : ∀ j ∈ Finset.range (n - l), F (l + j) = Gg j := by
    intro j hj
    rw [Finset.mem_range] at hj
    have hjn : l + j < n := by omega
    rw [hF, hGg]
    simp only [dif_pos hjn, dif_pos hj, glue]
    rw [dif_neg (by omega)]
    congr 2
    apply Fin.ext
    simp
  rw [h1, hsplit, Finset.sum_congr rfl h2, Finset.sum_congr rfl h3, hf1, hg1]

/-- Sum of a constant over the weight-one configurations. -/
lemma sum_ite_wt_one (k : ℕ) (c : ℂ) :
    ∑ f : Fin k → Fin 2, (if wt f = 1 then c else 0) = (k : ℂ) * c := by
  rw [← Finset.sum_filter, Finset.sum_const, card_wt_eq_one, nsmul_eq_mul]

/-- Sum of a constant over the (unique) weight-zero configuration. -/
lemma sum_ite_wt_zero (k : ℕ) (c : ℂ) :
    ∑ f : Fin k → Fin 2, (if wt f = 0 then c else 0) = c := by
  rw [← Finset.sum_filter, Finset.sum_const, card_wt_eq_zero, one_nsmul]

end Weight

/-! ## The W state and its Schmidt form -/

section WState

/-- The `n`-qubit **W state** `n^{-1/2} ∑ᵢ |0⋯1ᵢ⋯0⟩`. -/
noncomputable def wState (n : ℕ) : (Fin n → Fin 2) → ℂ :=
  fun s => if wt s = 1 then (((Real.sqrt n)⁻¹ : ℝ) : ℂ) else 0

/-- The W state is normalized. -/
theorem wState_normalized {n : ℕ} (hn : 1 ≤ n) : ∑ s, ‖wState n s‖ ^ 2 = 1 := by
  have hn' : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hval : ∀ s : Fin n → Fin 2, ‖wState n s‖ ^ 2 = if wt s = 1 then ((n : ℝ))⁻¹ else 0 := by
    intro s
    by_cases h : wt s = 1
    · rw [if_pos h]
      simp only [wState, if_pos h, Complex.norm_real, Real.norm_eq_abs,
        abs_of_nonneg (by positivity : (0:ℝ) ≤ (Real.sqrt n)⁻¹)]
      rw [sq, ← mul_inv, Real.mul_self_sqrt hn'.le]
    · simp [wState, h]
  rw [Finset.sum_congr rfl (fun s _ => hval s), ← Finset.sum_filter, Finset.sum_const,
    card_wt_eq_one, nsmul_eq_mul, mul_inv_cancel₀ (ne_of_gt hn')]

/-- The left isometry of the Schmidt form of a W-state cut: the normalized
`W`-vector of the left block and the all-zero configuration. -/
noncomputable def wLeftIso (l : ℕ) : Matrix (Fin l → Fin 2) (Fin 2) ℂ :=
  Matrix.of fun f x =>
    if x = 0 then (if wt f = 1 then (((Real.sqrt l)⁻¹ : ℝ) : ℂ) else 0)
    else (if wt f = 0 then 1 else 0)

/-- The right isometry of the Schmidt form of a W-state cut. -/
noncomputable def wRightIso (m : ℕ) : Matrix (Fin m → Fin 2) (Fin 2) ℂ :=
  Matrix.of fun g x =>
    if x = 0 then (if wt g = 0 then 1 else 0)
    else (if wt g = 1 then (((Real.sqrt m)⁻¹ : ℝ) : ℂ) else 0)

lemma wLeftIso_isometry {l : ℕ} (hl : 1 ≤ l) : (wLeftIso l)ᴴ * wLeftIso l = 1 := by
  have hl' : (0 : ℝ) < (l : ℝ) := by exact_mod_cast hl
  have hs : ((Real.sqrt l)⁻¹ : ℝ) * ((Real.sqrt l)⁻¹ : ℝ) = ((l : ℝ))⁻¹ := by
    rw [← mul_inv, Real.mul_self_sqrt hl'.le]
  have h00 : ∑ f : Fin l → Fin 2, (starRingEnd ℂ) (wLeftIso l f 0) * wLeftIso l f 0 = 1 := by
    have hterm : ∀ f : Fin l → Fin 2, (starRingEnd ℂ) (wLeftIso l f 0) * wLeftIso l f 0
        = if wt f = 1 then ((((l : ℝ))⁻¹ : ℝ) : ℂ) else 0 := by
      intro f
      by_cases h : wt f = 1
      · simp only [wLeftIso, Matrix.of_apply, if_pos h, if_true, Complex.conj_ofReal,
          ← Complex.ofReal_mul, hs]
      · simp [wLeftIso, h]
    rw [Finset.sum_congr rfl (fun f _ => hterm f), sum_ite_wt_one]
    push_cast
    field_simp
  have h11 : ∑ f : Fin l → Fin 2, (starRingEnd ℂ) (wLeftIso l f 1) * wLeftIso l f 1 = 1 := by
    have hterm : ∀ f : Fin l → Fin 2, (starRingEnd ℂ) (wLeftIso l f 1) * wLeftIso l f 1
        = if wt f = 0 then (1 : ℂ) else 0 := by
      intro f
      by_cases h : wt f = 0 <;> simp [wLeftIso, h]
    rw [Finset.sum_congr rfl (fun f _ => hterm f), sum_ite_wt_zero]
  have h01 : ∑ f : Fin l → Fin 2, (starRingEnd ℂ) (wLeftIso l f 0) * wLeftIso l f 1 = 0 := by
    refine Finset.sum_eq_zero fun f _ => ?_
    by_cases h : wt f = 1
    · simp [wLeftIso, h]
    · simp [wLeftIso, h]
  have h10 : ∑ f : Fin l → Fin 2, (starRingEnd ℂ) (wLeftIso l f 1) * wLeftIso l f 0 = 0 := by
    refine Finset.sum_eq_zero fun f _ => ?_
    by_cases h : wt f = 1
    · simp [wLeftIso, h]
    · simp [wLeftIso, h]
  ext x y
  rw [Matrix.mul_apply, Matrix.one_apply]
  simp only [Matrix.conjTranspose_apply, RCLike.star_def]
  fin_cases x <;> fin_cases y
  · simpa using h00
  · simpa using h01
  · simpa using h10
  · simpa using h11

lemma wRightIso_isometry {m : ℕ} (hm : 1 ≤ m) : (wRightIso m)ᴴ * wRightIso m = 1 := by
  have hm' : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hs : ((Real.sqrt m)⁻¹ : ℝ) * ((Real.sqrt m)⁻¹ : ℝ) = ((m : ℝ))⁻¹ := by
    rw [← mul_inv, Real.mul_self_sqrt hm'.le]
  have h00 : ∑ g : Fin m → Fin 2, (starRingEnd ℂ) (wRightIso m g 0) * wRightIso m g 0 = 1 := by
    have hterm : ∀ g : Fin m → Fin 2, (starRingEnd ℂ) (wRightIso m g 0) * wRightIso m g 0
        = if wt g = 0 then (1 : ℂ) else 0 := by
      intro g
      by_cases h : wt g = 0 <;> simp [wRightIso, h]
    rw [Finset.sum_congr rfl (fun g _ => hterm g), sum_ite_wt_zero]
  have h11 : ∑ g : Fin m → Fin 2, (starRingEnd ℂ) (wRightIso m g 1) * wRightIso m g 1 = 1 := by
    have hterm : ∀ g : Fin m → Fin 2, (starRingEnd ℂ) (wRightIso m g 1) * wRightIso m g 1
        = if wt g = 1 then ((((m : ℝ))⁻¹ : ℝ) : ℂ) else 0 := by
      intro g
      by_cases h : wt g = 1
      · simp only [wRightIso, Matrix.of_apply]
        rw [if_neg (by decide : ¬ ((1 : Fin 2) = 0))]
        simp only [if_pos h, Complex.conj_ofReal, ← Complex.ofReal_mul, hs]
      · simp [wRightIso, h]
    rw [Finset.sum_congr rfl (fun g _ => hterm g), sum_ite_wt_one]
    push_cast
    field_simp
  have h01 : ∑ g : Fin m → Fin 2, (starRingEnd ℂ) (wRightIso m g 0) * wRightIso m g 1 = 0 := by
    refine Finset.sum_eq_zero fun g _ => ?_
    by_cases h : wt g = 1
    · simp [wRightIso, h]
    · simp [wRightIso, h]
  have h10 : ∑ g : Fin m → Fin 2, (starRingEnd ℂ) (wRightIso m g 1) * wRightIso m g 0 = 0 := by
    refine Finset.sum_eq_zero fun g _ => ?_
    by_cases h : wt g = 1
    · simp [wRightIso, h]
    · simp [wRightIso, h]
  ext x y
  rw [Matrix.mul_apply, Matrix.one_apply]
  simp only [Matrix.conjTranspose_apply, RCLike.star_def]
  fin_cases x <;> fin_cases y
  · simpa using h00
  · simpa using h01
  · simpa using h10
  · simpa using h11

/-- Entrywise formula for a product `L · diag(w) · Rᴴ`. -/
lemma mul_diagonal_conjTranspose_apply {α β γ : Type*} [Fintype γ] [DecidableEq γ]
    (L : Matrix α γ ℂ) (R : Matrix β γ ℂ) (w : γ → ℝ) (f : α) (g : β) :
    (L * Matrix.diagonal (fun x => (w x : ℂ)) * Rᴴ) f g
      = ∑ x, L f x * (w x : ℂ) * (starRingEnd ℂ) (R g x) := by
  simp only [Matrix.mul_apply, Matrix.diagonal_apply, Matrix.conjTranspose_apply, RCLike.star_def]
  refine Finset.sum_congr rfl fun x _ => ?_
  rw [Finset.sum_eq_single x]
  · simp
  · intro y _ hy
    simp [hy]
  · intro h; exact absurd (Finset.mem_univ x) h

/-- The Schmidt coefficients of the W state at the cut after site `l`. -/
noncomputable def wWeights (n l : ℕ) : Fin 2 → ℝ :=
  fun x => if x = 0 then Real.sqrt ((l : ℝ) / n) else Real.sqrt (((n - l : ℕ) : ℝ) / n)

lemma inv_sqrt_mul_sqrt_div {a n : ℕ} (ha : 1 ≤ a) (hn : 1 ≤ n) :
    ((Real.sqrt a)⁻¹ : ℝ) * Real.sqrt ((a : ℝ) / n) = (Real.sqrt n)⁻¹ := by
  have ha' : (0 : ℝ) < (a : ℝ) := by exact_mod_cast ha
  have hsa : (0 : ℝ) < Real.sqrt a := Real.sqrt_pos.mpr ha'
  rw [Real.sqrt_div ha'.le]
  field_simp

/-- **The cut matrix of the W state, in Schmidt form.** -/
theorem chainCutMatrix_wState_schmidtForm {n l : ℕ} (hl : l ≤ n) (hl1 : 1 ≤ l) (hlr : l < n) :
    chainCutMatrix (wState n) l hl
      = wLeftIso l * Matrix.diagonal (fun x => ((wWeights n l x : ℝ) : ℂ))
        * (wRightIso (n - l))ᴴ := by
  have hnl : 1 ≤ n - l := by omega
  have hn1 : 1 ≤ n := by omega
  have hA : ((Real.sqrt l)⁻¹ : ℝ) * Real.sqrt ((l : ℝ) / n) = (Real.sqrt n)⁻¹ :=
    inv_sqrt_mul_sqrt_div hl1 hn1
  have hB : ((Real.sqrt ((n - l : ℕ) : ℝ))⁻¹ : ℝ) * Real.sqrt (((n - l : ℕ) : ℝ) / n)
      = (Real.sqrt n)⁻¹ := inv_sqrt_mul_sqrt_div hnl hn1
  have hone : ((1 : Fin 2) = 0) = False := by simp
  ext f g
  rw [mul_diagonal_conjTranspose_apply, Fin.sum_univ_two]
  simp only [chainCutMatrix, Matrix.of_apply, wState, wLeftIso, wRightIso, wWeights,
    Matrix.of_apply, wt_glue hl f g, reduceIte, hone, if_false]
  by_cases hf1 : wt f = 1
  · by_cases hg0 : wt g = 0
    · rw [if_pos (by omega : wt f + wt g = 1), if_pos hf1, if_pos hg0, if_neg (by omega : ¬ wt f = 0),
        if_neg (by omega : ¬ wt g = 1)]
      simp only [map_one, mul_one, zero_mul, add_zero]
      rw [← Complex.ofReal_mul, hA]
    · rw [if_neg (by omega : ¬ (wt f + wt g = 1)), if_pos hf1, if_neg hg0,
        if_neg (by omega : ¬ wt f = 0)]
      simp
  · by_cases hf0 : wt f = 0
    · by_cases hg1 : wt g = 1
      · rw [if_pos (by omega : wt f + wt g = 1), if_neg hf1, if_pos hf0, if_pos hg1,
          if_neg (by omega : ¬ wt g = 0)]
        simp only [one_mul, Complex.conj_ofReal, zero_mul, zero_add]
        rw [← Complex.ofReal_mul, mul_comm, hB]
      · rw [if_neg (by omega : ¬ (wt f + wt g = 1)), if_neg hf1, if_neg hg1]
        simp
    · rw [if_neg (by omega : ¬ (wt f + wt g = 1)), if_neg hf1, if_neg hf0]
      simp

lemma wWeights_sq {n l : ℕ} (hn : 1 ≤ n) (x : Fin 2) :
    wWeights n l x ^ 2 = if x = 0 then (l : ℝ) / n else ((n - l : ℕ) : ℝ) / n := by
  have hn0 : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  by_cases h : x = 0
  · simp only [wWeights, if_pos h]
    exact Real.sq_sqrt (by positivity)
  · simp only [wWeights, if_neg h]
    exact Real.sq_sqrt (by positivity)

lemma wWeights_ne_zero {n l : ℕ} (hl1 : 1 ≤ l) (hlr : l < n) (x : Fin 2) :
    wWeights n l x ≠ 0 := by
  have hn0 : (0 : ℝ) < (n : ℝ) := by
    have : 0 < n := by omega
    exact_mod_cast this
  have hl0 : (0 : ℝ) < (l : ℝ) := by exact_mod_cast hl1
  have hml : (0 : ℝ) < ((n - l : ℕ) : ℝ) := by
    have : 0 < n - l := by omega
    exact_mod_cast this
  by_cases h : x = 0
  · simp only [wWeights, if_pos h]
    positivity
  · simp only [wWeights, if_neg h]
    positivity

lemma sum_negMulLog_wWeights {n l : ℕ} (hl : l ≤ n) (hn : 1 ≤ n) :
    ∑ x, Real.negMulLog (wWeights n l x ^ 2) = Real.binEntropy ((l : ℝ) / n) := by
  have hn0 : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hcast : ((n - l : ℕ) : ℝ) / n = 1 - (l : ℝ) / n := by
    rw [Nat.cast_sub hl]
    field_simp
  rw [Fin.sum_univ_two, wWeights_sq hn, wWeights_sq hn]
  simp only [if_true, if_neg (by decide : ¬ ((1 : Fin 2) = 0))]
  rw [hcast, Real.binEntropy_eq_negMulLog_add_negMulLog_one_sub]

/-- **Mutual information across a cut of the W state**: the binary entropy of
the fraction of sites on the left, doubled. -/
theorem mutualInformation_chainCutMatrix_wState {n l : ℕ} (hl : l ≤ n) (hl1 : 1 ≤ l)
    (hlr : l < n) :
    mutualInformation (chainCutMatrix (wState n) l hl) = 2 * Real.binEntropy ((l : ℝ) / n) := by
  have hnl : 1 ≤ n - l := by omega
  rw [chainCutMatrix_wState_schmidtForm hl hl1 hlr,
    mutualInformation_of_schmidtForm (wLeftIso_isometry hl1) (wRightIso_isometry hnl) rfl
      (card_le_card_block (d := 2) hl1) (card_le_card_block (d := 2) (l := n - l) hnl),
    sum_negMulLog_wWeights hl (by omega)]

/-- **The Schmidt rank of the W state is `2` at every bipartition.** -/
theorem schmidtRank_chainCutMatrix_wState {n l : ℕ} (hl : l ≤ n) (hl1 : 1 ≤ l) (hlr : l < n) :
    schmidtRank (chainCutMatrix (wState n) l hl) = 2 := by
  have hnl : 1 ≤ n - l := by omega
  have hrank := schmidtRank_of_schmidtForm
    (M := wLeftIso l * Matrix.diagonal (fun x => ((wWeights n l x : ℝ) : ℂ))
      * (wRightIso (n - l))ᴴ)
    (wLeftIso_isometry hl1) (wRightIso_isometry hnl) rfl (wWeights_ne_zero hl1 hlr)
  rw [chainCutMatrix_wState_schmidtForm hl hl1 hlr, hrank, Fintype.card_fin]

/-- **The W state is a matrix product state of bond dimension `2`.** -/
theorem hasBondDim_chainCutMatrix_wState {n l : ℕ} (hl : l ≤ n) (hl1 : 1 ≤ l) (hlr : l < n) :
    HasBondDim (chainCutMatrix (wState n) l hl) 2 := by
  rw [chainCutMatrix_wState_schmidtForm hl hl1 hlr]
  exact ⟨_, _, rfl⟩

/-! ## Minimizing the binary entropy over the cuts -/

lemma binEntropy_inv_le_of_le_half {n : ℕ} (hn : 2 ≤ n) {x : ℝ} (hx : ((n : ℝ))⁻¹ ≤ x)
    (hx2 : x ≤ 2⁻¹) : Real.binEntropy ((n : ℝ)⁻¹) ≤ Real.binEntropy x := by
  have hn0 : (0 : ℝ) < (n : ℝ) := by
    have : 0 < n := by omega
    exact_mod_cast this
  refine Real.binEntropy_strictMonoOn.monotoneOn ⟨by positivity, le_trans hx hx2⟩
    ⟨le_trans (by positivity) hx, hx2⟩ hx

/-- The binary entropy at `l/n` is minimal, over `1 ≤ l < n`, at `l = 1`. -/
lemma binEntropy_inv_le_div {n l : ℕ} (hn : 2 ≤ n) (hl1 : 1 ≤ l) (hlr : l < n) :
    Real.binEntropy ((n : ℝ)⁻¹) ≤ Real.binEntropy ((l : ℝ) / n) := by
  have hn0 : (0 : ℝ) < (n : ℝ) := by
    have : 0 < n := by omega
    exact_mod_cast this
  have hl0 : (1 : ℝ) ≤ (l : ℝ) := by exact_mod_cast hl1
  have hinvle : ((n : ℝ))⁻¹ ≤ (l : ℝ) / n := by
    rw [inv_eq_one_div, div_le_div_iff_of_pos_right hn0]
    exact hl0
  rcases le_total ((l : ℝ) / n) 2⁻¹ with h | h
  · exact binEntropy_inv_le_of_le_half hn hinvle h
  · have hsub : ((n - l : ℕ) : ℝ) / n = 1 - (l : ℝ) / n := by
      rw [Nat.cast_sub (le_of_lt hlr)]
      field_simp
    have hml1 : (1 : ℝ) ≤ ((n - l : ℕ) : ℝ) := by
      have : 1 ≤ n - l := by omega
      exact_mod_cast this
    have hinvle' : ((n : ℝ))⁻¹ ≤ ((n - l : ℕ) : ℝ) / n := by
      rw [inv_eq_one_div, div_le_div_iff_of_pos_right hn0]
      exact hml1
    have hhalf : ((n - l : ℕ) : ℝ) / n ≤ 2⁻¹ := by
      rw [hsub]
      linarith
    have := binEntropy_inv_le_of_le_half hn hinvle' hhalf
    rwa [hsub, Real.binEntropy_one_sub] at this

/-- **Integrated information of the W state**: `Φ(W_n) = 2 H₂(1/n)`. -/
theorem phi_wState {n : ℕ} (hn : 2 ≤ n) :
    Phi (wState_normalized (n := n) (by omega)) hn = 2 * Real.binEntropy ((n : ℝ)⁻¹) := by
  have hcut : ∀ p : Fin (n - 1),
      mutualInformation (chainCutMatrix (wState n) ((p : ℕ) + 1) (by have := p.isLt; omega))
        = 2 * Real.binEntropy ((((p : ℕ) + 1 : ℕ) : ℝ) / n) := by
    intro p
    have hp := p.isLt
    exact mutualInformation_chainCutMatrix_wState (by omega) (by omega) (by omega)
  refine le_antisymm ?_ ?_
  · have h0 := phi_le_mutualInformation (wState_normalized (n := n) (by omega)) hn ⟨0, by omega⟩
    rw [hcut ⟨0, by omega⟩] at h0
    simpa [one_div] using h0
  · refine le_phi _ hn (fun p => ?_)
    have hp := p.isLt
    rw [hcut p]
    have := binEntropy_inv_le_div (n := n) (l := (p : ℕ) + 1) hn (by omega) (by omega)
    push_cast at this ⊢
    linarith

/-- **The W state has strictly less integrated information than the GHZ state**
of the same length, bond dimension and Schmidt rank. -/
theorem phi_wState_lt_phi_ghz {n : ℕ} (hn : 3 ≤ n) :
    Phi (wState_normalized (n := n) (by omega)) (by omega : 2 ≤ n)
      < Phi (ghzState_normalized (n := n) (d := 2) (by omega) (by norm_num)) (by omega) := by
  have hn0 : (0 : ℝ) < (n : ℝ) := by
    have : 0 < n := by omega
    exact_mod_cast this
  have hne : ((n : ℝ))⁻¹ ≠ 2⁻¹ := by
    intro h
    have hn2 : (n : ℝ) = 2 := by
      field_simp at h
      linarith
    have : (3 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
    linarith
  rw [phi_wState (by omega), phi_ghz (by omega) (by norm_num)]
  have hlt := Real.binEntropy_lt_log_two.mpr hne
  have : Real.log ((2 : ℕ) : ℝ) = Real.log 2 := by norm_num
  rw [this]
  linarith

end WState

end IITTensorNetwork