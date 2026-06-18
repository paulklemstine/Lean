# Summary of changes for run e1629d4a-89e6-47dd-b3bb-380438c0e878
## What I did

I worked on the Catalog's Fibonacci / Carmichael primitive-divisor strand, whose goal was to close the remaining `sorry` in the Carmichael composite-case development. Along the way I discovered (and fixed) that the project did not build at all, then reused and extended the existing catalog rather than reproving it.

### Build repairs (the project was unbuildable as given)
- `lakefile.toml`: added `srcDir = "Catalog"` — without it every module path (e.g. `Shared.CarmichaelProof`) resolved to a non-existent file, so `lake build` built nothing.
- `lakefile.toml`: declared the missing `Applications` library (many files `import Applications.X`, but no such lib existed). It is intentionally left out of `defaultTargets` because parts of that tree have pre-existing breakage unrelated to this task (e.g. `Applications/HypergraphRamsey/Defs.lean` is missing); the needed module `Applications.RankOfApparition` builds cleanly and is pulled in transitively.
- `Speculative/AutoResearch/FibPrimitive.lean`: restored the opening `/-` of its module docstring (the file began with a bare `#` heading and could never compile).

### Supplied the missing helper file
- `Shared/CarmichaelHelper.lean` was imported by `CarmichaelComposite.lean` and `FibPrimitive.lean` but did not exist, breaking both. I created it and, instead of duplicating existing work, re-exported the catalog's prime-case theorem (`Applications.RankOfApparition.fib_prime_index_has_primitive`) as `fib_primitive_divisor_prime`. Sorry-free.

### New sorry-free theorems
- `Speculative/AutoResearch/FibPrimitiveExceptions.lean` — `fib_no_primitive_of_exception`: the *complete* sharpness side of Carmichael's theorem, ruling out a primitive prime divisor for the entire classical exception set {1, 2, 6, 12} (the catalog previously had only n = 12).
- `Speculative/AutoResearch/FibCarmichaelVerified.lean` — `fib_primitive_on_verified_range`: a cross-file synthesis proving unconditional existence of a primitive prime divisor for every n in [13, 50000], by gluing the rank-theoretic prime case to the `native_decide` GCD-residual certificate for composites. Sorry-free (verified it does not transitively use the open `sorry`).

All three files carry Lab Notebook (`-- !-- Lab Notebook -- !--`) and proof-sketch (`-- !-- comment -- !--`) blocks, and all headline theorems were checked to use only standard axioms.

### FUTURE_DIRECTIONS.md
Added with five falsifiable directions (each with a "The key insight is…" and a "Why now?"), centered on a staged program to close the one remaining open case: formalize the Möbius primitive part Φ_n and F_n = ∏ Φ_d, prove the Fibonacci lifting-the-exponent identity, and combine them with the golden-ratio growth bound Φ_n > n; plus generalizations to Lucas/Lehmer sequences and a localization/quotient reframing of the rank spine.

### Honest status of the target `sorry`
The one remaining `sorry` (in `Shared/CarmichaelProof.lean`, the `fib_carmichael_composite` branch for composite n > 10000) is the genuine asymptotic case — essentially Zsygmondy's theorem for the Fibonacci sequence, which is not in Mathlib and requires building the primitive-part / LTE / growth-bound infrastructure described in FUTURE_DIRECTIONS. It was not closable in this cycle without that infrastructure, so it is left in place and documented rather than faked. Everything I added is sorry-free, and the previously-unbuildable Carmichael files now compile.
