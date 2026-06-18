
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: The current formalization proves Z(m,n) ≤ (m+1)^n (polynomial upper bound) and Z
**Domain**: MachineLearning
**Mathematical framing**: # Future Directions: PL Hodge Theory for Neural Networks

## 1. Tight Asymptotic Characterization of the Zaslavsky Function

The current formalization proves Z(m,n) ≤ (m+1)^n (polynomial upper bound) and Z(m,n) ≥ C(m,n) (lower bound via a single binomial coefficient). The missing piece is the tight asymptotic: Z(m,n) = Θ(m^n/n!) for fixed n as m → ∞. Specifically, the conjecture is:

**Conjecture**: For all m ≥ n ≥ 1, we have n! · Z(m,n) ≥ m^n, and this bound is tight in the sense that Z(m,n) ≤ 2·m^n/n! for m ≥ 2n.

The key insight is that the dominant term in Z(m,n) = ∑_{k≤n} C(m,k) is C(m,n) ≈ m^n/n!, and the remaining terms C(m,k) for k < n are lower-order. This can be proved by showing C(m,n) ≥ m^n/(n!)·(1-n/m)^n via the falling factorial bound, and that the partial sums contribute at most a factor of 2.

**Why now?** The `choose_le_Z` theorem provides the lower bound framework. What's needed is a formalization of the falling factorial inequality C(m,n) ≥ (m-n+1)^n/n!, which requires careful handling of natural number subtraction and casting to ℚ or ℝ. Mathlib's `Nat.choose_le_pow_of_lt_half_left` and related lemmas provide the starting point.

## 2. Full Chain Complex Euler-Poincaré and Betti Number Computation

The current `TwoTermComplex` captures β₀ and β₁ with the Euler-Poincaré formula χ = β₀ - β₁. The natural extension is an n-term chain complex C_d → C_{d-1} → ⋯ → C_0 with the boundary-squared-is-zero condition ∂² = 0, yielding Betti numbers β_k = dim(ker ∂_k / im ∂_{k+1}) for all k.

**Conjecture**: For a polyhedral complex K arising from a ReLU network with architecture (w₁, ..., w_L) in ℝ^d, the Betti numbers satisfy β_k ≤ ∏_{i=1}^{L} C(w_i, k) for all 0 ≤ k ≤ d. The generalized Euler-Poincaré formula ∑_k (-1)^k β_k = ∑_k (-1)^k f_k holds.

The key insight is that the boundary-squared-is-zero condition ∂_k ∘ ∂_{k+1} = 0 implies im(∂_{k+1}) ⊆ ker(∂_k), and the quotient dim(ker/im) can be computed via the dimension formula: β_k = dim(ker ∂_k) - dim(im ∂_{k+1}). Telescoping the alternating sum gives the Euler-Poincaré identity.

**Why now?** The `beta₁_add_rank` theorem demonstrates the rank-nullity approach works. Extending to a sequence of boundary maps indexed by `Fin (d+1)` with the compatibility condition is straightforward using Mathlib's `HomologicalComplex` or a direct inductive definition. The algebraic framework is ready; what's needed is the combinatorial connection to polyhedral face counts.

## 3. VC Dimension Formalization via the Sauer-Shelah Lemma

The `shatterFn_eq_Z` theorem shows that the recursive shatter function equals the Zaslavsky function Z(m,n). The next step is to formalize the *semantic* Sauer-Shelah lemma: if a family F ⊆ Finset.powerset [n] has no shattered subset of size > d, then |F| ≤ Z(n, d).

**Conjecture**: For any family F of subsets of Fin n, if the VC dimension of F (the maximum size of a shattered subset) is at most d, then F.card ≤ Z n d = ∑_{k≤d} C(n,k). Furthermore, this bound is tight: there exists a family achieving equality.

The key insight is that the proof proceeds by double induction on n and d, using the projection/restriction decomposition: for any element x, partition F into F₀ (sets not containing x) and F₁ (sets containing x), then apply the inductive hypothesis to F₀ (on n-1 elements, VC-dim ≤ d) and F₁ ∩ F₀ (on n-1 elements, VC-dim ≤ d-1). This gives |F| = |F₀| + |F₁| ≤ Z(n-1,d) + Z(n-1,d-1) = Z(n,d).

**Why now?** The `shatterFn_eq_Z` theorem validates the recursive structure. Formalizing VC dimension requires defining "F shatters S" as ∀ T ⊆ S, ∃ A ∈ F, A ∩ S = T, which is expressible using Mathlib's `Finset` API. The inductive proof mirrors the recurrence already captured by `shatterFn_succ_succ`.

## 4. Matroid-Theoretic Zaslavsky Formula

The Zaslavsky function Z(m,n) counts regions of a *generic* hyperplane arrangement. For non-generic arrangements, the exact count is given by the characteristic polynomial of the arrangement's intersection lattice (equivalently, its matroid). For a generic arrangement, this matroid is the uniform matroid U_{n,m}, and the characteristic polynomial evaluates to Z(m,n) at t=1.

**Conjecture**: For any matroid M on ground set E with rank function r, the characteristic polynomial χ_M(t) = ∑_{A⊆E} (-1)^|A| t^{r(E)-r(A)} satisfies |χ_M(1)| ≤ Z(|E|, r(E)). Equality holds if and only if M is the uniform matroid.

The key insight is that the Möbius function of the lattice of flats controls the coefficients of χ_M, and the uniform matroid maximizes |χ_M(1)| among all matroids of given rank and size. This is because the uniform matroid has the most flats at each rank level.

**Why now?** Mathlib has `Matroid.Basic` with rank functions, circuits, and independent sets. The characteristic polynomial can be defined as a sum over subsets using `Finset.powerset`. The connection to hyperplane arrangements requires showing that the arrangement matroid (defined by linear independence of normal vectors) has its characteristic polynomial equal to the region count — this is Zaslavsky's theorem itself.

## 5. Quantitative Depth-Width Tradeoffs with Explicit Constants

The `depth_efficiency` theorem shows that deep networks achieve 2^N regions versus ≤ (N+1)^d for shallow networks. But this comparison is only meaningful when 2^N > (N+1)^d, i.e., when N > d·log₂(N+1). A sharper analysis would give the exact crossover point and show that for any ε > 0, a network of depth L = ⌈d/ε⌉ and width w = ⌈ε·N/d⌉ achieves at least (N/d)^d regions — matching the information-theoretic lower bound.

**Conjecture**: For a ReLU network with N total neurons in dimension d, the maximum number of linear regions R satisfies (N/d)^d ≤ R ≤ 2^N, with the lower bound achieved by depth L = d and uniform width w = N/d, and the upper bound achieved by depth L = N (single neuron per layer).

The key insight is that the optimal depth-width allocation for maximizing regions is L = d layers of width N/d each, giving Z(N/d, d)^d ≈ (N/d)^d · (1/d!)^d regions. This matches the "covering number" lower bound from statistical learning theory.

**Why now?** The `deep_bound_exponential` and `shallow_bound_polynomial` theorems provide the two extremes. The intermediate case (L layers of width N/L for 1 < L < N) requires analyzing Z(N/L, d)^L as a function of L, which involves optimizing a product of binomial sums. The key lemma is that Z(w, d) ≥ (w/d)^d for w ≥ d, which combined with the tight asymptotic from Direction 1 would complete the picture.

**Concept description**: # Future Directions: PL Hodge Theory for Neural Networks

## 1. Tight Asymptotic Characterization of the Zaslavsky Function

The current formalization proves Z(m,n) ≤ (m+1)^n (polynomial upper bound) and Z(m,n) ≥ C(m,n) (lower bound via a single binomial coefficient). The missing piece is the tight asymptotic: Z(m,n) = Θ(m^n/n!) for fixed n as m → ∞. Specifically, the conjecture is:

**Conjecture**: For all m ≥ n ≥ 1, we have n! · Z(m,n) ≥ m^n, and this bound is tight in the sense that Z(m,n) ≤ 2·m^n/n! for m ≥ 2n.

The key insight is that the dominant term in Z(m,n) = ∑_{k≤n} C(m,k) is C(m,n) ≈ m^n/n!, and the remaining terms C(m,k) for k < n are lower-order. This can be proved by showing C(m,n) ≥ m^n/(n!)·(1-n/m)^n via the falling factorial bound, and that the partial sums contribute at most a factor of 2.

**Why now?** The `choose_le_Z` theorem provides the lower bound framework. What's needed is a formalization of the falling factorial inequality C(m,n) ≥ (m-n+1)^n/n!, which requires careful handling of natural number subtraction and casting to ℚ or ℝ. Mathlib's `Nat.choose_le_pow_of_lt_half_left` and related lemmas provide the starting point.

## 2. Full Chain Complex Euler-Poincaré and Betti Number Computation

The current `TwoTermComplex` captures β₀ and β₁ with the Euler-Poincaré formula χ = β₀ - β₁. The natural extension is an n-term chain complex C_d → C_{d-1} → ⋯ → C_0 with the boundary-squared-is-zero condition ∂² = 0, yielding Betti numbers β_k = dim(ker ∂_k / im ∂_{k+1}) for all k.

**Conjecture**: For a polyhedral complex K arising from a ReLU network with architecture (w₁, ..., w_L) in ℝ^d, the Betti numbers satisfy β_k ≤ ∏_{i=1}^{L} C(w_i, k) for all 0 ≤ k ≤ d. The generalized Euler-Poincaré formula ∑_k (-1)^k β_k = ∑_k (-1)^k f_k holds.

The key insight is that the boundary-squared-is-zero condition ∂_k ∘ ∂_{k+1} = 0 implies im(∂_{k+1}) ⊆ ker(∂_k), and the quotient dim(ker/im) can be computed via the dimension formula: β_k = dim(ker ∂_k) - dim(im ∂_{k+1}). Telescoping the alternating sum gives the Euler-Poincaré identity.

**Why now?** The `beta₁_add_rank` theorem demonstrates the rank-nullity approach works. Extending to a sequence of boundary maps indexed by `Fin (d+1)` with the compatibility condition is straightforward using Mathlib's `HomologicalComplex` or a direct inductive definition. The algebraic framework is ready; what's needed is the combinatorial connection to polyhedral face counts.

## 3. VC Dimension Formalization via the Sauer-Shelah Lemma

The `shatterFn_eq_Z` theorem shows that the recursive shatter function equals the Zaslavsky function Z(m,n). The next step is to formalize the *semantic* Sauer-Shelah lemma: if a family F ⊆ Finset.powerset [n] has no shattered subset of size > d, then |F| ≤ Z(n, d).

**Conjecture**: For any family F of subsets of Fin n, if the VC dimension of F (the maximum size of a shattered subset) is at most d, then F.card ≤ Z n d = ∑_{k≤d} C(n,k). Furthermore, this bound is tight: there exists a family achieving equality.

The key insight is that the proof proceeds by double induction on n and d, using the projection/restriction decomposition: for any element x, partition F into F₀ (sets not containing x) and F₁ (sets containing x), then apply the inductive hypothesis to F₀ (on n-1 elements, VC-dim ≤ d) and F₁ ∩ F₀ (on n-1 elements, VC-dim ≤ d-1). This gives |F| = |F₀| + |F₁| ≤ Z(n-1,d) + Z(n-1,d-1) = Z(n,d).

**Why now?** The `shatterFn_eq_Z` theorem validates the recursive structure. Formalizing VC dimension requires defining "F shatters S" as ∀ T ⊆ S, ∃ A ∈ F, A ∩ S = T, which is expressible using Mathlib's `Finset` API. The inductive proof mirrors the recurrence already captured by `shatterFn_succ_succ`.

## 4. Matroid-Theoretic Zaslavsky Formula

The Zaslavsky function Z(m,n) counts regions of a *generic* hyperplane arrangement. For non-generic arrangements, the exact count is given by the characteristic polynomial of the arrangement's intersection lattice (equivalently, its matroid). For a generic arrangement, this matroid is the uniform matroid U_{n,m}, and the characteristic polynomial evaluates to Z(m,n) at t=1.

**Conjecture**: For any matroid M on ground set E with rank function r, the characteristic polynomial χ_M(t) = ∑_{A⊆E} (-1)^|A| t^{r(E)-r(A)} satisfies |χ_M(1)| ≤ Z(|E|, r(E)). Equality holds if and only if M is the uniform matroid.

The key insight is that the Möbius function of the lattice of flats controls the coefficients of χ_M, and the uniform matroid maximizes |χ_M(1)| among all matroids of given rank and size. This is because the uniform matroid has the most flats at each rank level.

**Why now?** Mathlib has `Matroid.Basic` with rank functions, circuits, and independent sets. The characteristic polynomial can be defined as a sum over subsets using `Finset.powerset`. The connection to hyperplane arrangements requires showing that the arrangement matroid (defined by linear independence of normal vectors) has its characteristic polynomial equal to the region count — this is Zaslavsky's theorem itself.

## 5. Quantitative Depth-Width Tradeoffs with Explicit Constants

The `depth_efficiency` theorem shows that deep networks achieve 2^N regions versus ≤ (N+1)^d for shallow networks. But this comparison is only meaningful when 2^N > (N+1)^d, i.e., when N > d·log₂(N+1). A sharper analysis would give the exact crossover point and show that for any ε > 0, a network of depth L = ⌈d/ε⌉ and width w = ⌈ε·N/d⌉ achieves at least (N/d)^d regions — matching the information-theoretic lower bound.

**Conjecture**: For a ReLU network with N total neurons in dimension d, the maximum number of linear regions R satisfies (N/d)^d ≤ R ≤ 2^N, with the lower bound achieved by depth L = d and uniform width w = N/d, and the upper bound achieved by depth L = N (single neuron per layer).

The key insight is that the optimal depth-width allocation for maximizing regions is L = d layers of width N/d each, giving Z(N/d, d)^d ≈ (N/d)^d · (1/d!)^d regions. This matches the "covering number" lower bound from statistical learning theory.

**Why now?** The `deep_bound_exponential` and `shallow_bound_polynomial` theorems provide the two extremes. The intermediate case (L layers of width N/L for 1 < L < N) requires analyzing Z(N/L, d)^L as a function of L, which involves optimizing a product of binomial sums. The key lemma is that Z(w, d) ≥ (w/d)^d for w ≥ d, which combined with the tight asymptotic from Direction 1 would complete the picture.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: MachineLearning
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v13 Depth Requirements -- First-Principles Grounding Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **First-Principles Grounding**. Focus on elegance, structural simplicity, and building blocks of deep theories.

### RESEARCH CORE METHODOLOGY:
1. **Foundational Clarity**: Build theories starting from clean, minimal, first-principles assumptions. Keep definitions mathematically pure, elegant, and simple.
2. **Lemma Factorization**: Decompose large, complex theorems into a hierarchy of beautiful, standalone, reusable lemmas. Each lemma should be a complete mathematical statement of independent interest.
3. **Explanatory Elegance**: Design proofs that are not only correct but structurally beautiful and easy to understand. Let the proofs explain the mathematical mechanism.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
