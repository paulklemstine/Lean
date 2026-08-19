/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality VIII: data processing and sufficiency

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1.

A practical universal compressor never sees the raw file: it sees a *parse* of
it — a token stream, a match/literal decomposition, a type (empirical
histogram).  Formally, the compressor is applied to `f x` for some
coarse-graining `f : X → Y`.  What does this cost?

**Data processing** (`capacity_pushforward_le`): coarse-graining never *raises*
the price of universality, `C(f_*S) ≤ C(S)`.  The engine is the log-sum
inequality (`logb_sum_le`, proved here from the catalog's pointwise Gibbs
estimate `sub_le_mul_log_div`), which gives monotonicity of the divergence under
pushforward, `klDiv_pushMeasure_le`.

**Sufficiency** (`capacity_pushforward_eq_of_factorizes`): if `f` is a
*sufficient statistic* in the Fisher–Neyman sense, `p_θ(x) = g_θ(f x) · h(x)`,
then the inequality is an equality, `C(f_*S) = C(S)` — the parse loses nothing.

Together these say precisely which front ends are free: **the price of
universality is a function of the sufficient statistic alone**, and every
non-sufficient parse pays for what it throws away.  This is the compression-side
counterpart of the classical statistical data-processing inequality, and it
tells the designer of a specialised decompressor exactly where the bits go.

## Main results

* `logb_sum_le` — the log-sum inequality in bits
* `klDiv_pushMeasure_le` — divergence decreases under coarse-graining
* `pushforward` — the coarse-grained source class `f_*S`
* `mutualInfo_pushforward_le`, `capacity_pushforward_le` — data processing for
  the average-case price of universality
* `klDiv_pushMeasure_eq_of_factorizes`, `mutualInfo_pushforward_eq_of_factorizes`,
  `capacity_pushforward_eq_of_factorizes` — sufficiency preserves the price

## Application keywords

universal compression, minimax redundancy, capacity, data processing
inequality, sufficient statistic, Fisher–Neyman factorization, log-sum
inequality
-/

import Bridges.UniversalRedundancyCapacityStructure

open Finset Real

namespace UniversalRedundancy

variable {X : Type*} [Fintype X] {Y : Type*} [Fintype Y] [DecidableEq Y]
variable {Θ : Type*} [Fintype Θ]

/-! ## The log-sum inequality -/

omit [Fintype X] in
/-- **Log-sum inequality** (natural logarithm).  For nonnegative `a` and
positive `b`, `(∑ a) log ((∑ a)/(∑ b)) ≤ ∑ a log (a/b)`. -/
lemma log_sum_le (s : Finset X) (a b : X → ℝ) (ha : ∀ x ∈ s, 0 ≤ a x)
    (hb : ∀ x ∈ s, 0 < b x) :
    (∑ x ∈ s, a x) * Real.log ((∑ x ∈ s, a x) / (∑ x ∈ s, b x))
      ≤ ∑ x ∈ s, a x * Real.log (a x / b x) := by
  rcases eq_or_lt_of_le (Finset.sum_nonneg ha) with hA0 | hApos
  · -- all of `a` vanishes
    have hzero : ∀ x ∈ s, a x = 0 := fun x hx =>
      (Finset.sum_eq_zero_iff_of_nonneg ha).1 hA0.symm x hx
    have h2 : ∑ x ∈ s, a x * Real.log (a x / b x) = 0 :=
      Finset.sum_eq_zero fun x hx => by rw [hzero x hx]; ring
    rw [h2, ← hA0]
    simp
  · have hsne : s.Nonempty := Finset.nonempty_of_sum_ne_zero (fun hz => by rw [hz] at hApos; exact lt_irrefl 0 hApos)
    have hBpos : 0 < ∑ x ∈ s, b x := Finset.sum_pos hb hsne
    have hcpos : 0 < (∑ x ∈ s, a x) / (∑ x ∈ s, b x) := div_pos hApos hBpos
    -- pointwise Gibbs estimate against the rescaled `b`
    have hterm : ∀ x ∈ s, a x - b x * ((∑ x ∈ s, a x) / (∑ x ∈ s, b x))
        ≤ a x * Real.log (a x / b x)
            - a x * Real.log ((∑ x ∈ s, a x) / (∑ x ∈ s, b x)) := by
      intro x hx
      have hbc : 0 < b x * ((∑ x ∈ s, a x) / (∑ x ∈ s, b x)) := mul_pos (hb x hx) hcpos
      have hkey := sub_le_mul_log_div (ha x hx) hbc
      rcases eq_or_lt_of_le (ha x hx) with h0 | hpos
      · rw [← h0]
        have hz : (0 : ℝ) * Real.log (0 / b x)
            - 0 * Real.log ((∑ x ∈ s, a x) / (∑ x ∈ s, b x)) = 0 := by ring
        rw [hz]
        linarith
      · have heq : a x * Real.log (a x / (b x * ((∑ x ∈ s, a x) / (∑ x ∈ s, b x))))
            = a x * Real.log (a x / b x)
                - a x * Real.log ((∑ x ∈ s, a x) / (∑ x ∈ s, b x)) := by
          rw [Real.log_div (ne_of_gt hpos) (ne_of_gt hbc),
            Real.log_div (ne_of_gt hpos) (ne_of_gt (hb x hx)),
            Real.log_mul (ne_of_gt (hb x hx)) (ne_of_gt hcpos)]
          ring
        rw [heq] at hkey
        exact hkey
    have hsum := Finset.sum_le_sum hterm
    rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, ← Finset.sum_mul,
      ← Finset.sum_mul] at hsum
    have hBc : (∑ x ∈ s, b x) * ((∑ x ∈ s, a x) / (∑ x ∈ s, b x)) = ∑ x ∈ s, a x := by
      field_simp
    rw [hBc] at hsum
    linarith

omit [Fintype X] in
/-- **Log-sum inequality in bits.** -/
lemma logb_sum_le (s : Finset X) (a b : X → ℝ) (ha : ∀ x ∈ s, 0 ≤ a x)
    (hb : ∀ x ∈ s, 0 < b x) :
    (∑ x ∈ s, a x) * logb 2 ((∑ x ∈ s, a x) / (∑ x ∈ s, b x))
      ≤ ∑ x ∈ s, a x * logb 2 (a x / b x) := by
  have hl2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h := log_sum_le s a b ha hb
  have hdiv : (∑ x ∈ s, a x) * Real.log ((∑ x ∈ s, a x) / (∑ x ∈ s, b x)) / Real.log 2
      ≤ (∑ x ∈ s, a x * Real.log (a x / b x)) / Real.log 2 := by
    gcongr
  calc (∑ x ∈ s, a x) * logb 2 ((∑ x ∈ s, a x) / (∑ x ∈ s, b x))
      = (∑ x ∈ s, a x) * Real.log ((∑ x ∈ s, a x) / (∑ x ∈ s, b x)) / Real.log 2 := by
        rw [Real.logb]; ring
    _ ≤ (∑ x ∈ s, a x * Real.log (a x / b x)) / Real.log 2 := hdiv
    _ = ∑ x ∈ s, a x * logb 2 (a x / b x) := by
        rw [Finset.sum_div]
        exact Finset.sum_congr rfl fun x _ => by rw [Real.logb]; ring

/-! ## Coarse-graining -/

/-- The pushforward of a mass function along `f`. -/
noncomputable def pushMeasure (f : X → Y) (p : X → ℝ) (y : Y) : ℝ :=
  ∑ x ∈ univ.filter (fun x => f x = y), p x

omit [Fintype Y] in
lemma pushMeasure_nonneg {f : X → Y} {p : X → ℝ} (hp : ∀ x, 0 ≤ p x) (y : Y) :
    0 ≤ pushMeasure f p y :=
  Finset.sum_nonneg fun x _ => hp x

lemma pushMeasure_sum (f : X → Y) (p : X → ℝ) :
    ∑ y, pushMeasure f p y = ∑ x, p x :=
  Finset.sum_fiberwise _ _ _

omit [Fintype Y] in
lemma pushMeasure_pos {f : X → Y} (hf : Function.Surjective f) {p : X → ℝ}
    (hp : ∀ x, 0 < p x) (y : Y) : 0 < pushMeasure f p y := by
  obtain ⟨x, hx⟩ := hf y
  refine Finset.sum_pos' (fun x' _ => (hp x').le) ⟨x, ?_, hp x⟩
  simp [hx]

/-- **Divergence decreases under coarse-graining** (data processing). -/
theorem klDiv_pushMeasure_le (f : X → Y) {p q : X → ℝ} (hp : ∀ x, 0 ≤ p x)
    (hq : ∀ x, 0 < q x) :
    klDiv (pushMeasure f p) (pushMeasure f q) ≤ klDiv p q := by
  unfold klDiv
  calc ∑ y, pushMeasure f p y * logb 2 (pushMeasure f p y / pushMeasure f q y)
      ≤ ∑ y, ∑ x ∈ univ.filter (fun x => f x = y), p x * logb 2 (p x / q x) :=
        Finset.sum_le_sum fun y _ =>
          logb_sum_le _ p q (fun x _ => hp x) (fun x _ => hq x)
    _ = ∑ x, p x * logb 2 (p x / q x) := Finset.sum_fiberwise _ _ _

namespace SourceClass

variable (S : SourceClass X Θ)

/-- The **coarse-grained source class** `f_*S`: every source is pushed forward
along `f`.  This is the class actually seen by a compressor whose front end
computes the statistic `f`. -/
noncomputable def pushforward (f : X → Y) : SourceClass Y Θ where
  prob θ := pushMeasure f (S.prob θ)
  nonneg θ := pushMeasure_nonneg (S.nonneg θ)
  sum_one θ := by rw [pushMeasure_sum]; exact S.sum_one θ

omit [Fintype Θ] in
lemma pushforward_prob (f : X → Y) (θ : Θ) :
    (S.pushforward f).prob θ = pushMeasure f (S.prob θ) := rfl

omit [Fintype Θ] in
lemma pushforward_pos {f : X → Y} (hf : Function.Surjective f)
    (hpos : ∀ θ x, 0 < S.prob θ x) (θ : Θ) (y : Y) :
    0 < (S.pushforward f).prob θ y :=
  pushMeasure_pos hf (hpos θ) y

/-- Coarse-graining commutes with Bayesian mixing. -/
lemma mix_pushforward (f : X → Y) (w : Θ → ℝ) :
    (S.pushforward f).mix w = pushMeasure f (S.mix w) := by
  funext y
  unfold mix pushMeasure pushforward
  simp only []
  rw [Finset.sum_comm]
  exact Finset.sum_congr rfl fun θ _ => by unfold pushMeasure; rw [Finset.mul_sum]

/-- **Data processing for the Bayes redundancy.** -/
theorem mutualInfo_pushforward_le (f : X → Y) {w : Θ → ℝ} (hw0 : ∀ θ, 0 ≤ w θ)
    (hpos : ∀ θ x, 0 < S.prob θ x) (hw1 : ∑ θ, w θ = 1) :
    (S.pushforward f).mutualInfo w ≤ S.mutualInfo w := by
  have hmpos : ∀ x, 0 < S.mix w x := S.mix_pos_of_mem_stdSimplex hpos ⟨hw0, hw1⟩
  unfold mutualInfo
  refine Finset.sum_le_sum fun θ _ => ?_
  refine mul_le_mul_of_nonneg_left ?_ (hw0 θ)
  rw [S.mix_pushforward f w, S.pushforward_prob f θ]
  exact klDiv_pushMeasure_le f (S.nonneg θ) hmpos

/-- **Data processing for the price of universality.**  A compressor that only
sees `f x` never pays *more* than one that sees `x`: coarse-graining cannot
increase the average-case minimax redundancy. -/
theorem capacity_pushforward_le [Nonempty Θ] {f : X → Y} (hf : Function.Surjective f)
    (hpos : ∀ θ x, 0 < S.prob θ x) :
    (S.pushforward f).capacity ≤ S.capacity := by
  obtain ⟨w, hw, hcap, -⟩ :=
    (S.pushforward f).exists_capacity_prior (S.pushforward_pos hf hpos)
  calc (S.pushforward f).capacity = (S.pushforward f).mutualInfo w := hcap.symm
    _ ≤ S.mutualInfo w := S.mutualInfo_pushforward_le f hw.1 hpos hw.2
    _ ≤ S.capacity := S.mutualInfo_le_capacity hpos hw

/-! ## Sufficiency

A statistic `f` is *sufficient* for the class when the likelihood factors as
`p_θ(x) = g_θ(f x) · h(x)` (Fisher–Neyman).  Then coarse-graining is free. -/

omit [Fintype Θ] in
/-- Under the Fisher–Neyman factorization the divergence to the mixture is
unchanged by the statistic. -/
theorem klDiv_pushMeasure_eq_of_factorizes (f : X → Y) {g : Θ → Y → ℝ} {h : X → ℝ}
    (hh : ∀ x, 0 ≤ h x) {θ : Θ} {G : Y → ℝ} :
    klDiv (pushMeasure f (fun x => g θ (f x) * h x))
        (pushMeasure f (fun x => G (f x) * h x))
      = klDiv (fun x => g θ (f x) * h x) (fun x => G (f x) * h x) := by
  have hH : ∀ y, pushMeasure f (fun x => g θ (f x) * h x) y
      = g θ y * ∑ x ∈ univ.filter (fun x => f x = y), h x := by
    intro y
    unfold pushMeasure
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl fun x hx => ?_
    rw [Finset.mem_filter] at hx
    simp only [hx.2]
  have hHG : ∀ y, pushMeasure f (fun x => G (f x) * h x) y
      = G y * ∑ x ∈ univ.filter (fun x => f x = y), h x := by
    intro y
    unfold pushMeasure
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl fun x hx => ?_
    rw [Finset.mem_filter] at hx
    simp only [hx.2]
  unfold klDiv
  have hleft : ∀ y : Y,
      pushMeasure f (fun x => g θ (f x) * h x) y
          * logb 2 (pushMeasure f (fun x => g θ (f x) * h x) y
              / pushMeasure f (fun x => G (f x) * h x) y)
        = (∑ x ∈ univ.filter (fun x => f x = y), h x) * (g θ y * logb 2 (g θ y / G y)) := by
    intro y
    have hHnn : 0 ≤ ∑ x ∈ univ.filter (fun x => f x = y), h x :=
      Finset.sum_nonneg fun x _ => hh x
    rw [hH y, hHG y]
    rcases eq_or_lt_of_le hHnn with h0 | hpos
    · rw [← h0]; simp
    · rw [mul_comm (g θ y) _, mul_comm (G y) _, mul_div_mul_left _ _ (ne_of_gt hpos)]
      ring
  have hright : ∀ x : X,
      (g θ (f x) * h x) * logb 2 ((g θ (f x) * h x) / (G (f x) * h x))
        = h x * (g θ (f x) * logb 2 (g θ (f x) / G (f x))) := by
    intro x
    rcases eq_or_lt_of_le (hh x) with h0 | hpos
    · rw [← h0]; simp
    · rw [mul_comm (g θ (f x)) (h x), mul_comm (G (f x)) (h x),
        mul_div_mul_left _ _ (ne_of_gt hpos)]
      ring
  calc ∑ y, pushMeasure f (fun x => g θ (f x) * h x) y
          * logb 2 (pushMeasure f (fun x => g θ (f x) * h x) y
              / pushMeasure f (fun x => G (f x) * h x) y)
      = ∑ y, ∑ x ∈ univ.filter (fun x => f x = y),
          h x * (g θ (f x) * logb 2 (g θ (f x) / G (f x))) := by
        refine Finset.sum_congr rfl fun y _ => ?_
        rw [hleft y, Finset.sum_mul]
        refine Finset.sum_congr rfl fun x hx => ?_
        rw [Finset.mem_filter] at hx
        rw [hx.2]
    _ = ∑ x, h x * (g θ (f x) * logb 2 (g θ (f x) / G (f x))) := Finset.sum_fiberwise _ _ _
    _ = ∑ x, (g θ (f x) * h x) * logb 2 ((g θ (f x) * h x) / (G (f x) * h x)) :=
        Finset.sum_congr rfl fun x _ => (hright x).symm

/-- **Sufficiency preserves the Bayes redundancy.** -/
theorem mutualInfo_pushforward_eq_of_factorizes (f : X → Y) {g : Θ → Y → ℝ} {h : X → ℝ}
    (hh : ∀ x, 0 ≤ h x)
    (hfact : ∀ θ x, S.prob θ x = g θ (f x) * h x) (w : Θ → ℝ) :
    (S.pushforward f).mutualInfo w = S.mutualInfo w := by
  set G : Y → ℝ := fun y => ∑ θ, w θ * g θ y with hGdef
  have hmix : S.mix w = fun x => G (f x) * h x := by
    funext x
    unfold mix
    rw [hGdef]
    simp only [Finset.sum_mul]
    exact Finset.sum_congr rfl fun θ _ => by rw [hfact θ x]; ring
  unfold mutualInfo
  refine Finset.sum_congr rfl fun θ _ => ?_
  refine congrArg (fun t => w θ * t) ?_
  have hp : S.prob θ = fun x => g θ (f x) * h x := funext fun x => hfact θ x
  rw [S.mix_pushforward f w, S.pushforward_prob f θ, hp, hmix]
  exact klDiv_pushMeasure_eq_of_factorizes f hh

/-- **Sufficiency preserves the price of universality.**  If `f` is a sufficient
statistic for the class (Fisher–Neyman factorization), the coarse-grained class
`f_*S` has exactly the same capacity: a front end that keeps only a sufficient
statistic costs no bits at all.  Combined with `capacity_pushforward_le`, the
average-case price of universality is a function of the sufficient statistic
alone. -/
theorem capacity_pushforward_eq_of_factorizes (f : X → Y)
    {g : Θ → Y → ℝ} {h : X → ℝ} (hh : ∀ x, 0 ≤ h x)
    (hfact : ∀ θ x, S.prob θ x = g θ (f x) * h x) :
    (S.pushforward f).capacity = S.capacity := by
  have himg : (fun w => (S.pushforward f).mutualInfo w) '' stdSimplex ℝ Θ
      = (fun w => S.mutualInfo w) '' stdSimplex ℝ Θ := by
    ext t
    constructor
    · rintro ⟨w, hw, rfl⟩
      exact ⟨w, hw, (S.mutualInfo_pushforward_eq_of_factorizes f hh hfact w).symm⟩
    · rintro ⟨w, hw, rfl⟩
      exact ⟨w, hw, S.mutualInfo_pushforward_eq_of_factorizes f hh hfact w⟩
  unfold capacity
  rw [himg]


/-! ## The other extreme: a front end that destroys everything

The trivial statistic `f ≡ ()` throws all the data away.  Its coarse-grained
class has capacity `0`, so for any class with two distinct sources the data
processing inequality `capacity_pushforward_le` is *strict*: a non-sufficient
front end really does lose bits, and the loss can be the whole price of
universality. -/

/-- The totally coarse statistic has zero price of universality. -/
theorem capacity_pushforward_trivial [Nonempty Θ] :
    (S.pushforward (fun _ : X => (default : Unit))).capacity = 0 := by
  have hmi : ∀ w : Θ → ℝ, w ∈ stdSimplex ℝ Θ →
      (S.pushforward (fun _ : X => (default : Unit))).mutualInfo w = 0 := by
    intro w hw
    have hprob : ∀ θ, (S.pushforward (fun _ : X => (default : Unit))).prob θ
        = fun _ : Unit => (1 : ℝ) := by
      intro θ
      funext u
      have : (univ.filter (fun _ : X => (default : Unit) = u)) = univ := by
        refine Finset.filter_true_of_mem fun x _ => ?_
        exact Subsingleton.elim _ _
      show pushMeasure _ _ u = 1
      unfold pushMeasure
      rw [this]
      exact S.sum_one θ
    have hmix : (S.pushforward (fun _ : X => (default : Unit))).mix w
        = fun _ : Unit => (1 : ℝ) := by
      funext u
      unfold mix
      simp only [hprob]
      rw [← Finset.sum_mul, hw.2, one_mul]
    unfold mutualInfo
    refine Finset.sum_eq_zero fun θ _ => ?_
    rw [hprob θ, hmix]
    have : klDiv (fun _ : Unit => (1 : ℝ)) (fun _ : Unit => (1 : ℝ)) = 0 := by
      unfold klDiv
      simp
    rw [this, mul_zero]
  have himg : (fun w => (S.pushforward (fun _ : X => (default : Unit))).mutualInfo w)
      '' stdSimplex ℝ Θ = {0} := by
    ext t
    constructor
    · rintro ⟨w, hw, rfl⟩
      exact hmi w hw
    · rintro rfl
      obtain ⟨w, hw⟩ : (stdSimplex ℝ Θ).Nonempty := Set.Nonempty.of_subtype
      exact ⟨w, hw, hmi w hw⟩
  unfold capacity
  rw [himg, csSup_singleton]

/-- **A non-sufficient front end is strictly costly.**  For a class containing
two distinct sources, discarding the data entirely strictly lowers the price of
universality: the data processing inequality is strict. -/
theorem capacity_pushforward_trivial_lt [Nonempty Θ] (hpos : ∀ θ x, 0 < S.prob θ x)
    {θ₁ θ₂ : Θ} (hne : S.prob θ₁ ≠ S.prob θ₂) :
    (S.pushforward (fun _ : X => (default : Unit))).capacity < S.capacity := by
  rw [S.capacity_pushforward_trivial]
  exact S.capacity_pos_of_ne hpos hne

end SourceClass

end UniversalRedundancy