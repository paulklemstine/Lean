# Computational Evidence — Doppelgänger Phase-Lock

All computations below were run inside Lean 4 / Mathlib (`#eval` for exploration,
`decide` for the kernel-verified claims).  Every statement marked **[verified]** is a
theorem in `Catalog/Applications/DoppelgangerPhaseLock/` proved without `sorry` and
without `native_decide`; statements marked **[exploratory]** were obtained by `#eval`
only and are *not* part of the formal claims.

## 1. Model recap

An agent is a deterministic reaction rule `δ : S → I → S` (internal states `S`, stimuli
`I`).  Two spatially separated copies observe the *same* stimulus word `w`.  They
**phase-lock** on `w` when `drive δ w s = drive δ w t` for *all* initial states `s, t`
(`Doppelganger.Locks`).  This is exactly a synchronizing (reset) word of the automaton.

## 2. Small-case search: minimal phase-lock times of the Černý agents

`cernyN n` on `n` states over the alphabet `{a, b}`: `a` rotates the state cyclically,
`b` maps state `0 ↦ 1` and fixes the rest.  Exhaustive breadth-first search over all
`2^k` words:

| states `n` | minimal locking word (shortest, lexicographically first) | length | `(n-1)²` | cubic bound `(n-1)n²` proved here |
|---|---|---|---|---|
| 3 | `b a a b`                     | 4  | 4  | 18  |
| 4 | `b a a a b a a a b`           | 9  | 9  | 48  |
| 5 | `b a a a a b a a a a b a a a a b` | 16 | 16 | 100 |

* `n = 3` and `n = 4` are **[verified]**: `Doppelganger.cerny3_lock_time_eq_four` and
  `Doppelganger.cerny4_lock_time_eq_nine` prove both the existence of the locking word
  *and* the non-existence of any shorter one, by kernel-checked exhaustive search.
* `n = 5` is **[exploratory]** (`#eval` search over all words of length ≤ 16).
* For `n = 3` the shortest locking word is **unique**: `#eval` filtering all 16 words of
  length 4 returns exactly `[b, a, a, b]` **[exploratory]**, and no word of length ≤ 3
  locks **[verified]**.

The observed sequence of minimal lock times `4, 9, 16` is `(n-1)²` (squares, OEIS
A000290 read from the term `4`).  This is the classical Černý family; it sits far below
the cubic upper bound `(|S|-1)·|S|²` that we prove unconditionally, which is why the gap
is recorded as Conjecture C1 in `FUTURE_DIRECTIONS.md`.

## 3. Counterexample hunt

* **Reversible agents.** The parity agent `s ↦ ¬s` is injective in every stimulus and
  never locks — `#eval` of the decision procedure returns `false`, and this is
  **[verified]** twice: structurally
  (`Doppelganger.parityAgent_not_phaseLocking`, via the general reversibility
  obstruction) and by decision procedure
  (`Doppelganger.parityAgent_not_phaseLocking_by_decision`).
* **Distinct stimuli.** Two copy agents (`δ s i = i`) lock after one *shared* stimulus,
  but stay permanently out of phase when fed `(true, false)` forever
  (`Doppelganger.desync_of_distinct_stimuli`) **[verified]**.  So "identical stimuli" is
  not decoration: it is the whole content of the hypothesis.
* **Infinite memory.** The countdown agent on `ℕ` (`s ↦ s - 1`) merges *every pair* of
  states, yet no single word locks all states: a word of length `n` fails on the pair
  `(n+1, 0)` (`Doppelganger.pairwise_mergeable_not_phaseLocking`) **[verified]**.  Hence
  the finiteness hypothesis in the main synchronization theorem cannot be dropped.

## 4. Rarity of failure under blind driving

For a locking block `u` of length `L` over an alphabet with `q = |I|^L` blocks, the
counted fraction of length-`L·m` stimulus streams that fail to lock is at most
`(1 - 1/q)^m` (`Doppelganger.nonlocking_fraction_le`) **[verified]**.  Numerically, for
the Černý agent `cerny3` (`L = 4`, `|I| = 2`, `q = 16`):

| blocks `m` | worst-case failure fraction `(15/16)^m` |
|---|---|
| 1  | 0.938 |
| 10 | 0.524 |
| 50 | 0.039 |
| 100 | 0.0016 |

so blind environmental driving synchronizes the doppelgängers with asymptotic
probability one (`Doppelganger.tendsto_nonlocking_fraction_zero`) **[verified]**.

## 5. What the evidence changed

The evidence killed one naive hypothesis outright (that pairwise merging always implies
global locking — false for infinite state spaces, §3), and it sharpened another: our
proved cubic bound is not tight on the Černý family, whose lock time is quadratic.  The
monotone-agent theorem `Doppelganger.monotone_lock_length` is the first fragment of that
quadratic regime that we could prove in full generality.
