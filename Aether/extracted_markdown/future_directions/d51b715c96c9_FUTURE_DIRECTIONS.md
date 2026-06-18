# Future Directions: Ehrhart Theory of Lorentzian Permutohedra

## Synthesis

This research establishes the first formal chain from Lorentzian polynomial support geometry through M-convex exchange axioms to Integer Decomposition Property (IDP) and Ehrhart h*-nonnegativity. The chain **Lorentzian → M-convex → IDP → h* ≥ 0** opens a new corridor connecting discrete convex analysis, algebraic combinatorics, and arithmetic geometry. Each future direction below extends this chain in a different dimension: deeper positivity (unimodality), broader applicability (convex hull dilation), cross-domain bridges (Hodge theory, statistical mechanics), and computational frontiers (efficient decomposition). Together, they constitute a research program that could unify Ehrhart positivity phenomena under the Lorentzian umbrella.

---

## Direction 1: Unimodality of h*-Vectors from Lorentzian Structure

**Conjecture:** For every M-convex set $S \subset \mathbb{N}^n$ with constant total degree, the h*-vector of the associated lattice polytope (Newton polytope of the support) is unimodal: $h^*_0 \leq h^*_1 \leq \cdots \leq h^*_m \geq h^*_{m+1} \geq \cdots \geq h^*_d$ for some peak index $m$.

**Test:** 
- Enumerate all M-convex subsets of $\{x \in \mathbb{N}^n : \sum x_i = d\}$ for $n = 3, 4, 5$ and $d = 2, 3, 4$.
- For each, compute the h*-vector via Ehrhart interpolation.
- Check unimodality. A single non-unimodal h*-vector refutes the conjecture.

**Impact:** Would establish the strongest known positivity for Lorentzian-support polytopes, going beyond nonnegativity to shape constraints. Connects to the Hodge–Riemann bilinear relations on toric varieties.

**Catalog References:** `Pythagorean/LorentzianPermutohedra/EhrhartIDP.lean` (IDP theorem), `Pythagorean/LorentzianPermutohedra/Defs.lean` (LorentzianSupportSet).

**Proof Strategy:** Use the Lorentzian quadratic form condition (not just support M-convexity) to construct a Lefschetz-type operator on the Ehrhart ring. The Hard Lefschetz theorem for the associated toric variety should force unimodality.

**Domain Bridges:** Algebraic geometry (Hodge theory) ↔ Discrete combinatorics (h*-vectors).

**Lineage:** Extends `idp_of_minkowski_sum` and `lorentzian_support_has_idp`.

**Ambition:** Grand challenge — requires new Hodge-theoretic machinery in the formalization.

---

## Direction 2: IDP for Convex Hull Lattice Dilation

**Conjecture:** If $P \subset \mathbb{Z}^n$ has M-convex lattice points with constant coordinate sum, then for all $t \geq 1$, every lattice point in $t \cdot \text{conv}(P) \cap \mathbb{Z}^n$ decomposes as a sum of $t$ points from $P$.

**Test:**
- For small M-convex sets ($n \leq 4$, $|P| \leq 15$), compute $t \cdot \text{conv}(P) \cap \mathbb{Z}^n$ for $t = 2, 3, 4$.
- For each lattice point, run the peel-off decomposition algorithm.
- Any point that fails to decompose is a counterexample.

**Impact:** Would upgrade our Minkowski-sum IDP to the geometrically natural convex-hull version, connecting directly to Stanley's theorem without the Minkowski-sum caveat.

**Catalog References:** `Pythagorean/LorentzianPermutohedra/EhrhartIDP.lean` (peel_off_of_minkowski_sum), `Catalog/FINAL/Pythagorean/MConvexBridge.lean` (IsMConvexExchange).

**Proof Strategy:** Use the exchange axiom to show that for any $x \in t \cdot \text{conv}(P) \cap \mathbb{Z}^n$, there exists $y \in P$ with $x - y \in (t-1) \cdot \text{conv}(P) \cap \mathbb{Z}^n$. The key step is showing that subtracting a lattice point of $P$ from a point in the scaled convex hull stays in the reduced hull. This requires Murota's "exchange distance" argument and possibly the matroid intersection theorem.

**Domain Bridges:** Convex geometry ↔ Discrete optimization.

**Lineage:** Direct extension of `exists_peeloff` and `idp_of_minkowski_sum`.

**Ambition:** Solid extension — requires convex hull infrastructure in the formalization but the mathematics is well-understood.

---

## Direction 3: Real-Rootedness of Ehrhart Numerators

**Conjecture:** For M-convex sets arising from matroid polytopes, the h*-polynomial $h^*(z) = h^*_0 + h^*_1 z + \cdots + h^*_d z^d$ has only real roots.

**Test:**
- Compute h*-polynomials for uniform matroid polytopes $U(r, n)$ with $n \leq 8$.
- Compute roots numerically. Any complex root refutes the conjecture.
- Extend to graphic matroids and transversal matroids.

**Impact:** Real-rootedness implies log-concavity and unimodality, giving the strongest possible positivity statement. Would connect Ehrhart theory to the theory of stable polynomials (Borcea–Brändén).

**Catalog References:** `Pythagorean/LorentzianPermutohedra/Defs.lean` (IsLogConcave, IsUnimodal), `Pythagorean/LorentzianPermutohedra/EhrhartSeries.lean` (full_simplex_exchange).

**Proof Strategy:** Show that the h*-polynomial of an M-convex polytope is a specialization of a multivariate Lorentzian polynomial, then apply the Brändén–Huh theory of stable/Lorentzian polynomials to conclude real-rootedness.

**Domain Bridges:** Analytic combinatorics (stable polynomials) ↔ Ehrhart theory (h*-polynomials).

**Lineage:** Extends `lorentzian_support_has_idp` in the analytic direction.

**Ambition:** Grand challenge — real-rootedness is much stronger than unimodality and may require genuinely new ideas.

---

## Direction 4: Ehrhart–Euler Product Domination

**Conjecture:** For a lattice generalized permutohedron $P$ with edge directions $\{e_i - e_j\}$, the Ehrhart series is coefficientwise dominated by a product of geometric series:
$$\text{Ehr}_P(z) \leq_{\text{coeff}} \prod_{\text{edges}} \frac{1}{1 - z^{l_e}}$$
where $l_e$ is the lattice length of edge $e$.

**Test:**
- Compute Ehrhart series for small permutohedra and hypersimplices.
- Compute the edge Euler product.
- Verify coefficientwise domination for $t = 0, 1, \ldots, 20$.

**Impact:** Would provide an explicit upper bound on lattice-point counts in terms of the combinatorial skeleton, connecting Ehrhart theory to number-theoretic Euler products as in `Catalog/FINAL/Pythagorean/EulerFactor.lean`.

**Catalog References:** `Catalog/FINAL/Pythagorean/EulerFactor.lean` (eulerFactor, generating series discipline), `Pythagorean/LorentzianPermutohedra/EhrhartSeries.lean` (ehrhartCount_monotone_of_nonempty).

**Proof Strategy:** Interpret each edge as contributing a one-dimensional Ehrhart factor. The domination should follow from the inclusion of the polytope in the Minkowski sum of its edge segments, combined with submultiplicativity of lattice-point counts.

**Domain Bridges:** Number theory (Euler products) ↔ Polyhedral geometry (edge structure).

**Lineage:** Extends `minkowski_sum_card_lower_bound` and `ehrhart_semigroup_decomposition`.

**Ambition:** Solid extension — the mathematics is concrete and testable.

---

## Direction 5: Lattice Gas Free Energy Convexity from M-Convexity

**Conjecture:** If the state space of a lattice gas model forms an M-convex set, the free energy $F(\beta) = -\frac{1}{\beta} \ln Z(\beta)$ is a convex function of the inverse temperature $\beta > 0$.

**Test:**
- Compute $Z(\beta)$ for M-convex state spaces (hypersimplices) with random site energies.
- Plot $F(\beta)$ and verify convexity numerically for $\beta \in [0.01, 10]$.
- Compare with non-M-convex state spaces (random subsets of the simplex).

**Impact:** Would give the first connection between discrete convex analysis and statistical mechanics thermodynamics, showing that M-convexity of the configuration space implies thermodynamic stability.

**Catalog References:** `Pythagorean/LorentzianPermutohedra/EhrhartSeries.lean` (ehrhartCount_pos, lorentzian_support_has_idp).

**Proof Strategy:** The partition function $Z(\beta)$ is a sum of exponentials over an M-convex set. Use the exchange property to show that the Hessian of $\ln Z$ is positive semidefinite (by coupling arguments similar to those in FKG/Holley inequalities). Alternatively, show that $Z(\beta)$ is log-convex in $\beta$ using the Cauchy–Schwarz inequality and the semigroup decomposition.

**Domain Bridges:** Statistical physics (thermodynamics) ↔ Discrete convex analysis (M-convexity).

**Lineage:** Extends `ehrhart_semigroup_decomposition` to physical partition functions.

**Ambition:** Grand challenge — bridges two traditionally separate fields.
