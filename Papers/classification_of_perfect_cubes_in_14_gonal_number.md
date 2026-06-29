# Computational Evidence: Perfect Cubes among 14-gonal Numbers

We study the Diophantine equation `P_14(n) = t^3`, where
`P_s(n) = ((s-2)n^2 - (s-4)n)/2`. For `s = 14` this simplifies to

```
P_14(n) = (12 n^2 - 10 n) / 2 = 6 n^2 - 5 n = n (6n - 5).
```

## 1. Small-case calculations

| n  | P_14(n) = n(6n-5) | perfect cube? | t |
|----|-------------------|---------------|---|
| 0  | 0                 | yes           | 0 |
| 1  | 1                 | yes           | 1 |
| 2  | 14                | no            |   |
| 3  | 39                | no            |   |
| 4  | 76                | no            |   |
| 5  | 125               | yes           | 5 |
| 6  | 186               | no            |   |
| 7  | 259               | no            |   |
| ...| ...               | ...           |   |

A brute-force search over `0 ≤ n ≤ 2000` (run with `#eval` in Lean) returns
exactly `n ∈ {0, 1, 5}`:

```
#eval (List.range 2000).filter (fun n => isCube (6*n*n - 5*n))  -- [0, 1, 5]
```

So the conjectural solution set is `(n,t) ∈ {(0,0), (1,1), (5,5)}`.

## 2. OEIS

- 14-gonal numbers `0,1,14,39,76,125,...`: OEIS A051866.
- The values `0,1,125` are the cubes `0^3, 1^3, 5^3`.

## 3. Counterexample hunt

No counterexample to the conjectured classification was found for `n ≤ 2000`.

## 4. Structural observations driving the proof

Let `g = gcd(n, 6n-5)`. Since `6n - 5 ≡ n (mod 5)` and `gcd(n, 6n-5) = gcd(n,5)`,
we have `g ∈ {1, 5}`.

* **Case A — `5 ∤ n`.** Then `n` and `6n-5` are coprime and their product is a
  cube, so (the exponent `3` being odd, over `ℤ`) each factor is itself a cube:
  `n = a^3`, `6n - 5 = b^3`, giving the cubic Thue equation `6a^3 - b^3 = 5`.
  Only `a = b = 1` (i.e. `n = 1`) is small; this is fully verified here as a
  structural splitting theorem.

* **Case B — `5 ∣ n`.** Write `n = 5m`. Then
  `P_14(5m) = 25 · m · (6m - 1)` with `gcd(m, 6m-1) = 1`. If `5 ∤ m` and
  `5 ∤ (6m-1)` then `5 ∤ m(6m-1)`, so `t^3 = 25·(unit mod 5)`, forcing
  `v_5(t^3) = 2`, which is impossible for a cube. Hence any solution with
  `5 ∣ n` must have `m ≡ 0` or `m ≡ 1 (mod 5)`. This valuation obstruction is
  fully verified here.

* **Mordell model.** Multiplying by `24`,
  `(12n - 5)^2 = 24 t^3 + 25`, an integral point on the elliptic
  curve `Y^2 = 24 X^3 + 25` (equivalently `V^2 = U^3 + 14400`).

The residual cubic Thue equations (`6a^3 - b^3 = 5` and the case-B descendants)
have no further solutions; this is the genuinely deep part and is recorded as a
conjecture in `FUTURE_DIRECTIONS.md`.
