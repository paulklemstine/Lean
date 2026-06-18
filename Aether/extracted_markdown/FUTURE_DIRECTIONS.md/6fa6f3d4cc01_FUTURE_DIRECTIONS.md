# Future Directions

## Synthesis

The module-theoretic framework developed in this work establishes that the core arguments of lattice cryptography — hybrid telescoping, quotient indistinguishability, TVD contraction, and operator-norm correctness — are instances of universal algebraic principles. This opens five concrete research directions, ranging from immediate extensions building on catalog theorems to grand-challenge goals that could transform how post-quantum standards are verified. All directions share a common thread: the insight that cryptographic reductions are transport theorems in module categories, and that this perspective enables both machine verification and new mathematical discoveries.

---

## Direction 1: Complete Verified Regev Reduction

**Conjecture:** The complete Regev reduction — from worst-case GapSVP to average-case decision-LWE — can be decomposed into module-theoretic components and fully machine-verified, using the hybrid telescope (Theorem B) and TVD contraction (Theorem A') as building blocks.

**Test:** Formalize the four components of the Regev reduction:
1. GapSVP → BDD reduction (classical, algebraic)
2. Quantum sampling subroutine (specify target distribution, verify moments computationally)
3. Search-LWE → Decision-LWE (already covered by `search_from_decision_as_special_case`)
4. Dimension/modulus reduction (formalize as quotient map, verify TVD contraction)

Attempt to prove each component in Lean 4. The conjecture is falsified if any component requires mathematical machinery fundamentally outside the module-theoretic framework.

**Impact:** A complete, machine-verified Regev reduction would be the first fully formal proof of worst-case hardness for any post-quantum cryptographic primitive. This would set the standard for all future cryptographic standardization.

**Catalog References:** `Cryptography/LWE/Security.lean` (search_from_decision_coordinate, hybrid_telescope_bound), `Cryptography/ModuleLWE/SearchDecision.lean` (abstract_hybrid_telescope), `Cryptography/ModuleLWE/TVDContraction.lean` (tvd_contracts_under_linear_pushforward)

**Proof Strategy:** Decompose into 8-12 independent lemmas. The classical components (GapSVP→BDD, dimension reduction) should be provable with current Mathlib. The quantum sampling step requires formalizing discrete Gaussian distributions, which may need new Mathlib contributions.

**Domain Bridges:** Lattice geometry ↔ Quantum computation ↔ Module theory ↔ Probability theory

**Lineage:** Direct extension of Theorems A', B, C from this work.

**Ambition:** ★★★★★ — Grand challenge. Would be a landmark in formal verification.

---

## Direction 2: Fujisaki-Okamoto Transform as Module Morphism

**Conjecture:** The Fujisaki-Okamoto (FO) transform, which converts CPA-secure encryption to CCA-secure key encapsulation, can be expressed as a consistency predicate preserved under module morphisms. Specifically, the FO decapsulation check `re-encrypt and compare` factors through the quotient map `M → M/ker(f)` whenever the error distribution is kernel-invariant.

**Test:** 
1. Define `FOConsistentCiphertext` as a predicate on ciphertexts.
2. Prove that for kernel-invariant noise, `FOConsistentCiphertext` is preserved by compression.
3. Verify computationally on toy instances (q ≤ 11, n ≤ 3) that FO rejection rates are unchanged by compression.

**Impact:** Would enable formal verification of the full ML-KEM specification (FIPS 203), including CCA security. Currently, no proof assistant has a verified FO transform for lattice-based systems.

**Catalog References:** `Cryptography/LWE/Security.lean` (dualRegev_decrypt_encrypt_eq, dualRegev_cpa_security_of_lwe), `Cryptography/ModuleLWE/KernelQuotient.lean` (acceptProb_map_eq)

**Proof Strategy:** Define the FO transform abstractly as a game transformation. Show that CCA advantage ≤ CPA advantage + Pr[FO rejection] using the hybrid framework. Bound Pr[FO rejection] using the compression correctness theorem (Theorem C).

**Domain Bridges:** Cryptography ↔ Game theory ↔ Module theory

**Lineage:** Extends Theorems A and C to the CCA setting.

**Ambition:** ★★★★☆ — High impact, technically demanding.

---

## Direction 3: Quotient Security Monotonicity — Proof or Counterexample

**Conjecture:** For every finite module-LWE instance with kernel-invariant error distribution and surjective linear compression `f : M →ₗ[R] N`, the best distinguishing advantage after compression is never greater than before compression. Formally:

```
∀ D : N → Bool, ∃ D' : M → Bool,
  |acceptProb(f_*χ, D) - 1/2| ≤ |acceptProb(χ, D') - 1/2|
```

**Test:** 
1. Exhaustively verify for all `(Z/qZ)^n → Z/qZ` with q ≤ 7, n ≤ 3.
2. Search for counterexamples in non-abelian module settings.
3. If no counterexample is found for q ≤ 11, attempt a proof using the Neyman-Pearson lemma for optimal distinguishers.

**Impact:** A proof would give a clean, quantitative bound on how much security margin compression provides. A counterexample would reveal subtle obstructions to modular security composition.

**Catalog References:** `Cryptography/ModuleLWE/SearchDecision.lean` (quotientSecurityMonotonicity_conjecture), `Cryptography/ModuleLWE/KernelQuotient.lean` (acceptProb_map_eq)

**Proof Strategy:** For the proof direction: use the fact that `acceptProb(f_*χ, D) = acceptProb(χ, D∘f)` (already proved) to show that `D' = D∘f` is a valid witness. The conjecture then reduces to showing that `D∘f` achieves at least as much advantage as `D`. For the counterexample direction: search over non-surjective maps or structured (non-kernel-invariant) distributions.

**Domain Bridges:** Probability theory ↔ Module theory ↔ Information theory

**Lineage:** Builds on Theorem A (acceptProb_map_eq) and the conjecture stated in SearchDecision.lean.

**Ambition:** ★★★☆☆ — Achievable within one research cycle.

---

## Direction 4: Operator-Norm Optimization for Concrete Parameters

**Conjecture:** For ML-KEM-768, the operator-norm bound `‖f‖ · δ` used in Theorem C overestimates the actual noise amplification by at most a factor of √k (where k is the module rank), and this factor can be made tight by choosing the compression matrix to minimize the operator norm while maintaining the required compression ratio.

**Test:**
1. Compute exact operator norms for the NTT-domain compression matrices used in ML-KEM.
2. Compare the operator-norm bound with the actual maximum noise amplification over all error vectors of norm ≤ δ.
3. Search for compression matrices that achieve smaller operator norms while preserving the ML-KEM structure.

**Impact:** Tighter operator-norm bounds translate directly to smaller ciphertext sizes or larger security margins. A factor-of-√k improvement could enable more aggressive parameter choices in future standards.

**Catalog References:** `Cryptography/ModuleLWE/Compression.lean` (decode_correct_of_linear_noise_bound, decode_correct_of_composed_compression)

**Proof Strategy:** Use the SVD decomposition of the compression matrix to compute exact operator norms. The gap between ‖f‖ · δ and max‖f(e)‖ for ‖e‖ ≤ δ depends on the alignment of the noise distribution with the singular vectors of f.

**Domain Bridges:** Functional analysis ↔ Cryptographic engineering ↔ Optimization

**Lineage:** Extends Theorem C to the concrete parameter regime.

**Ambition:** ★★☆☆☆ — Directly applicable, moderate difficulty.

---

## Direction 5: Non-Commutative Module-LWE and NTRU

**Conjecture:** The module-theoretic framework extends to non-commutative base rings, enabling a unified treatment of NTRU-style systems alongside LWE-based systems. Specifically, the TVD contraction theorem (Theorem A') and the hybrid telescope (Theorem B) hold verbatim when `R` is a non-commutative ring and `M, N` are left `R`-modules.

**Test:**
1. Verify that the proofs of Theorems A' and B do not use commutativity of `R` (they should not, since the proofs are about finite sums and absolute values, not ring operations).
2. Formalize a Module-NTRU instance as a left module over a non-commutative ring.
3. Derive the NTRU security reduction from the abstract module theorems.

**Impact:** Would unify the security foundations of LWE-based and NTRU-based post-quantum cryptography into a single verified framework. NTRU is used in several alternative PQ standards (e.g., NTRU-HRSS, SNTRUP).

**Catalog References:** `Cryptography/ModuleLWE/TVDContraction.lean`, `Cryptography/ModuleLWE/SearchDecision.lean`, `Cryptography/ModuleLWE/KernelQuotient.lean`

**Proof Strategy:** Audit existing proofs for commutativity assumptions. The only place `CommRing R` appears in our theorems is in the type signatures — the proofs themselves work over arbitrary functions between finite types. For the NTRU instantiation, define the relevant non-commutative rings (group algebras) and module structures.

**Domain Bridges:** Non-commutative algebra ↔ Cryptography ↔ Lattice theory

**Lineage:** Generalizes all four main theorems to the non-commutative setting.

**Ambition:** ★★★☆☆ — Conceptually clean but requires careful Lean engineering.
