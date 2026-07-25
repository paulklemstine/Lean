import Applications.AbstractAlgebra.KnottedLightGeneralWinding

open Complex intervalIntegral

namespace KnottedLightLogLift

open KnottedLightGeneralWinding

/-- A global logarithmic lift over one turn.  Its derivative is the logarithmic
 derivative of the beam, and it closes after the turn. -/
def HasPeriodicLogLift (γ : ℝ → ℂ) : Prop :=
  ∃ L : ℝ → ℂ,
    (∀ θ, HasDerivAt L (deriv γ θ / γ θ) θ) ∧
    Continuous (fun θ => deriv γ θ / γ θ) ∧
    (∀ θ, Complex.exp (L θ) = γ θ) ∧
    L (2 * Real.pi) = L 0

/-
A periodic logarithmic lift has zero winding.
-/
theorem winding_eq_zero_of_periodicLogLift {γ : ℝ → ℂ}
    (hlog : HasPeriodicLogLift γ) : winding γ = 0 := by
  obtain ⟨ L, hL_deriv, hL_cont, hL_exp, hL_periodic ⟩ := hlog; simp_all +decide [ winding ] ;
  rw [ intervalIntegral.integral_eq_sub_of_hasDerivAt ];
  rotate_right;
  exacts [ L, by rw [ hL_periodic, sub_self ], fun x hx => hL_deriv x, hL_cont.intervalIntegrable _ _ ]

/-
Every smooth non-vanishing loop with zero winding admits a global logarithm
that returns to its initial value after one turn.
-/
theorem periodicLogLift_of_winding_eq_zero {γ γ' : ℝ → ℂ}
    (hγ : IsSmoothLoop γ γ') (hw : winding γ = 0) : HasPeriodicLogLift γ := by
  refine' ⟨ fun θ => Complex.log ( γ 0 ) + ∫ t in ( 0 : ℝ )..θ, deriv γ t / γ t, _, _, _, _ ⟩;
  · intro θ;
    have h_ftc : HasDerivAt (fun θ => ∫ t in (0:ℝ)..θ, deriv γ t / γ t) (deriv γ θ / γ θ) θ := by
      apply_rules [ intervalIntegral.integral_hasDerivAt_right ];
      · exact hγ.logDeriv_intervalIntegrable _ _;
      · exact hγ.logDeriv_continuous.stronglyMeasurable.stronglyMeasurableAtFilter;
      · exact hγ.logDeriv_continuous.continuousAt;
    exact HasDerivAt.const_add _ h_ftc;
  · exact hγ.logDeriv_continuous;
  · intro θ;
    -- By definition of $L$, we know that its derivative is $f$.
    have hL_deriv : ∀ θ, HasDerivAt (fun θ => Complex.exp (Complex.log (γ 0) + ∫ t in (0:ℝ)..θ, deriv γ t / γ t) / γ θ) (0 : ℂ) θ := by
      intro θ;
      have h_int_deriv : HasDerivAt (fun θ => ∫ t in (0 : ℝ)..θ, deriv γ t / γ t) (deriv γ θ / γ θ) θ := by
        apply_rules [ intervalIntegral.integral_hasDerivAt_right ];
        · exact hγ.logDeriv_intervalIntegrable _ _;
        · exact hγ.logDeriv_continuous.stronglyMeasurable.stronglyMeasurableAtFilter;
        · exact hγ.logDeriv_continuous.continuousAt;
      convert HasDerivAt.div ( HasDerivAt.comp θ ( Complex.hasDerivAt_exp _ ) ( HasDerivAt.const_add _ h_int_deriv ) ) ( hγ.hasDeriv θ ) ( hγ.ne_zero θ ) using 1 ; norm_num [ Complex.exp_add, Complex.exp_log, hγ.ne_zero ];
      rw [ hγ.deriv_eq ] ; ring;
      grind;
    -- Since the derivative of $L$ is zero, $L$ is constant.
    have hL_const : ∀ θ, Complex.exp (Complex.log (γ 0) + ∫ t in (0:ℝ)..θ, deriv γ t / γ t) / γ θ = Complex.exp (Complex.log (γ 0) + ∫ t in (0:ℝ)..0, deriv γ t / γ t) / γ 0 := by
      intro θ; exact is_const_of_deriv_eq_zero (fun θ => (hL_deriv θ).differentiableAt) (fun θ => (hL_deriv θ).deriv) θ 0;
    simp_all +decide [ Complex.exp_log, div_eq_iff, hγ.ne_zero ];
  · unfold winding at hw; aesop;

/-
**Kernel theorem for optical charge.** Among smooth non-vanishing loops, the
kernel of winding is exactly the class admitting a single-valued logarithmic lift
through a complete turn.
-/
theorem winding_eq_zero_iff_periodicLogLift {γ γ' : ℝ → ℂ}
    (hγ : IsSmoothLoop γ γ') :
    winding γ = 0 ↔ HasPeriodicLogLift γ := by
  exact ⟨ periodicLogLift_of_winding_eq_zero hγ, fun h => winding_eq_zero_of_periodicLogLift h ⟩

/-
A single-valued logarithmic dressing carries no topological charge.
-/
theorem winding_exp_periodic {L L' : ℝ → ℂ}
    (hL : ∀ θ, HasDerivAt L (L' θ) θ)
    (hcL' : Continuous L')
    (hperiodic : L (2 * Real.pi) = L 0) :
    winding (fun θ => Complex.exp (L θ)) = 0 := by
  -- Compute derivative of exp ∘ L as L' * exp L.
  have h_deriv : ∀ θ, deriv (fun θ => Complex.exp (L θ)) θ = (L' θ) * Complex.exp (L θ) := by
    intro θ; rw [ mul_comm ] ; exact HasDerivAt.deriv ( by simpa using HasDerivAt.cexp ( hL θ ) ) ;
  convert winding_eq_zero_of_periodicLogLift _;
  use L
  refine ⟨?_, ?_, ?_, hperiodic⟩
  · intro θ
    simpa [h_deriv, Complex.exp_ne_zero] using hL θ
  · simpa [h_deriv, Complex.exp_ne_zero] using hcL'
  · intro θ
    rfl

/-
Multiplication by an arbitrary smooth, nowhere-zero envelope possessing a
single-valued logarithm leaves the beam charge unchanged.
-/
theorem winding_dressed {γ γ' L L' : ℝ → ℂ}
    (hγ : IsSmoothLoop γ γ')
    (hL : ∀ θ, HasDerivAt L (L' θ) θ)
    (hcL' : Continuous L')
    (hperiodic : L (2 * Real.pi) = L 0) :
    winding (fun θ => Complex.exp (L θ) * γ θ) = winding γ := by
  rw [ winding_mul ];
  rw [ winding_exp_periodic hL hcL' hperiodic, zero_add ];
  constructor;
  exact fun θ => HasDerivAt.cexp ( hL θ );
  exact fun θ => Complex.exp_ne_zero _;
  exact Continuous.mul ( Complex.continuous_exp.comp ( show Continuous L from continuous_iff_continuousAt.mpr fun x => HasDerivAt.continuousAt ( hL x ) ) ) hcL';
  exact hγ

/-
-- !-- Lab Notes -- !--

**Hypothesis (Hypothesizer).** The vanishing of optical charge should be equivalent,
not merely related, to the existence of a logarithm that is single-valued after one
azimuthal turn.  This would identify the kernel of the multiplicative winding map
analytically and imply invariance under general radial or polarization dressing.

**Experiment (Experimenter).** For a zero-charge loop, integrate its logarithmic
derivative from the initial point and add a logarithm of the initial amplitude.
Differentiating the product of the loop with the negative exponential of this
primitive shows that product is constant.  The vanishing integral closes the
primitive.  Conversely, the fundamental theorem of calculus turns closure of any
such primitive directly into zero winding.

**Analysis (Analyst).** The construction does not require a pre-selected branch of
the complex logarithm along the image.  Non-vanishing is used only to initialize
the lift and to identify the logarithmic derivative.  The same kernel theorem
shows that every smooth periodic exponential envelope contributes zero charge.

**Critique (Critic).** Pointwise addition of optical fields is deliberately absent:
winding is multiplicative, and addition can create zeros.  The dressing theorem
requires a globally closing logarithm; mere non-vanishing of an envelope is not
enough, since an envelope may itself wind around the origin.  Each conclusion is
therefore guarded by the exact topological boundary condition it needs.

**Synthesis (Principal Investigator).** The contour-integral charge now has an
explicit analytic kernel, and the kernel characterization yields robustness under
arbitrary smooth single-valued amplitude and polarization dressings.  This joins
complex analysis, the topology of the punctured plane, and optical charge
conservation in one structural statement.
-/

end KnottedLightLogLift