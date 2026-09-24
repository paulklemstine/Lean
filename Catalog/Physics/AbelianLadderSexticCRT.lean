/-
# Chain rule and CRT additivity of the single-prime type entropy

This file supplies the two general tools behind the degree-6 rung of the abelian
splitting-type ladder (`Physics.AbelianLadderCyclicSextic`).

1. **The chain rule of the counting entropy.**  For arbitrary read-outs `g, k`
   on a finite sample set,

   `H(g | k) = H(g, k) - H(k)`            (`condEnt_eq_uEnt_pair_sub`),

   so the catalog's mutual information has the symmetric Shannon form
   `I(g ; k) = H(g) + H(k) - H(g, k)` (`mutInfo_eq_symm_form`), is symmetric
   (`mutInfo_comm`), and equals `H(k)` whenever `k` is a function of `g`
   (`mutInfo_eq_uEnt_of_determines`).  The catalog so far only had the
   *definition* `I = H(g) - H(g | k)`; the chain rule is what makes statements
   such as "the quadratic subfield carries exactly one bit of the sextic type"
   meaningful.

2. **CRT additivity of the type entropy.**  For coprime cyclic orders,

   `H(T_{mn}) = H(T_m) + H(T_n)`          (`typeEntropy_mul_of_coprime`),

   the single-prime analogue of the catalog's `Ipair_mul_of_coprime`; iterating,
   the type entropy of `C_n` is the sum of the type entropies of its primary
   components (`typeEntropy_eq_sum_prime_powers`).  At `n = 6` this reads
   `H(T₆) = H(T₂) + H(T₃) = 1 + (log₂ 3 - 2/3)` (`typeEntropy_six_eq_two_add_three`):
   the sextic rung of the ladder carries *no information beyond* its quadratic
   and cubic rungs.

3. **The orthogonal split.**  For coprime `m, n` the composite type determines
   each component (`gcd_ordType_mul_of_coprime`: `T_m = gcd(T_{mn}, m)`), the
   composite type carries exactly `H(T_m)` resp. `H(T_n)` bits about the
   components, and the components are independent
   (`orthogonal_split_of_coprime`).
-/
import Physics.AbelianLadderCompositeLoss

namespace CyclicTypeChannel

open Finset

/-! ## 1. The chain rule -/

section ChainRule

variable {α β γ : Type*} [DecidableEq β] [DecidableEq γ]

/-- **Chain rule** for the counting entropy: `H(g | k) = H(g, k) - H(k)`. -/
theorem condEnt_eq_uEnt_pair_sub (s : Finset α) (g : α → β) (k : α → γ) :
    condEnt s g k = uEnt s (fun x => (g x, k x)) - uEnt s k := by
  classical
  rcases s.eq_empty_or_nonempty with rfl | hsne
  · simp [condEnt, uEnt]
  have hs : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hsne
  set L : α → ℝ := fun a => Real.logb 2 (#{x ∈ s | k x = k a} : ℝ) with hL
  set P : α → ℝ := fun a => Real.logb 2 (#{x ∈ s | (g x, k x) = (g a, k a)} : ℝ) with hP
  have hterm : ∀ c ∈ s.image k,
      ((#{x ∈ s | k x = c} : ℝ) / s.card) * uEnt {x ∈ s | k x = c} g
        = (∑ a ∈ {x ∈ s | k x = c}, (L a - P a)) / s.card := by
    intro c hc
    have hpos : (0 : ℝ) < #{x ∈ s | k x = c} := by
      obtain ⟨a, ha, rfl⟩ := mem_image.1 hc
      exact_mod_cast card_pos.2 ⟨a, by simp [ha]⟩
    have h1 : ∀ a ∈ {x ∈ s | k x = c}, L a = Real.logb 2 (#{x ∈ s | k x = c} : ℝ) := by
      intro a ha
      simp only [hL, (mem_filter.1 ha).2]
    have h2 : ∀ a ∈ {x ∈ s | k x = c},
        Real.logb 2 (#{x ∈ {x ∈ s | k x = c} | g x = g a} : ℝ) = P a := by
      intro a ha
      have : {x ∈ {x ∈ s | k x = c} | g x = g a} = {x ∈ s | (g x, k x) = (g a, k a)} := by
        ext x
        simp only [mem_filter, Prod.mk.injEq, (mem_filter.1 ha).2]
        tauto
      simp only [hP, this]
    rw [sum_sub_distrib, sum_congr rfl h1, sum_const, nsmul_eq_mul, uEnt,
      ← sum_congr rfl h2]
    field_simp
  rw [condEnt, sum_congr rfl hterm, ← sum_div,
    sum_fiberwise_of_maps_to (fun a ha => mem_image_of_mem k ha), sum_sub_distrib, uEnt, uEnt]
  ring

/-- **Symmetric Shannon form** of the mutual information:
`I(g ; k) = H(g) + H(k) - H(g, k)`. -/
theorem mutInfo_eq_symm_form (s : Finset α) (g : α → β) (k : α → γ) :
    mutInfo s g k = uEnt s g + uEnt s k - uEnt s (fun x => (g x, k x)) := by
  rw [mutInfo, condEnt_eq_uEnt_pair_sub]
  ring

/-- **Mutual information is symmetric.** -/
theorem mutInfo_comm (s : Finset α) (g : α → β) (k : α → γ) :
    mutInfo s g k = mutInfo s k g := by
  have hswap : uEnt s (fun x => (g x, k x)) = uEnt s (fun x => (k x, g x)) := by
    have := uEnt_comp_injOn (s := s) (g := fun x => (k x, g x)) (f := Prod.swap)
      (Set.injOn_of_injective Prod.swap_injective)
    exact this
  rw [mutInfo_eq_symm_form, mutInfo_eq_symm_form, hswap]
  ring

/-- If `k` is a function of `g` on `s`, the pair `(g, k)` induces the same
partition as `g`, so `H(g, k) = H(g)`. -/
theorem uEnt_pair_eq_of_determines {s : Finset α} {g : α → β} {k : α → γ}
    (h : ∀ x ∈ s, ∀ y ∈ s, g x = g y → k x = k y) :
    uEnt s (fun x => (g x, k x)) = uEnt s g := by
  have hfib : ∀ a ∈ s, {x ∈ s | (g x, k x) = (g a, k a)} = {x ∈ s | g x = g a} := by
    intro a ha
    refine Finset.filter_congr fun x hx => ?_
    simp only [Prod.mk.injEq]
    exact ⟨fun h' => h'.1, fun h' => ⟨h', h x hx a ha h'⟩⟩
  rw [uEnt, uEnt, Finset.sum_congr rfl fun a ha => by rw [hfib a ha]]

/-- **A coarsening is received in full**: if `k` is a function of `g`, then
`I(g ; k) = H(k)`. -/
theorem mutInfo_eq_uEnt_of_determines {s : Finset α} {g : α → β} {k : α → γ}
    (h : ∀ x ∈ s, ∀ y ∈ s, g x = g y → k x = k y) :
    mutInfo s g k = uEnt s k := by
  rw [mutInfo_eq_symm_form, uEnt_pair_eq_of_determines h]
  ring

end ChainRule

/-! ## 2. CRT additivity of the single-prime type entropy -/

/-- The CRT residue map on a single exponent. -/
def crtRes (m n : ℕ) (a : ℕ) : ℕ × ℕ := (a % m, a % n)

theorem crtRes_injOn {m n : ℕ} (h : Nat.Coprime m n) :
    Set.InjOn (crtRes m n) (range (m * n)) := by
  intro a ha b hb hab
  simp only [coe_range, Set.mem_Iio, crtRes, Prod.mk.injEq] at ha hb hab
  exact eq_of_mod_eq_mod h ha hb hab.1 hab.2

theorem image_crtRes {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (h : Nat.Coprime m n) :
    (range (m * n)).image (crtRes m n) = range m ×ˢ range n := by
  refine Finset.eq_of_subset_of_card_le ?_ ?_
  · intro x hx
    obtain ⟨a, -, rfl⟩ := mem_image.1 hx
    simp [crtRes, mem_product, Nat.mod_lt _ hm, Nat.mod_lt _ hn]
  · rw [card_image_of_injOn (crtRes_injOn h), card_product, card_range, card_range, card_range]

/-- **CRT additivity of the type entropy**: for coprime cyclic orders the
Frobenius-type entropy of `C_{mn}` is the sum of those of `C_m` and `C_n`. -/
theorem typeEntropy_mul_of_coprime {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (h : Nat.Coprime m n) :
    typeEntropy (m * n) = typeEntropy m + typeEntropy n := by
  classical
  set G : ℕ × ℕ → ℕ × ℕ := fun x => (ordType m x.1, ordType n x.2) with hG
  set f : ℕ × ℕ → ℕ := fun z => z.1 * z.2 with hf
  have hstep : ∀ a ∈ range (m * n), ordType (m * n) a = (f ∘ (G ∘ crtRes m n)) a := by
    intro a _
    simp only [hf, hG, crtRes, Function.comp_apply]
    rw [ordType_mul_of_coprime h, ordType_mod, ordType_mod]
  have hfinj : Set.InjOn f ((G ∘ crtRes m n) '' (range (m * n))) := by
    rintro z hz z' hz' hzz
    obtain ⟨a, -, rfl⟩ := hz
    obtain ⟨b, -, rfl⟩ := hz'
    simp only [hf, hG, crtRes, Function.comp_apply, Prod.mk.injEq] at hzz ⊢
    exact eq_of_mul_eq_mul_coprime h hm (ordType_dvd _) (ordType_dvd _) (ordType_dvd _)
      (ordType_dvd _) hzz
  have hrm : (range m).Nonempty := ⟨0, by simp [hm]⟩
  have hrn : (range n).Nonempty := ⟨0, by simp [hn]⟩
  calc typeEntropy (m * n) = uEnt (range (m * n)) (f ∘ (G ∘ crtRes m n)) := uEnt_congr hstep
    _ = uEnt (range (m * n)) (G ∘ crtRes m n) := uEnt_comp_injOn hfinj
    _ = uEnt ((range (m * n)).image (crtRes m n)) G :=
        (uEnt_image_injOn (crtRes_injOn h) G).symm
    _ = uEnt (range m ×ˢ range n) G := by rw [image_crtRes hm hn h]
    _ = typeEntropy m + typeEntropy n := uEnt_prod hrm hrn _ _

theorem typeEntropy_one : typeEntropy 1 = 0 :=
  uEnt_of_card_le_one (by simp) _

/-- **The type entropy is a sum over the primary components.**  The Frobenius
entropy of any cyclic order is determined by its prime-power rungs. -/
theorem typeEntropy_eq_sum_prime_powers {n : ℕ} (hn : n ≠ 0) :
    typeEntropy n = ∑ p ∈ n.primeFactors, typeEntropy (p ^ n.factorization p) := by
  have hmul : ∀ (a b : ℕ), Nat.Coprime a b →
      Real.exp (typeEntropy (a * b)) = Real.exp (typeEntropy a) * Real.exp (typeEntropy b) := by
    intro a b hab
    rcases Nat.eq_zero_or_pos a with rfl | ha
    · simp only [Nat.coprime_zero_left] at hab
      subst hab
      simp [typeEntropy_one]
    rcases Nat.eq_zero_or_pos b with rfl | hb
    · simp only [Nat.coprime_zero_right] at hab
      subst hab
      simp [typeEntropy_one]
    rw [typeEntropy_mul_of_coprime ha hb hab, Real.exp_add]
  have hone : Real.exp (typeEntropy 1) = 1 := by rw [typeEntropy_one, Real.exp_zero]
  have hfac := Nat.multiplicative_factorization (fun m => Real.exp (typeEntropy m)) hmul hone hn
  rw [Finsupp.prod, Nat.support_factorization] at hfac
  simp only at hfac
  rw [← Real.exp_sum] at hfac
  exact Real.exp_injective hfac

/-! ## 3. The orthogonal split of a coprime rung -/

/-- The component type is recovered from the composite type: `T_m = gcd(T_{mn}, m)`. -/
theorem gcd_ordType_mul_of_coprime {m n : ℕ} (h : Nat.Coprime m n) (a : ℕ) :
    Nat.gcd (ordType (m * n) a) m = ordType m a := by
  rw [ordType_mul_of_coprime h]
  have hy : Nat.Coprime (ordType n a) m := (h.symm).coprime_dvd_left (ordType_dvd a)
  rw [Nat.Coprime.gcd_mul_right_cancel _ hy]
  exact Nat.gcd_eq_left (ordType_dvd a)

/-- Seen from the composite sample `range (m n)`, the component type `T_m` has
exactly the entropy of the rung `C_m` (the CRT pushes the uniform law forward to
the uniform law). -/
theorem uEnt_range_mul_ordType_left {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (h : Nat.Coprime m n) :
    uEnt (range (m * n)) (ordType m) = typeEntropy m := by
  classical
  have hrm : (range m).Nonempty := ⟨0, by simp [hm]⟩
  have hrn : (range n).Nonempty := ⟨0, by simp [hn]⟩
  set G : ℕ × ℕ → ℕ × ℕ := fun x => (ordType m x.1, (fun _ : ℕ => 0) x.2) with hG
  have hconst : uEnt (range n) (fun _ : ℕ => 0) = 0 := by
    rw [uEnt]
    have : ∀ a ∈ range n, #{x ∈ range n | (fun _ : ℕ => 0) x = (fun _ : ℕ => 0) a} = (range n).card :=
      fun a _ => by simp
    rw [Finset.sum_congr rfl fun a ha => by rw [this a ha], sum_const, nsmul_eq_mul]
    have hc : ((range n).card : ℝ) ≠ 0 := by simp; omega
    field_simp
    ring
  calc uEnt (range (m * n)) (ordType m)
      = uEnt (range (m * n)) (G ∘ crtRes m n) := by
        refine AbelianLadder.uEnt_congr_fibers fun x _ y _ => ?_
        simp [hG, crtRes, ordType_mod]
    _ = uEnt ((range (m * n)).image (crtRes m n)) G :=
        (uEnt_image_injOn (crtRes_injOn h) G).symm
    _ = uEnt (range m ×ˢ range n) G := by rw [image_crtRes hm hn h]
    _ = typeEntropy m := by
        have hp := uEnt_prod hrm hrn (ordType m) (fun _ : ℕ => (0 : ℕ))
        rw [hconst, add_zero] at hp
        exact hp

/-- **The orthogonal split of a coprime rung.**  For coprime `m, n`, the composite
type `T_{mn}` carries exactly `H(T_m)` bits about the `m`-component and exactly
`H(T_n)` bits about the `n`-component; these add up to `H(T_{mn})`, and the two
components are independent (`I(T_m ; T_n) = 0`). -/
theorem orthogonal_split_of_coprime {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (h : Nat.Coprime m n) :
    mutInfo (range (m * n)) (ordType (m * n)) (ordType m) = typeEntropy m ∧
    mutInfo (range (m * n)) (ordType (m * n)) (ordType n) = typeEntropy n ∧
    mutInfo (range (m * n)) (ordType m) (ordType n) = 0 := by
  have hTm : uEnt (range (m * n)) (ordType m) = typeEntropy m :=
    uEnt_range_mul_ordType_left hm hn h
  have hTn : uEnt (range (m * n)) (ordType n) = typeEntropy n := by
    rw [mul_comm]; exact uEnt_range_mul_ordType_left hn hm h.symm
  refine ⟨?_, ?_, ?_⟩
  · rw [mutInfo_eq_uEnt_of_determines (fun x _ y _ hxy => by
      rw [← gcd_ordType_mul_of_coprime h x, ← gcd_ordType_mul_of_coprime h y, hxy]), hTm]
  · rw [mutInfo_eq_uEnt_of_determines (fun x _ y _ hxy => by
      rw [← gcd_ordType_mul_of_coprime h.symm x, ← gcd_ordType_mul_of_coprime h.symm y,
        mul_comm n m, hxy]), hTn]
  · have hpair : uEnt (range (m * n)) (fun x => (ordType m x, ordType n x))
        = typeEntropy (m * n) := by
      refine AbelianLadder.uEnt_congr_fibers fun x _ y _ => ?_
      constructor
      · intro hxy
        simp only [Prod.mk.injEq] at hxy
        rw [ordType_mul_of_coprime h, ordType_mul_of_coprime h, hxy.1, hxy.2]
      · intro hxy
        simp only [Prod.mk.injEq]
        exact ⟨by rw [← gcd_ordType_mul_of_coprime h x, ← gcd_ordType_mul_of_coprime h y, hxy],
          by rw [← gcd_ordType_mul_of_coprime h.symm x, ← gcd_ordType_mul_of_coprime h.symm y,
            mul_comm n m, hxy]⟩
    rw [mutInfo_eq_symm_form, hTm, hTn, hpair, typeEntropy_mul_of_coprime hm hn h]
    ring

/-- **The sextic rung is the sum of the quadratic and cubic rungs.** -/
theorem typeEntropy_six_eq_two_add_three : typeEntropy 6 = typeEntropy 2 + typeEntropy 3 :=
  typeEntropy_mul_of_coprime (m := 2) (n := 3) (by norm_num) (by norm_num) (by norm_num)

/-- The same identity, evaluated: `1/3 + log₂ 3 = 1 + (log₂ 3 - 2/3)`, now as a
*consequence* of CRT rather than of two separate enumerations. -/
theorem typeEntropy_six_decomposed :
    typeEntropy 6 = 1 + (Real.logb 2 3 - 2 / 3) ∧ typeEntropy 6 = 1 / 3 + Real.logb 2 3 := by
  rw [typeEntropy_six_eq_two_add_three, typeEntropy_val_2, typeEntropy_val_3]
  constructor <;> ring

end CyclicTypeChannel