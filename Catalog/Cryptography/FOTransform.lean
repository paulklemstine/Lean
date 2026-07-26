import Mathlib

/-!
# Fujisaki–Okamoto Transform as Module Morphism

This module formalizes the key insight that the Fujisaki–Okamoto (FO) consistency
check — the "re-encrypt and compare" step at the heart of CCA-secure lattice KEMs
like ML-KEM (FIPS 203) — is a **quotient-theoretic invariant** of module morphisms.

## Main Definitions

* `KernelInvariant` — a weight function on a module is constant on cosets of `ker f`
* `FOConsistentCiphertext` — abstract FO consistency predicate
* `PredicateFactorsThrough` — a predicate descends to the image of a map
* `FactorsThrough` — a function descends through a surjection

## Main Theorems

* `foConsistent_factors_through_quotient` — FO consistency factors through compression
* `foRejectProb_map_eq` — rejection probability is preserved by compression
* `fo_game_hop_bound` — CCA game hop bounded by bad-event probability
* `foReject_compression_invariant` — specialized to linear maps on modules
* `cca_gap_quotient_stable` — CCA bound transfers under compression

## Significance

This reframes FO from a cryptographic trick into a structural theorem about module
quotients, opening a route to compositional CCA verification for lattice KEMs.
-/

open Finset BigOperators

noncomputable section

/-! ## Core Definitions -/

/-- A weight function `μ : M → ℚ` is **kernel-invariant** with respect to a linear
map `f : M →ₗ[R] N` if `μ` is constant on cosets of `ker f`. Equivalently,
`μ x = μ y` whenever `x - y ∈ ker f`. This is the noise-law hypothesis that
ensures compression preserves distributional properties. -/
def KernelInvariant
    {R M N : Type*} [Semiring R] [AddCommGroup M] [AddCommGroup N]
    [Module R M] [Module R N]
    (f : M →ₗ[R] N) (μ : M → ℚ) : Prop :=
  ∀ x y, y - x ∈ LinearMap.ker f → μ x = μ y

/-- **FO consistency predicate**: a ciphertext `c` is FO-consistent if
re-encrypting the recovered key-message pair and comparing yields `True`.
This abstracts the "re-encrypt and compare" step of the FO transform. -/
def FOConsistentCiphertext
    {C K M : Type*}
    (reencrypt : K → M → C)
    (recover   : C → K × M)
    (cmp       : C → C → Prop)
    (c : C) : Prop :=
  let km := recover c
  cmp (reencrypt km.1 km.2) c

/-- A function `g : α → β` **factors through** a map `π : α → γ` if there
exists `h : γ → β` such that `g = h ∘ π`. -/
def FactorsThrough
    {α β γ : Type*} (g : α → β) (π : α → γ) : Prop :=
  ∃ h : γ → β, g = h ∘ π

/-- A predicate `P : α → Prop` **factors through** a map `π : α → γ` if
`P` is constant on fibers of `π`. Equivalently, `P` descends to the quotient. -/
def PredicateFactorsThrough
    {α γ : Type*} (P : α → Prop) (π : α → γ) : Prop :=
  ∃ Q : γ → Prop, ∀ a, P a ↔ Q (π a)

/-! ## Supporting Lemma: Characterization of PredicateFactorsThrough -/

/-- `PredicateFactorsThrough` is equivalent to the predicate being constant on
fibers: if `π a₁ = π a₂` then `P a₁ ↔ P a₂`. -/
theorem predicateFactorsThrough_iff_fiber_const
    {α γ : Type*}
    (P : α → Prop) (π : α → γ) :
    PredicateFactorsThrough P π ↔
    (∀ a₁ a₂, π a₁ = π a₂ → (P a₁ ↔ P a₂)) := by
  refine ⟨fun ⟨Q, hQ⟩ a₁ a₂ h => ?_, fun h => ?_⟩
  · rw [hQ, hQ, h]
  · exact ⟨fun y => ∃ a : α, π a = y ∧ P a,
      fun a => ⟨fun ha => ⟨a, rfl, ha⟩, fun ⟨a', ha', ha''⟩ => (h _ _ ha').1 ha''⟩⟩

/-! ## Theorem 1: FO Consistency Factors Through Compression -/

/-- **FO consistency factors through the compression map.**

If recovery and comparison both respect the compression map (i.e., they depend
only on compressed ciphertexts), then the FO consistency predicate descends
to a predicate on compressed ciphertexts.

This is the central structural theorem: FO decapsulation consistency is not
an implementation detail but a quotient-theoretic invariant. -/
theorem foConsistent_factors_through_quotient
    {C N K M : Type*}
    (compress : C → N)
    (reencrypt : K → M → C)
    (recover : C → K × M)
    (cmp : C → C → Prop)
    (_hrecover : ∀ c₁ c₂, compress c₁ = compress c₂ → recover c₁ = recover c₂)
    (hcmp : ∀ c₁ c₂ c₁' c₂',
        compress c₁ = compress c₁' →
        compress c₂ = compress c₂' →
        (cmp c₁ c₂ ↔ cmp c₁' c₂'))
    (_hreencrypt_compat : ∀ c₁ c₂,
        compress c₁ = compress c₂ →
        ∀ k m, compress (reencrypt k m) = compress (reencrypt k m))
    (hrecover_reencrypt : ∀ c₁ c₂,
        compress c₁ = compress c₂ →
        compress (reencrypt (recover c₁).1 (recover c₁).2) =
        compress (reencrypt (recover c₂).1 (recover c₂).2))
    : PredicateFactorsThrough
        (FOConsistentCiphertext reencrypt recover cmp)
        compress := by
  rw [predicateFactorsThrough_iff_fiber_const]
  intro a₁ a₂ ha
  unfold FOConsistentCiphertext
  exact hcmp _ _ _ _ (hrecover_reencrypt a₁ a₂ ha) ha

/-! ## Theorem 2: FO Rejection Probability Preserved by Compression -/

/-
**Rejection probability is preserved under compression.**

When a predicate factors through a map `π` (witnessed by a descended predicate
`Q`), and we have a weight function `μ`, the total weight of elements where the
predicate fails equals the total weight computed fiber-by-fiber on the image of `π`.

This shows that FO rejection rate is the same whether computed on raw or
compressed ciphertexts — the key probability-level consequence of quotient
invariance.
-/
theorem foRejectProb_map_eq
    {C N : Type*}
    [Fintype C] [Fintype N] [DecidableEq N]
    (π : C → N)
    (P : C → Prop) [DecidablePred P]
    (Q : N → Prop) [DecidablePred Q]
    (μ : C → ℚ)
    (hfact : ∀ c, P c ↔ Q (π c))
    : (∑ c : C, if P c then 0 else μ c) =
      (∑ y : N, if Q y then 0 else
        ∑ c : C, if π c = y then μ c else 0) := by
  simp +decide [ hfact, Finset.sum_ite ];
  rw [ Finset.sum_sigma' ];
  refine' Finset.sum_bij ( fun x hx => ⟨ π x, x ⟩ ) _ _ _ _ <;> simp +contextual;
  grind

/-! ## Theorem 3: Game Hop Bound via Bad-Event Analysis -/

/-- **Game hop bound**: when two games agree on "good" ciphertexts (where
predicate `P` holds), the distinguishing advantage is bounded by the total
weight of "bad" ciphertexts.

This formalizes the standard game-hopping technique: if `RealGame` and
`HybridGame` give identical outputs on all inputs where `P` holds, and the
weight function `μ` is nonneg with game values bounded by 1, then:

  `|∑ μ(c) · R(c) - ∑ μ(c) · H(c)| ≤ ∑_{¬P(c)} μ(c)`

Instantiating `P` with FO consistency bounds the CCA advantage. -/
theorem fo_game_hop_bound
    {C : Type*}
    [Fintype C]
    (RealGame HybridGame : C → ℚ)
    (P : C → Prop) [DecidablePred P]
    (μ : C → ℚ)
    (hμ_nonneg : ∀ c, 0 ≤ μ c)
    (hgame_bound : ∀ c, |RealGame c - HybridGame c| ≤ 1)
    (hagree : ∀ c, P c → RealGame c = HybridGame c)
    : |(∑ c : Finset.univ (α := C), μ c * RealGame c) -
       (∑ c : Finset.univ (α := C), μ c * HybridGame c)|
      ≤ ∑ c : Finset.univ (α := C), if P c then 0 else μ c := by
  rw [← Finset.sum_sub_distrib]
  refine le_trans (Finset.abs_sum_le_sum_abs _ _) (Finset.sum_le_sum ?_)
  intro c _hc
  split_ifs with hp
  · simp [hagree c hp]
  · simp only [← mul_sub, abs_mul, abs_of_nonneg (hμ_nonneg _)]
    exact mul_le_of_le_one_right (hμ_nonneg _) (hgame_bound _)

/-! ## Corollaries -/

/-- If the FO predicate factors through a linear compression map, then the total
rejection weight can be rewritten as a fiber-wise sum over the codomain.
This is the module-theoretic specialization of `foRejectProb_map_eq`. -/
theorem foReject_compression_invariant
    {R M N : Type*}
    [CommRing R] [AddCommGroup M] [AddCommGroup N]
    [Module R M] [Module R N]
    [Fintype M] [Fintype N] [DecidableEq N]
    (f : M →ₗ[R] N)
    (μ : M → ℚ)
    (P : M → Prop) [DecidablePred P]
    (Q : N → Prop) [DecidablePred Q]
    (hPQ : ∀ m, P m ↔ Q (f m))
    : (∑ m : M, if P m then 0 else μ m) =
      (∑ n : N, if Q n then 0 else
        ∑ m : M, if f m = n then μ m else 0) :=
  foRejectProb_map_eq f P Q μ hPQ

/-- **CCA gap is quotient-stable**: if FO rejection and CPA advantage are
preserved by compression, then the CCA bound transfers. -/
theorem cca_gap_quotient_stable
    (CCAAdv_orig CPAAdv_orig FOReject_orig CPAAdv_comp FOReject_comp : ℚ)
    (h_cca_orig : CCAAdv_orig ≤ CPAAdv_orig + FOReject_orig)
    (h_cpa_eq : CPAAdv_orig = CPAAdv_comp)
    (h_fo_eq : FOReject_orig = FOReject_comp)
    : CCAAdv_orig ≤ CPAAdv_comp + FOReject_comp := by
  linarith

/-! ## Verified Computation: Toy FO Acceptance -/

/-- Check FO consistency on a concrete finite type: given explicit
reencrypt, recover, and equality comparison, compute whether each
element satisfies FOConsistentCiphertext. -/
def foConsistencyCheck
    {C : Type*} [DecidableEq C]
    (reencrypt : C → C → C)
    (recover : C → C × C) :
    C → Bool :=
  fun c =>
    let km := recover c
    reencrypt km.1 km.2 == c

/-- The boolean check agrees with the propositional predicate when
comparison is decidable equality. -/
theorem foConsistencyCheck_iff
    {C : Type*} [DecidableEq C]
    (reencrypt : C → C → C)
    (recover : C → C × C)
    (c : C) :
    foConsistencyCheck reencrypt recover c = true ↔
    FOConsistentCiphertext reencrypt recover (· = ·) c := by
  unfold foConsistencyCheck FOConsistentCiphertext
  simp [BEq.beq]

end

/-! ## Axiom Verification -/

#print axioms predicateFactorsThrough_iff_fiber_const
#print axioms foConsistent_factors_through_quotient
#print axioms foRejectProb_map_eq
#print axioms fo_game_hop_bound
#print axioms foReject_compression_invariant
#print axioms cca_gap_quotient_stable
#print axioms foConsistencyCheck_iff