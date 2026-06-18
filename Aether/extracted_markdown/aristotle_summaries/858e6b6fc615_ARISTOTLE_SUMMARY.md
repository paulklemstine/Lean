# Summary of changes for run 0d5d29e7-f0b9-4a36-9448-d210aabea2da
This cycle developed Fibonacci entry-point ("rank of apparition") theory, closing the cycle's designated research-target `sorry` and extending it with new fully-proved theorems.

## What was done

**1. Closed the priority research-target `sorry`** in `Catalog/Speculative/AutoResearch/FibonacciEntryPointCharacterization.lean`:
- `fibEntryPt_mul_coprime` — the **lcm law** `α(a·b) = lcm(α a, α b)` for coprime moduli `a,b` — is now fully proved (was `sorry`). Proof: coprimality collapses `a·b ∣ F(k)` into `a ∣ F(k) ∧ b ∣ F(k)`, the characterization theorem turns each into an entry-point divisibility, and `Nat.dvd_antisymm` finishes. The surrounding docstrings/declaration list were updated from "conjecture/sorry" to "proved", with a Lab Notebook block added.

**2. New file** `Catalog/Speculative/AutoResearch/FibonacciEntryPointLcmLaw.lean` with 5 new theorems (all proved, `sorry = 0`), each with Lab Notebook blocks and proof-sketch comments:
- `fibEntryPt_dvd_index`: `m ∣ F(n)` with `n>0` forces `α m ∣ n` ("rank divides the index").
- `fibEntryPt_two` (`α 2 = 3`), `fibEntryPt_three` (`α 3 = 4`): base data.
- `fibEntryPt_six` (`α 6 = 12`): the lcm law `lcm 3 4 = 12` in action.
- `six_primitive_at_twelve`: the punchline — `6` is a primitive divisor of `F(12)`, contrasting the existing `fib_twelve_no_primitive` (no primitive *prime* divisor). This shows the `n=12` boundary of Carmichael's theorem is genuinely a prime-only obstruction.

**3. `FUTURE_DIRECTIONS.md`** with the required Synthesis, Results Summary, and 5 falsifiable Research Directions (each with Hypothesis / Test / Why now / If true / If false).

## Catalog synthesis
The work builds directly on existing catalog results (`fib_dvd_iff_entryPt_dvd`, `entryPt_eq_iff_primitive`, `fib_twelve_no_primitive`, and the `bridge_lemma`/entry-point lemmas in `Shared/CarmichaelProof.lean` and `CarmichaelComposite.lean`), connecting the multiplicative structure of entry points to the additive question of primitive divisors.

## Verification
All new/modified theorems compile cleanly via `lake build` and depend only on the standard axioms `[propext, Classical.choice, Quot.sound]`. A grep confirms no `sorry` remains in either touched file.

## Build fix
The project's `lakefile.toml` was missing `srcDir = "Catalog"`, so no library target could resolve (the sources live under `Catalog/` while the libs were rooted at the project root). I added `srcDir = "Catalog"`, which makes the in-project imports (e.g. `Shared.CarmichaelProof`, `Speculative.AutoResearch....`) and `lake build` work as intended.

## Not addressed (pre-existing, out of scope)
`fib_carmichael_composite` in `Shared/CarmichaelProof.lean` retains a pre-existing `sorry` for the infinite tail `n > 10000` — this is the full Carmichael primitive-divisor theorem for Fibonacci numbers, a genuinely deep result requiring substantial machinery, left untouched. The designated tractable research-target sorry (the lcm law) is the one that was closed.