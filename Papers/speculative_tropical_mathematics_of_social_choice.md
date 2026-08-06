# Computational evidence: tropical social choice

All computations below were run inside Lean 4 (`#eval`) on an exactly computable model of
the tropical semiring: `Option ℤ` with `none = ∞` (tropical zero), `some 0` (tropical
one), `⊕ = min`, `⊙ = +`.  This is the integral sub-semiring of the semiring
`TR = Tropical (WithTop ℝ)` used in the formalisation, so every counterexample found here
transfers verbatim, and every exhaustive check is a check over a finite window of the
coefficient space.

## 1. Exhaustive search over tropical linear rules

A tropical linear rule on `n` voters is `f(x) = ⨁ᵢ aᵢ ⊙ xᵢ = minᵢ (aᵢ + xᵢ)`.  The
coefficient grid used is `a ∈ {∞, 0, 1, 2}ⁿ` (with `{-1}` added in the `n = 2` run), and
axioms were tested on all profiles from the same grid.

| `n` | tropical Pareto (unanimous) | Pareto **and** tropically multiplicative | of those, non-dictatorial |
|-----|------------------------------|-------------------------------------------|---------------------------|
| 2   | 7                            | 2                                         | 0                         |
| 3   | 37                           | 3                                         | 0                         |
| 4   | 175                          | 4                                         | 0                         |

The multiplicative unanimous rules found are exactly the `n` coefficient vectors
`(∞,…,∞,0,∞,…,∞)`, i.e. the dictators `x ↦ x_k`.  This is the content of the formal
theorem `tropical_arrow`.

## 2. OEIS

The counts of unanimous (tropical Pareto) rules over the 4-element coefficient grid
`{∞, 0, 1, 2}` are `1, 7, 37, 175, 781, …` for `n = 1, 2, 3, 4, 5`, i.e. `4ⁿ − 3ⁿ`
(a unanimous rule is one whose coefficients are all `≥ 0` with at least one equal to `0`).
This is **OEIS A005061** (`a(n) = 4^n − 3^n`).  The number of *full* tropical social
welfare functions is instead exactly `n`, the dictators.

## 3. Counterexample hunt (weaker axioms)

Dropping tropical multiplicativity and keeping only tropical IIA (= tropical linearity)
plus tropical Pareto, the search returns many non-dictatorial rules; for `n = 2` and the
grid `{∞,-1,0,1,2}` there are `5` unanimous rules that are not multiplicative:

```
(0,0), (0,1), (0,2), (1,0), (2,0)
```

The simplest is `a = (0,0)`, i.e. the **Rawlsian rule** `f(x) = min(x₁,x₂)`; the evaluation
`(pareto, multiplicative, isDictator) = (true, false, false)` confirms it is unanimous,
non-multiplicative and non-dictatorial.  This is the witness used in
`exists_nondictatorial_of_tropPareto_tropIIA`.

Explicit failure of multiplicativity for the Rawlsian rule:
`x = (0,∞)`, `y = (∞,0)` gives `x ⊙ y = (∞,∞)`, so `f(x ⊙ y) = ∞` while
`f(x) ⊙ f(y) = 0 ⊙ 0 = 0`.

## 4. Classical (ordinal) IIA is genuinely violated

With two voters and two alternatives, the cost profiles

```
u : voter 0 = (a ↦ 2, b ↦ 3),  voter 1 = (a ↦ 5, b ↦ 4)
v : voter 0 = (a ↦ 2, b ↦ 3),  voter 1 = (a ↦ 5, b ↦ 1)
```

induce the same individual rankings of `{a,b}` (voter 0 prefers `a`, voter 1 prefers `b`)
but the Rawlsian rule ranks `a` above `b` in `u` (`min(2,5)=2 < 3 = min(3,4)`) and `b`
above `a` in `v` (`min(3,1)=1 < 2 = min(2,5)`).  Formalised as
`rawlsian_violates_classical_IIA`; it explains why the tropical escape does not
contradict Arrow's theorem — tropical IIA is a cardinal, not an ordinal, condition.

## 5. Zero-temperature (Maslov) limit

Numerically, for `y = (2, 5)` the Boltzmann aggregator
`softMin(t) = -(1/t)·log(e^{-2t} + e^{-5t})` gives

| `t`  | `softMin(t)` | bound `min y − log 2 / t` |
|------|--------------|----------------------------|
| 1    | 1.9514       | 1.3069                     |
| 2    | 1.9988       | 1.6534                     |
| 5    | 2.0000       | 1.8614                     |
| 10   | 2.0000       | 1.9307                     |

consistent with the proved two-sided bound
`min y − log|s| / t ≤ softMin(t) ≤ min y` (`softMin_bounds`) and the limit
`softMin(t) → min y` (`softMin_tendsto_inf'`).

## 6. Kernel-checked version of these searches

All of the finite searches above have been re-run *inside the Lean kernel* in
`Catalog/Probability/TropicalSocialChoiceEvidence.lean`, where the model `T = Option ℤ`
(`none = ∞`, `some 0 =` tropical one, `⊕ = min`, `⊙ = +`) is defined executably and each
count is a theorem proved by `decide` (no `native_decide`, no axioms):

| statement | theorem |
|---|---|
| unanimous rules over `{∞,0,1,2}ⁿ`: `7, 37, 175` for `n = 2,3,4` | `paretoCount_two/three/four` |
| unanimous **and** multiplicative: `2, 3, 4` | `swfCount_two/three/four` |
| of those, non-dictatorial: `0, 0, 0` | `nondictatorialSWFCount_two/three/four` |
| unanimous **and** diagonally idempotent: `3, 7, 15 = 2ⁿ − 1` | `oligarchyCount_two/three/four` |
| Rawlsian rule `(0,0)`: unanimous, non-multiplicative, non-dictatorial | `rawlsian_evidence` |
| explicit multiplicativity failure at `x = (0,∞)`, `y = (∞,0)` | `rawlsian_mul_failure` |
| weighted rule `(0,1)`: unanimous but *not* diagonally idempotent | `weighted_not_diagIdem_evidence` |

The axioms are tested on all profiles from the sub-grid `{∞, 0, 1}ⁿ`; this suffices to
reject every non-dictatorial candidate, in agreement with the proved theorems
`tropical_arrow` (dictators) and `oligarchy_iff` (coalitions).  The last row is the finite
shadow of the new separation between coalition rules and genuinely weighted rules: the
`2ⁿ − 1` diagonally idempotent unanimous rules are exactly the nonempty coalitions, and
`2ⁿ − 1 − n` of them are non-dictatorial (`card_nondictatorial_coalitions`).

## Addendum: the second round of results

The results added in the second round are algebraic or analytic rather than enumerative,
and each is fully proved in Lean, so no new numerical search was required.  For orientation
they are summarised here together with the finite data that motivated them.

| finding | where proved |
|---|---|
| the tropical Arrow theorem holds over **any** nontrivial commutative semiring without zero divisors | `semiring_arrow_iff` (`TropicalSocialChoiceSemiring.lean`) |
| in particular over `Tropical (WithTop G)` for any linearly ordered cancellative `G`, and over the bounded min–max semiring | `tropical_arrow_general`, `minmax_arrow` |
| a product semiring (which *has* zero divisors) admits a non-dictatorial rule `x ↦ (1,0) ⊙ x₀ ⊕ (0,1) ⊙ x₁` | `exists_nondictatorial_of_zero_divisors` |
| the count `2ⁿ − 1` of diagonally idempotent unanimous rules (rows `oligarchyCount_two/three/four` above) counts the *linear* ones only: dropping linearity there are non-coalition solutions, e.g. `min (x₀, φ(x₁))` with `φ(r) = 2r` for `r ≥ 0`, `r/2` for `r < 0` | `not_oligarchy_of_tropIIA_tropDiagIdem` (`TropicalSocialChoiceNonlinear.lean`) |
| the numeric zero-temperature tables are explained by an exponentially small error term: `0 ≤ (min y − log m/t) − softMin ≤ (q/m)·e^{−tΔ}/t` | `softMin_sandwich_of_gap` (`TropicalSocialChoiceDequantisation.lean`) |
| every non-dictatorial unanimous tropical linear rule violates classical IIA, so ordinal IIA + tropical linearity + unanimity ⟺ dictatorship | `nondictatorial_violates_classical_IIA`, `arrow_recovered_iff` (`TropicalSocialChoiceOrdinal.lean`) |
| monotone ("tropically strategy-proof") is implied by linearity, so it excludes nothing: `min (x₀, 1 + x₁)` is strategy-proof, unanimous, linear, not a coalition rule | `not_tropical_gibbard_satterthwaite` (`TropicalSocialChoiceStrategyProof.lean`) |
