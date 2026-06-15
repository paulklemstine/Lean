
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

**Title**: Bridge XI (`InterleavingPathFunctor.lean`) discharged the two purely *constructi
**Domain**: Applications
**Mathematical framing**: # Future Directions — Boltzmann Bridge XI: Functorial Transport and the Contractible Path Space

## Synthesis

Bridge XI (`InterleavingPathFunctor.lean`) discharged the two purely *constructive*
Future Directions left open by Bridge X. It turned the static path space of
filtrations into a **functorial and contractible** object, resting on a single
structural observation: both the pullback `pullback f` and the geodesic interpolation
`lerp` are *affine in the weight*, so they commute on the nose.

Three facts now interlock over the geodesic `lerp`:

* a **functorial** law — `pullback_lerp` shows `pullback f (lerp F G t) =
  lerp (pullback f F) (pullback f G) t`, so the contravariant persistence functor
  carries the `F`–`G` geodesic onto the geodesic of the pulled-back endpoints. This
  upgrades Bridge IX''s point-level `1`-Lipschitz statement (`pullback_lipschitzWith_one`)
  to the path-level isometry `eInterleavingDist_pullback_lerp` and its contraction
  bound `eInterleavingDist_pullback_lerp_le`. The assignment `α ↦ (Filtration α, lerp)`
  is thus a functor into geodesic spaces.
* a **homotopical** law — `lerp_straightLine_contraction` builds the explicit
  straight-line homotopy `H s r = lerp F (γ r) s` contracting any path `γ` to its
  basepoint `F` at constant `s`-speed, witnessing that the path space is contractible.
* a **diagonal** law — `eInterleavingDist_convex_sharp` records that Bridge X's
  Busemann convexity inequality becomes an *equality* at `H = F`, identifying the
  Bridge IX geodesic identity as the sharp diagonal of convexity.

The decisive insight of this cycle is that **transport and contraction are the same
algebraic fact wearing two hats**: "affine commutes with affine" is what makes
`pullback` commute with `lerp` (functoriality) and equally what keeps the contracting
two-parameter family `lerp F (γ r) s` inside the geodesic algebra (contractibility).
No metric reasoning enters the structural layer; the metric content is inherited
verbatim through the Bridge VIII isometry and the Bridge IX geodesic identity.

## Results summary

| Theorem | Statement | Role |
|---|---|---|
| `pullback_lerp` | `pullback f (lerp F G t) = lerp (pullback f F) (pullback f G) t` | geodesic transport (algebraic) |
| `eInterleavingDist_pullback_lerp` | `d(pb (lerp s), pb (lerp t)) = ofReal\|s−t\|·d(pb F, pb G)` | path-level isometry |
| `eInterleavingDist_pullback_lerp_le` | `… ≤ ofReal\|s−t\|·d(F,G)` | pullback is short on paths |
| `lerp_straightLine_contraction` | `∃ H, H 0 = F ∧ H 1 = γ ∧ constant-speed` | contractible path space |
| `eInterleavingDist_convex_sharp` | `d(F, lerp F G t) = ofReal(1−t)·d(F,F)+ofReal t·d(F,G)` | sharp diagonal of convexity |

All five compile with `sorry`-count 0 and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

---

## Direction 1 — The strict convexity defect and genuinely non-unique geodesics

**Conjecture.** The Busemann defect
`δ(H,F,G,t) := ofReal(1−t)·d(H,F) + ofReal t·d(H,G) − d(H, lerp F G t)` is `≥ 0`
everywhere (Bridge X's `eInterleavingDist_convex`) and equals `0` at `H = F`
(Bridge XI's `eInterleavingDist_convex_sharp`), but is *not* identically zero: over
`α = Fin 2` there is an explicit triple `F, G, H` of `ofWeight`-filtrations and a
`t ∈ (0,1)` with `δ(H,F,G,t) > 0`. Consequently `(Filtration α, eInterleavingDist)`
admits two genuinely distinct constant-speed geodesics between some pair, so it is
geodesic but **not uniquely geodesic**, hence not CAT(0), despite Busemann convexity.

**The key insight is** that the interleaving metric is, by Bridge VIII's
`eInterleavingDist_eq_weightSupEDist`, an ℓ∞-type supremum over simplices, and ℓ∞
balls are cubes: when the simplex maximising `|H − lerp t|` *migrates* from one
coordinate to another as `t` crosses a threshold, the straight convex bound is
strictly slack and a bent path realises the same endpoint distance.

**Why now?** Bridge VIII already reduces every distance to a finite `⨆` over
`Finset (Fin 2)` (four simplices), and `ofWeight` builds filtrations from explicit
weight tables. The defect is therefore a finite `#eval`-checkable sup computation, not
an analytic argument — the entire CAT(0) question collapses to exhibiting one weight
table where the argmax of the gap moves with `t`.

---

## Direction 2 — Naturality of the contraction: pullback transports homotopies

**Conjecture.** The straight-line contraction of `lerp_straightLine_contraction` is
*natural* in the vertex type: for `f : α → β`, pulling back the contraction of a path
`γ` based at `F` is the contraction of the pulled-back path `pullback f ∘ γ` based at
`pullback f F`, i.e. `pullback f (H s r) = H' s r` where `H'` is the contraction
produced from `pullback f F` and `pullback f ∘ γ`. Hence `pullback f` is not merely a
morphism of geodesic spaces but a morphism of **contractions**, and the assignment
`α ↦ (path space of Filtration α)` is a functor into contractible spaces with
basepoint-preserving, contraction-preserving maps.

**The key insight is** that `pullback_lerp` already commutes `pullback` past a single
`lerp`, and the contraction homotopy `H s r = lerp F (γ r) s` is built entirely from
`lerp`s; so `pullback` commutes past the *whole two-parameter family* for the same
"affine commutes with affine" reason, with no new metric input.

**Why now?** `pullback_lerp` is the exact one-step commutation lemma, and
`lerp_straightLine_contraction` packages the homotopy explicitly as a term in `lerp`;
the naturality square is therefore a direct `ext_weight`/`simp` rewrite of the
homotopy term, immediately promoting Bridge XI's two separate functorial and
homotopical chapters into a single functor-of-contractible-spaces statement.

---

## Direction 3 — Geodesics leave the Vietoris–Rips locus

**Conjecture.** Let `diamFiltration` (from `HigherPersistence.lean`) be the
Vietoris–Rips diameter filtration of a finite metric space. The geodesic between two
diameter-filtrations generically *leaves* the diameter locus: there is a finite metric
configuration (a 3- or 4-point space) and a `t ∈ (0,1)` for which
`(lerp (diamFiltration X) (diamFiltration Y) t).weight` violates the diameter
max-rule `weight(triangle) = max over its edges`, so no metric `Z` has
`diamFiltration Z = lerp (diamFiltration X) (diamFiltration Y) t`. The VR locus is
geodesically *non-convex* inside `(Filtration α, eInterleavingDist)`.

**The key insight is** that diameter weights obey a cross-simplex compatibility
constraint — a triangle's weight is the max of its three edge weights — whereas
`lerp` mixes the weight of each simplex *independently* and affinely; an affine blend
of two maxima is generally not the max of the blended edges, so the interpolant stays
a valid monotone filtration but ceases to be a valid *metric* filtration.

**Why now?** Bridge IX flagged this frontier but had no path object; Bridge X gave
`lerp` and Bridge XI confirmed `lerp` is transported and contracted functorially.
With `diamWeight` already a concrete `sup'` over pairwise distances, the violation is
a single arithmetic inequality on one triangle of a 3-point space — falsifiable by one
`#eval`.

---

## Direction 4 — The equality locus of functorial transport

**Conjecture.** The path-level contraction `eInterleavingDist_pullback_lerp_le` is
*sharp exactly when `f` is surjective*: for surjective `f`, the transported geodesic
speed equals the upstream speed, `d(pb (lerp s), pb (lerp t)) = ofReal|s−t|·d(F,G)`
for all `s,t ∈ [0,1]`; and for any non-surjective `f` whose missed simplices carry a
strictly larger weight gap, the inequality is strict at every `s ≠ t`. Thus
`pullback f` is a *path-isometry* iff it is a metric isometry iff `f` is surjective —
a clean trichotomy fusing Bridge IX''s corrected Direction 3 with Bridge XI's path
layer.

**The key insight is** that `eInterleavingDist_pullback_lerp` already factors the
transported speed as `ofReal|s−t|` times `d(pb F, pb G)`, and Bridge IX''s
`eInterleavingDist_pullback_eq_of_surjective` pins exactly when `d(pb F, pb G) =
d(F,G)`; the path equality is therefore the scalar `ofReal|s−t|` multiplied through
the *endpoint* equality, so the geodesic-speed equality locus *is* the endpoint
isometry locus.

**Why now?** Both halves exist: `eInterleavingDist_pullback_lerp` gives the speed
factorisation and `eInterleavingDist_pullback_eq_of_surjective` gives the endpoint
characterisation. Multiplying one by `ofReal|s−t|` is a one-line `congr`/`rw`, turning
two endpoint-level facts into a complete path-level isometry classification — the
natural capstone of the functorial-transport chapter.

**Concept description**: # Future Directions — Boltzmann Bridge XI: Functorial Transport and the Contractible Path Space

## Synthesis

Bridge XI (`InterleavingPathFunctor.lean`) discharged the two purely *constructive*
Future Directions left open by Bridge X. It turned the static path space of
filtrations into a **functorial and contractible** object, resting on a single
structural observation: both the pullback `pullback f` and the geodesic interpolation
`lerp` are *affine in the weight*, so they commute on the nose.

Three facts now interlock over the geodesic `lerp`:

* a **functorial** law — `pullback_lerp` shows `pullback f (lerp F G t) =
  lerp (pullback f F) (pullback f G) t`, so the contravariant persistence functor
  carries the `F`–`G` geodesic onto the geodesic of the pulled-back endpoints. This
  upgrades Bridge IX''s point-level `1`-Lipschitz statement (`pullback_lipschitzWith_one`)
  to the path-level isometry `eInterleavingDist_pullback_lerp` and its contraction
  bound `eInterleavingDist_pullback_lerp_le`. The assignment `α ↦ (Filtration α, lerp)`
  is thus a functor into geodesic spaces.
* a **homotopical** law — `lerp_straightLine_contraction` builds the explicit
  straight-line homotopy `H s r = lerp F (γ r) s` contracting any path `γ` to its
  basepoint `F` at constant `s`-speed, witnessing that the path space is contractible.
* a **diagonal** law — `eInterleavingDist_convex_sharp` records that Bridge X's
  Busemann convexity inequality becomes an *equality* at `H = F`, identifying the
  Bridge IX geodesic identity as the sharp diagonal of convexity.

The decisive insight of this cycle is that **transport and contraction are the same
algebraic fact wearing two hats**: "affine commutes with affine" is what makes
`pullback` commute with `lerp` (functoriality) and equally what keeps the contracting
two-parameter family `lerp F (γ r) s` inside the geodesic algebra (contractibility).
No metric reasoning enters the structural layer; the metric content is inherited
verbatim through the Bridge VIII isometry and the Bridge IX geodesic identity.

## Results summary

| Theorem | Statement | Role |
|---|---|---|
| `pullback_lerp` | `pullback f (lerp F G t) = lerp (pullback f F) (pullback f G) t` | geodesic transport (algebraic) |
| `eInterleavingDist_pullback_lerp` | `d(pb (lerp s), pb (lerp t)) = ofReal\|s−t\|·d(pb F, pb G)` | path-level isometry |
| `eInterleavingDist_pullback_lerp_le` | `… ≤ ofReal\|s−t\|·d(F,G)` | pullback is short on paths |
| `lerp_straightLine_contraction` | `∃ H, H 0 = F ∧ H 1 = γ ∧ constant-speed` | contractible path space |
| `eInterleavingDist_convex_sharp` | `d(F, lerp F G t) = ofReal(1−t)·d(F,F)+ofReal t·d(F,G)` | sharp diagonal of convexity |

All five compile with `sorry`-count 0 and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

---

## Direction 1 — The strict convexity defect and genuinely non-unique geodesics

**Conjecture.** The Busemann defect
`δ(H,F,G,t) := ofReal(1−t)·d(H,F) + ofReal t·d(H,G) − d(H, lerp F G t)` is `≥ 0`
everywhere (Bridge X's `eInterleavingDist_convex`) and equals `0` at `H = F`
(Bridge XI's `eInterleavingDist_convex_sharp`), but is *not* identically zero: over
`α = Fin 2` there is an explicit triple `F, G, H` of `ofWeight`-filtrations and a
`t ∈ (0,1)` with `δ(H,F,G,t) > 0`. Consequently `(Filtration α, eInterleavingDist)`
admits two genuinely distinct constant-speed geodesics between some pair, so it is
geodesic but **not uniquely geodesic**, hence not CAT(0), despite Busemann convexity.

**The key insight is** that the interleaving metric is, by Bridge VIII's
`eInterleavingDist_eq_weightSupEDist`, an ℓ∞-type supremum over simplices, and ℓ∞
balls are cubes: when the simplex maximising `|H − lerp t|` *migrates* from one
coordinate to another as `t` crosses a threshold, the straight convex bound is
strictly slack and a bent path realises the same endpoint distance.

**Why now?** Bridge VIII already reduces every distance to a finite `⨆` over
`Finset (Fin 2)` (four simplices), and `ofWeight` builds filtrations from explicit
weight tables. The defect is therefore a finite `#eval`-checkable sup computation, not
an analytic argument — the entire CAT(0) question collapses to exhibiting one weight
table where the argmax of the gap moves with `t`.

---

## Direction 2 — Naturality of the contraction: pullback transports homotopies

**Conjecture.** The straight-line contraction of `lerp_straightLine_contraction` is
*natural* in the vertex type: for `f : α → β`, pulling back the contraction of a path
`γ` based at `F` is the contraction of the pulled-back path `pullback f ∘ γ` based at
`pullback f F`, i.e. `pullback f (H s r) = H' s r` where `H'` is the contraction
produced from `pullback f F` and `pullback f ∘ γ`. Hence `pullback f` is not merely a
morphism of geodesic spaces but a morphism of **contractions**, and the assignment
`α ↦ (path space of Filtration α)` is a functor into contractible spaces with
basepoint-preserving, contraction-preserving maps.

**The key insight is** that `pullback_lerp` already commutes `pullback` past a single
`lerp`, and the contraction homotopy `H s r = lerp F (γ r) s` is built entirely from
`lerp`s; so `pullback` commutes past the *whole two-parameter family* for the same
"affine commutes with affine" reason, with no new metric input.

**Why now?** `pullback_lerp` is the exact one-step commutation lemma, and
`lerp_straightLine_contraction` packages the homotopy explicitly as a term in `lerp`;
the naturality square is therefore a direct `ext_weight`/`simp` rewrite of the
homotopy term, immediately promoting Bridge XI's two separate functorial and
homotopical chapters into a single functor-of-contractible-spaces statement.

---

## Direction 3 — Geodesics leave the Vietoris–Rips locus

**Conjecture.** Let `diamFiltration` (from `HigherPersistence.lean`) be the
Vietoris–Rips diameter filtration of a finite metric space. The geodesic between two
diameter-filtrations generically *leaves* the diameter locus: there is a finite metric
configuration (a 3- or 4-point space) and a `t ∈ (0,1)` for which
`(lerp (diamFiltration X) (diamFiltration Y) t).weight` violates the diameter
max-rule `weight(triangle) = max over its edges`, so no metric `Z` has
`diamFiltration Z = lerp (diamFiltration X) (diamFiltration Y) t`. The VR locus is
geodesically *non-convex* inside `(Filtration α, eInterleavingDist)`.

**The key insight is** that diameter weights obey a cross-simplex compatibility
constraint — a triangle's weight is the max of its three edge weights — whereas
`lerp` mixes the weight of each simplex *independently* and affinely; an affine blend
of two maxima is generally not the max of the blended edges, so the interpolant stays
a valid monotone filtration but ceases to be a valid *metric* filtration.

**Why now?** Bridge IX flagged this frontier but had no path object; Bridge X gave
`lerp` and Bridge XI confirmed `lerp` is transported and contracted functorially.
With `diamWeight` already a concrete `sup'` over pairwise distances, the violation is
a single arithmetic inequality on one triangle of a 3-point space — falsifiable by one
`#eval`.

---

## Direction 4 — The equality locus of functorial transport

**Conjecture.** The path-level contraction `eInterleavingDist_pullback_lerp_le` is
*sharp exactly when `f` is surjective*: for surjective `f`, the transported geodesic
speed equals the upstream speed, `d(pb (lerp s), pb (lerp t)) = ofReal|s−t|·d(F,G)`
for all `s,t ∈ [0,1]`; and for any non-surjective `f` whose missed simplices carry a
strictly larger weight gap, the inequality is strict at every `s ≠ t`. Thus
`pullback f` is a *path-isometry* iff it is a metric isometry iff `f` is surjective —
a clean trichotomy fusing Bridge IX''s corrected Direction 3 with Bridge XI's path
layer.

**The key insight is** that `eInterleavingDist_pullback_lerp` already factors the
transported speed as `ofReal|s−t|` times `d(pb F, pb G)`, and Bridge IX''s
`eInterleavingDist_pullback_eq_of_surjective` pins exactly when `d(pb F, pb G) =
d(F,G)`; the path equality is therefore the scalar `ofReal|s−t|` multiplied through
the *endpoint* equality, so the geodesic-speed equality locus *is* the endpoint
isometry locus.

**Why now?** Both halves exist: `eInterleavingDist_pullback_lerp` gives the speed
factorisation and `eInterleavingDist_pullback_eq_of_surjective` gives the endpoint
characterisation. Multiplying one by `ofReal|s−t|` is a one-line `congr`/`rw`, turning
two endpoint-level facts into a complete path-level isometry classification — the
natural capstone of the functorial-transport chapter.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v14 Depth Requirements -- Conceptual Unifier: Local-to-Global Sheaves Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Local-to-Global Sheaves)**. Explore sheaf theory, local-to-global translations, and cohomological obstructions.

### RESEARCH CORE METHODOLOGY:
1. **Local-to-Global Translation**: Construct sheaves or presheaves to describe local properties that glue together to form global structures. Check if local solutions can be extended globally.
2. **Obstruction Theory & Cohomology**: Use cohomology groups or obstruction classes to mathematically measure the failure or boundaries of local-to-global extensions.
3. **Stalk-Level Reduction**: Reduce complex global proofs to stalk-level computations or local neighborhood verifications, using algebraic localization or geometric limits.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
