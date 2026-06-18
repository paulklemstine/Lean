# Summary of changes for run a39db6a7-374d-41b7-a503-c7e8ae47c918
## Summary

### Theorem Analysis & Correction

The original theorem `pAdic_factoring_oracle` claimed that **every** n > 1 can be written as a product a × b with both a > 1 and b > 1. This statement is **false** — it fails for all prime numbers (e.g., 2, 3, 5, 7, ...), which by definition have no non-trivial factorization.

The original statement has been **commented out** with a clear explanation of why it is false, and a **corrected version** `pAdic_factoring_oracle_corrected` has been stated and formally proved. The corrected version adds the hypothesis `¬ Nat.Prime n` (i.e., n is composite), making the statement true and provable.

### Formal Proof

The corrected theorem is proved in `Computation/Factoring/NonArchimedeanOracle.lean` using Mathlib's `Nat.exists_dvd_of_not_prime2`, which provides a non-trivial divisor d of any composite number. The factorization n = d × (n/d) with both factors > 1 follows by arithmetic. The proof compiles cleanly with no `sorry` statements and uses only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

### Deliverables

All requested files have been created:

1. **`Computation/Factoring/NonArchimedeanOracle.lean`** — The formal Lean 4 proof with the original false statement commented out and the corrected version proved.
2. **`Main.lean`** — Updated to import the proof file.
3. **`RESEARCH_REPORT.md`** — Academic research report with abstract, motivation, mathematical framework, proof overview, novelty analysis, open problems, and references.
4. **`demo.py`** — Self-contained Python script demonstrating the theorem numerically, showing factorizations of composite numbers and confirming primes have no non-trivial factorization. Runs with `python3 demo.py`.
5. **`diagram.svg`** — SVG visualization of the proof structure, showing the decision flow between prime (unfactorable) and composite (factorable) numbers.
6. **`DISCUSSION.md`** — Scientific American-style article (~1200 words) explaining the theorem accessibly, with connections to cryptography, formal verification, and p-adic mathematics.