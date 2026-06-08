## Assignment: Direction 1: Brauer–Manin Obstructions for Integral Points on Cubic Surfaces

**Mode:** `discover` with a sharp `formalize` subgoal

Prove genuinely new, nontrivial theorems around the cubic surface
\[
X_k : x^3+y^3+z^3 = k
\]
viewed as an integral affine cubic surface over \(\mathbb Z\), and use the existing local admissibility infrastructure as the first layer of a much richer obstruction theory. The ambition is not to formalize full étale cohomology immediately; it is to create the first rigorous Lean bridge between explicit congruence obstructions, local-global principles, and a proto-Brauer–Manin formalism for integral points.

The revolutionary target is to show that the familiar mod \(9\) obstruction is not an isolated congruence accident, but the first visible footprint of a deeper adelic/cohomological mechanism. If this program succeeds, the three-cubes problem becomes a laboratory for arithmetic geometry in the strongest possible sense: explicit search, local solubility, adelic compatibility, and obstruction theory all living in one formal ecosystem.

---

## Core Theorem Targets

You must prove at least **3 substantial theorems** with multi-step arguments. At least one should introduce a genuinely new definition, and at least one must connect arithmetic geometry to another domain.

### New definitions to introduce

Create at least one new structure not already in the catalog. Suggested definitions:

1. **Integral adelic local admissibility data**
   ```lean
   structure IntegralLocalData (k : ℤ) where
     sol_mod : ℕ → Prop
     compat : ∀ {m n : ℕ}, m ∣ n → sol_mod n → sol_mod m
   ```

2. **Proto-Brauer-compatible admissibility**
   A deliberately finite/computable shadow of the Brauer–Manin condition:
   ```lean
   def ProtoBrauerCompatible (k : ℤ) : Prop :=
     EverywhereLocallyAdmissible k ∧
       ∀ m : ℕ, m ≠ 0 → ∃ x y z : ZMod m, x^3 + y^3 + z^3 = (k : ZMod m)
   ```
   or, more subtly, define a filtered family using only moduli built from bad primes.

3. **Cubic residue obstruction profile**
   ```lean
   def CubicObstructionProfile (k : ℤ) : Set ℕ :=
     {m | ¬ ∃ x y z : ZMod m, x^3 + y^3 + z^3 = (k : ZMod m)}
   ```

These are not the full Brauer group, but they are mathematically meaningful finite shadows of the adelic obstruction, and they give Aristotle a platform for future cohomological upgrades.

---

## Precise theorem statements

You should aim to prove the following kind of results, with exact Lean statements as close as possible to these signatures.

### Theorem 1: Global representation implies proto-adelic compatibility
This should strengthen the existing local theorem.

```lean
theorem sumThreeCubesRep_implies_protoBrauerCompatible
    (k : ℤ) :
    (∃ x y z : ℤ, x^3 + y^3 + z^3 = k) →
    ProtoBrauerCompatible k
```

**Mathematical content:** Any actual integral point gives compatible points modulo every modulus, hence survives every finite congruence test. This is not deep by itself, but it is the gateway theorem that embeds explicit integer solutions into an adelic-style object.

**Why it matters:** It upgrades “representable implies locally admissible” into “representable implies compatible across all finite quotients,” which is the correct conceptual precursor to Brauer–Manin.

---

### Theorem 2: The mod 9 obstruction propagates to the proto-Brauer level
This should formalize the claim that the classical obstruction is detected by your new obstruction profile.

```lean
theorem eq_four_or_five_mod_nine_implies_not_protoBrauerCompatible
    {k : ℤ}
    (hk : k % 9 = 4 ∨ k % 9 = 5) :
    ¬ ProtoBrauerCompatible k
```

Or equivalently through the obstruction profile:

```lean
theorem nine_mem_CubicObstructionProfile_of_eq_four_or_five_mod_nine
    {k : ℤ}
    (hk : k % 9 = 4 ∨ k % 9 = 5) :
    9 ∈ CubicObstructionProfile k
```

**Mathematical content:** The mod \(9\) obstruction is recast as a finite-level obstruction in an adelic filtration.

**Why it matters:** This is the first formal step toward the sentence “modular obstructions are shadows of Brauer classes.” Even if you do not yet formalize Brauer groups, the architecture should point unmistakably in that direction.

---

### Theorem 3: Compatibility under divisibility of moduli
This is a structural theorem for your new obstruction formalism.

```lean
theorem cubic_solution_mod_downward_closed
    {k : ℤ} {m n : ℕ}
    (hdiv : m ∣ n)
    (hn : n ≠ 0)
    (hsol : ∃ x y z : ZMod n, x^3 + y^3 + z^3 = (k : ZMod n)) :
    ∃ x y z : ZMod m, x^3 + y^3 + z^3 = (k : ZMod m)
```

**Mathematical content:** Solvability descends along quotient maps \( \mathbb Z/n\mathbb Z \to \mathbb Z/m\mathbb Z \).

**Why it matters:** This is the algebraic backbone of any finite-adelic approximation. Without this theorem, your obstruction profile is just a list of disconnected congruence failures. With it, you have a genuine filtered object.

---

### Theorem 4: Cross-domain theorem — obstruction profiles as computational complexity filters
This is where you must be bold. Connect arithmetic geometry to algorithms/computation.

Define a search space predicate such as:
```lean
def BoundedThreeCubeSearch (k : ℤ) (B : ℕ) : Prop :=
  ∃ x y z : ℤ, |x| ≤ B ∧ |y| ≤ B ∧ |z| ≤ B ∧ x^3 + y^3 + z^3 = k
```

Then prove a theorem of the form:
```lean
theorem obstructionProfile_prunes_search
    {k : ℤ} (hm : ∃ m ∈ CubicObstructionProfile k, True) :
    ∀ B : ℕ, ¬ BoundedThreeCubeSearch k B
```

or the stronger contraposition-friendly form:
```lean
theorem boundedSearch_implies_no_finite_obstruction
    {k : ℤ} {B : ℕ}
    (hB : BoundedThreeCubeSearch k B) :
    CubicObstructionProfile k = ∅
```
You may need to weaken the exact statement for formal tractability, e.g. proving that any bounded solution kills every obstruction modulus.

**Why it matters:** This is the first explicit bridge between arithmetic geometry and verified search complexity: obstruction theory becomes a mathematically certified pruning oracle.

---

### Theorem 5: Prime-power reduction principle at the bad prime 3
A more ambitious theorem, but highly desirable:

```lean
theorem mod_nine_obstruction_controls_all_three_power_levels
    {k : ℤ}
    (hk : k % 9 = 4 ∨ k % 9 = 5) :
    ∀ e : ℕ, 2 ≤ e →
      ¬ ∃ x y z : ZMod (3^e), x^3 + y^3 + z^3 = (k : ZMod (3^e))
```

**Mathematical content:** Failure at mod \(9\) persists through all higher \(3\)-power quotients.

**Why it matters:** This is a true local theorem at the prime \(3\), not just a single congruence computation. It begins to look like a \(3\)-adic obstruction, which is exactly the arithmetic-geometric perspective you want.

---

## Lean 4 formalization targets

Use signatures close to the following:

```lean
def CubicObstructionProfile (k : ℤ) : Set ℕ :=
  {m | ¬ ∃ x y z : ZMod m, x^3 + y^3 + z^3 = (k : ZMod m)}

def ProtoBrauerCompatible (k : ℤ) : Prop :=
  ∀ m : ℕ, m ≠ 0 → ∃ x y z : ZMod m, x^3 + y^3 + z^3 = (k : ZMod m)

theorem sumThreeCubesRep_implies_protoBrauerCompatible
    (k : ℤ) :
    (∃ x y z : ℤ, x^3 + y^3 + z^3 = k) →
    ProtoBrauerCompatible k

theorem cubic_solution_mod_downward_closed
    {k : ℤ} {m n : ℕ}
    (hdiv : m ∣ n)
    (hsol : ∃ x y z : ZMod n, x^3 + y^3 + z^3 = (k : ZMod n)) :
    ∃ x y z : ZMod m, x^3 + y^3 + z^3 = (k : ZMod m)

theorem nine_mem_CubicObstructionProfile_of_eq_four_or_five_mod_nine
    {k : ℤ}
    (hk : k % 9 = 4 ∨ k % 9 = 5) :
    9 ∈ CubicObstructionProfile k

theorem eq_four_or_five_mod_nine_implies_not_protoBrauerCompatible
    {k : ℤ}
    (hk : k % 9 = 4 ∨ k % 9 = 5) :
    ¬ ProtoBrauerCompatible k
```

If Mathlib’s existing `ZMod` coercions force small adjustments, adapt carefully, but keep the mathematical meaning exact.

---

## Proof strategy architecture

You must not just state theorems; you must attack them from multiple angles.

### Strategy A: Congruence-to-adelic lifting architecture
**Best first path.**
1. Start from `sumThreeCubesRep_implies_everywhereLocallyAdmissible` and strengthen it from local admissibility at selected places to explicit solvability modulo arbitrary \(m\).
2. Use quotient maps `ZMod n →+* ZMod m` when `m ∣ n` to prove downward closure.
3. Package these into `ProtoBrauerCompatible`, then import the known mod \(9\) obstruction to show failure of compatibility.

**Why promising:** It is closest to current catalog infrastructure and yields immediate theorem density with genuine conceptual upgrade.

---

### Strategy B: Prime decomposition and local factorization
1. Define solvability modulo \(m\).
2. Use Chinese remainder heuristics or factorization over coprime moduli to relate solvability modulo \(m\) to solvability modulo prime powers.
3. Isolate the prime \(3\) as the bad prime, proving that the mod \(9\) obstruction is the essential local obstruction in the currently visible range.

**Why promising:** This mirrors the actual arithmetic geometry: local conditions factor by places. Even a partial theorem here is a major conceptual gain.

**Risk:** CRT lemmas in Lean may require more setup than expected; use this after Strategy A secures core results.

---

### Strategy C: Computational obstruction profile as a verified experimental object
1. Define `CubicObstructionProfile` and prove monotonicity/downward-closure facts.
2. Implement a verified procedure that checks whether a given modulus lies in the profile by exhaustive residue testing.
3. Compare the computed profile for \(k = 33, 42, 114\) and document that these pass mod \(9\), unlike forbidden classes \(4,5 \bmod 9\).

**Why promising:** This produces a theorem-plus-algorithm package, exactly what a new field needs: conceptual framework plus falsifiable data.

**Most promising overall:** **A first, C in parallel, B if time permits.** Strategy A establishes the new mathematical language. Strategy C makes it scientifically operational. Strategy B pushes toward the genuine Brauer–Manin worldview.

---

## Cross-domain connections you must include

At least one theorem and one discussion section must explicitly connect this project to another domain.

### 1. Arithmetic geometry + computational complexity
The obstruction profile is a certified search-pruning invariant. This reframes local-global obstructions as complexity-theoretic filters for Diophantine search.

### 2. Arithmetic geometry + cohomology
Even if full Brauer groups are not formalized, explain rigorously that `ProtoBrauerCompatible` is a finite-level approximation to adelic compatibility, and that the mod \(9\) obstruction should be viewed as a shadow of a \(3\)-adic Brauer evaluation.

### 3. Arithmetic geometry + dynamical / probabilistic heuristics
Discuss how obstruction profiles could feed probabilistic models for representability of \(k\), analogous to local density heuristics in the Hardy–Littlewood circle method.

### 4. Arithmetic geometry + programming languages / certified algorithms
A verified obstruction engine would be the first certified front-end for large-scale three-cubes search.

---

## Conjecture with testable prediction

State a falsifiable conjecture in the file, not just in prose.

```lean
/--
Conjecture: finite congruence compatibility is the only obstruction visible at the
current formal level for sums of three cubes.
-/
def ProtoBrauerCompletenessConjecture : Prop :=
  ∀ k : ℤ, ProtoBrauerCompatible k → ∃ x y z : ℤ, x^3 + y^3 + z^3 = k
```

Then add a computationally testable finite version:

```lean
def PassesSearchAndCongruenceTests (k : ℤ) (B M : ℕ) : Prop :=
  (∀ m ≤ M, m ≠ 0 → ∃ x y z : ZMod m, x^3 + y^3 + z^3 = (k : ZMod m)) ∧
  ¬ ∃ x y z : ℤ, |x| ≤ B ∧ |y| ≤ B ∧ |z| ≤ B ∧ x^3 + y^3 + z^3 = k
```

**Testable prediction:** If the conjecture is false, there should exist \(k\) and increasing parameters \(B,M\) such that `PassesSearchAndCongruenceTests k B M` persists for large ranges. Your `demo.py` should search for such candidates.

Suggested explicit test cases:
- Positive controls: \(k = 33, 42, 114\)
- Obstructed controls: \(k \equiv 4,5 \pmod 9\)
- Borderline exploratory cases: small \(k\) not yet represented within modest bounds but passing congruence tests

A counterexample would be mathematically seismic.

---

## Catalog building blocks

You must explicitly build on:

- `sumThreeCubesRep_implies_everywhereLocallyAdmissible`
  from `Algebra/SumThreeCubes/LocalGlobal.lean`

- `not_threeCubeLocalAdmissible_mod9_of_eq_four_or_five`
  from `Algebra/SumThreeCubes/LocalObstruction.lean`

Explain in comments and paper text exactly how:
- the first theorem is the seed of adelic compatibility,
- the second theorem is reinterpreted as a finite obstruction class at the bad prime \(3\).

If additional `ZMod`, quotient-ring, CRT, or divisibility lemmas from Mathlib are needed, isolate them into reusable helper lemmas.

---

## Required theorem style constraints

Your file must contain at least 3 theorems whose proofs genuinely use deep tactics or proof patterns such as:
- `induction`
- `rcases`
- `by_contra`
- `field_simp`
- multi-step `calc`
- explicit transport through quotient maps
- contradiction via modular descent

Do not pad the file with trivial lemmas. The center of gravity must be mathematically meaningful statements.

---

## Verified algorithm / computational method

You must produce a verified algorithm, not merely theorem statements.

### Required algorithm
Implement a finite obstruction checker:
```lean
def hasCubicSolutionMod (k : ℤ) (m : ℕ) : Bool := ...
```
together with a correctness theorem of the form:
```lean
theorem hasCubicSolutionMod_correct
    {k : ℤ} {m : ℕ} :
    hasCubicSolutionMod k m = true ↔
      ∃ x y z : ZMod m, x^3 + y^3 + z^3 = (k : ZMod m)
```
If full equivalence is too heavy for arbitrary `m`, prove a certified soundness theorem and a completeness theorem for bounded enumeration over representatives.

Then define:
```lean
def obstructionProfileUpTo (k : ℤ) (M : ℕ) : List ℕ := ...
```
and prove that every listed modulus is a genuine obstruction.

This is essential: theorem + executable arithmetic experiment.

---

## demo.py requirements

Your `demo.py` must:
1. Compute obstruction profiles up to a user-given bound \(M\).
2. Compare profiles for \(k = 33, 42, 114\) and for obstructed classes \(k \equiv 4,5 \pmod 9\).
3. Display whether each tested \(k\) passes all congruence checks up to \(M\).
4. Optionally perform bounded integer search for actual representations and compare “search evidence” against “obstruction evidence.”

The demo should make the scientific point vivid: some \(k\) fail instantly for structural reasons; others survive all finite tests and become genuine Diophantine mysteries.

---

## Revolutionary significance

If you succeed, you will have created the first formal research program in which:
- explicit Diophantine search,
- local congruence obstructions,
- finite adelic compatibility,
- and the conceptual shadow of Brauer–Manin obstruction

are unified around the three-cubes problem.

That opens an entirely new field of formally verified arithmetic experimentation. It would turn a famous computational number theory problem into a prototype for integral points on higher-dimensional varieties. The next steps would include norm-form equations, Markoff-type surfaces, and eventually genuine cohomological obstructions.

This is not an incremental extension. It is the beginning of a formal arithmetic geometry of explicit obstruction profiles.

---

## Application keywords

**Brauer–Manin obstruction, integral points, cubic surfaces, sums of three cubes, local-global principle, adelic compatibility, modular obstructions, \(3\)-adic analysis, obstruction profiles, certified Diophantine search, arithmetic geometry, computational number theory, Chinese remainder theorem, cohomological heuristics, search pruning, verified algorithms**

---

## Mandatory deliverables

You must produce **all** of the following:

1. **`FUTURE_DIRECTIONS.md`**
   - 3–5 original research directions
   - each direction must include the exact sentences:
     - **“The key insight is...”**
     - **“Why now?”**
   - at least one direction must bridge to a different domain

2. **`RESEARCH_PAPER.md`**
   - standalone scientific paper
   - readable without code access
   - explain theorem statements, proof ideas, computational method, significance, and next questions

3. **`ARTICLE.md`**
   - Scientific American style
   - broad audience
   - focus on the mathematics and why it matters
   - **do not focus on formal verification machinery**

4. **A verified algorithm or computational method**
   - specifically the obstruction checker and profile computation above

5. **`demo.py`**
   - interactive demonstration of the results and conjectural landscape

Soli Deo Gloria.

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
    "visualizations": [ { "name": "...", "code": "# matplotlib or plotly script, self-contained", "description": "What this visualizes" } ],
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
