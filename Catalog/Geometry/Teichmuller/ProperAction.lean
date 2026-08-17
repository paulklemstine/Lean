/-
# Proper discontinuity of the mapping class group and the moduli metric

`Geometry.Teichmuller.ModuliSpace` defines the moduli pseudometric of the torus as the infimum

    moduliDist τ τ' = ⨅ g : SL(2, ℤ), teichDist τ (g • τ')

over the *infinite* mapping class group, and proves that it is a symmetric, invariant
pseudometric.  Two facts were left open there (conjecture **C4** of `FUTURE_DIRECTIONS.md`):
the infimum is a *minimum*, and its vanishing detects exactly the mapping class group orbit.
Both are consequences of a single geometric statement — the action is **properly
discontinuous** — which is what this file proves.

Main results:

* `Teichmuller.finite_smul_dist_le` : for all `z w : ℍ` and `R : ℝ` the set of mapping classes
  `g` with `dist z (g • w) ≤ R` is *finite*.  This is proper discontinuity in its sharpest
  ("uniformly finite orbit-intersection") form.
* `Teichmuller.finite_stabilizer` : consequently every stabilizer is a finite group, so the two
  orbifold points found in `ModuliSpace.lean` have finite (in fact cyclic of order `2` and `3`)
  local groups.
* `Teichmuller.exists_min_teichDist_orbit`, `Teichmuller.exists_moduliDist_eq` : the infimum
  defining `moduliDist` is attained; `moduliDist` is a *minimum* over the orbit.
* `Teichmuller.moduliDist_eq_zero_iff` : `moduliDist τ τ' = 0 ↔ ∃ g, g • τ' = τ`.  The kernel of
  the pseudometric is exactly the orbit equivalence relation, i.e. `moduliDist` descends to a
  genuine *metric* on the moduli space `ℍ / SL(2, ℤ)`.
* `Teichmuller.moduliDist_pos_of_not_orbit`, `Teichmuller.moduliDist_rho_I_pos'` : distinct
  points of the moduli space are at positive distance; in particular the two orbifold points
  are, re-deriving `ConeSeparation.moduliDist_rho_I_pos` from a soft argument.

-- !-- Lab Notes -- !--
Hypothesizer (C4): the infimum should be attained because the orbit of a point is discrete and
the hyperbolic balls are compact.
Experimenter: compactness is not needed at all.  The two elementary distance estimates
`im_le_im_mul_exp_dist` and `dist_coe_le` bound, for `dist z (g • w) ≤ R`, both
`normSq (c w + d) = w.im / (g • w).im` and `normSq (a w + b) = ‖g • w‖² · normSq (c w + d)`
by explicit constants; `ModularGroup.tendsto_normSq_coprime_pair` then says that only finitely
many integer pairs satisfy such a bound, and a matrix is its two rows.
Analyst: so proper discontinuity of `SL(2, ℤ)` on `ℍ` is *purely arithmetic* — properness of
the quadratic form `|c w + d|²` on `ℤ²` — and the metric input is only the two-sided comparison
of imaginary parts along a bounded hyperbolic displacement.  Note the argument bounds the whole
matrix, not just its bottom row: the top row is controlled because `‖g • w‖` is bounded, which
is exactly where the *lower* bound on `(g • w).im` (equivalently: `z` and `g • w` stay in a
compact part of `ℍ`) enters.
Critic: is `moduliDist_eq_zero_iff` vacuous?  No: the forward direction genuinely needs
attainment — an infimum of positive numbers can be `0` — and the reverse direction is the
already-proved invariance.  The corollary `moduliDist_rho_I_pos'` is checked against the
independently proved `moduliDist_rho_I_pos` of `ConeSeparation.lean`.
-/
import Mathlib
import Geometry.Teichmuller.ConeSeparation

namespace Teichmuller

open Complex UpperHalfPlane Matrix MatrixGroups Filter

/-! ### The two rows of a modular matrix -/

/-- The denominator `c w + d` of the Möbius action is nonzero. -/
theorem denom_int_ne_zero (g : SL(2, ℤ)) (w : ℍ) :
    ((g 1 0 : ℤ) : ℂ) * (w : ℂ) + ((g 1 1 : ℤ) : ℂ) ≠ 0 := by
  intro h
  have him : ((g 1 0 : ℤ) : ℝ) * w.im = 0 := by
    have := congrArg Complex.im h
    simpa [Complex.add_im, Complex.mul_im, UpperHalfPlane.coe_im, UpperHalfPlane.coe_re]
      using this
  have hre : ((g 1 0 : ℤ) : ℝ) * w.re + ((g 1 1 : ℤ) : ℝ) = 0 := by
    have := congrArg Complex.re h
    simpa [Complex.add_re, Complex.mul_re, UpperHalfPlane.coe_im, UpperHalfPlane.coe_re]
      using this
  have hc : ((g 1 0 : ℤ) : ℝ) = 0 := by
    rcases mul_eq_zero.mp him with h' | h'
    · exact h'
    · exact absurd h' (ne_of_gt w.im_pos)
  have hd : ((g 1 1 : ℤ) : ℝ) = 0 := by
    rw [hc] at hre; linarith
  have hc' : g 1 0 = 0 := by exact_mod_cast hc
  have hd' : g 1 1 = 0 := by exact_mod_cast hd
  have hdet : (g : Matrix (Fin 2) (Fin 2) ℤ).det = 1 := g.2
  rw [Matrix.det_fin_two, hc', hd'] at hdet
  simp at hdet

/-- `|c w + d|² · Im (g • w) = Im w`: the transformation rule for the imaginary part. -/
theorem normSq_denom_mul_im (g : SL(2, ℤ)) (w : ℍ) :
    normSq (((g 1 0 : ℤ) : ℂ) * (w : ℂ) + ((g 1 1 : ℤ) : ℂ)) * (g • w).im = w.im := by
  rw [ModularGroup.im_smul_eq_div_normSq]
  have h : denom (SpecialLinearGroup.toGL ((SpecialLinearGroup.map (Int.castRingHom ℝ)) g))
      (w : ℂ) = ((g 1 0 : ℤ) : ℂ) * (w : ℂ) + ((g 1 1 : ℤ) : ℂ) := by
    simp [UpperHalfPlane.denom]
  rw [h]
  have hne : normSq (((g 1 0 : ℤ) : ℂ) * (w : ℂ) + ((g 1 1 : ℤ) : ℂ)) ≠ 0 :=
    ne_of_gt (Complex.normSq_pos.mpr (denom_int_ne_zero g w))
  field_simp

/-- The numerator identity `(g • w) · (c w + d) = a w + b`. -/
theorem coe_smul_mul_denom (g : SL(2, ℤ)) (w : ℍ) :
    ((g • w : ℍ) : ℂ) * (((g 1 0 : ℤ) : ℂ) * (w : ℂ) + ((g 1 1 : ℤ) : ℂ))
      = ((g 0 0 : ℤ) : ℂ) * (w : ℂ) + ((g 0 1 : ℤ) : ℂ) := by
  rw [UpperHalfPlane.coe_specialLinearGroup_apply]
  simp only [algebraMap_int_eq, eq_intCast, Complex.ofReal_intCast]
  exact div_mul_cancel₀ _ (denom_int_ne_zero g w)

/-- `|a w + b|² = ‖g • w‖² · |c w + d|²`. -/
theorem normSq_num (g : SL(2, ℤ)) (w : ℍ) :
    normSq (((g 0 0 : ℤ) : ℂ) * (w : ℂ) + ((g 0 1 : ℤ) : ℂ))
      = normSq ((g • w : ℍ) : ℂ) * normSq (((g 1 0 : ℤ) : ℂ) * (w : ℂ) + ((g 1 1 : ℤ) : ℂ)) := by
  rw [← normSq_mul, coe_smul_mul_denom]

/-! ### Properness of the quadratic form `|c w + d|²` -/

/-- **Properness of the lattice form.** For each `w : ℍ` and each bound `C`, only finitely many
integer pairs `(m, n)` satisfy `|m w + n|² ≤ C`. -/
theorem finite_normSq_le (w : ℍ) (C : ℝ) :
    {p : Fin 2 → ℤ | normSq ((p 0 : ℂ) * (w : ℂ) + (p 1 : ℂ)) ≤ C}.Finite := by
  have h := (ModularGroup.tendsto_normSq_coprime_pair w).eventually (eventually_gt_atTop C)
  rw [Filter.eventually_cofinite] at h
  exact h.subset fun p hp => by simpa using not_lt.mpr hp

/-! ### Proper discontinuity -/

/-- **Proper discontinuity of the mapping class group action.** For any two marked tori `z`,
`w` and any bound `R`, only finitely many mapping classes move `w` to within hyperbolic
distance `R` of `z`. -/
theorem finite_smul_dist_le (z w : ℍ) (R : ℝ) :
    {g : SL(2, ℤ) | dist z (g • w) ≤ R}.Finite := by
  set N : ℝ := ‖(z : ℂ)‖ + z.im * Real.exp R * (Real.exp R - 1) with hN
  set C : ℝ := max (N ^ 2 * (w.im * Real.exp R / z.im)) (w.im * Real.exp R / z.im) with hC
  set A : Set (Fin 2 → ℤ) := {p | normSq ((p 0 : ℂ) * (w : ℂ) + (p 1 : ℂ)) ≤ C} with hA
  set f : SL(2, ℤ) → (Fin 2 → ℤ) × (Fin 2 → ℤ) :=
    fun g => (![g 0 0, g 0 1], ![g 1 0, g 1 1]) with hf
  have hinj : Function.Injective f := by
    intro g g' hgg
    have h0 : (![g 0 0, g 0 1] : Fin 2 → ℤ) = ![g' 0 0, g' 0 1] := congrArg Prod.fst hgg
    have h1 : (![g 1 0, g 1 1] : Fin 2 → ℤ) = ![g' 1 0, g' 1 1] := congrArg Prod.snd hgg
    have e00 : g 0 0 = g' 0 0 := by simpa using congrFun h0 0
    have e01 : g 0 1 = g' 0 1 := by simpa using congrFun h0 1
    have e10 : g 1 0 = g' 1 0 := by simpa using congrFun h1 0
    have e11 : g 1 1 = g' 1 1 := by simpa using congrFun h1 1
    apply Matrix.SpecialLinearGroup.ext
    intro i j
    fin_cases i <;> fin_cases j <;> assumption
  have hsub : f '' {g : SL(2, ℤ) | dist z (g • w) ≤ R} ⊆ A ×ˢ A := by
    rintro _ ⟨g, hg, rfl⟩
    have hdist : dist z (g • w) ≤ R := hg
    have hd0 : 0 ≤ dist z (g • w) := dist_nonneg
    have hR0 : 0 ≤ R := le_trans hd0 hdist
    have hexp : Real.exp (dist z (g • w)) ≤ Real.exp R := Real.exp_le_exp.mpr hdist
    -- upper bound on the imaginary part of `g • w`
    have him_up : (g • w).im ≤ z.im * Real.exp R := by
      have h1 : (g • w).im ≤ z.im * Real.exp (dist (g • w) z) :=
        im_le_im_mul_exp_dist (g • w) z
      have h2 : dist (g • w) z = dist z (g • w) := dist_comm _ _
      rw [h2] at h1
      exact h1.trans (by nlinarith [z.im_pos, Real.exp_pos (dist z (g • w))])
    -- lower bound on the imaginary part of `g • w`
    have him_lo : z.im ≤ (g • w).im * Real.exp R := by
      have h1 : z.im ≤ (g • w).im * Real.exp (dist z (g • w)) := im_le_im_mul_exp_dist z (g • w)
      nlinarith [(g • w).im_pos, Real.exp_pos (dist z (g • w))]
    have hexpR : (0:ℝ) < Real.exp R := Real.exp_pos R
    -- the bottom row is short
    have hden_pos : 0 < normSq (((g 1 0 : ℤ) : ℂ) * (w : ℂ) + ((g 1 1 : ℤ) : ℂ)) :=
      Complex.normSq_pos.mpr (denom_int_ne_zero g w)
    have hden : normSq (((g 1 0 : ℤ) : ℂ) * (w : ℂ) + ((g 1 1 : ℤ) : ℂ))
        ≤ w.im * Real.exp R / z.im := by
      have key := normSq_denom_mul_im g w
      have h1 : 0 < (g • w).im := (g • w).im_pos
      have h2 : normSq (((g 1 0 : ℤ) : ℂ) * (w : ℂ) + ((g 1 1 : ℤ) : ℂ)) = w.im / (g • w).im := by
        rw [eq_div_iff (ne_of_gt h1)]
        exact key
      rw [h2, div_le_div_iff₀ h1 z.im_pos]
      nlinarith [w.im_pos, z.im_pos, him_lo]
    -- the point `g • w` has bounded modulus
    have hnorm : ‖((g • w : ℍ) : ℂ)‖ ≤ N := by
      have h1 : dist (z : ℂ) ((g • w : ℍ) : ℂ) ≤ (g • w).im * (Real.exp (dist z (g • w)) - 1) :=
        dist_coe_le z (g • w)
      have h2 : (g • w).im * (Real.exp (dist z (g • w)) - 1)
          ≤ z.im * Real.exp R * (Real.exp R - 1) := by
        have he1 : (1:ℝ) ≤ Real.exp (dist z (g • w)) := Real.one_le_exp hd0
        nlinarith [(g • w).im_pos, z.im_pos]
      have h3 : ‖((g • w : ℍ) : ℂ)‖ ≤ ‖(z : ℂ)‖ + dist (z : ℂ) ((g • w : ℍ) : ℂ) := by
        have hsum := norm_add_le (z : ℂ) (((g • w : ℍ) : ℂ) - (z : ℂ))
        have hd : ‖((g • w : ℍ) : ℂ) - (z : ℂ)‖ = dist (z : ℂ) ((g • w : ℍ) : ℂ) := by
          rw [dist_eq_norm, ← norm_neg]
          congr 1
          ring
        rw [hd] at hsum
        simpa using hsum
      rw [hN]
      linarith
    have hnorm2 : normSq ((g • w : ℍ) : ℂ) ≤ N ^ 2 := by
      have h0 : ‖((g • w : ℍ) : ℂ)‖ ^ 2 = normSq ((g • w : ℍ) : ℂ) := by
        rw [Complex.sq_norm]
      have hnn : 0 ≤ ‖((g • w : ℍ) : ℂ)‖ := norm_nonneg _
      nlinarith
    have hNnonneg : 0 ≤ N := by
      have h1 : (1:ℝ) ≤ Real.exp R := Real.one_le_exp hR0
      have h2 : (0:ℝ) ≤ z.im * Real.exp R * (Real.exp R - 1) :=
        mul_nonneg (mul_nonneg z.im_pos.le (Real.exp_pos R).le) (by linarith)
      have h0 : (0:ℝ) ≤ ‖(z : ℂ)‖ := norm_nonneg _
      simp only [hN]
      linarith
    have hnum : normSq (((g 0 0 : ℤ) : ℂ) * (w : ℂ) + ((g 0 1 : ℤ) : ℂ))
        ≤ N ^ 2 * (w.im * Real.exp R / z.im) := by
      rw [normSq_num g w]
      have hq : 0 ≤ normSq ((g • w : ℍ) : ℂ) := normSq_nonneg _
      nlinarith [hden_pos, hnorm2, hden]
    constructor
    · show normSq _ ≤ C
      simpa [hf, hC] using le_trans hnum (le_max_left _ _)
    · show normSq _ ≤ C
      simpa [hf, hC] using le_trans hden (le_max_right _ _)
  have hfinA : A.Finite := finite_normSq_le w C
  have hfinim : (f '' {g : SL(2, ℤ) | dist z (g • w) ≤ R}).Finite :=
    Set.Finite.subset ((hfinA).prod hfinA) hsub
  exact Set.Finite.of_finite_image hfinim (Function.Injective.injOn hinj)

/-- **Every stabilizer is finite**: the local group of a point of the moduli space is finite. -/
theorem finite_stabilizer (z : ℍ) : {g : SL(2, ℤ) | g • z = z}.Finite := by
  refine Set.Finite.subset (finite_smul_dist_le z z 0) ?_
  intro g hg
  have h : g • z = z := hg
  show dist z (g • z) ≤ 0
  rw [h, dist_self]

/-! ### The infimum defining `moduliDist` is a minimum -/

/-- The Teichmüller distance from `z` to the orbit of `w` is *attained*. -/
theorem exists_min_teichDist_orbit (z w : ℍ) :
    ∃ g₀ : SL(2, ℤ), ∀ g : SL(2, ℤ), teichDist z (g₀ • w) ≤ teichDist z (g • w) := by
  set S : Set SL(2, ℤ) := {g : SL(2, ℤ) | dist z (g • w) ≤ dist z w} with hS
  have hfin : S.Finite := finite_smul_dist_le z w (dist z w)
  have hne : S.Nonempty := ⟨1, by simp [hS]⟩
  obtain ⟨g₀, hg₀S, hmin⟩ := Set.exists_min_image S (fun g => teichDist z (g • w)) hfin hne
  refine ⟨g₀, fun g => ?_⟩
  by_cases hg : g ∈ S
  · exact hmin g hg
  · have hgt : dist z w < dist z (g • w) := by
      simpa [hS, not_le] using hg
    have h1 : teichDist z (g₀ • w) ≤ teichDist z ((1 : SL(2, ℤ)) • w) := hmin 1 (by simp [hS])
    have h2 : teichDist z w < teichDist z (g • w) := by
      rw [teichDist_eq_half_dist, teichDist_eq_half_dist]
      linarith
    simp only [one_smul] at h1
    linarith

/-- The infimum defining the moduli distance is attained: `moduliDist` is a minimum over the
mapping class group orbit. -/
theorem exists_moduliDist_eq (z w : ℍ) :
    ∃ g : SL(2, ℤ), moduliDist z w = teichDist z (g • w) := by
  obtain ⟨g₀, hg₀⟩ := exists_min_teichDist_orbit z w
  exact ⟨g₀, le_antisymm (moduliDist_le z w g₀) (le_ciInf hg₀)⟩

/-! ### `moduliDist` is a metric on the moduli space -/

/-- **The kernel of the moduli pseudometric is exactly the mapping class group orbit
relation.**  Hence `moduliDist` descends to a genuine metric on the moduli space
`ℍ / SL(2, ℤ)` of tori. -/
theorem moduliDist_eq_zero_iff (z w : ℍ) :
    moduliDist z w = 0 ↔ ∃ g : SL(2, ℤ), g • w = z := by
  constructor
  · intro h
    obtain ⟨g, hg⟩ := exists_moduliDist_eq z w
    rw [h] at hg
    exact ⟨g, ((teichDist_eq_zero_iff z (g • w)).mp hg.symm).symm⟩
  · rintro ⟨g, rfl⟩
    rw [moduliDist_smul_left]
    have h := moduliDist_le_teichDist w w
    rw [(teichDist_eq_zero_iff w w).mpr rfl] at h
    exact le_antisymm h (moduliDist_nonneg w w)

/-- Distinct points of the moduli space are at positive distance. -/
theorem moduliDist_pos_of_not_orbit {z w : ℍ} (h : ∀ g : SL(2, ℤ), g • w ≠ z) :
    0 < moduliDist z w :=
  lt_of_le_of_ne (moduliDist_nonneg z w) fun hzero =>
    let ⟨g, hg⟩ := (moduliDist_eq_zero_iff z w).mp hzero.symm
    h g hg

/-- The two orbifold points of the moduli space are at positive distance — a soft re-derivation
of `Teichmuller.moduliDist_rho_I_pos` from proper discontinuity instead of from the systolic
functional. -/
theorem moduliDist_rho_I_pos' : 0 < moduliDist rho UpperHalfPlane.I := by
  refine moduliDist_pos_of_not_orbit fun g hg => smul_rho_ne_I g⁻¹ ?_
  rw [← hg, inv_smul_smul]

end Teichmuller