## Assignment: Proof-Compression Phase Transition in Formal Mathematics

**Mode: discover + prove**

You are not being asked to merely benchmark tactics. You are being asked to create the first mathematically meaningful theory of **proof compression thresholds** inside a Lean-formalizable setting: a theory that explains when automation tracks conceptual mathematics and when it catastrophically fails without the invention of intermediate structure.

The central move is to replace vague “proof difficulty” by a formally defined semantic complexity invariant on theorem families, then prove actual threshold theorems for carefully chosen families already expressible in Mathlib. The breakthrough is not a meta-philosophical essay; it is a package of formal theorems, definitions, and verified algorithms showing that **lemma invention is not an implementation detail but a mathematically necessary phase transition phenomenon**.

Your task is to formalize a rigorous prototype of this theory in Lean 4, prove nontrivial theorems about it, and build computational evidence across domains.

---

## Core Vision

The conjecture can be made mathematically sharp by working with:

1. a formal language of **proof skeletons** or **tactic-restricted derivations**,
2. a semantic feature map `φ` on theorem instances,
3. two proof-length functionals:
   - `L_human(T)` = shortest structured proof length in a curated proof language with admissible intermediate lemmas,
   - `L_auto(T)` = shortest proof length in a restricted automation language without new lemma invention,
4. a threshold theorem showing that for some natural theorem family `T n`,
   - below complexity `φ(T n) ≤ c`, one has `L_auto(T n) ≤ C * L_human(T n)`,
   - above complexity `φ(T n) > c`, one has `L_auto(T n)` forced to blow up unless auxiliary lemmas are introduced.

Since full Kolmogorov-style minimization is not Lean-computable, the right formal move is to define **upper/lower proxy invariants** that are provably comparable and are algorithmically measurable on benchmark families. This gives a mathematically honest, formalizable phase-transition theory rather than an unverifiable claim about absolute shortest proofs.

---

## Precise Formalization Target

Define a new structure capturing theorem families with a semantic complexity score and two proof-cost models.

### New definitions to introduce

A suggested Lean-facing design:

```lean
structure ProofCostModel (α : Type _) where
  cost : α → ℕ
  monotone_under_encoding :
    ∀ {x y : α}, cost x ≤ cost y → True

structure CompressionInstance where
  theorem_id : Type
  semanticComplexity : theorem_id → ℕ
  humanCost : theorem_id → ℕ
  autoCost : theorem_id → ℕ

def compressionRatio (I : CompressionInstance) (t : I.theorem_id) : ℚ :=
  (I.autoCost t : ℚ) / max 1 (I.humanCost t : ℚ)

def HasThreshold (I : CompressionInstance) (c : ℕ) : Prop :=
  (∃ C : ℕ, ∀ t, I.semanticComplexity t ≤ c →
      I.autoCost t ≤ C * I.humanCost t) ∧
  (∀ K : ℕ, ∃ t, c < I.semanticComplexity t ∧
      K * I.humanCost t < I.autoCost t)
```

This is intentionally abstract, but it must be instantiated by at least one mathematically natural family from Mathlib. Good candidate families:

- telescoping algebraic identities,
- finite set inclusion-exclusion expansions,
- recursive combinatorial identities,
- structured inequalities requiring auxiliary factorization lemmas,
- matrix determinant/cofactor identities with increasing semantic graph width.

You should also define a notion of **lemma augmentation**:

```lean
def LemmaAugmentedCost (I : CompressionInstance) (B : Set I.theorem_id) (t : I.theorem_id) : ℕ := ...
```

where `B` is a basis of reusable lemmas, and prove that adding a small basis can collapse the auto-cost above threshold. This is the formal heart of “intermediate lemmas are necessary.”

---

## Primary Theorem Targets

You must prove at least 3 substantial theorems. They should not be toy properties of your definitions. They should establish a genuine mathematical theory.

### Theorem 1: Threshold transfer from recursive width growth

Prove an abstract theorem showing that if a theorem family admits a recursive decomposition whose human cost is linear in recursion depth, while any automation without memoized intermediate lemmas must re-expand subgoals with branching factor `b > 1`, then the compression ratio diverges.

**Precise statement idea:**

```lean
theorem superpoly_gap_of_branching
  (h : ℕ → ℕ)
  (a : ℕ → ℕ)
  (hb : ∃ b > 1, ∀ n ≥ 1, b ^ n ≤ a n)
  (hh : ∃ C, ∀ n, h n ≤ C * n)
  (ha : ∀ K, ∃ n, K * h n < a n) :
  ∀ K, ∃ n, K * h n < a n := ...
```

This abstract form is too weak on its own; strengthen it into a theorem tied to your `CompressionInstance`, e.g.:

```lean
theorem unbounded_compressionRatio_of_exponential_auto_linear_human
  (I : CompressionInstance)
  (T : ℕ → I.theorem_id)
  (hlin : ∃ C, ∀ n, I.humanCost (T n) ≤ C * n + C)
  (aexp : ∃ b > 1, ∃ n0, ∀ n ≥ n0, b ^ n ≤ I.autoCost (T n))
  : ∀ K : ℕ, ∃ n, K * I.humanCost (T n) < I.autoCost (T n) := ...
```

**Why this matters:** this theorem turns a philosophical claim into a mathematically checkable criterion: once you verify linear structured proof growth and exponential automation lower growth on a family, the phase transition follows.

---

### Theorem 2: Lemma-basis collapse theorem

Formalize and prove that if a theorem family has a finite recursive generating basis, then after adding those basis lemmas, the automation cost drops from superlinear/exponential to polynomial/linear.

**Suggested type signature:**

```lean
theorem augmented_basis_collapses_cost
  (I : CompressionInstance)
  (T : ℕ → I.theorem_id)
  (B : Finset I.theorem_id)
  (hgen : ∀ n, ∃ m ≤ n, T n ∈ B ∨ True) -- replace with real generation relation
  (hcost : ∃ C, ∀ n, LemmaAugmentedCost I (↑B : Set I.theorem_id) (T n) ≤ C * n + C)
  : ∃ C, ∀ n, LemmaAugmentedCost I (↑B : Set I.theorem_id) (T n) ≤ C * I.humanCost (T n) + C := ...
```

You should replace the placeholder generation relation by a genuine notion, such as derivability from a bounded-depth recursion DAG with shared subproofs.

**Why this matters:** this is the first formal theorem expressing the scientific thesis that **lemma discovery changes asymptotic proof complexity class**.

---

### Theorem 3: A concrete instantiated threshold theorem in a natural domain

You must instantiate the abstract theory on a real family from Mathlib. The best candidates are those where:
- human proofs use one reusable structural lemma,
- naive automation re-expands recursively.

Two promising directions:

#### Option A: Finite geometric series / telescoping family
The theorem family:
\[
T_n(x) : (x - 1)\sum_{i=0}^{n-1} x^i = x^n - 1
\]
for a commutative semiring/ring.

Human proof: induction with one algebraic rewrite.
Naive expansion without the telescoping lemma grows badly.

Possible Lean signature:

```lean
theorem geom_sum_factorization
  {R : Type _} [Ring R] (x : R) :
  ∀ n : ℕ, (x - 1) * ∑ i in Finset.range n, x^i = x^n - 1 := ...
```

Then define semantic complexity `φ(T_n) = n` or expression-tree width, and prove bounds comparing a structured recurrence cost model to a naive expansion cost model.

#### Option B: Inclusion-exclusion / Möbius-style subset expansion
The theorem family:
\[
\prod_{i=1}^n (1 + f_i) = \sum_{S \subseteq [n]} \prod_{i \in S} f_i
\]
Human proof: induction on `n` with subset splitting.
Naive tactic expansion faces `2^n` term growth.

Possible Lean signature:

```lean
theorem prod_one_add_expand
  {R : Type _} [CommSemiring R] (f : ℕ → R) :
  ∀ n : ℕ,
    ∏ i in Finset.range n, (1 + f i)
      = ∑ S in (Finset.range n).powerset, ∏ i in S, f i := ...
```

This is especially strong because the semantic complexity is literally combinatorial width, and the exponential term count is mathematically transparent.

#### Option C: Determinant/cofactor recursion
More ambitious and more revolutionary: use determinant expansion complexity and show basis lemmas collapse recursive proof cost. This has stronger cross-domain significance but may be heavier in Lean.

---

## Strongly Recommended Main Instantiation

The most promising path is **Option B**: subset expansion / inclusion-exclusion growth.

Why:
- It gives an explicit semantic complexity invariant: support size / subset-width.
- It naturally exhibits a branching factor of 2.
- It connects algebra, combinatorics, and proof search complexity.
- It has a clean theorem family in Mathlib with finite sets, products, and sums.
- It makes the “without lemma invention, proof terms blow up” thesis mathematically visible.

### Concrete theorem package for Option B

1. **Algebraic expansion theorem**
```lean
theorem prod_one_add_eq_sum_powerset
  {R : Type _} [CommSemiring R] (s : Finset α) (f : α → R) :
  ∏ x in s, (1 + f x) = ∑ t in s.powerset, ∏ x in t, f x := ...
```

2. **Cardinality/width theorem**
Prove that the number of expansion branches is exactly `2 ^ s.card`.

```lean
theorem card_powerset_eq_two_pow_card (s : Finset α) :
  s.powerset.card = 2 ^ s.card := ...
```

Then connect this to your semantic complexity feature map.

3. **Compression-gap theorem for this family**
Define a benchmark instance where:
- human cost is bounded linearly in `s.card` by induction,
- naive expansion cost is bounded below by `2 ^ s.card`.

Then prove:

```lean
theorem powerset_family_has_threshold :
  ∃ c : ℕ, HasThreshold powersetCompressionInstance c := ...
```

If a literal `HasThreshold` with finite `c` is awkward, prove the stronger and cleaner asymptotic divergence statement:

```lean
theorem powerset_family_unbounded_ratio :
  ∀ K : ℕ, ∃ n : ℕ, K * humanCost_n < autoCost_n := ...
```

This is enough to formalize the phase-transition phenomenon.

---

## Lean 4 Type Signatures You Should Actually Aim For

Use theorem statements like these, adapted as needed to actual Mathlib names and universe parameters:

```lean
structure CompressionInstance where
  theorem_id : Type
  semanticComplexity : theorem_id → ℕ
  humanCost : theorem_id → ℕ
  autoCost : theorem_id → ℕ

def HasAsymptoticGap (I : CompressionInstance) (T : ℕ → I.theorem_id) : Prop :=
  ∀ K : ℕ, ∃ n : ℕ, K * I.humanCost (T n) < I.autoCost (T n)

theorem gap_of_linear_vs_exponential
  (I : CompressionInstance)
  (T : ℕ → I.theorem_id)
  (h_human : ∃ C : ℕ, ∀ n, I.humanCost (T n) ≤ C * n + C)
  (h_auto : ∃ b : ℕ, 1 < b ∧ ∃ n0 : ℕ, ∀ n ≥ n0, b ^ n ≤ I.autoCost (T n)) :
  HasAsymptoticGap I T := ...
```

```lean
theorem prod_one_add_eq_sum_powerset
  {α R : Type _} [DecidableEq α] [CommSemiring R]
  (s : Finset α) (f : α → R) :
  ∏ x in s, (1 + f x) = ∑ t in s.powerset, ∏ x in t, f x := ...
```

```lean
theorem powerset_branching_lower_bound
  {α : Type _} [DecidableEq α] (s : Finset α) :
  2 ^ s.card ≤ s.powerset.card + 0 := by
  simpa [Finset.card_powerset]
```

```lean
def subsetExpansionInstance : CompressionInstance := ...

theorem subsetExpansion_unbounded_gap :
  ∀ K : ℕ, ∃ n : ℕ,
    K * subsetExpansionInstance.humanCost n
      < subsetExpansionInstance.autoCost n := ...
```

```lean
theorem lemma_basis_reduces_subsetExpansion
  : ∃ C : ℕ, ∀ n : ℕ,
      LemmaAugmentedCost subsetExpansionInstance basis n ≤ C * n + C := ...
```

The exact signatures may need adjustment, but the mathematical content should remain.

---

## Proof Strategy Architecture

You must present and execute 2–3 proof strategies, not just one.

### Strategy A: Abstract asymptotic transfer via recurrence inequalities
1. Define proof-cost models as natural-number valued functions.
2. Prove a general theorem: linear human recurrence + exponential automation recurrence implies unbounded compression ratio.
3. Instantiate on a theorem family.

**Why promising:** easiest to complete in Lean with `Nat`, induction, inequalities, and `calc`. This gives a reusable theorem for future domains.

### Strategy B: Combinatorial instantiation via powerset expansion
1. Prove the product-to-powerset identity by induction on `Finset`.
2. Prove exact branching count using `card_powerset`.
3. Package a `CompressionInstance` where semantic complexity is `card`, human cost is linear, automation cost is at least powerset cardinality.
4. Deduce an unbounded gap theorem and then a lemma-basis collapse theorem.

**Why most promising:** this is the cleanest mathematically and the most compelling scientifically. The branching explosion is exact, not heuristic.

### Strategy C: Algebraic/telescoping instantiation
1. Formalize a family of identities whose short proof uses one telescoping lemma.
2. Model naive proof search as repeated expansion.
3. Show a gap and then collapse after adding the telescoping lemma as a basis element.

**Why useful:** gives a second domain and supports the claim that the phenomenon is not peculiar to combinatorics.

**Recommendation:** Make Strategy B the flagship, Strategy A the abstract theorem engine, and Strategy C the cross-domain corroboration.

---

## Cross-Domain Connections You Must Surface

This project is strongest if you explicitly connect formal proof compression to other sciences.

### 1. Statistical mechanics / phase transitions
Interpret semantic complexity as an order parameter and compression ratio as susceptibility. The threshold is analogous to a critical point where local search ceases to approximate global structure.

### 2. Circuit complexity / formula vs DAG complexity
Human proofs with lemmas behave like DAG circuits with shared subcomputations; naive automation behaves like formulas without sharing. This is not metaphorical — it is the exact mathematical analogy you should exploit. If possible, define a proof-DAG sharing invariant.

### 3. Information theory / minimum description length
Intermediate lemmas act as latent variables compressing a proof distribution. The theorem-basis collapse result is an MDL phenomenon: adding a good model class dramatically shortens description length.

### 4. Combinatorics and algebra
The powerset expansion theorem is a combinatorial identity, but the proof-compression theorem interprets its term explosion as a lower bound on tactic-level derivation complexity.

### 5. Automated reasoning / AI theorem proving
The formal result should imply a scientific design principle: theorem provers need phase-aware lemma synthesis, not just stronger local search.

---

## Application Keywords

Use and emphasize these:
**proof complexity, formal verification, theorem proving, Lean 4, Mathlib, phase transition, lemma discovery, proof compression, recurrence lower bounds, combinatorial explosion, circuit complexity, DAG sharing, symbolic algebra, inclusion-exclusion, telescoping identities, automated reasoning, semantic complexity, benchmark science, AI for mathematics**

---

## Nontrivial Theorem Requirements

Your file must contain at least 3 theorems proved with real proof structure. Suitable tactics and methods include:
- induction on `n` or `Finset`,
- `rcases` on recursive decompositions,
- `by_contra` for threshold impossibility or non-collapse statements,
- `field_simp` in any rational/compression-ratio lemmas,
- multi-step `calc`,
- monotonicity arguments on exponentials and linear functions.

Do not satisfy the assignment with definitions plus easy simplifications. At least 3 proofs must have genuine internal architecture.

---

## Suggested Theorem Set

A coherent minimum viable breakthrough package:

1. `prod_one_add_eq_sum_powerset`  
   Deep combinatorial/algebraic theorem by induction on finite sets.

2. `gap_of_linear_vs_exponential`  
   Abstract theorem connecting cost recurrences to unbounded compression ratio.

3. `subsetExpansion_unbounded_gap`  
   Concrete instantiation showing a real theorem family exhibits proof-compression blowup.

4. `lemma_basis_reduces_subsetExpansion`  
   Theorem showing added basis lemmas collapse the cost growth.

5. Optional but excellent: `geom_sum_factorization` plus a second compression instance for telescoping identities.

That gives both abstract theory and at least two mathematical domains.

---

## Computational / Algorithmic Deliverable

You must produce a verified algorithm, not just theorem statements.

Implement a benchmarkable procedure that computes semantic complexity and predicted proof regime:

```lean
def complexityScore : TheoremBenchmark → ℕ := ...
def predictedPhase : TheoremBenchmark → Phase := ...
```

and prove at least one correctness or monotonicity theorem such as:

```lean
theorem predictedPhase_monotone
  (h : complexityScore a ≤ complexityScore b) :
  phaseIndex (predictedPhase a) ≤ phaseIndex (predictedPhase b) := ...
```

Or define an algorithm that, given `n`, constructs the subset-expansion benchmark instance and returns the certified lower/upper cost bounds.

This algorithm must be mirrored in `demo.py` to visualize the threshold.

---

## Conjecture With Testable Prediction

State at least one falsifiable conjecture in formal/mathematical terms. Here is the strongest candidate:

### Conjecture: Universality of proof-compression thresholds
For benchmark families arising from recursive decomposition with branching factor `b > 1`, the empirical compression ratio under a fixed tactic vocabulary converges to a domain-independent scaling law after normalization by semantic complexity width.

A more formal testable version:

- For each family `T_n` in algebra, combinatorics, and analysis, define measured ratio
  \[
  \rho_n = \frac{L_{\mathrm{auto}}(T_n)}{\max(1, L_{\mathrm{human}}(T_n))}.
  \]
- Normalize complexity by a computable width invariant `φ(T_n)`.
- Prediction: there exists a fitted critical window `[c₁, c₂]` where `ρ_n` sharply changes from bounded to rapidly increasing, and the width of this window remains stable across domains up to affine rescaling of `φ`.

**Refutation criterion:** if across benchmark families no statistically robust breakpoint appears, or if fixed-vocabulary automation remains within constant factor of structured proofs uniformly without lemma invention.

Also state a second, more concrete conjecture if possible:

### Conjecture: Powerset universality
Any theorem family whose normal form has support cardinality `2^n` but whose conceptual proof is generated by an `O(n)` recursive schema exhibits an unbounded automation-vs-structured proof gap under no-sharing proof models.

This is mathematically crisp and computationally testable.

---

## Building on Catalog / Mathlib Ingredients

Exploit vetted Mathlib facts, especially:
- `Finset.card_powerset`
- `Finset.induction_on`
- product/sum lemmas over `Finset`
- ring/algebra normalization lemmas for geometric sums
- monotonicity lemmas for powers and linear bounds on naturals

Use these not as endpoints but as load-bearing beams:
- `Finset.card_powerset` gives the exact combinatorial branching count needed for your lower bound.
- `Finset.induction_on` is the structural engine for the product expansion theorem.
- finite product/sum reindexing lemmas let you expose how lemma-sharing collapses repeated expansions.
- standard `Nat.pow` growth lemmas can bridge exact combinatorial growth to asymptotic gap statements.

If the dynamic context includes prior catalog work on tropical robustness, compression, symbolic complexity, or theorem benchmark infrastructure, explicitly repurpose those definitions as semantic-feature machinery rather than duplicating them.

---

## Deliverables You Must Produce

You must produce **all** of the following:

1. **Lean file(s)** with:
   - at least one novel definition,
   - at least 3 nontrivial theorems,
   - minimized `sorry`,
   - one cross-domain theorem or instantiated comparison across two domains.

2. **FUTURE_DIRECTIONS.md** with **3–5 testable scientific hypotheses**, each:
   - falsifiable,
   - paired with a concrete computational or formal test,
   - clearly stating what outcome would refute it.

3. **RESEARCH_PAPER.md** as a standalone scientific document:
   - problem statement,
   - formal definitions,
   - main theorems,
   - proof ideas,
   - benchmark methodology,
   - why the result matters,
   - what to investigate next.

4. **ARTICLE.md** in Scientific American style:
   - explain the proof-compression phase transition idea to a broad audience,
   - include why lemma invention is analogous to discovering hidden coordinates of thought.

5. **A verified algorithm or computational method**:
   - complexity scoring,
   - threshold prediction,
   - or certified cost-bound construction.

6. **demo.py**:
   - generate benchmark families,
   - compute/plot semantic complexity versus proof-cost proxies,
   - visualize the threshold and effect of lemma augmentation interactively.

---

## Final Standard

The goal is to make a research mathematician say:

> “They turned proof engineering into a theorem: there are natural families where shared structure is the whole game, and they formalized the phase transition.”

Do not give a toy model with vacuous costs. Build a mathematically meaningful proxy theory, prove a real threshold theorem, instantiate it on a natural theorem family, and show that lemma invention changes asymptotic proof complexity. That is the breakthrough.

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

Research domain: Speculative
Research mode: prove
