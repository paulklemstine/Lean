Soli Deo Gloria

## Assignment: Direction 1: Persistence Zeta Function Multiplicativity

**Mode:** `prove`

Aristotle, this is not a routine extension. This is a chance to create the first rigorously formalized Euler-product theory for persistence. The conjecture points toward a new arithmetic interface between topological data analysis and analytic number theory: persistence modules behaving like arithmetic objects whose primewise structure controls global invariants. If you can isolate and prove a true multiplicativity theorem — even first under a sharp coprimality hypothesis with an explicit correction law beyond it — you will have opened a new field: **arithmetic persistence theory**.

The key is to avoid a toy statement about a hand-coded finite product. The theorem must identify a mathematically inevitable multiplicative mechanism, explain exactly where it breaks, and package this as both a theorem and an algorithm.

---

## Core Vision

Classical zeta functions encode global structure by primewise factorization. Persistence theory encodes shape evolution by barcodes. The breakthrough is to show that, for filtered finite abelian groups with primewise-independent torsion, the barcode-counting zeta invariant factorizes exactly as an Euler product under products of filtrations.

This would make persistence zeta the first serious candidate for an **analytic invariant of filtered algebraic-topological data**.

The right target is not merely
\[
Z(F_1\times F_2,s)=Z(F_1,s)Z(F_2,s)
\]
as a numerological identity, but a theorem of the form:

- the barcode contribution decomposes primewise under CRT,
- coprime support forces additivity of prime barcode lengths,
- that additivity upgrades to multiplicativity of Euler factors,
- overlap of support introduces a correction term that can be isolated and computed.

That correction term is itself mathematically valuable: it would be the analogue of a local interaction factor, suggesting a persistence-theoretic analogue of ramification.

---

## Precise Theorem Targets

You should formulate the theorem in Lean around a new formal structure capturing filtered finite abelian groups with prime support data and a primewise barcode-length statistic.

Because the catalog reference indicates `persistence_CRT_decomposition` and `bounded_torsion_implies_bounded_primeSupport`, the formal theorem should explicitly build on those results rather than bypass them.

### New definition required

Define a new structure, genuinely novel relative to the catalog, encoding the arithmetic data of a filtration:

```lean
structure ArithmeticFilteredAbelianGroup where
  α : Type
  instAddCommGroup : AddCommGroup α
  instFintype : Fintype α
  filtration : ℕ → AddSubgroup α
  mono_filtration : Monotone filtration
  finite_support_primes : Finset ℕ
  prime_support_spec : ∀ p : ℕ, Nat.Prime p →
    p ∈ finite_support_primes ↔ PrimeSupportsFiltration filtration p
```

You may want a cleaner version using `[AddCommGroup α] [Fintype α]` externally, but the essential novelty is a structure carrying both filtration and arithmetic support.

Then define the local barcode statistic and persistence zeta:

```lean
def localBarcodeLength
  (F : ArithmeticFilteredAbelianGroup) (p : ℕ) : ℕ := ...

def persistenceZetaFactor
  (F : ArithmeticFilteredAbelianGroup) (p : ℕ) (s : ℕ) : ℚ := 1 + localBarcodeLength F p / p^s

def persistenceZeta
  (F : ArithmeticFilteredAbelianGroup) (s : ℕ) : ℚ :=
  ∏ p in F.finite_support_primes, persistenceZetaFactor F p s
```

If rational powers are awkward, use `ℚ` and `p^s` in the denominator, or equivalently define
\[
1 + \frac{\ell_p(F)}{p^s}
\]
as a rational number. This is sufficient for a first theorem and fully formalizable.

### Theorem 1: Primewise additivity under coprime support product

This is the structural theorem. State it with explicit hypotheses.

```lean
theorem localBarcodeLength_prod_of_coprime_support
  (F₁ F₂ : ArithmeticFilteredAbelianGroup)
  (hcop :
    Disjoint F₁.finite_support_primes F₂.finite_support_primes) :
  ∀ p : ℕ,
    localBarcodeLength (prodArithmeticFiltration F₁ F₂) p
      = localBarcodeLength F₁ p + localBarcodeLength F₂ p
```

This theorem should not be a combinatorial tautology. It must be proved by invoking CRT decomposition of persistence data and showing that disjoint support kills mixed prime interactions.

### Theorem 2: Multiplicativity of persistence zeta under coprime support

This is the headline theorem.

```lean
theorem persistenceZeta_mul_of_coprime_support
  (F₁ F₂ : ArithmeticFilteredAbelianGroup)
  (s : ℕ)
  (hcop :
    Disjoint F₁.finite_support_primes F₂.finite_support_primes) :
  persistenceZeta (prodArithmeticFiltration F₁ F₂) s
    = persistenceZeta F₁ s * persistenceZeta F₂ s
```

This is the theorem that matters scientifically. It turns persistence zeta into an arithmetic multiplicative invariant.

### Theorem 3: Explicit correction-factor formula in the overlapping-support case

Do not stop at the easy coprime-support case. Introduce a correction factor and prove an exact factorization. This is where the work becomes field-opening.

```lean
def overlapCorrection
  (F₁ F₂ : ArithmeticFilteredAbelianGroup) (s : ℕ) : ℚ := ...

theorem persistenceZeta_mul_with_correction
  (F₁ F₂ : ArithmeticFilteredAbelianGroup)
  (s : ℕ) :
  persistenceZeta (prodArithmeticFiltration F₁ F₂) s
    = persistenceZeta F₁ s * persistenceZeta F₂ s * overlapCorrection F₁ F₂ s
```

The definition of `overlapCorrection` should be explicit as a finite product over the intersection of prime supports:
```lean
def overlapCorrection ... :=
  ∏ p in F₁.finite_support_primes ∩ F₂.finite_support_primes,
    ((1 + localBarcodeLength (prodArithmeticFiltration F₁ F₂) p / p^s) /
     ((1 + localBarcodeLength F₁ p / p^s) *
      (1 + localBarcodeLength F₂ p / p^s)))
```

Then the theorem is a finite-product rearrangement plus support decomposition. This gives you a mathematically meaningful exact formula even when naive multiplicativity fails.

### Theorem 4: Vanishing of correction factor under primewise independence

This theorem identifies the exact mechanism behind multiplicativity.

```lean
theorem overlapCorrection_eq_one_of_primewise_independence
  (F₁ F₂ : ArithmeticFilteredAbelianGroup)
  (s : ℕ)
  (hindep :
    ∀ p ∈ F₁.finite_support_primes ∩ F₂.finite_support_primes,
      localBarcodeLength (prodArithmeticFiltration F₁ F₂) p
        = localBarcodeLength F₁ p + localBarcodeLength F₂ p) :
  overlapCorrection F₁ F₂ s = 1
```

Combined with Theorem 3, this yields a conceptual multiplicativity criterion.

---

## Lean 4 Formalization Targets

You should aim for a file in the style of:

`Pythagorean/PersistenceZetaMultiplicativity.lean`

and explicitly import or build on:

- `Pythagorean/AdelicPersistentHomology.lean`
- the theorem `persistence_CRT_decomposition`
- the theorem `bounded_torsion_implies_bounded_primeSupport`
- any existing finite-support / CRT lemmas in the catalog

If exact names differ, preserve the mathematical architecture.

### Suggested Lean theorem signatures

Use these as targets, adapting to actual catalog names:

```lean
theorem prime_support_prod_subset_union
  (F₁ F₂ : ArithmeticFilteredAbelianGroup) :
  (prodArithmeticFiltration F₁ F₂).finite_support_primes ⊆
    F₁.finite_support_primes ∪ F₂.finite_support_primes := ...

theorem localBarcodeLength_eq_zero_of_prime_notin_support
  (F : ArithmeticFilteredAbelianGroup) {p : ℕ}
  (hp : p ∉ F.finite_support_primes) :
  localBarcodeLength F p = 0 := ...

theorem persistenceZetaFactor_eq_one_of_notin_support
  (F : ArithmeticFilteredAbelianGroup) (s : ℕ) {p : ℕ}
  (hp : p ∉ F.finite_support_primes) :
  persistenceZetaFactor F p s = 1 := ...

theorem localBarcodeLength_prod_of_coprime_support
  (F₁ F₂ : ArithmeticFilteredAbelianGroup)
  (hcop : Disjoint F₁.finite_support_primes F₂.finite_support_primes) :
  ∀ p : ℕ,
    localBarcodeLength (prodArithmeticFiltration F₁ F₂) p
      = localBarcodeLength F₁ p + localBarcodeLength F₂ p := ...

theorem persistenceZeta_mul_of_coprime_support
  (F₁ F₂ : ArithmeticFilteredAbelianGroup)
  (s : ℕ)
  (hcop : Disjoint F₁.finite_support_primes F₂.finite_support_primes) :
  persistenceZeta (prodArithmeticFiltration F₁ F₂) s
    = persistenceZeta F₁ s * persistenceZeta F₂ s := ...

theorem persistenceZeta_mul_with_correction
  (F₁ F₂ : ArithmeticFilteredAbelianGroup)
  (s : ℕ) :
  persistenceZeta (prodArithmeticFiltration F₁ F₂) s
    = persistenceZeta F₁ s * persistenceZeta F₂ s * overlapCorrection F₁ F₂ s := ...
```

At least three of these should require real proof architecture: induction on finite supports, `rcases` on prime membership cases, `by_contra` to force support contradictions, `field_simp` for rational correction factors, and multi-step `calc` rewrites of finite products.

---

## Proof Strategy Architecture

You must pursue at least 2–3 proof paths and decide which is strongest.

### Strategy A: CRT-first structural proof
**Most promising.**

1. Use `bounded_torsion_implies_bounded_primeSupport` to guarantee a finite Euler product.
2. Apply `persistence_CRT_decomposition` to decompose the product filtration into primewise components.
3. Prove that if prime supports are disjoint, then for each prime `p`, one factor contributes trivially, so
   \[
   \ell_p(F_1 \times F_2)=\ell_p(F_1)+\ell_p(F_2).
   \]
4. Convert pointwise factorization into product factorization by partitioning the finite support into disjoint union pieces.

Why this is best: it reveals the theorem as a manifestation of arithmetic locality, not a barcode-counting coincidence.

### Strategy B: Finite Euler-product combinatorics
1. Define support of the product filtration and prove it is contained in the union of supports.
2. Split the finite product over union/intersection of supports.
3. On primes outside support, show local factor equals 1.
4. Reduce multiplicativity to pointwise local-factor identities.

Why useful: this gives a robust exact correction-factor theorem and is likely easier to complete in Lean once the local lemmas exist.

### Strategy C: Contrapositive / obstruction analysis
1. Assume multiplicativity fails.
2. Use `by_contra` to extract a prime where local factorization fails.
3. Show such a prime must lie in the overlap of supports.
4. Conclude failure is entirely controlled by shared-prime interactions, motivating the correction factor.

Why valuable: even if full local additivity is hard, this yields a sharp theorem on the support of obstructions, already scientifically meaningful.

Recommended plan: prove Theorem 3 by Strategy B no matter what; then prove Theorem 2 via Strategy A; use Strategy C to package the failure mechanism as a theorem if full generality stalls.

---

## Cross-Domain Mathematical Connections

This project must explicitly connect persistence theory to another mathematical domain.

### 1. Analytic number theory
The Euler product viewpoint is the central bridge:
- `persistenceZeta` is a finite analogue of a Dirichlet-Euler product.
- coprime-support multiplicativity mirrors multiplicativity of arithmetic functions.
- overlap corrections resemble local ramification factors or bad Euler factors.

**Application keywords:** Euler products, multiplicative functions, local-global principle, bad primes, Dirichlet series.

### 2. Topological data analysis
The barcode length statistic is the persistence-theoretic content:
- local barcode lengths act like primewise Betti masses,
- product filtrations correspond to combining independent data sources,
- multiplicativity says arithmetic independence implies analytic decoupling of topological summaries.

**Application keywords:** barcodes, persistent homology, filtered objects, topological summaries, multi-scale invariants.

### 3. Statistical physics / partition functions
This is the unexpected bridge that makes the work paradigm-shifting:
- `persistenceZeta` behaves like a partition function built from local modes,
- coprime support corresponds to non-interacting species,
- overlap correction is an interaction term.

This suggests a future “thermodynamics of persistence,” where barcode statistics define energy landscapes and phase transitions in filtrations.

**Application keywords:** partition function, non-interacting modes, interaction correction, statistical mechanics, phase transition analogies.

### 4. Representation-theoretic / adelic perspective
If the catalog’s adelic reconstruction theorem is available, you should frame the result adelically:
- filtered finite abelian groups decompose into local prime data,
- persistence zeta is an adelic generating function,
- multiplicativity is an adelic factorization theorem.

**Application keywords:** adeles, CRT decomposition, local components, arithmetic geometry, adelic invariants.

---

## Nontriviality Requirements

You are explicitly forbidden from turning this into a vacuous finite computation.

Your file must contain at least 3 genuinely nontrivial theorems whose proofs use some of:
- induction on `Finset`
- `rcases` on support-membership dichotomies
- `by_contra` to derive support contradictions
- `field_simp` in the correction-factor theorem
- substantial `calc` chains for finite-product decomposition

Good candidates:
1. `prime_support_prod_subset_union`
2. `localBarcodeLength_prod_of_coprime_support`
3. `persistenceZeta_mul_of_coprime_support`
4. `persistenceZeta_mul_with_correction`
5. `overlapCorrection_eq_one_of_primewise_independence`

---

## Conjecture With Testable Prediction

You must include at least one falsifiable conjecture, not merely prose.

### Conjecture A: Exact obstruction localization
```lean
conjecture multiplicativity_failure_supported_on_overlap
  (F₁ F₂ : ArithmeticFilteredAbelianGroup) :
  ∀ s : ℕ,
    persistenceZeta (prodArithmeticFiltration F₁ F₂) s
      ≠ persistenceZeta F₁ s * persistenceZeta F₂ s →
    ∃ p ∈ F₁.finite_support_primes ∩ F₂.finite_support_primes,
      localBarcodeLength (prodArithmeticFiltration F₁ F₂) p
        ≠ localBarcodeLength F₁ p + localBarcodeLength F₂ p
```

**Computational test:** enumerate filtered finite abelian groups with at most 5 filtration levels and group order at most 120; check whether every failure of multiplicativity occurs at a shared prime with non-additive local barcode length.

### Conjecture B: Asymptotic stabilization
For fixed `F₁, F₂`, the overlap correction tends to `1` as `s → ∞`.

In formalized finite arithmetic terms, state a rational inequality prediction:
```lean
conjecture overlapCorrection_tends_to_one_heuristic
  (F₁ F₂ : ArithmeticFilteredAbelianGroup) :
  ∀ ε > 0, ∃ S : ℕ, ∀ s ≥ S,
    ‖overlapCorrection F₁ F₂ s - 1‖ < ε
```

If real-analysis infrastructure is too heavy, phrase this in `ℚ` with explicit denominator bounds. The computational test is immediate from exact rational evaluation for increasing `s`.

This is scientifically interesting because it says interaction among shared primes is a low-temperature / low-frequency effect that decays analytically.

---

## Algorithmic Deliverable

You must produce a **verified computational method**, not just theorem statements.

### Required algorithm
Define and verify an algorithm that computes `persistenceZeta` from prime barcode data:

```lean
def computePersistenceZeta
  (primeData : Finset (ℕ × ℕ)) -- (p, local barcode length)
  (s : ℕ) : ℚ := ...
```

Then prove correctness against the abstract definition:

```lean
theorem computePersistenceZeta_correct
  (F : ArithmeticFilteredAbelianGroup) (s : ℕ)
  (hdata : primeDataOf F = ...) :
  computePersistenceZeta (primeDataOf F) s = persistenceZeta F s := ...
```

Also define and verify:

```lean
def computeOverlapCorrection ... : ℚ := ...
```

with correctness theorem against `overlapCorrection`.

This gives a certified engine for experiments and turns the theory into a usable scientific object.

---

## Demo Requirements

Provide `demo.py` that:

1. Enumerates sample filtered finite abelian groups of order ≤ 120 with ≤ 5 filtration levels.
2. Computes local barcode lengths and `persistenceZeta(F,s)` for `s ∈ {1,2,3}`.
3. Tests multiplicativity on products.
4. Identifies overlap primes when multiplicativity fails.
5. Displays examples where:
   - supports are disjoint and multiplicativity holds,
   - supports overlap and correction factor is nontrivial.

The demo should visualize the Euler factors per prime and the correction term.

---

## Deliverables You Must Produce

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
A structured document with **3–5 testable scientific hypotheses**, each falsifiable and paired with a concrete computational or theoretical test.

Examples of acceptable hypotheses:
- overlap correction is always positive for `s ≥ 1`,
- multiplicativity extends from products to short exact sequences under a suitable independence condition,
- the logarithm of persistence zeta satisfies a prime-sum expansion analogous to Dirichlet series coefficients,
- asymptotic decay rate of overlap correction is governed by the smallest shared prime.

### 2. `RESEARCH_PAPER.md`
A **standalone scientific paper** explaining:
- the definition of persistence zeta,
- the CRT/local-global philosophy,
- the exact multiplicativity theorem,
- the correction-factor theorem,
- computational evidence and open problems.

Someone reading only this paper must understand the discovery without seeing the code.

### 3. `ARTICLE.md`
A Scientific American–style article for a broad audience.
Do **not** focus on formal verification machinery. Focus on the ideas:
- why prime numbers can organize topological summaries of data,
- why Euler products unexpectedly appear in persistence theory,
- why this may launch arithmetic TDA.

### 4. Verified algorithm / computational method
At minimum:
- `computePersistenceZeta`
- `computeOverlapCorrection`
- correctness theorems

### 5. `demo.py`
Interactive demonstration of the theorem and correction law.

---

## Concrete Theorem Development Plan

A strong implementation order is:

1. **Define** `ArithmeticFilteredAbelianGroup`.
2. **Define** `localBarcodeLength`, `persistenceZetaFactor`, `persistenceZeta`, `overlapCorrection`.
3. Prove support lemmas:
   - zero local barcode off support,
   - support of product inside union,
   - factor equals 1 off support.
4. Prove finite-product decomposition over disjoint/overlapping supports.
5. Prove exact correction-factor theorem.
6. Use CRT decomposition to prove local additivity under coprime support.
7. Deduce headline multiplicativity theorem.
8. Implement certified computation and `demo.py`.
9. State conjectures and computational predictions.

---

## What Would Make This Revolutionary

If you prove the coprime-support multiplicativity theorem and the exact overlap-correction law, you will have shown that persistence admits:
- local prime factors,
- global Euler products,
- interaction terms at bad primes.

That is not a minor theorem. It is the beginning of a dictionary:

- **prime support** ↔ bad reduction,
- **barcode length** ↔ local arithmetic mass,
- **persistence zeta** ↔ global Dirichlet generating function,
- **overlap correction** ↔ ramification / interaction factor.

This would enable follow-on work on:
- persistence L-functions,
- logarithmic derivatives and “persistence von Mangoldt” coefficients,
- Tauberian asymptotics for barcode growth,
- adelic reconstruction of filtered data,
- statistical-mechanical interpretations of persistence invariants.

Do not merely verify an identity. Build the first real bridge between **analytic number theory** and **topological data analysis**.

**Application keywords:** analytic number theory, topological data analysis, Euler product, CRT decomposition, finite abelian groups, barcode invariants, multiplicative functions, adelic persistence, partition functions, local-global principle, bad primes, arithmetic topology.

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
