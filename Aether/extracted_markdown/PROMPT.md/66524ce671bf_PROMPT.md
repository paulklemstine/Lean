
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

**Title**: For a Calabi-Yau threefold X defined over ℚ, the L-function L(X, s) = Σ aₙ n⁻ˢ
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Arithmetic Mirror Symmetry

## 1. Modularity of CY Threefold Point Counts

For a Calabi-Yau threefold X defined over ℚ, the L-function L(X, s) = Σ aₙ n⁻ˢ
conjecturally satisfies a functional equation and admits analytic continuation.
For rigid CY threefolds (h²¹ = 0), the Fourier coefficients aₚ should coincide
with those of a weight-4 modular form.

The key insight is that the mirror Euler characteristic theorem (χ̃ = (-1)ⁿχ)
constrains the functional equation of L(X, s) via the parity of the motivic
weight, and for rigid CY threefolds the mirror has h¹¹ = 0 which forces the
L-function to be modular by Serre's conjecture (now proved).

Why now? The formalized Hodge diamond structure with Serre duality provides the
exact framework to state and prove that the Galois representation on H³(X)
has the correct Hodge-Tate weights for modularity. The `betti_poincare_dual`
theorem already encodes Poincaré duality, which is the geometric input to the
functional equation.

## 2. Arithmetic Mirror Map and Period Integrals

The mirror map τ(z) = ∫ Ω_z / ∫ Ω₀ relates the complex structure parameter z
of the mirror family to the Kähler parameter τ of X. For the quintic, this map
has q-expansion coefficients that are integers — a deep arithmetic fact.

The key insight is that integrality of the mirror map coefficients is equivalent
to a congruence condition on the Picard-Fuchs differential equation modulo
primes, which can be formalized as a statement about p-adic valuations of
hypergeometric series ₄F₃ evaluated at rational points.

Why now? Our formalization of CY3Data with concrete quintic examples (h¹¹=1,
h²¹=101) provides the numerical framework. The next step is to formalize the
Picard-Fuchs operator for the quintic family and prove that its solutions at
the MUM point have integer q-expansion, which is a finite verification for each
coefficient.

## 3. SYZ Fibration and Tropical Mirror Symmetry

The SYZ conjecture says mirror symmetry is T-duality on special Lagrangian torus
fibrations. Tropicalizing this picture yields a combinatorial version: the mirror
of a toric CY hypersurface is computed by dualizing the Newton polytope.

The key insight is that for toric CY hypersurfaces, h^{1,1}(X) equals the number
of lattice points interior to facets of the Newton polytope Δ, while h^{n-1,1}(X)
equals the number of interior lattice points of Δ itself, and the Batyrev mirror
construction swaps Δ ↔ Δ° (polar dual). This makes our mirror_euler_sign theorem
a shadow of a purely combinatorial duality.

Why now? Tropical geometry and polytope combinatorics are well within reach of
Lean formalization. The Hodge diamond framework we built can be instantiated with
Batyrev's formula, and the Euler characteristic relation becomes a theorem about
Ehrhart polynomials of dual polytopes.

## 4. Weil Conjectures for CY Varieties over Finite Fields

For a smooth CY n-fold X over 𝔽_q, the zeta function Z(X/𝔽_q, T) is a rational
function whose factors correspond to cohomology groups. Mirror symmetry predicts
specific relationships between the zeta functions of X and its mirror X̌.

The key insight is that our Hodge diamond structure directly controls the degrees
of the numerator/denominator factors of the zeta function: the factor corresponding
to Hᵏ has degree bₖ. The `betti_poincare_dual` theorem then implies the functional
equation Z(X, 1/q^n T) = ±q^{nχ/2} T^χ Z(X, T), and `eulerChar_mirror` shows
how this functional equation transforms under the mirror involution.

Why now? The Weil conjectures for smooth projective varieties follow from étale
cohomology theory. While full étale cohomology is not in Mathlib, the numerology
(degree of zeta function factors = Betti numbers) can be stated as axioms and
the mirror symmetry consequences derived formally from our framework.

## 5. Higher-Dimensional Hodge Diamond Classification

For CY n-folds with n ≥ 4, the Hodge diamond has more free parameters than
just (h¹¹, h^{n-1,1}). The mirror involution h^{p,q} ↦ h^{n-p,q} imposes
non-trivial constraints on which Hodge diamonds can appear in mirror pairs.

The key insight is that the CYHodgeDiamond structure we formalized (with the
vanishing conditions h^{k,0} = 0 for 0 < k < n) combined with Hodge symmetry
and Serre duality dramatically reduces the number of free Hodge numbers. For
CY 4-folds, the independent numbers are h¹¹, h²¹, h³¹, and h²², subject to
the constraint 2(24 + h¹¹ + h³¹ - h²¹) = h²² (from the top Chern class being
the Euler characteristic). Mirror symmetry then swaps h¹¹ ↔ h³¹ while
preserving h²¹ and h²².

Why now? Our formalization already handles the general n case for CY Hodge
diamonds. Specializing to n = 4 and proving the Chern class constraint as a
linear relation on Hodge numbers would yield the first formal verification of
CY 4-fold mirror symmetry constraints, which are actively studied in F-theory
compactifications.

**Concept description**: # Future Directions: Arithmetic Mirror Symmetry

## 1. Modularity of CY Threefold Point Counts

For a Calabi-Yau threefold X defined over ℚ, the L-function L(X, s) = Σ aₙ n⁻ˢ
conjecturally satisfies a functional equation and admits analytic continuation.
For rigid CY threefolds (h²¹ = 0), the Fourier coefficients aₚ should coincide
with those of a weight-4 modular form.

The key insight is that the mirror Euler characteristic theorem (χ̃ = (-1)ⁿχ)
constrains the functional equation of L(X, s) via the parity of the motivic
weight, and for rigid CY threefolds the mirror has h¹¹ = 0 which forces the
L-function to be modular by Serre's conjecture (now proved).

Why now? The formalized Hodge diamond structure with Serre duality provides the
exact framework to state and prove that the Galois representation on H³(X)
has the correct Hodge-Tate weights for modularity. The `betti_poincare_dual`
theorem already encodes Poincaré duality, which is the geometric input to the
functional equation.

## 2. Arithmetic Mirror Map and Period Integrals

The mirror map τ(z) = ∫ Ω_z / ∫ Ω₀ relates the complex structure parameter z
of the mirror family to the Kähler parameter τ of X. For the quintic, this map
has q-expansion coefficients that are integers — a deep arithmetic fact.

The key insight is that integrality of the mirror map coefficients is equivalent
to a congruence condition on the Picard-Fuchs differential equation modulo
primes, which can be formalized as a statement about p-adic valuations of
hypergeometric series ₄F₃ evaluated at rational points.

Why now? Our formalization of CY3Data with concrete quintic examples (h¹¹=1,
h²¹=101) provides the numerical framework. The next step is to formalize the
Picard-Fuchs operator for the quintic family and prove that its solutions at
the MUM point have integer q-expansion, which is a finite verification for each
coefficient.

## 3. SYZ Fibration and Tropical Mirror Symmetry

The SYZ conjecture says mirror symmetry is T-duality on special Lagrangian torus
fibrations. Tropicalizing this picture yields a combinatorial version: the mirror
of a toric CY hypersurface is computed by dualizing the Newton polytope.

The key insight is that for toric CY hypersurfaces, h^{1,1}(X) equals the number
of lattice points interior to facets of the Newton polytope Δ, while h^{n-1,1}(X)
equals the number of interior lattice points of Δ itself, and the Batyrev mirror
construction swaps Δ ↔ Δ° (polar dual). This makes our mirror_euler_sign theorem
a shadow of a purely combinatorial duality.

Why now? Tropical geometry and polytope combinatorics are well within reach of
Lean formalization. The Hodge diamond framework we built can be instantiated with
Batyrev's formula, and the Euler characteristic relation becomes a theorem about
Ehrhart polynomials of dual polytopes.

## 4. Weil Conjectures for CY Varieties over Finite Fields

For a smooth CY n-fold X over 𝔽_q, the zeta function Z(X/𝔽_q, T) is a rational
function whose factors correspond to cohomology groups. Mirror symmetry predicts
specific relationships between the zeta functions of X and its mirror X̌.

The key insight is that our Hodge diamond structure directly controls the degrees
of the numerator/denominator factors of the zeta function: the factor corresponding
to Hᵏ has degree bₖ. The `betti_poincare_dual` theorem then implies the functional
equation Z(X, 1/q^n T) = ±q^{nχ/2} T^χ Z(X, T), and `eulerChar_mirror` shows
how this functional equation transforms under the mirror involution.

Why now? The Weil conjectures for smooth projective varieties follow from étale
cohomology theory. While full étale cohomology is not in Mathlib, the numerology
(degree of zeta function factors = Betti numbers) can be stated as axioms and
the mirror symmetry consequences derived formally from our framework.

## 5. Higher-Dimensional Hodge Diamond Classification

For CY n-folds with n ≥ 4, the Hodge diamond has more free parameters than
just (h¹¹, h^{n-1,1}). The mirror involution h^{p,q} ↦ h^{n-p,q} imposes
non-trivial constraints on which Hodge diamonds can appear in mirror pairs.

The key insight is that the CYHodgeDiamond structure we formalized (with the
vanishing conditions h^{k,0} = 0 for 0 < k < n) combined with Hodge symmetry
and Serre duality dramatically reduces the number of free Hodge numbers. For
CY 4-folds, the independent numbers are h¹¹, h²¹, h³¹, and h²², subject to
the constraint 2(24 + h¹¹ + h³¹ - h²¹) = h²² (from the top Chern class being
the Euler characteristic). Mirror symmetry then swaps h¹¹ ↔ h³¹ while
preserving h²¹ and h²².

Why now? Our formalization already handles the general n case for CY Hodge
diamonds. Specializing to n = 4 and proving the Chern class constraint as a
linear relation on Hodge numbers would yield the first formal verification of
CY 4-fold mirror symmetry constraints, which are actively studied in F-theory
compactifications.

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
