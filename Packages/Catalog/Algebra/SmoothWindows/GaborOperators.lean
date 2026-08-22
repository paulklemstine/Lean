import Mathlib

/-!
# Smooth windows I: translation, modulation and the Weyl relation

The Reciprocal-Zero Harmonics programme (`Algebra.ReciprocalZeroHarmonics.Core`,
`Algebra.ReciprocalZeroHarmonics.WindowDichotomy`) analyses spectral data through the
*rectangular* window `|Im ρ| ≤ T`.  This file lays the algebraic foundation for replacing that
sharp cutoff by a smooth (Gaussian / Schwartz) window: the two families of operators that move a
window around phase space,

* **translation** `(T_a f)(t) = f (t - a)`,
* **modulation** `(M_b f)(t) = e^{2πi b t} f (t)`,

and the *modulation/translation identity* (the Weyl commutation relation) that they satisfy.

## Main results

* `modOp_transOp` — **Weyl commutation relation**: `M_b T_a = χ(b a) · T_a M_b`, where
  `χ(x) = e^{2πix}`.  Translation and modulation commute only up to the phase `e^{2πi ab}`; this
  failure of commutativity *is* the Heisenberg group.
* `Heis` — the (circle-valued) **Heisenberg group** with multiplication
  `(a,b,z)·(a',b',z') = (a+a', b+b', z z' χ(b a'))`, with a full `Group` instance proved from the
  cocycle identity.
* `heisRep` — the **Schrödinger/Gabor representation** `Heis →* Function.End (ℝ → ℂ)`,
  `(a,b,z) ↦ z · T_a M_b`: a genuine monoid homomorphism, i.e. the Weyl relation is exactly what
  makes the composite of two Gabor shifts a third one.
* `heisRep_injective` — the representation is **faithful**: the Gaussian is a test vector which
  separates all Heisenberg elements.  Consequently the phase factor in `modOp_transOp` cannot be
  removed by any renormalisation of the operators.
* `modOp_transOp_ne` — an adversarial check: the phase is really needed, the two orders of
  composition differ on any window that is nonzero at the origin.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** Windowing should be an *action of a group*, not an ad hoc
  cutoff; the correct group is the Heisenberg group, and the rectangular window of the catalog is
  merely one (non-smooth) vector in a representation space.
* **Experiment (Experimenter).** All operator identities reduce to `Complex.exp_add` after
  clearing casts; the group axioms for `Heis` reduce to the cocycle identity
  `b·a' + (b+b')·a'' = b'·a'' + b·(a' + a'')`.  Faithfulness needed a genuinely analytic input:
  the Gaussian test vector is nowhere zero and has a unique maximum, which pins down `a`, then
  the phase `z`, then the modulation `b` via `χ(1/4) = i ≠ 1`.
* **Analysis (Analyst).** The phase cocycle `χ(ba')` is not a coboundary — faithfulness shows the
  central `Circle` factor is not redundant.  This is the structural reason a *smooth* window can
  be moved freely in phase space while keeping all of its algebraic bookkeeping exact.
* **Critique (Critic).** Nothing here is definitional: `modOp_transOp` is false without the phase
  (`modOp_transOp_ne`), and `heisRep_injective` shows the group is not a proper quotient.
-/

namespace SmoothWindows

open Complex Real

/-! ## The character `χ(x) = e^{2πix}` -/

/-- The basic additive character `χ(x) = e^{2πix}` of `ℝ`. -/
noncomputable def chi (x : ℝ) : ℂ := Complex.exp ((2 * π * x : ℝ) * Complex.I)

@[simp] theorem chi_zero : chi 0 = 1 := by simp [chi]

theorem chi_add (x y : ℝ) : chi (x + y) = chi x * chi y := by
  unfold chi
  rw [← Complex.exp_add]
  push_cast
  ring_nf

@[simp] theorem chi_ne_zero (x : ℝ) : chi x ≠ 0 := Complex.exp_ne_zero _

@[simp] theorem norm_chi (x : ℝ) : ‖chi x‖ = 1 := by
  rw [chi]
  exact Complex.norm_exp_ofReal_mul_I (2 * π * x)

theorem chi_neg (x : ℝ) : chi (-x) = (chi x)⁻¹ := by
  refine eq_inv_of_mul_eq_one_left ?_
  rw [← chi_add]
  simp

/-- `χ` is the coercion of `Circle.exp (2πx)`. -/
theorem coe_circleExp (x : ℝ) : (Circle.exp (2 * π * x) : ℂ) = chi x := by
  rw [Circle.coe_exp, chi]

/-- `χ(x) = 1` exactly on the integers.  (Used to detect the modulation parameter.) -/
theorem chi_eq_one_iff (x : ℝ) : chi x = 1 ↔ ∃ n : ℤ, x = n := by
  unfold chi
  rw [Complex.exp_eq_one_iff]
  constructor
  · rintro ⟨n, hn⟩
    refine ⟨n, ?_⟩
    have hn' : ((2 * π * x : ℝ) : ℂ) = (n : ℂ) * (2 * π) := by
      have h := hn
      rw [show (n : ℂ) * (2 * (π : ℂ) * Complex.I) = ((n : ℂ) * (2 * (π : ℂ))) * Complex.I by
        ring] at h
      exact mul_right_cancel₀ Complex.I_ne_zero h
    have h3 : 2 * π * x = (n : ℝ) * (2 * π) := by exact_mod_cast hn'
    have hpi : (2 * π : ℝ) ≠ 0 := by positivity
    exact mul_left_cancel₀ hpi (by linarith)
  · rintro ⟨n, rfl⟩
    exact ⟨n, by push_cast; ring⟩

theorem chi_quarter_ne_one : chi (1 / 4 : ℝ) ≠ 1 := by
  intro hchi
  rw [chi_eq_one_iff] at hchi
  obtain ⟨n, hn⟩ := hchi
  have h4 : (4 : ℝ) * (n : ℝ) = 1 := by rw [← hn]; norm_num
  have : (4 : ℤ) * n = 1 := by exact_mod_cast h4
  omega

/-! ## Translation and modulation -/

/-- **Translation** `(T_a f)(t) = f (t - a)`. -/
def transOp (a : ℝ) (f : ℝ → ℂ) : ℝ → ℂ := fun t => f (t - a)

/-- **Modulation** `(M_b f)(t) = e^{2πi b t} f (t)`. -/
noncomputable def modOp (b : ℝ) (f : ℝ → ℂ) : ℝ → ℂ := fun t => chi (b * t) * f t

@[simp] theorem transOp_zero (f : ℝ → ℂ) : transOp 0 f = f := by
  funext t; simp [transOp]

@[simp] theorem modOp_zero (f : ℝ → ℂ) : modOp 0 f = f := by
  funext t; simp [modOp]

theorem transOp_transOp (a a' : ℝ) (f : ℝ → ℂ) :
    transOp a (transOp a' f) = transOp (a + a') f := by
  funext t; simp [transOp, sub_sub]

theorem modOp_modOp (b b' : ℝ) (f : ℝ → ℂ) :
    modOp b (modOp b' f) = modOp (b + b') f := by
  funext t
  simp only [modOp, ← mul_assoc, ← chi_add]
  ring_nf

/-- Translation and modulation are `ℂ`-linear in the window. -/
theorem transOp_add (a : ℝ) (f g : ℝ → ℂ) :
    transOp a (f + g) = transOp a f + transOp a g := rfl

theorem modOp_add (b : ℝ) (f g : ℝ → ℂ) :
    modOp b (f + g) = modOp b f + modOp b g := by
  funext t; simp [modOp, mul_add]

/-- **The modulation/translation identity (Weyl commutation relation).**
`M_b T_a = χ(ab) · T_a M_b`: modulation and translation commute only up to the phase
`e^{2πiab}`. -/
theorem modOp_transOp (a b : ℝ) (f : ℝ → ℂ) :
    modOp b (transOp a f) = fun t => chi (b * a) * transOp a (modOp b f) t := by
  funext t
  simp only [modOp, transOp, ← mul_assoc, ← chi_add]
  ring_nf

/-- The reversed form of the Weyl relation: `T_a M_b = χ(-ab) · M_b T_a`. -/
theorem transOp_modOp (a b : ℝ) (f : ℝ → ℂ) :
    transOp a (modOp b f) = fun t => chi (-(b * a)) * modOp b (transOp a f) t := by
  funext t
  rw [modOp_transOp a b f]
  simp only [← mul_assoc, ← chi_add]
  rw [show -(b * a) + b * a = 0 by ring, chi_zero, one_mul]

/-- The Weyl phase is genuinely there: for `a = b = 1/2` the two orders of composition differ on
any window that does not vanish at the origin.  (Adversarial check that `modOp_transOp` is not a
triviality.) -/
theorem modOp_transOp_ne (f : ℝ → ℂ) (hf : f 0 ≠ 0) :
    modOp (1 / 2) (transOp (1 / 2) f) ≠ transOp (1 / 2) (modOp (1 / 2) f) := by
  intro h
  have h0 := congrFun h (1 / 2 : ℝ)
  simp only [modOp, transOp] at h0
  rw [show (1 / 2 : ℝ) - 1 / 2 = 0 by norm_num,
    show (1 / 2 : ℝ) * (1 / 2) = 1 / 4 by norm_num, mul_zero, chi_zero, one_mul] at h0
  have := mul_right_cancel₀ hf (by simpa using h0 : chi (1 / 4 : ℝ) * f 0 = 1 * f 0)
  exact chi_quarter_ne_one this

/-! ## The Heisenberg group and the Gabor representation -/

/-- The (circle-valued) **Heisenberg group**: triples `(a, b, z)` of a translation, a modulation
and a unimodular phase, multiplied through the Weyl cocycle. -/
structure Heis where
  /-- the translation parameter -/
  a : ℝ
  /-- the modulation parameter -/
  b : ℝ
  /-- the central phase -/
  z : Circle

namespace Heis

@[ext] theorem ext {g h : Heis} (ha : g.a = h.a) (hb : g.b = h.b) (hz : g.z = h.z) : g = h := by
  cases g; cases h; simp_all

noncomputable instance : One Heis := ⟨⟨0, 0, 1⟩⟩

noncomputable instance : Mul Heis :=
  ⟨fun g h => ⟨g.a + h.a, g.b + h.b, g.z * h.z * Circle.exp (2 * π * (g.b * h.a))⟩⟩

noncomputable instance : Inv Heis :=
  ⟨fun g => ⟨-g.a, -g.b, g.z⁻¹ * Circle.exp (2 * π * (g.b * g.a))⟩⟩

@[simp] theorem one_a : (1 : Heis).a = 0 := rfl
@[simp] theorem one_b : (1 : Heis).b = 0 := rfl
@[simp] theorem one_z : (1 : Heis).z = 1 := rfl
@[simp] theorem mul_a (g h : Heis) : (g * h).a = g.a + h.a := rfl
@[simp] theorem mul_b (g h : Heis) : (g * h).b = g.b + h.b := rfl
@[simp] theorem mul_z (g h : Heis) :
    (g * h).z = g.z * h.z * Circle.exp (2 * π * (g.b * h.a)) := rfl
@[simp] theorem inv_a (g : Heis) : g⁻¹.a = -g.a := rfl
@[simp] theorem inv_b (g : Heis) : g⁻¹.b = -g.b := rfl
@[simp] theorem inv_z (g : Heis) : g⁻¹.z = g.z⁻¹ * Circle.exp (2 * π * (g.b * g.a)) := rfl

/-- The Heisenberg group law: associativity is precisely the 2-cocycle identity for the Weyl
phase `2π b a'`. -/
noncomputable instance : Group Heis where
  mul_assoc g h k := by
    refine Heis.ext (by simp [add_assoc]) (by simp [add_assoc]) ?_
    have e1 : Circle.exp (2 * π * ((g.b + h.b) * k.a))
        = Circle.exp (2 * π * (h.b * k.a)) * Circle.exp (2 * π * (g.b * k.a)) := by
      rw [← Circle.exp_add]; ring_nf
    have e2 : Circle.exp (2 * π * (g.b * (h.a + k.a)))
        = Circle.exp (2 * π * (g.b * h.a)) * Circle.exp (2 * π * (g.b * k.a)) := by
      rw [← Circle.exp_add]; ring_nf
    simp only [mul_z, mul_a, mul_b, e1, e2]
    simp [mul_comm, mul_left_comm, mul_assoc]
  one_mul g := Heis.ext (by simp) (by simp) (by simp)
  mul_one g := Heis.ext (by simp) (by simp) (by simp)
  inv_mul_cancel g := by
    refine Heis.ext (by simp) (by simp) ?_
    have : Circle.exp (2 * π * (g.b * g.a)) * Circle.exp (2 * π * (-g.b * g.a)) = 1 := by
      rw [← Circle.exp_add, show 2 * π * (g.b * g.a) + 2 * π * (-g.b * g.a) = 0 by ring]
      simp
    simp only [mul_z, inv_b, inv_z, one_z]
    rw [mul_assoc, mul_mul_mul_comm, inv_mul_cancel, this, mul_one]

end Heis

/-- The **Schrödinger (Gabor) representation** of the Heisenberg group on functions `ℝ → ℂ`:
`(a, b, z) ↦ z · T_a M_b`. -/
noncomputable def gaborAct (g : Heis) (f : ℝ → ℂ) : ℝ → ℂ :=
  fun t => (g.z : ℂ) * transOp g.a (modOp g.b f) t

theorem gaborAct_apply (g : Heis) (f : ℝ → ℂ) (t : ℝ) :
    gaborAct g f t = (g.z : ℂ) * chi (g.b * (t - g.a)) * f (t - g.a) := by
  simp [gaborAct, transOp, modOp, mul_assoc]

@[simp] theorem gaborAct_one (f : ℝ → ℂ) : gaborAct 1 f = f := by
  funext t; simp [gaborAct_apply]

/-- **The representation property.**  The composite of two Gabor shifts is the Gabor shift of the
Heisenberg product — this is exactly the modulation/translation identity in group form. -/
theorem gaborAct_mul (g h : Heis) (f : ℝ → ℂ) :
    gaborAct (g * h) f = gaborAct g (gaborAct h f) := by
  funext t
  simp only [gaborAct_apply, Heis.mul_a, Heis.mul_b, Heis.mul_z, Circle.coe_mul, coe_circleExp]
  rw [show t - (g.a + h.a) = (t - g.a) - h.a by ring,
    show chi ((g.b + h.b) * (t - g.a - h.a))
      = chi (g.b * (t - g.a)) * chi (h.b * ((t - g.a) - h.a)) * (chi (g.b * h.a))⁻¹ by
      rw [← chi_add, ← chi_neg, ← chi_add]; congr 1; ring]
  field_simp

/-- The Gabor representation packaged as a monoid homomorphism into the endomorphism monoid of
the space of windows. -/
noncomputable def heisRep : Heis →* Function.End (ℝ → ℂ) where
  toFun g := gaborAct g
  map_one' := by funext f; exact gaborAct_one f
  map_mul' g h := by funext f; exact gaborAct_mul g h f

/-- Every Gabor operator is invertible, with inverse the Gabor operator of the inverse group
element. -/
theorem gaborAct_leftInverse (g : Heis) (f : ℝ → ℂ) : gaborAct g⁻¹ (gaborAct g f) = f := by
  rw [← gaborAct_mul, inv_mul_cancel, gaborAct_one]

/-- The Gaussian test window used to prove faithfulness. -/
noncomputable def gaussTest : ℝ → ℂ := fun t => ((Real.exp (-t ^ 2) : ℝ) : ℂ)

theorem gaussTest_ne_zero (t : ℝ) : gaussTest t ≠ 0 := by
  simp [gaussTest]

theorem norm_gaussTest (t : ℝ) : ‖gaussTest t‖ = Real.exp (-t ^ 2) := by
  rw [gaussTest, Complex.norm_real, Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]

/-- **Faithfulness of the Gabor representation.**  If a Gabor shift acts trivially (on all
windows, in particular on the Gaussian) then it is the identity element: the translation
parameter is detected by the position of the Gaussian's maximum, the phase by the value there,
and the modulation parameter by the fact that `χ` is not constant. -/
theorem heisRep_injective : Function.Injective heisRep := by
  rw [injective_iff_map_eq_one]
  intro g hg
  have hfun : gaborAct g gaussTest = gaussTest := congrFun hg gaussTest
  -- Step 1: `a = 0`, read off from the modulus.
  have hmod : ∀ t : ℝ, Real.exp (-(t - g.a) ^ 2) = Real.exp (-t ^ 2) := by
    intro t
    have h := congrFun hfun t
    rw [gaborAct_apply] at h
    have h' := congrArg (‖·‖) h
    simpa [norm_gaussTest, norm_chi, Complex.norm_mul, Circle.norm_coe] using h'
  have ha : g.a = 0 := by
    have h1 := hmod 0
    have h2 := hmod g.a
    rw [Real.exp_eq_exp] at h1 h2
    nlinarith [h1, h2]
  -- Step 2: the remaining identity is `z·χ(bt) = 1` for all `t`.
  have hphase : ∀ t : ℝ, (g.z : ℂ) * chi (g.b * t) = 1 := by
    intro t
    have h := congrFun hfun t
    rw [gaborAct_apply, ha, sub_zero] at h
    have hne : gaussTest t ≠ 0 := gaussTest_ne_zero t
    have : (g.z : ℂ) * chi (g.b * t) * gaussTest t = 1 * gaussTest t := by
      rw [one_mul]; exact h
    exact mul_right_cancel₀ hne this
  have hz : (g.z : ℂ) = 1 := by simpa using hphase 0
  have hb : g.b = 0 := by
    by_contra hb0
    have h := hphase (1 / (4 * g.b))
    rw [hz, one_mul, show g.b * (1 / (4 * g.b)) = 1 / 4 by field_simp] at h
    exact chi_quarter_ne_one h
  exact Heis.ext ha hb (by ext; simpa using hz)

end SmoothWindows