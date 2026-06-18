# Theorem Trace (internal anti-hallucination record)

Every result below is taken **verbatim from the Phase A Lean output**. No theorem
is invented; no name is paraphrased into a grander claim. Statements quoted are the
ones that actually appear in the Lean source. Theorems whose full statement is only
described in the module docstring (the Garden-of-Eden file is truncated in the Phase A
output) are marked **[docstring]** and are described, not over-claimed.

## File: Catalog/Bridges/FibonacciDivisibilityPigeonhole.lean

| Lean name | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|
| `fib_dvd_of_dvd` | If `m ∣ n` then `fib m ∣ fib n`. | §"A lattice hidden in the Fibonacci numbers" | Thm 1 |
| `fib_dvd_iff` | For `3 ≤ m`: `fib m ∣ fib n ↔ m ∣ n`. | §"A lattice hidden in the Fibonacci numbers" | Thm 2 |
| `oddPart` (def) | `oddPart x = x / 2 ^ (x.factorization 2)` — divide out all factors of 2. | §"The pigeonhole with teeth" | Def 3 |
| `divisibility_pigeonhole` | Any `S ⊆ [1,2n]` with `|S| = n+1` contains `a ≠ b` in `S` with `a ∣ b`. | §"The pigeonhole with teeth" | Thm 4 |

## File: Catalog/Bridges/GardenOfEden.lean

| Lean name | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|
| `IsGardenOfEden` (def) | `IsGardenOfEden F y := ∀ x, F x ≠ y` — a state with no preimage. | §"Gardens of Eden" | Def 5 |
| `exists_garden_of_eden_iff_not_surjective` | `(∃ y, IsGardenOfEden F y) ↔ ¬ Surjective F`. | §"Gardens of Eden" | Thm 6 |
| `iterate_descends` | If `∀ x, F x ≤ x` then `∀ n x, F^[n+1] x ≤ F^[n] x`. | §"Gardens of Eden" | Lem 7 |
| `finite_garden_of_eden_descent` | `F` monotone with `∀ x, F x ≤ x` on a finite poset `P`: every `x` has `n ≤ card P` with `F^[n] x = F^[n+1] x`. | §"Gardens of Eden" | Thm 8 |
| `finite_garden_of_eden_of_not_surjective` **[docstring]** | A non-surjective monotone descending map has a Garden-of-Eden state outside the eventual image. | §"Gardens of Eden" | Thm 9 |
| `finite_configuration_garden_of_eden` **[docstring]** | On finite configuration spaces, non-surjective maps have unreachable configurations. | §"Gardens of Eden" | Thm 10 |
| `preinjective_of_surjective_on_finite_configurations` **[docstring]** | Finite Moore–Myhill shadow: surjectivity implies injectivity on finite types. | §"Gardens of Eden" | Thm 11 |

## Notes
- `fib_dvd_of_dvd` is a thin wrapper over Mathlib's `Nat.fib_dvd`.
- The proof of `fib_dvd_iff` uses the gcd identity `gcd(fib m, fib n) = fib(gcd m n)`.
- `divisibility_pigeonhole`'s hypothesis `hn : n ≥ 1` is retained from the request but
  is not used in the proof (noted in the Lean docstring); the paper mentions this.
- The pigeonhole proof keys each integer by its odd part and uses that there are exactly
  `n` odd numbers in `[1, 2n]`.
