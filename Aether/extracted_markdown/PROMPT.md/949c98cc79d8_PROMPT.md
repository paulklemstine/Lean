Soli Deo Gloria

## Assignment: Direction 2: Stability of Torsion Barcodes Under Filtration Perturbations

**Mode:** `prove`

Prove a genuinely new torsion-stability theorem that could become the torsion analogue of algebraic stability in persistent homology. Do not settle for a cosmetic extension of existing barcode stability. The conceptual target is this:

> Ordinary persistence is stable because interval decompositions linearize perturbations.  
> Torsion persistence has no such luxury over `ℤ`.  
> The breakthrough is to identify the **right replacement for interval decompositions** — a torsion support/birth landscape that is still functorial and metrically stable.

Your task is to formalize that replacement and prove its first nontrivial stability theorems in Lean 4, building explicitly on:

- `Algebra/Homology/DerivedFunctors/TorsionDetection.lean`
  - `exists_torsion_birth`
  - `torsion_persistence_functorial`
  - `torPersistenceModule`
  - any composition/functoriality lemmas such as `pTorPersistence_map_comp`

The goal is not to imitate classical barcode language where it fails, but to create the correct torsion-native invariant and prove it is stable under filtration perturbation.

---

## Core Mathematical Objective

Let `F, F'` be filtrations indexed by `ℕ` (or a finite initial segment), with maps of chain complexes inducing a `δ`-interleaving up to chain homotopy. Let torsion classes in homology have **birth indices** defined via the earliest filtration stage where the class appears as torsion.

You should define a torsion invariant robust enough to survive the absence of interval decomposition, then prove a stability bound of the form:

> If `F` and `F'` are `δ`-interleaved, then every torsion birth in `F` is matched to a torsion birth in `F'` within additive error `≤ δ`, and conversely.

This should be stated first for a **torsion support set** and then, if possible, for a derived bottleneck-style metric on finite torsion birth multisets.

---

## Precise Theorem Targets

You must include at least **3 substantial theorems**. At least one should be a main theorem, one should be a functorial transport theorem, and one should be a cross-domain theorem.

### New definitions you should introduce

You must define at least one new concept not already in the catalog. Suggested candidates:

1. `torsionBirthSet`:
   the set of filtration indices where a torsion class is born.

2. `torsionBirthRadius` or `torsionBirthProfile`:
   a function `ℕ → Prop` or `ℕ → ℕ` encoding where torsion first appears.

3. `deltaInterleavedFiltration`:
   a structure encoding shifted maps between filtrations together with chain-homotopy compatibility.

4. `torsionSupportDistance`:
   a Hausdorff-style distance on subsets of `ℕ` or finite multisets of birth indices.

A strong option is to define:

```lean
def torsionBirthSet
  (F : ℕ → ChainComplex Ab ℕ) (n : ℕ) : Set ℕ := ...
```

and

```lean
def torsionSupportDistance (A B : Set ℕ) : ℕ := ...
```

or a bounded-prop version expressing `A` and `B` are `δ`-close.

---

## Suggested Lean 4 theorem statements

These signatures are intentionally schematic; refine them to match actual catalog objects and universe parameters.

### Theorem 1: Functorial transport of torsion births under shifted maps
A first theorem should say that a morphism of filtrations shifted by `δ` sends torsion births to nearby torsion births.

```lean
theorem torsion_birth_transport
  {F F' : ℕ → ChainComplex Ab ℕ}
  {n δ i : ℕ}
  (hmap : ShiftedFiltrationMap F F' δ)
  (hi : i ∈ torsionBirthSet F n) :
  ∃ j, j ∈ torsionBirthSet F' n ∧ j ≤ i + δ
```

Breakthrough content: this replaces interval endpoint transport by a torsion-native birth transport theorem.

### Theorem 2: Stability of torsion support under interleavings
This is the main theorem. State it as Hausdorff stability of support sets.

```lean
theorem torsion_birthSet_stable
  {F F' : ℕ → ChainComplex Ab ℕ}
  {n δ : ℕ}
  (hint : DeltaInterleaving F F' δ) :
  Set.HausdorffDistNat (torsionBirthSet F n) (torsionBirthSet F' n) ≤ δ
```

If `Set.HausdorffDistNat` does not exist, define an explicit predicate:

```lean
def NatSetDeltaClose (A B : Set ℕ) (δ : ℕ) : Prop :=
  (∀ ⦃a⦄, a ∈ A → ∃ b ∈ B, Nat.dist a b ≤ δ) ∧
  (∀ ⦃b⦄, b ∈ B → ∃ a ∈ A, Nat.dist a b ≤ δ)
```

and prove

```lean
theorem torsion_birthSet_deltaClose
  {F F' : ℕ → ChainComplex Ab ℕ}
  {n δ : ℕ}
  (hint : DeltaInterleaving F F' δ) :
  NatSetDeltaClose (torsionBirthSet F n) (torsionBirthSet F' n) δ
```

This is the cleanest and most Lean-realistic main statement.

### Theorem 3: Chain-homotopy invariance at zero perturbation
Show exact invariance under stagewise chain-homotopy equivalence.

```lean
theorem torsion_birthSet_chainHomotopy_invariant
  {F F' : ℕ → ChainComplex Ab ℕ}
  {n : ℕ}
  (h : StagewiseChainHomotopyEquiv F F') :
  torsionBirthSet F n = torsionBirthSet F' n
```

This theorem is both mathematically necessary and a key base case for the stability proof.

### Theorem 4: Cross-domain theorem via metric geometry
Connect persistence to metric geometry by showing refinement perturbation controls torsion support displacement.

```lean
theorem barycentricSubdivision_torsion_stability
  {F F' : ℕ → ChainComplex Ab ℕ}
  {n : ℕ}
  (href : IsRefinementOfMeshAtMostOne F F') :
  NatSetDeltaClose (torsionBirthSet F n) (torsionBirthSet F' n) 1
```

Interpretation: combinatorial mesh control implies metric control on torsion births.

### Theorem 5: Numerical-analysis style Lipschitz theorem
Connect to numerical analysis by viewing filtration perturbation as a discretization error.

```lean
theorem torsion_birth_lipschitz
  {I : Type} [PseudoMetricSpace I]
  (X : I → ℕ → ChainComplex Ab ℕ)
  (n : ℕ) :
  LipschitzWith 1 (fun p => torsionBirthProfile (X p) n)
```

This may be too ambitious in full generality, but even a discrete version is powerful:
perturbing the input by one filtration step perturbs torsion births by at most one step.

---

## Most promising formal target

The best primary target is **Theorem 2** in the `NatSetDeltaClose` form. It avoids overcommitting to interval decomposition or multiset matching while still capturing a mathematically meaningful and publishable torsion stability theorem.

If successful, derive a corollary for finite filtrations:

```lean
theorem finite_torsion_birth_bottleneck
  {F F' : ℕ → ChainComplex Ab ℕ}
  {n δ : ℕ}
  [FiniteBirths F n] [FiniteBirths F' n]
  (hint : DeltaInterleaving F F' δ) :
  bottleneckNat (torsionBirthMultiset F n) (torsionBirthMultiset F' n) ≤ δ
```

Even if full bottleneck matching is difficult, proving the set-level Hausdorff statement is already a breakthrough.

---

## Proof architecture: 3 viable strategies

### Strategy A: Direct transport of witnesses of torsion birth
**Most promising for Lean.**

1. Unpack `i ∈ torsionBirthSet F n` using `exists_torsion_birth`:
   extract a homology class or cycle witness born at stage `i` that is torsion and not visible earlier.
2. Push the witness across the shifted filtration map using `torsion_persistence_functorial` and composition lemmas like `pTorPersistence_map_comp`.
3. Use the interleaving identities up to chain homotopy to show:
   - torsion is preserved,
   - the image must appear by stage `i + δ`,
   - minimality of birth gives a nearby birth in `F'`.
4. Repeat symmetrically to obtain `NatSetDeltaClose`.

Why this is best: it directly leverages the catalog’s torsion birth existence theorem and functoriality infrastructure, and avoids introducing heavy decomposition theory that is false over `ℤ`.

### Strategy B: Work at the level of torsion support functors
1. Define `torPersistenceModule`-level support:
   a stage belongs to support if the torsion submodule changes nontrivially there.
2. Show a `δ`-interleaving of filtrations induces a `δ`-interleaving of torsion persistence modules.
3. Prove that support jump sets of interleaved torsion modules are `δ`-close.

Why it is conceptually elegant: it isolates the theorem from chain-level details and expresses stability as a module-theoretic phenomenon.

Risk: support-jump formalization may require more algebraic infrastructure than is already available.

### Strategy C: Derived-category / exact-sequence control
1. Analyze torsion births through short exact sequences attached to filtration inclusions.
2. Use connecting morphisms and exactness to characterize birth stages as failures of previous-stage surjectivity/injectivity on torsion subgroups.
3. Show these failures shift by at most `δ` under interleaving.

Why it is interesting: it reframes persistent torsion in terms of derived exactness defects.

Risk: beautiful mathematically, but probably the hardest to execute efficiently in Lean.

**Recommendation:** Use Strategy A for the main theorem, Strategy B for conceptual cleanup/corollaries, and harvest elements of Strategy C only if exact-sequence lemmas are already in the catalog.

---

## Required deep-proof ingredients

Your proofs must visibly use nontrivial tactics and structure. Across the file, ensure theorems use several of:

- `induction` on filtration index or refinement depth
- `rcases` to unpack torsion birth witnesses
- `by_contra` for minimal birth contradictions
- multi-step `calc` chains for transport inequalities and map compositions
- `field_simp` only if a metric/norm estimate genuinely introduces rational bounds
- exactness/chasing via repeated lemma application, not brute-force simplification

Do **not** choose theorem statements that collapse to definitional equality or finite enumeration.

---

## Cross-domain connection requirement

You must include at least one theorem explicitly bridging torsion persistence with another field.

### Preferred bridge: Metric geometry
Formalize a theorem saying that filtration perturbations bounded in mesh induce bounded displacement of torsion birth sets. This makes torsion persistence a metric invariant, not just an algebraic gadget.

**Application keywords:** `metric geometry`, `Hausdorff stability`, `interleaving distance`, `bottleneck control`

### Optional stronger bridge: Numerical analysis
Interpret refinement as discretization. Show torsion birth indices are stable under mesh refinement, analogous to stability of numerically approximated spectra.

**Application keywords:** `discretization error`, `multiscale numerics`, `topological signal analysis`

### Alternative bridge: Materials science / physics
Torsion often detects orientation obstructions and nontrivial gluing. A stable torsion barcode could quantify robust topological defects in discretized media.

**Application keywords:** `topological defects`, `lattice models`, `discrete gauge structure`, `orientation obstruction`

---

## Concrete computational test program

You must also produce a verified computational method, not just pure theorems.

### Algorithmic deliverable
Define and implement a procedure that, for a finite filtration, computes a torsion birth profile or candidate torsion birth set in low degrees.

Possible shape:

```lean
def computeTorsionBirths :
  FiniteFilteredComplex → ℕ → List ℕ
```

or a certified predicate:

```lean
def certifiedTorsionBirths :
  FiniteFilteredComplex → ℕ → Finset ℕ
```

with a correctness theorem relating the output to `torsionBirthSet`.

### Demo target
Test on filtrations of:
- triangulated `RP²`
- barycentric subdivisions of `RP²`
- lens-space-inspired toy filtrations if feasible
- at least 10 synthetic filtered complexes with controlled refinement mesh

The falsifiable prediction is:

> For each example pair `(F, F')` with refinement mesh `m`, every computed torsion birth in degree `1` or `2` moves by at most `m`.

A single counterexample invalidates the conjectured sharp bound.

---

## Conjecture to include in FUTURE_DIRECTIONS.md

State at least one sharp, falsifiable conjecture with a clear test.

### Conjecture A: Sharp mesh stability
For any finite simplicial filtration `F` and its barycentric subdivision filtration `Sd(F)`,
```text
NatSetDeltaClose (torsionBirthSet F n) (torsionBirthSet Sd(F) n) 1
```
for all relevant homological degrees `n`.

**Test:** Compute both sides for `RP²`, Moore spaces, and random 2-complex filtrations. Search for displacement `> 1`.

### Conjecture B: Primewise decomposition stability
If one refines torsion birth sets by prime support, then the stability constant improves:
```text
p-primary torsion birth sets are δ-close with smaller matching ambiguity than total torsion.
```

**Test:** Compute `p`-primary torsion births for `p = 2,3,5` on examples with mixed torsion.

### Conjecture C: Finite bottleneck enhancement
For finite filtrations with bounded torsion rank, the set-level Hausdorff theorem upgrades to a multiset bottleneck theorem.

**Test:** Build explicit finite examples and compare sorted birth multisets under controlled perturbations.

---

## Deliverables you must produce

You must produce **all** of the following:

1. **Lean file(s)** with:
   - at least 3 substantial theorems,
   - at least 1 novel definition,
   - minimal `sorry`,
   - explicit use of catalog torsion lemmas.

2. **`FUTURE_DIRECTIONS.md`**
   - 3–5 falsifiable scientific hypotheses
   - each with a concrete computational or theoretical disproof test

3. **`RESEARCH_PAPER.md`**
   - standalone scientific exposition
   - must explain the mathematical problem, the obstruction from lack of interval decomposition over `ℤ`, the new invariant, the main theorem, proof ideas, examples, and next questions
   - do not assume reader has code access

4. **`ARTICLE.md`**
   - Scientific American style
   - explain why stable torsion matters for extracting subtle shape information from noisy data
   - taboo: do **not** focus on formal verification machinery

5. **A verified algorithm/computational method**
   - for computing or certifying torsion birth information on finite filtrations

6. **`demo.py`**
   - interactive or script-based demonstration
   - compute/visualize torsion birth sets for `RP²` and its barycentric subdivision
   - compare displacements across at least 10 examples

---

## What would count as a breakthrough

A result counts as genuinely field-opening if it establishes even the first rigorous version of the principle:

> torsion persistence, despite lacking interval decomposition, still admits a robust stability theory under interleaving.

That would open:
- torsion-sensitive topological data analysis,
- stable detection of orientation obstructions in noisy geometric data,
- prime-sensitive persistence pipelines,
- new algebraic stability theories beyond barcode decomposability.

This is not a side quest. This is the missing theorem that could make torsion persistence scientifically usable.

---

## Implementation guidance

Start modestly but nontrivially:

1. Formalize `torsionBirthSet`.
2. Prove stagewise chain-homotopy invariance.
3. Define `NatSetDeltaClose`.
4. Prove transport under shifted filtration maps.
5. Upgrade to two-sided `δ`-closeness under interleavings.
6. If time permits, derive finite bottleneck corollaries.

Keep the formalization aligned with the catalog’s existing torsion API; do not rebuild homological algebra from scratch.

---

## Application keywords

`tersistent homology`, `torsion barcodes`, `interleaving distance`, `Hausdorff stability`, `metric geometry`, `topological data analysis`, `derived functors`, `chain homotopy`, `barycentric subdivision`, `discretization error`, `prime torsion`, `orientation obstruction`, `multiscale topology`

---

## Final charge

Do not merely formalize a conjecture-shaped shadow. Invent the correct torsion-stability invariant, prove that it is functorial and stable, and show by theorem and computation that torsion can be made as robust as persistence itself — without pretending `ℤ` behaves like a field.

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
