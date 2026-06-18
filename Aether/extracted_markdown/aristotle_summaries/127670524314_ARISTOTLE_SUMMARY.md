# Summary of changes for run 6e6b674d-eff3-4df1-9d97-e94cd7101225
## What I did

This cycle targeted the Fibonacci primitive-divisor (Carmichael) development in the catalog. I found that the development was actually **broken at the build level** — not merely `sorry`-laden — and repaired it, then added a new, fully-proven local-to-global theory.

### Build repairs
- **Restored the missing `Catalog/Shared/CarmichaelHelper.lean`** (imported by two files but absent, breaking the whole chain). It now contains a genuine, `sorry`-free proof of the prime-index case `fib_primitive_divisor_prime`: for prime index `n`, every prime factor of `F(n)` is primitive because `gcd n k` is a proper divisor of the prime `n`, hence `1`, and `F(1)=1`.
- **Fixed `Catalog/Speculative/AutoResearch/FibPrimitive.lean`**, whose module doc-comment was missing its opening `/-!` and whose `import`s were placed *after* the comment (illegal in Lean 4). Imports moved to the top.
- **Fixed the import in `Catalog/Speculative/CarmichaelPrimitiveDivisor.lean`** (it referenced a non-existent `Shared.CarmichaelComposite`; redirected to the module that actually defines `fib_carmichael`).

After these fixes the entire chain compiles.

### New theorems (new file `Catalog/Speculative/AutoResearch/FibonacciApparitionLattice.lean`)
A self-contained, Mathlib-only, `sorry`-free theory casting Carmichael's structural skeleton as a local-to-global (sheaf-flavored) phenomenon. Highlights:
- `fib_dvd_iff_appar_dvd` — the keystone: `p ∣ F(k) ↔ z(p) ∣ k`, i.e. the global divisibility locus is exactly the multiples of the local stalk (rank of apparition).
- `fib_appar_eq_iff_primitive` — primitivity at index `n` is exactly the stalk condition `z(p) = n`.
- `fib_prime_index_all_primitive` — strengthens the catalog existence result to "every prime factor is primitive" for prime indices.
- `fib_twelve_no_primitive` — the sharp `n = 12` obstruction (`F(12)=144=2⁴·3²`), the unique composite exception.
- plus `fibAppar_dvd_of_fib_dvd` and clean spec lemmas.

All six theorems were verified to depend only on `propext`, `Classical.choice`, `Quot.sound`.

### Deliverables
- Two authored `.lean` files, each with `-- !-- Lab Notebook -- !--` blocks (Hypothesis / Result / Insight / Failure analysis) and `-- !-- ... -- !--` proof-sketch comments.
- `FUTURE_DIRECTIONS.md` with a synthesis, a results summary, and 5 falsifiable research directions (each with a "The key insight is…" sentence and a "Why now?" justification), centered on closing the remaining analytic gap and generalizing the local-to-global theorem.

### Remaining open item
One `sorry` remains in `Catalog/Shared/CarmichaelProof.lean` (`fib_carmichael_composite`): the analytic large-`n` composite case (`n > 10000`). This is the genuinely deep part — it needs a formal Fibonacci Lifting-the-Exponent lemma plus a golden-ratio growth lower bound on the cyclotomic Fibonacci factor. The work this cycle shows this metric estimate is the *only* missing ingredient; everything structural around it is now exact and axiom-clean. It is laid out as the lead conjecture in `FUTURE_DIRECTIONS.md`. I deliberately did not scaffold it, since doing so would have introduced many new unproven lemmas rather than eliminating the existing one.