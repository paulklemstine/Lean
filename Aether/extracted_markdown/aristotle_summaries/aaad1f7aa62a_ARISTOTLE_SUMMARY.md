# Summary of changes for run 2f76e5ab-f5c2-41c7-a754-b3169373342b
Extended the catalog's rank-of-apparition program into a complete lattice-morphism theory.

## What was produced

**`Speculative/AutoResearch/RankApparitionFinite.lean`** — a new, self-contained Lean 4 file (builds under the registered `Speculative` library; `sorry = 0`; axioms = `propext, Classical.choice, Quot.sound` only). It restates the catalog's rank-of-apparition core (`IsSDS`, `entry`, `Appears`, the abstract law of apparition `dvd_iff_entry_dvd`, rigidity `entry_eq_of_dvd_iff`, the order-side morphism `entry_dvd_entry_of_dvd`, and the binary join law `entry_mul_coprime`) and then proves four genuinely new main results that build on it:

- `appears_mul` — the appearance set is closed under coprime products.
- `entry_dvd_gcd` — the meet (gcd) lower bound `entry u (gcd a b) ∣ gcd(entry u a, entry u b)`, completing the lattice picture begun by the catalog's order-side morphism.
- `entry_prod_coprime` — finite multiplicativity / the full join law: for a pairwise-coprime appearing family, `entry u (∏ᵢ fᵢ) = lcmᵢ (entry u fᵢ)`, generalizing the catalog's binary `entry_mul_coprime` to arbitrarily many factors.
- `entry_eq_lcm_primePow` — reduction to prime powers: `entry u m = lcm_{p∣m} entry u (p^{vₚ(m)})`, collapsing all rank-of-apparition computation to the prime-power case.

Cross-domain instantiations `fib_entry_prod_coprime` (Fibonacci) and `mersenne_entry_prod_coprime` (Mersenne/repunit, where `entry` is the multiplicative order) follow uniformly.

Each result has a one-to-two-sentence `-- !--` proof sketch, and the file ends with a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis). The failure analysis records that the `Catalog/` tree is not on the Lake module path (library globs resolve from the repo root, not `Catalog/`), so the catalog file cannot be imported and its small core was restated self-containedly.

**`Speculative/AutoResearch/FUTURE_DIRECTIONS.md`** — narrative synthesis, a results-summary table, and 5 falsifiable research directions (prime-power closed form via lifting-the-exponent; discharging `Appears` totality via Pisano periodicity; upgrading to a full `entry(lcm a b) = lcm(entry a, entry b)` lattice homomorphism; Carmichael primitive divisors through `entry`; generalization to `GCDMonoid`/Lucas/elliptic divisibility sequences), each with a "The key insight is..." sentence and a "Why now?" justification connecting to existing catalog files.

All theorems were verified by a full `lake build` of the module and an axiom check; no `sorry` and no nonstandard axioms remain.