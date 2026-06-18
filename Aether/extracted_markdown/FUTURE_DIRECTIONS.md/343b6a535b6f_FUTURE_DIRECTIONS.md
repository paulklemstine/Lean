# Future Directions: Certificate Density and the Prime Polynomial Theorem

## Synthesis

The certificate density framework establishes a quantitative bridge between three mathematical domains: the arithmetic of irreducible polynomials (number theory), the generation properties of matrix groups (algebra), and the error bounds of the function-field Riemann hypothesis (analytic number theory). The five directions below exploit this bridge in both directions — using arithmetic to control algebraic generation (Directions 1–3) and using algebraic structure to illuminate arithmetic questions (Directions 4–5). Together, they chart a path toward a unified "generation theory" for finite groups of Lie type, where the certificate density serves as the fundamental quantitative invariant.

---

## Direction 1: Necklace Divisibility via Burnside's Lemma

**Conjecture:** The necklace divisibility theorem n | Σ_{d|n} μ(n/d) q^d can be formally proved by constructing the cyclic group action on q-ary strings of length n and applying Burnside's lemma to count primitive necklaces.

**Test:** Formalize the Z/nZ action on (Fin q)^(Fin n), verify that Burnside's lemma gives (1/n) Σ_{d|n} φ(n/d) q^(gcd(n,d)) total necklaces, and that inclusion-exclusion via Möbius inversion extracts the primitive necklace count (1/n) Σ_{d|n} μ(n/d) q^d. If the primitive count is not a non-negative integer for any (q,n), the approach fails.

**Impact:** Closes the one remaining sorry in the formalization and establishes the first fully verified proof of this 200-year-old number-theoretic identity in a modern proof assistant.

**Catalog References:** `Pythagorean/CertificateDensity.lean` (Theorem: `necklace_sum_div_n`)

**Proof Strategy:** Define the type `Necklace q n := (Fin n → Fin q)`, the cyclic shift action `σ : (Fin n → Fin q) → (Fin n → Fin q)` by `σ f i = f (i + 1)`, and the orbit quotient. Apply `MulAction.card_quotient_eq_sum_card_fixedBy` from Mathlib. The fixed points of σ^d are exactly the strings with period dividing d, giving q^(gcd(n,d)) fixed points. The Möbius inversion step uses the established framework.

**Domain Bridges:** Combinatorics ↔ Number Theory ↔ Algebra

**Lineage:** Extends `necklace_sum_div_prime` (Fermat's little theorem case) to all n.

**Ambition:** Solid extension — closes a specific gap in the current formalization.

---

## Direction 2: Certificate Density for Symplectic and Orthogonal Groups

**Conjecture:** For the symplectic group Sp_{2n}(𝔽_q), the certificate density (proportion of elements with irreducible characteristic polynomial satisfying the symplectic symmetry constraint f(x) = x^{2n} f(1/x)) is asymptotically 1/(2n), with error O(q^{-n}).

**Test:** Compute the certificate density for Sp_4(𝔽_q) for q = 3, 5, 7 and compare with 1/4. The "self-reciprocal irreducible" count for degree 2n should be approximately q^n/(2n). If the actual count deviates from this by more than q^{n/2} for any tested case, the conjecture's error term needs revision.

**Impact:** Extends the certificate framework from GL_n to all classical groups, providing generation probability bounds for the groups that appear in quantum error correction (Sp_{2n} stabilizes symplectic quantum codes).

**Catalog References:** `Algebra/MatrixGroupGeneration.lean` (generation framework), `Pythagorean/CertificateDensity.lean` (GL_n density)

**Proof Strategy:** Count self-reciprocal irreducible polynomials using the map f(x) ↦ x^n f(x + 1/x), which reduces to counting irreducible polynomials of degree n. Apply the existing necklace formula to this reduced count. The orbit-stabilizer argument carries over with the centralizer now being a unitary group U_1(𝔽_{q^n}).

**Domain Bridges:** Algebra (classical groups) ↔ Number Theory (self-reciprocal polynomials) ↔ Quantum Computing (symplectic stabilizer codes)

**Lineage:** Direct extension of the GL_n certificate density theorem.

**Ambition:** Solid extension — fills an important gap for non-GL classical groups.

---

## Direction 3: Quantum Error-Correcting Codes via Singer Cycle Certificates

**Conjecture:** Singer cycle certificates in GL_n(𝔽_q) define stabilizer generators for quantum codes over 𝔽_q, and the certificate density controls the probability that a random stabilizer generator has maximal-distance separable (MDS) properties. Specifically, for q = p^2 (a square prime power), the density of Hermitian self-orthogonal Singer cycles is asymptotically 1/(2n).

**Test:** For GL_4(𝔽_4), compute the number of Singer cycles whose minimal polynomial defines a Hermitian self-orthogonal code. Compare with the predicted count |GL_4(𝔽_4)| · 1/(2·4) = |GL_4(𝔽_4)|/8. Deviation > 20% falsifies the conjecture.

**Impact:** Provides a new construction method for quantum stabilizer codes based on certificate density theory, potentially yielding codes with provably good parameters from random sampling.

**Catalog References:** `Pythagorean/CertificateDensity.lean` (density bounds), `Algebra/MatrixGroupGeneration.lean` (certificate systems)

**Proof Strategy:** Formalize the connection between Singer cycles and cyclic codes. Show that the dual code of a Singer cycle code corresponds to the reciprocal polynomial. Establish conditions under which the Singer cycle code is self-orthogonal (for CSS-type quantum codes) or Hermitian self-orthogonal (for general stabilizer codes).

**Domain Bridges:** Group Theory (certificates) ↔ Coding Theory (cyclic codes) ↔ Quantum Computing (stabilizer codes)

**Lineage:** Extends certificate density theory into the quantum domain.

**Ambition:** Grand challenge — requires bridging three established mathematical domains.

---

## Direction 4: Cohen-Lenstra Heuristics via Certificate Counting

**Conjecture:** The certificate density for GL_n(𝔽_q) as q varies satisfies moment statistics consistent with the Cohen-Lenstra heuristics for function-field class groups. Specifically, the probability that a random element of GL_n(𝔽_q) has characteristic polynomial with Galois group exactly Z/nZ (the Singer cycle case) versus a proper subgroup follows the Cohen-Lenstra weighting |Aut(G)|^{-1} applied to the cyclic group.

**Test:** For n = 6, compute the distribution of Galois groups of characteristic polynomials over GL_6(𝔽_q) for q = 3, 5, 7. The fraction with Galois group Z/6Z should approach 1/6. The fraction with Galois group S_3 (from irreducible quadratic × irreducible cubic factorization) should approach a specific Cohen-Lenstra prediction. Deviation > 10% from the predicted distribution for q = 7 falsifies the connection.

**Impact:** Establishes a new bridge between random matrix theory over finite fields and arithmetic statistics, suggesting that certificate density theory is a shadow of deeper algebraic structures controlling class group distributions.

**Catalog References:** `Pythagorean/CertificateDensity.lean` (density framework)

**Proof Strategy:** Use the rational canonical form to classify elements of GL_n(𝔽_q) by invariant factor type. Count each type using the orbit-stabilizer theorem with centralizer computations for each rational canonical form type. Compare with Cohen-Lenstra predictions for the distribution of abelian groups weighted by 1/|Aut|.

**Domain Bridges:** Random Matrix Theory ↔ Algebraic Number Theory (Cohen-Lenstra) ↔ Group Theory

**Lineage:** Extends the single-density result to a full distribution theory.

**Ambition:** Grand challenge — connects to one of the deepest conjectural frameworks in number theory.

---

## Direction 5: Tropical Certificate Density and Expander Graph Construction

**Conjecture:** The certificate density framework admits a tropical analogue, where the finite field 𝔽_q is replaced by the tropical semifield T = (ℝ ∪ {-∞}, max, +), and "irreducible" tropical characteristic polynomials correspond to indecomposable tropical matrices. The tropical certificate density converges to 1/n as the "tropical q" (a scaling parameter) tends to infinity, with the same Möbius-function error structure.

**Test:** Compute the fraction of n×n tropical matrices (with entries in {0, 1, ..., M}) that are tropically indecomposable, for n = 3, 4, 5 and M = 10, 100, 1000. If the fraction converges to 1/n with error ~ 1/M^{n/2}, the tropical analogue holds.

**Impact:** Opens a new research direction connecting tropical geometry to algebraic generation theory. If the tropical certificate density satisfies the same asymptotics, it suggests a universal structural principle governing irreducibility across algebraic settings.

**Catalog References:** `Pythagorean/CertificateDensity.lean` (algebraic density), `Pythagorean/TropicalBerggrenZeta.lean` (tropical arithmetic)

**Proof Strategy:** Define tropical irreducibility via the tropical determinant and permanent structure. Use the tropical analogue of the characteristic polynomial (the tropical eigenvalue set) to classify tropical matrices. Apply tropical Möbius inversion to count tropically indecomposable polynomials.

**Domain Bridges:** Tropical Geometry ↔ Group Theory ↔ Number Theory

**Lineage:** Extends the Pythagorean-tropical bridge to a new domain.

**Ambition:** Grand challenge — speculative but testable connection between algebraic and tropical worlds.
