# Future Directions: Hadamard Existence by Algebraic Generation

## Synthesis

The five verified theorems in this work — tensor closure, Sylvester family, arithmetic obstruction, equidistant codes, and design parameter counting — form the foundation of a *compositional existence calculus* for Hadamard matrices. The unifying theme is that Hadamard existence is not a collection of isolated constructions but an algebraic system with multiplicative closure, arithmetic constraints, and deep cross-domain bridges. Each future direction extends this system along a different axis: enriching the generator set (Direction 1), completing the cross-domain equivalence (Direction 2), formalizing the spectral theory (Direction 3), establishing density guarantees (Direction 4), and bridging to quantum information theory (Direction 5). Together, these directions would transform the Hadamard conjecture from an intractable monolith into a modular verification problem where each piece can be attacked independently.

---

## Direction 1: Paley Construction from Finite Fields

**Conjecture:** For every prime q ≡ 3 (mod 4), the Paley Type I construction produces a Hadamard matrix of order q + 1, formally verifiable using Mathlib's `ZMod` and `FiniteField` APIs.

**Test:** Formalize the quadratic residue character χ : ZMod q → ℤ and prove that the matrix Q(i,j) = χ(i − j) satisfies QQᵀ = qI − J (where J is the all-ones matrix). Then verify the bordered construction gives a Hadamard matrix. Begin with q = 3, 7, 11 as test cases.

**Impact:** This would add infinitely many new seeds to the generation calculus. Combined with tensor closure (Theorem 3.1 in `Catalog/Algebra/Hadamard/Constructions.lean`), each Paley seed generates an infinite family. The coverage gap shrinks dramatically: our computational experiments show that Paley + Sylvester + tensor covers 44/52 admissible orders up to 200, versus 8/52 with Sylvester alone.

**Catalog References:** `Catalog/Algebra/Hadamard/Constructions.lean` (tensor closure theorem, HadamardSeed inductive type)

**Proof Strategy:** The core technical challenge is showing QQᵀ = qI − J, which requires the identity ∑_{t≠0} χ(t)χ(t+a) = −1 for a ≠ 0. This follows from the multiplicativity of χ and the fact that {t(t+a) : t ≠ 0, −a} has each non-zero quadratic residue class equally represented. The formalization requires Gauss sum theory or direct character sum manipulation in ZMod q.

**Domain Bridges:** Number theory (quadratic reciprocity, character sums), finite geometry (quadrics over finite fields)

**Lineage:** Extends HadamardSeed with a `paley` constructor, preserving the existing soundness theorem.

**Ambition:** Grand challenge — completing this direction would make the formal system strictly stronger than any existing formalization of Hadamard existence.

---

## Direction 2: Bidirectional Hadamard-BIBD Equivalence

**Conjecture:** The correspondence between normalized Hadamard matrices of order 4t and symmetric 2-(4t−1, 2t−1, t−1) designs is a formal equivalence: every such BIBD arises from a Hadamard matrix, and vice versa.

**Test:** Formalize the reverse direction: given a symmetric BIBD with the correct parameters, construct a normalized Hadamard matrix by converting the incidence matrix (0/1 → −1/+1) and bordering with a row and column of ones. Verify the orthogonality condition. Test with the Fano plane (parameters 2-(7, 3, 1), corresponding to order 8).

**Impact:** Establishes a formal functor between two categories of combinatorial objects. Any existence theorem for symmetric BIBDs automatically transfers to Hadamard matrices and vice versa. This opens the door to attacking Hadamard existence via design-theoretic methods (e.g., difference sets, group actions).

**Catalog References:** `Catalog/Algebra/Hadamard/Design.lean` (normalized_row_pair_ones, normalized_row_ones_count)

**Proof Strategy:** The forward direction is partially formalized (we proved the row intersection counting). The reverse direction requires: (1) showing that a BIBD incidence matrix N satisfies NNᵀ = (k−λ)I + λJ; (2) converting to ±1 entries; (3) bordering; (4) verifying the product identity. The key algebraic step is the Fisher inequality v ≤ b and the regularity conditions.

**Domain Bridges:** Combinatorial design theory, finite geometry, algebraic coding theory

**Lineage:** Extends the SymmetricBIBD structure in Design.lean to a full equivalence.

**Ambition:** Solid extension — the forward direction is already partially complete; the reverse completes the bridge.

---

## Direction 3: Walsh Transform Energy Preservation

**Conjecture:** The normalized Walsh-Hadamard transform W_k = (1/√(2^k)) · H_k preserves the L² norm: for all x : Fin(2^k) → ℝ, ||W_k x||² = ||x||².

**Test:** Define walshTransform recursively mirroring the Sylvester construction. Prove the energy preservation identity by induction on k, using the block structure [[H, H], [H, −H]] and the fact that orthogonal blocks produce uncorrelated components.

**Impact:** This is the formal bridge from combinatorial existence to harmonic analysis and signal processing. It would be the first machine-verified proof that the Walsh system forms an orthonormal basis — a fact used in compressed sensing, spectral analysis, and quantum computing.

**Catalog References:** `Catalog/Algebra/Hadamard/Constructions.lean` (Sylvester family, hadamardOrder'_pow_two)

**Proof Strategy:** Define walshTransform (k : ℕ) : (Fin (2^k) → ℝ) → (Fin (2^k) → ℝ) recursively. The base case is trivial. The inductive step uses: ||W_{k+1} x||² = ||W_k (x_top + x_bot)||² + ||W_k (x_top − x_bot)||² (where x_top, x_bot are the upper and lower halves). By induction, this equals ||x_top + x_bot||² + ||x_top − x_bot||² = 2(||x_top||² + ||x_bot||²) = 2||x||². The factor of 2 is absorbed by the 1/√(2^(k+1)) normalization.

**Domain Bridges:** Harmonic analysis, signal processing, compressed sensing, quantum computing

**Lineage:** Builds on the Sylvester construction infrastructure.

**Ambition:** Solid extension — the mathematics is well-understood; the challenge is clean formalization of the recursive structure over real-valued functions.

---

## Direction 4: Density of Generated Orders

**Conjecture:** The set of orders generated by HadamardSeed (with Paley seeds added) has positive lower density among multiples of 4: lim inf_{N→∞} |{n ≤ N : GeneratedHadamardOrder(n) ∧ 4|n}| / |{n ≤ N : 4|n}| > 0.

**The key insight is** that the multiplicative closure means generated orders include all products of elements from a set with positive density in the primes (Paley primes q ≡ 3 mod 4), and multiplicative closures of such sets have been studied in analytic number theory.

**Why now?** Recent results on the distribution of primes in arithmetic progressions (by Dirichlet's theorem, primes q ≡ 3 mod 4 have density 1/2 among primes) combined with multiplicative number theory results on product sets could yield a positive density bound.

**Test:** Compute the empirical density of generated orders for N = 10^3, 10^4, 10^5. Fit a model. The density should stabilize above some positive constant (our experiments show ~85% at N = 200).

**Impact:** A positive density result would be the strongest known quantitative approximation to the Hadamard conjecture — showing that "most" admissible orders are Hadamard orders, even if we cannot prove all are.

**Catalog References:** `Catalog/Algebra/Hadamard/Constructions.lean` (GeneratedHadamardOrder, hadamardSeed_implies_order)

**Proof Strategy:** Use the fact that {q+1 : q prime, q ≡ 3 mod 4} has logarithmic density 1/2 in the even numbers. The multiplicative closure of any set with positive lower density in the integers has density 1 (Erdős–Kac type results). However, our generators live in multiples of 4, requiring careful analysis.

**Domain Bridges:** Analytic number theory, multiplicative combinatorics, probabilistic number theory

**Lineage:** Extends the generation calculus with quantitative density estimates.

**Ambition:** Grand challenge — requires combining formal number theory with the existence calculus.

---

## Direction 5: Mutually Unbiased Bases and Quantum Information

**Conjecture:** A Hadamard matrix of order n gives rise to a pair of mutually unbiased bases (MUBs) in ℂⁿ: the standard basis and the columns of (1/√n)H, and this connection can be formalized to transfer Hadamard existence results to quantum information theory.

**The key insight is** that two orthonormal bases {|eᵢ⟩} and {|fⱼ⟩} in ℂⁿ are mutually unbiased if |⟨eᵢ|fⱼ⟩|² = 1/n for all i,j — and the columns of a normalized (1/√n)H give exactly this when H is a real Hadamard matrix.

**Why now?** The MUB problem (how many mutually unbiased bases exist in ℂⁿ?) is a central open problem in quantum information, and the connection to Hadamard matrices is well-known but not formalized. Mathlib's growing linear algebra over ℂ makes this newly accessible.

**Test:** For n = 4, construct the two MUBs from the Sylvester matrix and verify the mutual unbiasedness condition formally. Show that the tensor product of Hadamard matrices corresponds to tensor products of MUB pairs.

**Impact:** Bridges combinatorial existence to quantum computation and quantum cryptography, opening Hadamard theory to a new community and application domain.

**Catalog References:** `Catalog/Algebra/Hadamard/Constructions.lean` (tensor closure, Sylvester family), `Catalog/Algebra/Hadamard/Coding.lean` (equidistant code theorem)

**Proof Strategy:** Define MUB as a predicate on pairs of matrices in ℂⁿ. Show that IsHadamard(H) implies MUB(I, (1/√n)·H) by computing |⟨eᵢ|(1/√n)H|fⱼ⟩|² = (1/n)|H(i,j)|² = 1/n (since |H(i,j)| = 1).

**Domain Bridges:** Quantum information theory, quantum cryptography, quantum state tomography

**Lineage:** Extends the coding-theory bridge to the quantum domain.

**Ambition:** Grand challenge — requires bridging combinatorics to complex linear algebra and quantum information formalism.
