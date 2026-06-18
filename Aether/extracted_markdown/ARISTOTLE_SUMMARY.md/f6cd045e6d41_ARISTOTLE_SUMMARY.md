# Summary of changes for run 0123a218-0810-449b-aea0-7e8df996de32
## Completed: Non-Archimedean Factoring Oracle

### Key Finding: The Original Theorem Was False

The original statement claimed that **every** `n > 1` has a nontrivial factorization `a * b = n` with `a > 1` and `b > 1`. This is **false for prime numbers** — for example, 2, 3, 5, 7 cannot be written as a product of two factors both greater than 1.

### Corrected Theorem

The original statement is preserved as a block comment in `Main.lean` with an explanation of why it fails. A corrected version adds the hypothesis `¬ Nat.Prime n` (i.e., n is composite):

```lean
theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1)
    (hcomp : ¬ Nat.Prime n) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1
```

### Proof

The proof is 2 lines using `Nat.exists_dvd_of_not_prime2` to extract a nontrivial divisor `k` (with `1 < k < n`), then constructing the factorization `(k, n/k)`. Verified axiom-clean (only `propext`, `Classical.choice`, `Quot.sound`).

### Deliverables

All 5 requested files are complete:

1. **`Main.lean`** — Corrected theorem with machine-verified proof, original false statement commented out with explanation.
2. **`RESEARCH_REPORT.md`** — Academic-style report covering abstract, motivation, framework, proof overview, novelty, open problems, and references.
3. **`demo.py`** — Self-contained Python demo that illustrates why the original fails for primes and verifies the corrected theorem for all composites up to 10,000. Runs with `python3 demo.py`.
4. **`diagram.svg`** — SVG visualization showing the partition of ℕ > 1 into primes (no nontrivial factorization) and composites (always factorable), with the oracle mapping.
5. **`DISCUSSION.md`** — Scientific American-style article (~1200 words) explaining the theorem accessibly, covering the error discovery, mathematical content, cryptographic relevance, and philosophical reflections.