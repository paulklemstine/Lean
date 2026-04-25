/-! # CatalogBuild.Speculative.LagrangeFourSquare

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 19
-/

import Mathlib

/-- If N = N(q₁·q₂), then N = N(q₁) · N(q₂). -/
theorem four_square_factoring_channel
    (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) (N : ℤ)
    (hN : quatNorm (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)
                   (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)
                   (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)
                   (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂) = N) :
    N = quatNorm a₁ b₁ c₁ d₁ * quatNorm a₂ b₂ c₂ d₂ := by
  rw [← hN, ← euler_four_square_identity]


/-- GCD-based factor extraction from 4-square representations. -/
theorem four_square_cross_collision (a₁ a₂ N : ℤ) :
    ↑(Int.gcd (a₁ - a₂) N) ∣ N := Int.gcd_dvd_right _ _


/-- 4 + C(4,2) = 10 channels. -/
theorem four_square_channel_count : 4 + Nat.choose 4 2 = 10 := by decide


/-- [Section: # CatalogBuild.Speculative.LagrangeFourSquare
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 19] -/
theorem sigma1_pos (n : ℕ) (hn : 0 < n) : 0 < sigma1 n := by
  unfold sigma1
  apply Finset.sum_pos
  · intro d hd; exact Nat.pos_of_mem_divisors hd
  · exact Nat.nonempty_divisors.mpr (by omega)


/-- [Section: # CatalogBuild.Speculative.LagrangeFourSquare
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 19] -/
theorem complex_norm_mult (a₁ b₁ a₂ b₂ : ℤ) :
    (a₁^2 + b₁^2) * (a₂^2 + b₂^2) =
    (a₁*a₂ - b₁*b₂)^2 + (a₁*b₂ + b₁*a₂)^2 := by ring


/-- [Section: # CatalogBuild.Speculative.LagrangeFourSquare
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 19] -/
theorem quaternion_norm_mult (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    (a₁^2 + b₁^2 + c₁^2 + d₁^2) * (a₂^2 + b₂^2 + c₂^2 + d₂^2) =
    (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)^2 +
    (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)^2 +
    (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)^2 +
    (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂)^2 := by ring


theorem hurwitz_1248 : ({1, 2, 4, 8} : Finset ℕ).card = 4 := by decide


theorem cayley_dickson_channels :
    (1 + Nat.choose 1 2 = 1) ∧
    (2 + Nat.choose 2 2 = 3) ∧
    (4 + Nat.choose 4 2 = 10) ∧
    (8 + Nat.choose 8 2 = 36) ∧
    (16 + Nat.choose 16 2 = 136) ∧
    (32 + Nat.choose 32 2 = 528) := by decide


/-- gcd(mN - x, N) = gcd(x, N). -/
theorem lattice_short_vector_gcd_eq (x N m : ℤ) :
    Int.gcd (m * N - x) N = Int.gcd x N := by
  rw [show m * N - x = -x + m * N by ring]
  rw [Int.gcd_add_mul_right_left]
  rw [Int.neg_gcd]


theorem lattice_product_factor (v₁ v₂ N : ℕ)
    (hN : 1 < N) (hv1 : 0 < v₁) (hv2 : 0 < v₂)
    (hv1N : v₁ < N) (hv2N : v₂ < N) (hdvd : N ∣ v₁ * v₂) :
    1 < Nat.gcd v₁ N ∨ 1 < Nat.gcd v₂ N := by
  contrapose! hv1N;
  cases hv1N.1.eq_or_lt <;> cases hv1N.2.eq_or_lt <;> simp_all +decide [ Nat.Coprime, Nat.Coprime.gcd_eq_one ];
  exact absurd ( Nat.dvd_gcd ( show N ∣ v₂ from ( Nat.Coprime.symm ‹v₁.gcd N = 1› ) |> fun h => h.dvd_of_dvd_mul_left hdvd ) ( dvd_refl N ) ) ( by aesop )


def berggrenA (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)


def berggrenB (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)


def berggrenC (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


theorem berggrenA_preserves_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    let (a', b', c') := berggrenA a b c
    a'^2 + b'^2 = c'^2 := by
  simp [berggrenA]; nlinarith


theorem berggrenB_preserves_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    let (a', b', c') := berggrenB a b c
    a'^2 + b'^2 = c'^2 := by
  simp [berggrenB]; nlinarith


theorem berggrenC_preserves_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    let (a', b', c') := berggrenC a b c
    a'^2 + b'^2 = c'^2 := by
  simp [berggrenC]; nlinarith


theorem quantum_fourth_root (N : ℕ) :
    Nat.sqrt (Nat.sqrt N) ≤ Nat.sqrt N :=
  Nat.sqrt_le_sqrt (Nat.sqrt_le_self N)


theorem info_theoretic_lower_bound (total_bits channels : ℕ)
    (hc : 0 < channels) :
    total_bits / channels ≤ total_bits :=
  Nat.div_le_self total_bits channels


theorem channels_quadratic (k : ℕ) : k ≤ k + Nat.choose k 2 :=
  Nat.le_add_right k _


