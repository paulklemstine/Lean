import Cryptography.NonabelianTypeChannel.Entropy

/-!
# The type channel of a Galois group is its abelianization content

Let `G` be the Galois group of a number field, realised as a finite set `S` of
permutations of the roots, and let `T : G → τ` be the *splitting type* readout
(the cycle type of Frobenius, i.e. the factorisation shape of `p` in the field).
By Chebotarev, Frobenius is equidistributed in `G`, so the statistics of the pair
(residue class of `p`, splitting type of `p`) are the statistics of the pair
(coset of a uniform `g ∈ G` modulo the derived subgroup, `T g`): the residue class
of `p` modulo the conductor of the abelian characters of `G` is *exactly* the coset
of Frobenius in `G^ab = G / [G, G]`.

This file formalises that reduction and its consequences.

## Main definitions

* `TypeChannel.IsSubgroupFinset S` — `S : Finset G` is a subgroup.
* `TypeChannel.IsDerivedFinset S N` — certificate that `N` is the derived subgroup
  `[S, S]`: every commutator of `S` lies in `N`, and every element of `N` is a
  commutator of elements of `S`.
* `TypeChannel.IsCosetReadout S N c` — `c` is a readout of `S` whose level sets are
  exactly the cosets of `N`; this is the abstract form of "the residue class of `p`".
* `TypeChannel.cosetObs N g` — the tautological coset readout `g ↦ N g`.

## Main results

* `TypeChannel.card_fiber_cosetReadout`, `TypeChannel.card_image_mul_card`
  — Lagrange: the coset readout is balanced with fibres of size `|N|`.
* `TypeChannel.entropy_cosetReadout` — `H(coset) = log₂ [S : N]`.
* `TypeChannel.typeChannel_le_logb_index` — **the abelianization cap**: whatever the
  splitting type readout `T` is, and however many types it has,
  `I(coset ; T) ≤ log₂ [S : N]`.  For `S₄` (with `[S₄ : A₄] = 2`) this caps a
  five-type channel at exactly one bit.
* `TypeChannel.typeChannel_eq_logb_index_of_determines` — if the type determines the
  coset, the channel is complete: `I = log₂ [S : N]`.
* `TypeChannel.typeChannel_eq_zero_of_perfect` — a perfect group leaks nothing.
* `TypeChannel.residue_channel_eq_coset_channel` — **the law**: any residue readout
  that separates the cosets of the derived subgroup has *exactly* the coset channel.
* `TypeChannel.typeChannel_decomposition` — `I = H(T) - H(T | coset)`, and
  `TypeChannel.loss_eq` — `log₂[S:N] - I = H(coset | T)`, the "loss" column.
-/

namespace TypeChannel

open Finset Real

variable {G : Type*} [Group G] [DecidableEq G] {κ τ : Type*} [DecidableEq κ] [DecidableEq τ]

/-- A `Finset` of a group which is a subgroup. -/
structure IsSubgroupFinset (S : Finset G) : Prop where
  one_mem : (1 : G) ∈ S
  mul_mem : ∀ a ∈ S, ∀ b ∈ S, a * b ∈ S
  inv_mem : ∀ a ∈ S, a⁻¹ ∈ S

/-- Certificate that `N` is the derived subgroup of `S`: it contains every commutator
of `S`, and each of its elements is itself a commutator of elements of `S`. -/
structure IsDerivedFinset (S N : Finset G) : Prop where
  subset : N ⊆ S
  commutator_mem : ∀ a ∈ S, ∀ b ∈ S, a * b * a⁻¹ * b⁻¹ ∈ N
  mem_commutator : ∀ n ∈ N, ∃ a ∈ S, ∃ b ∈ S, n = a * b * a⁻¹ * b⁻¹

/-- A readout of `S` whose level sets are exactly the cosets of `N`.  This is the
abstract form of the residue class `p mod m*`: by class field theory the residue
class of an unramified prime determines, and is determined by, the coset of its
Frobenius modulo the derived subgroup. -/
def IsCosetReadout (S N : Finset G) (c : G → κ) : Prop :=
  ∀ a ∈ S, ∀ b ∈ S, (c a = c b ↔ a * b⁻¹ ∈ N)

/-- The tautological coset readout `g ↦ N g`. -/
def cosetObs (N : Finset G) (g : G) : Finset G := N.image (fun n => n * g)

section Lagrange

variable {S N : Finset G} {c : G → κ}

/-- The tautological readout `g ↦ N g` really is a coset readout. -/
lemma cosetObs_isCosetReadout (hN : IsSubgroupFinset N) :
    IsCosetReadout S N (cosetObs N) := by
  intro a _ b _
  constructor
  · intro h
    have ha : a ∈ cosetObs N a := by
      refine mem_image.mpr ⟨1, hN.one_mem, by simp⟩
    rw [h] at ha
    obtain ⟨n, hn, hnb⟩ := mem_image.mp ha
    have : a * b⁻¹ = n := by rw [← hnb]; group
    rw [this]; exact hn
  · intro h
    unfold cosetObs
    ext x
    simp only [mem_image]
    constructor
    · rintro ⟨n, hn, rfl⟩
      exact ⟨n * (a * b⁻¹), hN.mul_mem _ hn _ h, by group⟩
    · rintro ⟨n, hn, rfl⟩
      refine ⟨n * (a * b⁻¹)⁻¹, hN.mul_mem _ hn _ (hN.inv_mem _ h), by group⟩

/-- Each fibre of a coset readout is a coset of `N`, hence has exactly `|N|` elements. -/
lemma card_fiber_cosetReadout (hS : IsSubgroupFinset S)
    (hNS : N ⊆ S) (hc : IsCosetReadout S N c) {a : G} (ha : a ∈ S) :
    (fiber S c (c a)).card = N.card := by
  have hset : fiber S c (c a) = N.image (fun n => n * a) := by
    ext g
    simp only [fiber, mem_filter, mem_image]
    constructor
    · rintro ⟨hgS, hcg⟩
      exact ⟨g * a⁻¹, (hc g hgS a ha).mp hcg, by group⟩
    · rintro ⟨n, hn, rfl⟩
      have hmem : n * a ∈ S := hS.mul_mem _ (hNS hn) _ ha
      refine ⟨hmem, (hc (n * a) hmem a ha).mpr ?_⟩
      have : n * a * a⁻¹ = n := by group
      rw [this]; exact hn
  rw [hset, Finset.card_image_of_injective _ (mul_left_injective a)]

/-- Lagrange's theorem in the form used by the channel: the number of cosets times
`|N|` is `|S|`. -/
lemma card_image_mul_card (hS : IsSubgroupFinset S)
    (hNS : N ⊆ S) (hc : IsCosetReadout S N c) :
    (S.image c).card * N.card = S.card := by
  have h0 := Finset.card_eq_sum_card_image c S
  have h1 : ∀ b ∈ S.image c, (S.filter (fun a => c a = b)).card = N.card := by
    intro b hb
    obtain ⟨a, ha, rfl⟩ := mem_image.mp hb
    exact card_fiber_cosetReadout hS hNS hc ha
  rw [h0, Finset.sum_congr rfl h1, Finset.sum_const, smul_eq_mul]

/-- The coset readout carries exactly `log₂ [S : N]` bits. -/
lemma entropy_cosetReadout (hS : IsSubgroupFinset S) (hN : IsSubgroupFinset N)
    (hNS : N ⊆ S) (hc : IsCosetReadout S N c) :
    entropy S c = logb 2 (S.image c).card := by
  refine entropy_eq_logb_card_of_uniform_fibers (k := N.card) ⟨1, hS.one_mem⟩
    (card_pos.mpr ⟨1, hN.one_mem⟩) ?_
  intro a ha
  obtain ⟨g, hg, rfl⟩ := mem_image.mp ha
  exact card_fiber_cosetReadout hS hNS hc hg

end Lagrange

section Channel

variable {S N : Finset G} {c : G → κ} {T : G → τ}

/-- **The abelianization cap.**  The splitting-type channel of a finite Galois group
never carries more than `log₂ [G : G']` bits, no matter how many splitting types the
field has.  (For `S₄` this is one bit against five types and `H(T) > 2` bits.) -/
theorem typeChannel_le_logb_index (hS : IsSubgroupFinset S) (hN : IsSubgroupFinset N)
    (hNS : N ⊆ S) (hc : IsCosetReadout S N c) (T : G → τ) :
    mutualInfo S c T ≤ logb 2 (S.image c).card := by
  rw [← entropy_cosetReadout hS hN hNS hc]
  exact mutualInfo_le_left S c T

omit [Group G] [DecidableEq G] in
/-- The channel is also capped by the entropy of the splitting type itself. -/
theorem typeChannel_le_entropy_type (S : Finset G) (c : G → κ) (T : G → τ) :
    mutualInfo S c T ≤ entropy S T :=
  mutualInfo_le_right S c T

omit [DecidableEq G] in
/-- The channel is nonnegative (Gibbs). -/
theorem typeChannel_nonneg (hS : IsSubgroupFinset S) (c : G → κ) (T : G → τ) :
    0 ≤ mutualInfo S c T :=
  mutualInfo_nonneg ⟨1, hS.one_mem⟩ c T

/-- **Completeness.**  If the splitting type determines the abelianization coset, the
channel carries the full `log₂ [S : N]` bits. -/
theorem typeChannel_eq_logb_index_of_determines (hS : IsSubgroupFinset S)
    (hN : IsSubgroupFinset N) (hNS : N ⊆ S) (hc : IsCosetReadout S N c)
    {φ : τ → κ} (h : ∀ g ∈ S, c g = φ (T g)) :
    mutualInfo S c T = logb 2 (S.image c).card := by
  rw [mutualInfo_eq_left_of_factors h]
  exact entropy_cosetReadout hS hN hNS hc

omit [DecidableEq G] in
/-- **Perfect groups leak nothing.**  If the derived subgroup is everything, the
splitting-type channel is identically zero: there is no residue information at all. -/
theorem typeChannel_eq_zero_of_perfect (hS : IsSubgroupFinset S)
    (hc : IsCosetReadout S S c) (T : G → τ) :
    mutualInfo S c T = 0 := by
  refine mutualInfo_eq_zero_of_const (a := c 1) ?_
  intro w hw
  exact (hc w hw 1 hS.one_mem).mpr (by simpa using hw)

omit [Group G] [DecidableEq G] in
/-- **The law: the type channel is the abelianization content.**  Any residue readout
`R` that is a function of the abelianization coset and separates distinct cosets has
*exactly* the coset channel: `I(R ; T) = I(coset ; T)`. -/
theorem residue_channel_eq_coset_channel {ρ : Type*} [DecidableEq ρ]
    (S : Finset G) (c : G → κ) (T : G → τ) {R : G → ρ} {ψ : κ → ρ}
    (hR : ∀ g ∈ S, R g = ψ (c g)) (hψ : Set.InjOn ψ (S.image c : Finset κ)) :
    mutualInfo S R T = mutualInfo S c T := by
  rw [show mutualInfo S R T = mutualInfo S (fun g => ψ (c g)) T from by
    unfold mutualInfo
    rw [entropy_congr hR, entropy_congr (f := pairObs R T) (f' := pairObs (fun g => ψ (c g)) T)
      (fun w hw => by unfold pairObs; rw [hR w hw])]]
  exact mutualInfo_comp_left hψ

omit [Group G] [DecidableEq G] in
/-- The channel decomposition `I = H(T) - H(T | coset)`. -/
theorem typeChannel_decomposition (S : Finset G) (c : G → κ) (T : G → τ) :
    mutualInfo S c T = entropy S T - condEntropy S T c :=
  mutualInfo_eq_sub_condEntropy S c T

/-- The *loss* column of the law table: `log₂[S:N] - I = H(coset | T)`. -/
theorem loss_eq (hS : IsSubgroupFinset S) (hN : IsSubgroupFinset N)
    (hNS : N ⊆ S) (hc : IsCosetReadout S N c) (T : G → τ) :
    logb 2 (S.image c).card - mutualInfo S c T = condEntropy S c T := by
  rw [← entropy_cosetReadout hS hN hNS hc, mutualInfo_comm,
    mutualInfo_eq_sub_condEntropy]
  ring

/-- The loss is nonnegative, i.e. the cap of `typeChannel_le_logb_index` is the
abelianization entropy. -/
theorem loss_nonneg (hS : IsSubgroupFinset S) (hN : IsSubgroupFinset N)
    (hNS : N ⊆ S) (hc : IsCosetReadout S N c) (T : G → τ) :
    0 ≤ logb 2 (S.image c).card - mutualInfo S c T := by
  rw [loss_eq hS hN hNS hc T]
  exact condEntropy_nonneg S c T

end Channel

end TypeChannel