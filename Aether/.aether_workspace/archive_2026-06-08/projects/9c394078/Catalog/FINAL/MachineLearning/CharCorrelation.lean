/-
# Quadratic Character Correlation Theorem

The key number-theoretic identity: for a prime `p ≡ 3 (mod 4)` and the
quadratic character `χ` on `𝔽_p`,

  `∑ t, χ(t) * χ(t + a) = if a = 0 then p - 1 else -1`

This is the heart of the Paley construction, reducing to the Jacobi sum identity
`J(χ, χ⁻¹) = -χ(-1)` from Mathlib.
-/
import Mathlib

open Finset BigOperators

noncomputable def quadCharZMod (p : ℕ) [Fact p.Prime] : ZMod p → ℤ :=
  quadraticChar (ZMod p)

section CharCorrelation

variable (p : ℕ) [hp : Fact p.Prime]

private lemma ringChar_ZMod_ne_two (hp3 : p % 4 = 3) :
    ringChar (ZMod p) ≠ 2 := by
  rw [ZMod.ringChar_zmod_n]
  omega

/-- The quadratic character on `ZMod p` has `χ(0) = 0`. -/
lemma quadCharZMod_zero : quadCharZMod p 0 = 0 :=
  quadraticChar_zero

/-- For nonzero `a`, `χ(a) ∈ {1, -1}`. -/
lemma quadCharZMod_dichotomy {a : ZMod p} (ha : a ≠ 0) :
    quadCharZMod p a = 1 ∨ quadCharZMod p a = -1 :=
  quadraticChar_dichotomy ha

/-- `χ(a)² = 1` for `a ≠ 0`. -/
lemma quadCharZMod_sq_one {a : ZMod p} (ha : a ≠ 0) :
    quadCharZMod p a ^ 2 = 1 :=
  quadraticChar_sq_one ha

/-- `χ(a) * χ(a) = 1` for `a ≠ 0`. -/
lemma quadCharZMod_mul_self {a : ZMod p} (ha : a ≠ 0) :
    quadCharZMod p a * quadCharZMod p a = 1 := by
  have := quadCharZMod_sq_one p ha; linarith [sq (quadCharZMod p a)]

/-- The sum of the quadratic character over all elements is 0. -/
lemma quadCharZMod_sum_zero (hp3 : p % 4 = 3) :
    ∑ t : ZMod p, quadCharZMod p t = 0 :=
  quadraticChar_sum_zero (ringChar_ZMod_ne_two p hp3)

/-- `χ(-1) = -1` when `p ≡ 3 (mod 4)`. -/
lemma quadCharZMod_neg_one (hp3 : p % 4 = 3) :
    quadCharZMod p (-1) = -1 := by
  unfold quadCharZMod
  rw [quadraticChar_neg_one (ringChar_ZMod_ne_two p hp3), ZMod.card p,
      ZMod.χ₄_nat_mod_four, hp3]
  decide

/-- `χ(-x) = -χ(x)` when `p ≡ 3 (mod 4)`. -/
lemma quadCharZMod_neg (hp3 : p % 4 = 3) (x : ZMod p) :
    quadCharZMod p (-x) = -quadCharZMod p x := by
  by_cases hx : x = 0
  · simp [hx, quadCharZMod_zero]
  · unfold quadCharZMod
    rw [show (-x : ZMod p) = (-1) * x from by ring,
        map_mul (quadraticChar (ZMod p))]
    have : quadraticChar (ZMod p) (-1 : ZMod p) = -1 := by
      exact quadCharZMod_neg_one p hp3
    unfold quadCharZMod at this
    rw [this]; ring

/-- The quadratic character is its own inverse. -/
lemma quadChar_self_inv :
    (quadraticChar (ZMod p))⁻¹ = quadraticChar (ZMod p) :=
  (quadraticChar_isQuadratic (ZMod p)).inv

/-- The quadratic character is nontrivial when `p ≡ 3 (mod 4)`. -/
lemma quadChar_ne_one (hp3 : p % 4 = 3) :
    quadraticChar (ZMod p) ≠ 1 :=
  quadraticChar_ne_one (ringChar_ZMod_ne_two p hp3)

/-
The diagonal case: `∑ t, χ(t)² = p - 1`.
The `t = 0` term contributes 0, and each `t ≠ 0` term contributes 1.
-/
lemma quadChar_correlation_diag (hp3 : p % 4 = 3) :
    ∑ t : ZMod p, quadCharZMod p t * quadCharZMod p t = (p : ℤ) - 1 := by
  -- We begin by separating the sum into the term for t = 0 and the rest.
  have h0 : (∑ t, quadCharZMod p t * quadCharZMod p t) = (∑ t ∈ Finset.univ.erase 0, quadCharZMod p t * quadCharZMod p t) + (quadCharZMod p 0) * (quadCharZMod p 0) := by
    rw [ Finset.sum_erase_add _ _ ( Finset.mem_univ _ ) ];
  -- By definition of $quadCharZMod$, we know that for $t ≠ 0$, $(quadCharZMod p t)² = 1$.
  have h1 : ∀ t : ZMod p, t ≠ 0 → (quadCharZMod p t) * (quadCharZMod p t) = 1 := by
    exact?;
  rw [ h0, Finset.sum_congr rfl fun t ht => h1 t <| Finset.ne_of_mem_erase ht, Finset.sum_const, Finset.card_erase_of_mem <| Finset.mem_univ _, Finset.card_univ, ZMod.card, nsmul_eq_mul, mul_one ] ; simp +decide [ quadCharZMod_zero ];
  rw [ Nat.cast_pred hp.1.pos ]

/-
The Jacobi sum `J(χ, χ) = ∑ a, χ(a) * χ(1 - a) = -χ(-1) = 1` when `p ≡ 3 mod 4`.
-/
lemma jacobiSum_quadChar (hp3 : p % 4 = 3) :
    jacobiSum (quadraticChar (ZMod p)) (quadraticChar (ZMod p)) = 1 := by
  -- Since $\chi$ is quadratic, $\chi$ is nontrivial when $p \equiv 3 \mod 4$.
  have h_quad_ne_one : quadraticChar (ZMod p) ≠ 1 := by
    exact?;
  have := @jacobiSum_nontrivial_inv ( ZMod p );
  convert @this ℤ _ _ _ _ ( quadraticChar ( ZMod p ) ) h_quad_ne_one using 1;
  · rw [ quadChar_self_inv ];
  · have h_quad_neg_one : quadraticChar (ZMod p) (-1) = -1 := by
      convert quadCharZMod_neg_one p hp3 using 1;
    grind

/-
Key: `∑ t, χ(t) * χ(t + 1) = -1`.
Proof: substitute `u = -t` to relate to `J(χ, χ)`, using `χ(-1) = -1`.
-/
lemma quadChar_correlation_one (hp3 : p % 4 = 3) :
    ∑ t : ZMod p, quadCharZMod p t * quadCharZMod p (t + 1) = -1 := by
  -- By the properties of the quadratic character, we know that $\sum_{t \in \mathbb{F}_p} \chi(t) \chi(t + 1) = \sum_{u \in \mathbb{F}_p} \chi(-u) \chi(1 - u)$.
  have h_sum : ∑ t : ZMod p, quadCharZMod p t * quadCharZMod p (t + 1) = ∑ u : ZMod p, quadCharZMod p (-u) * quadCharZMod p (1 - u) := by
    rw [ ← Equiv.sum_comp ( Equiv.neg ( ZMod p ) ) ] ; norm_num ; congr ; ext ; ring;
  -- By the properties of the quadratic character, we know that $\chi(-u) = -\chi(u)$ for all $u \in \mathbb{F}_p$.
  have h_neg : ∀ u : ZMod p, quadCharZMod p (-u) = -quadCharZMod p u := by
    exact?;
  simp_all +decide [ Finset.sum_neg_distrib, mul_neg ];
  convert jacobiSum_quadChar p hp3 using 1

/-
`∑ t, χ(t) * χ(t + a) = -1` for `a ≠ 0`, by scaling.
-/
lemma quadChar_correlation_off_diag (hp3 : p % 4 = 3) {a : ZMod p} (ha : a ≠ 0) :
    ∑ t : ZMod p, quadCharZMod p t * quadCharZMod p (t + a) = -1 := by
  -- Substitute $t = a * s$ in the sum.
  have h_subst : ∑ t : ZMod p, quadCharZMod p t * quadCharZMod p (t + a) = ∑ s : ZMod p, quadCharZMod p (a * s) * quadCharZMod p (a * s + a) := by
    have h_subst : Finset.image (fun s => a * s) (Finset.univ : Finset (ZMod p)) = Finset.univ := by
      exact Finset.eq_of_subset_of_card_le ( Finset.subset_univ _ ) ( by rw [ Finset.card_image_of_injective _ fun x y hxy => mul_left_cancel₀ ha hxy ] );
    conv_lhs => rw [ ← h_subst, Finset.sum_image ( Finset.card_image_iff.mp <| by simp +decide [ h_subst ] ) ] ;
  -- Factor out $\chi(a)$ from the sum.
  have h_factor : ∑ s : ZMod p, quadCharZMod p (a * s) * quadCharZMod p (a * s + a) = quadCharZMod p a * quadCharZMod p a * ∑ s : ZMod p, quadCharZMod p s * quadCharZMod p (s + 1) := by
    simp +decide only [Finset.mul_sum _ _ _, mul_left_comm, mul_assoc];
    refine' Finset.sum_congr rfl fun x _ => _;
    unfold quadCharZMod; simp +decide [ *, quadraticCharFun_mul ] ; ring;
    rw [ show a + a * x = a * ( 1 + x ) by ring, quadraticCharFun_mul ] ; ring;
  rw [ h_subst, h_factor, quadCharZMod_mul_self, one_mul, quadChar_correlation_one ] ; aesop;
  exact ha

/-- **The quadratic character correlation theorem**.
`∑ t, χ(t) * χ(t + a) = if a = 0 then p - 1 else -1`. -/
theorem quadChar_correlation (hp3 : p % 4 = 3) (a : ZMod p) :
    ∑ t : ZMod p, quadCharZMod p t * quadCharZMod p (t + a) =
      if a = 0 then (p : ℤ) - 1 else -1 := by
  split
  · next h => rw [h]; simp [quadChar_correlation_diag p hp3]
  · next h => exact quadChar_correlation_off_diag p hp3 h

end CharCorrelation