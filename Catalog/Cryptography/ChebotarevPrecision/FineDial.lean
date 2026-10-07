import Cryptography.TypeChannelMilestone.UnifiedLaw

/-!
# Paper 134 — Chebotarev precision I: thickening, coprime flatness, fine-dial reduction

Experiment 463 re-measured the whole type-channel master table simultaneously and found
every field within `0.00048` bits of its law value.  This file proves the three
*structural* facts that make such a simultaneous measurement meaningful, i.e. the facts
that say what a perfectly equidistributed (Chebotarev) population of primes *must* show.

* `entropy_comp_fst_of_uniform` — **uniform projection**: if a population `Ω'` lies over
  the Galois group `S` with every group element carrying the same number `m` of
  population points, every readout of the Frobenius has the same law on `Ω'` as on `S`.
* `entropy_thicken`, `mutualInfo_thicken` — **the thickening control**: replicating
  the population uniformly (`S ×ˢ R`) changes no entropy and no channel.  (Measured:
  `−0.00044` bits, i.e. zero to the measurement precision.)
* `mutualInfo_prod_eq_zero` — **coprime flatness**: on a product population (the
  Chebotarev law of a compositum of linearly disjoint fields), readouts of the two
  factors are exactly independent: the channel is `0` bits.
* `fineDial_reduction` — **the fine-dial reduction theorem**.  Model the joint law of
  (residue class `r ∈ R`, Frobenius `g ∈ S`) as uniform on the fibre product
  `{(g, r) | c g = φ r}`, where `φ : R → G^ab` is the Artin map of class field theory
  with uniform fibres.  Then for *every* type readout `T`,
  `I(r ; T) = I(coset ; T)`: the residue dial, however fine (e.g. the sparse 229-class
  dial of the `S3d` field), carries exactly the coset law.  The proof is a genuine
  Markov-chain argument `r → coset → T`, assembled from the battery chain rule and
  coprime flatness on each coset fibre.
* `fineDial_law_le_logb_index`, `fineDial_dial_independent` — consequences: any dial is
  capped by `log₂[G : G']`, and two different dials always have identical laws.
-/

namespace TypeChannel

open Finset Real

section UniformProjection

variable {Ω ρ α β : Type*} [DecidableEq Ω] [DecidableEq ρ] [DecidableEq α] [DecidableEq β]

omit [DecidableEq ρ] in
/-- Counting lemma for a population lying uniformly over `S`. -/
lemma card_filter_fst_of_uniform {Ω' : Finset (Ω × ρ)} {S : Finset Ω} {m : ℕ}
    (hsub : ∀ w ∈ Ω', w.1 ∈ S) (hfib : ∀ g ∈ S, (Ω'.filter (fun w => w.1 = g)).card = m)
    (p : Ω → Prop) [DecidablePred p] :
    (Ω'.filter (fun w => p w.1)).card = m * (S.filter p).card := by
  have hmaps : Set.MapsTo Prod.fst (Ω'.filter (fun w => p w.1) : Set (Ω × ρ))
      (S.filter p : Set Ω) := by
    intro w hw
    simp only [coe_filter, Set.mem_setOf_eq] at hw ⊢
    exact ⟨hsub w hw.1, hw.2⟩
  rw [Finset.card_eq_sum_card_fiberwise hmaps]
  rw [Finset.sum_congr rfl (g := fun _ => m), Finset.sum_const, smul_eq_mul, mul_comm]
  intro g hg
  rw [mem_filter] at hg
  rw [← hfib g hg.1, Finset.filter_filter]
  congr 1
  apply Finset.filter_congr
  intro w _
  constructor
  · rintro ⟨_, h⟩; exact h
  · rintro h; exact ⟨h ▸ hg.2, h⟩

omit [DecidableEq ρ] in
/-- **Uniform projection.**  A population lying over `S` with constant fibre size `m > 0`
has the same law for every readout of the first coordinate. -/
theorem entropy_comp_fst_of_uniform {Ω' : Finset (Ω × ρ)} {S : Finset Ω} {m : ℕ}
    (hm : 0 < m) (hsub : ∀ w ∈ Ω', w.1 ∈ S)
    (hfib : ∀ g ∈ S, (Ω'.filter (fun w => w.1 = g)).card = m) (f : Ω → α) :
    entropy Ω' (fun w => f w.1) = entropy S f := by
  have himg : Ω'.image (fun w => f w.1) = S.image f := by
    ext a
    simp only [mem_image]
    constructor
    · rintro ⟨w, hw, rfl⟩; exact ⟨w.1, hsub w hw, rfl⟩
    · rintro ⟨g, hg, rfl⟩
      have hpos : 0 < (Ω'.filter (fun w => w.1 = g)).card := by rw [hfib g hg]; exact hm
      obtain ⟨w, hw⟩ := Finset.card_pos.mp hpos
      rw [mem_filter] at hw
      exact ⟨w, hw.1, by rw [hw.2]⟩
  have hcard : Ω'.card = m * S.card := by
    have := card_filter_fst_of_uniform hsub hfib (fun _ => True)
    simpa using this
  have hfiber : ∀ a, (fiber Ω' (fun w => f w.1) a).card = m * (fiber S f a).card := by
    intro a
    exact card_filter_fst_of_uniform hsub hfib (fun g => f g = a)
  unfold entropy prob
  rw [himg]
  refine Finset.sum_congr rfl (fun a _ => ?_)
  rw [hfiber a, hcard]
  have hm' : (m : ℝ) ≠ 0 := by exact_mod_cast hm.ne'
  push_cast
  rw [mul_div_mul_left _ _ hm']

omit [DecidableEq ρ] in
/-- Channels between readouts of the first coordinate survive uniform projection. -/
theorem mutualInfo_comp_fst_of_uniform {Ω' : Finset (Ω × ρ)} {S : Finset Ω} {m : ℕ}
    (hm : 0 < m) (hsub : ∀ w ∈ Ω', w.1 ∈ S)
    (hfib : ∀ g ∈ S, (Ω'.filter (fun w => w.1 = g)).card = m) (f : Ω → α) (g : Ω → β) :
    mutualInfo Ω' (fun w => f w.1) (fun w => g w.1) = mutualInfo S f g := by
  unfold mutualInfo
  rw [entropy_comp_fst_of_uniform hm hsub hfib f, entropy_comp_fst_of_uniform hm hsub hfib g,
    ← entropy_comp_fst_of_uniform hm hsub hfib (pairObs f g)]
  rfl

omit [DecidableEq ρ] in
/-- **Thickening control (entropy).**  Uniform replication of the population. -/
theorem entropy_thicken {S : Finset Ω} {R : Finset ρ} (hR : R.Nonempty) (f : Ω → α) :
    entropy (S ×ˢ R) (fun w => f w.1) = entropy S f := by
  refine entropy_comp_fst_of_uniform (m := R.card) (card_pos.mpr hR)
    (fun w hw => (mem_product.mp hw).1) (fun g hg => ?_) f
  have : (S ×ˢ R).filter (fun w => w.1 = g) = ({g} : Finset Ω) ×ˢ R := by
    ext w
    simp only [mem_filter, mem_product, mem_singleton]
    constructor
    · rintro ⟨⟨_, h2⟩, h3⟩; exact ⟨h3, h2⟩
    · rintro ⟨h1, h2⟩; exact ⟨⟨h1 ▸ hg, h2⟩, h1⟩
  rw [this, card_product, card_singleton, one_mul]

omit [DecidableEq ρ] in
/-- **Thickening control (channels).**  Every channel is invariant under uniform
replication of the population: the thickening control must read `0` bits. -/
theorem mutualInfo_thicken {S : Finset Ω} {R : Finset ρ} (hR : R.Nonempty)
    (f : Ω → α) (g : Ω → β) :
    mutualInfo (S ×ˢ R) (fun w => f w.1) (fun w => g w.1) = mutualInfo S f g := by
  unfold mutualInfo
  rw [entropy_thicken hR f, entropy_thicken hR g, ← entropy_thicken hR (pairObs f g)]
  rfl

end UniformProjection

section Product

variable {Ω ρ α β : Type*} [DecidableEq Ω] [DecidableEq ρ] [DecidableEq α] [DecidableEq β]

/-- Marginal on the second factor of a product population. -/
lemma entropy_prod_snd {S : Finset Ω} {R : Finset ρ} (hS : S.Nonempty) (g : ρ → β) :
    entropy (S ×ˢ R) (fun w => g w.2) = entropy R g := by
  have hswap : (R ×ˢ S).image Prod.swap = S ×ˢ R := Finset.image_swap_product S R
  have hinj : Set.InjOn (Prod.swap : ρ × Ω → Ω × ρ) (R ×ˢ S : Finset (ρ × Ω)) :=
    fun x _ y _ h => Prod.swap_injective h
  rw [← hswap, entropy_image_of_injOn hinj]
  exact entropy_thicken hS g

omit [DecidableEq Ω] [DecidableEq ρ] in
/-- The joint law of a product population factorises. -/
lemma prob_prod_pair (S : Finset Ω) (R : Finset ρ) (f : Ω → α) (g : ρ → β) (a : α) (b : β) :
    prob (S ×ˢ R) (pairObs (fun w => f w.1) (fun w => g w.2)) (a, b) =
      prob S f a * prob R g b := by
  have hfib : fiber (S ×ˢ R) (pairObs (fun w => f w.1) (fun w => g w.2)) (a, b) =
      fiber S f a ×ˢ fiber R g b := by
    ext w
    simp only [fiber, pairObs, mem_filter, mem_product, Prod.mk.injEq]
    tauto
  unfold prob
  rw [hfib, card_product, card_product]
  push_cast
  rw [mul_div_mul_comm]

omit [DecidableEq Ω] [DecidableEq ρ] in
/-- **Additivity of entropy on product populations.** -/
theorem entropy_prod_pair {S : Finset Ω} {R : Finset ρ} (hS : S.Nonempty) (hR : R.Nonempty)
    (f : Ω → α) (g : ρ → β) :
    entropy (S ×ˢ R) (pairObs (fun w => f w.1) (fun w => g w.2)) =
      entropy S f + entropy R g := by
  have hsub : (S ×ˢ R).image (pairObs (fun w => f w.1) (fun w => g w.2)) ⊆
      S.image f ×ˢ R.image g := by
    intro x hx
    obtain ⟨w, hw, rfl⟩ := mem_image.mp hx
    obtain ⟨h1, h2⟩ := mem_product.mp hw
    exact mem_product.mpr ⟨mem_image_of_mem _ h1, mem_image_of_mem _ h2⟩
  rw [entropy_eq_sum_of_subset hsub, Finset.sum_product]
  have hcell : ∀ a ∈ S.image f, ∀ b ∈ R.image g,
      -(prob (S ×ˢ R) (pairObs (fun w => f w.1) (fun w => g w.2)) (a, b) *
          logb 2 (prob (S ×ˢ R) (pairObs (fun w => f w.1) (fun w => g w.2)) (a, b))) =
        -(prob S f a * logb 2 (prob S f a)) * prob R g b +
          prob S f a * -(prob R g b * logb 2 (prob R g b)) := by
    intro a ha b hb
    rw [prob_prod_pair, Real.logb_mul (prob_pos_of_mem ha).ne' (prob_pos_of_mem hb).ne']
    ring
  rw [Finset.sum_congr rfl (fun a ha => Finset.sum_congr rfl (fun b hb => hcell a ha b hb))]
  simp only [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.sum_mul]
  rw [sum_prob hR, sum_prob hS, mul_one, one_mul]
  rfl

/-- **Coprime flatness.**  On a product population, a readout of the first factor and a
readout of the second factor share exactly zero bits. -/
theorem mutualInfo_prod_eq_zero (S : Finset Ω) (R : Finset ρ) (f : Ω → α) (g : ρ → β) :
    mutualInfo (S ×ˢ R) (fun w => f w.1) (fun w => g w.2) = 0 := by
  rcases S.eq_empty_or_nonempty with hS | hS
  · subst hS; simp [mutualInfo, entropy]
  rcases R.eq_empty_or_nonempty with hR | hR
  · subst hR; simp [mutualInfo, entropy]
  unfold mutualInfo
  rw [entropy_prod_pair hS hR, entropy_thicken hR, entropy_prod_snd hS]
  ring

end Product

section FineDial

variable {Ω ρ κ τ : Type*} [DecidableEq Ω] [DecidableEq ρ] [DecidableEq κ] [DecidableEq τ]

/-- The Chebotarev–class-field population of (Frobenius, residue class) pairs: the fibre
product of the coset readout `c` and the Artin map `φ`. -/
def fibreProduct (S : Finset Ω) (R : Finset ρ) (c : Ω → κ) (φ : ρ → κ) : Finset (Ω × ρ) :=
  (S ×ˢ R).filter (fun w => c w.1 = φ w.2)

/-- The Artin map has uniform fibres of size `m` over every coset that occurs. -/
def UniformDial (S : Finset Ω) (R : Finset ρ) (c : Ω → κ) (φ : ρ → κ) (m : ℕ) : Prop :=
  0 < m ∧ ∀ k ∈ S.image c, (R.filter (fun r => φ r = k)).card = m

variable {S : Finset Ω} {R : Finset ρ} {c : Ω → κ} {φ : ρ → κ} {m : ℕ}

omit [DecidableEq Ω] [DecidableEq ρ] in
lemma fibreProduct_fst_mem {w : Ω × ρ} (hw : w ∈ fibreProduct S R c φ) : w.1 ∈ S :=
  (mem_product.mp (mem_filter.mp hw).1).1

omit [DecidableEq Ω] [DecidableEq ρ] in
lemma fibreProduct_rel {w : Ω × ρ} (hw : w ∈ fibreProduct S R c φ) : c w.1 = φ w.2 :=
  (mem_filter.mp hw).2

omit [DecidableEq ρ] in
lemma fibreProduct_fiber_fst (hd : UniformDial S R c φ m) (g : Ω) (hg : g ∈ S) :
    ((fibreProduct S R c φ).filter (fun w => w.1 = g)).card = m := by
  have : (fibreProduct S R c φ).filter (fun w => w.1 = g) =
      ({g} : Finset Ω) ×ˢ R.filter (fun r => φ r = c g) := by
    ext w
    simp only [fibreProduct, mem_filter, mem_product, mem_singleton]
    constructor
    · rintro ⟨⟨⟨_, h2⟩, h3⟩, h4⟩; exact ⟨h4, h2, by rw [← h3, h4]⟩
    · rintro ⟨h1, h2, h3⟩; exact ⟨⟨⟨h1 ▸ hg, h2⟩, by rw [h1, h3]⟩, h1⟩
  rw [this, card_product, card_singleton, one_mul]
  exact hd.2 _ (mem_image_of_mem c hg)

omit [DecidableEq Ω] [DecidableEq ρ] in
/-- On a coset fibre, the population is a product: Frobenius in the coset × residues
mapping to it. -/
lemma fibreProduct_fiber_coset (k : κ) :
    fiber (fibreProduct S R c φ) (fun w => c w.1) k =
      fiber S c k ×ˢ R.filter (fun r => φ r = k) := by
  ext w
  simp only [fiber, fibreProduct, mem_filter, mem_product]
  constructor
  · rintro ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩; exact ⟨⟨h1, h4⟩, h2, by rw [← h3, h4]⟩
  · rintro ⟨⟨h1, h4⟩, h2, h3⟩; exact ⟨⟨⟨h1, h2⟩, by rw [h4, h3]⟩, h4⟩

/-- **The fine-dial reduction theorem.**  For a uniform Artin dial, the residue-class
channel equals the abelianization-coset channel, for every type readout `T`:
`I(r ; T) = I(coset ; T)`. -/
theorem fineDial_reduction (hd : UniformDial S R c φ m) (T : Ω → τ) :
    mutualInfo (fibreProduct S R c φ) (fun w => w.2) (fun w => T w.1) = mutualInfo S c T := by
  -- Step 1: the dial `r` and the refined dial `(coset, r)` induce the same partition.
  have hpart : mutualInfo (fibreProduct S R c φ) (pairObs (fun w => c w.1) (fun w => w.2))
        (fun w => T w.1) =
      mutualInfo (fibreProduct S R c φ) (fun w => w.2) (fun w => T w.1) := by
    refine mutualInfo_congr_partition (S := fibreProduct S R c φ) (c := fun w : Ω × ρ => w.2)
      (c' := pairObs (fun w => c w.1) (fun w => w.2)) (fun w => T w.1) ?_
    intro a ha b hb
    have ha' : c a.1 = φ a.2 := fibreProduct_rel ha
    have hb' : c b.1 = φ b.2 := fibreProduct_rel hb
    simp only [pairObs, Prod.mk.injEq]
    constructor
    · intro h; exact ⟨by rw [ha', hb', h], h⟩
    · intro h; exact h.2
  -- Step 2: battery chain rule `I(T ; (coset, r)) = I(T ; coset) + I(T ; r | coset)`.
  have hchain := mutualInfo_pair_chain (S := fibreProduct S R c φ) (fun w => T w.1) (fun w => c w.1)
    (fun w => w.2)
  -- Step 3: the coset channel survives the uniform projection to `S`.
  have hproj : mutualInfo (fibreProduct S R c φ) (fun w => T w.1) (fun w => c w.1) = mutualInfo S T c :=
    mutualInfo_comp_fst_of_uniform hd.1 (fun w hw => fibreProduct_fst_mem hw)
      (fun g hg => fibreProduct_fiber_fst hd g hg) T c
  -- Step 4: given the coset, residue and type are independent (coprime flatness).
  have hcond : condMutualInfo (fibreProduct S R c φ) (fun w => T w.1) (fun w => w.2) (fun w => c w.1) = 0 := by
    unfold condMutualInfo
    refine Finset.sum_eq_zero (fun k _ => ?_)
    have h0 := mutualInfo_prod_eq_zero (fiber S c k) (R.filter (fun r => φ r = k)) T
      (fun r => r)
    rw [fibreProduct_fiber_coset k, h0, mul_zero]
  have hc1 := mutualInfo_comm (fibreProduct S R c φ) (fun w => w.2) (fun w => T w.1)
  have hc2 := mutualInfo_comm (fibreProduct S R c φ)
    (pairObs (fun w => c w.1) (fun w => w.2)) (fun w => T w.1)
  have hc3 := mutualInfo_comm S c T
  linarith

/-- **Dial independence.**  Two uniform Artin dials (of any sizes) over the same Galois
readout have exactly the same type channel. -/
theorem fineDial_dial_independent {ρ' : Type*} [DecidableEq ρ'] {R' : Finset ρ'}
    {φ' : ρ' → κ} {m' : ℕ} (hd : UniformDial S R c φ m) (hd' : UniformDial S R' c φ' m')
    (T : Ω → τ) :
    mutualInfo (fibreProduct S R c φ) (fun w => w.2) (fun w => T w.1) =
      mutualInfo (fibreProduct S R' c φ') (fun w => w.2) (fun w => T w.1) := by
  rw [fineDial_reduction hd, fineDial_reduction hd']

end FineDial

section GroupCap

variable {G : Type*} [Group G] [DecidableEq G] {ρ κ τ : Type*} [DecidableEq ρ] [DecidableEq κ]
  [DecidableEq τ] {S N : Finset G} {c : G → κ} {R : Finset ρ} {φ : ρ → κ} {m : ℕ}

/-- **Any residue dial is capped by the abelianization.**  For a Galois group `S` with
derived subgroup `N` and a uniform Artin dial, the residue channel lies in
`[max 0 (H(T) − log₂|G'|), log₂[G : G']]`, whatever the number of residue classes. -/
theorem fineDial_law_sandwich (hS : IsSubgroupFinset S) (hN : IsSubgroupFinset N)
    (hNS : N ⊆ S) (hc : IsCosetReadout S N c) (hd : UniformDial S R c φ m) (T : G → τ) :
    max 0 (entropy S T - logb 2 N.card) ≤
        mutualInfo (fibreProduct S R c φ) (fun w => w.2) (fun w => T w.1) ∧
      mutualInfo (fibreProduct S R c φ) (fun w => w.2) (fun w => T w.1) ≤
        logb 2 (S.image c).card := by
  rw [fineDial_reduction hd]
  have h := typeChannel_sandwich hS hN hNS hc T
  exact ⟨h.1, h.2.trans (min_le_right _ _)⟩

/-- The cap alone, in the form used to diagnose anomalies. -/
theorem fineDial_law_le_logb_index (hS : IsSubgroupFinset S) (hN : IsSubgroupFinset N)
    (hNS : N ⊆ S) (hc : IsCosetReadout S N c) (hd : UniformDial S R c φ m) (T : G → τ) :
    mutualInfo (fibreProduct S R c φ) (fun w => w.2) (fun w => T w.1) ≤
      logb 2 (S.image c).card :=
  (fineDial_law_sandwich hS hN hNS hc hd T).2

end GroupCap

end TypeChannel