import Mathlib

/-!
# Berggren Semigroup: Definitions for Second-Extremality Theory

Core definitions for the Berggren tree action on Pythagorean triples,
including word evaluation, hypotenuse extraction, and the generalized
hypotenuse formulas for pure A and C rays from arbitrary starting triples.
-/

set_option maxHeartbeats 800000

namespace BerggrenExtremal

/-! ## Core Definitions -/

/-- A Pythagorean triple satisfies a² + b² = c². -/
def IsPythTriple (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- Berggren generator A. -/
def bergA (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- Berggren generator B. -/
def bergB (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Berggren generator C. -/
def bergC (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- The three Berggren generators. -/
inductive Gen where | A | B | C
  deriving DecidableEq, Repr, Fintype

/-- Apply a generator to a triple. -/
def applyGen : Gen → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | .A, (a, b, c) => bergA a b c
  | .B, (a, b, c) => bergB a b c
  | .C, (a, b, c) => bergC a b c

/-- A word is a list of generators (applied left-to-right). -/
abbrev Word := List Gen

/-- Apply a word to a triple (first letter applied first). -/
def applyWord : Word → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | [], t => t
  | g :: w, t => applyWord w (applyGen g t)

/-- The root triple (3, 4, 5). -/
def root : ℤ × ℤ × ℤ := (3, 4, 5)

/-- Extract hypotenuse from a triple. -/
def hyp (v : ℤ × ℤ × ℤ) : ℤ := v.2.2

/-- Hypotenuse of a word applied to root. -/
def cOfWord (w : Word) : ℤ := hyp (applyWord w root)

/-! ## Basic Properties -/

theorem applyWord_nil (t : ℤ × ℤ × ℤ) : applyWord [] t = t := rfl

theorem applyWord_cons (g : Gen) (w : Word) (t : ℤ × ℤ × ℤ) :
    applyWord (g :: w) t = applyWord w (applyGen g t) := rfl

theorem applyWord_append (w₁ w₂ : Word) (t : ℤ × ℤ × ℤ) :
    applyWord (w₁ ++ w₂) t = applyWord w₂ (applyWord w₁ t) := by
  induction w₁ generalizing t with
  | nil => simp [applyWord]
  | cons g w ih => simp [applyWord, ih]

/-! ## Hypotenuse Formulas -/

/-- Hypotenuse after applying A. -/
theorem hyp_bergA (a b c : ℤ) : hyp (bergA a b c) = 2*a - 2*b + 3*c := by
  simp [hyp, bergA]

/-- Hypotenuse after applying B. -/
theorem hyp_bergB (a b c : ℤ) : hyp (bergB a b c) = 2*a + 2*b + 3*c := by
  simp [hyp, bergB]

/-- Hypotenuse after applying C. -/
theorem hyp_bergC (a b c : ℤ) : hyp (bergC a b c) = -2*a + 2*b + 3*c := by
  simp [hyp, bergC]

/-! ## Leg Difference After Generators

Key structural insight: after A, the second leg dominates (b' > a');
after C, the first leg dominates (a' > b'); after B, the sign depends on input.
The exact difference formulas are:
-/

/-- After A: b' - a' = a + b. -/
theorem bergA_leg_diff (a b c : ℤ) :
    (bergA a b c).2.1 - (bergA a b c).1 = a + b := by
  simp [bergA]; ring

/-- After C: a' - b' = a + b. -/
theorem bergC_leg_diff (a b c : ℤ) :
    (bergC a b c).1 - (bergC a b c).2.1 = a + b := by
  simp [bergC]; ring

/-- After B: a' - b' = -(a - b) = b - a. -/
theorem bergB_leg_diff (a b c : ℤ) :
    (bergB a b c).1 - (bergB a b c).2.1 = -(a - b) := by
  simp [bergB]; ring

/-! ## Generalized Hypotenuse Formulas for Pure Rays

The matrices A and C are both unipotent (eigenvalue 1 with multiplicity 3),
so A^m and C^m are polynomial in m. The row-3 entries give exact hypotenuse
formulas from any starting triple.
-/

/-- Predicted hypotenuse of A^m applied from (a,b,c). -/
def hypAllAFrom (m : ℕ) (a b c : ℤ) : ℤ :=
  2 * (m : ℤ) * a - 2 * (m : ℤ)^2 * b + (2 * (m : ℤ)^2 + 1) * c

/-- Predicted hypotenuse of C^m applied from (a,b,c). -/
def hypAllCFrom (m : ℕ) (a b c : ℤ) : ℤ :=
  -2 * (m : ℤ)^2 * a + 2 * (m : ℤ) * b + (2 * (m : ℤ)^2 + 1) * c

/-- The generalized hypotenuse formula for A^m is correct. -/
theorem hyp_allA_from (m : ℕ) (a b c : ℤ) :
    hyp (applyWord (List.replicate m Gen.A) (a, b, c)) = hypAllAFrom m a b c := by
  induction m generalizing a b c with
  | zero => simp [applyWord, hyp, hypAllAFrom]
  | succ m ih =>
    simp only [List.replicate_succ, applyWord_cons]
    rw [ih]
    simp [applyGen, bergA, hypAllAFrom]
    ring

/-- The generalized hypotenuse formula for C^m is correct. -/
theorem hyp_allC_from (m : ℕ) (a b c : ℤ) :
    hyp (applyWord (List.replicate m Gen.C) (a, b, c)) = hypAllCFrom m a b c := by
  induction m generalizing a b c with
  | zero => simp [applyWord, hyp, hypAllCFrom]
  | succ m ih =>
    simp only [List.replicate_succ, applyWord_cons]
    rw [ih]
    simp [applyGen, bergC, hypAllCFrom]
    ring

/-- **Key algebraic identity**: The difference hypAllA - hypAllC = 2m(m+1)(a-b).
This controls which ray is optimal depending on the sign of a-b. -/
theorem hyp_allA_minus_allC (m : ℕ) (a b c : ℤ) :
    hypAllAFrom m a b c - hypAllCFrom m a b c = 2 * (m : ℤ) * ((m : ℤ) + 1) * (a - b) := by
  simp [hypAllAFrom, hypAllCFrom]; ring

/-! ## Closed Forms from Root -/

/-- Hypotenuse of A^n from root: 2n² + 6n + 5. -/
theorem cOfWord_allA (n : ℕ) :
    cOfWord (List.replicate n Gen.A) = 2 * (n : ℤ)^2 + 6 * n + 5 := by
  simp [cOfWord, hyp_allA_from, hypAllAFrom, root]; ring

/-- Hypotenuse of C^n from root: 4n² + 8n + 5. -/
theorem cOfWord_allC (n : ℕ) :
    cOfWord (List.replicate n Gen.C) = 4 * (n : ℤ)^2 + 8 * n + 5 := by
  simp [cOfWord, hyp_allC_from, hypAllCFrom, root]; ring

/-- The A-ray always has strictly smaller hypotenuse than the C-ray for n ≥ 1. -/
theorem hyp_gap_A_C (n : ℕ) (hn : 1 ≤ n) :
    cOfWord (List.replicate n Gen.A) < cOfWord (List.replicate n Gen.C) := by
  rw [cOfWord_allA, cOfWord_allC]; nlinarith

end BerggrenExtremal