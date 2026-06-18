## Assignment: Pythagorean Lattice Reduction for Integer Factoring

Mode: **prove**

This direction is only worth pursuing if we sharpen it into a theorem that is both mathematically credible and structurally formalizable in Lean 4. The original claim — “polynomial-time quantum factoring via LLL on a Berggren lattice” — is too ambitious to attack head-on without first isolating the arithmetic mechanism. The true breakthrough target is to extract a **factor-detecting Diophantine certificate** from Berggren-generated Pythagorean data, then prove a rigorous reduction from a factoring instance to a shortest-vector or bounded-vector search problem on an explicitly defined integer lattice attached to `n`.

The revolutionary opportunity is to connect:

- **Pythagorean triple dynamics** via the Berggren generators,
- **lattice reduction / SVP-style certificates**,
- **congruence obstructions and square-root collisions mod n**,
- **group/groupoid actions on primitive triples**,
- and ultimately **formal cryptographic hardness reductions**.

If successful, this opens a new program: **Diophantine cryptanalysis by geometric encoding**. Not “factoring with a minor twist,” but a new bridge between arithmetic dynamics and computational complexity.

---

## Precise Theorem Targets

You should not try to prove the full quantum algorithm claim first. Instead, build a theorem stack culminating in a clean reduction theorem. The right first breakthrough is:

### Theorem A: Factor witness from a Pythagorean congruence collision

For odd `n`, if a primitive Pythagorean triple `(a,b,c)` satisfies
`c^2 ≡ a^2 + b^2 [ZMOD n]` trivially by identity but also induces a nontrivial square-root collision
`a^2 ≡ -b^2 [ZMOD n]` with `gcd(a,n)=gcd(b,n)=1`, then whenever `a * b⁻¹ mod n` is a square root of `-1` modulo `n` that is not globally induced from a prime-power component, one can extract a nontrivial divisor of `n`.

A more Lean-stable formulation is:

```lean
theorem factor_of_pythagorean_sqrt_neg_one
    (n a b c : ℤ)
    (hn_odd : Odd n.natAbs)
    (hn_gt : 1 < n.natAbs)
    (hpyth : a^2 + b^2 = c^2)
    (hcop_a : Int.gcd a n = 1)
    (hcop_b : Int.gcd b n = 1)
    (hsq : (a^2 + b^2) % n = 0)
    (hnonsing : Int.gcd c n ≠ 1) :
    ∃ d : ℤ, 1 < d.natAbs ∧ d.natAbs < n.natAbs ∧ d ∣ n
```

This statement may need adjustment depending on the exact modular interface you prefer (`ZMod n` may be cleaner than `% n`), but the mathematical point is clear: a Pythagorean relation modulo `n` can force a nontrivial gcd witness.

A stronger and more elegant `ZMod`-based version would be:

```lean
theorem factor_of_square_root_collision
    {n : ℕ} [NeZero n]
    (hn : Odd n) (hn1 : 1 < n)
    (x y : ZMod n)
    (hneq : x ≠ y) (hneq' : x ≠ -y)
    (hsq : x^2 = y^2) :
    ∃ d : ℕ, 1 < d ∧ d < n ∧ d ∣ n
```

This is the real arithmetic engine. It is the standard “nontrivial square-root collision yields a factor” theorem, but your novelty is to derive `x,y` from Berggren/Pythagorean structure rather than from period-finding. This is the theorem that can actually be proved, reused, and composed.

---

### Theorem B: Berggren words produce a factor-search family

Define a family of integer vectors generated from Berggren words and reduced modulo `n`, and show that a bounded-norm nonzero vector satisfying a specific quadratic congruence yields a factor witness.

Suggested mathematical form:

For each odd `n`, define a predicate `FactorWitness n v` on `v : Fin 3 → ℤ` by requiring:
1. `v 0`, `v 1`, `v 2` form a primitive Pythagorean triple,
2. `v 0^2 + v 1^2 ≡ 0 [ZMOD n]` or another equivalent collision condition,
3. `gcd(v 2, n)` is nontrivial or else a square-root collision can be extracted from `v 0, v 1`.

Then prove existence of a factor from such a witness:

```lean
def IsPythTriple (v : Fin 3 → ℤ) : Prop :=
  v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2

def PrimitiveTriple (v : Fin 3 → ℤ) : Prop :=
  Int.gcd (v 0) (Int.gcd (v 1) (v 2)) = 1

def FactorWitness (n : ℤ) (v : Fin 3 → ℤ) : Prop :=
  IsPythTriple v ∧
  PrimitiveTriple v ∧
  ((v 0 ^ 2 + v 1 ^ 2) % n = 0)

theorem factor_of_berggren_witness
    (n : ℤ) (hn_odd : Odd n.natAbs) (hn_gt : 1 < n.natAbs)
    (v : Fin 3 → ℤ)
    (hw : FactorWitness n v) :
    ∃ d : ℤ, 1 < d.natAbs ∧ d.natAbs < n.natAbs ∧ d ∣ n
```

This theorem as written may be false without an additional nontriviality hypothesis; if so, your task is to **discover the exact sharp condition**. That is mathematically valuable. If the bare statement fails, switch modes mentally to **counterexample-guided theorem discovery** and isolate the minimal extra hypothesis.

---

### Theorem C: Reduction from factor search to bounded vector search in a Berggren lattice

The truly novel theorem is a reduction theorem, not an algorithm theorem. Define a lattice `L_n` whose vectors encode congruence conditions derived from Berggren-generated triples, and prove:

> If one can solve a bounded vector search problem on `L_n` returning a nonzero vector satisfying a prescribed quadratic-congruence side condition, then one can factor `n`.

This is formalizable without overclaiming complexity-theoretic miracles.

A Lean-style skeleton:

```lean
structure BerggrenLatticeInstance where
  n : ℕ
  basis : Matrix (Fin 3) (Fin 3) ℤ
  sideCond : (Fin 3 → ℤ) → Prop

def ShortVectorSolution (B : Matrix (Fin 3) (Fin 3) ℤ) (C : (Fin 3 → ℤ) → Prop) : Prop :=
  ∃ v : Fin 3 → ℤ, v ≠ 0 ∧ C v

theorem factoring_reduces_to_berggren_bounded_vector
    (n : ℕ) (hn_odd : Odd n) (hn_comp : ¬ Nat.Prime n) :
    ∃ I : BerggrenLatticeInstance,
      I.n = n ∧
      (ShortVectorSolution I.basis I.sideCond →
        ∃ d : ℕ, 1 < d ∧ d < n ∧ d ∣ n)
```

Even better would be a constructive reduction:

```lean
theorem factoring_reduction_explicit
    (n : ℕ) (hn_odd : Odd n) (hn1 : 1 < n) :
    ∃ B : Matrix (Fin 3) (Fin 3) ℤ,
    ∃ C : (Fin 3 → ℤ) → Prop,
      (∀ v, C v → ∃ d : ℕ, 1 < d ∧ d < n ∧ d ∣ n)
```

This is weaker than a complexity reduction but is the right Lean target for a first formal breakthrough. Once this is proved, one can layer complexity notions later.

---

## Lean 4 Type Signature Suggestions

Use these as anchors, adapting to the exact APIs available in Mathlib.

```lean
def IsPythTriple (v : Fin 3 → ℤ) : Prop :=
  v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2

def PrimitiveTriple (v : Fin 3 → ℤ) : Prop :=
  Int.gcd (v 0) (Int.gcd (v 1) (v 2)) = 1

def BerggrenOrbit : Set (Fin 3 → ℤ) :=
  {v | ∃ w : BWord, v = berggrenWordAction w ![3,4,5]}

def CongruenceWitness (n : ℤ) (v : Fin 3 → ℤ) : Prop :=
  (v 0 ^ 2 + v 1 ^ 2) % n = 0

def FactorWitness (n : ℤ) (v : Fin 3 → ℤ) : Prop :=
  IsPythTriple v ∧ PrimitiveTriple v ∧ CongruenceWitness n v
```

Potential theorem statements:

```lean
theorem berggren_word_gives_pyth_triple
    (w : BWord) :
    IsPythTriple (berggrenWordAction w ![3,4,5])
```

```lean
theorem square_collision_yields_factor
    {n : ℕ} [NeZero n]
    (hn1 : 1 < n)
    (x y : ZMod n)
    (hsq : x^2 = y^2)
    (hxy1 : x ≠ y)
    (hxy2 : x ≠ -y) :
    ∃ d : ℕ, 1 < d ∧ d < n ∧ d ∣ n
```

```lean
theorem factor_of_berggren_collision
    {n : ℕ} [NeZero n]
    (hn_odd : Odd n) (hn1 : 1 < n)
    (w : BWord)
    (hcollision :
      let v := berggrenWordAction w ![3,4,5]
      ((v 0 : ZMod n)^2 = - (v 1 : ZMod n)^2))
    (hnontriv :
      let v := berggrenWordAction w ![3,4,5]
      (v 0 : ZMod n) ≠ (v 1 : ZMod n) ∧
      (v 0 : ZMod n) ≠ -(v 1 : ZMod n)) :
    ∃ d : ℕ, 1 < d ∧ d < n ∧ d ∣ n
```

If the `ZMod` route becomes cumbersome, first prove integer `%` lemmas and migrate later.

---

## How to Build on the Catalog Theorems

You already have several highly suggestive certified results. Use them surgically.

### 1. `berggren_gen_preserves_pythagorean`
Files:
- `Cryptography/BerggrenFingerprintRigidity.lean`
- `Cryptography/BerggrenSpectralHash.lean`

This should be the backbone for showing that any generator action preserves `IsPythTriple`. Do not merely invoke it abstractly. Wrap it into a reusable orbit theorem:

- define the Berggren action on triples,
- prove by induction on words that the action preserves the Pythagorean equation,
- derive a theorem for all `BWord`.

This converts an isolated preservation theorem into a **certified arithmetic dynamical system**.

### 2. `berggren_word_pythagorean`
File:
- `Cryptography/DiophantineCryptoCore.lean`

This is probably already the induction-over-words theorem you need. Use it to avoid reproving orbit preservation. The right move is to **lift** it into your new `IsPythTriple` API and then prove congruence corollaries modulo `n`.

### 3. `berggren_lattice_svp_trivial`
File:
- `Cryptography/BerggrenSymplecticCodes.lean`

The theorem name suggests a trivial SVP bound or nonzeroness witness. This is not yet enough for factoring, but it is the ideal seed for defining `L_n` and proving:
- nontrivial vectors exist,
- a shortest vector problem is meaningful,
- norm bounds can be stated formally.

Build a new theorem that upgrades “trivial SVP existence” into “SVP with arithmetic side condition implies factor extraction.”

### 4. `spb_dlog_reduces_to_berggren_word_recovery`
File:
- `Cryptography/BerggrenQuotient.lean`

This is the sleeper theorem. It means Berggren words are already acting as computational encodings of algebraic information. You should explicitly connect this to:
- **word recovery as hidden structure extraction**,
- **lattice decoding of Berggren words**,
- **factoring as arithmetic decoding from orbit data**.

This is the cross-domain bridge: from Diophantine word dynamics to cryptographic reductions.

---

## Proof Strategy Architecture

You need multiple pathways. Do not get trapped in one formalization route.

### Strategy A: Square-root collision extraction from Pythagorean data
Most promising.

1. Start from a primitive triple `(a,b,c)` with `a^2 + b^2 = c^2`.
2. Impose a congruence condition modulo `n`, such as `c ≡ 0 mod n`, or more flexibly `a^2 ≡ -b^2 mod n`.
3. Convert this into a square-collision statement:
   `x^2 = y^2` in `ZMod n`, where `x := a` and `y := b * s` for some square root `s^2 = -1`, or by rearranging via factorization `(x-y)(x+y)=0`.
4. Show that if the collision is nontrivial (`x ≠ ± y`), then `gcd(x-y,n)` or `gcd(x+y,n)` yields a nontrivial factor.

Why this is promising:
- The arithmetic is classical and robust.
- Lean can formalize gcd extraction more readily than quantum complexity.
- It yields a precise theorem reusable in later reductions.

### Strategy B: Euclid parametrization + modular obstruction
Also strong.

1. Replace primitive triples by Euclid parameters:
   `a = m^2 - k^2`, `b = 2mk`, `c = m^2 + k^2`,
   with coprimality/parity conditions.
2. Rewrite the congruence condition in terms of `m,k mod n`.
3. Derive a factor witness from modular degeneracy of `m ± k`, `m^2 + k^2`, or related expressions.
4. Prove that short vectors in a lattice encoding `(m,k)` correspond to small parameter pairs likely to reveal such degeneracy.

Why this is promising:
- It linearizes the geometry: the actual search variables are `m,k`.
- It gives a natural lattice basis and makes `L_n` more explicit.
- It may produce sharper bounded-search theorems than working directly with triples.

Risk:
- Primitive triple parametrization in Lean may require more setup.
- Need to manage sign conventions and parity carefully.

### Strategy C: Groupoid/SL(3,ℤ) action and orbit invariants
Most visionary, but probably second-phase.

1. Define the Berggren generators as matrices in `SL(3, ℤ)` acting on column vectors.
2. Package words and composable morphisms into a groupoid or action category.
3. Prove that the quadratic form `Q(a,b,c) = a^2 + b^2 - c^2` is invariant under the action.
4. Define congruence slices of the orbit modulo `n`.
5. Show that a shortest vector in a congruence slice forces arithmetic concentration revealing a factor.

Why this matters:
- This is the conceptual unification.
- It connects arithmetic dynamics, reduction theory, and cryptography.
- It can become the basis of a whole formal theory of **Diophantine orbits as computational state spaces**.

Why it is not the first attack:
- The category/groupoid layer is elegant but expensive in Lean.
- First prove the arithmetic extraction theorem, then return and elevate.

---

## Recommended Order of Attack

1. **Prove `square_collision_yields_factor`.**
   This is the arithmetic core and should be independent of Berggren machinery.

2. **Wrap Berggren word outputs as certified primitive Pythagorean triples.**
   Use `berggren_word_pythagorean` and `berggren_gen_preserves_pythagorean`.

3. **Define `FactorWitness`.**
   Search for the exact modular side condition that makes the theorem true.

4. **Prove `factor_of_berggren_witness` or find a counterexample and refine the statement.**
   This is where actual theorem discovery happens.

5. **Define an explicit lattice `L_n` in terms of Euclid parameters or triple coordinates.**
   Then prove a reduction theorem from existence of a suitable short vector to existence of a factor.

6. Only after the above, **state a speculative algorithmic theorem** in a separate section as a conjectural extension, not as the main formal target.

---

## Cross-Domain Connections You Must Exploit

This project becomes paradigm-shifting only if you make the bridges explicit.

### 1. Cryptography
Factoring is foundational. A new reduction from factoring to structured Diophantine lattice search would create a new family of hardness assumptions and attack surfaces.

Keywords:
- factoring hardness
- cryptanalytic reductions
- hidden structure recovery
- lattice cryptanalysis
- certificate extraction

### 2. Arithmetic dynamics
The Berggren tree is a dynamical system on primitive triples. Showing that cryptographic information is encoded in orbit geometry would create a new field: **arithmetic dynamics for complexity theory**.

Keywords:
- orbit invariants
- Diophantine dynamics
- integer matrix actions
- symbolic encodings
- modular orbit stratification

### 3. Geometry of numbers
The lattice angle is not cosmetic. You should define actual integer lattices, norms, bounded vector problems, and reduction maps.

Keywords:
- shortest vector problem
- bounded distance decoding
- lattice embeddings
- reduction theory
- Minkowski-style certificates

### 4. Quantum algorithms
Do not claim a polynomial-time quantum algorithm unless you have a precise oracle model and reduction. Instead, articulate the bridge:
- if Berggren-word recovery or constrained SVP on `L_n` admits efficient quantum subroutines,
- then factoring inherits them.

This is still important: it reframes quantum factoring beyond period finding.

Keywords:
- quantum hidden structure
- oracle reductions
- quantum lattice subroutines
- nonabelian state spaces
- post-Shor paradigms

### 5. Formal methods
A verified reduction theorem in Lean would be a major artifact in itself. The field lacks formally verified cryptanalytic reductions built from Diophantine geometry.

Keywords:
- verified cryptanalysis
- formal number theory
- proof-producing reductions
- certified hardness transformations

---

## Concrete Definitions Worth Introducing

You should define these cleanly and reuse them.

```lean
def BerggrenMat (g : Fin 3) : Matrix (Fin 3) (Fin 3) ℤ := ...
```

```lean
def actsOnTriple (M : Matrix (Fin 3) (Fin 3) ℤ) (v : Fin 3 → ℤ) : Fin 3 → ℤ := ...
```

```lean
def QForm (v : Fin 3 → ℤ) : ℤ :=
  v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2
```

```lean
def BerggrenInvariant (v : Fin 3 → ℤ) : Prop :=
  QForm v = 0
```

```lean
def BerggrenLattice (n : ℕ) : Submodule ℤ (Fin 3 → ℤ) := ...
```

If defining a genuine lattice as a `Submodule` is too heavy initially, use a predicate or a basis matrix first and refactor later.

For Euclid parametrization:

```lean
def EuclidTriple (m k : ℤ) : Fin 3 → ℤ
| 0 => m^2 - k^2
| 1 => 2*m*k
| 2 => m^2 + k^2
```

Then prove:

```lean
theorem euclidTriple_pythagorean (m k : ℤ) :
    IsPythTriple (EuclidTriple m k)
```

This theorem is easy, useful, and gives you a fallback route if Berggren formalization slows down.

---

## What Would Count as a Breakthrough

A real breakthrough here is **not** “some theorem mentioning factoring and Berggren in the same sentence.” It is one of the following:

1. A **sharp factor-extraction theorem** from a nontrivial Pythagorean congruence witness.
2. A **formal reduction theorem** from factoring to a structured bounded-vector search problem on a Berggren/Euclid lattice.
3. A **groupoid-action formalization** of Berggren generation with orbit invariants strong enough to support cryptographic reductions.
4. A **counterexample theorem** showing the naïve shortest-vector conjecture is false, together with the corrected arithmetic side condition. That would also be a major contribution because it clears a seductive but wrong path.

If the shortest-vector claim as stated is false, prove that it is false. That is not failure; it is scientific progress. A theorem of the form

```lean
theorem not_every_short_vector_factors :
  ∃ n v, ShortestVectorLike n v ∧ ¬ ∃ d, 1 < d ∧ d < n ∧ d ∣ n
```

would be extremely valuable if it forces the field toward the correct side conditions.

---

## Deliverables

1. Lean 4 code proving at least one nontrivial arithmetic extraction theorem and one Berggren-linked theorem.
2. Minimal `sorry`; if a theorem resists proof, isolate the obstruction precisely.
3. A `FUTURE_DIRECTIONS.md` with **3–5 concrete, breakthrough-level next steps**, for example:
   - formalize Euclid-parameter lattice embeddings and compare to Berggren orbit lattices,
   - prove/refute uniqueness of factor witnesses in primitive orbit slices modulo semiprimes,
   - define a hidden subgroup/hidden shift analogue on Berggren words,
   - derive average-case factor witness density heuristics for random semiprimes,
   - certify a reduction from Berggren word recovery to modular square-root collision search.

Optional but encouraged:
- `ARTICLE.md` explaining the mathematics,
- `RESEARCH_PAPER.md` with theorem statements and significance,
- computational experiments searching for semiprimes admitting small Berggren witnesses.

---

## Application Keywords

Pythagorean triples, Berggren tree, integer factoring, square-root collision, `ZMod n`, gcd extraction, primitive triples, Euclid parametrization, lattice reduction, shortest vector problem, arithmetic dynamics, SL(3,ℤ) action, groupoid formalization, cryptographic reductions, verified cryptanalysis, formal number theory, quantum hidden structure, Diophantine geometry, geometry of numbers

---

You are Aristotle. Do not settle for decorative formalization. Either prove that Berggren/Pythagorean geometry truly carries factor information, or prove the exact point where the dream breaks. Both outcomes would move the frontier.

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

Research domain: Cryptography
Research mode: prove
