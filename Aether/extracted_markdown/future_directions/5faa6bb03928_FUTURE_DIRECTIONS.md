# Future Directions

## Synthesis

The formalization of compact operator invariant subspace theory establishes a verified corridor through one of operator theory's deepest fault lines. Our twelve theorems — spanning eigenspace closedness, commutant preservation, finite-dimensionality from compactness, and the Enflo–Read obstruction — create a modular platform for exploring the boundary between operators that must have invariant subspaces and those that might resist them. The following directions extend this platform in five ways: (1) closing the Riesz–Schauder gap to obtain unconditional results, (2) strengthening invariance to hyperinvariance, (3) expanding the compact class to polynomially compact and Riesz operators, (4) attacking the Hilbert space invariant subspace problem through verified obstruction analysis, and (5) connecting to quantum information theory through invariant channel structure.

---

## Direction 1: Riesz–Schauder Spectral Theorem Formalization

**Conjecture:** Every nonzero compact operator on an infinite-dimensional complex Banach space has a nonzero eigenvalue.

**Test:** Formalize the Fredholm alternative for compact operators in Lean 4. The key steps are: (1) prove that the spectrum of a compact operator is at most countable with 0 as the only possible accumulation point, (2) show that every nonzero spectral point is an eigenvalue, (3) conclude that if the operator is nonzero, some spectral point is nonzero. A successful formalization would compose directly with our `eigenspace_is_nontrivial_proper_closedInvariant` to yield the unconditional Aronszajn–Smith theorem. Failure would indicate a gap in Mathlib's Fredholm theory infrastructure.

**Impact:** Removes the eigenvalue existence hypothesis from all our main theorems, yielding the unconditional statement: every nonzero compact operator on an infinite-dimensional Hilbert space has a nontrivial closed invariant subspace. This would be one of the deepest formally verified results in functional analysis.

**Catalog References:** `Algebra/InvariantSubspace/CompactOperators.lean::eigenspace_is_nontrivial_proper_closedInvariant`, `Algebra/InvariantSubspace/CompactOperators.lean::finiteDimensional_eigenspace_of_isCompactOperator`

**Proof Strategy:** Develop the Fredholm alternative via the analytic Fredholm theorem: for compact T and nonzero λ, T - λI is Fredholm of index 0. Use Riesz's lemma to show that the resolvent set of T minus {0} equals the set of non-eigenvalues. The spectral radius formula then constrains the spectrum.

**Domain Bridges:** Spectral theory → Fredholm theory → Index theory

**Lineage:** Direct extension of our Theorem C (finite-dimensionality). The Riesz–Schauder theorem is the missing link between compactness and eigenvalue existence.

**Ambition:** Grand challenge — this would require formalizing a significant portion of Fredholm theory not currently in Mathlib.

---

## Direction 2: Hyperinvariant Subspace Theorem

**Conjecture:** If K is a nonzero compact operator on an infinite-dimensional complex Hilbert space and μ ≠ 0 is an eigenvalue of K, then E_μ(K) is hyperinvariant for K — that is, invariant under every operator that commutes with K.

**Test:** Formalize the statement and proof in Lean 4. Our `commutant_preserves_compact_spectral_sector` already proves that the entire commutant preserves the eigenspace. The hyperinvariance result follows if we can show that the commutant of K equals {T : TK = KT}, which is definitional. The test is whether Lean's type system handles the quantification cleanly, and whether the result extends to show that the eigenspace is invariant under the *double commutant* (operators commuting with all operators that commute with K). A disproof would require finding an operator in the double commutant that does not preserve the eigenspace.

**Impact:** Hyperinvariant subspaces are strictly stronger than invariant subspaces. Establishing hyperinvariance opens connections to the Burnside theorem and transitive algebra theory.

**Catalog References:** `Algebra/InvariantSubspace/CompactOperators.lean::eigenspace_map_of_commuting`, `Algebra/InvariantSubspace/CompactOperators.lean::commutant_preserves_compact_spectral_sector`

**Proof Strategy:** The eigenspace E_μ(K) is already shown to be invariant under all T with TK = KT (our Theorem 3.3). For hyperinvariance of K itself, we need to show that every operator commuting with K preserves E_μ(K), which is exactly our theorem. The strengthening to the double commutant requires additional algebraic machinery.

**Domain Bridges:** Operator algebras → von Neumann algebras → Burnside theory

**Lineage:** Direct strengthening of our Theorems B and commutant_preserves_compact_spectral_sector.

**Ambition:** Solid extension — the key ingredients are already in place, this primarily requires careful algebraic formalization.

---

## Direction 3: Polynomially Compact and Riesz Operators

**Conjecture:** If T is an operator on an infinite-dimensional complex Hilbert space such that p(T) is compact for some nonzero polynomial p, and if p(T) has a nonzero eigenvalue, then T has a nontrivial closed invariant subspace.

**Test:** Formalize the reduction from polynomially compact operators to compact operators. The key insight is that K = p(T) is compact and commutes with T (since T commutes with any polynomial in T). Our `commuting_operator_has_invariant_subspace_of_compact_eigenvalue` then applies directly. A computational test: construct random matrices T, compute p(T) for various polynomials p, check whether the resulting eigenspaces are T-invariant. Failure of the conjecture would require a polynomial p where p(T) has nonzero eigenvalues but T has no nontrivial invariant subspace — which our theorem shows is impossible.

**Impact:** Significantly expands the class of operators known to have invariant subspaces. Polynomially compact operators arise naturally in perturbation theory and differential equations.

**Catalog References:** `Algebra/InvariantSubspace/CompactOperators.lean::commuting_operator_has_invariant_subspace_of_compact_eigenvalue`, `Algebra/InvariantSubspace/CompactOperators.lean::eigenspace_map_of_commuting`

**Proof Strategy:** Observe that for K = p(T), we have TK = Tp(T) = p(T)T = KT since T commutes with polynomials in T. Apply our Theorem B directly. The formalization challenge is showing that T commutes with p(T) in the Lean type system, which requires properties of the polynomial functional calculus.

**Domain Bridges:** Polynomial algebra → Functional calculus → Perturbation theory

**Lineage:** Builds on Bernstein–Robinson (1966) and directly extends our commutant machinery.

**Ambition:** Solid extension — mathematically straightforward given our infrastructure, but requires polynomial calculus formalization.

---

## Direction 4: Formal Enflo–Read Obstruction Analysis

**Conjecture:** On a separable infinite-dimensional Hilbert space, if an operator T has no nontrivial closed invariant subspace, then T has no nonzero compact operator in its commutant. (Equivalently: T satisfies the EnfloReadPattern.)

**Test:** This is a strengthening of our obstruction theorem (which only rules out compact commutants with nonzero eigenvalues). To test it, one would need to determine whether a compact operator K commuting with a hypothetical counterexample T can have *only* zero eigenvalues (quasinilpotent compact operator). If K is compact, quasinilpotent, and nonzero, does K still force T to have an invariant subspace? The Riesz–Schauder theorem implies that every nonzero compact operator on infinite-dimensional space has a nonzero eigenvalue, so this conjecture would follow from Riesz–Schauder + our obstruction theorem. A disproof would require a compact quasinilpotent operator on a Hilbert space, which Riesz–Schauder forbids.

**Impact:** Would establish that any Hilbert space counterexample to the invariant subspace problem must have *completely trivial* compact commutant, not merely one without nonzero eigenvalues. This is a severe structural constraint that could guide the search for counterexamples or their impossibility proofs.

**Catalog References:** `Algebra/InvariantSubspace/CompactOperators.lean::noInvariantSubspace_implies_no_compact_eigenvalue_commutant`, `Algebra/InvariantSubspace/CompactOperators.lean::EnfloReadPattern`

**Proof Strategy:** Formalize the Riesz–Schauder theorem (Direction 1), then compose with our obstruction theorem. The composition is: if K is compact, nonzero, and commutes with T, then K has a nonzero eigenvalue (Riesz–Schauder), and if T has no invariant subspace, this is impossible (our obstruction). Therefore K = 0.

**Domain Bridges:** Spectral theory → Counterexample theory → Banach space geometry

**Lineage:** Extends our EnfloReadPattern to its strongest possible form (total compact commutant triviality vs. spectral triviality).

**Ambition:** Grand challenge — depends on Direction 1 (Riesz–Schauder formalization).

---

## Direction 5: Quantum Channel Invariant Sectors

**Conjecture:** For a quantum channel Φ (completely positive trace-preserving map) on B(H) that commutes with a compact channel Ψ, the nonzero eigenspaces of Ψ provide invariant sectors for Φ, and these sectors correspond to decoherence-free subspaces of the quantum dynamics.

**Test:** Construct random quantum channels (as Kraus operator sums) on ℂⁿˣⁿ, compute compact channels in their commutant, and verify eigenspace preservation. Specifically: generate Φ = Σᵢ AᵢρAᵢ† and search for Ψ = Σⱼ BⱼρBⱼ† with ΦΨ = ΨΦ and Ψ compact-like (rapidly decaying singular values of the Choi matrix). Check whether eigenspaces of Ψ's Choi matrix are preserved by Φ. A refutation would require a commuting compact channel whose eigenspaces are not preserved by the other channel, which our theory shows is impossible at the operator level.

**Impact:** Would connect our formal invariant subspace theory to quantum error correction and decoherence-free subspace theory. The compact channel plays the role of a "coarse-graining" operation, and its invariant sectors become certified error-free subsystems.

**Catalog References:** `Algebra/InvariantSubspace/CompactOperators.lean::selfAdjoint_compact_mode_preservation`, `Algebra/InvariantSubspace/CompactOperators.lean::CompactlyGeneratedInvariant`

**Proof Strategy:** Lift our B(H) results to the space of operators on B(H) (superoperators). The key challenge is showing that compact channels correspond to compact operators on an appropriate operator space, and that commutation at the channel level implies commutation at the operator level.

**Domain Bridges:** Operator theory → Quantum information → Error correction → Condensed matter (topological order)

**Lineage:** Extends our selfAdjoint_compact_mode_preservation to the quantum channel setting. Connects to the broader program of using operator-theoretic methods in quantum information.

**Ambition:** Grand challenge — requires formalizing quantum channels and their relationship to operator algebras, which is largely missing from Mathlib.
