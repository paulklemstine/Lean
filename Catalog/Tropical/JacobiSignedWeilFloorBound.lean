import Tropical.JacobiSignedWeilFloorCore

/-!
# The Weil floor for the Jacobi-signed circle count

This file proves, completely elementarily (no algebraic geometry, no Hasse bound
imported), the **Weil bound**

`W p ^ 2 ≤ 4 * p`

for the Jacobi-signed circle count `W p = ∑_x χ(x(1-x²))` of
`JacobiSignedWeilFloorCore.lean`.  Equivalently `|W p| ≤ 2 √p`: the JACSIGN
statistic sits exactly at the square-root noise floor of a character sum.

The proof is a second-moment (averaging over quadratic twists) argument:

* `JacSign.chiSum_quadratic` : `∑_d χ((d-a)(d-b)) = p-1` if `a = b` and `-1` otherwise;
* `JacSign.A p d = ∑_x χ(x³ - d x)` is the trace of Frobenius of `y² = x³ - d x`;
* `JacSign.A_sq_scale` : `A p (c²) = χ(c) · A p 1` — all *square* twists carry the
  same squared trace;
* `JacSign.moment` : `∑_d (A p d)² = 2 p (p-1)` — the exact second moment;
* since squaring is at most `2`-to-`1`, the `p-1` scalings contribute
  `(p-1) · (A p 1)² ≤ 2 · 2p(p-1)`, whence `(A p 1)² ≤ 4p`.
-/

open Finset

namespace JacSign

variable (p : ℕ) [Fact p.Prime]

/-- `∑_u χ(u² - u) = -1`: the basic nontrivial quadratic character sum. -/
theorem chiSum_sq_sub_self (hp : p ≠ 2) :
    ∑ u : ZMod p, quadraticChar (ZMod p) (u ^ 2 - u) = -1 := by
  have hF : ringChar (ZMod p) ≠ 2 := by rw [ZMod.ringChar_zmod_n]; exact hp
  have h1 : ∑ u : ZMod p, quadraticChar (ZMod p) (u ^ 2 - u)
      = ∑ u ∈ univ.erase (0 : ZMod p), quadraticChar (ZMod p) (u ^ 2 - u) := by
    rw [← Finset.add_sum_erase _ _ (Finset.mem_univ (0 : ZMod p))]; simp
  have h2 : ∀ u ∈ univ.erase (0 : ZMod p),
      quadraticChar (ZMod p) (u ^ 2 - u) = quadraticChar (ZMod p) (1 - u⁻¹) := by
    intro u hu
    have hu0 : u ≠ 0 := (Finset.mem_erase.mp hu).1
    have h : u ^ 2 - u = u ^ 2 * (1 - u⁻¹) := by field_simp
    rw [h, map_mul, quadraticChar_sq_one' hu0, one_mul]
  rw [h1, Finset.sum_congr rfl h2]
  have h3 : ∑ u ∈ univ.erase (0 : ZMod p), quadraticChar (ZMod p) (1 - u⁻¹)
      = ∑ v ∈ univ.erase (1 : ZMod p), quadraticChar (ZMod p) v := by
    refine Finset.sum_nbij' (i := fun u => 1 - u⁻¹) (j := fun v => (1 - v)⁻¹) ?_ ?_ ?_ ?_ ?_
    · intro a ha
      have ha0 : a ≠ 0 := (Finset.mem_erase.mp ha).1
      simp only [Finset.mem_erase, Finset.mem_univ, and_true]
      intro h
      have hinv : a⁻¹ = 0 := by linear_combination -h
      exact ha0 (by simpa using inv_eq_zero.mp hinv)
    · intro v hv
      have hv1 : v ≠ 1 := (Finset.mem_erase.mp hv).1
      simp only [Finset.mem_erase, Finset.mem_univ, and_true]
      exact inv_ne_zero (sub_ne_zero.mpr (Ne.symm hv1))
    · intro a ha
      have ha0 : a ≠ 0 := (Finset.mem_erase.mp ha).1
      show (1 - (1 - a⁻¹))⁻¹ = a
      rw [show (1 : ZMod p) - (1 - a⁻¹) = a⁻¹ by ring, inv_inv]
    · intro v hv
      have hv1 : v ≠ 1 := (Finset.mem_erase.mp hv).1
      show 1 - ((1 - v)⁻¹)⁻¹ = v
      rw [inv_inv]; ring
    · intro a _; rfl
  rw [h3]
  have h4 := quadraticChar_sum_zero (F := ZMod p) hF
  have h5 : quadraticChar (ZMod p) 1
      + ∑ v ∈ univ.erase (1 : ZMod p), quadraticChar (ZMod p) v = 0 := by
    rw [Finset.add_sum_erase _ _ (Finset.mem_univ (1 : ZMod p))]; exact h4
  rw [MulChar.map_one] at h5
  linarith

/-- The character sum of a quadratic polynomial with roots `a`, `b`. -/
theorem chiSum_quadratic (hp : p ≠ 2) (a b : ZMod p) :
    ∑ d : ZMod p, quadraticChar (ZMod p) ((d - a) * (d - b))
      = if a = b then (p : ℤ) - 1 else -1 := by
  by_cases hab : a = b
  · subst hab
    rw [if_pos rfl]
    have hval : ∀ d : ZMod p, quadraticChar (ZMod p) ((d - a) * (d - a))
        = if d = a then 0 else 1 := by
      intro d
      by_cases hd : d = a
      · simp [hd]
      · rw [if_neg hd, ← sq]
        exact quadraticChar_sq_one' (sub_ne_zero.mpr hd)
    rw [Finset.sum_congr rfl fun d _ => hval d, Finset.sum_ite]
    have h : (univ.filter (fun x : ZMod p => ¬ x = a)) = univ.erase a := by
      ext x; simp [Finset.mem_erase, and_comm]
    have hp2 := (Fact.out : p.Prime).two_le
    rw [Finset.sum_const, Finset.sum_const, h,
      Finset.card_erase_of_mem (Finset.mem_univ a), Finset.card_univ, ZMod.card]
    simp only [smul_zero, zero_add, nsmul_eq_mul, mul_one]
    push_cast [Nat.cast_sub (by omega : 1 ≤ p)]
    ring
  · have hba : b - a ≠ 0 := sub_ne_zero.mpr (Ne.symm hab)
    have hre : ∑ d : ZMod p, quadraticChar (ZMod p) ((d - a) * (d - b))
        = ∑ u : ZMod p, quadraticChar (ZMod p)
            ((((Equiv.mulLeft₀ (b - a) hba).trans (Equiv.addLeft a)) u - a) *
             (((Equiv.mulLeft₀ (b - a) hba).trans (Equiv.addLeft a)) u - b)) :=
      (Fintype.sum_equiv ((Equiv.mulLeft₀ (b - a) hba).trans (Equiv.addLeft a)) _ _
        fun u => rfl).symm
    rw [hre]
    have hval : ∀ u : ZMod p,
        ((((Equiv.mulLeft₀ (b - a) hba).trans (Equiv.addLeft a)) u - a) *
         (((Equiv.mulLeft₀ (b - a) hba).trans (Equiv.addLeft a)) u - b))
          = (b - a) ^ 2 * (u ^ 2 - u) := by
      intro u
      show (a + (b - a) * u - a) * (a + (b - a) * u - b) = (b - a) ^ 2 * (u ^ 2 - u)
      ring
    simp only [hval, map_mul, quadraticChar_sq_one' hba, one_mul]
    rw [chiSum_sq_sub_self p hp, if_neg hab]

/-- `A p d` is the character sum of the quadratic twist `y² = x³ - d x`
(the negative of its trace of Frobenius). -/
noncomputable def A (p : ℕ) [Fact p.Prime] (d : ZMod p) : ℤ :=
  ∑ x : ZMod p, quadraticChar (ZMod p) (x ^ 3 - d * x)

theorem chi_cube (x : ZMod p) : quadraticChar (ZMod p) (x ^ 3) = quadraticChar (ZMod p) x := by
  rw [map_pow]
  rcases quadraticChar_isQuadratic (ZMod p) x with h | h | h <;> rw [h] <;> norm_num

theorem A_zero (hp : p ≠ 2) : A p 0 = 0 := by
  have hF : ringChar (ZMod p) ≠ 2 := by rw [ZMod.ringChar_zmod_n]; exact hp
  simp only [A, zero_mul, sub_zero, chi_cube]
  exact quadraticChar_sum_zero hF

/-- All square twists have the same character sum up to the sign `χ(c)`. -/
theorem A_sq_scale {c : ZMod p} (hc : c ≠ 0) :
    A p (c ^ 2) = quadraticChar (ZMod p) c * A p 1 := by
  have hre : A p (c ^ 2) = ∑ u : ZMod p, quadraticChar (ZMod p) ((c * u) ^ 3 - c ^ 2 * (c * u)) := by
    rw [A]
    exact (Fintype.sum_equiv (Equiv.mulLeft₀ c hc) _ _ fun u => rfl).symm
  rw [hre, A, Finset.mul_sum]
  refine Finset.sum_congr rfl fun u _ => ?_
  rw [show (c * u) ^ 3 - c ^ 2 * (c * u) = c ^ 3 * (u ^ 3 - 1 * u) by ring, map_mul, chi_cube]

theorem inner_T (hp : p ≠ 2) (h1 : p % 4 = 1) (x : ZMod p) :
    (∑ y : ZMod p, if x ^ 2 = y ^ 2 then quadraticChar (ZMod p) (x * y) else 0)
      = if x = 0 then 0 else 2 := by
  have hchi1 : quadraticChar (ZMod p) (-1) = 1 := chi_neg_one_eq_one p h1
  have hset : (univ.filter (fun y : ZMod p => x ^ 2 = y ^ 2)) = {x, -x} := by
    ext y
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_insert,
      Finset.mem_singleton]
    constructor
    · intro h
      rcases sq_eq_sq_iff_eq_or_eq_neg.mp h.symm with h' | h'
      · exact Or.inl h'
      · exact Or.inr h'
    · rintro (rfl | rfl) <;> ring
  rw [← Finset.sum_filter, hset]
  by_cases hx : x = 0
  · subst hx; simp
  · rw [if_neg hx]
    have hne : x ≠ -x := by
      intro h
      rcases (ZMod.neg_eq_self_iff x).mp h.symm with h' | h'
      · exact hx h'
      · have hodd : p % 2 = 1 := (Fact.out : p.Prime).eq_two_or_odd.resolve_left hp
        omega
    have e1 : quadraticChar (ZMod p) (x * x) = 1 := by
      rw [← sq]; exact quadraticChar_sq_one' hx
    have e2 : quadraticChar (ZMod p) (x * -x) = 1 := by
      rw [show x * -x = (-1) * x ^ 2 by ring, map_mul, hchi1, one_mul, quadraticChar_sq_one' hx]
    rw [Finset.sum_pair hne, e1, e2]
    norm_num

/-- **The exact second moment over all quadratic twists.** -/
theorem moment (hp : p ≠ 2) (h1 : p % 4 = 1) :
    ∑ d : ZMod p, (A p d) ^ 2 = 2 * (p : ℤ) * ((p : ℤ) - 1) := by
  have hF : ringChar (ZMod p) ≠ 2 := by rw [ZMod.ringChar_zmod_n]; exact hp
  have hp2 := (Fact.out : p.Prime).two_le
  have hstep1 : ∀ d : ZMod p, (A p d) ^ 2
      = ∑ x : ZMod p, ∑ y : ZMod p,
          quadraticChar (ZMod p) (x * y) *
            quadraticChar (ZMod p) ((d - x ^ 2) * (d - y ^ 2)) := by
    intro d
    rw [sq, A, Finset.sum_mul_sum]
    refine Finset.sum_congr rfl fun x _ => Finset.sum_congr rfl fun y _ => ?_
    rw [← map_mul, ← map_mul]
    congr 1
    ring
  rw [Finset.sum_congr rfl fun d _ => hstep1 d, Finset.sum_comm]
  have hswap : ∀ x : ZMod p, (∑ d : ZMod p, ∑ y : ZMod p,
        quadraticChar (ZMod p) (x * y) * quadraticChar (ZMod p) ((d - x ^ 2) * (d - y ^ 2)))
      = ∑ y : ZMod p, quadraticChar (ZMod p) (x * y) *
          (if x ^ 2 = y ^ 2 then (p : ℤ) - 1 else -1) := by
    intro x
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl fun y _ => ?_
    rw [← Finset.mul_sum, chiSum_quadratic p hp (x ^ 2) (y ^ 2)]
  rw [Finset.sum_congr rfl fun x _ => hswap x]
  have hterm : ∀ x y : ZMod p,
      quadraticChar (ZMod p) (x * y) * (if x ^ 2 = y ^ 2 then (p : ℤ) - 1 else -1)
        = (if x ^ 2 = y ^ 2 then quadraticChar (ZMod p) (x * y) else 0) * (p : ℤ)
          - quadraticChar (ZMod p) x * quadraticChar (ZMod p) y := by
    intro x y
    by_cases h : x ^ 2 = y ^ 2
    · rw [if_pos h, if_pos h, map_mul]; ring
    · rw [if_neg h, if_neg h, map_mul]; ring
  simp only [hterm, Finset.sum_sub_distrib]
  have hT : ∑ x : ZMod p, ∑ y : ZMod p,
      (if x ^ 2 = y ^ 2 then quadraticChar (ZMod p) (x * y) else 0) * (p : ℤ)
      = 2 * ((p : ℤ) - 1) * (p : ℤ) := by
    simp only [← Finset.sum_mul]
    rw [Finset.sum_congr rfl fun x _ => inner_T p hp h1 x]
    congr 1
    rw [Finset.sum_ite]
    have h : (univ.filter (fun x : ZMod p => ¬ x = 0)) = univ.erase 0 := by
      ext x; simp [Finset.mem_erase, and_comm]
    rw [h, Finset.sum_const, Finset.sum_const,
      Finset.card_erase_of_mem (Finset.mem_univ (0 : ZMod p)), Finset.card_univ, ZMod.card]
    simp only [smul_zero, zero_add, nsmul_eq_mul]
    push_cast [Nat.cast_sub (by omega : 1 ≤ p)]
    ring
  have hzero : ∑ x : ZMod p, ∑ y : ZMod p,
      quadraticChar (ZMod p) x * quadraticChar (ZMod p) y = 0 := by
    rw [← Finset.sum_mul_sum, quadraticChar_sum_zero hF, mul_zero]
  rw [hT, hzero, sub_zero]
  ring

/-- **The Weil floor.** The trace sum of `y² = x³ - x` obeys `|A| ≤ 2√p`. -/
theorem A_one_sq_le (hp : p ≠ 2) (h1 : p % 4 = 1) : (A p 1) ^ 2 ≤ 4 * (p : ℤ) := by
  have hp2 := (Fact.out : p.Prime).two_le
  set F : ZMod p → ℤ := fun d => (A p d) ^ 2 with hFdef
  have hFnn : ∀ d, 0 ≤ F d := fun d => sq_nonneg _
  have hscale : ∀ c ∈ univ.erase (0 : ZMod p), F (c ^ 2) = (A p 1) ^ 2 := by
    intro c hc
    have hc0 : c ≠ 0 := (Finset.mem_erase.mp hc).1
    rw [hFdef]
    simp only
    rw [A_sq_scale p hc0, mul_pow, quadraticChar_sq_one hc0, one_mul]
  have hleft : ∑ c ∈ univ.erase (0 : ZMod p), F (c ^ 2) = ((p : ℤ) - 1) * (A p 1) ^ 2 := by
    rw [Finset.sum_congr rfl hscale, Finset.sum_const,
      Finset.card_erase_of_mem (Finset.mem_univ (0 : ZMod p)), Finset.card_univ, ZMod.card,
      nsmul_eq_mul]
    congr 1
    push_cast [Nat.cast_sub (by omega : 1 ≤ p)]
    ring
  have hfib : ∀ b : ZMod p,
      ((univ.erase (0 : ZMod p)).filter (fun c => c ^ 2 = b)).card ≤ 2 := by
    intro b
    by_cases hemp : ((univ.erase (0 : ZMod p)).filter (fun c => c ^ 2 = b)) = ∅
    · simp [hemp]
    · obtain ⟨c0, hc0⟩ := Finset.nonempty_of_ne_empty hemp
      have hsub : ((univ.erase (0 : ZMod p)).filter (fun c => c ^ 2 = b)) ⊆ {c0, -c0} := by
        intro c hc
        have hcb : c ^ 2 = b := (Finset.mem_filter.mp hc).2
        have hc0b : c0 ^ 2 = b := (Finset.mem_filter.mp hc0).2
        have hcc : c ^ 2 = c0 ^ 2 := by rw [hcb, hc0b]
        rcases sq_eq_sq_iff_eq_or_eq_neg.mp hcc with h | h
        · simp [h]
        · simp [h]
      calc ((univ.erase (0 : ZMod p)).filter (fun c => c ^ 2 = b)).card
          ≤ ({c0, -c0} : Finset (ZMod p)).card := Finset.card_le_card hsub
        _ ≤ 2 := (Finset.card_insert_le _ _).trans (by simp)
  have hright : ∑ c ∈ univ.erase (0 : ZMod p), F (c ^ 2) ≤ 2 * ∑ d : ZMod p, F d := by
    rw [Finset.sum_comp F fun c : ZMod p => c ^ 2]
    have hle : ∑ b ∈ (univ.erase (0 : ZMod p)).image (fun c : ZMod p => c ^ 2),
        ((univ.erase (0 : ZMod p)).filter (fun c => c ^ 2 = b)).card • F b
        ≤ ∑ b ∈ (univ.erase (0 : ZMod p)).image (fun c : ZMod p => c ^ 2), 2 * F b := by
      refine Finset.sum_le_sum fun b _ => ?_
      rw [nsmul_eq_mul]
      have hb := hFnn b
      have hcard : (((univ.erase (0 : ZMod p)).filter (fun c => c ^ 2 = b)).card : ℤ) ≤ 2 := by
        exact_mod_cast hfib b
      exact mul_le_mul_of_nonneg_right hcard hb
    refine hle.trans ?_
    rw [Finset.mul_sum]
    exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
      fun b _ _ => by positivity
  rw [hleft, moment p hp h1] at hright
  have hpos : (0 : ℤ) < (p : ℤ) - 1 := by
    have : (2 : ℤ) ≤ (p : ℤ) := by exact_mod_cast hp2
    linarith
  nlinarith [hright, hpos]

/-- For `p ≡ 1 (mod 4)` the Jacobi-signed circle count is the twist sum `A p 1`. -/
theorem W_eq_A_one (h1 : p % 4 = 1) : W p = A p 1 := by
  rw [W, A]
  refine Finset.sum_congr rfl fun x _ => ?_
  rw [show x * (1 - x ^ 2) = (-1) * (x ^ 3 - 1 * x) by ring, map_mul,
    chi_neg_one_eq_one p h1, one_mul]

/-- **The Weil floor for the Jacobi-signed circle count.**
For every odd prime `p`, `W p ^ 2 ≤ 4 p`, i.e. `|W p| ≤ 2 √p`. -/
theorem W_sq_le (hp : p ≠ 2) : (W p) ^ 2 ≤ 4 * (p : ℤ) := by
  have hp2 := (Fact.out : p.Prime).two_le
  have hodd : p % 2 = 1 := (Fact.out : p.Prime).eq_two_or_odd.resolve_left hp
  by_cases h3 : p % 4 = 3
  · rw [W_eq_zero_of_three_mod_four p h3]
    have hnn : (0 : ℤ) ≤ (p : ℤ) := Int.natCast_nonneg p
    nlinarith
  · have h1 : p % 4 = 1 := by omega
    rw [W_eq_A_one p h1]
    exact A_one_sq_le p hp h1

/-- The Weil floor in absolute-value form: `|W p| ≤ 2 √p`. -/
theorem abs_W_le (hp : p ≠ 2) : |(W p : ℝ)| ≤ 2 * Real.sqrt p := by
  have h := W_sq_le p hp
  have h' : ((W p : ℝ)) ^ 2 ≤ 4 * (p : ℝ) := by exact_mod_cast h
  have hnn : (0 : ℝ) ≤ (p : ℝ) := Nat.cast_nonneg p
  have hsq : Real.sqrt p ^ 2 = (p : ℝ) := Real.sq_sqrt hnn
  have hs : 0 ≤ 2 * Real.sqrt p := by positivity
  nlinarith [abs_nonneg ((W p : ℝ)), sq_abs ((W p : ℝ)), hsq, Real.sqrt_nonneg (p : ℝ)]

end JacSign