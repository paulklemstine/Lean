## Assignment: Quantum Pythagorean Teleportation: Berggren Orbits as Clifford Circuits

Mode: **prove**

This direction is only worth pursuing if we cut through the metaphor and isolate a formally defensible core that could become a genuine new bridge theorem between arithmetic group actions, finite symplectic geometry, and quantum information. The original phrasing is too ambitious as stated: “categorical equivalence between Pythagorean lattices and stabilizer subgroups of the Clifford group” and “primitive triple matrices form universal quantum gates under tropical composition” is not currently plausible in literal full generality, because stabilizer/Clifford circuits are not computationally universal. So the breakthrough move is to formalize the **correct restricted equivalence** and then prove a sharp transport theorem from Berggren dynamics to stabilizer-state reachability and teleportation normal forms.

Your mission is to extract a theorem that is:
1. mathematically precise,
2. Lean-formalizable with Mathlib,
3. genuinely cross-domain,
4. strong enough to open a new field of arithmetic quantum circuit semantics.

---

## Core Breakthrough Target

### Theorem A: Berggren parity reduction factors through the one-qubit Clifford symplectic action

The deepest viable first theorem is not full categorical equivalence, but a **surjective arithmetic-to-symplectic bridge**.

Let `B₁ B₂ B₃ : Matrix (Fin 3) (Fin 3) ℤ` denote the standard Berggren generators. For a primitive Pythagorean triple `(a,b,c)`, write its parity vector
\[
\pi(a,b,c) := (a \bmod 2,\; b \bmod 2) \in (\mathbb Z/2\mathbb Z)^2.
\]
Primitive triples satisfy exactly one leg even and one odd, so the parity data lies in the two nonzero isotropic classes relevant to the mod-2 symplectic picture.

Define the Berggren orbit graph on primitive triples, and define the mod-2 reduction of a Berggren generator by acting on the first two coordinates and projecting to `SL(2, 𝔽₂)`, which is canonically isomorphic to the one-qubit Clifford quotient `Clifford₁ / Pauli₁ ≃ Sp(2, 𝔽₂)`.

### Precise theorem statement
Prove that the Berggren action on primitive triples induces a well-defined action on parity classes, and this induced action lands in `SL(2, ZMod 2)` and generates the full group.

Informally:
\[
\langle B_1,B_2,B_3 \rangle \curvearrowright \{\text{primitive triples}\}
\quad\Longrightarrow\quad
SL(2,\mathbb F_2)\curvearrowright (\mathbb F_2)^2 \setminus \{0\},
\]
with surjective image.

### Lean 4 target shape
You will likely need to define some auxiliary objects, but the theorem should end up near this shape:

```lean
open Matrix

def tripleParity (v : Fin 3 → ℤ) : Fin 2 → ZMod 2 :=
  fun i => (v ⟨i.1, by omega⟩ : ZMod 2)

def IsPrimTripleVec (v : Fin 3 → ℤ) : Prop :=
  v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2 ∧ Int.gcd (Int.gcd (v 0) (v 1)) (v 2) = 1

def BerggrenGenerators : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
-- fill with the three classical Berggren matrices

def mod2FirstTwo (M : Matrix (Fin 3) (Fin 3) ℤ) : Matrix (Fin 2) (Fin 2) (ZMod 2) :=
  fun i j => (M (Fin.castLT i (by omega)) (Fin.castLT j (by omega)) : ZMod 2)

theorem berggren_parity_action_well_defined
  (M : Matrix (Fin 3) (Fin 3) ℤ)
  (hM : M ∈ Subgroup.closure (Set.range BerggrenGenerators))
  (v : Fin 3 → ℤ)
  (hv : IsPrimTripleVec v) :
  tripleParity (M.mulVec v) ≠ 0 := by
  ...

theorem berggren_mod2_in_sl2
  (i : Fin 3) :
  mod2FirstTwo (BerggrenGenerators i) ∈ Matrix.SpecialLinearGroup (Fin 2) (ZMod 2) := by
  ...

theorem berggren_mod2_surjective :
  Subgroup.closure (Set.range (fun i => mod2FirstTwo (BerggrenGenerators i))) =
    ⊤ := by
  ...
```

A more representation-theoretic variant, if easier in Lean:

```lean
theorem berggren_generators_generate_SL2_ZMod2 :
  Subgroup.closure (Set.range (fun i => mod2FirstTwo (BerggrenGenerators i))) =
    ⊤ := by
  ...
```

This is the first honest “quantum bridge” theorem: Berggren arithmetic generates exactly the symplectic skeleton underlying one-qubit Clifford transport.

### Why this is a breakthrough
This says that the ancient Berggren tree is not merely a number-theoretic parametrization, but an **arithmetic lift of finite quantum symplectic dynamics**. That opens a field: arithmetic circuit semantics, where integer orbits model stabilizer propagation.

---

## Second Breakthrough Target

### Theorem B: Primitive triples admit a stabilizer-state encoding invariant under Berggren descendants

Teleportation is fundamentally a stabilizer protocol. The right theorem is therefore an **encoding theorem** from primitive triples to mod-2 stabilizer labels, not universality.

Define a map from primitive triples to nonzero vectors of `(ZMod 2)^2`, for example by parity:
\[
E(a,b,c) = (a \bmod 2,\; b \bmod 2).
\]
Then prove Berggren descendants preserve the admissible stabilizer class set and act transitively on it.

### Precise theorem statement
For every primitive Pythagorean triple `v`, its Berggren orbit projects under `tripleParity` onto the full nonzero orbit of `SL(2, ZMod 2)` acting on `(ZMod 2)^2 \setminus {0}`.

### Lean 4 target shape
```lean
def nonzeroVec2 : Set (Fin 2 → ZMod 2) := {x | x ≠ 0}

theorem primitive_triple_parity_nonzero
  (v : Fin 3 → ℤ) (hv : IsPrimTripleVec v) :
  tripleParity v ∈ nonzeroVec2 := by
  ...

theorem berggren_orbit_projects_to_symplectic_orbit
  (v : Fin 3 → ℤ) (hv : IsPrimTripleVec v) :
  Set.MapsTo tripleParity
    {w | ∃ M ∈ Subgroup.closure (Set.range BerggrenGenerators), w = M.mulVec v}
    (MulAction.orbit (⊤ : Subgroup (Matrix.SpecialLinearGroup (Fin 2) (ZMod 2)))
      (tripleParity v)) := by
  ...
```

If orbit formalization is cumbersome, replace with the explicit finite statement:
```lean
theorem berggren_parity_orbit_is_univ_nonzero
  (v : Fin 3 → ℤ) (hv : IsPrimTripleVec v) :
  {x | ∃ M ∈ Subgroup.closure (Set.range BerggrenGenerators),
      x = tripleParity (M.1.mulVec v)} = {x | x ≠ 0} := by
  ...
```
after choosing the right matrix/group representation.

### Why this matters
This yields a precise arithmetic model of **stabilizer reachability**. In quantum information language, primitive triples become arithmetic labels for nonzero Pauli/stabilizer directions, and Berggren branching becomes a deterministic arithmetic compiler for stabilizer transitions.

---

## Third Breakthrough Target

### Theorem C: Berggren depth gives an optimal normal-form cost for parity-state transport

Do **not** claim “optimal teleportation protocol” in full physical sense. Instead prove an exact combinatorial optimality theorem:

- Berggren tree depth = minimal generator length in the arithmetic presentation.
- Under mod-2 projection, this bounds or exactly computes the minimal symplectic gate count for the induced parity transport.

This is realistic, novel, and powerful.

### Precise theorem statement
For each parity target `x ≠ 0` in `(ZMod 2)^2`, the shortest Berggren word sending the root triple to a triple of parity `x` projects to a shortest word in the induced generating set of `SL(2, ZMod 2)` sending the root parity to `x`.

### Lean 4 target shape
You may need a finite graph metric or word length definition:
```lean
def wordLength {G : Type*} [Group G] (S : Set G) (g : G) : Nat := ...

def rootTriple : Fin 3 → ℤ := ![3,4,5]

theorem berggren_depth_projects_to_minimal_symplectic_cost
  (x : Fin 2 → ZMod 2) (hx : x ≠ 0) :
  ∃ n : Nat,
    (∃ w, wordLength (Set.range BerggrenGenerators) w = n ∧
      tripleParity (w.mulVec rootTriple) = x) ∧
    IsLeast
      {m | ∃ g, wordLength (Set.range (fun i => mod2FirstTwo (BerggrenGenerators i))) g = m ∧
           g.mulVec (tripleParity rootTriple) = x}
      n := by
  ...
```

You may simplify this theorem if word metrics are too heavy: prove a finite exhaustive classification over `SL(2, ZMod 2)` by explicit enumeration, then derive minimality by computation.

### Why this matters
This converts Berggren descent into a **compiler optimality theorem**. That is the correct teleportation analogue: arithmetic branching realizes shortest stabilizer transport at the mod-2 level.

---

## Corrected Conceptual Framing

You must explicitly correct the overreach in the original brief:

- **Do not claim universality of Clifford/stabilizer gates.**
- Instead prove that primitive triple dynamics capture the **stabilizer fragment** or **symplectic shadow** of one-qubit Clifford computation.
- If you want “tropical composition,” define it carefully as min-plus matrix combination or weighted path composition on the Berggren tree, and prove a legitimate theorem about shortest-path semantics. Do not assert quantum universality from it.

A good replacement statement is:

> Primitive Berggren dynamics furnish an arithmetic presentation of the finite symplectic control layer of one-qubit stabilizer circuits, and Berggren tree depth computes a canonical transport complexity for parity-labeled stabilizer states.

That is original, believable, and deep.

---

## How to Build on the Catalog Theorems

Use the listed theorems as anchors, not decorations.

1. `root_triple_pythagorean`
   - Use this to instantiate the root object of the Berggren tree concretely.
   - It should seed the base case for orbit constructions and parity computations.

2. `root_triple_is_pythagorean`
   - This likely gives a cleaner proposition-level fact for the root triple.
   - Use it to avoid reproving primitive/Pythagorean validity for the seed.

3. `triple_5_12_13_primitive`
   - This is especially valuable because `(5,12,13)` has parity `(1,0)`, a clean nonzero mod-2 label.
   - Use it as a second explicit witness in transitivity/surjectivity arguments.

4. `berggren_map_pythagorean`
   - This is probably the key closure theorem: Berggren maps preserve the Pythagorean property.
   - Extend its proof pattern to parity and primitive invariance under descendants.

5. `min_primitive_triple`
   - This may support uniqueness/minimality arguments for root or shortest-depth properties.
   - If it gives arithmetic minimality, connect it to shortest-word or canonical-form arguments.

If any of these are weaker than their names suggest, inspect them and adapt. The key is to turn them into:
- root witness,
- closure under Berggren action,
- primitive invariance,
- parity classification,
- minimality/cost.

---

## Proof Strategy Architecture

### Strategy A: Finite reduction and explicit generation computation
This is the most promising route.

1. Define the three Berggren matrices explicitly over `ℤ`.
2. Reduce them mod 2 on the first two coordinates.
3. Compute the resulting `2×2` matrices over `ZMod 2`.
4. Show they generate all of `SL(2, ZMod 2)` by finite enumeration.
5. Prove primitive triples have nonzero parity labels and that Berggren action respects these labels.

Why this is best:
- `SL(2, ZMod 2)` is tiny.
- Lean handles finite case splits and decidable equality well.
- It yields a certified theorem with strong conceptual payoff and low formalization risk.

### Strategy B: Symplectic reinterpretation via determinant preservation
1. Show the reduced Berggren matrices preserve the standard alternating form on `(ZMod 2)^2`.
2. Deduce they land in `Sp(2, ZMod 2)`.
3. Use the classical identity `Sp(2, ZMod 2) = SL(2, ZMod 2)`.
4. Prove surjectivity by exhibiting images of standard generators.

Why this is elegant:
- It aligns directly with Clifford/stabilizer semantics.
- It gives the conceptual theorem, not just the finite brute-force fact.

Risk:
- Formalizing alternating forms and `Sp = SL` may be more overhead than direct enumeration unless Mathlib already makes this easy.

### Strategy C: Orbit-graph semantics and shortest-path optimality
1. Define the Berggren tree as a directed graph on primitive triples.
2. Define the parity projection to the finite graph on nonzero vectors of `(ZMod 2)^2`.
3. Show projection is a graph homomorphism.
4. Compute the target graph diameter and shortest paths explicitly.
5. Lift minimal paths from the finite symplectic graph back to arithmetic witnesses.

Why this is exciting:
- It creates the teleportation/compiler semantics layer.
- It naturally leads to algorithm extraction and visualization.

Risk:
- More infrastructure.
- Better as a second theorem after Strategy A succeeds.

**Recommended order:** A → B → C.

---

## Cross-Domain Connections You Should Make Explicit

### 1. Quantum information / stabilizer formalism
The quotient of the one-qubit Clifford group by phases and Paulis is `Sp(2, 𝔽₂) ≃ SL(2, 𝔽₂) ≃ S₃`. Your theorem identifies Berggren arithmetic with this finite control skeleton. This is the correct quantum bridge.

### 2. Arithmetic dynamics
The Berggren tree is an orbit structure in an arithmetic semigroup. Showing that a finite quantum symmetry is a quotient of this orbit dynamics creates a new paradigm: **arithmetic dynamics as circuit semantics**.

### 3. Tropical / shortest-path algebra
If you formalize “tropical composition” at all, interpret it as shortest-path composition on the Berggren tree or min-plus cost propagation on generator words. Then prove a genuine optimization theorem instead of an unsupported physics metaphor.

### 4. Category theory
If you use categorical language, keep it modest and exact:
- define a category of Berggren-generated orbit states,
- define a category/action groupoid of nonzero `𝔽₂²` states under `SL(2, 𝔽₂)`,
- prove a functor that is full/surjective on objects or factors through a quotient groupoid.

Do **not** claim equivalence unless you actually prove full faithfulness and essential surjectivity.

### 5. Coding theory / symplectic geometry
Stabilizer labels are symplectic data over `𝔽₂`. Primitive-triple parity classes becoming symplectic states suggests a bridge to binary linear codes and finite phase space.

---

## Concrete Lean Definitions Worth Introducing

You should define these cleanly and concretely:

```lean
def isPythagoreanVec (v : Fin 3 → ℤ) : Prop :=
  v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2

def isPrimitiveVec (v : Fin 3 → ℤ) : Prop :=
  Int.gcd (Int.gcd (v 0) (v 1)) (v 2) = 1

def isPrimTripleVec (v : Fin 3 → ℤ) : Prop :=
  isPythagoreanVec v ∧ isPrimitiveVec v

def rootTriple : Fin 3 → ℤ
| 0 => 3
| 1 => 4
| _ => 5
```

Berggren matrices:
```lean
def B1 : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]
def B2 : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]
def B3 : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]
```

Parity projection:
```lean
def tripleParity (v : Fin 3 → ℤ) : Fin 2 → ZMod 2
| 0 => (v 0 : ZMod 2)
| 1 => (v 1 : ZMod 2)
```

Then prove:
- primitive triples have parity `(1,0)` or `(0,1)`,
- Berggren generators preserve primitiveness if available from catalog or reproved,
- reduced Berggren action generates all of `SL(2, ZMod 2)`.

---

## Specific Theorems to Aim to Complete in Lean

### Theorem 1: Primitive parity classification
```lean
theorem primitive_triple_parity_cases
  (v : Fin 3 → ℤ) (hv : IsPrimTripleVec v) :
  tripleParity v = ![1,0] ∨ tripleParity v = ![0,1] := by
  ...
```
This is a strong arithmetic lemma and a clean bridge to nonzero stabilizer labels.

### Theorem 2: Berggren generators preserve primitive parity admissibility
```lean
theorem berggren_generator_preserves_nonzero_parity
  (i : Fin 3) (v : Fin 3 → ℤ) (hv : IsPrimTripleVec v) :
  tripleParity ((BerggrenGenerators i).mulVec v) ≠ 0 := by
  ...
```

### Theorem 3: Mod-2 Berggren image generates `SL(2, ZMod 2)`
```lean
theorem berggren_mod2_generates_sl2 :
  Subgroup.closure {g | ∃ i : Fin 3, g = mod2FirstTwo (BerggrenGenerators i)} = ⊤ := by
  ...
```

### Theorem 4: Orbit surjectivity on nonzero parity states
```lean
theorem berggren_parity_orbit_full
  (v : Fin 3 → ℤ) (hv : IsPrimTripleVec v) :
  ∀ x : Fin 2 → ZMod 2, x ≠ 0 →
    ∃ M ∈ Subgroup.closure (Set.range BerggrenGenerators),
      tripleParity (M.1.mulVec v) = x := by
  ...
```

This is your flagship theorem if you can land it.

---

## Experimental / Computational Component

Before proving, run small computations:
- Explicitly reduce `B1, B2, B3` mod 2.
- Enumerate `SL(2, ZMod 2)` and verify generation.
- Compute parity labels for the first few Berggren descendants of `(3,4,5)` and `(5,12,13)`.
- Check whether parity projection already distinguishes generator effects.

If needed, include a tiny `demo.py` to sanity-check generator words before formalization, but the final deliverable is Lean.

---

## What Not to Waste Time On

- Do not attempt full quantum teleportation semantics with Hilbert spaces unless you already have the infrastructure.
- Do not define the full Clifford group over complex matrices in Lean unless absolutely necessary.
- Do not claim categorical equivalence with stabilizer subgroups unless you can prove a literal equivalence.
- Do not pursue “universal quantum gates” through Clifford-only data; that is mathematically false.

The real win is sharper:
**Berggren arithmetic is a quotient-lift of stabilizer symplectic dynamics.**

---

## Revolutionary Significance

If proved, this creates a new subject:
### Arithmetic Quantum Semantics
A theory where classical integer orbit structures encode finite quantum control laws.

This could lead to:
- arithmetic compilers for stabilizer protocols,
- number-theoretic models of circuit normal forms,
- tropical shortest-path semantics for quantum control fragments,
- bridges between Pythagorean parametrization, symplectic coding theory, and categorical quantum mechanics.

The point is not just a cute analogy. The point is a certified formal theorem that ancient Diophantine dynamics projects onto modern quantum information symmetries.

---

## Deliverables

1. Lean file(s) formalizing the core definitions and proving at least Theorem 1 + Theorem 3.
2. If possible, Theorem 4 as the flagship orbit theorem.
3. A short `ARTICLE.md` or `RESEARCH_PAPER.md` explaining the arithmetic-to-symplectic bridge.
4. A **required** `FUTURE_DIRECTIONS.md` containing 3–5 concrete breakthrough next steps.

---

## Required FUTURE_DIRECTIONS.md

You must produce `FUTURE_DIRECTIONS.md` with 3–5 specific next-step projects at breakthrough level, for example:
1. Lift the mod-2 bridge from one-qubit symplectic dynamics to two-qubit stabilizer phase space `Sp(4, 𝔽₂)`.
2. Replace parity labels with full Gaussian integer residue data to recover richer Clifford invariants.
3. Define a Berggren groupoid quotient and prove a genuine functorial equivalence with a finite stabilizer action groupoid.
4. Tropicalize Berggren word metrics and prove a min-plus compiler optimality theorem for stabilizer transport.
5. Connect primitive triple orbits to binary self-dual code symmetries via finite symplectic embeddings.

These should not be vague. They should be theorem-grade.

---

## Application Keywords

Pythagorean triples; Berggren tree; arithmetic dynamics; Clifford group; stabilizer formalism; symplectic geometry over finite fields; `SL(2, 𝔽₂)`; quantum teleportation normal forms; tropical shortest paths; categorical quantum mechanics; formal verification; Lean 4; Mathlib; orbit semigroups; compiler optimality; finite phase space.

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
