

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

## PRIMARY FILE AND CORE FORMALIZATION TARGET

Create a new Lean 4 development centered on a finite prime-spectral state space with entropic transport, Sinkhorn scaling, and proof-theoretic separation certificates. The core file should introduce a mathematically usable finite-dimensional formalization that is strong enough to prove existence/uniqueness of balanced couplings, quantitative convergence of alternating normalization, and sound/complete separation statements for derivability via entropic countermodel transport.

Work in maximal typeclass generality, but reduce analytic burdens to the finite setting:
```lean
variable {S : Type*} [CoherentClosureProofSemiring S]
variable [Fintype (SpectralPoint S)] [DecidableEq (SpectralPoint S)]
```

You should define all finite sums explicitly over `Finset.univ`, and prefer finite-dimensional theorems that can actually be proved in Mathlib without introducing measure-theoretic overhead.

---

## NEW DEFINITIONS AND STRUCTURES TO INTRODUCE

Introduce at least the following definitions, with doc comments explicitly naming bridge applications to thermodynamic physics, quantum-inspired transport, post-quantum cryptographic separation, and certified robustness:

```lean
/-- Bridge: connects prime-spectral proof semantics to thermodynamic entropy
and quantum-inspired Schrödinger bridge couplings on finite state spaces. -/
def IsProbMass {α : Type*} [Fintype α] (w : α → ℝ) : Prop :=
  (∀ a, 0 ≤ w a) ∧ (∑ a, w a = 1)

/-- Prime-spectral Gibbs kernel with inverse temperature β and entropic scale ε. -/
def spectralGibbsKernel
    {α : Type*} [Fintype α]
    (c : α → α → ℝ) (β ε : ℝ) : α → α → ℝ :=
  fun p q => Real.exp (-β * c p q / ε)

/-- Weighted row marginal for finite couplings. -/
def rowMarginalWeighted
    {α : Type*} [Fintype α]
    (μ : α → ℝ) (π : α → α → ℝ) : α → ℝ :=
  fun p => ∑ q, π p q

/-- Weighted column marginal for finite couplings. -/
def colMarginalWeighted
    {α : Type*} [Fintype α]
    (μ : α → ℝ) (π : α → α → ℝ) : α → ℝ :=
  fun q => ∑ p, π p q

/-- Spectral coupling induced by left/right scaling factors and a Gibbs kernel. -/
def spectralCoupling
    {α : Type*} [Fintype α]
    (μ u v : α → ℝ) (K : α → α → ℝ) : α → α → ℝ :=
  fun p q => u p * K p q * v q * μ p * μ q

/-- One-sided Sinkhorn row update. -/
def sinkhornRowUpdate
    {α : Type*} [Fintype α]
    (μ a v : α → ℝ) (K : α → α → ℝ) : α → ℝ :=
  fun p => a p / ((∑ q, K p q * v q * μ q) * μ p)

/-- One-sided Sinkhorn column update. -/
def sinkhornColUpdate
    {α : Type*} [Fintype α]
    (μ b u : α → ℝ) (K : α → α → ℝ) : α → ℝ :=
  fun q => b q / ((∑ p, u p * K p q * μ p) * μ q)

/-- A balanced pair of scaling potentials for a kernel and target marginals. -/
structure IsSinkhornBalanced
    {α : Type*} [Fintype α]
    (μ a b : α → ℝ) (K : α → α → ℝ) (u v : α → ℝ) : Prop where
  pos_u : ∀ p, 0 < u p
  pos_v : ∀ q, 0 < v q
  row_eq : rowMarginalWeighted μ (spectralCoupling μ u v K) = a
  col_eq : colMarginalWeighted μ (spectralCoupling μ u v K) = b

/-- Projective Hilbert ratio for positive vectors, used for quantitative contraction. -/
def hilbertRatio
    {α : Type*} [Fintype α]
    (x y : α → ℝ) : ℝ :=
  sSup {r | ∃ i, ∃ j, y i > 0 ∧ y j > 0 ∧ r = (x i / y i) / (x j / y j)}

/-- Log-diameter of a strictly positive kernel, the finite Birkhoff contraction datum. -/
def kernelProjectiveDiameter
    {α : Type*} [Fintype α]
    (K : α → α → ℝ) : ℝ :=
  sSup {r | ∃ i, ∃ j, ∃ k, ∃ l, 0 < K i k ∧ 0 < K j l ∧ 0 < K i l ∧ 0 < K j k ∧
    r = Real.log ((K i k * K j l) / (K i l * K j k))}

/-- Entropic transport gap used as a non-derivability certificate. -/
def transportGap
    (ε β : ℝ) (x y : S) : ℝ :=
  sInf {t : ℝ | ∃ π, True}  -- replace with your finite entropic objective

/-- Spectral separability: existence of a prime-spectral witness separating x from y. -/
def spectralSeparable (x y : S) : Prop :=
  ∃ p : SpectralPoint S, primeEval p x ≠ primeEval p y

/-- Derivability relation exported from the proof semiring semantics. -/
def derivable (x y : S) : Prop :=
  ClosureProvable x y  -- replace by the actual catalog notion if already present
```

Also add at least 5 more utility-level definitions that support quantitative theorems, e.g.
- `kernelMinEntry`
- `kernelMaxEntry`
- `strictlyPositiveKernel`
- `sinkhornPotentialEnergy`
- `entropicObjective`
- `certifiedSeparationRadius`
- `postQuantumSpectralAdvantage`
- `lipschitzCertifiedRobustnessScore`

These should not be decorative: use them in theorem statements.

---

## EXACT CORE TYPE SIGNATURES TO FORMALIZE

Refine the target theorem into a version that is actually provable in finite dimensions. The uniqueness should be modulo the standard gauge symmetry unless you explicitly fix a normalization. The most formalizable route is to normalize `u` by `∑ p, u p * μ p = 1`.

Introduce:
```lean
def normalizedPotential
    {α : Type*} [Fintype α]
    (μ u : α → ℝ) : Prop :=
  ∑ p, u p * μ p = 1
```

Then prove the normalized existence/uniqueness theorem:

```lean
theorem sinkhorn_factorization_exists_unique
    {α : Type*} [Fintype α] [DecidableEq α]
    (μ : α → ℝ) (hμpos : ∀ p, 0 < μ p)
    (a b : α → ℝ) (ha : IsProbMass a) (hb : IsProbMass b)
    (c : α → α → ℝ)
    (β ε : ℝ) (hβ : 0 < β) (hε : 0 < ε)
    (hKpos : ∀ p q, 0 < spectralGibbsKernel c β ε p q) :
    ∃! uv : (α → ℝ) × (α → ℝ),
      IsSinkhornBalanced μ a b (spectralGibbsKernel c β ε) uv.1 uv.2 ∧
      normalizedPotential μ uv.1 := by
```

Also prove the gauge-invariant variant:

```lean
theorem sinkhorn_factorization_unique_up_to_gauge
    {α : Type*} [Fintype α] [DecidableEq α]
    (μ : α → ℝ) (hμpos : ∀ p, 0 < μ p)
    (a b : α → ℝ) (ha : IsProbMass a) (hb : IsProbMass b)
    (K : α → α → ℝ) (hKpos : ∀ p q, 0 < K p q) :
    ∀ {u₁ v₁ u₂ v₂},
      IsSinkhornBalanced μ a b K u₁ v₁ →
      IsSinkhornBalanced μ a b K u₂ v₂ →
      ∃ c0 : ℝ, 0 < c0 ∧
        (∀ p, u₂ p = c0 * u₁ p) ∧
        (∀ q, v₂ q = (c0⁻¹) * v₁ q) := by
```

Define alternating Sinkhorn iteration on pairs:
```lean
def sinkhornStep
    {α : Type*} [Fintype α]
    (μ a b : α → ℝ) (K : α → α → ℝ) :
    (α → ℝ) × (α → ℝ) → (α → ℝ) × (α → ℝ)
```

and finite iterates:
```lean
def sinkhornIterate
    {α : Type*} [Fintype α]
    (μ a b : α → ℝ) (K : α → α → ℝ) (n : ℕ) :
    (α → ℝ) × (α → ℝ)
```

Then prove positivity invariance and balancing formulas:
```lean
theorem sinkhornStep_preserves_strict_positivity ...
theorem sinkhorn_row_update_exact ...
theorem sinkhorn_col_update_exact ...
theorem sinkhornIterate_pos ...
```

For convergence, replace topological `Tendsto` by an explicit metric rate first; then derive `Tendsto` as a corollary. A finite-dimensional estimate is much more usable:

```lean
def sinkhornError
    {α : Type*} [Fintype α]
    (μ a b : α → ℝ) (K : α → α → ℝ)
    (uv : (α → ℝ) × (α → ℝ)) : ℝ :=
  (∑ p, |rowMarginalWeighted μ (spectralCoupling μ uv.1 uv.2 K) p - a p|) +
  (∑ q, |colMarginalWeighted μ (spectralCoupling μ uv.1 uv.2 K) q - b q|)

theorem sinkhorn_iterates_geometric_certificate
    {α : Type*} [Fintype α] [DecidableEq α]
    (μ a b : α → ℝ) (K : α → α → ℝ)
    (hμpos : ∀ p, 0 < μ p)
    (ha : IsProbMass a) (hb : IsProbMass b)
    (hKpos : ∀ p q, 0 < K p q) :
    ∃ ρ : ℝ, ∃ C : ℝ,
      0 ≤ ρ ∧ ρ < 1 ∧ 0 ≤ C ∧
      ∀ n : ℕ,
        sinkhornError μ a b K (sinkhornIterate μ a b K n) ≤ C * ρ^n := by
```

Then:
```lean
theorem sinkhorn_iterates_converge
    {α : Type*} [Fintype α] [DecidableEq α]
    (μ a b : α → ℝ) (K : α → α → ℝ)
    (hμpos : ∀ p, 0 < μ p)
    (ha : IsProbMass a) (hb : IsProbMass b)
    (hKpos : ∀ p q, 0 < K p q) :
    ∃ uv,
      IsSinkhornBalanced μ a b K uv.1 uv.2 ∧
      Tendsto (fun n => sinkhornIterate μ a b K n) atTop (nhds uv) := by
```

For the proof-theoretic bridge, target soundness/completeness in a way compatible with finite witnesses:

```lean
theorem entropic_transport_separation_sound
    (ε β : ℝ) (hε : 0 < ε) (hβ : 0 < β)
    (x y : S) :
    derivable x y → transportGap ε β x y = 0 := by

theorem entropic_transport_separation_complete
    (ε β : ℝ) (hε : 0 < ε) (hβ : 0 < β)
    (x y : S) :
    spectralSeparable x y → ¬ derivable x y → 0 < transportGap ε β x y := by
```

Also prove a combined iff under an additional adequacy hypothesis:
```lean
class EntropicSpectralAdequacy (S : Type*) [CoherentClosureProofSemiring S] : Prop where
  derivable_iff_zero_gap :
    ∀ ε β, 0 < ε → 0 < β → ∀ x y : S, derivable x y ↔ transportGap ε β x y = 0

theorem entropic_transport_zero_gap_iff_derivable
    [EntropicSpectralAdequacy S]
    (ε β : ℝ) (hε : 0 < ε) (hβ : 0 < β)
    (x y : S) :
    transportGap ε β x y = 0 ↔ derivable x y := by
```

---

## REQUIRED SUPPORTING THEOREMS: AT LEAST 20, WITH DIVERSE TACTICS

Prove a dense ladder of lemmas, not just the main statements. At minimum include the following theorem families.

### A. Positivity, normalization, and finite-sum identities
Use `linarith`, `nlinarith`, `positivity`, `field_simp`, `ring`, `have`, `calc`.
```lean
theorem spectralGibbsKernel_pos ...
theorem spectralCoupling_nonneg ...
theorem spectralCoupling_pos ...
theorem rowMarginalWeighted_nonneg ...
theorem colMarginalWeighted_nonneg ...
theorem IsProbMass_nonneg ...
theorem IsProbMass_total_mass ...
theorem sinkhornRowUpdate_pos ...
theorem sinkhornColUpdate_pos ...
theorem normalizedPotential_rescaling ...
```

### B. Exact balancing identities
Use extensionality and `Finset.sum_mul`, `Finset.mul_sum`, `ring_nf`.
```lean
theorem sinkhorn_row_update_exact ...
theorem sinkhorn_col_update_exact ...
theorem balanced_pair_row_formula ...
theorem balanced_pair_col_formula ...
theorem balanced_pair_total_mass_agreement ...
```

### C. Uniqueness/gauge structure
Use `funext`, `by_contra`, ratio arguments, finite extremizers from `Fintype`.
```lean
theorem balanced_ratio_is_constant ...
theorem gauge_action_preserves_coupling ...
theorem normalized_balanced_pair_unique ...
theorem sinkhorn_factorization_unique_up_to_gauge ...
```

### D. Iterative dynamics and convergence certificates
Use induction on `n`, `omega` for simple integer index manipulations, and topological corollaries.
```lean
theorem sinkhornIterate_zero ...
theorem sinkhornIterate_succ ...
theorem sinkhornIterate_pos ...
theorem sinkhornError_nonneg ...
theorem sinkhornError_zero_of_balanced ...
theorem sinkhorn_iterates_geometric_certificate ...
theorem sinkhorn_iterates_converge ...
```

### E. Separation and cross-domain applications
Use `rcases`, contrapositive, witness extraction, and `by_cases`.
```lean
theorem transportGap_nonneg ...
theorem transportGap_eq_zero_of_derivable ...
theorem positive_gap_of_spectral_witness ...
theorem entropic_transport_separation_sound ...
theorem entropic_transport_separation_complete ...
theorem quantum_certified_countermodel_radius_positive ...
theorem post_quantum_spectral_advantage_lower_bound ...
theorem lipschitz_certified_robustness_from_gap ...
```

The last three can be corollaries from abstract definitions, but they must have explicit quantitative statements.

Example signatures:
```lean
def certifiedSeparationRadius (ε β : ℝ) (x y : S) : ℝ :=
  transportGap ε β x y / (β + ε)

theorem quantum_certified_countermodel_radius_positive
    (ε β : ℝ) (hε : 0 < ε) (hβ : 0 < β)
    (x y : S) :
    spectralSeparable x y → ¬ derivable x y →
    0 < certifiedSeparationRadius ε β x y := by
```

```lean
def postQuantumSpectralAdvantage (ε β : ℝ) (x y : S) : ℝ :=
  Real.log (1 + transportGap ε β x y)

theorem post_quantum_spectral_advantage_lower_bound
    (ε β : ℝ) (hε : 0 < ε) (hβ : 0 < β)
    (x y : S) :
    spectralSeparable x y → ¬ derivable x y →
    0 < postQuantumSpectralAdvantage ε β x y := by
```

```lean
def lipschitzCertifiedRobustnessScore (L ε β : ℝ) (x y : S) : ℝ :=
  transportGap ε β x y / (L + 1)

theorem lipschitz_certified_robustness_from_gap
    (L ε β : ℝ) (hL : 0 ≤ L) (hε : 0 < ε) (hβ : 0 < β)
    (x y : S) :
    spectralSeparable x y → ¬ derivable x y →
    0 < lipschitzCertifiedRobustnessScore L ε β x y := by
```

---

## PROOF ARCHITECTURE: 5 CONCRETE PATHS

### Strategy 1: Finite-dimensional Sinkhorn via convex optimization
Most promising for the normalized existence/uniqueness theorem.

1. Define a strictly convex finite-dimensional dual functional on `(u,v)` or on log-potentials `(f,g)`.
2. Show coercivity modulo gauge and strict convexity after fixing the normalization `normalizedPotential μ u`.
3. Use finite-dimensional compactness/continuity to extract a minimizer.
4. Differentiate only in the elementary finite-variable sense if needed, or avoid derivatives by using known balancing equations as the Euler-Lagrange characterization.
5. Derive uniqueness from strict convexity.

In Lean, a fully analytic derivative proof may be heavy; a more formalizable route is:
- define the set of balanced pairs,
- prove nonempty using an imported catalog theorem if available,
- prove uniqueness from ratio arguments and finite positivity.
If the catalog already contains a Schrödinger bridge existence theorem, instantiate it to the finite prime-spectral setting and then focus your originality on normalization, gauge uniqueness, and quantitative certificates.

### Strategy 2: Ratio monotonicity and gauge rigidity
Best for uniqueness-up-to-scale.

1. Assume two balanced pairs `(u₁,v₁)` and `(u₂,v₂)`.
2. Form pointwise ratios `r(p) = u₂ p / u₁ p` and `s(q) = v₂ q / v₁ q`.
3. Use row and column balancing plus positivity of `K` to show any maximal ratio must equal any minimal ratio.
4. Conclude all ratios are equal to a constant `c0 > 0`.
5. Normalize to force `c0 = 1`.

This is algebraic and finite; it should be Lean-friendly with `by_contra`, finite extrema on `Fintype`, and `linarith` after positivity lemmas.

### Strategy 3: Alternating exactness of updates
Best for proving row/column exactness and positivity of iterates.

1. Expand definitions of `sinkhornRowUpdate`, `spectralCoupling`, and `rowMarginalWeighted`.
2. Cancel denominators using positivity assumptions and `field_simp`.
3. Rearrange finite sums with `ring_nf` and `Finset.sum_comm`.
4. Use induction on `n` for positivity of iterates.
5. Build the error bound framework before topological convergence.

### Strategy 4: Quantitative convergence via finite contraction surrogate
If a full Birkhoff theorem is too heavy, prove a weaker but explicit rate under a uniform lower/upper bound:
```lean
∃ m M, 0 < m ∧ m ≤ K p q ∧ K p q ≤ M
```
for all `p q`.

Then show each update map is Lipschitz in an `ℓ∞` or projective metric with constant
```lean
ρ = (M - m) / (M + m)
```
or any valid explicit `ρ < 1` that you can prove. The exact optimal coefficient is less important than a correct explicit one. This satisfies the utility requirement and produces algorithmic complexity bounds:
```lean
N = O (Real.log (1/δ) / Real.log (1/ρ))
```
formalized as a theorem of the form:
```lean
∀ δ > 0, ∃ N, ∀ n ≥ N, sinkhornError ... ≤ δ
```

### Strategy 5: Separation by transporting spectral witnesses
For soundness/completeness:

1. Define `transportGap` so it vanishes whenever a derivation-compatible coupling exists.
2. For soundness, map a derivation into a feasible coupling of zero excess cost.
3. For completeness, from `spectralSeparable x y` extract `p` with unequal prime evaluations.
4. Build a witness cost function concentrating on separating coordinates.
5. Show any feasible coupling pays positive entropy-regularized cost, yielding `0 < transportGap`.

This is the key bridge from proof theory to thermodynamic transport, and the place to use `rcases`, witness extraction, and contradiction.

---

## MINIMAL HYPOTHESES AND SYMMETRY REQUIREMENTS

Whenever possible, minimize assumptions:
- positivity of `μ` and `K` should suffice; avoid unnecessary boundedness unless used for quantitative rates,
- derive symmetry corollaries when `c p q = c q p`,
- include quantifier alternation theorems of the form `∀ x, ∃ ε > 0, ...`,
- prove at least one theorem showing existence of a positive certified radius for every spectrally separable non-derivable pair.

Example:
```lean
theorem forall_nonderivable_exists_certified_radius
    (β : ℝ) (hβ : 0 < β) :
    ∀ x y : S, spectralSeparable x y → ¬ derivable x y →
      ∃ ε : ℝ, 0 < ε ∧ 0 < certifiedSeparationRadius ε β x y := by
```

Also include a symmetry theorem:
```lean
theorem symmetric_cost_yields_symmetric_gap
    (ε β : ℝ)
    (hc : ∀ p q, c p q = c q p) :
    transportGap ε β x y = transportGap ε β y x := by
```
if your definition of `transportGap` makes this formalizable.

---

## COMPUTATIONAL AND COMPLEXITY-STYLE THEOREMS

State explicit finite-algorithm utility theorems. Even if asymptotic notation is informal in comments, the Lean theorem must contain explicit bounds.

Introduce:
```lean
def sinkhornIterationBound (ρ C δ : ℝ) : ℕ :=
  Nat.ceil (Real.log (C / δ) / Real.log (1 / ρ))
```

Then prove a theorem of the form:
```lean
theorem sinkhorn_iteration_complexity_bound
    {α : Type*} [Fintype α] [DecidableEq α]
    (μ a b : α → ℝ) (K : α → α → ℝ)
    (hμpos : ∀ p, 0 < μ p)
    (ha : IsProbMass a) (hb : IsProbMass b)
    (hKpos : ∀ p q, 0 < K p q)
    (ρ C δ : ℝ)
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1) (hC : 0 ≤ C) (hδ : 0 < δ)
    (hgeom : ∀ n, sinkhornError μ a b K (sinkhornIterate μ a b K n) ≤ C * ρ^n) :
    ∀ n ≥ sinkhornIterationBound ρ C δ,
      sinkhornError μ a b K (sinkhornIterate μ a b K n) ≤ δ := by
```

Also derive a finite-state certificate count bound using `Fintype.card`:
```lean
theorem prime_spectral_certificate_search_bound
    (x y : S) :
    ∃ N : ℕ, N = Fintype.card (SpectralPoint S) ∧
      ∀ p : SpectralPoint S, True := by
```
This theorem is simple, but include a stronger nontrivial version if the catalog supports it:
- a witness search needs at most `card (SpectralPoint S)` checks,
- if no witness is found, conclude non-separability.

---

## TACTICAL REQUIREMENTS INSIDE PROOFS

Across the file, explicitly use a diverse tactic palette:
- `induction n with`
- `rcases h with ⟨...⟩`
- `by_contra h`
- `linarith`
- `nlinarith`
- `field_simp`
- `omega`
- `simp [definitions]`
- `rw [Finset.sum_comm]`
- `ext p`
- `funext p`
- `have hpos := ...`
- `calc ...`
- `by_cases h : ...`

Do not let the file collapse into only `simp`/`aesop`. The theorem inventory should visibly exercise multiple proof styles.

---

## CROSS-DOMAIN THEOREM NAMES AND DOC COMMENTS

Use theorem and definition names that explicitly encode the scientific bridges. At least several theorem names should contain one or more of:
- `quantum`
- `thermodynamic`
- `post_quantum`
- `certified`
- `lattice`
- `robustness`

Examples:
```lean
theorem thermodynamic_sinkhorn_free_energy_descent ...
theorem quantum_schrodinger_bridge_prime_spectral_uniqueness ...
theorem post_quantum_spectral_advantage_lower_bound ...
theorem certified_countermodel_transport_gap_soundness ...
theorem lattice_style_separation_search_is_finite ...
```

Even if the content is finite-dimensional and abstract, the naming should make the bridge explicit.

---

## WHAT TO DO IF FULL GENERALITY IS TOO HEAVY

If the exact existence proof for arbitrary positive kernel is blocked, prove the strongest complete special case with a fully formal theorem:
1. finite type `α`,
2. strictly positive kernel,
3. normalized uniqueness,
4. explicit iteration formulas,
5. convergence under a stronger assumption such as uniform kernel bounds.

Then state the remaining general theorem precisely as a conjecture or as a theorem under an explicit imported hypothesis:
```lean
axiom finite_sinkhorn_exists
  ...
```
But only do this if absolutely necessary, and still prove many downstream consequences rigorously from that axiom. The file must remain mathematically rich and useful, not a stub.

---

## SCIENTIFIC SIGNIFICANCE TO REFLECT IN DOC COMMENTS AND THEOREM CHOICE

This development should make precise a new bridge:

- **Proof theory ↔ thermodynamic physics**: derivability is characterized by zero free-energy transport gap.
- **Prime spectra ↔ entropic optimal transport**: spectral witnesses become transport certificates.
- **Cryptography ↔ logical separation**: positive transport gap acts as a post-quantum-style hardness/advantage surrogate.
- **Certified robustness ↔ semantics**: the gap induces a quantitative robustness radius against semantic perturbations.

The mathematical civilization-level point is that a logical countermodel is not merely a yes/no witness; it acquires geometry, entropy, and algorithmic complexity. Formalize that viewpoint in the theorem ecology.

---

## DELIVERABLE SHAPE

Produce a substantial Lean file with:
- 10+ definitions/structures,
- 20+ theorems,
- the four target theorem families above,
- explicit quantitative bounds,
- no sorries,
- and a coherent chain from finite Gibbs kernels to proof-theoretic separation.

Also produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, including at least:
1. extension from finite spectra to compact spectral spaces,
2. a tropical/large-deviation degeneration of the entropic gap,
3. a certified robustness interpretation for neural proof systems or differentiable theorem provers,
4. a post-quantum/lattice analogue of spectral transport certificates,
5. a Donsker–Varadhan dual characterization of `transportGap`.

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
            Define an entropic transport kernel on the prime spectrum of a coherent closure proof semiring and prove a Sinkhorn-type factorization theorem: every strictly positive proof-cost kernel K on SpectralPoint S induces a unique pair of scaling potentials whose diagonal rescaling realizes the Gibbs-optimal countermodel coupling with prescribed marginals. Then prove that the resulting iterative scaling algorithm converges and yields computable upper/lower bounds on non-derivability separation rates. This extends the recently productive Schrödinger-bridge/thermodynamic line, but differs from in-flight work by targeting matrix-scaling structure, convergence, and algorithmic factorization rather than minimizers, dual semantics, PAC-Bayes, or online regret.

            ### Precise Mathematical Framing
            Let P := SpectralPoint S for a coherent closure proof semiring S with finite prime spectrum. Equip P with a strictly positive reference measure μ and a proof-cost c : P → P → ℝ. Define K(p,q) = exp(-β * c p q). For admissible source/target marginals a,b on P, define the entropic transport functional J(π) = Σ_{p,q} π(p,q) c(p,q) + ε KL(π || μ⊗μ) subject to row marginals a and column marginals b. Prove: (1) existence/uniqueness of the optimizer π*; (2) factorization π*(p,q)=u(p) K(p,q) v(q) μ(p) μ(q); (3) iterative proportional fitting/Sinkhorn updates on (u,v) converge geometrically under positivity bounds; (4) the induced transport free energy gives a computable separation functional T_ε(x,y) built from source mass on witnesses supporting x and sink mass on witnesses refuting y; (5) if derivable x y then T_ε(x,y)=0, while if not derivable x y then under spectral separability assumptions T_ε(x,y)>0; (6) rounding/support-thresholding of π* yields sparse approximate witness plans and a polynomial-time certificate pipeline. This creates a new algorithmic transport layer for proof semantics, connecting entropic OT, matrix scaling, and spectral logic.

            ### Lean 4 Sketch
theorem sinkhorn_factorization_exists_unique
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (μ : SpectralPoint S → ℝ) (hμ : ∀ p, 0 < μ p)
    (c : SpectralPoint S → SpectralPoint S → ℝ)
    (β ε : ℝ) (hβ : 0 < β) (hε : 0 < ε)
    (a b : SpectralPoint S → ℝ)
    (ha : IsProb a) (hb : IsProb b) :
    ∃! (u v : SpectralPoint S → ℝ),
      (∀ p, 0 < u p) ∧ (∀ q, 0 < v q) ∧
      let K := fun p q => Real.exp (-β * c p q / ε)
      let π := fun p q => u p * K p q * v q * μ p * μ q
      rowMarginal π = a ∧ colMarginal π = b := by
  sorry

theorem sinkhorn_iterates_converge
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    ... :
    Tendsto (sinkhornIterate K a b) atTop (nhds (u,v)) := by
  sorry

theorem entropic_transport_separation_sound
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (x y : S) : derivable x y → transportGap ε β x y = 0 := by
  sorry

theorem entropic_transport_separation_complete
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (x y : S) : spectralSeparable x y → ¬ derivable x y → 0 < transportGap ε β x y := by
  sorry

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `pac_bayes_prime_spectral_bound_of_mgf` : theorem pac_bayes_prime_spectral_bound_of_mgf {S : Type*} {n : ℕ}
     (file: Bridges/PACBayesBound.lean)
  2. `purity_lower_bound_from_spectrum` : theorem purity_lower_bound_from_spectrum (k : ℕ) (hk : k > 0)
     (file: Bridges/QuantumIdempotent.lean)
  3. `rate_distortion_duality_of_coherent_proof_semiring` : theorem rate_distortion_duality_of_coherent_proof_semiring
     (file: Bridges/LawvereRateDistortionDuality.lean)
  4. `thermodynamic_prime_separation` : theorem thermodynamic_prime_separation
     (file: Bridges/ThermodynamicStonePrimeCompleteness.lean)
  5. `unique_top2Set_iff_positive_pair_margin` : theorem unique_top2Set_iff_positive_pair_margin (x : Fin 3 → ℝ) :
     (file: Bridges/TropicalSatakeTop2Margin.lean)

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



Recent successful concepts: Thermodynamic Reflection Capacity and a Sharp Incompleteness Threshold for Closure Self-Models, Prime-Spectral Schrödinger Bridge for Closure-Generated Proof Semirings via Entropic Countermodel Transport, Thermodynamic Sanov–Large-Deviation Completeness for Closure Self-Models via Prime-Spectral Free-Energy Rate Function


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
            @Speculative/AutoResearch/ThermodynamicSanovCompleteness.lean
```lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Thermodynamic Sanov–Large-Deviation Completeness for Closure Self-Models
# via Prime-Spectral Free-Energy Rate Function

This file establishes that derivability in a coherent closure proof semiring
is equivalent to the vanishing of a thermodynamic rate function across all
inverse temperatures β > 0.

## Main results

* `derivable_iff_zero_defect` — semantic adequacy: derivability ↔ zero defect
  at all spectral points.
* `thermodynamicRate_nonneg` — the rate functional is nonneg for nonneg inputs.
* `thermodynamicRate_self_zero_of_derivable` — derivable implies zero rate at reference.
* `nonderivable_rate_at_ref_pos` — non-derivable implies positive rate at reference.
* `thermodynamic_sanov_completeness` — the main biconditional theorem.
* `nonderivable_has_positive_rate_gap` — non-derivability creates a positive rate gap.
-/

import Mathlib

noncomputable section

open Finset BigOperators Classical

/-! ## Part 1: Coherent Closure Proof Semirings -/

/-- A **coherent closure proof semiring** is a bounded distributive lattice `S`
equipped with a closure operator `cl : S → S` satisfying extensiveness,
idempotency, and monotonicity. -/
class CoherentClosureProofSemiring (S : Type*) extends DistribLattice S, BoundedOrder S where
  cl : S → S
  cl_extensive : ∀ x : S, x ≤ cl x
  cl_idempotent : ∀ x : S, cl (cl x) = cl x
  cl_monotone : ∀ x y : S, x ≤ y → cl x ≤ cl y

namespace ThermodynamicSanov

variable {S : Type*} [CoherentClosureProofSemiring S]

abbrev cl : S → S := CoherentClosureProofSemiring.cl

def derivable (x y : S) : Prop := cl x ≤ cl y

theorem derivable_refl (x : S) : derivable x x := le_refl _

theorem derivable_trans {x y z : S} (hxy : derivable x y) (hyz : derivable y z) :
    derivable x z := le_trans hxy hyz

/-! ## Part 2: Spectral Points -/

/-- A **spectral point** of a coherent closure proof semiring is a prime filter
compatible with the closure operator. -/
structure SpectralPoint (S : Type*) [CoherentClosureProofSemiring S] where
  val : S → Prop
  val_mono : ∀ {a b : S}, a ≤ b → val a → val b
  val_top : val ⊤
  val_inf : ∀ a b : S, val (a ⊓ b) ↔ val a ∧ val b
  val_prime : ∀ a b : S, val (a ⊔ b) → val a ∨ val b
  val_cl : ∀ x : S, val (cl x) ↔ val x

/-! ## Part 3: Countermodel Defect Observable -/

/-- The **countermodel defect** observable. Returns `1` when the spectral point
separates `x` from `y`, and `0` otherwise. -/
def countermodelDefect (x y : S) (p : SpectralPoint S) : ℝ :=
  if p.val (cl x) ∧ ¬p.val (cl y) then 1 else 0

theorem countermodelDefect_nonneg (x y : S) (p : SpectralPoint S) :
    0 ≤ countermodelDefect x y p := by
  unfold countermodelDefect; split_ifs <;> norm_num

theorem countermodelDefect_le_one (x y : S) (p : SpectralPoint S) :
    countermodelDefect x y p ≤ 1 := by
  unfold countermodelDefect; split_ifs <;> norm_num

/-- Derivability kills the defect. -/
theorem derivable_implies_zero_defect (x y : S) (h : derivable x y)
    (p : SpectralPoint S) : countermodelDefect x y p = 0 := by
  unfold countermodelDefect
  rw [if_neg]
  push_neg
  exact fun hval => p.val_mono h hval

theorem countermodelDefect_eq_zero_iff (x y : S) (p : SpectralPoint S) :
    countermodelDefect x y p = 0 ↔ (p.val (cl x) → p.val (cl y)) := by
  unfold countermodelDefect
  constructor
  · intro h
    split_ifs at h with hc
    · exact absurd h one_ne_zero
    · push_neg at hc; exact hc
  · intro h
    rw [if_neg]
    push_neg; exact h

/-! ## Part 4: Prime Spectral Completeness -/

/-- The prime spectral completeness hypothesis. -/
class PrimeSpectralComplete (S : Type*) [CoherentClosureProofSemiring S] : Prop where
  separation : ∀ x y : S, ¬derivable x y →
    ∃ p : SpectralPoint S, p.val (cl x) ∧ ¬p.val (cl y)

/-- **Semantic adequacy**: derivability ↔ zero defect everywhere. -/
theorem derivable_iff_zero_defect [PrimeSpectralComplete S] (x y : S) :
    derivable x y ↔ ∀ p : SpectralPoint S, countermodelDefect x y p = 0 := by
  constructor
  · exact derivable_implies_zero_defect x y
  · intro h
    by_contra hnd
    obtain ⟨p, hp1, hp2⟩ := PrimeSpectralComplete.separation x y hnd
    have := h p
    unfold countermodelDefect at this
    simp [hp1, hp2] at this

/-- Non-derivability produces a spectral point with positive defect. -/
theorem nonderivable_exists_positive_defect [PrimeSpectralComplete S] (x y : S)
    (h : ¬derivable x y) :
    ∃ p : SpectralPoint S, 0 < countermodelDefect x y p := by
  obtain ⟨p, hp1, hp2⟩ := PrimeSpectralComplete.separation x y h
  exact ⟨p, by unfold countermodelDefect; simp [hp1, hp2]⟩

/-! ## Part 5: Divergence -/

/-- A **divergence** on a type `Ω` satisfying the core properties:
nonnegativity, identity of indiscernibles, and faithfulness. -/
structure Divergence (Ω : Type*) where
  d : (Ω → ℝ) → (Ω → ℝ) → ℝ
  d_nonneg : ∀ ν μ : Ω → ℝ, 0 ≤ d ν μ
  d_self : ∀ μ : Ω → ℝ, d μ μ = 0
  d_faithful : ∀ ν μ : Ω → ℝ, d ν μ = 0 → ν = μ

/-! ## Part 6: Thermodynamic Rate Function -/

variable [Fintype (SpectralPoint S)]

/-- The **energy defect functional**. -/
def energyDefect (x y : S) (β : ℝ) (ν : SpectralPoint S → ℝ) : ℝ :=
  β * ∑ p : SpectralPoint S, ν p * countermodelDefect x y p

/-- The **thermodynamic rate functional**. -/
def thermodynamicRate (D : Divergence (SpectralPoint S))
    (μ : SpectralPoint S → ℝ) (β : ℝ) (x y : S)
    (ν : SpectralPoint S → ℝ) : ℝ :=
  D.d ν μ + energyDefect x y β ν

/-- Energy defect is nonneg when `β ≥ 0` and `ν ≥ 0`. -/
-- ... (truncated, full file has 477 lines)
```


### Catalog Reference Files
            @Speculative/AutoResearch/ThermodynamicSanovCompleteness.lean
```lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Thermodynamic Sanov–Large-Deviation Completeness for Closure Self-Models
# via Prime-Spectral Free-Energy Rate Function

This file establishes that derivability in a coherent closure proof semiring
is equivalent to the vanishing of a thermodynamic rate function across all
inverse temperatures β > 0.

## Main results

* `derivable_iff_zero_defect` — semantic adequacy: derivability ↔ zero defect
  at all spectral points.
* `thermodynamicRate_nonneg` — the rate functional is nonneg for nonneg inputs.
* `thermodynamicRate_self_zero_of_derivable` — derivable implies zero rate at reference.
* `nonderivable_rate_at_ref_pos` — non-derivable implies positive rate at reference.
* `thermodynamic_sanov_completeness` — the main biconditional theorem.
* `nonderivable_has_positive_rate_gap` — non-derivability creates a positive rate gap.
-/

import Mathlib

noncomputable section

open Finset BigOperators Classical

/-! ## Part 1: Coherent Closure Proof Semirings -/

/-- A **coherent closure proof semiring** is a bounded distributive lattice `S`
equipped with a closure operator `cl : S → S` satisfying extensiveness,
idempotency, and monotonicity. -/
class CoherentClosureProofSemiring (S : Type*) extends DistribLattice S, BoundedOrder S where
  cl : S → S
  cl_extensive : ∀ x : S, x ≤ cl x
  cl_idempotent : ∀ x : S, cl (cl x) = cl x
  cl_monotone : ∀ x y : S, x ≤ y → cl x ≤ cl y

namespace ThermodynamicSanov

variable {S : Type*} [CoherentClosureProofSemiring S]

abbrev cl : S → S := CoherentClosureProofSemiring.cl

def derivable (x y : S) : Prop := cl x ≤ cl y

theorem derivable_refl (x : S) : derivable x x := le_refl _

theorem derivable_trans {x y z : S} (hxy : derivable x y) (hyz : derivable y z) :
    derivable x z := le_trans hxy hyz

/-! ## Part 2: Spectral Points -/

/-- A **spectral point** of a coherent closure proof semiring is a prime filter
compatible with the closure operator. -/
structure SpectralPoint (S : Type*) [CoherentClosureProofSemiring S] where
  val : S → Prop
  val_mono : ∀ {a b : S}, a ≤ b → val a → val b
  val_top : val ⊤
  val_inf : ∀ a b : S, val (a ⊓ b) ↔ val a ∧ val b
  val_prime : ∀ a b : S, val (a ⊔ b) → val a ∨ val b
  val_cl : ∀ x : S, val (cl x) ↔ val x

/-! ## Part 3: Countermodel Defect Observable -/

/-- The **countermodel defect** observable. Returns `1` when the spectral point
separates `x` from `y`, and `0` otherwise. -/
def countermodelDefect (x y : S) (p : SpectralPoint S) : ℝ :=
  if p.val (cl x) ∧ ¬p.val (cl y) then 1 else 0

theorem countermodelDefect_nonneg (x y : S) (p : SpectralPoint S) :
    0 ≤ countermodelDefect x y p := by
  unfold countermodelDefect; split_ifs <;> norm_num

theorem countermodelDefect_le_one (x y : S) (p : SpectralPoint S) :
    countermodelDefect x y p ≤ 1 := by
  unfold countermodelDefect; split_ifs <;> norm_num

/-- Derivability kills the defect. -/
theorem derivable_implies_zero_defect (x y : S) (h : derivable x y)
    (p : SpectralPoint S) : countermodelDefect x y p = 0 := by
  unfold countermodelDefect
  rw [if_neg]
  push_neg
  exact fun hval => p.val_mono h hval

theorem countermodelDefect_eq_zero_iff (x y : S) (p : SpectralPoint S) :
    countermodelDefect x y p = 0 ↔ (p.val (cl x) → p.val (cl y)) := by
  unfold countermodelDefect
  constructor
  · intro h
    split_ifs at h with hc
    · exact absurd h one_ne_zero
    · push_neg at hc; exact hc
  · intro h
    rw [if_neg]
    push_neg; exact h

/-! ## Part 4: Prime Spectral Completeness -/

/-- The prime spectral completeness hypothesis. -/
class PrimeSpectralComplete (S : Type*) [CoherentClosureProofSemiring S] : Prop where
  separation : ∀ x y : S, ¬derivable x y →
    ∃ p : SpectralPoint S, p.val (cl x) ∧ ¬p.val (cl y)

/-- **Semantic adequacy**: derivability ↔ zero defect everywhere. -/
theorem derivable_iff_zero_defect [PrimeSpectralComplete S] (x y : S) :
    derivable x y ↔ ∀ p : SpectralPoint S, countermodelDefect x y p = 0 := by
  constructor
  · exact derivable_implies_zero_defect x y
  · intro h
    by_contra hnd
    obtain ⟨p, hp1, hp2⟩ := PrimeSpectralComplete.separation x y hnd
    have := h p
    unfold countermodelDefect at this
    simp [hp1, hp2] at this

/-- Non-derivability produces a spectral point with positive defect. -/
theorem nonderivable_exists_positive_defect [PrimeSpectralComplete S] (x y : S)
    (h : ¬derivable x y) :
    ∃ p : SpectralPoint S, 0 < countermodelDefect x y p := by
  obtain ⟨p, hp1, hp2⟩ := PrimeSpectralComplete.separation x y h
  exact ⟨p, by unfold countermodelDefect; simp [hp1, hp2]⟩

/-! ## Part 5: Divergence -/

/-- A **divergence** on a type `Ω` satisfying the core properties:
nonnegativity, identity of indiscernibles, and faithfulness. -/
structure Divergence (Ω : Type*) where
  d : (Ω → ℝ) → (Ω → ℝ) → ℝ
  d_nonneg : ∀ ν μ : Ω → ℝ, 0 ≤ d ν μ
  d_self : ∀ μ : Ω → ℝ, d μ μ = 0
  d_faithful : ∀ ν μ : Ω → ℝ, d ν μ = 0 → ν = μ

/-! ## Part 6: Thermodynamic Rate Function -/

variable [Fintype (SpectralPoint S)]

/-- The **energy defect functional**. -/
def energyDefect (x y : S) (β : ℝ) (ν : SpectralPoint S → ℝ) : ℝ :=
  β * ∑ p : SpectralPoint S, ν p * countermodelDefect x y p

/-- The **thermodynamic rate functional**. -/
def thermodynamicRate (D : Divergence (SpectralPoint S))
    (μ : SpectralPoint S → ℝ) (β : ℝ) (x y : S)
    (ν : SpectralPoint S → ℝ) : ℝ :=
  D.d ν μ + energyDefect x y β ν

/-- Energy defect is nonneg when `β ≥ 0` and `ν ≥ 0`. -/
-- ... (truncated, full file has 477 lines)
```


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
Research mode: formalize
