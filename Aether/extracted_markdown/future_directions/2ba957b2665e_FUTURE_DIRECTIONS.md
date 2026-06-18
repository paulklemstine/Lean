# Future Directions: Matroid Minor Theory and Obstruction Spectra

## Synthesis

This research cycle established a rigorous, machine-verified framework for studying matroid minor theory through obstruction spectra. We built on Mathlib's `Matroid.IsMinor` infrastructure to formalize minor ideals, excluded minors, and the obstruction spectrum, proving six key structural theorems: duality preserves minors, dual involution on ideals, dual palindromy for self-dual ideals, the antichain theorem, dual generation, and spectral partition/bound properties.

Three cross-domain connections emerged as particularly promising: (1) the palindromy of obstruction spectra under matroid duality connects to the rich existing theory of self-dual codes in coding theory — self-dual codes over GF(q) produce self-dual matroid classes whose excluded minors must come in dual pairs; (2) the sub-additive intersection bound on spectra links the combinatorial complexity of matroid classes to lattice-theoretic operations, suggesting that the minor ideal lattice has spectral invariants analogous to those in operator algebra; and (3) the antichain theorem connects to Dilworth's theorem and the theory of well-quasi-orderings, providing a bridge between finite combinatorics and infinite order theory.

The direction with highest breakthrough potential is Direction 1 (Spectral Rigidity), because a proof that the obstruction spectrum uniquely determines a minor-closed class (up to some equivalence) would transform the GGW conjecture from a finiteness question into a classification problem with computable invariants. The existing palindromy and antichain results are the first structural constraints on possible spectra; much sharper constraints should hold for representable matroids.

---

### Direction 1: Spectral Rigidity for Representable Matroid Classes

**Conjecture**: For GF(q)-representable matroids with q prime, if two minor-closed classes C₁ and C₂ have the same obstruction spectrum (σ_{C₁} = σ_{C₂} as functions ℕ∞ → ℕ), then C₁ and C₂ agree on all matroids of rank ≤ 2q.

**Test**: Enumerate all minor-closed classes of binary matroids (GF(2)) with at most 3 excluded minors. For each pair with identical spectra, check whether they agree on small matroids. A single counterexample refutes the conjecture; universal agreement supports it.

**Impact**: If true, the obstruction spectrum becomes a computable classifier for minor-closed classes, reducing the GGW conjecture to a spectral finiteness question. If false, the counterexample reveals which structural features are *not* captured by the spectrum, guiding the search for richer invariants.

**Catalog References**: `Bridges/MatroidMinorSpectrum/Defs.lean` (dual_palindromy, obstructionSet_antichain), `Bridges/MatroidMinorSpectrum/Spectrum.lean` (spectrum_sum_eq_total)

**Proof Strategy**: Start with binary matroids (q=2). Use the computational enumeration of binary matroid minors (feasible up to ground set size ~12). For each pair of minor-closed classes with matching spectra, check agreement on rank ≤ 4 matroids. Formalize any discovered equivalences in Lean.

**Domain Bridges**: Matroid theory ↔ Coding theory (self-dual codes give self-dual classes) ↔ Finite geometry (GF(q)-representability is a geometric property)

**Lineage**: Builds on dual_palindromy and obstructionSet_antichain from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Growth Rate–Spectrum Correspondence

**Conjecture**: If a minor-closed class C of matroids has growth rate g(C) = k (meaning the maximum number of elements in a rank-r member of C is Θ(r^k)), then the obstruction spectrum σ_C satisfies: the support of σ_C is contained in ranks ≤ f(k) for some computable function f.

**Test**: For the known classes with computed growth rates (graphic: k=2; GF(q)-representable: k=2; binary non-graphic: k=2), verify that all excluded minors have bounded rank. The Growth Rate Theorem guarantees k ∈ {1, 2, q^n - 1, ∞}; test whether the corresponding spectral supports are bounded.

**Impact**: This would provide a quantitative link between the density structure of a matroid class and the complexity of its excluded minor characterization. It would also give effective upper bounds on the rank of excluded minors, which are currently unknown in general.

**Catalog References**: `Bridges/MatroidMinorSpectrum/Spectrum.lean` (spectrum_le_total, spectrum_sum_eq_total)

**Proof Strategy**: Use the Growth Rate Theorem (Geelen-Kabell-Kung-Whittle) as a black box. For a class with growth rate k, show that any excluded minor of rank > f(k) would violate the growth rate bound by containing too many elements. The key lemma: an excluded minor of rank r in a class with growth rate k must have at most O(r^k) elements, but its minimality (every proper minor is in the class) forces it to have at least Ω(r^(k+1)) elements, a contradiction for large r.

**Domain Bridges**: Matroid density theory ↔ Spectral analysis ↔ Extremal combinatorics

**Lineage**: Extends the spectral framework from this cycle with growth rate bounds.

**Ambition**: grand_challenge

---

### Direction 3: Computational Enumeration of Minor Ideal Lattice Fragments

**Conjecture**: The lattice of minor ideals of binary matroids, restricted to those with at most 5 excluded minors, has a computable Hasse diagram with at most 50 elements.

**Test**: Enumerate all binary matroids on ≤ 8 elements. Compute the minor relation. For each antichain A of size ≤ 5, determine the minor ideal excluded by A. Count distinct ideals and compute containment.

**Impact**: A concrete enumeration of the minor ideal lattice fragment would provide the first empirical data for testing spectral rigidity and would reveal structural patterns in how minor-closed classes are organized.

**Catalog References**: `Bridges/MatroidMinorSpectrum/Defs.lean` (infIdeal, generated, obstructionSet_antichain)

**Proof Strategy**: Implement the enumeration in Python/SageMath. Represent binary matroids as matrices over GF(2). Compute minors by deletion/contraction. Build the antichain lattice. Verify key structural properties in Lean.

**Domain Bridges**: Computational algebra ↔ Lattice theory ↔ Matroid enumeration

**Lineage**: Extends the lattice structure from this cycle with computational data.

**Ambition**: extension

---

### Direction 4: Palindromy Refinement for Finite Matroids

**Conjecture**: For a self-dual minor ideal I on a finite ground type with n elements, the obstruction spectrum satisfies σ(r) = σ(n - r) for all r ≤ n, and σ(r) = 0 for r > n.

**Test**: For the known self-dual classes (graphic, regular, binary), verify the palindromy equation numerically. The key examples are: graphic matroids on K₅ (n=10), regular matroids with excluded minors F₇, F₇*, U₂,₄.

**Impact**: This refines the dual palindromy theorem from a qualitative statement (excluded minors come in pairs) to a quantitative one (the spectrum is a palindrome). Combined with the antichain theorem, this constrains the possible shapes of obstruction spectra.

**Catalog References**: `Bridges/MatroidMinorSpectrum/Defs.lean` (dual_palindromy, isSelfDual_iff)

**Proof Strategy**: Work with finite matroids on `Fin n`. Show that duality maps rank-r matroids to rank-(n-r) matroids. Combined with dual_palindromy, this gives σ(r) = σ(n-r). The key technical challenge is relating `eRank` to the ground set size, which requires finiteness assumptions.

**Domain Bridges**: Finite matroid theory ↔ Coding theory (weight enumerators of self-dual codes are palindromic) ↔ Combinatorial optimization

**Lineage**: Directly refines dual_palindromy from this cycle.

**Ambition**: extension

---

### Direction 5: Category-Theoretic Minor Ideal Functoriality

**Conjecture**: The assignment α ↦ MinorIdealLattice(α) extends to a contravariant functor from the category of finite sets with injections to the category of complete lattices with lattice homomorphisms.

**Test**: For injections f : α ↪ β, define the pushforward of a minor ideal by extending matroids via direct sum with loops. Verify that this preserves lattice operations (intersection, union) and commutes with the duality involution.

**Impact**: A functorial perspective on minor ideals would connect matroid theory to categorical combinatorics and could reveal new structural theorems via abstract nonsense (e.g., limits and colimits of minor ideals).

**Catalog References**: `Bridges/MatroidMinorSpectrum/Defs.lean` (MinorIdeal, dualIdeal, infIdeal), `Catalog/Bridges/PrimeSpectrum.lean` (prime_spectrum_invariant_of_lattice_equiv)

**Proof Strategy**: Define the functor on objects as the complete lattice of minor ideals. On morphisms, use matroid restriction along injections. Verify the functorial axioms (identity, composition) in Lean.

**Domain Bridges**: Category theory ↔ Matroid theory ↔ Lattice theory ↔ Universal algebra (lattice of varieties)

**Lineage**: Extends the lattice structure from this cycle with categorical machinery.

**Ambition**: extension
