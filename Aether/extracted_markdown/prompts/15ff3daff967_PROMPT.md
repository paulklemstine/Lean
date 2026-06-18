
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

**Title**: The current framework uses a fixed novelty threshold δ. A natural extension is t
**Domain**: Algebra
**Mathematical framing**: # Future Directions: Certified Novelty Detection for Theorem Provers

## 1. Adaptive Threshold Selection via Corpus Geometry

The current framework uses a fixed novelty threshold δ. A natural extension is to derive the threshold from the corpus itself — specifically, to set δ as a function of the corpus separation (e.g., δ = c · CorpusSeparation for some constant c > 1). The key insight is that a threshold scaled to the internal geometry of the corpus automatically adapts to the "resolution" of the known mathematics: dense areas of the theorem space require finer novelty discrimination than sparse areas. Why now? The `CorpusSeparation` definition and `separation_novelty_bound` theorem already provide the infrastructure. The conjecture is: for any corpus S with separation σ > 0 and threshold δ = σ, the novelty certificate rejects exactly the corpus elements and accepts points that are "genuinely outside the convex hull" in a metric sense. This should be formalizable using the existing Finset.inf' machinery plus convexity from Mathlib's `Analysis.Convex`.

## 2. Compositional Novelty for Structured Proofs

The `certified_novel_triangle` theorem shows novelty degrades gracefully under perturbation. This suggests a compositional framework: if a proof P consists of lemmas L₁, ..., Lₙ, define its novelty as the sum (or minimum) of individual novelty scores. The key insight is that compositional novelty gives a Lipschitz map from the product metric space (one factor per lemma) to ℝ, enabling modular certification where each lemma is certified independently. Why now? The Lipschitz result (`noveltyScore_dist_le`) immediately lifts to product spaces via standard Mathlib infrastructure (`PseudoMetricSpace.Prod`). The testable conjecture: for S ⊆ α^n (n-tuples of lemma signatures), the product novelty score is 1-Lipschitz in the ℓ^∞ product metric.

## 3. Novelty Persistence under Corpus Growth

As the corpus grows over time (S₁ ⊆ S₂ ⊆ ...), novelty scores decrease monotonically by `noveltyScore_antitone`. A deeper question is: at what rate? The key insight is that if the corpus grows to be ε-dense in the ambient space (every point is within ε of some corpus element), then all novelty scores collapse to ≤ ε, providing a quantitative "knowledge saturation" theorem. Why now? Mathlib already has `Metric.denseRange` and `EMetric.mem_closure_iff`. The conjecture to formalize: if S is an ε-net of a compact metric space α, then `∀ x, NoveltyScore x S hS ≤ ε`, and conversely if `∀ x, NoveltyScore x S hS ≤ ε`, then S is an ε-net. This would connect novelty certification to covering number theory.

## 4. Information-Theoretic Novelty Bounds

The metric novelty score measures "geometric" distance. An orthogonal measure is information-theoretic: how much does adding theorem x to corpus S increase the entropy of the corpus distribution? The key insight is that in finite metric spaces, the metric novelty score lower-bounds the information gain via a Fano-type inequality, connecting geometric and information-theoretic notions of novelty. Why now? Mathlib's `MeasureTheory.Measure.entropy` and `Finset.card` provide the foundations. The falsifiable conjecture: for a uniform distribution on a finite metric space with minimum distance d_min, adding a point x with NoveltyScore ≥ d_min increases the Shannon entropy by at least log(1 + 1/|S|).

## 5. Multi-Scale Novelty via Filtrations

A single threshold cannot capture novelty at multiple scales. Define a novelty filtration: for thresholds δ₁ < δ₂ < ... < δₖ, the sets Nᵢ = {x : IsCertifiedNovel x S hS δᵢ} form a decreasing chain N₁ ⊇ N₂ ⊇ ... ⊇ Nₖ. The key insight is that this filtration is a metric analog of persistent homology — tracking which novelty certificates "persist" across scales reveals structural features of the theorem space that single-scale analysis misses. Why now? The anti-monotonicity results already give the chain property for free. The testable conjecture: formalize that the "persistence diagram" of novelty (recording birth/death scales for each point) is 1-Lipschitz in the bottleneck distance with respect to Hausdorff distance on corpora. This would require formalizing bottleneck distance, but the core metric arguments are already in place.

**Concept description**: # Future Directions: Certified Novelty Detection for Theorem Provers

## 1. Adaptive Threshold Selection via Corpus Geometry

The current framework uses a fixed novelty threshold δ. A natural extension is to derive the threshold from the corpus itself — specifically, to set δ as a function of the corpus separation (e.g., δ = c · CorpusSeparation for some constant c > 1). The key insight is that a threshold scaled to the internal geometry of the corpus automatically adapts to the "resolution" of the known mathematics: dense areas of the theorem space require finer novelty discrimination than sparse areas. Why now? The `CorpusSeparation` definition and `separation_novelty_bound` theorem already provide the infrastructure. The conjecture is: for any corpus S with separation σ > 0 and threshold δ = σ, the novelty certificate rejects exactly the corpus elements and accepts points that are "genuinely outside the convex hull" in a metric sense. This should be formalizable using the existing Finset.inf' machinery plus convexity from Mathlib's `Analysis.Convex`.

## 2. Compositional Novelty for Structured Proofs

The `certified_novel_triangle` theorem shows novelty degrades gracefully under perturbation. This suggests a compositional framework: if a proof P consists of lemmas L₁, ..., Lₙ, define its novelty as the sum (or minimum) of individual novelty scores. The key insight is that compositional novelty gives a Lipschitz map from the product metric space (one factor per lemma) to ℝ, enabling modular certification where each lemma is certified independently. Why now? The Lipschitz result (`noveltyScore_dist_le`) immediately lifts to product spaces via standard Mathlib infrastructure (`PseudoMetricSpace.Prod`). The testable conjecture: for S ⊆ α^n (n-tuples of lemma signatures), the product novelty score is 1-Lipschitz in the ℓ^∞ product metric.

## 3. Novelty Persistence under Corpus Growth

As the corpus grows over time (S₁ ⊆ S₂ ⊆ ...), novelty scores decrease monotonically by `noveltyScore_antitone`. A deeper question is: at what rate? The key insight is that if the corpus grows to be ε-dense in the ambient space (every point is within ε of some corpus element), then all novelty scores collapse to ≤ ε, providing a quantitative "knowledge saturation" theorem. Why now? Mathlib already has `Metric.denseRange` and `EMetric.mem_closure_iff`. The conjecture to formalize: if S is an ε-net of a compact metric space α, then `∀ x, NoveltyScore x S hS ≤ ε`, and conversely if `∀ x, NoveltyScore x S hS ≤ ε`, then S is an ε-net. This would connect novelty certification to covering number theory.

## 4. Information-Theoretic Novelty Bounds

The metric novelty score measures "geometric" distance. An orthogonal measure is information-theoretic: how much does adding theorem x to corpus S increase the entropy of the corpus distribution? The key insight is that in finite metric spaces, the metric novelty score lower-bounds the information gain via a Fano-type inequality, connecting geometric and information-theoretic notions of novelty. Why now? Mathlib's `MeasureTheory.Measure.entropy` and `Finset.card` provide the foundations. The falsifiable conjecture: for a uniform distribution on a finite metric space with minimum distance d_min, adding a point x with NoveltyScore ≥ d_min increases the Shannon entropy by at least log(1 + 1/|S|).

## 5. Multi-Scale Novelty via Filtrations

A single threshold cannot capture novelty at multiple scales. Define a novelty filtration: for thresholds δ₁ < δ₂ < ... < δₖ, the sets Nᵢ = {x : IsCertifiedNovel x S hS δᵢ} form a decreasing chain N₁ ⊇ N₂ ⊇ ... ⊇ Nₖ. The key insight is that this filtration is a metric analog of persistent homology — tracking which novelty certificates "persist" across scales reveals structural features of the theorem space that single-scale analysis misses. Why now? The anti-monotonicity results already give the chain property for free. The testable conjecture: formalize that the "persistence diagram" of novelty (recording birth/death scales for each point) is 1-Lipschitz in the bottleneck distance with respect to Hausdorff distance on corpora. This would require formalizing bottleneck distance, but the core metric arguments are already in place.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Algebra
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v12 Depth Requirements -- Speculative Specifier Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Speculative Specifying (Bold Conjectures)**. Target high-risk, high-reward, grand-challenge level research.

### RESEARCH CORE METHODOLOGY:
1. **Grand Challenges**: Formulate bold, surprising, and non-trivial conjectures that challenge existing intuition. Even if a complete proof cannot be achieved in this cycle, outline precise strategies, obstacles, and partial results.
2. **Deep Speculation**: Explore radical connections that seem distant or impossible at first glance. Frame your theorems as seeds for entirely new fields of study.
3. **Long-Term Roadmap**: Dedicate significant intellectual effort to detailing the proof strategies and testable predictions in your future directions, laying out a clear path for future researchers.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
