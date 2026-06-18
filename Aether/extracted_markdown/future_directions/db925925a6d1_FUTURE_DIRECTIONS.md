# Future Directions

## 1. Kantorovich–Wasserstein Lifting for Probabilistic/Branching Systems

Replace the deterministic transition function `next : σ → σ` with a probability kernel `K : σ → Measure σ` (or a semiring-valued transition matrix). The bisimulation distance then uses the Kantorovich (optimal transport) lifting instead of the pointwise `d(next s, next t)`. This would yield a **Kantorovich–Rubinstein theorem for reversible temporal semantics** — connecting bisimulation metrics to optimal transport theory.

**Key challenge**: Formalizing the Kantorovich duality in Lean 4 over `ℝ≥0∞`-valued costs, or using the existing Mathlib measure theory to define the Wasserstein distance.

## 2. Symmetry from Reversibility

Prove that when the transition function is a bijection (reversible dynamics), the least bisimulation pseudometric is automatically symmetric — upgrading from a Lawvere quasi-metric to a genuine pseudometric. The proof strategy: show the lifting operator commutes with argument transposition when `next` is injective, then use leastness to compare `d` with its transpose.

**Status**: The preservation theorem `stepLift_symmetric` is already proved. What remains is the inductive/limit argument showing the supremum inherits symmetry and connecting this specifically to bijectivity of `next`.

## 3. Tropicalization of the Bisimulation Pseudometric

Replace the semiring $(ℝ_{\geq 0}^{\infty}, +, \max)$ with the tropical semiring $(\mathbb{R} \cup \{\infty\}, \min, +)$. This changes the bisimulation metric from a "worst-case discrepancy" to a "shortest-path cost," connecting to:
- Shortest path algorithms on behavioral graphs
- Tropical geometry of system invariants
- Min-plus algebra for timing analysis

This could leverage the existing tropical semiring infrastructure in the project.

## 4. Algorithm Extraction and Certified Computation

Extract a verified algorithm from the Lean formalization:
- **Finite stabilization bound**: Prove that for a system with $n$ states, the iteration stabilizes in at most $n^2$ steps.
- **Decidable equality on `ℝ≥0∞`**: For rational-valued observation distances, prove the computation is exact.
- **Code extraction**: Use Lean's code generation to produce an executable bisimulation distance calculator with correctness guarantees.

## 5. Quantitative Full Abstraction

Prove a **full abstraction theorem**: the bisimulation pseudometric equals the "testing distance" — the supremum over all contexts of the difference in observable behavior. This would show that the denotational distance (our construction) and the operational distance (testing) coincide, the quantitative analogue of the classical full abstraction theorem for process algebras.

**Formal statement sketch**:
```
∀ s t, d*(s, t) = ⨆ C : Context, |⟦C[s]⟧ - ⟦C[t]⟧|
```
where the supremum ranges over all observation contexts.
