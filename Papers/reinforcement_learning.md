# Computational evidence

All numbers below were produced with Lean 4 `#eval` (IEEE `Float` arithmetic) on a two-point
response space `Ω = {0,1}`, with

```
SFT reference   p = (0.30, 0.70)
reward model    r = (1.00, 0.00)
pretraining     d = (0.80, 0.20)
KL temperature  β = 0.5
```

Policies are parametrized by their mass `t = q(0)` on the first response, and

```
J_γ(t) = t·r₀ + (1−t)·r₁ − β·KL(q‖p) + γ·( d₀ log t + d₁ log(1−t) ).
```

The evidence stage is deliberately small: it is used only to sanity-check the four inequalities
that the Lean development then proves in full generality.

## 1. Gibbs policy and free energy

| quantity | value |
|---|---|
| `π_β(0) = p₀e^{r₀/β}/Z` | `0.760004` |
| `F(r) = β log Z` | `0.535229` |
| grid argmax of `J_0` over `t ∈ {0.001,…,0.999}` | `t* = 0.760`, `J = 0.535229` |

The `γ = 0` grid maximizer agrees with the closed-form Gibbs policy to the grid resolution,
and the optimal value agrees with `β log Z` to 6 decimals — a numerical check of
`RLHF.objective_gibbs` / `RLHF.variational_principle`.

## 2. The PTX optimum has no closed form but exists and is unique

Grid maximization of `J_γ` (step `10⁻³`):

| `γ` | `t*` | `J_γ(t*)` |
|---|---|---|
| `0.0` | `0.760` | `0.535229` |
| `0.1` | `0.767` | `0.484806` |
| `0.5` | `0.780` | `0.283873` |
| `2.0` | `0.792` | `−0.467417` |

The maximizer moves monotonically towards the pretraining distribution `d₀ = 0.8` as `γ` grows,
and no closed-form Gibbs formula reproduces these values (the stationarity condition is
transcendental).  In every run the grid objective was unimodal — consistent with the strict
concavity proved in `RLHF.objectivePTX_midpoint_gt`.

## 3. Pythagorean drift bound (`RLHF.ptx_pythagorean`, `RLHF.ptx_drift_le`)

Reported as `(KL(q*‖π_β), (γ/β)·KL(d‖π_β), β·KL(q*‖π_β)+γ·KL(d‖q*), γ·KL(d‖π_β))`:

| `γ` | `KL(q*‖π_β)` | bound `(γ/β)KL(d‖π_β)` | Pythagorean LHS | Pythagorean RHS |
|---|---|---|---|---|
| `0.1` | `0.000135` | `0.000914` | `0.000383` | `0.000457` |
| `0.5` | `0.001118` | `0.004569` | `0.001155` | `0.002285` |
| `2.0` | `0.002899` | `0.018278` | `0.001842` | `0.009139` |

Both inequalities hold with room to spare, and `KL(q*‖π_β) → 0` as `γ → 0`, matching
`RLHF.ptx_drift_tendsto_zero`.

## 4. Gibbs–Bogoliubov–Feynman gap (`RLHF.freeEnergy_add_inner_le`, `freeEnergy_bregman_eq_kl`)

Gap `F(s) − F(r) − 𝔼_{π_r}[s − r]` for several alternative reward models `s`:

| `s` | gap |
|---|---|
| `(2.0, 0.0)` | `0.123704` |
| `(0.0, 1.0)` | `0.834632` |
| `(1.0, 0.0)` (= `r`) | `0.000000` |
| `(3.0, −1.0)` | `0.583163` |

Non-negative always, and exactly zero at `s = r` — the supporting-hyperplane behaviour, and
(by the Bregman identity) equal to `β·KL(π_r‖π_s)`.

## 5. Lipschitz / reward-hacking budget (`RLHF.freeEnergy_lipschitz`)

Reported as `(|F(r) − F(s)|, ‖r − s‖_∞)`:

| `s` | `|ΔF|` | `‖r−s‖_∞` |
|---|---|---|
| `(2.0, 0.0)` | `0.883709` | `1.000000` |
| `(0.0, 1.0)` | `0.314624` | `1.000000` |
| `(3.0, −1.0)` | `1.863176` | `2.000000` |

The `1`-Lipschitz bound is respected and is nearly tight for large sup-norm perturbations
(`1.863` vs `2.000`).

## 6. Strict midpoint concavity (`RLHF.objectivePTX_midpoint_gt`)

Gaps `J_γ((t₁+t₂)/2) − (J_γ(t₁)+J_γ(t₂))/2`:

| `γ` | `(t₁,t₂)` | gap |
|---|---|---|
| `0.5` | `(0.2, 0.8)` | `0.207944` |
| `0.5` | `(0.40, 0.45)` | `0.001428` |
| `0.0` | `(0.1, 0.9)` | `0.184032` |

Strictly positive in all cases, including at `γ = 0`.

## 8. Stationarity, the self-consistent Gibbs form, and the anti-starvation floor

Instance: `Ω = Bool`, `β = 1`, `γ = 0.5`, `r = (1, 0)`, `p = (0.5, 0.5)`, `d = (0.3, 0.7)`.
Ternary search on the one-dimensional simplex gives the PPO-ptx optimum

| quantity | value |
|---|---|
| `q*` | `(0.595481, 0.404519)` |
| `J_γ(q*)` | `0.182608` |
| score at `true` | `0.077135` |
| score at `false` | `0.077135` |
| score gap | `9.7 × 10⁻⁹` |

The score is constant to search precision, as `RLHF.ptx_stationarity_iff` requires.  Feeding `q*`
back through the self-consistent Gibbs map `q ↦ normalize(p · exp((r + γ d/q)/β))` returns
`(0.5954812, 0.4045188)` — the fixed-point identity `RLHF.ptx_maximizer_iff_self_consistent`.

Anti-starvation floor with reward ceiling `M = 1`
(`γ d y / (β log(1/p y) + M + γ − r y)`):

| `y` | floor | `q* y` |
|---|---|---|
| `true` | `0.125718` | `0.595481` |
| `false` | `0.159588` | `0.404519` |

Both floors hold with a comfortable margin, consistent with `RLHF.ptx_no_starvation`; the margin
suggests the constant is not optimal, which is next-cycle sub-conjecture 2 in
`FUTURE_DIRECTIONS.md`.

## 7. OEIS

No integer sequence arises in this development (all objects are real-valued functionals on a
simplex), so no OEIS lookup applies.

**Status of this file.** These are floating-point explorations, *not* verified computations.
Every claim they support is proved in full generality, `sorry`-free, in
`Catalog/Algebra/RLHFTiltTorsorPTX.lean`, `Catalog/Algebra/RLHFPTXExistence.lean`,
`Catalog/Algebra/RLHFPTXDrift.lean` and `Catalog/Algebra/RLHFStationarity.lean`.
