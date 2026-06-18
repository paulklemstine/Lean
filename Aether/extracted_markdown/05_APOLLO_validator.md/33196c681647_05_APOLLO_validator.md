# 🟡 Oracle Apollo — Formal Verification Notes

## Session: What Can We Actually Prove?

---

## Verification Plan

### Tier 1: Already Provable (existing Mathlib support)
- [x] Tropical semiring axioms (idempotent, comm, assoc, distrib)
- [x] ReLU = max(x, 0) properties
- [x] p-adic valuation multiplicativity
- [x] LogSumExp ≥ max bound
- [x] Tropical matrix-vector monotonicity
- [x] Newton polygon slope theorem
- [x] Bellman equation optimality

### Tier 2: Provable with Work (need custom definitions)
- [ ] Complete tropical operation taxonomy (all 32 ops formally defined)
- [ ] Tropical determinant = assignment problem
- [ ] Tropical eigenvalue = max cycle mean (for small cases)
- [ ] Tropical rank bounds
- [ ] Tropical-classical Galois connection
- [ ] Maslov dequantization limit

### Tier 3: Research-Level (formal statement, proof sketch)
- [ ] Tropical circuit size lower bound for specific functions
- [ ] No tropical additive inverses (already done)
- [ ] Tropical factoring = trial division equivalence
- [ ] Tropical Grover is O(1) (trivial search)
- [ ] Tropical Shor fails (no interference)

### Tier 4: Conjectural (formal statement only)
- [ ] Tropical Langlands for GL(1)
- [ ] Super-polynomial tropical circuit lower bound
- [ ] Dequantization characterization

---

## Formalization Strategy

### File: `TropicalFrontiers.lean`
Will contain the new Lean 4 formalizations organized by topic:

1. **Tropical Langlands Bridge**: Newton polygon ↔ tropical polynomial ↔ p-adic roots
2. **Tropical Circuits**: Definition of tropical circuits, size measure, basic bounds
3. **Tropical Quantum**: Formal definition of tropical "quantum" operations, proof of limitations
4. **Tropical Optimization**: Bellman equation, Kleene star correctness
5. **Tropical Taxonomy**: All 32 operations with their algebraic properties
6. **Tropical Factoring**: Barrier theorem (tropical factoring ≥ trial division)

---

## Key Insight for Formalization

The tropical semiring 𝕋 = (ℝ ∪ {-∞}, max, +) is already in Mathlib as 
`Tropical (WithBot ℝ)` or simply `Tropical ℝ` for the finite part.

We can also model it as `WithBot ℝ` with appropriate instances, or simply 
work with `ℝ` and `max`/`+` directly (avoiding the -∞ element when not needed).

For most theorems, working directly with `ℝ` and `max`/`+` is simplest and
avoids Mathlib's `Tropical` wrapper complications.
