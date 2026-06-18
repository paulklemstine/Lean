# Summary of changes for run a20309af-6399-4ac2-b2ba-8ea0c527a02c
Produced a self-contained, machine-checked formalization of the research concept **"Neural Network Training as Renormalization Group (RG) Flow"**, added under `Catalog/MachineLearning/NeuralRG/`.

**Lean files (8 theorems, sorry = 0, only standard axioms `propext`/`Classical.choice`/`Quot.sound`):**

`MachineLearning/NeuralRG/Flow.lean` — the *flow* half of the SGD↔RG analogy. Models training via a gradient field `g` and the step map `sgdStep g η x = x − η•g x`, and proves:
- `sgd_fixed_iff_critical` — SGD/RG fixed points are exactly the loss's critical points.
- `quadratic_error_recursion` — for a linear network the flow linearizes exactly to the RG beta function `M = I − ηA`: `T x − x* = M (x − x*)`.
- `quadratic_geometric_decay` — `‖Tⁿx − x*‖ ≤ ‖M‖ⁿ‖x − x*‖`.
- `quadratic_tendsto_fixedPoint` — criticality `‖M‖ < 1` ⇒ convergence to the Gaussian fixed point.

`MachineLearning/NeuralRG/CoarseGraining.lean` — the *coarse-graining/universality* half. Treats the RG block-spin operator as an idempotent projection `P` (`P∘P=P`) and proves:
- `coarseGraining_fixed_eq_range` — the RG fixed-point manifold equals the subspace `range P`.
- `coarseGraining_iterate_eq` — `P^[n+1] = P` (the RG flow is a one-step projection).
- `sgd_rg_covariant` — SGD commutes with coarse-graining under RG covariance `P∘g = g∘P`.
- `universality_class_preserved` — configurations in the same universality class (`P x = P y`) stay coarse-grained-equal along the entire trajectory, formalizing "same universality class ⇒ same fixed point".

Each file includes brief `-- !--` proof-sketch annotations on every theorem and a Lab Notebook block (Hypothesis / Result / Insight / Failure analysis), with docstrings citing related catalog work (`MachineLearning.ResNetLipschitz`, `Algebra.IdempotentHilbertBasis`).

**`MachineLearning/NeuralRG/FUTURE_DIRECTIONS.md`** — a narrative synthesis, a results-summary table, and 5 bold, falsifiable research directions (deriving RG covariance from data isotropy; a non-Gaussian Wilson–Fisher-type fixed point; quotient/functorial dynamics on `E/ker P`; a convergence-rate ↔ critical-exponent spectral dictionary; stochastic coarse-graining with a fixed-point measure), each with a "The key insight is…" sentence and a "Why now?" justification.

Both files were verified with `lake build` (no errors, no warnings) and confirmed free of `sorry`. Note: the buildable Lean project is rooted at `Catalog/`, so the new modules sit correctly under the `MachineLearning` library target there.