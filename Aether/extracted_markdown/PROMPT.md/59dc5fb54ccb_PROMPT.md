## Assignment: Direction 5: Residual Finiteness and Semantic Distinguishability

**Mode:** `prove` with a computational `discover` subgoal.

You are not being asked for a routine formalization of “free groups are residually finite.” You are being asked to turn residual finiteness into a **quantitative semantic separation theorem** for program equivalence, and to formalize the bridge from combinatorial group theory to **finite-model compiler testing**.

The central scientific vision is this:

> Distinct programs in a free-group semantics should be distinguishable by evaluation in a *small finite group*, with bounds controlled by syntax length.

If achieved, this becomes a mathematically certified analogue of property-based testing: instead of testing against arbitrary models, one tests against a bounded family of finite permutation groups. That is a field-opening connection between **geometric group theory**, **formal semantics**, and **verified compiler testing**.

---

## Core Research Objective

Let `FreeGroup α` denote the free group on alphabet `α`, and let `wordLength : FreeGroup α → ℕ` be a suitable reduced-word length function (you may need to define this if the exact notion is not already in Mathlib/catalog). For finite `α` with `Fintype α`, define the semantic distinguishability radius:

```lean
def sepProfile (α : Type) [DecidableEq α] [Fintype α] (L : ℕ) : ℕ :=
  sInf { k : ℕ | ∀ x y : FreeGroup α,
    x ≠ y →
    wordLength x ≤ L →
    wordLength y ≤ L →
    ∃ (σ : α → Equiv.Perm (Fin k)),
      FreeGroup.lift σ x ≠ FreeGroup.lift σ y }
```

If `FreeGroup.lift` is not directly the available API, adapt this using the catalog theorem
`Pythagorean/VerifiedCompilerSynthesis.lean`:
- `evalFreeGroup`
- `freeGroup_eval_natural`

Your first mission is to formalize a mathematically clean variant of this notion, even if the exact infimum-based definition is replaced by an existential bounded predicate better suited to Lean.

---

## Precise Theorem Targets

You must prove **at least 3 substantial theorems**, with nontrivial proofs using induction / `rcases` / `by_contra` / `field_simp`-style multi-step reasoning / long `calc` chains. No theorem should collapse to `rfl`, `decide`, or brute-force enumeration unless the statement itself is profound.

### Theorem 1: Finite semantic separation from residual finiteness
Formalize a bounded-length finite separation theorem.

**Mathematical statement.**
For every finite generator type `α`, every length bound `L`, and every distinct free-group elements `x ≠ y` of length at most `L`, there exists a finite group `G` and an evaluation `α → G` separating them.

A Lean-oriented target:

```lean
theorem freeGroup_finite_separation_bounded
  (α : Type) [DecidableEq α] [Fintype α]
  (L : ℕ) :
  ∀ x y : FreeGroup α,
    x ≠ y →
    wordLength x ≤ L →
    wordLength y ≤ L →
    ∃ (G : Type) (_ : Group G) (_ : Fintype G),
      ∃ φ : α → G,
        evalFreeGroup φ x ≠ evalFreeGroup φ y
```

This is the minimal breakthrough theorem: it converts residual finiteness into a **uniform semantic distinguishability principle on finite syntax balls**.

**Why this matters.**
Residual finiteness is usually stated elementwise (`g ≠ 1 → ∃ finite quotient separating g`). Your theorem reframes it as a **semantic testing guarantee** for all programs up to size `L`. This is the first step toward a certified bounded testing oracle.

---

### Theorem 2: Pairwise separation reduces to identity separation
Prove the reduction from separating `x` and `y` to separating `x * y⁻¹` from `1`.

**Mathematical statement.**
For any group-valued evaluation, `x` and `y` evaluate differently iff `x * y⁻¹` evaluates nontrivially.

Lean target:

```lean
theorem eval_ne_iff_mul_inv_ne_one
  {α G : Type} [DecidableEq α] [Group G]
  (φ : α → G) (x y : FreeGroup α) :
  evalFreeGroup φ x ≠ evalFreeGroup φ y ↔
    evalFreeGroup φ (x * y⁻¹) ≠ 1
```

or equivalently with equality to `1`:

```lean
theorem eval_eq_iff_mul_inv_eq_one
  {α G : Type} [DecidableEq α] [Group G]
  (φ : α → G) (x y : FreeGroup α) :
  evalFreeGroup φ x = evalFreeGroup φ y ↔
    evalFreeGroup φ (x * y⁻¹) = 1
```

**Why this matters.**
This theorem is the semantic heart of the project. It translates **compiler equivalence checking** into **identity testing in finite quotients**. It is also the gateway to importing classical residual finiteness machinery.

---

### Theorem 3: Finite test-set existence on bounded syntax balls
Show that for each `L`, there is a finite family of finite groups that separates every distinct pair of bounded words.

**Mathematical statement.**
Because the set of reduced words of length `≤ L` over finite `α` is finite, and each pair is separable by some finite group, there exists a finite list of finite groups / evaluations that collectively separate all pairs.

Lean target, one possible formulation:

```lean
def BoundedEvaluator (α : Type) [DecidableEq α] :=
  Σ (G : Type), Group G × Fintype G × (α → G)

theorem finite_test_suite_exists
  (α : Type) [DecidableEq α] [Fintype α]
  (L : ℕ) :
  ∃ tests : Finset (BoundedEvaluator α),
    ∀ x y : FreeGroup α,
      x ≠ y →
      wordLength x ≤ L →
      wordLength y ≤ L →
      ∃ t ∈ tests,
        let G := t.1
        let _ := (t.2.1)
        let _ := (t.2.2.1)
        let φ := (t.2.2.2)
        evalFreeGroup φ x ≠ evalFreeGroup φ y
```

You may replace `Finset` by `List` or a more convenient finite container if dependent typing becomes painful.

**Why this matters.**
This theorem is the actual **testing oracle theorem**. It says bounded semantic inequivalence can be detected by a *finite battery of tests*. That is a new conceptual bridge between residual finiteness and practical test generation.

---

## Ambitious Quantitative Theorem Candidates

These are harder and may become conjectural if full proof is out of reach, but you should push aggressively.

### Candidate Theorem 4: Quantitative permutation separation
For finite `α` with `|α| = n`, every nontrivial reduced word `w` of length `≤ L` is nontrivial under some map into `Symm (Fin (L+1))`, or at least some `Symm (Fin (C * L))`.

Lean sketch:

```lean
theorem freeGroup_perm_separation_linear_bound
  (α : Type) [DecidableEq α] [Fintype α]
  (L : ℕ) :
  ∀ w : FreeGroup α,
    w ≠ 1 →
    wordLength w ≤ L →
    ∃ φ : α → Equiv.Perm (Fin (L+1)),
      evalFreeGroup φ w ≠ 1
```

This is the mathematically bold theorem corresponding to the conjectured “`S_{L+1}` suffices” principle.

If full proof is inaccessible, state it as the main conjecture and prove a weaker theorem with an unspecified finite permutation degree obtained from Cayley’s theorem applied to a separating finite quotient.

### Candidate Theorem 5: Quotient-to-permutation upgrade
Any finite-group separator yields a permutation-group separator of bounded degree.

```lean
theorem finite_group_separator_to_perm_separator
  {α G : Type} [DecidableEq α] [Group G] [Fintype G]
  {x y : FreeGroup α} (φ : α → G)
  (hxy : evalFreeGroup φ x ≠ evalFreeGroup φ y) :
  ∃ ψ : α → Equiv.Perm (Fin (Fintype.card G)),
    evalFreeGroup ψ x ≠ evalFreeGroup ψ y
```

This should follow from the left regular action / Cayley embedding. It is a beautiful crosswalk from abstract finite quotients to **concrete executable tests in symmetric groups**.

**Breakthrough significance.**
If Theorems 3 + 5 are proved, then bounded free-group inequivalence is decidable by a finite suite of **permutation tests**. This is exactly the sort of result that can seed a new line of verified symbolic testing.

---

## New Definitions You Should Introduce

You are required to create at least one genuinely new concept. The following are excellent candidates.

### 1. Semantic distinguishability on a class of finite groups
```lean
def SemanticallyDistinguishable
  (C : Type → Prop) -- class of test groups, e.g. finite groups or permutation groups
  {α : Type} [DecidableEq α]
  (x y : FreeGroup α) : Prop :=
  ∃ (G : Type) (_ : Group G), C G ∧
    ∃ φ : α → G, evalFreeGroup φ x ≠ evalFreeGroup φ y
```

### 2. Bounded test completeness
```lean
def TestSuiteCompleteUpTo
  (α : Type) [DecidableEq α] [Fintype α]
  (L : ℕ)
  (tests : Finset (BoundedEvaluator α)) : Prop :=
  ∀ x y : FreeGroup α,
    x ≠ y →
    wordLength x ≤ L →
    wordLength y ≤ L →
    ∃ t ∈ tests,
      let G := t.1
      let _ := (t.2.1)
      let _ := (t.2.2.1)
      let φ := (t.2.2.2)
      evalFreeGroup φ x ≠ evalFreeGroup φ y
```

### 3. Permutation separation profile
```lean
def permSepProfile
  (α : Type) [DecidableEq α] [Fintype α]
  (L : ℕ) : ℕ := ...
```

This gives a quantitative invariant of the syntax ball. It is mathematically novel and computationally testable.

---

## Proof Architecture: 3 Viable Strategies

You must not merely state results; you must architect proof routes. Here are the main avenues.

### Strategy A: Residual finiteness + finite bounded ball compactness
**Most promising for Lean and for guaranteed theorem production.**

1. Prove `x ≠ y ↔ x * y⁻¹ ≠ 1` and the evaluation transfer theorem (`eval_eq_iff_mul_inv_eq_one`).
2. Use classical residual finiteness of free groups: for each nontrivial `w`, there exists a finite group and morphism with nontrivial image of `w`.
3. Restrict to the finite set of words of length `≤ L` (requires finite generator type and finiteness of bounded reduced words / representatives).
4. Choose one separator for each inequivalent pair and package them into a finite test suite.

**Why best:**  
This route converts a deep infinite statement into a finite combinatorial oracle with minimal dependence on proving new hard group theory inside Lean. It is the cleanest path to a publishable theorem and a verified algorithm.

---

### Strategy B: Cayley graph / permutation-action realization
**Best for the symmetric-group conjecture and executable demos.**

1. Start with a separating finite quotient from residual finiteness.
2. Use the left regular action to embed the quotient into a permutation group on `|G|` points.
3. Push the separating map through this embedding to obtain a permutation-group separator.
4. Derive an explicit degree bound in terms of the size of the quotient.

**Why powerful:**  
This directly explains why **symmetric groups are universal test environments**. It is the bridge from abstract algebra to practical finite-state testing.

---

### Strategy C: Schreier/Stallings automata for explicit quantitative bounds
**Most visionary, hardest to formalize, likely partially conjectural.**

1. Represent a nontrivial reduced word by a path in the bouquet of `n` loops.
2. Build a finite covering / Stallings automaton in which the path does not close.
3. Extract a finite permutation representation from the action on cosets / covering sheets.
4. Attempt to prove a degree bound polynomial or linear in `L`, ideally `L+1`.

**Why revolutionary:**  
If successful, this upgrades residual finiteness from existential to **constructive quantitative separation**. It would connect formal language methods, automata, and low-dimensional topology to compiler testing.

**Recommendation:**  
Use Strategy A for the core formal theorems, Strategy B for the universal symmetric-group corollary, and frame Strategy C as the main future theorem/conjecture with computational evidence.

---

## Cross-Domain Connections You Must Explicitly Develop

This project is not “just group theory.” You must foreground the following bridges.

### 1. Verified compilation / program equivalence
Distinct reduced words are distinct programs in a reversible algebraic IR. Your theorems imply:

- semantic inequivalence is witnessed in a finite model,
- bounded inequivalence is witnessed in a finite family of finite models,
- compiler rewrites can be tested against a mathematically complete bounded oracle.

This is a new certified analogue of **QuickCheck for algebraic semantics**.

### 2. Property-based testing and model checking
Finite groups become test models. Symmetric groups become **universal finite-state environments**. This connects:

- residual finiteness,
- finite-model completeness on bounded syntax classes,
- exhaustive bounded semantic testing.

### 3. Automata and formal languages
Reduced words of bounded length form a regular language. Distinguishability can be viewed as a language-separation phenomenon via finite-state actions. This suggests a bridge to:

- automata minimization,
- symbolic execution,
- finite-state semantics.

### 4. Geometry/topology
If you pursue Stallings foldings, then semantic distinguishability is encoded by finite graph covers of a wedge of circles. This creates a striking connection between:

- free groups,
- graph coverings,
- executable testing oracles.

### 5. Complexity theory
The function `permSepProfile α L` is a new complexity invariant: how large a permutation universe is required to separate all inequivalent programs up to size `L`? This invites asymptotic study:
- linear?
- polynomial?
- exponential?
- sensitive to rank `|α|`?

---

## Application Keywords

Use these explicitly in your paper and article:

**residual finiteness, free groups, semantic distinguishability, bounded model completeness, finite quotient testing, permutation group oracle, compiler verification, property-based testing, Cayley embedding, Stallings folding, symbolic semantics, finite-state witnesses, algebraic program equivalence, quantitative group theory**

---

## Catalog Building Blocks

You must build concretely on:

- `Pythagorean/VerifiedCompilerSynthesis.lean`
  - `evalFreeGroup`
  - `freeGroup_eval_natural`

Do not mention these passively. Use them as the certified semantic interface:
- `evalFreeGroup` should be your main evaluator for free-group expressions into target groups.
- `freeGroup_eval_natural` should be exploited to prove functoriality / naturality of evaluation under homomorphisms, especially in the quotient-to-permutation upgrade.

If needed, create auxiliary lemmas showing:
- evaluation respects multiplication,
- evaluation respects inverse,
- postcomposition with a homomorphism commutes with evaluation.

These are likely the technical spine of Theorems 2 and 5.

---

## Concrete Lean 4 Formalization Targets

You should aim for a file containing at least the following theorem signatures, adapted as needed to actual APIs:

```lean
theorem eval_eq_iff_mul_inv_eq_one
  {α G : Type} [DecidableEq α] [Group G]
  (φ : α → G) (x y : FreeGroup α) :
  evalFreeGroup φ x = evalFreeGroup φ y ↔
    evalFreeGroup φ (x * y⁻¹) = 1
```

```lean
theorem freeGroup_finite_separation_bounded
  (α : Type) [DecidableEq α] [Fintype α]
  (L : ℕ) :
  ∀ x y : FreeGroup α,
    x ≠ y →
    wordLength x ≤ L →
    wordLength y ≤ L →
    ∃ (G : Type) (_ : Group G) (_ : Fintype G),
      ∃ φ : α → G,
        evalFreeGroup φ x ≠ evalFreeGroup φ y
```

```lean
theorem finite_group_separator_to_perm_separator
  {α G : Type} [DecidableEq α] [Group G] [Fintype G]
  {x y : FreeGroup α} (φ : α → G)
  (hxy : evalFreeGroup φ x ≠ evalFreeGroup φ y) :
  ∃ ψ : α → Equiv.Perm (Fin (Fintype.card G)),
    evalFreeGroup ψ x ≠ evalFreeGroup ψ y
```

```lean
theorem finite_test_suite_exists
  (α : Type) [DecidableEq α] [Fintype α]
  (L : ℕ) :
  ∃ tests : Finset (BoundedEvaluator α),
    TestSuiteCompleteUpTo α L tests
```

If a full residual finiteness theorem for free groups is absent from Mathlib, you have two acceptable options:
1. Prove a weaker but still nontrivial version for a concrete rank (e.g. two generators) and bounded words, using explicit constructions.
2. Introduce an axiomatically packaged theorem interface around a catalog or literature result, but then fully prove the downstream bounded finite-test-suite theorem in Lean.

The second option is acceptable only if the downstream structure is genuinely deep and new.

---

## Computational Conjecture and Falsifiable Prediction

You must state and investigate this conjecture:

> **Conjecture (Universal symmetric-group separator).**  
> For the free group on `n` generators, every nontrivial reduced word of length at most `L` is separated from the identity by some evaluation into `S_{L+1}`. Equivalently, every pair of distinct reduced words of length at most `L` are separated by some evaluation into `S_{L+1}`.

A Lean-friendly predicate:

```lean
def UniversalSymmSeparatorUpTo
  (α : Type) [DecidableEq α] [Fintype α]
  (L k : ℕ) : Prop :=
  ∀ x y : FreeGroup α,
    x ≠ y →
    wordLength x ≤ L →
    wordLength y ≤ L →
    ∃ φ : α → Equiv.Perm (Fin k),
      evalFreeGroup φ x ≠ evalFreeGroup φ y
```

Conjectural statement:

```lean
conjecture universal_symm_separator_L_add_one
  (α : Type) [DecidableEq α] [Fintype α]
  (L : ℕ) :
  UniversalSymmSeparatorUpTo α L (L + 1)
```

### Test protocol
For `n = 2` and `L ∈ {3,4,5,6}`:
1. Enumerate reduced words of length `≤ L`.
2. For each pair `(x,y)`, search for `k ∈ {3,4,5,6,7}` and `φ : α → S_k` separating them.
3. Record the smallest such `k`.
4. Plot the maximal required `k` versus `L`.

### Falsification criterion
If any pair with `L ≤ 5` requires `k > 7`, then the `S_{L+1}` conjecture is too optimistic in its current form.

You should also formulate a second, weaker fallback conjecture:
> There exists a universal constant `C` such that `S_{C L}` suffices.

This gives the project robustness even if the sharp linear bound fails.

---

## Required Deliverables

You must produce **all** of the following:

### 1. Lean file with deep proofs
At least 3 nontrivial theorems, with proof scripts that genuinely use:
- induction,
- `rcases`,
- `by_contra`,
- multi-step `calc`,
- explicit algebraic rewrites,
- and/or finite combinatorial packaging.

Minimize `sorry`. If one strategic `sorry` remains, isolate it to the deepest imported classical residual finiteness lemma and prove everything downstream from it.

### 2. `FUTURE_DIRECTIONS.md`
Include **3–5 falsifiable scientific hypotheses**, each with a clear computational or formal test. Examples:

- **Hypothesis 1:** `permSepProfile (Fin 2) L ≤ L+1` for all `L ≤ 8`.  
  **Test:** exhaustive search over reduced words and assignments into `S_k`, `k ≤ 9`.

- **Hypothesis 2:** The maximal minimal separating degree for rank 2 grows linearly in `L`.  
  **Test:** fit computed data for `L ≤ 10`; disconfirm if superlinear lower envelopes appear.

- **Hypothesis 3:** Random pairs of reduced words are typically separated by `S_3` or `S_4`.  
  **Test:** Monte Carlo over random reduced words; estimate empirical distribution.

- **Hypothesis 4:** Stallings-automaton constructions produce smaller separating permutation degrees than brute-force quotient search.  
  **Test:** compare separator sizes algorithmically.

Each hypothesis must be falsifiable, not vague.

### 3. `RESEARCH_PAPER.md`
A standalone scientific document containing:
- motivation from residual finiteness and semantics,
- precise theorem statements,
- proof ideas,
- computational evidence,
- limitations,
- and future directions.

A reader with no code access must understand the discovery.

### 4. `ARTICLE.md`
Write it in **Scientific American** style:
- vivid,
- accessible,
- conceptually accurate,
- explaining how an abstract theorem about free groups becomes a tool for testing software transformations.

### 5. Verified algorithm / computational method
Implement a certified or partially certified procedure that:
- enumerates reduced words up to length `L`,
- searches finite permutation assignments,
- detects separators,
- and reports a finite test suite or separation profile.

Even if the search itself is external/Python, the mathematical specification should be explicit and tied back to the Lean definitions.

### 6. `demo.py`
An interactive demonstration that:
- takes two words in generators,
- searches for a finite symmetric-group separator,
- displays the smallest `k` found,
- and can batch-test all pairs up to a chosen `L`.

A compelling demo is not optional; it is the experimental arm of the theorem.

---

## Final Scientific Charge

Do not settle for merely re-proving a classical fact. The target is to create a new theorem-schema:

> **bounded inequivalence in free-group semantics admits finite, concrete, permutation-model witnesses**

That principle has the flavor of a new doctrine:
- residual finiteness becomes **semantic observability**,
- finite quotients become **test environments**,
- symmetric groups become **universal executable models**.

If you can prove the bounded finite-test-suite theorem and the quotient-to-permutation upgrade, you will have opened a new lane between **group theory and formal methods**. If you can push further toward `S_{L+1}`, you may have the seed of an entirely new quantitative theory of algebraic program testing.

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
