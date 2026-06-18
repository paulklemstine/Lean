# Summary of changes for run 88976e77-7b1b-4e0f-b72b-124c1762e691
## Cycle deliverable: Fractal Fibonacci — the entry-point map as a self-similar arithmetic invariant

I produced one new, self-contained Lean file plus a research-notes file, building on (and generalizing) the catalog's Fibonacci/Carmichael machinery.

### New Lean file: `Novelty/FractalFibonacci.lean`
A complete, from-scratch development of the **entry-point (rank-of-apparition) theory** of the Fibonacci numbers, organized around the self-similarity identity `fib (gcd m n) = gcd (fib m, fib n)`. It compiles cleanly (no `sorry`, no extra axioms beyond `propext`/`Classical.choice`/`Quot.sound`, no linter warnings). Every theorem has a verified proof. Highlights:

- `fib_dvd_gcd` — self-similarity at a fixed modulus.
- `entryPoint` (definition) + `entryPoint_spec` — the rank-of-apparition invariant and its minimality.
- `entryPoint_dvd` — **the entry point divides every index of appearance** (needs no primality).
- `entryPoint_eq_of_primitive` / `isPrimitive_of_entryPoint_eq` — a prime is a *primitive (Carmichael) divisor* of `fib n` iff its entry point is exactly `n`.
- `primitive_divisor_inj` — **main theorem ("fractal injectivity"): a fixed prime is a primitive divisor of at most one Fibonacci number**, with corollary `primitive_divisor_distinct`.
- `fibPair_backward`, `fibPair_collision_to_zero`, `every_prime_dvd_fib` — a self-contained proof that **every prime divides some Fibonacci number**, via pigeonhole on the finite pair-map mod `p` plus reversibility of the recurrence (avoiding the catalog's heavy `native_decide`).
- `infinite_fib_divisor_primes` — infinitely many primes divide Fibonacci numbers.

The file includes the required `-- !-- ... -- !--` proof-sketch blocks and Lab Notebook blocks (Hypothesis / Result / Insight / Failure analysis) for each major theorem, and a docstring explaining how this extends the catalog's `CarmichaelComposite` / `Fib_gcd_identity` scaffolding by promoting the entry point to a first-class invariant.

### `FUTURE_DIRECTIONS.md`
Contains the required `## Synthesis` and `## Results Summary` sections plus five falsifiable research directions (entry point of prime powers / lifting-the-exponent; multiplicativity on coprime moduli; a Mathlib-native Pisano period bound; abstraction to general Lucas/strong-divisibility sequences; density/growth of the primitive-divisor index set). Each direction states a precise hypothesis, a test, a "key insight," a "Why now," and the consequences of truth/falsity.

### Build note
I registered the new file as a `Novelty` library in `lakefile.toml` so it is discoverable by the build; the module `Novelty.FractalFibonacci` builds successfully.