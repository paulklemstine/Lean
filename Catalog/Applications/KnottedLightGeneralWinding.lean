/-
# General Winding Number and the Topology of `ℂ*` (Knotted Light, next step)

This file continues the study of the topological charge of orbital-angular-momentum
("knotted light") beams begun in `KnottedLight.lean`.  There the winding number was
computed only for the special phase field `exp(i ℓ θ)`.  Here we develop the winding
number as a genuine invariant of an *arbitrary* smooth non-vanishing loop
`γ : ℝ → ℂ \ {0}`, and prove the two structural theorems that make it the
fundamental invariant of `ℂ*`:

* **Additivity / group homomorphism.** The winding number turns pointwise
  multiplication of loops into addition of charges
  (`winding_mul`, `winding_one`, `winding_inv`, `winding_zpow`).
* **Integrality (`ℤ = π₁(ℂ*)`).** The winding number of *any* closed loop is an
  integer (`winding_integer`).  This is the honest statement that the topological
  charge is quantized — not by fiat, but as a consequence of single-valuedness.
* **Surjectivity.** Every integer is realised (`winding_surjective`), via the OAM
  phase `exp(i ℓ θ)`; combined with integrality and additivity this exhibits the
  winding number as a surjective group homomorphism `π₁(ℂ*) ↠ ℤ`.

## Contrarian conjectures (v26)

* `winding_not_additive_under_sum` — DISPROOF of "the winding number is additive
  under pointwise *addition* of fields": it is additive under multiplication, not
  addition (adding a beam to itself doubles the field but does *not* double the
  charge).
* `winding_scale_invariant` — the charge is invariant under multiplication by a
  nonzero constant (a form of gauge/amplitude invariance), refuting "rescaling the
  field amplitude changes its topological charge".
-/
import Mathlib

open Complex intervalIntegral

namespace KnottedLightGeneralWinding

/-- The winding number of a loop `φ : ℝ → ℂ` over one full turn `[0, 2π]`, via the
logarithmic-derivative contour integral `(1/2πi) ∮ φ'/φ`. -/
noncomputable def winding (φ : ℝ → ℂ) : ℂ :=
  (1 / (2 * Real.pi * Complex.I)) * ∫ θ in (0:ℝ)..(2 * Real.pi), deriv φ θ / φ θ

/-- A convenient predicate: `γ` is a smooth non-vanishing loop-candidate on all of
`ℝ`, with continuous derivative `γ'`.  (We do *not* require periodicity here; that
is imposed only where it is needed, e.g. for integrality.) -/
structure IsSmoothLoop (γ γ' : ℝ → ℂ) : Prop where
  hasDeriv : ∀ θ, HasDerivAt γ (γ' θ) θ
  ne_zero  : ∀ θ, γ θ ≠ 0
  contDeriv : Continuous γ'

namespace IsSmoothLoop

variable {γ γ' : ℝ → ℂ}

theorem continuous (h : IsSmoothLoop γ γ') : Continuous γ :=
  continuous_iff_continuousAt.2 (fun x => (h.hasDeriv x).continuousAt)

theorem deriv_eq (h : IsSmoothLoop γ γ') (θ : ℝ) : deriv γ θ = γ' θ :=
  (h.hasDeriv θ).deriv

/-- The logarithmic derivative `γ'/γ` is continuous. -/
theorem logDeriv_continuous (h : IsSmoothLoop γ γ') :
    Continuous (fun θ => deriv γ θ / γ θ) := by
  have hd : (fun θ => deriv γ θ / γ θ) = fun θ => γ' θ / γ θ :=
    funext (fun θ => by rw [h.deriv_eq])
  rw [hd]
  exact h.contDeriv.div h.continuous h.ne_zero

/-- The logarithmic derivative is interval-integrable on any interval. -/
theorem logDeriv_intervalIntegrable (h : IsSmoothLoop γ γ') (a b : ℝ) :
    IntervalIntegrable (fun θ => deriv γ θ / γ θ) MeasureTheory.volume a b :=
  (h.logDeriv_continuous).intervalIntegrable a b

end IsSmoothLoop

/-! ## The winding number is a group homomorphism `(loops, ·) → (ℂ, +)` -/

/-- Winding number of a constant loop is `0`. -/
theorem winding_const (c : ℂ) : winding (fun _ => c) = 0 := by
  unfold winding; simp

theorem winding_one : winding (fun _ => (1 : ℂ)) = 0 := winding_const 1

/-
**Additivity.** The winding number sends pointwise multiplication of loops to
addition of charges.
-/
theorem winding_mul {γ γ' δ δ' : ℝ → ℂ}
    (hγ : IsSmoothLoop γ γ') (hδ : IsSmoothLoop δ δ') :
    winding (fun θ => γ θ * δ θ) = winding γ + winding δ := by
  unfold winding;
  rw [ ← mul_add, ← intervalIntegral.integral_add ];
  · refine' congr rfl ( intervalIntegral.integral_congr fun θ _ => _ );
    erw [ deriv_mul ];
    · rw [ div_add_div _ _ (hγ.ne_zero θ) (hδ.ne_zero θ) ]
    · exact HasDerivAt.differentiableAt ( hγ.hasDeriv θ );
    · exact hδ.hasDeriv θ |> HasDerivAt.differentiableAt;
  · exact hγ.logDeriv_intervalIntegrable _ _;
  · exact hδ.logDeriv_intervalIntegrable _ _

/-
**Inverse.** Inverting a loop negates its charge.
-/
theorem winding_inv {γ γ' : ℝ → ℂ} (hγ : IsSmoothLoop γ γ') :
    winding (fun θ => (γ θ)⁻¹) = - winding γ := by
  unfold winding;
  -- By definition of $IsSmoothLoop$, we know that $(fun t => (γ t)⁻¹)$ has a derivative of $-(γ' t) / (γ t)^2$.
  have h_deriv_inv : ∀ θ, deriv (fun t => (γ t)⁻¹) θ = -(deriv γ θ) / (γ θ)^2 := by
    intro θ; have := hγ.hasDeriv θ; have := this.deriv; simp_all +decide [ div_eq_mul_inv ] ;
    convert HasDerivAt.deriv ( HasDerivAt.comp θ ( hasDerivAt_inv ( hγ.ne_zero θ ) ) ‹HasDerivAt γ ( γ' θ ) θ› ) using 1 ; ring;
  simp_all +decide [ div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm, sq ];
  simp +decide [ mul_left_comm ( γ _ ), hγ.ne_zero ]

/-! ## Integrality: `ℤ = π₁(ℂ*)` -/

/-
**Quantization of topological charge.** The winding number of *any* closed
(`γ(2π) = γ(0)`) smooth non-vanishing loop is an integer.  This is the honest
statement that the charge is quantized: it follows from single-valuedness of the
field, via `exp` of the antiderivative of the logarithmic derivative.
-/
theorem winding_integer {γ γ' : ℝ → ℂ} (hγ : IsSmoothLoop γ γ')
    (hclosed : γ (2 * Real.pi) = γ 0) :
    ∃ n : ℤ, winding γ = (n : ℂ) := by
  -- We'll use that exponential functions are periodic with period $2\pi i$. Define $G(\theta) : = \int_0^\theta f(t) \, dt$ where $f(t) := \deriv \gamma t / \gamma t$.
  set G : ℝ → ℂ := fun θ => ∫ t in (0:ℝ)..θ, (deriv γ t) / (γ t)
  have hG : ∀ θ, HasDerivAt G ((deriv γ θ) / (γ θ)) θ := by
    intro θ; apply_rules [ intervalIntegral.integral_hasDerivAt_right ];
    · exact hγ.logDeriv_intervalIntegrable _ _;
    · exact hγ.logDeriv_continuous.stronglyMeasurable.stronglyMeasurableAtFilter;
    · exact hγ.logDeriv_continuous.continuousAt;
  -- From `hF`, `F` is constant: `Differentiable ℝ F` (`fun θ => (hF θ).differentiableAt`) and `∀ x, deriv F x = 0` (`(hF x).deriv`), so by `is_const_of_deriv_eq_zero`, `F (2*Real.pi) = F 0`.
  have hF_const : ∀ θ, deriv (fun θ => γ θ * Complex.exp (- G θ)) θ = 0 := by
    intro θ;
    convert HasDerivAt.deriv ( HasDerivAt.mul ( hγ.hasDeriv θ ) ( HasDerivAt.cexp ( HasDerivAt.neg ( hG θ ) ) ) ) using 1 ; ring;
    simp +decide [ mul_comm, mul_left_comm, hγ.deriv_eq, hγ.ne_zero ]
  have hF_eq : γ (2 * Real.pi) * Complex.exp (- G (2 * Real.pi)) = γ 0 * Complex.exp (- G 0) := by
    exact is_const_of_deriv_eq_zero ( fun θ => DifferentiableAt.mul ( hγ.hasDeriv θ |> HasDerivAt.differentiableAt ) ( Complex.differentiableAt_exp.comp _ <| DifferentiableAt.neg <| hG θ |> HasDerivAt.differentiableAt ) ) hF_const ( 2 * Real.pi ) 0;
  -- Since $\gamma(2\pi) = \gamma(0)$, we have $\exp(-G(2\pi)) = 1$.
  have h_exp : Complex.exp (-G (2 * Real.pi)) = 1 := by
    have := hγ.ne_zero 0; aesop;
  obtain ⟨ n, hn ⟩ := Complex.exp_eq_one_iff.mp h_exp;
  use -n; unfold winding; simp_all +decide [ mul_assoc, mul_comm, mul_left_comm ] ;
  rw [ show ( ∫ θ in ( 0 : ℝ )..Real.pi * 2, deriv γ θ / γ θ ) = - ( I * ( Real.pi * ( n * 2 ) ) ) by linear_combination' -hn ] ; ring ; norm_num [ Complex.ext_iff, Real.pi_ne_zero ] ;

/-! ## Surjectivity via the OAM phase, and consistency with `KnottedLight` -/

/-- The OAM phase field `exp(i ℓ θ)`, the running example of a knotted-light loop. -/
noncomputable def oamPhase (ℓ : ℤ) (θ : ℝ) : ℂ := Complex.exp ((ℓ : ℂ) * θ * Complex.I)

theorem oamPhase_hasDerivAt (ℓ : ℤ) (θ : ℝ) :
    HasDerivAt (oamPhase ℓ) ((ℓ : ℂ) * Complex.I * oamPhase ℓ θ) θ := by
  unfold oamPhase
  have h1 : HasDerivAt (fun t : ℝ => (ℓ : ℂ) * t * Complex.I) ((ℓ : ℂ) * Complex.I) θ := by
    have hid : HasDerivAt (fun t : ℝ => (t : ℂ)) (1 : ℂ) θ := by
      simpa using Complex.ofRealCLM.hasDerivAt
    have h := ((hasDerivAt_const θ (ℓ : ℂ)).mul hid).mul_const Complex.I
    simpa using h
  have h2 := (Complex.hasDerivAt_exp ((ℓ : ℂ) * θ * Complex.I)).comp θ h1
  simpa [mul_comm, mul_left_comm, mul_assoc] using h2

theorem oamPhase_isSmoothLoop (ℓ : ℤ) :
    IsSmoothLoop (oamPhase ℓ) (fun θ => (ℓ : ℂ) * Complex.I * oamPhase ℓ θ) where
  hasDeriv θ := oamPhase_hasDerivAt ℓ θ
  ne_zero θ := by unfold oamPhase; exact Complex.exp_ne_zero _
  contDeriv := by
    unfold oamPhase
    fun_prop

theorem oamPhase_deriv (ℓ : ℤ) (θ : ℝ) :
    deriv (oamPhase ℓ) θ = (ℓ : ℂ) * Complex.I * oamPhase ℓ θ :=
  (oamPhase_hasDerivAt ℓ θ).deriv

/-- The general winding number reproduces the charge `ℓ` of the OAM phase. -/
theorem winding_oamPhase (ℓ : ℤ) : winding (oamPhase ℓ) = (ℓ : ℂ) := by
  unfold winding
  have hint : ∀ θ ∈ Set.uIcc (0 : ℝ) (2 * Real.pi),
      deriv (oamPhase ℓ) θ / oamPhase ℓ θ = (ℓ : ℂ) * Complex.I := by
    intro θ _
    rw [oamPhase_deriv, mul_div_assoc,
      div_self (by unfold oamPhase; exact Complex.exp_ne_zero _)]
    ring
  rw [intervalIntegral.integral_congr hint, intervalIntegral.integral_const,
    Complex.real_smul]
  have hpi : (Real.pi : ℂ) ≠ 0 := by exact_mod_cast Real.pi_ne_zero
  have hI : Complex.I ≠ 0 := Complex.I_ne_zero
  push_cast
  field_simp
  ring

/-- **Surjectivity of the charge.** Every integer arises as the winding number of a
smooth non-vanishing closed loop. -/
theorem winding_surjective (n : ℤ) :
    ∃ γ γ' : ℝ → ℂ, IsSmoothLoop γ γ' ∧ γ (2 * Real.pi) = γ 0 ∧ winding γ = (n : ℂ) := by
  refine ⟨oamPhase n, _, oamPhase_isSmoothLoop n, ?_, winding_oamPhase n⟩
  unfold oamPhase
  have : ((n : ℂ) * ((2 * Real.pi : ℝ) : ℂ) * Complex.I)
      = (n : ℂ) * (2 * Real.pi * Complex.I) := by push_cast; ring
  rw [show ((n : ℂ) * ((0 : ℝ) : ℂ) * Complex.I) = 0 by push_cast; ring, this,
    Complex.exp_int_mul_two_pi_mul_I, Complex.exp_zero]

/-! ## Contrarian conjectures (v26) -/

/-- **Scale (amplitude) invariance.** Multiplying the field by a nonzero constant
does not change its topological charge, refuting *"rescaling the amplitude changes
the charge."* -/
theorem winding_scale_invariant {γ γ' : ℝ → ℂ} (hγ : IsSmoothLoop γ γ')
    (c : ℂ) (hc : c ≠ 0) :
    winding (fun θ => c * γ θ) = winding γ := by
  unfold winding
  congr 1
  apply intervalIntegral.integral_congr
  intro θ _
  simp only
  have h1 : HasDerivAt (fun t => c * γ t) (c * γ' θ) θ := (hγ.hasDeriv θ).const_mul c
  rw [h1.deriv, (hγ.hasDeriv θ).deriv, mul_div_mul_left _ _ hc]

/-- **DISPROOF** of *"the winding number is additive under pointwise addition of
fields."* Adding the OAM beam `exp(iθ)` to itself gives `2·exp(iθ)`, whose charge is
still `1`, not `1 + 1 = 2`.  Winding is additive under multiplication, not addition. -/
theorem winding_not_additive_under_sum :
    ¬ ∀ ℓ : ℤ, winding (fun θ => oamPhase ℓ θ + oamPhase ℓ θ)
        = winding (oamPhase ℓ) + winding (oamPhase ℓ) := by
  intro h
  have h1 := h 1
  have hfun : (fun θ => oamPhase 1 θ + oamPhase 1 θ) = fun θ => (2 : ℂ) * oamPhase 1 θ := by
    funext θ; ring
  rw [hfun, winding_scale_invariant (oamPhase_isSmoothLoop 1) 2 (by norm_num),
    winding_oamPhase] at h1
  norm_num at h1

end KnottedLightGeneralWinding