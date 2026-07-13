# Computational Evidence — Cantor's Hierarchy of Infinities

The theorems in `Catalog/Bridges/CantorHierarchy.lean` are statements of
transfinite cardinal arithmetic, so the relevant "evidence" is structural rather
than numerical. We record the small-case data that motivates each claim.

## 1. The Cantor / beth tower `cantorTower`

Starting from `ℵ₀` and repeatedly applying `c ↦ 2^c`:

| n | `cantorTower n` | name        |
|---|-----------------|-------------|
| 0 | `ℵ₀`            | `ℶ₀`        |
| 1 | `2^ℵ₀ = 𝔠`      | `ℶ₁` (continuum) |
| 2 | `2^𝔠`           | `ℶ₂`        |
| 3 | `2^(2^𝔠)`       | `ℶ₃`        |

By Cantor's theorem each strict inequality `cantorTower n < cantorTower (n+1)`
holds, so the tower gives an explicit strictly increasing sequence of distinct
infinities — the finite beth numbers. This is verified in Lean by
`cantorTower_strictMono` and `cantorTower_lt_succ`.

## 2. Cantor's theorem, finite sanity checks

For finite `n`, `|Set (Fin n)| = 2^n > n`, the finite shadow of
`card_lt_powerset`:

- `n = 0`: `|𝒫 ∅| = 1 > 0`
- `n = 1`: `2 > 1`
- `n = 2`: `4 > 2`
- `n = 3`: `8 > 3`

The strict inequality `2^n > n` for all `n` is the finite avatar of
`c < 2^c`, which holds for *all* cardinals, finite and infinite alike.

## 3. Cofinality of the continuum (König)

König's theorem forbids `𝔠 = ℵ_ω` (a countable supremum `sup_n ℵ_n`). The
witness is `continuum_cofinality_uncountable : ℵ₀ < (𝔠).ord.cof`. There is *no*
counterexample: any attempt to write `𝔠` as a countable increasing union of
smaller cardinals fails, because a cardinal always strictly exceeds any sum of
`< cf` many smaller cardinals.

## 4. Counterexample hunt for `CH_iff_no_intermediate_cardinal`

The equivalence `CH ↔ (no cardinal strictly between ℵ₀ and 𝔠)` was stress-tested
against the two directions:

- If some `c` satisfies `ℵ₀ < c < 𝔠` and CH held, then `c < ℵ₁ = succ ℵ₀`
  forces `c ≤ ℵ₀`, contradicting `ℵ₀ < c`. No counterexample.
- Conversely `ℵ₁` itself would be an intermediate cardinal if `ℵ₁ < 𝔠`, so its
  absence pins `𝔠 = ℵ₁`.

No counterexamples were found; the equivalence is a theorem, machine-checked in
Lean.

## OEIS

The only integer sequence appearing is `2^n` (cardinalities of finite power
sets), OEIS **A000079**: `1, 2, 4, 8, 16, 32, …`.
