## Assignment: Direction 3 (Grand Challenge): Ext-Tor Persistent Spectral Sequence

**Mode**: `prove` + `formalize` + `discover`

Build a formal Lean 4 foundation for a **derived persistence theory** in which filtered chain complexes over `ℤ` give rise to a spectral-sequence-like hierarchy of torsion invariants, with an `E₂` page governed by `Tor`/`Ext` of associated-graded data and with higher differentials detecting torsion phenomena invisible to first-order invariants.

This must not be a cosmetic extension of existing `Tor₁` detection. The target is a genuinely new theorem package that makes a research mathematician say: *persistent homology has a derived layer, and Lean can certify it.*

---

## Core Breakthrough Goal

The central scientific objective is to formalize a **persistent exact-couple machine** for filtered chain complexes over `ℤ`, then prove rigorous theorems showing that the first nontrivial derived page carries `Tor`/`Ext` information of the associated graded, and that the next differential defines a secondary torsion obstruction.

Even if full spectral sequence convergence is not yet available in Mathlib, you must still prove a mathematically substantive approximation theorem: an exact-couple / page-2 / obstruction package strong enough to justify the slogan

> “Persistent homology admits derived torsion corrections, and these corrections are functorial and computable.”

This is the minimal field-opening nucleus.

---

## Precise Theorem Targets

You should aim for **at least 3 deep theorems**, with one flagship theorem and two supporting structural theorems. The following formulations are the intended targets.

### New definitions you should introduce

You must define at least one genuinely new structure. Recommended core definition:

```lean
structure FilteredChainComplex where
  (ι : Type*)
  [preorder_ι : Preorder ι]
  (C : ι → ChainComplex ModuleCat.{0} ℤ ℕ)
  (incl : ∀ {p q : ι}, p ≤ q → (C p) ⟶ (C q))
  (incl_id : ∀ p, incl (show p ≤ p from le_rfl) = 𝟙 _)
  (incl_comp :
    ∀ {p q r : ι} (hpq : p ≤ q) (hqr : q ≤ r),
      incl (le_trans hpq hqr) = incl hpq ≫ incl hqr)
```

Then define a page-1/page-2 approximation object, for example:

```lean
structure PersistentExactCoupleData where
  (D E : ℤ → ℤ → Type*)
  (i : ∀ p q, D p q → D p (q-1))
  (j : ∀ p q, D p q → E p q)
  (k : ∀ p q, E p q → D (p-1) q)
  (exact_ijk : Prop)
```

and a secondary torsion invariant, e.g.

```lean
def SecondaryTorsionObstruction
  (F : FilteredChainComplex) : Type := ...
```

You may simplify indices if necessary; the key is to define a formal object representing the first derived obstruction beyond `Tor₁`.

---

## Flagship Theorem A: Functorial page-2 Tor/Ext identification

### Mathematical statement
For a filtered chain complex `F` of finitely generated abelian groups with bounded filtration and degreewise finite-type associated graded pieces, there exists a canonical page-2 approximation `E₂(F)` such that each bidegree is naturally identified with a direct sum of `Tor` and `Ext` groups built from the homology of the associated graded pieces. Moreover, this construction is functorial in filtered chain maps.

A sharpened bidegree form to target:

\[
E^{p,q}_2(F) \cong \operatorname{Tor}_1^{\mathbb Z}(H_{q-1}(\mathrm{gr}_p F), \mathbb Z/n\mathbb Z)
\;\oplus\;
\operatorname{Ext}^1_{\mathbb Z}(H_q(\mathrm{gr}_p F), \mathbb Z/n\mathbb Z)
\]

for a coefficient system parameter `ℤ/nℤ`, or an integral version where `Ext/Tor` arise in the universal-coefficient decomposition of the page.

If full generality is too heavy, prove the theorem first for **two-step filtrations**; that is still deep and nontrivial, and it isolates the first genuinely derived persistent correction.

### Suggested Lean 4 signature
A realistic formal target, allowing some abstraction over the exact `E₂` implementation:

```lean
theorem page_two_natIso_ext_tor
  (F : FilteredChainComplex)
  (hbounded : BoundedFiltration F)
  (hfg : FiniteTypeAssociatedGraded F) :
  ∃ (E2 : ℤ → ℤ → AddCommGroupCat),
    (∀ p q,
      Nonempty
        (E2 p q ≅
          AddCommGroupCat.of
            ((ModuleCat.of ℤ) ⟶ (ModuleCat.of ℤ)))) ∧
    PageTwoFunctorial F E2
```

A more concrete and preferable finite-abelian-group formulation:

```lean
theorem page_two_decomposition
  (F : FilteredChainComplex)
  (p q : ℤ)
  (hbounded : BoundedFiltration F)
  (hfg : FiniteTypeAssociatedGraded F) :
  ∃ A B : Type,
    Nonempty (A ≃+ Tor₁ℤ (assocGrHomology F p (q-1)) defaultCoeff) ∧
    Nonempty (B ≃+ Ext₁ℤ (assocGrHomology F p q) defaultCoeff) ∧
    Nonempty (pageTwoGroup F p q ≃+ (A × B))
```

You should adapt the exact signature to the catalog APIs around:

- `Algebra/Homology/DerivedFunctors/TorsionDetection.lean`
- `Catalog/Algebra/Homology/DerivedFunctors/ExtTorBasic.lean`
  - `Tor1_ZMod_ZMod_equiv`
  - `Ext1_ZMod_ZMod_equiv`

### Why this is a breakthrough
This theorem would be the first certified bridge from **persistent topology** to **derived functor technology** in Lean. It upgrades persistence from rank/barcode data to a derived invariant package sensitive to extension classes and torsion interaction across filtration layers. That is the birth of **derived TDA**.

---

## Supporting Theorem B: Secondary torsion obstruction is nontrivial and functorial

### Mathematical statement
Define a secondary obstruction `δ₂(F)` from the exact-couple differential data of a filtered chain complex. Prove:

1. `δ₂(F)` is natural under filtered chain maps.
2. If `δ₂(F) ≠ 0`, then the torsion pattern in total homology cannot be reconstructed from page-1 `Tor₁` data alone.
3. For split filtrations, `δ₂(F) = 0`.

This theorem formalizes the slogan that the first higher differential detects “hidden torsion coupling.”

### Suggested Lean 4 signature

```lean
theorem secondary_torsion_obstruction_natural
  {F G : FilteredChainComplex}
  (φ : FilteredChainMap F G) :
  mapSecondaryObstruction φ (secondaryTorsionObstruction F) =
    secondaryTorsionObstruction G
```

```lean
theorem secondary_obstruction_vanishes_of_split
  (F : FilteredChainComplex)
  (hsplit : FiltrationSplit F) :
  secondaryTorsionObstruction F = 0
```

```lean
theorem nonzero_secondary_obstruction_not_detected_by_tor1
  (F : FilteredChainComplex)
  (hδ : secondaryTorsionObstruction F ≠ 0) :
  ¬ Tor1OnlyDetectsTotalTorsion F
```

### Why this is a breakthrough
This is the conceptual heart of the project. It says that persistence has a **secondary layer of information**, analogous to secondary operations in homotopy theory or anomalies in gauge theory: local first-order invariants do not globally determine the system. That is exactly the kind of conceptual leap that opens a field.

---

## Supporting Theorem C: Two-step filtered complexes already exhibit derived persistence

### Mathematical statement
For a two-step filtered chain complex
\[
0 \subseteq F^0C \subseteq F^1C = C,
\]
the page-2 approximation and secondary obstruction can be computed explicitly from the extension class of the short exact sequence of chain complexes. Prove that this obstruction vanishes iff the filtration splits in the derived sense.

### Suggested Lean 4 signature

```lean
theorem two_step_secondary_obstruction_eq_extension_class
  (F : TwoStepFilteredChainComplex)
  (p q : ℤ) :
  secondaryTorsionObstruction (F.toFilteredChainComplex) p q =
    extensionClassToObstruction F p q
```

```lean
theorem two_step_obstruction_vanishes_iff_derived_split
  (F : TwoStepFilteredChainComplex) :
  secondaryTorsionObstruction (F.toFilteredChainComplex) = 0 ↔
    DerivedFiltrationSplit F
```

### Why this matters
If full spectral sequence infrastructure is too ambitious in one cycle, this theorem gives a complete, nontrivial, publishable theorem schema. Two-step filtrations are enough to exhibit the new phenomenon cleanly and are already rich enough to model mapping cones, mapping tori, and extension-driven torsion effects.

---

## Proof Strategy Architecture

You must present and execute **2–3 proof pathways**, not just one.

### Strategy A: Exact-couple-first construction
1. Define the exact couple from filtered subcomplexes and quotient complexes.
2. Prove exactness using long exact sequences in homology for short exact sequences of chain complexes.
3. Derive the page-2 object and identify it via universal coefficient decompositions using catalog `Tor`/`Ext` equivalences.

**Why promising:** This is the most mathematically canonical route and best aligns with the conjectural spectral sequence statement.

### Strategy B: Two-step filtration as derived extension calculus
1. Restrict first to filtrations with only two nontrivial stages.
2. Encode the filtration as a short exact sequence of chain complexes.
3. Show the connecting homomorphism / extension class induces the secondary torsion obstruction.
4. Recover page-2-style `Tor/Ext` terms from homology of subquotients.

**Why promising:** This avoids needing full spectral sequence infrastructure while still proving genuinely new theorems. Likely the best path for this cycle.

### Strategy C: Persistent module viewpoint via exact triangles
1. Treat the filtered complex as a persistence diagram in the derived category.
2. Formalize truncations / cofibers / associated graded pieces.
3. Show secondary torsion arises from failure of decomposition into interval-like pieces.
4. Compare with `Tor₁`-only invariants using explicit counterexamples.

**Why promising:** This creates the strongest cross-domain bridge to TDA and representation theory, but may be heavier in Lean. Use it if Mathlib support for homological algebra categories is sufficient.

**Recommendation:** Execute **Strategy B first**, then bootstrap pieces of Strategy A. Strategy B gives the clearest route to deep theorems with manageable formal overhead.

---

## Required Use of Catalog Theorems

You must explicitly build on:

- `Algebra/Homology/DerivedFunctors/TorsionDetection.lean`
- `Catalog/Algebra/Homology/DerivedFunctors/ExtTorBasic.lean`
  - `Tor1_ZMod_ZMod_equiv`
  - `Ext1_ZMod_ZMod_equiv`

Use them concretely, not decoratively:
- Use `Tor1_ZMod_ZMod_equiv` to identify first-order torsion in associated graded homology groups.
- Use `Ext1_ZMod_ZMod_equiv` to model extension data contributing to the page-2 decomposition or obstruction class.
- Prove that the new obstruction refines the detection power of those catalog theorems rather than merely restating them filtration-wise.

A strong theorem would explicitly show:
```lean
theorem secondary_refines_catalog_torsion_detection
  (F : TwoStepFilteredChainComplex) :
  Tor1DetectablePart F ≤ TotalTorsionInvariant F ∧
  secondaryTorsionObstruction F = 0 ↔
    Tor1DetectablePart F = TotalTorsionInvariant F
```

---

## Cross-Domain Connections You Must Exploit

Include at least one theorem and discussion thread connecting this work to another domain.

### 1. Homotopy theory
The higher differential should be framed as a certified analog of a **secondary operation**. This links filtered homology to exact couples, Postnikov-style obstructions, and derived extensions.

### 2. Mathematical physics
Interpret the secondary torsion obstruction as an algebraic shadow of an **anomaly**: a local invariant (`Tor₁`) fails to glue globally, and the obstruction measures that failure. This is not just rhetoric—make it precise by proving a naturality theorem under filtered maps, analogous to anomaly functoriality.

### 3. Topological data analysis
Persistent homology usually forgets extension data. Your theorem package should imply that barcodes/ranks are incomplete in the presence of torsion and filtered extension phenomena. This opens **torsion-sensitive TDA** and **derived persistence descriptors**.

### 4. Arithmetic topology / number theory
If feasible, include a theorem or conjecture connecting torsion page behavior to `p`-primary decomposition:
```lean
theorem secondary_obstruction_decomposes_by_prime
  (F : FilteredChainComplex) :
  secondaryTorsionObstruction F ≃
    ⨁ p : PrimeSpectrum ℤ, pPrimarySecondaryObstruction F p
```
Even a partial theorem for finite abelian groups would be excellent.

---

## Concrete Computational Testbed

You must implement a verified algorithm or computational method for explicit examples.

Primary test family:
- filtered triangulations / cellular chain models of the **mapping torus of degree-2 map `S¹ → S¹`**
- optional comparison family: lens spaces `L(p,q)` with filtration by skeleta or subcomplexes

The test must compare:
1. `Tor₁`-only detection on associated graded homology
2. the secondary obstruction / page-2 invariant
3. total homology torsion

and verify cases where (2) detects something missed by (1).

### Algorithmic target
Define an executable routine for small finite chain complexes over `ℤ`:
- input: boundary matrices + filtration labels
- compute: associated graded chain groups, homology summaries, candidate `Tor₁` page, extension/obstruction witness
- output: explicit certificate that `Tor₁`-only data is insufficient or sufficient

A plausible Lean-facing API:

```lean
def computeTwoStepDerivedPersistence
  (F : FiniteTwoStepFilteredComplex) :
  DerivedPersistenceSummary
```

with a soundness theorem:

```lean
theorem computeTwoStepDerivedPersistence_sound
  (F : FiniteTwoStepFilteredComplex) :
  realizesDerivedPersistenceInvariant F (computeTwoStepDerivedPersistence F)
```

This is mandatory: not just theorem statements, but a verified computational method.

---

## Conjecture with Testable Prediction

You must state at least one falsifiable conjecture with a clear computational disproof criterion.

### Recommended conjecture
**Conjecture (primewise collapse criterion).**
For any bounded finite filtered chain complex over `ℤ`, if every `p`-primary secondary torsion obstruction vanishes, then the derived persistent exact-couple collapses at page 2 and total torsion is determined by page-2 `Ext/Tor` data.

A Lean declaration placeholder could be:

```lean
conjecture primewise_secondary_vanishing_implies_page2_collapse
  (F : FiniteFilteredChainComplex) :
  (∀ p, pPrimarySecondaryObstruction F p = 0) →
  PageTwoDeterminesTotalTorsion F
```

### Computational test
Search over small filtered chain complexes with boundary entries in `{-2,-1,0,1,2}` and filtration length `≤ 3`.
- If you find a complex with all primewise secondary obstructions zero but with page-2 data not determining total torsion, the conjecture is false.
- Otherwise, produce empirical support tables in `FUTURE_DIRECTIONS.md`.

---

## Minimum Theorem Complexity Requirements

Your Lean file must contain at least **3 nontrivial theorems** whose proofs use genuine mathematical structure:
- induction on filtration length or chain degree,
- `rcases` on exactness or decomposition data,
- `by_contra` to show non-detectability by `Tor₁`,
- `field_simp` if rationalized auxiliary calculations arise,
- multi-step `calc` chains for naturality / equivalence compositions.

Do **not** waste theorem slots on decidable equalities or tautological transport lemmas.

---

## Suggested File/Module Architecture

Create a focused development, e.g.

- `DerivedPersistence/FilteredChainComplex.lean`
- `DerivedPersistence/TwoStepObstruction.lean`
- `DerivedPersistence/PageTwoExtTor.lean`
- `DerivedPersistence/Examples/MappingTorusDegTwo.lean`

The examples file should contain the explicit computational witness family.

---

## Deliverables You Must Produce

You must produce **all** of the following:

1. **Lean code** with the new definitions, at least 3 deep theorems, and minimized `sorry`.
2. **A structured `FUTURE_DIRECTIONS.md`** with **3–5 falsifiable scientific hypotheses**, each with:
   - precise conjecture,
   - what computation/theorem would test it,
   - what outcome would falsify it.
3. **A standalone `RESEARCH_PAPER.md`** explaining:
   - the mathematical discovery,
   - precise theorem statements,
   - proof architecture,
   - why it matters scientifically,
   - limitations and next steps.
4. **An accessible `ARTICLE.md`** in Scientific American style:
   - what persistent homology misses,
   - how derived torsion repairs that blindness,
   - why this matters beyond pure math.
5. **A verified algorithm or computational method** for finite filtered chain complexes.
6. **A `demo.py`** that interactively demonstrates the result on small examples, especially the degree-2 mapping torus case.

---

## Application Keywords

Derived persistence; exact couples; spectral sequences; filtered chain complexes; Tor; Ext; universal coefficient theorem; torsion invariants; secondary operations; anomaly detection; persistent homology; topological data analysis; homotopy theory; arithmetic topology; finite abelian groups; mapping torus; lens spaces; certified computation; formalized homological algebra.

---

## Final Charge

Do not settle for “there exists some filtration machinery.” Prove a theorem package that certifies the first real sentence of a new field:

> **Persistent topology has higher derived torsion invariants, these invariants are functorial, computable, and strictly stronger than first-order Tor detection.**

If full spectral sequence convergence is out of reach, make the two-step filtration case so precise, so natural, and so computationally verified that it becomes the canonical seed from which the full theory must grow.

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
