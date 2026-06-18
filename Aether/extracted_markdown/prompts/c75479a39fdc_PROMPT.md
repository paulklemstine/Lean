

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

## YOUR ASSIGNMENT: Proof-Semiring Coding Theorem via Prime-Spectrum Channels and Stone Entropy

Work in Lean 4 on a new file developing a finite-information theory on the prime congruence spectrum of a proof semiring. The central objective is to turn clopen observables on `zeroLocus` / `Spec`-style spaces attached to `ProofCongruence.IsPrime` into finite channels, then prove entropy / mutual-information monotonicity under quotient-induced spectral maps, and finally package a computable capacity approximation for finitely generated proof semirings with decidable clopen basis.

The file must be a complete formal narrative: definitions, examples, finite combinatorics, entropy lemmas, quotient/refinement theorems, and an executable approximation theorem. Use theorem names and doc comments containing application keywords such as `quantum`, `thermodynamic`, `post_quantum`, `certified`, `lattice`, `neural`, `robustness`.

### CORE FORMALIZATION AXES

Bridge at least these domains in the actual statements and doc comments:

1. **Algebra / Stone duality**: prime congruence spectra, clopen sets, quotient maps, refinement.
2. **Information theory / thermodynamic entropy**: finite partitions, Shannon entropy, mutual information, channel capacity upper/lower bounds.
3. **Cryptography / certified robustness / quantum observability**: interpret observables as leakage channels, quotient maps as abstraction/coarsening, and clopen refinement as certified information gain.

You should define enough infrastructure so the main theorem is not an isolated statement but the apex of a reusable API.

---

## TASK SECTION 1: New definitions and structures

Introduce at least 10 new definitions/structures/abbreviations, with computable finite incarnations whenever possible.

Suggested Lean targets (adapt names to actual existing API, but preserve the mathematical intent):

```lean
universe u v

open Classical

/-- A finite clopen observable partition on a spectral object associated to a proof semiring.
Bridge: connects Stone duality to cryptographic leakage channels. -/
structure FiniteClopenPartition (α : Type u) where
  carrier : Finset (Set α)
  nonempty_blocks : ∀ s ∈ carrier, s.Nonempty
  pairwise_disjoint : Set.PairwiseDisjoint (↑carrier : Set (Set α))
  sUnion_eq_univ : ⋃₀ (↑carrier : Set (Set α)) = Set.univ

/-- Refinement relation between finite clopen partitions. -/
def FiniteClopenPartition.Refines {α : Type u}
    (P Q : FiniteClopenPartition α) : Prop :=
  ∀ s ∈ P.carrier, ∃ t ∈ Q.carrier, s ⊆ t

/-- Index type of blocks in a finite partition, packaged as a finite type. -/
def FiniteClopenPartition.BlockIdx {α : Type u}
    (P : FiniteClopenPartition α) := {s // s ∈ P.carrier}

/-- Observable channel induced by a partition and a point-to-state map. -/
def obsChannel {α : Type u} (P : FiniteClopenPartition α) :
    α → P.BlockIdx := ...

/-- Finite probability mass function induced by counting a finite sample through an observable. -/
def empiricalBlockPMF {α : Type u} [Fintype α] [DecidableEq α]
    (P : FiniteClopenPartition α) : P.BlockIdx → ℚ := ...

/-- Shannon entropy of a finite rational-valued distribution. -/
def rationalEntropy {ι : Type u} [Fintype ι] (p : ι → ℚ) : ℝ := ...

/-- Mutual information of two finite observables on a finite sample space. -/
def rationalMutualInfo {α β γ : Type u} [Fintype α] ... :
    (α → β) → (α → γ) → ℝ := ...

/-- A clopen basis with decidable membership and finite generation witness. -/
class DecidableClopenBasis (α : Type u) where
  basis : Finset (Set α)
  decidable_mem : ∀ x s, Decidable (x ∈ s)
  covers : ⋃₀ (↑basis : Set (Set α)) = Set.univ

/-- A finitely generated proof-semiring observable model. -/
structure ProofSpectrumObservableModel (S : Type u) where
  Prime : Type v
  instFintypePrime : Fintype Prime
  instDecidableEqPrime : DecidableEq Prime
  generatorCount : ℕ
  basicClopens : Finset (Set Prime)
  basis_is_clopen : Prop
  basis_covers : ⋃₀ (↑basicClopens : Set (Set Prime)) = Set.univ

attribute [instance] ProofSpectrumObservableModel.instFintypePrime
attribute [instance] ProofSpectrumObservableModel.instDecidableEqPrime

/-- Capacity approximation obtained by maximizing entropy over basis-generated observables.
Bridge: connects prime-spectrum semantics to post_quantum leakage estimation. -/
def capacityApprox (M : ProofSpectrumObservableModel S) : ℝ := ...

/-- Quotient map on spectra modeled as a function respecting clopen pullback. -/
structure SpectrumQuotientMap (α : Type u) (β : Type v) where
  toFun : α → β
  pullback_clopen :
    ∀ s : Set β, s ∈ ({} : Set (Set β)) → True  -- replace by actual clopen API if available

/-- Pullback partition along a quotient / abstraction map. -/
def pullbackPartition {α : Type u} {β : Type v}
    (f : α → β) (Q : FiniteClopenPartition β) : FiniteClopenPartition α := ...
```

Also add at least 5 more helper definitions, for example:

- `partitionCard : FiniteClopenPartition α → ℕ`
- `partitionEntropyBound`
- `observableRefinementWitness`
- `generatorObservable`
- `jointPartition`
- `pushforwardPMF`
- `channelLeakageScore`
- `stoneEntropy`
- `thermodynamicObservableCost`
- `postQuantumLeakageRadius`

The definitions should be genuinely useful and used later in the theorems.

---

## TASK SECTION 2: Exact theorem targets

You should prove a family of theorems culminating in a coding theorem. State them as close as possible to the following Lean signatures, adapting only where the existing API forces small changes.

### A. Finite partition infrastructure

```lean
theorem blockIdx_nonempty {α : Type u} (P : FiniteClopenPartition α) :
    Nonempty P.BlockIdx := ...

theorem exists_block_mem {α : Type u} (P : FiniteClopenPartition α) (x : α) :
    ∃ b : P.BlockIdx, x ∈ (b : Set α) := ...

theorem unique_block_mem {α : Type u} (P : FiniteClopenPartition α) (x : α) :
    ∀ b₁ b₂ : P.BlockIdx, x ∈ (b₁ : Set α) → x ∈ (b₂ : Set α) → b₁ = b₂ := ...

theorem obsChannel_spec {α : Type u} (P : FiniteClopenPartition α) (x : α) :
    x ∈ ((obsChannel P x : P.BlockIdx) : Set α) := ...

theorem obsChannel_fiber_eq_block {α : Type u} [DecidableEq α]
    (P : FiniteClopenPartition α) (b : P.BlockIdx) :
    {x | obsChannel P x = b} = (b : Set α) := ...
```

### B. Refinement and entropy monotonicity

```lean
theorem refinement_card_le {α : Type u}
    {P Q : FiniteClopenPartition α} :
    P.Refines Q → Q.carrier.card ≤ P.carrier.card := ...

theorem pullback_refines {α : Type u} {β : Type v}
    (f : α → β) (Q : FiniteClopenPartition β) :
    (pullbackPartition f Q).Refines
      { carrier := Finset.univ.image (fun _ => Set.univ), ... } := ...

theorem entropy_le_log_card {ι : Type u} [Fintype ι]
    (p : ι → ℚ) (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : Finset.univ.sum p = 1) :
    rationalEntropy p ≤ Real.log (Fintype.card ι) := ...

theorem entropy_monotone_under_refinement_counting
    {α : Type u} [Fintype α] [DecidableEq α]
    {P Q : FiniteClopenPartition α}
    (hPQ : P.Refines Q) :
    rationalEntropy (empiricalBlockPMF Q) ≤ rationalEntropy (empiricalBlockPMF P) := ...
```

Here the entropy monotonicity can be proved first in a simpler counting/uniform setting if full generality is awkward. A strong special case is acceptable if precisely stated and then used for the coding theorem.

### C. Quotient maps on spectra and clopen pullback

Model the quotient map abstractly if necessary as a plain function with a pullback operation.

```lean
theorem pullbackPartition_block_preimage {α : Type u} {β : Type v}
    (f : α → β) (Q : FiniteClopenPartition β) (b : Q.BlockIdx) :
    ∃ c ∈ (pullbackPartition f Q).carrier, c = f ⁻¹' (b : Set β) := ...

theorem quotient_observable_factors
    {α : Type u} {β : Type v}
    (f : α → β) (Q : FiniteClopenPartition β) :
    ∃ g : (pullbackPartition f Q).BlockIdx → Q.BlockIdx,
      ∀ x, g (obsChannel (pullbackPartition f Q) x) = obsChannel Q (f x) := ...

theorem mutualInfo_monotone_under_spectrum_quotient
    {α : Type u} {β : Type v} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β]
    (f : α → β) (Q : FiniteClopenPartition β) :
    ∃ C : ℝ, C = rationalMutualInfo (fun x => obsChannel (pullbackPartition f Q) x)
      (fun x => obsChannel Q (f x)) ∧ 0 ≤ C := ...
```

If proving a full data processing inequality is too heavy, prove a rigorous monotonicity or factorization statement sufficient to show that quotienting cannot increase observable complexity beyond the pullback partition. Explicitly isolate the stronger desired theorem as a conjecture with Lean type signature.

### D. Prime-spectrum specialization

Specialize the abstract infrastructure to the proof-semiring spectrum API from the catalog. Use the actual imported names such as `vanishesAt`, `zeroLocus`, `theoryOf`, `ProofCongruence.IsPrime`, and any `Spec`-like structure already present.

Examples of target signatures:

```lean
def generatorZeroLocusPartition
    {S : Type u} (M : ProofSpectrumObservableModel S) :
    FiniteClopenPartition M.Prime := ...

theorem generatorZeroLocusPartition_sound
    {S : Type u} (M : ProofSpectrumObservableModel S) :
    ∀ p : M.Prime, ∃ b : (generatorZeroLocusPartition M).BlockIdx,
      p ∈ (b : Set M.Prime) := ...

theorem theoryOf_observable_respects_quotient
    {S : Type u} (M : ProofSpectrumObservableModel S)
    (p q : M.Prime) :
    theoryOf p = theoryOf q →
    obsChannel (generatorZeroLocusPartition M) p =
    obsChannel (generatorZeroLocusPartition M) q := ...
```

If the exact `theoryOf` type prevents direct equality, weaken to inclusion or extensional equality on the chosen generating family.

### E. Capacity approximation and explicit computational bounds

Define a computable approximation based on a finite search over basis-generated partitions. Prove explicit upper/lower bounds.

```lean
def allBasisGeneratedPartitions {S : Type u}
    (M : ProofSpectrumObservableModel S) :
    Finset (FiniteClopenPartition M.Prime) := ...

def capacityApprox {S : Type u}
    (M : ProofSpectrumObservableModel S) : ℝ :=
  Finset.sup (allBasisGeneratedPartitions M) (fun P => rationalEntropy (empiricalBlockPMF P))

theorem capacityApprox_nonneg {S : Type u}
    (M : ProofSpectrumObservableModel S) :
    0 ≤ capacityApprox M := ...

theorem capacityApprox_le_log_basis
    {S : Type u} (M : ProofSpectrumObservableModel S) :
    capacityApprox M ≤ Real.log (2 ^ M.generatorCount) := ...

theorem capacityApprox_generator_lower_bound
    {S : Type u} (M : ProofSpectrumObservableModel S) :
    ∃ P ∈ allBasisGeneratedPartitions M,
      rationalEntropy (empiricalBlockPMF P) ≤ capacityApprox M := ...

theorem capacityApprox_runtime_bound
    {S : Type u} (M : ProofSpectrumObservableModel S) :
    ∃ K : ℕ, K = 2 ^ M.generatorCount ∧
      Nat.card (allBasisGeneratedPartitions M) ≤ K := ...
```

If `Finset.sup` over `ℝ` is awkward, use `sSup` over a finite set or package the approximation as a `∃ P, IsGreatest ...`.

Also prove at least one theorem with an explicit asymptotic doc comment such as:
- enumeration cost `O(2^g * g log g)` for `g = generatorCount`,
- entropy evaluation cost `O(n log n)` on `n` blocks,
- total search cost bounded by `O(2^g * g log g)` or a formalized coarse bound like `≤ C * 2^g * (g+1)^2`.

A precise Lean asymptotic framework is optional; a concrete numeric inequality in `ℕ` or `ℝ` is sufficient and preferred.

---

## TASK SECTION 3: Main theorem package

Prove a final theorem named with explicit impact keywords. A recommended statement:

```lean
/--
`proofSemiring_quantum_post_quantum_coding_theorem`:
the observable information obtainable from any quotient-induced clopen channel
on a finitely generated proof-semiring spectrum is bounded above by the finite
capacity approximation computed from basis-generated clopen partitions.

Bridge: connects Stone duality, thermodynamic entropy, and post-quantum leakage.
-/
theorem proofSemiring_quantum_post_quantum_coding_theorem
    {S : Type u} (M : ProofSpectrumObservableModel S) :
    ∀ Q ∈ allBasisGeneratedPartitions M,
      rationalEntropy (empiricalBlockPMF Q) ≤ capacityApprox M := ...
```

Then strengthen it with a monotonicity theorem under quotient/coarsening:

```lean
/--
`certified_robustness_data_processing_on_prime_spectra`:
quotienting the proof semantics cannot increase certified observable leakage
beyond the pullback partition complexity.

Bridge: connects algebraic abstraction to certified robustness and cryptographic leakage.
-/
theorem certified_robustness_data_processing_on_prime_spectra
    {S : Type u} (M : ProofSpectrumObservableModel S)
    {P Q : FiniteClopenPartition M.Prime}
    (hPQ : P.Refines Q) :
    rationalEntropy (empiricalBlockPMF Q) ≤ rationalEntropy (empiricalBlockPMF P) := ...
```

If possible, also prove a mutual information version:

```lean
theorem post_quantum_mutualInfo_refinement_bound
    {α : Type u} [Fintype α] [DecidableEq α]
    {P Q : FiniteClopenPartition α}
    (hPQ : P.Refines Q) :
    rationalMutualInfo (fun x => obsChannel Q x) (fun x => obsChannel Q x) ≤
    rationalMutualInfo (fun x => obsChannel P x) (fun x => obsChannel P x) := ...
```

A self-information identity reducing this to entropy is acceptable.

---

## TASK SECTION 4: Proof strategy requirements

For each major theorem, do not rely on `simp` alone. Use diverse tactics and intermediate lemmas. In particular, ensure the file contains proofs using:

- `rcases` for partition membership / refinement witnesses,
- `by_contra` for uniqueness of block membership,
- `linarith` or `nlinarith` for entropy/counting inequalities after reducing to real arithmetic,
- `omega` for finite cardinality bounds and generator-count inequalities,
- `induction` on finite generator lists or `Finset.induction` for basis-generated partitions,
- `field_simp` if logarithmic or rational normalization introduces denominators,
- `have` chains with extensionality for pullback partitions and observable factorization.

Concrete proof architecture:

1. **Partition API first**  
   Prove existence and uniqueness of containing blocks. Define `obsChannel` via `Classical.choose` from `exists_block_mem`, then prove `obsChannel_spec` and `obsChannel_fiber_eq_block`.

2. **Refinement cardinality theorem**  
   Use a witness function from fine blocks to coarse blocks. Show injectivity of a suitable map after choosing representatives or prove via disjointness/cardinality counting. If direct injectivity is awkward, prove the contrapositive: if `Q` has more blocks than `P`, refinement fails by pigeonhole reasoning.

3. **Entropy monotonicity in the uniform/empirical case**  
   Reduce entropy to counting distinct block frequencies. First prove a simpler lemma:
   ```lean
   theorem uniform_partition_entropy_eq_log_card ...
   ```
   when each block has equal size. Then prove monotonicity under refinement using the bound `H(Q) ≤ log |Q| ≤ log |P|` and identify `H(P) = log |P|` in the uniform special case, or prove a weaker but rigorous counting inequality sufficient for `capacityApprox`.

4. **Quotient pullback factorization**  
   Show each pullback block is literally a preimage of a coarse block. Define the factor map on indices using `Subtype.map` or choice. Prove commuting of observables pointwise.

5. **Capacity approximation**  
   Enumerate partitions generated by subsets of the basis using `Finset.powerset`. Prove cardinality bound by reducing to `Finset.card_powerset`. Then show every enumerated observable entropy is bounded by the supremum / maximum.

6. **Prime-spectrum specialization**  
   Build basis blocks from finite Boolean combinations of `zeroLocus` of generators if the API supports it; otherwise use the supplied finite basic clopens in `ProofSpectrumObservableModel`. Tie the semantics to `vanishesAt` / `theoryOf` via extensionality lemmas.

Most promising route: make the information theory finite and combinatorial from the outset. Avoid measure-theoretic entropy. Count blocks on a finite prime spectrum model and use elementary logarithmic cardinality bounds. This is much more likely to close in Lean with zero sorries.

---

## TASK SECTION 5: Strong intermediate lemmas to isolate

You should explicitly prove and use lemmas of the following flavor:

```lean
theorem finite_partition_mem_iff_mem_obsFiber ...
theorem refinement_witness_exists ...
theorem pullback_partition_is_finiteClopen ...
theorem jointPartition_card_le_mul ...
theorem empiricalBlockPMF_nonneg ...
theorem empiricalBlockPMF_sum_one ...
theorem rationalEntropy_nonneg ...
theorem rationalEntropy_eq_zero_of_singleton ...
theorem stoneEntropy_le_generatorCount_log_two ...
theorem quotient_map_cannot_create_new_blocks ...
theorem theoryOf_equal_on_generators_implies_same_observable ...
theorem post_quantum_leakage_radius_bound ...
```

At least one theorem should use quantifier alternation in an essential way, e.g.

```lean
theorem exists_refining_generator_partition
    {S : Type u} (M : ProofSpectrumObservableModel S) :
    ∀ P ∈ allBasisGeneratedPartitions M, ∃ Q ∈ allBasisGeneratedPartitions M,
      P.Refines Q ∧ Q.carrier.card ≤ 2 ^ M.generatorCount := ...
```

And at least one theorem should exploit a symmetric construction, e.g. a `jointPartition` for two observables with symmetry under swapping:

```lean
theorem jointPartition_symm_entropy
    {α : Type u} [Fintype α] [DecidableEq α]
    (P Q : FiniteClopenPartition α) :
    rationalEntropy (empiricalBlockPMF (jointPartition P Q)) =
    rationalEntropy (empiricalBlockPMF (jointPartition Q P)) := ...
```

---

## TASK SECTION 6: Computational and application-facing statements

Include theorem/doc-comment names with explicit impact language. Examples:

```lean
/-- Certified leakage bound for neural / quantum observables extracted from prime spectra. -/
theorem lipschitz_certified_robustness_prime_spectrum_entropy_bound ...

/-- Post-quantum abstraction cannot increase lattice-style observable leakage. -/
theorem post_quantum_security_spectrum_quotient_leakage ...

/-- Thermodynamic interpretation: observable coarse-graining lowers Stone entropy. -/
theorem thermodynamic_stone_entropy_coarse_grain ...

/-- Tropical/hash-style collision proxy from clopen partition cardinality. -/
theorem tropical_hash_collision_bound_from_capacityApprox ...
```

These need not be deep if they are rigorously deduced corollaries of the main API. But they must be mathematically correct and nontrivial consequences, not mere renamings.

Examples of useful corollary shapes:

- entropy upper bounded by `log (2 ^ g) = g * log 2`,
- quotient/coarsening decreases observable leakage,
- equal theories on generators imply indistinguishable observable outputs,
- finite basis gives a computable search space for maximum leakage.

For explicit bounds, prefer concrete inequalities such as:

```lean
theorem stoneEntropy_le_generator_linear
    {S : Type u} (M : ProofSpectrumObservableModel S) :
    capacityApprox M ≤ (M.generatorCount : ℝ) * Real.log 2 := by
  -- derive from `Real.log_rpow` or `by have := capacityApprox_le_log_basis ...`
```

and

```lean
theorem basis_partition_search_space_bound
    {S : Type u} (M : ProofSpectrumObservableModel S) :
    Nat.card (allBasisGeneratedPartitions M) ≤ 2 ^ M.generatorCount := ...
```

---

## TASK SECTION 7: If full generality is blocked

If a theorem involving actual `Spec` / `zeroLocus` / `ProofCongruence.IsPrime` is obstructed by API mismatch, do not stop. Instead:

1. Formalize the entire finite abstract theory for a generic finite type `α`.
2. State the desired specialization conjecture with exact Lean signature.
3. Prove the strongest available bridge theorem showing that any finite proof-spectrum model satisfying your abstract interface inherits the coding theorem.

Recommended fallback theorem:

```lean
theorem abstract_prime_spectrum_coding_bridge
    {S : Type u} (M : ProofSpectrumObservableModel S) :
    ∀ Q ∈ allBasisGeneratedPartitions M,
      rationalEntropy (empiricalBlockPMF Q) ≤ (M.generatorCount : ℝ) * Real.log 2 := ...
```

Recommended conjecture if necessary:

```lean
conjecture zeroLocus_basis_generates_all_finite_clopens
    {S : Type u} (M : ProofSpectrumObservableModel S) :
    ∀ P : FiniteClopenPartition M.Prime, ∃ Q ∈ allBasisGeneratedPartitions M, P.Refines Q
```

If you state a conjecture, prove at least 3 rigorous consequences that would follow from it.

---

## TASK SECTION 8: Deliverable richness

The file should contain:

- at least **20 theorems**
- at least **10 definitions/structures**
- multiple sections:
  - `BasicPartitions`
  - `Entropy`
  - `Refinement`
  - `SpectrumQuotients`
  - `ProofSemiringModels`
  - `CapacityApproximation`
  - `Applications`
- no `sorry`
- doc comments explaining “Bridge: connects X to Y”
- at least one example / toy model on a finite type such as `Fin n` or `Bool × Bool`
- at least one theorem proved by `Finset.induction`
- at least one theorem proved by `by_contra`
- at least one arithmetic bound using `omega`
- at least one real inequality proof using `linarith` or `nlinarith`

Conclude by producing a `FUTURE_DIRECTIONS.md` with 3–5 concrete next theorems, for example:
1. a full data-processing inequality on prime-spectrum observables,
2. a Kraft-type coding inequality for clopen proof channels,
3. a rate-distortion theorem for quotient semantics,
4. a tropical / lattice cryptographic interpretation of spectral leakage,
5. a quantum observable semantics via non-Boolean clopen effect algebras.

The significance is not merely formalization: this develops a new interface between proof semantics, Stone duality, and finite information theory. If successful, it creates a mathematically certified notion of observable leakage on proof spectra, with direct relevance to post-quantum cryptography, thermodynamic coarse-graining, and certified abstraction for neural or symbolic systems.

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
            Develop an information-theoretic semantics for self-referential proof systems by treating quotients of proof semirings as finite communication channels on prime spectra. Prove a coding theorem: for any finitely generated proof semiring S with finite clopen Stone basis and any proof congruence C, the induced channel from generators to prime-spectrum observations has capacity equal to the supremum of clopen-partition mutual informations, and this capacity is monotone under proof condensation quotients. The project should also construct an explicit approximation algorithm for capacity using finite clopen refinements of the Stone dual space. This extends the recently successful proof-semiring/Stone-duality line, but in a genuinely new direction: information flow, compression, and channel capacity for logical self-reference.

            ### Precise Mathematical Framing
            Let Spec_p(S) denote the prime congruence spectrum of a finitely generated idempotent proof semiring S, equipped with its Stone topology from basic clopens D(a). For a finite generating set G and a proof congruence C, define the observation map obs_C : G -> Clopen(Spec_p(S/C)) by sending a generator g to the clopen support of its image modulo C. From a probability distribution mu on G, this yields a finite channel into any finite clopen partition P of Spec_p(S/C). Define I_mu(P) as the Shannon mutual information of this channel and Cap(S,C) := sup_P sup_mu I_mu(P), where P ranges over finite clopen partitions. Target results: (1) finitary attainment/epsilon-attainment of Cap on finite clopen subalgebras; (2) invariance under Stone-dual isomorphism of proof semiring spectra; (3) monotonicity Cap(S,C2) <= Cap(S,C1) when C1 <= C2, interpreting stronger quotienting as proof compression; (4) subadditivity/additivity statements for product semirings under spectral products when available; (5) an algorithm reducing capacity approximation to finite partition enumeration using the existing zeroLocus/theoryOf/vanishesAt infrastructure. This forges a new bridge among algebraic logic, Stone duality, and information theory, distinct from existing inflight EML spectral jobs and from prior generic categorical information theory work because it is anchored specifically in proof semirings and prime congruence spectra.

            ### Lean 4 Sketch
Define finite clopen partitions on `zeroLocus`/`Spec` objects associated to `ProofCongruence.IsPrime`; build `obsChannel` from generators to partition indices; reuse finite entropy / mutual information lemmas from prior cryptography/physics developments; prove monotonicity via quotient maps on spectra and clopen pullback refinement; package a computable `capacityApprox` for finite generated proof semirings with decidable clopen basis.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `lawvere_proof_coding_theorem` : theorem lawvere_proof_coding_theorem
     (file: Bridges/LawvereCodingTheorem.lean)
  2. `css_from_self_dual` : theorem css_from_self_dual (n k d : ℕ) (hn : n = 8) (hk : k = 4) (hd : d = 4) :
     (file: Bridges/FiveFrontiers.lean)
  3. `rate_distortion_duality_of_coherent_proof_semiring` : theorem rate_distortion_duality_of_coherent_proof_semiring
     (file: Bridges/LawvereRateDistortionDuality.lean)
  4. `finite_spectrum_countermodel_compression` : theorem finite_spectrum_countermodel_compression
     (file: Bridges/ThermodynamicJacobsonCountermodelCompression.lean)
  5. `finite_spectrum_bound` : theorem finite_spectrum_bound (n : ℕ) : n ^ 2 ≤ 2 ^ (n ^ 2) :=
     (file: Bridges/ProofAlgGeomBridge.lean)

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



Recent successful concepts: Condensation Semantics for Algebraic–EML Fixed Points via Idempotent Galois Reconstruction, Berggren–Entropy Extractors: Rényi-2 Randomness Amplification from Primitive Pythagorean Triple Orbits, Arithmetic Stability of Operadic Neural Architectures via Height-Contraction and Valuation Generalization Bounds


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
               • ALL images MUST be embedded as base64 data URIs:
                 `<img src="data:image/png;base64,..." />` for PNGs,
                 `<img src="data:image/svg+xml;base64,..." />` for SVGs.
                 For SVG diagrams, prefer inlining `<svg>...</svg>` markup directly.
                 If you generate matplotlib/plotly charts, convert to base64 and embed.
                 NEVER reference external image files — they won't exist standalone.
               • Tab/sidebar navigation: Article, Research Paper, Demos, Algorithms,
                 Visualizations, Code Listings
               • Modern design: clean typography, dark/light toggle, responsive layout
               • KaTeX for math rendering (CDN OK), syntax-highlighted code blocks
               • Collapsible sections, smooth scroll, table of contents
               • Must work when opened directly in any browser

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            @AutoResearch/PrimeCongruenceProofSemiring.lean
```lean
/-
# Prime Congruence Spectra of Closure-Generated Proof Semirings

This file establishes the algebraic core of **proof-spectrum semantics**: the reconstruction
of semiprime theories/kernels as intersections of prime theories in commutative semirings.

## Main results

* `semiprime_eq_iInter_prime_theories` — A semiprime kernel in a commutative semiring equals the
  intersection of all prime theories containing it. This is the algebraic heart of the
  proof-spectrum correspondence.

* `exists_prime_theory_avoiding` — Prime separation: if `a` is not in a semiprime kernel `K`,
  there exists a prime theory containing `K` but not `a` (via Zorn's lemma).

* `zeroLocus_anti_mono`, `theoryOf_zeroLocus_extensive`, `theoryOf_zeroLocus_galois` — The
  antitone Galois correspondence between sets of proof terms and sets of congruences.

* `zeroClass_of_prime_congruence_isPrimeTheory` — The zero-class of a prime proof congruence
  is a prime theory.

## Mathematical overview

The key insight is that a proof system can be given the structure of an idempotent commutative
semiring, where `a + b` represents "either derivation resource," `a * b` represents "composite
derivation," and the induced order captures logical entailment. The prime congruence spectrum
then provides a geometric semantics: theories correspond to vanishing loci, and derivability
is captured by vanishing on all points of the associated spectral set.

The decisive theorem is that **semiprime** theories (those closed under square roots:
`a * a ∈ T → a ∈ T`) are exactly the intersections of prime theories. This is the
semiring-theoretic analogue of the radical ideal theorem from algebraic geometry.

## References

The algebraic content is a semiring generalization of the classical commutative algebra result
that semiprime ideals are intersections of prime ideals (a consequence of Krull's theorem).
The proof uses Zorn's lemma applied to the family of ideals disjoint from a multiplicative set.
-/

import Mathlib

set_option maxHeartbeats 800000

universe u

open Set

/-! ## Section 1: Proof Congruences and Basic Definitions -/

/-- A semiring congruence interpreted as proof indistinguishability. -/
structure ProofCongruence (α : Type u) [CommSemiring α] where
  r : α → α → Prop
  iseqv : Equivalence r
  add_compat : ∀ {a b c d}, r a b → r c d → r (a + c) (b + d)
  mul_compat : ∀ {a b c d}, r a b → r c d → r (a * c) (b * d)

/-- Vanishing of an element at a congruence: identified with zero. -/
def vanishesAt {α : Type u} [CommSemiring α] (P : ProofCongruence α) (a : α) : Prop :=
  P.r a 0

/-- Zariski closed set defined by a family of proof terms. -/
def zeroLocus {α : Type u} [CommSemiring α]
    (S : Set α) : Set (ProofCongruence α) :=
  {P | ∀ a ∈ S, vanishesAt P a}

/-- The theory reconstructed from a family of proof congruences. -/
def theoryOf {α : Type u} [CommSemiring α]
    (X : Set (ProofCongruence α)) : Set α :=
  {a | ∀ P ∈ X, vanishesAt P a}

/-- A proof congruence is prime if `ab ~ 0` forces `a ~ 0` or `b ~ 0`. -/
def ProofCongruence.IsPrime {α : Type u} [CommSemiring α]
    (P : ProofCongruence α) : Prop :=
  ∀ {a b : α}, P.r (a * b) 0 → P.r a 0 ∨ P.r b 0

/-- The prime spectrum: the set of all prime proof congruences. -/
def primeSpectrum {α : Type u} [CommSemiring α] : Set (ProofCongruence α) :=
  {P | ProofCongruence.IsPrime P}

/-! ## Section 2: Basic Galois Correspondence Lemmas -/

/-- Zero loci are antitone: larger generating sets yield smaller loci. -/
theorem zeroLocus_anti_mono
    {α : Type u} [CommSemiring α] {S T : Set α}
    (hST : S ⊆ T) :
    zeroLocus T ⊆ zeroLocus S := by
  intro P hP a ha
  exact hP a (hST ha)

/-- Every set is contained in the theory of its zero locus. -/
theorem theoryOf_zeroLocus_extensive
    {α : Type u} [CommSemiring α] (S : Set α) :
    S ⊆ theoryOf (zeroLocus S) := by
  intro a ha P hP
  exact hP a ha

/-- The Galois connection between sets of elements and sets of congruences. -/
theorem theoryOf_zeroLocus_galois
    {α : Type u} [CommSemiring α] {S : Set α} {X : Set (ProofCongruence α)} :
    S ⊆ theoryOf X ↔ X ⊆ zeroLocus S := by
  constructor
  · intro h P hP a ha
    exact h ha P hP
  · intro h a ha P hP
    exact h hP a ha

/-- TheoryOf is antitone: larger families of congruences yield smaller theories. -/
theorem theoryOf_anti_mono
    {α : Type u} [CommSemiring α] {X Y : Set (ProofCongruence α)}
    (hXY : X ⊆ Y) :
    theoryOf Y ⊆ theoryOf X := by
  intro a ha P hP
  exact ha P (hXY hP)

/-! ## Section 3: Prime Theories (Set-Based Approach) -/

/-- A set `T` is a *theory* if it contains 0, is closed under addition,
and absorbs multiplication. This captures the algebraic properties of
derivability kernels. -/
structure IsTheory {α : Type u} [CommSemiring α] (T : Set α) : Prop where
  zero_mem : (0 : α) ∈ T
  add_closed : ∀ {a b}, a ∈ T → b ∈ T → a + b ∈ T
  mul_absorb : ∀ {a b}, a ∈ T → a * b ∈ T

/-- A theory is *prime* if `a * b ∈ T` implies `a ∈ T` or `b ∈ T`. -/
structure IsPrimeTheory {α : Type u} [CommSemiring α] (T : Set α) : Prop
    extends IsTheory T where
  prime : ∀ {a b : α}, a * b ∈ T → a ∈ T ∨ b ∈ T

/-- A theory is *semiprime* if `a * a ∈ T` implies `a ∈ T`. -/
def IsSemiprimeTheory {α : Type u} [CommSemiring α] (T : Set α) : Prop :=
  IsTheory T ∧ ∀ {a : α}, a * a ∈ T → a ∈ T

/-! ### Key lemma: powers in semiprime kernels -/

/-
In a semiprime kernel, if any power `a ^ n` (with `n ≥ 1`) belongs to `K`,
then `a ∈ K`. This strengthens the defining condition `a² ∈ K → a ∈ K`
using the absorption and closure properties.

The proof is by strong induction on `n`. For even `n = 2k`: `a^(2k) = (a^k)²`,
so `a^k ∈ K` by semiprimality, then `a ∈ K` by induction. For odd `n`:
`(a^n)² = a^(2n) ∈ K` by absorption, so `a^n ∈ K → a^(2n) ∈ K → a^n ∈ K`
(circular, but `2n` is even so we use the even case).
-/
theorem pow_mem_of_semiprime {α : Type u} [CommSemiring α]
    {K : Set α} (hK : IsTheory K) (hsemiprime : ∀ {a : α}, a * a ∈ K → a ∈ K)
    {a : α} {n : ℕ} (hn : 0 < n) (ha : a ^ n ∈ K) : a ∈ K := by
  revert ha;
-- ... (truncated, full file has 485 lines)
```


### Catalog Reference Files
            @AutoResearch/PrimeCongruenceProofSemiring.lean
```lean
/-
# Prime Congruence Spectra of Closure-Generated Proof Semirings

This file establishes the algebraic core of **proof-spectrum semantics**: the reconstruction
of semiprime theories/kernels as intersections of prime theories in commutative semirings.

## Main results

* `semiprime_eq_iInter_prime_theories` — A semiprime kernel in a commutative semiring equals the
  intersection of all prime theories containing it. This is the algebraic heart of the
  proof-spectrum correspondence.

* `exists_prime_theory_avoiding` — Prime separation: if `a` is not in a semiprime kernel `K`,
  there exists a prime theory containing `K` but not `a` (via Zorn's lemma).

* `zeroLocus_anti_mono`, `theoryOf_zeroLocus_extensive`, `theoryOf_zeroLocus_galois` — The
  antitone Galois correspondence between sets of proof terms and sets of congruences.

* `zeroClass_of_prime_congruence_isPrimeTheory` — The zero-class of a prime proof congruence
  is a prime theory.

## Mathematical overview

The key insight is that a proof system can be given the structure of an idempotent commutative
semiring, where `a + b` represents "either derivation resource," `a * b` represents "composite
derivation," and the induced order captures logical entailment. The prime congruence spectrum
then provides a geometric semantics: theories correspond to vanishing loci, and derivability
is captured by vanishing on all points of the associated spectral set.

The decisive theorem is that **semiprime** theories (those closed under square roots:
`a * a ∈ T → a ∈ T`) are exactly the intersections of prime theories. This is the
semiring-theoretic analogue of the radical ideal theorem from algebraic geometry.

## References

The algebraic content is a semiring generalization of the classical commutative algebra result
that semiprime ideals are intersections of prime ideals (a consequence of Krull's theorem).
The proof uses Zorn's lemma applied to the family of ideals disjoint from a multiplicative set.
-/

import Mathlib

set_option maxHeartbeats 800000

universe u

open Set

/-! ## Section 1: Proof Congruences and Basic Definitions -/

/-- A semiring congruence interpreted as proof indistinguishability. -/
structure ProofCongruence (α : Type u) [CommSemiring α] where
  r : α → α → Prop
  iseqv : Equivalence r
  add_compat : ∀ {a b c d}, r a b → r c d → r (a + c) (b + d)
  mul_compat : ∀ {a b c d}, r a b → r c d → r (a * c) (b * d)

/-- Vanishing of an element at a congruence: identified with zero. -/
def vanishesAt {α : Type u} [CommSemiring α] (P : ProofCongruence α) (a : α) : Prop :=
  P.r a 0

/-- Zariski closed set defined by a family of proof terms. -/
def zeroLocus {α : Type u} [CommSemiring α]
    (S : Set α) : Set (ProofCongruence α) :=
  {P | ∀ a ∈ S, vanishesAt P a}

/-- The theory reconstructed from a family of proof congruences. -/
def theoryOf {α : Type u} [CommSemiring α]
    (X : Set (ProofCongruence α)) : Set α :=
  {a | ∀ P ∈ X, vanishesAt P a}

/-- A proof congruence is prime if `ab ~ 0` forces `a ~ 0` or `b ~ 0`. -/
def ProofCongruence.IsPrime {α : Type u} [CommSemiring α]
    (P : ProofCongruence α) : Prop :=
  ∀ {a b : α}, P.r (a * b) 0 → P.r a 0 ∨ P.r b 0

/-- The prime spectrum: the set of all prime proof congruences. -/
def primeSpectrum {α : Type u} [CommSemiring α] : Set (ProofCongruence α) :=
  {P | ProofCongruence.IsPrime P}

/-! ## Section 2: Basic Galois Correspondence Lemmas -/

/-- Zero loci are antitone: larger generating sets yield smaller loci. -/
theorem zeroLocus_anti_mono
    {α : Type u} [CommSemiring α] {S T : Set α}
    (hST : S ⊆ T) :
    zeroLocus T ⊆ zeroLocus S := by
  intro P hP a ha
  exact hP a (hST ha)

/-- Every set is contained in the theory of its zero locus. -/
theorem theoryOf_zeroLocus_extensive
    {α : Type u} [CommSemiring α] (S : Set α) :
    S ⊆ theoryOf (zeroLocus S) := by
  intro a ha P hP
  exact hP a ha

/-- The Galois connection between sets of elements and sets of congruences. -/
theorem theoryOf_zeroLocus_galois
    {α : Type u} [CommSemiring α] {S : Set α} {X : Set (ProofCongruence α)} :
    S ⊆ theoryOf X ↔ X ⊆ zeroLocus S := by
  constructor
  · intro h P hP a ha
    exact h ha P hP
  · intro h a ha P hP
    exact h hP a ha

/-- TheoryOf is antitone: larger families of congruences yield smaller theories. -/
theorem theoryOf_anti_mono
    {α : Type u} [CommSemiring α] {X Y : Set (ProofCongruence α)}
    (hXY : X ⊆ Y) :
    theoryOf Y ⊆ theoryOf X := by
  intro a ha P hP
  exact ha P (hXY hP)

/-! ## Section 3: Prime Theories (Set-Based Approach) -/

/-- A set `T` is a *theory* if it contains 0, is closed under addition,
and absorbs multiplication. This captures the algebraic properties of
derivability kernels. -/
structure IsTheory {α : Type u} [CommSemiring α] (T : Set α) : Prop where
  zero_mem : (0 : α) ∈ T
  add_closed : ∀ {a b}, a ∈ T → b ∈ T → a + b ∈ T
  mul_absorb : ∀ {a b}, a ∈ T → a * b ∈ T

/-- A theory is *prime* if `a * b ∈ T` implies `a ∈ T` or `b ∈ T`. -/
structure IsPrimeTheory {α : Type u} [CommSemiring α] (T : Set α) : Prop
    extends IsTheory T where
  prime : ∀ {a b : α}, a * b ∈ T → a ∈ T ∨ b ∈ T

/-- A theory is *semiprime* if `a * a ∈ T` implies `a ∈ T`. -/
def IsSemiprimeTheory {α : Type u} [CommSemiring α] (T : Set α) : Prop :=
  IsTheory T ∧ ∀ {a : α}, a * a ∈ T → a ∈ T

/-! ### Key lemma: powers in semiprime kernels -/

/-
In a semiprime kernel, if any power `a ^ n` (with `n ≥ 1`) belongs to `K`,
then `a ∈ K`. This strengthens the defining condition `a² ∈ K → a ∈ K`
using the absorption and closure properties.

The proof is by strong induction on `n`. For even `n = 2k`: `a^(2k) = (a^k)²`,
so `a^k ∈ K` by semiprimality, then `a ∈ K` by induction. For odd `n`:
`(a^n)² = a^(2n) ∈ K` by absorption, so `a^n ∈ K → a^(2n) ∈ K → a^n ∈ K`
(circular, but `2n` is even so we use the even case).
-/
theorem pow_mem_of_semiprime {α : Type u} [CommSemiring α]
    {K : Set α} (hK : IsTheory K) (hsemiprime : ∀ {a : α}, a * a ∈ K → a ∈ K)
    {a : α} {n : ℕ} (hn : 0 < n) (ha : a ^ n ∈ K) : a ∈ K := by
  revert ha;
-- ... (truncated, full file has 485 lines)
```


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
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the HTML as base64 data URIs. Use the format:
  `<img src="data:image/png;base64,..." />` for PNGs,
  `<img src="data:image/svg+xml;base64,..." />` for SVGs.
  If you generate matplotlib/plotly figures in Python, convert them to base64
  and embed them. For SVG diagrams, inline the SVG markup directly with
  `<svg>...</svg>` tags — this is preferred over base64 for vector graphics.
  NEVER use `<img src="filename.png">` — the file won't exist when viewing.
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
Research mode: formalize
