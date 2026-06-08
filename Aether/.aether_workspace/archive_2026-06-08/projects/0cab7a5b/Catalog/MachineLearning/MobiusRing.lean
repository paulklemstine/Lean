/-
  # The Möbius Ring ℤ√1 = ℤ[ε]/(ε²−1)

  This file formalizes the Möbius ring, the ring of integers adjoined with a
  square root of 1. Unlike ℤ√d for d < 0 (Gaussian/Eisenstein integers) or
  d > 1 (real quadratic fields), d = 1 gives a degenerate but algebraically
  rich structure: a non-domain commutative ring whose zero divisors, units,
  and ideal structure mirror the topology of the Möbius band.

  ## Main Results

  * `epsilon_sq` : ε² = 1, the defining relation
  * `zero_divisor` : (1+ε)(1−ε) = 0, zero divisors exist
  * `not_isDomain` : ℤ√1 is not an integral domain
  * `norm_factors` : N(a+bε) = (a+b)(a−b), the norm factors over ℤ
  * `units_iff` : z is a unit iff (re + im) and (re − im) are ±1
  * `splitting_hom` : the ring homomorphism φ: ℤ√1 → ℤ × ℤ
  * `splitting_injective` : φ is injective
  * `parity_obstruction` : the image of φ lies in the parity subring
  * `idempotent_rigidity` : the only idempotents in ℤ√1 are 0 and 1
-/
import Mathlib

namespace MobiusRing

/-- The Möbius ring is ℤ√1, the ring of integers with an adjoined square root of unity. -/
abbrev M := ℤ√(1 : ℤ)

/-- The generator ε of the Möbius ring, satisfying ε² = 1. -/
def eps : M := ⟨0, 1⟩

/-- The "positive orientation" element 1 + ε. -/
def ePos : M := ⟨1, 1⟩

/-- The "negative orientation" element 1 − ε. -/
def eNeg : M := ⟨1, -1⟩

/-! ## Basic Properties -/

/-
The defining relation: ε² = 1.
-/
theorem epsilon_sq : eps ^ 2 = (1 : M) := by
  decide +kernel

/-
The orientation elements multiply to zero: (1+ε)(1−ε) = 0.
-/
theorem zero_divisor : ePos * eNeg = (0 : M) := by
  decide +kernel

/-
ℤ√1 is not an integral domain because it has zero divisors.
-/
theorem not_isDomain : ¬ IsDomain M := by
  obtain ⟨a, b, h_ne_zero, h_prod_zero⟩ : ∃ a b : M, a ≠ 0 ∧ b ≠ 0 ∧ a * b = 0 := by
    exists ePos, eNeg;
  aesop

/-! ## Norm Factorization

The norm N(a + bε) = a² − b² factors as (a+b)(a−b) over ℤ.
This factorization is the key algebraic shadow of the Möbius band's
non-orientability: the norm form is indefinite. -/

/-
The norm of an element of ℤ√1 factors as (a+b)(a−b).
-/
theorem norm_factors (z : M) : z.norm = (z.re + z.im) * (z.re - z.im) := by
  simp +decide [ Zsqrtd.norm ] ; ring

/-! ## Unit Classification

The unit group of ℤ√1 is the Klein four-group V₄ = {1, −1, ε, −ε}.
Every element squares to 1, reflecting the Möbius band's property
that two traversals restore orientation. -/

/-
An element of ℤ√1 is a unit if and only if both (re + im) and (re − im) are ±1.
-/
theorem units_iff (z : M) :
    IsUnit z ↔ (z.re + z.im = 1 ∨ z.re + z.im = -1) ∧
               (z.re - z.im = 1 ∨ z.re - z.im = -1) := by
                 convert @Zsqrtd.isUnit_iff_norm_isUnit 1 z using 1;
                 unfold Zsqrtd.norm;
                 constructor <;> intro h <;> rw [ show z.re * z.re - 1 * z.im * z.im = ( z.re + z.im ) * ( z.re - z.im ) by ring ] at * <;> simp_all +decide [ Int.isUnit_iff ]

/-
ε is a unit.
-/
theorem epsilon_isUnit : IsUnit eps := by
  rw [Zsqrtd.isUnit_iff_norm_isUnit]
  simp [Zsqrtd.norm_def, eps]

/-
Every unit squares to 1 (the V₄ / exponent-2 property).
-/
theorem unit_sq_eq_one (z : M) (hz : IsUnit z) : z ^ 2 = 1 := by
  convert ( congr_arg ( fun x : ℤ√1 => x ) <| show z ^ 2 = ( z * z ) from ?_ ) using 1;
  · rw [ units_iff ] at hz;
    rcases hz with ⟨ h₁ | h₁, h₂ | h₂ ⟩ <;> rw [ show z = ⟨ z.re, z.im ⟩ from rfl ] <;> norm_num [ h₁, h₂, Zsqrtd.ext_iff ];
    · constructor <;> nlinarith;
    · grind;
    · grind;
    · constructor <;> nlinarith;
  · rw [ pow_two ]

/-! ## The Splitting Homomorphism

The map φ(a + bε) = (a+b, a−b) is a ring homomorphism ℤ√1 → ℤ × ℤ.
It is injective but not surjective: its image is the index-2 subring
of pairs (x,y) with x ≡ y (mod 2). This "parity obstruction" is the
algebraic manifestation of the orientation double cover. -/

/-
The splitting map φ: ℤ√1 → ℤ × ℤ sending a + bε to (a+b, a−b).
-/
def splittingMap : M →+* ℤ × ℤ where
  toFun z := (z.re + z.im, z.re - z.im)
  map_one' := by simp
  map_mul' := by
    exact fun x y => Prod.ext ( by simp +decide ; ring ) ( by simp +decide ; ring )
  map_zero' := by simp
  map_add' := by
    simp +zetaDelta at *;
    grind +revert

/-
The splitting map is injective.
-/
theorem splitting_injective : Function.Injective splittingMap := by
  intro x y hxy;
  injection hxy with h₁ h₂ ; exact Zsqrtd.ext ( by linarith ) ( by linarith )

/-
Parity obstruction: the components of φ(z) always have the same parity.
    This is because (a+b) and (a−b) always have the same parity.
-/
theorem parity_obstruction (z : M) :
    (splittingMap z).1 % 2 = (splittingMap z).2 % 2 := by
      simp +arith +decide [ splittingMap ];
      grind

/-
The splitting map sends ε to (1, −1).
-/
theorem splitting_epsilon : splittingMap eps = (1, -1) := by
  rfl

/-! ## Idempotent Rigidity

Over ℚ, the ring ℚ√1 ≅ ℚ × ℚ has nontrivial idempotents (1/2)(1+ε) and (1/2)(1−ε).
But over ℤ, division by 2 is impossible, so the only idempotents are 0 and 1.
This rigidity theorem captures the arithmetic obstruction to decomposition. -/

/-- An element z of the Möbius ring is *idempotent* if z² = z. -/
def IsIdempotent (z : M) : Prop := z * z = z

/-
Idempotent rigidity: the only idempotents in ℤ√1 are 0 and 1.
    This is a non-trivial arithmetic constraint: over ℚ√1 ≅ ℚ × ℚ,
    the elements (1±ε)/2 are idempotent, but the integrality
    condition forces z ∈ {0, 1}.
-/
theorem idempotent_rigidity (z : M) (h : IsIdempotent z) : z = 0 ∨ z = 1 := by
  obtain ⟨a, b, hz⟩ : ∃ a b : ℤ, z = ⟨a, b⟩ := by
    exact ⟨ z.re, z.im, rfl ⟩;
  simp_all +decide [ IsIdempotent ];
  simp_all +decide [ Zsqrtd.ext_iff ];
  rcases lt_trichotomy a 0 with ha | rfl | ha <;> rcases lt_trichotomy b 0 with hb | rfl | hb <;> first | left; constructor <;> nlinarith | right; constructor <;> nlinarith;

/-! ## Orientation Ideals and Annihilators

The ideals (ePos) = (1+ε) and (eNeg) = (1−ε) are the orientation ideals.
Each annihilates the other, and their intersection is zero.
This captures the two "sheets" of the orientation double cover. -/

/-
The orientation ideals annihilate each other.
-/
theorem orientation_annihilate : ∀ (a b : ℤ), (a • ePos) * (b • eNeg) = 0 := by
  intro a b;
  convert congr_arg ( fun x : M => a • x * b • 1 ) zero_divisor using 1 <;> norm_num [ mul_assoc, mul_comm, mul_left_comm ]

/-
If an element is annihilated by both ePos and eNeg, it is zero.
    This shows that the orientation ideals have trivial intersection.
-/
theorem annihilator_intersection (z : M) (hp : ePos * z = 0) (hn : eNeg * z = 0) :
    z = 0 := by
      simp_all +decide [ ePos, eNeg ];
      simp_all +decide [ Zsqrtd.ext_iff ];
      constructor <;> linarith

/-! ## The Mod-4 Norm Obstruction

The norm N(a+bε) = a²−b² can never be ≡ 2 (mod 4).
This is because a²−b² = (a+b)(a−b), and (a+b) ≡ (a−b) mod 2,
so the product is either 0 mod 4 (both even) or odd × odd = odd. -/

/-- **Novel structure**: The norm fiber over n, classifying elements by norm value. -/
structure NormFiber (n : ℤ) where
  element : M
  norm_eq : element.norm = n

/-
Mod-4 obstruction: no element of ℤ√1 has norm ≡ 2 (mod 4).
-/
theorem mod4_obstruction (z : M) : z.norm % 4 ≠ 2 ∧ z.norm % 4 ≠ -2 := by
  rcases Int.even_or_odd' z.re with ⟨ k, hk | hk ⟩ <;> rcases Int.even_or_odd' z.im with ⟨ l, hl | hl ⟩ <;> push_cast [ hk, hl, Zsqrtd.norm ] <;> ring_nf <;> norm_num [ Int.add_emod, Int.sub_emod, Int.mul_emod ]

/-- When the norm n = a²−b², the fiber is nonempty by construction. -/
def norm_fiber_witness (a b : ℤ) : NormFiber (a * a - b * b) :=
  ⟨⟨a, b⟩, by simp [Zsqrtd.norm_def]⟩

/-
2 is not a Möbius norm, confirming the mod-4 obstruction for a specific value.
-/
theorem two_not_norm : ¬ ∃ z : M, z.norm = 2 := by
  exact fun ⟨ z, hz ⟩ => by have := mod4_obstruction z; simp_all +decide ;

end MobiusRing