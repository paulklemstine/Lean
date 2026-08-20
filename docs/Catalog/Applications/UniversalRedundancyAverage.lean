/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality III: the *average-case* (Bayes) theory

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1:
**one shared decompressor must serve all inputs**.

`MachineLearning.UniversalRedundancy.Core` settles the **worst-case pointwise**
price of universality: it is exactly `log₂ Cₛ`, the logarithm of the Shtarkov
sum.  That is a *minimax over messages*: it charges the universal code for its
single worst message.  The classical Rissanen-style question is the
**average-case** one:

> for a source `p_θ`, a universal coding distribution `q` costs
> `E_{p_θ} log₂ (1/q)` bits while the code specialised to `θ` costs the entropy
> `H(p_θ)`.  How large must the excess `D(p_θ ‖ q)` be for the *worst* `θ`?

This file develops that theory from scratch on finite message spaces and links
it to the worst-case theory of the catalog.

## Main results

* `klDiv_nonneg` — Gibbs' inequality (finite-support form, with sub-probability
  reference measure); `avgRedundancy_nonneg` is Shannon's source-coding bound:
  no code beats the entropy on average.
* `klDiv_code_eq` — the operational identity: `D(p ‖ 2^{-ℓ})` *is* the excess of
  the expected code length over the entropy.
* `bayes_compensation` — the **compensation identity**
  `∑_θ w θ · D(p_θ ‖ q) = I(w) + D(m_w ‖ q)`, where `m_w` is the Bayes mixture
  and `I(w)` the mutual information.  The mixture is the unique Bayes-optimal
  universal code, and the identity is the exact bookkeeping of the price of
  universality.
* `exists_kl_ge_mutualInfo` — **redundancy ≥ capacity**: for every coding
  distribution there is a source paying at least `I(w)` bits, for every prior
  `w` (Gallager–Davisson style lower bound).
* `klDiv_mixture_le` — **two-part-code upper bound**: the Bayes mixture pays at
  most `log₂ (1/w θ)`, hence at most `log₂ #Θ` under the uniform prior.
* `klDiv_nml_le_logb_shtarkovSum` — **average ≤ worst case**: the NML code of
  the catalog pays at most `log₂ Cₛ` on average against every source, so the
  average-case price never exceeds the worst-case price.
* `exists_kl_ge_log_card_of_disjoint`, `singular_minimax_average_exact` — for a
  class of **mutually singular** sources the average-case price is *exactly*
  `log₂ #Θ`: the universal code must literally spend the bits naming the source.
* `deterministic_average_price_bits` — on `n`-bit files the deterministic class
  costs exactly `n` bits on average as well (pigeonhole, in expectation), while
  `iid_average_price_le` bounds the memoryless class by `#A log₂ (n+1)`;
  `average_price_separation` is the resulting separation.

## Application keywords

minimax redundancy, Bayes mixture, mutual information, redundancy–capacity
theorem, Gibbs inequality, Kullback–Leibler divergence, universal compression
-/

import MachineLearning.UniversalRedundancy.Separation

open Finset Real

namespace UniversalRedundancy

/-! ## Kullback–Leibler divergence in bits -/

variable {X : Type*} [Fintype X]

/-- Kullback–Leibler divergence, in bits, of `p` from the coding distribution
`q` on a finite message space.  Terms with `p x = 0` contribute `0`. -/
noncomputable def klDiv (p q : X → ℝ) : ℝ := ∑ x, p x * logb 2 (p x / q x)

/-- Shannon entropy in bits. -/
noncomputable def entropyBits (p : X → ℝ) : ℝ := -∑ x, p x * logb 2 (p x)

/-- Expected code length of the length function `ℓ` under `p`. -/
noncomputable def avgLen (p : X → ℝ) (ℓ : X → ℝ) : ℝ := ∑ x, p x * ℓ x

/-- Pointwise Gibbs estimate: `p - q ≤ p log (p / q)` for `p ≥ 0 < q`. -/
lemma sub_le_mul_log_div {p q : ℝ} (hp : 0 ≤ p) (hq : 0 < q) :
    p - q ≤ p * Real.log (p / q) := by
  rcases eq_or_lt_of_le hp with h | h
  · simp [← h]; linarith
  · have h1 : Real.log (q / p) ≤ q / p - 1 :=
      Real.log_le_sub_one_of_pos (div_pos hq h)
    have h2 : Real.log (p / q) = -Real.log (q / p) := by
      rw [← Real.log_inv]
      congr 1
      field_simp
    have h3 : p * Real.log (q / p) ≤ p * (q / p - 1) :=
      mul_le_mul_of_nonneg_left h1 hp
    have h4 : p * (q / p - 1) = q - p := by field_simp
    rw [h2]
    nlinarith [h3, h4]

omit [Fintype X] in
/-- **Gibbs' inequality**, general finite-support form: over any finite set `s`,
if `p ≥ 0`, `r > 0` and `r` carries no more mass than `p` on `s`, the
Kullback–Leibler sum over `s` is nonnegative. -/
theorem sum_mul_logb_div_nonneg {s : Finset X} {p r : X → ℝ} (hp : ∀ x ∈ s, 0 ≤ p x)
    (hr : ∀ x ∈ s, 0 < r x) (h : ∑ x ∈ s, r x ≤ ∑ x ∈ s, p x) :
    0 ≤ ∑ x ∈ s, p x * logb 2 (p x / r x) := by
  have hsum : ∑ x ∈ s, (p x - r x) ≤ ∑ x ∈ s, p x * Real.log (p x / r x) :=
    Finset.sum_le_sum fun x hx => sub_le_mul_log_div (hp x hx) (hr x hx)
  have hsub : ∑ x ∈ s, (p x - r x) = (∑ x ∈ s, p x) - ∑ x ∈ s, r x := by
    rw [Finset.sum_sub_distrib]
  have h0 : 0 ≤ ∑ x ∈ s, p x * Real.log (p x / r x) := by
    rw [hsub] at hsum; linarith
  have hrw : ∑ x ∈ s, p x * logb 2 (p x / r x)
      = (∑ x ∈ s, p x * Real.log (p x / r x)) / Real.log 2 := by
    rw [Finset.sum_div]
    refine Finset.sum_congr rfl fun x _ => ?_
    rw [Real.logb]
    ring
  rw [hrw]
  exact div_nonneg h0 (Real.log_pos (by norm_num)).le

/-- **Gibbs' inequality** (finite form).  If `p` is nonnegative, `q` is strictly
positive and the total mass of `q` does not exceed that of `p`, then the
Kullback–Leibler sum is nonnegative. -/
theorem klDiv_nonneg_of_sum_le {p q : X → ℝ} (hp : ∀ x, 0 ≤ p x) (hq : ∀ x, 0 < q x)
    (h : ∑ x, q x ≤ ∑ x, p x) : 0 ≤ klDiv p q :=
  sum_mul_logb_div_nonneg (fun x _ => hp x) (fun x _ => hq x) h

/-- Gibbs' inequality for two probability distributions. -/
theorem klDiv_nonneg {p q : X → ℝ} (hp : ∀ x, 0 ≤ p x) (hq : ∀ x, 0 < q x)
    (hp1 : ∑ x, p x = 1) (hq1 : ∑ x, q x ≤ 1) : 0 ≤ klDiv p q :=
  klDiv_nonneg_of_sum_le hp hq (by rw [hp1]; exact hq1)

/-! ## The operational meaning: expected code length minus entropy -/

/-- The divergence from the implicit distribution `2 ^ (-ℓ)` of a code is
exactly the excess of the expected code length over the entropy. -/
theorem klDiv_code_eq {p : X → ℝ} (hp : ∀ x, 0 ≤ p x) (ℓ : X → ℕ) :
    klDiv p (fun x => (2 : ℝ) ^ (-(ℓ x : ℤ)))
      = avgLen p (fun x => (ℓ x : ℝ)) - entropyBits p := by
  unfold klDiv avgLen entropyBits
  rw [sub_neg_eq_add, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun x _ => ?_
  rcases eq_or_lt_of_le (hp x) with h | h
  · simp [← h]
  · have hpow : (0 : ℝ) < (2 : ℝ) ^ (-(ℓ x : ℤ)) := by positivity
    have hlog : logb 2 ((2 : ℝ) ^ (-(ℓ x : ℤ))) = -(ℓ x : ℝ) := by
      rw [show ((2 : ℝ) ^ (-(ℓ x : ℤ))) = (2 : ℝ) ^ ((-(ℓ x : ℤ) : ℤ) : ℝ) by
        rw [Real.rpow_intCast], Real.logb_rpow (by norm_num) (by norm_num)]
      push_cast
      ring
    rw [Real.logb_div (ne_of_gt h) (ne_of_gt hpow), hlog]
    ring

/-- **Shannon's source-coding bound.**  No Kraft-compliant code beats the
entropy of the source on average. -/
theorem avgRedundancy_nonneg {p : X → ℝ} (hp : ∀ x, 0 ≤ p x) (hp1 : ∑ x, p x = 1)
    {ℓ : X → ℕ} (hℓ : SourceClass.Kraft ℓ) :
    entropyBits p ≤ avgLen p (fun x => (ℓ x : ℝ)) := by
  have h := klDiv_nonneg (p := p) (q := fun x => (2 : ℝ) ^ (-(ℓ x : ℤ))) hp
    (fun x => by positivity) hp1 hℓ
  rw [klDiv_code_eq hp ℓ] at h
  linarith

/-! ## The Bayes mixture and the compensation identity -/

namespace SourceClass

variable {Θ : Type*} [Fintype Θ] (S : SourceClass X Θ)

/-- The **Bayes mixture** of a class under the prior `w`. -/
noncomputable def mix (w : Θ → ℝ) (x : X) : ℝ := ∑ θ, w θ * S.prob θ x

/-- **Mutual information** (in bits) between parameter and message under the
prior `w`: the Bayes redundancy of the mixture code. -/
noncomputable def mutualInfo (w : Θ → ℝ) : ℝ := ∑ θ, w θ * klDiv (S.prob θ) (S.mix w)

lemma mix_nonneg {w : Θ → ℝ} (hw : ∀ θ, 0 ≤ w θ) (x : X) : 0 ≤ S.mix w x :=
  Finset.sum_nonneg fun θ _ => mul_nonneg (hw θ) (S.nonneg θ x)

lemma mix_sum_one {w : Θ → ℝ} (hw1 : ∑ θ, w θ = 1) : ∑ x, S.mix w x = 1 := by
  unfold mix
  rw [Finset.sum_comm]
  calc ∑ θ, ∑ x, w θ * S.prob θ x = ∑ θ, w θ := by
        refine Finset.sum_congr rfl fun θ _ => ?_
        rw [← Finset.mul_sum, S.sum_one θ, mul_one]
    _ = 1 := hw1

lemma le_mix {w : Θ → ℝ} (hw : ∀ θ, 0 ≤ w θ) (θ : Θ) (x : X) :
    w θ * S.prob θ x ≤ S.mix w x :=
  Finset.single_le_sum (f := fun θ => w θ * S.prob θ x)
    (fun θ' _ => mul_nonneg (hw θ') (S.nonneg θ' x)) (Finset.mem_univ θ)

end SourceClass

/-- Pointwise chain rule for the divergence integrand. -/
lemma mul_logb_div_split {p m q : ℝ} (hp : 0 ≤ p) (hm : 0 < m) (hq : 0 < q) :
    p * logb 2 (p / q) = p * logb 2 (p / m) + p * logb 2 (m / q) := by
  rcases eq_or_lt_of_le hp with h | h
  · simp [← h]
  · rw [Real.logb_div (ne_of_gt h) (ne_of_gt hq), Real.logb_div (ne_of_gt h) (ne_of_gt hm),
      Real.logb_div (ne_of_gt hm) (ne_of_gt hq)]
    ring

namespace SourceClass

variable {Θ : Type*} [Fintype Θ] (S : SourceClass X Θ)

/-- **The compensation identity.**  For every prior `w` and every strictly
positive coding distribution `q`, the Bayes-average redundancy of `q` splits
exactly into the mutual information (the unavoidable part, paid even by the
optimal universal code) plus the divergence of `q` from the Bayes mixture (the
avoidable part).  Consequently the mixture is the Bayes-optimal universal
code. -/
theorem bayes_compensation_aux {w : Θ → ℝ} {q : X → ℝ} (hq : ∀ x, 0 < q x)
    (hm : ∀ x, 0 < S.mix w x) :
    ∑ θ, w θ * klDiv (S.prob θ) q
      = S.mutualInfo w + ∑ θ, w θ * ∑ x, S.prob θ x * logb 2 (S.mix w x / q x) := by
  have hsplit : ∀ θ, klDiv (S.prob θ) q
      = klDiv (S.prob θ) (S.mix w) + ∑ x, S.prob θ x * logb 2 (S.mix w x / q x) := by
    intro θ
    unfold klDiv
    rw [← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun x _ =>
      mul_logb_div_split (S.nonneg θ x) (hm x) (hq x)
  unfold mutualInfo
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun θ _ => ?_
  rw [hsplit θ]
  ring

/-- The cross term of the compensation identity is the divergence of the coding
distribution from the Bayes mixture. -/
lemma sum_cross_eq_klDiv_mix {w : Θ → ℝ} (q : X → ℝ) :
    ∑ θ, w θ * ∑ x, S.prob θ x * logb 2 (S.mix w x / q x)
      = ∑ x, S.mix w x * logb 2 (S.mix w x / q x) := by
  calc ∑ θ, w θ * ∑ x, S.prob θ x * logb 2 (S.mix w x / q x)
      = ∑ θ, ∑ x, (w θ * S.prob θ x) * logb 2 (S.mix w x / q x) := by
        refine Finset.sum_congr rfl fun θ _ => ?_
        rw [Finset.mul_sum]
        exact Finset.sum_congr rfl fun x _ => by ring
    _ = ∑ x, ∑ θ, (w θ * S.prob θ x) * logb 2 (S.mix w x / q x) := Finset.sum_comm
    _ = ∑ x, S.mix w x * logb 2 (S.mix w x / q x) := by
        refine Finset.sum_congr rfl fun x _ => ?_
        rw [← Finset.sum_mul]
        rfl

/-- **The compensation identity.**  For every prior `w` and every strictly
positive coding distribution `q`,

`∑_θ w θ · D(p_θ ‖ q) = I(w) + D(m_w ‖ q)`.

The Bayes-average price of the universal code `q` splits exactly into the
mutual information `I(w)` -- the unavoidable price of universality, paid even
by the best universal code -- plus the divergence from the Bayes mixture `m_w`,
which is the avoidable part.  In particular the mixture is Bayes optimal. -/
theorem bayes_compensation {w : Θ → ℝ} {q : X → ℝ} (hq : ∀ x, 0 < q x)
    (hm : ∀ x, 0 < S.mix w x) :
    ∑ θ, w θ * klDiv (S.prob θ) q = S.mutualInfo w + klDiv (S.mix w) q := by
  rw [S.bayes_compensation_aux hq hm, S.sum_cross_eq_klDiv_mix q]
  rfl

/-- **Redundancy ≥ capacity** (Gallager–Davisson lower bound).  Whatever
universal coding distribution `q` is used, some source in the class pays at
least the mutual information `I(w)`, for *every* prior `w`.  Maximising over
priors gives the channel-capacity lower bound on the minimax average
redundancy. -/
theorem exists_kl_ge_mutualInfo [Nonempty Θ] {w : Θ → ℝ} (hw : ∀ θ, 0 ≤ w θ)
    (hw1 : ∑ θ, w θ = 1) {q : X → ℝ} (hq : ∀ x, 0 < q x) (hq1 : ∑ x, q x ≤ 1)
    (hm : ∀ x, 0 < S.mix w x) :
    ∃ θ, S.mutualInfo w ≤ klDiv (S.prob θ) q := by
  obtain ⟨θmax, hmax⟩ := Finite.exists_max fun θ => klDiv (S.prob θ) q
  refine ⟨θmax, ?_⟩
  have hcomp := S.bayes_compensation hq hm
  have hmixkl : 0 ≤ klDiv (S.mix w) q :=
    klDiv_nonneg_of_sum_le (fun x => (hm x).le) hq (by rw [S.mix_sum_one hw1]; exact hq1)
  have hle : ∑ θ, w θ * klDiv (S.prob θ) q ≤ klDiv (S.prob θmax) q := by
    calc ∑ θ, w θ * klDiv (S.prob θ) q ≤ ∑ θ, w θ * klDiv (S.prob θmax) q :=
          Finset.sum_le_sum fun θ _ => mul_le_mul_of_nonneg_left (hmax θ) (hw θ)
      _ = klDiv (S.prob θmax) q := by rw [← Finset.sum_mul, hw1, one_mul]
  linarith

/-- **Two-part-code upper bound.**  Against the Bayes mixture, the source `θ`
pays at most `log₂ (1 / w θ)` bits: the cost of *naming* `θ` under the prior. -/
theorem klDiv_mix_le {w : Θ → ℝ} (hw : ∀ θ, 0 ≤ w θ) {θ : Θ} (hwθ : 0 < w θ) :
    klDiv (S.prob θ) (S.mix w) ≤ logb 2 (1 / w θ) := by
  have step : ∀ x : X, S.prob θ x * logb 2 (S.prob θ x / S.mix w x)
      ≤ S.prob θ x * logb 2 (1 / w θ) := by
    intro x
    rcases eq_or_lt_of_le (S.nonneg θ x) with h | h
    · simp [← h]
    · have hmix : 0 < S.mix w x := lt_of_lt_of_le (mul_pos hwθ h) (S.le_mix hw θ x)
      have hle : S.prob θ x / S.mix w x ≤ 1 / w θ := by
        rw [div_le_div_iff₀ hmix hwθ]
        have := S.le_mix hw θ x
        nlinarith
      exact mul_le_mul_of_nonneg_left
        (Real.logb_le_logb_of_le (by norm_num) (div_pos h hmix) hle) h.le
  calc klDiv (S.prob θ) (S.mix w) ≤ ∑ x, S.prob θ x * logb 2 (1 / w θ) :=
        Finset.sum_le_sum fun x _ => step x
    _ = logb 2 (1 / w θ) := by rw [← Finset.sum_mul, S.sum_one θ, one_mul]

end SourceClass

/-- The uniform prior on a finite parameter set. -/
noncomputable def uniformPrior (Θ : Type*) [Fintype Θ] : Θ → ℝ :=
  fun _ => (Fintype.card Θ : ℝ)⁻¹

lemma uniformPrior_nonneg {Θ : Type*} [Fintype Θ] (θ : Θ) : 0 ≤ uniformPrior Θ θ := by
  unfold uniformPrior; positivity

lemma uniformPrior_pos {Θ : Type*} [Fintype Θ] [Nonempty Θ] (θ : Θ) :
    0 < uniformPrior Θ θ := by
  have : (0 : ℝ) < (Fintype.card Θ : ℝ) := by exact_mod_cast Fintype.card_pos
  unfold uniformPrior; positivity

lemma uniformPrior_sum_one {Θ : Type*} [Fintype Θ] [Nonempty Θ] :
    ∑ θ, uniformPrior Θ θ = 1 := by
  have hcard : (0 : ℝ) < (Fintype.card Θ : ℝ) := by exact_mod_cast Fintype.card_pos
  unfold uniformPrior
  rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  field_simp

namespace SourceClass

variable {Θ : Type*} [Fintype Θ] (S : SourceClass X Θ)

/-- **The universal price is at most `log₂ #Θ` on average.**  The uniform
mixture code is within `log₂ #Θ` bits of the code tailored to the true source,
for every source in a finite class. -/
theorem klDiv_uniformMix_le [Nonempty Θ] (θ : Θ) :
    klDiv (S.prob θ) (S.mix (uniformPrior Θ)) ≤ logb 2 (Fintype.card Θ) := by
  have h := S.klDiv_mix_le (w := uniformPrior Θ) uniformPrior_nonneg (uniformPrior_pos θ)
  have hcard : (0 : ℝ) < (Fintype.card Θ : ℝ) := by exact_mod_cast Fintype.card_pos
  have : (1 : ℝ) / uniformPrior Θ θ = (Fintype.card Θ : ℝ) := by
    unfold uniformPrior; field_simp
  rwa [this] at h

/-- The mutual information of the uniform prior is at most `log₂ #Θ`. -/
theorem mutualInfo_uniformPrior_le [Nonempty Θ] :
    S.mutualInfo (uniformPrior Θ) ≤ logb 2 (Fintype.card Θ) := by
  unfold mutualInfo
  calc ∑ θ, uniformPrior Θ θ * klDiv (S.prob θ) (S.mix (uniformPrior Θ))
      ≤ ∑ _θ : Θ, uniformPrior Θ _θ * logb 2 (Fintype.card Θ) :=
        Finset.sum_le_sum fun θ _ =>
          mul_le_mul_of_nonneg_left (S.klDiv_uniformMix_le θ) (uniformPrior_nonneg θ)
    _ = logb 2 (Fintype.card Θ) := by
        rw [← Finset.sum_mul, uniformPrior_sum_one, one_mul]

/-! ## Average price ≤ worst-case price: the NML bridge -/

omit [Fintype Θ] in
/-- **The average-case price never exceeds the worst-case price.**  The NML code
of the class — the optimal *worst-case* universal code — pays at most `log₂ Cₛ`
bits on average against every source of the class. -/
theorem klDiv_nml_le_logb_shtarkovSum [Nonempty Θ] (hpos : ∀ x, 0 < S.maxLik x) (θ : Θ) :
    klDiv (S.prob θ) S.nml ≤ logb 2 S.shtarkovSum := by
  have hC := S.shtarkovSum_pos
  have step : ∀ x : X, S.prob θ x * logb 2 (S.prob θ x / S.nml x)
      ≤ S.prob θ x * logb 2 S.shtarkovSum := by
    intro x
    have hnml : 0 < S.nml x := div_pos (hpos x) hC
    rcases eq_or_lt_of_le (S.nonneg θ x) with h | h
    · simp [← h]
    · have hle : S.prob θ x / S.nml x ≤ S.shtarkovSum := by
        rw [div_le_iff₀ hnml]
        have := S.prob_le_shtarkovSum_mul_nml θ x
        linarith
      exact mul_le_mul_of_nonneg_left
        (Real.logb_le_logb_of_le (by norm_num) (div_pos h hnml) hle) h.le
  calc klDiv (S.prob θ) S.nml ≤ ∑ x, S.prob θ x * logb 2 S.shtarkovSum :=
        Finset.sum_le_sum fun x _ => step x
    _ = logb 2 S.shtarkovSum := by rw [← Finset.sum_mul, S.sum_one θ, one_mul]

/-! ## Mutually singular classes: the average price is exactly `log₂ #Θ` -/

omit [Fintype Θ] in
/-- Sources supported on their own support set vanish off it. -/
lemma prob_eq_zero_of_not_mem_supp [DecidableEq X] {supp : Θ → Finset X} {θ : Θ}
    (hmass : ∑ x ∈ supp θ, S.prob θ x = 1) {x : X} (hx : x ∉ supp θ) :
    S.prob θ x = 0 := by
  have hsplit : ∑ x ∈ supp θ, S.prob θ x + ∑ x ∈ univ \ supp θ, S.prob θ x
      = ∑ x, S.prob θ x := Finset.sum_add_sum_compl (supp θ) _
  rw [hmass, S.sum_one θ] at hsplit
  have hzero : ∑ x ∈ univ \ supp θ, S.prob θ x = 0 := by linarith
  have := (Finset.sum_eq_zero_iff_of_nonneg (fun x _ => S.nonneg θ x)).mp hzero
  exact this x (Finset.mem_sdiff.mpr ⟨Finset.mem_univ x, hx⟩)

/-- **The price of universality for a mutually singular class is at least
`log₂ #Θ` bits on average.**  If the sources of the class live on pairwise
disjoint supports, then *every* universal coding distribution loses at least
`log₂ #Θ` bits on average against some member of the class: the universal code
must effectively transmit the name of the source. -/
theorem exists_kl_ge_logb_card_of_disjoint [Nonempty Θ] [DecidableEq X]
    (supp : Θ → Finset X) (hdisj : ∀ θ θ', θ ≠ θ' → Disjoint (supp θ) (supp θ'))
    (hmass : ∀ θ, ∑ x ∈ supp θ, S.prob θ x = 1)
    {q : X → ℝ} (hq0 : ∀ x, 0 < q x) (hq1 : ∑ x, q x ≤ 1) :
    ∃ θ, logb 2 (Fintype.card Θ) ≤ klDiv (S.prob θ) q := by
  classical
  have hcard : (0 : ℝ) < (Fintype.card Θ : ℝ) := by exact_mod_cast Fintype.card_pos
  set c : Θ → ℝ := fun θ => ∑ x ∈ supp θ, q x with hcdef
  -- each support is nonempty, so `c θ > 0`
  have hne : ∀ θ, (supp θ).Nonempty := by
    intro θ
    rcases Finset.eq_empty_or_nonempty (supp θ) with he | h
    · exfalso; have := hmass θ; rw [he] at this; simp at this
    · exact h
  have hcpos : ∀ θ, 0 < c θ := fun θ =>
    Finset.sum_pos (fun x _ => hq0 x) (hne θ)
  -- the supports are disjoint, so the masses `c θ` sum to at most one
  have hsum : ∑ θ, c θ ≤ 1 := by
    have hpair : ((univ : Finset Θ) : Set Θ).PairwiseDisjoint supp := by
      intro θ _ θ' _ h
      exact hdisj θ θ' h
    have hb : ∑ θ, c θ = ∑ x ∈ (univ : Finset Θ).biUnion supp, q x :=
      (Finset.sum_biUnion hpair).symm
    rw [hb]
    exact le_trans (Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
      fun x _ _ => (hq0 x).le) hq1
  -- hence some source has small coding mass on its own support
  obtain ⟨θ, -, hθ⟩ : ∃ θ ∈ (univ : Finset Θ), c θ ≤ (Fintype.card Θ : ℝ)⁻¹ := by
    refine Finset.exists_le_of_sum_le ⟨Classical.arbitrary Θ, Finset.mem_univ _⟩ ?_
    calc ∑ θ, c θ ≤ 1 := hsum
      _ = ∑ _θ : Θ, (Fintype.card Θ : ℝ)⁻¹ := by
          rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]; field_simp
  refine ⟨θ, ?_⟩
  -- restrict the divergence to the support
  have hrestrict : klDiv (S.prob θ) q
      = ∑ x ∈ supp θ, S.prob θ x * logb 2 (S.prob θ x / q x) := by
    unfold klDiv
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro x _ hx
    rw [S.prob_eq_zero_of_not_mem_supp (hmass θ) hx, zero_mul]
  -- Gibbs against the conditional coding distribution `q / c θ`
  have hgibbs : 0 ≤ ∑ x ∈ supp θ, S.prob θ x * logb 2 (S.prob θ x / (q x / c θ)) := by
    refine sum_mul_logb_div_nonneg (fun x _ => S.nonneg θ x)
      (fun x _ => div_pos (hq0 x) (hcpos θ)) ?_
    rw [hmass θ, ← Finset.sum_div]
    exact le_of_eq (div_self (ne_of_gt (hcpos θ)))
  have hsplit : ∑ x ∈ supp θ, S.prob θ x * logb 2 (S.prob θ x / (q x / c θ))
      = (∑ x ∈ supp θ, S.prob θ x * logb 2 (S.prob θ x / q x)) + logb 2 (c θ) := by
    have hterm : ∀ x ∈ supp θ, S.prob θ x * logb 2 (S.prob θ x / (q x / c θ))
        = S.prob θ x * logb 2 (S.prob θ x / q x) + S.prob θ x * logb 2 (c θ) := by
      intro x _
      rcases eq_or_lt_of_le (S.nonneg θ x) with h | h
      · simp [← h]
      · rw [div_div_eq_mul_div, Real.logb_div (ne_of_gt (mul_pos h (hcpos θ))) (ne_of_gt (hq0 x)),
          Real.logb_div (ne_of_gt h) (ne_of_gt (hq0 x)),
          Real.logb_mul (ne_of_gt h) (ne_of_gt (hcpos θ))]
        ring
    rw [Finset.sum_congr rfl hterm, Finset.sum_add_distrib, ← Finset.sum_mul, hmass θ, one_mul]
  -- conclude
  have hkl : 0 ≤ klDiv (S.prob θ) q + logb 2 (c θ) := by
    rw [hrestrict]; rw [hsplit] at hgibbs; linarith
  have hlogc : logb 2 (c θ) ≤ -logb 2 (Fintype.card Θ) := by
    have h1 : logb 2 (c θ) ≤ logb 2 ((Fintype.card Θ : ℝ)⁻¹) :=
      Real.logb_le_logb_of_le (by norm_num) (hcpos θ) hθ
    rwa [Real.logb_inv] at h1
  linarith

/-- **Exact minimax average redundancy of a mutually singular class.**  The
uniform mixture pays at most `log₂ #Θ` bits against every source, and no coding
distribution can do better than `log₂ #Θ` against all of them: the average-case
price of universality is *exactly* `log₂ #Θ`, matching the worst-case value
`log₂ Cₛ = log₂ #Θ` of `shtarkovSum_eq_card_of_disjoint_supports`. -/
theorem singular_minimax_average_exact [Nonempty Θ] [DecidableEq X]
    (supp : Θ → Finset X) (hdisj : ∀ θ θ', θ ≠ θ' → Disjoint (supp θ) (supp θ'))
    (hmass : ∀ θ, ∑ x ∈ supp θ, S.prob θ x = 1) :
    (∀ θ, klDiv (S.prob θ) (S.mix (uniformPrior Θ)) ≤ logb 2 (Fintype.card Θ)) ∧
      (∀ q : X → ℝ, (∀ x, 0 < q x) → ∑ x, q x ≤ 1 →
        ∃ θ, logb 2 (Fintype.card Θ) ≤ klDiv (S.prob θ) q) :=
  ⟨S.klDiv_uniformMix_le, fun _q hq0 hq1 =>
    S.exists_kl_ge_logb_card_of_disjoint supp hdisj hmass hq0 hq1⟩

end SourceClass

end UniversalRedundancy