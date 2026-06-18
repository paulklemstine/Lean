# Future Directions: Nonlinear Σ-Protocol Extraction Obstruction Theory

## Synthesis

The results in this cycle establish that transcript extraction in Σ-protocols is governed by the fiber geometry of the witness map, not by transcript count. The affine extraction paradigm (`Catalog/Cryptography/AffineSigmaExtraction.lean`) succeeds because the identity map has trivial fibers; the nonlinear theory (`Cryptography/NonlinearSigmaExtraction.lean`) shows that nontrivial fibers create irreducible extraction barriers. All five directions below extend this fiber-geometric framework: Direction 1 generalizes to multivariate maps where fibers become algebraic varieties; Direction 2 studies how symmetry-breaking observables collapse fibers; Direction 3 connects fiber cardinality to computational complexity; Direction 4 develops the analogy with phase retrieval into a formal equivalence; Direction 5 proposes a classification theory for Σ-protocols by identifiability class. Together, these directions aim to establish algebraic fiber theory as the natural mathematical language for cryptographic extraction problems.

---

## Direction 1: Fiber-Control Conjecture for Multivariate Polynomial Witness Maps

**Conjecture:** For transcript systems of the form zᵢ = t + cᵢ · g(w₁, ..., wₙ) where g : Fⁿ → F is a polynomial map of total degree d, no finite number of scalar-challenge transcripts can uniquely recover the witness vector (w₁, ..., wₙ) whenever the generic fiber of g has positive dimension. More precisely, the number of compatible witnesses after image extraction is at least |g⁻¹(u)| for the extracted image u, and this quantity is controlled by the degree and the fiber dimension of g.

**Test:**
- For random multivariate polynomials g : F_p² → F_p of degree 2, 3, 4, generate transcripts z_i = t + c_i · g(w) for random w.
- Extract the image u from two distinct-challenge transcripts.
- Enumerate all w' ∈ F_p² with g(w') = u.
- Record the fiber size as a function of degree, number of variables, and field size.
- Verify that fiber size is a lower bound on extraction ambiguity regardless of transcript count.
- Expected: generic fiber size grows polynomially with degree for multivariate maps.

**Impact:** This would establish the fundamental complexity barrier for extraction in multivariate Σ-protocols, directly relevant to lattice-based and MPC-based proof systems where witness vectors are high-dimensional.

**Catalog References:**
- `Catalog/Cryptography/AffineSigmaExtraction.lean` — `no_unique_extract_of_noninj` (affine obstruction)
- `Cryptography/NonlinearSigmaExtraction.lean` — `no_finite_transcript_unique_extraction_of_collision` (nonlinear multi-transcript impossibility)

**Proof Strategy:** Extend the current framework to multivariate g : Fⁿ → Fᵐ. Define TranscriptCompatible for vector-valued witness maps. Show that scalar-challenge transcripts can recover at most the m-dimensional image vector, then prove that fiber dimension ≥ n - m generically by dimension theory. For m < n, unique extraction is impossible without additional algebraic constraints.

**Domain Bridges:** Algebraic geometry (fiber dimension of polynomial maps), commutative algebra (Gröbner basis computation of fibers), computational complexity (enumeration hardness of algebraic varieties).

**Lineage:** Direct generalization of Theorem 3.2 and Theorem 4.2 from the current cycle.

**Ambition:** 🔴 Grand Challenge — establishing the multivariate fiber barrier would reshape the foundations of extraction theory for modern proof systems.

---

## Direction 2: Symmetry-Breaking Transcript Augmentation

**Conjecture:** For a witness map g : F → F with collision group G (the group of symmetries preserving g, e.g., G = {id, negation} for g(w) = w²), adding an auxiliary observable h : F → F to the protocol restores unique extraction if and only if the joint map (g, h) : F → F² has trivial fibers. Equivalently, the auxiliary observable must "break" every nontrivial element of G: for every σ ∈ G \ {id}, there exists w with h(σ(w)) ≠ h(w).

**Test:**
- For g(w) = w² over F_p, test auxiliary observables h(w) = w³, h(w) = w, h(w) = w⁵.
- For each h, compute the fiber structure of (g, h) : F_p → F_p².
- Verify that (w², w³) is injective on F_p* (since w² = v² and w³ = v³ implies w = v).
- Test for general degree-d maps: what is the minimum degree of a symmetry-breaking auxiliary?
- Expected: for the sign symmetry w ↦ -w, any odd-degree polynomial h breaks it.

**Impact:** Provides a constructive design principle for "repairing" nonlinear protocols — augment with a symmetry-breaking observable rather than restricting the domain.

**Catalog References:**
- `Cryptography/NonlinearSigmaExtraction.lean` — `unique_extraction_on_injective_domain` (domain restriction approach)
- `Catalog/Cryptography/AffineSigmaExtraction.lean` — `affine_code_injectivity_iff_extraction` (affine analogue)

**Proof Strategy:** Define the collision group G = {σ : F → F | g ∘ σ = g}. Show that G acts freely on fibers. Prove that (g, h) is injective iff h separates G-orbits. For g(w) = w², G = {id, neg}, so h must satisfy h(w) ≠ h(-w) for all w ≠ 0. Formalize in Lean using group actions.

**Domain Bridges:** Group theory (symmetry groups of polynomial maps), representation theory (characters separating group elements), protocol design (multi-channel Σ-protocols).

**Lineage:** Motivated by the impossibility results in the current cycle; provides the constructive complement.

**Ambition:** 🟡 Solid Extension — directly actionable for protocol designers.

---

## Direction 3: Algebraic Degree Barrier and Computational Complexity of Fiber Enumeration

**Conjecture:** For polynomial witness maps g : F_pⁿ → F_pᵐ of total degree d, the computational complexity of enumerating fibers (and thus resolving extraction ambiguity) undergoes a phase transition:
- For d = 1 (affine): O(n³) via linear algebra
- For d = 2 (quadratic): O(pⁿ⁻ᵐ) in the worst case, but O(poly(n)) for structured maps
- For d ≥ 3: generically NP-hard (over appropriate fields)

This creates a *degree barrier* for extraction: protocols with higher-degree witness maps are not just ambiguous — resolving the ambiguity is computationally hard.

**Test:**
- Benchmark Gröbner basis computation (e.g., using SageMath or Macaulay2) for random polynomial systems g(w) = u over F_p for p = 2, 3, 5, 7 and n = 2, 3, ..., 8.
- Measure computation time vs. (d, n, p).
- Identify the degree/dimension threshold where computation becomes impractical.
- Compare structured maps (sparse polynomials, symmetric maps) vs. random dense maps.

**Impact:** Connects extraction theory to computational algebraic geometry and could reveal that certain nonlinear protocols have a dual advantage: not only are witnesses ambiguous, but resolving the ambiguity is computationally expensive (potentially useful for proof-of-work constructions).

**Catalog References:**
- `Cryptography/NonlinearSigmaExtraction.lean` — `nonlinear_image_determined_of_two_transcripts` (image extraction is always efficient)
- `Catalog/Cryptography/AffineSigmaExtraction.lean` — `matrix_affine_extract` (affine extraction is polynomial)

**Proof Strategy:** For the lower bound, reduce Boolean satisfiability to fiber membership for degree-3 polynomial maps over F₂. For the upper bound, use effective versions of the Nullstellensatz to bound Gröbner basis computation. Formalize the affine case (O(n³)) and the quadratic case (reduction to quadratic form classification) in Lean.

**Domain Bridges:** Computational algebra (Gröbner bases, elimination theory), complexity theory (NP-hardness of polynomial system solving), algebraic geometry (effective Nullstellensatz).

**Lineage:** Extends the qualitative impossibility results to quantitative computational barriers.

**Ambition:** 🔴 Grand Challenge — establishing precise complexity transitions would have implications far beyond cryptography.

---

## Direction 4: Phase Retrieval Equivalence

**Conjecture:** The nonlinear Σ-extraction problem for g(w) = |w|² (or w² over finite fields) is formally equivalent to 1-dimensional phase retrieval: transcript-compatible witnesses form exactly the orbit of w under the measurement symmetry group. Specifically, for the squaring map over F_p, the "phase retrieval group" is Z/2Z acting by w ↦ -w, and transcript extraction recovers the signal only up to this group action.

**Test:**
- Implement both the cryptographic extraction problem and the phase retrieval problem in Python.
- For the squaring map: verify that compatible witnesses are exactly {w, -w} for every w ≠ 0.
- For degree-d power maps: verify that compatible witnesses form orbits under the group of d-th roots of unity.
- For general polynomial maps: characterize the "measurement symmetry group" and verify that transcript ambiguity equals orbit size.
- Compare with known phase retrieval algorithms (Gerchberg-Saxton, Wirtinger flow) adapted to finite fields.

**Impact:** Creates a formal bridge between two major mathematical communities (cryptography and signal processing), potentially enabling cross-pollination of techniques: phase retrieval algorithms could suggest novel extraction strategies, and cryptographic obstructions could reveal fundamental limits of phase retrieval.

**Catalog References:**
- `Cryptography/NonlinearSigmaExtraction.lean` — `sq_collision_of_neg_ne_self` (the sign symmetry)
- `Cryptography/NonlinearSigmaExtraction.lean` — `transcript_family_depends_only_on_image` (image-only recovery)

**Proof Strategy:** Define the measurement symmetry group G_g = {σ : F → F | g ∘ σ = g} and prove that transcript-compatible witnesses form a G_g-orbit. For g(w) = w², show G_g ≅ Z/2Z. Formalize the equivalence as a bijection between compatible witnesses and G_g-orbits, then specialize to show this matches the phase retrieval symmetry.

**Domain Bridges:** Signal processing (phase retrieval), harmonic analysis (ambiguity functions), quantum information (state tomography with symmetry).

**Lineage:** Motivated by the structural parallel between our Theorem 4.1 and the phase retrieval impossibility theorem.

**Ambition:** 🟡 Solid Extension — the equivalence is mathematically clean and should be formalizable.

---

## Direction 5: Identifiability Classification of Σ-Protocols

**Conjecture:** Every Σ-protocol with polynomial acceptance conditions can be classified into exactly one of four identifiability classes, determined by the fiber geometry of its witness map:
1. **Fully identifiable** (affine-injective): witness uniquely determined; fibers are singletons
2. **Quotient-identifiable** (nonlinear with finite fibers): witness determined up to a finite symmetry group; fibers are finite G-orbits
3. **Partially identifiable** (positive-dimensional fibers): witness constrained to a positive-dimensional variety; additional structural information needed
4. **Non-identifiable** (degenerate): transcripts carry no witness information; witness map is constant on the domain

Each class has a characteristic extraction complexity and a minimal augmentation strategy for achieving full identifiability.

**Test:**
- Classify 20+ concrete Σ-protocols from the literature by computing their witness map fiber structure.
- Verify that every protocol falls cleanly into one of the four classes.
- For each non-fully-identifiable protocol, compute the minimal symmetry-breaking augmentation.
- Check whether the classification is stable under small perturbations of the witness map.

**Impact:** Would provide the first systematic taxonomy of Σ-protocols by algebraic identifiability, replacing the current ad hoc analysis of special soundness with a principled geometric framework.

**Catalog References:**
- `Catalog/Cryptography/AffineSigmaExtraction.lean` — `AffineSigmaProtocol.universal_special_soundness` (Class 1)
- `Cryptography/NonlinearSigmaExtraction.lean` — `no_unique_extract_of_nonlinear_collision` (Class 2 obstruction)
- `Cryptography/NonlinearSigmaExtraction.lean` — `unique_extraction_on_injective_domain` (domain restriction to reach Class 1)

**Proof Strategy:** Define the identifiability class as a function of the fiber dimension and fiber group. Prove that affine protocols with extraction rank are Class 1 (already done). Prove that polynomial protocols with finite collision groups are Class 2 (quadratic case done; general polynomial case is new). Define Class 3 via fiber dimension > 0 and give examples from multivariate settings. Prove that the classification is exhaustive.

**Domain Bridges:** Algebraic statistics (identifiability theory for statistical models), algebraic geometry (classification of morphisms by fiber type), category theory (functorial classification of covers).

**Lineage:** Natural synthesis of all results from both the affine and nonlinear extraction cycles.

**Ambition:** 🔴 Grand Challenge — a complete classification theory would be a foundational contribution to both cryptography and algebra.
