/-
# Radicals always exist over quadratic finite fields

Radical isogeny algorithms are run on supersingular curves over `𝔽_{p²}`.  A
radical 2-isogeny step from the Montgomery parameter `A` needs a square root of
`A + 2`; if that root is missing one has to change the Montgomery model, using
instead `√(2-A)` or `√(A²-4)` (see `ModularTwoIsogeny`, where all three models
were shown to hit the same point of the `j`-line).

The main theorem of this file, `exists_radical_of_isSquare_neg_one`, is that at
least one of these three radicals is *always* available, as soon as `-1` is a
square in the base field.  The proof is a quadratic-character computation
resting on the identity

`(A+2)·(2-A) = -(A²-4)`,

so the three radicands multiply to minus a square: their quadratic characters
cannot all be `-1`.

`isSquare_neg_one_of_card_sq` specialises this to a field of square
cardinality — exactly the quadratic finite fields `𝔽_{p²}` of supersingular
isogeny cryptography — where `-1` is automatically a square.  Combined with the
model-independence theorem of `ModularTwoIsogeny` this yields
`exists_montgomery_quotient_model`: over `𝔽_{p²}` the 2-isogenous curve always
has a Montgomery model defined over the same field, so a radical walk never
needs a field extension.

The final section records small, fully checked supersingular instances of the
radical step, verified by `decide`.
-/
import Cryptography.IsogenySIDH.ModularTwoIsogeny

namespace Cryptography.IsogenySIDH

open Finset

/-! ## Existence of one of the three radicals -/

section RadicalExistence

variable {F : Type*} [Field F] [Fintype F] [DecidableEq F]

omit [Fintype F] [DecidableEq F] in
/-- The three radicands of the three Montgomery models of the quotient multiply
to minus a square. -/
theorem radicand_product (A : F) : (A + 2) * (2 - A) = -(A ^ 2 - 4) := by ring

/-- **At least one radical exists.**  If `-1` is a square in the finite field
`F`, then for every `A` at least one of `A+2`, `2-A`, `A²-4` is a square in
`F`.  Hence (when `A² ≠ 4`) one of the three Montgomery renormalisations of the
quotient of `E_A` by `⟨(0,0)⟩` is already defined over `F`. -/
theorem exists_radical_of_isSquare_neg_one (hneg : IsSquare (-1 : F)) (A : F) :
    IsSquare (A + 2) ∨ IsSquare (2 - A) ∨ IsSquare (A ^ 2 - 4) := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨h1, h2, h3⟩ := hcon
  have hchi1 : quadraticChar F (A + 2) = -1 := quadraticChar_neg_one_iff_not_isSquare.mpr h1
  have hchi2 : quadraticChar F (2 - A) = -1 := quadraticChar_neg_one_iff_not_isSquare.mpr h2
  have hchi3 : quadraticChar F (A ^ 2 - 4) = -1 := quadraticChar_neg_one_iff_not_isSquare.mpr h3
  have hchineg : quadraticChar F (-1) = 1 :=
    (quadraticChar_one_iff_isSquare (a := (-1 : F)) (neg_ne_zero.mpr one_ne_zero)).mpr hneg
  have hprod : quadraticChar F ((A + 2) * (2 - A)) = 1 := by
    rw [map_mul, hchi1, hchi2]; norm_num
  rw [radicand_product] at hprod
  have hsplit : quadraticChar F (-(A ^ 2 - 4)) = -1 := by
    have hrw : (-(A ^ 2 - 4)) = (-1 : F) * (A ^ 2 - 4) := by ring
    rw [hrw, map_mul, hchineg, hchi3]; norm_num
  rw [hsplit] at hprod
  norm_num at hprod

omit [DecidableEq F] in
/-- In a finite field whose cardinality is a perfect square — in particular in
`𝔽_{p²}` for odd `p` — the element `-1` is a square. -/
theorem isSquare_neg_one_of_card_sq (hF : ringChar F ≠ 2) {q : ℕ}
    (hcard : Fintype.card F = q ^ 2) : IsSquare (-1 : F) := by
  have hcardodd : Fintype.card F % 2 = 1 := FiniteField.odd_card_of_char_ne_two hF
  rw [hcard] at hcardodd
  have hqodd : q % 2 = 1 := by
    rcases Nat.even_or_odd q with he | ho
    · obtain ⟨k, hk⟩ := he
      subst hk
      have hsq : (k + k) ^ 2 = 2 * (2 * k ^ 2) := by ring
      rw [hsq] at hcardodd
      omega
    · obtain ⟨m, hm⟩ := ho
      omega
  have hmod : q ^ 2 % 4 = 1 := by
    obtain ⟨m, hm⟩ : Odd q := Nat.odd_iff.mpr hqodd
    subst hm
    have hsq : (2 * m + 1) ^ 2 = 4 * (m ^ 2 + m) + 1 := by ring
    rw [hsq]
    omega
  rw [FiniteField.isSquare_neg_one_iff, hcard, hmod]
  norm_num

/-- **The quotient curve always has a Montgomery model over the same field.**
If `-1` is a square in the finite field `F` of odd characteristic and `A² ≠ 4`,
then some `A' ∈ F` is a Montgomery parameter for the curve `2`-isogenous to
`E_A` via `⟨(0,0)⟩`; i.e. `jMont A' = jQuot A`.  No field extension is ever
needed for a radical walk over `𝔽_{p²}`. -/
theorem exists_montgomery_quotient_model (hF : ringChar F ≠ 2)
    (hneg : IsSquare (-1 : F)) {A : F} (hd : A ^ 2 - 4 ≠ 0) :
    ∃ A' : F, jMont A' = jQuot A := by
  have htwo : (2 : F) ≠ 0 := Ring.two_ne_zero hF
  have hAp2 : A + 2 ≠ 0 := fun h => hd (by linear_combination (A - 2) * h)
  have hAm2 : A - 2 ≠ 0 := fun h => hd (by linear_combination (A + 2) * h)
  rcases exists_radical_of_isSquare_neg_one hneg A with hs | hs | hs
  · obtain ⟨a, ha⟩ := hs
    have hsq : a ^ 2 = A + 2 := by rw [ha]; ring
    have ha0 : a ≠ 0 := by
      intro h; apply hAp2; rw [← hsq, h]; ring
    exact ⟨radTwoParam A a, jMont_radTwoParam htwo ha0 hsq hd⟩
  · obtain ⟨g, hg⟩ := hs
    have hsq : g ^ 2 = 2 - A := by rw [hg]; ring
    have hg0 : g ≠ 0 := by
      intro h
      apply hAm2
      have : (2 : F) - A = 0 := by rw [← hsq, h]; ring
      linear_combination -this
    exact ⟨radTwoParamMinus A g, jMont_radTwoParamMinus htwo hg0 hsq hd⟩
  · obtain ⟨d, hdd⟩ := hs
    have hsq : d ^ 2 = A ^ 2 - 4 := by rw [hdd]; ring
    have hd0 : d ≠ 0 := by
      intro h; apply hd; rw [← hsq, h]; ring
    exact ⟨radTwoParamCentre A d, jMont_radTwoParamCentre htwo hd0 hsq⟩

/-- Consequently, over a finite field of square cardinality and odd
characteristic every nondegenerate Montgomery parameter has a `2`-isogenous
Montgomery neighbour in the same field, and the pair of `j`-invariants is a
zero of the modular polynomial `Φ₂`. -/
theorem exists_modPoly2_neighbour_of_card_sq (hF : ringChar F ≠ 2) {q : ℕ}
    (hcard : Fintype.card F = q ^ 2) {A : F} (hd : A ^ 2 - 4 ≠ 0) :
    ∃ A' : F, modPoly2 (jMont A) (jMont A') = 0 := by
  obtain ⟨A', hA'⟩ :=
    exists_montgomery_quotient_model hF (isSquare_neg_one_of_card_sq hF hcard) hd
  exact ⟨A', by rw [hA']; exact modPoly2_jMont_jQuot hd⟩

end RadicalExistence

/-! ## Verified supersingular instances

For a prime `p ≡ 3 mod 4` the curve `y² = x³ + x` over `𝔽_p` is supersingular,
so it has exactly `p + 1` points.  We check this and the corresponding radical
step by exhaustive computation. -/

section Instances

instance : Fact (Nat.Prime 7) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 23) := ⟨by norm_num⟩

/-- The affine points of the generalized Montgomery curve `B y² = x³ + A x² + x`
over `ZMod p`. -/
def affineMontPoints (p : ℕ) [NeZero p] (B A : ZMod p) : Finset (ZMod p × ZMod p) :=
  Finset.univ.filter fun P => B * P.2 ^ 2 = P.1 ^ 3 + A * P.1 ^ 2 + P.1

/-- Number of projective points: the affine ones plus the single point at
infinity of a Montgomery model. -/
def montPointCount (p : ℕ) [NeZero p] (B A : ZMod p) : ℕ :=
  (affineMontPoints p B A).card + 1

/-- `y² = x³ + x` over `𝔽₇` is supersingular: it has `7 + 1` points. -/
theorem supersingular_seven_source : montPointCount 7 1 0 = 7 + 1 := by decide

/-- In `𝔽₇` the radical `α = 3` is a square root of `A + 2 = 2`. -/
theorem radical_seven : (3 : ZMod 7) ^ 2 = (0 : ZMod 7) + 2 := by decide

/-- The radical step from `A = 0` in `𝔽₇` produces the Montgomery parameter `1`
with twisting coefficient `6`. -/
theorem radStep_seven :
    radTwoParam (0 : ZMod 7) 3 = 1 ∧ radTwoTwist (3 : ZMod 7) = 6 := by
  constructor <;> decide

/-- The target `6 y² = x³ + x² + x` of the radical step over `𝔽₇` is again
supersingular. -/
theorem supersingular_seven_target : montPointCount 7 6 1 = 7 + 1 := by decide

/-- The radical step over `𝔽₇` is certified by the modular polynomial. -/
theorem modPoly2_seven :
    modPoly2 (jMont (0 : ZMod 7)) (jMont (radTwoParam (0 : ZMod 7) 3)) = 0 := by decide

/-- `y² = x³ + x` over `𝔽₂₃` is supersingular. -/
theorem supersingular_twentythree_source : montPointCount 23 1 0 = 23 + 1 := by decide

/-- In `𝔽₂₃` the radical `α = 5` is a square root of `A + 2 = 2`. -/
theorem radical_twentythree : (5 : ZMod 23) ^ 2 = (0 : ZMod 23) + 2 := by decide

/-- The radical step from `A = 0` in `𝔽₂₃` produces parameter `19` and twist
coefficient `21`. -/
theorem radStep_twentythree :
    radTwoParam (0 : ZMod 23) 5 = 19 ∧ radTwoTwist (5 : ZMod 23) = 21 := by
  constructor <;> decide

/-- The target `21 y² = x³ + 19 x² + x` of the radical step over `𝔽₂₃` is again
supersingular. -/
theorem supersingular_twentythree_target : montPointCount 23 21 19 = 23 + 1 := by decide

/-- The radical step over `𝔽₂₃` is certified by the modular polynomial. -/
theorem modPoly2_twentythree :
    modPoly2 (jMont (0 : ZMod 23)) (jMont (radTwoParam (0 : ZMod 23) 5)) = 0 := by decide

end Instances

end Cryptography.IsogenySIDH