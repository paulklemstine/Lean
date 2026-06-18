# Summary of changes for run 11d9c880-c096-46f7-9a9b-ff81514a0331
## Completed: Non-Archimedean Factoring Oracle

### Critical Finding: Original Statement is False

The original theorem claimed that **every** n > 1 can be written as a product a × b with a > 1 and b > 1. This is **false** — primes (2, 3, 5, 7, ...) cannot be factored this way. For example, 2 = 1 × 2, but 1 is not greater than 1.

### Corrected Theorem (Proved)

The corrected version adds the hypothesis `¬ Nat.Prime n` (n is composite):

```lean
theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1)
    (hc : ¬ Nat.Prime n) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1
```

The proof uses `Nat.exists_dvd_of_not_prime2` from Mathlib to extract a non-trivial divisor k of n (with 1 < k < n), then sets a = k and b = n/k. It compiles cleanly with no `sorry` and only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

### Deliverables

| File | Description |
|------|-------------|
| `Speculative/NonArchimedeanFactoring.lean` | Lean 4 proof with documented correction of the original false statement |
| `Main.lean` | Imports the proof module |
| `RESEARCH_REPORT.md` | Academic report: abstract, motivation, framework, proof overview, novelty, open problems, references |
| `demo.py` | Self-contained Python demo showing primes as counterexamples and verified factorizations for composites (runs with `python3 demo.py`) |
| `diagram.svg` | SVG visualization of the decision tree (prime vs composite) and proof structure |
| `DISCUSSION.md` | ~1200-word Scientific American–style article on the theorem and its context |