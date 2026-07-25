import Mathlib
import Speculative.Collatz.Accelerated

/-!
# Cycle Obstruction Theorems for Collatz Dynamics

This file proves the **product identity** for hypothetical periodic orbits
of the accelerated odd Collatz map, and derives cycle exclusion criteria.

## Main results

1. **Cycle recurrence identity**: If `x₀, ..., x_{k-1}` form a cycle of the
   accelerated odd map with 2-adic valuations `a₀, ..., a_{k-1}`, then
   `2^{a_i} · x_{i+1} = 3 · x_i + 1` for all `i`.

2. **Product identity**: For a cycle of length `k`,
   `2^(∑ aᵢ) · ∏ xᵢ = ∏ (3·xᵢ + 1)`.

3. **Rational product identity**: `2^(∑ aᵢ) = ∏ (3 + 1/xᵢ)` as rationals.

These identities provide a framework for excluding nontrivial cycles:
the rational product must simultaneously be a power of 2 and a product
of terms slightly above 3, creating strong arithmetic constraints.

## Mathematical significance

Any nontrivial cycle of the Collatz map must satisfy these identities.
Combined with bounds on the xᵢ, they provide computable certificates
ruling out cycles in specific parameter ranges.
-/

namespace Collatz

/-! ### Cycle recurrence -/

/-
In a cycle of the accelerated odd map, each step satisfies the recurrence
    `2^(v₂(3xᵢ+1)) · x_{i+1} = 3·xᵢ + 1`.
-/
theorem cycle_recurrence
    (k : ℕ) (hk : 0 < k)
    (x : Fin k → ℕ)
    (hpos : ∀ i, 0 < x i)
    (hodd : ∀ i, (x i) % 2 = 1)
    (hcyc : ∀ i : Fin k,
      accelCollatzOdd (x i) = x ⟨(i.1 + 1) % k, Nat.mod_lt _ hk⟩) :
    ∀ i : Fin k,
      2 ^ v2Nat (3 * x i + 1) * x ⟨(i.1 + 1) % k, Nat.mod_lt _ hk⟩ =
        3 * x i + 1 := by
  intro i;
  convert accel_formula ( x i ) |> Eq.symm using 1;
  grind

/-
**Product identity for odd cycles (natural number version)**:
    For a cycle `x₀, ..., x_{k-1}` of the accelerated odd map,
    `∏ᵢ (3·xᵢ + 1) = 2^(∑ᵢ aᵢ) · ∏ᵢ xᵢ`
    where `aᵢ = v₂(3·xᵢ + 1)`.
-/
theorem cycle_product_identity
    (k : ℕ) (hk : 0 < k)
    (x : Fin k → ℕ)
    (hpos : ∀ i, 0 < x i)
    (hodd : ∀ i, (x i) % 2 = 1)
    (hcyc : ∀ i : Fin k,
      accelCollatzOdd (x i) = x ⟨(i.1 + 1) % k, Nat.mod_lt _ hk⟩) :
    ∏ i, (3 * x i + 1) =
      2 ^ (∑ i, v2Nat (3 * x i + 1)) * ∏ i, x i := by
  have := cycle_recurrence k hk x hpos hodd hcyc;
  rw [ ← Finset.prod_congr rfl fun i _ => this i, Finset.prod_mul_distrib, Finset.prod_pow_eq_pow_sum ];
  rcases k with ( _ | _ | k ) <;> norm_num at *;
  · simp +decide [ Fin.eq_zero ];
  · conv_rhs => rw [ ← Equiv.prod_comp ( Equiv.addRight 1 ) ] ;
    norm_num [ Fin.add_def ]

/-
**Rational product identity for odd cycles**:
    For a cycle, `2^(∑ aᵢ) = ∏ (3 + 1/(xᵢ : ℚ))`.
    This is the key identity for deriving cycle exclusion bounds.
-/
theorem cycle_rational_product_identity
    (k : ℕ) (hk : 0 < k)
    (x : Fin k → ℕ)
    (hpos : ∀ i, 0 < x i)
    (hodd : ∀ i, (x i) % 2 = 1)
    (hcyc : ∀ i : Fin k,
      accelCollatzOdd (x i) = x ⟨(i.1 + 1) % k, Nat.mod_lt _ hk⟩) :
    (2 : ℚ) ^ (∑ i, v2Nat (3 * x i + 1)) =
      ∏ i, (3 + 1 / (x i : ℚ)) := by
  -- Apply the product identity to rewrite the goal in terms of the product of the odd parts.
  have h_prod : (∏ i, (3 * x i + 1 : ℚ)) = 2 ^ (∑ i, v2Nat (3 * x i + 1)) * (∏ i, x i : ℚ) := by
    exact mod_cast cycle_product_identity k hk x hpos hodd hcyc;
  convert congr_arg ( fun y : ℚ => y / ∏ i, ( x i : ℚ ) ) h_prod.symm using 1;
  · rw [ mul_div_cancel_right₀ _ ( Finset.prod_ne_zero_iff.mpr fun i _ => Nat.cast_ne_zero.mpr ( ne_of_gt ( hpos i ) ) ) ];
  · rw [ ← Finset.prod_div_distrib, Finset.prod_congr rfl ] ; intros ; rw [ add_div, mul_div_cancel_right₀ _ ( Nat.cast_ne_zero.mpr <| ne_of_gt <| hpos _ ) ]

/-! ### Cycle exclusion criteria -/

/-
In any cycle, the sum of valuations satisfies `∑ aᵢ ≥ k`, since each aᵢ ≥ 1
    (because 3xᵢ+1 is even for odd xᵢ).
-/
theorem cycle_valuation_sum_ge
    (k : ℕ) (hk : 0 < k)
    (x : Fin k → ℕ)
    (hpos : ∀ i, 0 < x i)
    (hodd : ∀ i, (x i) % 2 = 1)
    (hcyc : ∀ i : Fin k,
      accelCollatzOdd (x i) = x ⟨(i.1 + 1) % k, Nat.mod_lt _ hk⟩) :
    k ≤ ∑ i, v2Nat (3 * x i + 1) := by
  exact le_trans ( by norm_num ) ( Finset.sum_le_sum fun i _ => v2Nat_three_mul_add_one_pos ( hodd i ) )

/-
**Lower bound on cycle products**: In any cycle with minimum element at least `B`,
    the product `∏(3 + 1/xᵢ)` satisfies `3^k < ∏(3 + 1/xᵢ) ≤ (3 + 1/B)^k`.
-/
theorem cycle_product_bounds
    (k : ℕ) (hk : 0 < k)
    (x : Fin k → ℕ)
    (hpos : ∀ i, 0 < x i)
    (hodd : ∀ i, (x i) % 2 = 1)
    (B : ℕ) (hB : 0 < B)
    (hmin : ∀ i, B ≤ x i) :
    (3 : ℚ) ^ k < ∏ i, (3 + 1 / (x i : ℚ)) ∧
    ∏ i, (3 + 1 / (x i : ℚ)) ≤ (3 + 1 / (B : ℚ)) ^ k := by
  constructor;
  · exact lt_of_le_of_lt ( by norm_num ) ( Finset.prod_lt_prod ( fun _ _ => by positivity ) ( fun _ _ => by linarith [ show ( 0 : ℚ ) < 1 / x ‹_› from one_div_pos.mpr ( Nat.cast_pos.mpr ( hpos _ ) ) ] ) ( show ∃ i, i ∈ Finset.univ ∧ 3 < 3 + 1 / ( x i : ℚ ) from ⟨ ⟨ 0, hk ⟩, Finset.mem_univ _, lt_add_of_pos_right _ ( one_div_pos.mpr ( Nat.cast_pos.mpr ( hpos _ ) ) ) ⟩ ) );
  · exact le_trans ( Finset.prod_le_prod ( fun _ _ => by positivity ) fun _ _ => show ( 3 + 1 / ( x _ : ℚ ) ) ≤ 3 + 1 / ( B : ℚ ) by gcongr ; exact_mod_cast hmin _ ) ( by norm_num )

end Collatz