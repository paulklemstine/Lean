Soli Deo Gloria

## Assignment: Direction 5 — Coalgebraic Semantics and Game-Theoretic Characterization

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

This direction should not be treated as a routine formalization of “standard bisimulation folklore.” The real target is a **coalgebraic-operational equivalence theorem for bounded λ-term transition systems** that simultaneously unifies:

- operational semantics of λ-terms,
- coalgebraic behavioral equivalence,
- bounded modal indistinguishability,
- and finite-round bisimulation games.

If executed well, this opens a formal bridge from **lambda calculus to coalgebra, finite model theory, and descriptive complexity**, and creates a reusable Lean infrastructure for future results on modal depth, adequacy, minimization, and algorithmic equivalence checking.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.
   If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at
   least 3 theorems proven using induction, `rcases`, `by_contra`, `field_simp`,
   or multi-step `calc` reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept
   that does not already exist in the Catalog. Check the catalog references to
   confirm novelty.

4. **Cross-domain connections**: Include at least one theorem that connects your
   domain to a different mathematical domain (e.g., number theory + tropical
   geometry, algebra + physics).

5. **Conjecture with testable prediction**: State at least one falsifiable
   conjecture with a clear computational test that could disprove it.

---

## Core Vision

The bounded FTS attached to λ-terms should be upgraded from a mere transition gadget into a **coalgebra for a finitely branching observation functor**, and weak bisimilarity should be shown to admit **three equivalent faces**:

1. **coalgebraic**: equality under the canonical semantics into a final bounded behavior object,
2. **game-theoretic**: Duplicator wins a finite-round weak bisimulation game,
3. **logical**: satisfaction of the same bounded modal formulas.

The breakthrough is not any one equivalence in isolation. The breakthrough is a **certified triangle of equivalences**:
\[
\text{weak bisimilarity} \;\Longleftrightarrow\; \text{game equivalence at depth } d \;\Longleftrightarrow\; \text{modal indistinguishability up to depth } d,
\]
specialized to bounded λ-term FTS and formalized in Lean 4.

That triangle is the finite-depth semantic engine behind future work on:
- behavioral compression of λ-term state spaces,
- modal-definability and descriptive complexity bounds,
- certified equivalence checking algorithms,
- and game semantics for resource-bounded computation.

---

## Precise Formal Targets

You should introduce a bounded transition-system interface suitable for coalgebraic reasoning. If the catalog already contains `FTS`, adapt names accordingly, but preserve the mathematical content.

### Novel definitions to introduce

At least one of the following must be implemented as a genuinely new definition:

```lean
/-- A bounded finitely branching transition system. -/
structure BoundedFTS where
  State : Type
  step : State → Finset State
  init : State
  bound : ℕ
  bounded_step : ∀ s, (step s).card ≤ bound
```

```lean
/-- d-round weak bisimulation game between states a and b. -/
def BisimGame (d : ℕ) (A B : BoundedFTS) (a : A.State) (b : B.State) : Prop := ...
```

```lean
/-- Modal indistinguishability up to formulas of depth d. -/
def ModalEquivalentUpTo (d : ℕ) (A B : BoundedFTS) (a : A.State) (b : B.State) : Prop := ...
```

```lean
/-- Coalgebraic observation map into depth-d behaviors. -/
def behaviorApprox (d : ℕ) (A : BoundedFTS) : A.State → Behavior d := ...
```

If feasible, define a depth-indexed behavior type rather than invoking a full final coalgebra abstractly:

```lean
inductive Behavior : ℕ → Type
| zero : Behavior 0
| succ : Finset (Behavior d) → Behavior (d+1)
```

or an equivalent encoding. This is often the right formal substitute for “the final coalgebra up to depth `d`” and is likely more tractable in Lean than a fully general categorical finality theorem.

---

## Precise Theorem Statements

You must prove at least 3 substantial theorems. The following are the primary targets.

### Theorem 1: Coalgebraic invariance of weak bisimulation

This theorem should show that weakly bisimilar states have identical bounded observations.

Suggested Lean target:

```lean
theorem weakBisimilar_imp_behaviorEq
    (d : ℕ) (A : BoundedFTS) {a b : A.State} :
    WeakBisimilar A a b →
    behaviorApprox d A a = behaviorApprox d A b
```

Stronger cross-system version if your definitions support heterogeneous relations:

```lean
theorem weakBisimilar_imp_behaviorEq'
    (d : ℕ) (A B : BoundedFTS) {a : A.State} {b : B.State} :
    WeakBisimilarAcross A B a b →
    behaviorApprox d A a = behaviorApprox d B b
```

**Why this matters:** this is the coalgebraic half of the story. It says weak bisimulation is not merely relational but semantically extensional with respect to all bounded observations.

---

### Theorem 2: Game characterization of weak bisimilarity

This is the centerpiece.

```lean
theorem game_characterization
    (d : ℕ) (A B : BoundedFTS) (a : A.State) (b : B.State) :
    WeakBisimilarAcrossDepth d A B a b ↔ BisimGame d A B a b
```

If your development first proves a same-system version:

```lean
theorem game_characterization_self
    (d : ℕ) (A : BoundedFTS) (a b : A.State) :
    WeakBisimilarUpTo d A a b ↔ BisimGame d A A a b
```

and then lifts to cross-systems, that is acceptable.

**Important refinement:** because finite-round games generally characterize **depth-bounded** equivalence rather than full coinductive equivalence, be mathematically precise. If the unrestricted theorem is too strong, do **not** state a false theorem. Instead define:
- `WeakBisimilarUpTo d ...`
or
- `ModalEquivalentUpTo d ...`
and prove the exact bounded equivalence theorem.

A more honest and likely correct target is:

```lean
theorem game_characterization_depth
    (d : ℕ) (A B : BoundedFTS) (a : A.State) (b : B.State) :
    ModalEquivalentUpTo d A B a b ↔ BisimGame d A B a b
```

followed by a corollary:

```lean
theorem weakBisimilar_imp_game
    (d : ℕ) (A B : BoundedFTS) (a : A.State) (b : B.State) :
    WeakBisimilarAcross A B a b → BisimGame d A B a b
```

This would be mathematically stronger in credibility than forcing an overclaim.

---

### Theorem 3: Modal-depth correspondence

Use the modal logic from the earlier theorem lineage and show that game depth matches modal depth.

```lean
theorem modal_game_equiv
    (d : ℕ) (A B : BoundedFTS) (a : A.State) (b : B.State) :
    ModalEquivalentUpTo d A B a b ↔ BisimGame d A B a b
```

This is the formal finite-model-theoretic bridge. It is the result that imports Ehrenfeucht–Fraïssé thinking into the λ-term setting.

A stronger semantic version:

```lean
theorem modal_depth_behavior
    (d : ℕ) (A B : BoundedFTS) (a : A.State) (b : B.State) :
    ModalEquivalentUpTo d A B a b ↔ behaviorApprox d A a = behaviorApprox d B b
```

Then Theorem 2 can be obtained by transitivity.

---

## Recommended Theorem Architecture

A highly viable decomposition is:

1. Define `Behavior d`.
2. Define `behaviorApprox d`.
3. Define `BisimGame d`.
4. Define `ModalEquivalentUpTo d`.
5. Prove:
   - `behaviorApprox_eq_iff_modalEquivalentUpTo`
   - `modalEquivalentUpTo_iff_BisimGame`
   - `weakBisimilar_imp_behaviorEq`
6. Conclude:
   - `weakBisimilar → BisimGame d`
   - if you can, under image-finiteness + extensionality assumptions, derive converse limits.

This avoids overcommitting to a full abstract final coalgebra if Lean friction becomes too high, while still delivering the mathematically essential result.

---

## Lean 4 Type Signature Guidance

These signatures are intentionally concrete and realistic.

```lean
def ReachableIn (A : BoundedFTS) : ℕ → Set A.State := ...
```

```lean
def WeakStep (A : BoundedFTS) (a b : A.State) : Prop := ...
```

```lean
def WeakBisimulation (A B : BoundedFTS)
    (R : A.State → B.State → Prop) : Prop := ...
```

```lean
def WeakBisimilarAcross (A B : BoundedFTS) (a : A.State) (b : B.State) : Prop :=
  ∃ R, WeakBisimulation A B R ∧ R a b
```

```lean
inductive Behavior : ℕ → Type
| zero : Behavior 0
| succ {d : ℕ} : Finset (Behavior d) → Behavior (d+1)
```

```lean
def behaviorApprox : (d : ℕ) → (A : BoundedFTS) → A.State → Behavior d
| 0, A, s => Behavior.zero
| d+1, A, s => Behavior.succ ((A.step s).image (behaviorApprox d A))
```

```lean
inductive Formula : ℕ → Type
| atom : String → Formula d
| top : Formula d
| bot : Formula d
| and : Formula d → Formula d → Formula d
| or  : Formula d → Formula d → Formula d
| diamond : Formula d → Formula (d+1)
| box     : Formula d → Formula (d+1)
```

```lean
def Satisfies : {d : ℕ} → Formula d → A.State → Prop := ...
```

```lean
def ModalEquivalentUpTo
    (d : ℕ) (A B : BoundedFTS) (a : A.State) (b : B.State) : Prop :=
  ∀ φ : Formula d, Satisfies φ a ↔ Satisfies φ b
```

```lean
def BisimGame : ℕ → (A B : BoundedFTS) → A.State → B.State → Prop
| 0,     A, B, a, b => True
| d+1,   A, B, a, b =>
    (∀ a', a' ∈ A.step a → ∃ b', b' ∈ B.step b ∧ BisimGame d A B a' b') ∧
    (∀ b', b' ∈ B.step b → ∃ a', a' ∈ A.step a ∧ BisimGame d A B a' b')
```

If weak transitions require stuttering / τ-closure, replace `step` by a derived `weakStepSet d` or closure operator. Be explicit about boundedness so the game remains finite and computationally executable.

---

## Proof Strategy: 3 Viable Routes

You must include 2–3 proof approaches in your working plan and choose one as primary.

### Strategy A: Depth-indexed final semantics via finite trees
**Most promising.**

1. Define `Behavior d` inductively as depth-`d` observation trees.
2. Define `behaviorApprox` by recursion on `d`.
3. Prove by induction on `d` that equality of `behaviorApprox d` is equivalent to modal equivalence up to depth `d`.
4. Prove by induction on `d` that this is equivalent to Duplicator winning `BisimGame d`.

**Why this is best:** it avoids heavy category theory formalization while still delivering the coalgebraic substance. In Lean, depth-indexed semantics are far more robust than trying to formalize final coalgebras in one leap.

### Strategy B: Relational/game induction directly on bounded bisimulation
1. Define `BisimGame d` recursively.
2. Define `WeakBisimilarUpTo d` recursively as a stratified simulation relation.
3. Prove equivalence by induction on `d`, using `rcases` on matching moves and `by_contra` for failure of Duplicator strategies.
4. Only afterward package the recursion as a coalgebraic observation map.

**Why it works:** this route keeps the game proof close to standard back-and-forth arguments and may be easier if your current codebase already has weak transition closures.

### Strategy C: Categorical packaging after the finite proof
1. First prove the finite-depth equivalences using Strategy A or B.
2. Then define a category of bounded FTS and coalgebra morphisms.
3. Show `behaviorApprox d` is natural with respect to coalgebra morphisms.
4. Extract a “bounded finality” theorem as a universal property.

**Why this matters:** this is the visionary upgrade. It turns your operational theorem into a reusable categorical semantics framework. But it should come after the finite proof, not before.

**Recommendation:** Use **Strategy A as primary**, Strategy B as support, and Strategy C only if time permits.

---

## Mathematical Subtleties You Must Handle Honestly

Do not blur these distinctions:

1. **Finite depth vs full bisimilarity**  
   A `d`-round game usually characterizes depth-`d` indistinguishability, not full coinductive equivalence. If you want full equivalence, you likely need:
   - image-finiteness,
   - all finite depths,
   - and a compactness/Hennessy–Milner style argument.

2. **Weak vs strong bisimulation**  
   If weak transitions involve silent steps, you need either:
   - a closure operation in the transition relation,
   - or a game rule allowing stuttering.
   Be precise. “Possibly with stuttering” must be encoded in the game definition itself.

3. **Coalgebra functor precision**  
   `F(X) = P_fin(X)` is natural for finitely branching systems, but if labels or silent actions are present, the functor may need to be:
   \[
   F(X) = \mathcal P_{\mathrm{fin}}(L \times X)
   \]
   or a weakly-saturated variant. If labels matter, include them.

4. **Kernel of the unique morphism to final coalgebra**  
   In Lean, proving a literal final coalgebra theorem for all bounded FTS may be much harder than proving a depth-indexed approximation theorem. If full finality is too ambitious, prove:
   - kernel of `behaviorApprox d` equals depth-`d` modal equivalence,
   and state the full final-coalgebra claim as a conjectural next step.

That would still be a strong scientific contribution.

---

## Cross-Domain Connections (MANDATORY)

Include at least one theorem explicitly bridging to another domain.

### Option 1: Descriptive complexity bridge
Prove that if two states are distinguished by a `d`-round game loss, then there exists a modal formula of depth `d` separating them.

This is the modal analog of an Ehrenfeucht–Fraïssé definability theorem and directly connects to finite model theory.

Suggested theorem:

```lean
theorem spoiler_win_implies_separating_formula
    (d : ℕ) (A B : BoundedFTS) (a : A.State) (b : B.State) :
    ¬ BisimGame d A B a b →
    ∃ φ : Formula d, Satisfies φ a ∧ ¬ Satisfies φ b
```

This is a serious theorem with real mathematical content.

### Option 2: Algorithmic verification bridge
Show that the game semantics induces a decision procedure for bounded equivalence on finite systems.

```lean
def decideBisimGame (d : ℕ) (A B : BoundedFTS) [Fintype A.State] [Fintype B.State]
    (a : A.State) (b : B.State) : Bool := ...
```

```lean
theorem decideBisimGame_correct
    (d : ℕ) (A B : BoundedFTS) [Fintype A.State] [Fintype B.State]
    (a : A.State) (b : B.State) :
    decideBisimGame d A B a b = true ↔ BisimGame d A B a b
```

This gives a computational method, not just a theorem.

### Option 3: Information-flow / security semantics bridge
Interpret modal indistinguishability as bounded observational equivalence for a program observer. Then prove that game equivalence implies no depth-`d` observer can distinguish the terms.

This connects λ-calculus semantics to program verification and security.

---

## Application Keywords

Use these explicitly in the write-up and paper metadata:

**Application keywords:** coalgebraic semantics, bisimulation game, finite model theory, descriptive complexity, λ-calculus, modal logic, behavioral equivalence, certified verification, model checking, game semantics, image-finite transition systems, weak bisimulation, final coalgebra approximation, algorithmic equivalence checking.

---

## Concrete Theorem Bundle to Aim For

A strong deliverable file would contain at least the following:

1. `behaviorApprox_respects_weak_bisim`
2. `modalEquivalentUpTo_iff_behaviorEq`
3. `modalEquivalentUpTo_iff_BisimGame`
4. `spoiler_win_implies_separating_formula`
5. `decideBisimGame_correct`

Even proving 1–3 with full rigor would already be significant. Adding 4 or 5 would make the project field-opening.

---

## Suggested Proof Skeletons

### For `modalEquivalentUpTo_iff_behaviorEq`
- Induct on `d`.
- Base case: every state has the same depth-0 behavior.
- Step case:
  - unfold `behaviorApprox`,
  - reduce equality of `Finset`-images to back-and-forth matching,
  - use induction hypothesis on successors,
  - build distinguishing formulas via `diamond` / `box` when equality fails.

This proof should involve substantial `rcases`, induction, and `calc`.

### For `modalEquivalentUpTo_iff_BisimGame`
- Induct on `d`.
- Base case is trivial but should be embedded in a nontrivial theorem.
- Step case:
  - for the forward implication, instantiate modal formulas corresponding to successor challenges;
  - for the reverse implication, recursively synthesize formulas from Spoiler-winning subpositions.
- Use `by_contra` to convert failure of matching into existence of a separating formula.

### For `weakBisimilar_imp_behaviorEq`
- Take a witness relation `R`.
- Induct on `d`.
- At step `d+1`, use the bisimulation property to show every successor observation on one side is matched by an equal depth-`d` observation on the other.
- Conclude equality of `Finset` images.

If weak transitions are closure-based, you will likely need lemmas about closure composition and bounded reachability.

---

## Falsifiable Conjecture with Computational Test

You must state at least one explicit conjecture with a clear test.

### Conjecture A: Finite-depth collapse on bounded λ-term fragments
For λ-terms in a fixed bounded fragment, there exists `N` such that if two terms are `N`-round game equivalent, then they are fully weakly bisimilar.

```lean
conjecture bounded_fragment_depth_collapse
    (Γ : TermFragment) :
    ∃ N, ∀ t u ∈ Γ,
      BisimGame N (toBoundedFTS t) (toBoundedFTS u) _ _ →
      WeakBisimilarAcross (toBoundedFTS t) (toBoundedFTS u) _ _
```

**Computational test:** enumerate pairs of terms in the fragment up to size `k`, compute the least distinguishing depth, and search for stabilization. A counterexample is any pair agreeing up to depth `N` but not fully bisimilar.

### Conjecture B: Minimal distinguishing formula depth equals Spoiler winning rank
```lean
conjecture distinguishing_depth_equals_game_rank :
  ∀ (A B : BoundedFTS) [Fintype A.State] [Fintype B.State] (a : A.State) (b : B.State),
    minFormulaDepthSeparating A B a b = minSpoilerWinDepth A B a b
```

**Computational test:** implement both quantities and compare on all finite examples up to a state bound.

This is especially strong because it predicts an exact correspondence between logic and game complexity.

---

## Deliverables (MANDATORY)

You must produce **ALL** of the following:

1. **A structured `FUTURE_DIRECTIONS.md`**
   - Include **3–5 testable scientific hypotheses**.
   - Each hypothesis must be falsifiable and include a concrete computational or formal test.

2. **A `RESEARCH_PAPER.md`**
   - It must be a **standalone scientific document**.
   - A reader with no access to the code must understand:
     - the problem,
     - the main definitions,
     - the theorem statements,
     - why the results matter,
     - and what next experiments/theorems should be attempted.

3. **An `ARTICLE.md`**
   - Written in **Scientific American style**.
   - Engaging, accessible, and accurate.
   - Explain why coalgebraic games for λ-terms are surprising and important.

4. **A verified algorithm or computational method**
   - At minimum: a certified decision procedure for bounded game equivalence or modal equivalence on finite systems.
   - Include a correctness theorem in Lean.

5. **A `demo.py`**
   - Demonstrate the result interactively.
   - Suggested features:
     - build two small bounded FTS,
     - compute game equivalence up to depth `d`,
     - produce a separating modal formula when equivalence fails,
     - visualize the back-and-forth game tree.

---

## Standard of Ambition

Do not merely restate “bisimulation is a game.” That is not enough.

The goal is to make Lean certify that **bounded λ-term semantics sits inside the same semantic triangle that powers modern coalgebra, modal logic, and finite model theory**. If done correctly, this is the seed of a new program:

- coalgebraic λ-semantics,
- descriptive complexity for higher-order processes,
- certified modal distinguishability,
- and algorithmic synthesis of separating formulas.

That is a real research frontier.

Be bold, but be mathematically honest. If the full final-coalgebra theorem is too strong, prove the finite-depth approximation theorem completely and state the full version as the next conjectural horizon.

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
