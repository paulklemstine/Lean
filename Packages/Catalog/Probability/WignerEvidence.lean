/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Computational evidence for the Wigner semicircle development

Exact rational brute-force computation of the ensemble averages
`E [ tr (W^m) ]` for the Rademacher sign ensemble on `N` vertices, obtained by
enumerating *all* `2^(N(N-1)/2)` sign configurations and computing traces exactly
over `ℚ` (no floating point, no sampling).

The output of these computations is recorded in `ComputationalEvidence.md`.  It was
used to guess — and only afterwards to prove — the exact finite-`N` formulas of
`Probability.WignerRademacherEnsemble` and `Probability.WignerUniversalFourthMoment`,
and to formulate the sixth-moment conjecture of `FUTURE_DIRECTIONS.md`.

Nothing in this file is used in any proof; it is a computational laboratory.
The `#eval` commands are left commented out so that the module builds instantly.
-/
import Mathlib

namespace WignerEvidence

/-- The unordered edges of the complete graph on `N` vertices, in a fixed order. -/
def edgesList (N : ℕ) : List (ℕ × ℕ) :=
  (List.range N).flatMap fun i => ((List.range N).filter fun j => i < j).map fun j => (i, j)

/-- The `(i,j)` entry of the sign matrix determined by the bitmask `mask`:
zero on the diagonal, and `±1` according to the bit attached to the edge `{i,j}`. -/
def entryOf (N mask i j : ℕ) : ℚ :=
  if i = j then 0
  else
    let p := if i < j then (i, j) else (j, i)
    if mask.testBit ((edgesList N).idxOf p) then 1 else -1

/-- Multiply a row vector by the matrix `e`. -/
def applyMat (N : ℕ) (e : ℕ → ℕ → ℚ) (v : List ℚ) : List ℚ :=
  (List.range N).map fun j => ((List.range N).map fun i => v[i]! * e i j).sum

/-- The `a`-th standard basis row vector. -/
def basisVec (N a : ℕ) : List ℚ := (List.range N).map fun i => if i = a then 1 else 0

/-- `tr (A^m)` computed by iterating the matrix on basis vectors (cost `O(N³m)`). -/
def tracePow (N : ℕ) (e : ℕ → ℕ → ℚ) (m : ℕ) : ℚ :=
  ((List.range N).map fun a => ((applyMat N e)^[m] (basisVec N a))[a]!).sum

/-- The exact ensemble average of `tr (W^m)` over all `2^(N(N-1)/2)` sign
configurations. -/
def avgTracePow (N m : ℕ) : ℚ :=
  let E := N * (N - 1) / 2
  ((List.range (2 ^ E)).foldl (fun acc mask => acc + tracePow N (entryOf N mask) m) 0)
    / (2 ^ E : ℚ)

/-- The prediction of `RademacherWigner.expect_trace_W_four`. -/
def predict4 (N : ℕ) : ℚ := 2 * N * (N - 1) ^ 2 - N * (N - 1)

/-- The conjectured sixth-moment formula (see `FUTURE_DIRECTIONS.md`). -/
def predict6 (N : ℕ) : ℚ := (N:ℚ) * ((N:ℚ) - 1) * (5 * (N:ℚ) ^ 2 - 15 * (N:ℚ) + 11)

-- E[tr W²] = N(N-1) :  0, 2, 6, 12, 20
-- #eval (List.range 5).map fun N => avgTracePow (N + 1) 2

-- E[tr W³] = 0
-- #eval (List.range 5).map fun N => avgTracePow (N + 1) 3

-- E[tr W⁴] = 2N(N-1)² - N(N-1) :  0, 2, 18, 60, 140
-- #eval (List.range 5).map fun N => avgTracePow (N + 1) 4
-- #eval (List.range 5).map fun N => predict4 (N + 1)

-- E[tr W⁵] = 0
-- #eval (List.range 4).map fun N => avgTracePow (N + 1) 5

-- sixth moment data
-- #eval (List.range 5).map fun N => avgTracePow (N + 1) 6
-- #eval (List.range 5).map fun N => predict6 (N + 1)
-- out-of-sample test at N = 6: both evaluate to 3030
-- #eval avgTracePow 6 6
-- #eval predict6 6

end WignerEvidence