

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

# Čech Cohomological Classification of Quantum Contextuality: Peres-Mermin Klein Four-Group, Mermin-GHZ Rank-One Obstruction, and Entanglement-Cohomology Hierarchy

## The Vision

Quantum contextuality—the impossibility of assigning definite values to all observables simultaneously while respecting measurement compatibility—is the deepest structural feature distinguishing quantum from classical physics. Abramsky & Brandenburger (2011) revealed that contextuality is fundamentally a *sheaf cohomology* phenomenon: the obstruction to a global section of the value presheaf lives in Čech cohomology H¹(S, G). Yet no machine-verified proof has ever computed H¹ for any concrete quantum scenario. This brief opens the field of **computational cohomological contextuality classification**: we prove that the Peres-Mermin square yields H¹ ≅ (ℤ₂)² (the Klein four-group), the Mermin-GHZ scenario yields H¹ ≅ ℤ₂, and the cohomological rank strictly increases with multipartite entanglement depth. This creates a *certified randomness quantifier*: the rank of H¹ is a lower bound on the bits of certified randomness extractable from contextuality-based protocols (Pironio et al., Nature 2010).

## Core Structures (5+ New Definitions)

```lean
/-- A measurement scenario: the combinatorial skeleton of a quantum experiment.
Bridge: connects algebraic topology (nerve complexes) to quantum foundations (contextuality). -/
structure MeasurementScenario where
  measurements : Finset ℕ
  outcomes : ℕ  -- |O|, typically 2 for qubit scenarios
  contexts : Finset (Finset ℕ)  -- maximal compatible sets
  covers_measurements : ∀ m ∈ measurements, ∃ c ∈ contexts, m ∈ c
  contexts_pairwise_overlaps : ∀ c₁ c₂ ∈ contexts, (c₁ ∩ c₂).Nonempty ∨ c₁ = c₂

/-- The Čech cochain complex over a measurement scenario with coefficients in a group.
Bridge: connects homological algebra to quantum information theory. -/
structure CechComplex (S : MeasurementScenario) (G : Type*) [AddCommGroup G] where
  zero_cochains : (c : S.contexts) → (c → Fin S.outcomes) → G
  one_cochains : ∀ c₁ c₂ ∈ S.contexts, (c₁ ∩ c₂).Nonempty → G
  coboundary_zero : (c₁ c₂ ∈ S.contexts) → (h : (c₁ ∩ c₂).Nonempty) →
    one_cochains c₁ c₂ h = zero_cochains c₁ (restrict_to_overlap_left _ _) -
                           zero_cochains c₂ (restrict_to_overlap_right _ _)
  coboundary_one : ∀ c₁ c₂ c₃ ∈ S.contexts, (h₁₂ : (c₁ ∩ c₂).Nonempty) →
    (h₂₃ : (c₂ ∩ c₃).Nonempty) → (h₁₃ : (c₁ ∩ c₃).Nonempty) →
    one_cochains c₁ c₃ h₁₃ = one_cochains c₁ c₂ h₁₂ + one_cochains c₂ c₃ h₂₃

/-- Čech cohomology group H¹(S, G) as a computable quotient.
Bridge: connects computational topology to certified quantum randomness. -/
def CechCohomologyH1 (S : MeasurementScenario) (G : Type*) [AddCommGroup G] : Type*
  := (ker (coboundaryMap₁ S G)) ⧸ (im (coboundaryMap₀ S G))

/-- A contextual obstruction: a nontrivial element of H¹ certifying contextuality.
Bridge: connects cohomology theory to quantum cryptography (certified randomness). -/
structure ContextualObstruction (S : MeasurementScenario) where
  cocycle : CechCocycle S (ZMod 2)
  not_coboundary : ¬∃ (s : CechCoboundary S (ZMod 2)), cocycle = s.1
  certified_randomness_bits : ℕ  -- lower bound on extractable randomness

/-- Entanglement depth classification via cohomological rank.
Bridge: connects multipartite entanglement to topological invariants. -/
structure EntanglementCohomologyRank where
  depth : ℕ
  scenario : MeasurementScenario
  rank_H1 : ℕ  -- dim_{ZMod 2} H¹(scenario, ZMod 2)
  depth_rank_monotone : depth ≤ rank_H1  -- hierarchy property
```

## The Peres-Mermin Square: Precise Construction

```lean
/-- The Peres-Mermin measurement scenario: 9 observables in a 3×3 grid, 6 contexts.
Each context is a commuting set of 3 observables whose product is ±I.
Bridge: connects quantum nonlocality to the Klein four-group structure in H¹. -/
def PeresMerminScenario : MeasurementScenario := {
  measurements := {0,1,2,3,4,5,6,7,8}
  outcomes := 2
  contexts := {
    -- Row contexts: {A₁, A₂, A₁A₂}, {B₁, B₂, B₁B₂}, {A₁B₁, A₂B₂, A₁A₂B₁B₂}
    {0, 1, 2}, {3, 4, 5}, {6, 7, 8},
    -- Column contexts: {A₁, B₁, A₁B₁}, {A₂, B₂, A₂B₂}, {A₁A₂, B₁B₂, A₁A₂B₁B₂}
    {0, 3, 6}, {1, 4, 7}, {2, 5, 8}
  }
  covers_measurements := by
    intro m hm; fin_cases hm <;> use {0,1,2} <;> simp
  contexts_pairwise_overlaps := by
    -- Each pair of contexts shares at least one measurement
    intro c₁ c₂ hc₁ hc₂; by_contra h_ne
    -- Exhaustive case analysis on the 6 contexts
    ...
}
```

## Main Theorems (10+ Required)

### Theorem 1: H¹ is a Computable ℤ₂-Vector Space

```lean
/-- H¹(S, ℤ₂) is a finite-dimensional ℤ₂-vector space with computable dimension.
The dimension equals dim(ker δ₁) - dim(im δ₀) in the Čech complex.
Bridge: connects computational homological algebra to quantum contextuality classification.
Complexity: O(n·m²) where n = |contexts|, m = max |overlap|. -/
theorem cech_H1_vector_space_dim (S : MeasurementScenario) :
  ∃ (d : ℕ), Module.rank (ZMod 2) (CechCohomologyH1 S (ZMod 2)) = d ∧
  d = dim_ker_coboundary_one S - dim_im_coboundary_zero S ∧
  d ≤ S.contexts.card := by
  -- Strategy A: Direct linear algebra over ZMod 2.
  -- (1) Show CechCohomologyH1 S (ZMod 2) carries a ZMod 2-module structure.
  -- (2) Show it is finite-dimensional since the cochain groups are finite.
  -- (3) Apply rank-nullity to the coboundary maps.
  -- (4) Bound d by |contexts| since C¹ has dimension at most |contexts| choose 2.
  sorry
```

### Theorem 2: Peres-Mermin Yields Klein Four-Group

```lean
/-- The Peres-Mermin scenario has H¹ ≅ (ℤ₂)²: the Klein four-group.
This is the first machine-verified Čech cohomology computation in quantum foundations.
The two independent obstructions correspond to:
  (1) The row-wise parity obstruction (Mermin's magic square row condition)
  (2) The column-wise parity obstruction (Mermin's magic square column condition)
Bridge: connects the Klein four-group (algebra) to quantum contextuality (physics).
Certified randomness: at least 2 bits of certified randomness from PM contextuality. -/
theorem pm_cohomology_klein_four :
  Module.rank (ZMod 2) (CechCohomologyH1 PeresMerminScenario (ZMod 2)) = 2 := by
  -- Strategy: Direct computation of the Čech complex.
  -- (1) Enumerate all ZMod 2-valued 0-cochains: 2^6 = 64 assignments (one per context).
  -- (2) Compute im(δ₀): the 2^6 coboundaries span a subspace of dimension 4.
  --     Key insight: the row constraints reduce 6 degrees of freedom to 4.
  -- (3) Enumerate all ZMod 2-valued 1-cochains: one per overlap pair.
  --     There are 12 overlap pairs (each row intersects 2 columns, 3 rows × 2 = 6,
  --     plus the dual; but accounting for symmetry gives 12).
  -- (4) Compute ker(δ₁): cocycles satisfy the consistency condition on triple overlaps.
  --     The cocycle condition on each of the 4 triple overlaps gives 4 linear constraints.
  --     ker(δ₁) has dimension 6.
  -- (5) H¹ = ker(δ₁)/im(δ₀) has dimension 6 - 4 = 2.
  -- (6) Construct explicit generators: the row-parity cocycle and column-parity cocycle.
  sorry
```

### Theorem 3: Mermin-GHZ Yields ℤ₂

```lean
/-- The Mermin-GHZ scenario has H¹ ≅ ℤ₂: exactly one independent obstruction.
This obstruction is the GHZ paradox (Mermin, Am. J. Phys. 1990).
Bridge: connects the GHZ paradox (quantum foundations) to cohomology (algebraic topology).
Certified randomness: at least 1 bit of certified randomness from GHZ contextuality. -/
theorem ghz_cohomology_z2 :
  Module.rank (ZMod 2) (CechCohomologyH1 GHZScenario (ZMod 2)) = 1 := by
  -- Strategy: Analogous direct computation.
  -- (1) GHZ has 3 qubits, 4 contexts (the 4 GHZ measurement settings).
  -- (2) The overlap structure is simpler than PM: each pair of contexts shares 1 measurement.
  -- (3) im(δ₀) has dimension 3 (one constraint per qubit).
  -- (4) ker(δ₁) has dimension 4.
  -- (5) H¹ = ker(δ₁)/im(δ₀) has dimension 4 - 3 = 1.
  -- (6) The single generator is the GHZ parity cocycle.
  sorry
```

### Theorem 4: Entanglement-Cohomology Hierarchy

```lean
/-- The cohomological rank strictly increases with multipartite entanglement depth.
This establishes a hierarchy: rank(H¹(PM)) > rank(H¹(GHZ)), i.e., 2 > 1.
Bridge: connects multipartite entanglement depth (quantum info) to topological invariants (algebraic topology).
This is the cohomological analogue of the entanglement classification hierarchy. -/
theorem entanglement_cohomology_hierarchy :
  (EntanglementCohomologyRank.mk 3 PeresMerminScenario 2 (by omega)).rank_H1 >
  (EntanglementCohomologyRank.mk 3 GHZScenario 1 (by omega)).rank_H1 := by
  -- Follows directly from pm_cohomology_klein_four and ghz_cohomology_z2.
  omega
```

### Theorem 5: Certified Randomness from Cohomological Rank

```lean
/-- The rank of H¹(S, ℤ₂) is a lower bound on certified randomness bits.
Bridge: connects cohomological invariants (topology) to certified randomness (cryptography).
This enables post-quantum randomness certification: the cohomological rank
certifies randomness even against quantum adversaries with bounded entanglement. -/
theorem certified_randomness_from_cohomology (S : MeasurementScenario) :
  ∀ (ob : ContextualObstruction S),
    ob.certified_randomness_bits ≤
      Module.rank (ZMod 2) (CechCohomologyH1 S (ZMod 2)) := by
  -- Strategy: Information-theoretic argument.
  -- (1) Each independent cohomological obstruction yields a distinct parity constraint.
  -- (2) Each parity constraint provides at most 1 bit of certified randomness.
  -- (3) The total certified randomness is bounded by the number of independent
  --     obstructions, which equals rank(H¹).
  -- (4) This follows from the chain rule for conditional entropy and the
  --     fact that cohomological obstructions are linearly independent over ℤ₂.
  sorry
```

### Theorem 6: PM Obstructions Are Independent

```lean
/-- The two Peres-Mermin obstructions are linearly independent over ℤ₂.
This means no single assignment can simultaneously resolve both the row and column
parity obstructions — the core of the Peres-Mermin paradox.
Bridge: connects linear independence (algebra) to quantum paradox (physics). -/
theorem pm_obstructions_independent :
  ∀ (a b : ZMod 2), a • pm_row_cocycle + b • pm_column_cocycle = 0 → a = 0 ∧ b = 0 := by
  -- Strategy: Evaluate on specific overlaps to extract a and b.
  -- (1) Evaluate on the overlap {0} ∩ {0}: the row cocycle is 1, column is 0 → a = 0.
  -- (2) Evaluate on the overlap {1} ∩ {1}: the row cocycle is 0, column is 1 → b = 0.
  sorry
```

### Theorem 7: Coboundary Maps Form a Complex

```lean
/-- The Čech coboundary maps satisfy δ₁ ∘ δ₀ = 0, making the cochain groups
into a genuine cochain complex. This is the foundational algebraic fact
that makes cohomology well-defined.
Bridge: connects homological algebra to quantum measurement theory. -/
theorem coboundary_complex_property (S : MeasurementScenario) (G : Type*) [AddCommGroup G] :
  ∀ (f : CechZeroCochain S G), coboundaryMap₁ S G (coboundaryMap₀ S G f) = 0 := by
  -- Strategy: Unfold definitions and use antisymmetry of the overlap.
  -- (1) (δ₁ ∘ δ₀)f(c₁, c₂, c₃) = f(c₁|_{c₂∩c₃}) - f(c₂|_{c₁∩c₃})
  --     - (f(c₂|_{c₁∩c₃}) - f(c₃|_{c₁∩c₂}))
  -- (2) By restriction consistency on triple overlaps, terms cancel.
  -- (3) This is the Čech analogue of d² = 0 in de Rham cohomology.
  sorry
```

### Theorem 8: Contextuality Detection via H¹

```lean
/-- A scenario S is contextual (has no global section) iff H¹(S, ℤ₂) ≠ 0.
This is the cohomological detection theorem: nonvanishing cohomology detects contextuality.
Bridge: connects cohomology (topology) to Kochen-Specker contextuality (physics).
This is the computational backbone of automated contextuality verification. -/
theorem contextuality_detection (S : MeasurementScenario) :
  (∃ (ob : ContextualObstruction S), True) ↔
    Module.rank (ZMod 2) (CechCohomologyH1 S (ZMod 2)) > 0 := by
  -- Strategy: Constructive equivalence.
  -- Forward: A contextual obstruction is a nontrivial cocycle class, so rank > 0.
  -- Backward: If rank > 0, pick any nonzero element of H¹; it represents a
  --   cocycle that is not a coboundary, hence a contextual obstruction.
  sorry
```

### Theorem 9: Computational Complexity of Cohomology Computation

```lean
/-- H¹(S, ℤ₂) can be computed in O(|contexts|³ · |measurements|) time over ℤ₂.
This is achieved by Gaussian elimination on the coboundary matrix over ℤ₂.
Bridge: connects computational complexity (CS) to quantum contextuality (physics).
This enables real-time contextuality classification for quantum experiments. -/
theorem cech_H1_computation_complexity (S : MeasurementScenario) :
  ∃ (T : ℕ), T ≤ S.contexts.card ^ 3 * S.measurements.card ∧
    ComputesH1 T S := by
  -- Strategy: Reduce to linear algebra over ZMod 2.
  -- (1) The coboundary map δ₀ is a matrix over ZMod 2 with |contexts| columns
  --     and |overlaps| rows.
  -- (2) The coboundary map δ₁ is a matrix over ZMod 2 with |overlaps| columns
  --     and |triple_overlaps| rows.
  -- (3) Gaussian elimination over ZMod 2 runs in O(n³) where n = |contexts|.
  -- (4) Total: O(|contexts|³) for rank computation, times |measurements| for
  --     the size of each row.
  sorry
```

### Theorem 10: Lattice-Based Cryptographic Connection

```lean
/-- The cohomological obstruction group H¹(S, ℤ₂) embeds into the lattice
of Boolean assignments on S.measurements. This embedding preserves the
ZMod 2-module structure and enables lattice-based cryptographic protocols
for certified randomness.
Bridge: connects lattice cryptography (post-quantum security) to quantum contextuality (physics).
The embedding maps each cohomological obstruction to a short vector in the
assignment lattice, enabling worst-case to average-case reductions. -/
theorem cohomology_lattice_embedding (S : MeasurementScenario) :
  ∃ (f : CechCohomologyH1 S (ZMod 2) →+ (S.measurements → ZMod 2)),
    Function.Injective f ∧
    ∀ (x : CechCohomologyH1 S (ZMod 2)),
      ‖f x‖ ≤ S.contexts.card := by
  -- Strategy: Construct the embedding from the evaluation map.
  -- (1) Each cocycle class [α] determines a partial assignment on overlaps.
  -- (2) Extend to a full assignment on measurements by choosing representatives
  --     from each context (using the axiom of choice for finite sets).
  -- (3) The ZMod 2-linearity follows from the linearity of the coboundary maps.
  -- (4) Injectivity: if [α] ≠ 0, then α is not a coboundary, so the induced
  --     assignment differs on some overlap, hence on some measurement.
  -- (5) Norm bound: each measurement appears in at most |contexts| overlaps.
  sorry
```

### Theorem 11: Quantum Hamiltonian Ground State Energy Bound

```lean
/-- The cohomological rank provides a lower bound on the ground state energy
of the associated quantum Hamiltonian H_S = Σ_{c ∈ contexts} Π_c.
This connects contextuality to the many-body localization problem.
Bridge: connects quantum Hamiltonians (condensed matter) to Čech cohomology (topology).
The bound is: E₀(H_S) ≥ rank(H¹(S, ℤ₂)) · ε where ε is the contextuality strength. -/
theorem hamiltonian_ground_state_cohomology_bound (S : MeasurementScenario)
    (ε : ℝ) (hε : 0 < ε) :
  ∃ (H : Matrix (Fin S.measurements.card) (Fin S.measurements.card) ℂ),
    IsHermitian H ∧
    groundStateEnergy H ≥
      (Module.rank (ZMod 2) (CechCohomologyH1 S (ZMod 2)) : ℝ) * ε := by
  -- Strategy: Construct the Hamiltonian from context projectors.
  -- (1) For each context c, define Π_c = Π_{m ∈ c} (I - P_m) where P_m
  --     projects onto the +1 eigenspace of observable m.
  -- (2) H_S = Σ_c Π_c is a sum of commuting projectors.
  -- (3) Each cohomological obstruction forces at least one context to have
  --     energy ≥ ε (since the obstruction prevents a simultaneous +1 assignment).
  -- (4) By linear independence of obstructions, the total energy is at least
  --     rank(H¹) · ε.
  sorry
```

## Proof Strategy Architecture

**Path A (Direct Computation — RECOMMENDED for PM and GHZ):**
1. Define the overlap graph of each scenario as a finite structure.
2. Write the coboundary matrices δ₀ and δ₁ explicitly as `Matrix` over `ZMod 2`.
3. Compute `ker(δ₁)` and `im(δ₀)` by Gaussian elimination over `ZMod 2`.
4. Apply `rank_nullity` to get `dim(H¹) = dim(ker δ₁) - dim(im δ₀)`.
5. Construct explicit generators and prove independence.

**Path B (Abstract Nerve Theorem):**
1. Show that H¹(S, G) depends only on the nerve complex N(S).
2. Use the nerve theorem to reduce to simplicial cohomology.
3. Apply existing Mathlib results on simplicial cohomology of small complexes.
4. This path is more elegant but requires more infrastructure.

**Path C (Sheaf-Theoretic — for future generalization):**
1. Define presheaves on measurement scenarios.
2. Show that the value presheaf has no global section iff H¹ ≠ 0.
3. This is the most general approach but requires the most setup.

**Recommendation:** Use Path A for the concrete PM and GHZ computations. Path A is most promising because (a) the scenarios are small enough for explicit matrix computation, (b) Gaussian elimination over `ZMod 2` is well-understood and can be verified in Lean, and (c) the explicit generators provide the strongest connection to certified randomness.

## Revolutionary Significance

This work opens three new fields simultaneously:

1. **Computational Cohomological Contextuality**: Automated verification of contextuality via cohomology computation. Any quantum experiment can now be classified by its H¹ rank in O(|contexts|³) time.

2. **Cohomological Randomness Certification**: The rank of H¹ is a *certified* lower bound on extractable randomness bits. This creates a new class of randomness certification protocols where the certification is purely topological—immune to side-channel attacks that exploit physical implementation details.

3. **Entanglement-Cohomology Hierarchy**: The strict inequality rank(H¹(PM)) > rank(H¹(GHZ)) is the first step toward a complete classification of multipartite entanglement via topological invariants. This could resolve open questions about the structure of the entanglement polytope.

## FUTURE_DIRECTIONS.md (Required Output)

Aristotle MUST produce a structured `FUTURE_DIRECTIONS.md` with the following concrete next steps:

1. **Tropical Contextuality**: Define tropical Čech cohomology over the tropical semiring (ℝ ∪ {∞}, min, +) and prove that tropical H¹ classifies *approximate* contextuality with certified robustness bounds.

2. **Post-Quantum Key Distribution from H¹**: Construct a key distribution protocol where security reduces to the hardness of computing H¹ for adversarially chosen scenarios—this is a lattice-type problem over ZMod 2.

3. **Neural Contextuality Certification**: Train a neural network to predict H¹ rank from scenario statistics, then certify the prediction using the cohomological Lipschitz bound from Theorem 10.

4. **Čech-De Rham Spectral Sequence for Quantum Field Theories**: Extend from finite scenarios to infinite measurement spaces (QFT) using the Čech-de Rham spectral sequence, connecting to the algebraic K-theory of operator algebras.

5. **Topological Quantum Error Correction**: Show that the cohomological rank of a stabilizer code's measurement scenario determines the code distance, creating a direct link between contextuality and quantum error correction thresholds.

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
            Open the field of computational cohomological contextuality classification by proving three foundational results: (1) For any finite measurement scenario S with n contexts and m pairwise overlaps, H¹(S, ℤ₂) is a computable ℤ₂-vector space whose dimension equals dim(ker δ₁) − dim(im δ₀) in the Čech complex. (2) The Peres-Mermin scenario satisfies H¹(PM, ℤ₂) ≅ (ℤ₂)² (the Klein four-group), yielding exactly 2 independent contextual obstructions — the first machine-verified Čech cohomology computation in quantum foundations. (3) The Mermin-GHZ scenario satisfies H¹(GHZ, ℤ₂) ≅ ℤ₂, yielding exactly 1 independent obstruction, and the cohomological rank strictly increases with multipartite entanglement depth, establishing an entanglement-cohomology hierarchy: rank(H¹(PM)) > rank(H¹(GHZ)). This enables automated contextuality classification and certified randomness quantification via cohomological invariants.

            ### Precise Mathematical Framing
            Given a measurement scenario S = (X, C, O) with measurements X, contexts C ⊆ P(X), and outcome set O = ℤ₂, define the Čech complex Č⁰(S, ℤ₂) → Č¹(S, ℤ₂) → Č²(S, ℤ₂) where Č⁰ = ℤ₂^|C| (one value per context), Č¹ = ℤ₂^|U| (one value per overlap pair), with coboundary δ₀: Č⁰ → Č¹ given by (δ₀f)(c∩c') = f(c) − f(c'). Then H¹(S, ℤ₂) = ker(δ₁)/im(δ₀). Theorem 1 (Computability): For finite S, dim(H¹(S, ℤ₂)) = dim(ker δ₁) − dim(im δ₀), computable by native_decide. Theorem 2 (Peres-Mermin): With 6 measurements, 4 contexts, and 6 pairwise overlaps, the Čech complex yields dim(H¹(PM, ℤ₂)) = 2, so H¹(PM, ℤ₂) ≅ (ℤ₂)². The two independent obstructions correspond to the two parity constraints that the GHZ state violates. Theorem 3 (GHZ Comparison): The 3-party Mermin-GHZ scenario with 4 contexts yields H¹(GHZ, ℤ₂) ≅ ℤ₂ (rank 1), and there is a natural injective map H¹(GHZ) ↪ H¹(PM) showing PM has strictly richer cohomological structure, reflecting deeper multipartite entanglement.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `meta_klein_four_group` : theorem meta_klein_four_group :
     (file: Algebra/Other/TwoEyesNextSteps.lean)
  2. `ghz_coherence_dimension_independent` : theorem ghz_coherence_dimension_independent :
     (file: Logic/CoherenceStratification.lean)
  3. `quantum_hamming_bound_5_1_3` : theorem quantum_hamming_bound_5_1_3 :
     (file: Physics/Quantum/MoonshotQuantum.lean)
  4. `quantum_birthday_bound` : theorem quantum_birthday_bound (S : ℕ) (hS : 0 < S) :
     (file: Physics/QuantumE8ModularForms.lean)
  5. `trop_char_finite_trivial` : theorem trop_char_finite_trivial {G : Type*} [Group G] [Fintype G]
     (file: Physics/ArchitectureOfReality/TropicalLanglands.lean)

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



Recent successful concepts: Sheaf-Theoretic Causal Calculus: Presheaf Interventions, Čech Cohomological Identifiability Obstructions, and Local-to-Global Adjustment, Non-Archimedean Information Geometry: p-adic Fisher Metric, Ultrametric Statistical Manifolds, and Valuation-Theoretic Cramér-Rao Bounds, Cohomological Quantum Contextuality: Sheaf-Theoretic Kochen-Specker, Čech Obstruction Classes, and All-vs-Nothing Contextuality Bounds


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

Research domain: Physics
Research mode: prove
