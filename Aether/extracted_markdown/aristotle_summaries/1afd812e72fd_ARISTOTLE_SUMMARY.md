# Summary of changes for run 121927fe-bb91-420e-b0c3-6b19cae26395
Completed a research cycle formalizing the mathematical foundations of Integrated Information Theory (IIT) in Lean 4.

**New file**: `Catalog/Speculative/Consciousness/IntegratedInformation.lean` (extends the existing `Speculative/Consciousness` catalog domain). It compiles cleanly against Mathlib; all main theorems use only the standard axioms `propext`, `Classical.choice`, `Quot.sound` (verified via `#print axioms`).

**Model**: A system is `Fin n` (n ≥ 2 elements) with a nonnegative *effective information* function `ei` on its nontrivial cuts (bipartitions encoded as subsets). Integrated information `Phi` is defined as the minimum of `ei` over all cuts; a polynomial-size `phiApprox` is the minimum over only the `n` singleton cuts.

**Proved theorems (10, no `sorry`)**:
- `Phi_attained` — the Minimum Information Partition exists and realizes `Phi` (the precise sense of "Phi is the effective information at the MIP").
- `Phi_le_ei` — `Phi` is a lower bound across all cuts; `Phi_nonneg` — nonnegativity.
- `Phi_eq_zero_iff_reducible` — irreducibility characterization (`Phi = 0` iff some cut carries no information): the core IIT thesis that an integrated system is exactly one no cut can decompose.
- `card_allCuts` — the exact cut space has `2^n − 2` elements (the rigorous combinatorial surrogate for NP-hardness: brute force is exponential).
- `card_singletonCuts` — the approximation evaluates exactly `n` cuts (polynomial cost).
- `Phi_le_phiApprox` — the polynomial-time approximation is a sound upper bound on `Phi`.
- plus three supporting lemmas (`allCuts_nonempty`, `singletonCuts_nonempty`, `singletonCuts_subset`).

**One conjecture (intentional `sorry`)**: `phiApprox_gap_unbounded_conjecture` — the approximation has no additive accuracy guarantee, marking the boundary of cheap approximation.

Each major theorem carries a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis) and a one-line `-- !-- ... -- !--` proof sketch, as requested.

**`FUTURE_DIRECTIONS.md`** (project root) contains the required `## Synthesis` and `## Results Summary` sections plus five falsifiable research directions (unbounded approximation gap, lattice-monotone approximation hierarchy, k-block partitions, genuine NP-hardness via MIN-BISECTION, and tractability under submodular `ei`), each with its key insight, a concrete test, and if-true/if-false analyses.

Note on scope: genuine NP-hardness is not claimed as a proved theorem — only its exponential-search-space surrogate (`card_allCuts`) is proved, with the full hardness reduction laid out as Direction 4 for the next cycle.