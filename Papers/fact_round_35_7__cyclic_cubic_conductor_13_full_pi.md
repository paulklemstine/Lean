# Computational evidence — cyclic cubic field of conductor 13

All numbers below were produced by direct enumeration in Lean (`#eval`, exact
integer/`Float` arithmetic) before any theorem was stated; each of them is now
backed by a machine-checked theorem in `Catalog/Bridges/`.

## 1. Splitting types mod 13

For each nonzero residue `u` mod `13` the table lists the multiplicative order of
`u` in `(Z/13)ˣ` and the splitting type `T(u)` in the cyclic cubic subfield
`K₃ ⊂ Q(ζ₁₃)` (computed as `1` if `u⁴ = 1`, i.e. `u` is a cubic residue, else `3`):

| u | ord₁₃(u) | T(u) |
|---|---------|------|
| 1 | 1  | 1 |
| 2 | 12 | 3 |
| 3 | 3  | 3 |
| 4 | 6  | 3 |
| 5 | 4  | 1 |
| 6 | 12 | 3 |
| 7 | 12 | 3 |
| 8 | 4  | 1 |
| 9 | 3  | 3 |
| 10| 6  | 3 |
| 11| 12 | 3 |
| 12| 2  | 1 |

Cubic residues: `{1, 5, 8, 12}` — exactly `4` of the `12` units.
**Only two splitting types occur**, with rates `1/3` and `2/3`.
Formalised: `CyclicCubic13.cubicResidues_13`, `card_cubicResidues_13`,
`conductor13_two_types`, `conductor13_type_counts`.

## 2. Entropy and pinning

* `H(T)` from the counts `(4, 8)`: `0.918296…` bits.
* Closed form `log₂ 3 − 2/3 = 0.9182958340544894`: agrees to all printed digits.
* `I(p mod 13 ; T) = H(T)` (the type is a deterministic function of the residue),
  so the channel is fully pinned.

The reported experimental constant `0.9192` is **not** the exact value; the true
value is `0.91829…`.  Formalised: `conductor13_entropy`,
`conductor13_full_pinning`, `entropy_lt_reported` (`H(T) < 0.9187 < 0.9192`).

## 3. Semiprime pair channel

Enumerating the `9` exponent pairs of the `C₃` model (equivalently the `144`
exponent pairs mod `12`, which give the same value):

* `H({T(p),T(q)}) = 1.392147`,
* `H({T(p),T(q)} | N mod 13) = 0.918296`,
* `I({T(p),T(q)} ; N mod 13) = 0.473851 = log₂ 3 − 10/9`.

The reported `0.4702` is again slightly off; `0.47385… > 0.4702`.
Note the surprising exact identity `H(T) − Ipair = 4/9` (the `log₂ 3` cancels).
Formalised: `Ipair_three_eq`, `conductor13_pair_channel`,
`conductor13_pairing_defect`, `Ipair_three_gt_reported`.

## 4. Which-factor

Over the `4` off-diagonal pairs of the `C₃` model (`64` of the `144` pairs mod
`12`):

* `H(orientation bit) = 1.000000`,
* `H(orientation | ({T(p),T(q)}, N mod 13)) = 1.000000`,
* hence `I = 0.000000` — the reported `0.0001` is numerical noise around an exact
  zero.

Formalised: `WhichFactorWall.conductor13_which_factor_zero`,
`conductor13_orientation_entropy`, `conductor13_decoder_thirtytwo`
(every decoder is correct on exactly `32` of the `64` classes).

## 5. The conductor-13 tower

Exact entropies of the splitting-type channels of all subfields of `Q(ζ₁₃)`:

| degree m | H(T_m) | numeric |
|---|---|---|
| 1  | 0                | 0.000 |
| 2  | 1                | 1.000 |
| 3  | log₂3 − 2/3      | 0.918 |
| 4  | 3/2              | 1.500 |
| 6  | log₂3 + 1/3      | 1.918 |
| 12 | log₂3 + 5/6      | 2.418 |

Successive gaps along the cubic branch are rational: `H₆ − H₃ = 1`,
`H₁₂ − H₆ = 1/2`.  Cubic information share `0.918/2.418 = 0.3797 ∈ (0.37, 0.39)`.
The table is additive across coprime factorisations:
`H₆ = H₂ + H₃ = 1 + 0.918`, `H₁₂ = H₄ + H₃ = 1.5 + 0.918`,
`H₃₀ = H₂ + H₃ + H₅ = 1 + 0.918 + 0.722 = 2.640` — now a theorem
(`typeEntropy_mul_of_coprime`).

Formalised: `CyclicSubfield.conductor13_tower_gaps`,
`conductor13_crt_split`, `cubic_information_share`,
`typeEntropy_mono_of_dvd`.

## 6. Counterexample hunt

* *Is the cubic entropy special to conductor 13?*  Enumeration of the cubic type
  over all `f − 1` exponents at conductors `f = 7, 13, 19, 31, 37, 43` returns
  `0.918296` in every case.  This is now a theorem for **all** prime conductors
  `f` with `3 ∣ f − 1` (`cubic_subfield_pinned_all_conductors`), so no
  counterexample exists.
* *Is `H(T)` monotone in the subfield lattice?*  Enumerated divisor tables:
  `n = 12`: `(1,0), (2,1), (3,0.9183), (4,1.5), (6,1.9183), (12,2.4183)`;
  `n = 16`: `(1,0), (2,1), (4,1.5), (8,1.75), (16,1.875)`;
  `n = 18`: `(1,0), (2,1), (3,0.9183), (6,1.9183), (9,1.2244), (18,2.2244)`;
  `n = 30`: `(1,0), (2,1), (3,0.9183), (5,0.7219), (6,1.9183), (10,1.7219),
  (15,1.6402), (30,2.6402)`.  Monotone along every divisibility chain (note the
  values are *not* monotone in the numerical size of `m`: `H(T₅) < H(T₄)`), and
  the data-processing proof (`typeEntropy_mono_of_dvd`) shows there is no
  counterexample.
* *Can a decoder beat `1/2` on the which-factor question?*  Exhaustive search over
  all `2^{#observable values}` decoders: for the `C₃` model every one of the
  `4` decoders scores exactly `2` out of `4`; at conductor `13` every decoder
  scores exactly `32` out of `64`.  The involution argument
  (`decoder_success_half`) proves this in general.

No sequence in this file required an OEIS lookup: all rates are the elementary
`φ(d)/n` densities already present in the catalog's type-count law.

## Addendum (cycle 2) — the prime-power saturation law

Evidence gathered *before* formalising `typeEntropy_prime_pow_eq`.  Column
`H(direct)` is the `φ`-law entropy `∑_{d ∣ n} (φ(d)/n)·log₂(n/φ(d))` evaluated
directly on `n = p^e`; column `C(p)·(1 − p^{−e})` is the conjectured closed form
with ceiling `C(p) = p·log₂ p/(p−1) − log₂ (p−1)`.

```
  p  e    p^e     H(direct)     C(1-p^-e)     ceiling C(p)
  2  1      2   1.000000000   1.000000000    2.000000
  2  2      4   1.500000000   1.500000000    2.000000
  2  3      8   1.750000000   1.750000000    2.000000
  2  4     16   1.875000000   1.875000000    2.000000
  3  1      3   0.918295834   0.918295834    1.377444
  3  2      9   1.224394445   1.224394445    1.377444
  3  3     27   1.326427316   1.326427316    1.377444
  3  4     81   1.360438273   1.360438273    1.377444
  5  1      5   0.721928095   0.721928095    0.902410
  5  2     25   0.866313714   0.866313714    0.902410
  5  3    125   0.895190838   0.895190838    0.902410
  5  4    625   0.900966262   0.900966262    0.902410
  7  1      7   0.591672779   0.591672779    0.690285
  7  2     49   0.676197461   0.676197461    0.690285
  7  3    343   0.688272416   0.688272416    0.690285
  7  4   2401   0.689997409   0.689997409    0.690285
```

Agreement to all printed digits; no discrepancy was found in the search range.
The law is now a theorem (`typeEntropy_prime_pow_eq`), and three of its values are
re-derived inside Lean and matched against the catalog's independently computed
entries (`typeEntropy_nine_of_law`, `typeEntropy_twentyseven_of_law`,
`typeEntropy_thirtytwo_of_law` versus `typeEntropy_val_9`, `_27`, `_32`).

Note the conductor-13 row `p = 3, e = 1`: `0.918296 = C(3)·(2/3)`, i.e. the cyclic
cubic channel realises exactly two thirds of the `3`-primary ceiling
`C(3) = (3/2)·log₂ 3 − 1 ≈ 1.377444`.

### Numerics behind next-cycle direction 2 (Mertens growth law)

With `H(P(x)) = ∑_{p ≤ x} C(p)·(1 − 1/p)` (saturation law + CRT additivity):

```
        x     H(P(x))   H - log2 x   H - log2 x - log2 log x
       10    3.231897    -0.090031                 -1.293286
      100    7.081987     0.438130                 -1.765124
     1000   10.882702     0.916918                 -1.871299
    10000   14.585053     1.297341                 -1.905914
   100000   18.214353     1.604713                 -1.920470
  1000000   21.794179     1.862610                 -1.925607
  2000000   22.865029     1.933461                 -1.925381
```

The last column is settling near `−1.9254`, which is the numerical content of the
conjecture recorded in `FUTURE_DIRECTIONS.md`.  This is exploratory arithmetic in
floating point, **not** a verified computation.

---

## Cycle 3 evidence

### Defect and entropy values at small prime degree

Computed from the proved closed forms
`H(T_q) = log₂ q − ((q−1)/q)·log₂(q−1)` and
`D(q) = ((q−1)/q²)·((q−1)log₂(q−1) − (q−2)log₂(q−2))`:

```
 q   H(T_q)     Ipair q    D(q) = H − Ipair
 2   1.000000   1.000000   0.000000    (= 0,    rational)
 3   0.918296   0.473851   0.444444    (= 4/9,  rational)
 5   0.721928   0.202710   0.519218    (irrational — proved)
 7   0.591673   0.114105   0.477567    (irrational — proved)
11   0.439497   0.051897   0.387600    (irrational — proved)
13   0.391244   0.038642   0.352601    (irrational — proved)
```

Only the first two rows are rational, which is exactly the dichotomy proved in
`pairing_defect_rational_iff`.  Note that `D(q)` is not monotone: it peaks near
`q = 5` and then decays.

### Counterexample hunt for the integer relations

The irrationality proofs rest on two families of impossible identities.  Both were
searched exhaustively over small parameters before being proved (exploratory
integer arithmetic, superseded by the Lean theorems
`nat_pow_relation_impossible` and `nat_pow_odd_prime_relation_impossible`):

* `(v+1)^((v+1)b) = 2^A · v^(vb)` for `2 ≤ v ≤ 59`, `1 ≤ b ≤ 3`: no solution.
* `q^(qb) = 2^A · (q−1)^((q−1)b)` for `q ∈ {3,5,7,11,13,17,19,23}`, `1 ≤ b ≤ 3`:
  no solution.

### The conductor-13 Rényi spectrum

From the two-point distribution `(1/3, 2/3)` proved in `conductor13_pushProb`:

```
  a      H_a
  0    1.000000    (Hartley: two types — proved exactly)
  0.5  0.958144
  1    0.918296    (Shannon: log₂3 − 2/3 — proved exactly)
  1.5  0.881384
  2    0.847997    (collision: log₂(9/5) — proved exactly)
  3    0.792481
  5    0.720105
 10    0.649802
  ∞    0.584963    (min-entropy log₂(3/2); not formalised)
```

The spectrum is decreasing in the order, and the strict step from `a = 1` to
`a = 2` is proved in `conductor13_collision_lt_shannon` (its arithmetic content is
`108 < 125`).  Rows other than `a ∈ {0, 1, 2}` are floating-point evaluations of
the proved formula `conductor13_renyi_formula`, not separate verified facts.

## Cycle 4 — the prime-degree Rényi gap

The prime-degree channel is the two-point vector `(1/q, (q−1)/q)`, so
`H_1 = log₂ q − ((q−1)/q) log₂(q−1)` and `H_2 = 2 log₂ q − log₂(q² − 2q + 2)`.
Floating-point evaluation of these two proved closed forms (exploratory; only the
exact statements are theorems):

```
  q     H_1        H_2        gap = H_1 − H_2
  2   1.000000   1.000000     0.000000
  3   0.918296   0.847997     0.070299
  5   0.721928   0.556393     0.165535
  7   0.591673   0.405263     0.186410
 13   0.391279   0.220838     0.170441
```

The gap vanishes exactly at `q = 2` (uniform channel), rises to a maximum around
`q = 7`, and then decays; positivity for all `q ≥ 3` is the theorem
`typeRenyi_two_lt_typeEntropy`.

**Integer certificates.**  The strict gap at degree `q` is equivalent to
`q^q (q−1)^(q−1) < (q² − 2q + 2)^q`.  The two sides, computed exactly:

```
  q = 3:        108  <         125
  q = 5:     800000  <     1419857
  q = 7:  38423222208 < 94931877133
```

and the inequality was checked to hold for `q ∈ {3, 5, 7, 13, 101}` before being
proved for all `m = q − 1 ≥ 2` in `collision_gap_nat` (the case `m = 2` by direct
computation, the rest from `1 + x ≤ exp x` together with `exp 1 < 3`).

**The irrationality obstruction.**  A rational gap would force the identity
`(q² − 2q + 2)^{qb} = 2^A · (q^q (q−1)^{q−1})^b`, whose right-hand side is
divisible by `q` while its left-hand side is not, because `q² − 2q + 2 ≡ 2`
(mod `q`) and `q` is odd.  The residue was evaluated for all 45 odd primes below
200 — it is `2` in every case — and the general statement is the theorem
`succ_not_dvd_sq_add_one`.
