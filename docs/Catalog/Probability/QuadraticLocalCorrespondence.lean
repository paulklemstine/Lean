import Mathlib.NumberTheory.LegendreSymbol.Basic

/-!
# Quadratic local correspondence: ramification and Legendre colors

For a quadratic discriminant `D` and a rational prime `p`, the quadratic character has
local value `χ_D(p) = (D/p)`.  This file proves, uniformly in `D` and `p`, the elementary
local dictionary behind the degree-two case:

* value `0` exactly at ramified primes (`p ∣ D`);
* away from ramification the value is one of `±1` and has square `1`;
* value `1` exactly when `D` is a square modulo `p`;
* value `-1` exactly when `D` is a nonsquare modulo `p`;
* these facts combine into a three-way ramified/split/inert classification.

This is the rigorously accessible local arithmetic core of the proposed test.  It does not
claim to formalize the global Langlands correspondence or enumerate quadratic fields.
-/

namespace LanglandsForToddlers

/-- The local quadratic color attached to an integer `D` at a prime `p`. -/
def quadraticColor (D : ℤ) (p : ℕ) [Fact p.Prime] : ℤ := legendreSym p D

/-
The local color vanishes exactly when the prime ramifies (divides `D`).
-/
theorem quadraticColor_eq_zero_iff_dvd (D : ℤ) (p : ℕ) [Fact p.Prime] :
    quadraticColor D p = 0 ↔ (p : ℤ) ∣ D := by
  unfold quadraticColor; simp +decide [ legendreSym.eq_zero_iff ] ;
  rw [ ZMod.intCast_zmod_eq_zero_iff_dvd ]

/-
At an unramified prime, a quadratic color is exactly one of the two signs.
-/
theorem quadraticColor_eq_one_or_neg_one (D : ℤ) (p : ℕ) [Fact p.Prime]
    (hunram : ¬(p : ℤ) ∣ D) :
    quadraticColor D p = 1 ∨ quadraticColor D p = -1 := by
  have hcolor_ne : quadraticColor D p ≠ 0 := by
    intro hzero
    exact hunram ((quadraticColor_eq_zero_iff_dvd D p).mp hzero)
  have hcast_ne : (D : ZMod p) ≠ 0 := by
    intro hcast
    apply hcolor_ne
    rw [quadraticColor, legendreSym.eq_zero_iff]
    exact hcast
  exact legendreSym.eq_one_or_neg_one p hcast_ne

/-
Every unramified quadratic color has order dividing two.
-/
theorem quadraticColor_sq_eq_one (D : ℤ) (p : ℕ) [Fact p.Prime]
    (hunram : ¬(p : ℤ) ∣ D) :
    quadraticColor D p ^ 2 = 1 := by
  cases quadraticColor_eq_one_or_neg_one D p hunram <;> simp +decide [ * ]

/-
The complete ramified/unramified numerical packet for a local quadratic color.
-/
theorem quadraticColor_local_packet (D : ℤ) (p : ℕ) [Fact p.Prime] :
    (quadraticColor D p = 0 ↔ (p : ℤ) ∣ D) ∧
    (¬(p : ℤ) ∣ D → quadraticColor D p ^ 2 = 1) ∧
    (¬(p : ℤ) ∣ D ↔ (D : ZMod p) ≠ 0) := by
  refine ⟨quadraticColor_eq_zero_iff_dvd D p,
    quadraticColor_sq_eq_one D p, ?_⟩
  constructor <;> intro h <;>
    simpa [ZMod.intCast_zmod_eq_zero_iff_dvd] using h

/-
At an unramified prime, color `1` is precisely the split (square-residue) case.
-/
theorem quadraticColor_eq_one_iff_isSquare (D : ℤ) (p : ℕ) [Fact p.Prime]
    (hunram : ¬(p : ℤ) ∣ D) :
    quadraticColor D p = 1 ↔ IsSquare (D : ZMod p) := by
  have hnonzero : (D : ZMod p) ≠ 0 :=
    (quadraticColor_local_packet D p).2.2.mp hunram
  convert legendreSym.eq_one_iff p hnonzero using 1

/-
Color `-1` is precisely the inert (nonsquare-residue) case.
-/
theorem quadraticColor_eq_neg_one_iff_not_isSquare (D : ℤ) (p : ℕ) [Fact p.Prime] :
    quadraticColor D p = -1 ↔ ¬ IsSquare (D : ZMod p) := by
  by_cases hunram : ¬(p : ℤ) ∣ D
  · have hsplit := quadraticColor_eq_one_iff_isSquare D p hunram
    grind +suggestions
  ·
    simp_all +decide [ quadraticColor, legendreSym ];
    obtain ⟨ k, hk ⟩ := hunram; simp +decide [ hk, quadraticCharFun ] ;

/-
The local shape-color dictionary, packaged as a three-way classification.

The three alternatives correspond to ramified, split, and inert behavior respectively.
This final result uses the preceding nonsquare characterization and the local packet.
-/
theorem quadratic_local_shape_color_classification (D : ℤ) (p : ℕ) [Fact p.Prime] :
    ((p : ℤ) ∣ D ∧ quadraticColor D p = 0) ∨
    (¬(p : ℤ) ∣ D ∧ IsSquare (D : ZMod p) ∧ quadraticColor D p = 1) ∨
    (¬(p : ℤ) ∣ D ∧ ¬ IsSquare (D : ZMod p) ∧ quadraticColor D p = -1) := by
  grind +suggestions

end LanglandsForToddlers