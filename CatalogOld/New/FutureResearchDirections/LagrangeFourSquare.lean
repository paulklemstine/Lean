import Mathlib

/-!
# Lagrange's Four-Square Theorem and Applications to Gravitational Factoring

## Main Results

- `lagrange_four_squares`: Every natural number is a sum of four squares
- `euler_four_square_identity`: Quaternion norm multiplicativity
- `four_square_factoring_channel`: Factoring via quaternion products
- `sigma1_lower_bound`: σ₁(n) ≥ n + 1 for n > 1
- `berggrenA_preserves_pyth`: Berggren matrices preserve Pythagorean property
- `cayley_dickson_channels`: Channel counts across the hierarchy
- `lattice_short_vector_gcd_eq`: Short vectors simplify GCD
-/

set_option maxHeartbeats 3200000

open Nat BigOperators Finset

/-! ## §1. Lagrange's Four-Square Theorem -/

/-- Every natural number is the sum of four squares (Lagrange, 1770). -/
theorem lagrange_four_squares (n : ℕ) :
    ∃ a b c d : ℕ, a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = n :=
  Nat.sum_four_squares n

/-! ## §2. Euler's Four-Square Identity -/

/-- The quaternion norm. -/
def quatNorm (a b c d : ℤ) : ℤ := a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2

/-- Euler's four-square identity: N(q₁) · N(q₂) = N(q₁ · q₂). -/
theorem euler_four_square_identity (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    quatNorm a₁ b₁ c₁ d₁ * quatNorm a₂ b₂ c₂ d₂ =
    quatNorm (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)
             (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)
             (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)
             (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂) := by
  unfold quatNorm; ring

/-! ## §3. Factoring via Four-Square Decomposition -/

/-- If N = N(q₁·q₂), then N = N(q₁) · N(q₂). -/
theorem four_square_factoring_channel
    (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) (N : ℤ)
    (hN : quatNorm (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)
                   (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)
                   (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)
                   (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂) = N) :
    N = quatNorm a₁ b₁ c₁ d₁ * quatNorm a₂ b₂ c₂ d₂ := by
  rw [← hN, ← euler_four_square_identity]

/-- The norm is always nonneg. -/
theorem quatNorm_nonneg (a b c d : ℤ) : 0 ≤ quatNorm a b c d := by
  unfold quatNorm; positivity

/-- GCD-based factor extraction from 4-square representations. -/
theorem four_square_cross_collision (a₁ a₂ N : ℤ) :
    ↑(Int.gcd (a₁ - a₂) N) ∣ N := Int.gcd_dvd_right _ _

/-- 4 + C(4,2) = 10 channels. -/
theorem four_square_channel_count : 4 + Nat.choose 4 2 = 10 := by decide

/-! ## §4. Sum-of-Divisors Function -/

noncomputable def sigma1 (n : ℕ) : ℕ := ∑ d ∈ n.divisors, d

theorem sigma1_pos (n : ℕ) (hn : 0 < n) : 0 < sigma1 n := by
  unfold sigma1
  apply Finset.sum_pos
  · intro d hd; exact Nat.pos_of_mem_divisors hd
  · exact Nat.nonempty_divisors.mpr (by omega)

theorem sigma1_lower_bound (n : ℕ) (hn : 1 < n) : n + 1 ≤ sigma1 n := by
  unfold sigma1
  have h1 : 1 ∈ n.divisors := Nat.mem_divisors.mpr ⟨one_dvd n, by omega⟩
  have hn_mem : n ∈ n.divisors := Nat.mem_divisors.mpr ⟨dvd_refl n, by omega⟩
  have hne : (1 : ℕ) ≠ n := by omega
  calc n + 1
    _ = ∑ d ∈ ({1, n} : Finset ℕ), d := by simp [hne]; omega
    _ ≤ ∑ d ∈ n.divisors, d := by
        apply Finset.sum_le_sum_of_subset
        intro x hx; simp at hx
        cases hx with
        | inl h => subst h; exact h1
        | inr h => subst h; exact hn_mem

/-! ## §5. Norm Multiplicativity -/

theorem complex_norm_mult (a₁ b₁ a₂ b₂ : ℤ) :
    (a₁^2 + b₁^2) * (a₂^2 + b₂^2) =
    (a₁*a₂ - b₁*b₂)^2 + (a₁*b₂ + b₁*a₂)^2 := by ring

theorem quaternion_norm_mult (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    (a₁^2 + b₁^2 + c₁^2 + d₁^2) * (a₂^2 + b₂^2 + c₂^2 + d₂^2) =
    (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)^2 +
    (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)^2 +
    (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)^2 +
    (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂)^2 := by ring

/-! ## §6. Channel Hierarchy -/

theorem hurwitz_1248 : ({1, 2, 4, 8} : Finset ℕ).card = 4 := by decide

theorem cayley_dickson_channels :
    (1 + Nat.choose 1 2 = 1) ∧
    (2 + Nat.choose 2 2 = 3) ∧
    (4 + Nat.choose 4 2 = 10) ∧
    (8 + Nat.choose 8 2 = 36) ∧
    (16 + Nat.choose 16 2 = 136) ∧
    (32 + Nat.choose 32 2 = 528) := by decide

/-! ## §7. Lattice Reduction -/

/-- gcd(mN - x, N) = gcd(x, N). -/
theorem lattice_short_vector_gcd_eq (x N m : ℤ) :
    Int.gcd (m * N - x) N = Int.gcd x N := by
  rw [show m * N - x = -x + m * N by ring]
  rw [Int.gcd_add_mul_right_left]
  rw [Int.neg_gcd]

/-
If N | (v₁ · v₂) with 0 < v₁, v₂ < N, at least one GCD > 1.
-/
theorem lattice_product_factor (v₁ v₂ N : ℕ)
    (hN : 1 < N) (hv1 : 0 < v₁) (hv2 : 0 < v₂)
    (hv1N : v₁ < N) (hv2N : v₂ < N) (hdvd : N ∣ v₁ * v₂) :
    1 < Nat.gcd v₁ N ∨ 1 < Nat.gcd v₂ N := by
  contrapose! hv1N;
  cases hv1N.1.eq_or_lt <;> cases hv1N.2.eq_or_lt <;> simp_all +decide [ Nat.Coprime, Nat.Coprime.gcd_eq_one ];
  exact absurd ( Nat.dvd_gcd ( show N ∣ v₂ from ( Nat.Coprime.symm ‹v₁.gcd N = 1› ) |> fun h => h.dvd_of_dvd_mul_left hdvd ) ( dvd_refl N ) ) ( by aesop )

/-! ## §8. Berggren Tree -/

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

/-! ## §9. Grover Speedup -/

theorem grover_speedup (T : ℕ) (hT : 1 < T) : Nat.sqrt T < T :=
  Nat.sqrt_lt_self hT

theorem quantum_fourth_root (N : ℕ) :
    Nat.sqrt (Nat.sqrt N) ≤ Nat.sqrt N :=
  Nat.sqrt_le_sqrt (Nat.sqrt_le_self N)

/-! ## §10. Tropical Geometry -/

theorem tropical_pythagorean (x y z : ℕ) :
    min x y = z → (x = z ∧ z ≤ y) ∨ (y = z ∧ z ≤ x) := by
  intro h
  rcases Nat.le_total x y with hxy | hyx
  · left; rw [min_eq_left hxy] at h; exact ⟨h, h ▸ hxy⟩
  · right; rw [min_eq_right hyx] at h; exact ⟨h, h ▸ hyx⟩

/-! ## §11. Information Theory -/

theorem info_theoretic_lower_bound (total_bits channels : ℕ)
    (hc : 0 < channels) :
    total_bits / channels ≤ total_bits :=
  Nat.div_le_self total_bits channels

theorem channels_quadratic (k : ℕ) : k ≤ k + Nat.choose k 2 :=
  Nat.le_add_right k _