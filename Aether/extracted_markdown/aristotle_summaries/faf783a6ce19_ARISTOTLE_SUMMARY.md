# Summary of changes for run 856aacc7-9997-4a4a-96c2-b76c9f3bc63d
## Summary

### Theorem Analysis and Correction

The original theorem `pAdic_factoring_oracle` claimed that **every** natural number n > 1 admits a non-trivial factorization (∃ a b > 1, a * b = n). This statement is **false** — prime numbers are counterexamples (e.g., n = 2 has no such factorization).

I identified this error, commented out the original false statement with an explanation, and proved a **corrected version** that adds the hypothesis `¬ Nat.Prime n`, restricting to composite numbers:

```lean
theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1)
    (hc : ¬ Nat.Prime n) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1
```

I also proved an auxiliary classification theorem:

```lean
theorem prime_or_composite (n : ℕ) (hn : n > 1) :
    Nat.Prime n ∨ ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1
```

Both proofs are complete (no `sorry`), build successfully, and use only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

### Deliverables

All requested files are present:

| File | Description |
|------|-------------|
| `Cryptography/Factoring/NonArchimedeanFactoring.lean` | Lean 4 formalization with complete proofs |
| `RESEARCH_REPORT.md` | Academic research report with abstract, motivation, proof overview, novelty, open problems, and references |
| `demo.py` | Self-contained Python demo illustrating the theorem numerically (runs with `python3 demo.py`) |
| `diagram.svg` | SVG diagram showing the prime/composite classification and proof strategy |
| `DISCUSSION.md` | Scientific American–style article (~1200 words) explaining the theorem accessibly |

### Key Insight

The p-adic framing in the original statement was a red herring — the corrected theorem is purely number-theoretic. The proof uses Mathlib's `Nat.exists_dvd_of_not_prime2` to extract the smallest non-trivial divisor of a composite number, then pairs it with the complementary factor. This episode demonstrates the value of formal verification: even seemingly obvious number-theoretic claims can be subtly wrong, and machine-checked proofs catch these errors with certainty.