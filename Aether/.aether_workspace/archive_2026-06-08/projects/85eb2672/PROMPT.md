## Assignment: Pythagorean Triple Group Structure

**Mode:** `prove`

Aristotle, do not merely show that the Berggren tree generates primitive triples. That is known folklore. The breakthrough target is to expose the **hidden algebraic and dynamical architecture** of the tree: a free-semigroup / groupoid action on integer Lorentz space, arithmetic propagation laws along branches, and a computational framework that turns the tree into an engine for certified search and prime-pattern experiments.

You should treat the Berggren tree not as a combinatorial curiosity, but as a **discrete light-cone dynamics** on the quadratic surface
\[
x^2+y^2-z^2=0,
\]
with primitive Pythagorean triples as integral null vectors. The aim is to formalize a structure theorem that makes this dynamics reusable across number theory, matrix groups, automata, and experimental mathematics.

---

## Core Breakthrough Objectives

You must prove **at least 3 substantial theorems** with nontrivial proof structure, and define **at least one genuinely new concept** not already in the catalog.

Build explicitly on these verified ingredients:

- `berggren_preserves_pythagorean_mod`
  from `FINAL/Pythagorean/BerggrenDynamicsArithmetic.lean`
- `berggren_is_pythagorean`
  from `FINAL/Pythagorean/BerggrenHarmonicTropical.lean`
- `berggren_preserves_pythagorean`
  from `FINAL/Pythagorean/BerggrenHolographicDuality.lean`
- `berggren_children_are_pythagorean`
  from `FINAL/Pythagorean/HarmonicMusicTheory.lean`
- `berggren_depth_prime`
  from `FINAL/Pythagorean/PythagoreanFactoring.lean`
- `prime_dvd_hypotenuse_of_primitive_triple_mod4`
  from `FINAL/Pythagorean/TropicalBerggrenZeta.lean`

Your task is to synthesize these into a new formal theory of **Berggren dynamics as arithmetic group action**.

---

## New Definitions to Introduce

You should define at least one or more of the following, in Lean-native form.

### 1. Berggren word action
A finite word in the three Berggren generators acting on a root triple.

Suggested Lean-facing structure:
```lean
abbrev Triple := Fin 3 → ℤ

inductive BerggrenGen
| A | B | C
deriving DecidableEq, Repr

abbrev BerggrenWord := List BerggrenGen

def actsOnTriple : BerggrenWord → Triple → Triple := ...
```

### 2. Primitive null triple
A triple that is Pythagorean, primitive, and positive in the geometric sense.
```lean
def IsPrimitiveTriple (v : Triple) : Prop := ...
def IsNullLorentz (v : Triple) : Prop := v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2
def IsPositiveTriple (v : Triple) : Prop := 0 < v 0 ∧ 0 < v 1 ∧ 0 < v 2
def IsPrimitiveNullPositive (v : Triple) : Prop :=
  IsNullLorentz v ∧ IsPrimitiveTriple v ∧ IsPositiveTriple v
```

### 3. Berggren ancestry / reachability groupoid
A relation encoding “reachable by a Berggren word,” with composition as groupoid-like concatenation.
```lean
def BerggrenReachable (u v : Triple) : Prop := ∃ w : BerggrenWord, actsOnTriple w u = v
```

If full groupoid formalization is too heavy in the available library, formalize the **precategory skeleton**: identities by empty word, composition by list append, and associativity of reachability witnesses.

This is already mathematically meaningful and Lean-realistic.

---

## Precise Theorem Targets

You should aim to prove the following or closely equivalent statements.

---

### Theorem 1: Reachability is a transitive arithmetic dynamics preserving the null cone

This is the foundational algebraic theorem: Berggren words define a semigroup action preserving the Pythagorean quadratic form.

**Mathematical statement**
For every Berggren word \(w\) and every integer triple \(v\), if \(v\) is Pythagorean, then \(w \cdot v\) is Pythagorean. Moreover, reachability from a fixed root is transitive under word concatenation.

**Lean 4 type signature**
```lean
theorem berggren_word_preserves_pythagorean
    (w : BerggrenWord) (v : Triple)
    (h : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2) :
    (actsOnTriple w v) 0 ^ 2 + (actsOnTriple w v) 1 ^ 2 = (actsOnTriple w v) 2 ^ 2 := by
  ...

theorem berggren_reachable_trans
    {u v w : Triple}
    (huv : BerggrenReachable u v)
    (hvw : BerggrenReachable v w) :
    BerggrenReachable u w := by
  ...
```

**Why this matters**
This upgrades isolated preservation lemmas into a reusable formal dynamical system. Once this exists, every arithmetic property can be studied as an invariant, monotone statistic, or cocycle on Berggren words.

---

### Theorem 2: Modular invariants propagate along the entire Berggren tree

Use the mod-\(m\) preservation theorem to show that any root congruence class determines a full congruence class pattern for descendants.

**Mathematical statement**
For every modulus \(m \neq 0\), every Berggren word preserves the Pythagorean congruence relation modulo \(m\). In particular, all descendants of \((3,4,5)\) remain on the modular null cone.

**Lean 4 type signature**
```lean
theorem berggren_word_preserves_pythagorean_mod
    (m : ℕ) [NeZero m]
    (w : BerggrenWord) (v : Triple)
    (h : (v 0 : ZMod m)^2 + (v 1 : ZMod m)^2 = (v 2 : ZMod m)^2) :
    ((actsOnTriple w v) 0 : ZMod m)^2 + ((actsOnTriple w v) 1 : ZMod m)^2
      = ((actsOnTriple w v) 2 : ZMod m)^2 := by
  ...

theorem root_descendants_on_modular_nullcone
    (m : ℕ) [NeZero m] (w : BerggrenWord) :
    ((actsOnTriple w rootTriple) 0 : ZMod m)^2 + ((actsOnTriple w rootTriple) 1 : ZMod m)^2
      = ((actsOnTriple w rootTriple) 2 : ZMod m)^2 := by
  ...
```

Here `rootTriple` can be your chosen formalization of \((3,4,5)\).

**Why this matters**
This is the doorway to finite-state and automata-theoretic analysis of the tree. Mod-\(m\) images of Berggren dynamics define a finite directed graph, opening computational experiments on periodicity, mixing, and local-global obstructions.

---

### Theorem 3: Prime divisors of primitive hypotenuses obey mod-4 constraints along Berggren descendants

This should turn the catalog theorem about prime divisors of primitive hypotenuses into a transport theorem over Berggren reachability.

**Mathematical statement**
If a triple is primitive and reachable in the Berggren tree from the root, then every odd prime dividing its hypotenuse is congruent to \(1 \pmod 4\).

**Lean 4 type signature**
```lean
theorem odd_prime_dvd_hypotenuse_of_reachable_primitive_triple_mod4
    {v : Triple}
    (hreach : BerggrenReachable rootTriple v)
    (hprim : IsPrimitiveTriple v)
    {p : ℕ}
    (hp : Nat.Prime p)
    (hodd : p % 2 = 1)
    (hdiv : p ∣ Int.natAbs (v 2)) :
    p % 4 = 1 := by
  ...
```

**Why this matters**
This makes the tree into a certified arithmetic sieve. It says the dynamical generation process is compatible with a deep local restriction on prime support. That is the first step toward a formal “Berggren zeta mechanism” where branch statistics encode arithmetic laws.

---

### Theorem 4: No nontrivial Berggren word fixes a positive primitive triple

This is a strong structural theorem and much more interesting than mere preservation.

**Mathematical statement**
If a Berggren word sends a positive primitive triple to itself, then the word must be empty.

A realistic version in Lean is to prove a strict monotonicity invariant, such as growth of the hypotenuse, for every nonempty word acting on positive primitive triples.

**Lean 4 type signature**
```lean
theorem berggren_nonempty_word_strictly_increases_hypotenuse
    (w : BerggrenWord) (hw : w ≠ [])
    (v : Triple)
    (hpos : IsPositiveTriple v)
    (hpyth : IsNullLorentz v) :
    v 2 < (actsOnTriple w v) 2 := by
  ...

theorem berggren_no_nontrivial_fixed_point
    (w : BerggrenWord) (hw : w ≠ [])
    (v : Triple)
    (hpos : IsPositiveTriple v)
    (hpyth : IsNullLorentz v) :
    actsOnTriple w v ≠ v := by
  ...
```

**Why this matters**
This identifies the Berggren action as a genuinely expanding arithmetic dynamical system. That is the structural input needed for uniqueness of ancestry, acyclicity, entropy-style invariants, and algorithmic enumeration without duplication.

---

### Theorem 5: Finite-state reduction of Berggren dynamics modulo m

This is your cross-domain theorem: number theory + automata / dynamical systems / computation.

**Mathematical statement**
For each modulus \(m\), Berggren words induce a finite transition system on \((\mathbb{Z}/m\mathbb{Z})^3\), and the modular image of the Berggren tree from the root lies in the finite set of modular null vectors.

**Lean 4 type signature**
```lean
def modState (m : ℕ) := Fin 3 → ZMod m

def actsOnModState (m : ℕ) [NeZero m] : BerggrenWord → modState m → modState m := ...

theorem berggren_mod_state_closed
    (m : ℕ) [NeZero m]
    (w : BerggrenWord) (v : modState m)
    (h : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2) :
    (actsOnModState m w v) 0 ^ 2 + (actsOnModState m w v) 1 ^ 2 = (actsOnModState m w v) 2 ^ 2 := by
  ...
```

**Why this matters**
This converts an infinite arithmetic tree into a finite automaton modulo \(m\). That opens experimental mathematics on orbit graphs, stationary distributions, and symbolic coding of primitive triples.

---

## Proof Strategy Architecture

You must not provide only one route. Build the file around 2–3 possible strategies, and choose one as primary.

### Strategy A: Induction on Berggren words
Most promising for the preservation and reachability theorems.

1. Define `actsOnTriple` recursively on `List BerggrenGen`.
2. Prove one-step preservation for each generator using existing catalog theorems like `berggren_preserves_pythagorean` and `berggren_preserves_pythagorean_mod`.
3. Induct on the word:
   - base case `[]`: identity action;
   - inductive step `g :: w`: apply one-step preservation, then the induction hypothesis.
4. For transitivity of reachability, concatenate words and prove action respects append:
```lean
theorem actsOnTriple_append :
  actsOnTriple (w₁ ++ w₂) v = actsOnTriple w₂ (actsOnTriple w₁ v)
```
or the analogous convention depending on your recursion order.

**Why most promising:** It aligns perfectly with Lean’s recursive strengths and converts the tree into a compositional object.

---

### Strategy B: Matrix-semigroup / Lorentz form approach
Best for the no-fixed-point and structural theorems.

1. Represent each Berggren generator as an explicit `Matrix (Fin 3) (Fin 3) ℤ`.
2. Define the quadratic form matrix
   \[
   Q = \mathrm{diag}(1,1,-1)
   \]
   and prove each generator preserves the form:
   \[
   M^\top Q M = Q.
   \]
3. Deduce preservation of the null cone by matrix algebra.
4. Prove positivity/growth by inspecting the third coordinate of each generator on positive triples and using `linarith`, `omega`, `nlinarith`, or explicit `calc` chains.
5. Use strict growth of the hypotenuse to exclude fixed points and cycles.

**Why powerful:** This reveals the hidden relation to the integral Lorentz group \(O(2,1;\mathbb Z)\), which is the conceptual upgrade from tree combinatorics to arithmetic geometry.

---

### Strategy C: Descent / contradiction on positive primitive triples
Most useful for uniqueness and anti-cycle statements.

1. Define a size measure, ideally `Int.natAbs (v 2)` or a lexicographic norm.
2. Show every nontrivial generator strictly increases the hypotenuse on positive triples.
3. Suppose a nonempty word fixes a triple; derive an infinite strictly increasing chain returning to itself, contradiction.
4. For uniqueness-of-ancestry style lemmas, combine monotonicity with primitive positivity and a minimal-counterexample argument.

**Why valuable:** It gives by-contradiction proofs with real arithmetic substance, satisfying the depth requirement and creating tools for future uniqueness theorems.

---

## Cross-Domain Connections You Must Explicitly Develop

At least one theorem and part of the exposition must connect Pythagorean triples to a different field.

### 1. Arithmetic dynamics / symbolic dynamics
Interpret the Berggren tree as a **3-shift symbolic dynamical system** on words in generators, with finite-state reductions modulo \(m\).

Potential statement:
- modulo \(m\), the orbit of the root under Berggren words is a finite directed graph;
- reachable modular states satisfy the null-cone equation.

This connects number theory to automata, symbolic dynamics, and computational complexity.

### 2. Lorentzian geometry / discrete physics
The form \(x^2+y^2-z^2\) is a Minkowski metric in signature \((2,1)\). Berggren generators preserving the null cone are discrete Lorentz transformations.

Potential theorem/exposition:
- primitive triples are integral light-like vectors;
- Berggren dynamics is a discrete causal evolution increasing “time” \(c\).

This connects number theory to relativity-inspired geometry and lattice physics.

### 3. Spectral graph / random walk viewpoint
Build the modular reduction graph and experimentally study mixing or orbit coverage.

Potential computational theorem:
- the graph of reachable mod-\(m\) null states is finite and algorithmically enumerable.

This connects to expander heuristics, random walks, and arithmetic statistics.

---

## Strongly Recommended Additional Theorems

These are not mandatory, but any one of them would elevate the project.

### A. Hypotenuse monotonicity for each generator
```lean
theorem berggren_gen_increases_hypotenuse
    (g : BerggrenGen) (v : Triple)
    (hpos : IsPositiveTriple v)
    (hpyth : IsNullLorentz v) :
    v 2 < (actsOnTriple [g] v) 2 := by
  ...
```

### B. Distinct children theorem
Show the three Berggren children of a positive primitive triple are pairwise distinct.
```lean
theorem berggren_children_pairwise_distinct
    (v : Triple) (hpos : IsPositiveTriple v) (hpyth : IsNullLorentz v) :
    Pairwise fun g₁ g₂ : BerggrenGen => g₁ ≠ g₂ → actsOnTriple [g₁] v ≠ actsOnTriple [g₂] v := by
  ...
```

### C. Primitive preservation theorem
If the parent is primitive, so are all descendants. This may require careful gcd lemmas.
```lean
theorem berggren_word_preserves_primitivity
    (w : BerggrenWord) (v : Triple)
    (hprim : IsPrimitiveTriple v)
    (hpos : IsPositiveTriple v)
    (hpyth : IsNullLorentz v) :
    IsPrimitiveTriple (actsOnTriple w v) := by
  ...
```

This would be major: it converts the tree from a generator of examples into a certified primitive-triple machine.

---

## Computational / Algorithmic Deliverable

You must produce a **verified algorithm**, not just theorem statements.

### Required algorithm
Implement a certified enumerator of Berggren descendants up to hypotenuse bound \(N\), together with proofs of soundness.

Suggested objects:
```lean
def enumerateUpTo (N : ℕ) : List Triple := ...

theorem enumerateUpTo_sound
    {v : Triple} (hv : v ∈ enumerateUpTo N) :
    IsNullLorentz v ∧ Int.natAbs (v 2) ≤ N := by
  ...
```

Stretch goal:
- prove no duplicates under a suitable normal form;
- compute modular orbit statistics;
- compare frequency of prime hypotenuses.

This is the computational backbone for the conjecture-testing cycle.

---

## Conjecture With Testable Prediction

You must state at least one **falsifiable conjecture** and provide a clear computational test in `demo.py`.

### Conjecture 1: Modular equidistribution heuristic
For fixed odd modulus \(m\), the hypotenuse residues of primitive Berggren descendants of depth \(n\) become asymptotically equidistributed among the residues compatible with the null-cone and primitive constraints.

**Computational disproof test**
- Enumerate all descendants up to depth \(n\).
- Collect `c mod m`.
- Compare empirical frequencies across admissible residue classes.
- A large persistent bias as \(n\) grows would disconfirm the conjecture.

### Conjecture 2: Prime hypotenuse branch bias
Among primitive descendants of large depth, the event “hypotenuse is prime” is not uniform across the three first-letter branches \(A,B,C\).

**Computational disproof test**
- Partition descendants by first generator.
- Estimate prime-hypotenuse density up to depth \(n\) or bound \(N\).
- If densities converge numerically to the same value within shrinking error bars, the conjecture fails.

### Conjecture 3: Minimal automaton phenomenon
For certain moduli \(m\), the modular Berggren transition graph on reachable null states is strongly connected.

**Computational disproof test**
- Build the graph modulo \(m\).
- Run SCC decomposition.
- Any failure of strong connectivity disproves the conjecture for that \(m\).

---

## Lean Tactics / Proof Depth Requirements

Your file must contain proofs using several of:

- `induction` on words / depth
- `rcases` on reachability witnesses
- `by_contra` for no-fixed-point or no-cycle arguments
- `field_simp` if you pass through rational parametrizations
- multi-step `calc`
- arithmetic tools such as `linarith`, `nlinarith`, `omega`
- matrix reasoning if you formalize the Lorentz-form preservation route

Do **not** hide the mathematics behind `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is deep and the computational reflection is genuinely the theorem.

---

## Concrete File Vision

A strong final file would contain:

1. Definitions:
   - `Triple`, `BerggrenGen`, `BerggrenWord`
   - `actsOnTriple`
   - `IsPrimitiveTriple`, `IsNullLorentz`, `IsPositiveTriple`
   - `BerggrenReachable`

2. Fundamental lemmas:
   - action of append
   - one-step generator preservation
   - word preservation
   - reachability transitivity

3. Structural theorems:
   - modular preservation
   - strict hypotenuse growth
   - no nontrivial fixed points
   - prime divisor mod-4 transport theorem

4. Computational section:
   - enumerator up to depth / hypotenuse bound
   - correctness theorem
   - modular orbit computation support

This would already be a publishable formal nucleus.

---

## Revolutionary Significance

If you succeed, you will have done more than formalize classical number theory. You will have created a **certified arithmetic dynamics framework** for Pythagorean triples.

This opens:

- **Arithmetic symbolic dynamics:** Berggren words as codes for integral null vectors.
- **Finite automata on Diophantine varieties:** modular orbit graphs of quadratic forms.
- **Discrete Lorentzian geometry over \(\mathbb Z\):** integral light-cone dynamics.
- **Prime statistics on algebraic trees:** experimentally testable branch laws.
- **Certified search algorithms:** exact enumeration of primitive triples with proven correctness.

The follow-on program is enormous: Markov-type trees, Apollonian packings, indefinite quadratic forms, thin groups, and spectral statistics of modular reductions. This is not an incremental exercise. It is the blueprint for a new formal field: **computational arithmetic dynamics of quadratic Diophantine structures**.

---

## Application Keywords

Pythagorean triples; Berggren tree; arithmetic dynamics; symbolic dynamics; Lorentzian lattice; integral null cone; modular automata; thin groups; prime distribution; certified enumeration; matrix semigroups; Diophantine geometry; finite-state reduction; computational number theory; experimental mathematics; discrete relativity.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **`FUTURE_DIRECTIONS.md`**
   - 3–5 falsifiable scientific hypotheses
   - each with a precise computational or theoretical disproof test

2. **`RESEARCH_PAPER.md`**
   - standalone scientific paper
   - must explain definitions, main theorems, proof ideas, significance, and next questions
   - readable without any code access

3. **`ARTICLE.md`**
   - Scientific American style
   - accessible, vivid, concept-driven explanation for a broad audience

4. **A verified algorithm or computational method**
   - certified Berggren enumeration / modular orbit explorer / prime-pattern analyzer

5. **`demo.py`**
   - interactive demonstration of the tree, modular orbit graph, and conjecture tests

Minimize sorry. Prove the hard structure. Build the arithmetic machine.

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
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

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
