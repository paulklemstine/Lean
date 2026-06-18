Soli Deo Gloria

## Assignment: Direction 2: Functorial Localization of Persistence Modules

**Mode:** prove

You are not being asked for an incremental cleanup. You are being asked to build the missing algebraic mechanism that makes **primewise persistence stability** look inevitable rather than ad hoc. The breakthrough is to show that the prime-sensitive invariants already appearing in the catalog are shadows of a genuinely functorial localization theory for persistence modules. If this works, then primewise stability is no longer a bespoke theorem: it becomes the image of ordinary persistence stability under an exact/flat base-change machine.

This is the right level of ambition because it connects:
- persistence theory,
- commutative algebra via localization and flatness,
- homological algebra via exactness preservation,
- and computational topology via primewise barcode-like diagnostics.

The conceptual goal is:

> Construct and analyze a localization functor at a prime \(p\) on finitely generated \(\mathbb Z\)-persistence modules, prove that it preserves interleavings and identifies \(p\)-torsion birth data with ordinary torsion birth data after localization, and formulate a testable mechanism by which localization can sharpen effective interleaving witnesses.

This should build directly on:

- `Pythagorean/PrimewiseTorsionStability.lean`
  - `pTorsionBirthSet_eq_torsionBirthSet`
  - `pTorsionBirthSet_deltaClose`

and should explicitly reinterpret those results as consequences or precursors of the new localization formalism.

---

## Precise Mathematical Target

Work in a concrete formalizable model of finitely supported \(\mathbb Z\)-indexed persistence modules valued in finitely generated abelian groups, e.g. a structure consisting of:
- `obj : ℤ → FGAb`
- `map : ∀ {i j : ℤ}, i ≤ j → obj i ⟶ obj j`
- functoriality axioms.

If Mathlib’s category-theoretic infrastructure is too heavy for rapid progress, define a bespoke structure first and only then expose categorical consequences.

### New structure you should define

Define a localized persistence module structure, or a base-change construction, along the lines of:

```lean
structure ZPersModule where
  obj : ℤ → Type
  instAddCommGroupObj : ∀ i, AddCommGroup (obj i)
  instModuleObj : ∀ i, Module ℤ (obj i)
  map : ∀ {i j : ℤ}, i ≤ j → obj i →ₗ[ℤ] obj j
  map_id' : ∀ i, map (show i ≤ i from le_rfl) = LinearMap.id
  map_comp' :
    ∀ {i j k : ℤ} (hij : i ≤ j) (hjk : j ≤ k),
      map (le_trans hij hjk) = (map hjk).comp (map hij)
```

Then define a localization/base-change object at prime `p`:

```lean
def LocalizedAtPrime (p : ℕ) [Fact p.Prime] (F : ZPersModule) : ZPersModule := ...
```

If full localization at `ℤ_(p)` is awkward in Lean, it is acceptable to formalize a mathematically faithful surrogate first:
- either via `IsLocalization` machinery for the submonoid of integers coprime to `p`,
- or via a finite presentation / invariant factor model where localization is implemented by removing torsion at primes `q ≠ p` and extending the free part appropriately.

But the theorem statements must still clearly express the true mathematical localization principle.

---

## Core Theorem Statements

You must prove at least 3 substantial theorems. They should not collapse to definitional simplifications. They must require multi-step argument, induction, contradiction, exactness-style reasoning, or structured `calc`.

### Theorem 1: Functorial preservation of interleavings under localization

A precise theorem should look like:

```lean
theorem localized_preserves_interleaving
    (p : ℕ) [Fact p.Prime]
    (F G : ZPersModule)
    (δ : ℕ)
    (h : Interleaved F G δ) :
    Interleaved (LocalizedAtPrime p F) (LocalizedAtPrime p G) δ := ...
```

If your interleaving parameter is `ℤ`, `ℕ`, or `ENNReal`, choose one and make the shift operation precise. The theorem must state **same parameter δ**, not merely existence of some larger bound.

**Why this matters:** this is the categorical heart of the program. It says localization is stability-compatible as a functor, not just an invariant-level trick.

---

### Theorem 2: Identification of prime torsion births with ordinary torsion births after localization

You should formulate and prove a theorem of the shape:

```lean
theorem pTorsionBirthSet_eq_torsionBirthSet_localized
    (p : ℕ) [Fact p.Prime]
    (F : ZPersModule) :
    PTorsionBirthSet p F = TorsionBirthSet (LocalizedAtPrime p F) := ...
```

or, if your formalization requires finite support / finite generation assumptions:

```lean
theorem pTorsionBirthSet_eq_torsionBirthSet_localized
    (p : ℕ) [Fact p.Prime]
    (F : FiniteTypeZPersModule) :
    PTorsionBirthSet p F = TorsionBirthSet (LocalizedAtPrime p F) := ...
```

This theorem should explicitly subsume or sharpen the catalog theorem
`pTorsionBirthSet_eq_torsionBirthSet`.

**Why this matters:** it converts a prime-filtered invariant into an ordinary torsion invariant after base change. This is the conceptual compression that opens the field.

---

### Theorem 3: Primewise stability as a corollary of ordinary stability after localization

This should be a theorem that visibly derives primewise closeness from ordinary localized torsion stability. For example:

```lean
theorem pTorsionBirthSet_deltaClose_of_interleaving
    (p : ℕ) [Fact p.Prime]
    (F G : ZPersModule)
    (δ : ℕ)
    (h : Interleaved F G δ) :
    DeltaClose δ (PTorsionBirthSet p F) (PTorsionBirthSet p G) := ...
```

but the proof should go through localization and Theorem 2, not by reusing the catalog proof directly. Make the architecture explicit:
1. localize,
2. preserve interleaving,
3. apply ordinary torsion stability,
4. transport back via birth-set identification.

This theorem should act as a **rederivation theorem** showing the new theory has explanatory power.

---

## Ambitious Fourth Theorem: Localization can sharpen witnesses

The most revolutionary theorem here is not just preservation, but a **strict improvement criterion** for interleaving witnesses. You may not be able to prove the strongest possible version in one cycle, but you should formalize at least a meaningful theorem in this direction.

A good target is:

```lean
def PLocalInterleavingWitness
    (p : ℕ) [Fact p.Prime]
    (F G : ZPersModule) (δ : ℕ) : Prop :=
  ∃ φ ψ, IsInterleavingWitness F G δ φ ψ ∧
    MapsBecomeSimplerAfterLocalization p φ ψ
```

and then prove something like:

```lean
theorem localized_witness_improvement_criterion
    (p : ℕ) [Fact p.Prime]
    (F G : ZPersModule) (δ : ℕ)
    (h : PLocalInterleavingWitness p F G δ) :
    ∃ δ' ≤ δ, Interleaved (LocalizedAtPrime p F) (LocalizedAtPrime p G) δ' := ...
```

Even if strict inequality `δ' < δ` cannot yet be proved in full generality, prove a **criterion theorem** showing improvement under a precise algebraic condition, such as vanishing of the obstruction maps after inverting all primes except `p`.

This is where you can be genuinely original.

---

## Recommended Lean 4 Type Signatures

These are suggested targets; adapt to your actual definitions, but keep them this precise.

```lean
def LocalizedAtPrime (p : ℕ) [Fact p.Prime] (F : ZPersModule) : ZPersModule := ...

def PTorsionBirthSet (p : ℕ) [Fact p.Prime] (F : ZPersModule) : Finset ℤ := ...

def TorsionBirthSet (F : ZPersModule) : Finset ℤ := ...

def Interleaved (F G : ZPersModule) (δ : ℕ) : Prop := ...

theorem localized_preserves_interleaving
    (p : ℕ) [Fact p.Prime]
    (F G : ZPersModule) (δ : ℕ) :
    Interleaved F G δ →
    Interleaved (LocalizedAtPrime p F) (LocalizedAtPrime p G) δ := ...

theorem pTorsionBirthSet_eq_torsionBirthSet_localized
    (p : ℕ) [Fact p.Prime]
    (F : ZPersModule) :
    PTorsionBirthSet p F = TorsionBirthSet (LocalizedAtPrime p F) := ...

theorem pTorsionBirthSet_deltaClose_via_localization
    (p : ℕ) [Fact p.Prime]
    (F G : ZPersModule) (δ : ℕ) :
    Interleaved F G δ →
    DeltaClose δ (PTorsionBirthSet p F) (PTorsionBirthSet p G) := ...
```

If you use a more concrete encoding of finitely generated abelian groups, include signatures for:
- Smith normal form decomposition,
- prime-support extraction,
- localization on presentations.

That may actually be the most computationally effective route.

---

## Proof Strategy Architecture

You must include 2–3 serious proof paths and choose one as primary.

### Strategy A: Abstract localization via flat base change
1. Define \(L_p(F)(i) := F(i) \otimes_{\mathbb Z} \mathbb Z_{(p)}\), with structure maps induced functorially.
2. Prove localization preserves composition and identities, hence defines an endofunctor/base-change functor on persistence modules.
3. Show interleaving maps tensor forward, giving preservation of interleavings with the same shift parameter.
4. Use the structure theorem for finitely generated abelian groups after localization:
   \[
   (\mathbb Z^r \oplus \bigoplus_q T_q)\otimes \mathbb Z_{(p)}
   \cong \mathbb Z_{(p)}^r \oplus T_p,
   \]
   i.e. only \(p\)-primary torsion survives.
5. Deduce equality of birth sets and transport ordinary torsion stability to primewise torsion stability.

**Why promising:** conceptually perfect and field-opening. It exposes the exact commutative algebra mechanism.

**Risk:** Mathlib localization/tensor infrastructure may be heavy.

---

### Strategy B: Concrete classification route via invariant factors / primary decomposition
1. Represent each finitely generated abelian group in the persistence module by a normal form:
   free rank plus a finite multiset of primary torsion summands.
2. Define `LocalizedAtPrime` by deleting all torsion summands whose prime is not `p`, keeping the free part.
3. Prove this operation commutes with persistence maps once maps are expressed in a compatible presentation.
4. Show the torsion births in the localized system are exactly the \(p\)-torsion births in the original system.
5. Derive interleaving preservation and the delta-close theorem by tracking generators and deaths explicitly.

**Why promising:** much more computational and demo-friendly. This route may be easier to verify on random examples and more suitable for `demo.py`.

**Risk:** more implementation overhead up front, and less elegant than true tensor localization unless carefully narrated.

---

### Strategy C: Derived/obstruction-theoretic witness improvement
1. Define an obstruction to a \(\delta\)-interleaving witness in terms of torsion annihilators or failure of certain maps to split.
2. Prove that localization at \(p\) kills all obstruction components supported away from \(p\).
3. Deduce a criterion under which the minimal witness parameter decreases after localization.
4. Search computationally for explicit finite modules where this criterion is met strictly.

**Why promising:** this is the genuinely new science-fiction part. If it works, it says localization does not merely preserve stability—it can improve observed alignment.

**Risk:** likely too ambitious as the primary path. Best as theorem + conjecture + computational experiment.

---

## Most Promising Route

**Primary route: Strategy B, narrated as a concrete model of Strategy A.**

Reason: you need a result this cycle that is both mathematically deep and executable in Lean with minimal sorry. A concrete finitely generated abelian group model can still express the true localization phenomenon while supporting:
- rigorous theorem proving,
- explicit algorithms,
- random testing,
- and interactive demos.

Then, in the paper, explain that the concrete implementation is a finite-presentation shadow of the abstract tensor-localization theorem one ultimately wants.

---

## Cross-Domain Connections You Must Exploit

Do not leave these as slogans; make at least one theorem bridge domains.

### 1. Commutative algebra × topological data analysis
Localization is a standard algebraic microscope. Here it becomes a **topological frequency filter** for persistence: one prime at a time. This recasts persistence modules as arithmetic objects and opens primewise denoising / decomposition.

A theorem or definition should explicitly identify localization as a base-change functor and explain prime-support decomposition of persistence information.

### 2. Homological algebra × signal separation
Prime localization behaves like spectral filtering: each prime isolates a channel of torsion information. This suggests a theorem or conjecture about decomposition of torsion birth data across primes:
```lean
conjecture torsion_birthSet_decomposes_over_primes : ...
```
with finite computational tests.

### 3. Derived categories / sheaf-theoretic viewpoint
Frame localized persistence as the degree-0 shadow of derived base change. Even if not fully formalized, your `FUTURE_DIRECTIONS.md` should propose a derived persistence localization theory where higher Tor terms measure instability of non-flat constructions.

### 4. Arithmetic topology
There is a deep analogy between prime decomposition in number theory and decomposition of torsion persistence features into prime channels. Push this language in the paper and article. It is not decorative; it gives a new ontology for persistence invariants.

---

## A Falsifiable Conjecture with Computational Test

You must state and test at least one concrete conjecture. Here is the right one:

> **Conjecture (strict witness improvement).**
> There exist finitely supported \(\mathbb Z\)-persistence modules \(F,G\) and a prime \(p\) such that the minimal interleaving parameter between \(F\) and \(G\) is strictly larger than the minimal interleaving parameter between \(L_p(F)\) and \(L_p(G)\).

Formalize a computable surrogate:

```lean
def interleavingDistance (F G : FiniteZPersModule) : ℕ := ...
```

and state:

```lean
conjecture exists_strict_localization_improvement
    (p : ℕ) [Fact p.Prime] :
    ∃ F G, interleavingDistance (LocalizedAtPrime p F) (LocalizedAtPrime p G)
          < interleavingDistance F G := ...
```

### Computational test
Generate 100 random finite persistence modules built from:
- free summands,
- cyclic torsion summands `ZMod (p^k)` and `ZMod (q^ℓ)`,
- sparse structure maps.

For each:
1. compute `PTorsionBirthSet p F`,
2. compute `TorsionBirthSet (LocalizedAtPrime p F)`,
3. verify equality,
4. test preservation of interleavings under random witnesses,
5. search for strict improvements in minimal δ.

A failed search does **not** disprove the conjecture; a counterexample to equality/preservation does.

---

## Expected Theorem-Level Mathematical Insight

You should explicitly exploit the algebraic fact:

\[
A \otimes_{\mathbb Z} \mathbb Z_{(p)}
\cong A_{\mathrm{free}} \otimes \mathbb Z_{(p)} \oplus A[p^\infty],
\]
for finitely generated abelian \(A\), where all \(q\)-primary torsion with \(q \neq p\) vanishes after localization.

In the persistence setting, this means:
- births of \(q\)-torsion classes for \(q \neq p\) disappear,
- births of \(p\)-torsion classes survive unchanged in index,
- free classes remain but do not contribute to torsion birth sets.

This is the exact mechanism behind Theorem 2. Your proof should make this decomposition transparent, not merely computational.

---

## Concrete Deliverables Inside the Lean File

Your Lean development must include:

1. **At least one genuinely new definition**
   such as `LocalizedAtPrime`, `PLocalInterleavingWitness`, `PrimeSupportProfile`, or `LocalizedPersistenceMap`.

2. **At least 3 deep theorems**
   with nontrivial proofs using tactics like:
   - induction on filtration length,
   - `rcases` on decomposition data,
   - `by_contra` to rule out spurious torsion survival,
   - `field_simp` if you encode localization fractions,
   - multi-step `calc` chains for functoriality and equality transport.

3. **At least one cross-domain theorem**
   Example target:
   ```lean
   theorem torsion_birth_support_decomposes_primewise
       (F : FiniteZPersModule) :
       TorsionBirthSet F =
         ⋃ p ∈ primeSupport F, PTorsionBirthSet p F := ...
   ```
   This connects persistence with arithmetic prime decomposition. Even if expressed via finsets rather than unions, the theorem should say the ordinary torsion signal is assembled from prime channels.

4. **A verified algorithm**
   implementing localization on finite persistence modules and computing the induced torsion birth sets.

5. **A demo**
   showing random examples and any strict-improvement candidates discovered.

---

## Suggested File/Section Architecture

A strong architecture would be:

- `Localization/FiniteFGAbModel.lean`
  - concrete representation of finitely generated abelian groups
- `Localization/PersistenceLocalization.lean`
  - persistence modules, interleavings, localized functor
- `Localization/PrimewiseStabilityViaLocalization.lean`
  - core theorems and corollaries
- `Localization/Algorithms.lean`
  - computable localization and birth-set extraction

If you must keep it in one file, organize by sections:
1. algebraic model,
2. localization construction,
3. interleaving preservation,
4. birth-set identification,
5. stability corollary,
6. computational criterion/conjecture.

---

## Application Keywords

Include these explicitly in the paper and metadata-style summaries:

- primewise persistence
- localization functor
- \(p\)-primary torsion
- interleaving stability
- flat base change
- finitely generated abelian groups
- topological data analysis
- commutative algebra
- arithmetic decomposition
- spectral filtering
- derived persistence
- algorithmic barcode refinement

---

## Revolutionary Significance

If successful, this project opens a new subfield: **arithmetic persistence theory**. The message is that persistence modules over \(\mathbb Z\) are not merely richer than field-valued persistence because they contain torsion; they are richer because their torsion admits **primewise geometric optics** via localization. This would enable:

- prime-by-prime stability theory,
- arithmetic denoising of persistence signals,
- localization-based comparison algorithms,
- eventual derived and sheaf-theoretic persistence constructions,
- and new bridges between TDA and commutative/homological algebra.

This is not “another theorem about torsion.” It is the algebraic infrastructure that makes primewise phenomena inevitable, modular, and extensible.

---

## Mandatory Non-Lean Deliverables

You must also produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
3–5 original research directions. Each direction must include:
- a sentence beginning exactly with **“The key insight is...”**
- a sentence beginning exactly with **“Why now?”**
At least one direction must bridge to a different domain, such as:
- derived algebraic geometry,
- arithmetic statistics,
- signal processing,
- or quantum error correction.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper that:
- defines the problem,
- explains the localization construction,
- states the main theorems precisely,
- explains why they matter conceptually,
- describes the computational experiments,
- and outlines next-step conjectures.
A reader with no access to the code must still understand the discovery.

### 3. `ARTICLE.md`
Write in Scientific American style:
- vivid,
- concept-driven,
- accessible to broad scientific readers.
**Taboo:** do not focus on formal verification machinery. Focus on the mathematics and why prime localization changes the way we think about persistence.

### 4. Verified algorithm/computational method
Not just theorem statements: implement the actual localization and birth-set computation machinery for finite examples.

### 5. `demo.py`
Interactive or semi-interactive script that:
- generates random finite persistence modules,
- localizes at chosen primes,
- compares `PTorsionBirthSet p F` with `TorsionBirthSet (LocalizedAtPrime p F)`,
- tests interleaving preservation on sampled examples,
- and searches for strict improvement candidates.

---

## Final Charge

Do not settle for a theorem that merely restates catalog results in new notation. The target is to make primewise torsion stability emerge from a functorial localization principle. If you succeed, you will have replaced a family of isolated persistence facts with an algebraic machine. That is the kind of move that creates a research program rather than a lemma.

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
- **Visualization scripts** — Produce up to 3 self-contained Python scripts
  that visually illustrate the core mathematical concepts discovered. Use
  matplotlib for static plots (heatmaps, curves, surfaces) or plotly for
  interactive charts. Available libraries: numpy, matplotlib, plotly.
  If using matplotlib, the script must call plt.savefig() — the system
  captures the output as a PNG. If using plotly, assign the figure to a
  variable named `fig` — the system captures fig.to_html(). Each script
  must include a comment header explaining what it visualizes and why.
  **CRITICAL: Each visualization script MUST be a single, fully self-contained
  file. Do NOT import from any local modules (algorithms.py, demo.py, etc.).
  Instead, inline all needed functions and classes directly in the script.
  The browser runtime (Pyodide) has no access to local .py files.**
- **Interactive HTML demos** — Produce up to 3 self-contained HTML snippets
  (with inline CSS/JS, no external dependencies) that demonstrate the
  mathematical concepts interactively — sliders, animations, dynamic SVG,
  or canvas drawing. Each demo must be a complete <div> fragment that
  works when inserted into a page. No <html>, <head>, or <body> tags —
  just the content div with its inline styles and scripts.

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
    "visualizations": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files. Inline all needed functions directly.", "description": "What this visualizes" } ],
    "interactive_demos": [ { "name": "...", "html": "<div>...</div>", "description": "What this demonstrates" } ],
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
