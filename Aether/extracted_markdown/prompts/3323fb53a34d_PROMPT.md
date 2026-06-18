## Assignment: Quadratic Reciprocity Beyond a Single Theorem — Five Formal Lenses, One Arithmetic Geometry

**Mode:** `prove` + `formalize`

You are not being asked to merely restate quadratic reciprocity. The catalog already contains a theorem named `quadratic_reciprocity_law`. That means the real scientific opportunity is higher: **formalize multiple genuinely different proof architectures**, isolate the conceptual invariants they share, and turn reciprocity from a single fact into a **verified comparative theory of proofs**. The breakthrough is not “QR is true”; it is that Lean can certify that **Gauss sums, lattice-point parity, and local/global reciprocity mechanisms are computationally interoperable witnesses of the same law**.

Your target is a new Lean development that proves, compares, and algorithmizes at least **three distinct proofs** of quadratic reciprocity, together with the supplementary laws for `(-1/p)` and `(2/p)`, and at least one theorem connecting reciprocity to a different domain.

This should become a field-opening blueprint for:
- **proof comparison in arithmetic**
- **computable reciprocity laws**
- **bridges from elementary number theory to spectral/algebraic structures**
- **machine-verified translation between combinatorial, analytic, and Galois-theoretic arguments**

---

## Core Theorem Targets

You should introduce a clean formal interface for “proof witnesses” of quadratic reciprocity. Do **not** just prove the same theorem three times anonymously. Define a structure encoding a proof method and show that each method computes the same Legendre-symbol sign.

### New definition requirement
Define at least one genuinely new concept, for example:

```lean
structure ReciprocityWitness where
  signFn : ℕ → ℕ → ℤ
  domain : Prop
  sound :
    ∀ {p q : ℕ}, Nat.Prime p → Nat.Prime q → p ≠ q → p ≠ 2 → q ≠ 2 →
      signFn p q = (-1) ^ (((p - 1) / 2) * ((q - 1) / 2))
```

or, more concretely, a proof-specific parity extractor:

```lean
structure QRParityModel where
  parity : ℕ → ℕ → ZMod 2
  valid_on :
    ∀ {p q : ℕ}, Nat.Prime p → Nat.Prime q → p ≠ q → p ≠ 2 → q ≠ 2 → Prop
  reciprocity_parity :
    ∀ {p q : ℕ}, Nat.Prime p → Nat.Prime q → p ≠ q → p ≠ 2 → q ≠ 2 →
      parity p q = (((p - 1) / 2) * ((q - 1) / 2) : ℕ)
```

A more realistic Lean choice may use `ℤ`, `ZMod 2`, or booleans depending on library convenience. The point is conceptual novelty: **a formal object representing a proof mechanism for reciprocity**.

---

## Precise Theorem Statements

You must prove at least 3 deep theorems. Here is the exact level of specificity expected.

### Theorem 1: Eisenstein parity formulation of quadratic reciprocity
Formalize the lattice-point parity proof in a way that does not collapse to the catalog theorem.

**Mathematical statement:**  
For distinct odd primes `p, q`,
\[
\sum_{i=1}^{(p-1)/2} \left\lfloor \frac{i q}{p} \right\rfloor
+
\sum_{j=1}^{(q-1)/2} \left\lfloor \frac{j p}{q} \right\rfloor
=
\frac{(p-1)(q-1)}{4}.
\]
Taking parity yields quadratic reciprocity.

**Lean target sketch:**
```lean
theorem eisenstein_floor_identity
    (p q : ℕ)
    (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpodd : p % 2 = 1) (hqodd : q % 2 = 1)
    (hpq : p ≠ q) :
    (∑ i in Finset.Icc 1 (p / 2), ((i * q) / p) +
     ∑ j in Finset.Icc 1 (q / 2), ((j * p) / q))
      = ((p - 1) * (q - 1)) / 4
```

A parity corollary should then imply:
```lean
theorem quadratic_reciprocity_eisenstein
    (p q : ℕ)
    (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q) :
    legendreSym p q * legendreSym q p
      = (-1) ^ (((p - 1) / 2) * ((q - 1) / 2))
```

Here `legendreSym` may be your own formal wrapper if Mathlib’s exact API is inconvenient. If necessary, define:
```lean
def legendreSym (a p : ℕ) : ℤ := ...
```
with values in `{-1,0,1}`.

### Theorem 2: Gauss-lemma / sign-of-permutation or Gauss-sum witness
If full complex Gauss sums are too library-heavy, formalize a modernized arithmetic Gauss-lemma proof that still captures Gauss’s philosophy: a sign extracted from modular multiplication.

**Mathematical statement:**  
For odd prime `p` and `a` coprime to `p`, the Legendre symbol `(a/p)` equals
\[
(-1)^{\, |\{1 \le k \le (p-1)/2 : ak \bmod p > p/2\}| }.
\]

**Lean target sketch:**
```lean
def upperHalfResidueCount (a p : ℕ) : ℕ :=
  ((Finset.Icc 1 (p / 2)).filter
    (fun k => p / 2 < (a * k) % p)).card

theorem gauss_lemma_legendre
    (a p : ℕ)
    (hp : Nat.Prime p)
    (hp2 : p ≠ 2)
    (hcop : Nat.Coprime a p) :
    legendreSym a p = (-1) ^ upperHalfResidueCount a p
```

Then derive reciprocity by specializing `a = q` and comparing counts:
```lean
theorem quadratic_reciprocity_gauss_lemma
    (p q : ℕ)
    (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q) :
    legendreSym q p * legendreSym p q
      = (-1) ^ (((p - 1) / 2) * ((q - 1) / 2))
```

This is deep, nontrivial, and highly formalizable.

### Theorem 3: Supplementary law for `(-1/p)`
**Mathematical statement:** for odd prime `p`,
\[
\left(\frac{-1}{p}\right)=(-1)^{(p-1)/2}.
\]

**Lean target sketch:**
```lean
theorem legendre_minus_one
    (p : ℕ)
    (hp : Nat.Prime p)
    (hp2 : p ≠ 2) :
    legendreSym (p - 1) p = (-1) ^ ((p - 1) / 2)
```

### Theorem 4: Supplementary law for `(2/p)`
**Mathematical statement:** for odd prime `p`,
\[
\left(\frac{2}{p}\right)=(-1)^{(p^2-1)/8}.
\]

**Lean target sketch:**
```lean
theorem legendre_two
    (p : ℕ)
    (hp : Nat.Prime p)
    (hp2 : p ≠ 2) :
    legendreSym 2 p = (-1) ^ ((p * p - 1) / 8)
```

### Theorem 5: Cross-proof equivalence theorem
This is the real conceptual prize.

**Mathematical statement:** the parity extracted from Eisenstein’s lattice proof equals the parity extracted from Gauss’s lemma, for all distinct odd primes.

**Lean target sketch:**
```lean
theorem eisenstein_gauss_parity_equiv
    (p q : ℕ)
    (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q) :
    eisensteinParity p q = gaussParity p q
```

This theorem transforms “multiple proofs” into a **formal equivalence of proof invariants**.

### Theorem 6: Ambitious modern reciprocity shadow via finite-field character sums
A full class field theory formalization is likely too large unless Mathlib already has the exact infrastructure. So the scientifically intelligent move is to formalize a **class-field-theoretic shadow**: identify the Legendre symbol with the unique nontrivial quadratic character of `(ZMod p)ˣ`, then prove reciprocity through character behavior and Frobenius-style parity. This is still modern and structurally important.

A realistic theorem:

```lean
theorem quadratic_character_unique
    (p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2) :
    ∃! χ : Units (ZMod p) →* ℤˣ, isQuadraticCharacter χ
```

or a weaker but workable formulation:
```lean
theorem legendre_equals_quadratic_character
    (p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2)
    (a : Units (ZMod p)) :
    legendreUnit a = quadraticCharacter a
```

Then use this to connect reciprocity with automorphism/Frobenius language.

If full class field theory is out of reach, explicitly say in `RESEARCH_PAPER.md` that the formalization captures the **abelian character-theoretic skeleton** of the local-global proof.

---

## Proof Strategy Architecture

You must provide multiple proof routes and choose among them intelligently.

### Strategy A: Gauss lemma as the main formal backbone
1. Define `legendreSym` and `upperHalfResidueCount`.
2. Prove that multiplication by `a` permutes nonzero residues mod `p`, then partition images into lower/upper halves.
3. Convert the sign count into the Legendre symbol and derive reciprocity.

**Why promising:** This is the best balance of depth and formal tractability. It uses finite sets, modular arithmetic, cardinality arguments, and parity—excellent Lean terrain.

### Strategy B: Eisenstein lattice-point proof
1. Formalize the triangle/rectangle decomposition:
   \[
   \#\{(x,y): 1\le x\le (p-1)/2,\ 1\le y\le (q-1)/2,\ qx > py\}
   \]
   and its complement.
2. Prove the floor-sum identity by exact counting.
3. Reduce mod 2 and identify the parity with the Legendre symbol via Gauss lemma or a direct sign argument.

**Why promising:** Geometrically transparent, gives a different proof witness, and is ideal for the required cross-domain connection because it turns number theory into discrete geometry.

### Strategy C: Character-theoretic / proto-class-field proof
1. Realize the Legendre symbol as a quadratic multiplicative character on `Units (ZMod p)`.
2. Show reciprocity emerges from comparing the action of prime classes on quadratic extensions or from properties of finite-field characters and Gauss sums.
3. Formalize the minimum viable “modern proof skeleton” rather than all of global class field theory.

**Why promising:** This is the conceptual bridge to algebraic number theory and Galois representations. It is the most revolutionary, but likely the hardest. Use it as the ambitious third axis; if full completion is too large, still formalize a robust finite-field character version.

**Recommendation:** Make Strategy A + Strategy B fully complete, and push Strategy C as far as the library allows. The key breakthrough theorem should be the **equivalence of the parity models**.

---

## Build on Catalog Theorems

Use the existing catalog theorem
- `FINAL/Algebra/TimelineGravityCycles.lean`  
  `quadratic_reciprocity_law`

not as the endpoint, but as a **certified target for proof comparison**. Concretely:
- prove your Gauss-lemma and Eisenstein versions independently;
- then show each implies or agrees with the catalog reciprocity law;
- derive a theorem like:

```lean
theorem quadratic_reciprocity_methods_agree
    (p q : ℕ)
    (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q) :
    quadraticReciprocityViaGauss p q =
    quadraticReciprocityViaEisenstein p q
```

If `cyclotomic_lattice_bound` from `Algebra/EMLClosureUnification/Core.lean` has usable counting or cyclotomic estimates, exploit it in the modern/character proof as a technical bridge: lattice geometry and cyclotomic arithmetic are exactly the right interface for reciprocity. Even if the theorem is not directly about QR, cite and reuse its counting style or boundedness infrastructure if possible.

---

## Cross-Domain Connection Requirement

You must include at least one theorem connecting quadratic reciprocity to a different domain.

### Best option: number theory + discrete geometry
Formalize that Eisenstein’s proof is a theorem about **parity of lattice points under a rational slope line**. For example:

```lean
def reciprocityLatticeRegion (p q : ℕ) : Finset (ℕ × ℕ) := ...

theorem reciprocity_lattice_region_parity
    (p q : ℕ)
    (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q) :
    (reciprocityLatticeRegion p q).card % 2
      = ((((p - 1) / 2) * ((q - 1) / 2)) % 2)
```

This is a bona fide bridge: **arithmetic law = geometric parity invariant**.

### Stronger option: number theory + spectral/character theory
Show that the Legendre symbol defines a quadratic character whose orthogonality controls a parity or sum identity. This opens pathways to:
- Fourier analysis on finite fields
- pseudorandomness
- expander constructions
- coding theory

### Application keywords
Include these explicitly in your writeup and code comments:
**quadratic character, finite field Fourier analysis, lattice-point parity, Gauss sums, reciprocity law, computational number theory, proof interoperability, arithmetic geometry, cryptographic residue testing, symbolic verification**

---

## Conjecture With Testable Prediction

You must state at least one falsifiable conjecture with a clear computational test.

Here is a strong candidate that naturally emerges from your proof-comparison framework:

### Conjecture: Proof-invariant parity compression
For distinct odd primes `p, q`, the minimal proof witness extracted from any “elementary reciprocity proof” factors through the same `ZMod 2` parity invariant.

Informally: every elementary proof of quadratic reciprocity computes the same hidden bit.

Possible Lean-side placeholder:
```lean
conjecture elementary_qr_proofs_factor_through_parity :
  ∀ M : QRParityModel, ElementaryModel M →
    ∃ f : ZMod 2 → ZMod 2, ∀ p q, M.parity p q = f (eisensteinParity p q)
```

### Computational test
In `demo.py`, for many prime pairs `(p,q)`:
- compute parity via floor sums,
- compute parity via upper-half residue counts,
- compute parity via direct Legendre symbol products,
- verify equality across all methods.

A single counterexample disproves the conjectural universality claim.

A second concrete conjecture:
### Conjecture: Geometric stability of reciprocity parity
The lattice-point parity underlying reciprocity is invariant under a family of shear transforms preserving boundary coprimality data.

This is bold and falsifiable: implement sheared lattice regions and search for parity failures.

---

## Formalization Guidance and Likely Lean Components

You will likely need:
- `Nat.Prime`, `Nat.Coprime`
- `ZMod p`
- `Units (ZMod p)`
- `Finset.Icc`, `Finset.filter`, `Finset.card`
- modular arithmetic lemmas
- floor/division lemmas on naturals or integers
- parity lemmas mod `2`
- `calc` blocks, `rcases`, `by_contra`, `field_simp` where applicable
- explicit coercion management between `ℕ`, `ℤ`, and `ZMod p`

If natural-number floors become painful, move the counting identity to integers:
```lean
Int.floor ( (i : ℚ) * q / p )
```
but only if that genuinely simplifies proof transport.

---

## Nontriviality Requirements

You must satisfy all depth constraints explicitly:
- no fake progress by `native_decide`, `decide`, `norm_num`, or bare `rfl`;
- at least 3 theorems with substantial proofs using induction, `rcases`, `by_contra`, `field_simp`, or multi-step `calc`;
- at least one genuinely new definition (`QRParityModel`, `legendreSym`, `reciprocityLatticeRegion`, etc.);
- at least one cross-domain theorem;
- at least one falsifiable conjecture with executable test.

In particular, the following theorems are expected to require real proof structure:
1. `gauss_lemma_legendre`
2. `eisenstein_floor_identity`
3. `eisenstein_gauss_parity_equiv`
4. one supplementary law (`legendre_minus_one` or `legendre_two`) by a nontrivial derivation

---

## Deliverables

You must produce **all** of the following:

1. **Lean code** formalizing at least three distinct proof pathways or proof witnesses for quadratic reciprocity, with minimized `sorry`.
2. **FUTURE_DIRECTIONS.md** containing **3–5 falsifiable scientific hypotheses**, each with:
   - precise statement,
   - what computation/test could refute it,
   - what a positive result would suggest.
3. **RESEARCH_PAPER.md** that is fully standalone:
   - problem statement,
   - theorem statements,
   - explanation of each proof architecture,
   - what was formalized versus what remains open,
   - why proof comparison matters scientifically.
4. **ARTICLE.md** in Scientific American style:
   - explain reciprocity as a hidden symmetry of primes,
   - explain why multiple proofs matter,
   - explain how formal verification changes number theory.
5. **A verified algorithm or computational method**:
   - algorithm to compute Legendre-symbol reciprocity via at least two proof witnesses,
   - formally connected to the theorem statements.
6. **demo.py**:
   - interactive exploration of prime pairs,
   - displays the Gauss count, Eisenstein floor sums, direct residue computation,
   - verifies supplementary laws,
   - optionally visualizes the lattice region for Eisenstein’s proof.

---

## Scientific Significance

If you succeed, the result is not “quadratic reciprocity in Lean” but something more original:

- a **verified comparative anatomy of proofs**;
- a template for formalizing higher reciprocity laws by identifying proof invariants;
- a bridge from elementary arithmetic to **character theory, finite-field harmonic analysis, and discrete geometry**;
- a computational platform for experimenting with reciprocity phenomena and discovering new parity invariants.

This opens follow-on work on:
- cubic and quartic reciprocity,
- Artin-symbol style formalizations,
- Gauss sums and finite-field Fourier transforms,
- reciprocity in tropical or combinatorial shadows,
- proof-mining: extracting algorithms from distinct classical proofs and comparing complexity.

Do not merely certify a theorem already known. **Expose the hidden architecture that makes the theorem inevitable.**

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
