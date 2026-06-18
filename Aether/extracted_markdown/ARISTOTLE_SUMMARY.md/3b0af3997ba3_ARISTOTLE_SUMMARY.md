# Summary of changes for run ca3c21aa-ed37-429c-8c25-016146fca4c5
## Completed: Non-Archimedean Factoring Oracle

### Key Finding: The Original Statement is False
The original theorem claimed that **every** `n > 1` can be written as `a * b` with `a > 1` and `b > 1`. This is **false** — primes (e.g., `n = 2`) have no such nontrivial factorization. The original statement is preserved in a block comment with an explanation.

### Corrected Theorem (Proved)
A corrected version adds the hypothesis `¬ Nat.Prime n` (the number must be composite):

```lean
theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1)
    (hc : ¬ Nat.Prime n) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1
```

The proof uses `Nat.exists_dvd_of_not_prime2` to extract a divisor `k` with `1 < k < n`, then takes `a = k` and `b = n / k`. It compiles cleanly with only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

### Deliverables
| File | Description |
|------|-------------|
| `Speculative/NonArchimedeanFactoring.lean` | Lean 4 proof (builds successfully, no sorries) |
| `Main.lean` | Imports the proof module |
| `RESEARCH_REPORT.md` | Academic research report with abstract, motivation, proof overview, open problems |
| `DISCUSSION.md` | Scientific American-style article (~1200 words) |
| `demo.py` | Self-contained Python demo (runs without errors, illustrates the theorem numerically including p-adic valuations) |
| `diagram.svg` | SVG diagram showing proof structure and Newton polygon connection |