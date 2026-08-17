/-
# The mapping class group, the moduli space of tori, and its degeneracies

The mapping class group of the torus is `SL(2, ℤ)`, acting on the Teichmüller space `ℍ` of
marked tori by change of marking, i.e. by Möbius transformations.  The moduli space of tori is
the quotient `ℍ / SL(2, ℤ)`, whose (pseudo-)distance is

    d_M (τ, τ') = inf over the mapping class group of d_T (τ, g · τ') .

This file proves:

* `Teichmuller.teichDist_smul` : **the mapping class group acts by isometries** of the
  Teichmüller metric — the property that makes the moduli distance well defined;
* `Teichmuller.moduliDist_comm`, `moduliDist_triangle`, `moduliDist_nonneg`,
  `moduliDist_smul_left`, `moduliDist_smul_right` : the moduli distance is a
  mapping-class-group-invariant pseudometric on `ℍ`, i.e. a genuine distance on the quotient;
* `Teichmuller.moduliDist_self_smul` and `Teichmuller.exists_ne_moduliDist_eq_zero` :
  the moduli distance is *only* a pseudometric on `ℍ`: distinct marked tori can be
  isomorphic as unmarked tori — the quotient is nontrivial;
* `Teichmuller.exists_nontrivial_stabilizer` : **the action is not free**: the square root of
  `-1` in `SL(2, ℤ)` fixes the square torus `i` and is nontrivial even modulo `±1`; hence the
  moduli space is an orbifold, not a manifold, and the quotient map is not a covering;
* `Teichmuller.exists_order_three_stabilizer` and `Teichmuller.smul_rho_ne_I` : the hexagonal
  torus `ρ = -1/2 + i√3/2` carries a stabiliser of order **three** in `PSL(2, ℤ)`, and
  `Teichmuller.sq_eq_one_of_smul_I_eq` shows the stabiliser of `i` has order **two**; hence the
  two cone points lie in different orbits and the moduli space has at least two distinct
  orbifold singularities, of cone angles `π` and `2π/3`;
* `Teichmuller.teichDist_T_pos` together with `Teichmuller.exists_teichDist_T_lt` :
  the parabolic mapping class `T : τ ↦ τ + 1` has **zero translation length which is not
  attained** — the quantitative source of the noncompactness of the moduli space
  (its "cusp"), in sharp contrast with the Anosov classes of
  `Geometry.Teichmuller.TranslationLength`, whose translation length is positive and attained.

-- !-- Lab Notes -- !--
Hypothesizer: the three Nielsen–Thurston types (elliptic / parabolic / Anosov) should be
*visible in the metric* on Teichmüller space: fixed point, infimum-zero-not-attained, and
positive-attained respectively.
Experimenter: the displacement identity `cosh_dist_smul` computes all three at once.  For
`S = !![0,-1;1,0]` (trace `0`) the displacement vanishes at `i`; for `T = !![1,1;0,1]`
(trace `2`) it equals `arcosh (1 + 1/(2y²)) > 0`, tending to `0` as `y → ∞`; for trace `> 2`
it is bounded below by `arcosh ((t²-2)/2) > 0`.  Analyst: the three cases are exactly
`|tr| < 2`, `= 2`, `> 2` — the metric geometry of the moduli space is governed by the trace,
and the failure of properness at the cusp is the parabolic case.
Critic: "the action is not free" is weaker than "the orbifold has two distinct cone points" —
the latter needs the stabiliser of `i` computed exactly.  Experimenter: solving `g · i = i`
over `ℤ` forces `a = d`, `b = -c`, hence `a² + c² = det g = 1`, whose only integral solutions
are the four points `(±1, 0), (0, ±1)`; all four square to `±1`.  Conjugating the order-three
stabiliser of `ρ` into the stabiliser of `i` therefore yields a contradiction, so the two cone
points are distinct in moduli.
-/
import Mathlib
import Geometry.Teichmuller.TranslationLength

namespace Teichmuller

open Complex UpperHalfPlane Matrix MatrixGroups

variable (τ τ' τ'' : ℍ)

/-- The `SL(2, ℤ)`-action on `ℍ` is the restriction of the `SL(2, ℝ)`-action. -/
theorem int_smul_eq (g : SL(2, ℤ)) (z : ℍ) :
    g • z = (Matrix.SpecialLinearGroup.map (Int.castRingHom ℝ) g) • z := by
  apply UpperHalfPlane.ext
  rw [UpperHalfPlane.coe_specialLinearGroup_apply, UpperHalfPlane.coe_specialLinearGroup_apply]
  simp

/-- The mapping class group acts by isometries of the hyperbolic metric. -/
theorem dist_int_smul (g : SL(2, ℤ)) (z w : ℍ) : dist (g • z) (g • w) = dist z w := by
  rw [int_smul_eq g z, int_smul_eq g w]
  exact dist_smul _ _ _

/-- **The mapping class group acts by isometries of the Teichmüller metric.** -/
theorem teichDist_smul (g : SL(2, ℤ)) : teichDist (g • τ) (g • τ') = teichDist τ τ' := by
  rw [teichDist_eq_half_dist, teichDist_eq_half_dist, dist_int_smul]

/-- The distance on the moduli space `ℍ / SL(2, ℤ)` of tori, as a function on `ℍ`. -/
noncomputable def moduliDist : ℝ := ⨅ g : SL(2, ℤ), teichDist τ (g • τ')

theorem moduliDist_bddBelow : BddBelow (Set.range fun g : SL(2, ℤ) => teichDist τ (g • τ')) := by
  refine ⟨0, ?_⟩
  rintro r ⟨g, rfl⟩
  exact teichDist_nonneg _ _

theorem moduliDist_nonneg : 0 ≤ moduliDist τ τ' :=
  le_ciInf fun _ => teichDist_nonneg _ _

theorem moduliDist_le (g : SL(2, ℤ)) : moduliDist τ τ' ≤ teichDist τ (g • τ') :=
  ciInf_le (moduliDist_bddBelow τ τ') g

theorem moduliDist_le_teichDist : moduliDist τ τ' ≤ teichDist τ τ' := by
  have := moduliDist_le τ τ' 1
  simpa using this

/-- Right invariance under the mapping class group. -/
theorem moduliDist_smul_right (h : SL(2, ℤ)) : moduliDist τ (h • τ') = moduliDist τ τ' := by
  have hfun : ∀ g : SL(2, ℤ), teichDist τ (g • (h • τ')) = teichDist τ ((g * h) • τ') := by
    intro g; rw [SemigroupAction.mul_smul]
  simp only [moduliDist, hfun]
  exact (Equiv.mulRight h).iInf_comp (g := fun k : SL(2, ℤ) => teichDist τ (k • τ'))

/-- Left invariance under the mapping class group. -/
theorem moduliDist_smul_left (h : SL(2, ℤ)) : moduliDist (h • τ) τ' = moduliDist τ τ' := by
  have hfun : ∀ g : SL(2, ℤ), teichDist (h • τ) (g • τ') = teichDist τ ((h⁻¹ * g) • τ') := by
    intro g
    rw [SemigroupAction.mul_smul, ← teichDist_smul τ ((h⁻¹ • (g • τ' : ℍ))) h, smul_inv_smul]
  simp only [moduliDist, hfun]
  exact (Equiv.mulLeft h⁻¹).iInf_comp (g := fun k : SL(2, ℤ) => teichDist τ (k • τ'))

/-- Marked tori in the same mapping class group orbit are at moduli distance zero: they are the
same point of the moduli space. -/
theorem moduliDist_self_smul (h : SL(2, ℤ)) : moduliDist τ (h • τ) = 0 := by
  refine le_antisymm ?_ (moduliDist_nonneg _ _)
  have h1 : moduliDist τ (h • τ) = moduliDist τ τ := moduliDist_smul_right τ τ h
  have h2 : moduliDist τ τ ≤ teichDist τ τ := moduliDist_le_teichDist τ τ
  rw [(teichDist_eq_zero_iff τ τ).mpr rfl] at h2
  rw [h1]
  exact h2

theorem moduliDist_comm : moduliDist τ τ' = moduliDist τ' τ := by
  have key : ∀ (a b : ℍ) (g : SL(2, ℤ)), teichDist a (g • b) = teichDist b (g⁻¹ • a) := by
    intro a b g
    rw [teichDist_comm, ← teichDist_smul (g • b) a g⁻¹, inv_smul_smul]
  have h1 : moduliDist τ τ' = ⨅ g : SL(2, ℤ), teichDist τ' (g⁻¹ • τ) := by
    simp only [moduliDist]
    exact iInf_congr fun g => key τ τ' g
  rw [h1, moduliDist]
  exact (Equiv.inv (SL(2, ℤ))).iInf_comp (g := fun k : SL(2, ℤ) => teichDist τ' (k • τ))

theorem moduliDist_triangle : moduliDist τ τ'' ≤ moduliDist τ τ' + moduliDist τ' τ'' := by
  have step : ∀ g h : SL(2, ℤ),
      moduliDist τ τ'' ≤ teichDist τ (g • τ') + teichDist τ' (h • τ'') := by
    intro g h
    have h1 : teichDist τ ((g * h) • τ'') ≤ teichDist τ (g • τ') + teichDist (g • τ') ((g * h) • τ'')
      := teichDist_triangle τ (g • τ') ((g * h) • τ'')
    have h2 : teichDist (g • τ') ((g * h) • τ'') = teichDist τ' (h • τ'') := by
      rw [SemigroupAction.mul_smul, teichDist_smul]
    calc moduliDist τ τ'' ≤ teichDist τ ((g * h) • τ'') := moduliDist_le _ _ _
      _ ≤ teichDist τ (g • τ') + teichDist τ' (h • τ'') := by rw [h2] at h1; exact h1
  have step2 : ∀ g : SL(2, ℤ),
      moduliDist τ τ'' - teichDist τ (g • τ') ≤ moduliDist τ' τ'' := by
    intro g
    refine le_ciInf fun h => ?_
    have := step g h
    linarith
  have step3 : ∀ g : SL(2, ℤ),
      moduliDist τ τ'' - moduliDist τ' τ'' ≤ teichDist τ (g • τ') := by
    intro g
    have := step2 g
    linarith
  have hinf := le_ciInf step3
  have hdef : moduliDist τ τ' = ⨅ x : SL(2, ℤ), teichDist τ (x • τ') := rfl
  rw [← hdef] at hinf
  linarith

/-- The moduli distance is a genuine *pseudo*metric and not a metric on `ℍ`: the translate
`τ ↦ τ + 1` gives distinct marked tori that are isomorphic as unmarked tori. -/
theorem exists_ne_moduliDist_eq_zero :
    ∃ σ σ' : ℍ, σ ≠ σ' ∧ moduliDist σ σ' = 0 := by
  refine ⟨UpperHalfPlane.I, ModularGroup.T • UpperHalfPlane.I, ?_, moduliDist_self_smul _ _⟩
  rw [UpperHalfPlane.modular_T_smul]
  intro h
  have : (UpperHalfPlane.I : ℂ) = ((1 : ℝ) + UpperHalfPlane.I : ℂ) := by
    rw [← UpperHalfPlane.coe_vadd]
    exact congrArg _ h
  simp [UpperHalfPlane.I] at this

/-- **The action of the mapping class group is not free.**  The class of `S = !![0,-1;1,0]`
fixes the square torus `i`, and is nontrivial even modulo the kernel `{±1}` of the action.
Consequently the moduli space of tori is an orbifold with an order-two point at `i`. -/
theorem exists_nontrivial_stabilizer :
    ∃ g : SL(2, ℤ), g • UpperHalfPlane.I = UpperHalfPlane.I ∧ g ≠ 1 ∧ g ≠ -1 := by
  refine ⟨ModularGroup.S, ?_, ?_, ?_⟩
  · rw [UpperHalfPlane.modular_S_smul]
    apply UpperHalfPlane.ext
    simp [UpperHalfPlane.I, Complex.inv_def, Complex.normSq_apply]
  · intro h
    have h00 := congrArg (fun M : SL(2, ℤ) => (M : Matrix (Fin 2) (Fin 2) ℤ) 0 0) h
    simp [ModularGroup.S] at h00
  · intro h
    have h00 := congrArg (fun M : SL(2, ℤ) => (M : Matrix (Fin 2) (Fin 2) ℤ) 0 0) h
    simp [ModularGroup.S] at h00

section Parabolic

/-- The displacement of the parabolic class `T : τ ↦ τ + 1`. -/
theorem cosh_dist_T (σ : ℍ) :
    Real.cosh (dist σ (ModularGroup.T • σ)) = 1 + 1 / (2 * σ.im ^ 2) := by
  have h := cosh_dist_smul ModularGroup.T σ
  have hentry : entry ModularGroup.T 0 0 = 1 ∧ entry ModularGroup.T 0 1 = 1 ∧
      entry ModularGroup.T 1 0 = 0 ∧ entry ModularGroup.T 1 1 = 1 := by
    refine ⟨?_, ?_, ?_, ?_⟩ <;> simp [entry, ModularGroup.T]
  have htr : tr ModularGroup.T = 2 := by
    simp [tr, hentry.1, hentry.2.2.2]
    norm_num
  rw [htr, hentry.1, hentry.2.1, hentry.2.2.1, hentry.2.2.2] at h
  rw [h]
  ring

/-- **Parabolic classes have positive displacement everywhere.** -/
theorem teichDist_T_pos (σ : ℍ) : 0 < teichDist σ (ModularGroup.T • σ) := by
  have hy : 0 < σ.im := σ.im_pos
  have hc : 1 < Real.cosh (dist σ (ModularGroup.T • σ)) := by
    rw [cosh_dist_T]
    have : 0 < 1 / (2 * σ.im ^ 2) := by positivity
    linarith
  have hne : dist σ (ModularGroup.T • σ) ≠ 0 := Real.one_lt_cosh.mp hc
  have : 0 < dist σ (ModularGroup.T • σ) := lt_of_le_of_ne dist_nonneg (Ne.symm hne)
  rw [teichDist_eq_half_dist]
  linarith

/-- **... but the infimum of the parabolic displacement is zero**: it is not attained.  This is
the cusp of the moduli space of tori, and the reason the moduli space is not compact. -/
theorem exists_teichDist_T_lt {ε : ℝ} (hε : 0 < ε) :
    ∃ σ : ℍ, teichDist σ (ModularGroup.T • σ) < ε := by
  have hc : 1 < Real.cosh ε := Real.one_lt_cosh.mpr hε.ne'
  set c := Real.cosh ε - 1 with hcdef
  have hcpos : 0 < c := by simp only [hcdef]; linarith
  set y := Real.sqrt (1 / c) + 1 with hydef
  have hy1 : 1 ≤ y := by
    have := Real.sqrt_nonneg (1 / c)
    simp only [hydef]; linarith
  have hypos : 0 < y := lt_of_lt_of_le one_pos hy1
  have hysq : 1 / c < y ^ 2 := by
    have h1 : Real.sqrt (1 / c) ^ 2 = 1 / c := Real.sq_sqrt (by positivity)
    have h2 : Real.sqrt (1 / c) < y := by simp only [hydef]; linarith
    have h3 : 0 ≤ Real.sqrt (1 / c) := Real.sqrt_nonneg _
    nlinarith
  refine ⟨⟨⟨0, y⟩, hypos⟩, ?_⟩
  set σ : ℍ := ⟨⟨0, y⟩, hypos⟩ with hσ
  have hσim : σ.im = y := rfl
  have hcosh : Real.cosh (dist σ (ModularGroup.T • σ)) < Real.cosh ε := by
    rw [cosh_dist_T, hσim]
    have hkey : 1 / (2 * y ^ 2) < c := by
      rw [div_lt_iff₀ (by positivity)]
      have : 1 / c < y ^ 2 := hysq
      rw [div_lt_iff₀ hcpos] at this
      nlinarith
    simp only [hcdef] at hkey
    linarith
  have hlt : dist σ (ModularGroup.T • σ) < ε := by
    have := Real.cosh_lt_cosh.mp hcosh
    rwa [abs_of_nonneg dist_nonneg, abs_of_pos hε] at this
  rw [teichDist_eq_half_dist]
  linarith

end Parabolic

section EllipticOrderThree

/-- The hexagonal torus `ρ = e^{2πi/3} = -1/2 + i√3/2`, the second corner of the standard
fundamental domain of the modular group. -/
noncomputable def rho : ℍ :=
  ⟨⟨-1 / 2, Real.sqrt 3 / 2⟩, by
    have : (0 : ℝ) < Real.sqrt 3 := Real.sqrt_pos.mpr (by norm_num)
    simp⟩

/-- The elliptic class `ST : τ ↦ -1/(τ + 1)` fixes the hexagonal torus. -/
theorem smul_rho : (ModularGroup.S * ModularGroup.T) • rho = rho := by
  rw [SemigroupAction.mul_smul, UpperHalfPlane.modular_T_smul, UpperHalfPlane.modular_S_smul]
  apply UpperHalfPlane.ext
  have h3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have key : ((rho : ℂ) + 1) * (rho : ℂ) = -1 := by
    apply Complex.ext <;> simp [rho] <;> nlinarith [h3]
  simp only [UpperHalfPlane.coe_vadd]
  push_cast
  exact inv_eq_of_mul_eq_one_left (by linear_combination -key)

/-- The only integral solutions of `a² + c² = 1`. -/
theorem int_sq_add_sq_eq_one {a c : ℤ} (h : a ^ 2 + c ^ 2 = 1) :
    (a = 1 ∧ c = 0) ∨ (a = -1 ∧ c = 0) ∨ (a = 0 ∧ c = 1) ∨ (a = 0 ∧ c = -1) := by
  have i1 : -1 ≤ a := by nlinarith [sq_nonneg c, sq_nonneg (a + 1)]
  have i2 : a ≤ 1 := by nlinarith [sq_nonneg c, sq_nonneg (a - 1)]
  have i3 : -1 ≤ c := by nlinarith [sq_nonneg a, sq_nonneg (c + 1)]
  have i4 : c ≤ 1 := by nlinarith [sq_nonneg a, sq_nonneg (c - 1)]
  interval_cases a <;> interval_cases c <;> omega

/-- **The stabiliser of the square torus `i` has order two in `PSL(2, ℤ)`**: every element of
`SL(2, ℤ)` fixing `i` squares to `±1`. -/
theorem sq_eq_one_of_smul_I_eq (g : SL(2, ℤ)) (h : g • UpperHalfPlane.I = UpperHalfPlane.I) :
    g ^ 2 = 1 ∨ g ^ 2 = -1 := by
  have hdet : (g : Matrix (Fin 2) (Fin 2) ℤ) 0 0 * (g : Matrix (Fin 2) (Fin 2) ℤ) 1 1 -
      (g : Matrix (Fin 2) (Fin 2) ℤ) 0 1 * (g : Matrix (Fin 2) (Fin 2) ℤ) 1 0 = 1 := by
    have := g.property
    rwa [Matrix.det_fin_two] at this
  have h' : ((g • UpperHalfPlane.I : ℍ) : ℂ) = (UpperHalfPlane.I : ℂ) := by rw [h]
  rw [UpperHalfPlane.coe_specialLinearGroup_apply] at h'
  simp only [UpperHalfPlane.coe_I, algebraMap_int_eq, eq_intCast] at h'
  push_cast at h'
  have hd : (((g : Matrix (Fin 2) (Fin 2) ℤ) 1 0 : ℂ) * Complex.I +
      ((g : Matrix (Fin 2) (Fin 2) ℤ) 1 1 : ℂ)) ≠ 0 := by
    intro h0
    rw [Complex.ext_iff] at h0
    simp at h0
    obtain ⟨hd0, hc0⟩ := h0
    have h1 : (g : Matrix (Fin 2) (Fin 2) ℤ) 1 1 = 0 := by exact_mod_cast hd0
    have h2 : (g : Matrix (Fin 2) (Fin 2) ℤ) 1 0 = 0 := by exact_mod_cast hc0
    rw [h1, h2] at hdet; simp at hdet
  rw [div_eq_iff hd, Complex.ext_iff] at h'
  simp at h'
  have had : (g : Matrix (Fin 2) (Fin 2) ℤ) 0 0 = (g : Matrix (Fin 2) (Fin 2) ℤ) 1 1 := h'.2
  have hbc : (g : Matrix (Fin 2) (Fin 2) ℤ) 0 1 = -(g : Matrix (Fin 2) (Fin 2) ℤ) 1 0 := by
    exact_mod_cast h'.1
  rw [← had, hbc] at hdet
  have hsum : (g : Matrix (Fin 2) (Fin 2) ℤ) 0 0 ^ 2 +
      (g : Matrix (Fin 2) (Fin 2) ℤ) 1 0 ^ 2 = 1 := by nlinarith [hdet]
  rcases int_sq_add_sq_eq_one hsum with ⟨ha, hc⟩ | ⟨ha, hc⟩ | ⟨ha, hc⟩ | ⟨ha, hc⟩
  · left; apply Subtype.ext; ext i j
    fin_cases i <;> fin_cases j <;>
      simp [pow_two, Matrix.mul_apply, Fin.sum_univ_two, ← had, hbc, ha, hc]
  · left; apply Subtype.ext; ext i j
    fin_cases i <;> fin_cases j <;>
      simp [pow_two, Matrix.mul_apply, Fin.sum_univ_two, ← had, hbc, ha, hc]
  · right; apply Subtype.ext; ext i j
    fin_cases i <;> fin_cases j <;>
      simp [pow_two, Matrix.mul_apply, Fin.sum_univ_two, ← had, hbc, ha, hc]
  · right; apply Subtype.ext; ext i j
    fin_cases i <;> fin_cases j <;>
      simp [pow_two, Matrix.mul_apply, Fin.sum_univ_two, ← had, hbc, ha, hc]

/-- **A cone point of order three.**  The hexagonal torus `ρ` is fixed by a mapping class whose
image in `PSL(2, ℤ)` has order exactly three: `g³ = -1` while `g, g² ∉ {±1}`. -/
theorem exists_order_three_stabilizer :
    ∃ g : SL(2, ℤ), g • rho = rho ∧ g ^ 3 = -1 ∧ g ≠ 1 ∧ g ≠ -1 ∧ g ^ 2 ≠ 1 ∧ g ^ 2 ≠ -1 := by
  refine ⟨ModularGroup.S * ModularGroup.T, smul_rho, ?_, ?_, ?_, ?_, ?_⟩
  · apply Subtype.ext
    simp [ModularGroup.S, ModularGroup.T, pow_succ, Matrix.one_fin_two]
  · intro h
    have h00 := congrArg (fun M : SL(2, ℤ) => (M : Matrix (Fin 2) (Fin 2) ℤ) 0 0) h
    simp [ModularGroup.S, ModularGroup.T] at h00
  · intro h
    have h00 := congrArg (fun M : SL(2, ℤ) => (M : Matrix (Fin 2) (Fin 2) ℤ) 0 0) h
    simp [ModularGroup.S, ModularGroup.T] at h00
  · intro h
    have h01 := congrArg (fun M : SL(2, ℤ) => (M : Matrix (Fin 2) (Fin 2) ℤ) 0 1) h
    simp [ModularGroup.S, ModularGroup.T, pow_succ] at h01
  · intro h
    have h01 := congrArg (fun M : SL(2, ℤ) => (M : Matrix (Fin 2) (Fin 2) ℤ) 0 1) h
    simp [ModularGroup.S, ModularGroup.T, pow_succ] at h01

/-- **The two cone points are genuinely distinct points of the moduli space**: the hexagonal
torus `ρ` and the square torus `i` lie in different `SL(2, ℤ)`-orbits, since their stabilisers
in `PSL(2, ℤ)` have orders three and two respectively.  Hence the moduli space of tori carries
at least two distinct orbifold singularities. -/
theorem smul_rho_ne_I (g : SL(2, ℤ)) : g • rho ≠ UpperHalfPlane.I := by
  intro hg
  set U : SL(2, ℤ) := ModularGroup.S * ModularGroup.T with hU
  have hginv : g⁻¹ • UpperHalfPlane.I = rho := by rw [← hg, inv_smul_smul]
  have hfix : (g * U * g⁻¹) • UpperHalfPlane.I = UpperHalfPlane.I := by
    rw [SemigroupAction.mul_smul, SemigroupAction.mul_smul, hginv, hU, smul_rho, hg]
  have hconj : (g * U * g⁻¹) ^ 2 = g * U ^ 2 * g⁻¹ := by
    simp [pow_two, mul_assoc, inv_mul_cancel_left]
  have hsq := sq_eq_one_of_smul_I_eq _ hfix
  rw [hconj] at hsq
  have hback : U ^ 2 = g⁻¹ * (g * U ^ 2 * g⁻¹) * g := by
    simp [mul_assoc, inv_mul_cancel_left]
  have hentry : ((U ^ 2 : SL(2, ℤ)) : Matrix (Fin 2) (Fin 2) ℤ) 0 1 = -1 := by
    simp [hU, ModularGroup.S, ModularGroup.T, pow_succ]
  rcases hsq with h1 | h1 <;> rw [h1] at hback <;> simp at hback <;> rw [hback] at hentry <;>
    simp at hentry

end EllipticOrderThree

end Teichmuller