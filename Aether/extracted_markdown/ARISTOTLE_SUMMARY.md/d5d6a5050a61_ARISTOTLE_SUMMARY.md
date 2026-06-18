# Summary of changes for run 2ecbb5b4-3906-4b45-b01c-79d4e63fcc94
## Completed: Non-Archimedean Factoring Oracle

### Key Finding: Original Statement Was False

The original theorem claimed that **every** `n > 1` can be written as `a * b` with both `a > 1` and `b > 1`. This is **false** — prime numbers (e.g., `n = 2`) have no such non-trivial factorization. The original statement has been preserved in a block comment with an explanation of why it fails.

### Corrected and Proved Theorem

The corrected version adds the hypothesis `¬ n.Prime` (i.e., n is composite):

```lean
theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1)
    (hc : ¬ n.Prime) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1
```

The proof uses `Nat.exists_dvd_of_not_prime2` from Mathlib to extract a proper divisor `k` with `1 < k < n` and `k | n`, then constructs the factorization `n = k × (n/k)`. The proof compiles cleanly with only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

### Deliverables

| File | Description |
|------|-------------|
| `Cryptography/Factoring/NonArchimedeanFactoringOracle.lean` | Formal Lean 4 proof (sorry-free, builds successfully) |
| `Main.lean` | Updated to reference the proof file, with original false statement commented out |
| `RESEARCH_REPORT.md` | Academic report with abstract, motivation, proof overview, novelty analysis, open problems, and references |
| `demo.py` | Self-contained Python demonstration showing counterexamples for primes, the corrected theorem in action, p-adic valuation perspective, and RSA relevance |
| `diagram.svg` | SVG visualization showing the classification of ℕ_{>1} into primes/composites, the proof structure, and Newton polygon illustration |
| `DISCUSSION.md` | ~1200-word Scientific American–style article explaining the theorem accessibly |