/-
# Persistent Homology of Prime Numbers: Definitions

This module defines the core structures for studying the topology of the
prime number sequence through the lens of persistent homology. We model
the primes as a point cloud in ℕ and study how the Rips filtration
(ε-neighborhood graph) evolves as the scale parameter ε increases.

## Main Definitions

* `EpsAdj` - ε-adjacency relation on naturals
* `EpsChain` - ε-connectivity via chains in a set
* `BarcodeInterval` - Birth-death pairs encoding H₀ persistent homology
-/

import Mathlib

open Nat Finset

/-! ## Prime Utilities -/

/-- The set of primes below N as a Finset -/
def primeSetBelow (N : ℕ) : Finset ℕ :=
  (Finset.range N).filter Nat.Prime

/-- primesBelow is monotone -/
theorem primeSetBelow_mono {M N : ℕ} (h : M ≤ N) : primeSetBelow M ⊆ primeSetBelow N := by
  intro x hx
  simp only [primeSetBelow, Finset.mem_filter, Finset.mem_range] at hx ⊢
  exact ⟨Nat.lt_of_lt_of_le hx.1 h, hx.2⟩

/-! ## Rips Filtration -/

/-- The natural number distance (absolute difference) -/
def natDist (a b : ℕ) : ℕ :=
  if a ≤ b then b - a else a - b

/-- Two natural numbers are ε-adjacent if their distance is at most ε and they are distinct -/
def EpsAdj (eps : ℕ) (a b : ℕ) : Prop :=
  a ≠ b ∧ natDist a b ≤ eps

instance (eps a b : ℕ) : Decidable (EpsAdj eps a b) := by
  unfold EpsAdj natDist; exact instDecidableAnd

/-- An ε-chain in a set S is a sequence of elements where consecutive
    elements are ε-adjacent and all belong to S -/
inductive EpsChain (S : Set ℕ) (eps : ℕ) : ℕ → ℕ → Prop where
  | refl (a : ℕ) (ha : a ∈ S) : EpsChain S eps a a
  | step (a b c : ℕ) (ha : a ∈ S) (hb : b ∈ S)
    (hadj : EpsAdj eps a b) (hbc : EpsChain S eps b c) :
    EpsChain S eps a c

/-- Two elements are ε-connected in S if there exists an ε-chain between them -/
def EpsConnected (S : Set ℕ) (eps : ℕ) (a b : ℕ) : Prop :=
  EpsChain S eps a b

/-! ## Gap Barcode Structure (Novel Definition)

This is our main novel formalization: we encode H₀ persistent homology of a
1-dimensional point cloud directly as a sequence of gap values, bypassing
the full simplicial complex machinery. For a 1D point cloud, the H₀ barcode
is completely determined by the sorted gaps between consecutive points. -/

/-- A barcode interval represents a topological feature that is born at
    scale `birth` and dies at scale `death`. -/
structure BarcodeInterval where
  birth : ℕ
  death : ℕ  -- 0 encodes infinite persistence (the essential class)

/-- The persistence (lifetime) of a barcode interval -/
def BarcodeInterval.persistence (b : BarcodeInterval) : ℕ :=
  if b.death = 0 then 0
  else b.death - b.birth

/-- Compute gaps between sorted list elements -/
def listGaps : List ℕ → List ℕ
  | [] => []
  | [_] => []
  | a :: b :: rest => (b - a) :: listGaps (b :: rest)

/-- The H₀ barcode of the prime point cloud up to N.
    Each bar corresponds to a prime gap: birth = 0, death = gap size. -/
def primeH0Barcode (N : ℕ) : List BarcodeInterval :=
  let primes := (primeSetBelow N).sort (· ≤ ·)
  let gaps := listGaps primes
  -- Essential class
  ⟨0, 0⟩ ::
  -- One bar per gap, dying at the gap value
  gaps.map fun g => ⟨0, g⟩

/-- Maximum finite persistence in a barcode -/
def maxFinitePersistence (bars : List BarcodeInterval) : ℕ :=
  (bars.filter (·.death ≠ 0)).foldl (fun acc b => max acc b.persistence) 0

/-! ## Metric Structure -/

/-- natDist is symmetric -/
theorem natDist_symm (a b : ℕ) : natDist a b = natDist b a := by
  simp only [natDist]
  split <;> split <;> omega

/-- natDist satisfies the identity of indiscernibles -/
theorem natDist_eq_zero_iff (a b : ℕ) : natDist a b = 0 ↔ a = b := by
  simp only [natDist]
  split <;> omega

/-- natDist satisfies the triangle inequality -/
theorem natDist_triangle (a b c : ℕ) :
    natDist a c ≤ natDist a b + natDist b c := by
  simp only [natDist]
  split <;> split <;> split <;> omega