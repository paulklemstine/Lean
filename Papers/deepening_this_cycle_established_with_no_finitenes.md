# Computational evidence — the kernel/game bridge

This note records the small-case checks that motivated the theorems in
`ArgumentationKernelGame.lean`. All claims are subsequently proved formally in
Lean; the numbers below are only sanity checks.

## 1. The dictionary

For an argumentation framework `(A, R)` (`R a b` = "`a` attacks `b`"):

| argumentation      | digraph theory              | combinatorial game            |
|--------------------|-----------------------------|-------------------------------|
| stable extension   | kernel of `flip R`          | P-position set of `flip R`    |
| conflict-free      | independent set             | no move loss→loss             |
| attacks all outside| absorbing / dominating      | every non-loss moves to a loss|

The equivalence is `stable_iff_kernel` / `stable_iff_gameSolution`.

## 2. Odd cycle — non-existence

Directed 3-cycle `0 → 1 → 2 → 0` (`cyc3 a b := b = a+1`). Enumerate all
`2³ = 8` candidate kernels `S ⊆ {0,1,2}`:

| S          | independent? | absorbing?                         | kernel? |
|------------|--------------|------------------------------------|---------|
| {}         | yes          | no (0 has no out-edge into S)      | no      |
| {0}        | yes          | no (1's successor 2 ∉ S)           | no      |
| {1}        | yes          | no (2's successor 0 ∉ S)           | no      |
| {2}        | yes          | no (0's successor 1 ∉ S)           | no      |
| {0,1}      | no (0→1)     | —                                  | no      |
| {1,2}      | no (1→2)     | —                                  | no      |
| {0,2}      | no (2→0)     | —                                  | no      |
| {0,1,2}    | no           | —                                  | no      |

No row is a kernel ⇒ **no kernel** ⇒ **no stable extension** and, in game terms,
the 3-cycle "you may move to the next vertex forever" game has no consistent
win/loss labelling. This is exactly `no_kernel_cyc3` / `no_stable_cyc3`.

Even cycles do have kernels (e.g. the directed 4-cycle has the two kernels
`{0,2}` and `{1,3}`), consistent with the classical even/odd dichotomy — we did
not formalise the even case, only the odd obstruction that shows some hypothesis
is genuinely needed.

## 3. Well-founded case — unique solution

Path `0 → 1 → 2` (`M 0 1`, `M 1 2`, and nothing else), which is well-founded
(reverse relation has no infinite ascending chain). The game recursion
"`a` is losing iff every move leads to a win":

* `2` terminal ⇒ losing (P).
* `1 → 2` (a loss) ⇒ `1` winning (N).
* `0 → 1` (a win, its only move) ⇒ `0` losing (P).

So the unique kernel / P-set is `{0, 2}`, and one checks it is independent
(no edge inside `{0,2}`) and absorbing (`1`'s edge `1→2` lands in the set).
This is the content of `kernel_isLoss` + `kernel_unique` +
`exists_unique_kernel`, and, transported, `exists_unique_stable_of_wf`.

## 4. OEIS

No integer sequence is central to these results; the `completeAF` stable count
`= n` (proved in `ArgumentationStable.lean`) is the identity sequence. No new
OEIS lookup was warranted.
