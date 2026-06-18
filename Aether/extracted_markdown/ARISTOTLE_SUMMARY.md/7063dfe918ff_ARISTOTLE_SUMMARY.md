# Summary of changes for run d09a55fc-75fa-44f4-91f8-cf53d6725429
## Completed: Non-Archimedean Factoring Oracle

### Key Finding: Original Statement Was False
The original theorem claimed that **every** integer n > 1 can be written as a product a × b with a, b > 1. This is false — primes (e.g., 2, 3, 5, 7, ...) have no such factorization. The original statement is preserved in a block comment in `Main.lean` with an explanation of why it fails.

### Corrected Theorem
The corrected version adds the hypothesis `¬ Nat.Prime n`, making the statement:
> For every composite n > 1, there exist a, b > 1 with a × b = n.

This is proved in Lean 4 using `Nat.exists_dvd_of_not_prime2` to extract a divisor k with 2 ≤ k < n, then setting a = k and b = n/k. The proof uses only standard axioms (propext, Classical.choice, Quot.sound).

### Deliverables
1. **`Main.lean`** — Corrected and fully proven theorem (no `sorry`). The original false statement is commented out with explanation.
2. **`RESEARCH_REPORT.md`** — Academic-style report with abstract, motivation, mathematical framework, proof overview, novelty analysis, open problems, and references.
3. **`demo.py`** — Self-contained Python demonstration that verifies the theorem computationally for n ∈ [2, 1000], shows p-adic valuation additivity, and correctly identifies primes as excluded cases. Runs with `python3 demo.py`.
4. **`diagram.svg`** — SVG flowchart visualizing the oracle's logic: input n > 1 → primality check → if composite, extract minimal factor k → output a = k, b = n/k.
5. **`DISCUSSION.md`** — Scientific American–style article (~1200 words) explaining the theorem through accessible analogies and connecting it to cryptography, formal verification, and open questions in algorithmic number theory.