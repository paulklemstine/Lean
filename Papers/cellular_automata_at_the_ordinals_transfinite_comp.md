# Computational Evidence

Object under study: the one-dimensional **spreading cellular automaton** on cells `ℕ`,
with local rule

```
cell n is ON next step  ⇔  n = 0   (permanent source at the origin)
                         or  cell (n-1) was ON
```

viewed as a monotone operator `spread : Set ℕ →o Set ℕ`,
`spread S = {0} ∪ { m+1 | m ∈ S }`.

## 1. Small-case calculations (finite-time evolution from ∅)

Iterating from the empty configuration `∅`:

| step k | configuration `spread^[k] ∅` | as a set   |
| :----: | :--------------------------- | :--------- |
| 0      | `{}`                         | `Iio 0`    |
| 1      | `{0}`                        | `Iio 1`    |
| 2      | `{0,1}`                      | `Iio 2`    |
| 3      | `{0,1,2}`                    | `Iio 3`    |
| 4      | `{0,1,2,3}`                  | `Iio 4`    |
| k      | `{0,1,…,k-1}`                | `Iio k`    |

So after `k` steps exactly the first `k` cells are on. This is the formal content of
`spread_iterate : spread^[k] ∅ = Set.Iio k`.

Key observation: cell `k` is **never** on at finite stage `k` (nor at any earlier
stage). Hence no finite stage equals the fully-on configuration `univ`
(`finite_stage_not_univ`).

## 2. OEIS

The finite stages are the initial segments `{0,1,…,k-1}`; the "boundary" (rightmost on
cell after `k` steps) is `k-1`, i.e. the identity/counting sequence
`0,1,2,3,4,…` (OEIS **A001477**). The number of on-cells at step `k` is likewise `k`.
No nontrivial new integer sequence arises — the interesting phenomenon is the *ordinal*
closure behaviour, not an integer sequence.

## 3. Counterexample hunt (against the two claims)

Claim A: `∀ k : ℕ, spread^[k] ∅ ≠ univ`.
- Sampled `k = 0,…,1000`: in every case cell `k` is off, so the stage `≠ univ`.
  No counterexample. Proven in general in `finite_stage_not_univ`.

Claim B (limit rule): at the first limit ordinal `ω`, `lfpApprox spread ⊥ ω = univ`.
- The transfinite value at `ω` is the union of all finite stages
  `⋃ k, Iio k = ℕ = univ`, since every `n` appears in `Iio (n+1)`.
  No counterexample. Proven in `lfpApprox_omega_eq_iUnion` and
  `spread_reaches_univ_at_omega`.

Together: the *closure ordinal* of this automaton is exactly `ω` — the computation
provably cannot finish in finite time but finishes at the first transfinite stage.

## 4. Table: finite vs. transfinite time

| time                | value                         | complete? |
| :------------------ | :---------------------------- | :-------: |
| `k` (finite)        | `Iio k` (proper subset)       | no        |
| `ω` (first limit)   | `univ = spread.lfp`           | yes       |

This is the numerical shadow of the formal bridge theorem `transfinite_computation`.

## Why heavier computation is unnecessary

The claims are *uniform in `k`* and are settled by exact symbolic computation
(`spread^[k] ∅ = Iio k`) rather than by sampling; the finite-case table above is a
sanity check, and the transfinite behaviour is a closed-form union. All statements are
machine-checked in `TransfiniteComputation.lean` with no `sorry` and only the standard
axioms `propext, Classical.choice, Quot.sound`.
