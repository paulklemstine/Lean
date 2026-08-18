/-
Copyright (c) 2026. Phase A Research Mission: Bridge NumberTheory ↔ Machine Learning.

# Arithmetic Geometry of Transformer Weight Lattices, VI:
# the denominator law is exact — the defect spectrum at a rational mixing weight

`Bridges.QuantizedWeightLatticesSharpConstant` proved the **denominator law**: for a
convex `L`-Lipschitz loss and the `δ`-grid quantizer, the convexity defect at the
interpolation weight `a = k/q` is at most `(1 − 1/q)·L·δ`, and it exhibited a
witness attaining the bound only for `k = q − 1`.  Conjecture 1 of
`FUTURE_DIRECTIONS.md` asked whether the bound is attained for *every* `k`
coprime to `q`.

This file settles that conjecture **affirmatively, and in a stronger form**:

* `defect_spectrum` — for `gcd(k, q) = 1` and *every* `j` with `0 ≤ j < q` there is
  an explicit convex `1`-Lipschitz loss (a "distance to a target weight" loss) and
  an explicit pair of weights whose quantized convexity defect at mixing weight
  `k/q` equals **exactly** `δ·j/q`.  The whole arithmetic progression
  `(δ/q)·{0, 1, …, q−1}` is realised: the defect spectrum is the full rank-one
  lattice slice predicted by the arithmetic half of the denominator law.
* `denominator_constant_exact` — consequently the supremum of the defect over all
  convex `1`-Lipschitz losses at mixing weight `k/q` is attained and equals
  `(1 − 1/q)·δ`; formally an `IsGreatest` statement, so the constant of the
  denominator law is optimal for every residue `k` coprime to `q`.
* `denominator_constant_reduced` — for a general (not necessarily reduced) weight
  `k/q` the sharp constant is `(1 − gcd(k,q)/q)·δ`, i.e. only the *reduced*
  denominator matters.  Arithmetic, not size, of the mixing weight controls the
  loss of convexity.
* `quantizeTensor_defect_denominator` — the denominator law itself lifts from `ℝ`
  to whole weight tensors `ι → ℝ` with the sup norm: entrywise `δ`-grid
  quantization of a transformer's weights loses at most `(1 − 1/q)·L·δ` of
  convexity at any mixing weight of denominator `q`.
* `mesh_determined_by_defectSet`, `reducedDenominator_determined_by_defectSet` — a
  spectral converse: the achievable convexity defects are an arithmetic
  fingerprint.  They determine the mesh `δ` of the quantizer and the *reduced*
  denominator of the mixing weight, both recoverable from landscape measurements
  alone.

The mechanism: all three roundings are lattice points, so the discrepancy
`a·Qx + (1−a)·Qy − Q(a x + (1−a) y)` lies in `(δ/q)·ℤ`; its numerator is
`k·(round X − round Y) mod q`, and as `round X − round Y` ranges over `ℤ` this
covers all of `ℤ/qℤ` exactly when `gcd(k, q) = 1`.  Attainment is therefore a
covering statement for the cyclic group `ℤ/qℤ`, and the covering witnesses are
produced here by Bézout.
-/

import Bridges.QuantizedWeightLatticesSharpConstant

namespace QuantizedWeightLattices.DenominatorSharp

open Set QuantizedWeightLattices QuantizedWeightLattices.SharpConstant

/-! ## Section 1: the covering lemma for `ℤ/qℤ` -/

/-- **Bézout covering.**  If `k` is invertible mod `q`, every residue `j` is of the
form `k·d` mod `q`.  This is the arithmetic input that makes the denominator law
attainable at *every* coprime residue. -/
lemma exists_mul_sub_dvd {k q : ℕ} (hcop : Nat.Coprime k q) (j : ℤ) :
    ∃ d : ℤ, (q : ℤ) ∣ ((k : ℤ) * d - j) := by
  have hco : IsCoprime (k : ℤ) (q : ℤ) := Int.isCoprime_iff_gcd_eq_one.2 (by
    simpa [Int.gcd_natCast_natCast] using hcop)
  obtain ⟨u, v, huv⟩ := hco
  refine ⟨u * j, ⟨-(v * j), ?_⟩⟩
  have : (k : ℤ) * u = 1 - v * q := by linarith [huv]
  calc (k : ℤ) * (u * j) - j = ((k : ℤ) * u) * j - j := by ring
    _ = (1 - v * q) * j - j := by rw [this]
    _ = (q : ℤ) * -(v * j) := by ring

/-! ## Section 2: exact roundings of the witness points -/

/-- Rounding is exact on half-integers of the form `d − 1/2` (Lean's `round`
rounds halves upwards). -/
lemma round_int_sub_half (d : ℤ) : round ((d : ℝ) - 1 / 2) = d := by
  rw [round_eq]
  norm_num

lemma gridRound_int_sub_half {δ : ℝ} (hδ : 0 < δ) (d : ℤ) :
    gridRound δ (δ * ((d : ℝ) - 1 / 2)) = δ * (d : ℝ) := by
  have hne : δ ≠ 0 := ne_of_gt hδ
  have hx : δ * ((d : ℝ) - 1 / 2) / δ = (d : ℝ) - 1 / 2 := by
    field_simp
  rw [gridRound, hx, round_int_sub_half]

/-- **The critical rounding.**  If `n = q·s + j` with `0 ≤ j < q`, the point
`n/q − 1/2` rounds to `s`: the fractional part `j/q` is *not* enough to push the
rounding up.  This is where the denominator `q` enters. -/
lemma round_ratio_sub_half {q : ℕ} (hq : 0 < q) {n s j : ℤ} (hn : n = (q : ℤ) * s + j)
    (hj0 : 0 ≤ j) (hjq : j < (q : ℤ)) : round ((n : ℝ) / (q : ℝ) - 1 / 2) = s := by
  have hqR : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  have hjR : (0 : ℝ) ≤ (j : ℝ) := by exact_mod_cast hj0
  have hjqR : (j : ℝ) < (q : ℝ) := by exact_mod_cast hjq
  have hval : (n : ℝ) / (q : ℝ) = (s : ℝ) + (j : ℝ) / (q : ℝ) := by
    rw [hn]
    push_cast
    field_simp
  rw [round_eq, show (n : ℝ) / (q : ℝ) - 1 / 2 + 1 / 2 = (n : ℝ) / (q : ℝ) by ring, hval]
  have hfrac0 : (0 : ℝ) ≤ (j : ℝ) / (q : ℝ) := by positivity
  have hfrac1 : (j : ℝ) / (q : ℝ) < 1 := by rw [div_lt_one hqR]; exact hjqR
  rw [Int.floor_eq_iff]
  constructor <;> linarith

lemma gridRound_ratio_point {δ : ℝ} (hδ : 0 < δ) {q : ℕ} (hq : 0 < q) {n s j : ℤ}
    (hn : n = (q : ℤ) * s + j) (hj0 : 0 ≤ j) (hjq : j < (q : ℤ)) :
    gridRound δ (δ * ((n : ℝ) / (q : ℝ) - 1 / 2)) = δ * (s : ℝ) := by
  have hne : δ ≠ 0 := ne_of_gt hδ
  have hx : δ * ((n : ℝ) / (q : ℝ) - 1 / 2) / δ = (n : ℝ) / (q : ℝ) - 1 / 2 := by
    field_simp
  rw [gridRound, hx, round_ratio_sub_half hq hn hj0 hjq]

/-! ## Section 3: the witness family realising an arbitrary lattice defect -/

/-- **Master witness.**  Fix a mixing weight `a = k/q` and integers `d, s, j` with
`k·d = q·s + j` and `0 ≤ j < q`.  Take the two weights `x = δ(d − 1/2)` and
`y = −δ/2`; they round to `δ·d` and `0`, while their `a`-combination
`δ(kd/q − 1/2)` rounds *down* to `δ·s`.  Against the target loss `|w − δ·C|` with
`C` large enough, the convexity defect of the quantized landscape is exactly
`δ·j/q`.

Every claim of this file is an instance of this computation. -/
lemma targetLoss_defect_witness {δ : ℝ} (hδ : 0 < δ) {k q : ℕ} (hq : 0 < q)
    {d s j C : ℤ} (hkd : (k : ℤ) * d = (q : ℤ) * s + j) (hj0 : 0 ≤ j) (hjq : j < (q : ℤ))
    (hCd : d ≤ C) (hCs : s ≤ C) (hC0 : 0 ≤ C) :
    targetLoss (δ * (C : ℝ))
        (gridRound δ (((k : ℝ) / q) * (δ * ((d : ℝ) - 1 / 2))
          + (1 - (k : ℝ) / q) * (-(δ / 2))))
      - (((k : ℝ) / q) * targetLoss (δ * (C : ℝ)) (gridRound δ (δ * ((d : ℝ) - 1 / 2)))
        + (1 - (k : ℝ) / q) * targetLoss (δ * (C : ℝ)) (gridRound δ (-(δ / 2))))
      = δ * (j : ℝ) / (q : ℝ) := by
  -- the mixing point is `δ·(kd/q − 1/2)`
  have hmix : ((k : ℝ) / q) * (δ * ((d : ℝ) - 1 / 2)) + (1 - (k : ℝ) / q) * (-(δ / 2))
      = δ * ((((k : ℤ) * d : ℤ) : ℝ) / (q : ℝ) - 1 / 2) := by
    push_cast
    field_simp
    ring
  rw [hmix, gridRound_ratio_point hδ hq hkd hj0 hjq, gridRound_int_sub_half hδ,
    gridRound_neg_half hδ]
  -- now evaluate the three losses
  have hCdR : (d : ℝ) ≤ (C : ℝ) := by exact_mod_cast hCd
  have hCsR : (s : ℝ) ≤ (C : ℝ) := by exact_mod_cast hCs
  have hC0R : (0 : ℝ) ≤ (C : ℝ) := by exact_mod_cast hC0
  have e1 : targetLoss (δ * (C : ℝ)) (δ * (s : ℝ)) = δ * ((C : ℝ) - (s : ℝ)) := by
    simp only [targetLoss]
    rw [abs_of_nonpos (by nlinarith)]
    ring
  have e2 : targetLoss (δ * (C : ℝ)) (δ * (d : ℝ)) = δ * ((C : ℝ) - (d : ℝ)) := by
    simp only [targetLoss]
    rw [abs_of_nonpos (by nlinarith)]
    ring
  have e3 : targetLoss (δ * (C : ℝ)) 0 = δ * (C : ℝ) := by
    simp only [targetLoss]
    rw [zero_sub, abs_neg, abs_of_nonneg (by positivity)]
  rw [e1, e2, e3]
  have hj : (j : ℝ) = (k : ℝ) * (d : ℝ) - (q : ℝ) * (s : ℝ) := by
    have := congrArg (fun z : ℤ => (z : ℝ)) hkd
    push_cast at this
    linarith
  field_simp
  rw [hj]
  ring

/-! ## Section 4: the defect spectrum at a coprime mixing weight -/

/-- **Theorem S9 (the defect spectrum is the full lattice slice).**  Let
`gcd(k, q) = 1` and let `j` be any residue `0 ≤ j < q`.  Then there is a convex
`1`-Lipschitz loss (distance to a target weight) and a pair of weights whose
`δ`-grid quantized convexity defect at mixing weight `k/q` is exactly `δ·j/q`.

So the set of achievable defects at a coprime rational mixing weight is precisely
the arithmetic progression `(δ/q)·{0, …, q−1}` allowed by the arithmetic half of
the denominator law: no value in that lattice slice is missing. -/
theorem defect_spectrum {δ : ℝ} (hδ : 0 < δ) {k q : ℕ} (hq : 0 < q)
    (hcop : Nat.Coprime k q) {j : ℤ} (hj0 : 0 ≤ j) (hjq : j < (q : ℤ)) :
    ∃ c x y : ℝ, ConvexOn ℝ univ (targetLoss c) ∧ LipschitzWith 1 (targetLoss c) ∧
      targetLoss c (gridRound δ (((k : ℝ) / q) * x + (1 - (k : ℝ) / q) * y))
        - (((k : ℝ) / q) * targetLoss c (gridRound δ x)
          + (1 - (k : ℝ) / q) * targetLoss c (gridRound δ y))
        = δ * (j : ℝ) / (q : ℝ) := by
  obtain ⟨d, e, he⟩ := exists_mul_sub_dvd hcop j
  have hkd : (k : ℤ) * d = (q : ℤ) * e + j := by linarith [he]
  set C : ℤ := max d (max e 0)
  refine ⟨δ * (C : ℝ), δ * ((d : ℝ) - 1 / 2), -(δ / 2), convexOn_targetLoss _,
    lipschitzWith_targetLoss _, ?_⟩
  exact targetLoss_defect_witness hδ hq hkd hj0 hjq (le_max_left _ _)
    ((le_max_left _ _).trans (le_max_right d _)) ((le_max_right _ _).trans (le_max_right d _))

/-- The set of convexity defects of `δ`-grid quantized landscapes of convex
`1`-Lipschitz losses, at the fixed mixing weight `a = k/q`. -/
def defectSet (δ : ℝ) (k q : ℕ) : Set ℝ :=
  {D : ℝ | ∃ (f : ℝ → ℝ) (x y : ℝ), ConvexOn ℝ univ f ∧ LipschitzWith 1 f ∧
    D = f (gridRound δ (((k : ℝ) / q) * x + (1 - (k : ℝ) / q) * y))
      - (((k : ℝ) / q) * f (gridRound δ x) + (1 - (k : ℝ) / q) * f (gridRound δ y))}

/-- **Theorem S10 (Conjecture 1 of `FUTURE_DIRECTIONS.md`, resolved).**  For every
denominator `q` and every numerator `k` coprime to `q` with `0 < k < q`, the
maximal convexity defect of a `δ`-grid quantized convex `1`-Lipschitz landscape at
mixing weight `k/q` is attained and equals exactly `(1 − 1/q)·δ`.

The upper bound is the denominator law `gridRound_defect_denominator`; the
attainment is the top of the defect spectrum (`defect_spectrum` at `j = q − 1`).
Together with the refutation of the old `L·r` conjecture, this pins the exact
arithmetic dependence of the convexity loss on the mixing weight. -/
theorem denominator_constant_exact {δ : ℝ} (hδ : 0 < δ) {k q : ℕ} (hq : 0 < q) (hk : k ≤ q)
    (hcop : Nat.Coprime k q) :
    IsGreatest (defectSet δ k q) (δ * (1 - 1 / (q : ℝ))) := by
  have hqR : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  constructor
  · -- attainment at `j = q − 1`
    have hj0 : (0 : ℤ) ≤ (q : ℤ) - 1 := by
      have : (1 : ℤ) ≤ (q : ℤ) := by exact_mod_cast hq
      linarith
    have hjq : (q : ℤ) - 1 < (q : ℤ) := by linarith
    obtain ⟨c, x, y, hconv, hlip, heq⟩ := defect_spectrum hδ hq hcop hj0 hjq
    refine ⟨targetLoss c, x, y, hconv, hlip, ?_⟩
    rw [heq]
    have : (((q : ℤ) - 1 : ℤ) : ℝ) = (q : ℝ) - 1 := by push_cast; ring
    rw [this]
    field_simp
  · rintro D ⟨f, x, y, hconv, hlip, rfl⟩
    have h := gridRound_defect_denominator (L := 1) hconv hlip hδ hq hk x y
    have hone : ((1 : NNReal) : ℝ) = 1 := by norm_num
    rw [hone, one_mul] at h
    linarith

/-! ## Section 5: general (non-reduced) mixing weights -/

/-- **Theorem S11 (only the reduced denominator matters).**  For an arbitrary
mixing weight `k/q` with `0 < k < q`, the exact maximal convexity defect is
`(1 − g/q)·δ` where `g = gcd(k, q)`: the sharp constant depends on the *reduced*
denominator `q/g` alone.  Two mixing weights of the same value have the same
convexity cost, and a weight with a small reduced denominator (e.g. `1/2`) is
strictly gentler than a nearby weight with a large one. -/
theorem denominator_constant_reduced {δ : ℝ} (hδ : 0 < δ) {k q : ℕ} (hk0 : 0 < k) (hkq : k < q) :
    IsGreatest (defectSet δ k q) (δ * (1 - (Nat.gcd k q : ℝ) / (q : ℝ))) := by
  have hq0 : 0 < q := lt_trans hk0 hkq
  set g : ℕ := Nat.gcd k q with hg
  have hg0 : 0 < g := Nat.gcd_pos_of_pos_left _ hk0
  obtain ⟨k', hk'⟩ : g ∣ k := Nat.gcd_dvd_left k q
  obtain ⟨q', hq'⟩ : g ∣ q := Nat.gcd_dvd_right k q
  have hq'0 : 0 < q' := by
    rcases Nat.eq_zero_or_pos q' with h | h
    · simp [h] at hq'; omega
    · exact h
  have hk'0 : 0 < k' := by
    rcases Nat.eq_zero_or_pos k' with h | h
    · simp [h] at hk'; omega
    · exact h
  have hcop : Nat.Coprime k' q' := by
    have := Nat.coprime_div_gcd_div_gcd (m := k) (n := q) hg0
    have e1 : k / g = k' := by rw [hk']; exact Nat.mul_div_cancel_left _ hg0
    have e2 : q / g = q' := by rw [hq']; exact Nat.mul_div_cancel_left _ hg0
    rwa [e1, e2] at this
  have hk'q' : k' ≤ q' := by
    have : g * k' < g * q' := by rw [← hk', ← hq']; exact hkq
    exact le_of_lt (lt_of_mul_lt_mul_left this (Nat.zero_le g))
  have hgR : (0 : ℝ) < (g : ℝ) := by exact_mod_cast hg0
  have hq'R : (0 : ℝ) < (q' : ℝ) := by exact_mod_cast hq'0
  -- the two fractions agree as real numbers
  have hfrac : ((k : ℝ) / (q : ℝ)) = ((k' : ℝ) / (q' : ℝ)) := by
    rw [hk', hq']
    push_cast
    field_simp
  have hbound : δ * (1 - (g : ℝ) / (q : ℝ)) = δ * (1 - 1 / (q' : ℝ)) := by
    rw [hq']
    push_cast
    field_simp
  have hset : defectSet δ k q = defectSet δ k' q' := by
    unfold defectSet
    rw [hfrac]
  rw [hset, hbound]
  exact denominator_constant_exact hδ hq'0 hk'q' hcop

/-! ## Section 6: the denominator law for whole weight tensors -/

section Tensor

variable {ι : Type*} [Fintype ι] {L : NNReal} {f : (ι → ℝ) → ℝ}

/-- Entrywise discrepancy bound: quantizing a rational convex combination of two
weight tensors differs from the same combination of the quantized tensors by at
most `(1 − 1/q)·δ` in sup norm. -/
lemma quantizeTensor_denominator_dist {δ : ℝ} (hδ : 0 < δ) {k q : ℕ} (hk0 : 0 < k) (hkq : k < q)
    (W V : ι → ℝ) :
    ‖quantizeTensor δ (((k : ℝ) / q) • W + (1 - (k : ℝ) / q) • V)
      - (((k : ℝ) / q) • quantizeTensor δ W + (1 - (k : ℝ) / q) • quantizeTensor δ V)‖
      ≤ δ * (1 - 1 / (q : ℝ)) := by
  have hq0 : 0 < q := lt_trans hk0 hkq
  have hqR : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq0
  have hq1 : 1 / (q : ℝ) ≤ 1 := by
    rw [div_le_one hqR]
    exact_mod_cast hq0
  refine (pi_norm_le_iff_of_nonneg (by nlinarith)).2 fun i => ?_
  have hi : (((k : ℝ) / q) • W + (1 - (k : ℝ) / q) • V) i
      = ((k : ℝ) / q) * W i + (1 - (k : ℝ) / q) * V i := rfl
  have e : (quantizeTensor δ (((k : ℝ) / q) • W + (1 - (k : ℝ) / q) • V)
      - (((k : ℝ) / q) • quantizeTensor δ W + (1 - (k : ℝ) / q) • quantizeTensor δ V)) i
      = -(((k : ℝ) / q) * gridRound δ (W i) + (1 - (k : ℝ) / q) * gridRound δ (V i)
          - gridRound δ (((k : ℝ) / q) * W i + (1 - (k : ℝ) / q) * V i)) := by
    simp only [Pi.sub_apply, Pi.add_apply, Pi.smul_apply, smul_eq_mul, quantizeTensor, hi]
    ring
  rw [Real.norm_eq_abs, e, abs_neg]
  exact discrepancy_le_denominator hδ hk0 hkq (W i) (V i)

/-- **Theorem S12 (tensor denominator law).**  For a convex `L`-Lipschitz loss on
whole transformer weight tensors, entrywise `δ`-grid quantization satisfies the
convexity inequality at any mixing weight `k/q` with defect at most
`(1 − 1/q)·L·δ`.  Interpolating two quantized checkpoints with a low-denominator
weight (e.g. a `1/2` model soup) is provably gentler on the landscape than an
arbitrary interpolation, and by `denominator_constant_reduced` the constant
cannot be improved. -/
theorem quantizeTensor_defect_denominator (hf : ConvexOn ℝ univ f) (hL : LipschitzWith L f)
    {δ : ℝ} (hδ : 0 < δ) {k q : ℕ} (hk0 : 0 < k) (hkq : k < q) (W V : ι → ℝ) :
    f (quantizeTensor δ (((k : ℝ) / q) • W + (1 - (k : ℝ) / q) • V))
      ≤ ((k : ℝ) / q) * f (quantizeTensor δ W)
        + (1 - (k : ℝ) / q) * f (quantizeTensor δ V) + (L : ℝ) * (δ * (1 - 1 / (q : ℝ))) := by
  have hq0 : 0 < q := lt_trans hk0 hkq
  have hqR : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq0
  have ha0 : (0 : ℝ) ≤ (k : ℝ) / q := by positivity
  have ha1 : (k : ℝ) / q ≤ 1 := by
    rw [div_le_one hqR]
    exact_mod_cast hkq.le
  set A : ι → ℝ := quantizeTensor δ (((k : ℝ) / q) • W + (1 - (k : ℝ) / q) • V)
  set B : ι → ℝ := ((k : ℝ) / q) • quantizeTensor δ W
    + (1 - (k : ℝ) / q) • quantizeTensor δ V
  have hdist : ‖A - B‖ ≤ δ * (1 - 1 / (q : ℝ)) :=
    quantizeTensor_denominator_dist hδ hk0 hkq W V
  have hlip : |f A - f B| ≤ (L : ℝ) * ‖A - B‖ := abs_sub_le_lipschitz hL A B
  have hmul : (L : ℝ) * ‖A - B‖ ≤ (L : ℝ) * (δ * (1 - 1 / (q : ℝ))) :=
    mul_le_mul_of_nonneg_left hdist L.coe_nonneg
  have hAB : f A ≤ f B + (L : ℝ) * (δ * (1 - 1 / (q : ℝ))) := by
    have := (abs_le.1 (hlip.trans hmul)).2
    linarith
  have hconv : f B ≤ ((k : ℝ) / q) * f (quantizeTensor δ W)
      + (1 - (k : ℝ) / q) * f (quantizeTensor δ V) :=
    hf.2 (mem_univ _) (mem_univ _) ha0 (by linarith) (by ring)
  linarith

end Tensor

/-! ## Section 7: a spectral converse — the defect set is an arithmetic fingerprint

The exact constants of Sections 4–5 can be read backwards: the convexity defects
of the quantized landscape are an *observable* of a training run (one measures the
violation of the convexity inequality), and they determine the arithmetic data of
the quantizer. -/

/-- **Theorem S13 (the mesh is determined by the defects).**  Two grid quantizers
with the same set of achievable convexity defects at one coprime mixing weight
have the same mesh.  The convexity defect spectrum of a quantized landscape
therefore *identifies* the lattice it was produced by. -/
theorem mesh_determined_by_defectSet {δ δ' : ℝ} (hδ : 0 < δ) (hδ' : 0 < δ') {k q : ℕ}
    (hq : 1 < q) (hk : k ≤ q) (hcop : Nat.Coprime k q)
    (h : defectSet δ k q = defectSet δ' k q) : δ = δ' := by
  have hq0 : 0 < q := lt_trans Nat.zero_lt_one hq
  have hqR : (1 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  have h1 := denominator_constant_exact hδ hq0 hk hcop
  have h2 := denominator_constant_exact hδ' hq0 hk hcop
  rw [h] at h1
  have hmax : δ * (1 - 1 / (q : ℝ)) = δ' * (1 - 1 / (q : ℝ)) := h1.unique h2
  have hpos : 0 < 1 - 1 / (q : ℝ) := by
    have : 1 / (q : ℝ) < 1 := by
      rw [div_lt_one (by linarith)]
      exact hqR
    linarith
  exact mul_right_cancel₀ (ne_of_gt hpos) hmax

/-- **Theorem S14 (the reduced denominator is determined by the defects).**  At a
fixed mesh, two mixing weights with the same defect set have the same *reduced*
denominator.  Combined with `denominator_constant_reduced` this says that the
reduced denominator of the interpolation weight is a complete invariant of the
convexity cost: it can be recovered from landscape measurements alone. -/
theorem reducedDenominator_determined_by_defectSet {δ : ℝ} (hδ : 0 < δ) {k q k' q' : ℕ}
    (hk0 : 0 < k) (hkq : k < q) (hk0' : 0 < k') (hkq' : k' < q')
    (h : defectSet δ k q = defectSet δ k' q') :
    q / Nat.gcd k q = q' / Nat.gcd k' q' := by
  have hq0 : 0 < q := lt_trans hk0 hkq
  have hq0' : 0 < q' := lt_trans hk0' hkq'
  have hg0 : 0 < Nat.gcd k q := Nat.gcd_pos_of_pos_left _ hk0
  have hg0' : 0 < Nat.gcd k' q' := Nat.gcd_pos_of_pos_left _ hk0'
  have hgd : Nat.gcd k q ∣ q := Nat.gcd_dvd_right k q
  have hgd' : Nat.gcd k' q' ∣ q' := Nat.gcd_dvd_right k' q'
  have h1 := denominator_constant_reduced hδ hk0 hkq
  have h2 := denominator_constant_reduced hδ hk0' hkq'
  rw [h] at h1
  have hmax : δ * (1 - (Nat.gcd k q : ℝ) / (q : ℝ))
      = δ * (1 - (Nat.gcd k' q' : ℝ) / (q' : ℝ)) := h1.unique h2
  have hfrac : (Nat.gcd k q : ℝ) / (q : ℝ) = (Nat.gcd k' q' : ℝ) / (q' : ℝ) := by
    have := mul_left_cancel₀ (ne_of_gt hδ) hmax
    linarith
  have hqR : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq0
  have hqR' : (0 : ℝ) < (q' : ℝ) := by exact_mod_cast hq0'
  have hgR : (0 : ℝ) < (Nat.gcd k q : ℝ) := by exact_mod_cast hg0
  have hgR' : (0 : ℝ) < (Nat.gcd k' q' : ℝ) := by exact_mod_cast hg0'
  have hcast : ((q / Nat.gcd k q : ℕ) : ℝ) = ((q' / Nat.gcd k' q' : ℕ) : ℝ) := by
    rw [Nat.cast_div hgd (ne_of_gt hgR), Nat.cast_div hgd' (ne_of_gt hgR')]
    rw [div_eq_div_iff (ne_of_gt hqR) (ne_of_gt hqR')] at hfrac
    rw [div_eq_div_iff (ne_of_gt hgR) (ne_of_gt hgR')]
    linarith
  exact_mod_cast hcast

end QuantizedWeightLattices.DenominatorSharp