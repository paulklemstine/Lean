import Cryptography.TypeChannelMilestone.InfoCalculus

/-!
# The Galois/Frobenius side channel: data processing and the independence law

This file strengthens two of the three closures of the Galois/Frobenius side-channel
family (`Cryptography.NonabelianTypeChannel.*`, the which-factor wall and the
Artin/torsor channel) from *support / one-readout* statements to *distributional,
all-post-processings* statements, in the finite Shannon calculus of
`Cryptography.NonabelianTypeChannel.Entropy`.

## Main results

* `mutualInfo_comp_left_le`, `mutualInfo_comp_both_le` — **data processing**:
  post-processing either readout never increases a channel.
* `residue_postprocess_le_index` — the **abelianization cap for every post-processed
  residue readout**: `I(ψ ∘ coset ; φ ∘ T) ≤ I(coset ; T) ≤ log₂ [S : N]`.  The catalog
  cap `typeChannel_le_logb_index` only covered the coset readout itself and injective
  relabellings of it (`residue_channel_eq_coset_channel`).
* `mutualInfo_eq_zero_of_card_mul` — the **independence law** in counting form: if every
  joint cell count factors, the channel is exactly zero.
* `frobenius_one_time_pad` — **the Artin channel is a one-time pad**: in *any* finite
  Galois group `S` (abelian or not), for any candidate set `A ⊆ S` of Frobenius elements
  of `p` and a Chebotarev-uniform Frobenius of `q` in `S`, *every* readout of the
  product `σ_p σ_q` carries
  **exactly zero** bits about *every* readout of `σ_p`.
* `frobenius_posterior_eq_prior` — the same, as "posterior = prior": conditioning on any
  observed value of the product readout leaves the law of every readout of `σ_p`
  unchanged.  This is the distributional strengthening of `nonabelian_no_pruning`
  (which only says the posterior has full *support*).
* `frobenius_pad_breaks_with_cofactor` — non-vacuity: once the Frobenius of the cofactor
  is also revealed, the product readout carries the full `log₂ |A|` bits.
-/

namespace TypeChannel

namespace GaloisSideChannel

open Finset Real

variable {Ω α β γ δ : Type*} [DecidableEq α] [DecidableEq β] [DecidableEq γ] [DecidableEq δ]

/-! ## 1. Data processing -/

/-- **Data processing (left).**  Post-processing the first readout by any function `ψ`
never increases the channel: `I(ψ ∘ f ; g) ≤ I(f ; g)`. -/
theorem mutualInfo_comp_left_le (S : Finset Ω) (f : Ω → α) (g : Ω → β) (ψ : α → γ) :
    mutualInfo S (fun w => ψ (f w)) g ≤ mutualInfo S f g := by
  rw [mutualInfo_comm S _ g, mutualInfo_comm S f g]
  calc mutualInfo S g (fun w => ψ (f w))
      ≤ mutualInfo S g (pairObs (fun w => ψ (f w)) f) := mutualInfo_le_pair g _ f
    _ = mutualInfo S g f := by
        rw [mutualInfo_comm S g, mutualInfo_comm S g f]
        refine mutualInfo_congr_partition (c := f) (c' := pairObs (fun w => ψ (f w)) f) g ?_
        intro a _ b _
        simp only [pairObs, Prod.mk.injEq]
        constructor
        · intro h; exact ⟨by rw [h], h⟩
        · exact fun h => h.2

/-- **Data processing (right).** `I(f ; φ ∘ g) ≤ I(f ; g)`. -/
theorem mutualInfo_comp_right_le (S : Finset Ω) (f : Ω → α) (g : Ω → β) (φ : β → δ) :
    mutualInfo S f (fun w => φ (g w)) ≤ mutualInfo S f g := by
  rw [mutualInfo_comm S f _, mutualInfo_comm S f g]
  exact mutualInfo_comp_left_le S g f φ

/-- **Data processing (both sides).** `I(ψ ∘ f ; φ ∘ g) ≤ I(f ; g)`. -/
theorem mutualInfo_comp_both_le (S : Finset Ω) (f : Ω → α) (g : Ω → β) (ψ : α → γ)
    (φ : β → δ) :
    mutualInfo S (fun w => ψ (f w)) (fun w => φ (g w)) ≤ mutualInfo S f g :=
  (mutualInfo_comp_right_le S _ g φ).trans (mutualInfo_comp_left_le S f g ψ)

section Residue

variable {G : Type*} [Group G] [DecidableEq G] {κ τ : Type*} [DecidableEq κ] [DecidableEq τ]

/-- **The abelianization cap for every post-processed residue readout.**  Let `S` be a
finite Galois group, `N` its derived subgroup and `c` the coset (residue-class) readout.
For *any* coarsening `ψ` of the residue (e.g. reducing `p` to a smaller modulus, or
any arithmetic function of the residue) and *any* post-processing `φ` of the splitting
type, the channel is bounded by the coset channel, and hence by `log₂ [S : N]`. -/
theorem residue_postprocess_le_index {S N : Finset G} {c : G → κ}
    (hS : IsSubgroupFinset S) (hN : IsSubgroupFinset N) (hNS : N ⊆ S)
    (hc : IsCosetReadout S N c) (T : G → τ) (ψ : κ → γ) (φ : τ → δ) :
    mutualInfo S (fun g => ψ (c g)) (fun g => φ (T g)) ≤ mutualInfo S c T ∧
      mutualInfo S c T ≤ logb 2 (S.image c).card :=
  ⟨mutualInfo_comp_both_le S c T ψ φ, typeChannel_le_logb_index hS hN hNS hc T⟩

omit [DecidableEq G] in
/-- In a perfect Galois group *every* post-processed residue readout leaks exactly
nothing about *every* post-processed type readout. -/
theorem residue_postprocess_eq_zero_of_perfect {S : Finset G} {c : G → κ}
    (hS : IsSubgroupFinset S) (hc : IsCosetReadout S S c) (T : G → τ) (ψ : κ → γ)
    (φ : τ → δ) :
    mutualInfo S (fun g => ψ (c g)) (fun g => φ (T g)) = 0 := by
  have h1 := mutualInfo_comp_both_le S c T ψ φ
  rw [typeChannel_eq_zero_of_perfect hS hc T] at h1
  have h2 := mutualInfo_nonneg (S := S) ⟨1, hS.one_mem⟩ (fun g => ψ (c g)) (fun g => φ (T g))
  linarith

end Residue

/-! ## 2. The independence law -/

/-- **The independence law (probability form).**  If the joint law of `(f, g)` is the
product of the marginals on the product of the images, the channel is exactly zero. -/
theorem mutualInfo_eq_zero_of_prob_mul {S : Finset Ω} {f : Ω → α} {g : Ω → β}
    (h : ∀ a ∈ S.image f, ∀ b ∈ S.image g,
      prob S (pairObs f g) (a, b) = prob S f a * prob S g b) :
    mutualInfo S f g = 0 := by
  rcases S.eq_empty_or_nonempty with hS | hS
  · subst hS; simp [mutualInfo, entropy]
  have hpair : entropy S (pairObs f g) = entropy S f + entropy S g := by
    rw [entropy_eq_sum_of_subset (image_pairObs_subset (S := S) (f := f) (g := g)),
      Finset.sum_product]
    have hterm : ∀ a ∈ S.image f, ∑ b ∈ S.image g,
        -(prob S (pairObs f g) (a, b) * logb 2 (prob S (pairObs f g) (a, b)))
          = -(prob S f a * logb 2 (prob S f a)) * ∑ b ∈ S.image g, prob S g b
            + prob S f a * ∑ b ∈ S.image g, -(prob S g b * logb 2 (prob S g b)) := by
      intro a ha
      rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
      refine Finset.sum_congr rfl (fun b hb => ?_)
      rw [h a ha b hb, Real.logb_mul (prob_pos_of_mem ha).ne' (prob_pos_of_mem hb).ne']
      ring
    rw [Finset.sum_congr rfl hterm, Finset.sum_add_distrib, sum_prob hS]
    simp only [mul_one]
    rw [← Finset.sum_mul, sum_prob hS, one_mul]
    rfl
  unfold mutualInfo
  rw [hpair]; ring

/-- A joint cell count that factors gives a joint probability that factors. -/
lemma prob_pair_eq_mul_of_card_mul {S : Finset Ω} {f : Ω → α} {g : Ω → β} {a : α} {b : β}
    (hS : S.Nonempty)
    (h : (fiber S (pairObs f g) (a, b)).card * S.card = (fiber S f a).card * (fiber S g b).card) :
    prob S (pairObs f g) (a, b) = prob S f a * prob S g b := by
  have hS' : (S.card : ℝ) ≠ 0 := by exact_mod_cast (card_pos.mpr hS).ne'
  have hc : ((fiber S (pairObs f g) (a, b)).card : ℝ) * S.card
      = (fiber S f a).card * (fiber S g b).card := by exact_mod_cast h
  unfold prob
  field_simp
  linarith

/-- **The independence law (counting form).**  If every joint cell count satisfies
`#{f = a, g = b} · |S| = #{f = a} · #{g = b}`, the channel is exactly zero. -/
theorem mutualInfo_eq_zero_of_card_mul {S : Finset Ω} {f : Ω → α} {g : Ω → β}
    (h : ∀ a ∈ S.image f, ∀ b ∈ S.image g,
      (fiber S (pairObs f g) (a, b)).card * S.card = (fiber S f a).card * (fiber S g b).card) :
    mutualInfo S f g = 0 := by
  refine mutualInfo_eq_zero_of_prob_mul (fun a ha b hb => ?_)
  obtain ⟨w, hw, _⟩ := mem_image.mp ha
  exact prob_pair_eq_mul_of_card_mul ⟨w, hw⟩ (h a ha b hb)

/-! ## 3. The Artin channel is a one-time pad -/

section OneTimePad

variable {G : Type*} [Group G] [DecidableEq G] {S A : Finset G}

/-- The counting core of the one-time pad: inside a finite Galois group `S`, the shear
`(x, z) ↦ (x, x⁻¹ z)` identifies the cell `{F x = a, H (x y) = b}` of `A × S` with a
product of a cell of `F` on `A` and a cell of `H` on `S`. -/
lemma card_shear_filter (hS : IsSubgroupFinset S) (hA : A ⊆ S) (P Q : G → Prop)
    [DecidablePred P] [DecidablePred Q] :
    ((A ×ˢ S).filter (fun z => P z.1 ∧ Q (z.1 * z.2))).card
      = (A.filter P).card * (S.filter Q).card := by
  have hset : (A ×ˢ S).filter (fun z => P z.1 ∧ Q (z.1 * z.2))
      = ((A.filter P) ×ˢ (S.filter Q)).image (fun u : G × G => (u.1, u.1⁻¹ * u.2)) := by
    ext ⟨x, y⟩
    simp only [mem_filter, mem_product, mem_image, Prod.mk.injEq, Prod.exists]
    constructor
    · rintro ⟨⟨hx, hy⟩, hP, hQ⟩
      exact ⟨x, x * y, ⟨⟨hx, hP⟩, hS.mul_mem _ (hA hx) _ hy, hQ⟩, rfl, by group⟩
    · rintro ⟨u, v, ⟨⟨hu, hP⟩, hv, hQ⟩, rfl, rfl⟩
      refine ⟨⟨hu, hS.mul_mem _ (hS.inv_mem _ (hA hu)) _ hv⟩, hP, ?_⟩
      simpa using hQ
  rw [hset, Finset.card_image_of_injective, Finset.card_product]
  intro u v huv
  simp only [Prod.mk.injEq] at huv
  obtain ⟨h1, h2⟩ := huv
  refine Prod.ext h1 ?_
  rw [h1] at h2
  exact mul_left_cancel h2

/-- The cell counts of the product channel factor exactly:
`#{F x = a, H (x y) = b} · |A × S| = #{F x = a} · #{H (x y) = b}`. -/
lemma pad_card_mul (hS : IsSubgroupFinset S) (hA : A ⊆ S) (F : G → α) (H : G → β)
    (a : α) (b : β) :
    (fiber (A ×ˢ S) (pairObs (fun z : G × G => F z.1)
      (fun z => H (z.1 * z.2))) (a, b)).card * (A ×ˢ S).card
      = (fiber (A ×ˢ S) (fun z : G × G => F z.1) a).card *
        (fiber (A ×ˢ S) (fun z : G × G => H (z.1 * z.2)) b).card := by
  have h1 : (fiber (A ×ˢ S) (pairObs (fun z : G × G => F z.1)
      (fun z => H (z.1 * z.2))) (a, b)).card
      = (A.filter (fun x => F x = a)).card * (S.filter (fun x => H x = b)).card := by
    rw [← card_shear_filter hS hA]
    unfold fiber pairObs
    simp only [Prod.mk.injEq]
  have h2 : (fiber (A ×ˢ S) (fun z : G × G => F z.1) a).card
      = (A.filter (fun x => F x = a)).card * (S.filter (fun _ => True)).card := by
    rw [← card_shear_filter hS hA]
    unfold fiber
    simp only [and_true]
  have h3 : (fiber (A ×ˢ S) (fun z : G × G => H (z.1 * z.2)) b).card
      = (A.filter (fun _ => True)).card * (S.filter (fun x => H x = b)).card := by
    rw [← card_shear_filter hS hA]
    unfold fiber
    simp only [true_and]
  rw [h1, h2, h3, Finset.card_product]
  simp only [filter_true]
  ring

/-- **The Artin channel is a one-time pad.**  Let `S` be a finite (possibly non-abelian)
Galois group.  Model the Frobenius of `p` as uniform on an arbitrary candidate set
`A ⊆ S` and the Frobenius of `q` as uniform on `S` (Chebotarev).  Then *any* readout `H`
of the Frobenius of `N`, `σ_N = σ_p σ_q` — its conjugacy class, its abelianization coset,
its cycle type, anything — carries **exactly zero** bits about *any* readout `F` of
`σ_p`. -/
theorem frobenius_one_time_pad (hS : IsSubgroupFinset S) (hA : A ⊆ S) (F : G → α)
    (H : G → β) :
    mutualInfo (A ×ˢ S) (fun z => F z.1) (fun z => H (z.1 * z.2)) = 0 :=
  mutualInfo_eq_zero_of_card_mul (fun a _ b _ => pad_card_mul hS hA F H a b)

/-- **Posterior equals prior.**  For every observed value `b` of the readout of the
Frobenius of `N`, the conditional law of every readout of the Frobenius of `p` equals its
prior law.  `nonabelian_no_pruning` is the support shadow of this statement. -/
theorem frobenius_posterior_eq_prior (hS : IsSubgroupFinset S) (hA : A ⊆ S) (F : G → α)
    (H : G → β) (a : α) {b : β} (hb : b ∈ (A ×ˢ S).image (fun z => H (z.1 * z.2))) :
    prob (fiber (A ×ˢ S) (fun z => H (z.1 * z.2)) b) (fun z => F z.1) a
      = prob (A ×ˢ S) (fun z => F z.1) a := by
  have hpb : 0 < prob (A ×ˢ S) (fun z : G × G => H (z.1 * z.2)) b := prob_pos_of_mem hb
  obtain ⟨w, hw, _⟩ := mem_image.mp hb
  have hjoint := prob_pair_eq_mul_of_card_mul ⟨w, hw⟩ (pad_card_mul hS hA F H a b)
  have hchain := prob_pair_eq_mul (S := A ×ˢ S) (X := fun z : G × G => F z.1)
    (t := fun z : G × G => H (z.1 * z.2)) (a := a) hb
  rw [hjoint] at hchain
  have key : prob (A ×ˢ S) (fun z : G × G => H (z.1 * z.2)) b *
      (prob (fiber (A ×ˢ S) (fun z : G × G => H (z.1 * z.2)) b) (fun z => F z.1) a
        - prob (A ×ˢ S) (fun z : G × G => F z.1) a) = 0 := by
    rw [mul_sub]; linarith
  rcases mul_eq_zero.mp key with h | h
  · exact absurd h hpb.ne'
  · linarith

/-- **Non-vacuity: the pad breaks once the cofactor's Frobenius is revealed.**  The pair
(Frobenius of `N`, Frobenius of `q`) determines the Frobenius of `p`, so it carries the
full `log₂ |A|` bits about it.  The zero of `frobenius_one_time_pad` is therefore a
genuine independence phenomenon, not an entropy deficit. -/
theorem frobenius_pad_breaks_with_cofactor (hS : IsSubgroupFinset S) (hA : A ⊆ S)
    (hA0 : A.Nonempty) :
    mutualInfo (A ×ˢ S) (fun z => z.1) (fun z => (z.1 * z.2, z.2)) = logb 2 A.card := by
  rw [mutualInfo_eq_left_of_factors (φ := fun u : G × G => u.1 * u.2⁻¹)
    (fun w _ => by simp)]
  have himg : (A ×ˢ S).image (fun z : G × G => z.1) = A := by
    ext x
    simp only [mem_image, mem_product, Prod.exists, exists_and_right, exists_eq_right]
    exact ⟨fun ⟨_, h, _⟩ => h, fun h => ⟨1, h, hS.one_mem⟩⟩
  rw [entropy_eq_logb_card_of_uniform_fibers (k := S.card)
    (hA0.product ⟨1, hS.one_mem⟩) (card_pos.mpr ⟨1, hS.one_mem⟩), himg]
  intro x hx
  rw [himg] at hx
  have := card_shear_filter hS hA (fun y => y = x) (fun _ => True)
  simp only [and_true, filter_true] at this
  unfold fiber
  rw [this, Finset.filter_eq' A x, if_pos hx, card_singleton, one_mul]

end OneTimePad

end GaloisSideChannel

end TypeChannel