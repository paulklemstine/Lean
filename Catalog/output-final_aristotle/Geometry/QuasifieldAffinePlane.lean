/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Coordinatizing Affine Planes by Quasifields

A **quasifield** is the algebraic structure that coordinatizes an affine
translation plane.  It is an additive abelian group `Q` equipped with a
multiplication `∘` that has a two-sided identity, is right distributive over
addition, has no zero divisors (encoded by unique left/right division for
non-zero elements) and satisfies the *planar* (Veblen) axiom.  Unlike a field,
a quasifield need be neither commutative, associative, nor left distributive.

The main results of this file are purely geometric and completely general:

* `Quasifield.two_points_unique_line` — any two distinct points of the
  coordinatized plane lie on a **unique** line.  This is the first incidence
  axiom of an affine plane, and it follows from right distributivity together
  with unique left division.

* `Quasifield.parallel_playfair` — Playfair's axiom: through any point there is
  a unique line parallel to a given line.

* `Quasifield.exists_four_general_position` — a non-degeneracy witness: there
  exist four points no three of which are collinear.

Together these say every quasifield coordinatizes a genuine affine plane.

A division ring gives a quasifield (`DivisionRing.toQuasifield`); the classical
theorem is that the plane is *Desarguesian* precisely when the coordinatizing
quasifield can be chosen to be a division ring (associative, two-sided
distributive).  A quasifield failing left distributivity therefore yields a
**non-Desarguesian** plane; a concrete example of order `9` is developed in
`Catalog.Geometry.NearfieldPlaneOrder9`.

## References
* Hughes, D. R. and Piper, F. C. *Projective Planes*, Springer 1973.
* Hall, M. *Projective planes*, Trans. Amer. Math. Soc. 54 (1943).
-/

namespace QuasifieldPlane

open Function

/-- A (right) **quasifield** on an additive abelian group `Q`:
multiplication with two-sided identity, right distributivity, unique two-sided
division for non-zero elements, and the planar (Veblen) axiom. -/
structure Quasifield (Q : Type*) [AddCommGroup Q] where
  /-- multiplicative identity -/
  one : Q
  /-- the (generally non-associative) multiplication -/
  mul : Q → Q → Q
  one_ne_zero : one ≠ 0
  mul_one : ∀ a, mul a one = a
  one_mul : ∀ a, mul one a = a
  mul_zero : ∀ a, mul a 0 = 0
  zero_mul : ∀ a, mul 0 a = 0
  /-- right distributive law -/
  right_distrib : ∀ a b c, mul (a + b) c = mul a c + mul b c
  /-- unique left division: for `a ≠ 0` the map `x ↦ a ∘ x` is a bijection -/
  left_div : ∀ a, a ≠ 0 → ∀ c, ∃! x, mul a x = c
  /-- unique right division: for `a ≠ 0` the map `x ↦ x ∘ a` is a bijection -/
  right_div : ∀ a, a ≠ 0 → ∀ c, ∃! x, mul x a = c
  /-- planar (Veblen) axiom: for `a ≠ b` the map `x ↦ x∘a - x∘b` is a bijection -/
  planar : ∀ a b, a ≠ b → ∀ d, ∃! x, mul x a = mul x b + d

variable {Q : Type*} [AddCommGroup Q]

/-- Right-distributivity in subtracted form: `(a - b)∘c = a∘c - b∘c`. -/
theorem Quasifield.sub_mul (F : Quasifield Q) (a b c : Q) :
    F.mul (a - b) c = F.mul a c - F.mul b c := by
  have h := F.right_distrib (a - b) b c
  rw [sub_add_cancel] at h
  rw [h]; abel

/-! ## Lines of the coordinatized plane

Points are pairs `Q × Q`.  Lines come in two kinds:
* `ordinary m b` is the line `y = x ∘ m + b`;
* `vertical c` is the line `x = c`. -/

/-- A line in the affine plane coordinatized by a quasifield. -/
inductive Line (Q : Type*) where
  | ordinary : Q → Q → Line Q
  | vertical : Q → Line Q
  deriving DecidableEq

/-- Incidence: whether point `p` lies on line `L`. -/
def Quasifield.onLine (F : Quasifield Q) (p : Q × Q) : Line Q → Prop
  | Line.ordinary m b => p.2 = F.mul p.1 m + b
  | Line.vertical c => p.1 = c

@[simp] theorem Quasifield.onLine_ordinary (F : Quasifield Q) (p : Q × Q) (m b : Q) :
    F.onLine p (Line.ordinary m b) ↔ p.2 = F.mul p.1 m + b := Iff.rfl

@[simp] theorem Quasifield.onLine_vertical (F : Quasifield Q) (p : Q × Q) (c : Q) :
    F.onLine p (Line.vertical c) ↔ p.1 = c := Iff.rfl

/-! ## First incidence axiom: two points determine a unique line -/

/-
**Two distinct points lie on a unique line.**  The proof splits on whether
the two points share an `x`-coordinate.  If so, the only line through both is
the corresponding vertical line.  Otherwise the slope is produced by unique left
division applied to `x₁ - x₂ ≠ 0`, using right distributivity to reduce the
incidence equations.
-/
theorem Quasifield.two_points_unique_line (F : Quasifield Q) {p q : Q × Q}
    (hpq : p ≠ q) : ∃! L : Line Q, F.onLine p L ∧ F.onLine q L := by
  obtain ⟨x₁, y₁⟩ := p
  obtain ⟨x₂, y₂⟩ := q;
  by_cases hx : x₁ = x₂;
  · refine' ⟨ Line.vertical x₁, _, _ ⟩ <;> simp_all +decide [ Quasifield.onLine ];
    rintro ( _ | _ ) <;> simp_all +decide;
    grind;
  · obtain ⟨m₀, hm₀⟩ : ∃! m₀, F.mul (x₁ - x₂) m₀ = y₁ - y₂ := by
      exact F.left_div _ ( sub_ne_zero.mpr hx ) _;
    refine' ⟨ Line.ordinary m₀ ( y₁ - F.mul x₁ m₀ ), _, _ ⟩ <;> simp +decide [ Quasifield.onLine ] at *;
    · have := F.sub_mul x₁ x₂ m₀; simp_all +decide [ sub_eq_iff_eq_add ] ;
      abel1;
    · rintro ( _ | _ ) <;> simp +decide [ Quasifield.sub_mul ] at *; all_goals grind

/-! ## Parallelism and Playfair's axiom -/

/-- Two lines are parallel when they are equal or share no point. -/
def Quasifield.Parallel (F : Quasifield Q) (L M : Line Q) : Prop :=
  L = M ∨ ∀ p, ¬ (F.onLine p L ∧ F.onLine p M)

/-- Vertical lines never meet an ordinary line: they always share exactly one
point, hence are not parallel unless equal. -/
theorem Quasifield.vertical_meets_ordinary (F : Quasifield Q) (c m b : Q) :
    F.onLine (c, F.mul c m + b) (Line.vertical c) ∧
    F.onLine (c, F.mul c m + b) (Line.ordinary m b) := by
  constructor <;> simp [Quasifield.onLine]

/-
**Playfair's axiom.**  Through any point there is a unique line parallel to a
given line.  For a vertical `L` the parallel is the vertical through the point;
for an ordinary `L` of slope `m` it is the ordinary line of slope `m` through the
point.  Uniqueness uses the planar axiom to show lines of different slope meet.
-/
theorem Quasifield.parallel_playfair (F : Quasifield Q) (L : Line Q) (p : Q × Q) :
    ∃! M : Line Q, F.onLine p M ∧ F.Parallel L M := by
  rcases L with ( m | c );
  · refine' ⟨ Line.ordinary m ( p.2 - F.mul p.1 m ), _, _ ⟩ <;> simp +decide [ Quasifield.onLine, Quasifield.Parallel ];
    · exact em _;
    · rintro ( _ | _ ) <;> simp +decide [ eq_sub_iff_add_eq' ];
      intro h₁ h₂;
      contrapose! h₂;
      rename_i a b c;
      obtain ⟨ x, hx ⟩ := F.planar b m ( by aesop ) ( a - c );
      grind;
  · refine' ⟨ Line.vertical p.1, _, _ ⟩ <;> simp_all +decide [ Quasifield.onLine, Quasifield.Parallel ];
    · exact em _;
    · rintro ( m | c ) <;> simp_all +decide

/-! ## Non-degeneracy -/

/-- Three points are collinear if some line contains all three. -/
def Quasifield.Collinear (F : Quasifield Q) (p q r : Q × Q) : Prop :=
  ∃ L, F.onLine p L ∧ F.onLine q L ∧ F.onLine r L

/-
**Non-degeneracy witness.**  The four points `(0,0)`, `(1,0)`, `(0,1)`,
`(1,1)` form a quadrangle: no three are collinear.  This guarantees the plane is
not a degenerate (near-pencil) configuration.
-/
theorem Quasifield.exists_four_general_position (F : Quasifield Q) :
    ∃ a b c d : Q × Q,
      ¬ F.Collinear a b c ∧ ¬ F.Collinear a b d ∧
      ¬ F.Collinear a c d ∧ ¬ F.Collinear b c d := by
  -- Take the four points a := ((0:Q),(0:Q)), b := (F.one, 0), c := (0, F.one), d := (F.one, F.one).
  set a : Q × Q := (0, 0)
  set b : Q × Q := (F.one, 0)
  set c : Q × Q := (0, F.one)
  set d : Q × Q := (F.one, F.one);
  refine' ⟨ a, b, c, d, _, _, _, _ ⟩ <;> simp +decide [ Quasifield.Collinear ];
  · rintro ( _ | _ ) <;> simp +decide [ a, b, c ]; all_goals grind +suggestions;
  · rintro ( L | L ) <;> simp_all +decide [ Quasifield.onLine ]; all_goals grind +suggestions;
  · rintro ( _ | _ ) <;> simp +decide [ a, c, d, Quasifield.onLine ]; all_goals grind +suggestions;
  · intro L hL₁ hL₂ hL₃; rcases L with ( _ | _ ) <;> simp_all +decide ;
    · grind +suggestions;
    · exact F.one_ne_zero ( by aesop )

/-! ## Division rings are quasifields -/

/-- Every division ring is a quasifield under its own operations. -/
noncomputable def DivisionRing.toQuasifield (D : Type*) [DivisionRing D] :
    Quasifield D where
  one := 1
  mul := (· * ·)
  one_ne_zero := one_ne_zero
  mul_one := mul_one
  one_mul := one_mul
  mul_zero := mul_zero
  zero_mul := zero_mul
  right_distrib := add_mul
  left_div := by
    intro a ha c
    refine ⟨a⁻¹ * c, ?_, ?_⟩
    · show a * (a⁻¹ * c) = c
      rw [← mul_assoc, mul_inv_cancel₀ ha, one_mul]
    · intro y hy
      have hy' : a * y = c := hy
      rw [← hy', ← mul_assoc, inv_mul_cancel₀ ha, one_mul]
  right_div := by
    intro a ha c
    refine ⟨c * a⁻¹, ?_, ?_⟩
    · show c * a⁻¹ * a = c
      rw [mul_assoc, inv_mul_cancel₀ ha, mul_one]
    · intro y hy
      have hy' : y * a = c := hy
      rw [← hy', mul_assoc, mul_inv_cancel₀ ha, mul_one]
  planar := by
    intro a b hab d
    have hab' : a - b ≠ 0 := sub_ne_zero.mpr hab
    refine ⟨d * (a - b)⁻¹, ?_, ?_⟩
    · show d * (a - b)⁻¹ * a = d * (a - b)⁻¹ * b + d
      have : d * (a - b)⁻¹ * a - d * (a - b)⁻¹ * b = d := by
        rw [← mul_sub, mul_assoc, inv_mul_cancel₀ hab', mul_one]
      rw [sub_eq_iff_eq_add] at this
      rw [this, add_comm]
    · intro y hy
      have hy' : y * a = y * b + d := hy
      have : y * (a - b) = d := by rw [mul_sub]; rw [hy']; abel
      rw [← this, mul_assoc, mul_inv_cancel₀ hab', mul_one]

/-- The multiplication of a quasifield is *associative*. -/
def Quasifield.IsAssociative (F : Quasifield Q) : Prop :=
  ∀ a b c, F.mul (F.mul a b) c = F.mul a (F.mul b c)

/-- The multiplication of a quasifield is *left distributive*. -/
def Quasifield.IsLeftDistrib (F : Quasifield Q) : Prop :=
  ∀ a b c, F.mul a (b + c) = F.mul a b + F.mul a c

/-- The multiplication of a quasifield is *commutative*. -/
def Quasifield.IsCommutative (F : Quasifield Q) : Prop :=
  ∀ a b, F.mul a b = F.mul b a

/-- A division ring's quasifield is associative. -/
theorem DivisionRing.toQuasifield_isAssociative (D : Type*) [DivisionRing D] :
    (DivisionRing.toQuasifield D).IsAssociative := fun a b c => (mul_assoc a b c)

/-- A division ring's quasifield is left distributive. -/
theorem DivisionRing.toQuasifield_isLeftDistrib (D : Type*) [DivisionRing D] :
    (DivisionRing.toQuasifield D).IsLeftDistrib := fun a b c => mul_add a b c

end QuasifieldPlane