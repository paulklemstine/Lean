/-
# The systolic functional on the moduli space of tori

`Geometry.Teichmuller.Systole` proves the two *pointwise* halves of Hermite's bound: every
marked torus has a nonzero lattice vector with `|m + n τ|² ≤ (2/√3) · Im τ`, and the hexagonal
torus `ρ` has none shorter than `(2/√3) · Im ρ`.  `Geometry.Teichmuller.ConeSeparation` proves
that each individual function `Q_{m,n}(τ) = |m + n τ|² / Im τ` is log-`1`-Lipschitz for the
hyperbolic metric and is permuted by the mapping class group.

This file assembles these into the **systolic functional** itself,

    sys τ  =  min { |m + n τ|² / Im τ  :  (m, n) ∈ ℤ² \ {0} } ,

which requires knowing that the minimum is *attained*.  That is exactly the properness of the
lattice quadratic form proved in `Geometry.Teichmuller.ProperAction`
(`Teichmuller.finite_normSq_le`).  Main results:

* `Teichmuller.exists_isLeast_latticeValues`, `Teichmuller.sys_isLeast` : the infimum is a
  minimum, attained at an explicit nonzero lattice vector;
* `Teichmuller.sys_pos`, `Teichmuller.sys_le_hermite` : `0 < sys τ ≤ 2/√3`;
* `Teichmuller.sys_smul` : `sys` is invariant under the mapping class group, hence a genuine
  function on the moduli space;
* `Teichmuller.sys_rho = 2/√3`, `Teichmuller.sys_I = 1` : the values at the two orbifold points,
  giving a second, purely functional proof that they lie in different orbits
  (`Teichmuller.smul_rho_ne_I_of_sys`);
* `Teichmuller.log_sys_div_le_moduliDist` : `log (sys z / sys w) ≤ 2 · moduliDist z w` — the
  systolic functional is log-`2`-Lipschitz *on the moduli space*, i.e. it descends to the
  quotient and is a metric invariant there;
* `Teichmuller.sys_le_one_div_im`, `Teichmuller.exists_sys_lt` : the cusp — `sys` takes
  arbitrarily small positive values;
* `Teichmuller.moduliDist_unbounded` : consequently the **moduli space has infinite diameter**,
  the quantitative form of noncompactness.

-- !-- Lab Notes -- !--
Hypothesizer (C3): `sys` should be a proper exhaustion of the moduli space with maximum `2/√3`
at `ρ`; a first testable consequence is that the moduli space is unbounded for `moduliDist`.
Experimenter: attainment of the minimum is the only missing analytic ingredient, and it is a
corollary of `finite_normSq_le`: the values `≤ 1/Im τ` come from the finitely many integer pairs
with `|m + n τ|² ≤ 1`.  With the minimum attained, `moduliDist_pos_of_systole_gap` applies with
`r = sys z`, `s = sys w` and yields the Lipschitz estimate in one line.
Analyst: the estimate `log (sys z / sys w) ≤ 2 · moduliDist z w` unifies three previously
separate facts: separation of the two cone points (`sys ρ ≠ sys i`), the existence of the cusp
(`sys → 0`), and unboundedness of the moduli space (compose the two).  Note the constant: `2`
appears because `teichDist` is *half* the hyperbolic distance.
Critic: `sys` is defined as an `sInf` of a set of reals, so all statements must be guarded by
the attainment lemma; every result below is stated in terms of `IsLeast`, never merely `sInf`,
so no statement is vacuous through an empty or unbounded index set.  The values `2/√3 > 1` are
compared by an explicit inequality on `√3`, not by `norm_num` on decimals.
-/
import Mathlib
import Geometry.Teichmuller.ProperAction

namespace Teichmuller

open Complex UpperHalfPlane Matrix MatrixGroups

/-- The normalized squared length `Q_{m,n}(τ) = |m + n τ|² / Im τ` of the lattice vector
`m + n τ` of the marked torus `τ`. -/
noncomputable def latticeValue (tau : ℍ) (m n : ℤ) : ℝ :=
  Complex.normSq ((m : ℂ) + (n : ℂ) * (tau : ℂ)) / tau.im

/-- The set of normalized squared lengths of the *nonzero* lattice vectors of `τ`. -/
def latticeValues (tau : ℍ) : Set ℝ :=
  {r | ∃ m n : ℤ, (m ≠ 0 ∨ n ≠ 0) ∧ r = latticeValue tau m n}

theorem latticeValue_one_zero (tau : ℍ) : latticeValue tau 1 0 = 1 / tau.im := by
  simp [latticeValue]

theorem latticeValue_pos (tau : ℍ) {m n : ℤ} (h : m ≠ 0 ∨ n ≠ 0) : 0 < latticeValue tau m n := by
  have h1 : Complex.normSq ((m : ℂ) + (n : ℂ) * (tau : ℂ)) ≠ 0 := by
    simpa using normSq_lattice_ne_zero tau m n h
  have h2 : 0 < Complex.normSq ((m : ℂ) + (n : ℂ) * (tau : ℂ)) :=
    lt_of_le_of_ne (Complex.normSq_nonneg _) (Ne.symm h1)
  exact div_pos h2 tau.im_pos

/-! ### The minimum is attained -/

/-- **The systole is attained.**  Among the nonzero lattice vectors of a marked torus there is a
shortest one; equivalently the set `latticeValues τ` has a least element. -/
theorem exists_isLeast_latticeValues (tau : ℍ) :
    ∃ m n : ℤ, (m ≠ 0 ∨ n ≠ 0) ∧ IsLeast (latticeValues tau) (latticeValue tau m n) := by
  classical
  set T : Set (ℤ × ℤ) :=
    {q : ℤ × ℤ | (q.1 ≠ 0 ∨ q.2 ≠ 0) ∧ latticeValue tau q.1 q.2 ≤ latticeValue tau 1 0} with hT
  -- `T` is finite: its elements have `|m + n τ|² ≤ 1`
  have hTfin : T.Finite := by
    have hfin := finite_normSq_le tau 1
    have hmap : (fun q : ℤ × ℤ => (![q.2, q.1] : Fin 2 → ℤ)) '' T ⊆
        {p : Fin 2 → ℤ | Complex.normSq ((p 0 : ℂ) * (tau : ℂ) + (p 1 : ℂ)) ≤ 1} := by
      rintro _ ⟨⟨m, n⟩, hq, rfl⟩
      have hle : latticeValue tau m n ≤ 1 / tau.im := by
        simpa [latticeValue_one_zero] using hq.2
      have him : 0 < tau.im := tau.im_pos
      have : Complex.normSq ((m : ℂ) + (n : ℂ) * (tau : ℂ)) ≤ 1 := by
        rw [latticeValue, div_le_div_iff₀ him him] at hle
        nlinarith [him]
      simpa [Matrix.cons_val_zero, Matrix.cons_val_one, add_comm, mul_comm] using this
    have hinj : Set.InjOn (fun q : ℤ × ℤ => (![q.2, q.1] : Fin 2 → ℤ)) T := by
      rintro ⟨m, n⟩ - ⟨m', n'⟩ - h
      have h0 : n = n' := by simpa using congrFun h 0
      have h1 : m = m' := by simpa using congrFun h 1
      simp [h0, h1]
    exact Set.Finite.of_finite_image (hfin.subset hmap) hinj
  have hTne : T.Nonempty := ⟨(1, 0), by simp [hT]⟩
  obtain ⟨q0, hq0T, hq0min⟩ :=
    Set.exists_min_image T (fun q : ℤ × ℤ => latticeValue tau q.1 q.2) hTfin hTne
  refine ⟨q0.1, q0.2, hq0T.1, ⟨⟨q0.1, q0.2, hq0T.1, rfl⟩, ?_⟩⟩
  rintro r ⟨m, n, hmn, rfl⟩
  by_cases hle : latticeValue tau m n ≤ latticeValue tau 1 0
  · exact hq0min (m, n) ⟨hmn, hle⟩
  · push_neg at hle
    exact le_trans hq0T.2 hle.le

/-- The systolic functional of a marked torus: the least normalized squared length of a nonzero
lattice vector.  By `Teichmuller.sys_isLeast` this infimum is a minimum. -/
noncomputable def sys (tau : ℍ) : ℝ := sInf (latticeValues tau)

theorem sys_isLeast (tau : ℍ) : IsLeast (latticeValues tau) (sys tau) := by
  obtain ⟨m, n, hmn, hleast⟩ := exists_isLeast_latticeValues tau
  rw [sys, hleast.csInf_eq]
  exact hleast

/-- The systole is realized by an explicit nonzero lattice vector. -/
theorem exists_sys_eq (tau : ℍ) :
    ∃ m n : ℤ, (m ≠ 0 ∨ n ≠ 0) ∧ sys tau = latticeValue tau m n := by
  obtain ⟨m, n, hmn, hr⟩ := (sys_isLeast tau).1
  exact ⟨m, n, hmn, hr⟩

/-- Minimality: no nonzero lattice vector is shorter than the systole. -/
theorem sys_le (tau : ℍ) {m n : ℤ} (h : m ≠ 0 ∨ n ≠ 0) : sys tau ≤ latticeValue tau m n :=
  (sys_isLeast tau).2 ⟨m, n, h, rfl⟩

theorem sys_pos (tau : ℍ) : 0 < sys tau := by
  obtain ⟨m, n, hmn, hr⟩ := exists_sys_eq tau
  rw [hr]
  exact latticeValue_pos tau hmn

/-- Reformulation of minimality as a lower bound on squared lengths. -/
theorem sys_mul_im_le (tau : ℍ) {m n : ℤ} (h : m ≠ 0 ∨ n ≠ 0) :
    sys tau * tau.im ≤ Complex.normSq ((m : ℂ) + (n : ℂ) * (tau : ℂ)) := by
  have := sys_le tau h
  rw [latticeValue, le_div_iff₀ tau.im_pos] at this
  exact this

/-! ### Invariance under the mapping class group -/

theorem latticeValues_smul (g : SL(2, ℤ)) (tau : ℍ) :
    latticeValues (g • tau) = latticeValues tau := by
  have key : ∀ (h : SL(2, ℤ)) (t : ℍ), latticeValues (h • t) ⊆ latticeValues t := by
    rintro h t r ⟨m, n, hmn, rfl⟩
    refine ⟨m * (h : Matrix (Fin 2) (Fin 2) ℤ) 1 1 + n * (h : Matrix (Fin 2) (Fin 2) ℤ) 0 1,
      m * (h : Matrix (Fin 2) (Fin 2) ℤ) 1 0 + n * (h : Matrix (Fin 2) (Fin 2) ℤ) 0 0,
      index_ne_zero_smul h m n hmn, ?_⟩
    simpa [latticeValue] using normSq_ratio_smul h t m n
  refine Set.Subset.antisymm (key g tau) ?_
  have h2 := key g⁻¹ (g • tau)
  rwa [inv_smul_smul] at h2

/-- **The systolic functional is a mapping class group invariant**, so it is a well-defined
function on the moduli space of tori. -/
theorem sys_smul (g : SL(2, ℤ)) (tau : ℍ) : sys (g • tau) = sys tau := by
  rw [sys, sys, latticeValues_smul]

/-! ### Values: Hermite's constant and the two orbifold points -/

/-- **Hermite's bound.** The systolic functional is bounded above by `γ₂ = 2/√3`. -/
theorem sys_le_hermite (tau : ℍ) : sys tau ≤ 2 / Real.sqrt 3 := by
  obtain ⟨m, n, hmn, hle⟩ := exists_short_lattice_vector tau
  refine le_trans (sys_le tau hmn) ?_
  rw [latticeValue, div_le_iff₀ tau.im_pos]
  exact hle

/-- The hexagonal torus attains Hermite's constant: `sys ρ = 2/√3`. -/
theorem sys_rho : sys rho = 2 / Real.sqrt 3 := by
  have hsq3 : (0:ℝ) < Real.sqrt 3 := Real.sqrt_pos.mpr (by norm_num)
  have hrhoim : rho.im = Real.sqrt 3 / 2 := rfl
  refine le_antisymm (sys_le_hermite rho) ?_
  obtain ⟨m, n, hmn, hr⟩ := exists_sys_eq rho
  rw [hr, latticeValue, le_div_iff₀ rho.im_pos]
  have h := le_normSq_rho m n hmn
  have hval : 2 / Real.sqrt 3 * rho.im = 1 := by
    rw [hrhoim]
    field_simp
  rw [hval] at h
  have h2 : 2 / Real.sqrt 3 * rho.im = 1 := by rw [hrhoim]; field_simp
  linarith [h, h2]

/-- The square torus has systolic ratio `1`. -/
theorem sys_I : sys UpperHalfPlane.I = 1 := by
  have hIim : (UpperHalfPlane.I : ℍ).im = 1 := by simp [UpperHalfPlane.I]
  refine le_antisymm ?_ ?_
  · have h := sys_le (UpperHalfPlane.I) (m := 1) (n := 0) (Or.inl one_ne_zero)
    rwa [latticeValue_one_zero, hIim, div_one] at h
  · obtain ⟨m, n, hmn, hr⟩ := exists_sys_eq UpperHalfPlane.I
    rw [hr, latticeValue, hIim, div_one]
    have hns : Complex.normSq ((m : ℂ) + (n : ℂ) * (UpperHalfPlane.I : ℂ))
        = (m : ℝ) ^ 2 + (n : ℝ) ^ 2 := by
      simp [Complex.normSq_apply, UpperHalfPlane.I]
      ring
    rw [hns]
    have : 1 ≤ m ^ 2 + n ^ 2 := by
      rcases hmn with h | h
      · rcases lt_or_gt_of_ne h with h' | h' <;> nlinarith [sq_nonneg n]
      · rcases lt_or_gt_of_ne h with h' | h' <;> nlinarith [sq_nonneg m]
    exact_mod_cast this

/-- `1 < 2/√3`: the square torus is *not* extremal for the systolic functional. -/
theorem one_lt_hermite : (1:ℝ) < 2 / Real.sqrt 3 := by
  have hsq3 : (0:ℝ) < Real.sqrt 3 := Real.sqrt_pos.mpr (by norm_num)
  have h3 : Real.sqrt 3 < 2 := by
    nlinarith [Real.sq_sqrt (show (0:ℝ) ≤ 3 by norm_num), Real.sqrt_nonneg 3]
  rw [lt_div_iff₀ hsq3]
  linarith

/-- A second proof, purely by means of the invariant `sys`, that the hexagonal and square tori
lie in different mapping class group orbits. -/
theorem smul_rho_ne_I_of_sys (g : SL(2, ℤ)) : g • rho ≠ UpperHalfPlane.I := by
  intro h
  have h1 : sys (g • rho) = sys UpperHalfPlane.I := by rw [h]
  rw [sys_smul, sys_rho, sys_I] at h1
  exact absurd h1.symm (ne_of_lt one_lt_hermite)

/-! ### The systolic functional is Lipschitz on the moduli space -/

/-- **`log sys` is `2`-Lipschitz for the moduli distance.**  Since `sys` is a mapping class group
invariant, this says the systolic ratio is a Lipschitz function on the moduli space itself. -/
theorem log_sys_div_le_moduliDist (z w : ℍ) (hzw : sys w ≤ sys z) :
    Real.log (sys z / sys w) ≤ 2 * moduliDist z w := by
  obtain ⟨m, n, hmn, hr⟩ := exists_sys_eq w
  have hw : ∃ m n : ℤ, (m ≠ 0 ∨ n ≠ 0) ∧
      Complex.normSq ((m : ℂ) + (n : ℂ) * (w : ℂ)) ≤ sys w * w.im := by
    refine ⟨m, n, hmn, ?_⟩
    rw [hr, latticeValue, div_mul_cancel₀]
    exact ne_of_gt w.im_pos
  have hz : ∀ m n : ℤ, (m ≠ 0 ∨ n ≠ 0) →
      sys z * z.im ≤ Complex.normSq ((m : ℂ) + (n : ℂ) * (z : ℂ)) :=
    fun m n h => sys_mul_im_le z h
  have := moduliDist_pos_of_systole_gap z w (sys_pos w) hzw hz hw
  linarith

/-- Two tori with different systolic ratios are at positive moduli distance — a quantitative
separation statement on the moduli space. -/
theorem moduliDist_pos_of_sys_lt {z w : ℍ} (h : sys w < sys z) : 0 < moduliDist z w := by
  have hlog : 0 < Real.log (sys z / sys w) :=
    Real.log_pos ((one_lt_div (sys_pos w)).mpr h)
  have := log_sys_div_le_moduliDist z w h.le
  linarith

/-! ### The cusp and infinite diameter -/

/-- Tall tori are thin: `sys τ ≤ 1 / Im τ`. -/
theorem sys_le_one_div_im (tau : ℍ) : sys tau ≤ 1 / tau.im := by
  have h := sys_le tau (m := 1) (n := 0) (Or.inl one_ne_zero)
  rwa [latticeValue_one_zero] at h

/-- On the cusp region the systolic functional is *exactly* `1 / Im τ`: for a tall torus the
shortest lattice vector is the horizontal one. -/
theorem sys_eq_one_div_im (tau : ℍ) (h : 1 ≤ tau.im) : sys tau = 1 / tau.im := by
  refine le_antisymm (sys_le_one_div_im tau) ?_
  obtain ⟨m, n, hmn, hr⟩ := exists_sys_eq tau
  rw [hr, latticeValue, le_div_iff₀ tau.im_pos, div_mul_eq_mul_div, one_mul,
    div_self (ne_of_gt tau.im_pos)]
  have hns : Complex.normSq ((m : ℂ) + (n : ℂ) * (tau : ℂ))
      = ((m : ℝ) + (n : ℝ) * tau.re) ^ 2 + ((n : ℝ) * tau.im) ^ 2 := by
    simp [Complex.normSq_apply, UpperHalfPlane.coe_re, UpperHalfPlane.coe_im]
    ring
  rw [hns]
  rcases eq_or_ne n 0 with hn0 | hn0
  · have hm0 : m ≠ 0 := by
      rcases hmn with hm | hn
      · exact hm
      · exact absurd hn0 hn
    have hm1 : (1:ℝ) ≤ ((m : ℝ)) ^ 2 := by
      have : (1:ℤ) ≤ m ^ 2 := by
        rcases lt_or_gt_of_ne hm0 with h' | h' <;> nlinarith
      exact_mod_cast this
    rw [hn0]
    push_cast
    nlinarith
  · have hn1 : (1:ℝ) ≤ ((n : ℝ)) ^ 2 := by
      have : (1:ℤ) ≤ n ^ 2 := by
        rcases lt_or_gt_of_ne hn0 with h' | h' <;> nlinarith
      exact_mod_cast this
    have hy1 : (1:ℝ) ≤ tau.im ^ 2 := by nlinarith [tau.im_pos]
    have hone : (1:ℝ) ≤ ((n : ℝ) * tau.im) ^ 2 := by
      calc (1:ℝ) = 1 * 1 := by ring
        _ ≤ (n : ℝ) ^ 2 * tau.im ^ 2 := mul_le_mul hn1 hy1 zero_le_one (by positivity)
        _ = ((n : ℝ) * tau.im) ^ 2 := by ring
    linarith [sq_nonneg ((m : ℝ) + (n : ℝ) * tau.re)]

/-- **The cusp.**  The systolic functional takes arbitrarily small positive values, so the
moduli space is not compact. -/
theorem exists_sys_lt {eps : ℝ} (heps : 0 < eps) : ∃ tau : ℍ, 0 < sys tau ∧ sys tau < eps := by
  refine ⟨⟨⟨0, 2 / eps⟩, by positivity⟩, sys_pos _, ?_⟩
  have him : (⟨⟨0, 2 / eps⟩, by positivity⟩ : ℍ).im = 2 / eps := rfl
  have h := sys_le_one_div_im (⟨⟨0, 2 / eps⟩, by positivity⟩ : ℍ)
  rw [him] at h
  have : 1 / (2 / eps) = eps / 2 := by field_simp
  rw [this] at h
  linarith

/-- **The moduli space of tori has infinite diameter.**  For every bound `M` there is a marked
torus whose distance in the moduli space to the hexagonal torus exceeds `M`. -/
theorem moduliDist_unbounded (M : ℝ) : ∃ tau : ℍ, M < moduliDist rho tau := by
  have hsq3 : (0:ℝ) < Real.sqrt 3 := Real.sqrt_pos.mpr (by norm_num)
  set eps : ℝ := 2 / Real.sqrt 3 * Real.exp (-(2 * M + 2)) with heps
  have hepspos : 0 < eps := by
    have : 0 < Real.exp (-(2 * M + 2)) := Real.exp_pos _
    positivity
  obtain ⟨tau, hpos, hlt⟩ := exists_sys_lt hepspos
  refine ⟨tau, ?_⟩
  have hsysle : sys tau ≤ sys rho := by
    rw [sys_rho]
    exact sys_le_hermite tau
  have hkey := log_sys_div_le_moduliDist rho tau hsysle
  have hratio : Real.exp (2 * M + 2) ≤ sys rho / sys tau := by
    rw [sys_rho, le_div_iff₀ hpos]
    have h1 : sys tau * Real.exp (2 * M + 2) ≤ eps * Real.exp (2 * M + 2) :=
      mul_le_mul_of_nonneg_right hlt.le (Real.exp_pos _).le
    have h2 : eps * Real.exp (2 * M + 2) = 2 / Real.sqrt 3 := by
      rw [heps, mul_assoc, ← Real.exp_add, show -(2 * M + 2) + (2 * M + 2) = 0 by ring,
        Real.exp_zero, mul_one]
    nlinarith [h1, h2]
  have hlog : 2 * M + 2 ≤ Real.log (sys rho / sys tau) := by
    have hdivpos : 0 < sys rho / sys tau := div_pos (sys_pos rho) hpos
    have := Real.log_le_log (Real.exp_pos (2 * M + 2)) hratio
    rwa [Real.log_exp] at this
  linarith

end Teichmuller