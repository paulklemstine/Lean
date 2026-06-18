# Summary of changes for run bab2f699-a7f3-4eee-8163-565c8067311d
Completed a full research cycle on the Tropical-domain concept "Diophantine Approximation on Neural Networks: How Well Can ReLU Approximate π?". All deliverables build cleanly with 0 sorries and only standard axioms (propext, Classical.choice, Quot.sound).

Deliverables (in Catalog/Tropical/NeuralNetworks/):

1. DiophantineReLUPi.lean — built on the existing catalog bridge MachineLearning/TropicalReLUBridge (ReLU networks = tropical rational functions). Main results:
   - reluNet_eq_castQ / reluNet_rational_ne_pi: a ReLU network with rational parameters at a rational input outputs a rational number, hence (via irrational_pi) can NEVER equal π — the Diophantine obstruction.
   - leibnizNet: an explicit width-n ReLU network implementing the Leibniz series π/4 = 1 − 1/3 + 1/5 − …; proved its value is 4·∑(−1)^i/(2i+1) independent of input (leibnizNet_apply), and that it is a tropical rational function (leibnizNet_isTropRational, from the bridge).
   - leibniz_partialSum_error + leibnizNet_error_bound: the explicit approximation rate |f(x) − π| ≤ 4/(2n+1), i.e. n = O(1/ε) hidden units suffice for accuracy ε (matching the concept's claim). Uses the conditional alternating-series sandwich lemmas (the Leibniz series is not absolutely summable).
   - leibnizNet_tendsto_pi / leibnizNet_approximates_pi: convergence to π; and leibnizNet_ne_pi: each network value is rational hence never exactly π — the "approximate but never reach" boundary characterisation.

2. ReLURepresentableConstants.lean — the sharp exact characterisation:
   - reLURepresentable_iff_rational: a constant is the exact output of some rational ReLU network at some rational input IFF it is rational (forward = obstruction; backward = width-0 constant network).
   - reLURepresentable_eq_range + reLURepresentable_dense: the exactly-representable constants are precisely ℚ ⊂ ℝ, hence dense — every real (incl. all irrationals) is approximable, while irrationals are never exact.
   - pi_not_reLURepresentable, sqrt_two_not_reLURepresentable corollaries (e omitted: Mathlib lacks irrationality of e, noted as a future direction).

Both files contain "-- !-- Lab Notes -- !--" blocks documenting the Hypothesize/Experiment/Analyze/Critique/Synthesize loop, plus explicit adversarial counterexample search blocks (compiling Lean examples) showing each main theorem is non-vacuous and that the rationality hypothesis is load-bearing.

3. FUTURE_DIRECTIONS.md — five bold, falsifiable conjectures derived from this cycle (optimality of the Θ(1/n) rate, doubly-exponential depth speedup via AGM, tropical-degree lower bounds via the bridge's convexity lemma, ℚ(x) representability for algebraic inputs, and a tropical-hypersurface "irrationality bracketing" tool), each with a "The key insight is…" sentence and a "Why now?" justification.

Note: the project's lakefile.toml was missing srcDir, so no module could resolve its imports (e.g. import Tropical.… pointed at a nonexistent root). I added srcDir = "Catalog" to match the actual directory layout; this is the minimal fix that makes the existing catalog modules and the new files build.