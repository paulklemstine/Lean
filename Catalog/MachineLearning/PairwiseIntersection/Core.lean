/-
# Pairwise Intersection Energy and Incidence Lower Bounds

This module develops a combinatorial framework for proving that low pairwise
intersection complexity in a tube/cell incidence system forces the cell set
to be large. The main result is a Cauchy–Schwarz-based lower bound:

  |Cells| ≥ (|Tubes| · L)² / PairEnergy

when every tube is incident to at least L cells.

This is the combinatorial engine underlying Kakeya-type dimension lower bounds:
sparse directional probing forces metric largeness.

## Key definitions
- `cellMult` — number of tubes incident to a given cell
- `tubeLoad` — number of cells incident to a given tube
- `totalIncidences` — total number of cell-tube incidence pairs
- `pairEnergy` — pairwise intersection energy (codegree sum)
- `collisionProb` — collision probability of the cell-hit distribution

## Key theorems
- `energy_eq_sum_cellMult_sq` — energy identity
- `totalIncidences_eq_sum_cellMult` — double counting
- `sq_totalIncidences_le_card_mul_pairEnergy` — Cauchy–Schwarz
- `incidence_lower_bound` — the main cell count lower bound
- `collision_prob_le_of_energy` — information-theoretic corollary
-/

import Mathlib

namespace PairwiseIntersection

open Finset BigOperators

variable {Cell Tube : Type*} [Fintype Cell] [Fintype Tube]
  [DecidableEq Cell] [DecidableEq Tube]
  (I : Cell → Tube → Prop) [inst : ∀ q t, Decidable (I q t)]

/-! ## Core Definitions -/

/-- The number of tubes incident to a given cell (cell multiplicity).
This is the "degree" of a cell in the incidence bipartite graph. -/
def cellMult (q : Cell) : ℕ :=
  (Finset.univ.filter (fun t => I q t)).card

/-- The number of cells incident to a given tube (tube load).
This is the "degree" of a tube in the incidence bipartite graph. -/
def tubeLoad (t : Tube) : ℕ :=
  (Finset.univ.filter (fun q => I q t)).card

/-- Total number of incidence pairs in the system. -/
def totalIncidences : ℕ :=
  ∑ t : Tube, tubeLoad I t

/-- Pairwise intersection energy: for each ordered pair of tubes (t, u),
count the number of cells incident to both. This is the codegree sum
in the incidence bipartite graph. -/
def pairEnergy : ℕ :=
  ∑ t : Tube, ∑ u : Tube,
    (Finset.univ.filter (fun q : Cell => I q t ∧ I q u)).card

/-- Sum of squared cell multiplicities. -/
def sumSqCellMult : ℕ :=
  ∑ q : Cell, (cellMult I q) ^ 2

/-! ## Double Counting Identity

The total incidences can be computed by summing over tubes (tube loads)
or by summing over cells (cell multiplicities). -/

/-
Double counting: total incidences equals sum of cell multiplicities.
-/
theorem totalIncidences_eq_sum_cellMult :
    totalIncidences I = ∑ q : Cell, cellMult I q := by
  unfold totalIncidences cellMult;
  simp +decide only [tubeLoad, card_filter];
  exact Finset.sum_comm

/-! ## Energy Identity

The pair energy equals the sum of squared cell multiplicities:
  Σ_{t,u} |{q : I(q,t) ∧ I(q,u)}| = Σ_q |{t : I(q,t)}|²

This is because both sides count the number of triples (q, t, u)
where q is incident to both t and u. -/

/-
Energy identity: pairEnergy = Σ_q (cellMult q)².
-/
theorem energy_eq_sum_cellMult_sq :
    pairEnergy I = sumSqCellMult I := by
  unfold pairEnergy sumSqCellMult;
  -- By Fubini's theorem, we can interchange the order of summation.
  have h_fubini : ∑ t : Tube, ∑ u : Tube, ∑ q : Cell, (if I q t ∧ I q u then 1 else 0) = ∑ q : Cell, ∑ t : Tube, ∑ u : Tube, (if I q t ∧ I q u then 1 else 0) := by
    exact Eq.symm ( Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_comm ) );
  convert h_fubini using 3 ; simp +decide [ cellMult ];
  unfold cellMult;
  simp +decide only [card_filter, pow_two];
  rw [ Finset.sum_mul ] ; congr ; ext ; aesop

/-! ## Cauchy–Schwarz Inequality

The key analytic step: by Cauchy–Schwarz,
  (Σ_q cellMult(q))² ≤ |Cell| · Σ_q cellMult(q)²

Combined with the identities above:
  totalIncidences² ≤ |Cell| · pairEnergy -/

/-
Cauchy–Schwarz for natural number sums:
(Σ_i f(i))² ≤ |S| · Σ_i f(i)²
-/
omit [DecidableEq Cell] in
theorem sq_sum_le_card_mul_sum_sq (f : Cell → ℕ) :
    (∑ q : Cell, f q) ^ 2 ≤ Fintype.card Cell * ∑ q : Cell, f q ^ 2 := by
  -- By the Cauchy-Schwarz inequality, we have that for any vectors $u$ and $v$ of equal length, $(∑ i, u i * v i)^2 ≤ (∑ i, u i^2) * (∑ i, v i^2)$.
  have h_cauchy_schwarz : ∀ (u v : Cell → ℝ), (∑ i, u i * v i)^2 ≤ (∑ i, u i^2) * (∑ i, v i^2) := by
    exact?;
  simpa [ ← @Nat.cast_le ℝ ] using h_cauchy_schwarz ( fun _ => 1 ) ( fun i => f i )

/-
The Cauchy–Schwarz inequality applied to the incidence system:
totalIncidences² ≤ |Cell| · pairEnergy.
-/
theorem sq_totalIncidences_le_card_mul_pairEnergy :
    (totalIncidences I) ^ 2 ≤ Fintype.card Cell * pairEnergy I := by
  rw [ totalIncidences_eq_sum_cellMult, energy_eq_sum_cellMult_sq ];
  convert sq_sum_le_card_mul_sum_sq ( fun q => cellMult I q )

/-! ## Main Incidence Lower Bound

If every tube has load at least L, and the pair energy is at most P, then
  (|Tube| · L)² ≤ |Cell| · P

This is equivalent to |Cell| ≥ (|Tube| · L)² / P in ℚ or ℝ. -/

/-
The main incidence lower bound: if every tube meets at least L cells
and the pair energy is at most P, then (|Tube| · L)² ≤ |Cell| · P.
-/
theorem incidence_lower_bound (L P : ℕ)
    (hload : ∀ t : Tube, L ≤ tubeLoad I t)
    (henergy : pairEnergy I ≤ P) :
    (Fintype.card Tube * L) ^ 2 ≤ Fintype.card Cell * P := by
  refine' le_trans _ ( Nat.mul_le_mul_left _ henergy );
  have h_total : (Fintype.card Tube * L) ^ 2 ≤ (totalIncidences I) ^ 2 := by
    exact Nat.pow_le_pow_left ( by simpa [ totalIncidences ] using Finset.sum_le_sum fun t ( ht : t ∈ Finset.univ ) => hload t ) 2;
  exact h_total.trans ( sq_totalIncidences_le_card_mul_pairEnergy I )

/-! ## Real-valued version for geometric applications -/

/-
The incidence lower bound stated over ℝ with division.
-/
theorem incidence_lower_bound_div (L P : ℕ)
    (hload : ∀ t : Tube, L ≤ tubeLoad I t)
    (henergy : pairEnergy I ≤ P)
    (hP : 0 < P) :
    ((Fintype.card Tube : ℝ) * L) ^ 2 / P ≤ Fintype.card Cell := by
  convert div_le_div_of_nonneg_right ( show ( ( Fintype.card Tube * L ) ^ 2 : ℝ ) ≤ Fintype.card Cell * P by exact mod_cast incidence_lower_bound I L P hload henergy ) ( Nat.cast_nonneg P ) using 1 ; ring;
  rw [ mul_assoc, mul_inv_cancel₀ ( by positivity ), mul_one ]

/-! ## Information-Theoretic Corollary

The cell multiplicity distribution defines a probability measure on cells.
The pair energy controls the collision probability (= second moment of this
distribution), giving a lower bound on the Rényi-2 entropy.

If the total incidences are I_total and the pair energy is P, then
  collision probability = P / I_total² ≤ |Cell|⁻¹ · (P / I_total² · |Cell|)

More precisely: P / I_total² ≥ 1/|Cell|, which is equivalent to
|Cell| ≥ I_total² / P (our main theorem!).

The Rényi-2 entropy H₂ = -log₂(collision_prob) satisfies:
  H₂ ≥ log₂(I_total² / P). -/

/-- Collision probability of the cell-hit distribution. When totalIncidences > 0,
this equals pairEnergy / totalIncidences². -/
noncomputable def collisionProb : ℝ :=
  if totalIncidences I = 0 then 0
  else (pairEnergy I : ℝ) / ((totalIncidences I : ℝ) ^ 2)

/-
The collision probability is at least 1/|Cell| (equivalently,
|Cell| ≥ totalIncidences² / pairEnergy). This is the information-theoretic
rephrasing of the Cauchy–Schwarz bound.
-/
theorem collision_prob_ge_inv_card
    (hI : 0 < totalIncidences I) :
    (1 : ℝ) / Fintype.card Cell ≤ collisionProb I := by
  -- From sq_totalIncidences_le_card_mul_pairEnergy we have totalIncidences^{2} ≤ |Cell| * pairEnergy.
  have h_sq : ((totalIncidences I) : ℝ) ^ 2 ≤ (Fintype.card Cell : ℝ) * (pairEnergy I : ℝ) := by
    exact_mod_cast sq_totalIncidences_le_card_mul_pairEnergy I;
  unfold collisionProb;
  rw [ if_neg ( ne_of_gt hI ), div_le_div_iff₀ ] <;> norm_cast at * <;> nlinarith

end PairwiseIntersection