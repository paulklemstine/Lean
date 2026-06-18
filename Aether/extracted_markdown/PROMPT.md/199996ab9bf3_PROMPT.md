
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

**Title**: Bridge IX (`InterleavingGeodesic.lean`) gave the persistence-stability arc its f
**Domain**: Geometry
**Mathematical framing**: # Future Directions — Boltzmann Bridge X: The Path Space of Filtrations

## Synthesis

Bridge IX (`InterleavingGeodesic.lean`) gave the persistence-stability arc its first
explicit *path of filtrations*: the convex-interpolation geodesic `lerp` and the
constant-speed identity `eInterleavingDist (lerp F G s) (lerp F G t) = ofReal |s−t| ·
eInterleavingDist F G`. Bridge X (`InterleavingPathSpace.lean`) turns that single
geodesic into a **path space** and exposes its homotopical and curvature structure.

Three structurally different facts now coexist over the same object `lerp`:

* an **algebraic** law — `lerp_lerp` shows the geodesics are closed under
  reparametrisation, a `lerp` of two `lerp`s being the `lerp` at the affine parameter
  `(1−t)·a + t·b`. This is the combinatorial skeleton of a fundamental groupoid: paths
  compose to paths, and reparametrisations stay inside the family.
* a **metric** law — `eInterleavingDist_lerp_betweenness` upgrades Bridge IX's midpoint
  bisection to the full geodesic-segment additivity `d(s,u)+d(u,t)=d(s,t)` for any
  `s ≤ u ≤ t`, and `exists_constantSpeed_geodesic` packages everything into the textbook
  statement *the space is geodesic*.
* an **analytic** law — `eInterleavingDist_convex` proves Busemann convexity
  `d(H, lerp F G t) ≤ ofReal(1−t)·d(H,F) + ofReal t·d(H,G)`, inherited from the
  sup-distance through Bridge VIII's isometry `eInterleavingDist_eq_weightSupEDist`.

The decisive insight of this cycle is that **geodesy is the sharp diagonal of
convexity**: the constant-speed equality of Bridge IX is exactly the convexity
inequality of Bridge X restricted to the endpoints' own geodesic, where the
non-maximising slack over the simplex supremum vanishes. Convexity holds for every
third point `H`; equality holds only when the maximising simplex is shared. That single
asymmetry organises everything below.

## Results summary

| Theorem | Statement | Role |
|---|---|---|
| `lerp_self` | `lerp F F t = F` | degenerate geodesic |
| `lerp_lerp` | `lerp (lerp F G a) (lerp F G b) t = lerp F G ((1−t)a+tb)` | reparametrisation closure |
| `eInterleavingDist_lerp_betweenness` | `d(s,u)+d(u,t)=d(s,t)` for `s ≤ u ≤ t` | geodesic-segment law |
| `eInterleavingDist_convex` | `d(H, lerp F G t) ≤ ofReal(1−t)·d(H,F)+ofReal t·d(H,G)` | Busemann convexity |
| `exists_constantSpeed_geodesic` | `∃ γ, γ 0 = F ∧ γ 1 = G ∧ d(γ s, γ t)=ofReal\|s−t\|·d(F,G)` | the space is geodesic |

All five compile with `sorry`-count 0 and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

---

## Direction 1 — The convexity defect and the failure of unique geodesy

**Conjecture.** Define the convexity defect
`δ(H,F,G,t) := ofReal(1−t)·d(H,F) + ofReal t·d(H,G) − d(H, lerp F G t)`. Then `δ ≥ 0`
always (this is `eInterleavingDist_convex`), but `δ` is *not* identically zero: there is
a concrete triple `F, G, H` of three-simplex filtrations and a `t ∈ (0,1)` with
`δ(H,F,G,t) > 0`, and moreover there exist two genuinely distinct constant-speed
geodesics between some `F` and `G` — so `(Filtration α, eInterleavingDist)` is geodesic
but **not uniquely geodesic**, hence not CAT(0), despite satisfying Busemann convexity.

**The key insight is** that the interleaving metric is an ℓ∞-type supremum, and ℓ∞
geometry is flat with square balls: between two points whose displacement is
concentrated on different coordinates, any monotone staircase is a geodesic. Concretely,
choose weights so the maximiser of `|H − lerp t|` migrates from one simplex to another as
`t` crosses ½ — then the straight-line convex bound is strictly slack, and a "bent"
path through a third filtration realises the same endpoint distance.

**Why now?** `eInterleavingDist_convex` has just pinned the inequality and isolated
exactly the slack term; the only remaining work is to *witness* the slack with a finite
example over `α = Fin 3`, which is a finite `#eval`-checkable search rather than an
analytic argument. The negative curvature question is reduced to a counterexample hunt.

---

## Direction 2 — Concatenation and a contractible fundamental groupoid

**Conjecture.** The reparametrisation law `lerp_lerp` extends to a full
*path-concatenation* operation `γ ⋆ γ'` on `lerp`-paths that is associative and
unital up to reparametrisation, and the resulting path space is **contractible**: every
loop based at `F` is `lerp`-homotopic to the constant loop `lerp_self F`. Consequently
the fundamental groupoid of `(Filtration α, eInterleavingDist)` is trivial (equivalent to
a point on each connected component), and `Filtration α` is an Eilenberg–MacLane space of
no positive homotopy.

**The key insight is** that geodesic convexity (`eInterleavingDist_convex`) forces
straight-line contractibility: the homotopy `(s, r) ↦ lerp F (γ r) s` contracts any path
`γ` to the constant `F`, and `lerp_lerp` guarantees this two-parameter family stays inside
the geodesic algebra so the contraction is internal, not merely topological.

**Why now?** Both ingredients are in hand — `lerp_lerp` gives the algebra of paths and
`lerp_self` gives the constant path — so the contraction can be *built as a Lean term*
(`fun s r => lerp F (γ r) ...`) rather than asserted abstractly. This is the natural first
genuinely 2-dimensional (homotopical) theorem of the arc.

---

## Direction 3 — Geodesics do not stay in the Vietoris–Rips locus

**Conjecture.** Let `diamFiltration` (from `HigherPersistence.lean`) be the
Vietoris–Rips diameter filtration of a finite metric space. Then the geodesic between two
diameter-filtrations generically *leaves* the diameter locus: there is a finite metric
configuration and a `t ∈ (0,1)` for which `lerp (diamFiltration X) (diamFiltration Y) t`
is **not** equal to `diamFiltration Z` for any metric `Z`. Equivalently, the set of
Vietoris–Rips filtrations is geodesically *non-convex* inside `(Filtration α,
eInterleavingDist)`.

**The key insight is** that diameter weights satisfy a triangle-type compatibility
constraint across simplices (the weight of a triangle is determined by its edges via a
max), whereas convex interpolation mixes weights simplex-by-simplex independently and
destroys that constraint — the interpolant is a valid monotone filtration but not a valid
*metric* filtration.

**Why now?** Bridge IX explicitly flagged this as its geometric-vs-combinatorial frontier
but lacked the path object to test it; Bridge X's `lerp` plus the existing
`diamFiltration` make the statement a direct computation on a 3- or 4-point space,
falsifiable by exhibiting a single simplex whose interpolated weight violates the
diameter max-rule.

---

## Direction 4 — Functorial transport of geodesics

**Conjecture.** The pullback functor of `InterleavingFunctor.lean`
(`F ↦ ⟨σ ↦ F.weight (σ.image f), …⟩` for `f : α → β`) sends geodesics to geodesics and is
**1-Lipschitz on paths**: `pullback f (lerp F G t) = lerp (pullback f F) (pullback f G) t`
and therefore `d(pullback f (lerp F G s), pullback f (lerp F G t)) ≤ ofReal|s−t| ·
d(pullback f F, pullback f G)`, with equality iff `f` does not collapse the maximising
simplex. Hence `pullback f` is a morphism of geodesic spaces, and the assignment
`α ↦ (Filtration α, lerp)` is a functor into the category of geodesic spaces.

**The key insight is** that `pullback` acts on weights by *precomposition* with
`σ ↦ σ.image f`, an operation that is **affine** in the weight, so it commutes
definitionally with the affine `lerp` — the geodesic structure is preserved for the same
algebraic reason `lerp_lerp` holds.

**Why now?** The pullback functor already exists and is proven 1-Lipschitz on points in
`InterleavingFunctor.lean`; combined with `lerp` from this cycle, the commutation
`pullback f (lerp F G t) = lerp (pullback f F) (pullback f G) t` is a one-line
`ext_weight`/`simp` away, immediately upgrading a point-level isometry statement to a
path-level (functorial) one and connecting the metric and homotopical chapters of the arc.

**Concept description**: # Future Directions — Boltzmann Bridge X: The Path Space of Filtrations

## Synthesis

Bridge IX (`InterleavingGeodesic.lean`) gave the persistence-stability arc its first
explicit *path of filtrations*: the convex-interpolation geodesic `lerp` and the
constant-speed identity `eInterleavingDist (lerp F G s) (lerp F G t) = ofReal |s−t| ·
eInterleavingDist F G`. Bridge X (`InterleavingPathSpace.lean`) turns that single
geodesic into a **path space** and exposes its homotopical and curvature structure.

Three structurally different facts now coexist over the same object `lerp`:

* an **algebraic** law — `lerp_lerp` shows the geodesics are closed under
  reparametrisation, a `lerp` of two `lerp`s being the `lerp` at the affine parameter
  `(1−t)·a + t·b`. This is the combinatorial skeleton of a fundamental groupoid: paths
  compose to paths, and reparametrisations stay inside the family.
* a **metric** law — `eInterleavingDist_lerp_betweenness` upgrades Bridge IX's midpoint
  bisection to the full geodesic-segment additivity `d(s,u)+d(u,t)=d(s,t)` for any
  `s ≤ u ≤ t`, and `exists_constantSpeed_geodesic` packages everything into the textbook
  statement *the space is geodesic*.
* an **analytic** law — `eInterleavingDist_convex` proves Busemann convexity
  `d(H, lerp F G t) ≤ ofReal(1−t)·d(H,F) + ofReal t·d(H,G)`, inherited from the
  sup-distance through Bridge VIII's isometry `eInterleavingDist_eq_weightSupEDist`.

The decisive insight of this cycle is that **geodesy is the sharp diagonal of
convexity**: the constant-speed equality of Bridge IX is exactly the convexity
inequality of Bridge X restricted to the endpoints' own geodesic, where the
non-maximising slack over the simplex supremum vanishes. Convexity holds for every
third point `H`; equality holds only when the maximising simplex is shared. That single
asymmetry organises everything below.

## Results summary

| Theorem | Statement | Role |
|---|---|---|
| `lerp_self` | `lerp F F t = F` | degenerate geodesic |
| `lerp_lerp` | `lerp (lerp F G a) (lerp F G b) t = lerp F G ((1−t)a+tb)` | reparametrisation closure |
| `eInterleavingDist_lerp_betweenness` | `d(s,u)+d(u,t)=d(s,t)` for `s ≤ u ≤ t` | geodesic-segment law |
| `eInterleavingDist_convex` | `d(H, lerp F G t) ≤ ofReal(1−t)·d(H,F)+ofReal t·d(H,G)` | Busemann convexity |
| `exists_constantSpeed_geodesic` | `∃ γ, γ 0 = F ∧ γ 1 = G ∧ d(γ s, γ t)=ofReal\|s−t\|·d(F,G)` | the space is geodesic |

All five compile with `sorry`-count 0 and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

---

## Direction 1 — The convexity defect and the failure of unique geodesy

**Conjecture.** Define the convexity defect
`δ(H,F,G,t) := ofReal(1−t)·d(H,F) + ofReal t·d(H,G) − d(H, lerp F G t)`. Then `δ ≥ 0`
always (this is `eInterleavingDist_convex`), but `δ` is *not* identically zero: there is
a concrete triple `F, G, H` of three-simplex filtrations and a `t ∈ (0,1)` with
`δ(H,F,G,t) > 0`, and moreover there exist two genuinely distinct constant-speed
geodesics between some `F` and `G` — so `(Filtration α, eInterleavingDist)` is geodesic
but **not uniquely geodesic**, hence not CAT(0), despite satisfying Busemann convexity.

**The key insight is** that the interleaving metric is an ℓ∞-type supremum, and ℓ∞
geometry is flat with square balls: between two points whose displacement is
concentrated on different coordinates, any monotone staircase is a geodesic. Concretely,
choose weights so the maximiser of `|H − lerp t|` migrates from one simplex to another as
`t` crosses ½ — then the straight-line convex bound is strictly slack, and a "bent"
path through a third filtration realises the same endpoint distance.

**Why now?** `eInterleavingDist_convex` has just pinned the inequality and isolated
exactly the slack term; the only remaining work is to *witness* the slack with a finite
example over `α = Fin 3`, which is a finite `#eval`-checkable search rather than an
analytic argument. The negative curvature question is reduced to a counterexample hunt.

---

## Direction 2 — Concatenation and a contractible fundamental groupoid

**Conjecture.** The reparametrisation law `lerp_lerp` extends to a full
*path-concatenation* operation `γ ⋆ γ'` on `lerp`-paths that is associative and
unital up to reparametrisation, and the resulting path space is **contractible**: every
loop based at `F` is `lerp`-homotopic to the constant loop `lerp_self F`. Consequently
the fundamental groupoid of `(Filtration α, eInterleavingDist)` is trivial (equivalent to
a point on each connected component), and `Filtration α` is an Eilenberg–MacLane space of
no positive homotopy.

**The key insight is** that geodesic convexity (`eInterleavingDist_convex`) forces
straight-line contractibility: the homotopy `(s, r) ↦ lerp F (γ r) s` contracts any path
`γ` to the constant `F`, and `lerp_lerp` guarantees this two-parameter family stays inside
the geodesic algebra so the contraction is internal, not merely topological.

**Why now?** Both ingredients are in hand — `lerp_lerp` gives the algebra of paths and
`lerp_self` gives the constant path — so the contraction can be *built as a Lean term*
(`fun s r => lerp F (γ r) ...`) rather than asserted abstractly. This is the natural first
genuinely 2-dimensional (homotopical) theorem of the arc.

---

## Direction 3 — Geodesics do not stay in the Vietoris–Rips locus

**Conjecture.** Let `diamFiltration` (from `HigherPersistence.lean`) be the
Vietoris–Rips diameter filtration of a finite metric space. Then the geodesic between two
diameter-filtrations generically *leaves* the diameter locus: there is a finite metric
configuration and a `t ∈ (0,1)` for which `lerp (diamFiltration X) (diamFiltration Y) t`
is **not** equal to `diamFiltration Z` for any metric `Z`. Equivalently, the set of
Vietoris–Rips filtrations is geodesically *non-convex* inside `(Filtration α,
eInterleavingDist)`.

**The key insight is** that diameter weights satisfy a triangle-type compatibility
constraint across simplices (the weight of a triangle is determined by its edges via a
max), whereas convex interpolation mixes weights simplex-by-simplex independently and
destroys that constraint — the interpolant is a valid monotone filtration but not a valid
*metric* filtration.

**Why now?** Bridge IX explicitly flagged this as its geometric-vs-combinatorial frontier
but lacked the path object to test it; Bridge X's `lerp` plus the existing
`diamFiltration` make the statement a direct computation on a 3- or 4-point space,
falsifiable by exhibiting a single simplex whose interpolated weight violates the
diameter max-rule.

---

## Direction 4 — Functorial transport of geodesics

**Conjecture.** The pullback functor of `InterleavingFunctor.lean`
(`F ↦ ⟨σ ↦ F.weight (σ.image f), …⟩` for `f : α → β`) sends geodesics to geodesics and is
**1-Lipschitz on paths**: `pullback f (lerp F G t) = lerp (pullback f F) (pullback f G) t`
and therefore `d(pullback f (lerp F G s), pullback f (lerp F G t)) ≤ ofReal|s−t| ·
d(pullback f F, pullback f G)`, with equality iff `f` does not collapse the maximising
simplex. Hence `pullback f` is a morphism of geodesic spaces, and the assignment
`α ↦ (Filtration α, lerp)` is a functor into the category of geodesic spaces.

**The key insight is** that `pullback` acts on weights by *precomposition* with
`σ ↦ σ.image f`, an operation that is **affine** in the weight, so it commutes
definitionally with the affine `lerp` — the geodesic structure is preserved for the same
algebraic reason `lerp_lerp` holds.

**Why now?** The pullback functor already exists and is proven 1-Lipschitz on points in
`InterleavingFunctor.lean`; combined with `lerp` from this cycle, the commutation
`pullback f (lerp F G t) = lerp (pullback f F) (pullback f G) t` is a one-line
`ext_weight`/`simp` away, immediately upgrading a point-level isometry statement to a
path-level (functorial) one and connecting the metric and homotopical chapters of the arc.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Geometry
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v11 Depth Requirements -- Algorithmic & Constructive Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Algorithmic & Constructive Generation**. Prioritize concrete computation, explicit witness constructions, and algorithmic content.

### RESEARCH CORE METHODOLOGY:
1. **Constructive Witness Extraction**: Whenever asserting that an object exists, focus on constructing it explicitly. Avoid non-constructive classical axioms (like double negation elimination or classical choice) unless absolutely necessary.
2. **Computational Verification**: Build definitions that can be computationally evaluated (`#eval` or `decide`). Connect abstract algebra/topology directly to effective algorithms and discrete models.
3. **Algorithmic Complexity**: Focus on the computational power and structures of your mathematical objects, proving properties about their stability, convergence, or decidability.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
