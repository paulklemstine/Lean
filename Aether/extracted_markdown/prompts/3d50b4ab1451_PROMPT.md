## Assignment: Direction 4: Primewise Decomposition and Improved Constants (Grand Challenge)

**Mode**: `prove` with a built-in `counterexample` fallback if the strongest p-adic improvement statement fails.

Prove genuinely new, non-trivial theorems on **primewise torsion persistence stability**. Build directly on the catalog results around `TorsionBirthSet`, `prime_selectivity_filtration`, and `torsion_birthSet_deltaClose`, but do **not** merely repackage the existing global δ-stability statement. The goal is to expose a hidden arithmetic stratification of torsion persistence: different primes should behave as independently stable information channels.

This direction is only successful if it produces a theorem that would make a persistence theorist and a number theorist both pause: **torsion persistence is not a single unstable shadow of homology, but a vector-valued arithmetic signal with primewise regularity laws.**

---

## Core Vision

Classical persistence stability treats torsion as a monolithic phenomenon. That is too coarse. A finite torsion group is canonically assembled from its p-primary pieces, and filtrations often create torsion at different primes by different mechanisms and at different scales. If the current catalog gives only

```lean
NatSetDeltaClose (TorsionBirthSet F) (TorsionBirthSet F') δ
```

then the revolutionary step is to show that **prime-local torsion births satisfy a finer, possibly strictly smaller, stability modulus**. This would amount to an arithmetic refinement of persistence stability analogous to frequency-channel separation in signal processing or eigenspace decomposition in spectral theory.

The speculative slogan is:

> **Interleaving noise is not equally visible to every prime.**

If true, this opens a new field: **arithmetic topological data analysis**, where one studies filtrations through their primewise torsion spectra, local stability exponents, and reconstruction laws.

---

## Precise Formal Target

You should introduce a new prime-local birth invariant and prove at least three substantial theorems about it.

### New definition to introduce

Define a p-primary torsion birth set, ideally as a genuinely new concept and not just notation:

```lean
def PTorsionBirthSet
  (p : ℕ) [Fact p.Prime]
  (F : Filtration C) : Set ℕ := ...
```

or, if the catalog works with finite sets / multisets / nat sets, adapt accordingly:

```lean
def PTorsionBirthSet
  (p : ℕ) [Fact p.Prime]
  (F : Filtration C) : Finset ℕ := ...
```

The intended meaning: `n ∈ PTorsionBirthSet p F` iff at filtration level `n` there is a **new p-primary torsion class** born in the relevant homology group. If the catalog encodes torsion births via annihilation by nonunits or finite order classes, define the p-primary version using existence of a class annihilated by a power of `p`, together with minimality of the birth index.

You should also define a quantitative primewise modulus, if needed:

```lean
def padicShiftPenalty (p δ : ℕ) : ℕ := ...
```

Do **not** force a fake p-adic valuation on arbitrary δ if the formal infrastructure is not yet present. A robust alternative is to define the improvement in terms of divisibility data:

```lean
def primeShiftBound (p δ : ℕ) : ℕ := δ / p^ν
```

for a suitable `ν`, or even more conservatively define a bound `primeShiftBound p δ ≤ δ` extracted from the interleaving morphisms’ p-divisibility behavior. If the strongest valuation-based form is too ambitious, prove a weaker but rigorous theorem first and state the sharper one as a conjecture.

---

## Breakthrough Theorem Targets

You must aim for statements at this level of specificity.

### Theorem 1: Primewise decomposition of torsion births

A decomposition theorem connecting the global torsion birth set to primewise channels.

**Mathematical statement**: for any filtration whose torsion homology groups are finite at each level, every torsion birth arises from some prime, and the global torsion birth set is the union of primewise birth sets.

Possible Lean shape:

```lean
theorem torsionBirthSet_eq_iUnion_primewise
  (F : Filtration C) :
  TorsionBirthSet F = ⋃ p : {p : ℕ // Nat.Prime p.1}, PTorsionBirthSet p.1 F
```

or in a finitary form over primes dividing the torsion order at each level:

```lean
theorem mem_torsionBirthSet_iff_exists_prime
  (F : Filtration C) (n : ℕ) :
  n ∈ TorsionBirthSet F ↔
    ∃ p : ℕ, Nat.Prime p ∧ n ∈ PTorsionBirthSet p F
```

**Why this matters**: this is the arithmetic spectral decomposition theorem for torsion persistence. It says the global invariant is not primitive; it is assembled from prime-local observables.

---

### Theorem 2: Primewise stability with nontrivial improved constant

This is the main breakthrough theorem. State the strongest theorem you can actually support from the catalog.

#### Strong aspirational form
```lean
theorem pTorsionBirthSet_deltaClose_improved
  (p δ : ℕ) [Fact p.Prime]
  {F F' : Filtration C}
  (hInt : Interleaved F F' δ)
  (hp : PrimewiseControlled p hInt) :
  NatSetDeltaClose (PTorsionBirthSet p F) (PTorsionBirthSet p F')
    (primeShiftBound p δ)
```

with a theorem
```lean
theorem primeShiftBound_le
  (p δ : ℕ) [Fact p.Prime] :
  primeShiftBound p δ ≤ δ
```

and ideally an example showing strict inequality can occur.

#### If the valuation-based conjecture is too strong
prove a rigorously justified intermediate theorem:

```lean
theorem pTorsionBirthSet_deltaClose_same_or_better
  (p δ : ℕ) [Fact p.Prime]
  {F F' : Filtration C}
  (hInt : Interleaved F F' δ) :
  ∃ ε ≤ δ, NatSetDeltaClose (PTorsionBirthSet p F) (PTorsionBirthSet p F') ε
```

where `ε` is extracted functorially from p-primary annihilation data of the interleaving maps.

**Why this matters**: this would be the first theorem showing that torsion persistence carries **strictly finer stability information than ordinary persistence**.

---

### Theorem 3: Strict improvement / separation example

You need one theorem showing the primewise theory is not vacuous.

Possible shape:

```lean
theorem exists_strict_primewise_improvement
  :
  ∃ (p δ : ℕ) (_ : Nat.Prime p) (F F' : Filtration C),
    Interleaved F F' δ ∧
    ¬ NatSetDeltaClose (PTorsionBirthSet p F) (PTorsionBirthSet p F') (δ - 1) → False
```

Better yet, prove existence of `ε < δ` with primewise closeness while global sharpness still requires `δ`:

```lean
theorem exists_primewise_better_than_global
  :
  ∃ (p δ ε : ℕ) (_ : Nat.Prime p) (hε : ε < δ) (F F' : Filtration C),
    Interleaved F F' δ ∧
    NatSetDeltaClose (PTorsionBirthSet p F) (PTorsionBirthSet p F') ε ∧
    ¬ NatSetDeltaClose (TorsionBirthSet F) (TorsionBirthSet F') ε
```

If a full existential construction inside Lean is too heavy, then formalize a **parametric family** of filtrations with explicit arithmetic behavior and prove the separation theorem for that family.

**Why this matters**: without a strict-separation theorem, the primewise theory could be a relabeling of the global one. This theorem would prove the arithmetic channel decomposition has real predictive content.

---

## Lean 4 Type Signature Suggestions

These are not mandatory exact names, but your theorem statements should be this precise.

```lean
def PTorsionClass (p : ℕ) [Fact p.Prime] (A : Type*) [AddCommGroup A] : Prop := ...
def PTorsionBirthSet (p : ℕ) [Fact p.Prime] (F : Filtration C) : Set ℕ := ...

theorem mem_pTorsionBirthSet_of_mem_torsionBirthSet
  (p n : ℕ) [Fact p.Prime] (F : Filtration C) :
  n ∈ PTorsionBirthSet p F → n ∈ TorsionBirthSet F

theorem mem_torsionBirthSet_iff_exists_prime
  (F : Filtration C) (n : ℕ) :
  n ∈ TorsionBirthSet F ↔ ∃ p : ℕ, Nat.Prime p ∧ n ∈ PTorsionBirthSet p F

def primeShiftBound (p δ : ℕ) : ℕ := ...

theorem primeShiftBound_le_delta
  (p δ : ℕ) [Fact p.Prime] :
  primeShiftBound p δ ≤ δ

theorem pTorsionBirthSet_deltaClose
  (p δ : ℕ) [Fact p.Prime]
  {F F' : Filtration C}
  (h : Interleaved F F' δ)
  (hp : PrimewiseControlled p h) :
  NatSetDeltaClose (PTorsionBirthSet p F) (PTorsionBirthSet p F')
    (primeShiftBound p δ)

theorem exists_primewise_better_than_global
  :
  ∃ p δ ε, Nat.Prime p ∧ ε < δ ∧
    ∃ F F' : Filtration C,
      Interleaved F F' δ ∧
      NatSetDeltaClose (PTorsionBirthSet p F) (PTorsionBirthSet p F') ε ∧
      ¬ NatSetDeltaClose (TorsionBirthSet F) (TorsionBirthSet F') ε
```

If the actual catalog uses different ambient types, replace `Filtration C`, `Interleaved`, and `Set ℕ` accordingly, but keep this level of precision.

---

## Proof Architecture: 3 Viable Strategies

You must pursue at least two of these in the file, and explain in comments or notes why one is the mainline route.

### Strategy A: Chinese Remainder decomposition of finite torsion
**Best when the catalog already expresses torsion via finite abelian groups or annihilator data.**

1. Show that any torsion class has order divisible by some prime `p`, hence induces a p-primary torsion witness.
2. Use a decomposition theorem for finite torsion groups into p-primary summands.
3. Prove that “birth at index n” is preserved under passage to p-primary components.
4. Push the existing `torsion_birthSet_deltaClose` theorem through the p-primary projection maps.
5. Extract a smaller effective shift from p-divisibility of the interleaving morphisms.

Why promising: this directly leverages the algebraic structure of torsion and turns prime decomposition into a functor on persistence modules.

Deep tactics likely needed: `rcases` on finite-order witnesses, induction on exponents, multi-step `calc`, contradiction arguments to prove minimality of births.

---

### Strategy B: Localization / primary functor method
**Best when the catalog already has `prime_selectivity_filtration` or localization-flavored machinery.**

1. Define a prime-selective detector functor `F ↦ F_(p)` or a p-torsion observable.
2. Show functoriality: interleavings descend to interleavings after prime selection.
3. Identify `PTorsionBirthSet p F` with the ordinary torsion birth set of the prime-selected filtration.
4. Apply the catalog stability theorem to the transformed filtration.
5. Prove the transformed interleaving has a smaller effective delay than the original one.

Why promising: this is conceptually clean and modular. It converts the grand challenge into “stability commutes with arithmetic filtering.”

Cross-check: this is the natural extension of `prime_selectivity_filtration` from detection to stability.

---

### Strategy C: Counterexample-guided refinement
**Use this if the naive valuation formula `δ / ord_p(δ)` is false as stated.**

1. Construct explicit filtrations with mixed torsion at two primes.
2. Show the strongest naive bound fails for one prime.
3. Identify the correct hypothesis: perhaps improved stability requires p-divisible transition maps, bounded p-exponent, or separated prime birth layers.
4. Prove the corrected theorem under the minimal true hypothesis.
5. Formalize the failed naive statement as a falsifiable conjecture with an explicit search protocol.

Why promising: even a counterexample here is scientifically valuable. It turns a vague dream into a sharply true theorem with the right arithmetic assumptions.

This route is completely acceptable if executed decisively. A counterexample plus corrected theorem can be more paradigm-shifting than a forced false proof.

---

## Mandatory Cross-Domain Connection

Include at least one theorem or construction that bridges to another field. Choose one of the following and make it formal.

### Option 1: Signal processing interpretation
Interpret `PTorsionBirthSet p F` as a **prime channel response**. Prove a theorem that the global torsion detector is the superposition of independent prime channels.

Possible statement:
```lean
theorem torsion_detector_factorizes_over_primes
  ...
```

Scientific significance: this reframes torsion persistence as multichannel arithmetic filtering.

### Option 2: p-adic geometry / arithmetic dynamics
Relate the improved stability modulus to p-adic valuation or divisibility filtration on morphisms. Show that greater p-divisibility of interleaving maps implies smaller p-primary birth drift.

Possible statement:
```lean
theorem higher_p_divisibility_smaller_shift
  (k : ℕ) :
  p^k ∣ interleavingDefect h → primeShiftBound p δ ≤ δ / p^k
```

Scientific significance: this imports valuation theory into topological stability.

### Option 3: Physics / spectral decomposition analogy
Define an arithmetic “channel energy” counting p-primary births and prove additivity or subadditivity across primes.

Possible statement:
```lean
def primeBirthEnergy (p : ℕ) [Fact p.Prime] (F : Filtration C) : ℕ := ...

theorem total_torsion_energy_decomposes
  (F : Filtration C) :
  totalTorsionEnergy F = ∑ p in relevantPrimes F, primeBirthEnergy p F
```

Scientific significance: this connects persistence to conserved quantities and mode decomposition.

---

## Concrete Building Blocks from the Catalog

You should explicitly build on:

- `TorsionBirthSet`
  - Use it as the global invariant to be refined.
  - Prove inclusion/equality statements comparing it to `PTorsionBirthSet`.

- `prime_selectivity_filtration`
  - This should be upgraded from a detector/localization mechanism into a **stability transport theorem**.
  - Ideal pattern: prime selection commutes with interleaving up to a sharpened bound.

- `torsion_birthSet_deltaClose`
  - This is the baseline theorem to surpass.
  - Your work should either:
    1. derive it as a corollary by union over primes, or
    2. prove a strictly stronger primewise theorem that recovers it by taking the supremum over primes.

A particularly strong architecture would be:

1. Define `PTorsionBirthSet`.
2. Prove `PTorsionBirthSet p F = TorsionBirthSet (prime_selectivity_filtration p F)`.
3. Transfer `torsion_birthSet_deltaClose` to the prime-selected filtration.
4. Improve the constant using prime-selective arithmetic control.
5. Reconstruct the global theorem from the primewise family.

That would be a complete arithmetic theory, not an isolated lemma.

---

## What Counts as Success

At minimum, your Lean development must contain:

1. **One novel definition**:
   - `PTorsionBirthSet`, `PrimewiseControlled`, `primeShiftBound`, `primeBirthEnergy`, or equivalent.

2. **At least 3 substantial theorems**, with proofs using nontrivial tactics such as:
   - induction,
   - `rcases`,
   - `by_contra`,
   - `field_simp` if rational/divisibility normalization appears,
   - multi-step `calc`,
   - explicit use of divisibility and prime decomposition lemmas.

3. **One cross-domain theorem** from the list above.

4. **One falsifiable conjecture** with a computational test.

5. **One verified algorithm or computational method** that computes or approximates primewise torsion birth sets and compares global vs primewise stability constants.

6. **One demo** showing the effect on explicit filtrations with mixed prime torsion.

---

## Falsifiable Conjectures to Include in FUTURE_DIRECTIONS.md

You must include 3–5 hypotheses; at least one should be close to the following.

### Hypothesis A: Strict primewise improvement is generic in mixed torsion families
For random finite filtrations whose torsion orders have at least two distinct prime factors, there exists a prime `p` such that the optimal stability constant for `PTorsionBirthSet p` is strictly smaller than the optimal global torsion stability constant.

**Test**: generate filtrations with torsion orders divisible by `2,3,5`; compute optimal `ε_p` and global `ε`; count frequency of `ε_p < ε`.

### Hypothesis B: Primewise constants correlate with p-adic divisibility of transition maps
The effective primewise shift bound decreases monotonically with the p-adic valuation of the interleaving morphisms.

**Test**: build explicit families where transition maps are multiplied by `p^k`; measure whether computed birth drift decreases as `k` increases.

### Hypothesis C: Global torsion stability is the max envelope of primewise stability
For a broad class of finite-type filtrations,
```text
optimal_global_shift = sup_p optimal_prime_shift(p).
```

**Test**: compute both sides on mixed-prime examples and search for counterexamples.

### Hypothesis D: Primewise birth spectra distinguish filtrations invisible to global torsion births
There exist filtrations `F, G` with `TorsionBirthSet F = TorsionBirthSet G` but `PTorsionBirthSet p F ≠ PTorsionBirthSet p G` for some prime `p`.

**Test**: exhaustive search over small filtered complexes / toy persistence modules.

### Hypothesis E: Primewise entropy obeys a data-processing inequality
If a filtration is passed through a prime-selective functorial simplification, the entropy of the p-birth distribution cannot increase.

**Test**: define empirical entropy of birth times per prime and compare before/after simplification.

---

## Computational / Algorithmic Deliverable

You must produce a verified algorithm, not just theorem statements.

Suggested target:

```lean
def computePTorsionBirthSet
  (p : ℕ) [Fact p.Prime]
  (F : ExplicitFiniteFiltration) : Finset ℕ := ...
```

and a correctness theorem:

```lean
theorem computePTorsionBirthSet_correct
  (p : ℕ) [Fact p.Prime]
  (F : ExplicitFiniteFiltration) :
  computePTorsionBirthSet p F = PTorsionBirthSet p F
```

If exact equality is too difficult, prove soundness/completeness as separate theorems.

Then create `demo.py` that:

- computes p-primary torsion births for `p = 2,3,5,7`,
- compares global vs primewise stability radii,
- visualizes mixed torsion filtrations,
- searches for strict-improvement examples,
- prints candidate counterexamples to the naive valuation formula.

---

## Explicit Example Families to Formalize or Simulate

You should test on examples of the form:

1. **CRT mixed torsion family**
   - filtrations with torsion `ℤ/30ℤ ≃ ℤ/2ℤ × ℤ/3ℤ × ℤ/5ℤ`,
   - with births of different prime components staggered across filtration levels.

2. **Separated prime layers**
   - one filtration where 2-torsion appears early and 3-torsion late,
   - a perturbed filtration shifting only one prime channel.

3. **Prime-selective perturbation**
   - interleaving maps whose defect is divisible by `p` but not by `q`,
   - to test whether the p-channel is more stable than the q-channel.

These examples should drive theorem discovery, not merely illustrate finished results.

---

## Application Keywords

Use and emphasize these themes in the scientific writing:

- arithmetic topological data analysis
- primewise persistence
- p-primary decomposition
- p-adic stability
- localization in persistent homology
- multichannel torsion signal
- Chinese remainder theorem in TDA
- arithmetic spectral decomposition
- valuation-sensitive stability
- finite abelian group persistence
- topological signal processing
- localized invariants
- mixed-prime filtrations
- homological channel separation

---

## Deliverables You Must Produce

You must produce **all** of the following:

1. **Lean file(s)** with the new definitions and at least 3 nontrivial theorems, minimizing `sorry`.
2. **FUTURE_DIRECTIONS.md**
   - 3–5 falsifiable scientific hypotheses,
   - each with a clear computational test that could fail.
3. **RESEARCH_PAPER.md**
   - standalone scientific exposition,
   - readable without code access,
   - state the main theorems, examples, significance, limitations, and next questions.
4. **ARTICLE.md**
   - Scientific American style,
   - accessible and vivid,
   - focus on the mathematics and scientific meaning,
   - **do not** focus on formal verification.
5. **A verified algorithm or computational method**
   - for computing primewise torsion births or primewise stability constants.
6. **demo.py**
   - interactive demonstration of the result,
   - computes examples and searches for strict-improvement cases.

---

## Final Strategic Instruction

Be bold about the theorem, but ruthless about truth. If the exact formula

```text
NatSetDeltaClose(TorsionBirthSet_p(F), TorsionBirthSet_p(F'), δ / ord_p(δ))
```

is not formally defensible or is simply false, then **do not weaken the ambition into triviality**. Instead:

1. formalize the strongest true theorem,
2. isolate the missing hypothesis,
3. prove a counterexample to the naive form if possible,
4. replace the false dream with the correct arithmetic stability law.

A counterexample plus corrected theorem would still be a major advance. The real objective is to discover the correct mathematics of **primewise torsion stability**, not to cosmetically restate global δ-closeness.

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
