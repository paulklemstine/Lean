# Summary of changes for run e8fc72b8-56ba-49af-916a-391c82c9bda0
# Non-Archimedean Factoring Oracle — Completed

## Key Finding: Original Statement Was False

The original theorem claimed that **every** n > 1 can be written as a product a × b with both a > 1 and b > 1. This is **false for primes** (e.g., n = 2 has no such factorization). The original statement is preserved in a block comment with an explanation of why it fails.

## Corrected Theorem — Fully Proved

A corrected version adds the hypothesis `¬ Nat.Prime n` (i.e., n is composite):

```lean
theorem non_archimedean_factoring_oracle_breakthrough
    {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1) (hc : ¬ Nat.Prime n) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1
```

The proof uses `Nat.exists_dvd_of_not_prime2` to extract a nontrivial divisor k of n, then constructs witnesses a = k and b = n/k. It is fully machine-verified with only standard axioms (propext, Classical.choice, Quot.sound). No `sorry` remains in active code.

## Deliverables

| File | Description |
|------|-------------|
| `Main.lean` | Lean 4 formalization with complete proof (builds cleanly) |
| `RESEARCH_REPORT.md` | Academic report with abstract, motivation, proof overview, open problems, and references |
| `demo.py` | Self-contained Python demo illustrating the theorem numerically (run with `python3 demo.py`) |
| `diagram.svg` | SVG visualization of the proof structure (viewable in any browser) |
| `DISCUSSION.md` | Scientific American-style article (~1200 words) explaining the theorem accessibly |