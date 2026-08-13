import MachineLearning.HalfPlaneCircleBasic

/-!
# The circle count is CRT-separable

The modular circle `x² + y² ≡ 1 (mod N)` is a *local* object: its point count
splits as a product over coprime factorisations,

  `C(m n) = C(m) · C(n)`  for `gcd(m,n) = 1`,

and at an odd prime it is given by the classical conic count

  `C(p) = p - χ(-1) = p - 1` if `p ≡ 1 (mod 4)`, `p + 1` if `p ≡ 3 (mod 4)`.

The proof of the prime formula is by the stereographic parametrisation of the
conic from the point `(-1, 0)`: the circle minus that point is in bijection with
the set of slopes `t` for which `1 + t² ≠ 0`.

This is the "CRT-separable" baseline against which the half-plane count
`H(N)` of `HalfPlaneReflection.lean` is measured.
-/

namespace HalfPlane

open Finset

section CRT

variable {m n : ℕ} [NeZero m] [NeZero n]

/-- **CRT separability of the circle**, `ZMod` form. -/
theorem card_circleZ_mul_of_coprime (h : Nat.Coprime m n) :
    haveI : NeZero (m * n) := ⟨Nat.mul_ne_zero (NeZero.ne m) (NeZero.ne n)⟩
    (circleZ (m * n)).card = (circleZ m).card * (circleZ n).card := by
  haveI : NeZero (m * n) := ⟨Nat.mul_ne_zero (NeZero.ne m) (NeZero.ne n)⟩
  set e := ZMod.chineseRemainder h with he
  rw [← Finset.card_product]
  refine Finset.card_bij
    (fun q _ => (((e q.1).1, (e q.2).1), ((e q.1).2, (e q.2).2))) ?_ ?_ ?_
  · intro q hq
    rw [mem_circleZ] at hq
    have hmap : (e q.1) ^ 2 + (e q.2) ^ 2 = 1 := by
      rw [← map_pow, ← map_pow, ← map_add, hq, map_one]
    simp only [Finset.mem_product, mem_circleZ]
    constructor
    · exact congrArg Prod.fst hmap
    · exact congrArg Prod.snd hmap
  · intro q _ q' _ hqq
    have h1 : e q.1 = e q'.1 := by
      apply Prod.ext
      · exact congrArg (fun z => z.1.1) hqq
      · exact congrArg (fun z => z.2.1) hqq
    have h2 : e q.2 = e q'.2 := by
      apply Prod.ext
      · exact congrArg (fun z => z.1.2) hqq
      · exact congrArg (fun z => z.2.2) hqq
    exact Prod.ext (e.injective h1) (e.injective h2)
  · intro b hb
    simp only [Finset.mem_product, mem_circleZ] at hb
    obtain ⟨hb1, hb2⟩ := hb
    refine ⟨(e.symm (b.1.1, b.2.1), e.symm (b.1.2, b.2.2)), ?_, ?_⟩
    · rw [mem_circleZ]
      rw [← map_pow, ← map_pow, ← map_add]
      have : ((b.1.1, b.2.1) : ZMod m × ZMod n) ^ 2 + ((b.1.2, b.2.2) : ZMod m × ZMod n) ^ 2
          = 1 := by
        apply Prod.ext
        · simpa using hb1
        · simpa using hb2
      rw [this, map_one]
    · simp

/-- **CRT separability of the circle count**: `C(mn) = C(m)C(n)` for coprime `m`, `n`. -/
theorem circleCount_mul_of_coprime (h : Nat.Coprime m n) :
    circleCount (m * n) = circleCount m * circleCount n := by
  haveI : NeZero (m * n) := ⟨Nat.mul_ne_zero (NeZero.ne m) (NeZero.ne n)⟩
  rw [circleCount_eq_card_circleZ, circleCount_eq_card_circleZ,
    circleCount_eq_card_circleZ, card_circleZ_mul_of_coprime h]

end CRT

section Prime

variable (p : ℕ) [Fact (Nat.Prime p)]

/-- The set of admissible stereographic slopes: those `t` with `1 + t² ≠ 0`. -/
def slopeSet : Finset (ZMod p) := Finset.univ.filter (fun t => 1 + t ^ 2 ≠ 0)

variable {p}

instance : NeZero p := ⟨(Fact.out (p := Nat.Prime p)).ne_zero⟩

lemma two_ne_zero_zmod (hp : p ≠ 2) : (2 : ZMod p) ≠ 0 := by
  apply Ring.two_ne_zero
  rw [ZMod.ringChar_zmod_n p]
  exact_mod_cast hp

/-- On the circle, the only point with `x = -1` is `(-1, 0)`; hence away from it the
stereographic denominator `1 + x` is invertible. -/
lemma one_add_fst_ne_zero {q : ZMod p × ZMod p}
    (hq : q ∈ (circleZ p).erase ((-1 : ZMod p), (0 : ZMod p))) : (1 : ZMod p) + q.1 ≠ 0 := by
  obtain ⟨hne, hmem⟩ := Finset.mem_erase.mp hq
  rw [mem_circleZ] at hmem
  intro h
  have hx1 : q.1 = -1 := by linear_combination h
  have hy : q.2 ^ 2 = 0 := by rw [hx1] at hmem; linear_combination hmem
  exact hne (Prod.ext hx1 (pow_eq_zero_iff (n := 2) (by norm_num) |>.mp hy))

/-- The stereographic slope `t = y/(1+x)` satisfies `1 + t² = 2/(1+x)`. -/
lemma denom_eq {x y : ZMod p} (h : x ^ 2 + y ^ 2 = 1) (hx : (1 : ZMod p) + x ≠ 0) :
    1 + (y / (1 + x)) ^ 2 = 2 / (1 + x) := by
  field_simp
  linear_combination h

/-- **Stereographic projection.** The circle minus `(-1,0)` is in bijection with the
set of slopes `t` satisfying `1 + t² ≠ 0`. -/
theorem card_circleZ_erase (hp : p ≠ 2) :
    ((circleZ p).erase ((-1 : ZMod p), (0 : ZMod p))).card = (slopeSet p).card := by
  have h2 : (2 : ZMod p) ≠ 0 := two_ne_zero_zmod hp
  refine Finset.card_bij'
    (fun q _ => q.2 / (1 + q.1))
    (fun u _ => ((1 - u ^ 2) / (1 + u ^ 2), 2 * u / (1 + u ^ 2)))
    ?_ ?_ ?_ ?_
  · intro q hq
    have hx := one_add_fst_ne_zero hq
    have hmem := mem_circleZ.mp (Finset.mem_of_mem_erase hq)
    simp only [slopeSet, Finset.mem_filter, Finset.mem_univ, true_and]
    rw [denom_eq hmem hx]
    exact div_ne_zero h2 hx
  · intro u hu
    simp only [slopeSet, Finset.mem_filter, Finset.mem_univ, true_and] at hu
    rw [Finset.mem_erase]
    refine ⟨?_, ?_⟩
    · intro hcon
      have hx : (1 - u ^ 2) / (1 + u ^ 2) = -1 := congrArg Prod.fst hcon
      rw [div_eq_iff hu] at hx
      exact h2 (by linear_combination hx)
    · rw [mem_circleZ]
      simp only
      field_simp
      ring
  · intro q hq
    have hx := one_add_fst_ne_zero hq
    have hmem := mem_circleZ.mp (Finset.mem_of_mem_erase hq)
    have hd := denom_eq hmem hx
    simp only
    rw [hd]
    refine Prod.ext ?_ ?_
    · simp only
      rw [div_div_eq_mul_div, div_eq_iff h2]
      field_simp
      linear_combination -hmem
    · simp only
      rw [div_div_eq_mul_div, div_eq_iff h2]
      field_simp
  · intro u hu
    simp only [slopeSet, Finset.mem_filter, Finset.mem_univ, true_and] at hu
    have hden : (1 : ZMod p) + (1 - u ^ 2) / (1 + u ^ 2) = 2 / (1 + u ^ 2) := by
      field_simp
      ring
    simp only
    rw [hden, div_div_eq_mul_div, div_eq_iff h2]
    field_simp

/-- The number of admissible slopes is `p - (χ(-1) + 1)`. -/
theorem card_slopeSet (hp : p ≠ 2) :
    ((slopeSet p).card : ℤ) = p - (quadraticChar (ZMod p) (-1) + 1) := by
  have hchar : ringChar (ZMod p) ≠ 2 := by
    rw [ZMod.ringChar_zmod_n p]; exact_mod_cast hp
  have hsplit :
      (Finset.univ.filter (fun t : ZMod p => 1 + t ^ 2 ≠ 0)).card
        + (Finset.univ.filter (fun t : ZMod p => ¬ (1 + t ^ 2 ≠ 0))).card
        = Fintype.card (ZMod p) := by
    simpa using
      (Finset.card_filter_add_card_filter_not
        (s := (Finset.univ : Finset (ZMod p))) (p := fun t => 1 + t ^ 2 ≠ 0))
  have hroots : (Finset.univ.filter (fun t : ZMod p => ¬ (1 + t ^ 2 ≠ 0)))
      = {x : ZMod p | x ^ 2 = -1}.toFinset := by
    ext t
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, not_not,
      Set.mem_toFinset, Set.mem_setOf_eq]
    constructor
    · intro h; linear_combination h
    · intro h; linear_combination h
  have hcard : (({x : ZMod p | x ^ 2 = -1}.toFinset).card : ℤ)
      = quadraticChar (ZMod p) (-1) + 1 :=
    quadraticChar_card_sqrts hchar (-1)
  have hp' : Fintype.card (ZMod p) = p := ZMod.card p
  have : ((slopeSet p).card : ℤ) + (({x : ZMod p | x ^ 2 = -1}.toFinset).card : ℤ)
      = (p : ℤ) := by
    rw [← hcard] at *
    have := hsplit
    rw [hroots, hp'] at this
    exact_mod_cast congrArg (fun k : ℕ => (k : ℤ)) this
  rw [hcard] at this
  linarith

/-- **The circle count at an odd prime**: `C(p) = p - χ(-1)`. -/
theorem circleCount_prime_int (hp : p ≠ 2) :
    (circleCount p : ℤ) = (p : ℤ) - quadraticChar (ZMod p) (-1) := by
  have hmem : ((-1 : ZMod p), (0 : ZMod p)) ∈ circleZ p := by
    rw [mem_circleZ]; ring
  have hcard : (circleZ p).card
      = ((circleZ p).erase ((-1 : ZMod p), (0 : ZMod p))).card + 1 := by
    rw [Finset.card_erase_of_mem hmem]
    have : 1 ≤ (circleZ p).card := Finset.card_pos.mpr ⟨_, hmem⟩
    omega
  rw [circleCount_eq_card_circleZ, hcard, card_circleZ_erase hp]
  push_cast
  rw [card_slopeSet hp]
  ring

/-- **The circle count at an odd prime**, explicit form:
`C(p) = p - 1` if `p ≡ 1 (mod 4)` and `C(p) = p + 1` if `p ≡ 3 (mod 4)`. -/
theorem circleCount_prime (hp : p ≠ 2) :
    circleCount p = if p % 4 = 1 then p - 1 else p + 1 := by
  have hodd : p % 2 = 1 :=
    Nat.odd_iff.mp ((Fact.out (p := Nat.Prime p)).odd_of_ne_two hp)
  have hchar : ringChar (ZMod p) ≠ 2 := by
    rw [ZMod.ringChar_zmod_n p]; exact_mod_cast hp
  have hchi : quadraticChar (ZMod p) (-1) = ZMod.χ₄ (Fintype.card (ZMod p)) :=
    quadraticChar_neg_one hchar
  rw [ZMod.card p] at hchi
  have hkey := circleCount_prime_int (p := p) hp
  have hp1 : 1 ≤ p := (Fact.out (p := Nat.Prime p)).one_lt.le
  by_cases h4 : p % 4 = 1
  · have : ZMod.χ₄ (p : ZMod 4) = 1 := by
      rw [ZMod.χ₄_nat_eq_if_mod_four]
      simp [h4]
      omega
    rw [this] at hchi
    rw [hchi] at hkey
    simp only [h4, if_true]
    omega
  · have h3 : p % 4 = 3 := by omega
    have : ZMod.χ₄ (p : ZMod 4) = -1 := by
      rw [ZMod.χ₄_nat_eq_if_mod_four]
      simp [h3]
      omega
    rw [this] at hchi
    rw [hchi] at hkey
    simp only [h4, if_false]
    omega

end Prime

end HalfPlane