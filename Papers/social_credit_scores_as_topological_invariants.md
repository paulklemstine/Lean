# Computational Evidence

The three theorem files formalize concrete, checkable statements.  Below is the
small-scale numerical evidence that motivated the formal claims.  The *verified*
artifacts are the Lean theorems themselves (`Applications/SocialCredit/*.lean`,
building `sorry`-free); the figures here are illustrative.

## 1. Affine credit dynamics (`FixedPoint.lean`)

Update `x ↦ c + k·x` with reward `c = 1`, damping `k = 1/2`, start `x₀ = 0`.
Equilibrium predicted: `c/(1-k) = 1/(1/2) = 2`.

| n | score `xₙ` |
|---|-----------|
| 0 | 0        |
| 1 | 1        |
| 2 | 1.5      |
| 3 | 1.75     |
| 4 | 1.875    |
| 5 | 1.9375   |
| 10| 1.99902… |

Closed form `xₙ = kⁿ·x₀ + c·(1-kⁿ)/(1-k) = 2·(1 - 2⁻ⁿ)`, matching the table,
and `xₙ → 2`.  These are exactly `creditIterate_closed_form` and
`creditIterate_tendsto`.

## 2. Ternary encoding / Cantor attractor (`CantorAttractor.lean`)

`cantorEnc a = ∑ₙ (2·[aₙ])/3^{n+1}` with digits in `{0,2}`.

| history `a` (first digits, then 0…) | score |
|---|---|
| 000… | 0 |
| 200… i.e. `true,false,…` | 2/3 |
| 020… | 2/9 |
| 222… (all `true`) | 1 |
| 202… | 2/3 + 2/27 = 20/27 |

* All values lie in `[0,1]` — matches `cantorEnc_mem_Icc`.
* Prepending `false` sends `x ↦ x/3` (e.g. `2/3 ↦ 2/9`); prepending `true`
  sends `x ↦ x/3 + 2/3` — matches `cantorEnc_scons_false/true` and the
  self-similarity `C = C/3 ∪ (C/3 + 2/3)` (`cantorSet_self_similar`).
* **Gap test for injectivity.**  Any two histories differing first at index `n`
  differ in score by at least `2/3^{n+1} − 1/3^{n+1} = 1/3^{n+1} > 0`, so the
  map is injective — no collisions were found in a scan of all `2^{12}` length-12
  prefixes, consistent with `cantorEnc_injective`.

## 3. Tier classification / phase transition (`PhaseTransition.lean`)

`tier t x = (t ≤ x)`.  With `t = 0.5`:

| x | 0.499 | 0.4999 | 0.5 | 0.5001 |
|---|---|---|---|---|
| tier | false | false | true | true |

The value jumps at exactly `x = t` and is locally constant elsewhere — matching
`tier_discontinuousAt`, `tier_continuousAt_of_ne`, and the sensitivity statement
`tier_sensitive`.  Connectedness of `ℝ` forbids any continuous non-constant
`ℝ → Bool` classification (`continuous_binary_classification_constant`), so the
jump is unavoidable (`phase_transition_of_separating`).
