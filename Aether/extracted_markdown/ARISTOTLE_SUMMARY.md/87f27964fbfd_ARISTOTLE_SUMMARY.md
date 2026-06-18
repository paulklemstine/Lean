# Summary of changes for run e34a3162-82d2-4a93-9ca7-da2dc148a010
## What I did

I executed a new research cycle on **the rank of apparition as a lattice morphism**, extending the existing Fibonacci "spine" (`m ∣ F n ↔ fibRank m ∣ n`) in `Catalog/Applications/RankOfApparition.lean`. I added a new **§7** to that file (it is deliberately self-contained against Mathlib, matching the file's established pattern), containing 7 new theorems, all proved with `sorry = 0` and axioms restricted to the standard `propext / Classical.choice / Quot.sound` (verified individually).

### New theorems (`Catalog/Applications/RankOfApparition.lean`, §7)
- `fibRank_eq_of_forall` — universal property: `fibRank m` is the unique positive `d` whose multiples are exactly the apparition indices of `m`.
- `fibRank_lcm` — join law: `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)` for `0 < a, 0 < b`.
- `fibRank_lcm_fib` — closed form `fibRank (lcm (F a) (F b)) = lcm a b` for `a, b ≥ 3`.
- `fib_lcm_dvd_fib_lcm` — hypothesis-free `lcm (F a) (F b) ∣ F (lcm a b)`.
- `fibRank_gcd_dvd` — meet inequality `fibRank (gcd a b) ∣ gcd (fibRank a) (fibRank b)` (one-way, as the spine linearises lcm but not gcd).
- `card_apparition_Ioc` — exact density: `#{ n ∈ Ioc 0 N | m ∣ F n } = N / fibRank m`.
- `card_apparition_Ioc_pair` — joint exact density `N / lcm (fibRank m₁) (fibRank m₂)`, with no error term and no coprimality needed (strengthening the conjectured coprime-only version).

Each theorem carries a brief `-- !-- comment -- !--` proof sketch and a `!-- Lab Notebook --` block (Hypothesis / Result / Insight / Failure analysis), as requested.

### Verification
I independently confirmed the proofs by elaborating a fully self-contained copy of all definitions plus the §7 theorems, checked the merged file through the LSP (real proof goals close cleanly), grepped to confirm no `sorry` remains (the only match is the docstring phrase "sorry-free"), and ran axiom checks on all seven theorems — each uses only `propext`, `Classical.choice`, `Quot.sound` (the lcm-divisibility lemma needs only `propext`, `Quot.sound`). I fixed one real bug found during verification (swapped `Nat.dvd_antisymm` arguments in `fibRank_eq_of_forall`).

### FUTURE_DIRECTIONS.md
Added `FUTURE_DIRECTIONS.md` at the project root with a Synthesis, a Results Summary, and 5 falsifiable research directions (gcd strictness criterion, asymptotic/natural density limit, prime-power ranks via Lifting-the-Exponent, abstracting the spine to arbitrary strong divisibility sequences, and Carmichael's composite case via the join law), each including a "The key insight is…" sentence and a "Why now?" justification.

The unifying lesson recorded for the next cycle: the spine is a faithful order/lattice embedding of moduli (under divisibility) into indices, so the join law, the closed-form rank evaluations, and the exact apparition densities are all corollaries of that single embedding.