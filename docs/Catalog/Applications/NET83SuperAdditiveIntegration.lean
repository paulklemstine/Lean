/-
# NET-83 — THE-INTEGRATION-IS-SUPER-ADDITIVE

A formal model of the experiment reported in NET-83 (limited-memory axis,
round 33): combining **GPTQ 4-bit weight quantization** with **top-k sparse
attention** degrades a language model *worse* than the sum of the two
degradations taken separately.

Empirically (retained accuracy relative to fp32):

| arm            | retained | CE    |
|----------------|----------|-------|
| full fp32      | 1.0000   | 2.697 |
| attn k=16      | 0.9768   | 2.774 |
| attn k=20      | 0.9803   | 2.755 |
| attn k=24      | 0.9851   | 2.742 |
| GPTQ4          | 0.9081   | 3.015 |
| GPTQ4 + k=16   | 0.8598   | 3.220 |
| GPTQ4 + k=20   | 0.8707   | 3.180 |
| GPTQ4 + k=24   | 0.8772   | 3.155 |

so at `k = 16` the additive prediction is `2.32% + 9.19% = 11.51%` while the
measured loss is `14.02%`; the residual `2.51%` is the *interaction cost*.

This file formalises the two mechanisms proposed for the effect and proves
that they are real, quantifies them exactly, and delimits them:

* `NET83.selection_stable_of_margin` — a **safe regime**: if the top-k score
  margin exceeds twice the score perturbation, quantization cannot change the
  selected key set.  (Mechanism (1) is *gated* by the margin.)
* `NET83.selection_flips_at_margin_two_eps` — the constant `2ε` is sharp: at
  margin exactly `2ε` the selection does flip.
* `NET83.interaction_le_noiseBound` — the interaction cost is always at most
  the sup-norm of the quantization noise: budget tables need a correction, but
  a bounded one.
* `NET83.interaction_eq_of_zero_mean` — **mechanism (2)**, exactly: when the
  quantization error has zero mean over the full key set (so quantization
  alone is invisible: `degQ = 0`) the sparse arm still pays the full sparse
  noise average.  Dense attention averages the error away, sparse attention
  cannot.
* `NET83.sparse_noise_gain_ge_inv_card` and `NET83.uniform_noise_gain` —
  the Cauchy–Schwarz noise-gain bound `∑ wᵢ² ≥ 1/k`, i.e. the sparse arm's
  noise energy is `n/k` times the dense arm's.  This is the quantitative
  reason the interaction cost *decreases* as `k` grows, as observed
  (2.51% → 1.77% → 1.60% for k = 16, 20, 24).
* `NET83.interaction_worstcase_le` / `NET83.interaction_worstcase_attained` —
  the worst-case interaction cost over all `ε`-bounded, zero-mean noise is
  **exactly** `ε · min 1 ((n-k)/k)`, an antitone function of `k`
  (`NET83.worstBound_antitone`).
* `NET83.not_subadditive` (**P1 refuted**) and
  `NET83.axes_not_independent` (**P3 refuted**): no universal sub-additive
  budget law exists, and the two axes provably fail to be independent.
* `NET83.strict_superadditivity` (**P2 confirmed**): an explicit family of
  configurations on which the combined degradation strictly exceeds the sum.

Everything is proved from scratch over `Fin n → ℝ`; no result is definitional.
-/
import Mathlib

namespace NET83

open Finset

/-! ## 1.  The averaging model

An attention head with key set `Fin n` reads values `v : Fin n → ℝ`.  Dense
(fp32) attention averages over all `n` keys; top-k attention averages over a
selected set `S` with `S.card = k`.  Weight quantization perturbs the values by
`η : Fin n → ℝ`.
-/

variable {n : ℕ}

/-- Average of `f` over the index set `S` (zero if `S` is empty). -/
noncomputable def avgOn (S : Finset (Fin n)) (f : Fin n → ℝ) : ℝ :=
  (∑ i ∈ S, f i) / S.card

/-- Degradation of the **attention-only** arm: the sparse read minus the dense
read of the clean values. -/
noncomputable def degA (v : Fin n → ℝ) (S : Finset (Fin n)) : ℝ :=
  |avgOn S v - avgOn univ v|

/-- Degradation of the **quantization-only** arm: dense attention over the
perturbed values. -/
noncomputable def degQ (eta : Fin n → ℝ) : ℝ := |avgOn univ eta|

/-- Degradation of the **combined** arm: sparse attention over the perturbed
values. -/
noncomputable def degAQ (v eta : Fin n → ℝ) (S : Finset (Fin n)) : ℝ :=
  |avgOn S (fun i => v i + eta i) - avgOn univ v|

/-- The interaction cost: measured combined degradation minus the additive
prediction.  `0` means the axes are independent, `> 0` is super-additivity. -/
noncomputable def interaction (v eta : Fin n → ℝ) (S : Finset (Fin n)) : ℝ :=
  degAQ v eta S - degA v S - degQ eta

lemma avgOn_add (S : Finset (Fin n)) (f g : Fin n → ℝ) :
    avgOn S (fun i => f i + g i) = avgOn S f + avgOn S g := by
  simp [avgOn, Finset.sum_add_distrib, add_div]

/-- A bounded function has bounded averages. -/
lemma abs_avgOn_le {S : Finset (Fin n)} {f : Fin n → ℝ} {eps : ℝ}
    (hf : ∀ i, |f i| ≤ eps) : |avgOn S f| ≤ eps ∨ S = ∅ := by
  rcases S.eq_empty_or_nonempty with h | h
  · exact Or.inr h
  · left
    have hcard : (0 : ℝ) < S.card := by
      exact_mod_cast Finset.card_pos.mpr h
    have hsum : |∑ i ∈ S, f i| ≤ S.card * eps := by
      calc |∑ i ∈ S, f i| ≤ ∑ i ∈ S, |f i| := Finset.abs_sum_le_sum_abs _ _
        _ ≤ ∑ _i ∈ S, eps := Finset.sum_le_sum (fun i _ => hf i)
        _ = S.card * eps := by simp [mul_comm]
    rw [avgOn, abs_div, abs_of_nonneg (le_of_lt hcard)]
    rw [div_le_iff₀ hcard]
    simpa [mul_comm] using hsum

lemma abs_avgOn_le' {S : Finset (Fin n)} {f : Fin n → ℝ} {eps : ℝ}
    (hS : S.Nonempty) (hf : ∀ i, |f i| ≤ eps) : |avgOn S f| ≤ eps := by
  rcases abs_avgOn_le hf with h | h
  · exact h
  · exact absurd h (Finset.nonempty_iff_ne_empty.mp hS)

/-! An auxiliary fact used above: `|a + b| = |a| + |b|` exactly when `a` and `b`
have the same sign. -/
theorem abs_add_eq_add_abs_of_nonneg_mul {a b : ℝ} (h : 0 ≤ a * b) :
    |a + b| = |a| + |b| := by
  rcases le_or_gt 0 a with ha | ha
  · rcases le_or_gt 0 b with hb | hb
    · rw [abs_of_nonneg ha, abs_of_nonneg hb, abs_of_nonneg (by linarith)]
    · have : a = 0 := by nlinarith
      simp [this, abs_of_nonpos hb.le]
  · rcases le_or_gt b 0 with hb | hb
    · rw [abs_of_neg ha, abs_of_nonpos hb, abs_of_nonpos (by linarith)]; ring
    · have : b = 0 := by nlinarith
      simp [this, abs_of_neg ha]

/-! ## 2.  The interaction cost is real but bounded

Triangle inequality: the combined arm never loses more than the sparse arm plus
the sup-norm of the quantization noise.  So an engineering budget table needs
an interaction penalty, but the penalty is at most the noise scale.
-/

/-- **Bounded interaction penalty.**  With `ε`-bounded quantization noise the
interaction cost never exceeds `ε`. -/
theorem interaction_le_noiseBound {v eta : Fin n → ℝ} {S : Finset (Fin n)}
    {eps : ℝ} (hS : S.Nonempty) (heta : ∀ i, |eta i| ≤ eps) :
    interaction v eta S ≤ eps := by
  have hsplit : avgOn S (fun i => v i + eta i) = avgOn S v + avgOn S eta :=
    avgOn_add S v eta
  have htri : degAQ v eta S ≤ degA v S + |avgOn S eta| := by
    unfold degAQ degA
    rw [hsplit]
    have : avgOn S v + avgOn S eta - avgOn univ v
        = (avgOn S v - avgOn univ v) + avgOn S eta := by ring
    rw [this]
    exact abs_add_le _ _
  have hq : 0 ≤ degQ eta := abs_nonneg _
  have hb : |avgOn S eta| ≤ eps := abs_avgOn_le' hS heta
  unfold interaction
  linarith

/-- The interaction cost is never worse than the noise even in the presence of
a selection flip: the same bound holds for *any* selected set. -/
theorem interaction_le_noiseBound_forall {v eta : Fin n → ℝ} {eps : ℝ}
    (heta : ∀ i, |eta i| ≤ eps) :
    ∀ S : Finset (Fin n), S.Nonempty → interaction v eta S ≤ eps :=
  fun _ hS => interaction_le_noiseBound hS heta

/-! ## 3.  Mechanism (2): sparse sums cannot average the noise away

If the quantization error has zero mean over the whole key set, the dense arm
sees *nothing* (`degQ = 0`), yet the sparse arm pays the full sparse average of
the error.  The entire loss of the combined arm beyond `degA` is interaction.
-/

/-- Zero-mean quantization error is invisible to dense attention. -/
theorem degQ_eq_zero_of_zero_sum {eta : Fin n → ℝ}
    (h : ∑ i, eta i = 0) : degQ eta = 0 := by
  simp [degQ, avgOn, h]

/-- **Exact interaction identity.**  If the quantization error averages to zero
over all keys (invisible to dense attention) and the sparse read of the values
is on the same side as its sparse noise average, then the interaction cost is
*exactly* the sparse noise average. -/
theorem interaction_eq_of_zero_mean {v eta : Fin n → ℝ} {S : Finset (Fin n)}
    (hsum : ∑ i, eta i = 0)
    (hsign : 0 ≤ (avgOn S v - avgOn univ v) * avgOn S eta) :
    interaction v eta S = |avgOn S eta| := by
  have hq : degQ eta = 0 := degQ_eq_zero_of_zero_sum hsum
  have hsplit : avgOn S (fun i => v i + eta i) = avgOn S v + avgOn S eta :=
    avgOn_add S v eta
  have key : degAQ v eta S = degA v S + |avgOn S eta| := by
    unfold degAQ degA
    rw [hsplit, show avgOn S v + avgOn S eta - avgOn univ v
        = (avgOn S v - avgOn univ v) + avgOn S eta from by ring]
    exact abs_add_eq_add_abs_of_nonneg_mul hsign
  unfold interaction
  rw [key, hq]; ring


/-! ## 4.  The worst-case interaction cost is exactly `ε · min 1 ((n-k)/k)`

Among all quantization errors that are `ε`-bounded and invisible to dense
attention (zero mean), the sparse arm's extra loss is maximised at
`ε · min 1 ((n-k)/k)`.  This is an *antitone* function of the attention budget
`k`, matching the measured decay of the interaction cost
(2.51% → 1.77% → 1.60% at k = 16, 20, 24).
-/

/-- The worst-case interaction cost of a `k`-sparse head among `n` keys with
`ε`-bounded, zero-mean quantization noise. -/
noncomputable def worstBound (n k : ℕ) (eps : ℝ) : ℝ :=
  eps * min 1 (((n : ℝ) - k) / k)

/-- **Upper bound half of the exact worst case.**  Zero-mean `ε`-bounded noise
cannot shift a `k`-sparse read by more than `ε · min 1 ((n-k)/k)`. -/
theorem interaction_worstcase_le {S : Finset (Fin n)} {eta : Fin n → ℝ}
    {eps : ℝ} (hS : S.Nonempty) (hzero : ∑ i, eta i = 0)
    (heta : ∀ i, |eta i| ≤ eps) :
    |avgOn S eta| ≤ worstBound n S.card eps := by
  have hcard : (0 : ℝ) < S.card := by exact_mod_cast Finset.card_pos.mpr hS
  have heps : 0 ≤ eps := le_trans (abs_nonneg _) (heta ⟨0, by
      rcases hS with ⟨i, _⟩; exact Nat.pos_of_ne_zero (fun h => by simp [h] at i; exact i.elim0)⟩)
  have h1 : |avgOn S eta| ≤ eps := abs_avgOn_le' hS heta
  -- the complement bound
  have hsplit : (∑ i ∈ S, eta i) + (∑ i ∈ Sᶜ, eta i) = 0 := by
    rw [Finset.sum_add_sum_compl]; exact hzero
  have hcompl : |∑ i ∈ S, eta i| ≤ ((n : ℝ) - S.card) * eps := by
    have : (∑ i ∈ S, eta i) = -(∑ i ∈ Sᶜ, eta i) := by linarith
    rw [this, abs_neg]
    calc |∑ i ∈ Sᶜ, eta i| ≤ ∑ i ∈ Sᶜ, |eta i| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _i ∈ Sᶜ, eps := Finset.sum_le_sum (fun i _ => heta i)
      _ = (Sᶜ.card : ℝ) * eps := by simp [mul_comm]
      _ = ((n : ℝ) - S.card) * eps := by
          have hc : Sᶜ.card = n - S.card := by
            simp [Finset.card_compl]
          have hle : S.card ≤ n := by
            simpa using Finset.card_le_card (Finset.subset_univ S)
          rw [hc]
          congr 1
          push_cast [Nat.cast_sub hle]
          ring
  have h2 : |avgOn S eta| ≤ ((n : ℝ) - S.card) / S.card * eps := by
    rw [avgOn, abs_div, abs_of_nonneg hcard.le, div_le_iff₀ hcard]
    calc |∑ i ∈ S, eta i| ≤ ((n : ℝ) - S.card) * eps := hcompl
      _ = ((n : ℝ) - S.card) / S.card * eps * S.card := by field_simp
  unfold worstBound
  rcases le_total (1 : ℝ) (((n : ℝ) - S.card) / S.card) with h | h
  · rw [min_eq_left h]; simpa using h1
  · rw [min_eq_right h]; rw [mul_comm]; exact h2

/-- **Achievability half.**  When the budget is at most half the context
(`2k ≤ n`, the practical regime) the worst case `ε` is attained by an explicit
zero-mean, `ε`-bounded quantization error. -/
theorem interaction_worstcase_attained {S : Finset (Fin n)} {eps : ℝ}
    (hS : S.Nonempty) (heps : 0 ≤ eps) (hhalf : 2 * S.card ≤ n) :
    ∃ eta : Fin n → ℝ, (∑ i, eta i = 0) ∧ (∀ i, |eta i| ≤ eps) ∧
      avgOn S eta = eps ∧ worstBound n S.card eps = eps := by
  have hcard : (0 : ℝ) < S.card := by exact_mod_cast Finset.card_pos.mpr hS
  have hlt : (S.card : ℝ) ≤ (n : ℝ) - S.card := by
    have : (2 * S.card : ℝ) ≤ n := by exact_mod_cast hhalf
    linarith
  have hpos : (0 : ℝ) < (n : ℝ) - S.card := lt_of_lt_of_le hcard hlt
  refine ⟨fun i => if i ∈ S then eps else -((S.card : ℝ) / ((n : ℝ) - S.card)) * eps,
    ?_, ?_, ?_, ?_⟩
  · have hsplit := Finset.sum_add_sum_compl S
      (fun i => if i ∈ S then eps else -((S.card : ℝ) / ((n : ℝ) - S.card)) * eps)
    rw [← hsplit]
    have h1 : ∑ i ∈ S, (if i ∈ S then eps
        else -((S.card : ℝ) / ((n : ℝ) - S.card)) * eps) = (S.card : ℝ) * eps := by
      rw [Finset.sum_congr rfl (fun i hi => if_pos hi)]; simp [mul_comm]
    have hcc : (Sᶜ.card : ℝ) = (n : ℝ) - S.card := by
      have hle : S.card ≤ n := by simpa using Finset.card_le_card (Finset.subset_univ S)
      have hc : Sᶜ.card = n - S.card := by simp [Finset.card_compl]
      rw [hc]; push_cast [Nat.cast_sub hle]; ring
    have h2 : ∑ i ∈ Sᶜ, (if i ∈ S then eps
        else -((S.card : ℝ) / ((n : ℝ) - S.card)) * eps)
        = -((n : ℝ) - S.card) * ((S.card : ℝ) / ((n : ℝ) - S.card)) * eps := by
      rw [Finset.sum_congr rfl (fun i hi => if_neg (Finset.mem_compl.mp hi))]
      rw [Finset.sum_const, nsmul_eq_mul, hcc]; ring
    rw [h1, h2]
    field_simp
    ring
  · intro i
    by_cases hi : i ∈ S
    · simp [hi, abs_of_nonneg heps]
    · simp only [hi, if_false]
      rw [abs_mul, abs_neg, abs_of_nonneg heps,
        abs_of_nonneg (by positivity : (0:ℝ) ≤ (S.card : ℝ) / ((n : ℝ) - S.card))]
      have : (S.card : ℝ) / ((n : ℝ) - S.card) ≤ 1 := by
        rw [div_le_one hpos]; exact hlt
      nlinarith
  · rw [avgOn, Finset.sum_congr rfl (fun i hi => if_pos hi), Finset.sum_const,
      nsmul_eq_mul]
    field_simp
  · unfold worstBound
    have : (1 : ℝ) ≤ ((n : ℝ) - S.card) / S.card := by
      rw [le_div_iff₀ hcard]; linarith
    rw [min_eq_left this]; ring

/-- The worst-case interaction bound is **antitone in the attention budget**:
enlarging `k` can only shrink the interaction penalty. -/
theorem worstBound_antitone {k₁ k₂ : ℕ} {eps : ℝ} (heps : 0 ≤ eps)
    (h1 : 0 < k₁) (h12 : k₁ ≤ k₂) :
    worstBound n k₂ eps ≤ worstBound n k₁ eps := by
  have hk1 : (0 : ℝ) < k₁ := by exact_mod_cast h1
  have hk2 : (0 : ℝ) < k₂ := lt_of_lt_of_le hk1 (by exact_mod_cast h12)
  have hle : (k₁ : ℝ) ≤ k₂ := by exact_mod_cast h12
  unfold worstBound
  have hmono : ((n : ℝ) - k₂) / k₂ ≤ ((n : ℝ) - k₁) / k₁ := by
    rw [div_le_div_iff₀ hk2 hk1]
    nlinarith
  exact mul_le_mul_of_nonneg_left (min_le_min le_rfl hmono) heps

/-- Strict decay in the saturated regime `n/2 ≤ k₁ < k₂ < n`: there the
interaction penalty is *strictly* decreasing in the attention budget, which is
the qualitative shape observed in the NET-83 table. -/
theorem worstBound_strictAnti {k₁ k₂ : ℕ} {eps : ℝ} (heps : 0 < eps)
    (h1 : 0 < k₁) (h12 : k₁ < k₂) (hk2 : k₂ < n) (hhalf : n ≤ 2 * k₁) :
    worstBound n k₂ eps < worstBound n k₁ eps := by
  have hk1R : (0 : ℝ) < k₁ := by exact_mod_cast h1
  have hk2R : (0 : ℝ) < k₂ := by exact_mod_cast lt_trans h1 h12
  have hlt : (k₁ : ℝ) < k₂ := by exact_mod_cast h12
  have hn2 : (k₂ : ℝ) < n := by exact_mod_cast hk2
  have hhalfR : (n : ℝ) ≤ 2 * k₁ := by exact_mod_cast hhalf
  have e1 : ((n : ℝ) - k₁) / k₁ ≤ 1 := by rw [div_le_one hk1R]; linarith
  have e2 : ((n : ℝ) - k₂) / k₂ ≤ 1 := by
    rw [div_le_one hk2R]; linarith
  have hstrict : ((n : ℝ) - k₂) / k₂ < ((n : ℝ) - k₁) / k₁ := by
    rw [div_lt_div_iff₀ hk2R hk1R]
    nlinarith
  unfold worstBound
  rw [min_eq_right e1, min_eq_right e2]
  exact mul_lt_mul_of_pos_left hstrict heps

/-! ## 5.  Mechanism (1): quantization moves the top-k threshold

Top-k selection is a *discrete* operation, so a small perturbation of the
scores either changes nothing or changes the selected set outright.  The
switch happens exactly at score margin `2ε`.
-/

/-- `S` is a top-`k` set for the score vector `s`: it has `k` elements and no
excluded key scores above an included one. -/
def IsTopK (s : Fin n → ℝ) (k : ℕ) (S : Finset (Fin n)) : Prop :=
  S.card = k ∧ ∀ i ∈ S, ∀ j, j ∉ S → s j ≤ s i

/-- **Safe regime for mechanism (1).**  If the clean top-k margin exceeds twice
the score perturbation induced by quantization, the selected key set is
unchanged: quantization cannot re-route attention. -/
theorem selection_stable_of_margin {s e : Fin n → ℝ} {k : ℕ} {eps : ℝ}
    {S S' : Finset (Fin n)}
    (hS : IsTopK s k S) (hS' : IsTopK (fun i => s i + e i) k S')
    (he : ∀ i, |e i| ≤ eps)
    (hmargin : ∀ i ∈ S, ∀ j, j ∉ S → s j + 2 * eps < s i) : S' = S := by
  by_contra hne
  have hcards : S.card = S'.card := by rw [hS.1, hS'.1]
  have hSS' : (S' \ S).Nonempty := by
    rcases Finset.eq_empty_or_nonempty (S' \ S) with h | h
    · exact absurd (Finset.eq_of_subset_of_card_le
        (Finset.sdiff_eq_empty_iff_subset.mp h) (le_of_eq hcards)) hne
    · exact h
  have hS'S : (S \ S').Nonempty := by
    rcases Finset.eq_empty_or_nonempty (S \ S') with h | h
    · exact absurd (Finset.eq_of_subset_of_card_le
        (Finset.sdiff_eq_empty_iff_subset.mp h) (le_of_eq hcards.symm)).symm hne
    · exact h
  obtain ⟨j, hj⟩ := hSS'
  obtain ⟨i, hi⟩ := hS'S
  rw [Finset.mem_sdiff] at hj hi
  have hle : s i + e i ≤ s j + e j := hS'.2 j hj.1 i hi.2
  have hm := hmargin i hi.1 j hj.2
  have hei := abs_le.mp (he i)
  have hej := abs_le.mp (he j)
  linarith

/-- **Sharpness of the `2ε` threshold.**  At margin exactly `2ε` the selected
set does flip, so the strict inequality in `selection_stable_of_margin` cannot
be relaxed.  This is mechanism (1) of NET-83: quantized keys project
differently and a different key passes the top-k threshold. -/
theorem selection_flips_at_margin_two_eps :
    ∃ (s e : Fin 2 → ℝ) (S S' : Finset (Fin 2)) (eps : ℝ),
      0 < eps ∧ (∀ i, |e i| ≤ eps) ∧ IsTopK s 1 S ∧
      IsTopK (fun i => s i + e i) 1 S' ∧
      (∀ i ∈ S, ∀ j, j ∉ S → s j + 2 * eps ≤ s i) ∧ S' ≠ S := by
  refine ⟨![1, -1], ![-1, 1], {0}, {1}, 1, one_pos, ?_, ⟨by simp, ?_⟩,
    ⟨by simp, ?_⟩, ?_, ?_⟩
  · intro i; fin_cases i <;> norm_num
  · intro i hi j hj
    fin_cases i <;> fin_cases j <;> simp_all
  · intro i hi j hj
    fin_cases i <;> fin_cases j <;> simp_all
  · intro i hi j hj
    fin_cases i <;> fin_cases j <;> simp_all
    all_goals norm_num
  · intro h
    have : (1 : Fin 2) ∈ ({0} : Finset (Fin 2)) := by rw [← h]; simp
    simp at this

/-! ## 6.  Mechanism (2), quantitative: sparse weights cannot average noise away

If the attention weights are supported on `k` keys, the noise gain
`∑ wᵢ²` — the factor by which independent, unit-variance quantization error is
transmitted to the output — is at least `1/k`, attained by uniform weights.
Dense attention over `n` keys achieves `1/n`.  So sparsifying the head
multiplies the transmitted quantization energy by `n/k`.
-/

/-- Noise gain (transmitted variance factor) of a weight vector supported on
`S`. -/
noncomputable def noiseGain (S : Finset (Fin n)) (w : Fin n → ℝ) : ℝ :=
  ∑ i ∈ S, (w i) ^ 2

/-- **Cauchy–Schwarz floor on the noise gain.**  Any normalised attention
pattern supported on `k` keys transmits at least `1/k` of the quantization
variance. -/
theorem sparse_noise_gain_ge_inv_card {S : Finset (Fin n)} {w : Fin n → ℝ}
    (hS : S.Nonempty) (hw : ∑ i ∈ S, w i = 1) :
    1 / (S.card : ℝ) ≤ noiseGain S w := by
  have hcard : (0 : ℝ) < S.card := by exact_mod_cast Finset.card_pos.mpr hS
  have hcs : (∑ i ∈ S, w i) ^ 2 ≤ (S.card : ℝ) * ∑ i ∈ S, (w i) ^ 2 :=
    sq_sum_le_card_mul_sum_sq
  rw [hw, one_pow] at hcs
  rw [noiseGain, div_le_iff₀ hcard]
  linarith [hcs]

/-- Uniform attention over `S` attains the floor. -/
theorem uniform_noise_gain {S : Finset (Fin n)} (hS : S.Nonempty) :
    noiseGain S (fun _ => 1 / (S.card : ℝ)) = 1 / (S.card : ℝ) := by
  have hcard : (0 : ℝ) < S.card := by exact_mod_cast Finset.card_pos.mpr hS
  rw [noiseGain, Finset.sum_const, nsmul_eq_mul]
  field_simp

/-- **Noise amplification by sparsification.**  Restricting attention from `n`
keys to `k < n` keys multiplies the transmitted quantization variance by at
least `n/k > 1`: the sparse weighted sum cannot average the quantization error
away.  This is exactly the mechanism NET-83 proposes for the interaction
cost, and it predicts the observed decay of the penalty as `k` grows. -/
theorem noise_gain_amplification {S : Finset (Fin n)} {w : Fin n → ℝ}
    (hS : S.Nonempty) (hw : ∑ i ∈ S, w i = 1) (hlt : S.card < n) :
    1 < (n : ℝ) / S.card ∧
      (n : ℝ) / S.card * (1 / (n : ℝ)) ≤ noiseGain S w := by
  have hcard : (0 : ℝ) < S.card := by exact_mod_cast Finset.card_pos.mpr hS
  have hn : (0 : ℝ) < n := lt_trans hcard (by exact_mod_cast hlt)
  have hltR : (S.card : ℝ) < n := by exact_mod_cast hlt
  constructor
  · rw [lt_div_iff₀ hcard]; linarith
  · have : (n : ℝ) / S.card * (1 / (n : ℝ)) = 1 / (S.card : ℝ) := by
      field_simp
    rw [this]
    exact sparse_noise_gain_ge_inv_card hS hw

/-- The transmitted quantization energy of a uniform `k`-sparse head,
`σ²/k`, is **strictly decreasing** in the attention budget `k`. -/
theorem noiseEnergy_strictAnti {k₁ k₂ : ℕ} {sigma : ℝ} (hs : 0 < sigma)
    (h1 : 0 < k₁) (h12 : k₁ < k₂) :
    sigma ^ 2 / (k₂ : ℝ) < sigma ^ 2 / (k₁ : ℝ) := by
  have hk1 : (0 : ℝ) < k₁ := by exact_mod_cast h1
  have hk2 : (0 : ℝ) < k₂ := by exact_mod_cast lt_trans h1 h12
  have hlt : (k₁ : ℝ) < k₂ := by exact_mod_cast h12
  exact div_lt_div_of_pos_left (by positivity) hk1 hlt

/-! ## 7.  The verdict: P1 and P3 refuted, P2 confirmed -/

/-- **P2, confirmed in general form.**  Whenever the sparse read of the values
sits on the high side of the dense read and the budget is at most half the
context, there is an `ε`-bounded quantization error that is *completely
invisible* to dense attention (`degQ = 0`) yet costs the combined arm a further
`ε` on top of the sparse-attention loss.  The degradation of the integrated
system strictly exceeds the sum of the degradations of its parts. -/
theorem strict_superadditivity {S : Finset (Fin n)} {v : Fin n → ℝ} {eps : ℝ}
    (hS : S.Nonempty) (heps : 0 < eps) (hhalf : 2 * S.card ≤ n)
    (hside : avgOn univ v ≤ avgOn S v) :
    ∃ eta : Fin n → ℝ, (∀ i, |eta i| ≤ eps) ∧ degQ eta = 0 ∧
      interaction v eta S = eps ∧
      degAQ v eta S > degA v S + degQ eta := by
  obtain ⟨eta, hzero, hbound, havg, -⟩ :=
    interaction_worstcase_attained hS heps.le hhalf
  have hq : degQ eta = 0 := degQ_eq_zero_of_zero_sum hzero
  have hsign : 0 ≤ (avgOn S v - avgOn univ v) * avgOn S eta := by
    rw [havg]
    have : 0 ≤ avgOn S v - avgOn univ v := by linarith
    positivity
  have hint : interaction v eta S = eps := by
    rw [interaction_eq_of_zero_mean hzero hsign, havg, abs_of_nonneg heps.le]
  refine ⟨eta, hbound, hq, hint, ?_⟩
  unfold interaction at hint
  linarith

/-! ### An explicit four-key instance

`n = 4` keys, budget `k = 2`, values `v = (0,0,3,3)`, quantization error
`η = (-1,-1,-1,1)`.  Dense attention sees an error of only `1/2`; the sparse
head sees the full `-1`, and the two losses stack. -/

/-- Values of the explicit instance. -/
def vEx : Fin 4 → ℝ := fun i => if (i : ℕ) < 2 then 0 else 3

/-- Quantization error of the explicit instance. -/
def etaEx : Fin 4 → ℝ := fun i => if (i : ℕ) < 3 then -1 else 1

/-- Selected key set of the explicit instance. -/
def SEx : Finset (Fin 4) := {0, 1}

lemma SEx_card : SEx.card = 2 := by decide

lemma sum_SEx (f : Fin 4 → ℝ) : ∑ i ∈ SEx, f i = f 0 + f 1 :=
  Finset.sum_pair (by decide)

lemma degA_ex : degA vEx SEx = 3 / 2 := by
  rw [degA, avgOn, avgOn, sum_SEx, SEx_card]
  norm_num [vEx, Fin.sum_univ_four]

lemma degQ_ex : degQ etaEx = 1 / 2 := by
  rw [degQ, avgOn]
  norm_num [etaEx, Fin.sum_univ_four]

lemma degAQ_ex : degAQ vEx etaEx SEx = 5 / 2 := by
  rw [degAQ, avgOn, avgOn, sum_SEx, SEx_card]
  norm_num [vEx, etaEx, Fin.sum_univ_four]

/-- The explicit instance is strictly super-additive with interaction cost
`1/2`: measured `5/2` against an additive prediction of `3/2 + 1/2 = 2`. -/
theorem interaction_ex : interaction vEx etaEx SEx = 1 / 2 := by
  rw [interaction, degA_ex, degQ_ex, degAQ_ex]; norm_num

/-- **P1 refuted.**  There is no universal sub-additive (indeed no additive)
budget law: the combined degradation can exceed the sum of the parts. -/
theorem not_subadditive :
    ¬ (∀ (m : ℕ) (v eta : Fin m → ℝ) (S : Finset (Fin m)), S.Nonempty →
        degAQ v eta S ≤ degA v S + degQ eta) := by
  intro h
  have := h 4 vEx etaEx SEx ⟨0, by decide⟩
  rw [degA_ex, degQ_ex, degAQ_ex] at this
  norm_num at this

/-- **P3 refuted.**  The quantization axis and the attention-budget axis are
not independent: the interaction term is not identically zero. -/
theorem axes_not_independent :
    ¬ (∀ (m : ℕ) (v eta : Fin m → ℝ) (S : Finset (Fin m)), S.Nonempty →
        interaction v eta S = 0) := by
  intro h
  have := h 4 vEx etaEx SEx ⟨0, by decide⟩
  rw [interaction_ex] at this
  norm_num at this

/-- **Corrected budget law.**  The honest engineering statement: the combined
degradation lies between the additive prediction and the additive prediction
plus the worst-case interaction penalty.  Naive additivity is a *lower* bound,
never an upper bound. -/
theorem budget_law_two_sided {v eta : Fin n → ℝ} {S : Finset (Fin n)} {eps : ℝ}
    (hS : S.Nonempty) (hzero : ∑ i, eta i = 0) (heta : ∀ i, |eta i| ≤ eps) :
    degAQ v eta S ≤ degA v S + degQ eta + worstBound n S.card eps := by
  have hsplit : avgOn S (fun i => v i + eta i) = avgOn S v + avgOn S eta :=
    avgOn_add S v eta
  have hb : |avgOn S eta| ≤ worstBound n S.card eps :=
    interaction_worstcase_le hS hzero heta
  have hq : 0 ≤ degQ eta := abs_nonneg _
  have htri : degAQ v eta S ≤ degA v S + |avgOn S eta| := by
    unfold degAQ degA
    rw [hsplit, show avgOn S v + avgOn S eta - avgOn univ v
        = (avgOn S v - avgOn univ v) + avgOn S eta from by ring]
    exact abs_add_le _ _
  linarith

/-! ## 8.  Lab notes — the measured NET-83 table

Retained accuracy, verbatim from the run (paper 165):
`attn k=16/20/24 → 0.9768 / 0.9803 / 0.9851`, `GPTQ4 → 0.9081`,
`GPTQ4+k → 0.8598 / 0.8707 / 0.8772`.  The three arithmetic statements below
are the interaction costs, and their monotone decay in `k` is precisely the
shape predicted by `worstBound_antitone` and `noiseEnergy_strictAnti`.
-/

/-- Measured interaction cost at budget `k`: combined loss minus the sum of the
individual losses, computed from retained accuracies. -/
def measuredInteraction (retAttn retQuant retBoth : ℝ) : ℝ :=
  (1 - retBoth) - ((1 - retAttn) + (1 - retQuant))

/-- The three measured interaction costs are positive (super-additivity) and
strictly decreasing in the attention budget `k`, matching the model. -/
theorem net83_table_superadditive_and_antitone :
    0 < measuredInteraction 0.9768 0.9081 0.8598 ∧
    0 < measuredInteraction 0.9803 0.9081 0.8707 ∧
    0 < measuredInteraction 0.9851 0.9081 0.8772 ∧
    measuredInteraction 0.9803 0.9081 0.8707
      < measuredInteraction 0.9768 0.9081 0.8598 ∧
    measuredInteraction 0.9851 0.9081 0.8772
      < measuredInteraction 0.9803 0.9081 0.8707 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> norm_num [measuredInteraction]

/-- The same verdict read off the cross-entropies: the combined arm's CE excess
over fp32 exceeds the sum of the two individual excesses. -/
theorem net83_crossentropy_superadditive :
    ((2.774 : ℝ) - 2.697) + (3.015 - 2.697) < (3.220 - 2.697) ∧
    ((2.755 : ℝ) - 2.697) + (3.015 - 2.697) < (3.180 - 2.697) ∧
    ((2.742 : ℝ) - 2.697) + (3.015 - 2.697) < (3.155 - 2.697) := by
  refine ⟨?_, ?_, ?_⟩ <;> norm_num

/-! ## 9.  Adversarial review: the effect is *not* a pointwise identity

Critic stage.  Super-additivity is a worst-case (and, by §10, an average-case)
phenomenon, not a pointwise law: a lucky quantization error can partially
cancel the sparse-attention bias, giving a **negative** interaction.  The
honest statement is the two-sided budget law of §7 together with the
mean-square identity of §10.
-/

/-- A quantization error that partially cancels the sparse-attention bias. -/
def etaCancel : Fin 4 → ℝ := fun i => if (i : ℕ) < 3 then 1 else -1

lemma degQ_cancel : degQ etaCancel = 1 / 2 := by
  rw [degQ, avgOn]
  norm_num [etaCancel, Fin.sum_univ_four]

lemma degAQ_cancel : degAQ vEx etaCancel SEx = 1 / 2 := by
  rw [degAQ, avgOn, avgOn, sum_SEx, SEx_card]
  norm_num [vEx, etaCancel, Fin.sum_univ_four]

/-- **Boundary of the verdict.**  On the very same values and key budget, a
different `1`-bounded quantization error makes the interaction *negative*: the
combined arm beats the sparse arm alone.  So NET-83's super-additivity cannot
be upgraded to a pointwise inequality; it is a worst-case and mean-square
statement. -/
theorem interaction_can_be_negative :
    interaction vEx etaCancel SEx < 0 := by
  rw [interaction, degA_ex, degQ_cancel, degAQ_cancel]; norm_num

/-! ## 10.  Exact mean-square interaction `σ²(1/k − 1/n)`

Model the quantization error as a random vector on a finite ensemble `Ω` with
uniform weights, coordinatewise centred, pairwise uncorrelated and of common
variance `σ²` — the standard dither model for round-to-nearest quantization.
Then **no adversarial choice is needed**: in the mean-square metric the
interaction term is identically `σ²(1/k − 1/n) > 0` for every budget `k < n`,
and it decays like `1/k`, which is the shape of the NET-83 table.
-/

section MeanSquare

variable {Omega : Type*} [Fintype Omega] [Nonempty Omega]

/-- Uniform average over the finite noise ensemble `Ω`. -/
noncomputable def Eavg (g : Omega → ℝ) : ℝ :=
  (∑ w, g w) / (Fintype.card Omega)

lemma Eavg_const (c : ℝ) : Eavg (fun _ : Omega => c) = c := by
  have h : (0 : ℝ) < (Fintype.card Omega) := by exact_mod_cast Fintype.card_pos
  rw [Eavg, Finset.sum_const, nsmul_eq_mul, Finset.card_univ]
  field_simp

omit [Nonempty Omega] in
lemma Eavg_add (g h : Omega → ℝ) :
    Eavg (fun w => g w + h w) = Eavg g + Eavg h := by
  simp [Eavg, Finset.sum_add_distrib, add_div]

omit [Nonempty Omega] in
lemma Eavg_const_mul (c : ℝ) (g : Omega → ℝ) :
    Eavg (fun w => c * g w) = c * Eavg g := by
  simp [Eavg, ← Finset.mul_sum, mul_div_assoc]

omit [Nonempty Omega] in
lemma Eavg_sum {ι : Type*} (S : Finset ι) (g : ι → Omega → ℝ) :
    Eavg (fun w => ∑ i ∈ S, g i w) = ∑ i ∈ S, Eavg (g i) := by
  rw [Eavg, Finset.sum_comm, Finset.sum_div]
  simp [Eavg]

omit [Nonempty Omega] in
/-- **Second moment of a sparse read of centred, uncorrelated noise.**
A uniform `k`-sparse attention head transmits exactly `σ²/k` of the
quantization variance; the dense head (`k = n`) transmits `σ²/n`. -/
theorem meansquare_avgOn (eta : Omega → Fin n → ℝ) (sigma : ℝ)
    {S : Finset (Fin n)} (hS : S.Nonempty)
    (hcov : ∀ i j, i ≠ j → Eavg (fun w => eta w i * eta w j) = 0)
    (hvar : ∀ i, Eavg (fun w => (eta w i) ^ 2) = sigma ^ 2) :
    Eavg (fun w => (avgOn S (eta w)) ^ 2) = sigma ^ 2 / S.card := by
  have hcard : (0 : ℝ) < S.card := by exact_mod_cast Finset.card_pos.mpr hS
  have hfun : (fun w => (avgOn S (eta w)) ^ 2)
      = fun w => (1 / (S.card : ℝ) ^ 2) * ∑ i ∈ S, ∑ j ∈ S, eta w i * eta w j := by
    funext w
    have hsq : (∑ i ∈ S, eta w i) ^ 2 = ∑ i ∈ S, ∑ j ∈ S, eta w i * eta w j := by
      rw [sq, Finset.sum_mul_sum]
    rw [avgOn, div_pow, hsq]
    field_simp
  rw [hfun, Eavg_const_mul]
  have hinner : Eavg (fun w => ∑ i ∈ S, ∑ j ∈ S, eta w i * eta w j)
      = ∑ i ∈ S, ∑ j ∈ S, Eavg (fun w => eta w i * eta w j) := by
    rw [Eavg_sum S (fun i w => ∑ j ∈ S, eta w i * eta w j)]
    exact Finset.sum_congr rfl
      (fun i _ => Eavg_sum S (fun j w => eta w i * eta w j))
  rw [hinner]
  have hdiag : ∀ i ∈ S, ∑ j ∈ S, Eavg (fun w => eta w i * eta w j) = sigma ^ 2 := by
    intro i hi
    rw [Finset.sum_eq_single i]
    · simpa [sq] using hvar i
    · intro j _ hne; exact hcov i j (Ne.symm hne)
    · intro h; exact absurd hi h
  rw [Finset.sum_congr rfl hdiag, Finset.sum_const, nsmul_eq_mul]
  field_simp

omit [Nonempty Omega] in
/-- The centred sparse read has mean zero. -/
lemma Eavg_avgOn_eq_zero (eta : Omega → Fin n → ℝ) {S : Finset (Fin n)}
    (hmean : ∀ i, Eavg (fun w => eta w i) = 0) :
    Eavg (fun w => avgOn S (eta w)) = 0 := by
  have hfun : (fun w => avgOn S (eta w))
      = fun w => (1 / (S.card : ℝ)) * ∑ i ∈ S, eta w i := by
    funext w; rw [avgOn]; ring
  rw [hfun, Eavg_const_mul, Eavg_sum S (fun i w => eta w i)]
  simp [hmean]

/-- **Crown theorem — universal mean-square super-additivity.**
For centred, pairwise uncorrelated quantization noise of variance `σ²`, the
mean-square degradation of the integrated system exceeds the sum of the
mean-square degradations of its parts by *exactly* `σ²(1/k − 1/n)`.  No
adversarial choice of noise and no sign condition on the values is required:
the interaction cost is an identity of the model, positive for every budget
`k < n`, and decaying like `1/k`. -/
theorem meansquare_interaction_exact (eta : Omega → Fin n → ℝ) (sigma : ℝ)
    (v : Fin n → ℝ) {S : Finset (Fin n)} (hS : S.Nonempty)
    (hmean : ∀ i, Eavg (fun w => eta w i) = 0)
    (hcov : ∀ i j, i ≠ j → Eavg (fun w => eta w i * eta w j) = 0)
    (hvar : ∀ i, Eavg (fun w => (eta w i) ^ 2) = sigma ^ 2) :
    Eavg (fun w => (avgOn S (fun i => v i + eta w i) - avgOn univ v) ^ 2)
      - (avgOn S v - avgOn univ v) ^ 2
      - Eavg (fun w => (avgOn univ (eta w)) ^ 2)
      = sigma ^ 2 * (1 / (S.card : ℝ) - 1 / (n : ℝ)) := by
  have hne : Nonempty (Fin n) := ⟨hS.choose⟩
  have huniv : (univ : Finset (Fin n)).Nonempty := Finset.univ_nonempty
  set b := avgOn S v - avgOn univ v with hb
  have hfun : (fun w => (avgOn S (fun i => v i + eta w i) - avgOn univ v) ^ 2)
      = fun w => (b ^ 2 + 2 * b * avgOn S (eta w)) + (avgOn S (eta w)) ^ 2 := by
    funext w
    rw [avgOn_add S v (eta w), hb]
    ring
  rw [hfun, Eavg_add (fun w => b ^ 2 + 2 * b * avgOn S (eta w))
      (fun w => (avgOn S (eta w)) ^ 2),
    Eavg_add (fun _ => b ^ 2) (fun w => 2 * b * avgOn S (eta w)),
    Eavg_const (b ^ 2), Eavg_const_mul (2 * b) (fun w => avgOn S (eta w)),
    Eavg_avgOn_eq_zero eta hmean,
    meansquare_avgOn eta sigma hS hcov hvar,
    meansquare_avgOn eta sigma huniv hcov hvar]
  have hcardn : ((univ : Finset (Fin n)).card : ℝ) = (n : ℝ) := by
    simp
  rw [hcardn]
  ring

/-- The mean-square interaction cost is strictly positive whenever the head is
genuinely sparse and the quantization error is genuinely present. -/
theorem meansquare_interaction_pos (eta : Omega → Fin n → ℝ) (sigma : ℝ)
    (v : Fin n → ℝ) {S : Finset (Fin n)} (hS : S.Nonempty) (hsig : sigma ≠ 0)
    (hlt : S.card < n)
    (hmean : ∀ i, Eavg (fun w => eta w i) = 0)
    (hcov : ∀ i j, i ≠ j → Eavg (fun w => eta w i * eta w j) = 0)
    (hvar : ∀ i, Eavg (fun w => (eta w i) ^ 2) = sigma ^ 2) :
    0 < Eavg (fun w => (avgOn S (fun i => v i + eta w i) - avgOn univ v) ^ 2)
      - (avgOn S v - avgOn univ v) ^ 2
      - Eavg (fun w => (avgOn univ (eta w)) ^ 2) := by
  rw [meansquare_interaction_exact eta sigma v hS hmean hcov hvar]
  have hcard : (0 : ℝ) < S.card := by exact_mod_cast Finset.card_pos.mpr hS
  have hn : (S.card : ℝ) < n := by exact_mod_cast hlt
  have hnpos : (0 : ℝ) < n := lt_trans hcard hn
  have hgap : 0 < 1 / (S.card : ℝ) - 1 / (n : ℝ) := by
    have : 1 / (n : ℝ) < 1 / (S.card : ℝ) := by
      exact one_div_lt_one_div_of_lt hcard hn
    linarith
  have : 0 < sigma ^ 2 := by positivity
  positivity

end MeanSquare

/-! ## 11.  Non-vacuity: the Rademacher dither ensemble realises the model

The hypotheses of §10 are satisfiable for every `n` and every `σ`: take the
`2ⁿ` sign patterns with equal weight.  Centering and pairwise decorrelation are
proved by the coordinate-flip involution, which is the combinatorial core of
the argument.
-/

/-- Rademacher (random-sign) quantization error of scale `σ`. -/
def rad (sigma : ℝ) (w : Fin n → Bool) (i : Fin n) : ℝ :=
  if w i then sigma else -sigma

/-- Flip the `i`-th sign of a pattern. -/
def flipAt (i : Fin n) (w : Fin n → Bool) : Fin n → Bool :=
  Function.update w i (!w i)

lemma flipAt_involutive (i : Fin n) : Function.Involutive (flipAt i) := by
  intro w
  funext j
  by_cases h : j = i
  · subst h; simp [flipAt]
  · simp [flipAt, Function.update_of_ne h]

/-- A sum over all sign patterns of a function that is odd under one coordinate
flip vanishes. -/
lemma sum_eq_zero_of_flip_odd {i : Fin n} (g : (Fin n → Bool) → ℝ)
    (hodd : ∀ w, g (flipAt i w) = - g w) : ∑ w, g w = 0 := by
  have h1 : ∑ w, g (flipAt i w) = ∑ w, g w :=
    Equiv.sum_comp (Function.Involutive.toPerm _ (flipAt_involutive i)) g
  rw [Finset.sum_congr rfl (fun w _ => hodd w), Finset.sum_neg_distrib] at h1
  linarith

lemma rad_flip_self (sigma : ℝ) (i : Fin n) (w : Fin n → Bool) :
    rad sigma (flipAt i w) i = - rad sigma w i := by
  simp only [rad, flipAt, Function.update_self]
  cases w i <;> simp

lemma rad_flip_other (sigma : ℝ) {i j : Fin n} (hij : j ≠ i) (w : Fin n → Bool) :
    rad sigma (flipAt i w) j = rad sigma w j := by
  simp [rad, flipAt, Function.update_of_ne hij]

/-- The Rademacher ensemble is centred. -/
theorem rad_mean (sigma : ℝ) (i : Fin n) :
    Eavg (fun w : Fin n → Bool => rad sigma w i) = 0 := by
  rw [Eavg, sum_eq_zero_of_flip_odd (i := i) _ (fun w => rad_flip_self sigma i w)]
  simp

/-- The Rademacher ensemble is pairwise uncorrelated. -/
theorem rad_cov (sigma : ℝ) {i j : Fin n} (hij : i ≠ j) :
    Eavg (fun w : Fin n → Bool => rad sigma w i * rad sigma w j) = 0 := by
  rw [Eavg, sum_eq_zero_of_flip_odd (i := i) _ (fun w => ?_)]
  · simp
  · rw [rad_flip_self sigma i w, rad_flip_other sigma (Ne.symm hij) w]; ring

/-- Each Rademacher coordinate has variance `σ²`. -/
theorem rad_var (sigma : ℝ) (i : Fin n) :
    Eavg (fun w : Fin n → Bool => (rad sigma w i) ^ 2) = sigma ^ 2 := by
  have : (fun w : Fin n → Bool => (rad sigma w i) ^ 2) = fun _ => sigma ^ 2 := by
    funext w
    by_cases h : w i <;> simp [rad, h]
  rw [this, Eavg_const]

/-- **The model is non-vacuous and the crown theorem applies to it.**  For the
`2ⁿ`-point Rademacher dither ensemble, the mean-square interaction cost of
`k`-sparse attention with quantization of scale `σ` is exactly
`σ²(1/k − 1/n)`, hence strictly positive for every `k < n`. -/
theorem rademacher_interaction_exact (sigma : ℝ) (v : Fin n → ℝ)
    {S : Finset (Fin n)} (hS : S.Nonempty) :
    Eavg (fun w : Fin n → Bool =>
        (avgOn S (fun i => v i + rad sigma w i) - avgOn univ v) ^ 2)
      - (avgOn S v - avgOn univ v) ^ 2
      - Eavg (fun w : Fin n → Bool => (avgOn univ (rad sigma w)) ^ 2)
      = sigma ^ 2 * (1 / (S.card : ℝ) - 1 / (n : ℝ)) :=
  meansquare_interaction_exact (fun w => rad sigma w) sigma v hS
    (rad_mean sigma) (fun _ _ hij => rad_cov sigma hij) (rad_var sigma)

end NET83