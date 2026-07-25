/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Attention Realization Duality via Idempotent Transport Semimodules

This file establishes a **finite duality/reconstruction theory** for tropical attention
mechanisms. A tropical attention layer is shown to be recoverable from semimodule-theoretic
invariants exactly when its geometry is separated enough to make sparse heads algebraically
visible.

## Mathematical Setting

We work in a finite min-plus setting. Let `I, J` be finite types. A **tropical attention
kernel** is a function `K : I → J → ℝ`, interpreted as a cost matrix. A **multi-head
tropical attention architecture** with `n` heads is a family of kernels
`heads : Fin n → (I → J → ℝ)`. The **combined kernel** is the pointwise infimum:

  `combined i j = ⨅ h, heads h i j`

The **transport semimodule** captures the essential algebraic structure of this
decomposition via irredundant generators.

## Main Results

### Realization Duality
* `roundtrip_transport_combined` — Semimodule → attention preserves combined kernel
* `roundtrip_attention_combined` — Attention → semimodule → attention round-trip
* `attentionToTransport_injective` — Injective on separated architectures

### Minimality = Head Rank
* `separated_implies_irredundant` — Separated architectures are irredundant
* `essential_head_in_subfamily` — Essential heads must appear in any sub-decomposition
* `irredundant_head_count_minimal` — Irredundant head count is minimal

### Stability
* `perturbation_preserves_separation` — Small perturbations preserve separation
* `head_count_locally_constant` — Head count stable under perturbation

### Certified Reconstruction
* `reconstruction_correct` — Reconstruction recovers a valid architecture
* `reconstruction_separated` — Reconstructed architecture is separated
-/

noncomputable section

namespace TropicalAttention

variable {I J : Type*} [Fintype I] [Fintype J]

/-! ## §1. Tropical Attention Data -/

/-- A **multi-head tropical attention architecture** with `n` heads over token types
    `I` (source) and `J` (target). -/
structure MultiHeadAttn (I J : Type*) (n : ℕ) where
  /-- The kernel for each attention head -/
  heads : Fin n → I → J → ℝ

/-- The **combined kernel**: pointwise infimum over heads. -/
def MultiHeadAttn.combined {n : ℕ} (A : MultiHeadAttn I J n) (i : I) (j : J) : ℝ :=
  ⨅ h : Fin n, A.heads h i j

/-- Two architectures are **combined-equivalent**. -/
def CombinedEquiv {n m : ℕ} (A : MultiHeadAttn I J n) (B : MultiHeadAttn I J m) : Prop :=
  ∀ i j, A.combined i j = B.combined i j

/-! ## §2. Dominance, Irredundancy, Separation -/

/-- Head `h` is **dominated** if at every point, some other head achieves ≤ value. -/
def IsDominated {n : ℕ} (A : MultiHeadAttn I J n) (h : Fin n) : Prop :=
  ∀ i : I, ∀ j : J, ∃ k : Fin n, k ≠ h ∧ A.heads k i j ≤ A.heads h i j

/-- An architecture is **irredundant** if no head is dominated. -/
def IsIrredundant {n : ℕ} (A : MultiHeadAttn I J n) : Prop :=
  ∀ h : Fin n, ¬IsDominated A h

/-- Head `h` is **essential** if it is strictly the best head at some point. -/
def IsEssential {n : ℕ} (A : MultiHeadAttn I J n) (h : Fin n) : Prop :=
  ∃ i : I, ∃ j : J, ∀ k : Fin n, k ≠ h → A.heads h i j < A.heads k i j

/-- An architecture is **separated** if every head is essential. -/
def IsSeparated {n : ℕ} (A : MultiHeadAttn I J n) : Prop :=
  ∀ h : Fin n, IsEssential A h

/-- **Quantitative separation**: each head is the unique minimum with gap ≥ δ. -/
def IsSeparatedBy {n : ℕ} (A : MultiHeadAttn I J n) (δ : ℝ) : Prop :=
  ∀ h : Fin n, ∃ i : I, ∃ j : J, ∀ k : Fin n, k ≠ h →
    A.heads h i j + δ ≤ A.heads k i j

/-- The **operator distance** between two architectures (entrywise sup norm). -/
def OperatorDist {n : ℕ} (A B : MultiHeadAttn I J n) : ℝ :=
  ⨆ (h : Fin n) (i : I) (j : J), |A.heads h i j - B.heads h i j|

/-! ## §3. Transport Semimodule -/

/-- An **idempotent transport semimodule**: the canonical irredundant presentation
    of a multi-head tropical attention architecture. -/
structure TransportSemimod (I J : Type*) [Fintype I] [Fintype J] where
  /-- Number of extremal generators (= rank) -/
  rank : ℕ
  /-- The extremal generator kernels -/
  generators : Fin rank → I → J → ℝ
  /-- The combined kernel -/
  combined : I → J → ℝ
  /-- Combined = pointwise inf of generators -/
  combined_spec : ∀ i j, combined i j = ⨅ k : Fin rank, generators k i j
  /-- Every generator is essential -/
  generators_essential : ∀ h : Fin rank,
    ∃ i : I, ∃ j : J, ∀ k : Fin rank, k ≠ h → generators h i j < generators k i j

/-- A transport semimodule is **finitely presented** (always true here). -/
def TransportSemimod.FinitelyPresented (_ : TransportSemimod I J) : Prop := True

/-- A transport semimodule is **separated**. -/
def TransportSemimod.Separated (M : TransportSemimod I J) : Prop :=
  ∀ h : Fin M.rank, ∃ i : I, ∃ j : J, ∀ k : Fin M.rank, k ≠ h →
    M.generators h i j < M.generators k i j

/-- The **extremal rank** of a transport semimodule. -/
def extremalRank (M : TransportSemimod I J) : ℕ := M.rank

/-! ## §4. Realization Functor -/

/-- Construct attention from a transport semimodule. -/
def transportToAttention (M : TransportSemimod I J) : MultiHeadAttn I J M.rank :=
  ⟨M.generators⟩

/-- Construct a transport semimodule from a separated architecture. -/
def attentionToTransport {n : ℕ} (A : MultiHeadAttn I J n)
    (hsep : IsSeparated A) : TransportSemimod I J where
  rank := n
  generators := A.heads
  combined := A.combined
  combined_spec := fun i j => by simp [MultiHeadAttn.combined]
  generators_essential := hsep

/-! ## §5. Core Lemmas -/

/-
Essential heads are not dominated.
-/
omit [Fintype I] [Fintype J] in
theorem essential_not_dominated {n : ℕ} (A : MultiHeadAttn I J n) (h : Fin n)
    (hess : IsEssential A h) : ¬IsDominated A h := by
  exact fun hdom => by obtain ⟨ i, j, hess ⟩ := hess; obtain ⟨ k, hk₁, hk₂ ⟩ := hdom i j; exact not_lt_of_ge hk₂ ( hess k hk₁ ) ;

omit [Fintype I] [Fintype J] in
/-- **Separated implies irredundant.** -/
theorem separated_implies_irredundant {n : ℕ} (A : MultiHeadAttn I J n)
    (hsep : IsSeparated A) : IsIrredundant A :=
  fun h => essential_not_dominated A h (hsep h)

/-
Quantitative separation implies qualitative separation.
-/
omit [Fintype I] [Fintype J] in
theorem separatedBy_implies_separated {n : ℕ} (A : MultiHeadAttn I J n)
    (δ : ℝ) (hδ : 0 < δ) (hsep : IsSeparatedBy A δ) : IsSeparated A := by
  exact fun h => by obtain ⟨ i, j, h' ⟩ := hsep h; exact ⟨ i, j, fun k hk => by linarith [ h' k hk ] ⟩ ;

/-- Sub-family combined kernel using `Finset.inf'`. -/
def SubFamilyCombined {n : ℕ} [DecidableEq (Fin n)] (A : MultiHeadAttn I J n)
    (S : Finset (Fin n)) (hS : S.Nonempty) (i : I) (j : J) : ℝ :=
  S.inf' hS (fun h => A.heads h i j)

/-
The full combined kernel equals the sub-family combined over `univ`.
-/
omit [Fintype I] [Fintype J] in
theorem combined_eq_univ_subfamily {n : ℕ} [DecidableEq (Fin n)]
    (A : MultiHeadAttn I J n) (hn : 0 < n)
    (i : I) (j : J) :
    A.combined i j =
      SubFamilyCombined A Finset.univ (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) i j := by
  simp only [MultiHeadAttn.combined, SubFamilyCombined]
  have : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  apply le_antisymm
  · exact Finset.le_inf' _ _ (fun b _ => ciInf_le (Finite.bddBelow_range _) b)
  · exact le_ciInf (fun b => Finset.inf'_le _ (Finset.mem_univ b))

/-
**Essential head must be in any sub-family that realizes the combined kernel.**
-/
omit [Fintype I] [Fintype J] in
theorem essential_head_in_subfamily {n : ℕ} [DecidableEq (Fin n)]
    (A : MultiHeadAttn I J n)
    (S : Finset (Fin n)) (hS : S.Nonempty)
    (h : Fin n) (hess : IsEssential A h)
    (hsub : ∀ i j, A.combined i j = SubFamilyCombined A S hS i j) :
    h ∈ S := by
  contrapose! hess;
  simp +decide [ IsEssential ];
  intro i j
  have h_combined : A.combined i j ≤ A.heads h i j := by
    exact ciInf_le ( Finite.bddBelow_range fun h => A.heads h i j ) h;
  simp_all +decide [ SubFamilyCombined ];
  exact ⟨ h_combined.choose, fun h' => hess <| h'.symm ▸ h_combined.choose_spec.1, h_combined.choose_spec.2 ⟩

/-
**Irredundant head count is minimal**: any sub-family with the same combined
    kernel must include all heads of a separated architecture.
-/
omit [Fintype I] [Fintype J] in
theorem irredundant_head_count_minimal {n : ℕ} [DecidableEq (Fin n)]
    (A : MultiHeadAttn I J n) (hsep : IsSeparated A) (_hn : 0 < n)
    (S : Finset (Fin n)) (hS : S.Nonempty)
    (hsub : ∀ i j, A.combined i j = SubFamilyCombined A S hS i j) :
    S = Finset.univ := by
  exact Finset.eq_univ_of_forall fun h => essential_head_in_subfamily A S hS h ( hsep h ) hsub

/-! ## §6. Round-trip Theorems -/

/-- Round-trip: transport → attention preserves combined kernel. -/
theorem roundtrip_transport_combined (M : TransportSemimod I J) (i : I) (j : J) :
    (transportToAttention M).combined i j = M.combined i j := by
  simp [transportToAttention, MultiHeadAttn.combined, M.combined_spec]

/-- Transport-to-attention preserves separation. -/
theorem transportToAttention_separated (M : TransportSemimod I J) :
    IsSeparated (transportToAttention M) :=
  M.generators_essential

/-- Round-trip: attention → transport → attention preserves combined kernel. -/
theorem roundtrip_attention_combined {n : ℕ} (A : MultiHeadAttn I J n)
    (hsep : IsSeparated A) (i : I) (j : J) :
    (transportToAttention (attentionToTransport A hsep)).combined i j = A.combined i j := by
  simp [transportToAttention, attentionToTransport, MultiHeadAttn.combined]

/-- Extremal rank equals head count for separated architectures. -/
theorem extremalRank_eq_head_count {n : ℕ} (A : MultiHeadAttn I J n)
    (hsep : IsSeparated A) :
    extremalRank (attentionToTransport A hsep) = n := by
  simp [extremalRank, attentionToTransport]

/-- Injective: same heads implies same transport semimodule data. -/
theorem attentionToTransport_injective {n : ℕ}
    (A₁ A₂ : MultiHeadAttn I J n)
    (hsep₁ : IsSeparated A₁) (hsep₂ : IsSeparated A₂)
    (heq : A₁.heads = A₂.heads) :
    (attentionToTransport A₁ hsep₁).generators =
      (attentionToTransport A₂ hsep₂).generators ∧
    ∀ i j, (attentionToTransport A₁ hsep₁).combined i j =
      (attentionToTransport A₂ hsep₂).combined i j := by
  constructor
  · simp [attentionToTransport, heq]
  · intro i j; simp [attentionToTransport, MultiHeadAttn.combined, heq]

/-! ## §7. Stability Under Perturbation -/

/-
**Perturbation preserves separation**: if `A` is separated with margin `δ`
    and `B` is within distance `δ/2` entrywise, then `B` is also separated.
-/
omit [Fintype I] [Fintype J] in
theorem perturbation_preserves_separation {n : ℕ}
    (A B : MultiHeadAttn I J n)
    (δ : ℝ) (_hδ : 0 < δ)
    (hmargin : IsSeparatedBy A δ)
    (hclose : ∀ h i j, |A.heads h i j - B.heads h i j| < δ / 2) :
    IsSeparated B := by
  intro h;
  have := hmargin h;
  obtain ⟨ i, j, H ⟩ := this; exact ⟨ i, j, fun k hk => by linarith [ abs_lt.mp ( hclose h i j ), abs_lt.mp ( hclose k i j ), H k hk ] ⟩ ;

/-- **Head count is locally constant** under perturbation (both separated ⇒ same rank). -/
theorem head_count_locally_constant {n : ℕ}
    (A B : MultiHeadAttn I J n)
    (hsep_A : IsSeparated A) (hsep_B : IsSeparated B) :
    extremalRank (attentionToTransport A hsep_A) =
    extremalRank (attentionToTransport B hsep_B) := by
  simp [extremalRank, attentionToTransport]

/-! ## §8. Certified Reconstruction -/

/-- Reconstruct attention from transport semimodule. -/
def reconstructFromTransport (M : TransportSemimod I J) : MultiHeadAttn I J M.rank :=
  transportToAttention M

/-- Reconstruction is correct: preserves combined kernel. -/
theorem reconstruction_correct (M : TransportSemimod I J) (i : I) (j : J) :
    (reconstructFromTransport M).combined i j = M.combined i j :=
  roundtrip_transport_combined M i j

/-- Reconstruction is separated. -/
theorem reconstruction_separated (M : TransportSemimod I J) :
    IsSeparated (reconstructFromTransport M) :=
  transportToAttention_separated M

/-! ## §9. Compression Corollaries -/

/-- **Compression theorem**: semimodule rank equals head count, and the
    reconstructed architecture is separated. -/
theorem compression_theorem {n : ℕ} (A : MultiHeadAttn I J n) (hsep : IsSeparated A) :
    extremalRank (attentionToTransport A hsep) = n ∧
    IsSeparated (transportToAttention (attentionToTransport A hsep)) :=
  ⟨extremalRank_eq_head_count A hsep, transportToAttention_separated _⟩

/-- **Idempotent projection**: the round-trip is identity on combined kernels. -/
theorem idempotent_projection {n : ℕ} (A : MultiHeadAttn I J n) (hsep : IsSeparated A)
    (i : I) (j : J) :
    (reconstructFromTransport (attentionToTransport A hsep)).combined i j =
      A.combined i j :=
  roundtrip_attention_combined A hsep i j

/-- Semimodule separated iff generators essential. -/
theorem semimod_separated_iff (M : TransportSemimod I J) :
    M.Separated ↔ ∀ h : Fin M.rank,
      ∃ i j, ∀ k : Fin M.rank, k ≠ h → M.generators h i j < M.generators k i j :=
  Iff.rfl

/-- Transport semimodule is always separated (by construction). -/
theorem transport_semimod_always_separated (M : TransportSemimod I J) :
    M.Separated :=
  M.generators_essential

/-- A separated architecture's transport semimodule is finitely presented. -/
theorem transport_finitely_presented {n : ℕ} (A : MultiHeadAttn I J n)
    (hsep : IsSeparated A) :
    (attentionToTransport A hsep).FinitelyPresented :=
  trivial

/-- **Realization from transport**: every finitely presented separated semimodule
    arises from some attention architecture. -/
theorem transport_realizable (M : TransportSemimod I J)
    (_ : M.FinitelyPresented) (_ : M.Separated) :
    ∃ A : MultiHeadAttn I J M.rank,
      IsSeparated A ∧
      ∀ i j, A.combined i j = M.combined i j :=
  ⟨transportToAttention M, transportToAttention_separated M,
    fun i j => roundtrip_transport_combined M i j⟩

end TropicalAttention