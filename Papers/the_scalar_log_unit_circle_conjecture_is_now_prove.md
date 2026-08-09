# Computational evidence — scalar-log unit-circle problem, cycle 2

All numbers below are floating-point exploration used to *choose* the certified
constants.  Everything that is claimed as a theorem is proved in Lean in
`Catalog/NumberTheory/EMLQuantumScalarLogSharp.lean` and
`Catalog/NumberTheory/EMLQuantumUnitaryExponential.lean`; the tables here are
not themselves verification.

## 1. The radius function `f(t) = ‖log (1 + t i)‖`

Closed form used throughout (proved as `QuantumEML.scalarLogNorm_sq`):

```
f(t)^2 = (log(1 + t^2) / 2)^2 + arctan(t)^2
```

| `t`      | `Re log`  | `Im log`  | `f(t)`    |
|----------|-----------|-----------|-----------|
| 0.50000  | 0.111572  | 0.463648  | 0.476883  |
| 1.00000  | 0.346574  | 0.785398  | 0.858466  |
| 1.10000  | 0.396496  | 0.832981  | 0.922533  |
| 1.20000  | 0.445999  | 0.876058  | 0.983053  |
| 1.22870  | 0.460082  | 0.887656  | 0.999805  |
| 1.25000  | 0.470492  | 0.896055  | 1.012066  |
| 1.30000  | 0.494771  | 0.915101  | 1.040292  |
| 2.00000  | 0.804719  | 1.107149  | 1.368704  |
| 3.00000  | 1.151293  | 1.249046  | 1.698702  |

The table is strictly increasing in `t`, which is what suggested (and is now
proved as `strictMonoOn_scalarLogNorm`) that the positive solution is unique.

Bisection on `[1.2, 1.25]` gives the root

```
t* = 1.2290375625139616...
```

so the certified interval `[6/5, 5/4]` from cycle 2 is essentially optimal at
this rational denominator size, and it is 30 times narrower than the previous
certified interval `[1/2, 3]`.

No integer sequence arises in this problem (the objects here are a single
transcendental constant and continuous families), so no OEIS identifier is
claimed.

## 2. Endpoint margins (the quantities the Lean proof has to beat)

```
f(6/5)^2 = 0.96639283...   (needs < 1, margin 3.4e-2)
f(5/4)^2 = 1.02427766...   (needs > 1, margin 2.4e-2)
```

The margins are small, so crude bounds do not suffice.  The bounds actually used
in the Lean proof were selected numerically first:

| quantity | rational bound used | value of bound | true value |
|---|---|---|---|
| `arctan(6/5) = π/4 + arctan(1/11)` | `≤ π/4 + 1/11` with `π < 3.15` | 0.878409 | 0.876058 |
| `arctan(5/4) = π/4 + arctan(1/9)`  | `≥ π/4 + 9/82` with `π > 3.141592` | 0.895154 | 0.896055 |
| `log(61/25) = log 2 + log(61/50)`  | `≤ 0.6931471808 + 11/50` | 0.913147 | 0.891998 |
| `log(41/16) = log 2 + log(41/32)`  | `≥ 0.6931471803 + 9/41` | 0.912659 | 0.941280 |

Two-sided `arctan` bounds `y/(1+y²) ≤ arctan y ≤ y` (proved in Lean) are applied
to the *small* arguments `1/9` and `1/11` produced by the exact addition
identities; this is what makes the margins work.  Applying them directly to
`6/5` or `5/4` is far too lossy (`arctan(5/4) ≥ (5/4)/(1+25/16) = 0.4878`).

## 3. Counterexample hunt

* *Monotonicity of `f` on `(0, ∞)`*: sampled 10^5 equally spaced points on
  `(0, 50]`; number of decreases observed: **0**.  Now proved.
* *Uniqueness of the positive root*: `f(10^k)` for `k = 0..6` equals
  `0.8585, 2.7366, 4.8625, 7.0839, 9.3433, 11.6196, 13.9045`, i.e. `f` grows
  like `log t`; a geometric sweep from `10^{-6}` to `10^6` found exactly
  **1** crossing of the level `1`.  Now proved (globally).
* *Is the certified scalar factor special unitary?*  For `t = t*` the value
  `z = log(1 + t* i) ≈ 0.46008 + 0.88766 i` satisfies `|z| = 1` but
  `z^2 ≈ -0.57 + 0.817 i ≠ 1`.  So `z • I₂ ∉ SU(2)`.  This negative observation
  became the theorem `scalarLog_smul_one_det_ne_one` (for every `t ≠ 0`).
* *Rotation trick for exponential surjectivity*: 1000 random unitary spectra of
  size `2`–`4` containing `-1` were multiplied by a random phase `e^{-iθ}`;
  in **1000 of 1000** cases the rotated spectrum avoided `-1`, matching the
  counting argument (`exists_circle_point_notMem`) that a finite spectrum
  cannot cover the circle.
