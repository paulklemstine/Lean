# Summary of changes for run a3c57118-1982-4848-98cd-2369dd44701b
## What I did

I investigated the project's open `sorry` placeholders in the Carmichael/Fibonacci ("Pythagorean") cluster, fixed the build, contributed a new self-contained theory file with fully verified theorems, and wrote the required research notes.

### Build repairs (necessary to make anything in the catalog compile)
- The package build config did not point at the `Catalog/` source root, so no catalog module resolved. Added `srcDir = "Catalog"` to `lakefile.toml`.
- `Catalog/Shared/CarmichaelProof.lean` imported a file that does not exist in the project (`Shared.CarmichaelHelper`), making it impossible to build. That import was dead (nothing from it was used), so I removed it; the file now compiles.

### New deliverable: `Catalog/Pythagorean/FibonacciEntryPoint.lean`
A new, `import Mathlib`-only file developing the theory of the **Fibonacci entry point** `z(p)` (rank of apparition). It builds cleanly with **zero `sorry`** and only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`). Main results:
- `exists_pos_dvd_fib` — every `p > 0` divides some positive-index Fibonacci number (pigeonhole in `ZMod p` run backwards through the recurrence).
- `dvd_fib_iff_entryPt_dvd` — `p ∣ F k ↔ z(p) ∣ k` (the index set killed by `p` is exactly the multiples of `z(p)`).
- `primitive_iff_entryPt_eq` — `p` is a primitive divisor of `F n` iff `z(p) = n`.
- plus `entryPt_dvd_of_dvd_fib`, `entryPt_le_of_pos`, and structural lemmas.

This directly extends the existing catalog results `bridge_lemma` (in `Catalog/Shared/CarmichaelProof.lean`) and `fib_primitive_iff_divisors` / `prime_dvd_fib_gcd` (in `Catalog/Speculative/AutoResearch/FibPrimitive.lean`), upgrading their proper-divisor *reduction* into an exact `↔` characterization via the entry-point invariant. The file contains the requested Lab Notebook block and per-theorem proof-sketch comment blocks.

### `FUTURE_DIRECTIONS.md`
Five falsifiable research directions (each with a "The key insight is…" sentence and a "Why now?" justification), including the concrete route to closing the remaining gap.

### Honest status of the one remaining `sorry`
The project's only genuine code `sorry` is the **infinite tail** of Carmichael's primitive-divisor theorem in `Catalog/Shared/CarmichaelProof.lean` (`fib_carmichael_composite`, the case composite `n > 10000`). The finite range is handled by `native_decide`; the tail is a research-level theorem (Carmichael 1913 / Bilu–Hanrot–Voutier 2001) requiring a Fibonacci Lifting-the-Exponent lemma and a primitive-part growth bound not present in Mathlib. I attempted it but did not find a sound proof, so I left it as `sorry` rather than introduce an unsound or vacuous proof. The new entry-point file reformulates this exact gap as "some prime has `z(p) = n`", and `FUTURE_DIRECTIONS.md` lays out the LTE + primitive-part-bound strategy to close it in a future cycle.

All new/edited Lean compiles; the new theorems were verified `sorry`-free with clean axioms.