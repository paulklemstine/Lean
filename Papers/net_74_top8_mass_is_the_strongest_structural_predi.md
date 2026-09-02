# Computational evidence — NET-74 round 25

All numbers below were first obtained by exact rational arithmetic outside Lean
and then **re-derived inside Lean 4** in the files listed at the end.  Only the
Lean derivations are claims; the tables here record how the targets were found.

## 1. Recomputing the three Spearman coefficients from the published table

Input (the five tabulated domains):

| domain   | entropy | top-8 mass | head agreement | k\*@512 |
|----------|---------|------------|----------------|---------|
| code     | 3.798   | 0.488      | 0.083          | 12      |
| prose-en | 3.801   | 0.488      | 0.082          | 16      |
| math     | 3.615   | 0.526      | 0.086          | 16      |
| prose-de | 3.752   | 0.502      | 0.080          | 20      |
| prose-fr | 3.864   | 0.473      | 0.079          | >24     |

Midranks (average ranks, standard tie correction):

* `k*`      → `1, 5/2, 5/2, 4, 5`  (one tie: prose-en / math)
* entropy   → `3, 4, 1, 2, 5`
* top-8     → `5/2, 5/2, 5, 4, 1`  (one tie: code / prose-en)
* head agr. → `4, 3, 5, 2, 1`

Rank covariances `S_xy`, and variances `S_xx`:

| pair | `S_xy` | `S_xx` | `S_yy` | ρ |
|---|---|---|---|---|
| entropy ↔ k\*  | `7/2`   | `10`   | `19/2` | `+7/(2√95) ≈ +0.359` |
| top-8 ↔ k\*    | `-11/4` | `19/2` | `19/2` | `-11/38 ≈ -0.289` |
| head agr ↔ k\* | `-8`    | `10`   | `19/2` | `-8/√95 ≈ -0.821` |

Reported values were `-0.60`, `+0.80`, `-0.40`.  All three recomputed signs or
magnitudes disagree; the ordering of the three predictors by `|ρ|` is exactly
inverted.

**Tie-breaking sweep.**  Enumerating both admissible orderings of each tie
(4 combinations) gives, for the ordinal-rank covariance:

* top-8 ↔ k\*: maximum over all tie-breaks is `-1` — never positive.
* entropy ↔ k\*: minimum over all tie-breaks is `+2` — never negative.
* head agr ↔ k\*: `-7` or `-9`, i.e. `ρ = -0.7` or `-0.9`.

**Censored knee sweep.**  prose-fr is recorded as `>24`.  Any value `> 20`
leaves all midranks unchanged, so all three coefficients are unchanged.

## 2. Exact null distribution of Spearman's ρ at n = 5

Enumerating all `120` permutations of five items and their displacement
`D = ∑ (σ i - i)²` (with `ρ = 1 - D/20`):

| D | 0 | 2 | 4 | 6 | 8 | 10 | 12 | 14 | 16 | 18 | 20 | 22 | 24 | 26 | 28 | 30 | 32 | 34 | 36 | 38 | 40 |
|---|---|---|---|---|---|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|
| count | 1 | 4 | 3 | 6 | 7 | 6 | 4 | 10 | 6 | 10 | 6 | 10 | 6 | 10 | 4 | 6 | 7 | 6 | 3 | 4 | 1 |

* `|ρ| ≥ 0.7` ⟺ `D ≤ 6` or `D ≥ 34`: `14 + 14 = 28` of `120` ⇒ size `7/30 ≈ 0.233`.
* `ρ ≤ -0.7` ⟺ `D ≥ 34`: `14/120 = 7/60 ≈ 0.117`.
* `ρ ≤ -0.9` ⟺ `D ≥ 38`: `5/120 = 1/24 ≈ 0.042`.

The head-agreement column realises `D = 34` under one tie-break and `D = 38`
under the other, straddling the 5% line.

## 3. Structural spot checks on the knee

For the two-phase ("staged") capture curves used in the mechanism file, with
head budget `r = 8`, head mass `c`, tolerance `τ` and target knee `k`:

* `cum j = c` for `1 ≤ j ≤ 8` and `cum k = τ` exactly, so top-8 mass `c` and
  knee `k` can be dialled independently — checked symbolically, then proved.
* For the uniform domain with per-key mass `τ/k`: collision mass at the knee is
  `k · (τ/k)² = τ²/k`, and `k · τ²/k = τ²`, i.e. the Cauchy–Schwarz bound
  `τ² ≤ k · C` is an equality.  Numerically at `τ = 1/2, k = 16`:
  `C = 1/64`, `τ²/C = 16 = k`.

## 4. Where each item is proved

| item | file | theorem |
|---|---|---|
| three coefficients | `Catalog/Physics/NET74SpearmanAudit.lean` | `spearman_*_kstar_eq`, `net74_P1_sign_refuted`, `net74_P2_refuted`, `net74_P3_refuted` |
| tie / censoring sweeps | same | `*_under_every_tiebreak`, `rcov_*_kstarOf` |
| null distribution, p-values | `Catalog/Physics/NET74SmallSamplePower.lean` | `card_bar`, `card_tail34`, `card_tail38`, `bar_false_positive_rate`, `headAgr_significance_hinges_on_tiebreak` |
| staged curves, tail mechanism | `Catalog/Physics/NET74TailMechanism.lean` | `head_mass_knee_decoupled`, `knee_depends_only_on_tail`, `tail_shape_dominates_head_mass` |
| participation ratio | `Catalog/Physics/NET74ParticipationRatio.lean` | `knee_ge_of_collision_bound`, `uniform_attains_participation_bound` |

No OEIS sequence is involved; the only integer sequence appearing (the
displacement histogram above) is the exact Spearman null at `n = 5`, which the
Lean enumeration reproduces.
