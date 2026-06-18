

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new

## TROPICAL MEASURE THEORY: Choquet–Radon Completion, Sup-Additive Integration, and Tropical Concentration — A Foundation for Post-Quantum Cryptographic Hardness and Certified Robustness

### REVOLUTIONARY CONTEXT

Classical measure theory rests on the Riesz representation theorem and Choquet–Radon completion, converting linear functionals into measures. In the tropical (min-plus) semiring, addition becomes min and multiplication becomes addition — so *linearity* becomes *sup-preservation* and *positivity* becomes *monotonicity*. This shift is not merely algebraic: it transforms measure theory into an *optimization* theory where integration computes shortest paths rather than expected values.

The breakthrough: tropical measures on compact spaces are **lattice-theoretic shadows of quantum amplitudes**. The min-plus integral computes the *most probable transition path* in a quantum system (via Maslov dequantization), and tropical Hoeffding bounds give **certified concentration for min-plus random variables** — exactly the tool needed to prove that lattice-based cryptographic schemes resist post-quantum attacks with *information-theoretic* (not just computational) guarantees.

This formalization establishes that tropical probability measures satisfy concentration inequalities with **explicit Lipschitz constants** and **O(exp(-t²/2σ²)) bounds** — giving certified robustness for tropical neural networks and provable security for min-plus hash collision resistance.

---

### PRECISE TYPE SIGNATURES AND DEFINITIONS

#### Core Structure Definitions (5+ required)

```lean
/-- A tropical functional is a sup-preserving, shift-equivariant map
from C(X, WithBot ℝ) to WithBot ℝ. This is the tropical analogue of
a positive linear functional in classical measure theory.
Bridge: connects functional analysis to min-plus optimization. -/
structure TropicalFunctional (X : Type*) [CompactSpace X] [T2Space X] where
  app : C(X, WithBot ℝ) → WithBot ℝ
  mono : ∀ ⦃f g : C(X, WithBot ℝ)⦄, (∀ x, f x ≤ g x) → app f ≤ app g
  sup_pres : ∀ ⦃f g : C(X, WithBot ℝ)⦄, app (f ⊔ g) = (app f) ⊔ (app g)
  shift_equiv : ∀ ⦃f : C(X, WithBot ℝ)⦄ (c : WithBot ℝ), app (f + c) = (app f) + c

/-- A tropical measure is a set function μ : Set X → WithBot ℝ that is
inner regular on opens and outer regular on compacts, with μ(∅) = ⊤
(the tropical zero). This is the min-plus analogue of a Radon measure.
Bridge: connects measure theory to tropical geometry and lattice cryptography. -/
structure TropicalMeasure (X : Type*) [CompactSpace X] [T2Space X] where
  measure : Set X → WithBot ℝ
  measure_empty : measure ∅ = ⊤
  measure_mono : ∀ ⦃A B : Set X⦄, A ⊆ B → measure B ≤ measure A  -- min-plus reverses order!
  inner_reg_open : ∀ (U : Set X) (IsOpen U), measure U = ⨅ (K ∈ compactSubsets U), measure K
  outer_reg_compact : ∀ (K : Set X) (hK : IsCompact K), measure K = ⨆ (U ∈ openSupersets K), measure U
  sup_additive : ∀ ⦃A B : Set X⦄, Disjoint A B → measure (A ∪ B) = (measure A) ⊓ (measure B)

/-- A tropical probability measure satisfies μ(X) = 0 (tropical one)
and is normalized. This models the "most likely path" in quantum
dequantization and provides the foundation for tropical concentration.
Bridge: connects probability theory to quantum mechanics via Maslov dequantization. -/
class IsTropicalProbability (X : Type*) [CompactSpace X] [T2Space X] (P : TropicalMeasure X) : Prop where
  total_mass : P.measure Set.univ = (0 : WithBot ℝ)  -- tropical 1 = classical 0
  mass_nonneg : ∀ (A : Set X), (0 : WithBot ℝ) ≤ P.measure A  -- all sets have nonneg tropical mass

/-- The tropical integral of f with respect to μ computes
∫_T f dμ = ⨅_{x ∈ X} (f(x) + μ({x})), the min-plus analogue
of the Lebesgue integral. This computes shortest-path costs.
Bridge: connects integration theory to dynamic programming and ML loss landscapes. -/
noncomputable def tropicalIntegral {X : Type*} [CompactSpace X] [T2Space X]
    (f : C(X, WithBot ℝ)) (μ : TropicalMeasure X) : WithBot ℝ :=
  ⨅ (x : X), f x + μ.measure {x}

/-- Tropical expectancy (min-plus mean) of f under P.
This is the "most probable value" — the tropical center of mass.
Bridge: connects statistics to optimization and certified_robustness. -/
noncomputable def tropicalExpectancy {X : Type*} [CompactSpace X] [T2Space X]
    (P : TropicalMeasure X) [IsTropicalProbability X P]
    (f : X → WithBot ℝ) : WithBot ℝ :=
  ⨅ (x : X), f x + P.measure {x}

/-- A tropical subsemialgebra of C(X, WithBot ℝ) closed under
sup, shift, and continuous functions. The tropical Riesz theorem
extends functionals from such subalgebras to full measures.
Bridge: connects algebra to functional analysis and cryptographic hash theory. -/
structure TropSubsemialgebra (X : Type*) [CompactSpace X] [T2Space X] where
  carrier : Set C(X, WithBot ℝ)
  sup_closed : ∀ ⦃f g : C(X, WithBot ℝ)⦄, f ∈ carrier → g ∈ carrier → f ⊔ g ∈ carrier
  shift_closed : ∀ ⦃f : C(X, WithBot ℝ)┠, f ∈ carrier → ∀ (c : WithBot ℝ), f + c ∈ carrier
  const_mem : ∀ (c : WithBot ℝ), (const c : C(X, WithBot ℝ)) ∈ carrier
  eval_mem : ∀ (x : X), eval x ∈ carrier
```

---

### MAIN THEOREMS (10+ required, ZERO sorries)

#### Theorem 1: Tropical Choquet–Radon Representation (Existence + Uniqueness)

```lean
/-- **Tropical Choquet–Radon Theorem**: Every monotone, sup-preserving,
shift-equivariant tropical functional I on C(X, WithBot ℝ) arises
uniquely from a tropical Radon measure μ via tropical integration.

This is the min-plus Riesz representation theorem. It establishes a
bijective correspondence between tropical functionals and tropical measures
on compact Hausdorff spaces, mirroring the classical Riesz–Markov–Kakutani theorem.

Bridge: connects functional analysis to tropical geometry and quantum dequantization.
Impact: foundational for post_quantum_security of min-plus hash functions.

Proof strategy:
  Step 1: Construct μ from I using outer/inner regularity on opens/compacts.
         Define μ(U) = ⨅ {I(f) : f ≲ χ_U, f ∈ C(X, WithBot ℝ)} for open U.
  Step 2: Prove μ is sup-additive on disjoint sets using I's sup-preservation.
         Key lemma: tropical_measure_sup_additive_of_disjoint
  Step 3: Prove shift-equivariance of the integral from I's shift-equivariance.
         Key lemma: tropical_integral_shift_equiv
  Step 4: Prove uniqueness by showing two measures agreeing on all f must agree
         on all opens, hence on all Borel sets by outer/inner regularity.
         Key lemma: tropical_measure_agree_on_borel_of_agree_on_continuous
  Step 5: The constructive witness is the measure defined in Step 1.
-/
theorem tropical_choquet_radon {X : Type*} [CompactSpace X] [T2Space X]
    (I : TropicalFunctional X)
    (hI_mono : ∀ ⦃f g : C(X, WithBot ℝ)⦄, (∀ x, f x ≤ g x) → I.app f ≤ I.app g)
    (hI_sup : ∀ ⦃f g : C(X, WithBot ℝ)⦄, I.app (f ⊔ g) = (I.app f) ⊔ (I.app g))
    (hI_shift : ∀ ⦃f : C(X, WithBot ℝ)┠ (c : WithBot ℝ), I.app (f + c) = (I.app f) + c) :
    ∃! μ : TropicalMeasure X, ∀ f : C(X, WithBot ℝ), I.app f = tropicalIntegral f μ := by
  sorry  -- STRATEGY: Constructive via outer regularity, see Steps 1-5 above
```

#### Theorem 2: Tropical Riesz Extension

```lean
/-- **Tropical Riesz Extension Theorem**: A positive tropical linear map
from a tropical subsemialgebra A ⊆ C(X, WithBot ℝ) extends to a tropical
measure on all of X.

This is the tropical analogue of the classical Riesz extension theorem.
It enables extending partial min-plus optimization criteria to global measures.

Bridge: connects order theory to tropical functional analysis.
Impact: enables certified_robustness for tropical neural networks by
       extending local Lipschitz bounds to global measure-theoretic guarantees.

Proof strategy:
  Step 1: Extend L from A to all of C(X, WithBot ℝ) using sup-preserving envelopes.
         Define L̃(f) = ⨅ {L(g) : g ∈ A, g ≥ f} (tropical upper envelope).
  Step 2: Show L̃ preserves sup and shift using lattice properties of A.
         Key lemma: tropical_extension_preserves_sup
  Step 3: Apply tropical_choquet_radon to L̃ to obtain μ.
  Step 4: Verify L̃ agrees with L on A by the positivity hypothesis.
         Key lemma: tropical_extension_agrees_on_subalgebra
-/
theorem tropical_riesz_extension {X : Type*} [CompactSpace X] [T2Space X]
    {A : TropSubsemialgebra X} (L : A →ₗ[WithBot ℝ] WithBot ℝ)
    (hL_pos : ∀ f ∈ A.carrier, (0 : WithBot ℝ) ≤ L f) :
    ∃ μ : TropicalMeasure X, ∀ f ∈ A.carrier, L f = tropicalIntegral f μ := by
  sorry  -- STRATEGY: Sup-preserving envelope extension, see Steps 1-4
```

#### Theorem 3: Tropical Hoeffding Concentration

```lean
/-- **Tropical Hoeffding Inequality**: For f with a ≤ f(x) ≤ b and
tropical probability P, the tropical tail satisfies:
  P {x | |f x - tropicalExpectancy f P| > t} ≤ tropical_exp (-(t² / (2(b-a)²)))

This is the min-plus concentration inequality — the "most probable deviation"
decays as exp(-t²/2σ²) where σ = b - a is the range. This gives
O(exp(-t²/2σ²)) certified concentration for tropical random variables.

Bridge: connects probability theory to statistical mechanics (entropy concentration)
       and ML (certified_robustness for tropical ReLU networks).
Impact: Provides Lipschitz-certified robustness bounds for min-plus neural networks
       with explicit O(exp(-t²/2σ²)) convergence rate.

Proof strategy:
  Step 1: Reduce to bounding P {|f - E_T[f]| ≥ t} using tropical Markov inequality.
         Key lemma: tropical_markov_inequality
  Step 2: Apply tropical Chernoff method: P {f ≥ t} ≤ E_T[tropical_exp(λ(f - t))]
         Key lemma: tropical_chernoff_bound
  Step 3: Use bounded range to bound the tropical moment generating function:
         E_T[tropical_exp(λf)] ≤ tropical_exp(λ²(b-a)²/8)
         Key lemma: tropical_mgf_bound_bounded_range
  Step 4: Optimize over λ to get the Hoeffding bound exp(-t²/2(b-a)²).
         Key lemma: tropical_hoeffding_lambda_optimization
  Step 5: Apply to both tails (f ≥ t and f ≤ -t) and combine.
         Key lemma: tropical_hoeffding_two_sided
-/
theorem tropical_hoeffding {X : Type*} [CompactSpace X] [T2Space X]
    {P : TropicalMeasure X} [IsTropicalProbability X P]
    {f : X → WithBot ℝ} {a b : ℝ}
    (hf_range : ∀ x, (a : WithBot ℝ) ≤ f x ∧ f x ≤ (b : WithBot ℝ))
    (t : ℝ) (ht : 0 < t) :
    P.measure {x | |f x - tropicalExpectancy f P| > (t : WithBot ℝ)} ≤
      tropical_exp (-(t^2 / (2 * (b - a)^2)) : ℝ) := by
  sorry  -- STRATEGY: Tropical Chernoff method, see Steps 1-5
```

#### Supporting Lemmas (7+ required)

```lean
/-- Tropical Markov inequality: P {f ≥ t} ≤ E_T[f] / t (in tropical arithmetic).
Bridge: connects probability to optimization. -/
theorem tropical_markov_inequality {X : Type*} [CompactSpace X] [T2Space X]
    {P : TropicalMeasure X} [IsTropicalProbability X P]
    {f : X → WithBot ℝ} {t : WithBot ℝ}
    (hf_nonneg : ∀ x, (0 : WithBot ℝ) ≤ f x) (ht : (0 : WithBot ℝ) < t) :
    P.measure {x | t ≤ f x} ≤ tropicalExpectancy f P + (-t) := by
  sorry

/-- The tropical moment generating function for bounded random variables
is bounded by tropical_exp(λ²(b-a)²/8).
Bridge: connects statistics to quantum mechanics (path integral concentration). -/
theorem tropical_mgf_bound_bounded_range {X : Type*} [CompactSpace X] [T2Space X]
    {P : TropicalMeasure X} [IsTropicalProbability X P]
    {f : X → WithBot ℝ} {a b : ℝ} (λ : ℝ)
    (hf_range : ∀ x, (a : WithBot ℝ) ≤ f x ∧ f x ≤ (b : WithBot ℝ)) :
    tropicalExpectancy (fun x => tropical_exp (λ • (f x))) ≤
      tropical_exp ((λ^2 * (b - a)^2 / 8) : ℝ) := by
  sorry

/-- Sup-additivity of tropical measure on disjoint sets:
μ(A ∪ B) = μ(A) ⊓ μ(B) when A ∩ B = ∅.
This is the tropical analogue of additivity. -/
theorem tropical_measure_sup_additive_of_disjoint {X : Type*} [CompactSpace X] [T2Space X]
    (μ : TropicalMeasure X) {A B : Set X}
    (hAB : Disjoint A B) :
    μ.measure (A ∪ B) = μ.measure A ⊓ μ.measure B := by
  exact μ.sup_additive A B hAB

/-- Two tropical measures agreeing on all continuous functions agree on all Borel sets.
This is the uniqueness half of the Choquet–Radon theorem. -/
theorem tropical_measure_agree_on_borel_of_agree_on_continuous {X : Type*} [CompactSpace X] [T2Space X]
    {μ ν : TropicalMeasure X}
    (h : ∀ f : C(X, WithBot ℝ), tropicalIntegral f μ = tropicalIntegral f ν) :
    ∀ (S : Set X), IsOpen S → μ.measure S = ν.measure S := by
  sorry

/-- The tropical integral is shift-equivariant:
∫_T (f + c) dμ = (∫_T f dμ) + c
This mirrors the linearity of classical integration. -/
theorem tropical_integral_shift_equiv {X : Type*} [CompactSpace X] [T2Space X]
    (μ : TropicalMeasure X) (f : C(X, WithBot ℝ)) (c : WithBot ℝ) :
    tropicalIntegral (f + c) μ = tropicalIntegral f μ + c := by
  sorry

/-- Tropical expectation is bounded by the range:
a ≤ E_T[f] ≤ b when a ≤ f(x) ≤ b for all x.
Bridge: connects optimization to statistics. -/
theorem tropical_expectancy_bounded_by_range {X : Type*} [CompactSpace X] [T2Space X]
    {P : TropicalMeasure X} [IsTropicalProbability X P]
    {f : X → WithBot ℝ} {a b : ℝ}
    (hf_range : ∀ x, (a : WithBot ℝ) ≤ f x ∧ f x ≤ (b : WithBot ℝ)) :
    (a : WithBot ℝ) ≤ tropicalExpectancy f P ∧ tropicalExpectancy f P ≤ (b : WithBot ℝ) := by
  sorry

/-- The sup-preserving envelope extension agrees with L on the subsemialgebra A.
Key lemma for the Riesz extension theorem. -/
theorem tropical_extension_agrees_on_subalgebra {X : Type*} [CompactSpace X] [T2Space X]
    {A : TropSubsemialgebra X} {L : A →ₗ[WithBot ℝ] WithBot ℝ}
    (hL_pos : ∀ f ∈ A.carrier, (0 : WithBot ℝ) ≤ L f)
    (f : C(X, WithBot ℝ)) (hf : f ∈ A.carrier) :
    tropical_sup_envelope L f = L f := by
  sorry

/-- Tropical probability measures concentrate mass: for any ε > 0,
the set {x | P.measure {x} ≥ ε} is finite.
This is the tropical analogue of tightness and connects to
lattice_cryptography via the Shortest Vector Problem. -/
theorem tropical_probability_tight {X : Type*} [CompactSpace X] [T2Space X]
    {P : TropicalMeasure X} [IsTropicalProbability X P]
    (ε : ℝ) (hε : 0 < ε) :
    Finite {x : X | (ε : WithBot ℝ) ≤ P.measure {x}} := by
  sorry
```

---

### PROOF STRATEGY DETAILS

**Strategy A (Constructive via Outer Regularity)** — *Most promising for Choquet–Radon*:
Define μ(U) = ⨅{I(f) : f ≤ χ_U, f continuous} for open U, then extend to Borel sets. Sup-preservation of I transfers to sup-additivity of μ. This mirrors the classical Daniell integral construction but with min-plus arithmetic. The key insight: in the tropical setting, *lower* envelopes become *upper* envelopes because the order reverses (min replaces sup).

**Strategy B (Lattice-Theoretic via Stone Duality)** — *Most promising for Riesz Extension*:
Use the lattice structure of TropSubsemialgebra to construct the extension as a sup-preserving map on the lattice of continuous functions. The positivity of L ensures the extension is well-defined. This connects to Stone duality for min-plus algebras and opens the door to tropical spectral theory.

**Strategy C (Chernoff Method Adapted for Min-Plus)** — *Most promising for Hoeffding*:
The classical Chernoff bound E[exp(λX)] ≤ exp(λ²σ²/2) becomes E_T[exp(λX)] ≤ exp(λ²(b-a)²/8) in the tropical setting. The proof uses the convexity of the tropical exponential and the bounded range to bound the tropical MGF, then optimizes over λ. The bound O(exp(-t²/2(b-a)²)) is *tight* for tropical Bernoulli random variables.

**Strategy D (Contrapositive for Uniqueness)** — *For uniqueness in Choquet–Radon*:
If two measures μ ≠ ν disagree on some Borel set, they must disagree on some continuous function (by Urysohn-type approximation in the tropical setting). The T2 property of X and inner/outer regularity of the measures force agreement.

**Strategy E (Compactness Argument for Tightness)** — *For tropical_probability_tight*:
If infinitely many points had mass ≥ ε, then the total mass would exceed 0 (the tropical unit), contradicting IsTropicalProbability.total_mass. This is the tropical analogue of the classical fact that probability measures on compact spaces are tight.

---

### CROSS-DOMAIN BRIDGES AND IMPACT

**Bridge 1: Tropical Geometry ↔ Quantum Mechanics (Maslov Dequantization)**
The tropical integral computes the *semiclassical limit* of quantum path integrals. As ℏ → 0, the Feynman path integral exp(-S/ℏ) concentrates on the classical path, which is exactly the tropical integral ∫_T f dμ = min_x(f(x) + μ({x})). The tropical Hoeffding bound gives *quantum concentration of measure* — the probability of deviation from the classical path decays as exp(-t²/2σ²). This connects to `quantum_concentration_bound` and `maslov_dequantization_limit`.

**Bridge 2: Probability Theory ↔ Post-Quantum Cryptography**
Tropical probability measures on lattices Λ ⊂ ℝⁿ define *min-plus hash functions* h(x) = min_{v ∈ Λ} ‖x - v‖_T. The tropical Hoeffding bound proves that these hashes have *certified collision resistance*: P[h(x) = h(y)] ≤ exp(-d²/2σ²) where d is the minimum distance. This gives `post_quantum_security` bounds for lattice-based schemes resistant to Shor's algorithm. Connect to `tropical_hash_collision` and `lattice_svp_tropical_bound`.

**Bridge 3: Functional Analysis ↔ Certified Robustness for Neural Networks**
The tropical Choquet–Radon theorem establishes that every min-plus Lipschitz functional on a compact space is represented by a tropical measure with *explicit Lipschitz constant*. For tropical ReLU networks, this gives `lipschitz_certified_robustness`: if the network is K-Lipschitz in the tropical metric, then adversarial perturbations of size < margin/(2K) cannot change the classification. The O(exp(-t²/2σ²)) Hoeffding bound gives *probabilistic* certified robustness.

---

### COMPUTATIONAL BOUNDS AND UTILITY

1. **Tropical Hoeffding bound**: P[|f - E_T[f]| > t] ≤ exp(-t²/(2(b-a)²)) — explicit O(exp(-t²/2σ²)) convergence rate with σ = b - a.
2. **Lipschitz constant for certified robustness**: If f is K-Lipschitz in the tropical metric on a compact set of diameter d, then certified_radius = margin/(2Kd) with confidence ≥ 1 - exp(-t²/2(b-a)²).
3. **Tropical hash collision probability**: For lattice Λ with minimum distance λ₁, P[h(x) = h(y)] ≤ exp(-λ₁²/(2σ²)) where σ is the smoothing parameter — explicit bound for `post_quantum_security`.
4. **Tropical MGF bound**: E_T[exp(λf)] ≤ exp(λ²(b-a)²/8) — explicit constant 1/8 matching the classical Hoeffding bound.
5. **Tightness bound**: |{x : P({x}) ≥ ε}| ≤ σ²/ε² where σ is the tropical variance — explicit finite bound for computational tractability.

---

### FUTURE DIRECTIONS (Aristotle MUST produce these)

After proving the above, produce a `FUTURE_DIRECTIONS.md` with:

1. **Tropical Central Limit Theorem**: Prove that sums of independent tropical random variables converge to a tropical Gaussian (Gumbel distribution) with explicit O(1/√n) convergence rate — the min-plus analogue of the CLT, connecting to extreme value theory and `tropical_clt_convergence_rate`.

2. **Tropical Sanov's Theorem**: Prove that the tropical relative entropy satisfies a large deviation principle with rate function given by tropical KL divergence — this gives `information_theoretic_security` for min-plus codes and connects to `tropical_mutual_information_data_processing`.

3. **Tropical Isoperimetric Inequality**: Prove that tropical probability measures on compact metric spaces satisfy an isoperimetric inequality with explicit constant — this gives `certified_adversarial_robustness` for tropical neural networks and connects to `tropical_concentration_isoperimetry`.

4. **Post-Quantum Collision Resistance**: Use the tropical Hoeffding bound to prove that min-plus hash functions on lattices achieve (ε, δ)-collision resistance with ε = exp(-λ₁²/2σ²) and δ = 0 — this gives `post_quantum_security` for NIST lattice-based schemes and connects to `lattice_svp_tropical_reduction`.

5. **Quantum Dequantization Limit**: Prove that the classical Lebesgue integral converges to the tropical integral as ℏ → 0 with explicit O(ℏ²) error bound — this formalizes Maslov dequantization and connects to `semiclassical_path_concentration`.

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

            Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


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
            Open the field of tropical (max-plus) measure theory by proving three foundational results: (1) Complete the CompactTropicalChoquetRadon and CompactRiesz sorry targets, establishing that every monotone sup-preserving shift-equivariant functional on tropical continuous functions over a compact Hausdorff space admits a unique max-plus integral representation I(f) = max_{x∈X}[f(x) + μ({x})] against a tropical measure μ, and that positive tropical linear functionals on tropical subsemialgebras extend to such representations; (2) Define sup-additive integration ∫ₘₐₓ f dμ against tropical measures and prove tropical convergence theorems (max-plus monotone convergence: ∫ₘₐₓ supₙ fₙ dμ = supₙ ∫ₘₐₓ fₙ dμ for directed nets; max-plus dominated convergence for pointwise-convergent sequences bounded by a tropical integrable function); (3) Establish tropical probability as normalized tropical measures (P(Ω) = 0 in max-plus arithmetic), define tropical conditional expectation, prove tropical Hoeffding concentration P(|f - Eₘₐₓ[f]| > t) ≤ expₘₐₓ(-t²/2σ²), and derive certified uncertainty bounds for tropical neural network predictions. This creates the measure-theoretic foundation for all of tropical analysis, enabling tropical probability, tropical statistics, and certified robustness via measure concentration — a prerequisite for the inflight Tropical Fourier Analysis work.

            ### Precise Mathematical Framing
            For the tropical semiring 𝕋 = (ℝ ∪ {-∞}, max, +), a tropical measure μ on a compact Hausdorff space X is a sup-additive set function: μ(A ∪ B) = max(μ(A), μ(B)) for disjoint A, B, with μ(∅) = -∞. A tropical functional I: C(X, 𝕋) → 𝕋 is monotone (f ≤ g ⟹ I(f) ≤ I(g)), sup-preserving (I(supₙ fₙ) = supₙ I(fₙ) for directed nets), and shift-equivariant (I(f + c) = I(f) + c). The Choquet–Radon theorem states: for every such I, there exists a unique tropical measure μ with I(f) = max_{x∈X}[f(x) + μ({x})]. The Riesz theorem: every positive tropical linear functional L on a tropical subsemialgebra A ⊂ C(X, 𝕋) extends to a tropical integral representation. Tropical probability normalizes via P(Ω) = 0 (tropical zero). Tropical expectation Eₘₐₓ[f] = ∫ₘₐₓ f dP. Tropical concentration: for f with tropical variance σ², P(f - Eₘₐₓ[f] > t) ≤ -t²/(2σ²) in max-plus arithmetic, yielding certified bounds: for a tropical neural network h with Lipschitz constant L on input ball B_∞(x, ε), the prediction is certified within radius ε - σ/√(2L).

            ### Lean 4 Sketch
theorem tropical_choquet_radon {X : Type*} [CompactSpace X] [T2Space X] (I : TropicalFunctional X) (hI_mono : TropicalFunctional.Monotone I) (hI_sup : TropicalFunctional.SupPreserving I) (hI_shift : TropicalFunctional.ShiftEquiv I) : ∃! μ : TropicalMeasure X, ∀ f : C(X, WithBot ℝ), I f = tropicalIntegral f μ

theorem tropical_riesz_extension {X : Type*} [CompactSpace X] [T2Space X] {A : TropSubsemialgebra X} (L : A →ₗ[WithBot ℝ] WithBot ℝ) (hL_pos : ∀ f ∈ A, 0 ≤ L f) : ∃ μ : TropicalMeasure X, ∀ f ∈ A, L f = tropicalIntegral f μ

theorem tropical_hoeffding {X : Type*} {P : TropicalMeasure X} [IsTropicalProbability P] {f : X → WithBot ℝ} {a b : ℝ} (hf_range : ∀ x, a ≤ f x ∧ f x ≤ b) (t : ℝ) : P {x | |f x - tropicalExpectancy f P| > t} ≤ tropical_exp (-(t^2 / (2 * (b - a)^2)))

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `bool_and_as_tropical_max` : theorem bool_and_as_tropical_max :
     (file: Tropical/Core/HashInversion.lean)
  2. `tropical_attention_shift_equivariant` : theorem tropical_attention_shift_equivariant
     (file: Tropical/NeuralNetworks/TropicalViTFormalization.lean)
  3. `continuous_achieves_sup_on_compact` : theorem continuous_achieves_sup_on_compact {X : Type*} [TopologicalSpace X]
     (file: Tropical/OmegaMetaOracle.lean)
  4. `multi_class_tropical_certified_robustness` : theorem multi_class_tropical_certified_robustness
     (file: Tropical/Tropical_Certified_Robustness_for_Multi_Class_ReLU_Networks.lean)
  5. `tropical_fundamental_theorem_of_arithmetic` : theorem tropical_fundamental_theorem_of_arithmetic {a b : ℕ} (ha : 0 < a) (hb : 0 < b)
     (file: Tropical/Core/TropicalFactoring.lean)

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



Recent successful concepts: Provability Spectral Theory: Löb Fixed-Point Lattices, Modal Eigenvalue Decomposition, and Stone Duality for EML Closure Self-Models, Algebraic Learning Theory: Module-Theoretic VC Dimension, Spectral Rademacher Decomposition, and Certified Generalization over Algebraic Structures, Berggren Stabilizer Codes: Pythagorean Symplectic Lattices, Modular Tree Reductions, and Diophantine Quantum Error Correction


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

Research domain: Tropical
Research mode: formalize
