## Assignment: Direction 2: Phase-Aware Lemma Synthesis for AI Theorem Provers

**Mode:** `prove` + `discover`

Aristotle, do not treat this as an engineering tweak to an ATP. Treat it as the beginning of a mathematical theory of *reasoning phase transitions*. The real target is not “a better prover,” but a formally certified architecture theorem: there exist structural regimes of theorem-search in which *lemma synthesis is provably the correct macroscopic control parameter*. If formalized cleanly, this opens a new field at the interface of proof complexity, learning theory, and verified AI systems.

Build directly on the catalog objects in:

- `Speculative/ProofCompression/Defs.lean`
  - `Phase`
  - `complexityScore`
  - `predictedPhase`
  - and especially the monotonicity theorem `predictedPhase_monotone`

Your task is to create a Lean 4 theory showing that phase-aware resource allocation is mathematically justified under explicit assumptions, and to extract from that theory a verified algorithmic policy for theorem proving.

---

## Central Vision

The breakthrough theorem family should show that once semantic complexity crosses a certified threshold, a prover that can synthesize and exploit intermediate lemmas has a monotone advantage over direct search, and that this advantage is stable under complexity growth. This would be a mathematically precise analogue of phase transitions in statistical physics: below threshold, direct proof search dominates; above threshold, structural decomposition dominates.

This is revolutionary because it reframes ATP as **phase-sensitive control** rather than fixed-strategy search. If you succeed, follow-on work becomes possible in:

- theorem-prover curriculum design,
- adaptive tactic scheduling,
- proof-compression-aware model training,
- verified AI agents that reason about their own search regime,
- analogies with free-energy minimization and renormalization in physics.

Application keywords: **automated theorem proving, proof complexity, phase transitions, adaptive search, lemma synthesis, semantic complexity, formal verification, curriculum learning, statistical physics of reasoning, program synthesis**

---

## Precise Formal Targets

You must introduce at least one genuinely new definition not already present in the catalog. Suggested core notion:

- `LemmaBenefit`: a structure capturing whether synthesized lemmas reduce effective search complexity.
- `PhaseAwarePolicy`: a strategy that branches on `predictedPhase`.
- `effectiveComplexity`: semantic complexity after admissible lemma decomposition.
- `CompressionThreshold`: a predicate expressing when lemma synthesis yields strict complexity reduction.

A possible Lean skeleton:

```lean
import Speculative.ProofCompression.Defs

open Classical

namespace PhaseAwareLemmaSynthesis

inductive SearchAction
| direct
| synthesizeLemmas
deriving DecidableEq, Repr

structure LemmaBenefit (α : Type) where
  baseComplexity : α → Nat
  reducedComplexity : α → Nat
  beneficial : Prop := ∀ x, reducedComplexity x ≤ baseComplexity x

def PhaseAwarePolicy {α : Type} (predictedPhase : α → Phase) : α → SearchAction :=
  fun x =>
    match predictedPhase x with
    | Phase.tractable => SearchAction.direct
    | _ => SearchAction.synthesizeLemmas

def effectiveComplexity {α : Type} (L : LemmaBenefit α) (useLemma : Bool) (x : α) : Nat :=
  if useLemma then L.reducedComplexity x else L.baseComplexity x

def CompressionThreshold {α : Type} (L : LemmaBenefit α) (k : Nat) : Prop :=
  ∀ x, k ≤ L.baseComplexity x → L.reducedComplexity x < L.baseComplexity x
```

You do **not** need to use exactly these names, but the file should contain a concept at this level of mathematical substance.

---

## Required Theorem Statements

You need at least 3 nontrivial theorems with multi-step proofs. Here is the theorem package I want you to aim for.

### Theorem 1: Monotone phase-aware action stability
This theorem turns catalog phase monotonicity into a control theorem.

**Mathematical statement:**
If complexity is monotone along an embedding of theorem states and `predictedPhase` is monotone, then once a problem instance is assigned to lemma synthesis, every more complex instance is also assigned to lemma synthesis.

**Lean-style target:**
```lean
theorem phaseAwarePolicy_monotone
  {α : Type} [Preorder α]
  (hphase : Monotone predictedPhase)
  (hcut : ∀ {x y : α}, x ≤ y →
    PhaseAwarePolicy predictedPhase x = SearchAction.synthesizeLemmas →
    PhaseAwarePolicy predictedPhase y = SearchAction.synthesizeLemmas) :
  Monotone (fun x => PhaseAwarePolicy predictedPhase x = SearchAction.synthesizeLemmas)
```

A more concrete and likely easier formulation is:
```lean
theorem phaseAwarePolicy_synthesis_upward_closed
  {α : Type} [Preorder α]
  (hmono : Monotone predictedPhase)
  {x y : α} (hxy : x ≤ y)
  (hx : PhaseAwarePolicy predictedPhase x = SearchAction.synthesizeLemmas) :
  PhaseAwarePolicy predictedPhase y = SearchAction.synthesizeLemmas
```

This should require `rcases` on phase values and use the catalog monotonicity theorem in a nontrivial way.

**Why it matters:** it certifies that phase-aware control is not brittle. It yields a mathematically robust “once hard, always structurally hard upward” principle.

---

### Theorem 2: Strict advantage above compression threshold
This is the core theorem. Prove that above a threshold, phase-aware lemma use strictly lowers effective complexity.

**Mathematical statement:**
Let `L` be a lemma-benefit model with strict compression above threshold `k`. If an instance is predicted to be beyond the tractable phase and its base complexity exceeds `k`, then the phase-aware policy achieves strictly lower effective complexity than direct search.

**Lean-style target:**
```lean
theorem effectiveComplexity_strictly_decreases_above_threshold
  {α : Type}
  (L : LemmaBenefit α)
  (k : Nat)
  (hthr : CompressionThreshold L k)
  {x : α}
  (hx : k ≤ L.baseComplexity x)
  (hphase : predictedPhase x ≠ Phase.tractable) :
  effectiveComplexity L true x < effectiveComplexity L false x
```

If necessary, formulate this with your own phase-aware boolean `usesSynthesis : α → Bool` extracted from `predictedPhase`.

This proof should use unfolding, case splitting on booleans/phases, and a `calc` chain with the threshold hypothesis. No trivial automation.

**Why it matters:** this is the first formal theorem saying that a phase-aware prover is not merely different, but *provably better under explicit structural assumptions*.

---

### Theorem 3: Resource allocation dominance theorem
Formalize the idea that for equal computational budget, a prover that allocates lemma-synthesis budget in the intractable phase dominates a direct-search-only policy on a complexity surrogate.

Define a simple abstract budget model:
- direct search success if complexity ≤ budget,
- synthesis success if reduced complexity ≤ budget.

Then prove:

```lean
def SolvesWithinBudget {α : Type} (c : α → Nat) (B : Nat) (x : α) : Prop :=
  c x ≤ B

theorem phaseAware_dominates_direct_above_threshold
  {α : Type}
  (L : LemmaBenefit α)
  (k B : Nat)
  (hthr : CompressionThreshold L k)
  {x : α}
  (hxk : k ≤ L.baseComplexity x)
  (hB : L.reducedComplexity x ≤ B)
  (hnot : ¬ L.baseComplexity x ≤ B) :
  SolvesWithinBudget (effectiveComplexity L true) B x ∧
  ¬ SolvesWithinBudget (effectiveComplexity L false) B x
```

This theorem should involve `constructor`, `by_contra` or negation handling, and explicit reasoning with inequalities.

**Why it matters:** this is the bridge from pure proof theory to ATP evaluation. It gives a clean formal surrogate for the experimental claim “same budget, more solved problems.”

---

## Cross-Domain Theorem Requirement

You must include at least one theorem that explicitly connects this framework to another domain.

### Recommended bridge: statistical physics / energy landscape
Introduce an abstract “reasoning energy” proportional to complexity, and show that lemma synthesis lowers energy in the hard phase.

Example definition:
```lean
def reasoningEnergy {α : Type} (c : α → Nat) (x : α) : Rat := c x
```

Then prove a theorem like:
```lean
theorem synthesis_lowers_reasoningEnergy
  {α : Type}
  (L : LemmaBenefit α)
  (k : Nat)
  (hthr : CompressionThreshold L k)
  {x : α}
  (hx : k ≤ L.baseComplexity x) :
  reasoningEnergy L.reducedComplexity x < reasoningEnergy L.baseComplexity x
```

This is intentionally simple mathematically, but conceptually powerful: it establishes a formal dictionary between ATP control and energy descent. From there, future work can define free energy, entropy of tactic distributions, or metastable proof states.

Alternative bridge domains:
- **Learning theory:** prove a monotonicity statement showing phase-aware scheduling induces a curriculum partition on theorem space.
- **Program synthesis:** define a decomposition graph and prove that lemma synthesis corresponds to a complexity-reducing abstraction step.
- **Software verification:** show that upward closure of the hard phase induces a safe escalation policy.

Do not make the cross-domain theorem cosmetic; it must have a real formal statement and proof.

---

## Proof Strategy Architecture

You must not rely on one proof idea. Develop at least 2–3 viable routes and choose the strongest.

### Strategy A: Order-theoretic control via monotonicity
1. Model theorem instances in a preorder induced by semantic complexity.
2. Use `predictedPhase_monotone` from the catalog to show upward closure of hard phases.
3. Lift this to policy monotonicity and then to dominance of synthesis actions.

**Why promising:** it reuses certified catalog infrastructure and yields robust theorems with minimal ad hoc assumptions.

### Strategy B: Compression-surrogate proof complexity
1. Define `LemmaBenefit` as an abstract compression witness.
2. Prove strict reduction in `effectiveComplexity` above a threshold.
3. Convert complexity reduction into budget dominance and solve-rate separation.

**Why promising:** this directly formalizes the scientific claim and naturally supports extraction of a verified algorithm.

### Strategy C: Energy/phase analogy from statistical physics
1. Define an energy functional on theorem states.
2. Show that tractable/intractable phases correspond to low/high energy regimes.
3. Prove synthesis acts as an energy-lowering transition in the hard phase.

**Why promising:** conceptually field-opening, especially for ARTICLE.md and future work.  
**Why secondary:** likely less central than A+B for the main Lean theorem package, but ideal for the cross-domain theorem.

**Recommendation:** Use A+B as the core proof spine; append C as the conceptual bridge theorem family.

---

## Stronger Scientific Conjecture to State Formally

Your current conjecture is good but still too empirical. Upgrade it into a mathematically structured hypothesis.

### Conjecture (Phase-Separated Solver Advantage)
There exists a threshold function `T : Nat → Nat` such that for any theorem family `F : Nat → α` with monotone complexity,
if `T n ≤ complexityScore (F n)` eventually, then a phase-aware prover with certified lemma synthesis solves infinitely many instances of `F` within budget `B n` that a direct-search prover of the same budget cannot solve.

This is falsifiable by constructing benchmark families and checking whether the predicted separation occurs.

A computational test:
1. Build theorem families stratified by `complexityScore`.
2. Measure direct-search solve rate vs. phase-aware solve rate under equal token/time budgets.
3. Reject the conjecture if no statistically significant separation appears above the certified threshold.

You do not need to prove this full asymptotic conjecture now, but you **must** state it in `FUTURE_DIRECTIONS.md` with a precise refutation criterion.

---

## Verified Algorithm Requirement

You must produce a verified algorithm, not just theorem statements.

### Target algorithm
Implement a certified decision procedure:

```lean
def chooseSearchAction {α : Type} (predictedPhase : α → Phase) : α → SearchAction
```

and prove:
- it selects direct search in the tractable phase,
- it selects lemma synthesis otherwise,
- if the threshold hypotheses hold, this choice weakly or strictly improves effective complexity.

You should also define a simple executable evaluator over synthetic theorem instances:
- compute complexity,
- query phase,
- choose policy,
- report expected complexity reduction.

This algorithm should be mirrored in `demo.py` so that one can interactively vary complexity and threshold and observe the induced policy.

---

## Experimental/Computational Deliverables

You must explicitly deliver **all** of the following:

1. **`FUTURE_DIRECTIONS.md`**  
   Include 3–5 testable scientific hypotheses, each falsifiable. Suggested examples:
   - **Hypothesis 1:** Above a complexity threshold predicted by `predictedPhase`, lemma synthesis increases solve rate by at least δ under equal budget.
   - **Hypothesis 2:** The gain from lemma synthesis is monotone in semantic complexity on curated theorem families.
   - **Hypothesis 3:** A curriculum that trains on tractable-phase instances first improves hard-phase performance more than random-order training.
   - **Hypothesis 4:** Energy-style complexity descent predicts proof-search success better than raw theorem length.
   - **Hypothesis 5:** The upward-closed hard phase is stable across Mathlib domains (algebra, analysis, combinatorics).

2. **`RESEARCH_PAPER.md`**  
   Must be standalone. It should explain:
   - the mathematical model of phase-aware proving,
   - the new definitions,
   - the main theorems,
   - why these theorems justify a new ATP architecture,
   - what experiments would validate or refute the theory.

3. **`ARTICLE.md`**  
   Scientific American style. Explain the idea that theorem proving may have “phases of matter,” and that above a threshold, inventing lemmas is like changing the state of the system rather than pushing harder.

4. **Verified algorithm / computational method**  
   The Lean development must include an executable search-policy selector with correctness theorems.

5. **`demo.py`**  
   Interactive demonstration:
   - input a complexity score and threshold,
   - display predicted phase,
   - show chosen action,
   - compare direct vs. synthesis effective complexity,
   - optionally simulate benchmark curves.

---

## Concrete Lean Expectations

Your Lean file should contain:

- at least one new structure/definition (`LemmaBenefit`, `PhaseAwarePolicy`, etc.),
- at least 3 substantial theorems,
- proofs using induction, `rcases`, `by_contra`, `field_simp`, or multi-step `calc`,
- no cheap theorem padding,
- minimal `sorry`.

Prefer theorem statements that can actually be proved with the existing catalog abstractions. If `predictedPhase` is too abstractly typed in the catalog, specialize to a surrogate theorem-instance type that carries a complexity measure and phase prediction map.

---

## A More Ambitious Theorem If Time Permits

If the library setup allows, prove a partition theorem:

```lean
theorem theoremSpace_partitioned_by_phase
  {α : Type}
  (pred : α → Phase) :
  Set.PairwiseDisjoint (fun p : Phase => {x | pred x = p})
```

and then show the synthesis region is upward closed under complexity order. This would make the theory geometrically clean: theorem space decomposes into certified phase strata.

Even better: define a “phase boundary” set and prove a no-return property under monotone complexity growth.

---

## What Would Make This Field-Opening

A merely decent result says: “here is a heuristic policy.”  
A field-opening result says: “there is a mathematically certified phase transition in proof search, and lemma invention is the correct order parameter above threshold.”

That is the bar.

Use the catalog theorem `predictedPhase_monotone` not as a citation ornament, but as the seed of a new theory of adaptive reasoning. Make the formal development strong enough that a future researcher could extend it toward:
- renormalization-style proof decomposition,
- entropy-regularized tactic policies,
- theorem-proving curricula,
- certified active learning for lemma selection.

Produce something that makes people realize ATP architecture can be studied with the same conceptual seriousness as phase transitions, control theory, and statistical learning.

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
