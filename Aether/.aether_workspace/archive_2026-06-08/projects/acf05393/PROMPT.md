## Assignment: Prove new, non-trivial theorems that push the current formal infrastructure from “Hilbert class field as an abstract certificate” toward genuine machine-checked class field theory. Build on catalog theorems. Minimize sorry.

# Research Direction
# Future Directions: Toward Formal Class Field Theory and Abelian Langlands

This cycle should not merely extend definitions. It should force a conceptual transition: from isolated algebraic-number-theoretic constructions to a formal reciprocity mechanism. The decisive target is to make the class group act as a computable Galois shadow, then leverage that shadow to formalize explicit class field generation and capitulation phenomena.

The strongest direction is to prove theorems that separate the **existence of the Artin map**, the **structure of its kernel**, and the **explicit generation of Hilbert class fields by CM invariants**. Those three pillars together form the minimal viable skeleton of formal abelian Langlands for number fields.

Application keywords: `class field theory`, `Artin reciprocity`, `Hilbert class field`, `capitulation`, `complex multiplication`, `abelian Langlands`, `Galois representations`, `ideal class groups`, `computational algebraic number theory`, `formal verification`

---

## 1. Artin Map Surjectivity in Finite Unramified Abelian Extensions

### Breakthrough target
Prove a formally precise surjectivity theorem for the unramified Artin map without assuming the full Hilbert class field isomorphism. This is the right theorem because it isolates the first genuinely arithmetic content of global reciprocity: **class groups control unramified abelian Galois groups**.

### Precise theorem statement
Let `K` be a number field and `L/K` a finite Galois extension that is abelian and everywhere unramified. Then there exists a canonical surjective group homomorphism
\[
\operatorname{Art}_{L/K} : \mathrm{Cl}(\mathcal O_K) \twoheadrightarrow \mathrm{Gal}(L/K),
\]
and therefore
\[
|\mathrm{Gal}(L/K)| \le |\mathrm{Cl}(\mathcal O_K)|.
\]

### Lean 4 formalization target
A plausible theorem signature, depending on the exact catalog API, is:

```lean
theorem exists_surjective_artinMap_of_unramified_abelian
    (K L : Type*) [Field K] [Field L]
    [NumberField K] [NumberField L]
    [Algebra K L] [FiniteDimensional K L]
    (hGal : Normal K L)
    (hSep : IsSeparable K L)
    (hAb : IsCommutative (L ≃ₐ[K] L) (· * ·))
    (hUnr : IsEverywhereUnramified K L) :
    ∃ φ : ClassGroup (integralClosure ℤ K) →* (L ≃ₐ[K] L),
      Function.Surjective φ := by
  sorry
```

and the cardinal inequality as:

```lean
theorem card_galoisGroup_le_card_classGroup_of_unramified_abelian
    (K L : Type*) [Field K] [Field L]
    [NumberField K] [NumberField L]
    [Algebra K L] [FiniteDimensional K L]
    [Fintype (L ≃ₐ[K] L)]
    [Fintype (ClassGroup (integralClosure ℤ K))]
    (hGal : Normal K L)
    (hSep : IsSeparable K L)
    (hAb : IsCommutative (L ≃ₐ[K] L) (· * ·))
    (hUnr : IsEverywhereUnramified K L) :
    Fintype.card (L ≃ₐ[K] L) ≤
      Fintype.card (ClassGroup (integralClosure ℤ K)) := by
  sorry
```

If the catalog already contains `IsHilbertClassField K L`, also prove the specialization:

```lean
theorem artinMap_surjective_of_isHilbertClassField
    (K L : Type*) [Field K] [Field L]
    [NumberField K] [NumberField L]
    [Algebra K L]
    (hHCF : IsHilbertClassField K L) :
    ∃ φ : ClassGroup (integralClosure ℤ K) →* (L ≃ₐ[K] L),
      Function.Surjective φ := by
  sorry
```

### Proof strategy architecture

#### Strategy A: Factor through existing `IsHilbertClassField` infrastructure
1. If the catalog already provides `artinIso` inside `IsHilbertClassField`, weaken it to a projection theorem: every `artinIso` yields a surjective homomorphism.
2. Abstract the surjective component into a new structure/theorem that does not require proving injectivity.
3. Derive the cardinal inequality from `Fintype.card_le_of_surjective`.

**Why promising:** minimal new arithmetic, maximal formal payoff. This is the fastest route if an isomorphism theorem is already encoded.

#### Strategy B: Construct the map from Frobenius on prime ideals
1. Define the map on nonzero prime ideals unramified in `L` by sending `𝔭` to `Frob_𝔭`.
2. Prove multiplicativity on ideals and descent to principal ideals using the unramified abelian hypothesis.
3. Descend to the class group and prove surjectivity via Chebotarev-style generation, or a weaker finite-generation argument if Chebotarev is unavailable.

**Why revolutionary:** this turns the formal development from “certificate-based class field theory” into actual reciprocity. It creates infrastructure reusable for ray class fields and decomposition laws.

#### Strategy C: Galois action on ideals and quotient universal property
1. Construct a monoid homomorphism from fractional ideals modulo principal ideals into the abelianized Galois group.
2. Use universal properties of quotient groups to descend.
3. Prove surjectivity from the statement that Frobenius classes generate the abelian Galois group in an unramified extension.

**Why promising:** structurally elegant and likely aligns well with Lean’s quotient APIs.

### Cross-domain connections
- **Abelian Langlands:** this is the global reciprocity map in its first tractable formal incarnation.
- **Arithmetic statistics:** cardinal inequalities suggest machine-verifiable constraints on unramified extension towers.
- **Certified computation:** once surjectivity is formal, one can certify that a computed extension exhausts all unramified abelian symmetry predicted by the class group.
- **Homological algebra:** the kernel is the first concrete instance of a reciprocity defect and foreshadows cohomological formulations of class field theory.

### Concrete test cases
Verify in small examples whenever the catalog supports them:
- `ℚ(√-5)`
- `ℚ(√-23)`
- genus fields of imaginary quadratic fields with small discriminant

### Why this is a breakthrough
A surjective Artin map is the first real theorem of class field theory, not merely a definitional repackaging. Formalizing it means Lean begins to prove reciprocity laws rather than only manipulate algebraic objects adjacent to them.

---

## 2. Imaginary Quadratic CM Generator Formalization

### Breakthrough target
Formalize the bridge from ideal classes to explicit field generators using CM `j`-invariants. This is the place where abstract class field theory becomes constructive. It is the formal shadow of Hilbert’s 12th problem in the only setting where the answer is known.

### Precise theorem statement
For an imaginary quadratic field `K = ℚ(√d)` with squarefree `d < 0`, let `H_D(X)` be the Hilbert class polynomial of discriminant `D`. Then:
1. `natDegree H_D = #ClassGroup (𝓞 K)`,
2. the splitting field `L` of `H_D` over `K` is a Hilbert class field of `K`,
3. hence there is an isomorphism
   \[
   \mathrm{Cl}(\mathcal O_K) \cong \mathrm{Gal}(L/K).
   \]

### Lean 4 formalization target
A first finite-discriminant theorem, suitable for explicit proof:

```lean
theorem natDegree_hilbertClassPolynomial_eq_classNumber
    (K : Type*) [Field K] [NumberField K]
    (hIQ : IsImaginaryQuadraticField K)
    (H : Polynomial K) -- placeholder for Hilbert class polynomial
    (hH : IsHilbertClassPolynomial K H) :
    H.natDegree = Fintype.card (ClassGroup (integralClosure ℤ K)) := by
  sorry
```

Splitting field realization:

```lean
theorem splittingField_isHilbertClassField_of_CM
    (K : Type*) [Field K] [NumberField K]
    (hIQ : IsImaginaryQuadraticField K)
    (H : Polynomial K)
    (hH : IsHilbertClassPolynomial K H)
    (L : Type*) [Field L] [Algebra K L]
    (hSplit : IsSplittingField K L H) :
    IsHilbertClassField K L := by
  sorry
```

For explicit discriminants:

```lean
theorem hilbertClassPolynomial_degree_D_neg4 :
    (hilbertClassPolynomial (-4)).natDegree =
      Fintype.card (ClassGroup (integralClosure ℤ (QuadraticField (-1)))) := by
  sorry
```

and similarly for `D = -8, -3, -7, -11`.

### Proof strategy architecture

#### Strategy A: Axiomatized Hilbert class polynomial interface
1. Introduce a structure `IsHilbertClassPolynomial K H` encapsulating the minimal arithmetic properties needed: roots are CM `j`-invariants, degree equals class number, splitting field unramified abelian.
2. Prove downstream consequences from that interface before attempting full analytic construction.
3. Instantiate the interface for explicit small discriminants via known closed forms.

**Why most promising:** it decouples deep complex-analytic construction from algebraic consequences and gives immediate formal leverage.

#### Strategy B: Orbit-stabilizer via class group action on CM elliptic curves
1. Formalize the action of `ClassGroup (𝓞 K)` on CM elliptic curves/lattices.
2. Show the orbit of `j(𝓞_K)` has cardinality equal to the class number.
3. Identify the minimal polynomial degree with orbit size and the splitting field with the Hilbert class field.

**Why visionary:** this connects algebraic number theory, moduli, and Galois actions. It is the true geometric heart of CM.

#### Strategy C: Explicit polynomial computation for Heegner discriminants
1. Hard-code or certify the known `H_D`.
2. Compute `natDegree`.
3. Match against class group cardinality from catalog theorems and verify splitting field axioms directly.

**Why useful:** gives immediate concrete wins and tests the architecture on finite examples.

### Cross-domain connections
- **Modular forms / elliptic curves:** CM values of modular functions generate class fields.
- **Explicit Langlands:** modular parameters realizing abelian Galois extensions are the prototypical automorphic-to-Galois bridge.
- **Computational complexity:** Hilbert class polynomial computation becomes certifiable.
- **Arithmetic geometry:** this is the first formal point where moduli spaces produce number fields.

### Why this is a breakthrough
Formal class field theory without explicit generators remains inert. CM turns reciprocity into a polynomial one can compute, split, and certify. This opens a path to verified algorithms for class fields and modular arithmetic.

---

## 3. Capitulation Kernel Detection

### Breakthrough target
Formalize the extension-of-ideals map on class groups and identify its kernel as a measurable arithmetic invariant. Capitulation is where class groups stop being static and begin interacting functorially across field extensions.

### Precise theorem statement
For a finite extension `L/K` of number fields, the extension-of-ideals map induces a group homomorphism
\[
\iota_{L/K} : \mathrm{Cl}(\mathcal O_K) \to \mathrm{Cl}(\mathcal O_L).
\]
Its kernel
\[
\mathrm{Cap}(L/K) := \ker(\iota_{L/K})
\]
is exactly the set of ideal classes of `K` that become principal in `L`. In the Hilbert class field case, the kernel is all of `ClassGroup (𝓞 K)`.

### Lean 4 formalization target

```lean
theorem classGroup_extensionMap_exists
    (K L : Type*) [Field K] [Field L]
    [NumberField K] [NumberField L]
    [Algebra K L] [FiniteDimensional K L] :
    ∃ φ : ClassGroup (integralClosure ℤ K) →*
          ClassGroup (integralClosure ℤ L), True := by
  sorry
```

Kernel identification:

```lean
theorem mem_classGroup_extensionMap_ker_iff_capitulates
    (K L : Type*) [Field K] [Field L]
    [NumberField K] [NumberField L]
    [Algebra K L] [FiniteDimensional K L]
    (φ : ClassGroup (integralClosure ℤ K) →*
         ClassGroup (integralClosure ℤ L))
    (c : ClassGroup (integralClosure ℤ K)) :
    c ∈ MonoidHom.ker φ ↔ CapitulatesIn K L c := by
  sorry
```

Hilbert class field total capitulation:

```lean
theorem ker_extensionMap_eq_top_of_isHilbertClassField
    (K L : Type*) [Field K] [Field L]
    [NumberField K] [NumberField L]
    [Algebra K L]
    (hHCF : IsHilbertClassField K L)
    (φ : ClassGroup (integralClosure ℤ K) →*
         ClassGroup (integralClosure ℤ L)) :
    MonoidHom.ker φ = ⊤ := by
  sorry
```

### Proof strategy architecture

#### Strategy A: Ideal extension descends to quotient
1. Define extension of nonzero fractional ideals along `𝓞 K → 𝓞 L`.
2. Show principal ideals map to principal ideals.
3. Descend to the quotient defining the class group.

**Why most promising:** purely algebraic and likely already partially supported by ideal transport lemmas in Mathlib.

#### Strategy B: Use universal property of quotient groups
1. Build the map on fractional ideals.
2. Prove compatibility with the subgroup of principal ideals.
3. Invoke quotient-lift machinery to obtain the class-group homomorphism.

#### Strategy C: Hilbert class field via principalization
1. Assuming `IsHilbertClassField`, show every ideal of `K` becomes principal in `L`.
2. Translate this directly to triviality of the extension map.
3. Infer that the kernel is all of `ClassGroup (𝓞 K)`.

### Cross-domain connections
- **Transfer maps in algebraic topology:** capitulation behaves like a vanishing phenomenon after base change.
- **Galois cohomology:** the capitulation kernel is the first visible shadow of `H¹`/transfer phenomena.
- **Iwasawa theory:** understanding kernels under extension is the seed of growth laws in towers.

### Why this is a breakthrough
Capitulation is not a side phenomenon; it is the mechanism by which ideal classes are annihilated by passage to larger arithmetic universes. Formalizing it opens the road to principalization theorems, transfer maps, and eventually class group growth in towers.

---

## 4. Degree Equality for Hilbert Class Fields

### Breakthrough target
Remove the gap between “`L` is declared a Hilbert class field” and the decisive arithmetic equality
\[
[L:K] = h_K.
\]
This is the numerical spine of the theory.

### Precise theorem statement
If `L/K` is a Hilbert class field of `K`, then
\[
\mathrm{finrank}_K L = \# \mathrm{Cl}(\mathcal O_K).
\]

### Lean 4 type signature

```lean
theorem finrank_hilbertClassField_eq_classNumber
    (K L : Type*) [Field K] [Field L]
    [NumberField K] [NumberField L]
    [Algebra K L] [FiniteDimensional K L]
    [Fintype (ClassGroup (integralClosure ℤ K))]
    (hHCF : IsHilbertClassField K L) :
    FiniteDimensional.finrank K L =
      Fintype.card (ClassGroup (integralClosure ℤ K)) := by
  sorry
```

### Proof strategy architecture
1. Extract `artinIso` from `hHCF`.
2. Convert cardinality of `L ≃ₐ[K] L` to `finrank K L` using finite Galois extension infrastructure.
3. rewrite through the isomorphism to the class group.

Alternative route:
1. Prove `Fintype.card (L ≃ₐ[K] L) = finrank K L` under Galois assumptions.
2. Combine with the class group isomorphism.
3. Normalize coercions and cardinality casts carefully.

### Cross-domain connections
- **Field arithmetic:** converts abstract Galois symmetry into vector-space dimension.
- **Certified algebra systems:** allows exact degree certification of computed class fields.
- **Representation theory:** degree/cardinality equalities are the first place where arithmetic symmetry counts become formally computable invariants.

### Why this is a breakthrough
It turns the abstract reciprocity statement into a quantitative theorem. Once degree equals class number is formal, one can certify that an explicitly generated field is not merely unramified abelian, but exactly the Hilbert class field.

---

## 5. Functoriality Toward Abelian Langlands

### Breakthrough target
Prove that the Artin map is functorial with respect to towers of unramified abelian extensions. This is the first true “Langlands-style” structural theorem in the formal system.

### Precise theorem statement
For number fields `K ⊆ M ⊆ L` with `L/K` and `M/K` finite, Galois, abelian, and everywhere unramified, the Artin maps commute with restriction:
\[
\mathrm{res}_{L/M} \circ \operatorname{Art}_{L/K}
=
\operatorname{Art}_{M/K}.
\]
Equivalently, the reciprocity map is natural in the extension.

### Lean 4 type signature

```lean
theorem artinMap_functorial_in_tower
    (K M L : Type*) [Field K] [Field M] [Field L]
    [NumberField K] [NumberField M] [NumberField L]
    [Algebra K M] [Algebra M L] [Algebra K L]
    [IsScalarTower K M L]
    [FiniteDimensional K M] [FiniteDimensional M L] [FiniteDimensional K L]
    (φKM : ClassGroup (integralClosure ℤ K) →* (M ≃ₐ[K] M))
    (φKL : ClassGroup (integralClosure ℤ K) →* (L ≃ₐ[K] L))
    (hfun : ∀ c,
      AlgEquiv.restrictNormalHom M (φKL c) = φKM c) :
    True := by
  sorry
```

A stronger final form should replace the placeholder `True` by the exact equality of homomorphisms once the restriction map API is settled.

### Proof strategy architecture

#### Strategy A: Frobenius compatibility in towers
1. Prove restriction of Frobenius at `L/K` equals Frobenius at `M/K`.
2. Descend from prime ideals to class groups.
3. ext on ideal classes.

#### Strategy B: Transport through Hilbert class field isomorphisms
1. Use class-group/Galois-group identifications for both `M` and `L`.
2. Show naturality by uniqueness of the induced map from ideal classes.
3. Reduce to commutativity of restriction on Galois automorphisms.

#### Strategy C: Categorical packaging
1. Define a category of unramified abelian extensions of `K`.
2. Show the Artin map is a natural transformation from class-group-valued data to Galois-group-valued data.
3. Extract tower functoriality as a component theorem.

### Cross-domain connections
- **Category theory:** reciprocity as naturality rather than isolated bijections.
- **Langlands philosophy:** functoriality is the central organizing principle.
- **Computer formalization:** naturality theorems are exactly what make later automation possible.

### Why this is a breakthrough
A single surjective Artin map is a theorem. Functoriality is a theory. This is the moment formal class field theory begins to behave like a coherent mathematical machine rather than a bag of lemmas.

---

## Implementation priorities

1. **First priority:** prove the surjective Artin map theorem in the weakest assumptions your current catalog permits.
2. **Second priority:** define the extension-of-ideals map on class groups and characterize the capitulation kernel.
3. **Third priority:** isolate an interface for Hilbert class polynomials and prove explicit low-discriminant instances.
4. **Fourth priority:** package cardinality/degree equalities cleanly so they can be reused without theorem duplication.
5. **Fifth priority:** state and prove at least one tower-functoriality lemma, even if initially only under `IsHilbertClassField` assumptions.

---

## Deliverables

1. Lean files with theorems above, minimizing sorry.
2. A short note documenting exactly which catalog theorems were used as building blocks, and how.
3. Explicit comments near each theorem explaining whether it is:
   - a direct consequence of catalog infrastructure,
   - a new formal arithmetic construction,
   - or a temporary axiomatic interface awaiting deeper formalization.
4. A structured `FUTURE_DIRECTIONS.md` containing **3–5 falsifiable scientific hypotheses**, each with:
   - a precise conjecture,
   - a concrete formal test in Lean,
   - a criterion for success/failure.

---

## Required FUTURE_DIRECTIONS hypotheses
Your `FUTURE_DIRECTIONS.md` must include 3–5 testable hypotheses of the following flavor:

1. **Ray class precursor hypothesis**  
   Conjecture that the surjective Artin map extends from ordinary class groups to ray class groups modulo a finite modulus `𝔪`, with codomain the Galois group of the maximal abelian extension unramified outside `𝔪`.  
   **Test:** formalize a ray-class-group surrogate and prove the analogue for one explicit modulus over an imaginary quadratic field.

2. **Capitulation detection hypothesis**  
   Conjecture that for cyclic unramified extensions `L/K`, the capitulation kernel equals the subgroup of `ClassGroup (𝓞 K)` fixed by an explicitly definable transfer operator.  
   **Test:** define the transfer map and compare kernels in one finite example.

3. **CM generation hypothesis**  
   Conjecture that for each Heegner discriminant, the splitting field of the certified Hilbert class polynomial is formally provable to satisfy `IsHilbertClassField`.  
   **Test:** complete all cases `D ∈ {-3,-4,-7,-8,-11,-19,-43,-67,-163}` that current infrastructure can support.

4. **Functoriality hypothesis**  
   Conjecture that Artin maps in towers of unramified abelian extensions form a natural transformation.  
   **Test:** prove commutativity for one nontrivial tower `K ⊆ M ⊆ L`.

5. **Abelian Langlands shadow hypothesis**  
   Conjecture that one can formalize a bijection between finite-order Hecke characters of `K` unramified everywhere and characters of `ClassGroup (𝓞 K)`.  
   **Test:** define both sides in a restricted finite setting and prove the correspondence for imaginary quadratic `K` with small class number.

The aim is not to tidy up known infrastructure. The aim is to force Lean to witness the first living layer of reciprocity.

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

Research domain: Speculative
Research mode: prove
