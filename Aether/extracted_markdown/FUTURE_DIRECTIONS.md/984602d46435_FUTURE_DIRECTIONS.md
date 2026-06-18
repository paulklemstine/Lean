# Future Directions

## Synthesis

The formalization of the Fujisaki-Okamoto transform as a quotient-theoretic invariant opens a systematic program for connecting module algebra, game-based cryptographic security, and information theory. The core discovery — that the FO consistency predicate factors through compression morphisms — is the first step in what could become a general theory of **security-preserving algebraic morphisms**. The directions below form a coherent arc: Direction 1 tests whether the framework extends to the actual deployed standard; Direction 2 explores a deeper algebraic structure (implicit rejection as a cohomological obstruction); Directions 3-4 probe the information-theoretic and coding-theoretic boundaries; and Direction 5 aims at the grand challenge of fully automated CCA verification.

---

## Direction 1: ML-KEM Parameter Instantiation and FIPS 203 Verification

**Conjecture:** For the specific parameters of ML-KEM-512, ML-KEM-768, and ML-KEM-1024 (FIPS 203), the compression maps used in ciphertext compression satisfy the quotient invariance conditions of Theorem 1, and the centered binomial noise distribution $\text{CBD}_\eta$ is kernel-invariant with respect to these compression maps.

**Test:** Formalize the ML-KEM compression function `Compress_q(x, d)` = `⌈(2^d / q) · x⌋ mod 2^d` as a function on `ZMod q`, compute the induced fibers for `q = 3329` and `d ∈ {1, 4, 5, 10, 11}`, and verify kernel invariance of `CBD_2` and `CBD_3` computationally. A single fiber where the centered binomial assigns different total weights would refute the conjecture.

**Impact:** A positive result would give a machine-verifiable path to CCA security of the actual NIST standard. This would be the first formal verification of ML-KEM's FO transform using algebraic rather than bit-level reasoning.

**Catalog References:** `Cryptography/FOTransform.lean` (Theorems 1-3), `Cryptography/ModuleLWE/Defs.lean` (KernelInvariantError), `Cryptography/ModuleLWE/Compression.lean` (compression correctness).

**Proof Strategy:** Formalize `Compress_q` as a linear map on `ZMod q`-modules. The key challenge is that rounding is not strictly linear — it involves a floor/ceiling operation. The strategy is to decompose compression as a linear map plus a rounding error, show the rounding error is bounded, and prove that the FO predicate is robust to this perturbation.

**Domain Bridges:** Cryptography ↔ Number Theory (properties of `q = 3329`, an NTT-friendly prime), Cryptography ↔ Module Theory (quotient structure of `(ZMod 3329)^256`).

**Lineage:** Builds directly on `foConsistent_factors_through_quotient` and `foRejectProb_map_eq`.

**Ambition:** *Solid extension* — high-impact practical verification, well-defined scope.

---

## Direction 2: Implicit Rejection as Cohomological Obstruction

**Conjecture:** The implicit rejection variant of FO (where rejection returns `H(s, ct)` instead of `⊥`) can be modeled as a **twisted quotient** — the FO consistency predicate factors through a quotient only up to a cocycle determined by the hash function `H`. The cohomological obstruction to exact factorization measures the additional security loss introduced by implicit vs. explicit rejection.

**Test:** Define a formal notion of "twisted factorization" where the descended predicate depends on both the quotient element and a cocycle value. Compute the cohomological obstruction for toy instances with `q ≤ 11` and verify whether the obstruction size correlates with the security gap between implicit and explicit rejection measured in concrete game-hopping proofs.

**Impact:** This would provide the first algebraic explanation for why implicit rejection introduces a tighter security proof. If the cohomology is trivial for ML-KEM's specific parameters, it would show that the implicit/explicit distinction vanishes at the algebraic level — a conceptual simplification of the security proof.

**Catalog References:** `Cryptography/FOTransform.lean` (PredicateFactorsThrough), `Cryptography/LWE/Security.lean` (hybrid game framework).

**Proof Strategy:** Define $H^1(\ker f, \{0,1\})$ as the group of twisted descent data. Show that explicit rejection corresponds to the trivial cocycle and implicit rejection to a potentially nontrivial one. Use the long exact sequence in cohomology to bound the obstruction.

**Domain Bridges:** Cryptography ↔ Algebraic Topology (group cohomology), Cryptography ↔ Game Semantics (twisted game transformations).

**Lineage:** Novel extension of the quotient invariance framework.

**Ambition:** *Grand challenge* — if true, this would create a new bridge between cryptographic security and algebraic topology.

---

## Direction 3: Quotient-Optimal Compression Design

**Conjecture:** Among all linear compression maps $f: (\mathbb{Z}/q\mathbb{Z})^n \to (\mathbb{Z}/q\mathbb{Z})^m$ with $m < n$, the maps that minimize FO rejection probability under a given noise distribution are exactly those whose kernel is maximally aligned with the noise distribution's support. Formally, the optimal compression minimizes $\sum_{k \in \ker f} |\mu(x) - \mu(x+k)|$ over all $x$.

**Test:** For $q \in \{5, 7, 11\}$ and $n = 3$, $m = 2$, enumerate all linear maps (up to equivalence), compute FO rejection rates under centered and uniform noise, and check whether the minimum-rejection map has the predicted kernel alignment property. A case where a non-aligned kernel achieves lower rejection would refute the conjecture.

**Impact:** A design principle for compression in lattice KEMs: choose compression maps whose kernels are "noise-invisible." This could improve concrete parameters for future standards.

**Catalog References:** `Cryptography/FOTransform.lean` (KernelInvariant, foRejectProb_map_eq), `Cryptography/ModuleLWE/Compression.lean`.

**Proof Strategy:** Express the rejection probability as a function of the kernel geometry. Use the Poisson summation formula on $\mathbb{Z}/q\mathbb{Z}$ to relate kernel alignment to Fourier coefficients of the noise distribution.

**Domain Bridges:** Cryptography ↔ Harmonic Analysis (Fourier analysis on finite groups), Cryptography ↔ Coding Theory (dual code geometry).

**Lineage:** Extends the computational experiments in `demo.py` and `applications.py`.

**Ambition:** *Solid extension* — practical design guidance backed by formal theory.

---

## Direction 4: Information-Theoretic Characterization of FO Security Loss

**Conjecture:** The FO security loss (the gap `CCA_adv - CPA_adv`) equals the mutual information $I(C; E | f(C))$ between the ciphertext $C$ and the noise $E$ conditioned on the compressed ciphertext $f(C)$, up to a universal constant. In particular, when the noise is kernel-invariant, this mutual information is zero and the security loss equals zero.

**Test:** For toy instances, compute both the FO rejection probability and the conditional mutual information $I(C; E | f(C))$ under uniform and non-uniform noise distributions. Verify whether $\text{FO\_reject} = I(C; E | f(C))$ holds exactly or approximately. A significant deviation would refute exact equality, while approximate agreement would suggest the relationship holds up to logarithmic factors.

**Impact:** This would establish the FO transform as an information-theoretic **channel coding** problem: the security loss is exactly the information leakage through the compression channel. This bridges post-quantum cryptography to Shannon theory.

**Catalog References:** `Cryptography/FOTransform.lean` (fo_game_hop_bound), `Cryptography/ModuleLWE/Defs.lean` (KernelInvariantError).

**Proof Strategy:** Use the data processing inequality to upper-bound the mutual information, then construct a matching lower bound using the game hop argument. The key insight is that the "bad event" in the game hop is precisely the event where $f(C)$ loses information about whether re-encryption will match.

**Domain Bridges:** Cryptography ↔ Information Theory (mutual information, data processing), Cryptography ↔ Statistics (sufficient statistics).

**Lineage:** Extends the sufficient-statistic interpretation in the research paper.

**Ambition:** *Grand challenge* — would unify game-based and information-theoretic approaches to CCA security.

---

## Direction 5: Automated CCA Verification via Algebraic Condition Checking

**Conjecture:** For any lattice-based KEM whose compression is a linear map and whose noise distribution is a product distribution on coordinates, the quotient invariance conditions (Theorems 1-3) can be verified by a decision procedure that checks: (a) the compression matrix has the correct rank, (b) the noise distribution is kernel-invariant (checkable by comparing Fourier coefficients on the kernel's dual), and (c) the re-encryption function is affine in the ciphertext coordinates. These three checks are sufficient for CCA security transfer.

**Test:** Implement the decision procedure and run it on: (i) ML-KEM's actual parameters (expected: pass), (ii) Saber's parameters (expected: pass with modification for rounding), (iii) a deliberately broken scheme where the noise is not kernel-invariant (expected: fail). A false positive (procedure says "secure" for a scheme with known CCA attacks) would refute the conjecture.

**Impact:** Fully automated CCA verification for lattice KEMs. Instead of writing custom security proofs for each new scheme, designers would run a checker that verifies algebraic conditions. This could become a standard tool for NIST's post-quantum standardization process.

**Catalog References:** All of `Cryptography/FOTransform.lean`, `Cryptography/LWE/Security.lean` (CPA reductions), `Cryptography/ModuleLWE/Compression.lean` (operator norm bounds).

**Proof Strategy:** Formalize the decision procedure in Lean 4 as a `Decidable` instance. The main challenge is showing that the Fourier-based kernel invariance check is both sound and complete. Use Pontryagin duality on finite abelian groups to establish the equivalence.

**Domain Bridges:** Cryptography ↔ Automata/Decision Procedures, Cryptography ↔ Harmonic Analysis, Cryptography ↔ Formal Methods.

**Lineage:** Culmination of the entire quotient invariance program.

**Ambition:** *Grand challenge* — would transform how post-quantum KEMs are verified and standardized.
