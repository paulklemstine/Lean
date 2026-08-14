# Computational evidence — CM-ECM-GENERAL (`j = 0` curve `y² = x³ + 1`)

All numbers below were computed inside Lean (`#eval`, kernel/compiler evaluation)
with the naive point count

```lean
def cnt (p : ℕ) : ℕ :=
  1 + ((List.range p).flatMap fun x => (List.range p).map fun y => (x,y)).countP
        (fun P => (P.2*P.2) % p == (P.1*P.1*P.1 + 1) % p)
```

i.e. `cnt p = #E_{j0}(𝔽_p) = 1 + #{(x,y) ∈ 𝔽_p² : y² = x³ + 1}`.

Two of these observations were subsequently promoted to *kernel-checked
theorems* about the very same quantity: `cardJ0 p5 = 6` and `cardJ0 p29 = 30`
(`Catalog/Probability/CMECMGeneralConditionality.lean`, proved by `decide`).
Everything else in this file is exploratory data, and is labelled as such; the
general statements it suggested are proved for **all** primes `p > 3` in the
Lean files, not merely checked on a range.

## 1. Small-case table

`(p, #E, #E mod 6, a_p = p+1-#E, p mod 3, 9 ∣ #E, p mod 9)`

```
(5,   6, 0,   0, 2, false, 5)   (7,  12, 0,  -4, 1, false, 7)
(11, 12, 0,   0, 2, false, 2)   (13, 12, 0,   2, 1, false, 4)
(17, 18, 0,   0, 2, true , 8)   (19, 12, 0,   8, 1, false, 1)
(23, 24, 0,   0, 2, false, 5)   (29, 30, 0,   0, 2, false, 2)
(31, 36, 0,  -4, 1, true , 4)   (37, 48, 0, -10, 1, false, 1)
(41, 42, 0,   0, 2, false, 5)   (43, 36, 0,   8, 1, true , 7)
(47, 48, 0,   0, 2, false, 2)   (53, 54, 0,   0, 2, true , 8)
(59, 60, 0,   0, 2, false, 5)   (61, 48, 0,  14, 1, false, 7)
(67, 84, 0, -16, 1, false, 4)   (71, 72, 0,   0, 2, true , 8)
(73, 84, 0, -10, 1, false, 1)   (79, 84, 0,  -4, 1, false, 7)
(83, 84, 0,   0, 2, false, 2)   (89, 90, 0,   0, 2, true , 8)
(97, 84, 0,  14, 1, false, 7)  (101,102, 0,   0, 2, false, 2)
(103, 84, 0, 20, 1, false, 4)  (107,108, 0,   0, 2, true , 8)
(109,108, 0,  2, 1, true , 1)  (113,114, 0,   0, 2, false, 5)
```

The `p = 3` row is deliberately absent: `#E_{j0}(𝔽_3) = 4`, which is *not*
divisible by `3` — the curve is singular at `3` (`Δ = -27`), and this is exactly
why the theorems carry the hypothesis `p ≠ 3`.  (`p = 2` gives `#E = 3`, which is
divisible by `3`, but the parity arguments need `p ≠ 2`.)

## 2. Universal checks over all primes `3 < p < 400` (76 primes)

| claim | result |
|---|---|
| `6 ∣ #E_{j0}(𝔽_p)` | `true` (76/76) |
| `p ≡ 2 (mod 3) ⟹ #E = p + 1` exactly | `true` |
| `p ≡ 2 (mod 3) ⟹ (9 ∣ #E ↔ p ≡ 8 mod 9)` | `true` |
| `a_p ≡ p + 1 (mod 6)` | `true` |
| `p ≡ 2 (mod 3) ⟹ a_p = 0` | `true` |
| `5 ∣ #E` | 11 of 76 — **not** constant |

The first five rows are now theorems for all `p > 3`:
`six_dvd_curveCard_j0`, `inert_curveCard`, `inert_nine_dvd_iff`,
`trace_congr_six`, `inert_trace_zero`.  The last row is the conditionality
seal: `ell_five_order_event_nonconstant` proves the non-constancy from the two
kernel-verified counts `#E(𝔽_29) = 30` and `#E(𝔽_5) = 6`.

## 3. Counterexample hunt: is the `ℓ = 9` dial visible on the split half?

For `p ≡ 1 (mod 3)` (the split half) we tabulated `(p mod 9, 9 ∣ #E)` for all
such primes `< 400`:

```
(7,false) (4,false) (1,false) (4,true) (1,false) (7,true) (7,false) (4,false)
(1,false) (7,false) (7,false) (4,false) (1,true) (1,true) (4,false) (7,false)
(4,true)  (1,false) (1,false) (4,false) (1,false) (4,false) (7,true) (4,true)
(7,false) (1,false) (7,true) (4,true) (1,true) (7,false) (7,false) (4,false)
(7,false) (7,false) (4,false) (1,false) (1,true)
```

Each of the three classes `1, 4, 7 (mod 9)` carries **both** values, so
`9 ∣ #E` is *not* a function of `p mod 9` on the split half.  The residue dial
`9 ∣ #E ↔ p ≡ 8 (mod 9)` is therefore an inert-half phenomenon, which is exactly
the scope of the theorem `inert_nine_dvd_iff`.  (This is the sense in which the
split-half Hecke term is "hidden": no `mod 9` residue predicts it.)

## 4. Union-dilution, numerically

With two classes of weight `1/2`, conditional rates `a = (0.20, 0.40)` and a
class-independent extra half `b = 0.20`:

* class channel: `μ_A = 0.30`, `Var = 0.01`, `η²_A = 0.01/(0.3·0.7) ≈ 0.0476`;
* union channel: `μ_U = 0.50`, `Var = 0.01` (unchanged), `η²_U = 0.01/0.25 = 0.04`.

Dilution factor `μ_A(1-μ_A)/μ_U(1-μ_U) = 0.21/0.25 = 0.84 < 1`, matching the
proved statements `wvar_add_const` (numerator invariance),
`union_dilution`/`union_dilution_strict` (the inequality) and
`eta2_dilution_factor` (the exact factor).

## 5. The Gaussian companion `y² = x³ + x` (`j = 1728`, CM by `ℤ[i]`)

Same naive count for `E_{1728}`, all odd primes `p < 120`, as
`(p, #E, p mod 4, #E = p+1?)`:

```
(3,  4,3,true)  (5,  4,1,false) (7,  8,3,true)  (11,12,3,true)  (13,20,1,false)
(17,16,1,false) (19,20,3,true)  (23,24,3,true)  (29,20,1,false) (31,32,3,true)
(37,36,1,false) (41,32,1,false) (43,44,3,true)  (47,48,3,true)  (53,68,1,false)
(59,60,3,true)  (61,52,1,false) (67,68,3,true)  (71,72,3,true)  (73,80,1,false)
(79,80,3,true)  (83,84,3,true)  (89,80,1,false) (97,80,1,false) (101,100,1,false)
(103,104,3,true) (107,108,3,true) (109,116,1,false) (113,128,1,false)
```

Every inert prime `p ≡ 3 (mod 4)` gives `#E = p + 1` exactly, and no split prime
does.  Both halves of this observation are now theorems for all primes:
`inert_curveCard_1728` and `trace1728_eq_zero_iff` (`a_p = 0 ↔ p ≡ 3 mod 4`).
The companion statement for the `j = 0` curve, `traceJ0_eq_zero_iff`
(`a_p = 0 ↔ p ≡ 2 mod 3`), turns the experiment's "atomic trace law" into the
exact counting identity `atomic_trace_law`.

## 6. OEIS

The sequence `#E_{j0}(𝔽_p)` for `p = 5, 7, 11, 13, …` is the classical
Eisenstein/`j = 0` point-count sequence and is not needed for any proof here; we
make no OEIS identification claim.

## 7. Follow-up cycle: witnesses used by `CMECMGeneralSilentSet.lean`

All numbers below are Lean kernel computations (`decide` on
`ECMParity.curveCard`), not external scripts.

| `p` | `p mod 3` | `#E_{j0}(𝔽_p)` | `a_p = p+1-#E` | `a_p mod 9` |
|----|----|----|----|----|
| 5  | 2 (inert) | 6  | 0  | 0 |
| 13 | 1 (split) | 12 | 2  | 2 |
| 29 | 2 (inert) | 30 | 0  | 0 |
| 31 | 1 (split) | 36 | −4 | 5 |

* `#E_{j0}(𝔽_5) = 6` is the *only* datum needed for the "only if" half of the
  silent-set classification: any `ℓ` dividing all counts divides `6`.  Together
  with `6 ∣ #E` for every good prime this closes the silent set at `{1,2,3,6}`.
* `13` and `31` are both `≡ 4 (mod 9)` and both split, yet their traces differ
  mod `9` (`2` versus `5`), which is the counterexample behind
  `trace_mod_nine_not_determined_on_split_half`.  On the inert half the trace is
  identically `0`, so the contrast is exact.
* Counterexample hunt for the sharpness construction: the channel used in
  `union_dilution_sharp` is `μ = (1-√(1-c))/2`, conditional probabilities
  `μ ± μ/2`, class-blind mass `b = 1/2 - μ`; e.g. `c = 3/4` gives `μ = 1/4`,
  probabilities `1/8, 3/8`, `b = 1/4`, and `η²` drops from `(1/8)²/(3/16)` to
  `4·(1/8)²`, a ratio of exactly `3/4`.

## 8. Present cycle: free-iterate divisibility and the dilution family

*Free iterates.*  The counting lemma `card_dvd_card_of_free_iterate` is checked
against the cases already computed above: for `p = 5, 13, 29, 31` the order-three
translation `step` on the point set of `y² = x³ + 1` is fixed-point free, and the
counts `6, 12, 30, 36` are indeed all divisible by `3`; the same map read with
`n = 6` (translation by the point of order `6`) matches `6 ∣ 6, 12, 30, 36`.  For
`n = 4` the divisibility fails already at `p = 5` (`#E = 6`), consistent with the
silent set being exactly `{1,2,3,6}`.

*Dilution family, inverted.*  The sharpness construction of `union_dilution_sharp`
is `μ = (1−√(1−c))/2`, and the achieved factor is `4μ(1−μ) = c`.  Inverting it on
the three factors measured in the experiment (each computed to four decimals from
the closed form, then re-substituted):

| measured factor `c` | `μ = (1−√(1−c))/2` | `4μ(1−μ)` |
|----|----|----|
| `0.69` (`ℓ = 9`: `0.0120/0.0174`) | `0.2216` | `0.6900` |
| `0.94` (`ℓ = 5`: `0.0030/0.0032`) | `0.3775` | `0.9400` |
| `0.34` (`ℚ(i)`, `ℓ = 3`: `0.0048/0.0143`) | `0.0938` | `0.3400` |
| `0.75` (worked example of §7) | `0.2500` | `0.7500` |

All four lie in `(0,1)`, in agreement with `dilution_factor_range`
(`{c | DilutionFactor c} = (0,1]`); the last row is the case verified exactly in
Lean.  Only the last row is a formal (kernel-checked) statement — the other three
are floating-point evaluations of the proved closed form on the experiment's
reported numbers.
