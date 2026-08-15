import Applications.MordellKernelSubgroup
import Applications.MordellInfiniteOrbit

/-!
# Effective apparition: every good prime divides some orbit denominator

Work in progress (cycle 6).
-/

namespace MordellDenominators

open WeierstrassCurve WeierstrassCurve.Affine

/-! ## A reduction toolkit for `ℓ`-integral rationals -/

/-- The `y`-coordinate of an affine point, `none` at the point at infinity. -/
def yCoord {R : Type*} [CommRing R] {W : Affine R} : W.Point → Option R
  | .zero => none
  | @WeierstrassCurve.Affine.Point.some _ _ _ _ y _ => some y

/-- The reduction of a rational number modulo a prime `ℓ`: `num · den⁻¹` in `ZMod ℓ`.
For `ℓ`-integral rationals this is the usual reduction map. -/
def redQ (ℓ : ℕ) (q : ℚ) : ZMod ℓ := (q.num : ZMod ℓ) * ((q.den : ZMod ℓ))⁻¹

lemma den_cast_ne_zero {ℓ : ℕ} [Fact ℓ.Prime] {q : ℚ} (hd : ¬ ℓ ∣ q.den) :
    ((q.den : ZMod ℓ)) ≠ 0 := fun h => hd ((ZMod.natCast_eq_zero_iff _ _).mp h)

/-- The reduction of an `ℓ`-integral rational vanishes exactly when `ℓ` divides its
numerator. -/
lemma redQ_eq_zero_iff {ℓ : ℕ} [Fact ℓ.Prime] {q : ℚ} (hd : ¬ ℓ ∣ q.den) :
    redQ ℓ q = 0 ↔ (ℓ : ℤ) ∣ q.num := by
  rw [redQ, mul_eq_zero]
  constructor
  · rintro (h | h)
    · exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).mp h
    · exact absurd (inv_eq_zero.mp h) (den_cast_ne_zero hd)
  · intro h
    exact Or.inl ((ZMod.intCast_zmod_eq_zero_iff_dvd _ _).mpr h)

/-- Equality of reductions, cleared of denominators. -/
lemma redQ_cross {ℓ : ℕ} [Fact ℓ.Prime] {q r : ℚ} (hq : ¬ ℓ ∣ q.den) (hr : ¬ ℓ ∣ r.den)
    (h : redQ ℓ q = redQ ℓ r) :
    (q.num : ZMod ℓ) * (r.den : ZMod ℓ) = (r.num : ZMod ℓ) * (q.den : ZMod ℓ) := by
  have hq0 := den_cast_ne_zero hq
  have hr0 := den_cast_ne_zero hr
  rw [redQ, redQ] at h
  field_simp at h
  linear_combination h

/-! ## The arithmetic core: colliding reductions force a kernel point -/

/-- The integral curve equation attached to a rational point: with `x = a/d`, `y = b/f` in
lowest terms, `b²d³ = a³f² + N f² d³`. -/
lemma mordell_int_equation {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + (N : ℚ)) :
    y.num ^ 2 * (x.den : ℤ) ^ 3 = x.num ^ 3 * (y.den : ℤ) ^ 2
      + N * (y.den : ℤ) ^ 2 * (x.den : ℤ) ^ 3 := by
  have hd : ((x.den : ℤ) : ℚ) ≠ 0 := by exact_mod_cast x.den_ne_zero
  have hf : ((y.den : ℤ) : ℚ) ≠ 0 := by exact_mod_cast y.den_ne_zero
  have hx : ((x.num : ℤ) : ℚ) / ((x.den : ℤ) : ℚ) = x := by push_cast; exact Rat.num_div_den x
  have hy : ((y.num : ℤ) : ℚ) / ((y.den : ℤ) : ℚ) = y := by push_cast; exact Rat.num_div_den y
  have : ((y.num ^ 2 * (x.den : ℤ) ^ 3 : ℤ) : ℚ)
      = ((x.num ^ 3 * (y.den : ℤ) ^ 2 + N * (y.den : ℤ) ^ 2 * (x.den : ℤ) ^ 3 : ℤ) : ℚ) := by
    push_cast
    rw [← hx, ← hy] at h
    field_simp at h ⊢
    linear_combination h
  exact_mod_cast this

/-- The chord `x`-coordinate written as a ratio of two integers, for points given in the form
`x = a/d`, `y = b/f`. -/
lemma chord_int_frac {N a₁ d₁ b₁ f₁ a₂ d₂ b₂ f₂ : ℤ}
    (hd₁ : (d₁ : ℚ) ≠ 0) (hd₂ : (d₂ : ℚ) ≠ 0) (hf₁ : (f₁ : ℚ) ≠ 0) (hf₂ : (f₂ : ℚ) ≠ 0)
    (hk : ((a₁ * d₂ - a₂ * d₁ : ℤ) : ℚ) ≠ 0) :
    ((a₁ : ℚ) / d₁ * ((a₂ : ℚ) / d₂) * ((a₁ : ℚ) / d₁ + (a₂ : ℚ) / d₂) + 2 * (N : ℚ)
        + 2 * ((b₁ : ℚ) / f₁) * ((b₂ : ℚ) / f₂)) / ((a₁ : ℚ) / d₁ - (a₂ : ℚ) / d₂) ^ 2
      = ((a₁ * a₂ * (a₁ * d₂ + a₂ * d₁) * f₁ * f₂ + 2 * N * d₁ ^ 2 * d₂ ^ 2 * f₁ * f₂
          + 2 * b₁ * b₂ * d₁ ^ 2 * d₂ ^ 2 : ℤ) : ℚ)
        / (((a₁ * d₂ - a₂ * d₁) ^ 2 * f₁ * f₂ : ℤ) : ℚ) := by
  push_cast at hk ⊢
  have hsub : ((a₁ : ℚ) / d₁ - (a₂ : ℚ) / d₂) ≠ 0 := by
    intro h
    apply hk
    field_simp at h
    linarith [h]
  rw [div_eq_div_iff (pow_ne_zero 2 hsub)
    (by exact mul_ne_zero (mul_ne_zero (pow_ne_zero 2 hk) hf₁) hf₂)]
  field_simp

/-- A prime `ℓ ≥ 5` is invertible modulo itself in the sense that `4 ≠ 0` in `ZMod ℓ`. -/
lemma four_ne_zero_zmod {ℓ : ℕ} (hl5 : 5 ≤ ℓ) : ((4 : ℤ) : ZMod ℓ) ≠ 0 := by
  intro h
  have : (ℓ : ℤ) ∣ 4 := (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).mp h
  have := Int.le_of_dvd (by norm_num) this
  omega

lemma intCast_ne_zero_of_not_dvd {ℓ : ℕ} {m : ℤ} (h : ¬(ℓ : ℤ) ∣ m) : ((m : ℤ) : ZMod ℓ) ≠ 0 :=
  fun hc => h ((ZMod.intCast_zmod_eq_zero_iff_dvd _ _).mp hc)

/-- **The arithmetic core.**  Two `ℓ`-integral points of `E_N` with the same reduction modulo a
good prime `ℓ ≥ 5`, at which the common reduced `y`-coordinate is nonzero, have a difference
whose `x`-coordinate is *not* `ℓ`-integral: the prime `ℓ` divides its denominator.  Everything
is phrased through the integral data `x = a/d`, `y = b/f`. -/
lemma dvd_den_chord_abstract {N a₁ d₁ b₁ f₁ a₂ d₂ b₂ f₂ : ℤ} {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ)
    (hd₁ : d₁ ≠ 0) (hd₂ : d₂ ≠ 0) (hf₁ : f₁ ≠ 0) (hf₂ : f₂ ≠ 0)
    (hld₁ : ¬(ℓ : ℤ) ∣ d₁) (hld₂ : ¬(ℓ : ℤ) ∣ d₂) (hlf₁ : ¬(ℓ : ℤ) ∣ f₁) (hlf₂ : ¬(ℓ : ℤ) ∣ f₂)
    (hcurve : b₁ ^ 2 * d₁ ^ 3 = a₁ ^ 3 * f₁ ^ 2 + N * f₁ ^ 2 * d₁ ^ 3)
    (hu : (ℓ : ℤ) ∣ a₁ * d₂ - a₂ * d₁) (hw : (ℓ : ℤ) ∣ b₁ * f₂ - b₂ * f₁)
    (hb₁ : ¬(ℓ : ℤ) ∣ b₁) (hk : a₁ * d₂ - a₂ * d₁ ≠ 0) :
    ℓ ∣ (((a₁ : ℚ) / d₁ * ((a₂ : ℚ) / d₂) * ((a₁ : ℚ) / d₁ + (a₂ : ℚ) / d₂) + 2 * (N : ℚ)
        + 2 * ((b₁ : ℚ) / f₁) * ((b₂ : ℚ) / f₂)) / ((a₁ : ℚ) / d₁ - (a₂ : ℚ) / d₂) ^ 2).den := by
  haveI := Fact.mk hl
  have hd₁' : ((d₁ : ℤ) : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hd₁
  have hd₂' : ((d₂ : ℤ) : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hd₂
  have hf₁' : ((f₁ : ℤ) : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hf₁
  have hf₂' : ((f₂ : ℤ) : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hf₂
  have hk' : ((a₁ * d₂ - a₂ * d₁ : ℤ) : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hk
  rw [chord_int_frac hd₁' hd₂' hf₁' hf₂' hk']
  refine prime_dvd_den ?_ hl ?_ ?_
  · exact mul_ne_zero (mul_ne_zero (pow_ne_zero 2 hk) hf₁) hf₂
  · exact Dvd.dvd.mul_right (Dvd.dvd.mul_right (dvd_pow hu two_ne_zero) f₁) f₂
  · -- the numerator reduces to `4 b₁ b₂ d₁² d₂²`, which is prime to `ℓ`
    intro hA
    have h0 : ((a₁ * a₂ * (a₁ * d₂ + a₂ * d₁) * f₁ * f₂ + 2 * N * d₁ ^ 2 * d₂ ^ 2 * f₁ * f₂
        + 2 * b₁ * b₂ * d₁ ^ 2 * d₂ ^ 2 : ℤ) : ZMod ℓ) = 0 :=
      (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).mpr hA
    have hu0 : ((a₁ : ℤ) : ZMod ℓ) * ((d₂ : ℤ) : ZMod ℓ)
        = ((a₂ : ℤ) : ZMod ℓ) * ((d₁ : ℤ) : ZMod ℓ) := by
      have := (ZMod.intCast_zmod_eq_zero_iff_dvd (a₁ * d₂ - a₂ * d₁) ℓ).mpr hu
      push_cast at this
      linear_combination this
    have hw0 : ((b₁ : ℤ) : ZMod ℓ) * ((f₂ : ℤ) : ZMod ℓ)
        = ((b₂ : ℤ) : ZMod ℓ) * ((f₁ : ℤ) : ZMod ℓ) := by
      have := (ZMod.intCast_zmod_eq_zero_iff_dvd (b₁ * f₂ - b₂ * f₁) ℓ).mpr hw
      push_cast at this
      linear_combination this
    have hc0 : ((b₁ : ℤ) : ZMod ℓ) ^ 2 * ((d₁ : ℤ) : ZMod ℓ) ^ 3
        = ((a₁ : ℤ) : ZMod ℓ) ^ 3 * ((f₁ : ℤ) : ZMod ℓ) ^ 2
          + ((N : ℤ) : ZMod ℓ) * ((f₁ : ℤ) : ZMod ℓ) ^ 2 * ((d₁ : ℤ) : ZMod ℓ) ^ 3 := by
      exact_mod_cast congrArg (fun m : ℤ => ((m : ℤ) : ZMod ℓ)) hcurve
    push_cast at h0
    have hkey : (4 : ZMod ℓ) * (b₁ : ZMod ℓ) * (b₂ : ZMod ℓ) * (d₁ : ZMod ℓ) ^ 3
        * (d₂ : ZMod ℓ) ^ 2 * (f₁ : ZMod ℓ) = 0 := by
      push_cast at hu0 hw0 hc0
      linear_combination (d₁ : ZMod ℓ) * (f₁ : ZMod ℓ) * h0
        + ((a₁ : ZMod ℓ) * (f₁ : ZMod ℓ) ^ 2 * (f₂ : ZMod ℓ)
            * (2 * (a₁ : ZMod ℓ) * (d₂ : ZMod ℓ) + (a₂ : ZMod ℓ) * (d₁ : ZMod ℓ))) * hu0
        - (2 * (b₁ : ZMod ℓ) * (d₁ : ZMod ℓ) ^ 3 * (d₂ : ZMod ℓ) ^ 2) * hw0
        + (2 * (d₂ : ZMod ℓ) ^ 2 * (f₂ : ZMod ℓ)) * hc0
    have hb₁0 : ((b₁ : ℤ) : ZMod ℓ) ≠ 0 := intCast_ne_zero_of_not_dvd hb₁
    have hb₂0 : ((b₂ : ℤ) : ZMod ℓ) ≠ 0 := by
      intro hc
      rw [hc, zero_mul] at hw0
      exact hb₁0 ((mul_eq_zero.mp hw0).resolve_right (intCast_ne_zero_of_not_dvd hlf₂))
    have h4 : (4 : ZMod ℓ) ≠ 0 := by
      have := four_ne_zero_zmod (ℓ := ℓ) hl5
      push_cast at this
      exact this
    push_cast at hb₁0 hb₂0
    have hd₁0 : ((d₁ : ℤ) : ZMod ℓ) ≠ 0 := intCast_ne_zero_of_not_dvd hld₁
    have hd₂0 : ((d₂ : ℤ) : ZMod ℓ) ≠ 0 := intCast_ne_zero_of_not_dvd hld₂
    have hf₁0 : ((f₁ : ℤ) : ZMod ℓ) ≠ 0 := intCast_ne_zero_of_not_dvd hlf₁
    push_cast at hd₁0 hd₂0 hf₁0
    exact absurd hkey (by
      refine mul_ne_zero (mul_ne_zero (mul_ne_zero (mul_ne_zero (mul_ne_zero h4 hb₁0) hb₂0)
        (pow_ne_zero 3 hd₁0)) (pow_ne_zero 2 hd₂0)) hf₁0)

/-- Equality of reductions of two `ℓ`-integral rationals, in cross-multiplied integral form. -/
lemma dvd_cross_of_redQ_eq {ℓ : ℕ} [Fact ℓ.Prime] {q r : ℚ} (hq : ¬ ℓ ∣ q.den)
    (hr : ¬ ℓ ∣ r.den) (h : redQ ℓ q = redQ ℓ r) :
    (ℓ : ℤ) ∣ q.num * (r.den : ℤ) - r.num * (q.den : ℤ) := by
  have hcross := redQ_cross hq hr h
  refine (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).mp ?_
  push_cast
  push_cast at hcross
  linear_combination hcross

/-- **The arithmetic core, in terms of rational points.**  If two `ℓ`-integral points of
`E_N : y² = x³ + N` have the same reduction modulo a good prime `ℓ ≥ 5`, the reduced
`y`-coordinate being nonzero, and their `x`-coordinates differ, then `ℓ` divides the denominator
of the chord expression — the `x`-coordinate of their difference. -/
lemma dvd_den_chord_of_res_eq {N : ℤ} {x₁ y₁ x₂ y₂ : ℚ}
    (h₁ : y₁ ^ 2 = x₁ ^ 3 + (N : ℚ)) (h₂ : y₂ ^ 2 = x₂ ^ 3 + (N : ℚ))
    {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ)
    (hd₁ : ¬ ℓ ∣ x₁.den) (hd₂ : ¬ ℓ ∣ x₂.den)
    (hx : redQ ℓ x₁ = redQ ℓ x₂) (hy : redQ ℓ y₁ = redQ ℓ y₂)
    (hy0 : ¬ (ℓ : ℤ) ∣ y₁.num) (hne : x₁ ≠ x₂) :
    ℓ ∣ ((x₁ * x₂ * (x₁ + x₂) + 2 * (N : ℚ) + 2 * y₁ * y₂) / (x₁ - x₂) ^ 2).den := by
  haveI := Fact.mk hl
  have hf₁ : ¬ ℓ ∣ y₁.den := not_dvd_den_y h₁ hl hd₁
  have hf₂ : ¬ ℓ ∣ y₂.den := not_dvd_den_y h₂ hl hd₂
  have hcx₁ : ((x₁.num : ℤ) : ℚ) / (((x₁.den : ℤ)) : ℚ) = x₁ := by
    push_cast; exact Rat.num_div_den x₁
  have hcx₂ : ((x₂.num : ℤ) : ℚ) / (((x₂.den : ℤ)) : ℚ) = x₂ := by
    push_cast; exact Rat.num_div_den x₂
  have hcy₁ : ((y₁.num : ℤ) : ℚ) / (((y₁.den : ℤ)) : ℚ) = y₁ := by
    push_cast; exact Rat.num_div_den y₁
  have hcy₂ : ((y₂.num : ℤ) : ℚ) / (((y₂.den : ℤ)) : ℚ) = y₂ := by
    push_cast; exact Rat.num_div_den y₂
  have hk : x₁.num * (x₂.den : ℤ) - x₂.num * (x₁.den : ℤ) ≠ 0 := by
    intro hc
    refine hne ?_
    rw [← hcx₁, ← hcx₂, div_eq_div_iff (by exact_mod_cast x₁.den_ne_zero)
      (by exact_mod_cast x₂.den_ne_zero)]
    exact_mod_cast sub_eq_zero.mp hc
  have heq : (((x₁.num : ℤ) : ℚ) / ((x₁.den : ℤ) : ℚ)
        * (((x₂.num : ℤ) : ℚ) / ((x₂.den : ℤ) : ℚ))
        * (((x₁.num : ℤ) : ℚ) / ((x₁.den : ℤ) : ℚ)
          + ((x₂.num : ℤ) : ℚ) / ((x₂.den : ℤ) : ℚ)) + 2 * (N : ℚ)
        + 2 * (((y₁.num : ℤ) : ℚ) / ((y₁.den : ℤ) : ℚ))
          * (((y₂.num : ℤ) : ℚ) / ((y₂.den : ℤ) : ℚ)))
      / (((x₁.num : ℤ) : ℚ) / ((x₁.den : ℤ) : ℚ)
        - ((x₂.num : ℤ) : ℚ) / ((x₂.den : ℤ) : ℚ)) ^ 2
      = (x₁ * x₂ * (x₁ + x₂) + 2 * (N : ℚ) + 2 * y₁ * y₂) / (x₁ - x₂) ^ 2 := by
    rw [hcx₁, hcx₂, hcy₁, hcy₂]
  rw [← heq]
  refine dvd_den_chord_abstract hl hl5
    (by exact_mod_cast x₁.den_ne_zero) (by exact_mod_cast x₂.den_ne_zero)
    (by exact_mod_cast y₁.den_ne_zero) (by exact_mod_cast y₂.den_ne_zero)
    (by exact_mod_cast hd₁) (by exact_mod_cast hd₂) (by exact_mod_cast hf₁)
    (by exact_mod_cast hf₂) (mordell_int_equation h₁)
    (dvd_cross_of_redQ_eq hd₁ hd₂ hx) (dvd_cross_of_redQ_eq hf₁ hf₂ hy) hy0 hk

/-! ## From colliding reductions to kernel points -/

/-- The `x`-coordinate of a difference of two affine points with distinct `x`-coordinates. -/
lemma xCoord_sub_of_X_ne {N : ℤ} {x₁ y₁ x₂ y₂ : ℚ}
    (hns₁ : (mordell ((N : ℤ) : ℚ)).toAffine.Nonsingular x₁ y₁)
    (hns₂ : (mordell ((N : ℤ) : ℚ)).toAffine.Nonsingular x₂ y₂) (hne : x₁ ≠ x₂) :
    xCoord ((Point.some hns₁ : (mordell ((N : ℤ) : ℚ)).toAffine.Point) - Point.some hns₂)
      = some ((x₁ * x₂ * (x₁ + x₂) + 2 * ((N : ℤ) : ℚ) + 2 * y₁ * y₂) / (x₁ - x₂) ^ 2) := by
  have hE₁ : y₁ ^ 2 = x₁ ^ 3 + ((N : ℤ) : ℚ) := (mordell_equation_iff _ _ _).1 hns₁.1
  have hE₂ : y₂ ^ 2 = x₂ ^ 3 + ((N : ℤ) : ℚ) := (mordell_equation_iff _ _ _).1 hns₂.1
  have hneg : -(Point.some hns₂ : (mordell ((N : ℤ) : ℚ)).toAffine.Point)
      = Point.some ((WeierstrassCurve.Affine.nonsingular_neg ..).mpr hns₂) :=
    WeierstrassCurve.Affine.Point.neg_some hns₂
  rw [sub_eq_add_neg, hneg, WeierstrassCurve.Affine.Point.add_of_X_ne hne]
  simp only [xCoord, Option.some.injEq]
  rw [WeierstrassCurve.Affine.slope_of_X_ne hne]
  simp only [WeierstrassCurve.Affine.addX, WeierstrassCurve.Affine.negY,
    mordell_a₁, mordell_a₂, mordell_a₃]
  have hd : x₁ - x₂ ≠ 0 := sub_ne_zero.mpr hne
  field_simp
  linear_combination hE₁ + hE₂

/-- Reduction is compatible with negation. -/
lemma redQ_neg {ℓ : ℕ} (q : ℚ) : redQ ℓ (-q) = - redQ ℓ q := by
  simp [redQ]

/-- **Doubling a point with vanishing reduced `y`-coordinate lands in the kernel.**  This is the
`2`-torsion branch of the local law: if `ℓ ∣ num y` then `2P` reduces to the point at
infinity. -/
lemma two_nsmul_mem_denKernel_of_dvd_num {N : ℤ} {x y : ℚ}
    (hns : (mordell ((N : ℤ) : ℚ)).toAffine.Nonsingular x y)
    {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ) (hlN : ¬(ℓ : ℤ) ∣ N) (hd : ¬ ℓ ∣ x.den)
    (hy : (ℓ : ℤ) ∣ y.num) :
    (2 : ℕ) • (Point.some hns : (mordell ((N : ℤ) : ℚ)).toAffine.Point) ∈ denKernel N ℓ hl := by
  have hE : y ^ 2 = x ^ 3 + ((N : ℤ) : ℚ) := (mordell_equation_iff _ _ _).1 hns.1
  rcases eq_or_ne y 0 with rfl | hy0
  · -- a `2`-torsion point: `2P = 0`
    have : (Point.some hns : (mordell ((N : ℤ) : ℚ)).toAffine.Point) + Point.some hns = 0 := by
      refine WeierstrassCurve.Affine.Point.add_self_of_Y_eq ?_
      simp [WeierstrassCurve.Affine.negY, mordell]
    rw [two_nsmul, this]
    exact (denKernel N ℓ hl).zero_mem
  · intro X hX
    rw [two_nsmul, mordell_double_xCoord _ _ _ hns hy0] at hX
    have hXval : (x ^ 4 - 8 * ((N : ℤ) : ℚ) * x) / (4 * y ^ 2) = X := by simpa using hX
    rw [← hXval]
    exact (dvd_den_double_iff_of_not_dvd_den hE hy0 hl hl5 hlN hd).2 hy

/-- **Collision lemma.**  If two `ℓ`-integral points of `E_N(ℚ)` have the same reduction modulo
a good prime `ℓ ≥ 5`, then twice their difference lies in the denominator kernel.  This is the
reduction-injectivity statement that powers the pigeonhole bound below, proved entirely by
explicit chord arithmetic — no reduction morphism of curves is needed. -/
theorem two_nsmul_sub_mem_denKernel_of_red_eq {N : ℤ} {x₁ y₁ x₂ y₂ : ℚ}
    (hns₁ : (mordell ((N : ℤ) : ℚ)).toAffine.Nonsingular x₁ y₁)
    (hns₂ : (mordell ((N : ℤ) : ℚ)).toAffine.Nonsingular x₂ y₂)
    {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ) (hlN : ¬(ℓ : ℤ) ∣ N)
    (hd₁ : ¬ ℓ ∣ x₁.den) (hd₂ : ¬ ℓ ∣ x₂.den)
    (hx : redQ ℓ x₁ = redQ ℓ x₂) (hy : redQ ℓ y₁ = redQ ℓ y₂) :
    (2 : ℕ) • ((Point.some hns₁ : (mordell ((N : ℤ) : ℚ)).toAffine.Point) - Point.some hns₂)
      ∈ denKernel N ℓ hl := by
  haveI := Fact.mk hl
  have hE₁ : y₁ ^ 2 = x₁ ^ 3 + ((N : ℤ) : ℚ) := (mordell_equation_iff _ _ _).1 hns₁.1
  have hE₂ : y₂ ^ 2 = x₂ ^ 3 + ((N : ℤ) : ℚ) := (mordell_equation_iff _ _ _).1 hns₂.1
  have hf₁ : ¬ ℓ ∣ y₁.den := not_dvd_den_y hE₁ hl hd₁
  have hf₂ : ¬ ℓ ∣ y₂.den := not_dvd_den_y hE₂ hl hd₂
  by_cases hy0 : (ℓ : ℤ) ∣ y₁.num
  · -- the common reduction is a `2`-torsion point: double each of the two points separately
    have hy0' : (ℓ : ℤ) ∣ y₂.num := by
      refine (redQ_eq_zero_iff hf₂).mp ?_
      rw [← hy]
      exact (redQ_eq_zero_iff hf₁).mpr hy0
    have h2A := two_nsmul_mem_denKernel_of_dvd_num hns₁ hl hl5 hlN hd₁ hy0
    have h2B := two_nsmul_mem_denKernel_of_dvd_num hns₂ hl hl5 hlN hd₂ hy0'
    have hsplit : (2 : ℕ) • ((Point.some hns₁ : (mordell ((N : ℤ) : ℚ)).toAffine.Point)
        - Point.some hns₂)
        = (2 : ℕ) • (Point.some hns₁ : (mordell ((N : ℤ) : ℚ)).toAffine.Point)
          - (2 : ℕ) • (Point.some hns₂ : (mordell ((N : ℤ) : ℚ)).toAffine.Point) := by
      rw [two_nsmul, two_nsmul, two_nsmul]; abel
    rw [hsplit]
    exact sub_mem h2A h2B
  · by_cases hxe : x₁ = x₂
    · -- equal `x`-coordinates: either the points coincide, or `y₁ = -y₂`, which is excluded
      subst hxe
      have hsq : (y₁ - y₂) * (y₁ + y₂) = 0 := by linear_combination hE₁ - hE₂
      rcases mul_eq_zero.mp hsq with h | h
      · have hyeq : y₁ = y₂ := by linarith [sub_eq_zero.mp h]
        subst hyeq
        have hpt : (Point.some hns₁ : (mordell ((N : ℤ) : ℚ)).toAffine.Point)
            = Point.some hns₂ := rfl
        rw [hpt, sub_self, smul_zero]
        exact (denKernel N ℓ hl).zero_mem
      · exfalso
        have hyeq : y₂ = -y₁ := by linarith [eq_neg_of_add_eq_zero_left h]
        rw [hyeq, redQ_neg] at hy
        have h2 : (2 : ZMod ℓ) * redQ ℓ y₁ = 0 := by linear_combination hy
        have h2ne : (2 : ZMod ℓ) ≠ 0 := by
          have hz : ((2 : ℤ) : ZMod ℓ) ≠ 0 := by
            refine intCast_ne_zero_of_not_dvd ?_
            intro hc
            have := Int.le_of_dvd (by norm_num) hc
            omega
          push_cast at hz
          exact hz
        exact hy0 ((redQ_eq_zero_iff hf₁).mp ((mul_eq_zero.mp h2).resolve_left h2ne))
    · -- distinct `x`-coordinates: the chord computation puts the difference in the kernel
      refine AddSubgroup.nsmul_mem _ ?_ 2
      intro X hX
      rw [xCoord_sub_of_X_ne hns₁ hns₂ hxe] at hX
      have hXval : (x₁ * x₂ * (x₁ + x₂) + 2 * ((N : ℤ) : ℚ) + 2 * y₁ * y₂) / (x₁ - x₂) ^ 2 = X := by
        simpa using hX
      rw [← hXval]
      exact dvd_den_chord_of_res_eq hE₁ hE₂ hl hl5 hd₁ hd₂ hx hy hy0 hxe

/-! ## The pigeonhole bound -/

/-- Every point of the curve is either the point at infinity or affine. -/
lemma point_eq_zero_or_some {N : ℤ} (Q : (mordell ((N : ℤ) : ℚ)).toAffine.Point) :
    Q = 0 ∨ ∃ x y : ℚ, ∃ h : (mordell ((N : ℤ) : ℚ)).toAffine.Nonsingular x y,
      Q = Point.some h := by
  cases Q with
  | zero => exact Or.inl rfl
  | @some x y h => exact Or.inr ⟨x, y, h, rfl⟩

/-- The reduction of an `ℓ`-integral point satisfies the reduced Weierstrass equation. -/
lemma redQ_curve_eq {N : ℤ} {x y : ℚ} {ℓ : ℕ} [Fact ℓ.Prime] (hl : ℓ.Prime)
    (h : y ^ 2 = x ^ 3 + ((N : ℤ) : ℚ)) (hd : ¬ ℓ ∣ x.den) :
    (redQ ℓ y) ^ 2 = (redQ ℓ x) ^ 3 + ((N : ℤ) : ZMod ℓ) := by
  have hf : ¬ ℓ ∣ y.den := not_dvd_den_y h hl hd
  have hd0 : ((x.den : ℕ) : ZMod ℓ) ≠ 0 := den_cast_ne_zero hd
  have hf0 : ((y.den : ℕ) : ZMod ℓ) ≠ 0 := den_cast_ne_zero hf
  have hc0 : ((y.num : ℤ) : ZMod ℓ) ^ 2 * ((x.den : ℕ) : ZMod ℓ) ^ 3
      = ((x.num : ℤ) : ZMod ℓ) ^ 3 * ((y.den : ℕ) : ZMod ℓ) ^ 2
        + ((N : ℤ) : ZMod ℓ) * ((y.den : ℕ) : ZMod ℓ) ^ 2 * ((x.den : ℕ) : ZMod ℓ) ^ 3 := by
    have := congrArg (fun m : ℤ => ((m : ℤ) : ZMod ℓ)) (mordell_int_equation h)
    push_cast at this
    linear_combination this
  rw [redQ, redQ]
  field_simp
  linear_combination hc0

/-- The pair of reductions of the coordinates of a point (junk values at infinity). -/
def redPair {N : ℤ} (ℓ : ℕ) (Q : (mordell ((N : ℤ) : ℚ)).toAffine.Point) : ZMod ℓ × ZMod ℓ :=
  (redQ ℓ ((xCoord Q).getD 0), redQ ℓ ((yCoord Q).getD 0))

/-- The set of points of the reduced Mordell curve over `ZMod ℓ`. -/
def curveSet (N : ℤ) (ℓ : ℕ) [NeZero ℓ] : Finset (ZMod ℓ × ZMod ℓ) :=
  Finset.univ.filter (fun p => p.2 ^ 2 = p.1 ^ 3 + ((N : ℤ) : ZMod ℓ))

/-- A quadratic equation `b² = c` has at most two solutions in a field. -/
lemma card_sq_eq_le_two {ℓ : ℕ} [Fact ℓ.Prime] [NeZero ℓ] (N : ℤ) (a : ZMod ℓ) :
    ((curveSet N ℓ).filter (fun p => p.1 = a)).card ≤ 2 := by
  rcases Finset.eq_empty_or_nonempty ((curveSet N ℓ).filter (fun p => p.1 = a)) with he | ⟨p₀, hp₀⟩
  · simp [he]
  · have hsub : (curveSet N ℓ).filter (fun p => p.1 = a)
        ⊆ ({(a, p₀.2), (a, -p₀.2)} : Finset (ZMod ℓ × ZMod ℓ)) := by
      intro p hp
      simp only [Finset.mem_filter, curveSet, Finset.mem_univ, true_and] at hp hp₀
      have hfac : (p.2 - p₀.2) * (p.2 + p₀.2) = 0 := by
        have h1 : p.2 ^ 2 = p.1 ^ 3 + ((N : ℤ) : ZMod ℓ) := hp.1
        have h2 : p₀.2 ^ 2 = p₀.1 ^ 3 + ((N : ℤ) : ZMod ℓ) := hp₀.1
        rw [hp.2] at h1
        rw [hp₀.2] at h2
        linear_combination h1 - h2
      rcases mul_eq_zero.mp hfac with h | h
      · have : p = (a, p₀.2) := Prod.ext hp.2 (by linear_combination h)
        simp [this]
      · have : p = (a, -p₀.2) := Prod.ext hp.2 (by linear_combination h)
        simp [this]
    exact le_trans (Finset.card_le_card hsub) (le_trans (Finset.card_insert_le _ _) (by simp))

/-- **The reduced curve has at most `2ℓ` points.**  Each `x`-coordinate carries at most two
`y`-coordinates.  (This is the elementary bound; Hasse's theorem would give `ℓ + 1 + 2√ℓ`.) -/
lemma card_curveSet_le {ℓ : ℕ} [Fact ℓ.Prime] [NeZero ℓ] (N : ℤ) :
    (curveSet N ℓ).card ≤ 2 * ℓ := by
  have hfib := Finset.card_eq_sum_card_fiberwise
    (f := Prod.fst) (s := curveSet N ℓ) (t := (Finset.univ : Finset (ZMod ℓ)))
    (fun p _ => Finset.mem_univ p.1)
  rw [hfib]
  calc ∑ a : ZMod ℓ, ((curveSet N ℓ).filter (fun p => p.1 = a)).card
      ≤ ∑ _a : ZMod ℓ, 2 := Finset.sum_le_sum (fun a _ => card_sq_eq_le_two N a)
    _ = 2 * ℓ := by
        rw [Finset.sum_const, Finset.card_univ, ZMod.card, smul_eq_mul, mul_comm]

/-- **Effective apparition bound.**  For every integer `N`, every prime `ℓ ≥ 5` with `ℓ ∤ N`
(equivalently `ℓ ∤ Δ = -432N²`, i.e. every good prime) and every rational point `P` of
`E_N : y² = x³ + N`, there is an index `n` with `0 < n ≤ 4ℓ` such that `nP` lies in the
denominator kernel at `ℓ`.  In other words a good prime cannot avoid the orbit of `P`: it shows
up in a denominator (or the orbit hits the point at infinity) within the first `4ℓ` steps — a
bound linear in `ℓ`, coming from the elementary count `#E(F_ℓ) ≤ 2ℓ` of points on the reduced
curve. -/
theorem exists_small_multiple_mem_denKernel {N : ℤ} {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ)
    (hlN : ¬(ℓ : ℤ) ∣ N) (P : (mordell ((N : ℤ) : ℚ)).toAffine.Point) :
    ∃ n : ℕ, 0 < n ∧ n ≤ 4 * ℓ ∧ n • P ∈ denKernel N ℓ hl := by
  haveI := Fact.mk hl
  haveI : NeZero ℓ := ⟨by omega⟩
  by_contra hcon
  push_neg at hcon
  set K : ℕ := 2 * ℓ + 1 with hK
  have hKbound : K ≤ 4 * ℓ := by omega
  -- every index in `[1, K]` gives an affine, `ℓ`-integral point
  have hcoord : ∀ n ∈ Finset.Icc 1 K, ∃ x y : ℚ,
      ∃ h : (mordell ((N : ℤ) : ℚ)).toAffine.Nonsingular x y,
        n • P = Point.some h ∧ ¬ ℓ ∣ x.den := by
    intro n hn
    simp only [Finset.mem_Icc] at hn
    have hnot := hcon n (by omega) (le_trans hn.2 hKbound)
    rcases point_eq_zero_or_some (n • P) with hz | ⟨x, y, h, hc⟩
    · exact absurd (hz ▸ (denKernel N ℓ hl).zero_mem) hnot
    · refine ⟨x, y, h, hc, ?_⟩
      intro hdvd
      refine hnot ?_
      intro X hX
      rw [hc] at hX
      have hxX : x = X := by simpa [xCoord] using hX
      rwa [← hxX]
  -- no two indices in `[1, K]` can have the same pair of reductions
  have key : ∀ m n : ℕ, m ∈ Finset.Icc 1 K → n ∈ Finset.Icc 1 K → m < n →
      redPair (N := N) ℓ (m • P) = redPair (N := N) ℓ (n • P) → False := by
    intro m n hm hn hmn hfeq
    obtain ⟨x₁, y₁, h₁, hP₁, hd₁⟩ := hcoord m hm
    obtain ⟨x₂, y₂, h₂, hP₂, hd₂⟩ := hcoord n hn
    simp only [Finset.mem_Icc] at hm hn
    rw [hP₁, hP₂] at hfeq
    simp only [redPair, xCoord, yCoord, Option.getD_some, Prod.mk.injEq] at hfeq
    have hmem := two_nsmul_sub_mem_denKernel_of_red_eq h₂ h₁ hl hl5 hlN hd₂ hd₁
      hfeq.1.symm hfeq.2.symm
    rw [← hP₁, ← hP₂] at hmem
    have hdiff : (n - m) • P = n • P - m • P := by
      rw [eq_sub_iff_add_eq, ← add_nsmul, Nat.sub_add_cancel (le_of_lt hmn)]
    have hsplit : (2 * (n - m)) • P = (2 : ℕ) • (n • P - m • P) := by
      rw [mul_nsmul', hdiff]
    refine hcon (2 * (n - m)) (by omega) ?_ ?_
    · simp only [hK] at hm hn
      omega
    · rw [hsplit]
      exact hmem
  -- the reductions land on the reduced curve, which has at most `2ℓ` points
  have hmaps : ∀ a ∈ Finset.Icc 1 K, redPair (N := N) ℓ (a • P) ∈ curveSet N ℓ := by
    intro a ha
    obtain ⟨x, y, h, hc, hd⟩ := hcoord a ha
    have hE : y ^ 2 = x ^ 3 + ((N : ℤ) : ℚ) := (mordell_equation_iff _ _ _).1 h.1
    have : redPair (N := N) ℓ (a • P) = (redQ ℓ x, redQ ℓ y) := by
      rw [hc]; rfl
    rw [this]
    simpa [curveSet] using redQ_curve_eq hl hE hd
  -- pigeonhole: `K = 2ℓ + 1` indices, at most `2ℓ` points on the reduced curve
  have hcard : (curveSet N ℓ).card < (Finset.Icc 1 K).card := by
    have h1 : (curveSet N ℓ).card ≤ 2 * ℓ := card_curveSet_le N
    have h2 : (Finset.Icc 1 K).card = K := by rw [Nat.card_Icc]; omega
    omega
  obtain ⟨m, hm, n, hn, hmn, hfeq⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to hcard hmaps
  rcases lt_or_gt_of_ne hmn with h | h
  · exact key m n hm hn h hfeq
  · exact key n m hn hm h hfeq.symm

/-! ## Consequences: every good prime occurs, effectively -/

/-- **Every good prime divides an orbit denominator, within `4ℓ` steps.**  Let `P` be a rational
point of infinite order on `E_N : y² = x³ + N` and let `ℓ ≥ 5` be a prime not dividing `N` — a
prime of good reduction.  Then some multiple `nP` with `0 < n ≤ 4ℓ` has `ℓ` in the denominator
of its `x`-coordinate.  The "only bad primes" conjecture therefore fails at *every* good prime,
and fails early. -/
theorem exists_small_multiple_dvd_den {N : ℤ} {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ)
    (hlN : ¬(ℓ : ℤ) ∣ N) {P : (mordell ((N : ℤ) : ℚ)).toAffine.Point}
    (hP : ∀ n : ℕ, 0 < n → n • P ≠ 0) :
    ∃ n : ℕ, 0 < n ∧ n ≤ 4 * ℓ ∧ ∃ X : ℚ, xCoord (n • P) = some X ∧ ℓ ∣ X.den := by
  obtain ⟨n, hn0, hnle, hmem⟩ := exists_small_multiple_mem_denKernel hl hl5 hlN P
  rcases point_eq_zero_or_some (n • P) with hz | ⟨x, y, h, hc⟩
  · exact absurd hz (hP n hn0)
  · have hxc : xCoord (n • P) = some x := by rw [hc]; rfl
    exact ⟨n, hn0, hnle, x, hxc, hmem x hxc⟩

/-- **No good prime avoids the orbit.**  For a point of infinite order there is no prime
`ℓ ≥ 5` of good reduction that stays out of all denominators of the orbit: the set of such
"innocent" good primes is empty. -/
theorem no_good_prime_avoids_orbit {N : ℤ} {P : (mordell ((N : ℤ) : ℚ)).toAffine.Point}
    (hP : ∀ n : ℕ, 0 < n → n • P ≠ 0) :
    {ℓ : ℕ | ℓ.Prime ∧ 5 ≤ ℓ ∧ ¬(ℓ : ℤ) ∣ N ∧
      ∀ n : ℕ, 0 < n → ∀ X : ℚ, xCoord (n • P) = some X → ¬ ℓ ∣ X.den} = ∅ := by
  ext ℓ
  simp only [Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false, not_and]
  rintro hl hl5 hlN hall
  obtain ⟨n, hn0, -, X, hX, hdvd⟩ := exists_small_multiple_dvd_den hl hl5 hlN hP
  exact hall n hn0 X hX hdvd

/-- **The inclusion of the conjecture, reversed.**  The "only bad primes" conjecture asserts
that the primes occurring in the denominators of an orbit are contained in `{2, 3} ∪ {p : p ∣ N}`.
The truth is the *opposite* inclusion: a prime that does **not** occur must be `2`, `3`, or a
prime factor of `N`.  Every other prime does occur. -/
theorem non_appearing_prime_is_bad {N : ℤ} {P : (mordell ((N : ℤ) : ℚ)).toAffine.Point}
    (hP : ∀ n : ℕ, 0 < n → n • P ≠ 0) {ℓ : ℕ} (hl : ℓ.Prime)
    (hnon : ¬ ∃ n : ℕ, 0 < n ∧ ∃ X : ℚ, xCoord (n • P) = some X ∧ ℓ ∣ X.den) :
    ℓ = 2 ∨ ℓ = 3 ∨ (ℓ : ℤ) ∣ N := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨h2, h3, hlN⟩ := hcon
  have hl5 : 5 ≤ ℓ := by
    have h2le := hl.two_le
    rcases Nat.lt_or_ge ℓ 5 with hlt | hge
    · interval_cases ℓ
      · exact absurd rfl h2
      · exact absurd rfl h3
      · exact absurd hl (by norm_num)
    · exact hge
  obtain ⟨n, hn0, -, X, hX, hdvd⟩ := exists_small_multiple_dvd_den hl hl5 hlN hP
  exact hnon ⟨n, hn0, X, hX, hdvd⟩

/-- **Only finitely many primes are absent from the orbit.**  The set of primes that never
divide a denominator in the orbit of a point of infinite order is contained in the finite set
`{2, 3} ∪ {p : p ∣ N}`. -/
theorem non_appearing_primes_finite {N : ℤ} (hN : N ≠ 0)
    {P : (mordell ((N : ℤ) : ℚ)).toAffine.Point} (hP : ∀ n : ℕ, 0 < n → n • P ≠ 0) :
    {ℓ : ℕ | ℓ.Prime ∧
      ¬ ∃ n : ℕ, 0 < n ∧ ∃ X : ℚ, xCoord (n • P) = some X ∧ ℓ ∣ X.den}.Finite := by
  refine Set.Finite.subset (Set.Finite.insert 2 (Set.Finite.insert 3
    (Set.finite_coe_iff.mp (Finset.finite_toSet N.natAbs.primeFactors)))) ?_
  rintro ℓ ⟨hl, hnon⟩
  rcases non_appearing_prime_is_bad hP hl hnon with h | h | h
  · exact Or.inl h
  · exact Or.inr (Or.inl h)
  · refine Or.inr (Or.inr ?_)
    simp only [Finset.mem_coe, Nat.mem_primeFactors]
    exact ⟨hl, by simpa using Int.natAbs_dvd_natAbs.mpr h, Int.natAbs_ne_zero.mpr hN⟩

/-- **The apparition index is positive and at most `4ℓ`.**  Refining the apparition law of
cycle 4, for a point of infinite order and a good prime `ℓ ≥ 5` the modulus `m` describing the
indices at which `ℓ` appears is a genuine, effectively bounded period. -/
theorem apparition_index_pos_le {N : ℤ} {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ)
    (hlN : ¬(ℓ : ℤ) ∣ N) (P : (mordell ((N : ℤ) : ℚ)).toAffine.Point) :
    ∃ m : ℕ, 0 < m ∧ m ≤ 4 * ℓ ∧
      ∀ k : ℤ, ((∀ Y : ℚ, xCoord (k • P) = some Y → ℓ ∣ Y.den) ↔ (m : ℤ) ∣ k) := by
  obtain ⟨m, hm⟩ := den_apparition_index hl P
  obtain ⟨n, hn0, hnle, hmem⟩ := exists_small_multiple_mem_denKernel hl hl5 hlN P
  have hmn : (m : ℤ) ∣ (n : ℤ) := by
    refine (hm (n : ℤ)).1 ?_
    intro Y hY
    refine hmem Y ?_
    rwa [natCast_zsmul] at hY
  have hmn' : m ∣ n := by exact_mod_cast hmn
  refine ⟨m, ?_, le_trans (Nat.le_of_dvd hn0 hmn') hnle, hm⟩
  rcases Nat.eq_zero_or_pos m with rfl | hpos
  · exact absurd (Nat.eq_zero_of_zero_dvd hmn') (by omega)
  · exact hpos

/-! ## The concrete curve `E_55` -/

/-- **On `E_55 : y² = x³ + 55` with `P = (9,28)`, every prime `ℓ ≥ 5` other than `5` and `11`
divides the denominator of `x(nP)` for some `n ≤ 4ℓ`.**  The two primes dividing `N = 5·11` and
the primes `2, 3` are the only ones the "only bad primes" conjecture allows; here *all* the
remaining primes occur, with an explicit bound on where they first occur. -/
theorem every_good_prime_appears_55 {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ) (h5 : ℓ ≠ 5)
    (h11 : ℓ ≠ 11) :
    ∃ n : ℕ, 0 < n ∧ n ≤ 4 * ℓ ∧ ∃ X : ℚ,
      xCoord (n • (Point.some nonsingular_int_55_9_28 :
        (mordell (((55 : ℤ)) : ℚ)).toAffine.Point)) = some X ∧ ℓ ∣ X.den := by
  refine exists_small_multiple_dvd_den (N := 55) hl hl5 ?_ mordell_55_point_infinite_order
  intro hdvd
  have h55 : ℓ ∣ 5 * 11 := by exact_mod_cast hdvd
  rcases (Nat.Prime.dvd_mul hl).mp h55 with h | h
  · exact h5 ((Nat.prime_dvd_prime_iff_eq hl (by norm_num)).mp h)
  · exact h11 ((Nat.prime_dvd_prime_iff_eq hl (by norm_num)).mp h)

end MordellDenominators