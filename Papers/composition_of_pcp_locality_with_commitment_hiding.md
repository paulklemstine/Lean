# Computational evidence

All numbers below were produced by `#eval` inside Lean 4 / Mathlib (kernel-level
evaluation of the very `Finset` expressions that appear in the formal statements),
before the corresponding theorems were proved.

## 1. The opened view of the committed 2-query PCP for 3-colouring

Prover randomness is a colour permutation `π ∈ S₃` (`Equiv.Perm (Fin 3)`,
`|S₃| = 6`). On the challenged edge `(x, y)` the verifier opens the two symbols
`(π (c x), π (c y))`.

Fibre sizes of the map `π ↦ (π a, π b)` for `(a,b) = (0,1)`:

| target pair | (0,0) | (0,1) | (0,2) | (1,0) | (1,1) | (1,2) | (2,0) | (2,1) | (2,2) |
|---|---|---|---|---|---|---|---|---|---|
| # permutations | 0 | 1 | 1 | 1 | 0 | 1 | 1 | 1 | 0 |

For `(a,b) = (1,2)` the table is **identical**:

| target pair | (0,0) | (0,1) | (0,2) | (1,0) | (1,1) | (1,2) | (2,0) | (2,1) | (2,2) |
|---|---|---|---|---|---|---|---|---|---|
| # permutations | 0 | 1 | 1 | 1 | 0 | 1 | 1 | 1 | 0 |

So the opened pair is *uniform on the six ordered pairs of distinct colours and
independent of the colouring* — exactly what a simulator that does not know `c`
can reproduce. This is the computational shadow of sharp 2-transitivity of `S₃`,
formalized as `perm3_card_eq_one` and used in `zkSim_perfectly_simulates`.

## 2. Counterexample hunt: is the full symmetric group needed?

Replacing the prover's permutation randomness by the *cyclic* subgroup
(`c ↦ c + d`, `d ∈ ZMod 3`, order 3) gives, for an edge with `(c x, c y) = (0,1)`:

| target pair | (0,1) | (1,2) | (2,0) | others |
|---|---|---|---|---|
| # shifts | 1 | 1 | 1 | 0 |

while for an edge with `(c x, c y) = (0,2)`:

| target pair | (0,2) | (1,0) | (2,1) | others |
|---|---|---|---|---|
| # shifts | 1 | 1 | 1 | 0 |

The two distributions are **different**, and each one determines `c y - c x`.
Hence cyclic rerandomization leaks a bit of the witness on every edge: the
`PerfectlySimulatesOpened` hypothesis genuinely fails there. This ruled out the
cheaper `ZMod 3`-torsor randomization before any proof attempt, and motivated the
boundary results in `Catalog/MachineLearning/CommittedLocalOracleZKBoundary.lean`.

## 3. One-time-pad commitment fibres

For the coordinate-wise pad on two coordinates over `ZMod 2`, the number of pads
`ρ` producing a *fixed* commitment string is `1` for the message `(0,0)` and `1`
for the message `(0,1)`:

```
#eval #{ρ : Fin 2 → ZMod 2 | (fun i => 0 + ρ i) = 0}                 -- 1
#eval #{ρ : Fin 2 → ZMod 2 | (fun i => (if i = 0 then 0 else 1) + ρ i) = 0}  -- 1
```

Equal fibres for different messages is precisely the counting content of perfect
hiding (`fiberCount_congr`), here witnessed by the translation bijection used in
`otpOracle_hides`.

## 4. Failure probabilities in the boundary examples

* `leakyOracle` (identity commitment, one unopened coordinate carrying `1`):
  the honest transcript has real probability `1` and simulated probability `0`.
* `padOracle` with a simulator opening the wrong symbol: the exhibited honest
  transcript has real probability `1/2` and simulated probability `0`.

Both are proved in Lean (`leaky_hvzk_fails`, `pad_hvzk_fails`) by kernel
evaluation of the counting definitions, so these are verified facts, not merely
numerical observations.

## 5. OEIS

The only sequence appearing is the fibre profile `1,1,1,1,1,1` of the sharply
2-transitive action of `S₃`; the relevant count `n!/(n-2)! = n(n-1)` of ordered
distinct pairs (`6` for `n = 3`) is A002378 (oblong numbers). No search beyond
this was warranted.
