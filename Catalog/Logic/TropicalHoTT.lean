/-
# Tropical Homotopy Type Theory: Idempotent Homotopy Semantics

This file develops a rigorous "tropical shadow" of identity and equivalence
from homotopy type theory, built on finite types, weighted relations, and
min-plus arithmetic.

## Main results

* `tropPathEq_isEquivalence`: The zero-distance relation on a tropical path
  space is an equivalence relation (Theorem 1).
* `TropEquiv.preserves_TropPathEq`: Tropical equivalences preserve path
  classes (Theorem 2).
* `matrixTropEquiv_decidable`: Tropical matrix equivalence is decidable
  (Theorem 3).
* `tropUnivalence_finite`: Classification theorem equating matrix-level
  and structure-level tropical equivalence (Tropical Univalence).
* Concrete examples on `Fin 3` and `Fin 4` distinguishing non-equivalent
  tropical types.
-/

import Mathlib

open Finset Function

/-! ## Core Definitions -/

/-- A tropical path space on a finite type `α`: a pseudometric with ℕ-valued distances. -/
structure TropicalPathSpace (α : Type*) [Fintype α] where
  d : α → α → ℕ
  self : ∀ x, d x x = 0
  symm : ∀ x y, d x y = d y x
  tri : ∀ x y z, d x z ≤ d x y + d y z

/-- The tropical path equality relation: two points are identified when their
    distance is zero. This is the tropical shadow of the identity type. -/
def TropPathEq {α : Type*} [Fintype α] (X : TropicalPathSpace α) : α → α → Prop :=
  fun x y => X.d x y = 0

/-- A tropical equivalence between two tropical path spaces: a bijection
    that preserves all pairwise distances. This is the tropical shadow of
    an equivalence of types. -/
structure TropEquiv (α β : Type*) [Fintype α] [Fintype β]
    (X : TropicalPathSpace α) (Y : TropicalPathSpace β) where
  toEquiv : α ≃ β
  isometry : ∀ x y, Y.d (toEquiv x) (toEquiv y) = X.d x y

/-- Distance matrix representation for finite tropical path spaces. -/
def DistanceMatrix (n : ℕ) := Fin n → Fin n → ℕ

/-- Matrix-level tropical equivalence: existence of a permutation witness. -/
def MatrixTropEquiv {n : ℕ} (D E : DistanceMatrix n) : Prop :=
  ∃ σ : Equiv.Perm (Fin n), ∀ i j, E (σ i) (σ j) = D i j

/-! ## Theorem 1: Tropical path zero relation is an equivalence relation -/

/-
The zero-distance relation on a tropical path space is an equivalence
    relation. This is the first bridge from identity types to tropical identity
    classes: the path type condenses into a computational quotient.
-/
theorem tropPathEq_isEquivalence
    {α : Type*} [Fintype α] (X : TropicalPathSpace α) :
    Equivalence (TropPathEq X) := by
  refine' ⟨ fun x => _, fun { x y } h => _, fun { x y z } hxy hyz => _ ⟩ <;> simp_all +decide [ TropPathEq ];
  · exact X.self x;
  · rw [ ← h, X.symm ];
  · linarith [ X.tri x y z, X.tri y z x, X.tri z x y ]

/-! ## Theorem 2: Tropical equivalences preserve path classes -/

/-
A tropical equivalence induces a bijection on tropical path components.
    This is the tropical analogue of transport along equivalence: the bridge
    from path semantics to equivalence semantics.
-/
theorem TropEquiv.preserves_TropPathEq
    {α β : Type*} [Fintype α] [Fintype β]
    {X : TropicalPathSpace α} {Y : TropicalPathSpace β}
    (e : TropEquiv α β X Y) :
    ∀ x y, TropPathEq X x y ↔ TropPathEq Y (e.toEquiv x) (e.toEquiv y) := by
  unfold TropPathEq;
  -- By definition of $e$, we know that $Y.d (e.toEquiv x) (e.toEquiv y) = X.d x y$ for all $x, y \in \alpha$.
  have h_iso : ∀ x y : α, Y.d (e.toEquiv x) (e.toEquiv y) = X.d x y := by
    exact e.isometry
  aesop

/-! ## Theorem 3: Decidability of matrix tropical equivalence -/

/-
For finite tropical path spaces, tropical equivalence is decidable:
    it reduces to searching over all permutations of `Fin n`. This is the
    tropical analogue of univalence becoming a decidable algebraic criterion.
-/
instance matrixTropEquiv_decidable {n : ℕ} (D E : DistanceMatrix n) :
    Decidable (MatrixTropEquiv D E) :=
  inferInstanceAs (Decidable (∃ σ : Equiv.Perm (Fin n), ∀ i j, E (σ i) (σ j) = D i j))

/-! ## Tropical Univalence: Classification theorem -/

/-
The tropical univalence theorem for finite spaces: matrix-level tropical
    equivalence coincides with structure-level tropical equivalence.
    Identity of structures up to equivalence becomes an explicit min-plus
    permutation witness.
-/
theorem tropUnivalence_finite
    {n : ℕ} (D E : DistanceMatrix n)
    (hD_self : ∀ i, D i i = 0) (hD_symm : ∀ i j, D i j = D j i)
    (hD_tri : ∀ i j k, D i k ≤ D i j + D j k)
    (hE_self : ∀ i, E i i = 0) (hE_symm : ∀ i j, E i j = E j i)
    (hE_tri : ∀ i j k, E i k ≤ E i j + E j k) :
    MatrixTropEquiv D E ↔
      ∃ _ : TropEquiv (Fin n) (Fin n)
        ⟨D, hD_self, hD_symm, hD_tri⟩
        ⟨E, hE_self, hE_symm, hE_tri⟩, True := by
  constructor;
  · rintro ⟨ σ, hσ ⟩;
    refine' ⟨ ⟨ _, _ ⟩, trivial ⟩;
    exacts [ σ, hσ ];
  · simp +decide [ MatrixTropEquiv ];
    exact fun e => ⟨ e.toEquiv, fun i j => e.isometry i j ⟩

/-! ## Theorem 4: Zero-edge relation and tropical quotient -/

/-- The zero-edge relation: two points are directly identified when the
    generating relation assigns zero weight. -/
def ZeroEdgeRel {α : Type*} (r : α → α → ℕ) : α → α → Prop :=
  fun x y => r x y = 0

/-
Given a tropical path space, the zero-distance relation equals
    the equivalence closure of the zero-edge relation.

    This is the tropical shadow of a higher inductive quotient: constructors
    become weighted edges, path constructors become zero-cost identifications,
    and the resulting quotient is computable.
-/
theorem tropical_quotient_generated_by_zero_edges
    {α : Type*} [Fintype α] (X : TropicalPathSpace α) :
    TropPathEq X = Relation.EqvGen (ZeroEdgeRel X.d) := by
  funext x yropPathEq;
  nontriviality;
  simp_all +decide [ TropPathEq ];
  constructor <;> intro h;
  · exact Relation.EqvGen.rel _ _ h;
  · induction h;
    · assumption;
    · exact X.self _;
    · rw [ X.symm, ‹X.d _ _ = 0› ];
    · rename_i x y z hxy hyz hx hyhy;
      exact le_antisymm ( by simpa [ hx, hyhy ] using X.tri x y z ) ( Nat.zero_le _ )

/-! ## Concrete Examples -/

/-! ### Example A: Discrete metric on Fin 3 -/

/-- The discrete tropical path space on `Fin 3`: distance 0 to self, distance 1
    to any other point. -/
def discreteFin3 : TropicalPathSpace (Fin 3) where
  d := fun i j => if i = j then 0 else 1
  self := fun x => if_pos rfl
  symm := fun x y => by
    show (if x = y then 0 else 1) = (if y = x then 0 else 1)
    split_ifs <;> simp_all [eq_comm]
  tri := fun x y z => by
    show (if x = z then 0 else 1) ≤ (if x = y then 0 else 1) + (if y = z then 0 else 1)
    split_ifs <;> simp_all

/-
In the discrete space on Fin 3, two points are tropically path-equal
    iff they are equal.
-/
theorem discreteFin3_pathEq_iff (x y : Fin 3) :
    TropPathEq discreteFin3 x y ↔ x = y := by
  fin_cases x <;> fin_cases y <;> simp +decide [ TropPathEq ]

/-! ### Example B: Cyclic tropical circle on Fin 3 -/

/-- A cyclic tropical path space on `Fin 3` with edge costs forming a triangle.
    Edge costs: d(0,1) = 1, d(1,2) = 1, d(0,2) = 2. -/
def cyclicFin3 : TropicalPathSpace (Fin 3) where
  d := fun i j =>
    if i = j then 0
    else if (i.val = 0 ∧ j.val = 1) ∨ (i.val = 1 ∧ j.val = 0) then 1
    else if (i.val = 1 ∧ j.val = 2) ∨ (i.val = 2 ∧ j.val = 1) then 1
    else 2
  self := fun x => if_pos rfl
  symm := fun x y => by
    fin_cases x <;> fin_cases y <;> decide
  tri := fun x y z => by
    fin_cases x <;> fin_cases y <;> fin_cases z <;> decide

/-! ### Example C: Distinguishing non-equivalent tropical types on Fin 4 -/

/-- Distance matrix D on Fin 4: the discrete metric. -/
def exD4_discrete : DistanceMatrix 4 :=
  fun i j => if i = j then 0 else 1

/-- Distance matrix E on Fin 4: a non-discrete metric where some pairs
    have distance 2. -/
def exD4_nondiscrete : DistanceMatrix 4 :=
  fun i j =>
    if i = j then 0
    else if (i.val + j.val) % 2 = 0 then 2
    else 1

/-
The discrete and non-discrete Fin 4 metrics are not tropically equivalent:
    there is no permutation witness. This demonstrates that tropical univalence
    does NOT collapse all finite spaces of the same size.
-/
theorem fin4_not_tropEquiv : ¬ MatrixTropEquiv exD4_discrete exD4_nondiscrete := by
  rintro ⟨ σ, hσ ⟩;
  revert σ; native_decide;

/-! ## Additional structural results -/

/-- Tropical path cost composition is bounded by the triangle inequality.
    This is the tropical shadow of path concatenation. -/
theorem tropPath_cost_compose_bound
    {α : Type*} [Fintype α] (X : TropicalPathSpace α) (x y z : α) :
    X.d x z ≤ X.d x y + X.d y z :=
  X.tri x y z

/-- The identity tropical equivalence: every tropical path space is
    equivalent to itself. -/
def TropEquiv.refl {α : Type*} [Fintype α] (X : TropicalPathSpace α) :
    TropEquiv α α X X where
  toEquiv := Equiv.refl α
  isometry := fun _ _ => rfl

/-
Matrix tropical equivalence is reflexive.
-/
theorem matrixTropEquiv_refl {n : ℕ} (D : DistanceMatrix n) :
    MatrixTropEquiv D D := by
  exact ⟨ Equiv.refl _, fun i j => rfl ⟩

/-
Matrix tropical equivalence is symmetric.
-/
theorem matrixTropEquiv_symm {n : ℕ} {D E : DistanceMatrix n} :
    MatrixTropEquiv D E → MatrixTropEquiv E D := by
  exact fun ⟨ σ, hσ ⟩ => ⟨ σ⁻¹, fun i j => by simpa [ eq_comm ] using hσ ( σ⁻¹ i ) ( σ⁻¹ j ) ⟩

/-
Matrix tropical equivalence is transitive.
-/
theorem matrixTropEquiv_trans {n : ℕ} {D E F : DistanceMatrix n} :
    MatrixTropEquiv D E → MatrixTropEquiv E F → MatrixTropEquiv D F := by
  rintro ⟨ σ, hσ ⟩ ⟨ τ, hτ ⟩;
  exact ⟨ τ * σ, fun i j => by simpa [ hσ ] using hτ ( σ i ) ( σ j ) ⟩

/-
Matrix tropical equivalence is an equivalence relation.
-/
theorem matrixTropEquiv_isEquivalence {n : ℕ} :
    Equivalence (fun D E : DistanceMatrix n => MatrixTropEquiv D E) := by
  constructor;
  · exact fun x => ⟨ Equiv.refl _, fun _ _ => rfl ⟩;
  · exact fun {x y} a => matrixTropEquiv_symm a
  · exact fun {x y z} a a_1 => matrixTropEquiv_trans a a_1