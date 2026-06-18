# Future Directions

## Synthesis

The theorems established in this work — solvability transfer under group isomorphism, the S₅ obstruction, the polynomial non-solvability theorem, and the Galois connection — form a verified pipeline from group theory through field theory to order theory. Each future direction extends one or more links in this pipeline, either deepening the group-theoretic analysis, broadening the arithmetic detection methods, or exploiting the cross-domain bridge to lattice theory. The grand challenges aim to formalize complete algorithms for Galois group computation and to attack the inverse Galois problem, while the solid extensions build directly on the proven theorems to handle new polynomial families and certificate types.

---

## Direction 1: Formal Modular Galois Group Computation

**Conjecture:** For every irreducible quintic f ∈ ℤ[X], the Galois group Gal(f/ℚ) can be determined by examining factorization patterns of f modulo at most 100 primes, combined with the discriminant.

**Test:** Implement a certified algorithm that, given f, computes factorization patterns mod p for p ≤ 541 (the 100th prime) and outputs one of: S₅, A₅, D₅, F₂₀, ℤ/5ℤ. Verify correctness against known databases of quintic Galois groups (e.g., the LMFDB). A counterexample — a quintic where 100 primes are insufficient — would disprove the conjecture.

**Impact:** This would complete the arithmetic → group-theory link in the detection pipeline, making the formal obstruction theorem applicable without external computation.

**Catalog References:** `Algebra/GaloisBeyondAbelRuffini.lean` (ResolventCertificate, polynomial_not_solvable_of_galGroup_equiv_S5)

**Proof Strategy:** Formalize Dedekind's theorem on Frobenius elements, then prove the subgroup classification theorem for transitive subgroups of S₅. The Chebotarev density theorem guarantees that each cycle type occurs for some prime, so finitely many primes suffice.

**Domain Bridges:** Number theory ↔ Group theory ↔ Computational algebra

**Lineage:** Extends `polynomial_not_solvable_of_galGroup_equiv_S5` by removing the Galois group identification as an external input.

**Ambition:** Grand challenge — would create the first fully formal, end-to-end certified impossibility proof for specific polynomials.

---

## Direction 2: Transitive Subgroup Classification for S₅

**Conjecture:** Every transitive subgroup of S₅ that contains an element of order 5 and an element of order 2 whose cycle type is (2,1,1,1) is equal to S₅.

**Test:** Enumerate all transitive subgroups of S₅ (there are exactly 5 conjugacy classes: ℤ/5ℤ, D₅, F₂₀, A₅, S₅) and verify computationally that only S₅ satisfies both conditions. A formal proof in the proof assistant would establish this rigorously. The conjecture is falsifiable: if any proper transitive subgroup contains both an element of order 5 and a (2,1,1,1)-type element, the conjecture fails.

**Impact:** This is the key finite-group lemma needed to close the gap between modular factorization data and Galois group identification.

**Catalog References:** `Algebra/GaloisBeyondAbelRuffini.lean` (not_radicalSolvable_of_mulEquiv_S5)

**Proof Strategy:** Use `Decidable` instances on `Fin 5` to reduce the theorem to a finite computation. Alternatively, prove it via the classification: ℤ/5ℤ has no element of order 2, D₅ has no (2,1,1,1) cycle type, F₂₀ has no transposition, A₅ has no odd permutation.

**Domain Bridges:** Finite group theory ↔ Combinatorics ↔ Computational verification

**Lineage:** Directly supports Direction 1 and bridges the gap between ResolventCertificate and the S₅ identification.

**Ambition:** Solid extension — the statement is known to be true and the proof is finite.

---

## Direction 3: Galois Connection Functoriality and the Inverse Galois Problem

**Conjecture:** The Galois connection established in `intermediateField_subgroup_galoisConnection` is natural with respect to field extensions: for a tower K ⊆ L ⊆ M of Galois extensions, the Galois connections for M/K, M/L, and L/K are related by a commutative diagram of adjunctions.

**Test:** Formalize the naturality square for a specific tower (e.g., ℚ ⊆ ℚ(√2) ⊆ ℚ(√2, √3)) and verify that the diagram commutes. Extend to arbitrary finite Galois towers. A counterexample in the non-Galois case would bound the generality.

**Impact:** This would provide the formal infrastructure for inverse Galois theory: given a group G, construct a field extension whose Galois group is G by building it as a tower of cyclic extensions.

**Catalog References:** `Algebra/GaloisBeyondAbelRuffini.lean` (intermediateField_subgroup_galoisConnection), `Algebra/ProofSpectra/Core.lean` (galois_connection_theory_variety)

**Proof Strategy:** Use the order-theoretic properties of Galois connections (composition of Galois connections is a Galois connection) together with the fundamental theorem of Galois theory for each step of the tower.

**Domain Bridges:** Field theory ↔ Order theory ↔ Category theory

**Lineage:** Extends `intermediateField_subgroup_galoisConnection` from single extensions to towers.

**Ambition:** Grand challenge — functorial Galois theory is at the frontier of formal mathematics.

---

## Direction 4: Radical Extension Tower Certificates

**Conjecture:** For every solvable quintic f ∈ ℚ[X] with Galois group G ⊆ S₅, there exists a radical extension tower of height at most 5 that splits f, and this tower can be constructed algorithmically from the derived series of G.

**Test:** For each solvable transitive subgroup of S₅ (ℤ/5ℤ, D₅, F₂₀), construct explicit radical towers for representative polynomials. For example, verify that x⁵ − 2 splits over ℚ(2^(1/5), ζ₅) and formalize the tower ℚ ⊂ ℚ(ζ₅) ⊂ ℚ(2^(1/5), ζ₅). The height bound of 5 is falsifiable.

**Impact:** Completes the solvability side of the pipeline: not only can we certify non-solvability, but for solvable cases we can produce explicit radical expressions.

**Catalog References:** `Algebra/GaloisBeyondAbelRuffini.lean` (radicalSolvable_of_certificate, DerivedSeriesCertificate)

**Proof Strategy:** Use the derived series certificate to construct the tower: each step G⁽ⁱ⁾/G⁽ⁱ⁺¹⁾ is abelian, hence corresponds to a radical extension (by Kummer theory if the base field contains enough roots of unity).

**Domain Bridges:** Field theory ↔ Constructive algebra ↔ Symbolic computation

**Lineage:** Builds on `DerivedSeriesCertificate` and `radicalSolvable_of_certificate` to produce constructive witnesses.

**Ambition:** Solid extension — the mathematics is classical but formalization requires substantial infrastructure.

---

## Direction 5: Non-Solvability Beyond Quintics — Certified Obstruction for Degree n ≥ 5

**Conjecture:** For every n ≥ 5, there exists an explicit polynomial fₙ ∈ ℤ[X] of degree n such that Gal(fₙ/ℚ) = Sₙ, with the identification certifiable by modular factorization data using at most O(n²) primes.

**Test:** For n = 6, 7, 8, construct candidate polynomials (e.g., xⁿ − x − 1) and compute modular factorization patterns. Verify that the Galois group is Sₙ using cycle-type analysis. The O(n²) bound is falsifiable.

**Impact:** Extends the detection pipeline from quintics to arbitrary degree, creating a universal impossibility engine.

**Catalog References:** `Algebra/GaloisBeyondAbelRuffini.lean` (not_radicalSolvable_Sn_of_five_le)

**Proof Strategy:** The theorem `not_radicalSolvable_Sn_of_five_le` already handles the group-theoretic obstruction for n ≥ 5. The challenge is the Galois group identification: generalize the transitive subgroup theorem from S₅ to Sₙ. A key tool is Jordan's theorem: a primitive permutation group of degree n containing a p-cycle for some prime p ≤ n − 3 is either Aₙ or Sₙ.

**Domain Bridges:** Group theory ↔ Number theory ↔ Analytic number theory (Chebotarev density)

**Lineage:** Directly generalizes the quintic pipeline to all degrees ≥ 5.

**Ambition:** Grand challenge — requires formalizing deep results in finite group theory (Jordan's theorem, primitive permutation groups).
