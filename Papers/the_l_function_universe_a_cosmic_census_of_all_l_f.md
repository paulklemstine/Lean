# Computational Evidence: the L-function universe is countable

The project formalizes a cardinality dichotomy for spaces of Dirichlet series
`L(s) = Σ a(k) k^{-s}`, identified with their coefficient sequences `a : ℕ → ℂ`.

## 1. Small-case calculations

**Dirichlet characters (the concrete countable family).** For each modulus `n` the
number of Dirichlet characters mod `n` is `φ(n)` (for `n ≥ 1`):

| n | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|----|----|----|
| # characters mod n (= φ(n)) | 1 | 1 | 2 | 2 | 4 | 2 | 6 | 4 | 6 | 4 | 10 | 4 |

Each is finite, and the moduli are indexed by `ℕ`, so the total family
`Σ n, DirichletCharacter ℂ n` is a countable union of finite sets — countable.
The running total (number of characters of modulus `≤ N`) is finite for every `N`,
which is precisely the "enumerate the first 100" phenomenon:

    Σ_{n≤N} φ(n) :  1, 2, 4, 6, 10, 12, 18, 22, 28, 32, ...

This is the *totient summatory function* (OEIS **A002088**), confirming each finite
prefix of the enumeration is a genuine finite set.

## 2. The naive universe, by contrast, is a continuum

Without arithmetic constraints the coefficient sequences range over all of
`ℕ → ℂ`. Already the `{0,1}`-valued sequences biject with subsets of `ℕ`, of which
there are `2^{ℵ₀} > ℵ₀`. So the *unconstrained* universe is uncountable; the
countability is entirely due to the arithmetic axioms (periodicity/algebraicity of
coefficients, finite determining data).

## 3. The census slices are finite

Modelling an L-function by its finite determining packet
`(degree, conductor, root number, finitely many Euler-factor coefficients)`, the set
of packets whose invariants are all bounded by `N` is finite for every `N`, and
these finite slices exhaust the whole (countably infinite) universe. Concretely, for
each complexity bound the census is a finite subset of a finite product
`Iic N × Iic N × Icc(-N,N) × Iic N × {lists over [-N,N] of length ≤ N}`.

## 4. Counterexample hunt

The claim "the constrained universe is countable" is verified rather than refuted:
- periodic sequences over a countable alphabet: countable (proved, `periodicSeq_countable`);
- Dirichlet characters over all moduli: countable (proved, `dirichletCharFamily_countable`);
- finite-data Selberg packets: countably infinite (proved, `selbergDatum_countably_infinite`).
No counterexample is possible: countability of each family is a theorem, not a
conjecture, in the models used here.

## Summary

The formal artifacts (`NaiveUniverse.lean`, `PeriodicUniverse.lean`,
`SelbergCensus.lean`) turn these observations into fully checked Lean 4 proofs:
the naive universe is uncountable, but every arithmetically constrained model —
periodic-coefficient L-functions, Dirichlet L-functions, and finite-data Selberg
packets — is countable.
