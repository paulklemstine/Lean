import Mathlib
import Novelty.FloatBackwardErrorHorner
import Novelty.FloatPseudoOrbitShadowing

/-!
# Structural backward error: a floating-point logistic map is an exact logistic map

Fourth cycle.  The backward-error statement of the first cycle
(`hornerFl_backward`) perturbs the coefficients of the polynomial *individually*,
so the perturbed system need not belong to the original parameterised family.
For the natural product implementation of the logistic map,

```
  fl_step r x  =  fl( r ⊗ fl( x ⊗ fl(1 ⊖ x) ) )
```

a much stronger, *structural* backward-error statement holds: the computed value
is the exact value of the logistic map **of the same family** at a perturbed
parameter `r'` with `|r' - r| ≤ γ₃(u) |r|`
(`flLogisticStep_parameter_backward`).  Consequently a floating-point logistic
execution is the exact orbit of a nonautonomous logistic family whose parameters
stay in a relative `γ₃(u)`-neighbourhood of `r`
(`flLogisticOrbit_exact_family`).

The boundary of the statement is also identified: the perturbed parameter may
exceed `4`, in which case `[0,1]` is no longer invariant
(`parameter_overshoot_escapes`), which is exactly why the runtime hypothesis
"the execution was observed to remain in `[0,1]`" cannot be dropped from
`logistic_binary64_shadowing`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): rounding errors in a *structured* evaluation scheme
should be expressible as perturbations *within* the model family, not merely as
arbitrary coefficient perturbations; if so, floating-point chaos experiments
simulate a genuine (slightly detuned) member of the family exactly.
Experiment (Experimenter): for the three-operation product form the three
relative errors combine into the single factor `(1+e₁)(1+e₂)(1+e₃)`, which
multiplies `r` alone.  The subtraction `1 ⊖ x` is the only step where structure
could fail, and it does not: its relative error again scales the whole product.
Analysis (Analyst): the same argument fails for Horner form
`r ⊗ (x ⊗ (1 ⊖ x))` versus the expanded form `r x - r x²`, where the two
monomials acquire *different* factors — structural backward error is a property
of the *program*, not of the mathematical function.  This is the sharpest
formulation of "backward-error semantics is a semantics of programs".
Critique (Critic): `|r' - r| ≤ γ₃|r|` allows `r' > 4`; the escape lemma shows
this is not vacuous, so the invariance hypothesis in the shadowing corollary is
load-bearing.
-- !-- End Lab Notes -- !--
-/

namespace Novelty.FloatBackwardError

/-- The logistic map with parameter `r`. -/
def logisticMap (r z : ℝ) : ℝ := r * (z * (1 - z))

/-- The natural floating-point implementation `fl(r ⊗ fl(x ⊗ fl(1 ⊖ x)))`. -/
def flLogisticStep (M : RoundingModel) (r x : ℝ) : ℝ :=
  M.mul r (M.mul x (M.sub 1 x))

/-- Relative perturbations compose: if `t₁` and `t₂` are within `γ_a` and `γ_b`
of `1`, their product is within `γ_{a+b}` of `1`. -/
lemma gamma_mul_bound {u t₁ t₂ : ℝ} (hu : 0 ≤ u) {a b : ℕ}
    (h₁ : |t₁ - 1| ≤ gamma u a) (h₂ : |t₂ - 1| ≤ gamma u b) :
    |t₁ * t₂ - 1| ≤ gamma u (a + b) := by
  have habs2 : |t₂| ≤ (1 + u) ^ b := by
    have h2' : |t₂ - 1| ≤ gamma u b * |(1:ℝ)| := by simpa using h₂
    simpa using abs_le_of_rel h2'
  have key : |t₁ * t₂ - 1| ≤ |t₁ - 1| * |t₂| + |t₂ - 1| := by
    have hsplit : t₁ * t₂ - 1 = (t₁ - 1) * t₂ + (t₂ - 1) := by ring
    rw [hsplit]
    refine (abs_add_le _ _).trans ?_
    rw [abs_mul]
  have hga : gamma u a = (1 + u) ^ a - 1 := rfl
  have hgb : gamma u b = (1 + u) ^ b - 1 := rfl
  have hgab : gamma u (a + b) = (1 + u) ^ a * (1 + u) ^ b - 1 := by
    simp [gamma, pow_add]
  have hpowb : (0:ℝ) ≤ (1 + u) ^ b := by positivity
  have hprod : |t₁ - 1| * |t₂| ≤ gamma u a * (1 + u) ^ b :=
    mul_le_mul h₁ habs2 (abs_nonneg _) (gamma_nonneg hu a)
  rw [hgab]
  nlinarith [hprod, h₂]

/-- Elementary bound: the product of three factors `1 + eᵢ` with `|eᵢ| ≤ u`
differs from `1` by at most `γ₃(u)`. -/
lemma abs_prod_three_sub_one {u e₁ e₂ e₃ : ℝ} (hu : 0 ≤ u)
    (h₁ : |e₁| ≤ u) (h₂ : |e₂| ≤ u) (h₃ : |e₃| ≤ u) :
    |(1 + e₁) * (1 + e₂) * (1 + e₃) - 1| ≤ gamma u 3 := by
  have hg1 : ∀ e : ℝ, |e| ≤ u → |(1 + e) - 1| ≤ gamma u 1 := by
    intro e he
    simpa [gamma] using he
  have h12 := gamma_mul_bound hu (hg1 e₁ h₁) (hg1 e₂ h₂)
  have h123 := gamma_mul_bound hu h12 (hg1 e₃ h₃)
  simpa using h123

/-- **Structural backward error.**  The floating-point logistic step is the
*exact* logistic step of the same family at a perturbed parameter within
relative distance `γ₃(u)` of `r`. -/
theorem flLogisticStep_parameter_backward (M : RoundingModel) (r x : ℝ) :
    ∃ r' : ℝ, |r' - r| ≤ gamma M.u 3 * |r| ∧ flLogisticStep M r x = logisticMap r' x := by
  obtain ⟨e₁, he₁, hsub⟩ := M.sub_spec 1 x
  obtain ⟨e₂, he₂, hmul₂⟩ := M.mul_spec x (M.sub 1 x)
  obtain ⟨e₃, he₃, hmul₃⟩ := M.mul_spec r (M.mul x (M.sub 1 x))
  refine ⟨r * ((1 + e₁) * (1 + e₂) * (1 + e₃)), ?_, ?_⟩
  · have hkey : r * ((1 + e₁) * (1 + e₂) * (1 + e₃)) - r
        = ((1 + e₁) * (1 + e₂) * (1 + e₃) - 1) * r := by ring
    rw [hkey, abs_mul]
    exact mul_le_mul_of_nonneg_right
      (abs_prod_three_sub_one M.u_nonneg he₁ he₂ he₃) (abs_nonneg r)
  · rw [flLogisticStep, hmul₃, hmul₂, hsub, logisticMap]
    ring

/-- The forward defect of one logistic step, in terms of the intermediate
magnitudes `|r|`, `|x|` and `|1 - x|`. -/
theorem flLogisticStep_defect (M : RoundingModel) (r x : ℝ) :
    |flLogisticStep M r x - logisticMap r x| ≤ gamma M.u 3 * (|r| * (|x| * |1 - x|)) := by
  obtain ⟨r', hr', hval⟩ := flLogisticStep_parameter_backward M r x
  rw [hval, logisticMap, logisticMap]
  have hkey : r' * (x * (1 - x)) - r * (x * (1 - x)) = (r' - r) * (x * (1 - x)) := by ring
  rw [hkey, abs_mul, abs_mul]
  have h1 : |r' - r| * (|x| * |1 - x|) ≤ (gamma M.u 3 * |r|) * (|x| * |1 - x|) :=
    mul_le_mul_of_nonneg_right hr' (by positivity)
  calc |r' - r| * (|x| * |1 - x|) ≤ (gamma M.u 3 * |r|) * (|x| * |1 - x|) := h1
    _ = gamma M.u 3 * (|r| * (|x| * |1 - x|)) := by ring

/-- The floating-point logistic orbit. -/
def flLogisticOrbit (M : RoundingModel) (r x₀ : ℝ) : ℕ → ℝ
  | 0 => x₀
  | n + 1 => flLogisticStep M r (flLogisticOrbit M r x₀ n)

/-- **A floating-point logistic execution is the exact orbit of a nonautonomous
logistic family** whose parameters remain within relative distance `γ₃(u)` of the
nominal parameter. -/
theorem flLogisticOrbit_exact_family (M : RoundingModel) (r x₀ : ℝ) :
    ∃ rs : ℕ → ℝ, (∀ n, |rs n - r| ≤ gamma M.u 3 * |r|) ∧
      ∀ n, flLogisticOrbit M r x₀ (n + 1) = logisticMap (rs n) (flLogisticOrbit M r x₀ n) := by
  choose rs hrs hval using
    fun n => flLogisticStep_parameter_backward M r (flLogisticOrbit M r x₀ n)
  exact ⟨rs, hrs, hval⟩

/-- Consistency of the two backward-error pictures: the perturbed logistic map is
evaluated exactly by Horner with the perturbed coefficient list. -/
theorem logisticMap_eq_hornerR (r z : ℝ) : logisticMap r z = hornerR [0, r, -r] z := by
  simp [logisticMap, hornerR]; ring

/-- **Boundary of the theory.**  A parameter perturbation, however small, can push
`r` above `4`, and then the unit interval is no longer invariant: the midpoint
escapes.  Hence the runtime hypothesis "the observed execution stayed in `[0,1]`"
is load-bearing in `logistic_binary64_shadowing`. -/
theorem parameter_overshoot_escapes {r : ℝ} (hr : 4 < r) :
    logisticMap r (1 / 2) ∉ Set.Icc (0:ℝ) 1 := by
  intro hmem
  have h2 : logisticMap r (1 / 2) = r / 4 := by
    simp [logisticMap]; ring
  have := hmem.2
  rw [h2] at this
  linarith

end Novelty.FloatBackwardError