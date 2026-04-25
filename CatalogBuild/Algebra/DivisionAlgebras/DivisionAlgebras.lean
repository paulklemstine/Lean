/-! # CatalogBuild.Algebra.DivisionAlgebras.DivisionAlgebras

Auto-generated from theorem catalog database.
Domain: Algebra/DivisionAlgebras
Declarations: 16
-/

import Mathlib

/-- The Cayley-Dickson construction. Given a type α with ring and star (conjugation)
operations, construct a new type on α × α with doubled multiplication. -/
structure CayleyDickson (α : Type*) where
  fst : α
  snd : α
  deriving Repr, DecidableEq

namespace CayleyDickson

variable {α : Type*}





/-- Addition in the Cayley-Dickson construction is component-wise. -/
instance [Add α] : Add (CayleyDickson α) where
  add x y := ⟨x.fst + y.fst, x.snd + y.snd⟩





/-- Negation in the Cayley-Dickson construction is component-wise. -/
instance [Neg α] : Neg (CayleyDickson α) where
  neg x := ⟨-x.fst, -x.snd⟩





/-- Zero in the Cayley-Dickson construction. -/
instance [Zero α] : Zero (CayleyDickson α) where
  zero := ⟨0, 0⟩





/-- The Cayley-Dickson multiplication:
(a, b) * (c, d) = (a*c - star(d)*b, d*a + b*star(c)) -/
instance [Ring α] [Star α] : Mul (CayleyDickson α) where
  mul x y := ⟨x.fst * y.fst - Star.star y.snd * x.snd,
              y.snd * x.fst + x.snd * Star.star y.fst⟩





/-- Conjugation in the Cayley-Dickson construction:
star(a, b) = (star(a), -b) -/
instance [Star α] [Neg α] : Star (CayleyDickson α) where
  star x := ⟨Star.star x.fst, -x.snd⟩





/-- One in the Cayley-Dickson construction: (1, 0). -/
instance [One α] [Zero α] : One (CayleyDickson α) where
  one := ⟨1, 0⟩





/-- The "imaginary unit" of the Cayley-Dickson construction: (0, 1). -/
def im [Zero α] [One α] : CayleyDickson α := ⟨0, 1⟩





/-- Type alias: applying Cayley-Dickson to ℝ gives something isomorphic to ℂ. -/
abbrev CD_R := CayleyDickson ℝ





/-- Type alias: applying Cayley-Dickson twice to ℝ gives something isomorphic to ℍ. -/
abbrev CD_C := CayleyDickson CD_R





/-- Type alias: applying Cayley-Dickson three times to ℝ gives the octonions. -/
abbrev CD_H := CayleyDickson CD_C





/-- The associator of three elements in a ring. -/
def algAssociator [Ring α] (a b c : α) : α :=
  (a * b) * c - a * (b * c)





/-- [Section: # CatalogBuild.Algebra.DivisionAlgebras.DivisionAlgebras
Auto-generated from theorem catalog database.
Domain: Algebra/DivisionAlgebras
Declarations: 16] -/
theorem algAssociator_eq_zero [Ring α] (a b c : α) :
    algAssociator a b c = 0 := by
  exact sub_eq_zero_of_eq ( mul_assoc a b c )





/-- The commutator of two elements: [a, b] = a * b - b * a. -/
def algCommutator [Ring α] (a b : α) : α :=
  a * b - b * a





/-- [Section: # CatalogBuild.Algebra.DivisionAlgebras.DivisionAlgebras
Auto-generated from theorem catalog database.
Domain: Algebra/DivisionAlgebras
Declarations: 16] -/
theorem algCommutator_eq_zero [CommRing α] (a b : α) :
    algCommutator a b = 0 := by
  unfold algCommutator; simp +decide [ mul_comm ] ;





/-- The quaternion norm is multiplicative: normSq(pq) = normSq(p) * normSq(q). -/
theorem quaternion_norm_mul (p q : Quaternion ℝ) :
    normSq (p * q) = normSq p * normSq q := by
  grind




