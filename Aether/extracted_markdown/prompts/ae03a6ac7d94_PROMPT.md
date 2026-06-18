
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

**Title**: The file `WillmoreEnergy.lean` establishes the elementary half of the Willmore
**Domain**: Geometry
**Mathematical framing**: # Future Directions: Willmore Energy Lower Bounds by Genus

The file `WillmoreEnergy.lean` establishes the elementary half of the Willmore
story in a clean measure-theoretic abstraction: the pointwise square identity
`H² - K = ((κ₁-κ₂)/2)²`, its integral consequence `∫ K ≤ W`, the Gauss–Bonnet
bound `2π·χ ≤ W`, the sharp `4π` bound for genus `0`, the universal `4π` bound
from a Gauss-map degree input, and a precise statement of *why* the elementary
argument degenerates for higher genus. Below are five concrete, falsifiable
directions that build directly on these results and connect to the catalog files
`DiscreteGaussBonnet.lean` (`total_curvature_eq_genus`,
`eulerChar_eq_two_sub_two_mul_genus`) and `GenusFormula.lean`.

## 1. A quantitative umbilic-defect lower bound

The identity `willmoreDensity_sub_gaussCurv` says `W - ∫K = ∫((κ₁-κ₂)/2)²`, the
total *umbilic defect*. Conjecture: for any closed surface,
`W ≥ 2π·χ + c · diam(spec(II))²` for an explicit constant, where the second term
measures how far the surface is from being totally umbilic in an averaged sense.
**The key insight is** that the slack in `gauss_le_willmore` is *itself* a
geometrically meaningful energy (the traceless second fundamental form), so the
inequality can be upgraded to an identity-with-remainder rather than a bare
bound. **Why now?** The remainder is already available in Lean as
`∫ x, ((k1 x - k2 x)/2)^2 ∂μ`; one only needs `integral_eq_integral_add` style
splitting, which is fully supported in current Mathlib measure theory.

## 2. Rigidity: characterizing equality `W = ∫K`

`willmoreDensity_eq_gaussCurv_iff` proves the pointwise rigidity `H² = K ↔ κ₁=κ₂`.
The integral upgrade — `W = ∫K` (with both integrable and the defect `≥ 0`) forces
`κ₁ = κ₂` μ-almost everywhere (total umbilicity) — should follow from
`MeasureTheory.integral_eq_zero_iff_of_nonneg`. **The key insight is** that the
nonnegative defect integrand vanishes in integral iff it vanishes a.e., turning a
pointwise iff into an a.e. rigidity theorem with no new geometry. **Why now?** The
nonnegativity lemma `willmoreDensity_nonneg` plus the square identity are already
proved, so the only missing ingredient is a single standard Mathlib lemma about
a.e.-vanishing of nonnegative integrands.

## 3. Genus-monotonicity of the elementary obstruction

`gaussBonnet_bound_vacuous_high_genus` shows `4π(1-g) ≤ 0` for `g ≥ 1`.
Strengthen this to a *monotone family*: the elementary lower bound
`b(g) = 4π(1-g)` is strictly decreasing in `g`, and the gap between `b(g)` and the
true sharp bound `β(g)` (e.g. `β(1) = 2π²`) is strictly increasing. **The key
insight is** that the elementary Gauss–Bonnet method loses exactly `2π` of
detectable energy per unit genus, which can be stated and proved as a clean real
inequality `b(g+1) = b(g) - 4π`. **Why now?** This is a finite real-arithmetic
statement reachable by `linarith`/`nlinarith` on top of the existing genus
machinery in `DiscreteGaussBonnet.lean`, requiring no analysis at all.

## 4. The Li–Yau multiplicity bound via the set-integral method

`willmore_ge_fourPi_of_setGauss` already isolates the degree mechanism: a region
contributing `≥ 4π` of positive Gauss curvature forces `W ≥ 4π`. Generalize to
the Li–Yau inequality: a surface with a point of multiplicity `k` satisfies
`W ≥ 4πk`. **The key insight is** that `k` disjoint sheets each contribute an
independent `4π` of Gauss-map degree, so the single-set bound becomes a finite
sum over `k` disjoint measurable regions via additivity of the set integral.
**Why now?** `setIntegral_le_integral` and finite additivity of restricted
integrals are present in Mathlib, so the `k = 1` proof here extends to general
`k` by induction with no new analytic input.

## 5. The Marques–Neves bound `2π² ≤ W` for tori (the open target)

`willmore_torus_conjecture` records the genus-1 sharp bound as a `sorry`. A
tractable intermediate target is the *conformal/min-max width* reformulation:
define an abstract "width" functional on the abstract surface model and prove
that (i) the Willmore energy dominates the width and (ii) the width of any
genus-1 configuration is `≥ 2π²`. **The key insight is** that the full
Almgren–Pitts machinery can be *axiomatized* at the level of a width functional
satisfying a small list of monotonicity/normalization properties, reducing the
deep theorem to a finite combinatorial-analytic core that Lean can verify.
**Why now?** The abstract measure-space surface model in this file is exactly the
right setting to host such a width functional without committing to a smooth
manifold structure, so the reformulation can be prototyped immediately on top of
`willmoreEnergy`.

**Concept description**: # Future Directions: Willmore Energy Lower Bounds by Genus

The file `WillmoreEnergy.lean` establishes the elementary half of the Willmore
story in a clean measure-theoretic abstraction: the pointwise square identity
`H² - K = ((κ₁-κ₂)/2)²`, its integral consequence `∫ K ≤ W`, the Gauss–Bonnet
bound `2π·χ ≤ W`, the sharp `4π` bound for genus `0`, the universal `4π` bound
from a Gauss-map degree input, and a precise statement of *why* the elementary
argument degenerates for higher genus. Below are five concrete, falsifiable
directions that build directly on these results and connect to the catalog files
`DiscreteGaussBonnet.lean` (`total_curvature_eq_genus`,
`eulerChar_eq_two_sub_two_mul_genus`) and `GenusFormula.lean`.

## 1. A quantitative umbilic-defect lower bound

The identity `willmoreDensity_sub_gaussCurv` says `W - ∫K = ∫((κ₁-κ₂)/2)²`, the
total *umbilic defect*. Conjecture: for any closed surface,
`W ≥ 2π·χ + c · diam(spec(II))²` for an explicit constant, where the second term
measures how far the surface is from being totally umbilic in an averaged sense.
**The key insight is** that the slack in `gauss_le_willmore` is *itself* a
geometrically meaningful energy (the traceless second fundamental form), so the
inequality can be upgraded to an identity-with-remainder rather than a bare
bound. **Why now?** The remainder is already available in Lean as
`∫ x, ((k1 x - k2 x)/2)^2 ∂μ`; one only needs `integral_eq_integral_add` style
splitting, which is fully supported in current Mathlib measure theory.

## 2. Rigidity: characterizing equality `W = ∫K`

`willmoreDensity_eq_gaussCurv_iff` proves the pointwise rigidity `H² = K ↔ κ₁=κ₂`.
The integral upgrade — `W = ∫K` (with both integrable and the defect `≥ 0`) forces
`κ₁ = κ₂` μ-almost everywhere (total umbilicity) — should follow from
`MeasureTheory.integral_eq_zero_iff_of_nonneg`. **The key insight is** that the
nonnegative defect integrand vanishes in integral iff it vanishes a.e., turning a
pointwise iff into an a.e. rigidity theorem with no new geometry. **Why now?** The
nonnegativity lemma `willmoreDensity_nonneg` plus the square identity are already
proved, so the only missing ingredient is a single standard Mathlib lemma about
a.e.-vanishing of nonnegative integrands.

## 3. Genus-monotonicity of the elementary obstruction

`gaussBonnet_bound_vacuous_high_genus` shows `4π(1-g) ≤ 0` for `g ≥ 1`.
Strengthen this to a *monotone family*: the elementary lower bound
`b(g) = 4π(1-g)` is strictly decreasing in `g`, and the gap between `b(g)` and the
true sharp bound `β(g)` (e.g. `β(1) = 2π²`) is strictly increasing. **The key
insight is** that the elementary Gauss–Bonnet method loses exactly `2π` of
detectable energy per unit genus, which can be stated and proved as a clean real
inequality `b(g+1) = b(g) - 4π`. **Why now?** This is a finite real-arithmetic
statement reachable by `linarith`/`nlinarith` on top of the existing genus
machinery in `DiscreteGaussBonnet.lean`, requiring no analysis at all.

## 4. The Li–Yau multiplicity bound via the set-integral method

`willmore_ge_fourPi_of_setGauss` already isolates the degree mechanism: a region
contributing `≥ 4π` of positive Gauss curvature forces `W ≥ 4π`. Generalize to
the Li–Yau inequality: a surface with a point of multiplicity `k` satisfies
`W ≥ 4πk`. **The key insight is** that `k` disjoint sheets each contribute an
independent `4π` of Gauss-map degree, so the single-set bound becomes a finite
sum over `k` disjoint measurable regions via additivity of the set integral.
**Why now?** `setIntegral_le_integral` and finite additivity of restricted
integrals are present in Mathlib, so the `k = 1` proof here extends to general
`k` by induction with no new analytic input.

## 5. The Marques–Neves bound `2π² ≤ W` for tori (the open target)

`willmore_torus_conjecture` records the genus-1 sharp bound as a `sorry`. A
tractable intermediate target is the *conformal/min-max width* reformulation:
define an abstract "width" functional on the abstract surface model and prove
that (i) the Willmore energy dominates the width and (ii) the width of any
genus-1 configuration is `≥ 2π²`. **The key insight is** that the full
Almgren–Pitts machinery can be *axiomatized* at the level of a width functional
satisfying a small list of monotonicity/normalization properties, reducing the
deep theorem to a finite combinatorial-analytic core that Lean can verify.
**Why now?** The abstract measure-space surface model in this file is exactly the
right setting to host such a width functional without committing to a smooth
manifold structure, so the reformulation can be prototyped immediately on top of
`willmoreEnergy`.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Geometry
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v14 Depth Requirements -- Synthetic Catalog Integration Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Synthetic Catalog Integration**. Focus on building a coherent body of work on top of our existing catalog.

### RESEARCH CORE METHODOLOGY:
1. **Lineage Synthesis**: Analyze the existing catalog context deeply. Do not reinvent definitions; import and build directly on top of the validated catalog results.
2. **Connect the Dots**: Search for "orphan" results or gaps in the catalog and construct bridges to connect them. Show how new theorems advance the overall mathematical architecture of the repository.
3. **Foundational Extension**: Take successful packages from the catalog and extend their results to broader algebraic settings, sharper bounds, or new domain applications.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
