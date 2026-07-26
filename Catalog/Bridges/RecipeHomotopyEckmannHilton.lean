import Mathlib

/-!
# A Bridge between Topology and Algebra: the Eckmann–Hilton argument

## The cross-domain connection

This file proves a genuine *connector* theorem linking two areas that look
unrelated at first sight:

* **Topology / homotopy theory.** In a homotopy type the loops based at a point
  can be composed. When one moves to *2-dimensional* structure (loops between
  loops, i.e. the second homotopy group `π₂`, or loops in a topological monoid /
  H-space) there are genuinely *two* ways to compose: a "vertical" composition
  and a "horizontal" composition. They share a common identity (the constant
  loop) and satisfy the *interchange law*.

* **Algebra.** A commutative monoid.

The **Eckmann–Hilton argument** says these two worlds coincide: any set carrying
two unital binary operations that share the same unit and satisfy the
interchange law is forced to have the two operations *equal*, and that single
operation is automatically **commutative and associative**.  This is the abstract
reason why the higher homotopy groups `πₙ` (`n ≥ 2`) are abelian, and why the
fundamental group of a topological group is abelian.  A purely *topological*
input (two ways to compose loops) produces a purely *algebraic* output (a
commutative monoid) — no continuity, no analysis, only the interchange law.

## The "recipe / homotopy of dishes" narrative

Think of the points as *dishes* (flavor profiles) and of the two operations as
two different ways of combining cooking procedures: e.g. combining two recipes
"in series" (do one method after the other) versus "in parallel" (blend two
methods into one). The interchange law says that combining-in-series a pair of
parallel blends equals combining-in-parallel a pair of serial blends. The
Eckmann–Hilton theorem then says: whenever both ways of combining share a
trivial "do nothing" recipe, the two ways of combining are the *same* way, and
the resulting operation on dishes is commutative and associative. Cooking, at the
level of methods, is a commutative monoid.

## Main results

* `InterchangeStructure` — the data of two unital operations with a shared unit
  satisfying the interchange law.
* `InterchangeStructure.hcomp_eq_vcomp` — the two operations coincide.
* `InterchangeStructure.vcomp_comm` — the operation is commutative.
* `InterchangeStructure.vcomp_assoc` — the operation is associative.
* `InterchangeStructure.toCommMonoid` — package the raw data into a
  `CommMonoid`, realizing the topology → algebra bridge.
* `InterchangeStructure.ofCommMonoid` — every commutative monoid gives an
  interchange structure (with both operations equal to `*`), so the hypotheses
  are non-vacuous and the correspondence is genuine.
-/

namespace RecipeHomotopy

/-- Two binary operations `vcomp` ("vertical" composition, `∘`) and `hcomp`
("horizontal" composition, `⋆`) on a type `α`, sharing a common two-sided unit,
and satisfying the **interchange law**
`(a ⋆ b) ∘ (c ⋆ d) = (a ∘ c) ⋆ (b ∘ d)`.

In homotopy theory `α` is (a discrete model of) the loops-between-loops of a
space, `vcomp`/`hcomp` are the two natural compositions, and `unit` is the
constant loop. -/
structure InterchangeStructure (α : Type*) where
  /-- "Vertical" composition `∘`. -/
  vcomp : α → α → α
  /-- "Horizontal" composition `⋆`. -/
  hcomp : α → α → α
  /-- The shared unit (the constant / "do nothing" loop). -/
  unit : α
  /-- `unit` is a left unit for `vcomp`. -/
  vcomp_unit_left : ∀ a, vcomp unit a = a
  /-- `unit` is a right unit for `vcomp`. -/
  vcomp_unit_right : ∀ a, vcomp a unit = a
  /-- `unit` is a left unit for `hcomp`. -/
  hcomp_unit_left : ∀ a, hcomp unit a = a
  /-- `unit` is a right unit for `hcomp`. -/
  hcomp_unit_right : ∀ a, hcomp a unit = a
  /-- The interchange law relating the two compositions. -/
  interchange : ∀ a b c d,
    vcomp (hcomp a b) (hcomp c d) = hcomp (vcomp a c) (vcomp b d)

namespace InterchangeStructure

variable {α : Type*} (S : InterchangeStructure α)

/-- The two compositions agree, oriented `a ∘ b = a ⋆ b`. -/
theorem vcomp_eq_hcomp (a b : α) : S.vcomp a b = S.hcomp a b := by
  calc S.vcomp a b
      = S.vcomp (S.hcomp a S.unit) (S.hcomp S.unit b) := by
        rw [S.hcomp_unit_right, S.hcomp_unit_left]
    _ = S.hcomp (S.vcomp a S.unit) (S.vcomp S.unit b) := S.interchange _ _ _ _
    _ = S.hcomp a b := by rw [S.vcomp_unit_right, S.vcomp_unit_left]

/-- The two compositions agree: `a ⋆ b = a ∘ b`. -/
theorem hcomp_eq_vcomp (a b : α) : S.hcomp a b = S.vcomp a b :=
  (S.vcomp_eq_hcomp a b).symm

/-- The (common) composition is commutative. -/
theorem vcomp_comm (a b : α) : S.vcomp a b = S.vcomp b a := by
  have key : S.hcomp a b = S.vcomp b a := by
    calc S.hcomp a b
        = S.hcomp (S.vcomp S.unit a) (S.vcomp b S.unit) := by
          rw [S.vcomp_unit_left, S.vcomp_unit_right]
      _ = S.vcomp (S.hcomp S.unit b) (S.hcomp a S.unit) := (S.interchange _ _ _ _).symm
      _ = S.vcomp b a := by rw [S.hcomp_unit_left, S.hcomp_unit_right]
  rw [← key, S.hcomp_eq_vcomp]

/-- The (common) composition is associative. -/
theorem vcomp_assoc (a b c : α) :
    S.vcomp (S.vcomp a b) c = S.vcomp a (S.vcomp b c) := by
  have medial : ∀ x y z w, S.vcomp (S.vcomp x y) (S.vcomp z w)
      = S.vcomp (S.vcomp x z) (S.vcomp y w) := by
    intro x y z w
    calc S.vcomp (S.vcomp x y) (S.vcomp z w)
        = S.vcomp (S.hcomp x y) (S.hcomp z w) := by
          rw [S.vcomp_eq_hcomp x y, S.vcomp_eq_hcomp z w]
      _ = S.hcomp (S.vcomp x z) (S.vcomp y w) := S.interchange _ _ _ _
      _ = S.vcomp (S.vcomp x z) (S.vcomp y w) := S.hcomp_eq_vcomp _ _
  have h := medial a b S.unit c
  rw [S.vcomp_unit_left, S.vcomp_unit_right] at h
  exact h

/-- The horizontal composition is commutative (a restatement, via
`hcomp_eq_vcomp`). -/
theorem hcomp_comm (a b : α) : S.hcomp a b = S.hcomp b a := by
  rw [S.hcomp_eq_vcomp, S.hcomp_eq_vcomp, S.vcomp_comm]

/-- **Topology → Algebra bridge.** The raw interchange data assembles into a
`CommMonoid` structure on `α`, with multiplication the (common) composition and
identity the shared unit. -/
def toCommMonoid : CommMonoid α where
  mul := S.vcomp
  one := S.unit
  one_mul := S.vcomp_unit_left
  mul_one := S.vcomp_unit_right
  mul_assoc := S.vcomp_assoc
  mul_comm := S.vcomp_comm

/-- **Algebra → Topology bridge.** Every commutative monoid gives an interchange
structure (taking both operations to be `*`), so the interchange hypotheses are
satisfiable and the two viewpoints correspond. -/
def ofCommMonoid (M : Type*) [CommMonoid M] : InterchangeStructure M where
  vcomp := (· * ·)
  hcomp := (· * ·)
  unit := 1
  vcomp_unit_left := one_mul
  vcomp_unit_right := mul_one
  hcomp_unit_left := one_mul
  hcomp_unit_right := mul_one
  interchange := by
    intro a b c d
    exact mul_mul_mul_comm a b c d

end InterchangeStructure

/-- **Headline statement of the bridge.** If a type carries two operations with a
shared unit satisfying the interchange law, then it is a commutative monoid under
either operation and the two operations coincide. This is the algebraic content
behind "higher homotopy groups are abelian". -/
theorem eckmann_hilton {α : Type*} (S : InterchangeStructure α) :
    (∀ a b, S.hcomp a b = S.vcomp a b) ∧
    (∀ a b, S.vcomp a b = S.vcomp b a) ∧
    (∀ a b c, S.vcomp (S.vcomp a b) c = S.vcomp a (S.vcomp b c)) :=
  ⟨S.hcomp_eq_vcomp, S.vcomp_comm, S.vcomp_assoc⟩

end RecipeHomotopy