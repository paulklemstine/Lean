/-
# DIAL-CROSS-TALK: independent dials are truly independent (FACT round-34 #3, paper 121)

Verdict **THE-DIALS-ARE-INDEPENDENT**.  Two `S₃` cubics whose discriminants are coprime (more
precisely: whose quadratic resolvents differ, so the two splitting fields are linearly disjoint)
have compositum Galois group `S₃ × S₃`; by Chebotarev the pair of Frobenius classes of an
unramified prime is uniformly distributed on `S₃ × S₃`.  Everything below is stated in the
counting-entropy framework `uEnt` / `condEnt` / `mutInfo` of `Catalog.Shared.CyclicTypeChannel`
(uniform measure on a finite sample space) and extends `Catalog.Bridges.CharacterOneBit`.

## Main results

General information theory on finite uniform sources
* `mutInfo_eq_zero_of_countIndep` — if the joint count table factorises, `I(g ; k) = 0`.
* `countIndep_product`, `mutInfo_product_marginals`, `mutInfo_group_product_eq_zero` — on a
  product sample space (linearly disjoint compositum, group `G × H`) *any* two readouts of the
  two coordinates carry exactly `0` bits about each other.
* `uEnt_product`, `uEnt_product_fst`, `mutInfo_product` — additivity of entropy and of mutual information over
  independent blocks (this is what turns the prime statement into the semiprime statement).
* `condEnt_le_condEnt_comp`, `mutInfo_comp_left_le`, `mutInfo_comp_right_le` — the data
  processing inequality, derived from the Gibbs inequality `mutInfo_nonneg`.
* `one_le_mutInfo_fibreProd` — **shared resolvent ⟹ at least one bit**: on a fibre product
  `G ×_C H` over a two-element quotient, readouts determining the quadratic characters share at
  least one bit.

The two cubics
* `S3.mutInfo_dials_indep` — `I(T₁ ; T₂) = 0` on `S₃ × S₃` (**the verdict**, exact).
* `S3.mutInfo_semiprime_indep` — `I(pair₁ ; pair₂) = 0` for `N = p q` (exact).
* `S3.uEnt_dial_pair` — `H(T₁, T₂) = 4/3 + log₂ 3 = 2 H(T)`; `S3.condEnt_dials_indep` —
  `H(T₁ | T₂) = H(T₁) = 2/3 + (log₂ 3)/2`.
* `S3.mutInfo_sharedQuad` — on `S₃ ×_{C₂} S₃` (shared quadratic resolvent) `I(T₁ ; T₂) = 1`
  exactly; `S3.mutInfo_sharedQuad_bound_sharp` shows the general lower bound is attained;
  `S3.not_countIndep_sharedQuad` — the joint table does not factor.
* `S3.crossTalk_dichotomy` — `0` bits (coprime) versus `1` bit (shared resolvent);
  `S3.mutInfo_semiprime_shared` — `2` bits for semiprimes with a shared resolvent, while
  `S3.uEnt_semiprime_shared_pair` keeps each pair read-out at `4/3 + log₂ 3` bits.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the measured prime value `I = 0.000437` bits (null `z = -0.81`) and
  semiprime value `I = 0.001424` bits are pure finite-sample bias around an exact `0`; the only
  mechanism that can create cross-talk between two `S₃` dials is a shared quadratic resolvent,
  and then the cross-talk is exactly the one sign bit.
Experiment (Stage 2, primes `5 ≤ p < 30000`, unramified in both, splitting type from the root
  count mod `p`):
  * `x³+x+1` (disc `-31`) vs `x³-x-1` (disc `-23`): 3241 primes, empirical `I = 0.000243` bits;
    joint counts 111/111: 82, 111/12: 263, 111/3: 180, 12/111: 275, 12/12: 811, 12/3: 546,
    3/111: 170, 3/12: 554, 3/3: 360 (product law predicts 90, 270, 180, 270, 810, 540, 180, 540,
    360).  The Miller–Madow bias for a `3 × 3` table is `4 / (2 n ln 2) ≈ 0.00089` bits.
  * `x³-2` vs `x³+x+1` (coprime): 3242 primes, `I = 0.000808` bits.
  * `x³-2` vs `x³-3` (both resolvent `ℚ(√-3)`): 3243 primes, `I = 1.000267` bits; joint counts
    111/111: 171, 111/3: 363, 3/111: 376, 3/3: 700, 12/12: 1633, all other cells `0`
    (fibre-product law `1 : 2 : 2 : 4 : 9` over 18 predicts 180, 360, 360, 720, 1621).
  * `x³-2` vs `x³-5`: 3242 primes, `I = 1.000023` bits.
  * semiprimes `N = p q` (consecutive prime pairs, coprime cubics): 1617 samples,
    `I = 0.0216` bits against a `9 × 9` bias of `64 / (2 n ln 2) ≈ 0.029` bits.
Analysis (Stage 3): all coprime-resolvent values are within bias of `0`; both shared-resolvent
  values are within `3·10⁻⁴` of the exact `1` proved below.
Critique (Stage 4): the finite-sample `z`-scores are not formalised; the Chebotarev step
  (uniformity of Frobenius) and the Galois-theoretic step (compositum group is `S₃ × S₃` resp.
  `S₃ ×_{C₂} S₃`) are the standard modelling assumptions of the catalog and enter only through
  the choice of sample space.
-/
import Bridges.CharacterOneBit
import Shared.CyclicTypeChannelNonneg

namespace CyclicTypeChannel

open Finset

variable {α β γ : Type*}

section Independence

variable [DecidableEq β] [DecidableEq γ] {s : Finset α} {g : α → β} {k : α → γ}

/-- **Count independence**: the joint count table of `(g, k)` on `s` factorises,
`|s| · #{g = b, k = c} = #{g = b} · #{k = c}` — the uniform-measure form of `P(b, c) = P(b) P(c)`. -/
def CountIndep (s : Finset α) (g : α → β) (k : α → γ) : Prop :=
  ∀ b c, s.card * #{x ∈ s | g x = b ∧ k x = c} = #{x ∈ s | g x = b} * #{x ∈ s | k x = c}

/-- **Independence ⟹ zero mutual information** in the counting framework. -/
theorem mutInfo_eq_zero_of_countIndep (hs : s.Nonempty) (h : CountIndep s g k) :
    mutInfo s g k = 0 := by
  classical
  have hNpos : (0:ℝ) < s.card := by exact_mod_cast hs.card_pos
  have key : ∀ c ∈ s.image k,
      ((#{x ∈ s | k x = c} : ℝ) / s.card) * uEnt {x ∈ s | k x = c} g
        = (#{x ∈ s | k x = c} : ℝ) / s.card * Real.logb 2 s.card
          - (∑ a ∈ s with k a = c, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ)) / s.card := by
    intro c hc
    obtain ⟨a0, ha0, rfl⟩ := mem_image.1 hc
    set t := {x ∈ s | k x = k a0} with ht
    have htpos : (0:ℝ) < t.card := by
      exact_mod_cast card_pos.2 ⟨a0, by simp [ht, ha0]⟩
    have hfib : ∀ a ∈ t, Real.logb 2 (#{x ∈ t | g x = g a} : ℝ)
        = Real.logb 2 (#{x ∈ s | g x = g a} : ℝ) + Real.logb 2 t.card
          - Real.logb 2 s.card := by
      intro a ha
      have hc1 : #{x ∈ t | g x = g a} = #{x ∈ s | g x = g a ∧ k x = k a0} := by
        rw [ht, filter_filter]
        congr 1
        ext x
        simp [and_comm]
      have hmul := h (g a) (k a0)
      rw [← hc1] at hmul
      have hGpos : (0:ℝ) < #{x ∈ s | g x = g a} := by
        exact_mod_cast fiber_card_pos (mem_filter.1 ha).1
      have hmulR : (s.card : ℝ) * #{x ∈ t | g x = g a}
          = #{x ∈ s | g x = g a} * t.card := by exact_mod_cast hmul
      have : (#{x ∈ t | g x = g a} : ℝ) = #{x ∈ s | g x = g a} * t.card / s.card := by
        rw [eq_div_iff hNpos.ne']
        linarith
      rw [this, Real.logb_div (by positivity) hNpos.ne', Real.logb_mul hGpos.ne' htpos.ne']
    unfold uEnt
    rw [sum_congr rfl hfib, sum_sub_distrib, sum_add_distrib, sum_const, sum_const]
    simp only [nsmul_eq_mul]
    have htne : (t.card : ℝ) ≠ 0 := htpos.ne'
    field_simp
    ring
  unfold mutInfo condEnt
  rw [sum_congr rfl key, sum_sub_distrib, ← sum_div, ← sum_mul, ← sum_div,
    sum_fiberwise_of_maps_to (fun x hx => mem_image_of_mem k hx)]
  have hsum : ∑ c ∈ s.image k, (#{x ∈ s | k x = c} : ℝ) = s.card := by
    exact_mod_cast (card_eq_sum_card_image k s).symm
  rw [hsum, div_self hNpos.ne', uEnt]
  ring

omit [DecidableEq β] [DecidableEq γ] in
/-- Readouts of the two coordinates of a product sample space are count-independent. -/
theorem countIndep_product (s : Finset β) (t : Finset γ) {δ ε : Type*} [DecidableEq δ]
    [DecidableEq ε] (g : β → δ) (k : γ → ε) :
    CountIndep (s ×ˢ t) (fun x => g x.1) (fun x => k x.2) := by
  intro b c
  have h1 : #{x ∈ s ×ˢ t | g x.1 = b ∧ k x.2 = c} = #{x ∈ s | g x = b} * #{y ∈ t | k y = c} := by
    rw [← card_product, ← filter_product]
  have h2 : #{x ∈ s ×ˢ t | g x.1 = b} = #{x ∈ s | g x = b} * t.card := by
    rw [← card_product, ← filter_product_left]
  have h3 : #{x ∈ s ×ˢ t | k x.2 = c} = s.card * #{y ∈ t | k y = c} := by
    rw [← card_product, ← filter_product_right]
  rw [h1, h2, h3, card_product]
  ring

omit [DecidableEq β] [DecidableEq γ] in
/-- Linearly disjoint dials: on a product sample space, readouts of the two coordinates share
no information. -/
theorem mutInfo_product_marginals {δ ε : Type*} [DecidableEq δ] [DecidableEq ε]
    {s : Finset β} {t : Finset γ} (hs : s.Nonempty) (ht : t.Nonempty) (g : β → δ) (k : γ → ε) :
    mutInfo (s ×ˢ t) (fun x => g x.1) (fun x => k x.2) = 0 :=
  mutInfo_eq_zero_of_countIndep (hs.product ht) (countIndep_product s t g k)

/-- Group form: for any two finite Galois groups `G`, `H` (the Galois group of a linearly
disjoint compositum is `G × H`), any two splitting-type readouts are independent. -/
theorem mutInfo_group_product_eq_zero {G H δ ε : Type*} [Fintype G] [Fintype H] [Nonempty G]
    [Nonempty H] [DecidableEq δ] [DecidableEq ε] (T₁ : G → δ) (T₂ : H → ε) :
    mutInfo (univ : Finset (G × H)) (fun x => T₁ x.1) (fun x => T₂ x.2) = 0 := by
  rw [← univ_product_univ]
  exact mutInfo_product_marginals univ_nonempty univ_nonempty T₁ T₂

/-- Entropy only sees the fibres: two readouts inducing the same partition of `s` have the
same entropy. -/
lemma uEnt_congr_fibres {δ ε : Type*} [DecidableEq δ] [DecidableEq ε] (s : Finset α)
    (g : α → δ) (g' : α → ε) (h : ∀ x ∈ s, ∀ y ∈ s, g x = g y ↔ g' x = g' y) :
    uEnt s g = uEnt s g' := by
  unfold uEnt
  congr 2
  refine sum_congr rfl fun a ha => ?_
  congr 3
  exact filter_congr fun x hx => h x hx a ha

omit [DecidableEq β] [DecidableEq γ] in
/-- **Additivity of entropy** on a product sample space. -/
theorem uEnt_product {δ ε : Type*} [DecidableEq δ] [DecidableEq ε] {s : Finset β}
    {t : Finset γ} (hs : s.Nonempty) (ht : t.Nonempty) (g : β → δ) (k : γ → ε) :
    uEnt (s ×ˢ t) (fun x => (g x.1, k x.2)) = uEnt s g + uEnt t k := by
  have hS : (0:ℝ) < s.card := by exact_mod_cast hs.card_pos
  have hT : (0:ℝ) < t.card := by exact_mod_cast ht.card_pos
  have hfib : ∀ x ∈ s ×ˢ t, (#{y ∈ s ×ˢ t | (g y.1, k y.2) = (g x.1, k x.2)} : ℝ)
      = (#{a ∈ s | g a = g x.1} : ℝ) * #{b ∈ t | k b = k x.2} := by
    intro x _
    rw [← Nat.cast_mul, ← card_product, ← filter_product]
    simp only [Prod.mk.injEq]
  have hlog : ∀ x ∈ s ×ˢ t,
      Real.logb 2 (#{y ∈ s ×ˢ t | (g y.1, k y.2) = (g x.1, k x.2)} : ℝ)
        = Real.logb 2 (#{a ∈ s | g a = g x.1} : ℝ)
          + Real.logb 2 (#{b ∈ t | k b = k x.2} : ℝ) := by
    intro x hx
    rw [hfib x hx, Real.logb_mul]
    · exact_mod_cast (fiber_card_pos (mem_product.1 hx).1).ne'
    · exact_mod_cast (fiber_card_pos (mem_product.1 hx).2).ne'
  unfold uEnt
  rw [sum_congr rfl hlog, sum_add_distrib, sum_product, sum_product_right]
  dsimp only
  simp only [Finset.sum_const, nsmul_eq_mul, card_product, Nat.cast_mul]
  rw [Real.logb_mul hS.ne' hT.ne', ← Finset.mul_sum, ← Finset.mul_sum]
  field_simp
  ring

omit [DecidableEq β] [DecidableEq γ] in
/-- The marginal of a product sample space: `H(g ∘ fst) = H(g)`. -/
theorem uEnt_product_fst {δ : Type*} [DecidableEq δ] {s : Finset β} {t : Finset γ}
    (hs : s.Nonempty) (ht : t.Nonempty) (g : β → δ) :
    uEnt (s ×ˢ t) (fun x => g x.1) = uEnt s g := by
  have h := uEnt_product hs ht g (fun _ => ())
  have h0 : uEnt t (fun _ : γ => ()) = 0 := uEnt_eq_zero_of_const fun _ _ _ _ => rfl
  rw [h0, add_zero] at h
  rw [← h]
  apply uEnt_congr_fibres
  intro x _ y _
  simp

omit [DecidableEq β] [DecidableEq γ] in
/-- **Additivity of mutual information** over independent blocks. -/
theorem mutInfo_product {δ₁ δ₂ ε₁ ε₂ : Type*} [DecidableEq δ₁] [DecidableEq δ₂]
    [DecidableEq ε₁] [DecidableEq ε₂] {s : Finset β} {t : Finset γ}
    (hs : s.Nonempty) (ht : t.Nonempty)
    (g₁ : β → δ₁) (k₁ : β → ε₁) (g₂ : γ → δ₂) (k₂ : γ → ε₂) :
    mutInfo (s ×ˢ t) (fun x => (g₁ x.1, g₂ x.2)) (fun x => (k₁ x.1, k₂ x.2))
      = mutInfo s g₁ k₁ + mutInfo t g₂ k₂ := by
  have hst : (s ×ˢ t).Nonempty := hs.product ht
  rw [mutInfo, mutInfo, mutInfo, condEnt_eq_joint_sub hst, condEnt_eq_joint_sub hs,
    condEnt_eq_joint_sub ht]
  have hj : uEnt (s ×ˢ t) (fun x => ((g₁ x.1, g₂ x.2), (k₁ x.1, k₂ x.2)))
      = uEnt s (fun a => (g₁ a, k₁ a)) + uEnt t (fun b => (g₂ b, k₂ b)) := by
    rw [← uEnt_product hs ht]
    apply uEnt_congr_fibres
    intro x _ y _
    simp only [Prod.mk.injEq]
    tauto
  rw [hj, uEnt_product hs ht, uEnt_product hs ht]
  ring

end Independence

/-! ## Data processing and the shared-resolvent lower bound -/

section DataProcessing

variable [DecidableEq β] [DecidableEq γ]

/-- **Conditioning on less can only increase uncertainty**: if `h ∘ g` is a coarsening of `g`,
then `H(k | g) ≤ H(k | h ∘ g)`. -/
theorem condEnt_le_condEnt_comp {δ : Type*} [DecidableEq δ] (s : Finset α) (k : α → β)
    (g : α → γ) (h : γ → δ) : condEnt s k g ≤ condEnt s k (fun x => h (g x)) := by
  classical
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [condEnt]
  -- fibrewise Gibbs inequality
  have hfib : ∀ c ∈ s.image (fun x => h (g x)),
      ((#{x ∈ s | h (g x) = c} : ℝ) / s.card) *
          (uEnt {x ∈ s | h (g x) = c} (fun x => (k x, g x)) - uEnt {x ∈ s | h (g x) = c} g)
        ≤ ((#{x ∈ s | h (g x) = c} : ℝ) / s.card) * uEnt {x ∈ s | h (g x) = c} k := by
    intro c hc
    obtain ⟨a, ha, rfl⟩ := mem_image.1 hc
    have ht : ({x ∈ s | h (g x) = h (g a)} : Finset α).Nonempty := ⟨a, by simp [ha]⟩
    have h1 := mutInfo_nonneg {x ∈ s | h (g x) = h (g a)} k g
    rw [mutInfo, condEnt_eq_joint_sub ht] at h1
    exact mul_le_mul_of_nonneg_left (by linarith) (by positivity)
  have hsum := sum_le_sum hfib
  simp only [mul_sub, sum_sub_distrib] at hsum
  have e1 : ∑ c ∈ s.image (fun x => h (g x)), ((#{x ∈ s | h (g x) = c} : ℝ) / s.card) *
      uEnt {x ∈ s | h (g x) = c} (fun x => (k x, g x))
      = uEnt s (fun x => (k x, g x)) - uEnt s (fun x => h (g x)) := by
    have := condEnt_eq_joint_sub hs (fun x => (k x, g x)) (fun x => h (g x))
    rw [condEnt] at this
    rw [this, uEnt_congr_fibres s (fun a => ((k a, g a), h (g a))) (fun x => (k x, g x))]
    intro x _ y _
    simp only [Prod.mk.injEq]
    constructor
    · exact fun h => h.1
    · rintro ⟨h1, h2⟩; exact ⟨⟨h1, h2⟩, by rw [h2]⟩
  have e2 : ∑ c ∈ s.image (fun x => h (g x)), ((#{x ∈ s | h (g x) = c} : ℝ) / s.card) *
      uEnt {x ∈ s | h (g x) = c} g = uEnt s g - uEnt s (fun x => h (g x)) := by
    have := condEnt_eq_joint_sub hs g (fun x => h (g x))
    rw [condEnt] at this
    rw [this, uEnt_congr_fibres s (fun a => (g a, h (g a))) g]
    intro x _ y _
    simp only [Prod.mk.injEq]
    constructor
    · exact fun h => h.1
    · intro h1; exact ⟨h1, by rw [h1]⟩
  rw [e1, e2] at hsum
  rw [condEnt_eq_joint_sub hs]
  unfold condEnt
  linarith

/-- **Data processing inequality** (right argument). -/
theorem mutInfo_comp_right_le {δ : Type*} [DecidableEq δ] (s : Finset α) (k : α → β)
    (g : α → γ) (h : γ → δ) : mutInfo s k (fun x => h (g x)) ≤ mutInfo s k g := by
  unfold mutInfo
  linarith [condEnt_le_condEnt_comp s k g h]

/-- **Data processing inequality** (left argument). -/
theorem mutInfo_comp_left_le {δ : Type*} [DecidableEq δ] (s : Finset α) (g : α → β)
    (h : β → δ) (k : α → γ) : mutInfo s (fun x => h (g x)) k ≤ mutInfo s g k := by
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [mutInfo, condEnt, uEnt]
  rw [mutInfo_comm hs, mutInfo_comm hs g]
  exact mutInfo_comp_right_le s k g h

end DataProcessing

section FibreProduct

variable {G H C : Type*} [Group G] [Fintype G] [Group H] [Fintype H] [Group C] [Fintype C]
  [DecidableEq C]

/-- The fibre product `G ×_C H` of two groups over a common quotient `C`: the Galois group of
the compositum of two fields sharing the subfield cut out by `C`. -/
def fibreProd (χ₁ : G →* C) (χ₂ : H →* C) : Finset (G × H) := {x | χ₁ x.1 = χ₂ x.2}

omit [Fintype C] in
/-- The fibre of the common character on `G ×_C H` is a product of character fibres. -/
lemma fibreProd_fibre (χ₁ : G →* C) (χ₂ : H →* C) (c : C) :
    ({x ∈ fibreProd χ₁ χ₂ | χ₁ x.1 = c} : Finset (G × H))
      = ({a : G | χ₁ a = c} : Finset G) ×ˢ ({b : H | χ₂ b = c} : Finset H) := by
  ext ⟨a, b⟩
  simp only [fibreProd, mem_filter, mem_univ, true_and, mem_product]
  constructor
  · rintro ⟨h1, h2⟩; exact ⟨h2, h1 ▸ h2⟩
  · rintro ⟨h1, h2⟩; exact ⟨h1.trans h2.symm, h1⟩

/-- Over a two-element quotient with surjective characters, each value of the common character
takes exactly half of the fibre product. -/
theorem fibreProd_balanced (χ₁ : G →* C) (χ₂ : H →* C) (h₁ : Function.Surjective χ₁)
    (h₂ : Function.Surjective χ₂) (hC : Fintype.card C = 2) (c : C) :
    2 * #{x ∈ fibreProd χ₁ χ₂ | χ₁ x.1 = c} = #(fibreProd χ₁ χ₂) := by
  classical
  obtain ⟨a₀, rfl⟩ := h₁ c
  obtain ⟨b₀, hb₀⟩ := h₂ (χ₁ a₀)
  have hfib : ∀ c' : C, #{x ∈ fibreProd χ₁ χ₂ | χ₁ x.1 = c'}
      = #{a : G | χ₁ a = χ₁ a₀} * #{b : H | χ₂ b = χ₂ b₀} := by
    intro c'
    rw [fibreProd_fibre, card_product]
    congr 1
    · exact MonoidHom.card_fiber_eq_of_mem_range χ₁ (h₁ c') ⟨a₀, rfl⟩
    · exact MonoidHom.card_fiber_eq_of_mem_range χ₂ (h₂ c') ⟨b₀, rfl⟩
  have hsum : #(fibreProd χ₁ χ₂) = ∑ c' : C, #{x ∈ fibreProd χ₁ χ₂ | χ₁ x.1 = c'} :=
    card_eq_sum_card_fiberwise (fun x _ => mem_univ (χ₁ x.1))
  rw [hsum, sum_congr rfl fun c' _ => hfib c', sum_const, card_univ, hC, smul_eq_mul, hfib]

/-- **Shared resolvent forces at least one bit of cross-talk.**  Let two fields have Galois
groups `G`, `H` whose quadratic characters `χ₁`, `χ₂` cut out the *same* quadratic field, so that
the compositum has group `G ×_C H`.  If each splitting-type read-out determines its character,
then the two splitting types share at least one bit. -/
theorem one_le_mutInfo_fibreProd {β γ : Type*} [DecidableEq β] [DecidableEq γ]
    (χ₁ : G →* C) (χ₂ : H →* C) (h₁ : Function.Surjective χ₁) (h₂ : Function.Surjective χ₂)
    (hC : Fintype.card C = 2) (T₁ : G → β) (T₂ : H → γ) (f₁ : β → C) (f₂ : γ → C)
    (hf₁ : ∀ a, χ₁ a = f₁ (T₁ a)) (hf₂ : ∀ b, χ₂ b = f₂ (T₂ b)) :
    1 ≤ mutInfo (fibreProd χ₁ χ₂) (fun x => T₁ x.1) (fun x => T₂ x.2) := by
  have hne : (fibreProd χ₁ χ₂).Nonempty := ⟨(1, 1), by simp [fibreProd]⟩
  have hone : mutInfo (fibreProd χ₁ χ₂) (fun x => f₁ (T₁ x.1)) (fun x => f₂ (T₂ x.2)) = 1 := by
    rw [mutInfo_comm hne]
    refine mutInfo_eq_one_of_refines_balanced hne ?_ ?_
    · intro x hx y hy hxy
      have hx' : χ₁ x.1 = χ₂ x.2 := (mem_filter.1 hx).2
      have hy' : χ₁ y.1 = χ₂ y.2 := (mem_filter.1 hy).2
      rw [← hf₁, ← hf₁, hx', hy', hf₂, hf₂, hxy]
    · intro a _
      have hfe : ∀ x ∈ fibreProd χ₁ χ₂,
          (f₁ (T₁ x.1) = f₁ (T₁ a.1) ↔ χ₁ x.1 = χ₁ a.1) := by
        intro x _; rw [hf₁, hf₁]
      rw [filter_congr hfe]
      exact fibreProd_balanced χ₁ χ₂ h₁ h₂ hC _
  have s1 := mutInfo_comp_left_le (fibreProd χ₁ χ₂) (fun x => T₁ x.1) f₁
    (fun x => f₂ (T₂ x.2))
  have s2 := mutInfo_comp_right_le (fibreProd χ₁ χ₂) (fun x => T₁ x.1) (fun x => T₂ x.2) f₂
  linarith

end FibreProduct

namespace S3

open Equiv Equiv.Perm

/-- The Galois group `S₃` of a single cubic. -/
abbrev P3 := Perm (Fin 3)

/-- **THE-DIALS-ARE-INDEPENDENT.**  For two cubics with coprime discriminants the Frobenius pair
is uniform on `S₃ × S₃` and the two splitting types share exactly `0` bits. -/
theorem mutInfo_dials_indep :
    mutInfo ((univ : Finset P3) ×ˢ (univ : Finset P3))
      (fun x => splitType x.1) (fun x => splitType x.2) = 0 :=
  mutInfo_product_marginals univ_nonempty univ_nonempty _ _

/-- The fibre product `S₃ ×_{C₂} S₃`: the Galois group of the compositum of two non-isomorphic
cubic fields with the *same* quadratic resolvent (e.g. `x³ - 2` and `x³ - 3`). -/
def sharedQuad : Finset (P3 × P3) := {x | sign x.1 = sign x.2}

set_option maxHeartbeats 4000000 in
/-- `|S₃ ×_{C₂} S₃| = 18`. -/
theorem card_sharedQuad : #sharedQuad = 18 := by decide

/-- `log₂ 18 = 1 + 2 log₂ 3`. -/
lemma lb_18 : Real.logb 2 (18 : ℝ) = 1 + 2 * Real.logb 2 3 := by
  rw [show (18 : ℝ) = 2 * 9 by norm_num, Real.logb_mul (by norm_num) (by norm_num),
    Real.logb_self_eq_one (by norm_num), lb_9]

set_option maxHeartbeats 4000000 in
/-- Sharing the quadratic subfield does not change a single dial: the marginal of the first
splitting type on `S₃ ×_{C₂} S₃` is still the Chebotarev law `(1/6, 1/2, 1/3)`. -/
theorem uEnt_sharedQuad_fst :
    uEnt sharedQuad (fun x => splitType x.1) = 2 / 3 + Real.logb 2 3 / 2 := by
  have hcount : (sharedQuad.image (fun x => splitType x.1)).val.map
      (fun v => (#{x ∈ sharedQuad | splitType x.1 = v} : ℕ)) = ({3, 9, 6} : Multiset ℕ) := by
    decide
  rw [uEnt_eq_countSum _ _ _ hcount, card_sharedQuad]
  simp only [Multiset.insert_eq_cons, Multiset.map_cons, Multiset.sum_cons,
    Multiset.map_singleton, Multiset.sum_singleton, Nat.cast_ofNat]
  rw [lb_18, lb_9, lb_6]
  ring

set_option maxHeartbeats 4000000 in
/-- All three splitting types occur for the second cubic. -/
theorem image_sharedQuad_snd :
    sharedQuad.image (fun x => splitType x.2) = {{1, 1, 1}, {2, 1}, {3}} := by decide

set_option maxHeartbeats 4000000 in
/-- `H(T₁ | T₂) = (log₂ 3)/2 - 1/3` on the fibre product. -/
theorem condEnt_sharedQuad :
    condEnt sharedQuad (fun x => splitType x.1) (fun x => splitType x.2)
      = Real.logb 2 3 / 2 - 1 / 3 := by
  unfold condEnt
  rw [image_sharedQuad_snd, sum_insert (by decide), sum_insert (by decide), sum_singleton]
  have c1 : #{x ∈ sharedQuad | splitType x.2 = {1, 1, 1}} = 3 := by decide
  have c2 : #{x ∈ sharedQuad | splitType x.2 = {2, 1}} = 9 := by decide
  have c3 : #{x ∈ sharedQuad | splitType x.2 = {3}} = 6 := by decide
  have u1 : uEnt {x ∈ sharedQuad | splitType x.2 = {1, 1, 1}} (fun x => splitType x.1)
      = Real.logb 2 3 - 2 / 3 := by
    rw [uEnt_eq_countSum _ _ ({1, 2} : Multiset ℕ) (by decide), c1]
    simp only [Multiset.insert_eq_cons, Multiset.map_cons, Multiset.sum_cons,
      Multiset.map_singleton, Multiset.sum_singleton, Nat.cast_ofNat, Nat.cast_one]
    rw [Real.logb_one, Real.logb_self_eq_one (by norm_num)]
    ring
  have u2 : uEnt {x ∈ sharedQuad | splitType x.2 = {2, 1}} (fun x => splitType x.1) = 0 :=
    uEnt_eq_zero_of_const (by decide)
  have u3 : uEnt {x ∈ sharedQuad | splitType x.2 = {3}} (fun x => splitType x.1)
      = Real.logb 2 3 - 2 / 3 := by
    rw [uEnt_eq_countSum _ _ ({2, 4} : Multiset ℕ) (by decide), c3]
    simp only [Multiset.insert_eq_cons, Multiset.map_cons, Multiset.sum_cons,
      Multiset.map_singleton, Multiset.sum_singleton, Nat.cast_ofNat]
    rw [lb_6, lb_4, Real.logb_self_eq_one (by norm_num)]
    ring
  rw [c1, c2, c3, u1, u2, u3, card_sharedQuad]
  push_cast
  ring

/-- **Cross-talk is exactly one bit** when the two cubics share their quadratic resolvent:
`I(T₁ ; T₂) = 1` on `S₃ ×_{C₂} S₃`. -/
theorem mutInfo_sharedQuad :
    mutInfo sharedQuad (fun x => splitType x.1) (fun x => splitType x.2) = 1 := by
  rw [mutInfo, uEnt_sharedQuad_fst, condEnt_sharedQuad]
  ring

set_option maxHeartbeats 4000000 in
/-- The shared-resolvent pair is genuinely dependent: its joint count table does not factor
(no prime is `'12'` for one cubic and `'111'` for the other). -/
theorem not_countIndep_sharedQuad :
    ¬ CountIndep sharedQuad (fun x => splitType x.1) (fun x => splitType x.2) := by
  intro h
  have h1 := h {2, 1} {1, 1, 1}
  have e1 : #{x ∈ sharedQuad | splitType x.1 = {2, 1} ∧ splitType x.2 = {1, 1, 1}} = 0 := by
    decide
  have e2 : #{x ∈ sharedQuad | splitType x.1 = {2, 1}} = 9 := by decide
  have e3 : #{x ∈ sharedQuad | splitType x.2 = {1, 1, 1}} = 3 := by decide
  rw [e1, e2, e3] at h1
  omega

/-- The concrete fibre product is the abstract one for the sign characters. -/
theorem sharedQuad_eq_fibreProd : sharedQuad = fibreProd (sign : P3 →* ℤˣ) sign := rfl

/-- The general lower bound specialised to the two cubics, and its **sharpness**:
`1 ≤ I(T₁ ; T₂)` follows from data processing alone, and the exact computation shows equality. -/
theorem mutInfo_sharedQuad_bound_sharp :
    1 ≤ mutInfo sharedQuad (fun x => splitType x.1) (fun x => splitType x.2) ∧
      mutInfo sharedQuad (fun x => splitType x.1) (fun x => splitType x.2) = 1 := by
  refine ⟨?_, mutInfo_sharedQuad⟩
  rw [sharedQuad_eq_fibreProd]
  exact one_le_mutInfo_fibreProd sign sign (sign_surjective _) (sign_surjective _) (by decide)
    splitType splitType signOfType signOfType sign_eq_signOfType sign_eq_signOfType

/-- **The dichotomy.**  For coprime discriminants (Galois group `S₃ × S₃`) the dials carry
`0` bits about each other; for a shared quadratic resolvent (`S₃ ×_{C₂} S₃`) exactly `1`. -/
theorem crossTalk_dichotomy :
    mutInfo ((univ : Finset P3) ×ˢ (univ : Finset P3))
        (fun x => splitType x.1) (fun x => splitType x.2) = 0 ∧
      mutInfo sharedQuad (fun x => splitType x.1) (fun x => splitType x.2) = 1 :=
  ⟨mutInfo_dials_indep, mutInfo_sharedQuad⟩

/-! ### Semiprimes `N = p q`

The pair read-out of a semiprime is `(T(p), T(q))`.  With `p`, `q` independent Frobenius draws
the sample space is a product of two copies of the compositum group. -/

/-- **Semiprime independence**: `I(pair₁ ; pair₂) = 0` for coprime discriminants. -/
theorem mutInfo_semiprime_indep :
    mutInfo (((univ : Finset P3) ×ˢ (univ : Finset P3)) ×ˢ
        ((univ : Finset P3) ×ˢ (univ : Finset P3)))
      (fun x => (splitType x.1.1, splitType x.2.1))
      (fun x => (splitType x.1.2, splitType x.2.2)) = 0 := by
  have h := mutInfo_product (univ_nonempty.product univ_nonempty)
    (univ_nonempty.product univ_nonempty)
    (fun y : P3 × P3 => splitType y.1) (fun y : P3 × P3 => splitType y.2)
    (fun y : P3 × P3 => splitType y.1) (fun y : P3 × P3 => splitType y.2)
  refine h.trans ?_
  rw [mutInfo_dials_indep]
  norm_num

/-- **Semiprime cross-talk doubles**: with a shared resolvent, `I(pair₁ ; pair₂) = 2` bits. -/
theorem mutInfo_semiprime_shared :
    mutInfo (sharedQuad ×ˢ sharedQuad)
      (fun x => (splitType x.1.1, splitType x.2.1))
      (fun x => (splitType x.1.2, splitType x.2.2)) = 2 := by
  have hne : sharedQuad.Nonempty := ⟨(1, 1), by simp [sharedQuad]⟩
  have h := mutInfo_product hne hne
    (fun y : P3 × P3 => splitType y.1) (fun y : P3 × P3 => splitType y.2)
    (fun y : P3 × P3 => splitType y.1) (fun y : P3 × P3 => splitType y.2)
  refine h.trans ?_
  rw [mutInfo_sharedQuad]
  norm_num

/-- Knowing the other dial leaves the full Chebotarev entropy: `H(T₁ | T₂) = H(T₁)`. -/
theorem condEnt_dials_indep :
    condEnt ((univ : Finset P3) ×ˢ (univ : Finset P3))
      (fun x => splitType x.1) (fun x => splitType x.2) = 2 / 3 + Real.logb 2 3 / 2 := by
  have h := mutInfo_dials_indep
  rw [mutInfo, uEnt_product_fst univ_nonempty univ_nonempty, uEnt_splitType] at h
  linarith

/-- The semiprime pair read-out keeps its entropy under a shared resolvent:
`H(pair₁) = 4/3 + log₂ 3` on `(S₃ ×_{C₂} S₃)²`. -/
theorem uEnt_semiprime_shared_pair :
    uEnt (sharedQuad ×ˢ sharedQuad) (fun x => (splitType x.1.1, splitType x.2.1))
      = 4 / 3 + Real.logb 2 3 := by
  have hne : sharedQuad.Nonempty := ⟨(1, 1), by simp [sharedQuad]⟩
  rw [uEnt_product hne hne (fun y : P3 × P3 => splitType y.1) (fun y : P3 × P3 => splitType y.1),
    uEnt_sharedQuad_fst]
  ring

/-- The joint entropy of the two independent dials is the sum: `H(T₁, T₂) = 4/3 + log₂ 3`. -/
theorem uEnt_dial_pair :
    uEnt ((univ : Finset P3) ×ˢ (univ : Finset P3))
      (fun x => (splitType x.1, splitType x.2)) = 4 / 3 + Real.logb 2 3 := by
  rw [uEnt_product univ_nonempty univ_nonempty, uEnt_splitType]
  ring

end S3

end CyclicTypeChannel