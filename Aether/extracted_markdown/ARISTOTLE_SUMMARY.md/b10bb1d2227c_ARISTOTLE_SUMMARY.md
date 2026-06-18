# Summary of changes for run 1ffa8e4b-afbd-487d-8bc1-2ae515277a84
## Summary

### Theorem Analysis & Correction

The original theorem `pAdic_factoring_oracle` claims that **every** n > 1 admits a non-trivial factorization (∃ a b > 1, a·b = n). This is **false** — prime numbers (e.g., n = 2) are immediate counterexamples. No pair (a, b) with both a > 1 and b > 1 satisfies a · b = 2.

The original statement is commented out with an explanation in both `Main.lean` and `Cryptography/Factoring/PAdicFactoring.lean`. Two corrected versions are provided and **fully proved** (no sorry, clean axioms: propext, Classical.choice, Quot.sound):

1. **`pAdic_factoring_oracle_corrected`**: Every n > 1 is either prime or admits a non-trivial factorization. (Adds `Nat.Prime n` as a disjunct.)

2. **`pAdic_factoring_oracle_composite`**: Every composite n (n > 1, ¬ Prime n) admits a non-trivial factorization. (Adds `¬ Nat.Prime n` as a hypothesis.)

Both proofs use `Nat.exists_dvd_of_not_prime2` to extract a divisor d with 1 < d < n for composite numbers, then set a = d, b = n/d.

### Deliverables

| File | Description |
|------|-------------|
| `Main.lean` | Original location with commented-out false theorem + two proved corrected versions |
| `Cryptography/Factoring/PAdicFactoring.lean` | Clean version that builds as part of the project's Cryptography target |
| `RESEARCH_REPORT.md` | Academic research report with abstract, motivation, proof overview, novelty, open problems, references |
| `demo.py` | Self-contained Python demo (runs with `python3 demo.py`) showing the oracle on various numbers, demonstrating the counterexample, and illustrating p-adic valuations |
| `diagram.svg` | SVG diagram showing the decision structure of the corrected oracle (prime vs. composite branches) |
| `DISCUSSION.md` | ~1200-word Scientific American-style article explaining the theorem accessibly |

### Build Verification

`Cryptography/Factoring/PAdicFactoring.lean` builds successfully with no sorry in active code and only standard axioms.