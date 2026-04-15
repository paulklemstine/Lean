/-! # CatalogBuild.NumberTheory.Diophantine.LinearDiophantine

Auto-generated from theorem catalog database.
Domain: NumberTheory/Diophantine
Declarations: 7
-/

import Mathlib

theorem bezout_identity_explicit (a b : ℤ) :
    ∃ x y : ℤ, a * x + b * y = Int.gcd a b := by
  exact Int.gcd_eq_gcd_ab a b ▸ ⟨ _, _, rfl ⟩

/-! ## The Fundamental Theorem -/

/-
PROBLEM
The linear Diophantine equation `a * x + b * y = c` has integer solutions
    if and only if `gcd(a, b)` divides `c`.

PROVIDED SOLUTION
Forward: if (x,y) is a solution, then gcd(a,b) | a*x + b*y = c since gcd divides both a and b. Use Int.gcd_dvd_left and Int.gcd_dvd_right. Backward: if gcd | c, write c = gcd * k, use Bezout to get a*s + b*t = gcd, then x = s*k, y = t*k works.
-/

theorem linear_diophantine_solvable_iff (a b c : ℤ) :
    (∃ x y : ℤ, a * x + b * y = c) ↔ (↑(Int.gcd a b) : ℤ) ∣ c := by
  constructor;
  · exact fun ⟨ x, y, h ⟩ => h ▸ dvd_add ( dvd_mul_of_dvd_left ( Int.gcd_dvd_left _ _ ) _ ) ( dvd_mul_of_dvd_left ( Int.gcd_dvd_right _ _ ) _ );
  · exact fun h => by rcases h with ⟨ k, rfl ⟩ ; exact ⟨ k * Int.gcdA a b, k * Int.gcdB a b, by rw [ Int.gcd_eq_gcd_ab ] ; ring ⟩ ;

/-! ## Solution Structure -/

/-
PROBLEM
If `(x₀, y₀)` is a solution to `ax + by = c`, then for any integer `k`,
    `(x₀ + k * (b / gcd(a,b)), y₀ - k * (a / gcd(a,b)))` is also a solution,
    provided gcd(a,b) divides both a and b (which it always does).

PROVIDED SOLUTION
Expand: a*(x₀ + k*(b/g)) + b*(y₀ - k*(a/g)) = a*x₀ + b*y₀ + k*(a*(b/g) - b*(a/g)). The first part equals c by h. For the second part, since g = gcd(a,b) divides both a and b, we have a = g*(a/g) and b = g*(b/g), so a*(b/g) - b*(a/g) = g*(a/g)*(b/g) - g*(b/g)*(a/g) = 0. Use Int.ediv_mul_cancel with Int.gcd_dvd_left and Int.gcd_dvd_right.
-/

theorem linear_diophantine_family (a b c x₀ y₀ k : ℤ) (g : ℤ)
    (hg_def : g = Int.gcd a b)
    (h : a * x₀ + b * y₀ = c) :
    a * (x₀ + k * (b / g)) + b * (y₀ - k * (a / g)) = c := by
  cases' eq_or_ne g 0 <;> simp_all +decide [ mul_left_comm, mul_assoc ];
  · lia;
  · rw [ ← h ] ; ring;
    rw [ ← Int.mul_ediv_assoc _ ( Int.gcd_dvd_left _ _ ), ← Int.mul_ediv_assoc _ ( Int.gcd_dvd_right _ _ ) ] ; ring;

/-! ## Homogeneous Case -/

/-- The homogeneous equation `ax + by = 0` always has the solution `(b, -a)`. -/

theorem linear_diophantine_homogeneous (a b : ℤ) :
    a * b + b * (-a) = 0 := by ring

/-
PROBLEM
Any two solutions of `ax + by = c` differ by a solution of the homogeneous equation.

PROVIDED SOLUTION
Subtract h₂ from h₁ and use ring.
-/

theorem linear_diophantine_difference (a b c x₁ y₁ x₂ y₂ : ℤ)
    (h₁ : a * x₁ + b * y₁ = c)
    (h₂ : a * x₂ + b * y₂ = c) :
    a * (x₁ - x₂) + b * (y₁ - y₂) = 0 := by
  linear_combination h₁ - h₂

/-! ## Special Cases -/

/-
PROBLEM
When gcd(a,b) = 1, the equation ax + by = c always has solutions.

PROVIDED SOLUTION
Since gcd = 1, use the forward direction of linear_diophantine_solvable_iff. One divides everything, so the condition is trivially satisfied.
-/

theorem linear_diophantine_coprime (a b c : ℤ)
    (hcop : Int.gcd a b = 1) :
    ∃ x y : ℤ, a * x + b * y = c := by
  exact linear_diophantine_solvable_iff a b c |>.2 ( by simp +decide [ hcop ] )

/-
PROBLEM
When a and b are both zero, ax + by = c has solutions iff c = 0.

PROVIDED SOLUTION
0*x + 0*y = 0 always, so any x,y works when c=0. When c≠0, 0*x + 0*y = 0 ≠ c. Use simp.
-/

theorem linear_diophantine_zero (c : ℤ) :
    (∃ x y : ℤ, (0 : ℤ) * x + (0 : ℤ) * y = c) ↔ c = 0 := by
  grind
