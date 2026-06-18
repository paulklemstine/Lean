

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

## Thermodynamic Reflection–Diagonal Conservation, Rigidity, and Overcapacity Incompleteness

Work in a new Lean 4 file that turns the three target statements into the apex of a larger formal theory. Do not treat them as isolated lemmas. Build a self-contained mathematical narrative around a thermodynamic capacity calculus for closure self-models, with explicit bridges to statistical physics, certified robustness, and cryptographic resource tradeoffs.

### Core target theorems

You should prove the following exact statements, or strengthen them under weaker hypotheses if the catalog supports it:

```lean
theorem reflection_diagonal_conservation
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ) :
    reflectionCapacity M β + diagonalCapacity M β ≤ freeEnergySelfBudget M β := by
  ...

theorem reflection_diagonal_rigidity
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (hsat :
      reflectionCapacity M β + diagonalCapacity M β = freeEnergySelfBudget M β) :
    ExtremalSelfDescriptionFamily M β := by
  ...

theorem overcapacity_incompleteness
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (hover :
      freeEnergySelfBudget M β <
        reflectionCapacity M β + diagonalCapacity M β) :
    ¬ (Consistent M ∧ Sound M ∧ ClosureComplete M) := by
  ...
```

If the existing catalog already has stronger hypotheses such as `0 ≤ β`, prove the more general form first if possible, and otherwise prove the restricted theorem plus a reduction lemma showing exactly where the sign of `β` is used.

---

## Required theory expansion: new definitions and structures

Introduce at least 10 new nontrivial definitions, organized so the main theorems become natural consequences of a reusable framework. Suggested definitions with precise Lean signatures:

```lean
def capacityGap {S : Type _} (M : ClosureSelfModel S) (β : ℝ) : ℝ :=
  freeEnergySelfBudget M β - (reflectionCapacity M β + diagonalCapacity M β)

def IsSubcritical {S : Type _} (M : ClosureSelfModel S) (β : ℝ) : Prop :=
  reflectionCapacity M β + diagonalCapacity M β < freeEnergySelfBudget M β

def IsCritical {S : Type _} (M : ClosureSelfModel S) (β : ℝ) : Prop :=
  reflectionCapacity M β + diagonalCapacity M β = freeEnergySelfBudget M β

def IsSupercritical {S : Type _} (M : ClosureSelfModel S) (β : ℝ) : Prop :=
  freeEnergySelfBudget M β < reflectionCapacity M β + diagonalCapacity M β

def normalizedReflectionShare {S : Type _} (M : ClosureSelfModel S) (β : ℝ) : ℝ :=
  reflectionCapacity M β / freeEnergySelfBudget M β

def normalizedDiagonalShare {S : Type _} (M : ClosureSelfModel S) (β : ℝ) : ℝ :=
  diagonalCapacity M β / freeEnergySelfBudget M β

def thermodynamicSlackWitness {S : Type _} (M : ClosureSelfModel S) (β : ℝ) : Prop :=
  ∃ ε > 0,
    reflectionCapacity M β + diagonalCapacity M β + ε ≤ freeEnergySelfBudget M β

def quantumCertifiedBarrierProfile {S : Type _} (M : ClosureSelfModel S) : ℝ → ℝ :=
  fun β => freeEnergySelfBudget M β - reflectionCapacity M β

def postQuantumDiagonalReserve {S : Type _} (M : ClosureSelfModel S) : ℝ → ℝ :=
  fun β => freeEnergySelfBudget M β - diagonalCapacity M β

def thermodynamicRigidityEnvelope {S : Type _} (M : ClosureSelfModel S) : Set ℝ :=
  {β | IsCritical M β}

def selfCompressionDefect {S : Type _} (M : ClosureSelfModel S) (β : ℝ) : ℝ :=
  (reflectionCapacity M β + diagonalCapacity M β) - freeEnergySelfBudget M β
```

Also add at least one structure bundling hypotheses used repeatedly. For example:

```lean
structure CapacityBalancedSelfModel {S : Type _} where
  model : ClosureSelfModel S
  beta : ℝ
  hbudget : reflectionCapacity model beta + diagonalCapacity model beta
              ≤ freeEnergySelfBudget model beta
```

and one symmetry-flavored predicate:

```lean
def ReflectionDiagonalSymmetric {S : Type _} (M : ClosureSelfModel S) (β : ℝ) : Prop :=
  reflectionCapacity M β = diagonalCapacity M β
```

If appropriate, add instances or coercions only when mathematically justified; do not create decorative typeclass noise.

---

## Required theorem cluster

Prove at least 20 theorems total, with the three target theorems as the center. The theorem names should be inventive and domain-bridging. Include at least the following kinds of results.

### A. Algebra of the capacity gap

```lean
theorem capacityGap_eq_budget_minus_sum
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ) :
    capacityGap M β =
      freeEnergySelfBudget M β - (reflectionCapacity M β + diagonalCapacity M β) := by
  ...

theorem subcritical_iff_positive_gap
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ) :
    IsSubcritical M β ↔ 0 < capacityGap M β := by
  ...

theorem critical_iff_zero_gap
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ) :
    IsCritical M β ↔ capacityGap M β = 0 := by
  ...

theorem supercritical_iff_positive_defect
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ) :
    IsSupercritical M β ↔ 0 < selfCompressionDefect M β := by
  ...

theorem conservation_equiv_nonnegative_gap
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ) :
    reflectionCapacity M β + diagonalCapacity M β ≤ freeEnergySelfBudget M β
      ↔ 0 ≤ capacityGap M β := by
  ...
```

These should use `linarith`, `ring_nf`, `nlinarith` where possible, not just `simp`.

### B. Rigidity and extremality consequences

Prove that equality forces extremality, but also derive secondary consequences:

```lean
theorem criticality_forces_extremal_quantum_certificate
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (h : IsCritical M β) :
    ExtremalSelfDescriptionFamily M β := by
  ...

theorem rigidity_blocks_thermodynamic_slack
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (h : ExtremalSelfDescriptionFamily M β) :
    ¬ thermodynamicSlackWitness M β := by
  ...

theorem extremal_implies_zero_capacityGap
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (h : ExtremalSelfDescriptionFamily M β) :
    capacityGap M β = 0 := by
  ...
```

If the catalog only provides one direction, make the dependence explicit and prove the converse under the weakest extra hypothesis you can isolate.

### C. Incompleteness by contrapositive and phase transition logic

The target `overcapacity_incompleteness` should not stand alone. Prove a clean web of contrapositives and corollaries:

```lean
theorem consistent_sound_complete_implies_conservation
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (h : Consistent M ∧ Sound M ∧ ClosureComplete M) :
    reflectionCapacity M β + diagonalCapacity M β ≤ freeEnergySelfBudget M β := by
  ...

theorem consistent_sound_complete_implies_not_supercritical
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (h : Consistent M ∧ Sound M ∧ ClosureComplete M) :
    ¬ IsSupercritical M β := by
  ...

theorem supercritical_quantum_incompleteness_barrier
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (h : IsSupercritical M β) :
    ¬ (Consistent M ∧ Sound M ∧ ClosureComplete M) := by
  ...

theorem post_quantum_security_tradeoff
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (hcs : Consistent M ∧ Sound M)
    (hcomp : ClosureComplete M) :
    diagonalCapacity M β ≤ freeEnergySelfBudget M β - reflectionCapacity M β := by
  ...
```

Use `by_contra`, `push_neg`, and arithmetic contradiction tactics.

### D. Symmetry and balanced splitting theorems

Bridge to geometric and cryptographic symmetry by proving sharp consequences under
`ReflectionDiagonalSymmetric`:

```lean
theorem symmetric_split_half_budget
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (hsym : ReflectionDiagonalSymmetric M β)
    (hcons : reflectionCapacity M β + diagonalCapacity M β ≤ freeEnergySelfBudget M β) :
    reflectionCapacity M β ≤ freeEnergySelfBudget M β / 2 := by
  ...

theorem symmetric_split_half_budget_dual
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (hsym : ReflectionDiagonalSymmetric M β)
    (hcons : reflectionCapacity M β + diagonalCapacity M β ≤ freeEnergySelfBudget M β) :
    diagonalCapacity M β ≤ freeEnergySelfBudget M β / 2 := by
  ...

theorem symmetric_critical_exact_half
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (hsym : ReflectionDiagonalSymmetric M β)
    (hcrit : IsCritical M β) :
    reflectionCapacity M β = freeEnergySelfBudget M β / 2 ∧
    diagonalCapacity M β = freeEnergySelfBudget M β / 2 := by
  ...
```

These are good places to use `field_simp` if division hypotheses arise, or to avoid division by rewriting as doubled inequalities.

### E. Quantifier alternation and witness extraction

Include at least 3 theorems with genuine `∀ β, ∃ ε` or `∃ β, ∀ ...` structure. For example:

```lean
theorem subcritical_has_positive_slack
    {S : Type _} (M : ClosureSelfModel S) :
    ∀ ⦃β : ℝ⦄, IsSubcritical M β → ∃ ε > 0,
      reflectionCapacity M β + diagonalCapacity M β + ε ≤ freeEnergySelfBudget M β := by
  ...

theorem positive_gap_produces_certified_robustness_margin
    {S : Type _} (M : ClosureSelfModel S) :
    ∀ ⦃β : ℝ⦄, 0 < capacityGap M β → ∃ ε > 0, ε ≤ capacityGap M β := by
  ...

theorem no_uniform_overcapacity_under_complete_soundness
    {S : Type _} (M : ClosureSelfModel S)
    (h : Consistent M ∧ Sound M ∧ ClosureComplete M) :
    ¬ ∃ β : ℝ, IsSupercritical M β := by
  ...
```

The witness `ε = capacityGap M β` is often enough; use `rcases` and arithmetic carefully.

---

## Precise proof architecture

Do not attack the main theorem first. Build the following ladder.

### Step 1: isolate the arithmetic interface
Create lemmas that convert between:
- inequalities on capacities,
- positivity/nonnegativity of `capacityGap`,
- positivity of `selfCompressionDefect`,
- criticality/subcriticality/supercriticality predicates.

Expected proof tools: `unfold`, `constructor`, `linarith`, `ring_nf`.

### Step 2: import the thermodynamic barrier from the catalog
You should identify the exact theorem from the existing development that says, in substance, one or more of the following:
- consistency/soundness/completeness imply a free-energy budget inequality,
- no-self-compression bounds diagonal or reflection contributions,
- extremality follows from saturation of a free-energy inequality.

Wrap those theorems in new lemmas with the current names and signatures so the rest of the file is independent of catalog naming volatility.

Suggested wrappers:

```lean
theorem catalog_free_energy_budget_upper_envelope
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (h : Consistent M ∧ Sound M ∧ ClosureComplete M) :
    reflectionCapacity M β + diagonalCapacity M β ≤ freeEnergySelfBudget M β := by
  ...

theorem catalog_saturation_yields_extremal_family
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (h :
      reflectionCapacity M β + diagonalCapacity M β = freeEnergySelfBudget M β) :
    ExtremalSelfDescriptionFamily M β := by
  ...
```

Then derive the target theorems from these wrappers.

### Step 3: prove `reflection_diagonal_conservation`
If the catalog theorem already gives this under logical hypotheses, determine whether `ClosureSelfModel` carries those hypotheses as fields, or whether you need an additional class/assumption. If the target theorem as written is too strong, first prove the strongest valid form:

```lean
theorem reflection_diagonal_conservation_of_consistent_sound_complete
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (h : Consistent M ∧ Sound M ∧ ClosureComplete M) :
    reflectionCapacity M β + diagonalCapacity M β ≤ freeEnergySelfBudget M β := by
  ...
```

and then prove the original target only if those assumptions are definitional or globally available.

### Step 4: prove rigidity from saturation
This should likely be a direct application of the catalog extremality theorem. If there is no exact theorem, combine:
- conservation,
- equality hypothesis,
- an “equality case” of the no-self-compression or Chaitin barrier theorem,
- any existing characterization of extremal self-description families.

### Step 5: prove incompleteness by contradiction
For `overcapacity_incompleteness`, the cleanest route is contrapositive:
1. Assume `Consistent M ∧ Sound M ∧ ClosureComplete M`.
2. Derive conservation.
3. Contradict `hover` by `linarith`.

This theorem should be a one-line payoff after the wrapper lemma is in place, but make sure the surrounding file develops the conceptual content rather than only this trivial contradiction.

---

## Lean 4 type signatures to include verbatim

In addition to the three targets, include these exact signatures where compatible with the catalog:

```lean
theorem reflection_diagonal_conservation_of_gap_nonneg
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (hgap : 0 ≤ capacityGap M β) :
    reflectionCapacity M β + diagonalCapacity M β ≤ freeEnergySelfBudget M β := by
  ...

theorem certified_lipschitz_thermodynamic_margin
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (h : 0 < capacityGap M β) :
    ∃ ε > 0, ε ≤ freeEnergySelfBudget M β -
      (reflectionCapacity M β + diagonalCapacity M β) := by
  ...

theorem lattice_post_quantum_reserve_bound
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (h : Consistent M ∧ Sound M ∧ ClosureComplete M) :
    reflectionCapacity M β ≤ quantumCertifiedBarrierProfile M β := by
  ...

theorem neural_certified_diagonal_reserve_bound
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (h : Consistent M ∧ Sound M ∧ ClosureComplete M) :
    diagonalCapacity M β ≤ postQuantumDiagonalReserve M β := by
  ...

theorem thermodynamic_phase_transition_trichotomy
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ) :
    IsSubcritical M β ∨ IsCritical M β ∨ IsSupercritical M β := by
  ...
```

The “quantum”, “post_quantum”, “neural”, and “certified” names are deliberate: keep them in theorem names and doc comments.

---

## Explicit computational/analytic bounds

Even if the capacities are abstract reals, force utility by proving concrete numeric inequalities on normalized shares and defects whenever the budget is positive.

Assuming a hypothesis
```lean
(hB : 0 < freeEnergySelfBudget M β)
```
prove results like:

```lean
theorem normalized_shares_sum_le_one
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (hcons : reflectionCapacity M β + diagonalCapacity M β ≤ freeEnergySelfBudget M β)
    (hB : 0 < freeEnergySelfBudget M β) :
    normalizedReflectionShare M β + normalizedDiagonalShare M β ≤ 1 := by
  ...

theorem normalized_reflection_certified_radius
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (hcons : reflectionCapacity M β + diagonalCapacity M β ≤ freeEnergySelfBudget M β)
    (hB : 0 < freeEnergySelfBudget M β) :
    normalizedReflectionShare M β ≤ 1 := by
  ...

theorem normalized_diagonal_certified_radius
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (hcons : reflectionCapacity M β + diagonalCapacity M β ≤ freeEnergySelfBudget M β)
    (hB : 0 < freeEnergySelfBudget M β) :
    normalizedDiagonalShare M β ≤ 1 := by
  ...
```

If you can prove Lipschitz-style perturbation lemmas in `β` from catalog continuity/monotonicity assumptions, do so. For example, under any available assumptions of the form
`|f β₁ - f β₂| ≤ L * |β₁ - β₂|`, derive a certified robustness margin for the subcritical region. If continuity is not available, state and prove a finite-difference bound under an explicit hypothesis.

---

## Cross-domain bridges to include in doc comments and theorem names

Every major theorem block should explicitly connect at least two of the following:
- thermodynamic formal logic,
- statistical mechanics / free energy,
- certified ML robustness / Lipschitz margins,
- lattice or post-quantum cryptographic resource allocation,
- algebraic or tropical phase transitions.

Use theorem names such as:
- `quantumCertifiedBarrierProfile`
- `post_quantum_security_tradeoff`
- `lipschitz_certified_robustness_from_capacity_gap`
- `tropical_phase_split_of_critical_budget` (if you define a max-plus analogue)
- `lattice_reflection_reserve_monotone` (if monotonicity is available)

A strong optional extension is to define a max-plus “tropicalized” capacity surrogate and prove that ordinary criticality implies tropical criticality under an order-preserving embedding. This would create a genuinely new bridge between EML thermodynamics and tropical geometry.

Example optional definitions:

```lean
def tropicalCapacityEnvelope {S : Type _} (M : ClosureSelfModel S) (β : ℝ) : ℝ :=
  max (reflectionCapacity M β) (diagonalCapacity M β)

theorem tropical_phase_split_of_critical_budget
    {S : Type _} (M : ClosureSelfModel S) (β : ℝ)
    (hcrit : IsCritical M β) :
    tropicalCapacityEnvelope M β ≤ freeEnergySelfBudget M β := by
  ...
```

---

## Tactic diversity requirements inside the file

Use all of the following nontrivially somewhere in the proofs:
- `rcases`
- `by_contra`
- `linarith`
- `nlinarith`
- `field_simp`
- `constructor`
- `have`
- `calc`
- `simpa`
- `omega` if any natural-number auxiliary bounds appear

If needed, introduce an auxiliary `Nat`-indexed discretization of inverse temperature windows to justify `omega` usage, e.g. a theorem that a finite partition cannot contain more supercritical slices than allowed by a monotonic reserve principle.

Example optional discrete theorem:

```lean
theorem finite_supercritical_window_bound
    {S : Type _} (M : ClosureSelfModel S) :
    ∀ n : ℕ, (∃ k < n, IsSupercritical M (k : ℝ)) →
      ¬ (Consistent M ∧ Sound M ∧ ClosureComplete M) := by
  ...
```

---

## Minimal-hypothesis discipline

Wherever possible, separate arithmetic lemmas over arbitrary real-valued functions from model-specific thermodynamic lemmas. For example:

```lean
theorem sum_le_iff_gap_nonneg
    (a b c : ℝ) :
    a + b ≤ c ↔ 0 ≤ c - (a + b) := by
  linarith
```

Then instantiate with the three capacity functions. This will improve proof reuse and reduce brittleness.

Similarly, if a theorem only uses ordered-ring structure, generalize it from `ℝ` to a linear ordered field:

```lean
theorem normalized_share_sum_le_one
    {α : Type _} [LinearOrderedField α]
    (r d b : α) (h : r + d ≤ b) (hb : 0 < b) :
    r / b + d / b ≤ 1 := by
  ...
```

and then specialize to `ℝ`. This kind of typeclass abstraction is mandatory for rigor points.

---

## Strong suggested theorem ordering

1. Scalar arithmetic lemmas in a `section OrderedField`.
2. Definitions of gap/defect/criticality.
3. Basic iff lemmas connecting inequalities to gap/defect.
4. Trichotomy theorem.
5. Witness extraction theorems (`∃ ε > 0`).
6. Catalog wrapper lemmas.
7. Main conservation theorem.
8. Rigidity theorem and equality-case corollaries.
9. Incompleteness theorem and contrapositives.
10. Normalized-share and certified-margin corollaries.
11. Symmetry/half-budget theorems.
12. Optional tropical / cryptographic bridge theorems.

---

## Significance to the research program

The file should make mathematically explicit that closure self-models obey a conservation law analogous to a thermodynamic resource budget: reflection and diagonal self-reference compete for a single free-energy reserve. Equality is not generic; it is a rigidity phenomenon forcing an extremal self-description family. Strict overcapacity is therefore not merely “inefficient” but logically impossible under consistency, soundness, and closure completeness.

This is a foundational bridge:
- **Physics**: free-energy budget, criticality, phase transition, rigidity.
- **Logic / EML**: incompleteness via self-reference capacities.
- **ML certified robustness**: positive capacity gap as a certified robustness margin.
- **Cryptography / post-quantum**: reserve splitting as a resource-allocation law analogous to lattice hardness budgets.

The breakthrough is to formalize self-reference barriers as conservation and phase-transition principles, not isolated Gödelian obstructions. This opens a program where logical impossibility is studied with the tools of convex budget geometry, normalized capacities, and critical phenomena.

---

## Deliverables inside the file

- At least 10 new definitions.
- At least 20 theorems, with the three target theorems included.
- Zero `sorry`.
- Rich doc comments on major definitions/theorems, explicitly using words like:
  `thermodynamic`, `quantum`, `certified`, `post_quantum`, `lattice`, `phase_transition`, `robustness`.
- A concluding section of theorem statements named around future expansion, e.g. monotonicity in `β`, continuity of the critical set, or tropicalized capacity envelopes, proved if possible and otherwise isolated behind clearly minimal hypotheses.

Also produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps such as:
1. monotonicity/convexity of `thermodynamicRigidityEnvelope`,
2. tropicalization of the conservation law,
3. entropy-rate analogues for stochastic self-models,
4. post-quantum cryptographic interpretation of diagonal reserve,
5. certified robustness transfer theorems from positive capacity gap.

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
            Prove a sharp conservation inequality linking the two recently introduced self-reference invariants of closure self-models—reflection capacity and diagonal capacity—showing that they are not independent resources but dual faces of a single thermodynamic self-reference budget. The target result is a family of inequalities and extremality criteria of the form reflectionCapacity(M,β)+diagonalCapacity(M,β) ≤ freeEnergySelfBudget(M,β), together with rigidity statements characterizing models that saturate the bound and phase-transition corollaries showing that exceeding a critical combined capacity forces incompleteness or unstable self-evaluation. This is different from the in-flight work on reflection capacity alone and from thermodynamic dual semantics: it synthesizes the two completed partial lines into a new quantitative conservation principle for self-reference.

            ### Precise Mathematical Framing
            Let M be a closure self-model equipped with a temperature-parameterized provability/free-energy semantics from the existing thermodynamic EML framework. Define reflectionCapacity(M,β) as the supremal thermodynamic gain achievable by internally validating reflection instances, and diagonalCapacity(M,β) as the supremal gain achievable by internally encoding fixed-point/diagonal constructions. Introduce a common partition-function normalization over self-descriptions and define freeEnergySelfBudget(M,β) as the log-partition or convex dual budget controlling both operations. The main program is to prove: (1) upper bounds reflectionCapacity ≤ B_refl and diagonalCapacity ≤ B_diag with B_refl+B_diag ≤ freeEnergySelfBudget; (2) a conservation law reflectionCapacity+diagonalCapacity ≤ freeEnergySelfBudget; (3) a Legendre-dual variational characterization of the budget via Gibbs weights on self-descriptions; (4) a rigidity theorem that equality implies concentration on a family of extremal self-descriptions satisfying a KKT-style complementary slackness relation between reflection and diagonal witnesses; (5) a phase-transition incompleteness criterion: if an attempted internal semantics assigns capacities violating the conservation law, then either consistency, soundness, or closure completeness must fail. This opens a quantitative field of self-referential thermodynamics by treating reflection and diagonalization as competing informational resources rather than isolated obstructions.

            ### Lean 4 Sketch
theorem reflection_diagonal_conservation
    (M : ClosureSelfModel S) (β : ℝ) :
    reflectionCapacity M β + diagonalCapacity M β ≤ freeEnergySelfBudget M β := by
  sorry

theorem reflection_diagonal_rigidity
    (M : ClosureSelfModel S) (β : ℝ)
    (hsat : reflectionCapacity M β + diagonalCapacity M β = freeEnergySelfBudget M β) :
    ExtremalSelfDescriptionFamily M β := by
  sorry

theorem overcapacity_incompleteness
    (M : ClosureSelfModel S) (β : ℝ)
    (hover : freeEnergySelfBudget M β < reflectionCapacity M β + diagonalCapacity M β) :
    ¬ (Consistent M ∧ Sound M ∧ ClosureComplete M) := by
  sorry

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `diagonal_phase_transition_incompleteness_of_quantitative` : theorem diagonal_phase_transition_incompleteness_of_quantitative
     (file: EML/DiagonalPhaseTransition.lean)
  2. `sq_half_self_dual_bound` : theorem sq_half_self_dual_bound (x y : ℝ) :
     (file: Bridges/EntropyTropicalDuality.lean)
  3. `two_is_diagonal` : theorem two_is_diagonal : Nat.Prime 2 ∧ 2 % 4 ≠ 1 ∧ 2 % 4 ≠ 3 := by
     (file: EML/SPBExtended/PhotonResearchRound4.lean)
  4. `spb_two_neg_three_not_int` : theorem spb_two_neg_three_not_int : ¬((1 - 2 * (-3) : ℤ) ∣ (2 + (-3))) := by
     (file: EML/SPBIntegers.lean)
  5. `self_reference_bound` : theorem self_reference_bound
     (file: Speculative/Other/DickianMath.lean)

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

Research domain: EML
Research mode: prove
