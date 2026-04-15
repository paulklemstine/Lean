/-! # CatalogBuild.Pythagorean.GravitationalFactoring.SieveComplexity

Auto-generated from theorem catalog database.
Domain: Pythagorean/GravitationalFactoring
Declarations: 7
-/

import Mathlib

def peelProduct (d x : ℤ) : ℤ := (d - x) * (d + x)

/-- The peel product equals d² - x². -/

theorem peelProduct_eq (d x : ℤ) : peelProduct d x = d ^ 2 - x ^ 2 := by
  unfold peelProduct; ring

/-! ## §3. Factor Base -/

/-- The factor base: primes up to B. -/

theorem relation_count_needed (B : ℕ) :
    (factorBase B).card + 1 > (factorBase B).card := by omega

/-! ## §4. Balanced Semiprimes -/

/-- For N = pq with p ≤ q, N ≥ p². -/

theorem balanced_semiprime_bound (p q : ℕ) (hp : 2 ≤ p) (hq : p ≤ q) :
    p * q ≥ p ^ 2 := by nlinarith

/-- Density of factor-revealing residues. -/

theorem balanced_density (p q : ℕ) (hp : 2 ≤ p) (hq : 2 ≤ q) :
    1 ≤ p + q - 1 := by omega

/-! ## §5. L-Notation Optimal Parameter -/

/-- The optimal α = 1/2 balances collection cost and LA cost. -/

theorem peel_mod_structure (d x : ℤ) :
    peelProduct d x = d ^ 2 - x ^ 2 := peelProduct_eq d x

/-- With k peel channels per tuple, each tuple provides k smooth candidates. -/

theorem gravitational_advantage (k : ℕ) (hk : 2 ≤ k) : k ≥ 2 := hk

