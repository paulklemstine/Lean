## Assignment: Perfect Cuboid (Euler Brick)

**Mode:** prove + formalize + counterexample-if-needed

Prove genuinely new, non-trivial theorems around the perfect cuboid obstruction problem. Do **not** promise a full resolution unless Lean evidence supports it. The scientifically serious target is to formalize structural obstructions, infinite families of near-misses, and reductions to arithmetic geometry that sharpen the search space or certify impossibility in substantial regimes.

### Research Direction
A **perfect cuboid** is a triple `(x,y,z) ∈ ℕ^3` such that all three face diagonals and the space diagonal are integers:
- `x^2 + y^2 = a^2`
- `x^2 + z^2 = b^2`
- `y^2 + z^2 = c^2`
- `x^2 + y^2 + z^2 = d^2`

with `a b c d ∈ ℕ`.

The classical open problem asks whether such a tuple exists. Since a complete solution is likely out of reach in one cycle, the breakthrough objective is:

1. **Formalize the perfect cuboid equation system cleanly in Lean 4.**
2. **Prove infinite parametric families of Euler bricks / near-misses** where the three face diagonals are integral but the space diagonal is provably non-integral.
3. **Prove new modular, parity, gcd, and descent obstructions** for perfect cuboids.
4. **Connect the problem to intersections of quadrics / algebraic surfaces**, and formalize at least one reduction theorem showing that primitive perfect cuboids correspond to rational points on a specific affine or projective surface.
5. If the global existence question resists proof, produce a **counterexample-oriented brief**: isolate a natural overstrong conjecture and refute it by explicit Lean-certified examples.

### Mathematical Framing
This is not merely a recreational Diophantine puzzle. The perfect cuboid sits at the crossroads of:
- **Pythagorean triple theory**
- **integral points on algebraic surfaces**
- **local-global obstructions**
- **descent and primitive reduction**
- **computational Diophantine search certification**

A major contribution here would be a formally verified bridge from elementary number theory to arithmetic geometry: prove that primitive perfect cuboids are equivalent to primitive integer points on a concrete intersection of quadrics, then derive modular restrictions or near-miss parametrizations from that structure.

### Precise Theorem Targets

You should aim to formalize and prove some combination of the following. These are realistic, meaningful, and nontrivial.

#### 1. Primitive reduction theorem
Every perfect cuboid scales from a primitive one.

**Mathematical statement.**
If `(x,y,z)` is a perfect cuboid, then dividing by `g = gcd x (gcd y z)` yields a primitive perfect cuboid `(x/g, y/g, z/g)` with pairwise-coprime content in the sense `gcd (x/g) (gcd (y/g) (z/g)) = 1`.

**Lean 4 target signature**
```lean
def IsPerfectCuboid (x y z : ℕ) : Prop :=
  ∃ a b c d : ℕ,
    a^2 = x^2 + y^2 ∧
    b^2 = x^2 + z^2 ∧
    c^2 = y^2 + z^2 ∧
    d^2 = x^2 + y^2 + z^2

def PrimitiveTriple (x y z : ℕ) : Prop :=
  Nat.gcd x (Nat.gcd y z) = 1

theorem perfect_cuboid_has_primitive_scaling
    {x y z : ℕ} (h : IsPerfectCuboid x y z) :
    ∃ g x' y' z',
      g > 0 ∧
      x = g * x' ∧ y = g * y' ∧ z = g * z' ∧
      PrimitiveTriple x' y' z' ∧
      IsPerfectCuboid x' y' z' := by
  sorry
```

This theorem is foundational: it reduces the open problem to primitive solutions and prepares all later parity and congruence arguments.

---

#### 2. Parity obstruction for primitive perfect cuboids
A primitive perfect cuboid must have exactly one even edge and two odd edges.

**Mathematical statement.**
Let `(x,y,z)` be primitive and perfect. Then exactly one of `x,y,z` is even.

This is stronger than the basic “not all odd” observation and is a clean primitive obstruction.

**Lean 4 target signature**
```lean
def ExactlyOneEven (x y z : ℕ) : Prop :=
  (Even x ∧ Odd y ∧ Odd z) ∨
  (Odd x ∧ Even y ∧ Odd z) ∨
  (Odd x ∧ Odd y ∧ Even z)

theorem primitive_perfect_cuboid_exactly_one_even
    {x y z : ℕ}
    (hprim : PrimitiveTriple x y z)
    (hpc : IsPerfectCuboid x y z) :
    ExactlyOneEven x y z := by
  sorry
```

This is a rigorous structural theorem and should be easy enough to close fully in Lean using modular arithmetic mod `2` and `4`.

---

#### 3. Mod-8 / mod-16 obstruction on the space diagonal
In the primitive parity pattern, the space diagonal square is constrained to a specific congruence class.

**Mathematical statement.**
If `(x,y,z)` is a primitive perfect cuboid, then `x^2 + y^2 + z^2 ≡ 1, 4, or 9 (mod 16)` depending on parity pattern; in the primitive case with exactly one even edge, the sum is odd and hence the diagonal is odd. Sharpen this to the strongest true statement Lean can support.

A more concrete theorem:
```lean
theorem primitive_perfect_cuboid_space_diag_odd
    {x y z : ℕ}
    (hprim : PrimitiveTriple x y z)
    (hpc : IsPerfectCuboid x y z) :
    ∃ d, d^2 = x^2 + y^2 + z^2 ∧ Odd d := by
  sorry
```

Then strengthen to a congruence theorem if feasible.

---

#### 4. Infinite family of Euler bricks from paired Pythagorean triples
Formalize a constructive infinite family of Euler bricks with integral face diagonals, then prove the space diagonal is not integral for an infinite subfamily.

A classical strategy: choose `x` so that both `(x,y,a)` and `(x,z,b)` are primitive Pythagorean triples. Then solve for compatibility of `y^2 + z^2 = c^2`. Even if a full 3-parameter family is hard, prove a family of **near-misses** where two or three face diagonals are integral and the space diagonal fails by a modular obstruction.

A realistic theorem:
```lean
def IsEulerBrick (x y z : ℕ) : Prop :=
  ∃ a b c : ℕ,
    a^2 = x^2 + y^2 ∧
    b^2 = x^2 + z^2 ∧
    c^2 = y^2 + z^2

theorem exists_infinite_euler_brick_family :
    ∀ N : ℕ, ∃ x y z ≥ N, IsEulerBrick x y z := by
  sorry
```

If the `≥ N` tuple syntax becomes awkward, spell out inequalities explicitly.

Even better: prove a specific parameter family.

Example target shape:
```lean
theorem euler_brick_family_parametric
    {m n p q : ℕ}
    (hmn : n < m) (hpq : q < p)
    (hcop1 : Nat.Coprime m n) (hcop2 : Nat.Coprime p q)
    (hpar1 : ¬ (m % 2 = n % 2))
    (hpar2 : ¬ (p % 2 = q % 2))
    (hcompat : m^2 - n^2 = 2*p*q) :
    IsEulerBrick (2*m*n) (m^2 - n^2) (p^2 - q^2) := by
  sorry
```

You may need to adjust the compatibility equation; the important thing is to derive a true parametric theorem from two compatible Pythagorean representations.

---

#### 5. Algebraic-surface reduction theorem
Show that perfect cuboids correspond to integer points on an intersection of quadrics, and primitive perfect cuboids correspond to rational points on a normalized surface.

**Mathematical statement.**
Define variables `u = a/x`, `v = b/x`, `w = d/x` over `ℚ` when `x ≠ 0`. Then:
- `u^2 = 1 + (y/x)^2`
- `v^2 = 1 + (z/x)^2`
- `w^2 = 1 + (y/x)^2 + (z/x)^2`

Eliminate `y/x, z/x` to obtain a rational surface relation such as
`w^2 = u^2 + v^2 - 1`.

This gives a reduction from perfect cuboids to rational points satisfying additional square conditions.

**Lean 4 target signature**
```lean
theorem perfect_cuboid_rat_point_on_surface
    {x y z a b c d : ℚ}
    (hx : x ≠ 0)
    (h1 : a^2 = x^2 + y^2)
    (h2 : b^2 = x^2 + z^2)
    (h3 : d^2 = x^2 + y^2 + z^2) :
    (d / x)^2 = (a / x)^2 + (b / x)^2 - 1 := by
  sorry
```

This is elementary algebra, but its significance is enormous: it turns the cuboid problem into arithmetic on a rational surface. Once formalized, it invites future work on birational models, local obstructions, and elliptic fibrations.

---

#### 6. Nonexistence in restricted families
A field-opening result would be to prove no perfect cuboid exists in a substantial parametric class.

Example:
- no primitive perfect cuboid with one edge divisible by `4` and the other two congruent to `±1 mod 8`, if this follows from squareclass analysis;
- no perfect cuboid in a chosen parametric family of Euler bricks;
- no perfect cuboid with two face diagonals primitive simultaneously under some coprimality assumptions.

A candidate formal target:
```lean
theorem no_perfect_cuboid_in_family
    {m n : ℕ}
    (hcop : Nat.Coprime m n)
    (hpar : ¬ (m % 2 = n % 2)) :
    ¬ IsPerfectCuboid (2*m*n) (m^2 - n^2) (m^2 + n^2) := by
  sorry
```

This exact statement may be false as written; verify first. If false, pivot to a **counterexample** mode and prove the corrected theorem. The point is to carve out rigorous forbidden regions.

### Lean 4 Definitions to Introduce
Use explicit definitions early and keep them reusable.

```lean
def IsSquare (n : ℕ) : Prop := ∃ k : ℕ, k^2 = n

def IsEulerBrick (x y z : ℕ) : Prop :=
  IsSquare (x^2 + y^2) ∧
  IsSquare (x^2 + z^2) ∧
  IsSquare (y^2 + z^2)

def IsPerfectCuboid (x y z : ℕ) : Prop :=
  IsEulerBrick x y z ∧ IsSquare (x^2 + y^2 + z^2)

def PrimitiveTriple (x y z : ℕ) : Prop :=
  Nat.gcd x (Nat.gcd y z) = 1
```

You may also want `PairwiseCoprime` if useful.

### 2–3 Proof Strategy Paths

#### Strategy A: Primitive reduction + parity/congruence descent
1. Prove scaling invariance: if `(x,y,z)` is perfect then dividing by the common gcd preserves the property.
2. Reduce to primitive solutions and classify parity using `mod 2`, `mod 4`, and `mod 8`.
3. Derive stronger congruence constraints on edges and diagonals, then exclude broad residue classes or parameter families.

**Why promising:** This is the most Lean-friendly path. It uses standard arithmetic lemmas, avoids heavy algebraic geometry at first, and can yield publishable obstruction theorems even without resolving the full open problem.

#### Strategy B: Pythagorean parametrization and compatibility equations
1. Since each face gives a Pythagorean triple, parametrize:
   - `x = 2mn`, `y = m^2 - n^2`, `a = m^2 + n^2`, etc.
2. Equate shared edges across two parametrizations, producing compatibility equations between parameters.
3. Study whether the third face and space diagonal can be square; derive explicit infinite near-miss families or impossible parameter regimes.

**Why promising:** This exposes the hidden geometry and is the natural route to infinite families of Euler bricks. It also interfaces well with `euler_four_square`, since sums of squares identities may help construct or transform families.

#### Strategy C: Rational surface / arithmetic geometry reduction
1. Normalize by one edge and pass to rational variables.
2. Prove the cuboid equations define an intersection of quadrics, then derive a surface relation like `w^2 = u^2 + v^2 - 1`.
3. Investigate local obstructions, birational parametrizations of subfamilies, or reductions to elliptic curves in selected slices.

**Why promising:** This is the most visionary route. Even a modest Lean formalization here would open a new formal arithmetic-geometry program around the perfect cuboid, far beyond brute-force search.

### How to Build on Catalog Theorems

- **`euler_four_square`**  
  Use it as a conceptual and technical bridge: the cuboid problem is governed by simultaneous square conditions, and Euler’s four-square identity may help combine known sum-of-squares representations into new brick constructions or invariant transforms. Even if it does not directly solve the cuboid equations, formalize a lemma showing how square representations propagate through multiplicative constructions.

- **`exists_refinement_cell_for_pair`**  
  This can inspire a decomposition viewpoint: parameter space for paired Pythagorean triples may admit a finite “cell” analysis by congruence class or valuation profile. You likely cannot directly import Berkovich machinery into the full proof, but you can imitate the philosophy: partition parameter space by local arithmetic type and prove obstructions cellwise.

- **`capset_diagonal`**  
  Use as a cross-domain analogy rather than direct dependency: the perfect cuboid conditions involve avoiding or forcing diagonal coincidences in structured arithmetic sets. There may be a combinatorial reformulation of compatible square pairs as a sparse set with additive constraints. If you can define a finite search obstruction in `ZMod n`, this becomes a compelling bridge to additive combinatorics.

- **`exists_bounded_cycle_mean_le`**  
  Potentially repurpose for certified search: define a weighted search graph on residue classes or parameter states, where a cycle corresponds to a consistent modular lifting pattern. A bounded-cycle theorem could help certify that certain modular search branches terminate or recur without yielding solutions. This is speculative but could become a formal computational theorem.

- **`algebraic_security_trichotomy`**  
  This suggests a trichotomy mindset: classify parameter families into
  1. impossible by local obstruction,
  2. reducible to lower-dimensional families,
  3. genuinely unresolved.  
  A theorem of this form for cuboid parameter space would be conceptually powerful.

### Cross-Domain Connections
You must connect to at least one other domain in a mathematically serious way:

1. **Arithmetic geometry:** perfect cuboids as rational/integer points on intersections of quadrics and possibly elliptic fibrations.
2. **Additive combinatorics:** compatibility of multiple square conditions as structured sparse subsets of residue rings.
3. **Formal verification / certified computation:** machine-checked modular sieves and exhaustive search certificates.
4. **Algebraic complexity:** the cuboid constraints define a low-degree polynomial system; formalize elimination identities and certify infeasibility in residue classes.
5. **Sum-of-squares algebra:** connect `euler_four_square` to transformations of brick data.

### Breakthrough Significance
A complete proof of existence or nonexistence would be historic. But even short of that, a formal library of:
- primitive reduction,
- parity and modular obstructions,
- certified infinite near-miss families,
- algebraic-surface reductions,

would be a genuine breakthrough in **formal Diophantine arithmetic geometry**. It would transform a classical recreational problem into a benchmark formalization platform for:
- local-global principles,
- rational surface reasoning in Lean,
- certified search over arithmetic constraints,
- future reductions to elliptic curves or higher descent.

This opens a new program: not just “solve the perfect cuboid,” but “formalize the arithmetic-geometric anatomy of unsolved Diophantine problems.”

### Concrete Deliverables
1. Lean file(s) with reusable definitions:
   - `IsSquare`
   - `IsEulerBrick`
   - `IsPerfectCuboid`
   - primitive reduction helpers
   - parity / congruence lemmas

2. At least one fully proved theorem from the target list above.

3. Preferably one constructive theorem giving an infinite family of Euler bricks or near-misses.

4. One bridge theorem to arithmetic geometry, such as `perfect_cuboid_rat_point_on_surface`.

5. If a bold conjecture fails, include a **counterexample theorem** instead of leaving a weak sorry.

6. Minimize sorry aggressively. If a theorem becomes too ambitious, split it into certified lemmas.

### Application Keywords
perfect cuboid, Euler brick, Diophantine equations, Pythagorean triples, sums of squares, arithmetic geometry, rational surfaces, intersections of quadrics, local-global obstruction, modular arithmetic, descent, primitive solutions, formal verification, Lean 4, Mathlib, certified search, algebraic surfaces

### Required FUTURE_DIRECTIONS.md
This is critical. Produce `FUTURE_DIRECTIONS.md` with **3–5 precise, falsifiable hypotheses**. Each must have a clear computational or formal test.

Use this format:

```md
### [Direction Title]
Hypothesis: ...
Test: ...
Possible outcome if true: ...
Possible outcome if false: ...
```

You must include hypotheses of the following flavor:

1. **Residue obstruction hypothesis**  
   Hypothesis: every primitive perfect cuboid violates at least one congruence condition modulo `M` for some explicit `M` (e.g. `16`, `32`, `64`, or `105`).  
   Test: exhaustive Lean/Python verification over all primitive residue classes modulo `M`.  

2. **Surface parametrization hypothesis**  
   Hypothesis: a Zariski-dense family of rational points on the normalized cuboid surface comes from a 2-parameter birational map.  
   Test: derive candidate formulas and verify the surface equation symbolically in Lean for generic parameters.

3. **Near-miss infinitude hypothesis**  
   Hypothesis: there are infinitely many Euler bricks with space diagonal at distance `1` from a square, or bounded by `O(n^α)` in a chosen parameter family.  
   Test: formalize the family and prove/disprove the bound for the first `N` cases computationally.

4. **Elliptic-fibration slice hypothesis**  
   Hypothesis: fixing one normalized face parameter reduces the surface to an elliptic curve with positive rank for infinitely many slices.  
   Test: derive the slice equation and compute sample ranks externally; formalize the algebraic reduction in Lean.

5. **No-solution-in-family hypothesis**  
   Hypothesis: a specific 2-parameter Pythagorean family never yields a perfect cuboid.  
   Test: prove a modular contradiction symbolically, or find a counterexample.

Pursue the strongest theorem you can actually certify. If the full perfect cuboid problem does not yield, turn that resistance into structure: obstructions, reductions, parametrizations, and certified near-misses. That is the path to a real breakthrough.

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
