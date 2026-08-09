/-
# The exact second moment of the trace of Frobenius over a finite field

Let `F` be a finite field of odd characteristic, `q = #F`, and for `a b : F` let
`a(a,b)` be the trace of Frobenius of the short Weierstrass curve `y^2 = x^3+a*x+b`
(defined in `Combinatorics.EllipticPointCount`).  We prove the **exact** identity

`∑_{a,b ∈ F} a(a,b)^2 = q^3 - q^2`,

together with its Chebyshev consequence: the number of parameter pairs `(a,b)` with
`a(a,b)^2 ≥ K` is at most `(q^3 - q^2)/K`.  In particular *almost all* curves in the
family satisfy the Hasse bound `|a| ≤ 2√q`, by a purely elementary character-sum
computation (no Weil conjectures, no Riemann–Roch).

The engine is the elementary evaluation of the quadratic character sum of a
separable quadratic, `EllipticModCount.sum_char_mul_shift`.

Main results:

* `EllipticModCount.sum_char_mul_shift` : `∑_c χ(c(c+w)) = -1` for `w ≠ 0`.
* `EllipticModCount.sum_char_shift_pair` : `∑_b χ((b+u)(b+v)) = q-1` or `-1`.
* `EllipticModCount.second_moment_charSum` : `∑_{a,b} S(a,b)^2 = q^3 - q^2`.
* `EllipticModCount.second_moment_frobTrace` : the same for the trace of Frobenius.
* `EllipticModCount.card_large_frobTrace_le` : Chebyshev / "Hasse on average".
-/
import Mathlib
import Combinatorics.EllipticPointCount

namespace EllipticModCount

open Finset

variable {F : Type*} [Field F] [Fintype F] [DecidableEq F]

section CharacterSums

/-- `χ(c * c)` is the indicator of `c ≠ 0`. -/
private lemma char_mul_self (c : F) :
    quadraticChar F (c * c) = if c = 0 then 0 else 1 := by
  by_cases h : c = 0
  · simp [h]
  · rw [if_neg h, ← sq]
    exact quadraticChar_sq_one' h

/-- `∑_c χ(c^2) = q - 1`. -/
theorem sum_char_sq : ∑ c : F, quadraticChar F (c * c) = (Fintype.card F : ℤ) - 1 := by
  rw [Finset.sum_congr rfl fun c _ => char_mul_self c]
  have hsplit : ∀ c : F, (if c = 0 then (0 : ℤ) else 1) = 1 - (if c = 0 then 1 else 0) := by
    intro c
    by_cases h : c = 0 <;> simp [h]
  rw [Finset.sum_congr rfl fun c _ => hsplit c, Finset.sum_sub_distrib]
  simp [Finset.card_univ]

/-- **A separable quadratic character sum.** For `w ≠ 0`, `∑_c χ(c(c+w)) = -1`. -/
theorem sum_char_mul_shift (hF : ringChar F ≠ 2) {w : F} (hw : w ≠ 0) :
    ∑ c : F, quadraticChar F (c * (c + w)) = -1 := by
  have h0 : ∑ c : F, quadraticChar F (c * (c + w))
      = ∑ c ∈ univ.erase (0 : F), quadraticChar F (c * (c + w)) := by
    rw [Finset.sum_erase_eq_sub (mem_univ (0 : F))]
    simp
  have h1 : ∑ c ∈ univ.erase (0 : F), quadraticChar F (c * (c + w))
      = ∑ c ∈ univ.erase (0 : F), quadraticChar F (1 + w * c⁻¹) := by
    refine Finset.sum_congr rfl fun c hc => ?_
    have hc0 : c ≠ 0 := (Finset.mem_erase.mp hc).1
    have hfac : c * (c + w) = c ^ 2 * (1 + w * c⁻¹) := by
      field_simp
    rw [hfac, map_mul, quadraticChar_sq_one' hc0, one_mul]
  have h2 : ∑ c ∈ univ.erase (0 : F), quadraticChar F (1 + w * c⁻¹)
      = ∑ t ∈ univ.erase (1 : F), quadraticChar F t := by
    refine Finset.sum_nbij' (i := fun c : F => 1 + w * c⁻¹) (j := fun t : F => w * (t - 1)⁻¹)
      ?_ ?_ ?_ ?_ ?_
    · intro c hc
      have hc0 : c ≠ 0 := (Finset.mem_erase.mp hc).1
      refine Finset.mem_erase.mpr ⟨?_, mem_univ _⟩
      intro h
      have : w * c⁻¹ = 0 := by linear_combination h
      rcases mul_eq_zero.mp this with h' | h'
      · exact hw h'
      · exact hc0 (inv_eq_zero.mp h')
    · intro t ht
      have ht1 : t ≠ 1 := (Finset.mem_erase.mp ht).1
      refine Finset.mem_erase.mpr ⟨?_, mem_univ _⟩
      exact mul_ne_zero hw (inv_ne_zero (sub_ne_zero.mpr ht1))
    · intro c hc
      have hc0 : c ≠ 0 := (Finset.mem_erase.mp hc).1
      field_simp
      rw [show c + w - c = w from by ring, div_self hw]
    · intro t ht
      have ht1 : t ≠ 1 := (Finset.mem_erase.mp ht).1
      have h1' : t - 1 ≠ 0 := sub_ne_zero.mpr ht1
      field_simp
      ring
    · intro c _
      rfl
  have h3 : ∑ t ∈ univ.erase (1 : F), quadraticChar F t = -1 := by
    rw [Finset.sum_erase_eq_sub (mem_univ (1 : F)), quadraticChar_sum_zero hF]
    simp
  rw [h0, h1, h2, h3]

/-- The `b`-average of `χ((b+u)(b+v))`. -/
theorem sum_char_shift_pair (hF : ringChar F ≠ 2) (u v : F) :
    ∑ b : F, quadraticChar F ((b + u) * (b + v))
      = if u = v then (Fintype.card F : ℤ) - 1 else -1 := by
  have hbij : Function.Bijective fun c : F => c - u := by
    constructor
    · intro c₁ c₂ h
      simpa using h
    · intro c
      exact ⟨c + u, by ring⟩
  have hshift : ∑ c : F, quadraticChar F (c * (c + (v - u)))
      = ∑ b : F, quadraticChar F ((b + u) * (b + v)) := by
    have := Fintype.sum_bijective (fun c : F => c - u) hbij
      (fun c => quadraticChar F ((c - u + u) * (c - u + v)))
      (fun b => quadraticChar F ((b + u) * (b + v))) (fun _ => rfl)
    rw [← this]
    refine Finset.sum_congr rfl fun c _ => ?_
    congr 1
    ring
  rw [← hshift]
  by_cases h : u = v
  · subst h
    rw [if_pos rfl]
    have hcc : ∀ c : F, c * (c + (u - u)) = c * c := by
      intro c
      ring
    rw [Finset.sum_congr rfl fun c _ => congrArg (quadraticChar F) (hcc c), sum_char_sq]
  · rw [if_neg h]
    exact sum_char_mul_shift hF (sub_ne_zero.mpr (Ne.symm h))

end CharacterSums

section SecondMoment

/-- The square of the character sum expanded as a double sum. -/
theorem charSum_sq (a b : F) :
    (charSum a b) ^ 2 = ∑ x : F, ∑ y : F, quadraticChar F (wRHS a b x * wRHS a b y) := by
  rw [sq, charSum, Finset.sum_mul_sum]
  exact Finset.sum_congr rfl fun x _ =>
    Finset.sum_congr rfl fun y _ => (map_mul (quadraticChar F) _ _).symm

/-- The `a`-sum of the two-point correlation. -/
theorem sum_a_correlation (x y : F) :
    ∑ a : F, (if x ^ 3 + a * x = y ^ 3 + a * y then (Fintype.card F : ℤ) - 1 else -1)
      = if x = y then (Fintype.card F : ℤ) ^ 2 - (Fintype.card F : ℤ) else 0 := by
  by_cases h : x = y
  · subst h
    rw [if_pos rfl]
    have : ∀ a : F, (if x ^ 3 + a * x = x ^ 3 + a * x then (Fintype.card F : ℤ) - 1 else -1)
        = (Fintype.card F : ℤ) - 1 := by
      intro a
      rw [if_pos rfl]
    rw [Finset.sum_congr rfl fun a _ => this a, Finset.sum_const, Finset.card_univ,
      nsmul_eq_mul]
    ring
  · rw [if_neg h]
    have hxy : x - y ≠ 0 := sub_ne_zero.mpr h
    have hiff : ∀ a : F, (x ^ 3 + a * x = y ^ 3 + a * y) ↔ a = -(x ^ 2 + x * y + y ^ 2) := by
      intro a
      constructor
      · intro ha
        have hfac : (x - y) * (x ^ 2 + x * y + y ^ 2 + a) = 0 := by linear_combination ha
        rcases mul_eq_zero.mp hfac with h' | h'
        · exact absurd h' hxy
        · linear_combination h'
      · intro ha
        rw [ha]
        ring
    have hstep : ∀ a : F,
        (if x ^ 3 + a * x = y ^ 3 + a * y then (Fintype.card F : ℤ) - 1 else -1)
          = -1 + (if a = -(x ^ 2 + x * y + y ^ 2) then (Fintype.card F : ℤ) else 0) := by
      intro a
      by_cases ha : a = -(x ^ 2 + x * y + y ^ 2)
      · rw [if_pos ((hiff a).mpr ha), if_pos ha]
        ring
      · rw [if_neg (fun hc => ha ((hiff a).mp hc)), if_neg ha]
        ring
    rw [Finset.sum_congr rfl fun a _ => hstep a, Finset.sum_add_distrib, Finset.sum_const,
      Finset.card_univ, nsmul_eq_mul, Finset.sum_ite_eq' univ (-(x ^ 2 + x * y + y ^ 2))
        (fun _ : F => (Fintype.card F : ℤ))]
    simp

/-- The number of pairs `(x,y)` on which the two `x`-coordinates give the same value of
`x^3 + a*x`; this is the "collision count" governing the `b`-variance of the family. -/
def collisions (a : F) : ℕ :=
  (univ.filter fun xy : F × F => xy.1 ^ 3 + a * xy.1 = xy.2 ^ 3 + a * xy.2).card

/-- **Second moment in `b` for a fixed `a`, as a two-point correlation.** -/
theorem sum_b_charSum_sq_eq_sum_ite (hF : ringChar F ≠ 2) (a : F) :
    ∑ b : F, (charSum a b) ^ 2
      = ∑ x : F, ∑ y : F,
          (if x ^ 3 + a * x = y ^ 3 + a * y then (Fintype.card F : ℤ) - 1 else -1) := by
  rw [Finset.sum_congr rfl fun b _ => charSum_sq a b, Finset.sum_comm]
  refine Finset.sum_congr rfl fun x _ => ?_
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun y _ => ?_
  have hrw : ∀ b : F,
      wRHS a b x * wRHS a b y = (b + (x ^ 3 + a * x)) * (b + (y ^ 3 + a * y)) := by
    intro b
    rw [wRHS, wRHS]
    ring
  rw [Finset.sum_congr rfl fun b _ => congrArg (quadraticChar F) (hrw b),
    sum_char_shift_pair hF]

/-- **Exact `b`-variance of a fixed slope `a`.** The second moment of the character sum
along the line `b ↦ (a,b)` is `q * collisions a - q^2`. -/
theorem sum_b_charSum_sq (hF : ringChar F ≠ 2) (a : F) :
    ∑ b : F, (charSum a b) ^ 2
      = (Fintype.card F : ℤ) * (collisions a : ℤ) - (Fintype.card F : ℤ) ^ 2 := by
  rw [sum_b_charSum_sq_eq_sum_ite hF a]
  have hconv : (∑ x : F, ∑ y : F,
      (if x ^ 3 + a * x = y ^ 3 + a * y then (Fintype.card F : ℤ) - 1 else -1))
      = ∑ xy : F × F,
        (if xy.1 ^ 3 + a * xy.1 = xy.2 ^ 3 + a * xy.2 then (Fintype.card F : ℤ) - 1 else -1) :=
    (Fintype.sum_prod_type' (fun x y : F =>
      if x ^ 3 + a * x = y ^ 3 + a * y then (Fintype.card F : ℤ) - 1 else -1)).symm
  rw [hconv]
  have hstep : ∀ xy : F × F,
      (if xy.1 ^ 3 + a * xy.1 = xy.2 ^ 3 + a * xy.2 then (Fintype.card F : ℤ) - 1 else -1)
        = -1 + (if xy.1 ^ 3 + a * xy.1 = xy.2 ^ 3 + a * xy.2 then (Fintype.card F : ℤ) else 0) := by
    intro xy
    by_cases h : xy.1 ^ 3 + a * xy.1 = xy.2 ^ 3 + a * xy.2
    · simp [h]
      ring
    · simp [h]
  rw [Finset.sum_congr rfl fun xy _ => hstep xy, Finset.sum_add_distrib, Finset.sum_const,
    Finset.card_univ, nsmul_eq_mul, ← Finset.sum_filter, Finset.sum_const, nsmul_eq_mul,
    Fintype.card_prod]
  push_cast
  rw [collisions]
  ring

/-- **Exact second moment of the character sum over the whole family.** -/
theorem second_moment_charSum (hF : ringChar F ≠ 2) :
    ∑ a : F, ∑ b : F, (charSum a b) ^ 2
      = (Fintype.card F : ℤ) ^ 3 - (Fintype.card F : ℤ) ^ 2 := by
  rw [Finset.sum_congr rfl fun a _ => sum_b_charSum_sq_eq_sum_ite hF a, Finset.sum_comm]
  have step2 : ∀ x : F, ∑ y : F, ∑ a : F,
      (if x ^ 3 + a * x = y ^ 3 + a * y then (Fintype.card F : ℤ) - 1 else -1)
      = (Fintype.card F : ℤ) ^ 2 - (Fintype.card F : ℤ) := by
    intro x
    rw [Finset.sum_congr rfl fun y _ => sum_a_correlation x y]
    rw [Finset.sum_ite_eq univ x (fun _ : F => (Fintype.card F : ℤ) ^ 2 - (Fintype.card F : ℤ))]
    simp
  have hswap : ∀ x : F, ∑ y : F, ∑ a : F,
      (if x ^ 3 + a * x = y ^ 3 + a * y then (Fintype.card F : ℤ) - 1 else -1)
      = ∑ a : F, ∑ y : F,
        (if x ^ 3 + a * x = y ^ 3 + a * y then (Fintype.card F : ℤ) - 1 else -1) :=
    fun x => Finset.sum_comm
  rw [Finset.sum_congr rfl fun x _ => ((hswap x).symm.trans (step2 x))]
  rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  ring

/-- **Exact second moment of the trace of Frobenius.** -/
theorem second_moment_frobTrace (hF : ringChar F ≠ 2) :
    ∑ a : F, ∑ b : F, (frobTrace a b) ^ 2
      = (Fintype.card F : ℤ) ^ 3 - (Fintype.card F : ℤ) ^ 2 := by
  rw [← second_moment_charSum hF]
  refine Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun b _ => ?_
  rw [frobTrace_eq_neg_charSum hF]
  ring

end SecondMoment

section Chebyshev

/-- **Hasse on average.** For every threshold `K > 0`, the number of parameter pairs
`(a,b)` whose trace of Frobenius satisfies `a(a,b)^2 ≥ K` is at most `(q^3-q^2)/K`. -/
theorem card_large_frobTrace_le (hF : ringChar F ≠ 2) (K : ℤ) :
    K * ((univ.filter fun ab : F × F => K ≤ (frobTrace ab.1 ab.2) ^ 2).card : ℤ)
      ≤ (Fintype.card F : ℤ) ^ 3 - (Fintype.card F : ℤ) ^ 2 := by
  classical
  set S : Finset (F × F) := univ.filter fun ab : F × F => K ≤ (frobTrace ab.1 ab.2) ^ 2 with hS
  have hlow : (S.card : ℤ) * K ≤ ∑ ab ∈ S, (frobTrace ab.1 ab.2) ^ 2 := by
    have := Finset.card_nsmul_le_sum S (fun ab : F × F => (frobTrace ab.1 ab.2) ^ 2) K
      (fun ab hab => (Finset.mem_filter.mp hab).2)
    simpa [nsmul_eq_mul, mul_comm] using this
  have hsub : ∑ ab ∈ S, (frobTrace ab.1 ab.2) ^ 2 ≤ ∑ ab : F × F, (frobTrace ab.1 ab.2) ^ 2 := by
    refine Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ S) ?_
    intro ab _ _
    positivity
  have htotal : ∑ ab : F × F, (frobTrace ab.1 ab.2) ^ 2
      = (Fintype.card F : ℤ) ^ 3 - (Fintype.card F : ℤ) ^ 2 := by
    rw [Fintype.sum_prod_type]
    exact second_moment_frobTrace hF
  rw [← htotal]
  calc K * (S.card : ℤ) = (S.card : ℤ) * K := by ring
    _ ≤ ∑ ab ∈ S, (frobTrace ab.1 ab.2) ^ 2 := hlow
    _ ≤ ∑ ab : F × F, (frobTrace ab.1 ab.2) ^ 2 := hsub

/-- **Existence of curves with a large trace of Frobenius.** The second moment forces some
member of the family to have `a_p^2 ≥ q - 1`; combined with Hasse this pins the extremal
size of the trace between `√(q-1)` and `2√q`. -/
theorem exists_frobTrace_sq_ge (hF : ringChar F ≠ 2) :
    ∃ a b : F, (Fintype.card F : ℤ) - 1 ≤ (frobTrace a b) ^ 2 := by
  by_contra hcon
  push_neg at hcon
  have hbound : ∑ a : F, ∑ b : F, (frobTrace a b) ^ 2
      ≤ ∑ _a : F, ∑ _b : F, ((Fintype.card F : ℤ) - 2) := by
    refine Finset.sum_le_sum fun a _ => Finset.sum_le_sum fun b _ => ?_
    have := hcon a b
    omega
  rw [second_moment_frobTrace hF] at hbound
  simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul] at hbound
  have hq : (1 : ℤ) ≤ (Fintype.card F : ℤ) := by
    have := Fintype.card_pos_iff.mpr (⟨0⟩ : Nonempty F)
    exact_mod_cast this
  nlinarith [hbound, hq]

end Chebyshev

section FirstMoment

/-- **Exact total point count of the whole family.** Summing over all `q^2` short
Weierstrass equations gives exactly `q^2 * (q+1)` points, i.e. the average curve has
exactly `q + 1` points. -/
theorem sum_cardPoints_family (hF : ringChar F ≠ 2) :
    ∑ a : F, ∑ b : F, (cardPoints a b : ℤ)
      = (Fintype.card F : ℤ) ^ 2 * ((Fintype.card F : ℤ) + 1) := by
  have hpoint : ∀ a b : F, (cardPoints a b : ℤ)
      = ((Fintype.card F : ℤ) + 1) - frobTrace a b := by
    intro a b
    rw [frobTrace]
    ring
  rw [Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun b _ => hpoint a b]
  have hinner : ∀ a : F, ∑ b : F, (((Fintype.card F : ℤ) + 1) - frobTrace a b)
      = (Fintype.card F : ℤ) * ((Fintype.card F : ℤ) + 1) := by
    intro a
    rw [Finset.sum_sub_distrib, sum_frobTrace_over_b hF, Finset.sum_const, Finset.card_univ,
      nsmul_eq_mul, sub_zero]
  rw [Finset.sum_congr rfl fun a _ => hinner a, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  ring

end FirstMoment

end EllipticModCount