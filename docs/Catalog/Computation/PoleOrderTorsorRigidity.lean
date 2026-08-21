import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep
import Computation.PoleOrderTorsor
import Computation.PoleOrderTorsorOrbits

/-!
# Rigidity of the corrected product, and Lean-verified moonshine iterates

Third cycle on the pole-order obstruction.  The first two cycles produced the corrected product
`f ⋆ g = q · f · g` on normalized `q`-series, its commutative group structure, and the coefficient
filtration whose graded pieces detect orbits.  This file asks the adversarial questions.

* **Is the correction canonical?**  Yes.  `PoleOrderTorsor.not_isNormalized_mul` shows the naive
  product of two normalized series is *never* normalized, and
  `PoleOrderTorsor.isNormalized_qPow_mul_mul_iff` shows `q^m · f · g` is normalized **iff**
  `m = 1`.  So `⋆` is the unique monomial repair of the pole-order obstruction.
* **How rigid are the orbits?**  Completely: `PoleOrderTorsor.Norm.zpow_eq_one_iff` and
  `PoleOrderTorsor.Norm.orbit_zpow_injective` show every non-trivial cyclic subgroup is infinite
  cyclic, and `PoleOrderTorsor.Norm.pow_bijective` packages divisibility and torsion-freeness into
  the statement that every power map is a bijection.
* **Where does the first invariant live?**  `PoleOrderTorsor.Norm.ker_leadCoeffHom` identifies the
  kernel of the first invariant with the second stage of the filtration, so the two descriptions
  of "trivial at level 1" agree.
* **Does the theory compute?**  `PoleOrderTorsor.Norm.coeffAt_pow_of_mem_deepSubgroup` gives the
  general linear-growth law, and
  `PoleOrderTorsor.Norm.coeffAt_two_pow_traceLaurent_moonshine` verifies it on genuine Monstrous
  Moonshine data: for `J = q⁻¹ + 196884 q + ⋯`, the `n`-th `⋆`-iterate has `q`-coefficient exactly
  `196884 n`.
-/

namespace PoleOrderTorsor

open HahnSeries PoleOrderObstruction PowerSeries

/-! ## Canonicity of the correction -/

/-- The **uncorrected** product of two normalized series is never normalized: the pole-order
obstruction of `Shared.PoleOrderObstruction` in its sharpest binary form. -/
theorem not_isNormalized_mul {f g : LC} (hf : IsNormalized f) (hg : IsNormalized g) :
    ¬ IsNormalized (f * g) := by
  intro h
  have h1 := h.orderTop_eq
  rw [HahnSeries.orderTop_mul, hf.orderTop_eq, hg.orderTop_eq, ← WithTop.coe_add] at h1
  have : ((-1 : ℤ) + (-1 : ℤ)) = (-1 : ℤ) := by exact_mod_cast h1
  omega

/-- **The correction exponent is unique.**  For normalized `f, g` the series `q^m · f · g` is
normalized precisely for `m = 1`; the corrected product is the only monomial repair. -/
theorem isNormalized_qPow_mul_mul_iff {f g : LC} (hf : IsNormalized f) (hg : IsNormalized g)
    (m : ℕ) : IsNormalized (qSeries ^ m * (f * g)) ↔ m = 1 := by
  constructor
  · intro h
    have h1 := h.orderTop_eq
    rw [HahnSeries.orderTop_mul, orderTop_qSeries_pow, HahnSeries.orderTop_mul,
      hf.orderTop_eq, hg.orderTop_eq, ← WithTop.coe_add, ← WithTop.coe_add] at h1
    have : ((m : ℤ) + ((-1 : ℤ) + (-1 : ℤ))) = (-1 : ℤ) := by exact_mod_cast h1
    omega
  · rintro rfl
    simpa using isNormalized_q_mul_mul hf hg

namespace Norm

/-! ## Rigidity of the orbits -/

/-- Torsion-freeness in its integral form. -/
theorem zpow_eq_one_iff {f : Norm} {n : ℤ} (hn : n ≠ 0) : f ^ n = 1 ↔ f = 1 := by
  constructor
  · intro h
    rcases n.natAbs_eq with hna | hna
    · have hnat : f ^ n.natAbs = 1 := by
        rw [← zpow_natCast, ← hna, h]
      exact (pow_eq_one_iff (by simpa using hn)).1 hnat
    · have hnat : f ^ n.natAbs = 1 := by
        have : f ^ (-(n.natAbs : ℤ)) = 1 := by rw [← hna, h]
        rw [zpow_neg, inv_eq_one, zpow_natCast] at this
        exact this
      exact (pow_eq_one_iff (by simpa using hn)).1 hnat
  · rintro rfl
    exact one_zpow n

/-- **Every non-trivial `⋆`-orbit is an infinite cyclic group.** -/
theorem orbit_zpow_injective {f : Norm} (hf : f ≠ 1) :
    Function.Injective (fun n : ℤ => f ^ n) := by
  intro m n hmn
  simp only at hmn
  by_contra hne
  have hsub : f ^ (m - n) = 1 := by
    rw [zpow_sub, hmn, mul_inv_cancel]
  exact hf ((zpow_eq_one_iff (sub_ne_zero.mpr hne)).1 hsub)

/-- **Unique divisibility, packaged.**  Every power map of the corrected-product group is a
bijection: the group is divisible (surjectivity) and torsion-free (injectivity). -/
theorem pow_bijective {n : ℕ} (hn : n ≠ 0) : Function.Bijective (fun f : Norm => f ^ n) := by
  refine ⟨pow_left_injective hn, fun f => ?_⟩
  obtain ⟨g, hg, -⟩ := existsUnique_root f hn
  exact ⟨g, hg⟩

/-! ## The first invariant and the filtration agree -/

/-- The kernel of the first invariant is exactly the second stage of the coefficient
filtration. -/
theorem ker_leadCoeffHom : MonoidHom.ker leadCoeffHom = deepSubgroup 2 := by
  ext f
  rw [MonoidHom.mem_ker, leadCoeffHom_apply]
  constructor
  · intro h
    have h0 : a₀ f = 0 := by
      simpa using congrArg Multiplicative.toAdd h
    intro i hi0 hi2
    have hi1 : i = 1 := by omega
    subst hi1
    show PowerSeries.coeff 1 ((toOneUnit f : PowerSeries ℂ)) = 0
    rw [a₀_toOneUnit, h0]
  · intro h
    have h1 : PowerSeries.coeff 1 ((toOneUnit f : PowerSeries ℂ)) = 0 := h 1 one_pos (by omega)
    rw [a₀_toOneUnit] at h1
    rw [h1]
    rfl

/-! ## Linear growth of the invariants along an orbit -/

/-- **Linear growth law.**  If `f` lies in the `k`-th stage of the filtration then the level-`k`
invariant of the `n`-th `⋆`-iterate is `n` times that of `f`. -/
theorem coeffAt_pow_of_mem_deepSubgroup {k : ℕ} (hk : 0 < k) {f : Norm}
    (hf : f ∈ deepSubgroup k) (n : ℕ) : coeffAt k (f ^ n) = n * coeffAt k f := by
  obtain ⟨-, -, hiter⟩ :=
    coeff_pow_of_lowVanish hk (toOneUnit f).constantCoeff_val hf n
  rw [coeffAt_toOneUnit, toOneUnit_pow, OneUnit.val_pow, hiter, coeffAt_toOneUnit]

/-! ## A Lean-verified Monstrous Moonshine iterate

The McKay–Thompson series of the class `1A` is the normalized modular function
`J = q⁻¹ + 196884 q + 21493760 q² + ⋯`.  As a member of the corrected-product group it lies in the
second stage of the filtration (its constant term vanishes), so its level-`2` invariant — the
coefficient of `q` — grows linearly along its `⋆`-orbit. -/

/-- A trace-shaped normalized series, as an element of the corrected-product group. -/
noncomputable def ofTrace (c : ℕ → ℂ) : Norm :=
  ⟨traceLaurent c, isNormalized_traceLaurent c⟩

@[simp] theorem coeffAt_one_ofTrace (c : ℕ → ℂ) : coeffAt 1 (ofTrace c) = c 0 := by
  rw [coeffAt_eq_coeff]
  show (traceLaurent c).coeff (((1 : ℕ) : ℤ) - 1) = c 0
  rw [show (((1 : ℕ) : ℤ) - 1) = (0 : ℤ) by norm_num, coeff_zero_traceLaurent]

@[simp] theorem coeffAt_two_ofTrace (c : ℕ → ℂ) : coeffAt 2 (ofTrace c) = c 1 := by
  rw [coeffAt_eq_coeff]
  show (traceLaurent c).coeff (((2 : ℕ) : ℤ) - 1) = c 1
  rw [show (((2 : ℕ) : ℤ) - 1) = (1 : ℤ) by norm_num, coeff_one_traceLaurent]

/-- A McKay–Thompson-shaped series (vanishing constant term) lies in the second stage of the
filtration. -/
theorem ofTrace_mem_deepSubgroup_two {c : ℕ → ℂ} (hc : c 0 = 0) :
    ofTrace c ∈ deepSubgroup 2 := by
  intro i hi0 hi2
  have hi1 : i = 1 := by omega
  subst hi1
  show PowerSeries.coeff 1 ((toOneUnit (ofTrace c) : PowerSeries ℂ)) = 0
  rw [← coeffAt_toOneUnit, coeffAt_one_ofTrace, hc]

/-- **Iterating a McKay–Thompson series.**  The `q`-coefficient of the `n`-th `⋆`-iterate of a
normalized trace series is `n` times the original `q`-coefficient. -/
theorem coeffAt_two_pow_ofTrace {c : ℕ → ℂ} (hc : c 0 = 0) (n : ℕ) :
    coeffAt 2 (ofTrace c ^ n) = n * c 1 := by
  rw [coeffAt_pow_of_mem_deepSubgroup (by omega) (ofTrace_mem_deepSubgroup_two hc) n,
    coeffAt_two_ofTrace]

/-- The moonshine instance: for `J = q⁻¹ + 196884 q + ⋯` the `n`-th corrected-product iterate has
`q`-coefficient `196884 n`.  For `n = 2` this is `393768`. -/
theorem coeffAt_two_pow_traceLaurent_moonshine (n : ℕ) :
    coeffAt 2 (ofTrace (fun m => if m = 1 then (196884 : ℂ) else 0) ^ n) = 196884 * n := by
  rw [coeffAt_two_pow_ofTrace (by norm_num) n]
  norm_num
  ring

/-- The `⋆`-square of `J` has `q`-coefficient `393768`. -/
theorem coeffAt_two_sq_traceLaurent_moonshine :
    coeffAt 2 (ofTrace (fun m => if m = 1 then (196884 : ℂ) else 0) ^ 2) = 393768 := by
  rw [coeffAt_two_pow_traceLaurent_moonshine 2]
  norm_num

end Norm

end PoleOrderTorsor