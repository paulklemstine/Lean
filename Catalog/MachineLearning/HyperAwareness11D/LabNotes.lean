import MachineLearning.HyperAwareness11D.FrameBounds

/-!
# Hyper-Awareness — Lab Notes: exact rational experiments in dimension 11

All experiments below are carried out in exact rational arithmetic (`ℚ`), so the printed
numbers are exact, not floating point.  They are the computational evidence that motivated
(and then stress-tested) the theorems of this development; the accompanying file
`ComputationalEvidence.md` reproduces the printed output.

## Experiment 1 — a 21-unit layer collapses two percepts (`collision_21`)

The most natural "almost optimal" architecture on `ℝ¹¹` uses the `11` positive detectors
`x ↦ x_j⁺` and only `10` of the `11` negative detectors.  It has `21` units, one below the
proven optimum `22`.  `collision_21` is a *proof* that the two distinct percepts
`xA = -e₁₀` and `xB = -2 e₁₀` are mapped to the same output, i.e. the missing unit is fatal —
exactly as `HyperAwareness11D.two_mul_le_card_of_injective` predicts.

## Experiment 2 — frame ratios of the optimal 22-unit split layer

`#eval` of `ratio x y = ‖Φx - Φy‖² / ‖x - y‖²` on five percept pairs returns

  `(1/2, 1, 61/102, 1/2, 1)`

confirming the sharp sandwich `1/2 ≤ ratio ≤ 1` of `double_frame`, with the value `1/2`
attained exactly at antipodal pairs and `1` attained against the origin.

## Experiment 3 — activation balance

`#eval` of the pair of active-unit counts `(#active at x, #active at -x)` returns

  `((10, 10), (10, 10), 11, 11)`  (i.e. the pairs `(10,10)`, `(10,10)`, `(11,11)`).

The last percept has all coordinates nonzero (transverse) and gives the perfectly balanced
`11 + 11 = 22` split predicted by `balanced_activation_at_optimum`.  The first two percepts
have a vanishing coordinate, and there the counts drop to `10`: this is precisely why the
theorems quantify over *transverse* probe directions.
-/

namespace HyperAwareness11D.LabNotes

open Finset

/-- Rational ReLU, for exact computation. -/
def reluQ (t : ℚ) : ℚ := max t 0

/-- The `21`-unit layer: all `11` positive detectors, but only `10` negative detectors. -/
def W21 : Fin 21 → Fin 11 → ℚ := fun i j =>
  if (i : ℕ) < 11 then (if (i : ℕ) = (j : ℕ) then 1 else 0)
  else (if (i : ℕ) - 11 = (j : ℕ) then -1 else 0)

/-- The layer map of `W21`. -/
def layer21 (x : Fin 11 → ℚ) : Fin 21 → ℚ := fun i => reluQ (∑ j, W21 i j * x j)

def xA : Fin 11 → ℚ := fun j => if (j : ℕ) = 10 then -1 else 0
def xB : Fin 11 → ℚ := fun j => if (j : ℕ) = 10 then -2 else 0

set_option maxHeartbeats 1000000 in
/-- **Experiment 1, verified.**  The `21`-unit layer identifies two distinct percepts:
an explicit witness for the failure of losslessness one unit below the optimum. -/
theorem collision_21 : layer21 xA = layer21 xB ∧ xA ≠ xB := by
  constructor
  · funext i
    fin_cases i <;> norm_num [layer21, W21, xA, xB, reluQ, Fin.sum_univ_succ]
  · intro h
    have h10 := congrFun h 10
    norm_num [xA, xB] at h10

/-- The optimal `22`-unit split layer, in rational arithmetic. -/
def splitW : Fin 22 → Fin 11 → ℚ := fun i j =>
  if (i : ℕ) < 11 then (if (i : ℕ) = (j : ℕ) then 1 else 0)
  else (if (i : ℕ) - 11 = (j : ℕ) then -1 else 0)

def splitQ (x : Fin 11 → ℚ) : Fin 22 → ℚ := fun i => reluQ (∑ j, splitW i j * x j)

def sqd (x y : Fin 11 → ℚ) : ℚ := ∑ i, (x i - y i) ^ 2
def sqd22 (x y : Fin 22 → ℚ) : ℚ := ∑ i, (x i - y i) ^ 2

/-- Squared expansion ratio of the split layer on a pair of percepts. -/
def ratio (x y : Fin 11 → ℚ) : ℚ := sqd22 (splitQ x) (splitQ y) / sqd x y

def e0Q : Fin 11 → ℚ := fun j => if (j : ℕ) = 0 then 1 else 0
def v1 : Fin 11 → ℚ := fun j => (j : ℚ) - 5
def v2 : Fin 11 → ℚ := fun j => ((j : ℚ) - 3) * (-1) ^ (j : ℕ)

-- Experiment 2: prints `(1/2, 1, 61/102, 1/2, 1)`
#eval (ratio e0Q (fun j => -e0Q j), ratio e0Q (fun _ => 0), ratio v1 v2,
  ratio v1 (fun j => -v1 j), ratio v2 (fun _ => 0))

/-- Active-unit counts of the split layer at `x` and at `-x`. -/
def activeCounts (x : Fin 11 → ℚ) : ℕ × ℕ :=
  (((univ : Finset (Fin 22)).filter (fun i => 0 < ∑ j, splitW i j * x j)).card,
   ((univ : Finset (Fin 22)).filter (fun i => 0 < ∑ j, splitW i j * (-(x j)))).card)

-- Experiment 3: prints `((10, 10), (10, 10), 11, 11)`
#eval (activeCounts v1, activeCounts v2, activeCounts (fun j => (j : ℚ) + 1))

end HyperAwareness11D.LabNotes