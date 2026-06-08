/-
  Quantum Random Walks on Cayley Graphs: Definitions

  Novel definitions for Cayley graphs, transition matrices,
  spectral gap data, and quantum walk mixing times.
-/
import Mathlib

open Finset BigOperators Matrix Real

noncomputable section

/-! ## Cayley Graph Definition -/

/-- The Cayley graph of a group G with generating set S.
    Two elements g, h are adjacent iff g⁻¹ * h ∈ S.
    This requires S to be symmetric and not contain the identity
    for the graph to be well-defined (undirected, no self-loops). -/
def cayleyAdj {G : Type*} [Group G] (S : Set G) (g h : G) : Prop :=
  g⁻¹ * h ∈ S

/-- A generating set S is symmetric if s ∈ S implies s⁻¹ ∈ S. -/
def IsSymmGenSet {G : Type*} [Group G] (S : Set G) : Prop :=
  ∀ s ∈ S, s⁻¹ ∈ S

/-
The Cayley adjacency relation is symmetric when S is symmetric.
-/
theorem cayleyAdj_symm {G : Type*} [Group G] (S : Set G) (hS : IsSymmGenSet S) :
    ∀ g h : G, cayleyAdj S g h → cayleyAdj S h g := by
  intro g h hgh;
  exact hS _ hgh |> fun hgh' => by simpa using hgh'

/-- The normalized transition matrix of the Cayley graph random walk.
    T(g,h) = 1/|S| if g⁻¹h ∈ S, else 0. -/
def cayleyTransition {G : Type*} [Group G] [DecidableEq G] [Fintype G]
    (S : Finset G) : Matrix G G ℝ :=
  fun g h => if g⁻¹ * h ∈ S then (1 : ℝ) / S.card else 0

/-! ## Spectral Gap -/

/-- The spectral gap of a stochastic matrix, as an abstract parameter
    satisfying positivity and boundedness. -/
structure SpectralGapData where
  /-- The spectral gap γ = 1 - |λ₂| -/
  gap : ℝ
  /-- The spectral gap is positive -/
  gap_pos : gap > 0
  /-- The spectral gap is at most 1 -/
  gap_le_one : gap ≤ 1

/-! ## Mixing Time Definitions -/

/-- Classical mixing time bound: τ_classical = (1/γ) · log(N/ε).
    This is the standard upper bound from Markov chain spectral theory. -/
def classicalMixBound (N : ℕ) (γ ε : ℝ) : ℝ :=
  (1 / γ) * (Real.log N + Real.log (1 / ε))

/-- Quantum mixing time bound: τ_quantum = √(1/γ) · log(N/ε).
    This captures the quadratic speedup of quantum walks. -/
def quantumMixBound (N : ℕ) (γ ε : ℝ) : ℝ :=
  Real.sqrt (1 / γ) * (Real.log N + Real.log (1 / ε))

/-- The quantum-classical mixing ratio: the factor by which quantum
    walks are faster than classical walks. -/
def mixingSpeedupRatio (N : ℕ) (γ ε : ℝ) : ℝ :=
  classicalMixBound N γ ε / quantumMixBound N γ ε

/-! ## Quantum Walk State -/

/-- A quantum walk state on a finite group G is a function G → ℂ
    (i.e., an element of l²(G)). The probability of measuring g
    is |ψ(g)|². -/
def QuantumWalkState (G : Type*) := G → ℂ

/-- The probability of measuring group element g in state ψ. -/
def measureProb {G : Type*} (ψ : QuantumWalkState G) (g : G) : ℝ :=
  Complex.normSq (ψ g)

/-- Total variation distance between two probability distributions
    on a finite group. -/
def totalVariation {G : Type*} [Fintype G] (p q : G → ℝ) : ℝ :=
  (1 / 2) * ∑ g : G, |p g - q g|

/-- The uniform distribution on a finite group. -/
def uniformDist (G : Type*) [Fintype G] (_g : G) : ℝ :=
  1 / (Fintype.card G : ℝ)

end