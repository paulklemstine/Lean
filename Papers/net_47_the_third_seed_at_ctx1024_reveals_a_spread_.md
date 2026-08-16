# Computational evidence — NET-47 knee spread as binary staircase numbers

All computations below were run inside Lean 4 (`#eval`, exact rational / natural arithmetic),
so every number quoted here is machine-computed, not hand-derived.

## 1. The NET-47 knee triple as binary numbers

The measured knee distribution at `(d = 4, ctx = 1024)` is `{96, 112, 128}`, with product point
`d·ctx/32 = 128 = 2^7`.  Binary expansions (`Nat.digits 2`, least-significant first):

| k | binary (msb first) | shape |
|---|---|---|
| 96 | `1100000` | `2^5·(2^2−1) = 2^7 − 2^5` |
| 112 | `1110000` | `2^4·(2^3−1) = 2^7 − 2^4` |
| 128 | `10000000` | `2^7` |

So each measured knee is a *binary staircase number* `stair b j = 2^b (2^j − 1)`: a block of `j`
ones followed by `b` zeros.  The triple is `{2^7 − 2^5, 2^7 − 2^4, 2^7}` — the top of the ladder
`2^n − 2^{n−j}` together with its supremum `2^n`.

## 2. The staircase ladder of weight 7

`#eval (List.range 8).map (fun j => stair (7-j) j)` gives

```
[0, 64, 96, 112, 120, 124, 126, 127]
```

i.e. `2^7 − 2^{7−j}` for `j = 0,…,7`.  The observed knees `96, 112` are the second and third
rungs; `128 = 2^7` is the sup of the ladder.  The gaps are `2^5, 2^4, 2^3, …`, so consecutive
rungs halve their distance to `2^7` — the "±16 half-grid-step jitter" of the round is exactly the
statement that `112` is the midpoint of `96` and `128` (`2·112 = 96 + 128`, `8·112 = 7·128`).

## 3. Divisor data (the arithmetic-function boundary)

`∑ d ∣ k` versus `2k`:

| k | σ(k) | 2k | class |
|---|---|---|---|
| 96 | 252 | 192 | abundant |
| 112 | 248 | 224 | abundant |
| 128 | 255 | 256 | deficient |

The two *jittered* knees are abundant, the *product point* is deficient: the jitter crosses the
perfect-number boundary.  The general rule found and then proved: `stair b j` is abundant when
`j ≥ 2` and `b ≥ j`; deficient when `j = 1` (a power of two).

## 4. Perfect members of the family (counterexample hunt for the classification)

`#eval` over `0 ≤ b, j < 6` selecting `σ(stair b j) = 2·stair b j`:

```
[(1, 2, 6), (2, 3, 28), (4, 5, 496)]
```

Exactly the pairs with `b = j − 1` **and** `2^j − 1` prime.  Note `(3,4)` (i.e. `120 = 2^3·15`) is
absent, because `15` is not prime — this rules out the naive conjecture "`b = j−1` suffices" and
matches the Euclid–Euler-type classification proved in
`Catalog/NumberTheory/KneeStaircaseDivisorSpectrum.lean`.  (`120` is itself a rung of the weight-7
ladder, so the counterexample lives inside the very ladder under study.)

## 5. Abundancy index along the shift direction

`σ(stair b 3)/stair b 3` for `b = 0,…,7`:

```
8/7, 12/7, 2, 15/7, 31/14, 9/4, 127/56, 255/112
```

strictly increasing, converging to `2·σ(7)/7 = 16/7 ≈ 2.2857` (`255/112 ≈ 2.2768`).  This is the
computational shadow of the two proved statements: strict monotonicity of the abundancy index in
`b`, and the limit `2σ(m)/m`.

## 6. OEIS

The staircase family `2^b(2^j − 1)` (numbers whose binary expansion is a single block of ones
followed by zeros) restricted to `b = 0` is the Mersenne sequence A000225 (`1, 3, 7, 15, …`); the
weight-7 ladder `64, 96, 112, 120, 124, 126, 127` consists of the numbers `2^7 − 2^i`.  The perfect
members found in §4 are `6, 28, 496` = A000396.  No further sequence lookup was needed: every
claim below is proved symbolically for all `b, j`, not extrapolated from a finite table.
