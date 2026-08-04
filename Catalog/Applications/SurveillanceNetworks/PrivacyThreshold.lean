/-
# A sharp privacy threshold for surveillance of binary network histories

An observer watches a finite system whose configurations form a finite type `S`
(for a dynamic directed network on `n` participants observed for `T` time steps,
`S = (Fin T × Fin n × Fin n) → Bool`, a binary history tensor).  The observer
emits a *record* through a channel and a decoder later reconstructs a
configuration; the reconstruction error is measured by a dissimilarity
`d : S → S → ℕ` (Hamming distance on histories).

*Perfect privacy* means the record law does not depend on the configuration.
This file proves that perfect privacy has an exact geometric price:

* `privatelyAchievable_iff_exists_center` — a perfectly private **deterministic**
  channel meets the worst-case distortion budget `D` if and only if a single
  ball of radius `D` covers the whole configuration space.
* `randPrivatelyAchievable_iff_exists_center` — the same threshold holds for
  **randomized** channels (`S → PMF M`) whose output law is independent of the
  configuration, under an almost-sure worst-case distortion requirement:
  randomization does not help.
* `isLeast_privately_achievable` — consequently the optimal private worst-case
  distortion equals the covering radius of the one-codeword code,
  `coveringRadius d = ⨅_c ⨆_s d c s`.
* `hamming_coveringRadius` — for Hamming distortion on binary tensors indexed by
  a finite set `α` the covering radius is exactly `|α|`, so a perfectly private
  observer of a `T`-step network history on `n` nodes suffers worst-case
  distortion exactly `T * n * n` (`history_private_distortion`): privacy forces a
  totally uninformative reconstruction.

The complementary quantitative side is an exact-volume converse.  The fibres of a
channel are covered by distortion balls, giving `|S| ≤ rate · B`
(`card_le_rate_mul_ball`), and even a decoder allowed to fail outside a good set
`G` obeys `|G| ≤ rate · B` (`card_good_le_rate_mul_ball`).  For Hamming
distortion the ball volume is computed exactly,
`hamming_ball_card : |B(c, D)| = ∑_{i ≤ D} C(|α|, i)`, yielding the concrete
surveillance bound `hamming_rate_bound`:
`2 ^ |α| ≤ rate · ∑_{i ≤ D} C(|α|, i)`,
and its excess-distortion version `hamming_rate_bound_excess`.
-/
import Mathlib

open Finset

namespace SurveillanceNetworks.Privacy

variable {S M : Type*}

/-! ## Privacy and distortion for deterministic channels -/

/-- A deterministic channel is perfectly private when the record it emits does not
depend on the configuration. -/
def PerfectPrivacy (obs : S → M) : Prop := ∀ s t, obs s = obs t

/-- The distortion budget `D` is *privately achievable* over the record alphabet
`M` if some perfectly private channel and decoder reconstruct every configuration
to within `D`. -/
def PrivatelyAchievable (M : Type*) (d : S → S → ℕ) (D : ℕ) : Prop :=
  ∃ (obs : S → M) (dec : M → S), PerfectPrivacy obs ∧ ∀ s, d (dec (obs s)) s ≤ D

/-- **Sharp privacy threshold, deterministic case.**  A perfectly private
deterministic channel achieves worst-case distortion `D` if and only if a single
ball of radius `D` covers the entire configuration space. -/
theorem privatelyAchievable_iff_exists_center [Nonempty S] [Nonempty M]
    (d : S → S → ℕ) (D : ℕ) :
    PrivatelyAchievable M d D ↔ ∃ c : S, ∀ s, d c s ≤ D := by
  constructor
  · rintro ⟨obs, dec, hprivacy, hd⟩
    obtain ⟨s₀⟩ : Nonempty S := inferInstance
    exact ⟨dec (obs s₀), fun s => by simpa [hprivacy s s₀] using hd s⟩
  · rintro ⟨c, hc⟩
    obtain ⟨m₀⟩ : Nonempty M := inferInstance
    exact ⟨fun _ => m₀, fun _ => c, fun _ _ => rfl, fun s => hc s⟩

/-! ## Privacy and distortion for randomized channels -/

/-- A randomized channel `ch : S → PMF M` is perfectly private when the law of the
record is the same for every configuration. -/
def RandPerfectPrivacy (ch : S → PMF M) : Prop := ∀ s t, ch s = ch t

/-- The budget `D` is *privately achievable by a randomized channel* if some
perfectly private randomized channel and decoder reconstruct every configuration
to within `D` almost surely (i.e. for every record in the support). -/
def RandPrivatelyAchievable (M : Type*) (d : S → S → ℕ) (D : ℕ) : Prop :=
  ∃ (ch : S → PMF M) (dec : M → S),
    RandPerfectPrivacy ch ∧ ∀ s, ∀ m ∈ (ch s).support, d (dec m) s ≤ D

/-- **Randomization does not help.**  Under an almost-sure worst-case distortion
requirement, a perfectly private randomized channel achieves distortion `D` if and
only if a single ball of radius `D` covers the whole configuration space — exactly
the deterministic threshold. -/
theorem randPrivatelyAchievable_iff_exists_center [Nonempty S] [Nonempty M]
    (d : S → S → ℕ) (D : ℕ) :
    RandPrivatelyAchievable M d D ↔ ∃ c : S, ∀ s, d c s ≤ D := by
  constructor
  · rintro ⟨ch, dec, hprivacy, hd⟩
    obtain ⟨s₀⟩ : Nonempty S := inferInstance
    obtain ⟨m₀, hm₀⟩ := (ch s₀).support_nonempty
    exact ⟨dec m₀, fun s => hd s m₀ ((hprivacy s s₀) ▸ hm₀)⟩
  · rintro ⟨c, hc⟩
    obtain ⟨m₀⟩ : Nonempty M := inferInstance
    exact ⟨fun _ => PMF.pure m₀, fun _ => c, fun _ _ => rfl, fun s _ _ => hc s⟩

/-- The two privacy notions have the same achievable distortion budgets. -/
theorem randPrivatelyAchievable_iff_privatelyAchievable [Nonempty S] [Nonempty M]
    (d : S → S → ℕ) (D : ℕ) :
    RandPrivatelyAchievable M d D ↔ PrivatelyAchievable M d D :=
  (randPrivatelyAchievable_iff_exists_center d D).trans
    (privatelyAchievable_iff_exists_center d D).symm

/-! ## The optimal private distortion is the covering radius -/

/-- The covering radius of the one-codeword code: the smallest radius `r` such
that some single ball of radius `r` covers the configuration space. -/
noncomputable def coveringRadius (d : S → S → ℕ) : ℕ := sInf {r | ∃ c : S, ∀ s, d c s ≤ r}

/-- Some ball of radius `coveringRadius d` really does cover the space. -/
theorem exists_center_coveringRadius [Fintype S] [Nonempty S] (d : S → S → ℕ) :
    ∃ c : S, ∀ s, d c s ≤ coveringRadius d := by
  have hne : {r : ℕ | ∃ c : S, ∀ s, d c s ≤ r}.Nonempty := by
    refine ⟨∑ s : S, d (Classical.arbitrary S) s, Classical.arbitrary S, fun s => ?_⟩
    exact Finset.single_le_sum (fun s _ => Nat.zero_le (d (Classical.arbitrary S) s))
      (Finset.mem_univ s)
  exact Nat.sInf_mem hne

/-- A ball of radius `D` covers the space iff the covering radius is at most `D`. -/
theorem coveringRadius_le_iff [Fintype S] [Nonempty S] (d : S → S → ℕ) (D : ℕ) :
    coveringRadius d ≤ D ↔ ∃ c : S, ∀ s, d c s ≤ D := by
  constructor
  · intro h
    obtain ⟨c, hc⟩ := exists_center_coveringRadius d
    exact ⟨c, fun s => (hc s).trans h⟩
  · rintro ⟨c, hc⟩
    exact Nat.sInf_le ⟨c, hc⟩

/-- **The optimal private worst-case distortion equals the covering radius.** -/
theorem isLeast_privately_achievable [Fintype S] [Nonempty S] [Nonempty M]
    (d : S → S → ℕ) :
    IsLeast {D | PrivatelyAchievable M d D} (coveringRadius d) := by
  have set_eq : {D | PrivatelyAchievable M d D} = {D | ∃ c : S, ∀ s, d c s ≤ D} := by
    ext D
    exact privatelyAchievable_iff_exists_center d D
  rw [set_eq]
  exact ⟨exists_center_coveringRadius d, fun D hD => (coveringRadius_le_iff d D).mpr hD⟩

/-! ## Hamming distortion on binary tensors -/

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- Hamming distance between two binary tensors indexed by `α`. -/
def hdist (x y : α → Bool) : ℕ := (univ.filter fun i => x i ≠ y i).card

omit [DecidableEq α] in
lemma hdist_comm (x y : α → Bool) : hdist x y = hdist y x := by
  unfold hdist; congr 1; apply filter_congr; intro i _; exact ⟨Ne.symm, Ne.symm⟩

omit [DecidableEq α] in
lemma hdist_self (x : α → Bool) : hdist x x = 0 := by simp [hdist]

omit [DecidableEq α] in
lemma hdist_le_card (x y : α → Bool) : hdist x y ≤ Fintype.card α :=
  le_trans (card_filter_le _ _) (le_of_eq (Finset.card_univ))

omit [DecidableEq α] in
/-- The complement of a tensor is at maximal Hamming distance from it. -/
lemma hdist_not (x : α → Bool) : hdist x (fun i => !x i) = Fintype.card α := by
  unfold hdist
  rw [Finset.filter_true_of_mem]
  · rfl
  · intro i _
    by_cases h : x i <;> simp [h]

/-- **The covering radius for Hamming distortion is maximal.**  No single ball of
radius smaller than `|α|` covers the space of binary tensors. -/
theorem hamming_coveringRadius :
    coveringRadius (hdist : (α → Bool) → (α → Bool) → ℕ) = Fintype.card α := by
  apply le_antisymm
  · exact (coveringRadius_le_iff hdist _).mpr ⟨fun _ => true, fun s => hdist_le_card _ _⟩
  · refine le_csInf ⟨Fintype.card α, fun _ => true, fun s => hdist_le_card _ _⟩ ?_
    rintro r ⟨c, hc⟩
    exact hdist_not c ▸ hc (fun i => !c i)

/-- **Perfect privacy destroys all utility.**  A perfectly private observer of
binary tensors can only guarantee worst-case Hamming distortion `D` when
`D ≥ |α|`, i.e. when the guarantee is vacuous. -/
theorem hamming_privatelyAchievable_iff [Nonempty M]
    (D : ℕ) :
    PrivatelyAchievable M (hdist : (α → Bool) → (α → Bool) → ℕ) D ↔ Fintype.card α ≤ D := by
  rw [privatelyAchievable_iff_exists_center, ← coveringRadius_le_iff, hamming_coveringRadius]

/-- **Network histories.**  A history of a directed network on `n` participants
observed at `T` times is a binary tensor indexed by `Fin T × Fin n × Fin n`; a
perfectly private observer of such histories suffers worst-case Hamming
distortion exactly `T * n * n`, the total number of recorded bits. -/
theorem history_private_distortion (T n : ℕ) :
    coveringRadius (hdist : ((Fin T × Fin n × Fin n) → Bool) →
      ((Fin T × Fin n × Fin n) → Bool) → ℕ) = T * n * n := by
  rw [hamming_coveringRadius]
  simp [Fintype.card_prod]
  ring

/-! ## Exact covering converse -/

variable [Fintype S] [DecidableEq S] [DecidableEq M]

/-- The **rate** of a channel: the number of distinct records it emits. -/
def rate (obs : S → M) : ℕ := (univ.image obs).card

/-- **Covering converse.**  If a decoder reconstructs every configuration within
distortion `D`, and every ball of radius `D` has at most `B` elements, then the
channel must emit at least `|S| / B` records. -/
theorem card_le_rate_mul_ball (obs : S → M) (dec : M → S) (d : S → S → ℕ) (D B : ℕ)
    (hball : ∀ c : S, (univ.filter fun s => d c s ≤ D).card ≤ B)
    (hrec : ∀ s, d (dec (obs s)) s ≤ D) :
    Fintype.card S ≤ rate obs * B := by
  have hcard : Fintype.card S = (univ : Finset S).card := rfl
  rw [hcard]
  have huniv : (univ : Finset S) = (univ.image obs).biUnion (fun m => univ.filter fun s => obs s = m) := by
    ext s; simp
  rw [huniv]
  have hdisj : ∀ m₁ m₂, m₁ ≠ m₂ → Disjoint (univ.filter fun s => obs s = m₁) (univ.filter fun s => obs s = m₂) := by
    intro m₁ m₂ hne
    apply Finset.disjoint_left.mpr
    intro s hs₁ hs₂
    simp at hs₁ hs₂
    exact hne (hs₁.symm.trans hs₂)
  rw [card_biUnion (fun m₁ _ m₂ _ hne => hdisj m₁ m₂ hne)]
  have hterm : ∀ u ∈ univ.image obs, (univ.filter fun s => obs s = u).card ≤ B := by
    intro u hu
    have : (univ.filter fun s => obs s = u) ⊆ univ.filter fun s => d (dec u) s ≤ D := by
      intro s hs
      simp at hs
      have := hrec s
      rw [hs] at this
      simp [this]
    exact Nat.le_trans (Finset.card_mono this) (hball (dec u))
  calc ∑ u ∈ univ.image obs, (univ.filter fun s => obs s = u).card
      ≤ ∑ _u ∈ univ.image obs, B := Finset.sum_le_sum hterm
    _ = (univ.image obs).card * B := by simp [Finset.sum_const]
    _ = rate obs * B := rfl

/-- **Excess-distortion converse.**  Only the configurations in a "good" set `G`
need be reconstructed within `D`; the rate is then bounded below by `|G| / B`. -/
theorem card_good_le_rate_mul_ball (obs : S → M) (dec : M → S) (d : S → S → ℕ) (D B : ℕ)
    (G : Finset S)
    (hball : ∀ c : S, (univ.filter fun s => d c s ≤ D).card ≤ B)
    (hrec : ∀ s ∈ G, d (dec (obs s)) s ≤ D) :
    G.card ≤ rate obs * B := by
  have huniv : G = (G.image obs).biUnion (fun m => G.filter fun s => obs s = m) := by
    ext s; simp [Finset.mem_biUnion]; tauto
  rw [huniv]
  have hdisj : ∀ m₁ m₂, m₁ ≠ m₂ →
      Disjoint (G.filter fun s => obs s = m₁) (G.filter fun s => obs s = m₂) := by
    intro m₁ m₂ hne
    refine Finset.disjoint_left.mpr fun s hs₁ hs₂ => ?_
    simp at hs₁ hs₂
    exact hne (hs₁.2.symm.trans hs₂.2)
  rw [card_biUnion (fun m₁ _ m₂ _ hne => hdisj m₁ m₂ hne)]
  have hterm : ∀ u ∈ G.image obs, (G.filter fun s => obs s = u).card ≤ B := by
    intro u _
    have hsub : (G.filter fun s => obs s = u) ⊆ univ.filter fun s => d (dec u) s ≤ D := by
      intro s hs
      simp at hs
      have := hrec s hs.1
      rw [hs.2] at this
      simp [this]
    exact Nat.le_trans (Finset.card_mono hsub) (hball (dec u))
  calc ∑ u ∈ G.image obs, (G.filter fun s => obs s = u).card
      ≤ ∑ _u ∈ G.image obs, B := Finset.sum_le_sum hterm
    _ = (G.image obs).card * B := by simp [Finset.sum_const]
    _ ≤ (univ.image obs).card * B :=
        Nat.mul_le_mul_right _ (Finset.card_le_card (Finset.image_subset_image (subset_univ G)))
    _ = rate obs * B := rfl

/-- **Exact Hamming ball volume.**  The ball of radius `D` around any binary
tensor has exactly `∑_{i ≤ D} C(|α|, i)` elements. -/
theorem hamming_ball_card (c : α → Bool) (D : ℕ) :
    (univ.filter fun s => hdist c s ≤ D).card
      = ∑ i ∈ range (D + 1), (Fintype.card α).choose i := by
  -- Define the Hamming ball and the sum
  set ball := univ.filter fun s => hdist c s ≤ D with hball
  set target := ∑ i ∈ range (D + 1), (Fintype.card α).choose i with htarget
  -- Define the map: s ↦ {i | c i ≠ s i}
  let f : (α → Bool) → Finset α := fun s => univ.filter fun i => c i ≠ s i
  -- f s has size = hdist c s
  have hf_size : ∀ s, (f s).card = hdist c s := fun s => rfl
  -- f is injective: if f s₁ = f s₂, then s₁ = s₂
  have hf_inj : ∀ s₁ s₂, f s₁ = f s₂ → s₁ = s₂ := by
    intro s₁ s₂ hf_eq
    funext i
    have hmem : i ∈ f s₁ ↔ i ∈ f s₂ := by rw [hf_eq]
    simp [f] at hmem
    cases hi : c i <;> cases hj : s₁ i <;> cases hk : s₂ i <;> simp_all
  -- The image of ball under f is {I : Finset α | I.card ≤ D}
  let subsets_le_D := Finset.biUnion (Finset.range (D + 1)) (fun i => Finset.powersetCard i (univ : Finset α))
  -- Show that f maps ball onto subsets_le_D
  have hf_image : ∀ I ∈ subsets_le_D, ∃ s, s ∈ ball ∧ f s = I := by
    intro I hI
    rw [Finset.mem_biUnion] at hI
    obtain ⟨k, hI_k, hI_mem⟩ := hI
    rw [Finset.mem_range] at hI_k
    rw [Finset.mem_powersetCard] at hI_mem
    -- Construct s that differs from c exactly at positions in I
    let s : α → Bool := fun a => if a ∈ I then !c a else c a
    use s
    constructor
    · -- Show s ∈ ball
      simp only [ball, hdist, Finset.mem_filter, Finset.mem_univ, true_and]
      have hcard : (univ.filter fun i => c i ≠ s i).card = #I := by
        congr 1
        ext i
        simp [s]
      rw [hcard, hI_mem.2]
      exact Nat.lt_succ_iff.mp hI_k
    · -- Show f s = I
      ext i
      simp [f, s]
  -- f maps ball into subsets_le_D
  have hf_maps : ∀ s ∈ ball, f s ∈ subsets_le_D := by
    intro s hs
    rw [Finset.mem_biUnion]
    refine ⟨(f s).card, ?_, ?_⟩
    · simp only [Finset.mem_range]
      rw [hf_size]
      exact Nat.lt_succ_of_le (by simpa [ball] using hs)
    · rw [Finset.mem_powersetCard]
      exact ⟨Finset.subset_univ _, rfl⟩
  -- Use Finset.card_bij to show card ball = card subsets_le_D
  have hbij : ball.card = subsets_le_D.card := by
    apply Finset.card_bij (fun s _ => f s)
    · intro s hs
      exact hf_maps s hs
    · intro s₁ hs₁ s₂ hs₂ heq
      exact hf_inj s₁ s₂ heq
    · intro I hI
      obtain ⟨s, hs, hf_eq⟩ := hf_image I hI
      exact ⟨s, hs, hf_eq⟩
  -- Compute card subsets_le_D
  have hcard_subsets : subsets_le_D.card = ∑ i ∈ Finset.range (D + 1), Nat.choose (Fintype.card α) i := by
    show (Finset.biUnion (Finset.range (D + 1)) (fun i => Finset.powersetCard i (univ : Finset α))).card = ∑ i ∈ Finset.range (D + 1), Nat.choose (Fintype.card α) i
    rw [Finset.card_biUnion]
    · apply Finset.sum_congr rfl
      intro i hi
      rw [Finset.card_powersetCard, Finset.card_univ]
    · intro i hi j hj hij
      simp only [Finset.disjoint_left, Finset.mem_powersetCard]
      intro I ⟨hI_sub, hI_card⟩ ⟨hI_sub', hI_card'⟩
      exact hij (hI_card.symm.trans hI_card')
  rw [hbij, hcard_subsets, htarget]

/-- **Surveillance rate bound with exact volume.**  An observer reconstructing
every binary tensor within Hamming distortion `D` must emit at least
`2 ^ |α| / ∑_{i ≤ D} C(|α|, i)` distinct records. -/
theorem hamming_rate_bound [Fintype M] (obs : (α → Bool) → M) (dec : M → (α → Bool))
    (D : ℕ) (hrec : ∀ s, hdist (dec (obs s)) s ≤ D) :
    2 ^ Fintype.card α ≤ rate obs * ∑ i ∈ range (D + 1), (Fintype.card α).choose i := by
  have hcard : Fintype.card (α → Bool) = 2 ^ Fintype.card α := Fintype.card_fun
  rw [← hcard]
  refine card_le_rate_mul_ball obs dec hdist D
    (∑ i ∈ range (D + 1), (Fintype.card α).choose i) (fun c => ?_) hrec
  rw [hamming_ball_card]

/-- **Excess-distortion surveillance bound.**  If the observer reconstructs all
tensors in a good set `G` within Hamming distortion `D`, then
`|G| ≤ rate · ∑_{i ≤ D} C(|α|, i)`. -/
theorem hamming_rate_bound_excess [Fintype M] (obs : (α → Bool) → M) (dec : M → (α → Bool))
    (D : ℕ) (G : Finset (α → Bool)) (hrec : ∀ s ∈ G, hdist (dec (obs s)) s ≤ D) :
    G.card ≤ rate obs * ∑ i ∈ range (D + 1), (Fintype.card α).choose i := by
  refine card_good_le_rate_mul_ball obs dec hdist D
    (∑ i ∈ range (D + 1), (Fintype.card α).choose i) G (fun c => ?_) hrec
  rw [hamming_ball_card]

end SurveillanceNetworks.Privacy