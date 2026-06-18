# Summary of changes for run 6fc2fcbc-0638-4048-8955-85aecb9282bb
## Close Proofs — Fibonacci Primitive Divisors (Carmichael)

I focused on the project's genuine open `sorry` situation in the Fibonacci primitive-divisor / Carmichael program, repaired the (non-building) subsystem, and added new fully-proved theorems plus a research roadmap.

### Build repairs (the Carmichael chain did not compile on arrival)
- `lakefile.toml`: added the missing `srcDir = "Catalog"` (without it nothing built — Lake looked for `Algebra/…` at the repo root).
- `Catalog/Speculative/CarmichaelPrimitiveDivisor.lean`: fixed a wrong import path (`Shared.CarmichaelComposite` → `Speculative.AutoResearch.CarmichaelComposite`).
- Created the missing `Catalog/Shared/CarmichaelHelper.lean` that several files imported but which did not exist.

### New, fully-proved theorems (`sorry = 0`; axioms limited to `propext`/`Classical.choice`/`Quot.sound`, plus `Lean.ofReduceBool` for the certified band)
- `Catalog/Shared/CarmichaelHelper.lean` — `fib_primitive_divisor_prime`: Carmichael's theorem for **prime indices** (the previously-missing helper), via a clean rank-of-apparition / `Nat.fib_gcd` argument.
- `Catalog/Speculative/CarmichaelSynthesis.lean` — a cross-file synthesis of the prime branch, the `native_decide` composite certificate, and the entry-point (LTE) theory:
  - `fib_all_prime_factors_primitive` — for prime `p ≥ 3`, *every* prime factor of `F p` is primitive (strictly stronger than existence);
  - `fib_carmichael_certified_band` — Carmichael on the certified band `13 ≤ n ≤ 10000`, glued from the two `sorry`-free leaves so it does **not** import the open tail;
  - `fib_prime_entryPoint_eq` — the entry point of any prime factor of `F p` equals `p`;
  - `fib_primitive_primes_injective_on_primes` — distinct prime indices give distinct least primitive primes (infinitude corollary).

Each file carries `-- !-- Lab Notebook -- !--` blocks (Hypothesis / Result / Insight / Failure) and `-- !-- … -- !--` proof sketches, and I verified axiom-cleanliness with `#print axioms` on every new result.

### Remaining open `sorry` (documented, not hidden)
One genuine `sorry` remains: `fib_carmichael_composite` for the infinite **composite tail** `n > 10000` in `Catalog/Shared/CarmichaelProof.lean`. This is the deep half of Carmichael's 1913 theorem and needs the cyclotomic primitive-part `Φ_n` machinery, which is not yet assembled. `FUTURE_DIRECTIONS.md` gives a concrete attack plan that reuses the project's already-proved Fibonacci Lifting-the-Exponent lemma and the `z(p) ∣ p²−1` result, plus three further falsifiable directions (removing the `10000` cutoff, quantitative `ω(Φ_n)` lower bounds, and abstracting the method to Lucas/Lehmer sequences).

All touched modules build successfully (`lake build` over the six relevant modules completes with no errors), and the new files contain no real `sorry`.