## Assignment: Algebra–Logic–Speculative Temporal Prime Congruence Duality for Reversible Oracle Semirings via Causal Spectra and Certified Fixed-Point Extraction

**Mode:** prove

Prove genuinely new theorems that crystallize a new algebraic semantics of reversible computation. The target is not a variant of existing Stone/Priestley duality, and not a rebranding of temporal Birkhoff theory. The target is a new spectrum-level duality in which **prime temporal congruences** are the semantic atoms of reversible oracle dynamics, and in which **spectral separation** becomes a certified notion of causal distinguishability.

You should aim to formalize the finite, structurally clean core first, so that theorems are actually provable in Lean 4 with Mathlib’s current order/lattice/topology/category infrastructure. Then push the conceptual envelope through carefully chosen definitions that support future generalization.

---

## Core Vision

Build a theory in which a finite reversible oracle semiring carries enough internal temporal structure to define a **prime temporal congruence spectrum** `Specₜ(R)`, and in which this spectrum supports:

1. a **representation theorem** separating elements by prime temporal congruences,
2. a **Stone–Priestley style duality** with finite temporal event frames carrying an involution and oracle-compatible successor structure,
3. a **certified fixed-point extraction theorem** turning spectral compactness/separation into finite reversible certificates of eventual periodicity,
4. an **algorithmic separation theorem** yielding either a causal witness of distinguishability or a certificate of eventual identification.

If achieved, this opens a field: **spectral semantics of reversible computation**. It connects semiring geometry, modal/temporal logic, finite-state dynamics, certified semantics, and proof-producing decision procedures. The conceptual leap is to treat reversible temporal behavior not via raw state graphs but via **prime congruence geometry**, where localization at a spectral point extracts the causal essence of a behavior.

---

## Formal Scope: finite theorem package first

To make this Lean-realistic and mathematically sharp, work in the finite setting first.

Let `R` be a finite semiring with:
- addition and multiplication,
- a time-shift endomorphism `tau : R →+* R`,
- a reversal involution `rho : R ≃+* R`,
- a finite family of oracle endomorphisms indexed by `Ω`,
- compatibility axioms expressing temporal reversibility:
  - `rho.trans rho = Equiv.refl R`,
  - `rho (tau x) = tau.symm?` is too strong unless `tau` is an automorphism,
  - so in the first formal package **assume `tau` is a semiring automorphism** `tau : R ≃+* R`,
  - and require `rho.toEquiv (tau x) = tau.symm (rho x)`.

This avoids pseudo-inverses on endomorphisms and makes the reversible semantics mathematically honest.

A temporal congruence should be an equivalence relation compatible with semiring operations and invariant under `tau`, `rho`, and all oracle maps.

For the finite breakthrough theorem, define primeness in a form Lean can support. Do **not** begin with an overly mystical “collapse of `a*b` and `a+b`” definition unless you can prove it behaves well. Instead, define a prime temporal congruence as a proper temporal congruence whose quotient admits a finite total order compatible with the induced distributive semiring/order structure, or equivalently whose quotient is temporally indecomposable in a separation sense. Then prove equivalence with a more algebraic primeness criterion later.

This is one of the key architectural decisions: first secure a robust formal notion that supports duality and separation; then derive the “collapse” intuition as a theorem.

---

## Precise theorem targets

### 1. Temporal prime separation / representation theorem

For a finite distributive idempotent semiring with reversible temporal structure, if distinct elements are spectrally separated by temporal prime congruences, then the canonical evaluation map into sections over the temporal prime spectrum is injective.

A Lean-oriented statement could be staged as follows:

```lean
structure TemporalOracleSemiring (R : Type*) [Semiring R] where
  tau : R ≃+* R
  rho : R ≃+* R
  oracle : Type*
  act : oracle → (R →+* R)
  rho_involutive : rho.trans rho = MulSemiringEquiv.refl R
  rho_tau : ∀ x : R, rho (tau x) = tau.symm (rho x)

structure IsTemporalCongruence
    {R : Type*} [Semiring R] (T : TemporalOracleSemiring R)
    (c : Setoid R) : Prop :=
  (mul' : ∀ {a b a' b'}, c.Rel a a' → c.Rel b b' → c.Rel (a * b) (a' * b'))
  (add' : ∀ {a b a' b'}, c.Rel a a' → c.Rel b b' → c.Rel (a + b) (a' + b'))
  (tau_stable : ∀ {a b}, c.Rel a b → c.Rel (T.tau a) (T.tau b))
  (rho_stable : ∀ {a b}, c.Rel a b → c.Rel (T.rho a) (T.rho b))
  (oracle_stable : ∀ o {a b}, c.Rel a b → c.Rel (T.act o a) (T.act o b))
```

Then define a finite-spectrum notion:

```lean
def SpectrallySeparated
    {R : Type*} [Fintype R] [DecidableEq R] [Semiring R]
    (T : TemporalOracleSemiring R) : Prop :=
  ∀ ⦃x y : R⦄, x ≠ y →
    ∃ c : Setoid R, IsPrimeTemporalCongruence T c ∧ ¬ c.Rel x y
```

And the representation theorem target:

```lean
theorem temporal_spectrum_representation_injective
    {R : Type*} [Fintype R] [DecidableEq R]
    [Semiring R] [IsIdempotentSemiring R]
    (T : TemporalOracleSemiring R)
    (hsep : SpectrallySeparated T) :
    Function.Injective (canonicalSectionMap T)
```

Here `canonicalSectionMap T : R → SectionAlgebra (SpecT T)` should be defined concretely in the finite setting as pointwise evaluation modulo prime temporal congruences. You do not need sheaf theory at first; a “section algebra” can simply be the product over spectral points of finite quotient values, with continuity/topology added later as structure.

**Breakthrough significance:** this says temporal prime congruences are not merely observational tools; they are complete enough to recover the algebra. That is the spectral semantics analogue of recovering a space from its points, but now the points are causal quotient behaviors.

---

### 2. Finite temporal Priestley duality with involution and oracle action

Define a finite temporal Priestley frame as a finite ordered topological space (in finite settings, topology may be reconstructed from clopen up-sets), equipped with:
- an order-reversing involution `rev`,
- an order-preserving automorphism `next`,
- a family of oracle-labeled endomorphisms preserving the Priestley structure,
- compatibility `rev ∘ next = next⁻¹ ∘ rev`.

A Lean skeleton:

```lean
structure FiniteTemporalPriestleyFrame where
  X : Type*
  instFintype : Fintype X
  instDecEq : DecidableEq X
  le : X → X → Prop
  instPartialOrder : PartialOrder X
  next : X ≃ X
  rev : X ≃ X
  oracle : Type*
  act : oracle → (X → X)
  rev_involutive : Function.Involutive rev
  rev_next : ∀ x, rev (next x) = next.symm (rev x)
  act_monotone : ∀ o, Monotone (act o)
  next_monotone : Monotone next
```

Then formulate the contravariant equivalence theorem at the level of categories of finite objects:

```lean
theorem finite_temporal_priestley_duality :
  Nonempty
    (CategoryTheory.Equivalence
      (FiniteReversibleOracleSemiringCat)
      (FiniteTemporalPriestleyFrameCatᵒᵖ))
```

If full categorical equivalence is too large for one cycle, prove the pair of reconstruction theorems:

```lean
theorem semiring_to_frame_to_semiring_iso
    (R : FiniteReversibleOracleSemiringCat) :
    Nonempty ((TemporalFrameSemiring (TemporalSpec R)) ≅ R)

theorem frame_to_semiring_to_frame_iso
    (X : FiniteTemporalPriestleyFrameCat) :
    Nonempty ((TemporalSpec (FrameSemiring X)) ≅ X)
```

**Breakthrough significance:** this would be the first duality in which finite reversible computational semantics are encoded by prime congruence spectra rather than by raw automata or Kripke structures. It creates a transfer principle:
- algebraic identities ↔ temporal frame constraints,
- quotient semantics ↔ order-topological separation,
- reversibility ↔ spectral involution.

This is the exact kind of theorem that births a subject.

---

### 3. Certified fixed-point extraction from spectral compactness/separation

This is the most novel theorem. In finite settings, “spectrally compact orbit closure” should be made concrete and computable. Since every finite space is compact, the meaningful hypothesis is not compactness alone but **finite spectral recurrence under separation**, i.e. the orbit of `x` in the prime-spectrum evaluation algebra has finitely many distinct local images. Then eventual periodicity follows by pigeonhole, but the breakthrough is to extract a **certificate object** functorially from the spectral data.

Define a certificate structure:

```lean
structure ReversibleCertificate (R : Type*) [Semiring R] where
  preperiod : ℕ
  period : ℕ
  period_pos : 0 < period
  witness : R
  stabilizes : Prop
```

More refined:

```lean
structure OrbitCertificate
    {R : Type*} [Semiring R] (T : TemporalOracleSemiring R) (x : R) where
  preperiod : ℕ
  period : ℕ
  period_pos : 0 < period
  prime : Setoid R
  isPrime : IsPrimeTemporalCongruence T prime
  periodic_mod_prime :
    prime.Rel ((T.tau ^ (preperiod + period)) x) ((T.tau ^ preperiod) x)
```

Then the extraction theorem:

```lean
theorem certified_eventual_periodicity
    {R : Type*} [Fintype R] [DecidableEq R]
    [Semiring R] [IsIdempotentSemiring R]
    (T : TemporalOracleSemiring R) (x : R)
    (hrec : FiniteSpectralOrbit T x) :
    ∃ C : OrbitCertificate T x, True
```

And the functoriality theorem:

```lean
theorem certificate_functorial_under_quotient
    {R S : Type*} [Fintype R] [Fintype S] [DecidableEq R] [DecidableEq S]
    [Semiring R] [Semiring S]
    (T₁ : TemporalOracleSemiring R) (T₂ : TemporalOracleSemiring S)
    (f : R →+* S)
    (hf : IsTemporalQuotientMap T₁ T₂ f)
    {x : R} :
    ∀ C : OrbitCertificate T₁ x,
      ∃ D : OrbitCertificate T₂ (f x), CertificatePushforward hf C D
```

The theorem should ultimately state more than mere existence: the certificate is **computable** from finite orbit data in the quotient/stalk. In Lean, “computable” can be represented by defining an explicit function:

```lean
def extractCertificate
    {R : Type*} [Fintype R] [DecidableEq R]
    [Semiring R]
    (T : TemporalOracleSemiring R) (x : R) :
    Option (OrbitCertificate T x)
```

and proving correctness under the recurrence hypothesis.

**Breakthrough significance:** this converts spectral semantics into proof-producing dynamics. The spectrum is not merely descriptive; it yields executable certificates of eventual behavior. This is the bridge from abstract duality to certified verification.

---

### 4. Algorithmic separation/dichotomy theorem

Prove that for finite reversible oracle semirings, there is a finite procedure which, given `x y : R`, either:
- outputs a prime temporal congruence separating them, or
- outputs a finite reversible certificate that their temporal images eventually identify in every prime quotient compatible with the given constraints.

Lean target:

```lean
inductive SeparationResult
    {R : Type*} [Semiring R] (T : TemporalOracleSemiring R) (x y : R) where
  | separated
      (c : Setoid R)
      (hc : IsPrimeTemporalCongruence T c)
      (hxy : ¬ c.Rel x y)
  | eventually_identical
      (N k : ℕ)
      (hk : 0 < k)
      (h : ∀ c, IsPrimeTemporalCongruence T c →
          c.Rel ((T.tau ^ (N + k)) x) ((T.tau ^ N) y))

theorem decide_temporal_separation
    {R : Type*} [Fintype R] [DecidableEq R]
    [Semiring R] [IsIdempotentSemiring R]
    (T : TemporalOracleSemiring R) (x y : R) :
    SeparationResult T x y
```

This is intentionally bold. If the full dichotomy is too strong, first prove decidability of spectral separation:

```lean
theorem decidable_spectral_separation
    {R : Type*} [Fintype R] [DecidableEq R]
    [Semiring R]
    (T : TemporalOracleSemiring R) :
    Decidable (SpectrallySeparated T)
```

Then refine to witness extraction.

**Breakthrough significance:** this gives a proof-producing semantics engine for reversible systems. It is the semiring-spectrum analogue of model checking with certificates.

---

## Recommended proof architecture: three strategic paths

### Strategy A: Finite duality via distributive-lattice reduction
**Most promising for Lean.**

1. Reduce the additive/idempotent semiring structure to a finite distributive lattice/order:
   - in idempotent semirings, use `a ≤ b :↔ a + b = b`;
   - prove `tau`, `rho`, and oracle actions are order endomorphisms/automorphisms.
2. Define temporal congruences first as lattice congruences stable under the extra structure.
3. Use finite Priestley/Stone-style separation on clopen up-sets or prime filters/ideals.
4. Reconstruct the semiring from order-theoretic sections; multiplication is then shown compatible and preserved by the duality data.

Why this is promising:
- Mathlib is strongest on orders, finite types, lattices, equivalences, and category-theoretic packaging of dualities.
- Prime congruence machinery for general semirings is comparatively sparse; reducing to distributive-lattice congruences makes the project formalizable now.
- The reversible temporal operators naturally act on the order side.

### Strategy B: Prime congruence spectrum directly from quotient indecomposability
1. Define temporal congruences on semirings directly.
2. Define prime temporal congruences as proper congruences with temporally irreducible quotient.
3. Construct `Specₜ(R)` as a finite topological poset using basic opens:
   - `U(a,b) = { p | ¬ p.Rel a b }`.
4. Prove `T₀`, compactness, and basis properties directly.
5. Build the canonical evaluation map into the product of quotient stalks.

Why it is valuable:
- This is closer to the intended conceptual breakthrough.
- It gives the cleanest algebraic semantics.

Why it is harder:
- You will need to invent and verify many congruence-level lemmas from scratch.
- The right notion of primeness is delicate and can derail the formalization if chosen too ambitiously.

### Strategy C: Automata/dynamics first, spectrum second
1. Regard `tau`, `rho`, and oracle actions as generating a finite transformation monoid/groupoid on `R`.
2. Define behavioral equivalence by invariant congruences under this action.
3. Use orbit decomposition and Myhill–Nerode-style minimization ideas to produce canonical quotients.
4. Show prime temporal congruences are exactly minimal nontrivial separators of this action.
5. From these minimal separators, recover a Priestley-style dual space.

Why it is exciting:
- Strong cross-connection to automata theory and reversible computation.
- May make the certificate extraction theorem nearly automatic.

Why it is secondary:
- Harder to align immediately with existing Stone/Priestley infrastructure in Lean.
- Best used to guide intuition and future generalization, even if Strategy A carries the formal proof.

**Recommendation:** execute Strategy A as the formal spine, borrow the conceptual language of Strategy B for theorem statements, and use Strategy C to motivate the certificate extraction and algorithmic corollary.

---

## Key intermediate lemmas you should prove

These are the actual bridge stones. Without them, the grand theorems will remain slogans.

1. **Order from idempotent addition**
```lean
theorem add_idem_order
    {R : Type*} [Semiring R] [IsIdempotentSemiring R] :
    PartialOrder R
```
or use an existing canonical order construction if available.

2. **Temporal maps preserve the canonical order**
```lean
theorem tau_monotone
    {R : Type*} [Semiring R] [IsIdempotentSemiring R]
    (T : TemporalOracleSemiring R) :
    Monotone T.tau
```
and similarly for oracle actions; `rho` should be an order isomorphism or anti-isomorphism depending on your chosen convention.

3. **Finite temporal congruences form a bounded lattice**
```lean
theorem temporal_congruence_finite_lattice
    {R : Type*} [Fintype R] [DecidableEq R] [Semiring R]
    (T : TemporalOracleSemiring R) :
    Finite (TemporalCongruence T)
```

4. **Basic opens separate points iff prime temporal congruences separate elements**
```lean
theorem spectral_separation_iff_eval_injective ...
```

5. **Finite orbit recurrence in quotient stalks**
```lean
theorem finite_quotient_orbit_eventually_periodic
    {R : Type*} [Fintype R] [DecidableEq R] [Semiring R]
    (T : TemporalOracleSemiring R)
    (c : Setoid R) (hc : IsTemporalCongruence T c)
    (x : Quotient c) :
    ∃ N k, 0 < k ∧ ((T.inducedTau c)^[N+k] x = (T.inducedTau c)^[N] x)
```

6. **Certificate extraction by minimal repetition**
```lean
theorem extractCertificate_spec ...
```

7. **Functoriality of induced certificates under quotient maps**
```lean
theorem pushforward_certificate_spec ...
```

These are the actual engine room.

---

## Cross-domain connections you should exploit explicitly

This project becomes field-opening only if you make the hidden analogies precise.

### 1. Reversible computation and algebraic geometry
Prime temporal congruences are the reversible-computation analogue of prime ideals:
- a spectral point is not a state but an **irreducible observational mode**,
- localization at a point extracts a “causal stalk,”
- distinguishability becomes geometric separation.

This is a new semantics for reversible programs, reversible circuits, and bidirectional transition systems.

### 2. Modal/temporal logic and Priestley duality
The `tau` automorphism and `rho` involution act like temporal modalities with converse:
- `tau` = next,
- `tau.symm` = previous,
- `rho` = time reversal / converse modality.

Your duality theorem should be described as a semantics for a finite fragment of **reversible temporal logic**. This opens the possibility of algebraizing converse temporal modalities via semiring spectra.

### 3. Automata theory and Myhill–Nerode minimization
Temporal congruences stable under oracle action are reminiscent of language congruences and behavioral equivalences. The prime ones should behave like minimal witnesses of observational distinction. The algorithmic corollary is then a spectral analogue of DFA minimization with richer algebraic content.

### 4. Certified verification and proof-producing computation
The certificate extraction theorem turns compactness/recurrence into machine-checkable evidence of stabilization. This resonates with:
- liveness/safety verification,
- certified model checking,
- proof-carrying code,
- formal methods for reversible systems.

### 5. Dynamical systems and eventual periodicity
Finite orbit recurrence is elementary, but your theorem reframes it through spectral localization. This is the nontrivial step: periodicity is not proved in the raw system, but **extracted from prime quotient geometry**. That is the conceptual novelty.

### 6. Universal algebra and congruence geometry
If successful, this suggests a broader theory of:
- temporal congruence spectra for algebras with operators,
- reversible dualities for finite algebraic systems,
- geometric semantics of fixed points and recurrence.

This is where the project can scale beyond semirings.

---

## How to build on likely catalog infrastructure

You said to build on catalog Stone/Priestley and prime-congruence infrastructure from recent proof-certificate work. Use it aggressively, but with a clean separation of responsibilities:

1. **Reuse finite spectral/topological separation lemmas**
   - If the catalog already has finite Stone/Priestley separation by clopens, adapt the basis from ordinary inequalities/non-membership to pair-nonseparation sets `U(a,b)`.
   - The crucial transfer lemma is that these sets form a clopen up-set basis on the temporal spectrum.

2. **Reuse quotient/certificate patterns**
   - If there is existing “certificate extraction” infrastructure from tropical proof systems, repurpose the pattern:
     - finite witness object,
     - correctness theorem,
     - functoriality under morphisms.
   - Replace tropical margin/separation by temporal recurrence modulo prime congruence.

3. **Reuse finite duality category skeletons**
   - If finite duality categories and equivalence constructors already exist, instantiate them with:
     - objects = finite reversible oracle semirings / finite temporal Priestley frames,
     - morphisms = semiring maps commuting with `tau`, `rho`, and oracle action / frame maps preserving order, successor, involution, oracle labels.

4. **Reuse decidability and Fintype machinery**
   - The algorithmic corollary should lean heavily on `Fintype`, `Finset`, quotient enumeration, and decidability of finite predicates.

Do not merely cite these ingredients. State which exact lemmas or patterns you are importing and how the temporal layer modifies them.

---

## Lean formalization advice

To maximize success:

- Start with **finite** structures and explicit `Fintype`, `DecidableEq`.
- Package temporal structure in a single structure extending semiring data only by maps and laws.
- Avoid sheaf-theoretic abstractions at first. Model “sections” as dependent products over finite spectral points.
- Use `Setoid` for congruences initially; later wrap them into a richer structure if needed.
- For duality, prove explicit reconstruction isomorphisms before packaging categorical equivalence.
- If semiring primeness becomes unwieldy, define prime temporal congruence through the dual order/lattice semantics first, then derive the semiring-facing characterization.

A realistic formal sequence is:

1. define `TemporalOracleSemiring`,
2. define temporal congruence,
3. define finite spectrum,
4. define basic opens and order,
5. prove separation/injectivity,
6. define finite temporal frames,
7. prove reconstruction theorems,
8. define certificates,
9. prove extraction and functoriality,
10. prove decision procedure.

---

## Concrete theorem package to aim for in Lean

At minimum, produce the following theorem names or close analogues:

```lean
theorem temporal_basicOpen_clopen
theorem temporal_spectrum_T0
theorem temporal_spectrum_compact_finite
theorem temporal_prime_separates_of_ne
theorem temporal_spectrum_representation_injective
theorem temporal_frame_reconstruction
theorem temporal_semiring_reconstruction
theorem finite_temporal_priestley_duality
theorem finite_quotient_orbit_eventually_periodic
def extractCertificate
theorem extractCertificate_correct
theorem certificate_functorial_under_quotient
theorem decide_temporal_separation
```

If you need to split the project, the first decisive milestone is:

> **Milestone theorem:** finite spectrally separated reversible oracle semirings embed injectively into the product of their prime temporal quotient stalks, with a computable eventual-periodicity certificate for each element in each stalk.

That alone would already be a publishable conceptual nucleus.

---

## Application keywords

reversible computation; semiring semantics; prime congruence spectrum; Priestley duality; Stone duality; temporal logic; converse modalities; oracle computation; causal spectra; certified fixed points; eventual periodicity; proof-producing verification; finite-state dynamics; algebraic automata theory; congruence geometry; localization; spectral separation; formal semantics; Lean 4; Mathlib; computable certificates

---

## Standard of novelty

Do not settle for “there exists some duality-like correspondence.” Prove a theorem where:
- the objects are precise,
- the maps are functorial,
- the spectrum separates,
- the duality reconstructs,
- the certificates compute.

The key phrase to keep in mind is:

> **Prime temporal congruences are the geometric points of reversible causality.**

Make that sentence true in Lean.

---

## Deliverables

1. Lean files formalizing the finite theory and proving the main theorems above.
2. Minimal use of `sorry`, with any remaining gaps isolated to clearly marked technical lemmas.
3. A structured `FUTURE_DIRECTIONS.md` containing **3–5 concrete breakthrough-level next steps**, for example:
   - extension from finite to spectral/Noetherian reversible semirings,
   - converse temporal logic completeness via prime temporal spectra,
   - relation to coalgebraic bisimulation and reversible automata,
   - sheaf/stalk semantics for local causal certificates,
   - extension from semirings to quantales / dioids / semiring-enriched categories.

Be explicit in that file: each direction should state a theorem-level target, why it matters, and what existing machinery from this project makes it plausible.

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
    "algorithms": [ { "name": "...", "pseudocode": "..." } ],
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

Research domain: Bridges
Research mode: prove
