# Summary of changes for run b61204e6-30d6-4a6f-a1bc-3467550e8af2
Built a new, fully-proved Lean 4 bridge library on the Fibonacci **rank of apparition** in `Catalog/Bridges/FibRankApparition.lean` (no `sorry`; main results verified to use only the standard axioms `propext`, `Classical.choice`, `Quot.sound`).

Definitions: `appSet m` (positive indices where `m ∣ Nat.fib n`) and `rankApp m := sInf (appSet m)`.

Main theorems (all proved):
- `dvd_fib_iff_rankApp_dvd` — the divisibility profile `m ∣ F n ↔ rankApp m ∣ n`, holding for **every** positive modulus (not just prime powers).
- `fib_divisor_set_eq_multiples` — `{n | m ∣ F n}` is exactly the multiples of `rankApp m`.
- `rankApp_coprime_mul` — coprime composition `rankApp (m·n) = lcm (rankApp m) (rankApp n)`.
- `carmichael_fib_witness` — for coprime `m,n > 1`, the composite `m·n` is non-prime yet its Fibonacci divisibility test is governed entirely by the single index class `lcm (rankApp m) (rankApp n)` (Carmichael-type indistinguishability).

Supporting results: existence of the rank of apparition (`exists_pos_dvd_fib`, a Pisano-period fact absent from Mathlib, proved by pigeonhole on the invertible pair map `n ↦ (F n, F(n+1))` in `ZMod m`), the defining minimality/membership lemmas, both directions of the transfer law, and a `decide`-based characterization (`rankApp_eq_of`) giving concrete computed ranks plus the worked composite witness `rankApp 10 = 15`.

Key finding (recorded in the in-file Lab Notebook): the converse divisibility law needs no p-adic valuation-depth machinery — the single identity `Nat.fib_gcd` collapses the prime-power valuation ladder and makes apparition arithmetic governed purely by gcd/lcm index combinatorics. This factors the divisibility step behind the primitive-divisor work in `Shared/CarmichaelProof.lean` (which also pivots on `Nat.fib_gcd`).

Deliverables: the `.lean` file contains brief proof-sketch comment blocks and a Lab Notebook (Hypothesis/Result/Insight/Failure). `FUTURE_DIRECTIONS.md` (project root) gives a synthesis, results summary, and five falsifiable conjectures (quantitative Pisano bounds, rank/period ratio multiplicativity, Fibonacci-pseudoprime witnesses, Lucas-sequence generalization, and an entropy-based Carmichael census), each with a "key insight" and "why now" justification.