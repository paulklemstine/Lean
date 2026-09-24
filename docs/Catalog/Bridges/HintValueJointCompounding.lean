/-
# HINT-VALUE-JOINT: do hints compound?  The exact one-bit law

Round-30 experiment #1 (paper 101, verdict *THE-HINTS-COMPOUND*) reports, for a
factor-residue battery read through the four views of `Algebra.SumDiffSplit`,

| view                       | bits   |
|----------------------------|--------|
| product view (hint-free)   | 2.1314 |
| sum view alone             | 0.6432 |
| gap view alone             | 0.6496 |
| joint `(s,d)` view         | 4.5605 |
| **joint hint value**       | **+2.4291** |

and reads the difference `+2.4291` against a "per-dial hint sum" of `+1.0288` as a **hint
synergy of `+1.40` bits**, concluding that *hints compound like capacities*.

This file settles the compounding question exactly, and the answer is sharper — and more
restrictive — than the verdict.  The decisive move is to define a *hint* the way a hint is
actually used: the **conditional** value of a dial **given the hint-free channel `N`**,

* `HintValueJoint.sumHint  = I(T ; N, s) - I(T ; N)`,
* `HintValueJoint.gapHint  = I(T ; N, d) - I(T ; N)`,
* `SumDiffSplit.hintValue  = I(T ; s, d) - I(T ; N)`   (the joint hint value),
* `HintValueJoint.hintSynergy = hintValue - sumHint - gapHint`.

Main results.

* `HintValueJoint.sumHint_nonneg`, `gapHint_nonneg`, `sumHint_le_hintValue`,
  `gapHint_le_hintValue` — the routing table is a partial order; each conditional dial hint
  sits between `0` and the joint hint value.
* `HintValueJoint.hintValue_le_sumHint_add_one`, `hintValue_le_gapHint_add_one` — **the
  quadratic bottleneck.**  Over any coefficient ring carrying a *sign selector* (a Boolean
  section of squaring; `HintValueJoint.zsel` is one for `ZMod p`, `p` an odd prime), the
  joint hint value exceeds *either* single conditional hint by at most **one bit**.  The
  mechanism is exactly the identity `d² = s² - 4N`: given the product residue and the sum
  residue, the gap residue is pinned up to sign, so the `(s,d)` view can add no more than the
  single orientation bit.
* `HintValueJoint.hintSynergy_le_one_sub_max`, `hintSynergy_le_one` — **THE-HINTS-COMPOUND-BY-
  AT-MOST-ONE-BIT.**  Hint synergy is bounded above by `1 - max(sumHint, gapHint)`, hence by
  one bit, *unconditionally in the number of labels, the population and the modulus*.  A
  measured conditional hint synergy of `+1.40` bits is therefore impossible *over a single
  prime modulus*: the reported figure must come either from unconditional per-dial rows
  (`I(T;s)`, `I(T;d)`), for which no such ceiling exists
  (`SumDiffSynergy.residueSynergy_le_label_entropy` is the only bound), from plug-in bias, or
  from the two-field arity of the modulus.  Cycle 2
  (`Bridges.HintValueMultiFieldCeiling`) settles which: the ceiling is exactly one
  orientation bit **per field**, so `+1.40` is possible over two fields and impossible over
  one.
* `HintValueJoint.neg_min_le_hintSynergy` — the redundancy direction is bounded by the
  smaller dial hint.
* `HintValueJoint.CompoundWitness` (mod `7`) — the one-bit ceiling is **attained**: a
  four-sample battery on which `sumHint = gapHint = 0` and `hintValue = 1`, i.e.
  `hintSynergy = +1` exactly.  Two hints that are individually worthless given `N` are
  jointly worth a full bit: the orientation bit of the hyperbola `pq = 1`.
* `HintValueJoint.RedundantWitness` (mod `5`) — compounding is **not a law**: a two-sample
  battery with `sumHint = gapHint = hintValue = 1`, so `hintSynergy = -1`.  Hints can be
  perfectly redundant.
* `HintValueJoint.hint_synergy_has_no_sign` — the two witnesses together: no universal
  superadditivity (nor subadditivity) statement for conditional hints exists.
* `HintValueJoint.hintSynergy_eq_zero_of_product_measurable` — the degenerate boundary.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): three conjectures were pre-stated.  (H1) conditional hints are
  superadditive ("hints compound"), as the round-30 verdict asserts;  (H2) their synergy is
  unbounded, growing with the label entropy, as capacity synergy does (paper 92);  (H3) the
  `(s,d)` view is strictly richer than `(N,s)`.
Experiment (Stage 2): exact recomputation of the routing table on small batteries (see
  `ComputationalEvidence.md`).  `200 000` random batteries over `m ∈ {5,7,11,13}`, `n ∈
  {4,…,12}` samples and `2`–`6` labels: **no** battery with conditional hint synergy above
  `1.000000` bit, and the value `1` attained exactly (mod `7`, hyperbola `pq = 1`, labels
  `XOR`); minimum observed `-1`, attained mod `5`.  Both extremal batteries are formalised
  below with exact (not estimated) entropies.
Analysis (Stage 3): (H1) is **false** — `RedundantWitness` has synergy `-1`.  (H2) is
  **false** over a single field, and this is the main theorem: `hintSynergy ≤ 1` no matter how many labels,
  samples or residues are involved, because `4N = s² - d²` makes `(N,s)` determine `d` up to
  a single sign.  (H3) survives, but only just: the gap between the `(N,s)` row and the
  `(s,d)` row is at most the one orientation bit, and that bit is exactly what
  `CompoundWitness` extracts.  The correct slogan is not "hints compound like capacities" but
  **"the second hint is worth at most the orientation bit"** — capacities compound without a
  ceiling, hints do not.
Critique (Stage 4): the one-bit theorem is stated for coefficient rings carrying a sign
  selector, and `zsel_sound` supplies one for every odd prime modulus; the hypothesis is
  genuinely needed, since over a ring with many square roots of unity the `(N,s)` fibre of
  the `(s,d)` view can be larger than `2`.  Every numerical claim below is an exact rational
  number of bits computed from fibre counts through `TraceBattery.H_eq_log_sub_log_of_uniform`;
  no `native_decide`, no floating point.  The flagged `0.9663`-bit which-factor statistic of
  the round-30 log is untouched here — it is a plug-in estimate on `~508k` cells with `30k`
  samples, and no theorem in this file depends on it.
-/
import Mathlib
import Algebra.SumDiffSynergy

namespace HintValueJoint

open TraceBattery BatterySynergy SumDiffSplit

/-! ## 0. Two small pieces of the information calculus -/

section Calculus

variable {Ω : Type*} [Fintype Ω] {α β Λ : Type*}

/-- Adding a statistic to a reading raises its capacity by at most that statistic's entropy,
in bits. -/
theorem MIb_pair_le_add_Hb (L : Ω → Λ) (f : Ω → α) (g : Ω → β) :
    MIb L (fun x => (f x, g x)) ≤ MIb L f + Hb g := by
  rw [MIb, MIb, Hb, ← add_div]
  exact (div_le_div_iff_of_pos_right log_two_pos).mpr (MI_pair_le_add_H L f g)

private theorem logb_le_one_of_le_two {c : ℕ} (hc : c ≤ 2) : Real.logb 2 (c : ℝ) ≤ 1 := by
  rcases Nat.eq_zero_or_pos c with rfl | hpos
  · simp
  · have h0 : (0 : ℝ) < (c : ℝ) := by exact_mod_cast hpos
    have hle : (c : ℝ) ≤ (2 : ℝ) := by exact_mod_cast hc
    calc Real.logb 2 (c : ℝ) ≤ Real.logb 2 (2 : ℝ) :=
          Real.logb_le_logb_of_le (by norm_num) h0 hle
      _ = 1 := Real.logb_self_eq_one (by norm_num)

/-- A Boolean statistic carries at most one bit. -/
theorem Hb_bool_le_one (e : Ω → Bool) : Hb e ≤ 1 := by
  classical
  refine le_trans (Hb_le_logb_card_img e) (logb_le_one_of_le_two ?_)
  have h := Finset.card_le_univ (img e)
  simpa using h

/-- **The binary-refinement ceiling.**  If a reading `f` refines a reading `g`, and a single
Boolean function of `f` suffices to separate the points of a `g`-fibre, then `f` carries at
most one bit more than `g` about any label. -/
theorem MIb_le_add_one_of_binary_refinement [Nonempty Ω] (L : Ω → Λ) (f : Ω → α) (g : Ω → β)
    (e : α → Bool)
    (hcoarse : ∀ x y, f x = f y → g x = g y)
    (hsplit : ∀ x y, g x = g y → e (f x) = e (f y) → f x = f y) :
    MIb L f ≤ MIb L g + 1 := by
  have hsame : ∀ x y, f x = f y ↔ (g x, e (f x)) = (g y, e (f y)) := by
    intro x y
    constructor
    · intro h
      exact Prod.ext (hcoarse x y h) (by rw [h])
    · intro h
      exact hsplit x y (congrArg Prod.fst h) (congrArg Prod.snd h)
  rw [MIb_eq_of_same_fibers L f (fun x => (g x, e (f x))) hsame]
  have h1 := MIb_pair_le_add_Hb L g (fun x => e (f x))
  have h2 := Hb_bool_le_one (fun x => e (f x))
  linarith

end Calculus

/-! ## 1. Conditional dial hints and their synergy -/

section Views

variable {Ω : Type*} [Fintype Ω] {Λ : Type*} {R : Type*} [CommRing R]

/-- The **hinted sum view**: the hint-free channel `N` together with the sum dial `s`.  This
is what a solver holding the product residue learns when it is *also* told `s`. -/
def sumHintView (P Q : Ω → R) : Ω → R × R := fun x => (productView P Q x, sumView P Q x)

/-- The **hinted gap view**: the hint-free channel `N` together with the gap dial `d`. -/
def gapHintView (P Q : Ω → R) : Ω → R × R := fun x => (productView P Q x, gapView P Q x)

/-- The **conditional hint value of the sum dial**: what `s` adds on top of `N`, in bits. -/
noncomputable def sumHint (L : Ω → Λ) (P Q : Ω → R) : ℝ :=
  MIb L (sumHintView P Q) - MIb L (productView P Q)

/-- The **conditional hint value of the gap dial**: what `d` adds on top of `N`, in bits. -/
noncomputable def gapHint (L : Ω → Λ) (P Q : Ω → R) : ℝ :=
  MIb L (gapHintView P Q) - MIb L (productView P Q)

/-- **Hint synergy**: the joint hint value minus the two conditional dial hints.  Positive
means the two hints compound; negative means they are redundant. -/
noncomputable def hintSynergy (L : Ω → Λ) (P Q : Ω → R) : ℝ :=
  hintValue L P Q - sumHint L P Q - gapHint L P Q

omit [Fintype Ω] in
theorem productView_comp_sumHintView (P Q : Ω → R) :
    productView P Q = Prod.fst ∘ sumHintView P Q := rfl

omit [Fintype Ω] in
theorem productView_comp_gapHintView (P Q : Ω → R) :
    productView P Q = Prod.fst ∘ gapHintView P Q := rfl

/-- **A conditional hint is never negative.** -/
theorem sumHint_nonneg (L : Ω → Λ) (P Q : Ω → R) : 0 ≤ sumHint L P Q := by
  have h : MIb L (productView P Q) ≤ MIb L (sumHintView P Q) := by
    rw [productView_comp_sumHintView]
    exact MIb_comp_le L (sumHintView P Q) Prod.fst
  simp only [sumHint]; linarith

theorem gapHint_nonneg (L : Ω → Λ) (P Q : Ω → R) : 0 ≤ gapHint L P Q := by
  have h : MIb L (productView P Q) ≤ MIb L (gapHintView P Q) := by
    rw [productView_comp_gapHintView]
    exact MIb_comp_le L (gapHintView P Q) Prod.fst
  simp only [gapHint]; linarith

variable [Invertible (2 : R)]

omit [Fintype Ω] in
/-- The hinted sum view is a coarsening of the joint residue view: both `N` and `s` are
functions of `(s,d)`. -/
theorem sumHintView_comp (P Q : Ω → R) :
    sumHintView P Q = (fun v : R × R => (prodOf v, v.1)) ∘ residueView P Q := by
  funext x
  simp [sumHintView, residueView, productView, sumView, prodOf_sd]

omit [Fintype Ω] in
theorem gapHintView_comp (P Q : Ω → R) :
    gapHintView P Q = (fun v : R × R => (prodOf v, v.2)) ∘ residueView P Q := by
  funext x
  simp [gapHintView, residueView, productView, gapView, prodOf_sd]

/-- **Each conditional dial hint is dominated by the joint hint value.** -/
theorem sumHint_le_hintValue (L : Ω → Λ) (P Q : Ω → R) : sumHint L P Q ≤ hintValue L P Q := by
  have h : MIb L (sumHintView P Q) ≤ MIb L (residueView P Q) := by
    rw [sumHintView_comp]
    exact MIb_comp_le L (residueView P Q) _
  simp only [sumHint, hintValue]; linarith

theorem gapHint_le_hintValue (L : Ω → Λ) (P Q : Ω → R) : gapHint L P Q ≤ hintValue L P Q := by
  have h : MIb L (gapHintView P Q) ≤ MIb L (residueView P Q) := by
    rw [gapHintView_comp]
    exact MIb_comp_le L (residueView P Q) _
  simp only [gapHint, hintValue]; linarith

/-- **Redundancy is bounded.**  Hints can be redundant, but never by more than the smaller of
the two conditional dial hints. -/
theorem neg_min_le_hintSynergy (L : Ω → Λ) (P Q : Ω → R) :
    -min (sumHint L P Q) (gapHint L P Q) ≤ hintSynergy L P Q := by
  rcases le_total (sumHint L P Q) (gapHint L P Q) with h | h
  · rw [min_eq_left h]
    have := gapHint_le_hintValue L P Q
    simp only [hintSynergy]; linarith
  · rw [min_eq_right h]
    have := sumHint_le_hintValue L P Q
    simp only [hintSynergy]; linarith

end Views

/-! ## 2. The quadratic bottleneck: `d² = s² - 4N` -/

section Bottleneck

variable {Ω : Type*} [Fintype Ω] {Λ : Type*} {R : Type*} [CommRing R]

omit [Fintype Ω] in
/-- **Given `N` and `s`, the gap residue is pinned up to sign.**  This is the identity
`4 N = s² - d²` read as a constraint on `d`. -/
theorem gap_sq_eq_of_sumHintView_eq (P Q : Ω → R) {x y : Ω}
    (h : sumHintView P Q x = sumHintView P Q y) :
    gapView P Q x * gapView P Q x = gapView P Q y * gapView P Q y := by
  have hN : P x * Q x = P y * Q y := congrArg Prod.fst h
  have hs : P x + Q x = P y + Q y := congrArg Prod.snd h
  show (Q x - P x) * (Q x - P x) = (Q y - P y) * (Q y - P y)
  calc (Q x - P x) * (Q x - P x)
      = (P x + Q x) * (P x + Q x) - 4 * (P x * Q x) := by ring
    _ = (P y + Q y) * (P y + Q y) - 4 * (P y * Q y) := by rw [hN, hs]
    _ = (Q y - P y) * (Q y - P y) := by ring

omit [Fintype Ω] in
/-- **Given `N` and `d`, the sum residue is pinned up to sign.** -/
theorem sum_sq_eq_of_gapHintView_eq (P Q : Ω → R) {x y : Ω}
    (h : gapHintView P Q x = gapHintView P Q y) :
    sumView P Q x * sumView P Q x = sumView P Q y * sumView P Q y := by
  have hN : P x * Q x = P y * Q y := congrArg Prod.fst h
  have hd : Q x - P x = Q y - P y := congrArg Prod.snd h
  show (P x + Q x) * (P x + Q x) = (P y + Q y) * (P y + Q y)
  calc (P x + Q x) * (P x + Q x)
      = (Q x - P x) * (Q x - P x) + 4 * (P x * Q x) := by ring
    _ = (Q y - P y) * (Q y - P y) + 4 * (P y * Q y) := by rw [hN, hd]
    _ = (P y + Q y) * (P y + Q y) := by ring

variable [Invertible (2 : R)] [Nonempty Ω]

/-- **The one-bit law, sum form.**  If the coefficient ring carries a *sign selector* `sel` —
a Boolean function separating the two square roots of any square — then the joint residue view
carries at most one bit more than the hinted sum view, so the joint hint value exceeds the
sum-dial hint by at most one bit. -/
theorem hintValue_le_sumHint_add_one (L : Ω → Λ) (P Q : Ω → R) (sel : R → Bool)
    (hsel : ∀ a b : R, a * a = b * b → sel a = sel b → a = b) :
    hintValue L P Q ≤ sumHint L P Q + 1 := by
  have key : MIb L (residueView P Q) ≤ MIb L (sumHintView P Q) + 1 := by
    refine MIb_le_add_one_of_binary_refinement L (residueView P Q) (sumHintView P Q)
      (fun v => sel v.2) ?_ ?_
    · intro x y h
      rw [sumHintView_comp]
      simp only [Function.comp_apply, h]
    · intro x y hg he
      have hs : sumView P Q x = sumView P Q y := congrArg Prod.snd hg
      have hd : gapView P Q x = gapView P Q y :=
        hsel _ _ (gap_sq_eq_of_sumHintView_eq P Q hg) he
      exact Prod.ext hs hd
  simp only [hintValue, sumHint]; linarith

/-- **The one-bit law, gap form.** -/
theorem hintValue_le_gapHint_add_one (L : Ω → Λ) (P Q : Ω → R) (sel : R → Bool)
    (hsel : ∀ a b : R, a * a = b * b → sel a = sel b → a = b) :
    hintValue L P Q ≤ gapHint L P Q + 1 := by
  have key : MIb L (residueView P Q) ≤ MIb L (gapHintView P Q) + 1 := by
    refine MIb_le_add_one_of_binary_refinement L (residueView P Q) (gapHintView P Q)
      (fun v => sel v.1) ?_ ?_
    · intro x y h
      rw [gapHintView_comp]
      simp only [Function.comp_apply, h]
    · intro x y hg he
      have hd : gapView P Q x = gapView P Q y := congrArg Prod.snd hg
      have hs : sumView P Q x = sumView P Q y :=
        hsel _ _ (sum_sq_eq_of_gapHintView_eq P Q hg) he
      exact Prod.ext hs hd
  simp only [hintValue, gapHint]; linarith

/-- **THE-HINTS-COMPOUND-BY-AT-MOST-ONE-BIT.**  Conditional hint synergy is bounded by
`1 - max(sumHint, gapHint)`.  Compounding is real (see `CompoundWitness`) but it is capped by
the single orientation bit of the quadratic recovery `d² = s² - 4N`, independently of the
modulus, the population and the number of labels. -/
theorem hintSynergy_le_one_sub_max (L : Ω → Λ) (P Q : Ω → R) (sel : R → Bool)
    (hsel : ∀ a b : R, a * a = b * b → sel a = sel b → a = b) :
    hintSynergy L P Q ≤ 1 - max (sumHint L P Q) (gapHint L P Q) := by
  rcases le_total (sumHint L P Q) (gapHint L P Q) with h | h
  · rw [max_eq_right h]
    have := hintValue_le_sumHint_add_one L P Q sel hsel
    simp only [hintSynergy]; linarith
  · rw [max_eq_left h]
    have := hintValue_le_gapHint_add_one L P Q sel hsel
    simp only [hintSynergy]; linarith

/-- **The hard one-bit ceiling.**  No factor-residue battery, over any modulus carrying a sign
selector, can show more than one bit of conditional hint synergy. -/
theorem hintSynergy_le_one (L : Ω → Λ) (P Q : Ω → R) (sel : R → Bool)
    (hsel : ∀ a b : R, a * a = b * b → sel a = sel b → a = b) :
    hintSynergy L P Q ≤ 1 := by
  have h := hintSynergy_le_one_sub_max L P Q sel hsel
  have h1 := sumHint_nonneg L P Q
  have h2 := gapHint_nonneg L P Q
  have h3 : 0 ≤ max (sumHint L P Q) (gapHint L P Q) := le_max_of_le_left h1
  linarith

/-- **The all-or-nothing law.**  Maximal compounding is possible only when *each* hint is
individually worthless: the synergy equals one bit exactly when both conditional dial hints
read `0` and the joint hint value reads `1`.  There is no battery in which two individually
valuable hints also compound maximally. -/
theorem hintSynergy_eq_one_iff (L : Ω → Λ) (P Q : Ω → R) (sel : R → Bool)
    (hsel : ∀ a b : R, a * a = b * b → sel a = sel b → a = b) :
    hintSynergy L P Q = 1 ↔
      sumHint L P Q = 0 ∧ gapHint L P Q = 0 ∧ hintValue L P Q = 1 := by
  constructor
  · intro h
    have hmax := hintSynergy_le_one_sub_max L P Q sel hsel
    have h1 := sumHint_nonneg L P Q
    have h2 := gapHint_nonneg L P Q
    have hs : sumHint L P Q ≤ max (sumHint L P Q) (gapHint L P Q) := le_max_left _ _
    have hg : gapHint L P Q ≤ max (sumHint L P Q) (gapHint L P Q) := le_max_right _ _
    have hsum : sumHint L P Q = 0 := by rw [h] at hmax; linarith
    have hgap : gapHint L P Q = 0 := by rw [h] at hmax; linarith
    refine ⟨hsum, hgap, ?_⟩
    simp only [hintSynergy, hsum, hgap] at h
    linarith
  · rintro ⟨hs, hg, hv⟩
    simp only [hintSynergy, hs, hg, hv]
    ring

/-- The degenerate boundary: product-measurable labels make every row of the table vanish, so
the synergy is exactly zero. -/
theorem hintSynergy_eq_zero_of_product_measurable (L : Ω → Λ) (P Q : Ω → R)
    (h : ∀ x y, productView P Q x = productView P Q y → L x = L y) :
    hintSynergy L P Q = 0 := by
  have hprod : MIb L (productView P Q) = Hb L := MIb_eq_label_entropy_of_determines L _ h
  have hsum : MIb L (sumHintView P Q) = Hb L := by
    refine MIb_eq_label_entropy_of_determines L _ fun x y hxy => ?_
    exact h x y (congrArg Prod.fst hxy)
  have hgap : MIb L (gapHintView P Q) = Hb L := by
    refine MIb_eq_label_entropy_of_determines L _ fun x y hxy => ?_
    exact h x y (congrArg Prod.fst hxy)
  have hres : MIb L (residueView P Q) = Hb L := by
    refine MIb_eq_label_entropy_of_determines L _ fun x y hxy => ?_
    exact h x y (prod_eq_of_sd_eq hxy)
  simp only [hintSynergy, hintValue, sumHint, gapHint, hprod, hsum, hgap, hres]
  ring

end Bottleneck

/-! ## 3. A sign selector for an odd prime modulus -/

section Selector

/-- **Two is invertible modulo an odd prime**, so the sum/difference change of coordinates is
available at every modulus of interest. -/
noncomputable def invertibleTwoOfOdd {p : ℕ} [Fact p.Prime] (hp : p % 2 = 1) :
    Invertible (2 : ZMod p) := by
  refine invertibleOfNonzero ?_
  intro h
  have h2 : ((2 : ℕ) : ZMod p) = 0 := by exact_mod_cast h
  have hdvd : p ∣ 2 := (ZMod.natCast_eq_zero_iff 2 p).mp h2
  have hle := Nat.le_of_dvd (by norm_num) hdvd
  have := (Fact.out : p.Prime).two_le
  omega

/-- The **sign selector** of `ZMod p`: the lower half of the representatives. -/
def zsel {p : ℕ} [NeZero p] (a : ZMod p) : Bool := decide (2 * a.val < p)

/-- **`zsel` separates the two square roots.**  Over an odd prime modulus, `a² = b²` forces
`a = ±b`, and the two signs land in different halves unless they coincide. -/
theorem zsel_sound {p : ℕ} [Fact p.Prime] (hp : p % 2 = 1) (a b : ZMod p)
    (h : a * a = b * b) (hs : zsel a = zsel b) : a = b := by
  have hfac : (a - b) * (a + b) = 0 := by linear_combination h
  rcases mul_eq_zero.1 hfac with h1 | h1
  · exact sub_eq_zero.1 h1
  · have hab : a = -b := by linear_combination h1
    by_cases hb : b = 0
    · rw [hab, hb, neg_zero]
    · haveI : NeZero b := ⟨hb⟩
      have hval : (-b).val = p - b.val := ZMod.val_neg_of_ne_zero b
      have hlt : b.val < p := ZMod.val_lt b
      have hpos : 0 < b.val := by
        rcases Nat.eq_zero_or_pos b.val with h0 | h0
        · exact absurd ((ZMod.val_eq_zero b).1 h0) hb
        · exact h0
      rw [hab] at hs
      simp only [zsel, hval, decide_eq_decide] at hs
      omega

end Selector

/-! ## 4. THE-HINTS-CAN-CANCEL: an exact `-1`-bit redundancy witness -/

namespace RedundantWitness

/-- Two samples on the hyperbola `p q = 1` modulo `5`: `(1,1)` and `(2,3)`. -/
def P : Fin 2 → ZMod 5 := ![1, 2]

def Q : Fin 2 → ZMod 5 := ![1, 3]

/-- The labels separate the two samples. -/
def L : Fin 2 → Fin 2 := ![0, 1]

theorem product_const (x y : Fin 2) : productView P Q x = productView P Q y := by
  fin_cases x <;> fin_cases y <;> decide

theorem cnt_L (x : Fin 2) : cnt L (L x) = 1 := by
  rw [SumDiffSynergy.cnt_eq_filter_card]
  fin_cases x <;> decide

theorem Hb_L : Hb L = 1 := by
  have h := SumDiffSynergy.H_eq_of_uniform_counts L 1 (by norm_num) cnt_L
  norm_num at h
  rw [Hb, h]
  field_simp

theorem MIb_product : MIb L (productView P Q) = 0 := by
  rw [MIb, MI_eq_zero_of_const L _ product_const, zero_div]

theorem sumHint_determines (x y : Fin 2) : sumHintView P Q x = sumHintView P Q y → L x = L y := by
  fin_cases x <;> fin_cases y <;> decide

theorem gapHint_determines (x y : Fin 2) : gapHintView P Q x = gapHintView P Q y → L x = L y := by
  fin_cases x <;> fin_cases y <;> decide

theorem residue_determines (x y : Fin 2) : residueView P Q x = residueView P Q y → L x = L y := by
  fin_cases x <;> fin_cases y <;> decide

theorem sumHint_eq_one : sumHint L P Q = 1 := by
  rw [sumHint, MIb_eq_label_entropy_of_determines L _ sumHint_determines, Hb_L, MIb_product]
  ring

theorem gapHint_eq_one : gapHint L P Q = 1 := by
  rw [gapHint, MIb_eq_label_entropy_of_determines L _ gapHint_determines, Hb_L, MIb_product]
  ring

theorem hintValue_eq_one : hintValue L P Q = 1 := by
  rw [hintValue, MIb_eq_label_entropy_of_determines L _ residue_determines, Hb_L, MIb_product]
  ring

/-- **The two hints are perfectly redundant: synergy `-1` bit.** -/
theorem hintSynergy_eq_neg_one : hintSynergy L P Q = -1 := by
  rw [hintSynergy, hintValue_eq_one, sumHint_eq_one, gapHint_eq_one]
  ring

end RedundantWitness

/-! ## 5. THE-ORIENTATION-BIT: the one-bit ceiling is attained -/

namespace CompoundWitness

instance : Invertible (2 : ZMod 7) := ⟨4, by decide, by decide⟩

/-- Four samples on the hyperbola `p q = 1` modulo `7`: `(2,4), (4,2), (3,5), (5,3)`.  The
product residue is constant, the sum residue takes two values and the gap residue takes two
values — and the two are independent coordinates of the fibre. -/
def P : Fin 4 → ZMod 7 := ![2, 4, 3, 5]

def Q : Fin 4 → ZMod 7 := ![4, 2, 5, 3]

/-- The label is the `XOR` of the two residue coordinates: it is the *orientation* of the
factorisation relative to its sum class. -/
def L : Fin 4 → Fin 2 := ![0, 1, 1, 0]

theorem product_const (x y : Fin 4) : productView P Q x = productView P Q y := by
  fin_cases x <;> fin_cases y <;> decide

theorem cnt_L (x : Fin 4) : cnt L (L x) = 2 := by
  rw [SumDiffSynergy.cnt_eq_filter_card]
  fin_cases x <;> decide

theorem cnt_sumHint (x : Fin 4) : cnt (sumHintView P Q) (sumHintView P Q x) = 2 := by
  rw [SumDiffSynergy.cnt_eq_filter_card]
  fin_cases x <;> decide

theorem cnt_gapHint (x : Fin 4) : cnt (gapHintView P Q) (gapHintView P Q x) = 2 := by
  rw [SumDiffSynergy.cnt_eq_filter_card]
  fin_cases x <;> decide

theorem cnt_pr_sumHint (x : Fin 4) :
    cnt (pr L (sumHintView P Q)) (pr L (sumHintView P Q) x) = 1 := by
  rw [SumDiffSynergy.cnt_eq_filter_card]
  fin_cases x <;> decide

theorem cnt_pr_gapHint (x : Fin 4) :
    cnt (pr L (gapHintView P Q)) (pr L (gapHintView P Q) x) = 1 := by
  rw [SumDiffSynergy.cnt_eq_filter_card]
  fin_cases x <;> decide

theorem residue_determines (x y : Fin 4) :
    residueView P Q x = residueView P Q y → L x = L y := by
  fin_cases x <;> fin_cases y <;> decide

theorem H_L : H L = Real.log 4 - Real.log 2 := by
  have h := SumDiffSynergy.H_eq_of_uniform_counts L 2 (by norm_num) cnt_L
  norm_num at h
  rw [h]

theorem Hb_L : Hb L = 1 := by
  rw [Hb, H_L, SumDiffSynergy.log_four]
  field_simp
  norm_num

theorem MIb_product : MIb L (productView P Q) = 0 := by
  rw [MIb, MI_eq_zero_of_const L _ product_const, zero_div]

/-- **The sum hint is worthless on this battery**: knowing `s` on top of `N` reads exactly
zero bits. -/
theorem MIb_sumHintView : MIb L (sumHintView P Q) = 0 := by
  have hf : H (sumHintView P Q) = Real.log 4 - Real.log 2 := by
    have h := SumDiffSynergy.H_eq_of_uniform_counts (sumHintView P Q) 2 (by norm_num) cnt_sumHint
    norm_num at h
    rw [h]
  have hpr : H (pr L (sumHintView P Q)) = Real.log 4 := by
    have h := SumDiffSynergy.H_eq_of_uniform_counts (pr L (sumHintView P Q)) 1 (by norm_num)
      cnt_pr_sumHint
    norm_num at h
    rw [h]
  have : MI L (sumHintView P Q) = 0 := by
    rw [MI_eq, H_L, hf, hpr, SumDiffSynergy.log_four]; ring
  rw [MIb, this, zero_div]

/-- **The gap hint is worthless on this battery** as well. -/
theorem MIb_gapHintView : MIb L (gapHintView P Q) = 0 := by
  have hf : H (gapHintView P Q) = Real.log 4 - Real.log 2 := by
    have h := SumDiffSynergy.H_eq_of_uniform_counts (gapHintView P Q) 2 (by norm_num) cnt_gapHint
    norm_num at h
    rw [h]
  have hpr : H (pr L (gapHintView P Q)) = Real.log 4 := by
    have h := SumDiffSynergy.H_eq_of_uniform_counts (pr L (gapHintView P Q)) 1 (by norm_num)
      cnt_pr_gapHint
    norm_num at h
    rw [h]
  have : MI L (gapHintView P Q) = 0 := by
    rw [MI_eq, H_L, hf, hpr, SumDiffSynergy.log_four]; ring
  rw [MIb, this, zero_div]

theorem sumHint_eq_zero : sumHint L P Q = 0 := by
  rw [sumHint, MIb_sumHintView, MIb_product]; ring

theorem gapHint_eq_zero : gapHint L P Q = 0 := by
  rw [gapHint, MIb_gapHintView, MIb_product]; ring

/-- **The joint view reads a full bit**: the orientation of the factorisation. -/
theorem hintValue_eq_one : hintValue L P Q = 1 := by
  rw [hintValue, MIb_eq_label_entropy_of_determines L _ residue_determines, Hb_L, MIb_product]
  ring

/-- **The one-bit ceiling is attained: synergy exactly `+1`.** -/
theorem hintSynergy_eq_one : hintSynergy L P Q = 1 := by
  rw [hintSynergy, hintValue_eq_one, sumHint_eq_zero, gapHint_eq_zero]
  ring

end CompoundWitness

/-! ## 6. The verdict -/

/-- **The one-bit law at an odd prime modulus.**  For every battery read through factor
residues modulo an odd prime, the conditional hint synergy is at most one bit. -/
theorem hintSynergy_le_one_zmod {p : ℕ} [Fact p.Prime] (hp : p % 2 = 1)
    {Ω : Type*} [Fintype Ω] [Nonempty Ω] {Λ : Type*}
    (L : Ω → Λ) (P Q : Ω → ZMod p) :
    hintSynergy L P Q ≤ 1 :=
  letI := invertibleTwoOfOdd hp
  hintSynergy_le_one L P Q zsel (zsel_sound hp)

/-- **The ceiling is sharp.**  Modulo `7` there is a four-sample battery whose two conditional
dial hints read exactly `0` bits while the joint hint value reads exactly `1` bit: hints do
compound, and they compound by exactly the orientation bit, the maximum the quadratic
bottleneck allows. -/
theorem one_bit_ceiling_attained :
    ∃ (L : Fin 4 → Fin 2) (P Q : Fin 4 → ZMod 7),
      sumHint L P Q = 0 ∧ gapHint L P Q = 0 ∧ hintValue L P Q = 1 ∧ hintSynergy L P Q = 1 :=
  ⟨CompoundWitness.L, CompoundWitness.P, CompoundWitness.Q, CompoundWitness.sumHint_eq_zero,
    CompoundWitness.gapHint_eq_zero, CompoundWitness.hintValue_eq_one,
    CompoundWitness.hintSynergy_eq_one⟩

/-- **Hint synergy has no sign.**  The round-30 slogan "hints compound" is not a law: there is
a battery modulo `5` whose two conditional hints are perfectly redundant (synergy `-1`) and a
battery modulo `7` whose hints compound maximally (synergy `+1`).  Superadditivity of hints is
therefore false in general, and so is subadditivity. -/
theorem hint_synergy_has_no_sign :
    (∃ (L : Fin 2 → Fin 2) (P Q : Fin 2 → ZMod 5), hintSynergy L P Q < 0) ∧
    (∃ (L : Fin 4 → Fin 2) (P Q : Fin 4 → ZMod 7), 0 < hintSynergy L P Q) := by
  constructor
  · exact ⟨RedundantWitness.L, RedundantWitness.P, RedundantWitness.Q, by
      rw [RedundantWitness.hintSynergy_eq_neg_one]; norm_num⟩
  · exact ⟨CompoundWitness.L, CompoundWitness.P, CompoundWitness.Q, by
      rw [CompoundWitness.hintSynergy_eq_one]; norm_num⟩

/-- **No conditional hint synergy of `+1.40` bits exists.**  The round-30 reading of
`+2.4291` joint bits against `+1.0288` per-dial bits cannot be a *conditional* hint
decomposition: any such decomposition obeys the one-bit law.  Stated contrapositively for the
modulus family of the experiment. -/
theorem no_conditional_synergy_above_one {p : ℕ} [Fact p.Prime] (hp : p % 2 = 1)
    {Ω : Type*} [Fintype Ω] [Nonempty Ω] {Λ : Type*} :
    ¬ ∃ (L : Ω → Λ) (P Q : Ω → ZMod p), 1 < hintSynergy L P Q := by
  rintro ⟨L, P, Q, h⟩
  exact absurd (hintSynergy_le_one_zmod hp L P Q) (not_le.2 h)

end HintValueJoint