import Mathlib
import Catalog.NumberTheory.NormalizedQSeriesRoots

/-!
# Rational `⋆`-powers: the normalized `q`-series form a `ℚ`-vector space

Sixth research cycle.  Cycle 4 proved that the group of normalized `q`-series
`q⁻¹ + a₀ + a₁ q + ⋯` (under the corrected product `f ⋆ g = q f g`) is torsion
free and divisible; cycle 5 turned the `n`-th power maps into automorphisms.
Here we draw the structural consequence:

* `UniquelyDivisible.ratModule` — a general construction: **any** abelian group
  in which multiplication by every positive integer is bijective is canonically
  a `ℚ`-vector space.  The scalar action is `r • x = r.num • (x / r.den)`, and
  the module axioms are forced by torsion freeness.
* `NormalizedQSeries.instModuleRatAdditiveNormalized` — hence the group of
  normalized `q`-series is a `ℚ`-vector space in multiplicative notation:
  **rational `⋆`-powers `f^r` exist and are unique for every `r ∈ ℚ`.**
* `NormalizedQSeries.ratPow` and its laws `ratPow_add`, `ratPow_mul`,
  `ratPow_natCast` package the action multiplicatively: `f^{r+s} = f^r ⋆ f^s`,
  `f^{rs} = (f^s)^r`, and `f^{(n : ℚ)} = q^{n-1} fⁿ`.
* `NormalizedQSeries.existsUnique_ratPow` — for every normalized `f` and every
  rational `r` with denominator `d` and numerator `p`, there is a *unique*
  normalized `g` with `g^{⋆d} = f^{⋆p}`.

Together with cycles 3–5 this pins the isomorphism type of the corrected
moonshine group: it is a `ℚ`-vector space, and in particular has no arithmetic
obstruction whatsoever beyond the single integer pole order.
-/

namespace UniquelyDivisible

variable {M : Type*} [AddCommGroup M]

/-- Division by a positive integer in a uniquely divisible abelian group. -/
noncomputable def divBy (H : ∀ n : ℕ, 0 < n → Function.Bijective fun x : M => n • x)
    (n : ℕ) (x : M) : M :=
  if hn : 0 < n then (Equiv.ofBijective _ (H n hn)).symm x else 0

theorem nsmul_divBy (H : ∀ n : ℕ, 0 < n → Function.Bijective fun x : M => n • x)
    (n : ℕ) (hn : 0 < n) (x : M) : n • divBy H n x = x := by
  rw [divBy, dif_pos hn]
  exact (Equiv.ofBijective _ (H n hn)).apply_symm_apply x

theorem eq_of_nsmul_eq (H : ∀ n : ℕ, 0 < n → Function.Bijective fun x : M => n • x)
    {n : ℕ} (hn : 0 < n) {x y : M} (h : n • x = n • y) : x = y := (H n hn).injective h

/-- The rational scalar action `r • x = r.num • (x / r.den)`. -/
noncomputable def ratSMul (H : ∀ n : ℕ, 0 < n → Function.Bijective fun x : M => n • x)
    (r : ℚ) (x : M) : M :=
  r.num • divBy H r.den x

theorem den_zsmul_ratSMul (H : ∀ n : ℕ, 0 < n → Function.Bijective fun x : M => n • x)
    (r : ℚ) (x : M) : (r.den : ℤ) • ratSMul H r x = r.num • x := by
  rw [ratSMul, natCast_zsmul, smul_comm r.den r.num, nsmul_divBy H r.den r.pos]

/-- The defining property of the rational action, for an arbitrary
representation `r = a / b`. -/
theorem zsmul_ratSMul_of_eq_div (H : ∀ n : ℕ, 0 < n → Function.Bijective fun x : M => n • x)
    (r : ℚ) (a : ℤ) (b : ℕ) (hb : 0 < b) (hr : r = (a : ℚ) / (b : ℚ)) (x : M) :
    (b : ℤ) • ratSMul H r x = a • x := by
  have hb' : ((b : ℚ)) ≠ 0 := by positivity
  have hd' : ((r.den : ℚ)) ≠ 0 := by
    exact_mod_cast (Nat.cast_ne_zero (R := ℚ)).mpr r.den_nz
  have h : (r.num : ℚ) / (r.den : ℚ) = (a : ℚ) / (b : ℚ) := by rw [Rat.num_div_den, hr]
  field_simp at h
  have hint : r.num * (b : ℤ) = (r.den : ℤ) * a := by exact_mod_cast h
  refine eq_of_nsmul_eq H (n := r.den) r.pos ?_
  have e1 : (r.den : ℕ) • ((b : ℤ) • ratSMul H r x) = ((b : ℤ) * r.num) • x := by
    rw [← natCast_zsmul (n := r.den) (a := ((b : ℤ) • ratSMul H r x)), smul_smul,
      mul_comm ((r.den : ℤ)) ((b : ℤ)), ← smul_smul, den_zsmul_ratSMul H r x, smul_smul]
  have e2 : (r.den : ℕ) • (a • x) = ((r.den : ℤ) * a) • x := by
    rw [← natCast_zsmul (n := r.den) (a := (a • x)), smul_smul]
  rw [e1, e2]
  congr 1
  linear_combination hint

theorem ratSMul_add_right (H : ∀ n : ℕ, 0 < n → Function.Bijective fun x : M => n • x)
    (r : ℚ) (x y : M) :
    ratSMul H r (x + y) = ratSMul H r x + ratSMul H r y := by
  have hdiv : divBy H r.den (x + y) = divBy H r.den x + divBy H r.den y := by
    refine eq_of_nsmul_eq H r.pos ?_
    rw [nsmul_divBy H r.den r.pos, smul_add, nsmul_divBy H r.den r.pos,
      nsmul_divBy H r.den r.pos]
  rw [ratSMul, ratSMul, ratSMul, hdiv, smul_add]

/-- **Any uniquely divisible abelian group is a `ℚ`-vector space.**  The action
is `r • x = r.num • (x / r.den)`; the module axioms follow from the injectivity
of multiplication by positive integers. -/
noncomputable def ratModule (H : ∀ n : ℕ, 0 < n → Function.Bijective fun x : M => n • x) :
    Module ℚ M where
  smul r x := ratSMul H r x
  one_smul x := by
    show ratSMul H 1 x = x
    rw [ratSMul]
    show (1 : ℤ) • divBy H 1 x = x
    rw [one_smul]
    simpa using nsmul_divBy H 1 one_pos x
  mul_smul r s x := by
    show ratSMul H (r * s) x = ratSMul H r (ratSMul H s x)
    have hb : 0 < r.den * s.den := Nat.mul_pos r.pos s.pos
    refine eq_of_nsmul_eq H (n := r.den * s.den) hb ?_
    have hcast : ∀ z : M, (r.den * s.den : ℕ) • z = (((r.den * s.den : ℕ) : ℤ)) • z := by
      intro z; rw [natCast_zsmul]
    rw [hcast, hcast]
    have hl : ((r.den * s.den : ℕ) : ℤ) • ratSMul H (r * s) x = (r.num * s.num) • x := by
      refine zsmul_ratSMul_of_eq_div H (r * s) (r.num * s.num) (r.den * s.den) hb ?_ x
      have e : ((r.num * s.num : ℤ) : ℚ) / ((r.den * s.den : ℕ) : ℚ)
          = ((r.num : ℚ) / (r.den : ℚ)) * ((s.num : ℚ) / (s.den : ℚ)) := by
        push_cast
        rw [mul_div_mul_comm]
      rw [e, Rat.num_div_den, Rat.num_div_den]
    have hr' : ((r.den * s.den : ℕ) : ℤ) • ratSMul H r (ratSMul H s x)
        = (r.num * s.num) • x := by
      push_cast
      rw [mul_comm ((r.den : ℤ)) ((s.den : ℤ)), ← smul_smul,
        den_zsmul_ratSMul H r (ratSMul H s x), smul_comm ((s.den : ℤ)) r.num,
        den_zsmul_ratSMul H s x, smul_smul, mul_comm]
    rw [hl, hr']
  smul_zero r := by
    show ratSMul H r 0 = 0
    have hdiv : divBy H r.den 0 = 0 := by
      refine eq_of_nsmul_eq H r.pos ?_
      rw [nsmul_divBy H r.den r.pos, smul_zero]
    rw [ratSMul, hdiv, smul_zero]
  smul_add r x y := ratSMul_add_right H r x y
  add_smul r s x := by
    show ratSMul H (r + s) x = ratSMul H r x + ratSMul H s x
    have hb : 0 < r.den * s.den := Nat.mul_pos r.pos s.pos
    refine eq_of_nsmul_eq H (n := r.den * s.den) hb ?_
    have hcast : ∀ z : M, (r.den * s.den : ℕ) • z = (((r.den * s.den : ℕ) : ℤ)) • z := by
      intro z; rw [natCast_zsmul]
    rw [hcast, hcast]
    have hr : ((r.den : ℚ)) ≠ 0 := by
      exact_mod_cast (Nat.cast_ne_zero (R := ℚ)).mpr r.den_nz
    have hs : ((s.den : ℚ)) ≠ 0 := by
      exact_mod_cast (Nat.cast_ne_zero (R := ℚ)).mpr s.den_nz
    have hl : ((r.den * s.den : ℕ) : ℤ) • ratSMul H (r + s) x
        = (r.num * s.den + s.num * r.den) • x := by
      refine zsmul_ratSMul_of_eq_div H (r + s) (r.num * s.den + s.num * r.den)
        (r.den * s.den) hb ?_ x
      have e : ((r.num * s.den + s.num * r.den : ℤ) : ℚ) / ((r.den * s.den : ℕ) : ℚ)
          = ((r.num : ℚ) / (r.den : ℚ)) + ((s.num : ℚ) / (s.den : ℚ)) := by
        push_cast
        field_simp
      rw [e, Rat.num_div_den, Rat.num_div_den]
    have hr1 : ((r.den * s.den : ℕ) : ℤ) • ratSMul H r x = (r.num * s.den) • x := by
      push_cast
      rw [mul_comm ((r.den : ℤ)) ((s.den : ℤ)), ← smul_smul, den_zsmul_ratSMul H r x,
        smul_smul, mul_comm]
    have hr2 : ((r.den * s.den : ℕ) : ℤ) • ratSMul H s x = (s.num * r.den) • x := by
      push_cast
      rw [← smul_smul, den_zsmul_ratSMul H s x, smul_smul, mul_comm]
    rw [hl, smul_add, hr1, hr2, ← add_smul]
  zero_smul x := by
    show ratSMul H 0 x = 0
    simp [ratSMul]

end UniquelyDivisible

namespace NormalizedQSeries

open PoleOrderObstruction

/-- Multiplication by `n` is bijective on the additive form of the group of
normalized `q`-series, for every `n ≥ 1`. -/
theorem nsmul_bijective_additive (n : ℕ) (hn : 0 < n) :
    Function.Bijective fun x : Additive Normalized => n • x := by
  have h : (fun x : Additive Normalized => n • x)
      = Additive.ofMul ∘ (fun g : Normalized => g ^ n) ∘ Additive.toMul := by
    funext x; rfl
  have hb : Function.Bijective (fun g : Normalized => g ^ n) :=
    ⟨Normalized.pow_left_injective hn, Normalized.pow_left_surjective hn⟩
  rw [h]
  exact Additive.ofMul.bijective.comp (hb.comp Additive.toMul.bijective)

/-- **The normalized `q`-series form a `ℚ`-vector space.**  Written
multiplicatively: rational `⋆`-powers of normalized `q`-series exist, are
unique, and satisfy the usual exponent laws. -/
noncomputable instance instModuleRatAdditiveNormalized : Module ℚ (Additive Normalized) :=
  UniquelyDivisible.ratModule nsmul_bijective_additive

/-- The rational `⋆`-power `f ^ r` of a normalized `q`-series. -/
noncomputable def ratPow (f : Normalized) (r : ℚ) : Normalized :=
  Additive.toMul (r • Additive.ofMul f)

@[inherit_doc] notation:75 f " ^⋆ " r => ratPow f r

theorem ratPow_add (f : Normalized) (r s : ℚ) :
    (f ^⋆ (r + s)) = (f ^⋆ r) * (f ^⋆ s) := by
  show Additive.toMul ((r + s) • Additive.ofMul f) = _
  rw [add_smul]
  rfl

theorem ratPow_mul (f : Normalized) (r s : ℚ) :
    (f ^⋆ (r * s)) = ((f ^⋆ s) ^⋆ r) := by
  show Additive.toMul ((r * s) • Additive.ofMul f) = _
  rw [mul_smul]
  rfl

@[simp] theorem ratPow_one (f : Normalized) : (f ^⋆ (1 : ℚ)) = f := by
  show Additive.toMul ((1 : ℚ) • Additive.ofMul f) = f
  rw [one_smul]
  rfl

@[simp] theorem ratPow_zero (f : Normalized) : (f ^⋆ (0 : ℚ)) = 1 := by
  show Additive.toMul ((0 : ℚ) • Additive.ofMul f) = 1
  rw [zero_smul]
  rfl

/-- Rational powers extend the integer powers: `f ^ (n : ℚ) = fⁿ`. -/
theorem ratPow_natCast (f : Normalized) (n : ℕ) : (f ^⋆ ((n : ℚ))) = f ^ n := by
  induction n with
  | zero => simp
  | succ k ih =>
      have : ((k + 1 : ℕ) : ℚ) = (k : ℚ) + 1 := by push_cast; ring
      rw [this, ratPow_add, ih, ratPow_one, pow_succ]

/-- **Existence and uniqueness of rational `⋆`-powers.**  For a normalized `f`
and a rational `r = p / d` in lowest terms, `f ^⋆ r` is the unique normalized
series whose `d`-th `⋆`-power is the `p`-th `⋆`-power of `f`. -/
theorem existsUnique_ratPow (f : Normalized) (r : ℚ) :
    ∃! g : Normalized, g ^ r.den = f ^ (r.num) := by
  refine ⟨f ^⋆ r, ?_, ?_⟩
  · have hkey : ((r.den : ℤ)) • (r • Additive.ofMul f) = r.num • Additive.ofMul f :=
      UniquelyDivisible.den_zsmul_ratSMul (H := nsmul_bijective_additive) r (Additive.ofMul f)
    have h1 : Additive.toMul (((r.den : ℤ)) • (r • Additive.ofMul f))
        = (f ^⋆ r) ^ ((r.den : ℤ)) := rfl
    have h2 : Additive.toMul ((r.num) • Additive.ofMul f) = f ^ (r.num) := rfl
    have := congrArg Additive.toMul hkey
    rw [h1, h2] at this
    rw [← this, zpow_natCast]
  · intro g hg
    refine Normalized.pow_left_injective (n := r.den) r.pos ?_
    have hkey : ((r.den : ℤ)) • (r • Additive.ofMul f) = r.num • Additive.ofMul f :=
      UniquelyDivisible.den_zsmul_ratSMul (H := nsmul_bijective_additive) r (Additive.ofMul f)
    have h1 : Additive.toMul (((r.den : ℤ)) • (r • Additive.ofMul f))
        = (f ^⋆ r) ^ ((r.den : ℤ)) := rfl
    have h2 : Additive.toMul ((r.num) • Additive.ofMul f) = f ^ (r.num) := rfl
    have hval := congrArg Additive.toMul hkey
    rw [h1, h2] at hval
    show g ^ r.den = (f ^⋆ r) ^ r.den
    rw [hg, ← zpow_natCast (f ^⋆ r) r.den, hval]

end NormalizedQSeries