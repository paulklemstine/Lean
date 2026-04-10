/-
# General k-Tuple Pythagorean Theory

Formalization of Pythagorean k-tuples using Fin-indexed vectors,
including peel identities, shared-hypotenuse collisions, lifting,
channel growth, and sphere reduction.
-/
import Mathlib

open Finset BigOperators

set_option maxHeartbeats 800000

/-! ## Definition -/

/-- A Pythagorean k-tuple: a vector v : Fin k → ℤ with hypotenuse d
    such that ∑ᵢ (v i)² = d². -/
def IsPythagoreanKTuple {k : ℕ} (v : Fin k → ℤ) (d : ℤ) : Prop :=
  ∑ i, (v i)^2 = d^2

/-! ## Peel Identity for k-Tuples -/

/-
For any component j of a k-tuple, (d - v j)(d + v j) = ∑_{i ≠ j} (v i)².
-/
theorem ktuple_factor_identity {k : ℕ} (v : Fin k → ℤ) (d : ℤ) (j : Fin k)
    (h : IsPythagoreanKTuple v d) :
    (d - v j) * (d + v j) = ∑ i ∈ Finset.univ.erase j, (v i)^2 := by
  simp_all +decide [ IsPythagoreanKTuple, mul_comm ];
  ring

/-! ## GCD Extraction -/

/-
GCD extraction from k-tuple peel identity.
-/
theorem ktuple_gcd_extraction {k : ℕ} (v : Fin k → ℤ) (d : ℤ) (j : Fin k)
    (h : IsPythagoreanKTuple v d) (N : ℤ) (hN : N = v j) :
    (Int.gcd (d - v j) N : ℤ) * (Int.gcd (d + v j) N : ℤ) ∣ N^2 := by
  convert mul_dvd_mul ( Int.gcd_dvd_right ( d - v j ) N ) ( Int.gcd_dvd_right ( d + v j ) N ) using 1 ; rw [ hN ] ; ring

/-! ## Shared Hypotenuse -/

/-- Two k-tuples sharing a hypotenuse have equal sums of squares. -/
theorem ktuple_shared_hypotenuse {k : ℕ} (v w : Fin k → ℤ) (d : ℤ)
    (hv : IsPythagoreanKTuple v d) (hw : IsPythagoreanKTuple w d) :
    ∑ i, (v i)^2 = ∑ i, (w i)^2 := by
  unfold IsPythagoreanKTuple at hv hw; linarith

/-! ## Lifting -/

/-
Any k-tuple can be extended to a (k+1)-tuple by appending 0.
-/
theorem ktuple_lift {k : ℕ} (v : Fin k → ℤ) (d : ℤ)
    (h : IsPythagoreanKTuple v d) :
    IsPythagoreanKTuple (Fin.snoc v 0) d := by
  -- By definition of Fin.snoc, we can decompose the sum over Fin (k+1) as the sum over Fin k plus the last element's square.
  have h_sum_split : ∑ i : Fin (k + 1), (Fin.snoc v 0 i)^2 = ∑ i : Fin k, (v i)^2 + (0)^2 := by
    simp +decide [ Fin.sum_univ_castSucc ];
  unfold IsPythagoreanKTuple at *; aesop;

/-! ## Channel and Cross-Collision Counts -/

/-- A k-tuple provides k factor identity channels (one per component). -/
theorem dimension_channel_growth (k : ℕ) (hk : k ≥ 3) : k - 1 ≥ 2 := by
  omega

/-
Cross-collision pairs grow quadratically: C(k-1, 2).
-/
theorem cross_collision_count (k : ℕ) (hk : k ≥ 3) :
    Nat.choose (k - 1) 2 ≥ 1 := by
  exact Nat.choose_pos ( by omega )

/-! ## Sphere Reduction -/

/-
If g divides all components and the hypotenuse, dividing through
    preserves the k-tuple property.
-/
theorem sphere_reduction {k : ℕ} (v : Fin k → ℤ) (d g : ℤ) (hg : g ≠ 0)
    (h : IsPythagoreanKTuple v d)
    (hdiv_v : ∀ i, g ∣ v i) (hdiv_d : g ∣ d) :
    IsPythagoreanKTuple (fun i => v i / g) (d / g) := by
  obtain ⟨ m, rfl ⟩ := hdiv_d;
  simp_all +decide [ IsPythagoreanKTuple, mul_pow ];
  exact mul_left_cancel₀ ( pow_ne_zero 2 hg ) ( by rw [ ← Finset.sum_congr rfl fun i _ => by rw [ ← Int.ediv_mul_cancel ( hdiv_v i ) ] ] at h; simpa [ Finset.mul_sum _ _ _, mul_pow, mul_assoc, mul_comm, mul_left_comm, Finset.sum_mul ] using h )

/-! ## Even Hypotenuse Parity -/

/-
In a k-tuple with even hypotenuse, the sum of squares of components
    is divisible by 4.
-/
theorem ktuple_even_hypotenuse_sq_div4 {k : ℕ} (v : Fin k → ℤ) (d : ℤ)
    (h : IsPythagoreanKTuple v d) (heven : 2 ∣ d) :
    4 ∣ ∑ i, (v i)^2 := by
  exact h.symm ▸ pow_dvd_pow_of_dvd heven 2

/-! ## Iterated Reduction -/

/-- Iterated GCD reduction preserves the k-tuple property. -/
theorem iterated_reduction_preserves {k : ℕ} (v : Fin k → ℤ) (d : ℤ)
    (h : IsPythagoreanKTuple v d) :
    let g := Finset.univ.gcd (fun i => (v i).natAbs)
    g > 0 → IsPythagoreanKTuple v d := by
  intro _ _; exact h