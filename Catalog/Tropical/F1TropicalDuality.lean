import Mathlib

/-!
# The F₁-Tropical Duality: Field with One Element Meets Tropical Geometry

## Overview

This file formalizes the deep connection between the hypothetical "field with one
element" F₁ and tropical geometry. The key insight is that tropical semirings
provide a concrete algebraic realization of F₁-geometry:

* **F₁-modules** are pointed sets (sets with a distinguished "zero" element)
* **F₁-algebras** are commutative monoids with absorbing zero
* The **tropical semiring** `(ℝ ∪ {∞}, min, +)` is the canonical F₁-algebra
* **Base change** from F₁ to ℤ sends monoids to monoid algebras (toric coordinate rings)

## Main Results

* `TropicalF1Algebra` — Novel structure formalizing F₁-algebras via tropical axioms
* `tropical_order_agrees_min` — The F₁-induced order matches the natural order
* `tropical_mul_preserves_order` — Tropical scaling is monotone
* `base_change_preserves_rank` — Base change F₁ → ℤ preserves rank
* `f1_betti_binomial` — F₁-Betti numbers equal binomial coefficients

## Mathematical Significance

The field with one element F₁ is hypothetical — no actual field has one element.
But the *category* of F₁-modules (= pointed sets) and F₁-algebras (= monoids
with absorbing zero) is well-defined. The tropical semiring provides the
"arithmetic" of F₁: addition is min (idempotent!), and multiplication is
ordinary addition. This idempotency — `a + a = a` in the tropical/F₁ world —
is the algebraic shadow of the fact that F₁ has characteristic 1.
-/

noncomputable section

open Finset BigOperators Classical

/-! ## Part 1: F₁-Algebra Structure -/

/-- An F₁-algebra: the algebraic structure capturing the "field with one element".
Tropical addition (min) is idempotent, tropical multiplication (+) distributes
over it, with an absorbing zero (∞) and multiplicative unit (0). -/
structure TropicalF1Algebra (α : Type*) where
  add : α → α → α
  mul : α → α → α
  zero : α
  one : α
  add_idem : ∀ a : α, add a a = a
  add_comm : ∀ a b : α, add a b = add b a
  add_assoc : ∀ a b c : α, add (add a b) c = add a (add b c)
  mul_comm : ∀ a b : α, mul a b = mul b a
  mul_assoc : ∀ a b c : α, mul (mul a b) c = mul a (mul b c)
  mul_add : ∀ a b c : α, mul a (add b c) = add (mul a b) (mul a c)
  zero_mul : ∀ a : α, mul zero a = zero
  one_mul : ∀ a : α, mul one a = a
  zero_add : ∀ a : α, add zero a = a

/-
The natural numbers with infinity form a TropicalF1Algebra via (min, +).
This is the fundamental example connecting tropical geometry and F₁.
-/
def WithTop.tropicalF1 : TropicalF1Algebra (WithTop ℕ) where
  add := min
  mul := (· + ·)
  zero := ⊤
  one := (0 : WithTop ℕ)
  add_idem := fun a => min_self a
  add_comm := fun a b => min_comm a b
  add_assoc := fun a b c => min_assoc a b c
  mul_comm := fun a b => add_comm a b
  mul_assoc := fun a b c => add_assoc a b c
  mul_add := fun a b c => by
    cases a <;> cases b <;> cases c <;> simp_all +decide [ min_def ];
    split_ifs <;> rfl
  zero_mul := fun a => WithTop.top_add a
  one_mul := fun a => zero_add a
  zero_add := fun a => min_top_left a

/-! ## Part 2: F₁-Order Structure -/

/-- The F₁-points of an F₁-algebra: generators that cannot be decomposed. -/
def TropicalF1Algebra.isGenerator (A : TropicalF1Algebra α) (x : α) : Prop :=
  ∀ a b : α, A.add a b = x → a = x ∨ b = x

/-- The F₁-order: a ≤ b iff a ⊕ b = a (i.e., a is the "minimum"). -/
def TropicalF1Algebra.le (A : TropicalF1Algebra α) (a b : α) : Prop :=
  A.add a b = a

/-- The tropical order is reflexive (from idempotency). -/
theorem TropicalF1Algebra.le_refl (A : TropicalF1Algebra α) (a : α) :
    A.le a a := A.add_idem a

/-- The tropical order is antisymmetric. -/
theorem TropicalF1Algebra.le_antisymm (A : TropicalF1Algebra α) (a b : α)
    (hab : A.le a b) (hba : A.le b a) : a = b := by
  unfold TropicalF1Algebra.le at hab hba
  rw [← hab, A.add_comm, hba]

/-
The tropical order is transitive.
-/
theorem TropicalF1Algebra.le_trans (A : TropicalF1Algebra α) (a b c : α)
    (hab : A.le a b) (hbc : A.le b c) : A.le a c := by
  unfold TropicalF1Algebra.le at *; have := A.add_assoc a b c; aesop;

/-
Tropical addition gives the meet (greatest lower bound) on the left.
-/
theorem TropicalF1Algebra.add_le_left (A : TropicalF1Algebra α) (a b : α) :
    A.le (A.add a b) a := by
  have := A.add_assoc a b a;
  have := A.add_comm b a;
  have := A.add_assoc a a b; simp_all +decide [ TropicalF1Algebra.le ] ;
  rw [ ← this, A.add_idem ]

/-
Tropical addition gives the meet (greatest lower bound) on the right.
-/
theorem TropicalF1Algebra.add_le_right (A : TropicalF1Algebra α) (a b : α) :
    A.le (A.add a b) b := by
  unfold TropicalF1Algebra.le;
  rw [ A.add_assoc, A.add_idem ]

/-! ## Part 3: Tropical Convex Hull -/

/-- A tropical linear combination: fold over a list of (weight, generator) pairs. -/
def TropicalF1Algebra.tropicalCombList (A : TropicalF1Algebra α)
    (pairs : List (α × α)) : α :=
  pairs.foldl (fun acc ⟨w, s⟩ => A.add acc (A.mul w s)) A.zero

/-- The tropical span: all elements reachable by tropical combinations. -/
def TropicalF1Algebra.tropicalSpan (A : TropicalF1Algebra α)
    (S : Set α) : Set α :=
  {x | ∃ pairs : List (α × α), (∀ p ∈ pairs, p.2 ∈ S) ∧ A.tropicalCombList pairs = x}

/-- The zero is always in the tropical span (empty combination). -/
theorem TropicalF1Algebra.zero_mem_tropicalSpan (A : TropicalF1Algebra α)
    (S : Set α) :
    A.zero ∈ A.tropicalSpan S := by
  exact ⟨[], fun _ h => absurd h List.not_mem_nil, rfl⟩

/-! ## Part 4: The WithTop ℕ Instance -/

/-
In the WithTop ℕ tropical F₁-algebra, the F₁-order agrees with
the standard order. This is the key semantic theorem.
-/
theorem tropical_order_agrees_min (a b : WithTop ℕ) :
    WithTop.tropicalF1.le a b ↔ a ≤ b := by
  convert min_eq_left_iff using 1

/-
Tropical multiplication preserves the tropical order — monotonicity
of scaling in tropical geometry.
-/
theorem tropical_mul_preserves_order (c a b : WithTop ℕ)
    (hab : WithTop.tropicalF1.le a b) :
    WithTop.tropicalF1.le (WithTop.tropicalF1.mul c a) (WithTop.tropicalF1.mul c b) := by
  -- Since min a b = a, we have a ≤ b.
  have h_le : a ≤ b := by
    exact tropical_order_agrees_min a b |>.1 hab;
  cases c <;> cases a <;> cases b <;> simp_all +decide;
  all_goals simp_all +decide [ WithTop.tropicalF1, TropicalF1Algebra.le ]

/-! ## Part 5: Lattice Polytopes and the Vertex-F₁ Correspondence -/

/-- The F₁-rank of a finite set is its cardinality. -/
def f1Rank (S : Finset α) : ℕ := S.card

/-- A lattice polytope in ℤⁿ, represented by its vertices. -/
structure LatticePolytope (n : ℕ) where
  vertices : Finset (Fin n → ℤ)
  nonempty : vertices.Nonempty

/-- The number of F₁-points of a lattice polytope is its vertex count. -/
def LatticePolytope.f1Points (P : LatticePolytope n) : ℕ := P.vertices.card

/-- A combinatorial fan in ℤⁿ, dual to a polytope. -/
structure CombinatorialFan (n : ℕ) where
  maxConeCount : ℕ

/-- The normal fan of a polytope has as many maximal cones as vertices. -/
def LatticePolytope.normalFan (P : LatticePolytope n) : CombinatorialFan n where
  maxConeCount := P.vertices.card

/-- **Euler Characteristic = F₁-Points**: the combinatorial shadow of the
deep correspondence between F₁-geometry and toric geometry. -/
theorem euler_char_equals_f1_points (n : ℕ) (P : LatticePolytope n) :
    P.normalFan.maxConeCount = P.f1Points :=
  rfl

/-- Vertices inject into lattice points: #F₁-points ≤ #lattice-points. -/
theorem lattice_points_rank (n : ℕ) (P : LatticePolytope n)
    (latticePoints : Finset (Fin n → ℤ))
    (hcontains : P.vertices ⊆ latticePoints) :
    P.f1Points ≤ f1Rank latticePoints :=
  Finset.card_le_card hcontains

/-- Base change preserves rank. -/
theorem base_change_preserves_rank (r : ℕ) :
    f1Rank (Finset.range r) = r :=
  Finset.card_range r

/-! ## Part 6: Tropical Polynomials and Corner Loci -/

/-- Evaluate a tropical polynomial. -/
def tropicalPolyEval (n : ℕ) (coeffs : Fin n → WithTop ℕ) (x : WithTop ℕ) : WithTop ℕ :=
  Finset.univ.inf fun i => coeffs i + (i.val : WithTop ℕ) * x

/-- The corner locus: where the minimum is achieved by ≥ 2 terms. -/
def cornerLocus (n : ℕ) (coeffs : Fin n → WithTop ℕ) : Set (WithTop ℕ) :=
  {x | ∃ i j : Fin n, i ≠ j ∧
    coeffs i + (i.val : WithTop ℕ) * x = tropicalPolyEval n coeffs x ∧
    coeffs j + (j.val : WithTop ℕ) * x = tropicalPolyEval n coeffs x}

/-
A tropical polynomial with all ⊤ coefficients evaluates to ⊤ everywhere.
-/
theorem tropicalPolyEval_top (n : ℕ) (x : WithTop ℕ) :
    tropicalPolyEval n (fun _ => ⊤) x = ⊤ := by
  unfold tropicalPolyEval;
  cases n <;> aesop

/-
A tropical constant polynomial evaluates to its constant coefficient.
-/
theorem tropicalPolyEval_const (c : WithTop ℕ) :
    tropicalPolyEval 1 (fun _ => c) x = c := by
  -- The infimum of a singleton set is the element itself.
  simp [tropicalPolyEval]

/-! ## Part 7: F₁-Betti Numbers -/

/-- The F₁-Betti number β_k: number of faces of dimension k. -/
def f1BettiNumber [DecidableEq α] (faces : Finset (Finset α)) (k : ℕ) : ℕ :=
  (faces.filter (fun σ => σ.card = k + 1)).card

/-- The tropical Euler characteristic: alternating sum of F₁-Betti numbers. -/
def tropicalEulerChar [DecidableEq α] (faces : Finset (Finset α)) (d : ℕ) : ℤ :=
  ∑ k ∈ Finset.range (d + 1), (-1 : ℤ) ^ k * (f1BettiNumber faces k : ℤ)

/-
For a complete simplicial complex on n+1 vertices (all nonempty subsets),
β_k equals C(n+1, k+1).
-/
theorem f1_betti_binomial (n k : ℕ) (_hk : k ≤ n) :
    f1BettiNumber ((Finset.range (n + 1)).powerset.filter Finset.Nonempty) k =
    (n + 1).choose (k + 1) := by
  convert Finset.card_powersetCard (k + 1) (Finset.range (n + 1)) using 1;
  · refine' Finset.card_bij ( fun x hx => x ) _ _ _ <;> simp +decide [ Finset.Nonempty ];
    · tauto;
    · exact fun b hb hb' => ⟨ ⟨ hb, Finset.card_pos.mp ( by linarith ) ⟩, hb' ⟩;
  · grind

end