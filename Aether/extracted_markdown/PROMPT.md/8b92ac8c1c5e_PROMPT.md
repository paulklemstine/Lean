## Assignment: Direction 2: Efficient Computation via Smith Normal Form (Extension → Breakthrough)

**Mode:** `prove` + `formalize` + `discover`

Build a formal computational theory of **secondary torsion obstructions for filtered chain complexes over ℤ** that turns the abstract long exact sequence machinery into an explicit **Smith-normal-form-driven algorithm** with cubic-time complexity in the matrix size. This must not be a cosmetic implementation of known homological algebra: the target is a new formal bridge between **derived obstruction theory, exact sequence functoriality, and certified integer linear algebra**.

The decisive breakthrough is to show that a genuinely derived invariant — the obstruction detected by a connecting morphism on torsion — can be extracted **purely from matrix normal forms and basis-change data**, without resorting to brute-force homological constructions. If successful, this opens a new program: **certified derived persistence by exact linear algebra over PID coefficients**.

## Core Theorem Targets

You should formalize a precise notion of a **two-step filtered chain complex of free finitely generated abelian groups** and define a new computable invariant, the **SNF secondary torsion obstruction**.

### New definition to introduce
Define a structure, not already in the catalog, along the following lines:

```lean
structure TwoStepFilteredChainComplex where
  C₁ C₀ Q : Type
  [addCommGroup C₁] [Module ℤ C₁] [Module.Free ℤ C₁] [Module.Finite ℤ C₁]
  [addCommGroup C₀] [Module ℤ C₀] [Module.Free ℤ C₀] [Module.Finite ℤ C₀]
  [addCommGroup Q]  [Module ℤ Q]  [Module.Free ℤ Q]  [Module.Finite ℤ Q]
  i : C₁ →ₗ[ℤ] C₀
  p : C₀ →ₗ[ℤ] Q
  exact_i_p : LinearMap.range i = LinearMap.ker p
```

and then a degreewise version for chain complexes, or a structure encoding one filtration step
\[
0 \to A_\bullet \xrightarrow{i} C_\bullet \xrightarrow{p} Q_\bullet \to 0.
\]

Define the computable obstruction:
```lean
def secondaryTorsionObstruction
  (F : TwoStepFilteredChainComplex) (n : ℤ) : Type := ...
```
or more canonically as an element/subgroup in a quotient such as \(A/nA\), extracted from the connecting homomorphism on torsion classes.

This definition should be *algorithm-facing*: it should expose dependence on boundary matrices and on SNF decomposition data.

---

## Precise theorem statement with Lean-oriented targets

Your first theorem should isolate the algebraic heart of the computation.

### Theorem 1: Connecting map from SNF data
For a short exact sequence of finitely generated free abelian groups
\[
0 \to A \xrightarrow{i} B \xrightarrow{p} C \to 0
\]
and an endomorphism \(d : C \to C\) induced from a compatible chain-level differential, the connecting homomorphism on torsion classes can be written explicitly using Smith normal form data of the relevant integer matrices.

A Lean-facing theorem target could be:

```lean
theorem connecting_hom_eq_snf_formula
  {A B C : Type*}
  [AddCommGroup A] [Module ℤ A] [Module.Free ℤ A] [Module.Finite ℤ A]
  [AddCommGroup B] [Module ℤ B] [Module.Free ℤ B] [Module.Finite ℤ B]
  [AddCommGroup C] [Module ℤ C] [Module.Free ℤ C] [Module.Finite ℤ C]
  (i : A →ₗ[ℤ] B) (p : B →ₗ[ℤ] C)
  (hexact : LinearMap.range i = LinearMap.ker p)
  (M : Matrix (Fin m) (Fin n) ℤ)
  (S U V : Matrix _ _ ℤ)
  (hSNF : SmithNormalForm M S U V)
  :
  connectingHom i p = explicitSNFConnectingMap i p S U V
```

You will need to adapt the exact type to available Mathlib infrastructure; the mathematical content is non-negotiable: the abstract connecting morphism must equal an explicit map computed from diagonal invariants and basis changes.

### Theorem 2: Correctness of composed-SNF obstruction algorithm
For a two-step filtered chain complex \(0 \to A_\bullet \to C_\bullet \to Q_\bullet \to 0\), the secondary torsion obstruction computed by:
1. SNF of the subcomplex differential,
2. SNF of the total complex differential,
3. SNF of the quotient complex differential,
4. explicit connecting-map reconstruction from basis changes,

agrees with the abstract obstruction from the long exact sequence in homology.

Lean target:

```lean
theorem secondary_obstruction_algorithm_correct
  (F : FilteredChainComplexTwoStep ℤ)
  [FiniteTypeHypotheses F]
  :
  algorithmicSecondaryObstruction F = abstractSecondaryObstruction F
```

This is the central theorem. It converts homological algebra into certified computation.

### Theorem 3: Cubic-time reducibility to SNF oracle
Prove that if Smith normal form of an \(n \times n\) integer matrix is available in \(O(n^3)\) ring operations, then the secondary torsion obstruction for a bounded two-step filtered chain complex of matrix dimension at most \(n\) is computable in \(O(n^3)\) many calls plus lower-order matrix operations.

Lean target:

```lean
theorem secondary_obstruction_time_bound
  (F : FilteredChainComplexTwoStep ℤ)
  (hdim : matrixDim F ≤ n)
  :
  bitComplexity (algorithmicSecondaryObstruction F) ≤
    K * n^3 + K'
```

If exact bit-complexity is too far from current Mathlib, formalize instead an **operation-count model**:

```lean
theorem secondary_obstruction_reduces_to_three_snf
  (F : FilteredChainComplexTwoStep ℤ) :
  ∃ data,
    algorithmUsesAtMostThreeSNFCalls F data ∧
    reconstructsSecondaryObstruction F data
```

This still qualifies as a deep theorem if the reconstruction proof is substantial.

### Theorem 4: Cyclic-case validation via Tor
Use the catalog theorem
`Catalog/Algebra/Homology/DerivedFunctors/ExtTorBasic.lean`
especially `Tor1_ZMod_ZMod_equiv`,
to validate the algorithm in the cyclic quotient case.

Mathematical statement:
For \(A = \mathbb Z/a\), \(C = \mathbb Z/b\), the obstruction computed from SNF agrees with the canonical class in
\[
\operatorname{Tor}_1^{\mathbb Z}(\mathbb Z/a,\mathbb Z/b) \cong \mathbb Z/\gcd(a,b).
\]

Lean target:

```lean
theorem cyclic_case_secondary_obstruction_agrees_with_Tor
  (a b : ℕ) :
  algorithmicCyclicObstruction a b =
    (Tor1_ZMod_ZMod_equiv a b).symm (canonicalTorClass a b)
```

This theorem is your cross-check and your bridge to the derived functor catalog.

---

## Why this is a breakthrough

The usual story is that Smith normal form computes homology groups. That is old. The new story you should force into existence is:

> **Smith normal form also computes secondary derived structure — not just primary homology — when the exact-sequence geometry is tracked through basis-change matrices.**

That is qualitatively different. It would mean:
- filtered obstruction theory becomes algorithmic,
- derived persistence can be implemented over ℤ with certificates,
- torsion-sensitive topological data analysis becomes computationally realistic,
- homological algebra gains a new formal interface with exact integer linear algebra.

This opens a field of **certified derived computational topology**.

---

## Proof architecture: 3 viable strategies

### Strategy A: Matrix-level reconstruction of the connecting morphism
**Most promising.**

1. Choose bases for all finitely generated free abelian groups and represent differentials/inclusions/projections as integer matrices.
2. Use SNF decompositions \(UMV = D\) to split domain/codomain into free and torsion-relevant coordinates.
3. Show that the abstract connecting morphism is represented by an explicit formula involving:
   - the diagonal entries of the quotient differential SNF,
   - the basis-change matrices \(U, V\),
   - a lift-and-reduce operation modulo the image lattice.
4. Prove independence of basis choices by conjugacy/invariance under unimodular transformations.
5. Deduce that the algorithmic obstruction equals the abstract one.

**Why most promising:** everything is concrete, compatible with Lean’s matrix infrastructure, and naturally supports an executable algorithm.

### Strategy B: Derived-functor comparison via Tor and snake lemma
1. Define the obstruction abstractly through the long exact sequence in homology.
2. Identify the torsion piece with a Tor-class using catalog results like `Tor1_ZMod_ZMod_equiv`.
3. Prove that the SNF-produced class realizes the same universal property as the Tor connecting class.
4. Use naturality and cyclic decomposition of finitely generated abelian groups to reduce the general case to cyclic summands.

**Strength:** conceptually elegant and ties directly to the catalog.  
**Weakness:** likely heavier categorical overhead in Lean.

### Strategy C: Spectral-sequence-lite filtration argument
1. Regard the two-step filtration as the minimal nontrivial filtered complex.
2. Interpret the secondary obstruction as the first nontrivial differential/extension datum beyond the graded homology.
3. Show that for a two-step filtration, this datum collapses to the explicit SNF connecting formula.
4. Use this to motivate later generalization to multi-step filtered complexes and derived persistence.

**Strength:** visionary and opens future work.  
**Weakness:** more infrastructure than needed for the first breakthrough.

**Recommendation:** Prove the main result with **Strategy A**, validate special cases and conceptual meaning with **Strategy B**, and present **Strategy C** in `FUTURE_DIRECTIONS.md` as the next frontier.

---

## Required deep theorem style

Your file must contain **at least 3 substantial theorems** proved with real mathematical tactics:
- induction on rank / cyclic decomposition,
- `rcases` on exactness witnesses and torsion representatives,
- `by_contra` for uniqueness or well-definedness,
- `field_simp` where rationalized determinant arguments or divisibility lemmas appear,
- multi-step `calc` chains for equality of maps/classes.

Do **not** hide the mathematics behind automation. The point is to formalize the mechanism, not merely certify examples.

---

## Cross-domain connection theorems

You must include at least one theorem connecting this algebraic framework to another domain.

### Option 1: Computational topology bridge
Show that for the standard skeletal filtration of a lens space \(L(p,1)\), the computed secondary torsion obstruction recovers the expected torsion linking behavior in degree 1/2.

Lean-style target:
```lean
theorem lensSpace_obstruction_detects_p_torsion
  (p : ℕ) [Fact (0 < p)] :
  secondaryObstruction (lensSpaceFilteredComplex p) ≠ 0
```

### Option 2: Numerical linear algebra bridge
Prove that the obstruction is invariant under certified row/column preconditioning by unimodular matrices, connecting homological invariants with stable integer linear algebra.

```lean
theorem obstruction_invariant_under_unimodular_preconditioning
  (F : FilteredChainComplexTwoStep ℤ)
  (U V : Matrix (Fin n) (Fin n) ℤ)
  (hU : IsUnimodular U) (hV : IsUnimodular V) :
  algorithmicSecondaryObstruction (precondition F U V) =
    algorithmicSecondaryObstruction F
```

### Option 3: Physics-inspired bridge
Interpret the torsion obstruction as a discrete anomaly/defect class in a lattice gauge toy model built from the chain complex. Even a formal theorem saying “gauge-equivalent integer presentations have identical obstruction classes” would be a strong algebra–physics bridge.

**Application keywords:** derived persistence, topological data analysis, certified integer linear algebra, exact sequences, torsion detection, spectral invariants, computational homological algebra, lattice topology, discrete gauge anomalies.

---

## Concrete computational agenda

Implement the conjectured algorithm and test it on:

1. **Lens spaces \(L(p,1)\)** with standard skeletal filtration.
2. **Random sparse integer boundary matrices** up to \(100 \times 100\) with entries in \(\{-2,-1,0,1,2\}\).
3. **Mapping torus chain complexes** from triangulated automorphisms.

For small examples, compare against brute-force enumeration of lifts and connecting classes. If failure occurs, identify whether the issue lies in:
- non-functorial basis choices,
- quotient-lift ambiguity,
- hidden saturation issues in sublattices,
- mismatch between SNF decomposition and exact-sequence representatives.

This failure analysis is scientifically valuable and should be formalized if discovered.

---

## Falsifiable conjectures for the next cycle

Include at least one explicit conjecture in the code/comments and fully in `FUTURE_DIRECTIONS.md`.

### Conjecture A: Saturation-stability criterion
For a two-step filtered chain complex of free abelian groups, the secondary torsion obstruction vanishes whenever the inclusion of cycle lattices is saturated after SNF basis normalization.

**Test:** generate random filtered complexes, compute saturation index, and check vanishing/nonvanishing correlation. A single counterexample falsifies it.

### Conjecture B: Sparse genericity
For random sparse integer filtered complexes with bounded entries, the probability of nonzero secondary torsion obstruction tends to 1 as rank grows, conditioned on nontrivial quotient torsion.

**Test:** Monte Carlo over sizes \(10,20,\dots,100\). Disprove by observing decay or stabilization away from 1.

### Conjecture C: Lens-space rigidity
For the standard skeletal filtration on \(L(p,1)\), the secondary obstruction determines \(p\) up to sign.

**Test:** compute obstructions for many \(p\); falsified if two distinct \(p\) yield identical obstruction data under the canonical normalization.

---

## Catalog dependency and how to use it

Build directly on:

- `Catalog/Algebra/Homology/DerivedFunctors/ExtTorBasic.lean`
  - especially `Tor1_ZMod_ZMod_equiv`

Use it not as decoration but as a **certified reduction principle**:
1. decompose torsion modules into cyclic summands via SNF,
2. reduce the comparison theorem to cyclic factors,
3. invoke `Tor1_ZMod_ZMod_equiv` to identify the abstract derived class,
4. reassemble by naturality/additivity.

If the lineage theorem `no_obstruction_iff_torsion_surjective` is already present in the live context, use it as follows:
- prove your algorithm computes the map whose surjectivity is tested there,
- derive a corollary giving an **effective decision procedure** for the obstruction criterion.

Example target:

```lean
theorem no_obstruction_iff_algorithmic_surjective
  (F : FilteredChainComplexTwoStep ℤ) :
  noObstruction F ↔ algorithmicConnectingMapSurjective F
```

This is exactly the theory-to-practice bridge the project needs.

---

## Deliverables you must produce

You must deliver **all** of the following:

1. **Lean file(s)** with:
   - at least one new structure/definition,
   - at least 3 nontrivial theorems,
   - minimized `sorry`,
   - an executable obstruction algorithm.

2. **`FUTURE_DIRECTIONS.md`**
   - 3–5 falsifiable scientific hypotheses,
   - each with a concrete computational test and possible failure mode.

3. **`RESEARCH_PAPER.md`**
   - standalone scientific paper,
   - explains the invariant, theorem statements, proof ideas, algorithm, experiments, significance,
   - readable without access to code.

4. **`ARTICLE.md`**
   - Scientific American style,
   - explain how a classical algebraic normal form unexpectedly computes a derived topological obstruction.

5. **Verified algorithm / computational method**
   - not merely theorem statements,
   - explicit reconstruction of the obstruction from SNF data.

6. **`demo.py`**
   - interactive demo computing the obstruction on sample filtered complexes,
   - include lens spaces, random matrices, and one mapping torus example.

---

## Standard for success

Success is **not** “we formalized another SNF lemma.”  
Success is:

> We proved that a secondary homological obstruction, previously defined abstractly through exact sequences, can be computed explicitly and certifiably from Smith normal form data, and we validated it on topological examples.

That is a field-opening result at the interface of **homological algebra, certified computation, and torsion-sensitive topological data analysis**.

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
