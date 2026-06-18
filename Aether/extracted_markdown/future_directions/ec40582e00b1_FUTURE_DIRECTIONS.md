# Future Directions: Dynamic Spectral Gap Tracking

## Synthesis

The locality theorem for Lorentzian certificates under rank-1 updates opens a fundamentally new research program: **online certified sampling**. The key structural insight — that monomial updates create sharp combinatorial shadows in derivative space, leaving most certificate leaves untouched — connects algebraic locality to spectral stability in a way that has not been exploited before. The five directions below form a coherent arc: Direction 1 sharpens the perturbation bounds, Direction 2 extends to compositional updates, Direction 3 bridges to the interlacing polynomial worldview, Direction 4 connects to statistical physics, and Direction 5 pushes toward tropical and nonarchimedean settings. Together, they chart a path from the current "rank-1 update" theory to a full-blown **dynamic certified MCMC framework**.

---

## Direction 1: Weighted-Average Certificate for Tight Support-Sensitive Bounds

**Conjecture:** There exists a weighted-average gap certificate $\bar{\Gamma}(f) = \frac{1}{|L|} \sum_{\beta \in L} \lambda_{\min}(H_\beta(f))$ such that under a rank-1 update $f' = f + c X^\alpha$,
$$|\bar{\Gamma}(f') - \bar{\Gamma}(f)| \leq C_d \cdot |c| \cdot \frac{|\text{Affected}(\alpha, d-2)|}{|\text{Leaves}(d-2)|},$$
with $C_d$ depending only on degree and conditioning. This would make the fraction factor *tight*, not merely a complexity parameter.

**Test:** Formalize the weighted-average certificate in Lean 4, prove the perturbation bound using Weyl's eigenvalue inequality at each affected leaf, and compare the bound with numerical experiments on graphic matroid polynomials for graphs with 10–50 vertices.

**Impact:** Transforms the current "zero or bounded" stability dichotomy into a *quantitatively graded* support-sensitive bound. This is the mathematical upgrade needed for practical online MCMC with calibrated error budgets.

**The key insight is** that the infimum-based certificate cannot exploit the fraction factor (a single bad leaf controls the infimum), but an average-based certificate can, because unaffected leaves contribute zero perturbation to the average.

**Why now?** The locality theorem (Theorem 4 in `Pythagorean/DynamicSpectralGap.lean`) provides the exact machinery to split the leaf set into affected and unaffected parts. The missing piece is Weyl's inequality applied per-leaf, which is available in Mathlib's spectral theory.

**Catalog References:** `Pythagorean/DynamicSpectralGap.lean` (locality theorems), `Catalog/Pythagorean/CertificateSampling.lean` (spectral gap infrastructure).

**Proof Strategy:** Define $\bar{\Gamma}$, split the sum into affected and unaffected parts, use `leafQuadForm_unchanged_of_not_affected` for unaffected terms, apply Weyl's bound for affected terms, sum and normalize.

**Domain Bridges:** Random matrix theory (Weyl's inequality), online algorithms (incremental quality guarantees).

**Lineage:** Directly extends Theorems 4 and 5 of this work.

**Ambition:** Solid extension — 70% confidence of formalizability within 2 weeks.

---

## Direction 2: Compositional Updates and Streaming Certificates

**Conjecture:** For a stream of $T$ rank-1 updates $f_0 \to f_1 \to \cdots \to f_T$ with $f_{t+1} = f_t + c_t X^{\alpha_t}$, the gap certificate satisfies
$$\Gamma(f_T) \geq \Gamma(f_0) - 2\kappa \cdot |\{t : \text{AffectedLeaves}(\alpha_t, d) \neq \emptyset\}| / T,$$
under uniform conditioning at each step. The number of "active steps" (those that affect at least one leaf) controls the total drift.

**Test:** Implement streaming certificate maintenance for dynamic graph sequences (random edge insertions/deletions on Erdős–Rényi graphs). Track the gap certificate over 1000 updates and compare with the theoretical bound.

**Impact:** Extends the single-update theory to the streaming setting, which is the real-world use case. Would enable certified MCMC in data-stream applications.

**The key insight is** that inactive updates (those affecting no leaves) contribute zero drift, so the gap degradation scales with the number of active updates, not the total number of updates.

**Why now?** The exact preservation theorem (Theorem 4) provides the key zero-drift guarantee for inactive updates. The challenge is tracking conditioning across compositions.

**Catalog References:** `Pythagorean/DynamicSpectralGap.lean` (all theorems), `Catalog/Bridges/Catalog/Pythagorean/DynamicLorentzianCertificates.lean` (dynamic certificate framework).

**Proof Strategy:** Induction on $T$, applying the single-step bound at each active step and the exact preservation at each inactive step.

**Domain Bridges:** Streaming algorithms, online learning (regret bounds), amortized analysis.

**Lineage:** Direct generalization of Theorems 4–5 to the sequential setting.

**Ambition:** Solid extension — 80% confidence of formalizability within 3 weeks.

---

## Direction 3: Interlacing Polynomial Approach to Spectral Gap Control

**Conjecture (Grand Challenge):** The leaf Hessians of a Lorentzian polynomial form an *interlacing family* in the sense of Marcus–Spielman–Srivastava, and the spectral gap can be controlled via barrier-function arguments that exploit the interlacing structure. Specifically, for a rank-1 update, the characteristic polynomials of the leaf Hessians interlace, and the movement of the smallest eigenvalue is controlled by the barrier function at the current eigenvalue location.

**Test:** For graphic matroid polynomials on complete graphs $K_n$ ($n = 4, 5, 6, 7$), compute all leaf Hessian eigenvalue polynomials and verify the interlacing property numerically. Check whether the barrier function bound is tighter than the conditioning bound $2\kappa$.

**Impact:** Would connect Lorentzian polynomial dynamics to the MSS framework, potentially yielding exponentially tighter bounds and connecting to Kadison–Singer-type results. This is a paradigm shift from "perturbation theory" to "interlacing theory."

**The key insight is** that Lorentzian polynomials already satisfy a form of the "common interlacing" property (the Hessians have at most one positive eigenvalue), which is exactly the starting point for MSS-type arguments.

**Why now?** The locality theorem identifies *which* Hessians change, and the interlacing framework provides a tool to control *how much* they change. The two theories have not been combined before.

**Catalog References:** `Pythagorean/DynamicSpectralGap.lean` (affected leaf structure), `Catalog/Pythagorean/LorentzianSpectralGap.lean` (spectral gap theory).

**Proof Strategy:** Establish that the collection $\{H_\beta(f)\}_\beta$ forms a common interlacing family. Define the barrier function $\Phi(t) = \sum_\beta 1/(\lambda_{\min}(H_\beta) - t)$. Show that the rank-1 update shifts the barrier by a controlled amount.

**Domain Bridges:** Random matrix theory, operator theory, combinatorial optimization (Kadison–Singer), derandomization.

**Lineage:** Extends the Lorentzian certificate framework using MSS methodology.

**Ambition:** Grand challenge — 30% confidence, but transformative if successful.

---

## Direction 4: Finite-Volume Response Theory for Combinatorial Glauber Dynamics

**Conjecture:** The basis-exchange chain for Lorentzian polynomials satisfies a discrete analogue of the *linear response* principle from statistical physics: the change in the relaxation time under a local energy perturbation is bounded by the susceptibility (integrated correlation function) of the local observable. Formally, if $\tau(f)$ denotes the relaxation time and $\delta f$ is a monomial perturbation,
$$\frac{d\tau}{d\epsilon}\Big|_{\epsilon=0} \leq \tau(f)^2 \cdot \chi_{\text{local}}(\delta f),$$
where $\chi_{\text{local}}$ is a local susceptibility controlled by the affected-leaf structure.

**Test:** For basis-exchange chains on graphic matroids ($K_5, K_6, K_7$), numerically compute both sides of the inequality. Test whether the susceptibility bound is tighter than the conditioning bound.

**Impact:** Would establish a rigorous bridge between Lorentzian combinatorics and statistical physics, potentially importing the vast toolkit of response theory (fluctuation-dissipation, Kramers–Kronig) into the combinatorial setting.

**The key insight is** that the leaf Hessians play the role of local Hamiltonians, the spectral gap plays the role of the mass gap, and the rank-1 update plays the role of a local perturbation — exactly the setup of linear response theory.

**Why now?** The locality theorem provides the "finite support" condition that makes linear response rigorous (the perturbation affects only finitely many terms in the Hamiltonian).

**Catalog References:** `Pythagorean/DynamicSpectralGap.lean` (perturbation bounds), `Catalog/Pythagorean/CertificateSampling.lean` (mixing time from spectral gap).

**Proof Strategy:** Express $\tau$ as $1/\gamma$ where $\gamma$ is the spectral gap. Use the Rayleigh quotient representation of $\gamma$ and differentiate with respect to the perturbation parameter. Bound the derivative using the local structure of the perturbation.

**Domain Bridges:** Statistical mechanics (linear response), quantum information (Lieb–Robinson bounds), condensed matter physics.

**Lineage:** Interprets the locality theorem through the lens of statistical physics.

**Ambition:** Grand challenge — 25% confidence, but would open an entirely new field.

---

## Direction 5: Tropical and Nonarchimedean Spectral Certificates

**Conjecture:** The locality theorem has a tropical analogue: for a tropical Lorentzian polynomial (a piecewise-linear function satisfying convexity conditions on Newton polytope faces), a local coefficient change affects only the tropical "leaves" (faces of the Newton polytope dual) that contain the updated monomial. The "spectral gap" becomes a combinatorial quantity related to the edge lengths of the tropical variety.

**Test:** Implement tropical certificate computation for small examples (tropical lines, tropical cubics) and verify that coefficient changes affect only local faces of the Newton subdivision.

**Impact:** Would extend the entire framework to nonarchimedean fields and tropical geometry, connecting to the tropical Hodge theory program of Adiprasito–Huh–Katz and potentially to algorithmic aspects of tropical optimization.

**The key insight is** that tropical differentiation (the "tropicalization" of partial derivatives) preserves the locality structure: a tropical monomial perturbation affects only those tropical leaves whose support contains the perturbed monomial.

**Why now?** Tropical Lorentzian polynomials have been studied by Brändén–Huh and others, but the *dynamic* theory — how certificates evolve under perturbation — has not been developed in the tropical setting.

**Catalog References:** `Pythagorean/DynamicSpectralGap.lean` (locality theorem as template), tropical geometry literature.

**Proof Strategy:** Define tropical iterated derivatives as min-plus convolutions. Prove the tropical analogue of the annihilation lemma. Establish a tropical certificate structure and prove locality.

**Domain Bridges:** Tropical geometry, algebraic geometry (Hodge theory), optimization (tropical linear programming), phylogenetics (tropical metric spaces).

**Lineage:** Tropicalization of the entire locality framework.

**Ambition:** Solid extension with speculative elements — 50% confidence for the basic tropical locality, 20% for the full spectral certificate theory.
