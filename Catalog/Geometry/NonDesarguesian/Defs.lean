/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Non-Desarguesian Geometry: Core Definitions

This file introduces the algebraic and geometric structures needed to study
non-Desarguesian projective planes:

1. **ProjectivePlane**: Abstract incidence axioms for a projective plane
2. **DesarguesConfig**: The Desargues configuration (two perspective triangles)
3. **Quasifield**: The algebraic structure coordinatizing translation planes
4. **Hall multiplication**: The concrete non-associative multiplication on GF(9)
   that gives rise to the Hall plane, the smallest non-Desarguesian projective plane

## Main definitions

* `NonDesarguesian.ProjectivePlane` — incidence structure satisfying projective plane axioms
* `NonDesarguesian.DesarguesConfig` — a Desargues configuration in a projective plane
* `NonDesarguesian.hallMul` — Hall multiplication on `ZMod 3 × ZMod 3`
* `NonDesarguesian.gf9Mul` — Standard field multiplication on GF(9) for comparison
* `NonDesarguesian.frobenius3` — Frobenius automorphism on GF(9)

## References

* Hall, Marshall. "Projective planes." Trans. Amer. Math. Soc. 54 (1943): 229-277.
* Hughes, Daniel R., and Fred C. Piper. "Projective planes." Springer, 1973.
-/

namespace NonDesarguesian

/-! ### Projective Plane Axioms -/

/-- A projective plane is an incidence structure `(Point, Line, inc)` satisfying:
    1. Any two distinct points lie on a unique line
    2. Any two distinct lines meet in a unique point
    3. There exist four points in general position (no three collinear) -/
structure ProjectivePlane where
  Point : Type*
  Line : Type*
  inc : Point → Line → Prop
  /-- Two distinct points determine a unique line -/
  line_unique : ∀ (p q : Point), p ≠ q → ∃! l : Line, inc p l ∧ inc q l
  /-- Two distinct lines meet in a unique point -/
  point_unique : ∀ (l m : Line), l ≠ m → ∃! p : Point, inc p l ∧ inc p m
  /-- Non-degeneracy: four points in general position -/
  general_position : ∃ (a b c d : Point),
    (∀ l : Line, ¬(inc a l ∧ inc b l ∧ inc c l)) ∧
    (∀ l : Line, ¬(inc a l ∧ inc b l ∧ inc d l)) ∧
    (∀ l : Line, ¬(inc a l ∧ inc c l ∧ inc d l)) ∧
    (∀ l : Line, ¬(inc b l ∧ inc c l ∧ inc d l))

/-- The order of a finite projective plane is one less than the number of
    points on any line. For a plane of order n, each line contains n+1 points. -/
noncomputable def ProjectivePlane.order (π : ProjectivePlane) [Fintype π.Point]
    [DecidableEq π.Point] [∀ (p : π.Point) (l : π.Line), Decidable (π.inc p l)]
    (l : π.Line) : ℕ :=
  (Finset.univ.filter (fun p => π.inc p l)).card - 1

/-! ### Desargues Configuration -/

/-- A Desargues configuration consists of:
    - A center of perspectivity O
    - Two triangles ABC and A'B'C'
    - The triangles are perspective from O (OA meets OA', etc.)
    - The conclusion: the intersections of corresponding sides are collinear

    The Desargues theorem states that if two triangles are perspective from
    a point, then they are perspective from a line. This holds in every
    projective plane coordinatized by a division ring, but can fail in
    planes coordinatized by proper quasifields. -/
structure DesarguesConfig (π : ProjectivePlane) where
  /-- Center of perspectivity -/
  O : π.Point
  /-- First triangle -/
  A : π.Point
  B : π.Point
  C : π.Point
  /-- Second triangle -/
  A' : π.Point
  B' : π.Point
  C' : π.Point
  /-- Lines through O and corresponding vertices -/
  lOA : π.Line
  lOB : π.Line
  lOC : π.Line
  /-- O, A, A' are collinear -/
  O_A_collinear : π.inc O lOA ∧ π.inc A lOA ∧ π.inc A' lOA
  /-- O, B, B' are collinear -/
  O_B_collinear : π.inc O lOB ∧ π.inc B lOB ∧ π.inc B' lOB
  /-- O, C, C' are collinear -/
  O_C_collinear : π.inc O lOC ∧ π.inc C lOC ∧ π.inc C' lOC
  /-- The six triangle vertices are distinct from O and from each other -/
  distinct : A ≠ B ∧ A ≠ C ∧ B ≠ C ∧ A' ≠ B' ∧ A' ≠ C' ∧ B' ≠ C' ∧
    O ≠ A ∧ O ≠ B ∧ O ≠ C ∧ O ≠ A' ∧ O ≠ B' ∧ O ≠ C'

/-- The Desargues property: In every Desargues configuration, the three
    intersection points of corresponding sides are collinear.
    A projective plane satisfies this iff it can be coordinatized by a
    division ring (Hilbert's theorem). -/
def ProjectivePlane.DesarguesProperty (π : ProjectivePlane) : Prop :=
  ∀ (cfg : DesarguesConfig π)
    (lAB lA'B' lAC lA'C' lBC lB'C' : π.Line),
    -- Sides of first triangle
    (π.inc cfg.A lAB ∧ π.inc cfg.B lAB) →
    (π.inc cfg.A lAC ∧ π.inc cfg.C lAC) →
    (π.inc cfg.B lBC ∧ π.inc cfg.C lBC) →
    -- Sides of second triangle
    (π.inc cfg.A' lA'B' ∧ π.inc cfg.B' lA'B') →
    (π.inc cfg.A' lA'C' ∧ π.inc cfg.C' lA'C') →
    (π.inc cfg.B' lB'C' ∧ π.inc cfg.C' lB'C') →
    -- Corresponding sides meet
    lAB ≠ lA'B' → lAC ≠ lA'C' → lBC ≠ lB'C' →
    -- Conclusion: intersection points are collinear
    ∃ (P Q R : π.Point) (m : π.Line),
      (π.inc P lAB ∧ π.inc P lA'B') ∧
      (π.inc Q lAC ∧ π.inc Q lA'C') ∧
      (π.inc R lBC ∧ π.inc R lB'C') ∧
      (π.inc P m ∧ π.inc Q m ∧ π.inc R m)

/-- A non-Desarguesian projective plane is one where the Desargues property fails. -/
def ProjectivePlane.IsNonDesarguesian (π : ProjectivePlane) : Prop :=
  ¬π.DesarguesProperty

/-! ### GF(9) Arithmetic

We represent GF(9) = GF(3)[α]/(α² + 1) as pairs (a, b) ∈ ZMod 3 × ZMod 3,
where (a, b) represents the element a + bα with α² = -1 = 2 (mod 3). -/

/-- Standard field multiplication in GF(9) = GF(3)[α]/(α²+1).
    (a + bα)(c + dα) = (ac + 2bd) + (ad + bc)α
    where α² = -1 = 2 in ZMod 3. -/
def gf9Mul (x y : ZMod 3 × ZMod 3) : ZMod 3 × ZMod 3 :=
  (x.1 * y.1 + 2 * x.2 * y.2, x.1 * y.2 + x.2 * y.1)

/-- The Frobenius automorphism on GF(9): σ(a + bα) = a + bα³ = a + 2bα.
    In characteristic 3, this is x ↦ x³. -/
def frobenius3 (x : ZMod 3 × ZMod 3) : ZMod 3 × ZMod 3 :=
  (x.1, 2 * x.2)

/-- Hall multiplication on GF(9) = GF(3)[α]/(α²+1).

    The Hall quasifield modifies field multiplication by applying the
    Frobenius automorphism to the left factor when the right factor
    is not in the base field GF(3):

    x ○ y = x · y           if y ∈ GF(3) (i.e., y.2 = 0)
    x ○ y = σ(x) · y        if y ∉ GF(3) (i.e., y.2 ≠ 0)

    Expanding:
    d = 0: (ac, bc)
    d ≠ 0: (ac + bd, ad + 2bc)

    This multiplication is right-distributive but NOT associative,
    yielding a proper quasifield that coordinatizes the Hall plane
    of order 9 — the smallest non-Desarguesian projective plane. -/
def hallMul (x y : ZMod 3 × ZMod 3) : ZMod 3 × ZMod 3 :=
  if y.2 = 0 then
    (x.1 * y.1, x.2 * y.1)
  else
    (x.1 * y.1 + x.2 * y.2, x.1 * y.2 + 2 * x.2 * y.1)

/-- Component-wise addition on GF(9), which is the same as the standard
    field addition. -/
def gf9Add (x y : ZMod 3 × ZMod 3) : ZMod 3 × ZMod 3 :=
  (x.1 + y.1, x.2 + y.2)

/-- The zero element of GF(9). -/
def gf9Zero : ZMod 3 × ZMod 3 := (0, 0)

/-- The multiplicative identity in both GF(9) and the Hall quasifield. -/
def gf9One : ZMod 3 × ZMod 3 := (1, 0)

/-- An element of GF(9) is in the base field GF(3) iff its second
    component is zero. -/
def isInBaseField (x : ZMod 3 × ZMod 3) : Prop := x.2 = 0

instance : DecidablePred isInBaseField :=
  fun x => inferInstanceAs (Decidable (x.2 = 0))

/-! ### Quasifield Structure -/

/-- A quasifield is an algebraic structure (Q, +, ○) generalizing division rings:
    - (Q, +) is an abelian group with identity 0
    - 1 ○ a = a and a ○ 1 = a
    - Right distributivity: (a + b) ○ c = a ○ c + b ○ c
    - For each a ≠ 0 and b, the equation x ○ a = b has a unique solution
    - 0 ○ a = 0 and a ○ 0 = 0

    Every division ring is a quasifield, but not conversely. A projective plane
    can be coordinatized by a quasifield iff it is a translation plane.
    The plane is Desarguesian iff the quasifield is actually a division ring
    (i.e., both distributive laws and associativity hold). -/
class QuasifieldOps (Q : Type*) where
  qadd : Q → Q → Q
  qmul : Q → Q → Q
  qzero : Q
  qone : Q
  qneg : Q → Q

class IsQuasifield (Q : Type*) [QuasifieldOps Q] : Prop where
  add_assoc : ∀ a b c : Q, QuasifieldOps.qadd (QuasifieldOps.qadd a b) c =
    QuasifieldOps.qadd a (QuasifieldOps.qadd b c)
  add_comm : ∀ a b : Q, QuasifieldOps.qadd a b = QuasifieldOps.qadd b a
  zero_add : ∀ a : Q, QuasifieldOps.qadd QuasifieldOps.qzero a = a
  add_left_neg : ∀ a : Q, QuasifieldOps.qadd (QuasifieldOps.qneg a) a = QuasifieldOps.qzero
  one_mul : ∀ a : Q, QuasifieldOps.qmul QuasifieldOps.qone a = a
  mul_one : ∀ a : Q, QuasifieldOps.qmul a QuasifieldOps.qone = a
  right_distrib : ∀ a b c : Q,
    QuasifieldOps.qmul (QuasifieldOps.qadd a b) c =
    QuasifieldOps.qadd (QuasifieldOps.qmul a c) (QuasifieldOps.qmul b c)
  zero_mul : ∀ a : Q, QuasifieldOps.qmul QuasifieldOps.qzero a = QuasifieldOps.qzero
  mul_zero : ∀ a : Q, QuasifieldOps.qmul a QuasifieldOps.qzero = QuasifieldOps.qzero
  one_ne_zero : QuasifieldOps.qone ≠ (QuasifieldOps.qzero : Q)

/-- A quasifield is **proper** (non-associative) if multiplication fails
    to be associative. This is the algebraic hallmark of non-Desarguesian planes. -/
def IsProperQuasifield (Q : Type*) [QuasifieldOps Q] : Prop :=
  ∃ a b c : Q, QuasifieldOps.qmul (QuasifieldOps.qmul a b) c ≠
    QuasifieldOps.qmul a (QuasifieldOps.qmul b c)

/-- A quasifield that also satisfies left distributivity and associativity
    is a division ring. This is the algebraic characterization of
    Desarguesian planes. -/
def QuasifieldIsDivisionRing (Q : Type*) [QuasifieldOps Q] : Prop :=
  (∀ a b c : Q, QuasifieldOps.qmul a (QuasifieldOps.qadd b c) =
    QuasifieldOps.qadd (QuasifieldOps.qmul a b) (QuasifieldOps.qmul a c)) ∧
  (∀ a b c : Q, QuasifieldOps.qmul (QuasifieldOps.qmul a b) c =
    QuasifieldOps.qmul a (QuasifieldOps.qmul b c))

/-! ### Hall Quasifield Operations Instance -/

/-- QuasifieldOps instance for the Hall quasifield on ZMod 3 × ZMod 3. -/
instance hallQuasifieldOps : QuasifieldOps (ZMod 3 × ZMod 3) where
  qadd := gf9Add
  qmul := hallMul
  qzero := gf9Zero
  qone := gf9One
  qneg := fun x => (-(x.1), -(x.2))

/-! ### Collineation Groups -/

/-- A collineation of a projective plane is an automorphism: a pair of
    bijections on points and lines preserving incidence. -/
structure Collineation (π : ProjectivePlane) where
  pointMap : π.Point → π.Point
  lineMap : π.Line → π.Line
  pointMap_injective : Function.Injective pointMap
  pointMap_surjective : Function.Surjective pointMap
  lineMap_injective : Function.Injective lineMap
  lineMap_surjective : Function.Surjective lineMap
  preserves_inc : ∀ p l, π.inc p l ↔ π.inc (pointMap p) (lineMap l)

/-- The collineation group of a non-Desarguesian plane is strictly smaller
    than PGL(3, q) acting on the Desarguesian plane of the same order.
    We express this as: the order of the collineation group divides the
    order of PGL, with strict inequality. -/
def collineationGroupSmaller (π : ProjectivePlane) [Fintype π.Point]
    [DecidableEq π.Point] [Fintype π.Line] [DecidableEq π.Line]
    (_n : ℕ) (numCollins : ℕ)
    (pgl_order : ℕ) : Prop :=
  π.IsNonDesarguesian → numCollins < pgl_order

end NonDesarguesian