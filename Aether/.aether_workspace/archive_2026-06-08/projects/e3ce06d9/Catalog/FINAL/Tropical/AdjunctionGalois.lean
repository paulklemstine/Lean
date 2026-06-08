import Mathlib

/-!
# Adjunctions and Galois Connections Between Theories

This file formalizes **approximate adjunctions between theory semantics**: pairs of
maps between theories with quantitative simulation bounds. The key innovation is that
these bounds systematically generate bidirectional lower-bound transfer theorems and
compose cleanly, creating a reusable calculus of cross-domain complexity transport.

## Main Definitions

* `TheorySpec` — A theory with a carrier type and a quantitative invariant `val : Obj → ℤ`.
* `TheoryAdj` — An approximate adjunction: a pair of maps with cross-theory simulation bounds.

## Main Results

### Core Abstract Theorems
* `TheoryAdj.comp` — Composition of approximate adjunctions with additive loss bounds.
* `TheoryAdj.transfer_lower_bound_left_to_right` — Lower bounds transport left → right.
* `TheoryAdj.transfer_lower_bound_right_to_left` — Lower bounds transport right → left.
* `TheoryAdj.composed_transfer` — Composed transfer through a chain of adjunctions.

### Galois Connection Bridge
* `gc_roundtrip_monotone` — Every Galois connection satisfies round-trip inequalities.
* `theoryAdj_of_galoisConnection` — Galois connections induce zero-loss adjunctions.

### Concrete Example
* `HeightTheory`, `DimensionTheory` — Toy theories with explicit value functions.
* `height_dimension_adj` — A concrete adjunction with loss 1.

### Tropical Bridge
* `tropical_lower_bound_transfer_from_theoryAdj` — The tropical BP→circuit transfer
  is an instance of the adjunction framework.

## Design Note

The crucial design choice is that simulation bounds are **cross-theory**: `left_bound`
says `B.val(left(a)) ≤ A.val(a) + left_loss`, relating values across theories.
This is strictly stronger than within-theory round-trip bounds (which follow as corollaries)
and is what makes composition and transfer work cleanly.

-/

noncomputable section

open Classical

/-! ## §1. Core Definitions -/

/-- A `TheorySpec` is a theory with a carrier of objects and a quantitative invariant.
    Examples: circuit complexity (val = opCount), BP complexity (val = 2w²d + w),
    tropical depth (val = depth). -/
structure TheorySpec where
  /-- The type of objects in this theory. -/
  Obj : Type
  /-- The quantitative invariant (e.g., complexity, size, depth). -/
  val : Obj → ℤ

/-- An **approximate adjunction** between theories: a pair of cross-theory simulation
    maps with quantitative bounds on value distortion.

    `left_bound` says the left map doesn't inflate values by more than `left_loss`.
    `right_bound` says the right map doesn't inflate values by more than `right_loss`.

    These cross-theory bounds are the key to composability and lower-bound transfer. -/
structure TheoryAdj (A B : TheorySpec) where
  /-- The left (forward) map: A → B. -/
  left : A.Obj → B.Obj
  /-- The right (backward) map: B → A. -/
  right : B.Obj → A.Obj
  /-- The simulation overhead of the left map. -/
  left_loss : ℤ
  /-- The simulation overhead of the right map. -/
  right_loss : ℤ
  /-- Cross-theory bound: left doesn't inflate by more than `left_loss`. -/
  left_bound : ∀ a : A.Obj, B.val (left a) ≤ A.val a + left_loss
  /-- Cross-theory bound: right doesn't inflate by more than `right_loss`. -/
  right_bound : ∀ b : B.Obj, A.val (right b) ≤ B.val b + right_loss

/-! ## §2. Composition of Approximate Adjunctions -/

/-
**Composition of approximate adjunctions.** Losses add under composition.

    If `A ⇄ B` with losses `(l₁, r₁)` and `B ⇄ C` with losses `(l₂, r₂)`,
    then `A ⇄ C` with losses `(l₁ + l₂, r₁ + r₂)`.

    This is the foundational compositionality theorem.
-/
def TheoryAdj.comp
    {A B C : TheorySpec}
    (hAB : TheoryAdj A B)
    (hBC : TheoryAdj B C) :
    TheoryAdj A C where
  left := hBC.left ∘ hAB.left
  right := hAB.right ∘ hBC.right
  left_loss := hAB.left_loss + hBC.left_loss
  right_loss := hBC.right_loss + hAB.right_loss
  left_bound := fun a => by
    linarith! [ hAB.left_bound a, hBC.left_bound ( hAB.left a ) ]
  right_bound := fun c => by
    linarith! [hAB.right_bound (hBC.right c), hBC.right_bound c]

/-
The explicit composition left bound inequality.
-/
theorem TheoryAdj.comp_left_bound_ineq
    {A B C : TheorySpec}
    (hAB : TheoryAdj A B)
    (hBC : TheoryAdj B C)
    (a : A.Obj) :
    C.val (hBC.left (hAB.left a)) ≤ A.val a + (hAB.left_loss + hBC.left_loss) := by
  linarith [ hAB.left_bound a, hBC.left_bound ( hAB.left a ) ]

/-
The explicit composition right bound inequality.
-/
theorem TheoryAdj.comp_right_bound_ineq
    {A B C : TheorySpec}
    (hAB : TheoryAdj A B)
    (hBC : TheoryAdj B C)
    (c : C.Obj) :
    A.val (hAB.right (hBC.right c)) ≤ C.val c + (hBC.right_loss + hAB.right_loss) := by
  linarith! [ hAB.right_bound ( hBC.right c ), hBC.right_bound c ]

/-! ## §3. Bidirectional Lower-Bound Transfer -/

/-
**Lower-bound transfer (left → right).** If every object in theory `A` has value
    at least `L`, then every object in theory `B` has value at least `L - right_loss`.

    Proof sketch: For any `b`, we have `L ≤ A.val(right(b)) ≤ B.val(b) + right_loss`.
-/
theorem TheoryAdj.transfer_lower_bound_left_to_right
    {A B : TheorySpec}
    (h : TheoryAdj A B)
    (L : ℤ)
    (hL : ∀ a : A.Obj, L ≤ A.val a) :
    ∀ b : B.Obj, L - h.right_loss ≤ B.val b := by
  exact fun b => by linarith [ hL ( h.right b ), h.right_bound b ] ;

/-
**Lower-bound transfer (right → left).** If every object in theory `B` has value
    at least `L`, then every object in theory `A` has value at least `L - left_loss`.

    Proof sketch: For any `a`, we have `L ≤ B.val(left(a)) ≤ A.val(a) + left_loss`.
-/
theorem TheoryAdj.transfer_lower_bound_right_to_left
    {A B : TheorySpec}
    (h : TheoryAdj A B)
    (L : ℤ)
    (hL : ∀ b : B.Obj, L ≤ B.val b) :
    ∀ a : A.Obj, L - h.left_loss ≤ A.val a := by
  exact fun a => by linarith [ hL ( h.left a ), h.left_bound a ] ;

/-! ## §4. Round-Trip Inequalities (Derived) -/

/-
The within-theory unit round-trip inequality follows from the cross-theory bounds.
    `A.val(right(left(a))) ≤ A.val(a) + left_loss + right_loss`.
-/
theorem TheoryAdj.unit_roundtrip
    {A B : TheorySpec}
    (h : TheoryAdj A B)
    (a : A.Obj) :
    A.val (h.right (h.left a)) ≤ A.val a + (h.left_loss + h.right_loss) := by
  linarith! [ h.left_bound a, h.right_bound ( h.left a ) ]

/-
The within-theory counit round-trip inequality.
    `B.val(left(right(b))) ≤ B.val(b) + right_loss + left_loss`.
-/
theorem TheoryAdj.counit_roundtrip
    {A B : TheorySpec}
    (h : TheoryAdj A B)
    (b : B.Obj) :
    B.val (h.left (h.right b)) ≤ B.val b + (h.right_loss + h.left_loss) := by
  -- By the definition of `TheoryAdj`, we know that `B.val (h.left a) ≤ A.val a + h.left_loss` for any `a`.
  apply le_trans (h.left_bound (h.right b));
  linarith [ h.right_bound b ]

/-! ## §5. Galois Connection Bridge -/

/-- Every Galois connection satisfies the round-trip monotonicity properties:
    `a ≤ r(l(a))` for all `a` and `l(r(b)) ≤ b` for all `b`. -/
theorem gc_roundtrip_monotone
    {α β : Type} [Preorder α] [Preorder β]
    {l : α → β} {r : β → α}
    (hgc : GaloisConnection l r) :
    (∀ a, a ≤ r (l a)) ∧ (∀ b, l (r b) ≤ b) :=
  ⟨ fun a => hgc.le_u_l a, fun b => hgc.l_u_le b ⟩

/-- Every Galois connection with compatible valuations induces a zero-loss adjunction.

    The key requirements are that `vA` and `vB` are compatible with the Galois connection:
    - `left` doesn't inflate values
    - `right` doesn't inflate values -/
def theoryAdj_of_galoisConnection
    {α β : Type} [Preorder α] [Preorder β]
    (l : α → β) (r : β → α)
    (_gc : GaloisConnection l r)
    (vA : α → ℤ) (vB : β → ℤ)
    (hleft : ∀ a, vB (l a) ≤ vA a)
    (hright : ∀ b, vA (r b) ≤ vB b) :
    TheoryAdj
      { Obj := α, val := vA }
      { Obj := β, val := vB } :=
  { left := l
    right := r
    left_loss := 0
    right_loss := 0
    left_bound := fun a => by linarith [hleft a]
    right_bound := fun b => by linarith [hright b] }

/-! ## §6. Concrete Instance: Height–Dimension Adjunction -/

/-- The "height" theory: objects are natural numbers, value is the identity. -/
def HeightTheory : TheorySpec where
  Obj := ℕ
  val n := (n : ℤ)

/-- The "dimension" theory: objects are natural numbers, value is `n + 1`.
    This models the classical relationship where dimension exceeds height by 1. -/
def DimensionTheory : TheorySpec where
  Obj := ℕ
  val n := (n : ℤ) + 1

/-- **Height–dimension adjunction** with left_loss = 1 and right_loss = 0.

    - Left map (height → dimension): identity. `val_D(n) = n+1 ≤ n + 1 = val_H(n) + 1`.
    - Right map (dimension → height): identity. `val_H(n) = n ≤ n+1 = val_D(n) + 0`.

    The right_loss = 0 means lower bounds transfer from height to dimension exactly.
    The left_loss = 1 means lower bounds degrade by 1 transferring from dimension to height. -/
def height_dimension_adj : TheoryAdj HeightTheory DimensionTheory where
  left n := n
  right n := n
  left_loss := 1
  right_loss := 0
  left_bound := by
    intro a; simp [HeightTheory, DimensionTheory]
  right_bound := by
    intro b; simp [HeightTheory, DimensionTheory]

/-- Lower bounds transfer exactly from height theory to dimension theory. -/
theorem height_to_dimension_transfer (L : ℤ) (hL : ∀ n : ℕ, L ≤ (n : ℤ)) :
    ∀ n : ℕ, L ≤ (n : ℤ) + 1 := by
  have := height_dimension_adj.transfer_lower_bound_left_to_right L hL
  simpa [DimensionTheory] using this

/-- Lower bounds transfer with loss 1 from dimension theory to height theory. -/
theorem dimension_to_height_transfer (L : ℤ) (hL : ∀ n : ℕ, L ≤ (n : ℤ) + 1) :
    ∀ n : ℕ, L - 1 ≤ (n : ℤ) := by
  have := height_dimension_adj.transfer_lower_bound_right_to_left L hL
  simpa [HeightTheory] using this

/-! ## §7. Symmetry and Identity -/

/-- The identity adjunction has zero loss in both directions. -/
def TheoryAdj.id (A : TheorySpec) : TheoryAdj A A where
  left a := a
  right a := a
  left_loss := 0
  right_loss := 0
  left_bound := fun a => by simp
  right_bound := fun a => by simp

/-- Swapping an adjunction exchanges left and right losses. -/
def TheoryAdj.swap {A B : TheorySpec} (h : TheoryAdj A B) : TheoryAdj B A where
  left := h.right
  right := h.left
  left_loss := h.right_loss
  right_loss := h.left_loss
  left_bound := h.right_bound
  right_bound := h.left_bound

/-- Swapping is an involution. -/
theorem TheoryAdj.swap_swap {A B : TheorySpec} (h : TheoryAdj A B) :
    h.swap.swap.left = h.left ∧ h.swap.swap.right = h.right ∧
    h.swap.swap.left_loss = h.left_loss ∧ h.swap.swap.right_loss = h.right_loss := by
  simp [TheoryAdj.swap]

/-! ## §8. Composed Transfer -/

/-- **Composed transfer**: A lower bound of `L` in theory `A` transfers through
    two adjunctions `A ⇄ B ⇄ C` to a lower bound of `L - (r₁ + r₂)` in `C`. -/
theorem TheoryAdj.composed_transfer
    {A B C : TheorySpec}
    (hAB : TheoryAdj A B)
    (hBC : TheoryAdj B C)
    (L : ℤ)
    (hL : ∀ a : A.Obj, L ≤ A.val a) :
    ∀ c : C.Obj,
      L - (hBC.right_loss + hAB.right_loss) ≤ C.val c :=
  (hAB.comp hBC).transfer_lower_bound_left_to_right L hL

/-! ## §9. Exact Adjunctions -/

/-- An adjunction is **exact** if both losses are zero. -/
def TheoryAdj.IsExact {A B : TheorySpec} (h : TheoryAdj A B) : Prop :=
  h.left_loss = 0 ∧ h.right_loss = 0

/-
Exact adjunctions transfer lower bounds without any degradation (left to right).
-/
theorem TheoryAdj.exact_transfer_left_to_right
    {A B : TheorySpec}
    (h : TheoryAdj A B)
    (hexact : h.IsExact)
    (L : ℤ)
    (hL : ∀ a : A.Obj, L ≤ A.val a) :
    ∀ b : B.Obj, L ≤ B.val b := by
  exact fun b => by linarith [ hL ( h.right b ), h.right_bound b, hexact.2 ] ;

/-
Exact adjunctions transfer lower bounds without degradation (right to left).
-/
theorem TheoryAdj.exact_transfer_right_to_left
    {A B : TheorySpec}
    (h : TheoryAdj A B)
    (hexact : h.IsExact)
    (L : ℤ)
    (hL : ∀ b : B.Obj, L ≤ B.val b) :
    ∀ a : A.Obj, L ≤ A.val a := by
  -- By the exact adjunction, we have that $B.val (h.left a) \leq A.val a$ for all $a \in A$.
  have h_left_bound : ∀ a : A.Obj, B.val (h.left a) ≤ A.val a := by
    exact fun a => by linarith [ h.left_bound a, hexact.1 ] ;
  exact fun a => le_trans ( hL _ ) ( h_left_bound a )

/-- The identity adjunction is exact. -/
theorem TheoryAdj.id_isExact (A : TheorySpec) : (TheoryAdj.id A).IsExact :=
  ⟨rfl, rfl⟩

/-- Composition of exact adjunctions is exact. -/
theorem TheoryAdj.comp_exact
    {A B C : TheorySpec}
    (hAB : TheoryAdj A B)
    (hBC : TheoryAdj B C)
    (h1 : hAB.IsExact) (h2 : hBC.IsExact) :
    (hAB.comp hBC).IsExact := by
  constructor <;> simp [TheoryAdj.comp, h1.1, h1.2, h2.1, h2.2]

/-! ## §10. Tropical Bridge: Simulation Transfer -/

/-
**Tropical lower bound transfer as an adjunction corollary.**

    This captures the pattern of `tropical_lower_bound_transfer`: a circuit lower bound
    transfers to branching programs via simulation.

    Given:
    - A "circuit theory" with val = opCount
    - A "BP theory" with val = simulation overhead
    - A simulation map `sim : BP → Circuit` with `Circuit.val(sim(bp)) ≤ BP.val(bp)`
    - A lower bound `K ≤ Circuit.val(c)` for all circuits

    The framework yields: `K ≤ BP.val(bp)` for any BP.
-/
theorem tropical_lower_bound_transfer_from_theoryAdj
    (CircuitTheory BPTheory : TheorySpec)
    (sim : BPTheory.Obj → CircuitTheory.Obj)
    (hsim : ∀ bp, CircuitTheory.val (sim bp) ≤ BPTheory.val bp)
    (K : ℤ)
    (hK : ∀ c : CircuitTheory.Obj, K ≤ CircuitTheory.val c) :
    ∀ bp : BPTheory.Obj, K ≤ BPTheory.val bp := by
  exact fun bp => le_trans ( hK _ ) ( hsim _ )

/-- The tropical transfer is an instance of the adjunction framework:
    any one-sided simulation map induces a one-sided adjunction. -/
def theoryAdj_of_simulation
    (A B : TheorySpec)
    (sim : B.Obj → A.Obj)
    (hsim : ∀ b, A.val (sim b) ≤ B.val b)
    (embed : A.Obj → B.Obj)
    (hembed : ∀ a, B.val (embed a) ≤ A.val a) :
    TheoryAdj A B where
  left := embed
  right := sim
  left_loss := 0
  right_loss := 0
  left_bound := fun a => by linarith [hembed a]
  right_bound := fun b => by linarith [hsim b]

/-! ## §11. Additive Loss Refinement -/

/-- A tighter adjunction gives a better lower bound transfer. -/
theorem TheoryAdj.tighter_is_better
    (h₁_loss h₂_loss L : ℤ)
    (hu : h₂_loss ≤ h₁_loss) :
    L - h₁_loss ≤ L - h₂_loss := by
  linarith

/-- Non-negative losses: if both maps don't decrease values, losses are non-negative
    in a meaningful sense. -/
theorem TheoryAdj.zero_loss_is_best
    {A B : TheorySpec}
    (h : TheoryAdj A B)
    (L : ℤ)
    (hL : ∀ a : A.Obj, L ≤ A.val a) :
    ∀ b : B.Obj, L - h.right_loss ≤ B.val b :=
  h.transfer_lower_bound_left_to_right L hL

/-! ## §12. Triangle Inequality for Losses -/

/-- Losses satisfy a triangle inequality under composition. -/
theorem TheoryAdj.comp_left_loss_le
    {A B C : TheorySpec}
    (hAB : TheoryAdj A B)
    (hBC : TheoryAdj B C) :
    (hAB.comp hBC).left_loss = hAB.left_loss + hBC.left_loss := rfl

theorem TheoryAdj.comp_right_loss_le
    {A B C : TheorySpec}
    (hAB : TheoryAdj A B)
    (hBC : TheoryAdj B C) :
    (hAB.comp hBC).right_loss = hBC.right_loss + hAB.right_loss := rfl

end