
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

**Title**: The file `Basic.lean` establishes a fully formal, axiom-clean depth-separation
**Domain**: Novelty
**Mathematical framing**: # Future Directions: ReLU Width–Depth Trade-offs

The file `Basic.lean` establishes a fully formal, axiom-clean depth-separation
result for ReLU networks built from the tent map `tent x = 1 - |2x - 1|`. The
depth-`k` constant-width network `tent^[k]` rises from `0` to `1` over an
interval of width `2^{-k}` (`tent_iterate_zero`, `tent_iterate_peak`), is
`2^k`-Lipschitz (`tent_iterate_lipschitz`), yet stays bounded in `[0,1]`. Any
`K`-Lipschitz approximant with `K·2^{-k} + 2ε < 1` provably fails
(`relu_depth_separation`). The following directions extend this frontier; each
is testable and falsifiable.

## 1. From a single steep ramp to a counting (oscillation) lower bound

The current obstruction uses one ramp of width `2^{-k}`. The sharper
Telgarsky-style statement counts oscillations: `tent^[k]` crosses the level
`1/2` exactly `2^k` times, while a one-hidden-layer ReLU network of width `w`
is piecewise-linear with at most `w+1` pieces and hence crosses any level at
most `w+1` times. This yields an *exact width lower bound* `w ≥ 2^k - 1`,
independent of the weight magnitudes — a strictly stronger separation than the
Lipschitz version.
**The key insight is** that the crossing number of a continuous piecewise-linear
function is bounded by its number of affine pieces, so an exponential crossing
count forces exponential width regardless of how large the weights are allowed
to be. **Why now?** The tent and its iterate are already formalized with their
ascending-branch identity `tent_eq_two_mul`; the missing ingredient is a Lean
lemma "a function with `p` affine pieces has at most `p` solutions to `f = c`",
which is a finite combinatorial fact about `tent_iterate_peak`-style alternation
and is within reach of the existing induction machinery.

## 2. Matching shallow upper bound: quantitative 1-D universal approximation

Pair the lower bound with a constructive upper bound: every `K`-Lipschitz
`f : [0,1] → ℝ` is approximated within `ε` by the piecewise-linear interpolant
on `N = ⌈K/ε⌉` equal nodes, which is exactly a width-`N` one-hidden-layer ReLU
network. This pins the shallow cost at `Θ(K/ε)` and, with direction 1, closes
the `width ≈ ε^{-1}` (shallow) vs `depth ≈ log(1/ε)` (deep) gap quantitatively.
**The key insight is** that Lipschitz control bounds the interpolation error by
`K · (mesh size)`, so a uniform mesh of `K/ε` nodes suffices and each interior
node is one ReLU neuron. **Why now?** `relu_depth_separation` already isolates
the Lipschitz constant as the governing quantity; the dual upper bound reuses
the same `LipschitzWith` API plus Mathlib's `Real`-interval interpolation
lemmas, making the two-sided `Θ` characterization formalizable today.

## 3. Higher-dimensional separation on `[-1,1]^n`

Lift the construction to `[-1,1]^n` via tensorized tents
`F(x) = tent^[k](x₁) · ⋯ · tent^[k](xₙ)` or a max-pooling variant, and show the
shallow Lipschitz/width cost scales as `ε^{-n}` while a depth-`O(n·log(1/ε))`
network keeps polynomial size — the genuine curse-of-dimensionality separation
named in the original concept.
**The key insight is** that local steepness is multiplicative under tensor
products, so the per-coordinate factor `2^k` compounds to `2^{nk}` worth of
oscillation that a single shallow layer must resolve along every axis
simultaneously. **Why now?** The 1-D engine (`tent_lipschitz`,
`tent_iterate_lipschitz`) is multiplicative-composition-ready, and Mathlib's
`LipschitzWith.prod`/`pi` lemmas give the product Lipschitz bounds needed to
transport the obstruction coordinatewise.

## 4. Robustness / adversarial reading of the Lipschitz obstruction

Reinterpret `relu_depth_separation` as a *robustness lower bound*: because
`tent^[k]` has local slope `2^k`, an input perturbation of size `2^{-k}` flips
the output across the full range `[0,1]`. Formalize that any classifier of
Lipschitz constant `K < 2^k` must misclassify some `2^{-k}`-adversarial pair,
giving a provable depth-induced fragility theorem.
**The key insight is** that the *same* quantity (local slope `2^k`) that defeats
shallow approximation also certifies adversarial sensitivity, unifying
expressivity and robustness through one Lipschitz budget. **Why now?** The
endpoints `tent_iterate_zero = 0` and `tent_iterate_peak = 1` already exhibit an
explicit `2^{-k}`-separated pair with maximal output gap, so the adversarial
statement is a direct repackaging of the proven inequality.

## 5. Cross-domain bridge: tent oscillation vs. the EML exponential tower

The catalog's `MachineLearning.DepthSeparation.Separation` proves a Lipschitz
obstruction for the iterated *exponential* `iterExp k` (whose **range** explodes
like a tower), whereas this file's `tent^[k]` keeps a **bounded range** but
explodes in **local slope**. Formalize a single abstract obstruction
—"`f` attains values `a < b` at points distance `δ` apart ⟹ no `K`-Lipschitz
`ε`-approximant exists once `K·δ + 2ε < b - a`"— and derive *both* theorems as
instances.
**The key insight is** that range-blowup and slope-blowup are two faces of one
inequality `(b-a) ≤ K·δ + 2ε`, so a single lemma parameterized by the
witnessing pair `(δ, b-a)` subsumes the exponential-tower and tent-map
separations. **Why now?** Both endpoint computations already exist in the
catalog (`iterExp_endpoint_gap`) and in this file (`tent_iterate_peak`), so the
unifying lemma can be stated, proven once, and back-applied to retire two
bespoke proofs — a concrete cross-domain consolidation.

**Concept description**: # Future Directions: ReLU Width–Depth Trade-offs

The file `Basic.lean` establishes a fully formal, axiom-clean depth-separation
result for ReLU networks built from the tent map `tent x = 1 - |2x - 1|`. The
depth-`k` constant-width network `tent^[k]` rises from `0` to `1` over an
interval of width `2^{-k}` (`tent_iterate_zero`, `tent_iterate_peak`), is
`2^k`-Lipschitz (`tent_iterate_lipschitz`), yet stays bounded in `[0,1]`. Any
`K`-Lipschitz approximant with `K·2^{-k} + 2ε < 1` provably fails
(`relu_depth_separation`). The following directions extend this frontier; each
is testable and falsifiable.

## 1. From a single steep ramp to a counting (oscillation) lower bound

The current obstruction uses one ramp of width `2^{-k}`. The sharper
Telgarsky-style statement counts oscillations: `tent^[k]` crosses the level
`1/2` exactly `2^k` times, while a one-hidden-layer ReLU network of width `w`
is piecewise-linear with at most `w+1` pieces and hence crosses any level at
most `w+1` times. This yields an *exact width lower bound* `w ≥ 2^k - 1`,
independent of the weight magnitudes — a strictly stronger separation than the
Lipschitz version.
**The key insight is** that the crossing number of a continuous piecewise-linear
function is bounded by its number of affine pieces, so an exponential crossing
count forces exponential width regardless of how large the weights are allowed
to be. **Why now?** The tent and its iterate are already formalized with their
ascending-branch identity `tent_eq_two_mul`; the missing ingredient is a Lean
lemma "a function with `p` affine pieces has at most `p` solutions to `f = c`",
which is a finite combinatorial fact about `tent_iterate_peak`-style alternation
and is within reach of the existing induction machinery.

## 2. Matching shallow upper bound: quantitative 1-D universal approximation

Pair the lower bound with a constructive upper bound: every `K`-Lipschitz
`f : [0,1] → ℝ` is approximated within `ε` by the piecewise-linear interpolant
on `N = ⌈K/ε⌉` equal nodes, which is exactly a width-`N` one-hidden-layer ReLU
network. This pins the shallow cost at `Θ(K/ε)` and, with direction 1, closes
the `width ≈ ε^{-1}` (shallow) vs `depth ≈ log(1/ε)` (deep) gap quantitatively.
**The key insight is** that Lipschitz control bounds the interpolation error by
`K · (mesh size)`, so a uniform mesh of `K/ε` nodes suffices and each interior
node is one ReLU neuron. **Why now?** `relu_depth_separation` already isolates
the Lipschitz constant as the governing quantity; the dual upper bound reuses
the same `LipschitzWith` API plus Mathlib's `Real`-interval interpolation
lemmas, making the two-sided `Θ` characterization formalizable today.

## 3. Higher-dimensional separation on `[-1,1]^n`

Lift the construction to `[-1,1]^n` via tensorized tents
`F(x) = tent^[k](x₁) · ⋯ · tent^[k](xₙ)` or a max-pooling variant, and show the
shallow Lipschitz/width cost scales as `ε^{-n}` while a depth-`O(n·log(1/ε))`
network keeps polynomial size — the genuine curse-of-dimensionality separation
named in the original concept.
**The key insight is** that local steepness is multiplicative under tensor
products, so the per-coordinate factor `2^k` compounds to `2^{nk}` worth of
oscillation that a single shallow layer must resolve along every axis
simultaneously. **Why now?** The 1-D engine (`tent_lipschitz`,
`tent_iterate_lipschitz`) is multiplicative-composition-ready, and Mathlib's
`LipschitzWith.prod`/`pi` lemmas give the product Lipschitz bounds needed to
transport the obstruction coordinatewise.

## 4. Robustness / adversarial reading of the Lipschitz obstruction

Reinterpret `relu_depth_separation` as a *robustness lower bound*: because
`tent^[k]` has local slope `2^k`, an input perturbation of size `2^{-k}` flips
the output across the full range `[0,1]`. Formalize that any classifier of
Lipschitz constant `K < 2^k` must misclassify some `2^{-k}`-adversarial pair,
giving a provable depth-induced fragility theorem.
**The key insight is** that the *same* quantity (local slope `2^k`) that defeats
shallow approximation also certifies adversarial sensitivity, unifying
expressivity and robustness through one Lipschitz budget. **Why now?** The
endpoints `tent_iterate_zero = 0` and `tent_iterate_peak = 1` already exhibit an
explicit `2^{-k}`-separated pair with maximal output gap, so the adversarial
statement is a direct repackaging of the proven inequality.

## 5. Cross-domain bridge: tent oscillation vs. the EML exponential tower

The catalog's `MachineLearning.DepthSeparation.Separation` proves a Lipschitz
obstruction for the iterated *exponential* `iterExp k` (whose **range** explodes
like a tower), whereas this file's `tent^[k]` keeps a **bounded range** but
explodes in **local slope**. Formalize a single abstract obstruction
—"`f` attains values `a < b` at points distance `δ` apart ⟹ no `K`-Lipschitz
`ε`-approximant exists once `K·δ + 2ε < b - a`"— and derive *both* theorems as
instances.
**The key insight is** that range-blowup and slope-blowup are two faces of one
inequality `(b-a) ≤ K·δ + 2ε`, so a single lemma parameterized by the
witnessing pair `(δ, b-a)` subsumes the exponential-tower and tent-map
separations. **Why now?** Both endpoint computations already exist in the
catalog (`iterExp_endpoint_gap`) and in this file (`tent_iterate_peak`), so the
unifying lemma can be stated, proven once, and back-applied to retire two
bespoke proofs — a concrete cross-domain consolidation.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v9 Depth Requirements -- Adversarial Ground-Truth Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Adversarial Ground-Truth**. Trust nothing, assume everything is false until proven, and actively seek weaknesses. Think like an Adversarial Critic to pressure-test claims.

### RESEARCH CORE METHODOLOGY:
1. **Challenge Assumptions**: For every conjecture or theorem under investigation, actively search for counterexamples, corner cases, and boundary conditions. Proving that a claim is FALSE or identifying exactly where it fails is as valuable as a proof.
2. **Stress-Test the Frontier**: When a proof succeeds, push it to its limits. What happens if you drop or if a hypothesis is weakened? Write explicit comments documenting these boundary conditions.
3. **Relentless Rigor**: Write robust, clean, compilable Lean 4 proofs. Avoid trivial tautologies or simple wrapper theorems. Let your mathematical curiosity drive deep structural insights.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
