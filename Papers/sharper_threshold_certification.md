# Computational evidence — BB84 QBER threshold enclosure

All numbers below were produced with exact rational (`fractions.Fraction`) and
50–60 digit decimal arithmetic, *before* the Lean formalization; every claim that
appears in the Lean files is proved there and does not rely on these
computations.  This note records the exploratory data that guided the choice of
certificates.

## 1. The object

The asymptotic one-way BB84 secret-key rate (Shor–Preskill/CSS) is
`r(Q) = 1 - 2 H₂(Q)` bits, equivalently `log 2 - 2 · binEntropy Q` nats.
`p⋆` denotes its unique zero in `[0, 1/2]`.

High-precision bisection (60 digits) gives

```
p⋆ = 0.110027864438359551261811704334989460177114905091894934278004…
r(0.11) = 1.16506722613005244605552265379794172165176808062796645·10⁻⁴ nats
H₂'(0.11) = log(89/11) = 2.09074109…
```

## 2. Certificates: turning `log` comparisons into integer comparisons

For `p = a/(a+c)` one has, exactly,

```
binEntropy(a/(a+c)) < (log 2)/2   ⟺   (a+c)^(2(a+c)) < 2^(a+c)·a^(2a)·c^(2c).
```

Small-case table (all verified by exact integer arithmetic, and all reproved in
Lean by `decide`):

| `a/(a+c)` | integer certificate | digits | holds? | conclusion |
|---|---|---|---|---|
| `1/16`   | `16^32 < 2^16·1^2·15^30` | 39 | yes | `p⋆ > 0.0625` |
| `1/8`    | `2^8·1^2·7^14 < 8^16` | 15 | yes | `p⋆ < 0.125` |
| `11/100` | `100^200 < 2^100·11^22·89^178` | 401 | yes | `p⋆ > 0.11` |
| `111/1000` | `2^1000·111^222·889^1778 < 1000^2000` | 6001 | yes | `p⋆ < 0.111` |
| `1101/10000` | `2^10^4·1101^2202·8899^17798 < 10^4^20000` | 80001 | yes | `p⋆ < 0.1101` |
| `79/718` | `718^1436 < 2^718·79^158·639^1278` | 4102 | yes | `p⋆ > 79/718` |

Cost observation: the integer `(a+c)^(2(a+c))` has `Θ(b log b)` digits for
`b = a+c`, and kernel `Nat.pow` unfolds linearly, so the certificate cost grows
like `b²`.  `b = 10⁴` evaluates in seconds; `b = 10⁵` does not terminate in a
practical time.  This is the barrier that motivated the analytic refinements.

## 3. Value of the rate at `11 %` as a logarithm of a rational

```
R := 2^100·11^22·89^178 / 100^200 = 1.011718805686342313127235023252575811…
r(0.11) = (1/100)·log R
```

Bounds actually used (all verified as exact rational comparisons):

| bound | value | slack vs. exact |
|---|---|---|
| `1 - 1/R ≤ log R` | 0.011583065986791 | 6.8·10⁻⁵ |
| `log R ≤ R - 1`   | 0.011718805686342 | 6.8·10⁻⁵ |
| `2(R-1)/(R+1) ≤ log R` (Padé) | 0.011650534856064 | 1.3·10⁻⁷ |
| `log R ≤ (R - 1/R)/2` (Padé)  | 0.011650940100548 | 2.6·10⁻⁷ |
| exact | 0.011650672261300 | — |

## 4. Mean-value step: predicted precision

With `A = (log 2)/2 - H₂(q₀)` and `H₂'` bracketed on `[q₀, q₁]`, the width of the
resulting enclosure is `≈ (p⋆ - q₀)·(U-L)/L ≈ 4.9·(p⋆ - q₀)²`.  Measured against
the formalized results:

| anchor `q₀` | `|q₀ - p⋆|` | predicted width | achieved width | decimals |
|---|---|---|---|---|
| `11/100` (crude log bounds) | 2.79·10⁻⁵ | 3.8·10⁻⁹ | 2.0·10⁻⁶ (log-slack limited) | 6 |
| `11/100` (Padé) | 2.79·10⁻⁵ | 3.8·10⁻⁹ | 4.9·10⁻⁹ | 8 |
| `79/718` (Padé) | 9.29·10⁻⁹ | 4.2·10⁻¹⁶ | 2.2·10⁻¹⁵ | 13 |

## 5. Diophantine data: continued fraction of `p⋆`

```
p⋆ = [0; 9, 11, 3, 2, 189, 2, …]
convergents:  0/1, 1/9, 11/100, 34/309, 79/718, 16466/149653, 33011/300024, …
errors:       -0.110,  1.083·10⁻³, -2.786·10⁻⁵, 4.498·10⁻⁶, -9.285·10⁻⁹,
              2.142·10⁻¹¹, -8.479·10⁻¹³
```

Two observations drove the final cycle:

* the textbook value `11/100` is itself a convergent of `p⋆` — the classical
  "11 %" is the best rational approximation of the threshold with denominator
  below `309`;
* the convergent `79/718` has a three-digit denominator (certificate: 4 102-digit
  integers, i.e. *cheaper* than the `10⁴` decimal certificate) yet is 3 000 times
  closer to the root, which is exactly what a Newton step rewards.

The next convergent `16466/149653` would predict a width `≈ 2·10⁻²¹`, but its
certificate needs `149653^299306` (≈ 1.6·10⁶ digits, ≈ 3·10⁵ kernel
multiplications) and is out of reach of linear-unfolding `Nat.pow`.

## 6. Counterexample hunt

* Sign of `r` was sampled on `{k/1000 : 100 ≤ k ≤ 130}` and is positive exactly
  for `k ≤ 110`, consistent with a single sign change; monotonicity of
  `binEntropy` on `[0,1/2]` (Mathlib) rules out further zeros, and this is what
  the Lean uniqueness proof uses.
* The Padé inequalities were tested on `x ∈ {1.0001, 1.01, 1.1, 2, 10, 100}`:
  both hold for `x ≥ 1` and both *fail* for `x < 1` (they reverse), which is why
  the Lean statements carry the hypothesis `1 ≤ x`.
* Every integer certificate in the table above was re-checked in Lean by
  `decide`, so no floating-point or Python result is load-bearing.
