## Assignment: Building on the formally verified foundations established here—primitive reduction, parity/modular obstructions, rational surface reduction, and infinite Euler brick families—push the perfect cuboid program into a genuinely new regime: from necessary conditions to structural exclusion, density collapse, and birational control.

Prove new, non-trivial theorems in Lean 4. Build explicitly on catalog theorems already established for primitive reduction, parity constraints, modular obstructions, and rational-surface reformulations. Minimize `sorry`. Where exhaustive finite verification is needed, isolate it into small certified computations.

Mode: **prove**

---

# Research Direction
# Future Directions: Perfect Cuboid Formalization Program — Residue Geometry, Birational Surfaces, and Certified Search Collapse

## Vision

The perfect cuboid problem sits at the fault line between Diophantine geometry, modular arithmetic, and certified computation. The next breakthrough is not “check a few more congruences.” It is to formalize a theorem that **turns the search space into a geometrically and arithmetically thin object**: either empty modulo a strategically chosen modulus, or trapped inside a rigid rational surface whose integral points can be attacked by descent.

You already have the foundational layer: primitive reduction, parity restrictions, rational surface reduction, and explicit Euler brick families. Now force these ingredients to interact.

The right goal is to prove that the surviving candidates are not merely rare — they are **structured**, and that structure can be formalized.

---

## Theorem Cluster A: Certified Mod-105 Residue Sieve

### Breakthrough theorem statement

Let `pc_residue_good M x y z` mean that the three face-square conditions and the space-diagonal-square condition are simultaneously solvable modulo `M`:

- `x^2 + y^2` is a square mod `M`
- `x^2 + z^2` is a square mod `M`
- `y^2 + z^2` is a square mod `M`
- `x^2 + y^2 + z^2` is a square mod `M`

with the primitive parity pattern “exactly two even, one odd.”

Define:
```lean
def IsSquareMod (M a : ℤ) : Prop :=
  ∃ t : ℤ, t^2 ≡ a [ZMOD M]

def TwoEvenOneOdd (x y z : ℤ) : Prop :=
  ((Even x ∧ Even y ∧ Odd z) ∨
   (Even x ∧ Odd y ∧ Even z) ∨
   (Odd x ∧ Even y ∧ Even z))

def GoodCuboidResidue (M x y z : ℤ) : Prop :=
  IsSquareMod M (x^2 + y^2) ∧
  IsSquareMod M (x^2 + z^2) ∧
  IsSquareMod M (y^2 + z^2) ∧
  IsSquareMod M (x^2 + y^2 + z^2)
```

The target theorem is:

```lean
theorem no_primitive_perfect_cuboid_residue_mod_105 :
  ∀ x y z : ℤ,
    TwoEvenOneOdd x y z →
    ¬ GoodCuboidResidue 105 x y z
```

If the full statement is false, then prove the strongest surviving certified theorem:

```lean
theorem primitive_perfect_cuboid_residue_mod_105_classification :
  ∀ x y z : ℤ,
    TwoEvenOneOdd x y z →
    GoodCuboidResidue 105 x y z →
    (x % 105, y % 105, z % 105) ∈ survivingClasses105
```

together with a finite explicit `survivingClasses105` and a cardinality theorem:
```lean
theorem survivingClasses105_density_bound :
  survivingClasses105.toFinset.card ≤ B
```
for a concrete, sharp bound `B`.

### Why this is a breakthrough

A certified mod-105 collapse would be the first formally verified theorem showing that primitive perfect cuboids are obstructed simultaneously by the interaction of the `3`, `5`, and `7` local pictures, not just by isolated parity arguments. That is qualitatively different from “more congruence checking”: it builds a **global local obstruction architecture**.

If total obstruction fails, a complete classification of survivors is still a major result. It transforms the infinite problem into a finite set of arithmetic channels. This is the Diophantine analogue of a phase-space reduction in physics: the state space does not disappear, but it collapses onto a tiny exceptional locus.

### Lean 4 formalization target

You should aim for a theorem over integers using `%` and congruence classes, but internally reduce to `ZMod 105` for finite computation. A useful computational formulation is:

```lean
def GoodCuboidResidueZMod (M : ℕ) (x y z : ZMod M) : Prop :=
  (∃ a : ZMod M, a^2 = x^2 + y^2) ∧
  (∃ b : ZMod M, b^2 = x^2 + z^2) ∧
  (∃ c : ZMod M, c^2 = y^2 + z^2) ∧
  (∃ d : ZMod M, d^2 = x^2 + y^2 + z^2)

theorem no_good_residue_105_zmod :
  ∀ x y z : ZMod 105,
    TwoEvenOneOddLift x y z →
    ¬ GoodCuboidResidueZMod 105 x y z
```

Then bridge back to integers via reduction modulo `105`.

### Proof strategies

#### Strategy A: Direct finite certification over `ZMod 105`
1. Define the set of quadratic residues in `ZMod 105`.
2. Enumerate all triples `(x,y,z) : ZMod 105` satisfying the parity lift.
3. Decide `GoodCuboidResidueZMod 105 x y z` by brute-force search over witnesses.
4. Prove the resulting finite set is empty, or compute the survivor list exactly.

**Why promising:** Lean handles finite decidable predicates well once the definitions are clean. This gives a completely certified theorem and avoids delicate number-theoretic decomposition lemmas.

#### Strategy B: Chinese remainder decomposition `ZMod 105 ≃ ZMod 3 × ZMod 5 × ZMod 7`
1. Prove that squarehood mod `105` decomposes componentwise.
2. Characterize admissible triples modulo `3`, `5`, and `7` separately.
3. Show the parity condition plus local square constraints are incompatible across the CRT product.

**Why more elegant:** This reveals *why* the obstruction exists, not just that it does. If successful, it gives a reusable framework for `M = p₁…p_k` and opens a path to larger certified sieves.

#### Strategy C: Hybrid proof
1. Prove CRT decomposition abstractly.
2. Use small certified finite computations only for `mod 3`, `mod 5`, and `mod 7`.
3. Reassemble globally with a structural contradiction.

**Most promising:** This balances conceptual clarity and formal tractability. It avoids a monolithic 105-case computation while preserving mathematical meaning.

### Cross-domain connections
- **Arithmetic geometry:** local solubility and adelic obstruction heuristics.
- **Formal methods:** certified finite-state elimination via decidable predicates.
- **Complexity theory:** the cuboid search problem becomes a certified constraint-satisfaction problem over finite rings.
- **Statistical mechanics analogy:** residue classes act like forbidden microstates; the theorem identifies a hard exclusion phase.

### Application keywords
`perfect cuboid`, `modular obstruction`, `quadratic residues`, `CRT`, `finite certification`, `ZMod`, `local-global`, `certified search pruning`, `Diophantine sieve`

---

## Theorem Cluster B: Birational Parametrization or Formal Non-Parametrizability of the Rational Surface

You identified the affine surface
\[
w^2 = u^2 + v^2 - 1
\]
with extra square constraints
\[
u^2 - 1 = a^2,\qquad v^2 - 1 = b^2.
\]

This is the right geometric pivot: it encodes the perfect cuboid problem over `ℚ` as a rational-point problem on a constrained surface.

### Primary theorem target: explicit rational family

Prove, if true, an explicit theorem of the form:

```lean
theorem rational_surface_parametrization :
  ∃ U V W A B : ℚ → ℚ → ℚ,
    (∀ s t : ℚ,
      (W s t)^2 = (U s t)^2 + (V s t)^2 - 1) ∧
    (∀ s t : ℚ, (U s t)^2 - 1 = (A s t)^2) ∧
    (∀ s t : ℚ, (V s t)^2 - 1 = (B s t)^2)
```

A more geometric version, if you can define birationality cleanly, is:

```lean
theorem constrained_surface_has_dominant_rational_map :
  ∃ Φ : ℚ × ℚ → ℚ × ℚ × ℚ × ℚ × ℚ,
    DenseRange Φ ∧
    (∀ p, let q := Φ p
      in q.3^2 = q.1^2 + q.2^2 - 1 ∧
         q.1^2 - 1 = q.4^2 ∧
         q.2^2 - 1 = q.5^2)
```

If this is too ambitious for current infrastructure, prove the explicit identity theorem for a concrete candidate family.

### Alternate breakthrough theorem: obstruction to naive two-parameter parametrization

If a dense two-parameter family does **not** exist in the expected shape, that is equally important. Then prove a no-go theorem for a broad ansatz class, for example:

```lean
theorem no_low_degree_separable_parametrization :
  ¬ ∃ U V W A B : ℚ[s,t],
      totalDegree U ≤ 2 ∧ totalDegree V ≤ 2 ∧
      ((W^2 = U^2 + V^2 - 1) ∧
       (U^2 - 1 = A^2) ∧
       (V^2 - 1 = B^2))
```

Even a weaker theorem for linear-fractional or separable forms would be substantial.

### Why this is a breakthrough

This is where the cuboid problem stops being a recreational number theory puzzle and becomes formal arithmetic geometry. A successful parametrization would give a machine for generating all rational candidate configurations, shifting the problem to integrality and descent. A formal no-go theorem would be just as revolutionary: it would show that the natural rational-surface route is obstructed at the birational level, suggesting hidden geometry like elliptic fibrations or Brauer-Manin phenomena.

### Proof strategies

#### Strategy A: Double Pythagorean reduction
1. Rewrite `u^2 - 1 = a^2` and `v^2 - 1 = b^2` as hyperbola parametrizations:
   \[
   u = \frac{r^2+1}{2r},\quad a = \frac{r^2-1}{2r},\qquad
   v = \frac{s^2+1}{2s},\quad b = \frac{s^2-1}{2s}.
   \]
2. Substitute into `w^2 = u^2 + v^2 - 1`.
3. Analyze the resulting equation in `r,s`; either extract a conic bundle or prove the residual obstruction.

**Why promising:** The first two constraints become trivial identities, leaving one decisive equation. This is the cleanest path to either parametrization or obstruction.

#### Strategy B: View the surface as an intersection of quadrics
1. Work in coordinates `(u,v,a,b,w)` with equations
   \[
   u^2-a^2=1,\quad v^2-b^2=1,\quad w^2=u^2+v^2-1.
   \]
2. Eliminate variables systematically and study the resulting threefold/surface as a rational variety or conic bundle.
3. Search for a rational point and project from it.

**Why conceptually powerful:** Intersections of quadrics are often rational once a rational point is known. This strategy aligns with classical birational geometry and could expose hidden symmetry.

#### Strategy C: Fibration over one parameter
1. Fix `u` via a rational parameter.
2. The remaining equations define a conic in `(v,w,b)`.
3. Prove generic solvability or derive an obstruction from discriminant conditions.

**Most promising:** Start with Strategy A. It reduces the problem to one equation after killing two square constraints exactly. If the residual equation becomes genus-1 rather than rational, that itself is a profound discovery.

### Cross-domain connections
- **Birational geometry:** rationality vs conic-bundle structure.
- **Elliptic curves:** the residual equation after substitution may become genus one.
- **Hasse principle / Brauer-Manin:** if local points exist but parametrization fails, the obstruction may be global.
- **Symbolic computation:** Lean-certified polynomial identity checking can replace CAS black boxes for key equalities.

### Application keywords
`rational surface`, `birational map`, `conic bundle`, `intersection of quadrics`, `elliptic fibration`, `Hasse principle`, `Brauer-Manin`, `formal arithmetic geometry`

---

## Theorem Cluster C: Density Collapse for Primitive Candidate Cuboids

Whether or not mod `105` kills everything, you should prove a theorem that quantifies how much the already-formalized obstructions compress the search space.

### Target theorem statement

Let `AdmissibleResidueClass M` be the set of residue triples modulo `M` satisfying:
- primitive condition modulo `M` in the appropriate sense,
- exactly two even and one odd,
- all face/space square conditions modulo `M`.

Then prove:

```lean
theorem admissible_residue_density_bound (M : ℕ) :
  ∃ C : ℚ,
    C < 1 ∧
    card (AdmissibleResidueClass M) ≤ C * M^3
```

Specialize to `M = 105` or `M = 840 = 2^3 * 3 * 5 * 7` if your previous parity theorems integrate naturally.

A more implementation-friendly version:

```lean
theorem admissible_residue_count_105 :
  (Fintype.card { xyz : ZMod 105 × ZMod 105 × ZMod 105 //
      GoodTripleCondition xyz.1 xyz.2.1 xyz.2.2 }) ≤ B
```

for explicit small `B`.

### Why this matters

A theorem of this kind converts qualitative obstructions into **quantitative scarcity**. This is how one bridges pure number theory and computational mathematics: by proving that the entropy of the candidate space collapses. Such results can guide certified large-scale search, but more importantly, they provide evidence that perfect cuboids — if they exist — lie on an exceptionally thin exceptional set.

### Proof strategies

#### Strategy A: Inclusion-exclusion over local factors
Use the CRT decomposition and multiply local densities.

#### Strategy B: Certified enumeration for a carefully chosen modulus
A direct finite count is enough for one sharp theorem.

#### Strategy C: Abstract upper bound from independent obstructions
Combine parity, primitive reduction, and square constraints as successive filters.

**Most promising:** A hybrid CRT-counting argument gives both insight and a reusable engine for future moduli.

### Cross-domain connections
- **Information theory:** obstruction theorems reduce candidate entropy.
- **Complexity science:** converts exponential search over boxes into a sparse language recognition problem.
- **Experimental mathematics:** formal density bounds can direct where brute-force search is actually meaningful.

### Application keywords
`density theorem`, `search complexity`, `residue entropy`, `CRT factorization`, `certified enumeration`, `primitive triples`

---

## Concrete Lean 4 implementation guidance

### Core definitions to add
```lean
def IsSquareModNat (M : ℕ) (a : ZMod M) : Prop := ∃ t : ZMod M, t^2 = a

def FaceDiagonalSquareMod (M : ℕ) (x y : ZMod M) : Prop :=
  IsSquareModNat M (x^2 + y^2)

def SpaceDiagonalSquareMod (M : ℕ) (x y z : ZMod M) : Prop :=
  IsSquareModNat M (x^2 + y^2 + z^2)

def GoodCuboidResidueZMod (M : ℕ) (x y z : ZMod M) : Prop :=
  FaceDiagonalSquareMod M x y ∧
  FaceDiagonalSquareMod M x z ∧
  FaceDiagonalSquareMod M y z ∧
  SpaceDiagonalSquareMod M x y z
```

For parity on `ZMod 105`, avoid naive `Even` on ring elements; define it via lifts from integers or via image of reduction modulo `2`:
```lean
def EvenResidue {M : ℕ} [NeZero M] (x : ZMod M) : Prop :=
  (x.val % 2 = 0)
```
or, more invariantly, reduce from integers when proving the final theorem.

### Recommended theorem pipeline
1. Prove bridge lemmas from integer square conditions to square conditions mod `M`.
2. Transport primitive cuboid assumptions to `GoodCuboidResidueZMod`.
3. Prove finite exclusion/classification at modulus `105`.
4. Deduce integer-level nonexistence for that residue pattern.

---

## What to build on from the existing foundation

Use the already formalized:
- primitive reduction theorem to reduce to primitive triples,
- parity theorem forcing the two-even-one-odd configuration,
- modular impossibility lemmas modulo `4` and `8`,
- rational-surface reduction theorem connecting cuboids to rational solutions.

The point is not to reprove these. The point is to **compose** them into a stronger machine:
- parity gives the admissible local parity type,
- modular square constraints propagate to `ZMod M`,
- rational reduction identifies the geometric exceptional locus,
- Euler brick families provide nontrivial rational/integer comparison examples.

---

## Scientific significance

A successful outcome here would establish one of two transformative narratives:

1. **Arithmetic exclusion narrative:** primitive perfect cuboids are impossible because local constraints already annihilate the search space at a surprisingly small modulus.

2. **Geometric rigidity narrative:** all surviving candidates lie on a tightly constrained rational/algebraic surface, reducing the problem to a new class of formal Diophantine geometry questions.

Either outcome opens a field:
- certified local-global methods for Diophantine problems in Lean,
- formal birational geometry for arithmetic surfaces,
- complexity-aware theorem proving where finite search is promoted to mathematics via proof certificates.

This is exactly the kind of result that changes how formal mathematics attacks longstanding open problems.

---

## Deliverables

1. A Lean file proving at least one flagship theorem from Cluster A or B, with preference for:
   - `no_primitive_perfect_cuboid_residue_mod_105`, or
   - an explicit rational parametrization identity theorem for the constrained surface, or
   - a complete survivor classification modulo `105`.

2. Supporting lemmas connecting integer perfect cuboid assumptions to modular/rational formulations.

3. Minimal `sorry` use; isolate any unavoidable finite computation into explicit decidable lemmas.

4. A structured `FUTURE_DIRECTIONS.md` containing **3–5 falsifiable hypotheses**, each with:
   - precise conjecture statement,
   - exact computational or formal test,
   - predicted implication if true,
   - fallback interpretation if false.

### Required hypotheses for `FUTURE_DIRECTIONS.md`
At least include candidates of the following form:
- **Higher-modulus sieve hypothesis:** mod `3·5·7·11` eliminates all survivors from mod `105`.
- **Elliptic-fibration hypothesis:** the residual equation after double hyperbola parametrization is birational to an elliptic curve of positive rank.
- **Density-zero hypothesis:** admissible residue classes across squarefree moduli have asymptotic density `0`.
- **Brauer-Manin obstruction hypothesis:** the constrained surface has local points everywhere but no Zariski-dense rational parametrization.
- **Descent hypothesis:** every rational point in the constrained family maps to an integral obstruction after denominator clearing.

Make these testable, not aspirational.

---

## Final charge

Do not merely extend the existing perfect cuboid library. Force a synthesis between modular arithmetic, finite certified computation, and birational geometry. Either prove that the cuboid dies in residue space, or show that it survives only on a rigid geometric skeleton. Both are paradigm-shifting.

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

Research domain: Speculative
Research mode: prove
