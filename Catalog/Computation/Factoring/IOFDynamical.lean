/-! # CatalogBuild.Computation.Factoring.IOFDynamical

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 9
-/

import Mathlib

/-- The state of the IOF system at step k, represented as a point in ℤ³.
The trajectory lies on the Pythagorean cone a² + b² = c². -/
structure IOFState where
  a : ℤ
  b : ℤ
  c : ℤ




/-- Construct the IOF state at step k. -/
def state (N : ℤ) (k : ℕ) : IOFState where
  a := N - 2 * k
  b := ((N - 2 * k) ^ 2 - 1) / 2
  c := ((N - 2 * k) ^ 2 + 1) / 2




/-- [Section: # CatalogBuild.Computation.Factoring.IOFDynamical
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 9] -/
theorem same_factor_same_step (p q₁ q₂ : ℕ) (hp : Nat.Prime p) (hp2 : 2 < p)
    (hq₁ : Nat.Prime q₁) (hq₂ : Nat.Prime q₂)
    (hle₁ : p ≤ q₁) (hle₂ : p ≤ q₂) :
    let k := (p - 1) / 2
    (state (↑(p * q₁)) k).a % ↑p = (state (↑(p * q₂)) k).a % ↑p := by
      unfold state; norm_num [ mul_comm p, Int.add_emod, Int.sub_emod, Int.mul_emod ] ;




/-- [Section: # CatalogBuild.Computation.Factoring.IOFDynamical
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 9] -/
theorem energy_at_factor (p q : ℕ) (hp : 2 < p) (hq : 2 < q) (hp_odd : p % 2 = 1) :
    let N : ℤ := ↑(p * q)
    let k := (p - 1) / 2
    (N - 2 * ↑k) ^ 2 = (↑(p * q) - ↑p + 1) ^ 2 := by
      grind +ring




/-- The "velocity" of the descent in energy space at step k.
v(k) = E(k) - E(k+1) = 4(N - 2k - 1).
The velocity decreases linearly, meaning the system decelerates. -/
def velocity (N : ℤ) (k : ℕ) : ℤ := 4 * (N - 2 * k - 1)




theorem velocity_positive (N : ℕ) (k : ℕ) (hk : 2 * k + 1 < N) :
    0 < velocity (↑N) k := by
      exact mul_pos zero_lt_four ( by linarith )




theorem constant_deceleration (N : ℤ) (k : ℕ) :
    velocity N k - velocity N (k + 1) = 8 := by
      unfold velocity; ring;
      push_cast; ring;




theorem multi_stride_gcd (N p : ℕ) (s : ℕ) (hs : 0 < s)
    (hp : Nat.Prime p) (hdvd : p ∣ N) (hp2 : p ≠ 2)
    (k : ℕ) (hk : k = (p - 1) / 2)
    (j : ℕ) (hjs : j * s ≤ k) (hjsn : k < (j + 1) * s) :
    ∃ i, j * s ≤ i ∧ i < (j + 1) * s ∧ i = k := by
      aesop




theorem at_least_one_step (N p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hN : N = p * q) (hp2 : 2 < p) (hle : p ≤ q) :
    0 < (p - 1) / 2 := by
      grind



