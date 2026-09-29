/-
# THE-LAW-IS-UNIVERSAL (paper 112): the sign channel depends only on the group

The FACT round-32 experiments report that the splitting type `T(p)` of primes in the
`S₃`-field of `x³ - 2` carries exactly one bit about the sign character, just as for
`x³ + x + 1`.  This file isolates the *group-theoretic* content of that observation
and proves it in complete generality, on top of the catalog's counting entropy
framework `CyclicTypeChannel.uEnt / condEnt / mutInfo`.

Main results.

* `uEnt_const_fiber` : if all fibres of `g` on `s` have the same size `c`,
  then `H(g) = log₂ |s| - log₂ c`.
* `uEnt_hom` : for any homomorphism `χ : G →* H` of finite groups, the push-forward
  of the uniform (Haar / Chebotarev) measure along `χ` is uniform on the image, so
  `H(χ) = log₂ |im χ|`.
* `condEnt_eq_zero_of_factor` : if `g` is a function of `k`, then `H(g | k) = 0`.
* `sign_channel_universal` : **the law is universal** — for *every* finite group `G`,
  *every* surjection `χ : G →* ℤˣ` and *every* "type" function `T` through which `χ`
  factors, `I(χ ; T) = 1` bit exactly.
* `S3_sign_channel` : the instance `G = S₃`, `χ = sign`, `T = cycle type`.  Every
  `S₃`-field (`x³ - 2`, `x³ + x + 1`, …) has Frobenius distributed by Chebotarev on
  `S₃`, hence the same one-bit channel.
* `S3_pair_sign_channel` : the semiprime pair channel `I(χ(g)χ(h) ; (T g, T h)) = 1`.
* `mutInfo_prod_indep` : independent coordinates carry zero mutual information;
  applied to `S₃ × C` it gives the "coprime moduli are flat" statement.
-/
import Shared.CyclicTypeChannel

namespace S3SignChannelUniversal

open Finset CyclicTypeChannel

variable {α β γ : Type*}

/-! ## 1. Entropy of equal-fibre maps and of factorised maps -/

/-- If every fibre of `g` on `s` has the same cardinality `c`, the entropy is
`log₂ |s| - log₂ c` (the push-forward is uniform on `|s| / c` values). -/
theorem uEnt_const_fiber [DecidableEq β] (s : Finset α) (g : α → β) (c : ℕ)
    (hc : ∀ a ∈ s, #{x ∈ s | g x = g a} = c) (hs : s.Nonempty) :
    uEnt s g = Real.logb 2 s.card - Real.logb 2 c := by
  have hN : (s.card : ℝ) ≠ 0 := by exact_mod_cast (card_pos.2 hs).ne'
  have hsum : (∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ))
      = s.card * Real.logb 2 c := by
    rw [Finset.sum_congr rfl (fun a ha => by rw [hc a ha]), sum_const, nsmul_eq_mul]
  rw [uEnt, hsum]
  field_simp

/-- A function that is constant on `s` carries no entropy. -/
lemma uEnt_eq_zero_of_const [DecidableEq β] (s : Finset α) (g : α → β)
    (hg : ∀ x ∈ s, ∀ y ∈ s, g x = g y) : uEnt s g = 0 := by
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [uEnt]
  rw [uEnt_const_fiber s g s.card ?_ hs, sub_self]
  intro a ha
  congr 1
  exact Finset.filter_true_of_mem fun x hx => hg x hx a ha

/-- If `g` is determined by `k` on `s` (i.e. `g` factors through `k`), the
conditional entropy `H(g | k)` vanishes. -/
theorem condEnt_eq_zero_of_factor [DecidableEq β] [DecidableEq γ]
    (s : Finset α) (g : α → β) (k : α → γ)
    (hf : ∀ x ∈ s, ∀ y ∈ s, k x = k y → g x = g y) : condEnt s g k = 0 := by
  refine Finset.sum_eq_zero fun c _ => ?_
  rw [uEnt_eq_zero_of_const, mul_zero]
  intro x hx y hy
  simp only [mem_filter] at hx hy
  exact hf x hx.1 y hy.1 (hx.2.trans hy.2.symm)

/-- If `g` factors through `k`, then `I(g ; k) = H(g)`: the type reveals all of `g`. -/
theorem mutInfo_eq_uEnt_of_factor [DecidableEq β] [DecidableEq γ]
    (s : Finset α) (g : α → β) (k : α → γ)
    (hf : ∀ x ∈ s, ∀ y ∈ s, k x = k y → g x = g y) : mutInfo s g k = uEnt s g := by
  rw [mutInfo, condEnt_eq_zero_of_factor s g k hf, sub_zero]

/-! ## 2. Push-forward of the uniform measure along a homomorphism -/

section Hom

variable {G H : Type*} [Group G] [Fintype G] [DecidableEq G] [Group H] [DecidableEq H]

omit [DecidableEq G] in
/-- Every fibre of a homomorphism is a coset of its kernel. -/
lemma card_fiber_hom (χ : G →* H) (a : G) :
    #{x ∈ (univ : Finset G) | χ x = χ a} = #{x ∈ (univ : Finset G) | χ x = 1} := by
  refine Finset.card_bij (fun x _ => a⁻¹ * x) ?_ ?_ ?_
  · intro x hx
    simp only [mem_filter, mem_univ, true_and] at hx ⊢
    rw [map_mul, map_inv, hx, inv_mul_cancel]
  · intro x _ y _ h
    simpa using h
  · intro y hy
    simp only [mem_filter, mem_univ, true_and] at hy
    refine ⟨a * y, ?_, by simp⟩
    simp [map_mul, hy]

omit [DecidableEq G] in
/-- The Haar push-forward along `χ` has entropy `log₂ |im χ|`: every homomorphic
image of the uniform distribution is uniform on the image. -/
theorem uEnt_hom (χ : G →* H) :
    uEnt univ χ = Real.logb 2 (Nat.card χ.range) := by
  classical
  set K := #{x ∈ (univ : Finset G) | χ x = 1}
  have hK : K = Nat.card χ.ker := by
    have : Nat.card χ.ker = Nat.card {x : G // χ x = 1} :=
      Nat.card_congr (Equiv.subtypeEquivRight fun x => by simp [MonoidHom.mem_ker])
    rw [this, Nat.card_eq_fintype_card, Fintype.card_subtype]
  have hmul : Nat.card χ.ker * Nat.card χ.range = Fintype.card G := by
    rw [← Subgroup.index_ker, Subgroup.card_mul_index, Nat.card_eq_fintype_card]
  have hKpos : 0 < Nat.card χ.ker := Nat.card_pos
  rw [uEnt_const_fiber univ χ K (fun a _ => card_fiber_hom χ a) univ_nonempty,
    card_univ, ← hmul, hK, Nat.cast_mul,
    Real.logb_mul (by exact_mod_cast hKpos.ne') (by exact_mod_cast Nat.card_pos.ne')]
  ring

omit [DecidableEq G] in
/-- A surjection onto a group with two elements splits the uniform measure into
two halves: exactly one bit. -/
theorem uEnt_surj_units (χ : G →* ℤˣ) (hχ : Function.Surjective χ) :
    uEnt univ χ = 1 := by
  rw [uEnt_hom, MonoidHom.range_eq_top.2 hχ, Subgroup.card_top, Nat.card_eq_fintype_card,
    Fintype.card_units_int]
  simp

end Hom

/-! ## 3. The universal sign-channel law -/

/-- **THE-LAW-IS-UNIVERSAL.**  For any finite group `G`, any surjective sign-type
character `χ : G →* ℤˣ` and any type function `T : G → τ` that determines `χ`,
the type channel carries exactly one bit about `χ`:
`I(χ ; T) = 1`.  Nothing about the particular polynomial enters: only the group,
the index-two subgroup `ker χ`, and the fact that `T` refines the coset decomposition. -/
theorem sign_channel_universal {G τ : Type*} [Group G] [Fintype G] [DecidableEq G]
    [DecidableEq τ] (χ : G →* ℤˣ) (hχ : Function.Surjective χ) (T : G → τ)
    (hT : ∀ g h, T g = T h → χ g = χ h) :
    mutInfo univ χ T = 1 := by
  rw [mutInfo_eq_uEnt_of_factor univ χ T (fun x _ y _ => hT x y), uEnt_surj_units χ hχ]

/-- The instance `S₃`: the sign of a Frobenius permutation is read off from its
cycle type, so the cycle-type (splitting-type) channel carries exactly one bit
about the sign character.  This is the same for every `S₃`-field. -/
theorem S3_sign_channel :
    mutInfo univ (Equiv.Perm.sign : Equiv.Perm (Fin 3) →* ℤˣ) Equiv.Perm.cycleType = 1 :=
  sign_channel_universal _ (Equiv.Perm.sign_surjective (Fin 3)) _
    (fun g h hgh => by rw [Equiv.Perm.sign_of_cycleType, Equiv.Perm.sign_of_cycleType, hgh])

/-- The same law for every symmetric group `S_n`, `n ≥ 2`. -/
theorem Sn_sign_channel (n : ℕ) (hn : 2 ≤ n) :
    mutInfo univ (Equiv.Perm.sign : Equiv.Perm (Fin n) →* ℤˣ) Equiv.Perm.cycleType = 1 := by
  haveI : Nontrivial (Fin n) := Fin.nontrivial_iff_two_le.2 hn
  exact sign_channel_universal _ (Equiv.Perm.sign_surjective (Fin n)) _
    (fun g h hgh => by rw [Equiv.Perm.sign_of_cycleType, Equiv.Perm.sign_of_cycleType, hgh])

/-- The product character `(g, h) ↦ χ g · χ h` on `G × G`: the sign of a
semiprime `n = p q` seen through its two prime factors. -/
def pairChar {G : Type*} [Group G] (χ : G →* ℤˣ) : G × G →* ℤˣ :=
  (χ.comp (MonoidHom.fst G G)) * (χ.comp (MonoidHom.snd G G))

lemma pairChar_apply {G : Type*} [Group G] (χ : G →* ℤˣ) (x : G × G) :
    pairChar χ x = χ x.1 * χ x.2 := rfl

/-- **Semiprime pair channel.**  The pair of types `(T g, T h)` of two independent
Frobenius elements carries exactly one bit about the product character. -/
theorem pair_sign_channel_universal {G τ : Type*} [Group G] [Fintype G] [DecidableEq G]
    [DecidableEq τ] (χ : G →* ℤˣ) (hχ : Function.Surjective χ) (T : G → τ)
    (hT : ∀ g h, T g = T h → χ g = χ h) :
    mutInfo univ (pairChar χ) (fun x : G × G => (T x.1, T x.2)) = 1 := by
  refine sign_channel_universal _ ?_ _ ?_
  · intro u
    obtain ⟨g, hg⟩ := hχ u
    exact ⟨(g, 1), by simp [pairChar_apply, hg]⟩
  · intro x y hxy
    simp only [Prod.mk.injEq] at hxy
    rw [pairChar_apply, pairChar_apply, hT _ _ hxy.1, hT _ _ hxy.2]

/-- The semiprime pair channel for `S₃ × S₃`: exactly one bit. -/
theorem S3_pair_sign_channel :
    mutInfo univ (pairChar (Equiv.Perm.sign : Equiv.Perm (Fin 3) →* ℤˣ))
      (fun x : Equiv.Perm (Fin 3) × Equiv.Perm (Fin 3) =>
        (x.1.cycleType, x.2.cycleType)) = 1 :=
  pair_sign_channel_universal _ (Equiv.Perm.sign_surjective (Fin 3)) _
    (fun g h hgh => by rw [Equiv.Perm.sign_of_cycleType, Equiv.Perm.sign_of_cycleType, hgh])

/-- The channel can never exceed one bit about a sign character, whatever the type:
`I(χ ; T) ≤ H(χ) = 1`. -/
theorem sign_channel_le_one {G τ : Type*} [Group G] [Fintype G] [DecidableEq G]
    [DecidableEq τ] (χ : G →* ℤˣ) (hχ : Function.Surjective χ) (T : G → τ) :
    mutInfo univ χ T ≤ 1 := by
  rw [mutInfo, uEnt_surj_units χ hχ]
  have : 0 ≤ condEnt univ χ T := by
    refine Finset.sum_nonneg fun c _ => mul_nonneg (by positivity) (uEnt_nonneg _ _)
  linarith

/-! ## 4. Independent coordinates are flat -/

section Indep

variable [DecidableEq α] [DecidableEq β] [DecidableEq γ] {δ : Type*} [DecidableEq δ]

omit [DecidableEq α] [DecidableEq δ] in
lemma filter_prod_fst (s : Finset α) (t : Finset δ) (g : α → β) (x : α × δ) :
    {y ∈ s ×ˢ t | g y.1 = g x.1} = {a ∈ s | g a = g x.1} ×ˢ t := by
  ext y; simp [and_right_comm]

omit [DecidableEq α] [DecidableEq δ] in
lemma filter_prod_snd (s : Finset α) (t : Finset δ) (k : δ → γ) (c : γ) :
    {y ∈ s ×ˢ t | k y.2 = c} = s ×ˢ {b ∈ t | k b = c} := by
  ext y; simp [and_assoc]

omit [DecidableEq α] [DecidableEq δ] in
/-- Entropy of a function of the first coordinate on a product is unchanged. -/
theorem uEnt_prod_fst (s : Finset α) (t : Finset δ) (g : α → β) (ht : t.Nonempty) :
    uEnt (s ×ˢ t) (fun x => g x.1) = uEnt s g := by
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [uEnt]
  have hS : (s.card : ℝ) ≠ 0 := by exact_mod_cast (card_pos.2 hs).ne'
  have hT : (t.card : ℝ) ≠ 0 := by exact_mod_cast (card_pos.2 ht).ne'
  have hsum : (∑ x ∈ s ×ˢ t, Real.logb 2 (#{y ∈ s ×ˢ t | g y.1 = g x.1} : ℝ))
      = t.card * ∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ)
        + s.card * t.card * Real.logb 2 t.card := by
    simp_rw [filter_prod_fst, card_product, Nat.cast_mul]
    rw [Finset.sum_product]
    have : ∀ a ∈ s, (∑ _b ∈ t, Real.logb 2 ((#{x ∈ s | g x = g a} : ℝ) * t.card))
        = t.card * Real.logb 2 (#{x ∈ s | g x = g a} : ℝ) + t.card * Real.logb 2 t.card := by
      intro a ha
      have hc : (#{x ∈ s | g x = g a} : ℝ) ≠ 0 := by exact_mod_cast (fiber_card_pos ha).ne'
      rw [sum_const, nsmul_eq_mul, Real.logb_mul hc hT]
      ring
    rw [Finset.sum_congr rfl this, sum_add_distrib, ← mul_sum, sum_const, nsmul_eq_mul]
    ring
  rw [uEnt, uEnt, hsum, card_product, Nat.cast_mul, Real.logb_mul hS hT]
  field_simp
  ring

omit [DecidableEq α] [DecidableEq δ] in
/-- **Flatness.**  If the "type" depends only on the first coordinate and the
"residue" only on the second, the residue carries zero information about the
type: `I(g ∘ fst ; k ∘ snd) = 0`.  With `G = S₃ × (ℤ/m)ˣ` (linear disjointness of
the `S₃`-field and `ℚ(ζ_m)`), this is the "coprime moduli are flat" law. -/
theorem mutInfo_prod_indep (s : Finset α) (t : Finset δ) (g : α → β) (k : δ → γ) :
    mutInfo (s ×ˢ t) (fun x => g x.1) (fun x => k x.2) = 0 := by
  rcases t.eq_empty_or_nonempty with rfl | ht
  · simp [mutInfo, uEnt, condEnt]
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [mutInfo, uEnt, condEnt]
  have hS : (s.card : ℝ) ≠ 0 := by exact_mod_cast (card_pos.2 hs).ne'
  have hT : (t.card : ℝ) ≠ 0 := by exact_mod_cast (card_pos.2 ht).ne'
  rw [mutInfo, uEnt_prod_fst s t g ht, condEnt]
  have himg : (s ×ˢ t).image (fun x => k x.2) = t.image k := by
    ext c; simp only [mem_image, mem_product, Prod.exists]
    constructor
    · rintro ⟨a, b, ⟨_, hb⟩, rfl⟩; exact ⟨b, hb, rfl⟩
    · rintro ⟨b, hb, rfl⟩
      obtain ⟨a, ha⟩ := hs
      exact ⟨a, b, ⟨ha, hb⟩, rfl⟩
  have hterm : ∀ c ∈ t.image k,
      ((#{x ∈ s ×ˢ t | k x.2 = c} : ℝ) / (s ×ˢ t).card) *
          uEnt {x ∈ s ×ˢ t | k x.2 = c} (fun x => g x.1)
        = ((#{b ∈ t | k b = c} : ℝ) / t.card) * uEnt s g := by
    intro c hc
    obtain ⟨b, hb, rfl⟩ := mem_image.1 hc
    have hne : ({b' ∈ t | k b' = k b}).Nonempty := ⟨b, by simp [hb]⟩
    rw [filter_prod_snd, uEnt_prod_fst s _ g hne, card_product, card_product, Nat.cast_mul,
      Nat.cast_mul]
    field_simp
  rw [himg, Finset.sum_congr rfl hterm, ← sum_mul, ← sum_div]
  have : (∑ c ∈ t.image k, (#{b ∈ t | k b = c} : ℝ)) = t.card := by
    exact_mod_cast sum_fiber_card t k
  rw [this, div_self hT, one_mul, sub_self]

/-- Coprime moduli are flat, group-level form: in `S₃ × C` (Frobenius of the
compositum of an `S₃`-field with a linearly disjoint abelian field with group `C`),
the abelian residue carries no information about the `S₃` cycle type. -/
theorem S3_coprime_flat {C : Type*} [Fintype C] [DecidableEq C] :
    mutInfo (univ : Finset (Equiv.Perm (Fin 3) × C))
      (fun x => x.1.cycleType) (fun x => x.2) = 0 := by
  have := mutInfo_prod_indep (univ : Finset (Equiv.Perm (Fin 3))) (univ : Finset C)
    Equiv.Perm.cycleType id
  simpa [univ_product_univ] using this

end Indep

end S3SignChannelUniversal