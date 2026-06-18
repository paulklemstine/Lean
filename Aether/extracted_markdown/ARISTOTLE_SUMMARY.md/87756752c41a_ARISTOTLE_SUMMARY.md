# Summary of changes for run 9487effe-cd38-4830-a88e-a26ff75de587
Produced the new Lean 4 deliverable `Catalog/Cryptography/ConservedPathReductions.lean` plus `FUTURE_DIRECTIONS.md`, fusing two catalog strands: the pseudo-metric/advantage view of cryptographic reductions (`Catalog/Cryptography/AdvantageMetric.lean`) and the Fibonacci/Carmichael primitive-divisor work (`Catalog/Shared/CarmichaelProof.lean`, `Catalog/Novelty/FibApparitionExistence.lean`).

The file defines the path-length functional `pathLength` on a discrete walk in any pseudometric space (with helper lemmas `pathLength_zero`, `pathLength_succ`, `pathLength_nonneg`) and proves six headline results, all with `sorry = 0`:

- `gameDist_path_le` — endpoint distance ≤ path length (pseudometric generalization of the hybrid argument).
- `pathLength_concat` — additivity of path length under concatenation at any `k ≤ n`.
- `lipschitz_reduction_contracts_path` — a `K`-Lipschitz reduction multiplies path length by at most `K`. Notably, the proof revealed the conventional hypothesis `0 ≤ K` is unnecessary, so it was dropped, yielding a strictly more general statement.
- `reduction_end_to_end_bound` — the end-to-end estimate `dist (φ(f 0)) (φ(f n)) ≤ K · pathLength f n`.
- `fib_gcd_conservation` — gcd conservation `gcd (fib m) (fib n) = fib (gcd m n)`.
- `fib_primitivity_bridge` — the conserved-quantity heart of the Carmichael bridge lemma, collapsing local non-divisibility on proper divisors to global non-divisibility on all smaller indices.

Verification: the file compiles cleanly with no warnings and contains no `sorry`. Axiom audit shows the four metric results depend only on `propext, Classical.choice, Quot.sound`, and the two number-theoretic results depend only on `propext, Quot.sound`.

Each result carries a brief `-- !-- ... -- !--` proof sketch, the file includes a Lab Notebook block (Hypothesis / Result / Insight / Failure analysis), and the docstrings cite the related catalog theorems (`advantage_triangle`, `hybrid_argument`, `reduction_composition`, `prg_stretch_amplification`, `CarmichaelProof.bridge_lemma`). `FUTURE_DIRECTIONS.md` records the synthesis, a results summary, and five falsifiable research directions, each with a "The key insight is..." sentence and a "Why now?" justification (including closing the Carmichael tail and proving sharpness of the Lipschitz bound).