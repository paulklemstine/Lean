# Computational evidence — asymmetric vs symmetric divisibility in semiprimes

All numbers below were produced by `#eval` inside this Lean project (Lean 4.28 /
Mathlib), enumerating **all** ordered pairs of primes `5 < p < q < 200` (903 semiprimes
`N = p q`, excluding the factors 2, 3, 5 so that residues are units).  They are
*exploratory* data, not verified theorems; the theorems they motivated are in
`Catalog/Tropical/SmoothSelfHint*.lean` and are proved with 0 sorries.

## 1. Conditional frequencies, `l = 3`

| `N mod 3` | #semiprimes | `#{3 ∣ p-1}` (asymmetric) | `#{3 ∣ p-1 ∨ 3 ∣ q-1}` (symmetric) |
|---|---|---|---|
| 1 | 441 | 210 (47.6 %) | 210 (47.6 %) |
| 2 | 462 | 232 (50.2 %) | 462 (**100.0 %**) |

The `100.0 %` in the last cell is not a statistical accident: it is
`SmoothSelfHint.symmetric_forced_mod_three` (if `N ≡ 2 (mod 3)` then some factor is
`≡ 1 (mod 3)`), and the flatness of the asymmetric column is
`SmoothSelfHint.asym_fiber_card` / `SmoothSelfHint.miF_asym_zero`.

Empirical mutual informations from these counts (float `#eval`):

* symmetric: **0.3328 bits** — model value `3/2 - (3/4)·log₂3 = 0.31128` bits
  (`SmoothSelfHint.mi_sym_three`), reported measurement `0.313` bits;
* asymmetric: **0.000487 bits** — model value exactly `0`
  (`SmoothSelfHint.mi_asym_three`), reported measurement `0.0000–0.0005` bits.

## 2. Conditional frequencies, `l = 5`

| `N mod 5` | #semiprimes | asymmetric | symmetric |
|---|---|---|---|
| 1 | 222 | 45 (20.3 %) | 45 (20.3 %) |
| 2 | 230 | 60 (26.1 %) | 120 (52.2 %) |
| 3 | 230 | 56 (24.3 %) | 110 (47.8 %) |
| 4 | 221 | 53 (24.0 %) | 100 (45.2 %) |

The uniform model predicts asymmetric `1/(l-1) = 25 %` in every class, and symmetric
`1/(l-1) = 25 %` at `n = 1` versus `2/(l-1) = 50 %` at `n ≠ 1`
(`SmoothSelfHint.sym_condProb_value`).  Both patterns are clearly visible.  Grouped as
`n = 1` vs `n ≠ 1`, the empirical mutual informations are **0.047 bits** (symmetric) and
**0.0016 bits** (asymmetric); the reported measurement for `l = 5` is `0.036` bits.

## 3. `l = 7`

| `N mod 7` | # | asymmetric | symmetric |
|---|---|---|---|
| 0 | 42 | 0 | 6 |
| 1 | 141 | 15 (10.6 %) | 15 (10.6 %) |
| 2 | 140 | 22 (15.7 %) | 42 (30.0 %) |
| 3 | 147 | 20 (13.6 %) | 42 (28.6 %) |
| 4 | 139 | 27 (19.4 %) | 48 (34.5 %) |
| 5 | 147 | 20 (13.6 %) | 42 (28.6 %) |
| 6 | 147 | 22 (15.0 %) | 42 (28.6 %) |

Model: asymmetric `1/6 ≈ 16.7 %` everywhere; symmetric `1/6` at `n = 1` and `2/6 ≈
33.3 %` elsewhere.  (Class `0` is outside the unit model: it means `7 ∣ N`.)

## 4. Counterexample hunt for the self-hint claims

* residue hint, `l = 3`: `77 = 7·11` and `65 = 5·13` are both `≡ 2 (mod 3)` and disagree
  on `3 ∣ p-1`; `91 = 7·13` and `55 = 5·11` do the same in the class `1`.  Hence *both*
  classes are ambiguous (`SmoothSelfHint.asym_ambiguous_each_class`).  No counterexample
  to the impossibility could exist: `SmoothSelfHint.asym_no_residue_dial_any_modulus`
  proves it for *every* modulus.
* smoothness hint, `B = 10`: the four quadrants are realised by
  `253 = 11·23` (`N-1 = 252` smooth, `p-1 = 10` smooth),
  `1081 = 23·47` (`1080` smooth, `22` not),
  `143 = 11·13` (`142 = 2·71` not, `10` smooth),
  `667 = 23·29` (`666 = 2·3²·37` not, `22` not).
  Adding the `N+1` bit does not help: `253` and `1081` both have
  (`N-1` smooth, `N+1` not) yet opposite secret bits (`254 = 2·127`, `1082 = 2·541`).

## 5. Sequences

The counting function behind everything is `#{(a,b) ∈ G² : ab = n, a ∈ A}`.  For
`A = {1}` it is the constant sequence `1, 1, 1, …` (asymmetric) versus
`1, 2, 2, …, 2` (symmetric, one entry per residue).  These are too degenerate for an
OEIS lookup; the informative quantity is the symmetric probability
`(2(l-1) - 1)/(l-1)²` for `l = 3, 5, 7, 11`: `3/4, 7/16, 11/36, 19/100`, i.e. numerators
`2g-1` and denominators `g²` — no OEIS entry was consulted, and none is claimed.

## 6. The closed form against the measured leak (added in the second cycle)

`SmoothSelfHint.symMI d` is the closed form proved in
`Catalog/Tropical/SmoothSelfHintClosedForm.lean`:

```
symMI d = ( log₂(d/(2d-1)) + (d-1)·log₂(d/(d-1)) + 2(d-1)·log₂(2d/(2d-1))
            + (d-1)(d-2)·log₂(d(d-2)/(d-1)²) ) / d²
```

Evaluated at `d = l - 1` (floating point, `#eval`; the `d = 2` entry uses the Lean
convention `log 0 = 0`, under which the last term vanishes and the exact value
`3/2 - (3/4)log₂3` is proved in `symMI_two`):

| `l` | `d = l-1` | `symMI d` | measured MI | `d²·symMI d` |
|---|---|---|---|---|
| 3 | 2 | 0.31128 | 0.313 | 1.2451 |
| 5 | 4 | 0.03588 | 0.036 | 0.5741 |
| 7 | 6 | 0.01439 | 0.015 | 0.5181 |
| 11 | 10 | 0.00484 | 0.005 | 0.4837 |
| — | 100 | 0.0000446 | — | 0.4463 |
| — | 1000 | 0.00000044 | — | 0.4431 |

Every closed-form value agrees with the experiment to the precision the experiment
reports.  The last column is the source of the decay law proved in this cycle
(`symMI_lt_two_div_sq`, `neg_lt_symMI`, `symMI_tendsto_zero`): `d²·symMI d` is bounded
and converges to `log₂ e - 1 = 0.442695…` (proved: `symMI_asymptotic`), and the certified `l = 5` window
`0.0355 < I < 0.036` (`mi_sym_five_bounds`) brackets the measured `0.036`.
