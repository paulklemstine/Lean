Soli Deo Gloria

## Assignment: Direction 1 — Hennessy–Milner Completeness via Finite Distinguishing Formulas

**Mode:** `prove`

Prove a genuinely new, nontrivial completeness theorem in the existing Yoneda–bisimulation framework: for **image-finite** labeled transition systems, Hennessy–Milner equivalence coincides with bisimilarity. This is not a routine extension. It is the decisive missing bridge between **logical indistinguishability**, **coalgebraic behavioral equivalence**, and **algorithmic partition refinement** in the standard nondeterministic setting.

Build directly on:

- `Pythagorean/YonedaBisimulation/Correspondence.lean`
- especially the catalog theorems corresponding to:
  - `bisimilar_implies_hm_equiv`
  - `hm_box_iff`

Your task is to formalize the converse direction under image-finiteness by constructing **finite distinguishing conjunctions**. The heart of the proof is not the statement itself, but the architecture: from local non-matchability of successors, extract a finite family of distinguishing formulas, assemble them into a single conjunction, and force a contradiction with HM-equivalence.

This is the classical Hennessy–Milner theorem, but in this formal ecosystem it becomes something larger: a certified interface between modal logic, coinduction, and finite-state algorithmics. If done cleanly, this opens the door to verified minimization algorithms, modal characteristic formulas, and complexity-theoretic analyses of behavioral equivalence.

---

## Core Theorem Target

Let `Act` be the action type, `State` the state type, and let the LTS transition relation be given by something like:

```lean
step : State → Act → State → Prop
```

Assume the existing file already defines HM formulas, satisfaction, and HM-equivalence.

You should introduce a new image-finiteness structure, with **computational content**:

```lean
structure ImageFiniteLTS (State Act : Type _) where
  step : State → Act → State → Prop
  succs : State → Act → Finset State
  mem_succs_iff : ∀ s a t, t ∈ succs s a ↔ step s a t
```

If the ambient development already packages LTSs differently, adapt the signature, but preserve this finitary witness principle.

Then define HM-equivalence and bisimulation-compatible transfer predicates in the style of the existing development.

### Precise theorem statement

The central theorem should have a Lean shape essentially of the following form:

```lean
theorem hm_equiv_is_bisimulation_of_imageFinite
    {State Act : Type _}
    [DecidableEq State]
    (M : ImageFiniteLTS State Act) :
    IsBisimulation M.step (fun s t => HMEquiv M.step s t)
```

or, if `IsBisimulation` is not already present, prove the transfer property directly:

```lean
theorem hm_equiv_transfer_of_imageFinite
    {State Act : Type _}
    [DecidableEq State]
    (M : ImageFiniteLTS State Act)
    {s t : State}
    (hEq : HMEquiv M.step s t) :
    ∀ ⦃a s'⦄, M.step s a s' →
      ∃ t', M.step t a t' ∧ HMEquiv M.step s' t'
```

and symmetrically if needed.

The final equivalence theorem should then be:

```lean
theorem hm_equiv_iff_bisimilar_of_imageFinite
    {State Act : Type _}
    [DecidableEq State]
    (M : ImageFiniteLTS State Act)
    {s t : State} :
    HMEquiv M.step s t ↔ Bisimilar M.step s t
```

using the catalog theorem `bisimilar_implies_hm_equiv` for one direction and your new theorem for the converse.

---

## New Definitions You Must Introduce

You must define at least one genuinely new concept not already in the catalog. The following are mathematically meaningful and directly useful.

### 1. Finite distinguishing family

A finite package of formulas indexed by the finitely many `a`-successors of a state:

```lean
def DistinguishingFamily
    {State Act : Type _}
    (step : State → Act → State → Prop)
    (s' : State)
    (ts : Finset State) : Prop :=
  ∃ Φ : State → HMFormula Act,
    (∀ t' ∈ ts, ¬ HMEquiv step s' t' →
      satisfies step s' (Φ t') ∧ ¬ satisfies step t' (Φ t')) 
```

You may refine this to store only formulas on `ts`, e.g. using a subtype or `∀ t' : {x // x ∈ ts}, ...`. The important thing is that it captures **uniform finite distinguishability data**.

### 2. Finite conjunction operator

If conjunction is not already n-ary in the syntax, define a fold:

```lean
def finsetConj {Act : Type _} : Finset (HMFormula Act) → HMFormula Act
```

and prove the semantic theorem:

```lean
theorem satisfies_finsetConj_iff
    {State Act : Type _}
    (step : State → Act → State → Prop)
    [DecidableEq (HMFormula Act)]
    (Γ : Finset (HMFormula Act))
    (s : State) :
    satisfies step s (finsetConj Γ) ↔ ∀ φ ∈ Γ, satisfies step s φ
```

This theorem is not cosmetic: it is the logical engine that converts many pairwise distinguishing formulas into one global obstruction.

### 3. One-step modal separator

Define the formula asserting the existence of an `a`-successor satisfying a finite conjunction:

```lean
def stepSeparator {Act : Type _} (a : Act) (Γ : Finset (HMFormula Act)) : HMFormula Act :=
  HMFormula.diamond a (finsetConj Γ)
```

This creates the exact contradiction formula needed in the HM proof.

---

## The Breakthrough Theorem Architecture

### Theorem 1: Finite conjunction semantics
Prove the fold semantics theorem for finite conjunctions.

Suggested Lean shape:

```lean
theorem satisfies_finsetConj_iff
    {State Act : Type _}
    (step : State → Act → State → Prop)
    (Γ : Finset (HMFormula Act))
    (s : State) :
    satisfies step s (finsetConj Γ) ↔ ∀ φ ∈ Γ, satisfies step s φ
```

This should be proved by induction on the `Finset`, not by simplification alone.

### Theorem 2: Finite distinguishing conjunction
If each member of a finite family of states is individually distinguishable from `s'`, then there is one finite conjunction satisfied by `s'` and by none of them.

Suggested Lean shape:

```lean
theorem exists_finitary_separator
    {State Act : Type _}
    [DecidableEq State]
    (step : State → Act → State → Prop)
    {s' : State} {ts : Finset State}
    (hsep : ∀ t' ∈ ts, ¬ HMEquiv step s' t' →
      ∃ φ : HMFormula Act, satisfies step s' φ ∧ ¬ satisfies step t' φ) :
    ∃ ψ : HMFormula Act,
      satisfies step s' ψ ∧
      ∀ t' ∈ ts, ¬ HMEquiv step s' t' → ¬ satisfies step t' ψ
```

The intended `ψ` is the conjunction of all chosen `φ_{t'}`. This theorem is the finitary compactness principle specific to image-finite branching.

### Theorem 3: HM-equivalence satisfies the bisimulation transfer condition
This is the main nontrivial theorem.

Suggested Lean shape:

```lean
theorem hm_equiv_transfer_of_imageFinite
    {State Act : Type _}
    [DecidableEq State]
    (M : ImageFiniteLTS State Act)
    {s t : State}
    (hEq : HMEquiv M.step s t) :
    ∀ ⦃a s'⦄, M.step s a s' →
      ∃ t', M.step t a t' ∧ HMEquiv M.step s' t'
```

Proof idea: assume `s -a→ s'` and no `a`-successor of `t` is HM-equivalent to `s'`. Since `succs t a` is finite, choose a distinguishing formula for each `t' ∈ succs t a`; conjoin them to get `ψ`; then `s ⊨ ◇a ψ`, while `t ⊭ ◇a ψ`, contradicting `HMEquiv`.

### Theorem 4: Hennessy–Milner completeness for image-finite systems
Suggested Lean shape:

```lean
theorem hm_equiv_iff_bisimilar_of_imageFinite
    {State Act : Type _}
    [DecidableEq State]
    (M : ImageFiniteLTS State Act)
    {s t : State} :
    HMEquiv M.step s t ↔ Bisimilar M.step s t
```

This is the headline result. It completes the logical–coalgebraic correspondence in the standard image-finite setting.

---

## Proof Strategy Paths

You must include at least 2–3 serious proof routes in your planning comments or paper, and then execute the most promising one in Lean.

### Strategy A — Direct finite-conjunction contradiction
1. Assume `HMEquiv s t`, `step s a s'`, and no matching `t'`.
2. Enumerate `succs t a : Finset State`.
3. For each `t'` in that finite set, use non-equivalence to choose a distinguishing formula `φ_{t'}`.
4. Let `ψ = finsetConj {φ_{t'} | t' ∈ succs t a}`.
5. Prove `s' ⊨ ψ`, hence `s ⊨ ◇a ψ`.
6. Show every `a`-successor of `t` fails `ψ`, hence `t ⊭ ◇a ψ`.
7. Contradict HM-equivalence.

**Why this is most promising:** it matches the classical proof exactly, uses only finite data, and aligns perfectly with `Finset` and existing modal semantics in Mathlib/Lean.

### Strategy B — Define the greatest HM-stable relation and prove transfer
1. Define a relation `R s t := HMEquiv step s t`.
2. Show `R` is symmetric and preserves truth of all formulas.
3. Prove transfer by contradiction using a “universal blocker” formula built from the finite successor set.
4. Package this as `IsBisimulation step R`.

**Why it is attractive:** cleaner conceptually, and it scales to later work on characteristic formulas and coalgebraic modal logic.

### Strategy C — Partition-refinement viewpoint
1. Define depth-`n` modal equivalence classes.
2. Show image-finiteness implies stabilization of one-step distinguishing data over finite successor sets.
3. Use the finite depth separators to derive full bisimulation transfer.

**Why this is scientifically exciting:** it connects HM logic directly to Paige–Tarjan-style refinement and suggests verified minimization algorithms. It may be heavier in Lean, but it opens algorithmic consequences.

**Recommendation:** implement **Strategy A** as the main formal proof, while framing **B** and **C** in `RESEARCH_PAPER.md` and `FUTURE_DIRECTIONS.md` as scalable generalizations.

---

## Cross-Domain Mathematical Connections

You are required to include at least one theorem or formal discussion that links this work to another domain. Do not leave this as prose only; make at least one formal artifact.

### Connection 1 — Algorithms / partition refinement
Formalize a theorem showing that finite distinguishing conjunctions correspond to one-step splitter certificates used in partition refinement.

A possible formal statement:

```lean
theorem separator_induces_block_split
    {State Act : Type _}
    [DecidableEq State]
    (M : ImageFiniteLTS State Act)
    (a : Act)
    (Γ : Finset (HMFormula Act))
    {s t : State} :
    satisfies M.step s (stepSeparator a Γ) →
    ¬ satisfies M.step t (stepSeparator a Γ) →
    s ≠ t
```

Better still: define a block predicate by formula satisfaction and show the separator splits any candidate behavioral partition. This creates a direct bridge to Paige–Tarjan and model checking.

### Connection 2 — Decidability / finite model checking
For finite `State`, prove that HM-equivalence is decidable from formula-depth approximants or from finite-state search over successor sets. Even a partial theorem here is powerful.

Possible direction:

```lean
theorem decidable_hm_equiv_of_finite_imageFinite
    {State Act : Type _}
    [Fintype State] [DecidableEq State] :
    DecidableRel (HMEquiv M.step)
```

If full proof is too large, formalize a verified semidecision or bounded approximant algorithm and prove soundness.

### Connection 3 — Coalgebra / automata
Frame the theorem as a finitary instance of modal adequacy for coalgebras of the finite powerset functor. Even if not fully formalized categorically, state this clearly in the paper and connect the finite conjunction to Moss-style predicate lifting intuition.

**Application keywords:** modal logic, bisimulation, image-finite transition systems, partition refinement, Paige–Tarjan, model checking, coalgebra, automata theory, characteristic formulas, decidability, finite-state verification.

---

## Required Deep Proof Tactics

You must ensure the Lean file contains **at least 3 substantial theorems** whose proofs genuinely use:
- induction on `Finset` or syntax depth,
- `rcases` on existential/distinguishing witnesses,
- `by_contra` in the transfer contradiction step,
- multi-step `calc`,
- and, where appropriate, rewriting through `hm_box_iff` or semantic lemmas.

Avoid trivial closure proofs. The core transfer theorem should visibly use:
- `by_contra hNoMatch`
- extraction of finite witnesses from `succs`
- `rcases` on distinguishing formulas
- an induction proving conjunction semantics

---

## Computational / Algorithmic Deliverable

You must produce a **verified algorithmic artifact**, not just theorems.

### Required algorithm
Implement a procedure that, for a finite image-finite LTS with `|State| ≤ 6` and `Act = {a, b}`, searches for:
- HM-equivalent but non-bisimilar pairs, or
- confirms none exist in the tested universe.

At minimum:
1. Encode finite LTSs by finite successor tables.
2. Compute bounded-depth modal equivalence approximants.
3. Compute bisimulation via partition refinement or greatest fixed point.
4. Compare the two on all generated systems up to the search bound.

The experiment should support the theorem and also serve as a falsification harness for stronger conjectures.

---

## Conjecture With Testable Prediction

You must include at least one falsifiable conjecture with a clear computational test.

### Conjecture A — Depth bound by refinement rank
For every finite image-finite LTS and states `s,t`, if `s` and `t` are not bisimilar, then there exists an HM distinguishing formula whose modal depth is at most the partition refinement stabilization depth of the pair.

Possible Lean-facing abstraction:

```lean
conjecture modal_depth_le_refinement_rank :
  ∀ (M : ImageFiniteLTS State Act) [Fintype State] [DecidableEq State] (s t : State),
    ¬ Bisimilar M.step s t →
    ∃ φ : HMFormula Act,
      satisfies M.step s φ ∧ ¬ satisfies M.step t φ ∧
      modalDepth φ ≤ refinementRank M s t
```

This is falsifiable by exhaustive search over small finite LTSs.

### Conjecture B — Characteristic formulas for finite bisimulation classes
Every state in a finite image-finite LTS admits an HM characteristic formula of depth bounded by the number of partition refinement rounds.

This would open a direct bridge between modal logic and explainable verification.

---

## Implementation Notes for Lean 4

- Use `Finset`-valued successor functions rather than existential image-finiteness; this gives computational content and avoids repeated finite-choice headaches.
- If formulas require `[DecidableEq (HMFormula Act)]` for `Finset`, derive or define it carefully.
- If conjunction is binary in the syntax, define `finsetConj` by fold with a top-like formula if available; otherwise define a nonempty fold plus a special true formula if the syntax supports it. If no truth constant exists, you may need a custom nonempty conjunction type or use a list together with a semantic predicate.
- Reuse `hm_box_iff` and any existing semantic extensionality lemmas aggressively.
- Keep the finite separator theorem modular; it will likely be reusable for characteristic formulas later.

---

## Deliverables (ALL mandatory)

You must produce all of the following:

1. **Lean file(s)** containing:
   - the new `ImageFiniteLTS` structure,
   - at least one novel definition such as `finsetConj` or `DistinguishingFamily`,
   - at least 3 substantial theorems with deep proofs,
   - the main theorem `hm_equiv_iff_bisimilar_of_imageFinite`,
   - minimal `sorry` usage.

2. **`FUTURE_DIRECTIONS.md`**
   - include **3–5 testable scientific hypotheses**,
   - each must be falsifiable and have a concrete computational test,
   - at least one should concern modal-depth bounds,
   - at least one should concern algorithmic complexity or partition refinement.

3. **`RESEARCH_PAPER.md`**
   - standalone scientific exposition,
   - explain the theorem, proof idea, significance, and consequences,
   - include lineage: Hennessy–Milner, Stirling, Sangiorgi,
   - explain how finite conjunctions act as compactness witnesses in image-finite systems,
   - discuss algorithmic implications for bisimulation minimization and model checking.

4. **`ARTICLE.md`**
   - Scientific American style,
   - accessible and engaging,
   - focus on the mathematical idea: how finitely many local distinctions become one global logical separator,
   - **do not focus on formal verification machinery**.

5. **Verified algorithm / computational method**
   - bounded exhaustive checker for finite LTSs,
   - compares modal equivalence approximants with bisimulation,
   - proves soundness of the computed separator or partition refinement step where feasible.

6. **`demo.py`**
   - interactively constructs small LTS examples,
   - displays successors, HM distinguishing formulas, and bisimulation classes,
   - demonstrates the main theorem on representative examples,
   - includes a search mode over all LTSs with up to 6 states over `Act = {a,b}`.

---

## Scientific Significance

If you succeed, you will have completed the **standard Hennessy–Milner completeness theorem** inside this Yoneda-bisimulation framework in a way that is not merely classical bookkeeping, but structurally generative:

- it identifies **finite distinguishing conjunctions** as the exact logical analogue of **splitters** in partition refinement;
- it turns modal equivalence into a computationally meaningful bisimulation principle under image-finiteness;
- it lays the groundwork for **verified characteristic formulas**, **certified minimization algorithms**, and **complexity bounds on logical distinguishability**;
- it creates a bridge from modal logic to **automata theory**, **coalgebra**, and **algorithmic verification**.

This is not just “formalizing a known theorem.” It is constructing the missing finite interface between logic and behavior — the interface from which new algorithms, new depth bounds, and new coalgebraic generalizations can emerge.

Be bold, be precise, and make the finite conjunction construction so clean that it becomes the primitive from which an entire next layer of theory can be built.

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
