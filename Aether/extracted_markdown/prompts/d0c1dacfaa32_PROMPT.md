Soli Deo Gloria

## Assignment: Sums of Three Cubes — Local-Global Geometry Beyond the Mod 9 Obstruction

**Mode:** `prove`

You should not merely repackage the classical congruence obstruction. The real target is to formalize a **local-global architecture** for the Diophantine surface
\[
X_k : x^3+y^3+z^3 = k,
\]
showing that the mod \(9\) obstruction is the first term in a broader geometric story involving affine cubic surfaces, rational/integral points, and a proto-Hasse philosophy. The breakthrough is to make the existing catalog theorem `sum_three_cubes_mod_nine_ne_four_five` the base case of a much richer formal theory.

Your mission is to build a Lean 4 development that turns the “sum of three cubes” problem from a folklore congruence fact into a **formal research platform**: local obstructions, symmetry reductions, cubic-surface parametrizations, and testable density heuristics.

---

## Core Research Vision

For integers \(k\), define representability by
\[
\exists x y z \in \mathbb Z,\quad x^3+y^3+z^3 = k.
\]
It is known heuristically that the only systematic congruence obstruction is \(k \equiv 4,5 \pmod 9\), but this does **not** by itself give a theorem of existence. Your goal is to formalize several genuinely nontrivial structural theorems that isolate:

1. **Necessary local obstructions** in a reusable form,
2. **Symmetry and reduction principles** for the cubic surface \(X_k\),
3. **A bridge to arithmetic geometry** via the affine/projective cubic surface and Hasse-style reasoning,
4. **A computational conjecture** with explicit falsification protocol.

This opens a field: a verified framework for attacking hard Diophantine existence problems through the interaction of modular arithmetic, algebraic identities, and arithmetic geometry.

---

## Catalog Theorems to Build On

Use these explicitly and structurally, not as decorations:

1. `sum_three_cubes_mod_nine_ne_four_five`
   from `Algebra/CubeResidues.lean`

   This should be the foundation for your local obstruction layer. Generalize its use from a standalone theorem into a theorem schema about representability classes.

2. `sum_three_cubes_neg_sum`
   from `Algebra/LocalGlobal.lean`

   Use this to prove sign-symmetry and transport results between \(k\) and \(-k\). This is your first genuine local-global hint.

3. `sum_of_cubes`
   from `Algebra/ChimeraFactoring.lean` and/or `Algebra/Core/ChimeraFactoring.lean`

   Use the factorization
   \[
   x^3+y^3=(x+y)(x^2-xy+y^2)
   \]
   to derive nontrivial reduction lemmas when one variable is constrained, and to connect the three-cube problem to binary cubic forms and divisor structure.

Do not just invoke these once. Build a coherent theory on top of them.

---

## New Definitions You Must Introduce

At least one genuinely new concept is mandatory. I recommend introducing all of the following:

### 1. Local admissibility mod \(n\)
Define the set of residues mod \(n\) representable as three cubes:
```lean
def ThreeCubeLocalAdmissible (n : ℕ) (a : ZMod n) : Prop :=
  ∃ x y z : ZMod n, x^3 + y^3 + z^3 = a
```

### 2. Integral representability
```lean
def SumThreeCubesRep (k : ℤ) : Prop :=
  ∃ x y z : ℤ, x^3 + y^3 + z^3 = k
```

### 3. The affine cubic surface attached to \(k\)
A lightweight structure, even if only as a predicate on triples:
```lean
def OnCubicSurface (k x y z : ℤ) : Prop :=
  x^3 + y^3 + z^3 = k
```

### 4. Hasse-admissibility surrogate
You likely cannot fully formalize adeles in this cycle, but you can define the arithmetic shadow:
```lean
def EverywhereLocallyAdmissible (k : ℤ) : Prop :=
  ∀ n : ℕ, 0 < n → ∃ x y z : ZMod n, x^3 + y^3 + z^3 = (k : ZMod n)
```
or a weaker but still meaningful version restricted to prime powers / selected moduli already manageable in Mathlib.

This is the crucial visionary move: distinguish **integral representability** from **everywhere local admissibility**, making room for a formal Hasse-principle discussion.

---

## Precise Theorem Targets

You must prove at least 3 substantial theorems. Here is a recommended theorem suite.

### Theorem 1: Mod 9 obstruction packaged as local non-admissibility
A structural reformulation of the catalog theorem.

```lean
theorem not_three_cube_local_admissible_mod9_of_eq_four_or_five
    (a : ZMod 9) (h : a = 4 ∨ a = 5) :
    ¬ ThreeCubeLocalAdmissible 9 a
```

and its integer corollary

```lean
theorem sumThreeCubesRep_implies_not_mod9_four_five
    (k : ℤ) (hrep : SumThreeCubesRep k) :
    ¬ ((k : ZMod 9) = 4 ∨ (k : ZMod 9) = 5)
```

**Why this matters:** this turns a one-off congruence theorem into a reusable local obstruction API. Future work can replace `9` by other moduli or p-adic conditions.

---

### Theorem 2: Sign symmetry of representability
Build on `sum_three_cubes_neg_sum`.

```lean
theorem sumThreeCubesRep_neg_iff (k : ℤ) :
    SumThreeCubesRep (-k) ↔ SumThreeCubesRep k
```

A one-way version is weaker; prove the iff.

**Why this matters:** this identifies an involutive symmetry of the Diophantine surface family \(X_k\), reducing search and connecting arithmetic to automorphisms of cubic surfaces.

---

### Theorem 3: Permutation invariance on the cubic surface
Formalize the \(S_3\)-symmetry of the equation.

```lean
theorem onCubicSurface_perm
    (k x y z : ℤ) (σ : Equiv.Perm (Fin 3))
    (h : OnCubicSurface k x y z) :
    OnCubicSurface k
      (![x, y, z] (σ 0))
      (![x, y, z] (σ 1))
      (![x, y, z] (σ 2))
```

If this exact vector syntax is awkward, define a triple permutation action in a simpler way. The point is not notation; it is to prove a genuine symmetry theorem.

**Why this matters:** this is the first geometric theorem in the file. It says \(X_k\) is not just an equation but a symmetric cubic surface under coordinate permutation.

---

### Theorem 4: A reduction lemma from the sum-of-cubes factorization
Exploit `sum_of_cubes` to derive a nontrivial decomposition theorem when one coordinate is isolated.

```lean
theorem sumThreeCubesRep_iff_exists_factorization
    (k z : ℤ) :
    (∃ x y : ℤ, x^3 + y^3 + z^3 = k) ↔
    ∃ s q : ℤ, s * q = k - z^3
      ∧ ∃ x y : ℤ, x + y = s ∧ x^2 - x*y + y^2 = q
```

You may need to adjust the exact statement, but it must genuinely use `sum_of_cubes` and produce a bridge from the three-cube problem to factorization/binary quadratic constraints.

**Why this matters:** this connects additive Diophantine geometry to multiplicative algebraic structure. It opens a route to divisor-based search algorithms and to binary cubic form methods.

---

### Theorem 5: Local-global implication
A theorem stating representability implies local admissibility.

```lean
theorem sumThreeCubesRep_implies_everywhereLocallyAdmissible
    (k : ℤ) (h : SumThreeCubesRep k) :
    EverywhereLocallyAdmissible k
```

You may need a slightly weaker definition if full `∀ n` is cumbersome; even
```lean
∀ n > 0, ThreeCubeLocalAdmissible n (k : ZMod n)
```
is already strong.

**Why this matters:** this is the formal seed of the Hasse principle for this problem. It does not solve the global problem, but it cleanly separates local necessity from global sufficiency.

---

## Lean 4 Type Signatures

Use these or close variants:

```lean
def SumThreeCubesRep (k : ℤ) : Prop :=
  ∃ x y z : ℤ, x^3 + y^3 + z^3 = k

def ThreeCubeLocalAdmissible (n : ℕ) (a : ZMod n) : Prop :=
  ∃ x y z : ZMod n, x^3 + y^3 + z^3 = a

def OnCubicSurface (k x y z : ℤ) : Prop :=
  x^3 + y^3 + z^3 = k

def EverywhereLocallyAdmissible (k : ℤ) : Prop :=
  ∀ n : ℕ, 0 < n → ThreeCubeLocalAdmissible n (k : ZMod n)

theorem sumThreeCubesRep_implies_not_mod9_four_five
    (k : ℤ) :
    SumThreeCubesRep k →
    ¬ (((k : ZMod 9) = 4) ∨ ((k : ZMod 9) = 5))

theorem sumThreeCubesRep_neg_iff (k : ℤ) :
    SumThreeCubesRep (-k) ↔ SumThreeCubesRep k

theorem sumThreeCubesRep_implies_everywhereLocallyAdmissible
    (k : ℤ) :
    SumThreeCubesRep k → EverywhereLocallyAdmissible k
```

If needed, use `by
  rcases h with ⟨x,y,z,rfl⟩
  ...`
and explicit casts into `ZMod n`.

---

## Proof Strategy Architecture

You must include at least 2–3 real proof strategy paths in the file comments or paper, and then execute the most promising one in Lean.

### Strategy A: Congruence-to-local-lift architecture
1. Define `ThreeCubeLocalAdmissible`.
2. Reinterpret `sum_three_cubes_mod_nine_ne_four_five` as a statement about failure of local admissibility mod 9.
3. Show any integral representation reduces mod \(n\), yielding local admissibility for every \(n\).

**Why promising:** this is the cleanest route to a formal local-global hierarchy and directly leverages existing catalog theorems.

---

### Strategy B: Symmetry and involution geometry
1. Formalize permutation invariance and sign inversion on solutions.
2. Use `sum_three_cubes_neg_sum` to prove representability is invariant under \(k \mapsto -k\).
3. Package these as automorphisms of the family of cubic surfaces \(X_k\).

**Why promising:** this turns arithmetic manipulations into geometric structure. It is conceptually stronger than isolated lemmas and supports future work on rational curves on cubic surfaces.

---

### Strategy C: Factorization reduction via binary forms
1. Rewrite \(x^3+y^3\) using `sum_of_cubes`.
2. Express the existence of \(x,y\) with \(x^3+y^3 = m\) as a factorization constraint on \(m\).
3. Use this to derive a search algorithm over divisors of \(k-z^3\), rather than naive box enumeration.

**Why promising:** this yields the required verified algorithm and connects the three-cube problem to algebraic factorization, binary quadratic forms, and computational number theory.

**Most promising overall:** combine A + C. A gives the theorem-level architecture; C gives the algorithmic heart. B should still be formalized because it upgrades the file from arithmetic to geometry.

---

## Cross-Domain Connections You Must Make

At least one theorem and one discussion section must connect to a different domain.

### Arithmetic geometry
Interpret \(x^3+y^3+z^3=k\) as an affine cubic surface. Explain:
- local solvability modulo \(n\) as a shadow of adelic solvability,
- the distinction between local points and integral points,
- how failure of a Hasse principle would appear formally as
  `EverywhereLocallyAdmissible k ∧ ¬ SumThreeCubesRep k`.

This is the strongest cross-domain bridge and should be central.

### Algebraic/computational complexity
Your divisor-based reduction transforms brute-force cubic search into structured factor search. This connects Diophantine geometry to algorithm design and complexity reduction.

### Optional further bridge: dynamical/search heuristics
The solution set on \(X_k\) can be viewed as an orbit problem under symmetries and parameter sweeps, suggestive of statistical mechanics or energy landscapes. You need not formalize this deeply, but mention it in FUTURE_DIRECTIONS.

**Application keywords:** Diophantine equations, cubic surfaces, local-global principle, Hasse principle, modular obstructions, binary cubic forms, algorithmic number theory, arithmetic geometry, symmetry reduction, computational search.

---

## Conjecture with Testable Prediction

You must state a falsifiable conjecture with a clear computational disproof protocol.

### Recommended conjecture
```lean
/-- Conjecture: every integer not congruent to 4 or 5 mod 9 is everywhere locally admissible. -/
```
But better, make it stronger and genuinely interesting in prose:

**Conjecture (Local sufficiency at finite level, testable form).**
For every integer \(k\) with \(k \not\equiv 4,5 \pmod 9\), and for every tested modulus \(n \le B\), the residue class of \(k\) is representable as a sum of three cubes modulo \(n\).

This is falsifiable: find a single modulus \(n\) and a residue \(k \not\equiv 4,5 \pmod 9\) such that no triple of cubes mod \(n\) sums to \(k\).

### Stronger arithmetic-geometry conjecture
**Conjecture (Integral Hasse heuristic for three cubes, computational form).**
For “100%” of integers \(k \not\equiv 4,5 \pmod 9\), there exists an integral solution to \(x^3+y^3+z^3=k\).

You cannot prove this, but you can implement experiments that measure empirical density up to a bound and search for anomalous families.

The conjecture section must include:
- exact statement,
- what data would refute it,
- why current theory does not already settle it.

---

## Verified Algorithm / Computational Method

You are required to deliver not only theorems but a verified method.

### Recommended algorithm: modular sieve + factorization reduction
For a target integer \(k\) and search bound \(B\):

1. Reject immediately if \(k \equiv 4,5 \pmod 9\).
2. For each candidate \(z \in [-B,B]\), compute \(m = k-z^3\).
3. Search for factorizations \(m = s q\).
4. Use the identity
   \[
   x^3+y^3 = (x+y)(x^2-xy+y^2)
   \]
   to test whether there exist \(x,y\) with \(x+y=s\) and \(x^2-xy+y^2=q\).
5. If found, return a certified solution.

You may implement a partially verified version where the correctness theorem states:
- if the algorithm returns `(x,y,z)`, then indeed `x^3 + y^3 + z^3 = k`,
- if it rejects due to mod 9, then no solution exists.

This is scientifically meaningful even without completeness.

---

## Demo Requirements

Produce `demo.py` that:
1. takes an integer \(k\),
2. checks the mod 9 obstruction,
3. searches for a solution using the factorization-based method,
4. displays:
   - whether the target is locally obstructed,
   - any found integral solution,
   - statistics on tested \(z\) and factor pairs,
   - optional heatmap/histogram of residue coverage modulo \(n\).

The demo must make the mathematics visible, not just print “success/failure.”

---

## Mandatory Deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
3–5 original research directions. Each direction must include the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to another domain, for example:
- Brauer-Manin style obstructions,
- rational points on cubic surfaces,
- complexity-theoretic structure of Diophantine search,
- probabilistic density heuristics.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper that explains:
- the three-cube problem,
- your formal definitions,
- the theorems proved,
- the local-global architecture,
- the algorithm,
- the conjecture and experiments,
- why this matters for arithmetic geometry and computational number theory.

A reader with no access to code must still understand the discovery.

### 3. `ARTICLE.md`
Scientific American style. Explain:
- why a simple-looking equation can encode deep geometry,
- why mod 9 is only the beginning,
- how local checks and global solutions can diverge,
- why this problem sits at the frontier of number theory.

**Taboo:** do not focus on formal verification machinery.

### 4. Verified algorithm or computational method
As above: modular sieve + structured search, with a correctness theorem.

### 5. `demo.py`
Interactive exploration of local obstructions and solution search.

---

## Minimum Theorem Count and Proof Depth

Your Lean file must contain at least **3 substantial theorems** whose proofs genuinely use techniques such as:
- `induction`
- `rcases`
- `by_contra`
- `field_simp`
- multi-step `calc`
- modular casting arguments
- algebraic rewriting with existing factorization theorems

Do **not** fill the file with trivial finite checks or theorem statements whose only content is simplification.

A strong target is:
1. local obstruction theorem,
2. sign symmetry theorem,
3. local-global implication theorem,
4. factorization reduction theorem,
5. symmetry/permutation theorem.

---

## What Would Count as a Breakthrough Here

A breakthrough is **not** “I proved again that \(4,5 \bmod 9\) are impossible.”
A breakthrough is:

- formalizing the sum-of-three-cubes problem as a **family of cubic surfaces**,
- proving a clean theorem that **global solutions imply local solutions at every modulus**,
- extracting a **verified search algorithm** from algebraic factorization,
- stating a **precise Hasse-style conjecture** in a machine-checkable framework,
- creating the first reusable Lean platform for future work on integral points on cubic surfaces.

This is the seed of a new verified arithmetic geometry program.

Go build the theory, not just the examples.

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

Research domain: Algebra
Research mode: prove
