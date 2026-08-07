# Computational evidence — quantum-horizon microstate counting

All quantities below refer to the model formalised in `Catalog/Novelty/BekensteinHawkingAreaLaw.lean`:
a horizon configuration is a finite ordered list of punctures `(k, M)` with spin
label `k = 2j ≥ 1` (contributing `k` area quanta and `k+1 = 2j+1` internal
states) and magnetic label `M = 2m ∈ {-k, -k+2, …, k}`.

* `W(A)` = number of configurations of total area `A` (`hStates`).
* `D(A, M)` = number of configurations of area `A` with total projection `M`.
* `Z(A) = D(A, 0)` = number of configurations obeying the projection (Gauss)
  constraint (`hStatesSinglet`).

## 1. Small-case enumeration (computed inside Lean by `#eval`)

Direct enumeration of the `Finset` of configurations (no recurrence used):

```
W(0..6)                     = [1, 2, 7, 24, 82, 280, 956]
Z(0), Z(2), Z(4), Z(6)      = [1, 3, 26, 252]
Z(1), Z(3), Z(5), Z(7)      = [0, 0, 0, 0]
D(4, -4 .. 4)               = [8, 0, 20, 0, 26, 0, 20, 0, 8]
```

Observations that shaped the formal development:

* `∑_M D(4,M) = 8+20+26+20+8 = 82 = W(4)` (fibrewise decomposition).
* `D(4,M) = D(4,-M)`: the symmetry proved as `hStatesProj_neg`.
* `D(4,M) = 0` unless `M ≡ 4 (mod 2)`: the parity superselection rule proved as
  `projOf_parity` / `hStatesSinglet_odd`.
* `D(4,0) = 26 = Z(4)`, the largest sector — consistent with (but not needed
  for) the pigeonhole argument actually used.

## 2. Extended tables (independent scratch computation, not Lean-verified)

The following two tables were produced by an auxiliary script; they were used
only to *choose* conjectures. Everything that is asserted as a theorem in the
`.lean` files is proved there from scratch.

`W(A)` from the renewal recursion `W(n) = ∑_{k≥1} (k+1) W(n-k)`:

```
A :  0   1   2   3    4    5    6     7     8      9      10      11       12
W : 1    2   7   24   82   280  956   3264  11144  38048  129904  443520  1514272
```

The same numbers are reproduced by the two-term recursion
`W(n) = 4W(n-1) - 2W(n-2)` (`hStates_linear_rec`), whose characteristic roots
are `2 ± √2`.  The sequence matches the classical linear-recurrence sequence
`a(n) = 4a(n-1) - 2a(n-2)`, `a(0)=1`, `a(1)=2` (listed in OEIS as A007070; the
identification was made offline and not re-checked against the online database).

Ratios and entropy:

```
A     W(A)/ (2+√2)^A      log W(A)/A      log W(A+1) - log W(A)
1     0.585786            0.693147        1.252763
2     0.600505            0.972955        1.232144
4     0.603464            1.101680        1.228070
8     0.603553            1.164832        1.227947
16    0.603553            1.196390        1.227947
20    0.603553            1.202701        —
```

with `log(2+√2) = 1.2279471773…` and `(1+√2)/4 = 0.6035533906…`.  This is exactly
the content of the closed form `4W(A) = (1+√2)(2+√2)^A + (1-√2)(2-√2)^A`
(`hStates_closed_form`), of the bounds `(2+√2)^A/2 ≤ W(A) ≤ (2+√2)^A`
(`hStates_bounds`), and of the *differential* area law
`log W(A+1) - log W(A) → log(2+√2)` (`entropy_increment_tendsto`): note how much
faster the increments converge than the averages `log W(A)/A`.

Constrained (projection-zero) counts, by dynamic programming over
`(area, projection)`:

```
A       2    4     6      8       10       12        14         16
Z(A)    3    26    252    2568    26928    287648    3112896    34013312
log Z(A)/A          0.549  0.815  0.922  0.981  1.020  1.047  1.068  1.084
defect  = A log(2+√2) - log Z(A):  1.357 1.654 1.838 1.973 2.079 2.166 2.240 2.305
proved bound log 4 + 2 log(A+1):   3.584 4.605 5.278 5.781 6.182 6.516 6.802 7.053
```

The measured defect stays comfortably inside the proved envelope
(`singlet_entropy_defect_le`), and its growth is consistent with
`defect ≈ (1/2) log A + const` (a least-squares slope of `≈ 0.46` over the range
`A ∈ [2,16]`), i.e. `Z(A) ≍ (2+√2)^A / √A`.  That observation is *not* proved
here; it is recorded as Conjecture 1 of `FUTURE_DIRECTIONS.md`.

## 3. Counterexample hunt

* **Two-term recursion at small `A`.**  `W(2) = 7 ≠ 4W(1) - 2W(0) = 6`: the
  linear recursion genuinely fails at `n = 2`, which is why
  `hStates_linear_rec` carries the hypothesis `1 ≤ n` (i.e. it starts at
  `n+2 = 3`).  This was found numerically before the Lean statement was fixed.
* **Odd areas.**  `Z(A) = 0` for every odd `A` tested, so any statement of the
  constrained area law phrased for *all* areas is false; the formal statement is
  therefore restricted to even areas (`singlet_entropy_area_law`), and the odd
  case is proved to vanish identically (`hStatesSinglet_odd`).
* **Bounds at `A = 0`.**  `W(0) = 1 > 3/4 = (3/4)(2+√2)^0`, so the sharp upper
  bound `W(A) ≤ (1+√2)/4 · (2+√2)^A` fails at `A = 0`; the formal bounds are
  stated for `A ≥ 1`.
* No configuration was found violating `D(A,M) = D(A,-M)` or the fibrewise sum
  rule `∑_M D(A,M) = W(A)` for `A ≤ 8`.

---

# Cycle 2 evidence (general models, characteristic root, Hagedorn point)

All numbers below are `#eval` outputs of the *formalised* definitions
(`gW`, `hStates`), obtained with `lake env lean` against the compiled project.

## 4. General puncture models: `gW deg` for three degeneracy functions

```
deg = single type, one state at area 1 and one at area 2  (deg 1 = deg 2 = 1)
  gW 0..9 :  1, 1, 2, 3, 5, 8, 13, 21, 34, 55          -- Fibonacci, OEIS A000045
deg = single type at area 1 with 3 internal states       (singleDeg 3)
  gW 0..6 :  1, 3, 9, 27, 81, 243, 729                  -- 3^A, as proved in `gW_singleDeg`
deg = concrete model truncated at K = 3 (deg k = k+1 for k ≤ 3, else 0)
  gW 0..8 :  1, 2, 7, 24, 77, 254, 835, 2740, 9001
untruncated concrete model  (deg k = k+1)
  W  0..8 :  1, 2, 7, 24, 82, 280, 956, 3264, 11144
```

The truncated and untruncated counts agree up to `A = 3` and separate at `A = 4`,
where a single puncture of area `4` first becomes available — a useful check that
`gW` really implements the intended model.

## 5. The characteristic root predicts the observed growth rate

For finitely supported `deg` the growth rate should be `1/r`, where
`∑_k deg(k) r^k = 1` (`gEntropy_eq_neg_log_charRoot`).

```
model                      observed ratio gW(n+1)/gW(n)      predicted 1/r
Fibonacci  (x + x² = 1)     55/34 = 1.6176                   1/0.61803 = 1.6180
singleDeg 3 (3x = 1)        729/243 = 3.0000                 1/(1/3)   = 3.0000
truncated K=3 (2x+3x²+4x³=1) 9001/2740 = 3.2850              1/0.304481 = 3.2843
```

Residual of the characteristic equation at the observed rate for the `K = 3`
model: `2r + 3r² + 4r³ = 0.99962` at `r = 1/3.2850` — consistent with the
theorem, the small deficit being the finite-`A` correction.

## 6. Degeneracy monotonicity is strict (Conjecture 3, now proved)

Raising `deg 2` from `0` to `1` in the single-type model `deg 1 = 1` changes the
count from the constant sequence `1,1,1,…` (density `0`) to the Fibonacci
sequence (density `log 1.618 = 0.4812`), and raising `deg 1` from `2` to `3`
changes `2^A` into `3^A`.  No pair of degeneracy functions was found where a
strict pointwise increase left the growth rate unchanged, in agreement with
`gDensity_strict_mono`.

## 7. Approach to the Hagedorn point

Values of the canonical partition function `Z(x) = ∑ W(A) x^A` at fugacities approaching
`x_c = 1/(2+√2) = 0.292893`:

```
x         0.20     0.25      0.28      0.29      0.2925    0.292893 (= x_c)
Z(x)    2.2857   4.5000   14.0870   61.4756   449.9382      ∞ (divergent series)
```

(the finite entries are the closed form `(1-x)²/(2x²-4x+1)` of
`partition_function_closed_form`; the divergence as `x ↑ x_c` is the content of
`partitionFunction_tendsto_atTop`, and the induced divergence of
`⟨A⟩ = x Z'/Z` is `meanArea_tendsto_atTop`).

---

# Cycle 3 evidence

## 8. The canonical moments in closed form (Conjecture 2, now proved)

The exact rational forms proved in `BekensteinHawkingHagedornPole.lean` were first checked
against the microcanonical series `∑ A W(A) x^A` and `∑ W(A) x^A` summed to 300 terms
(`W` generated by `W(A+2) = 4W(A+1) - 2W(A)`, seeded `1, 2, 7` — the two-term recursion is
valid only from `A = 1`, which is exactly the counterexample recorded in §2):

```
x        Z(x) closed form   Z(x) series (300)    ⟨A⟩ closed form   ⟨A⟩ series (300)
0.10       1.306452           1.306452             0.358423          0.358423
0.20       2.285714           2.285714             1.785714          1.785714
0.25       4.500000           4.500000             5.333333          5.333333
0.28      14.086957          14.086940            21.135266         21.134914
```

(the small drift at `x = 0.28` is the truncation of the series, not of the closed form).

## 9. The order of the Hagedorn pole

`(x_c - x)·⟨A⟩(x)` should converge to `x_c = 0.292893` (`meanArea_pole_residue`) and
`(x_c - x)²·Var(x)` to `x_c² = 0.085786` (`areaVariance_pole_residue`):

```
x            0.25       0.28       0.29       0.2925     0.29289
(x_c-x)⟨A⟩  0.228764   0.272502   0.288229   0.292256   0.292888
Var(x)       ~6.31e0    4.92e2     ---        5.54e5     8.28e9
(x_c-x)²Var  0.054483   0.081870   ---        0.085671   0.085785
```

The variance is positive throughout (`areaVariance_pos`) and blows up with a *double* pole:
the specific heat is positive below the Hagedorn temperature and diverges at it.

## 10. The truncation rate for the Barbero–Immirzi parameter (Conjecture 4, now proved)

Roots `r_K` of the truncated characteristic equation `∑_{k≤K} (k+1) r^k = 1` (bisection,
60 steps) and the resulting densities `L_K = -log r_K`, against `L = log(2+√2) = 1.227947`
and against the proved certificate `L - L_K ≤ (2/(1-2x_c))·(2x_c)^K = 4.828·(0.58579)^K`:

```
K     r_K        L_K        L - L_K      proved bound
1   0.500000   0.693147   0.534800        2.828427
2   0.333333   1.098612   0.129335        1.656854
3   0.304481   1.189147   0.038800        0.970563
4   0.296567   1.215484   0.012464        0.568542
5   0.294092   1.223863   0.004084        0.333044
6   0.293286   1.226608   0.001339        0.195093
7   0.293021   1.227511   0.000437        0.114283
8   0.292935   1.227806   0.000141        0.066945
```

The observed error decays like `0.327^K`, comfortably inside the proved `0.586^K`; the
certificate is valid, and not tight (see the next-cycle sub-conjectures).

## 11. Projection profiles: the summed injection and the parity obstruction

Sector occupations `D(A,M)` for `M = -A, …, A`, computed from the formalised `horizonStates`:

```
A = 2:  2, 0, 3, 0, 2                                   (W(2) = 7,  Z(2) = 3)
A = 4:  8, 0, 20, 0, 26, 0, 20, 0, 8                     (W(4) = 82, Z(4) = 26)
A = 6:  32, 0, 112, 0, 208, 0, 252, 0, 208, 0, 112, 0, 32
```

* Every odd sector is empty — the parity superselection rule; in particular `D(1,1) = 1`
  while `D(1,0) = 0`, which **refutes** the unimodality statement
  `D(A,M) ≤ D(A,0)` proposed in the previous cycle (`hStatesProj_not_le_singlet`).
  Within a parity class the profiles above *are* unimodal, which is the corrected
  conjecture.
* `∑_M D(4,M)² = 1604 ≤ Z(8) = 2568`, the summed concatenation injection
  (`sum_sq_hStatesProj_le_singlet`), and `W(4)² = 6724 ≤ 9·2568 = 23112`, the
  Cauchy–Schwarz bound `W(A)² ≤ (2A+1)Z(2A)` (`hStates_sq_le_singlet_sharp`) — against
  `81·2568` for the older pigeonhole bound.

---

# Cycle 4: the third cumulant and the subleading constant

## 12. The microstate counts used throughout

`W(0..10) = 1, 2, 7, 24, 82, 280, 956, 3264, 11144, 38048, 129904` (recursion
`W(A+2) = 4W(A+1) − 2W(A)`, valid from `A = 1`).

## 13. The third moment: series versus closed form

Truncating `∑_A A³ W(A) x^A` at 80 terms at `x = 1/5` (exact rational arithmetic, then
converted to a float for display) gives `170.949604`, while the proved closed form
`2x(1+12x−20x²+20x⁴−16x⁵)/(2x²−4x+1)⁴` gives `170.949604`; the difference is `0` to
displayed precision (the tail is `O((5x)^{-80})`).  This is exploratory data only — the
identity itself is proved in `areaCubeWeighted_closed_form`.

## 14. The third cumulant and its pole

`κ₃(x) = 2x(1+5x−36x²+56x³−4x⁴−36x⁵+16x⁶)/((2x²−4x+1)³(1−x)³)`
(`areaThirdCumulant_closed_form`; at `x = 1/5` this agrees exactly, in rational arithmetic,
with the moment combination `⟨A³⟩ − 3⟨A²⟩⟨A⟩ + 2⟨A⟩³`).  Approaching `x_c = (2−√2)/2 ≈ 0.2928932`:

```
    x        κ₃(x)                (x_c − x)³ κ₃(x)
  0.1000     1.375905             0.00987505
  0.2000     35.272413            0.02827400
  0.2800     21919.235            0.04697962
  0.2900     2044335.2            0.04951034
  0.2920     70193218.8           0.05002289
  0.2928     6.20069e10           0.05022854
                       limit  →   0.05025253  =  2 x_c³
```

The numbers approach `2x_c³` from below, matching `areaThirdCumulant_pole_residue`; all the
listed values of `κ₃` are positive, matching `areaThirdCumulant_pos`.

## 15. No logarithmic correction: `W(A)/(2+√2)^A`

```
   A     W(A)/(2+√2)^A     |W(A)/(2+√2)^A − (1+√2)/4|
   1     0.5857864376      1.78e-02
   2     0.6005050634      3.05e-03
   4     0.6034636562      8.97e-05
   8     0.6035533128      7.78e-08
  16     0.6035533906      5.80e-14
  24     0.6035533906      5.55e-16
```

The convergence is geometric with ratio `θ = (2−√2)/(2+√2) ≈ 0.1715729`, exactly as in the
proved bound `hStates_div_pow_sub_abs_le`; the limit is `(1+√2)/4 ≈ 0.6035533906`, so
`S(A) − A log(2+√2) → log((1+√2)/4) ≈ −0.5049` and no `log A` term is present
(`entropy_sub_area_law_tendsto`).
