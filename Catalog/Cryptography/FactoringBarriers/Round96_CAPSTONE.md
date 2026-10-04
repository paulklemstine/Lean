# Round 96 — capstone: the UMW window `[1/3, 2/5)` is closed by five independent walls

**2026-10-04. NO new factoring algorithm. NO complexity beaten. This capstone
consolidates rounds 96, 96b–96f and records the corrected conclusion.** The
investigation began by locating the one parameter window in which a rank-2 GAP
divisor cover would beat Harvey's `N^{1/5}` — and ends having attacked that
window from five structurally different directions, all of which hit the same
wall. It also records **two errors I made and caught** (a budget-escape
"witness" and a greedy-cover mislabel), because both are the kind the record's
rules exist to catch.

Machine-checked companion: `UMWCountingWall.lean` (**0 `sorry`, 0 `axiom`**,
footprint `[propext, Classical.choice, Quot.sound]`).
Empirical: `Experiments/UMWWindow/` — `umw_window.py`, `gap_structure.py`,
`aligned_construct.py`, `design_alignment.py`, `rank_c_search.py`,
`divisor_cover_number.py` (all deterministic, `out*.txt` committed).

---

## 1. The window (round 96) — still the right target

Umans–Wang (arXiv:2511.10851) reduce deterministic factoring below `N^{1/5}` to
their `(α,β)`-Divisor Conjecture; Theorem 5.5 gives `Õ(N^{max(α,β)/2})`.
* Beating Harvey needs `γ = max(α,β) < 2/5`.
* A counting argument forces `α + 2β ≥ 1`, i.e. `γ ≥ 1/3`.

> **The window is `γ ∈ [1/3, 2/5)`, with slack `3γ−1` growing from 0 at `1/3`.**

This survives round 96d: He–Sahai (arXiv:2608.06681) refute the *arithmetic-
progression* version but leave the higher-rank version open, and the frontier
(`1/5` deterministic, `L[1/3]` heuristic, Shor unbeaten) is unchanged.

## 2. The five walls

Every attempt to build a cover in the window hit one of these:

| # | route | what happened |
|---|---|---|
| 96b | **random** covers | birthday obstruction: coverage `~ n^{2γ−1}` → 0 for `γ<1/2` |
| 96c | **hill-climbed rank-2 GAP** | full cover at `n=800` is a **fluke**; dies to 35–61% at `n=5000` |
| 96d | **design/difference-set** | ratio to random `~1.0–1.06`; constant factor, same exponent |
| 96e | **higher-rank GAP** (`c=2..6`) | 32–56% at every rank; no improvement with rank |
| 96f | **divisor-reuse** (divisibility, not residues) | cover number `~ Θ(π(n))`, exceeds `n^{2γ}` budget |

The common wall is the **counting constraint** (machine-checked): covering the
maximal prime powers forces the product of the differences to absorb the
primorial `≈ exp(n)`, i.e. `α + 2β ≥ 1`; and the divisor-reuse variant of round
96f shows even the most favourable "one difference per prime power" packaging
needs `Θ(π(n)) ≈ n/ln n` differences — too many for any `γ<1/2`.

**Kneser's theorem is the transferable insight.** A GAP's residues mod `i` are
at least as spread as a random set of equal size (a single coprime-step AP
saturates all residues mod `i≥|S|`). So GAP structure creates *fewer* residue
collisions than random — it obeys the birthday law, rather than evading it. This
predicted the round-96e outcome before the search ran.

## 3. Two errors caught (and why they matter)

* **Budget escape (96c).** An apparent "complete cover of `[2,800]` at
  `γ=0.36` (exponent 0.180)" had `max(S)=384151 > M=65816` — the hill-climb had
  wandered outside the magnitude budget. Under a **strict** budget (over-budget
  builds rejected, never truncated) it collapses to `≈50%`. This is Round 49's
  own "truncated-then-rechecked" failure (§4c), caught here by scaling to
  `n=2000,5000`.
* **Greedy mislabel (96f).** A first cover-number script reported "`k=2`, full
  cover" for `n=400`. `k` was counting *picks* before the greedy gave up
  (`bestgain=0`), not a successful cover — 354 of 400 were still uncovered.
  Fixed by reporting `uncovered` + a `full` flag and using all `d≤M` as
  candidates. **The corrected number (126) is what makes the wall visible.**

Both errors had the same shape: a search reported success because a *stopping
criterion* fired, not because the *goal* was met. The record's rules (5)–(7)
exist for exactly this.

## 4. Honest conclusion

* **No new factoring algorithm. No complexity beaten.** Consistent with the
  program's 52-round record.
* The window `[1/3, 2/5)` is **not** shown to be empty — but it is now attacked
  from five independent structural directions, and the shared obstruction is
  machine-checked. **A beating construction, if it exists, must differ from all
  five families above in some way none of them captured.**
* The two honest "live" possibilities that survive this round:
  1. **Rigour, not search:** prove the counting wall extends to rule out *all*
     rank-`n^{o(1)}` GAP covers below `γ=2/5`. This would close the window as a
     theorem.
  2. **A genuinely new covering mechanism** — none of the five routes bound
     `|S mod i ∩ T mod i|` *and* exploited `|{i : i∣(s−t)}|` simultaneously.
     A construction that makes a *single* difference carry a co-designed set of
     large prime powers **and** the intervening small integers, while keeping
     `|S|,|T| ≤ n^β`, is the one idea the analysis has not excluded. (Round 96c
     §2 showed the naive `T={t₀}` bundling overshoots `M` by ~600×; the bundling
     must run over *differences*, not points, and share structure.)

**A kill is a success.** Five walls recorded, two self-caught errors documented,
one machine-checked constraint, one transferable theorem (Kneser).