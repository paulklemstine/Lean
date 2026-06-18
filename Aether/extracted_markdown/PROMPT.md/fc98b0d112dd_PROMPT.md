## Assignment: Direction 3: Sheaf-Theoretic Tropical Persistence

Prove new, non-trivial theorems that turn tropical persistence from a combinatorial construction into a sheaf-theoretic machine. Build explicitly on:

- `Pythagorean/TropicalBridge/Stability.lean`
- `Catalog/Pythagorean/TropicalBridge/FiltrationPersistence.lean`

and treat the existing `tropicalEventProfile`, stability bounds, and `TropicalFiltration` API as the certified finite/combinatorial shadow of a more geometric theory.

Your goal is not to repackage known persistence. Your goal is to show that the tropical event profile is the decategorified trace of a constructible tropical sheaf, and that stability emerges from functoriality rather than ad hoc estimates.

## Central Vision

The breakthrough is to exhibit tropical persistence data as a sheaf on the parameter line whose stalks are tropical algebraic invariants of the active subgraph, and then prove that the event profile/barcode-like object is recovered from a global-section or pushforward construction. If this works even in a finite, graph-theoretic, semimodule-valued setting, it creates a bridge from tropical persistence to:

- constructible sheaf theory,
- persistent sheaves,
- microlocal viewpoints on singular support,
- derived invariants of filtrations,
- and eventually tropicalized versions of the six-functor formalism.

This is not “another stability lemma.” It is a conceptual recoding of persistence itself.

## Precise Theorem Targets

You must formalize at least one new mathematical structure and prove at least 3 nontrivial theorems with multi-step proofs. Theorems should be stated at a level Lean can support now, even if the full derived-category slogan remains partially conjectural.

### New definitions to introduce

At minimum define a finite sheaf-like object on threshold parameters for a tropical filtration. Suggested core definitions:

1. `TropicalKernelSheaf`
   - a presheaf on threshold intervals with values in tropical semimodule data attached to active vertices/edges;
2. `ConstructibleThresholdSheaf`
   - a finite-constructible condition saying stalk data is locally constant away from finitely many critical values;
3. `SheafEventProfile`
   - a global invariant extracted from the presheaf/sheaf and compared to `tropicalEventProfile`.

If full sheaf axioms over arbitrary opens are too heavy, work with the Alexandrov topology on threshold indices or with interval-restricted finite covers. A finite poset sheaf is enough for a field-opening first theorem.

## Exact theorem statements to aim for

### Theorem 1: Constructibility of the tropical kernel sheaf
For any finite filtration with finitely many critical thresholds, the tropical kernel assignment is constant on each open interval between consecutive critical values.

Informal statement:
> Let `f : TropicalFiltration α` with finite critical set `C = {c₀ < ⋯ < cₙ}`. Define `F(t)` to be the tropical kernel object of the active subgraph at threshold `t`. Then for every interval `(cᵢ, cᵢ₊₁)`, the stalks `F(s)` and `F(t)` are canonically isomorphic for all `s,t` in that interval.

Lean-oriented target signature:
```lean
theorem tropicalKernelSheaf_locallyConstant_between_critical
  {α : Type _} [Fintype α] [DecidableEq α]
  (filt : TropicalFiltration α)
  (crit : Finset ℝ)
  (hcrit : crit = filt.criticalValues)
  {s t : ℝ}
  (hs : s ∉ crit)
  (ht : t ∉ crit)
  (hseg : sameCriticalGap crit s t) :
  TropicalKernelData filt s ≃ TropicalKernelData filt t
```

Here `sameCriticalGap crit s t` is a new definition meaning no critical value lies strictly between `s` and `t`. If equivalence is too ambitious, prove equality of active vertex sets first, then transport to equality/equivalence of kernel data.

### Theorem 2: Event profile recovery from sheaf jumps
The tropical event profile is determined by the discontinuity locus of the sheaf and can be computed as the sum of jump contributions across critical thresholds.

Informal statement:
> The event profile at threshold `t` equals the cumulative tropical rank jump of the sheaf across all critical values ≤ `t`.

Lean-oriented target signature:
```lean
theorem tropicalEventProfile_eq_cumulativeSheafJump
  {α : Type _} [Fintype α] [DecidableEq α]
  (filt : TropicalFiltration α) :
  ∀ t : ℝ,
    tropicalEventProfile filt t =
      ∑ c in filt.criticalValues.filter (fun x => x ≤ t),
        sheafJump filt c
```

This theorem is revolutionary because it converts a persistence observable into a constructible-sheaf counting formula. Even if `sheafJump` is defined combinatorially at first, the theorem establishes the correct architecture for derived generalization.

### Theorem 3: Sheaf-theoretic stability bound
If two filtrations are uniformly close, then the corresponding sheaf jump profiles are interleaved, and hence their event profiles differ by a controlled amount.

Informal statement:
> If `filt₁` and `filt₂` differ by at most `ε` in threshold data, then their tropical kernel sheaves are `ε`-interleaved on the threshold line, implying the event profiles satisfy the known stability estimate.

Lean-oriented target signature:
```lean
theorem sheafEventProfile_stability
  {α : Type _} [Fintype α] [DecidableEq α]
  (filt₁ filt₂ : TropicalFiltration α)
  (ε : ℝ) (hε : 0 ≤ ε)
  (hclose : filtrationSupDist filt₁ filt₂ ≤ ε) :
  ∀ t : ℝ,
    |SheafEventProfile filt₁ t - SheafEventProfile filt₂ t| ≤ stabilityBound filt₁ filt₂ ε
```

This should build on the existing stability theorem in `Pythagorean/TropicalBridge/Stability.lean`; do not reproach from zero. Instead, prove that your sheaf profile coincides with the existing profile, then inherit/transport stability.

### Theorem 4: Cross-domain bridge to combinatorial topology or algebra
At least one theorem must connect the sheaf object to another domain. The strongest accessible option is graph topology / poset sheaves / Möbius inversion.

Suggested statement:
> For path graphs, the sheaf jump at a critical threshold equals the change in the number of active connected components (or another graph invariant already formalized). For cycle graphs, the total jump sum detects the first tropical cycle obstruction.

Lean-oriented target signature:
```lean
theorem sheafJump_pathGraph_eq_componentDrop
  (n : ℕ) :
  ∀ t : ℝ,
    sheafJump (pathGraphFiltration n) t =
      componentJump (pathGraphFiltration n) t
```

Alternative algebraic bridge:
```lean
theorem cumulativeSheafJump_eq_mobiusInversion
  {P : Type _} [Fintype P] [PartialOrder P] [LocallyFiniteOrder P]
  (filt : PosetIndexedTropicalFiltration P) :
  cumulativeJump filt = mobiusTransform (localStalkRank filt)
```

This would be a serious bridge to incidence algebras and combinatorial sheaf theory.

## Most promising proof architecture

### Strategy A: Finite-poset sheaf model on critical strata
This is likely the best route.

1. Replace the real line by the finite ordered set of strata determined by `criticalValues`.
   - Each stratum is either a critical point or an interval between consecutive critical values.
   - Define the sheaf/presheaf on this finite poset.
2. Show the active subgraph is constant on each open stratum.
   - This should follow from threshold monotonicity and “no critical value crossed.”
3. Define stalk/kernel data on each stratum and restriction maps by monotonicity.
4. Prove the event profile is exactly the cumulative jump across point strata.
   - This is where existing `tropicalEventProfile` lemmas should be reused.
5. Transport the known stability theorem through the identification.

Why this is most promising:
- It avoids hard topological sheaf infrastructure.
- It matches Lean well: finite posets, `Finset`, monotone maps, cumulative sums.
- It still captures the mathematical essence of constructibility and pushforward.

### Strategy B: Interval presheaf on ℝ with explicit gluing over finite covers
Use actual interval-indexed opens, but only for finite unions relevant to the filtration.

1. Define `F(U)` for intervals/unions as tropical kernel data stable throughout `U`.
2. Restriction maps come from inclusions of active sets.
3. Prove a finite sheaf condition for covers subordinate to the critical decomposition.
4. Show global sections over `Iic t` recover the event profile or cumulative rank.

Why it is interesting:
- Closer to genuine sheaf theory.
- Gives a cleaner conceptual story for `RESEARCH_PAPER.md`.

Why it is harder:
- More topological bookkeeping in Lean.
- You may need to simulate sheaf axioms rather than use a full sheaf library.

### Strategy C: Derived-shadow approach via exact-difference sequences
If the kernel object is hard to package as a sheaf, define a difference complex-like invariant.

1. Introduce a two-step object `K_before → K_after` at each critical threshold.
2. Define the jump as a cokernel/rank-defect analogue in tropical semimodule language.
3. Sum these local defects to reconstruct the profile.
4. Interpret this as the degree-0 shadow of a derived pushforward.

Why this matters:
- It gives the “derived” flavor without requiring actual derived categories.
- It may be the best route to a falsifiable conjecture about higher derived jumps.

## Build explicitly on catalog theorems

You must identify and use the exact existing API around:

- `tropicalEventProfile`
- any monotonicity lemmas for filtrations/active sets,
- any stability inequalities already proven in `Stability.lean`,
- `TropicalFiltration` constructors and threshold semantics from `FiltrationPersistence.lean`.

Do not merely cite them. Explain in comments and in `RESEARCH_PAPER.md` how each theorem is being lifted:
- existing event-profile lemmas become the decategorified output;
- existing stability becomes a corollary of sheaf-profile identification;
- existing finite critical-value control becomes constructibility.

## Required conjecture with computational test

State at least one falsifiable conjecture with a concrete disproof protocol.

### Conjecture A: Path/cycle derived concentration
> For path graphs and cycle graphs, all higher tropical sheaf-jump obstructions vanish outside critical thresholds, and the full event profile is determined by degree-0 jump data.

Lean-friendly conjecture skeleton:
```lean
conjecture path_cycle_higherJump_vanishes
  (G : SimpleGraph α)
  (hG : IsPathGraph G ∨ IsCycleGraph G)
  (filt : TropicalFiltration α) :
  ∀ t : ℝ, HigherSheafJump filt t = 0
```

Computational test:
- construct explicit filtrations for path graphs `P_n` and cycle graphs `C_n`;
- compute stalk data and jump data at all critical thresholds;
- search for a threshold where a nonzero `HigherSheafJump` appears.

### Conjecture B: Tropical sheaf stability is sharp on cycles
> On cycle graphs, the sheaf-theoretic stability constant equals the maximal multiplicity of simultaneous critical events.

Test:
- generate weighted cycle filtrations;
- perturb weights by `ε`;
- compare observed profile discrepancy with predicted bound;
- disprove by finding a smaller universal constant.

## Concrete path-graph and cycle-graph deliverable

You must explicitly construct the sheaf for:
- path graphs,
- cycle graphs,

and verify:
1. the stalk at threshold `t` matches the tropical kernel dimension/data of the active graph;
2. the sheaf is constructible with jumps only at entrance times;
3. the cumulative jumps reproduce the event profile.

This is mandatory. It is the testbed that turns the conjectural geometry into executable mathematics.

## Cross-domain connections to emphasize

You must include at least one theorem and one discussion section tying this work to a different domain. Strong options:

- **Microlocal analysis:** critical thresholds behave like singular support on the parameter line; jump loci are 1D shadows of microsupport.
- **Combinatorial sheaf theory:** finite-poset sheaves on the critical stratification provide a graph-theoretic incarnation of constructible sheaves.
- **Incidence algebras / Möbius inversion:** cumulative jump formulas resemble inversion on the critical poset.
- **Statistical physics:** threshold activation resembles phase transitions; sheaf jumps are order parameters.
- **Topological data analysis:** recasts barcode-like invariants as sheaf pushforwards, suggesting higher-dimensional and multiparameter tropical persistence.

Application keywords:
`tropical persistence`, `constructible sheaves`, `persistent homology`, `microlocal analysis`, `finite poset sheaves`, `graph filtrations`, `interleavings`, `Möbius inversion`, `phase transitions`, `semiring linear algebra`

## Lean 4 formalization targets

Aim to create definitions/theorems with signatures in this spirit:

```lean
structure TropicalKernelSheaf (α : Type _) [Fintype α] [DecidableEq α] where
  filt : TropicalFiltration α
  stalk : ℝ → Type _
  res : ∀ {s t : ℝ}, s ≤ t → stalk t → stalk s
  res_id : ∀ t, res (show t ≤ t from le_rfl) = id
  res_comp :
    ∀ {r s t : ℝ} (hrs : r ≤ s) (hst : s ≤ t),
      res (le_trans hrs hst) = res hrs ∘ res hst
```

If `Type`-valued stalks are too ambitious, use `ℕ`-valued rank data first:

```lean
structure TropicalRankSheaf (α : Type _) [Fintype α] [DecidableEq α] where
  filt : TropicalFiltration α
  rankAt : ℝ → ℕ
  mono : Monotone rankAt
  critical : Finset ℝ
  locallyConstant_off_critical :
    ∀ {s t : ℝ}, sameCriticalGap critical s t → rankAt s = rankAt t
```

Then prove:

```lean
theorem SheafEventProfile_eq_rankSheaf
  {α : Type _} [Fintype α] [DecidableEq α]
  (S : TropicalRankSheaf α) :
  ∀ t : ℝ, SheafEventProfile S t = S.rankAt t
```

and

```lean
theorem rankSheaf_constructible
  {α : Type _} [Fintype α] [DecidableEq α]
  (filt : TropicalFiltration α) :
  ∃ S : TropicalRankSheaf α, S.filt = filt
```

Use induction over the sorted list of critical values, `rcases` on threshold trichotomies, `by_contra` for no-jump/no-critical contradictions, and multi-step `calc` blocks to relate cumulative sums to event profiles.

## Mandatory proof-style requirements

Your file must include at least 3 theorems whose proofs genuinely use deep tactics such as:
- induction on the ordered critical-value list,
- `rcases` on cases of threshold position,
- `by_contra` to force existence of a critical crossing,
- `field_simp` if any rational threshold formulas appear,
- multi-step `calc` chains transporting equalities/inequalities.

Do not satisfy the assignment with definitional equalities.

## Deliverables

You must produce ALL of the following:

1. `FUTURE_DIRECTIONS.md`
   - 3–5 original research directions.
   - Each direction must include the exact sentences:
     - `The key insight is ...`
     - `Why now? ...`
   - At least one direction must bridge to a different domain such as microlocal analysis, statistical physics, or incidence algebras.

2. `RESEARCH_PAPER.md`
   - A standalone scientific document.
   - It must explain:
     - the new sheaf structure,
     - the precise theorems,
     - why the sheaf viewpoint conceptually explains stability,
     - what higher-dimensional generalizations become possible.
   - A reader with no code access must understand the discovery.

3. `ARTICLE.md`
   - Scientific American style.
   - Explain the mathematical ideas and significance to a broad audience.
   - Do **not** focus on formal verification machinery.

4. A verified algorithm or computational method
   - Compute the critical stratification, stalk/rank data, and cumulative sheaf jumps.
   - It must be connected to your theorem statements, not a separate toy script.

5. `demo.py`
   - Interactive demonstration on path graphs and cycle graphs.
   - Show critical thresholds, stalk values, jump profile, and comparison with `tropicalEventProfile`.

## Final charge

Do not stop at “there exists a presheaf.” Prove that the tropical persistence observable already present in the catalog is the visible shadow of a constructible sheaf on the threshold line. If you can make stability a consequence of sheaf interleaving rather than a standalone inequality, you will have created a new entry point from tropical semiring persistence into mainstream geometry.

The field-opening move is this: convert tropical persistence from a list of threshold events into a functorial object with singular support, jumps, and pushforward. Even a finite-poset version, if done cleanly and proved sharply, is a genuine conceptual advance.

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
- **Visualization scripts** — Produce up to 3 self-contained Python scripts
  that visually illustrate the core mathematical concepts discovered. Use
  matplotlib for static plots (heatmaps, curves, surfaces) or plotly for
  interactive charts. Available libraries: numpy, matplotlib, plotly.
  If using matplotlib, the script must call plt.savefig() — the system
  captures the output as a PNG. If using plotly, assign the figure to a
  variable named `fig` — the system captures fig.to_html(). Each script
  must include a comment header explaining what it visualizes and why.
  **CRITICAL: Each visualization script MUST be a single, fully self-contained
  file. Do NOT import from any local modules (algorithms.py, demo.py, etc.).
  Instead, inline all needed functions and classes directly in the script.
  The browser runtime (Pyodide) has no access to local .py files.**
- **Interactive HTML demos** — Produce up to 3 self-contained HTML snippets
  (with inline CSS/JS, no external dependencies) that demonstrate the
  mathematical concepts interactively — sliders, animations, dynamic SVG,
  or canvas drawing. Each demo must be a complete <div> fragment that
  works when inserted into a page. No <html>, <head>, or <body> tags —
  just the content div with its inline styles and scripts.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses, including 1-2 grand_challenge paradigm-shifting conjectures
and 2-3 solid extensions building directly on Catalog theorems.
MUST begin with a ## Synthesis section tying all directions together.
Each direction must use the structured format with explicit fields:
**Conjecture**, **Test**, **Impact**, **Catalog References**,
**Proof Strategy**, **Domain Bridges**, **Lineage**, **Ambition**.
Reference specific Catalog theorems by file path. Every hypothesis
must be daring enough to matter and specific enough to fail.


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
    "visualizations": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files. Inline all needed functions directly.", "description": "What this visualizes" } ],
    "interactive_demos": [ { "name": "...", "html": "<div>...</div>", "description": "What this demonstrates" } ],
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

Research domain: Pythagorean
Research mode: prove
