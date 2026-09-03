# Computational Evidence — T-DIAL-BITLEN (exp 508, assessment v282)

All numbers below are exact rational arithmetic; every one of them is re-derived inside
`Catalog/Pythagorean/ZeroFitDialBitlenStable.lean`, so the file itself is the verification
artifact. Nothing here is asserted on the strength of a scratch computation alone.

## 1. The six recorded cells

| bitlen | seed     | T-dial ρ | bare QR-count ρ | advantage |
|-------:|---------:|---------:|----------------:|----------:|
| 48 | 20261010 | 0.7192 | 0.5990 | +0.1202 |
| 48 | 20261011 | 0.7202 | 0.6005 | +0.1197 |
| 48 | 20261012 | 0.7198 | 0.5997 | +0.1201 |
| 52 | 20261010 | 0.7154 | 0.5760 | +0.1394 |
| 52 | 20261011 | 0.7169 | 0.5768 | +0.1401 |
| 52 | 20261012 | 0.7161 | 0.5756 | +0.1405 |

Derived exactly:

* `meanT48 = 21592/30000 = 0.719733…`, `meanQ48 = 17992/30000 = 0.599733…`,
  mean advantage `= 3600/30000 = 0.12` exactly.
* `meanT52 = 21484/30000 = 0.716133…`, `meanQ52 = 17284/30000 = 0.576133…`,
  mean advantage `= 4200/30000 = 0.14` exactly.
* bitlen drift of the mean `= 108/30000 = 0.0036`, i.e. `0.0009` per bit.
* all six T cells lie in `[0.6, 0.85]`, with margin `≥ 0.1154` above the floor and
  `≥ 0.1298` below the ceiling.

## 2. The ceiling ladder as a function of bitlen

Write `X = 8^b` (`b` = number of dyadic blocks of the exact-bitlen sample; bitlen 48 ↦
`b = 47`, bitlen 52 ↦ `b = 51`) and `p = 2^{-t}`. The catalog ceilings evaluate to

| ceiling | closed form | bitlen-free limit |
|---|---|---|
| coarse / bare-count at rate `p` | `(7/2)p(1-p)·X/(X-1)` | `(7/2)p(1-p)` |
| tip-blind at depth `t` | `(X - Xp³)/(X-1)` | `1 - p³` |
| bulk-blind at depth `t` | `(X·((7/2)p(1-p)+p³) - 1)/(X-1)` | `(7/2)p(1-p)+p³` |

Every entry is of the shape `(X·g + h)/(X-1)` with `g ∈ [0,1]`, `|h| ≤ 1`, hence within
`3/X` of its limit. Numerically:

| b (bitlen) | `3/8^b` |
|---:|---|
| 47 (48) | `1.08 · 10^{-42}` |
| 51 (52) | `4.2 · 10^{-46}` |

So the **total geometric budget for a bitlen 48 → 52 change of any ceiling is below
`1.1 · 10^{-42}`**, while the measured drift is `3.6 · 10^{-3}`: a ratio above `10^{39}`.
The formal statement uses the safe rounding `10^{-40}` and the safe factor `10^{37}`.

## 3. Counterexample hunt

* *Can the band top escape the refining ceiling at some bitlen?* No: the refining ceiling of
  the 2-adic tie profile is `(6/7)(1 + 1/(2^b(2^b+1))) > 6/7 = 0.857…` for every `b ≥ 1`,
  and `0.85² = 0.7225 < 6/7`. Checked symbolically, not just sampled
  (`band_admissible_every_bitlen`).
* *Can the bulk-blind limit `g = (7/2)p(1-p) + p³` exceed 1 (which would break the shape
  lemma)?* Yes — but only for `p > 1/2`, i.e. depth `t = 0`. Sampling: `g(0.6) = 1.056`,
  `g(0.55) = 1.032`, `g(0.5) = 1.000`, `g(0.25) = 0.671`. The factorisation
  `1 - g = (1-2p)(p-1)(p-2)/2` shows `g ≤ 1` exactly on `p ≤ 1/2`, i.e. `t ≥ 1`, which is
  why `bulkLimit_le_one` carries the hypothesis `1 ≤ t`. This corner case was found by the
  sampling sweep above and is the only hypothesis the shape argument really needs.
* *Is the bare-QR cap `0.3829` uniform down to small bitlen?* No. `rateCeil b 3` equals
  `(49/128)·X/(X-1)`, which for `b = 1` is `49/128 · 8/7 = 0.4375`. Evaluated exactly:
  `b = 4 ↦ 0.382906`, `b = 5 ↦ 0.382824`, `b = 6 ↦ 0.382814`. So the true crossing of the
  `0.3829` cap is between `b = 4` and `b = 5`; the formal statement
  `qr_count_ceiling_uniform` carries `6 ≤ b`, one step of slack, because its proof routes
  through the coarse `3·8^{-b}` shape bound rather than the exact value.

## 4. Cycle 2: the modulus sweep

Exact values of the modulus-only ceiling `3ℓ/(ℓ²+ℓ+1)` (proved in
`Pythagorean.ZeroFitDialEllAdicCeiling`, `ell_spearmanSq`):

| ℓ | limit `ρ²` | decimal | clears recorded `0.7192² = 0.51725`? |
|---:|---|---:|---|
| 2 | 6/7   | 0.8571 | yes |
| 3 | 9/13  | 0.6923 | yes |
| 4 | 4/7   | 0.5714 | yes |
| 5 | 15/31 | 0.4839 | no |
| 7 | 7/19  | 0.3684 | no |

The sweep first suggested, and the closed form then proved, that the sequence is *strictly
decreasing* — the opposite of the naive expectation that a finer valuation grading helps.
The crossing happens between `ℓ = 4` and `ℓ = 5`, which is exactly the content of
`recorded_dial_forces_small_modulus` (`ℓ ≥ 5` excluded, with the clean intermediate bound
`ρ² ≤ 1/2`) and `moduli_two_three_four_admissible`.

Spot-checks of the closed form `ρ² = (3ℓ/(ℓ²+ℓ+1))(1 + 1/(x(x+1)))`, `x = ℓ^b`:

* `ℓ = 2, b = 1`: profile `[1,1]`, no ties, formula gives `(6/7)(1+1/6) = 1`. ✓
* `ℓ = 2, b = 3`: profile `[4,2,1,1]`, formula gives `(6/7)(1+1/72) = 0.8690…`, and the
  catalog's `dyadic_spearmanSq` gives the same (`ell_two_recovers_dyadic`). ✓
* `ℓ = 3, b = 2`: profile `[6,2,1]`, `x = 9`, formula gives `(9/13)(91/90) = 7/10` exactly,
  and direct evaluation of `spearmanSq [6,2,1]` also returns `7/10`. ✓

## 5. Sequence check

The block profile driving all of this is `dyadicBlocks b = [2^{b-1}, …, 2, 1, 1]`, the tie
profile of the 2-adic valuation on `{0,…,2^b-1}`; its tie correction is
`12·Σ(m³-m)/12 = (8^b-1)/7 - (2^b-1)`, whose `b`-th terms `1, 9, 73, 585, 4681, …` are the
repunits in base 8 (A023001 shifted, `(8^b-1)/7`). No new sequence is produced by the
bitlen axis: the bitlen enters only through the normalisation `X/(X-1)`, which is the
content of the main theorem.
