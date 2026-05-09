# MASTER FUTURE DIRECTIONS — Accumulated Research Wisdom

*Last updated: 2026-05-09 17:39*

## Breakthrough Opportunities (ranked by impact)

### 1. Krull Dimension as Cryptographic Security Parameter

- **Theorem Statement**: For any Noetherian ring R of Krull dimension d, any ascending chain of ideals arising from a cryptographic protocol stabilizes in at most f(d) steps, where f is an explicit function of d.
- **Proof Strategy**:
  1. Each strict ideal inclusion increases the height of the chain by ≥ 1.
  2. The height is bounded by the Krull dimension d.
  3. Therefore at most d strict inclusions are possible.
  - Key lemmas needed: `Ideal.height_le_krullDim`, `strict_inclusion_increases_height`
- **Why This Is Revolutionary**: Gives the first *quantitative* termination bound for lattice key generation protocols, moving from "eventually terminates" to "terminates in O(d) rounds." This connects an algebraic invariant (Krull dimension) directly to a cryptographic efficiency parameter.
- **Catalog Leverage**: Build on `acc_protocol_termination`, `no_infinite_strict_ascending_chain`
- **Research Mode**: prove
- **Estimated Depth**: 4

### 2. Constructive Gröbner Basis Key Validation

- **Theorem Statement**: For R = K[X₁,...,Xₙ] (K a computable field) and I = ⟨f₁,...,fₖ⟩, ideal membership r ∈ I is decidable in EXPSPACE, and the normal form NF(r, G) with respect to a Gröbner basis G provides a canonical representative in R/I.
- **Proof Strategy**:
  1. Formalize Buchberger's algorithm for Gröbner basis computation.
  2. Prove termination using the Noetherian property of the monomial order.
  3. Prove that NF(r, G) = 0 ↔ r ∈ I.
  - Key lemmas: `MvPolynomial.wellFounded_lt`, Dickson's lemma
- **Why This Is Revolutionary**: Gives a constructive decision procedure for ideal membership, turning the abstract finite-generation guarantee into an algorithm. This directly applies to key validation in NTRU and multivariate lattice schemes.
- **Catalog Leverage**: Build on `multivariate_key_certification`, `mvPolynomial_noetherian`
- **Research Mode**: formalize
- **Estimated Depth**: 5

### 3. Module-LWE Certification via Noetherian Modules

- **Theorem Statement**: For a Noetherian ring R and finitely generated R-module M, every ascending chain of submodules stabilizes, and every submodule is finitely generated. The quotient M/N inherits Noetherian.
- **Proof Strategy**:
  1. Apply `IsNoetherian` directly (already in Mathlib for modules).
  2. Formalize the module-theoretic certification framework parallel to the ideal case.
  3. Instantiate for free modules R^n used in Module-LWE.
- **Why This Is Revolutionary**: Extends certification from Ring-LWE (ideals in R) to Module-LWE (submodules of R^n), covering the full CRYSTALS-Kyber parameter space. Module-LWE is considered more secure than Ring-LWE for the same dimension.
- **Catalog Leverage**: Build on `noetherian_certification_completeness`, `certification_pipeline`
- **Research Mode**: prove
- **Estimated Depth**: 3

### 4. Primary Decomposition for Multi-Party Key Analysis

- **Theorem Statement**: Every ideal in a Noetherian ring admits a primary decomposition I = Q₁ ∩ Q₂ ∩ ... ∩ Qₖ, where each Qⱼ is primary. The associated primes Ass(R/I) = {√Q₁, ..., √Qₖ} characterize the "attack surfaces" of the cryptographic key space.
- **Proof Strategy**:
  1. Use Lasker-Noether theorem (should exist in Mathlib as `Ideal.exists_primary_decomposition` or similar).
  2. Interpret each primary component as an independent "attack channel."
  3. Show that security reduces to hardness of each primary component independently.
- **Why This Is Revolutionary**: Decomposes the security of a lattice scheme into independent components, enabling modular security analysis. Each primary component corresponds to a distinct attack strategy.
- **Catalog Leverage**: Build on `key_space_intersection_membership`, `finitely_generated_key_certification`
- **Research Mode**: formalize
- **Estimated Depth**: 4

### 5. Noetherian Normalization and Lattice Reduction

- **Theorem Statement**: (Noether normalization) For a finitely generated K-algebra R, there exist algebraically independent elements x₁,...,xₐ ∈ R such that R is integral over K[x₁,...,xₐ]. The degree d equals the Krull dimension.
- **Proof Strategy**:
  1. Formalize Noether normalization lemma.
  2. Connect the algebraically independent generators to a "reduced basis" in the lattice sense.
  3. Show that lattice reduction (LLL/BKZ) finds approximations to the normalization.
- **Why This Is Revolutionary**: Creates a direct mathematical bridge between algebraic normalization (commutative algebra) and lattice reduction (computational algebra/cryptography). This could lead to new lattice reduction algorithms guided by algebraic structure.
- **Catalog Leverage**: Build on `polynomial_quotient_certification`, `multivariate_key_certification`
- **Research Mode**: discover
- **Estimated Depth**: 5

---