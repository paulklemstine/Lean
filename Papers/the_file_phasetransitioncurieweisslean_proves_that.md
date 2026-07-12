# Computational Evidence: Branching-Survival Phase Transition

Companion to `Physics/BranchingSurvivalPhaseTransition.lean`. The survival
probability `q` of a Galton–Watson process with Poisson offspring mean `μ`
solves the self-consistency equation

    q = 1 - exp(-μ q).

## 1. Threshold at μ_c = 1 (subcritical vs. supercritical)

Positive root of `f(q) = 1 - exp(-μ q) - q` on `(0, 1)` (bisection):

| μ    | positive q* | phase        |
|------|-------------|--------------|
| 0.5  | 0 (none)    | subcritical  |
| 0.8  | 0 (none)    | subcritical  |
| 1.0  | 0 (none)    | critical     |
| 1.1  | 0.176134    | supercritical|
| 1.5  | 0.582812    | supercritical|
| 2.0  | 0.796812    | supercritical|
| 3.0  | 0.940480    | supercritical|

A strictly positive survival probability appears exactly once `μ > 1`, matching
`branching_phase_transition` and mirroring the Curie–Weiss threshold `β_c = 1`.

## 2. Verification of the lower bound `2(μ-1)/μ² ≤ q*`

Every tested supercritical `μ` satisfies the quantitative bound proved in
`branching_exponent_lower`:

| μ    | q*        | 2(μ-1)/μ²  | q* ≥ bound |
|------|-----------|------------|------------|
| 1.01 | 0.019736  | 0.019606   | yes        |
| 1.1  | 0.176134  | 0.165289   | yes        |
| 1.5  | 0.582812  | 0.444444   | yes        |
| 2.0  | 0.796812  | 0.500000   | yes        |
| 3.0  | 0.940480  | 0.444444   | yes        |

## 3. Critical exponent: linear onset (exponent 1)

Ratio `q*/(μ-1)` as `μ → 1⁺` (accurate bisection):

| μ-1     | q*          | q*/(μ-1) |
|---------|-------------|----------|
| 0.1     | 1.761e-01   | 1.7613   |
| 0.01    | 1.974e-02   | 1.9736   |
| 0.001   | 1.997e-03   | 1.9973   |
| 0.0001  | 2.000e-04   | 1.9997   |

The ratio converges to `2`, i.e. `q*(μ) ~ 2(μ-1)` — a **linear** onset
(critical exponent `1`). This contrasts sharply with the symmetric Curie–Weiss
magnetization `m*(β) ~ √(3(β-1))` (exponent `1/2`). The difference is caused by
the offspring map `1 - exp(-μ q)` not being odd: its leading correction is
quadratic, not cubic.

## 4. Counterexample hunt

No counterexample to the lower bound or to the threshold dichotomy was found in
the sampled range `μ ∈ {0.5, …, 3.0}`. The subcritical claim (`q = 0` only) was
confirmed for `μ ≤ 1`; the supercritical existence and the bound
`2(μ-1)/μ² ≤ q*` held for every `μ > 1` tested.
