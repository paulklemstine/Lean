import Mathlib

/-!
# Finite mutual information: log-sum, data processing, and the `I ≤ H(A)` cap

This file develops, from first principles, the small amount of information theory
needed by `Novelty.SplitCountChannel` (the SPLIT-COUNT-LAW experiment).

Everything is phrased for a *finite joint weight table* `p : α → β → ℝ` with
nonnegative entries; the mutual information is measured in **bits**:

`mutualInfo p = ∑ a ∑ b, p a b * logb 2 (p a b / (rowMarg p a * colMarg p b))`.

Main results.

* `Real.logsum_inequality` : the log-sum inequality
  `(∑ aᵢ) * log ((∑ aᵢ)/(∑ bᵢ)) ≤ ∑ aᵢ * log (aᵢ / bᵢ)` for `aᵢ ≥ 0`, `bᵢ > 0`.
* `mutualInfo_map_le` : the **data processing inequality** for a deterministic
  relabelling `g : β → γ` of the second coordinate.
* `mutualInfo_le_rowEntropy` : `I(A;B) ≤ H(A)`.
* `mutualInfo_le_one_of_binary` : for a binary first coordinate, `I(A;B) ≤ 1` bit.
* `mutualInfo_nonneg` : `I(A;B) ≥ 0`.

No probabilistic measure theory is used: all statements are elementary real
inequalities about finite tables, which is exactly the level at which the
split-count experiment lives.
-/

namespace SplitCountLaw

open Finset Real

/-- Row marginal of a finite weight table. -/
noncomputable def rowMarg {α β : Type*} [Fintype β] (p : α → β → ℝ) (a : α) : ℝ :=
  ∑ b, p a b

/-- Column marginal of a finite weight table. -/
noncomputable def colMarg {α β : Type*} [Fintype α] (p : α → β → ℝ) (b : β) : ℝ :=
  ∑ a, p a b

/-- Mutual information of a finite joint weight table, in bits. -/
noncomputable def mutualInfo {α β : Type*} [Fintype α] [Fintype β] (p : α → β → ℝ) : ℝ :=
  ∑ a, ∑ b, p a b * logb 2 (p a b / (rowMarg p a * colMarg p b))

/-- Shannon entropy (in bits) of a finite weight vector. -/
noncomputable def entropyBits {α : Type*} [Fintype α] (q : α → ℝ) : ℝ :=
  ∑ a, -(q a * logb 2 (q a))

/-! ## The log-sum inequality -/

/-- Pointwise ingredient of the log-sum inequality:
`x * log (x / y) - x * log c ≥ x - y * c` for `x ≥ 0`, `y, c > 0`. -/
lemma log_div_sub_log_ge {x y c : ℝ} (hx : 0 ≤ x) (hy : 0 < y) (hc : 0 < c) :
    x - y * c ≤ x * Real.log (x / y) - x * Real.log c := by
  rcases eq_or_lt_of_le hx with h | hx'
  · subst_vars
    simp only [zero_mul, zero_sub, sub_zero, neg_nonpos]
    positivity
  · have ht : 0 < x / (y * c) := by positivity
    have hlog : Real.log ((y * c) / x) ≤ (y * c) / x - 1 :=
      Real.log_le_sub_one_of_pos (by positivity)
    have hx0 : x ≠ 0 := ne_of_gt hx'
    have hsplit : Real.log ((y * c) / x) = -(Real.log (x / y) - Real.log c) := by
      rw [Real.log_div (by positivity) hx0, Real.log_mul (ne_of_gt hy) (ne_of_gt hc),
        Real.log_div hx0 (ne_of_gt hy)]
      ring
    rw [hsplit] at hlog
    have := mul_le_mul_of_nonneg_left hlog (le_of_lt hx')
    have hxx : x * ((y * c) / x - 1) = y * c - x := by
      field_simp
    nlinarith [this, hxx]

/-- **Log-sum inequality.** For nonnegative `a` and positive `b`,
`(∑ aᵢ) log ((∑ aᵢ)/(∑ bᵢ)) ≤ ∑ aᵢ log (aᵢ/bᵢ)`. -/
theorem logsum_inequality {ι : Type*} (s : Finset ι) (a b : ι → ℝ)
    (ha : ∀ i ∈ s, 0 ≤ a i) (hb : ∀ i ∈ s, 0 < b i) :
    (∑ i ∈ s, a i) * Real.log ((∑ i ∈ s, a i) / (∑ i ∈ s, b i)) ≤
      ∑ i ∈ s, a i * Real.log (a i / b i) := by
  set A := ∑ i ∈ s, a i with hA
  set B := ∑ i ∈ s, b i with hB
  have hA0 : 0 ≤ A := Finset.sum_nonneg ha
  rcases eq_or_lt_of_le hA0 with h | hApos
  · -- all `a i = 0`
    have hzero : ∀ i ∈ s, a i = 0 := (Finset.sum_eq_zero_iff_of_nonneg ha).1 h.symm
    have h1 : ∑ i ∈ s, a i * Real.log (a i / b i) = 0 :=
      Finset.sum_eq_zero (fun i hi => by rw [hzero i hi]; ring)
    rw [h1, ← h, zero_mul]
  · have hBpos : 0 < B := by
      rcases Finset.eq_empty_or_nonempty s with rfl | hs
      · simp [hA] at hApos
      · exact Finset.sum_pos hb hs
    have hc : 0 < A / B := div_pos hApos hBpos
    have key : ∀ i ∈ s, a i - b i * (A / B) ≤ a i * Real.log (a i / b i) -
        a i * Real.log (A / B) :=
      fun i hi => log_div_sub_log_ge (ha i hi) (hb i hi) hc
    have hsum := Finset.sum_le_sum key
    rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, ← Finset.sum_mul, ← Finset.sum_mul] at hsum
    rw [← hA, ← hB] at hsum
    have hBB : B * (A / B) = A := by field_simp
    rw [hBB] at hsum
    linarith

/-- `logb 2` version of the log-sum inequality. -/
theorem logsum_inequality_logb {ι : Type*} (s : Finset ι) (a b : ι → ℝ)
    (ha : ∀ i ∈ s, 0 ≤ a i) (hb : ∀ i ∈ s, 0 < b i) :
    (∑ i ∈ s, a i) * logb 2 ((∑ i ∈ s, a i) / (∑ i ∈ s, b i)) ≤
      ∑ i ∈ s, a i * logb 2 (a i / b i) := by
  have h := logsum_inequality s a b ha hb
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hdiv : (∑ i ∈ s, a i) * Real.log ((∑ i ∈ s, a i) / (∑ i ∈ s, b i)) / Real.log 2 ≤
      (∑ i ∈ s, a i * Real.log (a i / b i)) / Real.log 2 := by
    exact div_le_div_of_nonneg_right h hl2.le
  simpa [Real.logb, Finset.sum_div, mul_div_assoc] using hdiv

/-- Strict form of the pointwise ingredient, when `x ≠ y * c`. -/
lemma log_div_sub_log_gt {x y c : ℝ} (hx : 0 ≤ x) (hy : 0 < y) (hc : 0 < c)
    (hne : x ≠ y * c) :
    x - y * c < x * Real.log (x / y) - x * Real.log c := by
  rcases eq_or_lt_of_le hx with h | hx'
  · subst_vars
    simp only [zero_mul, zero_sub, sub_zero, neg_lt_zero]
    positivity
  · have hx0 : x ≠ 0 := ne_of_gt hx'
    have hne1 : (y * c) / x ≠ 1 := by
      intro h
      apply hne
      field_simp at h
      linarith
    have hlog : Real.log ((y * c) / x) < (y * c) / x - 1 :=
      Real.log_lt_sub_one_of_pos (by positivity) hne1
    have hsplit : Real.log ((y * c) / x) = -(Real.log (x / y) - Real.log c) := by
      rw [Real.log_div (by positivity) hx0, Real.log_mul (ne_of_gt hy) (ne_of_gt hc),
        Real.log_div hx0 (ne_of_gt hy)]
      ring
    rw [hsplit] at hlog
    have hmul := (mul_lt_mul_iff_of_pos_left hx').2 hlog
    have hxx : x * ((y * c) / x - 1) = y * c - x := by field_simp
    nlinarith [hmul, hxx]

/-- **Strict log-sum inequality**: strict as soon as one ratio is off. -/
theorem logsum_inequality_strict {ι : Type*} (s : Finset ι) (a b : ι → ℝ)
    (ha : ∀ i ∈ s, 0 ≤ a i) (hb : ∀ i ∈ s, 0 < b i) {i₀ : ι} (hi₀ : i₀ ∈ s)
    (hne : a i₀ * (∑ i ∈ s, b i) ≠ b i₀ * (∑ i ∈ s, a i)) :
    (∑ i ∈ s, a i) * Real.log ((∑ i ∈ s, a i) / (∑ i ∈ s, b i)) <
      ∑ i ∈ s, a i * Real.log (a i / b i) := by
  set A := ∑ i ∈ s, a i with hA
  set B := ∑ i ∈ s, b i with hB
  have hA0 : 0 ≤ A := Finset.sum_nonneg ha
  have hne' : A ≠ 0 := by
    intro h
    apply hne
    have hzero : ∀ i ∈ s, a i = 0 := (Finset.sum_eq_zero_iff_of_nonneg ha).1 h
    rw [hzero i₀ hi₀, h]
    ring
  have hApos : 0 < A := lt_of_le_of_ne hA0 (Ne.symm hne')
  have hBpos : 0 < B := by
    rcases Finset.eq_empty_or_nonempty s with rfl | hs
    · simp [hA] at hApos
    · exact Finset.sum_pos hb hs
  have hc : 0 < A / B := div_pos hApos hBpos
  have key : ∀ i ∈ s, a i - b i * (A / B) ≤ a i * Real.log (a i / b i) -
      a i * Real.log (A / B) :=
    fun i hi => log_div_sub_log_ge (ha i hi) (hb i hi) hc
  have hne₀ : a i₀ ≠ b i₀ * (A / B) := by
    intro h
    apply hne
    rw [h]
    field_simp
  have keylt : a i₀ - b i₀ * (A / B) < a i₀ * Real.log (a i₀ / b i₀) -
      a i₀ * Real.log (A / B) :=
    log_div_sub_log_gt (ha i₀ hi₀) (hb i₀ hi₀) hc hne₀
  have hsum : ∑ i ∈ s, (a i - b i * (A / B)) <
      ∑ i ∈ s, (a i * Real.log (a i / b i) - a i * Real.log (A / B)) :=
    Finset.sum_lt_sum key ⟨i₀, hi₀, keylt⟩
  rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, ← Finset.sum_mul, ← Finset.sum_mul] at hsum
  rw [← hA, ← hB] at hsum
  have hBB : B * (A / B) = A := by field_simp
  rw [hBB] at hsum
  linarith

/-- `logb 2` version of the strict log-sum inequality. -/
theorem logsum_inequality_strict_logb {ι : Type*} (s : Finset ι) (a b : ι → ℝ)
    (ha : ∀ i ∈ s, 0 ≤ a i) (hb : ∀ i ∈ s, 0 < b i) {i₀ : ι} (hi₀ : i₀ ∈ s)
    (hne : a i₀ * (∑ i ∈ s, b i) ≠ b i₀ * (∑ i ∈ s, a i)) :
    (∑ i ∈ s, a i) * logb 2 ((∑ i ∈ s, a i) / (∑ i ∈ s, b i)) <
      ∑ i ∈ s, a i * logb 2 (a i / b i) := by
  have h := logsum_inequality_strict s a b ha hb hi₀ hne
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hdiv : (∑ i ∈ s, a i) * Real.log ((∑ i ∈ s, a i) / (∑ i ∈ s, b i)) / Real.log 2 <
      (∑ i ∈ s, a i * Real.log (a i / b i)) / Real.log 2 := by
    exact div_lt_div_of_pos_right h hl2
  simpa [Real.logb, Finset.sum_div, mul_div_assoc] using hdiv

/-! ## Data processing -/

section DPI

variable {α β γ : Type*} [Fintype α] [Fintype β] [Fintype γ] [DecidableEq γ]

/-- Deterministic relabelling of the second coordinate. -/
noncomputable def push (p : α → β → ℝ) (g : β → γ) : α → γ → ℝ :=
  fun a c => ∑ b ∈ Finset.univ.filter (fun b => g b = c), p a b

omit [Fintype α] in
lemma rowMarg_push (p : α → β → ℝ) (g : β → γ) (a : α) :
    rowMarg (push p g) a = rowMarg p a := by
  simp only [rowMarg, push]
  exact Finset.sum_fiberwise Finset.univ g (fun b => p a b)

omit [Fintype γ] in
lemma colMarg_push (p : α → β → ℝ) (g : β → γ) (c : γ) :
    colMarg (push p g) c = ∑ b ∈ Finset.univ.filter (fun b => g b = c), colMarg p b := by
  simp only [colMarg, push]
  exact Finset.sum_comm

/-- **Data processing inequality.**  Relabelling the second coordinate by a
deterministic map cannot increase the mutual information. -/
theorem mutualInfo_map_le (p : α → β → ℝ) (g : β → γ)
    (hp : ∀ a b, 0 ≤ p a b) (hrow : ∀ a, 0 < rowMarg p a) (hcol : ∀ b, 0 < colMarg p b) :
    mutualInfo (push p g) ≤ mutualInfo p := by
  have hterm : ∀ a : α, ∀ c : γ,
      push p g a c * logb 2 (push p g a c / (rowMarg (push p g) a * colMarg (push p g) c)) ≤
        ∑ b ∈ Finset.univ.filter (fun b => g b = c),
          p a b * logb 2 (p a b / (rowMarg p a * colMarg p b)) := by
    intro a c
    have h := logsum_inequality_logb (Finset.univ.filter (fun b => g b = c))
      (fun b => p a b) (fun b => rowMarg p a * colMarg p b)
      (fun b _ => hp a b) (fun b _ => mul_pos (hrow a) (hcol b))
    have hden : ∑ b ∈ Finset.univ.filter (fun b => g b = c), rowMarg p a * colMarg p b
        = rowMarg (push p g) a * colMarg (push p g) c := by
      rw [← Finset.mul_sum, colMarg_push, rowMarg_push]
    rw [hden] at h
    simpa [push] using h
  calc mutualInfo (push p g)
      = ∑ a, ∑ c, push p g a c *
          logb 2 (push p g a c / (rowMarg (push p g) a * colMarg (push p g) c)) := rfl
    _ ≤ ∑ a, ∑ c, ∑ b ∈ Finset.univ.filter (fun b => g b = c),
          p a b * logb 2 (p a b / (rowMarg p a * colMarg p b)) :=
          Finset.sum_le_sum (fun a _ => Finset.sum_le_sum (fun c _ => hterm a c))
    _ = mutualInfo p := by
          refine Finset.sum_congr rfl (fun a _ => ?_)
          exact Finset.sum_fiberwise Finset.univ g
            (fun b => p a b * logb 2 (p a b / (rowMarg p a * colMarg p b)))

end DPI

/-! ## The `I ≤ H(A)` cap -/

section Cap

variable {α β : Type*} [Fintype α] [Fintype β]

/-- Splitting a mutual-information cell into a conditional part and a row part. -/
lemma mutualInfo_split (p : α → β → ℝ) (hp : ∀ a b, 0 ≤ p a b)
    (hrow : ∀ a, 0 < rowMarg p a) (hcol : ∀ b, 0 < colMarg p b) :
    mutualInfo p = (∑ a, ∑ b, p a b * logb 2 (p a b / colMarg p b))
      + entropyBits (rowMarg p) := by
  have hsplit : ∀ a b, p a b * logb 2 (p a b / (rowMarg p a * colMarg p b))
      = p a b * logb 2 (p a b / colMarg p b) - p a b * logb 2 (rowMarg p a) := by
    intro a b
    rcases eq_or_lt_of_le (hp a b) with h | h
    · simp [← h]
    · have h1 : p a b / (rowMarg p a * colMarg p b)
          = (p a b / colMarg p b) / rowMarg p a := by
        field_simp
      rw [h1, Real.logb_div (div_ne_zero (ne_of_gt h) (ne_of_gt (hcol b))) (ne_of_gt (hrow a))]
      ring
  simp only [mutualInfo, entropyBits]
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl (fun a _ => ?_)
  rw [Finset.sum_congr rfl (fun b _ => hsplit a b), Finset.sum_sub_distrib, ← Finset.sum_mul]
  have : (∑ b, p a b) = rowMarg p a := rfl
  rw [this]
  ring

/-- Mutual information never exceeds the entropy of the first coordinate. -/
theorem mutualInfo_le_rowEntropy (p : α → β → ℝ) (hp : ∀ a b, 0 ≤ p a b)
    (hrow : ∀ a, 0 < rowMarg p a) (hcol : ∀ b, 0 < colMarg p b) :
    mutualInfo p ≤ entropyBits (rowMarg p) := by
  have hle : ∑ a, ∑ b, p a b * logb 2 (p a b / colMarg p b) ≤ 0 := by
    rw [Finset.sum_comm]
    refine Finset.sum_nonpos (fun b _ => Finset.sum_nonpos (fun a _ => ?_))
    rcases eq_or_lt_of_le (hp a b) with h | h
    · simp [← h]
    · have hb : p a b ≤ colMarg p b :=
        Finset.single_le_sum (f := fun a' => p a' b) (fun a' _ => hp a' b) (Finset.mem_univ a)
      have hle1 : p a b / colMarg p b ≤ 1 := by rw [div_le_one (hcol b)]; exact hb
      exact mul_nonpos_of_nonneg_of_nonpos (le_of_lt h)
        (Real.logb_nonpos (by norm_num) (le_of_lt (div_pos h (hcol b))) hle1)
  have := mutualInfo_split p hp hrow hcol
  linarith

/-- Binary entropy in bits, in Mathlib's normalisation. -/
lemma entropyBits_binary_eq (q : Fin 2 → ℝ) (hs : q 0 + q 1 = 1) :
    entropyBits q = Real.binEntropy (q 0) / Real.log 2 := by
  have hq1 : q 1 = 1 - q 0 := by linarith
  simp only [entropyBits, Fin.sum_univ_two, Real.binEntropy, Real.logb, hq1]
  rw [Real.log_inv, Real.log_inv]
  field_simp

/-- A binary weight vector summing to one has entropy at most one bit. -/
lemma entropyBits_binary_le_one (q : Fin 2 → ℝ) (hs : q 0 + q 1 = 1) :
    entropyBits q ≤ 1 := by
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  rw [entropyBits_binary_eq q hs, div_le_one hl2]
  exact Real.binEntropy_le_log_two

/-- With a binary first coordinate, mutual information is capped at one bit. -/
theorem mutualInfo_le_one_of_binary (p : Fin 2 → β → ℝ) (hp : ∀ a b, 0 ≤ p a b)
    (hrow : ∀ a, 0 < rowMarg p a) (hcol : ∀ b, 0 < colMarg p b)
    (htot : rowMarg p 0 + rowMarg p 1 = 1) :
    mutualInfo p ≤ 1 := by
  refine le_trans (mutualInfo_le_rowEntropy p hp hrow hcol) ?_
  exact entropyBits_binary_le_one _ htot

end Cap

/-! ## Channel decomposition `I = H(B) - H(B|A)` -/

section Channel

variable {α β : Type*} [Fintype α] [Fintype β]

/-- For a joint table built from a prior `w` and a channel `k` (`p a b = w a * k a b`),
the mutual information is the output entropy minus the average conditional entropy. -/
theorem mutualInfo_of_channel (w : α → ℝ) (k : α → β → ℝ)
    (hw : ∀ a, 0 ≤ w a) (hk : ∀ a b, 0 ≤ k a b) (hk1 : ∀ a, ∑ b, k a b = 1)
    (hcol : ∀ b, 0 < colMarg (fun a b => w a * k a b) b) :
    mutualInfo (fun a b => w a * k a b)
      = entropyBits (colMarg (fun a b => w a * k a b)) - ∑ a, w a * entropyBits (k a) := by
  set p : α → β → ℝ := fun a b => w a * k a b with hp
  have hrow : ∀ a, rowMarg p a = w a := by
    intro a; simp only [rowMarg, hp, ← Finset.mul_sum, hk1 a, mul_one]
  have key : ∀ a b, p a b * logb 2 (p a b / (rowMarg p a * colMarg p b))
      = w a * (k a b * logb 2 (k a b)) - w a * k a b * logb 2 (colMarg p b) := by
    intro a b
    rcases eq_or_lt_of_le (hw a) with hwa | hwa
    · simp [hp, ← hwa]
    rcases eq_or_lt_of_le (hk a b) with hkab | hkab
    · simp [hp, ← hkab]
    have hdiv : p a b / (rowMarg p a * colMarg p b) = k a b / colMarg p b := by
      rw [hrow a]
      field_simp [hp]
      rfl
    rw [hdiv, Real.logb_div (ne_of_gt hkab) (ne_of_gt (hcol b))]
    simp only [hp]
    ring
  have hexp : mutualInfo p = ∑ a, ∑ b,
      (w a * (k a b * logb 2 (k a b)) - w a * k a b * logb 2 (colMarg p b)) := by
    simp only [mutualInfo]
    exact Finset.sum_congr rfl (fun a _ => Finset.sum_congr rfl (fun b _ => key a b))
  rw [hexp]
  have h1 : ∀ a : α, ∑ b, (w a * (k a b * logb 2 (k a b)) - w a * k a b * logb 2 (colMarg p b))
      = -(w a * entropyBits (k a)) - ∑ b, w a * k a b * logb 2 (colMarg p b) := by
    intro a
    rw [Finset.sum_sub_distrib]
    congr 1
    have hE : entropyBits (k a) = -∑ b, k a b * logb 2 (k a b) := by
      simp only [entropyBits, Finset.sum_neg_distrib]
    rw [hE, mul_neg, neg_neg, Finset.mul_sum]
  rw [Finset.sum_congr rfl (fun a _ => h1 a), Finset.sum_sub_distrib]
  have h2 : ∑ a, ∑ b, w a * k a b * logb 2 (colMarg p b)
      = -entropyBits (colMarg p) := by
    rw [Finset.sum_comm]
    simp only [entropyBits, ← Finset.sum_neg_distrib, neg_neg]
    refine Finset.sum_congr rfl (fun b _ => ?_)
    rw [← Finset.sum_mul]
    rfl
  rw [h2]
  simp only [Finset.sum_neg_distrib]
  ring

end Channel

/-! ## Nonnegativity -/

section Nonneg

variable {α β : Type*} [Fintype α] [Fintype β]

/-- Mutual information of a normalised nonnegative table is nonnegative. -/
theorem mutualInfo_nonneg (p : α → β → ℝ) (hp : ∀ a b, 0 ≤ p a b)
    (hrow : ∀ a, 0 < rowMarg p a) (hcol : ∀ b, 0 < colMarg p b)
    (htot : ∑ a, rowMarg p a = 1) :
    0 ≤ mutualInfo p := by
  have hcolsum : ∑ b, colMarg p b = 1 := by
    simpa [rowMarg, colMarg, Finset.sum_comm (f := fun a b => p a b)] using htot
  have h := logsum_inequality_logb (Finset.univ : Finset (α × β))
    (fun x => p x.1 x.2) (fun x => rowMarg p x.1 * colMarg p x.2)
    (fun x _ => hp x.1 x.2) (fun x _ => mul_pos (hrow x.1) (hcol x.2))
  have hA : ∑ x : α × β, p x.1 x.2 = 1 := by
    rw [Fintype.sum_prod_type]
    simpa [rowMarg] using htot
  have hB : ∑ x : α × β, rowMarg p x.1 * colMarg p x.2 = 1 := by
    rw [Fintype.sum_prod_type]
    simp only [← Finset.mul_sum, hcolsum, mul_one]
    simpa using htot
  rw [hA, hB] at h
  simp only [div_one, Real.logb_one, mul_zero] at h
  have hI : mutualInfo p = ∑ x : α × β, p x.1 x.2 *
      logb 2 (p x.1 x.2 / (rowMarg p x.1 * colMarg p x.2)) := by
    rw [Fintype.sum_prod_type]; rfl
  rw [hI]
  linarith

/-- **Strict positivity.** A normalised table with one cell off the independent
product carries strictly positive information. -/
theorem mutualInfo_pos (p : α → β → ℝ) (hp : ∀ a b, 0 ≤ p a b)
    (hrow : ∀ a, 0 < rowMarg p a) (hcol : ∀ b, 0 < colMarg p b)
    (htot : ∑ a, rowMarg p a = 1) {a₀ : α} {b₀ : β}
    (hne : p a₀ b₀ ≠ rowMarg p a₀ * colMarg p b₀) :
    0 < mutualInfo p := by
  have hcolsum : ∑ b, colMarg p b = 1 := by
    simpa [rowMarg, colMarg, Finset.sum_comm (f := fun a b => p a b)] using htot
  have hA : ∑ x : α × β, p x.1 x.2 = 1 := by
    rw [Fintype.sum_prod_type]
    simpa [rowMarg] using htot
  have hB : ∑ x : α × β, rowMarg p x.1 * colMarg p x.2 = 1 := by
    rw [Fintype.sum_prod_type]
    simp only [← Finset.mul_sum, hcolsum, mul_one]
    simpa using htot
  have hne' : p (a₀, b₀).1 (a₀, b₀).2 * (∑ x : α × β, rowMarg p x.1 * colMarg p x.2)
      ≠ (rowMarg p (a₀, b₀).1 * colMarg p (a₀, b₀).2) * (∑ x : α × β, p x.1 x.2) := by
    rw [hA, hB]
    simpa using hne
  have h := logsum_inequality_strict_logb (Finset.univ : Finset (α × β))
    (fun x => p x.1 x.2) (fun x => rowMarg p x.1 * colMarg p x.2)
    (fun x _ => hp x.1 x.2) (fun x _ => mul_pos (hrow x.1) (hcol x.2))
    (Finset.mem_univ (a₀, b₀)) hne'
  rw [hA, hB] at h
  simp only [div_one, Real.logb_one, mul_zero] at h
  have hI : mutualInfo p = ∑ x : α × β, p x.1 x.2 *
      logb 2 (p x.1 x.2 / (rowMarg p x.1 * colMarg p x.2)) := by
    rw [Fintype.sum_prod_type]; rfl
  rw [hI]
  linarith

/-- **Independence control.** A product table carries no information. -/
theorem mutualInfo_eq_zero_of_indep (w : α → ℝ) (v : β → ℝ)
    (hw : ∀ a, 0 ≤ w a) (hv : ∀ b, 0 ≤ v b)
    (hw1 : ∑ a, w a = 1) (hv1 : ∑ b, v b = 1) :
    mutualInfo (fun a b => w a * v b) = 0 := by
  have hrow : ∀ a, rowMarg (fun a b => w a * v b) a = w a := by
    intro a; simp only [rowMarg, ← Finset.mul_sum, hv1, mul_one]
  have hcol : ∀ b, colMarg (fun a b => w a * v b) b = v b := by
    intro b
    simp only [colMarg]
    rw [← Finset.sum_mul, hw1, one_mul]
  simp only [mutualInfo, hrow, hcol]
  refine Finset.sum_eq_zero (fun a _ => Finset.sum_eq_zero (fun b _ => ?_))
  rcases eq_or_lt_of_le (hw a) with h | ha
  · simp [← h]
  rcases eq_or_lt_of_le (hv b) with h | hb
  · simp [← h]
  rw [div_self (by positivity)]
  simp

end Nonneg

end SplitCountLaw