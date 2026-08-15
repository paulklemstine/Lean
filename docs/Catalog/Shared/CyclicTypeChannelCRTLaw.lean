/-
# The CRT additivity law for the splitting-type channel

The exact evaluations show an arithmetic law behind the numbers: for coprime
cyclic orders the type-pair channel is *additive*,

  `I_pair (m * n) = I_pair m + I_pair n`.

This file proves the law in general (for the ordered type pair) from three
ingredients:

* the Chinese Remainder Theorem, which relabels the sample set `box (m*n)` as
  the product `box m ×ˢ box n`;
* the multiplicativity of the splitting type,
  `ord_{mn}(a) = ord_m(a) · ord_n(a)`, together with the fact that this
  factorisation is an *injective recoding* of the pair of component types;
* the additivity of the counting channel over independent products
  (`mutInfo_prod`).

The consequence is a structural explanation of the growth table:
the information of a cyclic order is a sum of primary contributions, so the
one-bit binary cap can be exceeded simply by multiplying orders together.
-/
import Shared.CyclicTypeChannelProduct
import Shared.CyclicTypeChannelSymmetry

namespace CyclicTypeChannel

open Finset

/-! ## 1. The ordered type-pair channel -/

/-- The **ordered** splitting-type pair `(T(p), T(q))` of a semiprime `N = p q`. -/
def ordPair (n : ℕ) (p : ℕ × ℕ) : ℕ × ℕ := (ordType n p.1, ordType n p.2)

/-- The ordered type-pair channel `I((T(p),T(q)) ; N mod f)`. -/
noncomputable def IpairOrd (n : ℕ) : ℝ := mutInfo (box n) (ordPair n) (prodRes n)

lemma ordType_pos {n : ℕ} (hn : 0 < n) (a : ℕ) : 0 < ordType n a :=
  Nat.div_pos (Nat.le_of_dvd hn (Nat.gcd_dvd_right a n)) (Nat.gcd_pos_of_pos_right a hn)

/-! ## 2. Multiplicativity of the splitting type -/

/-- **The splitting type is multiplicative in the order.**  For coprime `m, n`
the type of an exponent in `C_{mn}` is the product of its types in `C_m` and
`C_n`; this is the type-level shadow of `C_{mn} ≅ C_m × C_n`. -/
theorem ordType_mul_of_coprime {m n : ℕ} (h : Nat.Coprime m n) (a : ℕ) :
    ordType (m * n) a = ordType m a * ordType n a := by
  rw [ordType, ordType, ordType, h.gcd_mul a,
    Nat.div_mul_div_comm (Nat.gcd_dvd_right a m) (Nat.gcd_dvd_right a n)]

/-- Splitting the product of a divisor of `m` with a divisor of `n` back into its
two factors is unambiguous when `m` and `n` are coprime. -/
theorem eq_of_mul_eq_mul_coprime {m n x x' y y' : ℕ} (h : Nat.Coprime m n) (hm : 0 < m)
    (hx : x ∣ m) (hx' : x' ∣ m) (hy : y ∣ n) (hy' : y' ∣ n) (he : x * y = x' * y') :
    x = x' ∧ y = y' := by
  have hxm : Nat.gcd (x * y) m = x := by
    rw [Nat.Coprime.gcd_mul_right_cancel x (Nat.Coprime.coprime_dvd_left hy h.symm)]
    exact Nat.gcd_eq_left hx
  have hxm' : Nat.gcd (x' * y') m = x' := by
    rw [Nat.Coprime.gcd_mul_right_cancel x' (Nat.Coprime.coprime_dvd_left hy' h.symm)]
    exact Nat.gcd_eq_left hx'
  have hxx : x = x' := by rw [← hxm, ← hxm', he]
  refine ⟨hxx, ?_⟩
  have hxpos : 0 < x := Nat.pos_of_dvd_of_pos hx hm
  subst hxx
  exact Nat.eq_of_mul_eq_mul_left hxpos he

/-! ## 3. The CRT relabelling of the sample set -/

/-- The Chinese Remainder relabelling of a pair of exponents mod `m * n`. -/
def crtMap (m n : ℕ) (p : ℕ × ℕ) : (ℕ × ℕ) × (ℕ × ℕ) :=
  ((p.1 % m, p.2 % m), (p.1 % n, p.2 % n))

/-- CRT uniqueness in the form used below. -/
theorem eq_of_mod_eq_mod {m n : ℕ} (h : Nat.Coprime m n) {a b : ℕ} (ha : a < m * n)
    (hb : b < m * n) (h1 : a % m = b % m) (h2 : a % n = b % n) : a = b := by
  have : a ≡ b [MOD m * n] := (Nat.modEq_and_modEq_iff_modEq_mul h).1 ⟨h1, h2⟩
  have := this
  rw [Nat.ModEq, Nat.mod_eq_of_lt ha, Nat.mod_eq_of_lt hb] at this
  exact this

theorem crtMap_injOn {m n : ℕ} (h : Nat.Coprime m n) :
    Set.InjOn (crtMap m n) (box (m * n)) := by
  rintro ⟨a, b⟩ hab ⟨a', b'⟩ hab' he
  simp only [box, coe_product, Set.mem_prod, mem_coe, mem_range] at hab hab'
  simp only [crtMap, Prod.mk.injEq] at he
  obtain ⟨⟨ha1, hb1⟩, ⟨ha2, hb2⟩⟩ := he
  rw [Prod.mk.injEq]
  exact ⟨eq_of_mod_eq_mod h hab.1 hab'.1 ha1 ha2, eq_of_mod_eq_mod h hab.2 hab'.2 hb1 hb2⟩

theorem image_crtMap {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (h : Nat.Coprime m n) :
    (box (m * n)).image (crtMap m n) = box m ×ˢ box n := by
  refine Finset.eq_of_subset_of_card_le ?_ ?_
  · intro x hx
    obtain ⟨⟨a, b⟩, hab, rfl⟩ := mem_image.1 hx
    simp only [box, mem_product, mem_range] at hab ⊢
    exact ⟨⟨Nat.mod_lt _ hm, Nat.mod_lt _ hm⟩, ⟨Nat.mod_lt _ hn, Nat.mod_lt _ hn⟩⟩
  · rw [Finset.card_image_of_injOn (crtMap_injOn h)]
    simp only [box, card_product, card_range]
    exact le_of_eq (by ring)

/-! ## 4. The additivity law -/

/-- **CRT additivity of the splitting-type channel.**  For coprime cyclic orders
the (ordered) type-pair information splits as a sum over the primary components:
`I(m·n) = I(m) + I(n)`.  This is the exact law behind the observed values
`I(6) = I(2)+I(3)`, `I(10) = I(2)+I(5)`, `I(12) = I(4)+I(3)`,
`I(15) = I(3)+I(5)`. -/
theorem IpairOrd_mul_of_coprime {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (h : Nat.Coprime m n) :
    IpairOrd (m * n) = IpairOrd m + IpairOrd n := by
  classical
  -- the coordinatewise read-out and conditioning variable on the product
  set G : ((ℕ × ℕ) × (ℕ × ℕ)) → (ℕ × ℕ) × (ℕ × ℕ) := fun X => (ordPair m X.1, ordPair n X.2)
    with hG
  set K : ((ℕ × ℕ) × (ℕ × ℕ)) → ℕ × ℕ := fun X => (prodRes m X.1, prodRes n X.2) with hK
  -- the multiplicative recoding of a pair of component types
  set f : ((ℕ × ℕ) × (ℕ × ℕ)) → ℕ × ℕ := fun z => (z.1.1 * z.2.1, z.1.2 * z.2.2) with hf
  -- the residue-splitting recoding of the product residue
  set d : ℕ → ℕ × ℕ := fun z => (z % m, z % n) with hd
  have hbm : (box m).Nonempty := ⟨(0, 0), by simp [box, mem_product, hm]⟩
  have hbn : (box n).Nonempty := ⟨(0, 0), by simp [box, mem_product, hn]⟩
  -- step 1 : the `m*n` read-out is the multiplicative recoding of the CRT read-out
  have hstep1 : ∀ p ∈ box (m * n), ordPair (m * n) p = (f ∘ (G ∘ crtMap m n)) p := by
    intro p _
    simp only [hf, hG, crtMap, Function.comp_apply, ordPair, Prod.mk.injEq]
    constructor
    · rw [ordType_mul_of_coprime h, ordType_mod, ordType_mod]
    · rw [ordType_mul_of_coprime h, ordType_mod, ordType_mod]
  have hstep2 : ∀ p ∈ box (m * n), (d ∘ prodRes (m * n)) p = (K ∘ crtMap m n) p := by
    intro p _
    simp only [hd, hK, crtMap, Function.comp_apply, prodRes, Prod.mk.injEq]
    constructor
    · rw [Nat.mod_mod_of_dvd _ ⟨n, rfl⟩, Nat.add_mod]
    · rw [Nat.mod_mod_of_dvd _ ⟨m, mul_comm m n⟩, Nat.add_mod]
  -- step 3 : the multiplicative recoding is injective on the values that occur
  have hfinj : Set.InjOn f ((G ∘ crtMap m n) '' (box (m * n))) := by
    rintro z hz z' hz' hzz
    obtain ⟨p, -, rfl⟩ := hz
    obtain ⟨p', -, rfl⟩ := hz'
    simp only [hf, hG, crtMap, Function.comp_apply, ordPair, Prod.mk.injEq] at hzz ⊢
    obtain ⟨h1, h2⟩ := hzz
    have e1 := eq_of_mul_eq_mul_coprime h hm (ordType_dvd (n := m) _) (ordType_dvd (n := m) _)
      (ordType_dvd (n := n) _) (ordType_dvd (n := n) _) h1
    have e2 := eq_of_mul_eq_mul_coprime h hm (ordType_dvd (n := m) _) (ordType_dvd (n := m) _)
      (ordType_dvd (n := n) _) (ordType_dvd (n := n) _) h2
    exact ⟨⟨e1.1, e2.1⟩, ⟨e1.2, e2.2⟩⟩
  -- step 4 : the residue-splitting recoding is injective on the residues that occur
  have hdinj : Set.InjOn d (prodRes (m * n) '' (box (m * n))) := by
    rintro z hz z' hz' hzz
    obtain ⟨p, -, rfl⟩ := hz
    obtain ⟨p', -, rfl⟩ := hz'
    have hlt : ∀ q : ℕ × ℕ, prodRes (m * n) q < m * n := fun q =>
      Nat.mod_lt _ (Nat.mul_pos hm hn)
    simp only [hd, Prod.mk.injEq] at hzz
    exact eq_of_mod_eq_mod h (hlt p) (hlt p') hzz.1 hzz.2
  calc IpairOrd (m * n)
      = mutInfo (box (m * n)) (f ∘ (G ∘ crtMap m n)) (prodRes (m * n)) :=
        mutInfo_congr hstep1 (fun _ _ => rfl)
    _ = mutInfo (box (m * n)) (G ∘ crtMap m n) (prodRes (m * n)) := by
        rw [mutInfo, mutInfo, uEnt_comp_injOn hfinj, condEnt_comp_injOn hfinj]
    _ = mutInfo (box (m * n)) (G ∘ crtMap m n) (d ∘ prodRes (m * n)) := by
        rw [mutInfo, mutInfo, condEnt_cond_injOn hdinj]
    _ = mutInfo (box (m * n)) (G ∘ crtMap m n) (K ∘ crtMap m n) :=
        mutInfo_congr (fun _ _ => rfl) hstep2
    _ = mutInfo ((box (m * n)).image (crtMap m n)) G K :=
        (mutInfo_image_injOn (crtMap_injOn h) G K).symm
    _ = mutInfo (box m ×ˢ box n) G K := by rw [image_crtMap hm hn h]
    _ = IpairOrd m + IpairOrd n := by
        rw [hG, hK, mutInfo_prod hbm hbn]
        rfl

/-! ## 5. From the ordered to the unordered pair -/

/-- The unordered type pair is the unordered shadow of the ordered one. -/
theorem typePair_eq_symPair (n : ℕ) (p : ℕ × ℕ) : typePair n p = symPair (ordPair n p) := rfl

/-- **The which-factor wall is exactly zero for the type-pair channel**: the
unordered type pair carries exactly as much information about `N mod f` as the
ordered one, even though it has strictly smaller entropy whenever the two types
can differ. -/
theorem Ipair_eq_IpairOrd (n : ℕ) : Ipair n = IpairOrd n := by
  have hσs : ∀ p ∈ box n, Prod.swap p ∈ box n := by
    intro p hp
    simp only [box, mem_product, mem_range, Prod.fst_swap, Prod.snd_swap] at hp ⊢
    exact ⟨hp.2, hp.1⟩
  have hσσ : ∀ p ∈ box n, Prod.swap (Prod.swap p) = p := fun p _ => rfl
  have hgσ : ∀ p ∈ box n, ordPair n (Prod.swap p) = ((ordPair n p).2, (ordPair n p).1) :=
    fun p _ => rfl
  have hkσ : ∀ p ∈ box n, prodRes n (Prod.swap p) = prodRes n p := by
    intro p _
    exact prodRes_symm n p.2 p.1
  rw [Ipair, IpairOrd, show typePair n = symPair ∘ ordPair n from rfl]
  exact mutInfo_symPair hσs hσσ hgσ hkσ

/-- **CRT additivity of the (unordered) semiprime type-pair channel.**  This is
the exact law governing the whole growth table: the information of a cyclic
order is the sum of its primary contributions. -/
theorem Ipair_mul_of_coprime {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (h : Nat.Coprime m n) :
    Ipair (m * n) = Ipair m + Ipair n := by
  rw [Ipair_eq_IpairOrd, Ipair_eq_IpairOrd, Ipair_eq_IpairOrd, IpairOrd_mul_of_coprime hm hn h]

/-! ## 6. The channel is determined by its prime-power values -/

/-- The trivial cyclic order carries no information. -/
theorem Ipair_one : Ipair 1 = 0 := by
  have hcard : (box 1).card ≤ 1 := by decide
  have hcond : condEnt (box 1) (typePair 1) (prodRes 1) = 0 := by
    refine Finset.sum_eq_zero fun c _ => ?_
    have : (#{x ∈ box 1 | prodRes 1 x = c}) ≤ 1 :=
      le_trans (Finset.card_filter_le _ _) hcard
    rw [uEnt_of_card_le_one this, mul_zero]
  rw [Ipair, mutInfo, uEnt_of_card_le_one hcard, hcond, sub_zero]

/-- **The type-pair channel is a sum over the primary components.**  Iterating
CRT additivity, the information carried by a cyclic order is the sum of the
informations of its prime-power parts, so the whole growth table is determined
by the prime-power values alone. -/
theorem Ipair_eq_sum_prime_powers {n : ℕ} (hn : n ≠ 0) :
    Ipair n = ∑ p ∈ n.primeFactors, Ipair (p ^ n.factorization p) := by
  have hmul : ∀ (a b : ℕ), Nat.Coprime a b →
      Real.exp (Ipair (a * b)) = Real.exp (Ipair a) * Real.exp (Ipair b) := by
    intro a b hab
    rcases Nat.eq_zero_or_pos a with rfl | ha
    · simp only [Nat.coprime_zero_left] at hab
      subst hab
      simp [Ipair_one]
    rcases Nat.eq_zero_or_pos b with rfl | hb
    · simp only [Nat.coprime_zero_right] at hab
      subst hab
      simp [Ipair_one]
    rw [Ipair_mul_of_coprime ha hb hab, Real.exp_add]
  have hone : Real.exp (Ipair 1) = 1 := by rw [Ipair_one, Real.exp_zero]
  have hfac := Nat.multiplicative_factorization (fun m => Real.exp (Ipair m)) hmul hone hn
  rw [Finsupp.prod, Nat.support_factorization] at hfac
  simp only at hfac
  have hsum : ∏ p ∈ n.primeFactors, Real.exp (Ipair (p ^ n.factorization p))
      = Real.exp (∑ p ∈ n.primeFactors, Ipair (p ^ n.factorization p)) :=
    (Real.exp_sum _ _).symm
  rw [hsum] at hfac
  exact Real.exp_injective hfac

end CyclicTypeChannel