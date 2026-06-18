# Future Directions: Closure-Growth Separation for Neural Proof Mining

## 1. Finite-Cardinality Closure Growth Functions and Entropy Bounds

Define the **closure growth function** `γ_F(n) = |F^[n](S)|` for finite `α` and prove:
- The growth function is monotone non-decreasing for preclosure operators.
- For closure operators, `γ_C(n) = γ_C(1)` for all `n ≥ 1` (immediate from `closureIter_stabilizes`).
- The **closure entropy rate** `h_F = lim_{n→∞} γ_F(n)/n` exists and is zero for closure operators.
- Positive entropy rate for a preclosure operator implies the existence of infinitely many distinct states reachable by the policy.

This connects the combinatorial witness theory to Shannon-theoretic information measures.

## 2. Lawvere Metric Enrichment of Proof-State Transformers

Enrich the set of proof states with a **Lawvere metric** (a.k.a. generalized metric space valued in `[0, ∞]`):
- Define `d : α → α → ℝ≥0∞` satisfying `d(x,x) = 0` and the triangle inequality `d(x,z) ≤ d(x,y) + d(y,z)`.
- A set transformer `F` is **non-expansive** if `d(F(S), F(T)) ≤ d(S, T)` for a suitable Hausdorff-like distance on sets.
- Prove that non-expansive preclosure operators have bounded closure growth in the metric sense.
- Connect to the theory of enriched categories and profunctors for compositional proof transformations.

This gives a quantitative refinement of the qualitative separation theorems.

## 3. Tropicalization of Closure Growth

Interpret closure growth in the **tropical semiring** `(ℝ ∪ {∞}, min, +)`:
- The closure growth function becomes a tropical polynomial.
- Stabilization of a closure operator corresponds to a tropical fixed point.
- The separation theorem becomes a statement about tropical Newton polygons.
- Connect to the existing `Tropical/` infrastructure in the project.

This provides an algebraic framework for analyzing the complexity of closure dynamics.

## 4. Algorithmic Witness Extraction for Neural-Guided Proof Search

Turn the finite witness theorem into a constructive algorithm:
- Given oracle access to `F` and `G`, compute the separating stage `n` and witness `x`.
- Analyze the computational complexity: if `F` and `G` are computable and the ambient space is decidable, witness extraction is Σ₁-complete.
- Implement a concrete witness extractor for propositional proof search, where `F` and `G` are resolution-based and tableaux-based policies.
- Use witnesses to generate training curricula: the witness `x` becomes a training example that distinguishes policy quality.

This is the direct application to neural proof mining: the mathematical certificate becomes a training signal.

## 5. Closure-Growth Complexity Classes for Theorem Proving

Define complexity classes based on closure growth:
- **CG(f)**: the class of proof problems solvable by a preclosure operator whose growth function is bounded by `f(n)`.
- **CG(1)**: problems solvable by a single closure application (idempotent hull).
- **CG(poly)**: problems requiring polynomially many iterations.
- **CG(exp)**: problems requiring exponentially many iterations.
- Prove separation results: `CG(1) ⊂ CG(poly)` under suitable assumptions.
- Connect to classical proof complexity (Frege systems, extended Frege, etc.) by showing that proof system strength corresponds to closure operator power.

This creates a new complexity-theoretic framework for proof search, complementing the classical hierarchy.
