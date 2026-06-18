# Future Directions: Tensor-Sorted Rewrite Systems for Scientific Computing

## Synthesis

The tensor-sorted rewrite calculus established in this work opens a systematic path from symbolic algebra to certified scientific computation. The three flagship theorems — rewrite soundness, energy invariance, and the polarization identity — form a minimal but complete nucleus for typed symbolic physics. Each future direction below extends this nucleus along a natural axis: richer algebraic structure (complex scalars, higher-order tensors), stronger normalization guarantees (confluence, termination), deeper physical semantics (Hamiltonians, variational principles), or computational scaling (sparse matrices, parallel rewriting). Together, these directions form a roadmap from the current three-sorted calculus to a full-spectrum certified tensor algebra capable of supporting finite element analysis, quantum chemistry preprocessing, and optimization pipeline verification.

The key insight unifying all directions is that **observable preservation** — the principle that physically meaningful quantities survive symbolic transformation — can be formally certified once the rewrite system has typed semantics. Every direction below builds on this insight by either enriching the class of observables or strengthening the class of transformations.

---

## Direction 1: Confluence and Unique Normal Forms

**Conjecture:** The 8-rule distributivity fragment defined in `TensorSortedRewrite.lean` is confluent modulo associativity-commutativity of scalar addition, i.e., any two reduction sequences from the same term yield syntactically equal normal forms up to AC-equivalence of `scalAdd`.

**Test:** Enumerate all tensor terms of depth ≤ 5 with 3 scalar, 3 vector, and 2 matrix variables. For each term, compute all possible reduction sequences (using breadth-first enumeration of rule applications). Check that all terminal forms are AC-equivalent. A single counterexample — two irreducible forms that differ by more than scalar-addition reordering — refutes the conjecture. Run over ℚ for exact arithmetic.

**Impact:** Confluence implies that normalization is deterministic up to AC, which is essential for using the rewrite system as a certified decision procedure. Without confluence, different simplification strategies could produce different "simplified" forms, undermining trust in automated preprocessing.

**Catalog References:** `Pythagorean/TensorSortedRewrite.lean` — `TensorRewrite`, `normStep`, `normStep_sound_*`.

**Proof Strategy:** Define a weight function that strictly decreases under each oriented rule (the current `tensorWeight` increases, but a redex-counting measure should decrease). Prove local confluence by showing all critical pairs are joinable. Apply Newman's lemma (termination + local confluence → confluence).

**Domain Bridges:** Term rewriting theory → optimization preprocessing → compiler correctness for scientific code.

**Lineage:** Extends Theorem 1 (one-step soundness) and Theorem 6 (normStep soundness) toward a complete decision procedure.

**Ambition:** Medium — requires careful critical pair analysis but builds on well-understood rewriting theory.

---

## Direction 2: Complex Inner Product Spaces and Quantum Observables

**Conjecture:** The tensor-sorted rewrite system extends to complex scalars `ℂ` with a sesquilinear pairing `⟨v, w⟩ = ∑ᵢ conj(vᵢ) · wᵢ`, and all 8 rewrite rules remain sound under this interpretation. Furthermore, the energy invariance theorem (Theorem 3) generalizes to Hermitian-matrix expectation values `⟨ψ| H |ψ⟩`, preserving the real-valuedness of observables.

**Test:** Implement the complex evaluator over `ℂⁿ` with `n ∈ {2, 4, 8}`. Generate 10,000 random Hermitian matrices and complex vectors. For each, normalize the expression `⟨ψ, H·ψ⟩` and verify: (a) the numerical value is preserved to machine precision, (b) the result is real-valued (imaginary part < 10⁻¹²). A single complex-valued result from a Hermitian observable refutes the real-valuedness claim.

**Impact:** This bridges the tensor rewrite system to finite-dimensional quantum mechanics, where `⟨ψ| H |ψ⟩` is the fundamental observable. Certified simplification of quantum expectation values would have applications in quantum chemistry (Hartree-Fock energy expressions), quantum information (entanglement witnesses), and quantum computing (circuit optimization for variational quantum eigensolvers).

**Catalog References:** `Pythagorean/TensorSortedRewrite.lean` — `energy`, `energy_add`, `energy_add_of_symmetric`, `dotProd_comm_of_symmetric`.

**Proof Strategy:** Replace `CommRing R` with `StarRing ℂ` (or `RCLike`). Replace `dotProd` with the sesquilinear form. Modify `dotProd_smul_left` to use `starRingEnd` (conjugation). The key challenge is that `⟨a•v, w⟩ = conj(a) · ⟨v, w⟩`, not `a · ⟨v, w⟩`. This requires modifying the `dot_smulVec_left` rewrite rule to track conjugation.

**Domain Bridges:** Linear algebra → quantum mechanics → quantum computing → quantum chemistry.

**Lineage:** Direct extension of Theorems 3-5 to the complex/Hermitian setting.

**Ambition:** Grand challenge — requires significant new infrastructure (star-rings, sesquilinearity) and breaks the symmetry of the current rewrite rules.

---

## Direction 3: Sparse Matrix Structure Preservation

**Conjecture:** For sparse matrices (with at most `s` nonzero entries per row, where `s ≪ n`), the normalized form produced by the distributivity rewrite system preserves sparsity structure: if all matrix variables in a term are `s`-sparse, then the semantic matrix produced by evaluating any intermediate or final term has at most `s` nonzero entries per row.

**Test:** Generate 5,000 random sparse matrices (CSR format) with `n = 100`, `s = 5`. Build random tensor terms of depth 4. Normalize and evaluate, checking the sparsity pattern of all intermediate matrix results. A single dense intermediate matrix refutes the conjecture. Compute the sparsity ratio (nnz/n²) before and after normalization.

**Impact:** Sparsity preservation is critical for scalability. Finite element stiffness matrices, graph Laplacians, and many physics operators are sparse. If normalization destroys sparsity, the certified simplification becomes computationally useless for large problems. Proving sparsity preservation would make the rewrite system practical for real-world scientific computing.

**Catalog References:** `Pythagorean/TensorSortedRewrite.lean` — `TensorRewrite`, `evalMat`, `evalVec`.

**Proof Strategy:** Add a `Sparse` predicate on matrix terms and prove that each rewrite rule preserves it. The key insight: distributivity rules never multiply matrices together (no `matMul` in the current fragment), so sparsity of individual matrices is preserved through addition and scalar multiplication.

**Domain Bridges:** Numerical linear algebra → finite elements → graph algorithms → scientific computing at scale.

**Lineage:** Extends Theorem 1 with structural properties beyond semantic equality.

**Ambition:** Medium — the current fragment avoids matrix-matrix multiplication, which is the main source of fill-in.

---

## Direction 4: Higher-Order Tensor Calculus with Einstein Summation

**Conjecture:** The three-sorted calculus extends to an `n`-sorted system with sorts `Tensor(k)` for `k = 0, 1, 2, ...` (where `k` is the tensor order), equipped with contraction operations that generalize dot product and matrix-vector multiplication. The distributivity rewrite rules generalize to a universal schema: contraction distributes over addition at each pair of orders.

**Test:** Implement a 4-sorted system (orders 0-3) and verify soundness for all pairwise contraction rules (6 pairs) on 1,000 random terms each. Check that the energy identity `E(T, v) = contract(v, contract(T, v))` holds for order-2 tensors `T` and order-1 vectors `v`, and that analogous identities hold for higher-order contractions. A single semantic mismatch refutes the extension.

**Impact:** Real-world tensor computations (general relativity, continuum mechanics, machine learning) involve tensors of order 3 and above. Einstein summation notation is the lingua franca of theoretical physics. A formally verified rewrite system for Einstein summation would be a breakthrough in certified scientific computing, enabling symbolic optimization of tensor network contractions, finite element assembly kernels, and deep learning tensor operations.

**Catalog References:** `Pythagorean/TensorSortedRewrite.lean` — `TensorSort`, `TensorTerm`, `TensorRewrite`.

**Proof Strategy:** Parameterize `TensorSort` by `ℕ` (tensor order). Define contraction as a binary operation `contract : Tensor(j+k) → Tensor(k) → Tensor(j)`. Prove distributivity of contraction over addition by induction on tensor order, using the current matrix-vector case as the base.

**Domain Bridges:** Tensor algebra → differential geometry → general relativity → machine learning → finite elements.

**Lineage:** Extends the entire framework from 3 sorts to infinitely many.

**Ambition:** Grand challenge — requires a fundamentally new inductive structure for sorts and terms, plus careful handling of index types.

---

## Direction 5: Certified Finite Element Assembly Pipeline

**Conjecture:** The tensor-sorted rewrite system, combined with the energy invariance theorem, provides a formally verified preprocessing step for finite element assembly: if element stiffness matrices `K₁, ..., Kₘ` are assembled into a global stiffness matrix `K = ∑ Kᵢ` and the displacement is decomposed as `u = ∑ uⱼ`, then the total strain energy `E(K, u)` can be decomposed into element contributions plus coupling terms, and this decomposition is preserved by normalization.

**Test:** Implement a 2D triangular mesh FEM with 100 elements. Build the symbolic energy expression `⟨u, K·u⟩` where `K = K₁ + ... + K₁₀₀`. Normalize the expression and verify: (a) the numerical energy matches direct computation to 10 decimal places, (b) the normalized form exposes element-wise energies, (c) the wall-clock time for symbolic normalization is within 10× of direct numerical evaluation for meshes up to 1000 elements. Failure of (a) refutes soundness; failure of (c) indicates practical infeasibility.

**Impact:** Finite element analysis is the backbone of computational engineering. A formally verified pipeline from symbolic assembly to numerical evaluation would provide unprecedented confidence in structural analysis codes used for safety-critical applications (bridges, aircraft, nuclear reactors).

**Catalog References:** `Pythagorean/TensorSortedRewrite.lean` — `energy_add`, `energy_invariant_of_rewrites`, `tensorRewrites_sound_*`.

**Proof Strategy:** The energy expansion theorem (Theorem 4) already handles the case of two terms. Prove the multi-term generalization by induction on the number of summands. The coupling-term structure follows from the symmetric specialization (Theorem 5) when stiffness matrices are symmetric.

**Domain Bridges:** Formal verification → structural engineering → computational mechanics → safety-critical systems.

**Lineage:** Direct application of Theorems 3, 4, and 5 to a concrete engineering domain.

**Ambition:** Medium-high — the formal mathematics is already present; the challenge is scaling the symbolic system to realistic problem sizes and connecting to existing FEM codes.
