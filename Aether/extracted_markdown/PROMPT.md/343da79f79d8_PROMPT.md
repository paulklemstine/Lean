Soli Deo Gloria

## Assignment: Direction 2: Nonlinear Extraction Obstructions

**Mode:** prove

Prove genuinely new, non-trivial theorems at the boundary of Σ-protocol extraction theory. Build directly on:

- `Catalog/Cryptography/AffineSigmaExtraction.lean`
- especially the theorem `no_unique_extract_of_noninj`

but do **not** merely restate the affine obstruction in nonlinear language. The goal is to formalize a sharp algebraic boundary: when the response depends nonlinearly on the witness, two-transcript extraction ceases to be a theorem of pure algebra, and recovery requires enough transcripts to overcome algebraic multiplicity.

This is not an incremental variant. It is a blueprint for a **polynomial theory of extraction**, where transcript consistency defines an algebraic variety and extraction becomes an elimination problem.

---

## Core Vision

In the affine case, special soundness is linear algebra. In the nonlinear case, it becomes **algebraic geometry over finite fields**: each transcript cuts out a hypersurface in witness space, and extraction means proving that the intersection of these hypersurfaces is a singleton or at least finite and algorithmically recoverable.

Your task is to establish the first rigorous formal boundary theorem for this transition.

The scientific breakthrough is to show:

1. **Two transcripts are fundamentally insufficient in general** for nonlinear witness dependence, even when the challenge values differ.
2. **Additional transcripts can restore extractability**, not by linear inversion but by forcing uniqueness of the polynomial image.
3. The right abstraction is not “linear independence of challenges” but **injectivity of the polynomial observation map** induced by transcript families.

This opens a formal research program in:
- polynomial special soundness,
- algebraic transcript geometry,
- Gröbner/elimination-based extraction,
- lower bounds for transcript complexity of nonlinear proof systems.

---

## Precise Mathematical Target

Work over a finite field `𝔽 = ZMod p` with `Fact p.Prime`, and model nonlinear response functions of the form

\[
z = t + c \cdot f(w)
\]

where:
- `w : 𝔽` is the witness,
- `t : 𝔽` is transcript blinding,
- `c : 𝔽` is the challenge,
- `f : 𝔽 → 𝔽` is nonlinear, with primary case `f(w)=w^2`.

The key phenomenon is that transcripts only reveal the value `f(w)`, not necessarily `w`, so extraction is governed by fiber cardinality of `f`.

---

## New Definitions You Should Introduce

Define at least one genuinely new concept not already present in the catalog. Suggested definitions:

### 1. Polynomial transcript consistency
A family of transcripts is consistent with witness `w` under `f` if there exists a common `t` such that all equations hold:
\[
z_i = t + c_i \cdot f(w).
\]

Lean target:
```lean
def PolyTranscriptConsistent
    {F : Type*} [Field F]
    (f : F → F) (cs zs : List F) : Prop :=
  ∃ t w, ∀ i : Fin cs.length,
    zs.get i = t + (cs.get i) * f w
```

### 2. Polynomial observation map
For a fixed challenge family `cs`, define the map sending `(t,w)` to the transcript vector:
\[
(t,w) \mapsto (t + c_1 f(w), \dots, t + c_n f(w)).
\]

Lean target:
```lean
def polyObservationMap
    {F : Type*} [Field F]
    (f : F → F) (cs : List F) : F × F → List F :=
  fun tw => cs.map (fun c => tw.1 + c * f tw.2)
```

### 3. Transcript-extractability
A challenge family `cs` is extractable for `f` if equality of transcript vectors forces equality of witnesses.

Lean target:
```lean
def TranscriptExtractable
    {F : Type*} [Field F]
    (f : F → F) (cs : List F) : Prop :=
  ∀ {t1 t2 w1 w2},
    polyObservationMap f cs (t1, w1) = polyObservationMap f cs (t2, w2) →
    w1 = w2
```

This is the correct nonlinear analogue of affine uniqueness.

You may also define a weaker notion:
```lean
def ImageExtractable
    {F : Type*} [Field F]
    (f : F → F) (cs : List F) : Prop :=
  ∀ {t1 t2 w1 w2},
    polyObservationMap f cs (t1, w1) = polyObservationMap f cs (t2, w2) →
    f w1 = f w2
```

This weaker notion is often the true algebraic invariant.

---

## Exact Theorem Statements to Formalize

You must prove at least **3 substantial theorems**. The following are the primary targets.

---

### Theorem 1: Two-transcript extraction reduces to injectivity of `f`

If two challenges are distinct, equal transcript pairs force equality of `f(w)`, but not of `w` unless `f` is injective.

Mathematical statement:

For any field `F`, any function `f : F → F`, and distinct challenges `c₁ ≠ c₂`,
if
\[
z_1 = t_1 + c_1 f(w_1), \quad z_2 = t_1 + c_2 f(w_1),
\]
and also
\[
z_1 = t_2 + c_1 f(w_2), \quad z_2 = t_2 + c_2 f(w_2),
\]
then
\[
f(w_1)=f(w_2).
\]
Hence, if `f` is noninjective, witness extraction from two transcripts fails in general.

Lean 4 type signature target:
```lean
theorem two_transcript_eq_image_of_ne
    {F : Type*} [Field F]
    {f : F → F} {c1 c2 t1 t2 w1 w2 z1 z2 : F}
    (hneq : c1 ≠ c2)
    (hz1₁ : z1 = t1 + c1 * f w1)
    (hz2₁ : z2 = t1 + c2 * f w1)
    (hz1₂ : z1 = t2 + c1 * f w2)
    (hz2₂ : z2 = t2 + c2 * f w2) :
    f w1 = f w2
```

And then the obstruction theorem:

```lean
theorem two_transcript_no_unique_extract_of_noninj
    {F : Type*} [Field F]
    {f : F → F}
    (hnoninj : ¬ Function.Injective f) :
    ∃ c1 c2 z1 z2 w1 w2 t1 t2,
      c1 ≠ c2 ∧ w1 ≠ w2 ∧
      z1 = t1 + c1 * f w1 ∧
      z2 = t1 + c2 * f w1 ∧
      z1 = t2 + c1 * f w2 ∧
      z2 = t2 + c2 * f w2
```

This theorem is the nonlinear successor to `no_unique_extract_of_noninj`.

**Why this matters:** It proves that the obstruction is not merely “linearity breaks,” but “only the polynomial image is observable.” This is the exact conceptual shift from affine extraction to algebraic extraction.

---

### Theorem 2: Quadratic protocols over odd fields are not two-transcript extractable

Specialize to `f(w)=w^2`. Over any field of characteristic not 2, the map is noninjective because `w` and `-w` collide.

Mathematical statement:

If `F` is a field with `2 ≠ 0`, then for any distinct challenges `c₁ ≠ c₂`, there exist distinct witnesses `w` and `-w` producing identical two-transcript data up to suitable blindings.

Lean 4 target:
```lean
theorem square_two_transcript_not_extractable
    {F : Type*} [Field F]
    (h2 : (2 : F) ≠ 0) :
    ∃ c1 c2 z1 z2 w1 w2 t1 t2,
      c1 ≠ c2 ∧ w1 ≠ w2 ∧
      z1 = t1 + c1 * (w1^2) ∧
      z2 = t1 + c2 * (w1^2) ∧
      z1 = t2 + c1 * (w2^2) ∧
      z2 = t2 + c2 * (w2^2)
```

A stronger and cleaner variant over `ZMod p` with `p` odd:

```lean
theorem zmod_square_noninjective_of_odd_prime
    (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) :
    ¬ Function.Injective (fun x : ZMod p => x^2)
```

Then combine with Theorem 1.

**Why this matters:** It formalizes the first concrete nonlinear impossibility result for a Σ-protocol-shaped acceptance rule.

---

### Theorem 3: Three transcripts determine the polynomial image when two challenges differ

For any function `f`, once you have at least two distinct challenges among a transcript family sharing the same blinding `t`, the value `f(w)` is uniquely determined by the transcript vector. A third transcript does not recover `w` in general, but it can overdetermine consistency and support algorithmic recovery of `f(w)`.

A mathematically precise and provable theorem is:

If `cs : List F` contains two distinct entries, then equality of transcript vectors implies equality of `f(w)`.

Lean 4 target:
```lean
theorem image_extractable_of_two_distinct_challenges
    {F : Type*} [Field F]
    {f : F → F} {cs : List F}
    (hcs : ∃ i j : Fin cs.length, i ≠ j ∧ cs.get i ≠ cs.get j) :
    ImageExtractable f cs
```

This is a list/vector generalization of Theorem 1 and is conceptually deep: transcript families identify only the polynomial image unless further assumptions are made on `f`.

You should prove this by selecting two distinct challenge coordinates and subtracting equations.

**Why this matters:** It identifies the exact invariant exposed by transcript data, namely `f(w)`. This is the proper notion of extraction in nonlinear systems.

---

### Theorem 4: Injective nonlinear image implies full extraction

If `f` happens to be injective on the relevant witness domain, then two distinct challenges suffice for extraction.

Lean 4 target:
```lean
theorem two_transcript_extractable_of_injective
    {F : Type*} [Field F]
    {f : F → F}
    (hinj : Function.Injective f) :
    ∀ {c1 c2}, c1 ≠ c2 →
    ∀ {t1 t2 w1 w2 z1 z2},
      z1 = t1 + c1 * f w1 →
      z2 = t1 + c2 * f w1 →
      z1 = t2 + c1 * f w2 →
      z2 = t2 + c2 * f w2 →
      w1 = w2
```

This theorem completes the dichotomy:
- distinct challenges recover `f(w)`,
- injectivity of `f` upgrades image extraction to witness extraction.

This is the nonlinear replacement for affine special soundness.

---

### Theorem 5: Consistency criterion for transcript families

Prove a theorem characterizing when a transcript family can arise from some `(t,w)`.

For challenge list `cs` and response list `zs`, consistency is equivalent to existence of a scalar `y` in the image of `f` such that
\[
z_i - z_j = (c_i-c_j)y
\]
for all pairs `i,j`.

Lean 4 target:
```lean
theorem poly_transcript_consistent_iff_pairwise
    {F : Type*} [Field F]
    {f : F → F} {cs zs : List F}
    (hlen : cs.length = zs.length) :
    PolyTranscriptConsistent f cs zs ↔
    ∃ y, (∃ w, f w = y) ∧
      ∀ i j : Fin cs.length,
        zs.get i - zs.get j = (cs.get i - cs.get j) * y
```

This theorem is excellent because it uses:
- existential unpacking (`rcases`),
- pairwise algebra,
- multi-step `calc`,
- possibly `field_simp` when deriving formulas in fraction fields.

**Why this matters:** It converts transcript validity into an algebraic rank-1 condition, paving the way for Gröbner-style elimination and algorithmic extractors.

---

## Lean 4 Proof Architecture

You asked for deeper mathematical insight, so the proof plan should be structural, not tactical-only.

### Strategy A: Difference-elimination algebra
Most promising for the first wave.

1. Write transcript equations for two witnesses.
2. Subtract equations coordinatewise:
   \[
   (c_i-c_j)(f(w_1)-f(w_2)) = 0.
   \]
3. Use existence of distinct challenges to conclude `f(w₁)=f(w₂)`.
4. Upgrade to `w₁=w₂` under injectivity.

Why this is strongest:
- minimal dependencies,
- clean Lean implementation,
- directly generalizes the affine proof,
- reveals the true invariant: the polynomial image.

Expected tactics:
- `rcases`
- `have`
- `linarith` is optional, but better to rely on `ring_nf`, `nlinarith`, or direct field cancellation
- `field_simp` when solving for `f w`
- `calc` chains for equation subtraction

---

### Strategy B: Observation-map injectivity
Elegant and conceptually powerful.

1. Define `polyObservationMap f cs`.
2. Prove that if `cs` contains two distinct challenges, then the map
   \[
   (t,w) \mapsto (t + c_i f(w))_i
   \]
   factors through `(t, f(w))`.
3. Show this factorization is injective in the second coordinate exactly up to `f(w)`.
4. Deduce witness extractability iff `f` is injective.

Why this matters:
- gives a reusable abstraction for future polynomial extraction,
- supports later multivariate witness generalizations,
- ties naturally to category-style factorization and algebraic statistics.

This strategy is especially good for `RESEARCH_PAPER.md`, because it states the phenomenon in modern mathematical language.

---

### Strategy C: Algebraic-geometry / elimination perspective
Most visionary, possibly partially formalized.

1. Model transcript equations as polynomial equations in variables `t,w`.
2. For `f(w)=w^2`, the solution set for fixed transcripts is a finite algebraic set.
3. Two transcripts define a variety with involutive symmetry `w ↔ -w`.
4. Three or more transcripts can be used to test consistency of the image parameter `y = w^2`, reducing extraction to elimination.

In Lean, you may not fully formalize Gröbner bases, but you can formalize the low-dimensional algebra that motivates them.

Why this is revolutionary:
- recasts cryptographic extraction as elimination theory,
- links Σ-protocol soundness to computational algebraic geometry,
- opens a path to `MvPolynomial`-based extractors.

---

## Cross-Domain Connections You Must Surface

### 1. Cryptography × Algebraic Geometry
Transcript equations define affine varieties over finite fields. Non-unique extraction corresponds to positive fiber cardinality of the projection to transcript space.

Keywords:
- affine variety
- fiber cardinality
- elimination ideal
- identifiability

### 2. Cryptography × Computational Algebra
Extraction becomes solving a polynomial system, not a linear one. This naturally invites:
- Gröbner bases,
- resultants,
- elimination orders,
- finite-field polynomial solving.

### 3. Cryptography × Inverse Problems / Algebraic Statistics
The transcript vector is an observation model, and witness extraction is an **identifiability problem**. The distinction between recovering `f(w)` and recovering `w)` mirrors latent-variable identifiability.

### 4. Cryptography × Physics
Quadratic witness dependence introduces a gauge-like symmetry `w ~ -w`, analogous to physical states identified under symmetry. Extraction fails because observables see only the orbit.

This is exactly the kind of connection that makes the result memorable.

---

## Recommended Lean File Scope

Create a focused file, for example:

`Scratch/NonlinearSigmaExtraction.lean`

or, if integrating more permanently:

`Catalog/Cryptography/NonlinearSigmaExtraction.lean`

Use and cite:
- `Catalog/Cryptography/AffineSigmaExtraction.lean`
- `Mathlib/Data/ZMod/Basic`
- `Mathlib/FieldTheory/Finite/Basic`
- `Mathlib/Data/Polynomial`
- possibly `Mathlib/Data/MvPolynomial/Basic`

---

## Concrete Proof Milestones

You must include at least 3 nontrivial theorems whose proofs use multi-step reasoning. A suggested sequence:

1. `two_transcript_eq_image_of_ne`
   - core elimination theorem
   - use subtraction and cancellation

2. `two_transcript_no_unique_extract_of_noninj`
   - use `hnoninj` to obtain `w1 ≠ w2` with equal image
   - construct equal transcripts explicitly
   - use `rcases` and witness construction

3. `two_transcript_extractable_of_injective`
   - combine theorem 1 with injectivity
   - conceptually closes the dichotomy

4. `zmod_square_noninjective_of_odd_prime`
   - choose `1` and `-1`
   - show they are distinct in odd characteristic
   - show squares coincide

5. `image_extractable_of_two_distinct_challenges`
   - list/vector generalization
   - use coordinate extraction with `Fin`

6. `poly_transcript_consistent_iff_pairwise`
   - deepest theorem in the file
   - pairwise-difference criterion

If time is limited, prioritize 1, 2, 4, and 5.

---

## Testable Conjecture You Must State

You must include at least one falsifiable conjecture with a clear computational test.

### Conjecture A: Degree-based image extraction threshold
For `f : F → F` a polynomial of degree `d`, transcript families with at least two distinct challenges always determine `f(w)`, but recovering `w` generically requires enough side constraints to separate fibers of `f`; for `f(w)=w^d` over `ZMod p`, the generic ambiguity is exactly the size of the kernel of the `d`-th power map on `Fˣ`.

Computational test:
- For primes `p`,
- enumerate witnesses for `f(w)=w^d`,
- compute transcript collisions under fixed distinct challenges,
- verify that collision multiplicity matches `gcd(d, p-1)` on nonzero witnesses.

This can be disproved by a single counterexample prime.

### Conjecture B: Pairwise-difference criterion extends to multivariate witnesses
For `f : F^n → F`, transcript families determine the scalar image `f(w)` whenever two challenges differ, and witness extraction reduces to injectivity of `f` on the witness domain.

Computational test:
- sample quadratic forms `Q(x)` over `ZMod p`,
- search for transcript collisions among distinct witnesses,
- verify that all collisions satisfy `Q(x)=Q(y)`.

### Conjecture C: Generic quadratic forms need only image extraction
For nondegenerate quadratic forms over odd finite fields, two transcripts determine the quadratic value but witness fibers have cardinality approximately `p^{n-1}`.

Computational test:
- enumerate fibers of `Q`,
- compare transcript collision classes to level sets of `Q`.

---

## Verified Algorithmic Deliverable

You must provide a verified computational method, not just theorems.

### Required algorithm
Implement an extractor for the polynomial image `y = f(w)` from two transcripts with distinct challenges:

\[
y = \frac{z_1-z_2}{c_1-c_2}.
\]

Then recover `t` via
\[
t = z_1 - c_1 y.
\]

Lean target:
```lean
def extractImage
    {F : Type*} [Field F]
    (c1 c2 z1 z2 : F) : Option (F × F) :=
  if h : c1 = c2 then none
  else
    let y := (z1 - z2) / (c1 - c2)
    let t := z1 - c1 * y
    some (t, y)
```

Prove correctness:
```lean
theorem extractImage_correct
    {F : Type*} [Field F]
    {f : F → F} {c1 c2 t w z1 z2 : F}
    (hneq : c1 ≠ c2)
    (hz1 : z1 = t + c1 * f w)
    (hz2 : z2 = t + c2 * f w) :
    extractImage c1 c2 z1 z2 = some (t, f w)
```

This is a real verified extractor — not for the witness, but for the polynomial image. That distinction is scientifically central.

You may also include a brute-force finite-field witness enumerator in `demo.py` to exhibit non-uniqueness for squares.

---

## demo.py Requirements

Your `demo.py` must do all of the following:

1. Pick odd primes `p` such as `5, 7, 11`.
2. Define transcripts
   \[
   z_i = t + c_i w^2 \mod p.
   \]
3. Show explicit collisions:
   - `w` and `-w` produce identical transcript pairs.
4. Implement image extraction:
   - recover `y = w^2`
   - recover `t`
5. For 3 or more transcripts, verify pairwise-difference consistency.
6. Empirically test the conjecture on collision multiplicities for `w^d`.

This demo should be interactive and visibly support the formal theorems.

---

## RESEARCH_PAPER.md Narrative

Your standalone paper must explain, without relying on the code:

- the affine special soundness paradigm,
- why nonlinear witness dependence changes the mathematics,
- the exact theorem: two transcripts determine only `f(w)`,
- the square-map obstruction over odd fields,
- the observation-map factorization,
- the algorithm extracting the image parameter,
- why this reframes extraction as an algebraic identifiability problem,
- future directions toward multivariate polynomial protocols and Gröbner-based extraction.

A reader should come away thinking: “special soundness is secretly elimination theory.”

---

## ARTICLE.md Narrative

Write it in Scientific American style. The central metaphor should be:

> Linear protocols are like hearing a melody and identifying the note. Nonlinear protocols are like hearing only the intensity of a sound: many different notes can produce the same energy.

Explain:
- why two conversations with a prover are enough in the linear world,
- why quadratic dependence creates mirror-image witnesses,
- how the mathematics reveals hidden symmetry,
- why this matters for next-generation proof systems.

---

## FUTURE_DIRECTIONS.md Requirements

Include **3–5 testable scientific hypotheses**, each falsifiable. Suggested hypotheses:

1. **Power-map fiber law:** For `f(w)=w^d` over `ZMod p`, transcript collision multiplicity equals `gcd(d, p-1)` away from zero.
2. **Quadratic-form level-set law:** For nondegenerate quadratic forms `Q : (ZMod p)^n → ZMod p`, transcript collisions coincide exactly with equal-value level sets of `Q`.
3. **Generic image-extraction universality:** For any polynomial response family `z = t + c·f(w)`, two distinct challenges always suffice to recover the image parameter `f(w)` by a universal rational formula.
4. **Elimination-based extractor feasibility:** For bounded-degree multivariate `f`, Gröbner elimination over transcript equations yields a practical extractor for the algebraic image in small dimensions.
5. **Symmetry-obstruction principle:** Failure of witness extraction is controlled by automorphisms preserving `f`, e.g. `w ↦ -w` for squares.

Each hypothesis must have:
- a precise statement,
- a proposed computational experiment,
- a clear criterion for refutation.

---

## Application Keywords

Include these explicitly in your writeup and comments:

- Σ-protocols
- special soundness
- nonlinear extraction
- polynomial identifiability
- algebraic cryptanalysis
- affine varieties over finite fields
- elimination theory
- Gröbner bases
- transcript geometry
- finite-field inverse problems
- witness ambiguity
- quadratic forms
- symmetry obstruction
- verified extraction algorithm

---

## Final Standard

Deliver a file with real mathematical weight. The ideal outcome is a clean formal theorem schema:

> Distinct challenges recover the polynomial image; injectivity of the witness map is exactly what upgrades image recovery to witness extraction.

That statement is simple, memorable, and field-opening. It transforms a cryptographic folklore intuition into a precise algebraic doctrine.

Produce **all** of:
- `FUTURE_DIRECTIONS.md`
- `RESEARCH_PAPER.md`
- `ARTICLE.md`
- a verified algorithm/computational method in Lean
- `demo.py`

Minimize sorry. Avoid trivial proofs. Use induction / `rcases` / `by_contra` / `field_simp` / multi-step `calc` in substantive ways. The result should feel like the first page of a new chapter in formal cryptographic algebra.

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
