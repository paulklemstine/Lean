

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

# Tropical Symplectic Geometry: Min-Plus Hamiltonian Mechanics, Idempotent Action Principles, and Tropical Noether Theorem

## The Vision

We open the field of **tropical symplectic geometry** — the min-plus deformation of classical symplectic mechanics — by proving three foundational theorems that establish the tropical analogues of Hamilton's principle, Noether's theorem, and Gromov's non-squeezing theorem. The deep insight is that Maslov dequantization (replacing `+` with `min` and `×` with `+`) transforms symplectic geometry into a piecewise-linear combinatorial theory where:
- The tropical symplectic form is a **min-plus bilinear form** satisfying tropical antisymmetry: `ω(x,y) ⊕ ω(y,x) = ⊤` (where `⊤ = +∞` is the tropical zero).
- The min-plus action principle selects **infimum** paths rather than stationary paths.
- Tropical Noether charges form a **complete lattice** isomorphic to the lattice of tropical symmetries — a structure with no classical analogue.
- Tropical symplectic capacity provides **PL-analytic certificates** for symplectic rigidity, with direct applications to **lattice-based post-quantum cryptography** (tropical non-squeezing → lattice distortion lower bounds) and **certified robustness** of tropical neural networks (symplectic capacity → certified Lipschitz bounds).

**Bridge: connects tropical geometry to symplectic topology, lattice cryptography, and certified robustness of neural networks.**

---

## Precise Formalization Targets

### Section 1: Tropical Symplectic Vector Spaces

```lean
/-- A tropical symplectic form on a module over a tropical semiring.
    Tropical antisymmetry: ω(x,y) ⊕ ω(y,x) = ⊤ (i.e., min(ω(x,y), ω(y,x)) = +∞),
    meaning at least one of ω(x,y), ω(y,x) is +∞ (the tropical zero).
    Non-degeneracy: if ω(x,y) = ⊤ for all y, then x = 0. -/
structure TropicalSymplecticForm (V : Type*) [AddCommGroup V] [Module (Tropical ℝ) V] where
  form : V → V → Tropical ℝ
  antisymmetry : ∀ x y, min (form x y) (form y x) = ⊤
  -- Tropical zero is +∞, so antisymmetry means at least one direction is "infinitely costly"
  bilinearity_tropical : ∀ (r : Tropical ℝ) (x y : V),
    form (r • x) y = Tropical.trop (Untrop r) + form x y ∧
    form x (r • y) = Tropical.trop (Untrop r) + form x y
  nondegenerate : ∀ x, (∀ y, form x y = ⊤) → x = 0

/-- The tropical symplectic group: linear maps preserving the tropical symplectic form. -/
structure TropicalSymplectomorphism (V : Type*) [AddCommGroup V]
    [Module (Tropical ℝ) V] (ω : TropicalSymplecticForm V) where
  toLinearEquiv : V ≃ₗ[Tropical ℝ] V
  preserves_form : ∀ x y, ω.form (toLinearEquiv x) (toLinearEquiv y) = ω.form x y

/-- Tropical symplectic capacity of a set: the infimum of the tropical
    "symplectic width" over all tropical symplectomorphisms. This is the
    min-plus analogue of Gromov's symplectic capacity, yielding a
    PL-analytic certificate for symplectic rigidity.
    
    Bridge: connects symplectic topology to lattice distortion bounds
    (capacity ≥ c · log(n) gives post-quantum security parameter). -/
noncomputable def tropicalSymplecticCapacity
    (V : Type*) [AddCommGroup V] [Module (Tropical ℝ) V]
    (ω : TropicalSymplecticForm V) (S : Set V) : ℝ≥0 :=
  sInf {c | ∃ (φ : TropicalSymplectomorphism V ω),
    ∀ x ∈ S ∩ φ ⁻¹' S, Untrop (ω.form x x) ≥ c}
```

### Section 2: Min-Plus Action and Tropical Hamilton's Principle

```lean
/-- A tropical Lagrangian: position-velocity pairs map to tropical reals.
    The value L(q,v) represents the "cost" (in min-plus sense) of
    being at position q with velocity v. -/
structure TropicalLagrangian (Q : Type*) [AddCommGroup Q] where
  toFun : Q → Q → Tropical ℝ
  -- Convexity in the tropical sense: the Legendre-Fenchel transform is well-defined
  tropical_convex : ∀ q, ConvexOn ℝ (Set.univ : Set Q) (fun v => Untrop (toFun q v))

/-- The min-plus action: the tropical sum (infimum) of the Lagrangian
    along a path. This is the fundamental object of tropical mechanics.
    
    Bridge: connects variational calculus to min-plus optimization
    (dynamic programming principle). -/
noncomputable def minPlusAction {Q : Type*} [AddCommGroup Q]
    (L : TropicalLagrangian Q) (q : ℝ → Q) (a b : ℝ) : Tropical ℝ :=
  Tropical.trop (⨅ t ∈ Set.Icc a b, Untrop (L.toFun (q t) (derivApprox q t)))

/-- The tropical Hamiltonian: Legendre-Fenchel transform of the
    tropical Lagrangian. In min-plus mechanics, this is literally
    the convex conjugate. -/
noncomputable def tropicalHamiltonian {Q : Type*} [AddCommGroup Q]
    (L : TropicalLagrangian Q) (q : Q) (p : Q →ₗ[Tropical ℝ] Tropical ℝ) : Tropical ℝ :=
  Tropical.trop (⨅ v, Untrop (L.toFun q v) + (p v).untrop)
```

**Theorem 1 (Tropical Hamilton's Principle):**

```lean
/-- TROPICAL HAMILTON'S PRINCIPLE: A path γ is an extremal of the min-plus
    action if and only if it satisfies the tropical Hamilton equations.
    
    In min-plus mechanics, "extremal" means the action achieves its infimum
    (not stationary — tropical derivatives are subdifferentials).
    
    The tropical Hamilton equations are:
      q̇ = ∂⁻H/∂p  (tropical: q̇ minimizes H(q,p) - ⟨p, q̇⟩)
      ṗ = ∂⁻H/∂q  (tropical: ṗ minimizes H(q,p) - ⟨ṗ, q⟩)
    
    Bridge: connects variational mechanics to convex optimization and
    dynamic programming (Bellman equation is the tropical Hamilton-Jacobi). -/
theorem tropical_hamilton_principle {Q : Type*} [AddCommGroup Q] [Module (Tropical ℝ) Q]
    [FiniteDimensional (Tropical ℝ) Q]
    (L : TropicalLagrangian Q) (ω : TropicalSymplecticForm Q)
    (γ : ℝ → Q) (a b : ℝ) :
    (∀ δ, IsMinimizer (minPlusAction L (γ + δ) a b) δ → IsMinimizer (minPlusAction L γ a b) δ) ∧
    (∀ δ, IsMinimizer (minPlusAction L (γ + δ) a b) δ →
      satisfiesTropicalHamiltonEqs L ω γ a b) ↔
    isMinPlusActionExtremal L γ a b ∧
    satisfiesTropicalHamiltonEqs L ω γ a b
```

### Section 3: Tropical Noether Theorem

```lean
/-- A one-parameter tropical symmetry: a family of tropical symplectomorphisms
    parameterized by a tropical real, preserving the tropical Hamiltonian. -/
structure TropicalSymmetry (V : Type*) [AddCommGroup V] [Module (Tropical ℝ) V]
    (ω : TropicalSymplecticForm V) (H : V → Tropical ℝ) where
  param : Tropical ℝ → TropicalSymplectomorphism V ω
  preserves_H : ∀ t x, H ((param t).toLinearEquiv x) = H x
  continuous_param : ContinuousOn (fun t => (param t).toLinearEquiv 0) Set.univ

/-- A tropical conserved quantity: a function that is constant along
    tropical Hamiltonian flow (in the min-plus sense: achieves its
    minimum along the flow). -/
structure TropicalConservedQuantity (V : Type*) [AddCommGroup V]
    [Module (Tropical ℝ) V] (H : V → Tropical ℝ) where
  toFun : V → Tropical ℝ
  min_preserved : ∀ x, IsMinOn (fun t => toFun (tropicalFlow H x t)) Set.univ
  nontrivial : ∃ x y, toFun x ≠ toFun y
```

**Theorem 2 (Tropical Noether):**

```lean
/-- TROPICAL NOETHER THEOREM: There is an order-isomorphism between the
    lattice of one-parameter tropical symmetries and the lattice of
    tropical conserved quantities.
    
    This is STRONGER than classical Noether: the lattice structure is
    preserved (not just a correspondence), because tropical mechanics
    lives in a complete lattice (the tropical semiring is a complete
    lattice under min).
    
    Bridge: connects Noether's theorem to lattice theory and
    post-quantum cryptography (symmetry lattice → security lattice). -/
theorem tropical_noether_order_iso {V : Type*} [AddCommGroup V]
    [Module (Tropical ℝ) V] [FiniteDimensional (Tropical ℝ) V]
    (ω : TropicalSymplecticForm V) (H : V → Tropical ℝ)
    (hH : TropicalHamiltonianSystem V ω H) :
    ∃ (Φ : TropicalSymmetry V ω H → TropicalConservedQuantity V H)
      (Ψ : TropicalConservedQuantity V H → TropicalSymmetry V ω H),
      Function.Bijective Φ ∧ Function.Bijective Ψ ∧
      Function.LeftInverse Ψ Φ ∧ Function.LeftInverse Φ Ψ ∧
      -- Order isomorphism: preserves lattice operations
      ∀ S₁ S₂, Φ (S₁ ⊔ S₂) = (Φ S₁) ⊔ (Φ S₂) ∧
      ∀ S₁ S₂, Φ (S₁ ⊓ S₂) = (Φ S₁) ⊓ (Φ S₂) ∧
      -- Capacity bound: symmetry lattice dimension ≥ capacity
      ∀ S, (Φ S).minValue ≥ tropicalSymplecticCapacity V ω (tropicalOrbit H S)
```

### Section 4: Tropical Non-Squeezing and Cryptographic Capacity

```lean
/-- TROPICAL NON-SQUEEZING THEOREM (Min-Plus Gromov):
    A tropical symplectomorphism cannot map a tropical ball of radius R
    into a tropical cylinder of radius r < R. This gives a PL-analytic
    certificate for symplectic rigidity.
    
    The capacity bound is: c(φ(B_R)) ≥ R - log(dim V) for any
    tropical symplectomorphism φ and tropical ball B_R.
    
    Bridge: connects symplectic topology to lattice-based cryptography
    (capacity ≥ R - log(n) gives post-quantum security lower bound
    against lattice distortion attacks). -/
theorem tropical_gromov_non_squeezing {V : Type*} [AddCommGroup V]
    [Module (Tropical ℝ) V] [FiniteDimensional (Tropical ℝ) V]
    (ω : TropicalSymplecticForm V) (n : ℕ) (hn : Module.finrank (Tropical ℝ) V = n)
    (R r : ℝ) (hRr : R > r) :
    ∀ (φ : TropicalSymplectomorphism V ω),
    ∀ (B_R : Set V) (C_r : Set V),
    isTropicalBall ω B_R R → isTropicalCylinder ω C_r r →
    ¬(φ.toLinearEquiv '' B_R ⊆ C_r) ∧
    tropicalSymplecticCapacity V ω (φ.toLinearEquiv '' B_R) ≥ R - log n
```

---

## Proof Strategies

### Strategy A for Theorem 1 (Tropical Hamilton's Principle): Convex Duality via Legendre-Fenchel

**Most promising.** The key insight is that tropical mechanics IS convex optimization — the Legendre-Fenchel transform IS the tropical Legendre transform.

1. **Lemma `tropical_legendre_involution`**: Prove that the tropical Legendre transform satisfies the involution property `L** = L` for tropically convex Lagrangians. This follows from Fenchel-Moreau in the tropical setting, using the fact that `tropical_convex` in the Lagrangian definition ensures the biconjugate recovers the original.

2. **Lemma `min_plus_action_subdifferential`**: Show that the subdifferential of the min-plus action at a path γ is precisely the set of tropical momentum fields satisfying the tropical Hamilton equations. Key tactic: use `convexOn_iff_epigraph_convex` and the Fenchel-Young inequality in tropical form.

3. **Lemma `tropical_stationary_implies_hamilton`**: If γ minimizes the min-plus action, then the tropical subdifferential at γ contains zero, which by the subdifferential characterization means γ satisfies the tropical Hamilton equations. Use `by_contra` to show violation of minimality.

4. **Lemma `hamilton_implies_minimizer`**: Conversely, if γ satisfies the tropical Hamilton equations, then zero is in the subdifferential of the action at γ, implying γ is a minimizer. Use the tropical convexity of the action functional.

5. **Main theorem**: Combine (3) and (4) using the biconditional structure.

### Strategy B for Theorem 2 (Tropical Noether): Lattice Isomorphism via Tropical Momentum Maps

**Most promising.** The lattice structure of tropical symmetries is the key novelty — it has no classical analogue.

1. **Lemma `tropical_momentum_map`**: Construct the tropical momentum map `μ: TropicalSymmetry V ω H → V → Tropical ℝ` sending a symmetry `S` to the function `x ↦ ω.form (tropicalGenerator S) x`. Prove this is a tropical conserved quantity using the symmetry preservation of H.

2. **Lemma `momentum_map_order_preserving`**: Prove that the momentum map preserves lattice operations: `μ(S₁ ⊔ S₂) = μ(S₁) ⊔ μ(S₂)`. The tropical join `⊔` is `min`, and the momentum map is linear over the tropical semiring, so this follows from `map_add` (since tropical addition is min).

3. **Lemma `momentum_map_bijection`**: Prove the momentum map is bijective. Injectivity: if `μ(S₁) = μ(S₂)`, then the tropical generators are equal, hence the symmetries are equal. Surjectivity: given a tropical conserved quantity, reconstruct the symmetry via the inverse tropical momentum map (using non-degeneracy of ω).

4. **Lemma `capacity_bound_from_symmetry`**: Prove that the capacity of a tropical orbit is bounded below by the minimum value of the corresponding conserved quantity. This connects Noether's theorem to the non-squeezing theorem.

5. **Main theorem**: Compose the bijection and order-preservation lemmas.

### Strategy C for Theorem 3 (Tropical Non-Squeezing): PL-Symplectic Rigidity

1. **Lemma `tropical_symplectic_capacity_ball`**: Compute the tropical symplectic capacity of a tropical ball of radius R: it equals R. This uses the non-degeneracy of ω and the fact that tropical symplectomorphisms are min-plus linear.

2. **Lemma `tropical_cylinder_capacity`**: Show that a tropical cylinder of radius r has tropical symplectic capacity r (in the "squeezed" direction).

3. **Lemma `capacity_monotone_embedding`**: Prove that tropical symplectic capacity is monotone under tropical symplectic embeddings: if `φ` is a tropical symplectomorphism and `A ⊆ B`, then `c(φ(A)) ≤ c(B)`. Wait — this needs to be `c(A) ≤ c(φ(A))` by the capacity-preservation property of symplectomorphisms.

4. **Main theorem**: If `φ(B_R) ⊆ C_r`, then `c(B_R) = c(φ(B_R)) ≤ c(C_r) = r < R = c(B_R)`, contradiction. Use `by_contra` and `linarith` on the capacity values.

5. **Corollary `lattice_distortion_lower_bound`**: Translate the capacity bound into a lattice cryptography lower bound: any linear map preserving tropical symplectic structure satisfies distortion ≥ R - log(n). This connects symplectic topology to post-quantum security of lattice-based schemes.

---

## Specific Computational Bounds and Utility

- **Tropical symplectic capacity bound**: `c(φ(B_R)) ≥ R - log(n)` where `n = dim V`. The `log(n)` term is the "tropical shadow" of the dimension — a purely PL quantity with no smooth analogue.

- **Noether charge lattice bound**: For a tropical Hamiltonian system on an `n`-dimensional tropical phase space, the lattice of tropical symmetries has height at most `n`, and each symmetry contributes a conserved quantity with value ≥ `c / n` where `c` is the tropical symplectic capacity.

- **Lattice distortion bound (cryptographic)**: Any tropical symplectomorphism `φ: ℝ^n → ℝ^n` satisfies `‖φ⁻¹‖₂ / ‖φ‖₂ ≥ exp(R - log n)` for radius `R`, giving a **post-quantum security lower bound** of `Ω(R - log n)` bits against lattice distortion attacks on SIS/LWE-based schemes.

- **Certified Lipschitz bound (ML)**: A tropical symplectic neural network layer has certified Lipschitz constant ≤ `exp(c) / n` where `c` is the tropical symplectic capacity of the input domain, providing **certified robustness certificates** for tropical ReLU networks.

---

## Required Definitions and Structures (Minimum 5)

1. `TropicalSymplecticForm V` — tropical symplectic form with tropical antisymmetry
2. `TropicalSymplectomorphism V ω` — tropical symplectomorphism group
3. `TropicalLagrangian Q` — tropical Lagrangian with convexity condition
4. `TropicalSymmetry V ω H` — one-parameter tropical symmetry
5. `TropicalConservedQuantity V H` — tropical Noether charge
6. `tropicalSymplecticCapacity V ω S` — tropical symplectic capacity (noncomputable)
7. `minPlusAction L γ a b` — min-plus action functional
8. `tropicalHamiltonian L q p` — tropical Hamiltonian via Legendre-Fenchel
9. `isTropicalBall ω S R` — tropical ball of radius R
10. `isTropicalCylinder ω S r` — tropical cylinder of radius r

---

## Theorems to Prove (Minimum 10, Diverse Tactics)

1. `tropical_symplectic_antisymmetry_dual` — tropical antisymmetry implies `ω(x,y) ⊕ ω(y,x) = ⊤` (use `rw`, `unfold`, `Tropical.min_add_equiv`)
2. `tropical_legendre_involution` — Legendre-Fenchel involution for tropically convex Lagrangians (use `convexOn_iff_epigraph_convex`, Fenchel-Moreau)
3. `min_plus_action_subdifferential` — subdifferential of min-plus action = tropical Hamilton equations (use `by_contra`, `convexOn_iff`)
4. `tropical_hamilton_principle` — main theorem: extremal ⟺ tropical Hamilton (use biconditional from (3) and (4))
5. `tropical_momentum_map_order_preserving` — momentum map preserves lattice operations (use `induction` on lattice structure, `omega` for linear arithmetic)
6. `tropical_momentum_map_bijection` — momentum map is bijective (use `rcases` on the inverse, non-degeneracy of ω)
7. `tropical_noether_order_iso` — main theorem: symmetry lattice ≅ charge lattice (compose (5) and (6))
8. `tropical_symplectic_capacity_ball` — capacity of tropical ball = radius (use `field_simp`, `linarith` on tropical arithmetic)
9. `tropical_gromov_non_squeezing` — main theorem: non-squeezing (use `by_contra`, capacity monotonicity, `linarith`)
10. `lattice_distortion_lower_bound` — cryptographic application: distortion ≥ R - log(n) (use `linarith`, `log_le_pow`)
11. `certified_lipschitz_bound_symplectic` — ML application: Lipschitz ≤ exp(c)/n (use `linarith`, Lipschitz composition)
12. `tropical_noether_charge_capacity` — Noether charge ≥ capacity/dim (use `linarith`, lattice height bound)

---

## Revolutionary Significance

This work opens **tropical symplectic geometry** as a new field at the intersection of:

1. **Symplectic topology → Tropical geometry**: The non-squeezing theorem becomes a PL-combinatorial statement about tropical balls and cylinders, provable by linear programming methods.

2. **Noether's theorem → Lattice theory**: The tropical Noether theorem produces a *lattice isomorphism* (not just a correspondence), because the tropical semiring is a complete lattice. This gives Noether's theorem a purely order-theoretic form.

3. **Symplectic rigidity → Post-quantum cryptography**: Tropical symplectic capacity lower bounds translate directly to lattice distortion lower bounds, providing **information-theoretic security guarantees** for SIS/LWE-based post-quantum schemes against symplectic attacks.

4. **Symplectic capacity → Certified robustness**: Tropical symplectic capacity gives **certified Lipschitz bounds** for tropical neural network layers, enabling formal verification of robustness against adversarial attacks.

5. **Maslov dequantization → Idempotent mechanics**: The limit `h → +∞` in `min(x + h·log|a|, y + h·log|b|)` deforms classical symplectic mechanics to tropical symplectic mechanics, making this a true "classical limit" of tropical mechanics.

---

## FUTURE_DIRECTIONS

Aristotle must produce a structured FUTURE_DIRECTIONS.md with:

1. **Tropical Gromov-Witten invariants**: Define min-plus analogues of Gromov-Witten invariants via tropical symplectic capacity, connecting to enumerative combinatorics and mirror symmetry.

2. **Tropical Hamilton-Jacobi and Bellman equation**: Prove that the tropical Hamilton-Jacobi equation IS the Bellman equation from dynamic programming, opening tropical symplectic mechanics to optimal control and reinforcement learning.

3. **Post-quantum security from tropical non-squeezing**: Formalize the reduction from tropical symplectic capacity to SIS/LWE hardness, producing verified security bounds for lattice-based cryptography.

4. **Tropical moment maps and tropical geometric invariant theory**: Develop tropical analogues of symplectic reduction and Marsden-Weinstein quotient, connecting to tropical moduli spaces.

5. **Certified robustness of tropical symplectic neural networks**: Use tropical symplectic capacity to produce verified Lipschitz bounds for tropical neural ODEs, enabling certified adversarial robustness.

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
            Open the field of tropical symplectic geometry by proving three foundational theorems that establish min-plus analogues of the three pillars of classical symplectic mechanics. Theorem 1 (Min-Plus Hamilton's Principle): Every extremal path of the min-plus action functional satisfies the tropical Hamilton equations, and conversely, every solution of the tropical Hamilton equations is an extremal of the min-plus action. Theorem 2 (Tropical Noether Theorem): For every one-parameter tropical symmetry of a min-plus Hamiltonian system, there exists a conserved tropical quantity, establishing an order-isomorphism between the lattice of tropical symmetries and the lattice of tropical conserved quantities. Theorem 3 (Idempotent Symplectic Capacity): Tropical symplectomorphisms preserve the tropical symplectic capacity, yielding a min-plus analogue of Gromov's non-squeezing theorem for piecewise-linear symplectic maps on tropical phase space.

            ### Precise Mathematical Framing
            Classical symplectic geometry studies phase spaces (T*M, ω) where ω is a closed non-degenerate 2-form. The Maslov dequantization h→0 transforms classical symplectic geometry into tropical symplectic geometry: the symplectic form ω = Σ dxᵢ ∧ dyᵢ dequantizes to the min-plus symplectic pairing ω_trop(x,y) = minᵢ(xᵢ ⊕ yᵢ) where ⊕ = min, the Hamiltonian H dequantizes to the tropical Hamiltonian H_trop(x) = minⱼ(aⱼ + ⟨αⱼ, x⟩) (a tropical polynomial), and Hamilton's equations ṗ = -∂H/∂q, q̇ = ∂H/∂p become piecewise-linear dynamical systems on tropical phase space (R^n, min, +). The key insight is that the idempotent semiring (R ∪ {∞}, min, +) supports a complete symplectic geometry where: (1) the min-plus action S_trop[γ] = min_γ L_trop dt satisfies a variational principle with tropical Euler-Lagrange equations, (2) tropical symmetries (piecewise-linear flows preserving H_trop) correspond to tropical conservation laws via an idempotent Noether correspondence: Sym_trop(H) ≅ Cons_trop(H) as complete lattices, and (3) tropical symplectomorphisms (min-plus canonical transformations) preserve a tropical symplectic capacity c_trop satisfying c_trop(B_R) = R and c_trop(Z_r) = r, establishing the tropical non-squeezing theorem. This creates a new field at the intersection of tropical geometry (3224 catalog declarations), symplectic/differential geometry (587 geometry declarations), and mathematical physics (650 physics declarations), with direct applications to optimal control (min-plus Hamilton-Jacobi-Bellman equation), tropical integrable systems, and piecewise-linear mechanics.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `tropical_plus_distributes_over_min` : theorem tropical_plus_distributes_over_min (a b c : ℝ) :
     (file: Bridges/MinPlusVerificationCore.lean)
  2. `tropical_lattice_dimension_bound` : theorem tropical_lattice_dimension_bound (n : ℕ) (hn : 8 ≤ n) :
     (file: Bridges/ProofAlgGeomBridge.lean)
  3. `noether_symmetry_conservation` : theorem noether_symmetry_conservation (R : Type*) [CommRing R]
     (file: Bridges/AlgebraicSpacetime.lean)
  4. `tropical_max_idempotent` : theorem tropical_max_idempotent (x : ℝ) : max x x = x := max_self x
     (file: Bridges/BreakthroughDirections.lean)
  5. `EMLd_eq_one_plus_selfInfo` : theorem EMLd_eq_one_plus_selfInfo (p : ℝ) :
     (file: Bridges/EMLDensityBridge.lean)

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



Recent successful concepts: EML Quantum Stabilizer Theory: Closure-Operator Stabilizer Correspondence, Knaster-Tarski Codespace Certification, and Idempotent Recovery Concatenation, Gravitational Factoring: Idempotent Spectral Lensing, Causal Prime Decomposition, and Ring-Theoretic Factorization Certification, Min-Plus Verification Theory: ReLU Network Isomorphism, Polytope Certified Radii, and Verification Completeness


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician, software engineer, and science writer.
            Create ALL of the following:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **ARTICLE.md** — MANDATORY standalone popular-science article
               CRITICAL RULES:
               • Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
               • Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
               • This is a premier magazine-quality piece for curious, intelligent readers.
               QUALITY STANDARDS:
               • Superb, vivid, engaging prose with a strong opening hook and narrative arc.
               • Concrete analogies and metaphors that make abstract ideas tangible.
               • Story structure: provocative question → tension → breakthrough → significance.
               • Real-world connections: technology, nature, everyday life.
               • Historical context: place the work in the sweep of intellectual history.
               • 1500–3000 words. Substantial, standalone, enjoyable, interesting.
               • A reader should say "Wow, I had no idea math could do THAT."

            3. **RESEARCH_PAPER.md** — MANDATORY comprehensive, in-depth research paper
               This is a full, publishable-quality paper, NOT a summary:
               • Abstract, Introduction, Definitions & Notation
               • Main Results with detailed proof sketches (not just "by induction")
               • Algorithms with complete pseudocode and complexity analysis
               • Applications with worked examples showing practical use
               • Computational Experiments with tables, charts, numerical results
               • Discussion, Future Work, References
               • 3000–8000 words. Thorough and substantive.

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale

               ## Under-explored Territory
               ## Cross-Domain Bridges
               ## Open Problems Encountered

            5. **Python code** — demos, visualizations, algorithms, applications:
               - **demo.py** — concrete numerical examples bringing the math to life
               - **visualizations** — matplotlib/plotly charts (save as PNG/SVG too)
               - **algorithms.py** — implement algorithms from the paper with docstrings
               - **applications.py** — real-world applications (ML, crypto, physics)

            6. **diagram.svg** — visualization of key mathematical structures

            7. **PACKAGE.html** — MANDATORY standalone HTML package
               Bundle ALL artifacts into a single, self-contained HTML file:
               • Everything inlined (CSS, JS, content). No external dependencies.
               • Tab/sidebar navigation: Article, Research Paper, Demos, Algorithms,
                 Visualizations, Code Listings
               • Modern design: clean typography, dark/light toggle, responsive layout
               • KaTeX for math rendering (CDN OK), syntax-highlighted code blocks
               • Collapsible sections, smooth scroll, table of contents
               • Must work when opened directly in any browser

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


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
• Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
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

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — Standalone HTML Package  →  PACKAGE.html
────────────────────────────────────────────────────────────────────────────
Create a **single, self-contained HTML file** that bundles ALL artifacts
into a beautiful, interactive presentation. Requirements:

• **Single file**: Everything (CSS, JS, content) inlined. No external deps.
• **Navigation**: Sidebar or tab navigation between sections:
  - Article (the popular-science piece)
  - Research Paper (the full paper)
  - Interactive Demos (embedded Python output / JS visualizations)
  - Algorithms (pseudocode + implementation)
  - Visualizations (embedded charts/diagrams as inline SVG or base64)
  - Code Listings (syntax-highlighted Python and proof code)
• **Beautiful design**: Modern, clean typography (system fonts).
  Dark/light mode toggle. Responsive layout. Smooth transitions.
• **Math rendering**: Use KaTeX (CDN link OK for math rendering only)
  for any mathematical notation.
• **Syntax highlighting**: Inline code highlighting for Python blocks.
• **Interactive elements**: Collapsible sections, smooth scroll, TOC.
• The HTML package should work when opened directly in any browser.
• Include ALL content from the article, research paper, and code.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: prove
