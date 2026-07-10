# Computational Evidence — Gödel's Casino

All values below were computed in Lean (`#eval`) from the definitions in
`Catalog/Logic/GodelCasino.lean`. The model: a finite space of worlds `Ω`, a
statement `s : Ω → Bool` (its truth value in each world), a bet `b : Bool`, per-world
payoff `+1` if the bet matches and `-1` otherwise, and `expProfit s b` the expected
payoff under the uniform prior over worlds. `optProfit s = max (expProfit s true)
(expProfit s false)`.

## Single cards

| Card (statement)                              | class               | `expProfit · true` | `expProfit · false` | `optProfit` |
|-----------------------------------------------|---------------------|--------------------|---------------------|-------------|
| `id : Bool → Bool` (true iff world = `true`)   | balanced, independent | `0`               | `0`                 | `0`         |
| `fun _ => true`                                | valid (decidable)   | `1`                | `-1`                | `1`         |
| `fun i : Fin 4 => i ≠ 0` (true in 3/4 worlds)  | biased, independent | `1/2`              | `-1/2`              | `1/2`       |

Observations, all matching the closed form `expProfit s true = (2·#true − #worlds)/#worlds`:

- **Zero-sum:** in every row `expProfit true + expProfit false = 0`.
- **Decidable ⇒ full win:** the valid card pays the maximum `1`.
- **Balanced ⇒ no edge:** the `id` card (the "you're right in some model" / Continuum-
  Hypothesis-like card) pays `0` no matter how you bet.
- **Independent but biased ⇒ partial edge:** an independent card that is *not* balanced
  still gives a strictly positive optimal profit (`1/2` here). So the obstruction is not
  independence per se but **balance** (`#true = #worlds/2`).

## Decks (average optimal profit per round)

| Deck                                   | `deckOptProfit` |
|----------------------------------------|-----------------|
| `[id]` (one balanced card)             | `0`             |
| `[⊤, ⊤]` (two valid cards)             | `1`             |
| `[⊤, id]` (one valid, one balanced)    | `1/2`           |

## Counterexample hunt

The conjecture claims a *universal* per-round lower bound of `1/3`. The deck `[id]`
achieves `deckOptProfit = 0 < 1/3`, a direct counterexample. More generally, a deck of
`k` balanced cards has average `0`, and a deck mixing a fraction `f` of decidable cards
with balanced cards has average exactly `f`, which ranges over all of `[0,1]`. There is
therefore no universal positive lower bound.

## Takeaway

The numbers confirm the formal verdict: the player's entire edge comes from the
*decidable* cards. Genuinely balanced independent statements contribute exactly `0` to
expected profit and cost `1` in the worst case. This motivates the theorems proved in the
Lean file.
