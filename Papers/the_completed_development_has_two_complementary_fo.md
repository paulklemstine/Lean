# Computational Evidence: Randomized Gödel's Casino

We study a randomized player on a finite space of possible worlds `W`. A
statement is `s : W → Bool`, a prior over worlds is `μ : W → ℚ`, and a strategy
is the probability `r ∈ [0,1]` of betting `true`. The per-world expected payoff
(over the player's own coin) is

    randPayoff s r ω = r·payoff(true,ω) + (1-r)·payoff(false,ω)
                     = (2r-1)  if s ω = true,
                     = (1-2r)  if s ω = false.

The prior-expected profit is `expRand μ s r = ∑_ω μ ω · randPayoff s r ω`.

## 1. The closed form (checked by hand on small cases)

Writing `T = trueMass = ∑_{s ω = true} μ ω` and `F = falseMass`, direct
expansion gives the **bilinear** identity

    expRand μ s r = (2r-1)·(T − F).

Small checks:

| W        | μ (uniform)      | s        | T   | F   | r    | (2r-1)(T-F) | direct sum |
|----------|------------------|----------|-----|-----|------|-------------|------------|
| Bool     | (1/2, 1/2)       | id       | 1/2 | 1/2 | 3/7  | 0           | 0          |
| Bool     | (1/2, 1/2)       | id       | 1/2 | 1/2 | 1    | 0           | 0          |
| Fin 3    | (1/3,1/3,1/3)    | [T,T,F]  | 2/3 | 1/3 | 1    | 1/3         | 1/3        |
| Fin 3    | (1/3,1/3,1/3)    | [T,T,F]  | 2/3 | 1/3 | 1/2  | 0           | 0          |
| Fin 3    | (1/3,1/3,1/3)    | [T,T,F]  | 2/3 | 1/3 | 0    | -1/3        | -1/3       |

All rows agree, confirming the closed form and the derived facts:
* `r = 1/2` (fair coin) gives `0` in **every** world and for **every** prior.
* The optimal value over `r ∈ [0,1]` is attained at an endpoint (a *pure* bet),
  equal to `|T − F|`.

## 2. Complement-symmetric priors force value 0

If there is an involution `σ : W → W` with `μ(σ ω) = μ ω` and `s(σ ω) = ¬ s ω`
(each world paired with a truth-flipped, equally-likely partner), then `T = F`,
so `expRand μ s r = 0` for **all** `r`. Tested:

* `W = Bool`, `μ` uniform, `s = id`, `σ = not`: `T = F = 1/2`, value `0` for
  `r ∈ {0, 3/7, 1/2, 1}`. ✓
* `W = Fin 4`, `μ` uniform, `s = [T,T,F,F]`, `σ` swapping `0↔2, 1↔3`: `T = F =
  1/2`, value `0`. ✓

## 3. Counterexample hunt for "randomization can beat pure play"

Claim tested: `∃ r ∈ [0,1]` with `expRand μ s r > max(expRand μ s 0,
expRand μ s 1)`. Since `expRand` is affine in `r`, its maximum on `[0,1]` is at
an endpoint; a random search over `μ, s` on `W = Fin 2, Fin 3` finds **no**
counterexample, matching the theorem `no_benefit_randomization`.

## 4. Edge iff information

`∃ r ∈ [0,1], expRand μ s r > 0` holds exactly when `T ≠ F`. On `W = Fin 3`
uniform, every `s` with `#true ≠ #false` admits a profitable pure bet, and the
balanced ones (`Bool`, `s = id`) admit none — matching `edge_iff_asymmetric`.

## Conclusion

The evidence supports a single clean picture: expected profit is *bilinear* in
the strategy skew and the prior imbalance. Randomization is worthless to an
informed player, symmetric priors annihilate every strategy, and the whole edge
is the prior's asymmetry. These are exactly the theorems proved in
`Catalog/Probability/GodelCasinoRandomized.lean`.
