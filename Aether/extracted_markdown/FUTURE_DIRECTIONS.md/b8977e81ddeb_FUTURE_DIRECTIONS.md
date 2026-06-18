# Future Directions: Decomposable Matrix Verification

## Overview

This document maps the breakthrough opportunities opened by the formal theory of decomposable verification. Each direction builds directly on the proved theorems and extends the local-to-global verification paradigm.

---

## Direction 1: Formal Sum-Check Protocol over Multilinear Polynomials

### Exact Theorem Statement

```lean
theorem sumcheck_soundness
    {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    {n : ℕ}
    (p : MvPolynomial (Fin n) F)
    (d : ℕ) (hdeg : p.totalDegree ≤ d)
    (claimed_sum : F)
    (hneq : (∑ x : Fin n → ({0, 1} : Finset F), MvPolynomial.eval (fun i => (x i : F)) p) ≠ claimed_sum) :
    -- Probability that a cheating prover fools an honest verifier
    -- is at most n·d / |F| per round
    True -- placeholder for the probability bound
```

### Why It Matters
The sum-check protocol is the workhorse of interactive proof systems, from IP = PSPACE to modern SNARKs. Formalizing its soundness would create the first machine-verified foundation for algebraic proof systems. Our `freivalds_soundness_bound` already establishes the one-round, degree-1 special case; extending to multilinear polynomials over the Boolean hypercube is the natural next step.

### Required Mathlib Infrastructure
- `MvPolynomial` evaluation and degree bounds
- Schwartz-Zippel lemma for multivariate polynomials (may need to be built)
- Counting arguments over finite fields (partially established by our `card_submodule_eq_pow_finrank`)

### Estimated Difficulty
**Hard** (3–5 weeks). The Schwartz-Zippel lemma is the main obstacle; once available, the sum-check protocol follows by induction on variables.

### Builds On
`freivalds_soundness_bound`, `card_submodule_eq_pow_finrank`, `ker_finrank_lt_of_ne_zero`

---

## Direction 2: Tropical Polynomial Identity Testing

### Exact Theorem Statement

```lean
theorem tropical_PIT_separation
    {n : ℕ}
    (f g : (Fin n → ℝ) → ℝ)
    (hf : IsTropicalPolynomial f) (hg : IsTropicalPolynomial g)
    (hneq : f ≠ g) :
    ∃ x : Fin n → ℝ, |f x - g x| ≥ δ_tropical(f, g)
```

### Why It Matters
Tropical polynomial identity testing reduces PIT—a central problem in algebraic complexity—to piecewise-linear geometry. The formal connection between classical PIT (Freivalds for matrices) and tropical PIT creates a bridge between randomized algorithms and combinatorial geometry. This could lead to deterministic PIT algorithms via tropicalization.

### Required Mathlib Infrastructure
- Tropical semiring formalization (exists in Mathlib: `Tropical`)
- Piecewise-linear function theory
- Tropical convexity (polyhedral geometry)

### Estimated Difficulty
**Very Hard** (6–10 weeks). Requires building tropical polynomial theory from scratch, but the payoff is enormous: a formal bridge between algebraic and tropical complexity.

### Builds On
`tropical_mirror`, `tropical_and`, `tropical_mulVec_norm_bound`

---

## Direction 3: Sheaf Semantics for Verification Presheaves

### Exact Theorem Statement

```lean
-- The presheaf of local verifiers
def verificationPresheaf (D : Matrix n n R) : Presheaf (Set n) where
  obj U := {r : U → R | (D.restrict U).mulVec r = 0}
  map f := fun r => r ∘ f

theorem verification_presheaf_detects_nonzero
    (D : Matrix n n R) (hD : D ≠ 0) :
    ¬ (∀ U : Set n, verificationPresheaf D |>.obj U = ⊤)
```

### Why It Matters
This recasts matrix verification in the language of sheaf theory. The key insight: the assignment `U ↦ {probes annihilating discrepancy on U}` forms a presheaf, and global soundness corresponds to non-triviality of this presheaf. This is the most conceptually profound direction—it connects randomized verification to modern algebraic geometry and could open verification theory to tools from cohomological algebra.

### Required Mathlib Infrastructure
- Presheaf/sheaf formalization (exists in Mathlib: `CategoryTheory.Sheaf`)
- Submatrix restriction API
- Galois connection between covers and local sections

### Estimated Difficulty
**Hard** (4–6 weeks). The category-theoretic setup exists in Mathlib, but connecting it to concrete matrix operations requires careful bridge-building.

### Builds On
`block_diagonal_mul_eq_iff`, `block_diagonal_failure_detection`, `block_verification_detection`

---

## Direction 4: Randomized Certificates for Transformer Linear Layers

### Exact Theorem Statement

```lean
theorem transformer_attention_certificate
    {n d_k d_v : ℕ}
    (Q K V : Matrix (Fin n) (Fin d_k) ℝ)
    (W_O : Matrix (Fin d_v) (Fin d_v) ℝ)
    (Q' K' V' : Matrix (Fin n) (Fin d_k) ℝ)
    (W_O' : Matrix (Fin d_v) (Fin d_v) ℝ)
    (h_attn : attention_scores Q K = attention_scores Q' K')
    (h_val : V = V') (h_out : W_O = W_O') :
    transformer_layer Q K V W_O = transformer_layer Q' K' V' W_O'
```

### Why It Matters
Modern AI systems are built on transformer architectures. Formalizing certificates for attention layers—the core computation—would create the foundation for trustworthy AI verification. Our `linear_layer_certificate` and `block_network_certificate` already handle the linear component; extending to attention (which involves softmax and bilinear forms) is the natural frontier.

### Required Mathlib Infrastructure
- Softmax function and its properties
- Bilinear form theory connected to matrix multiplication
- Real analysis for exp/log operations in attention

### Estimated Difficulty
**Hard** (4–8 weeks). The softmax nonlinearity is the main challenge; the linear algebra infrastructure is already in place from our current work.

### Builds On
`linear_layer_certificate`, `block_network_certificate`, `verification_composition`, `tropical_layer_composition_bound`

---

## Direction 5: Algebraic Soundness Pipeline for Neural Verification

### Exact Theorem Statement

```lean
theorem neural_verification_pipeline
    {L : ℕ} -- number of layers
    (W W' : Fin L → Matrix (Fin n) (Fin n) ℝ)
    (σ : ℝ → ℝ) -- activation function (e.g., ReLU)
    (hσ_lip : ∀ x y, |σ x - σ y| ≤ |x - y|) -- 1-Lipschitz
    (x : Fin n → ℝ)
    (hlocal : ∀ i, ‖(W i - W' i).mulVec (intermediate_output W σ x i)‖ ≤ ε_i)
    :
    ‖network_output W σ x - network_output W' σ x‖ ≤ composed_bound ε W σ
```

### Why It Matters
This is the end-to-end vision: a formally verified pipeline from individual layer certificates to global neural network equivalence guarantees. It combines Lipschitz continuity of activations, tropical composition bounds, and layer-by-layer verification into a single soundness theorem. This would be the first machine-verified framework for certifying neural network behavior.

### Required Mathlib Infrastructure
- Lipschitz continuity and composition
- ReLU formalization (piecewise linear)
- Iterated function composition with bounds
- Our existing tropical composition bounds

### Estimated Difficulty
**Very Hard** (8–12 weeks). The main challenges are: (1) formalizing the interplay between linear layers and nonlinear activations, and (2) making the error propagation bounds tight enough to be useful. But the payoff—a formal foundation for neural verification—would be transformative.

### Builds On
`tropical_layer_composition_bound`, `verification_composition`, `tropical_robustness_margin`, `tropical_margin_list_min_pos`

---

## Team Directive

**Team structure**: Each direction should be pursued by a team of 1-2 formalization specialists with access to the full Mathlib library and the theorems established in this cycle.

**Iteration protocol**:
1. State the theorem in Lean with `sorry`
2. Decompose into 3-10 helper lemmas
3. Test each helper with `#eval` on small examples
4. Prove helpers bottom-up
5. Assemble the main theorem
6. Write documentation and cross-references

**Cross-team coordination**: Directions 1 and 2 share the Schwartz-Zippel lemma as infrastructure. Directions 4 and 5 share the neural network formalization. Direction 3 provides the conceptual framework that unifies all others.

**Priority order**: Direction 1 (sum-check) is the highest-impact short-term target because it directly extends our Freivalds infrastructure and connects to the widest range of applications in formal complexity theory. Direction 5 (neural pipeline) is the highest-impact long-term target because it addresses the most pressing applied problem.
