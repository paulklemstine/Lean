# Future Directions: Spectral Optimization for Cryptographic Compression

## Synthesis

The work in this cycle establishes a rigorous bridge between **operator-norm analysis** and **cryptographic compression design** by introducing the RMS amplification invariant and proving the √k gap theorem. This opens five interconnected research directions:

1. **Concrete ML-KEM spectral bounds** — applying the theory to actual NIST-standardized parameters
2. **Block-diagonal optimization** — extending equipartition to structured matrices
3. **Probabilistic amplification** — moving from worst-case to average-case bounds
4. **Higher-order compression** — compositions and multi-stage pipelines
5. **Isoperimetric connections** — linking spectral optimization to geometric measure theory

Each direction builds directly on the formally verified theorems and creates new falsifiable predictions testable with both computation and formal proof. Together, they form a research program to make **spectral geometry a first-class tool in post-quantum cryptographic design**.

---

## Direction 1: Structured ML-KEM Anisotropy Gap

**Conjecture:** For the concrete NTT-domain compression operators used in ML-KEM-768 (k=3, n=256, q=3329, du=10, dv=4), the anisotropy ratio satisfies

    anisotropyRatio(f_compress) < 1.3

This is strictly less than the theoretical maximum √3 ≈ 1.732.

**Test:** Extract the exact compression matrices from the ML-KEM specification (FIPS 203). Compute the anisotropy ratio for all concrete block structures arising from the NTT decomposition. Disprove by exhibiting any block with ratio exceeding 1.3. Verify formally by instantiating the existing Lean theorems with concrete numerical values.

**Impact:** If confirmed, this would show that ML-KEM's compression is inherently well-structured — the √k worst case is far from reality. This has immediate implications for tightening decryption failure probability bounds in security proofs.

**Catalog References:**
- `Cryptography/ModuleLWE/Compression.lean` — `decode_correct_of_linear_noise_bound`
- `Pythagorean/SpectralCompression.lean` — `anisotropyRatio_le_sqrt_card`, `one_le_anisotropyRatio`

**Proof Strategy:** Computational verification first (extract NTT matrices, compute ratios), then formalize the bound as a `native_decide`-checkable statement in Lean for concrete small instances.

**Domain Bridges:** Post-quantum cryptography ↔ Spectral graph theory (NTT as DFT on cyclic groups)

**Lineage:** Direct extension of `anisotropyRatio_le_sqrt_card`.

**Ambition:** Medium — primarily computational, but high impact for standards compliance.

---

## Direction 2: Balanced Block Compression is Optimal (Grand Challenge)

**Conjecture:** Among block-diagonal compression operators with fixed block sizes (b₁, ..., bₘ) and fixed total Frobenius norm, the minimum operator norm is achieved when each block has equal singular values, and the common singular value is the same across all blocks.

More precisely, for B = diag(B₁, ..., Bₘ) with ||B||_F = C fixed:

    min ||B||_op = C / √(∑ bᵢ)

achieved iff each Bᵢ = (C/√(∑ bᵢ)) · Iᵢ.

**Test:** Implement continuous optimization over block-diagonal matrices with fixed Frobenius norm. For blocks of size up to 4×4, exhaustive grid search. For larger blocks, gradient descent with multiple random initializations. Disprove by finding a lower-operator-norm unbalanced configuration.

**Impact:** This would be a fundamental result in matrix optimization, providing a rigorous design principle for structured compression in lattice cryptography. It would extend the scalar equipartition principle (formally verified for diagonal maps) to the full matrix setting.

**Catalog References:**
- `Pythagorean/SpectralCompression.lean` — `rms_le_sup`, `sup_eq_rms_of_balanced`
- `Cryptography/ModuleLWE/Compression.lean` — `decode_correct_of_composed_compression`

**Proof Strategy:**
1. Prove the result first for 2-block case using Lagrange multipliers.
2. Generalize by induction on number of blocks.
3. The key lemma: for a single block, the operator norm is minimized at fixed Frobenius norm iff all singular values are equal (this is our `sup_eq_rms_of_balanced` for diagonal matrices; the general case requires SVD).

**Domain Bridges:** Matrix optimization ↔ Information geometry ↔ Coding theory (water-filling in channel capacity)

**Lineage:** Generalization of `sup_eq_rms_of_balanced` from diagonal to block-diagonal.

**Ambition:** Grand Challenge — proving the full block-diagonal case requires new SVD-based machinery in Lean/Mathlib.

---

## Direction 3: Probabilistic Amplification Bounds

**Conjecture:** For subgaussian noise vectors e ~ SubGaussian(σ²) in ℝᵏ, the typical amplification is controlled by rmsAmp rather than the operator norm:

    P(||f(e)|| > t · rmsAmp(f) · σ · √k) ≤ 2 exp(-t²/2)

This is a dimension-free concentration inequality that would show rmsAmp is the "right" quantity for probabilistic correctness analysis.

**Test:** Monte Carlo simulation with 10⁶ samples for various k and f. Compare empirical tail quantiles to both the operator-norm bound and the rmsAmp bound. Disprove if empirical tails consistently track the operator norm more closely than rmsAmp.

**Impact:** This would transform cryptographic correctness proofs from worst-case to average-case, potentially tightening decryption failure bounds by orders of magnitude for well-structured compression.

**Catalog References:**
- `Pythagorean/SpectralCompression.lean` — `rmsAmp_le_opNorm_le_sqrt_card_mul_rmsAmp`
- `Cryptography/ModuleLWE/Compression.lean` — `decode_correct_of_linear_noise_bound`

**Proof Strategy:** The formal proof would require:
1. A Lean formalization of subgaussian random variables (partially available in Mathlib).
2. A Hanson-Wright inequality or rotation-invariance argument.
3. The key insight: for rotation-invariant noise, the amplification distribution depends only on the singular value spectrum, and rmsAmp captures the RMS of this spectrum.

**Domain Bridges:** Probability theory ↔ Random matrix theory ↔ High-dimensional statistics

**Lineage:** Extension of the deterministic √k bound to probabilistic setting.

**Ambition:** Grand Challenge — requires probability theory integration that goes beyond current Mathlib.

---

## Direction 4: Multi-Stage Compression Pipelines

**Conjecture:** For composed compression maps f = gₘ ∘ ... ∘ g₁, the RMS amplification satisfies:

    rmsAmp(f) ≤ ∏ᵢ rmsAmp(gᵢ)

with equality iff all gᵢ have the same singular subspaces (commuting case).

**Test:** Construct explicit 2-stage and 3-stage compressions with varying alignment between singular subspaces. Compute rmsAmp of the composition and compare to the product of individual rmsAmps. Disprove by finding a composition where rmsAmp(f) > ∏ rmsAmp(gᵢ).

**Impact:** Multi-stage compression arises naturally in lattice KEM designs (key compression + ciphertext compression). A submultiplicativity result for rmsAmp would enable modular correctness analysis.

**Catalog References:**
- `Pythagorean/SpectralCompression.lean` — `rmsAmp_le_opNorm`, `opNorm_le_sqrt_card_mul_rmsAmp`
- `Cryptography/ModuleLWE/Compression.lean` — `decode_correct_of_composed_compression`

**Proof Strategy:** Start with the diagonal case (where composition = componentwise product, and submultiplicativity follows from the AM-QM inequality). Then generalize using SVD decomposition.

**Domain Bridges:** Functional analysis (operator composition) ↔ Signal processing (cascaded filters) ↔ Cryptographic protocol design

**Lineage:** Builds on `decode_correct_of_composed_compression` by replacing operator norm with rmsAmp.

**Ambition:** Medium-High — the diagonal case is tractable; the general case requires SVD.

---

## Direction 5: Isoperimetric Characterization of Optimal Compression

**Conjecture:** The balanced compression operators (those achieving anisotropyRatio = 1) are precisely the conformal linear maps — those preserving angles between vectors. The √k gap theorem is an instance of a broader isoperimetric phenomenon: among all linear maps with fixed "volume" (determinant or Frobenius norm), the conformally symmetric ones minimize the "surface area" (operator norm / worst-case distortion).

**Test:** For k = 3 and k = 4, enumerate all compression operators with fixed Frobenius norm. Verify that the operator norm is minimized exactly at the conformal points. Check whether the inequality curve matches known isoperimetric profiles.

**Impact:** This would connect cryptographic compression design to one of the deepest themes in geometric analysis — isoperimetric inequalities. It would provide a principled geometric framework for understanding why balanced designs are optimal.

**Catalog References:**
- `Pythagorean/SpectralCompression.lean` — `sup_eq_rms_of_balanced`, `rms_le_sup`

**Proof Strategy:** The conformal characterization for diagonal maps is exactly our `balancedEntries` condition. The general case requires showing that the operator norm, viewed as a function on the Grassmannian of linear maps with fixed Frobenius norm, achieves its minimum on the orbit of scalar multiples of partial isometries.

**Domain Bridges:** Geometric measure theory ↔ Riemannian geometry ↔ Optimal transport ↔ Cryptographic design

**Lineage:** Conceptual generalization of the equipartition principle to geometric setting.

**Ambition:** Grand Challenge — connects to deep mathematics (isoperimetric theory) but the formal prerequisites are substantial.
