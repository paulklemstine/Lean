import Mathlib
import Shared.CatalogbuildSharedIspythtriple.IsPythTriple

/-!
# The commutative monoid of integral Pythagorean triples

This file builds the algebraic substrate for the *aggregate dichotomy* study
(`Pythagorean.AggregateDichotomy`).  Starting from the catalog predicate
`IsPythTriple a b c : a ^ 2 + b ^ 2 = c ^ 2` we bundle an integral Pythagorean
triple with a **nonnegative hypotenuse** and equip the resulting type `PTriple`
with the Brahmagupta–Fibonacci product

`(a, b, c) * (a', b', c') = (a a' - b b', a b' + b a', c c')`,

which is exactly multiplication of Gaussian integers on the legs together with
multiplication of hypotenuses.

Main results.

* `PTriple.instCommMonoid` : the Brahmagupta product makes `PTriple` a commutative monoid.
* `PTriple.hypHom` : the hypotenuse is a monoid homomorphism to `ℤ`.
* `PTriple.toGaussian` : the leg pair is a monoid homomorphism to `ℤ[i]`, and it is
  **injective** (`PTriple.toGaussian_injective`) — the hypotenuse is redundant data.
* `PTriple.range_toGaussian` : the image of `toGaussian` is precisely the set of Gaussian
  integers whose norm is a perfect square, a submonoid of `ℤ[i]`.
* `PTriple.isUnit_iff_c_eq_one`, `PTriple.eq_of_c_eq_one` : the unit group is the group of
  four "rotations" `±1, ±i`, i.e. the degenerate triples.
-/

namespace Pythagorean

/-- An integral Pythagorean triple, with the hypotenuse normalised to be nonnegative. -/
@[ext]
structure PTriple where
  /-- first leg -/
  a : ℤ
  /-- second leg -/
  b : ℤ
  /-- hypotenuse -/
  c : ℤ
  /-- the Pythagorean relation, taken from the catalog predicate `IsPythTriple` -/
  isPyth : IsPythTriple a b c
  /-- normalisation: the hypotenuse is nonnegative -/
  hc : 0 ≤ c

namespace PTriple

lemma sq_eq (t : PTriple) : t.a ^ 2 + t.b ^ 2 = t.c ^ 2 := t.isPyth

/-- The hypotenuse is determined by the legs, thanks to the nonnegativity normalisation. -/
lemma c_eq_of_legs {t s : PTriple} (ha : t.a = s.a) (hb : t.b = s.b) : t.c = s.c := by
  have h : t.c ^ 2 = s.c ^ 2 := by
    have ht := t.sq_eq
    have hs := s.sq_eq
    rw [← ht, ← hs, ha, hb]
  rcases lt_trichotomy t.c s.c with h1 | h1 | h1
  · exact absurd h (by nlinarith [t.hc, s.hc])
  · exact h1
  · exact absurd h (by nlinarith [t.hc, s.hc])

instance : One PTriple :=
  ⟨⟨1, 0, 1, by show (1 : ℤ) ^ 2 + 0 ^ 2 = 1 ^ 2; ring, by norm_num⟩⟩

instance : Mul PTriple :=
  ⟨fun t s =>
    ⟨t.a * s.a - t.b * s.b, t.a * s.b + t.b * s.a, t.c * s.c,
      by
        have ht := t.sq_eq
        have hs := s.sq_eq
        show (t.a * s.a - t.b * s.b) ^ 2 + (t.a * s.b + t.b * s.a) ^ 2 = (t.c * s.c) ^ 2
        calc (t.a * s.a - t.b * s.b) ^ 2 + (t.a * s.b + t.b * s.a) ^ 2
            = (t.a ^ 2 + t.b ^ 2) * (s.a ^ 2 + s.b ^ 2) := by ring
          _ = t.c ^ 2 * s.c ^ 2 := by rw [ht, hs]
          _ = (t.c * s.c) ^ 2 := by ring,
      mul_nonneg t.hc s.hc⟩⟩

@[simp] lemma one_a : (1 : PTriple).a = 1 := rfl
@[simp] lemma one_b : (1 : PTriple).b = 0 := rfl
@[simp] lemma one_c : (1 : PTriple).c = 1 := rfl
@[simp] lemma mul_a (t s : PTriple) : (t * s).a = t.a * s.a - t.b * s.b := rfl
@[simp] lemma mul_b (t s : PTriple) : (t * s).b = t.a * s.b + t.b * s.a := rfl
@[simp] lemma mul_c (t s : PTriple) : (t * s).c = t.c * s.c := rfl

instance instCommMonoid : CommMonoid PTriple where
  mul_assoc t s u := by ext <;> simp <;> ring
  one_mul t := by ext <;> simp
  mul_one t := by ext <;> simp
  mul_comm t s := by ext <;> simp <;> ring

/-- The hypotenuse, as a monoid homomorphism into the multiplicative monoid of `ℤ`. -/
def hypHom : PTriple →* ℤ where
  toFun := PTriple.c
  map_one' := rfl
  map_mul' _ _ := rfl

@[simp] lemma hypHom_apply (t : PTriple) : hypHom t = t.c := rfl

lemma c_prod {n : ℕ} (f : Fin n → PTriple) : (∏ i, f i).c = ∏ i, (f i).c :=
  map_prod hypHom f Finset.univ

/-- The legs of a triple, viewed as a Gaussian integer. -/
def toGaussian : PTriple →* GaussianInt where
  toFun t := ⟨t.a, t.b⟩
  map_one' := rfl
  map_mul' t s := by
    ext <;> simp; ring

@[simp] lemma toGaussian_re (t : PTriple) : (toGaussian t).re = t.a := rfl
@[simp] lemma toGaussian_im (t : PTriple) : (toGaussian t).im = t.b := rfl

/-- **The hypotenuse carries no extra information**: a Pythagorean triple with nonnegative
hypotenuse is determined by its Gaussian integer of legs. -/
theorem toGaussian_injective : Function.Injective toGaussian := by
  intro t s h
  have ha : t.a = s.a := congrArg Zsqrtd.re h
  have hb : t.b = s.b := congrArg Zsqrtd.im h
  exact PTriple.ext ha hb (c_eq_of_legs ha hb)

/-- The norm of the Gaussian integer attached to a triple is the square of the hypotenuse. -/
lemma norm_toGaussian (t : PTriple) : (toGaussian t).norm = t.c ^ 2 := by
  have h := t.sq_eq
  rw [Zsqrtd.norm_def]
  simp only [toGaussian_re, toGaussian_im]
  nlinarith [h]

/-- **Characterisation of the image**: a Gaussian integer comes from a Pythagorean triple iff
its norm is a perfect square.  Thus `PTriple` is (isomorphic to) the submonoid of `ℤ[i]` cut
out by the square-norm condition. -/
theorem range_toGaussian :
    Set.range toGaussian = {z : GaussianInt | IsSquare z.norm} := by
  ext z
  constructor
  · rintro ⟨t, rfl⟩
    exact ⟨t.c, by rw [norm_toGaussian]; ring⟩
  · rintro ⟨c, hc⟩
    refine ⟨⟨z.re, z.im, |c|, ?_, abs_nonneg c⟩, ?_⟩
    · show z.re ^ 2 + z.im ^ 2 = |c| ^ 2
      have hz : z.norm = z.re * z.re - (-1) * z.im * z.im := Zsqrtd.norm_def z
      rw [sq_abs]
      nlinarith [hc, hz]
    · rfl

/-- Degenerate triples: hypotenuse one forces the four "rotations". -/
theorem eq_of_c_eq_one (t : PTriple) (h : t.c = 1) :
    (t.a = 1 ∧ t.b = 0) ∨ (t.a = -1 ∧ t.b = 0) ∨ (t.a = 0 ∧ t.b = 1) ∨ (t.a = 0 ∧ t.b = -1) := by
  have hsum : t.a ^ 2 + t.b ^ 2 = 1 := by rw [t.sq_eq, h]; ring
  have ha : t.a ^ 2 ≤ 1 := by nlinarith [sq_nonneg t.b]
  have hb : t.b ^ 2 ≤ 1 := by nlinarith [sq_nonneg t.a]
  have ha1 : -1 ≤ t.a := by nlinarith
  have ha2 : t.a ≤ 1 := by nlinarith
  have hb1 : -1 ≤ t.b := by nlinarith
  have hb2 : t.b ≤ 1 := by nlinarith
  interval_cases h1 : t.a <;> interval_cases h2 : t.b <;> simp_all

/-- The units of `PTriple` are exactly the triples of hypotenuse one. -/
theorem isUnit_iff_c_eq_one (t : PTriple) : IsUnit t ↔ t.c = 1 := by
  constructor
  · intro h
    obtain ⟨v, hv⟩ := h.exists_right_inv
    have hc : t.c * v.c = 1 := by simpa using congrArg PTriple.c hv
    have := Int.isUnit_iff.mp (IsUnit.of_mul_eq_one v.c hc)
    have h0 := t.hc
    omega
  · intro h
    have hsum : t.a ^ 2 + t.b ^ 2 = 1 := by rw [t.sq_eq, h]; ring
    have hconj : IsPythTriple t.a (-t.b) t.c := by
      show t.a ^ 2 + (-t.b) ^ 2 = t.c ^ 2
      have := t.sq_eq; nlinarith [this]
    refine IsUnit.of_mul_eq_one (a := t) ⟨t.a, -t.b, t.c, hconj, t.hc⟩ ?_
    ext
    · show t.a * t.a - t.b * (-t.b) = 1
      nlinarith [hsum]
    · show t.a * (-t.b) + t.b * t.a = 0
      ring
    · show t.c * t.c = 1
      rw [h]; ring

/-! ## Smart constructor, and the absorbing zero triple -/

/-- Smart constructor for a Pythagorean triple from explicit data. -/
def ofLegs (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) (hc : 0 ≤ c) : PTriple := ⟨a, b, c, h, hc⟩

@[simp] lemma ofLegs_a (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) (hc : 0 ≤ c) :
    (ofLegs a b c h hc).a = a := rfl
@[simp] lemma ofLegs_b (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) (hc : 0 ≤ c) :
    (ofLegs a b c h hc).b = b := rfl
@[simp] lemma ofLegs_c (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) (hc : 0 ≤ c) :
    (ofLegs a b c h hc).c = c := rfl

/-- The degenerate *zero triple* `(0,0,0)`: the absorbing element of the monoid. -/
def zeroT : PTriple := ofLegs 0 0 0 (by norm_num) (le_refl 0)

@[simp] lemma zeroT_a : zeroT.a = 0 := rfl
@[simp] lemma zeroT_b : zeroT.b = 0 := rfl
@[simp] lemma zeroT_c : zeroT.c = 0 := rfl

@[simp] lemma zeroT_mul (t : PTriple) : zeroT * t = zeroT := by
  ext <;> simp

@[simp] lemma mul_zeroT (t : PTriple) : t * zeroT = zeroT := by
  ext <;> simp

/-- A triple is the zero triple exactly when its Gaussian integer vanishes. -/
lemma toGaussian_eq_zero_iff (t : PTriple) : toGaussian t = 0 ↔ t = zeroT := by
  constructor
  · intro h
    have ha : t.a = 0 := by simpa using congrArg Zsqrtd.re h
    have hb : t.b = 0 := by simpa using congrArg Zsqrtd.im h
    exact PTriple.ext ha hb (c_eq_of_legs (s := zeroT) (by simpa using ha) (by simpa using hb))
  · rintro rfl
    ext <;> simp

/-- **Cancellation away from the zero triple.**  The monoid `PTriple` embeds into the domain
`ℤ[i]`, hence every triple other than `(0,0,0)` is cancellable. -/
lemma mul_right_cancel_of_ne_zeroT {t u v : PTriple} (ht : t ≠ zeroT) (h : u * t = v * t) :
    u = v := by
  have hG : toGaussian t ≠ 0 := fun h0 => ht ((toGaussian_eq_zero_iff t).mp h0)
  have hmul : toGaussian u * toGaussian t = toGaussian v * toGaussian t := by
    rw [← map_mul, ← map_mul, h]
  exact toGaussian_injective (mul_right_cancel₀ hG hmul)

end PTriple

end Pythagorean