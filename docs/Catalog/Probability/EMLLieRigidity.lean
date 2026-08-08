import Probability.EMLExpLogDuality

/-!
# Rigidity of the EML generator algebra: representations and vector fields

This file is the next cycle of the research thread started in
`Catalog/Probability/EMLExpLogDuality.lean` (the infinitesimal side of the EML
exp–log duality) and `Catalog/Probability/EMLScalingGroupDuality.lean` (the
global side).  It closes, in concrete and fully proved form, two of the
conjectures recorded in `FUTURE_DIRECTIONS.md`.

## Conjecture 4: no faithful representation by skew-symmetric matrices

The relation `⁅D, T⁆ = T` is an *eigenvector* relation for `ad D` with nonzero
eigenvalue.  In a representation `ρ` the matrix `B = ρ T` therefore satisfies
`A B - B A = B` with `A = ρ D`.  We prove three consequences, all elementary but
none formal triviality:

* `trace_lie_mul_self` / `skew_shift_eq_zero` : if in addition `B` is
  skew-symmetric then `B = 0`.  Hence `no_faithful_skew_representation`: the EML
  algebra has **no faithful representation by skew-symmetric real matrices** —
  it is not the Lie algebra of a compact group, and the pure-scaling generator
  can never be realized by an infinitesimal rotation.
* `shift_trace_pow_eq_zero` : all power traces `tr(B^k)`, `k ≥ 1`, vanish, so
  `B` is "trace-nilpotent" in every finite-dimensional representation.
* `shift_det_not_isUnit` : `B` is singular in every representation of positive
  dimension.  (The proof is a one-line trace obstruction: invertibility of `B`
  would force `0 = tr 1 = n`.)

## Conjecture 1: rigidity of the EML realization

The second generator of the algebra is *forced* by the first: any differentiable
vector field `f ∂` on `ℝ` with `⁅(x ∂), f ∂⁆ = -f ∂` is a constant field
(`affField_rigidity`), and correspondingly any differentiable field on `(0, ∞)`
bracketing with the EML dilation field `y log y ∂` to eigenvalue `-1` is exactly
a pure scaling field `c y ∂ = emlField (0, c)` (`emlField_rigidity`).  So the
logarithm appearing in `emlField` is the unique solution of a first order
rigidity equation, not a modelling convention.  Both proofs go through a
singular first order ODE (`x f' = 0`, resp. `y log y F' = F log y`) whose
solutions are pinned down away from the singular point and then glued by
continuity.

## Universal abelian quotient

`scaleChar : EMLGen →ₗ⁅ℝ⁆ ℝ` is the *universal* map to an abelian Lie algebra:
every Lie algebra homomorphism out of `EMLGen` into an abelian algebra kills the
shift ideal and factors through `scaleChar` (`lieHom_abelian_factors`), and the
quotient `EMLGen ⧸ shiftIdeal` is abelian (`quotient_isLieAbelian`).
-/

namespace EMLLieRigidity

open EMLExpLogDuality EMLExpLogDuality.EMLGen Matrix

/-! ## 1.  A trace obstruction for the relation `⁅A, B⁆ = B` -/

section Matrices

variable {n : Type*} [Fintype n] [DecidableEq n]

/-- The basic trace identity: `tr(⁅A, B⁆ B) = 0` for all square matrices. -/
theorem trace_lie_mul_self (A B : Matrix n n ℝ) : Matrix.trace (⁅A, B⁆ * B) = 0 := by
  rw [Ring.lie_def, Matrix.sub_mul, Matrix.trace_sub, Matrix.mul_assoc,
    Matrix.trace_mul_comm A (B * B), Matrix.trace_mul_comm (B * A) B, ← Matrix.mul_assoc,
    sub_self]

omit [DecidableEq n] in
/-- A real skew-symmetric matrix with `tr(B * B) = 0` vanishes: the trace form is
(negative) definite on skew-symmetric matrices. -/
theorem skew_eq_zero_of_trace_sq (B : Matrix n n ℝ) (hB : Bᵀ = -B)
    (h : Matrix.trace (B * B) = 0) : B = 0 := by
  have hji : ∀ i j, B j i = -B i j := by
    intro i j
    have := congrFun (congrFun hB i) j
    simpa using this
  have key : ∀ i, (B * B) i i = -∑ j, B i j ^ 2 := by
    intro i
    rw [Matrix.mul_apply, ← Finset.sum_neg_distrib]
    exact Finset.sum_congr rfl fun j _ => by rw [hji i j]; ring
  have h' : ∑ i, (∑ j, B i j ^ 2) = 0 := by
    have htr : Matrix.trace (B * B) = -∑ i, ∑ j, B i j ^ 2 := by
      rw [Matrix.trace, ← Finset.sum_neg_distrib]
      exact Finset.sum_congr rfl fun i _ => key i
    rw [htr, neg_eq_zero] at h
    exact h
  have hnn : ∀ i ∈ (Finset.univ : Finset n), (0:ℝ) ≤ ∑ j, B i j ^ 2 :=
    fun i _ => Finset.sum_nonneg fun j _ => sq_nonneg _
  ext i j
  have h1 := (Finset.sum_eq_zero_iff_of_nonneg hnn).mp h' i (Finset.mem_univ i)
  have h2 := (Finset.sum_eq_zero_iff_of_nonneg
    (fun j (_ : j ∈ (Finset.univ : Finset n)) => sq_nonneg (B i j))).mp h1 j (Finset.mem_univ j)
  simpa [pow_eq_zero_iff] using h2

/-- **The compactness obstruction.**  If `⁅A, B⁆ = B` and `B` is skew-symmetric
then `B = 0`: an `ad`-eigenvector with nonzero eigenvalue cannot be an
infinitesimal rotation. -/
theorem skew_shift_eq_zero (A B : Matrix n n ℝ) (hB : Bᵀ = -B) (h : ⁅A, B⁆ = B) : B = 0 := by
  refine skew_eq_zero_of_trace_sq B hB ?_
  have := trace_lie_mul_self A B
  rwa [h] at this

/-- `ad A` acts on the powers of `B` by the eigenvalue `k`: `⁅A, B ^ k⁆ = k • B ^ k`. -/
theorem lie_pow_eq_nsmul (A B : Matrix n n ℝ) (h : A * B - B * A = B) (k : ℕ) :
    A * B ^ (k + 1) - B ^ (k + 1) * A = ((k : ℝ) + 1) • B ^ (k + 1) := by
  induction k with
  | zero => simpa using h
  | succ m ih =>
    have step : A * B ^ (m + 2) - B ^ (m + 2) * A
        = (A * B ^ (m + 1) - B ^ (m + 1) * A) * B + B ^ (m + 1) * (A * B - B * A) := by
      simp [pow_succ, Matrix.mul_assoc, Matrix.sub_mul, Matrix.mul_sub]
    rw [step, ih, h, Matrix.smul_mul, ← pow_succ]
    push_cast
    module

/-- **Trace nilpotency.**  Every positive power of an `ad`-eigenvector of
eigenvalue one has vanishing trace. -/
theorem trace_pow_eq_zero_of_lie_eq_self (A B : Matrix n n ℝ) (h : A * B - B * A = B) (k : ℕ) :
    Matrix.trace (B ^ (k + 1)) = 0 := by
  have h1 := lie_pow_eq_nsmul A B h k
  have h2 : Matrix.trace (A * B ^ (k + 1) - B ^ (k + 1) * A) = 0 := by
    rw [Matrix.trace_sub, Matrix.trace_mul_comm, sub_self]
  rw [h1, Matrix.trace_smul, smul_eq_mul] at h2
  have hne : ((k : ℝ) + 1) ≠ 0 := by positivity
  rcases mul_eq_zero.mp h2 with h' | h'
  · exact absurd h' hne
  · exact h'

end Matrices

/-- **Singularity.**  An `ad`-eigenvector of eigenvalue one is never invertible:
`A - B A B⁻¹ = 1` would have trace `0 = n`. -/
theorem det_not_isUnit_of_lie_eq_self {n : ℕ} (hn : 0 < n) (A B : Matrix (Fin n) (Fin n) ℝ)
    (h : A * B - B * A = B) : ¬ IsUnit B.det := by
  intro hu
  have hinv : B * B⁻¹ = 1 := Matrix.mul_nonsing_inv B hu
  have hinv' : B⁻¹ * B = 1 := Matrix.nonsing_inv_mul B hu
  have key : A - B * (A * B⁻¹) = 1 := by
    have h2 : (A * B - B * A) * B⁻¹ = B * B⁻¹ := by rw [h]
    rw [hinv, Matrix.sub_mul, Matrix.mul_assoc, Matrix.mul_assoc] at h2
    have hAB : A * (B * B⁻¹) = A := by rw [hinv, Matrix.mul_one]
    rwa [hAB] at h2
  have htr := congrArg Matrix.trace key
  rw [Matrix.trace_sub, Matrix.trace_mul_comm B (A * B⁻¹), Matrix.mul_assoc, hinv',
    Matrix.mul_one, sub_self, Matrix.trace_one] at htr
  have hne : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  simp at htr
  exact hne htr.symm

/-! ## 2.  Consequences for representations of the EML algebra -/

section Representations

variable {n : Type*} [Fintype n] [DecidableEq n]
variable (rho : EMLGen →ₗ⁅ℝ⁆ Matrix n n ℝ)

/-- In any representation the shift generator satisfies the matrix eigenvalue
relation `⁅ρ D, ρ T⁆ = ρ T`. -/
theorem rep_lie_relation : rho D * rho T - rho T * rho D = rho T := by
  have h := LieHom.map_lie rho D T
  rw [lie_D_T] at h
  rw [← Ring.lie_def]
  exact h.symm

/-- **Conjecture 4, concrete form.**  If every generator acts by a skew-symmetric
matrix then the shift generator acts by zero. -/
theorem skew_rep_shift_eq_zero (hskew : ∀ g, (rho g)ᵀ = -(rho g)) : rho T = 0 :=
  skew_shift_eq_zero (rho D) (rho T) (hskew T) (by
    rw [Ring.lie_def]; exact rep_lie_relation rho)

/-- **No faithful skew-symmetric (i.e. "compact") representation.**  The EML
generator algebra is not a subalgebra of any `𝔰𝔬(n)`. -/
theorem no_faithful_skew_representation (hskew : ∀ g, (rho g)ᵀ = -(rho g)) :
    ¬ Function.Injective rho := by
  intro hinj
  have h0 : rho T = rho 0 := by rw [skew_rep_shift_eq_zero rho hskew, map_zero]
  have : (T : EMLGen) = 0 := hinj h0
  have := congrArg EMLGen.shift this
  simp at this

/-- In any finite-dimensional representation, all positive power traces of the
shift generator vanish. -/
theorem rep_shift_trace_pow_eq_zero (k : ℕ) : Matrix.trace ((rho T) ^ (k + 1)) = 0 :=
  trace_pow_eq_zero_of_lie_eq_self (rho D) (rho T) (rep_lie_relation rho) k

end Representations

/-- In any representation of positive dimension the shift generator acts by a
singular matrix. -/
theorem rep_shift_det_not_isUnit {n : ℕ} (hn : 0 < n)
    (rho : EMLGen →ₗ⁅ℝ⁆ Matrix (Fin n) (Fin n) ℝ) : ¬ IsUnit (rho T).det :=
  det_not_isUnit_of_lie_eq_self hn (rho D) (rho T) (rep_lie_relation rho)

/-- The concrete `2 × 2` realization of the catalog file is an instance: the
image of `T` there is `!![0, 1; 0, 0]`, which is indeed singular. -/
theorem toMatrix_T_det_not_isUnit : ¬ IsUnit (toMatrix T).det :=
  rep_shift_det_not_isUnit (by norm_num) toMatrixLie

/-- A real `2 × 2` matrix whose first two power traces vanish squares to zero
(Cayley–Hamilton in dimension two: `tr B = 0` and `tr B² = 0` force
`det B = 0`). -/
theorem sq_eq_zero_of_trace_two (B : Matrix (Fin 2) (Fin 2) ℝ)
    (h1 : Matrix.trace B = 0) (h2 : Matrix.trace (B * B) = 0) : B * B = 0 := by
  rw [Matrix.trace_fin_two] at h1
  rw [Matrix.trace_fin_two, Matrix.mul_apply, Matrix.mul_apply, Fin.sum_univ_two,
    Fin.sum_univ_two] at h2
  have hd : B 1 1 = -B 0 0 := by linarith
  rw [hd] at h2
  have hkey : B 0 0 * B 0 0 + B 0 1 * B 1 0 = 0 := by nlinarith [h2]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Matrix.mul_apply, Fin.sum_univ_two, hd] <;> nlinarith [hkey]

/-- **Nilpotency in dimension two.**  In every two-dimensional representation the
pure-scaling generator acts by a square-zero matrix; in particular it is
nilpotent, so no faithful two-dimensional representation can diagonalize it. -/
theorem rep_dim_two_shift_isNilpotent (rho : EMLGen →ₗ⁅ℝ⁆ Matrix (Fin 2) (Fin 2) ℝ) :
    IsNilpotent (rho T) := by
  refine ⟨2, ?_⟩
  have h1 : Matrix.trace (rho T) = 0 := by
    have := rep_shift_trace_pow_eq_zero rho 0
    simpa using this
  have h2 : Matrix.trace (rho T * rho T) = 0 := by
    have := rep_shift_trace_pow_eq_zero rho 1
    rwa [pow_two] at this
  rw [pow_two]
  exact sq_eq_zero_of_trace_two _ h1 h2

/-! ## 3.  Rigidity of the EML vector-field realization -/

/-- Solutions of the singular ODE `x f'(x) = 0` on `ℝ` are constant: the
derivative vanishes off the origin, and continuity glues the two half lines. -/
theorem const_of_mul_deriv_eq_zero (f : ℝ → ℝ) (hf : Differentiable ℝ f)
    (h : ∀ x : ℝ, x * deriv f x = 0) : ∀ x, f x = f 0 := by
  have hd : ∀ x : ℝ, x ≠ 0 → deriv f x = 0 := by
    intro x hx
    rcases mul_eq_zero.mp (h x) with h' | h'
    · exact absurd h' hx
    · exact h'
  have hIoi : ∀ x ∈ Set.Ioi (0:ℝ), ∀ y ∈ Set.Ioi (0:ℝ), f x = f y := fun x hx y hy =>
    isOpen_Ioi.is_const_of_deriv_eq_zero isPreconnected_Ioi hf.differentiableOn
      (fun z hz => hd z (ne_of_gt hz)) hx hy
  have hIio : ∀ x ∈ Set.Iio (0:ℝ), ∀ y ∈ Set.Iio (0:ℝ), f x = f y := fun x hx y hy =>
    isOpen_Iio.is_const_of_deriv_eq_zero isPreconnected_Iio hf.differentiableOn
      (fun z hz => hd z (ne_of_lt hz)) hx hy
  have hzr : f 0 = f 1 := by
    have h1 : Filter.Tendsto f (nhdsWithin 0 (Set.Ioi (0:ℝ))) (nhds (f 0)) :=
      hf.continuous.continuousAt.continuousWithinAt
    have h2 : Filter.Tendsto f (nhdsWithin 0 (Set.Ioi (0:ℝ))) (nhds (f 1)) := by
      refine Filter.Tendsto.congr' ?_ tendsto_const_nhds
      filter_upwards [self_mem_nhdsWithin] with z hz
      exact hIoi 1 (by norm_num) z hz
    exact tendsto_nhds_unique h1 h2
  have hzl : f 0 = f (-1) := by
    have h1 : Filter.Tendsto f (nhdsWithin 0 (Set.Iio (0:ℝ))) (nhds (f 0)) :=
      hf.continuous.continuousAt.continuousWithinAt
    have h2 : Filter.Tendsto f (nhdsWithin 0 (Set.Iio (0:ℝ))) (nhds (f (-1))) := by
      refine Filter.Tendsto.congr' ?_ tendsto_const_nhds
      filter_upwards [self_mem_nhdsWithin] with z hz
      exact hIio (-1) (by norm_num) z hz
    exact tendsto_nhds_unique h1 h2
  intro x
  rcases lt_trichotomy x 0 with hx | hx | hx
  · rw [hIio x hx (-1) (by norm_num), ← hzl]
  · rw [hx]
  · rw [hIoi x hx 1 (by norm_num), ← hzr]

/-- **Rigidity, affine picture.**  A differentiable vector field `f ∂` on `ℝ`
with `⁅(x ∂), f ∂⁆ = -f ∂` is a constant field, i.e. exactly `affField (0, c)`.
The dilation generator determines its partner. -/
theorem affField_rigidity (f : ℝ → ℝ) (hf : Differentiable ℝ f)
    (h : ∀ x : ℝ, vfBracket (affField D) f x = -f x) :
    f = affField ⟨0, f 0⟩ := by
  have hode : ∀ x : ℝ, x * deriv f x = 0 := by
    intro x
    have hx := h x
    rw [vfBracket, deriv_affField] at hx
    have haff : affField D x = x := by simp [affField]
    rw [haff] at hx
    simp only [D_scale] at hx
    linarith
  funext x
  rw [const_of_mul_deriv_eq_zero f hf hode x]
  simp [affField]

/-- Solutions of the singular ODE `(y - 1) * g'(y) = 0` type equation on the
positive half line are constant: the derivative vanishes off `y = 1`, and
continuity at `1` glues `(0, 1)` to `(1, ∞)`. -/
theorem const_of_deriv_eq_zero_punctured (g : ℝ → ℝ)
    (hg : DifferentiableOn ℝ g (Set.Ioi 0)) (hgc : ContinuousAt g 1)
    (h : ∀ y : ℝ, 0 < y → y ≠ 1 → deriv g y = 0) :
    ∀ y : ℝ, 0 < y → g y = g 1 := by
  have hlow : ∀ y ∈ Set.Ioo (0:ℝ) 1, ∀ z ∈ Set.Ioo (0:ℝ) 1, g y = g z := fun y hy z hz =>
    isOpen_Ioo.is_const_of_deriv_eq_zero isPreconnected_Ioo
      (hg.mono (fun w hw => hw.1)) (fun w hw => h w hw.1 (ne_of_lt hw.2)) hy hz
  have hhigh : ∀ y ∈ Set.Ioi (1:ℝ), ∀ z ∈ Set.Ioi (1:ℝ), g y = g z := fun y hy z hz =>
    isOpen_Ioi.is_const_of_deriv_eq_zero isPreconnected_Ioi
      (hg.mono (fun w hw => lt_trans one_pos hw)) (fun w hw => h w (lt_trans one_pos hw)
        (ne_of_gt hw)) hy hz
  have hleft : g (1/2) = g 1 := by
    have h1 : Filter.Tendsto g (nhdsWithin 1 (Set.Iio (1:ℝ))) (nhds (g 1)) :=
      hgc.continuousWithinAt
    have h2 : Filter.Tendsto g (nhdsWithin 1 (Set.Iio (1:ℝ))) (nhds (g (1/2))) := by
      refine Filter.Tendsto.congr' ?_ tendsto_const_nhds
      filter_upwards [self_mem_nhdsWithin,
        (eventually_gt_nhds (show (0:ℝ) < 1 by norm_num)).filter_mono nhdsWithin_le_nhds]
        with z hz1 hz2
      exact hlow (1/2) (by norm_num) z ⟨hz2, hz1⟩
    exact (tendsto_nhds_unique h2 h1)
  have hright : g 2 = g 1 := by
    have h1 : Filter.Tendsto g (nhdsWithin 1 (Set.Ioi (1:ℝ))) (nhds (g 1)) :=
      hgc.continuousWithinAt
    have h2 : Filter.Tendsto g (nhdsWithin 1 (Set.Ioi (1:ℝ))) (nhds (g 2)) := by
      refine Filter.Tendsto.congr' ?_ tendsto_const_nhds
      filter_upwards [self_mem_nhdsWithin] with z hz1
      exact hhigh 2 (by norm_num) z hz1
    exact (tendsto_nhds_unique h2 h1)
  intro y hy
  rcases lt_trichotomy y 1 with hy1 | hy1 | hy1
  · rw [hlow y ⟨hy, hy1⟩ (1/2) (by norm_num), hleft]
  · rw [hy1]
  · rw [hhigh y hy1 2 (by norm_num), hright]

/-- **Rigidity, EML picture.**  Any differentiable field `F ∂` on `(0, ∞)` which
is an `ad`-eigenvector of eigenvalue `-1` for the EML dilation field
`emlField D = y log y ∂` is a pure scaling field `F y = c y`, i.e.
`emlField (0, c)`.  In particular the logarithm in the EML realization is forced
by the bracket relation. -/
theorem emlField_rigidity (F : ℝ → ℝ) (hF : Differentiable ℝ F)
    (h : ∀ y : ℝ, 0 < y → vfBracket (emlField D) F y = -F y) :
    ∀ y : ℝ, 0 < y → F y = emlField ⟨0, F 1⟩ y := by
  -- the bracket relation says `y log y * F' y = F y * log y`
  have hode : ∀ y : ℝ, 0 < y → y * Real.log y * deriv F y = F y * Real.log y := by
    intro y hy
    have hy0 : y ≠ 0 := ne_of_gt hy
    have hx := h y hy
    rw [vfBracket, deriv_emlField D hy0] at hx
    have hfield : emlField D y = y * Real.log y := by simp [emlField]
    rw [hfield] at hx
    simp only [D_scale, D_shift] at hx
    nlinarith [hx]
  set g : ℝ → ℝ := fun y => F y / y with hgdef
  have hgdiff : DifferentiableOn ℝ g (Set.Ioi 0) := by
    refine DifferentiableOn.div hF.differentiableOn differentiableOn_id ?_
    intro y hy
    exact ne_of_gt hy
  have hgc : ContinuousAt g 1 := by
    have : DifferentiableAt ℝ g 1 :=
      (hF 1).div differentiableAt_id (by norm_num)
    exact this.continuousAt
  have hgderiv : ∀ y : ℝ, 0 < y → y ≠ 1 → deriv g y = 0 := by
    intro y hy hy1
    have hy0 : y ≠ 0 := ne_of_gt hy
    have hlogy : Real.log y ≠ 0 := Real.log_ne_zero_of_pos_of_ne_one hy hy1
    have hFy : y * deriv F y = F y := by
      have := hode y hy
      have h2 : (y * deriv F y - F y) * Real.log y = 0 := by ring_nf; nlinarith [this]
      rcases mul_eq_zero.mp h2 with h' | h'
      · linarith [sub_eq_zero.mp h']
      · exact absurd h' hlogy
    have hd : HasDerivAt g ((deriv F y * y - F y * 1) / y ^ 2) y := by
      exact ((hF y).hasDerivAt).div (hasDerivAt_id y) hy0
    rw [hd.deriv]
    have : deriv F y * y - F y * 1 = 0 := by
      rw [mul_comm (deriv F y) y] at *
      linarith [hFy]
    rw [this, zero_div]
  intro y hy
  have := const_of_deriv_eq_zero_punctured g hgdiff hgc hgderiv y hy
  have hgy : F y / y = F 1 / 1 := this
  have : F y = F 1 * y := by
    field_simp at hgy
    linarith [hgy]
  rw [this]
  simp [emlField]
  ring

/-! ## 4.  The universal abelian quotient -/

/-- The scale character `(a, b) ↦ a`, a Lie algebra homomorphism to the abelian
Lie algebra `ℝ`. -/
def scaleChar : EMLGen →ₗ⁅ℝ⁆ ℝ where
  toFun g := g.scale
  map_add' g h := rfl
  map_smul' c g := rfl
  map_lie' := by intro g h; simp [bracket_scale, Ring.lie_def, mul_comm]

@[simp] lemma scaleChar_apply (g : EMLGen) : scaleChar g = g.scale := rfl

/-- The kernel of the scale character is exactly the shift ideal. -/
theorem scaleChar_eq_zero_iff (g : EMLGen) : scaleChar g = 0 ↔ g ∈ shiftIdeal := Iff.rfl

/-- Every Lie algebra homomorphism from `EMLGen` to an abelian Lie algebra kills
the shift generator. -/
theorem lieHom_abelian_shift_eq_zero {L : Type*} [LieRing L] [LieAlgebra ℝ L] [IsLieAbelian L]
    (f : EMLGen →ₗ⁅ℝ⁆ L) : f T = 0 := by
  have h := LieHom.map_lie f D T
  rw [lie_D_T] at h
  rw [h, trivial_lie_zero]

/-- **Universality of the scale character.**  Any Lie algebra homomorphism into
an abelian algebra factors through `scaleChar`: it is `g ↦ scaleChar g • f D`. -/
theorem lieHom_abelian_factors {L : Type*} [LieRing L] [LieAlgebra ℝ L] [IsLieAbelian L]
    (f : EMLGen →ₗ⁅ℝ⁆ L) (g : EMLGen) : f g = scaleChar g • f D := by
  have hdec : g = g.scale • D + g.shift • T := basis_decomposition g
  rw [hdec]
  rw [map_add, map_smul, map_smul, lieHom_abelian_shift_eq_zero f, smul_zero, add_zero]
  simp

/-- **SC1′, first half.**  The quotient of the EML algebra by the shift ideal is
abelian: the derived algebra is exactly the shift ideal, so all brackets die in
the quotient. -/
theorem quotient_isLieAbelian : IsLieAbelian (EMLGen ⧸ shiftIdeal) := by
  constructor
  intro x y
  obtain ⟨a, rfl⟩ := LieSubmodule.Quotient.surjective_mk' shiftIdeal x
  obtain ⟨b, rfl⟩ := LieSubmodule.Quotient.surjective_mk' shiftIdeal y
  have hmem : ⁅a, b⁆ ∈ shiftIdeal := by
    simp [mem_shiftIdeal]
  have h1 : ⁅(LieSubmodule.Quotient.mk' shiftIdeal a),
      (LieSubmodule.Quotient.mk' shiftIdeal b)⁆
      = LieSubmodule.Quotient.mk' shiftIdeal ⁅a, b⁆ := rfl
  rw [h1]
  exact (LieSubmodule.Quotient.mk_eq_zero _).2 hmem

/-- The quotient map is nonzero: the class of the dilation generator survives,
so `EMLGen ⧸ shiftIdeal` is a nonzero abelian algebra (one-dimensional, spanned
by the class of `D`). -/
theorem quotient_mk_D_ne_zero :
    (LieSubmodule.Quotient.mk' shiftIdeal D : EMLGen ⧸ shiftIdeal) ≠ 0 := by
  intro hcon
  have : D ∈ shiftIdeal := (LieSubmodule.Quotient.mk_eq_zero _).1 hcon
  rw [mem_shiftIdeal, D_scale] at this
  exact one_ne_zero this

end EMLLieRigidity