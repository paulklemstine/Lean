# Future Directions: Tropical Leaf Witness Theory

## Synthesis

The tropical leaf witness theory established here — showing that spectral certificates of derivative leaves are bounded by combinatorial coefficient invariants — opens a systematic program at the intersection of tropical geometry, spectral theory, and discrete optimization. The five directions below trace a coherent arc: from tightening the current bound (Direction 1), to extracting arithmetic content via $p$-adic valuations (Direction 2), to connecting with matroid theory (Direction 3), to applying the framework to quantum certification (Direction 4), to the grand challenge of a fully tropical Lorentzian theory (Direction 5). Each builds on the formal infrastructure created in this cycle, and each produces testable predictions.

---

## Direction 1: Newton Polytope Refinement of Tropical Witnesses

**Conjecture:** For a Lorentzian polynomial $p$ with nonneg coefficients, the tropical leaf witness can be tightened by restricting the coefficient sum to the *vertices* of the Newton polytope of $L_A(p)$, rather than summing over the entire support. Specifically:

$$W_{\mathrm{spec}}(p, A) \leq \sum_{a \in A} \sum_{v \in \mathrm{Vert}(\mathrm{Newt}(\partial_a^2 L_A))} |c_v|$$

This vertex-restricted witness would be strictly tighter than the full $L^1$ norm and would connect the bound to polyhedral geometry.

**Test:** For DPP polynomials of size $n = 6, 8$, compute both the full tropical witness and the vertex-restricted witness. Measure the ratio $W_{\mathrm{vert}} / W_{\mathrm{trop}}$. If $W_{\mathrm{vert}}$ is significantly smaller while still bounding $W_{\mathrm{spec}}$, the conjecture holds.

**Impact:** This would transform the tropical witness from an $L^1$ bound to a *polyhedral* bound, connecting directly to the theory of Newton polytopes and mixed volumes. It would also improve the algorithmic efficiency: for sparse polynomials with few vertices, the vertex witness is much cheaper to compute.

**Catalog References:**
- `Pythagorean/TropicalLeafWitnesses/Defs.lean` — `tropicalLeafWitness`, `derivativeFace`
- `Pythagorean/TropicalLeafWitnesses/Theorems.lean` — `leafWitness_le_tropicalLeafWitness`

**Proof Strategy:** Define the vertex-restricted witness in Lean using `Finset.filter` on the support. Prove tightening by showing that for nonneg-coefficient polynomials, $|p(\mathbf{1})| = p(\mathbf{1}) = \sum c_\alpha \leq \sum_{v \in \mathrm{Vert}} c_v \cdot (\text{face volume factor})$.

**Domain Bridges:** Convex geometry (Newton polytopes) ↔ Tropical geometry ↔ Spectral theory

**Lineage:** Direct extension of `leafWitness_le_tropicalLeafWitness`.

**Ambition:** 🔬 Solid extension — tightens existing bound.

---

## Direction 2: $p$-Adic Tropical Witnesses and Arithmetic Invariants

**Conjecture:** For a polynomial $p \in \mathbb{Q}[x_1, \ldots, x_n]$ and a prime $q$, define the $q$-adic tropical leaf witness as:

$$W_{\mathrm{trop}}^{(q)}(p, A) := \sum_{a \in A} \sum_{\alpha \in \mathrm{supp}(\partial_a^2 L_A)} |v_q(c_\alpha)|$$

where $v_q$ is the $q$-adic valuation. Then:

$$\log |W_{\mathrm{spec}}(p, A)| \leq C(A) \cdot \max_q W_{\mathrm{trop}}^{(q)}(p, A)$$

for some explicit constant $C(A)$ depending on the subsystem size.

**Test:** For DPP polynomials with rational entries, compute $W_{\mathrm{trop}}^{(q)}$ for primes $q = 2, 3, 5, 7, 11$ and compare against $\log W_{\mathrm{spec}}$. A single counterexample (where the inequality fails for all tested primes) would refute the conjecture.

**Impact:** This would establish *arithmetic tropical witnesses* — invariants that capture number-theoretic structure invisible to the archimedean absolute value. It would connect the theory to $p$-adic geometry, Berkovich spaces, and arithmetic intersection theory.

**Catalog References:**
- `Pythagorean/TropicalLeafWitnesses/Defs.lean` — `tropCoeff`, `tropSupport`
- `Catalog/Speculative/AutoResearch/DPPLorentzian.lean` — `dppPartitionFunction`

**Proof Strategy:** Formalize $p$-adic valuations as instances of `IsKrullValuation`. Use the product formula $\prod_v |x|_v = 1$ to relate archimedean and non-archimedean witnesses.

**Domain Bridges:** Number theory ($p$-adic valuations) ↔ Tropical geometry ↔ Spectral theory

**Lineage:** Extends `tropCoeff` definition to non-archimedean valuations.

**Ambition:** 🔭 Grand challenge — requires deep arithmetic input.

---

## Direction 3: Submodularity and Valuated Matroid Structure

**Conjecture:** For DPP polynomials $Z_K$ with PSD kernel $K$, the tropical leaf witness $A \mapsto W_{\mathrm{trop}}(Z_K, A)$ is a submodular set function:

$$W_{\mathrm{trop}}(Z_K, A) + W_{\mathrm{trop}}(Z_K, B) \geq W_{\mathrm{trop}}(Z_K, A \cap B) + W_{\mathrm{trop}}(Z_K, A \cup B)$$

If true, this would imply that the tropical witness can be optimized by greedy algorithms, and that it defines a *valuated matroid* on the ground set.

**Test:** Generate 100 random PSD kernels of sizes $n = 4, 5, 6$. For each, compute $W_{\mathrm{trop}}(A)$ for all $2^n$ subsets and verify the submodularity inequality for all $2^{2n}$ pairs $(A, B)$.

**Impact:** This would connect the tropical leaf witness to the rich theory of submodular optimization, matroid intersection, and discrete convex analysis. It would enable efficient (greedy, $O(n^2)$) computation of optimal subsystems — those with maximum tropical witness.

**Catalog References:**
- `Pythagorean/TropicalLeafWitnesses/Defs.lean` — `IsSubmodularOn`, `dppTropicalLeafWitness`
- `Catalog/Speculative/AutoResearch/DPPLorentzian.lean` — `DPPKernel`, `dpp_pairwise_negative_dependence`

**Proof Strategy:** Use the Cauchy-Binet formula to express principal minors of $K$ as sums of squared minors of factor matrices. Show that the $L^1$ norm of derivatives inherits submodularity from the log-submodularity of determinants.

**Domain Bridges:** Matroid theory ↔ Combinatorial optimization ↔ Tropical geometry ↔ Machine learning (DPP diversity)

**Lineage:** Builds on `dpp_pairwise_negative_dependence` and computational evidence from `demo.py`.

**Ambition:** 🔬 Solid extension — computationally verified, proof strategy is clear.

---

## Direction 4: Tropical Entanglement Certificates

**Conjecture:** For multipartite quantum states whose density matrix coefficients define a polynomial, the tropical leaf witness provides a device-independent certificate for genuine multipartite entanglement. Specifically, if $W_{\mathrm{trop}}(p, A) > 0$ for all proper subsets $A$ of the parties, then the state exhibits genuine multipartite entanglement.

**Test:** Construct the GHZ state and W-state polynomials for $n = 3, 4$ parties. Compute tropical leaf witnesses for all bipartitions and tripartitions. Verify that entangled states have nonzero witnesses while separable states have zero witnesses.

**Impact:** This would establish the first formal connection between tropical geometry and quantum information. It would provide a new class of entanglement witnesses that are *computationally cheap* (coefficient sums) and *formally certifiable* (machine-verified bounds).

**Catalog References:**
- `Pythagorean/TropicalLeafWitnesses/Theorems.lean` — `leafWitness_le_tropicalLeafWitness`
- `Catalog/Bridges/Catalog/Speculative/AutoResearch/MultiModeLorentzianWitnesses.lean` — `leafWitness`, `mixedHessianAtOnes`

**Proof Strategy:** Define quantum state polynomials as MvPolynomials with complex coefficients. Extend the tropical-spectral bridge to the complex case using $|c|$ instead of the real absolute value. Show that separable states produce zero tropical witnesses.

**Domain Bridges:** Quantum information ↔ Tropical geometry ↔ Spectral theory ↔ Entanglement detection

**Lineage:** Extends `leafWitness` to quantum states; builds on the spectral witness interpretation.

**Ambition:** 🔭 Grand challenge — paradigm-shifting if successful.

---

## Direction 5: Fully Tropical Lorentzian Theory

**Conjecture:** There exists a purely tropical characterization of Lorentzian polynomials: a polynomial $p$ with nonneg coefficients is Lorentzian if and only if its tropicalization $\mathrm{Trop}(p)$ satisfies a tropical concavity condition on every 2-dimensional restriction.

The key insight is that the Brändén-Huh Lorentzian condition (at most one positive eigenvalue of the Hessian) should correspond to a tropical condition on second differences of coefficient valuations.

**Why now?** The tropical-spectral bridge theorem shows that coefficient data controls spectral data. The converse — that tropical concavity implies Lorentzian structure — would complete the circle and establish a full equivalence.

**Test:** For random Lorentzian polynomials (products of linear forms with nonneg coefficients), verify the tropical concavity condition. For known non-Lorentzian polynomials, verify it fails.

**Impact:** This would create a complete *tropical Lorentzian theory* — a combinatorial characterization of a class of polynomials whose current definition requires checking eigenvalue constraints. It would reduce Lorentzian recognition from a spectral problem to a polyhedral one.

**Catalog References:**
- `Pythagorean/TropicalLeafWitnesses/Defs.lean` — `tropicalMixedHessian`
- `Catalog/Speculative/AutoResearch/DPPLorentzian.lean` — `IsDPPLorentzian`

**Proof Strategy:** Define tropical concavity as a condition on `tropCoeff`: for all $i, j$ and all $\alpha$, $2 \cdot \mathrm{tropCoeff}(\alpha) \leq \mathrm{tropCoeff}(\alpha + e_i) + \mathrm{tropCoeff}(\alpha - e_i)$ (tropical Hessian nonpositivity). Prove that Lorentzian implies tropical concavity using the evaluation bound. The converse is the hard direction, likely requiring ultrametric structure.

**Domain Bridges:** Tropical geometry ↔ Hodge theory ↔ Combinatorial algebraic geometry ↔ Optimization theory

**Lineage:** Ultimate goal of the tropical leaf witness program.

**Ambition:** 🔭 Grand challenge — would unify tropical and spectral characterizations of Lorentzian polynomials.
