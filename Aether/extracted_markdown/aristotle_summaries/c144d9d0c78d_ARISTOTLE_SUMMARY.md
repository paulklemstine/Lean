# Summary of changes for run 8e252012-d224-4c4c-aa31-8401168ef489
## What I did

I ran one research cycle on the Fibonacci primitive-divisor / "rank of apparition" ecosystem, extending the existing catalog entry-point theory (`Catalog/Applications/FibonacciEntryPoints.lean`, `Catalog/Shared/CarmichaelProof.lean`) with the previously-missing **multiplicative structure** of the rank of apparition.

### New file (verified compiling, `sorry`-free, only standard axioms `propext`/`Classical.choice`/`Quot.sound`)
`Catalog/Applications/FibonacciApparitionMultiplicativity.lean` proves:

- **`entryPoint_mul_coprime`** (main result): for coprime `p, q`, the Fibonacci rank of apparition is lcm-multiplicative — `entryPoint (p*q) = lcm (entryPoint p) (entryPoint q)`.
- **`entryPoint_dvd_of_dvd`**: monotonicity — `p ∣ q ⇒ entryPoint p ∣ entryPoint q` (divisibility of moduli becomes divisibility of indices).
- **`entryPoint_eq_of_iff`** and **`entryPoint_eq`**: uniqueness of the entry point from its divisibility footprint / from a primitive index.
- **`entryPoint_mul_not_lcm_noncoprime`** (Critic's disproof): a sharp counterexample showing coprimality is necessary — `entryPoint 4 = 6 ≠ 3 = lcm(entryPoint 2, entryPoint 2)`, a 2-adic "rank jump."
- Supporting `entryPoint_two`, `entryPoint_four`, and re-derived basics (`dvd_fib_iff_entry_dvd`, etc.), since this catalog's cross-file imports are not resolvable in its build configuration.

Each major theorem carries a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis) doubling as its proof sketch, as required.

### Notes / future work
`FUTURE_DIRECTIONS.md` contains the required `## Synthesis`, `## Results Summary`, and five falsifiable `## Research Directions` (each with a "key insight" and "why now"): the prime-power rank jump (LTE wall), a closed lcm-over-prime-powers formula for `entryPoint`, closing the open Carmichael composite tail, the fiber structure of `entryPoint` (Zsygmondy-style), and transplanting the theory to general Lucas / strong-divisibility sequences.

### On the original `sorry`
The one remaining priority `sorry` (`fib_carmichael_composite` in `Catalog/Shared/CarmichaelProof.lean`, the composite case for `n > 10000`) is the genuine infinite-tail content of Carmichael's 1913 primitive-divisor theorem, which is beyond a single cycle to discharge from scratch. I left it untouched and documented a concrete attack plan for it as Research Direction 3, reframed via the entry-point machinery proved this cycle (a primitive divisor of `F_n` is exactly a prime whose rank of apparition equals `n`). The other named priority target, `fib_gcd_identity`, was already proved in the catalog (no sorry).