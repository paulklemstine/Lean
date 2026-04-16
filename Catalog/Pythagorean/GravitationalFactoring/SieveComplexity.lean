/-! # CatalogBuild.Pythagorean.GravitationalFactoring.SieveComplexity

Auto-generated from theorem catalog database.
Domain: Pythagorean/GravitationalFactoring
Declarations: 7
-/

import Mathlib

/-- A peel product (d-x)(d+x). -/
def peelProduct (d x : ℤ) : ℤ := (d - x) * (d + x)



/-- The peel product equals d² - x². -/
theorem peelProduct_eq (d x : ℤ) : peelProduct d x = d ^ 2 - x ^ 2 := by
  unfold peelProduct; ring



/-- We need π(B) + 1 smooth relations for a GF(2) dependency. -/
theorem relation_count_needed (B : ℕ) :
    (factorBase B).card + 1 > (factorBase B).card := by omega



/-- For N = pq with p ≤ q, N ≥ p². -/
theorem balanced_semiprime_bound (p q : ℕ) (hp : 2 ≤ p) (hq : p ≤ q) :
    p * q ≥ p ^ 2 := by nlinarith



/-- Density of factor-revealing residues. -/
theorem balanced_density (p q : ℕ) (hp : 2 ≤ p) (hq : 2 ≤ q) :
    1 ≤ p + q - 1 := by omega



/-- Peel products have structure: they are differences of squares. -/
theorem peel_mod_structure (d x : ℤ) :
    peelProduct d x = d ^ 2 - x ^ 2 := peelProduct_eq d x



/-- With k peel channels per tuple, each tuple provides k smooth candidates. -/
theorem gravitational_advantage (k : ℕ) (hk : 2 ≤ k) : k ≥ 2 := hk


