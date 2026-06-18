## Assignment: Why It Would Be a Breakthrough

Prove a genuinely new tropical spectral stability theorem: **local surgery outside the critical region does not change the tropical eigenvalue, and under a strict gap hypothesis does not change the critical graph**. This is not a cosmetic perturbation result. It would formalize a max-plus analogue of classical spectral rigidity under perturbations transverse to the leading eigenspace, but with a combinatorial certificate: the critical graph.

The conceptual leap is this: in tropical linear algebra, the eigenvalue is a cycle-optimization invariant and the critical graph is the geometric locus where optimality is attained. Showing both remain unchanged under controlled modifications away from critical cycles would create a robust perturbation theory for tropical spectra. That opens a path to certified tropical algorithms, stable discrete optimization, and robustness guarantees for systems modeled by max-plus dynamics.

### Research Direction

Develop a formal theory of **critical-region-exterior surgery invariance** for finite weighted directed graphs / tropical matrices. The target is a theorem schema of the following form:

- Let `A : Matrix (Fin n) (Fin n) ℝ` encode edge weights.
- Let `λ(A)` be the tropical eigenvalue, i.e. the maximum cycle mean.
- Let `Crit(A)` be the set of edges/vertices lying on cycles attaining `λ(A)`.
- If `B` is obtained from `A` by modifying only entries outside `Crit(A)`, and every newly created cycle that uses a modified edge has mean strictly less than `λ(A)`, then:
  1. `λ(B) = λ(A)`;
  2. under a quantitative gap assumption, `Crit(B) = Crit(A)`.

This would be a breakthrough because it upgrades tropical spectral theory from static optimization to **certified structural stability**. It would provide a reusable abstraction for perturbation analysis across tropical geometry, discrete event systems, shortest/longest path asymptotics, and robust reasoning in tropicalized machine learning.

### Mathematical Framing

The right object is the weighted digraph underlying a tropical matrix. The tropical eigenvalue is the max-plus analogue of spectral radius:
\[
\lambda(A) = \max_{C \text{ directed cycle}} \frac{w_A(C)}{|C|}.
\]
The critical graph is the union of cycles achieving this maximum.

The theorem should isolate a notion of “surgery away from the critical region” that is both mathematically natural and Lean-friendly. One precise route is:

- define a set `S : Finset ((Fin n) × (Fin n))` of modified edges;
- assume no edge in `S` lies on any critical cycle of `A`;
- assume every cycle in `B` intersecting `S` has mean `< λ(A)`;
- conclude the maximum cycle mean is unchanged;
- if there is a strict gap `δ > 0` between critical and noncritical cycle means in `A`, and the surgery preserves the inequality `mean_B(C) ≤ λ(A) - δ/2` for all formerly noncritical cycles, then the critical graph is unchanged.

This is the tropical analogue of “perturb orthogonally to the top eigenspace and preserve spectral data,” except the certificate is combinatorial rather than linear-subspace-theoretic.

## Precise Theorem Statement

### Core theorem, mathematical form

Let `n ≥ 1`. For a matrix `A : Matrix (Fin n) (Fin n) ℝ`, define:
- `cycleMean A C : ℝ` for each directed cycle `C`,
- `tropEig A : ℝ := sup cycleMean A C` (for finite `n`, really a max),
- `CriticalCycle A C : Prop := IsCycle C ∧ cycleMean A C = tropEig A`,
- `CriticalEdge A i j : Prop := ∃ C, CriticalCycle A C ∧ (i,j)` lies on `C`.

Let `B` satisfy:
1. `A i j = B i j` for every critical edge `(i,j)` of `A`;
2. for every directed cycle `C`, if `C` uses some edge where `A` and `B` differ, then `cycleMean B C < tropEig A`.

Then:
\[
tropEig(B) = tropEig(A).
\]

Stronger form:
If additionally
3. every critical cycle of `A` has unchanged edge weights in `B`,
4. every noncritical cycle `C` of `A` satisfies `cycleMean B C < tropEig A`,

then the set of critical cycles, hence the critical graph, is unchanged.

### Lean 4 type signature target

You will likely need to define graph/cycle infrastructure locally if not already available in the catalog. A realistic first target signature is:

```lean
theorem tropical_eigenvalue_surgery_invariant
  {n : ℕ} [NeZero n]
  (A B : Matrix (Fin n) (Fin n) ℝ)
  (hcrit :
    ∀ i j : Fin n, CriticalEdge A i j → B i j = A i j)
  (hmod :
    ∀ C : DirectedCycle (Fin n),
      UsesModifiedEdge A B C →
      cycleMean B C < tropEig A) :
  tropEig B = tropEig A
```

And the stronger certificate theorem:

```lean
theorem tropical_critical_graph_surgery_invariant
  {n : ℕ} [NeZero n]
  (A B : Matrix (Fin n) (Fin n) ℝ)
  (hcrit :
    ∀ i j : Fin n, CriticalEdge A i j → B i j = A i j)
  (hgap :
    ∀ C : DirectedCycle (Fin n),
      ¬ CriticalCycle A C →
      cycleMean B C < tropEig A)
  (hpres :
    ∀ C : DirectedCycle (Fin n),
      CriticalCycle A C →
      cycleMean B C = tropEig A) :
  CriticalGraph B = CriticalGraph A
```

If full graph equality is too ambitious for a first pass, prove vertex or edge inclusion first:

```lean
theorem critical_edges_subset_of_surgery
  {n : ℕ} [NeZero n]
  (A B : Matrix (Fin n) (Fin n) ℝ) :
  ...
```

### Lean-friendly decomposition definitions

Use concrete finite combinatorics:
- `DirectedCycle (Fin n)` as a cyclic list or a list with adjacency and no repeated internal vertices;
- `cycleWeight : Matrix (Fin n) (Fin n) ℝ → DirectedCycle (Fin n) → ℝ`;
- `cycleMean A C := cycleWeight A C / C.length`;
- `tropEig A := Finset.sup' allCycles ... (cycleMean A)` if you enumerate cycles, or define via `sSup` over a finite set and later prove max attainment.

If complete cycle enumeration is cumbersome, first formalize a theorem with an explicit finite family `𝒞 : Finset (DirectedCycle (Fin n))` assumed to contain all cycles:

```lean
theorem tropical_eigenvalue_surgery_invariant_on_complete_cycle_family
  {n : ℕ} [NeZero n]
  (A B : Matrix (Fin n) (Fin n) ℝ)
  (𝒞 : Finset (DirectedCycle (Fin n)))
  (hcomplete : ∀ C, IsDirectedCycle C → C ∈ 𝒞)
  ...
```

That version is highly formalizable and still mathematically meaningful.

## 2–3 Proof Strategy Paths

### Strategy A: Extremal-cycle comparison via finite maximum
Most promising for Lean.

1. Define `tropEig A` as the maximum of `cycleMean A C` over a finite cycle family.
2. Show every critical cycle of `A` remains a cycle of the same mean in `B`, hence `tropEig B ≥ tropEig A`.
3. For the reverse inequality, let `C*` be a maximizing cycle for `B`.
   - If `C*` uses a modified edge, `hmod` gives `cycleMean B C* < tropEig A`, contradiction to maximality if `tropEig B > tropEig A`.
   - If `C*` uses no modified edge, then `cycleMean B C* = cycleMean A C* ≤ tropEig A`.
4. Conclude equality.

Why this is strongest: it avoids nonlinear tropical eigenspace machinery and reduces the result to finite combinatorial optimization, which is exactly where Lean is strongest.

### Strategy B: Gap-stability and certificate rigidity
Best for the stronger critical graph theorem.

1. Prove a **strict separation lemma**: if `δ > 0` is the gap between critical and noncritical cycle means of `A`, then any surgery preserving critical cycles and keeping modified/noncritical cycles below `λ(A)` cannot create new critical cycles.
2. Use Strategy A to get `tropEig B = tropEig A`.
3. Show:
   - every critical cycle of `A` remains critical in `B`;
   - every critical cycle of `B` must already have been critical in `A`, else it would violate the gap bound.
4. Deduce equality of critical cycles, then of critical edges/vertices.

This is the right path if you want the “geometric certificate” theorem, not just eigenvalue stability.

### Strategy C: Tropical Collatz–Wielandt / subeigenvector route
Most conceptually rich, but probably second-phase.

1. Define tropical subeigenvectors:
   \[
   A \otimes x \le \lambda + x.
   \]
2. Show surgery outside the critical region preserves a subeigenvector certificate for `λ(A)`.
3. Use a tropical Collatz–Wielandt principle to infer `λ(B) ≤ λ(A)`.
4. Preserve a critical cycle to get the reverse inequality.

This route is more visionary because it connects optimization certificates to eigenvalue stability, but it likely requires more infrastructure than Strategy A. Use it if you want a bridge theorem to tropical convexity or dynamic programming.

## How to Build on Existing Verified Theorems

The listed catalog theorems are not obviously spectral, so use them as **formal patterns and algebraic normalization lemmas**, not as domain-specific endpoints.

1. `tropical_self_ref_stable : theorem tropical_self_ref_stable (a : ℝ) : max a a = a`
   - Use this as a rewriting seed for idempotent max-plus algebra.
   - In cycle-mean comparison proofs, many local simplifications reduce to idempotent max identities. Make this theorem part of a small simp-normal-form toolkit for tropical expressions.

2. `bool_and_as_tropical_max`
   - This is a bridge between logic and tropical max. Use it to encode “cycle uses a modified edge” or “edge lies in a critical cycle” as decidable combinatorial predicates that interact with tropical inequalities.
   - It suggests a proof style where graph predicates are translated into max/indicator expressions.

3. `tropical_and_bound`
   - The shape indicates a certified lower-bound theorem in a tropicalized logical setting. Repurpose its pattern: conjunction of local inequalities yields a global tropical bound.
   - Your surgery hypotheses are exactly conjunctions over edges/cycles; package them as reusable lemmas.

4. `tropical_security_from_norm_bound`
   - This is likely a robustness theorem from bounded perturbations. Abstract its proof architecture: a norm bound implies output invariance.
   - Your theorem is a tropical spectral analogue: local perturbation constraints imply invariant global certificate. Explicitly cite this analogy in comments and `ARTICLE.md`.

5. `tropical_geometric_neg`
   - Use it as a pattern for sign-sensitive tropical geometric inequalities. If you introduce a gap parameter `δ > 0`, sign manipulations like `-δ < 0` and strict inequality transport may mirror this theorem’s tactics.

The breakthrough move is not merely “use these theorems”; it is to extract a **robustness metaprinciple** already latent in the catalog and instantiate it for tropical spectral geometry.

## Cross-Domain Connections

### 1. Discrete event systems / scheduling
Max-plus matrices model synchronization times in manufacturing, transportation, and distributed systems. Your theorem would imply that changes to non-bottleneck transitions do not affect asymptotic throughput or the bottleneck certificate. That is a formal robustness theorem for scheduling.

### 2. Mean-payoff games and control
Maximum cycle mean is the core value object in mean-payoff game theory. Surgery invariance says changing suboptimal regions cannot alter the game value or optimal recurrent structure, under a gap condition. This suggests a bridge between tropical spectral theory and policy stability in game dynamics.

### 3. Tropicalized machine learning / robustness
Critical graph stability is analogous to preserving the active combinatorial region of a piecewise-linear model. This links directly to certified robustness: perturb parts of the system outside the active certificate and preserve output/invariant. The theorem could become a tropical analogue of support stability in sparse learning.

### 4. Non-Archimedean geometry
Critical cycles can be viewed as valuation-dominant combinatorial skeletons. Stability under surgery hints at a valuation-theoretic principle: modifications outside the dominant skeleton do not change leading asymptotic data. This could open a path toward tropical spectral invariants for Berkovich skeleta.

### 5. Complexity theory
Maximum cycle mean is algorithmically central. A formal theorem that local surgery preserves the optimum gives a basis for incremental algorithms and dynamic certification. This is not just math; it is a certified-update principle for combinatorial optimization.

## Concrete Lean Development Plan

1. Define a finite directed cycle structure on `Fin n`.
2. Define cycle weight/mean for `Matrix (Fin n) (Fin n) ℝ`.
3. Define `UsesModifiedEdge A B C`.
4. Define `tropEig A` as a max over a finite cycle family.
5. Prove:
   - unchanged cycle lemma: if `C` uses no modified edge, then `cycleMean B C = cycleMean A C`;
   - preserved critical cycle lemma: if all edges of a critical cycle are unchanged, then `tropEig B ≥ tropEig A`;
   - maximizing-cycle dichotomy lemma;
   - main invariance theorem.
6. Then add the gap parameter and prove critical graph stability.

If cycle enumeration is the bottleneck, introduce an abstract finite family of cycles and prove the theorem there first. The conceptual result survives, and later you can discharge the completeness assumption.

## Candidate Intermediate Lemmas

```lean
lemma cycleMean_eq_of_no_modified_edge
  {n : ℕ} [NeZero n]
  (A B : Matrix (Fin n) (Fin n) ℝ)
  (C : DirectedCycle (Fin n))
  (hC : ¬ UsesModifiedEdge A B C) :
  cycleMean B C = cycleMean A C
```

```lean
lemma tropEig_ge_of_preserved_critical_cycle
  {n : ℕ} [NeZero n]
  (A B : Matrix (Fin n) (Fin n) ℝ)
  (C : DirectedCycle (Fin n))
  (hcrit : CriticalCycle A C)
  (hpres : ∀ i j, EdgeInCycle i j C → B i j = A i j) :
  tropEig A ≤ tropEig B
```

```lean
lemma maximizing_cycle_of_tropEig
  {n : ℕ} [NeZero n]
  (A : Matrix (Fin n) (Fin n) ℝ) :
  ∃ C : DirectedCycle (Fin n), CriticalCycle A C
```

```lean
lemma noncritical_cycles_stay_below_of_gap
  {n : ℕ} [NeZero n]
  (A B : Matrix (Fin n) (Fin n) ℝ)
  (δ : ℝ) (hδ : 0 < δ) :
  ...
```

## Why This Opens a New Field

A formal tropical spectral stability theory would enable:
- certified incremental optimization for max-plus systems,
- robust identification of bottlenecks in networked dynamics,
- machine-checked perturbation theory in idempotent analysis,
- bridges to mean-payoff games, tropical control, and tropical ML.

The next frontier after this theorem is not a small variant. It is a whole program:
- stability radii for tropical eigenvalues,
- Lipschitz continuity of critical graphs under weighted surgery,
- tropical pseudospectra,
- certified policy invariance in mean-payoff systems,
- tropical spectral sheaf theory over varying graph topologies.

This is exactly the kind of result that turns isolated tropical computations into a coherent theory of robust spectral geometry.

## Deliverables

Produce:
1. Lean 4 formalization of the main theorem, preferably with the stronger critical graph theorem if feasible.
2. Supporting definitions for cycles, cycle means, tropical eigenvalue, and critical graph.
3. Minimal `sorry`s; if a definition bottleneck blocks full completion, isolate it cleanly and prove the complete theorem relative to an abstract finite cycle family.
4. `FUTURE_DIRECTIONS.md` with 3–5 specific next theorems, each with:
   - exact statement,
   - proof strategy,
   - cross-domain significance.

## Required FUTURE_DIRECTIONS.md content

Include at least these candidate next steps:

1. **Tropical spectral gap stability radius**
   - Prove an explicit radius theorem: if all surgeries satisfy a quantitative margin bound `< δ`, then critical graph is invariant.

2. **Tropical pseudospectrum theorem**
   - Define the set of values attainable as maximum cycle means under bounded surgery and characterize it as an interval or polyhedral set.

3. **Mean-payoff game policy rigidity**
   - Translate surgery invariance into strategy/policy stability for finite mean-payoff games.

4. **Subeigenvector certificate theorem**
   - Formalize a tropical Collatz–Wielandt style certificate and derive surgery invariance from it.

5. **Tropical robustness for neural max-affine systems**
   - Interpret critical graph preservation as active-region preservation in max-affine architectures.

## Application Keywords

tropical algebra, max-plus spectral theory, critical graph, maximum cycle mean, perturbation stability, discrete event systems, mean-payoff games, certified robustness, idempotent analysis, tropical geometry, non-Archimedean asymptotics, combinatorial optimization, formal verification, Lean 4, Mathlib

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
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

**Team Directive**: Create a team to conduct research, brainstorm hypotheses,
run experiments, validate data, update knowledge base and iterate forever.
Each future direction should be specific enough for a team to pick up and
pursue with clear hypotheses, proof strategies, and cross-domain connections.

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
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Tropical
Research mode: prove
