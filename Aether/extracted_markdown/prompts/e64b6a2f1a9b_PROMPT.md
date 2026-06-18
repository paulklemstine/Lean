## Assignment: Sums of Three Cubes — Local-Global Geometry Beyond the Mod 9 Obstruction

You are not being asked to merely restate folklore. You are being asked to formalize a genuinely structural theory of the Diophantine surface
\[
X_k : x^3+y^3+z^3 = k,
\]
and to isolate the exact local, geometric, and algorithmic mechanisms governing representability. The goal is to transform “sum of three cubes” from a computational curiosity into a Lean-certified local-global research program.

Build on the verified results already in the catalog, especially:

- `sum_three_cubes_neg_sum`
  from `FINAL/MachineLearning/LocalGlobal.lean`
- `sum_three_cubes_neg_sum`
  from `MachineLearning/NumberTheory/SumThreeCubes/LocalGlobal.lean`
- `cube_is_sum_of_three_cubes`
  from `MachineLearning/NumberTheory/SumThreeCubes/Basic.lean`
- `hasse_interval_width`
  from `Speculative/AdvancedOpenQuest...`
- and, where useful as conceptual bridges, valuation/ultrametric tools such as
  `gradient_sum_bound` and `ultrametric_sum_zero_dominant_bound`.

Your mission is to prove new, non-trivial theorems about necessary congruence obstructions, functorial closure properties of representable integers, and the geometry/local-solubility interface of the cubic surface \(X_k\). The strongest version of this project should make precise, in Lean, the philosophy:

> The only universal elementary obstruction to \(x^3+y^3+z^3=k\) is the mod \(9\) obstruction, and all deeper difficulty is global, sparse, and geometric rather than purely congruential.

This is the right frontier because it connects:
- additive number theory,
- arithmetic geometry of affine cubic surfaces,
- local-global principles,
- computational search/verification,
- and even ultrametric/tropical reasoning about dominant terms and local lifting.

## Core new definition requirement

Define at least one genuinely new concept, for example:

- `IsThreeCubeRepresentable (k : ℤ) : Prop := ∃ x y z : ℤ, x^3 + y^3 + z^3 = k`
- `ForbiddenModNine (k : ℤ) : Prop := k % 9 = 4 ∨ k % 9 = 5`
- `LocallyThreeCubeRepresentable (k : ℤ) : Prop := ∀ n : ℕ, 0 < n → ∃ x y z : ZMod n, x^3 + y^3 + z^3 = k`
- `AdmissibleThreeCube (k : ℤ) : Prop := ¬ ForbiddenModNine k`
- or a stronger geometric notion:
  `HasIntegralPointOnCubicSurface (k : ℤ) : Prop := ∃ P : ℤ × ℤ × ℤ, ...`

The best version is to define both an arithmetic predicate and a local predicate, then prove implications between them.

## Precise theorem targets

You must include at least 3 deep theorems. Here is the recommended theorem package.

### Theorem 1: mod 9 obstruction is necessary

Formalize the classical necessary obstruction:
if \(k\) is representable as a sum of three integer cubes, then \(k \not\equiv 4,5 \pmod 9\).

Suggested Lean statement:
```lean
def IsThreeCubeRepresentable (k : ℤ) : Prop :=
  ∃ x y z : ℤ, x^3 + y^3 + z^3 = k

def ForbiddenModNine (k : ℤ) : Prop :=
  k % 9 = 4 ∨ k % 9 = 5

theorem three_cubes_mod9_necessary
    {k : ℤ} :
    IsThreeCubeRepresentable k → ¬ ForbiddenModNine k
```

A stronger and better-formalized version:
```lean
theorem three_cubes_mod9_residue
    {k : ℤ} :
    IsThreeCubeRepresentable k →
    k % 9 ∈ ({0, 1, 2, 3, 6, 7, 8} : Set ℤ)
```

This should not be a brute-force `native_decide` proof over all triples mod 9 unless you elevate it into a conceptual lemma:
first prove every cube mod 9 is in `{0,1,8}`, then prove every sum of three such residues avoids `4,5`. The mathematical content is in the reduction and structured modular reasoning.

### Theorem 2: representability is closed under negation

This should explicitly build on the catalog theorem `sum_three_cubes_neg_sum`, but you should strengthen or repackage it in your new framework.

Suggested Lean statement:
```lean
theorem three_cube_representable_neg_iff
    (k : ℤ) :
    IsThreeCubeRepresentable (-k) ↔ IsThreeCubeRepresentable k
```

This theorem is not just a symmetry fact; it is the first functoriality law of the representation relation and should be stated at the level of your new definition. Use the catalog theorem as a building block, not as the endpoint.

### Theorem 3: every cube is representable, hence infinitely many representable integers

Build on `cube_is_sum_of_three_cubes`.

Suggested Lean statements:
```lean
theorem three_cube_representable_of_cube
    (m : ℤ) :
    IsThreeCubeRepresentable (m^3)

theorem infinitely_many_three_cube_representable :
    Set.Infinite {k : ℤ | IsThreeCubeRepresentable k}
```

The second theorem is conceptually important: it upgrades an explicit family into a global infinitude result. The proof should use an injective map \(m \mapsto m^3\) or a standard infinitude transfer argument, not trivial enumeration.

### Theorem 4: local obstruction theorem modulo 9

Connect arithmetic geometry/local-global language to concrete congruence.

Suggested Lean statement:
```lean
def LocallyAtMod (k : ℤ) (n : ℕ) : Prop :=
  ∃ x y z : ZMod n, x^3 + y^3 + z^3 = (k : ZMod n)

theorem not_locally_representable_mod9_of_forbidden
    {k : ℤ} :
    ForbiddenModNine k → ¬ LocallyAtMod k 9
```

This theorem is the precise bridge to the Hasse-principle framing: failure modulo 9 is a local obstruction, hence any global integral point would imply local solubility and therefore cannot exist. This is where the project stops being a recreational number theory file and becomes arithmetic geometry.

### Theorem 5: global representation implies local representation

This is the key “Hasse-necessary” theorem.

Suggested Lean statement:
```lean
theorem global_implies_local
    {k : ℤ} {n : ℕ} (hn : 0 < n) :
    IsThreeCubeRepresentable k → LocallyAtMod k n
```

This theorem should be proved by reducing an integer solution modulo \(n\). It is elementary but conceptually foundational: it formalizes the local-global direction that every arithmetic geometer uses automatically.

### Theorem 6: local-global contradiction theorem

Combine the previous two into a compact obstruction principle.

Suggested Lean statement:
```lean
theorem forbiddenModNine_not_representable
    {k : ℤ} :
    ForbiddenModNine k → ¬ IsThreeCubeRepresentable k
```

This is likely your cleanest central theorem if done structurally:
global representation ⇒ local representation mod 9, but forbidden residues fail local representation mod 9.

This is more valuable than a direct modular contradiction because it explicitly encodes the Hasse-style obstruction mechanism.

## Ambitious theorem target: affine cubic surface viewpoint

If you can push farther, define the affine cubic surface:
```lean
def SumThreeCubesSurface (k : ℤ) : Set (ℤ × ℤ × ℤ) :=
  {P | let ⟨x,y,z⟩ := P; x^3 + y^3 + z^3 = k}
```

or over a general commutative ring:
```lean
def SumThreeCubesSurfaceR (R : Type*) [CommRing R] (k : R) : Set (R × R × R) := ...
```

Then prove a ring-generic reduction theorem:
```lean
theorem integral_point_gives_modn_point
    {k : ℤ} {n : ℕ} (hn : 0 < n) :
    (∃ P ∈ SumThreeCubesSurface k, True) →
    ∃ Q, Q ∈ SumThreeCubesSurfaceR (ZMod n) (k : ZMod n)
```

This opens the door to future formalization of the Hasse principle, Brauer-Manin obstructions, and cubic-surface arithmetic.

## Proof strategy architecture

You must pursue at least 2–3 proof pathways and choose the strongest one per theorem.

### Strategy A: congruence-class decomposition mod 9
Best for `three_cubes_mod9_necessary`, `not_locally_representable_mod9_of_forbidden`.

1. Prove a lemma that every cube modulo 9 lies in `{0,1,8}`.
   This can be done by reducing an integer modulo 3 or by explicit residue analysis modulo 9, but package it as a conceptual cube-residue lemma.
2. Prove that sums of three elements of `{0,1,8}` modulo 9 avoid residues `4` and `5`.
3. Transfer this to integers or `ZMod 9`.

Why promising: it is mathematically canonical and creates reusable infrastructure for higher-power congruence obstructions.

### Strategy B: local-global factorization through `ZMod n`
Best for `global_implies_local`, `forbiddenModNine_not_representable`.

1. Define `LocallyAtMod`.
2. Show any integer solution maps to a `ZMod n` solution by coercion.
3. Show forbidden mod 9 classes admit no `ZMod 9` solution.
4. Conclude non-representability from local failure.

Why promising: this is the most conceptually powerful route because it formalizes arithmetic geometry rather than only modular arithmetic. It also prepares future work on \(p\)-adic lifting and Hasse-style principles.

### Strategy C: closure and infinitude via explicit families
Best for `three_cube_representable_neg_iff`, `three_cube_representable_of_cube`,
`infinitely_many_three_cube_representable`.

1. Repackage `cube_is_sum_of_three_cubes` into your new predicate.
2. Use sign symmetry \( (-x)^3+(-y)^3+(-z)^3 = -(x^3+y^3+z^3)\) or the catalog negation theorem.
3. Derive infinitude from the infinite family \(m^3\).

Why promising: it gives a clean structural theory of the representable set and avoids isolated one-off lemmas.

## Cross-domain connections you should explicitly formalize or discuss

### 1. Arithmetic geometry / Hasse principle
The equation \(x^3+y^3+z^3=k\) defines an affine cubic surface. Formalizing
“global integral point ⇒ local point modulo every \(n\)” is the elementary shadow of the Hasse principle. The failure of representability for \(k \equiv 4,5 \pmod 9\) is a concrete local obstruction.

This is not rhetoric: your theorem package should make the surface viewpoint explicit in definitions and theorem names.

### 2. Ulrametric and valuation thinking
Use the catalog’s ultrametric/valuation results conceptually: local solubility and modular obstructions are primitive forms of valuation-theoretic reasoning. Even if you do not directly invoke `gradient_sum_bound` or `ultrametric_sum_zero_dominant_bound`, explain in the paper how local congruence obstructions are the discrete precursor of \(p\)-adic analysis.

A strong optional theorem would relate mod-\(p\) solvability to valuation heuristics for dominant cubic terms.

### 3. Algebraic geometry / singularity structure
For special \(k\), the affine cubic surface may have different geometric behavior. Even a lightweight formal observation about the polynomial
\[
f_k(x,y,z)=x^3+y^3+z^3-k
\]
and its gradient
\[
(3x^2,3y^2,3z^2)
\]
can connect the arithmetic problem to geometry of cubic hypersurfaces. If you can prove a non-singularity statement over characteristic \(\neq 3\), that would be an excellent cross-domain theorem.

Suggested optional Lean target:
```lean
theorem sumThreeCubes_surface_nonsingular_away_char3
    (K : Type*) [Field K] [NoZeroSMulDivisors ℕ K]
    (h3 : (3 : K) ≠ 0) (k : K) :
    -- formulate that the gradient cannot vanish at a point of the surface unless ...
```

### 4. Complexity and computation
The search for representations is computationally deep. Your verified algorithm should not just test random triples naively; it should exploit congruence pruning:
- discard forbidden `k mod 9`,
- search in symmetry-reduced regions,
- verify local admissibility first.

This is where formal theorem and algorithm meet.

## Application keywords

Include these explicitly in your paper and article:

- local-global principle
- Hasse obstruction
- affine cubic surface
- modular obstruction
- Diophantine geometry
- computational number theory
- congruence filtering
- \(p\)-adic heuristic
- arithmetic statistics
- sparse representability
- certified search
- symmetry reduction

## Conjectures with testable predictions

You must include at least one falsifiable conjecture with a clear computational test. Better: include 3–5 in `FUTURE_DIRECTIONS.md`.

Recommended conjectures:

1. **Weak local-global admissibility conjecture**
   ```text
   Conjecture: For every integer k with k % 9 ≠ 4,5, there exists n₀ such that
   for all n divisible by n₀, the congruence x^3+y^3+z^3 ≡ k (mod n) is soluble.
   ```
   Test: compute solvability modulo growing powers of small primes for many admissible `k`.

2. **Positive-density admissibility heuristic**
   ```text
   Conjecture: The set {k : ℤ | IsThreeCubeRepresentable k} has zero density among ℤ,
   but the set of locally admissible k has density 7/9.
   ```
   Test: count admissible residues and search actual representations up to large bounds.

3. **Height-distribution conjecture**
   ```text
   Conjecture: For admissible k, the minimal height of a solution (if one exists)
   has heavy-tailed growth and is not polynomially bounded in |k|.
   ```
   Test: compute minimal found solution heights for a large sample of admissible `k`.

4. **Symmetry-reduced search conjecture**
   ```text
   Conjecture: After ordering |x| ≤ |y| ≤ |z| and filtering by mod 9,
   average search complexity drops by a constant factor bounded away from 1.
   ```
   Test: benchmark naive vs filtered search.

5. **Geometric smoothness heuristic**
   ```text
   Conjecture: For k ≠ 0 and away from characteristic 3, the associated cubic
   surface exhibits generic local smoothness compatible with widespread local solubility.
   ```
   Test: symbolic gradient checks modulo many primes.

Each conjecture must be falsifiable and accompanied by a computational protocol.

## Required deliverables

You must produce ALL of the following:

1. `FUTURE_DIRECTIONS.md`
   with 3–5 falsifiable scientific hypotheses, each with:
   - exact statement,
   - why it matters,
   - a concrete computational or formal test that could disprove it.

2. `RESEARCH_PAPER.md`
   as a standalone scientific paper containing:
   - introduction and motivation,
   - precise definitions,
   - theorem statements,
   - proof ideas,
   - computational method,
   - significance for local-global arithmetic and cubic surfaces,
   - next-step research program.
   Someone reading only this paper must understand the discovery without opening Lean.

3. `ARTICLE.md`
   in Scientific American style:
   - vivid explanation of why three cubes are mysterious,
   - what the mod 9 obstruction means,
   - how local checks and global solutions differ,
   - why formal verification changes the research landscape.

4. A verified algorithm or computational method:
   - certified congruence filter for impossible targets,
   - local-solubility checker modulo \(n\),
   - symmetry-reduced bounded search for representations,
   - and correctness statements connecting the algorithm to theorems.

5. `demo.py`
   demonstrating:
   - input integer `k`,
   - immediate mod 9 admissibility verdict,
   - local checks modulo selected moduli,
   - bounded search for a representation,
   - explanatory output tying the computation to the formal theorems.

## Lean-specific expectations

- Give precise theorem names and use your new definitions consistently.
- Avoid trivial proofs by pure decision procedures unless the statement is inherently finite and the conceptual content has already been isolated in lemmas.
- Ensure at least 3 substantial proofs use techniques like:
  - `induction`
  - `rcases`
  - `by_contra`
  - `field_simp`
  - multi-step `calc`
- Prefer theorem chains over monolithic proofs.
- Minimize `sorry`, and if any remain, isolate them in the most ambitious optional theorem only.

## Concrete file-shaping suggestion

A strong final development might include:

- definitions of representability/local representability/forbidden residues,
- lemmas on cube residues mod 9,
- theorem that global solutions imply local solutions,
- theorem that forbidden residues are not locally soluble mod 9,
- theorem that forbidden residues are not globally representable,
- symmetry theorem under negation,
- infinitude theorem from cubes,
- optional surface/geometric theorem.

## Why this would be a breakthrough

A fully formalized local-global framework for sums of three cubes would be a real conceptual advance over isolated ad hoc lemmas. It would create a reusable certified platform for:
- arithmetic of cubic surfaces,
- modular obstructions in Diophantine equations,
- future \(p\)-adic lifting and Hensel-style formalization,
- computational experiments on density and sparsity,
- and eventually Brauer-Manin-style obstruction mechanisms in machine-checked arithmetic geometry.

Do not merely formalize that some numbers are or are not sums of three cubes. Build the first Lean-native arithmetic-geometric theory of the equation \(x^3+y^3+z^3=k\).

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
