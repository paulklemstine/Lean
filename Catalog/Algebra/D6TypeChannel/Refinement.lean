/-
# Refinement monotonicity of the counting conditional entropy

Extends the catalog's counting information calculus (`Shared.CyclicTypeChannel`,
`Shared.CyclicTypeChannelNonneg`) by the second half of the data-processing
principle, *on the conditioning side*:

* `condEnt_eq_avg` — the conditional entropy is the average, over the points of
  the source, of the entropy of the fibre through that point;
* `condEnt_le_of_refines` — **refining the dial can only lower `H(g | k)`**: if
  `k'` separates at least the points that `k` separates, then
  `H(g | k') ≤ H(g | k)`, i.e. `I(g ; k) ≤ I(g ; k')`;
* `condEnt_congr_of_partition` — two dials with the same level sets carry the
  same channel;
* `mutInfo_le_abelianization` — **the abelian ceiling**: for any finite group `G`,
  any read-out `g` of a uniformly random element, and any homomorphism
  `φ : G →* A` to an abelian group, `I(g ; φ) ≤ I(g ; G → G^ab)`.  In Chebotarev
  terms: no dial that factors through an abelian quotient of the Galois group
  (e.g. any congruence dial `p mod m`, by Kronecker–Weber) can beat the
  abelianisation.
-/
import Shared.CyclicTypeChannelNonneg

namespace D6TypeChannel

open CyclicTypeChannel Finset

variable {α β γ δ : Type*} [DecidableEq β] [DecidableEq γ] [DecidableEq δ]

/-- The conditional entropy as an average of fibre entropies over the source. -/
theorem condEnt_eq_avg (s : Finset α) (g : α → β) (k : α → γ) :
    condEnt s g k = (∑ a ∈ s, uEnt {x ∈ s | k x = k a} g) / s.card := by
  have hsum : ∑ a ∈ s, uEnt {x ∈ s | k x = k a} g =
      ∑ c ∈ s.image k, (#{x ∈ s | k x = c} : ℝ) * uEnt {x ∈ s | k x = c} g := by
    rw [← Finset.sum_fiberwise_of_maps_to (g := k) (t := s.image k)
      (fun a ha => mem_image_of_mem k ha)]
    refine sum_congr rfl fun c _ => ?_
    rw [sum_congr rfl (g := fun _ => uEnt {x ∈ s | k x = c} g)
      (fun a ha => by rw [(mem_filter.1 ha).2])]
    simp [sum_const, nsmul_eq_mul]
  rw [condEnt, hsum, sum_div]
  refine sum_congr rfl fun c _ => by ring

/-- `H(g | k) ≤ H(g)` (restatement of the catalog's Gibbs inequality). -/
lemma condEnt_le_uEnt (s : Finset α) (g : α → β) (k : α → γ) :
    condEnt s g k ≤ uEnt s g := by
  have := mutInfo_nonneg s g k
  rw [mutInfo] at this
  linarith

/-- **Refinement monotonicity.** If the dial `k'` refines the dial `k` on `s`
(equal `k'`-values force equal `k`-values), then `H(g | k') ≤ H(g | k)`. -/
theorem condEnt_le_of_refines (s : Finset α) (g : α → β) {k : α → γ} {k' : α → δ}
    (h : ∀ a ∈ s, ∀ b ∈ s, k' a = k' b → k a = k b) :
    condEnt s g k' ≤ condEnt s g k := by
  rw [condEnt_eq_avg s g k', condEnt_eq_avg s g k]
  apply div_le_div_of_nonneg_right _ (by positivity)
  have hmaps : ∀ a ∈ s, k a ∈ s.image k := fun a ha => mem_image_of_mem k ha
  rw [← Finset.sum_fiberwise_of_maps_to hmaps, ← Finset.sum_fiberwise_of_maps_to hmaps]
  refine sum_le_sum fun c hc => ?_
  set sc := {x ∈ s | k x = c} with hsc
  -- inside the fibre `sc`, the `k'`-fibres of `s` are the `k'`-fibres of `sc`
  have hfib : ∀ a ∈ sc, {x ∈ s | k' x = k' a} = {x ∈ sc | k' x = k' a} := by
    intro a ha
    rw [hsc, mem_filter] at ha
    ext x
    simp only [hsc, mem_filter]
    constructor
    · rintro ⟨hx, hxa⟩
      exact ⟨⟨hx, (h x hx a ha.1 hxa).trans ha.2⟩, hxa⟩
    · rintro ⟨⟨hx, _⟩, hxa⟩
      exact ⟨hx, hxa⟩
  have hL : ∑ a ∈ sc, uEnt {x ∈ s | k' x = k' a} g = (sc.card : ℝ) * condEnt sc g k' := by
    rw [sum_congr rfl (fun a ha => by rw [hfib a ha]), condEnt_eq_avg sc g k']
    obtain ⟨a, ha, rfl⟩ := mem_image.1 hc
    have hpos : (0 : ℝ) < sc.card := by
      exact_mod_cast card_pos.2 ⟨a, by rw [hsc, mem_filter]; exact ⟨ha, rfl⟩⟩
    field_simp
  have hR : ∑ a ∈ sc, uEnt {x ∈ s | k x = k a} g = (sc.card : ℝ) * uEnt sc g := by
    rw [sum_congr rfl (g := fun _ => uEnt sc g) (fun a ha => by
      rw [hsc, mem_filter] at ha
      rw [ha.2])]
    simp [sum_const, nsmul_eq_mul]
  rw [hL, hR]
  exact mul_le_mul_of_nonneg_left (condEnt_le_uEnt sc g k') (by positivity)

/-- Refinement in terms of the channel: a finer dial carries at least as much
information. -/
theorem mutInfo_le_of_refines (s : Finset α) (g : α → β) {k : α → γ} {k' : α → δ}
    (h : ∀ a ∈ s, ∀ b ∈ s, k' a = k' b → k a = k b) :
    mutInfo s g k ≤ mutInfo s g k' := by
  have := condEnt_le_of_refines s g h
  simp only [mutInfo]
  linarith

/-- Two dials with the same level sets carry exactly the same channel. -/
theorem condEnt_congr_of_partition (s : Finset α) (g : α → β) {k : α → γ} {k' : α → δ}
    (h : ∀ a ∈ s, ∀ b ∈ s, k' a = k' b ↔ k a = k b) :
    condEnt s g k' = condEnt s g k :=
  le_antisymm (condEnt_le_of_refines s g fun a ha b hb => (h a ha b hb).1)
    (condEnt_le_of_refines s g fun a ha b hb => (h a ha b hb).2)

/-- **The abelian ceiling.** For a finite group `G`, a read-out `g : G → β` of a
uniformly random element, and any homomorphism `φ` to an abelian group, the
channel through `φ` is bounded by the channel through the abelianisation. -/
theorem mutInfo_le_abelianization {G A : Type*} [Group G] [Fintype G] [CommGroup A]
    [DecidableEq A] [DecidableEq (Abelianization G)] (g : G → β) (φ : G →* A) :
    mutInfo univ g φ ≤ mutInfo univ g (Abelianization.of : G →* Abelianization G) := by
  refine mutInfo_le_of_refines univ g fun a _ b _ hab => ?_
  have := congrArg (Abelianization.lift φ) hab
  simpa only [Abelianization.lift_apply_of] using this

end D6TypeChannel