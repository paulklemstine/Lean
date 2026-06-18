# Future Directions: Tropical Barron–Choquet Duality

## 1. Tropical Adjoint/Residuation-Based Inverse Theorem

**Goal:** Formalize the synthesis–analysis adjunction for tropical networks.

**Theorem Statement (Informal):**
Define the synthesis map Ψ(w)(f) = max_i (w_i + eval_i(f)) and the analysis map
w*_i = inf_f (L(f) − eval_i(f)). Prove that analysis ⊣ synthesis forms a Galois
connection on the lattice of weight functions and functionals, and that exactness
holds under finite separability.

**Proof Strategy:** Define `TropicalSynthesis` and `TropicalAnalysis` as maps between
weight spaces and functional spaces. Show monotonicity of both. Prove the adjunction
`analysis(L) ≤ w ↔ L ≤ synthesis(w)` using properties of inf and sup. The exactness
theorem `synthesis(analysis(L)) = L` under separability follows from the sparse
reconstruction theorem.

**Impact:** Converts network reconstruction into a formal optimization problem. Opens
tropical compressed sensing and atomic norm recovery.

---

## 2. Infinite-Dimensional Idempotent Barron–Choquet Duality

**Goal:** Extend the finite representation theorem to compact feature spaces.

**Theorem Statement (Informal):**
Let X be a compact Hausdorff space, and let eval : X → (F → ℝ) be a continuous family
of evaluation functionals. Every upper-continuous tropical Choquet functional L admits
a representation L(f) = sup_{x ∈ K} (w(x) + eval(x)(f)) where K is a compact support
and w is upper semicontinuous.

**Proof Strategy:** Use Zorn's lemma for existence of maximal support, then the
finite representation theorem for compact approximation. Connect to the existing
`UCTropicalFunctional` in `CompactTropicalChoquetRadon.lean`.

**Cross-Domain Connection:** Bridges tropical convex geometry with infinite-dimensional
functional analysis. Connects to kernel methods in machine learning.

---

## 3. Stability of Recovered Support Under Perturbation

**Goal:** Prove quantitative stability bounds for the recovered irredundant support.

**Theorem Statement (Informal):**
If two tropical functionals L₁, L₂ satisfy ‖L₁ − L₂‖∞ ≤ ε and both have irredundant
representations with the same cardinality n, then there exists a bijection between
their supports such that matched weights differ by at most ε and matched evaluations
are O(ε)-close.

**Proof Strategy:** Extend `network_weight_stability` to handle support perturbation.
Use the isolation hypothesis to construct a matching between supports via a Hungarian-type
argument on the isolating inputs.

**Impact:** Essential for practical certified compression — real networks have noise.
Connects to perturbation theory in combinatorial optimization.

---

## 4. Tropical Representer Theorem for Regularized Learning

**Goal:** Prove that the minimizer of a regularized tropical loss has finite support.

**Theorem Statement (Informal):**
Given data (x₁,y₁),...,(xₘ,yₘ) and a tropical loss ℓ(f) = max_i |f(x_i) − y_i|,
the minimizer of ℓ(f) + λ·|support(f)| over tropical networks has support size at
most m (the number of data points).

**Proof Strategy:** Show that any minimizer with support larger than m can be pruned
(via the dominated unit elimination theorem) without increasing the loss. Use the
sparsity of max-plus representations to bound support size by the number of
"active constraints."

**Impact:** Direct ML application — provides a tropical analogue of the kernel
representer theorem. Gives certified bounds on network width for interpolation.

---

## 5. Equivalence Between Minimal Tropical Width and Extremal Semimodule Rank

**Goal:** Connect minimal network width to algebraic rank invariants.

**Theorem Statement (Informal):**
The minimum support cardinality of an irredundant tropical network realization of L
equals the extremal rank of the corresponding element in the feature semimodule —
i.e., the minimum number of extremal rays needed to express L in the tropical convex hull.

**Proof Strategy:** Define the tropical convex hull of evaluation functionals.
Show that irredundant network representations correspond bijectively to extremal
decompositions. Use the uniqueness theorem (`irredundant_support_card_eq`) to
establish that the two rank notions coincide.

**Cross-Domain Connection:** Bridges tropical convexity (extremal decomposition) with
ML theory (width minimization) and algebraic geometry (tropical rank). Opens
connections to tropical matrix factorization and non-negative matrix factorization.

---

## Prioritized Roadmap

| Priority | Direction | Difficulty | Estimated Effort |
|----------|-----------|-----------|-----------------|
| 1 | Tropical Representer Theorem (#4) | Medium | 2-3 weeks |
| 2 | Support Stability (#3) | Medium | 2-3 weeks |
| 3 | Residuation Inverse (#1) | Medium-Hard | 3-4 weeks |
| 4 | Extremal Rank Equivalence (#5) | Hard | 4-6 weeks |
| 5 | Infinite-Dimensional Extension (#2) | Hard | 6-8 weeks |

Direction #4 (Representer Theorem) is the highest-impact next step for ML applications.
Direction #3 (Stability) is critical for practical deployment.
Direction #1 (Residuation) provides the deepest algebraic insight.
