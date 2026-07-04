# Computational Evidence — Misère P‑positions of nuclear escalation ladders

## The game
Granularity `m ≥ 1`. Position = number of remaining rungs `r`. A move descends by
`s ∈ {1,…,m}`. Terminal position `0`. **Misère**: the player forced to make the
final escalation loses (equivalently, the player to move at `0` wins).

We write `wins m r = true` iff the player to move wins; a **P‑position** (mover
loses) is `wins m r = false`.

## 1. Small-case calculations (Boolean game solver)

`wins m r` for `r = 0 … 11`, misère:

| r        | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |10 |11 |
|----------|---|---|---|---|---|---|---|---|---|---|---|---|
| m=1      | W | **P** | W | **P** | W | **P** | W | **P** | W | **P** | W | **P** |
| m=2      | W | **P** | W | W | **P** | W | W | **P** | W | W | **P** | W |
| m=3      | W | **P** | W | W | W | **P** | W | W | W | **P** | W | W |

Misère P‑positions:
* m=1 → {1,3,5,7,9,11,…}  = `r ≡ 1 (mod 2)`
* m=2 → {1,4,7,10,…}      = `r ≡ 1 (mod 3)`
* m=3 → {1,5,9,…}         = `r ≡ 1 (mod 4)`

Normal play (`winsN`, mover at `0` loses):
* m=2 → P at {0,3,6,9,…}  = `r ≡ 0 (mod 3)`

## 2. Congruence check
For m=3, over `r = 0 … 39`:
* `(wins 3 r = false) ↔ (r % 4 == 1)` holds for every tested `r`.
* `(winsN 3 r = false) ↔ (r % 4 == 0)` holds for every tested `r`.

## 3. Counterexample hunt on the *stated* conjecture
The research brief claims misère P‑positions are `r ≡ 0 (mod m+1)`.
For m=1 this predicts the **even** positions, but the solver shows the P‑positions
are the **odd** positions. Every even `r ≥ 2` is a counterexample; the smallest is
`r = 2` (`wins 1 2 = true`, i.e. an N‑position, yet `2 ≡ 0 (mod 2)`).

**Conclusion of the hunt:** the stated conjecture is false. The residue `0` is the
*normal*-play (Sprague–Grundy) answer; the correct misère answer is residue `1`.
The congruence is, moreover, *exact* (holds for all `r`), not merely eventual — the
threshold `T(m) = 0` works.

## 4. Sequence identification
The subtraction game `{1,…,m}` is classical; its normal-play Grundy value is
`r mod (m+1)` and P‑positions are the multiples of `m+1` (OEIS A008587-type
arithmetic progressions). The misère P‑positions form the arithmetic progression
`1, m+2, 2m+3, …` = `{r : r ≡ 1 (mod m+1)}`.
