# Computational Evidence — The Anti-Fibonacci Sequence

Sequence studied: `A(0) = 1`, `A(n+1) = A(n) + n`.

## 1. Small-case calculations

`#eval (List.range 12).map A` yields:

```
n     0  1  2  3  4  5   6   7   8   9  10  11
A(n)  1  1  2  4  7  11  16  22  29  37  46  56
```

These match the sequence quoted in the brief (`1, 1, 2, 4, 7, 11, 16, …`).

## 2. OEIS identification

The terms `1, 2, 4, 7, 11, 16, 22, 29, 37, 46, 56` are the **central polygonal
numbers / lazy caterer numbers** `A000124`, with closed form `n(n-1)/2 + 1`.
With the repeated leading `1` (the greedy "dodge the sum" start), the sequence is
`A(n) = n(n-1)/2 + 1`, equivalently the subtraction-free identity

```
2·A(n) + n = n² + 2   (verified for all n ≤ 11 by #eval, then proved by induction).
```

## 3. Counterexample hunt against the brief's conjectures

The brief proposed three numeric claims. Direct computation **refutes** all three:

* **Claim (a): `A(n) ~ n²/4`, ratio `A(n)/n² → 1/4`.**
  From `2·A(n) = n² − n + 2` we get `A(n)/n² → 1/2`, not `1/4`.
  E.g. `A(11)/11² = 56/121 ≈ 0.463`, already far above `0.25` and climbing toward `0.5`.
  **Refuted** (the correct constant is `1/2`; proved as `tendsto_div_sq`).

* **Claim (b): `A(n+1)/A(n)` oscillates in `[1,2]` and does not converge.**
  Consecutive ratios: `1, 2, 2, 1.75, 1.571, 1.454, 1.375, 1.318, 1.276, 1.243, 1.217, …`
  — strictly decreasing after the second term and clearly converging to `1`.
  **Refuted** (the ratio converges, to `1`; proved as `tendsto_ratio_one`).
  Since `1 ≠ φ = (1+√5)/2 ≈ 1.618`, the sequence provably **avoids the golden ratio**
  (proved as `ratio_avoids_goldenRatio`).

* **Claim (c): `A` always avoids being a Fibonacci-style sum.**
  `#eval (List.range 12).filter (fun n => A (n+2) == A (n+1) + A n)` returns `[0, 3]`:
  the relation `A(n+2) = A(n+1) + A(n)` holds at `n = 0` (`2 = 1+1`) and `n = 3`
  (`11 = 7+4`), and **nowhere else**; for `n ≥ 4` the sequence strictly undershoots.
  **Refuted as stated** (there are exactly two coincidences); the correct statement is
  the characterisation `fibRelation_iff` plus the eventual strict inequality
  `fibRelation_lt`.

## 4. Table: A(n)/n² approaching 1/2

```
n        A(n)/n²
10       0.4600
100      0.4951
1000     0.499501
10000    0.4999500
```

The empirical trend confirms convergence to `1/2` at rate `Θ(1/n)`, consistent with
`A(n)/n² = 1/2 − 1/(2n) + 1/n²`.

## Conclusion

The concrete data pinned down the exact closed form and refuted every quantitative
claim in the brief, replacing them with the correct, proven statements now in
`AntiFibonacci.lean`.
