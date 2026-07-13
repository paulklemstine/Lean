# Computational Evidence — Disjunctive Sum of Well-Founded (Transfinite) Games

All claims below are ultimately discharged formally in
`Catalog/MachineLearning/TransfiniteGameSum.lean`. This note records the
small-case computations that motivated the theorems and the counterexample hunt
that produced the two contrarian disproofs.

## 1. The value function `W` of the countdown game

`Countdown` lives on `ℕ`: from `a` a player may move to any `b < a`. The value
`W n` ("the player to move wins") satisfies the Zermelo fixed point
`W p ↔ ∃ q, mv p q ∧ ¬ W q`.

| n | terminal? | W n | reason |
|---|-----------|-----|--------|
| 0 | yes       | F   | no move, mover stuck (loss) |
| 1 | no        | T   | move `1 → 0`, opponent stuck |
| 2 | no        | T   | move `2 → 0` |
| 3 | no        | T   | move `3 → 0` |

So `W n ↔ n ≠ 0` (formalized: `Countdown.W_iff`). Every positive position is a
win by moving directly to `0`.

## 2. The disjunctive sum = two-heap Nim

The disjunctive sum of countdown with itself is exactly **two-heap Nim**: a move
lowers one of the two heaps to any smaller value. Classic theory says a position
`(m, n)` is a loss for the mover (a P-position) iff `m = n` (Grundy value
`m XOR n = 0`). Small table of `Wsum (m, n)` ("mover wins"):

| (m,n) | 0 | 1 | 2 | 3 |
|-------|---|---|---|---|
| **0** | F | T | T | T |
| **1** | T | F | T | T |
| **2** | T | T | F | T |
| **3** | T | T | T | F |

The diagonal is all `F` (losses); off-diagonal all `T`. This is precisely the
prediction `Wsum (m,n) ↔ m ≠ n`.

* The **diagonal `F`** entries are the content of the flagship theorem
  `diag_loss : ¬ Wsum mv hwf (a, a)` — proved for *every* well-founded game, not
  just countdown, via the transfinite mirroring strategy.
* The row/column through `0` (`Wsum (0,n) ↔ n ≠ 0`) is a special case of
  `sum_terminal_left` (a terminal component is neutral).

## 3. Counterexample hunt (contrarian mode)

We tested two natural-looking universal conjectures against the table above.

**Conjecture C1:** "the disjunctive sum of two *winning* positions is winning."
* Test `(1,1)`: `W 1 = T`, `W 1 = T`, but `Wsum (1,1) = F`. **Counterexample.**
* Formalized as `Countdown.sum_of_wins_can_lose`. (This is the entire diagonal:
  every `(n,n)` with `n ≥ 1` is a winning-plus-winning position that is a loss.)

**Conjecture C2:** "adjoining a *losing* (P) position never changes the winner"
(i.e. a P-position is an absorbing element for the sum).
* Test `(0,1)`: `W 0 = F` (a P-position), `W 1 = T`, and `Wsum (0,1) = T`. The
  loss `0` did **not** turn the win `1` into a loss. **Counterexample.**
* Formalized as `Countdown.p_position_not_neutral`. Only the *terminal* /
  empty game is genuinely neutral (`sum_terminal_left`/`sum_terminal_right`); a
  general losing position is not.

## 4. OEIS

No new integer sequence is introduced; the relevant "sequence" is the Nim
P-position characterization `m = n`, which is standard combinatorial game theory
(Sprague–Grundy). No OEIS lookup was warranted.

## 5. Scope note

Well-foundedness (not finiteness) is the only hypothesis: the branching may be
infinite and the game rank an arbitrary ordinal (countdown already has rank `ω`),
so all results are genuinely about transfinite games.
