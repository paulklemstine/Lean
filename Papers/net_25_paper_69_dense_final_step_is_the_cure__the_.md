# Computational Evidence — NET-25 (DENSE-FINAL-STEP-IS-THE-CURE)

Concise numerical checks made *before* formalising, plus the experimental table
that the formal statements are calibrated against.  All Lean-side checks were
run with `#eval` on the very definitions that appear in the catalog files.

## 1. The carry automaton invariant (small cases)

Digit streams (LSB-first, base 10), `a = 7,9,3,8,5,6,2,9`, `b = 4,9,9,1,7,8,9,9`:

| depth `n` | `val d n + c n · 10ⁿ` | `val a n + val b n` |
|---|---|---|
| 0 | 0 | 0 |
| 1 | 11 | 11 |
| 2 | 191 | 191 |
| 3 | 1391 | 1391 |
| 4 | 10391 | 10391 |
| 5 | 130391 | 130391 |
| 6 | 1530391 | 1530391 |
| 7 | 12530391 | 12530391 |
| 8 | 192530391 | 192530391 |

Carry states along the run: `0,1,1,1,1,1,1,1,1` — a single bit, as
`Logic.CarryChain.carry_le_one` asserts.  Both columns agree at every depth,
which is the finite-case shadow of `Logic.CarryChain.val_digitOut_add_carry`
(proved for all `n`, all digit streams, all bases).

## 2. Counterexample hunt for the two boundary claims

* *Expressivity invariance*: attempted counterexample — a target boundary vector
  `v ∈ ℝ^h` unreachable with `d = 1`.  None exists: `W = (v | 0 | … )`,
  `e = (1,0,…,0)` realises any `v`, which is the constructive proof of
  `boundaryBias_surjective`.  Hence no width can add reachable functions.
* *Gain monotonicity*: attempted counterexample — a configuration where widening
  the EOS lowers the guaranteed gain.  With the per-coordinate scale `c` held
  fixed the bound `‖e‖² ≥ d c²` cannot decrease in `d`, so none exists; the
  bound is only guaranteed for a *fixed* per-coordinate scale, and this caveat
  is recorded explicitly in the hypothesis `∀ j, c ≤ |e j|` (an
  `O(1/√d)`-rescaled initialisation would keep `‖e‖²` constant — this is a real
  boundary of the claim, and it is the sharpest experimental test we can name).

## 3. Horizon arithmetic (calibration of the third file)

With contraction `lam = 0.7`, initial separation × readout norm `Δ·R = 3`,
margin `γ = 0.5`:

* smallest `N` with `lam^N · Δ·R < γ`: **N = 6** (the horizon);
* boundary gain `m = 384/20 = 19.2`: smallest `k` with `m · lam^k ≤ 1` is
  **k = 9**, and `log m / log(1/lam) = 8.28` — matching
  `Logic.StateHorizon.horizon_shift_log` (`k = ⌈8.28⌉ = 9`).

So a `19.2×` boundary gain buys about **9 extra depth steps** at this
contraction level: additive, logarithmic in the gain.  This is the quantitative
prediction extracted from the round.

## 4. Experimental table this work is calibrated to (round-net-25, measured)

| Arm | n=8 full | params |
|---|---|---|
| cap384-raw s0/s1 | 0.0078 / 0.0063 | 471,582 |
| proj384 s0/s1 | 1.0000 / 1.0000 | 335,242 |
| pos28 s0/s1 | 0.0049 / 0.0049 | 129,830 |
| pad384 s0..s3 | 1.0000 × 4 | 335,242 |
| pad384-zeroEOS s0/s1 | 0.7441 / 0.0259 | 334,878 |
| raw20-192 s0..s6 | 0.0806, 0.6997, 0.0103, 0.0063, 0.0093, 0.0020, 0.0132 | 125,214 |

These numbers are quoted from the round's logs; they are *not* re-verified here
and no theorem in this project depends on them.  The formal results are
statements about the mathematical model (carry automaton, factorised boundary
bias, contractive readout), which the table motivates.

## 5. OEIS

No new integer sequence arises; the carry-automaton digit stream is ordinary
base-10 addition, so an OEIS search is not applicable.
