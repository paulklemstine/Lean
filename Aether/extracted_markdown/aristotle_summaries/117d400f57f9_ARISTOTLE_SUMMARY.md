# Summary of changes for run ccc7eaeb-9e4b-4da2-a9c3-6b4088ab40e3
## Completed: Non-Archimedean Factoring Oracle

### Theorem Status

**Critical correction**: The original theorem statement was **false**. It claimed that every n > 1 can be written as a product a × b with both a, b > 1, but primes (e.g., n = 2) are counterexamples. The original statement is preserved in a block comment with an explanation of why it fails.

**Corrected theorem**: Added the hypothesis `¬ Nat.Prime n` (n is composite), making the statement true and provable:

```lean
theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1)
    (hc : ¬ Nat.Prime n) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1
```

**Proof**: Uses `Nat.exists_dvd_of_not_prime2` to extract a non-trivial divisor from the composite hypothesis, then constructs both factors. Verified sorry-free with clean axioms (propext, Classical.choice, Quot.sound).

### Deliverables

All files are in the project root:

| File | Description |
|------|-------------|
| `Speculative/NonArchimedeanFactoring.lean` | Lean 4 formalization with complete proof (no sorry) |
| `Main.lean` | Imports the Speculative module |
| `RESEARCH_REPORT.md` | Academic research report (abstract, motivation, proof overview, open problems, references) |
| `DISCUSSION.md` | Scientific American–style article (~1200 words) accessible to general readers |
| `demo.py` | Self-contained Python demo illustrating the theorem numerically with p-adic valuations |
| `diagram.svg` | SVG visualization of the oracle process and p-adic valuation tree structure |

All files compile/run successfully. The Python demo runs with `python3 demo.py` and produces formatted output showing the factoring oracle on numbers 2–50, p-adic valuations of 360, and a large semiprime example.