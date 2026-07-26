import Mathlib

/-! # Inverse Stereographic Renormalization Group

The renormalization group (RG) in physics "zooms out" by rescaling energy/length
scales.  Here we formalize the slogan

> *RG flow = iterated inverse stereographic projection on the energy sphere.*

The line `ℝ` is the space of (signed log-)energy coordinates `t`.  Inverse
stereographic projection `invStereo : ℝ → S¹ ⊂ ℝ²` wraps the line onto the
energy circle, sending `0 ↦ (0,1)` (the UV fixed point) and `t → ∞ ↦ (0,-1)`
(the IR fixed point).  Multiplicative rescaling `t ↦ λ·t` is the RG dilation on
the line; conjugating it by stereographic projection yields the **RG flow on the
circle** `rgFlow λ`.  The headline result `rgFlow_iterate` shows that iterating
the flow `n` times multiplies the scale by `λ^n` — exactly the one-parameter
(semi)group structure that *defines* a renormalization group.

This file is fully self-contained: it redefines `invStereo`/`stereoProj` so it
does not depend on the (currently non-compiling) auto-generated catalog stubs in
`Catalog/Geometry/InverseStereoResearch.lean` and
`Catalog/Computation/Oracles/Foundation.lean`, while reproving and *extending*
their core facts (`inv_stereo_on_circle`, `stereo_left_inverse`).

-- !-- Lab Notebook -- !--
Hypothesis: The physicists' RG semigroup is, up to a conjugacy, nothing more
  than multiplicative scaling of a real coordinate; stereographic projection
  realizes this conjugacy geometrically on a sphere/circle.
Result: Proven. `rgFlow λ` conjugates the dilation `t ↦ λt`, the conjugacy is
  exact on the image circle (`rgFlow_invStereo`), the flow is a semigroup
  (`rgFlow_semigroup`), it preserves the circle (`rgFlow_on_circle`), iterating
  it `n` times scales by `λ^n` (`rgFlow_iterate`), `(0,1)` is a universal fixed
  point (`rgFlow_uv_fixed`), and the IR endpoint `(0,-1)` is the `atTop` limit
  (`invStereo_tendsto_IR`).
Insight: The RG "loss of information when integrating out high modes" is *not*
  present at the level of the bijection — `invStereo` is injective with explicit
  inverse `stereoProj`.  Irreversibility only appears in the *iterated limit*
  λ^n → 0 or ∞, where every trajectory collapses onto a fixed point.  Thus RG
  irreversibility is a statement about the asymptotics of the abelian flow, not
  about the maps themselves.
Failure analysis: An earlier attempt tried to put the IR fixed point as an
  algebraic identity `rgFlow λ (0,-1) = (0,-1)`; this fails because `stereoProj`
  has a pole at the north pole `(0,-1)` (denominator `1 + y = 0`), so the IR
  fixed point is genuinely a *boundary/limit* object, captured correctly by a
  `Filter.Tendsto` statement rather than an equation.
-/

noncomputable section

namespace InverseStereoRG

/-- Inverse stereographic projection of the energy line onto the unit circle
`S¹ ⊂ ℝ²`. The parameter `t` is the energy coordinate. -/
def invStereo (t : ℝ) : ℝ × ℝ := (2 * t / (1 + t ^ 2), (1 - t ^ 2) / (1 + t ^ 2))

/-- Stereographic projection back to the line, from the north pole `(0,-1)`.
It is a left inverse of `invStereo` (see `stereoProj_invStereo`). -/
def stereoProj (p : ℝ × ℝ) : ℝ := p.1 / (1 + p.2)

-- !-- The image of `invStereo` lies on `S¹`: clear denominators and `ring`. -- !--
/-- **Energy sphere.** Every point produced by inverse stereographic projection
lies on the unit circle. -/
theorem invStereo_on_circle (t : ℝ) :
    (invStereo t).1 ^ 2 + (invStereo t).2 ^ 2 = 1 := by
  simp only [invStereo]
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  field_simp; ring

-- !-- `stereoProj ∘ invStereo = id`: field_simp collapses the nested fraction. -- !--
/-- **Exact reversibility.** `stereoProj` is a left inverse of `invStereo`, so no
information is lost by a single RG step. -/
theorem stereoProj_invStereo (t : ℝ) : stereoProj (invStereo t) = t := by
  simp only [invStereo, stereoProj]
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  field_simp; ring

-- !-- Injectivity follows from the explicit left inverse. -- !--
/-- **No compression.** Inverse stereographic projection is injective. -/
theorem invStereo_injective : Function.Injective invStereo :=
  Function.LeftInverse.injective stereoProj_invStereo

/-- The RG dilation on the energy line: multiplicative rescaling by `l`. -/
def dilate (l t : ℝ) : ℝ := l * t

/-- The **renormalization-group flow on the energy circle**: conjugate the line
dilation `dilate l` by stereographic projection. -/
def rgFlow (l : ℝ) (p : ℝ × ℝ) : ℝ × ℝ := invStereo (dilate l (stereoProj p))

-- !-- Unfold `rgFlow`, then `stereoProj_invStereo` cancels projection∘injection. -- !--
/-- **Conjugacy identity (key lemma).** On the image circle, the RG flow is
*exactly* the dilation read through the projection: `rgFlow l` scales the energy
parameter by `l`. -/
theorem rgFlow_invStereo (l t : ℝ) : rgFlow l (invStereo t) = invStereo (l * t) := by
  simp only [rgFlow, dilate, stereoProj_invStereo]

-- !-- Image of `rgFlow` is again an `invStereo` value, hence on the circle. -- !--
/-- **Circle preservation.** The RG flow maps the energy sphere to itself. -/
theorem rgFlow_on_circle (l : ℝ) (p : ℝ × ℝ) :
    (rgFlow l p).1 ^ 2 + (rgFlow l p).2 ^ 2 = 1 := invStereo_on_circle _

-- !-- Apply the conjugacy identity three times; `mul_assoc` matches the scales. -- !--
/-- **RG semigroup law.** Composing the flow at scales `l₁` and `l₂` equals the
flow at scale `l₁·l₂`: the renormalization group is abelian on the circle. -/
theorem rgFlow_semigroup (l₁ l₂ t : ℝ) :
    rgFlow l₁ (rgFlow l₂ (invStereo t)) = rgFlow (l₁ * l₂) (invStereo t) := by
  rw [rgFlow_invStereo, rgFlow_invStereo, rgFlow_invStereo, mul_assoc]

-- !-- Induction on `n`; the successor step uses `rgFlow_invStereo` then `ring_nf`. -- !--
/-- **Main theorem: RG flow = iterated inverse stereographic projection.**
Iterating the RG flow `n` times scales the energy parameter by `lⁿ`. This is the
defining one-parameter (semi)group property of the renormalization group,
realized geometrically as iterated stereographic transport on the energy
sphere. -/
theorem rgFlow_iterate (l t : ℝ) (n : ℕ) :
    (rgFlow l)^[n] (invStereo t) = invStereo (l ^ n * t) := by
  induction n with
  | zero => simp
  | succ k ih =>
    rw [Function.iterate_succ_apply', ih, rgFlow_invStereo]
    ring_nf

-- !-- Scaling fixes `t = 0`; `mul_zero` then the conjugacy identity. -- !--
/-- **UV fixed point.** The point `(0,1) = invStereo 0` is fixed by the RG flow
at every scale: it is the universal ultraviolet fixed point. -/
theorem rgFlow_uv_fixed (l : ℝ) : rgFlow l (invStereo 0) = invStereo 0 := by
  rw [rgFlow_invStereo, mul_zero]

/-
!-- Componentwise limits: `2t/(1+t²)→0` and `(1-t²)/(1+t²)→-1` as `t→∞`. -- !--

**IR fixed point as a limit.** As the energy coordinate runs to infinity the
RG trajectory collapses onto the north pole `(0,-1)`, the infrared fixed point.
This is a genuine boundary/limit phenomenon (`stereoProj` has a pole there), the
geometric face of RG irreversibility.
-/
theorem invStereo_tendsto_IR :
    Filter.Tendsto invStereo Filter.atTop (nhds (0, -1)) := by
  refine' Filter.Tendsto.prodMk_nhds _ _;
  · rw [ Metric.tendsto_nhds ];
    exact fun ε hε => Filter.eventually_atTop.2 ⟨ ε⁻¹ * 2, fun x hx => abs_lt.2 ⟨ by rw [ lt_sub_iff_add_lt ] ; rw [ lt_div_iff₀ ] <;> nlinarith [ inv_pos.2 hε, mul_inv_cancel₀ hε.ne' ], by rw [ sub_lt_iff_lt_add' ] ; rw [ div_lt_iff₀ ] <;> nlinarith [ inv_pos.2 hε, mul_inv_cancel₀ hε.ne' ] ⟩ ⟩;
  · erw [ Metric.tendsto_nhds ] ; intro ε hε ; refine' Filter.eventually_atTop.mpr ⟨ ⌈ε⁻¹ * 2⌉₊ + 1, fun t ht => _ ⟩ ; refine' abs_lt.mpr ⟨ _, _ ⟩ <;> nlinarith [ Nat.le_ceil ( ε⁻¹ * 2 ), mul_inv_cancel₀ ( ne_of_gt hε ), sq_nonneg ( t - 1 ), mul_div_cancel₀ ( 1 - t ^ 2 ) ( by positivity : ( 1 + t ^ 2 ) ≠ 0 ) ]

end InverseStereoRG