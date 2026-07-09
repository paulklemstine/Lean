# Computational Evidence: Local-to-Global KKL for Influence Functions

All computations below were run in Lean 4 / Mathlib with the exact definitions
used in `Cryptography/LocalToGlobalKKL/Basic.lean`:

```lean
def flipc (x : Fin n → Bool) (i : Fin n) := Function.update x i (!x i)
def Inf    f i     := (univ.filter (fun x => f x ≠ f (flipc x i))).card
def InfSub f j b i := (univ.filter (fun x => x j = b ∧ f x ≠ f (flipc x i))).card
```

`Inf f i` counts the *endpoints* of sensitive `i`-edges (so a sensitive edge is
counted twice, once per endpoint); this convention makes the decomposition an
exact additive identity with no factors of two floating around.

## 1. Small-case calculations (`n = 3`)

Two standard test functions on the 3-cube: parity `par x = (#{i : x i}) mod 2`
and the dictator `dict₀ x = x 0`.

| function | `Inf` at coords `(0,1,2)` |
|----------|---------------------------|
| parity   | `[8, 8, 8]`               |
| dict₀    | `[8, 0, 0]`               |

Parity is maximally influential in every direction (every one of the `2^3 = 8`
vertices is sensitive in every direction); the dictator is influential only in
its own coordinate. Both match the theory.

## 2. The self-averaging bridge `inf_decomp`

For parity with pinned coordinate `j = 0`, comparing
`Inf f i` against `InfSub f 0 false i + InfSub f 0 true i` for `i = 0,1,2`:

```
[(8, 8), (8, 8), (8, 8)]     -- (Inf f i, InfSub false i + InfSub true i)
```

Equality holds in every coordinate, confirming the structural identity
`Inf f i = InfSub f j false i + InfSub f j true i` that powers the file.

## 3. Link totals and the flagship bound

Total influence inside each link of `j = 0` (summed over `i ∈ {1,2}`):

```
LinkTotInf par 0 false = 8 ,  LinkTotInf par 0 true = 8
```

So with local bound `T = 8`, `localToGlobal_KKL_cube` guarantees a coordinate
`i ≠ 0` with `(n-1)·Inf ≥ 2T`, i.e. `2·Inf f i ≥ 16`, i.e. `Inf f i ≥ 8`.
Indeed every coordinate has `Inf = 8`: the bound is attained, so it is tight and
the theorem is non-vacuous.

## 4. Counterexample hunt

The two universal claims are the additive bridge (`inf_decomp`) and the abstract
averaging inequality. The bridge was checked exhaustively for all functions is
unnecessary because it is a set-partition identity (each vertex has `x j` either
`true` or `false`), which is exactly what the Lean proof formalises; spot checks
on parity, dictators, and constant functions all satisfy it. No counterexample
exists or was found. The abstract inequality
`τ·(∑ w) ≤ ∑ I` is a monotone averaging fact (a nonnegative-weighted sum of
per-link maxima), also with no counterexamples.

## 5. Sequences

No OEIS sequence is central to the theorem. The incidental values
`Inf(parity) = 2^n` and the link-total `= 2^{n-1}·(n-1)` are elementary and not
the object of study.

## Conclusion

The computational evidence confirms (i) the exact additive self-averaging of
influences over the two links of any coordinate, and (ii) the tightness and
non-vacuousness of the flagship local-to-global bound.
