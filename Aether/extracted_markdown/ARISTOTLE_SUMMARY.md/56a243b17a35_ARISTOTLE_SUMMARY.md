# Summary of changes for run 69d483d7-80ee-421c-97f9-0d5eff81a5d7
## Summary

Working in the `Shared` domain on Carmichael's primitive-divisor theorem for Fibonacci numbers, I restored a broken build and closed the tractable sorry, then went deeper by proving a new infinite-family result.

### Build fix + sorry closed
- `Shared/CarmichaelProof.lean` and `Speculative/AutoResearch/CarmichaelComposite.lean` both `import Shared.CarmichaelHelper`, but that file was **missing**, so the Carmichael chain did not compile. I recreated `Shared/CarmichaelHelper.lean` and gave a **complete, verified proof** of its key result `fib_primitive_divisor_prime` — the prime-index case of Carmichael's theorem (every prime factor of `F(p)` is primitive, via the Fibonacci gcd identity). This closes the prime-case sorry and unbreaks the build.

### New verified mathematics (going deeper)
- `Shared/FibCarmichaelFamilies.lean` — a **complete elementary proof for the infinite composite family `n = 2p`** (`p` prime `≥ 5`): `fib_primitive_divisor_two_mul_prime`. It is built from six fully-proved helper lemmas (the doubling identity `F(2n)=F(n)·L(n)`, `gcd(F n, L n) ∣ 2`, the parity law `2 ∣ F n ↔ 3 ∣ n`, the divisor structure of `2p`, and coprimality of `F(p)` with its Lucas companion). Includes sanity `example`s (`F 10 = 55 = 5·11`) and a full Lab Notes block, with the boundary `p = 3` (`n = 6`, a genuine Carmichael exception) identified by adversarial review.
- `Shared/FibCarmichaelUnion.lean` — `fib_primitive_divisor_covered`, a unified statement over an explicit covered index set, reusing the two cases (this file consumes the catalog result `fib_primitive_divisor_prime`).

All new main theorems have **0 sorries** and verify with only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`); no `native_decide`-only or trivial results. Each new file contains a `-- !-- Lab Notes -- !--` block documenting the Hypothesize → Experiment → Analyze → Critique → Synthesize loop.

### Deliverables
- `Shared/FUTURE_DIRECTIONS.md` — 5 falsifiable conjectures derived from this cycle, each with a "The key insight is…" sentence and a "Why now?" justification (e.g. extending the companion method to `n = pq`, a Lucas-number library as the keystone, the abundancy threshold `σ(n) ≤ 2n` as the sharp boundary for the elementary bound, and generalisation to Lucas sequences toward Zsygmondy).

### Honest status of the remaining sorry
One sorry remains: the **arbitrary composite tail `n > 10000`** in `Shared/CarmichaelProof.lean`. This is the deep Zsygmondy-type core of Carmichael's theorem — for indices with many proper divisors the elementary gcd/doubling arguments provably do not suffice (the crude product bound loses a factor `φ^{σ(n)−2n}`, failing for abundant `n`). A full proof needs the cyclotomic factorisation `Φ_n = ∏_{d|n} F(d)^{μ(n/d)}` and the size bound `Φ_n ≈ φ^{ϕ(n)} > n`, infrastructure absent from the underlying library. I replaced the bare `sorry` with a detailed explanatory comment and pointed to `FUTURE_DIRECTIONS.md`. This is the single, clearly-documented open step.