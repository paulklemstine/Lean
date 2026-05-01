import Mathlib

/-! # CatalogBuild.Speculative.RosettaStone.NewDiscoveries

Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 15
-/

/-- [Section: # CatalogBuild.Speculative.RosettaStone.NewDiscoveries
Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 15] -/
theorem idempotent_count_8 :
    (Finset.univ.filter (fun e : ZMod 8 => e * e = e)).card = 2 := by decide

/-- Product of idempotents is idempotent (= "meet"). -/
theorem idempotent_mul (e f : R) (he : e * e = e) (hf : f * f = f) :
    (e * f) * (e * f) = e * f := by
  rw [mul_mul_mul_comm, he, hf]

/-- [Section: # CatalogBuild.Speculative.RosettaStone.NewDiscoveries
Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 15] -/
theorem idempotent_join (e f : R) (he : e * e = e) (hf : f * f = f) :
    (e + f - e * f) * (e + f - e * f) = e + f - e * f := by
  grind

/-- The "one" idempotent. -/
theorem one_idempotent : (1 : R) * 1 = 1 := mul_one 1

/-- Idempotent ordering is transitive: if ef = e and fg = f, then eg = e. -/
theorem idempotent_le_trans (e f g : R)
    (hef : e * f = e) (hfg : f * g = f) :
    e * g = e := by
  calc e * g = (e * f) * g := by rw [hef]
    _ = e * (f * g) := by rw [mul_assoc]
    _ = e * f := by rw [hfg]
    _ = e := hef

/-- Idempotent ordering is antisymmetric. -/
theorem idempotent_le_antisymm (e f : R)
    (hef : e * f = e) (hfe : f * e = f) :
    e = f := by
  rw [mul_comm] at hfe; rw [← hef, hfe]

/-- Newton's method for idempotents: if e² ≈ e, then e' = 3e² - 2e³
satisfies e'² - e' = (e² - e)² · (2e-3)(2e+1).
The defect squares at each step — quadratic convergence! -/
theorem newton_idempotent_step (e : R) :
    let e' := 3 * e ^ 2 - 2 * e ^ 3
    e' * e' - e' = (e * e - e) ^ 2 * ((2 * e - 3) * (2 * e + 1)) := by
  dsimp only
  ring

/-- Newton refinement preserves exact idempotents. -/
theorem newton_preserves_idempotent (e : R) (he : e * e = e) :
    3 * e ^ 2 - 2 * e ^ 3 = e := by
  have h2 : e ^ 2 = e := by rw [sq, he]
  have h3 : e ^ 3 = e := by
    rw [show (3 : ℕ) = 2 + 1 from rfl, pow_add, h2, pow_one, he]
  rw [h2, h3]; ring

/-- Tropical distributivity (left). -/
theorem tropical_distrib_left (a b c : ℝ) :
    a + min b c = min (a + b) (a + c) := by
  simp [min_def]; split_ifs <;> linarith

/-- Tropical distributivity (right). -/
theorem tropical_distrib_right (a b c : ℝ) :
    min b c + a = min (b + a) (c + a) := by
  simp [min_def]; split_ifs <;> linarith

/-- Every element decomposes via an idempotent. -/
theorem fundamental_decomposition (e x : R) :
    x = e * x + (1 - e) * x := by
  simp [sub_mul, one_mul]

/-- The two summands are orthogonal. -/
theorem fundamental_orthogonality (e : R) (he : e * e = e) (y : R) :
    e * ((1 - e) * y) = 0 := by
  rw [← mul_assoc, mul_sub, mul_one, he, sub_self, zero_mul]

/-- e acts as identity on eR. -/
theorem idempotent_acts_as_identity (e : R) (he : e * e = e) (x : R) :
    e * (e * x) = e * x := by rw [← mul_assoc, he]

/-- The (1,1)-Peirce component is stable under left multiplication by e. -/
theorem peirce_11_stable (e : R) (he : e * e = e) (x : R) :
    e * (e * x * e) = e * x * e := by
  rw [← mul_assoc, ← mul_assoc, he]

/-- The (1,1)-Peirce component is stable under right multiplication by e. -/
theorem peirce_11_stable_right (e : R) (he : e * e = e) (x : R) :
    (e * x * e) * e = e * x * e := by
  rw [mul_assoc, he]