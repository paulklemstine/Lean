import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep
import Computation.PoleOrderTorsor
import Computation.PoleOrderTorsorOrbits
import Computation.PoleOrderTorsorRigidity

/-!
# One-parameter subgroups of the corrected-product group

Cycles 1–3 showed that the corrected product `f ⋆ g = q · f · g` turns normalized `q`-series into
a torsion-free, uniquely divisible abelian group, and that the invariant separating orbits is the
first level of the coefficient filtration, which grows *linearly* along an orbit.

This cycle explains **why** that linear growth is possible: the discrete orbit
`n ↦ f^{⋆n}` is the restriction to `ℤ` of a genuine **complex one-parameter subgroup**

`r ↦ f^{⋆ r}`,  `f^{⋆(r+s)} = f^{⋆r} ⋆ f^{⋆s}`,  `f^{⋆ n} = f^{⋆n}` for `n : ℕ`.

The construction substitutes `q·f - 1` into Mathlib's binomial series `(1 + X)^r`
(`PowerSeries.binomialSeries`, available because `ℂ` is a binomial ring), so it is *explicit*: no
choice is involved.  Consequences proved here:

* `PoleOrderTorsor.Norm.cpowHom` — a monoid homomorphism `Multiplicative ℂ →* Norm`, i.e. an
  action of the additive group `ℂ` on each orbit, refining the `ℤ`-orbit of cycle 2;
* `PoleOrderTorsor.Norm.cpow_natCast` — it interpolates the corrected-product iterates;
* `PoleOrderTorsor.Norm.cpow_inv_natCast_pow` — an **explicit** `n`-th root, matching the
  abstract unique root of `PoleOrderTorsor.Norm.existsUnique_root`;
* `PoleOrderTorsor.Norm.instRootableByNat` / `PoleOrderTorsor.Norm.rootableByInt` — the group is
  `RootableBy` over `ℕ` and over `ℤ` in Mathlib's sense: it is a divisible abelian group.
-/

namespace PoleOrderTorsor

open HahnSeries PoleOrderObstruction PowerSeries

/-! ## Substitution preserves the constant term -/

theorem constantCoeff_subst_eq {a f : PowerSeries ℂ} (ha : PowerSeries.constantCoeff a = 0) :
    PowerSeries.constantCoeff (PowerSeries.subst a f) = PowerSeries.constantCoeff f := by
  have hsub : PowerSeries.HasSubst a := PowerSeries.HasSubst.of_constantCoeff_zero' ha
  rw [show PowerSeries.constantCoeff (PowerSeries.subst a f)
      = MvPowerSeries.constantCoeff (PowerSeries.subst a f) from rfl,
    PowerSeries.constantCoeff_subst hsub]
  rw [finsum_eq_single _ 0 (fun d hd => by
    have : MvPowerSeries.constantCoeff ((a : PowerSeries ℂ) ^ d) = 0 := by
      rw [show MvPowerSeries.constantCoeff ((a : PowerSeries ℂ) ^ d)
          = PowerSeries.constantCoeff (a ^ d) from rfl, map_pow, ha, zero_pow hd]
    rw [this, smul_zero])]
  simp [PowerSeries.coeff_zero_eq_constantCoeff_apply]

/-! ## Complex powers of a one-unit -/

/-- The complex power `u^r` of a one-unit power series, defined by substituting `u - 1` into the
binomial series `(1 + X)^r`. -/
noncomputable def OneUnit.cpow (u : OneUnit) (r : ℂ) : OneUnit :=
  ⟨PowerSeries.subst ((u : PowerSeries ℂ) - 1) (PowerSeries.binomialSeries ℂ r), by
    rw [constantCoeff_subst_eq (by simp [u.constantCoeff_val]),
      PowerSeries.binomialSeries_constantCoeff]⟩

namespace OneUnit

theorem hasSubst_sub_one (u : OneUnit) : PowerSeries.HasSubst ((u : PowerSeries ℂ) - 1) :=
  PowerSeries.HasSubst.of_constantCoeff_zero' (by simp [u.constantCoeff_val])

@[simp] theorem val_cpow (u : OneUnit) (r : ℂ) :
    ((u.cpow r : OneUnit) : PowerSeries ℂ)
      = PowerSeries.subst ((u : PowerSeries ℂ) - 1) (PowerSeries.binomialSeries ℂ r) := rfl

/-- The exponent law: complex powers turn addition into multiplication. -/
theorem cpow_add (u : OneUnit) (r s : ℂ) : u.cpow (r + s) = u.cpow r * u.cpow s := by
  apply OneUnit.ext
  rw [val_cpow, OneUnit.val_mul, val_cpow, val_cpow, PowerSeries.binomialSeries_add,
    PowerSeries.subst_mul u.hasSubst_sub_one]

/-- Natural-number exponents recover ordinary powers. -/
theorem cpow_natCast (u : OneUnit) (n : ℕ) : u.cpow (n : ℂ) = u ^ n := by
  apply OneUnit.ext
  rw [val_cpow, PowerSeries.binomialSeries_nat, OneUnit.val_pow,
    PowerSeries.subst_pow u.hasSubst_sub_one, PowerSeries.subst_add u.hasSubst_sub_one,
    PowerSeries.subst_X u.hasSubst_sub_one,
    show PowerSeries.subst ((u : PowerSeries ℂ) - 1) (1 : PowerSeries ℂ) = 1 by
      rw [← PowerSeries.coe_substAlgHom u.hasSubst_sub_one, map_one]]
  ring_nf

@[simp] theorem cpow_zero (u : OneUnit) : u.cpow 0 = 1 := by
  simpa using cpow_natCast u 0

@[simp] theorem cpow_one (u : OneUnit) : u.cpow 1 = u := by
  simpa using cpow_natCast u 1

/-- Complex powers of complex powers, in the exponent: `(u^r)^n = u^{n r}`. -/
theorem cpow_pow (u : OneUnit) (r : ℂ) (n : ℕ) : (u.cpow r) ^ n = u.cpow ((n : ℂ) * r) := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [pow_succ, ih, ← cpow_add]
      congr 1
      push_cast
      ring

end OneUnit

namespace Norm

/-- The complex power `f^{⋆r}` of a normalized series, transported from one-unit coordinates. -/
noncomputable def cpow (f : Norm) (r : ℂ) : Norm :=
  normEquivOneUnit.symm ((toOneUnit f).cpow r)

theorem toOneUnit_cpow (f : Norm) (r : ℂ) : toOneUnit (cpow f r) = (toOneUnit f).cpow r :=
  normEquivOneUnit.apply_symm_apply _

/-- **The exponent law on normalized series.** -/
theorem cpow_add (f : Norm) (r s : ℂ) : cpow f (r + s) = cpow f r * cpow f s := by
  apply normEquivOneUnit.injective
  show toOneUnit (cpow f (r + s)) = toOneUnit (cpow f r * cpow f s)
  rw [toOneUnit_cpow, toOneUnit_mul, toOneUnit_cpow, toOneUnit_cpow, OneUnit.cpow_add]

/-- **Complex powers interpolate the corrected-product iterates.** -/
theorem cpow_natCast (f : Norm) (n : ℕ) : cpow f (n : ℂ) = f ^ n := by
  apply normEquivOneUnit.injective
  show toOneUnit (cpow f (n : ℂ)) = toOneUnit (f ^ n)
  rw [toOneUnit_cpow, toOneUnit_pow, OneUnit.cpow_natCast]

@[simp] theorem cpow_zero (f : Norm) : cpow f 0 = 1 := by
  simpa using cpow_natCast f 0

@[simp] theorem cpow_one (f : Norm) : cpow f 1 = f := by
  have := cpow_natCast f 1
  simpa using this

theorem cpow_pow (f : Norm) (r : ℂ) (n : ℕ) : (cpow f r) ^ n = cpow f ((n : ℂ) * r) := by
  apply normEquivOneUnit.injective
  show toOneUnit ((cpow f r) ^ n) = toOneUnit (cpow f ((n : ℂ) * r))
  rw [toOneUnit_pow, toOneUnit_cpow, toOneUnit_cpow, OneUnit.cpow_pow]

/-- **One-parameter subgroup.**  Every normalized series generates a homomorphism from the
additive group `ℂ` into the corrected-product group, whose restriction to `ℕ` is the orbit
`n ↦ f^{⋆n}`. -/
noncomputable def cpowHom (f : Norm) : Multiplicative ℂ →* Norm where
  toFun r := cpow f (Multiplicative.toAdd r)
  map_one' := by simp
  map_mul' r s := by
    show cpow f (Multiplicative.toAdd r + Multiplicative.toAdd s) = _
    rw [cpow_add]

@[simp] theorem cpowHom_apply (f : Norm) (r : Multiplicative ℂ) :
    cpowHom f r = cpow f (Multiplicative.toAdd r) := rfl

theorem cpowHom_ofAdd_natCast (f : Norm) (n : ℕ) :
    cpowHom f (Multiplicative.ofAdd (n : ℂ)) = f ^ n := by
  rw [cpowHom_apply]
  simpa using cpow_natCast f n

/-- **An explicit `n`-th root.**  `f^{⋆(1/n)}` is an `n`-th corrected-product root of `f`. -/
theorem cpow_inv_natCast_pow (f : Norm) {n : ℕ} (hn : n ≠ 0) :
    (cpow f ((n : ℂ)⁻¹)) ^ n = f := by
  have hn' : (n : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr hn
  rw [cpow_pow, mul_inv_cancel₀ hn', cpow_one]

/-- It agrees with the abstract unique root of cycle 2. -/
theorem cpow_inv_natCast_eq_root (f g : Norm) {n : ℕ} (hn : n ≠ 0) (hg : g ^ n = f) :
    g = cpow f ((n : ℂ)⁻¹) :=
  pow_left_injective hn (show g ^ n = (cpow f ((n : ℂ)⁻¹)) ^ n by
    rw [hg, cpow_inv_natCast_pow f hn])

/-- **Divisibility, explicitly.**  The corrected-product group is `ℕ`-rootable in Mathlib's
sense, with roots given by complex powers rather than by choice. -/
noncomputable instance instRootableByNat : RootableBy Norm ℕ where
  root f n := if n = 0 then 1 else cpow f ((n : ℂ)⁻¹)
  root_zero f := by simp
  root_cancel {n} f hn := by
    rw [if_neg hn]
    exact cpow_inv_natCast_pow f hn

/-- Hence also `ℤ`-rootable: a divisible abelian group. -/
noncomputable def rootableByInt : RootableBy Norm ℤ :=
  Group.rootableByIntOfRootableByNat Norm

end Norm

/-! ## The complex parameter is faithful -/

/-- If all coefficients of `w` below `k` vanish then all coefficients of `w ^ d` below `d * k`
vanish: orders add under multiplication. -/
theorem coeff_pow_eq_zero_of_lt {w : PowerSeries ℂ} {k : ℕ}
    (hw : ∀ i, i < k → PowerSeries.coeff i w = 0) (d : ℕ) :
    ∀ i, i < d * k → PowerSeries.coeff i (w ^ d) = 0 := by
  induction d with
  | zero => intro i hi; omega
  | succ d ih =>
      intro m hm
      rw [pow_succ, PowerSeries.coeff_mul]
      refine Finset.sum_eq_zero ?_
      rintro ⟨x, y⟩ hxy
      rw [Finset.mem_antidiagonal] at hxy
      rcases Nat.lt_or_ge x (d * k) with hx | hx
      · rw [ih x hx, zero_mul]
      · have hy : y < k := by
          have : (d + 1) * k = d * k + k := by ring
          omega
        rw [hw y hy, mul_zero]

/-- **The complex power scales the first invariant.**  If the one-unit `u` is `k`-deep then the
level-`k` coefficient of `u ^ r` is `r` times that of `u`: the discrete law
`coeff k (u ^ n) = n · coeff k u` extends to all complex exponents. -/
theorem coeff_cpow_of_lowVanish {u : OneUnit} {k : ℕ} (hk : 0 < k)
    (hlow : LowVanish k (u : PowerSeries ℂ)) (r : ℂ) :
    PowerSeries.coeff k ((u.cpow r : OneUnit) : PowerSeries ℂ)
      = r * PowerSeries.coeff k (u : PowerSeries ℂ) := by
  set w : PowerSeries ℂ := (u : PowerSeries ℂ) - 1 with hw
  have hsub : PowerSeries.HasSubst w := u.hasSubst_sub_one
  have hwlow : ∀ i, i < k → PowerSeries.coeff i w = 0 := by
    intro i hi
    rcases Nat.eq_zero_or_pos i with rfl | hi0
    · rw [hw, map_sub, PowerSeries.coeff_zero_eq_constantCoeff_apply,
        PowerSeries.coeff_zero_eq_constantCoeff_apply, u.constantCoeff_val, map_one, sub_self]
    · rw [hw, map_sub, hlow i hi0 hi, PowerSeries.coeff_one, if_neg (by omega), sub_zero]
  have hwk : PowerSeries.coeff k w = PowerSeries.coeff k (u : PowerSeries ℂ) := by
    rw [hw, map_sub, PowerSeries.coeff_one, if_neg (by omega), sub_zero]
  rw [OneUnit.val_cpow, ← hw, PowerSeries.coeff_subst' hsub]
  rw [finsum_eq_single _ 1 ?_]
  · rw [pow_one, hwk, PowerSeries.binomialSeries_coeff, Ring.choose_one_right]
    simp [smul_eq_mul]
  · intro d hd
    rcases Nat.eq_zero_or_pos d with rfl | hd0
    · rw [pow_zero, PowerSeries.coeff_one, if_neg (by omega), smul_zero]
    · have hd2 : 2 ≤ d := by omega
      have hlt : k < d * k := by nlinarith
      rw [coeff_pow_eq_zero_of_lt hwlow d k hlt, smul_zero]

namespace Norm

/-- The same statement on normalized series: the level-`k` invariant is `ℂ`-linear in the
exponent. -/
theorem coeffAt_cpow {f : Norm} {k : ℕ} (hk : 0 < k) (hf : f ∈ deepSubgroup k) (r : ℂ) :
    coeffAt k (cpow f r) = r * coeffAt k f := by
  rw [coeffAt_toOneUnit, toOneUnit_cpow, coeff_cpow_of_lowVanish hk hf r, coeffAt_toOneUnit]

/-- **The one-parameter subgroup is faithful.**  For `f ≠ q⁻¹` the map `r ↦ f^{⋆r}` is injective,
so each non-trivial `⋆`-orbit contains a copy of the additive group `ℂ`. -/
theorem cpow_injective {f : Norm} (hf : f ≠ 1) : Function.Injective (cpow f) := by
  obtain ⟨k, hk0, hlow, hne, -⟩ := first_invariant hf
  have hmem : f ∈ deepSubgroup k := hlow
  intro r s hrs
  have h := congrArg (coeffAt k) hrs
  rw [coeffAt_cpow hk0 hmem, coeffAt_cpow hk0 hmem] at h
  exact mul_right_cancel₀ hne h

/-- Packaged: every normalized series other than the base point lies on a faithful complex
one-parameter subgroup of the corrected-product group. -/
theorem exists_injective_oneParameter {f : Norm} (hf : f ≠ 1) :
    ∃ φ : Multiplicative ℂ →* Norm, Function.Injective φ ∧ φ (Multiplicative.ofAdd 1) = f := by
  refine ⟨cpowHom f, ?_, ?_⟩
  · intro r s hrs
    have := cpow_injective hf (a₁ := Multiplicative.toAdd r) (a₂ := Multiplicative.toAdd s) hrs
    exact Multiplicative.toAdd.injective this
  · rw [cpowHom_apply]
    simp

end Norm

end PoleOrderTorsor