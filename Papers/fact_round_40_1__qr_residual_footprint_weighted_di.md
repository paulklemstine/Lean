# Computational evidence — QR footprint dial (paper 145 / experiment 477)

All numbers below were produced by evaluating the Lean definitions in
`Catalog/MachineLearning/QRResidual/` (`#eval`), except where marked *(exploratory,
Python)*.  The items marked **kernel-checked** are re-verified by `decide`/`norm_num`
inside the Lean files, in the `LabNotes` sections of `Capstone.lean` and
`Distribution.lean`.

## 1. Small-case calculations

Factor base bound `B = 20`, odd factor base `{3, 5, 7, 11, 13, 17, 19}` (**kernel-checked**).

| quantity | value | note |
|---|---|---|
| `hitCount 1649 7` | `2` | `1649` is a QR mod 7 → two roots (**kernel-checked**) |
| `hitCount 1649 13` | `0` | `1649` is a non-residue mod 13 (**kernel-checked**) |
| `hitCount 1649 17` | `1` | ramified: `1649 = 17·97` (**kernel-checked**) |
| QR primes of `1649` in base | `{5, 7, 17}` | (**kernel-checked**) |
| `qrWeight 1649 20` | `478/595 ≈ 0.80336` | `2/5 + 2/7 + 2/17` (**kernel-checked**) |
| `qrWeight 1 20` | `9267838/4849845 ≈ 1.91095` | maximal: `1` is a QR everywhere (**kernel-checked**) |
| `Σ_{N<7} hitCount N 7` | `7` | exact cancellation of paper 130 (**kernel-checked**) |
| `#{N < 7 : N is a QR mod 7}` | `4 = (7+1)/2` | (**kernel-checked**) |

Mean-footprint identity on `S = {3,5}`, `N = 1`, period `15`:
total hits `Σ_{x<15} #{p ∈ S : p ∣ x²−1} = 16` and `15·(2/3 + 2/5) = 16`
(both **kernel-checked**; this is the `B`-small instance of `mean_footprint_eq_sum`).

## 2. Exact law of the QR pattern, checked on `B = 5`

Base `{3,5}`, period `P = 15`. The proved law
`#{N < P : pattern(N) = T} = ∏_{p∈T}(p+1)/2 · ∏_{p∉T}(p−1)/2` predicts

| pattern `T` | predicted | measured |
|---|---|---|
| `{3,5}` | `2·3 = 6` | `6` (**kernel-checked**) |
| `{3}` | `2·2 = 4` | `4` (**kernel-checked**) |
| `∅` | `1·2 = 2` | `2` (**kernel-checked**) |

## 3. Mean of the dial: prediction vs. measurement

The proved identity `mean_qrWeight` gives, for the odd primes `p ≤ 100` (24 primes),

* exact population mean of the dial `= Σ_{3 ≤ p ≤ 100} (p+1)/p² = 1.500283…`
* random-model footprint `Σ 1/p = 1.302817…` (the mean of the *raw* footprint weight
  `footprintWeight`, `mean_footprintWeight_eq_random`)
* maximal ("all-QR") value `Σ 2/p = 2.605634…`

*(exploratory, Python)* Sampling 5000 uniform random `N ∈ [10⁶, 10⁷)` (seed 20260829)
gives a sample mean of `1.50015` and sample sd `0.4314`; 200 consecutive
`N = 10007 … 10206` give `1.50035`.  Both agree with the proved population mean
`1.500283` to within sampling error, and are clearly distinct from the naive guess
"half of the maximum" (`1.3028`) — the excess is exactly `Σ 1/p²`, coming from the
ramified residues `p ∣ N`, exactly as the proved formula says.

## 4. Counterexample hunt

* *Is the dial constant / degenerate?* No: `qrWeight 1 20 ≠ qrWeight 1649 20`
  (**kernel-checked**), and `qrWeight_full_range` proves every one of the `2^{|base|}`
  subset sums is attained.
* *Does the dial ever see the factorisation?* Search failed by construction: the dial is a
  function of `N mod ∏ p` (`qrWeight_congr`), and Dirichlet's theorem then supplies
  arbitrarily large primes and semiprimes with identical values
  (`qrWeight_blind_to_primality`, `qrWeight_blind_semiprime`).  No counterexample can
  exist — this is now a theorem, not a failed search.
* *Can the QR dial be a function of the small-prime mechanism dial?*  No:
  `dials_functionally_independent` exhibits two moduli agreeing on the small dial and
  differing on the large one.

## 5. What the evidence supports

The regression claim of the experiment (`R²` lifting from `0.3927` to `0.5691`) is not
re-measured here; instead the exact optimisation facts behind it are proved
(`rss_line_eq`, `rsq_augment_strict`, `footprint_no_lift_iff_orthogonal`): a lift of the
observed size is possible **iff** the baseline residual is non-orthogonal to the feature,
and its size is exactly the squared residual correlation divided by `‖v‖²·TSS`.

## 6. Variance of the dial: prediction vs. measurement (second cycle)

The proved identity `sum_sq_dev_qrWeight` gives the exact variance of the dial over a full
period of moduli as `Var(B) = Σ_{3 ≤ p ≤ B} (p² − 1)/p⁴`.

| `B` | #primes | exact `Var(B)` | exact sd | exact mean `Σ (p+1)/p²` |
|---|---|---|---|---|
| 5 | 2 | `6944/50625 = 0.137165` | `0.370359` | `0.684444` |
| 20 | 7 | `0.177446` | `0.421243` | `1.147409` |
| 100 | 24 | `0.185936` | `0.431203` | `1.503246` |
| 1000 | 167 | `0.187627` | `0.433160` | `1.900201` |

*(exploratory, brute force over one full period)* Enumerating **all** moduli of the period
reproduces the formula exactly:

* `B = 5`, `P = 15`: `Σ_{N<15} (dial − mean)² = 6944/3375 = 15 · 6944/50625` ✓
* `B = 7`, `P = 105`: `Σ_{N<105} (dial − mean)² = 19102544/1157625 = 105 · Var(7)` ✓

Both identities are instances of the proved theorem, and the small-case fractions
`6944/50625`, `154/225` are additionally **kernel-checked** in the `LabNotes` section of
`Catalog/MachineLearning/QRResidual/Variance.lean`.

Comparison with the sampling run of section 3: for `B = 100` the sample standard deviation
of the dial over 5000 random `N` was `0.4314`, against the exact value `0.431203` — a
match to four decimals.  Note also that the variance *converges* as `B → ∞` (it is bounded
by `1/2`, proved in `qrWeight_variance_lt_half`, and numerically approaches `≈ 0.1877`)
while the mean diverges like `Σ 1/p`: the dial's spread is an absolute constant, which is
what makes it usable as a calibration feature at any factor-base bound.

## 7. What the reported R² numbers pin down (third cycle)

`rsq_line_eq` makes the lift exact, and `lift_eq_corr_sq_mul` rewrites it as
`ρ² · (1 − R²(before))` with `ρ` the sample correlation between the baseline residual and
the feature.  Inverting this on the reported numbers (kernel-checked rational identities in
the `LabNotes` of `Catalog/MachineLearning/QRResidual/LiftCeiling.lean`):

| regime | `R²` before | `R²` after | lift | implied `ρ²` | implied `|ρ|` |
|---|---|---|---|---|---|
| `u = 2.5` | `0.3927` | `0.5691` | `0.1764` | `1764/6073 = 0.29046` | `0.5389` |
| `u = 3.5` | `0.2063` | `0.3078` | `0.1015` | `1015/7937 = 0.12788` | `0.3576` |

Both implied correlations lie strictly inside `(0,1)`, i.e. the reported lifts are
compatible with the proved ceiling `lift ≤ 1 − R²(before)` (`lift_le_one_sub_rsqOf`): they
are large but not impossible, and they are exactly what a residual correlation of about
`0.54` (respectively `0.36`) with the footprint feature would produce.

## 8. Prime powers: Hensel lifting keeps two roots (fourth cycle)

Direct enumeration of the hit count `#{x < m : m ∣ x² − N}`:

| `N` | `m` | hits |
|---|---|---|
| 7 | 3 | 2 |
| 7 | 9 | 2 |
| 7 | 27 | 2 |
| 7 | 81 | 2 |
| 7 | 5 | 0 |
| 7 | 25 | 0 |

The counts for `m = 3, 9, 27` and `m = 5, 25` are **kernel-checked** by `decide` in the
`LabNotes` of `Catalog/MachineLearning/QRResidual/PrimePower.lean`, and the general fact is
now the theorem `hitCount_prime_pow`: for an odd prime `p ∤ N` the count is the same at
every exponent, hence `2` for admissible `p` and `0` otherwise.

*(exploratory)* The even prime behaves differently, which is why it is excluded from the
factor base used throughout: `#{x < 8 : 8 ∣ x² − 1} = 4`, `#{x < 16 : 16 ∣ x² − 9} = 4`,
`#{x < 32 : 32 ∣ x² − 17} = 4`, while `#{x < 8 : 8 ∣ x² − 3} = 0`.  This is the
`four-root` phenomenon that direction D3 of `FUTURE_DIRECTIONS.md` proposes to formalise.

## 9. Exact capacity of the dial (fifth cycle)

For `B = 20` the factor base is `{3, 5, 7, 11, 13, 17, 19}` (**kernel-checked**, 7 primes),
so the dial takes exactly `2^7 = 128` distinct values — the upper bound of the information
bound is attained, because distinct QR patterns always give distinct subset sums
(`subsetSum_injective`).  Concretely `qrWeight 1649 20 = 478/595` with pattern `{5, 7, 17}`
and `qrWeight 1 20 = 9267838/4849845` with the full pattern; the inequality of the two is
kernel-checked in the `LabNotes` of `Catalog/MachineLearning/QRResidual/Capacity.lean`.

The proof mechanism is worth recording as a computation in its own right: multiplying the
subset sum by the primorial `D = ∏_{p ≤ B} p` gives the natural number `Σ_{p∈T} 2·(D/p)`,
and a factor-base prime `p` divides it exactly when `p ∉ T` — the pattern can be read back
off the dial value by a single divisibility test per prime.

## 10. The even prime (sixth cycle)

Kernel-checked in the `LabNotes` of `PrimePower.lean`: `#{x < 8 : 8 ∣ x² − 1} = 4`,
`#{x < 16 : 16 ∣ x² − 1} = 4` and `#{x < 8 : 8 ∣ x² − 3} = 0`.  The vanishing half is now
the theorem `hitCount_two_pow_eq_zero`: an odd `N` with `N ≢ 1 (mod 8)` is never hit by any
`2^k`, `k ≥ 3`, because an odd square is `1 mod 8`.  The four-root count for `N ≡ 1 mod 8`
remains the open conjecture D3.
