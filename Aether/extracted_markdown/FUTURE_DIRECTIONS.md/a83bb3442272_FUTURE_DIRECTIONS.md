# Future Directions: Categorification of Entropy

## Synthesis

This research cycle established **functorial entropy** as a rigorous, machine-verified theory connecting category theory to information theory and thermodynamics. The central achievement is the Zero Characterization Theorem: a function between finite types has zero functorial entropy if and only if it is injective — providing a precise, quantitative bridge between algebraic properties (injectivity) and analytic properties (zero entropy). The Uniform Fiber Formula and Upper Bound complete the basic theory, while the Landauer Bridge demonstrates that functorial entropy directly measures thermodynamic cost of computation, connecting to the existing `zero_uniform_entropy_loss_iff_bijective` result in `Computation/ReversibleTropicalMachine.lean`.

The most promising cross-domain connection from this cycle is the **entropy-thermodynamics-computation triangle**: functorial entropy simultaneously measures information loss (information theory), thermodynamic cost (physics), and irreversibility (computation). This triangle suggests that the Catalog's existing work on tropical geometry and reversible computing (`Computation/ReversibleTropicalMachine.lean`) can be unified with the information-theoretic perspective through functorial entropy. The composition conjecture, if proved, would establish functorial entropy as a monotone invariant under the natural ordering of functions by "information preservation," with deep implications for data processing pipelines and neural network theory.

The highest breakthrough potential lies in Direction 1 (Composition Superadditivity), because proving it would establish functorial entropy as a true "measure of information loss" in the categorical sense — monotone under composition — which would have immediate applications in privacy analysis, data pipeline optimization, and neural architecture design.

---

### Direction 1: Composition Superadditivity Conjecture

**Conjecture**: For functions $f: \alpha \to \beta$ (surjective) and $g: \beta \to \gamma$ between finite types, $H(g) \leq H(g \circ f)$. That is, pre-composing with a surjection cannot decrease the functorial entropy.

**Test**: Exhaustively verify for all surjective $f: \text{Fin}(n) \to \text{Fin}(m)$ and all $g: \text{Fin}(m) \to \text{Fin}(k)$ with $n \leq 8$, $m \leq 5$, $k \leq 4$. A single counterexample disproves the conjecture. Alternatively, test the stronger conjecture $H(g \circ f) \geq H(f) + H(g)$ (which may be too strong).

**Impact**: If true, functorial entropy becomes a monotone invariant under composition with surjections, giving it the status of a categorical "measure" analogous to how measure is monotone under inclusion. This would make it useful for analyzing data processing pipelines: each stage can only increase total information loss. If false, the counterexample reveals subtle structure about how information loss interacts with composition.

**Catalog References**: `Speculative/AutoResearch/FunctorialEntropy/Core.lean` (composition_entropy_conjecture), `Computation/ReversibleTropicalMachine.lean` (zero_uniform_entropy_loss_iff_bijective)

**Proof Strategy**: The key difficulty is the nonlinearity of log. The fiber of $g \circ f$ at $c$ is $\bigcup_{b: g(b)=c} f^{-1}(b)$, so $|{(g \circ f)}^{-1}(c)| = \sum_{b: g(b)=c} |f^{-1}(b)|$. Use the convexity of $x \log x$ and Jensen's inequality applied to the fiber-sum decomposition. The surjectivity of $f$ ensures all terms in the sum are positive.

**Domain Bridges**: CategoryTheory <-> InformationTheory, Computation <-> Thermodynamics

**Lineage**: Builds directly on `functorialEntropy_eq_zero_iff_injective` and `functorialEntropy_uniform` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Rényi Functorial Entropy and the Information Loss Spectrum

**Conjecture**: Define the **Rényi functorial entropy of order $\alpha$** as $H_\alpha(f) = \frac{1}{\alpha - 1} \ln\left(\sum_b \left(\frac{|f^{-1}(b)|}{|\text{dom}|}\right)^\alpha \cdot |f^{-1}(b)|^{\alpha-1}\right)$. Conjecture: $\lim_{\alpha \to 1} H_\alpha(f) = H(f)$ (the standard functorial entropy), and $H_\alpha(f) = 0 \iff f$ is injective for all $\alpha > 0$.

**Test**: Compute $H_\alpha(f)$ for $\alpha \in \{0.5, 1, 2, 3, \infty\}$ on all functions $\text{Fin}(4) \to \text{Fin}(4)$. Verify the zero characterization holds for each $\alpha$. Check that $H_2(f) = \ln\left(\sum_b |f^{-1}(b)|^2 / |\text{dom}|\right)$, which relates to collision probability.

**Impact**: A one-parameter family of entropy measures would provide a spectrum of information loss, from "worst-case" (min-entropy, $\alpha \to \infty$) to "average-case" (Shannon, $\alpha = 1$). This connects to existing Rényi entropy theory and to differential privacy, where Rényi divergence is the standard tool.

**Catalog References**: `Algebra/Bridges.lean` (uniform_entropy_eq_log), `Speculative/AutoResearch/FunctorialEntropy/Core.lean`

**Proof Strategy**: The zero characterization for general $\alpha$ should follow from the same argument: if any fiber has size $\geq 2$, it contributes positively to $H_\alpha$. The limit as $\alpha \to 1$ requires L'Hôpital's rule on the Rényi formula.

**Domain Bridges**: InformationTheory <-> Cryptography, CategoryTheory <-> Privacy

**Lineage**: Extends the functorial entropy definition from this cycle.

**Ambition**: extension

---

### Direction 3: Tropical Entropy and the Min-Plus Information Channel

**Conjecture**: In the tropical (min-plus) semiring, the functorial entropy admits a natural analog: the **tropical functorial entropy** $H^{\text{trop}}(f) = \max_b |f^{-1}(b)|$, which is the max-fiber size (the "bottleneck" of the function). Conjecture: $H^{\text{trop}}(f) = 1 \iff f$ is injective, and for uniform fibers of size $k$, $H^{\text{trop}}(f) = k$.

**Test**: Verify on all functions $\text{Fin}(5) \to \text{Fin}(5)$ that $H^{\text{trop}}(f) = 1 \iff f$ is injective. Compare the tropical and classical entropies: is $\ln(H^{\text{trop}}(f)) \leq H(f)$?

**Impact**: Connects the tropical geometry machinery in the Catalog (`Computation/ReversibleTropicalMachine.lean`, the tropical contraction framework in `Algebra/Bridges.lean`) to information theory. The tropical entropy is computationally simpler (no logarithms) and may be more natural for worst-case analysis.

**Catalog References**: `Computation/ReversibleTropicalMachine.lean` (tropAdd, tropMul, pullbackEquiv), `Algebra/Bridges.lean` (TropicalContraction)

**Proof Strategy**: The tropical zero characterization is straightforward: max fiber = 1 iff all nonempty fibers have size 1 iff injective. The inequality $\ln(H^{\text{trop}}) \leq H$ follows from the fact that the max fiber contributes at least $(\text{max}/n) \cdot \ln(\text{max})$ to $H$.

**Domain Bridges**: TropicalGeometry <-> InformationTheory, Computation <-> CategoryTheory

**Lineage**: Builds on tropical structures in `Computation/ReversibleTropicalMachine.lean` and functorial entropy from this cycle.

**Ambition**: extension

---

### Direction 4: Functorial Entropy of Group Homomorphisms and the Kernel-Entropy Correspondence

**Conjecture**: For a group homomorphism $\varphi: G \to H$ between finite groups, $H(\varphi) = \ln|ker(\varphi)|$. That is, the functorial entropy of a group homomorphism is determined entirely by the kernel size, and equals the logarithm of the kernel order.

**Test**: Compute $H(\varphi)$ for: (a) the abelianization map $G \to G/[G,G]$ for $G = S_3, S_4, D_8$; (b) the determinant map $GL_n(\mathbb{F}_q) \to \mathbb{F}_q^*$; (c) the quotient map $\mathbb{Z}/12 \to \mathbb{Z}/4$. Verify $H(\varphi) = \ln|ker(\varphi)|$ in each case.

**Impact**: If true, this establishes a deep connection between algebra (kernel of a homomorphism) and information theory (entropy). It would mean that the information lost by a group homomorphism is entirely captured by the first isomorphism theorem: $G/\ker(\varphi) \cong \text{im}(\varphi)$, and each coset of $\ker(\varphi)$ is a uniform fiber of size $|\ker(\varphi)|$.

**Catalog References**: `Speculative/AutoResearch/FunctorialEntropy/Core.lean` (functorialEntropy_uniform), `Speculative/AutoResearch/ResidualFiniteness.lean` (finite_group_separator_to_perm_separator)

**Proof Strategy**: By the first isomorphism theorem, each fiber of $\varphi$ is a coset of $\ker(\varphi)$, so all fibers have size $|\ker(\varphi)|$. Apply `functorialEntropy_uniform` with $k = |\ker(\varphi)|$. The key lemma to formalize: fibers of group homomorphisms are cosets of the kernel.

**Domain Bridges**: Algebra <-> InformationTheory, GroupTheory <-> CategoryTheory

**Lineage**: Extends `functorialEntropy_uniform` and connects to group theory in the Catalog.

**Ambition**: grand_challenge

---

### Direction 5: Information Channel Category and Functorial Data Processing Inequality

**Conjecture**: The collection of information channels forms a category $\mathbf{InfoCh}$ where composition is function composition and the entropy satisfies a **data processing inequality**: for channels $C_1: \alpha \to \beta$ and $C_2: \beta \to \gamma$, the composed channel $C_2 \circ C_1$ has entropy $H(C_2 \circ C_1)$ satisfying $\max(H(C_1), H(C_2)) \leq H(C_2 \circ C_1) \leq H(C_1) + H(C_2) + \ln(\min(|\alpha|, |\beta|, |\gamma|))$.

**Test**: Verify the upper and lower bounds for all pairs of functions $f: \text{Fin}(5) \to \text{Fin}(4)$ and $g: \text{Fin}(4) \to \text{Fin}(3)$. Find the tightest possible constants.

**Impact**: Establishing information channels as a category with a well-behaved entropy functional would create a new mathematical framework for analyzing data pipelines, with rigorous bounds on information loss at each stage. This connects to the broader Catalog theme of bridging algebra and computation.

**Catalog References**: `Speculative/AutoResearch/FunctorialEntropy/Core.lean` (InformationChannel), `Computation/ReversibleTropicalMachine.lean`, `Algebra/Bridges.lean`

**Proof Strategy**: The lower bound follows from the composition conjecture (Direction 1). The upper bound requires bounding how much "additional" entropy composition can create beyond the sum. The key insight is that fiber sizes of $g \circ f$ are sums of fiber sizes of $f$ restricted to fibers of $g$, and the entropy of a sum is bounded by the entropy plus $\ln(\text{number of terms})$.

**Domain Bridges**: CategoryTheory <-> InformationTheory <-> Computation

**Lineage**: Builds on InformationChannel structure and composition_entropy_conjecture from this cycle.

**Ambition**: extension
