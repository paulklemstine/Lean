# Computational Evidence

Evidence gathered *before* and *alongside* the formalisation in
`Catalog/Cryptography/FactoringBarriers/`. All numbers below were produced by
`#eval` inside the project's Lean 4 / Mathlib toolchain (exact integer
arithmetic for the number-theoretic tables, IEEE `Float` for the asymptotic
tables). They are exploratory data, not proofs; the corresponding proofs are
the `sorry`-free theorems cited after each table.

---

## 1. The structural core: congruences of squares

**Small cases.**

| `N`    | `x`  | `y` | `x² mod N` | `y² mod N` | `gcd(x−y, N)` | `gcd(x+y, N)` | factorisation |
|--------|------|-----|-----------|-----------|---------------|---------------|---------------|
| 8051   | 90   | 7   | 49        | 49        | **83**        | 97            | 8051 = 83·97 |
| 15     | 7    | 1   | 4         | 1 (via `a^s`, `s=2`, `a^4≡1`) | **3** | 5 | 15 = 3·5 |
| 91     | 2⁶=64| 1   | —         | —         | **7**         | 13            | 91 = 7·13 (order of 2 mod 91 is 12) |

Each row is an instance of `congruence_of_squares` / `order_finding_yields_factor`.

**Exhaustive counterexample hunt.** Over all `N ∈ [4,150]` and all
`x, y ∈ [0,N)` (≈ 1.1 · 10⁶ triples):

```
triples with N ∣ (x²−y²), N ∤ (x−y), gcd(x−y,N) trivial, and N ∤ (x+y)  :  0
triples with N ∣ (x²−y²), N ∤ (x−y), N ∤ (x+y), giving a proper split   :  18890
```

Zero violations — consistent with the theorem `congruence_of_squares`, which we
then proved unconditionally. The second count shows the reduction is not
vacuous: proper splits are abundant *once the congruence is handed to you*.
The whole difficulty sits in producing the congruence, which is the point of
the framework ("barrier 5": the exploitation step is free, the production step
is not).

**Sharpness probe.** Dropping the hypothesis `N ∤ (x+y)` breaks the conclusion:
`N = 15, x = 4, y = 11` gives `15 ∣ (x−y)(x+y)` but `gcd(x−y,15) = gcd(−7,15) = 1`.
This counterexample is itself formalised, as `congruence_of_squares_needs_hp`.

---

## 2. The asymptotic ladder

With `x = log N` (so `x ≈ 355` for a 512-bit modulus, `x ≈ 1420` for 2048-bit),
logarithms of the four cost shapes:

| `x` (= log N) | `log(exp(x/4))` | `log L[1/3,1](x)` | `log L[1/2,1](x)` | `log(x³)` |
|------|--------|--------|--------|--------|
| 50   | 12.50  | 9.15   | 13.99  | 11.74 |
| 100  | 25.00  | 12.85  | 21.46  | 13.82 |
| 200  | 50.00  | 17.77  | 32.55  | 15.89 |
| 355  | 88.75  | 23.05  | 45.66  | 17.62 |
| 710  | 177.50 | 31.28  | 68.27  | 19.70 |
| 1420 | 355.00 | 42.14  | 101.52 | 21.78 |

The ordering `poly ≺ L[1/3] ≺ L[1/2] ≺ exp(x/4)` is visible and stable, and the
gaps widen — exactly the content of `Lfun_strictly_intermediate`
(`L[α,c]` is superpolynomial *and* subexponential for `0 < α < 1`) and
`barrier_hierarchy`.

**Crossover points** (smallest integer `x` where the barrier overtakes the
polynomial):

```
L[1/3,1](x) > x³    first at x ≈ 132
L[1/3,1](x) > x⁵    first at x ≈ 842
exp(x/4)    > x¹⁰   first at x ≈ 215
```

These finite crossovers are what `Superpoly` asserts in the limit; the tables
confirm the limit is not an artefact of enormous constants for cryptographic
sizes.

---

## 3. The multiplicative trade-off

Optimal `k`-way trade-off cost `k · exp(x^{1/k})` at `x = 1000`:

| `k` | 1 | 2 | 3 | 4 | 5 | 6 | 8 | 10 | 12 |
|-----|---|---|---|---|---|---|---|----|----|
| cost | ∞ (overflow) | 1.08·10¹⁴ | 6.6·10⁴ | 1107 | 268 | 142 | 85.7 | 73.5 | 71.0 |

Two things are visible, and both are theorems in `TradeoffBarrier.lean`:

* for each **fixed** `k` the cost is superpolynomial in `x`
  (`tradeoff_cost_superpoly`) — the columns `k = 2, 3` are the quadratic-sieve
  and number-field-sieve regimes;
* letting `k` grow with `x` collapses the cost: the table bottoms out near
  `k ≈ log x ≈ 7`–`12` at a value of order `log x`
  (`tradeoff_unbounded_arity_is_poly` proves the bound
  `k·exp(x^{1/k}) ≤ e^e·(log x + 1)` at `k = ⌈log x⌉`; here
  `e^e·(log 1000 + 1) ≈ 120`, and the observed minimum is `71`).

This is the honest boundary of the barrier: it constrains *bounded-arity*
strategies only.

---

## 4. Fourier sampling

The smallest instance of `dft_lt_period_indistinguishable`: for `r = 2`,
`K = 1`, sampling only the zero frequency, the distinct signals
`v = (1, −1)` and `w = (0, 0)` on `ℤ/2ℤ` both have `𝓕v(0) = 𝓕w(0) = 0`.
More generally the kernel of `K < r` linear samples is nonzero by dimension
count, which is exactly how the theorem is proved; no numerical search is
needed or informative here, since the statement is an exact linear-algebra
fact.

---

## 5. The randomness/collision barrier

**Exhaustive check of blindness.** For every pair of primes `p, q ≤ 60` and
every pair `i ≠ j` in `[0, min(p,q))`:

```
pairs with gcd(|i−j|, pq) ≠ 1  :  0
```

Zero — the arithmetic trajectory really is blind for `min(p,q)` steps, which is
`arithmetic_trajectory_blind`.

**Contrast with the heuristic.** For `N = 8051 = 83 · 97` and the standard rho
iteration `x ↦ x² + 1 (mod N)` starting at `2`, the first collision modulo the
hidden prime `83` occurs between indices `4` and `9`. Here `√83 ≈ 9.1`, so the
birthday heuristic is accurate *on this trajectory* — while the worst case over
trajectories is `83`, as the previous check shows. This is exactly the gap the
file records: `N^{1/4}` is average-case, `√N` is what is provable in the worst
case.

---

## 6. OEIS

No new integer sequence arises from this work. The only integer sequences in
sight (divisor counts, orders modulo `N`) are classical and already catalogued
(e.g. A000005, A002326); we found nothing worth a new OEIS entry, and we make
no claim of one.
