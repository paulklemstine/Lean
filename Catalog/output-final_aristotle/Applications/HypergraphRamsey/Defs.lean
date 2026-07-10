import Mathlib

/-!
# Hypergraph Ramsey Theory: Core Definitions (Applications development)

This module provides the basic vocabulary used across the `Applications.HypergraphRamsey`
development:

* `IsMonoHyperClique r c S b` — `S` is a monochromatic clique of colour `b`,
  i.e. every `r`-element subset of `S` is coloured `b`;
* `HyperRamseyProp r n k l` — the r-uniform Ramsey property on the vertex set `Fin n`:
  every 2-coloring of the `r`-subsets contains a red `k`-clique or a blue `l`-clique;
* `towerExp` — the iterated exponential `towerExp h N = 2 ↑↑ h` applied to base value `N`.
-/

open Finset Nat

/-- `S` is a monochromatic clique of colour `b` for the coloring `c` of `r`-subsets:
every `r`-element subset of `S` receives colour `b`. -/
def IsMonoHyperClique {n : ℕ} (r : ℕ) (c : Finset (Fin n) → Bool)
    (S : Finset (Fin n)) (b : Bool) : Prop :=
  ∀ T ∈ S.powersetCard r, c T = b

/-- The r-uniform Ramsey property on `Fin n`: every 2-coloring of the `r`-element
subsets contains a red `k`-clique or a blue `l`-clique. -/
def HyperRamseyProp (r n k l : ℕ) : Prop :=
  ∀ c : Finset (Fin n) → Bool,
    (∃ S : Finset (Fin n), S.card = k ∧ IsMonoHyperClique r c S true) ∨
    (∃ S : Finset (Fin n), S.card = l ∧ IsMonoHyperClique r c S false)

/-- Iterated exponentiation: `towerExp 0 N = N` and
`towerExp (h+1) N = 2 ^ towerExp h N`. So `towerExp h N` applies `h` levels of
base-2 exponentiation to the starting value `N`. -/
def towerExp : ℕ → ℕ → ℕ
  | 0, N => N
  | h + 1, N => 2 ^ towerExp h N

@[simp] theorem towerExp_zero (N : ℕ) : towerExp 0 N = N := rfl

theorem towerExp_succ (h N : ℕ) : towerExp (h + 1) N = 2 ^ towerExp h N := rfl