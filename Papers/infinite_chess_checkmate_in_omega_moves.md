# Computational Evidence — Transfinite Game Values

We model winning game trees abstractly with three node types:

* `mate` — checkmate delivered (value `0`);
* `step g` — a *winner* (White) node with a unique forced continuation `g`
  (value `value g + 1`);
* `bsup f` — a *loser* (Black) node with a countable family of continuations
  `f : ℕ → Game` (value `⨆ n, (value (f n) + 1)`).

This is the standard ordinal game-value recursion (winner minimises, loser
maximises); with a single-child winner move and countably-branching loser move
it already realises every ordinal below `ω^ω`.

## Small-case calculations

Finite games. `finGame n = step^n mate` has value

| n | value(finGame n) |
|---|------------------|
| 0 | 0 |
| 1 | 1 |
| 2 | 2 |
| k | k |

The "mate in ω" position `omegaGame = bsup finGame` offers Black a choice of
`n`, after which White mates in `n` forced moves:

    value(omegaGame) = ⨆ n, (n + 1) = ω.

White forces mate, but there is **no** finite bound: the value is genuinely `ω`.

## The hierarchy ω, ω², ω³, …, ω^ω

Sequential composition `graft A B` ("solve A, then B") is additive on values:

    value(graft A B) = value B + value A.

Iterating, `graftN k A` (k copies) has value `value A · k`. Building
`opowGame` recursively:

* `opowGame 0 = step mate`, value `1 = ω⁰`;
* `opowGame (n+1) = bsup (fun k => graftN k (opowGame n))`; Black picks `k`,
  White then solves `k` copies of the `ωⁿ`-position, giving value
  `⨆ k, (ωⁿ·k + 1) = ωⁿ·ω = ω^(n+1)`.

| n | value(opowGame n) |
|---|-------------------|
| 0 | ω⁰ = 1 |
| 1 | ω |
| 2 | ω² |
| 3 | ω³ |
| n | ωⁿ |

The diagonal position `omegaOmegaGame = bsup opowGame` lets Black pick `n` and
then forces the `ωⁿ`-puzzle:

    value(omegaOmegaGame) = ⨆ n, (ωⁿ + 1) = ω^ω.

## Counterexample hunt / sanity checks

* Additivity `value(graft A B) = value B + value A` was checked to be *right*-
  (not left-) additive, matching the non-commutativity of ordinal addition:
  e.g. `graft(omegaGame, omegaGame)` has value `ω + ω = ω·2`, and indeed
  `⨆ n, ((value B + n) + 1) = value B + ω`, confirming the outer game
  contributes on the right.
* The naive guess `(⨆ aᵢ) + β = ⨆ (aᵢ + β)` is **false** for ordinals
  (`sup_n n = ω` but `sup_n (n+1) = ω ≠ ω+1`); only *left* addition commutes
  with `sup`. All proofs respect this: `add_iSup_nat` uses left addition and
  `IsNormal`.
* Each `opowGame n` value is strictly increasing in `n`, and every `ωⁿ` is
  strictly below `ω^ω` — verified as theorems `value_opowGame_strictMono` and
  `value_opowGame_lt_omegaOmega`.

## OEIS

The finite shadow (values of `finGame n`) is the identity sequence
A001477 (`0,1,2,3,…`); the transfinite behaviour is not an integer sequence.

All claims above are proved (not merely computed) in
`Catalog/Pythagorean/InfiniteChessOmega.lean`, sorry-free, depending only on the
standard axioms `propext`, `Classical.choice`, `Quot.sound`.
