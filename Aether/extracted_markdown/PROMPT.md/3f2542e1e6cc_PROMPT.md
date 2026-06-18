Soli Deo Gloria

## Assignment: Direction 1 — Capture-Free Monotonicity via De Bruijn Indices

**Mode:** prove

Build a new de Bruijn-indexed λ-calculus complexity theory in Lean 4 that decisively separates **affine** computation from unrestricted β-reduction by proving a certified monotonicity law for branching complexity under capture-avoiding substitution.

This is not a refactor of the named-variable development. It is a conceptual leap: if the named-variable counterexample disappears in the intrinsically capture-free de Bruijn setting under an affine hypothesis, then we obtain a mathematically clean explanation for why duplication — not β-reduction itself — drives combinatorial explosion. That would be a breakthrough-level result at the interface of λ-calculus, implicit computational complexity, and linear logic.

You should build on:

- `Pythagorean/BoundedBetaTheorems.lean`
- `Pythagorean/BranchComplexity.lean`

and explicitly explain in the paper how the de Bruijn formalization isolates the source of growth phenomena more cleanly than named syntax.

---

## Core Vision

The central scientific claim to attack is:

> **Affine β-reduction in de Bruijn form is branch-monotone.**  
> If a term uses each bound variable at most once in the relevant affine sense, then a β-step cannot increase the branching complexity of the term.

If true, this yields the first clean, certified complexity separation theorem of the following form:

- **Affine fragment:** polynomially bounded reachable-state growth.
- **General λ-calculus:** potentially exponential state growth via duplication.

This would connect:

- **Programming languages:** affine/linear usage disciplines
- **Complexity theory:** implicit complexity and syntactic resource bounds
- **Proof theory:** linear logic’s ban on contraction as a complexity principle
- **Rewriting theory:** monotone potentials for reduction systems

Application keywords: `lambda calculus`, `de Bruijn indices`, `implicit computational complexity`, `linear logic`, `rewriting invariants`, `resource-sensitive computation`, `state-space growth`, `beta reduction`, `proof theory`, `symbolic execution`

---

## Precise Formal Targets

You must define a de Bruijn λ-calculus and prove at least **3 substantial theorems** with nontrivial proof structure. Avoid trivial automation. Use induction, rcases, by_contra, and multi-step `calc` proofs where appropriate.

### 1. New syntax and substitution infrastructure

Introduce a new syntax, e.g.

```lean
inductive DBTerm : Type
| var : Nat → DBTerm
| app : DBTerm → DBTerm → DBTerm
| lam : DBTerm → DBTerm
```

with standard operations:

- `shift : Nat → Nat → DBTerm → DBTerm`
- `subst : Nat → DBTerm → DBTerm → DBTerm`
- one-step β-reduction `BetaDB : DBTerm → DBTerm → Prop`

A canonical β-rule should have the shape:

```lean
| beta : BetaDB (DBTerm.app (DBTerm.lam t) s) (subst 0 s t)
```

possibly with the usual shift/unshift discipline encoded inside `subst`.

### 2. Novel resource-sensitive notion

Define at least one genuinely new concept, for example:

- `AffineAt : Nat → DBTerm → Prop` meaning the variable at de Bruijn level `k` occurs at most once
- `AffineClosed : DBTerm → Prop` meaning every bound variable is used at most once in its scope
- `branchComplexityDB : DBTerm → Nat`
- `redexCountDB : DBTerm → Nat`
- `stateGrowthDB : DBTerm → Nat → Nat`

A promising Lean shape is:

```lean
def branchComplexityDB : DBTerm → Nat
def redexCountDB : DBTerm → Nat
def AffineClosed : DBTerm → Prop
def StateSetDB : DBTerm → Nat → Finset DBTerm
def stateGrowthDB (t : DBTerm) (d : Nat) : Nat := (StateSetDB t d).card
```

If finite-state infrastructure from the catalog can be reused, do so explicitly.

---

## Theorem Targets

You should aim to prove the following theorem family, with precise Lean signatures as close as possible to these.

### Theorem A — Affine substitution does not increase branch complexity

This is the flagship theorem.

```lean
theorem branchComplexityDB_subst_le
  (t s : DBTerm) :
  AffineAt 0 t →
  branchComplexityDB (subst 0 s t) ≤
    max (branchComplexityDB t) (branchComplexityDB s)
```

or, if your `branchComplexityDB` is designed to ignore the substituted argument’s internal branching when it is merely inserted linearly, the stronger form:

```lean
theorem branchComplexityDB_subst_affine_le
  (t s : DBTerm) :
  AffineAt 0 t →
  branchComplexityDB (subst 0 s t) ≤ branchComplexityDB t + branchComplexityDB s
```

Most desirable is a formulation strong enough to imply β-step monotonicity for closed affine terms.

### Theorem B — β-step monotonicity for affine closed terms

```lean
theorem branchComplexityDB_beta_monotone
  {t u : DBTerm} :
  AffineClosed t →
  BetaDB t u →
  branchComplexityDB u ≤ branchComplexityDB t
```

This is the decisive theorem. It should not be proved by brute-force case enumeration alone; the proof must expose the structural reason monotonicity holds.

### Theorem C — Polynomial state-space bound

Using the catalog’s finiteness/state-growth framework, prove a recurrence-style upper bound:

```lean
theorem stateGrowthDB_le_pow_branchComplexity
  (t : DBTerm) (d : Nat) :
  AffineClosed t →
  stateGrowthDB t d ≤ branchComplexityDB t ^ d
```

If the exact exponent/base needs adjustment due to indexing conventions, that is acceptable, but the result must still be a genuine polynomial/exponential-in-depth control theorem derived from branch monotonicity plus branching bounds.

### Theorem D — Cross-domain bridge to linear logic / no-contraction principle

You must include at least one theorem explicitly connecting this development to another domain. A strong candidate:

```lean
theorem affine_closed_prevents_duplication
  (t : DBTerm) :
  AffineClosed t →
  redexCountDB t ≤ sizeDB t
```

and then interpret it in `RESEARCH_PAPER.md` as a λ-calculus analogue of the **absence of contraction** in linear logic.

Even better would be a theorem showing a quantitative resource law reminiscent of proof-net complexity, e.g. that affine substitution is 1-Lipschitz with respect to an occurrence-count seminorm.

Possible Lean target:

```lean
def varOccurrences : Nat → DBTerm → Nat

theorem varOccurrences_subst_affine
  (t s : DBTerm) :
  AffineAt 0 t →
  varOccurrences k (subst 0 s t) ≤
    varOccurrences (k+1) t + varOccurrences k s
```

This would create a real bridge from syntax to quantitative logic.

---

## Recommended Proof Architecture

You must provide at least 2–3 proof routes in your writeup and pursue the most promising one in Lean.

### Strategy A — Structural substitution accounting via occurrence bounds
Most promising.

1. Define `varOccurrences : Nat → DBTerm → Nat`.
2. Define `AffineAt k t : Prop := varOccurrences k t ≤ 1`.
3. Prove a substitution accounting lemma: substitution at an affine index inserts the argument into at most one location.
4. Deduce that no new parallel branching sites can be created beyond those already present in the function body and the inserted term.
5. Lift this to β-step monotonicity for affine closed terms.

Why this is promising: de Bruijn indices make binding arithmetic explicit, so occurrence counting and substitution accounting become exact structural recurrences rather than α-equivalence arguments.

### Strategy B — Potential-function proof via local redex geometry
Also strong.

1. Define `branchComplexityDB` as a local potential counting branching opportunities in application spines / redex neighborhoods.
2. Prove that β-reduction transforms one redex neighborhood into a substitution image.
3. Show affine use of the bound variable prevents the substitution image from duplicating a branch-creating application node.
4. Conclude monotonicity by local comparison plus context monotonicity.

Why this is attractive: it aligns closely with the intuition from rewriting theory — define a potential and show each step does not increase it.

### Strategy C — Simulation from linear/affine typed λ-calculus
More ambitious, less likely to finish first.

1. Define a lightweight affine judgment or usage certificate.
2. Prove that certified affine terms satisfy `AffineClosed`.
3. Use the typing derivation to prove substitution preserves non-duplication.
4. Transfer complexity monotonicity from usage derivations to raw de Bruijn terms.

Why this matters: it opens a route to typed implicit complexity. Why it is secondary: typing infrastructure may cost too much compared with direct syntactic occurrence-counting.

Pursue **Strategy A first**, using **Strategy B** as a fallback or interpretive layer.

---

## Key Intermediate Lemmas You Will Likely Need

These should become named lemmas in Lean, not just proof-local facts.

```lean
theorem varOccurrences_shift
  (t : DBTerm) (c d k : Nat) :
  ...

theorem varOccurrences_subst
  (t s : DBTerm) (k j : Nat) :
  ...

theorem AffineAt_lam
  (t : DBTerm) :
  AffineAt (k+1) t → AffineAt k (DBTerm.lam t)

theorem AffineClosed_subterm_app_left
  {t u : DBTerm} :
  AffineClosed (DBTerm.app t u) → AffineClosed t

theorem AffineClosed_subterm_app_right
  {t u : DBTerm} :
  AffineClosed (DBTerm.app t u) → AffineClosed u

theorem BetaDB_context_monotone
  {t u C} :
  BetaDB t u →
  branchComplexityDB (plugDB C u) ≤ branchComplexityDB (plugDB C t)
```

If evaluation contexts are too heavy, use direct induction on the β-step derivation.

---

## Cross-Domain Mathematical Insight

Do not treat this as a purely PL exercise. Frame and prove at least one theorem that reveals a deeper principle:

### Linear logic connection
Affine terms are exactly the fragment where contraction is absent. Your monotonicity theorem should be presented as a **syntactic complexity shadow of cut-elimination without contraction**.

### Implicit complexity connection
The state-growth bound should be interpreted as a machine-independent complexity certificate: syntax alone guarantees polynomially controlled nondeterministic exploration up to depth `d`.

### Rewriting/thermodynamic analogy
`branchComplexityDB` behaves like a discrete free energy: unrestricted β-reduction can increase it through duplication, but affine β-reduction cannot. If you can formulate a monotone potential theorem cleanly, this is publishable-quality conceptual packaging.

### Possible combinatorics bridge
If you define occurrence vectors or multiset profiles of variable usage, connect them to subadditivity/majorization ideas. Even one theorem in this direction would elevate the work.

---

## Computational Experiment Requirement

You must implement a verified or semi-verified computational method, not just theorem statements.

### Required algorithmic deliverable
Implement:

- random affine de Bruijn term generator for sizes 5–20
- β-step enumerator up to depth 10
- checker for `branchComplexityDB u ≤ branchComplexityDB t` along all explored paths

This should support the falsifiable conjecture:

> **Conjecture.** For every closed affine de Bruijn term `t` and every β-step `t →β u`,  
> `branchComplexityDB u ≤ branchComplexityDB t`.

### Testable prediction
On 1000+ random closed affine terms of sizes 5–20, exhaustive exploration of β-paths of length ≤ 10 should produce no counterexample.  
A single counterexample refutes the conjecture.

If the theorem as initially stated fails, pivot immediately to a corrected invariant, for example:

- monotonicity of a modified `branchPotentialDB`
- monotonicity under weak-head β only
- monotonicity for a stricter affine fragment
- additive bound `branchComplexityDB u ≤ branchComplexityDB t + c`

A negative result with a sharp counterexample is scientifically valuable and should be formalized if discovered.

---

## Suggested Lean 4 Type Signatures

Use these as targets, adapting names as needed to match the local codebase.

```lean
inductive DBTerm : Type
| var : Nat → DBTerm
| app : DBTerm → DBTerm → DBTerm
| lam : DBTerm → DBTerm

def shift : Nat → Nat → DBTerm → DBTerm
def subst : Nat → DBTerm → DBTerm → DBTerm
def branchComplexityDB : DBTerm → Nat
def redexCountDB : DBTerm → Nat
def varOccurrences : Nat → DBTerm → Nat
def AffineAt : Nat → DBTerm → Prop
def AffineClosed : DBTerm → Prop
def stateGrowthDB : DBTerm → Nat → Nat

inductive BetaDB : DBTerm → DBTerm → Prop
```

Flagship theorem signatures:

```lean
theorem subst_preserves_affine
  (t s : DBTerm) :
  AffineClosed t →
  AffineClosed s →
  AffineClosed (subst 0 s t)

theorem branchComplexityDB_subst_affine_le
  (t s : DBTerm) :
  AffineAt 0 t →
  branchComplexityDB (subst 0 s t) ≤ branchComplexityDB t

theorem branchComplexityDB_beta_monotone
  {t u : DBTerm} :
  AffineClosed t →
  BetaDB t u →
  branchComplexityDB u ≤ branchComplexityDB t

theorem stateGrowthDB_le_pow_branchComplexity
  (t : DBTerm) (d : Nat) :
  AffineClosed t →
  stateGrowthDB t d ≤ branchComplexityDB t ^ d
```

If the direct `≤ branchComplexityDB t` statement is too strong, weaken carefully and explain why:

```lean
theorem branchComplexityDB_beta_monotone'
  {t u : DBTerm} :
  AffineClosed t →
  BetaDB t u →
  branchComplexityDB u ≤ max 1 (branchComplexityDB t)
```

But do not weaken preemptively without evidence.

---

## Nontriviality Requirements

Your Lean file must contain at least 3 substantial theorems using deep proof tactics. Good candidates:

1. substitution-occurrence accounting by structural induction
2. affine-substitution branch bound
3. β-step monotonicity by cases on reduction plus previous lemmas
4. state-growth recurrence bound via induction on depth

Do **not** discharge the core mathematics by `native_decide`, `decide`, `norm_num`, or bare `rfl`.

---

## Deliverables — ALL mandatory

You must produce all of the following:

1. **Lean development** with minimized `sorry`, implementing the de Bruijn calculus, complexity measures, and at least 3 deep theorems.
2. **`FUTURE_DIRECTIONS.md`** with **3–5 falsifiable scientific hypotheses**, each with:
   - a precise conjecture
   - what experiment/test would refute it
   - what theorem would follow if true
3. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - problem statement
   - precise definitions
   - theorem statements
   - proof ideas
   - significance for λ-calculus, implicit complexity, and linear logic
   - limitations and next steps
4. **`ARTICLE.md`** in Scientific American style:
   - accessible exposition
   - focus on the mathematical ideas and significance
   - do **not** focus on formal verification machinery
5. **A verified algorithm or computational method**
   - affine term generator / reduction explorer / invariant checker
6. **`demo.py`**
   - interactively generate random affine terms
   - display β-reduction paths up to depth 10
   - compute `branchComplexityDB`
   - highlight whether monotonicity holds on sampled terms

---

## Scientific Payoff

If you succeed, you will have isolated a fundamental law:

> **Duplication, not substitution itself, is the engine of λ-calculus state explosion.**

That is the kind of theorem that changes how people package complexity in rewriting systems. It opens the door to:

- machine-independent polynomiality criteria for higher-order computation
- affine/linear resource analyses for symbolic evaluators
- complexity semantics for proof normalization
- certified search-space bounds for higher-order program synthesis

And if the conjecture fails, a de Bruijn counterexample would be equally important: it would prove that the obstruction is deeper than variable capture and force the invention of a subtler potential function. Either outcome is scientifically meaningful.

Be bold, precise, and structural. The right result here is not just another λ-calculus lemma — it is a new complexity principle.

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
