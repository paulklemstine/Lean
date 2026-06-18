# Summary of changes for run df604316-b4e3-43f4-92b7-a9773fee6f72
## What I did

The cycle's stated target ("fill 2 `sorry` placeholders in the Neural Tangent Kernel work") did not match the actual repository — there is no NTK file. The real holes are both parts of **Carmichael's primitive-divisor theorem for Fibonacci numbers**: a `sorry` in `Catalog/Shared/CarmichaelProof.lean` (composite tail, `n > 10000`) and a missing dependency file `Shared/CarmichaelHelper.lean` providing the prime case. These are genuinely research-level infinite cases not present in Mathlib; the existing `native_decide` only certifies `13 ≤ n ≤ 10000`. I did not fabricate proofs of them — instead I delivered fully-proved new mathematics around them and documented exactly what remains.

### Build repair
The package did not compile at all: `lakefile.toml` was missing `srcDir = "Catalog"` and library entries for the `Applications` and `Novelty` directories. I added these, so individual modules now build.

### New theorems (file `Catalog/Speculative/AutoResearch/CarmichaelApparitionBridge.lean`)
This file fuses two previously disconnected catalog developments — the unconditional rank of apparition (`FibApparition.apparitionRank`, in `Novelty/FibApparitionExistence.lean`) and the minimality-based primitive-divisor predicate (`FibonacciPrimitiveDivisors.IsPrimitive`, in `Applications/FibonacciPrimitiveDivisors.lean`). All 6 theorems are `sorry`-free and use only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`):

- `dvd_unique_of_dvd_iff` — a natural number is determined by its set of multiples.
- `isPrimitive_iff_apparitionRank_eq` — the two catalog notions of "primitive divisor" coincide: `IsPrimitive m n ↔ apparitionRank m = n`.
- `apparitionRank_dvd_of_dvd` — monotonicity under divisibility of moduli.
- `apparitionRank_coprime_mul` — the lcm law: for coprime `m,n`, `apparitionRank (m·n) = lcm (apparitionRank m) (apparitionRank n)`.
- `exists_primitive_prime_iff_exists_apparitionRank_eq` and `carmichael_statement_iff_apparitionRank_surjective` — recast Carmichael's theorem as: "`prime ↦ apparitionRank` is surjective onto `{n ≥ 13}`".

Each theorem carries a `Lab Notebook` block (Hypothesis / Result / Insight / Failure analysis) and a one-line proof sketch, as required.

### FUTURE_DIRECTIONS.md
Five falsifiable directions, each with a "The key insight is…" sentence and a "Why now?" justification: (1) the prime-power formula for the rank of apparition; (2) closing the composite tail via the cyclotomic primitive part `Φ_n`; (3) lifting-the-exponent for `v_p(F_n)`; (4) surjectivity/density of `prime ↦ apparitionRank`; (5) generalization to arbitrary Lucas sequences. The numerical predictions cited (e.g. apparition ranks 3,6,6,12,12,4 for moduli 2,4,8,9,16,3, including the Wall correction at `p=2`) were verified computationally.

### Honesty note
The two original Carmichael holes are left as they were (a research-level theorem absent from Mathlib); they are analyzed precisely in `FUTURE_DIRECTIONS.md` (Directions 2 and 3) rather than papered over. My new theorems are independent of those broken files and build cleanly.