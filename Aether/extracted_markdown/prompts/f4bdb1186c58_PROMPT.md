## Assignment: Hilbert 12 Beyond Kronecker–Weber — Formal Hilbert Class Field Infrastructure and First Explicit Reciprocity Theorems

**Mode:** prove + formalize + discover

Prove new, non-trivial theorems that create the *infrastructure* for a genuine Lean formalization of the first nontrivial layer of Hilbert’s 12th problem: from cyclotomic explicit class field theory over `ℚ` toward canonical unramified abelian extensions over general number fields. Do **not** merely restate Kronecker–Weber. Build the bridge from ideal-theoretic class groups to Galois groups of unramified abelian extensions, in a form that Mathlib can sustain and future cycles can amplify toward explicit reciprocity and automorphic parametrization.

The existing catalog theorems listed below are not directly in algebraic number theory, so use them opportunistically as structural lemmas or inspiration for finiteness / congruence / spectral viewpoints, but the real opportunity is to erect a new formal tower in Lean:
- ideal classes as quotient objects,
- principal ideals as a subgroup,
- finite class groups under suitable hypotheses,
- Hilbert class field as a maximal unramified abelian extension *defined axiomatically first, then instantiated when possible*,
- Artin-type map on prime ideals away from ramification in finite Galois extensions,
- first reciprocity statements in restricted settings.

This is a cold start. That means the most valuable contribution is not a flashy isolated lemma, but a **field-opening blueprint theorem** that future work can extend into explicit class field theory and eventually Langlands-compatible statements.

---

## Mathematical Framing

Kronecker–Weber says every finite abelian extension of `ℚ` lies in a cyclotomic extension. Hilbert 12 asks for analogous explicit generators for abelian extensions of more general number fields. The immediate formal target is not the full dream; it is the first invariant object that survives abstraction: the **Hilbert class field** `H/K`, characterized by:
1. `H/K` finite abelian,
2. `H/K` unramified at all finite places,
3. every ideal class of `K` becomes principal in `H`,
4. `Gal(H/K)` canonically identifies with the ideal class group `Cl(K)`.

In Lean, the revolutionary step is to formalize enough of this architecture so that future work can attach:
- ray class fields,
- idèle class groups,
- Artin reciprocity,
- explicit generators via modular / CM functions,
- abelian Langlands over global fields.

This is the correct formal gateway from algebraic number theory into arithmetic geometry and automorphic representation theory.

---

## Primary Theorem Targets

Because full Hilbert class field existence may currently exceed available Mathlib infrastructure, pursue the following theorem stack. The first two are mandatory and should be fully proved. The third is an ambitious interface theorem and may be partially formalized with clean definitions and proved in special cases.

### Theorem A: Principal ideals form a normal subgroup of fractional ideals
Formalize the ideal-class-group quotient mechanism in a concrete setting.

A precise theorem target:

```lean
theorem principalFractionalIdeals_normal
  (K : Type*) [Field K] [NumberField K] :
  Subgroup.Normal ((principalFractionalIdeals K).toSubgroup)
```

If the exact Mathlib objects do not yet exist, define a concrete surrogate using nonzero fractional ideals of the ring of integers `𝓞 K`:

```lean
theorem principal_ideal_setoid_is_congruence
  (K : Type*) [Field K] [NumberField K] :
  Equivalence (fun I J : FractionalIdeal (𝓞 K)⁰ K =>
    ∃ x : Kˣ, I = x • J)
```

Breakthrough value: this is the algebraic kernel from which the ideal class group is born. Once certified, quotient-based class field constructions become possible.

---

### Theorem B: Class group triviality implies PID-style principality of invertible ideals
This is the first robust theorem that turns quotient structure into arithmetic content.

```lean
theorem classGroup_trivial_iff_every_fractionalIdeal_principal
  (K : Type*) [Field K] [NumberField K] :
  Subsingleton (ClassGroup (𝓞 K)) ↔
    ∀ I : FractionalIdeal (𝓞 K)⁰ K, IsPrincipal I
```

A weaker but still excellent version is acceptable if Mathlib constraints force you to work with nonzero ideals or Dedekind domains in general:

```lean
theorem classGroup_trivial_iff_every_nonzero_ideal_principal
  (R K : Type*) [CommRing R] [IsDomain R] [Field K]
  [Algebra R K] [IsFractionRing R K] [IsDedekindDomain R] :
  Subsingleton (ClassGroup R) ↔
    ∀ I : Ideal R, I ≠ ⊥ → IsPrincipal I
```

Breakthrough value: this theorem converts abstract class group data into ideal generation, giving the formal engine behind “Hilbert class field kills the class group.” It is the ideal-theoretic shadow of class field theory.

---

### Theorem C: In a finite unramified abelian extension with universal capitulation, Galois group is controlled by the class group
This is the first reciprocity-shaped theorem. Even if a fully general canonical isomorphism is too ambitious, prove a special-case injective/surjective comparison theorem.

Preferred theorem shape:

```lean
theorem gal_unramifiedAbelian_ext_surj_from_classGroup
  (K L : Type*) [Field K] [Field L]
  [NumberField K] [NumberField L] [Algebra K L]
  [FiniteDimensional K L] [IsGalois K L] :
  IsUnramifiedEverywhere K L →
  IsAbelian (L ≃ₐ[K] L) →
  (∀ I : Ideal (𝓞 K), I ≠ ⊥ → ∃ J : Ideal (𝓞 L), IsPrincipal (Ideal.comap ?_ J)) →
  Nonempty ((ClassGroup (𝓞 K)) →* MulAut ((L ≃ₐ[K] L)))
```

This exact signature may need adaptation, but the mathematical content should be:

> If `L/K` is finite, abelian, everywhere unramified, and every ideal class of `K` capitulates in `L`, then there is a natural surjective morphism from `Cl(K)` to `Gal(L/K)`. Under maximality assumptions, this is an isomorphism.

If the maximality assumption cannot be formalized, prove the **surjection** or a **cardinality inequality**:
```lean
theorem card_gal_le_card_classGroup ...
```

Breakthrough value: this is the first formal articulation of Hilbert class field philosophy in Lean. Even a finite-cardinality inequality would be major, because it opens the route to proving the Hilbert class field characterization by universal properties.

---

## Special-Case Explicit Theorem You Should Strongly Consider

If general number fields are too heavy for current infrastructure, attack the first nontrivial explicit case where Hilbert 12 is alive:

### Imaginary quadratic case, abstract version
Prove that if `K` is an imaginary quadratic field with class number one, then every nonzero ideal of `𝓞 K` is principal.

```lean
theorem imaginaryQuadratic_classNumberOne_principal
  (d : ℤ)
  (hd1 : Squarefree d) (hd2 : d < 0)
  (hclass : Fintype.card (ClassGroup (ringOfIntegers (QuadraticField d))) = 1) :
  ∀ I : Ideal (ringOfIntegers (QuadraticField d)), I ≠ ⊥ → IsPrincipal I
```

This theorem is not yet full class field theory, but it is the perfect launchpad toward CM, singular moduli, and explicit generation of abelian extensions. It ties directly to Hilbert 12 in the one setting where the dream is classically realized.

---

## Lean 4 Formalization Targets

Use concrete formal objects wherever possible, but do **not** artificially downgrade the mathematics to `Nat` or `Matrix` if the theorem genuinely belongs in abstract algebraic structures. The right compromise is:
- concrete finite quotients where possible,
- explicit subgroups and quotients,
- cardinality theorems with `Fintype.card`,
- ring of integers / ideals / class groups from Mathlib if available,
- otherwise define a minimal local abstraction layer in a new file.

Candidate file targets:
- `NumberTheory/ClassField/HilbertClassFieldBasic.lean`
- `NumberTheory/ClassField/IdealClassGroupBridge.lean`
- `NumberTheory/ClassField/UnramifiedAbelianComparison.lean`

Suggested theorem signatures to aim for, adjusting to actual Mathlib names:

```lean
theorem principalIdeals_subgroup_normal
  (R : Type*) [CommRing R] [IsDomain R] :
  (principalIdealsSubgroup R).Normal

theorem classGroup_eq_bot_iff
  (R : Type*) [CommRing R] [IsDomain R] [IsDedekindDomain R] :
  Subsingleton (ClassGroup R) ↔
    ∀ I : Ideal R, I ≠ ⊥ → IsPrincipal I

theorem card_gal_unramified_abelian_le_classNumber
  (K L : Type*) [Field K] [Field L] [NumberField K] [NumberField L]
  [Algebra K L] [FiniteDimensional K L] [IsGalois K L] [Fintype (L ≃ₐ[K] L)] :
  IsUnramifiedEverywhere K L →
  IsAbelian (L ≃ₐ[K] L) →
  Fintype.card (L ≃ₐ[K] L) ≤ Fintype.card (ClassGroup (𝓞 K))
```

Even if some typeclasses are unavailable, preserve the theorem *shape*.

---

## Proof Strategy Architecture

### Strategy A: Quotient-first algebraic infrastructure
**Most promising** because it aligns with existing Mathlib strengths in groups, quotients, ideals, and finite algebra.

1. Define the principal-ideal relation on invertible / fractional ideals and prove it is a congruence.
2. Construct the quotient as a commutative group; identify triviality of the quotient with principality of all relevant ideals.
3. For extensions `L/K`, define capitulation as the map induced by extension of ideals, then prove kernel/image statements.
4. In unramified abelian settings, extract a comparison morphism from class group data to Galois data.

Why this is best: Lean is very good at universal properties, subgroup quotients, and transport through equivalences. This path creates reusable infrastructure instead of a one-off theorem.

---

### Strategy B: Dedekind-domain factorization route
Best if Mathlib already has rich support for Dedekind domains, unique factorization of ideals, and class groups.

1. Use prime ideal factorization to represent nonzero ideals as finite products of prime powers.
2. Show principal ideals form a subgroup under ideal multiplication.
3. Characterize the class group as the obstruction to selecting generators compatibly.
4. Deduce triviality/principality equivalences and cardinality bounds through factorization arguments.

Why it may work: ideal arithmetic in Dedekind domains is often easier than field-extension machinery. This gives strong arithmetic theorems before touching Hilbert class fields.

---

### Strategy C: Axiomatic Hilbert class field interface
Best for visionary reach, even if some existential content remains abstract.

1. Define a structure:
   ```lean
   structure IsHilbertClassField (K L : Type*) ... : Prop := 
     (finite : FiniteDimensional K L)
     (galois : IsGalois K L)
     (abelian : IsAbelian (L ≃ₐ[K] L))
     (unramified : IsUnramifiedEverywhere K L)
     (artin_bijective : Nonempty (ClassGroup (𝓞 K) ≃* (L ≃ₐ[K] L)))
   ```
2. Prove that any two such fields are `K`-algebra isomorphic by transporting the Artin bijection.
3. Derive corollaries: class number equals extension degree, trivial class group implies `L ≃ K`, capitulation of all ideals.

Why this is powerful: even before constructing `L`, you formalize the *correct universal object*. This creates a stable API for future explicit constructions.

---

## Cross-Domain Connections You Must Exploit

### 1. Langlands program
The abelian case of Langlands over number fields is class field theory. A formal Hilbert class field API is the first certified bridge from:
- ideal class groups / idèle classes
to
- 1-dimensional Galois representations / Hecke characters.

You should explicitly note in comments and documentation that:
- `Gal(H/K)` is the prototype of the abelianized absolute Galois group,
- class-group characters correspond to unramified Hecke characters,
- this is the degree-zero shadow of automorphic reciprocity.

A later theorem can convert class group characters
```lean
ClassGroup (𝓞 K) →* ℂˣ
```
into 1-dimensional Galois characters of `Gal(H/K)`.

---

### 2. Arithmetic geometry / complex multiplication
For imaginary quadratic fields, Hilbert 12 is realized by singular moduli and CM elliptic curves. Even if you do not formalize modular functions yet, define the endpoint:
- class group acts on CM elliptic curves,
- `j`-invariants generate Hilbert class fields,
- class number equals the size of the CM orbit.

This suggests future formal theorems relating:
```lean
Fintype.card (ClassGroup (𝓞 K))
```
to the number of CM isomorphism classes of elliptic curves with endomorphism ring `𝓞 K`.

---

### 3. Computational algebra / cryptography
Class groups and unramified abelian extensions appear in computational number theory and post-quantum constructions. A verified class-group-to-Galois interface can support:
- certified computation of class numbers,
- ideal arithmetic verification,
- explicit generation of abelian extensions,
- validation of CM methods for elliptic curve generation.

This is a rare chance to connect pure formalized mathematics to certified computational arithmetic.

---

## How to Build on the Existing Catalog

The provided catalog theorems are not directly about class field theory, but they can still be repurposed conceptually:

- `prime_cong_zero_class_prime_theory` may inspire or support congruence-class reasoning around primes and quotient structures.
- `idempotent_hilbert_basis_theorem` may be useful as a structural analogy for finite generation / basis extraction in quotient constructions.
- `fundamental_theorem_algebraic_light'` suggests some existing algebraic-light machinery may already package divisibility or polynomial reasoning; inspect for reusable lemmas.
- `bayes_theorem` and `insufficient_qubits_theorem` are likely orthogonal, but you should still seek a **cross-domain bridge theorem** if possible: e.g. “class group characters as finite Fourier modes” linking arithmetic statistics to information theory.

Do not force these into the proof. Use them only if they genuinely help.

---

## High-Value Auxiliary Lemmas

You will likely need a web of supporting lemmas. Good targets include:

```lean
theorem isPrincipal_mul {R} ... :
  IsPrincipal I → IsPrincipal J → IsPrincipal (I * J)

theorem isPrincipal_inv {R} ... :
  IsPrincipal I → IsPrincipal I⁻¹

theorem principal_ideal_ext_map
  (R S : Type*) ... :
  IsPrincipal I → IsPrincipal (Ideal.map (algebraMap R S) I)

theorem classGroup_eq_one_of_all_principal
  (R : Type*) [CommRing R] [IsDomain R] [IsDedekindDomain R] :
  (∀ I : Ideal R, I ≠ ⊥ → IsPrincipal I) → Subsingleton (ClassGroup R)

theorem classGroup_card_eq_one_iff
  (R : Type*) [CommRing R] [IsDomain R] [IsDedekindDomain R] [Fintype (ClassGroup R)] :
  Fintype.card (ClassGroup R) = 1 ↔ Subsingleton (ClassGroup R)
```

These are not glamorous, but they are exactly the sort of lemmas from which paradigm-shifting theorems become formalizable.

---

## What Would Count as a Breakthrough Here

A genuine breakthrough in this cycle would be **any one** of the following:

1. A clean Lean formalization of the ideal class group as a quotient with principality/triviality equivalence.
2. A special-case theorem showing unramified abelian extension degree is bounded by class number.
3. An axiomatic `IsHilbertClassField` structure with uniqueness and arithmetic consequences.
4. An imaginary quadratic class-number-one theorem tied to principal ideals and future CM generation.

Any of these would open a formal path toward:
- ray class fields,
- Artin reciprocity,
- explicit CM class field generation,
- abelian Langlands formalization.

That is not incremental. That is a new research program.

---

## Application Keywords

Hilbert 12, Kronecker–Weber, class field theory, Hilbert class field, ideal class group, Dedekind domain, fractional ideals, Artin reciprocity, abelian extensions, unramified extensions, ring of integers, imaginary quadratic fields, complex multiplication, singular moduli, Langlands correspondence, Hecke characters, Galois representations, arithmetic geometry, certified computational number theory, formalized algebraic number theory.

---

## Deliverables

1. **Lean 4 code** proving at least one major theorem from Theorem A/B/C above, with minimal `sorry`.
2. If full generality is blocked, prove the strongest special case available and document exactly which Mathlib gaps prevent the next step.
3. Create `FUTURE_DIRECTIONS.md` with **3–5 testable scientific hypotheses**, each a precise falsifiable conjecture with a clear test.
4. Optionally create `ARTICLE.md` explaining the mathematical architecture and why it matters for Hilbert 12 and abelian Langlands.

---

## Required FUTURE_DIRECTIONS.md Content

Include 3–5 directions in this exact spirit:

### [Artin Map Surjectivity in Finite Unramified Abelian Extensions]
**Conjecture**: For every number field `K` and every finite extension `L/K` satisfying `IsHilbertClassField K L`, there exists a canonical group isomorphism `ClassGroup (𝓞 K) ≃* (L ≃ₐ[K] L)`.
**Test**: Formalize `IsHilbertClassField`; prove the induced map is injective and surjective in successively stronger special cases, beginning with trivial class group and finite class number assumptions.

### [Imaginary Quadratic CM Generator Formalization]
**Conjecture**: For an imaginary quadratic field `K`, the minimal polynomial of a suitable CM `j`-invariant generates an extension whose degree equals `Fintype.card (ClassGroup (𝓞 K))`.
**Test**: Formalize the class polynomial degree statement first, then compare with class group cardinality in concrete discriminants.

### [Capitulation Kernel Detection]
**Conjecture**: For finite extensions `L/K`, the kernel of the ideal extension map `ClassGroup (𝓞 K) → ClassGroup (𝓞 L)` is trivial whenever `L/K` is unramified and linearly disjoint from the Hilbert class field of `K`.
**Test**: Define the capitulation map and verify triviality in explicit small examples or under stronger algebraic hypotheses.

### [Abelian Langlands Shadow Theorem]
**Conjecture**: Characters of `ClassGroup (𝓞 K)` are in canonical bijection with unramified one-dimensional Galois characters factoring through `Gal(H/K)` for any Hilbert class field `H` of `K`.
**Test**: After formalizing `IsHilbertClassField`, prove the equivalence by transporting characters across the class-group/Galois-group isomorphism.

### [Class Number as Arithmetic Complexity]
**Conjecture**: The cardinality of `ClassGroup (𝓞 K)` controls the complexity of certified ideal factorization algorithms in a formally measurable way.
**Test**: Implement certified ideal arithmetic for sample number fields and compare proof-term or runtime complexity against class number growth.

Make these hypotheses mathematically sharp and experimentally actionable.

---

## Final Directive

Do not dilute the project into vague “formalize class field theory.” Instead, force the first irreversible milestone:

> **Construct in Lean the algebraic interface that makes the Hilbert class field a definable and uniquely characterizable object, and prove at least one theorem that identifies ideal-class data with principality or unramified abelian Galois data.**

That is the seed from which formal Hilbert 12 and abelian Langlands can actually grow.

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

Research domain: Algebra
Research mode: prove
