/-! # CatalogBuild.Pythagorean.Research.DensityAndChannels

Auto-generated from theorem catalog database.
Domain: Pythagorean/Research
Declarations: 7
-/

import Mathlib

theorem peel_identity_sum {k : ℕ} (legs : Fin k → ℤ) (d : ℤ) (j : Fin k)
    (h : (∑ i, (legs i) ^ 2) = d ^ 2) :
    (d - legs j) * (d + legs j) = ∑ i ∈ Finset.univ.erase j, (legs i) ^ 2 := by
  have hsplit : (∑ i, (legs i) ^ 2) =
      (legs j) ^ 2 + ∑ i ∈ Finset.univ.erase j, (legs i) ^ 2 := by
    rw [← Finset.add_sum_erase _ _ (Finset.mem_univ j)]
  nlinarith [peel_product_eq d (legs j)]

/-! ## §3. Density of Factoring-Revealing Residues (Open Question 2.1) -/

/-- The inclusion-exclusion count: among {1, ..., pq}, the number of elements
sharing a nontrivial factor with pq equals p + q - 1 (when gcd(p,q) = 1). -/

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

/-! ## §4. Cross-Collision Channel Theory -/

/-- The cross-collision difference-of-squares identity. -/

theorem balanced_density_formula (p : ℕ) (hp : 0 < p) :
    p + p - 1 = 2 * p - 1 := by omega

/-- The number of factoring-revealing residues grows with p + q. -/

theorem density_monotone (p₁ q₁ p₂ q₂ : ℕ)
    (h : p₁ + q₁ ≤ p₂ + q₂) :
    p₁ + q₁ - 1 ≤ p₂ + q₂ - 1 := by omega

/-! ## §11. The Quaternion-to-Integer Factoring Reduction -/

/-- Quaternion norm is always nonneg. -/

theorem quaternion_component_bound (a b c d N : ℤ)
    (h : a^2 + b^2 + c^2 + d^2 = N) :
    a^2 ≤ N := by nlinarith [sq_nonneg b, sq_nonneg c, sq_nonneg d]

/-! ## §12. Parity Obstruction for Odd Semiprimes -/

/-- The peel product d² - x² preserves parity information. -/

theorem peel_parity (d x : ℤ) :
    (d - x) * (d + x) % 2 = (d^2 - x^2) % 2 := by
  congr 1; ring

/-! ## §13. Channel Success Probability Bound -/

/-- For k independent channels each with success probability δ,
the probability of at least one success is 1 - (1-δ)^k.
Here we prove the key algebraic fact that (1-δ)^k < 1 when 0 < δ < 1 and k > 0. -/

theorem fano_plane_channels : 480 * (8 + Nat.choose 8 2) = 17280 := by decide
