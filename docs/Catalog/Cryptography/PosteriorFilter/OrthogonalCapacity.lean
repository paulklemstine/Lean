import Cryptography.TypeChannelMilestone.InfoCalculus
import Cryptography.PosteriorFilter.KeepRate

/-!
# Paper 131 — battery capacity rides channels orthogonal to the target

The keep-rate law (`Cryptography.PosteriorFilter.KeepRate`) shows that a filter's success
depends only on how many classes it keeps.  This file states the information-theoretic
side, in the finite Shannon calculus of `Cryptography.NonabelianTypeChannel.Entropy`:

* `entropy_eq_logb_of_flat` — a readout with equal fibres over a set `A` carries
  `log₂ |A|` bits.
* `mutualInfo_eq_zero_of_flat_posterior` — **flat posterior ⇒ zero channel**: if the
  conditional law of `X` on every fibre of `t` is uniform on a common set, then
  `I(X ; t) = 0`.
* `target_channel_zero` — for the uniform pair of factor residues `(a, b) ∈ G × G` and
  *any* public dial `φ(a b)`, the target residue receives exactly `0` bits.
* `battery_cond_channel_zero` — adding a second public dial to a battery adds `0`
  conditional bits about the target.
* `joint_capacity` and `capacity_orthogonal` — yet the same dial carries all of its
  entropy about the joint factor pair; the public residue itself carries `log₂ |G|` bits.
  Capacity is real, and orthogonal to the target.
* `factor_reading_dial_leaks`, `leak_certifies_nonpublic` — the audit criterion behind the
  "dummy dial v1" catch: a dial computed by reading a table through the factor leaks its
  full entropy, and any nonzero leak certifies that the dial is not computable from `N`.
* `units_three_capacity`, `units_three_leak` — the 1-bit `d2` dial instance on
  `(ZMod 3)ˣ`.
-/

namespace PosteriorFilter

open TypeChannel Finset Real

section Flat

variable {Ω α β : Type*} [DecidableEq α] [DecidableEq β]

/-- A readout whose fibres over the set `A` all have the same share `|S| / |A|` carries
exactly `log₂ |A|` bits. -/
theorem entropy_eq_logb_of_flat {S : Finset Ω} {X : Ω → α} {A : Finset α}
    (hS : S.Nonempty) (hA : ∀ w ∈ S, X w ∈ A)
    (h : ∀ a ∈ A, (fiber S X a).card * A.card = S.card) :
    entropy S X = logb 2 A.card := by
  have hSpos : 0 < S.card := Finset.card_pos.mpr hS
  obtain ⟨w0, hw0⟩ := hS
  have hApos : 0 < A.card := Finset.card_pos.mpr ⟨X w0, hA w0 hw0⟩
  have himg : S.image X = A := by
    apply Finset.Subset.antisymm
    · intro a ha
      obtain ⟨w, hw, rfl⟩ := mem_image.mp ha
      exact hA w hw
    · intro a ha
      have hpos : 0 < (fiber S X a).card := by
        rcases Nat.eq_zero_or_pos (fiber S X a).card with h0 | h0
        · have := h a ha; rw [h0, zero_mul] at this; omega
        · exact h0
      obtain ⟨w, hw⟩ := Finset.card_pos.mp hpos
      simp only [fiber, mem_filter] at hw
      exact mem_image.mpr ⟨w, hw.1, hw.2⟩
  have hk : ∀ a ∈ S.image X, (fiber S X a).card = (fiber S X (X w0)).card := by
    intro a ha
    rw [himg] at ha
    have h1 := h a ha
    have h2 := h (X w0) (hA w0 hw0)
    exact Nat.eq_of_mul_eq_mul_right hApos (h1.trans h2.symm)
  have hkpos : 0 < (fiber S X (X w0)).card :=
    Finset.card_pos.mpr ⟨w0, mem_filter.mpr ⟨hw0, rfl⟩⟩
  rw [entropy_eq_logb_card_of_uniform_fibers ⟨w0, hw0⟩ hkpos hk, himg]

/-- **Flat posterior ⇒ zero channel.**  Suppose the readout `X` takes values in `A` and,
on every fibre of the dial `t`, each value of `A` is taken by exactly a `1/|A|` share of the
fibre.  Then the dial carries no information about `X`. -/
theorem mutualInfo_eq_zero_of_flat_posterior {S : Finset Ω} {X : Ω → α} {t : Ω → β}
    {A : Finset α} (hS : S.Nonempty) (hA : ∀ w ∈ S, X w ∈ A)
    (hflat : ∀ b ∈ S.image t, ∀ a ∈ A,
      (fiber (fiber S t b) X a).card * A.card = (fiber S t b).card) :
    mutualInfo S X t = 0 := by
  have hfib : ∀ a, ∀ b, (fiber S X a).filter (fun w => t w = b) = fiber (fiber S t b) X a := by
    intro a b; ext w; simp only [fiber, mem_filter]; tauto
  have hX : entropy S X = logb 2 A.card := by
    refine entropy_eq_logb_of_flat hS hA (fun a ha => ?_)
    have hmap : ∀ w ∈ fiber S X a, t w ∈ S.image t :=
      fun w hw => mem_image_of_mem t (fiber_subset hw)
    rw [Finset.card_eq_sum_card_fiberwise hmap, Finset.sum_mul,
      Finset.card_eq_sum_card_fiberwise (fun w hw => mem_image_of_mem t hw)]
    refine Finset.sum_congr rfl (fun b hb => ?_)
    rw [hfib a b, hflat b hb a ha]
    rfl
  have hcond : ∀ b ∈ S.image t, entropy (fiber S t b) X = logb 2 A.card := by
    intro b hb
    obtain ⟨w, hw, hwb⟩ := mem_image.mp hb
    exact entropy_eq_logb_of_flat ⟨w, mem_filter.mpr ⟨hw, hwb⟩⟩
      (fun w hw => hA w (fiber_subset hw)) (hflat b hb)
  have hpair := entropy_pair_chain (S := S) X t
  rw [Finset.sum_congr rfl (fun b hb => by rw [hcond b hb]), ← Finset.sum_mul,
    sum_prob hS, one_mul] at hpair
  unfold mutualInfo
  rw [hpair, hX]; ring

end Flat

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

omit [DecidableEq G] in
/-- The number of factor pairs whose public dial shows `d` is `|G| · |φ⁻¹(d)|`. -/
theorem card_fiber_dial {β : Type*} [DecidableEq β] (φ : G → β) (d : β) :
    (fiber (univ : Finset (G × G)) (fun w => φ (w.1 * w.2)) d).card =
      Fintype.card G * (univ.filter (fun c : G => φ c = d)).card := by
  unfold fiber
  rw [Finset.card_filter, flat_transport (fun _ c => if φ c = d then 1 else 0),
    Finset.card_filter, Finset.mul_sum]
  refine Finset.sum_congr rfl (fun c _ => ?_)
  simp [Finset.card_univ]

/-- **Zero conversion.**  For the uniform pair of factor residues and *any* public dial
`φ` — any function of the public residue `a b` — the channel from the dial to the target
residue `a` is exactly zero bits. -/
theorem target_channel_zero {β : Type*} [DecidableEq β] (φ : G → β) :
    mutualInfo (univ : Finset (G × G)) (fun w => w.1) (fun w => φ (w.1 * w.2)) = 0 := by
  refine mutualInfo_eq_zero_of_flat_posterior (A := univ) univ_nonempty
    (fun w _ => mem_univ _) (fun d _ r _ => ?_)
  have h1 : fiber (fiber (univ : Finset (G × G)) (fun w => φ (w.1 * w.2)) d) (fun w => w.1) r =
      univ.filter (fun w : G × G => φ (w.1 * w.2) = d ∧ w.1 = r) := by
    ext w; simp [fiber]
  rw [h1, posterior_flat, card_fiber_dial, Finset.card_univ, mul_comm]

/-- **Batteries add nothing about the target.**  Stacking a second public dial on a first
adds exactly zero conditional bits about the target residue: `I(a ; T₂ | T₁) = 0`. -/
theorem battery_cond_channel_zero {β γ : Type*} [DecidableEq β] [DecidableEq γ]
    (φ₁ : G → β) (φ₂ : G → γ) :
    condMutualInfo (univ : Finset (G × G)) (fun w => w.1) (fun w => φ₂ (w.1 * w.2))
      (fun w => φ₁ (w.1 * w.2)) = 0 := by
  have hchain := mutualInfo_pair_chain (S := (univ : Finset (G × G))) (fun w => w.1)
    (fun w => φ₁ (w.1 * w.2)) (fun w => φ₂ (w.1 * w.2))
  have hbat : mutualInfo (univ : Finset (G × G)) (fun w => w.1)
      (pairObs (fun w : G × G => φ₁ (w.1 * w.2)) (fun w => φ₂ (w.1 * w.2))) = 0 :=
    target_channel_zero (fun c => (φ₁ c, φ₂ c))
  rw [hbat, target_channel_zero] at hchain
  linarith

/-- **Capacity is real but orthogonal.**  Every public dial carries all of its entropy
about the joint factor pair, and none of it about the target residue. -/
theorem capacity_orthogonal {β : Type*} [DecidableEq β] (φ : G → β) :
    mutualInfo (univ : Finset (G × G)) (fun w => w) (fun w => φ (w.1 * w.2)) =
        entropy (univ : Finset (G × G)) (fun w => φ (w.1 * w.2)) ∧
      mutualInfo (univ : Finset (G × G)) (fun w => w.1) (fun w => φ (w.1 * w.2)) = 0 := by
  refine ⟨?_, target_channel_zero φ⟩
  rw [mutualInfo_comm]
  exact mutualInfo_eq_left_of_factors (φ := fun w : G × G => φ (w.1 * w.2)) (fun _ _ => rfl)

/-- The public residue itself is a dial of full capacity `log₂ |G|` bits about the joint
factor pair. -/
theorem joint_capacity :
    mutualInfo (univ : Finset (G × G)) (fun w => w) (fun w => w.1 * w.2) =
      logb 2 (Fintype.card G) := by
  rw [(capacity_orthogonal (fun c : G => c)).1]
  rw [entropy_eq_logb_of_flat (A := univ) univ_nonempty (fun _ _ => mem_univ _)]
  · rw [Finset.card_univ]
  · intro c _
    have := card_fiber_dial (fun c : G => c) c
    simp only at this
    rw [this, Finset.card_univ, Finset.card_univ, Fintype.card_prod]
    have h1 : (univ.filter (fun c' : G => c' = c)).card = 1 := by
      rw [Finset.card_eq_one]; exact ⟨c, by ext; simp⟩
    rw [h1, mul_one]

omit [Group G] in
/-- **The leak of a factor-reading dial.**  A "dummy" dial computed by reading a table `ψ`
through the target residue carries its full entropy about the target. -/
theorem factor_reading_dial_leaks {β : Type*} [DecidableEq β] (ψ : G → β) :
    mutualInfo (univ : Finset (G × G)) (fun w => w.1) (fun w => ψ w.1) =
      entropy (univ : Finset (G × G)) (fun w => ψ w.1) := by
  rw [mutualInfo_comm]
  exact mutualInfo_eq_left_of_factors (φ := ψ) (fun _ _ => rfl)

/-- **The public-ness audit.**  A dial that leaks any information about the target residue
cannot be computed from the public number: it must read through the factors. -/
theorem leak_certifies_nonpublic {β : Type*} [DecidableEq β] (D : G × G → β)
    (hleak : mutualInfo (univ : Finset (G × G)) (fun w => w.1) D ≠ 0) :
    ¬ ∃ φ : G → β, ∀ w, D w = φ (w.1 * w.2) := by
  rintro ⟨φ, hφ⟩
  apply hleak
  rw [mutualInfo_congr (f' := fun w => w.1) (g' := fun w => φ (w.1 * w.2))
    (fun _ _ => rfl) (fun w _ => hφ w)]
  exact target_channel_zero φ

/-- The identity table read through the target residue leaks `log₂ |G|` bits. -/
theorem identity_table_leak :
    mutualInfo (univ : Finset (G × G)) (fun w => w.1) (fun w => w.1) =
      logb 2 (Fintype.card G) := by
  rw [factor_reading_dial_leaks (fun a : G => a)]
  rw [entropy_eq_logb_of_flat (A := univ) univ_nonempty (fun _ _ => mem_univ _)]
  · rw [Finset.card_univ]
  · intro a _
    have : fiber (univ : Finset (G × G)) (fun w => w.1) a = {a} ×ˢ univ := by
      ext ⟨x, y⟩; simp [fiber, eq_comm]
    rw [this, Finset.card_product, Finset.card_singleton, one_mul, Finset.card_univ,
      Finset.card_univ, Fintype.card_prod]

section UnitsThree

/-- `(ZMod 3)ˣ` has two elements. -/
theorem card_units_zmod_three : Fintype.card (ZMod 3)ˣ = 2 := by
  rw [ZMod.card_units_eq_totient, Nat.totient_prime Nat.prime_three]

/-- **The `d2` instance.**  On residues modulo 3 the public residue carries exactly one bit
about the factor pair. -/
theorem units_three_capacity :
    mutualInfo (univ : Finset ((ZMod 3)ˣ × (ZMod 3)ˣ)) (fun w => w) (fun w => w.1 * w.2) = 1 := by
  rw [joint_capacity, card_units_zmod_three]; simp

/-- …and exactly zero bits about the target residue, while a factor-reading dial on the same
residues leaks one full bit — the "dummy dial v1" catch. -/
theorem units_three_leak :
    mutualInfo (univ : Finset ((ZMod 3)ˣ × (ZMod 3)ˣ)) (fun w => w.1) (fun w => w.1 * w.2) = 0 ∧
      mutualInfo (univ : Finset ((ZMod 3)ˣ × (ZMod 3)ˣ)) (fun w => w.1) (fun w => w.1) = 1 := by
  refine ⟨target_channel_zero (fun c => c), ?_⟩
  rw [identity_table_leak, card_units_zmod_three]; simp

end UnitsThree

end PosteriorFilter