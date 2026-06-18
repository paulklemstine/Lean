## Assignment: Algebra–MachineLearning–Logic Sheaf Proof-State Duality via Idempotent Cohomology Semimodules and Certified Minimal Counterexample Reconstruction

**Mode:** prove

Build a genuinely new theorem package in

`Bridges/AlgebraMachineLearningLogic/SheafProofStateDuality.lean`

that turns proof search, neural proof prediction, and local logical consistency into a finite sheaf-cohomological obstruction theory over idempotent semimodules, with an explicit certified reconstruction of minimal counterexample cycles.

This should not be a vague analogy. The goal is a formal finite theorem saying that for a proof-state dependency complex, the failure of a globally coherent proof policy is *exactly* first cohomology, and that every nonzero obstruction yields a machine-extractable minimal inconsistent cycle. If you can make this precise in Lean, you will have opened a new interface between algebraic logic, tropical/idempotent methods, and ML verification: a cohomological semantics of theorem proving.

### Breakthrough target

The conceptual leap is this:

- **proof systems** become finite dependency complexes,
- **neural or symbolic proof predictors** become local sections of a semimodule-valued presheaf,
- **global realizability / consistency** becomes existence of a global section,
- **fragility / inconsistency / adversarial failure** becomes a nontrivial `H¹`,
- **minimal counterexamples** become supports of nontrivial cocycles extracted algorithmically.

This is stronger than existing neural sheaf robustness results because the sheaf lives on the **proof-state complex**, not on parameter or feature space. It is stronger than generic proof-complexity analogies because it produces a **certified obstruction theorem with reconstruction**. If formalized cleanly, this could seed a whole field: cohomological proof learning.

---

## Precise theorem targets

You should aim to formalize a finite combinatorial version first, avoiding full sheaf-cohomology machinery if necessary. Work with a finite simplicial/dependency complex or finite hypergraph whose 1-skeleton and 2-face data suffice to define cocycles and coboundaries.

### Core finite duality theorem

Let:
- `V` be a finite type of proof states,
- `E` be a finite type of admissible local transitions / overlaps,
- `K` be a finite dependency complex encoded combinatorially,
- `S` be a finite idempotent commutative semiring or semimodule coefficient object,
- `F` assign local predictor-state spaces with restriction maps,
- `Z1` and `B1` be the usual 1-cocycles and 1-coboundaries in the finite Čech-style complex.

Prove a theorem of the following shape:

> **Finite Proof-State Realization via Vanishing First Cohomology.**  
> For a finite proof-state dependency complex `K` with gluing-compatible presheaf `F` valued in finite idempotent semimodules, the following are equivalent:
> 1. every locally compatible family of predictor states extends to a global section;
> 2. every 1-cocycle is a 1-coboundary;
> 3. the first obstruction quotient `H¹(K,F)` is trivial.
>
> Moreover, if `H¹(K,F)` is nontrivial, then there exists a finite support 1-cocycle whose support contains a minimal obstruction cycle, and a certified elimination procedure reconstructs such a cycle from any nontrivial cocycle representative.

A Lean-facing version could look like this:

```lean
theorem global_section_iff_H1_trivial
  {ι : Type u} [Fintype ι] [DecidableEq ι]
  (K : ProofDependencyComplex ι)
  (F : ProofStatePresheaf K S)
  (hglue : GluingCondition K F) :
  GlobalExtendability K F ↔ H1Trivial K F
```

and the cocycle/coboundary form:

```lean
theorem global_section_iff_every_cocycle_coboundary
  {ι : Type u} [Fintype ι] [DecidableEq ι]
  (K : ProofDependencyComplex ι)
  (F : ProofStatePresheaf K S)
  (hglue : GluingCondition K F) :
  GlobalExtendability K F ↔
    ∀ z : OneCocycle K F, ∃ c : ZeroCochain K F, coboundary c = z
```

### Certified minimal obstruction reconstruction theorem

Formalize an explicit finite extraction theorem:

> **Certified Minimal Counterexample Reconstruction.**  
> If `z` is a nontrivial 1-cocycle on a finite proof-state dependency complex, then the greedy elimination algorithm returns a support-minimal nontrivial cocycle `z_min` whose support contains a simple obstruction cycle. In particular, the output support is inclusion-minimal among supports of cocycles in the same nontrivial obstruction class, and certifies failure of global realizability.

Lean-facing target:

```lean
theorem exists_minimal_obstruction_of_nontrivial_H1
  {ι : Type u} [Fintype ι] [DecidableEq ι]
  (K : ProofDependencyComplex ι)
  (F : ProofStatePresheaf K S)
  (z : OneCocycle K F)
  (hz : ¬ IsCoboundary z) :
  ∃ zmin : OneCocycle K F,
    SameCohomologyClass z zmin ∧
    SupportMinimalAmongNontrivial zmin ∧
    ObstructionCycleCertified K F zmin
```

If the full “same cohomology class + support minimality” statement is too heavy initially, prove a weaker but still strong theorem:

```lean
theorem exists_inclusion_minimal_nontrivial_support
  {ι : Type u} [Fintype ι] [DecidableEq ι]
  (K : ProofDependencyComplex ι)
  (F : ProofStatePresheaf K S) :
  ∀ z : OneCocycle K F, ¬ IsCoboundary z →
    ∃ zmin : OneCocycle K F,
      ¬ IsCoboundary zmin ∧
      support zmin ⊆ support z ∧
      InclusionMinimalNontrivialSupport zmin
```

### Learnability/minimality duality theorem

Connect realizability and architectural minimality to `H⁰` generators, using the catalog theorem

- `finite_separation_semimodule_realization_minimal`

as the main algebraic bridge.

Target statement:

> **Learnability/Minimality Duality.**  
> In a realizable proof-state class with `H¹ = 0`, minimal globally consistent proof predictors correspond to generators of the semimodule of global sections `H⁰(K,F)`. Under finite separation hypotheses, the minimal architecture size equals the minimal generator cardinality of `H⁰`.

Lean-facing statement:

```lean
theorem realizable_minimal_architecture_eq_min_generators_H0
  {ι : Type u} [Fintype ι] [DecidableEq ι]
  (K : ProofDependencyComplex ι)
  (F : ProofStatePresheaf K S)
  (hreal : GlobalExtendability K F)
  (hsep : FiniteSeparationHypothesis K F) :
  MinimalArchitectureSize K F =
    MinimalGeneratorCardinality (GlobalSectionsSemimodule K F)
```

A useful intermediate theorem is:

```lean
theorem global_sections_semimodule_finitely_generated
  {ι : Type u} [Fintype ι] [DecidableEq ι]
  (K : ProofDependencyComplex ι)
  (F : ProofStatePresheaf K S) :
  FiniteGenerated (GlobalSectionsSemimodule K F)
```

and then invoke/adapt `finite_separation_semimodule_realization_minimal`.

### Robustness lower bound theorem

You do not need a fully analytic adversarial ML theorem at first. A finite combinatorial instability lower bound is already powerful:

> Nontrivial first cohomology forces a positive lower bound on proof-prediction instability: any globally approximating predictor must incur at least one disagreement along every representative obstruction cycle, hence at least the obstruction support size (or weight) as a lower bound on adversarial inconsistency/compression error.

Lean-facing finite version:

```lean
theorem nontrivial_H1_lower_bounds_prediction_instability
  {ι : Type u} [Fintype ι] [DecidableEq ι]
  (K : ProofDependencyComplex ι)
  (F : ProofStatePresheaf K S) :
  H1Nontrivial K F →
  ∃ n > 0, InstabilityLowerBound K F n
```

Weighted tropical version if available:

```lean
theorem cocycle_weight_lower_bounds_compression_error
  {ι : Type u} [Fintype ι] [DecidableEq ι]
  (K : WeightedProofDependencyComplex ι W)
  (F : WeightedProofStatePresheaf K S)
  (z : OneCocycle K F) :
  ¬ IsCoboundary z →
  cocycleWeight z ≤ ProofCompressionErrorLowerBound K F
```

---

## Lean 4 formalization guidance

A practical architecture is to define a finite combinatorial cochain complex directly, instead of importing all of sheaf theory at once.

Suggested definitions:

```lean
structure ProofDependencyComplex (ι : Type u) where
  edge : ι → ι → Prop
  triangle : ι → ι → ι → Prop
  -- or explicit finite sets of overlaps / admissible patches
```

```lean
structure ProofStatePresheaf (K : ProofDependencyComplex ι) (S : Type v) where
  local0 : ι → Type w
  local1 : {i j : ι} → K.edge i j → Type w
  resLeft  : ...
  resRight : ...
  -- optional semimodule structure assumptions packaged separately
```

If dependent local types become annoying, simplify aggressively: fix one coefficient semimodule `M`, and let 0-cochains be `ι → M`, 1-cochains be edge-labelings `Edge K → M`, and define cocycle conditions on triangles. This will still capture the obstruction theorem.

For example:

```lean
def ZeroCochain (K : ProofDependencyComplex ι) (M : Type v) := ι → M
def OneCochain (K : ProofDependencyComplex ι) (M : Type v) := Edge K → M

def coboundary (c : ZeroCochain K M) : OneCochain K M := ...
def IsCocycle (z : OneCochain K M) : Prop := ...
def IsCoboundary (z : OneCochain K M) : Prop := ∃ c, coboundary c = z
def H1Trivial : Prop := ∀ z, IsCocycle z → IsCoboundary z
```

Then define:

```lean
def GlobalExtendability (K : ProofDependencyComplex ι) (F : ...) : Prop := ...
```

and prove equivalence with `H1Trivial`.

For the reconstruction algorithm, because Lean likes termination proofs, define support size and use finite descent:

```lean
def support (z : OneCochain K M) : Finset (Edge K) := ...
def reducibleByCoboundary (z : OneCochain K M) : Prop := ...
def greedyReduce : OneCochain K M → OneCochain K M := ...
```

Then prove:
1. `greedyReduce` preserves cohomology class,
2. support strictly decreases when reducible,
3. finite descent terminates,
4. terminal output is support-minimal,
5. support-minimal nontrivial cocycle contains an obstruction cycle.

The “contains an obstruction cycle” theorem may require a graph-theoretic lemma:
a nonempty inclusion-minimal nontrivial cocycle support contains a simple cycle in the edge support. This is likely the cleanest bridge from cohomology to explicit counterexample reconstruction.

---

## Proof strategy options

### Strategy A: finite cochain-complex first, sheaf language second
**Most promising.**

1. Encode a finite dependency complex and semimodule-valued 0/1-cochains directly.
2. Prove `GlobalExtendability ↔ every cocycle is a coboundary` using explicit gluing equations.
3. Add the greedy support-reduction algorithm and derive minimal obstruction support.
4. Only then wrap the construction in presheaf/sheaf terminology.

Why this is best: it minimizes category-theoretic overhead and maximizes Lean tractability. It also makes the reconstruction algorithm natural, since support and elimination live directly at the cochain level.

### Strategy B: Čech-style finite sheaf formalization
1. Define a finite cover of proof states by admissible inference patches.
2. Construct Čech 0- and 1-cochains for the presheaf.
3. Formalize gluing and show the standard “global sections modulo compatibility” obstruction theorem.
4. Specialize to idempotent semimodule-valued coefficients and derive the extraction result combinatorially.

Why this is mathematically elegant: it aligns exactly with the sheaf-theoretic statement.  
Why it is riskier: full presheaf + Čech machinery may consume too much effort before reaching the extraction theorem.

### Strategy C: graph/hypergraph cycle-space route
1. Model local incompatibilities as edge labels in a finite graph/hypergraph.
2. Identify `H¹` with a cycle-space quotient in the finite combinatorial setting.
3. Use cycle basis / minimal support arguments to reconstruct a simple obstruction cycle.
4. Interpret global sections as realizable proof policies and import semimodule minimality later.

Why this is useful: it may make the minimal counterexample theorem easiest.  
Why it is incomplete alone: without the sheaf/presheaf semantics, the learnability duality may feel under-motivated. Best used as a subproof for the reconstruction component.

Recommended plan: **A for the main theorem, C for the minimal-cycle extraction lemma, then lift to sheaf language.**

---

## How to build on catalog theorems

You specifically have:

- `finite_separation_semimodule_realization_minimal`

Use it not as decoration but as the algebraic engine for the minimality half of the story. The intended bridge is:

1. Define the semimodule of global sections `GlobalSectionsSemimodule K F`.
2. Prove it is finitely generated under your finiteness hypotheses.
3. Show realizable proof predictors are exactly elements of this semimodule.
4. Apply `finite_separation_semimodule_realization_minimal` to identify minimal realizers/architectures with minimal generators.
5. Conclude that when `H¹ = 0`, local compatibility collapses the realizability problem to a finite semimodule generation problem.

If the catalog theorem is stated in terms of finite separation for function classes, instantiate:
- domain = proof states,
- outputs = predictor labels / semimodule weights,
- realizers = global sections,
- minimal architecture = minimal generating family.

This is the right nontrivial use: cohomological vanishing gives *existence*, the catalog theorem gives *minimal realization complexity*.

---

## Deeper mathematical framing

The theorem should be presented as a finite idempotent analogue of a classical principle:

- in ordinary sheaf theory, `H¹` measures obstruction to gluing;
- in logic, local consistency need not imply global consistency;
- in machine learning, local prediction compatibility need not imply robust global realizability.

Your contribution is to unify these by showing that in finite proof-state complexes with idempotent semimodule coefficients:

- **global inconsistency is literally a cohomological obstruction,**
- **fragility is the inability to trivialize a cocycle,**
- **minimal counterexamples are supports of nontrivial cohomology classes,**
- **minimal realizers are generators of `H⁰`.**

This is especially powerful over idempotent semimodules because:
- support and extremality are often more combinatorial than over rings,
- tropical/Boolean coefficients align naturally with proof-search costs, reachability, and admissibility,
- greedy elimination is more plausible and certifiable.

The Boolean case should be your first sandbox:
- local predictor states = admissible / inadmissible,
- cocycle support = incompatible overlaps,
- minimal obstruction = smallest impossible proof patch cycle.

Then tropicalize:
- edge labels = proof-step costs or confidence deficits,
- cocycle weight = cumulative obstruction cost,
- minimal support/weight = certified hard counterexample.

---

## Cross-domain connections to exploit

1. **Algebraic logic / proof complexity**  
   The dependency complex is a semantic refinement of resolution/proof-DAG structure. Nontrivial `H¹` becomes a topological certificate that local derivability data cannot be globally realized.

2. **Tropical and idempotent algebra**  
   Tropical semimodule coefficients let you treat proof search as weighted feasibility. This may lead to a tropical obstruction theory for theorem proving, where shortest counterexample cycles behave like min-plus geodesics.

3. **Neural theorem proving / adversarial robustness**  
   A proof predictor can be locally accurate on every patch yet globally unrealizable; your theorem makes this failure measurable and reconstructible. This is a robustness certificate for theorem-search policies.

4. **Program verification / abstract interpretation**  
   Local abstract transformers may be pairwise compatible but globally inconsistent around cycles. The same theorem could become a cohomological debugging tool for static analyzers.

5. **Distributed systems / consistency models**  
   Proof-state gluing mirrors distributed local views. Nontrivial cocycles resemble consistency anomalies; the minimal obstruction cycle is analogous to a minimal distributed execution witnessing impossibility.

6. **Homological error correction**  
   There is a conceptual kinship with syndrome decoding: a nontrivial cocycle is a syndrome, and greedy elimination extracts a minimal witness. This suggests future coding-theoretic interpretations of proof inconsistency.

---

## Suggested theorem decomposition

A strong file structure would be:

1. `ProofDependencyComplex` definitions
2. 0/1-cochains and coboundary
3. cocycles, coboundaries, `H1Trivial`
4. global section / extendability definition
5. theorem: `global_section_iff_every_cocycle_coboundary`
6. support of a cocycle
7. greedy elimination / support descent
8. theorem: existence of support-minimal nontrivial cocycle
9. theorem: support-minimal nontrivial cocycle contains certified obstruction cycle
10. semimodule of global sections
11. theorem: finite generation / minimal architecture duality via catalog result
12. instability/compression lower-bound corollary

---

## Concrete proof obligations

You should aim to prove lemmas of the following form:

```lean
theorem coboundary_is_cocycle
  (c : ZeroCochain K M) :
  IsCocycle (coboundary c)
```

```lean
theorem local_compatible_family_gives_zero_cocycle_obstruction
  (x : LocalCompatibleFamily K F) :
  ∃ z : OneCocycle K M, ObstructionOf x = z
```

```lean
theorem obstruction_zero_iff_globally_extendable
  (x : LocalCompatibleFamily K F) :
  ObstructionOf x = 0 ↔ ExtendableToGlobalSection x
```

```lean
theorem every_cocycle_coboundary_iff_all_local_families_extend
  :
  (∀ z : OneCocycle K M, IsCocycle z → IsCoboundary z) ↔
  GlobalExtendability K F
```

```lean
theorem greedy_step_preserves_cohomology_class
  (z : OneCocycle K M) :
  SameCohomologyClass z (greedyStep z)
```

```lean
theorem greedy_step_strictly_decreases_support
  (z : OneCocycle K M) :
  Reducible z →
  supportCard (greedyStep z) < supportCard z
```

```lean
theorem terminal_greedy_output_is_support_minimal
  (z : OneCocycle K M) :
  ¬ IsCoboundary z →
  SupportMinimalAmongNontrivial (greedyNormalForm z)
```

```lean
theorem minimal_nontrivial_support_contains_cycle
  (z : OneCocycle K M) :
  SupportMinimalAmongNontrivial z →
  ∃ C, SimpleObstructionCycle K C ∧ C.edgeSet ⊆ support z
```

```lean
theorem obstruction_cycle_lower_bounds_instability
  (C : ObstructionCycle K) :
  cycleWeight C ≤ ProofPredictionInstability K F
```

These can be staged. The first five are the essential formal core.

---

## Application keywords

sheaf cohomology, idempotent semimodule, tropical algebra, Boolean semiring, proof-state complex, theorem proving, neural proof prediction, adversarial robustness, global section, cocycle obstruction, minimal counterexample extraction, proof complexity, formal verification, abstract interpretation, cycle-space reconstruction, certified debugging, learnability/minimality duality, finite realization theory

---

## Deliverables

1. A Lean file implementing the finite combinatorial core in  
   `Bridges/AlgebraMachineLearningLogic/SheafProofStateDuality.lean`

2. At least one flagship theorem with a precise formal statement close to:
   - `global_section_iff_H1_trivial`, and
   - `exists_minimal_obstruction_of_nontrivial_H1`

3. Explicit use of `finite_separation_semimodule_realization_minimal` in the minimality section.

4. Minimal `sorry` count; prioritize a fully certified finite theorem over an over-ambitious abstraction.

5. A structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - weighted tropical obstruction theory for proof-search energy landscapes,
   - higher `H²` obstructions for compositional proof synthesis,
   - cohomological lower bounds for proof compression and replay,
   - extraction of adversarial proof perturbations from cocycle generators,
   - categorical semantics relating proof-state sheaves to distributed consistency and abstract interpretation.

Be bold: if this lands, it creates a new language in which theorem proving, learning, and logical inconsistency are all facets of the same finite cohomological object.

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

Research domain: Bridges
Research mode: prove
