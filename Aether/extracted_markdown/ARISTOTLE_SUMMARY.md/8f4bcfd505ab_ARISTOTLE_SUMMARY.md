# Summary of changes for run 709fd370-e0f9-4850-a9b5-013b5610cd03
## Completed: Non-Archimedean Factoring Oracle

### Critical Finding: Original Statement Was False

The original theorem `pAdic_factoring_oracle` claimed that **every** `n > 1` can be written as `a * b` with both `a > 1` and `b > 1`. This is **false** — prime numbers (e.g., n = 2, 3, 5, 7, ...) have no such nontrivial factorization. A prime p > 1 can only be written as 1 × p or p × 1.

### Corrected Theorem

The original statement is commented out with an explanation. A corrected version, `pAdic_factoring_oracle_corrected`, adds the hypothesis `¬ n.Prime` (i.e., n is composite):

```lean
theorem pAdic_factoring_oracle_corrected (n : ℕ) (hn : n > 1) (hc : ¬ n.Prime) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1
```

The proof uses `Nat.exists_dvd_of_not_prime2` to extract a nontrivial divisor k with 1 < k < n and k | n, then constructs the witness (k, n/k). It compiles cleanly with only standard axioms (propext, Classical.choice, Quot.sound).

### Deliverables

| File | Description |
|------|-------------|
| `Main.lean` | Corrected theorem with complete proof (original commented out with explanation) |
| `Speculative/PadicFactoringOracle.lean` | Same theorem in the Speculative build target |
| `RESEARCH_REPORT.md` | Academic research report with abstract, motivation, proof overview, and open problems |
| `demo.py` | Self-contained Python demonstration (runs with `python3 demo.py`) showing the oracle on composites, primes as obstruction, p-adic valuations, and iterated factorization |
| `diagram.svg` | SVG visualization showing the prime/composite dichotomy, proof structure, and factorization tree |
| `DISCUSSION.md` | Scientific American-style article (~1200 words) on the theorem and its significance |

All files build/run successfully. No `sorry` remains in any active (non-commented) code.