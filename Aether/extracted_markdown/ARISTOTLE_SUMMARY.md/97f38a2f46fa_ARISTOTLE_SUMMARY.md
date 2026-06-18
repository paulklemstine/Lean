# Summary of changes for run acc6fa35-6ebb-4f8e-8e94-b6bb1caffd9e
This cycle developed and closed Fibonacci entry-point (rank-of-apparition) theory, eliminating real `sorry` placeholders and adding a new self-contained theorem file with Lab Notebooks, plus `FUTURE_DIRECTIONS.md`.

## What was done

**1. Closed an open `sorry` in the catalog.** In `Catalog/Speculative/AutoResearch/FibonacciEntryPointCharacterization.lean`, the previously deferred research target `fibEntryPt_mul_coprime` — the lcm law `α(a·b) = lcm(α a, α b)` for coprime `a, b` (where `α` is the least positive index `k` with `m ∣ F(k)`) — is now fully proved (`sorry = 0`). Updated its docstrings/declaration table from "conjecture (sorry)" to "proved" and added a Lab Notebook block; also removed a linter warning.

**2. New theorem file** `Catalog/Speculative/AutoResearch/FibonacciEntryPointReconstruction.lean` (self-contained, `import Mathlib` only, matching catalog convention), with these results, all proved `sorry`-free:
- `fibEntryPt_dvd_of_dvd` — monotonicity: `a ∣ b ⟹ α(a) ∣ α(b)`, unconditionally.
- `fibEntryPt_fib` — fixed-point law: `α(F n) = n` for `n ≥ 3` (so `α` left-inverts `F` and is surjective onto `[3, ∞)`).
- `fibEntryPt_lcm_dvd` — unconditional lower bound: `lcm(α a, α b) ∣ α(a·b)`.
- `fibEntryPt_two`, `fibEntryPt_four` — explicit values `α(2)=3`, `α(4)=6`.
- `fibEntryPt_lcm_strict` — a Critic counterexample: `α(2·2)=6 ≠ 3=lcm(α 2, α 2)`, proving coprimality is necessary for the lcm law and correcting a heuristic in the parent file (the defect is always a strict multiple — larger — not smaller).

**3. Notes.** Each major theorem carries a `-- !-- Lab Notebook -- !--` block (Hypothesis/Result/Insight/Failure analysis), and a Step-1 theorem-declaration table is included. `FUTURE_DIRECTIONS.md` (at the project root) contains the required `## Synthesis`, `## Results Summary`, and five falsifiable `## Research Directions` (factorization reconstruction of `α`; prime-power law and Wall–Sun–Sun primes; Carmichael's tail via apparition surjectivity onto primes; exact equality conditions without coprimality; generalization to strong divisibility sequences).

## Verification
Both files build successfully against the project's Mathlib (v4.28.0) toolchain. Axiom audit of the new/closed theorems shows only `propext`, `Classical.choice`, `Quot.sound`. A grep confirms no code-level `sorry` remains in either file (only the word inside comments/notebooks). No `axiom` or `@[implemented_by]` was introduced.

## Left open (documented, not regressed)
The hard infinite-tail `sorry` in `Shared/CarmichaelProof.lean` (Carmichael's primitive-divisor theorem for composite `n > 10000`) was intentionally not attempted: it requires Zsygmondy-type primitive-divisor theory for Lucas sequences that is absent from Mathlib. It is reframed and proposed as Research Direction 3, using this cycle's `fibEntryPt_fib` (every index `n ≥ 3` is the apparition index of `F n`) as the starting reduction.