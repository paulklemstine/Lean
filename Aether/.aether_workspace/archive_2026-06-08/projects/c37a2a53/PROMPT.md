            ## Assignment: This document identifies five specific, testable scientific hypotheses that buil

            Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

            ### Research Direction
            # Future Directions: Toward Formal Class Field Theory and Abelian Langlands

This document identifies five specific, testable scientific hypotheses that build directly on the formal infrastructure established in this work. Each conjecture is falsifiable and comes with a concrete test that can be carried out in subsequent research cycles.

---

## 1. Artin Map Surjectivity in Finite Unramified Abelian Extensions

**Conjecture**: For every number field `K` and every finite extension `L/K` that is Galois, abelian, and everywhere unramified, there exists a canonical surjective group homomorphism from `ClassGroup (𝓞 K)` onto `Gal(L/K)`, whose kernel corresponds to the ideal classes that capitulate in `L`.

**Test**: Starting from our `IsHilbertClassField` structure, weaken the axiom `artinIso` to require only a surjective homomorphism `ClassGroup (𝓞 K) →* (L ≃ₐ[K] L)`. Define the capitulation kernel as the set of classes that map to the identity. Prove that `Fintype.card (L ≃ₐ[K] L) ≤ Fintype.card (ClassGroup (𝓞 K))` for unramified abelian extensions (without the full isomorphism axiom). Verify in explicit cases: ℚ(√-5)/ℚ and the genus field of ℚ(√-23).

**Impact**: This would formalize the Artin reciprocity map in the unramified setting, providing the first machine-verified statement of class field theory beyond the abelian-over-ℚ case. It would enable formal proofs about the structure of unramified abelian extensions and open the door to ray class field theory.

---

## 2. Imaginary Quadratic CM Generator Formalization

**Conjecture**: For an imaginary quadratic field `K = ℚ(√d)` with `d < 0` squarefree, the minimal polynomial of any CM j-invariant `j(𝓞_K)` has degree exactly `Fintype.card (ClassGroup (𝓞 K))`, and the splitting field of this polynomial over `K` is an `IsHilbertClassField K L`.

**Test**: 
1. Define the Hilbert class polynomial `H_D(x)` as a formal object in Lean (initially as an axiomatized polynomial of specified degree).
2. Prove `natDegree H_D = Fintype.card (ClassGroup (𝓞 K))` for the five discriminants D = -4, -8, -3, -7, -11 where explicit formulas are known.
3. Verify that the splitting field satisfies all axioms of `IsHilbertClassField`.

**Impact**: This would be the first formal verification connecting class field theory to complex multiplication and modular functions. It directly addresses Hilbert's 12th problem in the one setting where the answer is classically known, creating a template for formal CM theory.

---

## 3. Capitulation Kernel Detection

**Conjecture**: For a finite Galois extension `L/K` of number fields, the extension-of-ideals map `ClassGroup (𝓞 K) → ClassGroup (𝓞 L)` is well-defined as a group homomorphism, and its kernel (the "capitulation kernel") is trivial whenever `L/K` is unramified, abelian, and linearly disjoint from the Hilbert class field of `K` over `K`.

**Test**: 
1. Define the capitulation map formally: for `I : Ideal (𝓞 K)`, send it to the class of `Ideal.map (algebraMap (𝓞 K) (𝓞 L)) I` in `ClassGroup (𝓞 L)`.
2. Prove this is a well-defined group homomorphism.
3. In the special case where `L` is the Hilbert class field itself, prove the kernel equals the entire class group (principal capitulation theorem).
4. Test triviality of the kernel for ℚ(√-5, √-1)/ℚ(√-5) computationally.

**Impact**: The capitulation map is the key homological invariant in class field theory. Formalizing it would enable statements about genus theory, Iwasawa theory, and the behavior of ideal classes under field extensions — all prerequisites for deeper arithmetic applications.

---

## 4. Abelian Langlands Shadow Theorem

**Conjecture**: Given `IsHilbertClassField K L`, the function `classGroup_character_to_galois_character` (defined in our formalization) is a bijection between characters `ClassGroup (𝓞 K) →* ℂˣ` and characters `(L ≃ₐ[K] L) →* ℂˣ`. Moreover, this bijection preserves L-functions: the Hecke L-function attached to a class group character equals the Artin L-function of the corresponding Galois character.

**Test**: 
1. Prove that `classGroup_character_to_galois_character` is injective (follows from the Artin iso being an isomorphism).
2. Prove surjectivity by constructing the inverse map.
3. For the simpler claim (without L-functions): show the set of characters has the same cardinality on both sides.
4. For L-function equality: define formal Dirichlet series and prove the Euler product identity for unramified primes in the quadratic case.

**Impact**: This would be the first formally verified instance of the Langlands correspondence, even in its simplest form. The character bijection is the abelian case of the local-global compatibility that underlies the entire Langlands program. Formalizing even the unramified case would create infrastructure for automorphic forms and Galois representations.

---

## 5. Class Number as Arithmetic Complexity Measure

**Conjecture**: For the ring of integers `𝓞_K` of a number field `K`, the minimum number of generators needed for any ideal `I ⊆ 𝓞_K` is bounded by `max(2, ω(Fintype.card (ClassGroup (𝓞 K))))` where `ω` is the number of distinct prime factors. In particular, every ideal in a Dedekind domain is 2-generated, and the class group controls the "difficulty" of finding these generators.

**Test**: 
1. Formalize the 2-generator theorem for Dedekind domains: every nonzero ideal `I` in a Dedekind domain can be written as `I = Ideal.span {a, b}` for suitable `a, b`.
2. Prove that when `Subsingleton (ClassGroup R)`, every ideal is 1-generated (this follows from our existing theorem).
3. Implement certified ideal arithmetic for ℤ[√-5] and measure proof-term sizes for ideal factorization as a function of the class number.
4. Compare computational complexity of ideal operations across number fields with different class numbers.

**Impact**: This connects formal algebraic number theory to computational complexity and certified algorithms. The 2-generator theorem is a classical result that should be formalizable with current Mathlib infrastructure, and it has direct applications to computational algebra systems that need verified ideal arithmetic.

---

## Cross-Cutting Theme

All five directions share a common structure: they extend the **quotient-first algebraic infrastructure** established in this work (class group as quotient → principality characterization → axiomatic Hilbert class field → character correspondence) toward deeper arithmetic content. The progression is:

1. **Structure** (capitulation map, Artin map) — Directions 1, 3
2. **Instantiation** (CM theory, explicit generators) — Direction 2
3. **Correspondence** (Langlands, characters) — Direction 4
4. **Computation** (certified algorithms, complexity) — Direction 5

Each direction is independently valuable and can be pursued in parallel, but together they form a coherent program toward formal class field theory and the abelian Langlands correspondence.


            ### Mathematical Framing
            # Future Directions: Toward Formal Class Field Theory and Abelian Langlands

This document identifies five specific, testable scientific hypotheses that build directly on the formal infrastructure established in this work. Each conjecture is falsifiable and comes with a concrete test that can be carried out in subsequent research cycles.

---

## 1. Artin Map Surjectivity in Finite Unramified Abelian Extensions

**Conjecture**: For every number field `K` and every finite extension `L/K` that is Galois, abelian, and everywhere unramified, there exists a canonical surjective group homomorphism from `ClassGroup (𝓞 K)` onto `Gal(L/K)`, whose kernel corresponds to the ideal classes that capitulate in `L`.

**Test**: Starting from our `IsHilbertClassField` structure, weaken the axiom `artinIso` to require only a surjective homomorphism `ClassGroup (𝓞 K) →* (L ≃ₐ[K] L)`. Define the capitulation kernel as the set of classes that map to the identity. Prove that `Fintype.card (L ≃ₐ[K] L) ≤ Fintype.card (ClassGroup (𝓞 K))` for unramified abelian extensions (without the full isomorphism axiom). Verify in explicit cases: ℚ(√-5)/ℚ and the genus field of ℚ(√-23).

**Impact**: This would formalize the Artin reciprocity map in the unramified setting, providing the first machine-verified statement of class field theory beyond the abelian-over-ℚ case. It would enable formal proofs about the structure of unramified abelian extensions and open the door to ray class field theory.

---

## 2. Imaginary Quadratic CM Generator Formalization

**Conjecture**: For an imaginary quadratic field `K = ℚ(√d)` with `d < 0` squarefree, the minimal polynomial of any CM j-invariant `j(𝓞_K)` has degree exactly `Fintype.card (ClassGroup (𝓞 K))`, and the splitting field of this polynomial over `K` is an `IsHilbertClassField K L`.

**Test**: 
1. Define the Hilbert class polynomial `H_D(x)` as a formal object in Lean (initially as an axiomatized polynomial of specified degree).
2. Prove `natDegree H_D = Fintype.card (ClassGroup (𝓞 K))` for the five discriminants D = -4, -8, -3, -7, -11 where explicit formulas are known.
3. Verify that the splitting field satisfies all axioms of `IsHilbertClassField`.

**Impact**: This would be the first formal verification connecting class field theory to complex multiplication and modular functions. It directly addresses Hilbert's 12th problem in the one setting where the answer is classically known, creating a template for formal CM theory.

---

## 3. Capitulation Kernel Detection

**Conjecture**: For a finite Galois extension `L/K` of number fields, the extension-of-ideals map `ClassGroup (𝓞 K) → ClassGroup (𝓞 L)` is well-defined as a group homomorphism, and its kernel (the "capitulation kernel") is trivial whenever `L/K` is unramified, abelian, and linearly disjoint from the Hilbert class field of `K` over `K`.

**Test**: 
1. Define the capitulation map formally: for `I : Ideal (𝓞 K)`, send it to the class of `Ideal.map (algebraMap (𝓞 K) (𝓞 L)) I` in `ClassGroup (𝓞 L)`.
2. Prove this is a well-defined group homomorphism.
3. In the special case where `L` is the Hilbert class field itself, prove the kernel equals the entire class group (principal capitulation theorem).
4. Test triviality of the kernel for ℚ(√-5, √-1)/ℚ(√-5) computationally.

**Impact**: The capitulation map is the key homological invariant in class field theory. Formalizing it would enable statements about genus theory, Iwasawa theory, and the behavior of ideal classes under field extensions — all prerequisites for deeper arithmetic applications.

---

## 4. Abelian Langlands Shadow Theorem

**Conjecture**: Given `IsHilbertClassField K L`, the function `classGroup_character_to_galois_character` (defined in our formalization) is a bijection between characters `ClassGroup (𝓞 K) →* ℂˣ` and characters `(L ≃ₐ[K] L) →* ℂˣ`. Moreover, this bijection preserves L-functions: the Hecke L-function attached to a class group character equals the Artin L-function of the corresponding Galois character.

**Test**: 
1. Prove that `classGroup_character_to_galois_character` is injective (follows from the Artin iso being an isomorphism).
2. Prove surjectivity by constructing the inverse map.
3. For the simpler claim (without L-functions): show the set of characters has the same cardinality on both sides.
4. For L-function equality: define formal Dirichlet series and prove the Euler product identity for unramified primes in the quadratic case.

**Impact**: This would be the first formally verified instance of the Langlands correspondence, even in its simplest form. The character bijection is the abelian case of the local-global compatibility that underlies the entire Langlands program. Formalizing even the unramified case would create infrastructure for automorphic forms and Galois representations.

---

## 5. Class Number as Arithmetic Complexity Measure

**Conjecture**: For the ring of integers `𝓞_K` of a number field `K`, the minimum number of generators needed for any ideal `I ⊆ 𝓞_K` is bounded by `max(2, ω(Fintype.card (ClassGroup (𝓞 K))))` where `ω` is the number of distinct prime factors. In particular, every ideal in a Dedekind domain is 2-generated, and the class group controls the "difficulty" of finding these generators.

**Test**: 
1. Formalize the 2-generator theorem for Dedekind domains: every nonzero ideal `I` in a Dedekind domain can be written as `I = Ideal.span {a, b}` for suitable `a, b`.
2. Prove that when `Subsingleton (ClassGroup R)`, every ideal is 1-generated (this follows from our existing theorem).
3. Implement certified ideal arithmetic for ℤ[√-5] and measure proof-term sizes for ideal factorization as a function of the class number.
4. Compare computational complexity of ideal operations across number fields with different class numbers.

**Impact**: This connects formal algebraic number theory to computational complexity and certified algorithms. The 2-generator theorem is a classical result that should be formalizable with current Mathlib infrastructure, and it has direct applications to computational algebra systems that need verified ideal arithmetic.

---

## Cross-Cutting Theme

All five directions share a common structure: they extend the **quotient-first algebraic infrastructure** established in this work (class group as quotient → principality characterization → axiomatic Hilbert class field → character correspondence) toward deeper arithmetic content. The progression is:

1. **Structure** (capitulation map, Artin map) — Directions 1, 3
2. **Instantiation** (CM theory, explicit generators) — Direction 2
3. **Correspondence** (Langlands, characters) — Direction 4
4. **Computation** (certified algorithms, complexity) — Direction 5

Each direction is independently valuable and can be pursued in parallel, but together they form a coherent program toward formal class field theory and the abelian Langlands correspondence.



            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `all_nonzero_ideals_principal_of_classGroup_trivial` : theorem all_nonzero_ideals_principal_of_classGroup_trivial
     (file: Algebra/ClassField/HilbertClassFieldBasic.lean)
  2. `all_nonzero_ideals_principal_of_classGroup_trivial` : theorem all_nonzero_ideals_principal_of_classGroup_trivial
     (file: Algebra/ClassField/IdealClassGroupBridge.lean)
  3. `all_nonzero_ideals_principal_of_classGroup_trivial` : theorem all_nonzero_ideals_principal_of_classGroup_trivial
     (file: FINAL/Algebra/HilbertClassFieldBasic.lean)
  4. `all_nonzero_ideals_principal_of_classGroup_trivial` : theorem all_nonzero_ideals_principal_of_classGroup_trivial
     (file: FINAL/Algebra/IdealClassGroupBridge.lean)
  5. `exists_nonzero_poly_vanishing_on_finite_set_of_card_lt` : theorem exists_nonzero_poly_vanishing_on_finite_set_of_card_lt
     (file: Algebra/FiniteFieldPolynomialMethod/EvalKernel.lean)

### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


No specific files referenced. Use Mathlib and general knowledge.

            ---

            You are Aristotle. Pursue this research direction deeply and originally.
            Discover what matters. Prove what you can. Define what needs defining.
            Build on the catalog theorems referenced above.

            Use concrete types (Nat, Real, Finset, Matrix). Avoid trivial tautologies.
            If a direct proof fails, try the contrapositive, a constructive witness,
            or structural induction. Connect to at least one other domain for impact.

            ### Team Directive
            Create a team to conduct research, brainstorm testable hypotheses,
            run experiments to confirm or refute them, validate data,
            update knowledge base and iterate forever.

            Required: Lean 4 proofs, FUTURE_DIRECTIONS.md
            Optional: ARTICLE.md, RESEARCH_PAPER.md, demo.py

            FUTURE_DIRECTIONS.md is critical — it drives the next research cycle.
            Each direction must be a testable scientific hypothesis: a precise,
            falsifiable conjecture with a clear test that could confirm or refute it.
            Format each as:

            ### [Direction Title]
            **Conjecture**: A precise mathematical statement that can be proved or disproved.
            **Test**: What specific experiment, calculation, or proof attempt would
            confirm or refute this conjecture.
            **Impact**: If true, what new territory does this open? If false, what
            does the failure teach us?
            **Cross-domain**: Which other domains could this connect to?

            Do real science. Propose hypotheses that are bold enough to matter and
            specific enough to fail. Vague explorations like "study X further" or
            "extend Y" are not hypotheses — they are homework. Give us ideas that
            could change how we think about the problem.


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
