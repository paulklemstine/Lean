import Mathlib
import Catalog.NumberTheory.NormalizedQSeriesGroup

/-!
# Unique divisibility of the group of normalized `q`-series

Fourth research cycle on the pole-order obstruction.  In
`Catalog.NumberTheory.NormalizedQSeriesGroup` we showed that the normalized
Laurent series `q⁻¹ + a₀ + a₁ q + ⋯` form a commutative group under the
corrected product `f ⋆ g = q f g`, isomorphic to the group of `1`-units of
`ℂ⟦X⟧`.  Here we determine that group up to the finest possible invariant of
its arithmetic:

* `NormalizedQSeries.eq_one_of_pow_eq_one_of_constantCoeff_one` — the `1`-units
  of `ℂ⟦X⟧` are **torsion free**: no nontrivial root of unity has constant
  term `1`.  (A valuation/`geom_sum` argument.)
* `NormalizedQSeries.exists_pow_eq_of_constantCoeff_one` — the `1`-units are
  **divisible**: every one of them has an `n`-th root, obtained by substituting
  `u - 1` into the binomial series `(1 + X)^{1/n}`.  This is where the
  characteristic-zero hypothesis and the binomial (Hasse–Ward) structure of `ℚ`
  enter.
* `NormalizedQSeries.Normalized.existsUnique_pow` — consequently the group of
  normalized `q`-series is **uniquely divisible**: every normalized series has a
  *unique* `⋆`-`n`-th root.  Equivalently (`instRootableByNormalizedNat`) the
  group is rootable, and torsion free, so it is a `ℚ`-vector space in
  multiplicative notation.
* `NormalizedQSeries.existsUnique_star_root` restates this concretely: for `f`
  normalized and `n ≥ 1` there is exactly one normalized `g` with
  `q^{n-1} · gⁿ = f`.
* `NormalizedQSeries.existsUnique_moonshine_root` — the Monster-sized corrected
  product `q^{193} ∏_g T_g` has a *unique* normalized `194`-th `⋆`-root: the
  "geometric mean" of the `194` McKay–Thompson-shaped series exists and is
  unique.

The pole-order obstruction of the earlier cycles is thereby completely
resolved: after the canonical `q`-correction, the normalized `q`-series carry no
arithmetic obstruction at all — the group is a torsion-free divisible abelian
group, in which roots of every order exist and are unique.
-/

namespace NormalizedQSeries

open HahnSeries Finset PoleOrderObstruction PowerSeries

/-! ## 1. Roots of `1`-units in `ℂ⟦X⟧` -/

/-- Substituting a series with vanishing constant term preserves the constant
term. -/
theorem constantCoeff_subst_of_constantCoeff_one {h f : PowerSeries ℂ}
    (hc : PowerSeries.constantCoeff h = 0) (hsub : PowerSeries.HasSubst h)
    (hf : PowerSeries.constantCoeff f = 1) :
    PowerSeries.constantCoeff (PowerSeries.subst h f) = 1 := by
  have hsubst := PowerSeries.constantCoeff_subst (a := h) hsub f
  rw [show (MvPowerSeries.constantCoeff : PowerSeries ℂ →+* ℂ)
      = PowerSeries.constantCoeff from rfl] at hsubst
  rw [hsubst, finsum_eq_single _ 0]
  · simp [PowerSeries.coeff_zero_eq_constantCoeff, hf]
  · intro d hd
    have hzero : PowerSeries.constantCoeff (h ^ d) = 0 := by
      rw [map_pow, hc, zero_pow hd]
    simp [hzero]

/-- Powers of the binomial series add exponents. -/
theorem binomialSeries_pow (r : ℚ) (m : ℕ) :
    (PowerSeries.binomialSeries ℂ r) ^ m = PowerSeries.binomialSeries ℂ (m • r) := by
  induction m with
  | zero => simp
  | succ k ih => rw [pow_succ, ih, succ_nsmul, PowerSeries.binomialSeries_add]

/-- **Divisibility of the `1`-units.** Every power series with constant term `1`
has an `n`-th root with constant term `1`, for every `n ≥ 1`.  The root is the
binomial series `(1 + X)^{1/n}` with `X ↦ u - 1`. -/
theorem exists_pow_eq_of_constantCoeff_one {u : PowerSeries ℂ}
    (hu : PowerSeries.constantCoeff u = 1) {n : ℕ} (hn : 0 < n) :
    ∃ v : PowerSeries ℂ, PowerSeries.constantCoeff v = 1 ∧ v ^ n = u := by
  set h : PowerSeries ℂ := u - 1 with hh
  have hc : PowerSeries.constantCoeff h = 0 := by simp [hh, hu]
  have hsub : PowerSeries.HasSubst h := PowerSeries.HasSubst.of_constantCoeff_zero' hc
  refine ⟨PowerSeries.subst h (PowerSeries.binomialSeries ℂ ((n : ℚ)⁻¹)), ?_, ?_⟩
  · exact constantCoeff_subst_of_constantCoeff_one hc hsub (by simp)
  · rw [← PowerSeries.subst_pow hsub]
    have hpow : (PowerSeries.binomialSeries ℂ ((n : ℚ)⁻¹)) ^ n
        = PowerSeries.binomialSeries ℂ (1 : ℚ) := by
      rw [binomialSeries_pow]
      congr 1
      rw [nsmul_eq_mul]
      field_simp
    rw [hpow, show (1 : ℚ) = ((1 : ℕ) : ℚ) by norm_num, PowerSeries.binomialSeries_nat, pow_one,
      PowerSeries.subst_add hsub, PowerSeries.subst_X hsub,
      ← PowerSeries.coe_substAlgHom hsub, map_one]
    simp [hh]

/-- **Torsion freeness of the `1`-units.** A power series with constant term `1`
which is a root of unity is `1`. -/
theorem eq_one_of_pow_eq_one_of_constantCoeff_one {t : PowerSeries ℂ}
    (ht : PowerSeries.constantCoeff t = 1) {n : ℕ} (hn : 0 < n) (h : t ^ n = 1) : t = 1 := by
  by_contra hne
  have hsub : t - 1 ≠ 0 := sub_ne_zero.mpr hne
  have hgeom : (∑ i ∈ Finset.range n, t ^ i) * (t - 1) = t ^ n - 1 := geom_sum_mul t n
  rw [h, sub_self] at hgeom
  have hsum : (∑ i ∈ Finset.range n, t ^ i) ≠ 0 := by
    intro hzero
    have hconst : PowerSeries.constantCoeff (∑ i ∈ Finset.range n, t ^ i) = (n : ℂ) := by
      rw [map_sum]
      simp [map_pow, ht]
    rw [hzero, map_zero] at hconst
    exact (Nat.cast_ne_zero.mpr hn.ne').symm hconst
  exact (mul_ne_zero hsum hsub) hgeom

/-! ## 2. The group of `1`-units is uniquely divisible -/

namespace OneUnit

theorem val_pow (u : OneUnit) (n : ℕ) : (u ^ n).val = u.val ^ n := by
  induction n with
  | zero => simp
  | succ k ih => rw [pow_succ, pow_succ, OneUnit.val_mul, ih]

/-- The group of `1`-units is torsion free. -/
theorem pow_eq_one_iff (u : OneUnit) {n : ℕ} (hn : 0 < n) : u ^ n = 1 ↔ u = 1 := by
  constructor
  · intro h
    apply OneUnit.ext
    refine eq_one_of_pow_eq_one_of_constantCoeff_one u.constantCoeff_val hn ?_
    rw [← val_pow, h, OneUnit.val_one]
  · rintro rfl; simp

/-- **Unique divisibility of the `1`-units.** -/
theorem existsUnique_pow (u : OneUnit) {n : ℕ} (hn : 0 < n) : ∃! v : OneUnit, v ^ n = u := by
  obtain ⟨w, hw1, hwn⟩ := exists_pow_eq_of_constantCoeff_one u.constantCoeff_val hn
  refine ⟨⟨w, hw1⟩, OneUnit.ext (by rw [val_pow, hwn]), ?_⟩
  intro v hv
  have hquot : (v * (⟨w, hw1⟩ : OneUnit)⁻¹) ^ n = 1 := by
    rw [mul_pow, hv, inv_pow, OneUnit.ext (show ((⟨w, hw1⟩ : OneUnit) ^ n).val = u.val by
      rw [val_pow, hwn]), mul_inv_cancel]
  have := (pow_eq_one_iff _ hn).mp hquot
  rwa [mul_inv_eq_one] at this

end OneUnit

/-! ## 3. The group of normalized `q`-series is uniquely divisible -/

namespace Normalized

/-- The `n`-th power in the group `Normalized` is the `q`-corrected `n`-th
power `q^{n-1} · fⁿ`. -/
theorem val_pow (f : Normalized) (n : ℕ) :
    (f ^ n).val = HahnSeries.single ((n : ℤ) - 1) (1 : ℂ) * f.val ^ n := by
  induction n with
  | zero => simp [qInv]
  | succ k ih =>
      rw [pow_succ, Normalized.val_mul, ih, star, qSeries, pow_succ]
      push_cast
      calc HahnSeries.single (1 : ℤ) (1 : ℂ) *
            ((HahnSeries.single ((k : ℤ) - 1) (1 : ℂ) * f.val ^ k) * f.val)
          = (HahnSeries.single (1 : ℤ) (1 : ℂ) * HahnSeries.single ((k : ℤ) - 1) (1 : ℂ)) *
              (f.val ^ k * f.val) := by ring
        _ = HahnSeries.single ((k : ℤ) + 1 - 1) (1 : ℂ) * (f.val ^ k * f.val) := by
              rw [HahnSeries.single_mul_single, mul_one,
                show (1 : ℤ) + ((k : ℤ) - 1) = (k : ℤ) + 1 - 1 by ring]

/-- **Unique divisibility.** Every normalized `q`-series has a unique `⋆`-`n`-th
root, for every `n ≥ 1`. -/
theorem existsUnique_pow (f : Normalized) {n : ℕ} (hn : 0 < n) : ∃! g : Normalized, g ^ n = f := by
  obtain ⟨v, hv, huniq⟩ := OneUnit.existsUnique_pow (mulEquivOneUnit f) hn
  refine ⟨mulEquivOneUnit.symm v, ?_, ?_⟩
  · show mulEquivOneUnit.symm v ^ n = f
    rw [← map_pow, hv, MulEquiv.symm_apply_apply]
  · intro g hg
    have : mulEquivOneUnit g = v :=
      huniq _ (show mulEquivOneUnit g ^ n = mulEquivOneUnit f by rw [← map_pow, hg])
    rw [← this, MulEquiv.symm_apply_apply]

/-- The group of normalized `q`-series is torsion free. -/
theorem pow_eq_one_iff (f : Normalized) {n : ℕ} (hn : 0 < n) : f ^ n = 1 ↔ f = 1 := by
  constructor
  · intro h
    have hv : mulEquivOneUnit f ^ n = 1 := by rw [← map_pow, h, map_one]
    have := (OneUnit.pow_eq_one_iff _ hn).mp hv
    simpa using congrArg mulEquivOneUnit.symm this
  · rintro rfl; simp

end Normalized

/-- The group of normalized `q`-series is rootable (divisible): every element has
an `n`-th root for every `n ≠ 0`. -/
noncomputable instance instRootableByNormalizedNat : RootableBy Normalized ℕ where
  root f n := if hn : 0 < n then (Normalized.existsUnique_pow f hn).choose else 1
  root_zero f := by simp
  root_cancel := by
    intro n f hn
    have hpos : 0 < n := Nat.pos_of_ne_zero hn
    rw [dif_pos hpos]
    exact (Normalized.existsUnique_pow f hpos).choose_spec.1

/-! ## 4. Concrete Laurent form of the root -/

/-- **Existence and uniqueness of `q`-corrected roots.** For a normalized `f`
and `n ≥ 1` there is exactly one normalized `g` with `q^{n-1} · gⁿ = f`. -/
theorem existsUnique_star_root {f : LC} (hf : IsNormalized f) {n : ℕ} (hn : 0 < n) :
    ∃! g : LC, IsNormalized g ∧
      HahnSeries.single ((n : ℤ) - 1) (1 : ℂ) * g ^ n = f := by
  obtain ⟨G, hG, huniq⟩ := Normalized.existsUnique_pow ⟨f, hf⟩ hn
  refine ⟨G.val, ⟨G.isNormalized_val, ?_⟩, ?_⟩
  · rw [← Normalized.val_pow, hG]
  · rintro g ⟨hg, hgn⟩
    have : (⟨g, hg⟩ : Normalized) = G := by
      apply huniq
      apply Normalized.ext
      rw [Normalized.val_pow, hgn]
    exact congrArg Normalized.val this

/-! ## 5. Monstrous Moonshine: the geometric mean of the McKay–Thompson series -/

/-- **Unique `194`-th root of the Monster-sized corrected product.**  The
`q`-corrected product `q^{193} ∏_g T_g` of the `194` McKay–Thompson-shaped
series is normalized, hence has exactly one normalized `⋆`-`194`-th root: the
"geometric mean" of the Monster's trace series exists and is unique. -/
theorem existsUnique_moonshine_root (c : Fin monsterClassCount → ℕ → ℂ) :
    ∃! g : LC, IsNormalized g ∧
      HahnSeries.single (193 : ℤ) (1 : ℂ) * g ^ 194
        = HahnSeries.single (193 : ℤ) (1 : ℂ) * ∏ i, traceLaurent (c i) := by
  have hnorm := isNormalized_moonshine_corrected c
  have := existsUnique_star_root hnorm (n := 194) (by norm_num)
  simpa using this

end NormalizedQSeries