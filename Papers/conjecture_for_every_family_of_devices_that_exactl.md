# Computational Evidence: Metric Refinement of Oracle-Loading Capacity

Before formalizing, we sanity-checked the core inequalities on small cases. The
theory reduces every claim to the size of the embedded bit-cube `{0,1}^n`, so the
evidence is elementary but pinpoints exactly which quantities must appear.

## 1. The counting bound `2^n ≤ |State|`

An exact `n`-bit loader is an injection `{0,1}^n ↪ State`. First values:

| n | 2^n  |
|---|------|
| 0 | 1    |
| 1 | 2    |
| 2 | 4    |
| 3 | 8    |
| 4 | 16   |
| 8 | 256  |

Any finite state space must dominate this column for the loader to exist, and an
*ideal* loader must dominate it for **every** `n` — forcing an infinite space.
This matches OEIS A000079 (powers of two), the cardinality of `{0,1}^n`.

## 2. Packing → energy–precision tradeoff

Take a packing law `|S| ≤ (V/ε)^d` for an ε-separated set `S`. With the loader's
`2^n`-point separated set:

    2^n ≤ (V/ε)^d   ⇒   n·log 2 ≤ d·(log V + log(1/ε)).

Numerical check (V = 1, d = 1): to resolve `n = 10` bits we need
`log(1/ε) ≥ 10·log 2 ≈ 6.93`, i.e. `ε ≤ 2^{-10} ≈ 9.8e-4`. Halving the tolerable
error (one more bit of precision) buys exactly one more resolved oracle bit — the
linear-in-`n` behaviour the conjecture predicted. This is dimensional bookkeeping,
so no counterexample search is needed: the inequality is an identity after taking
logs of a true numeric inequality.

## 3. Compactness obstruction

A uniform-margin loader of *all* oracles yields an infinite `ε`-separated set. In a
compact metric space at scale `ε/2`, finitely many balls cover everything, yet each
ball can hold at most one separated point — an immediate pigeonhole contradiction.
Test on the finite prefix: at scale `ε/2` a compact space covered by `N` balls
admits at most `N` separated points, so it can resolve at most `⌊log₂ N⌋` bits. No
finite `N` resolves all bits.

## 4. Erasure entropy

Uniform prior over `2^n` strings has Shannon entropy `log(2^n) = n·log 2` nats
= `n` bits. Checked: n = 3 gives `3·log 2 ≈ 2.079` nats = `3` bits. This is the
Landauer floor for resetting the loader.

## Conclusion

The computational landscape is fully consistent with the four conjectured
refinements; all reduce to the single injective encoding `{0,1}^n ↪ State` and to
elementary properties of logarithms, packing, and total boundedness. No
counterexamples arise, so we proceed to formal proof.
