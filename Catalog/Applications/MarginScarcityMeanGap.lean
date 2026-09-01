import Applications.MarginScarcityEntropy

/-!
# Cycle 3: two forward-pass numbers bound the transplant damage

Cycles 1–2 bounded the measured transplant damage by the *margin-uncertified
fraction* and bounded that fraction below by the diffuse fraction.  Both are
per-position statistics: they need the whole margin histogram.  This file shows
that **two scalars suffice** — a cap `G` on the top-1 gap and the mean gap `mu`
over the held-out set:

  `damage ≤ (G − mu) / (G − 2·eps)`,

for any drift level `eps` with `2·eps < G`.  The mechanism is a reverse-Markov
argument (`low_margin_frac_le`): a large mean gap under a hard cap forces the
low-margin positions to be few, and low-margin positions are the only ones that
can be damaged (`uncertifiedSet_subset_lowMarginSet`, which is the cycle-1
screen localised at a gap lower bound `g`).

## Main results

* `uncertifiedSet_subset_lowMarginSet` — every margin-uncertified position has
  gap surrogate `g x ≤ 2·eps`.
* `low_margin_frac_le` — reverse Markov: the low-gap fraction is at most
  `(G − mu)/(G − 2·eps)`.
* `mean_margin_bounds_damage` — the composite: mean gap and gap cap bound the
  post-transplant damage, with no transplant and no histogram.
* `mean_margin_bound_sharp` — the bound is attained: a two-position family with
  gaps `(2·eps, G)` has mean gap `(2·eps + G)/2`, predicted damage bound `1/2`
  and low-margin fraction exactly `1/2`.
* `net54_mean_margin_requirement` — the falsifiable NET-54 consequence: since
  the tail arm's damage is `0.4557`, its gap statistics must satisfy
  `mu ≤ G − 0.4557·(G − 2·eps)`; at `G = 5`, `eps = 0.16` this caps the tail's
  mean top-1 gap at `2.8673` nats.  A measured mean gap above that value would
  falsify the whole margin route.
-/

namespace Catalog.Applications.MarginScarcityMeanGap

open Finset
open Catalog.Novelty.KVDecisionDissociation
open Catalog.Probability.TailTransplantGeometry
open Catalog.Probability.TailTransplantCost
open Catalog.Applications.MarginScarcityPortability

variable {Ω : Type*} [Fintype Ω] [DecidableEq Ω]

open Classical in
/-- The positions whose gap surrogate falls below the drift budget `2·eps`. -/
noncomputable def lowMarginSet (g : Ω → ℝ) (eps : ℝ) : Finset Ω :=
  Finset.univ.filter (fun x => g x ≤ 2 * eps)

open Classical in
/-- The low-margin fraction, computed from a single forward pass. -/
noncomputable def lowMarginFrac (g : Ω → ℝ) (eps : ℝ) : ℝ :=
  ((lowMarginSet g eps).card : ℝ) / (Fintype.card Ω : ℝ)

open Classical in
omit [DecidableEq Ω] in
/-- If `g` under-estimates the top-1 gap of `u` at every position and the drift
from `u` to `v` is at most `eps`, then every margin-uncertified position is a
low-margin position. -/
theorem uncertifiedSet_subset_lowMarginSet {m : ℕ} (u v : Ω → Fin m → ℝ) (d : Ω → Fin m)
    (g : Ω → ℝ) (eps : ℝ) (hg : ∀ x j, j ≠ d x → g x ≤ u x (d x) - u x j)
    (hdrift : ∀ x j, |u x j - v x j| ≤ eps) :
    uncertifiedSet u v d eps ⊆ lowMarginSet g eps := by
  classical
  intro x hx
  simp only [uncertifiedSet, Finset.mem_filter, Finset.mem_univ, true_and] at hx
  simp only [lowMarginSet, Finset.mem_filter, Finset.mem_univ, true_and]
  by_contra hlow
  push_neg at hlow
  exact hx ⟨fun j hj => lt_of_lt_of_le hlow (hg x j hj), fun j => hdrift x j⟩

open Classical in
omit [DecidableEq Ω] in
/-- **Reverse Markov for margins.**  A gap surrogate capped by `G` with mean at
least `mu` leaves at most a `(G − mu)/(G − 2·eps)` fraction of positions below
`2·eps`. -/
theorem low_margin_frac_le [Nonempty Ω] (g : Ω → ℝ) (eps G mu : ℝ)
    (hcap : ∀ x, g x ≤ G) (hGe : 2 * eps < G)
    (hmean : mu * (Fintype.card Ω : ℝ) ≤ ∑ x, g x) :
    lowMarginFrac g eps ≤ (G - mu) / (G - 2 * eps) := by
  classical
  set S := lowMarginSet g eps with hS
  set T := Finset.univ.filter (fun x => ¬ (g x ≤ 2 * eps)) with hT
  have hN : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast Fintype.card_pos
  have hcards : (S.card : ℝ) + (T.card : ℝ) = (Fintype.card Ω : ℝ) := by
    have : S.card + T.card = Fintype.card Ω := by
      simpa [hS, hT, lowMarginSet, Finset.card_univ] using
        (Finset.card_filter_add_card_filter_not
          (s := (Finset.univ : Finset Ω)) (p := fun x => g x ≤ 2 * eps))
    exact_mod_cast this
  have hsplit : ∑ x ∈ S, g x + ∑ x ∈ T, g x = ∑ x, g x := by
    rw [hS, hT, lowMarginSet]
    exact Finset.sum_filter_add_sum_filter_not _ _ _
  have h1 : ∑ x ∈ S, g x ≤ (S.card : ℝ) * (2 * eps) := by
    have hstep : ∑ x ∈ S, g x ≤ ∑ _x ∈ S, (2 * eps) := by
      refine Finset.sum_le_sum (fun x hx => ?_)
      simp only [hS, lowMarginSet, Finset.mem_filter] at hx
      exact hx.2
    rwa [Finset.sum_const, nsmul_eq_mul] at hstep
  have h2 : ∑ x ∈ T, g x ≤ (T.card : ℝ) * G := by
    have hstep : ∑ x ∈ T, g x ≤ ∑ _x ∈ T, G := Finset.sum_le_sum (fun x _ => hcap x)
    rwa [Finset.sum_const, nsmul_eq_mul] at hstep
  have hkey : (S.card : ℝ) * (G - 2 * eps) ≤ (G - mu) * (Fintype.card Ω : ℝ) := by
    have hTcard : (T.card : ℝ) = (Fintype.card Ω : ℝ) - (S.card : ℝ) := by linarith
    have h2' : ∑ x ∈ T, g x ≤ (Fintype.card Ω : ℝ) * G - (S.card : ℝ) * G := by
      rw [hTcard] at h2; linarith [h2, (by ring :
        ((Fintype.card Ω : ℝ) - (S.card : ℝ)) * G
          = (Fintype.card Ω : ℝ) * G - (S.card : ℝ) * G)]
    have hgoal1 : (S.card : ℝ) * (G - 2 * eps)
        = (S.card : ℝ) * G - (S.card : ℝ) * (2 * eps) := by ring
    have hgoal2 : (G - mu) * (Fintype.card Ω : ℝ)
        = (Fintype.card Ω : ℝ) * G - mu * (Fintype.card Ω : ℝ) := by ring
    rw [hgoal1, hgoal2]
    linarith
  rw [lowMarginFrac, ← hS, div_le_div_iff₀ hN (by linarith : (0:ℝ) < G - 2 * eps)]
  linarith

open Classical in
omit [DecidableEq Ω] in
/-- **Mean margin bounds transplant damage.**  Two numbers from one forward pass
— the gap cap `G` and the mean gap `mu` — upper-bound the measured
post-transplant disagreement.  No transplant, no margin histogram. -/
theorem mean_margin_bounds_damage [Nonempty Ω] {m : ℕ} (u v : Ω → Fin m → ℝ)
    (d dH : Ω → Fin m) (g : Ω → ℝ) (eps G mu : ℝ)
    (hg : ∀ x j, j ≠ d x → g x ≤ u x (d x) - u x j)
    (hdrift : ∀ x j, |u x j - v x j| ≤ eps)
    (hcap : ∀ x, g x ≤ G) (hGe : 2 * eps < G)
    (hmean : mu * (Fintype.card Ω : ℝ) ≤ ∑ x, g x)
    (hH : ∀ x, IsStrictTop (v x) (dH x)) :
    damageFrac dH d ≤ (G - mu) / (G - 2 * eps) := by
  classical
  have hN : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast Fintype.card_pos
  have hscreen : damageFrac dH d ≤ uncertifiedFrac u v d eps :=
    margin_route_screens_damage u v d dH eps hH
  have hsub : ((uncertifiedSet u v d eps).card : ℝ) ≤ ((lowMarginSet g eps).card : ℝ) := by
    exact_mod_cast Finset.card_le_card
      (uncertifiedSet_subset_lowMarginSet u v d g eps hg hdrift)
  have hfrac : uncertifiedFrac u v d eps ≤ lowMarginFrac g eps := by
    unfold uncertifiedFrac lowMarginFrac
    exact div_le_div_of_nonneg_right hsub hN.le
  exact le_trans hscreen (le_trans hfrac
    (low_margin_frac_le g eps G mu hcap hGe hmean))

/-- **The reverse-Markov bound is attained.**  On two positions with gaps
`2·eps` and `G` the mean gap is `(2·eps + G)/2`, the bound evaluates to `1/2`
and the low-margin fraction is exactly `1/2`.  So no improvement of
`low_margin_frac_le` as a function of `(G, mu, eps)` alone is possible. -/
theorem mean_margin_bound_sharp (eps G : ℝ) (hGe : 2 * eps < G) :
    lowMarginFrac (![2 * eps, G] : Fin 2 → ℝ) eps = 1 / 2 ∧
      (G - (2 * eps + G) / 2) / (G - 2 * eps) = 1 / 2 := by
  classical
  constructor
  · have hset : lowMarginSet (![2 * eps, G] : Fin 2 → ℝ) eps = {0} := by
      ext x
      simp only [lowMarginSet, Finset.mem_filter, Finset.mem_univ, true_and,
        Finset.mem_singleton]
      fin_cases x
      · simp
      · simp
        linarith
    rw [lowMarginFrac, hset]
    simp
  · have hne : G - 2 * eps ≠ 0 := by linarith
    rw [show G - (2 * eps + G) / 2 = (G - 2 * eps) / 2 by ring]
    rw [div_right_comm, div_self hne]

open Classical in
omit [DecidableEq Ω] in
/-- **The falsifiable NET-54 consequence.**  The tail arm's measured damage is
`0.4557`.  If its gap statistics were `(G, mu)` at drift `eps` with
`2·eps < G`, then necessarily `0.4557·(G − 2·eps) ≤ G − mu`; equivalently the
mean top-1 gap of the donor tail cannot exceed `G − 0.4557·(G − 2·eps)`.  At
`G = 5` nats and `eps = 0.16` this caps the mean gap at `2.8673` nats — a
directly measurable prediction whose violation would refute the margin route. -/
theorem net54_mean_margin_requirement [Nonempty Ω] {m : ℕ} (u v : Ω → Fin m → ℝ)
    (d dH : Ω → Fin m) (g : Ω → ℝ) (eps G mu : ℝ)
    (hg : ∀ x j, j ≠ d x → g x ≤ u x (d x) - u x j)
    (hdrift : ∀ x j, |u x j - v x j| ≤ eps)
    (hcap : ∀ x, g x ≤ G) (hGe : 2 * eps < G)
    (hmean : mu * (Fintype.card Ω : ℝ) ≤ ∑ x, g x)
    (hH : ∀ x, IsStrictTop (v x) (dH x))
    (hdam : (0.4557 : ℝ) = damageFrac dH d) :
    mu ≤ G - 0.4557 * (G - 2 * eps) := by
  have hb := mean_margin_bounds_damage u v d dH g eps G mu hg hdrift hcap hGe hmean hH
  rw [← hdam] at hb
  rw [le_div_iff₀ (by linarith : (0:ℝ) < G - 2 * eps)] at hb
  linarith

end Catalog.Applications.MarginScarcityMeanGap