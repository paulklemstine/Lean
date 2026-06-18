# Summary of changes for run a19d5c53-44fb-4f96-a391-e3d58ea072b5
## Summary

### Key Finding: The Original Theorem Is False

The theorem `pAdic_factoring_oracle` as stated claims that **every** natural number n > 1 can be written as a product a · b with both a > 1 and b > 1. This is **false** — prime numbers (e.g., n = 2) are counterexamples. For n = 2, any a, b > 1 would give a · b ≥ 4 > 2, a contradiction.

### What Was Done

1. **Commented out the false theorem** with an explanation of why it fails.
2. **Proved a corrected version** (`pAdic_factoring_oracle_corrected`) that adds the hypothesis `¬ Nat.Prime n` — every composite number n > 1 admits a non-trivial factorization. The proof uses `Nat.exists_dvd_of_not_prime2` to find a divisor k with k ∣ n, k ≥ 2, k² ≤ n, then sets a = k, b = n/k.
3. **Formally disproved the original** (`pAdic_factoring_oracle_false`) by exhibiting n = 2 as a counterexample.

Both proofs compile without sorry and use only standard axioms (propext, Classical.choice, Quot.sound).

### Deliverables

| File | Description |
|------|-------------|
| `Cryptography/Factoring/PadicFactoring.lean` | Lean 4 formalization with both proofs |
| `Main.lean` | Entry point importing the formalization |
| `RESEARCH_REPORT.md` | Academic-style research report |
| `demo.py` | Python demonstration (runs with `python3 demo.py`) |
| `diagram.svg` | SVG visualization of primes vs composites |
| `DISCUSSION.md` | Scientific American-style article (~1200 words) |