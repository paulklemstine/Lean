# Summary of changes for run 0bd04930-a738-4b5e-b531-25a51d7e1197
Delivered a self-contained, sorry-free deepening of the Fibonacci entry-point program.

## New Lean file
`Catalog/Novelty/FibCarmichaelStructure.lean` — builds on the existing
`Catalog/Novelty/FibonacciEntryPointDuality.lean` (master duality `p ∣ F n ↔ z(p) ∣ n`,
`z = fibEntry`) and synthesizes the squarefree/coprime recombination technique from
`Catalog/Novelty/KorseltCarmichael.lean`. Six main theorems, all proved with zero `sorry` and
only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`):

1. `exists_pos_fib_dvd` — the rank of apparition exists: every `p ≥ 1` divides some positive
   Fibonacci number `F k`. Proved from scratch (this is not in Mathlib) by realizing the
   apparition index as the first-return time of the orbit of `(0,1)` under an invertible
   "Fibonacci shift" `Equiv` on the finite phase space `ZMod p × ZMod p`.
2. `fibEntry_pos` — consequently `z(p) > 0` (the entry point is total on `p ≥ 1`).
3. `fib_dvd_gcd_iff` — simultaneous apparition collapses to the gcd:
   `p ∣ F(gcd m n) ↔ p ∣ F m ∧ p ∣ F n`.
4. `fibEntry_coprime_mul` (centerpiece) — the lcm law `z(m·n) = lcm(z m)(z n)` for coprime `m,n`.
5. `fibEntry_prod_coprime` — the lcm law over arbitrary pairwise-coprime finite products.
6. `fibEntry_squarefree` — for squarefree `n`, `z(n)` is the lcm of `z(p)` over the prime factors.

The conceptual core is that `{ n | p ∣ F n }` is exactly the principal ideal `(z p)`, so lattice
identities among these sets descend to identities of generators via one helper
(`dvd_eq_of_dvd_iff`); `z` thereby acts as a divisibility-lattice morphism (gcd ↦ meet,
coprime product ↦ lcm), a "Carmichael λ-function" for the Fibonacci sequence.

The file includes the requested `-- !-- ... -- !--` proof-sketch blocks for each result and a
`-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis).

## FUTURE_DIRECTIONS.md
A freeform narrative with a Synthesis, a Results Summary table, and five falsifiable research
directions (prime-power refinement and the Wall–Sun–Sun frontier; Pisano period as orbit length;
a Fibonacci–Korselt pseudoprime criterion; Lucas's law of apparition; and monotonicity/
functoriality of `z`), each containing a "The key insight is…" sentence and a "Why now?"
justification that cites the just-proven results.

## Build note
The project's `lakefile.toml` library globs (e.g. `Algebra.+`, `Tropical.+`) did not match the
actual `Catalog/...` module layout, so no catalog module was resolvable and nothing built. I
added one additive `lean_lib` (`name = "Catalog"`, `globs = ["Catalog.+"]`) that makes every
catalog module resolvable; existing library entries and default targets are untouched. Both the
new file and the foundation file compile cleanly with no warnings and no sorries.