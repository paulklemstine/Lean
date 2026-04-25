/-! # CatalogBuild.Pythagorean.Research.NontrivialShortcuts

Auto-generated from theorem catalog database.
Domain: Pythagorean/Research
Declarations: 8
-/

import Mathlib

/-- [Section: # CatalogBuild.Pythagorean.Research.NontrivialShortcuts
Auto-generated from theorem catalog database.
Domain: Pythagorean/Research
Declarations: 8] -/
theorem divisor_pair_triple (N d e : ℤ) (hprod : d * e = N ^ 2)
    (hparity : (2 : ℤ) ∣ (e - d)) :
    N ^ 2 + ((e - d) / 2) ^ 2 = ((e + d) / 2) ^ 2 := by
      cases abs_cases N <;> cases abs_cases d <;> cases abs_cases e <;> nlinarith [ Int.ediv_mul_cancel hparity, Int.ediv_mul_cancel ( show 2 ∣ e + d from by obtain ⟨ k, hk ⟩ := hparity; omega ) ]


/-- gcd(d, N) divides N. -/
theorem gcd_divides (N d : ℕ) : Nat.gcd d N ∣ N := Nat.gcd_dvd_right d N


/-- gcd(p, pq) = p. -/
theorem semiprime_shortcut (p q : ℕ) :
    Nat.gcd p (p * q) = p := Nat.gcd_eq_left (dvd_mul_right p q)


/-- [Section: # CatalogBuild.Pythagorean.Research.NontrivialShortcuts
Auto-generated from theorem catalog database.
Domain: Pythagorean/Research
Declarations: 8] -/
theorem nontrivial_pair_implies_factor (N d e : ℕ) (hN : 1 < N)
    (hprod : d * e = N ^ 2) (hd1 : 1 < d) (hdN : d < N) :
    1 < Nat.gcd d N := by
      contrapose! hdN;
      interval_cases _ : Nat.gcd d N <;> simp_all +decide [ Nat.Coprime, Nat.Coprime.symm ];
      -- Since $d$ and $N$ are coprime and $d \mid N^2$, it follows that $d \mid N$.
      have h_div : d ∣ N := by
        exact ( Nat.Coprime.dvd_of_dvd_mul_left ‹_› <| by use e; linarith );
      cases h_div ; aesop


/-- Any factor gives a non-trivial divisor pair. -/
theorem factor_gives_pair (N g : ℕ) (hN : 1 < N)
    (hg_dvd : g ∣ N) (hg1 : 1 < g) (hgN : g < N) :
    ∃ d e : ℕ, d * e = N ^ 2 ∧ 1 < d ∧ d < N ∧ d < e := by
  obtain ⟨k, rfl⟩ := hg_dvd
  exact ⟨g, g * k ^ 2, by ring, hg1, by nlinarith, by nlinarith⟩


/-- Fermat identity. -/
theorem fermat_two_square_triple (a b : ℤ) :
    (a ^ 2 - b ^ 2) ^ 2 + (2 * a * b) ^ 2 = (a ^ 2 + b ^ 2) ^ 2 := by ring


/-- Four divisor pairs of (pq)². -/
theorem four_pairs_semiprimes (p q : ℕ) :
    1 * (p * q) ^ 2 = (p * q) ^ 2 ∧
    p * (p * q ^ 2) = (p * q) ^ 2 ∧
    q * (q * p ^ 2) = (p * q) ^ 2 ∧
    p ^ 2 * q ^ 2 = (p * q) ^ 2 := by
  exact ⟨by ring, by ring, by ring, by ring⟩


/-- Odd leg = difference of squares. -/
theorem optimal_start_params (m n : ℤ) :
    m ^ 2 - n ^ 2 = (m - n) * (m + n) := by ring


