Soli Deo Gloria

## Assignment: Direction 5 — Higher-Degree Diagonal Surfaces and a Local-to-Global Obstruction Calculus

**Mode:** prove

Build a new formal theory of higher-degree diagonal equations that does not merely imitate the three-cubes file structure, but extracts the underlying obstruction mechanism and turns it into a reusable arithmetic machine.

The target is to generalize the local obstruction framework from
`Algebra/SumThreeCubes/Defs.lean` and
`Algebra/SumThreeCubes/LocalObstruction.lean`
to equations of the form
\[
x_1^n + x_2^n + \cdots + x_s^n = k
\]
for arbitrary degree \(n \ge 2\) and variable count \(s \ge 1\), with a particular emphasis on the four biquadrates case
\[
x^4+y^4+z^4+w^4 = k.
\]

This is not an incremental extension. The breakthrough is to formalize a **uniform obstruction calculus for diagonal hypersurfaces**: a theorem-proving framework that isolates which congruence classes can possibly fail, proves that global representability implies local admissibility in full generality, and creates a computational pipeline for discovering the “true” bad moduli for higher Waring-type problems. If successful, this opens a formal interface between additive number theory, local algebra, and algorithmic arithmetic geometry.

---

## Core Vision

The three-cubes obstruction is not an isolated curiosity. It is the first visible shadow of a much broader principle:

> For diagonal degree-\(n\) hypersurfaces with sufficiently many variables, global failures should be explained first and foremost by a finite, structured set of local residue obstructions controlled by \(n\)-th power arithmetic at prime powers.

Your job is to formalize the first robust layer of this principle.

---

## Precise Theorem Targets

You should introduce a generalized notion of local admissibility for degree \(n\) and \(s\) variables, then prove at least **3 substantial theorems**. At minimum, aim for the following theorem statements.

### New definitions to introduce

Define a generalized residue-sum set and admissibility predicate.

Suggested Lean 4 signatures:

```lean
def nthPowerResiduesMod (n m : ℕ) : Finset (ZMod m) :=
  (Finset.range m).image (fun a => ((a : ZMod m) ^ n))

def diagonalResidueSums (n s m : ℕ) : Finset (ZMod m) :=
  ((Finset.pi (Finset.replicate s (Finset.range m))).image fun v =>
    ∑ i in Finset.range s, (((v.1.get? i).getD 0 : ℕ) : ZMod m) ^ n)

def DiagonalLocalAdmissible (n s k m : ℕ) : Prop :=
  (k : ZMod m) ∈ diagonalResidueSums n s m

def EverywhereLocallyAdmissible (n s k : ℕ) : Prop :=
  ∀ m : ℕ, m > 0 → DiagonalLocalAdmissible n s k m
```

If the exact implementation of `diagonalResidueSums` via tuples is awkward, replace it by an existential predicate over `Fin s → ZMod m`. The concept matters more than the first encoding choice.

Also define a genuinely new concept not present in the catalog, for example:

```lean
def CriticalObstructionModulus (n s m : ℕ) : Prop :=
  m > 0 ∧
  ¬ (∀ k : ℕ, DiagonalLocalAdmissible n s k m → EverywhereLocallyAdmissible n s k)
```

or better, a more arithmetic notion:

```lean
def UniversallySurjectiveMod (n s m : ℕ) : Prop :=
  ∀ a : ZMod m, ∃ x : Fin s → ZMod m, a = ∑ i, x i ^ n
```

This “universal surjectivity” concept is mathematically meaningful: it detects when the diagonal form is locally complete modulo \(m\).

---

## Theorem 1 — Global representation implies local admissibility

This is the non-negotiable backbone theorem.

### Statement
For all \(n,s,k,m \in \mathbb{N}\) with \(m>0\), if \(k\) is globally representable as a sum of \(s\) \(n\)-th powers in \(\mathbb{Z}\), then \(k\) is locally admissible modulo \(m\).

### Mathematical form
\[
\forall n,s,k,m,\ m>0 \to
\left(\exists x_1,\dots,x_s\in \mathbb{Z},\ \sum_{i=1}^s x_i^n = k\right)
\to \mathrm{DiagonalLocalAdmissible}(n,s,k,m).
\]

### Suggested Lean 4 signature
```lean
theorem global_represents_implies_local_admissible
    (n s k m : ℕ) (hm : 0 < m)
    (hrep : ∃ x : Fin s → ℤ, (∑ i, x i ^ n) = k) :
    DiagonalLocalAdmissible n s k m := by
```

You may need a version with `k : ℤ` and then reduce modulo `m`. That is acceptable and probably cleaner.

### Why this is a breakthrough
This theorem upgrades the catalog’s three-cubes-specific logic into a **degree-uniform local necessity theorem** for diagonal forms. It becomes the foundational interface on which all future local-global experiments rest.

### Proof strategy options

**Strategy A: direct reduction mod \(m\) via `ZMod` (most promising).**
1. Assume a global witness `x : Fin s → ℤ`.
2. Map each `x i` into `ZMod m`.
3. Show via a `calc` chain that the image of \(\sum_i x_i^n\) equals \((k : ZMod m)\).
4. Package the reduced tuple as a witness for `DiagonalLocalAdmissible`.

Why best: this mirrors the exact arithmetic meaning and should integrate smoothly with `ZMod`, finite sums, and coercion lemmas.

**Strategy B: factor through a generalized “representation set” definition.**
1. Define `RepresentableByDiagonal (n s : ℕ) (k : ℤ) : Prop`.
2. Prove a general lemma that any polynomial representation over `ℤ` descends modulo `m`.
3. Instantiate for the monomial sum \(\sum x_i^n\).

Why useful: this abstracts future work to other forms, not just diagonal ones.

**Strategy C: prove first over `ℕ`, then lift to `ℤ`.**
1. Formalize nonnegative representations.
2. Transfer to integer representations by coercion.
3. Descend modulo `m`.

Less elegant, but can be technically simpler if exponentiation lemmas over `ℤ` become annoying.

---

## Theorem 2 — Monotonicity of local admissibility along divisibility

This theorem captures the arithmetic geometry of congruence descent.

### Statement
If \(m \mid M\), then admissibility modulo \(M\) implies admissibility modulo \(m\).

### Mathematical form
\[
m \mid M \;\Longrightarrow\;
\mathrm{DiagonalLocalAdmissible}(n,s,k,M)
\to
\mathrm{DiagonalLocalAdmissible}(n,s,k,m).
\]

### Suggested Lean 4 signature
```lean
theorem local_admissible_of_dvd
    (n s k m M : ℕ)
    (hm : 0 < m) (hM : 0 < M)
    (hdiv : m ∣ M) :
    DiagonalLocalAdmissible n s k M →
    DiagonalLocalAdmissible n s k m := by
```

### Why this matters
This theorem says obstruction information flows downward through quotient maps. It is the formal skeleton behind the idea that only **critical prime powers** matter. Once proven, it justifies computational searches over prime powers rather than arbitrary moduli.

### Proof strategy options

**Strategy A: use the canonical ring hom `ZMod M →+* ZMod m` induced by divisibility.**
1. Extract a witness tuple modulo `M`.
2. Push each coordinate through the quotient map.
3. Use preservation of addition and powers to obtain a witness modulo `m`.

Most promising, because it directly encodes reduction of congruences.

**Strategy B: rephrase admissibility as an existential congruence over integers.**
1. Unfold `DiagonalLocalAdmissible` into a congruence statement.
2. Use `m ∣ M` and divisibility transitivity.
3. Repackage the same integer witnesses.

This may avoid some `ZMod` map bureaucracy.

**Strategy C: prove a general image-monotonicity lemma for polynomial maps modulo divisibility.**
1. Define a general polynomial evaluation image set.
2. Show it descends under quotient maps.
3. instantiate with diagonal monomials.

This is the most reusable route if you want a future theory of arbitrary forms.

---

## Theorem 3 — Local completeness from universal residue generation

This theorem creates the bridge from pure residue arithmetic to additive number theory.

### Statement
If every residue class modulo \(m\) is a sum of \(s\) \(n\)-th powers, then every integer is locally admissible modulo \(m\).

### Mathematical form
\[
\mathrm{UniversallySurjectiveMod}(n,s,m)
\to
\forall k,\ \mathrm{DiagonalLocalAdmissible}(n,s,k,m).
\]

### Suggested Lean 4 signature
```lean
theorem universally_surjective_implies_all_locally_admissible
    (n s m : ℕ) (hm : 0 < m)
    (hsurj : UniversallySurjectiveMod n s m) :
    ∀ k : ℕ, DiagonalLocalAdmissible n s k m := by
```

### Why this matters
This theorem converts a finite algebraic property of the residue map into a complete local obstruction classification modulo \(m\). It is the exact conceptual step needed to turn brute-force residue computations into mathematically meaningful local-global evidence.

### Proof strategy options

**Strategy A: direct use of the surjectivity witness.**
1. Fix `k`.
2. Apply `hsurj` to `(k : ZMod m)`.
3. Extract witnesses and unfold admissibility.

**Strategy B: identify `diagonalResidueSums n s m = Finset.univ`.**
1. Prove set equality from surjectivity.
2. Conclude membership for arbitrary `k`.

Good if you want stronger computational corollaries.

---

## Theorem 4 — Cross-domain theorem: symmetry under multiplication by \(n\)-th powers of units

You are required to include at least one theorem bridging to another domain. This is the right one: it connects additive representation sets to the multiplicative structure of the unit group of `ZMod m`, i.e. algebraic number theory / finite group theory.

### Statement
If \(u\) is an \(n\)-th power unit modulo \(m\), then multiplication by \(u\) preserves the set of sums of \(s\) \(n\)-th powers.

More precisely: if \(u = a^n\) with `IsUnit a`, and
\[
r = x_1^n + \cdots + x_s^n,
\]
then
\[
u r = (a x_1)^n + \cdots + (a x_s)^n.
\]

### Suggested Lean 4 signature
```lean
theorem smul_mem_diagonalResidueSums_of_unit_nth_power
    (n s m : ℕ) (hm : 0 < m)
    (u a : ZMod m)
    (ha : IsUnit a)
    (hu : u = a ^ n) :
    ∀ r : ZMod m, r ∈ diagonalResidueSums n s m →
      u * r ∈ diagonalResidueSums n s m := by
```

### Why this is important
This theorem reveals that local admissible sets are not arbitrary finite sets: they carry symmetry from the multiplicative arithmetic of the residue ring. This is the first step toward a **representation-theoretic view of local obstructions**, where additive diagonal images are organized into multiplicative orbits.

### Cross-domain connection
- additive number theory: sums of powers
- algebraic number theory: \(n\)-th power residue classes
- finite group theory: action of unit groups on representation sets
- arithmetic geometry: symmetries of diagonal hypersurface fibers modulo \(m\)

### Proof strategy options

**Strategy A: explicit witness transport (best).**
1. Unfold membership of `r`.
2. Take witnesses `x : Fin s → ZMod m`.
3. Replace them by `fun i => a * x i`.
4. Use `mul_pow` and finite sum distributivity to prove the new sum equals `u * r`.

**Strategy B: define an action on the witness space and push it to the image set.**
1. Introduce the map `x ↦ a • x`.
2. Show diagonal evaluation is equivariant under this action.
3. Deduce set invariance.

This is more conceptual and better for future generalization.

---

## Theorem 5 — Prime-power reduction principle for obstruction search

Even if a full classification is too ambitious, prove a theorem that reduces local search to prime powers.

### Statement
If local admissibility fails modulo \(m\), then it fails modulo some prime power dividing \(m\), provided you establish the needed decomposition lemmas or work under a CRT-compatible surjectivity hypothesis.

A weaker but still valuable version:
- if every prime power dividing \(m\) is universally surjective, then \(m\) is universally surjective.

### Suggested Lean 4 signature
```lean
theorem universally_surjective_of_prime_power_factors
    (n s m : ℕ) (hm : 0 < m)
    (hfac : ∀ p a : ℕ, Nat.Prime p → p ^ a ∣ m → UniversallySurjectiveMod n s (p ^ a)) :
    UniversallySurjectiveMod n s m := by
```

This may require a CRT theorem from Mathlib. If too heavy, specialize to coprime products:

```lean
theorem universally_surjective_mul_of_coprime
    (n s m₁ m₂ : ℕ)
    (hcop : Nat.Coprime m₁ m₂)
    (h₁ : UniversallySurjectiveMod n s m₁)
    (h₂ : UniversallySurjectiveMod n s m₂) :
    UniversallySurjectiveMod n s (m₁ * m₂) := by
```

### Why this matters
This is the theorem that turns your computational experiments into a finite classification program. It says the obstruction landscape is assembled from prime-power local data, exactly as predicted by arithmetic geometry and local field heuristics.

---

## Conjecture with a falsifiable computational prediction

You must state at least one explicit conjecture and pair it with a computation that could refute it.

### Conjecture A — Biquadratic local obstruction principle
For \(s=4\), the equation
\[
x_1^4+x_2^4+x_3^4+x_4^4=k
\]
has no local obstructions modulo \(m\) except those forced by prime powers \(2^a\) and primes \(p^a\) with \(p \equiv 1 \pmod 4\).

A precise testable version:
> For every modulus \(m \le 100\), if every prime divisor \(p \mid m\) satisfies either \(p=2\) or \(p \not\equiv 1 \pmod 4\), then `UniversallySurjectiveMod 4 4 m`.

This can be disproved by a single modulus \(m \le 100\) for which some residue class fails.

### Conjecture B — Stabilization in the number of variables
For each fixed \(n\), there exists \(s_0(n)\) such that for all \(s \ge s_0(n)\), every local obstruction modulo \(m\) is controlled by finitely many critical prime powers dividing \(n\phi(m)\).

This is broader and more speculative, but still computationally approachable for small \(n,s,m\).

---

## Computational Deliverable: verified algorithm

You must produce not just theorems, but a verified computational method.

### Required algorithm
Implement a function that computes the locally admissible residue classes modulo \(m\) for sums of \(s\) \(n\)-th powers.

Suggested signature:
```lean
def computeDiagonalResidueSums (n s m : ℕ) : Finset (ZMod m)
```

Then prove a correctness theorem:
```lean
theorem mem_computeDiagonalResidueSums_iff
    (n s m : ℕ) (hm : 0 < m) (k : ZMod m) :
    k ∈ computeDiagonalResidueSums n s m ↔
    ∃ x : Fin s → ZMod m, (∑ i, x i ^ n) = k := by
```

This is important: the theorem certifies the finite search procedure, so that experiments become mathematically interpretable rather than anecdotal.

---

## Demo / experiment targets

Your `demo.py` must:
1. Compute admissible residue sets for `(n,s) = (4,4)` and all `m ≤ 100`.
2. Identify moduli where surjectivity fails.
3. Factor those moduli and summarize the prime-power pattern.
4. Compare observed failures with the conjectural pattern “only powers of 2 and primes \(p \equiv 1 \pmod 4\) matter.”
5. Produce at least one visualization:
   - heatmap of admissible density by modulus,
   - or obstruction graph on divisibility lattice,
   - or residue orbit decomposition under multiplication by 4th-power units.

---

## Proof architecture: how to build on the catalog

Use the catalog’s three-cubes framework as a seed, but abstract away all cube-specific constants and ad hoc residue classes.

### Build directly on:
- `Algebra/SumThreeCubes/Defs.lean`
  - generalize `ThreeCubeLocalAdmissible` to `DiagonalLocalAdmissible`
  - generalize `EverywhereLocallyAdmissible`
- `Algebra/SumThreeCubes/LocalObstruction.lean`
  - extract the proof pattern behind “global implies local”
  - refactor any lemmas about modular descent into degree-independent statements

The key move is not to duplicate the old theory with `4` replacing `3`, but to identify the invariant backbone:
- representation modulo `m`,
- descent along quotient maps,
- finite residue image computation,
- obstruction propagation through divisibility.

---

## Recommended proof sequence

### Path 1 — Foundational and most promising
1. Define `DiagonalLocalAdmissible`, `EverywhereLocallyAdmissible`, `UniversallySurjectiveMod`.
2. Prove `global_represents_implies_local_admissible`.
3. Prove `local_admissible_of_dvd`.
4. Prove `universally_surjective_implies_all_locally_admissible`.
5. Implement `computeDiagonalResidueSums` and prove correctness.
6. Specialize to `(n,s)=(4,4)` and derive explicit corollaries from computation.

Why this path is best:
It yields a reusable arithmetic engine with immediate theorem-experiment feedback.

### Path 2 — Structural / algebraic
1. Define the diagonal evaluation map \( (ZMod\,m)^s \to ZMod\,m \).
2. Prove equivariance under multiplication by \(n\)-th power units.
3. Study image-set invariance and orbit structure.
4. Use these symmetries to compress computation and explain obstruction patterns.

Why exciting:
This is where the additive problem starts to look like arithmetic dynamics on finite rings.

### Path 3 — CRT-driven prime-power theory
1. Prove surjectivity for coprime products from surjectivity on factors.
2. Reduce obstruction search to prime powers.
3. Experimentally classify critical prime powers for low degrees.

Why revolutionary:
This turns local obstruction discovery into a modular synthesis problem and points toward a formal local-global machine for Waring-type equations.

---

## Cross-domain connections to emphasize

You must explicitly connect this work to at least one other domain in a theorem, discussion, and future directions.

### Strongest bridges
- **Algebraic number theory:** \(n\)-th power residue classes, local reciprocity heuristics, prime-power lifting.
- **Arithmetic geometry:** diagonal hypersurfaces over finite rings; local fibers and reduction maps.
- **Analytic number theory:** Waring’s problem, Hardy–Littlewood local factors, singular series heuristics.
- **Finite group theory:** action of unit groups on residue-sum sets.
- **Computational complexity:** certified finite search over local obstruction lattices.
- **Physics/stat mech angle:** local admissibility as a discrete energy shell occupancy problem for polynomial Hamiltonians.

### Application keywords
Waring problem, local-global principle, diagonal hypersurfaces, \(n\)-th power residues, prime powers, Chinese remainder theorem, additive number theory, arithmetic geometry, local densities, singular series, residue orbit symmetry, finite-ring algorithms, obstruction classification.

---

## Minimum theorem count and proof depth

Your file must contain at least **3 nontrivial theorems** with proofs using substantial tactics and structure:
- induction,
- `rcases`,
- `by_contra`,
- `field_simp` where relevant,
- multi-step `calc`,
- nontrivial algebraic rewriting.

Do not satisfy the brief with computational equalities or finite enumeration alone. The point is to prove general mechanisms.

---

## Deliverables (ALL mandatory)

1. **Lean file(s)** with the new generalized theory and at least 3 deep theorems.
2. **A verified algorithm** for computing local admissible sets, together with a correctness theorem.
3. **`demo.py`** showing the biquadratic experiments up to modulus 100 and comparing data to the conjecture.
4. **`RESEARCH_PAPER.md`** as a standalone scientific paper explaining:
   - the generalized local obstruction framework,
   - the main theorems,
   - the computational findings,
   - why this matters for higher Waring-type problems.
5. **`ARTICLE.md`** in Scientific American style, accessible and idea-focused.
   Do **not** focus on formal verification machinery; focus on the mathematics and its significance.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 research directions.
   Each direction must include the exact sentences:
   - **“The key insight is...”**
   - **“Why now?”**
   At least one direction must bridge to a different domain, such as arithmetic geometry, complexity theory, or physics.

---

## Final scientific ambition

If done correctly, this project will not merely say “the three-cubes definitions also work for fourth powers.” It will establish a new formal paradigm:

> diagonal additive problems can be studied through a reusable local obstruction calculus, with theorem-certified computation revealing the hidden architecture of higher-degree arithmetic.

That is a field-opening blueprint.

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
