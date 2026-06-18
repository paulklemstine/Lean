# Summary of changes for run c7ced45b-a93e-4c38-8d60-bcf45938fbf4
Added a new self-contained Lean development on the **Fibonacci rank of apparition**, plus a `FUTURE_DIRECTIONS.md` of follow-on conjectures.

## New file: `Catalog/Speculative/FibApparitionExistence.lean`
Imports only Mathlib and compiles cleanly (no `sorry`, no warnings; all results depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`).

Theorems (all `proved`):
1. `fibStep_iterate` — iterating the Fibonacci shift map `(a,b) ↦ (b, a+b)` on `ZMod m × ZMod m` starting at `(0,1)` yields the consecutive Fibonacci pair `(F k, F (k+1))`. (induction on the recurrence)
2. `fib_apparition_exists` — **for every modulus `m ≥ 1` (not just primes)** there is a positive `k` with `m ∣ F k`. This is the main new ingredient: a finiteness/pigeonhole argument on the orbit of the shift permutation over the finite set `ZMod m × ZMod m`, supplying from scratch the existence half of Pisano-period theory, which Mathlib lacks.
3. `fib_dvd_iff_apparition_dvd` — the full **biconditional** `m ∣ F n ↔ z ∣ n` for the least positive apparition index `z`, valid for any modulus (no primality needed), strengthening the existing one-directional catalog lemma `fibEntryPt_dvd_of_fib_dvd`. (uses `Nat.fib_gcd`, `Nat.fib_dvd`, and minimality)
4. `apparitionRank` (def) with `apparitionRank_pos`, `apparitionRank_dvd_fib`, and the capstone `fib_dvd_iff_apparitionRank_dvd` — combining existence with the biconditional to give, for every `m ≥ 1`, an unconditional divisibility characterization `m ∣ F n ↔ z(m) ∣ n`.

Each theorem carries a brief `-- !-- ... -- !--` proof-sketch block as requested. The work explicitly extends the catalog's Fibonacci entry-point / Carmichael material (`Speculative.AutoResearch.CarmichaelComposite`) by removing its primality assumption and upgrading a single implication to a full biconditional with unconditional existence.

Note: the repository's `lakefile.toml` uses library source globs (e.g. `Speculative.+`) whose `srcDir` does not match the on-disk `Catalog/...` layout, so whole-project `lake build` does not resolve these modules (this affects the pre-existing files too, not just the new one). The new file was therefore verified by full standalone elaboration through the Lean server, confirming it compiles error-free and axiom-clean.

## `FUTURE_DIRECTIONS.md`
Five falsifiable research conjectures extending the file (Pisano period as the order of the shift permutation; multiplicativity of the rank of apparition; the prime law of apparition `z(p) ∣ p − (5/p)`; Carmichael-style primitive divisors via the rank lattice; generalization to arbitrary Lucas sequences / linear recurrences). Each includes a "The key insight is..." sentence and a "Why now?" justification.