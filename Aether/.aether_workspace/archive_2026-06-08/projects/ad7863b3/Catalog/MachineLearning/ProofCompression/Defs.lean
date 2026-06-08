import Mathlib

/-!
# Proof Compression Phase Transitions: Core Definitions

This module defines the mathematical framework for studying proof compression
thresholds — the phenomenon where automation without intermediate lemma invention
catastrophically fails beyond a critical complexity threshold.

## Main definitions

* `CompressionInstance` — a theorem family with semantic complexity and two cost measures
* `HasAsymptoticGap` — the compression ratio is unbounded along a family
* `HasThreshold` — there is a critical complexity below which automation is within
  constant factor, and above which it diverges
* `Phase` — classification of theorem instances by predicted proof regime
* `subsetExpansionInstance` — the canonical example: powerset expansion
* `augmentedSubsetExpansion` — the same family after adding an inductive basis lemma

## Mathematical context

Human proofs with reusable lemmas behave like DAG circuits with shared subcomputations;
naive automation behaves like tree-shaped formulas without sharing. The powerset expansion
identity `∏ (1 + f_i) = ∑_{S ⊆ [n]} ∏_{i ∈ S} f_i` is the canonical example:
the inductive proof costs O(n), while naive expansion produces 2^n terms.
-/

/-- A compression instance models a family of theorems equipped with:
- `semanticComplexity`: a measure of structural complexity (e.g., number of variables)
- `humanCost`: proof cost using structured reasoning with reusable lemmas
- `autoCost`: proof cost using naive automation without lemma invention -/
structure CompressionInstance where
  theorem_id : Type
  semanticComplexity : theorem_id → ℕ
  humanCost : theorem_id → ℕ
  autoCost : theorem_id → ℕ

/-- The compression ratio at a theorem instance, measuring how much more expensive
automation is relative to structured human proofs. -/
def compressionRatio (I : CompressionInstance) (t : I.theorem_id) : ℚ :=
  (I.autoCost t : ℚ) / max 1 (I.humanCost t : ℚ)

/-- A theorem family `T : ℕ → theorem_id` has an asymptotic gap if the compression
ratio is unbounded: for any constant K, there exists an instance where automation
costs more than K times the structured proof cost. -/
def HasAsymptoticGap (I : CompressionInstance) (T : ℕ → I.theorem_id) : Prop :=
  ∀ K : ℕ, ∃ n : ℕ, K * I.humanCost (T n) < I.autoCost (T n)

/-- A compression instance has a threshold at complexity `c` if:
1. Below threshold: automation cost is within constant factor of human cost
2. Above threshold: no constant factor suffices -/
def HasThreshold (I : CompressionInstance) (c : ℕ) : Prop :=
  (∃ C : ℕ, ∀ t, I.semanticComplexity t ≤ c → I.autoCost t ≤ C * I.humanCost t) ∧
  (∀ K : ℕ, ∃ t, c < I.semanticComplexity t ∧ K * I.humanCost t < I.autoCost t)

/-- Phase classification for the algorithmic component.
Theorem instances are classified as tractable (automation suffices),
transitional (near the threshold), or intractable (lemma invention required). -/
inductive Phase where
  | tractable : Phase
  | transitional : Phase
  | intractable : Phase
  deriving DecidableEq, Repr

/-- Numerical index of a phase, for monotonicity statements. -/
def Phase.index : Phase → ℕ
  | .tractable => 0
  | .transitional => 1
  | .intractable => 2

/-- Complexity scoring function: identity on ℕ (semantic complexity = parameter). -/
def complexityScore (n : ℕ) : ℕ := n

/-- Phase prediction given a threshold parameter.
Below threshold: tractable. Up to 2× threshold: transitional. Above: intractable. -/
def predictedPhase (threshold : ℕ) (n : ℕ) : Phase :=
  if n ≤ threshold then Phase.tractable
  else if n ≤ 2 * threshold then Phase.transitional
  else Phase.intractable

/-- The subset expansion compression instance.
Models the theorem family `∏ᵢ (1 + fᵢ) = ∑_{S} ∏_{i∈S} fᵢ` where:
- semantic complexity is the number of factors n
- human cost is n + 1 (one induction step per element)
- automation cost is 2^n (one term per subset in the powerset expansion) -/
def subsetExpansionInstance : CompressionInstance where
  theorem_id := ℕ
  semanticComplexity := id
  humanCost := fun n => n + 1
  autoCost := fun n => 2 ^ n

/-- The augmented subset expansion instance, modeling automation after adding
the key inductive lemma `∏ (1 + f_i) = ∑ ∏ f_j` as a reusable basis lemma.
With this lemma, each step reduces to one application, giving linear cost. -/
def augmentedSubsetExpansion : CompressionInstance where
  theorem_id := ℕ
  semanticComplexity := id
  humanCost := fun n => n + 1
  autoCost := fun n => n + 1

/-- A second compression instance modeling telescoping/geometric sum identities.
The family `(x-1) * ∑ x^i = x^n - 1`:
- human cost is linear (one induction step per n)
- automation cost models naive expansion of the product-sum -/
def telescopingInstance : CompressionInstance where
  theorem_id := ℕ
  semanticComplexity := id
  humanCost := fun n => n + 1
  autoCost := fun n => n * n + 1

/-- Augmented telescoping instance after adding the telescoping lemma as a basis. -/
def augmentedTelescopingInstance : CompressionInstance where
  theorem_id := ℕ
  semanticComplexity := id
  humanCost := fun n => n + 1
  autoCost := fun n => n + 1