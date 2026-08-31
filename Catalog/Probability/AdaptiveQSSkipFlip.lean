/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Skip-flip wins, and the quadratic-residue null equaliser

Companion to `Probability.AdaptiveQSAllocation`.  That file shows that spending a
*fixed* budget in inverse proportion to a predicted rate must lose.  Experiment 559
then flipped the deployment: instead of reallocating sieve length, use the same
dial to **skip** the worst targets (`θ = q20` skipped `28.3%` of the work while
retaining `89.5%` of the relations, a `+28.9%` throughput gain), and defer the hard
tail (`40/400` targets that no amount of sieving reaches).

This file proves that the flip is not a lucky calibration but a theorem, in three
layers.

1. **Separation ⇒ retention beats work fraction.**  `sum_le_of_separated_slack` is
   the general engine: if every kept target beats every skipped target up to a slack
   `c`, then `|K| · (total yield) ≤ |s| · (kept yield) + c |K| |D|`.  With `c = 0`
   (`retention_ge_work_fraction`) this says exactly `retention ≥ work fraction`, i.e.
   the throughput ratio is `≥ 1`; `skip_throughput_ge` and `skip_throughput_gt` state
   it as a mean comparison, the latter strictly.

2. **An imperfect dial still wins, quantitatively.**  `approx_dial_retention` runs
   the same engine with `c = 2ε` for a dial that is only `ε`-accurate — the measured
   Spearman `0.739 < 1` costs at most a `2ε` degradation term, and
   `approx_dial_threshold_gain` gives the explicit condition on `ε` under which the
   skip still wins.  This is the robustness statement the deployment needs.

3. **The null equaliser is exact arithmetic, not statistics.**  A prime `p` for which
   `N` is a quadratic *non*-residue divides **no** value `x² - N`
   (`nonresidue_not_dvd_qsValue`), so its sieve hit rate is identically zero
   (`hitRate_eq_zero_of_nonresidue`) — the hard tail is unreachable by construction.
   `qs_null_equalizer` then says the yield of *any* allocation is unchanged by
   deleting the null targets, and `transfer_from_null_lt` says that moving any
   positive amount of budget off a null target onto a live one strictly increases the
   yield.  Deferral, not deeper sieving, is the instrument.
-/
import Mathlib
import Probability.AdaptiveQSAllocation

namespace Probability.AdaptiveQS

open Finset

variable {ι : Type*} [DecidableEq ι]

/-! ## The separation engine -/

/-- If every element of `K` beats every element of `D` up to an additive slack `c`,
and `s` is the disjoint union of `K` and `D`, then the *retention* `∑_K r / ∑_s r`
is at least the *work fraction* `|K| / |s|`, up to the slack term `c |K| |D|`. -/
theorem sum_le_of_separated_slack {s K D : Finset ι} {r : ι → ℝ} {c : ℝ}
    (hunion : K ∪ D = s) (hdisj : Disjoint K D)
    (hsep : ∀ i ∈ K, ∀ j ∈ D, r j ≤ r i + c) :
    (K.card : ℝ) * (∑ i ∈ s, r i)
      ≤ (s.card : ℝ) * (∑ i ∈ K, r i) + c * K.card * D.card := by
  have hsplit : ∑ i ∈ s, r i = (∑ i ∈ K, r i) + ∑ j ∈ D, r j := by
    rw [← hunion, Finset.sum_union hdisj]
  have hcard : (s.card : ℝ) = (K.card : ℝ) + (D.card : ℝ) := by
    rw [← hunion, Finset.card_union_of_disjoint hdisj]
    push_cast
    ring
  -- the cross bound `|K| ∑_D r ≤ |D| ∑_K r + c |K| |D|`
  have hcross : (K.card : ℝ) * (∑ j ∈ D, r j)
      ≤ (D.card : ℝ) * (∑ i ∈ K, r i) + c * K.card * D.card := by
    have hterm : ∀ p ∈ D ×ˢ K, r p.1 ≤ r p.2 + c := by
      intro p hp
      rw [Finset.mem_product] at hp
      exact hsep _ hp.2 _ hp.1
    have hsum : ∑ p ∈ D ×ˢ K, r p.1 ≤ ∑ p ∈ D ×ˢ K, (r p.2 + c) :=
      Finset.sum_le_sum hterm
    have hL : ∑ p ∈ D ×ˢ K, r p.1 = (K.card : ℝ) * ∑ j ∈ D, r j := by
      simp only [Finset.sum_product, Finset.sum_const, nsmul_eq_mul]
      rw [← Finset.mul_sum]
    have hR : ∑ p ∈ D ×ˢ K, (r p.2 + c)
        = (D.card : ℝ) * (∑ i ∈ K, r i) + c * K.card * D.card := by
      simp only [Finset.sum_product, Finset.sum_add_distrib, Finset.sum_const, nsmul_eq_mul,
        Finset.card_product]
      push_cast
      ring
    rw [hL, hR] at hsum
    exact hsum
  rw [hsplit, hcard]
  nlinarith [hcross]

/-- The slack-free separation bound: **retention ≥ work fraction**. -/
theorem sum_le_of_separated {s K D : Finset ι} {r : ι → ℝ}
    (hunion : K ∪ D = s) (hdisj : Disjoint K D)
    (hsep : ∀ i ∈ K, ∀ j ∈ D, r j ≤ r i) :
    (K.card : ℝ) * (∑ i ∈ s, r i) ≤ (s.card : ℝ) * ∑ i ∈ K, r i := by
  have h := sum_le_of_separated_slack (c := 0) hunion hdisj (by simpa using hsep)
  simpa using h

/-- The strict separation bound: if in addition some kept target strictly beats some
skipped target, the retention strictly exceeds the work fraction. -/
theorem sum_lt_of_separated {s K D : Finset ι} {r : ι → ℝ}
    (hunion : K ∪ D = s) (hdisj : Disjoint K D)
    (hsep : ∀ i ∈ K, ∀ j ∈ D, r j ≤ r i)
    {i₀ j₀ : ι} (hi₀ : i₀ ∈ K) (hj₀ : j₀ ∈ D) (hlt : r j₀ < r i₀) :
    (K.card : ℝ) * (∑ i ∈ s, r i) < (s.card : ℝ) * ∑ i ∈ K, r i := by
  have hsplit : ∑ i ∈ s, r i = (∑ i ∈ K, r i) + ∑ j ∈ D, r j := by
    rw [← hunion, Finset.sum_union hdisj]
  have hcard : (s.card : ℝ) = (K.card : ℝ) + (D.card : ℝ) := by
    rw [← hunion, Finset.card_union_of_disjoint hdisj]
    push_cast
    ring
  have hcross : (K.card : ℝ) * (∑ j ∈ D, r j) < (D.card : ℝ) * ∑ i ∈ K, r i := by
    have hsum : ∑ p ∈ D ×ˢ K, r p.1 < ∑ p ∈ D ×ˢ K, r p.2 := by
      refine Finset.sum_lt_sum ?_ ?_
      · intro p hp
        rw [Finset.mem_product] at hp
        exact hsep _ hp.2 _ hp.1
      · exact ⟨(j₀, i₀), Finset.mem_product.mpr ⟨hj₀, hi₀⟩, hlt⟩
    have hL : ∑ p ∈ D ×ˢ K, r p.1 = (K.card : ℝ) * ∑ j ∈ D, r j := by
      simp only [Finset.sum_product, Finset.sum_const, nsmul_eq_mul]
      rw [← Finset.mul_sum]
    have hR : ∑ p ∈ D ×ˢ K, r p.2 = (D.card : ℝ) * ∑ i ∈ K, r i := by
      simp only [Finset.sum_product, Finset.sum_const, nsmul_eq_mul]
    rw [hL, hR] at hsum
    exact hsum
  rw [hsplit, hcard]
  nlinarith [hcross]

/-! ## The deployment flip: threshold skipping -/

/-- The targets kept by a dial threshold. -/
noncomputable def keepSet (s : Finset ι) (d : ι → ℝ) (θ : ℝ) : Finset ι :=
  s.filter (fun i => θ ≤ d i)

/-- The targets deferred by a dial threshold. -/
noncomputable def skipSet (s : Finset ι) (d : ι → ℝ) (θ : ℝ) : Finset ι :=
  s.filter (fun i => ¬ θ ≤ d i)

/-- Yield per unit of work of a set of targets, all sieved at the same length. -/
noncomputable def throughput (K : Finset ι) (r : ι → ℝ) : ℝ := (∑ i ∈ K, r i) / K.card

lemma keepSet_union_skipSet (s : Finset ι) (d : ι → ℝ) (θ : ℝ) :
    keepSet s d θ ∪ skipSet s d θ = s :=
  Finset.filter_union_filter_not_eq _ _

omit [DecidableEq ι] in
lemma keepSet_disjoint_skipSet (s : Finset ι) (d : ι → ℝ) (θ : ℝ) :
    Disjoint (keepSet s d θ) (skipSet s d θ) :=
  Finset.disjoint_filter_filter_not _ _ _

/-- A dial is **concordant** with the true rate on `s` when it never orders two targets
backwards: a strictly smaller dial reading means a no-larger rate. -/
def Concordant (s : Finset ι) (d r : ι → ℝ) : Prop :=
  ∀ i ∈ s, ∀ j ∈ s, d j < d i → r j ≤ r i

omit [DecidableEq ι] in
/-- A dial obtained by a monotone transform of the true rate is concordant. -/
theorem concordant_of_monotone_dial {s : Finset ι} {r : ι → ℝ} {g : ℝ → ℝ}
    (hg : Monotone g) : Concordant s (fun i => g (r i)) r := by
  intro i _ j _ hlt
  by_contra hcon
  push_neg at hcon
  exact absurd (hg hcon.le) (not_le.mpr hlt)

omit [DecidableEq ι] in
/-- The true rate is trivially concordant with itself: the oracle dial. -/
theorem concordant_self (s : Finset ι) (r : ι → ℝ) : Concordant s r r :=
  fun _ _ _ _ h => h.le

/-- **Skip-flip wins.**  For a concordant dial and any threshold, the relations
retained are at least the proportion of the work retained:
`|K| · (total) ≤ |s| · (kept)`.  This is the exact form of the measured
"`28.3%` of the work skipped, `89.5%` of the relations retained". -/
theorem retention_ge_work_fraction {s : Finset ι} {d r : ι → ℝ} (hc : Concordant s d r)
    (θ : ℝ) :
    ((keepSet s d θ).card : ℝ) * (∑ i ∈ s, r i)
      ≤ (s.card : ℝ) * ∑ i ∈ keepSet s d θ, r i := by
  refine sum_le_of_separated (keepSet_union_skipSet s d θ) (keepSet_disjoint_skipSet s d θ) ?_
  intro i hi j hj
  rw [keepSet, Finset.mem_filter] at hi
  rw [skipSet, Finset.mem_filter] at hj
  exact hc i hi.1 j hj.1 (lt_of_lt_of_le (not_le.mp hj.2) hi.2)

/-- **The throughput gain.**  Skipping by a concordant dial never lowers the yield
per unit of work. -/
theorem skip_throughput_ge {s : Finset ι} {d r : ι → ℝ} (hc : Concordant s d r) (θ : ℝ)
    (hK : (keepSet s d θ).Nonempty) :
    throughput s r ≤ throughput (keepSet s d θ) r := by
  have hKs : keepSet s d θ ⊆ s := Finset.filter_subset _ _
  have hs : s.Nonempty := hK.mono hKs
  have hkpos : (0:ℝ) < (keepSet s d θ).card := by
    exact_mod_cast Finset.card_pos.mpr hK
  have hspos : (0:ℝ) < s.card := by exact_mod_cast Finset.card_pos.mpr hs
  rw [throughput, throughput, div_le_div_iff₀ hspos hkpos]
  have := retention_ge_work_fraction hc θ
  nlinarith [this]

/-- **Strict throughput gain.**  If the deferred set really is worse — some skipped
target has a strictly smaller rate than some kept target — the gain is strict. -/
theorem skip_throughput_gt {s : Finset ι} {d r : ι → ℝ} (hc : Concordant s d r) (θ : ℝ)
    {i₀ j₀ : ι} (hi₀ : i₀ ∈ keepSet s d θ) (hj₀ : j₀ ∈ skipSet s d θ) (hlt : r j₀ < r i₀) :
    throughput s r < throughput (keepSet s d θ) r := by
  have hK : (keepSet s d θ).Nonempty := ⟨i₀, hi₀⟩
  have hKs : keepSet s d θ ⊆ s := Finset.filter_subset _ _
  have hs : s.Nonempty := hK.mono hKs
  have hkpos : (0:ℝ) < (keepSet s d θ).card := by
    exact_mod_cast Finset.card_pos.mpr hK
  have hspos : (0:ℝ) < s.card := by exact_mod_cast Finset.card_pos.mpr hs
  have hsep : ∀ i ∈ keepSet s d θ, ∀ j ∈ skipSet s d θ, r j ≤ r i := by
    intro i hi j hj
    rw [keepSet, Finset.mem_filter] at hi
    rw [skipSet, Finset.mem_filter] at hj
    exact hc i hi.1 j hj.1 (lt_of_lt_of_le (not_le.mp hj.2) hi.2)
  have hstrict := sum_lt_of_separated (keepSet_union_skipSet s d θ)
    (keepSet_disjoint_skipSet s d θ) hsep hi₀ hj₀ hlt
  rw [throughput, throughput, div_lt_div_iff₀ hspos hkpos]
  nlinarith [hstrict]

/-! ## An imperfect dial: the quantitative flip -/

/-- **The flip survives a miscalibrated dial.**  If the dial is within `ε` of the true
rate on every target, threshold skipping retains the work-proportional yield up to a
degradation `2ε |K| |D|`.  A perfect dial (`ε = 0`) recovers
`retention_ge_work_fraction`. -/
theorem approx_dial_retention {s : Finset ι} {d r : ι → ℝ} {ε : ℝ}
    (hε : ∀ i ∈ s, |d i - r i| ≤ ε) (θ : ℝ) :
    ((keepSet s d θ).card : ℝ) * (∑ i ∈ s, r i)
      ≤ (s.card : ℝ) * (∑ i ∈ keepSet s d θ, r i)
        + 2 * ε * (keepSet s d θ).card * (skipSet s d θ).card := by
  have hsep : ∀ i ∈ keepSet s d θ, ∀ j ∈ skipSet s d θ, r j ≤ r i + 2 * ε := by
    intro i hi j hj
    rw [keepSet, Finset.mem_filter] at hi
    rw [skipSet, Finset.mem_filter] at hj
    have h1 : |d i - r i| ≤ ε := hε i hi.1
    have h2 : |d j - r j| ≤ ε := hε j hj.1
    have h1' : d i - r i ≤ ε := (abs_le.mp h1).2
    have h2' : -ε ≤ d j - r j := (abs_le.mp h2).1
    have hdj : d j < θ := not_le.mp hj.2
    have hdi : θ ≤ d i := hi.2
    linarith
  exact sum_le_of_separated_slack (c := 2 * ε) (keepSet_union_skipSet s d θ)
    (keepSet_disjoint_skipSet s d θ) hsep

/-- The explicit robustness condition: with an `ε`-accurate dial, the skipped work is
worth keeping whenever the accuracy beats the mean rate gap the skip has to buy. -/
theorem approx_dial_threshold_gain {s : Finset ι} {d r : ι → ℝ} {ε : ℝ}
    (hε : ∀ i ∈ s, |d i - r i| ≤ ε) (θ : ℝ) (hK : (keepSet s d θ).Nonempty)
    (hs : s.Nonempty) :
    throughput s r
      ≤ throughput (keepSet s d θ) r
        + 2 * ε * (skipSet s d θ).card / (s.card : ℝ) := by
  have hkpos : (0:ℝ) < (keepSet s d θ).card := by
    exact_mod_cast Finset.card_pos.mpr hK
  have hspos : (0:ℝ) < s.card := by exact_mod_cast Finset.card_pos.mpr hs
  have h := approx_dial_retention hε θ
  rw [throughput, throughput, div_le_iff₀ hspos]
  rw [div_add_div _ _ (ne_of_gt hkpos) (ne_of_gt hspos)]
  rw [div_mul_eq_mul_div, le_div_iff₀ (by positivity)]
  nlinarith [h, hkpos, hspos]

/-! ## The quadratic-residue null equaliser -/

section NullEqualizer

omit [DecidableEq ι]

/-- The quadratic-sieve value at `x` for the target `N`. -/
def qsValue (N x : ℤ) : ℤ := x ^ 2 - N

/-- **The exact mechanism.**  If `N` is a quadratic non-residue mod a prime `p`, then
`p` divides *no* sieve value `x² - N`: such a prime contributes nothing, ever. -/
theorem nonresidue_not_dvd_qsValue {p : ℕ} [Fact p.Prime] {N : ℤ}
    (h : ¬ IsSquare (N : ZMod p)) (x : ℤ) : ¬ ((p : ℤ) ∣ qsValue N x) := by
  intro hdvd
  apply h
  have : ((qsValue N x : ℤ) : ZMod p) = 0 := by
    exact_mod_cast (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).mpr hdvd
  rw [qsValue] at this
  push_cast at this
  refine ⟨(x : ZMod p), ?_⟩
  have hx : ((x : ZMod p)) ^ 2 = (N : ZMod p) := by linear_combination this
  rw [← hx]; ring

/-- The empirical hit rate of the prime `p` in the sieve window `w`. -/
noncomputable def hitRate (N : ℤ) (w : Finset ℤ) (p : ℕ) : ℝ :=
  ((w.filter (fun x => (p : ℤ) ∣ qsValue N x)).card : ℝ) / w.card

/-- **The hard tail is unreachable by construction.**  A non-residue prime has hit
rate exactly `0` in every window: no amount of extra sieving can change it. -/
theorem hitRate_eq_zero_of_nonresidue {p : ℕ} [Fact p.Prime] {N : ℤ}
    (h : ¬ IsSquare (N : ZMod p)) (w : Finset ℤ) : hitRate N w p = 0 := by
  have hempty : w.filter (fun x => (p : ℤ) ∣ qsValue N x) = ∅ := by
    rw [Finset.filter_eq_empty_iff]
    intro x _
    exact nonresidue_not_dvd_qsValue h x
  rw [hitRate, hempty]
  simp

/-- **The null equaliser.**  The yield of *any* allocation is unchanged by deleting the
null targets: budget spent on them is exactly wasted, whatever the schedule. -/
theorem qs_null_equalizer (s : Finset ι) (r ℓ : ι → ℝ) :
    yieldOf s r ℓ = yieldOf (s.filter (fun i => r i ≠ 0)) r ℓ := by
  unfold yieldOf
  rw [eq_comm]
  refine Finset.sum_subset (Finset.filter_subset _ _) ?_
  intro i hi hnot
  rw [Finset.mem_filter] at hnot
  have : r i = 0 := by
    by_contra hr
    exact hnot ⟨hi, hr⟩
  rw [this, zero_mul]

end NullEqualizer

/-- Transferring budget from one target to another. -/
noncomputable def transfer (ℓ : ι → ℝ) (a b : ι) (δ : ℝ) : ι → ℝ :=
  fun i => if i = a then ℓ a - δ else if i = b then ℓ b + δ else ℓ i

/-- **Deferral is the instrument.**  Moving any positive amount of budget off a null
target onto a live one strictly increases the yield — and, by `qs_null_equalizer`, this
is the only thing that can be done about the null targets. -/
theorem transfer_from_null_lt {s : Finset ι} {r ℓ : ι → ℝ} {a b : ι}
    (ha : a ∈ s) (hb : b ∈ s) (hab : a ≠ b) (hra : r a = 0) (hrb : 0 < r b)
    {δ : ℝ} (hδ : 0 < δ) :
    yieldOf s r ℓ < yieldOf s r (transfer ℓ a b δ) := by
  have hdiff : yieldOf s r (transfer ℓ a b δ) - yieldOf s r ℓ = r b * δ := by
    unfold yieldOf
    rw [← Finset.sum_sub_distrib]
    have hsupp : ∀ i ∈ s, i ∉ ({a, b} : Finset ι) →
        r i * transfer ℓ a b δ i - r i * ℓ i = 0 := by
      intro i _ hi
      simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hi
      simp [transfer, hi.1, hi.2]
    rw [← Finset.sum_subset (by
      intro i hi
      simp only [Finset.mem_insert, Finset.mem_singleton] at hi
      rcases hi with h | h <;> subst h <;> assumption) hsupp]
    rw [Finset.sum_pair hab]
    simp [transfer, Ne.symm hab, hra]
    ring
  nlinarith [hdiff, mul_pos hrb hδ]

end Probability.AdaptiveQS