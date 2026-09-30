import Cryptography.TypeChannelMilestone.InfoCalculus
import Cryptography.NonabelianTypeChannel.SplitType

/-!
# Paper 116 — the unified type-channel law, formally consolidated

Setting (as in `Cryptography.NonabelianTypeChannel.GroupChannel`): the Galois group is a
finite subgroup `S` of a group `G`, `N ⊆ S` is its derived subgroup, `c` is a coset
readout of `N` (the residue class `p mod m*`, by class field theory) and `T` is any
splitting-type readout.  We write `k = [S : N] = |S.image c|`.

## What this file proves

* `condEntropy_type_le_logb_derived` — `H(T | coset) ≤ log₂ |G'|`: once the abelianization
  coset is known, the type has at most `log₂ |G'|` bits of residual uncertainty.
* `typeChannel_sandwich` — **the two-sided sandwich**
  `max(0, H(T) − log₂|G'|) ≤ I(coset ; T) ≤ min(H(T), log₂[G : G'])`.
* `unified_type_channel_law` — **the corrected milestone law** in one statement:
  `I = H(T) − H(T | coset) = log₂[G : G'] − H(coset | T)`, with the two endpoints
  (abelian: `I = H(T)`; perfect: `I = 0`).
* `typeChannel_universal` — **universality**: two realisations of the same Galois group
  related by a (possibly different-looking) injective homomorphism carrying derived
  subgroup to derived subgroup and type to type have *identical* channels, whatever
  coset labels are used.  `typeChannel_conj_invariant` specialises this to conjugate
  permutation representations and the cycle-type readout.
* `battery_chain`, `battery_capped`, `battery_saturates` — batteries of type dials obey
  the chain rule, are monotone, never exceed `log₂[G : G']`, and gain *nothing* once one
  dial is complete.
* `battery_not_superadditive` — the critic's boundary: super-additivity
  `I(c;T₁) + I(c;T₂) ≤ I(c;(T₁,T₂))` fails for every nontrivial abelianization.
* `typeChannel_ne_loss_of_complete` — the critic's correction: the milestone's phrase
  "`I` is exactly `E[H(G^ab-class | T)]`" is false; that quantity is the *loss*
  `log₂[G:G'] − I`, and it vanishes on complete channels while `I = log₂ k > 0`.
-/

namespace TypeChannel

open Finset Real

variable {G : Type*} [Group G] [DecidableEq G] {κ τ : Type*} [DecidableEq κ] [DecidableEq τ]

section Sandwich

variable {S N : Finset G} {c : G → κ}

/-- The number of cosets times the size of the derived subgroup, in bits:
`log₂ |S| = log₂ [S : N] + log₂ |N|`. -/
lemma logb_card_eq_index_add (hS : IsSubgroupFinset S) (hN : IsSubgroupFinset N)
    (hNS : N ⊆ S) (hc : IsCosetReadout S N c) :
    logb 2 S.card = logb 2 (S.image c).card + logb 2 N.card := by
  have hmul := card_image_mul_card hS hNS hc
  have hk : ((S.image c).card : ℝ) ≠ 0 := by
    have : 0 < (S.image c).card := Finset.card_pos.mpr ⟨c 1, mem_image_of_mem c hS.one_mem⟩
    exact_mod_cast this.ne'
  have hn : (N.card : ℝ) ≠ 0 := by
    have : 0 < N.card := Finset.card_pos.mpr ⟨1, hN.one_mem⟩
    exact_mod_cast this.ne'
  rw [← Real.logb_mul hk hn]
  congr 1
  exact_mod_cast hmul.symm

/-- **Residual type uncertainty.**  Knowing the abelianization coset leaves at most
`log₂ |G'|` bits of uncertainty about the splitting type. -/
theorem condEntropy_type_le_logb_derived (hS : IsSubgroupFinset S) (hN : IsSubgroupFinset N)
    (hNS : N ⊆ S) (hc : IsCosetReadout S N c) (T : G → τ) :
    condEntropy S T c ≤ logb 2 N.card := by
  have hjoint : entropy S (pairObs c T) ≤ logb 2 S.card :=
    entropy_le_logb_card ⟨1, hS.one_mem⟩ _
  have hcoset := entropy_cosetReadout hS hN hNS hc
  have hsplit := logb_card_eq_index_add hS hN hNS hc
  unfold condEntropy
  linarith

/-- **Lower half of the sandwich.**  `H(T) − log₂ |G'| ≤ I(coset ; T)`. -/
theorem typeChannel_ge_entropy_sub_logb_derived (hS : IsSubgroupFinset S)
    (hN : IsSubgroupFinset N) (hNS : N ⊆ S) (hc : IsCosetReadout S N c) (T : G → τ) :
    entropy S T - logb 2 N.card ≤ mutualInfo S c T := by
  have h := condEntropy_type_le_logb_derived hS hN hNS hc T
  rw [mutualInfo_eq_sub_condEntropy]
  linarith

/-- **The two-sided sandwich for type channels.**
`max(0, H(T) − log₂|G'|) ≤ I(coset ; T) ≤ min(H(T), log₂[G : G'])`. -/
theorem typeChannel_sandwich (hS : IsSubgroupFinset S) (hN : IsSubgroupFinset N)
    (hNS : N ⊆ S) (hc : IsCosetReadout S N c) (T : G → τ) :
    max 0 (entropy S T - logb 2 N.card) ≤ mutualInfo S c T ∧
      mutualInfo S c T ≤ min (entropy S T) (logb 2 (S.image c).card) :=
  ⟨max_le (typeChannel_nonneg hS c T) (typeChannel_ge_entropy_sub_logb_derived hS hN hNS hc T),
    le_min (typeChannel_le_entropy_type S c T) (typeChannel_le_logb_index hS hN hNS hc T)⟩

/-- **The type deficit is bounded by the derived subgroup.**  The splitting entropy the
residue dial fails to capture, `H(T) − I(coset ; T)`, is at most `log₂ |G'|`. -/
theorem typeChannel_sandwich_width (hS : IsSubgroupFinset S) (hN : IsSubgroupFinset N)
    (hNS : N ⊆ S) (hc : IsCosetReadout S N c) (T : G → τ) :
    entropy S T - mutualInfo S c T ≤ logb 2 N.card := by
  linarith [typeChannel_ge_entropy_sub_logb_derived hS hN hNS hc T]

end Sandwich

section Law

variable {S N : Finset G} {c : G → κ}

/-- **The unified type-channel law (corrected form).**  For every finite Galois group with
derived subgroup `N`, coset readout `c` and splitting-type readout `T`:

1. `I(coset ; T) = H(T) − H(T | coset)`;
2. `I(coset ; T) = log₂[G : G'] − H(coset | T)` (the loss is the coset uncertainty
   given the type);
3. abelian endpoint: if `S` is abelian then `I = H(T)` (full pinning);
4. perfect endpoint: if `N = S` then `I = 0` (sealed). -/
theorem unified_type_channel_law (hS : IsSubgroupFinset S) (hN : IsSubgroupFinset N)
    (hd : IsDerivedFinset S N) (hc : IsCosetReadout S N c) (T : G → τ) :
    mutualInfo S c T = entropy S T - condEntropy S T c ∧
      mutualInfo S c T = logb 2 (S.image c).card - condEntropy S c T ∧
      ((∀ a ∈ S, ∀ b ∈ S, a * b = b * a) → mutualInfo S c T = entropy S T) ∧
      (N = S → mutualInfo S c T = 0) := by
  refine ⟨typeChannel_decomposition S c T, ?_, ?_, ?_⟩
  · linarith [loss_eq hS hN hd.subset hc T]
  · intro hab
    exact typeChannel_abelian_eq_entropy hS hab hd hc T
  · intro hNS
    subst hNS
    exact typeChannel_eq_zero_of_perfect hS hc T

/-- **Critic's correction.**  The milestone summary states that in the intermediate
regime the channel "is exactly `E[H(G^ab-class | T)]`".  That is the *loss*, not the
channel: on any complete channel with a nontrivial abelianization the two differ, since
the loss is `0` while `I = log₂ k > 0`. -/
theorem typeChannel_ne_loss_of_complete (hS : IsSubgroupFinset S) (hN : IsSubgroupFinset N)
    (hNS : N ⊆ S) (hc : IsCosetReadout S N c) {T : G → τ}
    (hdet : ∀ a ∈ S, ∀ b ∈ S, T a = T b → c a = c b) (hk : 2 ≤ (S.image c).card) :
    mutualInfo S c T ≠ condEntropy S c T := by
  have h1 := (typeChannel_complete_iff hS hN hNS hc).mpr hdet
  have h2 : condEntropy S c T = 0 := condEntropy_eq_zero_iff.mpr hdet
  have hpos : 0 < logb 2 ((S.image c).card : ℝ) :=
    Real.logb_pos (by norm_num) (by exact_mod_cast hk)
  rw [h1, h2]
  exact hpos.ne'

end Law

section Universality

variable {G' : Type*} [Group G'] [DecidableEq G'] {κ' : Type*} [DecidableEq κ']

omit [DecidableEq G] in
/-- **Universality of the type channel.**  Let `e : G →* G'` be injective on `S`, carrying
`S` onto `S'` and the derived subgroup `N` onto `N'`, and carrying the splitting type `T`
to `T'`.  Then *any* coset readout `c'` of `N'` in `S'` has exactly the same channel as
*any* coset readout `c` of `N` in `S`.  Two fields with the same Galois group (and the
same type statistics) therefore have identical type channels, whatever their
discriminants and residue labels. -/
theorem typeChannel_universal {S N : Finset G} {S' N' : Finset G'} {c : G → κ} {c' : G' → κ'}
    {T : G → τ} {T' : G' → τ} (e : G →* G') (he : Set.InjOn e S)
    (hS : IsSubgroupFinset S) (hNS : N ⊆ S)
    (hS' : S' = S.image e) (hN' : N' = N.image e)
    (hc : IsCosetReadout S N c) (hc' : IsCosetReadout S' N' c')
    (hT : ∀ g ∈ S, T' (e g) = T g) :
    mutualInfo S' c' T' = mutualInfo S c T := by
  subst hS' hN'
  rw [mutualInfo_image_of_injOn he c' T',
    mutualInfo_congr (S := S) (f := fun w => c' (e w)) (f' := fun w => c' (e w))
      (g' := T) (fun _ _ => rfl) hT]
  apply mutualInfo_congr_partition
  intro a ha b hb
  have hab : a * b⁻¹ ∈ S := hS.mul_mem _ ha _ (hS.inv_mem _ hb)
  rw [hc a ha b hb, hc' (e a) (mem_image_of_mem e ha) (e b) (mem_image_of_mem e hb)]
  rw [← map_inv, ← map_mul]
  constructor
  · intro h; exact mem_image_of_mem e h
  · intro h
    obtain ⟨n, hn, hne⟩ := mem_image.mp h
    have := he (Finset.mem_coe.mpr (hNS hn)) (Finset.mem_coe.mpr hab) hne
    rw [← this]; exact hn

omit [DecidableEq G] in
/-- **Universality, label-free form.**  Only the *partitions* matter: if the type readouts
`T` on `S` and `T'` on `S'` induce the same partition under `e` (they may take values in
different types and have different labels, e.g. cycle types in degree 3 versus degree 6),
the channels coincide. -/
theorem typeChannel_universal_partition {τ' : Type*} [DecidableEq τ']
    {S N : Finset G} {S' N' : Finset G'} {c : G → κ} {c' : G' → κ'}
    {T : G → τ} {T' : G' → τ'} (e : G →* G') (he : Set.InjOn e S)
    (hS : IsSubgroupFinset S) (hNS : N ⊆ S)
    (hS' : S' = S.image e) (hN' : N' = N.image e)
    (hc : IsCosetReadout S N c) (hc' : IsCosetReadout S' N' c')
    (hT : ∀ a ∈ S, ∀ b ∈ S, (T a = T b ↔ T' (e a) = T' (e b))) :
    mutualInfo S' c' T' = mutualInfo S c T := by
  have h1 := typeChannel_universal (T := fun g => T' (e g)) e he hS hNS hS' hN' hc hc'
    (fun _ _ => rfl)
  rw [h1, mutualInfo_comm, mutualInfo_comm S c T]
  exact mutualInfo_congr_partition c hT

/-- **Conjugate realisations are indistinguishable.**  Conjugating a permutation Galois
group, its derived subgroup and its coset labels by any `h` leaves the splitting-type
channel unchanged. -/
theorem typeChannel_conj_invariant {n : ℕ} {S N : Finset (Equiv.Perm (Fin n))}
    {c : Equiv.Perm (Fin n) → κ} {c' : Equiv.Perm (Fin n) → κ'}
    (h : Equiv.Perm (Fin n)) (hS : IsSubgroupFinset S) (hNS : N ⊆ S)
    (hc : IsCosetReadout S N c)
    (hc' : IsCosetReadout (S.image (fun g => h * g * h⁻¹)) (N.image (fun g => h * g * h⁻¹)) c') :
    mutualInfo (S.image (fun g => h * g * h⁻¹)) c' splitType = mutualInfo S c splitType := by
  have hinj : Set.InjOn (MulAut.conj h : Equiv.Perm (Fin n) →* Equiv.Perm (Fin n)) S :=
    fun x _ y _ hxy => (MulAut.conj h).injective hxy
  exact typeChannel_universal (MulAut.conj h : Equiv.Perm (Fin n) →* Equiv.Perm (Fin n)) hinj
    hS hNS rfl rfl hc hc' (fun g _ => splitType_conj g h)

end Universality

section Battery

variable {S N : Finset G} {c : G → κ} {β : Type*} [DecidableEq β]

omit [Group G] [DecidableEq G] in
/-- **Battery chain rule** for type dials. -/
theorem battery_chain (T₁ : G → τ) (T₂ : G → β) :
    mutualInfo S c (pairObs T₁ T₂) = mutualInfo S c T₁ + condMutualInfo S c T₂ T₁ :=
  mutualInfo_pair_chain c T₁ T₂

/-- **Batteries are monotone and capped by the abelianization.**
`I(c ; T₁) ≤ I(c ; (T₁, T₂)) ≤ log₂[G : G']`. -/
theorem battery_capped (hS : IsSubgroupFinset S) (hN : IsSubgroupFinset N) (hNS : N ⊆ S)
    (hc : IsCosetReadout S N c) (T₁ : G → τ) (T₂ : G → β) :
    mutualInfo S c T₁ ≤ mutualInfo S c (pairObs T₁ T₂) ∧
      mutualInfo S c (pairObs T₁ T₂) ≤ logb 2 (S.image c).card :=
  ⟨mutualInfo_le_pair c T₁ T₂, typeChannel_le_logb_index hS hN hNS hc _⟩

/-- **Saturation.**  Once one dial is complete (it determines the coset), no further dial
adds any information: the conditional channel `I(c ; T₂ | T₁)` is zero and the battery
sits exactly at the ceiling. -/
theorem battery_saturates (hS : IsSubgroupFinset S) (hN : IsSubgroupFinset N) (hNS : N ⊆ S)
    (hc : IsCosetReadout S N c) {T₁ : G → τ} (hdet : ∀ a ∈ S, ∀ b ∈ S, T₁ a = T₁ b → c a = c b)
    (T₂ : G → β) :
    condMutualInfo S c T₂ T₁ = 0 ∧
      mutualInfo S c (pairObs T₁ T₂) = logb 2 (S.image c).card := by
  have h1 := (typeChannel_complete_iff hS hN hNS hc).mpr hdet
  have hcap := typeChannel_le_logb_index hS hN hNS hc (pairObs T₁ T₂)
  have hch := mutualInfo_pair_chain (S := S) c T₁ T₂
  have hnn := condMutualInfo_nonneg (S := S) c T₂ T₁
  constructor <;> linarith

/-- **Super-additivity is not universal.**  For every nontrivial abelianization there is
a battery (two copies of the complete dial `c` itself) whose dials are redundant:
`I(c ; T₁) + I(c ; T₂) > I(c ; (T₁, T₂))`.  Synergy observed in the programme is
therefore a property of the specific dials, not of the law. -/
theorem battery_not_superadditive (hS : IsSubgroupFinset S) (hN : IsSubgroupFinset N)
    (hNS : N ⊆ S) (hc : IsCosetReadout S N c) (hk : 2 ≤ (S.image c).card) :
    mutualInfo S c (pairObs c c) < mutualInfo S c c + mutualInfo S c c := by
  have hself : mutualInfo S c c = logb 2 (S.image c).card := by
    rw [mutualInfo_eq_left_of_factors (f := c) (g := c) (φ := id) (fun _ _ => rfl)]
    exact entropy_cosetReadout hS hN hNS hc
  have hcap := typeChannel_le_logb_index hS hN hNS hc (pairObs c c)
  have hpos : 0 < logb 2 ((S.image c).card : ℝ) :=
    Real.logb_pos (by norm_num) (by exact_mod_cast hk)
  linarith

end Battery

end TypeChannel