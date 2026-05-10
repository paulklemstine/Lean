# MASTER FUTURE DIRECTIONS — Accumulated Research Wisdom

*Last updated: 2026-05-10 18:00*

## Breakthrough Opportunities (ranked by impact)

### 1. Quotient-Cardinality Refinement

- **Theorem Statement**: For `[Fintype α] [DecidableEq α]` with `ρ : Setoid α` having `[DecidableRel ρ.r]` and `f : α → α`, prove `∀ x, ∃ m n, m < n ∧ n ≤ Fintype.card (Quotient ρ) ∧ ρ.r (f^[m] x) (f^[n] x)`.
- **Proof Strategy**:
  1. Show `Quotient ρ` is `Fintype` when `ρ.r` is decidable (via `Quotient.fintype`).
  2. Apply pigeonhole to the quotient-valued sequence `i ↦ ⟦f^[i](x)⟧`.
  3. Convert quotient equality back to setoid relation.
- **Why This Is Revolutionary**: Dramatically tightens bounds when the equivalence has few classes (e.g., parity has only 2 classes, giving bound 2 instead of n).
- **Catalog Leverage**: Build on `exists_iterate_eq`, `orbit_repeats_mod_congruence`, `chronometric_pigeonhole_fixedPoint`.
- **Research Mode**: prove
- **Estimated Depth**: 2

### 2. Semiring Congruence Functoriality

- **Theorem Statement**: For `RingCon α` (Mathlib's semiring congruence), prove that orbit repetition bounds are functorial under congruence morphisms: if `φ : RingCon α →r RingCon β` is a congruence morphism and f respects both congruences, then the orbit bound for `β` is at most the orbit bound for `α`.
- **Proof Strategy**:
  1. Define morphisms between `RingCon` objects.
  2. Show that orbit repetition modulo a finer congruence implies repetition modulo a coarser one.
  3. Prove the functorial transport theorem.
- **Why This Is Revolutionary**: Opens the door to computing orbit bounds via quotient towers, reducing complex congruences to simpler ones.
- **Catalog Leverage**: Build on `SemiringCong` from `AutoResearch/Basic.lean`, `ProofCongruence` from `AutoResearch/PrimeCongruenceProofSemiring.lean`.
- **Research Mode**: formalize
- **Estimated Depth**: 3

### 3. Optimal Obstruction Certificate Computation

- **Theorem Statement**: Define `minObstructionHorizon ρ f x := Nat.find (⟨card α, ...⟩)` and prove it is the minimal horizon for which no adjacent stabilization occurs. Prove `minObstructionHorizon ρ f x ≤ card α` and that the search algorithm terminates in O(card α) steps.
- **Proof Strategy**:
  1. Use `Nat.find` with the decidability of `ρ.r`.
  2. Prove minimality by construction.
  3. Bound the find by the pigeonhole upper limit.
- **Why This Is Revolutionary**: Converts the theoretical bound into a practical algorithm with certified optimality.
- **Catalog Leverage**: Build on `BoundedObstructionCertificate`, `ChronometricIncompletenessBound`.
- **Research Mode**: prove
- **Estimated Depth**: 2

### 4. Tropical Semiring Collision Bounds

- **Theorem Statement**: Specialize the orbit repetition framework to the tropical semiring (ℕ ∪ {∞}, min, +) and prove that the orbit repetition bound for tropical matrix iteration is bounded by the dimension times the number of distinct entries.
- **Proof Strategy**:
  1. Define the tropical semiring as a `FiniteProofSemiring` instance (for finite truncations).
  2. Define tropical matrix iteration as a `WeightControlledOp`.
  3. Apply `chronometric_pigeonhole_fixedPoint` to derive bounds.
  4. Connect to known results on tropical eigenvalues.
- **Why This Is Revolutionary**: Bridges the framework to tropical geometry, enabling applications to shortest-path algorithms and network optimization.
- **Catalog Leverage**: Build on tropical semiring infrastructure in `Tropical/` catalog files.
- **Research Mode**: formalize
- **Estimated Depth**: 4

### 5. Gödel–Brouwer Semiring Diagonal Schema

- **Theorem Statement**: For a finitely presented proof semiring P with explicit coding map `code : P → ℕ` and self-substitution operator `sub : P → P → P`, define a diagonal sentence `d := sub p p` for the fixed point of the self-substitution and prove that `IsDiagonalClass` holds for the set of diagonal sentences.
- **Proof Strategy**:
  1. Define the coding formalism within the proof semiring.
  2. Construct the self-substitution map.
  3. Show the diagonal class property via the fixed-point construction.
  4. Derive incompleteness-style consequences.
- **Why This Is Revolutionary**: Creates a direct formal link between algebraic fixed-point theory and Gödel-style incompleteness.
- **Catalog Leverage**: Build on `IsDiagonalClass`, `diagonal_echo_quantum_certificate`, `diagonal_fixed_point` from `EMLClosureCore.lean`.
- **Research Mode**: formalize
- **Estimated Depth**: 5