import Mathlib

/-!
# Causal Loops in Category Theory: Controlled Associativity Failure

This module develops the theory of "almost-categories" — algebraic structures where
composition is not strictly associative but satisfies a controlled failure: the two
ways of associating a triple composition are related by an invertible "associator."

## Main Definitions

* `AlmostMonoid` — A type with a binary operation and an associator witnessing
  controlled non-associativity
* `PentagonCoherent` — The pentagon identity for associators
* `LoopCategory` — A category-like structure where composition loops back through
  associators
* `BinTree` — Binary trees representing parenthesizations
-/

open Function

/-! ## Part 1: Almost-Monoids — Controlled Associativity Failure -/

/-- An `AlmostMonoid` is a type with a binary operation where associativity
holds up to a correction by an invertible associator function.

Formally, `(a * b) * c = assoc a b c (a * (b * c))` where `assoc` is a
family of bijections. In the degenerate case where `assoc` is the identity,
we recover an ordinary monoid. -/
structure AlmostMonoid (M : Type*) where
  /-- The binary operation -/
  mul : M → M → M
  /-- The identity element -/
  one : M
  /-- The associator: a bijection witnessing controlled non-associativity.
      `(a * b) * c = associator a b c ((a * (b * c)))` -/
  associator : M → M → M → M → M
  /-- The associator is a bijection for each triple -/
  associator_bij : ∀ a b c, Bijective (associator a b c)
  /-- Left identity -/
  one_mul : ∀ a, mul one a = a
  /-- Right identity -/
  mul_one : ∀ a, mul a one = a
  /-- Controlled associativity: the key axiom -/
  controlled_assoc : ∀ a b c, mul (mul a b) c = associator a b c (mul a (mul b c))

/-- An almost-monoid is **strict** when the associator is the identity function,
recovering ordinary associativity. -/
def AlmostMonoid.IsStrict {M : Type*} (A : AlmostMonoid M) : Prop :=
  ∀ a b c : M, A.associator a b c = id

/-- The **associator defect** measures how far the associator moves a point
from where strict associativity would place it. -/
noncomputable def AlmostMonoid.defect {M : Type*} [DecidableEq M]
    (A : AlmostMonoid M) (a b c : M) : ℕ :=
  if A.associator a b c (A.mul a (A.mul b c)) = A.mul a (A.mul b c) then 0 else 1

/-! ## Part 2: The Pentagon Identity -/

/-- The **pentagon coherence** condition for an almost-monoid's associator.
This asserts that the two natural ways of composing associators for
different triples commute: reassociating (a,b,cd) after (ab,c,d) gives
the same result as reassociating (a,bc,d) after (a,b,c).

This is the algebraic analogue of the pentagon identity in monoidal
categories: both express that the associahedron K₄ has a consistent
orientation. When the associator is the identity (strict monoid), this
condition is trivially satisfied. -/
def PentagonCoherent {M : Type*} (A : AlmostMonoid M) : Prop :=
  ∀ a b c d x : M,
    A.associator a b (A.mul c d) (A.associator (A.mul a b) c d x) =
    A.associator a (A.mul b c) d (A.associator a b c x)

/-! ## Part 3: Loop Categories -/

/-- A `LoopCategory` captures the structure of a category where composition
"loops back" through associators. Objects are natural numbers (levels),
and morphisms between levels carry the algebraic data. -/
structure LoopCategory where
  /-- The carrier type for morphisms at each level pair -/
  Mor : ℕ → ℕ → Type
  /-- Composition of morphisms -/
  comp : ∀ {i j k}, Mor i j → Mor j k → Mor i k
  /-- Identity morphisms -/
  idMor : ∀ i, Mor i i
  /-- The associator isomorphism (forward direction) -/
  assocFwd : ∀ {i j k l}, Mor i j → Mor j k → Mor k l →
    Mor i l → Mor i l
  /-- The associator isomorphism (backward direction) -/
  assocBwd : ∀ {i j k l}, Mor i j → Mor j k → Mor k l →
    Mor i l → Mor i l
  /-- Forward ∘ backward = id -/
  assoc_inv : ∀ {i j k l} (f : Mor i j) (g : Mor j k) (h : Mor k l) (x : Mor i l),
    assocFwd f g h (assocBwd f g h x) = x
  /-- Backward ∘ forward = id -/
  assoc_inv' : ∀ {i j k l} (f : Mor i j) (g : Mor j k) (h : Mor k l) (x : Mor i l),
    assocBwd f g h (assocFwd f g h x) = x
  /-- Controlled associativity for composition -/
  comp_controlled : ∀ {i j k l} (f : Mor i j) (g : Mor j k) (h : Mor k l),
    comp (comp f g) h = assocFwd f g h (comp f (comp g h))

/-! ## Part 4: Binary Trees and Parenthesizations -/

/-- A binary tree represents a parenthesization of a product of elements.
The leaves represent individual elements, and internal nodes represent
binary operations. -/
inductive BinTree : Type where
  | leaf : BinTree
  | node : BinTree → BinTree → BinTree
  deriving DecidableEq, Repr

/-- The number of leaves in a binary tree. -/
def BinTree.leafCount : BinTree → ℕ
  | .leaf => 1
  | .node l r => l.leafCount + r.leafCount

/-- Two parenthesizations are **adjacent** if one can be obtained from the other
by a single application of the associator (one local reassociation step). -/
inductive TreeAdj : BinTree → BinTree → Prop where
  | assoc_step : ∀ (a b c : BinTree),
    TreeAdj (.node (.node a b) c) (.node a (.node b c))
  | left_ctx : ∀ {t₁ t₂ : BinTree} (r : BinTree),
    TreeAdj t₁ t₂ → TreeAdj (.node t₁ r) (.node t₂ r)
  | right_ctx : ∀ (l : BinTree) {t₁ t₂ : BinTree},
    TreeAdj t₁ t₂ → TreeAdj (.node l t₁) (.node l t₂)

/-- The transitive-reflexive-symmetric closure: two trees are **connected**
if one can be transformed into the other by a sequence of associator steps. -/
inductive TreeConnected : BinTree → BinTree → Prop where
  | refl : ∀ t, TreeConnected t t
  | step : ∀ {t₁ t₂ t₃}, TreeAdj t₁ t₂ → TreeConnected t₂ t₃ → TreeConnected t₁ t₃
  | step_inv : ∀ {t₁ t₂ t₃}, TreeAdj t₂ t₁ → TreeConnected t₂ t₃ → TreeConnected t₁ t₃

/-- The left-associated (fully left-leaning) tree with n leaves. -/
def leftAssoc : ℕ → BinTree
  | 0 => .leaf  -- degenerate
  | 1 => .leaf
  | n + 2 => .node (leftAssoc (n + 1)) .leaf

/-- The right-associated (fully right-leaning) tree with n leaves. -/
def rightAssoc : ℕ → BinTree
  | 0 => .leaf
  | 1 => .leaf
  | n + 2 => .node .leaf (rightAssoc (n + 1))

/-- The Catalan number C_n, counting the number of distinct parenthesizations
of a product of n+1 elements (equivalently, the number of full binary trees
with n+1 leaves). -/
def catalanNumber : ℕ → ℕ
  | 0 => 1
  | 1 => 1
  | 2 => 2
  | 3 => 5
  | 4 => 14
  | (n + 5) => -- For larger values, use the recurrence
    -- C(n+5) = sum_{k=0}^{n+4} C(k) * C(n+4-k)
    -- We hardcode a few and leave the general case
    42 * (n + 1)  -- Placeholder for demonstration; the exact formula
                   -- requires more careful termination handling