## Assignment: Sums of Three Cubes — Local-Global Geometry, Modular Obstructions, and Formal Diophantine Infrastructure

Prove new, non-trivial theorems about the Diophantine equation
\[
x^3+y^3+z^3 = n
\]
and formalize a serious Lean 4 foundation for the arithmetic of sums of three cubes. Do **not** settle for restating the mod-9 obstruction alone. Use it as the entry point to a broader program linking modular arithmetic, cubic surfaces, local solvability, and the failure of the Hasse principle.

Your target is not “some facts about cubes.” Your target is a formal research bridge between:
- elementary congruence obstructions,
- affine and projective cubic surfaces,
- local-global principles,
- computational certification of known examples/nonexamples,
- and a precise formal language for the density conjecture.

The equation \(x^3+y^3+z^3=n\) is one of the cleanest laboratories in arithmetic geometry where naive local reasoning is powerful but incomplete. Formalizing this landscape in Lean would open a reusable infrastructure for Mordell-type equations, cubic surfaces, and local-global obstructions across Mathlib.

### Core Research Goal

Construct a Lean 4 development that proves rigorous necessary conditions, derives infinite families of representable integers, formalizes local solvability statements over `ZMod m`, and defines a precise notion of asymptotic density for the representable set. Then push toward a formal statement of the Hasse-principle tension for the cubic surface
\[
X_n : x^3+y^3+z^3 = n.
\]

You should aim for at least one theorem that is genuinely structural, not merely computational.

---

## Breakthrough Theorems to Target

### Theorem A: Complete mod-9 obstruction for three cubes

This is the indispensable arithmetic skeleton. The classical fact is:
\[
\forall x y z \in \mathbb Z,\quad x^3+y^3+z^3 \not\equiv 4,5 \pmod 9.
\]
Equivalently, if \(n \equiv 4,5 \pmod 9\), then \(n\) is not a sum of three integer cubes.

But do not stop there: prove the stronger finite local characterization mod 9:
\[
\{x^3+y^3+z^3 \bmod 9 : x,y,z \in \mathbb Z\} = \{0,1,2,3,6,7,8\}.
\]

#### Lean 4 target
```lean
def SumThreeCubesRep (n : ℤ) : Prop :=
  ∃ x y z : ℤ, x^3 + y^3 + z^3 = n

theorem int_cube_mod_nine (x : ℤ) :
    x^3 % 9 = x % 9 ∨ x^3 % 9 = 0 ∨ x^3 % 9 = (-x) % 9 := by
  sorry

theorem sum_three_cubes_mod9_obstruction (n : ℤ)
    (h : n % 9 = 4 ∨ n % 9 = 5) :
    ¬ SumThreeCubesRep n := by
  sorry

theorem sum_three_cubes_mod9_characterization (a : ZMod 9) :
    (∃ x y z : ZMod 9, x^3 + y^3 + z^3 = a) ↔
      a ≠ 4 ∧ a ≠ 5 := by
  sorry
```

This theorem matters because it gives a fully formal local obstruction and a reusable pattern for proving representability/nonrepresentability by polynomial forms via finite quotient analysis.

---

### Theorem B: Infinite families of exact representations

Formalize explicit parametric identities giving infinitely many integers represented as sums of three cubes. For example:
\[
(a)^3 + (-a)^3 + b^3 = b^3,
\]
which is trivial but too weak. You need **nontrivial polynomial families** such as
\[
(9t^4)^3 + (3t - 9t^4)^3 + (1 - 9t^3)^3 = 1 - 27t^3 + \cdots
\]
or other certified polynomial identities from the literature if manageable.

At minimum, prove robust infinite families such as:
- every perfect cube is representable;
- infinitely many positive and negative integers are representable by nontrivial triples;
- for each `k : ℤ`, there exists `n` with `|n| > k` and `SumThreeCubesRep n`.

#### Lean 4 target
```lean
theorem cube_is_sum_of_three_cubes (m : ℤ) :
    SumThreeCubesRep (m^3) := by
  sorry

theorem infinitely_many_sum_three_cubes :
    ∀ B : ℤ, ∃ n : ℤ, Int.natAbs n > Int.natAbs B ∧ SumThreeCubesRep n := by
  sorry

theorem infinitely_many_positive_sum_three_cubes :
    ∀ B : ℕ, ∃ n : ℕ, B < n ∧ SumThreeCubesRep (n : ℤ) := by
  sorry
```

This is not the end goal; it is the minimal infrastructure needed before discussing density. If you can find and verify a nontrivial polynomial identity producing a sparse but infinite family, that is significantly better and mathematically more interesting.

---

### Theorem C: Formal local solvability framework modulo arbitrary moduli

Define the local representability predicate
\[
\mathrm{LocRep}(m,n) := \exists x,y,z \in \mathbb Z/m\mathbb Z,\ x^3+y^3+z^3=n.
\]
Then prove compatibility under divisibility / CRT-style lifting where possible.

#### Lean 4 target
```lean
def LocRep (m : ℕ) (a : ZMod m) : Prop :=
  ∃ x y z : ZMod m, x^3 + y^3 + z^3 = a

theorem locRep_mod9_exact (a : ZMod 9) :
    LocRep 9 a ↔ a ≠ 4 ∧ a ≠ 5 := by
  sorry

theorem locRep_monotone_of_factor
    {m n : ℕ} (h : m ∣ n) :
    ∀ a : ZMod m, LocRep m a →
      ∃ b : ZMod n, LocRep n b := by
  sorry
```

A stronger and more meaningful version would use ring homomorphisms or CRT decomposition:
```lean
theorem locRep_prod_of_coprime
    {m n : ℕ} (hmn : Nat.Coprime m n) (a : ZMod (m * n)) :
    LocRep (m * n) a ↔
      LocRep m (cast ... a) ∧ LocRep n (cast ... a) := by
  sorry
```
If the exact cast machinery is cumbersome, define the theorem at the level of tuples of residues and use existing `ZMod` equivalences.

This would be a genuine infrastructure theorem for local-global experimentation on polynomial Diophantine equations.

---

### Theorem D: Density formalization and obstruction-set asymptotics

Define the representable set
\[
R := \{n \in \mathbb Z : \exists x,y,z,\ x^3+y^3+z^3=n\},
\]
and the counting function
\[
R(N) := \#\{n \in \mathbb Z : |n|\le N,\ n \in R\}.
\]
Then define upper/lower asymptotic density in Lean for subsets of `ℤ` or `ℕ`. You likely will not prove the true density conjecture, but you can prove exact density statements for the mod-9 admissible set:
\[
\#\{0\le n < 9N : n \not\equiv 4,5 \pmod 9\} = 7N.
\]
Hence the admissible congruence classes have natural density \(7/9\).

#### Lean 4 target
```lean
def admissibleMod9 (n : ℕ) : Prop :=
  n % 9 ≠ 4 ∧ n % 9 ≠ 5

theorem count_admissible_mod9_block (N : ℕ) :
    ((Finset.range (9 * N)).filter (fun n => admissibleMod9 n)).card = 7 * N := by
  sorry
```

A stronger formulation:
```lean
def NatAsymptoticDensity (S : Set ℕ) (d : ℝ) : Prop :=
  Tendsto (fun N : ℕ =>
    (((Finset.range N).filter (fun n => n ∈ S)).card : ℝ) / N) atTop (𝓝 d)

theorem admissible_mod9_density :
    NatAsymptoticDensity {n : ℕ | admissibleMod9 n} (7 / 9 : ℝ) := by
  sorry
```

This is the right formal precursor to the actual density conjecture:
> Conjecture: among mod-9-admissible integers, 100% are representable as sums of three cubes.

Even if the full conjecture remains inaccessible, the formal asymptotic framework is itself a high-value contribution.

---

### Theorem E: Geometric recasting as an affine cubic surface

Define the affine variety
\[
X_n(\mathbb Z) = \{(x,y,z)\in \mathbb Z^3 : x^3+y^3+z^3=n\}.
\]
Then formalize the statement that integer representability is equivalent to the nonemptiness of integral points on the cubic surface \(X_n\). This sounds tautological, but the point is to build a reusable abstraction for Diophantine sets as integral points on varieties.

#### Lean 4 target
```lean
def CubicSurfacePoint (n : ℤ) :=
  {p : ℤ × ℤ × ℤ // p.1.1^3 + p.1.2^3 + p.2^3 = n}

theorem sumThreeCubes_iff_nonempty_cubicSurfacePoint (n : ℤ) :
    SumThreeCubesRep n ↔ Nonempty (CubicSurfacePoint n) := by
  sorry
```

Then push one layer deeper: define local points modulo `m`.
```lean
def CubicSurfacePointMod (m : ℕ) (a : ZMod m) :=
  {p : ZMod m × ZMod m × ZMod m // p.1.1^3 + p.1.2^3 + p.2^3 = a}
```

This creates the bridge to Hasse-principle language:
- global integer point,
- local points modulo all `m`,
- potential local-global gap.

That gap is where future breakthroughs live.

---

## Most Promising Proof Strategies

### Strategy 1: Finite residue classification + exact counting
Best first attack. Highest probability of complete formal success.

1. Prove that every cube modulo 9 is in `{0,1,8}` using either:
   - case split on `x % 9`, or
   - a general lemma from `ZMod 9`.
2. Enumerate all sums of three elements from `{0,1,8}` and show the image is exactly `{0,1,2,3,6,7,8}`.
3. Use this to derive the obstruction theorem on `ℤ`.
4. Upgrade to a counting theorem for admissible residue classes in blocks of length `9N`.

Why this is promising: it is elementary, exact, and creates immediately reusable infrastructure for modular representability of polynomial forms. It also connects directly to `zmod3_vec_three_mul`, suggesting the catalog already contains some `ZMod 3` combinatorial infrastructure.

---

### Strategy 2: Local representability as a CRT-engine
More ambitious, more structural.

1. Define `LocRep m a` using `ZMod m`.
2. Prove transport lemmas under ring equivalences and factorization of moduli.
3. For coprime moduli, derive decomposition of local representability through CRT.
4. Use mod 9 as the first fully solved case, then test small moduli computationally/formally.

Why this is promising: it transforms a one-off congruence theorem into a general Diophantine-local toolkit. This is the infrastructure needed if you want later work on Hensel lifting, local solubility at primes, and eventually Brauer-Manin-style obstructions in a simplified setting.

---

### Strategy 3: Geometric encoding of the Diophantine problem
Most visionary; likely partially formal rather than fully complete this cycle.

1. Define the affine cubic surface as a subtype of triples satisfying the cubic equation.
2. Prove equivalence between representability and nonemptiness of integral points.
3. Define local points modulo `m`.
4. State a formal “weak Hasse principle candidate”:
   ```lean
   def HasLocalPointEverywhere (n : ℤ) : Prop :=
     ∀ m : ℕ, m ≠ 0 → LocRep m (n : ZMod m)
   ```
5. Investigate whether `HasLocalPointEverywhere n` implies `SumThreeCubesRep n`; if not provable, formulate precise counterexample-search infrastructure.

Why this is promising: it moves the project from recreational number theory into arithmetic geometry. Even if you do not settle local-global equivalence, you will have formalized the right language for future work on Hasse failures.

---

## How to Build on Existing Verified Theorems

The current catalog is not directly about three cubes, but there are meaningful bridge opportunities.

1. `zmod3_vec_three_mul`
   - Use it as an entry point to finite-vector arithmetic over `ZMod 3`.
   - Extend the finite-field residue analysis from mod 3 to mod 9, or use mod 3 as the first local obstruction layer.
   - This can support lemmas about cubes in `ZMod 3`, then lift to `ZMod 9` by explicit residue analysis.

2. `hasse_interval_width`
   - While not directly about Hasse principles, it gives a naming and conceptual bridge for “Hasse” infrastructure already present in the catalog.
   - Use it as justification for introducing a new file/theorem namespace around local-global principles and Hasse-style conditions for cubic surfaces.

3. `gradient_sum_bound`, `ultrametric_sum_zero_dominant_bound`
   - These can inspire a non-obvious cross-domain direction: treat modular representability as a discrete energy landscape.
   - Use ultrametric ideas heuristically to organize p-adic/local analysis, especially if you later define p-adic approximation or lifting criteria.
   - This is not the first proof path, but it is fertile for FUTURE_DIRECTIONS.

Do not force irrelevant dependencies into proofs, but do explicitly connect them in comments, theorem naming, or future-architecture notes.

---

## Cross-Domain Connections You Must Exploit

### 1. Arithmetic geometry
The equation \(x^3+y^3+z^3=n\) defines an affine cubic surface. This brings in:
- integral points on varieties,
- local solvability,
- Hasse principle heuristics,
- possible Brauer-Manin-type obstructions in future work.

### 2. Additive combinatorics over finite rings
The image set of the cubic map in `ZMod m` and the sumset
\[
C_m + C_m + C_m,\quad C_m = \{x^3 : x \in \mathbb Z/m\mathbb Z\}
\]
is a clean additive-combinatorial object. This connects to:
- sumset growth,
- residue-class covering,
- cap-set / finite-abelian-group methods,
- explicit computation in finite rings.

### 3. Computation and certified search
Known large examples for specific integers are computationally discovered. Formalize a small certified-search layer:
- if explicit witnesses `(x,y,z)` are known, verify them in Lean,
- if exhaustive residue search modulo `m` rules out a class, certify the exclusion.

This is an excellent proving ground for the interface between symbolic theorem proving and computational number theory.

### 4. p-adic / ultrametric thinking
Three-cubes local solvability is naturally p-adic. Even if full `ℚ_p` formalization is too large, residue towers mod \(p^k\) are a concrete beginning. This is where the catalog’s ultrametric flavor can become unexpectedly relevant.

---

## Suggested Lean 4 Definitions

```lean
def SumThreeCubesRep (n : ℤ) : Prop :=
  ∃ x y z : ℤ, x^3 + y^3 + z^3 = n

def LocRep (m : ℕ) (a : ZMod m) : Prop :=
  ∃ x y z : ZMod m, x^3 + y^3 + z^3 = a

def admissibleMod9 (n : ℕ) : Prop :=
  n % 9 ≠ 4 ∧ n % 9 ≠ 5

def CubicSurfacePoint (n : ℤ) :=
  {p : ℤ × ℤ × ℤ // p.1.1^3 + p.1.2^3 + p.2^3 = n}

def CubicSurfacePointMod (m : ℕ) (a : ZMod m) :=
  {p : ZMod m × ZMod m × ZMod m // p.1.1^3 + p.1.2^3 + p.2^3 = a}

def HasLocalPointEverywhere (n : ℤ) : Prop :=
  ∀ m : ℕ, m ≠ 0 → LocRep m (n : ZMod m)
```

If coercions into `ZMod m` are annoying for `m = 0`, restrict to positive moduli:
```lean
def HasLocalPointEverywhere' (n : ℤ) : Prop :=
  ∀ m : ℕ+, LocRep m (n : ZMod m)
```

---

## Concrete Theorem Bundle to Deliver

Aim to prove as many of these as possible in one coherent file cluster:

```lean
theorem sum_three_cubes_mod9_obstruction (n : ℤ)
    (h : n % 9 = 4 ∨ n % 9 = 5) :
    ¬ SumThreeCubesRep n := by
  sorry

theorem locRep_mod9_exact (a : ZMod 9) :
    LocRep 9 a ↔ a ≠ 4 ∧ a ≠ 5 := by
  sorry

theorem cube_is_sum_of_three_cubes (m : ℤ) :
    SumThreeCubesRep (m^3) := by
  sorry

theorem infinitely_many_sum_three_cubes :
    ∀ B : ℤ, ∃ n : ℤ, Int.natAbs n > Int.natAbs B ∧ SumThreeCubesRep n := by
  sorry

theorem count_admissible_mod9_block (N : ℕ) :
    ((Finset.range (9 * N)).filter (fun n => admissibleMod9 n)).card = 7 * N := by
  sorry

theorem sumThreeCubes_iff_nonempty_cubicSurfacePoint (n : ℤ) :
    SumThreeCubesRep n ↔ Nonempty (CubicSurfacePoint n) := by
  sorry
```

If you achieve these cleanly, add one ambitious theorem:

```lean
theorem local_point_everywhere_of_not_mod9_bad (n : ℤ)
    (h : n % 9 ≠ 4 ∧ n % 9 ≠ 5) :
    LocRep 9 (n : ZMod 9) := by
  sorry
```

Or, more structurally:
```lean
theorem exists_local_point_mod9_iff (n : ℤ) :
    LocRep 9 (n : ZMod 9) ↔ n % 9 ≠ 4 ∧ n % 9 ≠ 5 := by
  sorry
```

---

## What Would Make This a Breakthrough

A fully formalized mod-9 obstruction alone is useful but not revolutionary. What would make this field-opening is:

1. **A reusable local-representability framework** for polynomial equations over `ZMod m`.
2. **A density API** for Diophantine image sets and admissible congruence classes.
3. **A geometric interface** identifying integral and local points on cubic surfaces.
4. **Certified witness verification** for computationally found three-cube representations.
5. **A formal statement of the local-global gap** for this family.

That package would turn a famous recreational problem into a serious arithmetic-geometry testbed in Lean.

---

## File/Architecture Suggestions

Create a coherent cluster such as:
- `Speculative/AutoResearch/NumberTheory/SumThreeCubes/Basic.lean`
- `Speculative/AutoResearch/NumberTheory/SumThreeCubes/Mod9.lean`
- `Speculative/AutoResearch/NumberTheory/SumThreeCubes/LocalGlobal.lean`
- `Speculative/AutoResearch/NumberTheory/SumThreeCubes/Density.lean`

Keep theorem names stable and compositional.

---

## Experimental / Computational Layer

If direct formal proof becomes heavy, support it with a tiny certified computation approach:
- compute the cube image in `ZMod 9`,
- compute the triple sumset,
- then prove the computed list is complete.

Likewise, for explicit famous examples (e.g. specific `n` known to be representable), create theorem statements with concrete witnesses:
```lean
theorem sum_three_cubes_33 :
    SumThreeCubesRep 33 := by
  refine ⟨?x, ?y, ?z, by native_decide⟩
```
only if the witness integers are practical for Lean. This would be a compelling demonstration of theorem-prover-backed computational number theory.

---

## Required Deliverable: FUTURE_DIRECTIONS.md

You must produce a structured `FUTURE_DIRECTIONS.md` with **3–5 testable scientific hypotheses**. Each must be a falsifiable conjecture with a clear computational or formal test.

Include hypotheses of the following kind:

1. **CRT local solvability hypothesis**  
   Conjecture: for every coprime `m n`, `LocRep (m*n) a` is equivalent to simultaneous local representability mod `m` and mod `n`.  
   Test: prove for small coprime pairs by explicit `ZMod` equivalence and search for counterexamples.

2. **Prime-power lifting hypothesis**  
   Conjecture: if `LocRep p a` holds for odd prime `p ≠ 3`, then `LocRep (p^k) a` holds for all `k ≥ 1`.  
   Test: brute-force finite search for small primes/powers; seek a Hensel-style proof.

3. **Density-of-representables hypothesis**  
   Conjecture: among integers `n ≤ N` with `n % 9 ≠ 4,5`, the proportion representable as three cubes tends to `1`.  
   Test: external computation plus formalized counting framework.

4. **Local-global gap hypothesis**  
   Conjecture: there exists `n` such that `HasLocalPointEverywhere n` but `¬ SumThreeCubesRep n`.  
   Test: formalize local predicates mod small prime powers and search for candidate counterexamples.

5. **Finite-ring additive-combinatorics hypothesis**  
   Conjecture: for sufficiently large odd `m` avoiding a finite exceptional set, every admissible residue class mod `m` lies in the triple sumset of cubic residues.  
   Test: compute for `m ≤ M`, detect pattern, then seek CRT-based proof.

These are not “ideas”; they are experimental mathematical programs.

---

## Application Keywords

Diophantine equations; sums of three cubes; cubic surfaces; Hasse principle; local-global principle; modular obstructions; `ZMod`; Chinese remainder theorem; additive combinatorics; asymptotic density; certified computation; arithmetic geometry; integral points; p-adic lifting; formal number theory; Lean 4; Mathlib.

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
