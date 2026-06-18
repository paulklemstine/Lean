Soli Deo Gloria

## Assignment: Direction 1: Global Tightness Conjecture — Exact Higher-Order State Complexity

**Mode**: `prove`

You are not being asked to polish an existing upper bound. You are being asked to turn a one-sided estimate into the **first exact state-complexity theorem for simply typed λ-calculus**. If successful, this would upgrade `typeStateBound` from a convenient combinatorial invariant into the **canonical minimal state count** of higher-order behavior, i.e. a genuine higher-order Myhill–Nerode theorem.

The catalog already gives the upper-bound half:
- `Catalog/Pythagorean/TypeComplexityBounds.lean`
  - `typeStateBound_eq_complexity`
  - `quotientSize_le_typeStateBound_forall_depth`

Your mission is to prove the missing lower-bound machinery by constructing **behaviorally saturating witness terms**. The decisive breakthrough is not “there exists some large term,” but rather:

> every simple type admits a closed inhabitant whose bounded observational quotient attains the catalog bound at some finite depth.

That is the conceptual pivot from **complexity bounded by type** to **complexity exactly characterized by type**.

---

## Precise Target Theorem

### Mathematical statement

Let `A` be a simple type. Assume `A` is inhabited by some closed well-typed term. Then there exists a closed term `t : A` and a depth `d : ℕ` such that the canonical quotient of depth-`d` reachable states of `t` has size exactly `typeStateBound A`.

Formally, the central theorem should have the shape:

```lean
theorem exists_term_attaining_typeStateBound
  (A : SimpleType) :
  InhabitedClosed A →
  ∃ (t : ClosedTerm A) (d : ℕ),
    canonicalQuotientSize d t = typeStateBound A
```

If the existing development encodes closed terms differently, adapt the binder names but preserve the quantifier structure.

A stronger, more revolutionary formulation is preferable if you can support it:

```lean
theorem exists_term_attaining_typeStateBound_at_all_large_depths
  (A : SimpleType) :
  InhabitedClosed A →
  ∃ (t : ClosedTerm A) (d0 : ℕ),
    ∀ d ≥ d0, canonicalQuotientSize d t = typeStateBound A
```

This would show not just one accidental saturation depth, but **eventual stabilization at the maximal quotient size**.

---

## Lean 4 Formalization Targets

You should aim to introduce at least one genuinely new concept that is not already in the catalog. The most promising one is a notion of finite-depth behavioral separation.

### New definition 1: depth-separating family

```lean
def PairwiseDepthSeparated {A : SimpleType} (d : ℕ) (S : Finset (ClosedTerm A)) : Prop :=
  ∀ ⦃t₁⦄, t₁ ∈ S →
  ∀ ⦃t₂⦄, t₂ ∈ S →
  t₁ ≠ t₂ →
  ¬ BoundedBehaviorallyEquivalent d t₁ t₂
```

This packages the lower-bound argument into a reusable combinatorial object.

### New definition 2: saturating witness

```lean
def SaturatesTypeBound (A : SimpleType) (t : ClosedTerm A) : Prop :=
  ∃ d : ℕ, canonicalQuotientSize d t = typeStateBound A
```

### New definition 3: eventual saturation (preferred if feasible)

```lean
def EventuallySaturatesTypeBound (A : SimpleType) (t : ClosedTerm A) : Prop :=
  ∃ d0 : ℕ, ∀ d ≥ d0, canonicalQuotientSize d t = typeStateBound A
```

These are not cosmetic. They let you state the theory as a hierarchy:
1. construct large pairwise-separated reachable families,
2. deduce quotient lower bounds,
3. squeeze with the catalog upper bound,
4. conclude exactness.

---

## Core Theorems to Prove

You must include **at least 3 nontrivial theorems** with real proof structure. The following package is the right target.

### Theorem 1: Separation gives quotient lower bounds

This is the foundational combinatorial engine.

```lean
theorem canonicalQuotientSize_ge_of_pairwise_separated
  {A : SimpleType} {d : ℕ} {t : ClosedTerm A} {S : Finset (ClosedTerm A)} :
  ReachableAtDepth d t S →
  PairwiseDepthSeparated d S →
  S.card ≤ canonicalQuotientSize d t
```

**Why this matters**: it converts witness construction into a cardinality lower bound. This is the higher-order analogue of building many distinguishable residual languages in Myhill–Nerode.

Likely proof ingredients:
- `rcases` a quotient representative argument,
- by contradiction assume too few quotient classes,
- use pigeonhole/collision in the quotient,
- derive behavioral equivalence of two distinct separated states.

This theorem should not collapse to finite enumeration. It should require actual quotient/class reasoning.

---

### Theorem 2: Recursive witness construction on types

You need a structural theorem saying that witness terms can be assembled recursively along the shape of simple types.

A plausible formal target:

```lean
theorem exists_pairwise_separated_reachable_family_of_card_typeStateBound
  (A : SimpleType) :
  InhabitedClosed A →
  ∃ (t : ClosedTerm A) (d : ℕ) (S : Finset (ClosedTerm A)),
    ReachableAtDepth d t S ∧
    PairwiseDepthSeparated d S ∧
    S.card = typeStateBound A
```

This is the real content. Once this is proved, the exactness theorem follows almost immediately from Theorem 1 and the catalog upper bound.

**Why this matters**: it says the type itself contains enough combinatorial room to realize all of its nominal complexity.

This is where you should use induction on `A` and explicit witness design:
- base types: produce a minimal but nontrivial separating family,
- product/sum-like encodings if available: combine independent branches,
- arrow types: create terms whose β-reduction and argument-sensitive behavior realize distinct residual states.

If the type language only has arrows and atoms, the induction should exploit Church-style encodings and continuation-sensitive distinguishers.

---

### Theorem 3: Global tightness

```lean
theorem global_tightness_conjecture
  (A : SimpleType) :
  InhabitedClosed A →
  ∃ (t : ClosedTerm A) (d : ℕ),
    canonicalQuotientSize d t = typeStateBound A
```

**Proof skeleton**:
1. obtain a separated family `S` of cardinality `typeStateBound A`,
2. use Theorem 1 to derive `typeStateBound A ≤ canonicalQuotientSize d t`,
3. apply `quotientSize_le_typeStateBound_forall_depth`,
4. conclude equality by `le_antisymm`.

This should be a proper multi-step `calc` proof, not a one-liner.

---

## Stronger Theorems Worth Attempting

If the infrastructure permits, one of these would be a field-opening upgrade.

### Strong form A: eventual stabilization
```lean
theorem eventual_global_tightness
  (A : SimpleType) :
  InhabitedClosed A →
  ∃ (t : ClosedTerm A) (d0 : ℕ),
    ∀ d ≥ d0, canonicalQuotientSize d t = typeStateBound A
```

This would mean the exact complexity is not depth-fragile.

### Strong form B: compositional multiplicativity/additivity
If `typeStateBound` is recursively defined on constructors, prove matching lower-bound composition laws for witnesses. For example, if some type constructor behaves multiplicatively:
```lean
theorem saturatingWitness_arrow_composition
  (A B : SimpleType) :
  Saturable A → Saturable B → Saturable (A ⟶ B)
```
with `Saturable A := ∃ t, SaturatesTypeBound A t`.

This creates an **inductive synthesis calculus of maximal-complexity terms**.

### Strong form C: canonical minimality
If there is a notion of higher-order automaton/state machine already present or definable:
```lean
theorem typeStateBound_is_minimal_realization_size
  (A : SimpleType) :
  InhabitedClosed A →
  MinimalRealizationSize A = typeStateBound A
```
This would be the true Myhill–Nerode analogue.

---

## Proof Strategy Architecture

You must present and pursue **2–3 proof routes**, not a single hint. Here are the main options.

### Strategy A: Structural witness induction on types
**Most promising.**

1. **Define a depth-separation predicate** for closed terms at type `A`.
2. **Induct on the structure of `A`**, constructing:
   - a witness term `t : A`,
   - a depth `d`,
   - a finite family `S` of reachable states,
   - pairwise separation of `S`,
   - exact cardinality `S.card = typeStateBound A`.
3. **Use the catalog upper bound** `quotientSize_le_typeStateBound_forall_depth` to squeeze.

Why this is best:
- It aligns directly with `typeStateBound_eq_complexity`.
- It explains *why* the bound is exact: the type grammar itself generates the maximal distinguishable state family.
- It is most likely to scale to future “eventual saturation” theorems.

Key technical challenge:
- For arrow types, you must build terms whose residual behavior is distinguishable by suitably chosen test arguments/contexts. This is the higher-order heart of the problem.

---

### Strategy B: Quotient-class realization via bounded contexts
1. Define bounded contextual distinguishability explicitly.
2. Show `typeStateBound A` can be reinterpreted as the maximal number of pairwise context-distinguishable residuals generated by a term of type `A`.
3. Construct a term whose reachable residuals realize all such distinguishers.

Why it is powerful:
- This is closest in spirit to classical Myhill–Nerode.
- It could yield a sharper theorem: `typeStateBound` is not merely attained, but attained **as the number of contextual equivalence classes**.

Why it is harder:
- Requires more infrastructure about contexts and plugging.
- If context machinery is not already in the catalog, Lean overhead may be substantial.

---

### Strategy C: Extremal combinatorics of β-reduction trees
1. Define a reduction tree profile at bounded depth.
2. Prove that quotient size is bounded below by the number of inequivalent leaves/subtrees in a well-chosen normalizing witness.
3. Construct extremal witnesses recursively to realize the combinatorial optimum.

Why this is interesting:
- It links the theorem to analytic combinatorics and branching processes.
- It may produce computational algorithms for witness synthesis.

Why it is secondary:
- Quotient size depends on equivalence, not raw branching alone; separation arguments must still be supplied.
- Better as a supporting viewpoint or algorithmic corollary than the primary proof.

**Recommendation**: pursue **Strategy A** as the main line, borrow contextual ideas from **Strategy B** for arrow-type separation, and use **Strategy C** to guide explicit witness construction and `demo.py`.

---

## Cross-Domain Connections You Must Exploit

This project is strongest when framed as a unification theorem.

### 1. Automata theory
`canonicalQuotientSize` is the higher-order analogue of the number of Myhill–Nerode equivalence classes. Proving exact attainment means:

- types determine **exact minimal state complexity**,
- closed λ-terms play the role of languages/automata,
- bounded behavioral equivalence plays the role of residual indistinguishability.

This opens a new field: **higher-order state complexity theory**.

### 2. Descriptive complexity / implicit computational complexity
If type shape exactly controls realizable quotient complexity, then simple types become **resource descriptors**. This suggests:
- logical/type-theoretic measures correspond to finite-state complexity profiles,
- higher-order programs can be classified by exact behavioral state counts,
- complexity classes may admit type-theoretic characterizations via quotient growth.

### 3. Combinatorics of λ-terms
Your witness construction is an extremal combinatorics theorem:
- among all terms of a given type, some realize the maximum possible number of distinguishable residual states,
- this is an extremal counting/saturation phenomenon,
- recursive witness synthesis may reveal a closed-form combinatorial grammar of maximizers.

### 4. Semantics and categorical logic
If exactness holds, `typeStateBound` is not just a syntactic invariant but a semantic one:
- types classify maximal finite observable behavior,
- quotient classes resemble finite coalgebraic observations,
- this invites a categorical reinterpretation of simple types as generators of finite behavioral complexity.

### 5. Statistical physics / phase-transition language
There may be a “saturation threshold” in depth:
- below threshold, quotient size grows;
- at threshold, it plateaus at `typeStateBound A`.

This invites language from finite-size scaling, phase transitions, and order parameters:
- depth as inverse temperature / time,
- quotient size as entropy/state count,
- saturation depth as critical scale.

You do not need to formalize the physics, but the paper should articulate the analogy.

---

## Application Keywords

Use these explicitly in the scientific writing and metadata:

**higher-order state complexity, Myhill–Nerode for λ-calculus, exact quotient complexity, bounded behavioral equivalence, simple types, β-reduction automata, extremal λ-term combinatorics, contextual distinguishability, descriptive complexity, coalgebraic semantics, finite-state abstraction, witness synthesis, saturation depth, semantic complexity invariants**

---

## Concrete Lean-Oriented Work Plan

### Phase 1: Mine and align with catalog lemmas
Read `Catalog/Pythagorean/TypeComplexityBounds.lean` carefully and identify:
- the exact type of `typeStateBound_eq_complexity`,
- the exact statement of `quotientSize_le_typeStateBound_forall_depth`,
- existing notions of closed term, reduction, reachable state, quotient, and behavioral equivalence.

Do not re-invent any definition already present. Build wrappers only where necessary.

### Phase 2: Introduce lower-bound infrastructure
Formalize:
- `PairwiseDepthSeparated`,
- `SaturatesTypeBound`,
- optionally `EventuallySaturatesTypeBound`.

Then prove the lower-bound theorem from separated reachable families:
```lean
canonicalQuotientSize_ge_of_pairwise_separated
```

This theorem should use:
- `rcases`,
- contradiction or quotient-collision reasoning,
- explicit cardinality comparison,
- nontrivial `calc` chains.

### Phase 3: Recursive witness synthesis
Define or construct recursively a family of witness terms:
- atomic/base type witness,
- constructor-level composition for arrows,
- auxiliary distinguishers/contexts if required.

You should expect the deepest theorem here to require:
- induction on `A`,
- case splits on the type structure,
- careful management of reachability and separation,
- possibly `by_contra` to prove pairwise inequivalence.

### Phase 4: Squeeze to equality
Use:
- lower bound from separation,
- upper bound from `quotientSize_le_typeStateBound_forall_depth`,
- `le_antisymm`.

This is the culmination theorem and should be written cleanly enough to serve as the centerpiece of `RESEARCH_PAPER.md`.

---

## Suggested Theorem Skeletons

These are schematic and should be adapted to the actual catalog names.

```lean
def PairwiseDepthSeparated {A : SimpleType} (d : ℕ) (S : Finset (ClosedTerm A)) : Prop :=
  ∀ ⦃t₁⦄, t₁ ∈ S →
  ∀ ⦃t₂⦄, t₂ ∈ S →
  t₁ ≠ t₂ →
  ¬ BoundedBehaviorallyEquivalent d t₁ t₂

def SaturatesTypeBound (A : SimpleType) (t : ClosedTerm A) : Prop :=
  ∃ d : ℕ, canonicalQuotientSize d t = typeStateBound A

theorem canonicalQuotientSize_ge_of_pairwise_separated
  {A : SimpleType} {d : ℕ} {t : ClosedTerm A} {S : Finset (ClosedTerm A)} :
  ReachableAtDepth d t S →
  PairwiseDepthSeparated d S →
  S.card ≤ canonicalQuotientSize d t := by
  -- nontrivial quotient-class counting argument

theorem exists_pairwise_separated_reachable_family_of_card_typeStateBound
  (A : SimpleType) :
  InhabitedClosed A →
  ∃ (t : ClosedTerm A) (d : ℕ) (S : Finset (ClosedTerm A)),
    ReachableAtDepth d t S ∧
    PairwiseDepthSeparated d S ∧
    S.card = typeStateBound A := by
  -- induction on A, recursive witness synthesis

theorem global_tightness_conjecture
  (A : SimpleType) :
  InhabitedClosed A →
  ∃ (t : ClosedTerm A) (d : ℕ),
    canonicalQuotientSize d t = typeStateBound A := by
  intro hA
  rcases exists_pairwise_separated_reachable_family_of_card_typeStateBound A hA with
    ⟨t, d, S, hReach, hSep, hCard⟩
  refine ⟨t, d, ?_⟩
  have hLower : typeStateBound A ≤ canonicalQuotientSize d t := by
    calc
      typeStateBound A = S.card := by simpa [hCard]
      _ ≤ canonicalQuotientSize d t :=
        canonicalQuotientSize_ge_of_pairwise_separated hReach hSep
  have hUpper : canonicalQuotientSize d t ≤ typeStateBound A :=
    quotientSize_le_typeStateBound_forall_depth A d t
  exact le_antisymm hUpper hLower
```

If there is an extant complexity theorem:
```lean
typeStateBound_eq_complexity
```
then prove a corollary equating actual realized complexity with the type complexity invariant.

---

## Computational/Algorithmic Deliverable

You must produce not only theorems but a **verified algorithmic witness search/synthesis method**.

### Required algorithm
Implement a procedure that, for small inhabited types `A`, attempts to synthesize a closed term `t` and depth `d` such that:
```text
canonicalQuotientSize(d, t) = typeStateBound(A)
```

There are two acceptable versions:

1. **Constructive synthesis algorithm**
   - recursively build the witness predicted by the proof;
   - output `(t, d)` and certify the quotient size.

2. **Enumerative falsification/confirmation algorithm**
   - enumerate closed β-reducible terms up to a size bound,
   - compute `canonicalQuotientSize d t` for increasing `d`,
   - track the maximum observed quotient size for each type.

The constructive version is scientifically stronger.

### `demo.py`
The demo must:
- let the user choose a small type,
- synthesize or enumerate witness terms,
- display quotient size as a function of depth,
- compare observed sizes to `typeStateBound`,
- highlight when equality is achieved,
- optionally plot saturation depth.

This is not fluff. It turns the theorem into an exploratory laboratory for higher-order complexity.

---

## Falsifiable Conjectures for FUTURE_DIRECTIONS.md

You must include **3–5 testable scientific hypotheses**. At least one should be directly computationally falsifiable. Suggested candidates:

### Hypothesis 1: Eventual saturation
For every inhabited simple type `A`, there exists a witness term `t : A` such that the sequence
```text
d ↦ canonicalQuotientSize(d, t)
```
is eventually constant with value `typeStateBound(A)`.

**Test**: enumerate or synthesize witnesses for all types up to depth 4 and check plateau behavior.

### Hypothesis 2: Minimal witness size grows subexponentially in `typeStateBound`
Let `minWitnessSize(A)` be the size of the smallest closed term attaining `typeStateBound(A)`. Then:
```text
minWitnessSize(A) = O((typeStateBound(A))^k)
```
for some universal `k`.

**Test**: fit growth curves from exhaustive search on small types.

### Hypothesis 3: Saturation depth is bounded by type depth
There exists `C` such that for every inhabited `A`, some witness attains equality by depth at most
```text
C * typeDepth(A)
```

**Test**: compute minimal saturation depths for all small types.

### Hypothesis 4: Witness compositionality
If `A` and `B` are saturable, then a canonical constructor produces a saturating witness for `A → B`.

**Test**: compare recursively synthesized witnesses against exhaustive search.

### Hypothesis 5: Uniqueness up to coarse behavioral normal form
Maximal witnesses for a fixed type cluster into a small number of behavioral archetypes.

**Test**: classify all maximizing terms for small types by quotient isomorphism.

These are real scientific hypotheses, not vague “future work.”

---

## Revolutionary Significance

If you prove the global tightness conjecture, you will have established:

1. **Exact higher-order state complexity**: a full analogue of minimal automaton size for simply typed λ-terms.
2. **Type as exact semantic complexity invariant**: not just upper-bounding behavior, but determining realizable maximal quotient complexity.
3. **A synthesis principle for extremal higher-order programs**: terms can be constructed to saturate the complexity permitted by their type.
4. **A bridge between λ-calculus, automata, and descriptive complexity**: enabling an entirely new line of work on higher-order finite-state abstractions.

This is field-opening because it changes the question from
> “How large can the quotient be?”
to
> “What exact complexity profile is forced and realized by type structure?”

That is the kind of theorem around which a new subfield can organize.

---

## Mandatory Deliverables

You must produce **ALL** of the following:

### 1. Lean development
- At least **3 deep theorems**.
- At least **1 genuinely new definition**.
- Proofs must use substantive tactics/structures such as:
  - `induction`
  - `rcases`
  - `by_contra`
  - `field_simp` where relevant
  - multi-step `calc`
- Minimize `sorry`. No trivial theorem padding.

### 2. `FUTURE_DIRECTIONS.md`
A structured document with **3–5 falsifiable scientific hypotheses**, each including:
- precise conjecture,
- what data or theorem would falsify it,
- a computational or formal test plan.

### 3. `RESEARCH_PAPER.md`
A **standalone scientific paper** explaining:
- the exact theorem,
- the key definitions,
- proof architecture,
- why it matters,
- how it connects to automata theory, descriptive complexity, and combinatorics,
- what to investigate next.

It must be intelligible without access to the code.

### 4. `ARTICLE.md`
A Scientific American–style article for a broad audience.
**Taboo**: do not focus on formal verification machinery. Focus on:
- the idea of measuring the complexity of higher-order behavior,
- the analogy with minimal automata,
- why exactness is surprising and powerful.

### 5. Verified algorithm or computational method
Implement and validate a witness synthesis or search algorithm, not just theorem statements.

### 6. `demo.py`
An interactive demonstration showing:
- small-type selection,
- witness synthesis/search,
- quotient-size computation versus depth,
- comparison to `typeStateBound`,
- empirical tests of the conjectures.

---

## Final Charge

Do not settle for “there exists some term with large quotient.” That is not the breakthrough. The breakthrough is:

> **For every inhabited simple type, maximal bounded behavioral complexity is not merely bounded by the type — it is exactly attained by a closed term of that type.**

Prove this, and you will have created the conceptual foundation of **higher-order state complexity theory**.

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
