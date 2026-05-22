import Mathlib

/-!
# Tropical Action Spectrum — Core Definitions

This file defines the fundamental objects of tropical spectral mechanics:
the min-plus transfer matrix, minimum-cost paths, cycle means, and the
tropical eigenvalue (minimum cycle mean).

## Main Definitions

* `TropicalAction.minCostPath L N i j` — minimum cost of going from `i`
  to `j` in exactly `N + 1` steps.
* `TropicalAction.cycleCost L k i` — minimum cost of a closed path of
  length `k + 1` starting at `i`.
* `TropicalAction.cycleMean L k i` — average cost per step of that cycle.
* `TropicalAction.tropEigenvalue L` — the minimum cycle mean over all
  vertices and cycle lengths 1 to n (the tropical eigenvalue).
* `TropicalAction.IsTropEigenpair L mu v` — states that `v` is a tropical
  eigenvector with eigenvalue `mu`.
-/

namespace TropicalAction

open Finset BigOperators

noncomputable section

variable {n : ℕ} [NeZero n]

/-- Minimum cost of a path from `i` to `j` using exactly `N + 1` edges.
    Defined by dynamic programming (Bellman recursion):
    - Base case: `minCostPath L 0 i j = L i j` (one edge)
    - Step: `minCostPath L (N+1) i j = min_k (minCostPath L N i k + L k j)` -/
def minCostPath (L : Fin n → Fin n → ℝ) : ℕ → Fin n → Fin n → ℝ
  | 0 => L
  | N + 1 => fun i j => Finset.univ.inf' Finset.univ_nonempty
      (fun k => minCostPath L N i k + L k j)

/-- Cost of the minimum-cost closed path (cycle) of length `k + 1`
    starting and ending at vertex `i`. -/
def cycleCost (L : Fin n → Fin n → ℝ) (k : ℕ) (i : Fin n) : ℝ :=
  minCostPath L k i i

/-- Average cost per step of the optimal cycle of length `k + 1` at vertex `i`. -/
def cycleMean (L : Fin n → Fin n → ℝ) (k : ℕ) (i : Fin n) : ℝ :=
  cycleCost L k i / (k + 1 : ℝ)

/-- The tropical eigenvalue (minimum cycle mean): the minimum average cost
    per step over all cycles of length 1 to n at all vertices. -/
def tropEigenvalue (L : Fin n → Fin n → ℝ) : ℝ :=
  (Finset.univ : Finset (Fin n × Fin n)).inf' Finset.univ_nonempty
    (fun p => cycleMean L p.2.val p.1)

/-- A tropical eigenpair: `v` is a tropical eigenvector with eigenvalue `mu`
    if `min_j (L i j + v j) = mu + v i` for all `i`. This is the min-plus
    analogue of Av = lam * v in classical linear algebra. -/
def IsTropEigenpair (L : Fin n → Fin n → ℝ) (mu : ℝ) (v : Fin n → ℝ) : Prop :=
  ∀ i, Finset.univ.inf' Finset.univ_nonempty (fun j => L i j + v j) = mu + v i

/-- The tropical spectral gap: difference between the second-smallest and
    smallest cycle means. Measures the rigidity/uniqueness of the optimal
    cycle structure. -/
def tropSpectralGap (L : Fin n → Fin n → ℝ) : ℝ :=
  let eigenval := tropEigenvalue L
  let means := (Finset.univ : Finset (Fin n × Fin n)).image
    (fun p => cycleMean L p.2.val p.1)
  let above := means.filter (· > eigenval)
  if h : above.Nonempty then above.min' h - eigenval else 0

end

end TropicalAction