# Summary of changes for run 86c1be56-59fe-4fdb-a764-58ba4fc734a8
Ran a NumberTheory research cycle on Fibonacci ranks of apparition and primitive prime divisors (Carmichael's theorem direction), extending the catalog's scattered/computational Carmichael material into clean, fully-verified theory.

Deliverables (all compile cleanly via `lake env lean`, 0 sorries, only standard axioms `propext`/`Classical.choice`/`Quot.sound`):

1. `Catalog/Speculative/AutoResearch/FibonacciPrimitiveDivisors.lean` — a self-contained rank-of-apparition toolkit with inline `-- !-- Lab Notes -- !--` blocks recording hypotheses, experiments, and a failure analysis. Main proved results:
   - `fib_strictMonoOn_two`: `fib` is strictly monotone on indices ≥ 2.
   - `fib_dvd_iff_of_three_le`: the Fibonacci divisibility lattice — for `m ≥ 3`, `F m ∣ F n ↔ m ∣ n`.
   - `fibRank` (rank of apparition) with `fibRank_pos_of_exists`, `fibRank_dvd_fib`, `fibRank_min`, and `fibRank_dvd_index` (rank divides any index where the prime appears — no primality needed).
   - `fib_dvd_iff_fibRank_dvd`: full appearance characterisation `p ∣ F n ↔ (p appears) ∧ fibRank p ∣ n`.
   - `primitive_iff_fibRank_eq`: `p` is a primitive prime divisor of `F n` iff `fibRank p = n`.
   - `fib_primitive_divisor_prime`: the prime-index case of Carmichael's theorem.

2. `Catalog/Shared/CarmichaelHelper.lean` — supplies `fib_primitive_divisor_prime` (with lab notes), the previously-missing dependency referenced by the existing `Shared/CarmichaelProof` and `Speculative/AutoResearch/CarmichaelComposite` files; proved fully via the `Nat.fib_gcd` strong-divisibility argument.

3. `Catalog/Speculative/AutoResearch/FUTURE_DIRECTIONS.md` — five precise, falsifiable conjectures for follow-up: the law of apparition (rank divides `p − (5/p)`), prime-power rank multiplicativity / Wall–Sun–Sun gate, a primitive-part lower bound `Φ*(n) > n` as the engine for the open large-composite case, the full exceptional-set Carmichael statement, and a Lucas-sequence generalization of the toolkit.

Scope note: the genuinely hard remaining open item — the large composite index case (`n > 10000`) currently left as a `sorry` in `Shared/CarmichaelProof.lean` — requires analytic primitive-part bounds and is documented as conjecture C3/C4 rather than fixed. Pre-existing catalog files were left intact. I followed the constraint to avoid prose articles, Python, widgets, or package files; all new work is standard Lean 4 plus the required FUTURE_DIRECTIONS.md and inline lab notes.