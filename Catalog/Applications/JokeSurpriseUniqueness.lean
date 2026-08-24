import Applications.JokeSurpriseStability

/-!
# Why *this* invariant? A uniqueness theorem for surprise

The two preceding files of this thread take the formula `humor S = max' S - min' S`
(equivalently `Metric.diam S`, by `JokeSurpriseStability.humor_eq_diam`) as given, and
study its algebra (`Applications.JokeSurpriseAlgebra`,
`Applications.JokeColimitUniversality`) and its stability
(`Applications.JokeSurpriseStability`). The obvious objection is that the formula is
*chosen*: any monotone functional on setups would produce a plausible-looking theory.

This file removes the choice. We axiomatise what a *humor scale* must satisfy —

* **position blindness**: a joke is not funnier for being told about larger numbers
  (translation invariance);
* **staged telling**: telling a joke in two consecutive stages accumulates the surprise
  of the stages (concatenation additivity);
* **monotonicity**: widening the gap between the extreme readings cannot reduce
  surprise —

and prove that these three axioms pin the invariant down **completely**:

* `HumorScale.eq_scale_mul` : every humor scale is `V m M = c · (M - m)` with
  `c = V 0 1`;
* `HumorScale.scale_nonneg` : the constant is nonnegative;
* `HumorScale.eq_scale_mul_humor` : on setups, every humor scale is a nonnegative
  multiple of the catalog's `humor`;
* `HumorScale.ext_of_scale_eq` : a humor scale is determined by its value on the unit
  gap — the theory has exactly one degree of freedom, the choice of unit.

Consequently every theorem of the thread transfers automatically to *any* admissible
invariant, without re-proof:

* `HumorScale.submodular` : every humor scale is submodular;
* `HumorScale.lipschitz_hausdorff` : every humor scale is `2c`-Lipschitz for the
  Hausdorff distance between setups.

The technical heart is `cauchy_of_monotone`: a monotone solution of the Cauchy
functional equation on `[0, ∞)` is linear. It is proved from scratch (rational
dilations `g (k s) = k g s`, the floor sandwich `k/n ≤ t ≤ (k+1)/n`, and an
Archimedean limit), since a monotone — as opposed to continuous or measurable —
Cauchy theorem is not available off the shelf.

-- !-- Lab Notes -- !--
Hypothesis (H7): the range/diameter formula is not a modelling choice but is *forced*
by position blindness, staged telling, and monotonicity.
Hypothesis (H8): if H7 holds, the whole thread (submodularity, Hausdorff stability) is
axiom-independent and transfers to every admissible invariant.

Experiment: H7 was reduced to a Cauchy functional equation for `g t = V 0 t` on
`[0, ∞)`. The additivity `g (s + t) = g s + g t` comes from concatenation plus
translation invariance; monotonicity of `g` from the third axiom. The linearity
`g t = g 1 · t` was then proved by hand: `g (k s) = k g s` by induction, hence
`g (1/n) = g 1 / n` and `g (k/n) = g 1 · k / n`; sandwiching `t` between
`⌊n t⌋/n` and `(⌊n t⌋ + 1)/n` gives `|g t - g 1 · t| ≤ g 1 / n` for every `n`, and the
Archimedean property finishes. Non-vacuity was checked by exhibiting the range scale
`rangeScale` (with `c = 1`) as a model of the axioms.

Analysis: H7 and H8 both survive, and they retro-justify the earlier files: every
theorem previously proved about `humor` is a theorem about *any* invariant obeying the
three axioms, up to the scale factor `c`.

Critique: monotonicity is essential and not decorative — without it, a Hamel-basis
solution of the Cauchy equation gives a wildly discontinuous "humor scale" that is
translation invariant and concatenation additive but not proportional to the range.
The axioms are consistent (`rangeScale`) and, by `ext_of_scale_eq`, categorical up to
the single scale parameter.

Synthesis: surprise is the unique — up to choice of unit — position-blind, stage-
additive, monotone measure of a setup; the range formula of the catalog is its
normalisation at `c = 1`.
-/

open Finset Metric JokeSurpriseAlgebra JokeSurpriseStability

namespace JokeSurpriseUniqueness

/-! ### A monotone Cauchy equation -/

/-- **Monotone Cauchy.** A monotone solution of the Cauchy functional equation on
`[0, ∞)` is linear. Proved from rational dilations plus a floor sandwich; no
continuity or measurability is assumed. -/
theorem cauchy_of_monotone (g : ℝ → ℝ)
    (hadd : ∀ s t : ℝ, 0 ≤ s → 0 ≤ t → g (s + t) = g s + g t)
    (hmono : ∀ s t : ℝ, 0 ≤ s → s ≤ t → g s ≤ g t) :
    ∀ t : ℝ, 0 ≤ t → g t = g 1 * t := by
  have hzero : g 0 = 0 := by have := hadd 0 0 le_rfl le_rfl; simp at this; linarith
  have hnsmul : ∀ (k : ℕ) (s : ℝ), 0 ≤ s → g (k * s) = k * g s := by
    intro k s hs
    induction k with
    | zero => simpa using hzero
    | succ n ih =>
        have h1 : ((n : ℝ) + 1) * s = (n : ℝ) * s + s := by ring
        push_cast
        rw [h1, hadd _ _ (by positivity) hs, ih]
        ring
  have hc : 0 ≤ g 1 := by have := hmono 0 1 le_rfl (by norm_num); linarith
  intro t ht
  by_contra hne
  have hkey : ∀ n : ℕ, 0 < n → |g t - g 1 * t| ≤ g 1 / n := by
    intro n hn
    have hnR : (0:ℝ) < n := by exact_mod_cast hn
    set k : ℕ := ⌊(n : ℝ) * t⌋₊ with hk
    have hkt : (k : ℝ) / n ≤ t := by
      rw [div_le_iff₀ hnR]
      have := Nat.floor_le (by positivity : (0:ℝ) ≤ (n:ℝ) * t)
      nlinarith
    have htk : t ≤ ((k : ℝ) + 1) / n := by
      rw [le_div_iff₀ hnR]
      have := Nat.lt_floor_add_one ((n : ℝ) * t)
      nlinarith
    have hginv : g (1 / n) = g 1 / n := by
      have h3 : g ((n : ℝ) * (1 / n)) = n * g (1 / n) := hnsmul n (1/n) (by positivity)
      rw [mul_one_div, div_self (ne_of_gt hnR)] at h3
      field_simp at h3 ⊢
      linarith
    have hgk : g ((k : ℝ) / n) = g 1 * k / n := by
      have h2 : ((k : ℝ) / n) = (k : ℝ) * (1 / n) := by ring
      rw [h2, hnsmul k (1/n) (by positivity), hginv]
      ring
    have hgk1 : g (((k : ℝ) + 1) / n) = g 1 * ((k : ℝ) + 1) / n := by
      have h2 : (((k : ℝ) + 1) / n) = ((k + 1 : ℕ) : ℝ) * (1 / n) := by push_cast; ring
      rw [h2, hnsmul (k+1) (1/n) (by positivity), hginv]
      push_cast; ring
    have hlow : g 1 * (k : ℝ) / n ≤ g t := by
      rw [← hgk]; exact hmono _ _ (by positivity) hkt
    have hhigh : g t ≤ g 1 * ((k : ℝ) + 1) / n := by
      rw [← hgk1]; exact hmono _ _ ht htk
    have hkt' : g 1 * (k : ℝ) / n ≤ g 1 * t := by
      rw [mul_div_assoc]; exact mul_le_mul_of_nonneg_left hkt hc
    have htk' : g 1 * t ≤ g 1 * ((k : ℝ) + 1) / n := by
      rw [mul_div_assoc]; exact mul_le_mul_of_nonneg_left htk hc
    have hdiff : g 1 * ((k : ℝ) + 1) / n - g 1 * (k : ℝ) / n = g 1 / n := by
      field_simp; ring
    rw [abs_le]
    constructor <;> linarith
  have hpos : 0 < |g t - g 1 * t| := abs_pos.2 (sub_ne_zero.2 hne)
  obtain ⟨n, hn⟩ := exists_nat_gt (g 1 / |g t - g 1 * t|)
  have hn0 : 0 < n := by
    rcases Nat.eq_zero_or_pos n with rfl | h
    · exfalso
      have hnn : 0 ≤ g 1 / |g t - g 1 * t| := div_nonneg hc (le_of_lt hpos)
      simp at hn
      linarith
    · exact h
  have hb := hkey n hn0
  have hnR : (0:ℝ) < n := by exact_mod_cast hn0
  rw [div_lt_iff₀ hpos] at hn
  rw [le_div_iff₀ hnR] at hb
  linarith

/-! ### Humor scales -/

/-- A **humor scale**: an assignment of a surprise value to each pair of extreme
readings `m ≤ M`, which is blind to absolute position, additive under staged telling,
and monotone in the divergence of the readings. -/
structure HumorScale where
  /-- The surprise assigned to a setup whose extreme readings are `m` and `M`. -/
  toFun : ℝ → ℝ → ℝ
  /-- Position blindness: shifting all readings does not change the surprise. -/
  trans_inv : ∀ m M c : ℝ, m ≤ M → toFun (m + c) (M + c) = toFun m M
  /-- Staged telling: surprise accumulates along a decomposition of the reading gap. -/
  concat : ∀ a b c : ℝ, a ≤ b → b ≤ c → toFun a b + toFun b c = toFun a c
  /-- Monotonicity: a wider gap of readings is at least as surprising. -/
  mono : ∀ a b c : ℝ, a ≤ b → b ≤ c → toFun a b ≤ toFun a c

namespace HumorScale

variable (V : HumorScale)

/-- The **unit of a humor scale**: the surprise of the unit reading gap. -/
def scale : ℝ := V.toFun 0 1

/-- The **unit is nonnegative**. -/
theorem scale_nonneg : 0 ≤ V.scale := by
  have h0 : V.toFun 0 0 + V.toFun 0 0 = V.toFun 0 0 := V.concat 0 0 0 le_rfl le_rfl
  have h1 : V.toFun 0 0 ≤ V.toFun 0 1 := V.mono 0 0 1 le_rfl (by norm_num)
  simp only [scale]
  linarith

/-- **Uniqueness of the surprise invariant.** Every humor scale is the range functional
scaled by its unit: `V m M = c · (M - m)`. The range formula of the catalog is
therefore forced by the axioms, not chosen. -/
theorem eq_scale_mul (m M : ℝ) (h : m ≤ M) : V.toFun m M = V.scale * (M - m) := by
  set g : ℝ → ℝ := fun t => V.toFun 0 t with hg
  have hadd : ∀ s t : ℝ, 0 ≤ s → 0 ≤ t → g (s + t) = g s + g t := by
    intro s t hs ht
    have h1 : V.toFun 0 s + V.toFun s (s + t) = V.toFun 0 (s + t) :=
      V.concat 0 s (s + t) hs (by linarith)
    have h2 : V.toFun (0 + s) (t + s) = V.toFun 0 t := V.trans_inv 0 t s ht
    rw [zero_add] at h2
    have h3 : t + s = s + t := by ring
    rw [h3] at h2
    simp only [hg]
    linarith
  have hmono : ∀ s t : ℝ, 0 ≤ s → s ≤ t → g s ≤ g t := fun s t hs hst =>
    V.mono 0 s t hs hst
  have hlin := cauchy_of_monotone g hadd hmono (M - m) (by linarith)
  have hshift : V.toFun (0 + m) ((M - m) + m) = V.toFun 0 (M - m) :=
    V.trans_inv 0 (M - m) m (by linarith)
  rw [zero_add] at hshift
  have hMm : M - m + m = M := by ring
  rw [hMm] at hshift
  rw [hshift]
  simpa [hg, scale] using hlin

/-- **A humor scale is determined by its unit.** Two humor scales that agree on the
unit gap agree on every setup: the theory has exactly one degree of freedom. -/
theorem ext_of_scale_eq (V W : HumorScale) (h : V.scale = W.scale) (m M : ℝ)
    (hm : m ≤ M) : V.toFun m M = W.toFun m M := by
  rw [V.eq_scale_mul m M hm, W.eq_scale_mul m M hm, h]

/-- **The axioms are consistent.** The range functional is a humor scale, with unit
`1`. -/
def rangeScale : HumorScale where
  toFun := fun m M => M - m
  trans_inv := by intro m M c _; ring
  concat := by intro a b c _ _; ring
  mono := by intro a b c _ hbc; linarith

@[simp] theorem rangeScale_scale : rangeScale.scale = 1 := by
  simp [scale, rangeScale]

/-- **On setups, every humor scale is a multiple of the catalog's `humor`.** -/
theorem eq_scale_mul_humor (S : Finset ℝ) (hS : S.Nonempty) :
    V.toFun (S.min' hS) (S.max' hS) = V.scale * humor S hS := by
  rw [V.eq_scale_mul _ _ (S.min'_le_max' hS)]
  rfl

/-- **Submodularity transfers.** Every humor scale is a submodular valuation on setups
with a shared reading — the result is independent of the choice of invariant. -/
theorem submodular (S T : Finset ℝ) (hS : S.Nonempty) (hT : T.Nonempty)
    (h : (S ∩ T).Nonempty) :
    V.toFun ((S ∪ T).min' hS.inl) ((S ∪ T).max' hS.inl)
        + V.toFun ((S ∩ T).min' h) ((S ∩ T).max' h)
      ≤ V.toFun (S.min' hS) (S.max' hS) + V.toFun (T.min' hT) (T.max' hT) := by
  rw [V.eq_scale_mul_humor _ hS.inl, V.eq_scale_mul_humor _ h, V.eq_scale_mul_humor _ hS,
    V.eq_scale_mul_humor _ hT, ← mul_add, ← mul_add]
  exact mul_le_mul_of_nonneg_left
    (JokeColimitUniversality.humor_submodular S T hS hT h) V.scale_nonneg

/-- **Hausdorff stability transfers.** Every humor scale is `2 · scale`-Lipschitz for
the Hausdorff distance between setups: robustness of the measurement is an axiomatic
consequence, not an artefact of the range formula. -/
theorem lipschitz_hausdorff (S T : Finset ℝ) (hS : S.Nonempty) (hT : T.Nonempty) :
    |V.toFun (S.min' hS) (S.max' hS) - V.toFun (T.min' hT) (T.max' hT)|
      ≤ 2 * V.scale * hausdorffDist (S : Set ℝ) (T : Set ℝ) := by
  have hbS : Bornology.IsBounded (S : Set ℝ) := S.finite_toSet.isBounded
  have hbT : Bornology.IsBounded (T : Set ℝ) := T.finite_toSet.isBounded
  have hne : hausdorffEDist (S : Set ℝ) (T : Set ℝ) ≠ ⊤ :=
    hausdorffEDist_ne_top_of_nonempty_of_bounded (by exact_mod_cast hS)
      (by exact_mod_cast hT) hbS hbT
  have hmetric := abs_diam_sub_diam_le_two_hausdorffDist hbS hbT hne
  rw [← humor_eq_diam S hS, ← humor_eq_diam T hT] at hmetric
  rw [V.eq_scale_mul_humor _ hS, V.eq_scale_mul_humor _ hT, ← mul_sub, abs_mul,
    abs_of_nonneg V.scale_nonneg]
  calc V.scale * |humor S hS - humor T hT|
      ≤ V.scale * (2 * hausdorffDist (S : Set ℝ) (T : Set ℝ)) :=
        mul_le_mul_of_nonneg_left hmetric V.scale_nonneg
    _ = 2 * V.scale * hausdorffDist (S : Set ℝ) (T : Set ℝ) := by ring

end HumorScale

end JokeSurpriseUniqueness