# Skip Evidence Justification

The three results closed this cycle (`value_eq`, `valid_iff`,
`factorial_value_unique_via_mixed`) are **transport identities**: they assert that
the general mixed-radix value/validity notions specialize *definitionally* to the
factoradic ones under the base choice `bᵢ = i + 1`, together with the running
product identity `∏_{j<i}(j+1) = i!`. There is no universal claim over an infinite
family of inputs to sample, and no candidate counterexample to hunt: each is an
equality (or biconditional) that either holds by rewriting or fails on the first
input. Small-case checks (`k = 0, 1, 2`) are subsumed by the closed-form proofs
themselves. Computational evidence is therefore unnecessary for these results.

For the one obstruction left open — the infinite composite tail of Carmichael's
Fibonacci primitive-divisor theorem — the *finite* range `13 ≤ n ≤ 10000` is
already handled by an exhaustive computation inside the file, which is the
strongest form of small-case evidence available; the remaining range is infinite
and cannot be settled by sampling, only by the structural argument sketched in
`FUTURE_DIRECTIONS.md`.
