# Summary of changes for run adb99e51-c918-4da1-9be9-84a7abd8c640
## Integrated Information Theory: Mathematical Foundations

I added a new self-contained Lean development formalizing the combinatorial core of Tononi's Integrated Information Theory (IIT), extending the existing `Speculative/Consciousness` material (which only modeled the dimension ladder) with the complementary information-theoretic invariant Φ.

### New files
- `Catalog/Speculative/Consciousness/IntegratedInformation.lean`
- `Catalog/Speculative/Consciousness/FUTURE_DIRECTIONS.md`

### Theorem declarations (all `proved`, 0 sorry, only standard axioms)
The framework models a finite `System n` by an effective-information functional `ei` over the nontrivial bipartitions `parts n`, with integrated information `Φ` defined as the value at the Minimum Information Partition (MIP).

1. `mem_parts` — membership characterization of the bipartition landscape.
2. `parts_nonempty` — for `n ≥ 2` a nontrivial cut always exists (singleton witness).
3. `parts_eq_empty` — boundary case: for `n ≤ 1` there are no nontrivial cuts (Φ undefined).
4. `phi_le_ei` — Φ is a lower bound: no cut beats the MIP.
5. `exists_MIP` — **the central result**: the Minimum Information Partition exists and realizes Φ.
6. `le_phi` — Φ is the *greatest* lower bound of the effective-information landscape.
7. `phi_nonneg` — integrated information is nonnegative.
8. `phi_eq_zero_iff` — reducibility dichotomy: Φ = 0 iff some cut destroys no information.
9. `phi_mono` — monotonicity of Φ under pointwise domination of effective information.
10. `phi_eq_of_common_mip` — strengthening: systems sharing a common minimizing cut with equal value have equal Φ.

Each theorem carries a one-line proof sketch in `-- !-- ... -- !--` blocks. Together items 4–6 make precise the brief's claim that "the maximum integrated information Φ is the minimum information partition": Φ *is* the effective information of the MIP and simultaneously the infimum over all cuts.

### Verification
The file elaborates with zero diagnostics (no errors/warnings) as a standalone module under Mathlib, contains no `sorry`/`admit`, and `#print axioms` confirms the main results depend only on `propext`, `Classical.choice`, `Quot.sound`. (Note: the project's `lakefile.toml` library globs point at root-level directories while sources live under `Catalog/`, so `lake build` targets are misconfigured project-wide; verification was therefore done via the language server and standalone compilation, which the file passes cleanly.)

### FUTURE_DIRECTIONS.md
Five falsifiable research conjectures extending the work, each with a "The key insight is..." sentence and a "Why now?" justification: (1) lifting Φ from bipartitions to the full partition lattice via `Finpartition`; (2) NP-hardness of Φ via a Karp reduction to MIN-BISECTION; (3) a poly-time approximation with a provable multiplicative guarantee built on the greatest-lower-bound characterization; (4) sub/super-additivity of Φ under system composition (with Φ = 0 for disjoint unions, an immediate corollary of `phi_eq_zero_iff`); and (5) Lipschitz stability and uniqueness of the MIP under perturbation, strengthening `phi_mono`.