# Computational Evidence — 14-gonal numbers that are fourth powers

## The equation

The `n`-th polygonal number of order `k` is `P_k(n) = ((k-2)·n² − (k-4)·n)/2`.
For `k = 14` this gives the **14-gonal number**

```
P_14(n) = 6·n² − 5·n.
```

We study the Diophantine equation `P_14(n) = t⁴`, i.e.

```
6·n² − 5·n = t⁴.
```

## 1. Small-case calculation (search over n)

For each integer `n` we test whether `6n² − 5n` is a perfect fourth power.
Values of `6n² − 5n` for small `|n|`:

| n  | 6n²−5n | fourth power? | t |
|----|--------|---------------|---|
| -3 | 69     | no            |   |
| -2 | 34     | no            |   |
| -1 | 11     | no            |   |
| 0  | 0      | yes           | 0 |
| 1  | 1      | yes           | ±1 |
| 2  | 14     | no            |   |
| 3  | 39     | no            |   |
| 4  | 76     | no            |   |
| 5  | 125    | no            |   |

A wide brute-force scan (|n| ≤ 10⁵) finds exactly the following solutions:

```
(n, t) ∈ {(0, 0), (1, 1), (1, -1), (-2000, 70), (-2000, -70)}.
```

Check of the large solution:  `6·(-2000)² − 5·(-2000) = 24·10⁶ + 10⁴ = 24 010 000 = 70⁴`.
(`70² = 4900`, `4900² = 24 010 000`.)  ✓

## 2. The Pell / quartic reduction

Completing the square (multiply by 24):

```
24·(6n² − 5n) = (12n − 5)² − 25,
```

so `6n² − 5n = t⁴` is equivalent to

```
(12n − 5)² − 24·t⁴ = 25.
```

Setting `x = 12n − 5`, every solution gives an integer point on

```
x² − 24·t⁴ = 25,      x ≡ 7 (mod 12).
```

| solution n | x = 12n−5 | t  | x² − 24t⁴ |
|------------|-----------|----|-----------|
| 0          | −5        | 0  | 25        |
| 1          | 7         | ±1 | 49 − 24 = 25 |
| −2000      | −24005    | ±70| 576 240 025 − 576 240 000 = 25 |

## 3. Descent structure

Write the equation as the product `n·(6n − 5) = t⁴`.

* `gcd(n, 6n−5)` divides `(6·n) − (6n−5) = 5`, hence is `1` or `5`.
* `gcd = 5  ⇔  5 ∣ n`.

**Coprime branch (`5 ∤ n`).**  `n` and `6n−5` are coprime and their product is a
fourth power, so each is `±` a fourth power.  With `n > 0` this forces
`n = a⁴` and `6n − 5 = b⁴`, i.e. the Thue equation `6a⁴ − b⁴ = 5`, whose only
nonnegative solution is `(a,b) = (1,1)`, giving `n = 1`.

**Divisible branch (`5 ∣ n`).**  Write `n = 5m`; then
`6n² − 5n = 25·m·(6m − 1)`, and `gcd(m, 6m−1) = 1`.  Since the product is a
fourth power and `25 ∣ t⁴`, we get `5 ∣ t`, `t = 5s`, and

```
m·(6m − 1) = 25·s⁴.
```

For the solution `n = −2000` we have `m = −400 = −25·2⁴`, `6m − 1 = −2401 = −7⁴`,
and `s = 14` (`t = 70`), since `25·2⁴·7⁴ = 25·14⁴`.

## 4. Counterexample hunt

No counterexample to the five-solution claim was found in the range `|n| ≤ 10⁵`.
The two non-trivial residue obstructions checked (`mod 16` and `mod 5`) are both
*consistent* with the known solutions and do **not** rule out further solutions —
confirming that the completeness statement is genuinely a Thue-equation-level fact,
not an elementary congruence fact.

## 5. OEIS

The 14-gonal numbers `P_14(n)` for `n ≥ 0` are `0, 1, 14, 39, 76, 125, …`
(OEIS A051866, "14-gonal (tetradecagonal) numbers").  Their intersection with the
fourth powers `0, 1, 16, 81, 256, …` (OEIS A000583) is `{0, 1, 24010000}`
among the values realised by the listed `n`.
