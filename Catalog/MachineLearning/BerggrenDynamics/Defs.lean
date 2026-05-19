import Mathlib

/-!
# Berggren Tree: Arithmetic Dynamics — Core Definitions

This file establishes the foundational definitions for studying the Berggren
ternary tree of primitive Pythagorean triples as a dynamical system.

## Main Definitions

- `BerggrenGen`: The type of Berggren generators (A, B, C), indexed by `Fin 3`.
- `berggrenMatrix`: The 3×3 integer matrix for each generator.
- `berggrenChild`: Coordinate-level child computation.
- `evalWord`: Evaluates a word in the free monoid on {A,B,C} starting from (3,4,5).
- `hyp`: Extracts the hypotenuse (third component) from a triple.
- `allA_triple`: The triple at depth n along the all-A branch.
- `IsBerggrenTriple`: Predicate for positive primitive Pythagorean triples.
-/

namespace BerggrenDynamics

/-! ## Generator type and matrices -/

/-- Berggren generators indexed as 0=A, 1=B, 2=C. -/
abbrev BerggrenGen := Fin 3

/-- The three Berggren generator matrices. -/
def berggrenMatrix : BerggrenGen → Matrix (Fin 3) (Fin 3) ℤ
  | ⟨0, _⟩ => !![1, -2, 2; 2, -1, 2; 2, -2, 3]
  | ⟨1, _⟩ => !![1, 2, 2; 2, 1, 2; 2, 2, 3]
  | ⟨2, _⟩ => !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- Apply a Berggren generator to a triple (a,b,c). -/
def berggrenChild (g : BerggrenGen) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  match g.val with
  | 0 => (t.1 - 2*t.2.1 + 2*t.2.2, 2*t.1 - t.2.1 + 2*t.2.2, 2*t.1 - 2*t.2.1 + 3*t.2.2)
  | 1 => (t.1 + 2*t.2.1 + 2*t.2.2, 2*t.1 + t.2.1 + 2*t.2.2, 2*t.1 + 2*t.2.1 + 3*t.2.2)
  | _ => (-t.1 + 2*t.2.1 + 2*t.2.2, -2*t.1 + t.2.1 + 2*t.2.2, -2*t.1 + 2*t.2.1 + 3*t.2.2)

/-- The root triple (3,4,5). -/
def root : ℤ × ℤ × ℤ := (3, 4, 5)

/-- Evaluate a word (list of generators) by folding child applications from the root. -/
def evalWord (w : List BerggrenGen) : ℤ × ℤ × ℤ :=
  w.foldl (fun t g => berggrenChild g t) root

/-- Extract the hypotenuse (third component) from a triple. -/
def hyp (t : ℤ × ℤ × ℤ) : ℤ := t.2.2

/-- A triple (a,b,c) is a positive primitive Pythagorean triple. -/
def IsBerggrenTriple (t : ℤ × ℤ × ℤ) : Prop :=
  t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 ∧
  0 < t.1 ∧ 0 < t.2.1 ∧ 0 < t.2.2 ∧
  Int.gcd t.1 t.2.1 = 1

/-- The triple along the all-A branch at depth n, given by the exact formula. -/
def allA_triple (n : ℕ) : ℤ × ℤ × ℤ :=
  (2 * n + 3, 2 * n ^ 2 + 6 * n + 4, 2 * n ^ 2 + 6 * n + 5)

/-- The word consisting of n copies of generator A (index 0). -/
def allA_word (n : ℕ) : List BerggrenGen :=
  List.replicate n (0 : Fin 3)

/-- Apply generator A to a triple. -/
def childA (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  berggrenChild (0 : Fin 3) t

/-- Apply generator B to a triple. -/
def childB (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  berggrenChild (1 : Fin 3) t

/-- Apply generator C to a triple. -/
def childC (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  berggrenChild (2 : Fin 3) t

/-- Apply a word to a given starting triple. -/
def applyWord (w : List BerggrenGen) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  w.foldl (fun t g => berggrenChild g t) t

end BerggrenDynamics