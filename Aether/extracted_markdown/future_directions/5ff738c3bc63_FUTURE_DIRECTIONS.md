# Future Directions: Stratified Interchange Algebras and Synthetic Homotopy Theory

## 1. Freudenthal Suspension Theorem for Suspended SIAs

The `SuspendedSIA` structure introduces suspension homomorphisms `susp : Carrier n → Carrier (n+1)` connecting adjacent levels. A natural conjecture is an algebraic analogue of the Freudenthal suspension theorem: under appropriate "connectivity" conditions on the SIA, the suspension map should become an isomorphism in a stable range.

**Conjecture**: Define a *k-connected SIA* as one where `Carrier n` is trivial (isomorphic to `Unit`) for `n < k`. Then for a k-connected Suspended SIA, the suspension map `susp n` is a bijection for `n ≤ 2k - 2`. This would give an algebraic version of the classical Freudenthal theorem without reference to topological spaces.

**Testable prediction**: For any concrete SIA built from the homotopy groups of a k-connected space (e.g., S³ is 2-connected, with π₃ = ℤ, π₄ = ℤ/2, ...), the suspension map should be surjective for n ≤ 2k - 1 and injective for n ≤ 2k - 2. This can be computationally verified for spheres using known homotopy group tables.

The key insight is that the algebraic axioms of the SIA — particularly the interchange law and the suspension homomorphism property — should be sufficient to derive stability results without topology, suggesting that Freudenthal is fundamentally an algebraic rather than topological theorem.

**Why now?** The formalized SIA structure provides the first clean axiomatization where this conjecture can be precisely stated and tested. Previous work on stable homotopy theory in Lean has been blocked by the absence of a suitable algebraic framework.

## 2. Classification of Finite SIAs and Connection to Group Cohomology

Every SIA with finite carriers determines a sequence of finite abelian groups (at each level) connected by homomorphisms. The classification of such sequences is closely related to derived functors and group cohomology.

**Conjecture**: The isomorphism classes of finite SIAs with `|Carrier n| ≤ N` for all n and `Carrier n` trivial for `n > k` are in bijection with elements of `∏_{i=0}^{k} Ab_{≤N}` modulo a natural equivalence relation induced by the homomorphism compatibility. More precisely, the "space" of SIA structures on a fixed sequence of abelian groups is a torsor for a product of Ext groups.

**Testable prediction**: Count the number of distinct SIA structures (up to isomorphism) on the graded abelian group `(ℤ/2, ℤ/2, ℤ/4, 0, 0, ...)`. The answer should equal the number of homomorphisms `ℤ/2 → ℤ/2` times the number of homomorphisms `ℤ/2 → ℤ/4`, i.e., 2 × 2 = 4. This can be verified computationally.

The key insight is that the SIA axioms (particularly the interchange law) impose no additional constraints beyond the group and homomorphism axioms — the interchange is automatically satisfied because all levels are abelian. This means SIA classification reduces entirely to classifying graded abelian groups with compatible homomorphisms.

**Why now?** The formalized `CommGroup` instance at each SIA level (our `instCommGroupCarrier`) directly connects to Mathlib's extensive group theory library, making automated enumeration feasible.

## 3. Higher Interchange Laws and n-Fold Monoidal Categories

The SIA's interchange law relates two binary operations. A natural generalization considers *n-fold interchange*, where n+1 binary operations mutually satisfy interchange. The Eckmann-Hilton argument shows that 2-fold interchange forces all operations to be equal and commutative. But what algebraic constraints does n-fold interchange impose beyond commutativity?

**Conjecture**: For n ≥ 2, having n binary operations on a set, all pairwise satisfying the interchange law with a common identity, forces all operations to be identical and commutative. Moreover, the resulting commutative monoid must satisfy the "higher commutativity" condition that every element commutes with every element in every possible parenthesization — which is already automatic for associative operations, but becomes non-trivial if associativity is weakened.

**Testable prediction**: Implement a brute-force search over all binary operations on `Fin n` for small n (say n ≤ 6). For each pair of operations with shared identity and interchange, verify they are equal. Then for triples of operations with pairwise interchange, verify no additional structure emerges beyond what pairwise EH gives. If additional structure appears, it would refute the conjecture.

The key insight is that the Eckmann-Hilton argument is "idempotent" — applying it twice should give nothing new — but this has never been formally verified in the n-fold setting.

**Why now?** Our formalization of the basic EH argument provides the infrastructure for mechanically iterating it, and `Fin n` computations are well-supported in Lean 4.

## 4. Delooping Theorems for SIAs

In homotopy theory, a connected space X is a "delooping" of its loop space ΩX, meaning X ≃ BΩX under appropriate conditions. Algebraically, this corresponds to the question: given an SIA truncated at level k, can we extend it to level k+1?

**Conjecture**: A Suspended SIA can always be extended by one level. Specifically, given `(Carrier 0, ..., Carrier k)` with all SIA axioms and suspension maps, there exists an extension to `Carrier (k+1)` with a suspension map `susp k : Carrier k → Carrier (k+1)` such that all axioms are preserved. However, the extension is not unique — the space of extensions is a torsor for `Aut(Carrier k)`.

**Testable prediction**: Take the SIA with `Carrier 0 = ℤ` and all higher levels trivial. There should be exactly one extension to level 1 (up to isomorphism): `Carrier 1 = {0}` with the trivial suspension. But if `Carrier 0 = ℤ` and `Carrier 1 = ℤ`, the number of valid suspension maps `susp 0 : ℤ → ℤ` should be countably infinite (one for each group homomorphism ℤ → ℤ, i.e., one for each integer).

The key insight is that the SIA axioms constrain extensions only through the homomorphism condition on suspension, so the "delooping space" is exactly `Hom(Carrier k, G)` for any abelian group G chosen as the new level.

**Why now?** The formalized `SuspendedSIA` structure and its kernel characterization (`suspKernel`) provide the technical foundation for stating and proving delooping results.

## 5. Derived Eckmann-Hilton for Non-Associative Operations

Our EH theorem assumes the binary systems have two-sided identity elements but does not assume associativity. A natural question: what happens if we weaken the identity axiom as well?

**Conjecture (Partial Eckmann-Hilton)**: If two binary operations on a set satisfy the interchange law and share a common *left* identity (but not necessarily right identity), then the operations agree on the image of the left identity operation. Specifically, for all `a`, `S.op e a = T.op e a`. But the operations need not be globally equal, and need not be commutative.

**Testable prediction**: Construct a type with two binary operations having a common left identity and interchange, but different right identity behavior. On `ℤ × ℤ`, define `S.op (a,b) (c,d) = (a+c, d)` with left identity `(0, ?)` — check if interchange can hold with a second operation having the same left identity but different right behavior. If no such example exists for types of size ≤ 8, the conjecture is likely false and full EH holds under weaker assumptions.

The key insight is that our proof of `eckmann_hilton_ops_eq` uses both left and right identity of both operations. If only left identity is needed, the theorem is stronger; if not, identifying exactly which identity axioms are necessary would sharpen the classical result.

**Why now?** The clean separation of axioms in our `BinarySystem` structure makes it easy to systematically weaken hypotheses and test which combinations suffice for the EH conclusion.
