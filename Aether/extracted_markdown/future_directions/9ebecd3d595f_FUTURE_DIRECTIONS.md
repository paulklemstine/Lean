# Future Directions: Uniform Symplectic Expansion Program

## Synthesis

The rank-aware certificate framework established in this work creates a new paradigm: higher-rank symplectic expansion is no longer an isolated construction problem but a systematic enterprise. The certificate `DLRankCharacterBoundCertificate` separates representation-theoretic inputs from spectral outputs, and the torus-type stability theorem provides an inductive mechanism for propagating expansion across ranks. The five directions below extend this paradigm in complementary ways: (1–2) deepen the symplectic theory through explicit generation and optimal constants, (3) broadens to other classical groups, (4) bridges to coding theory, and (5) connects to automorphic forms. Together, they chart a path from a single theorem schema to a complete theory of expansion for finite groups of Lie type.

---

## Direction 1: Explicit Symplectic Generation Certificates via Maximal Subgroup Exclusion

**Conjecture:** For each rank n ≥ 1 and all sufficiently large odd primes q, there exist explicit matrices s, t ∈ Sp₂ₙ(𝔽_q) — where s is a regular toral element with irreducible self-reciprocal characteristic polynomial and t is a "transverse" companion — such that ⟨s, t⟩ = Sp₂ₙ(𝔽_q). Moreover, the pair (s, t) can be constructed in polynomial time in n and log q.

**Test:** Implement the construction for Sp₆(𝔽_q) with q = 7, 11, 13 and verify generation computationally using the GAP algebra system. Check that the generated subgroup has the correct order |Sp₆(𝔽_q)| = q⁹(q⁶−1)(q⁴−1)(q²−1). Formalize the generation proof for Sp₄(𝔽_q) using `eq_bot_or_top_of_charpoly_irreducible` from `Catalog/Algebra/MatrixGroupGeneration.lean`.

**Impact:** Completes the certificate: currently our certificates assume generation as a hypothesis. With explicit generation proofs, the entire expansion pipeline — from raw matrix data to spectral gap — would be fully constructive. This would enable certified expander constructions for cryptographic applications and derandomization.

**Catalog References:** `Catalog/Algebra/MatrixGroupGeneration.lean` (eq_bot_or_top_of_charpoly_irreducible), `Catalog/Bridges/Catalog/Pythagorean/Sp4SpectralGap.lean` (DLCharacterBoundCertificate).

**Proof Strategy:** Use Aschbacher's maximal subgroup theorem for Sp₂ₙ(𝔽_q) to enumerate obstructions. An element s with irreducible self-reciprocal charpoly cannot lie in any reducible or imprimitive maximal subgroup (by `eq_bot_or_top_of_charpoly_irreducible`). The "no proper symplectic decomposition" condition on t excludes the remaining geometric maximal subgroups. Exclude exceptional maximal subgroups by a dimension argument using Landazuri–Seitz bounds.

**Domain Bridges:** Cryptography (verifiable random number generation), computational group theory (constructive recognition algorithms).

**Lineage:** Extends `eq_bot_or_top_of_charpoly_irreducible` from linear to symplectic context, completing the generation component of the certificate.

**Ambition:** 🔴 Grand Challenge — would be the first fully constructive higher-rank symplectic generation result with machine-verified proof.

**The key insight is** that irreducibility of the characteristic polynomial eliminates most maximal subgroup classes simultaneously, reducing the generation problem to excluding a finite list of exceptional configurations.

**Why now?** The `eq_bot_or_top_of_charpoly_irreducible` theorem is already formalized, and Aschbacher's theorem provides a finite classification of maximal subgroups. The gap is "merely" the symplectic upgrade — substantial but well-defined.

---

## Direction 2: Optimal Character-Ratio Constants via Explicit Deligne–Lusztig Computation

**Conjecture:** The optimal character-ratio constant for Sp₂ₙ(𝔽_q) with Coxeter torus elements is K_n = 2n, not K_n = n+1 as used in our conservative bounds. The true value can be determined by explicit computation of Deligne–Lusztig character values on Coxeter torus elements using Green functions.

**Test:** For Sp₄(𝔽_q) (n=2), compute all irreducible character values on a Coxeter torus element for q = 5, 7, 11, 13 using the known character table. Verify that the maximum character ratio is bounded by K₂/q with K₂ < 3. For Sp₆(𝔽_q) (n=3), compute using the Lusztig parametrization for q = 7, 11.

**Impact:** Tighter constants directly improve spectral gap bounds (the gap is 1 − K_n/q) and reduce the minimum field size threshold (need q > K_n). This matters for practical applications: the difference between K₃ = 4 and K₃ = 3 determines whether Sp₆(𝔽₅) is an expander.

**Catalog References:** `Pythagorean/Sp2nExpansion.lean` (DLRankCharacterBoundCertificate, mkRankCertificate).

**Proof Strategy:** Use the Deligne–Lusztig character formula for characters of toral type: χ_{T,θ}(s) = (−1)^l ∑_{w∈W} θ(w·s)/|C_G(s)|. For regular semisimple s in a Coxeter torus T, this simplifies to a sum over the Weyl group W(C_n) = (ℤ/2ℤ)^n ⋊ S_n. Bound each term and optimize over the choice of torus type.

**Domain Bridges:** Algebraic geometry (étale cohomology of Deligne–Lusztig varieties), computational algebra (explicit character computation).

**Lineage:** Refines the constants in `uniform_torus_type_stable_under_rank_succ` and `uniform_torus_type_rank_one`.

**Ambition:** 🟡 Solid Extension — computation-heavy but well-defined problem with clear methodology.

**The key insight is** that the inductive bound K_n = n+1 is an artifact of the transfer argument; the true bound from direct DL computation should be smaller, as the correction term in rank extension decays with q.

**Why now?** Computational algebra systems (GAP, CHEVIE) can compute character tables of Sp₂ₙ(𝔽_q) for n ≤ 5. The formalization framework is ready to accept improved constants with no structural changes.

---

## Direction 3: Extension to Orthogonal and Unitary Groups

**Conjecture:** The rank-aware certificate framework extends to the orthogonal groups SO₂ₙ₊₁(𝔽_q) (type B_n) and SO₂ₙ(𝔽_q) (type D_n), and the unitary groups SU_n(𝔽_{q²}) (type ²A_{n−1}), with analogous torus-type stability theorems and uniform spectral gaps.

**Test:** Define `DLRankCharacterBoundCertificate` for type B₂ = SO₅(𝔽_q) and verify the transference theorem yields positive gaps for q = 5, 7, 11. Check that the torus-type stability theorem adapts with K_n = n+1 for type B.

**Impact:** Would establish the first **pan-classical** expansion framework, covering all major families of finite groups of Lie type in a single architecture. This is the natural generalization of our symplectic theory and would subsume most known expansion results for specific classical groups.

**Catalog References:** `Pythagorean/Sp2nExpansion.lean` (full framework as template), `Catalog/Algebra/MatrixGroupGeneration.lean` (linear algebraic tools).

**Proof Strategy:** The Deligne–Lusztig machinery is uniform across types: the key input is always a character-ratio bound on Coxeter torus elements. For type B, the Weyl group is (ℤ/2ℤ)^n ⋊ S_n (same as type C), so the combinatorial structure of the DL formula is identical. For type D, the Weyl group is index-2 in the type-B Weyl group. For type ²A, the structure is different (unitary vs. symplectic), but the certificate framework applies verbatim.

**Domain Bridges:** Coding theory (orthogonal polar spaces → Reed-Muller type codes), physics (SO groups in spin systems, SU groups in gauge theory).

**Lineage:** Direct extension of the full symplectic framework to types B, D, ²A.

**Ambition:** 🔴 Grand Challenge — would unify expansion theory across all classical groups.

**The key insight is** that the certificate structure is type-independent: it only uses the character-ratio bound, not the specific form of the group. The representation theory changes, but the transference/mixing/Cheeger pipeline is identical.

**Why now?** The symplectic case proves the architecture works. The Deligne–Lusztig theory is equally well-developed for all classical types. The formalization infrastructure (Lean + Mathlib) handles matrix groups of any type.

---

## Direction 4: Polar-Space LDPC Codes from Symplectic Expanders

**Conjecture:** The Cayley graph on Sp₂ₙ(𝔽_q) with generators from a DL rank certificate, when restricted to the action on totally isotropic k-subspaces of the symplectic polar space W(2n−1, q), yields a bipartite graph whose associated LDPC code has minimum distance Ω(N^{1/2}) and rate Ω(1), where N is the block length.

**Test:** For Sp₄(𝔽₇) acting on totally isotropic 1-subspaces (points of W(3, 7)): construct the bipartite graph, compute girth and minimum distance of the associated code, and compare with random LDPC codes of the same parameters. For Sp₆(𝔽₅), estimate code parameters using the Cheeger bound.

**Impact:** Algebraic LDPC codes with guaranteed expansion properties are highly sought in coding theory. The symplectic structure provides additional algebraic structure that could enable efficient decoding algorithms. The Cheeger bound from our Theorem 3 gives explicit minimum distance guarantees.

**Catalog References:** `Pythagorean/Sp2nExpansion.lean` (rank_certificate_implies_sampler_quality, HasPolarSpaceSamplerQuality).

**Proof Strategy:** Use the Cheeger constant h ≥ (1 − K_n/q)/2 to bound the expansion of the bipartite graph. The minimum distance of the LDPC code is at least h · N / (2d) where d is the column weight (degree of the bipartite graph). The rate follows from a counting argument on totally isotropic subspaces.

**Domain Bridges:** Information theory (capacity-approaching codes), telecommunications (5G/6G error correction), quantum error correction (CSS codes from symplectic geometry).

**Lineage:** Builds on `rank_certificate_implies_sampler_quality` and `HasPolarSpaceSamplerQuality`.

**Ambition:** 🟡 Solid Extension — clear pathway from existing Cheeger bounds to code parameters.

**The key insight is** that the polar-space geometry is *preserved* by the symplectic group action, so the expansion of the Cayley graph transfers directly to expansion of the incidence graph of the polar space.

**Why now?** Our Theorem 3 provides the quantitative Cheeger bound. Polar-space codes are an active area of research, and explicit constructions with provable parameters would advance the field immediately.

---

## Direction 5: Automorphic Hecke Decay and Property (τ) for Symplectic Lattices

**Conjecture:** The uniform spectral gap for Sp₂ₙ(𝔽_q) as q → ∞ implies Property (τ) for the family of congruence quotients Sp₂ₙ(ℤ/qℤ). Moreover, the L² mixing estimate from Theorem 2 should be liftable to a statement about spectral decay of Hecke operators on Sp₂ₙ(ℤ)\Sp₂ₙ(ℝ)/K, giving explicit rates of equidistribution for Hecke orbits in Siegel modular variety.

**Test:** For n = 1 (SL₂), verify that the finite spectral gap matches the known Ramanujan bound λ₁ ≥ 1/4 for congruence subgroups (via Selberg's theorem). For n = 2 (Sp₄), compare the finite spectral gap with known estimates for Siegel cusp forms of genus 2.

**Impact:** Would connect the finite group theory to the Langlands program, establishing a bridge between Deligne–Lusztig character bounds and automorphic spectral theory. This is a deep problem at the intersection of number theory, representation theory, and harmonic analysis.

**Catalog References:** `Pythagorean/Sp2nExpansion.lean` (rank_certificate_implies_L2_mixing, uniform_torus_type_all_ranks), `Catalog/Bridges/Catalog/Pythagorean/Sp4SpectralGap.lean` (ds_majorant_convergence).

**Proof Strategy:** Property (τ) for congruence quotients of Sp₂ₙ(ℤ) follows from the work of Clozel (2003) using automorphic methods. The connection to our finite results goes through the comparison of Hecke eigenvalues: the Satake parameter of a Hecke eigenform at the prime p is related to the character ratio of the corresponding representation of Sp₂ₙ(𝔽_p).

**Domain Bridges:** Number theory (Langlands program, automorphic forms), arithmetic geometry (Shimura varieties), mathematical physics (quantum unique ergodicity on locally symmetric spaces).

**Lineage:** Extends the L² mixing framework from finite groups to arithmetic lattices.

**Ambition:** 🔴 Grand Challenge — would bridge finite group expansion to deep phenomena in automorphic representation theory.

**The key insight is** that the finite character-ratio bound C_n/q is the "shadow" of the Ramanujan conjecture for Sp₂ₙ: the bound on Satake parameters at unramified primes.

**Why now?** Our L² mixing theorem provides the formal framework. Recent progress on the Ramanujan conjecture for Sp₄ (by Weissauer and others) gives concrete test cases. The formalization in Lean would make the connection machine-verifiable for the first time.
