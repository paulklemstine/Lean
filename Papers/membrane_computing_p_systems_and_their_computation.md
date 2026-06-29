# Computational Evidence — Membrane Computing (P-Systems)

All evaluations were run in Lean against the formal model in
`Algebra/MembraneComputing/{Core,ComputationalPower,MembraneTree}.lean`.

## 1. Exponential workspace (duplication rule `a → a a`)

Population after `k` maximally-parallel steps starting from one object:

| k         | 0 | 1 | 2 | 3 | 4  | 5  | 6  | 7   | 8   |
|-----------|---|---|---|---|----|----|----|-----|-----|
| #objects  | 1 | 2 | 4 | 8 | 16 | 32 | 64 | 128 | 256 |

`#eval (List.range 9).map (fun k => (steps dupRule k {()}).card)`
→ `[1, 2, 4, 8, 16, 32, 64, 128, 256]` = `2^k`. (OEIS A000079, powers of two.)

This matches `card_steps_dup : (steps dupRule k {()}).card = 2 ^ k`: an
**exponential** parallel workspace produced in a **linear** number of steps —
the resource behind P-systems' polynomial-time attacks on NP problems.

## 2. Conservation (symport/antiport-style relabelling rule)

`#eval (List.range 5).map (fun k => (steps relabelRule k {true,false,true}).card)`
→ `[3, 3, 3, 3, 3]`: the count is invariant, matching `relabel_count_const`
(a corollary of `card_steps_of_conservative`).

## 3. Membrane dissolution conserves objects

Test tree `t = node {1,2} [ node {3} [ node {4,5} [] ], node {6} [] ]`
(6 objects). After dissolving the first inner membrane:

`#eval (t.total, (Mem.dissolve t).total)` → `(6, 6)`.

Matches `Mem.total_dissolve` (and the stronger `Mem.objects_dissolve`, which
shows the entire object **multiset** — not just its size — is preserved).

## Counterexample hunt

- Tried to break conservation by using a *non*-conservative rule of size ≠ 1:
  the count then changes (e.g. duplication doubles it), consistent with the
  `Conservative` hypothesis being necessary — no counterexample to the guarded
  statements.
- Tried `dissolve` on a leaf membrane (`node c []`): defined as identity, total
  unchanged — boundary case handled.
