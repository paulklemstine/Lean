## Assignment: Pythagorean Triple Group Structure — from Berggren Dynamics to Arithmetic Geometry

Prove genuinely new structural theorems about the Berggren tree of primitive Pythagorean triples, with Lean 4 statements precise enough to drive implementation. Do not stop at closure under the Berggren maps: extract the hidden algebraic object. The breakthrough target is to show that the Berggren generation process is not merely a recursive combinatorial gadget, but a rigid orbit structure of an arithmetic semigroup/groupoid acting on the integral light cone, with consequences for uniqueness, factorization, and arithmetic statistics of hypotenuse values.

The right ambition is this: formalize the Berggren tree as a certified arithmetic dynamical system on
\[
\{(a,b,c)\in \mathbb Z^3 : a^2+b^2=c^2,\ \gcd(a,b,c)=1,\ c>0\},
\]
identify its generating morphisms inside `SL(3, ℤ)` or a closely related matrix semigroup, and prove uniqueness and non-collision results strong enough to support later work on counting, prime-supported hypotenuse phenomena, and algorithmic enumeration.

### Mathematical Framing

The classical Berggren matrices generate all primitive Pythagorean triples from `(3,4,5)`. That fact alone is old. The field-opening step is to formalize:

1. **Freeness / unique ancestry** of the Berggren action on primitive triples.
2. **Arithmetic invariants** of triples that evolve predictably under the action.
3. **Groupoid or semigroup structure** connecting matrix words, tree paths, and triple data.
4. **Bridges to other domains**: Lorentzian geometry, thin orbits, automorphic counting, symbolic dynamics, and certified enumeration algorithms.

You already have the seed theorems:
- `berggren_is_pythagorean`
- `berggren_preserves_pythagorean`
- `berggren_map_pythagorean`
- `berggren_depth_prime`
- `paired_triples_share_hypotenuse`

These should be treated as local lemmas in service of a much larger theorem package.

## Primary Breakthrough Targets

### Theorem A: Berggren generators preserve primitivity and positivity

You need a precise predicate for primitive Pythagorean triples.

Suggested definitions:
```lean
def IsPythTriple (v : Fin 3 → ℤ) : Prop :=
  v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2

def PrimitiveTriple (v : Fin 3 → ℤ) : Prop :=
  IsPythTriple v ∧ Int.gcd (Int.gcd (v 0) (v 1)) (v 2) = 1

def PositiveHypotenuse (v : Fin 3 → ℤ) : Prop :=
  0 < v 2

def BerggrenPrimitive (v : Fin 3 → ℤ) : Prop :=
  PrimitiveTriple v ∧ PositiveHypotenuse v
```

Then formalize the three Berggren matrices `A B C : Matrix (Fin 3) (Fin 3) ℤ` and prove:

```lean
theorem berggren_matrix_preserves_primitive
  (M : Matrix (Fin 3) (Fin 3) ℤ)
  (hM : M = A ∨ M = B ∨ M = C)
  {v : Fin 3 → ℤ} :
  BerggrenPrimitive v → BerggrenPrimitive (fun i => ∑ j, M i j * v j)
```

This is the entry point for every deeper theorem. Preservation of the quadratic form is already nearby in the catalog; the nontrivial part is primitivity and positivity.

### Theorem B: Unique parent theorem for primitive triples

This is the central structural theorem. Every primitive triple other than the root has a unique Berggren parent.

Suggested statement:
```lean
def rootTriple : Fin 3 → ℤ
| ⟨0, _⟩ => 3
| ⟨1, _⟩ => 4
| ⟨2, _⟩ => 5

def BerggrenChild (u v : Fin 3 → ℤ) : Prop :=
  v = berggrenA u ∨ v = berggrenB u ∨ v = berggrenC u

theorem primitive_triple_has_unique_parent
  {v : Fin 3 → ℤ}
  (hv : BerggrenPrimitive v)
  (hroot : v ≠ rootTriple) :
  ∃! u : Fin 3 → ℤ, BerggrenPrimitive u ∧ BerggrenChild u v
```

This theorem upgrades “the tree generates all triples” into an actual **free rooted tree structure** on primitive triples. That is the mathematically meaningful step.

### Theorem C: No collisions / injectivity of path coding

Define words in the alphabet `{A,B,C}` and their action on the root. Then prove distinct reduced words yield distinct primitive triples.

Suggested type skeleton:
```lean
inductive BerggrenGen
| A | B | C
deriving DecidableEq

def BerggrenWord := List BerggrenGen

def actWord : BerggrenWord → (Fin 3 → ℤ) → (Fin 3 → ℤ)
| [], v => v
| g :: w, v => actWord w (actGen g v)

theorem berggren_word_injective_on_root :
  Function.Injective (fun w : BerggrenWord => actWord w rootTriple)
```

This is stronger than uniqueness of parent because it gives a canonical code for every primitive triple. It is the bridge to symbolic dynamics and algorithmic compression.

### Theorem D: Matrix determinant / special linear embedding

If your chosen Berggren matrices lie in `SL(3, ℤ)`, prove it exactly.

```lean
theorem berggren_generator_det_one (g : BerggrenGen) :
  Matrix.det (genMatrix g) = 1
```

and ideally:

```lean
theorem berggren_word_matrix_mem_SL3 (w : BerggrenWord) :
  Matrix.det (wordMatrix w) = 1
```

This matters because it places the Berggren dynamics inside a certified arithmetic matrix semigroup and enables future transfer from homogeneous dynamics and thin orbit theory.

### Theorem E: Hypotenuse monotonicity and depth lower bounds

You already have `berggren_depth_prime`. Push this toward a dynamical complexity statement: depth controls size.

```lean
def depth : BerggrenWord → ℕ := List.length

theorem hypotenuse_strict_growth_of_child
  {u v : Fin 3 → ℤ} :
  BerggrenPrimitive u → BerggrenChild u v → u 2 < v 2
```

and then

```lean
theorem depth_le_hypotenuse_growth
  (w : BerggrenWord) :
  depth w ≤ Int.natAbs ((actWord w rootTriple) 2)
```

A sharper exponential lower bound would be much more interesting if provable:
```lean
theorem hypotenuse_exponential_lower_bound
  ∃ r > (1 : ℝ), ∀ w : BerggrenWord,
    r ^ depth w ≤ Int.toReal ((actWord w rootTriple) 2)
```

Even a weaker certified version would be significant, because it turns the tree into a complexity-controlled enumeration scheme.

## Secondary Arithmetic Target: same-hypotenuse multiplicity and factorization structure

The theorem `paired_triples_share_hypotenuse` suggests a route toward arithmetic classification of repeated hypotenuse values.

A serious theorem to aim for:

```lean
def TripleOfHypotenuse (c : ℤ) :=
  {v : Fin 3 → ℤ // PrimitiveTriple v ∧ v 2 = c}

theorem primitive_triples_with_fixed_hypotenuse_finite
  (c : ℤ) :
  Set.Finite {v : Fin 3 → ℤ | PrimitiveTriple v ∧ v 2 = c}
```

Then, if feasible, classify cardinality in terms of prime factorization of `c` when `c > 0` and odd. Even a lower/upper bound in terms of the number of primes `≡ 1 [MOD 4]` would be excellent.

This would connect the Berggren tree to the sum-of-two-squares theorem and give a rigorous explanation of hypotenuse collisions.

## Lean 4 Type Signature Suggestions

You asked for precise signatures. Here are good formal targets.

```lean
def IsPrimitivePythagorean (a b c : ℤ) : Prop :=
  a^2 + b^2 = c^2 ∧ Int.gcd (Int.gcd a b) c = 1 ∧ 0 < c

theorem berggrenA_preserves_primitive
  {a b c : ℤ} :
  IsPrimitivePythagorean a b c →
  IsPrimitivePythagorean
    (a - 2*b + 2*c)
    (2*a - b + 2*c)
    (2*a - 2*b + 3*c)

theorem berggrenB_preserves_primitive
  {a b c : ℤ} :
  IsPrimitivePythagorean a b c →
  IsPrimitivePythagorean
    (a + 2*b + 2*c)
    (2*a + b + 2*c)
    (2*a + 2*b + 3*c)

theorem berggrenC_preserves_primitive
  {a b c : ℤ} :
  IsPrimitivePythagorean a b c →
  IsPrimitivePythagorean
    (-a + 2*b + 2*c)
    (-2*a + b + 2*c)
    (-2*a + 2*b + 3*c)
```

Unique parent, coordinate form:
```lean
theorem unique_parent_of_nonroot_primitive
  {a b c : ℤ}
  (h : IsPrimitivePythagorean a b c)
  (hroot : (a,b,c) ≠ (3,4,5)) :
  ∃! a' b' c' : ℤ,
    IsPrimitivePythagorean a' b' c' ∧
    ((a,b,c) =
      (a' - 2*b' + 2*c', 2*a' - b' + 2*c', 2*a' - 2*b' + 3*c') ∨
     (a,b,c) =
      (a' + 2*b' + 2*c', 2*a' + b' + 2*c', 2*a' + 2*b' + 3*c') ∨
     (a,b,c) =
      (-a' + 2*b' + 2*c', -2*a' + b' + 2*c', -2*a' + 2*b' + 3*c'))
```

If tuple syntax becomes painful, package triples in a structure:
```lean
structure PythTriple where
  a : ℤ
  b : ℤ
  c : ℤ
```

That may dramatically reduce proof friction.

## Proof Strategy Architecture

### Strategy 1: Lorentz-form / matrix-semigroup route
Most promising.

1. Define the quadratic form `Q(a,b,c) = a^2 + b^2 - c^2` and show each Berggren matrix preserves `Q`.
2. Prove each generator has determinant `1`, hence lies in `SL(3,ℤ)` and acts invertibly on the integral light cone `Q=0`.
3. Show the inverse images of a positive primitive triple under the three inverses have exactly one admissible positive primitive predecessor, except at the root.

Why this is best: it turns ad hoc algebra into linear algebra plus cone geometry. It is the cleanest route to uniqueness, no-collision, and future generalization to other norm forms.

### Strategy 2: Euclid-parameter descent route
Potentially easier for the unique-parent theorem.

1. Use the standard parametrization of primitive triples:
   \[
   (a,b,c) = (m^2-n^2,\,2mn,\,m^2+n^2)
   \]
   with coprime `m > n > 0`, opposite parity.
2. Identify how each Berggren generator transforms the parameter pair `(m,n)` by a positive unimodular `2×2` matrix action.
3. Prove each admissible `(m,n)` has a unique predecessor under this induced action, yielding unique parent for triples.

Why this is attractive: uniqueness often becomes a continued-fraction or Stern–Brocot style argument on coprime pairs. This creates a direct bridge to `SL(2,ℤ)` and symbolic coding of rationals.

### Strategy 3: Well-founded descent on hypotenuse
Useful fallback if matrix inverses are cumbersome in Lean.

1. Prove every non-root primitive triple admits at least one parent whose hypotenuse is strictly smaller.
2. Prove two distinct parents cannot map to the same child, using explicit coordinate algebra and gcd constraints.
3. Use well-founded induction on `c : ℕ` to derive existence and uniqueness of ancestry.

Why this works: Lean handles well-founded induction on natural size measures well, and the monotonicity theorem becomes a reusable enumeration certificate.

## Cross-Domain Connections You Must Exploit

### 1. Homogeneous dynamics / thin orbits
The Berggren semigroup is a prototype of a thin orbit inside an arithmetic group. Formalizing injective word coding and determinant-one action sets the stage for later counting theorems, orbit growth, and local-global questions analogous to Apollonian packings.

### 2. Symbolic dynamics and automata
Once you prove word injectivity, the Berggren tree becomes a symbolic dynamical system on a 3-letter alphabet. This opens formal-language questions: regularity of congruence classes, automata for parity patterns, and entropy/growth rates.

### 3. Analytic number theory
The “prime distribution along hypotenuse lengths” should not be treated as a vague conjectural slogan. The realistic formal target is to establish exact congruence restrictions and factorization constraints for hypotenuse values, then formulate falsifiable hypotheses about prime incidence at depth `n`. Build from `berggren_depth_prime`.

### 4. Certified algorithms / computational number theory
The unique-parent theorem and hypotenuse monotonicity give a formally verified enumeration algorithm for primitive triples without duplication. This is not just programming: it is a correctness theorem for arithmetic generation, relevant to certified search, exact geometry, and Diophantine benchmarking.

### 5. Lorentzian geometry
The equation `a^2 + b^2 = c^2` defines the integer light cone for signature `(2,1)`. The Berggren action is a discrete Lorentzian dynamics. This perspective is unexpected and powerful.

## Concrete Build Plan from Catalog Theorems

- Use `berggren_is_pythagorean`, `berggren_preserves_pythagorean`, and `berggren_map_pythagorean` as the preservation layer for `Q=0`.
- Use `paired_triples_share_hypotenuse` to isolate and classify collision phenomena at fixed `c`.
- Use `berggren_depth_prime` as a seed for relating arithmetic properties of `c` to tree depth or path structure. Even if a full prime-distribution theorem is out of reach, derive rigorous congruence and depth constraints first.

Do not merely reprove closure. Closure is infrastructure. The actual theorem is **free, unique, arithmetic Berggren dynamics**.

## High-Value Definitions to Introduce

```lean
def PrimitiveHypotenuseSet (n : ℤ) : Set (Fin 3 → ℤ) :=
  {v | PrimitiveTriple v ∧ v 2 = n}

def IsBerggrenRoot (v : Fin 3 → ℤ) : Prop :=
  v = rootTriple

def BerggrenReachable (v : Fin 3 → ℤ) : Prop :=
  ∃ w : BerggrenWord, actWord w rootTriple = v

def BerggrenDepth (v : Fin 3 → ℤ) : ℕ :=
  sInf {n | ∃ w : BerggrenWord, w.length = n ∧ actWord w rootTriple = v}
```

Then target:
```lean
theorem reachable_iff_primitive :
  ∀ v : Fin 3 → ℤ, BerggrenReachable v ↔ BerggrenPrimitive v
```
This is a flagship theorem if done cleanly.

## What Would Count as a Breakthrough Here

Not “another theorem about Pythagorean triples.” The breakthrough is a formal arithmetic-dynamical package showing:

- the Berggren tree is a free semigroup action on primitive triples,
- each primitive triple has a unique code and unique ancestry,
- the action is linear, determinant-one, and light-cone preserving,
- hypotenuse growth is monotone and complexity-controlled,
- fixed-hypotenuse multiplicity can be studied through certified orbit structure.

This would create a reusable formal platform for thin orbits, Diophantine dynamics, and certified enumeration in Lean.

## Application Keywords

Pythagorean triples, Berggren tree, primitive triples, `SL(3,ℤ)`, Lorentz form, thin orbits, symbolic dynamics, arithmetic semigroups, sum of two squares, certified enumeration, Diophantine dynamics, matrix group actions, formal verification, computational number theory, automata on arithmetic trees.

## Deliverables

1. Lean 4 file(s) proving at least one flagship structural theorem from A–E.
2. Supporting definitions for primitive triples, Berggren generators, and word actions.
3. Minimal `sorry`; if blocked, isolate the obstruction into small lemmas rather than leaving large gaps.
4. `FUTURE_DIRECTIONS.md` with **3–5 precise falsifiable scientific hypotheses**.

## Required FUTURE_DIRECTIONS.md content

Include 3–5 hypotheses of the following form:

1. **Depth-growth hypothesis**  
   Conjecture: there exists `λ > 1` such that for every Berggren word `w`,  
   `c(w) ≥ λ^(length w)`.  
   Test: compute exact minimal hypotenuse at depth `n` for `n ≤ 20` and compare with candidate `λ`.

2. **Congruence equidistribution hypothesis**  
   Conjecture: for any fixed odd modulus `m`, primitive hypotenuse values at depth `n` become asymptotically equidistributed among admissible residue classes mod `m`.  
   Test: enumerate depth layers and perform χ² deviation analysis.

3. **Fixed-hypotenuse multiplicity hypothesis**  
   Conjecture: the number of primitive triples with hypotenuse `c` is determined by the number of prime factors `p ≡ 1 mod 4` of `c`.  
   Test: compare exact counts for `c ≤ N` against factorization-based formula candidates.

4. **Automaton-recognizable path property hypothesis**  
   Conjecture: the set of Berggren words whose hypotenuse is prime is not regular, but its reduction modulo any fixed `m` is automatic.  
   Test: generate DFA candidates for residue-class properties and search for pumping obstructions for primality.

5. **Parent-selection monotonicity hypothesis**  
   Conjecture: the unique-parent map decreases a secondary energy functional besides hypotenuse, yielding a canonical gradient flow on primitive triples.  
   Test: define candidate energies from coordinates and verify strict descent computationally on large samples.

Be concrete. Make each hypothesis testable and refutable. This is not administrative overhead; it is the seed for the next research cycle.

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
