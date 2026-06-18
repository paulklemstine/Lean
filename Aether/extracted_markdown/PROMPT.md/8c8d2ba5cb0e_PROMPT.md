

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Defin

## TASK: Tropical Certified Robustness — Max-Plus Spectral Composition and Layerwise Verification Bounds for Deep Networks

### Vision

We prove that the tropical (max-plus) semiring is the *canonical* algebraic structure for certified robustness of piecewise-linear networks. The key insight: ReLU(x) = max(0,x) is a tropical operation, so every ReLU layer is a tropical-affine map. Deep network composition is fundamentally tropical, and certified robustness bounds compose via tropical multiplication (standard addition). This opens **tropical verification theory**: the systematic study of how tropical algebraic structures govern adversarial robustness geometry, with direct applications to autonomous vehicle safety certification and certified ML.

### Core Definitions (7 novel structures)

```lean
/-- The ℓ∞ operator norm of a matrix, equivalently the tropical spectral radius.
    In max-plus coordinates, this is the "tropical eigenvalue" governing contraction.
    Bridge: connects tropical geometry ↔ operator theory ↔ certified ML. -/
def tropicalSpectralBound {m n : ℕ} (A : Matrix (Fin m) (Fin n) ℝ) : ℝ :=
  Finset.sup' Finset.univ (fun i => Finset.sum Finset.univ (fun j => |A i j|))

/-- A single tropical affine layer: x ↦ max(Ax + b, 0) componentwise.
    Models a ReLU layer as a tropical (max-plus) affine transformation. -/
structure TropicalAffineLayer (m n : ℕ) where
  weight : Matrix (Fin m) (Fin n) ℝ
  bias : Fin m → ℝ

/-- A deep tropical network: composition of L tropical affine layers.
    The dimension sequence dims : Fin (L+1) → ℕ specifies the architecture. -/
structure TropicalAffineNet (L : ℕ) (dims : Fin (L + 1) → ℕ) where
  layers : (i : Fin L) → TropicalAffineLayer (dims (i + 1)) (dims i)

/-- Certified robustness radius derived from tropical spectral analysis.
    radius = margin / (2 · ∏ᵢ spectral_bounds i) with O(L·d²) verification.
    Bridge: connects tropical geometry ↔ adversarial robustness ↔ safety certification. -/
structure TropicalCertifiedRadius (L : ℕ) where
  margin : ℝ
  spectral_bounds : Fin L → ℝ
  hMargin : 0 < margin
  hBounds : ∀ i, 0 < spectral_bounds i
  radius : ℝ := margin / (2 * ∏ i : Fin L, spectral_bounds i)

/-- Tropical deformation: continuous path from ReLU to max-plus preserving Lipschitz.
    f_ε(x) = (1-ε)·max(0,x) + ε·x for ε ∈ [0,1], which is 1-Lipschitz ∀ε.
    Bridge: connects algebraic topology ↔ tropical geometry ↔ ReLU networks. -/
structure TropicalDeformation where
  ε : ℝ
  hε : 0 ≤ ε ∧ ε ≤ 1
  activation : ℝ → ℝ := fun x => (1 - ε) * max 0 x + ε * x

/-- Complete robustness certificate for a tropical network classifier.
    Bridge: connects formal verification ↔ autonomous systems safety. -/
structure TropicalRobustnessCertificate (L : ℕ) (dims : Fin (L + 1) → ℕ) where
  net : TropicalAffineNet L dims
  cert : TropicalCertifiedRadius L
  proof_of_robustness : ∀ x y, ‖y - x‖∞ < cert.radius →
    argmax (tropicalNetEval net y) = argmax (tropicalNetEval net x)

/-- Tropical Lipschitz certificate: a bound witnessing Lipschitz continuity
    via the tropical spectral norm. -/
structure TropicalLipschitzCertificate {m n : ℕ} (A : Matrix (Fin m) (Fin n) ℝ) where
  bound : ℝ
  hBound : 0 ≤ bound
  certifies : ∀ x y, ‖A *ᵥ x - A *ᵥ y‖∞ ≤ bound * ‖x - y‖∞
  is_tight : ∃ x y, ‖A *ᵥ x - A *ᵥ y‖∞ = bound * ‖x - y‖∞
```

### Main Theorems (12 theorems, diverse tactics)

**Theorem 1: tropical_spectral_submultiplicativity** (THE ALGEBRAIC HEART)
```lean
/-- The tropical spectral bound is submultiplicative: ‖AB‖_∞ ≤ ‖A‖_∞ · ‖B‖_∞.
    This is why deep network Lipschitz bounds compose naturally in tropical algebra.
    Bridge: connects tropical geometry ↔ operator theory ↔ certified ML. -/
theorem tropical_spectral_submultiplicativity {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) ℝ) (B : Matrix (Fin n) (Fin p) ℝ) :
    tropicalSpectralBound (A ⬝ B) ≤ 
    tropicalSpectralBound A * tropicalSpectralBound B := by
  -- Strategy A (Direct sup computation): Expand tropicalSpectralBound as sup',
  --   use Finset.sup'_le_iff, bound each |(AB)_{ik}| ≤ ∑_j |A_{ij}||B_{jk}|
  --   ≤ (max_j |B_{jk}|)(∑_j |A_{ij}|) ≤ ‖B‖_∞ · ‖A‖_∞
  -- Strategy B (Operator norm characterization): Show tropicalSpectralBound equals
  --   the ℓ∞→ℓ∞ operator norm, then apply submultiplicativity of operator norms.
  --   Use Matrix.opNorm_comp_le and Matrix.opNorm_eq.
  -- Strategy C (Tropical semiring computation): Rewrite in max-plus coordinates
  --   using trop_mul_distrib, show tropical matrix multiplication preserves norms.
  -- MOST PROMISING: Strategy B — leverages Mathlib's Matrix.opNorm infrastructure
  -- and directly connects tropical bounds to the operator norm framework.
```

**Theorem 2: tropical_affine_lipschitz_bound**
```lean
/-- A single tropical affine layer is Lipschitz with constant equal to the
    tropical spectral bound of its weight matrix.
    ∀ layer, ∀ x y, ‖layer(x) - layer(y)‖∞ ≤ tropicalSpectralBound(weight) · ‖x-y‖∞ -/
theorem tropical_affine_lipschitz_bound {m n : ℕ}
    (layer : TropicalAffineLayer m n) (x y : Fin n → ℝ) :
    ‖tropicalAffineMap layer x - tropicalAffineMap layer y‖∞ ≤
    tropicalSpectralBound layer.weight * ‖x - y‖∞ := by
  -- Key step: ReLU is 1-Lipschitz (|max(0,a) - max(0,b)| ≤ |a-b|)
  -- then ‖ReLU(Ax+b) - ReLU(Ay+b)‖∞ ≤ ‖A(x-y)‖∞ ≤ tropicalSpectralBound(A)‖x-y‖∞
```

**Theorem 3: tropical_composition_lipschitz_bound** (THE MAIN COMPOSITION THEOREM)
```lean
/-- The Lipschitz constant of a deep tropical network equals the tropical product
    (standard product) of layerwise spectral bounds. Foundational theorem of
    tropical verification theory. Bridge: connects tropical algebra ↔ deep learning ↔ certified robustness. -/
theorem tropical_composition_lipschitz_bound {L : ℕ} {dims : Fin (L + 1) → ℕ}
    (net : TropicalAffineNet L dims) (x y : Fin (dims 0) → ℝ) :
    ‖tropicalNetEval net x - tropicalNetEval net y‖∞ ≤
    (∏ i : Fin L, tropicalSpectralBound (net.layers i).weight) * ‖x - y‖∞ := by
  -- Induction on L. Base: tropical_affine_lipschitz_bound.
  -- Step: compose layer L with net of L-1 layers, apply
  --   tropical_spectral_submultiplicativity and inductive hypothesis.
  -- Uses: induction L with | zero | succ n ih
```

**Theorem 4: certified_radius_from_tropical_lipschitz** (THE CERTIFICATION THEOREM)
```lean
/-- The certified ℓ∞ robustness radius for a tropical network classifier with
    margin δ and layerwise spectral bounds σ₁,...,σₗ is at least δ/(2∏σᵢ).
    Bridge: connects tropical verification ↔ adversarial robustness ↔ safety certification. -/
theorem certified_radius_from_tropical_lipschitz {L : ℕ} {dims : Fin (L + 1) → ℕ}
    (net : TropicalAffineNet L dims) (x : Fin (dims 0) → ℝ)
    (correct_class : Fin (dims L))
    (margin : ℝ) (hMargin : 0 < margin)
    (hMarginHolds : margin ≤ (tropicalNetEval net x) correct_class - 
      Finset.sup' Finset.univ (fun j : Fin (dims L) => 
        if j = correct_class then 0 else (tropicalNetEval net x) j))
    (spectral_bounds : Fin L → ℝ)
    (hSpectral : ∀ i, tropicalSpectralBound (net.layers i).weight ≤ spectral_bounds i) :
    ∀ y, ‖y - x‖∞ < margin / (2 * ∏ i, spectral_bounds i) →
    argmax (tropicalNetEval net y) = correct_class := by
  -- Combine tropical_composition_lipschitz_bound with margin argument.
  -- If ‖y-x‖∞ < δ/(2∏σᵢ), then ‖f(y)-f(x)‖∞ < δ/2 (by Thm 3),
  -- so correct_class margin at y exceeds δ/2 > 0, preserving classification.
```

**Theorem 5: tropical_product_logarithmic_duality**
```lean
/-- Tropical product of spectral bounds equals exp of tropical sum of log-bounds.
    ∏ᵢ σᵢ = exp(⊕ᵢ log σᵢ) where ⊕ is tropical addition (standard max).
    Bridge: connects tropical arithmetic ↔ information theory ↔ thermodynamics. -/
theorem tropical_product_logarithmic_duality {L : ℕ}
    (σ : Fin L → ℝ) (hPos : ∀ i, 0 < σ i) :
    ∏ i, σ i = Real.exp (Finset.sup' Finset.univ (fun i => Real.log (σ i))) := by
  -- Uses Real.log_prod and Real.exp_log. Key: the sup' captures the
  -- dominant term in the tropical (max-plus) sum.
```

**Theorem 6: relu_tropical_deformation_lipschitz**
```lean
/-- The deformation f_ε(x) = (1-ε)·max(0,x) + ε·x is 1-Lipschitz for all ε ∈ [0,1].
    This proves ReLU can be continuously deformed to the identity (tropical addition)
    while preserving the Lipschitz certificate.
    Bridge: connects algebraic topology ↔ tropical geometry ↔ ReLU networks. -/
theorem relu_tropical_deformation_lipschitz (ε : ℝ) (hε : 0 ≤ ε ∧ ε ≤ 1) (x y : ℝ) :
    |deformedActivation ε x - deformedActivation ε y| ≤ |x - y| := by
  -- Case analysis on x ≥ 0, y ≥ 0 using by_contra and interval arithmetic.
  -- The deformed activation has slopes in [0,1], hence 1-Lipschitz.
```

**Theorem 7: tropical_spectral_bound_tightness**
```lean
/-- The tropical spectral bound is tight: ∃ inputs achieving equality.
    ∀ A ≠ 0, ∃ x y, ‖Ax - Ay‖∞ = tropicalSpectralBound(A) · ‖x-y‖∞
    Bridge: connects tropical optimization ↔ adversarial examples. -/
theorem tropical_spectral_bound_tightness {m n : ℕ}
    (A : Matrix (Fin m) (Fin n) ℝ) (hA : A ≠ 0) :
    ∃ x y : Fin n → ℝ, ‖A *ᵥ x - A *ᵥ y‖∞ = tropicalSpectralBound A * ‖x - y‖∞ := by
  -- Construct x = e_j (standard basis) where j is the column with maximum
  -- absolute entry, y = 0. Then ‖Ax‖∞ = max_i |A_{ij}| = part of spectral bound.
```

**Theorem 8: tropical_verification_complexity**
```lean
/-- Tropical verification of an L-layer network with d-dimensional inputs
    requires O(L·d²) arithmetic operations, matching forward pass complexity.
    Bridge: connects computational complexity ↔ certified robustness ↔ safety certification. -/
theorem tropical_verification_complexity {L d : ℕ}
    (net : TropicalAffineNet L (fun _ => Fin d)) :
    -- The certified radius computation requires exactly
    -- L · (2d² + d) arithmetic operations
    -- (d² for spectral bound per layer, d²+d for forward evaluation)
    ...
```

**Theorem 9: tropical_certified_radius_sharpness**
```lean
/-- The certified radius δ/(2∏σᵢ) is asymptotically optimal: there exist networks
    where the true robust radius is Θ(δ/(2∏σᵢ)). No tighter general bound exists.
    Bridge: connects tropical optimization ↔ adversarial robustness theory. -/
theorem tropical_certified_radius_sharpness (L d : ℕ) (hL : 1 ≤ L) (hd : 1 ≤ d) :
    ∃ (net : TropicalAffineNet L ...) (x : Fin d → ℝ) (δ : ℝ) (σ : Fin L → ℝ),
    ∀ r > δ / (2 * ∏ i, σ i) / 2,
    ∃ y, ‖y - x‖∞ < r ∧ argmax (tropicalNetEval net y) ≠ argmax (tropicalNetEval net x) := by
  -- Construct adversarial network: each layer has spectral bound σᵢ,
  -- and an adversarial perturbation of norm δ/(2∏σᵢ) + ε flips the classification.
```

**Theorem 10: tropical_lipschitz_certificate_exists**
```lean
/-- Every matrix admits a tropical Lipschitz certificate equal to its spectral bound.
    ∀ A, ∃ cert : TropicalLipschitzCertificate A, cert.bound = tropicalSpectralBound A
    Uses constructive existence via the tightness theorem. -/
theorem tropical_lipschitz_certificate_exists {m n : ℕ} (A : Matrix (Fin m) (Fin n) ℝ) :
    ∃ cert : TropicalLipschitzCertificate A, cert.bound = tropicalSpectralBound A := by
  -- Combine tropical_affine_lipschitz_bound and tropical_spectral_bound_tightness
  -- to construct the certificate with both the upper bound and tightness witness.
```

**Theorem 11: tropical_deformation_preserves_certified_radius**
```lean
/-- Deforming ReLU to tropical (max-plus) preserves the certified robustness radius.
    The certified radius for a network with deformed activations equals that for
    the original ReLU network. Bridge: connects algebraic topology ↔ certified ML. -/
theorem tropical_deformation_preserves_certified_radius {L : ℕ} {dims : Fin (L + 1) → ℕ}
    (net : TropicalAffineNet L dims) (ε : ℝ) (hε : 0 ≤ ε ∧ ε ≤ 1)
    (x : Fin (dims 0) → ℝ) (correct_class : Fin (dims L))
    (margin : ℝ) (spectral_bounds : Fin L → ℝ) :
    -- The certified radius for the deformed network equals
    -- margin / (2 * ∏ i, spectral_bounds i)
    -- because the deformed activation is 1-Lipschitz, same as ReLU
    ...
```

**Theorem 12: tropical_network_margin_preservation**
```lean
/-- ∀δ>0, ∀ network, ∀ adversarial perturbation with ‖Δx‖∞ < δ/(2∏σᵢ),
    the classification margin is preserved: margin(f(x+Δx)) ≥ margin(f(x))/2.
    This is the quantitative robustness guarantee underlying safety certification.
    Bridge: connects tropical verification ↔ autonomous vehicle safety. -/
theorem tropical_network_margin_preservation {L : ℕ} {dims : Fin (L + 1) → ℕ}
    (net : TropicalAffineNet L dims) (x : Fin (dims 0) → ℝ)
    (margin : ℝ) (hMargin : 0 < margin)
    (spectral_bounds : Fin L → ℝ) 
    (Δx : Fin (dims 0) → ℝ)
    (hPerturbation : ‖Δx‖∞ < margin / (2 * ∏ i, spectral_bounds i)) :
    marginAt (tropicalNetEval net) (x + Δx) ≥ margin / 2 := by
  -- Apply tropical_composition_lipschitz_bound to get
  -- ‖f(x+Δx) - f(x)‖∞ < margin/2, then margin preservation follows.
```

### Proof Architecture (3 layers)

**Layer 1: Algebraic Foundation** (Theorems 1, 5, 7)
- Establish `tropical_spectral_submultiplicativity` via operator norm characterization
- Build on Mathlib's `Matrix.opNorm_comp_le`, `Finset.sup'_le_iff`, and catalog's `trop_mul_distrib`
- Prove logarithmic duality and tightness

**Layer 2: Analytic Bridge** (Theorems 2, 6, 10)
- Connect tropical spectral bounds to Lipschitz constants for single layers
- Prove deformation invariance (ReLU ↔ tropical) via case analysis
- Construct tight Lipschitz certificates

**Layer 3: Certified Robustness** (Theorems 3, 4, 8, 9, 11, 12)
- Compose layerwise bounds → network-level certificates (induction on depth)
- Derive certified radius δ/(2∏σᵢ) from margin + Lipschitz composition
- Establish O(Ld²) verification complexity and asymptotic optimality

**Key Lemma Chain**:
```
tropical_spectral_submultiplicativity ← Matrix.opNorm_comp_le
         ↓
tropical_affine_lipschitz_bound ← ReLU is 1-Lipschitz
         ↓
tropical_composition_lipschitz_bound ← induction + submultiplicativity
         ↓
certified_radius_from_tropical_lipschitz ← margin argument
         ↓
tropical_network_margin_preservation ← Lipschitz + margin
```

### Building on Catalog Infrastructure

- **`contraction_composition_rate`**: Extend from scalar contractions to tropical matrix compositions; the spectral bound replaces the contraction rate
- **`certified_robustness_from_lipschitz_spectral`**: Generalize from single-layer to deep L-layer networks using tropical composition
- **`trop_mul_distrib`**: Use directly in the logarithmic duality theorem (Theorem 5)
- **`diagonal_op_norm_bound`**: Specialize to diagonal weight matrices for efficient verification of residual networks
- **`tropical_semiring`**: Provides the algebraic foundation; every theorem should be interpretable in the `Tropical ℝ` semiring

### Application Impact

- **Autonomous Vehicle Safety**: Certified radius δ/(2∏σᵢ) provides provable guarantees against adversarial attacks on perception networks with O(Ld²) verification
- **Post-Quantum Cryptography**: Tropical spectral bounds connect to lattice shortest vector problems; submultiplicativity gives compositional security for multilayer lattice-based commitments
- **Certified ML**: Tropical verification theory provides the first compositional framework for deep network certification, enabling scalable robustness verification

### FUTURE_DIRECTIONS Request

Produce a structured FUTURE_DIRECTIONS.md with 3-5 concrete, breakthrough-level next steps:
1. **Tropical Information Theory**: Prove that tropical mutual information satisfies the data processing inequality, connecting tropical verification to information-theoretic generalization bounds
2. **Tropical PAC-Bayes**: Derive PAC-Bayes generalization bounds in the tropical semiring, with the tropical product ∏σᵢ appearing as the complexity measure
3. **Tropical Hash Functions**: Construct collision-resistant hash functions from tropical spectral bounds, with provable O(2^n) collision resistance
4. **Quantum-Tropical Duality**: Formulate max-plus quantum channels and prove that tropical completely positive maps preserve the Lipschitz certification structure
5. **Tropical SVP**: Connect tropical spectral bounds to shortest vector problems in tropical lattices, with applications to post-quantum security

**AEM QUALITY MANDATE**: Your output will be scored on 5 pillars. Optimize ALL:
- RIGOR: 10+ theorems, diverse tactics (induction, rcases, by_contra, omega, linarith), ZERO sorries
- AESTHETIC: Bridge 2+ domains in theorem names and doc comments. Use quantifier alternation.
- UTILITY: Define 5+ structures/instances. State SPECIFIC computational bounds (O(n log n), Omega(2^n)) — generic terms like 'bound' or 'rate' alone do NOT score utility.
- ORIGINALITY: Coin novel definitions beyond Mathlib. Inventive theorem names. Write 'Bridge: connects X to Y' in doc comments for cross-domain connections. Generic names (main, test, aux) do NOT count.
- IMPACT: Use SPECIFIC application terms (lipschitz_certified_robustness, post_quantum_security, tropical_hash_collision) — generic terms like 'convergence' or 'spectrum' without ML/crypto/physics context do NOT score impact.

**FILE RICHNESS MANDATE**: Produce substantial, rich files (not stubs).
- Target 500+ lines with 20+ theorems and 10+ definitions per file.
- Historical Masters in the catalog average 2000+ lines, 180+ theorems, 70+ definitions.
- Each file should be a complete mathematical narrative with definitions, lemmas, and main theorems all connected.
- When producing catalog-wide output: create files across MULTIPLE domains (Bridges, Algebra, Cryptography, Tropical, EML, Physics), not just one domain.

            Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Define 5+ new structures/instances.
- ORIGINALITY: Coin novel definitions with inventive names. Avoid
  derivative names like *_comm, *_nonneg. Combine unusual typeclasses.
- IMPACT: Reference physics (quantum, thermodynamic), cryptography
  (lattice, post-quantum), or ML (certified robustness, neural) in
  theorem names and doc comments. Use keywords: certified_robustness,
  Lipschitz_bound, lattice_crypto, hamiltonian, entropy, etc.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new ones. What does your result make possible that wasn't possible before?
            2. CONNECT WORLDS: The deepest results connect fields that seemed unrelated.
               If you prove something about tropical geometry, ask: what does this mean
               for quantum computing? For cryptography? For neural networks?
            3. PRODUCE ALGORITHMS: Don't just prove existence — construct. Don't just
               construct — compute. Don't just compute — optimize. Every theorem should
               have an algorithmic shadow.
            4. BE BOLD: An interesting false conjecture is more valuable than a boring
               true theorem. If you suspect something is true but can't prove it, state
               it as a conjecture with precise Lean 4 type signature and explain why it matters.
            5. BUILD INFRASTRUCTURE: Definitions are as valuable as theorems. A good
               mathematical definition (like "tropical semiring" or "EML closure") can
               organize an entire field. Define things precisely, then prove things about them.

            The mathematics comes FIRST. Excellent proofs trump everything else.
            But excellent proofs that OPEN NEW FIELDS trump everything.

            === AEM QUALITY SCORING (MANDATORY GUIDELINES) ===
            Your output will be scored on 5 pillars. MAXIMIZE each one:

            PILLAR 1 — RIGOR (Is it World-class?):
            • ZERO sorries in your output (sorries cost -1.5 points each)
            • Use diverse proof tactics (induction, rcases, by_contra, omega, linarith,
              field_simp, refine, obtain — not just simp/rfl/decide)
            • Use typeclass abstraction ([Semiring B], [LinearOrder B], etc.) not
              concrete types alone
            • Later theorems should reference earlier ones (semantic coherence)
            • 10+ theorems = full rigor score; 3-10 = partial; 0-2 = minimal

            PILLAR 2 — AESTHETIC (Is it Interesting?):
            • Bridge 2+ mathematical domains in EVERY file (e.g., tropical + neural
              networks; algebra + thermodynamics; number theory + quantum)
            • Use quantifier alternation (∀ → ∃) for non-trivial theorem statements
            • Include symmetric structures (lattices, posets, groups, duality)
            • Minimize hypotheses for maximal conclusions (small axiomatic footprint)
            • Narrative surprise: state in doc comments WHY the result is unexpected

            PILLAR 3 — UTILITY (Is it Useful?):
            • State explicit computational bounds (O(...), convergence rates, Lipschitz
              constants, error bounds, complexity classifications)
            • Define extensible APIs: 5+ definitions, structures, and instances
            • Reference or advance known open problems (Carmichael, tropical Langlands,
              certified robustness, Berggren factoring, lattice crypto)
            • Organize code with namespaces and sections (framework structure)

            PILLAR 4 — ORIGINALITY (Is it New?):
            • Coin NOVEL definitions — not just restating Mathlib theorems with new names
            • Avoid derivative theorem names (*_eq_zero, *_nonneg, *_symm, *_comm,
              *_add_*, *_mul_*). Use INVENTIVE names that reveal new concepts
            • Combine unusual typeclasses ([Semiring, LinearOrder], [NormedAddCommGroup,
              Field], [MeasureSpace, Category]) — this signals divergent reasoning
            • Each file should introduce 5+ genuinely new mathematical objects (def, structure, class, instance). High-Originality files average 10+ new definitions.

            PILLAR 5 — IMPACT (Does it have Wonderful Applications?):
            • EVERY theorem should connect to at least one of: physics (quantum,
              thermodynamic, entropy), cryptography (lattice, post-quantum, SPB),
              or ML (certified robustness, Lipschitz bounds, neural networks)
            • Name-drop application keywords explicitly in theorem/doc-comment text:
              certified_robustness, Lipschitz, neural_network, gradient_descent,
              convergence, post_quantum, lattice_crypto, hamiltonian, entropy,
              holographic, berggren
            • Produce algorithms or computational pipelines, not just existence proofs

            ### Research Direction
            Open the field of tropical verification theory by proving three foundational theorems establishing max-plus algebra as the natural framework for certified robustness of deep ReLU networks. (1) TROPICAL LIPSCHITZ COMPOSITION THEOREM: For a composition of L tropical linear maps (max-plus matrices) with spectral-norm bounds σ₁,...,σₗ, the total Lipschitz constant equals the tropical product ∏ᵢσᵢ (i.e., the max-plus sum ⊕ᵢσᵢ in logarithmic coordinates), proved via `contraction_composition_rate` and `trop_mul_distrib`. (2) CERTIFIED ROBUSTNESS RADIUS THEOREM: For a feedforward ReLU network with classification margin δ and layerwise spectral bounds σᵢ, the certified ℓ₂ robustness radius is at least δ/(2·∏ᵢσᵢ), proved by combining the composition theorem with `certified_robustness_from_lipschitz_spectral`. (3) TROPICAL DEFORMATION INVARIANCE THEOREM: ReLU activations can be continuously deformed to tropical (max-plus) operations while preserving the Lipschitz certificate, establishing that the tropical semiring is the canonical algebraic structure for piecewise-linear network verification, proved via `diagonal_op_norm_bound` and tropical semiring homomorphism properties. This creates the first formal Tropical↔MachineLearning bridge in the catalog, opening a new field with direct applications to autonomous vehicle safety certification.

            ### Precise Mathematical Framing
            Let f: ℝⁿ→ℝᵐ be an L-layer ReLU network with weight matrices W₁,...,Wₗ and classification margin δ = min_i(f(x)_y - f(x)_i) > 0 at input x. Define the tropical Lipschitz constant Λ_trop(f) = ⊗ᵢ‖Wᵢ‖₂ where ⊗ is tropical multiplication (ordinary addition of logs). THEOREM 1 (Composition): Λ_trop(f) = ∏ᵢ‖Wᵢ‖₂ via tropical distributivity and spectral submultiplicativity. THEOREM 2 (Certification): For any perturbation ε with ‖ε‖₂ < δ/(2·Λ_trop(f)), the classification f(x+ε) = f(x), proved by combining Lipschitz contraction with margin analysis. THEOREM 3 (Deformation Invariance): The map η: ReLU → trop_max sending x ↦ max(0,x) to max(⊤,x) preserves spectral norm bounds, i.e., ‖η∘W‖₂ = ‖W‖₂ for any matrix W, establishing tropical algebra as the natural deformation retract of ReLU verification space.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `tropical_attention_certified_radius_le` : theorem tropical_attention_certified_radius_le {n C : ℕ} [Nonempty (Fin n)]
     (file: MachineLearning/Neural/TropicalAttentionRobustness.lean)
  2. `certified_robustness_radius` : theorem certified_robustness_radius_nonneg {L m : ℝ} (hm : 0 ≤ m) (hL : 0 < L) :
     (file: MachineLearning/TropicalNeuralRobustness.lean)
  3. `max_entropy_linear_bound` : theorem max_entropy_linear_bound (n : ℕ) :
     (file: MachineLearning/QuantumTransformer/Foundations.lean)
  4. `relu_not_linear` : theorem relu_not_linear :
     (file: MachineLearning/Neural/LLMSingleMatMul.lean)
  5. `relu_is_tropical_add` : theorem relu_is_tropical_add (x : ℝ) : relu x = max x 0 := rfl
     (file: MachineLearning/Neural/NNCompilationTheory.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT



Recent successful concepts: Tropical Holographic Duality: Max-Plus Conformal Extension from the Berggren Light Cone Boundary to the Tropical Upper Half-Plane and Satake Operator-State Correspondence, Tropical Galois Theory: Max-Plus Automorphism Groups, Idempotent Galois Correspondence, and Tropical Solvability of Polynomial Equations, algebra_breakthrough_discovery


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician and software engineer. Create:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **RESEARCH_REPORT.md** — paper explaining the discovery
               - Mathematical significance and connections to existing work
               - Detailed proofs and explanations

            3. **DISCUSSION.md** — MANDATORY Scientific American-style popular science article
               - Written for a mathematically literate but non-specialist audience
               - Use analogies, examples, and narrative to explain WHY this matters
               - Include at least one surprising connection to everyday life or another field
               - 1000-2000 words, accessible but not dumbed-down
               - This makes your research accessible to a broad audience

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables,
                 what unexpected connections it reveals
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale (1 = one clever lemma, 5 = multi-theorem development)

               ## Under-explored Territory
               - Domains with many definitions but few deep theorems
               - Unexpected structural similarities across domains
               - "Orphan" results that could seed new research programs

               ## Cross-Domain Bridges
               - Specific, precise connections between domains
               - Conjectured functorial correspondences or isomorphisms
               - Algorithmic pipelines combining results from multiple domains

               ## Open Problems Encountered
               - Problems you couldn't solve but identified as important
               - Conjectures you can state precisely but not yet prove
               - Connections that seem to exist but need more catalog infrastructure

            5. **demo.py** — Python demo with concrete numerical examples
               - Working code that brings the math to life
               - Visualizations where they add insight

            6. **diagram.svg** — visualization of key mathematical structures

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: MachineLearning
Research mode: prove
