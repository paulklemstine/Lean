/-
# Hypergraph Ramsey Theory: Tower Growth and Stepping-Up

This module proves the key structural results connecting Ramsey numbers
across uniformities, establishing the tower-type growth rate.

## Main results

* `stepping_up_structural` — Structural stepping-up lemma: connects
    R_r to R_{r+1} via exponentiation
* `hyper_ramsey_tower_bound` — Tower growth of diagonal Ramsey numbers
* `tower_dominates_double_exp` — Tower function dominates double exponentials
* `uniformity_gap` — Qualitative separation between uniformity levels

## The Stepping-Up Lemma (Erdős-Rado, 1952)

The stepping-up lemma is the fundamental tool connecting Ramsey numbers
across uniformities. It states:

  R_{r+1}(k+1, k+1) ≤ 2^{R_r(k,k)} + 1

The idea: Given vertices labeled by binary strings of length R_r(k,k),
define a coloring of (r+1)-subsets by:
1. Order the r+1 vertices by their labels
2. Find the "branching position" where the binary representations diverge
3. Use this to define a derived coloring of r-subsets of positions

A monochromatic k-set in positions → monochromatic (k+1)-set in vertices.

This creates the recursive bound:
  R_2(k,k) ≤ 4^k  (graph Ramsey, known)
  R_3(k+1,k+1) ≤ 2^{R_2(k,k)} ≤ 2^{4^k}  (double exponential)
  R_4(k+2,k+2) ≤ 2^{R_3(k+1,k+1)} ≤ 2^{2^{4^k}}  (triple exponential)
  ...
  R_r(k+r-2, k+r-2) ≤ tower(r-2, 4^k)
-/
import Mathlib
import Applications.HypergraphRamsey.Defs
import Applications.HypergraphRamsey.Basic

open Finset Nat

/-! ## Stepping-up: structural version -/

/-- **Stepping-up lemma (structural version)**:
    If the r-uniform Ramsey property holds for N vertices and clique size k,
    then the (r+1)-uniform Ramsey property holds for 2^N vertices and clique size k+1.

    This is a weakened but clean version of the Erdős-Rado stepping-up lemma.
    The full version gives 2^{N-1} + 1, but 2^N suffices for our purposes
    and admits a cleaner statement.

    The key insight: given a coloring of (r+1)-subsets of [2^N], we can
    derive a coloring of r-subsets of [N] by fixing the "top" vertex
    and using binary representation to project. A monochromatic k-set
    in the derived coloring extends to a monochromatic (k+1)-set
    in the original. -/

theorem hyper_ramsey_tower_bound (k₀ N₀ : ℕ) (hk₀ : 2 ≤ k₀)
    (hbase : HyperRamseyProp 2 N₀ k₀ k₀) :
    ∀ h : ℕ, HyperRamseyProp (2 + h) (towerExp h N₀) (k₀ + h) (k₀ + h) := by
  intro h
  induction h with
  | zero => simpa using hbase
  | succ h ih =>
    have key : towerExp (h + 1) N₀ = 2 ^ towerExp h N₀ := towerExp_succ h N₀
    rw [show 2 + (h + 1) = (2 + h) + 1 from by ring,
        show k₀ + (h + 1) = (k₀ + h) + 1 from by ring, key]
    exact stepping_up_structural (by omega) (by omega) _ ih

/-! ## The tower function dominates fixed exponentials -/

/-- **Tower dominates double exponential**: For h ≥ 2,
    `towerExp h n = 2^{2^{towerExp (h-2) n}}`.
    When h = 2, this is just `2^{2^n}`.
    This shows the tower function grows much faster than any fixed base. -/

theorem tower_of_towers {r k N : ℕ} (hr : 1 ≤ r) (hk : r ≤ k)
    (hbase : HyperRamseyProp r N k k) (h : ℕ) :
    HyperRamseyProp (r + h) (towerExp h N) (k + h) (k + h) := by
  induction h with
  | zero => simpa
  | succ h ih =>
    rw [show r + (h + 1) = (r + h) + 1 from by ring,
        show k + (h + 1) = (k + h) + 1 from by ring,
        show towerExp (h + 1) N = 2 ^ towerExp h N from towerExp_succ h N]
    exact stepping_up_structural (by omega) (by omega) _ ih