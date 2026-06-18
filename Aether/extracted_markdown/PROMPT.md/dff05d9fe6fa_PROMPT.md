
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

**Title**: The current formalization establishes the structural machinery (definitions of S
**Domain**: Novelty
**Mathematical framing**: # Future Directions: The Geometry of Consensus

## 1. Full Arrow's Impossibility via Decisive Ultrafilters

The current formalization establishes the structural machinery (definitions of SWF, Pareto, IIA, decisive coalitions, and the ultrafilter-on-finite-types theorem) but does not yet close the full loop: proving that decisive coalitions under Pareto + IIA form an ultrafilter. The key insight is that the "field expansion lemma" — showing decisiveness for one pair implies decisiveness for all pairs — requires constructing specific preference profiles that witness the transfer, and this construction is the technically hardest part.

**Testable conjecture**: The decisive coalitions of any SWF satisfying Pareto + IIA on ≥3 alternatives form a filter that is also an ultrafilter (i.e., for every coalition S, either S or Sᶜ is in the family). This can be tested by attempting to formalize the field expansion lemma for the 3-alternative case first, where only 6 preference orderings exist per voter.

**Why now?** Our definitions compile cleanly and the ultrafilter-is-principal theorem is already in Mathlib. The only missing piece is the algebraic characterization of decisive families, which requires careful but finite case analysis on triples of alternatives.

## 2. Quantitative Arrow: Curvature Bounds on Near-Dictatorships

Our Hellinger distance and Bhattacharyya coefficient results give a metric structure on the space of probability distributions. A natural quantitative extension of Arrow's theorem would bound how "close to dictatorial" a SWF must be, measured in terms of the curvature of the underlying preference space.

**Testable conjecture**: For any ε-approximately IIA social welfare function F (meaning |BC(F(P), F(Q))| ≤ ε whenever P and Q agree on a pair), there exists a voter v such that the Hellinger distance between F(P) and the dictatorial output Pᵥ is at most C·ε for some universal constant C depending only on the number of alternatives. The key insight is that our `bhattacharyya_cauchy_schwarz` and `hellinger_pos_of_ne` results already give the rigidity needed — strict positivity of Hellinger distance means approximate IIA forces approximate projection.

**Why now?** The Friedgut-Kalai-Naor quantitative Arrow theorem (2002) proves exactly this in the Boolean case. Our Fisher-Rao framework should give a cleaner proof via spherical geometry, and the necessary inequalities are already formalized.

## 3. Single-Peaked Preferences and Zero Curvature

Our `polarization_consensus` theorem shows that when all voters agree, the polarization index (average Hellinger distance) is zero. The geometric conjecture is stronger: when preferences are "single-peaked" (unimodal on a common axis), the effective curvature of the restricted preference space drops to zero, and majority rule satisfies all Arrow conditions on this restricted domain.

**Testable conjecture**: Define single-peakedness as the condition that all voter utility vectors lie in a geodesic arc (1-dimensional submanifold) of the probability simplex. On such a submanifold, the induced curvature is zero, and the Bhattacharyya coefficient satisfies BC(midpoint(p,q), r) = (BC(p,r) + BC(q,r))/2 exactly (no contraction). The key insight is that geodesics on the sphere are great circles, and a great circle has zero intrinsic curvature, so the contraction inequality becomes an equality.

**Why now?** Black's single-peakedness theorem (1948) is the classical positive result complementing Arrow's impossibility. Our framework gives a geometric explanation: single-peaked preferences live on a flat submanifold where the curvature obstruction vanishes.

## 4. Gibbard-Satterthwaite via Spherical Fixed Points

The Gibbard-Satterthwaite theorem states that any strategy-proof voting rule on ≥3 alternatives is dictatorial. The standard proof uses Arrow's theorem as a lemma. Our geometric framework suggests a more direct route: strategy-proofness corresponds to the aggregation map being a retraction (continuous map with F∘F = F), and the Brouwer fixed-point theorem on the sphere constrains such retractions.

**Testable conjecture**: Any continuous retraction F: (S^{n-1})^m → S^{n-1} satisfying unanimity (F(x,...,x) = x) and locality (F depends on each coordinate only through its angular position) is a projection onto one coordinate. The key insight is that retractions of the sphere onto itself must be the identity or a constant on each connected component, and locality plus unanimity forces projection.

**Why now?** The Borsuk-Ulam theorem and spherical topology are well-developed in Mathlib. Connecting them to social choice would be a genuine cross-domain bridge theorem.

## 5. Information-Geometric Characterization of Voting Rules

Beyond Arrow's impossibility, different voting rules (Borda count, Condorcet, approval voting, etc.) correspond to different maps on the Fisher-Rao manifold with different geometric properties. The polarization index gives a scalar summary of voter disagreement; different voting rules optimize different functions of this index.

**Testable conjecture**: The Borda count corresponds to the center of mass (Fréchet mean) on the probability simplex, while Condorcet methods correspond to the metric median. The Fréchet mean minimizes Σ H²(F, pᵢ) (total Hellinger distance) while the median minimizes Σ H(F, pᵢ) (total Hellinger distance without squaring). The key insight is that our `hellinger_eq_half_sq_dist` result shows H² = ½‖√p - √q‖², so minimizing total H² is equivalent to finding the Euclidean mean of the sqrt-embedded distributions, projected back to the sphere.

**Why now?** The Fréchet mean on Riemannian manifolds is computable and well-studied. Our sqrt-embedding reduces it to a standard linear algebra problem, making the characterization of voting rules as optimization problems on the sphere both precise and computable.

**Concept description**: # Future Directions: The Geometry of Consensus

## 1. Full Arrow's Impossibility via Decisive Ultrafilters

The current formalization establishes the structural machinery (definitions of SWF, Pareto, IIA, decisive coalitions, and the ultrafilter-on-finite-types theorem) but does not yet close the full loop: proving that decisive coalitions under Pareto + IIA form an ultrafilter. The key insight is that the "field expansion lemma" — showing decisiveness for one pair implies decisiveness for all pairs — requires constructing specific preference profiles that witness the transfer, and this construction is the technically hardest part.

**Testable conjecture**: The decisive coalitions of any SWF satisfying Pareto + IIA on ≥3 alternatives form a filter that is also an ultrafilter (i.e., for every coalition S, either S or Sᶜ is in the family). This can be tested by attempting to formalize the field expansion lemma for the 3-alternative case first, where only 6 preference orderings exist per voter.

**Why now?** Our definitions compile cleanly and the ultrafilter-is-principal theorem is already in Mathlib. The only missing piece is the algebraic characterization of decisive families, which requires careful but finite case analysis on triples of alternatives.

## 2. Quantitative Arrow: Curvature Bounds on Near-Dictatorships

Our Hellinger distance and Bhattacharyya coefficient results give a metric structure on the space of probability distributions. A natural quantitative extension of Arrow's theorem would bound how "close to dictatorial" a SWF must be, measured in terms of the curvature of the underlying preference space.

**Testable conjecture**: For any ε-approximately IIA social welfare function F (meaning |BC(F(P), F(Q))| ≤ ε whenever P and Q agree on a pair), there exists a voter v such that the Hellinger distance between F(P) and the dictatorial output Pᵥ is at most C·ε for some universal constant C depending only on the number of alternatives. The key insight is that our `bhattacharyya_cauchy_schwarz` and `hellinger_pos_of_ne` results already give the rigidity needed — strict positivity of Hellinger distance means approximate IIA forces approximate projection.

**Why now?** The Friedgut-Kalai-Naor quantitative Arrow theorem (2002) proves exactly this in the Boolean case. Our Fisher-Rao framework should give a cleaner proof via spherical geometry, and the necessary inequalities are already formalized.

## 3. Single-Peaked Preferences and Zero Curvature

Our `polarization_consensus` theorem shows that when all voters agree, the polarization index (average Hellinger distance) is zero. The geometric conjecture is stronger: when preferences are "single-peaked" (unimodal on a common axis), the effective curvature of the restricted preference space drops to zero, and majority rule satisfies all Arrow conditions on this restricted domain.

**Testable conjecture**: Define single-peakedness as the condition that all voter utility vectors lie in a geodesic arc (1-dimensional submanifold) of the probability simplex. On such a submanifold, the induced curvature is zero, and the Bhattacharyya coefficient satisfies BC(midpoint(p,q), r) = (BC(p,r) + BC(q,r))/2 exactly (no contraction). The key insight is that geodesics on the sphere are great circles, and a great circle has zero intrinsic curvature, so the contraction inequality becomes an equality.

**Why now?** Black's single-peakedness theorem (1948) is the classical positive result complementing Arrow's impossibility. Our framework gives a geometric explanation: single-peaked preferences live on a flat submanifold where the curvature obstruction vanishes.

## 4. Gibbard-Satterthwaite via Spherical Fixed Points

The Gibbard-Satterthwaite theorem states that any strategy-proof voting rule on ≥3 alternatives is dictatorial. The standard proof uses Arrow's theorem as a lemma. Our geometric framework suggests a more direct route: strategy-proofness corresponds to the aggregation map being a retraction (continuous map with F∘F = F), and the Brouwer fixed-point theorem on the sphere constrains such retractions.

**Testable conjecture**: Any continuous retraction F: (S^{n-1})^m → S^{n-1} satisfying unanimity (F(x,...,x) = x) and locality (F depends on each coordinate only through its angular position) is a projection onto one coordinate. The key insight is that retractions of the sphere onto itself must be the identity or a constant on each connected component, and locality plus unanimity forces projection.

**Why now?** The Borsuk-Ulam theorem and spherical topology are well-developed in Mathlib. Connecting them to social choice would be a genuine cross-domain bridge theorem.

## 5. Information-Geometric Characterization of Voting Rules

Beyond Arrow's impossibility, different voting rules (Borda count, Condorcet, approval voting, etc.) correspond to different maps on the Fisher-Rao manifold with different geometric properties. The polarization index gives a scalar summary of voter disagreement; different voting rules optimize different functions of this index.

**Testable conjecture**: The Borda count corresponds to the center of mass (Fréchet mean) on the probability simplex, while Condorcet methods correspond to the metric median. The Fréchet mean minimizes Σ H²(F, pᵢ) (total Hellinger distance) while the median minimizes Σ H(F, pᵢ) (total Hellinger distance without squaring). The key insight is that our `hellinger_eq_half_sq_dist` result shows H² = ½‖√p - √q‖², so minimizing total H² is equivalent to finding the Euclidean mean of the sqrt-embedded distributions, projected back to the sphere.

**Why now?** The Fréchet mean on Riemannian manifolds is computable and well-studied. Our sqrt-embedding reduces it to a standard linear algebra problem, making the characterization of voting rules as optimization problems on the sphere both precise and computable.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v10 Depth Requirements -- Conceptual Unifier Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Grothendieck style)**. Search for deep, hidden structures, universal patterns, and bridges across domains.

### RESEARCH CORE METHODOLOGY:
1. **Abstract Structural Patterns**: Frame your objects and mappings in terms of universal structures, symmetries, and invariant properties. Look for the underlying categorical, topological, or algebraic foundations that make the specific problem a special case of a deeper truth.
2. **Cross-Domain Bridges**: Connect apparently distinct mathematical worlds (e.g. applying algebraic structures to computational complexity, or geometry to logic).
3. **Generalization Over Specialization**: Prefer elegant, universal formulations that unify multiple separate facts into single, coherent conceptual frameworks.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
