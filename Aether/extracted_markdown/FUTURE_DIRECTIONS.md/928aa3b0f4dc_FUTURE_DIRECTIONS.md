# Future Directions: Moment Method for Random Cayley Expanders

## Synthesis

The certified moment-method scaffold established in this work—the trace–closed-walk identity, backtrack-free counting, symmetry theorems, and cross-domain bridge—creates a formal launchpad for five interconnected research programs. The common thread is the decomposition of spectral moments into tree-like (free-group) contributions and relation-driven corrections. Each direction below attacks the correction terms from a different angle: representation theory gives exact decompositions, free probability gives asymptotic universality, quantum information gives operational meaning, analytic combinatorics gives generating-function machinery, and computational exploration gives empirical guidance. Together, they form a convergent strategy for resolving the Random Cayley Expander Conjecture.

---

## Direction 1: Character Sum Bounds for S_n via Moment Kernel Decomposition

**Conjecture:** For fixed k ≥ 1, the expected k-th excess moment over random generating pairs (σ, τ) in S_n satisfies

$$\mathbb{E}_{\sigma,\tau}[\delta_{2k}(\sigma, \tau)] = O(1/n)$$

where $\delta_{2k} = \text{momentKernel}(\sigma, \tau, 2k) - \mu_{F_2}^{(2k)}(e)$.

**Test:** Compute the average excess moment for random pairs in S_n for n = 5, ..., 12 and verify the 1/n decay rate by regression. The formalized conjugation invariance theorem (`closedWordCount_conj_invariant` in `Pythagorean/CayleyExpander/MomentMethod.lean`) reduces the average to a sum over conjugacy classes, making the computation tractable.

**The key insight is** that the moment kernel decomposes over irreducible representations of S_n, and the dominant correction comes from the standard (n-1)-dimensional representation, which contributes O(1/n) by character orthogonality. The conjugation invariance theorem already certified in our framework is the first step toward formalizing this decomposition.

**Why now?** The trace identity and conjugation invariance are the two prerequisites for the character decomposition, and both are now machine-verified. The character theory of S_n is partially available in Mathlib, making the formal bridge feasible within the next cycle.

**Impact:** A formal proof of the 1/n decay would be the first rigorous moment bound for random Cayley graphs on S_n, directly advancing the Random Cayley Expander Conjecture.

**Catalog References:** `Pythagorean/CayleyExpander/MomentMethod.lean` (closedWordCount_conj_invariant, momentKernel_conj_invariant), `Pythagorean/CayleyExpander/MomentMethodAdvanced.lean` (trace_pow_eq_closedWordCount, spectral_moment_eq_return_prob).

**Proof Strategy:** Decompose the moment kernel using the Peter-Weyl theorem for finite groups. The conjugation invariance reduces the problem to character sums. Bound each irreducible contribution using known character bounds for S_n (e.g., Roichman's bounds).

**Domain Bridges:** Representation theory of S_n → asymptotic combinatorics → probability theory.

**Lineage:** Builds directly on Theorems 1, 3, and 6 of the current work.

**Ambition:** Grand challenge — would resolve the conjecture for fixed moments.

---

## Direction 2: Free Probability and Asymptotic Freeness of Random Permutations

**Conjecture:** The empirical spectral distribution of the normalized adjacency operator of Cay(S_n, {σ, σ⁻¹, τ, τ⁻¹}) converges in moments to the Kesten-McKay distribution (the spectral measure of the 4-regular tree) as n → ∞, for random generating pairs.

**Test:** For n = 5, ..., 10, compute moments up to order 8 and compare with the Kesten-McKay moments. The backtrack-free counting theorem (`card_backtrackFree_words` in `Pythagorean/CayleyExpander/MomentMethodAdvanced.lean`) gives the tree-like baseline; compare with empirical data.

**The key insight is** that the convergence to the Kesten-McKay law is equivalent to asymptotic freeness of the generators σ and τ in the sense of Voiculescu's free probability theory. The moment method provides the combinatorial interface: each moment is a sum over words, and freeness means that only non-crossing partition contributions survive in the limit.

**Why now?** The moment kernel framework and backtrack-free counting are the exact combinatorial objects that appear in free probability. The bridge between walk counting on groups and non-crossing partitions is a well-understood analogy that can now be formalized.

**Impact:** Establishing asymptotic freeness for random permutations would unify the Random Cayley Expander Conjecture with the broader program of random matrix universality. It would show that random Cayley graphs on S_n exhibit the same spectral behavior as random regular graphs—a deep structural insight.

**Catalog References:** `Pythagorean/CayleyExpander/MomentMethodAdvanced.lean` (card_backtrackFree_words, trace_pow_eq_closedWordCount), `Pythagorean/CayleyExpander/MomentMethod.lean` (momentKernel_le_one).

**Proof Strategy:** Formalize the Kesten-McKay distribution and its moments. Show that the relation-driven corrections to the moment kernel vanish by bounding the number of non-tree-like closed walks that involve "deep" relations in S_n.

**Domain Bridges:** Free probability → random matrix theory → quantum information.

**Lineage:** Extends the backtrack-free counting theorem toward asymptotic spectral analysis.

**Ambition:** Grand challenge — paradigm-shifting connection between discrete group theory and continuous random matrix theory.

---

## Direction 3: Quantum Channel Mixing via Cayley Moment Bounds

**Conjecture:** The purity of the k-fold quantum channel $\Phi_{\sigma,\tau}^k$ (the completely positive map induced by the random walk step on S_n) decays as $\text{tr}(\Phi^k(\rho)^2) \leq 1/n! + C_k \cdot (1 - \lambda)^k$ where $\lambda$ is the spectral gap, and the moment kernel directly controls the purity decay.

**Test:** Implement the quantum channel $\Phi$ for small S_n (n = 3, 4) as a superoperator on density matrices, and verify that purity decay matches the moment kernel predictions from `spectral_moment_eq_return_prob`.

**The key insight is** that the spectral moment = return probability theorem (`spectral_moment_eq_return_prob` in our formalization) is literally a purity calculation for the associated quantum channel. The normalized adjacency operator is a bistochastic quantum channel, and tr(Ā^m) computes the m-th moment of its spectrum, which controls the rate at which quantum states approach the maximally mixed state.

**Why now?** Quantum computing demands explicit mixing time bounds for random circuits. Our certified moment framework provides the exact mathematical objects needed. The bridge from group walks to quantum channels is a functor that can be formalized.

**Impact:** Certified mixing bounds for quantum channels on symmetric groups would have immediate applications in quantum algorithm design, random circuit sampling, and quantum error correction.

**Catalog References:** `Pythagorean/CayleyExpander/MomentMethodAdvanced.lean` (spectral_moment_eq_return_prob, momentKernel_le_one, free_group_moment_two_lower).

**Proof Strategy:** Formalize the quantum channel associated to a Cayley graph walk. Show that purity = (1/|G|) · tr(Ā^{2k}) and apply the moment-kernel bounds.

**Domain Bridges:** Quantum information → spectral graph theory → representation theory.

**Lineage:** Direct application of Theorem 6 (cross-domain bridge).

**Ambition:** Solid extension — immediate applications with existing infrastructure.

---

## Direction 4: Analytic Combinatorics of Return Probabilities

**Conjecture:** The generating function $F(\sigma, \tau; z) = \sum_{m=0}^{\infty} \text{closedWordCount}(\sigma, \tau, m) \cdot z^m$ is a rational function of $z$ for any finite group $G$ and generators $\sigma, \tau$, with poles determined by the eigenvalues of the adjacency matrix.

**Test:** For specific generators in S_3 and S_4, compute the first 10-15 terms of the sequence and verify rationality by finding the minimal linear recurrence. Compare pole locations with eigenvalues of the adjacency matrix.

**The key insight is** that the closed-word count sequence satisfies a linear recurrence whose characteristic polynomial is the characteristic polynomial of the adjacency matrix. The trace identity `tr(A^m) = closedWordCount · |G|` makes this explicit: the generating function of traces is always rational for finite-dimensional matrices.

**Why now?** The formalized trace identity provides the bridge from word counting to matrix analysis. Rational generating functions are a standard tool in analytic combinatorics, and their asymptotics are determined by the poles—which are exactly the eigenvalues we want to control.

**Impact:** Formalizing the rationality of the return-probability generating function would give a direct path from the moment method to asymptotic analysis. The poles of the generating function encode the entire spectral information of the Cayley graph.

**Catalog References:** `Pythagorean/CayleyExpander/MomentMethodAdvanced.lean` (trace_pow_eq_closedWordCount, adjMatrix_pow_counts_walks), `Pythagorean/CayleyExpander/MomentMethod.lean` (evalWord_append, closedWordCount_eq_filter).

**Proof Strategy:** Use the Cayley-Hamilton theorem to show that tr(A^m) satisfies a recurrence of degree |G|. Formalize this as rationality of the generating function. Then relate the pole closest to 0 to the spectral gap.

**Domain Bridges:** Analytic combinatorics → spectral theory → number theory (via zeta functions of graphs).

**Lineage:** Extends the trace identity toward generating-function methods.

**Ambition:** Solid extension — well-established techniques with clear formalization path.

---

## Direction 5: Computational Census and Extremal Cayley Graphs

**Conjecture:** Among all generating pairs (σ, τ) in S_n (up to conjugation and the symmetries we've proved), the pair achieving the maximum moment kernel μ₄ is "algebraically degenerate" in a precise sense: the generators satisfy a short relation (e.g., σ² = 1 or στ = τσ).

**Test:** For n = 4, 5, 6, compute μ₄ for all conjugacy class representatives of generating pairs and identify the extremal pairs. Classify them by the shortest relation they satisfy. Verify that non-degenerate pairs cluster near the free-group baseline.

**The key insight is** that the symmetry theorems (conjugation, inversion, swap invariance) dramatically reduce the search space. For S_5, the number of conjugacy classes of generating pairs is manageable, allowing a complete census. The extremal analysis reveals which algebraic structures cause elevated moments—and therefore poor expansion.

**Why now?** The three symmetry theorems (`closedWordCount_conj_invariant`, `closedWordCount_inv_invariant`, `closedWordCount_swap`) reduce the brute-force census by orders of magnitude. Combined with the decomposition into backtrack-free and relation-driven contributions, the census reveals the anatomy of non-expansion.

**Impact:** A complete classification of extremal Cayley graphs on small S_n would guide the asymptotic theory by identifying exactly which structures need to be excluded for the conjecture to hold. It would also produce explicit examples of optimal and worst-case expanders.

**Catalog References:** `Pythagorean/CayleyExpander/MomentMethod.lean` (closedWordCount_conj_invariant, closedWordCount_inv_invariant, closedWordCount_swap), `Pythagorean/CayleyExpander/MomentMethodAdvanced.lean` (trace_pow_eq_closedWordCount).

**Proof Strategy:** Implement an exhaustive census modulo symmetries. For each extremal pair, identify the minimal relation and formalize the connection between short relations and elevated moments.

**Domain Bridges:** Computational group theory → extremal graph theory → coding theory (expanders as error-correcting codes).

**Lineage:** Direct computational application of symmetry theorems.

**Ambition:** Solid extension — computationally intensive but mathematically straightforward.
