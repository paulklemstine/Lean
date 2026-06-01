/-
Copyright (c) 2025 Surveillance Network Information Theory Project. All rights reserved.

# Surveillance Networks: Information-Theoretic Undetectability

## Bridge: Rate-Distortion Theory ↔ Network Privacy ↔ Social Network Analysis

We formalize the privacy-utility tradeoff in finite surveillance networks and prove
that perfect surveillance and perfect privacy are mutually exclusive.

## Main Results
* **Theorem 1** (Privacy-Surveillance Exclusion): injective and constant channels
  are incompatible on non-trivial configuration spaces.
* **Theorem 2** (Packing Bound): channel image size ≥ packing number.
* **Theorem 3** (Trivial Channel Distortion): constant channels incur error.
* **Theorem 4** (Identity Channel): achieves zero distortion but no privacy.
* **Theorem 5** (Fiber Product Bound): configs ≤ imageSize × maxFiber.
-/

import Mathlib

open Finset Function BigOperators

/-! ## Section 1: Network Configurations -/

/-- A `NetworkConfig` on `n` nodes: the full adjacency matrix as `Fin n → Fin n → Bool`. -/
@[ext]
structure NetworkConfig (n : ℕ) where
  adj : Fin n → Fin n → Bool
  deriving DecidableEq

noncomputable instance (n : ℕ) : Fintype (NetworkConfig n) :=
  Fintype.ofInjective NetworkConfig.adj (fun _ _ h => NetworkConfig.ext h)

instance (n : ℕ) : Inhabited (NetworkConfig n) := ⟨⟨fun _ _ => false⟩⟩
instance (n : ℕ) : Nonempty (NetworkConfig n) := ⟨default⟩

/-! ## Section 2: Edge Distortion (Hamming Distance on Adjacency Matrices) -/

/-- The **edge distortion**: number of (directed) edge slots where configs disagree. -/
def edgeDistortion {n : ℕ} (g₁ g₂ : NetworkConfig n) : ℕ :=
  (Finset.univ.filter (fun p : Fin n × Fin n => g₁.adj p.1 p.2 ≠ g₂.adj p.1 p.2)).card

@[simp]
theorem edgeDistortion_self {n : ℕ} (g : NetworkConfig n) :
    edgeDistortion g g = 0 := by
  simp [edgeDistortion]

theorem edgeDistortion_symm {n : ℕ} (g₁ g₂ : NetworkConfig n) :
    edgeDistortion g₁ g₂ = edgeDistortion g₂ g₁ := by
  unfold edgeDistortion; congr 1; ext p
  simp only [Finset.mem_filter, Finset.mem_univ, true_and]; exact ne_comm

theorem edgeDistortion_eq_zero_iff {n : ℕ} (g₁ g₂ : NetworkConfig n) :
    edgeDistortion g₁ g₂ = 0 ↔ g₁ = g₂ := by
  constructor
  · intro h
    unfold edgeDistortion at h
    rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff] at h
    ext i j
    have := h (Finset.mem_univ (⟨i,j⟩ : Fin n × Fin n))
    simpa using this
  · rintro rfl; simp

theorem edgeDistortion_triangle {n : ℕ} (g₁ g₂ g₃ : NetworkConfig n) :
    edgeDistortion g₁ g₃ ≤ edgeDistortion g₁ g₂ + edgeDistortion g₂ g₃ := by
  exact le_trans ( Finset.card_mono fun x hx => by by_cases h : g₁.adj x.1 x.2 = g₂.adj x.1 x.2 <;> aesop ) ( Finset.card_union_le _ _ )

theorem edgeDistortion_le {n : ℕ} (g₁ g₂ : NetworkConfig n) :
    edgeDistortion g₁ g₂ ≤ n * n := by
  exact le_trans ( Finset.card_filter_le _ _ ) ( by norm_num )

/-! ## Section 3: Surveillance Channels -/

/-- A deterministic surveillance channel mapping network configs to codes. -/
structure SurveillanceChannel (n : ℕ) (C : Type*) where
  encode : NetworkConfig n → C

/-- A reconstruction map from codes back to network configs. -/
structure ReconstructionMap (n : ℕ) (C : Type*) where
  decode : C → NetworkConfig n

/-- Channel image size: number of distinct observation values. -/
noncomputable def channelImageSize {n : ℕ} {C : Type*} [Fintype C] [DecidableEq C]
    (ch : SurveillanceChannel n C) : ℕ :=
  (Finset.univ.image ch.encode).card

/-- A channel is **trivial** if it maps everything to the same code. -/
def isTrivialChannel {n : ℕ} {C : Type*} [DecidableEq C]
    (ch : SurveillanceChannel n C) : Prop :=
  ∀ g₁ g₂ : NetworkConfig n, ch.encode g₁ = ch.encode g₂

/-- A channel is **injective** (perfect surveillance). -/
def isInjectiveChannel {n : ℕ} {C : Type*}
    (ch : SurveillanceChannel n C) : Prop :=
  Function.Injective ch.encode

/-! ## Section 4: Theorem 1 — Privacy-Surveillance Mutual Exclusion -/

/-- Trivial channels have image size ≤ 1. -/
theorem trivialChannel_imageSize_le_one {n : ℕ} {C : Type*} [Fintype C] [DecidableEq C]
    (ch : SurveillanceChannel n C) (htriv : isTrivialChannel ch) :
    channelImageSize ch ≤ 1 := by
  unfold channelImageSize
  rw [Finset.card_le_one]
  intro a ha b hb
  simp only [Finset.mem_image, Finset.mem_univ, true_and] at ha hb
  obtain ⟨ga, rfl⟩ := ha; obtain ⟨gb, rfl⟩ := hb
  exact htriv ga gb

/-
Injective channels on ≥ 2 elements have image size ≥ 2.
-/
theorem injectiveChannel_imageSize_ge_two {n : ℕ} {C : Type*} [Fintype C] [DecidableEq C]
    (ch : SurveillanceChannel n C) (hinj : isInjectiveChannel ch)
    (g₁ g₂ : NetworkConfig n) (hne : g₁ ≠ g₂) :
    2 ≤ channelImageSize ch := by
  refine' Finset.one_lt_card.2 ⟨ ch.encode g₁, _, ch.encode g₂, _, _ ⟩ <;> simp +decide [ hinj.eq_iff, hne ]

/-- **Theorem 1: Privacy-Surveillance Mutual Exclusion.**
    A channel cannot be simultaneously trivial and injective on a space with ≥ 2 elements.
    This is the fundamental impossibility: perfect privacy (trivial) and perfect
    surveillance (injective) are mutually exclusive in any non-degenerate network. -/
theorem privacy_surveillance_exclusion {n : ℕ} {C : Type*} [Fintype C] [DecidableEq C]
    (ch : SurveillanceChannel n C)
    (g₁ g₂ : NetworkConfig n) (hne : g₁ ≠ g₂) :
    ¬(isTrivialChannel ch ∧ isInjectiveChannel ch) := by
  intro ⟨htriv, hinj⟩
  have h1 := trivialChannel_imageSize_le_one ch htriv
  have h2 := injectiveChannel_imageSize_ge_two ch hinj g₁ g₂ hne
  omega

/-! ## Section 5: Theorem 3 — Trivial Channel Distortion -/

/-- **Theorem 3: Trivial Channel Distortion.**
    A trivial channel must incur nonzero reconstruction error on at least
    one of any two distinct inputs. This is because both inputs map to the
    same code, so the reconstruction returns the same output for both. -/
theorem trivialChannel_distortion_nonzero {n : ℕ} {C : Type*} [DecidableEq C]
    (ch : SurveillanceChannel n C) (rec : ReconstructionMap n C)
    (htriv : isTrivialChannel ch)
    (g₁ g₂ : NetworkConfig n) (hne : g₁ ≠ g₂) :
    edgeDistortion g₁ (rec.decode (ch.encode g₁)) ≠ 0 ∨
    edgeDistortion g₂ (rec.decode (ch.encode g₂)) ≠ 0 := by
  by_contra h
  push_neg at h
  rw [edgeDistortion_eq_zero_iff] at h
  have heq : ch.encode g₁ = ch.encode g₂ := htriv g₁ g₂
  rw [heq] at h
  rw [edgeDistortion_eq_zero_iff] at h
  exact hne (h.1.trans h.2.symm)

/-! ## Section 6: Theorem 4 — Identity Channel -/

/-- The identity channel: transmits the full configuration. -/
def identityChannel (n : ℕ) : SurveillanceChannel n (NetworkConfig n) := ⟨id⟩

/-- The identity reconstruction map. -/
def identityReconstruction (n : ℕ) : ReconstructionMap n (NetworkConfig n) := ⟨id⟩

/-- **Theorem 4: Identity Channel Perfect Surveillance.**
    Zero distortion for every input. -/
theorem identityChannel_zero_distortion {n : ℕ} (g : NetworkConfig n) :
    edgeDistortion g ((identityReconstruction n).decode ((identityChannel n).encode g)) = 0 := by
  simp [identityChannel, identityReconstruction]

theorem identityChannel_injective (n : ℕ) : isInjectiveChannel (identityChannel n) :=
  fun _ _ h => h

theorem identityChannel_not_trivial {n : ℕ}
    (g₁ g₂ : NetworkConfig n) (hne : g₁ ≠ g₂) :
    ¬isTrivialChannel (identityChannel n) :=
  fun h => hne (h g₁ g₂)

/-! ## Section 7: Theorem 2 — Packing Bound -/

/-- Configs pairwise at distance > D. -/
def IsPackingSet {n : ℕ} (S : Finset (NetworkConfig n)) (D : ℕ) : Prop :=
  ∀ g₁ ∈ S, ∀ g₂ ∈ S, g₁ ≠ g₂ → D < edgeDistortion g₁ g₂

/-
**Theorem 2: Packing Bound.**
    If a channel achieves distortion ≤ D on each element of S,
    and S is (2D)-separated, then the channel's image size ≥ |S|.
    Proof: encode is injective on S (triangle inequality argument).
-/
theorem packing_bound {n : ℕ} {C : Type*} [Fintype C] [DecidableEq C]
    (ch : SurveillanceChannel n C) (rec : ReconstructionMap n C)
    (D : ℕ) (S : Finset (NetworkConfig n))
    (hdist : ∀ g ∈ S, edgeDistortion g (rec.decode (ch.encode g)) ≤ D)
    (hsep : IsPackingSet S (2 * D)) :
    S.card ≤ channelImageSize ch := by
  -- By the properties of the packing set and the distortion bound, if $g_1, g_2 \in S$ and $g_1 \ne g_2$, then $label(g_1) \ne label(g_2)$.
  have h_distinct_labels : ∀ g1 ∈ S, ∀ g2 ∈ S, g1 ≠ g2 → ch.encode g1 ≠ ch.encode g2 := by
    intro g1 hg1 g2 hg2 hne h_eq
    have h_dist : edgeDistortion g1 g2 ≤ edgeDistortion g1 (rec.decode (ch.encode g1)) + edgeDistortion g2 (rec.decode (ch.encode g2)) := by
      have := edgeDistortion_triangle g1 ( rec.decode ( ch.encode g1 ) ) g2; simp_all +decide [ edgeDistortion_symm ] ;
    linarith [ hsep g1 hg1 g2 hg2 hne, hdist g1 hg1, hdist g2 hg2 ];
  have h_card_image : (S.image ch.encode).card = S.card := by
    exact Finset.card_image_of_injOn fun g1 hg1 g2 hg2 h => Classical.not_not.1 fun hne => h_distinct_labels g1 hg1 g2 hg2 hne h;
  exact h_card_image ▸ Finset.card_le_card ( Finset.image_subset_image ( Finset.subset_univ _ ) )

/-! ## Section 8: Dynamic Networks -/

/-- A dynamic network: sequence of snapshots over T time steps. -/
@[ext]
structure DynNetwork (n T : ℕ) where
  snapshot : Fin T → NetworkConfig n
  deriving DecidableEq

noncomputable instance (n T : ℕ) : Fintype (DynNetwork n T) :=
  Fintype.ofInjective DynNetwork.snapshot (fun _ _ h => DynNetwork.ext h)

instance (n T : ℕ) : Inhabited (DynNetwork n T) := ⟨⟨fun _ => default⟩⟩

/-- Total distortion across all time steps. -/
def totalEdgeDistortion {n T : ℕ} (d₁ d₂ : DynNetwork n T) : ℕ :=
  ∑ t : Fin T, edgeDistortion (d₁.snapshot t) (d₂.snapshot t)

@[simp]
theorem totalEdgeDistortion_self {n T : ℕ} (d : DynNetwork n T) :
    totalEdgeDistortion d d = 0 := by
  simp [totalEdgeDistortion]

theorem totalEdgeDistortion_eq_zero_iff {n T : ℕ} (d₁ d₂ : DynNetwork n T) :
    totalEdgeDistortion d₁ d₂ = 0 ↔ d₁ = d₂ := by
  constructor <;> intro h <;> simp_all +decide [ totalEdgeDistortion, edgeDistortion ];
  cases d₁ ; cases d₂ ; aesop

/-- Dynamic Privacy-Surveillance Exclusion: a function on dynamic networks
    cannot be both injective and constant on ≥ 2 distinct inputs. -/
theorem dyn_privacy_surveillance_exclusion {n T : ℕ}
    {C : Type*} [DecidableEq C]
    (f : DynNetwork n T → C)
    (d₁ d₂ : DynNetwork n T) (hne : d₁ ≠ d₂) :
    ¬(Function.Injective f ∧ ∀ x y, f x = f y) := by
  intro ⟨hinj, hconst⟩
  exact hne (hinj (hconst d₁ d₂))

/-! ## Section 9: Theorem 5 — Fiber Product Bound -/

/-
**Theorem 5: Fiber Product Bound (Pigeonhole).**
    The total number of configs ≤ imageSize × maxFiberSize.
    This quantifies the privacy-utility tradeoff: more channel symbols (less privacy)
    means smaller fibers (better reconstruction).
-/
theorem fiber_product_bound {n : ℕ} {C : Type*} [Fintype C] [DecidableEq C]
    (ch : SurveillanceChannel n C) :
    Fintype.card (NetworkConfig n) ≤
      channelImageSize ch *
      Finset.sup' (Finset.univ.image ch.encode)
        (Finset.Nonempty.image Finset.univ_nonempty _)
        (fun c => (Finset.univ.filter (fun g : NetworkConfig n => ch.encode g = c)).card) := by
  have h_pigeonhole : (Finset.univ : Finset (NetworkConfig n)).card ≤ ∑ c ∈ Finset.image ch.encode Finset.univ, Finset.card (Finset.filter (fun g => ch.encode g = c) Finset.univ) := by
    rw [ ← Finset.card_eq_sum_card_fiberwise ];
    exact fun x _ => Finset.mem_image_of_mem _ ( Finset.mem_univ x );
  refine' le_trans h_pigeonhole _;
  exact Finset.sum_le_card_nsmul _ _ _ fun x hx => Finset.le_sup' ( fun c => Finset.card ( Finset.filter ( fun g => ch.encode g = c ) Finset.univ ) ) hx

/-! ## Section 10: Injective Channel Characterization -/

/-
An injective channel's image size equals the configuration count.
-/
theorem injectiveChannel_imageSize_eq {n : ℕ} {C : Type*} [Fintype C] [DecidableEq C]
    (ch : SurveillanceChannel n C) (hinj : isInjectiveChannel ch) :
    channelImageSize ch = Fintype.card (NetworkConfig n) := by
  convert Finset.card_image_of_injective _ hinj

/-! ## Section 11: Privacy Defect -/

/-- The **privacy defect**: normalized information leakage.
    0 = maximal privacy, approaches 1 = no privacy (injective). -/
noncomputable def privacyDefect {n : ℕ} {C : Type*} [Fintype C] [DecidableEq C]
    (ch : SurveillanceChannel n C) : ℚ :=
  if Fintype.card (NetworkConfig n) ≤ 1 then 0
  else ((channelImageSize ch : ℚ) - 1) / ((Fintype.card (NetworkConfig n) : ℚ) - 1)

theorem privacyDefect_trivial {n : ℕ} {C : Type*} [Fintype C] [DecidableEq C]
    (ch : SurveillanceChannel n C) (htriv : isTrivialChannel ch) :
    privacyDefect ch = 0 := by
  unfold privacyDefect;
  split_ifs <;> simp_all +decide [ sub_eq_iff_eq_add ];
  exact Or.inl ( le_antisymm ( trivialChannel_imageSize_le_one ch htriv ) ( Finset.card_pos.mpr ⟨ _, Finset.mem_image_of_mem _ ( Finset.mem_univ ⟨ fun _ _ => Bool.true ⟩ ) ⟩ ) )

/-! ## Conjecture: Exponential Privacy Cost

For networks on n ≥ 2 nodes, achieving distortion 0 requires
`Fintype.card (NetworkConfig n)` channel symbols (full injectivity).

**Testable prediction**: For n = 1, the identity channel on Bool
has 2^1 = 2 configurations. For n = 2, it has 2^4 = 16 configurations.
At D = 0, the minimum channel size must equal the config count,
because zero distortion forces injectivity, combined with
`injectiveChannel_imageSize_eq`.
-/