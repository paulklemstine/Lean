/-! # CatalogBuild.EML.BerggrenCompleteness

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 23
-/

import Mathlib

/-- [Section: # CatalogBuild.EML.BerggrenCompleteness
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 23] -/
def IsPT (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2




/-- [Section: # CatalogBuild.EML.BerggrenCompleteness
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 23] -/
def childA (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)



def childB (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)



def childC (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)




theorem childA_pyth (a b c : ℤ) (h : IsPT a b c) :
    let t := childA a b c; IsPT t.1 t.2.1 t.2.2 := by
  unfold IsPT childA at *; nlinarith




theorem childB_pyth (a b c : ℤ) (h : IsPT a b c) :
    let t := childB a b c; IsPT t.1 t.2.1 t.2.2 := by
  unfold IsPT childB at *; nlinarith




theorem childC_pyth (a b c : ℤ) (h : IsPT a b c) :
    let t := childC a b c; IsPT t.1 t.2.1 t.2.2 := by
  unfold IsPT childC at *; nlinarith




inductive BStep where | A | B | C
  deriving Repr, DecidableEq




def applyStep (s : BStep) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  match s with
  | .A => childA t.1 t.2.1 t.2.2
  | .B => childB t.1 t.2.1 t.2.2
  | .C => childC t.1 t.2.1 t.2.2




theorem depth1_A : applyPath [.A] = (5, 12, 13) := by native_decide



theorem depth1_B : applyPath [.B] = (21, 20, 29) := by native_decide



theorem depth1_C : applyPath [.C] = (15, 8, 17) := by native_decide




theorem depth2_AA : applyPath [.A, .A] = (7, 24, 25) := by native_decide

-- B-branch gives exponentially growing hypotenuses



theorem depth2_BB : applyPath [.B, .B] = (119, 120, 169) := by native_decide




theorem depth1_A_pyth : IsPT 5 12 13 := by unfold IsPT; norm_num



theorem depth1_B_pyth : IsPT 21 20 29 := by unfold IsPT; norm_num



theorem depth1_C_pyth : IsPT 15 8 17 := by unfold IsPT; norm_num




theorem pell_check_1 : 6 * 29 - 5 = (169 : ℤ) := by norm_num



theorem pell_check_2 : 6 * 169 - 29 = (985 : ℤ) := by norm_num



theorem pell_check_3 : 6 * 985 - 169 = (5741 : ℤ) := by norm_num




def parentA (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, 2*a + b - 2*c, 2*a + 2*b - 3*c)



def parentB (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b - 2*c, 2*a - b - 2*c, 2*a - 2*b - 3*c)
-- (parentC uses negation)

-- Verify: parentA recovers the root from depth-1-A child (5,12,13)
-- Note: we need absolute values / sign normalization
-- parentA(5,12,13) should give ±(3,4,5)
-- Actually the inverse of M₁ = [[1,-2,2],[2,-1,2],[2,-2,3]] is a specific matrix.
-- Let's verify numerically:



theorem parentA_check :
    let (a, b, c) := parentA 5 12 13
    (|a|, |b|, |c|) = (3, 4, 5) := by native_decide



