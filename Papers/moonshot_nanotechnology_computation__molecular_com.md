# Computational Evidence

Concise numerical checks supporting the formalized theorems.

## 1. Molecular parallelism: work–time rectangle bound

The core claim is `W ≤ T · p` (work bounded by time × parallelism). Small cases,
taking a "full" schedule `ops t = p`:

| p (molecules) | T (steps) | max work T·p |
|---------------|-----------|--------------|
| 1             | 8         | 8            |
| 2             | 4         | 8            |
| 4             | 2         | 8            |
| 8             | 1         | 8            |

Doubling parallelism halves the time needed for the *same* total work `W = 8` —
exactly a factor-`p` speedup, never more. The product `T·p` is invariant.

## 2. No exponential speedup (fixed volume `P`)

With work `W(n) = 2^n` and a fixed molecule budget `P`, parallel time obeys
`T(n) ≥ 2^n / P`:

| n  | 2^n        | P=10^6 : lower bound 2^n/P |
|----|------------|-----------------------------|
| 20 | 1.05e6     | 1                           |
| 30 | 1.07e9     | 1073                        |
| 40 | 1.10e12    | 1.10e6                      |
| 60 | 1.15e18    | 1.15e12                     |

Even a mole-scale molecule budget (`P ≈ 6·10^23`) only shifts the crossover by
~79 in `n` (`log₂(6·10^23) ≈ 79`). The exponential wall is pushed, never removed —
matching `no_exponential_speedup`.

## 3. Storage / description bounds

`k` two-state molecules ⇒ at most `2^k` configurations.

| k  | 2^k        | vs 10^18 |
|----|------------|----------|
| 59 | 5.76e17    | < 10^18  |
| 60 | 1.15e18    | ≥ 10^18  |

So distinguishing `10^18` states needs `⌈log₂ 10^18⌉ = 60` molecules, i.e. `59`
never suffice. This is exactly `dna_density_bound` (`2^59 < 10^18 ≤ 2^60`) and
`dna_density_needs_more`.

## 4. No zero-test (CRN monotonicity), worked instance

Species `{A}`, reaction `r` with `reactant = product = 0` (a trivial always-enabled
reaction). Enabledness is `0 ≤ x`, true for **every** state, so it can never equal
the predicate `x A = 0`. Concretely, `r` is enabled both at `x A = 0` and `x A = 5`,
so no reaction's enabling condition can equal "A is absent". This is the finite
witness behind `no_zero_test`: monotone triggers cannot detect absence, the exact
gap that blocks register-machine simulation in the exact discrete model.

## Counterexample hunt

- Initially claimed `2^60 < 10^18`; a direct computation shows `2^60 ≈ 1.153·10^18 > 10^18`.
  Corrected the exponent to `59` (`2^59 ≈ 5.76·10^17 < 10^18`); now machine-checked
  via `norm_num`.
- No counterexamples found to the monotonicity, conservation, or work–time claims;
  all are proved for arbitrary parameters.

All quantitative statements are additionally verified inside Lean (`norm_num` /
`decide` / general proofs), so no separate scripting was required.
