# Summary of changes for run 65896327-55b2-4b5f-885a-d99c3249b24b
## Completed: Non-Archimedean Factoring Oracle

### Critical Finding: Original Theorem is FALSE

The original statement claimed that **every** integer n > 1 can be written as a product a × b with both a > 1 and b > 1. This is false — prime numbers (e.g., 7, 13, 101) are, by definition, irreducible and admit no such factorization.

### Corrected Theorem (Formally Verified)

The corrected statement adds the hypothesis `¬ n.Prime` (i.e., n is composite):

```lean
theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1)
    (hc : ¬ n.Prime) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1
```

The proof uses `Nat.exists_dvd_of_not_prime2` to extract a non-trivial divisor from any composite number, then constructs the pair (k, n/k). It compiles cleanly with only standard axioms (propext, Classical.choice, Quot.sound).

The original false statement is preserved in a block comment with an explanation of why it fails.

### Deliverables

| File | Description |
|------|-------------|
| `Main.lean` | Lean 4 proof — original theorem commented out with explanation, corrected version fully proved |
| `RESEARCH_REPORT.md` | Academic-style report: abstract, motivation, proof overview, open problems, references |
| `demo.py` | Self-contained Python script demonstrating the theorem numerically (runs with `python3 demo.py`) |
| `diagram.svg` | SVG visualization showing primes vs. composites and the oracle's domain |
| `DISCUSSION.md` | Scientific American–style article (~1200 words) explaining the result accessibly |