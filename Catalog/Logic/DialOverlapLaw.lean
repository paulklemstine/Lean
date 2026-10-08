/-
# DIAL-OVERLAP-LAW: partially overlapping dials are exactly one bit redundant
(FACT round-37 #5, exp 462, paper 133)

Two fields whose Galois groups `G`, `H` restrict surjectively onto a common quotient `C`
(the Galois group of a shared subfield) have compositum group the fibre product `G ×_C H`
(`fibreProd χ₁ χ₂` of `Catalog.Bridges.DialCrossTalk`).  By Chebotarev the Frobenius pair of an
unramified prime is uniform on `G ×_C H`; every statement below lives in the counting-entropy
framework `uEnt` / `condEnt` / `mutInfo` of `Catalog.Shared.CyclicTypeChannel`.

## Main results

Abstract information theory (any finite uniform source)
* `mutInfo_eq_uEnt_label` — **the abstract overlap law**: if two readouts both determine a label
  `κ` and are fibrewise independent given `κ`, then `I(g ; k) = H(κ)` *exactly*.
* `mutInfo_le_uEnt_label` — **the overlap ceiling**: fibrewise independence alone already forces
  `I(g ; k) ≤ H(κ)`, whatever the readouts.
* `uEnt_eq_logb_of_uniform` — a label with `m` equal fibres carries `log₂ m` bits.

Fibre products (two fields sharing a subfield)
* `fibreProd_split`, `mutInfo_fibreProd_fibre_eq_zero` — given the shared character the two
  coordinates are an honest product: **all correlation beyond the shared character is zero**.
* `card_fibreProd_mul` — `|C| · |G ×_C H| = |G| · |H|` (so `|S₃ ×_{C₂} S₃| = 18`).
* `mutInfo_fibreProd_eq_logb_card` — **THE OVERLAP LAW**: character-determining readouts share
  exactly `log₂ |C|` bits; `mutInfo_fibreProd_le_logb_card` — *no* readouts share more.
* `mutInfo_sharedQuadratic_eq_one` — **PARTIAL-OVERLAP-LAW**: sharing a quadratic subfield costs
  exactly one bit, for arbitrary finite Galois groups.
* `mutInfo_perm_sharedSign_eq_one` — the law for `Sₙ ×_{C₂} Sₘ` and cycle types, all `n, m ≥ 2`.
* `mutInfo_fibreProd_trivial_eq_zero`, `mutInfo_fibreProd_diag_eq_logb`, `overlap_ladder_bounds`
  — the ladder: trivial overlap `0`, shared quotient `C` at most/exactly `log₂ |C|`, same field
  `log₂ |G|` for full Frobenius readouts.

The `S₃` pairs of exp 462
* `S3.mutInfo_sharedQuad_by_law` — `I(T₁ ; T₂) = 1` derived from the law (not by enumeration);
  `S3.card_sharedQuad_by_law` — order `18` from the order formula.
* `S3.sharedQuad_joint_table` — the joint Chebotarev table `1 : 2 : 2 : 4 : 9`.
* `S3.typeAgree_sharedQuad` (`14/18 = 7/9`, off-diagonal `4/18`), `S3.typeAgree_sameField`
  (`6/6`), `S3.typeAgree_coprime` (`14/36 = 7/18`), `S3.typeAgree_sharedQuad_fibres` (agreement
  `9/9` on `χ = -1`, `5/9` on the residue-invisible `χ = +1` fibre).
* `S3.L11_sign_blind_type_discriminates` — **insight L11**: the sign (residue-visible) mutual
  information is `1` bit for both the partial-overlap and the same-field pair, while type
  agreement and full-type redundancy (`1` vs `2/3 + (log₂ 3)/2`) tell them apart.
* `S3.overlap_ladder_S3` — `0 / 1 / H(T)` bits for coprime / shared-subfield / same-field.

A second family
* `Quartic.mutInfo_quarticPair`, `Quartic.uEnt_quarticPair_deg`,
  `Quartic.condEnt_quarticPair_deg` — two cyclic quartic fields sharing their quadratic subfield
  (`C₄ ×_{C₂} C₄`): residue degrees share exactly `1 = 3/2 - 1/2` bit.

Three dials over one shared subfield (second loop)
* `fibreProd3`, `fibreProd3_uniform`, `mutInfo3_12`, `mutInfo3_13`, `mutInfo3_23`,
  `mutInfo3_1_23` — every pair, and each dial against the other two jointly, shares exactly
  `log₂ |C|` bits.
* `totalCorrelation3` — total correlation exactly `2 log₂ |C|`; `coInformation3` — co-information
  exactly `+log₂ |C|` (pure redundancy); `S3.threeDials_S3` — `2` bits and `+1` bit for three
  `S₃` cubics with one common quadratic resolvent.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the measured deficits `+0.9998 / +0.9998 / +1.0000` are finite-sample
  scatter around an exact `1`; the redundancy of two fields is the entropy of their shared Galois
  quotient, because given that quotient the fibre product is a direct product.
Experiment (Stage 2, independent re-run, primes `7 < p < 60000` unramified in both cubics,
  splitting type from the number of roots mod `p`, plug-in mutual information):
  * `x³-5x-5` & `x³-3x-5` (`d = -7`): `n = 6053`, `I = 1.0000` bits, type agreement `0.7816`
    (law `7/9 = 0.7778`), table `111/111: 329, 111/3: 664, 3/111: 658, 3/3: 1369, 12/12: 3033`,
    all `12`-mixed cells `0` (law `1:2:2:4:9` predicts `336, 673, 673, 1345, 3027`).
  * `x³-6x-6` & `x³-3` (`d = -3`): `n = 6053`, `I = 1.0000`, agreement `0.7785`, off-diagonal
    `1341` (law `2/9 · 6053 = 1345`).
  * control `x³+x+1` & `x³-x-1` (coprime): `n = 6051`, `I = 0.0001`, agreement `0.3889`
    (law `7/18 = 0.3889`).
  * control same field (`x³-5x-5` twice): `I = 1.4559` (law `H(T) = 1.4591`), agreement `1`.
Analysis (Stage 3): all values sit on the formal predictions; the shared-subfield table has only
  five structurally non-zero cells, which is why plug-in bias is negligible here.
Critique (Stage 4): Chebotarev uniformity and the identification of the compositum group as a
  fibre product are modelling assumptions entering only through the choice of sample space; the
  finite-sample statistics are not formalised.
-/
import Bridges.DialCrossTalk

namespace CyclicTypeChannel

open Finset

variable {α β γ C : Type*}

section Abstract

variable [DecidableEq β] [DecidableEq γ] [DecidableEq C] {s : Finset α}

/-- A readout `g` *determines* the label `κ` on `s` if equal readouts force equal labels. -/
def Determines (s : Finset α) (g : α → β) (κ : α → C) : Prop :=
  ∀ x ∈ s, ∀ y ∈ s, g x = g y → κ x = κ y

/-- Chain rule along a determined label: `H(g) = H(κ) + H(g | κ)`. -/
theorem uEnt_eq_label_add_condEnt (hs : s.Nonempty) {g : α → β} {κ : α → C}
    (hdet : Determines s g κ) : uEnt s g = uEnt s κ + condEnt s g κ := by
  rw [condEnt_eq_joint_sub hs g κ]
  have : uEnt s (fun a => (g a, κ a)) = uEnt s g := by
    refine uEnt_congr_fibres s _ _ fun x hx y hy => ?_
    constructor
    · intro h; exact (Prod.mk.inj h).1
    · intro h; rw [h, hdet x hx y hy h]
  rw [this]; ring

/-- If on every fibre of `κ` the joint entropy of `(g, k)` splits, then so does the
conditional entropy given `κ`. -/
theorem condEnt_pair_of_fibrewise {g : α → β} {k : α → γ} {κ : α → C}
    (hsplit : ∀ c, uEnt {x ∈ s | κ x = c} (fun a => (g a, k a))
      = uEnt {x ∈ s | κ x = c} g + uEnt {x ∈ s | κ x = c} k) :
    condEnt s (fun a => (g a, k a)) κ = condEnt s g κ + condEnt s k κ := by
  unfold condEnt
  rw [← sum_add_distrib]
  refine sum_congr rfl fun c _ => ?_
  rw [hsplit c]; ring

/-- **The abstract overlap law.**  If both readouts determine a common label `κ`, and the readouts
are fibrewise independent given `κ` (joint entropy splits on every fibre), then the information the
two readouts share is *exactly* the entropy of the shared label: `I(g ; k) = H(κ)`. -/
theorem mutInfo_eq_uEnt_label (hs : s.Nonempty) {g : α → β} {k : α → γ} {κ : α → C}
    (hg : Determines s g κ) (hk : Determines s k κ)
    (hsplit : ∀ c, uEnt {x ∈ s | κ x = c} (fun a => (g a, k a))
      = uEnt {x ∈ s | κ x = c} g + uEnt {x ∈ s | κ x = c} k) :
    mutInfo s g k = uEnt s κ := by
  have hgk : Determines s (fun a => (g a, k a)) κ := fun x hx y hy h =>
    hg x hx y hy (Prod.mk.inj h).1
  have e1 := uEnt_eq_label_add_condEnt hs hg
  have e2 := uEnt_eq_label_add_condEnt hs hk
  have e3 := uEnt_eq_label_add_condEnt hs hgk
  have e4 := condEnt_pair_of_fibrewise (s := s) hsplit
  have e5 := condEnt_eq_joint_sub hs g k
  rw [mutInfo, e5]
  linarith

/-- A label all of whose fibres have size `|s| / m` carries exactly `log₂ m` bits. -/
theorem uEnt_eq_logb_of_uniform (hs : s.Nonempty) {κ : α → C} {m : ℕ} (hm : 0 < m)
    (hbal : ∀ a ∈ s, m * #{x ∈ s | κ x = κ a} = s.card) :
    uEnt s κ = Real.logb 2 m := by
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  have hmR : (0 : ℝ) < m := by exact_mod_cast hm
  have hterm : ∀ a ∈ s, Real.logb 2 (#{x ∈ s | κ x = κ a} : ℝ)
      = Real.logb 2 (s.card : ℝ) - Real.logb 2 m := by
    intro a ha
    have h : (#{x ∈ s | κ x = κ a} : ℝ) = (s.card : ℝ) / m := by
      have : (m : ℝ) * (#{x ∈ s | κ x = κ a} : ℝ) = (s.card : ℝ) := by exact_mod_cast hbal a ha
      field_simp
      linarith
    rw [h, Real.logb_div (ne_of_gt hN) (ne_of_gt hmR)]
  rw [uEnt, Finset.sum_congr rfl hterm, Finset.sum_const, nsmul_eq_mul]
  field_simp
  ring

/-- **The overlap ceiling.**  If two readouts are fibrewise independent given a label `κ`, they
can never share more than `H(κ)` bits — whether or not they determine `κ`. -/
theorem mutInfo_le_uEnt_label (hs : s.Nonempty) (g : α → β) (k : α → γ) (κ : α → C)
    (hsplit : ∀ c, uEnt {x ∈ s | κ x = c} (fun a => (g a, k a))
      = uEnt {x ∈ s | κ x = c} g + uEnt {x ∈ s | κ x = c} k) :
    mutInfo s g k ≤ uEnt s κ := by
  have hfibconst : ∀ c, ∀ x ∈ {x ∈ s | κ x = c}, ∀ y ∈ {x ∈ s | κ x = c}, κ x = κ y := by
    intro c x hx y hy
    rw [(mem_filter.1 hx).2, (mem_filter.1 hy).2]
  have hlaw : mutInfo s (fun x => (g x, κ x)) (fun x => (k x, κ x)) = uEnt s κ := by
    refine mutInfo_eq_uEnt_label hs (fun x _ y _ h => (Prod.mk.inj h).2)
      (fun x _ y _ h => (Prod.mk.inj h).2) fun c => ?_
    have e1 : uEnt {x ∈ s | κ x = c} (fun a => ((g a, κ a), (k a, κ a)))
        = uEnt {x ∈ s | κ x = c} (fun a => (g a, k a)) := by
      refine uEnt_congr_fibres _ _ _ fun x hx y hy => ?_
      have := hfibconst c x hx y hy
      constructor
      · intro h; simp only [Prod.mk.injEq] at h ⊢; exact ⟨h.1.1, h.2.1⟩
      · intro h; simp only [Prod.mk.injEq] at h ⊢; exact ⟨⟨h.1, this⟩, ⟨h.2, this⟩⟩
    have e2 : uEnt {x ∈ s | κ x = c} (fun a => (g a, κ a)) = uEnt {x ∈ s | κ x = c} g := by
      refine uEnt_congr_fibres _ _ _ fun x hx y hy => ?_
      have := hfibconst c x hx y hy
      constructor
      · intro h; exact (Prod.mk.inj h).1
      · intro h; rw [h, this]
    have e3 : uEnt {x ∈ s | κ x = c} (fun a => (k a, κ a)) = uEnt {x ∈ s | κ x = c} k := by
      refine uEnt_congr_fibres _ _ _ fun x hx y hy => ?_
      have := hfibconst c x hx y hy
      constructor
      · intro h; exact (Prod.mk.inj h).1
      · intro h; rw [h, this]
    rw [e1, e2, e3, hsplit c]
  have d1 := mutInfo_comp_right_le s g (fun x => (k x, κ x)) Prod.fst
  have d2 := mutInfo_comp_left_le s (fun x => (g x, κ x)) Prod.fst (fun x => (k x, κ x))
  simp only at d1 d2
  linarith

end Abstract

/-! ## 2. The fibre-product (shared subfield) model -/

section FibreProductLaw

variable {G H : Type*} [Group G] [Fintype G] [Group H] [Fintype H] [Group C] [Fintype C]
  [DecidableEq C] [DecidableEq β] [DecidableEq γ]

omit [Group G] [Fintype G] [Group H] [Fintype H] [DecidableEq β] [DecidableEq γ] in
/-- Entropy of the second coordinate on a product sample space. -/
theorem uEnt_product_snd' {s : Finset G} {t : Finset H} (hs : s.Nonempty) (ht : t.Nonempty)
    {δ : Type*} [DecidableEq δ] (k : H → δ) :
    uEnt (s ×ˢ t) (fun x => k x.2) = uEnt t k := by
  have h := uEnt_product hs ht (fun _ => ()) k
  have h0 : uEnt s (fun _ : G => ()) = 0 := uEnt_eq_zero_of_const fun _ _ _ _ => rfl
  rw [h0, zero_add] at h
  rw [← h]
  refine uEnt_congr_fibres _ _ _ fun x _ y _ => ?_
  simp

omit [Fintype C] in
/-- The fibre product is never empty: it contains `(1, 1)`. -/
theorem fibreProd_nonempty (χ₁ : G →* C) (χ₂ : H →* C) : (fibreProd χ₁ χ₂).Nonempty :=
  ⟨(1, 1), by simp [fibreProd]⟩

omit [Fintype C] in
/-- **Fibrewise independence on the fibre product.**  Given the shared character, the two
coordinates are an honest product, so the joint entropy of any two readouts splits. -/
theorem fibreProd_split (χ₁ : G →* C) (χ₂ : H →* C) (T₁ : G → β) (T₂ : H → γ) (c : C) :
    uEnt {x ∈ fibreProd χ₁ χ₂ | χ₁ x.1 = c} (fun a => (T₁ a.1, T₂ a.2))
      = uEnt {x ∈ fibreProd χ₁ χ₂ | χ₁ x.1 = c} (fun a => T₁ a.1)
        + uEnt {x ∈ fibreProd χ₁ χ₂ | χ₁ x.1 = c} (fun a => T₂ a.2) := by
  rw [fibreProd_fibre]
  rcases ({a : G | χ₁ a = c} : Finset G).eq_empty_or_nonempty with hA | hA
  · rw [hA]; simp [uEnt]
  rcases ({b : H | χ₂ b = c} : Finset H).eq_empty_or_nonempty with hB | hB
  · rw [hB]; simp [uEnt]
  rw [uEnt_product hA hB, uEnt_product_fst hA hB, uEnt_product_snd' hA hB]

omit [Fintype C] in
/-- **Correlation beyond the shared character vanishes**: on every fibre of the shared
character, the two readouts carry exactly `0` bits about each other. -/
theorem mutInfo_fibreProd_fibre_eq_zero (χ₁ : G →* C) (χ₂ : H →* C) (T₁ : G → β) (T₂ : H → γ)
    (c : C) :
    mutInfo {x ∈ fibreProd χ₁ χ₂ | χ₁ x.1 = c} (fun a => T₁ a.1) (fun a => T₂ a.2) = 0 := by
  rw [fibreProd_fibre]
  rcases ({a : G | χ₁ a = c} : Finset G).eq_empty_or_nonempty with hA | hA
  · rw [hA]; simp [mutInfo, condEnt, uEnt]
  rcases ({b : H | χ₂ b = c} : Finset H).eq_empty_or_nonempty with hB | hB
  · rw [hB]; simp [mutInfo, condEnt, uEnt]
  exact mutInfo_product_marginals hA hB T₁ T₂

omit [Fintype C] in
/-- **THE OVERLAP LAW (entropy form).**  Two fields with Galois groups `G`, `H` sharing the
subfield cut out by `C` (compositum group `G ×_C H`): if each splitting-type readout determines
its character, the two readouts share *exactly* the entropy of the shared character. -/
theorem mutInfo_fibreProd_eq_uEnt (χ₁ : G →* C) (χ₂ : H →* C) (T₁ : G → β) (T₂ : H → γ)
    (f₁ : β → C) (f₂ : γ → C) (hf₁ : ∀ a, χ₁ a = f₁ (T₁ a)) (hf₂ : ∀ b, χ₂ b = f₂ (T₂ b)) :
    mutInfo (fibreProd χ₁ χ₂) (fun x => T₁ x.1) (fun x => T₂ x.2)
      = uEnt (fibreProd χ₁ χ₂) (fun x => χ₁ x.1) := by
  refine mutInfo_eq_uEnt_label (fibreProd_nonempty χ₁ χ₂) ?_ ?_ (fibreProd_split χ₁ χ₂ T₁ T₂)
  · intro x _ y _ h
    simp only at h ⊢
    rw [hf₁, hf₁, h]
  · intro x hx y hy h
    simp only at h ⊢
    have hx' : χ₁ x.1 = χ₂ x.2 := (mem_filter.1 hx).2
    have hy' : χ₁ y.1 = χ₂ y.2 := (mem_filter.1 hy).2
    rw [hx', hy', hf₂, hf₂, h]

omit [Fintype C] in
/-- **The overlap ceiling on a fibre product**: *any* readouts of two fields sharing the subfield
cut out by `C` share at most the entropy of the shared character. -/
theorem mutInfo_fibreProd_le_uEnt (χ₁ : G →* C) (χ₂ : H →* C) (T₁ : G → β) (T₂ : H → γ) :
    mutInfo (fibreProd χ₁ χ₂) (fun x => T₁ x.1) (fun x => T₂ x.2)
      ≤ uEnt (fibreProd χ₁ χ₂) (fun x => χ₁ x.1) :=
  mutInfo_le_uEnt_label (fibreProd_nonempty χ₁ χ₂) _ _ _ (fibreProd_split χ₁ χ₂ T₁ T₂)

omit [DecidableEq β] [DecidableEq γ] in
/-- A surjective homomorphism has `|G| = |C| · |ker|`-many elements, fibre by fibre. -/
theorem card_eq_card_mul_fibre (χ : G →* C) (h : Function.Surjective χ) (c : C) :
    Fintype.card G = Fintype.card C * #({a : G | χ a = c} : Finset G) := by
  classical
  have hsum : (univ : Finset G).card = ∑ c' : C, #({a : G | χ a = c'} : Finset G) :=
    card_eq_sum_card_fiberwise (fun x _ => mem_univ (χ x))
  have hfib : ∀ c' : C, #({a : G | χ a = c'} : Finset G) = #({a : G | χ a = c} : Finset G) :=
    fun c' => MonoidHom.card_fiber_eq_of_mem_range χ (h c') (h c)
  rw [card_univ] at hsum
  rw [hsum, sum_congr rfl fun c' _ => hfib c', sum_const, card_univ, smul_eq_mul]

omit [DecidableEq β] [DecidableEq γ] in
/-- Each value of the shared character takes the same share `1/|C|` of the fibre product. -/
theorem fibreProd_uniform (χ₁ : G →* C) (χ₂ : H →* C) (h₁ : Function.Surjective χ₁)
    (h₂ : Function.Surjective χ₂) (c : C) :
    Fintype.card C * #{x ∈ fibreProd χ₁ χ₂ | χ₁ x.1 = c} = #(fibreProd χ₁ χ₂) := by
  classical
  have hfib : ∀ c' : C, #{x ∈ fibreProd χ₁ χ₂ | χ₁ x.1 = c'}
      = #({a : G | χ₁ a = c} : Finset G) * #({b : H | χ₂ b = c} : Finset H) := by
    intro c'
    rw [fibreProd_fibre, card_product]
    congr 1
    · exact MonoidHom.card_fiber_eq_of_mem_range χ₁ (h₁ c') (h₁ c)
    · exact MonoidHom.card_fiber_eq_of_mem_range χ₂ (h₂ c') (h₂ c)
  have hsum : #(fibreProd χ₁ χ₂) = ∑ c' : C, #{x ∈ fibreProd χ₁ χ₂ | χ₁ x.1 = c'} :=
    card_eq_sum_card_fiberwise (fun x _ => mem_univ (χ₁ x.1))
  rw [hsum, sum_congr rfl fun c' _ => hfib c', sum_const, card_univ, smul_eq_mul, hfib]

omit [DecidableEq β] [DecidableEq γ] in
/-- **Order of the compositum group**: `|C| · |G ×_C H| = |G| · |H|`
(for `S₃ ×_{C₂} S₃`: `2 · 18 = 6 · 6`). -/
theorem card_fibreProd_mul (χ₁ : G →* C) (χ₂ : H →* C) (h₁ : Function.Surjective χ₁)
    (h₂ : Function.Surjective χ₂) :
    Fintype.card C * #(fibreProd χ₁ χ₂) = Fintype.card G * Fintype.card H := by
  classical
  rw [← fibreProd_uniform χ₁ χ₂ h₁ h₂ 1, fibreProd_fibre, card_product,
    card_eq_card_mul_fibre χ₁ h₁ 1, card_eq_card_mul_fibre χ₂ h₂ 1]
  ring

omit [DecidableEq β] [DecidableEq γ] in
/-- The shared character of a fibre product of surjections carries exactly `log₂ |C|` bits. -/
theorem uEnt_fibreProd_char (χ₁ : G →* C) (χ₂ : H →* C) (h₁ : Function.Surjective χ₁)
    (h₂ : Function.Surjective χ₂) :
    uEnt (fibreProd χ₁ χ₂) (fun x => χ₁ x.1) = Real.logb 2 (Fintype.card C) :=
  uEnt_eq_logb_of_uniform (fibreProd_nonempty χ₁ χ₂) Fintype.card_pos
    fun _ _ => fibreProd_uniform χ₁ χ₂ h₁ h₂ _

/-- **THE OVERLAP LAW.**  Two fields sharing the subfield with Galois group `C` (compositum group
`G ×_C H`, both restriction maps surjective), read out through splitting types that determine the
shared character, are redundant by *exactly* `log₂ |C|` bits. -/
theorem mutInfo_fibreProd_eq_logb_card (χ₁ : G →* C) (χ₂ : H →* C)
    (h₁ : Function.Surjective χ₁) (h₂ : Function.Surjective χ₂) (T₁ : G → β) (T₂ : H → γ)
    (f₁ : β → C) (f₂ : γ → C) (hf₁ : ∀ a, χ₁ a = f₁ (T₁ a)) (hf₂ : ∀ b, χ₂ b = f₂ (T₂ b)) :
    mutInfo (fibreProd χ₁ χ₂) (fun x => T₁ x.1) (fun x => T₂ x.2)
      = Real.logb 2 (Fintype.card C) := by
  rw [mutInfo_fibreProd_eq_uEnt χ₁ χ₂ T₁ T₂ f₁ f₂ hf₁ hf₂, uEnt_fibreProd_char χ₁ χ₂ h₁ h₂]

/-- **The overlap ceiling, numerical form**: *any* two readouts share at most `log₂ |C|` bits. -/
theorem mutInfo_fibreProd_le_logb_card (χ₁ : G →* C) (χ₂ : H →* C)
    (h₁ : Function.Surjective χ₁) (h₂ : Function.Surjective χ₂) (T₁ : G → β) (T₂ : H → γ) :
    mutInfo (fibreProd χ₁ χ₂) (fun x => T₁ x.1) (fun x => T₂ x.2)
      ≤ Real.logb 2 (Fintype.card C) := by
  rw [← uEnt_fibreProd_char χ₁ χ₂ h₁ h₂]
  exact mutInfo_fibreProd_le_uEnt χ₁ χ₂ T₁ T₂

/-- **PARTIAL-OVERLAP-LAW (paper 133).**  Two fields sharing a *quadratic* subfield are exactly
one bit redundant, for arbitrary finite Galois groups `G`, `H`. -/
theorem mutInfo_sharedQuadratic_eq_one (χ₁ : G →* C) (χ₂ : H →* C)
    (h₁ : Function.Surjective χ₁) (h₂ : Function.Surjective χ₂) (hC : Fintype.card C = 2)
    (T₁ : G → β) (T₂ : H → γ) (f₁ : β → C) (f₂ : γ → C) (hf₁ : ∀ a, χ₁ a = f₁ (T₁ a))
    (hf₂ : ∀ b, χ₂ b = f₂ (T₂ b)) :
    mutInfo (fibreProd χ₁ χ₂) (fun x => T₁ x.1) (fun x => T₂ x.2) = 1 := by
  rw [mutInfo_fibreProd_eq_logb_card χ₁ χ₂ h₁ h₂ T₁ T₂ f₁ f₂ hf₁ hf₂, hC]
  simp

end FibreProductLaw

/-! ## 3. The overlap ladder -/

section Ladder

open Equiv Equiv.Perm

/-- **Shared sign, symmetric groups.**  For *any* two degrees `n, m ≥ 2`: two `Sₙ`/`Sₘ` fields with
the same quadratic resolvent (compositum `Sₙ ×_{C₂} Sₘ`) have cycle-type readouts sharing exactly
one bit. -/
theorem mutInfo_perm_sharedSign_eq_one (ι κ : Type*) [DecidableEq ι] [Fintype ι] [Nontrivial ι]
    [DecidableEq κ] [Fintype κ] [Nontrivial κ] :
    mutInfo (fibreProd (sign : Perm ι →* ℤˣ) (sign : Perm κ →* ℤˣ))
      (fun x => x.1.cycleType) (fun x => x.2.cycleType) = 1 :=
  mutInfo_sharedQuadratic_eq_one sign sign (sign_surjective ι) (sign_surjective κ) (by simp)
    Equiv.Perm.cycleType Equiv.Perm.cycleType (fun t => (-1) ^ (t.sum + t.card))
    (fun t => (-1) ^ (t.sum + t.card)) (fun σ => sign_of_cycleType σ)
    (fun σ => sign_of_cycleType σ)

/-- **Coprime rung of the ladder.**  When the shared quotient is trivial (linearly disjoint
fields, compositum `G × H`), *every* pair of readouts shares exactly `0` bits. -/
theorem mutInfo_fibreProd_trivial_eq_zero {G H β γ : Type*} [Group G] [Fintype G] [Group H]
    [Fintype H] [DecidableEq β] [DecidableEq γ] (T₁ : G → β) (T₂ : H → γ) :
    mutInfo (fibreProd (1 : G →* Unit) (1 : H →* Unit)) (fun x => T₁ x.1) (fun x => T₂ x.2)
      = 0 := by
  have hle := mutInfo_fibreProd_le_logb_card (1 : G →* Unit) (1 : H →* Unit)
    (fun _ => ⟨1, rfl⟩) (fun _ => ⟨1, rfl⟩) T₁ T₂
  simp only [Fintype.card_unique, Nat.cast_one, Real.logb_one] at hle
  exact le_antisymm hle (mutInfo_nonneg _ _ _)

/-- **Same-field rung of the ladder.**  For the *same* field read twice (compositum group the
diagonal `G ×_G G`), the full Frobenius readouts share exactly `log₂ |G|` bits. -/
theorem mutInfo_fibreProd_diag_eq_logb {G : Type*} [Group G] [Fintype G] [DecidableEq G] :
    mutInfo (fibreProd (MonoidHom.id G) (MonoidHom.id G)) (fun x => x.1) (fun x => x.2)
      = Real.logb 2 (Fintype.card G) :=
  mutInfo_fibreProd_eq_logb_card (MonoidHom.id G) (MonoidHom.id G) Function.surjective_id
    Function.surjective_id id id id id (fun _ => rfl) (fun _ => rfl)

/-- **The ladder is monotone in the shared quotient**: for any two fields and any readouts, the
redundancy is squeezed between `0` and `log₂ |C|`, and the top is attained by character-determining
readouts. -/
theorem overlap_ladder_bounds {G H C β γ : Type*} [Group G] [Fintype G] [Group H] [Fintype H]
    [Group C] [Fintype C] [DecidableEq C] [DecidableEq β] [DecidableEq γ]
    (χ₁ : G →* C) (χ₂ : H →* C) (h₁ : Function.Surjective χ₁) (h₂ : Function.Surjective χ₂)
    (T₁ : G → β) (T₂ : H → γ) :
    0 ≤ mutInfo (fibreProd χ₁ χ₂) (fun x => T₁ x.1) (fun x => T₂ x.2) ∧
      mutInfo (fibreProd χ₁ χ₂) (fun x => T₁ x.1) (fun x => T₂ x.2)
        ≤ Real.logb 2 (Fintype.card C) :=
  ⟨mutInfo_nonneg _ _ _, mutInfo_fibreProd_le_logb_card χ₁ χ₂ h₁ h₂ T₁ T₂⟩

end Ladder

/-! ## 4. The `S₃` pairs of exp 462 and the discriminators of insight L11

Both pairs found in the scan (`x³-5x-5` & `x³-3x-5` over `ℚ(√-7)`, `x³-6x-6` & `x³-3` over
`ℚ(√-3)`) have compositum group `S₃ ×_{C₂} S₃ = sharedQuad`.  The *same-field* (conjugate) pair has
compositum group the diagonal `sameField`. -/

namespace S3

open Equiv Equiv.Perm

/-- The diagonal `S₃ ×_{S₃} S₃`: the compositum group when both cubics define the same field
(e.g. a cubic and a conjugate/Tschirnhaus-equivalent cubic). -/
def sameField : Finset (P3 × P3) := {x | x.1 = x.2}

/-- The diagonal is the fibre product over the identity. -/
theorem sameField_eq_fibreProd : sameField = fibreProd (MonoidHom.id P3) (MonoidHom.id P3) := rfl

/-- **The paper-133 law, derived rather than computed**: the two `S₃` dials over a shared quadratic
field are exactly one bit redundant, as an instance of the general overlap law. -/
theorem mutInfo_sharedQuad_by_law :
    mutInfo sharedQuad (fun x => splitType x.1) (fun x => splitType x.2) = 1 := by
  rw [sharedQuad_eq_fibreProd]
  exact mutInfo_sharedQuadratic_eq_one sign sign (sign_surjective _) (sign_surjective _)
    (by decide) splitType splitType signOfType signOfType sign_eq_signOfType sign_eq_signOfType

/-- The compositum has order `18`, derived from `|C₂| · |S₃ ×_{C₂} S₃| = |S₃| · |S₃|`. -/
theorem card_sharedQuad_by_law : #sharedQuad = 18 := by
  have h := card_fibreProd_mul (sign : P3 →* ℤˣ) (sign : P3 →* ℤˣ) (sign_surjective (Fin 3))
    (sign_surjective (Fin 3))
  rw [← sharedQuad_eq_fibreProd] at h
  have h2 : Fintype.card ℤˣ = 2 := by decide
  have h6 : Fintype.card P3 = 6 := by decide
  rw [h2, h6] at h
  omega

set_option maxHeartbeats 4000000 in
/-- **The joint Chebotarev table on `S₃ ×_{C₂} S₃`** (out of `18`): `111/111 : 1`, `111/3 : 2`,
`3/111 : 2`, `3/3 : 4`, `12/12 : 9`; all four cells mixing `12` with `111` or `3` vanish. -/
theorem sharedQuad_joint_table :
    #{x ∈ sharedQuad | splitType x.1 = {1, 1, 1} ∧ splitType x.2 = {1, 1, 1}} = 1 ∧
    #{x ∈ sharedQuad | splitType x.1 = {1, 1, 1} ∧ splitType x.2 = {3}} = 2 ∧
    #{x ∈ sharedQuad | splitType x.1 = {3} ∧ splitType x.2 = {1, 1, 1}} = 2 ∧
    #{x ∈ sharedQuad | splitType x.1 = {3} ∧ splitType x.2 = {3}} = 4 ∧
    #{x ∈ sharedQuad | splitType x.1 = {2, 1} ∧ splitType x.2 = {2, 1}} = 9 ∧
    #{x ∈ sharedQuad | splitType x.1 = {2, 1} ∧ splitType x.2 ≠ {2, 1}} = 0 ∧
    #{x ∈ sharedQuad | splitType x.1 ≠ {2, 1} ∧ splitType x.2 = {2, 1}} = 0 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> decide

set_option maxHeartbeats 4000000 in
/-- **Type agreement, partial overlap**: the two splitting types agree on `14` of the `18`
elements, i.e. with probability `7/9`; the off-diagonal mass is `4/18 = 2/9`. -/
theorem typeAgree_sharedQuad :
    #{x ∈ sharedQuad | splitType x.1 = splitType x.2} = 14 ∧
      #{x ∈ sharedQuad | splitType x.1 ≠ splitType x.2} = 4 := by
  constructor <;> decide

set_option maxHeartbeats 4000000 in
/-- **Type agreement, same field**: the two splitting types always agree (`6/6`). -/
theorem typeAgree_sameField :
    #{x ∈ sameField | splitType x.1 = splitType x.2} = 6 ∧ #sameField = 6 := by
  constructor <;> decide

set_option maxHeartbeats 4000000 in
/-- **Type agreement, coprime discriminants**: `14` of `36`, i.e. `7/18` — exactly half the
partial-overlap value. -/
theorem typeAgree_coprime :
    #{x ∈ (univ : Finset P3) ×ˢ (univ : Finset P3) | splitType x.1 = splitType x.2} = 14 := by
  decide

set_option maxHeartbeats 4000000 in
/-- **Where the extra agreement lives.**  On the `χ_d = -1` fibre (`9` elements) the types agree
always (both `12`); on the residue-invisible `χ_d = +1` fibre (`9` elements, `A₃ × A₃`) they agree
only `5` times — exactly the independent rate `(1/3)² + (2/3)²`. -/
theorem typeAgree_sharedQuad_fibres :
    #{x ∈ sharedQuad | sign x.1 = -1 ∧ splitType x.1 = splitType x.2} = 9 ∧
      #{x ∈ sharedQuad | sign x.1 = 1 ∧ splitType x.1 = splitType x.2} = 5 ∧
      #{x ∈ sharedQuad | sign x.1 = 1} = 9 := by
  refine ⟨?_, ?_, ?_⟩ <;> decide

/-- **All fibre-product correlation beyond the sign character is zero**: on each fibre of the
shared quadratic character the two splitting types carry `0` bits about each other. -/
theorem mutInfo_sharedQuad_fibre_eq_zero (c : ℤˣ) :
    mutInfo {x ∈ sharedQuad | sign x.1 = c} (fun x => splitType x.1) (fun x => splitType x.2)
      = 0 := by
  rw [sharedQuad_eq_fibreProd]
  exact mutInfo_fibreProd_fibre_eq_zero sign sign splitType splitType c

set_option maxHeartbeats 4000000 in
/-- Same field read twice: full redundancy, `I(T₁ ; T₂) = H(T) = 2/3 + (log₂ 3)/2`. -/
theorem mutInfo_sameField_splitType :
    mutInfo sameField (fun x => splitType x.1) (fun x => splitType x.2)
      = 2 / 3 + Real.logb 2 3 / 2 := by
  have h0 : condEnt sameField (fun x => splitType x.1) (fun x => splitType x.2) = 0 := by
    refine condEnt_eq_zero_of_refines fun x hx y hy h => ?_
    have hx' : x.1 = x.2 := (mem_filter.1 hx).2
    have hy' : y.1 = y.2 := (mem_filter.1 hy).2
    simp only at h ⊢
    rw [hx', hy', h]
  have hcount : (sameField.image (fun x => splitType x.1)).val.map
      (fun v => (#{x ∈ sameField | splitType x.1 = v} : ℕ)) = ({1, 3, 2} : Multiset ℕ) := by
    decide
  have hc : #sameField = 6 := by decide
  rw [mutInfo, h0, sub_zero, uEnt_eq_countSum _ _ _ hcount, hc]
  simp only [Multiset.insert_eq_cons, Multiset.map_cons, Multiset.sum_cons,
    Multiset.map_singleton, Multiset.sum_singleton, Nat.cast_ofNat, Nat.cast_one]
  rw [lb_6, Real.logb_one, Real.logb_self_eq_one (by norm_num)]
  ring

/-- The residue-visible (sign) readouts are one bit redundant on the partial-overlap pair. -/
theorem mutInfo_sharedQuad_sign :
    mutInfo sharedQuad (fun x => sign x.1) (fun x => sign x.2) = 1 := by
  rw [sharedQuad_eq_fibreProd]
  exact mutInfo_sharedQuadratic_eq_one sign sign (sign_surjective _) (sign_surjective _)
    (by decide) (fun σ => sign σ) (fun σ => sign σ) id id (fun _ => rfl) (fun _ => rfl)

set_option maxHeartbeats 4000000 in
/-- …and *also* exactly one bit redundant on the same-field pair. -/
theorem mutInfo_sameField_sign :
    mutInfo sameField (fun x => sign x.1) (fun x => sign x.2) = 1 := by
  have h0 : condEnt sameField (fun x => sign x.1) (fun x => sign x.2) = 0 := by
    refine condEnt_eq_zero_of_refines fun x hx y hy h => ?_
    have hx' : x.1 = x.2 := (mem_filter.1 hx).2
    have hy' : y.1 = y.2 := (mem_filter.1 hy).2
    simp only at h ⊢
    rw [hx', hy', h]
  have h1 : uEnt sameField (fun x => sign x.1) = 1 :=
    uEnt_eq_one_of_balanced ⟨(1, 1), by simp [sameField]⟩ (by decide)
  rw [mutInfo, h0, h1, sub_zero]

/-- **Insight L11, formal.**  The residue-visible (sign) mutual information cannot tell a
partial-overlap pair from a same-field pair — it is exactly one bit in both — while the
discriminators separate them: type agreement `14/18` versus `6/6`, and full-type redundancy
`1` versus `H(T) = 2/3 + (log₂ 3)/2 > 1`. -/
theorem L11_sign_blind_type_discriminates :
    mutInfo sharedQuad (fun x => sign x.1) (fun x => sign x.2)
        = mutInfo sameField (fun x => sign x.1) (fun x => sign x.2) ∧
      mutInfo sharedQuad (fun x => splitType x.1) (fun x => splitType x.2)
        < mutInfo sameField (fun x => splitType x.1) (fun x => splitType x.2) ∧
      18 * #{x ∈ sameField | splitType x.1 = splitType x.2} ≠
        #sameField * #{x ∈ sharedQuad | splitType x.1 = splitType x.2} := by
  refine ⟨by rw [mutInfo_sharedQuad_sign, mutInfo_sameField_sign], ?_, ?_⟩
  · rw [mutInfo_sharedQuad_by_law, mutInfo_sameField_splitType]
    have := lb_three_gt_sharp
    linarith
  · rw [typeAgree_sameField.1, typeAgree_sameField.2, typeAgree_sharedQuad.1]
    norm_num

/-- **The `S₃` overlap ladder, closed at the pair level**: coprime `0` bits, shared quadratic
subfield exactly `1` bit, same field `H(T) = 2/3 + (log₂ 3)/2` bits. -/
theorem overlap_ladder_S3 :
    mutInfo ((univ : Finset P3) ×ˢ (univ : Finset P3))
        (fun x => splitType x.1) (fun x => splitType x.2) = 0 ∧
      mutInfo sharedQuad (fun x => splitType x.1) (fun x => splitType x.2) = 1 ∧
      mutInfo sameField (fun x => splitType x.1) (fun x => splitType x.2)
        = 2 / 3 + Real.logb 2 3 / 2 :=
  ⟨mutInfo_dials_indep, mutInfo_sharedQuad_by_law, mutInfo_sameField_splitType⟩

end S3

/-! ## 5. A second family: cyclic quartic fields sharing their quadratic subfield

The law is not about `S₃`.  Two cyclic quartic fields with the same quadratic subfield have
compositum group `C₄ ×_{C₂} C₄` (order `8`); the residue degree of an unramified prime is the order
of its Frobenius.  The law gives exactly one bit again, now with `H(deg) = 3/2` and
`H(deg₁ | deg₂) = 1/2`. -/

namespace Quartic

/-- The cyclic group `C₄ = Gal(K/ℚ)` of a cyclic quartic field. -/
abbrev Q4 := Multiplicative (ZMod 4)

/-- The quotient `C₂`, the Galois group of the quadratic subfield. -/
abbrev Q2 := Multiplicative (ZMod 2)

/-- Restriction to the quadratic subfield: `C₄ → C₂`. -/
def restrict : Q4 →* Q2 :=
  (ZMod.castHom (by norm_num : 2 ∣ 4) (ZMod 2)).toAddMonoidHom.toMultiplicative

/-- The compositum group `C₄ ×_{C₂} C₄`. -/
abbrev quarticPair : Finset (Q4 × Q4) := fibreProd restrict restrict

/-- Explicit residue-degree table on `C₄`. -/
def degTable (a : Q4) : ℕ :=
  if Multiplicative.toAdd a = 0 then 1 else if Multiplicative.toAdd a = 2 then 2 else 4

/-- The table is the order of the Frobenius element. -/
theorem orderOf_eq_degTable (a : Q4) : orderOf a = degTable a := by
  rw [← addOrderOf_ofMul_eq_orderOf, degTable]
  change addOrderOf (Multiplicative.toAdd a) = _
  generalize Multiplicative.toAdd a = b
  fin_cases b
  · simp
  · change addOrderOf (1 : ZMod 4) = _
    rw [ZMod.addOrderOf_one]; decide
  · have := ZMod.addOrderOf_coe (n := 4) 2 (by norm_num); norm_num at this ⊢; exact this
  · have := ZMod.addOrderOf_coe (n := 4) 3 (by norm_num); norm_num at this ⊢; exact this

theorem restrict_surjective : Function.Surjective restrict := by decide

/-- Read the quadratic character off a residue degree: nontrivial iff the degree is `4`. -/
def quadOfDeg (d : ℕ) : Q2 := if d = 4 then Multiplicative.ofAdd (1 : ZMod 2) else 1

/-- The residue degree determines the quadratic character: inert-in-the-subfield iff degree `4`. -/
theorem restrict_eq_of_deg (a : Q4) : restrict a = quadOfDeg (orderOf a) := by
  rw [orderOf_eq_degTable]; revert a; decide

/-- **Exactly one bit**, for the cyclic quartic pair. -/
theorem mutInfo_quarticPair :
    mutInfo quarticPair (fun x => orderOf x.1) (fun x => orderOf x.2) = 1 :=
  mutInfo_sharedQuadratic_eq_one restrict restrict restrict_surjective restrict_surjective
    (by decide) orderOf orderOf quadOfDeg quadOfDeg restrict_eq_of_deg restrict_eq_of_deg

/-- Each quartic dial carries `3/2` bits on the compositum. -/
theorem uEnt_quarticPair_deg : uEnt quarticPair (fun x => orderOf x.1) = 3 / 2 := by
  have hf : (fun x : Q4 × Q4 => orderOf x.1) = fun x => degTable x.1 := by
    funext x; exact orderOf_eq_degTable x.1
  have hcount : (quarticPair.image (fun x => degTable x.1)).val.map
      (fun v => (#{x ∈ quarticPair | degTable x.1 = v} : ℕ)) = ({2, 2, 4} : Multiset ℕ) := by
    decide
  have hc : #quarticPair = 8 := by decide
  rw [hf, uEnt_eq_countSum _ _ _ hcount, hc]
  simp only [Multiset.insert_eq_cons, Multiset.map_cons, Multiset.sum_cons,
    Multiset.map_singleton, Multiset.sum_singleton, Nat.cast_ofNat]
  rw [show (8 : ℝ) = 2 ^ (3 : ℕ) by norm_num, show (4 : ℝ) = 2 ^ (2 : ℕ) by norm_num,
    Real.logb_pow, Real.logb_pow, Real.logb_self_eq_one (by norm_num)]
  norm_num

/-- **The decomposition `1 = 3/2 - 1/2`**: `H(deg₁ | deg₂) = 1/2`. -/
theorem condEnt_quarticPair_deg :
    condEnt quarticPair (fun x => orderOf x.1) (fun x => orderOf x.2) = 1 / 2 := by
  have h := mutInfo_quarticPair
  rw [mutInfo, uEnt_quarticPair_deg] at h
  linarith

end Quartic

/-! ## 6. Three dials over one shared subfield: total correlation and co-information

Three fields sharing the subfield cut out by `C` have compositum group the triple fibre product
`G ×_C H ×_C K`.  The abstract law, applied twice, gives total correlation exactly `2 log₂ |C|`
and co-information exactly `+log₂ |C|`: the triple is purely *redundant*, never synergistic. -/

section ThreeDials

variable {G H K δ : Type*} [Group G] [Fintype G] [Group H] [Fintype H] [Group K] [Fintype K]
  [Group C] [Fintype C] [DecidableEq C] [DecidableEq β] [DecidableEq γ] [DecidableEq δ]

omit [Group G] [Group H] [Fintype G] [Fintype H] [Group C] [Fintype C] [DecidableEq C]
  [DecidableEq β] [DecidableEq γ] in
/-- On any product sample space, a readout of the first and a readout of the second coordinate
have additive joint entropy (empty factors included). -/
theorem uEnt_product_split {ε ζ : Type*} [DecidableEq ε] [DecidableEq ζ] (s : Finset G)
    (t : Finset H) (g : G → ε) (k : H → ζ) :
    uEnt (s ×ˢ t) (fun x => (g x.1, k x.2))
      = uEnt (s ×ˢ t) (fun x => g x.1) + uEnt (s ×ˢ t) (fun x => k x.2) := by
  rcases s.eq_empty_or_nonempty with hs | hs
  · subst hs; simp [uEnt]
  rcases t.eq_empty_or_nonempty with ht | ht
  · subst ht; simp [uEnt]
  rw [uEnt_product hs ht, uEnt_product_fst hs ht, uEnt_product_snd' hs ht]

/-- The triple fibre product `G ×_C H ×_C K`, arranged as a subset of `G × (H × K)`. -/
def fibreProd3 (χ₁ : G →* C) (χ₂ : H →* C) (χ₃ : K →* C) : Finset (G × (H × K)) :=
  {x | χ₁ x.1 = χ₂ x.2.1 ∧ χ₁ x.1 = χ₃ x.2.2}

omit [Fintype C] in
theorem fibreProd3_fibre (χ₁ : G →* C) (χ₂ : H →* C) (χ₃ : K →* C) (c : C) :
    ({x ∈ fibreProd3 χ₁ χ₂ χ₃ | χ₁ x.1 = c} : Finset (G × (H × K)))
      = ({a : G | χ₁ a = c} : Finset G) ×ˢ
          (({b : H | χ₂ b = c} : Finset H) ×ˢ ({d : K | χ₃ d = c} : Finset K)) := by
  ext ⟨a, b, d⟩
  simp only [fibreProd3, mem_filter, mem_univ, true_and, mem_product]
  constructor
  · rintro ⟨⟨h1, h2⟩, h3⟩; exact ⟨h3, h1 ▸ h3, h2 ▸ h3⟩
  · rintro ⟨h1, h2, h3⟩; exact ⟨⟨h1.trans h2.symm, h1.trans h3.symm⟩, h1⟩

omit [Fintype C] in
theorem fibreProd3_nonempty (χ₁ : G →* C) (χ₂ : H →* C) (χ₃ : K →* C) :
    (fibreProd3 χ₁ χ₂ χ₃).Nonempty :=
  ⟨(1, 1, 1), by simp [fibreProd3]⟩

omit [DecidableEq β] [DecidableEq γ] [DecidableEq δ] in
/-- The shared character is uniform on the triple fibre product. -/
theorem fibreProd3_uniform (χ₁ : G →* C) (χ₂ : H →* C) (χ₃ : K →* C)
    (h₁ : Function.Surjective χ₁) (h₂ : Function.Surjective χ₂) (h₃ : Function.Surjective χ₃)
    (c : C) :
    Fintype.card C * #{x ∈ fibreProd3 χ₁ χ₂ χ₃ | χ₁ x.1 = c} = #(fibreProd3 χ₁ χ₂ χ₃) := by
  classical
  have hfib : ∀ c' : C, #{x ∈ fibreProd3 χ₁ χ₂ χ₃ | χ₁ x.1 = c'}
      = #({a : G | χ₁ a = c} : Finset G) *
          (#({b : H | χ₂ b = c} : Finset H) * #({d : K | χ₃ d = c} : Finset K)) := by
    intro c'
    rw [fibreProd3_fibre, card_product, card_product]
    congr 1
    · exact MonoidHom.card_fiber_eq_of_mem_range χ₁ (h₁ c') (h₁ c)
    · congr 1
      · exact MonoidHom.card_fiber_eq_of_mem_range χ₂ (h₂ c') (h₂ c)
      · exact MonoidHom.card_fiber_eq_of_mem_range χ₃ (h₃ c') (h₃ c)
  have hsum : #(fibreProd3 χ₁ χ₂ χ₃) = ∑ c' : C, #{x ∈ fibreProd3 χ₁ χ₂ χ₃ | χ₁ x.1 = c'} :=
    card_eq_sum_card_fiberwise (fun x _ => mem_univ (χ₁ x.1))
  rw [hsum, sum_congr rfl fun c' _ => hfib c', sum_const, card_univ, smul_eq_mul, hfib]

/-- Hypotheses packaging: the three readouts determine their characters. -/
structure ThreeDialData (χ₁ : G →* C) (χ₂ : H →* C) (χ₃ : K →* C) (T₁ : G → β) (T₂ : H → γ)
    (T₃ : K → δ) : Prop where
  surj₁ : Function.Surjective χ₁
  surj₂ : Function.Surjective χ₂
  surj₃ : Function.Surjective χ₃
  det₁ : ∃ f : β → C, ∀ a, χ₁ a = f (T₁ a)
  det₂ : ∃ f : γ → C, ∀ b, χ₂ b = f (T₂ b)
  det₃ : ∃ f : δ → C, ∀ d, χ₃ d = f (T₃ d)

variable {χ₁ : G →* C} {χ₂ : H →* C} {χ₃ : K →* C} {T₁ : G → β} {T₂ : H → γ} {T₃ : K → δ}

omit [DecidableEq δ] in
/-- Inside the triple, the first two dials share exactly `log₂ |C|` bits. -/
theorem mutInfo3_12 (hD : ThreeDialData χ₁ χ₂ χ₃ T₁ T₂ T₃) :
    mutInfo (fibreProd3 χ₁ χ₂ χ₃) (fun x => T₁ x.1) (fun x => T₂ x.2.1)
      = Real.logb 2 (Fintype.card C) := by
  obtain ⟨f₁, hf₁⟩ := hD.det₁
  obtain ⟨f₂, hf₂⟩ := hD.det₂
  rw [mutInfo_eq_uEnt_label (κ := fun x => χ₁ x.1) (fibreProd3_nonempty χ₁ χ₂ χ₃) ?_ ?_ ?_]
  · exact uEnt_eq_logb_of_uniform (fibreProd3_nonempty χ₁ χ₂ χ₃) Fintype.card_pos
      fun _ _ => fibreProd3_uniform χ₁ χ₂ χ₃ hD.surj₁ hD.surj₂ hD.surj₃ _
  · intro x _ y _ h; simp only at h ⊢; rw [hf₁, hf₁, h]
  · intro x hx y hy h
    simp only at h ⊢
    rw [(mem_filter.1 hx).2.1, (mem_filter.1 hy).2.1, hf₂, hf₂, h]
  · intro c
    rw [fibreProd3_fibre]
    have h := uEnt_product_split ({a : G | χ₁ a = c} : Finset G)
      (({b : H | χ₂ b = c} : Finset H) ×ˢ ({d : K | χ₃ d = c} : Finset K)) T₁ (fun y => T₂ y.1)
    exact h

omit [DecidableEq γ] in
/-- Inside the triple, the first and third dials share exactly `log₂ |C|` bits. -/
theorem mutInfo3_13 (hD : ThreeDialData χ₁ χ₂ χ₃ T₁ T₂ T₃) :
    mutInfo (fibreProd3 χ₁ χ₂ χ₃) (fun x => T₁ x.1) (fun x => T₃ x.2.2)
      = Real.logb 2 (Fintype.card C) := by
  obtain ⟨f₁, hf₁⟩ := hD.det₁
  obtain ⟨f₃, hf₃⟩ := hD.det₃
  rw [mutInfo_eq_uEnt_label (κ := fun x => χ₁ x.1) (fibreProd3_nonempty χ₁ χ₂ χ₃) ?_ ?_ ?_]
  · exact uEnt_eq_logb_of_uniform (fibreProd3_nonempty χ₁ χ₂ χ₃) Fintype.card_pos
      fun _ _ => fibreProd3_uniform χ₁ χ₂ χ₃ hD.surj₁ hD.surj₂ hD.surj₃ _
  · intro x _ y _ h; simp only at h ⊢; rw [hf₁, hf₁, h]
  · intro x hx y hy h
    simp only at h ⊢
    rw [(mem_filter.1 hx).2.2, (mem_filter.1 hy).2.2, hf₃, hf₃, h]
  · intro c
    rw [fibreProd3_fibre]
    have h := uEnt_product_split ({a : G | χ₁ a = c} : Finset G)
      (({b : H | χ₂ b = c} : Finset H) ×ˢ ({d : K | χ₃ d = c} : Finset K)) T₁ (fun y => T₃ y.2)
    exact h

/-- The first dial shares exactly `log₂ |C|` bits with the *pair* of the other two: the second
dial adds nothing once the first is matched against the third. -/
theorem mutInfo3_1_23 (hD : ThreeDialData χ₁ χ₂ χ₃ T₁ T₂ T₃) :
    mutInfo (fibreProd3 χ₁ χ₂ χ₃) (fun x => T₁ x.1) (fun x => (T₂ x.2.1, T₃ x.2.2))
      = Real.logb 2 (Fintype.card C) := by
  obtain ⟨f₁, hf₁⟩ := hD.det₁
  obtain ⟨f₂, hf₂⟩ := hD.det₂
  rw [mutInfo_eq_uEnt_label (κ := fun x => χ₁ x.1) (fibreProd3_nonempty χ₁ χ₂ χ₃) ?_ ?_ ?_]
  · exact uEnt_eq_logb_of_uniform (fibreProd3_nonempty χ₁ χ₂ χ₃) Fintype.card_pos
      fun _ _ => fibreProd3_uniform χ₁ χ₂ χ₃ hD.surj₁ hD.surj₂ hD.surj₃ _
  · intro x _ y _ h; simp only at h ⊢; rw [hf₁, hf₁, h]
  · intro x hx y hy h
    simp only at h ⊢
    rw [(mem_filter.1 hx).2.1, (mem_filter.1 hy).2.1, hf₂, hf₂, (Prod.mk.inj h).1]
  · intro c
    rw [fibreProd3_fibre]
    have h := uEnt_product_split ({a : G | χ₁ a = c} : Finset G)
      (({b : H | χ₂ b = c} : Finset H) ×ˢ ({d : K | χ₃ d = c} : Finset K)) T₁ (fun y => (T₂ y.1, T₃ y.2))
    exact h

omit [DecidableEq β] in
/-- The second and third dials share exactly `log₂ |C|` bits inside the triple. -/
theorem mutInfo3_23 (hD : ThreeDialData χ₁ χ₂ χ₃ T₁ T₂ T₃) :
    mutInfo (fibreProd3 χ₁ χ₂ χ₃) (fun x => T₂ x.2.1) (fun x => T₃ x.2.2)
      = Real.logb 2 (Fintype.card C) := by
  obtain ⟨f₂, hf₂⟩ := hD.det₂
  obtain ⟨f₃, hf₃⟩ := hD.det₃
  rw [mutInfo_eq_uEnt_label (κ := fun x => χ₁ x.1) (fibreProd3_nonempty χ₁ χ₂ χ₃) ?_ ?_ ?_]
  · exact uEnt_eq_logb_of_uniform (fibreProd3_nonempty χ₁ χ₂ χ₃) Fintype.card_pos
      fun _ _ => fibreProd3_uniform χ₁ χ₂ χ₃ hD.surj₁ hD.surj₂ hD.surj₃ _
  · intro x hx y hy h
    simp only at h ⊢
    rw [(mem_filter.1 hx).2.1, (mem_filter.1 hy).2.1, hf₂, hf₂, h]
  · intro x hx y hy h
    simp only at h ⊢
    rw [(mem_filter.1 hx).2.2, (mem_filter.1 hy).2.2, hf₃, hf₃, h]
  · intro c
    rw [fibreProd3_fibre]
    rcases ({a : G | χ₁ a = c} : Finset G).eq_empty_or_nonempty with hA | hA
    · rw [hA]; simp [uEnt]
    rcases (({b : H | χ₂ b = c} : Finset H) ×ˢ ({d : K | χ₃ d = c} : Finset K)).eq_empty_or_nonempty
      with hB | hB
    · rw [hB]; simp [uEnt]
    rw [uEnt_product_snd' hA hB (fun y => (T₂ y.1, T₃ y.2)), uEnt_product_snd' hA hB (fun y => T₂ y.1),
      uEnt_product_snd' hA hB (fun y => T₃ y.2)]
    exact uEnt_product_split _ _ T₂ T₃

/-- **Total correlation of three overlapping dials**: `H(T₁) + H(T₂) + H(T₃) - H(T₁, T₂, T₃)`
equals exactly `2 log₂ |C|`. -/
theorem totalCorrelation3 (hD : ThreeDialData χ₁ χ₂ χ₃ T₁ T₂ T₃) :
    uEnt (fibreProd3 χ₁ χ₂ χ₃) (fun x => T₁ x.1) + uEnt (fibreProd3 χ₁ χ₂ χ₃) (fun x => T₂ x.2.1)
      + uEnt (fibreProd3 χ₁ χ₂ χ₃) (fun x => T₃ x.2.2)
      - uEnt (fibreProd3 χ₁ χ₂ χ₃) (fun x => (T₁ x.1, (T₂ x.2.1, T₃ x.2.2)))
      = 2 * Real.logb 2 (Fintype.card C) := by
  have hne := fibreProd3_nonempty χ₁ χ₂ χ₃
  have h1 := mutInfo3_1_23 hD
  have h2 := mutInfo3_23 hD
  rw [mutInfo, condEnt_eq_joint_sub hne] at h1 h2
  linarith

/-- **Co-information of three overlapping dials** is exactly `+log₂ |C|`:
`I(T₁;T₂) + I(T₁;T₃) - I(T₁;(T₂,T₃)) = log₂ |C|` — pure redundancy, no synergy. -/
theorem coInformation3 (hD : ThreeDialData χ₁ χ₂ χ₃ T₁ T₂ T₃) :
    mutInfo (fibreProd3 χ₁ χ₂ χ₃) (fun x => T₁ x.1) (fun x => T₂ x.2.1)
      + mutInfo (fibreProd3 χ₁ χ₂ χ₃) (fun x => T₁ x.1) (fun x => T₃ x.2.2)
      - mutInfo (fibreProd3 χ₁ χ₂ χ₃) (fun x => T₁ x.1) (fun x => (T₂ x.2.1, T₃ x.2.2))
      = Real.logb 2 (Fintype.card C) := by
  rw [mutInfo3_12 hD, mutInfo3_13 hD, mutInfo3_1_23 hD]
  ring

end ThreeDials

namespace S3

open Equiv Equiv.Perm

/-- The three-dial data for three `S₃` cubics with the same quadratic resolvent. -/
theorem threeDialData_S3 :
    ThreeDialData (sign : P3 →* ℤˣ) (sign : P3 →* ℤˣ) (sign : P3 →* ℤˣ) splitType splitType
      splitType :=
  ⟨sign_surjective _, sign_surjective _, sign_surjective _, ⟨signOfType, sign_eq_signOfType⟩,
    ⟨signOfType, sign_eq_signOfType⟩, ⟨signOfType, sign_eq_signOfType⟩⟩

/-- **Three `S₃` dials over one quadratic field**: total correlation exactly `2` bits and
co-information exactly `+1` bit. -/
theorem threeDials_S3 :
    uEnt (fibreProd3 sign sign sign) (fun x : P3 × (P3 × P3) => splitType x.1)
        + uEnt (fibreProd3 sign sign sign) (fun x : P3 × (P3 × P3) => splitType x.2.1)
        + uEnt (fibreProd3 sign sign sign) (fun x : P3 × (P3 × P3) => splitType x.2.2)
        - uEnt (fibreProd3 sign sign sign)
            (fun x : P3 × (P3 × P3) => (splitType x.1, (splitType x.2.1, splitType x.2.2))) = 2 ∧
      mutInfo (fibreProd3 sign sign sign) (fun x : P3 × (P3 × P3) => splitType x.1)
          (fun x => splitType x.2.1)
        + mutInfo (fibreProd3 sign sign sign) (fun x : P3 × (P3 × P3) => splitType x.1)
          (fun x => splitType x.2.2)
        - mutInfo (fibreProd3 sign sign sign) (fun x : P3 × (P3 × P3) => splitType x.1)
          (fun x => (splitType x.2.1, splitType x.2.2)) = 1 := by
  have hC : (Fintype.card ℤˣ : ℝ) = 2 := by
    have : Fintype.card ℤˣ = 2 := by decide
    exact_mod_cast this
  refine ⟨?_, ?_⟩
  · rw [totalCorrelation3 threeDialData_S3, hC]; simp
  · rw [coInformation3 threeDialData_S3, hC]; simp

end S3

end CyclicTypeChannel