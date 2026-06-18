## Assignment: Proof Expansion Constant for Formal Theories

**Mode:** `prove` + `discover`

Aristotle, do not nibble at the boundary of proof complexity. Carve out a new invariant of formal theories. The conjectural object here — a **proof expansion constant** — should be treated as a geometric quantity attached to a deductive system, measuring how sharply proof length inflates under semantic strengthening. If this can be formalized even in a mathematically honest toy regime and connected to existing proof-length machinery, it opens an entirely new program: a differential geometry of theorem difficulty.

Your task is to build the first rigorous Lean 4 foundation for this program, prove several nontrivial theorems in a controlled setting, and extract an algorithmic pipeline for testing the conjecture empirically.

---

## Core Vision

The breakthrough is **not** to restate “stronger statements are harder to prove.” The breakthrough is to define a **formal strengthening metric** and prove the existence of **lower-envelope growth laws** for proof length in at least one meaningful class of theories or theorem families.

You should aim to isolate a mathematically tractable surrogate of the global conjecture and then prove theorems showing that:

1. strengthening distance is a genuine invariant or pseudometric,
2. proof-length growth under strengthening is monotone/submultiplicative/superadditive in structured families,
3. in at least one explicit family, proof expansion is provably exponential or at least sharply superpolynomial in the strengthening parameter.

This would create the first formal bridge between:
- **proof complexity**
- **model-theoretic refinement**
- **semantic entropy / information loss under strengthening**
- **automated theorem proving curriculum design**
- **complexity-aware mathematics**

---

## Precise Research Target

### New mathematical structure to define

Define a new structure encoding theorem families, strengthening, and proof cost. A good target is:

```lean
structure ProofTheoryProfile where
  Formula : Type
  Provable : Formula → Prop
  ProofCost : Formula → ℕ
  Strengthens : Formula → Formula → Prop
  semDist : Formula → Formula → ℕ
  strengthens_refl :
    ∀ φ, Strengthens φ φ
  strengthens_trans :
    ∀ {φ ψ χ}, Strengthens φ ψ → Strengthens ψ χ → Strengthens φ χ
  semDist_zero_of_strengthens_both :
    ∀ {φ ψ}, Strengthens φ ψ → Strengthens ψ φ → semDist φ ψ = 0
  semDist_monotone :
    ∀ {φ ψ χ}, Strengthens φ ψ → Strengthens ψ χ →
      semDist φ χ ≥ semDist φ ψ
```

Then define a theory-dependent lower envelope:

```lean
def proofExpansionRatio (P : ProofTheoryProfile) (φ ψ : P.Formula) : Rat :=
  (P.ProofCost ψ : Rat) / (P.ProofCost φ : Rat)

def admitsExpansionConstant (P : ProofTheoryProfile) (h : Rat) : Prop :=
  0 < h ∧
  ∀ n : ℕ, ∃ φ ψ : P.Formula,
    P.Strengthens φ ψ ∧
    n ≤ P.semDist φ ψ ∧
    ((Real.exp (h * P.semDist φ ψ)) : Real) ≤
      ((P.ProofCost ψ : Real) / (P.ProofCost φ : Real))
```

This exact formulation may need adaptation because `Real.exp` over naturals/rationals and coercions can become awkward. If so, replace by base-2 exponential lower bounds, which are cleaner in Lean:

```lean
def admitsBinaryExpansionConstant (P : ProofTheoryProfile) (k : ℕ) : Prop :=
  0 < k ∧
  ∀ n : ℕ, ∃ φ ψ : P.Formula,
    P.Strengthens φ ψ ∧
    n ≤ P.semDist φ ψ ∧
    k ^ (P.semDist φ ψ) * P.ProofCost φ ≤ P.ProofCost ψ
```

This is likely the right formal target in Lean 4.

---

## Exact Theorem Targets

You must prove at least 3 substantial theorems. Here is the theorem package I recommend.

### Theorem 1: Strengthening distance induces a preorder-compatible pseudometric law

In a suitable theorem-family model, prove that semantic strengthening distance is subadditive along chains.

**Mathematical statement:**
For any formulas `φ ψ χ`, if `φ ⪯ ψ` and `ψ ⪯ χ`, then
\[
d(\phi,\chi) \ge d(\phi,\psi), \qquad
d(\phi,\chi) \le d(\phi,\psi) + d(\psi,\chi)
\]
for a suitable strengthening distance `d`.

A tractable concrete instance: formulas parameterized by natural-number complexity indices, with strengthening corresponding to index growth.

**Lean 4 type signature candidate:**
```lean
theorem semDist_subadditive
  (P : ProofTheoryProfile)
  (triangle :
    ∀ φ ψ χ, P.semDist φ χ ≤ P.semDist φ ψ + P.semDist ψ χ)
  (φ ψ χ : P.Formula) :
  P.semDist φ χ ≤ P.semDist φ ψ + P.semDist ψ χ := by
  exact triangle φ ψ χ
```

But do **not** stop at an axiom wrapper. Instantiate this for an explicit family where formulas are indexed objects and `semDist` is constructed, e.g.:

```lean
structure IndexedFamily where
  stmt : ℕ → Prop
  cost : ℕ → ℕ

def indexSemDist (i j : ℕ) : ℕ := j - i

theorem indexSemDist_triangle (i j k : ℕ) :
    indexSemDist i k ≤ indexSemDist i j + indexSemDist j k := by
  -- nontrivial proof using Nat.sub_eq, cases, arithmetic lemmas, calc
```

This theorem matters because it shows that strengthening distance is not an ad hoc statistic but a geometric quantity.

---

### Theorem 2: Exponential proof expansion in a constructed hierarchical family

Construct an explicit family `Φ_n` such that:
- `Φ_n` strengthens `Φ_m` whenever `m ≤ n`,
- `semDist(Φ_m, Φ_n) = n - m`,
- `ProofCost(Φ_n) = c * b^n` or at least satisfies a recurrence forcing exponential growth.

Then prove:
\[
\forall m \le n,\quad \mathrm{ProofCost}(\Phi_n) \ge 2^{n-m}\,\mathrm{ProofCost}(\Phi_m).
\]

**Lean 4 type signature candidate:**
```lean
def hierarchicalCost : ℕ → ℕ
| 0 => 1
| n + 1 => 2 * hierarchicalCost n

theorem hierarchicalCost_closed_form_lower (m n : ℕ) (h : m ≤ n) :
    2 ^ (n - m) * hierarchicalCost m ≤ hierarchicalCost n := by
  -- deep induction on the gap n - m or on a witness k with n = m + k
```

This is the first rigorous toy model of a proof expansion constant. It is not the final conjecture, but it is a mathematically meaningful witness that the phenomenon is coherent.

A stronger version:

```lean
theorem hierarchical_expansion_constant :
    ∀ m n : ℕ, m ≤ n →
      2 ^ (n - m) * hierarchicalCost m ≤ hierarchicalCost n := by
  intro m n hmn
  rcases Nat.exists_eq_add_of_le hmn with ⟨k, rfl⟩
  induction k with
  | zero =>
      simp [hierarchicalCost]
  | succ k ih =>
      -- multi-step calc, Nat.pow_succ, recursion unfolding
```

This theorem should be proved by induction and `rcases`, not by simplification magic.

---

### Theorem 3: Cross-domain theorem connecting semantic strengthening to entropy / information loss

You are required to include a cross-domain connection. The cleanest one is to interpret strengthening as **model-class shrinkage**, and define a finite-model entropy surrogate:
\[
H(\phi) = \log |\mathrm{Mod}_N(\phi)|
\]
for formulas over a finite universe of bounded structures. If `ψ` strengthens `φ`, then the model class shrinks, so entropy decreases.

Prove a theorem of the form:

\[
\phi \preceq \psi \implies H(\psi) \le H(\phi).
\]

If full logs are annoying in Lean, use cardinal monotonicity instead:

```lean
theorem strengthening_model_count_monotone
  {α : Type} [Fintype α]
  (S T : Finset α)
  (h : T ⊆ S) :
  T.card ≤ S.card := by
  exact Finset.card_le_card h
```

Then package this as a semantic theorem family:
- formulas correspond to subsets of a finite model space,
- strengthening is reverse inclusion on model sets,
- semantic distance can be cardinal drop or codimension-like deficit.

A richer theorem:

```lean
def modelShrinkDist {α : Type} [Fintype α] (S T : Finset α) : ℕ :=
  S.card - T.card

theorem modelShrinkDist_additive_of_nested
  {α : Type} [Fintype α]
  (U T S : Finset α)
  (hUT : U ⊆ T) (hTS : T ⊆ S) :
  modelShrinkDist S U = modelShrinkDist S T + modelShrinkDist T U := by
  -- use card_sdiff, subset transitivity, arithmetic
```

This is a genuine bridge between **proof complexity** and **information theory/statistical physics**:
strengthening reduces semantic phase space; proof difficulty may correlate with free-energy drop.

---

### Theorem 4: A no-free-lunch lower-bound transfer principle

Prove a transfer theorem: if proof cost dominates semantic shrinkage in one hierarchical encoding, then any embedding preserving strengthening and distance inherits an expansion lower bound.

**Abstract statement:**
If `f : A → B` preserves strengthening and scales distance below by `c`, and proof cost in `B` grows at least exponentially in distance, then pulled-back proof cost in `A` also has exponential lower growth.

**Lean sketch:**
```lean
theorem expansion_transfer
  (costA costB : ℕ → ℕ)
  (f : ℕ → ℕ)
  (hfmono : Monotone f)
  (hcostB : ∀ m n, m ≤ n → 2 ^ (f n - f m) * costB (f m) ≤ costB (f n))
  (hcompare : ∀ n, costA n ≤ costB (f n)) :
  ∀ m n, m ≤ n → 2 ^ (f n - f m) * costA m ≤ costB (f n) := by
  -- multi-step calc proof
```

This theorem is strategically important because it turns one toy hierarchy into a **methodology** for importing lower bounds across domains.

---

## Most Promising Formalization Path

The global conjecture about recursively axiomatized theories is too large to settle in one cycle. The right move is to prove a mathematically serious surrogate in a finite or indexed setting and make it extensible.

### Strategy A: Indexed theorem families with explicit proof-cost recurrences
This is the most promising route.

1. Represent formulas/theorems by indices `n : ℕ`.
2. Define strengthening by `m ≤ n`.
3. Define semantic distance by `n - m`.
4. Define proof cost recursively or as the minimal cost of a compositional derivation.
5. Prove exponential lower bounds by induction on the gap.

**Why best:** Lean handles indexed structures, order arguments, and recursive cost functions well. This gives deep theorems quickly and cleanly.

---

### Strategy B: Finite-model semantics and model-class shrinkage
1. Let formulas be represented by subsets of a finite model universe.
2. Strengthening is reverse inclusion.
3. Semantic distance is cardinal drop, codimension, or a weighted combination.
4. Prove monotonicity/additivity properties of distance.
5. Connect proof-cost heuristics to semantic shrinkage.

**Why important:** This gives the semantic content the conjecture needs. It upgrades “distance” from syntactic bookkeeping to a model-theoretic invariant.

---

### Strategy C: Proof DAG / derivation grammar complexity
1. Define a small proof system for a family of statements.
2. Define proof length as size of derivation trees or DAGs.
3. Show that strengthening forces extra derivational layers.
4. Prove lower bounds from grammar depth or branching constraints.

**Why valuable:** This is closest in spirit to true proof complexity. Harder to formalize, but potentially the most publishable if you can get a clean lower bound.

---

## Recommended Concrete Formal Model

Use a two-layer design.

### Layer 1: Abstract interface
Create `ProofTheoryProfile` or a lighter variant.

### Layer 2: Explicit instances
Implement at least two instances:
1. **Indexed hierarchy instance**
2. **Finite-model shrinkage instance**

Then prove that the indexed hierarchy satisfies an expansion constant and the finite-model instance satisfies semantic monotonicity/additivity.

This gives both the **proof-theoretic** and **semantic** sides of the conjecture.

---

## Suggested Lean 4 Definitions

These are not mandatory exact names, but the mathematical architecture should look like this:

```lean
structure Hierarchy where
  cost : ℕ → ℕ
  monotone_cost : Monotone cost

def strengthensIdx (m n : ℕ) : Prop := m ≤ n

def gapDist (m n : ℕ) : ℕ := n - m

def hasBinaryExpansion (H : Hierarchy) (b : ℕ) : Prop :=
  1 < b ∧
  ∀ m n, m ≤ n → b ^ (n - m) * H.cost m ≤ H.cost n
```

Main theorem target:

```lean
theorem recursive_doubling_hasBinaryExpansion :
    hasBinaryExpansion
      { cost := hierarchicalCost
        monotone_cost := by
          intro a b hab
          -- nontrivial proof
      } 2 := by
  refine ⟨by decide, ?_⟩
  intro m n hmn
  exact hierarchical_expansion_constant m n hmn
```

Also define a semantic side:

```lean
def strengthensSet {α : Type} (S T : Set α) : Prop := T ⊆ S

def finiteSemDist {α : Type} [Fintype α] [DecidableEq α]
    (S T : Finset α) : ℕ :=
  S.card - T.card
```

Then prove nested additivity or monotonicity.

---

## Deep Proof Tactics Requirement

Your file must contain at least 3 theorems whose proofs genuinely use:
- `induction`
- `rcases`
- `by_contra`
- `field_simp` where relevant
- multi-step `calc`

Recommended mapping:
- Theorem 1: `rcases` on `Nat.exists_eq_add_of_le`, then `calc`
- Theorem 2: induction on strengthening gap
- Theorem 3: contradiction argument for strict monotonicity failure in finite model shrinkage
- Optional theorem: a rational normalized expansion rate requiring `field_simp`

For example, define a normalized expansion slope:
```lean
def expansionSlope (c₁ c₂ d : ℕ) : Rat := (c₂ : Rat) / ((c₁ : Rat) * d)
```
and prove positivity under assumptions using fraction manipulations. This gives a legitimate place for `field_simp`.

---

## Stronger Conjectural Program

You should state, formalize in comments/markdown, and partially test the following falsifiable conjecture.

### Conjecture: Binary Expansion Lower Envelope
For a broad class of recursively generated theorem hierarchies `H`, there exists `b > 1` such that
\[
\forall^\infty (m,n),\ m \le n \implies b^{n-m} \cdot \mathrm{cost}(m) \le \mathrm{cost}(n).
\]

### Computational falsification test
Search for hierarchies where:
- semantic distance `n-m → ∞`,
- but `cost(n)/cost(m)` remains polynomial in `n-m`.

A single explicit family with unbounded distance and polynomial blowup refutes this version.

This is exactly the kind of conjecture that should live in `FUTURE_DIRECTIONS.md`: crisp, falsifiable, computationally attackable.

---

## Cross-Domain Connections You Must Exploit

### 1. Model Theory + Information Theory
Strengthening shrinks model classes. This is semantic compression. The quantity
\[
\Delta(\phi,\psi) \approx \log |\mathrm{Mod}(\phi)| - \log |\mathrm{Mod}(\psi)|
\]
behaves like information gain. The conjecture predicts that information gain may force proof-cost inflation.

### 2. Proof Complexity + Statistical Physics
The set of models is a phase space; strengthening is a quench; proof cost is the work needed to certify a lower-entropy state. This analogy is not fluff — it suggests monotonicity and barrier theorems.

### 3. Automated Reasoning + Curriculum Learning
If a theory has a measurable expansion constant, theorem-proving curricula can be sequenced by semantic distance to avoid catastrophic proof-length jumps.

### 4. Complexity Theory + Geometry
The map
\[
(\phi,\psi) \mapsto \log \frac{\mathrm{ProofCost}(\psi)}{\mathrm{ProofCost}(\phi)}
\]
should be treated as a coarse geometric cocycle over the strengthening preorder.

These are not side remarks. They are the scientific reason this project matters.

---

## Application Keywords

proof complexity, semantic strengthening, theorem difficulty forecasting, model-theoretic entropy, automated theorem proving, curriculum design, derivational geometry, formal theories, lower bounds, information compression, statistical physics of proof, semantic phase transitions, complexity invariants, proof-length growth, Lean 4 formalization

---

## Deliverables You MUST produce

You must produce **all** of the following:

1. **Lean file(s)** with:
   - at least one genuinely new definition not already in the catalog,
   - at least 3 nontrivial theorems,
   - minimized sorrys,
   - proofs using induction / rcases / by_contra / calc / field_simp.

2. **FUTURE_DIRECTIONS.md**
   Include 3–5 testable scientific hypotheses, each falsifiable and computationally testable. At least one must explicitly describe what data would refute the proof expansion conjecture.

3. **RESEARCH_PAPER.md**
   A standalone scientific paper explaining:
   - the invariant you defined,
   - the exact theorem statements,
   - proof ideas,
   - why the toy model matters,
   - what stronger versions should be attacked next.

4. **ARTICLE.md**
   Scientific American style. Explain how “some truths may be exponentially harder than their weaker cousins,” why that matters, and how your formal model captures the phenomenon.

5. **Verified algorithm or computational method**
   Implement a method that, given a finite theorem hierarchy or finite model family, computes:
   - strengthening distance,
   - proof-cost ratios,
   - candidate lower-envelope expansion constants.

6. **demo.py**
   Interactive demonstration:
   - generate theorem hierarchies,
   - compute empirical expansion ratios,
   - visualize whether exponential lower envelopes appear,
   - include at least arithmetic/algebra/combinatorics-inspired toy families.

---

## Minimum Theorem Package Checklist

Your final Lean development should include something close to:

1. `indexSemDist_triangle`
2. `hierarchical_expansion_constant`
3. `strengthening_model_count_monotone`
4. optionally `modelShrinkDist_additive_of_nested`
5. optionally `expansion_transfer`

If you can prove all five, this becomes a serious foundational package.

---

## Final Standard

Do not merely formalize a conjecture. Produce the first credible **mathematics of proof expansion**:
- a new invariant,
- a geometric strengthening metric,
- proven lower-bound phenomena in explicit families,
- semantic monotonicity theorems,
- and an executable experimental pipeline.

If you succeed, this project opens a new field: **the differential geometry of provability**.

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
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

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

Research domain: Speculative
Research mode: prove
