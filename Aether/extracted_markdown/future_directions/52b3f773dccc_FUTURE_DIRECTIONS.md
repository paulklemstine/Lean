# Future Directions: Axiomatic Oracle Hierarchies

## Synthesis

This research cycle made a surprising foundational discovery: the naïve axiomatization of jump operators — expansion (S ⊆ J(S)) plus unrestricted nontriviality (∀ S, ∃ x ∈ J(S), x ∉ S) — is **unsatisfiable for any type**. Applying nontriviality to the universal set yields x ∉ univ, which is impossible. We proved this vacuity result (`naive_jump_always_empty`) and developed two corrected frameworks: a `StrictExpander` on preorders (a < J(a)) and a `SetJumpOperator` with nontriviality restricted to proper subsets. From these corrected axioms, we derived the complete structural theory: strict hierarchy, no fixed points, information gaps, the essential-accidental gap (witnessing the strict separation between pointwise and uniform computability), and the finiteness obstruction.

The most promising cross-domain connection is between our **energy barrier interpretation** and the Catalog's `Computation/GravityOracle.lean`. Our framework shows that jump operators are fundamentally anti-idempotent (the double jump strictly dominates the single jump), while the gravity oracle's `geodesic_oracle_idempotent` represents the complementary phenomenon — a terminal oracle that has absorbed all information. The duality between anti-idempotent (jump) and idempotent (closure) operators is the key structural insight for future work.

The direction with highest breakthrough potential is **Direction 1: Ordinal-Indexed Oracle Chains**, because extending our ℕ-indexed `iterExpand` to transfinite ordinal chains would connect to Kleene's O, the hyperarithmetical hierarchy, and would require resolving the question of whether the limit construction (union at limit ordinals) preserves the jump properties — a non-trivial mathematical challenge.

---

### Direction 1: Ordinal-Indexed Oracle Chains and Transfinite Strict Expansion

**Conjecture**: The StrictExpander framework can be extended to ordinal-indexed chains by defining transfinite iteration: E^α(a) = E.jump(E^β(a)) for α = β + 1, and E^λ(a) = sup{E^β(a) : β < λ} for limit ordinals λ (when the preorder has directed suprema). The resulting hierarchy is strictly increasing through all ordinals strictly below the "collapse ordinal" — the first ordinal where the supremum construction fails or equals a fixed point.

**Test**: Define `TransfiniteExpand (E : StrictExpander α) (a : α) : Ordinal → α` using well-founded recursion on ordinals. Prove that for successor ordinals, the chain is strictly increasing (this follows directly from `strict_expansion`). For limit ordinals, prove that the supremum (if it exists) is strictly below the next jump. Compute the collapse ordinal for the concrete case of `natSuccExpander` on ℕ — it should be ω (since ℕ has no element above all finite numbers).

**Impact**: A complete transfinite extension would provide the abstract foundation for the hyperarithmetical hierarchy (H_α for α < ω₁^CK) and Turing's ordinal notations. If the collapse ordinal can be characterized intrinsically from the StrictExpander structure, this would yield a new invariant connecting order theory to computability.

**Catalog References**: `Bridges/OrdinalPRS.lean` (`energy_descent_chain_length`), `Computation/GravityOracle.lean` (`IsGravOracle`)

**Proof Strategy**:
1. Use Mathlib's `Ordinal` type and `Ordinal.limitRecOn` for transfinite recursion.
2. At successor ordinals: apply `strict_expansion` — straightforward.
3. At limit ordinals: requires the preorder to have directed colimits. Add this as a hypothesis (`DirectedComplete` or `SupClosed`).
4. Prove strict increase at limits: need that sup{E^β(a) : β < λ} < E.jump(sup{...}), which follows from `strict_expansion` applied to the supremum.
5. Key lemma: the supremum construction is well-defined and monotone.

**Domain Bridges**: Ordinal analysis (proof theory) <-> StrictExpander (computability) <-> Directed colimits (category theory)

**Lineage**: Extends this cycle's `iterExpand`, `iterExpand_strictMono`, and `expander_requires_infinite`.

**Ambition**: grand_challenge

---

### Direction 2: Quantitative Information Gaps and Oracle Entropy

**Conjecture**: For the concrete `SetJumpOperator` on ℕ, define the *information rate* I(n) = |J^{n+1}(∅) \ J^n(∅)| (the number of new elements at each level). For the filling jump, I(n) = 1 for all n. We conjecture that for any SetJumpOperator on ℕ where J(∅) is finite, the information rate I(n) is eventually periodic, and the *cumulative information* C(n) = |J^n(∅)| grows at most polynomially.

**Test**: Construct several concrete SetJumpOperators on ℕ with different jump behaviors (e.g., "add the k smallest missing elements" for various k). Compute I(n) and C(n) for each. Test whether I(n) is eventually periodic. Find a jump operator where I(n) grows super-polynomially, or prove this is impossible.

**Impact**: A quantitative theory of information production rates would connect oracle hierarchies to information theory and computational complexity. The growth rate of C(n) could characterize the "power" of different oracle constructions in a way that the qualitative hierarchy does not.

**Catalog References**: `Computation/InfoEfficientAlgorithms.lean` (`InfoEfficientAlgorithm`, `terminates_within_potential`), `Tropical/SpectralDynamics.lean` (`strict_cycle_gap_entropy_bridge`)

**Proof Strategy**:
1. Define concrete SetJumpOperators with various information rates.
2. Prove I(n) = k for the "add k smallest" jump.
3. For general jumps, relate I(n) to properties of the jump function.
4. Investigate whether super-polynomial growth is possible — this connects to the strength of the jump axioms.

**Domain Bridges**: Information theory (entropy) <-> Computability (oracle hierarchies) <-> Complexity theory (growth rates)

**Lineage**: Extends this cycle's `setjump_information_gap` and `setjump_diagonal_escape`.

**Ambition**: extension

---

### Direction 3: The Lattice of Jump Operators

**Conjecture**: The set of all SetJumpOperators on a fixed type β can be partially ordered by J₁ ≤ J₂ iff J₁.jump(S) ⊆ J₂.jump(S) for all S. This partial order admits a "composition product" J₂ ∘ J₁ (proved in this cycle as `composeSetJump`) that is strictly above each factor. We conjecture that the partial order has no maximum element (no "strongest possible jump") and that the composition product is associative.

**Test**: Define the partial order on SetJumpOperator β. Verify that `composeSetJump` is monotone with respect to this order. Construct two incomparable jump operators (neither J₁ ≤ J₂ nor J₂ ≤ J₁) to show the order is not total. Test associativity of composition.

**Impact**: If the lattice structure is rich (e.g., has infinite antichains), this would show that the space of possible oracle hierarchies is much more complex than the single linear hierarchy suggested by the Turing jump. This connects to the theory of Turing degrees, where incomparable degrees exist.

**Catalog References**: `Computation/GravityOracle.lean` (`IsGravOracle`), `Bridges/ClosureCompressionCore.lean`

**Proof Strategy**:
1. Define the ordering as a Lean `PartialOrder` instance on `SetJumpOperator β`.
2. Prove that `composeSetJump J₁ J₂` is above both J₁ and J₂ in this order.
3. Construct incomparable operators: J₁ adds even numbers first, J₂ adds odd numbers first.
4. Prove associativity of composition (should follow from function composition associativity).

**Domain Bridges**: Lattice theory (partial orders) <-> Computability (Turing degrees) <-> Algebra (semigroups)

**Lineage**: Extends this cycle's `composeSetJump` and `compose_dominates`.

**Ambition**: extension

---

### Direction 4: Closure-Jump Duality and Idempotent Completions

**Conjecture**: Every SetJumpOperator J induces a natural "closure operator" C_J defined by iterating J to the limit: C_J(S) = ⋃_n J^n(S). We conjecture that C_J satisfies the closure axioms (extensive, monotone, idempotent) if and only if J(univ) = univ. Furthermore, there is a Galois connection between the lattice of closure operators and the lattice of SetJumpOperators on any type.

**Background (Resolved)**: This cycle discovered and resolved a critical foundational issue — the naïve axiom "∀ S, ∃ x ∈ J(S), x ∉ S" is unsatisfiable because it fails at S = univ. We proved `naive_jump_always_empty` showing this, and corrected the axiomatization by restricting nontriviality to proper subsets.

**Test**: Define C_J as the limit oracle construction (`limitSetOracle`). Verify extensive (S ⊆ C_J(S)) and monotone (S ⊆ T ⇒ C_J(S) ⊆ C_J(T)). Test idempotence: is C_J(C_J(S)) = C_J(S)? This requires showing that J applied to the limit oracle doesn't add new elements — which may fail in general.

**Impact**: A clean duality between anti-idempotent (jump) and idempotent (closure) operators would unify computability theory with topology and lattice theory.

**Catalog References**: `Computation/GravityOracle.lean` (`geodesic_oracle_idempotent`), `Bridges/ClosureCompressionCore.lean` (`fixed_points_equal_incompressibles_of_strict_minimality`)

**Proof Strategy**:
1. Define C_J(S) = ⋃_n iterSetJump J S n (already `limitSetOracle`).
2. Prove extensive and monotone (straightforward).
3. For idempotence: show J(⋃_n J^n(S)) = ⋃_n J^n(S) or find a counterexample.
4. The key question: does the limit oracle reach univ? If so, J fixes it.

**Domain Bridges**: Topology (closure operators) <-> Computability (jump operators) <-> Lattice theory (Galois connections)

**Lineage**: Builds on this cycle's `limitSetOracle`, `limit_strictly_contains`, and `naive_jump_always_empty`.

**Ambition**: extension

---

### Direction 5: Polynomial Hierarchy Instantiation

**Conjecture**: The abstract SetJumpOperator framework can be instantiated with polynomial-time oracle Turing machines to recover the polynomial hierarchy PH = ⋃_k Σ^p_k. Define J(C) = {L : L is decidable in polynomial time with oracle access to C}. Then J satisfies expansion (P ⊆ P^C) and, assuming PH does not collapse, nontriviality (for each level, the next level contains genuinely harder problems).

**Test**: Formalize a simplified oracle computation model (e.g., oracle circuits with bounded depth). Prove that polynomial-time reductions compose (for expansion). Reduce nontriviality to standard separation assumptions (PH non-collapse). Derive the structural theorems (strict hierarchy, no fixed points) conditional on these assumptions.

**Impact**: This would connect our abstract framework to the central open questions in computational complexity. A proof that the polynomial hierarchy doesn't collapse would resolve a major conjecture; conversely, showing that our framework requires assumptions equivalent to PH non-collapse would clarify the logical strength of the axioms.

**Catalog References**: `Computation/CircuitBarriers.lean`, `Computation/BranchingPrograms.lean`

**Proof Strategy**:
1. Define a simplified oracle computation model.
2. Define Σ^p_k inductively using the SetJumpOperator structure.
3. Prove expansion from polynomial-time reduction composition.
4. Reduce nontriviality to PH non-collapse (conditional result).
5. Apply the abstract theorems to get conditional structural results.

**Domain Bridges**: Complexity theory (PH) <-> Abstract computability (jump operators) <-> Cryptographic hardness (one-way functions)

**Lineage**: Extends all of this cycle's abstract framework to the most important concrete instantiation.

**Ambition**: grand_challenge
