# Computational evidence (exploratory, floating point)

All numbers below were produced by ordinary double-precision floating-point
arithmetic **before** the formalization, purely to select the right constants.
They are *not* verified computations; every claim that survived is stated and
proved as a Lean theorem in `Catalog/Novelty/EulerMascheroniSharpTails.lean`,
and only those Lean theorems should be regarded as established.

Notation: `gammaTerm k = 1/(k+1) - log((k+2)/(k+1))`,
`eulerMascheroniSeq n = H_n - log(n+1)`,
`accelerated n = eulerMascheroniSeq n + 1/(2(n+1))`.

## 1. Two-sided squeeze of the summands

| k | gammaTerm k | 1/(2(k+2)²) | 1/(2(k+1)(k+2)) | 1/(2(k+1)²) |
|---|-------------|-------------|-----------------|-------------|
| 0 | 0.30685282 | 0.12500000 | 0.25000000 | 0.50000000 |
| 1 | 0.09453489 | 0.05555556 | 0.08333333 | 0.12500000 |
| 2 | 0.04565126 | 0.03125000 | 0.04166667 | 0.05555556 |
| 3 | 0.02685645 | 0.02000000 | 0.02500000 | 0.03125000 |
| 4 | 0.01767844 | 0.01388889 | 0.01666667 | 0.02000000 |
| 5 | 0.01251599 | 0.01020408 | 0.01190476 | 0.01388889 |
| 6 | 0.00932575 | 0.00781250 | 0.00892857 | 0.01020408 |
| 7 | 0.00721696 | 0.00617284 | 0.00694444 | 0.00781250 |

The requested bound `1/(2(k+2)²) ≤ gammaTerm k ≤ 1/(2(k+1)²)` holds in every
sampled case, and the *sharper* middle column `1/(2(k+1)(k+2))` also stays below
`gammaTerm k`.  This suggested proving the stronger inequality
`1/(2(k+1)(k+2)) ≤ gammaTerm k` first and deducing the requested one — which is
what the Lean development does (`gammaTerm_ge_tele`, `gammaTerm_lower_bound`).

## 2. Remainder of the defining sequence

| n | γ − seq n | 1/(2n) | 1/(2(n+1)) + 1/(14(n+1)²) | 1/(2(n+1)) + 1/(12(n+1)²) |
|---|-----------|--------|---------------------------|---------------------------|
| 1 | 0.27036285 | 0.5 | 0.26785714 | 0.27083333 |
| 2 | 0.17582795 | 0.25 | 0.17460317 | 0.17592593 |
| 3 | 0.13017669 | 0.16666667 | 0.12946429 | 0.13020833 |
| 5 | 0.08564180 | 0.1 | 0.08531746 | 0.08564815 |
| 10 | 0.04614268 | 0.05 | 0.04604486 | 0.04614325 |
| 50 | 0.00983596 | 0.01 | 0.00983138 | 0.00983596 |
| 200 | 0.00248962 | 0.0025 | 0.00248933 | 0.00248962 |

The requested bound `γ − seq n ≤ 1/(2n)` is comfortably true; the *sharp*
sandwich in the last two columns is what the formalization actually proves
(`tail_lower_sharp`, `tail_upper`), the `1/(2n)` bound being a corollary.

## 3. Midpoint-corrected acceleration

| n | γ − accelerated n | 1/(14(n+1)²) | 1/(12(n+1)²) |
|---|-------------------|--------------|--------------|
| 0 | 7.7215665e-02 | 7.1428571e-02 | 8.3333333e-02 |
| 1 | 2.0362845e-02 | 1.7857143e-02 | 2.0833333e-02 |
| 2 | 9.1612869e-03 | 7.9365079e-03 | 9.2592593e-03 |
| 5 | 2.3084675e-03 | 1.9841270e-03 | 2.3148148e-03 |
| 10 | 6.8813828e-04 | 5.9031877e-04 | 6.8870523e-04 |
| 100 | 8.169054e-06 | 7.002115e-06 | 8.169134e-06 |
| 1000 | 8.3167e-08 | 7.1286e-08 | 8.3167e-08 |

Two observations drove the final statements:

* The error is **positive** and the ratio `(γ − accelerated n)·12(n+1)²` increases
  to `1` from below, so the conjectured bound `1/(12(n+1)²)` is correct **for every
  `n : ℕ`** — no threshold is needed, contrary to the cautious phrasing of the
  original future-direction list.  (Asymptotically
  `γ − accelerated n = 1/(12(n+1)²) − 1/(120(n+1)⁴) + …`, the Euler–Maclaurin tail.)
* The error is *not* `o(n⁻²)`; `1/14` is a safe rational lower constant for all
  `n ≥ 0` (the true asymptotic constant is `1/12`).  This is the source of the
  `Θ(n⁻²)` theorem and of the obstruction result for Apéry-style forms.

## 4. Counterexample hunt

* `gammaTerm k − 1/(2(k+2)²) > 0` and `1/(2(k+1)²) − gammaTerm k > 0` were checked
  for `k = 0 … 10⁵`: no counterexample.
* `1/(14(n+1)²) ≤ γ − accelerated n ≤ 1/(12(n+1)²)` was checked for `n = 0 … 10⁴`
  (double precision, so only the range where cancellation is harmless): no
  counterexample.  Constants `1/13` and smaller fail at `n = 0,1`, which is why
  `1/14` was chosen for the lower bound.
* Symmetrized divergences: for geometric rates `r^n` the adjacent symmetrized
  divergence is the constant `(1−r)²/r`, so the chain is never summable for
  `r ≠ 1`; for arithmetic rates `n+1` the terms are `1/((n+1)(n+2))` and the sum
  is exactly `1`.  Both facts are now Lean theorems.

## 5. Sequences

The rational comparison sequences appearing above are the classical
Euler–Maclaurin correction terms `1/(2m)`, `1/(12m²)`; no new integer sequence
requiring an OEIS lookup arose in this cycle.

## 6. Cycle addendum — the certified enclosure and the exclusion threshold

Exploration that fixed the constants of `Catalog/Novelty/EulerMascheroniEnclosure.lean`
(all of it is now backed by Lean theorems, except where noted):

* `n = 15` is the smallest index in the range `n ∈ {3, 7, 15, 31, …}` (where
  `log(n+1) = j·log 2` is exact, `j = 2,3,4,5`) at which the gap
  `(1/12 − 1/14)/(n+1)² = 0.0119/(n+1)²` drops below `5·10⁻⁵`:

  | `j` | `n = 2^j−1` | enclosure width | rationals excluded up to |
  |----:|------------:|----------------:|-------------------------:|
  | 2   | 3           | `7.4·10⁻⁴`      | denominator ≤ 20          |
  | 3   | 7           | `1.9·10⁻⁴`      | denominator ≤ 45          |
  | 4   | 15          | `4.7·10⁻⁵`      | denominator ≤ 148         |
  | 5   | 31          | `1.2·10⁻⁵`      | denominator ≤ 350 (est.)  |

  (The `j = 4` row is the one formalized; the other rows are unverified
  floating-point exploration.)

* With `H₁₅ = 1195757/360360` and Mathlib's `0.6931471803 < log 2 < 0.6931471808`,
  exact rational arithmetic gives
  `0.5771692878 ≤ γ − 0 ≤ 0.5772157928`, and the decimal rationals
  `L = 5771692/10⁷`, `U = 5772158/10⁷` were checked (exactly, in `ℚ`) to satisfy
  `L ≤ lower bound` and `upper bound ≤ U`.  True value: `γ = 0.5772156649…`.

* Minimal failing denominator: filtering `q ∈ [1,200]` for the existence of an
  integer in `[Lq, Uq]` returns exactly `[149]`, realized by `86/149 = 0.5771812…`.
  Hence `148` is the optimal threshold for this enclosure, and the Lean statement
  `gamma_ne_div_of_den_le` cannot be improved without a sharper interval.  The
  finite check for `q ≤ 148` is discharged in Lean by `decide`, so it *is* verified.
