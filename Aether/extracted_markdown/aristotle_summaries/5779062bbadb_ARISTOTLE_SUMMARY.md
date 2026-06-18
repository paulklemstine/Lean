# Summary of changes for run ed01277c-2cba-455b-b863-c8e33200945c
## Completed: Non-Archimedean Factoring Oracle

### Key Finding: Original Statement is False

The original theorem claimed that **every** n > 1 admits a non-trivial factorization (∃ a b > 1, a·b = n). This is false — prime numbers are counterexamples. For example, 7 can only be written as 1 × 7, so no factorization with both factors > 1 exists.

### Corrected & Proven Theorem

The corrected version adds the hypothesis `¬ Nat.Prime n`, making the statement true and provable:

```lean
theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1)
    (hc : ¬ Nat.Prime n) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1
```

The proof uses `Nat.exists_dvd_of_not_prime2` to extract a non-trivial divisor k of n, then constructs the witness (k, n/k). It compiles cleanly with only standard axioms (propext, Classical.choice, Quot.sound).

### Deliverables

| File | Description |
|------|-------------|
| `Cryptography/Factoring/PadicFactoring.lean` | Lean 4 formalization with complete proof (no sorry) |
| `Main.lean` | Updated to import the proof file |
| `RESEARCH_REPORT.md` | Academic-style report with abstract, motivation, proof overview, and open problems |
| `demo.py` | Self-contained Python demo illustrating the theorem for composites and showing primes as counterexamples |
| `diagram.svg` | SVG visualization of the prime/composite dichotomy and proof strategy |
| `DISCUSSION.md` | Scientific American-style article (~1200 words) accessible to general readers |

The original false statement is preserved as a block comment with an explanation of why it fails.