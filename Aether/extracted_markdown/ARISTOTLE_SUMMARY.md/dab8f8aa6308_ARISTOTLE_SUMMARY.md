# Summary of changes for run 0a9fc09e-3bec-4b20-9a05-4b6c5e7384a5
## What was delivered

Two new, self-contained Lean files (both elaborate cleanly — `sorry = 0`, only the standard axioms `propext, Classical.choice, Quot.sound`) plus `FUTURE_DIRECTIONS.md`.

### 1. `Catalog/Logic/ProofComplexity/SimulationPreorder.lean`
Formalizes the order-theoretic core of the Cook–Reckhow program — the abstract **p-simulation preorder** on proof systems — and bridges it to the catalog's Fibonacci/entry-point number theory:
- `ProofSystem`: abstract proof system (`proves : Proof → Thm`, `size`, completeness).
- `Simulates` (polynomial-blow-up translation) proven reflexive and transitive, registered as a genuine `Preorder` (`simulationPreorder`). The crux, `polyBounded_comp`, shows the polynomial blow-up class is composition-closed.
- `PEquiv` (mutual simulation) registered as a `Setoid` (its quotient = the poset of "p-degrees").
- Bridge: `two_pow_le_fib` (`2^n ≤ F(2n+1)`) → `not_polyBounded_fib` (Fibonacci growth is super-polynomial) → `no_poly_bound_dominates_fib` → `no_simulation_of_fib_hard`: a system needing `F n`-size proofs of theorems another proves in linear size cannot be p-simulated by it — the proof-complexity reading of Fibonacci lower bounds as separation witnesses.

### 2. `Catalog/Shared/CarmichaelHelper.lean`
Supplies the previously-missing prime-index case of Carmichael's primitive-divisor theorem, `fib_primitive_divisor_prime`, via the entry-point/`gcd` argument (`dvd_fib_gcd_of_dvd`, `two_le_fib`). This closes the `Shared.CarmichaelHelper` import that `Shared/CarmichaelProof.lean` and `Speculative/AutoResearch/CarmichaelComposite.lean` depended on; with it, the catalog's `fib_carmichael` now reduces to a single remaining open case.

### Status of the catalog `sorry`
The one genuine remaining `sorry` is the infinite composite tail (`n > 10000`) of `fib_carmichael_composite` — the analytic heart of Carmichael's theorem. This is research-grade and is documented as the leading conjecture (Direction 1) in `FUTURE_DIRECTIONS.md`, with the proof route (`|Ψ_n| > p`) spelled out. Note: the catalog's `lakefile.toml` is configured so that its cross-imported files are not built by the default targets (a pre-existing repo-wide setup); all new work was therefore verified by direct elaboration.

### `FUTURE_DIRECTIONS.md`
Synthesis, a results table, and 5 falsifiable research directions (each with a "key insight" and "Why now?"): closing the Carmichael composite tail; a strict collapse/separation dichotomy; antisymmetrization to the partial order of p-degrees; the quantitative entry-point spectrum for prime indices; and growth-class robustness of the blow-up notion.

Lab-notebook comment blocks (Hypothesis / Result / Insight / Failure analysis) and `-- !-- comment -- !--` proof sketches are included in each `.lean` file.