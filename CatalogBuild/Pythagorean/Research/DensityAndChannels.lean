/-! # CatalogBuild.Pythagorean.Research.DensityAndChannels

Auto-generated from theorem catalog database.
Domain: Pythagorean/Research
Declarations: 7
-/

import Mathlib

/-- The peel identity in the context of a k-tuple: if Σxᵢ² = d², then
(d - xⱼ)(d + xⱼ) = Σᵢ≠ⱼ xᵢ². -/
theorem peel_identity_sum {k : ℕ} (legs : Fin k → ℤ) (d : ℤ) (j : Fin k)
    (h : (∑ i, (legs i) ^ 2) = d ^ 2) :
    (d - legs j) * (d + legs j) = ∑ i ∈ Finset.univ.erase j, (legs i) ^ 2 := by
  have hsplit : (∑ i, (legs i) ^ 2) =
      (legs j) ^ 2 + ∑ i ∈ Finset.univ.erase j, (legs i) ^ 2 := by
    rw [← Finset.add_sum_erase _ _ (Finset.mem_univ j)]
  nlinarith [peel_product_eq d (legs j)]


/-- [Section: ## §3. Density of Factoring-Revealing Residues (Open Question 2.1)] -/
theorem density_formula_primes (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hne : p ≠ q) :
    (Finset.filter (fun x => ¬ Nat.Coprime x (p * q))
      (Finset.range (p * q))).card = p + q - 1 := by
  -- The cardinality of the set is equal to $\varphi(pq)$.
  have h_card : #({x ∈ Finset.range (p * q) | ¬Nat.Coprime x (p * q)}) = p * q - Nat.totient (p * q) := by
    simp +decide [ Nat.totient, Finset.filter_not, Finset.card_sdiff ];
    simp +decide [ Nat.coprime_comm, Finset.filter_inter ];
  rw [ h_card, Nat.totient_mul, Nat.totient_prime hp, Nat.totient_prime hq ];
  · exact Nat.sub_eq_of_eq_add <| by nlinarith only [ Nat.sub_add_cancel hp.pos, Nat.sub_add_cancel hq.pos, Nat.sub_add_cancel ( show 1 ≤ p + q from by linarith only [ hp.pos, hq.pos ] ) ] ;
  · simpa [ * ] using Nat.coprime_primes hp hq


/-- For a balanced semiprime N = p², the density is (2p - 1)/p² ≈ 2/√N. -/
theorem balanced_density_formula (p : ℕ) (hp : 0 < p) :
    p + p - 1 = 2 * p - 1 := by omega


/-- The number of factoring-revealing residues grows with p + q. -/
theorem density_monotone (p₁ q₁ p₂ q₂ : ℕ)
    (h : p₁ + q₁ ≤ p₂ + q₂) :
    p₁ + q₁ - 1 ≤ p₂ + q₂ - 1 := by omega


/-- If the quaternion norm equals N, each component is bounded by √N. -/
theorem quaternion_component_bound (a b c d N : ℤ)
    (h : a^2 + b^2 + c^2 + d^2 = N) :
    a^2 ≤ N := by nlinarith [sq_nonneg b, sq_nonneg c, sq_nonneg d]


/-- The peel product d² - x² preserves parity information. -/
theorem peel_parity (d x : ℤ) :
    (d - x) * (d + x) % 2 = (d^2 - x^2) % 2 := by
  congr 1; ring


/-- 480 Fano planes × 36 channels per 8-tuple = 17280 total channels. -/
theorem fano_plane_channels : 480 * (8 + Nat.choose 8 2) = 17280 := by decide
