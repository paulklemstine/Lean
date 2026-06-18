# Summary of changes for run d34880fa-6314-4f3a-a4e8-b4045c696993
Added a new self-contained Lean development on **Fibonacci entry points (rank of apparition) and primitive prime divisors**, directly extending the catalog's Carmichael primitive-divisor work.

**New file:** `Catalog/Speculative/AutoResearch/FibonacciEntryPoints.lean` — builds cleanly (Mathlib-only) with **zero `sorry`**, using only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`). It proves:

- `fib_dvd_gcd` — the gcd–Fibonacci bridge: `p ∣ F_m → p ∣ F_n → p ∣ F_{gcd(m,n)}`.
- `entryPoint_pos`, `dvd_fib_entryPoint`, `entryPoint_min` — the existence/minimality package for the entry point `α(p) = least k>0 with p ∣ F_k`.
- `dvd_fib_iff_entry_dvd` — the characterization `p ∣ F_n ↔ α(p) ∣ n`.
- `primitive_iff_entry_eq` — `p` is a primitive prime divisor of `F_n` (divides `F_n` but no earlier Fibonacci) **iff** `α(p) = n`.
- `fib_twelve_no_primitive` — the classical exception: `F_12 = 144` has no primitive prime divisor.
- a worked `example` verifying `α(13) = 7`.

Each theorem carries a 1–2 sentence proof sketch as a comment.

**`Catalog/Speculative/AutoResearch/FUTURE_DIRECTIONS.md`** — five falsifiable research conjectures extending the work (entry point vs. Pisano period; the law of apparition via quadratic reciprocity; completing the Fibonacci-exception list; the Wall–Sun–Sun characterization; and a Lucas-sequence generalization via a strong-divisibility typeclass), each with a "key insight" and "Why now?" justification.

**Build fix:** the project's `lakefile.toml` was missing `srcDir = "Catalog"`, so no library file could resolve (the lib globs point at top-level names while the sources live under `Catalog/`). I added that line, which lets the libraries build. (Note: several pre-existing catalog files reference a missing module `Shared/CarmichaelHelper.lean`, which is unrelated to and outside the scope of this new development; the new file depends only on Mathlib and is unaffected.)