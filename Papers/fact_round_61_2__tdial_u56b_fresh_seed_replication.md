# Computational Evidence — FACT round-61 #2 (exp 542, U56B-DIAL-HOLDS-COUNT-PARITY)

All numbers below were produced with exact rational arithmetic (`fractions.Fraction`)
before the corresponding Lean statements were written. They are *evidence*, not proof;
every claim that survives is proved without `sorry` in `Catalog/MachineLearning/`.

## 1. The recorded cell

| quantity | value |
|---|---|
| pooled ρ(T, rate) | 0.669, CI [0.650, 0.690] |
| pre-stated H1 band | [0.55, 0.85] — **holds** (CI strictly inside) |
| pooled weighted advantage | +0.045 |
| H2 bar | +0.05 — **fails**, shortfall 0.005 |

Formalised as `pooled56`, `ci56Low/High`, `advantage56`, `h2Bar`, `shortfall56` and the
payload theorems `u56_ci_inside_band`, `u56_h2_fails`
(`MachineLearning/ZeroFitDialWeighted56.lean`).

## 2. Tie-attenuation ceilings for the 2-adic (trailing-zero) dial

Blocks: `dyadicBlocks b` = `[2^(b-1), …, 2, 1, 1]`, mass `2^b`.
Exact ceiling `ρ² = 1 - (Σ mⱼ³ - n)/(n³ - n)`.

Unweighted: `Σ mⱼ³ = (8^b + 6)/7`, so `ρ² → 6/7 = 0.857142…`, `ρ → 0.9258200998`.

Stratified weighting `wDyadic b p q = p·2^b :: (q · dyadicBlocks b)`:

| b | ρ² at (p,q)=(1,3) | continuum `1 - Σm³/n³` | gap | `1/n²` |
|---|---|---|---|---|
| 1 | 0.89285714 | 0.87890625 | 0.01395089 | 0.015625 |
| 2 | 0.92205882 | 0.91845703 | 0.00360179 | 0.00390625 |
| 3 | 0.92430352 | 0.92340088 | 0.00090264 | 0.00097656 |
| 5 | 0.92415251 | 0.92409611 | 0.00005641 | 0.00006104 |
| 8 | 0.92410800 | 0.92410712 | 0.00000088 | 0.00000095 |
| 12 | 0.92410715 | 0.92410714 | 3.44e-09 | 3.73e-09 |

The gap is always positive (the discrete `-mⱼ` correction pushes the finite ceiling
*above* the continuum value) and always below `1/n²`. This is exactly the sandwich
`1 - Σm³/n³ ≤ ρ² ≤ 1 - Σm³/n³ + 1/n²` proved as `spearmanSq_continuum_sandwich`.

Note `b = 1` is an exception to "weighting beats no weighting" only in the sense that
the hypothesis `b ≥ 2` is needed in `weighted_beats_unweighted`; the numbers above show
why.

## 3. The `√7` optimum

Continuum ceiling of a stratified weighting: `stratCeiling p q = 1 - (p³ + q³/7)/(p+q)³`.
Maximising over `p/q` gives `q/p = √7`, hence

```
κ* = 1 - 1/(1 + √7)² = 0.9247639617258105 ,   √κ* = 0.9616464848 .
```

Exhaustive search over `b ≤ 9`, `p ≤ 39`, `q ≤ 119` gives max `0.9247639573 < κ*`
(consistent with `weighted_cubic_cap` / `rational_weighting_strictly_suboptimal`).
Best small rational `q/p = 37/14` reaches within `10⁻⁶` of κ*
(`rational_weighting_near_optimal`); `wDyadic b 14 37` reads 0.91967 (b=2),
0.92475427 (b=5), 0.92476391 (b≥10).

Weighted budget on the ρ-scale: `√κ* - √(6/7) = 0.9616464848 - 0.9258200998 = 0.0358263850`,
i.e. between 0.0358 and 0.0359 (`weighting_gain_bounds`) — more than **seven times** the
0.005 H2 shortfall (`weighting_headroom_exceeds_shortfall`).

## 4. Radix generalisation

`kappaRadix g = (g³ - 1)/(g - 1)³`: `g = 2 ↦ 7`, `g = 10 ↦ 111/81 = 1.37037…`.
Weight gain `1/K - 1/(1+√K)²`: binary `K = 7` gives 0.0677 (< 0.068), decimal
`K = 111/81` gives 0.5175 (> 0.5) — the reweighting budget grows as the radix grows,
because a larger radix flattens the tie profile
(`weightGain_radix_strictMono`, `decimal_gain_exceeds_binary`).

## 5. Counterexample hunt

* Searched `b ≤ 12`, `1 ≤ p ≤ 60`, `1 ≤ q ≤ 200` for a finite pair beating `κ*`:
  **none found**; the maximum observed excess over the continuum value never exceeded
  `1/n²`. This motivated, and is now superseded by, the proof `wDyadic_finite_cap`
  (`ρ² ≤ κ* + 4^{-(b+1)}` for *all* `b, p, q`), instantiated at bitlen 56 as
  `u56_weighted_cap` (`ρ² ≤ κ* + 10⁻³³`).
* Searched for a profile violating `n ≤ Σ mⱼ³ ≤ n³`: none (both are now theorems).

## 6. Block-count cap (cycle 4)

Randomised search: for every `b` from 2 to 8, 400 random integer weight vectors
`W ∈ {1,…,20}^{b+1}` applied to `dyadicBlocks b`. In every case
`ρ² ≤ 1 - 1/K² + 1/n²` with `K = b+1`; the largest observed excess over `1 - 1/K²` was
`0.00275` (attained at the smallest `b`, where `1/n²` is largest). No counterexample.

Equality case: the class-equalising weights `wⱼ = 2^b/mⱼ` turn `dyadicBlocks 6` into the
flat profile `[64,64,64,64,64,64,64]` with `ρ² = 0.9795967` against the cap
`1 - 1/7² = 0.9795918` — the cap is tight to within `1/n²`, as proved in
`block_count_cap_sharp`.

Optimality search: for `b = 1,…,7`, 3000 random weight vectors with entries in
`{1,…,30}` were compared against cycle 1's class-equalising vector `eqWeights b`
(which produces the flat profiles `[1,1]`, `[2,2,2]`, `[4,4,4,4]`, … reading
`1.0, 0.91428571, 0.94117647, 0.96060038, 0.97232773, 0.97961136, 0.98437876`).
None of the 21000 weightings beat it — consistent with the proved `eqWeights_optimal`
(optimal up to `1/n²`) and with the open rigidity conjecture that the `1/n²` slack is
spurious.

## 7. OEIS

`Σ mⱼ³` for the unweighted dyadic profile is `(8^b + 6)/7`: `1, 2, 10, 74, 586, 4682, …`
— the "Jacobsthal-like" base-8 repunit family `(8^n + 6)/7`; no more specific OEIS
identification is claimed here.
