import Mathlib

/-!
# Tropical Knot Theory: Core Definitions

This module defines the foundational types and operations for tropical knot theory:

* `TropLaurent` — tropical Laurent polynomials as functions `ℤ → WithTop ℤ`
* `KnotDiagram` — combinatorial knot diagrams with recursive crossing structure
* `tJones` — the tropical Jones invariant via min-plus skein recursion
* `tropSupport`, `tropicalSpan` — support analysis for tropical polynomials

## Mathematical Framework

A **tropical Laurent polynomial** is a function `f : ℤ → WithTop ℤ` where `⊤` represents
the tropical zero. The tropical semiring uses `min` as addition and `+` as multiplication.

A **knot diagram** is encoded as a binary tree of crossings, each with weights for its
A-resolution and B-resolution. The leaves are unknotted loops. This captures the
Kauffman bracket state-sum structure: resolving all crossings yields a collection of loops,
and the tropical Jones invariant computes the min-plus state sum over all resolutions.

The **tropical Jones invariant** `tJones D n` gives the minimum cost to achieve Laurent
degree `n` over all complete resolutions of diagram `D`. Each crossing resolution shifts
the Laurent degree by ±1, mirroring the variable `A^{±1}` in the Kauffman bracket.
-/

namespace TropicalKnotTheory

/-! ## Tropical Laurent Polynomials -/

/-- A tropical Laurent polynomial: a function from ℤ (Laurent degrees) to WithTop ℤ
    (tropical values). The value ⊤ represents the tropical zero at that degree. -/
def TropLaurent := ℤ → WithTop ℤ

/-- Tropical addition: pointwise infimum. This is the tropical semiring's addition. -/
def tropAdd (f g : TropLaurent) : TropLaurent := fun n => min (f n) (g n)

/-- The tropical zero polynomial: ⊤ everywhere. This is the additive identity under min. -/
def tropZero : TropLaurent := fun _ => ⊤

/-- A tropical monomial: value `v` at degree `d`, tropical zero (⊤) elsewhere. -/
def tropMonomial (d : ℤ) (v : WithTop ℤ) : TropLaurent :=
  fun n => if n = d then v else ⊤

/-- The support of a tropical Laurent polynomial: degrees with finite value. -/
def tropSupport (f : TropLaurent) : Set ℤ := {n | f n ≠ ⊤}

/-- Tropical addition is commutative. -/
theorem tropAdd_comm (f g : TropLaurent) : tropAdd f g = tropAdd g f := by
  funext n; simp [tropAdd, min_comm]

/-- Tropical addition is associative. -/
theorem tropAdd_assoc (f g h : TropLaurent) :
    tropAdd (tropAdd f g) h = tropAdd f (tropAdd g h) := by
  funext n; simp [tropAdd, min_assoc]

/-- Tropical zero is the identity for tropical addition. -/
theorem tropAdd_zero (f : TropLaurent) : tropAdd f tropZero = f := by
  funext n; simp [tropAdd, tropZero]

/-- Tropical addition is idempotent: f ⊕ f = f. -/
theorem tropAdd_self (f : TropLaurent) : tropAdd f f = f := by
  funext n; simp [tropAdd]

/-! ## Knot Diagrams -/

/-- A combinatorial knot diagram, represented as a binary tree of crossings.

    - `loop` represents an unknotted loop (no crossings)
    - `crossing wA wB D0 D1` represents a diagram with a distinguished crossing,
      where `wA` and `wB` are the tropical weights (costs) for the A-resolution and
      B-resolution respectively, and `D0`, `D1` are the resulting sub-diagrams.

    The weights model the contribution of each crossing to the state-sum cost.
    The Laurent degree shifts by -1 for the A-resolution and +1 for the B-resolution,
    mirroring the `A` and `A⁻¹` factors in the Kauffman bracket. -/
inductive KnotDiagram where
  | loop : KnotDiagram
  | crossing : ℤ → ℤ → KnotDiagram → KnotDiagram → KnotDiagram
  deriving Inhabited, BEq, Repr

namespace KnotDiagram

/-- The number of crossings in a knot diagram (= number of internal nodes in the tree). -/
def numCrossings : KnotDiagram → ℕ
  | .loop => 0
  | .crossing _ _ D0 D1 => 1 + numCrossings D0 + numCrossings D1

/-- The writhe of a knot diagram: sum of signs of crossings.
    By convention, A-resolution weight minus B-resolution weight determines the sign. -/
def writhe : KnotDiagram → ℤ
  | .loop => 0
  | .crossing wA wB D0 D1 => (wA - wB).sign + writhe D0 + writhe D1

/-- The A-resolution of the outermost crossing. -/
def resolveA : KnotDiagram → KnotDiagram
  | .loop => .loop
  | .crossing _ _ D0 _ => D0

/-- The B-resolution of the outermost crossing. -/
def resolveB : KnotDiagram → KnotDiagram
  | .loop => .loop
  | .crossing _ _ _ D1 => D1

/-- The A-weight of the outermost crossing. Returns 0 for a loop. -/
def crossingWeightA : KnotDiagram → ℤ
  | .loop => 0
  | .crossing wA _ _ _ => wA

/-- The B-weight of the outermost crossing. Returns 0 for a loop. -/
def crossingWeightB : KnotDiagram → ℤ
  | .loop => 0
  | .crossing _ wB _ _ => wB

/-! ## The Tropical Jones Invariant -/

/-- The tropical Jones invariant, defined by min-plus skein recursion.

    For an unknotted loop, the value is 0 at degree 0 and ⊤ (tropical zero) elsewhere.
    For a crossing with weights `wA`, `wB` and sub-diagrams `D0`, `D1`:
    - The A-resolution contributes `wA + tJones D0 (n - 1)` (degree shift -1)
    - The B-resolution contributes `wB + tJones D1 (n + 1)` (degree shift +1)
    - The result is the tropical sum (min) of these contributions.

    This models the state-sum: each complete resolution assigns a total weight (sum of
    crossing weights along the resolution path) and a total degree (sum of ±1 shifts).
    The tropical Jones value at degree `n` is the minimum weight over all resolutions
    achieving degree `n`. -/
def tJones : KnotDiagram → ℤ → WithTop ℤ
  | .loop, n => if n = 0 then (0 : WithTop ℤ) else ⊤
  | .crossing wA wB D0 D1, n =>
      min ((wA : WithTop ℤ) + tJones D0 (n - 1)) ((wB : WithTop ℤ) + tJones D1 (n + 1))

/-- The total tropical cost of a diagram: minimum tropical Jones value across all degrees. -/
noncomputable def tCost : KnotDiagram → WithTop ℤ :=
  fun D => ⨅ n : ℤ, tJones D n

/-! ## Simplification -/

/-- A one-step simplification of a knot diagram by resolving a crossing.
    This can happen at the top level or inside a sub-diagram. -/
inductive SimpStep : KnotDiagram → KnotDiagram → Prop where
  | resolveA (wA wB : ℤ) (D0 D1 : KnotDiagram) :
      SimpStep (.crossing wA wB D0 D1) D0
  | resolveB (wA wB : ℤ) (D0 D1 : KnotDiagram) :
      SimpStep (.crossing wA wB D0 D1) D1
  | inLeft (wA wB : ℤ) (D0 D0' D1 : KnotDiagram) :
      SimpStep D0 D0' → SimpStep (.crossing wA wB D0 D1) (.crossing wA wB D0' D1)
  | inRight (wA wB : ℤ) (D0 D1 D1' : KnotDiagram) :
      SimpStep D1 D1' → SimpStep (.crossing wA wB D0 D1) (.crossing wA wB D0 D1')

/-- A diagram is in normal form if no simplification step is possible. -/
def NormalForm (D : KnotDiagram) : Prop := ∀ D', ¬SimpStep D D'

/-! ## Classical Jones (abstract interface for separation) -/

/-- Abstract classical Jones polynomial, represented as a function ℤ → ℤ.
    This is used only for the separation schema — the actual computation is
    not formalized here, only the abstract comparison. -/
def ClassicalJones := ℤ → ℤ

/-- Two diagrams have the same classical Jones polynomial. -/
def sameClassicalJones (D1 D2 : KnotDiagram) (jones : KnotDiagram → ClassicalJones) : Prop :=
  jones D1 = jones D2

/-- Two diagrams have different tropical Jones invariants. -/
def differentTropicalJones (D1 D2 : KnotDiagram) : Prop :=
  ∃ n, tJones D1 n ≠ tJones D2 n

/-- The tropical state-cost profile of a diagram. This is the full tropical Jones
    function viewed as a profile for comparison purposes. -/
def tropicalStateProfile (D : KnotDiagram) : ℤ → WithTop ℤ := tJones D

end KnotDiagram

end TropicalKnotTheory