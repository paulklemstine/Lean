# Summary of changes for run 2746b10b-a931-4b50-97dc-43666af813e5
## Completed: Non-Archimedean Factoring Oracle

### Key Finding: The Original Statement is False

The proposed theorem claimed that **every** integer n > 1 can be written as a product a × b with both a > 1 and b > 1. This is false — prime numbers are counterexamples (e.g., n = 2 cannot be so factored, since any product of two numbers ≥ 2 is at least 4).

### What Was Delivered

**Lean Proof** (`Computation/Factoring/NonArchimedeanOracle.lean`):
- The original false statement is preserved in a block comment with an explanation of why it's false.
- **`pAdic_factoring_oracle_corrected`**: A corrected theorem proving that every *composite* n > 1 admits a non-trivial factorization. The proof uses `Nat.exists_dvd_of_not_prime2` from Mathlib to extract a divisor k with 1 < k < n, then constructs the pair (k, n/k).
- **`pAdic_factoring_oracle_counterexample`**: A formal proof that n = 2 is a counterexample to the original statement (if a, b ≥ 2 then a × b ≥ 4 > 2).
- Both proofs compile cleanly with no sorries and only standard axioms (propext, Classical.choice, Quot.sound).

**Supporting Files:**
- `RESEARCH_REPORT.md` — Academic research report with abstract, motivation, proof overview, novelty analysis, open problems, and references.
- `demo.py` — Self-contained Python script that numerically verifies the theorem on composites up to 50 and demonstrates prime counterexamples. Runs with `python3 demo.py`.
- `diagram.svg` — SVG visualization showing the number line partitioned into primes (red, counterexamples) and composites (green, theorem applies), with the proof flow diagram.
- `DISCUSSION.md` — Scientific American-style article (~1200 words) explaining the theorem accessibly.