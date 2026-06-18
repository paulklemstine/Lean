# Future Directions: Exceptional Character-Sheaf Certificates

## Synthesis

The character-ratio certificate framework established in this work creates a modular pipeline: representation-theoretic data (character bounds on toral elements) flows through a formally verified transference chain to produce certified spectral gaps, Cheeger constants, and mixing bounds. The five directions below form a coherent program: Direction 1 fills the pipeline's input for G₂; Direction 2 extends the pipeline to all exceptional groups; Direction 3 pushes the output toward optimal (Ramanujan) bounds; Direction 4 bridges to geometric representation theory; Direction 5 connects to applications in cryptographic sampling. Together, they constitute a research agenda for **exceptional expander engineering** — the systematic exploitation of exceptional Lie theory for combinatorial and computational applications.

---

## Direction 1: Computational Verification of the G₂ Character-Ratio Conjecture

**Conjecture:** There exists C_{G₂} > 0 such that for every prime power q of good characteristic and every regular semisimple element s in a maximal torus of G₂(𝔽_q),

    max_{χ ∈ Irr(G₂(𝔽_q)), χ ≠ 1} |χ(s)/χ(1)| ≤ C_{G₂}/q.

**Test:** Compute character tables of G₂(𝔽_q) for q = 2, 3, 4, 5, 7, 8, 9, 11, 13, 16, 17, 19, 23, 25 using GAP/CHEVIE. For each q, compute M(q) = q · max_{s,χ} |χ(s)/χ(1)|. The conjecture predicts M(q) remains bounded; falsification occurs if M(q) grows systematically. Decompose M(q) by torus type to identify which tori contribute the extremal ratios.

**Impact:** If verified computationally, this provides the input data for our certificate framework, yielding the first proven uniform expander family from an exceptional group. If falsified, it reveals structural obstructions to expansion in exceptional groups, which would itself be a significant discovery.

**Catalog References:** `Pythagorean/G2CharacterSheafCertificate.lean` — `G2CharacterRatioBound`, `g2_conjecture_implies_expansion`, `g2_uniform_expansion`

**Proof Strategy:** Use the Enomoto–Yamada (1986) and Chang (2006) parameterization of irreducible characters of G₂(𝔽_q) via Deligne–Lusztig theory. The characters are organized into Harish-Chandra series corresponding to the 6 conjugacy classes of W(G₂). For each series, estimate |χ(s)/χ(1)| using Green function formulas.

**Domain Bridges:** Algebraic geometry (Deligne–Lusztig theory) → combinatorics (expansion); computational algebra (GAP/CHEVIE) → formal verification.

**Lineage:** Extends Liebeck–Shalev (2004) character-ratio bounds from asymptotic estimates to explicit constants.

**Ambition:** Solid extension — the mathematical tools exist; the novelty is in the explicit computation and formal certification.

**The key insight is** that bounded toral complexity (at most 6 torus types for G₂) reduces an infinite verification problem to a finite one, making computational verification tractable.

**Why now?** Character tables for G₂(𝔽_q) are available in CHEVIE for all q, and the certificate framework can immediately consume the resulting bounds to produce certified expanders.

---

## Direction 2: Exceptional Expander Ladder — F₄, E₆, E₇, E₈

**Conjecture:** For each exceptional group X ∈ {F₄, E₆, E₇, E₈}, there exists C_X > 0 such that the character-ratio bound holds with constant C_X on regular semisimple toral elements, yielding a uniform expander family.

**Test:** Compute M_X(q) for small q for each exceptional type. The bounded toral complexity argument predicts M_X(q) bounded for each X; the constants C_X should increase with rank but remain finite. Cross-reference with known character-degree polynomials to establish feasibility.

**Impact:** A complete exceptional expander ladder would provide 5 fundamentally new families of expander graphs, each with algebraically structured spectral properties distinct from classical-group expanders.

**Catalog References:** `Pythagorean/G2CharacterSheafCertificate.lean` — `CharacterRatioCertificate`, `uniform_expansion_of_certified_family`, `bounded_toral_complexity`

**Proof Strategy:** For each exceptional type:
1. Enumerate Weyl group conjugacy classes (torus types): |W(F₄)| = 1152, |W(E₆)| = 51840, |W(E₇)| = 2903040, |W(E₈)| = 696729600. The number of conjugacy classes (= torus types) is 25, 25, 60, 112 respectively.
2. For each torus type, use Deligne–Lusztig character formulas to bound |χ(s)/χ(1)|.
3. Take the maximum over torus types.

**Domain Bridges:** Exceptional Lie theory → combinatorics → computer science (explicit expander constructions).

**Lineage:** Direct extension of the G₂ certificate framework.

**Ambition:** Grand challenge — E₈ has 112 torus types and the character theory is extremely complex. A complete treatment would be a major achievement in computational representation theory.

**The key insight is** that the certificate framework is parametric in the group: no new theory is needed, only new character data. The transference theorems apply verbatim.

**Why now?** The certificate formalism has been established and verified; the remaining barrier is computational, not theoretical.

---

## Direction 3: Optimal Spectral Gaps and Ramanujan-Type Bounds

**Conjecture:** For G₂(𝔽_q) with regular semisimple generators of degree d, the Cayley graph achieves the Ramanujan bound λ₂ ≤ 2√(d−1)/d, or comes within a constant factor of it.

**Test:** Compare the certified spectral radius C/q with the Ramanujan bound 2√(d−1)/d for the Cayley graphs at q = 3, 5, 7, 11, 13. If C/q significantly exceeds the Ramanujan bound, there is room for improvement in the character-ratio estimates. If they nearly coincide, the certificates are essentially optimal.

**Impact:** Ramanujan graphs are the gold standard of expander construction. Showing that exceptional-group Cayley graphs are Ramanujan (or near-Ramanujan) would place them alongside the Lubotzky–Phillips–Sarnak (1988) and Morgenstern (1994) constructions as algebraically optimal expanders.

**Catalog References:** `Pythagorean/G2CharacterSheafCertificate.lean` — `certificate_spectral_radius_le`, `gap_monotone_in_q`; `Bridges/Catalog/Pythagorean/Sp4SpectralGap.lean` — `character_ratio_to_spectral_gap`

**Proof Strategy:** Use Deligne's proof of the Riemann hypothesis for varieties over finite fields (Weil conjectures) to obtain sharp bounds on Green functions. For G₂, the relevant varieties are Deligne–Lusztig varieties of dimension ≤ 6 (the number of positive roots), and the eigenvalues of Frobenius are controlled by Weil-type estimates.

**Domain Bridges:** Algebraic geometry (Weil conjectures) → spectral graph theory → coding theory (optimal LDPC codes from Ramanujan graphs).

**Lineage:** Extends the Ramanujan graph program of Lubotzky–Phillips–Sarnak to exceptional groups.

**Ambition:** Grand challenge — obtaining sharp constants requires deep algebraic geometry.

**The key insight is** that the Ramanujan bound is not just an aspiration but a consequence of the Weil conjectures applied to Deligne–Lusztig varieties, and the exceptional groups may naturally achieve it due to the small dimension of their flag varieties.

**Why now?** The certificate framework provides the consumption mechanism for sharp character bounds; what's needed is the production of optimally tight estimates.

---

## Direction 4: Character Sheaves as Certificate Sources

**Conjecture:** Lusztig's character-sheaf decomposition of class functions on G(𝔽_q) provides a natural factorization of the character-ratio certificate into geometric components (sheaf-theoretic data on the algebraic group) and arithmetic components (Frobenius eigenvalues), enabling systematic production of certificates from geometric representation theory.

**Test:** For G₂, express the character-ratio bound in terms of:
(a) geometric data: perverse sheaves on the unipotent variety of G₂,
(b) arithmetic data: Frobenius eigenvalues on stalks.
Verify that the geometric data is q-independent and the arithmetic data contributes the 1/q factor.

**Impact:** This would establish character sheaves as a general-purpose factory for expansion certificates, connecting the geometric Langlands program to combinatorial optimization. It would show that the geometric Langlands correspondence has computable, finite consequences for explicit graph construction.

**Catalog References:** `Pythagorean/G2CharacterSheafCertificate.lean` — `CharacterRatioCertificate`, `mkCertificateFromData`

**Proof Strategy:**
1. Use Lusztig's partition of Irr(G(𝔽_q)) into character-sheaf packets.
2. For each packet, the character values are controlled by the geometry of the corresponding sheaf on the algebraic group G.
3. The 1/q decay arises from the weights of the perverse sheaf (via Gabber's purity theorem or Deligne's mixed Hodge theory).

**Domain Bridges:** Geometric representation theory (character sheaves, perverse sheaves) → combinatorics (expansion certificates); algebraic geometry → theoretical computer science.

**Lineage:** Connects Lusztig's character-sheaf theory (1984–) to the expansion program.

**Ambition:** Grand challenge — requires bridging two of the deepest theories in modern mathematics.

**The key insight is** that character-sheaf data is q-independent geometric data, and the certificate formalism is precisely the interface that can consume this data to produce q-dependent combinatorial guarantees.

**Why now?** The formalization of the certificate-consumption side is complete; what remains is formalizing the certificate-production side from sheaf-theoretic input.

---

## Direction 5: Exceptional Expanders for Cryptographic Sampling

**Conjecture:** Cayley graphs of G₂(𝔽_q) with regular semisimple generators provide cryptographically secure pseudorandom generators, with provable mixing guarantees derived from character-ratio certificates. The mixing time is O(log q) steps, sufficient for polynomial-time sampling with exponential security margin.

**Test:** Implement a random-walk sampler on Cay(G₂(𝔽_q), S) for q = 2^k (k = 8, 16, 32). Measure:
(a) statistical distance from uniform after t steps (should decay as (C/q)^t),
(b) resistance to linear/algebraic distinguishing attacks,
(c) throughput in bits per operation compared to standard PRGs.

**Impact:** Exceptional-group PRGs would provide an alternative to lattice-based and elliptic-curve-based constructions, with security rooted in the representation theory of exceptional groups rather than number-theoretic hardness assumptions.

**Catalog References:** `Pythagorean/G2CharacterSheafCertificate.lean` — `l2_mixing_time_bound_of_certificate`, `mixing_time_finite`, `walk_error_geometric_decay`

**Proof Strategy:**
1. The certified spectral gap gives L² mixing in O(log(|G|)/gap) = O(log q) steps.
2. For cryptographic security, convert L² mixing to statistical distance via Cauchy–Schwarz: ‖μ^t − U‖_TV ≤ √|G| · ρ^t.
3. With ρ = C/q and |G| = q^6(q^6−1)(q^2−1), the mixing time to TV distance 2^{-k} is O(k + 6 log q / log(q/C)).

**Domain Bridges:** Exceptional Lie theory → cryptography → secure computation.

**Lineage:** Extends the Cayley-hash construction of Zémor (1991) and Tillich–Zémor (1994) from SL₂ to exceptional groups.

**Ambition:** Solid extension — the mathematical framework is in place; the novelty is in the application domain and implementation.

**The key insight is** that the certificate framework provides provable, quantitative mixing guarantees that translate directly to cryptographic security parameters, and exceptional groups offer structural diversity beyond the classical groups currently used.

**Why now?** Post-quantum cryptography motivates exploration of new algebraic structures. Exceptional groups, with their rigid and unusual symmetry, offer a fundamentally different security basis.
