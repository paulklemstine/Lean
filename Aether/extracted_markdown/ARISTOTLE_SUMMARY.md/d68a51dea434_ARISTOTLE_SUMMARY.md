# Summary of changes for run 9cce0727-47c0-47bc-a8aa-be90c9393394
## Completed: Reversible Computing and Thermodynamic Efficiency

### Deliverables

**`Computation/ReversibleComputing.lean`** — 162 lines, fully proven (zero sorry), formalizing 4 key results:

1. **Bennett's Reversible Embedding Theorem**: Any function `f : α → β` lifts to a bijection `α × β ≃ α × β` via `(a, b) ↦ (a, f(a) + b)`. This is the mathematical core of Bennett's 1973 result showing any computation can be made reversible. Includes proofs that the embedding preserves the first component, recovers `f` at zero, and that sequential composition corresponds to function addition (`reversibleEmbed_comp`).

2. **Toffoli Gate Properties**: The CCNOT gate `(a, b, c) ↦ (a, b, (a ∧ b) ⊕ c)` is proven to be an involution (self-inverse), hence a bijection (`toffoliEquiv`). We prove it computes AND (`toffoli_computes_and`) and simulates NOT (`toffoli_simulates_not`), establishing its computational universality.

3. **Landauer Erasure Identity**: For a surjective function `f : α → β` between finite types, `∑_b (|f⁻¹(b)| - 1) = |α| - |β|`. This is the combinatorial core of Landauer's principle: irreversible computation erasing `m` states to `n` states must lose exactly `m - n` units of information. Built on a helper lemma (`sum_fiber_sizes`) showing fibers partition the domain.

4. **Reversibility Characterization**: (a) Between equinumerous finite types, injectivity ⟺ surjectivity. (b) Injective functions have all fibers of size ≤ 1 (zero erasure). Together these formalize: a computation is reversible if and only if it erases no information.

### Axioms used
Only standard axioms: `propext`, `Classical.choice`, `Quot.sound` (verified via `#print axioms`).

**`FUTURE_DIRECTIONS.md`** — 5 research directions including Toffoli universality, quantitative Landauer bounds with Shannon entropy, Bennett's space-time tradeoff via pebble games, Fredkin gate / conservative logic, and entropy production in Markov chains.