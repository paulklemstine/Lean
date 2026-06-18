Soli Deo Gloria

## Assignment: Galois Theory Beyond Abel–Ruffini — Derived-Series Obstructions, Resolvent Certificates, and Arithmetic Detection of Nonsolvability

Prove new, non-trivial theorems in Lean 4. Build on catalog theorems. Minimize sorry. Do not merely restate classical textbook facts unless you package them into formally powerful criteria, explicit algorithms, and cross-domain bridges that open new formalization territory.

## Mode
**prove**

## Core Vision

Do **not** aim only for “formalize the fundamental theorem of Galois theory” in the abstract. That is too broad and too vulnerable to library limitations. Instead, isolate a breakthrough formal package:

1. a **machine-checkable obstruction theory for solvability by radicals** built from explicit finite-group certificates,
2. a **resolvent/discriminant-based detection framework** for quintics and related polynomials,
3. a **bridge from arithmetic data of a polynomial to group-theoretic nonsolvability**, and
4. a **cross-domain link** showing how Galois correspondences interact with general order-theoretic Galois connections already present in the catalog.

The revolutionary goal is not just “Abel–Ruffini in Lean,” but a reusable **formal decision pipeline**:
polynomial coefficients → arithmetic invariants / modular factorization data → explicit Galois-group embedding or identification → derived-series obstruction → impossibility of solution by radicals.

This opens a field-scale program in formal inverse Galois theory, symbolic computation, certified algebraic number theory, and automated theorem-guided polynomial solving.

## Existing Verified Theorems to Build On

You already have:

- `FINAL/Algebra/UnifyingTheory.lean`
  - `fundamental_theorem_algebraic_light'`
- `Algebra/ProofSpectra/Core.lean`
  - `galois_connection_theory_variety`
- `Algebra/GaloisObstruction.lean`
  - `galGroup_not_solvable_of_mulEquiv_S5`

The theorem
`galGroup_not_solvable_of_mulEquiv_S5`
is especially valuable: it gives a **certified terminal obstruction**. Your task is to build the missing architecture around it so that explicit polynomials can feed into this obstruction.

## Precise Theorem Targets

You must prove **at least 3 deep theorems**. The strongest possible package is the following.

---

### Theorem 1: Solvability descends along subnormal/derived-series comparison

Define a new notion expressing that a finite group is “radical-admissible” via a finite derived-series collapse to the trivial subgroup. Even if Mathlib already has `Group.Solvable`, you must define a new structure tailored to your computational certificates.

Suggested new definition:

```lean
structure DerivedSeriesCertificate (G : Type*) [Group G] where
  depth : ℕ
  witness : True -- replace with actual data encoding termination of derived series
```

Better, if feasible, define a recursive predicate:

```lean
def RadicalSolvable (G : Type*) [Group G] : Prop :=
  ∃ n : ℕ, Group.derivatedSeries G n = ⊥
```

or an equivalent custom notion compatible with available APIs.

Then prove a theorem transferring explicit group equivalence into this certificate framework.

#### Precise target statement
```lean
theorem radicalSolvable_of_mulEquiv
    (G H : Type*) [Group G] [Group H]
    (e : G ≃* H) :
    RadicalSolvable G ↔ RadicalSolvable H
```

If `Group.derivatedSeries` is not the exact API name, adapt to the available derived-series object in Mathlib, but keep the theorem mathematically exact.

#### Why this matters
This is the formal hinge between explicit permutation-group identification and radical solvability. It turns concrete `MulEquiv`s into algebraic-solvability certificates and creates a reusable layer for future inverse Galois work.

---

### Theorem 2: Any polynomial whose Galois group is isomorphic to `S₅` is not solvable by radicals

This should sharpen and contextualize the existing obstruction theorem into a polynomial-facing theorem.

#### Precise target statement
A realistic Lean-facing version may look like:

```lean
theorem polynomial_not_solvable_by_radicals_of_galGroup_equiv_S5
    {K : Type*} [Field K]
    (f : K[X])
    (hf_sep : f.Separable)
    (hf_irred : Irreducible f)
    (hG : Nonempty ((f.SplittingField).galGroup f ≃* Equiv.Perm (Fin 5)))
    (hS5 : IsomorphicToS5 ((f.SplittingField).galGroup f)) :
    ¬ SolvableByRadicals f
```

You may need to define `SolvableByRadicals` if Mathlib lacks the exact notion. That is acceptable and encouraged. The important point is to encode the classical statement in a form that can actually be reused.

A more implementation-friendly variant is also acceptable:

```lean
theorem not_solvable_by_radicals_of_galGroup_mulEquiv_S5
    {G : Type*} [Group G]
    (hG : G ≃* Equiv.Perm (Fin 5)) :
    ¬ RadicalSolvable G
```

followed by a corollary transferring from the polynomial’s Galois group to the group statement.

#### Why this matters
This is the formal Abel–Ruffini obstruction in its most reusable form: not a one-off theorem about “the general quintic,” but a theorem schema for any explicit quintic whose Galois group is certified to be `S₅`.

---

### Theorem 3: An explicit quintic family with certified nonsolvable Galois obstruction

Do not try to formalize the full moduli-theoretic “general quintic” first. Instead, formalize one or more **explicit irreducible quintics** and prove that if their Galois group is `S₅`, then they are not solvable by radicals. Ideally, push all the way to a fully certified instance.

A canonical candidate is:
- `X^5 - X - 1`
or
- `X^5 - 6*X + 3`

#### Precise target statement
At minimum:
```lean
theorem quintic_X5_sub_X_sub_1_not_solvable_by_radicals :
    ¬ SolvableByRadicals (X^5 - X - 1 : ℚ[X])
```

If full identification of the Galois group is too library-heavy, split into two deep theorems:

```lean
theorem irreducible_X5_sub_X_sub_1 : Irreducible (X^5 - X - 1 : ℚ[X])
```

```lean
theorem not_solvable_by_radicals_of_assumed_galgroup_S5_X5_sub_X_sub_1
    (hG : Nonempty (((SplittingField (X^5 - X - 1 : ℚ[X]))).galGroup
      (X^5 - X - 1 : ℚ[X]) ≃* Equiv.Perm (Fin 5))) :
    ¬ SolvableByRadicals (X^5 - X - 1 : ℚ[X])
```

A strong intermediate arithmetic criterion is even better:

```lean
theorem transitive_subgroup_of_S5_with_2cycle_and_5cycle_is_S5
    (G : Subgroup (Equiv.Perm (Fin 5)))
    (htrans : MulAction.IsPretransitive G (Fin 5))
    (h2 : ∃ σ : G, orderOf σ.1 = 2)
    (h5 : ∃ σ : G, orderOf σ.1 = 5) :
    G = ⊤
```

or a more realistic statement identifying a subgroup with `S₅` under cycle-type hypotheses. This theorem is mathematically deep and computationally useful.

#### Why this matters
A single explicit polynomial with a formally certified nonsolvability proof is the seed of a whole library of machine-verified algebraic impossibility results.

---

### Theorem 4: Cross-domain theorem — Galois correspondence as an order-theoretic Galois connection

Use `galois_connection_theory_variety` as a conceptual bridge. Prove that the subgroup/intermediate-field correspondence in a finite Galois extension forms a Galois connection in the order-theoretic sense, and relate it to the abstract theorem already in the catalog.

#### Precise target statement
A schematic Lean target:

```lean
theorem intermediateField_subgroup_galoisConnection
    {K L : Type*} [Field K] [Field L] [Algebra K L]
    (hfin : FiniteDimensional K L)
    (hnorm : Normal K L)
    (hsep : Algebra.IsSeparable K L) :
    GaloisConnection
      (fun E : IntermediateField K L => fixingSubgroup E)
      (fun H : Subgroup (L ≃ₐ[K] L) => fixedField H)
```

Even if exact names differ, this is the theorem to target.

Then prove at least one monotonicity/closure theorem using `gc.l_u_l_eq_l` / `gc.u_l_u_eq_u` style reasoning.

#### Why this matters
This is your required cross-domain connection: classical field theory meets lattice/order theory and the general theory of Galois connections. It reframes Galois theory as a universal adjunction phenomenon, making the formal development interoperable with algebraic geometry, logic, and category-inspired infrastructure.

## Lean 4 Type Signatures to Aim For

Use or adapt these signatures as closely as Mathlib allows:

```lean
def SolvableByRadicals {K : Type*} [Field K] (f : K[X]) : Prop := ...
```

```lean
def RadicalSolvable (G : Type*) [Group G] : Prop := ...
```

```lean
theorem radicalSolvable_of_mulEquiv
    (G H : Type*) [Group G] [Group H]
    (e : G ≃* H) :
    RadicalSolvable G ↔ RadicalSolvable H
```

```lean
theorem not_radicalSolvable_of_mulEquiv_S5
    (G : Type*) [Group G]
    (e : G ≃* Equiv.Perm (Fin 5)) :
    ¬ RadicalSolvable G
```

```lean
theorem polynomial_not_solvable_by_radicals_of_galGroup_equiv_S5
    {K : Type*} [Field K]
    (f : K[X])
    (hf_sep : f.Separable)
    (hf_irred : Irreducible f)
    (hG : Nonempty ((SplittingField f).galGroup f ≃* Equiv.Perm (Fin 5))) :
    ¬ SolvableByRadicals f
```

```lean
theorem intermediateField_subgroup_galoisConnection
    {K L : Type*} [Field K] [Field L] [Algebra K L]
    (hfin : FiniteDimensional K L)
    (hnorm : Normal K L)
    (hsep : Algebra.IsSeparable K L) :
    GaloisConnection
      (fun E : IntermediateField K L => fixingSubgroup E)
      (fun H : Subgroup (L ≃ₐ[K] L) => fixedField H)
```

If the exact names in Mathlib differ, preserve the theorem’s mathematical content and document the name substitutions.

## Proof Strategy Architecture

You must include **2–3 serious proof strategies** and pursue the most promising one.

### Strategy A: Group-theoretic obstruction pipeline
1. Define `RadicalSolvable` using the derived series or a certificate that implies ordinary solvability.
2. Prove invariance under `MulEquiv`.
3. Use the existing theorem `galGroup_not_solvable_of_mulEquiv_S5` to show any group equivalent to `S₅` is not solvable.
4. Transfer that obstruction to polynomial solvability by radicals.

**Why promising:** it directly leverages the strongest verified theorem already in the catalog and avoids needing the full historical proof of Abel–Ruffini from scratch.

### Strategy B: Arithmetic-to-group detection via factorization modulo primes
1. For a concrete quintic over `ℚ`, prove irreducibility by Eisenstein, reduction, or rational root arguments.
2. Use modular factorization patterns to infer existence of Frobenius elements of certain cycle types.
3. Combine cycle-type information with subgroup classification of transitive subgroups of `S₅` to conclude the Galois group is `S₅`.
4. Invoke the obstruction theorem.

**Why revolutionary:** this creates a formal arithmetic detection engine for Galois groups, blending number theory, finite group theory, and computational algebra.

### Strategy C: Order-theoretic Galois connection route
1. Formalize the subgroup ↔ intermediate-field correspondence as a `GaloisConnection`.
2. Derive closure and anti-monotonicity properties abstractly.
3. Use these order-theoretic lemmas to control subextensions associated with solvable normal series.
4. Conclude that an `S₅`-type extension cannot be generated by a tower of radical extensions.

**Why conceptually deepest:** it unifies field-theoretic Galois theory with abstract adjunction machinery and creates reusable infrastructure far beyond quintics.

**Most promising path:** combine **A + B** for the main nonsolvability theorem and **C** for the cross-domain theorem. A gives the shortest route to verified progress; B turns it into genuine mathematics rather than a black-box obstruction; C opens new formal territory.

## Required Deep Proof Tactics

At least 3 theorems must use genuinely mathematical tactics such as:
- `induction`
- `rcases`
- `by_contra`
- `field_simp`
- multi-step `calc`
- subgroup lattice arguments
- polynomial coefficient comparison
- finite-group reasoning via cycle decomposition

Avoid trivial closure by automation. If a theorem collapses to `decide` or `native_decide`, replace it with a stronger theorem.

## Novel Definitions Required

You must define at least one genuinely new concept not already in the catalog. Strong candidates:

1. `RadicalSolvable`
   - a certificate-oriented version of solvability for groups;

2. `SolvableByRadicals`
   - for polynomials over a field, expressed via existence of a splitting tower of radical extensions;

3. `ResolventCertificate`
   - data structure packaging discriminant/modular factorization/cycle-type evidence for identifying the Galois group.

Example:
```lean
structure ResolventCertificate (f : ℚ[X]) where
  prime₁ : ℕ
  prime₂ : ℕ
  factor_pattern₁ : List ℕ
  factor_pattern₂ : List ℕ
  disc_nonsquare : Prop
```

A theorem turning `ResolventCertificate f` into `Gal(f) ≃ S₅` would be a major contribution.

## Cross-Domain Connections You Must Include

At least one theorem must connect Galois theory to another domain. Recommended options:

### Option 1: Order theory / lattice theory
Use `galois_connection_theory_variety` to frame the subgroup–field correspondence as a special case of a Galois connection.

### Option 2: Computational complexity / symbolic computation
Show that a certified `S₅` obstruction yields a proof-producing algorithm that terminates with “not solvable by radicals,” connecting algebra to decision procedures.

### Option 3: Number theory
Use modular reduction / discriminants / prime decomposition to infer cycle types of Frobenius elements and hence Galois-group structure.

### Application keywords
**formal Galois theory, Abel–Ruffini, solvability by radicals, derived series, permutation groups, Frobenius cycle types, splitting fields, lattice Galois connections, certified symbolic algebra, inverse Galois theory, algorithmic number theory**

## Concrete Theorem Package You Should Aim to Deliver

At minimum, produce 3 of the following with serious proofs:

1. `radicalSolvable_of_mulEquiv`
2. `not_radicalSolvable_of_mulEquiv_S5`
3. `irreducible_X5_sub_X_sub_1`
4. `polynomial_not_solvable_by_radicals_of_galGroup_equiv_S5`
5. `intermediateField_subgroup_galoisConnection`
6. a theorem that a transitive subgroup of `S₅` containing specified cycle types is all of `S₅`
7. a theorem extracting nonsolvability from a `ResolventCertificate`

## Conjecture with Testable Prediction

State at least one falsifiable conjecture with a computational disproof criterion. Recommended:

### Conjecture: Modular cycle-type certificate for generic quintics
For every irreducible quintic `f ∈ ℤ[X]` with nonsquare discriminant, if there exist primes `p,q` such that:
- `f mod p` is irreducible (giving a 5-cycle),
- `f mod q` factors as quadratic × linear × linear × linear (giving a transposition-like Frobenius cycle pattern),
then the Galois group of `f` over `ℚ` is `S₅`.

This is falsifiable: search over quintics and compute discriminants and factorization patterns modulo primes; a counterexample disproves it.

A Lean-friendly formulation can package the hypothesis as a `ResolventCertificate`.

## Deliverables (MANDATORY)

You must produce **all** of the following:

1. **Lean file(s)** with at least 3 nontrivial theorems using deep proof tactics.
2. **A structured `FUTURE_DIRECTIONS.md`** containing **3–5 testable scientific hypotheses**, each a falsifiable conjecture with a clear computational test.
3. **A standalone `RESEARCH_PAPER.md`** explaining:
   - the precise theorems proved,
   - the formal obstruction pipeline,
   - why the results matter mathematically,
   - what new research becomes possible.
4. **An `ARTICLE.md`** in Scientific American style for a broad audience.
5. **A verified algorithm or computational method**:
   - ideally a procedure that consumes arithmetic data of a quintic and returns a certified nonsolvability obstruction when enough evidence is present.
6. **A `demo.py`** that interactively demonstrates the result:
   - input a quintic,
   - compute simple invariants / modular factorization data,
   - display whether an `S₅`-style obstruction is detected,
   - explain the mathematical meaning of the certificate.

## Final Scientific Ambition

Do not merely formalize an old theorem. Build the first pieces of a **formal Abel–Ruffini detection engine**. The breakthrough is a reusable architecture connecting:
- explicit polynomials,
- arithmetic invariants,
- finite permutation groups,
- derived-series solvability,
- and order-theoretic Galois correspondences.

If you succeed, this will not be “one more Lean theorem.” It will be a blueprint for certified impossibility proofs in symbolic algebra and a launchpad for formal inverse Galois theory.

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
