## Assignment: Galois group = S₅

**Mode:** `prove`

Prove a genuinely new theorem certifying that a concrete quintic over `ℚ` has full Galois group `S₅`, and do it in a way that opens a reusable formal pipeline for future Galois-group computations in Lean 4.

The target is not merely one isolated computation. The breakthrough is to formalize the **arithmetic-to-permutation-group bridge**:
1. factorization modulo primes gives cycle data,
2. discriminant parity detects containment in `Aₙ`,
3. finite group classification at small degree upgrades these arithmetic witnesses to an exact Galois group.

This is the seed of a formally verified “Dedekind–Frobenius–discriminant engine” for explicit inverse Galois computations.

---

## Precise theorem target

Let  
\[
f(X) := X^5 - X - 1 \in \mathbb{Z}[X].
\]

You should prove that the Galois group of `f` over `ℚ` is isomorphic to `Equiv.Perm (Fin 5)`.

A mathematically precise target is:

\[
\operatorname{Gal}(f/\mathbb{Q}) \cong S_5.
\]

If Mathlib’s current Galois-group API makes this exact formulation awkward, an acceptable first formal target is to prove that the natural permutation action of the Galois group on the five roots has image equal to `⊤` inside `Equiv.Perm (Fin 5)`, or equivalently that the associated permutation subgroup is all of `S₅`.

### Lean 4 type-signature targets

You may need to adapt to the exact Mathlib names, but aim for something of this shape:

```lean
def quinticS5 : Polynomial ℤ := X^5 - X - 1

theorem quinticS5_irreducible_over_Q :
  Irreducible (quinticS5.map (Int.castRingHom ℚ))

theorem quinticS5_disc :
  Polynomial.disc quinticS5 = 2869

theorem quinticS5_disc_not_square :
  ¬ IsSquare (Polynomial.disc quinticS5 : ℤ)

theorem quinticS5_galoisGroup_eq_top :
  let f : Polynomial ℚ := quinticS5.map (Int.castRingHom ℚ)
  let K := SplittingField f
  let G := Polynomial.Gal f
  -- permutation realization of G on the roots of f
  associatedRootPermutationSubgroup f = ⊤

theorem quinticS5_galoisGroup_isomorphic_S5 :
  let f : Polynomial ℚ := quinticS5.map (Int.castRingHom ℚ)
  Nonempty ((Polynomial.Gal f) ≃* Equiv.Perm (Fin 5))
```

If the exact object `Polynomial.Gal f` or “associatedRootPermutationSubgroup” differs, do not weaken the mathematics—formalize the strongest available equivalent statement.

---

## Exact theorem statement with quantifier structure

A robust final theorem would read:

> **Theorem.** Let `f = X^5 - X - 1 ∈ ℚ[X]`. Then:
> 1. `f` is irreducible over `ℚ`;
> 2. the discriminant of `f` is `2869`, hence not a square in `ℚ`;
> 3. the image of the Galois action on the roots of `f` is a transitive subgroup of `S₅` containing a 5-cycle and not contained in `A₅`;
> 4. therefore this image is all of `S₅`.

Even better, isolate the group-theoretic core as a reusable lemma:

```lean
theorem subgroup_eq_top_of_transitive_contains_fiveCycle_not_le_alternating
  (H : Subgroup (Equiv.Perm (Fin 5)))
  (htrans : MulAction.IsPretransitive H (Fin 5))
  (h5 : ∃ σ : H, IsCycle (σ : Equiv.Perm (Fin 5)) ∧ orderOf (σ : Equiv.Perm (Fin 5)) = 5)
  (hnotA5 : ¬ H ≤ Equiv.Perm.alternatingSubgroup (Fin 5)) :
  H = ⊤
```

This lemma is small-degree finite group theory in executable form. Once you have it, many explicit quintic Galois computations collapse to arithmetic certificates.

---

## Core mathematical blueprint

### Arithmetic input
Use the polynomial
\[
f(X)=X^5-X-1.
\]

Two-step argument:

- **5-cycle witness:** Reduce `f` modulo `2`. If it remains irreducible in `𝔽₂[X]`, then the Frobenius at `2` acts as a 5-cycle on the roots.
- **Odd permutation witness:** Compute the discriminant
  \[
  \operatorname{Disc}(f)=2869=19\cdot151,
  \]
  which is not a square. Therefore the Galois group is not contained in `A₅`.
- **Classification step:** A transitive subgroup of `S₅` containing a 5-cycle and not contained in `A₅` must be `S₅`.

This is the right theorem because it is the first nontrivial degree where arithmetic, finite group theory, and formal algebraic number theory all interact in a way that cannot be faked by brute-force root formulas.

---

## Proof strategies

### Strategy A: Minimal-friction permutation-subgroup route
This is likely the most promising.

1. **Irreducibility over `ℚ` and mod `2`.**
   - Show `X^5 - X - 1` is irreducible over `𝔽₂`.
   - Deduce irreducibility over `ℚ` using Gauss/Eisenstein-style transfer or direct rational root + degree-2/3 obstruction if needed.
   - Irreducibility over `ℚ` gives transitivity of the Galois action on roots.

2. **Discriminant and alternating subgroup.**
   - Compute `Polynomial.disc (X^5 - X - 1) = 2869`.
   - Prove `¬ IsSquare (2869 : ℤ)`.
   - Formalize the standard theorem: for a separable degree-`n` polynomial over a field of characteristic `≠ 2`, the Galois group acting on roots is contained in `Aₙ` iff the discriminant is a square.
   - Deduce the image is not contained in `A₅`.

3. **Finite group classification in degree 5.**
   - Prove a reusable lemma classifying transitive subgroups of `S₅` with a 5-cycle.
   - Exclude `C₅`, `D₅`, and the Frobenius group `GA(1,5)` because each lies in `A₅` or has constrained parity structure; then conclude `S₅`.
   - If needed, prove by explicit subgroup enumeration up to conjugacy in `S₅`.

**Why this is best:** it avoids having to formalize the full Frobenius machinery immediately. You can encode “contains a 5-cycle” through factorization behavior mod `2` plus a bespoke lemma, or even prove the existence of an order-5 permutation in the root action more directly.

---

### Strategy B: Dedekind/Frobenius formalization route
This is more ambitious and more revolutionary.

1. **Formalize a local-global theorem.**
   - For monic `f ∈ ℤ[X]`, prime `p` not dividing the discriminant, and factorization
     \[
     \bar f = \prod_i g_i
     \]
     over `𝔽_p`, the Frobenius permutation on roots in the splitting field has cycle type given by the tuple of degrees `deg g_i`.

2. **Apply to `p = 2`.**
   - Since `f mod 2` is irreducible of degree 5, the Frobenius has cycle type `(5)`, hence is a 5-cycle.

3. **Combine with discriminant parity and subgroup classification.**
   - Same endgame as Strategy A.

**Why this matters:** this is the beginning of a certified implementation of Dedekind’s theorem in Lean. It would be far bigger than this one quintic: it would unlock a practical path toward machine-verified Galois group recognition.

---

### Strategy C: Resolvent/group-enumeration route
Potentially useful if discriminant-to-sign infrastructure is missing.

1. **Show transitivity from irreducibility.**
2. **Construct explicit subgroup exclusions.**
   - Enumerate the transitive subgroups of `S₅`.
   - Use mod-2 irreducibility to force a 5-cycle.
   - Use another modular factorization, e.g. mod `3`, `5`, `7`, etc., to witness another cycle type excluding all proper transitive candidates.
3. **Conclude `S₅` without invoking the discriminant-square criterion.**

For example, if you can find a prime where the factorization pattern gives a transposition or a 2-cycle/3-cycle combination, then proper candidates collapse quickly.

**Why this is useful:** it gives a fallback if the discriminant–alternating theorem is too expensive to formalize right now. It also produces a template for computational Galois group certification by modular signatures alone.

---

## Key intermediate lemmas to isolate

You should aim to prove reusable infrastructure, not only the final theorem.

### 1. Irreducibility mod 2
```lean
theorem quinticS5_mod2_irreducible :
  Irreducible (Polynomial.map (Int.castRingHom (ZMod 2)) quinticS5)
```

For `𝔽₂`, this should be feasible by direct finite check:
- no linear factor (`f 0 ≠ 0`, `f 1 ≠ 0`);
- no irreducible quadratic factor;
- no irreducible cubic factor.

Since degree is 5, that suffices.

### 2. Discriminant computation
```lean
theorem disc_X5_sub_X_sub_one :
  Polynomial.disc quinticS5 = 2869
```

If the generic quintic discriminant formula is unavailable, compute via:
- resultant formula `disc(f) = (-1)^(n(n-1)/2) * leadingCoeff⁻¹ * res(f, f')`,
- here `f' = 5X^4 - 1`,
- reduce to an explicit integer resultant calculation.

### 3. Discriminant square criterion
```lean
theorem gal_le_alternating_iff_disc_isSquare
  {K : Type*} [Field K] [CharZero K]
  (f : Polynomial K)
  (hsep : f.Separable)
  (hsplit : ...) :
  rootPermutationSubgroup f ≤ Equiv.Perm.alternatingSubgroup _ ↔
  IsSquare (Polynomial.disc f)
```

Even a specialized degree-5 version is already valuable.

### 4. Group-theoretic classification lemma
```lean
theorem transitive_subgroup_S5_eq_top_of_contains_5cycle_and_not_le_A5
  (H : Subgroup (Equiv.Perm (Fin 5)))
  (htrans : ...)
  (h5 : ∃ σ : H, orderOf (σ : Equiv.Perm (Fin 5)) = 5)
  (hnot : ¬ H ≤ Equiv.Perm.alternatingSubgroup (Fin 5)) :
  H = ⊤
```

This should become a reusable certification lemma for quintic Galois groups.

---

## Mathlib building blocks and how to use them

The listed catalog theorems are not directly about Galois theory, so do not force them artificially. The right move is to build on Mathlib’s algebra stack itself. In particular:

- `Polynomial.Irreducible`:
  use for irreducibility over `ℚ` and finite fields.
- `Polynomial.card_filter_roots_le`:
  useful in finite-field arguments to bound the number of roots and rule out repeated factors or impossible splittings.
- `Polynomial.roots`, `Finset.card`:
  useful for turning separability + degree 5 into “exactly 5 distinct roots in the splitting field.”
- `polynomial_eq_zero_of_natDegree_lt_and_eval_eq_zero_on_finset`:
  potentially useful in proving uniqueness of factorization witnesses over small finite fields by evaluation on all field elements.
- Standard Mathlib machinery around:
  - `Polynomial.map`,
  - `Polynomial.natDegree`,
  - `Polynomial.derivative`,
  - `Polynomial.disc`,
  - `SplittingField`,
  - automorphism groups and permutation actions.

If there is already a discriminant API in Mathlib, exploit it aggressively; if not, formalize the minimum resultant-based interface needed for this theorem and no more.

---

## Concrete technical subgoals

1. Define
   ```lean
   def fZ : Polynomial ℤ := X^5 - X - 1
   def fQ : Polynomial ℚ := fZ.map (Int.castRingHom ℚ)
   ```

2. Prove:
   - `fQ.Monic`
   - `natDegree fQ = 5`
   - `Separable fQ` (automatic in characteristic zero)
   - `Irreducible fQ`

3. Over `ZMod 2`, prove irreducibility of `fZ mod 2`.

4. Compute discriminant exactly.

5. Prove `¬ IsSquare (2869 : ℤ)`:
   - either by prime factorization `2869 = 19 * 151`,
   - or by inequalities showing no square lies between `53^2 = 2809` and `54^2 = 2916`.

6. Connect non-square discriminant to `¬ G ≤ A₅`.

7. Prove the finite group lemma upgrading the two witnesses to `S₅`.

8. Package the final theorem as an isomorphism statement, not merely a cardinality statement.

---

## Cross-domain connections

This project is bigger than one quintic.

### 1. Computational algebra
A formal S₅-certificate for `X^5 - X - 1` is the prototype for a **verified Galois-group recognizer** over `ℚ`. That feeds directly into:
- exact factorization certification,
- resolvent-based algorithms,
- certified algebraic number field construction.

### 2. Arithmetic statistics
Once the “mod-`p` factorization → cycle type” bridge exists, Lean can begin to formalize **Chebotarev-visible signatures** of explicit number fields. This opens machine-checked experiments on the distribution of Frobenius classes.

### 3. Inverse Galois theory
A reusable pipeline for proving `Gal(f)=Sₙ` for explicit polynomials is a formal foothold toward constructive inverse Galois theory over `ℚ`. Quintics are the first serious test case.

### 4. Certified symbolic computation
This creates a path from informal CAS output (“Galois group is S₅”) to fully checked proof objects. That is crucial for trustworthy computer algebra in number theory and cryptography.

### 5. Permutation group theory meets arithmetic geometry
The discriminant-sign theorem is a deep bridge between the geometry of branch loci and the parity representation of root permutations. Formalizing it starts to unify algebraic geometry, number theory, and finite group actions in Lean.

---

## Application keywords

`Galois theory`, `Dedekind theorem`, `Frobenius cycle type`, `discriminant parity`, `alternating subgroup`, `transitive subgroup classification`, `splitting fields`, `computational algebra`, `certified CAS`, `inverse Galois theory`, `arithmetic statistics`, `Chebotarev heuristics`, `formal number theory`

---

## Bold extension targets if the main theorem lands early

If you complete the core theorem efficiently, immediately push one of these:

1. **General quintic S₅ criterion.**  
   Formalize a theorem schema:
   > If `f ∈ ℤ[X]` is irreducible of degree 5, has squarefree discriminant not a square, and `f mod p` is irreducible for some good prime `p`, then the Galois group is `S₅`.

2. **Dedekind factorization-to-cycle theorem.**  
   Package the prime reduction / cycle type correspondence as a reusable theorem.

3. **Transitive subgroup classifier for `S₅`.**  
   Create a library result classifying transitive subgroups of `S₅` by cycle data and parity.

These would turn a one-off result into a new research-grade Lean capability.

---

## Deliverables

1. The main Lean theorem certifying `Gal(X^5 - X - 1 / ℚ) ≅ S₅`.
2. Reusable lemmas for:
   - discriminant computation or discriminant-square criterion,
   - transitive subgroup classification in degree 5,
   - modular irreducibility witness.
3. Minimal `sorry`.
4. A structured `FUTURE_DIRECTIONS.md` containing **3–5 concrete breakthrough next steps**, for example:
   - formal Dedekind theorem for unramified primes,
   - a generic `S₅` certification theorem for quintics,
   - a certified Galois-group tactic for low-degree polynomials over `ℚ`,
   - explicit `A₅` and `D₅` quintic examples,
   - a bridge from modular factorization patterns to Chebotarev experiments.

Do not treat this as an isolated exercise. Treat it as the opening move in a formal, machine-verified theory of explicit Galois groups.

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

**Team Directive**: Create a team to conduct research, brainstorm hypotheses,
run experiments, validate data, update knowledge base and iterate forever.
Each future direction should be specific enough for a team to pick up and
pursue with clear hypotheses, proof strategies, and cross-domain connections.

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

Research domain: Speculative
Research mode: prove
