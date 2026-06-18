## Assignment: Iterate in `prove` + `sorry_fill` mode

This cycle should not merely “decompose failed proof attempts into smaller lemmas.” It should turn modular decomposition itself into a mathematically sharp theorem schema. The existing catalog already whispers the right synthesis:

- `modular_interface_bound` in `Logic/HolographicProofs.lean`
- `evidence_upper_bound` in `Logic/AdvancedTheorems.lean`
- `expert_regret_bound_nonneg` in `Logic/AdversarialPrediction.lean`
- `r2_multiplicative_structure` in `Logic/LightNumberLine.lean`
- `conformal_preserves_structure` in `Logic/UniverseIdempotent.lean`

The breakthrough opportunity is to prove that **modular composition preserves quantitative control** across logic, evidence aggregation, and online prediction. That is: local bounds glue into global bounds, and the gluing principle is itself formalized.

This is not an incremental extension. If you succeed, you open a reusable formal paradigm for:
- proof-carrying modular AI systems,
- compositional regret/evidence certification,
- holographic interfaces between local and global reasoning,
- and ultimately a library of “category-theoretic inequalities” in Lean.

## Primary Theorem Target

Define a compositional notion of module cost on finite systems and prove that global evidence/regret is bounded by the sum of local interface contributions.

A precise target theorem:

```lean
theorem modular_evidence_sum_bound
    {n k : ℕ}
    (b : BState n)
    (l : Fin n → ℝ)
    (w : Fin k → ℝ)
    (hk : 0 < k) :
    evidence_upper_bound b l ≤
      (∑ i : Fin k, |w i|) + modular_interface_bound k n
```

This exact statement may require adaptation depending on the codomain and shape of `modular_interface_bound` and `evidence_upper_bound`. If their return types are not directly ordered reals, define an intermediary real-valued complexity/evidence functional and prove a bridge theorem first. The essential content is:

> **For every finite modular decomposition, the global evidence is controlled by the aggregate local weights plus the interface complexity term.**

A second, sharper theorem should connect this to adversarial prediction:

```lean
theorem modular_regret_control
    (n T k : ℕ)
    (hn : 0 < n)
    (hT : 0 < T)
    (hk : 0 < k) :
    0 ≤ expert_regret_bound_nonneg n T hn hT ∧
    expert_regret_bound_nonneg n T hn hT ≤ modular_interface_bound k T + modular_interface_bound k n
```

If `expert_regret_bound_nonneg` is itself a proposition proving nonnegativity rather than a real-valued quantity, then the correct move is to define a real-valued regret functional `RegretBound n T` and prove:

```lean
theorem modular_regret_nonneg_and_bounded
    (n T k : ℕ)
    (hn : 0 < n)
    (hT : 0 < T)
    (hk : 0 < k) :
    0 ≤ RegretBound n T ∧
    RegretBound n T ≤ modular_interface_bound k T + modular_interface_bound k n
```

## More Ambitious Cross-Domain Bridge Theorem

Use `r2_multiplicative_structure` as a structural analogy: multiplicative composition in arithmetic should mirror additive/interface composition in complexity. Formalize a transfer principle:

```lean
theorem multiplicative_to_modular_transfer
    (a b c d : ℤ) (k : ℕ) :
    ∃ C : ℝ, 0 ≤ C ∧
      C ≤ modular_interface_bound k (Int.natAbs (a*c - b*d) + 1)
```

This is intentionally bold: the point is to manufacture a bridge between arithmetic composition laws and modular proof interfaces. Even if this exact theorem is too optimistic, produce a corrected version with a clean formal statement. The real objective is a new dictionary:
- arithmetic multiplicativity ↔ compositional proof architecture,
- conformal invariance ↔ structure-preserving transformations of proof state,
- evidence aggregation ↔ energy/partition bounds in statistical mechanics.

## Lean 4 Type-Signature Guidance

Because the catalog theorem signatures are partially elided, you should inspect the exact declarations and then instantiate one of these formal patterns.

### Pattern A: Real-valued compositional upper bound
```lean
theorem modular_composition_upper_bound
    {ι : Type} [Fintype ι]
    (local global : ι → ℝ)
    (hlocal : ∀ i, local i ≤ global i) :
    (∑ i, local i) ≤ ∑ i, global i := by
  ...
```

### Pattern B: Finite decomposition bound over `Fin k`
```lean
theorem fin_modular_bound
    (k : ℕ)
    (f g : Fin k → ℝ)
    (hfg : ∀ i, f i ≤ g i) :
    (∑ i : Fin k, f i) ≤ ∑ i : Fin k, g i := by
  ...
```

### Pattern C: Structure-preserving transport of bounds
Building on `conformal_preserves_structure`:
```lean
theorem transported_modular_bound
    (t : ℝ)
    (hconf : conformal_preserves_structure t)
    {k : ℕ}
    (f g : Fin k → ℝ)
    (hfg : ∀ i, f i ≤ g i) :
    (∑ i : Fin k, f i) ≤ ∑ i : Fin k, g i := by
  ...
```

This may look elementary, but the innovation is not the inequality itself — it is the **abstraction barrier**: once these transport lemmas exist, many previously brittle proof attempts can be rebuilt compositionally.

## Immediate `sorry_fill` Priority

The prompt explicitly identifies cold-start priority targets:
- `CarmichaelComposite`
- `Fib_gcd_identity`

You should attack them if they already exist as theorem stubs. Locate exact file paths and theorem names. If found, fill them first. Especially:

### Target 1: Fibonacci gcd identity
Ideal statement:
```lean
theorem Fib_gcd_identity (m n : ℕ) :
    Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n)
```

This is a classic theorem but still a strong library bridge theorem if missing in the local codebase. It unlocks algebraic-number-theoretic interfaces and gives a high-value benchmark for modular decomposition techniques.

### Target 2: Carmichael composite witness theorem
If `CarmichaelComposite` is a stub, likely desired shape:
```lean
theorem CarmichaelComposite :
    ∃ n : ℕ, Nat.Composite n ∧
      ∀ a : ℕ, Nat.Coprime a n → a^(n-1) ≡ 1 [MOD n]
```

Or a concrete witness version:
```lean
theorem Carmichael_561 :
    Nat.Composite 561 ∧
    ∀ a : ℕ, Nat.Coprime a 561 → a^(560) ≡ 1 [MOD 561]
```

If the general theorem is too large for one cycle, prove the explicit `561` witness. This is not just a number theory exercise: it provides a canonical example where local prime-factor behavior composes into a deceptive global pseudoprime property — exactly the modularity theme of this cycle.

## Proof Strategy Architecture

### Strategy A: Build a compositional inequality toolkit first
1. Prove generic finite-sum monotonicity lemmas over `Fin k`, `Finset`, and functions `ι → ℝ`.
2. Bridge catalog theorems into this language by extracting real-valued corollaries from `modular_interface_bound`, `evidence_upper_bound`, and regret bounds.
3. Derive the target modular evidence/regret theorem as a one-line composition of these generic lemmas.

Why this is promising:
- It minimizes brittle theorem-specific reasoning.
- It creates reusable infrastructure for future cycles.
- It is the best route if catalog theorem codomains are slightly awkward.

### Strategy B: Interpret existing theorems as energy bounds
1. Treat `evidence_upper_bound` as a partition-function style bound.
2. Treat `modular_interface_bound` as an interaction energy across module boundaries.
3. Prove a “free energy is subadditive under modular gluing” theorem.

Why this is visionary:
- It connects proof theory to statistical mechanics.
- It suggests future formalization of Gibbs-style semantics for evidence and regret.
- It may reveal sharper inequalities than naive summation.

This is the most conceptually revolutionary strategy.

### Strategy C: Structure transport via invariance
1. Use `conformal_preserves_structure` to formulate a generic “bound preserved under structure-preserving transforms” lemma.
2. Push modular/evidence bounds through these transforms.
3. Show that proof decomposition remains valid after reparameterization or normalization.

Why this matters:
- It opens a geometry of proof systems.
- It suggests renormalization-group analogies: coarse-graining proofs without losing certification.
- It could become the seed of a formal theory of proof universality classes.

## Cross-Domain Connections You Should Explicitly Exploit

### 1. Statistical mechanics
Interpret:
- evidence bounds as partition-function bounds,
- regret as dissipated work,
- modular interfaces as interaction energies.

Possible future theorem schema:
```lean
theorem modular_free_energy_subadditive ...
```

### 2. Number theory
Use `r2_multiplicative_structure` and the Carmichael/Fibonacci targets to show:
- multiplicative arithmetic structure composes globally from local prime data,
- just as proof/evidence structure composes from local interfaces.

This is a profound analogy, not a decorative one.

### 3. Geometry / conformal invariance
Use `conformal_preserves_structure` to motivate invariance of proof complexity under admissible transformations:
- normalization,
- scaling,
- coordinate changes in state spaces.

### 4. Online learning / adversarial prediction
Leverage `expert_regret_bound_nonneg` to prove that modular decomposition does not destroy no-regret guarantees. This could become a theorem about hierarchical expert systems.

## Concrete Lemma Decomposition

You should likely create and prove some of the following smaller lemmas.

```lean
theorem sum_abs_nonneg {k : ℕ} (w : Fin k → ℝ) :
    0 ≤ ∑ i : Fin k, |w i| := by
  ...

theorem finset_sum_le_sum {ι : Type} [Fintype ι]
    (f g : ι → ℝ) (h : ∀ i, f i ≤ g i) :
    (∑ i, f i) ≤ ∑ i, g i := by
  ...

theorem modular_plus_nonneg
    (k b : ℕ) :
    0 ≤ modular_interface_bound k b := by
  ...
```

If `modular_interface_bound` is not obviously nonnegative, prove a weaker theorem giving a lower bound or monotonicity in one argument:
```lean
theorem modular_interface_bound_mono_right
    (k : ℕ) {b₁ b₂ : ℕ} (h : b₁ ≤ b₂) :
    modular_interface_bound k b₁ ≤ modular_interface_bound k b₂ := by
  ...
```

That monotonicity theorem alone could become the key compositional primitive.

## What Would Count as a Breakthrough Here

A theorem of the form

> **global certified behavior ≤ sum of local certified behaviors + interface penalty**

is a universal law. If formalized cleanly in Lean and tied to the catalog theorems, it becomes a template for:
- modular verification of AI systems,
- compositional theorem proving,
- scalable formal epistemology,
- and a future theory of proof thermodynamics.

This is the field-opening direction: not another isolated bound, but a **formal science of compositional certification**.

## Application Keywords

- compositional verification
- modular proof systems
- online learning
- adversarial regret
- statistical mechanics
- partition functions
- conformal invariance
- arithmetic composition
- holographic interfaces
- certified AI
- proof thermodynamics
- hierarchical experts
- finite-sum inequalities
- formal epistemology

## Deliverables

1. Lean 4 theorem(s) implementing at least one primary target above.
2. Supporting lemmas with minimized `sorry`.
3. If present, fill `CarmichaelComposite` and/or `Fib_gcd_identity` exactly in place.
4. A `FUTURE_DIRECTIONS.md` containing 3–5 concrete next steps, each with:
   - theorem statement,
   - anticipated Lean types,
   - proof strategy,
   - cross-domain significance.

## Required FUTURE_DIRECTIONS.md items

You must include items at this level of specificity, for example:

1. **Hierarchical regret composition theorem**  
   Prove a bound showing regret of a tree of experts is bounded by the sum of node-local regrets plus depth-weighted interface terms.

2. **Modular free energy theorem**  
   Formalize evidence as a log-partition quantity and prove subadditivity under gluing of finite modules.

3. **Arithmetic-proof correspondence theorem**  
   Use `r2_multiplicative_structure` to derive a compositional invariant linking multiplicative decompositions with modular proof certificates.

4. **Conformal transport of certification**  
   Show structure-preserving transformations carry certified bounds to certified bounds in a generalized state space.

5. **Carmichael holography**  
   Formalize how local congruence data on prime-power factors composes into global pseudoprime behavior, then abstract this as a proof-interface theorem.

Be bold. The right result this cycle is not “another lemma.” It is the first law of modular certified reasoning.

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

Research domain: Logic
Research mode: prove
