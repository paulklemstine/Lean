## Assignment: Direction 1: Non-Abelian Arithmetic Phase Classification

**Mode:** `prove`

Prove genuinely new, non-trivial theorems in Lean 4, building explicitly on the catalog results
- `Pythagorean/ArithmeticPhaseClassification.lean`
  - `HasPTorsion_ZMod_iff_dvd`
  - `torsionProfileUpTo_prod`
- `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean`
  - `torsion_invisible_wrong_characteristic`

Minimize `sorry`. Do not settle for a reformulation of existing abelian results: the goal is to create a mathematically meaningful non-abelian phase classifier that survives contact with concrete finite groups and derived invariants.

---

## Central Vision

The abelianization map
\[
\pi : G \to G^{\mathrm{ab}} := G/[G,G]
\]
is the universal homological shadow of a non-abelian finite gauge group. The bold thesis of this project is that **prime-level arithmetic phase data seen by first-order torsion probes is already completely encoded in this shadow**. If true, this would identify a sharp boundary between genuinely non-abelian physics and homological arithmetic observables: it would say that all prime-detectable torsion phases accessible to derived functors of additive invariants collapse to abelianization.

That is not merely an extension of an abelian theorem. It is a classification principle: **non-abelian gauge theories may have complicated fusion and representation structure, but their first arithmetic phase portrait could be controlled by a universal linearized quotient.**

If the theorem fails, that failure is equally revolutionary: it would isolate the first derived obstruction beyond abelianization and open a new theory of “non-abelian arithmetic anomalies.”

---

## Precise Theorem Targets

You should introduce a new formal notion of arithmetic phase detection for finite groups, designed to mediate between group theory, homological algebra, and physical phase language.

### New definition to introduce

Define a new concept, for a finite group `G` and prime `p`, expressing that `p` is visible to homological arithmetic probes through the abelianized coefficient system.

Suggested shape:

```lean
def PrimePhaseVisibleViaAbelianization
    (G : Type*) [Group G] [Finite G] (p : ℕ) : Prop :=
  HasPTorsion ((Abelianization G)) p
```

This is only the starting point. The real novelty should be a second definition capturing non-abelian phase visibility intrinsically, not merely by abbreviation. For example:

```lean
def PrimeHomologicalPhaseVisible
    (G : Type*) [Group G] [Finite G] (p : ℕ) : Prop :=
  ∃ A : Type*, ∃ _ : AddCommGroup A,
    -- a coefficient object or additive probe derived from G
    True
```

You must refine this into an actual usable Lean definition tied to available Mathlib/catalo​g infrastructure. The point is to formalize a **new mathematical structure** expressing “phase information detectable by homological probes.”

A more structured option is to define a torsion profile function:

```lean
def arithmeticPhaseProfile
    (G : Type*) [Group G] [Finite G] : Set ℕ :=
  {p | PrimeHomologicalPhaseVisible G p}
```

and then prove comparison theorems against the abelianization profile.

---

## Main theorem statement

### Theorem A: Abelianization controls prime torsion visibility

Mathematical statement:
\[
\forall G\ \text{finite},\ \forall p \text{ prime},\ 
\mathrm{PrimeHomologicalPhaseVisible}(G,p)
\leftrightarrow
\mathrm{HasPTorsion}(G^{\mathrm{ab}},p).
\]

Suggested Lean 4 type signature:

```lean
theorem primePhaseVisible_iff_hasPTorsion_abelianization
    (G : Type*) [Group G] [Finite G] (p : ℕ) [Fact p.Prime] :
    PrimeHomologicalPhaseVisible G p ↔
      HasPTorsion (Abelianization G) p := by
  -- deep proof
```

This is the conceptual core. It says that for the class of probes you define, non-abelianity is invisible at the prime-torsion level.

If your chosen formalization of `PrimeHomologicalPhaseVisible` makes the exact biconditional too ambitious, prove the strongest mathematically meaningful pair of implications:

```lean
theorem primePhaseVisible_of_hasPTorsion_abelianization
    ...

theorem hasPTorsion_abelianization_of_primePhaseVisible
    ...
```

---

### Theorem B: Isomorphic abelianizations imply identical arithmetic phase profiles

Mathematical statement:
\[
\forall G_1,G_2\ \text{finite},\ 
G_1^{\mathrm{ab}} \cong G_2^{\mathrm{ab}}
\;\Longrightarrow\;
\forall p \text{ prime},\
\mathrm{PrimeHomologicalPhaseVisible}(G_1,p)
\leftrightarrow
\mathrm{PrimeHomologicalPhaseVisible}(G_2,p).
\]

Suggested Lean 4 type signature:

```lean
theorem arithmeticPhaseProfile_equiv_of_abelianization_iso
    (G₁ G₂ : Type*) [Group G₁] [Finite G₁] [Group G₂] [Finite G₂]
    (e : Abelianization G₁ ≃* Abelianization G₂)
    (p : ℕ) [Fact p.Prime] :
    PrimeHomologicalPhaseVisible G₁ p ↔
      PrimeHomologicalPhaseVisible G₂ p := by
  -- use Theorem A + transport across e
```

This is the exact formalization of the classification principle in the conjecture.

---

### Theorem C: Concrete separation/classification for benchmark groups

You must prove explicit benchmark computations for the groups named in the conjecture. The minimum acceptable package is:

\[
\mathrm{Profile}(S_3)=\{2\},\qquad
\mathrm{Profile}(A_4)=\{3\},\qquad
\mathrm{Profile}(Q_8)=\{2\}.
\]

Suggested Lean theorem shapes:

```lean
theorem primePhaseVisible_S3_iff
    (p : ℕ) [Fact p.Prime] :
    PrimeHomologicalPhaseVisible (Equiv.Perm (Fin 3)) p ↔ p = 2 := by
  -- identify abelianization with ZMod 2

theorem primePhaseVisible_A4_iff
    (p : ℕ) [Fact p.Prime] :
    PrimeHomologicalPhaseVisible AlternatingGroup.A4 p ↔ p = 3 := by
  -- identify abelianization with ZMod 3

theorem primePhaseVisible_Q8_iff
    (p : ℕ) [Fact p.Prime] :
    PrimeHomologicalPhaseVisible QuaternionGroup8 p ↔ p = 2 := by
  -- identify abelianization with ZMod 2 × ZMod 2
```

If the exact group names differ in Mathlib, adapt them, but do not weaken the mathematical target. These examples are not decoration; they are the first non-abelian calibration points of the theory.

---

## Stronger breakthrough theorem to attempt

If feasible, push to a theorem at the level of profiles rather than pointwise primes:

\[
\forall G\ \text{finite},\ 
\mathrm{arithmeticPhaseProfile}(G)
=
\mathrm{torsionProfileUpTo}(G^{\mathrm{ab}})
\]
for a suitable profile notion imported from the catalog.

Suggested Lean shape:

```lean
theorem arithmeticPhaseProfile_eq_torsionProfile_abelianization
    (G : Type*) [Group G] [Finite G] :
    arithmeticPhaseProfile G =
      arithmeticPhaseProfileOfAbelianGroup (Abelianization G) := by
  ext p
  constructor <;> intro hp
  · ...
  · ...
```

This would be the cleanest “phase classification theorem.”

---

## Proof architecture: 3 viable strategies

### Strategy A: Universal-property reduction through abelianization
**Most promising.**

1. Define your homological phase detector so that it is functorial with respect to group homomorphisms and invariant under passage to the maximal abelian quotient.
2. Use the universal property of `Abelianization G` to factor any additive/homological probe through the quotient map `G → Abelianization G`.
3. Apply catalog torsion results (`HasPTorsion_ZMod_iff_dvd`, `torsionProfileUpTo_prod`) to compute the resulting prime profile on the abelian side.

Why this is promising:
- It matches the conjectural mathematics exactly.
- It converts a non-abelian classification problem into a controlled abelian computation.
- It creates a reusable blueprint for later higher-derived generalizations.

Lean tactics likely needed:
- `rcases` for quotient/factorization arguments,
- `induction` on finitely generated abelian decompositions if needed,
- `calc` chains transporting equivalences,
- `by_contra` when showing no extra prime can appear.

---

### Strategy B: Derived-functor invisibility in wrong characteristic
1. Use `torsion_invisible_wrong_characteristic` as the key obstruction theorem.
2. Show that the only primes that can survive the additive derived functor you use are those dividing the torsion structure of the abelianized coefficient object.
3. Prove both directions:
   - if `p ∣ |G^ab|`, then a torsion witness exists;
   - if `p ∤ |G^ab|`, then derived torsion is invisible.

Why it matters:
- This ties the project directly to derived-functor technology rather than merely quotient-group structure.
- It gives a stronger interpretation: the theorem is not just group-theoretic, but a statement about **homological detectability thresholds**.

Lean tactics likely needed:
- `field_simp` if cardinality/divisibility arguments pass through rational identities or normalized counting expressions,
- `calc` for divisibility equivalences,
- `by_contra` to contradict wrong-characteristic invisibility.

---

### Strategy C: Finite-group case study first, then abstract generalization
1. Prove explicit benchmark theorems for `S₃`, `A₄`, and `Q₈`.
2. Observe from these examples that the phase profile coincides with the prime divisors of the abelianization.
3. Abstract the common proof pattern into a general theorem.

Why this is useful:
- It derisks the project if the fully abstract theorem is initially too hard.
- It produces publishable concrete results even before the full classification is complete.
- It can reveal counterexamples or hidden hypotheses early.

This strategy is especially valuable if the available Mathlib support for `Abelianization` and explicit finite groups is uneven.

---

## Required deep theorem inventory

Your Lean file must contain at least **3 substantial theorems** whose proofs are not trivial and genuinely use multi-step mathematical reasoning. A suggested minimum set:

1. `primePhaseVisible_iff_hasPTorsion_abelianization`
2. `arithmeticPhaseProfile_equiv_of_abelianization_iso`
3. one concrete computation theorem among `S₃`, `A₄`, `Q₈`
4. ideally a fourth theorem giving profile equality or monotonicity under products/quotients

At least three of these proofs should visibly use tools such as:
- `induction`
- `rcases`
- `by_contra`
- `field_simp`
- multi-step `calc`

Do not pad with tautologies.

---

## Cross-domain connection theorem

You must include at least one theorem that explicitly bridges this arithmetic phase theory to a different domain.

### Recommended bridge: lattice gauge theory / topological order heuristic encoded as a mathematical invariant
Formalize a theorem saying that prime phase visibility is stable under direct-product composition of independent gauge sectors:

\[
\mathrm{Profile}(G \times H)=\mathrm{Profile}(G)\cup\mathrm{Profile}(H),
\]
provided your phase detector is defined through abelianization/additive probes.

Suggested Lean signature:

```lean
theorem arithmeticPhaseProfile_prod
    (G H : Type*) [Group G] [Finite G] [Group H] [Finite H]
    (p : ℕ) [Fact p.Prime] :
    PrimeHomologicalPhaseVisible (G × H) p ↔
      PrimeHomologicalPhaseVisible G p ∨ PrimeHomologicalPhaseVisible H p := by
  -- reduce to abelianization of product, then use torsionProfileUpTo_prod
```

Why this is a true domain bridge:
- Algebraically, it is a statement about products and torsion.
- Physically, it says independent gauge sectors superpose by **phase-union** at the prime level.
- Homologically, it identifies a Künneth-style compositional law for arithmetic phase data.

**Application keywords:** topological order, lattice gauge theory, homological probes, derived functors, anomaly detection, phase composition law.

---

## Concrete computational test program

The conjecture is falsifiable and must be treated scientifically.

### Falsifiable conjecture
State explicitly in Lean comments and in `FUTURE_DIRECTIONS.md`:

\[
\forall G_1,G_2\ \text{finite},\ 
G_1^{\mathrm{ab}}\cong G_2^{\mathrm{ab}}
\Rightarrow
\mathrm{arithmeticPhaseProfile}(G_1)=\mathrm{arithmeticPhaseProfile}(G_2).
\]

### Computational disproof test
Implement a verified or semi-verified computational method that:
1. computes or approximates `arithmeticPhaseProfile G` for small finite groups,
2. computes abelianization data,
3. compares groups with isomorphic abelianizations,
4. searches for a counterexample.

Benchmark at minimum:
- `S₃`
- `A₄`
- `Q₈`
- and, if feasible, one additional pair of non-isomorphic groups with the same abelianization.

Your `demo.py` should:
- print the predicted profile from abelianization,
- print the computed profile from your detector,
- declare whether they match,
- visualize prime profiles as sets or bitmasks.

---

## Lean-oriented formal targets

You should aim for theorem statements close to the following:

```lean
def arithmeticPhaseProfile
    (G : Type*) [Group G] [Finite G] : Set ℕ :=
  {p | PrimeHomologicalPhaseVisible G p}

theorem primePhaseVisible_iff_hasPTorsion_abelianization
    (G : Type*) [Group G] [Finite G] (p : ℕ) [Fact p.Prime] :
    PrimeHomologicalPhaseVisible G p ↔
      HasPTorsion (Abelianization G) p := by
  ...

theorem arithmeticPhaseProfile_equiv_of_abelianization_iso
    (G₁ G₂ : Type*) [Group G₁] [Finite G₁] [Group G₂] [Finite G₂]
    (e : Abelianization G₁ ≃* Abelianization G₂) :
    arithmeticPhaseProfile G₁ = arithmeticPhaseProfile G₂ := by
  ext p
  by_cases hp : p.Prime
  · letI : Fact p.Prime := ⟨hp⟩
    simpa [arithmeticPhaseProfile, primePhaseVisible_iff_hasPTorsion_abelianization]
  · simp [arithmeticPhaseProfile, hp]

theorem arithmeticPhaseProfile_prod
    (G H : Type*) [Group G] [Finite G] [Group H] [Finite H] :
    arithmeticPhaseProfile (G × H) =
      arithmeticPhaseProfile G ∪ arithmeticPhaseProfile H := by
  ext p
  by_cases hp : p.Prime
  · letI : Fact p.Prime := ⟨hp⟩
    -- reduce to abelianization/product torsion profile
    ...
  · simp [arithmeticPhaseProfile, hp]
```

If `HasPTorsion` is only currently available for abelian groups or specific coefficient objects, adapt by introducing an intermediary definition and proving equivalence to the catalog notion.

---

## What would make this a breakthrough

If successful, this project opens a new program:

- a **homological arithmetic classification of non-abelian gauge phases**;
- a precise boundary between information captured by abelianization and information requiring genuinely non-abelian derived invariants;
- a formal bridge between finite group theory, derived functors, and lattice gauge phenomenology.

If the main conjecture fails, then the counterexample is equally valuable: it would identify the first place where non-abelian structure survives homological linearization, suggesting a new invariant beyond abelianization, perhaps involving Schur multipliers, low-degree group homology, or representation-theoretic torsion.

---

## Deliverables (MANDATORY)

You must produce **all** of the following:

1. **Lean development** with the new definitions and at least 3 substantial theorems, minimizing `sorry`.
2. **A verified algorithm or computational method** for comparing arithmetic phase profiles via abelianization and direct computation.
3. **`demo.py`** demonstrating the benchmark groups and the conjecture test interactively.
4. **`FUTURE_DIRECTIONS.md`** containing **3–5 falsifiable scientific hypotheses**, each with:
   - a precise conjectural statement,
   - a clear computational or formal test,
   - what outcome would count as disproof.
5. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - motivation,
   - theorem statements,
   - proof ideas,
   - examples,
   - significance,
   - next questions.
   It must be understandable without reading the code.
6. **`ARTICLE.md`** in Scientific American style:
   - engaging,
   - concept-driven,
   - broad-audience accessible,
   - focused on the mathematics and scientific meaning,
   - **do not focus on verification machinery**.

---

## Final charge

Do not merely show that abelianization exists. Force it to classify something surprising.

Either prove that the first arithmetic phase portrait of a non-abelian finite gauge theory is entirely controlled by its abelianization, or find the exact obstruction. In either case, isolate a mathematically sharp invariant, compute it on canonical non-abelian groups, and turn the result into a platform for a new science of arithmetic phases.

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

Research domain: Pythagorean
Research mode: prove
