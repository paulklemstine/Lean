# Computational Evidence: the restricted binomial GCD `F`

Definitions used throughout:

- `F(k) = gcd_{2 ≤ q ≤ k}   C(q·k, k)`   (this cycle's object)
- `D(k) = gcd_{2 ≤ q ≤ k+1} C(q·k, k)`   (OEIS A080170)
- `P(n) = max_{p ∣ n} p^{v_p(n)}`        (largest exact prime-power component)

All values below were produced by direct evaluation in Lean (`#eval`).

## 1. Small-case table of `F(k)`

```
k :  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20
F : 6  4  5  3  7  8  9  5 11  2 13  7  5 16 17  9 19  5  7

k : 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40
F : 11 23  4 25 13 27  7 29  1 31 32 11 17  7  3 37 19 13  2 41
```

## 2. The mission conjecture is false in BOTH directions

Mission conjecture H0: `F(k) = 1 ⟺ k is not a prime power`.

- `⇒` direction fails at `k = 6`: `6` is **not** a prime power, yet `F(6) = 7 ≠ 1`.
  (Reason: `6 + 1 = 7` is prime, so `7 ∣ F(6)`.)
- `⇐` direction fails at `k = 29`: `29` **is** a prime power (it is prime), yet
  `F(29) = 1`.  (Reason: `29 + 1 = 30 = 2·3·5` is far from a prime power.)

So the predicate "`k` is a prime power" is the **wrong index**.

## 3. The correct criterion is the A080170 dominance test on `k + 1`

Tested for all `2 ≤ k ≤ 200`:

```
F(k) = 1   ⟺   P(k+1)^2 < k + 1
```

i.e. exactly the same dominance criterion that governs `D(k) = A080170(k)`,
but read at the index `k + 1`.  No counterexample was found in the range.

Moreover `F(k) = D(k)` for every `3 ≤ k ≤ 200`; the two sequences differ only
at `k = 2` (where the extra term `q = k+1 = 3`, `C(6,2) = 15`, changes the gcd).

## 4. Prime fibre `k = p - 1`

For every prime `p ≤ 60`, the `p`-adic valuation `v_p(F(p-1)) = 1`:
`p ∣ F(p-1)` but `p² ∤ F(p-1)`.  The minimiser of the carry count is the
central term `q = 2`, which survives the truncation of the index range
(`2 ≤ p - 1` whenever `p ≥ 3`).

## 5. OEIS

`D(k)` is OEIS **A080170**.  The truncated variant `F(k)` agrees with `A080170`
for `k ≥ 3` on the tested range, so it is the same sequence up to the initial
term; the interest is the *criterion* rephrased in the corrected index.
