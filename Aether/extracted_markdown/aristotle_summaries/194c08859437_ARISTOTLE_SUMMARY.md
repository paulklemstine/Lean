# Summary of changes for run 4eabb01d-7462-4a3b-bdec-959ac08149b1
## What I did

I worked on the Carmichael / primitive-divisor arc (the cycle's priority targets `CarmichaelComposite` and the Fibonacci `fib_gcd` identity) and discovered the arc was actually broken: both `Catalog/Speculative/AutoResearch/CarmichaelComposite.lean` and `Catalog/Shared/CarmichaelProof.lean` imported a file `Shared.CarmichaelHelper` that **did not exist**, and referenced a lemma `fib_primitive_divisor_prime` that was never written. The catalog sources also weren't wired into the build (wrong `srcDir`, and the `Applications`/`Novelty` source trees were not registered as libraries).

### New Lean files (all main theorems `sorry = 0`; axioms = {propext, Classical.choice, Quot.sound})

1. `Catalog/Shared/CarmichaelHelper.lean` — supplies the previously-phantom **prime case of Carmichael's theorem**, `fib_primitive_divisor_prime`: for prime `n ≥ 13`, `F(n)` has a primitive prime divisor. Proved via a self-contained Fibonacci entry-point (rank of apparition) API (`entryPt`, `entryPt_dvd`, `entryPt_min`, `entryPt_ne_one`). This restores compilation of the whole arc.

2. `Catalog/Novelty/PrimitiveDivisorEntryLaw.lean` — extends the catalog's generic engine `Applications.UnifiedRankOfApparition` with four new theorems:
   - `sds_primitive_divisor_prime` — primitive prime divisor at prime index for **any** strong divisibility sequence with `u 1 = 1` (generalizes the Fibonacci case);
   - `sds_primitive_divisor_apparition` — sharp form: the primitive prime's apparition set is exactly the multiples of `p`;
   - `fib_primitive_at_prime` — the Fibonacci/Carmichael prime case re-derived from the engine;
   - `mersenne_primitive_at_prime` — Bang's theorem at prime exponents (`2^p − 1` has a primitive prime divisor), a cross-domain corollary of the same abstract theorem.

Both files contain `-- !-- Lab Notebook -- !--` blocks (Hypothesis/Result/Insight/Failure analysis) and one-to-two-sentence `-- !-- … -- !--` proof sketches per theorem.

3. `FUTURE_DIRECTIONS.md` — synthesis, results summary, and five falsifiable research directions (each with a "The key insight is…" sentence and a "Why now?" justification), centered on closing the remaining composite infinite-tail case via a Lean theory of the Fibonacci primitive part.

### Build infrastructure
Fixed `lakefile.toml`: added `srcDir = "Catalog"` and registered the `Applications` and `Novelty` libraries so the catalog sources build. Verified `lake build Shared.CarmichaelHelper Novelty.PrimitiveDivisorEntryLaw` and `lake build Speculative.AutoResearch.CarmichaelComposite` complete successfully, and confirmed via `#print axioms` that all five new theorems are free of `sorry`/non-standard axioms.

### Honest status of the remaining gap
One pre-existing `sorry` remains in the arc: `Shared/CarmichaelProof.fib_carmichael_composite` for composite `n > 10000` (the genuinely hard Zsygmondy/cyclotomic-growth tail, for which Mathlib has no supporting machinery). I left this user content intact and laid out a concrete proof roadmap for it as Direction 1 of `FUTURE_DIRECTIONS.md`. I introduced no new sorries or axioms.