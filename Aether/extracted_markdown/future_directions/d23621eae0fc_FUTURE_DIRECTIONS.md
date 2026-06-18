# Future Directions — Collatz Sharp Contraction Cycle

## Synthesis

This cycle sharpened the density-contraction foundations of the Collatz catalog. The
prior file `Catalog/Computation/CollatzParityContraction.lean` proved the *naive*
arithmetic core `pow3_lt_pow2_of_two_mul_lt`: if fewer than half the steps in an orbit
segment are odd (`2j < k`), then `3^j < 2^k` and the segment contracts. That bound is
suboptimal — it throws away everything between the rational `1/2` and the true threshold
`log 2 / log 3 ≈ 0.6309`. The new file `Catalog/Computation/CollatzSharpContraction.lean`
closes that gap by replacing the combinatorial inequality `3 < 4 = 2²` with an *exact*
logarithmic characterization.

The structural insight is that the multiplicative power comparison `3^j < 2^m` is, via
strict monotonicity of `Real.log` on the positives, *exactly equivalent* to the additive
linear inequality `j·log 3 < m·log 2` (`pow3_lt_pow2_iff_log`). Once contraction is
phrased additively, the optimal density threshold `log 2 / log 3` appears for free, and we
get the sharp criterion `pow3_lt_pow2_of_density`. We verified that this strictly dominates
the old bound: `log_of_two_mul_lt` shows every naively-captured segment is captured, and
`sharp_threshold_strictly_stronger` exhibits the explicit gap case `(j,m) = (1,2)` (i.e.
`3 < 4`) where the sharp criterion fires but the naive one does not. We also pinned the
threshold constant `log 3 / log 2` strictly inside `(1,2)` (`log3_div_log2_mem_Ioo`).

What did NOT close: lifting *segment* contraction `3^j < 2^m` to *orbit* contraction
`T^[k] n < n`. The obstruction is the additive `+1` accumulated at every odd step, which
contributes a geometric error term that only becomes negligible for large `n`. This is
recorded honestly as `sharp_orbit_contraction_conjecture` (the file's single `sorry`,
marked as an open conjecture, never a result). The cycle therefore isolates exactly where
the remaining difficulty lives: not in the power arithmetic (now optimal), but in the
affine error control of the orbit map.

## Results Summary

- `pow3_lt_pow2_iff_log`: proved — exact equivalence `(3:ℝ)^j < 2^m ↔ j·log 3 < m·log 2`, converting multiplicative contraction into additive density.
- `nat_pow3_lt_pow2_iff_log`: proved — the same equivalence transported to `ℕ` power comparisons.
- `pow3_lt_pow2_of_density`: proved — sharp contraction criterion: density below `log 2 / log 3` forces `3^j < 2^m`; strictly generalizes the naive `2j < k` bound.
- `log_of_two_mul_lt`: proved — the naive bound `2j < m` implies the sharp logarithmic bound (forward containment).
- `sharp_threshold_strictly_stronger`: proved — explicit witness `(1,2)` where the sharp criterion fires but the naive one fails (strict separation).
- `log3_div_log2_mem_Ioo`: proved — the optimal exponent `log 3 / log 2 = log₂ 3` lies strictly in `(1,2)`, locating the true density threshold above `1/2`.
- `sharp_orbit_contraction_conjecture`: conjecture (`sorry`) — realized-density segment contraction lifts to `T^[k] n < n` beyond a threshold `N₀`; open, blocked by the `+1` error term.

## Research Directions

### Direction 1: Affine Error Control for Orbit Contraction
**Hypothesis**: For a length-`k` segment with `j = oddCount n k` odd steps obeying the
sharp density bound `j·(log 3/log 2) < k - j`, there is a threshold `N₀` (depending only on
`k`) such that `n ≥ N₀ ⟹ T^[k] n < n`. The `+1` per odd step contributes at most a
`3^j` geometric tail, so contraction holds once `n` dominates `2^k/(2^{k-j} - 3^j)`.
**Test**: Prove the affine orbit bound `T^[k] n ≤ (3^j · n + C_k)/2^{k-j}` with an explicit
`C_k ≤ 3^j`, then combine with `pow3_lt_pow2_of_density` to discharge
`sharp_orbit_contraction_conjecture`. Sanity-check `N₀` numerically for `k = 20, 50`.
**Why now**: The power-arithmetic half is now *optimal and axiom-clean*
(`pow3_lt_pow2_of_density`); the only missing ingredient is the additive remainder, which
is a finite, fully elementary computation.
**If true**: First fully formal *sharp* orbit-contraction theorem in the catalog, and the
exact statement needed by any density-based Collatz attack.
**If false**: The failure would localize a genuine arithmetic obstruction in the error
term, telling us the sharp density bound is necessary but not sufficient at the orbit level.

### Direction 2: Density Threshold as a Phase Boundary
**Hypothesis**: Define `contracts j m := 3^j < 2^m`. The set `{(j,m) | contracts j m}` is
exactly `{(j,m) | j·log 3 < m·log 2}`, and its boundary slope is the irrational `log₂ 3`,
so no rational density threshold is both sufficient and necessary.
**Test**: Formalize `¬ ∃ p q : ℕ, 0 < q ∧ (∀ j m, (q·j < p·m ↔ 3^j < 2^m))` using
irrationality of `log 3 / log 2` (provable from unique factorization: `3^j ≠ 2^m`).
**Why now**: `pow3_lt_pow2_iff_log` already reduces membership to the linear log inequality;
only the irrationality of the slope remains.
**If true**: Explains *why* the naive `1/2` and every rational surrogate are strictly
suboptimal — the optimal threshold is provably irrational.
**If false**: Would reveal an unexpected rational coincidence in `3^j` vs `2^m`.

### Direction 3: Convergents of `log₂ 3` as Best Rational Contraction Bounds
**Hypothesis**: The continued-fraction convergents `p_n/q_n → log₂ 3`
(1, 3/2, 8/5, 19/12, …) give the *tightest* rational sufficient conditions: `q_n·j < p_n·m`
is the best density bound with denominator `≤ q_n` that still implies `3^j < 2^m`.
**Test**: Verify in Lean that `8·j < 5·m ⟹ 3^j < 2^m` (next convergent after `1/2`) via
`pow3_lt_pow2_iff_log`, and exhibit a case `(j,m)` separating it from `2·j < m`.
**Why now**: With the iff in hand, each rational bound is a one-line `nlinarith` over the
two logs, exactly as `log_of_two_mul_lt` already demonstrates for `1/2`.
**If true**: Produces an explicit, formally verified hierarchy of ever-sharper contraction
criteria converging to the optimum.
**If false**: Would indicate the convergents are not extremal for the integer comparison,
a surprising number-theoretic fact.

### Direction 4: Coupling Parity Exclusion with the Sharp Bound
**Hypothesis**: Parity exclusion (`oddCount_le_half_ceil`: `j ≤ ⌈k/2⌉`) already forces
`j/k ≤ 1/2 + o(1) < log 2/log 3`, so *every* sufficiently long segment satisfies the sharp
density bound automatically — the only escape is short segments or the `+1` error.
**Test**: Prove `oddCount n k · (log 3/log 2) < k - oddCount n k` for all `k ≥ k₀` directly
from `oddCount_le_half_ceil` and `log3_div_log2_mem_Ioo`.
**Why now**: Both inputs are now proved in the catalog (`oddCount_le_half_ceil` upstream,
`log3_div_log2_mem_Ioo` this cycle); the combination is pure inequality chasing.
**If true**: Reduces the Collatz contraction question to a *finite* check of short segments
plus the error-term control of Direction 1 — a major structural simplification.
**If false**: Pinpoints segment lengths where parity exclusion alone is too weak, guiding
where deeper combinatorics is required.

### Direction 5: Irrationality Measure and Quantitative Separation
**Hypothesis**: A quantitative form of Direction 2: for the gap function
`g(j,m) = m·log 2 - j·log 3`, when `g(j,m) > 0` it is bounded below by `c/m^μ` where `μ` is
the irrationality measure of `log₂ 3`. This gives an explicit margin of contraction.
**Test**: Formalize the lower bound `g(j,m) ≥ c·3^{-j}` from `|3^j/2^m - 1| ≥ 2^{-m}`
(integer gap) and `log` Lipschitz estimates near `1`, then connect to the error term in
Direction 1.
**Why now**: `pow3_lt_pow2_iff_log` makes `g` the canonical contraction certificate; a
quantitative version is what turns "contracts" into "contracts with a usable margin".
**If true**: Supplies the explicit margin needed to absorb the `+1` orbit error, directly
feeding Direction 1.
**If false**: Suggests the contraction margin can be arbitrarily thin, explaining the
existence of extremely long orbits (e.g. `n = 27`).
