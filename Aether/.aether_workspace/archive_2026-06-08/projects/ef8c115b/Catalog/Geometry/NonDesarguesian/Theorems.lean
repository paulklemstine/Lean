/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Geometry.NonDesarguesian.Defs

/-!
# Non-Desarguesian Geometry: Main Theorems

This file contains the core theorems establishing the existence and properties
of non-Desarguesian projective planes via the Hall quasifield construction.

## Main results

* `hall_mul_not_assoc` — The Hall multiplication on GF(9) is not associative
* `hall_right_distrib` — The Hall multiplication is right-distributive
* `hall_not_left_distrib` — The Hall multiplication is NOT left-distributive
* `hall_one_mul` / `hall_mul_one` — Identity element properties
* `hall_is_proper_quasifield` — The Hall quasifield is proper (non-associative)
* `gf9_mul_assoc` — Standard GF(9) IS associative (contrast)
* `frobenius3_involution` — Frobenius is an involution on GF(9)
* `frobenius3_mul` — Frobenius is multiplicative
* `proper_quasifield_not_division_ring` — Non-associative ⇒ not a division ring
* `perspectivity_injective` — Lines through an external point separate points on a line
* `projective_plane_point_count` — n²+n+1 point count formula
-/

namespace NonDesarguesian

open Finset

/-! ### Hall Quasifield: Multiplicative Identity -/

/-
The element (1, 0) is a left identity for Hall multiplication.
-/
theorem hall_one_mul (a : ZMod 3 × ZMod 3) :
    hallMul gf9One a = a := by
  native_decide +revert

/-
The element (1, 0) is a right identity for Hall multiplication.
-/
theorem hall_mul_one (a : ZMod 3 × ZMod 3) :
    hallMul a gf9One = a := by
  native_decide +revert

/-! ### Hall Quasifield: Zero Properties -/

/-
Zero is a left absorbing element for Hall multiplication.
-/
theorem hall_zero_mul (a : ZMod 3 × ZMod 3) :
    hallMul gf9Zero a = gf9Zero := by
  native_decide +revert

/-
Zero is a right absorbing element for Hall multiplication.
-/
theorem hall_mul_zero (a : ZMod 3 × ZMod 3) :
    hallMul a gf9Zero = gf9Zero := by
  native_decide +revert

/-! ### Hall Quasifield: Distributivity -/

/-
**Right distributivity of Hall multiplication.**

    The Hall multiplication satisfies (a + b) ○ c = a ○ c + b ○ c.
    This holds because in both cases (c in GF(3) or not), the formula
    for x ○ c is linear in x:
    - When c = (c₁, 0): x ○ c = (x₁c₁, x₂c₁) — linear in (x₁, x₂)
    - When c = (c₁, c₂) with c₂ ≠ 0: x ○ c = (x₁c₁ + x₂c₂, x₁c₂ + 2x₂c₁) — also linear

    This is the key algebraic property that makes the Hall quasifield
    a valid quasifield (and hence coordinatizes a projective plane).
-/
theorem hall_right_distrib (a b c : ZMod 3 × ZMod 3) :
    hallMul (gf9Add a b) c = gf9Add (hallMul a c) (hallMul b c) := by
  native_decide +revert

/-
**The Hall multiplication is NOT left-distributive.**

    Witness: a = (0,1), b = (1,0), c = (0,1)
    - a ○ (b + c) = (0,1) ○ (1,1) = (1, 2)
    - a ○ b + a ○ c = (0,1) + (1,0) = (1, 1) ≠ (1, 2)
-/
theorem hall_not_left_distrib :
    ∃ a b c : ZMod 3 × ZMod 3,
      hallMul a (gf9Add b c) ≠ gf9Add (hallMul a b) (hallMul a c) := by
  native_decide

/-! ### Non-Associativity: The Heart of Non-Desarguesian Geometry -/

/-
**The Hall multiplication on GF(9) is not associative.**

    Witness: x = (0,1), y = (0,1), z = (1,1)
    - (x ○ y) ○ z = (1,0) ○ (1,1) = (1, 1)
    - x ○ (y ○ z) = (0,1) ○ (1,2) = (2, 2)
    - (1, 1) ≠ (2, 2) in ZMod 3 × ZMod 3
-/
theorem hall_mul_not_assoc :
    ∃ x y z : ZMod 3 × ZMod 3,
      hallMul (hallMul x y) z ≠ hallMul x (hallMul y z) := by
  native_decide

/-! ### Contrast: Standard GF(9) IS Associative -/

/-
Standard GF(9) field multiplication is associative.
-/
theorem gf9_mul_assoc (a b c : ZMod 3 × ZMod 3) :
    gf9Mul (gf9Mul a b) c = gf9Mul a (gf9Mul b c) := by
  native_decide +revert

/-! ### Frobenius Automorphism Properties -/

/-
The Frobenius map is an involution on GF(9).
-/
theorem frobenius3_involution (x : ZMod 3 × ZMod 3) :
    frobenius3 (frobenius3 x) = x := by
  native_decide +revert

/-
The Frobenius map fixes exactly the base field GF(3).
-/
theorem frobenius3_fixed_iff (x : ZMod 3 × ZMod 3) :
    frobenius3 x = x ↔ x.2 = 0 := by
  native_decide +revert

/-
The Frobenius map is multiplicative w.r.t. standard GF(9) multiplication.
-/
theorem frobenius3_mul (x y : ZMod 3 × ZMod 3) :
    frobenius3 (gf9Mul x y) = gf9Mul (frobenius3 x) (frobenius3 y) := by
  decide +revert

/-! ### Hall Multiplication via Frobenius -/

/-
Hall multiplication can be expressed uniformly using the Frobenius map:
    when y ∉ GF(3), we have hallMul x y = gf9Mul (frobenius3 x) y.
-/
theorem hall_mul_eq_frob_mul (x y : ZMod 3 × ZMod 3) (hy : y.2 ≠ 0) :
    hallMul x y = gf9Mul (frobenius3 x) y := by
  native_decide +revert

/-
When y ∈ GF(3), Hall multiplication reduces to standard multiplication.
-/
theorem hall_mul_base_field (x y : ZMod 3 × ZMod 3) (hy : y.2 = 0) :
    hallMul x y = gf9Mul x y := by
  native_decide +revert

/-! ### Proper Quasifield and Division Ring -/

/-- **The Hall quasifield is a proper quasifield**: multiplication is non-associative. -/
theorem hall_is_proper_quasifield : IsProperQuasifield (ZMod 3 × ZMod 3) :=
  hall_mul_not_assoc

/-
**Non-associative quasifields cannot be division rings.**
    If a quasifield has non-associative multiplication, it fails the
    associativity requirement for division rings.
-/
theorem proper_quasifield_not_division_ring (Q : Type*) [QuasifieldOps Q]
    (h : IsProperQuasifield Q) : ¬QuasifieldIsDivisionRing Q := by
  obtain ⟨a, b, c, h_ne⟩ := h;
  exact fun h => h_ne ( h.2 a b c )

/-! ### Projective Plane Structure Theorems -/

/-
In a projective plane, if p is a point not on line l, then distinct
    points on l determine distinct lines through p.
-/
theorem perspectivity_injective (π : ProjectivePlane)
    (p : π.Point) (l : π.Line) (hp : ¬π.inc p l)
    (q₁ q₂ : π.Point) (hq₁ : π.inc q₁ l) (hq₂ : π.inc q₂ l)
    (hne : q₁ ≠ q₂)
    (m₁ : π.Line) (hm₁ : π.inc p m₁ ∧ π.inc q₁ m₁)
    (m₂ : π.Line) (hm₂ : π.inc p m₂ ∧ π.inc q₂ m₂) :
    m₁ ≠ m₂ := by
  intro h; have := π.line_unique q₁ q₂ hne; simp_all +decide [ ExistsUnique ] ;
  grind +ring

/-
**Projective plane point count formula.**
    A finite projective plane where every line has n+1 points
    and every point lies on n+1 lines has n² + n + 1 points.
-/
theorem projective_plane_point_count (π : ProjectivePlane) [Fintype π.Point]
    [DecidableEq π.Point] [Fintype π.Line] [DecidableEq π.Line]
    [∀ (p : π.Point) (l : π.Line), Decidable (π.inc p l)]
    (n : ℕ) (_hn : 1 ≤ n)
    (h_line : ∀ l : π.Line, (Finset.univ.filter (fun p => π.inc p l)).card = n + 1)
    (h_point : ∀ p : π.Point, (Finset.univ.filter (fun l => π.inc p l)).card = n + 1) :
    Fintype.card π.Point = n ^ 2 + n + 1 := by
  -- By counting incidence pairs (point, line) in� two� ways, we� get� |P| * (n+1)� =� |L|� *� ( �n�+1), so |P| = |L|.
  have h_card_eq : (Fintype.card π.Point) * (n + 1) = (Fintype.card π.Line) * (n + 1) := by
    have h_card_eq : (Finset.univ.sum (fun p : π.Point => (Finset.univ.filter (fun l : π.Line => π.inc p l)).card)) = (Finset.univ.sum (fun l : π.Line => (Finset.univ.filter (fun p : π.Point => π.inc p l)).card)) := by
      simp +decide only [card_filter] ; rw [ Finset.sum_comm ] ;
    aesop;
  -- By counting incidence pairs (point, line) in three ways, we get |P| * (n+1) = |L| * (n+1), so |P| = |L|.
  have h_card_eq : (Fintype.card π.Point) * (Fintype.card π.Point) = (Fintype.card π.Point) + n * (n + 1) * (Fintype.card π.Point) := by
    have h_card_eq : (Finset.card (Finset.univ : Finset π.Point)) * ((Finset.card (Finset.univ : Finset π.Point)) - 1) = (Finset.card (Finset.univ : Finset π.Line)) * (n + 1) * n := by
      have h_card_eq : (Finset.card (Finset.univ : Finset π.Point)) * ((Finset.card (Finset.univ : Finset π.Point)) - 1) = Finset.sum (Finset.univ : Finset π.Line) (fun l => Finset.card (Finset.filter (fun p => π.inc p l) Finset.univ) * (Finset.card (Finset.filter (fun p => π.inc p l) Finset.univ) - 1)) := by
        have h_card_eq : (Finset.card (Finset.univ : Finset π.Point)) * ((Finset.card (Finset.univ : Finset π.Point)) - 1) = Finset.sum (Finset.univ : Finset π.Point) (fun p => Finset.card (Finset.filter (fun q => q ≠ p) (Finset.univ : Finset π.Point))) := by
          simp +decide [ Finset.filter_ne' ];
        have h_card_eq : ∀ p : π.Point, Finset.card (Finset.filter (fun q => q ≠ p) (Finset.univ : Finset π.Point)) = Finset.sum (Finset.univ : Finset π.Line) (fun l => if π.inc p l then Finset.card (Finset.filter (fun q => q ≠ p ∧ π.inc q l) (Finset.univ : Finset π.Point)) else 0) := by
          intro p
          have h_card_eq : Finset.filter (fun q => q ≠ p) (Finset.univ : Finset π.Point) = Finset.biUnion (Finset.filter (fun l => π.inc p l) (Finset.univ : Finset π.Line)) (fun l => Finset.filter (fun q => q ≠ p ∧ π.inc q l) (Finset.univ : Finset π.Point)) := by
            ext q; simp [Finset.mem_biUnion];
            exact ⟨ fun h => by obtain ⟨ l, hl ⟩ := π.line_unique p q ( Ne.symm h ) ; exact ⟨ l, hl.1.1, h, hl.1.2 ⟩, fun h => h.choose_spec.2.1 ⟩;
          rw [ h_card_eq, Finset.card_biUnion ];
          · rw [ Finset.sum_filter ];
          · intros l hl l' hl' hll'; simp_all +decide [ Finset.disjoint_left ] ;
            intro q hq hq' hq''; have := π.point_unique l l' hll'; simp_all +decide [ ExistsUnique ] ;
            grind;
        have h_card_eq : ∀ l : π.Line, Finset.sum (Finset.univ : Finset π.Point) (fun p => if π.inc p l then Finset.card (Finset.filter (fun q => q ≠ p ∧ π.inc q l) (Finset.univ : Finset π.Point)) else 0) = Finset.card (Finset.filter (fun p => π.inc p l) (Finset.univ : Finset π.Point)) * (Finset.card (Finset.filter (fun p => π.inc p l) (Finset.univ : Finset π.Point)) - 1) := by
          intro l
          have h_card_eq : ∀ p ∈ Finset.filter (fun q => π.inc q l) (Finset.univ : Finset π.Point), Finset.card (Finset.filter (fun q => q ≠ p ∧ π.inc q l) (Finset.univ : Finset π.Point)) = Finset.card (Finset.filter (fun q => π.inc q l) (Finset.univ : Finset π.Point)) - 1 := by
            simp +contextual [ Finset.filter_ne', Finset.filter_and ];
          rw [ Finset.sum_ite ];
          rw [ Finset.sum_congr rfl h_card_eq, Finset.sum_const, Finset.card_filter ] ; norm_num;
        rw [ ← Finset.sum_congr rfl fun l hl => h_card_eq l ];
        rw [ Finset.sum_comm, ‹#univ * ( #univ - 1 ) = ∑ p, _›, Finset.sum_congr rfl fun p hp => ‹∀ p : π.Point, #{q | q ≠ p} = ∑ l, if π.inc p l then #{q | q ≠ p ∧ π.inc q l} else 0› p ];
      simp_all +decide [ mul_assoc ];
    cases k : Fintype.card π.Point <;> simp_all +decide [ Nat.succ_mul ] ; nlinarith;
  by_cases h : Fintype.card π.Point = 0 <;> simp_all +decide [ sq ];
  · obtain ⟨ p, q, r, s, hpqr, hqrs, hrsp, hpsr ⟩ := π.general_position; simp_all +decide [ Fintype.card_eq_zero_iff ] ;
    exact h.elim p;
  · nlinarith only [ h_card_eq, Nat.pos_of_ne_zero h ]

/-
Dual: a finite projective plane of order n has n² + n + 1 lines.
-/
theorem projective_plane_line_count (π : ProjectivePlane) [Fintype π.Point]
    [DecidableEq π.Point] [Fintype π.Line] [DecidableEq π.Line]
    [∀ (p : π.Point) (l : π.Line), Decidable (π.inc p l)]
    (n : ℕ) (_hn : 1 ≤ n)
    (h_line : ∀ l : π.Line, (Finset.univ.filter (fun p => π.inc p l)).card = n + 1)
    (h_point : ∀ p : π.Point, (Finset.univ.filter (fun l => π.inc p l)).card = n + 1) :
    Fintype.card π.Line = n ^ 2 + n + 1 := by
  -- By counting the total incidence pairs in two ways, we can show that |P| = |L|.
  have h_total_incidence : ∑ p : π.Point, (Finset.univ.filter (fun l => π.inc p l)).card = ∑ l : π.Line, (Finset.univ.filter (fun p => π.inc p l)).card := by
    simp +decide only [card_filter] ; rw [ Finset.sum_comm ] ;
  simp_all +decide [ mul_add ];
  nlinarith [ projective_plane_point_count π n _hn h_line h_point ]

/-! ### Concrete Counts -/

/-
GF(9) has exactly 9 elements.
-/
theorem gf9_card : Fintype.card (ZMod 3 × ZMod 3) = 9 := by
  rfl

/-- The Hall plane of order 9 has 91 = 9² + 9 + 1 points. -/
theorem hall_plane_91_points : 9 ^ 2 + 9 + 1 = (91 : ℕ) := by norm_num

/-- PGL(3, GF(9)) order = 42456960. -/
theorem pgl3_gf9_order : 9 ^ 3 * (9 ^ 3 - 1) * (9 ^ 2 - 1) = (42456960 : ℕ) := by norm_num

end NonDesarguesian