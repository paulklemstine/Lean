# Computational evidence — F1 tightness / bound-slack-by-X (paper 250)

All *verified* claims in this project are the Lean theorems in
`Catalog/Probability/F1Tightness*.lean` (each builds with 0 `sorry`).  The
computations below are **exploratory numerics** used to choose the statements;
they are not themselves machine-checked, except where a Lean declaration is
named.

## 1. The model in one line

`M` cells, prior `p` on cells, policy = permutation `σ`, cost
`polCost p σ = Σ (σ i + 1)·p i`.  Three costs:

| symbol | meaning | Lean |
|---|---|---|
| `c_asc`  | ascending (identity) scan cost | `scanCost` |
| `c_desc` | descending (reversed) scan cost | `revCost` |
| `C₀ = (M+1)/2` | flat-profile / random-order cost | `baseCost` |

Parameter map: `Λ = c_asc/c_desc`, `Θ = c_asc/C₀`, `q̂ = 1`, `S_asc = 1/Λ`,
`bound = 1/(Λ·Θ·q̂)`, `X = C₀/c_asc`.

Because `c_asc + c_desc = M + 1 = 2C₀` **exactly** (`scanCost_add_revCost_eq`),
the map collapses to one parameter:

```
X = (1+Λ)/(2Λ),   Θ = 2Λ/(1+Λ) = 1/X,   bound = X · S_asc.
```

## 2. Reproducing the booked numbers

With the independently verified `Λ = 0.765671`:

| quantity | formula | value | booked | Lean check |
|---|---|---|---|---|
| `Θ_asc` | `2Λ/(1+Λ)` | 0.867286 | 0.867 | `measured_Theta_approx` |
| `X` | `(1+Λ)/(2Λ)` | 1.1530220 | 1.15302 | `measured_gapX_approx` |
| `E_x` | `Λ/(1+Λ)` | 0.4336431 | — | `measured_meanPos` |
| `S_asc` | `1/Λ` | 1.3060440 | ≈1.31 | `predicted_speedup_approx` |
| `bound` | `1/(ΛΘ)` | 1.5058974 | ≈1.51 | `measured_bound_approx` |

The reported CI `Θ ∈ [0.8193, 0.9076]` ⇔ `Λ ∈ [0.6939, 0.8309]` maps to
`X ∈ [1.1018, 1.2206]` (`gapX_mem_interval`), i.e. slack ≥ 10% and ≤ 23%.

## 3. Small-case calculation (fully explicit, Lean-checked)

Linear profile `(0.4, 0.3, 0.2, 0.1)` on `M = 4` cells:

```
c_asc = 1(.4)+2(.3)+3(.2)+4(.1) = 2      c_desc = 4(.4)+3(.3)+2(.2)+1(.1) = 3
C₀ = 5/2      Λ = 2/3      Θ = 4/5      X = 5/4      S_asc = 3/2
bound = 1/(ΛΘ) = 15/8 = X·S_asc  ✓
```

This is the Lean theorem `F1Tightness.linear4_values` (proved by `norm_num`).

## 4. Discretised harmonic profile (exploratory sweep)

Harmonic density `1/x` on `[1, r]`, `M` equal-width cells, `p_i ∝ log((1+(i+1)h)/(1+ih))`:

| r | M | Λ | Θ | X | E_x | bound |
|---|---|---|---|---|---|---|
| 2.00 | 27 | 0.801221 | 0.889642 | 1.124047 | 0.442777 | 1.402917 |
| 2.20 | 27 | 0.777399 | 0.874760 | 1.143170 | 0.435061 | 1.470506 |
| 2.25 | 27 | 0.771898 | 0.871267 | 1.147754 | 0.433250 | 1.486923 |
| 2.25 | 1000 | 0.764349 | 0.866437 | 1.154152 | 0.433152 | 1.509981 |
| 3.00 | 1000 | 0.695861 | 0.820658 | 1.218534 | 0.410239 | 1.751118 |
| 10.0 | 1000 | 0.477891 | 0.646721 | 1.546263 | 0.323184 | 3.235594 |

Observations that drove the theorems:

* the measured pair `(Λ, X) = (0.765671, 1.15302)` sits at window ratio
  `r ≈ 2.23`, inside the sweep — consistent with the harmonic positional law of
  the papers 228–242 chain;
* `X` is monotone increasing in `r` and in `M`: discretisation *under*-reports
  the slack, so the booked `X` is a conservative estimate of the continuum
  value (a next-cycle conjecture, see `FUTURE_DIRECTIONS.md`);
* continuum mean positions `E(r) = 1/log r − 1/(r−1)`: `E(2) = 0.442695`,
  `E(2.25) = 0.433152`, `E(3) = 0.410239`, `E(10) = 0.323184`, all `< 1/2`,
  which is the Lean theorem `harmMeanPos_lt_half` (proved from the Padé
  inequality `log r > 2(r−1)/(r+1)`, `log_gt_pade`).

## 5. Counterexample hunt

* *Can any policy attain the bound on a non-flat front-loaded pool?*  No:
  swept all `4! = 24` policies for the profile of §3 — the ascending order is
  the unique minimiser with cost 2, next best 2.1.  Formalised (for all `M` and
  all permutations) in `scanCost_le_polCost`, `scanCost_lt_polCost` and
  `polCost_eq_scanCost_iff`.
* *Can `X = 1` be reached inside the antitone class?*  Only by the flat
  profile (`gapX_flat`, `gapX_eq_one_iff`, `slack_never_attained`), which the
  three independent tests reject pool-side.
* *Is the bound then improvable?*  No: the two-cell family
  `(1/2+δ, 1/2−δ)` has `X = (3/2)/(3/2−δ) → 1`, so no constant improvement is
  possible over the prior class (`sharp_over_prior_class`).  Sharpness lives on
  the class, unattainability on the pool — the two are consistent.

## 6. OEIS

No integer sequence arises: all objects here are ratios of expected probe
counts.  The only integer datum is the conservation identity
`c_asc + c_desc = M + 1`, which is Gauss' pairing and needs no lookup.

## 7. Second cycle: refinement, dispersion, and the reachable range

All numbers in this section are *exact rationals* and are machine-checked inside
the Lean files (not produced by a script), so they are stated here only as
orientation.

| object | profile | value | Lean theorem |
| --- | --- | --- | --- |
| fine grid, 4 cells | `(2/5, 3/10, 1/5, 1/10)` | `E = 3/8`, `X = 5/4` | `demoFn_meanPos`, `demoFn_gapX_fine` |
| after pairwise merging | `(7/10, 3/10)` | `E = 2/5`, `X = 15/13 ≈ 1.1538` | `demoFn_gapX_coarse` |
| refinement comparison | — | `15/13 < 5/4` | `demoFn_refinement` |
| dispersion functional | `(3/4, 1/4)` | `‖p − flat‖₁ = 1/2`, `V = 1/8` | `demoTwo_flatDist` |
| refined master bound | `(3/4, 1/4)` | `S · 9/8 ≤ bound` | `demoTwo_refined` |
| reachable slack range | any 27-cell profile | `X ∈ [28/54, 14]` | `gapX_range_sharp` (at `M = 27`) |

Observations that drove the second-cycle theorems:

* coarsening moves the measured mean position *forward* (here `3/8 → 2/5`) by
  exactly `∑_j (g(2j) − g(2j+1))/(4M) = (1/10 + 1/10)/8 = 1/40`, matching
  `meanPos_coarseFn`;
* the two effects of a refinement — more cells and a smaller mean position —
  push the slack in the *same* direction, which is why the comparison
  `X(coarse) < X(fine)` needs no numerical cancellation and only the hypothesis
  `E < 1/2`;
* the dispersion functional `V = ‖p − flat‖₁/(2M)` is a genuine improvement but
  a conservative one: on `(3/4, 1/4)` it certifies a factor `9/8 = 1.125`
  whereas the exact slack there is `X = (3/2)/(5/4) = 6/5 = 1.2`, which is the
  source of the "optimal constant" direction in `FUTURE_DIRECTIONS.md`.

## 8. Third cycle: the constrained polytope and the optimal dispersion constant

Again all values are exact rationals certified inside the Lean files.

| object | data | value | Lean theorem |
| --- | --- | --- | --- |
| sharper dispersion normalisation | `(3/4, 1/4)` | `V' = ‖p − flat‖₁/(2·c_asc) = (1/2)/(5/2) = 1/5` | `one_add_flatDist_div_scanCost_le_gapX` |
| exactness on two cells | `(3/4, 1/4)` | `1 + V' = 6/5 = X` (equality) | `twoCell_dispersion_exact` |
| optimality of the constant | `(3/4, 1/4)`, any `c > 1` | `X = 6/5 < 1 + c/5` | `dispersion_constant_optimal` |
| tail-constrained slack cap | `M` cells, cut `K`, edge mass `m` | `X ≤ (M+1)/(2Km+2)` | `gapX_le_of_edgeMass` |
| extremal constrained profile | `(1−m)·δ₀ + m·δ_K` | `E = (1/2 + Km)/M`, `X = (M+1)/(2Km+2)` | `pairProfile_gapX_extremal` |
| constrained range | as above | `X ∈ [(M+1)/(2M), (M+1)/(2Km+2)]`, both attained | `constrained_gapX_range_sharp` |

Observations that drove the third-cycle theorems:

* the gap noted at the end of §7 — the `2M`-normalised dispersion certifies
  `9/8` where the true slack on `(3/4, 1/4)` is `6/5` — closes *exactly* once
  the normalisation is taken to be `2·c_asc` instead of `2M`: on two cells the
  refined inequality becomes an identity, which simultaneously proves the
  constant `1` cannot be raised;
* the tail constraint enters the slack only through the product `K·m`, because
  the mean position is linear in the profile: this is what makes the constrained
  extremal profile a two-atom measure, one atom at the first cell and one at the
  cut.
