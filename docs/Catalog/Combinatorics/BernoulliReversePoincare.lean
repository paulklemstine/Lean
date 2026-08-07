/-
# A reverse Poincaré inequality and the two-sided sharp-threshold window

`Catalog/Combinatorics/BernoulliPoincare.lean` proves the variance–influence
inequality

`P (1 - P) ≤ p (1 - p) ∑_v I_v`,

where `P = bernProb p A` and `I_v = bernProb p (pivotalSet A v)` is the influence
of the site `v`.  This file proves the *converse* direction, site by site:

`p (1 - p) I_v ≤ P (1 - P)`  for every single site `v`.

The proof is a completely explicit one-coordinate decomposition.  Conditioning on
the states of all sites other than `v`, every off-configuration falls into
exactly one of three classes for an increasing event `A`:

* `bothSet A v` — the event already occurs with `v` closed (mass `d`);
* `pivotalSet A v` — the event occurs iff `v` is open (mass `e`);
* `noneSet A v`  — the event fails even with `v` open (mass `f`).

Then `d + e + f = 1`, `P = d + p e`, `1 - P = f + (1-p) e`, and the polynomial
identity

`P (1 - P) - p (1-p) e = d f + (1-p)² d e + p² e f ≥ 0`

gives the inequality with no analysis at all.  The per-site bound is sharp: a
one-site event `{η | η v = true}` has `I_v = 1`, `P = p` and turns it into an
equality.  Summing over the sites gives `p (1-p) ∑_v I_v ≤ |ι| · P (1 - P)`, the
reverse of the Poincaré inequality up to the factor `|ι|`.

Integrating the resulting *two-sided* Russo differential inequality

`P (1 - P) ≤ p (1-p) P' ≤ |ι| P (1 - P)`

produces a two-sided odds-ratio comparison: the odds of an increasing event grow
at least like the odds of one site and at most like the `|ι|`-th power of the
odds of one site.  In particular, for densities in a fixed compact subinterval
of `(0,1)` the density window on which `P` moves from `ε` to `1 - ε` has length
at least of order `1/|ι|`: no increasing event on `|ι|` sites can have a
threshold sharper than that.

## Main results

* `bernProb_eq_offProb_add`: `P = d + p e`, the one-coordinate decomposition.
* `offProb_partition`: `d + e + f = 1`.
* `bernProb_pivotal_le_variance`: **reverse Poincaré**, `p(1-p) I_v ≤ P(1-P)`.
* `sum_pivotal_le_card_variance`: the summed form with the factor `|ι|`.
* `bernProb_variance_sandwich`: the two-sided Russo differential inequality.
* `odds_ratio_le_pow`: **reverse odds-ratio comparison**.
* `threshold_window_lower_bound`: a quantitative lower bound on the width of the
  threshold window of any increasing event on `|ι|` sites.
-/

import Combinatorics.BernoulliOddsRatio

open Finset

namespace BernoulliThresholdCoupling

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## The three classes of off-configurations -/

/-- Configurations for which the site `v` is irrelevant because `A` already
occurs with `v` closed. -/
def bothSet (A : Set (ι → Bool)) (v : ι) : Set (ι → Bool) :=
  {η | Function.update η v false ∈ A}

/-- Configurations for which the site `v` is irrelevant because `A` fails even
with `v` open. -/
def noneSet (A : Set (ι → Bool)) (v : ι) : Set (ι → Bool) :=
  {η | Function.update η v true ∉ A}

omit [Fintype ι] in
theorem bothSet_update_mem_iff (A : Set (ι → Bool)) (v : ι) (η : ι → Bool) (b : Bool) :
    Function.update η v b ∈ bothSet A v ↔ η ∈ bothSet A v := by
  simp only [bothSet, Set.mem_setOf_eq, Function.update_idem]

omit [Fintype ι] in
theorem noneSet_update_mem_iff (A : Set (ι → Bool)) (v : ι) (η : ι → Bool) (b : Bool) :
    Function.update η v b ∈ noneSet A v ↔ η ∈ noneSet A v := by
  simp only [noneSet, Set.mem_setOf_eq, Function.update_idem]

/-- The mass of a `v`-independent set computed from the off-`v` coordinates
only:  we sum the off-`v` weight over the configurations that are open at `v`,
which is a faithful enumeration of the off-`v` configurations. -/
noncomputable def offProb (p : ℝ) (v : ι) (S : Set (ι → Bool)) : ℝ :=
  ∑ η ∈ univ.filter (fun η : ι → Bool => η v = true), S.indicator (offWeight p v) η

theorem offWeight_nonneg {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (v : ι) (η : ι → Bool) :
    0 ≤ offWeight p v η := by
  unfold offWeight
  refine Finset.prod_nonneg fun u _ => ?_
  by_cases hb : η u = true
  · simpa [hb] using hp0
  · simp only [Bool.not_eq_true] at hb
    simpa [hb] using sub_nonneg.mpr hp1

theorem offProb_nonneg {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (v : ι) (S : Set (ι → Bool)) :
    0 ≤ offProb p v S :=
  Finset.sum_nonneg fun η _ =>
    Set.indicator_nonneg (fun x _ => offWeight_nonneg hp0 hp1 v x) η

/-- For a set whose membership does not depend on the state of `v`, the Bernoulli
probability is computed by the off-`v` weights alone. -/
theorem bernProb_eq_offProb (p : ℝ) (v : ι) (S : Set (ι → Bool))
    (hS : ∀ (η : ι → Bool) (b : Bool), Function.update η v b ∈ S ↔ η ∈ S) :
    bernProb p S = offProb p v S := by
  rw [bernProb, sum_split v, offProb]
  refine Finset.sum_congr rfl fun η hη => ?_
  simp only [mem_filter, mem_univ, true_and] at hη
  have hoff : offWeight p v (Function.update η v false) = offWeight p v η :=
    offWeight_update p v η false
  have hw1 : weight p η = p * offWeight p v η := by
    rw [weight_eq_mul_offWeight p v η, hη]; norm_num
  have hw2 : weight p (Function.update η v false) = (1 - p) * offWeight p v η := by
    rw [weight_eq_mul_offWeight p v (Function.update η v false), Function.update_self, hoff]
    norm_num
  by_cases hin : η ∈ S
  · have h2 : Function.update η v false ∈ S := (hS η false).mpr hin
    rw [Set.indicator_of_mem hin, Set.indicator_of_mem h2, Set.indicator_of_mem hin,
      hw1, hw2]
    ring
  · have h2 : Function.update η v false ∉ S := fun h => hin ((hS η false).mp h)
    rw [Set.indicator_of_notMem hin, Set.indicator_of_notMem h2,
      Set.indicator_of_notMem hin]
    ring

/-- The pivotal, both and none sets have `v`-independent membership, so their
probabilities are computed off `v`. -/
theorem bernProb_pivotalSet_eq_offProb (p : ℝ) (v : ι) (A : Set (ι → Bool)) :
    bernProb p (pivotalSet A v) = offProb p v (pivotalSet A v) :=
  bernProb_eq_offProb p v _ (fun η b => pivotalSet_update_mem_iff A v η b)

/-! ## The one-coordinate decomposition -/

/-- **One-coordinate decomposition of the Bernoulli probability.**  For an
increasing event, `P = d + p e` where `d` is the mass of the off-configurations
on which `A` occurs regardless of `v`, and `e` is the pivotal mass. -/
theorem bernProb_eq_offProb_add {A : Set (ι → Bool)} (hA : IsIncreasing A) (p : ℝ) (v : ι) :
    bernProb p A = offProb p v (bothSet A v) + p * offProb p v (pivotalSet A v) := by
  rw [bernProb, sum_split v, offProb, offProb, Finset.mul_sum, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun η hη => ?_
  simp only [mem_filter, mem_univ, true_and] at hη
  have hupd : Function.update η v true = η := Function.update_eq_self_iff.mpr hη.symm
  have hoff : offWeight p v (Function.update η v false) = offWeight p v η :=
    offWeight_update p v η false
  have hw1 : weight p η = p * offWeight p v η := by
    rw [weight_eq_mul_offWeight p v η, hη]; norm_num
  have hw2 : weight p (Function.update η v false) = (1 - p) * offWeight p v η := by
    rw [weight_eq_mul_offWeight p v (Function.update η v false), Function.update_self, hoff]
    norm_num
  by_cases hboth : Function.update η v false ∈ A
  · have hmem : η ∈ bothSet A v := hboth
    have hin : η ∈ A := by
      refine hA _ _ (fun u hu => ?_) hboth
      by_cases huv : u = v
      · subst huv; exact hη
      · rwa [Function.update_of_ne huv] at hu
    have hpiv : η ∉ pivotalSet A v := fun h => h.2 hboth
    rw [Set.indicator_of_mem hin, Set.indicator_of_mem hboth, Set.indicator_of_mem hmem,
      Set.indicator_of_notMem hpiv, hw1, hw2]
    ring
  · have hmem : η ∉ bothSet A v := hboth
    by_cases hin : η ∈ A
    · have hpiv : η ∈ pivotalSet A v := ⟨by rwa [hupd], hboth⟩
      rw [Set.indicator_of_mem hin, Set.indicator_of_notMem hboth,
        Set.indicator_of_notMem hmem, Set.indicator_of_mem hpiv, hw1]
      ring
    · have hpiv : η ∉ pivotalSet A v := fun h => hin (by rw [← hupd]; exact h.1)
      rw [Set.indicator_of_notMem hin, Set.indicator_of_notMem hboth,
        Set.indicator_of_notMem hmem, Set.indicator_of_notMem hpiv]
      ring

/-- **The three classes partition the off-configurations.** -/
theorem offProb_partition {A : Set (ι → Bool)} (hA : IsIncreasing A) (p : ℝ) (v : ι) :
    offProb p v (bothSet A v) + offProb p v (pivotalSet A v)
      + offProb p v (noneSet A v) = 1 := by
  rw [← sum_offWeight_filter p v, offProb, offProb, offProb, ← Finset.sum_add_distrib,
    ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun η _ => ?_
  by_cases h1 : Function.update η v true ∈ A
  · have hnone : η ∉ noneSet A v := fun h => h h1
    by_cases h2 : Function.update η v false ∈ A
    · have hboth : η ∈ bothSet A v := h2
      have hpiv : η ∉ pivotalSet A v := fun h => h.2 h2
      rw [Set.indicator_of_mem hboth, Set.indicator_of_notMem hpiv,
        Set.indicator_of_notMem hnone]
      ring
    · have hboth : η ∉ bothSet A v := h2
      have hpiv : η ∈ pivotalSet A v := ⟨h1, h2⟩
      rw [Set.indicator_of_notMem hboth, Set.indicator_of_mem hpiv,
        Set.indicator_of_notMem hnone]
      ring
  · have hnone : η ∈ noneSet A v := h1
    have h2 : Function.update η v false ∉ A := by
      intro hc
      refine h1 (hA _ _ (fun u hu => ?_) hc)
      by_cases huv : u = v
      · subst huv; simp
      · simpa [Function.update_of_ne huv] using hu
    have hboth : η ∉ bothSet A v := h2
    have hpiv : η ∉ pivotalSet A v := fun h => h1 h.1
    rw [Set.indicator_of_notMem hboth, Set.indicator_of_notMem hpiv,
      Set.indicator_of_mem hnone]
    ring

/-! ## The reverse Poincaré inequality -/

/-- **Reverse Poincaré inequality (per site).**  For an increasing event and any
single site `v`, the influence of `v` is at most the variance divided by
`p(1-p)`.  Equality holds when `A` depends only on the site `v`. -/
theorem bernProb_pivotal_le_variance {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {A : Set (ι → Bool)} (hA : IsIncreasing A) (v : ι) :
    p * (1 - p) * bernProb p (pivotalSet A v) ≤ bernProb p A * (1 - bernProb p A) := by
  set d := offProb p v (bothSet A v) with hdef
  set e := offProb p v (pivotalSet A v) with hedef
  set f := offProb p v (noneSet A v) with hfdef
  have hd : 0 ≤ d := offProb_nonneg hp0 hp1 v _
  have he : 0 ≤ e := offProb_nonneg hp0 hp1 v _
  have hf : 0 ≤ f := offProb_nonneg hp0 hp1 v _
  have hsum : d + e + f = 1 := offProb_partition hA p v
  have hP : bernProb p A = d + p * e := bernProb_eq_offProb_add hA p v
  have hE : bernProb p (pivotalSet A v) = e := bernProb_pivotalSet_eq_offProb p v A
  rw [hP, hE]
  have hfe : f = 1 - d - e := by linarith
  have key : (d + p * e) * (1 - (d + p * e)) - p * (1 - p) * e
      = d * f + (1 - p) ^ 2 * (d * e) + p ^ 2 * (e * f) := by
    rw [hfe]; ring
  have t1 : 0 ≤ d * f := mul_nonneg hd hf
  have t2 : 0 ≤ (1 - p) ^ 2 * (d * e) := mul_nonneg (sq_nonneg _) (mul_nonneg hd he)
  have t3 : 0 ≤ p ^ 2 * (e * f) := mul_nonneg (sq_nonneg _) (mul_nonneg he hf)
  linarith

/-- **Reverse Poincaré inequality (summed form).**  The total influence is at
most `|ι|` times the variance divided by `p(1-p)`. -/
theorem sum_pivotal_le_card_variance {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {A : Set (ι → Bool)} (hA : IsIncreasing A) :
    p * (1 - p) * ∑ v : ι, bernProb p (pivotalSet A v) ≤
      (Fintype.card ι : ℝ) * (bernProb p A * (1 - bernProb p A)) := by
  rw [Finset.mul_sum]
  calc ∑ v : ι, p * (1 - p) * bernProb p (pivotalSet A v)
      ≤ ∑ _v : ι, bernProb p A * (1 - bernProb p A) :=
        Finset.sum_le_sum fun v _ => bernProb_pivotal_le_variance hp0 hp1 hA v
    _ = (Fintype.card ι : ℝ) * (bernProb p A * (1 - bernProb p A)) := by
        rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

/-- **The two-sided Russo differential inequality.**  For an increasing event the
derivative of the Bernoulli probability polynomial is squeezed between the
variance and `|ι|` times the variance, both divided by `p(1-p)`. -/
theorem bernProb_variance_sandwich {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {A : Set (ι → Bool)} (hA : IsIncreasing A) :
    bernProb p A * (1 - bernProb p A) ≤
        p * (1 - p) * deriv (fun t : ℝ => bernProb t A) p ∧
      p * (1 - p) * deriv (fun t : ℝ => bernProb t A) p ≤
        (Fintype.card ι : ℝ) * (bernProb p A * (1 - bernProb p A)) := by
  refine ⟨bernProb_variance_le_deriv hp0 hp1 hA, ?_⟩
  rw [deriv_bernProb hA]
  exact sum_pivotal_le_card_variance hp0 hp1 hA

/-! ## Integrating: the reverse odds-ratio comparison -/

/-- The gap between `|ι|` times the log-odds of a single site and the log-odds of
the event.  The reverse Poincaré inequality says it is nondecreasing. -/
noncomputable def logitGapPow (A : Set (ι → Bool)) (N : ℕ) (p : ℝ) : ℝ :=
  (N : ℝ) * (Real.log p - Real.log (1 - p))
    - (Real.log (bernProb p A) - Real.log (1 - bernProb p A))

theorem hasDerivAt_logitGapPow {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (hne : A.Nonempty) (hnec : (Aᶜ : Set (ι → Bool)).Nonempty) (N : ℕ) {p : ℝ}
    (hp0 : 0 < p) (hp1 : p < 1) :
    HasDerivAt (logitGapPow A N)
      ((N : ℝ) * (1 / p + 1 / (1 - p))
        - ((∑ v : ι, bernProb p (pivotalSet A v)) / bernProb p A
            + (∑ v : ι, bernProb p (pivotalSet A v)) / (1 - bernProb p A))) p := by
  set D := ∑ v : ι, bernProb p (pivotalSet A v) with hD
  have hPpos : 0 < bernProb p A := bernProb_pos hne hp0 hp1
  have hPlt : bernProb p A < 1 := bernProb_lt_one hnec hp0 hp1
  have hP : HasDerivAt (fun t : ℝ => bernProb t A) D p := hasDerivAt_bernProb hA p
  have h1 : HasDerivAt (fun t : ℝ => Real.log (bernProb t A)) (D / bernProb p A) p :=
    hP.log (ne_of_gt hPpos)
  have hQ : HasDerivAt (fun t : ℝ => 1 - bernProb t A) (-D) p := by
    simpa using (hasDerivAt_const p (1 : ℝ)).sub hP
  have h2 : HasDerivAt (fun t : ℝ => Real.log (1 - bernProb t A))
      (-D / (1 - bernProb p A)) p := hQ.log (by linarith)
  have h3 : HasDerivAt (fun t : ℝ => Real.log t) (1 / p) p := by
    simpa [one_div] using Real.hasDerivAt_log (ne_of_gt hp0)
  have h4 : HasDerivAt (fun t : ℝ => Real.log (1 - t)) (-1 / (1 - p)) p := by
    have hlin : HasDerivAt (fun t : ℝ => 1 - t) (-1) p := by
      simpa using (hasDerivAt_const p (1 : ℝ)).sub (hasDerivAt_id p)
    exact hlin.log (by linarith)
  have hcomb := ((h3.sub h4).const_mul (N : ℝ)).sub (h1.sub h2)
  convert hcomb using 1
  field_simp
  ring

/-- **The reverse Poincaré inequality in logistic form.** -/
theorem deriv_logitGapPow_nonneg {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (hne : A.Nonempty) (hnec : (Aᶜ : Set (ι → Bool)).Nonempty) {p : ℝ}
    (hp0 : 0 < p) (hp1 : p < 1) :
    0 ≤ deriv (logitGapPow A (Fintype.card ι)) p := by
  set N := Fintype.card ι with hN
  set D := ∑ v : ι, bernProb p (pivotalSet A v) with hD
  have hPpos : 0 < bernProb p A := bernProb_pos hne hp0 hp1
  have hPlt : bernProb p A < 1 := bernProb_lt_one hnec hp0 hp1
  rw [(hasDerivAt_logitGapPow hA hne hnec N hp0 hp1).deriv]
  have hvar : p * (1 - p) * D ≤ (N : ℝ) * (bernProb p A * (1 - bernProb p A)) :=
    sum_pivotal_le_card_variance hp0.le hp1.le hA
  have hPQ : 0 < bernProb p A * (1 - bernProb p A) := mul_pos hPpos (by linarith)
  have hpq : 0 < p * (1 - p) := mul_pos hp0 (by linarith)
  have hP0 : bernProb p A ≠ 0 := ne_of_gt hPpos
  have hP1 : (1 : ℝ) - bernProb p A ≠ 0 := ne_of_gt (by linarith)
  have hp0' : p ≠ 0 := ne_of_gt hp0
  have hp1' : (1 : ℝ) - p ≠ 0 := ne_of_gt (by linarith)
  have hsum1 : D / bernProb p A + D / (1 - bernProb p A)
      = D / (bernProb p A * (1 - bernProb p A)) := by
    field_simp; ring
  have hsum2 : 1 / p + 1 / (1 - p) = 1 / (p * (1 - p)) := by
    field_simp; ring
  have hkey : D / (bernProb p A * (1 - bernProb p A)) ≤ (N : ℝ) * (1 / (p * (1 - p))) := by
    rw [mul_one_div, div_le_div_iff₀ hPQ hpq]
    nlinarith
  rw [hsum1, hsum2]
  linarith

/-- The `|ι|`-power logit gap is nondecreasing on `(0,1)`. -/
theorem monotoneOn_logitGapPow {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (hne : A.Nonempty) (hnec : (Aᶜ : Set (ι → Bool)).Nonempty) :
    MonotoneOn (logitGapPow A (Fintype.card ι)) (Set.Ioo (0 : ℝ) 1) := by
  have hdiff : ∀ p ∈ Set.Ioo (0 : ℝ) 1,
      DifferentiableAt ℝ (logitGapPow A (Fintype.card ι)) p := fun p hp =>
    (hasDerivAt_logitGapPow hA hne hnec (Fintype.card ι) hp.1 hp.2).differentiableAt
  refine monotoneOn_of_deriv_nonneg (convex_Ioo 0 1) ?_ ?_ ?_
  · exact fun p hp => (hdiff p hp).continuousAt.continuousWithinAt
  · rw [interior_Ioo]
    exact fun p hp => (hdiff p hp).differentiableWithinAt
  · rw [interior_Ioo]
    exact fun p hp => deriv_logitGapPow_nonneg hA hne hnec hp.1 hp.2

/-- **Reverse odds-ratio comparison.**  For a nondegenerate increasing event on
`|ι|` sites and `p ≤ q` in `(0,1)`, the odds of the event grow *at most* like the
`|ι|`-th power of the odds of a single site:

`odds(P q) / odds(P p) ≤ (odds(q) / odds(p)) ^ |ι|`.

Together with `odds_ratio_mono` this pins the growth of the odds of any
increasing event between the first and the `|ι|`-th power of the single-site
odds ratio. -/
theorem odds_ratio_le_pow {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (hne : A.Nonempty) (hnec : (Aᶜ : Set (ι → Bool)).Nonempty) {p q : ℝ}
    (hp0 : 0 < p) (hpq : p ≤ q) (hq1 : q < 1) :
    bernProb q A * (1 - bernProb p A) * (p * (1 - q)) ^ (Fintype.card ι) ≤
      bernProb p A * (1 - bernProb q A) * (q * (1 - p)) ^ (Fintype.card ι) := by
  set N := Fintype.card ι with hN
  have hp1 : p < 1 := lt_of_le_of_lt hpq hq1
  have hq0 : 0 < q := lt_of_lt_of_le hp0 hpq
  have hPp : 0 < bernProb p A := bernProb_pos hne hp0 hp1
  have hPq : 0 < bernProb q A := bernProb_pos hne hq0 hq1
  have hPp1 : bernProb p A < 1 := bernProb_lt_one hnec hp0 hp1
  have hPq1 : bernProb q A < 1 := bernProb_lt_one hnec hq0 hq1
  have hmono := monotoneOn_logitGapPow hA hne hnec ⟨hp0, hp1⟩ ⟨hq0, hq1⟩ hpq
  unfold logitGapPow at hmono
  have hPpne : bernProb p A ≠ 0 := ne_of_gt hPp
  have hPqne : bernProb q A ≠ 0 := ne_of_gt hPq
  have hPp1ne : (1 : ℝ) - bernProb p A ≠ 0 := ne_of_gt (by linarith)
  have hPq1ne : (1 : ℝ) - bernProb q A ≠ 0 := ne_of_gt (by linarith)
  have hpne : p ≠ 0 := ne_of_gt hp0
  have hqne : q ≠ 0 := ne_of_gt hq0
  have hp1ne : (1 : ℝ) - p ≠ 0 := ne_of_gt (by linarith)
  have hq1ne : (1 : ℝ) - q ≠ 0 := ne_of_gt (by linarith)
  have hposL : 0 < bernProb q A * (1 - bernProb p A) * (p * (1 - q)) ^ N :=
    mul_pos (mul_pos hPq (by linarith)) (pow_pos (mul_pos hp0 (by linarith)) N)
  have hposR : 0 < bernProb p A * (1 - bernProb q A) * (q * (1 - p)) ^ N :=
    mul_pos (mul_pos hPp (by linarith)) (pow_pos (mul_pos hq0 (by linarith)) N)
  refine (Real.log_le_log_iff hposL hposR).mp ?_
  have hlogL : Real.log (bernProb q A * (1 - bernProb p A) * (p * (1 - q)) ^ N)
      = Real.log (bernProb q A) + Real.log (1 - bernProb p A)
        + (N : ℝ) * (Real.log p + Real.log (1 - q)) := by
    rw [Real.log_mul (mul_ne_zero hPqne hPp1ne) (pow_ne_zero N (mul_ne_zero hpne hq1ne)),
      Real.log_mul hPqne hPp1ne, Real.log_pow, Real.log_mul hpne hq1ne]
  have hlogR : Real.log (bernProb p A * (1 - bernProb q A) * (q * (1 - p)) ^ N)
      = Real.log (bernProb p A) + Real.log (1 - bernProb q A)
        + (N : ℝ) * (Real.log q + Real.log (1 - p)) := by
    rw [Real.log_mul (mul_ne_zero hPpne hPq1ne) (pow_ne_zero N (mul_ne_zero hqne hp1ne)),
      Real.log_mul hPpne hPq1ne, Real.log_pow, Real.log_mul hqne hp1ne]
  rw [hlogL, hlogR]
  nlinarith [hmono]

/-! ## A lower bound on the width of the threshold window -/

/-- **No event on `|ι|` sites has a threshold sharper than `1/|ι|`.**  If an
increasing event has probability exactly `1/2` at density `p`, then at any
larger density `q < 1` its probability is at most

`R / (1 + R)` with `R = (q(1-p) / (p(1-q))) ^ |ι|`,

so the probability cannot exceed `1 - ε` until the single-site odds ratio has
grown by a factor `((1-ε)/ε)^(1/|ι|)`.  This is the exact converse of
`bernProb_ge_of_half`. -/
theorem bernProb_le_pow_of_half {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (hne : A.Nonempty) (hnec : (Aᶜ : Set (ι → Bool)).Nonempty) {p q : ℝ}
    (hp0 : 0 < p) (hpq : p ≤ q) (hq1 : q < 1) (hhalf : bernProb p A = 1 / 2) :
    bernProb q A ≤ (q * (1 - p)) ^ (Fintype.card ι) /
      ((q * (1 - p)) ^ (Fintype.card ι) + (p * (1 - q)) ^ (Fintype.card ι)) := by
  set N := Fintype.card ι with hN
  have hp1 : p < 1 := lt_of_le_of_lt hpq hq1
  have hq0 : 0 < q := lt_of_lt_of_le hp0 hpq
  have ha : 0 < (q * (1 - p)) ^ N := pow_pos (mul_pos hq0 (by linarith)) N
  have hb : 0 < (p * (1 - q)) ^ N := pow_pos (mul_pos hp0 (by linarith)) N
  have hden : 0 < (q * (1 - p)) ^ N + (p * (1 - q)) ^ N := by linarith
  have h := odds_ratio_le_pow hA hne hnec hp0 hpq hq1
  rw [hhalf] at h
  rw [le_div_iff₀ hden]
  nlinarith

/-- **Quantitative threshold-window width.**  Combining the two-sided odds-ratio
bounds: if `bernProb p A = 1/2` then for `p ≤ q < 1` the probability at `q` lies
between the single-site value and its `|ι|`-th power version.  In particular the
probability is bounded away from `1` unless `q(1-p)/(p(1-q))` is at least
exponentially large in `1/|ι|`. -/
theorem threshold_window_lower_bound {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (hne : A.Nonempty) (hnec : (Aᶜ : Set (ι → Bool)).Nonempty) {p q : ℝ}
    (hp0 : 0 < p) (hpq : p ≤ q) (hq1 : q < 1) (hhalf : bernProb p A = 1 / 2) :
    q * (1 - p) / (q * (1 - p) + p * (1 - q)) ≤ bernProb q A ∧
      bernProb q A ≤ (q * (1 - p)) ^ (Fintype.card ι) /
        ((q * (1 - p)) ^ (Fintype.card ι) + (p * (1 - q)) ^ (Fintype.card ι)) :=
  ⟨bernProb_ge_of_half hA hne hnec hp0 hpq hq1 hhalf,
    bernProb_le_pow_of_half hA hne hnec hp0 hpq hq1 hhalf⟩

/-- **The grid instance of the reverse Poincaré inequality.**  Each site of the
`n × n` grid has crossing-influence at most the crossing variance divided by
`p(1-p)`. -/
theorem crossing_pivotal_le_variance (n : ℕ) (hn : 0 < n) {p : ℝ} (hp0 : 0 ≤ p)
    (hp1 : p ≤ 1) (v : Fin n × Fin n) :
    p * (1 - p) * bernProb p (pivotalSet (crossingEvent n hn) v) ≤
      bernProb p (crossingEvent n hn) * (1 - bernProb p (crossingEvent n hn)) :=
  bernProb_pivotal_le_variance hp0 hp1 (crossingEvent_isIncreasing n hn) v

end BernoulliThresholdCoupling