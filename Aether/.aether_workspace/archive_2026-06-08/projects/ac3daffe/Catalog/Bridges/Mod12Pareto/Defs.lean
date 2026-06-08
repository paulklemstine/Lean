/-
  Mod-12 Pareto Rigidity: Definitions
  ====================================

  Core definitions for cyclic distance on pitch-class space ZMod 12,
  voice-leading cost, Pareto dominance, and transposition actions.
-/
import Mathlib

open Finset BigOperators

/-- Pitch class: elements of ℤ/12ℤ -/
abbrev pc := ZMod 12

/-- Raw (unsigned mod-12) distance: the residue of a - b in {0,...,11}. -/
def rawDist (a b : pc) : ℕ := (a - b).val

/-- Cyclic distance on ZMod 12: the minimum of the two arc lengths. -/
def cycDist (a b : pc) : ℕ := min (rawDist a b) (12 - rawDist a b)

/-- Voice-leading cost for n-voice configurations: sum of pairwise cyclic distances. -/
def voiceLeadCost (n : ℕ) (x y : Fin n → pc) : ℕ :=
  ∑ i, cycDist (x i) (y i)

/-- Transpose a configuration by adding a constant pitch class. -/
def transposeConfig (n : ℕ) (t : pc) (x : Fin n → pc) : Fin n → pc :=
  fun i => x i + t

/-- z Pareto-dominates y as a voice leading from x: every voice is weakly closer,
    and at least one voice is strictly closer. -/
def Dominates (n : ℕ) (x y z : Fin n → pc) : Prop :=
  (∀ i, cycDist (x i) (z i) ≤ cycDist (x i) (y i)) ∧
  (∃ j, cycDist (x j) (z j) < cycDist (x j) (y j))

/-- A voice leading from x to y is Pareto-minimal if no alternative z dominates y. -/
def ParetoMinimal (n : ℕ) (x y : Fin n → pc) : Prop :=
  ¬ ∃ z : Fin n → pc, Dominates n x y z

/-- Normalize a 3-voice configuration by subtracting the first voice's pitch class. -/
def normalizeConfig3 (x : Fin 3 → pc) : Fin 3 → pc :=
  fun i => x i - x 0