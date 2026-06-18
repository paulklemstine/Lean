# Summary of changes for run d16a51eb-3235-4547-8b2b-5ab76b179ae5
## Completed: Non-Archimedean Factoring Oracle

### Critical Finding: Original Theorem is False

The original theorem claimed that **every** natural number n > 1 can be factored as n = a × b with a > 1 and b > 1. This is **mathematically false** — it fails for all prime numbers (e.g., 2, 3, 5, 7, ...). A prime has no non-trivial factorization.

### Corrected and Proven Theorem

The original false statement is preserved (commented out with explanation) in `Main.lean`. A corrected version adds the necessary hypothesis `¬ Nat.Prime n`:

```lean
theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1)
    (hc : ¬ Nat.Prime n) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1
```

The proof uses Mathlib's `Nat.exists_dvd_of_not_prime2` to obtain a non-trivial divisor k (with 2 ≤ k < n), then constructs the factorization as (k, n/k). Verified with only standard axioms (propext, Classical.choice, Quot.sound).

### Deliverables

| File | Description |
|------|-------------|
| `Main.lean` | Lean 4 formal proof (sorry-free, machine-verified) |
| `RESEARCH_REPORT.md` | Academic research report with abstract, motivation, proof overview, novelty analysis, open problems, and references |
| `demo.py` | Self-contained Python demo verifying the theorem numerically for all composites in [4, 100] and demonstrating why primes are counterexamples to the original claim |
| `diagram.svg` | SVG visualization showing the partition of ℕ > 1 into primes (unfactorable) and composites (factorable), plus the proof architecture |
| `DISCUSSION.md` | Scientific American-style article (~1200 words) explaining the theorem accessibly with analogies and broader context |