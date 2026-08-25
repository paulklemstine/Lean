# Computational Evidence — sharp constants for the RLHF alignment-drift law

Setting: finite response set `Ω`, reference policy `p` (strictly positive), reward `r`,
KL temperature `β > 0`, aligned (Gibbs) policy `π_β(y) ∝ p(y) e^{r(y)/β}`.
`σ_p(r) = √Var_p(r)`, `MAD_p(r) = 𝔼_p|r − 𝔼_p r|`, `range(r) = max r − min r`.

All numbers below come from double-precision floating-point exploration (Python) and are
**exploratory only**: they motivated the statements, they do not verify them.  The verified
artifacts are the Lean theorems in `Catalog/Algebra/RLHF*.lean`, which are proved with no
`sorry` and no extra axioms.

## 1. Small-case calculations: what is the true constant?

`β·‖π_β − p‖₁` and `β²·KL(π_β‖p)` against the candidate constants `MAD_p(r)` and
`Var_p(r)/2`.

| family | σ | MAD | β=1 | β=5 | β=100 | β=1000 | limit candidate |
|---|---|---|---|---|---|---|---|
| uniform on `Bool`, `r = 1_{true}` (`β‖·‖₁`) | 0.5 | 0.5 | 0.4621 | 0.4983 | 0.49999 | 0.500000 | MAD = 0.5 |
| same (`β²KL`) | | | 0.11094 | 0.12438 | 0.124998 | 0.125000 | Var/2 = 0.125 |
| rare spike `ε = 0.01`, `r = 1_{true}` (`β‖·‖₁`) | 0.0995 | 0.0198 | 0.03345 | 0.02187 | 0.019897 | 0.019810 | MAD = 0.0198 |
| same (`β²KL`) | | | 0.009687 | 0.005646 | 0.004982 | 0.004953 | Var/2 = 0.004950 |
| 3-point `p=(.2,.5,.3)`, `r=(2,−1,.5)` (`β‖·‖₁`) | 1.1715 | 1.05 | 0.9706 | 1.0611 | 1.05131 | 1.050135 | MAD = 1.05 |
| same (`β²KL`) | | | 0.6316 | 0.7357 | 0.68933 | 0.686560 | Var/2 = 0.68625 |
| rare spike `ε = 10⁻³`, `a = 5` (`β‖·‖₁`) | 0.15803 | 0.00999 | 0.25669 | 0.017136 | 0.010243 | 0.010015 | MAD = 0.00999 |

Reading: the `ℓ¹` drift constant converges to `MAD_p(r)` — **not** to `σ_p(r)`, which
overshoots by the factor `σ/MAD` (5.0× at `ε = 0.01`, 15.8× at `ε = 10⁻³`).  The KL constant
converges to `Var_p(r)/2`, i.e. **half** the catalogue's `e^{range/β}·Var` constant.
The 3-point row also shows `β‖π_β−p‖₁ > MAD` at moderate `β` (1.0611 at `β = 5`), so the
first-order law genuinely needs the `O(β⁻²)` correction that the theorems carry.

These observations became
`RLHF.l1_drift_tendsto_mad`, `RLHF.kl_tendsto_half_variance`,
`RLHF.l1_drift_upper_mad`, `RLHF.l1_drift_lower_mad`, `RLHF.abs_kl_sub_half_variance`.

## 2. Counterexample hunt for the non-asymptotic bounds

200 000 random instances: `|Ω| ∈ {2,…,5}`, `p` uniform on the simplex (normalised
uniforms), `r_y ∼ U[−3,3]`, `β = range(r)·U[1,6]` (i.e. inside the hypothesis
`β ≥ range r`), plus a random audit statistic `f_y ∼ U[−2,2]`.  Reported is the worst
(largest) value of `LHS − RHS`; a positive value would be a counterexample.

| claim | worst margin |
|---|---|
| `‖π_β − p‖₁ ≤ MAD/β + 2 Var/β²` | −4.48·10⁻⁵ |
| `‖π_β − p‖₁ ≥ MAD/β − 3 Var/β²` | −1.08·10⁻⁴ |
| `|KL − Var/(2β²)| ≤ 2·range(r)·Var/β³ + 3 Var²/β⁴` | −1.71·10⁻⁶ |
| `|𝔼_{π_β}f − 𝔼_p f − Cov(r,f)/β| ≤ 3·range(f)·Var/β²` | −1.18·10⁻⁶ |

No counterexample was found, and the margins are small, so the numeric constants
`2, 3, (2,3), 3` are close to optimal in the regime `β ≈ range r`.

## 3. The separation from the σ-law

On the Bernoulli spike family `p(true) = ε`, `r = 1_{true}`:
`MAD = 2ε(1−ε)`, `Var = ε(1−ε)`, hence `MAD/σ = 2√(ε(1−ε)) → 0` as `ε → 0`.

| ε | 1/2 | 0.1 | 0.01 | 10⁻³ | 10⁻⁴ |
|---|---|---|---|---|---|
| MAD/σ | 1 | 0.600 | 0.199 | 0.0632 | 0.0200 |

So the σ-constant of C1 is unboundedly lossy, and it is *exactly* tight only at `ε = 1/2`.
This is proved in Lean as `RLHF.mad_sq_spike_eq` (`MAD² = 4ε(1−ε)·Var`) and
`RLHF.mad_eq_sqrt_variance_balanced`, with the general equality criterion
`RLHF.mad_eq_sqrt_variance_iff`.

## 4. OEIS

No integer sequence arises in this problem (all quantities are continuous functionals of a
probability vector), so no OEIS search applies.

## 5. Where the σ-law comes from

`√(2·KL) ≈ σ/β` while `‖π_β − p‖₁ ≈ MAD/β`.  So the standard deviation enters *only*
through Pinsker's inequality, and the loss is exactly the deviation defect
`σ − MAD ≥ 0`.  Numerically the ratio `‖π_β − p‖₁ / √(2 KL)` converges to `MAD/σ`
(0.199 for `ε = 0.01`, 1.000 for the balanced two-point family); proved as
`RLHF.pinsker_defect_tendsto` and `RLHF.pinsker_asymptotically_tight_iff`.
