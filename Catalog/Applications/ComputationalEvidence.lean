import Mathlib

/-! # Computational evidence for finite-state identity

Small explicit Moore machines exercise the behavioural definition on representative cases.
The first machine records parity of `true` inputs.  The second is permanently false.  The
third has redundant physical states but the same observations as the second.  There is no
relevant integer sequence, so an OEIS search is inapplicable.
-/

namespace LifeboxEvidence

/-- Minimal self-contained finite Moore machine used for the checks. -/
structure Machine (Input State Output : Type*) where
  step : State → Input → State
  observe : State → Output

def Machine.runFrom {I S O : Type*} (M : Machine I S O) (s : S) (w : List I) : S :=
  w.foldl M.step s

def TraceEquiv {I S T O : Type*} (M : Machine I S O) (N : Machine I T O)
    (s : S) (t : T) : Prop :=
  ∀ w, M.observe (M.runFrom s w) = N.observe (N.runFrom t w)

/-- A two-state parity observer. -/
def parityPerson : Machine Bool Bool Bool where
  step s a := xor s a
  observe s := s

/-- A one-state observer that always emits false. -/
def silentPerson : Machine Bool Unit Bool where
  step _ _ := ()
  observe _ := false

/-- A physically different two-state implementation whose output is always false. -/
def redundantSilent : Machine Bool Bool Bool where
  step s a := xor s a
  observe _ := false

/-- Small-case table: outputs of parity on four representative histories. -/
example :
    [ parityPerson.observe (parityPerson.runFrom false []),
      parityPerson.observe (parityPerson.runFrom false [true]),
      parityPerson.observe (parityPerson.runFrom false [true, true]),
      parityPerson.observe (parityPerson.runFrom false [true, false, true]) ] =
    [false, true, false, false] := by
  decide

/-- Counterexample hunt: a one-symbol history refutes the universal equivalence claim. -/
theorem parity_not_silent : ¬ TraceEquiv parityPerson silentPerson false () := by
  intro h
  have hbad := h [true]
  norm_num [parityPerson, silentPerson, Machine.runFrom] at hbad

/-- Positive case: distinct physical state spaces can have identical behaviour. -/
theorem redundant_silent_equiv : TraceEquiv redundantSilent silentPerson false () := by
  intro w
  rfl

end LifeboxEvidence