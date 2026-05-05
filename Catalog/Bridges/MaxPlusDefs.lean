import Mathlib

/-!
# Max-Plus Algebra: Core Definitions

This file establishes the foundational definitions for finite-dimensional max-plus
(tropical) linear algebra over real-weighted matrices.

## Main definitions

* `maxPlusMul` - tropical matrix-vector multiplication
* `tropicalMatMul` - tropical matrix-matrix multiplication
* `tropicalMatPow` - iterated tropical matrix powers
* `walkWeight` - weight of a directed walk in the weighted complete digraph
* `cycleMean` - average weight per edge in a cycle
* `maxCycleMeanOfLength` - max cycle mean over cycles of a given length
* `maxCycleMean` - the maximal cycle mean (= tropical spectral radius)
* `maxEntry` - maximum entry of a matrix

## Overview

We work with `Fin n → Fin n → ℝ` matrices representing the weight function of a
complete weighted digraph on `n` vertices. In this model every edge is present
(with possibly negative weight), so every matrix is trivially strongly connected.
The "irreducibility" condition is therefore automatic over `ℝ` and becomes
non-trivial only when one moves to `WithBot ℝ` (where `-∞` means "no edge").
-/

noncomputable section

open Finset BigOperators

variable {n : ℕ}

/-! ### Max-plus matrix operations -/

/-- Max-plus matrix-vector multiplication: `(M ⊗ x)_i = max_j (M_i_j + x_j)`. -/
def maxPlusMul (M : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) (hn : 0 < n) :
    Fin n → ℝ :=
  fun i => Finset.univ.sup' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun j => M i j + x j)

/-- Tropical matrix-matrix multiplication: `(A ⊗ B)_ij = max_k (A_ik + B_kj)`. -/
def tropicalMatMul (hn : 0 < n) (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => Finset.univ.sup' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun k => A i k + B k j)

/-- Tropical identity matrix: diagonal entries are 0, off-diagonal are... also 0.
    Over `ℝ` (not `WithBot ℝ`), the true tropical identity would need `-∞`
    off the diagonal. For our purposes, we use the all-zeros matrix as the
    identity for `tropicalMatPow 0`. -/
def tropicalId : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => if i = j then 0 else 0

/-- Tropical matrix power by repeated multiplication. -/
def tropicalMatPow (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) :
    ℕ → Matrix (Fin n) (Fin n) ℝ
  | 0 => fun _i _j => 0
  | k + 1 => tropicalMatMul hn M (tropicalMatPow hn M k)

/-- Maximum entry of a matrix over `Fin n × Fin n`. -/
def maxEntry (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.univ.sup' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
    (fun i => Finset.univ.sup' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun j => M i j))

/-! ### Directed walks and cycles -/

/-- Weight of a directed walk given as a list of vertices.
    For `[v₀, v₁, ..., vₖ]`, the weight is `M v₀ v₁ + M v₁ v₂ + ... + M vₖ₋₁ vₖ`. -/
def walkWeight (M : Matrix (Fin n) (Fin n) ℝ) : List (Fin n) → ℝ
  | [] => 0
  | [_] => 0
  | a :: b :: rest => M a b + walkWeight M (b :: rest)

/-- A list represents a directed cycle if it has at least 2 elements and the
    first element equals the last (the cycle closes). -/
def IsSimpleCycle (c : List (Fin n)) : Prop :=
  c.length ≥ 2 ∧ c.getLast? = c.head?

/-- Weight of a cycle. -/
def cycleWeight (M : Matrix (Fin n) (Fin n) ℝ) (c : List (Fin n)) : ℝ :=
  walkWeight M c

/-- Mean weight of a cycle: total weight / number of edges.
    A cycle `[v₀, v₁, ..., vₖ₋₁, v₀]` has k edges and k+1 list elements. -/
def cycleMean (M : Matrix (Fin n) (Fin n) ℝ) (c : List (Fin n)) : ℝ :=
  cycleWeight M c / (c.length - 1 : ℝ)

/-! ### Maximal cycle mean -/

/-- The set of all cycle means for cycles of length between 2 and `bound+1`
    (i.e., 1 to `bound` edges). -/
def cycleMeanSet (M : Matrix (Fin n) (Fin n) ℝ) (bound : ℕ) : Set ℝ :=
  { μ : ℝ | ∃ c : List (Fin n), IsSimpleCycle c ∧ c.length ≤ bound + 1 ∧ μ = cycleMean M c }

/-- The maximal cycle mean: maximum of `cycleMean M c` over all directed cycles.
    For an `n × n` matrix over ℝ in a complete digraph, it suffices to check
    cycles of length at most `n + 1` (i.e., at most `n` edges). -/
def maxCycleMean (M : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  sSup (cycleMeanSet M n)

/-! ### Computable max cycle mean via enumeration

For a concrete algorithm, we enumerate all cycles up to length n+1 and
compute the maximum cycle mean. This avoids the `sSup` abstraction.
-/

/-- All lists of `Fin n` of a given length. -/
def allFinLists (n : ℕ) : ℕ → Finset (List (Fin n))
  | 0 => {[]}
  | k + 1 => (Finset.univ ×ˢ allFinLists n k).image (fun p => p.1 :: p.2)

/-- Check if a list forms a directed cycle (decidable version). -/
def isDirectedCycleBool {n : ℕ} (c : List (Fin n)) : Bool :=
  c.length ≥ 2 ∧ c.getLast? = c.head?

/-- All directed cycles of a given length as a Finset. -/
def allCyclesOfLength (n len : ℕ) : Finset (List (Fin n)) :=
  (allFinLists n len).filter (fun c => isDirectedCycleBool c)

/-- Compute max cycle mean over cycles of length exactly `len`. Returns 0 if no cycles exist. -/
def maxCycleMeanOfLength (M : Matrix (Fin n) (Fin n) ℝ) (len : ℕ) : ℝ :=
  if h : (allCyclesOfLength n len).Nonempty then
    (allCyclesOfLength n len).sup' h (fun c => cycleMean M c)
  else 0

/-- Computable maximal cycle mean: maximum over cycle lengths 2 to n+1. -/
def computeMaxCycleMean (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.sup' (Finset.Icc 2 (n + 1))
    ⟨2, Finset.mem_Icc.mpr ⟨le_refl 2, by omega⟩⟩
    (fun len => maxCycleMeanOfLength M len)

/-! ### Irreducibility -/

/-- Over `ℝ`, a matrix is trivially irreducible since all edges exist with
    finite weight in the complete weighted digraph. We define it as a Prop
    that is always true for `ℝ`-matrices. For the `WithBot ℝ` version,
    see `IrreducibleWB`. -/
def IrreducibleR (_M : Matrix (Fin n) (Fin n) ℝ) : Prop := True

/-! ### Spectral radius via asymptotic growth -/

/-- The bounded-defect linear growth property: tropical matrix power entries
    grow linearly with slope equal to the maximal cycle mean, up to a
    bounded additive error. -/
def BoundedDefectGrowth (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ)
    (lam : ℝ) : Prop :=
  ∃ C : ℝ, ∀ k : ℕ, 1 ≤ k →
    k * lam - C ≤ maxEntry hn (tropicalMatPow hn M k) ∧
    maxEntry hn (tropicalMatPow hn M k) ≤ k * lam + C

end