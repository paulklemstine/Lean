# Computational evidence — FACTOR-LOCAL-ET (round-41 #5, paper 154)

This is the pre-formalisation evidence stage for
`Catalog/Probability/FactorLocalETScaling.lean` and
`Catalog/Probability/FactorLocalETCrossChannel.lean`.

## 1. Independent re-measurement of the across-`k` slopes

An independent replication was run (deterministic Miller–Rabin prime sampler,
seed `20260920`, 300 balanced semiprimes `N = p·q` with `p, q` both exactly `k`
bits, for `k ∈ {16, 20, 24}`).  Costs measured per instance:

* **trial division** — number of odd trial divisors up to the smaller factor,
  i.e. `p/2`;
* **Pollard ρ** — the *actual* iteration count of a Floyd-cycle ρ run
  (`x ↦ x² + 1`) until `gcd` reveals a factor;
* **Fermat** — the exact step count `(p+q)/2 − ⌈√N⌉ + 1`;
* **gap** — `q − p`, recorded to test the transfer law.

Arithmetic means of `log₂` of the per-`k` mean cost:

| k  | log₂ E[T_trial] | log₂ E[T_ρ] | log₂ E[T_Fermat] | mean log₂ p |
|----|-----------------|-------------|------------------|-------------|
| 16 | 14.426          | 7.164       | 8.748            | 15.406      |
| 20 | 18.404          | 9.286       | 12.764           | 19.381      |
| 24 | 22.402          | 11.292      | 16.881           | 23.380      |

Resulting across-`k` slopes per `log₂ p` (`k = 16 → 24`):

| channel        | this replication | paper 154 report |
|----------------|------------------|------------------|
| trial division | **1.000**        | 0.84             |
| Pollard ρ      | **0.518**        | 0.52             |
| Fermat         | **1.020**        | 0.50             |

Geometric-mean and median statistics give the same picture
(trial `1.000 / 1.002`, ρ `0.520 / 0.514`, Fermat `0.985 / 1.002`), so the
discrepancies are not an artefact of the averaging functional.

**Reading.**  The ρ slope replicates exactly (`0.518` vs `0.52`, and vs paper
89's `0.523`).  The other two do not replicate on a *uniform balanced*
population, which is what motivated the formal work: the theorems below decide
which of the reported numbers can come from a stated cost model at all.

## 2. The gap exponent, and a numerical test of the transfer law

The same run measured the mean gap exponent:

| statistic | gap slope | Fermat slope | `2·gap − 1` |
|-----------|-----------|--------------|-------------|
| geometric mean | 0.999 | 0.985 | 0.998 |
| median         | 1.013 | 1.002 | 1.026 |

The identity `α_Fermat = 2·β_gap − 1` is confirmed numerically to within `0.02`
on this population, and is *proved* in
`FactorLocalET.fermat_powerBand_of_gap` (via the exact sandwich
`fermat_gap_locality`).  Inverting it on the reported `α_Fermat = 0.50` gives
`β_gap = 0.75`, i.e. the paper-154 population must have gaps scaling like
`p^{3/4}` rather than like `p`.  That is a concrete, falsifiable prediction
about the draw procedure, not about Fermat's algorithm.

## 3. Counterexample hunt against the claimed slope pair

The cross-channel law proved in `FactorLocalETCrossChannel.lean` says that on
*one* population with pointwise costs `a·p` and `c·√p`,

`|slope_trial − 2·slope_ρ| ≤ 1/Δk = 0.125` at `Δk = 8`.

The reported pair `(0.84, 0.52)` needs `|0.84 − 1.04| = 0.20`.  A search over
the model space is unnecessary: the inequality is proved, so no such population
exists.  The replication above lands at `(1.000, 0.518)`, discrepancy `0.036`,
comfortably inside the allowance — consistent, as expected.

## 4. Small-case sanity checks of the Fermat sandwich

`(q−p)²/(8q) ≤ (p+q)/2 − √(pq) ≤ (q−p)²/(8p)`:

| p    | q    | lower  | exact  | upper  |
|------|------|--------|--------|--------|
| 101   | 103   | 0.00485  | 0.00490  | 0.00495  |
| 101   | 199   | 6.033    | 8.229    | 11.886   |
| 1009  | 1013  | 0.001966 | 0.001980 | 0.001983 |
| 65537 | 98317 | 1366.15  | 1656.20  | 2049.47  |

Both inequalities hold with the expected slack (the ratio of the two bounds is
exactly `q/p`).

## 5. What was *not* verified computationally

No claim is made here about the paper-154 population itself; only the reported
summary numbers were used.  All statements about what those numbers imply are
the Lean theorems, which are unconditional given their stated hypotheses.

## 6. Cycle 4: how loose is the cross-channel allowance?

All numbers below were produced with the standard library only (seed
`20260920`), and every claim they motivated is stated as a Lean theorem in
`Catalog/Probability/FactorLocalETKantorovich.lean`.

**(a) The cycle-2 constant is far from binding.**  Over 20 000 random dyadic
populations (`n = 40` points drawn uniformly in `[2^{k-1}, 2^k)` at
`k = 16, 24`) and exponent pairs `(s,t) ∈ {(1,½), (1,¼), (2,½), (1.5,.75)}`, the
largest observed value of `|t·slope_s − s·slope_t|` was **2.9 %** of the proved
allowance `s·t/Δk`.

**(b) The extremum decouples.**  Writing `f(μ) = t·log₂E[x^s] − s·log₂E[x^t]`
for a single level, the two-level discrepancy is `(f(μ₂) − f(μ₁))/Δk`, so the
sharp constant is the *oscillation* of `f` over the window box.  Maximising `f`
over two-atom populations at the window endpoints gives, at `σ = 1`:

| `(s,t)`      | `osc(f)`   | `osc(f)/(s·t·|s−t|)` |
|--------------|-----------|----------------------|
| `(1, 0.5)`   | 0.021552  | 0.08621              |
| `(1, 0.25)`  | 0.016160  | 0.08618              |
| `(2, 0.5)`   | 0.127240  | 0.08483              |
| `(1.5, 0.75)`| 0.072296  | 0.08568              |
| `(1, 0.1)`   | 0.007752  | 0.08612              |
| `(0.9, 0.6)` | 0.013976  | 0.08628              |
| `(2, 1)`     | 0.169928  | 0.08496              |

against `ln 2/8 = 0.086643`; and at fixed `(s,t) = (0.4, 0.2)` the oscillation
scales as `σ²` (`8.664e-5, 3.465e-4, 1.385e-3, 5.528e-3, 2.190e-2` for
`σ = 0.25, 0.5, 1, 2, 4`).  This is the numerical content of direction **C2**.

**(c) The Kantorovich constant is the right one for `(1, ½)`.**  The proved
dyadic bound is `E p ≤ ((4+3√2)/8)·(E√p)²` with
`log₂((4+3√2)/8) = 0.0431066`, i.e. exactly twice the tabulated
`osc(f) = 0.021552` for `(1, ½)` — the numerical extremum and the proved
allowance agree to all printed digits.  The explicit two-point population
formalised in `kantorovich_constant_near_sharp` attains
`log₂(6/(3+2√2)) = 0.0418559`, i.e. **97.1 %** of the allowance (the Lean
statement claims the weaker, easily certified `≥ 0.041`).

**(d) Consequence for the reported pair.**  `2·0.52 − 0.84 = 0.20`, while the
sharpened allowance at `Δk = 8` is `0.0431/8 = 0.00539`: the reported pair
misses by a factor of `37`.  Cycle 2 could only certify a factor `1.6`.

## 7. Cycle 5: the doubling-ray constant confirms the C2 coefficient

`K(t) = (1+2^t)²/(4·2^t)` is the proved allowance for the exponent pair
`(2t, t)` on a dyadic window (`cross_channel_slope_law_doubling`).  Against the
generic power-mean bound `2t²` of cycle 3:

| `t`   | `log₂K(t)` | `2t²`    | ratio | `log₂K(t)/(2t²)` |
|-------|-----------|----------|-------|------------------|
| 1.00  | 0.169925  | 2.000    | 11.8  | 0.08496          |
| 0.50  | 0.043107  | 0.500    | 11.6  | 0.08621          |
| 0.25  | 0.010817  | 0.125    | 11.6  | 0.08654          |
| 0.10  | 0.001733  | 0.020    | 11.5  | 0.08663          |
| 0.01  | 0.0000173 | 0.0002   | 11.5  | 0.08664          |

The last column converges to `ln 2/8 = 0.086643`, and this is exactly the
coefficient conjectured in direction **C2**: on the ray `s = 2t` one has
`s·t·|s−t| = 2t³`, so the C2 prediction
`max|t·slope_s − s·slope_t| = (ln2/8)·s·t·|s−t|·σ²/Δk` reads `(ln2/4)·t³/Δk`,
while cycle 5 gives `t·log₂K(t)/Δk`, whose ratio to `2t³` is precisely the
tabulated column.  So C2's coefficient is now *proved* along the doubling ray
and remains conjectural only off it.

## 8. Cycle 6: truncated trial division does not compress the exponent

Monte-Carlo sweep (seed `20260920`, `2·10⁵` draws per level, `p` uniform on the
dyadic window `[2^{k−1}, 2^k]`, cost `min(p, B·2^k)`), two-point slope from
`k = 16` to `k = 24`:

| `B`  | measured slope | deficit `1 − slope` |
|------|----------------|---------------------|
| 0.05 | 1.000000       | 0.000               |
| 0.25 | 1.000000       | 0.000               |
| 0.50 | 1.000000       | 0.000               |
| 0.75 | 1.000059       | −0.00006            |
| 0.90 | 0.999974       | 0.00003             |
| 1.00 | 1.000038       | −0.00004            |
| 2.00 | 1.000002       | 0.000               |

The deficit is zero to Monte-Carlo error at every truncation level, which is
exactly what `scale_invariant_slope_eq_pow` predicts: a uniform dyadic draw is
scale invariant (`p_k = 2^k·u`), and truncation at `B·2^k` preserves that
invariance, so the slope is pinned at `1`.  The `B ≤ 1/2` rows are the fully
truncated regime of `fully_truncated_slope_eq_one`, where the cost is literally
the constant `B·2^k`.

The *worst case over all admissible populations* is the adversarial two-point
configuration that sits at the top of the window at `k = 16` and at the bottom
at `k = 24`: its slope is `(23 − 16)/8 = 0.875`, i.e. deficit exactly `1/8`.
This is the numerical counterpart of `truncated_trial_slope_ge`, and it is well
above the reported `0.84` (deficit `0.16`).  Conjecture C4 of the previous
cycle — that truncation manufactures a deficit past `0.125` — is therefore
false, and the proved statement `truncation_cannot_explain_084` is the formal
version of this table.

## 9. Cycle 7: the shape-drift identity, checked numerically

Monte-Carlo check of `shape_drift_identity` (seed `20260920`, `2·10⁵` draws per
level, linear cost `a·p` with `a = 1`, lever arm `k = 16 → 24`).  The columns
are the directly measured two-point slope and the right-hand side of the
identity `1 + log₂(M₁(24)/M₁(16))/8` computed from the normalised means alone.

| normalised population `u_k`             | measured slope | identity RHS | `M₁(16)/M₁(24)` |
|-----------------------------------------|----------------|--------------|------------------|
| uniform on `[1/2, 1]` (no drift)        | 0.999878       | 0.999878     | 1.0007           |
| uniform on `2^{−0.16k}·[1/2, 1]`        | 0.839955       | 0.839955     | 2.4290           |
| deterministic `u_k ≡ 2^{−0.16k}`        | 0.840000       | 0.840000     | 2.4284           |

The two columns agree to all printed digits in every row, as they must: the
identity is an equality, not a bound.  The last row is the Lean witness
`driftShape` of `drift_realizes_084`, and its shape ratio is the predicted
`2^{1.28} = 2.428390`, matching `drift_shape_ratio` and
`trial_084_forces_shape_ratio`.  The first row is the scale-invariant control,
pinned at slope `1` (`scale_invariant_slope_eq_pow`); note that a *dyadic*
population can never reach the second row's ratio, since its normalised means
are confined to `[1/2, 1]` and the ratio is at most `2 < 2.428`
(`dyadic_shape_ratio_le_two`, `dyadic_slope_ge`).

Reading the reported slopes through the identity gives the implied drift of the
shape moments of the *one* round-41 population:

| channel        | exponent `s` | reported slope | deficit `s − slope` | implied `M_s(16)/M_s(24)` |
|----------------|--------------|----------------|---------------------|----------------------------|
| trial division | 1            | 0.84           | +0.16               | 2.4284                     |
| Pollard ρ      | 1/2          | 0.52           | −0.02               | 0.8950                     |
| Pollard ρ (89) | 1/2          | 0.523          | −0.023              | 0.8803                     |

The deficits have *opposite signs*, so the drift function
`D(s) = log₂(M_s(16)/M_s(24))/8` cannot be linear — a pure rescaling
`u_k = m_k·v` would force `D(s) = s·D(1)`, predicting `D(1/2) = +0.08` where the
ρ channel reports `−0.02`.  This sign change is the observation behind
direction **C4′**.
