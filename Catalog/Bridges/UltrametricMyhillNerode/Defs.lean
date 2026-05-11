import Mathlib

/-!
# Ultrametric Myhill–Nerode: Core Definitions

This file defines the foundational structures for non-Archimedean neural minimization:
ultrametric neural systems, word evaluation, and approximate observational equivalence.

## Main Definitions

* `UltrametricNeuralSystem` — state transition system with ultrametric state and output spaces
* `ContractiveUNS` — contractive variant with contraction ratio c ∈ [0,1)
* `evalWord` — iterated transition along a word (list of actions)
* `ObsEqK` — k-step approximate observational equivalence
* `ObsEqInf` — full approximate observational equivalence
-/

noncomputable section

open Function

/-! ## Core Structures -/

/-- An ultrametric neural system: states `X` with ultrametric pseudometric `dX`,
    outputs `Y` with ultrametric pseudometric `dY`, transitions `T : A → X → X`,
    and output map `o : X → Y`. Each transition is nonexpanding.

    Both metrics are ultrametric, which is the key non-Archimedean hypothesis
    ensuring observational equivalence classes are topologically rigid. -/
structure UltrametricNeuralSystem (A X Y : Type*) where
  dX : X → X → ℝ
  dY : Y → Y → ℝ
  T : A → X → X
  o : X → Y
  dX_nonneg : ∀ x y, 0 ≤ dX x y
  dY_nonneg : ∀ u v, 0 ≤ dY u v
  dX_self : ∀ x, dX x x = 0
  dY_self : ∀ y, dY y y = 0
  dX_symm : ∀ x y, dX x y = dX y x
  dY_symm : ∀ u v, dY u v = dY v u
  dX_ultra : ∀ x y z, dX x z ≤ max (dX x y) (dX y z)
  dY_ultra : ∀ u v w, dY u w ≤ max (dY u v) (dY v w)
  nonexpanding : ∀ a x y, dX (T a x) (T a y) ≤ dX x y

/-- A contractive ultrametric neural system with contraction ratio `c ∈ [0,1)`
    and `L`-Lipschitz output map. -/
structure ContractiveUNS (A X Y : Type*) extends UltrametricNeuralSystem A X Y where
  c : ℝ
  L : ℝ
  hc_nonneg : 0 ≤ c
  hc_lt_one : c < 1
  contractive : ∀ a x y, dX (T a x) (T a y) ≤ c * dX x y
  hL_nonneg : 0 ≤ L
  o_lipschitz : ∀ x y, dY (o x) (o y) ≤ L * dX x y

/-! ## Word Evaluation -/

/-- Evaluate a word (list of actions) on a state by iterated transition.
    `evalWord T [a₁, a₂, a₃] x = T a₃ (T a₂ (T a₁ x))`. -/
def evalWord {A X : Type*} (T : A → X → X) : List A → X → X
  | [], x => x
  | a :: w, x => evalWord T w (T a x)

@[simp] theorem evalWord_nil {A X : Type*} (T : A → X → X) (x : X) :
    evalWord T [] x = x := rfl

@[simp] theorem evalWord_cons {A X : Type*} (T : A → X → X) (a : A) (w : List A) (x : X) :
    evalWord T (a :: w) x = evalWord T w (T a x) := rfl

/-! ## Observational Equivalence -/

/-- **Full observational equivalence up to tolerance ε**:
    Two states are equivalent iff all finite-horizon observations are within ε. -/
def ObsEqInf {A X Y : Type*} (S : UltrametricNeuralSystem A X Y) (ε : ℝ)
    (x y : X) : Prop :=
  ∀ w : List A, S.dY (S.o (evalWord S.T w x)) (S.o (evalWord S.T w y)) ≤ ε

/-- **k-step observational equivalence up to tolerance ε**:
    Observations agree up to ε for all words of length at most k. -/
def ObsEqK {A X Y : Type*} (S : UltrametricNeuralSystem A X Y) (ε : ℝ)
    (k : ℕ) (x y : X) : Prop :=
  ∀ w : List A, w.length ≤ k →
    S.dY (S.o (evalWord S.T w x)) (S.o (evalWord S.T w y)) ≤ ε

end