## Assignment: Homological Algebra: Derived Functors

**Mode:** `prove` + `formalize`

You are not being asked to merely port textbook homological algebra into Lean. You are being asked to build the first genuinely reusable computational skeleton for derived functors in Mathlib-facing Lean 4, with enough concrete content that Ext, Tor, connecting morphisms, and universal coefficient phenomena become *executable mathematics* rather than aspirational abstractions.

The breakthrough target is this:

> **Make derived functors concrete enough in Lean that one can both prove structural theorems and compute nontrivial examples for modules over `ℤ`, thereby turning abstract homological algebra into a verified algorithmic laboratory.**

This is important because once Ext/Tor and long exact sequences are formalized at the level of concrete resolutions and quotient/kernel computations, Lean becomes capable of certifying algebraic topology, representation theory, coding theory, and even parts of topological phases of matter that rely on universal coefficient phenomena. This is the gateway theorem stack.

---

## Core Research Objective

Formalize a concrete, computation-ready fragment of derived functor theory for modules over `ℤ` (and, where possible, over a general ring `R`), centered on:

1. **Concrete projective/free resolutions**
2. **Definition and computation of `Ext¹` and `Tor₁`**
3. **Long exact sequence mechanisms arising from short exact sequences**
4. **A concrete universal coefficient theorem for homology with coefficients**
5. **At least one cross-domain theorem linking these homological invariants to another area**

You should prioritize statements that are both:
- mathematically deep enough to matter, and
- formalizable against current Lean/Mathlib infrastructure with minimal sorry.

Use the existing verified theorem  
`Tor1_vanishes_for_free` from  
`Algebra/Homology/DerivedFunctors/UniversalCoefficient.lean`  
as a seed result, not an endpoint. The theorem says free modules kill first Tor in a concrete case; your task is to architect the surrounding world in which this theorem becomes a corollary of a larger machine.

---

## Exact Theorem Targets

You must prove **at least 3 substantial theorems**. The following are the highest-priority theorem statements.

### Theorem A: `Ext¹(ℤ/nℤ, A)` computes `A/nA`

For an abelian group `A` (formalized as `Module ℤ A` / `AddCommGroup A`), prove the classical computation:
\[
\operatorname{Ext}^1_{\mathbb Z}(\mathbb Z/n\mathbb Z, A)\;\cong\; A / nA
\]
for `n ≠ 0`.

This is one of the first truly meaningful derived-functor computations and should be formalized via an explicit free resolution of `ℤ/nℤ`.

### Lean-oriented type signature sketch
```lean
theorem ext1_Zmod_eq_quotient
  (A : Type*) [AddCommGroup A] [Module ℤ A]
  (n : ℤ) (hn : n ≠ 0) :
  Nonempty ((Ext1ZMod n A) ≃ₗ[ℤ] QuotientAddGroup.quotient (zmultiplesSubgroup A n))
```

If `≃ₗ[ℤ]` is too ambitious at first, use an additive equivalence:
```lean
theorem ext1_Zmod_eq_quotient
  (A : Type*) [AddCommGroup A] [Module ℤ A]
  (n : ℤ) (hn : n ≠ 0) :
  Nonempty (Ext1ZMod n A ≃+ A ⧸ zmultiplesSubgroup A n)
```

### New definition required
Introduce a novel concrete structure, for example:
```lean
def zmultiplesSubgroup
  (A : Type*) [AddCommGroup A] [Module ℤ A] (n : ℤ) : AddSubgroup A :=
{ carrier := {a | ∃ b, n • b = a},
  zero_mem' := by
  add_mem' := by
  neg_mem' := by }
```
This is not just bookkeeping: it is the computational bridge between abstract Ext and quotient data.

---

### Theorem B: `Tor₁(ℤ/nℤ, A)` computes the `n`-torsion subgroup

Prove
\[
\operatorname{Tor}^{\mathbb Z}_1(\mathbb Z/n\mathbb Z, A)
\;\cong\;
A[n] := \{a \in A \mid n a = 0\}
\]
for `n ≠ 0`.

### Lean-oriented type signature sketch
```lean
def nTorsionSubgroup
  (A : Type*) [AddCommGroup A] [Module ℤ A] (n : ℤ) : AddSubgroup A := ...

theorem tor1_Zmod_eq_torsion
  (A : Type*) [AddCommGroup A] [Module ℤ A]
  (n : ℤ) (hn : n ≠ 0) :
  Nonempty (Tor1ZMod n A ≃+ nTorsionSubgroup A n)
```

This theorem should explicitly build on the same free resolution used for Theorem A.  
It upgrades the catalog theorem

- `Tor1_vanishes_for_free`
  from `Algebra/Homology/DerivedFunctors/UniversalCoefficient.lean`

into part of a coherent computational theory:
- when `A` is free, `nTorsionSubgroup A n = ⊥`, hence `Tor₁ = 0`.

A strong corollary to prove:
```lean
theorem tor1_Zmod_free_vanishes_via_torsion
  (A : Type*) [AddCommGroup A] [Module ℤ A] [Module.Free ℤ A]
  (n : ℤ) (hn : n ≠ 0) :
  Subsingleton (Tor1ZMod n A)
```
or a suitable zero-object / trivial-group formulation.

---

### Theorem C: Concrete long exact sequence fragment in `Hom(-, A)` or `(- ⊗ A)`

Given a short exact sequence
\[
0 \to M' \xrightarrow{f} M \xrightarrow{g} M'' \to 0,
\]
construct and prove exactness of the induced connecting sequence fragment:
\[
0 \to \operatorname{Hom}(M'',A) \to \operatorname{Hom}(M,A) \to \operatorname{Hom}(M',A)
\to \operatorname{Ext}^1(M'',A) \to \operatorname{Ext}^1(M,A).
\]

You do **not** need the full infinite long exact sequence if infrastructure is too heavy; a rigorous exact 5-term fragment is already significant and field-opening if done concretely.

### Lean-oriented type signature sketch
```lean
structure ShortExactZMod
  (M' M M'' : Type*)
  [AddCommGroup M'] [Module ℤ M']
  [AddCommGroup M]  [Module ℤ M]
  [AddCommGroup M''] [Module ℤ M''] :=
(f : M' →ₗ[ℤ] M)
(g : M →ₗ[ℤ] M'')
(inj_f : Function.Injective f)
(exact_fg : LinearMap.range f = LinearMap.ker g)
(surj_g : Function.Surjective g)
```

Then define a connecting morphism:
```lean
def connectingHomToExt
  (S : ShortExactZMod M' M M'') (A : Type*) [AddCommGroup A] [Module ℤ A] :
  (M' →ₗ[ℤ] A) →+ Ext1Concrete M'' A := ...
```

And prove exactness:
```lean
theorem hom_ext_exact_fragment
  (S : ShortExactZMod M' M M'') (A : Type*) [AddCommGroup A] [Module ℤ A] :
  Exact
    (precompLinear S.g A)
    (precompLinear S.f A) ∧
  Exact
    (precompLinear S.f A)
    (connectingHomToExt S A)
```

This is a major milestone: it formalizes *the mechanism* that makes derived functors useful.

---

### Theorem D: Universal coefficient theorem for finitely generated chain complexes over `ℤ`

For a chain complex `C` of finitely generated free abelian groups, prove a concrete split short exact sequence
\[
0 \to H_n(C)\otimes A \to H_n(C;A) \to \operatorname{Tor}_1^{\mathbb Z}(H_{n-1}(C),A) \to 0.
\]

If the fully general statement is too infrastructure-heavy, prove it for a bounded concrete chain complex of free `ℤ`-modules.

### Lean-oriented type signature sketch
```lean
theorem universal_coefficient_short_exact
  (C : ConcreteChainComplex ℤ)
  (hfree : ∀ n, Module.Free ℤ (C.X n))
  (A : Type*) [AddCommGroup A] [Module ℤ A]
  (n : ℕ) :
  ShortExactZMod
    (HomologyTensorTerm C A n)
    (HomologyWithCoefficients C A n)
    (TorTermFromPrevHomology C A n)
```

Or, if you can express splitting:
```lean
theorem universal_coefficient_split
  ... :
  Nonempty (
    HomologyWithCoefficients C A n ≃+
      (HomologyGroup C n ⊗[ℤ] A) ⊕ Tor1OfHomologyPrev C A n
  )
```

This is the theorem that opens algebraic topology and computational topology to certified derived-functor computation.

---

## Cross-Domain Connection Requirement

You must include at least one theorem connecting homological algebra to another domain. Choose one of the following high-impact directions.

### Option 1: Algebraic Topology / Data Analysis
Show that if a finite chain complex has torsion-free homology in degree `n-1`, then coefficient extension preserves homology in degree `n`:
\[
H_n(C;A) \cong H_n(C)\otimes A.
\]
This is the rigorous form of “no hidden torsion obstruction,” and it has direct meaning in topological data analysis.

#### Lean sketch
```lean
theorem homology_with_coefficients_of_torsion_free_prev
  (C : ConcreteChainComplex ℤ)
  (A : Type*) [AddCommGroup A] [Module ℤ A]
  (n : ℕ)
  (htf : IsTorsionFreeAbGroup (HomologyGroup C (n-1))) :
  Nonempty (
    HomologyWithCoefficients C A n ≃+
    (HomologyGroup C n ⊗[ℤ] A)
  )
```

### Option 2: Coding Theory / Physics
Interpret `Tor₁(ℤ/nℤ, A)` as the obstruction space for `n`-periodic excitations or `n`-torsion code defects. Prove a theorem identifying vanishing of this Tor group with absence of `n`-torsion states.

#### Lean sketch
```lean
theorem tor1_vanishes_iff_no_n_torsion
  (A : Type*) [AddCommGroup A] [Module ℤ A]
  (n : ℤ) (hn : n ≠ 0) :
  Subsingleton (Tor1ZMod n A) ↔
  ∀ a : A, n • a = 0 → a = 0
```

This is mathematically clean and conceptually powerful: derived functors become measurable defect detectors.

### Option 3: Number Theory
For finite abelian groups presented via Smith normal form, prove that `Tor₁(ℤ/nℤ, A)` has cardinality equal to the number of invariant factors divisible by `n` in the appropriate sense. This would connect homological algebra to arithmetic structure theory.

---

## Suggested Novel Definitions

You must define at least one genuinely new concept not already in the catalog. Good candidates:

1. `zmultiplesSubgroup A n`
2. `nTorsionSubgroup A n`
3. `ShortExactZMod`
4. `ConcreteFreeResolution M`
5. `Ext1Concrete M A` as equivalence classes of extensions or as a cokernel of explicit maps from a chosen free resolution
6. `Tor1Concrete M A` as homology of tensoring a chosen free resolution

A particularly promising design is:

```lean
structure ConcreteFreeResolution
  (M : Type*) [AddCommGroup M] [Module ℤ M] :=
(F1 : Type*) [AddCommGroup F1] [Module ℤ F1] [Module.Free ℤ F1]
(F0 : Type*) [AddCommGroup F0] [Module ℤ F0] [Module.Free ℤ F0]
(d : F1 →ₗ[ℤ] F0)
(π : F0 →ₗ[ℤ] M)
(exact : LinearMap.range d = LinearMap.ker π)
(surj : Function.Surjective π)
```

Then define:
- `Ext1Concrete M A := cokernel ((LinearMap.lcomp ℤ _ _ _).something)`
- `Tor1Concrete M A := ker / image` from tensoring this two-term resolution

This is a decisive architectural move: it makes derived functors computable from finite presentations.

---

## Proof Strategy Architecture

You must present and execute **2–3 proof strategies** across the theorem suite. Do not rely on a single line of attack.

### Strategy A: Two-term free resolution of `ℤ/nℤ` by multiplication-by-`n`
Use the exact sequence
\[
\mathbb Z \xrightarrow{\cdot n} \mathbb Z \to \mathbb Z/n\mathbb Z \to 0.
\]
Apply `Hom(-,A)` and `(- ⊗ A)` concretely.

**Steps**
1. Define the two-term free resolution of `ℤ/nℤ` with differential `z ↦ n*z`.
2. Compute the induced cochain/chain maps explicitly:
   - `Hom(ℤ,A) ≃ A`, map becomes multiplication by `n`
   - `ℤ ⊗ A ≃ A`, map becomes multiplication by `n`
3. Identify cokernel and kernel with `A/nA` and `A[n]`.

**Why promising:** This gives explicit formulas and avoids heavy categorical machinery. It is the best route for Theorems A and B.

---

### Strategy B: Extension-class model for `Ext¹`
Define `Ext1Concrete M A` as equivalence classes of short exact sequences
\[
0 \to A \to E \to M \to 0
\]
with Baer-sum-inspired additive structure, at least in a restricted concrete setting.

**Steps**
1. Define extension objects and equivalence of extensions.
2. For `M = ℤ/nℤ`, classify extensions by the image of a chosen lift of `1 mod n`.
3. Show equivalence classes correspond to `A / nA`.

**Why promising:** Conceptually revolutionary and aligns with textbook mathematics.  
**Risk:** Heavier quotient/setoid engineering.  
**Use if:** resolution/cokernel route becomes awkward.

---

### Strategy C: Exactness via diagram chase in concrete module categories
For the long exact fragment, avoid full derived-category infrastructure and instead work directly with kernels, images, quotient maps, and lifts.

**Steps**
1. Package short exact sequences with explicit injective/surjective data.
2. Define the connecting morphism by lifting a map `M' → A` through a chosen free cover / pushout-style construction.
3. Prove exactness by `rcases`, `by_contra`, and multi-step `calc`, not by automation.

**Why promising:** It produces robust, understandable Lean code and satisfies the “deep proof tactics” requirement.

**Most promising overall:**  
- Use **Strategy A** for concrete computations (`Ext¹`, `Tor₁`)  
- Use **Strategy C** for the exactness theorem  
- Use **Strategy B** only if you want a more conceptually grand second layer

---

## Catalog Building Blocks to Use Explicitly

You are expected to build on:

- `Tor1_vanishes_for_free`
  in `Algebra/Homology/DerivedFunctors/UniversalCoefficient.lean`

Use it as:
- a consistency check for your `Tor₁ ≃ n`-torsion theorem,
- a corollary for free modules,
- and a bridge to the universal coefficient theorem.

You may also mine the spirit of:
- `norm_exact_sequence`
  from `Algebra/Other/MoonshotExplorations.lean`

not for direct reuse of content, but as a cue that exactness arguments have already been treated as first-class formal objects in the repository. Build a *real* exactness framework here, not a numerological analogue.

Do **not** waste time on unrelated catalog curiosities unless they genuinely help with a cross-domain theorem.

---

## Required Deep Theorem Count

Your Lean file must contain at least **3 nontrivial theorems** whose proofs genuinely use multi-step reasoning. Suitable candidates:

1. `ext1_Zmod_eq_quotient`
2. `tor1_Zmod_eq_torsion`
3. `hom_ext_exact_fragment`
4. `tor1_vanishes_iff_no_n_torsion`
5. `homology_with_coefficients_of_torsion_free_prev`
6. a concrete UCT split theorem for a bounded chain complex

At least 3 of these must use substantial tactics such as:
- induction
- `rcases`
- `by_contra`
- `field_simp` where relevant
- multi-step `calc`
- explicit kernel/image manipulations

No toy proofs. No theorem whose essence is `rfl`.

---

## Falsifiable Conjecture With Computational Test

You must state at least one computationally testable conjecture in `FUTURE_DIRECTIONS.md`. Here is a strong candidate:

### Conjecture: Smith-normal-form prediction for Tor/Ext
For every finitely presented abelian group
\[
A \cong \mathbb Z^r \oplus \bigoplus_i \mathbb Z/d_i\mathbb Z,
\]
the verified computation of `Tor₁(ℤ/nℤ, A)` and `Ext¹(ℤ/nℤ, A)` obtained from any Lean-certified presentation agrees canonically with the Smith normal form formula:
\[
\operatorname{Tor}_1(\mathbb Z/n\mathbb Z, A)
\cong \bigoplus_i \mathbb Z/\gcd(n,d_i)\mathbb Z,
\quad
\operatorname{Ext}^1(\mathbb Z/n\mathbb Z, A)
\cong A/nA.
\]

**Clear computational test:**  
Implement a procedure that:
1. takes a finite presentation matrix over `ℤ`,
2. computes its Smith normal form externally or via verified subroutines,
3. computes predicted Tor/Ext invariants,
4. compares with invariants extracted from your concrete resolution-based Lean definitions.

A counterexample would immediately falsify the conjecture or expose a bug in the formalization.

---

## Application Keywords

Include these explicitly in your documentation and framing:

- verified derived functors
- computational homological algebra
- universal coefficient theorem
- torsion detection
- exact sequence certification
- algebraic topology
- topological data analysis
- coding theory
- topological phases of matter
- Smith normal form
- finitely presented modules
- certified symbolic computation

---

## Deliverables (ALL MANDATORY)

You must produce **all** of the following:

1. **`FUTURE_DIRECTIONS.md`**  
   Include **3–5 testable scientific hypotheses**, each a falsifiable conjecture with:
   - precise statement,
   - what computation/test could refute it,
   - what success would imply.

2. **`RESEARCH_PAPER.md`**  
   A **standalone scientific paper** explaining:
   - the new definitions,
   - theorem statements,
   - proof ideas,
   - computational consequences,
   - why this opens a new line of work in formalized homological algebra.  
   Someone reading only this file must understand the discovery.

3. **`ARTICLE.md`**  
   Scientific American style. Explain derived functors, torsion, and universal coefficients as if unveiling a new scientific instrument for seeing hidden algebraic structure.

4. **A verified algorithm or computational method**  
   Not just theorem statements. At minimum:
   - an algorithm to compute `nTorsionSubgroup`,
   - or a certified routine for the `ℤ/nℤ` free resolution,
   - or a method computing concrete `Ext¹`/`Tor₁` invariants from presentations.

5. **`demo.py`**  
   Interactive demonstration:
   - input `n` and a finitely presented abelian group / small chain complex,
   - display predicted `Ext¹`, `Tor₁`, and UCT consequences,
   - compare examples such as `ℤ`, `ℤ/mℤ`, `ℤ ⊕ ℤ/6ℤ`, simple cellular chain complexes.

---

## Final Call to Action

Do not write a timid wrapper around existing abstractions. Build the concrete engine.

The right result here is not “we defined some symbols named Ext and Tor.”  
The right result is:

- a verified two-term resolution machine for `ℤ/nℤ`,
- explicit calculations of `Ext¹` and `Tor₁`,
- an exactness theorem that certifies connecting morphisms,
- and a universal coefficient framework that makes homology with coefficients computable and conceptually transparent.

If you succeed, you will have transformed Lean from a place where homological algebra is merely *stated* into a place where it is *computed, certified, and deployed across domains*.

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
