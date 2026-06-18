# Summary of changes for run 8c5268a4-8865-4d9d-81dd-53c2686deda5
## What was delivered

I created a new, fully self-contained and `sorry`-free Lean development of the **rank of apparition (Fibonacci entry point)** theory, which is the conceptual engine behind the project's Carmichael primitive-divisor targets.

**New file:** `Catalog/Speculative/AutoResearch/FibonacciApparition.lean` (imports only Mathlib; verified to compile with no errors or warnings; no `sorry`).

It defines `fibEntry m` = the least `k > 0` with `m ∣ F k`, and proves:

1. **`exists_pos_dvd_fib`** — every modulus `m > 0` divides some positive Fibonacci number (well-definedness of the rank of apparition), proved from scratch via periodicity of the Fibonacci pair-sequence modulo `m` (helper lemmas `fibPair_back`, `fibPair_descent` establishing backward determinism and descent to the origin, plus a pigeonhole argument).
2. **`fib_dvd_iff_fibEntry_dvd`** — the *law of apparition*: `m ∣ F k ↔ fibEntry m ∣ k`, the divisibility backbone of the whole theory.
3. **`prime_primitive_divisor_iff`** — a prime `p` is a *primitive prime divisor* of `F n` exactly when `fibEntry p = n`, recasting Carmichael's theorem as a statement about the entry-point function.
4. Supporting lemmas (`fibEntry_pos`, `fibEntry_dvd_fib`, `fibEntry_le`, `fibEntry_min`) and a corollary `primitive_divisor_unique_index` (distinct indices have disjoint primitive divisors), plus the classical gcd identity `fib_gcd_eq`.

Each key theorem carries a one–two sentence `-- !-- ... -- !--` proof sketch as required.

**`FUTURE_DIRECTIONS.md`** — five falsifiable research conjectures extending the work, each with a "The key insight is..." sentence and a "Why now?" justification. These cover: closing the infinite tail of `fib_carmichael_composite` (currently the project's open `sorry`) uniformly via the primitive-part bound; the apparition divisibility `fibEntry p ∣ p − (5/p)`; the Wall–Sun–Sun conjecture `fibEntry(p²) = p·fibEntry p` (now expressible as a precise Lean predicate); generalisation to arbitrary strong-divisibility / Lucas sequences; and a "proof phase transition" framing as the cofinite density of realised ranks.

## Note on the existing catalog
The pre-existing Carmichael files (`Catalog/Shared/CarmichaelProof.lean` and `Catalog/Speculative/.../CarmichaelComposite.lean`) reference a `Shared.CarmichaelHelper` module and a `fib_primitive_divisor_prime` lemma that do not exist in the repository, and the lakefile's source paths do not match the on-disk `Catalog/` layout, so those files do not currently build. Rather than patch that broken, undefined dependency chain, I delivered a clean, independently verifiable file that captures and proves the mathematical core (the law of apparition and the primitive-divisor characterisation) those files were aiming at, and Direction 1 in FUTURE_DIRECTIONS.md explains how this reduces the remaining composite-tail `sorry` to a single growth inequality.