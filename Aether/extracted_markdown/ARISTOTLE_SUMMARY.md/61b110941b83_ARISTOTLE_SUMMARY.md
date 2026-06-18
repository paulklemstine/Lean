# Summary of changes for run 98497818-415b-4497-9172-635f70da3998
Completed a research cycle on "Chaos and the Three-Body Problem: Lyapunov Exponent Bounds," extending the existing `Catalog/Physics/LyapunovChaos.lean`.

## New Lean file
`Catalog/Physics/LyapunovChaosBridges.lean` (module `Physics.LyapunovChaosBridges`) — builds cleanly with zero `sorry` and zero warnings; every theorem checked to depend only on the standard sound axioms (`propext`, `Classical.choice`, `Quot.sound`). It re-uses the two proven catalog foundations (`ftle`, `deriv_iterate_eq_prod`, `abs_deriv_iterate_ge`) and adds six new, fully proved theorems:

1. `cocycle_deriv_iterate` — the multiplicative cocycle `(f^{m+n})'(x) = (f^m)'(f^n x)·(f^n)'(x)` (chain rule), the algebraic backbone of Lyapunov theory.
2. `log_cocycle_deriv_iterate` — its additive/logarithmic form, matching the hypothesis of the subadditive (Kingman) / multiplicative (Oseledets) ergodic theorems.
3. `abs_deriv_iterate_le` — uniform upper stretching bound `|(f^n)'| ≤ Cⁿ`, the previously missing counterpart to the catalog's lower bound.
4. `ftle_sandwich` — two-sided bound `log c ≤ ftle ≤ log C`, generalizing the catalog's one-sided positivity (`ftle_ge_log`) into a quantitative window; chaos is the case `c > 1`.
5. `growth_rate_of_subexponential` — any positive sequence pinned to `dⁿ` up to a bounded multiplicative factor has growth rate exactly `log d`, explaining and generalizing the catalog's `entropy_periodic_growth`.
6. `expansion_separation` — rigorous sensitive dependence on initial conditions `cⁿ·|x−y| ≤ |fⁿx − fⁿy|` (the finite-distance "butterfly effect"), proved via the mean value theorem.

Each theorem carries a Lab Notebook block (Hypothesis / Result / Insight / Failure analysis) and a brief proof sketch, with catalog cross-references in the file header (`LyapunovChaos`, `Shared/HorseshoeComputation`, symbolic dynamics).

## Notes file
`Catalog/Physics/FUTURE_DIRECTIONS.md` — contains the required Synthesis and Results Summary sections plus five testable, falsifiable research directions (asymptotic Lyapunov exponent via the cocycle; 2-D matrix/Oseledets bound; non-uniform hyperbolicity on a positive-measure set; sharpness of the entropy-robustness window; and the Lyapunov–entropy / Ruelle inequality), each with a "key insight," a "Why now" justification tied to this cycle's results, and if-true/if-false consequences.

Honest scope note: these are rigorous results for one-dimensional smooth maps under uniform expansion (the provable analytic core), not the full high-dimensional non-uniformly hyperbolic three-body flow; the cocycle algebra and the localized uniform-bound hypotheses are deliberately set up as the scaffold for the multidimensional/asymptotic generalizations spelled out in the directions file.