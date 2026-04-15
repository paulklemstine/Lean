/-! # CatalogBuild.Pythagorean.Core.InsideOutFactoring

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 14
-/

import Mathlib

/-- All three inverse transforms share the same hypotenuse formula. -/
theorem parent_hypotenuse_universal (a b c : ℤ) :
    (invB1 a b c).2.2 = -2*a - 2*b + 3*c ∧
    (invB2 a b c).2.2 = -2*a - 2*b + 3*c ∧
    (invB3 a b c).2.2 = -2*a - 2*b + 3*c := by
  constructor
  · simp [invB1]
  constructor
  · simp [invB2]
  · simp [invB3]


/-- The parent hypotenuse is strictly less than c when a + b > c. -/
theorem parent_hypotenuse_decrease (a b c : ℤ)
    (ha : 0 < a) (hb : 0 < b) (hab : c < a + b) :
    -2*a - 2*b + 3*c < c := by linarith


/-- The parent via B₂⁻¹ has explicit components. -/
theorem parent2_components (N u h : ℤ) :
    invB2 N u h = (N + 2*u - 2*h, 2*N + u - 2*h, -2*N - 2*u + 3*h) := by
  simp [invB2]


/-- Grandparent via B₂⁻¹ ∘ B₂⁻¹ -/
def grandparent_B2B2 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  let p := invB2 a b c
  invB2 p.1 p.2.1 p.2.2


/-- [Section: ## §5. Grandparent: Composition of Two Parent Transforms
The grandparent via B₂⁻¹ ∘ B₂⁻¹ has the explicit formula:
(9a + 8b - 12c, 8a + 9b - 12c, -12a - 12b + 17c)
This is verified by direct computation.] -/
theorem grandparent_B2B2_explicit (a b c : ℤ) :
    grandparent_B2B2 a b c =
      (9*a + 8*b - 12*c, 8*a + 9*b - 12*c, -12*a - 12*b + 17*c) := by
  unfold grandparent_B2B2 invB2; ring;


/-- The grandparent B₂⁻¹ ∘ B₂⁻¹ preserves the Pythagorean property. -/
theorem grandparent_B2B2_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let t := grandparent_B2B2 a b c
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  have h1 := invB2_preserves_pyth a b c h
  exact invB2_preserves_pyth _ _ _ h1


/-- If an ancestor's leg has nontrivial GCD with N, we get a factor. -/
theorem factor_from_ancestor_leg (a' N : ℤ) (hN : 1 < N)
    (hg1 : 1 < Int.gcd a' N) (hg2 : (Int.gcd a' N : ℤ) < N) :
    ∃ d : ℤ, d ∣ N ∧ 1 < d ∧ d < N :=
  ⟨Int.gcd a' N, Int.gcd_dvd_right a' N, by exact_mod_cast hg1, hg2⟩


/-- If (N, u, h) maps to (3, 4, 5) via B₂⁻¹, then 3h = 2N + 2u + 5. -/
theorem root_via_B2_hypotenuse (N u h : ℤ)
    (h_root : invB2 N u h = (3, 4, 5)) :
    3 * h = 2*N + 2*u + 5 := by
  simp [invB2] at h_root; linarith [h_root.2.2]


/-- [Section: ## §7. The Root Equation System] -/
theorem root_via_B2_quadratic (N u h : ℤ)
    (hp : N ^ 2 + u ^ 2 = h ^ 2)
    (h_root : invB2 N u h = (3, 4, 5)) :
    5 * N ^ 2 - 8 * N * u - 20 * N + 5 * u ^ 2 - 20 * u - 25 = 0 := by
  unfold invB2 at h_root;
  grind


/-- For the trivial triple with odd N, c - b = 1. -/
theorem trivial_diff_one (N : ℤ) (hN : N % 2 = 1) :
    (N ^ 2 + 1) / 2 - (N ^ 2 - 1) / 2 = 1 := by omega


/-- The difference-of-squares factorization from a Pythagorean triple. -/
theorem diff_of_squares_factor (N u h : ℤ) (hp : N ^ 2 + u ^ 2 = h ^ 2) :
    (h - u) * (h + u) = N ^ 2 := by nlinarith [hp]


/-- Main factoring theorem: if we find u with h²=N²+u² and nontrivial gcd, we factor N. -/
theorem inside_out_factor_extraction (N u h : ℤ) (hN : 1 < N)
    (hp : N ^ 2 + u ^ 2 = h ^ 2)
    (hg : 1 < Int.gcd (h - u) N) (hg2 : (Int.gcd (h - u) N : ℤ) < N) :
    ∃ d : ℤ, d ∣ N ∧ 1 < d ∧ d < N := by
  exact ⟨Int.gcd (h - u) N, Int.gcd_dvd_right _ _, by exact_mod_cast hg, hg2⟩


/-- The first leg of the B₂⁻¹ parent of (N, u, h) equals N + 2u - 2h. -/
theorem parent_first_leg_structure (N u h : ℤ) :
    (invB2 N u h).1 = N + 2*u - 2*h := by
  simp [invB2]


/-- [Section: ## §10. Core Algebraic Identities] -/
theorem parent_leg_gcd_simplify (N u h : ℤ) :
    Int.gcd (N + (2*u - 2*h)) N = Int.gcd (2*u - 2*h) N := by
  refine' Nat.dvd_antisymm _ _;
  · exact Int.dvd_gcd ( by convert Int.dvd_sub ( Int.gcd_dvd_left _ _ ) ( Int.gcd_dvd_right _ _ ) using 1; ring ) ( Int.gcd_dvd_right _ _ );
  · exact Int.natCast_dvd_natCast.mp ( Int.dvd_coe_gcd ( dvd_add ( Int.gcd_dvd_right _ _ ) ( Int.gcd_dvd_left _ _ ) ) ( Int.gcd_dvd_right _ _ ) )
