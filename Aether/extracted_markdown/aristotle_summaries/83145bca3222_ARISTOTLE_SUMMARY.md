# Summary of changes for run 2c1c9bd9-2c37-4f02-8390-15dbfd6a742f
## Summary

### Theorem Analysis: The Original Statement is False

The proposed theorem `pAdic_factoring_oracle` claimed that **every** natural number n > 1 can be written as a product a × b with both a > 1 and b > 1. This is **false** — prime numbers are immediate counterexamples. For example, if n = 3 and both factors are ≥ 2, then a × b ≥ 4 > 3, a contradiction.

### What Was Delivered

**`Main.lean`** — Contains three formally verified results:
1. **The original false theorem** is commented out with an explanation of why it fails.
2. **`pAdic_factoring_oracle_counterexample`** — A machine-verified proof that the original statement is false (using n = 3 as counterexample).
3. **`pAdic_factoring_oracle_corrected`** — A corrected theorem adding the hypothesis `¬ Nat.Prime n`, proving that every **composite** number n > 1 admits a non-trivial factorization. The proof uses `Nat.exists_dvd_of_not_prime2` from Mathlib to extract the minimal factor.

All proofs compile without `sorry` and use only standard axioms.

**`RESEARCH_REPORT.md`** — Formal research report with abstract, motivation, mathematical framework, proof overview, novelty analysis, open problems, and references.

**`demo.py`** — Self-contained Python script demonstrating the counterexample (primes can't be factored) and the corrected theorem (composites can). Runs with `python3 demo.py`.

**`diagram.svg`** — SVG visualization showing the prime/composite dichotomy and the proof structure, renderable in any modern browser.

**`DISCUSSION.md`** — Scientific American-style article (~1200 words) explaining the theorem, its significance, and the role of formal verification in catching mathematical errors.