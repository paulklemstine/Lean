/-
# CRT additivity of the subfield type entropy

The catalog proves multiplicativity of the *semiprime pair* channel
(`IpairOrd_mul_of_coprime`) but leaves the simpler single-prime channel open.
This file closes that gap: for coprime cyclic orders the splitting-type entropy is
**additive**,

`typeEntropy (m * n) = typeEntropy m + typeEntropy n`   (`Nat.Coprime m n`),

so every type entropy is the sum of its prime-power contributions.

The proof has three independent ingredients:

* `uEnt_congr_fibers` — two read-outs with the same fibres have the same entropy;
  applied to `ordType (m n) a` versus the *pair* `(ordType m a, ordType n a)`,
  which have identical fibres because a product of coprime divisors determines its
  factors (`eq_of_mul_eq_mul_coprime`);
* `crt_fiber_one` — the Chinese Remainder map `a ↦ (a mod m, a mod n)` is a
  uniform cover of `range m ×ˢ range n` with fibre size `1`, so the uniform-cover
  invariance of `Bridges.CyclicSubfieldUniformCover` transports the entropy;
* `uEnt_product` — entropy of a coordinatewise read-out on a product set is the sum
  of the two entropies.

Consequences recorded here: `typeEntropy_six_split` (`H(T₆) = H(T₂) + H(T₃)`) and
`typeEntropy_twelve_split` (`H(T₁₂) = H(T₄) + H(T₃)`) for the conductor-13 tower —
now theorems about the channel rather than checks on the value table.
-/
import Bridges.CyclicSubfieldTower
import Shared.CyclicTypeChannelCRTLaw

namespace CyclicSubfield

open Finset hiding box
open CyclicTypeChannel

/-! ## 1. Two elementary entropy lemmas -/

variable {α α' β γ : Type*} [DecidableEq β] [DecidableEq γ]

/-- Entropy only depends on the partition into fibres. -/
theorem uEnt_congr_fibers {s : Finset α} {f : α → β} {g : α → γ}
    (h : ∀ a ∈ s, {x ∈ s | f x = f a} = {x ∈ s | g x = g a}) :
    uEnt s f = uEnt s g := by
  rw [uEnt, uEnt, Finset.sum_congr rfl (fun a ha => by rw [h a ha])]

/-- **Entropy of a product read-out on a product set is additive.** -/
theorem uEnt_product {s : Finset α} {t : Finset α'} (hs : s.Nonempty) (ht : t.Nonempty)
    (f : α → β) (g : α' → γ) :
    uEnt (s ×ˢ t) (fun x => (f x.1, g x.2)) = uEnt s f + uEnt t g := by
  classical
  have hsR : (0 : ℝ) < (s.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hs
  have htR : (0 : ℝ) < (t.card : ℝ) := by exact_mod_cast Finset.card_pos.2 ht
  have hfib : ∀ a ∈ s, ∀ b ∈ t,
      #{y ∈ s ×ˢ t | (f y.1, g y.2) = (f a, g b)}
        = #{a' ∈ s | f a' = f a} * #{b' ∈ t | g b' = g b} := by
    intro a _ b _
    have hset : {y ∈ s ×ˢ t | (f y.1, g y.2) = (f a, g b)}
        = {a' ∈ s | f a' = f a} ×ˢ {b' ∈ t | g b' = g b} := by
      ext y
      simp only [mem_filter, Finset.mem_product, Prod.ext_iff]
      tauto
    rw [hset, Finset.card_product]
  have hsum : ∑ x ∈ s ×ˢ t, Real.logb 2 (#{y ∈ s ×ˢ t | (f y.1, g y.2) = (f x.1, g x.2)} : ℝ)
      = (t.card : ℝ) * (∑ a ∈ s, Real.logb 2 (#{a' ∈ s | f a' = f a} : ℝ))
        + (s.card : ℝ) * (∑ b ∈ t, Real.logb 2 (#{b' ∈ t | g b' = g b} : ℝ)) := by
    rw [Finset.sum_product]
    have hterm : ∀ a ∈ s, ∑ b ∈ t,
        Real.logb 2 (#{y ∈ s ×ˢ t | (f y.1, g y.2) = (f a, g b)} : ℝ)
          = (t.card : ℝ) * Real.logb 2 (#{a' ∈ s | f a' = f a} : ℝ)
            + ∑ b ∈ t, Real.logb 2 (#{b' ∈ t | g b' = g b} : ℝ) := by
      intro a ha
      have hb : ∀ b ∈ t, Real.logb 2 (#{y ∈ s ×ˢ t | (f y.1, g y.2) = (f a, g b)} : ℝ)
          = Real.logb 2 (#{a' ∈ s | f a' = f a} : ℝ)
            + Real.logb 2 (#{b' ∈ t | g b' = g b} : ℝ) := by
        intro b hb
        have hpa : (0 : ℝ) < (#{a' ∈ s | f a' = f a} : ℝ) := by
          exact_mod_cast fiber_card_pos ha
        have hpb : (0 : ℝ) < (#{b' ∈ t | g b' = g b} : ℝ) := by
          exact_mod_cast fiber_card_pos hb
        rw [hfib a ha b hb]
        push_cast
        rw [Real.logb_mul (ne_of_gt hpa) (ne_of_gt hpb)]
      rw [Finset.sum_congr rfl hb, Finset.sum_add_distrib, Finset.sum_const, nsmul_eq_mul]
    rw [Finset.sum_congr rfl hterm, Finset.sum_add_distrib, Finset.sum_const, nsmul_eq_mul,
      ← Finset.mul_sum]
  have hcard : ((s ×ˢ t).card : ℝ) = (s.card : ℝ) * (t.card : ℝ) := by
    rw [Finset.card_product]; push_cast; ring
  rw [uEnt, uEnt, uEnt, hsum, hcard,
    Real.logb_mul (ne_of_gt hsR) (ne_of_gt htR)]
  field_simp
  ring

/-! ## 2. The Chinese Remainder map is a uniform cover with fibre size one -/

/-- **CRT as a uniform cover.**  For coprime `m, n` the reduction
`a ↦ (a mod m, a mod n)` maps `range (m * n)` onto `range m ×ˢ range n` with every
fibre a single point. -/
theorem crt_fiber_one {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (h : Nat.Coprime m n) :
    ∀ y ∈ (range m) ×ˢ (range n), #{a ∈ range (m * n) | (a % m, a % n) = y} = 1 := by
  intro y hy
  simp only [Finset.mem_product, mem_range] at hy
  have hle : #{a ∈ range (m * n) | (a % m, a % n) = y} ≤ 1 := by
    rw [Finset.card_le_one]
    intro a ha b hb
    simp only [mem_filter, mem_range, Prod.ext_iff] at ha hb
    exact eq_of_mod_eq_mod h ha.1 hb.1 (ha.2.1.trans hb.2.1.symm) (ha.2.2.trans hb.2.2.symm)
  have hpos : 0 < #{a ∈ range (m * n) | (a % m, a % n) = y} := by
    obtain ⟨k, hk1, hk2⟩ := Nat.chineseRemainder h y.1 y.2
    refine Finset.card_pos.2 ⟨k % (m * n), ?_⟩
    have hmn : 0 < m * n := Nat.mul_pos hm hn
    have h1 : (k % (m * n)) % m = y.1 := by
      rw [Nat.mod_mod_of_dvd k (Dvd.intro n rfl)]
      have : k % m = y.1 % m := hk1
      rw [this, Nat.mod_eq_of_lt hy.1]
    have h2 : (k % (m * n)) % n = y.2 := by
      rw [Nat.mod_mod_of_dvd k (Dvd.intro_left m rfl)]
      have : k % n = y.2 % n := hk2
      rw [this, Nat.mod_eq_of_lt hy.2]
    simp only [mem_filter, mem_range, Prod.ext_iff]
    exact ⟨Nat.mod_lt _ hmn, h1, h2⟩
  omega

/-! ## 3. CRT additivity of the type entropy -/

/-- The product read-out and the pair read-out of the splitting types have the same
fibres, because a product of coprime divisors determines both factors. -/
theorem fibers_ordType_eq_pair {m n : ℕ} (hm : 0 < m) (h : Nat.Coprime m n)
    (a : ℕ) :
    {x ∈ range (m * n) | ordType (m * n) x = ordType (m * n) a}
      = {x ∈ range (m * n) | (ordType m x, ordType n x) = (ordType m a, ordType n a)} := by
  ext x
  simp only [mem_filter, mem_range, Prod.ext_iff]
  constructor
  · rintro ⟨hx, he⟩
    rw [ordType_mul_of_coprime h, ordType_mul_of_coprime h] at he
    exact ⟨hx, eq_of_mul_eq_mul_coprime h hm (ordType_dvd x) (ordType_dvd a)
      (ordType_dvd x) (ordType_dvd a) he⟩
  · rintro ⟨hx, he1, he2⟩
    refine ⟨hx, ?_⟩
    rw [ordType_mul_of_coprime h, ordType_mul_of_coprime h, he1, he2]

/-- **CRT additivity of the splitting-type channel.**  For coprime cyclic orders,
`H(T_{mn}) = H(T_m) + H(T_n)`: the primary components of the Galois group
contribute independently. -/
theorem typeEntropy_mul_of_coprime {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (h : Nat.Coprime m n) :
    typeEntropy (m * n) = typeEntropy m + typeEntropy n := by
  classical
  have hmn : 0 < m * n := Nat.mul_pos hm hn
  -- step 1: replace the product type by the pair of types
  have step1 : uEnt (range (m * n)) (ordType (m * n))
      = uEnt (range (m * n)) (fun x => (ordType m x, ordType n x)) :=
    uEnt_congr_fibers (fun a _ => fibers_ordType_eq_pair hm h a)
  -- step 2: CRT relabelling (a uniform cover with fibre size one)
  have hmaps : ∀ a ∈ range (m * n), (a % m, a % n) ∈ (range m) ×ˢ (range n) := by
    intro a _
    simp only [Finset.mem_product, mem_range]
    exact ⟨Nat.mod_lt _ hm, Nat.mod_lt _ hn⟩
  have ht : ((range m) ×ˢ (range n)).Nonempty :=
    ⟨(0, 0), by simp only [Finset.mem_product, mem_range]; exact ⟨hm, hn⟩⟩
  have step2 : uEnt (range (m * n)) (fun x => (ordType m x, ordType n x))
      = uEnt ((range m) ×ˢ (range n)) (fun y => (ordType m y.1, ordType n y.2)) := by
    have hcov := uEnt_of_uniform_cover (s := range (m * n)) (t := (range m) ×ˢ (range n))
      (φ := fun a => (a % m, a % n)) (r := 1) Nat.one_pos ht hmaps (crt_fiber_one hm hn h)
      (fun y => (ordType m y.1, ordType n y.2))
    have hcomp : ((fun y : ℕ × ℕ => (ordType m y.1, ordType n y.2)) ∘ fun a => (a % m, a % n))
        = fun x => (ordType m x, ordType n x) := by
      funext a
      simp [Function.comp, ordType_mod]
    rwa [hcomp] at hcov
  -- step 3: entropy of a product read-out is additive
  have step3 : uEnt ((range m) ×ˢ (range n)) (fun y => (ordType m y.1, ordType n y.2))
      = typeEntropy m + typeEntropy n :=
    uEnt_product ⟨0, mem_range.2 hm⟩ ⟨0, mem_range.2 hn⟩ (ordType m) (ordType n)
  rw [typeEntropy, step1, step2, step3]

/-- `H(T₆) = H(T₂) + H(T₃)`: the sextic subfield of `Q(ζ₁₃)` splits into its
quadratic and cubic parts. -/
theorem typeEntropy_six_split : typeEntropy 6 = typeEntropy 2 + typeEntropy 3 := by
  have h := typeEntropy_mul_of_coprime (m := 2) (n := 3) (by norm_num) (by norm_num)
    (by norm_num)
  norm_num at h
  exact h

/-- `H(T₁₂) = H(T₄) + H(T₃)`: the full conductor-13 channel splits into its
`2`-primary and `3`-primary parts. -/
theorem typeEntropy_twelve_split : typeEntropy 12 = typeEntropy 4 + typeEntropy 3 := by
  have h := typeEntropy_mul_of_coprime (m := 4) (n := 3) (by norm_num) (by norm_num)
    (by norm_num)
  norm_num at h
  exact h

/-- The `3`-primary part of the conductor-13 channel is exactly the cubic subfield
entropy, and the `2`-primary part is exactly `3/2` bits. -/
theorem conductor13_primary_decomposition :
    typeEntropy 12 = 3 / 2 + (Real.logb 2 3 - 2 / 3) := by
  rw [typeEntropy_twelve_split, typeEntropy_val_4, typeEntropy_three]

end CyclicSubfield