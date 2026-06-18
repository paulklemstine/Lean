# Summary of changes for run 81ec8cb9-a0da-4dfc-88d8-93396e7935be
## Completed: Non-Archimedean Factoring Oracle

### Key Finding: Original Statement is FALSE

The original theorem claimed that **every** `n > 1` can be decomposed as `a * b = n` with `a > 1` and `b > 1`. This is false — prime numbers (e.g., 2, 3, 5, 7) are immediate counterexamples.

### Corrected and Proved Theorem

In `Main.lean`, I:
1. **Commented out** the original false statement with an explanation of why it fails.
2. **Added a corrected version** with the additional hypothesis `¬ Nat.Prime n` (i.e., `n` is composite).
3. **Proved the corrected theorem** using Mathlib's `Nat.exists_dvd_of_not_prime2`, which extracts a non-trivial divisor `k` (with `1 < k < n`) from any composite number. The factors `a = k` and `b = n/k` satisfy all required properties.

The proof uses only standard axioms (`propext`, `Classical.choice`, `Quot.sound`) — no `sorry` remains.

### Deliverables

| File | Description |
|------|-------------|
| `Main.lean` | Formal Lean 4 proof with corrected theorem statement |
| `RESEARCH_REPORT.md` | Academic-style report: abstract, motivation, proof overview, open problems, references |
| `demo.py` | Self-contained Python demo testing the oracle on composites 4–50, demonstrating primes as counterexamples, and illustrating p-adic valuation additivity (with optional matplotlib visualization) |
| `diagram.svg` | SVG diagram showing the proof structure: composite vs. prime classification, and the three-step proof flow (hypotheses → divisor extraction → factor construction) |
| `DISCUSSION.md` | Scientific American-style article (~1200 words) explaining the theorem accessibly |

### Proof Strategy

The proof is elegant and minimal: since `n > 1` and `n` is not prime, Mathlib provides a divisor `k` with `k ∣ n`, `k ≠ 1`, and `k ≠ n`. Setting `a = k` and `b = n/k` gives `a * b = n` (by `Nat.div_mul_cancel`), with both factors exceeding 1 (verified by `nlinarith`). The entire proof is three lines of tactic-mode Lean.