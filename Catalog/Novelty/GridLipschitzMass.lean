/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Extremal L1 mass of normalized 1-Lipschitz grid height functions

For every nonempty `m × n` rectangular grid, let `f : {0,…,m−1} × {0,…,n−1} → ℤ`
satisfy `f(0,0) = 0` and `|f(p) − f(q)| ≤ 1` on every grid edge.  Then the total
absolute mass `∑_{i<m, j<n} |f(i,j)|` is at most

    n · m(m−1)/2 + m · n(n−1)/2.

This bound is **sharp**: it is attained by the staircase height function
`f(i,j) = i + j` (and by its negative `f(i,j) = −(i+j)`).

The whole argument rests on a single per-cell domination lemma: a 1-Lipschitz
function anchored at the origin is bounded by the grid graph distance,
`|f(i,j)| ≤ i + j`.  Summing this cell-by-cell and evaluating the two Gauss sums
gives the extremal inequality.  This is exactly the extremal estimate needed in
the Miura-ori height-function model to turn an explicit lower-bound construction
for the flip-graph diameter into a matching upper bound whenever flip distance is
controlled by L1 height difference.

## Catalog connections
* `mathlib: Algebra.BigOperators.Fin` / `Finset.sum_range_id`: the closed form of
  the bound is two triangular (Gauss) sums.
* `Ginepro–Hull 2014, counting Miura-ori flat foldings`: height functions on the
  grid are exactly the model in which this L1 mass bound is the extremal estimate.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The total L1 mass of any origin-anchored 1-Lipschitz
  integer height function on the grid is maximized by the "diagonal staircase"
  `f(i,j) = i+j`, giving the bound `n·m(m−1)/2 + m·n(n−1)/2`.  Surprising twist:
  the maximum is achieved *cell-by-cell simultaneously*, not merely in aggregate.
Experiment (Experimenter): Proved per-cell domination `|f(i,j)| ≤ i+j` by a two
  step induction — first along the bottom row (`cell_row_le`), then up each column
  (`cell_abs_le`) — using only grid edges.  Summed via `Finset.sum_le_sum` and
  evaluated with `Finset.sum_range_id`.  Sharpness verified by exhibiting the
  staircase, checking it satisfies all hypotheses, and computing equality.
Analysis (Analyst): The anchoring `f(0,0)=0` is load-bearing: without it a
  constant shift makes the mass unbounded (`mn·|C|`).  The edge condition is used
  only along an L-shaped path to each cell, so the universal-edge hypothesis is
  not needed — only grid edges.  "True but hard" was avoided: the only real
  content is the path-telescoping bound; the rest is Gauss-sum bookkeeping.
Critique (Critic): The bound is not vacuous (equality is attained), not trivial
  (induction + telescoping triangle inequality), and faithful (edges restricted
  to the grid).  Corner cases `m=0` or `n=0` make the sum empty and the bound `0`,
  handled uniformly.  Negative staircase `-(i+j)` also attains it, recorded.
Synthesis (PI): A sharp, fully proved extremal L1 inequality for grid height
  functions, with the matching lower-bound construction exhibited explicitly.
-/
import Mathlib

open Finset

namespace GridLipschitzMass

/-- Total absolute mass (L1 mass) of `f` over the `m × n` grid. -/
def gridMass (f : ℕ → ℕ → ℤ) (m n : ℕ) : ℤ :=
  ∑ i ∈ Finset.range m, ∑ j ∈ Finset.range n, |f i j|

/-- The closed-form extremal bound `n·m(m−1)/2 + m·n(n−1)/2`. -/
def triBound (m n : ℕ) : ℕ := n * (m * (m - 1) / 2) + m * (n * (n - 1) / 2)

variable {f : ℕ → ℕ → ℤ} {m n : ℕ}

/-
Bottom-row domination: along `j = 0`, an origin-anchored 1-Lipschitz function
satisfies `|f(i,0)| ≤ i`.
-/
lemma cell_row_le
    (h0 : f 0 0 = 0)
    (hrow : ∀ i j, i + 1 < m → j < n → |f (i + 1) j - f i j| ≤ 1)
    (hn : 0 < n) :
    ∀ i, i < m → |f i 0| ≤ (i : ℤ) := by
  intro i hi; induction' i with i ih <;> norm_num [ * ] ;
  exact abs_le.mpr ⟨ by linarith [ abs_le.mp ( ih ( Nat.lt_of_succ_lt hi ) ), abs_le.mp ( hrow i 0 hi hn ) ], by linarith [ abs_le.mp ( ih ( Nat.lt_of_succ_lt hi ) ), abs_le.mp ( hrow i 0 hi hn ) ] ⟩

/-
Per-cell domination by grid distance: `|f(i,j)| ≤ i + j`.
-/
lemma cell_abs_le
    (h0 : f 0 0 = 0)
    (hrow : ∀ i j, i + 1 < m → j < n → |f (i + 1) j - f i j| ≤ 1)
    (hcol : ∀ i j, i < m → j + 1 < n → |f i (j + 1) - f i j| ≤ 1) :
    ∀ i j, i < m → j < n → |f i j| ≤ (i : ℤ) + (j : ℤ) := by
  intro i j hi hj
  induction' i with i ih generalizing j <;> induction' j with j ih' <;> simp_all +decide [ abs_le ];
  · constructor <;> linarith [ ih' ( Nat.lt_of_succ_lt hj ), hcol 0 j hi hj ];
  · grind;
  · grind +splitIndPred

/-
The grid sum `∑_{i<m} ∑_{j<n} (i + j)` equals the closed-form bound.
-/
lemma sum_grid_add (m n : ℕ) :
    ∑ i ∈ Finset.range m, ∑ j ∈ Finset.range n, ((i : ℤ) + (j : ℤ))
      = (triBound m n : ℤ) := by
  norm_num [ Finset.sum_add_distrib, triBound ];
  congr! 1;
  · rw_mod_cast [ ← Finset.mul_sum _ _ _, Finset.sum_range_id ];
  · exact congrArg _ ( Eq.symm <| Int.ediv_eq_of_eq_mul_left ( by norm_num ) <| Nat.recOn n ( by norm_num ) fun n ih => by cases n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith )

/-
**Extremal L1 mass bound.**  Any origin-anchored 1-Lipschitz integer height
function on the `m × n` grid has total absolute mass at most
`n·m(m−1)/2 + m·n(n−1)/2`.
-/
theorem gridMass_le
    (h0 : f 0 0 = 0)
    (hrow : ∀ i j, i + 1 < m → j < n → |f (i + 1) j - f i j| ≤ 1)
    (hcol : ∀ i j, i < m → j + 1 < n → |f i (j + 1) - f i j| ≤ 1) :
    gridMass f m n ≤ (triBound m n : ℤ) := by
  convert sum_grid_add m n ▸ Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => ( cell_abs_le h0 hrow hcol i j ( Finset.mem_range.mp hi ) ( Finset.mem_range.mp hj ) ) using 1

/-- The diagonal staircase height function `f(i,j) = i + j`. -/
def staircase : ℕ → ℕ → ℤ := fun i j => (i : ℤ) + (j : ℤ)

/-
The staircase is origin-anchored and 1-Lipschitz on every grid edge.
-/
theorem staircase_admissible :
    staircase 0 0 = 0 ∧
    (∀ i j, |staircase (i + 1) j - staircase i j| ≤ 1) ∧
    (∀ i j, |staircase i (j + 1) - staircase i j| ≤ 1) := by
  -- Let's simplify the goal.
  simp [staircase]

/-
**Sharpness.**  The staircase attains the extremal bound with equality, so the
bound `n·m(m−1)/2 + m·n(n−1)/2` cannot be improved.
-/
theorem gridMass_staircase (m n : ℕ) :
    gridMass staircase m n = (triBound m n : ℤ) := by
  convert sum_grid_add m n using 1;
  exact Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => by unfold staircase; rw [ abs_of_nonneg ] ; positivity;

/-
**Sharpness, negative branch.**  The reflected staircase `-(i+j)` also attains
the bound, witnessing the two extremal configurations.
-/
theorem gridMass_neg_staircase (m n : ℕ) :
    gridMass (fun i j => -(staircase i j)) m n = (triBound m n : ℤ) := by
  convert gridMass_staircase m n using 1;
  unfold gridMass; aesop;

end GridLipschitzMass