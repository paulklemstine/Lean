import Mathlib

/-!
# Exponential Information Complexity Lower Bound for Periodic L_p-Discrepancy via Duality

This file formalizes the *rigorous combinatorial kernel* behind the curse of dimensionality
for non-negative (positive-weight) cubature rules associated with periodic `L_p`-discrepancy.

## Background

In information-based complexity one studies cubature (quadrature) rules
`Q_n f = ∑_{i=1}^n w_i f(x_i)` approximating an integral `I f`.  For a suitable function
space `F_d` (e.g. the periodic space whose worst-case integration error equals the
`L_p`-discrepancy of the node set), the *worst-case error* is

  `e(Q_n) = sup_{‖f‖ ≤ 1} |I f − Q_n f|`.

A central phenomenon is the **curse of dimensionality**: for *non-negative* rules
(`w_i ≥ 0`) the number `n` of nodes needed to reach accuracy `ε` grows exponentially
in the dimension `d`.

## The duality / fooling-function kernel proved here

We isolate the *deterministic combinatorial core* of the argument, independent of the
analytic details of `F_d`.  The cube is split into `M` cells (think `M = 2^d` dyadic
boxes).  A node lying in cell `c` "sees" only the bump function supported on cell `c`.
The worst-case error is bounded below by testing against one *fooling bump* per cell.

* `Rule.sum_applyBump` — exact "swap of sums" identity: the total cubature mass spread
  over all `M` cell-bumps equals `∑_i w_i v_i` (the duality pairing).
* `Rule.sum_err_ge` — **averaging / duality lower bound**: `∑_j err_j ≥ M·δ − B·W`,
  where `W` is the total weight and `B` bounds the bump heights.  This genuinely uses
  `w_i ≥ 0` (non-negativity of the rule).
* `Rule.exists_large_err` — some single cell already has error `≥ δ − B·W/M`.
* `Rule.empty_cell_err` / `Rule.info_complexity` — pigeonhole core: if `n < M` then some
  cell is *uncovered*, and the bump on it incurs the full error `δ`.
* `Rule.curse_of_dimensionality` — with `M = 2^d`: any non-negative rule whose
  worst-case error beats `δ` must use `n ≥ 2^d` nodes — an **exponential** lower bound.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The exponential point count for non-negative cubature is not
an analytic accident of `F_d` but a *combinatorial* consequence of two facts: (i) a node
in one cell contributes nothing to a bump on a different cell, and (ii) the total weight
budget is finite.  Conjecture: a clean "average ⇒ extremal" duality argument recovers the
curse with no functional analysis.

Experiment (Experimenter): Model a rule by a cell-assignment `cell : Fin n → Fin M` and
weights `w ≥ 0`.  Test against `M` disjoint bumps of common integral `δ` and height `≤ B`.
Prove (a) the swap identity `∑_j Q(bump_j) = ∑_i w_i v_i`, (b) `∑_j err_j ≥ Mδ − BW`,
and (c) the pigeonhole `n < M ⇒ ∃` empty cell with error exactly `δ`.

Analysis (Analyst): Both arguments survive.  (b) is "true and not hard" once the swap
identity is in place; the load-bearing hypothesis is `w_i ≥ 0` (used to bound
`∑_i w_i v_i ≤ B·W`).  (c) is "true and elementary" via `Fintype.card_le_of_surjective`.
A *false* variant we discarded: dropping `w_i ≥ 0` breaks (b) (signed weights can make
`∑_i w_i v_i` arbitrarily large) but, interestingly, NOT (c) — the empty-cell bound is
sign-agnostic.  This pinpoints exactly where non-negativity is essential.

Critique (Critic): The results are not vacuous: `sum_err_ge` is a genuine inequality with
both sides nonzero, and `curse_of_dimensionality` produces the exponential bound `2^d ≤ n`
from a strict-error hypothesis.  Corner cases handled: `M = 0` is excluded where division
by `M` appears; `δ ≥ 0` is required so `|δ| = δ`.  No theorem reduces to `rfl`/`decide`.

Synthesis (PI): The duality kernel cleanly separates the *combinatorial* curse (here) from
the *analytic* identification "worst-case error = `L_p`-discrepancy" (left to `F_d`).
-/

namespace PeriodicDiscrepancyCurse

open Finset

/-- A non-negative linear cubature rule on a domain partitioned into `M` cells, using
`n` nodes.  `cell i` records the cell containing node `i`, and `w i ≥ 0` is its weight. -/
structure Rule (n M : ℕ) where
  /-- The cell containing each node. -/
  cell : Fin n → Fin M
  /-- The (non-negative) weight of each node. -/
  w : Fin n → ℝ
  /-- Non-negativity of the weights: the rule is a *positive* cubature rule. -/
  hw : ∀ i, 0 ≤ w i

namespace Rule

variable {n M : ℕ}

/-- The total weight `W = ∑_i w_i` of the rule. -/
def totalWeight (R : Rule n M) : ℝ := ∑ i, R.w i

@[simp] lemma totalWeight_nonneg (R : Rule n M) : 0 ≤ R.totalWeight :=
  Finset.sum_nonneg (fun i _ => R.hw i)

/-- The cubature value on the `j`-th fooling bump.  The bump for cell `j` takes value
`v i` at node `i` when that node lies in cell `j`, and `0` otherwise; the rule sees only
nodes inside cell `j`. -/
def applyBump (R : Rule n M) (v : Fin n → ℝ) (j : Fin M) : ℝ :=
  ∑ i, R.w i * (if R.cell i = j then v i else 0)

/-- The integration error on the `j`-th fooling bump, whose true integral is `δ`. -/
def err (R : Rule n M) (v : Fin n → ℝ) (δ : ℝ) (j : Fin M) : ℝ :=
  |δ - R.applyBump v j|

/-- **Duality / swap-of-sums identity.**  The total cubature mass spread across all `M`
cell-bumps equals the pairing `∑_i w_i v_i`. -/
theorem sum_applyBump (R : Rule n M) (v : Fin n → ℝ) :
    ∑ j, R.applyBump v j = ∑ i, R.w i * v i := by
  unfold applyBump
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  rw [← Finset.mul_sum]
  congr 1
  rw [Finset.sum_ite_eq Finset.univ (R.cell i) (fun _ => v i)]
  simp

/-- If every bump height is `≤ B`, the duality pairing is bounded by `B·W`.  **This is
where non-negativity `w_i ≥ 0` is used.** -/
theorem sum_applyBump_le (R : Rule n M) {v : Fin n → ℝ} {B : ℝ}
    (hv : ∀ i, v i ≤ B) : ∑ j, R.applyBump v j ≤ B * R.totalWeight := by
  rw [sum_applyBump, totalWeight, Finset.mul_sum]
  refine Finset.sum_le_sum (fun i _ => ?_)
  rw [mul_comm B (R.w i)]
  exact mul_le_mul_of_nonneg_left (hv i) (R.hw i)

/-- **Averaging / duality lower bound.**  With `M` disjoint bumps of common integral `δ`
and heights `≤ B`, the total error over all cells is at least `M·δ − B·W`. -/
theorem sum_err_ge (R : Rule n M) {v : Fin n → ℝ} {δ B : ℝ}
    (hv : ∀ i, v i ≤ B) :
    (M : ℝ) * δ - B * R.totalWeight ≤ ∑ j, R.err v δ j := by
  have h1 : ∑ j, (δ - R.applyBump v j) ≤ ∑ j, R.err v δ j := by
    refine Finset.sum_le_sum (fun j _ => ?_)
    exact le_abs_self _
  have h2 : ∑ j : Fin M, (δ - R.applyBump v j)
      = (M : ℝ) * δ - ∑ j, R.applyBump v j := by
    rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
      nsmul_eq_mul]
  rw [h2] at h1
  have h3 : ∑ j, R.applyBump v j ≤ B * R.totalWeight := sum_applyBump_le R hv
  linarith

/-- **Some single cell already carries near-maximal error.**  From the averaging bound,
there is a cell whose error is at least `δ − B·W/M`. -/
theorem exists_large_err (R : Rule n M) {v : Fin n → ℝ} {δ B : ℝ}
    (hM : 0 < M) (hv : ∀ i, v i ≤ B) :
    ∃ j, δ - B * R.totalWeight / (M : ℝ) ≤ R.err v δ j := by
  have hMR : (0 : ℝ) < M := by exact_mod_cast hM
  have hsum : ∑ _j : Fin M, (δ - B * R.totalWeight / (M : ℝ)) ≤ ∑ j, R.err v δ j := by
    have : ∑ _j : Fin M, (δ - B * R.totalWeight / (M : ℝ))
        = (M : ℝ) * δ - B * R.totalWeight := by
      rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
      field_simp
    rw [this]
    exact sum_err_ge R hv
  have hne : (Finset.univ : Finset (Fin M)).Nonempty := by
    rw [Finset.univ_nonempty_iff]
    exact Fin.pos_iff_nonempty.mp hM
  obtain ⟨j, _, hj⟩ := Finset.exists_le_of_sum_le hne hsum
  exact ⟨j, hj⟩

/-- **Pigeonhole: an uncovered cell exists when there are too few nodes.**  If `n < M`,
the cell-assignment cannot be surjective, so some cell contains no node. -/
theorem empty_cell_of_lt (R : Rule n M) (h : n < M) :
    ∃ j, ∀ i, R.cell i ≠ j := by
  by_contra hcon
  push_neg at hcon
  have hsurj : Function.Surjective R.cell := by
    intro j
    obtain ⟨i, hi⟩ := hcon j
    exact ⟨i, hi⟩
  have := Fintype.card_le_of_surjective R.cell hsurj
  simp only [Fintype.card_fin] at this
  omega

/-- The cubature value on a bump supported on an *uncovered* cell is `0`. -/
theorem applyBump_empty (R : Rule n M) (v : Fin n → ℝ) {j : Fin M}
    (hj : ∀ i, R.cell i ≠ j) : R.applyBump v j = 0 := by
  unfold applyBump
  refine Finset.sum_eq_zero (fun i _ => ?_)
  rw [if_neg (hj i)]
  ring

/-- The error on a bump supported on an uncovered cell is exactly `δ` (its integral). -/
theorem empty_cell_err (R : Rule n M) (v : Fin n → ℝ) {δ : ℝ} (hδ : 0 ≤ δ) {j : Fin M}
    (hj : ∀ i, R.cell i ≠ j) : R.err v δ j = δ := by
  unfold err
  rw [applyBump_empty R v hj, sub_zero, abs_of_nonneg hδ]

/-- **Information-complexity core.**  If a non-negative rule uses fewer nodes than there
are cells (`n < M`), then some fooling bump is integrated with the full error `δ`. -/
theorem info_complexity (R : Rule n M) (v : Fin n → ℝ) {δ : ℝ} (hδ : 0 ≤ δ)
    (h : n < M) : ∃ j, R.err v δ j = δ := by
  obtain ⟨j, hj⟩ := empty_cell_of_lt R h
  exact ⟨j, empty_cell_err R v hδ hj⟩

/-- **Curse of dimensionality (cell form).**  If every cell error is strictly below `δ`,
then the rule must use at least `M` nodes. -/
theorem nodes_ge_of_err_lt (R : Rule n M) (v : Fin n → ℝ) {δ : ℝ} (hδ : 0 ≤ δ)
    (hsmall : ∀ j, R.err v δ j < δ) : M ≤ n := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨j, hj⟩ := info_complexity R v hδ hcon
  exact absurd hj (ne_of_lt (hsmall j))

end Rule

/-- **Curse of dimensionality (exponential form).**  Let the cube be split into
`M = 2^d` dyadic cells.  Any non-negative cubature rule whose worst-case error against
the unit-integral fooling bumps stays strictly below `δ` must use at least `2^d` nodes —
an exponential lower bound in the dimension `d`, confirming the curse of dimensionality. -/
theorem curse_of_dimensionality {n d : ℕ} (R : Rule n (2 ^ d)) (v : Fin n → ℝ)
    {δ : ℝ} (hδ : 0 ≤ δ) (hsmall : ∀ j, R.err v δ j < δ) : 2 ^ d ≤ n :=
  R.nodes_ge_of_err_lt v hδ hsmall

end PeriodicDiscrepancyCurse