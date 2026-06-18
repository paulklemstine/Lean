# Summary of changes for run 712be1a9-fbb6-49ae-8a84-c76fcad6093d
## What I did

The target was the lone open `sorry` in the Carmichael / Fibonacci primitive-divisor work. In the process I found the component did not even build: both `Catalog/Shared/CarmichaelProof.lean` and `Catalog/Speculative/AutoResearch/CarmichaelComposite.lean` imported a `Shared.CarmichaelHelper` module that was missing from the project, so nothing elaborated.

### Build repair + new sorry-free theorems
1. **`Catalog/Shared/CarmichaelHelper.lean`** (new) — rebuilt the missing module and proved its export `fib_primitive_divisor_prime`: for prime `n ≥ 13`, every prime factor of `F(n)` is automatically a primitive prime divisor (rank-of-apparition argument via `Nat.fib_gcd`). Sorry-free; axioms are only `propext`, `Classical.choice`, `Quot.sound`. This restores elaboration of `CarmichaelComposite.lean`.
2. Removed the unused, broken `import Shared.CarmichaelHelper` from `CarmichaelProof.lean`.
3. **`Catalog/Speculative/AutoResearch/FibPrimitiveExceptions.lean`** (new) — proved the dual/sharpness side that the catalog lacked: the four Carmichael exceptions `fib_no_primitive_one/two/six/twelve`, and the unifying biconditional `carmichael_small_characterization`: for `1 ≤ n ≤ 12`, `F(n)` has no primitive prime divisor **iff** `n ∈ {1,2,6,12}`. All sorry-free and axiom-clean. This complements the catalog's existing apparition/entry-point duality (`dvd_fib_iff_entry_dvd`, `entryPt_eq_iff_primitive`, etc.) without duplicating it.

Each `.lean` file carries a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis) and `-- !-- comment -- !--` proof sketches.

### The remaining `sorry`
One `sorry` remains, in `CarmichaelProof.lean`: the infinite tail `n > 10000` of the composite case. This is the genuine analytic core of Carmichael's primitive-divisor theorem (not currently supported by Mathlib): it needs the homogeneous cyclotomic factorization `F(n)=∏Φ_d`, Carmichael's law of repetition (a Fibonacci lifting-the-exponent statement), and a Binet size bound `Φ_n>n`. A monolithic search did not close it, and building that theory was out of scope for this cycle. Rather than leave a bare `sorry` or add new unprovable scaffolding, I documented it fully in the file's lab notebook and made it the leading program in the future-directions file. The finite range `13 ≤ n ≤ 10000` remains fully proved via the verified computation already present.

### FUTURE_DIRECTIONS
`Catalog/Speculative/AutoResearch/FUTURE_DIRECTIONS.md` — narrative synthesis, results summary, and five falsifiable directions (cyclotomic-Fibonacci factorization; Fibonacci LTE / law of repetition; Binet size bound to remove the `10000` ceiling; generalization to all Lucas sequences; a Stone-type duality between indices and primitive-prime fibers), each with a "key insight" and "Why now?".

Net effect: the Carmichael component now elaborates (it previously did not), with six new sorry-free, axiom-clean theorems added, and the single deep tail isolated and documented.