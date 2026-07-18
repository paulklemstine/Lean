/-
Copyright (c) 2026.
Released under Apache 2.0 license.
-/
import Catalog.Cryptography.BraidGroup

/-!
# Cognitive braids and cyclotomic signatures

This study separates three mathematical layers often conflated in braid-based models of
cognition: Artin braids, isotopy invariants of their closures, and empirical interpretations.
The algebraic results below concern the first two layers only.  A polynomial is represented by
its coefficients in ascending degree order.  Evaluation at a primitive cube root is performed
inside the Eisenstein lattice `ℤ[ω]`, using `ω² + ω + 1 = 0`.
-/

namespace KnotsThatThink

open BraidGroup

/-- Coordinates `a + bω` in the Eisenstein lattice, where `ω² + ω + 1 = 0`. -/
abbrev Eisenstein := ℤ × ℤ

/-- Multiplication in Eisenstein coordinates. -/
def eisensteinMul (x y : Eisenstein) : Eisenstein :=
  (x.1 * y.1 - x.2 * y.2, x.1 * y.2 + x.2 * y.1 - x.2 * y.2)

/-- Squared complex modulus of `a + bω`. -/
def eisensteinNormSq (x : Eisenstein) : ℤ := x.1 ^ 2 - x.1 * x.2 + x.2 ^ 2

/-- The primitive cube root `ω`. -/
def omega : Eisenstein := (0, 1)

/-- Horner evaluation of an integral polynomial at `ω`. -/
def evalAtOmega : List ℤ → Eisenstein
  | [] => (0, 0)
  | a :: p =>
      let r := evalAtOmega p
      (a + (eisensteinMul omega r).1, (eisensteinMul omega r).2)

/-
Multiplication in `ℤ[ω]` preserves the expected quadratic norm.
-/
lemma eisensteinNormSq_mul (x y : Eisenstein) :
    eisensteinNormSq (eisensteinMul x y) = eisensteinNormSq x * eisensteinNormSq y := by
  unfold eisensteinMul eisensteinNormSq; ring;

/-
The chosen cyclotomic element is a cube root of unity.
-/
lemma omega_cube :
    eisensteinMul omega (eisensteinMul omega omega) = (1, 0) := by
  rfl

/-- The three proposed signatures, in ascending-degree coefficient order. -/
def linearPolynomial : List ℤ := [1]

def creativePolynomial : List ℤ := [1, 1, -1]

/-- A degree-shifted form of the figure-eight Jones polynomial.
Multiplication by a monomial does not affect modulus on the unit circle. -/
def confusedPolynomial : List ℤ := [1, -1, 1, -1, 1]

lemma linear_evaluation : evalAtOmega linearPolynomial = (1, 0) := by
  rfl

lemma creative_evaluation : evalAtOmega creativePolynomial = (2, 2) := by
  rfl

lemma confused_evaluation : evalAtOmega confusedPolynomial = (-1, -1) := by
  rfl

/-
At a primitive cube root, the proposed creative signature has squared modulus four,
whereas both comparison signatures have squared modulus one.
-/
theorem cyclotomic_signature_separation :
    eisensteinNormSq (evalAtOmega creativePolynomial) = 4 ∧
    eisensteinNormSq (evalAtOmega linearPolynomial) = 1 ∧
    eisensteinNormSq (evalAtOmega confusedPolynomial) = 1 := by
  rw [creative_evaluation, linear_evaluation, confused_evaluation]
  constructor
  · change (2 : ℤ) ^ 2 - 2 * 2 + 2 ^ 2 = 4
    ring
  constructor
  · change (1 : ℤ) ^ 2 - 1 * 0 + 0 ^ 2 = 1
    ring
  · change (-1 : ℤ) ^ 2 - (-1) * (-1) + (-1) ^ 2 = 1
    ring

/-
Distinct writhe is a rigorous obstruction to equality of cognitive braids.
-/
theorem braid_ne_of_writhe_ne {n : ℕ} {β γ : BraidGrp n}
    (h : writhe n β ≠ writhe n γ) : β ≠ γ := by
  exact fun h' => h <| h'.symm ▸ rfl

/-
The two-strand braid whose closure is the standard trefoil representative is not the
identity braid.  This is a statement about the braid itself, independent of closure conventions.
-/
theorem trefoil_braid_nontrivial :
    let s : BraidGrp 1 := sigma (0 : Fin 1)
    s ^ 3 ≠ 1 := by
  convert braid_ne_of_writhe_ne _;
  simp +decide

/-
Writhe is additive and therefore cannot distinguish a balanced word from the identity.
This boundary result prevents exponent sum from being misidentified as a knot invariant.
-/
theorem balanced_word_writhe_zero {n : ℕ} (i j : Fin n) :
    writhe n (sigma i * (sigma j)⁻¹) = writhe n (1 : BraidGrp n) := by
  simp +decide [ BraidGroup.writhe_sigma ]

/-
Any proposed closure invariant is constant on an explicitly supplied equivalence relation
exactly when it factors through equivalence classes.  This theorem records the indispensable
hypothesis; invariance does not follow merely from calling a function a Jones polynomial.
-/
theorem invariant_iff_class_constant {α R : Type*} (equiv : R → R → Prop) (J : R → α) :
    (∀ x y, equiv x y → J x = J y) ↔
      ∀ x, ∀ y ∈ {z | equiv x z}, J y = J x := by
  grind

-- !-- Lab Notes -- !--
/-
Hypothesis.  Cube-root evaluation might separate the three suggested signatures, while writhe
might certify nontriviality of the trefoil braid representative.

Experiment.  Horner evaluation in the Eisenstein lattice gives respectively `(1,0)`, `(2,2)`,
and `(-1,-1)`.  Their squared norms are `1`, `4`, and `1`.  Independently, the catalogued writhe
homomorphism sends the cube of the sole two-strand generator to exponent sum three.

Analysis.  The cyclotomic statistic separates the proposed creative polynomial from both
comparators, but it does not separate the proposed linear and confused signatures.  Thus it
cannot by itself rank all three examples.  Writhe detects some nontrivial braids but loses all
balanced words.

Critique.  Reidemeister equivalence applies to link diagrams, whereas equality in an Artin braid
group is generated by braid relations; closure equivalence additionally involves Markov moves.
Moreover, `V = 1` does not logically imply that a knot is trivial without a separate detection
theorem.  No empirical claim about cognition follows from these algebraic calculations.

Synthesis.  The surviving result is a guarded cross-domain bridge: Artin writhe supplies a
nontriviality certificate for the trefoil braid representative, and Eisenstein norm computes the
cube-root statistic exactly.  Claims of isotopy invariance and cognitive interpretation remain
separate hypotheses requiring independent evidence.
-/

end KnotsThatThink