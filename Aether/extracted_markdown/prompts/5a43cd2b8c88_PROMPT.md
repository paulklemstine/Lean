
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by the Plan)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.

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

**Title**: Quasi-symmetric maps generalize bi-Lipschitz maps by allowing the distortion con
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Fractal Topology and Hausdorff Dimension Invariance

## 1. Quantitative Distortion Bounds for Quasi-Symmetric Maps

Quasi-symmetric maps generalize bi-Lipschitz maps by allowing the distortion constant to depend on scale. A natural conjecture: if f : X → Y is η-quasi-symmetric (meaning there exists η : [0,∞) → [0,∞) with edist(f(x), f(a)) / edist(f(x), f(b)) ≤ η(edist(x,a) / edist(x,b))), then dimH(f(S)) can be bounded in terms of dimH(S) and the modulus η. The key insight is that quasi-symmetric maps satisfy a local version of the bi-Lipschitz condition at each scale, so the Hausdorff dimension distortion is controlled by the asymptotic behavior of η near 0 and ∞. Why now? Our `AntilipschitzOnWith` infrastructure provides the local lower bound machinery needed; extending it to scale-dependent constants is the natural next step.

## 2. Hausdorff Dimension of Product Sets: The Full Inequality

The classical result states dimH(A × B) ≥ dimH(A) + dimH(B) for any metric spaces, with equality when A satisfies certain regularity conditions (e.g., Ahlfors regularity). Formalizing this in Lean would require developing the product metric space Hausdorff measure theory. The key insight is that the product Hausdorff measure satisfies μH^{s+t}(A × B) ≥ μH^s(A) · μH^t(B), which can be proved using Frostman's lemma or direct covering arguments. Why now? Mathlib already has `dimH` and product metric spaces; the missing piece is the covering-theoretic argument connecting product coverings to factor coverings, which our Lipschitz inverse technique (`dimH_image_eq_of_lipschitz_inverse`) could assist via projection maps.

## 3. Conformal Dimension as a Topological Invariant

The conformal dimension of a metric space X is defined as cdim(X) = inf{dimH(Y) : Y quasi-symmetrically equivalent to X}. This is a genuine topological invariant (invariant under quasi-symmetric homeomorphisms). Conjecturally, for self-similar fractals satisfying the open set condition, cdim equals the Ahlfors regular conformal dimension, which can be computed via moduli of curve families. The key insight is that our `dimH_eq_of_biLipschitzOn_fullDim` theorem is the bi-Lipschitz special case of what should hold for quasi-symmetric maps, and cdim captures exactly what remains after quotienting out by quasi-symmetric equivalence. Why now? The infrastructure for `AntilipschitzOnWith` and dimension preservation under Lipschitz inverses provides the foundation; the next step is extending to the quasi-symmetric category.

## 4. Dimension Spectrum of IFS Attractors via Lipschitz Sections

For an iterated function system (IFS) {f₁, ..., fₙ} of contractions on a complete metric space, the attractor K satisfies dimH(K) ≤ s where s is the similarity dimension (solution to Σ rᵢˢ = 1). When the IFS satisfies the open set condition, equality holds. A formalization strategy: define the coding map π : {1,...,n}^ℕ → K, show it is Hölder continuous (using contractivity), and show it has a Lipschitz section on a dense subset (using the open set condition). Then apply our `dimH_image_bounds_of_holderOnWith_antilipschitzOnWith` to get both directions of the dimension bound. The key insight is that the coding map is Hölder with exponent related to the contraction ratios, and the open set condition provides the antilipschitz inverse needed for the lower bound. Why now? The Hölder-antilipschitz distortion bounds we proved are precisely the tool needed to formalize this classical argument.

## 5. Bi-Lipschitz Embedding Dimension of Fractals

Define the bi-Lipschitz embedding dimension of a compact metric space X as bldim(X) = inf{n ∈ ℕ : X bi-Lipschitz embeds into ℝⁿ}. The Assouad embedding theorem guarantees bldim(X) ≤ C·dim_A(X) for doubling spaces, where dim_A is the Assouad dimension. Conjecture: for self-similar fractals, bldim equals the ceiling of the Hausdorff dimension. The key insight is that our `biLipschitzOn_dimH_image_eq` theorem shows bi-Lipschitz embeddings preserve dimH exactly, so bldim(X) ≥ ⌈dimH(X)⌉ follows immediately (since dimH(ℝⁿ) = n). The upper bound requires constructive embedding arguments specific to each fractal. Why now? The dimension preservation result `biLipschitzOn_dimH_image_eq` gives the lower bound for free; formalizing the Assouad embedding theorem would yield the upper bound and complete the picture.

**Concept description**: # Future Directions: Fractal Topology and Hausdorff Dimension Invariance

## 1. Quantitative Distortion Bounds for Quasi-Symmetric Maps

Quasi-symmetric maps generalize bi-Lipschitz maps by allowing the distortion constant to depend on scale. A natural conjecture: if f : X → Y is η-quasi-symmetric (meaning there exists η : [0,∞) → [0,∞) with edist(f(x), f(a)) / edist(f(x), f(b)) ≤ η(edist(x,a) / edist(x,b))), then dimH(f(S)) can be bounded in terms of dimH(S) and the modulus η. The key insight is that quasi-symmetric maps satisfy a local version of the bi-Lipschitz condition at each scale, so the Hausdorff dimension distortion is controlled by the asymptotic behavior of η near 0 and ∞. Why now? Our `AntilipschitzOnWith` infrastructure provides the local lower bound machinery needed; extending it to scale-dependent constants is the natural next step.

## 2. Hausdorff Dimension of Product Sets: The Full Inequality

The classical result states dimH(A × B) ≥ dimH(A) + dimH(B) for any metric spaces, with equality when A satisfies certain regularity conditions (e.g., Ahlfors regularity). Formalizing this in Lean would require developing the product metric space Hausdorff measure theory. The key insight is that the product Hausdorff measure satisfies μH^{s+t}(A × B) ≥ μH^s(A) · μH^t(B), which can be proved using Frostman's lemma or direct covering arguments. Why now? Mathlib already has `dimH` and product metric spaces; the missing piece is the covering-theoretic argument connecting product coverings to factor coverings, which our Lipschitz inverse technique (`dimH_image_eq_of_lipschitz_inverse`) could assist via projection maps.

## 3. Conformal Dimension as a Topological Invariant

The conformal dimension of a metric space X is defined as cdim(X) = inf{dimH(Y) : Y quasi-symmetrically equivalent to X}. This is a genuine topological invariant (invariant under quasi-symmetric homeomorphisms). Conjecturally, for self-similar fractals satisfying the open set condition, cdim equals the Ahlfors regular conformal dimension, which can be computed via moduli of curve families. The key insight is that our `dimH_eq_of_biLipschitzOn_fullDim` theorem is the bi-Lipschitz special case of what should hold for quasi-symmetric maps, and cdim captures exactly what remains after quotienting out by quasi-symmetric equivalence. Why now? The infrastructure for `AntilipschitzOnWith` and dimension preservation under Lipschitz inverses provides the foundation; the next step is extending to the quasi-symmetric category.

## 4. Dimension Spectrum of IFS Attractors via Lipschitz Sections

For an iterated function system (IFS) {f₁, ..., fₙ} of contractions on a complete metric space, the attractor K satisfies dimH(K) ≤ s where s is the similarity dimension (solution to Σ rᵢˢ = 1). When the IFS satisfies the open set condition, equality holds. A formalization strategy: define the coding map π : {1,...,n}^ℕ → K, show it is Hölder continuous (using contractivity), and show it has a Lipschitz section on a dense subset (using the open set condition). Then apply our `dimH_image_bounds_of_holderOnWith_antilipschitzOnWith` to get both directions of the dimension bound. The key insight is that the coding map is Hölder with exponent related to the contraction ratios, and the open set condition provides the antilipschitz inverse needed for the lower bound. Why now? The Hölder-antilipschitz distortion bounds we proved are precisely the tool needed to formalize this classical argument.

## 5. Bi-Lipschitz Embedding Dimension of Fractals

Define the bi-Lipschitz embedding dimension of a compact metric space X as bldim(X) = inf{n ∈ ℕ : X bi-Lipschitz embeds into ℝⁿ}. The Assouad embedding theorem guarantees bldim(X) ≤ C·dim_A(X) for doubling spaces, where dim_A is the Assouad dimension. Conjecture: for self-similar fractals, bldim equals the ceiling of the Hausdorff dimension. The key insight is that our `biLipschitzOn_dimH_image_eq` theorem shows bi-Lipschitz embeddings preserve dimH exactly, so bldim(X) ≥ ⌈dimH(X)⌉ follows immediately (since dimH(ℝⁿ) = n). The upper bound requires constructive embedding arguments specific to each fractal. Why now? The dimension preservation result `biLipschitzOn_dimH_image_eq` gives the lower bound for free; formalizing the Assouad embedding theorem would yield the upper bound and complete the picture.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v6 Depth Requirements — Correct Proofs First

You are working on the frontier of mathematics. Your goal is to produce
Lean 4 code that COMPILES and PROVES non-trivial results. A correct proof
of one good theorem is worth more than 5 theorems with `sorry`.

### STEP 1: BRIEF PLAN (2-3 lines)

Before writing Lean code, state:
- **Strategy**: New structure (Grothendieck) OR extend existing result (Cauchy)
- **Theorems**: List the 2-4 theorems you will prove (one sentence each)
- **Why non-trivial**: One sentence explaining the key insight

### STEP 2: PROVE THEOREMS (correctness > completeness)

Write Lean 4 proofs that COMPILE. Every theorem should have:
- A complete proof (no `sorry` for the main result)
- A brief proof sketch as a comment (1-2 sentences)
- An `example` block showing the theorem in action (if practical)

For your BEST theorem, also provide:
- A generalization or strengthening (can use `sorry` if proving it would take too long)
- A boundary case or counterexample showing where the result fails

You do NOT need full PEGB on every theorem. Deep PEGB on your best theorem
and solid proofs on the rest is the target.

### STEP 3: Anti-patterns (avoid these)

These tactics indicate trivial proofs that add no value:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on the main theorem statement

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for generalizations and boundary cases.

### STEP 4: Novelty

Your theorems should be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
