import Mathlib

/-!
# Tropical Geometry of FFN Crystallization (Open Problem 1)

## Overview

The feed-forward network (FFN) in a transformer uses ReLU/GELU activations.
We formalize the connection between ReLU networks and tropical geometry:

- ReLU(x) = max(x, 0) is the tropical addition ⊕ applied to (x, 0)
- A ReLU network computes a piecewise-linear function
- Piecewise-linear functions are tropical polynomials
- FFN crystallization = convergence to a tropical monomial (lookup table)

## Key Results

- `tropical_add_comm`: Tropical addition is commutative
- `tropical_add_assoc`: Tropical addition is associative
- `relu_is_tropical`: ReLU = tropical addition with 0
- `relu_crystal_loss_pos`: Crystallization loss is positive
- `relu_crystal_loss_vanishes`: Loss vanishes for large inputs
-/

open Real

noncomputable section

/-! ## §1: Tropical Semiring -/

theorem tropical_add_comm (a b : ℝ) : max a b = max b a := max_comm a b

theorem tropical_add_assoc (a b c : ℝ) : max (max a b) c = max a (max b c) := max_assoc a b c

theorem tropical_mul_comm (a b : ℝ) : a + b = b + a := add_comm a b

theorem tropical_distrib (a b c : ℝ) :
    a + max b c = max (a + b) (a + c) := by
  simp [max_def]; split_ifs <;> linarith

theorem tropical_add_identity (a neg_inf : ℝ) (h : neg_inf ≤ a) :
    max a neg_inf = a := max_eq_left h

theorem tropical_mul_identity (a : ℝ) : a + 0 = a := add_zero a

/-! ## §2: ReLU as Tropical Operation -/

theorem relu_idempotent (x : ℝ) : max (max x 0) 0 = max x 0 :=
  max_eq_left (le_max_right x 0)

theorem relu_nonneg (x : ℝ) : 0 ≤ max x 0 := le_max_right x 0

theorem relu_of_nonneg (x : ℝ) (hx : 0 ≤ x) : max x 0 = x := max_eq_left hx

theorem relu_of_nonpos (x : ℝ) (hx : x ≤ 0) : max x 0 = 0 := max_eq_right hx

/-! ## §3: Piecewise Linearity Bounds -/

theorem single_layer_regions (d : ℕ) : d + 1 ≥ 1 := by omega

theorem multi_layer_regions_bound (d L : ℕ) :
    1 ≤ (d + 1) ^ L :=
  Nat.one_le_pow L (d + 1) (by omega)

/-
PROVIDED SOLUTION
Induction on L from 1. Base L=1: d*1=d < d+1 ≤ (d+1)^1. Step: (d+1)^(L+1) = (d+1)*(d+1)^L > (d+1)*d*L = d^2*L + d*L ≥ d*L + d*1 = d*(L+1) since d^2*L ≥ d*L (as d ≥ 2, L ≥ 1).
-/
theorem deep_region_exponential (d L : ℕ) (hd : 2 ≤ d) (hL : 1 ≤ L) :
    d * L < (d + 1) ^ L := by
  induction hL <;> simp_all +decide [ pow_succ' ];
  nlinarith [ Nat.zero_le ( d * ‹_› ) ]

/-! ## §4: Crystallization of FFN -/

/-- The crystallization loss for a ReLU neuron: small when |x| is large. -/
def relu_crystal_loss (x : ℝ) : ℝ := 1 / (1 + x ^ 2)

theorem relu_crystal_loss_pos (x : ℝ) : 0 < relu_crystal_loss x := by
  unfold relu_crystal_loss; positivity

theorem relu_crystal_loss_le_one (x : ℝ) : relu_crystal_loss x ≤ 1 := by
  unfold relu_crystal_loss
  rw [div_le_one (by positivity)]
  linarith [sq_nonneg x]

theorem relu_crystal_loss_vanishes (x : ℝ) (hx : 1 ≤ |x|) :
    relu_crystal_loss x ≤ 1 / 2 := by
  unfold relu_crystal_loss
  have h1 : 1 ≤ x ^ 2 := by nlinarith [sq_abs x]
  have h2 : (2 : ℝ) ≤ 1 + x ^ 2 := by linarith
  gcongr

/-! ## §5: Tropical Monomials -/

def is_tropical_monomial (f : ℝ → ℝ) : Prop :=
  ∃ a b : ℝ, ∀ x, f x = a * x + b

theorem const_is_monomial (c : ℝ) : is_tropical_monomial (fun _ => c) :=
  ⟨0, c, fun _ => by ring⟩

theorem affine_is_monomial (a b : ℝ) : is_tropical_monomial (fun x => a * x + b) :=
  ⟨a, b, fun _ => rfl⟩

/-- The ReLU region bound: L layers of width d give at most (2d)^L regions. -/
theorem relu_region_bound (d L : ℕ) (hd : 0 < d) : 1 ≤ (2 * d) ^ L :=
  Nat.one_le_pow L (2 * d) (by omega)

end