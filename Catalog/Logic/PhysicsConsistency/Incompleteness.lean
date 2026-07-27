import Logic.ProofSystemCollapse

/-!
# Abstract consistency and second incompleteness interface

This file supplies the minimal proof-theoretic interface used by finite
consistency-reflection towers.  A tagged formula language has consistency
sentences `Con i`; a GL theory is one for which consistency rules out proving
its matching consistency sentence.
-/

namespace PhysicsConsistency

open ProofSystemCollapse

/-- Formulas used by the abstract tagged consistency theories. -/
inductive Form where
  | atom : ℕ → Form
  | Con : ℕ → Form
  deriving DecidableEq

open Form

/-- A proof system is consistent when it does not prove every formula. -/
def Consistent (S : ProofSys Form) : Prop := ∃ f, ¬ Provable S f

/-- The local GL condition at tag `i`: consistency prevents a proof of `Con i`. -/
def IsGLTheory (i : ℕ) (S : ProofSys Form) : Prop :=
  Consistent S → ¬ Provable S (Con i)

/-- The abstract second-incompleteness consequence encoded by `IsGLTheory`. -/
theorem goedel_two {i : ℕ} {S : ProofSys Form}
    (hGL : IsGLTheory i S) (hc : Consistent S) : ¬ Provable S (Con i) :=
  hGL hc

/-- A concrete system with no proofs. -/
def stdSys : ProofSys Form where
  Proof := Empty
  concl := Empty.elim
  size := Empty.elim

/-- The proof-free standard system is consistent. -/
theorem consistent_stdSys : Consistent stdSys := by
  refine ⟨Form.atom 0, ?_⟩
  rintro ⟨p, _⟩
  exact Empty.elim p

/-- The proof-free standard system satisfies every tagged GL condition. -/
theorem isGL_stdSys (i : ℕ) : IsGLTheory i stdSys := by
  intro _
  rintro ⟨p, _⟩
  exact Empty.elim p

end PhysicsConsistency