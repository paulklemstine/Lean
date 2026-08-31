/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The inversion-mass refinement of the discordance budget

`AdaptiveQSDiscordance.lean` proved a *linear* budget for an arbitrary dial: the yield
retained by a threshold skip falls short of the work-proportional amount by at most
`M · |Disc|`, where `M` is the maximal rate and `Disc` the dial's inversion set.  That
bound charges the global maximum `M` to every inversion, so it is tight only when every
inversion pits a maximal target against a null one — which is exactly the situation the
measured run (`89.5%` retention at `71.7%` of the work) is *not* in.

This file closes the corresponding open direction ("Inversion-Mass Refinement of the
Discordance Budget") by charging each inversion its *actual* rate gap:

* `sum_le_of_positive_part_penalty` — the sharpened separation engine.  No boundedness and
  no nonnegativity hypotheses at all: for any splitting `s = K ⊔ D`,
  `|K| · Σ_s r ≤ |s| · Σ_K r + Σ_{(j,i) ∈ D×K} (r j − r i)⁺`.
* `inversionMass` — the total rate gap carried by the dial's inversions.
* `retention_of_inversion_mass`, `throughput_le_of_inversion_mass` — the refined budget in
  retention and in throughput form.
* `inversionMass_le_max_mul_card` — the refinement dominates: the inversion mass is at most
  `M · |Disc|`, so the new bound is never weaker than the old one, and
  `retention_of_discordance_of_inversion_mass` re-derives the old bound from the new one.
* `inversionMass_le_gap_mul_card` — a scale-free form: if every inversion has gap at most
  `g`, the whole penalty is at most `g · |Disc|`.
* `inversionMass_eq_zero_iff_concordant` — the penalty vanishes exactly for concordant
  dials, so the refined bound is an equality-preserving strengthening.
* `retention_deficit_eq`, `retention_deficit_eq_mass_difference` — the *exact* two-sided
  decomposition behind the budget: the retention deficit equals the inversion mass the
  threshold pays minus the concordance mass it earns, so the one-sided bound is tight
  precisely when the dial is never right about a deferred/retained pair.
* `retention_of_inversion_mass_sharp` — the resulting sharpened budget.
* Lab note `labnote_inversion_mass_strictly_better`: an explicit three-target dial with one
  inversion, where the refined penalty is `1` and the old penalty is `10`.
-/
import Mathlib
import Probability.AdaptiveQSAllocation
import Probability.AdaptiveQSSkipFlip
import Probability.AdaptiveQSDiscordance

namespace Probability.AdaptiveQS

open Finset

variable {ι : Type*} [DecidableEq ι]

/-! ## The sharpened separation engine -/

/-- **Separation with a pointwise penalty.**  For any splitting of the targets into a
retained set `K` and a deferred set `D`, the retention deficit is bounded by the sum of the
positive parts of the rate gaps over the deferred × retained pairs.  Unlike
`sum_le_of_bounded_exceptions` this needs no bound on the rates and no sign hypothesis:
it is an identity plus a pointwise `x ≤ x⁺`. -/
theorem sum_le_of_positive_part_penalty {s K D : Finset ι} {r : ι → ℝ}
    (hunion : K ∪ D = s) (hdisj : Disjoint K D) :
    (K.card : ℝ) * (∑ i ∈ s, r i)
      ≤ (s.card : ℝ) * (∑ i ∈ K, r i) + ∑ p ∈ D ×ˢ K, max (r p.1 - r p.2) 0 := by
  have hsplit : ∑ i ∈ s, r i = (∑ i ∈ K, r i) + ∑ j ∈ D, r j := by
    rw [← hunion, Finset.sum_union hdisj]
  have hcard : (s.card : ℝ) = (K.card : ℝ) + (D.card : ℝ) := by
    rw [← hunion, Finset.card_union_of_disjoint hdisj]
    push_cast
    ring
  have hL : ∑ p ∈ D ×ˢ K, (r p.1 - r p.2)
      = (K.card : ℝ) * (∑ j ∈ D, r j) - (D.card : ℝ) * ∑ i ∈ K, r i := by
    simp only [Finset.sum_product, Finset.sum_sub_distrib, Finset.sum_const, nsmul_eq_mul]
    rw [← Finset.mul_sum]
  have hsum : ∑ p ∈ D ×ˢ K, (r p.1 - r p.2) ≤ ∑ p ∈ D ×ˢ K, max (r p.1 - r p.2) 0 :=
    Finset.sum_le_sum fun p _ => le_max_left _ _
  rw [hL] at hsum
  rw [hsplit, hcard]
  nlinarith [hsum]

/-! ## The inversion mass -/

/-- The **inversion mass** of a dial `d` against the true rate `r`: the total rate gap
carried by the dial's ranking inversions.  Every summand is positive by construction, and
the quantity is homogeneous of degree one in `r` — unlike the count `|Disc|`, it is scale
free relative to the yields it bounds. -/
noncomputable def inversionMass (s : Finset ι) (d r : ι → ℝ) : ℝ :=
  ∑ p ∈ discordantPairs s d r, (r p.1 - r p.2)

omit [DecidableEq ι] in
/-- Each inversion contributes a positive gap, so the mass is nonnegative. -/
theorem inversionMass_nonneg (s : Finset ι) (d r : ι → ℝ) : 0 ≤ inversionMass s d r := by
  refine Finset.sum_nonneg fun p hp => ?_
  rw [discordantPairs, Finset.mem_filter] at hp
  linarith [hp.2.2]

omit [DecidableEq ι] in
/-- A concordant dial has zero inversion mass, and conversely a dial with zero mass has no
inversions at all: the refinement degenerates exactly where the exact theorem applies. -/
theorem inversionMass_eq_zero_iff_concordant (s : Finset ι) (d r : ι → ℝ) :
    inversionMass s d r = 0 ↔ discordantPairs s d r = ∅ := by
  constructor
  · intro h
    rw [Finset.eq_empty_iff_forall_notMem]
    intro p hp
    have hpos : 0 < r p.1 - r p.2 := by
      rw [discordantPairs, Finset.mem_filter] at hp
      linarith [hp.2.2]
    have hle : r p.1 - r p.2 ≤ inversionMass s d r := by
      refine Finset.single_le_sum (f := fun q => r q.1 - r q.2) (fun q hq => ?_) hp
      rw [discordantPairs, Finset.mem_filter] at hq
      linarith [hq.2.2]
    rw [h] at hle
    linarith
  · intro h
    rw [inversionMass, h, Finset.sum_empty]

/-- The part of the inversion mass that a given threshold actually pays: the positive rate
gaps over the deferred × retained pairs. -/
noncomputable def keptInversionMass (s : Finset ι) (d r : ι → ℝ) (θ : ℝ) : ℝ :=
  ∑ p ∈ skipSet s d θ ×ˢ keepSet s d θ, max (r p.1 - r p.2) 0

/-- The opposite ledger: the total rate gap on the deferred × retained pairs that the dial
orders *correctly*. -/
noncomputable def keptConcordanceMass (s : Finset ι) (d r : ι → ℝ) (θ : ℝ) : ℝ :=
  ∑ p ∈ skipSet s d θ ×ˢ keepSet s d θ, max (r p.2 - r p.1) 0

/-- Only the dial's inversions can contribute to what a threshold pays, so the paid mass is
at most the total inversion mass. -/
theorem keptInversionMass_le_inversionMass {s : Finset ι} {d r : ι → ℝ} (θ : ℝ) :
    keptInversionMass s d r θ ≤ inversionMass s d r := by
  set K := keepSet s d θ with hK
  set D := skipSet s d θ with hD
  have hstep : ∀ p ∈ D ×ˢ K,
      max (r p.1 - r p.2) 0 = if p ∈ discordantPairs s d r then r p.1 - r p.2 else 0 := by
    intro p hp
    rw [Finset.mem_product] at hp
    obtain ⟨hp1, hp2⟩ := hp
    rw [hD, skipSet, Finset.mem_filter] at hp1
    rw [hK, keepSet, Finset.mem_filter] at hp2
    have hd : d p.1 < d p.2 := lt_of_lt_of_le (not_le.mp hp1.2) hp2.2
    by_cases hlt : r p.2 < r p.1
    · have hmem : p ∈ discordantPairs s d r :=
        Finset.mem_filter.mpr ⟨Finset.mem_product.mpr ⟨hp1.1, hp2.1⟩, ⟨hd, hlt⟩⟩
      rw [if_pos hmem, max_eq_left (by linarith)]
    · have hmem : p ∉ discordantPairs s d r := by
        intro hmem
        rw [discordantPairs, Finset.mem_filter] at hmem
        exact hlt hmem.2.2
      rw [if_neg hmem, max_eq_right (by linarith [not_lt.mp hlt])]
  calc keptInversionMass s d r θ
      = ∑ p ∈ D ×ˢ K, if p ∈ discordantPairs s d r then r p.1 - r p.2 else 0 :=
        Finset.sum_congr rfl hstep
    _ = ∑ p ∈ (D ×ˢ K).filter (fun p => p ∈ discordantPairs s d r), (r p.1 - r p.2) := by
        rw [Finset.sum_filter]
    _ ≤ inversionMass s d r := by
        refine Finset.sum_le_sum_of_subset_of_nonneg ?_ ?_
        · intro p hp
          exact (Finset.mem_filter.mp hp).2
        · intro p hp _
          rw [discordantPairs, Finset.mem_filter] at hp
          linarith [hp.2.2]

/-- **The refined discordance budget.**  The retention deficit of a threshold skip is
bounded by the dial's inversion *mass*, with no reference to the maximal rate. -/
theorem retention_of_inversion_mass {s : Finset ι} {d r : ι → ℝ} (θ : ℝ) :
    ((keepSet s d θ).card : ℝ) * (∑ i ∈ s, r i)
      ≤ (s.card : ℝ) * (∑ i ∈ keepSet s d θ, r i) + inversionMass s d r := by
  have hengine := sum_le_of_positive_part_penalty (r := r)
    (keepSet_union_skipSet s d θ) (keepSet_disjoint_skipSet s d θ)
  have hpen := keptInversionMass_le_inversionMass (s := s) (d := d) (r := r) θ
  rw [keptInversionMass] at hpen
  linarith

/-! ## The exact two-sided decomposition

The engine above is an inequality only because it discards the pairs the dial gets right.
Keeping them gives an *identity*, and hence a characterisation of when the budget is
tight. -/

/-- **The retention deficit is exactly a signed pair sum.**  For any splitting of the
targets into a retained and a deferred part, the deficit equals the total signed rate gap
over deferred × retained pairs. -/
theorem retention_deficit_eq {s K D : Finset ι} {r : ι → ℝ}
    (hunion : K ∪ D = s) (hdisj : Disjoint K D) :
    (K.card : ℝ) * (∑ i ∈ s, r i) - (s.card : ℝ) * (∑ i ∈ K, r i)
      = ∑ p ∈ D ×ˢ K, (r p.1 - r p.2) := by
  have hsplit : ∑ i ∈ s, r i = (∑ i ∈ K, r i) + ∑ j ∈ D, r j := by
    rw [← hunion, Finset.sum_union hdisj]
  have hcard : (s.card : ℝ) = (K.card : ℝ) + (D.card : ℝ) := by
    rw [← hunion, Finset.card_union_of_disjoint hdisj]
    push_cast
    ring
  have hL : ∑ p ∈ D ×ˢ K, (r p.1 - r p.2)
      = (K.card : ℝ) * (∑ j ∈ D, r j) - (D.card : ℝ) * ∑ i ∈ K, r i := by
    simp only [Finset.sum_product, Finset.sum_sub_distrib, Finset.sum_const, nsmul_eq_mul]
    rw [← Finset.mul_sum]
  rw [hL, hsplit, hcard]
  ring

/-- **Exactness of the inversion budget.**  The retention deficit of a threshold skip is
*exactly* the mass of the inversions it pays for minus the mass of the pairs the dial gets
right.  The inequality `retention_of_inversion_mass` is therefore tight precisely when the
concordance mass vanishes, i.e. when the dial is never right about a deferred/retained
pair — which is the only way a threshold can lose the full inversion mass. -/
theorem retention_deficit_eq_mass_difference {s : Finset ι} {d r : ι → ℝ} (θ : ℝ) :
    ((keepSet s d θ).card : ℝ) * (∑ i ∈ s, r i)
        - (s.card : ℝ) * (∑ i ∈ keepSet s d θ, r i)
      = keptInversionMass s d r θ - keptConcordanceMass s d r θ := by
  have hid : ∀ x : ℝ, max x 0 - max (-x) 0 = x := by
    intro x
    rcases le_total 0 x with h | h
    · rw [max_eq_left h, max_eq_right (by linarith)]
      ring
    · rw [max_eq_right h, max_eq_left (by linarith)]
      ring
  rw [retention_deficit_eq (keepSet_union_skipSet s d θ) (keepSet_disjoint_skipSet s d θ),
    keptInversionMass, keptConcordanceMass, ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun p _ => ?_
  have := hid (r p.1 - r p.2)
  rw [show -(r p.1 - r p.2) = r p.2 - r p.1 by ring] at this
  exact this.symm

/-- **The sharpened budget.**  Subtracting the concordance mass strengthens the refined
bound, and the strengthening is real whenever the dial orders some deferred/retained pair
correctly. -/
theorem retention_of_inversion_mass_sharp {s : Finset ι} {d r : ι → ℝ} (θ : ℝ) :
    ((keepSet s d θ).card : ℝ) * (∑ i ∈ s, r i)
      ≤ (s.card : ℝ) * (∑ i ∈ keepSet s d θ, r i)
        + (inversionMass s d r - keptConcordanceMass s d r θ) := by
  have hdec := retention_deficit_eq_mass_difference (s := s) (d := d) (r := r) θ
  have hpen := keptInversionMass_le_inversionMass (s := s) (d := d) (r := r) θ
  linarith

omit [DecidableEq ι] in
/-- **The refinement dominates the linear budget.**  With all rates in `[0, M]`, the
inversion mass is at most `M · |Disc|`, so the refined bound is never weaker than the
`M · |Disc|` bound of `AdaptiveQSDiscordance`. -/
theorem inversionMass_le_max_mul_card {s : Finset ι} {d r : ι → ℝ} {M : ℝ}
    (hnonneg : ∀ i ∈ s, 0 ≤ r i) (hle : ∀ i ∈ s, r i ≤ M) :
    inversionMass s d r ≤ M * (discordantPairs s d r).card := by
  have hterm : ∀ p ∈ discordantPairs s d r, r p.1 - r p.2 ≤ M := by
    intro p hp
    rw [discordantPairs, Finset.mem_filter, Finset.mem_product] at hp
    have h1 : r p.1 ≤ M := hle _ hp.1.1
    have h2 : 0 ≤ r p.2 := hnonneg _ hp.1.2
    linarith
  calc inversionMass s d r ≤ ∑ _p ∈ discordantPairs s d r, M := Finset.sum_le_sum hterm
    _ = M * (discordantPairs s d r).card := by rw [Finset.sum_const, nsmul_eq_mul]; ring

/-- Consistency check: the old linear budget is a consequence of the refined one. -/
theorem retention_of_discordance_of_inversion_mass {s : Finset ι} {d r : ι → ℝ} {M : ℝ}
    (hnonneg : ∀ i ∈ s, 0 ≤ r i) (hle : ∀ i ∈ s, r i ≤ M) (θ : ℝ) :
    ((keepSet s d θ).card : ℝ) * (∑ i ∈ s, r i)
      ≤ (s.card : ℝ) * (∑ i ∈ keepSet s d θ, r i)
        + M * (discordantPairs s d r).card :=
  le_trans (retention_of_inversion_mass θ)
    (by linarith [inversionMass_le_max_mul_card (d := d) (M := M) hnonneg hle])

omit [DecidableEq ι] in
/-- **Scale-free form.**  If no inversion is worth more than a gap `g`, the whole penalty
is at most `g · |Disc|`, whatever the size of the rates themselves.  Deployment reads this
as: a dial may invert many pairs provided it only ever confuses nearly equal targets. -/
theorem inversionMass_le_gap_mul_card {s : Finset ι} {d r : ι → ℝ} {g : ℝ}
    (hgap : ∀ p ∈ discordantPairs s d r, r p.1 - r p.2 ≤ g) :
    inversionMass s d r ≤ g * (discordantPairs s d r).card := by
  calc inversionMass s d r ≤ ∑ _p ∈ discordantPairs s d r, g := Finset.sum_le_sum hgap
    _ = g * (discordantPairs s d r).card := by rw [Finset.sum_const, nsmul_eq_mul]; ring

/-- **Throughput form of the refined budget.**  The yield per unit of work of the retained
set is below the global one by at most `inversionMass / (|s| |K|)`. -/
theorem throughput_le_of_inversion_mass {s : Finset ι} {d r : ι → ℝ} (θ : ℝ)
    (hK : (keepSet s d θ).Nonempty) (hs : s.Nonempty) :
    throughput s r
      ≤ throughput (keepSet s d θ) r
        + inversionMass s d r / ((s.card : ℝ) * (keepSet s d θ).card) := by
  have hkpos : (0:ℝ) < (keepSet s d θ).card := by
    exact_mod_cast Finset.card_pos.mpr hK
  have hspos : (0:ℝ) < s.card := by exact_mod_cast Finset.card_pos.mpr hs
  have h := retention_of_inversion_mass (s := s) (d := d) (r := r) θ
  rw [throughput, throughput, div_le_iff₀ hspos, add_mul, div_mul_eq_mul_div,
    div_mul_eq_mul_div, div_add_div _ _ (ne_of_gt hkpos) (by positivity),
    le_div_iff₀ (by positivity)]
  nlinarith [h, hkpos, hspos, mul_pos hspos hkpos]

/-! ## Lab note — the refinement is strictly better

Three targets with rates `(10, 3, 2)` and a dial that ranks them `(10, 2, 3)`: the dial is
right about the big target and merely swaps the two nearly equal small ones.  There is
exactly one inversion, so the old penalty is `M · |Disc| = 10`, while the refined penalty
is the actual gap `3 − 2 = 1`.  All numbers below are proved. -/

/-- Lab-note rates: one dominant target and two nearly equal small ones. -/
def massLabRate : Fin 3 → ℝ := ![10, 3, 2]

/-- Lab-note dial: correct on the dominant target, inverted on the two small ones. -/
def massLabDial : Fin 3 → ℝ := ![10, 2, 3]

/-- The dial has exactly one inversion, namely the pair `(1, 2)`. -/
theorem massLab_discordantPairs :
    discordantPairs (Finset.univ : Finset (Fin 3)) massLabDial massLabRate = {(1, 2)} := by
  ext p
  obtain ⟨a, b⟩ := p
  fin_cases a <;> fin_cases b <;>
    simp [discordantPairs, massLabDial, massLabRate, Prod.ext_iff] <;> norm_num

/-- **The refined penalty is ten times smaller than the linear one.**  On this instance the
inversion mass is `1`, while the `M · |Disc|` budget charges `10`. -/
theorem labnote_inversion_mass_strictly_better :
    inversionMass (Finset.univ : Finset (Fin 3)) massLabDial massLabRate = 1 ∧
      inversionMass (Finset.univ : Finset (Fin 3)) massLabDial massLabRate
        < 10 * ((discordantPairs (Finset.univ : Finset (Fin 3))
            massLabDial massLabRate).card : ℝ) := by
  have hmass : inversionMass (Finset.univ : Finset (Fin 3)) massLabDial massLabRate = 1 := by
    rw [inversionMass, massLab_discordantPairs, Finset.sum_singleton]
    simp [massLabRate]
    norm_num
  refine ⟨hmass, ?_⟩
  rw [hmass, massLab_discordantPairs]
  norm_num

/-- The rates of the lab instance are bounded by `M = 10`, so the comparison above is
between two *valid* bounds and not an artefact of an inadmissible `M`. -/
theorem massLab_rate_bounds :
    (∀ i ∈ (Finset.univ : Finset (Fin 3)), 0 ≤ massLabRate i) ∧
      ∀ i ∈ (Finset.univ : Finset (Fin 3)), massLabRate i ≤ 10 := by
  constructor <;> intro i _ <;> fin_cases i <;> norm_num [massLabRate]

end Probability.AdaptiveQS