# Computational Evidence — The Anti-Fibonacci Sequence

## 1. Small-case calculation

The mission brief lists the anti-Fibonacci sequence as `1, 1, 2, 4, 7, 11, 16, …`.
Its successive differences are `0, 1, 2, 3, 4, 5, …`, so the sequence satisfies the
first-order recurrence

```
A 0 = 1,   A (k+1) = A k + k     (0-indexed)
```

Direct evaluation (`#eval (List.range 12).map A`) gives

```
1, 1, 2, 4, 7, 11, 16, 22, 29, 37, 46, 56
```

which matches the brief exactly. The closed form `A k = 1 + k(k-1)/2`
(`#eval (List.range 12).map (fun k => 1 + k*(k-1)/2)`) produces the identical list,
confirming `2·A k + k = k² + 2`.

## 2. OEIS identification

The values `1, 1, 2, 4, 7, 11, 16, 22, 29, 37, 46, 56, …` are the shifted
**central polygonal numbers** / "lazy caterer" sequence **OEIS A000124**
(`a(n) = n(n+1)/2 + 1`), read from `n = -1`. In particular `A k = A000124(k-1)` for
`k ≥ 1`, with `A 0 = A 1 = 1`.

## 3. Asymptotics — counterexample hunt against the brief's numeric claims

| quantity | brief's claim | measured (k = 50 … 55) | verdict |
|---|---|---|---|
| `A k / k²` | `→ 1/4` | `0.4904, 0.4906, 0.4908, 0.4909, 0.4911, 0.4912` | **→ 1/2**, refutes `1/4` |
| `A(k+1)/A(k)` | oscillates in `[1,2]`, diverges | `1.0408, 1.0400, 1.0392, 1.0384, 1.0377, 1.0370` | **→ 1** monotonically, refutes oscillation |

(Computed with `Float.ofNat (A (k+50)) / Float.ofNat ((k+50)^2)` and the analogous
ratio.) Both brief claims are numerically false for the listed sequence. The correct
statements — proved formally — are `A k / k² → 1/2` and `A(k+1)/A(k) → 1`.

## 4. The golden-ratio contrast

For the Fibonacci sequence, `F(k+1)/F(k) → φ ≈ 1.618`. For the anti-Fibonacci sequence
the same ratio tends to `1`. Since `1 < φ`, the anti-Fibonacci ratio provably never
converges to `φ`: the sequence "avoids the golden ratio". This is the phenomenon that
survives scrutiny and is formalized as the flagship theorem.

## Summary

The only internally consistent reading of the brief is the recurrence forced by its own
listed terms. Under that reading the growth constant is `1/2` (not `1/4`), the ratio
converges to `1` (it does not oscillate), and the golden-ratio-avoidance statement is
true and non-trivial. The Lean file `AntiFibonacci.lean` proves all three corrected
statements with `0` sorries.
