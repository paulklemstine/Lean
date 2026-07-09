# Computational Evidence — Gödel's Casino

## 1. Per-card expected payoff `2p − 1`

Payoff scheme: correct bet `+1`, incorrect bet `−1`, win probability `p`.
Expected payoff `E(p) = p·(+1) + (1−p)·(−1) = 2p − 1`.

| win prob `p` | E(p) = 2p−1 | interpretation                    |
|--------------|-------------|-----------------------------------|
| 1            | +1          | winnable / decidable card (sure)  |
| 3/4          | +1/2        | favorable but uncertain           |
| 1/2          | 0           | independent card, hedged (fair)   |
| 1/4          | −1/2        | unfavorable                       |
| 0            | −1          | sure loss                         |

`E(p) > 0 ⇔ p > 1/2`: profit is exactly "doing better than a coin flip".

## 2. Total profit on mixed decks (small cases)

`totalProfit ps = Σ (2 pᵢ − 1)`. Decks written as (#sure-win `p=1`, #hedged `p=1/2`).

| deck             | totalProfit | > 0 ? |
|------------------|-------------|-------|
| (1, 0)           | 1           | yes   |
| (1, 2)           | 1           | yes   |
| (0, 5)           | 0           | no (no edge) |
| (2, 4)           | 2           | yes   |
| (n, m)           | n           | iff n ≥ 1 |

Observation: hedged (independent) cards contribute exactly `0`; the profit equals
the number of winnable cards. This is the structural fact behind the linear
lower bound.

## 3. The "one-third" threshold

If a fraction `1/3` of a length-`N` deck is winnable and the rest are hedged,
`totalProfit ≥ N/3`. Concrete simulation with `N = 1000`:

- deck1000 = 334 winnable + 666 hedged
- totalProfit(deck1000) = 334·(+1) + 666·(0) = **334 > 0**.

More generally for `(k, N−k)` decks the profit is `k`, so any positive winnable
fraction bounded away from `0` yields profit growing linearly in `N`.

## 4. Counterexample hunt (honest boundary)

- If **no** card beats a coin flip (all `p = 1/2`), profit is exactly `0`: the
  strict-edge hypothesis in `casino_positive_profit` is necessary, not decorative.
- If some card is bet *below* `1/2` (a genuinely bad bet), profit can be negative,
  e.g. deck (1 sure win, 1 card at `p=0`) gives `1 + (−1) = 0`, and (0,·) with one
  `p=0` gives `−1`. Hence the "no worse than a coin flip" hypothesis is load-bearing.
- The slogan "≥ 1/3 of arithmetic statements are decidable" is **not** a theorem of
  the arithmetic hierarchy; treating it as an unconditional fact would be a false
  step. It is encoded as an explicit hypothesis on the deck.

## 5. Independence as symmetry

For a statement independent over a family of models (some model true, some false),
every bet `b ∈ {true, false}` is correct in some model, and every bet is wrong in
some model. No fixed directional bet (e.g. "always FALSE on Con(ZFC)") is uniformly
correct — confirming that the profit must come from the decidable fraction, not
from guessing independent cards.

## Conclusion

The computational landscape supports the *conditional* claim: a deck with a
winnable fraction bounded away from zero and the rest hedged to break-even is
strictly profitable in expectation, with profit at least the winnable count.
The unconditional folklore version is false and was pruned before formalization.
