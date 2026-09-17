# Computational evidence — QUBIT-TRADE3 (paper 86)

All numbers below were produced by short deterministic-seed Python scripts before the Lean
formalization, and every claim they support is now backed by a machine-checked theorem in
`Catalog/Bridges/`. The scripts themselves are exploratory, not verification: the verified
statements are the Lean theorems named at the end of each section.

## 1. The controlled-order population (the construction of paper 86)

Setup reproducing the experiment's design: for `r ∈ {210, 310, 434, 510}` (all `≡ 2 mod 4`,
so `r = 2u` with `u = r/2` odd), draw 20-bit primes `p, q ≡ 1 mod r`, choose per-prime orders
`d_p, d_q ∈ {r, r/2}` at random, realise elements of those exact orders by projection
`h^((p-1)/d)`, and CRT-combine them into a base `a` modulo `N = p q`. Then test every even
period `t = k · lcm(d_p, d_q)`, `k ≤ 4`, for a nontrivial `gcd(a^{t/2} − 1, N)`.

| class | `d_p = d_q` | `d_p ≠ d_q` |
|---|---|---|
| some certificate splits `N` | **0** | **35** |
| no certificate ever splits `N` | **25** | **0** |

The dichotomy is exact, with no exceptions in 60 trials: equal per-prime orders are permanently
unlucky, mixed orders always split. Formalized as
`QubitTrade.controlled_order_dichotomy` and `QubitTrade.ControlledInstance.extractable_iff_mixed`
(`Catalog/Bridges/QubitTradeFactorExtraction.lean`).

## 2. The sharp criterion on *unconstructed* semiprimes

The conjecture extracted from §1 was that equality of orders is not the real cause — equality of
their **2-adic valuations** is. Test: 400 random pairs of primes in `[101, 400]` and random
units `a`, comparing the predicate `v₂(ord_p a) ≠ v₂(ord_q a)` against an exhaustive search over
even periods `t = k · ord_N(a)`, `k ≤ 6`.

```
trials 398   predicate agrees with search 398   mismatches: none
```

Formalized as `QubitTrade.splits_iff_two_adic_ne`
(`Catalog/Bridges/QubitTradeSharpCriterion.lean`), which proves the equivalence for *all*
exponents, not just `k ≤ 6`.

## 3. The cap is per-base, not per-modulus

Random bases modulo random semiprimes of the same population:

```
share of bases with v₂(ord_p a) = v₂(ord_q a)  ≈  0.254   (299 samples)
```

So roughly three quarters of bases are usable, and re-drawing the base escapes the unlucky
half quickly — consistent with the classical Shor analysis. The qualitative statement that a
usable base *always exists* (for every odd semiprime with distinct prime factors) is formalized
as `QubitTrade.exists_splitting_base`, and the quantitative bound is formalized in
group-theoretic form as `QubitTrade.card_unlucky_pairs_le_half`: in a product of two cyclic
groups of even order — the shape of the unit group modulo an odd semiprime — at most half of all
bases are permanently unlucky. Transporting that bound along the Chinese Remainder isomorphism to
residue bases themselves is left as a future direction (see `FUTURE_DIRECTIONS.md`).

## 4. The ladder shape

The measured ramp of paper 86 (`P_factor(s=1) = 0.018 / 0.056 / 0.158 / 0.181` along
`t = wall−4 … wall+2`, ladders `0.056 / 0.204 / 0.471` at `wall−2`, saturation `≈ 0.53`) is
reported here only as the motivation for the model. What is proved is the *shape*, not the
numbers: `ramp c p s = c (1 − (1−p)^s)` compounds as independence
(`QubitTrade.ramp_compound`), is strictly increasing with diminishing returns
(`QubitTrade.ramp_strictMono`, `QubitTrade.ramp_gain_antitone`), is priced linearly for small
budgets (`QubitTrade.ramp_le_union_bound`), never reaches its ceiling
(`QubitTrade.ramp_lt_cap`) and converges to it (`QubitTrade.tendsto_ramp`); over a population
the ceiling factorizes as cert-rate × mixed-role fraction
(`QubitTrade.popCap_eq_certRate_mul_mixedFraction`). No numerical value from the experiment is
asserted as a theorem.
