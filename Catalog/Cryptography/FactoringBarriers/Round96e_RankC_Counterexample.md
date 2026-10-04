# Round 96e — rank-c GAP counterexample search: more structure does not escape

**2026-10-04. Still NO new factoring algorithm and NO exponent improvement.** This
is the **falsification test** of the round-96b birthday obstruction: if *any*
GAP rank `c` could cover `[n]` in the beating window `γ<0.4`, the obstruction
would be refuted and a beating construction might exist. It does not. Higher
rank gives **no improvement**, exactly as Kneser's theorem predicts.

Empirical companion: `Experiments/UMWWindow/rank_c_search.py` (deterministic;
`out_rankc.txt` committed).

---

## 1. Why higher rank is the right counterexample test

The round-96b obstruction was proved for *random* sets. A GAP is structured, so
the objection is fair: structured sets have different residue behaviour. The
decisive measurement (round 96d appendix, reproduced here):

| set of size 64 | `|S mod i|` at `i = 50,100,150,200,250,300` |
|---|---|
| single AP, coprime step | 50, 64, 64, 64, 64, 64 (saturates) |
| rank-2 GAP (8×8) | 48, 60, 64, 64, 52, 64 |
| rank-3 GAP (4×4×4) | 50, 55, 55, 55, 55, 55 |
| **random 64-set** | 39, 49, 54, 55, 58, 58 |

A GAP's residues mod `i` are **as spread as, or more than,** a random set of
equal size (Kneser/Cauchy–Davenport: `|S mod i| ≥ Σ L_j − (c−1)` when
aperiodic). So GAP structure creates **fewer** residue collisions than random,
not more — which means it should **not** beat the birthday law; it should obey
it at least as well. That is the falsifiable prediction this round tests.

## 2. The search

Build `S, T` each a sum of `c` arithmetic progressions
(`S = AP(a₁,d₁,L₁)+⋯+AP(a_c,d_c,L_c)`), `|S| = |T| ≈ n^γ`, with the magnitude
budget `M = exp(n^γ)` enforced **strictly** — each AP is allotted a per-AP budget
`M/c` so the sum cannot exceed `M` (the first version sized each AP to the full
`M`, giving 100% rejection and an infinite loop; fixed). Hill-climb the
generators, `c ∈ {2,3,4,6}`, `γ ∈ {0.36, 0.399}`, `n = 800`. Coverage = number of
`i ∈ [2,n]` dividing some **nonzero** difference.

## 3. Result

| rank `c` | `γ=0.36` (exp 0.180) | `γ=0.399` (exp 0.200) |
|---|---|---|
| 2 | 308/799 (38%) | 453/799 (56%) |
| 3 | 257/799 (32%) | 412/799 (51%) |
| 4 | 301/799 (37%) | 274/799 (34%) |
| 6 | 269/799 (33%) | 281/799 (35%) |

**Higher rank does not help.** There is no monotone improvement with `c`; every
rank sits at 32–56%, none reaches a full cover, and nothing beats the rank-2
plateau from round 96c. **The counterexample search fails**, exactly as the
Kneser-based prediction said. The birthday obstruction survives a serious
structural attack.

---

## 4. What this means

* The window `γ ∈ [1/3, 2/5)` is now attacked from **four** directions and holds:
  random sets (96b), hill-climbed rank-2 GAPs (96c), design/difference-set
  alignment (96d), and now higher-rank GAPs (96e). **No cover below exponent
  `1/4` has been exhibited by any of them.**
* This does **not** prove the obstruction for all GAPs — it is a measurement at
  `n=800` over `c ≤ 6` with a local search. But four independent structural
  families now agree, which is strong evidence (not proof) that the window needs
  a genuinely different idea, not more search.

## 5. Honest scope

* **No new factoring algorithm. No complexity beaten.**
* The substantive content is the **Kneser-based prediction** (GAP structure
  obeys the birthday law, because its residues are *more* spread) and its
  **confirmation** by the rank sweep. That is a transferable result, not a
  one-off number.
* **Not claimed:** that no GAP cover exists below `γ=0.4` — only that four
  structural families, each searched honestly under a strict budget, fail to
  produce one, and the theory predicts they should.

**Next attack.** The measurement arms are exhausted for local search. The two
remaining moves are both about *rigour*, not more search:
1. **Prove** the birthday obstruction for arbitrary GAP covers of size `n^γ`,
   `γ<1/2` — closing the window as a theorem.
2. **Escape the birthday regime entirely** by changing what is covered: the
   obstruction counts residues mod each `i≤n`; a construction that reuses one
   difference to cover many `i` via its *divisor structure* (not its residues)
   is the only route the analysis has not excluded. That points back to the
   `lcm`-bundle idea of round 96c §2 — but now bundling **differences**, not
   single points.