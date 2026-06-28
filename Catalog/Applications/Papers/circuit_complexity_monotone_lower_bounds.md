# Computational Evidence — Monotone Circuit Complexity

The main theorems are universally quantified structural statements (over an
arbitrary index type `ι`, arbitrary circuits, and arbitrary rounding operators),
so the decisive evidence is the Lean proofs themselves, which the kernel checks.
The notes below record the small-case sanity checks that guided the formalization.

## 1. The relevant-variable / CLIQUE size bound

For 2-CLIQUE on `Fin m`, every non-loop edge is a relevant variable, so any
monotone circuit needs at least `m.choose 2` nodes.

| m | edges = m.choose 2 |
|---|--------------------|
| 2 | 1 |
| 3 | 3 |
| 4 | 6 |
| 5 | 10 |
| 6 | 15 |

Sanity: an OR over all `m.choose 2` edge variables computes 2-CLIQUE and has size
`2·(m.choose 2) − 1` nodes, consistent with the lower bound `m.choose 2`.
`card_offDiag_eq_choose` confirms the edge count equals `m.choose 2`.

## 2. Karchmer–Wigderson protocol cost

For the circuit `(x₀ ∨ x₁) ∧ (x₂ ∨ x₃)` (depth 2): on any `1`-input `x` and
`0`-input `y`, `kwFind` communicates one bit at the AND gate and one at the chosen
OR gate, so `kwCost = 2 = depth`, matching `kwCost_le_depth`, and returns an index
`i` with `x i = true`, `y i = false`, matching `kwFind_spec`.

## 3. Approximation-method error accumulation

Taking `R = id` makes `approxEval` agree with `eval` exactly, so the error set is
empty and `0 ≤ numGates · 0` — the degenerate base case.

For a nontrivial check, let `δ = 1` and a rounding `R` that flips one input per
gate: a circuit with `g` gates can accumulate at most `g` errors, exactly the
`numGates · δ` bound of `approx_error_bound`. Plugging a far-ness budget
`E = numGates · δ + 1` into `approx_method_size_lb` would be unsatisfiable,
confirming the conclusion `E ≤ size · δ` is a genuine constraint, not vacuous.

## Counterexample hunt

No counterexample to any stated theorem was found; each statement is proved in
Lean with only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`),
verified via `#print axioms`.
