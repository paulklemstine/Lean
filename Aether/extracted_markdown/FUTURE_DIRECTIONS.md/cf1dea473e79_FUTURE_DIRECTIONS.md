# Future Directions: Tropical Algebra Automation

## 1. Extending to Full Tropical Semiring Normalization (Distributivity)

**Hypothesis:** The AC normalizer can be extended to handle the full tropical semiring identity `a + min(b, c) = min(a+b, a+c)` (distributivity of + over min), producing a decision procedure for a strictly larger fragment of tropical algebra.

**Proof Strategy:**
- Define a "tropical polynomial normal form" where every expression is rewritten as `min(t₁, t₂, ..., tₖ)` where each `tᵢ` is a sum of variables and constants (no nested `min` inside `+`)
- Implement distributive expansion: push all `+` outside `min` using `a + min(b,c) → min(a+b, a+c)`
- After expansion, each summand is a pure sum term; apply AC normalization to each, then ACI normalization to the outer `min`
- Prove soundness of the expansion step: `eval σ (distribute e) = eval σ e`
- The full normalizer is `cnormalize_ca ∘ distribute`, with soundness by composition

**Complexity:** Distributive expansion can cause exponential blowup in the worst case (analogous to converting CNF to DNF). Investigate whether practical tropical expressions have bounded expansion, and whether term-sharing (DAG representation) mitigates this.

**Cross-domain connections:**
- Tropical polynomial rings in tropical geometry (Maclagan–Sturmfels)
- Expansion is the "tropicalization" of polynomial multiplication
- Relates to certified Gröbner basis computation in tropical settings

---

## 2. Dualizing to Max-Plus Algebra

**Hypothesis:** The entire infrastructure (AST, normalizer, reflection theorem, tactic) can be systematically dualized from min-plus to max-plus by a single semantic dictionary swap, yielding a `tropical_max` tactic with zero new proof effort.

**Proof Strategy:**
- Define `CTropExprMax` with `tmax` replacing `tmin`, evaluating as `max` instead of `min`
- Prove a meta-theorem: for any `ACEquiv`-closed proof in min-plus, there exists a corresponding proof in max-plus, by the order-reversing isomorphism `x ↦ -x`
- Alternatively, implement a direct syntactic translation `dual : CTropExpr → CTropExprMax` and prove `eval_max σ (dual e) = -(eval_min (fun i => -(σ i)) e)`
- The max-plus normalizer is then `dual ∘ cnormalize_ca ∘ undual`

**Applications:**
- Critical path method (CPM) in project scheduling
- Max-plus spectral theory (Perron-Frobenius for max-plus matrices)
- Tropical convexity (max-plus halfspaces)
- Weighted automata over the max-plus semiring

---

## 3. Certified Shortest-Path and Dynamic Programming Verification

**Hypothesis:** The tropical reflection tactic can serve as a certified backend for verifying the correctness of dynamic programming recurrences and shortest-path algorithms expressed as tropical matrix equations.

**Proof Strategy:**
- Formalize tropical matrix multiplication: `(A ⊕ B)ᵢⱼ = min_k(Aᵢₖ + Bₖⱼ)`
- Express the Bellman-Ford recurrence as iterated tropical matrix-vector multiplication
- Use the `tropical` tactic to verify algebraic properties of the recurrence (associativity of tropical matrix multiplication, fixed-point equations)
- Formalize the correspondence: `shortest_path G s t = (W^n)_{s,t}` where `W` is the weight matrix and `^n` is tropical matrix power
- Verify small instances (3-5 node graphs) automatically via the tactic

**Concrete deliverables:**
- A formalized tropical matrix library in Lean with multiplication, powers, and Kleene star
- Verified shortest-path for parametric graphs (edge weights as symbolic variables)
- Integration with Mathlib's `Matrix` API

**Cross-domain connections:**
- Floyd-Warshall as tropical matrix powering
- Viterbi algorithm as max-plus matrix-vector product
- Network flow optimization
- Formal verification of routing protocols

---

## 4. Tropical Gröbner-Style Simplification

**Hypothesis:** A tropical analogue of Buchberger's algorithm can be implemented to decide equality of tropical rational functions (quotients of tropical polynomials), extending the normalizer beyond the polynomial fragment.

**Proof Strategy:**
- Implement tropical polynomial division using the "bend-and-break" approach
- Define tropical S-polynomials and a tropical Buchberger criterion
- Prove termination using a tropical analogue of the monomial ordering argument
- The resulting "tropical Gröbner basis" gives a canonical representative for each equivalence class of tropical rational functions
- Soundness follows from the confluence of the rewriting system

**Technical challenges:**
- Tropical polynomial division is not unique in the same way as classical division
- The "tropical basis" concept (Maclagan–Sturmfels, Chapter 2) involves subtleties about tropical varieties vs. tropical ideals
- Start with the special case of univariate tropical polynomials where the theory is cleaner

**Applications:**
- Deciding equality of piecewise-linear functions
- Tropical intersection theory computations
- Automated reasoning about tropical curves

---

## 5. Piecewise-Linear Neural Network Verification via Tropical Geometry

**Hypothesis:** ReLU neural networks define piecewise-linear functions that are tropical rational functions. The tropical normalizer can be extended to provide certified bounds on the output of ReLU networks, connecting tropical algebra to neural network verification.

**Proof Strategy:**
- Formalize the correspondence: `ReLU(x) = max(0, x) = -min(0, -x)`, so compositions of affine maps and ReLU are tropical rational functions
- For a single-hidden-layer network `f(x) = Σᵢ wᵢ · max(0, aᵢ · x + bᵢ)`, express `f` as a max-plus (dual tropical) polynomial
- Use the tropical normalizer to compute the canonical form of `f`, which reveals the linear regions explicitly
- Prove certified Lipschitz bounds from the canonical form: the Lipschitz constant equals the maximum slope of any linear piece
- For multi-layer networks, use tropical matrix multiplication to compose layers

**Concrete goals:**
- Verify robustness certificates for small (2-3 layer, 10-20 neuron) ReLU networks
- Formalize the "tropical semiring model of ReLU networks" (Zhang et al., 2018)
- Connect to Mathlib's `Analysis.NormedSpace` for Lipschitz formalization

**Impact:** This would create the first formally verified connection between tropical geometry and neural network verification, opening a path to certified AI safety proofs grounded in algebraic geometry rather than interval arithmetic or abstract interpretation.
