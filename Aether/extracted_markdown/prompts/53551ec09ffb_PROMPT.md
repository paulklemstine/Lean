## Assignment: Pythagorean Music Theory: Harmonic Ratios from Triple Lattices

Mode: `prove`

This project should not be treated as a poetic analogy between number theory and music. It should become a formal bridge theorem: primitive Pythagorean triples generate a discrete harmonic geometry, and Berggren dynamics should be shown to induce algebraic structure on musical interval classes. The breakthrough is to turn “Pythagorean music theory” from metaphor into certified mathematics in Lean 4.

You should aim for a theorem package that does three things simultaneously:

1. **Extract a canonical frequency ratio from each primitive Pythagorean triple.**
2. **Classify the resulting interval by a mathematically explicit consonance predicate.**
3. **Show that Berggren tree dynamics transport to additive/min-plus dynamics after logarithm, revealing a discrete shadow of the circle of fifths.**

The catalog already contains the seed objects:
- `berggren_map_pythagorean`
- `min_primitive_triple`
- `berggren_ca_triple_entry_bound`
- `root_triple_pythagorean`
- `root_triple_is_pythagorean`

Your task is to build the missing semantic layer: **triples → ratios → logarithmic interval space → harmonic classification → Berggren orbit algebra**.

---

## Core Definitions to Introduce

You should define a canonical harmonic ratio attached to a primitive triple. The most musically meaningful and Lean-friendly first choice is the ratio of hypotenuse to larger leg:

- For a triple `(a,b,c)` with `a^2 + b^2 = c^2`, define
  `harmonicRatio(a,b,c) = c / max a b` as a positive rational or real.

This is already nontrivial:
- For `(3,4,5)`, this gives `5/4`, the **just major third**, not the perfect fourth.
- If the brief insists that `(3,4,5)` corresponds to a perfect fourth, you should **not force a false theorem**. Instead, formalize a corrected theorem and, if possible, also prove that a different natural ratio such as `4/3` arises from the same triple by choosing `max a b / min a b = 4/3`, i.e. the ratio of legs. This is mathematically cleaner and more interesting: **one primitive triple carries multiple musically meaningful interval projections**.

Suggested Lean-facing definitions:

```lean
def isPythTriple (a b c : ℤ) : Prop := a^2 + b^2 = c^2

def primitiveTriple (a b c : ℤ) : Prop :=
  isPythTriple a b c ∧ Int.gcd a (Int.gcd b c) = 1

def legRatio (a b : ℤ) : ℚ :=
  (Int.natAbs (max a b) : ℚ) / (Int.natAbs (min a b) : ℚ)

def hypLegRatio (a b c : ℤ) : ℚ :=
  (Int.natAbs c : ℚ) / (Int.natAbs (max a b) : ℚ)

def tropicalLogRatio (q : ℚ) : ℝ :=
  Real.log q

def consonantRatio (q : ℚ) : Prop :=
  0 < q ∧ ∃ m n : ℕ, Nat.Coprime m n ∧ q = (m : ℚ) / n ∧ m * n ≤ 20
```

For the min-plus side, define a tropicalized interval coordinate:
```lean
def tropicalInterval (q : ℚ) : ℝ := Real.log q
```
and optionally a fifth-normalized coordinate:
```lean
def fifthCoordinate (q : ℚ) : ℝ := Real.log q / Real.log ((3 : ℝ) / 2)
```

This lets you state “circle of fifths” results as additive approximation or orbit statements in logarithmic space.

---

## Precise Theorem Targets

### Theorem A: Primitive triples induce positive reduced harmonic ratios

This is the foundational theorem. It turns number-theoretic triples into musical objects.

**Statement:**
For every primitive Pythagorean triple `(a,b,c)` with positive entries, both the leg ratio and hypotenuse-to-leg ratio are positive reduced rational numbers greater than `1`.

**Lean 4 type signature sketch:**
```lean
theorem primitive_triple_ratios_well_defined
  {a b c : ℤ}
  (hprim : primitiveTriple a b c)
  (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
  1 < legRatio a b ∧
  1 < hypLegRatio a b c ∧
  0 < (legRatio a b : ℚ) ∧
  0 < (hypLegRatio a b c : ℚ)
```

A stronger version should prove reducedness using coprimality inherited from primitiveness.

```lean
theorem primitive_triple_legRatio_reduced
  {a b c : ℤ}
  (hprim : primitiveTriple a b c)
  (ha : 0 < a) (hb : 0 < b) :
  ∃ m n : ℕ, Nat.Coprime m n ∧ legRatio a b = (m : ℚ) / n
```

**Why this matters:** this is the exact formal bridge from arithmetic geometry to harmonic theory. Without this, everything else is metaphor.

---

### Theorem B: The root triple `(3,4,5)` carries canonical musical intervals

The original prompt’s claim is too coarse. The correct breakthrough is to formalize the multiplicity of interval projections from a single triple.

**Statement:**
The root triple yields:
- leg ratio `4/3`, the perfect fourth,
- inverse leg ratio `3/4`,
- hypotenuse/greater-leg ratio `5/4`, the just major third,
- hypotenuse/smaller-leg ratio `5/3`, the major sixth.

**Lean 4 type signature sketch:**
```lean
theorem root_triple_interval_values :
  legRatio 3 4 = (4 : ℚ) / 3 ∧
  hypLegRatio 3 4 5 = (5 : ℚ) / 4
```

If you define the smaller-leg hypotenuse ratio:
```lean
def hypMinLegRatio (a b c : ℤ) : ℚ :=
  (Int.natAbs c : ℚ) / (Int.natAbs (min a b) : ℚ)
```
then also:
```lean
theorem root_triple_interval_values_extended :
  legRatio 3 4 = (4 : ℚ) / 3 ∧
  hypLegRatio 3 4 5 = (5 : ℚ) / 4 ∧
  hypMinLegRatio 3 4 5 = (5 : ℚ) / 3
```

You may then define predicates:
```lean
def isPerfectFourth (q : ℚ) : Prop := q = (4 : ℚ) / 3
def isMajorThird   (q : ℚ) : Prop := q = (5 : ℚ) / 4
```
and prove:
```lean
theorem root_triple_has_perfect_fourth_and_major_third :
  isPerfectFourth (legRatio 3 4) ∧
  isMajorThird (hypLegRatio 3 4 5)
```

**Why this matters:** it corrects an imprecise narrative and replaces it with a richer theorem: one primitive triple encodes a chord-like interval package.

---

### Theorem C: Berggren maps preserve harmonicity and induce logarithmic interval dynamics

Use the certified Berggren theorem as your transport mechanism.

**Statement:**
If `B` is a Berggren generator and `(a,b,c)` is a primitive Pythagorean triple with positive entries, then the image triple also determines positive harmonic ratios, and tropical logarithm sends multiplicative ratio comparisons into additive interval relations.

**Lean 4 type signature sketch:**
```lean
theorem berggren_preserves_harmonic_ratio_domain
  {a b c a' b' c' : ℤ}
  (hpy : primitiveTriple a b c)
  (hB : berggren_map_pythagorean (a,b,c) = (a',b',c')) :
  primitiveTriple a' b' c' →
  0 < legRatio a' b' ∧ 0 < hypLegRatio a' b' c'
```

For logarithmic transport:
```lean
theorem tropicalLogRatio_mul
  {q r : ℚ}
  (hq : 0 < q) (hr : 0 < r) :
  tropicalLogRatio (q * r) = tropicalLogRatio q + tropicalLogRatio r
```

Then combine with interval constructions to show additive behavior in log-space.

A stronger orbit statement, if feasible:
```lean
theorem berggren_orbit_log_intervals_discrete
  (T : ℕ → ℤ × ℤ × ℤ)
  (hroot : T 0 = (3,4,5))
  (hstep : ∀ n, ∃ U, T (n+1) = berggrenStep U (T n)) :
  ∀ n, ∃ q : ℚ, q = legRatio (T n).1 ((T n).2.1) ∧ 0 < tropicalLogRatio q
```

This is weakly stated, but it opens the route to proving monotonicity, bounded gaps, or discrete additive generation in interval space.

---

### Theorem D: A finite consonance classifier for primitive triples

You should define a mathematically explicit consonance predicate, not a psychoacoustic one. Start with a complexity bound on reduced numerator/denominator.

**Statement:**
Primitive triples with sufficiently small induced ratios are consonant under a bounded-complexity criterion.

**Lean 4 type signature sketch:**
```lean
def intervalComplexity (q : ℚ) : ℕ :=
  q.num.natAbs + q.den.natAbs

def consonant (q : ℚ) : Prop :=
  0 < q ∧ intervalComplexity q ≤ 12

theorem root_triple_consonant_intervals :
  consonant (legRatio 3 4) ∧
  consonant (hypLegRatio 3 4 5)
```

A more structural theorem:
```lean
theorem primitive_triple_small_entries_give_consonance
  {a b c : ℤ}
  (hprim : primitiveTriple a b c)
  (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
  (hbound : Int.natAbs c ≤ 12) :
  consonant (legRatio a b) ∧ consonant (hypLegRatio a b c)
```

This theorem would use catalog bounds such as `berggren_ca_triple_entry_bound` to derive finite certified regions of consonance in the Berggren tree.

**Why this matters:** it transforms musical language into a finite arithmetic geometry of low-complexity rationals.

---

### Theorem E: Circle-of-fifths shadow via Berggren orbit and tropical normalization

This is the most speculative and potentially field-opening target. State it carefully so it is true and formalizable.

Do **not** claim literal equality between Berggren orbits and the circle of fifths. Instead prove a **shadow theorem**: there exists a projection from primitive triples to logarithmic interval classes modulo octaves, and this projection sends selected Berggren suborbits into an additive subgroup generated by `log(3/2)` modulo `log 2`.

Define octave-equivalence:
```lean
def octaveEquivalent (x y : ℝ) : Prop :=
  ∃ n : ℤ, x - y = n * Real.log 2
```

Define fifth-generated class:
```lean
def inCircleOfFifthsClass (x : ℝ) : Prop :=
  ∃ n : ℤ, octaveEquivalent x (n * Real.log ((3 : ℝ) / 2))
```

Then target a theorem of the form:

```lean
theorem root_legRatio_in_circle_of_fifths_shadow :
  inCircleOfFifthsClass (tropicalInterval ((4 : ℚ) / 3))
```

This works because `4/3 = 2^2 / 3`, so
`log(4/3) = 2 log 2 - log 3 = log 2 - log(3/2)`,
hence octave-equivalent to `-log(3/2)`.

This is the right mathematical correction of the prompt’s ambition:
- the perfect fourth is the inverse fifth modulo octave,
- therefore the root triple already sits on the circle-of-fifths lattice after logarithm modulo octaves.

A more ambitious theorem:
```lean
theorem perfect_fourth_is_negative_fifth_mod_octave :
  octaveEquivalent (Real.log ((4 : ℝ) / 3)) (- Real.log ((3 : ℝ) / 2))
```

This is simple, exact, and conceptually powerful.

**Why this matters:** this is the first rigorous bridge between Euclidean triple geometry, multiplicative rational harmony, and tropical/additive interval theory modulo octave periodicity.

---

## Proof Strategy Architecture

### Strategy 1: Arithmetic-first, then musical semantics
Most promising for Lean completion.

1. Use existing Pythagorean and primitive-triple theorems to derive positivity, nonzero denominators, and coprimality facts.
2. Define ratio maps as rational-valued functions using `Int.natAbs`, `max`, `min`.
3. Prove exact evaluations for `(3,4,5)` by norm_num/ring reductions.
4. Introduce `Real.log` only after positivity is established, then prove additive transport lemmas and octave-equivalence identities.

Why promising:
- It isolates the hard algebraic facts before touching transcendental analysis.
- Lean handles exact rational identities and positivity much better than vague orbit semantics.
- This path should minimize `sorry`.

---

### Strategy 2: Berggren-equivariant semantics
Best for the breakthrough theorem.

1. Formalize a notion of `intervalMap : triple → ℚ`.
2. Show Berggren-generated triples stay in the domain using `berggren_map_pythagorean` and root theorems.
3. Study how each Berggren matrix transforms `(a,b,c)` and experimentally identify monotone or recurrent patterns in `legRatio` or `hypLegRatio`.
4. State and prove a transport theorem: Berggren dynamics preserve harmonic admissibility and induce a discrete orbit in log-space.

Why promising:
- It leverages the catalog directly.
- It creates a genuine dynamical system on interval space.
- Even a modest preservation theorem opens future spectral/dynamical work.

Risk:
- Exact circle-of-fifths encoding may be too strong globally; use a “shadow” theorem or a selected suborbit.

---

### Strategy 3: Tropical normalization and modulo-octave quotient
Most conceptually revolutionary.

1. Define interval space as positive rationals modulo powers of `2`.
2. Use logarithm to identify this quotient with additive classes modulo `log 2`.
3. Show that `4/3` is equivalent to `(3/2)^(-1)` modulo octaves.
4. Prove root-triple interval classes lie in the additive subgroup generated by fifths.

Why promising:
- This is where the “tropical music theory” becomes mathematically real.
- It connects number theory, additive geometry, and tuning theory.
- It could become the seed of a new formalized theory of rational temperaments.

Risk:
- Quotient structures modulo octave equivalence may require careful setoid machinery in Lean.

Recommended order:
**Strategy 1 first**, then **Strategy 3**, then **Strategy 2** if time remains.

---

## Cross-Domain Connections You Should Explicitly Exploit

### 1. Tropical geometry / min-plus algebra
The logarithm turns multiplicative frequency ratios into additive interval coordinates. Octave reduction becomes quotienting by translations in `log 2`. This is exactly the kind of structure tropical mathematics is built to see.

Possible theorem-level language:
- “harmonic ratios tropicalize to a discrete additive semimodule”
- “octave equivalence is translation equivalence in logarithmic interval space”
- “circle of fifths is a rank-1 lattice in tropical interval coordinates”

### 2. Dynamical systems / symbolic orbits
The Berggren tree is not just a generator of triples; it is a branching dynamical system. Pushing it through ratio maps creates an interval dynamical system. Even if exact closed forms are hard, proving invariants or monotonicity along subtrees would be novel.

### 3. Mathematical music theory / tuning theory
Formalize perfect fourth, fifth, major third, octave equivalence, and complexity-based consonance. The key is to use exact rational tuning, not floating-point approximations.

### 4. Discrete geometry / lattice theory
Primitive triples form a lattice-like arithmetic object. Interval extraction from triples can be viewed as a projection from a Diophantine lattice to a rational simplex of harmonic classes.

### 5. Information/compression viewpoint
Consonance as low arithmetic complexity suggests a coding-theoretic interpretation: simple ratios are low-description-length intervals. This is fertile ground for future theorem design.

---

## Building on Catalog Theorems

Use the verified results concretely, not ceremonially:

- `berggren_map_pythagorean`  
  Use this to show that your interval maps are defined on every Berggren descendant. This is the bridge from static triples to orbit semantics.

- `min_primitive_triple`  
  Use it to establish canonical positivity/minimality facts needed for `min`/`max` ratio definitions and to avoid denominator pathologies.

- `berggren_ca_triple_entry_bound`  
  Use this for finite-search or bounded-consonance theorems: if entries are bounded on a computational orbit segment, then induced ratios have bounded complexity.

- `root_triple_pythagorean` and `root_triple_is_pythagorean`  
  Use them as the certified base case for all root-triple musical interval theorems.

Do not merely cite these. Thread them directly into the proof architecture.

---

## Lean 4 Formalization Targets

You should aim to produce the following theorem names or close variants:

```lean
theorem primitive_triple_ratios_well_defined ...
theorem primitive_triple_legRatio_reduced ...
theorem root_triple_interval_values ...
theorem root_triple_has_perfect_fourth_and_major_third ...
theorem tropicalLogRatio_mul ...
theorem perfect_fourth_is_negative_fifth_mod_octave ...
theorem root_legRatio_in_circle_of_fifths_shadow ...
theorem berggren_preserves_harmonic_ratio_domain ...
theorem primitive_triple_small_entries_give_consonance ...
```

Useful concrete types:
- `ℤ` for triples
- `ℚ` for exact interval ratios
- `ℝ` for logarithmic/tropical interval space
- `Finset` if you enumerate bounded consonant descendants
- `Matrix` if Berggren generators are already represented linearly

---

## If a Claim Fails, Turn It Into a Counterexample Theorem

If the global claim
“the orbit structure of the Berggren tree encodes the circle of fifths”
is too strong, prove instead a sharp obstruction theorem.

For example:

```lean
theorem not_every_berggren_legRatio_is_fifth_power_mod_octave :
  ¬ ∀ a b c : ℤ, primitiveTriple a b c →
      inCircleOfFifthsClass (tropicalInterval (legRatio a b))
```

A clean counterexample would be scientifically valuable: it would force the correct reformulation in terms of a suborbit, projection, approximation, or coarse equivalence class.

This is not failure. This is theory formation.

---

## Deliverables

1. Lean 4 code proving as many of the theorem targets as possible.
2. Definitions for harmonic ratio, tropical interval, octave equivalence, consonance.
3. At least one theorem that explicitly uses a catalog theorem.
4. A correction of the `(3,4,5)` interval claim if necessary, with formal proof.
5. `FUTURE_DIRECTIONS.md` containing **3–5 concrete breakthrough next steps**.

---

## Required `FUTURE_DIRECTIONS.md`

This file is mandatory. It must contain 3–5 specific, high-upside next problems, for example:

1. **Berggren spectral harmony:** classify which Berggren subtrees produce monotone sequences in `tropicalInterval`.
2. **Octave quotient formalization:** construct a Lean setoid/quotient for rational intervals modulo powers of `2`.
3. **Consonance complexity theorem:** prove asymptotic sparsity of low-complexity interval classes among primitive triples.
4. **Temperament comparison:** compare just-intonation interval classes from triples with equal-tempered approximations via Diophantine bounds.
5. **Automata on Berggren music orbits:** use `berggren_ca_triple_entry_bound` to define and certify a cellular automaton of harmonic classes.

These should be written as actual next-cycle research targets, not vague aspirations.

---

## Application Keywords

Pythagorean triples, Berggren tree, harmonic ratios, just intonation, perfect fourth, major third, circle of fifths, tropical logarithm, min-plus algebra, octave equivalence, consonance classification, rational tuning, arithmetic dynamics, lattice music theory, formalized music mathematics, Lean 4, Mathlib

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
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

**Team Directive**: Create a team to conduct research, brainstorm hypotheses,
run experiments, validate data, update knowledge base and iterate forever.
Each future direction should be specific enough for a team to pick up and
pursue with clear hypotheses, proof strategies, and cross-domain connections.

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
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Pythagorean
Research mode: prove
