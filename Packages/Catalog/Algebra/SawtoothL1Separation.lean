import Algebra.MultivariateRidgeSeparation

/-!
# An `L¹` (average-case) depth separation

The separations proved so far are sup-norm statements.  This file upgrades them
to the `L¹` norm: a piecewise affine function with few knots is not merely wrong
at one point, its *integrated* error against the sawtooth tower is bounded below
by an absolute constant.

## Main results

* `integral_abs_affine_ge` — for an affine function `α x + β` on `[a,b]`,
  `∫ₐᵇ |α x + β| ≥ (b−a)·max(|value at a|,|value at b|)/8`.
* `tooth_integral_lower` — on a full tooth `[2t/2^k, (2t+2)/2^k]` containing no
  knot of `f`, the integrated error against `tri^[k]` is at least
  `1/(16·2^k)`: an affine function cannot track a tent.
* `sawtooth_L1_lower_bound` — summing over teeth,
  `∫₀¹ |f − tri^[k]| ≥ (2^(k−1) − |S|)/(16·2^k)`, which is `≈ 1/32` whenever the
  knot count is `o(2^k)`.
* `relu_L1_lower_bound` — for a depth-`L`, width-`w` ReLU network,
  `∫₀¹ |f − tri^[k]| ≥ (2^(k−1) − 2(2w+2)^L)/(16·2^k)`.  With `k = L^2+4` and
  `w < 2^(L−1) − 1` the right-hand side is `1/32 − o(1)`: the shallow network is
  wrong *on average*, not just somewhere.
-/

noncomputable section

namespace ReluDepth

open Finset intervalIntegral

/-! ## An affine function cannot be small on a whole interval -/

/-- If the larger endpoint value is at `a`. -/
theorem integral_abs_affine_lower (α β a b : ℝ) (hab : a < b) (hM : |α*b+β| ≤ |α*a+β|) :
    (b-a) * |α*a+β| / 8 ≤ ∫ x in a..b, |α*x+β| := by
  set M := |α*a+β| with hMdef
  set m := a + (b-a)/4 with hm
  have hcont : Continuous (fun x : ℝ => |α*x+β|) := by fun_prop
  have hint : ∀ u v : ℝ, IntervalIntegrable (fun x : ℝ => |α*x+β|) MeasureTheory.volume u v :=
    fun u v => hcont.intervalIntegrable u v
  have ham : a ≤ m := by rw [hm]; linarith
  have hmb : m ≤ b := by rw [hm]; linarith
  have hsplit : (∫ x in a..m, |α*x+β|) + (∫ x in m..b, |α*x+β|) = ∫ x in a..b, |α*x+β| :=
    intervalIntegral.integral_add_adjacent_intervals (hint a m) (hint m b)
  have h2 : 0 ≤ ∫ x in m..b, |α*x+β| :=
    intervalIntegral.integral_nonneg hmb (fun x _ => abs_nonneg _)
  have hslope : |α| * (b-a) ≤ 2 * M := by
    have h1 : |α * b + β - (α * a + β)| ≤ |α*b+β| + |α*a+β| := abs_sub _ _
    have h2 : α * b + β - (α * a + β) = α * (b - a) := by ring
    rw [h2, abs_mul, abs_of_pos (by linarith : (0:ℝ) < b - a)] at h1
    linarith
  have hlow : ∀ x ∈ Set.Icc a m, M/2 ≤ |α*x+β| := by
    intro x hx
    have hxa : x - a ≤ (b-a)/4 := by rw [hm] at hx; linarith [hx.2]
    have hxa0 : 0 ≤ x - a := by linarith [hx.1]
    have hdiff : |α*x+β - (α*a+β)| = |α| * (x - a) := by
      have h5 : α*x+β - (α*a+β) = α * (x-a) := by ring
      rw [h5, abs_mul, abs_of_nonneg hxa0]
    have h3 : |α| * (x-a) ≤ M/2 := by
      have h6 : |α| * (x - a) ≤ |α| * ((b-a)/4) :=
        mul_le_mul_of_nonneg_left hxa (abs_nonneg _)
      nlinarith [abs_nonneg α]
    have h4 := abs_sub_abs_le_abs_sub (α*a+β) (α*x+β)
    rw [abs_sub_comm (α*a+β) (α*x+β)] at h4
    rw [hdiff] at h4
    linarith
  have h1 : (m - a) * (M/2) ≤ ∫ x in a..m, |α*x+β| := by
    have h7 := intervalIntegral.integral_mono_on ham
      (_root_.intervalIntegrable_const (c := M/2)) (hint a m) hlow
    rw [intervalIntegral.integral_const] at h7
    simpa [smul_eq_mul] using h7
  have hma : m - a = (b-a)/4 := by rw [hm]; ring
  rw [hma] at h1
  linarith

/-- If the larger endpoint value is at `b`. -/
theorem integral_abs_affine_lower_right (α β a b : ℝ) (hab : a < b) (hM : |α*a+β| ≤ |α*b+β|) :
    (b-a) * |α*b+β| / 8 ≤ ∫ x in a..b, |α*x+β| := by
  set M := |α*b+β| with hMdef
  set m := b - (b-a)/4 with hm
  have hcont : Continuous (fun x : ℝ => |α*x+β|) := by fun_prop
  have hint : ∀ u v : ℝ, IntervalIntegrable (fun x : ℝ => |α*x+β|) MeasureTheory.volume u v :=
    fun u v => hcont.intervalIntegrable u v
  have ham : a ≤ m := by rw [hm]; linarith
  have hmb : m ≤ b := by rw [hm]; linarith
  have hsplit : (∫ x in a..m, |α*x+β|) + (∫ x in m..b, |α*x+β|) = ∫ x in a..b, |α*x+β| :=
    intervalIntegral.integral_add_adjacent_intervals (hint a m) (hint m b)
  have h2 : 0 ≤ ∫ x in a..m, |α*x+β| :=
    intervalIntegral.integral_nonneg ham (fun x _ => abs_nonneg _)
  have hslope : |α| * (b-a) ≤ 2 * M := by
    have h1 : |α * b + β - (α * a + β)| ≤ |α*b+β| + |α*a+β| := abs_sub _ _
    have h2 : α * b + β - (α * a + β) = α * (b - a) := by ring
    rw [h2, abs_mul, abs_of_pos (by linarith : (0:ℝ) < b - a)] at h1
    linarith
  have hlow : ∀ x ∈ Set.Icc m b, M/2 ≤ |α*x+β| := by
    intro x hx
    have hxb : b - x ≤ (b-a)/4 := by rw [hm] at hx; linarith [hx.1]
    have hxb0 : 0 ≤ b - x := by linarith [hx.2]
    have hdiff : |α*b+β - (α*x+β)| = |α| * (b - x) := by
      have h5 : α*b+β - (α*x+β) = α * (b-x) := by ring
      rw [h5, abs_mul, abs_of_nonneg hxb0]
    have h3 : |α| * (b-x) ≤ M/2 := by
      have h6 : |α| * (b - x) ≤ |α| * ((b-a)/4) :=
        mul_le_mul_of_nonneg_left hxb (abs_nonneg _)
      nlinarith [abs_nonneg α]
    have h4 := abs_sub_abs_le_abs_sub (α*b+β) (α*x+β)
    rw [hdiff] at h4
    linarith
  have h1 : (b - m) * (M/2) ≤ ∫ x in m..b, |α*x+β| := by
    have h7 := intervalIntegral.integral_mono_on hmb
      (_root_.intervalIntegrable_const (c := M/2)) (hint m b) hlow
    rw [intervalIntegral.integral_const] at h7
    simpa [smul_eq_mul] using h7
  have hbm : b - m = (b-a)/4 := by rw [hm]; ring
  rw [hbm] at h1
  linarith

/-- **Affine functions cannot be uniformly small.**  The integral of `|α x + β|`
controls the larger of the two endpoint values. -/
theorem integral_abs_affine_ge (α β a b : ℝ) (hab : a < b) :
    (b-a) * max |α*a+β| |α*b+β| / 8 ≤ ∫ x in a..b, |α*x+β| := by
  rcases le_total |α*b+β| |α*a+β| with h | h
  · rw [max_eq_left h]; exact integral_abs_affine_lower α β a b hab h
  · rw [max_eq_right h]; exact integral_abs_affine_lower_right α β a b hab h

/-! ## Continuity of networks -/

lemma continuous_relu : Continuous relu := by unfold relu; fun_prop

lemma continuous_tri : Continuous tri := by unfold tri relu; fun_prop

lemma continuous_tri_iterate (k : ℕ) : Continuous (tri^[k]) := by
  induction k with
  | zero => simpa using continuous_id
  | succ k ih => rw [Function.iterate_succ]; exact ih.comp continuous_tri

lemma LayerUnits.continuous {w L n : ℕ} {us : Fin n → ℝ → ℝ} (h : LayerUnits w L us) :
    ∀ i, Continuous (us i) := by
  induction h with
  | input => intro _; exact continuous_id
  | step _ _ W b ih =>
      intro j
      exact continuous_relu.comp
        ((continuous_finset_sum _ (fun i _ => continuous_const.mul (ih i))).add continuous_const)

lemma IsNet.continuous {w L : ℕ} {f : ℝ → ℝ} (h : IsNet w L f) : Continuous f := by
  obtain ⟨n, us, hus, c, d, rfl⟩ := h
  exact (continuous_finset_sum _ (fun i _ => continuous_const.mul (hus.continuous i))).add
    continuous_const

/-! ## The dyadic tooth grid -/

/-- The left endpoint of the `t`-th tooth of `tri^[k]`. -/
noncomputable def toothPt (k t : ℕ) : ℝ := ((2*t : ℕ) : ℝ)/2^k

lemma toothPt_succ (k t : ℕ) : toothPt k (t+1) = (((2*t+2 : ℕ)) : ℝ)/2^k := by
  unfold toothPt; congr 2

lemma toothPt_zero (k : ℕ) : toothPt k 0 = 0 := by simp [toothPt]

lemma toothPt_top (k : ℕ) (hk : 1 ≤ k) : toothPt k (2^(k-1)) = 1 := by
  unfold toothPt
  obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
  simp
  rw [pow_succ]
  field_simp

lemma toothPt_mono (k : ℕ) {s t : ℕ} (h : s ≤ t) : toothPt k s ≤ toothPt k t := by
  unfold toothPt; gcongr

lemma toothPt_lt (k : ℕ) {s t : ℕ} (h : s < t) : toothPt k s < toothPt k t := by
  unfold toothPt; gcongr

/-! ## One tooth -/

/-- **An affine function cannot track a tent.**  On a tooth free of knots, the
integrated error against `tri^[k]` is at least `1/(16·2^k)`. -/
theorem tooth_integral_lower {S : Finset ℝ} {f : ℝ → ℝ} (hf : PWA S f) (hfc : Continuous f)
    (k t : ℕ) (ht : 2*t+2 ≤ 2^k)
    (hno : ∀ z ∈ S, z ≤ toothPt k t ∨ toothPt k (t+1) ≤ z) :
    (1:ℝ)/(16 * 2^k) ≤ ∫ x in (toothPt k t)..(toothPt k (t+1)), |f x - tri^[k] x| := by
  have hpow : (0:ℝ) < 2^k := by positivity
  set x0 : ℝ := toothPt k t with hx0
  set x1 : ℝ := ((2*t+1 : ℕ) : ℝ)/2^k with hx1
  set x2 : ℝ := toothPt k (t+1) with hx2
  have hx2' : x2 = ((2*t+2 : ℕ) : ℝ)/2^k := by rw [hx2, toothPt_succ]
  have hx01 : x0 < x1 := by
    rw [hx0, hx1, toothPt]; gcongr; omega
  have hx12 : x1 < x2 := by
    rw [hx1, hx2']; gcongr; omega
  have hx0nn : 0 ≤ x0 := by rw [hx0, toothPt]; positivity
  have hx21 : x2 ≤ 1 := by
    rw [hx2', div_le_one hpow]
    exact_mod_cast ht
  have hmid : x1 = (x0 + x2)/2 := by
    rw [hx0, hx1, hx2', toothPt]; push_cast; ring
  -- `f` is affine on the whole tooth
  obtain ⟨α, β, hab⟩ := hf x0 x2 hx0nn (le_of_lt (lt_trans hx01 hx12)) hx21 hno
  -- the two affine branches of the tent
  have hleft : ∀ x ∈ Set.Icc x0 x1, tri^[k] x = 2^k * x - (2*t : ℕ) := by
    intro x hx
    have h := tri_iterate_affine k (2*t) (by omega) x (by exact hx.1)
      (by
        have hc : ((2*t : ℕ) : ℝ) + 1 = ((2*t+1 : ℕ) : ℝ) := by push_cast; ring
        rw [hc, ← hx1]; exact hx.2)
    rwa [if_pos ⟨t, by ring⟩] at h
  have hright : ∀ x ∈ Set.Icc x1 x2, tri^[k] x = ((2*t+2 : ℕ) : ℝ) - 2^k * x := by
    intro x hx
    have h := tri_iterate_affine k (2*t+1) (by omega) x (by rw [← hx1]; exact hx.1)
      (by
        have hc : ((2*t+1 : ℕ) : ℝ) + 1 = ((2*t+2 : ℕ) : ℝ) := by push_cast; ring
        rw [hc, ← hx2']; exact hx.2)
    rw [if_neg (by simp [parity_simps])] at h
    rw [h]
    push_cast
    ring
  -- nodal values
  have hf0 : f x0 = α * x0 + β := hab x0 ⟨le_refl _, le_of_lt (lt_trans hx01 hx12)⟩
  have hf1 : f x1 = α * x1 + β := hab x1 ⟨le_of_lt hx01, le_of_lt hx12⟩
  have hf2 : f x2 = α * x2 + β := hab x2 ⟨le_of_lt (lt_trans hx01 hx12), le_refl _⟩
  have ht0 : tri^[k] x0 = 0 := by
    rw [hleft x0 ⟨le_refl _, le_of_lt hx01⟩, hx0, toothPt]
    field_simp
    ring
  have ht1 : tri^[k] x1 = 1 := by
    rw [hleft x1 ⟨le_of_lt hx01, le_refl _⟩, hx1]
    field_simp
    push_cast
    ring
  have ht2 : tri^[k] x2 = 0 := by
    rw [hright x2 ⟨le_of_lt hx12, le_refl _⟩, hx2']
    field_simp
    ring
  -- one of the three nodal errors is at least 1/2
  have hnode : 1/2 ≤ max (max |f x0 - tri^[k] x0| |f x1 - tri^[k] x1|)
      |f x2 - tri^[k] x2| := by
    rw [ht0, ht1, ht2, sub_zero, sub_zero]
    by_contra hcon
    push_neg at hcon
    have h1 : |f x1 - 1| < 1/2 :=
      lt_of_le_of_lt (le_trans (le_max_right _ _) (le_max_left _ _)) hcon
    have h0 : |f x0| < 1/2 := lt_of_le_of_lt (le_trans (le_max_left _ _) (le_max_left _ _)) hcon
    have h2 : |f x2| < 1/2 := lt_of_le_of_lt (le_max_right _ _) hcon
    have hmidval : f x1 = (f x0 + f x2)/2 := by
      rw [hf0, hf1, hf2, hmid]; ring
    rw [hmidval] at h1
    have hb1 := (abs_lt.mp h1).1
    have hb0 := (abs_lt.mp h0).2
    have hb2 := (abs_lt.mp h2).2
    linarith
  -- integrate over the two halves
  have hcont : Continuous (fun x : ℝ => |f x - tri^[k] x|) :=
    (hfc.sub (continuous_tri_iterate k)).abs
  have hint : ∀ u v : ℝ, IntervalIntegrable (fun x : ℝ => |f x - tri^[k] x|)
      MeasureTheory.volume u v := fun u v => hcont.intervalIntegrable u v
  have hsplit : (∫ x in x0..x1, |f x - tri^[k] x|) + (∫ x in x1..x2, |f x - tri^[k] x|)
      = ∫ x in x0..x2, |f x - tri^[k] x| :=
    intervalIntegral.integral_add_adjacent_intervals (hint x0 x1) (hint x1 x2)
  have hw1 : x1 - x0 = 1/2^k := by
    rw [hx0, hx1, toothPt]; field_simp; push_cast; ring
  have hw2 : x2 - x1 = 1/2^k := by
    rw [hx1, hx2']; field_simp; push_cast; ring
  -- left half
  have hleftint : (1/2^k) * max |f x0 - tri^[k] x0| |f x1 - tri^[k] x1| / 8
      ≤ ∫ x in x0..x1, |f x - tri^[k] x| := by
    have hEq : ∀ x ∈ Set.uIcc x0 x1,
        |f x - tri^[k] x| = |(α - 2^k) * x + (β + ((2*t : ℕ) : ℝ))| := by
      intro x hx
      rw [Set.uIcc_of_le (le_of_lt hx01)] at hx
      rw [hab x ⟨hx.1, le_trans hx.2 (le_of_lt hx12)⟩, hleft x hx]
      ring_nf
    rw [intervalIntegral.integral_congr hEq]
    have hbase := integral_abs_affine_ge (α - 2^k) (β + ((2*t : ℕ) : ℝ)) x0 x1 hx01
    have e0 : (α - 2^k) * x0 + (β + ((2*t : ℕ) : ℝ)) = f x0 - tri^[k] x0 := by
      rw [hab x0 ⟨le_refl _, le_of_lt (lt_trans hx01 hx12)⟩, hleft x0 ⟨le_refl _, le_of_lt hx01⟩]
      ring
    have e1 : (α - 2^k) * x1 + (β + ((2*t : ℕ) : ℝ)) = f x1 - tri^[k] x1 := by
      rw [hab x1 ⟨le_of_lt hx01, le_of_lt hx12⟩, hleft x1 ⟨le_of_lt hx01, le_refl _⟩]
      ring
    rw [e0, e1, hw1] at hbase
    exact hbase
  -- right half
  have hrightint : (1/2^k) * max |f x1 - tri^[k] x1| |f x2 - tri^[k] x2| / 8
      ≤ ∫ x in x1..x2, |f x - tri^[k] x| := by
    have hEq : ∀ x ∈ Set.uIcc x1 x2,
        |f x - tri^[k] x| = |(α + 2^k) * x + (β - ((2*t+2 : ℕ) : ℝ))| := by
      intro x hx
      rw [Set.uIcc_of_le (le_of_lt hx12)] at hx
      rw [hab x ⟨le_trans (le_of_lt hx01) hx.1, hx.2⟩, hright x hx]
      ring_nf
    rw [intervalIntegral.integral_congr hEq]
    have hbase := integral_abs_affine_ge (α + 2^k) (β - ((2*t+2 : ℕ) : ℝ)) x1 x2 hx12
    have e1 : (α + 2^k) * x1 + (β - ((2*t+2 : ℕ) : ℝ)) = f x1 - tri^[k] x1 := by
      rw [hab x1 ⟨le_of_lt hx01, le_of_lt hx12⟩, hright x1 ⟨le_refl _, le_of_lt hx12⟩]
      ring
    have e2 : (α + 2^k) * x2 + (β - ((2*t+2 : ℕ) : ℝ)) = f x2 - tri^[k] x2 := by
      rw [hab x2 ⟨le_of_lt (lt_trans hx01 hx12), le_refl _⟩,
        hright x2 ⟨le_of_lt hx12, le_refl _⟩]
      ring
    rw [e1, e2, hw2] at hbase
    exact hbase
  have hmax : 1/2 ≤ max |f x0 - tri^[k] x0| |f x1 - tri^[k] x1|
      ∨ 1/2 ≤ max |f x1 - tri^[k] x1| |f x2 - tri^[k] x2| := by
    rcases max_cases (max |f x0 - tri^[k] x0| |f x1 - tri^[k] x1|) |f x2 - tri^[k] x2| with
      ⟨he, _⟩ | ⟨he, _⟩
    · left; rw [he] at hnode; exact hnode
    · right; rw [he] at hnode; exact le_trans hnode (le_max_right _ _)
  have hscale : ∀ M : ℝ, 1/2 ≤ M → (1:ℝ)/(16*2^k) ≤ (1/2^k) * M / 8 := by
    intro M hM
    have he : (1:ℝ)/(16*2^k) = (1/2^k) * (1/2) / 8 := by field_simp; ring
    rw [he]
    gcongr
  have hgoal : (1:ℝ)/(16 * 2^k) ≤ (∫ x in x0..x1, |f x - tri^[k] x|)
      + ∫ x in x1..x2, |f x - tri^[k] x| := by
    rcases hmax with h | h
    · have h2 : 0 ≤ ∫ x in x1..x2, |f x - tri^[k] x| :=
        intervalIntegral.integral_nonneg (le_of_lt hx12) (fun x _ => abs_nonneg _)
      linarith [le_trans (hscale _ h) hleftint]
    · have h2 : 0 ≤ ∫ x in x0..x1, |f x - tri^[k] x| :=
        intervalIntegral.integral_nonneg (le_of_lt hx01) (fun x _ => abs_nonneg _)
      linarith [le_trans (hscale _ h) hrightint]
  rw [hsplit] at hgoal
  exact hgoal

/-! ## Summing over teeth -/

/-- **`L¹` lower bound.**  A piecewise affine function with knot set `S` has integrated
error at least `(2^(k-1) − |S|)/(16·2^k)` against the tower `tri^[k]`. -/
theorem sawtooth_L1_lower_bound {S : Finset ℝ} {f : ℝ → ℝ} (hf : PWA S f) (hfc : Continuous f)
    {k : ℕ} (hk : 1 ≤ k) :
    ((2:ℝ)^(k-1) - S.card)/(16 * 2^k) ≤ ∫ x in (0:ℝ)..1, |f x - tri^[k] x| := by
  classical
  have hpow : (0:ℝ) < 2^k := by positivity
  set N : ℕ := 2^(k-1) with hN
  have hcont : Continuous (fun x : ℝ => |f x - tri^[k] x|) :=
    (hfc.sub (continuous_tri_iterate k)).abs
  have hint : ∀ u v : ℝ, IntervalIntegrable (fun x : ℝ => |f x - tri^[k] x|)
      MeasureTheory.volume u v := fun u v => hcont.intervalIntegrable u v
  have hsum : ∑ t ∈ Finset.range N, ∫ x in (toothPt k t)..(toothPt k (t+1)),
      |f x - tri^[k] x| = ∫ x in (toothPt k 0)..(toothPt k N), |f x - tri^[k] x| :=
    intervalIntegral.sum_integral_adjacent_intervals (fun t _ => hint _ _)
  rw [toothPt_zero, hN, toothPt_top k hk] at hsum
  -- teeth containing a knot
  have hbadcard : ((Finset.range N).filter
      (fun t => ∃ z ∈ S, toothPt k t < z ∧ z < toothPt k (t+1))).card ≤ S.card := by
    have hchoose : ∀ t : ℕ, ∃ z : ℝ, (∃ z' ∈ S, toothPt k t < z' ∧ z' < toothPt k (t+1)) →
        (z ∈ S ∧ toothPt k t < z ∧ z < toothPt k (t+1)) := by
      intro t
      by_cases h : ∃ z' ∈ S, toothPt k t < z' ∧ z' < toothPt k (t+1)
      · obtain ⟨z, hz1, hz2⟩ := h
        exact ⟨z, fun _ => ⟨hz1, hz2⟩⟩
      · exact ⟨0, fun hc => absurd hc h⟩
    choose g hg using hchoose
    have hmaps : Set.MapsTo g (((Finset.range N).filter
        (fun t => ∃ z ∈ S, toothPt k t < z ∧ z < toothPt k (t+1))) : Finset ℕ) (S : Finset ℝ) := by
      intro t ht
      simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range] at ht
      exact_mod_cast (hg t ht.2).1
    have hinj : Set.InjOn g (((Finset.range N).filter
        (fun t => ∃ z ∈ S, toothPt k t < z ∧ z < toothPt k (t+1))) : Finset ℕ) := by
      intro s hs t ht hst
      simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range] at hs ht
      have h1 := hg s hs.2
      have h2 := hg t ht.2
      by_contra hne
      rcases lt_or_gt_of_ne hne with h | h
      · have h3 : toothPt k (s+1) ≤ toothPt k t := toothPt_mono k (by omega)
        rw [hst] at h1
        linarith [h1.2.2, h2.2.1]
      · have h3 : toothPt k (t+1) ≤ toothPt k s := toothPt_mono k (by omega)
        rw [hst] at h1
        linarith [h1.2.1, h2.2.2]
    exact Finset.card_le_card_of_injOn g hmaps hinj
  -- lower bound each knot-free tooth
  have hgood : ∀ t ∈ (Finset.range N).filter
      (fun t => ¬ ∃ z ∈ S, toothPt k t < z ∧ z < toothPt k (t+1)),
      (1:ℝ)/(16*2^k) ≤ ∫ x in (toothPt k t)..(toothPt k (t+1)), |f x - tri^[k] x| := by
    intro t ht
    simp only [Finset.mem_filter, Finset.mem_range] at ht
    have hno : ∀ z ∈ S, z ≤ toothPt k t ∨ toothPt k (t+1) ≤ z := by
      intro z hz
      by_contra hcon
      push_neg at hcon
      exact ht.2 ⟨z, hz, hcon.1, hcon.2⟩
    have ht2 : 2*t+2 ≤ 2^k := by
      have hh : t + 1 ≤ N := ht.1
      have h2N : 2 * N = 2^k := by
        rw [hN]
        obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
        simp [pow_succ, mul_comm]
      omega
    exact tooth_integral_lower hf hfc k t ht2 hno
  have hnonneg : ∀ t ∈ Finset.range N,
      0 ≤ ∫ x in (toothPt k t)..(toothPt k (t+1)), |f x - tri^[k] x| := by
    intro t _
    exact intervalIntegral.integral_nonneg (toothPt_mono k (by omega))
      (fun x _ => abs_nonneg _)
  -- combine
  have hsplitsum := Finset.sum_filter_add_sum_filter_not (Finset.range N)
    (fun t => ¬ ∃ z ∈ S, toothPt k t < z ∧ z < toothPt k (t+1))
    (fun t => ∫ x in (toothPt k t)..(toothPt k (t+1)), |f x - tri^[k] x|)
  have hgoodcard : (N : ℝ) - S.card ≤ ((((Finset.range N).filter
      (fun t => ¬ ∃ z ∈ S, toothPt k t < z ∧ z < toothPt k (t+1))).card : ℕ) : ℝ) := by
    have hcards := Finset.card_filter_add_card_filter_not (s := Finset.range N)
      (p := fun t => ∃ z ∈ S, toothPt k t < z ∧ z < toothPt k (t+1))
    rw [Finset.card_range] at hcards
    have hle : N - S.card ≤ ((Finset.range N).filter
        (fun t => ¬ ∃ z ∈ S, toothPt k t < z ∧ z < toothPt k (t+1))).card := by omega
    have hcast := (Nat.cast_le (α := ℝ)).mpr hle
    have hsub : (N:ℝ) - S.card ≤ ((N - S.card : ℕ) : ℝ) := by
      rcases le_total (S.card) N with h | h
      · rw [Nat.cast_sub h]
      · have hneg : (N:ℝ) - S.card ≤ 0 := by
          have := (Nat.cast_le (α := ℝ)).mpr h
          linarith
        exact le_trans hneg (Nat.cast_nonneg _)
    linarith
  have hsumgood : ((((Finset.range N).filter
      (fun t => ¬ ∃ z ∈ S, toothPt k t < z ∧ z < toothPt k (t+1))).card : ℕ) : ℝ)
        * (1/(16*2^k))
      ≤ ∑ t ∈ (Finset.range N).filter
          (fun t => ¬ ∃ z ∈ S, toothPt k t < z ∧ z < toothPt k (t+1)),
        ∫ x in (toothPt k t)..(toothPt k (t+1)), |f x - tri^[k] x| := by
    have hs := Finset.sum_le_sum hgood
    simpa [Finset.sum_const, nsmul_eq_mul, mul_comm] using hs
  have hsumbad : 0 ≤ ∑ t ∈ (Finset.range N).filter
      (fun t => ¬ ¬ ∃ z ∈ S, toothPt k t < z ∧ z < toothPt k (t+1)),
      ∫ x in (toothPt k t)..(toothPt k (t+1)), |f x - tri^[k] x| := by
    refine Finset.sum_nonneg (fun t ht => ?_)
    simp only [Finset.mem_filter, Finset.mem_range] at ht
    exact hnonneg t (Finset.mem_range.mpr ht.1)
  have hposc : (0:ℝ) < 1/(16*2^k) := by positivity
  have hchain : ((N:ℝ) - S.card) * (1/(16*2^k)) ≤ ∫ x in (0:ℝ)..1, |f x - tri^[k] x| := by
    rw [← hsum, ← hsplitsum]
    have := mul_le_mul_of_nonneg_right hgoodcard (le_of_lt hposc)
    linarith
  have hNcast : ((N:ℕ) : ℝ) = 2^(k-1) := by rw [hN]; push_cast; ring
  rw [hNcast] at hchain
  calc ((2:ℝ)^(k-1) - S.card)/(16 * 2^k) = ((2:ℝ)^(k-1) - S.card) * (1/(16*2^k)) := by ring
    _ ≤ ∫ x in (0:ℝ)..1, |f x - tri^[k] x| := hchain

/-- **Average-case depth separation.**  A depth-`L`, width-`w` ReLU network has
integrated error at least `(2^(k-1) − 2(2w+2)^L)/(16·2^k)` against `tri^[k]`; for
`k = L^2+4` and `w < 2^(L-1) − 1` this is close to `1/32`. -/
theorem relu_L1_lower_bound (L w k : ℕ) (hk : 1 ≤ k) (f : ℝ → ℝ) (hnet : IsNet w L f) :
    ((2:ℝ)^(k-1) - 2 * (2*w+2)^L)/(16 * 2^k) ≤ ∫ x in (0:ℝ)..1, |f x - tri^[k] x| := by
  obtain ⟨S, hScard, hS⟩ := hnet.pwa
  have h1 := sawtooth_L1_lower_bound hS hnet.continuous hk
  have h2 : (S.card : ℝ) ≤ 2 * (2*w+2)^L := by
    have h3 := knotBound_le w L
    have h4 : (S.card : ℕ) ≤ 2 * (2*w+2)^L := by omega
    exact_mod_cast h4
  have hden : (0:ℝ) < 16 * 2^k := by positivity
  have hmono : ((2:ℝ)^(k-1) - 2 * (2*w+2)^L)/(16 * 2^k)
      ≤ ((2:ℝ)^(k-1) - S.card)/(16 * 2^k) := by gcongr
  linarith

end ReluDepth

end