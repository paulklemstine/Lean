# Computational evidence for the SPLIT-COUNT LAW

All numbers below were produced by an exact/floating-point evaluation of the
finite channel

* prior on the two classes: `P(χ(N)=1) = 1/n`, `P(χ(N)≠1) = (n−1)/n`;
* `P(s | χ(N)=1) = ((n−1)/n, 0, 1/n)`, `P(s | χ(N)≠1) = ((n−2)/n, 2/n, 0)`,

with mutual information measured in bits.  Every entry marked "formalised"
below is *also* proved in Lean 4 (see `Catalog/Novelty/SplitCountChannel.lean`);
the remaining rows are exploratory only and are explicitly labelled as such.

## 1. Table of the four channels, `n = 2 … 12`

```
  n        Is        OR       AND       XOR
  2    1.0000    0.3113    0.3113    1.0000
  3    0.4739    0.0728    0.1972    0.3789
  4    0.2947    0.0359    0.1345    0.2044
  5    0.2027    0.0215    0.0979    0.1276
  6    0.1487    0.0144    0.0748    0.0872
  7    0.1141    0.0103    0.0592    0.0633
  8    0.0906    0.0077    0.0482    0.0480   <-- XOR < AND
  9    0.0738    0.0060    0.0401    0.0377   <-- XOR < AND
 10    0.0614    0.0048    0.0339    0.0303   <-- XOR < AND
 11    0.0519    0.0040    0.0291    0.0250   <-- XOR < AND
 12    0.0445    0.0033    0.0253    0.0209   <-- XOR < AND
```

Observations:

* `Is` dominates all three Boolean faces at every order (formalised in general:
  `face_le_Is`, by data processing).
* `AND ≥ OR` at every order in the table, with equality only at `n = 2`.  This
  is now **formalised for every real `n ≥ 2`** in
  `Catalog/Novelty/SplitCountAndOr.lean` (`Ior_le_Iand`, `Ior_lt_Iand`).
* The naive chain `Is ≥ XOR ≥ AND ≥ OR` **fails from `n = 8`**: `XOR(8) = 0.04801`
  is below `AND(8) = 0.04817`.  Formalised exactly as `hierarchy_eight`.

## 2. Closed forms, checked against the table

| quantity | closed form | numeric | status |
|---|---|---|---|
| `Is 2`   | `1`                                              | 1.0000 | formalised (`Is_two`) |
| `Is 3`   | `log₂3 − 10/9`                                   | 0.47385 | formalised (`Is_three`) |
| `Is 8`   | `117/32 + (21/32)log₂3 − (105/64)log₂7`          | 0.09062 | formalised (`Is_eight`) |
| `OR 2`   | `3/2 − (3/4)log₂3`                               | 0.31128 | formalised (`Ior_two`) |
| `AND 2`  | `3/2 − (3/4)log₂3`                               | 0.31128 | formalised (`Iand_two`) |
| `XOR 2`  | `1`                                              | 1.0000 | formalised (`Ixor_two`) |
| `OR 3`   | `log₂3 − (5/9)log₂5 − 2/9`                       | 0.07278 | formalised (`Ior_three`) |
| `AND 3`  | `(5/3)log₂3 − 22/9`                              | 0.19717 | formalised (`Iand_three`) |
| `XOR 3`  | `(4/3)log₂3 − (5/9)log₂5 − 4/9`                  | 0.37888 | formalised (`Ixor_three`) |
| `AND 8`  | `45/8 − (63/32)log₂3 − (7/8)log₂7`               | 0.04817 | formalised (`Iand_eight`) |
| `XOR 8`  | `13/4 + (21/32)log₂3 − (25/16)log₂5 − (7/32)log₂7` | 0.04801 | formalised (`Ixor_eight`) |
| `OR 8`   | `31/8 + (27/64)log₂3 − (15/64)log₂5 − (91/64)log₂7` | 0.00774 | formalised (`Ior_eight`) |

## 3. The split-count marginal is `Bin(2, 1/n)`

For `n = 2, 3, 5, 7` the column marginal of the joint table and the binomial
pmf `((n−1)/n)², 2(n−1)/n², 1/n²` agree to machine precision:

```
n = 2 : [0.25,     0.5,      0.25    ] vs [0.25,     0.5,      0.25    ]
n = 3 : [0.444444, 0.444444, 0.111111] vs [0.444444, 0.444444, 0.111111]
n = 5 : [0.64,     0.32,     0.04    ] vs [0.64,     0.32,     0.04    ]
n = 7 : [0.734694, 0.244898, 0.020408] vs [0.734694, 0.244898, 0.020408]
```

Formalised for all real `n ≥ 2` as `colMarg_forkJoint`.

## 4. Sufficiency of the split-count

Mutual information of the *ordered* pair channel (states `(F,F), (T,F), (F,T), (T,T)`)
versus the split-count channel:

```
n = 2 : 1.0000000000 vs 1.0000000000
n = 3 : 0.4738513896 vs 0.4738513896
n = 4 : 0.2947367178 vs 0.2947367178
n = 7 : 0.1141052851 vs 0.1141052851
```

Formalised for all real `n ≥ 2` as `Ipair_eq_Is`.

## 5. Counterexample hunt

* **Claim "Is ≥ XOR ≥ AND ≥ OR at every order"** — counterexample found at `n = 8`
  (and every `n ≥ 8` in the table).  The claim is *false*; the corrected chain
  `OR < XOR < AND < Is` at `n = 8` is what we formalised.
* **Claim "Is n ≤ 1"** — no counterexample in `n = 2 … 12`; proved in general
  (`Is_le_one`), and shown strict for `n > 2` (`Is_lt_one`).
* **Claim "a single factor's split event carries information"** — refuted: the
  single-factor marginal is Bernoulli `1/n` in *both* classes, so the mutual
  information is exactly `0` (`Ifirst_eq_zero`).

## 6. Integer certificates used for the razor-thin `n = 8` comparisons

| comparison | equivalent integer inequality | truth |
|---|---|---|
| `XOR(8) < AND(8)` | `3^84 · 7^21 < 2^76 · 5^50` | `6.6872e57 < 6.7109e57` ✓ |
| `OR(8)  < XOR(8)` | `2^40 · 5^85 < 3^15 · 7^77` | ✓ |
| `AND(8) < Is(8)`  | `2^126 · 7^49 < 3^168`      | ✓ |

These are checked by the Lean kernel inside the proof of `hierarchy_eight`.

## 7. Higher-arity forks (exploratory, not formalised)

Exhaustive enumeration over `(Z/n)^r` of the `r`-factor fork
(`N = p₁ ⋯ p_r`, `χ(p_i)` independent uniform, class `= [χ(N)=1]`,
`s = #{i : χ(p_i) = 1}`, AND `= [s = r]`, OR `= [s ≥ 1]`), in bits:

```
 r = 2:  n=2 AND 0.311278  OR 0.311278  (gap  0.000000)
         n=3 AND 0.197160  OR 0.072780  (gap  0.124379)
         n=5 AND 0.097907  OR 0.021537  (gap  0.076369)
 r = 3:  n=2 AND 0.137925  OR 0.137925  (gap  0.000000)
         n=3 AND 0.060785  OR 0.009784  (gap  0.051001)
         n=5 AND 0.018763  OR 0.000739  (gap  0.018024)
 r = 4:  n=2 AND 0.065508  OR 0.065508  (gap  0.000000)
         n=3 AND 0.019791  OR 0.001368  (gap  0.018424)
         n=5 AND 0.003722  OR 0.000031  (gap  0.003692)
```

The `r = 2` rows reproduce the formalised closed forms exactly.  The pattern
"AND ≥ OR with equality exactly at `n = 2`" persists at every arity tested
(`r ≤ 4`, `n ≤ 8`); the general-arity statement is Conjecture 1 of
`FUTURE_DIRECTIONS.md` and is **not** formalised.

## 8. The decay rate (this is what refuted two conjectures)

Exact evaluation of `Is n` at large orders, with `L(n) := n² · Is n · log 2 − log n`:

```
     n            Is n        n · Is n     n²·Is n/log₂ n        L(n)
     5    2.0271e-01      1.014e+00           2.1826          1.9033
    20    1.7928e-02      3.586e-01           1.6593          1.9750
    50    3.4059e-03      1.703e-01           1.5087          1.9900
   100    9.5220e-04      9.522e-02           1.4332          1.9950
   300    1.2346e-04      3.704e-02           1.3504          1.9983
  1000    1.2850e-05      1.285e-02           1.2895          1.9995
 10000    1.6173e-07      1.617e-03           1.2171          2.0000
```

Two readings:

* `n · Is n → 0`, so there is **no** absolute constant `c > 0` with
  `Is n ≥ c/n` — the first-cycle Conjecture 4 is false.  Formalised as
  `not_exists_linear_lower_bound`.
* `n² · Is n / log₂ n → 1` (slowly, since the correction is `2/log n`), so
  `Is n · n/log₂ n → 0` rather than `→ 1` — the first-cycle Conjecture 3 is
  false.  Formalised as `not_tendsto_one_of_scaled`, with the correct rate
  proved as `Is_sharp_rate` and the two-sided bounds `Is_ge_logBound`,
  `Is_le_logBound` (`1 ≤ L(n) ≤ 3` for all `n ≥ 2`).

The `L(n)` column suggests the exact constant `L(n) → 2`, which is Conjecture 4
of `FUTURE_DIRECTIONS.md`; the arity-3 analogue gives `L₃(n) → 3`
(`3.064, 3.003, 3.0004, 3.0001` at `n = 5, 20, 50, 100`).

## 9. OEIS

No integer sequence arises here: the objects are transcendental combinations
`a + b·log₂3 + c·log₂5 + d·log₂7` with rational `a, b, c, d`, so no OEIS lookup
is applicable.  The rational coefficient vectors themselves (e.g.
`(45/8, −63/32, 0, −7/8)` for `AND(8)`) are order-dependent and not a sequence
of independent interest.

## 10. The exact constant and the second-order term (second cycle)

Write `L(n) = n² · Is n · log 2 − log n`, so that the sharp decay law reads
`Is n = L(n)/(n² log 2)` with `L(n) → 2`.  Evaluating the four-cell expansion
`Is_eq_logSum` in 50-digit arithmetic:

```
      n      L(n)            |L(n) − 2|   proved bound 2/n   n·(L(n) − 2)
     3       1.857427...     1.43e-01     6.67e-01           −0.4277
     5       1.903260...     9.67e-02     4.00e-01           −0.4837
    10       1.950312482865  4.97e-02     2.00e-01           −0.4968752
   100       1.995000255258  5.00e-03     2.00e-02           −0.4999745
  1000       1.999500000251  5.00e-04     2.00e-03           −0.4999997
 10000       1.999950000000  5.00e-05     2.00e-04           −0.5000000
100000       1.999995000000  5.00e-06     2.00e-05           −0.5000000
```

Both formal results are visible in this table: the proved envelope
`|L(n) − 2| ≤ 2/n` (`Is_const_bound`) holds with a factor-4 margin, and the
proved second-order limit `n(L(n) − 2) → −1/2` (`Is_second_order`) is reached to
seven digits by `n = 10⁴`.  The proved second-order envelope is
`|L(n) − 2 + 1/(2n)| ≤ 12/n²`; the true deviation is about `0.25/n³`, so that
envelope, too, is comfortably valid and not tight.

### Higher arity (exploratory, floating point — *not* formally verified)

The `r`-factor fork channel over `Z/n` (class = `[x₁+⋯+x_r ≡ 0]`,
split-count = `#{i : xᵢ = 0}`) has exact cell counts
`C(r,s)·((n−1)^{r−s} + (n−1)(−1)^{r−s})/n` in the class `χ(N) = 1`.  Writing
`L_r(n) = n^r · Is_r(n) · log 2 − log n`, double-precision evaluation gives

```
   r    L_r(100)     100·(L_r(100) − r)    predicted r(r−3)/4
   2    1.995000     −0.4999               −0.5
   3    3.000102      0.0102                0
   4    4.010340      1.0340                1
   5    5.025767      2.5767                2.5
   6    6.046432      4.6432                4.5
```

(direct enumeration over `(Z/n)^r` for `n ≤ 80` agrees with the closed-form cell
counts to machine precision; beyond `n ≈ 10³` the evaluation loses all accuracy,
since `Is_r(n) ≈ n^{-r} log n` underflows the working precision).  This is the
evidence behind the revised Conjecture 3 of `FUTURE_DIRECTIONS.md`.  **Update:**
the *first-order* content of this table — that `L_r(n) → r` — is now a theorem
at every arity (`SplitCountArityAsymp.IsR_arity_constant`, with the explicit
rate `2r/(n−1) + 6·2^r/n`); the second-order column `n(L_r(n) − r)` and its
conjectured value `r(r−3)/4` remain exploratory for `r ≥ 3` (only `r = 2` is
proved, by `Is_second_order`).

## 11. The arity-`r` channel: the χ² law and the decay in the arity

The evaluation below uses the same `r`-factor channel as §10 (class
`= [x₁+⋯+x_r ≡ 0]`, split-count `= #{i : xᵢ = 0}` for independent uniform
`xᵢ ∈ Z/n`), whose class-`χ(N)=1` cell counts are
`C(r,s)·((n−1)^{r−s} + (n−1)(−1)^{r−s})/n`.  The counting identity behind those
cell counts is now a theorem (`SplitCountZeroSum.card_zeroFree_zero`,
`card_zeroFree_ne`), checked here directly by enumeration for small `n, m`:

```
  n  m   #{nonzero m-tuples, sum 0}   ((n−1)^m+(n−1)(−1)^m)/n
  3  2                2                      2
  3  3                2                      2
  4  3                6                      6
  4  3 (target 1)     7      ((n−1)^m−(−1)^m)/n = 7
```

(these four values are also computed inside Lean by `#eval` on the very Finset
appearing in the theorem statement).

`IsR r n` in bits, against the proved bound `IsR r n ≤ (n−1)^{1−r}/log 2`
(`IsR_le_geometric`, whose right-hand side is the exact χ² divergence
`(n−1)^{1−r}` of `chiSquare_forkJointR`, divided by `log 2`):

```
   r    n      IsR r n     (n−1)^{1−r}     bound = (n−1)^{1−r}/log 2
   1    2     1.000000      1.000000            1.442695
   1    3     0.918296      1.000000            1.442695
   2    2     1.000000      1.000000            1.442695
   2    3     0.473851      0.500000            0.721348
   2    4     0.294737      0.333333            0.480898
   2    8     0.090565      0.142857            0.206099
   3    3     0.233473      0.250000            0.360674
   3    4     0.101473      0.111111            0.160299
   3    8     0.014371      0.020408            0.029443
   4    3     0.112964      0.125000            0.180337
   4    8     0.002210      0.002915            0.004206
   5    3     0.054386      0.062500            0.090168
   5    8     0.000332      0.000416            0.000601
```

Three formal results are visible in the table.  `IsR r 2 = 1` for every arity
(`IsR_two_eq_one`): the `n = 2` rows are exactly `1.000000`, so the quadratic
characters keep the full bit no matter how many factors `N` has.  `IsR 2 n` is
the semiprime value of §1 (`0.473851 = Is 3`, `0.294737 = Is 4`,
`0.090565 = Is 8`), which is the theorem `IsR_two_eq_Is`.  And for `n ≥ 3` the
column decays by a factor `≈ n−1` per extra factor, matching the proved bound
within a factor `≈ 1.5–2` uniformly — the χ² bound has the right geometric rate
but is not claimed to be sharp in the constant (at arity two the true rate is
`n^{−2}(log n + 2)/log 2`, smaller by a factor `≈ n/log n`).
