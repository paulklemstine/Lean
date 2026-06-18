# Future Directions: Non-Commutative Module-LWE and Beyond

## Synthesis

The theorems proved in this work — TVD contraction for arbitrary functions, the hybrid telescope, and the NTRU-Module-LWE bridge — reveal a clean factorization of lattice cryptographic security proofs into:

1. **Measure-theoretic core** (data processing inequality, triangle inequality) — ring-agnostic
2. **Algebraic construction layer** (linear maps, module structure) — provides the maps
3. **Hardness layer** (computational assumptions) — ring-specific

This factorization opens five concrete research directions, each building directly on the verified theorems and each falsifiable by explicit computation or formal proof attempt.

---

## Direction 1: Fiberwise Characterization of Contraction Tightness

**Conjecture:** The contraction inequality $d_{TV}(f_*\mu, f_*\nu) \leq d_{TV}(\mu, \nu)$ is tight (equality holds) if and only if the signed measure $\mu - \nu$ is *fiberwise coherent*: for each fiber $f^{-1}(b)$, the restriction $(\mu - \nu)|_{f^{-1}(b)}$ does not change sign.

**Test:** Enumerate all functions $f : \mathbb{Z}/n\mathbb{Z} \to \mathbb{Z}/m\mathbb{Z}$ for small $n, m \leq 8$. For each $f$, sample 1000 random pairs $(\mu, \nu)$, compute exact TVD before and after pushforward, and check whether tightness correlates with fiberwise sign coherence. A single counterexample disproves the conjecture.

**Impact:** This would provide a complete geometric characterization of when security reductions are tight — critical for optimal parameter selection in cryptographic standards.

**Catalog References:**
- `Cryptography/NoncommModuleLWE/TVDContraction.lean`: `coarse_graining_contracts_tvd`
- `Cryptography/ModuleLWE/Defs.lean`: `tvd` definition

**Proof Strategy:** Prove the forward direction (sign coherence → tightness) by showing the triangle inequality is tight for same-sign terms. The reverse direction should follow from constructing a sign-incoherent perturbation that introduces strict inequality.

**Domain Bridges:** Information theory (data processing inequality tightness), statistical mechanics (entropy production bounds), lattice geometry (quotient flatness).

**Lineage:** Extends `coarse_graining_contracts_tvd` with an equality characterization.

**Ambition:** ★★★ — Moderate difficulty, high utility for parameter selection.

---

## Direction 2: Worst-Case to Average-Case Reductions for Group-Ring Modules

**Conjecture:** For finite solvable groups $G$ and fields $k$ with $\text{char}(k) \nmid |G|$, the worst-case to average-case reduction for the Short Vector Problem on left $k[G]$-modules can be established using the Wedderburn decomposition $k[G] \cong \prod M_{n_i}(D_i)$.

**Test:** Implement the Wedderburn decomposition for $G = S_3$ over $\mathbb{F}_7$ (where $\text{char} \nmid |S_3| = 6$). Verify that the decomposition into matrix blocks preserves the lattice structure. Check whether the reduction from matrix-ring SVP to block-diagonal SVP is polynomially tight by computing condition numbers for random instances.

**Impact:** This would establish the first hardness foundation for non-commutative Module-LWE, converting our reduction-theoretic framework into a full security proof.

**Catalog References:**
- `Cryptography/NoncommModuleLWE/HybridTelescope.lean`: `NoncommModuleLWEParams`, `NTRUInstance`
- `Cryptography/NoncommModuleLWE/TVDContraction.lean`: `tvd_map_le_of_leftLinear`

**Proof Strategy:** Use the Artin-Wedderburn structure theorem to decompose the module into simple components. Reduce SVP on each component to matrix-lattice SVP. The semisimplicity condition ($\text{char}(k) \nmid |G|$) is essential for clean decomposition.

**Domain Bridges:** Representation theory (Wedderburn structure), number theory (algebraic number fields in simple components), lattice theory (sublattice structure under decomposition).

**Lineage:** Grand challenge building on the NTRU bridge theorem.

**Ambition:** ★★★★★ — Paradigm-shifting if achieved; would open verified non-commutative post-quantum cryptography.

---

## Direction 3: Entropy Production Under Linear Pushforward

**Conjecture:** For a surjective linear map $\phi : M \twoheadrightarrow N$ between finite modules with kernel $K = \ker \phi$, the *entropy production* satisfies:

$$H(f_*\mu) - H(\mu) = -\sum_{b \in N} (f_*\mu)(b) \cdot H(\mu | f^{-1}(b))$$

where $H(\mu | f^{-1}(b))$ is the conditional entropy on the fiber. Moreover, the TVD contraction slack is bounded by a function of the fiberwise entropy variance.

**Test:** Compute exact entropy values for all linear maps $\phi : (\mathbb{Z}/p\mathbb{Z})^3 \to (\mathbb{Z}/p\mathbb{Z})^2$ with $p = 3, 5$. Verify the entropy production formula and correlate TVD slack with fiberwise entropy statistics.

**Impact:** Connects the cryptographic contraction principle to Shannon-theoretic entropy bounds, potentially enabling tighter security reductions based on entropy rather than TVD alone.

**Catalog References:**
- `Cryptography/NoncommModuleLWE/TVDContraction.lean`: `coarse_graining_contracts_tvd`
- `Cryptography/ModuleLWE/Defs.lean`: `KernelInvariantError`

**Proof Strategy:** Decompose the pushforward using the fiber structure, apply the chain rule for entropy, relate the TVD slack to the KL-divergence using Pinsker's inequality.

**Domain Bridges:** Information theory (entropy, KL-divergence, Pinsker's inequality), statistical mechanics (coarse-graining entropy production), cryptography (entropy-based security notions).

**Lineage:** Extends `coarse_graining_contracts_tvd` with entropy-theoretic refinements.

**Ambition:** ★★★★ — Significant theoretical advance connecting two formalized domains.

---

## Direction 4: Non-Abelian Fourier Analysis for Security Bounds

**Conjecture:** For $R = k[G]$ with non-abelian $G$, the one-step advantage $d_{TV}(\phi_*\mu, U_N)$ can be bounded in terms of the non-abelian Fourier coefficients of $\mu$ via:

$$d_{TV}(\phi_*\mu, U_N)^2 \leq \frac{1}{4} \sum_{\rho \neq \text{triv}} d_\rho \cdot \|\hat{\mu}(\rho)\|_F^2$$

where $\rho$ ranges over nontrivial irreducible representations of $G$, $d_\rho$ is the dimension, and $\|\cdot\|_F$ is the Frobenius norm.

**Test:** For $G = S_3$ and several choices of $\mu$ (uniform on short elements), compute both sides numerically. A violation disproves the conjecture; consistent agreement supports it.

**Impact:** Would provide quantitative bounds for non-commutative Module-LWE security in terms of representation-theoretic data — a breakthrough connecting representation theory to cryptographic hardness.

**Catalog References:**
- `Cryptography/NoncommModuleLWE/HybridTelescope.lean`: `oneStepAdvantage`
- `Cryptography/NoncommModuleLWE/TVDContraction.lean`: `tvd_map_le_of_leftLinear`

**Proof Strategy:** Generalize the abelian Fourier bound (used in Ring-LWE analysis) to the non-abelian setting using Peter-Weyl orthogonality. The matrix-valued Fourier transform replaces scalar coefficients.

**Domain Bridges:** Harmonic analysis (non-abelian Fourier transform), representation theory (irreducible decomposition), number theory (character sums over non-abelian groups).

**Lineage:** Grand challenge extending the framework into harmonic analysis.

**Ambition:** ★★★★★ — Would open a new field of representation-theoretic cryptanalysis.

---

## Direction 5: Compositional Security for Multi-Stage Non-Commutative Protocols

**Conjecture:** For a composition of $k$ left-linear maps $\phi_1, \ldots, \phi_k$ with $\phi_i : M_i \to M_{i+1}$, the composed contraction satisfies:

$$d_{TV}((\phi_k \circ \cdots \circ \phi_1)_*\mu, (\phi_k \circ \cdots \circ \phi_1)_*\nu) \leq d_{TV}(\mu, \nu)$$

and the slack decomposes as:

$$\text{slack}_{\text{total}} \geq \max_i \text{slack}_i$$

where $\text{slack}_i$ is the contraction slack at stage $i$.

**Test:** Verify the composition inequality (already proved as `tvd_map_map_le`) and test the slack decomposition conjecture numerically for chains of 3-5 linear maps over $(\mathbb{Z}/5\mathbb{Z})^4$.

**Impact:** Enables modular security analysis for multi-round cryptographic protocols, where each round applies a different linear transformation.

**Catalog References:**
- `Cryptography/NoncommModuleLWE/HybridTelescope.lean`: `tvd_map_map_le`
- `Cryptography/NoncommModuleLWE/TVDContraction.lean`: `coarse_graining_contracts_tvd`

**Proof Strategy:** The inequality is already proved. The slack decomposition requires analyzing the interaction between fibers at successive stages — likely using the fiber product structure.

**Domain Bridges:** Protocol analysis (compositional security), category theory (functorial structure of pushforward), database privacy (composition theorems for differential privacy).

**Lineage:** Direct extension of `tvd_map_map_le`.

**Ambition:** ★★★ — Moderate difficulty, high practical relevance for protocol design.
