

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

## YOUR ASSIGNMENT: Berggren–Holevo Correspondence: Primitive Pythagorean Orbit Channels and Entropy-Stable Quantum Coding

Create `Bridges/QuantumPythagoreanInformation.lean` and make it a self-contained bridge between:

- primitive Pythagorean triple dynamics via the Berggren tree,
- finite quantum ensembles / finite quantum channels / Holevo-style entropy bounds,
- cryptographic packing via triple-norm collision separation,
- certified robustness style overlap control via explicit Lipschitz-type decay bounds.

The file should formalize a genuine correspondence: norm-separated Berggren orbits induce finite ensembles of approximately distinguishable quantum states, and therefore yield explicit lower bounds on Holevo-type information and channel capacity. This is not a cosmetic restatement of existing entropy lemmas; it should manufacture a new transport principle from arithmetic orbit geometry to quantum-information capacity.

Use theorem names and doc comments with explicit application keywords:
`quantum`, `post_quantum_security`, `lattice`, `certified`, `entropy`, `Holevo`, `fidelity`, `trapdoor`, `robustness`.

Produce a mathematically rich file: at least 10 new definitions/structures and 20+ theorems/lemmas, with zero sorries.

---

## Core formalization target

You should introduce a finite Berggren-orbit ensemble of quantum states indexed by primitive triples, define overlap and a channel-like object from this ensemble, and prove that arithmetic norm separation implies pairwise fidelity control, which implies a Holevo lower bound and a monotone depth-capacity estimate.

The narrative should culminate in a theorem of the following shape:

```lean
theorem berggren_depth_monotone_capacity_bound
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (S : BerggrenSlice ι)
    (hsep : S.PairwiseNormSeparated)
    (hcard : 1 < Fintype.card ι) :
    ∃ C : ℝ,
      0 ≤ C ∧
      C ≤ berggrenChannelCapacity S ∧
      depthLowerBound S ≤ C
```

If the exact entropy/capacity object in the catalog uses a different name or codomain, adapt the statement faithfully, but keep the same mathematical content: an explicit arithmetic lower bound on channel capacity extracted from Berggren depth and pairwise norm separation.

---

## New definitions and structures to add

Introduce at least the following, with exact Lean signatures as close as possible to these. If existing catalog objects suggest better field types, adjust minimally.

### 1. Berggren slice of indexed primitive triples
```lean
structure BerggrenSlice (ι : Type*) [Fintype ι] where
  triple : ι → PrimitiveTriple
  depth : ι → ℕ
  depth_compatible :
    ∀ i, berggrenDepth (triple i) = depth i
```

### 2. Triple-invariant quantum state
This should package a density-like state attached to a primitive triple, together with an arithmetic invariance law. If the existing quantum library already has density matrices, use them. Otherwise define an abstract finite state object over a finite-dimensional index type.

```lean
structure TripleInvariantState (d : Type*) [Fintype d] [DecidableEq d] where
  carrier : QuantumState d
  arithmetic_mass : PrimitiveTriple → ℝ
  arithmetic_mass_nonneg : ∀ t, 0 ≤ arithmetic_mass t
  arithmetic_mass_invariant :
    ∀ t u, tripleNorm t = tripleNorm u → arithmetic_mass t = arithmetic_mass u
```

### 3. Berggren ensemble
```lean
structure BerggrenEnsemble (ι d : Type*)
    [Fintype ι] [DecidableEq ι] [Fintype d] [DecidableEq d] where
  prob : ι → ℝ
  prob_nonneg : ∀ i, 0 ≤ prob i
  prob_sum_one : (∑ i, prob i) = 1
  stateOf : ι → TripleInvariantState d
  supportTriple : BerggrenSlice ι
```

### 4. Orbit overlap
Use whichever overlap notion is available in the catalog: fidelity, trace inner product, Hilbert–Schmidt overlap, or a bounded surrogate. If multiple exist, define `orbitOverlap` in terms of the strongest one with available theorems.

```lean
def orbitOverlap {d : Type*} [Fintype d] [DecidableEq d]
    (ρ σ : TripleInvariantState d) : ℝ := quantumFidelity ρ.carrier σ.carrier
```

### 5. Berggren channel
Define a finite channel induced by the ensemble. If the catalog has a channel object, use it. Otherwise define a scalar surrogate capacity functional sufficient for Holevo lower bounds.

```lean
def berggrenChannel {ι d : Type*}
    [Fintype ι] [DecidableEq ι] [Fintype d] [DecidableEq d]
    (E : BerggrenEnsemble ι d) : FiniteQuantumChannel ι d := ...
```

### 6. Pairwise norm separation
```lean
def BerggrenSlice.PairwiseNormSeparated {ι : Type*} [Fintype ι]
    (S : BerggrenSlice ι) : Prop :=
  ∀ ⦃i j⦄, i ≠ j → tripleNorm (S.triple i) ≠ tripleNorm (S.triple j)
```

Also define a quantitative version:
```lean
def BerggrenSlice.MinNormGap {ι : Type*} [Fintype ι]
    (S : BerggrenSlice ι) : ℕ := Finset.inf' Finset.univ ?h_nonempty
      (fun i => Finset.inf' (Finset.univ.erase i) ?h_nonempty'
        (fun j => Nat.dist (tripleNorm (S.triple i)) (tripleNorm (S.triple j))))
```
If this exact infimum is awkward, define a simpler witness-based lower bound:
```lean
def BerggrenSlice.HasNormGap (S : BerggrenSlice ι) (δ : ℕ) : Prop := ...
```

### 7. Explicit overlap envelope
```lean
def berggrenOverlapEnvelope (δ : ℕ) : ℝ :=
  1 / (1 + δ)
```
or, if the collision-bound catalog supports a stronger decay, use that:
```lean
def berggrenOverlapEnvelope (δ : ℕ) : ℝ :=
  Real.exp (-(δ : ℝ) / 2)
```

### 8. Effective packing number / coding rate
```lean
def berggrenPackingRate {ι : Type*} [Fintype ι] (S : BerggrenSlice ι) : ℝ :=
  Real.log (Fintype.card ι) / Real.log 2
```

### 9. Depth lower bound surrogate
```lean
def depthLowerBound {ι : Type*} [Fintype ι] (S : BerggrenSlice ι) : ℝ :=
  ((∑ i, (S.depth i : ℝ)) / Fintype.card ι) / (1 + berggrenAverageOverlapGap S)
```
You may simplify the denominator if necessary, but preserve explicit computable dependence on depth and separation.

### 10. Capacity surrogate
```lean
def berggrenChannelCapacity {ι d : Type*}
    [Fintype ι] [DecidableEq ι] [Fintype d] [DecidableEq d]
    (E : BerggrenEnsemble ι d) : ℝ := holevoQuantity (berggrenChannel E)
```
If the catalog’s capacity is a supremum over ensembles and not directly attached to a fixed ensemble, define a lower-bound surrogate and prove it is bounded by the true capacity.

---

## Main theorem cluster to prove

You should prove at least the following theorem family, with these names or very close variants.

### Arithmetic-to-quantum overlap bridge

```lean
theorem triple_gap_to_fidelity_bound
    {d : Type*} [Fintype d] [DecidableEq d]
    (ψ φ : TripleInvariantState d)
    (t u : PrimitiveTriple)
    (hgap : 0 < Nat.dist (tripleNorm t) (tripleNorm u)) :
    orbitOverlap ψ φ ≤ berggrenOverlapEnvelope (Nat.dist (tripleNorm t) (tripleNorm u))
```

This is the key bridge theorem. It should explicitly convert triple-norm separation into bounded quantum overlap / fidelity.

A stronger quantitative form is even better:

```lean
theorem triple_gap_to_fidelity_decay_quantum
    {d : Type*} [Fintype d] [DecidableEq d]
    (ψ φ : TripleInvariantState d)
    (t u : PrimitiveTriple)
    (hgap : δ ≤ Nat.dist (tripleNorm t) (tripleNorm u)) :
    orbitOverlap ψ φ ≤ berggrenOverlapEnvelope δ
```

### Pairwise packing bound

```lean
theorem pairwise_overlap_bound_of_norm_separation
    {ι d : Type*} [Fintype ι] [DecidableEq ι] [Fintype d] [DecidableEq d]
    (E : BerggrenEnsemble ι d)
    (δ : ℕ)
    (hsep : ∀ ⦃i j⦄, i ≠ j →
      δ ≤ Nat.dist (tripleNorm (E.supportTriple.triple i))
                    (tripleNorm (E.supportTriple.triple j))) :
    ∀ ⦃i j⦄, i ≠ j →
      orbitOverlap (E.stateOf i) (E.stateOf j) ≤ berggrenOverlapEnvelope δ
```

### Holevo lower bound from packing

Formalize a lower bound of the form “if pairwise overlaps are uniformly ≤ ε, then the accessible/Holevo information is at least `log |ι| - penalty(ε, |ι|)`”. Use the strongest existing finite-ensemble entropy theorem from the catalog. If the exact theorem only gives an upper bound on entropy defect, derive the lower bound.

```lean
def holevoPackingPenalty (n : ℕ) (ε : ℝ) : ℝ :=
  (n : ℝ) * ε

theorem holevo_lower_bound_of_packing
    {ι d : Type*} [Fintype ι] [DecidableEq ι] [Fintype d] [DecidableEq d]
    (E : BerggrenEnsemble ι d)
    (ε : ℝ)
    (hoverlap : ∀ ⦃i j⦄, i ≠ j → orbitOverlap (E.stateOf i) (E.stateOf j) ≤ ε)
    (hε₀ : 0 ≤ ε)
    (hε₁ : ε ≤ 1) :
    berggrenPackingRate E.supportTriple - holevoPackingPenalty (Fintype.card ι) ε
      ≤ berggrenChannelCapacity E
```

A sharper penalty using `log (1 + (n-1) ε)` or binary entropy is encouraged if catalog lemmas support it.

### Depth monotonicity and arithmetic growth

You need a monotonicity theorem tying Berggren depth growth to packing size or norm gap.

```lean
theorem berggren_depth_monotone_packing
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (S : BerggrenSlice ι) :
    0 ≤ depthLowerBound S
```

and a stronger theorem:
```lean
theorem berggren_depth_monotone_capacity_bound
    {ι d : Type*} [Fintype ι] [DecidableEq ι] [Fintype d] [DecidableEq d]
    (E : BerggrenEnsemble ι d)
    (δ : ℕ)
    (hsep : ∀ ⦃i j⦄, i ≠ j →
      δ ≤ Nat.dist (tripleNorm (E.supportTriple.triple i))
                    (tripleNorm (E.supportTriple.triple j)))
    (hcard : 1 < Fintype.card ι) :
    depthLowerBound E.supportTriple
      ≤ berggrenChannelCapacity E
        + holevoPackingPenalty (Fintype.card ι) (berggrenOverlapEnvelope δ)
```

This should encode “deeper arithmetic orbits give larger robust coding capacity up to an explicit overlap penalty”.

---

## Additional theorem requirements

Prove 10+ substantial lemmas beyond the main cluster. Suggested targets:

### Finite arithmetic combinatorics lemmas
```lean
theorem berggren_slice_norm_eq_of_not_separated ...
theorem pairwise_separated_implies_injective_norm ...
theorem card_le_norm_spectrum_card ...
theorem average_depth_nonneg ...
theorem depthLowerBound_nonneg ...
```

### Envelope monotonicity / analytic bounds
```lean
theorem berggrenOverlapEnvelope_nonneg (δ : ℕ) :
  0 ≤ berggrenOverlapEnvelope δ

theorem berggrenOverlapEnvelope_le_one (δ : ℕ) :
  berggrenOverlapEnvelope δ ≤ 1

theorem berggrenOverlapEnvelope_antitone :
  Antitone berggrenOverlapEnvelope

theorem berggrenOverlapEnvelope_tends_zero_quantum_certified :
  Tendsto (fun n : ℕ => berggrenOverlapEnvelope n) atTop (𝓝 0)
```

### Probability and entropy lemmas
```lean
theorem holevoPackingPenalty_nonneg (n : ℕ) {ε : ℝ} (hε : 0 ≤ ε) :
  0 ≤ holevoPackingPenalty n ε

theorem berggrenPackingRate_nonneg {ι : Type*} [Fintype ι] :
  0 ≤ berggrenPackingRate (ι := ι)

theorem uniform_prob_is_valid_berggren ...
theorem capacity_surrogate_nonneg ...
```

### Symmetry / permutation invariance
Introduce a theorem showing that relabeling indices does not change the overlap profile or capacity lower bound.

```lean
theorem berggrenChannel_perm_invariant_quantum_crypto
    {ι κ d : Type*}
    [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]
    [Fintype d] [DecidableEq d]
    (e : ι ≃ κ)
    (E : BerggrenEnsemble ι d) :
    berggrenChannelCapacity (E.reindex e) = berggrenChannelCapacity E
```

You may need to define:
```lean
def BerggrenEnsemble.reindex ...
```

### Existential/quantifier-alternating theorem
Include at least one theorem with genuine `∀ x, ∃ y` structure, e.g.
```lean
theorem exists_quantum_codeword_with_small_orbit_overlap
    {ι d : Type*} [Fintype ι] [DecidableEq ι] [Fintype d] [DecidableEq d]
    (E : BerggrenEnsemble ι d)
    (δ : ℕ)
    (hsep : ∀ ⦃i j⦄, i ≠ j →
      δ ≤ Nat.dist (tripleNorm (E.supportTriple.triple i))
                    (tripleNorm (E.supportTriple.triple j)))
    (i : ι) :
    ∃ ψ, ψ = E.stateOf i ∧
      ∀ j, j ≠ i → orbitOverlap ψ (E.stateOf j) ≤ berggrenOverlapEnvelope δ
```

This is important for AESTHETIC scoring and for codebook extraction.

---

## Concrete proof strategy guidance

### Strategy A: direct arithmetic → collision bound → fidelity bound → Holevo
This is the preferred route.

1. Use the Berggren-tree/triple-norm infrastructure to extract quantitative norm separation facts from indexed triples.
   - likely tools: primitive-triple injectivity lemmas, Berggren depth recursion, triple-norm collision bounds.
   - prove a finite pairwise-separation lemma by `intro i j hij`; use `by_contra` to convert overlap violations into forbidden norm collisions.

2. Transport the arithmetic separation into the quantum side using the existing fidelity / trace-distance / collision machinery.
   - if the catalog already proves a collision-to-fidelity estimate, instantiate it with the `arithmetic_mass` or state-preparation map.
   - if only trace-distance bounds are available, use Fuchs–van de Graaf:
     `1 - fidelity ≤ traceDistance ≤ sqrt (1 - fidelity^2)` or the exact catalog variant.
   - in Lean, expect `nlinarith`, `linarith`, `have h := ...`, and monotonicity of `Real.sqrt`.

3. Convert pairwise overlap control into a Holevo lower bound for the ensemble.
   - if there is a theorem bounding entropy defect by average pairwise overlap, use the uniform bound to estimate the average.
   - if the ensemble is uniform, simplify sums with `Finset.sum_const_nat`.
   - if not, prove the uniform case first as a special lemma:
     ```lean
     theorem holevo_lower_bound_of_uniform_packing ...
     ```
     then extend to weighted ensembles.

4. Relate Berggren depth to packing size or norm gap.
   - use induction on tree depth if a recursive Berggren constructor is available.
   - otherwise prove a simpler monotonicity: nonnegative average depth, then use an explicit definition of `depthLowerBound` that is trivially ≤ `log card`.
   - a good fallback is to define `depthLowerBound` so the final theorem is nontrivial but provable from existing combinatorics.

5. Package everything into the final theorem by composing inequalities with `linarith`.

### Strategy B: define a robust surrogate capacity first
If the catalog’s true quantum channel capacity API is too heavy, define a surrogate:
```lean
def berggrenRobustCapacityLowerBound (E : BerggrenEnsemble ι d) : ℝ := ...
```
Prove:
```lean
theorem berggrenRobustCapacityLowerBound_le_capacity ...
```
Then prove the arithmetic lower bound for the surrogate. This is mathematically legitimate and often the cleanest Lean architecture.

### Strategy C: start with a uniform ensemble special case
If the probability-weighted ensemble creates technical friction, first define:
```lean
def uniformBerggrenEnsemble ...
```
Prove all packing/Holevo statements there, then generalize. This is likely the best path if the entropy library has strongest lemmas for uniform finite ensembles.

---

## Tactic diversity requirements inside proofs

Use varied proof patterns across the file:

- `induction` on Berggren depth or finite recursion through tree constructors.
- `rcases` on primitive-triple or state objects.
- `by_contra` for injectivity / separation contradictions.
- `omega` for natural-number depth/gap arithmetic.
- `linarith` / `nlinarith` for entropy and overlap inequalities.
- `field_simp` if logarithmic/reciprocal envelope formulas require denominator clearing.
- `simpa` only as finishing step, not the main engine.
- `have`, `calc`, and `convert` to make proof architecture legible.

At least one theorem should genuinely use each of:
`induction`, `rcases`, `by_contra`, `omega`, `linarith`, `field_simp`.

---

## Suggested exact theorem statements for easy formalization

These are intentionally chosen to be strong but realistic.

```lean
theorem pairwise_separated_implies_injective_norm
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (S : BerggrenSlice ι)
    (hsep : S.PairwiseNormSeparated) :
    Function.Injective (fun i => tripleNorm (S.triple i))
```

```lean
theorem card_le_norm_spectrum_card
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (S : BerggrenSlice ι)
    (hsep : S.PairwiseNormSeparated) :
    Fintype.card ι ≤
      Fintype.card {n // ∃ i, tripleNorm (S.triple i) = n}
```

```lean
theorem average_depth_nonneg
    {ι : Type*} [Fintype ι]
    (S : BerggrenSlice ι) :
    0 ≤ ∑ i, (S.depth i : ℝ)
```

```lean
theorem depthLowerBound_nonneg
    {ι : Type*} [Fintype ι] [DecidableEq ι] :
    ∀ S : BerggrenSlice ι, 0 ≤ depthLowerBound S
```

```lean
theorem orbitOverlap_nonneg
    {d : Type*} [Fintype d] [DecidableEq d]
    (ρ σ : TripleInvariantState d) :
    0 ≤ orbitOverlap ρ σ
```

```lean
theorem orbitOverlap_le_one
    {d : Type*} [Fintype d] [DecidableEq d]
    (ρ σ : TripleInvariantState d) :
    orbitOverlap ρ σ ≤ 1
```

```lean
theorem holevoPackingPenalty_mono
    (n : ℕ) :
    Monotone (holevoPackingPenalty n)
```

```lean
theorem holevoPackingPenalty_zero (n : ℕ) :
    holevoPackingPenalty n 0 = 0
```

```lean
theorem uniform_prob_sum_one
    {ι : Type*} [Fintype ι] [Nonempty ι] :
    (∑ _ : ι, (1 : ℝ) / Fintype.card ι) = 1
```
This is often easiest via `Fintype.card` and `field_simp`.

```lean
def uniformBerggrenEnsemble
    {ι d : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]
    [Fintype d] [DecidableEq d]
    (S : BerggrenSlice ι)
    (ψ : ι → TripleInvariantState d) :
    BerggrenEnsemble ι d := ...
```

```lean
theorem uniform_prob_is_valid_berggren
    {ι d : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]
    [Fintype d] [DecidableEq d]
    (S : BerggrenSlice ι)
    (ψ : ι → TripleInvariantState d) :
    (uniformBerggrenEnsemble S ψ).prob_sum_one
```

```lean
theorem exists_quantum_codeword_with_small_orbit_overlap
    {ι d : Type*} [Fintype ι] [DecidableEq ι] [Fintype d] [DecidableEq d]
    (E : BerggrenEnsemble ι d)
    (δ : ℕ)
    (hsep : ∀ ⦃i j⦄, i ≠ j →
      δ ≤ Nat.dist (tripleNorm (E.supportTriple.triple i))
                    (tripleNorm (E.supportTriple.triple j)))
    (i : ι) :
    ∃ ψ, ψ = E.stateOf i ∧
      ∀ j, j ≠ i → orbitOverlap ψ (E.stateOf j) ≤ berggrenOverlapEnvelope δ
```

```lean
theorem holevo_lower_bound_of_uniform_packing
    {ι d : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]
    [Fintype d] [DecidableEq d]
    (S : BerggrenSlice ι)
    (ψ : ι → TripleInvariantState d)
    (ε : ℝ)
    (hoverlap : ∀ ⦃i j⦄, i ≠ j → orbitOverlap (ψ i) (ψ j) ≤ ε)
    (hε₀ : 0 ≤ ε)
    (hε₁ : ε ≤ 1) :
    berggrenPackingRate S - holevoPackingPenalty (Fintype.card ι) ε
      ≤ berggrenChannelCapacity (uniformBerggrenEnsemble S ψ)
```

```lean
theorem berggrenChannel_perm_invariant_quantum_crypto
    {ι κ d : Type*}
    [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]
    [Fintype d] [DecidableEq d]
    (e : ι ≃ κ)
    (E : BerggrenEnsemble ι d) :
    berggrenChannelCapacity (BerggrenEnsemble.reindex e E) =
      berggrenChannelCapacity E
```

---

## Domain-bridging doc comments to include

Add concise doc comments before major definitions/theorems. Use this exact phrase pattern at least several times:

- `Bridge: connects arithmetic orbit separation to quantum fidelity decay.`
- `Bridge: connects Berggren-tree combinatorics to Holevo information and post_quantum_security packing.`
- `Bridge: connects primitive triple trapdoors to certified robustness style overlap control.`
- `Bridge: connects lattice-like norm packing to entropy-stable quantum coding.`

This matters: the file should read like a new research program, not isolated lemmas.

---

## Implementation advice for Lean architecture

1. Keep the arithmetic and quantum sections modular:
   - `section Arithmetic`
   - `section Overlap`
   - `section Holevo`
   - `section Capacity`
   - `section Symmetry`

2. If the exact channel API is difficult, introduce intermediate aliases:
   ```lean
   abbrev QuantumOverlap := ...
   abbrev QuantumCapacityLowerBound := ℝ
   ```

3. Prefer finite index types throughout:
   `[Fintype ι] [DecidableEq ι]`, `[Fintype d] [DecidableEq d]`.

4. For nonempty uniform ensembles:
   `[Nonempty ι]` is usually necessary.

5. If `Real.log` causes edge-case pain at cardinality `0`, either:
   - assume `[Nonempty ι]`, or
   - define `berggrenPackingRate` using `Nat.log`/`Nat.cast`, or
   - use `if h : 0 < Fintype.card ι then ... else 0`.
   But keep the theorem statements explicit and computational.

6. If the fidelity theorem in the catalog is abstract over a typeclass, exploit that generality rather than specializing too early.

---

## Significance to preserve in theorem names and comments

The final file should make clear that the result is a prototype for:

- `entropy_stable_quantum_coding` from arithmetic orbits,
- `post_quantum_security` via triple-norm separation as a trapdoor-like packing resource,
- `certified_robustness` analogues where overlap decays with arithmetic distance,
- a new arithmetic-information dictionary linking Berggren tree depth to communication complexity.

This bridges at least:
1. number theory / Diophantine combinatorics,
2. quantum information / entropy,
3. cryptographic packing and collision resistance,
and optionally a fourth:
4. ML robustness through overlap/Lipschitz-style certification.

---

## If full strength is not reachable

If the true Holevo capacity theorem is too strong for the existing API, prove the strongest formally clean surrogate chain:

```lean
triple norm gap
→ pairwise overlap bound
→ average overlap bound
→ entropy defect bound
→ explicit lower bound on a capacity surrogate
→ surrogate ≤ true capacity
```

State any remaining gap as a precise conjecture with Lean signature, e.g.

```lean
conjecture berggren_holevo_sharp_entropy_gap
    {ι d : Type*} [Fintype ι] [DecidableEq ι] [Fintype d] [DecidableEq d]
    (E : BerggrenEnsemble ι d)
    (ε : ℝ)
    (hoverlap : ∀ ⦃i j⦄, i ≠ j → orbitOverlap (E.stateOf i) (E.stateOf j) ≤ ε) :
    berggrenPackingRate E.supportTriple - Real.log (1 + ((Fintype.card ι : ℝ) - 1) * ε) / Real.log 2
      ≤ berggrenChannelCapacity E
```

But do not stop at conjectures unless the API genuinely blocks the full proof.

---

## Required end product structure

The file should contain, in order:

1. New definitions and structures.
2. Basic nonnegativity / boundedness / monotonicity lemmas.
3. Finite combinatorial separation lemmas on Berggren slices.
4. Arithmetic-to-overlap bridge lemmas.
5. Uniform ensemble construction and validation.
6. Holevo lower-bound theorems.
7. Depth-monotone capacity theorems.
8. Symmetry/reindexing invariance theorems.
9. At least one explicit existential codeword extraction theorem.
10. A short final section of precisely stated conjectures if any sharp bound remains open.

Also produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, each at breakthrough level, for example:
- sharp asymptotic capacity growth along Berggren subtrees,
- tropicalized Holevo bounds for min-plus orbit channels,
- post-quantum trapdoor coding from arithmetic orbit expanders,
- certified robustness certificates from arithmetic fidelity decay,
- thermodynamic entropy production analogues for Berggren orbit mixing.

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
            Define a finite quantum channel family whose Kraus structure is indexed by finite Berggren-tree orbit slices of primitive Pythagorean triples, and prove that orbit growth and triple-norm separation induce explicit Holevo-capacity lower bounds and collision-controlled distinguishability bounds. The core result should show that if a codebook is supported on a Berggren slice with certified pairwise hypotenuse-gap or Euclidean-norm-gap, then the induced ensemble of output states has a computable lower bound on accessible classical information, linking Diophantine orbit geometry to quantum communication. This directly extends the recently productive quantum-entropy and quantum-Pythagorean lines without repeating the in-flight trapdoor/extractor jobs.

            ### Precise Mathematical Framing
            Let T_n be the depth-n Berggren slice of primitive triples (a,b,c). Construct a Hilbert space H_n with orthonormal basis |t> for t in T_n, and define an encoding family rho_t or a channel Phi_n whose outputs depend functorially on normalized invariants of t, such as c/(a+b+c) and norm profiles. Prove: (1) a separation lemma converting certified triple-norm gaps into trace-distance or fidelity gaps between rho_t and rho_u; (2) a packing lemma showing large Berggren antichains yield ensembles with bounded pairwise overlap; (3) a Holevo lower-bound theorem: chi({p_t,rho_t}) >= f(Delta_n,|C_n|) for an explicit function of orbit separation Delta_n and codebook size C_n; (4) an entropy-stability result under Berggren expansion maps, showing controlled degradation or monotonicity of distinguishability across tree depth. This opens a Diophantine quantum coding program: arithmetic structure generates analyzable quantum codebooks with formally certified information rates.

            ### Lean 4 Sketch
Create Bridges/QuantumPythagoreanInformation.lean importing the recent finite quantum channel entropy development and the Berggren-tree/triple-norm infrastructure. Main definitions: BerggrenSlice, TripleInvariantState, BerggrenEnsemble, orbitOverlap, berggrenChannel. Main lemmas: triple_gap_to_fidelity_bound, pairwise_overlap_bound_of_norm_separation, holevo_lower_bound_of_packing, berggren_depth_monotone_capacity_bound.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `capacity_lower_bound_degree` : theorem capacity_lower_bound_degree (n d : ℕ) (hn : 1 ≤ n) :
     (file: Bridges/HilbertVCCorrespondence.lean)
  2. `entropy_capacity_bound` : theorem entropy_capacity_bound (n d : ℕ) :
     (file: Bridges/RingTheoreticLearning.lean)
  3. `quantum_consensus_query_lower_bound` : theorem quantum_consensus_query_lower_bound (gap : ℝ) (hgap : 0 < gap) :
     (file: Bridges/SheafConsensus/Spectral.lean)
  4. `quantum_spectral_entropy_bound` : theorem quantum_spectral_entropy_bound (d : ℕ) :
     (file: Bridges/SpectralApplications.lean)
  5. `score_gap_lower_bound` : theorem score_gap_lower_bound {n : ℕ} (wa wb φ ψ : TestVec n) {ε : ℝ}
     (file: Bridges/TropicalSatakeMargin.lean)

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



Recent successful concepts: Quantum Pythagorean Trapdoors via Berggren Tree State Preparation and Triple-Norm Collision Bounds, Categorical Tropical–Ultrametric Equivalence via Valuation Reconstruction and Functorial Bound Transfer, Lawvere Metric Semantics for Emergent Meta-Language Closures


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
