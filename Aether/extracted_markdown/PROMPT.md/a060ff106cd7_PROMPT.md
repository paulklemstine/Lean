

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

## YOUR ASSIGNMENT: Thermodynamic Closure Theory — Landauer Closure Invariants, Idempotent Reversibility Certification, and Entropy Fixed-Point Convergence

**DOMAIN**: Bridges (EML Closure Theory ↔ Thermodynamics ↔ Reversible Computation ↔ Post-Quantum Cryptography)

**CONCEPT**: Open the field of *thermodynamic closure theory* by establishing that EML closure operators carry intrinsic thermodynamic invariants satisfying Landauer's bound, that reversibility of computation is decidable via idempotency of transition closures, and that iterated Landauer closures converge exponentially to entropy fixed points. This creates a certified decision procedure for thermodynamic reversibility with explicit complexity bounds, directly impacting post-quantum lattice security (reversible circuits resist side-channel attacks) and certified robustness in neural network verification (closure operators on ReLU lattices).

---

### STRUCTURE 1: Thermodynamic Lattice and Landauer Defect

```lean
/-- A thermodynamic lattice equips a complete lattice with a Boltzmann entropy
    functional and thermal unit k_B T. Bridge: connects order theory to
    statistical mechanics. -/
class ThermodynamicLattice (L : Type*) extends CompleteLattice L where
  boltzmann_entropy : L → ℝ
  thermal_unit : ℝ  -- k_B T in natural units
  thermal_unit_pos : 0 < thermal_unit
  entropy_monotone : ∀ {x y : L}, x ≤ y → boltzmann_entropy x ≤ boltzmann_entropy y
  entropy_strict_above_bottom : ∀ {x : L}, x ≠ ⊥ → boltzmann_entropy ⊥ < boltzmann_entropy x

/-- The Landauer defect of a closure operator C at x measures the
    logarithmic information destroyed by closing x. This is the
    codimension of the fiber C⁻¹(C(x)) relative to the closure image. -/
def landauer_defect {L : Type*} [Fintype L] [DecidableEq L]
    [ThermodynamicLattice L] (C : L → L) (x : L) : ℝ :=
  Real.log (Fintype.card {y : L // C y = C x}) / Real.log 2

/-- A closure operator is Landauer-minimal if it achieves equality in
    Landauer's bound at every non-fixed point. -/
def IsLandauerMinimal {L : Type*} [Fintype L] [DecidableEq L]
    [ThermodynamicLattice L] (C : L → L) [IsEMLClosureOperator C] : Prop :=
  ∀ x : L, C x ≠ x →
    boltzmann_entropy (C x) - boltzmann_entropy x =
      thermal_unit * Real.log 2 * landauer_defect C x
```

**Theorem 1 (Landauer Closure Thermodynamic Bound)**:
```lean
/-- Bridge: connects EML closure operators to Landauer's thermodynamic
    principle. Every EML closure operator on a finite thermodynamic lattice
    satisfies Landauer's bound: the entropy increase from closing x is at
    least k_B T ln(2) times the Landauer defect (the bit-measure of
    information destroyed by the closure fiber). -/
theorem landauer_closure_thermodynamic_bound
    (L : Type*) [Fintype L] [DecidableEq L] [ThermodynamicLattice L]
    (C : L → L) [IsEMLClosureOperator C] (x : L) :
    boltzmann_entropy (C x) - boltzmann_entropy x ≥
      thermal_unit * Real.log 2 * landauer_defect C x := by
  -- PROOF STRATEGY:
  -- Step 1: Show |C⁻¹(C(x))| ≥ 2 when C(x) ≠ x (by extensivity: x ∈ C⁻¹(C(x)),
  --   and x ≠ C(x) gives at least 2 elements in the fiber)
  -- Step 2: Apply entropy_strict_above_bottom and entropy_monotone to get
  --   S(C(x)) - S(x) > 0 when C(x) ≠ x
  -- Step 3: Use Fintype.card fiber ≥ 2 to get landauer_defect ≥ 1
  -- Step 4: Combine: S(C(x)) - S(x) ≥ thermal_unit * ln(2) * 1
  --   when landauer_defect = 0 (C(x) = x), both sides are 0 by idempotency
  sorry
```

**Proof strategy for `landauer_closure_thermodynamic_bound`**:
1. **Fiber cardinality lemma**: Prove `closure_fiber_card_ge_two`: When `C x ≠ x`, the set `{y : L // C y = C x}` has cardinality ≥ 2, since `x ∈ {y // C y = C x}` (by idempotency `C(C x) = C x`) and the distinct element `C x` is also in the fiber.
2. **Entropy separation lemma**: Prove `entropy_closure_separation`: For `x ≠ C x`, `boltzmann_entropy (C x) - boltzmann_entropy x > 0` using `entropy_monotone` applied to extensivity `x ≤ C x` and the strict inequality from `entropy_strict_above_bottom`.
3. **Defect lower bound**: Prove `landauer_defect_pos`: When `C x ≠ x`, `landauer_defect C x ≥ 1` since `Fintype.card {y // C y = C x} ≥ 2` implies `log₂(card) ≥ 1`.
4. **Main bound assembly**: Combine Steps 2–3 with `thermal_unit_pos` to get `S(C x) - S(x) ≥ thermal_unit * ln(2) * 1 ≥ thermal_unit * ln(2) * landauer_defect C x` (since defect ≥ 1 when `C x ≠ x`, and both sides are 0 when `C x = x`).

---

### STRUCTURE 2: Transition Closure and Reversibility Certification

```lean
/-- The forward orbit closure of an order-endomorphism f.
    cl_f(x) = sup {f^n(x) : n ≥ 0}. Bridge: connects dynamical systems
    to EML closure theory. -/
def transition_closure {L : Type*} [CompleteLattice L] [Fintype L]
    (f : L → L) (hf : ∀ x y : L, x ≤ y → f x ≤ f y) (x : L) : L :=
  sSup (Set.range (fun n : Fin (Fintype.card L + 1) => f^[n.val] x))

/-- The transition closure of an order-endomorphism is an EML closure
    operator. -/
instance transition_closure_is_EML
    (L : Type*) [CompleteLattice L] [Fintype L]
    (f : L → L) (hf : ∀ x y : L, x ≤ y → f x ≤ f y) :
    IsEMLClosureOperator (transition_closure f hf) where
  extensive := by -- f^0(x) = x ∈ orbit, so x ≤ sup(orbit)
    sorry
  monotone := by -- if x ≤ y then f^n(x) ≤ f^n(y) for all n, so sup ≤ sup
    sorry
  idempotent := by -- by finiteness, orbit stabilizes, so sup of sup-orbit = sup
    sorry

/-- A computation is thermodynamically reversible iff its transition
    closure is idempotent (equivalently, an automorphism). This provides
    a certified reversibility test in O(n²) time for finite lattices. -/
theorem reversibility_idempotency_duality
    (L : Type*) [CompleteLattice L] [Fintype L] [DecidableEq L]
    (f : L → L) (hf : ∀ x y : L, x ≤ y → f x ≤ f y) :
    Function.Bijective f ↔
      IsIdempotent (transition_closure f hf) := by
  -- PROOF STRATEGY:
  -- (→): If f is bijective, it's an automorphism. Then f^[n] permutes L,
  --   so transition_closure f = f, which is idempotent iff f∘f = f, but
  --   actually we need: f bijective + order-preserving → f = f⁻¹ (automorphism)
  --   → cl_f = f → f∘f = f only if f = id. So we need a different approach.
  --   Actually: f bijective order-endomorphism on finite lattice → f is
  --   order-automorphism. The orbit closure cl_f(x) = sup{f^n(x)} but since
  --   f permutes L, f^n cycles, so cl_f(x) = sup of cycle containing x.
  --   Then cl_f(cl_f(x)) = cl_f(x) since sup of cycle is a fixed point.
  -- (←): If cl_f is idempotent, then every element reaches a fixed point
  --   under iteration. If cl_f is also an automorphism, then f must be
  --   bijective. Key lemma: idempotent closure that is also injective = identity.
  sorry
```

**Proof strategy for `reversibility_idempotency_duality`**:
1. **Forward orbit stabilization**: Prove `orbit_stabilizes`: For any `x : L` and order-endomorphism `f` on a finite lattice of size `n`, `f^[n](x) = f^[m](x)` for some `m < n ≤ n`. This uses pigeonhole on `Fin (n+1)`.
2. **Bijective → automorphism**: Prove `order_bijection_automorphism`: A bijective order-endomorphism on a finite lattice is an order-automorphism (its inverse is also order-preserving).
3. **Automorphism → idempotent closure**: Prove `automorphism_closure_idempotent`: If `f` is an order-automorphism, then `transition_closure f hf` equals `f` restricted to cycles, and is idempotent because `sup{f^n(x) : n ∈ cycle}` is a fixed point of `transition_closure`.
4. **Idempotent closure → bijective**: Prove `idempotent_closure_bijection`: If `transition_closure f hf` is idempotent, then every orbit converges to a fixed point. By the Knaster-Tarski structure, these fixed points form a complete lattice. Injectivity of `f` follows from the orbit structure being a permutation on non-fixed elements.
5. **Complexity bound**: Prove `reversibility_certification_complexity`: The reversibility test `IsIdempotent (transition_closure f hf)` can be verified in `O(n²)` where `n = Fintype.card L`, since checking idempotency requires evaluating `cl_f(cl_f(x)) = cl_f(x)` for all `x`, each evaluation being `O(n)`.

---

### STRUCTURE 3: Entropy Fixed-Point Convergence (Discrete H-Theorem)

```lean
/-- The incidence matrix of a closure operator C on a finite lattice.
    M[i,j] = 1 if C(j) = i, 0 otherwise. Bridge: connects EML closure
    operators to spectral graph theory. -/
def closure_incidence_matrix {L : Type*} [Fintype L] [DecidableEq L]
    [CompleteLattice L] (C : L → L) : Matrix (Fin (Fintype.card L)) (Fin (Fintype.card L)) ℝ :=
  -- Constructed via enumeration of L
  sorry

/-- The spectral gap of a closure operator, defined as the difference
    between the two largest eigenvalues of its incidence matrix. -/
def closure_spectral_gap {L : Type*} [Fintype L] [DecidableEq L]
    [CompleteLattice L] (C : L → L) : ℝ :=
  sorry  -- λ₁ - λ₂ of closure_incidence_matrix C

/-- The Landauer closure operator: E_C(x) = C(x) ∨ ⊥ₜ where ⊥ₜ is the
    thermal ground state. When C is already extensive, E_C = C on non-bottom
    elements. Bridge: connects lattice operators to thermodynamic relaxation. -/
def landauer_closure {L : Type*} [CompleteLattice L]
    [ThermodynamicLattice L] (C : L → L) (x : L) : L :=
  C x ⊔ ⊥  -- Reduces to C x since ⊥ ≤ C x by extensivity; but on a
            -- thermodynamic lattice, we use thermal_unit to define a
            -- "thermal bottom" that lifts C

/-- The iterated Landauer closure E_C^n converges exponentially to the
    unique fixed point x* = E_C(x*), with rate governed by the spectral gap.
    This is a discrete H-theorem for EML closure dynamics.
    Bridge: connects Boltzmann H-theorem to order-theoretic fixed points. -/
theorem entropy_fixed_point_convergence
    (L : Type*) [Fintype L] [DecidableEq L] [ThermodynamicLattice L]
    (C : L → L) [IsEMLClosureOperator C]
    (hC : closure_spectral_gap C > 0)
    (x : L) :
    ∃! x* : L, landauer_closure C x* = x* ∧
      ∀ n : ℕ,
        dist (landauer_closure^[n] x) x* ≤
          (1 - closure_spectral_gap C)^n * dist x x* := by
  -- PROOF STRATEGY:
  -- Step 1: Apply Knaster-Tarski to get unique fixed point of landauer_closure
  -- Step 2: Show landauer_closure is a contraction w.r.t. spectral metric
  -- Step 3: Use Banach fixed-point theorem adapted to finite lattice
  -- Step 4: Derive explicit rate from spectral gap
  sorry
```

**Proof strategy for `entropy_fixed_point_convergence`**:
1. **Knaster-Tarski fixed point**: Prove `landauer_closure_has_unique_fixed_point`: By Knaster-Tarski, the set of fixed points of `landauer_closure C` forms a complete lattice. Since `C` is extensive and monotone, `landauer_closure C` has a least fixed point and a greatest fixed point. Uniqueness follows from the spectral gap condition (contraction).
2. **Contraction property**: Prove `landauer_closure_contraction`: For any `x, y : L`, `dist (landauer_closure C x) (landauer_closure C y) ≤ (1 - gap) * dist x y`, where `gap = closure_spectral_gap C`. This follows from the Perron-Frobenius theorem applied to `closure_incidence_matrix C`.
3. **Banach iteration**: Prove `banach_iteration_convergence`: For a contraction `T` with Lipschitz constant `λ < 1`, `T^n(x) → x*` with `dist(T^n(x), x*) ≤ λ^n * dist(x, x*)`. Apply with `T = landauer_closure C` and `λ = 1 - gap`.
4. **Explicit rate derivation**: Combine the contraction rate with the spectral gap to get `d(E^n(x), x*) ≤ (1 - gap(C))^n · d(x, x*)`, giving an `O((1-gap)^n)` convergence rate.

---

### STRUCTURE 4: Certified Reversibility for Post-Quantum Lattice Circuits

```lean
/-- A lattice circuit over a finite field F_q, relevant to post-quantum
    cryptography (e.g., Kyber, Dilithium). Bridge: connects EML closure
    theory to post-quantum lattice security. -/
structure LatticeCircuit (q : ℕ) [hq : Fact (0 < q)] where
  gates : List (Matrix (Fin d) (Fin d) (ZMod q))  -- d determined by context
  -- Each gate is a linear map over ZMod q

/-- A lattice circuit is side-channel resistant iff its transition closure
    is Landauer-minimal (minimal information leakage per Landauer's bound).
    This provides certified_robustness against power-analysis attacks. -/
def IsSideChannelResistant {q : ℕ} [Fact (0 < q)] [Fintype (ZMod q)]
    (C : LatticeCircuit q) : Prop :=
  IsLandauerMinimal (transition_closure C.toFunction C.monotone)

/-- Bridge: connects reversibility certification to post-quantum lattice
    security. A reversible lattice circuit with Landauer-minimal closure
    has certified side-channel resistance with O(q^d) security parameter. -/
theorem certified_reversibility_post_quantum_security
    (q : ℕ) [Fact (0 < q)] [Fintype (ZMod q)] (d : ℕ)
    (C : LatticeCircuit q) (hR : Function.Bijective C.toFunction)
    (hM : IsSideChannelResistant C) :
    ∃ (K : ℝ), K > 0 ∧
      ∀ (adversary : ZMod q^(d²) → Bool),
        -- Advantage of any quantum adversary in distinguishing
        -- C from a random permutation is bounded by K * q^(-d/2)
        True := by  -- Placeholder; the real statement uses quantum distinguishing advantage
  sorry
```

---

### STRUCTURE 5: Neural Network Certified Robustness via Closure

```lean
/-- A ReLU lattice is a finite sublattice of ℝ^n induced by ReLU activations.
    Bridge: connects EML closure theory to certified_robustness in ML. -/
structure ReLULattice (n : ℕ) where
  points : Finset (Fin n → ℝ)
  lattice_closed : ∀ x y ∈ points, x ⊔ y ∈ points ∧ x ⊓ y ∈ points

/-- The ReLU closure operator on a ReLU lattice: C(W, x) = sup{y ∈ points |
    y ≤ W · x} where W is a weight matrix. This is an EML closure operator. -/
def relu_closure {n : ℕ} (L : ReLULattice n) (W : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) : Fin n → ℝ :=
  sSup {y ∈ L.points | ∀ i, y i ≤ (W.mulVec x) i}

/-- Certified Lipschitz robustness: If C is the ReLU closure with spectral
    gap γ, then any perturbation δ with ‖δ‖ < γ/(2L) where L is the
    Lipschitz constant of the network, cannot change the classification.
    Bridge: connects closure spectral theory to certified_robustness. -/
theorem certified_lipschitz_robustness_closure
    (n : ℕ) (L : ReLULattice n) (W : Matrix (Fin n) (Fin n) ℝ)
    (hW : IsEMLClosureOperator (relu_closure L W))
    (γ : ℝ) (hγ : closure_spectral_gap (relu_closure L W) = γ)
    (lip_const : ℝ) (hlip : lip_const > 0)
    (x : Fin n → ℝ) (δ : Fin n → ℝ)
    (hδ : ‖δ‖ ≤ γ / (2 * lip_const)) :
    -- Classification at x is unchanged under perturbation δ
    -- (formalized as: closure image doesn't cross a decision boundary)
    relu_closure L W x = relu_closure L W (x + δ) ∨
      dist (relu_closure L W x) (relu_closure L W (x + δ)) < lip_const * ‖δ‖ := by
  sorry
```

---

### MANDATORY THEOREMS (10+ with diverse tactics)

Prove ALL of the following. Use `induction`, `rcases`, `by_contra`, `omega`, `linarith`, `field_simp`, `simp` strategically — NOT as crutches. ZERO `sorry` in final output.

1. **`landauer_defect_nonneg`**: `∀ C x, landauer_defect C x ≥ 0` (use `linarith` on log-cardinality)
2. **`landauer_defect_zero_iff_fixed`**: `landauer_defect C x = 0 ↔ C x = x` (use `by_contra` + `omega`)
3. **`closure_fiber_card_ge_two`**: `C x ≠ x → Fintype.card {y // C y = C x} ≥ 2` (use `Finset.card_le_card` + extensivity)
4. **`transition_closure_extensive`**: `∀ x, x ≤ transition_closure f hf x` (use `le_sUp` + `Set.mem_range`)
5. **`transition_closure_monotone`**: `x ≤ y → transition_closure f hf x ≤ transition_closure f hf y` (use `sSup_le_sSup` + monotonicity of `f`)
6. **`transition_closure_idempotent_of_bijective`**: `Function.Bijective f → transition_closure f hf ∘ transition_closure f hf = transition_closure f hf` (use `induction` on orbit length + `Fintype.card` pigeonhole)
7. **`orbit_stabilizes`**: `∃ m n, m < n ∧ n ≤ Fintype.card L ∧ f^[m] x = f^[n] x` (use `by_contra` + pigeonhole)
8. **`entropy_closure_separation`**: `C x ≠ x → boltzmann_entropy (C x) > boltzmann_entropy x` (use `ThermodynamicLattice.entropy_strict_above_bottom` + `by_contra`)
9. **`landauer_closure_thermodynamic_bound`**: The main theorem (use Steps 1–4 above)
10. **`landauer_minimal_iff_reversible`**: `IsLandauerMinimal C ↔ ∀ x, C x = x ∨ Fintype.card {y // C y = C x} = 2` (use `field_simp` + `linarith` on log expressions)
11. **`reversibility_idempotency_duality`**: The main duality theorem (use Steps 1–5 above)
12. **`certified_reversibility_complexity`**: Reversibility test via idempotency runs in `O(n²)` where `n = Fintype.card L` (use `Finset.sum_card` + `List.length`)
13. **`entropy_fixed_point_convergence`**: The main convergence theorem (use Banach fixed-point + spectral gap)
14. **`convergence_rate_explicit`**: `∀ n, dist (E^[n] x) x* ≤ (1 - γ)^n * dist x x*` where `γ = closure_spectral_gap C` (use `induction` on `n` + contraction inequality)

---

### MANDATORY DEFINITIONS (5+)

1. `ThermodynamicLattice L` — class extending `CompleteLattice` with entropy and thermal unit
2. `landauer_defect C x` — the bit-measure of information destroyed by closure
3. `IsLandauerMinimal C` — equality in Landauer's bound
4. `transition_closure f hf` — forward orbit closure as EML closure operator
5. `closure_incidence_matrix C` — spectral object governing convergence rate
6. `closure_spectral_gap C` — gap between two largest eigenvalues
7. `LatticeCircuit q` — finite-field lattice circuit for post-quantum crypto
8. `IsSideChannelResistant C` — Landauer-minimal reversibility (crypto security)
9. `ReLULattice n` — finite sublattice for neural certified robustness
10. `relu_closure L W` — ReLU-induced EML closure operator

---

### FUTURE_DIRECTIONS.md

Aristotle MUST produce a `FUTURE_DIRECTIONS.md` with 3–5 concrete breakthrough-level next steps:

1. **Tropical Landauer Theory**: Extend `landauer_defect` to tropical semirings (min-plus algebra) where `boltzmann_entropy` becomes tropical entropy (min-plus logarithmic). Prove a *tropical Landauer bound*: `trop_entropy(C(x)) - trop_entropy(x) ≥ ρ(C,x)` in the tropical semiring. This connects to `tropical_hash_collision` resistance in post-quantum cryptography.

2. **Quantum Closure Operators**: Define `QuantumClosure` on Hilbert lattice of projection operators. Prove that `IsLandauerMinimal` for quantum closures corresponds to unitary evolution (no information loss), establishing a *quantum reversibility certification* via EML closure theory.

3. **Neural Network Certified Robustness via Spectral Gap**: Extend `certified_lipschitz_robustness_closure` to deep ReLU networks by composing closure operators layer-by-layer. Prove that the spectral gap of the composed closure gives a *certified robustness radius* `r* = gap/(2L)` where `L` is the network Lipschitz constant, advancing the state-of-the-art in ML verification.

4. **Thermodynamic Complexity Classes**: Define `TC⁰_Landauer` as the class of languages decidable by circuits with Landauer-minimal closures. Prove `TC⁰_Landauer ⊆ NC¹` by showing that idempotent closure computation parallelizes via the spectral gap convergence rate.

5. **Post-Quantum Lattice Side-Channel Resistance**: Prove that Kyber/Dilithium-style lattice circuits satisfy `IsSideChannelResistant` when their transition closures have spectral gap `γ > 1/poly(n)`. This would give the first *certified post-quantum security* bound against power-analysis side channels grounded in thermodynamic closure theory.

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
            Open the field of thermodynamic closure theory by proving three foundational theorems that bridge EML closure operators, Landauer's thermodynamic principle, and reversible computation: (1) Landauer Closure Theorem — For any complete lattice L of computational states with bottom ⊥ and EML closure operator C, the Landauer closure E_C(x) = C(x) ∨ ⊥ is itself a closure operator, and the entropy increase satisfies S(E_C(x)) - S(x) ≥ k_B T ln(2) · ρ(C,x) where ρ is the closure rank defect, establishing Landauer's principle as a closure-theoretic invariant. (2) Reversibility-Idempotency Duality — A deterministic computation f: L → L on a finite lattice is thermodynamically reversible if and only if its transition closure cl_f is idempotent (cl_f ∘ cl_f = cl_f), equivalently cl_f is a lattice automorphism, yielding an EML-theoretic decision procedure for reversibility certification. (3) Entropy Fixed-Point Convergence — The iterated Landauer closure E_C^n(x) converges exponentially to the unique fixed point x* = E_C(x*) with rate governed by the spectral gap of the closure's incidence matrix: d(E_C^n(x), x*) ≤ λ^n · d(x, x*) for λ = 1 - gap(C) < 1, providing a discrete H-theorem for EML closure dynamics.

            ### Precise Mathematical Framing
            Given a complete lattice (L, ≤) with bottom element ⊥ and an EML closure operator C: L → L (satisfying x ≤ C(x), C(C(x)) = C(x), and monotonicity), define the Landauer closure E_C(x) = C(x) ∨ ⊥. The lattice entropy is S(x) = k_B · ln(|↓x|) where ↓x = {y ∈ L : y ≤ x}. The closure rank defect ρ(C,x) = rank(E_C(x)) - rank(x) measures information destroyed by erasure. Theorem 1 proves E_C is a closure operator and S(E_C(x)) - S(x) ≥ k_B T ln(2) · ρ(C,x), making Landauer's bound a consequence of EML idempotency. Theorem 2 establishes that cl_f idempotent ⟺ f reversible ⟺ cl_f ∈ Aut(L), connecting EML fixed-point theory to thermodynamic reversibility. Theorem 3 proves exponential convergence E_C^n → x* with rate λ = 1 - gap(∂C), yielding a lattice-theoretic H-theorem: S(E_C^{n+1}(x)) - S(E_C^n(x)) ≤ λ^n · ΔS_0.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `constant_unique_fixed_point` : theorem constant_unique_fixed_point (c : ℝ) :
     (file: Bridges/Advanced.lean)
  2. `EMLSelfMap_unique_fixed_point` : theorem EMLSelfMap_unique_fixed_point (x : ℝ) (hx : 0 < x) (hfp : EMLSelfMap x = x) :
     (file: Bridges/EMLDensityBridge.lean)
  3. `finite_idempotent_fixed_point` : theorem finite_idempotent_fixed_point {α : Type*} [Finite α] [Nonempty α]
     (file: Speculative/Other/NewHypothesesResearch.lean)
  4. `unique_beatpath_winner_stable_of_half_gap` : theorem unique_beatpath_winner_stable_of_half_gap
     (file: Bridges/BeatpathRobustness.lean)
  5. `boolean_thermodynamic_elimination_duality` : theorem boolean_thermodynamic_elimination_duality (Γ : Finset α) (y : α) (φ : α) :
     (file: Bridges/BooleanThermodynamicEliminationDuality.lean)

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



Recent successful concepts: Antipode Uniqueness and Deterministic Birkhoff Decomposition: Unambiguous Renormalization Prescriptions from Convolution-Inverse Uniqueness in Graded Hopf Algebras, Symplectic Cryptography: Symplectic Group One-Way Functions, Alternating-Form Hash Commitments, and Liouville Zero-Knowledge Proofs, Homological Deep Learning: Ext-Group Feature Obstructions, Long Exact Learning Bounds, and Depth-Wise Homological Convergence


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

Research domain: Bridges
Research mode: prove
