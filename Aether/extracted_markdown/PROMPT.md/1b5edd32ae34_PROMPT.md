Soli Deo Gloria

## Assignment: Direction 1: Arithmetic Universality for Deep Compositions

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`,
   `norm_num`, or `rfl` unless the statement itself is genuinely important.
   If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at
   least 3 theorems proven using induction, rcases, by_contra, field_simp,
   or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept
   that does not already exist in the Catalog. Check the catalog references to
   confirm novelty.

4. **Cross-domain connections**: Include at least one theorem that connects your
   domain to a different mathematical domain (e.g., number theory + tropical
   geometry, algebra + physics).

5. **Conjecture with testable prediction**: State at least one falsifiable
   conjecture with a clear computational test that could disprove it.

---

### Research Direction: Arithmetic Universality for Deep Tropical Compositions

**Core Conjecture (Tropical Deep Universality):** For multi-layer ReLU networks $L = \sigma_k \circ W_k \circ \cdots \circ \sigma_1 \circ W_1$ with tropical degeneration parameter $t$, the limiting active-set complex of the composed loss depends only on the *tropical composition diagram*: the sequence of weight matrices' valuation profiles and the combinatorial type of each layer's arrangement. Specifically, if two $k$-layer networks have valuation-equivalent weight matrices at each layer and the same activation pattern incidence structure, their tropical active-set complexes are isomorphic as cell complexes.

**Test:** Construct pairs of 3-layer ReLU networks with identical valuation profiles but different coefficients. Compute the linear region decomposition numerically (using the polyhedral tools of [Serra et al., 2018]). Verify that the number and incidence structure of linear regions agree. A single pair where the linear region counts disagree would refute the conjecture.

**Impact:** This would extend the single-layer universality results (Theorems 4.4, 4.7) to the architecturally relevant multi-layer setting, establishing that the "effective complexity" of a deep network is an arithmetic invariant of its weight matrices. This opens: (1) arithmetic complexity theory for neural architectures, (2) valuation-theoretic model compression — two networks with the same tropical diagram are functionally interchangeable, (3) connections to p-adic information geometry via the Berkovich skeleton of the loss landscape.

**Catalog References:** `Tropical/ArithmeticUniversality/Defs.lean` — Theorems `tropMax_eq_of_valuationEquivalent`, `activeComplex_bij_of_sameSignType`

---

### Novel Definitions (Lean 4)

```lean
/-- A valuation profile for a matrix assigns to each entry its p-adic valuation.
    This is the arithmetic fingerprint that determines tropical behavior. -/
structure ValuationProfile (p : ℕ) (m n : ℕ) where
  vals : Fin m → Fin n → ℕ
  -- The p-adic valuation of entry (i,j)

/-- Two matrices are valuation-equivalent if they have the same valuation profile. -/
def ValuationEquiv (p : ℕ) {m n : ℕ} (A B : Matrix (Fin m) (Fin n) ℚ) : Prop :=
  ∀ i j, (vPadic p) (A i j) = (vPadic p) (B i j)

/-- Tropical composition: the max-plus analogue of matrix multiplication.
    For matrices A (m×n) and B (n×k), the tropical product is
    (A ⊗ B)[i,k] = max_j (v(A[i,j]) + v(B[j,k]))
    This is the fundamental composition operation for deep networks. -/
def tropicalCompose (p : ℕ) {m n k : ℕ}
    (φA : ValuationProfile p m n) (φB : ValuationProfile p n k) :
    ValuationProfile p m k where
  vals i l := Finset.sup' (Finset.univ) (Finset.univ_nonempty)
    (fun j => φA.vals i j + φB.vals j l)

/-- The tropical composition diagram of a k-layer network is the sequence
    of valuation profiles and the sign-type (activation pattern) at each layer. -/
structure TropicalDiagram (p : ℕ) (dims : List ℕ) where
  profiles : ∀ {i}, i < dims.length - 1 →
    ValuationProfile p (dims.get ⟨i, by omega⟩) (dims.get ⟨i+1, by omega⟩)
  sign_types : ∀ {i}, i < dims.length - 1 →
    SignTypeVector (dims.get ⟨i+1, by omega⟩)

/-- Two tropical diagrams are isomorphic if there exist compatible
    permutations making profiles and sign types agree. -/
def TropicalDiagramIso {p : ℕ} {dims : List ℕ}
    (D₁ D₂ : TropicalDiagram p dims) : Prop :=
  ∃ (perms : Fin dims.length → (Equiv.Perm (Fin (dims.get ⟨·, by omega⟩)))),
    ∀ i (h : i < dims.length - 1),
      (∀ j k, D₁.profiles h j k = D₂.profiles h (perms i j) (perms (i+1) k)) ∧
      (∀ j, D₁.sign_types h j = D₂.sign_types h (perms (i+1) j))

/-- The active-set complex of a tropical function records the
    combinatorial type of its linear region decomposition.
    Faces correspond to subsets where certain coordinates achieve
    the maximum simultaneously. -/
structure ActiveSetComplex (n : ℕ) where
  faces : Finset (Finset (Fin n))
  -- Which coordinates jointly achieve the max
  face_order : faces → ℕ
  -- Dimension of each face
  face_incidence : ∀ {F G : Finset (Fin n)},
    F ∈ faces → G ∈ faces → (G ⊆ F → face_order G ≤ face_order F)
  maximal_face : ∃ F ∈ faces, face_order F = n
```

---

### Theorem 1: Tropical Composition Preserves Valuation Equivalence

```lean
/-- If A ~ A' and B ~ B' (valuation-equivalent pairs), then their
    tropical compositions are valuation-equivalent.
    This is the fundamental compatibility between arithmetic equivalence
    and deep network composition. -/
theorem tropicalCompose_preserves_valEquiv (p : ℕ) {m n k : ℕ}
    (A A' : Matrix (Fin m) (Fin n) ℚ) (B B' : Matrix (Fin n) (Fin k) ℚ)
    (hA : ValuationEquiv p A A') (hB : ValuationEquiv p B B') :
    ValuationEquiv p (tropicalMatMul p A B) (tropicalMatMul p A' B') := by
  -- Proof strategy:
  -- 1. Unfold tropical composition: (A⊗B)[i,l] = max_j (v(A[i,j]) + v(B[j,l]))
  -- 2. Use hA and hB pointwise: v(A[i,j]) = v(A'[i,j]) and v(B[j,l]) = v(B'[j,l])
  -- 3. The max over j of equal quantities is equal
  -- 4. Key subtlety: the ARGMAX set may differ even when values agree,
  --    but the max VALUE is determined by valuations alone
  sorry
```

**Proof Strategy A (Direct computation):** Unfold the tropical product definition. For each output coordinate $(i,l)$, the value $\max_j (v(A[i,j]) + v(B[j,l]))$ depends only on the individual valuations. Since $h_A$ and $h_B$ give pointwise equality of valuations, the max over identical sequences of addends is identical. This is straightforward but does not capture the combinatorial subtlety.

**Proof Strategy B (Argmax stability via sign types — RECOMMENDED):** The deeper insight is that while the max *value* is trivially preserved, the *argmax set* (which determines the active-set complex) is preserved when sign types agree. Use `activeComplex_bij_of_sameSignType` from the catalog. The key lemma is: if two addends in the tropical sum achieve the same maximal value, the sign type determines which survives the tie-breaking, and identical sign types give identical tie-breaking. This connects valuation equivalence to combinatorial type preservation.

---

### Theorem 2: Newton Polytope of Tropical Composition is Minkowski Sum

```lean
/-- The Newton polytope of a tropical composition equals the
    Minkowski sum of the layer Newton polytopes.
    This connects tropical deep networks to classical polyhedral geometry
    and explains why depth multiplicatively increases expressivity:
    the Minkowski sum of k polytopes in R^n has volume bounded by
    the mixed volume (Bernstein-Kushnirenko theorem). -/
theorem newtonPolytope_tropicalCompose (p : ℕ) {m n k : ℕ}
    (A : Matrix (Fin m) (Fin n) ℚ) (B : Matrix (Fin n) (Fin k) ℚ) :
    newtonPolytope (tropicalMatMul p A B) =
      minkowskiSum (newtonPolytope (tropicalMat p A))
                  (newtonPolytope (tropicalMat p B)) := by
  -- Proof strategy:
  -- 1. The tropical function f_A(x) = max_j (v(A[i,j]) + x_j) has
  --    Newton polytope = conv{v(A[i,·]) : j ∈ Fin n}
  -- 2. Tropical composition f_{A⊗B}(x) = max_j (v(A[i,j]) + f_B(e_j))
  -- 3. This is a tropical affine transform of f_B, shifted by v(A[i,·])
  -- 4. The Newton polytope of a tropical affine shift is the translate
  -- 5. The max over j is the tropical sum, whose Newton polytope is the
  --    Minkowski sum of the summand Newton polytopes
  sorry
```

**Proof Strategy A (Vertex-by-vertex):** Show that vertices of the composed polytope correspond to pairs of vertices from the summands. This requires careful handling of degenerate cases where Minkowski sums create non-vertex points.

**Proof Strategy B (Support function characterization — RECOMMENDED):** Two convex polytopes are equal iff their support functions agree in every direction. The support function of a Minkowski sum is the sum of support functions. For tropical polytopes, the support function in direction $\mathbf{w}$ is $\max_{\mathbf{v} \in P} \langle \mathbf{w}, \mathbf{v} \rangle$, and the tropical composition property makes this additive by construction. This avoids vertex enumeration entirely and generalizes to non-full-dimensional polytopes.

**Cross-domain connection:** The Minkowski sum structure connects to Bernstein's theorem in algebraic geometry: the number of common zeros of $k$ polynomial systems equals the mixed volume of their Newton polytopes. This means the number of critical points of a deep network's loss function (which determines the number of local minima) is bounded by the mixed volume of layer Newton polytopes — a purely arithmetic quantity.

---

### Theorem 3: Active-Set Complex Isomorphism from Diagram Isomorphism (Main Result)

```lean
/-- MAIN THEOREM: If two k-layer networks have isomorphic tropical diagrams,
    their active-set complexes are isomorphic as graded posets.
    This establishes that the combinatorial topology of a deep network's
    loss landscape is an arithmetic invariant. -/
theorem activeSetComplex_iso_of_diagramIso {p : ℕ} {dims : List ℕ}
    (D₁ D₂ : TropicalDiagram p dims)
    (h : TropicalDiagramIso D₁ D₂) :
    ActiveSetComplexIso (activeSetComplex D₁) (activeSetComplex D₂) := by
  -- Proof by induction on depth k:
  -- Base case (k=1): Follows from catalog theorem activeComplex_bij_of_sameSignType
  -- Inductive step: The active-set complex of σ_{k+1} ∘ W_{k+1} ∘ F_k
  --   is determined by the face lattice of the k+1-th Newton polytope
  --   and the active-set complex of F_k.
  --   By Theorem 2, the Newton polytope depends only on valuations.
  --   By induction, the active-set complex of F_k depends only on the diagram.
  --   The composition of face-lattice-preserving maps preserves isomorphism type.
  sorry
```

**Proof Strategy A (Direct induction on depth):** For $k=1$, the result is `activeComplex_bij_of_sameSignType`. For the inductive step, decompose the $k$-layer network as $\sigma_k \circ W_k \circ F_{k-1}$. The active-set complex of the composition is determined by (a) the face lattice of $\text{Newt}(W_k)$ (which depends only on valuations by Theorem 2), and (b) how faces of $\text{Newt}(W_k)$ restrict to the image of $F_{k-1}$'s active-set complex. By induction hypothesis, (b) is diagram-determined.

**Proof Strategy B (Berkovich skeleton approach — MOST PROMISING):** The active-set complex is the Berkovich skeleton of the tropical function. Tropical composition corresponds to composition of Berkovich retraction maps. An isomorphism of tropical diagrams induces a commutative diagram of Berkovich retractions, hence an isomorphism of skeleta. This is the deepest approach: it identifies the active-set complex as a homotopy invariant of the Berkovich analytic space associated to the network, connecting neural network topology to non-Archimedean analytic geometry.

---

### Theorem 4 (Cross-Domain): Tropical Composition and p-adic Information Content

```lean
/-- CROSS-DOMAIN THEOREM: The p-adic entropy of a tropical composition
    is subadditive in depth. This connects tropical deep networks to
    p-adic information theory.
    
    H_p(f ⊗ g) ≤ H_p(f) + H_p(g)
    
    where H_p(f) = log_p |Newt(f)|_p and |·|_p is the p-adic volume
    (normalized Haar measure on Z_p^n). -/
theorem padic_entropy_subadditive (p : ℕ) [hp : Fact (Nat.Prime p)]
    {m n k : ℕ}
    (A : Matrix (Fin m) (Fin n) ℚ) (B : Matrix (Fin n) (Fin k) ℚ) :
    padicEntropy p (tropicalMatMul p A B) ≤
      padicEntropy p (tropicalMat p A) + padicEntropy p (tropicalMat p B) := by
  -- This follows from Theorem 2 + Brunn-Minkowski inequality for p-adic volumes.
  -- The p-adic Brunn-Minkowski inequality states:
  --   vol_p(P + Q)^{1/n} ≤ vol_p(P)^{1/n} + vol_p(Q)^{1/n}
  -- Taking logarithms and using Theorem 2 gives the result.
  sorry
```

**Cross-domain significance:** This connects three fields simultaneously:
1. **p-adic analysis**: The entropy is measured in p-adic Haar measure
2. **Convex geometry**: Brunn-Minkowski controls Minkowski sum volumes
3. **Information theory**: Subadditivity is the data processing inequality for p-adic channels

This means deep networks *cannot* increase p-adic information content through tropical composition — a fundamental capacity bound analogous to the classical data processing inequality, but in the p-adic setting.

---

### Falsifiable Conjecture

**Conjecture (Tropical Region Count Formula):** For a $k$-layer ReLU network with dimensions $d_0, d_1, \ldots, d_k$, if each weight matrix has generic $p$-adic valuations (no ties in the tropical sum), the number of linear regions equals:

$$N = \prod_{i=1}^{k} \binom{d_i}{d_{i-1}} \cdot \sum_{F \in \text{faces}(\Delta)} \prod_{j \in F} \text{ord}_p(\det W_j)$$

where $\Delta$ is the tropical composition simplex and $W_j$ are the layer Jacobians.

**Test:** For $p=2$, $k=3$, dimensions $(2,4,4,2)$: compute the exact region count for 100 random weight matrices with generic 2-adic valuations. If the formula predicts correctly for all 100, confidence increases. A single counterexample refutes it.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 testable scientific hypotheses, each falsifiable with a clear computational test
(b) **RESEARCH_PAPER.md** — standalone scientific document explaining the discovery, its significance, and next steps
(c) **ARTICLE.md** — Scientific American style, accessible to broad audience
(d) **Verified algorithm**: `tropicalDiagramClassify` — takes a weight matrix sequence and computes the tropical diagram, checks isomorphism class
(e) **demo.py** — interactive demonstration: generate random deep networks, compute their tropical diagrams, verify that diagram-equivalent networks have isomorphic active-set complexes, visualize the Newton polytope Minkowski sum structure

**Application Keywords:** p-adic model compression, tropical capacity bounds, Berkovich neural topology, arithmetic expressivity, valuation-theoretic generalization bounds, non-Archimedean information geometry

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
