
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

**Title**: The current work proves the key ingredients — adjunction, harmonic characterizat
**Domain**: Applications
**Mathematical framing**: # Future Directions: Tropical Hodge Theory

## 1. Full Hodge Decomposition for Multi-Degree Complexes

The current work proves the key ingredients — adjunction, harmonic characterization, and orthogonality — for a single-degree weighted coboundary map d : ℝ^m → ℝ^n. The natural next step is to formalize the full three-way orthogonal decomposition for a multi-degree cochain complex:

  C^p = im(d_{p-1}) ⊕ im(δ_p) ⊕ ker(Δ_p)

where Δ_p = δ_p d_p + d_{p-1} δ_{p-1} is the full Hodge Laplacian. This requires formalizing the chain complex condition d² = 0, which enables the exact-coexact orthogonality (currently stated but not proved in full generality). The key insight is that the finite-dimensional case avoids the functional-analytic subtleties of the infinite-dimensional Hodge theorem — the decomposition follows purely from linear algebra over ℝ with positive-definite inner products.

Why now? Mathlib's `Submodule.orthogonal` and finite-dimensional inner product space theory have matured enough to support this construction. The adjunction theorem we proved is the critical ingredient that was missing.

## 2. Tropical Kirchhoff's Matrix Tree Theorem

The graph Laplacian's determinantal structure encodes the number of spanning trees via Kirchhoff's theorem: for a connected graph G with Laplacian L, the number of spanning trees equals any cofactor of L. The tropical analog replaces the determinant with the tropical permanent (minimum weight perfect matching), giving:

  trop-det(L) = min over spanning trees T of (sum of edge weights in T)

The key insight is that the tropical determinant of the Laplacian computes the minimum spanning tree weight, connecting our Laplacian formalization to tropical optimization. This would bridge spectral graph theory (our `laplacian_kernel_eq_incidence_kernel`) to tropical combinatorial optimization in a single theorem.

Why now? The quadratic form identity and kernel characterization we proved provide the spectral foundation. Formalizing the tropical determinant requires only Mathlib's `Equiv.Perm` and `Finset.sum` machinery.

## 3. Spectral Gap and Tropical Cheeger Inequality

Our `rayleigh_quotient_pos` theorem shows that non-constant functions have positive Laplacian energy. The quantitative version is the Cheeger inequality:

  λ₁ ≥ h² / (2 · max_degree)

where λ₁ is the smallest nonzero eigenvalue and h is the Cheeger constant (edge expansion). The tropical analog replaces the Cheeger constant with a tropical bottleneck quantity: the minimum over all cuts of the maximum edge weight in the cut.

The key insight is that the tropical Cheeger constant — defined via the min-max structure of the tropical semiring — gives tighter bounds than the classical version for graphs arising from tropical varieties, because the tropical metric (sup-norm) is compatible with the Laplacian energy bound we proved in `laplacian_energy_le_sup_norm`.

Why now? The energy bound theorem provides the upper-bound direction. The lower bound (Cheeger) requires formalizing graph cuts, which are well within Mathlib's combinatorial reach.

## 4. Tropical Hodge Numbers from Matroids

The Adiprasito-Huh-Katz theorem (2018) proves that the Betti numbers of matroid Chow rings form a log-concave sequence: b_k² ≥ b_{k-1} · b_{k+1}. This is equivalent to the Hard Lefschetz property for a tropical fan associated to the matroid. Our `SatisfiesHLP` predicate (from the existing HodgeDecomposition/Defs.lean) captures this property.

The key insight is that the Laplacian kernel dimension equals the Betti number β_0 (number of connected components), and this can be extended to higher Betti numbers via the multi-degree Hodge Laplacian from Direction 1. Proving log-concavity of the kernel dimensions would formalize a central case of the Adiprasito-Huh-Katz theorem.

Why now? The kernel characterization `laplacian_kernel_eq_incidence_kernel` gives β_0 = dim(ker L) = dim(ker B). Extending to higher degrees via the multi-degree complex from Direction 1 would give all Betti numbers, and log-concavity could then be attacked via the Lefschetz operator formalization.

## 5. Tropical-to-Classical Transfer via Berkovich Analytification

The deepest direction: formalize the comparison map between tropical cohomology and classical étale or singular cohomology via Berkovich analytification. For a smooth projective variety X over a non-archimedean valued field, the tropicalization map trop: X^{an} → Σ induces a map on cohomology:

  H^p(Σ, ℤ) → H^p(X^{an}, ℤ)

The key insight is that our weighted cochain complex with positive weights is exactly the combinatorial model for the tropical cohomology of the tropicalization Σ, and the adjunction/Hodge theory we developed gives the spectral sequence connecting tropical and algebraic cohomology. The transfer principle would say: if a cycle class is representable tropically (which our `cycleClass` formalization captures), then it is algebraic classically.

Why now? This is the most ambitious direction, but the foundations are in place: the weighted inner product, adjunction, and Hodge decomposition provide the tropical side. Mathlib's algebraic geometry is approaching the point where Berkovich spaces could be formalized, and our work provides the target for the comparison map.

**Concept description**: # Future Directions: Tropical Hodge Theory

## 1. Full Hodge Decomposition for Multi-Degree Complexes

The current work proves the key ingredients — adjunction, harmonic characterization, and orthogonality — for a single-degree weighted coboundary map d : ℝ^m → ℝ^n. The natural next step is to formalize the full three-way orthogonal decomposition for a multi-degree cochain complex:

  C^p = im(d_{p-1}) ⊕ im(δ_p) ⊕ ker(Δ_p)

where Δ_p = δ_p d_p + d_{p-1} δ_{p-1} is the full Hodge Laplacian. This requires formalizing the chain complex condition d² = 0, which enables the exact-coexact orthogonality (currently stated but not proved in full generality). The key insight is that the finite-dimensional case avoids the functional-analytic subtleties of the infinite-dimensional Hodge theorem — the decomposition follows purely from linear algebra over ℝ with positive-definite inner products.

Why now? Mathlib's `Submodule.orthogonal` and finite-dimensional inner product space theory have matured enough to support this construction. The adjunction theorem we proved is the critical ingredient that was missing.

## 2. Tropical Kirchhoff's Matrix Tree Theorem

The graph Laplacian's determinantal structure encodes the number of spanning trees via Kirchhoff's theorem: for a connected graph G with Laplacian L, the number of spanning trees equals any cofactor of L. The tropical analog replaces the determinant with the tropical permanent (minimum weight perfect matching), giving:

  trop-det(L) = min over spanning trees T of (sum of edge weights in T)

The key insight is that the tropical determinant of the Laplacian computes the minimum spanning tree weight, connecting our Laplacian formalization to tropical optimization. This would bridge spectral graph theory (our `laplacian_kernel_eq_incidence_kernel`) to tropical combinatorial optimization in a single theorem.

Why now? The quadratic form identity and kernel characterization we proved provide the spectral foundation. Formalizing the tropical determinant requires only Mathlib's `Equiv.Perm` and `Finset.sum` machinery.

## 3. Spectral Gap and Tropical Cheeger Inequality

Our `rayleigh_quotient_pos` theorem shows that non-constant functions have positive Laplacian energy. The quantitative version is the Cheeger inequality:

  λ₁ ≥ h² / (2 · max_degree)

where λ₁ is the smallest nonzero eigenvalue and h is the Cheeger constant (edge expansion). The tropical analog replaces the Cheeger constant with a tropical bottleneck quantity: the minimum over all cuts of the maximum edge weight in the cut.

The key insight is that the tropical Cheeger constant — defined via the min-max structure of the tropical semiring — gives tighter bounds than the classical version for graphs arising from tropical varieties, because the tropical metric (sup-norm) is compatible with the Laplacian energy bound we proved in `laplacian_energy_le_sup_norm`.

Why now? The energy bound theorem provides the upper-bound direction. The lower bound (Cheeger) requires formalizing graph cuts, which are well within Mathlib's combinatorial reach.

## 4. Tropical Hodge Numbers from Matroids

The Adiprasito-Huh-Katz theorem (2018) proves that the Betti numbers of matroid Chow rings form a log-concave sequence: b_k² ≥ b_{k-1} · b_{k+1}. This is equivalent to the Hard Lefschetz property for a tropical fan associated to the matroid. Our `SatisfiesHLP` predicate (from the existing HodgeDecomposition/Defs.lean) captures this property.

The key insight is that the Laplacian kernel dimension equals the Betti number β_0 (number of connected components), and this can be extended to higher Betti numbers via the multi-degree Hodge Laplacian from Direction 1. Proving log-concavity of the kernel dimensions would formalize a central case of the Adiprasito-Huh-Katz theorem.

Why now? The kernel characterization `laplacian_kernel_eq_incidence_kernel` gives β_0 = dim(ker L) = dim(ker B). Extending to higher degrees via the multi-degree complex from Direction 1 would give all Betti numbers, and log-concavity could then be attacked via the Lefschetz operator formalization.

## 5. Tropical-to-Classical Transfer via Berkovich Analytification

The deepest direction: formalize the comparison map between tropical cohomology and classical étale or singular cohomology via Berkovich analytification. For a smooth projective variety X over a non-archimedean valued field, the tropicalization map trop: X^{an} → Σ induces a map on cohomology:

  H^p(Σ, ℤ) → H^p(X^{an}, ℤ)

The key insight is that our weighted cochain complex with positive weights is exactly the combinatorial model for the tropical cohomology of the tropicalization Σ, and the adjunction/Hodge theory we developed gives the spectral sequence connecting tropical and algebraic cohomology. The transfer principle would say: if a cycle class is representable tropically (which our `cycleClass` formalization captures), then it is algebraic classically.

Why now? This is the most ambitious direction, but the foundations are in place: the weighted inner product, adjunction, and Hodge decomposition provide the tropical side. Mathlib's algebraic geometry is approaching the point where Berkovich spaces could be formalized, and our work provides the target for the comparison map.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
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
