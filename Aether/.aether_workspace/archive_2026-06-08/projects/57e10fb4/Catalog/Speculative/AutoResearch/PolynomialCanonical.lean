import Mathlib

open scoped BigOperators

structure TropMonomial (ι : Type) where
  coeff : ℚ
  expo  : ι →₀ ℕ
  deriving DecidableEq

structure TropPolynomial (ι : Type) where
  terms : List (TropMonomial ι)

def TropMonomial.eval {ι : Type} [Fintype ι] (m : TropMonomial ι) (x : ι → ℚ) : ℚ :=
  m.coeff + ∑ i, (m.expo i : ℚ) * x i

def TropPolynomial.eval {ι : Type} [Fintype ι]
    (p : TropPolynomial ι) (x : ι → ℚ) : WithTop ℚ :=
  (p.terms.map (fun m => (m.eval x : WithTop ℚ))).foldr min ⊤

def TropPolynomial.SemEq {ι : Type} [Fintype ι]
    (p q : TropPolynomial ι) : Prop :=
  ∀ x, p.eval x = q.eval x

def Dominated {ι : Type} [Fintype ι] (p : TropPolynomial ι) (m : TropMonomial ι) : Prop :=
  ∀ x, p.eval x ≤ m.eval x

-- To make canonicalization work, we first merge duplicate exponents.
def mergeDuplicates {ι : Type} [DecidableEq ι] (terms : List (TropMonomial ι)) : List (TropMonomial ι) :=
  -- keep the one with smallest coeff for each expo
  sorry

def TropPolynomial.Canonical {ι : Type} [DecidableEq ι] [Fintype ι]
    (p : TropPolynomial ι) : TropPolynomial ι :=
  sorry

theorem remove_dominated_preserves_eval
    {ι : Type} [Fintype ι] [DecidableEq ι] [LinearOrder ι]
    (p : TropPolynomial ι) (m : TropMonomial ι)
    (hdom : Dominated p m) :
    SemEq ⟨p.terms.filter (fun x => x ≠ m)⟩ p := by
  sorry