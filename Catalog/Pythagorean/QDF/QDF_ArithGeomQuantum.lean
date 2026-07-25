import Mathlib

/-! # CatalogBuild.Pythagorean.QDF.QDF_ArithGeomQuantum

Auto-generated from theorem catalog database.
Domain: Pythagorean/QDF
Declarations: 38
-/

/-- The fundamental radical decomposition for all three axes. -/
theorem radical_decomposition_full (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (d - c) * (d + c) = a ^ 2 + b ^ 2 ∧
    (d - b) * (d + b) = a ^ 2 + c ^ 2 ∧
    (d - a) * (d + a) = b ^ 2 + c ^ 2 := by
  constructor <;> [nlinarith; constructor <;> nlinarith]

/-- abc connection: (d-c) + (d+c) = 2d. -/
theorem abc_triple_sum (c d : ℤ) : (d - c) + (d + c) = 2 * d := by ring

/-- When d - c is a perfect square, the factoring identity simplifies. -/
theorem perfect_square_dc (a b c d s : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (hs : d - c = s ^ 2) :
    s ^ 2 * (d + c) = a ^ 2 + b ^ 2 := by
  have hdc : (d - c) * (d + c) = d ^ 2 - c ^ 2 := by ring
  have hab : d ^ 2 - c ^ 2 = a ^ 2 + b ^ 2 := by linarith
  rw [hs] at hdc
  linarith

/-- When d+c is also a perfect square, a²+b² is a perfect square. -/
theorem double_perfect_square (a b c d s t : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (hs : d - c = s ^ 2) (ht : d + c = t ^ 2) :
    a ^ 2 + b ^ 2 = (s * t) ^ 2 := by
  have h1 : (d - c) * (d + c) = a ^ 2 + b ^ 2 := by nlinarith
  rw [hs, ht] at h1
  linarith [show (s * t) ^ 2 = s ^ 2 * t ^ 2 from by ring]

/-- Thin quadruple: if d - c = 1, then a² + b² = 2d - 1. -/
theorem thin_quadruple_sum (a b d : ℤ)
    (h : a ^ 2 + b ^ 2 + (d - 1) ^ 2 = d ^ 2) :
    a ^ 2 + b ^ 2 = 2 * d - 1 := by nlinarith

/-- The "fat" quadruple case: c = 0 reduces to a Pythagorean triple. -/
theorem fat_quadruple (a b d : ℤ)
    (h : a ^ 2 + b ^ 2 + 0 ^ 2 = d ^ 2) :
    a ^ 2 + b ^ 2 = d ^ 2 := by linarith

/-- QDF + Brahmagupta: decompose a²+b² when d±c are sums of two squares. -/
theorem qdf_brahmagupta (a b c d p q r s : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (hp : d - c = p ^ 2 + q ^ 2) (hr : d + c = r ^ 2 + s ^ 2) :
    a ^ 2 + b ^ 2 = (p * r - q * s) ^ 2 + (p * s + q * r) ^ 2 := by
  have h1 : (d - c) * (d + c) = a ^ 2 + b ^ 2 := by nlinarith
  rw [hp, hr] at h1
  linarith [brahmagupta_fibonacci p q r s]

/-- QDF + Euler: product of two quadruple hypotenuses is a sum of 4 squares. -/
theorem qdf_euler_composition (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h1 : a₁^2 + b₁^2 + c₁^2 = d₁^2)
    (h2 : a₂^2 + b₂^2 + c₂^2 = d₂^2) :
    ∃ x y z w : ℤ, d₁^2 * d₂^2 = x^2 + y^2 + z^2 + w^2 := by
  refine ⟨a₁*a₂ - b₁*b₂ - c₁*c₂,
          a₁*b₂ + b₁*a₂,
          a₁*c₂ + c₁*a₂,
          b₁*c₂ - c₁*b₂, ?_⟩
  nlinarith [sq_nonneg (a₁*a₂ - b₁*b₂ - c₁*c₂),
             sq_nonneg (a₁*b₂ + b₁*a₂),
             sq_nonneg (a₁*c₂ + c₁*a₂),
             sq_nonneg (b₁*c₂ - c₁*b₂)]

/-- Component bound: a² ≤ d². -/
theorem component_bound (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    a ^ 2 ≤ d ^ 2 := by nlinarith [sq_nonneg b, sq_nonneg c]

/-- Pair bound: a² + b² ≤ d². -/
theorem component_bound_tight (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    a ^ 2 + b ^ 2 ≤ d ^ 2 := by nlinarith [sq_nonneg c]

/-- Nonneg component bound: 0 ≤ c ≤ d. -/
theorem nonneg_component_bound (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (hc : c ≥ 0) (hd : d ≥ 0) :
    c ≤ d := by nlinarith [sq_nonneg a, sq_nonneg b]

/-- Each component lies in [-d, d]. -/
theorem component_range (d : ℕ) (hd : d > 0)
    (a b c : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = (d : ℤ) ^ 2) :
    -↑d ≤ a ∧ a ≤ ↑d := by
  constructor <;> nlinarith [sq_nonneg (a + d), sq_nonneg (a - d), sq_nonneg b, sq_nonneg c]

/-- If d is even, then a² + b² + c² ≡ 0 mod 4. -/
theorem mod4_even_d (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) (hd : 2 ∣ d) :
    4 ∣ (a ^ 2 + b ^ 2 + c ^ 2) := by
  obtain ⟨k, rfl⟩ := hd; rw [h]; exact ⟨k ^ 2, by ring⟩

/-- gcd(a, d-c) · gcd(a, d+c) divides a². -/
theorem coprime_gcd_bound (a c d : ℤ) :
    (Int.gcd a (d - c) : ℤ) * (Int.gcd a (d + c) : ℤ) ∣ a ^ 2 := by
  calc (Int.gcd a (d - c) : ℤ) * (Int.gcd a (d + c) : ℤ)
      ∣ a * a := mul_dvd_mul (Int.gcd_dvd_left a (d - c)) (Int.gcd_dvd_left a (d + c))
    _ = a ^ 2 := by ring

/-- Shared-hypotenuse difference identity. -/
theorem shared_hyp_gcd (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2) :
    c₁ ^ 2 - c₂ ^ 2 = (a₂ ^ 2 + b₂ ^ 2) - (a₁ ^ 2 + b₁ ^ 2) := by linarith

/-- Cauchy–Schwarz for quadruple inner products (over ℤ). -/
theorem sphere_inner_product_int (a₁ b₁ c₁ a₂ b₂ c₂ d₁ d₂ : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2) :
    (a₁ * a₂ + b₁ * b₂ + c₁ * c₂) ^ 2 ≤ d₁ ^ 2 * d₂ ^ 2 := by
  nlinarith [sq_nonneg (a₁ * b₂ - b₁ * a₂),
             sq_nonneg (a₁ * c₂ - c₁ * a₂),
             sq_nonneg (b₁ * c₂ - c₁ * b₂)]

/-- Orthogonality condition. -/
theorem orthogonal_quadruples (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (horth : a₁ * a₂ + b₁ * b₂ + c₁ * c₂ = 0) :
    (a₁ * a₂ + b₁ * b₂ + c₁ * c₂) ^ 2 = 0 := by rw [horth]; ring

/-- Berggren M₁ preserves the Pythagorean property. -/
theorem berggren_sphere_action (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2 * b + 2 * c) ^ 2 + (2 * a - b + 2 * c) ^ 2 = (2 * a - 2 * b + 3 * c) ^ 2 := by
  nlinarith

/-- Composition of two M₁ transforms. -/
theorem berggren_M1_composed (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let a₁ := a - 2 * b + 2 * c
    let b₁ := 2 * a - b + 2 * c
    let c₁ := 2 * a - 2 * b + 3 * c
    (a₁ - 2 * b₁ + 2 * c₁) ^ 2 + (2 * a₁ - b₁ + 2 * c₁) ^ 2 =
    (2 * a₁ - 2 * b₁ + 3 * c₁) ^ 2 := by
  simp only
  nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c,
    sq_nonneg (a - b), sq_nonneg (a + b), sq_nonneg (a - c), sq_nonneg (b - c)]

/-- A descent chain of length 2. -/
theorem descent_chain_2 (d g₁ g₂ : ℕ)
    (hd : d > 0) (hg₁ : g₁ > 1) (hg₂ : g₂ > 1)
    (h₁ : g₁ ∣ d) (_ : g₂ ∣ d / g₁) :
    d / g₁ / g₂ < d := by
  have step1 := Nat.div_lt_self hd hg₁
  have pos1 := Nat.div_pos (Nat.le_of_dvd hd h₁) (by omega)
  exact lt_trans (Nat.div_lt_self pos1 hg₂) step1

/-- Triple embedding: any Pythagorean triple lifts to quadruples. -/
theorem triple_quadruple_embed (a b c k d : ℤ)
    (h_triple : a ^ 2 + b ^ 2 = c ^ 2)
    (h_lift : c ^ 2 + k ^ 2 = d ^ 2) :
    a ^ 2 + b ^ 2 + k ^ 2 = d ^ 2 := by linarith

/-- Any quadruple projects to a triple. -/
theorem quadruple_triple_project (a b c d e : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (he : a ^ 2 + b ^ 2 = e ^ 2) :
    e ^ 2 + c ^ 2 = d ^ 2 := by linarith

/-- Mixed product identity: scaling one quadruple by a component of another. -/
theorem mixed_product_identity (a₁ a₂ b₂ c₂ d₂ : ℤ)
    (h2 : a₂^2 + b₂^2 + c₂^2 = d₂^2) :
    (a₁ * a₂)^2 + (a₁ * b₂)^2 + (a₁ * c₂)^2 = (a₁ * d₂)^2 := by nlinarith [sq_nonneg a₁]

/-- If p | d and p | c, then p² | a² + b². -/
theorem mod_p_cascade (a b c d p : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (hpd : p ∣ d) (hpc : p ∣ c) :
    p ^ 2 ∣ (a ^ 2 + b ^ 2) := by
  obtain ⟨kd, rfl⟩ := hpd
  obtain ⟨kc, rfl⟩ := hpc
  exact ⟨kd ^ 2 - kc ^ 2, by linarith⟩

/-- If p | d, p | c, and p | a, then p² | b². -/
theorem mod_p_triple_cascade (a b c d p : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (hpd : p ∣ d) (hpc : p ∣ c) (hpa : p ∣ a) :
    p ^ 2 ∣ b ^ 2 := by
  obtain ⟨kd, rfl⟩ := hpd
  obtain ⟨kc, rfl⟩ := hpc
  obtain ⟨ka, rfl⟩ := hpa
  exact ⟨kd ^ 2 - kc ^ 2 - ka ^ 2, by linarith⟩

/-- Energy gap: same-hypotenuse quadruples have zero-sum component differences. -/
theorem energy_gap (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2) :
    (a₁ - a₂) * (a₁ + a₂) + (b₁ - b₂) * (b₁ + b₂) + (c₁ - c₂) * (c₁ + c₂) = 0 := by
  nlinarith

/-- Base: 1² + 2² + 2² = 3². -/
theorem family_base_1_2_2 : (1 : ℤ) ^ 2 + 2 ^ 2 + 2 ^ 2 = 3 ^ 2 := by norm_num

/-- Base: 2² + 3² + 6² = 7². -/
theorem family_base_2_3_6 : (2 : ℤ) ^ 2 + 3 ^ 2 + 6 ^ 2 = 7 ^ 2 := by norm_num

/-- Example: (3, 4, 12, 13). -/
theorem quadratic_family_3_4_12 : (3 : ℤ) ^ 2 + 4 ^ 2 + 12 ^ 2 = 13 ^ 2 := by norm_num

/-- Even-odd family: (2n)² + (2n+1)² + (2n(2n+1))² = (4n²+2n+1)². -/
theorem even_odd_family (n : ℤ) :
    (2*n)^2 + (2*n+1)^2 + (2*n*(2*n+1))^2 = (4*n^2 + 2*n + 1)^2 := by ring

/-- The lift creates a new factoring channel. -/
theorem new_channel (a b k d : ℤ)
    (h_lift : a ^ 2 + b ^ 2 + k ^ 2 = d ^ 2) :
    (d - b) * (d + b) = a ^ 2 + k ^ 2 := by nlinarith

/-- Divisibility cascade: if g | d, then g² | d². -/
theorem divisibility_cascade (d g : ℤ) (hgd : g ∣ d) :
    g ^ 2 ∣ d ^ 2 := by obtain ⟨k, rfl⟩ := hgd; exact ⟨k ^ 2, by ring⟩

/-- Double bridge: lifting twice creates two connections. -/
theorem double_bridge (a b c k₁ d₁ k₂ d₂ : ℤ)
    (h1 : a ^ 2 + b ^ 2 = c ^ 2)
    (h2 : c ^ 2 + k₁ ^ 2 = d₁ ^ 2)
    (h3 : d₁ ^ 2 + k₂ ^ 2 = d₂ ^ 2) :
    c ^ 2 + k₁ ^ 2 + k₂ ^ 2 = d₂ ^ 2 ∧
    a ^ 2 + b ^ 2 + k₁ ^ 2 + k₂ ^ 2 = d₂ ^ 2 := by
  constructor <;> linarith

/-- Bridge triangle inequality. -/
theorem bridge_triangle (c k d : ℤ)
    (h : c ^ 2 + k ^ 2 = d ^ 2) (hd : d ≥ 0) (hc : c ≥ 0) :
    d ≥ c := by nlinarith [sq_nonneg k]

/-- Hypotenuse growth in the quadratic family. -/
theorem family_hypotenuse_growth (n : ℕ) :
    (n : ℤ) ^ 2 + n + 1 ≥ n + 1 := by nlinarith [sq_nonneg (n : ℤ)]

/-- Every integer appears as a component in some quadruple. -/
theorem universal_component (n : ℤ) :
    ∃ b c d : ℤ, n ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 :=
  ⟨2 * n, 2 * n, 3 * n, by ring⟩

/-- Cross-quadruple product identity. -/
theorem cross_quadruple_product (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2) :
    (d₁ * d₂) ^ 2 = (a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2) * (a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2) := by
  nlinarith

/-- Sextuple gives 5 independent factorizations. -/
theorem sextuple_five_factorizations (a b c d e f : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 + e ^ 2 = f ^ 2) :
    (f - e) * (f + e) = a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 ∧
    (f - d) * (f + d) = a ^ 2 + b ^ 2 + c ^ 2 + e ^ 2 ∧
    (f - c) * (f + c) = a ^ 2 + b ^ 2 + d ^ 2 + e ^ 2 ∧
    (f - b) * (f + b) = a ^ 2 + c ^ 2 + d ^ 2 + e ^ 2 ∧
    (f - a) * (f + a) = b ^ 2 + c ^ 2 + d ^ 2 + e ^ 2 := by
  refine ⟨by nlinarith, by nlinarith, by nlinarith, by nlinarith, by nlinarith⟩

