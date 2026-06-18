## Assignment: Direction 1: Multi-Step Filtration Obstructions (Extension)

**Mode: prove**

Prove genuinely new, non-trivial theorems about **secondary and higher obstruction calculus for finite filtrations of finitely generated abelian groups**, with explicit Lean 4 formalization targets and a computational verification layer. Build directly on:

- `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean`
  - especially `torsion_persistence_functorial`
- `Catalog/Algebra/Homology/DerivedFunctors/ExtTorBasic.lean`
  - especially `Ext1_ZMod_ZMod_equiv`

The goal is not to repackage known exact-sequence facts. The goal is to create a **formal obstruction algebra** for filtrations: a framework where pairwise extension data fails to compose strictly, and the failure is itself measured by higher interaction terms. This is the algebraic seed of spectral-sequence-style convergence, derived persistence, and higher defect propagation.

---

## Core Vision

A two-step extension is controlled by an `Ext^1` class. A three-step filtration should not merely carry two unrelated `Ext^1` classes: it should carry a **composite obstruction profile** whose deviation from naive additivity is measurable. That deviation is the first shadow of higher coherence in filtered homological algebra.

If you can formalize even the three-step case in Lean with explicit cyclic examples, you will have opened a path toward:

- obstruction-theoretic models of persistence beyond barcode invariants,
- computable defect invariants for hierarchical data and materials,
- algebraic analogues of anomaly composition in physics,
- and eventually a machine-checkable algebra of higher filtration interactions.

This is the missing bridge between **extension theory**, **derived persistence**, and **higher compositional invariants**.

---

## Precise Mathematical Program

Work in the category of abelian groups, specializing to finitely generated abelian groups when needed for explicit computation.

Consider a three-step filtration
\[
0 \subseteq A \subseteq B \subseteq C.
\]
Let
\[
Q_1 := B/A,\qquad Q_2 := C/B,\qquad Q := C/A.
\]
There are short exact sequences
\[
0 \to A \to B \to Q_1 \to 0,\qquad
0 \to B \to C \to Q_2 \to 0,\qquad
0 \to A \to C \to Q \to 0.
\]
Each determines extension classes in `Ext^1`. The central problem is to define a **secondary composition invariant**
\[
\delta(A,B,C)
\]
from the pair of extension classes and compare it with the total extension class of `0 → A → C → Q → 0`.

You should introduce at least one new definition that is not already in the catalog, such as a structure encoding a three-step filtration together with its obstruction data.

---

## New Definitions to Introduce

Define a new structure representing a three-step filtration:

```lean
structure ThreeStepFiltration where
  A B C : AddCommGroupCat
  iAB : A ⟶ B
  iBC : B ⟶ C
  mono_iAB : Mono iAB
  mono_iBC : Mono iBC
```

If the ambient library setup makes `AddCommGroupCat` cumbersome, use a concrete substitute on abelian groups/types with additive structure, but keep the mathematical intent exact.

Then define a new obstruction concept, for example:

```lean
structure FiltrationObstructionProfile where
  e₁ : Type _
  e₂ : Type _
  total : Type _
  correction : Type _
```

This should eventually be refined so the fields are actual `Ext`-valued data or explicit cyclic invariants in the computable regime.

A more concrete and likely more Lean-feasible definition for the first cycle is an invariant for cyclic filtrations:

```lean
def cyclicStepObstruction (p a b : ℕ) : ℕ := ...
def cyclicTripleCorrection (p a b c : ℕ) : ℕ := ...
```

where these measure the mismatch between the total obstruction for
\[
\mathbb Z/p^a \subseteq \mathbb Z/p^b \subseteq \mathbb Z/p^c
\]
and the naive composition of adjacent obstructions.

The key is that the definition must be mathematically meaningful, not merely ad hoc bookkeeping.

---

## Primary Theorem Targets

You must prove at least 3 substantial theorems. The following are the recommended targets.

### Theorem 1: Functoriality of the three-step obstruction

**Mathematical statement.**  
For any morphism of three-step filtrations
\[
(A \subseteq B \subseteq C) \to (A' \subseteq B' \subseteq C'),
\]
the induced pair of adjacent extension classes and the total extension class are compatible under the induced maps on `Ext^1`; hence the secondary obstruction profile is functorial.

This extends `torsion_persistence_functorial` from pairwise torsion detection to compositional filtration data.

**Lean 4 type signature sketch**
```lean
theorem three_step_obstruction_functorial
  (F F' : ThreeStepFiltration)
  (fA : F.A ⟶ F'.A) (fB : F.B ⟶ F'.B) (fC : F.C ⟶ F'.C)
  (hAB : F.iAB ≫ fB = fA ≫ F'.iAB)
  (hBC : F.iBC ≫ fC = fB ≫ F'.iBC) :
  map_filtration_obstruction F F' fA fB fC hAB hBC
    = induced_obstruction_map F F' fA fB fC := by
  ...
```

If the fully abstract categorical statement is too heavy for the current Mathlib interfaces, prove a concrete version for cyclic or finitely generated abelian groups presented by explicit quotient maps.

**Why this matters.**  
Without functoriality there is no invariant theory. With functoriality, obstruction profiles become transportable along maps of filtered objects, making them candidates for derived persistence invariants.

---

### Theorem 2: Three-step composition law with correction term

**Mathematical statement.**  
For a three-step filtration \(0 \subseteq A \subseteq B \subseteq C\), there exists a correction term
\[
\kappa(A,B,C)
\]
such that the total obstruction of \(A \subseteq C\) is determined by the adjacent obstructions together with \(\kappa(A,B,C)\). In a computable cyclic regime, prove an explicit formula.

A concrete form to aim for:
\[
\delta_{A,C} = \Phi(\delta_{A,B},\delta_{B,C}) + \kappa(A,B,C),
\]
where \(\Phi\) is the naive composition law induced by connecting maps.

**Lean 4 type signature sketch**
```lean
theorem three_step_composition_law
  (F : ThreeStepFiltration) :
  totalObstruction F
    = composeAdjacentObstructions F + tripleCorrection F := by
  ...
```

In a concrete cyclic specialization:
```lean
theorem cyclic_three_step_composition_law
  (p a b c : ℕ) (hp : Nat.Prime p) (hab : a ≤ b) (hbc : b ≤ c) :
  cyclicTotalObstruction p a c
    = cyclicComposeAdjacent p a b c + cyclicTripleCorrection p a b c := by
  ...
```

**Why this is a breakthrough.**  
This is the first genuine higher-coherence law. It says filtered extension data is not just local-at-each-step; there is a nontrivial global defect. That is exactly the algebraic phenomenon spectral sequences encode abstractly. Here you are making it explicit and computable.

---

### Theorem 3: Vanishing of correction in split or low-complexity cases

**Mathematical statement.**  
If one adjacent short exact sequence splits, or if the filtration is extension-trivial in a suitable sense, then the triple correction term vanishes, and the total obstruction reduces to the naive composite of pairwise obstructions.

Typical statement:
\[
\text{if } 0\to A\to B\to Q_1\to 0 \text{ splits, then } \kappa(A,B,C)=0.
\]

**Lean 4 type signature sketch**
```lean
theorem triple_correction_eq_zero_of_split_left
  (F : ThreeStepFiltration)
  (hsplit : SplitMono F.iAB) :
  tripleCorrection F = 0 := by
  ...
```

And similarly for the right step:
```lean
theorem triple_correction_eq_zero_of_split_right
  (F : ThreeStepFiltration)
  (hsplit : SplitMono F.iBC) :
  tripleCorrection F = 0 := by
  ...
```

**Why this matters.**  
A correction term is only scientifically useful if we know when it disappears. These vanishing criteria identify the boundary between ordinary extension theory and genuinely higher obstruction phenomena.

---

### Theorem 4: Explicit cyclic computation

You should prove at least one explicit family theorem for
\[
\mathbb Z/p^a\mathbb Z \subseteq \mathbb Z/p^b\mathbb Z \subseteq \mathbb Z/p^c\mathbb Z.
\]

Use `Ext1_ZMod_ZMod_equiv` as the computational bridge.

**Candidate statement.**
For prime `p` and exponents `a ≤ b ≤ c`, the adjacent and total obstruction classes correspond under the `Ext^1`-cyclic classification to divisibility exponents, and the correction term is determined by a valuation-theoretic formula depending on `(a,b,c)`.

Even if the ultimate formula is modest, the theorem is deep if the proof reconstructs extension classes and compares them through exact-sequence machinery rather than direct enumeration.

**Lean 4 type signature sketch**
```lean
theorem Ext_cyclic_filtration_formula
  (p a b c : ℕ) (hp : Nat.Prime p) (hab : a ≤ b) (hbc : b ≤ c) :
  obstructionExponent p a b c
    = explicitFormula p a b c := by
  ...
```

---

## Proof Strategy Architecture

You must give Aristotle multiple paths. Do not commit to only one.

### Strategy A: Ext-theoretic composition via connecting morphisms
1. Represent the two adjacent short exact sequences by classes in `Ext^1(Q₁,A)` and `Ext^1(Q₂,B)`.
2. Use the long exact sequence in `Ext` induced by `0 → A → B → Q₁ → 0` to transport the class of the second extension into an obstruction relative to `A`.
3. Compare the resulting class with the total extension `0 → A → C → Q → 0`; define the discrepancy as the triple correction.

**Why promising:**  
This is conceptually closest to the conjecture and uses the catalog’s `Ext1_ZMod_ZMod_equiv` naturally. It also aligns with the slogan that higher filtration data lives in derived functorial composition.

### Strategy B: Yoneda-extension calculus in the abelian category of abelian groups
1. Encode each short exact sequence as a Yoneda `Ext^1` class.
2. Interpret the filtration as a composable extension diagram and analyze the splice.
3. Show that naive splicing does not always recover the total extension class without a correction term; identify the correction by comparing canonical representatives.

**Why promising:**  
This may avoid some overhead from long exact sequence infrastructure if Mathlib’s Yoneda-facing API is easier to exploit. It also gives a more direct conceptual story: the correction term is the failure of strict associativity in chosen extension representatives.

### Strategy C: Explicit classification for finitely generated abelian groups, then abstract lift
1. First prove theorems for cyclic `p`-primary groups using explicit presentations and the catalog equivalence for `Ext^1`.
2. Identify the correction term concretely in this setting.
3. Then formulate the abstract theorem as the conceptual envelope suggested by the cyclic computation.

**Why promising:**  
This is the most robust path if categorical APIs are incomplete. It guarantees nontrivial formal output and a verified computational method. It also produces data for the conjectural higher theory.

**Recommended order:** C → A → B.  
Get the cyclic engine working first; then abstract the pattern.

---

## Deep Proof Tactics Requirement

Your proofs must visibly use multi-step mathematics. Across the file, ensure at least 3 theorem proofs use some combination of:

- `induction`
- `rcases`
- `by_contra`
- `field_simp`
- substantial `calc` chains
- diagram-chasing style decomposition and reconstruction
- exactness arguments and quotient manipulations

Do **not** allow the project to collapse into finite-case evaluation. Even the cyclic examples should be proved by structural algebraic reasoning.

---

## Cross-Domain Connections You Must Include

Include at least one theorem or discussion bridge connecting this work to another domain.

### Option 1: Persistent homology / topological data analysis
Interpret the correction term as a **derived persistence defect**: pairwise persistence transitions do not fully determine multi-scale behavior. This opens a path to invariants beyond barcodes.

### Option 2: Physics / anomaly composition
Treat the triple correction as an algebraic analogue of an **anomaly term**: local compositional laws hold only up to a higher defect. This is mathematically analogous to associators and anomaly inflow.

### Option 3: Number theory / valuation theory
In the cyclic `p`-primary case, the correction term should depend on exponent jumps and thus behave like a **discrete valuation interaction invariant**. Make this explicit.

A concrete cross-domain theorem to target:

```lean
theorem cyclic_correction_depends_only_on_exponent_gaps
  (p a b c : ℕ) (hp : Nat.Prime p) (hab : a ≤ b) (hbc : b ≤ c) :
  cyclicTripleCorrection p a b c
    = gapInvariant (b - a) (c - b) := by
  ...
```

This connects homological obstruction theory to valuation-style arithmetic.

---

## Computational Test Program

You must formalize and test the family
\[
\mathbb Z/p\mathbb Z \subseteq \mathbb Z/p^2\mathbb Z \subseteq \mathbb Z/p^3\mathbb Z
\]
for primes `p ≤ 13`, and ideally more generally
\[
\mathbb Z/p^a\mathbb Z \subseteq \mathbb Z/p^b\mathbb Z \subseteq \mathbb Z/p^c\mathbb Z.
\]

The computational goal is not mere example generation. It is to test the falsifiable claim:

> **Conjecture.** For cyclic `p`-primary three-step filtrations, the triple correction term is determined solely by the exponent gaps `(b-a, c-b)` and is independent of `p`.

This is a real scientific conjecture because it can fail computationally.

### Required falsifiable prediction
State explicitly:

- If the conjecture is true, examples with the same exponent gaps but different primes produce identical correction values.
- If false, the `demo.py` must exhibit a counterexample.

---

## Lean 4 Formalization Targets

You should aim for theorem statements close to the following. Adjust universe/category details as needed to match Mathlib reality.

```lean
structure ThreeStepFiltration where
  A B C : AddCommGroupCat
  iAB : A ⟶ B
  iBC : B ⟶ C
  mono_iAB : Mono iAB
  mono_iBC : Mono iBC

def totalObstruction (F : ThreeStepFiltration) : ℤ := ...
def adjacentObstructionLeft (F : ThreeStepFiltration) : ℤ := ...
def adjacentObstructionRight (F : ThreeStepFiltration) : ℤ := ...
def composeAdjacentObstructions (F : ThreeStepFiltration) : ℤ := ...
def tripleCorrection (F : ThreeStepFiltration) : ℤ := ...

theorem three_step_composition_law
  (F : ThreeStepFiltration) :
  totalObstruction F
    = composeAdjacentObstructions F + tripleCorrection F := by
  ...

theorem triple_correction_eq_zero_of_split_left
  (F : ThreeStepFiltration)
  (hsplit : SplitMono F.iAB) :
  tripleCorrection F = 0 := by
  ...

theorem triple_correction_eq_zero_of_split_right
  (F : ThreeStepFiltration)
  (hsplit : SplitMono F.iBC) :
  tripleCorrection F = 0 := by
  ...

def cyclicTripleCorrection (p a b c : ℕ) : ℤ := ...

theorem cyclic_three_step_composition_law
  (p a b c : ℕ) (hp : Nat.Prime p) (hab : a ≤ b) (hbc : b ≤ c) :
  cyclicTotalObstruction p a c
    = cyclicComposeAdjacent p a b c + cyclicTripleCorrection p a b c := by
  ...

theorem cyclic_correction_depends_only_on_exponent_gaps
  (p q a b c : ℕ)
  (hp : Nat.Prime p) (hq : Nat.Prime q)
  (hab : a ≤ b) (hbc : b ≤ c) :
  cyclicTripleCorrection p a b c = cyclicTripleCorrection q a b c := by
  ...
```

If full categorical `Ext` is too heavy, it is acceptable to define these obstruction values first through the classification of cyclic extensions, provided you clearly indicate how this realizes the abstract Ext-theoretic vision.

---

## How to Build on the Catalog

### From `torsion_persistence_functorial`
Use it not as the destination but as the **functoriality engine**: pairwise torsion behavior already transports along maps. Your job is to show that **multi-step obstruction profiles** also transport, and that their correction term is stable under morphisms of filtrations.

### From `Ext1_ZMod_ZMod_equiv`
This is your computational Rosetta stone. It turns abstract extension classes between cyclic modules into explicit algebraic parameters. Use it to:
1. encode adjacent filtration steps,
2. compute their associated `Ext^1` classes,
3. compare with the total extension class,
4. and extract the correction term.

The breakthrough move is not “compute Ext again.”  
It is: **use the equivalence to define and verify higher compositional obstruction invariants**.

---

## Deliverables You Must Produce

You must produce **all** of the following:

1. **Lean file(s)** with at least 3 nontrivial theorems proved using deep tactics.
2. **A verified algorithm or computational method** computing adjacent obstructions, total obstruction, and correction terms for cyclic filtrations.
3. **`demo.py`** that interactively tests the conjectured composition law on families such as:
   - `Z/p ⊂ Z/p^2 ⊂ Z/p^3` for `p ≤ 13`
   - selected triples `(a,b,c)` with fixed gap pattern
4. **`FUTURE_DIRECTIONS.md`** with 3–5 falsifiable hypotheses. Each must include:
   - precise statement,
   - what data or theorem would refute it,
   - why it matters.
5. **`RESEARCH_PAPER.md`** as a standalone scientific document:
   - motivation,
   - definitions,
   - theorem statements,
   - proof ideas,
   - computational experiments,
   - implications.
6. **`ARTICLE.md`** in Scientific American style:
   - explain filtrations,
   - why pairwise information is not enough,
   - what a correction term means,
   - why formal proof matters.

---

## Required Scientific Hypotheses for `FUTURE_DIRECTIONS.md`

Include 3–5 hypotheses of this kind:

1. **Prime-independence hypothesis.**  
   For cyclic `p`-primary three-step filtrations, the triple correction depends only on exponent gaps, not on `p`.

2. **Split-detection hypothesis.**  
   The triple correction vanishes if and only if at least one adjacent extension class is split.

3. **Additivity failure localization hypothesis.**  
   For direct sums of filtrations, the correction term is additive on primary decompositions.

4. **Higher-step recursion hypothesis.**  
   For any bounded finite filtration, the total obstruction is determined recursively by adjacent obstructions plus finitely many higher interaction terms indexed by contiguous subfiltrations.

5. **Derived persistence detectability hypothesis.**  
   There exist filtered chain complexes with identical pairwise persistence data but different triple correction profiles.

Each is testable; none is vague.

---

## Application Keywords

Use these explicitly in the paper and article:

- derived persistence
- spectral sequence convergence
- extension theory
- Yoneda composition
- higher obstruction
- anomaly composition
- valuation-theoretic invariant
- filtered algebra
- topological data analysis
- formal verification
- computable homological algebra

---

## Final Standard

Do not settle for “there exists some obstruction.” Construct it. Compare it. Compute it. Prove when it vanishes. Exhibit when naive composition fails. Turn a filtration from a chain of inclusions into a **higher algebraic object with measurable defect data**.

This is the point where extension theory stops being local and starts becoming compositional science.

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
