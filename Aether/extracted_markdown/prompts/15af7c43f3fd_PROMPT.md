## Assignment: Direction 2: Persistent Homology of Tropical Filtrations

**Mode:** `prove`

Prove genuinely new theorems at the interface of tropical geometry, combinatorial topology, and persistent homology. Build explicitly on the catalog results

- `Tropical/ArithmeticUniversality/Defs.lean`
- theorem `sublevel_mono`
- theorem `activeSetComplex_mono`
- theorem `tropMax_sublevel_convex`

and use them as certified foundations rather than re-proving basic monotonicity/convexity facts.

Your goal is not to formalize a toy persistence statement. Your goal is to create the first Lean-certified bridge from **tropical active-set combinatorics** to **barcode complexity bounds** and **stability of topological signatures**.

---

## Central Vision

The catalog already suggests a decisive dichotomy:

- for **tropical max / convex tropical affine families**, sublevel sets are convex and hence topologically trivial;
- the genuinely interesting topology appears for **tropical min**, **differences of tropical affine forms**, or **finite unions of tropical convex pieces**, where topology is controlled by how active sets glue and change.

The breakthrough is to isolate a combinatorial object — an **active-set nerve filtration** — whose changes certify all topological events in the filtration. If you can prove that persistence is controlled by this finite combinatorial skeleton, you will have converted a geometric-topological problem into a finite tropical-combinatorial one. That is the right theorem: finite, computable, structurally explanatory, and extensible to random models.

---

## New Definitions You Should Introduce

You must define at least one genuinely new structure. I recommend introducing all three below.

### 1. Tropical patch cover
For a tropical family `F`, define the family of local sublevel patches indexed by active sets:
- each patch consists of points where a specified subset of affine forms realizes the tropical minimum and the value is `≤ c`.

This is the right cover for a Nerve-theorem style argument.

### 2. Active-set nerve filtration
A simplicial filtration whose simplices are finite collections of active sets with nonempty common patch intersection at threshold `c`.

This gives a combinatorial persistence object attached to `F`.

### 3. Barcode-critical value
A threshold `c` is barcode-critical if the active-set nerve filtration changes at `c`.

This gives a formally tractable replacement for analytic Morse-type critical values.

These should be stated in Lean-friendly finite/combinatorial language.

---

## Precise Theorem Targets

You must prove at least **3 substantial theorems**. The following package is ambitious but coherent.

### Theorem 1: Convex tropical max has trivial persistent homology
This is the baseline theorem that clarifies where topology can and cannot arise.

**Mathematical statement.**  
Let `F` be a tropical max-affine family on a real vector space. For every threshold `c`, if the sublevel set `S_F(c)` is nonempty then it is contractible. Consequently, all persistence bars in positive degree are absent, and in degree `0` there is at most one bar.

This theorem is not the destination; it is the conceptual launchpad. It shows that persistent topology is not a generic feature of tropical filtrations, but a signature of non-convex tropical constructions.

**Lean 4 target shape.**
```lean
theorem tropMax_sublevel_contractible
  {n m : ℕ} (F : TropicalMaxFamily ℝ n m) (c : ℝ) :
  IsEmpty (SublevelSet F c) ∨ ContractibleSpace (SublevelSet F c)

theorem tropMax_persistent_homology_vanishes
  {n m k : ℕ} (F : TropicalMaxFamily ℝ n m) (c₁ c₂ : ℝ)
  (h : c₁ ≤ c₂) (hk : 0 < k) :
  PersistentBetti F k c₁ c₂ = 0
```

If `PersistentBetti` is too heavy to define fully in this cycle, define a verified surrogate invariant, e.g. Betti number of the active-set nerve or homology rank of a finite simplicial approximation, and prove vanishing there.

---

### Theorem 2: Active-set nerve controls topology of tropical min filtration
This is the first true breakthrough theorem.

**Mathematical statement.**  
Let `F` be a finite tropical min-affine family in `ℝ^n`. Suppose that for every threshold `c`, the sublevel set `S_F(c)` admits a finite cover by tropical patches indexed by active sets, and every nonempty finite intersection of patches is contractible. Then for every `c`, the sublevel set `S_F(c)` is homotopy equivalent to the active-set nerve complex `N_F(c)`.

Consequently, the Betti numbers of `S_F(c)` equal those of `N_F(c)`, and all topological changes in the filtration are detected by changes in the active-set nerve.

This is the theorem that turns tropical persistent homology into finite combinatorics.

**Lean 4 target shape.**
```lean
structure TropicalPatchCover (F : TropicalMinFamily ℝ n m) (c : ℝ) where
  ι : Type
  finite_ι : Fintype ι
  patch : ι → Set (Fin n → ℝ)
  cover_eq : SublevelSet F c = ⋃ i, patch i
  patch_contractible : ∀ i, ContractibleSpace {x // x ∈ patch i}
  inter_contractible :
    ∀ s : Finset ι, s.Nonempty →
      (⋂ i ∈ s, patch i).Nonempty →
      ContractibleSpace {x // x ∈ ⋂ i ∈ s, patch i}

def ActiveSetNerve (F : TropicalMinFamily ℝ n m) (c : ℝ) : SimplicialComplex _ := ...

theorem sublevel_homotopy_equiv_activeSetNerve
  {n m : ℕ} (F : TropicalMinFamily ℝ n m) (c : ℝ)
  (Hcov : TropicalPatchCover F c) :
  Nonempty ((SublevelSet F c) ≃ₕ geometricRealization (ActiveSetNerve F c))
```

If a full Nerve theorem is not available in Mathlib in the exact needed form, prove a **finite-combinatorial surrogate**:
- equality of connected components,
- Euler characteristic equality,
- or homology isomorphism in low degree under stronger hypotheses.

Even a verified theorem for `H₀` and `EulerCharacteristic` would already be a real result if formulated sharply.

---

### Theorem 3: Barcode events occur only at active-set changes
This is the persistence theorem proper.

**Mathematical statement.**  
Let `F` be a finite tropical min-affine family, and let `c₁ < c₂`. If the active-set nerve is constant on the interval `[c₁,c₂]`, then the inclusion
\[
S_F(c₁) \hookrightarrow S_F(c₂)
\]
induces isomorphisms on all homology groups represented by the nerve model. Therefore no bar is born or dies in `[c₁,c₂]`.

Equivalently: barcode endpoints belong to the finite set of thresholds at which the active-set nerve changes.

This theorem gives the promised finite combinatorial bound on persistence complexity.

**Lean 4 target shape.**
```lean
def ActiveSetNerveConstantOn (F : TropicalMinFamily ℝ n m) (a b : ℝ) : Prop := ...

def BarcodeCritical (F : TropicalMinFamily ℝ n m) (c : ℝ) : Prop :=
  ¬ ∃ ε > 0, ActiveSetNerveConstantOn F (c - ε) (c + ε)

theorem no_barcode_event_of_nerve_constant
  {n m k : ℕ} (F : TropicalMinFamily ℝ n m) {c₁ c₂ : ℝ}
  (h₁₂ : c₁ ≤ c₂)
  (hconst : ActiveSetNerveConstantOn F c₁ c₂) :
  PersistentBetti F k c₁ c₂ = BettiLikeInvariant F k c₁

theorem barcode_endpoints_subset_criticalValues
  {n m : ℕ} (F : TropicalMinFamily ℝ n m) :
  ∀ t, BarcodeEndpoint F t → BarcodeCritical F t
```

Again, if full persistence machinery is too large, define and prove this for a verified finite persistence surrogate built from the nerve filtration.

---

### Theorem 4: Finite bar-count bound by active-set complexity
This theorem captures the original conjectural spirit in a Lean-feasible form.

**Mathematical statement.**  
Assume the active-set nerve filtration of `F` has only finitely many combinatorial changes, and let `𝒜_F` denote the finite set of active sets appearing in the filtration. Then the number of barcode events is bounded above by the number of active-set nerve changes, hence in particular by a finite function of `|𝒜_F|` (for example by the number of simplices in the nerve built from `𝒜_F`).

A realistic theorem may bound:
- number of connected-component mergers/births;
- total number of changes in Euler characteristic;
- or number of filtration change-points.

This is already powerful and computable.

**Lean 4 target shape.**
```lean
def activeSetUniverse (F : TropicalMinFamily ℝ n m) : Finset (Finset (Fin m)) := ...

def nerveChangePoints (F : TropicalMinFamily ℝ n m) : Finset ℝ := ...

theorem card_nerveChangePoints_le_activeSetComplexity
  {n m : ℕ} (F : TropicalMinFamily ℝ n m) :
  (nerveChangePoints F).card ≤ (activeSetUniverse F).card

theorem number_of_H0_bars_le_activeSetComplexity
  {n m : ℕ} (F : TropicalMinFamily ℝ n m) :
  H0BarCount F ≤ (activeSetUniverse F).card
```

If the exact inequality with `|𝒜_F|` is too strong, prove a mathematically honest upper bound such as
\[
\#\text{events} \le 2^{|𝒜_F|},
\]
then sharpen later. A proved weaker theorem is better than an unproved perfect one.

---

## Why This Is a Breakthrough

This would open a new field direction: **certified tropical topological inference**.

It would show that persistent homology of tropical landscapes is not a black-box numerical artifact but is governed by a finite active-set combinatorics. That creates a rigorous bridge between:

- **tropical geometry**: active sets, tropical convexity, valuations;
- **applied topology**: nerves, barcodes, persistent invariants;
- **optimization/loss landscapes**: piecewise-linear minima and nonconvex filtrations;
- **random geometry**: asymptotics as the number of affine forms grows.

The real conceptual leap is this: persistence becomes a theorem about **when combinatorial tropical degeneracies occur**, not just a computation on sampled point clouds.

---

## Cross-Domain Connections You Must Exploit

Include at least one theorem or explicit formal discussion tying the subject to another mathematical domain.

### Bridge A: Nerve theorem ↔ Čech/Vietoris–Rips philosophy
Show that the active-set nerve is a tropical analogue of a Čech complex: patches replace metric balls. This is a foundational bridge from tropical geometry to topological data analysis.

### Bridge B: Convex geometry ↔ homological algebra
The theorem `tropMax_sublevel_convex` implies contractibility, hence vanishing higher homology. This is a clean passage from convexity to homological triviality.

### Bridge C: Random tropical landscapes ↔ statistical mechanics
The asymptotic conjecture on normalized Betti vectors should be framed as a tropical analogue of a law of large numbers / self-averaging phenomenon. Valuation profile plays the role of a disorder law.

### Bridge D: Tropical geometry ↔ sheaf/cosheaf viewpoint
The active-set assignment over thresholds naturally suggests a constructible cosheaf of connected components or homology. Even if not fully formalized, state this as a follow-up architecture in `FUTURE_DIRECTIONS.md`.

---

## Proof Strategy Architecture

You must present and pursue at least 2–3 proof paths. Do not rely on one brittle route.

### Strategy A: Direct finite nerve control via patch intersections
Most promising.

1. Define tropical patches indexed by active sets.
2. Prove patch monotonicity in `c` using `sublevel_mono`.
3. Show each patch and each finite nonempty intersection is convex/contractible by reducing to linear inequality systems on active affine forms.
4. Build the active-set nerve filtration and prove that if the nerve is unchanged on `[c₁,c₂]`, then the topological invariant of interest is unchanged.
5. Derive finite event/bar-count bounds from finiteness of active-set patterns.

**Why this is strongest:** it converts geometry into finite combinatorics and only needs contractibility of intersections, not deep smooth topology.

### Strategy B: Euler characteristic / H₀ first, then upgrade
Safer fallback if full homotopy equivalence is too expensive.

1. Define the active-set nerve.
2. Prove connected-component equivalence between sublevel set and nerve under weaker hypotheses.
3. Prove Euler characteristic equality using inclusion–exclusion over contractible intersections.
4. Deduce barcode-event bounds in degree `0`, then extend to higher degrees where possible.

**Why useful:** gives a nontrivial, publishable theorem even if full Nerve theorem formalization is blocked.

### Strategy C: Discrete critical-value analysis
Best for event-localization theorems.

1. Prove there are only finitely many active-set patterns from a finite family of affine forms.
2. Associate to each pattern a semialgebraic/polyhedral feasibility condition in `c`.
3. Show the set of thresholds where the active-set nerve changes is finite and determined by equality/feasibility transitions among affine forms.
4. Deduce that persistence events can only occur at these thresholds.

**Why useful:** highly compatible with algorithm extraction and demo computation.

Recommended order: **C first for finiteness**, then **A for topology control**, with **B as fallback invariant package**.

---

## Lean 4 Formalization Guidance

Use finite combinatorial models aggressively. Do not begin by trying to formalize all of persistent homology in full generality unless the required machinery already exists. Instead:

- define a finite simplicial filtration from active sets;
- define computable invariants (`component count`, `Euler characteristic`, maybe `BettiLikeInvariant`);
- prove event-localization and complexity bounds for those invariants;
- if possible, connect them to actual homology via existing simplicial-complex machinery.

### Suggested Lean-friendly definitions
```lean
def IsActiveSetAt (F : TropicalMinFamily ℝ n m) (x : Fin n → ℝ) (A : Finset (Fin m)) : Prop := ...
def TropicalPatch (F : TropicalMinFamily ℝ n m) (c : ℝ) (A : Finset (Fin m)) :
    Set (Fin n → ℝ) := ...
def ActiveSetNerve (F : TropicalMinFamily ℝ n m) (c : ℝ) : SimplicialComplex (Finset (Fin m)) := ...
def ActiveSetNerveConstantOn (F : TropicalMinFamily ℝ n m) (a b : ℝ) : Prop := ...
def BarcodeCritical (F : TropicalMinFamily ℝ n m) (c : ℝ) : Prop := ...
def H0BarCount (F : TropicalMinFamily ℝ n m) : ℕ := ...
```

### Deep proof tactics expected
At least 3 theorems must require real reasoning using some combination of:
- `induction` on finite sets/simplices,
- `rcases` to unpack active-set witnesses,
- `by_contra` to force critical-value contradictions,
- `field_simp` if affine-threshold formulas involve rational expressions,
- multi-step `calc` chains for monotonicity/inclusion arguments.

No trivial enumeration theorems. No cosmetic lemmas padded with `simp`.

---

## Concrete Theorem Package to Aim For in the File

At minimum, produce a Lean file containing the following substantial results or strong variants:

1. `tropMax_sublevel_contractible`  
   Uses `tropMax_sublevel_convex` + convexity-to-contractibility reasoning.

2. `activeSetNerve_mono`  
   If `c₁ ≤ c₂`, then `ActiveSetNerve F c₁ ≤ ActiveSetNerve F c₂`, building on `activeSetComplex_mono` and `sublevel_mono`.

3. `no_H0_event_of_nerve_constant`  
   If the active-set nerve is unchanged on `[c₁,c₂]`, then the number of connected components of the modeled sublevel set is unchanged.

4. `critical_values_finite`  
   The set of nerve-change thresholds is finite for finite affine families.

5. `H0BarCount_le_activeSetComplexity`  
   Number of degree-0 bars bounded by active-set combinatorial complexity.

A stronger theorem replacing H₀ by Euler characteristic or full homology is ideal.

---

## Computational / Algorithmic Deliverable

You must provide a **verified algorithm or computational method**, not just theorem statements.

### Required algorithm
Implement an algorithm that, given a finite tropical min-affine family in `ℝ²` or `ℝ^n` with rational coefficients:

1. enumerates candidate active sets;
2. constructs the active-set nerve filtration across critical thresholds;
3. computes a certified surrogate barcode:
   - at minimum H₀ bars,
   - ideally Euler characteristic changes,
   - optionally full simplicial homology through an external Python backend.

Prove at least one correctness theorem of the form:
```lean
theorem algorithm_outputs_only_critical_values
  (F : TropicalMinFamily ℚ n m) :
  ∀ c ∈ criticalValuesAlgorithm F, BarcodeCritical F c
```
or
```lean
theorem algorithm_H0_bar_bound_correct
  (F : TropicalMinFamily ℚ n m) :
  H0BarCount F ≤ (criticalValuesAlgorithm F).length
```

---

## Demo Requirements

Provide `demo.py` that:

1. samples random tropical affine families with 5, 10, 20, 50 forms in `ℝ²`;
2. computes sublevel samples and active-set nerve filtration;
3. compares:
   - observed number of H₀ bars / persistence intervals,
   - size of active-set complex,
   - number of predicted critical values;
4. plots normalized Betti-like curves across valuation-equivalent families.

Use `gudhi` or `ripser` if convenient, but the demo must explicitly compare empirical barcodes to the theoremically predicted combinatorial bounds.

---

## Falsifiable Conjecture You Must State

Include at least one explicit conjecture with a clear disproof protocol.

### Conjecture A: Active-set bar bound
For every finite tropical min-affine family `F`,
\[
\#\mathrm{Bars}_{H_0}(F) \le |\mathcal A_F|.
\]
**Test:** generate random families, compute H₀ persistence, enumerate active sets, search for a family with more H₀ bars than active sets.

### Conjecture B: Valuation-profile universality
For random tropical affine families with i.i.d. valuation profiles from a fixed law, the normalized Betti-like vector of the active-set nerve filtration converges in probability to a deterministic limit depending only on that valuation law.
**Test:** compare families with different coefficients but identical valuation distributions; reject if normalized curves fail to stabilize as `m` grows.

### Conjecture C: Nerve sufficiency
For generic tropical min-affine families in `ℝ²`, every persistence endpoint occurs at a threshold where some active-set intersection changes feasibility.
**Test:** compute exact/approximate persistence endpoints and compare with combinatorially predicted thresholds; disprove with a persistent endpoint not explained by active-set changes.

These belong in `FUTURE_DIRECTIONS.md` as testable scientific hypotheses.

---

## Application Keywords

Use these explicitly in the paper and comments:

- tropical geometry
- persistent homology
- active-set complex
- nerve theorem
- Čech complex
- barcode complexity
- tropical optimization
- piecewise-linear landscapes
- topological data analysis
- random polyhedral geometry
- valuation universality
- self-averaging
- certified topology
- combinatorial persistence
- homological stability

---

## Deliverables You Must Produce

You must produce **all** of the following:

1. **Lean file(s)** with the new definitions and at least 3 substantial theorems using deep proof tactics.
2. **`FUTURE_DIRECTIONS.md`** containing 3–5 falsifiable scientific hypotheses with explicit computational tests.
3. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - theorem statements,
   - proof ideas,
   - significance,
   - computational experiments,
   - limitations,
   - next-step conjectures.
4. **`ARTICLE.md`** in Scientific American style for a broad audience.
5. **A verified algorithm/computational method** with at least one correctness theorem in Lean.
6. **`demo.py`** demonstrating the theorem and conjecture tests interactively.

---

## Final Charge

Do not settle for “sublevel sets are monotone.” That is infrastructure. The real theorem is that **tropical persistence is controlled by a finite active-set combinatorics**. If you can certify even the H₀/Euler-characteristic version now, with a clear path to full homological persistence later, that is already field-opening: it reframes tropical landscapes as objects with **computable topological phase transitions** governed by valuations and active-set geometry.

Build the combinatorial filtration. Prove that topology only changes when the active-set world changes. Extract an algorithm. Then use experiments to pressure-test the universality conjecture.

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
