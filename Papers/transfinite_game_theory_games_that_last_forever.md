# Computational Evidence: Well-Founded Game Determinacy

The central object is the game *value* `W p`, defined by the Zermelo fixed point
`W p ↔ ∃ q, mv p q ∧ ¬ W q` ("the mover wins iff some move reaches a position
losing for the opponent"). Before formalizing, we checked the theory on the
concrete **countdown game** on `ℕ`: from `a` one may move to any `b < a`.

## Small-case calculations (countdown game)

Backward induction from the terminal position `0`:

| position `n` | legal moves to        | `W n` (mover wins?) | reason                         |
|:------------:|:----------------------|:-------------------:|:-------------------------------|
| 0            | none (terminal)       | **false**           | no move ⇒ mover loses          |
| 1            | 0                      | **true**            | move to `0`; opponent stuck     |
| 2            | 0, 1                   | **true**            | move to `0`; opponent stuck     |
| 3            | 0, 1, 2                | **true**            | move to `0`; opponent stuck     |
| n ≥ 1        | 0, …, n−1              | **true**            | move to `0`; opponent stuck     |

So the pattern is unambiguous: `W n ↔ n ≠ 0`. This is exactly the theorem
`Countdown.W_iff`. The parity of the number of remaining moves under optimal play
matches the `alternation` invariant: from a winning `n ≥ 1`, the mover reaches
`0` in one move, i.e. the first terminal position occurs on turn `1` (odd = the
opponent's move), which is what `determinacy` predicts.

## Universal claim tested: "every play terminates"

For the countdown game, a longest play from `n` has length `n` (decrease by 1 each
move), and every play is finite because `<` on `ℕ` is well-founded. We tested the
general mechanism (`reaches_terminal`) against several opponent strategies
(always move to `0`, always decrease by `1`, move to a random smaller value): in
every case the play reaches `0`. No counterexample to termination exists precisely
because the move relation is well-founded — this is the hypothesis of the theory.

## Counterexample hunt for the determinacy dichotomy

We looked for a position that is neither a mover-win nor a mover-loss. None can
exist: `W p ∨ ¬ W p` is decidable classically, and `determinacy`
(`MoverWins p ↔ W p`) shows the operational notion of "can force a win" coincides
with `W`. Dropping well-foundedness *does* break determinacy (e.g. a single
position looping to itself never terminates), confirming that well-foundedness is
the essential hypothesis rather than an artifact.

## Transfinite aspect

Well-foundedness bounds no play by a fixed finite length: a position with moves to
`0, 1, 2, …` has children of unbounded finite rank, giving it rank `ω`; iterating
(e.g. `ℕ ×ₗ ℕ` under the lexicographic order) yields rank `ω²`, and so on through
the countable ordinals. The determinacy proof uses only well-foundedness, so it
applies uniformly to all such transfinite-rank games.
