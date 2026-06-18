Soli Deo Gloria

## Assignment: Direction 5: Mechanism Design with Certified Multi-Criteria Approximation

**Mode:** `prove`

You are not being asked for an incremental variant of a known approximation theorem. You are being asked to formalize the beginning of a new theory: **certified multi-criteria truthful approximation mechanisms** for covering problems, where truthfulness and simultaneous approximation guarantees coexist in a single theorem. If this works, it opens a formal bridge between **mechanism design**, **multi-objective optimization**, and **certified approximation algorithms**.

The breakthrough target is to show that a mechanism can be truthful in the strategic sense while preserving **uniform approximation guarantees across an entire cone of linear objectives**, not merely for one chosen scalarization. This would be a foundational step toward a theory of **Pareto-aware truthful algorithms**.

Build explicitly on:

- `Catalog/Pythagorean/WeightedHypergraphTransversal.lean`
  - `threshold_simultaneous_multiobjective_bound`
  - `scalarized_minimizer_is_pareto`

Your mission is to define the right strategic objects, prove at least **3 substantial theorems**, and produce a **verified algorithmic mechanism** with computational evidence.

---

## Core Mathematical Vision

A hypergraph covering game has:
- a finite type of agents/vertices `V`,
- a finite family of hyperedges `E`,
- private nonnegative reported costs `b : V → ℚ`,
- one or more social objectives induced by different weight profiles on vertices.

A feasible allocation is a transversal / hitting set `S : Finset V` covering every edge. Existing catalog results certify simultaneous approximation for threshold rounding of LP-like relaxations. The new question is:

> Can one package such a simultaneous approximation rule into a **monotone / truthful mechanism**, so that no agent benefits by under- or over-reporting, while the selected integral transversal remains simultaneously approximately optimal for every linear objective in a prescribed class?

This is a mechanism-design version of robust Pareto approximation. If formalized cleanly, it opens:
- multi-objective procurement,
- public goods with heterogeneous fairness criteria,
- healthcare triage / covering under multiple welfare metrics,
- explainable auction design where one allocation is certified against many policy objectives at once.

---

## New Definitions You Should Introduce

You must define at least one genuinely new concept absent from the catalog. I recommend introducing all of the following.

### 1. Multi-criteria truthful allocation rule
A deterministic allocation rule `A` is truthful if each agent’s utility is minimized by truthful reporting under threshold payments, and its output satisfies simultaneous approximation over a family of linear objectives.

Suggested Lean-level structure:
```lean
structure MultiCriteriaCoverMechanism
    (V E : Type) [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E] where
  covers      : (E → Finset V) → (V → ℚ) → Finset V
  payment     : (E → Finset V) → (V → ℚ) → V → ℚ
  feasible    : Prop
  truthful    : Prop
  multiApprox : ℚ → Prop
```

This can later be specialized to a concrete threshold mechanism.

### 2. Objective cone / scalarization family
Formalize the family of admissible linear objectives as a finite or finitely-supported cone of nonnegative weight vectors:
```lean
def ObjectiveCone (V : Type) := Set (V → ℚ)

def InNonnegCone {V : Type} (C : ObjectiveCone V) : Prop :=
  ∀ w ∈ C, ∀ v, 0 ≤ w v
```

This is the right abstraction for “simultaneously d-approximate for every linear combination of agent costs.”

### 3. Bid-monotone transversal rule
Truthfulness in single-parameter domains is often driven by monotonicity. Define a covering analogue:
```lean
def BidMonotone
    {V E : Type} [Fintype V] [DecidableEq V]
    (A : (E → Finset V) → (V → ℚ) → Finset V) : Prop :=
  ∀ (inc : E → Finset V) (b b' : V → ℚ) (v : V),
    (∀ u ≠ v, b u = b' u) →
    b' v ≤ b v →
    v ∈ A inc b →
    v ∈ A inc b'
```

Interpretation: if agent `v` lowers its bid while others remain fixed, it should not lose. This is the exact structural property from which threshold payments can be derived.

### 4. Critical-value payment
Define the payment of an included agent as the supremal bid at which they remain selected, approximated in the finite rational grid if needed for formalization. If full supremum is technically heavy, define a **discrete critical payment** over a finite candidate set first, and state the continuous version as a conjectural extension.

---

## Precise Theorem Targets

You need at least **3 nontrivial theorems**. The following are the right targets.

### Theorem 1: Monotonicity of threshold-rounded scalarized covering
This is the strategic hinge. Show that the allocation rule obtained by scalarized optimization plus threshold rounding is bid-monotone.

Informal statement:

> Let `A` be the allocation rule that, for a nonnegative weight vector `w`, computes a scalarized fractional covering minimizer for bids `b`, then applies threshold rounding at certified threshold `τ`. If `v` is selected at bid profile `b`, and only `v` lowers its bid to obtain `b'`, then `v` remains selected. Hence `A` is bid-monotone.

A possible Lean 4 theorem signature:
```lean
theorem threshold_rounding_bid_monotone
    {V E : Type} [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    (inc : E → Finset V)
    (τ : ℚ)
    (A : (V → ℚ) → Finset V)
    :
    BidMonotone A := by
  sorry
```

More realistically, parameterize `A` by the scalarized fractional optimizer and threshold operator coming from the catalog:
```lean
theorem scalarized_threshold_allocation_bid_monotone
    {V E : Type} [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    (inc : E → Finset V)
    (w : V → ℚ)
    (hw : ∀ v, 0 ≤ w v)
    (τ : ℚ)
    (hτ : 0 < τ) :
    BidMonotone (fun b => thresholdAllocation inc w τ b) := by
  sorry
```

Why this matters: this is the mechanism-design analogue of your catalog approximation theorem. Without monotonicity, there is no truthful mechanism; with it, critical payments become available.

---

### Theorem 2: Truthfulness via critical payments
Once monotonicity is formalized, prove the strategic theorem.

Informal statement:

> For any bid-monotone allocation rule in the hypergraph covering setting, the associated critical-value payment rule makes truthful reporting a dominant strategy for every agent.

Suggested Lean signature:
```lean
theorem truthful_of_bidMonotone_criticalPayment
    {V E : Type} [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    (inc : E → Finset V)
    (A : (V → ℚ) → Finset V)
    (hmono : BidMonotone A) :
    DominantStrategyTruthful inc A (criticalPayment A) := by
  sorry
```

You will likely need to define:
```lean
def Utility (S : Finset V) (p : V → ℚ) (trueCost : V → ℚ) (v : V) : ℚ :=
  if v ∈ S then p v - trueCost v else 0

def DominantStrategyTruthful ... : Prop := ...
```

Why this matters: this theorem is the exact point where multi-objective approximation becomes a strategic theorem rather than a pure optimization theorem.

---

### Theorem 3: Simultaneous approximation survives truthful implementation
This is the breakthrough theorem. It should combine the catalog’s multi-objective threshold bound with your truthfulness theorem.

Informal statement:

> Assume the threshold-rounded allocation rule satisfies the catalog theorem `threshold_simultaneous_multiobjective_bound`. Then the induced critical-payment mechanism is truthful and returns a transversal whose cost is within factor `d` of optimum for every objective in the admissible cone of nonnegative scalarizations.

Suggested Lean signature:
```lean
theorem truthful_mechanism_simultaneous_multiobjective
    {V E : Type} [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    (inc : E → Finset V)
    (C : ObjectiveCone V)
    (d : ℚ)
    (hd : 1 ≤ d)
    (τ : ℚ)
    (hbound :
      ∀ w ∈ C, SimultaneousApproxBound inc w τ d)
    (hcone : InNonnegCone C) :
    ∃ M : MultiCriteriaCoverMechanism V E,
      M.truthful ∧ M.multiApprox d := by
  sorry
```

If existential packaging becomes unwieldy, prove the theorem for an explicitly defined mechanism:
```lean
theorem threshold_critical_mechanism_truthful_multiapprox
    ...
    : DominantStrategyTruthful inc (thresholdAllocation inc w τ)
        (criticalPayment (thresholdAllocation inc w τ))
      ∧
      ∀ w ∈ C, objectiveCost w (thresholdAllocation inc w₀ τ b)
        ≤ d * optimumObjectiveCost inc w b := by
  sorry
```

This theorem should explicitly invoke or adapt:
- `threshold_simultaneous_multiobjective_bound`
- `scalarized_minimizer_is_pareto`

Why this matters: this is the first formal statement that one allocation rule can be both **strategically stable** and **simultaneously near-optimal across many social criteria**.

---

## Cross-Domain Theorem Requirement

You must include at least one theorem connecting this to another domain. Do not make this cosmetic. A strong choice is to connect the objective cone to convex / order-theoretic Pareto geometry.

### Theorem 4: Truthful simultaneous approximation implies Pareto-certified outcome
Informal statement:

> If an allocation is simultaneously `d`-approximate for every nonnegative scalarization in a cone, then no feasible allocation strictly improves all cone-evaluated objectives by a factor better than `d`; hence the mechanism output is a certified approximate Pareto point in the dual cone order.

This bridges:
- mechanism design,
- convex geometry / dual cones,
- Pareto optimization.

Suggested Lean signature:
```lean
theorem multiapprox_implies_approx_pareto
    {V E : Type} [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    (C : ObjectiveCone V)
    (S : Finset V)
    (d : ℚ) :
    (∀ w ∈ C, objectiveCost w S ≤ d * optimalCost w) →
    ApproxParetoPoint C d S := by
  sorry
```

This theorem is scientifically important because it says the mechanism is not merely optimizing many scalarizations accidentally; it is selecting an allocation with a geometric Pareto certificate.

Possible second bridge: public economics / welfare theory. Show that if `C` contains all nonnegative distributions supported on a fairness subgroup, then simultaneous approximation yields subgroup fairness guarantees.

---

## Conjecture with Falsifiable Computational Prediction

State this explicitly in the Lean file as a comment block and in the paper.

### Conjecture: universal truthful simultaneous approximation for bounded-rank hypergraphs
For every rank-`r` hypergraph covering instance, there exists a deterministic bid-monotone threshold-rounded mechanism with critical payments achieving simultaneous approximation factor `r` for every nonnegative linear objective in the cone generated by agent cost vectors.

Computationally falsifiable prediction:
- Generate random rank-`r` hypergraphs.
- Compute the LP-based fractional solution.
- Apply threshold rounding.
- Compute critical-value payments.
- Test all single-agent deviations over a rational grid.
- If any deviation strictly improves utility, the conjecture fails for that instance.

A single profitable deviation is a disproof.

This is a good conjecture because it is:
- mathematically sharp,
- computationally testable,
- structurally tied to your theorems.

---

## Proof Strategy Architecture

You must not give a one-line proof sketch. Develop 2–3 serious routes.

### Strategy A: Monotonicity-first mechanism design route
This is the most promising.

1. **Define a bid-monotone threshold allocation rule.**
   Show that decreasing one bid can only improve that agent’s position in the scalarized LP optimum or preserve feasibility under threshold rounding.

2. **Extract critical payments.**
   Prove a Myerson-style lemma specialized to finite covering domains: bid-monotonicity implies dominant-strategy truthfulness under critical-value payments.

3. **Import simultaneous approximation from the catalog.**
   Apply `threshold_simultaneous_multiobjective_bound` to the same allocation rule and combine with truthfulness. Then use `scalarized_minimizer_is_pareto` to deduce Pareto certification.

Why most promising: it modularizes the problem into a strategic lemma and an optimization lemma, matching the existing catalog architecture.

---

### Strategy B: Direct primal-dual route
Potentially deeper, possibly harder in Lean.

1. Define the fractional covering LP and dual packing LP.
2. Show that threshold rounding preserves complementary-slackness-style inequalities up to factor `d`.
3. Use dual witnesses to define payments and prove no profitable deviation by contradiction (`by_contra`) from violated dual feasibility.

Why interesting: this could produce stronger payment formulas and a more intrinsic economic interpretation. Why harder: LP duality infrastructure may be heavier than needed unless the catalog already has enough support.

---

### Strategy C: Pareto cone route
Most visionary, but dependent on good abstractions.

1. Formalize the cone of scalarizations and induced preorder on allocations.
2. Show simultaneous approximation implies approximate Pareto minimality in this preorder.
3. Prove the allocation rule is monotone with respect to bid perturbations inside the cone order, then derive truthfulness.

Why interesting: this could generalize beyond hypergraph covering to broad classes of multi-objective mechanisms. Why risky: requires more abstract convex/order formalization.

---

## Recommended Theorem Order in the Lean File

1. Define:
   - `ObjectiveCone`
   - `BidMonotone`
   - `criticalPayment`
   - `DominantStrategyTruthful`
   - `ApproxParetoPoint`
   - `thresholdAllocation` or a wrapper around the catalog construction

2. Prove structural lemmas:
   - membership monotonicity under bid decrease,
   - threshold stability lemmas,
   - objective monotonicity for nonnegative weights.

3. Main theorem cluster:
   - `threshold_rounding_bid_monotone`
   - `truthful_of_bidMonotone_criticalPayment`
   - `truthful_mechanism_simultaneous_multiobjective`
   - `multiapprox_implies_approx_pareto`

At least three of these must use genuinely nontrivial proof patterns:
- `induction` over finite sets / hyperedges,
- `rcases` to unpack covering witnesses,
- `by_contra` for strategic deviation impossibility,
- `field_simp` if rational thresholds/payments are represented explicitly,
- multi-step `calc` for approximation inequalities.

---

## How to Build on the Catalog Theorems

### `threshold_simultaneous_multiobjective_bound`
Use this as the certified approximation engine. Do not merely cite it. Explain exactly how:
- your mechanism’s allocation rule is the same threshold-rounded object or a direct wrapper around it,
- therefore the selected integral transversal inherits simultaneous approximation guarantees for every admissible scalarization.

### `scalarized_minimizer_is_pareto`
Use this to upgrade scalarized optimality into a Pareto-style certification:
- if your mechanism allocation is selected from a scalarized minimizer and then rounded with controlled loss,
- then it is not just approximately good for one weight vector,
- it is approximately Pareto-efficient relative to the scalarization cone.

This is the conceptual bridge that elevates the result from “truthful approximation algorithm” to “truthful multi-criteria mechanism.”

---

## Lean 4 Type Signature Suggestions

These are not mandatory exact names, but you should aim for signatures of this flavor.

```lean
def objectiveCost {V : Type} [Fintype V] (w b : V → ℚ) (S : Finset V) : ℚ :=
  ∑ v in S, w v * b v
```

```lean
def isTransversal
    {V E : Type} [DecidableEq V]
    (inc : E → Finset V) (S : Finset V) : Prop :=
  ∀ e, (inc e ∩ S).Nonempty
```

```lean
def BidMonotone
    {V E : Type} [Fintype V] [DecidableEq V]
    (A : (V → ℚ) → Finset V) : Prop :=
  ∀ (b b' : V → ℚ) (v : V),
    (∀ u, u ≠ v → b u = b' u) →
    b' v ≤ b v →
    v ∈ A b →
    v ∈ A b'
```

```lean
def DominantStrategyTruthful
    {V : Type} [Fintype V] [DecidableEq V]
    (A : (V → ℚ) → Finset V)
    (p : (V → ℚ) → V → ℚ) : Prop :=
  ∀ (c b b' : V → ℚ) (v : V),
    (∀ u, u ≠ v → b u = b' u) →
    Utility (A b) (p b) c v ≥ Utility (A b') (p b') c v
```

```lean
theorem truthful_of_bidMonotone_criticalPayment
    {V : Type} [Fintype V] [DecidableEq V]
    (A : (V → ℚ) → Finset V)
    (hmono : BidMonotone A) :
    DominantStrategyTruthful A (criticalPayment A) := by
  sorry
```

```lean
theorem threshold_critical_mechanism_truthful_multiapprox
    {V E : Type} [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    (inc : E → Finset V)
    (C : ObjectiveCone V)
    (d τ : ℚ)
    (hd : 1 ≤ d)
    (hτ : 0 < τ)
    (hcone : InNonnegCone C)
    :
    DominantStrategyTruthful
      (thresholdAllocation inc defaultWeight τ)
      (criticalPayment (thresholdAllocation inc defaultWeight τ))
    ∧
    (∀ w ∈ C,
      objectiveCost w bids (thresholdAllocation inc defaultWeight τ bids)
        ≤ d * optimumObjectiveCost inc w bids) := by
  sorry
```

If `defaultWeight` is conceptually wrong, replace with a mechanism parameterized by a certified scalarization family or a canonical scalarization derived from the instance. What matters is that the theorem clearly binds truthfulness and simultaneous approximation in one statement.

---

## Application Keywords

Include these explicitly in comments, paper, and article:

- truthful approximation mechanism
- multi-objective mechanism design
- Pareto-certified allocation
- hypergraph covering games
- critical-value payments
- bid monotonicity
- LP rounding
- public goods provision
- combinatorial procurement
- algorithmic fairness
- healthcare resource allocation
- robust social choice
- convex duality
- Pareto geometry

---

## Scientific Significance

If successful, this direction establishes a new paradigm:

> **One mechanism, many objectives, no strategic regret.**

That is not a routine extension of VCG or LP rounding. It says we can certify that strategic agents interacting with a combinatorial mechanism produce an outcome that remains near-optimal simultaneously for an entire family of social objectives. This is exactly the kind of theorem that can seed a new field: **multi-criteria truthful optimization**.

Follow-on work it would enable:
- truthful Pareto approximation for facility location,
- fair procurement with subgroup guarantees,
- robust combinatorial auctions under policy uncertainty,
- approximate Walrasian design with cone-certified welfare guarantees,
- learning-augmented mechanisms where the learned objective can vary within a certified family.

---

## Mandatory Deliverables

You must produce **ALL** of the following:

1. **Lean file(s)** with the new definitions and at least **3 substantial theorems**, using deep proof tactics such as `induction`, `rcases`, `by_contra`, `field_simp`, and multi-step `calc`.
2. **A verified algorithm or computational method**, not just theorem statements:
   - implement the mechanism,
   - compute threshold or critical-value payments,
   - certify simultaneous approximation on finite instances.
3. **`demo.py`**:
   - generate random hypergraph covering instances,
   - run the mechanism,
   - test 1000 random strategic deviations,
   - print whether any profitable deviation was found,
   - display approximation ratios for multiple scalarizations.
4. **`RESEARCH_PAPER.md`**:
   - a standalone scientific paper,
   - readable without the code,
   - must explain the theorem, why it matters, proof ideas, experiments, and next questions.
5. **`ARTICLE.md`** in Scientific American style:
   - engaging and accessible,
   - explain the mathematical idea and its significance,
   - do **not** focus on formal verification machinery.
6. **`FUTURE_DIRECTIONS.md`** with **3–5 original research directions**.
   Each direction must include:
   - “**The key insight is...**”
   - “**Why now?**”
   At least one direction must bridge to a different domain, such as convex geometry, public economics, learning theory, or statistical physics.

---

## Final Standard

Do not settle for a toy theorem saying some finite search works. Do not hide behind decidability. Do not formalize a definition without forcing it to do conceptual work.

The target is a theorem a mechanism designer would find surprising:

> A threshold-rounded covering mechanism can be made truthful, and its output is certified simultaneously against an entire cone of welfare objectives.

That is worthy of Aristotle.

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
    "visualizations": [ { "name": "...", "code": "# matplotlib or plotly script, self-contained", "description": "What this visualizes" } ],
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
