
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


## Concept

**Title**: The geodesic equations for the split metric ds² = sech²(y) dx² + cosh²(x) dy² yi
**Domain**: Geometry
**Mathematical framing**: # Future Directions: Split Geometry

## 1. Geodesic Equations and Phase Boundary Crossing

The geodesic equations for the split metric ds² = sech²(y) dx² + cosh²(x) dy² yield a coupled ODE system via the Christoffel symbols. The key insight is that geodesics transitioning between the elliptic region (|x| < |y|, K > 0) and hyperbolic region (|x| > |y|, K < 0) must cross the phase boundary |x| = |y| where K = 0, and the curvature sign change constrains how many crossings are possible. A natural conjecture: geodesics in split geometry cross the phase boundary at most finitely many times, with the number of crossings bounded by a function of the initial energy. Why now? The curvature sign characterization (splitCurvature_pos_iff) provides the precise geometric partition needed to analyze geodesic behavior region-by-region, and Mathlib's ODE theory is now mature enough to formalize existence and uniqueness of geodesic flows.

## 2. Gauss-Bonnet for Split Triangles

For a geodesic triangle with vertices in different curvature regions, the Gauss-Bonnet theorem gives angle excess = ∫∫ K dA where dA = √(det g) dx dy = (cosh x / cosh y) dx dy. The key insight is that the integral of K = sech²(x) - sech²(y) over a region straddling the diagonal can be decomposed as a difference of two independent 1D integrals: ∫∫ K dA = ∫∫ sech²(x)·(cosh x/cosh y) dx dy - ∫∫ sech²(y)·(cosh x/cosh y) dx dy, each of which has a closed-form antiderivative involving tanh and sinh. This would yield explicit angle-excess formulas for split triangles — a concrete computational test of the geometry. Why now? The splitMetricDet_pos theorem guarantees the volume form is well-defined, and the bounded curvature (splitCurvature_bound) ensures convergence of area integrals over compact regions.

## 3. Generalized Split Metrics: The (α, β)-Family

Replace the split metric with ds² = cosh^α(y) dx² + cosh^β(x) dy² for parameters α, β ∈ ℝ. The original split metric corresponds to (α, β) = (-2, 2). The key insight is that the curvature of the (α,β)-metric is K(x,y) = f_α(y) + g_β(x) for explicit functions f_α, g_β, so the zero-curvature locus is always a curve of the form g_β(x) = -f_α(y), which is a level set of a separable function — making the phase boundary geometry analytically tractable for all parameter values. The conjecture is that for α < 0 < β, the phase boundary is always a pair of curves asymptotic to the diagonals, and for αβ > 0 the curvature has constant sign. Why now? The monotonicity machinery (cosh_sq_strictMonoOn, cosh_lt_cosh_iff_abs_lt) generalizes directly to cosh^n for integer n, and the antisymmetry theorem extends to the case α = -β.

## 4. Completeness and Incompleteness of Split Geometry

A Riemannian manifold is geodesically complete if every geodesic extends to all time. The key insight is that the split metric has anisotropic completeness: the metric component sech²(y) → 0 as |y| → ∞ (making horizontal distances shrink), while cosh²(x) → ∞ as |x| → ∞ (making vertical distances grow). This suggests that the split metric is complete in the y-direction but potentially incomplete in the x-direction, since a horizontal geodesic can "reach infinity in finite time" when the metric degenerates. A formal proof of incompleteness would establish split geometry as a natural example of a non-complete Riemannian surface with mixed-sign curvature. Why now? The metric positivity (splitG11_pos, splitG22_pos) and determinant bounds (splitMetricDet_ge_one_iff) provide the quantitative control needed to estimate geodesic lengths.

## 5. Spectral Theory of the Split Laplacian

The Laplace-Beltrami operator for the split metric is Δf = cosh²(y) ∂²f/∂x² + (1/cosh²(x)) ∂²f/∂y² (up to lower-order terms from Christoffel symbols). The key insight is that this operator separates variables: Δ(X(x)Y(y)) = cosh²(y)X''Y + Y''X/cosh²(x), and after dividing by XY one obtains two independent Sturm-Liouville problems with potentials involving cosh². This means the spectrum of the split Laplacian on bounded domains decomposes into tensor products of 1D spectra — each factor governed by a Pöschl-Teller-type potential with known exact solutions. Why now? The curvature bounds (-1 < K < 1) from splitCurvature_bound ensure the operator is uniformly elliptic on compact sets, and Mathlib's spectral theory for self-adjoint operators can handle the resulting eigenvalue problems.

**Concept description**: # Future Directions: Split Geometry

## 1. Geodesic Equations and Phase Boundary Crossing

The geodesic equations for the split metric ds² = sech²(y) dx² + cosh²(x) dy² yield a coupled ODE system via the Christoffel symbols. The key insight is that geodesics transitioning between the elliptic region (|x| < |y|, K > 0) and hyperbolic region (|x| > |y|, K < 0) must cross the phase boundary |x| = |y| where K = 0, and the curvature sign change constrains how many crossings are possible. A natural conjecture: geodesics in split geometry cross the phase boundary at most finitely many times, with the number of crossings bounded by a function of the initial energy. Why now? The curvature sign characterization (splitCurvature_pos_iff) provides the precise geometric partition needed to analyze geodesic behavior region-by-region, and Mathlib's ODE theory is now mature enough to formalize existence and uniqueness of geodesic flows.

## 2. Gauss-Bonnet for Split Triangles

For a geodesic triangle with vertices in different curvature regions, the Gauss-Bonnet theorem gives angle excess = ∫∫ K dA where dA = √(det g) dx dy = (cosh x / cosh y) dx dy. The key insight is that the integral of K = sech²(x) - sech²(y) over a region straddling the diagonal can be decomposed as a difference of two independent 1D integrals: ∫∫ K dA = ∫∫ sech²(x)·(cosh x/cosh y) dx dy - ∫∫ sech²(y)·(cosh x/cosh y) dx dy, each of which has a closed-form antiderivative involving tanh and sinh. This would yield explicit angle-excess formulas for split triangles — a concrete computational test of the geometry. Why now? The splitMetricDet_pos theorem guarantees the volume form is well-defined, and the bounded curvature (splitCurvature_bound) ensures convergence of area integrals over compact regions.

## 3. Generalized Split Metrics: The (α, β)-Family

Replace the split metric with ds² = cosh^α(y) dx² + cosh^β(x) dy² for parameters α, β ∈ ℝ. The original split metric corresponds to (α, β) = (-2, 2). The key insight is that the curvature of the (α,β)-metric is K(x,y) = f_α(y) + g_β(x) for explicit functions f_α, g_β, so the zero-curvature locus is always a curve of the form g_β(x) = -f_α(y), which is a level set of a separable function — making the phase boundary geometry analytically tractable for all parameter values. The conjecture is that for α < 0 < β, the phase boundary is always a pair of curves asymptotic to the diagonals, and for αβ > 0 the curvature has constant sign. Why now? The monotonicity machinery (cosh_sq_strictMonoOn, cosh_lt_cosh_iff_abs_lt) generalizes directly to cosh^n for integer n, and the antisymmetry theorem extends to the case α = -β.

## 4. Completeness and Incompleteness of Split Geometry

A Riemannian manifold is geodesically complete if every geodesic extends to all time. The key insight is that the split metric has anisotropic completeness: the metric component sech²(y) → 0 as |y| → ∞ (making horizontal distances shrink), while cosh²(x) → ∞ as |x| → ∞ (making vertical distances grow). This suggests that the split metric is complete in the y-direction but potentially incomplete in the x-direction, since a horizontal geodesic can "reach infinity in finite time" when the metric degenerates. A formal proof of incompleteness would establish split geometry as a natural example of a non-complete Riemannian surface with mixed-sign curvature. Why now? The metric positivity (splitG11_pos, splitG22_pos) and determinant bounds (splitMetricDet_ge_one_iff) provide the quantitative control needed to estimate geodesic lengths.

## 5. Spectral Theory of the Split Laplacian

The Laplace-Beltrami operator for the split metric is Δf = cosh²(y) ∂²f/∂x² + (1/cosh²(x)) ∂²f/∂y² (up to lower-order terms from Christoffel symbols). The key insight is that this operator separates variables: Δ(X(x)Y(y)) = cosh²(y)X''Y + Y''X/cosh²(x), and after dividing by XY one obtains two independent Sturm-Liouville problems with potentials involving cosh². This means the spectrum of the split Laplacian on bounded domains decomposes into tensor products of 1D spectra — each factor governed by a Pöschl-Teller-type potential with known exact solutions. Why now? The curvature bounds (-1 < K < 1) from splitCurvature_bound ensure the operator is uniformly elliptic on compact sets, and Mathlib's spectral theory for self-adjoint operators can handle the resulting eigenvalue problems.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Geometry
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Research Team Protocol

You are leading a research team. Your team has different roles:
- The **Hypothesizer** generates bold, falsifiable conjectures
- The **Experimenter** proves or disproves them in Lean 4
- The **Analyst** examines what survived, what failed, and WHY
- The **Critic** searches for weaknesses, constructs counterexamples,
  and identifies where proofs might break down. A well-constructed
  counterexample is as valuable as a proof.
- The **Synthesist** upgrades the knowledge base and writes the
  FUTURE_DIRECTIONS.md that seeds the next cycle

You run this loop: **Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate**.
Each cycle is not a one-shot task. It is one iteration of an infinite
research process. Your notes (FUTURE_DIRECTIONS.md, Lab Notebooks,
proof sketches) determine whether the next team builds on your work
or starts over.

**Take good notes.** A cycle without useful notes is a wasted cycle.

### STEP 1: THEOREM DECLARATIONS (required -- before any code)

List every theorem you intend to prove or investigate. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `hypothesis` | `conjecture` | `proved` | `proved_with_lemma_sorry` | `disproved`
- **Why it matters**: One sentence on what this result would mean if true,
  and what it would teach us if false

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective -- proved -- constructive inverse -- confirms decidability of Nat x Nat
2. `cantorPairing_injective`: Cantor pairing is injective -- proved -- diagonal argument -- confirms invertibility
3. `cantorPairing_bijection`: Cantor pairing is a bijection -- proved_with_lemma_sorry -- follows from 1+2 -- completing the characterization

Use `hypothesis` for statements you are not yet sure you can prove but
want to investigate. Use `conjecture` for statements you believe are true
but cannot prove in this cycle. Use `disproved` for statements where you
found a counterexample. Use `proved` for statements with complete Lean
proofs. Use `proved_with_lemma_sorry` when the main proof is complete but
one or more supporting lemmas use `sorry`.

### STEP 2: EXPERIMENT (prove or disprove in Lean 4)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its
status to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it is deferred

**Disproofs count.** If a hypothesis is false, prove its negation or
construct an explicit counterexample. A well-constructed counterexample
is as valuable as a proof. Change the status to `disproved` and state
the counterexample clearly.

### STEP 3: CRITIQUE (find the weaknesses)

For your best theorem, the Critic must:
- Identify the strongest assumption that could be weakened
- Construct a boundary case: where does the result break down?
- If possible, state a `conjecture` for the generalized version and
  explain what would need to change in the proof

This is NOT optional. A theorem without a critique is incomplete.

### STEP 4: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` -- unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures, generalizations, and boundary cases.

### STEP 5: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### STEP 6: TAKE GOOD NOTES (first-class deliverables)

Your notes determine what the next research team investigates. They are NOT
an afterthought. They are your most important output after the proofs themselves.

**6a. Lab Notebook** (in each .lean file, as `-- !-- Lab Notebook -- !--` blocks):

For each major theorem, include a Lab Notebook comment block:
```lean
-- !-- Lab Notebook: cantorPairing_bijection -- !--
-- !-- Hypothesis: Cantor pairing is bijective because both surjective and injective -- !--
-- !-- Result: Proved via composition of surjective and injective proofs -- !--
-- !-- Insight: The constructive inverse of surjectivity is key; diagonal argument handles injectivity -- !--
-- !-- Failure analysis: Initial attempt to prove bijection directly failed; decomposition into surjective+injective was necessary -- !--
-- !-- End Lab Notebook -- !--
```

**6b. FUTURE_DIRECTIONS.md** (structured, not freeform):

Required structure:

## Synthesis
[2-3 paragraphs: what did this cycle discover? What failed and why? What
structural insight emerged? Tie the directions together into a narrative.]

## Results Summary
[For each theorem: name, status (proved/conjecture/disproved), one-sentence
significance. This is the lab notebook summary -- be precise.]

## Research Directions

### Direction 1: [Concise title]
**Hypothesis**: A precise, falsifiable mathematical statement.
**Test**: What experiment (proof/disproof/computation) would confirm or refute it.
**Why now**: What from THIS cycle makes this tractable.
**If true**: What new territory this opens.
**If false**: What the failure teaches us.

[Repeat for 3-5 directions]

### STEP 7: Generalization loop

For your BEST theorem, attempt one level of generalization:
- State a stronger version (can use sorry if proving would take too long)
- Identify the boundary: where does the result break down?
- If the generalization is itself interesting, mark it as a `conjecture`
  in your theorem declarations and explain it in FUTURE_DIRECTIONS.md

### Output format

Your output must include:
1. `.lean` files with proofs and Lab Notebook blocks (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with Synthesis, Results Summary, and 3-5 research
   directions (structured as in Step 6b)

Both are required. A cycle with proofs but no Lab Notebook or
FUTURE_DIRECTIONS.md is a cycle where the next team starts from scratch.
Take good notes.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
