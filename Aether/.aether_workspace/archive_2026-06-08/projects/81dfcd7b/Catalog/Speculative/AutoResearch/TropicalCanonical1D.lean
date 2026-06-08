import Mathlib

structure TropMonomial where
  coeff : ℚ
  slope : ℕ
  deriving DecidableEq, Repr, Inhabited

structure TropPolynomial where
  terms : List TropMonomial
  deriving DecidableEq, Repr, Inhabited

def TropMonomial.eval (m : TropMonomial) (x : ℚ) : ℚ :=
  m.coeff + (m.slope : ℚ) * x

def TropPolynomial.eval (p : TropPolynomial) (x : ℚ) : WithTop ℚ :=
  (p.terms.map (fun m => (m.eval x : WithTop ℚ))).foldr min ⊤

def TropPolynomial.SemEq (p q : TropPolynomial) : Prop :=
  ∀ x, p.eval x = q.eval x

def Dominated (p : TropPolynomial) (m : TropMonomial) : Prop :=
  ∀ x, p.eval x ≤ m.eval x

-- Computable univariate canonical form
def mergeDuplicates (terms : List TropMonomial) : List TropMonomial :=
  -- sort by slope, then keep minimum coeff
  sorry