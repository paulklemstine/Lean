# Computational Evidence

All computations below were carried out in double precision with the exact
definitions used in the Lean files:

```
step a n = n/2            (n even)
step a n = a*n + 1        (n odd)
ratio a n = step a n / n
F a ω N   = Σ_{n=1..N} exp(2πi ω · ratio a n)
limitAmp a ω = (e(ω/2) + e(aω)) / 2 ,   e(x) = exp(2πi x)
```

The numbers here are *illustrative exploration*; every mathematical claim used in
the project is separately proved in Lean (`Catalog/Novelty/CollatzSpectral*.lean`)
and is machine-checked with no `sorry` and only the standard axioms.

## 1. The limit law `F a ω N / N → limitAmp a ω`

`N = 100 000`. Columns: measured `|F a ω N| / N`, predicted `|limitAmp a ω|`,
and the closed form `|cos(π (a − 1/2) ω)|`.

| a | ω | \|F/N\| | \|limitAmp\| | \|cos(π(a−½)ω)\| |
|---|---|---------|--------------|------------------|
| 3 | 0.01 | 0.996917 | 0.996917 | 0.996917 |
| 3 | 0.10 | 0.707077 | 0.707107 | 0.707107 |
| 3 | 1/5 | 0.000078 | 0.000000 | 0.000000 |
| 3 | 1/9 | 0.642752 | 0.642788 | 0.642788 |
| 3 | 1/13 | 0.822965 | 0.822984 | 0.822984 |
| 3 | √2−1 | 0.993733 | 0.993775 | 0.993775 |
| 5 | 0.01 | 0.990023 | 0.990024 | 0.990024 |
| 5 | 0.10 | 0.156395 | 0.156434 | 0.156434 |
| 5 | 1/5 | 0.951072 | 0.951057 | 0.951057 |
| 5 | 1/9 | 0.000044 | 0.000000 | 0.000000 |
| 5 | 1/13 | 0.464695 | 0.464723 | 0.464723 |
| 7 | 0.01 | 0.979222 | 0.979223 | 0.979223 |
| 7 | 0.10 | 0.454025 | 0.453990 | 0.453990 |
| 7 | 1/5 | 0.587718 | 0.587785 | 0.587785 |
| 7 | 1/9 | 0.642819 | 0.642788 | 0.642788 |
| 7 | 1/13 | 0.000031 | 0.000000 | 0.000000 |

Two features are visible and are exactly what the theorems assert:

* the modulus of the normalized transform matches `|cos(π(a−½)ω)|` to five
  decimals already at `N = 10^5`;
* the irrational frequency `ω = √2 − 1` gives `|F/N| ≈ 0.994` for `a = 3`.  This
  is the concrete refutation of the previous cycle's global pointwise-decay
  hypothesis: there is no smallness at irrational frequencies near `0`.

## 2. The quantitative error bound

Proved bound: `‖F a ω N / N − limitAmp a ω‖ ≤ (1 + 2π|ω|(1 + log N)) / N`
(`norm_F_div_sub_limitAmp_le`).  At the resonance `a = 3, ω = 1/5`, where
`limitAmp = 0`, the left-hand side is just `|F|/N`:

| N | measured \|F/N\| | proved bound |
|---|------------------|--------------|
| 10 | 2.10e−1 | 5.15e−1 |
| 100 | 3.48e−2 | 8.04e−2 |
| 1000 | 4.89e−3 | 1.09e−2 |
| 10 000 | 6.32e−4 | 1.38e−3 |
| 100 000 | 7.76e−5 | 1.67e−4 |

The bound is valid throughout and is within a factor ≈ 2.2 of the observed
quantity, so the `log N / N` shape is essentially sharp.

## 3. Resonance sets (counterexample hunt for the discriminator)

`limitAmp a ω = 0` iff `(2a−1)ω ∈ 2ℤ + 1` (`limitAmp_eq_zero_iff`).  Scanning all
rationals `ω = p/q ∈ [0,3]` with `q ≤ 60` gave the zero sets

* `a = 3`: `1/5, 3/5, 1, 7/5, 9/5, 11/5, 13/5, 3` (8 values, all odd multiples of `1/5`);
* `a = 5`: `1/9, 1/3, 5/9, 7/9, 1, 11/9, 13/9, 5/3, …` (14 values, all odd multiples of `1/9`);
* `a = 7`: `1/13, 3/13, 5/13, 7/13, 9/13, 11/13, 1, 15/13, …` (20 values, all odd multiples of `1/13`).

No other zeros appeared, matching the theorem.  The intersection of the `a = 3`
and `a = 5` zero sets in the scanned range is `{1, 3}`, i.e. exactly the odd
integers — as proved in `common_resonance_three_five` (and its analogues
`common_resonance_three_seven`, `common_resonance_five_seven`).

## 4. Mean square over a period

Numerically (trapezoid rule, 2·10⁵ subintervals), `∫_0^2 |limitAmp a ω|² dω`
evaluates to `1.0000000000` for `a = 3, 5, 7, 9, 11`, independent of `a`; the Lean theorem
`meanSquare_limitAmp` proves `∫_0^2 ‖limitAmp a ω‖² dω = 1` for every `a ≥ 1`.
So the plain `L²` statistic is *not* a discriminator: only the location of the
resonance set is.

## 5. OEIS

No new integer sequence is produced by this work: the objects are real/complex
valued transforms, and the arithmetic data (resonance denominators `2a−1`:
5, 9, 13, …) is the trivial arithmetic progression `A016813`-like family, not a
new sequence.
