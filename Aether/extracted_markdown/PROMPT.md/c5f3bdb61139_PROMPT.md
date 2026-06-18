## Assignment: Machine Learning Generalization Bounds — Toward a Structure Theorem for Why Overparameterization Does Not Destroy Generalization

You are not being asked to formalize folklore inequalities. You are being asked to isolate a **mathematical mechanism** by which architecture, compression, and posterior concentration jointly force generalization in regimes where parameter count alone predicts failure. The breakthrough target is a **unified structural theorem**: overparameterized models generalize when their effective hypothesis class collapses through symmetry, quotienting, compression, or posterior localization.

Build directly on the verified bridge theorems already in the catalog:
- `sample_complexity_lower_bound` from `MachineLearning/CertificationBarrier.lean`
- `sample_complexity_mono_dim` from `MachineLearning/AlgebraicLearning/Foundations.lean`
- `finite_quotient_implies_finite_tropicalVC_and_compression` from `MachineLearning/OperadicDeepLearning/TropicalVCDuality.lean`
- `generalization_complexity_bridge` from `MachineLearning/OperadicDeepLearning/UniversalArchitecture.lean`
- `sample_complexity_threshold` from `MachineLearning/PadicInfoGeom/PadicCramerRao.lean`
- `pac_bayes_equal_var_rate_upper` from `MachineLearning/PACBayes/AsymptoticRate.lean`
- `complexity_determines_generalization` from `MachineLearning/ProvabilityPACBayesian.lean`

Your task is to prove **at least 3 substantial theorems** with multi-step arguments, and to introduce at least one genuinely new definition that crystallizes the hidden structure behind these catalog results.

---

## Core New Definition: Effective Architecture Compression Profile

Define a new structure measuring the tension between raw parameter dimension, quotient collapse, and code-length compression.

Suggested Lean-facing concept:

```lean
structure EffectiveComplexityProfile where
  paramDim : ℕ
  quotientComplexity : ℕ
  codeLength : ℕ
  posteriorKL : ℝ
  sampleSize : ℕ
```

Then define a derived effective complexity functional:

```lean
def EffectiveComplexityProfile.effectiveRate (P : EffectiveComplexityProfile) : ℝ :=
  (P.quotientComplexity : ℝ) + (P.codeLength : ℝ) + P.posteriorKL
```

And a predicate expressing a generalization regime:

```lean
def GeneralizesAtScale (P : EffectiveComplexityProfile) (ε δ : ℝ) : Prop :=
  0 < ε ∧ 0 < δ ∧ P.effectiveRate ≤ (P.sampleSize : ℝ) * ε^2 * (Real.log (1 / δ))
```

This is not just bookkeeping. It is the formal object that lets you compare:
- VC/compression collapse from tropical or operadic quotienting,
- PAC-Bayes posterior concentration,
- monotonic sample complexity laws,
- lower-bound obstructions.

This definition should become the hinge connecting symbolic architecture, information geometry, and statistical learning.

Application keywords: **PAC-Bayes, compression bounds, overparameterization, effective dimension, quotient complexity, operadic deep learning, tropical VC theory, posterior localization, sample complexity, information geometry**

---

## Theorem 1: Unified Compression–PAC-Bayes Generalization Principle

### Mathematical statement
Prove a theorem of the following form:

> If an architecture admits finite quotient complexity and finite compression, and if its posterior KL term satisfies the asymptotic PAC-Bayes upper bound, then its effective complexity controls generalization at finite sample size. In particular, overparameterization in `paramDim` alone does not obstruct generalization once quotient and compression collapse the effective rate.

A precise target statement:

```lean
theorem effective_generalization_of_compression_and_pacbayes
  (P : EffectiveComplexityProfile)
  (ε δ : ℝ)
  (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1)
  (hkl : P.posteriorKL ≤ Real.log (1 / δ))
  (hcomp : (P.quotientComplexity : ℝ) + (P.codeLength : ℝ) ≤ (P.sampleSize : ℝ) * ε^2)
  : GeneralizesAtScale P ε δ
```

You may need to tune the exact constants to align with available catalog theorems. That is fine. The point is not the constants; the point is the **structural theorem**.

### Why this is a breakthrough
This theorem would formalize a concept the field talks around but rarely states cleanly: **generalization is governed by effective complexity, not ambient parameter count**. If formalized in Lean with explicit inequalities, it creates a reusable theorem schema for proving generalization in wildly overparameterized settings via compression and posterior localization.

### Proof strategy options

**Strategy A: Direct inequality synthesis from catalog bounds**  
Most promising if existing theorems already produce numerical upper bounds.
1. Use `pac_bayes_equal_var_rate_upper` to upper-bound the posterior contribution.
2. Use `finite_quotient_implies_finite_tropicalVC_and_compression` and `generalization_complexity_bridge` to convert quotient/compression finiteness into effective complexity control.
3. Combine terms by `calc` chains and monotonicity; conclude `GeneralizesAtScale`.

**Strategy B: Contrapositive via sample complexity obstruction**
1. Assume failure of `GeneralizesAtScale`.
2. Rearrange inequalities to show effective complexity exceeds admissible sample threshold.
3. Invoke `sample_complexity_lower_bound` or `sample_complexity_threshold` to derive contradiction with the hypothesized compression/PAC-Bayes regime.

**Strategy C: Architecture-monotonic refinement**
1. Use `sample_complexity_mono_dim` to compare raw dimension growth with effective quotient collapse.
2. Show effective rate remains bounded even if `paramDim` increases.
3. Deduce generalization for overparameterized families by replacing dimension with effective rate.

Strategy A is likely the cleanest for the first theorem; Strategy B is ideal if the catalog’s lower-bound theorems are stronger than its upper-bound packaging.

---

## Theorem 2: Overparameterization Invariance Under Effective Complexity Collapse

### Mathematical statement
You should formalize a theorem showing that increasing ambient parameter dimension does not worsen generalization whenever quotient complexity, code length, and posterior KL remain fixed.

Suggested theorem:

```lean
theorem overparametrization_does_not_hurt_of_fixed_effective_rate
  (P₁ P₂ : EffectiveComplexityProfile)
  (ε δ : ℝ)
  (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1)
  (hdim : P₁.paramDim ≤ P₂.paramDim)
  (hq : P₂.quotientComplexity = P₁.quotientComplexity)
  (hc : P₂.codeLength = P₁.codeLength)
  (hkl : P₂.posteriorKL = P₁.posteriorKL)
  (hs : P₂.sampleSize = P₁.sampleSize)
  (hgen : GeneralizesAtScale P₁ ε δ)
  : GeneralizesAtScale P₂ ε δ
```

A stronger version would show the effective rate is literally invariant under dimension inflation preserving the compressed quotient description.

### Why this matters
This is the formal anti-classical theorem. Classical statistical learning says larger classes should generalize worse. Modern deep learning says larger networks often generalize better. Your theorem should identify a **precise mathematical reconciliation**: if parameter growth occurs inside symmetry directions or redundant encodings, then the learning-relevant complexity is unchanged.

This opens the door to a formal theory of:
- width limits with bounded effective complexity,
- architecture search by quotient collapse,
- “benign overparameterization” as a theorem rather than a slogan.

### Proof strategy options

**Strategy A: Definitional invariance**
1. Expand `GeneralizesAtScale` and `effectiveRate`.
2. Rewrite using the equalities `hq`, `hc`, `hkl`, `hs`.
3. The core proof is not trivial: after rewriting, unpack the conjunctions and transport inequalities carefully using `calc` and coercion management.

**Strategy B: Complexity bridge theorem**
1. Use `generalization_complexity_bridge` to express generalization in terms of complexity rather than raw dimension.
2. Use `sample_complexity_mono_dim` only to show raw dimension monotonicity does not improve the naive bound.
3. Conclude that the architecture-level complexity theorem dominates the dimension-based one.

**Strategy C: Contradiction against dimension-only lower bound**
1. Suppose increased dimension destroys generalization.
2. Then by bridge theorems, complexity must have increased.
3. Contradict invariance of quotient complexity, code length, and posterior KL.

Strategy B is conceptually strongest because it explicitly demonstrates the replacement of classical dimension dependence by architecture-sensitive complexity.

---

## Theorem 3: Compression–Quotient Duality Implies Sample Complexity Improvement

### Mathematical statement
Extract a theorem from the tropical/operadic side saying finite quotient collapse strictly improves or upper-bounds sample complexity compared to a raw-dimensional estimate.

A target theorem shape:

```lean
theorem quotient_compression_improves_sample_complexity
  (rawDim q c n : ℕ)
  (ε δ : ℝ)
  (hε : 0 < ε) (hδ : 0 < δ)
  (hq : q ≤ rawDim)
  (hc : c ≤ rawDim)
  (hbound_raw : (rawDim : ℝ) ≤ (n : ℝ) * ε^2)
  : ((q : ℝ) + (c : ℝ)) ≤ 2 * (n : ℝ) * ε^2
```

This is an abstract numeric shell. The more important theorem is the architecture-aware version that uses
`finite_quotient_implies_finite_tropicalVC_and_compression`
to deduce that quotienting forces a smaller effective complexity than naive parameter counting.

If possible, prove a theorem directly referencing an architecture/presentation object already present in the catalog, e.g.:

```lean
theorem operadic_quotient_yields_better_generalization_scale
  (A : OperadicPresentation)
  (ε δ : ℝ)
  ...
  : ∃ q c : ℕ, q + c ≤ architecture_raw_dimension A ∧ ...
```

Adapt names to actual available definitions.

### Why this is a breakthrough
This theorem forges a real bridge between **representation theory / operadic symmetry / tropical quotienting** and **statistical sample complexity**. It says architecture is not a nuisance variable but a source of **mathematically certifiable sample-efficiency gains**.

### Proof strategy options

**Strategy A: Tropical VC route**
1. Invoke `finite_quotient_implies_finite_tropicalVC_and_compression`.
2. Convert finite tropical VC/compression data into an explicit numerical bound.
3. Compare with `sample_complexity_mono_dim` or `sample_complexity_lower_bound` to show the quotient-based estimate is sharper.

**Strategy B: Universal architecture bridge**
1. Use `generalization_complexity_bridge` to move from architecture to complexity.
2. Bound complexity by quotient and compression terms.
3. Derive improved sample complexity threshold.

**Strategy C: Hybrid lower-vs-upper sandwich**
1. Use raw-dimensional lower bounds from `sample_complexity_lower_bound`.
2. Use compression/PAC-Bayes upper bounds from the catalog.
3. Show quotient collapse produces a nontrivial gap, i.e. a strict improvement regime.

Strategy A is the most cross-domain and scientifically exciting because it explicitly ties tropical geometry to learning-theoretic capacity.

---

## Theorem 4: A Cross-Domain Information-Geometric Generalization Bound

You are required to include at least one theorem connecting machine learning generalization to another mathematical domain. The strongest candidate in the present catalog is **p-adic or information geometry**.

### Mathematical statement
Prove a theorem asserting that if a model lies below an information-geometric sample-complexity threshold, then its PAC-Bayes effective rate is admissible.

Suggested target:

```lean
theorem padic_threshold_controls_effective_generalization
  (P : EffectiveComplexityProfile)
  (ε δ : ℝ)
  (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1)
  (hthr : sample_complexity_threshold ≤ P.sampleSize)
  (hkl : P.posteriorKL ≤ Real.log (1 / δ))
  (heff : (P.quotientComplexity : ℝ) + (P.codeLength : ℝ) ≤ (P.sampleSize : ℝ) * ε^2)
  : GeneralizesAtScale P ε δ
```

Adjust to the actual type of `sample_complexity_threshold`. If it depends on parameters, expose them explicitly.

### Cross-domain significance
This theorem connects:
- **information geometry** / p-adic statistical structure,
- **PAC-Bayes posterior concentration**,
- **architectural compression**.

That is exactly the kind of “I never thought these belonged in the same theorem” connection worth formalizing.

### Proof strategy options

**Strategy A: Threshold import**
1. Instantiate `sample_complexity_threshold` with your parameters.
2. Use it to derive the admissible sample regime.
3. Plug into Theorem 1.

**Strategy B: Cramér–Rao style route**
1. Interpret the threshold as controlling estimation complexity.
2. Show estimation control implies posterior concentration.
3. Convert to generalization via PAC-Bayes.

**Strategy C: Bridge via contradiction**
1. Assume no generalization despite threshold satisfaction.
2. Derive a sample complexity violation.
3. Contradict the threshold theorem.

---

## Required Lean 4 Design Notes

You should aim for theorem statements with explicit types and reusable predicates. Avoid vague propositions about “networks” unless a network object is already defined in Mathlib or the catalog. If necessary, work abstractly with profiles, complexity measures, and architecture presentations.

Suggested auxiliary definitions:

```lean
def EffectiveComplexityProfile.overparametrizedBy (P : EffectiveComplexityProfile) (k : ℕ) : EffectiveComplexityProfile :=
  { P with paramDim := P.paramDim + k }

theorem effectiveRate_overparametrizedBy
  (P : EffectiveComplexityProfile) (k : ℕ) :
  (P.overparametrizedBy k).effectiveRate = P.effectiveRate
```

This auxiliary theorem can support Theorem 2, but do not let it become one of the main three unless it is embedded inside a genuinely deeper result.

Also consider a predicate expressing quotient collapse:

```lean
def QuotientCollapsed (P : EffectiveComplexityProfile) : Prop :=
  P.quotientComplexity ≤ P.paramDim ∧ P.codeLength ≤ P.paramDim
```

This can be used to formulate architecture-sensitive sample-complexity comparison theorems.

---

## Proof Tactic Expectations

At least three theorems must use genuinely nontrivial proof patterns. You should deliberately include:
- `rcases` to unpack catalog existential/finite-compression hypotheses,
- `by_contra` for at least one impossibility theorem or obstruction theorem,
- `field_simp` if logarithmic/rationalized inequalities require denominator clearing,
- induction if you define architecture inflation or iterative layer-compression profiles,
- multi-step `calc` chains to manage coercions `ℕ → ℝ` and combine inequalities.

Do not hide the mathematics inside automation. The point is to expose the mechanism.

---

## A Stronger Optional Theorem: Separation Between Raw Dimension and Effective Complexity

If the catalog supports enough infrastructure, prove a strict separation theorem:

```lean
theorem exists_overparametrized_generalizing_profile
  (ε δ : ℝ) (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1) :
  ∃ P : EffectiveComplexityProfile,
    P.paramDim > P.sampleSize ∧
    GeneralizesAtScale P ε δ
```

This would be philosophically explosive: a formally certified existence theorem for a regime where the number of parameters exceeds the number of samples, yet generalization still holds by effective complexity control.

If this is too ambitious with current catalog infrastructure, state it as a conjecture and prove partial lemmas toward it.

---

## Conjecture with Falsifiable Computational Test

You must include at least one explicit conjecture with a disproof protocol.

### Conjecture: Effective-Rate Universality
```lean
conjecture effective_rate_universality
  (P : EffectiveComplexityProfile) :
  ∃ C : ℝ, 0 < C ∧
    ∀ ε δ : ℝ, 0 < ε → 0 < δ → δ < 1 →
    P.effectiveRate ≤ C * (P.sampleSize : ℝ) * ε^2 * Real.log (1 / δ) →
    GeneralizesAtScale P ε δ
```

### Computational falsification protocol
To test this conjecture:
1. Generate synthetic architecture profiles with fixed sample size.
2. Increase `paramDim` arbitrarily while holding `quotientComplexity`, `codeLength`, and posterior KL fixed.
3. Search for a profile where the inequality hypothesis holds but empirical generalization fails systematically.
4. A single such counterexample refutes universality.

This is a genuine scientific hypothesis because it can be falsified by explicit profile construction or simulation.

A second, even sharper conjecture:

```lean
conjecture quotient_collapse_strictly_beats_dimension_bound
  ∀ P : EffectiveComplexityProfile,
    QuotientCollapsed P →
    P.quotientComplexity + P.codeLength < P.paramDim →
    ∃ ε : ℝ, 0 < ε ∧
      ((P.quotientComplexity : ℝ) + (P.codeLength : ℝ)) ≤ (P.sampleSize : ℝ) * ε^2 ∧
      ¬ ((P.paramDim : ℝ) ≤ (P.sampleSize : ℝ) * ε^2)
```

This predicts a strict regime where quotient/compression proves learnability while raw dimension does not. It is falsifiable by exhaustive search over small finite profiles.

---

## Cross-Domain Connections You Should Make Explicit in Comments and Naming

1. **Tropical geometry / VC theory**  
   Quotient collapse from `finite_quotient_implies_finite_tropicalVC_and_compression` should be interpreted as a tropical capacity reduction mechanism.

2. **Operad theory / architecture semantics**  
   `generalization_complexity_bridge` suggests architecture composition laws can control statistical complexity. This is a rare and powerful connection: compositional algebra governs sample efficiency.

3. **Information geometry / p-adic thresholds**  
   `sample_complexity_threshold` indicates that non-Archimedean or geometric estimation thresholds may constrain learnability. Bring this into the story explicitly.

4. **Bayesian inference / code length / MDL**  
   PAC-Bayes and compression are two faces of one phenomenon: posterior concentration and short description length both reduce effective hypothesis volume.

5. **Statistical physics analogy**  
   Overparameterization can be framed as a high-dimensional phase space with a low-entropy effective manifold. If you can define this metaphor formally through effective rate collapse, do it in comments/docstrings.

---

## Deliverable Structure

Produce a Lean file containing:
1. the new definition `EffectiveComplexityProfile`,
2. at least 3 major theorems of the sort above,
3. one cross-domain theorem explicitly invoking a non-ML catalog theorem family,
4. at least one falsifiable conjecture,
5. comments indicating which catalog theorems are being used and how.

Minimize `sorry`, but if one is unavoidable, isolate it in the most ambitious theorem rather than in foundational lemmas.

---

## FUTURE_DIRECTIONS.md (MANDATORY)

In addition to the Lean file, produce `FUTURE_DIRECTIONS.md` with 3–5 falsifiable hypotheses. They must be scientific predictions, not vague ideas. Include clear tests.

Required hypotheses to consider refining:
1. **Benign Overparameterization Hypothesis**  
   For architecture families with constant quotient complexity and code length, generalization error remains bounded as parameter dimension tends to infinity.  
   **Test:** instantiate finite families of profiles and check whether the proven effective-rate bounds remain dimension-invariant.

2. **Tropical Compression Dominance Hypothesis**  
   Tropical quotient complexity predicts sample complexity more sharply than raw dimension for architectures with large symmetry groups.  
   **Test:** compare raw-dimensional and quotient-compressed bounds on explicit small architecture classes.

3. **PAC-Bayes / MDL Equivalence Window Hypothesis**  
   In equal-variance regimes, PAC-Bayes KL upper bounds numerically match compression-code-length bounds up to universal constants.  
   **Test:** compute both sides on synthetic profile data and search for uniform constant ratios.

4. **p-adic Threshold Transfer Hypothesis**  
   Information-geometric sample thresholds transfer to architecture-aware generalization criteria with no dependence on ambient parameter count.  
   **Test:** instantiate threshold parameters and verify whether effective-rate conditions suffice while raw-dimensional bounds fail.

5. **Strict Separation Hypothesis**  
   There exist explicit profiles where raw-dimension sample complexity lower bounds predict non-generalization, yet quotient-compression PAC-Bayes bounds certify generalization.  
   **Test:** brute-force search over small integer profiles satisfying the separation inequalities.

This is the frontier: prove that the true geometry of deep learning generalization lives in **effective complexity collapse**, not in naive parameter counting.

### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  Show the math working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: MachineLearning
Research mode: prove
