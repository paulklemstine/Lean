/-
  # Tropical Counterpoint: Core Definitions

  This module defines the basic objects of tropical music theory:
  melodies as integer-valued pitch sequences, vertical and horizontal
  interval costs, and the total cost functional whose zero locus
  characterizes first-species counterpoint.
-/
import Mathlib

open Finset BigOperators

/-! ## Melodies and Intervals -/

/-- A melody of length `n` is a sequence of integer pitches. -/
def Melody (n : ℕ) := Fin n → ℤ

/-- The vertical interval between two voices at position `i`. -/
def verticalInterval {n : ℕ} (u v : Melody n) (i : Fin n) : ℤ := v i - u i

/-! ## Consonance Classification -/

/-- Perfect consonances: unison (0), fifth (7), octave (12). -/
def perfectConsonance (k : ℤ) : Prop := k.natAbs ∈ ({0, 7, 12} : Finset ℕ)

/-- Imperfect consonances: minor third (3), major third (4), minor sixth (8), major sixth (9). -/
def imperfectConsonance (k : ℤ) : Prop := k.natAbs ∈ ({3, 4, 8, 9} : Finset ℕ)

/-- A vertical interval is consonant if it is perfect or imperfect. -/
def consonant (k : ℤ) : Prop := perfectConsonance k ∨ imperfectConsonance k

instance : DecidablePred perfectConsonance := fun k => by
  unfold perfectConsonance; infer_instance

instance : DecidablePred imperfectConsonance := fun k => by
  unfold imperfectConsonance; infer_instance

instance : DecidablePred consonant := fun k => by
  unfold consonant; infer_instance

/-! ## Local Penalty Functions -/

/-- Penalty for a dissonant vertical interval: 1 if dissonant, 0 if consonant. -/
noncomputable def forbiddenVerticalPenalty (k : ℤ) : ℝ :=
  if consonant k then 0 else 1

/-- Penalty for melodic leaps: excess beyond a step of 2 semitones. -/
noncomputable def melodicLeapPenalty (x y : ℤ) : ℝ :=
  max 0 ((Int.natAbs (y - x) : ℝ) - 2)

/-- Penalty for parallel perfect consonances between consecutive positions.
    Returns 1 if both intervals are perfect consonances, 0 otherwise. -/
noncomputable def parallelPerfectPenalty {n : ℕ} (u v : Melody (n + 1)) (i : Fin n) : ℝ :=
  if perfectConsonance (verticalInterval u v ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩) ∧
     perfectConsonance (verticalInterval u v ⟨i.val + 1, Nat.succ_lt_succ i.isLt⟩)
  then 1 else 0

/-! ## Total Cost Functional -/

/-- Total contrapuntal cost of a two-voice composition.
    Sum of vertical penalties + melodic leap penalties + parallel motion penalties. -/
noncomputable def totalCost {n : ℕ} (u v : Melody (n + 1)) : ℝ :=
  (∑ i : Fin (n + 1), forbiddenVerticalPenalty (verticalInterval u v i)) +
  (∑ i : Fin n, melodicLeapPenalty (v ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩)
                                    (v ⟨i.val + 1, Nat.succ_lt_succ i.isLt⟩)) +
  (∑ i : Fin n, parallelPerfectPenalty u v i)

/-! ## First Species Legality -/

/-- A two-voice composition is first-species legal if:
    1. Every vertical interval is consonant,
    2. No two consecutive vertical intervals are both perfect consonances,
    3. The upper voice moves by at most 2 semitones (stepwise motion). -/
def FirstSpeciesLegal {n : ℕ} (u v : Melody (n + 1)) : Prop :=
  (∀ i : Fin (n + 1), consonant (verticalInterval u v i)) ∧
  (∀ i : Fin n, ¬(perfectConsonance (verticalInterval u v ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩) ∧
                   perfectConsonance (verticalInterval u v ⟨i.val + 1, Nat.succ_lt_succ i.isLt⟩))) ∧
  (∀ i : Fin n, (Int.natAbs (v ⟨i.val + 1, Nat.succ_lt_succ i.isLt⟩ -
                              v ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩)) ≤ 2)

/-! ## Weighted Cost Functional -/

/-- Weighted total cost with parameters A (vertical), B (melodic), C (parallel). -/
noncomputable def weightedTotalCost {n : ℕ} (A B C : ℝ) (u v : Melody (n + 1)) : ℝ :=
  A * (∑ i : Fin (n + 1), forbiddenVerticalPenalty (verticalInterval u v i)) +
  B * (∑ i : Fin n, melodicLeapPenalty (v ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩)
                                        (v ⟨i.val + 1, Nat.succ_lt_succ i.isLt⟩)) +
  C * (∑ i : Fin n, parallelPerfectPenalty u v i)

/-! ## Harmonic Variety -/

/-- The set of distinct interval classes used in a two-voice composition. -/
noncomputable def intervalClassSet {n : ℕ} (u v : Melody (n + 1)) : Finset ℤ :=
  (Finset.univ : Finset (Fin (n + 1))).image (fun i => verticalInterval u v i)

/-- Harmonic variety: the number of distinct vertical interval classes. -/
noncomputable def harmonicVariety {n : ℕ} (u v : Melody (n + 1)) : ℕ :=
  (intervalClassSet u v).card

/-! ## Bach Score (Scalarized Multi-Objective) -/

/-- The Bach score balances low contrapuntal cost against high harmonic variety.
    λ > 0 rewards variety; the minimizer is a compromise between strict rules
    and harmonic richness. -/
noncomputable def bachScore {n : ℕ} (lam : ℝ) (u v : Melody (n + 1)) : ℝ :=
  totalCost u v - lam * (harmonicVariety u v : ℝ)

/-! ## Dynamic Programming Definitions -/

/-- Local transition cost in a bounded pitch DP formulation. -/
noncomputable def localTransitionCost (P : ℕ) (cantusCurr cantusNext : ℤ)
    (curr next : Fin P) : ℝ :=
  forbiddenVerticalPenalty ((next : ℤ) - cantusNext) +
  melodicLeapPenalty (curr : ℤ) (next : ℤ) +
  (if perfectConsonance ((curr : ℤ) - cantusCurr) ∧
      perfectConsonance ((next : ℤ) - cantusNext)
   then 1 else 0)

/-- State cost at a DP stage (accumulated cost up to position k). -/
noncomputable def dpStateCost (P : ℕ) (cantus : ℕ → ℤ) : ℕ → Fin P → ℝ
  | 0, x => forbiddenVerticalPenalty ((x : ℤ) - cantus 0)
  | k + 1, x => ⨅ y : Fin P,
      (localTransitionCost P (cantus k) (cantus (k + 1)) y x + dpStateCost P cantus k y)