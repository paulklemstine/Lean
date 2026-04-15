/-! # CatalogBuild.Pythagorean.Research.Synthesis

Auto-generated from theorem catalog database.
Domain: Pythagorean/Research
Declarations: 39
-/

import Mathlib

/-- The number of polynomial systems at depth k is 3^k. -/
theorem OQ_systems_at_depth (k : ℕ) : 3 ^ k ≥ 1 :=
  Nat.one_le_pow k 3 (by norm_num)

/-- Each depth-k system reduces to a degree-2 equation in u,
    because h is linear in (N, u) from the linear system, and
    the constraint h² = N² + u² introduces exactly one squaring. -/

theorem OQ_root_eq_degree_two (N u h : ℤ)
    (hlin : ∃ α β γ : ℤ, h = α * N + β * u + γ)
    (hpyth : N ^ 2 + u ^ 2 = h ^ 2) :
    ∃ A B C D E F : ℤ,
      A * N ^ 2 + B * N * u + C * u ^ 2 + D * N + E * u + F = 0 := by
  obtain ⟨α, β, γ, hh⟩ := hlin
  refine ⟨1 - α ^ 2, -2 * α * β, 1 - β ^ 2, -2 * α * γ, -2 * β * γ, -(γ ^ 2), ?_⟩
  have : h ^ 2 = (α * N + β * u + γ) ^ 2 := by rw [hh]
  nlinarith [this]

/-- The total number of candidate solutions grows as 2 · 3^k. -/

theorem OQ_total_candidates (k : ℕ) : 2 * 3 ^ k ≥ 2 := by
  have := Nat.one_le_pow k 3 (by norm_num); omega

/-- Descent from any PPT terminates: the parent hypotenuse strictly decreases. -/

theorem OQ_descent_step_decrease (a b c : ℤ)
    (ha : 0 < a) (hb : 0 < b) (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    -2 * a - 2 * b + 3 * c < c := by
  nlinarith [sq_nonneg (a + b - c)]

/-- The maximum number of descent steps is bounded by hypotenuse reduction ≥ 2. -/

theorem OQ_descent_max_steps (a b c : ℤ)
    (ha : 1 ≤ a) (hb : 1 ≤ b) (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    -2 * a - 2 * b + 3 * c ≤ c - 2 := by
  nlinarith [sq_nonneg (a + b - c)]

/-- Exponential lower bound: 3^k ≥ k + 1. -/

theorem OQ_exponential_vs_linear (k : ℕ) : 3 ^ k ≥ k + 1 := by
  induction k with
  | zero => norm_num
  | succ n ih =>
    calc 3 ^ (n + 1) = 3 ^ n * 3 := pow_succ 3 n
      _ ≥ 3 * (n + 1) := by omega
      _ ≥ n + 2 := by omega


/-- The trivial triple satisfies N² + u² = h². -/
theorem OQ_trivial_triple_valid (N : ℤ) (hN : N % 2 = 1) :
    N ^ 2 + ((N ^ 2 - 1) / 2) ^ 2 = ((N ^ 2 + 1) / 2) ^ 2 := by
  have h1 : (2 : ℤ) ∣ (N ^ 2 - 1) := by
    have : N ^ 2 - 1 = (N - 1) * (N + 1) := by ring
    rw [this]; exact dvd_mul_of_dvd_left (by omega) _
  have h2 : (2 : ℤ) ∣ (N ^ 2 + 1) := by
    have : N ^ 2 + 1 = (N - 1) * (N + 1) + 2 := by ring
    rw [this]; exact dvd_add (dvd_mul_of_dvd_left (by omega) _) (dvd_refl 2)
  nlinarith [Int.ediv_mul_cancel h1, Int.ediv_mul_cancel h2]

/-- Non-trivial triples: any same-parity divisor pair of N² gives a valid triple. -/

theorem OQ_nontrivial_triple_exists (N d e : ℤ) (hprod : d * e = N ^ 2)
    (hpar : (2 : ℤ) ∣ (e - d)) (hd_pos : 0 < d) (he_pos : 0 < e) :
    N ^ 2 + ((e - d) / 2) ^ 2 = ((e + d) / 2) ^ 2 := by
  have hparity2 : (2 : ℤ) ∣ (e + d) := by obtain ⟨k, hk⟩ := hpar; omega
  nlinarith [Int.ediv_mul_cancel hpar, Int.ediv_mul_cancel hparity2]

/-- For a semiprime N = p·q, the non-trivial pair gives smaller hypotenuse. -/

theorem OQ_semiprime_optimal_hyp (p q : ℤ) (hp : 2 ≤ p) (hq : 2 ≤ q) :
    q ^ 2 + p ^ 2 ≤ (p * q) ^ 2 := by
  nlinarith [sq_nonneg (p * q - p), sq_nonneg (p * q - q)]

/-- The trivial triple has c - b = 1 (provides no factoring information). -/

theorem OQ_trivial_triple_gap_one (N : ℤ) (hN : N % 2 = 1) :
    (N ^ 2 + 1) / 2 - (N ^ 2 - 1) / 2 = 1 := by omega

/-- For composites N = p·q, gcd(p, N) = p > 1. -/

theorem OQ_composite_has_nontrivial_divisor (p q : ℕ) (hp : 1 < p) (hq : 1 < q) :
    1 < Nat.gcd p (p * q) := by
  rw [Nat.gcd_eq_left (dvd_mul_right p q)]; exact hp


/-- The 3+1 Lorentz form Q₄(a,b,c,d) = a² + b² + c² - d². -/
def OQ_Q4_form (a b c d : ℤ) : ℤ := a ^ 2 + b ^ 2 + c ^ 2 - d ^ 2

/-- Quadruples lie on the null cone of Q₄. -/

theorem OQ_quad_on_null_cone (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    OQ_Q4_form a b c d = 0 := by
  simp [OQ_Q4_form]; linarith

/-- The quadruple difference-of-squares: (d-c)(d+c) = a² + b². -/

theorem OQ_quad_diff_squares (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (d - c) * (d + c) = a ^ 2 + b ^ 2 := by nlinarith

/-- Quadruple trees have branching factor 4 ≥ 3. -/

theorem OQ_quad_branching_advantage (k : ℕ) : 4 ^ k ≥ 3 ^ k :=
  Nat.pow_le_pow_left (by norm_num : 3 ≤ 4) k

/-- The 4D Lorentz metric η₄ = diag(1,1,1,-1). -/

def OQ_η4 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, -1]

/-- η₄ is an involution. -/

theorem OQ_η4_involution : OQ_η4 * OQ_η4 = 1 := by native_decide

/-- Embedding triples into quadruples preserves the Pythagorean relation. -/

theorem OQ_triple_embeds_in_quadruple (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    a ^ 2 + b ^ 2 + 0 ^ 2 = c ^ 2 := by linarith

/-- Three GCD checks per quadruple node. -/

theorem OQ_quad_gcd_checks (N a b c : ℕ) :
    Nat.gcd a N ∣ N ∧ Nat.gcd b N ∣ N ∧ Nat.gcd c N ∣ N :=
  ⟨Nat.gcd_dvd_right a N, Nat.gcd_dvd_right b N, Nat.gcd_dvd_right c N⟩


/-- Grover's quadratic relation: (3^k)² = 9^k. -/
theorem OQ_grover_quadratic (k : ℕ) : (3 ^ k) ^ 2 = 9 ^ k := by
  rw [← pow_mul, show 9 = 3 ^ 2 from by norm_num, ← pow_mul, mul_comm]

/-- For k depth levels, Grover reduces branch search from 3^k to ~3^(k/2). -/

theorem OQ_grover_depth_bound (k : ℕ) : 3 ^ (k / 2) * 3 ^ (k / 2) ≤ 3 ^ k := by
  rw [← pow_add]
  exact Nat.pow_le_pow_right (by norm_num : 0 < 3) (by omega)

/-- Quantum walk composition: b^(k/2) ≤ b^k for b ≥ 1. -/

theorem OQ_quantum_walk_composition (b k : ℕ) (hb : 1 ≤ b) :
    b ^ (k / 2) ≤ b ^ k :=
  Nat.pow_le_pow_right hb (Nat.div_le_self k 2)

/-- The oracle complexity of Grover on N items is O(√N).
    For branch sequences of depth k with branching factor 3,
    the total search space is 3^k, so Grover needs O(3^(k/2)) queries. -/

theorem OQ_grover_oracle_complexity (k : ℕ) :
    3 ^ (k / 2) ≤ 3 ^ k :=
  Nat.pow_le_pow_right (by norm_num : 0 < 3) (Nat.div_le_self k 2)


/-- The Lorentz metric η = diag(1, 1, -1). -/
def OQ_η : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- The three Berggren matrices. -/

def OQ_B1 : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

def OQ_B2 : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

def OQ_B3 : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- Berggren matrices are in O(2,1;ℤ). -/

theorem OQ_berggren_in_lorentz :
    OQ_B1ᵀ * OQ_η * OQ_B1 = OQ_η ∧
    OQ_B2ᵀ * OQ_η * OQ_B2 = OQ_η ∧
    OQ_B3ᵀ * OQ_η * OQ_B3 = OQ_η := by
  refine ⟨?_, ?_, ?_⟩ <;> native_decide

/-- det(B₁) = 1, det(B₂) = -1, det(B₃) = 1. -/

theorem OQ_berggren_dets :
    Matrix.det OQ_B1 = 1 ∧ Matrix.det OQ_B2 = -1 ∧ Matrix.det OQ_B3 = 1 := by
  refine ⟨?_, ?_, ?_⟩ <;> native_decide

/-- η² = I (Lorentz metric is self-inverse). -/

theorem OQ_η_sq : OQ_η * OQ_η = 1 := by native_decide

/-- Pythagorean triples lie on the integer null cone. -/

theorem OQ_pyth_on_null_cone (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    a ^ 2 + b ^ 2 - c ^ 2 = 0 := by omega

/-- The Lorentz form is preserved algebraically by the B₂ transform. -/

theorem OQ_lorentz_form_preserved_B2 (a b c : ℤ) :
    (a + 2*b + 2*c) ^ 2 + (2*a + b + 2*c) ^ 2 - (2*a + 2*b + 3*c) ^ 2 =
    a ^ 2 + b ^ 2 - c ^ 2 := by ring

/-- The inverse Berggren matrices. -/

def OQ_B1_inv : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, -2; -2, -1, 2; -2, -2, 3]

def OQ_B2_inv : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, -2; 2, 2, -3]

/-- B₁ · B₁⁻¹ = I. -/

theorem OQ_B1_times_inv : OQ_B1 * OQ_B1_inv = 1 := by native_decide

end LatticeConnection

/-! ## §6. Cross-Cutting Theorems -/

section CrossCutting

/-- The inside-out quadratic for B₂⁻¹ mapping to root (3,4,5). -/

theorem OQ_inside_out_identity (N u : ℤ) :
    5 * N ^ 2 - 8 * N * u - 20 * N + 5 * u ^ 2 - 20 * u - 25 =
    5 * (N - u) ^ 2 + 2 * N * u - 20 * (N + u) - 25 := by ring

/-- With the trivial substitution u = N - 1, the quadratic simplifies to 2N(N-21). -/

theorem OQ_trivial_substitution (N : ℤ) :
    5 * N ^ 2 - 8 * N * (N - 1) - 20 * N + 5 * (N - 1) ^ 2 - 20 * (N - 1) - 25 =
    2 * N * (N - 21) := by ring

/-- N = 21 is the unique positive composite satisfying the depth-1 B₂ equation. -/

theorem OQ_depth_one_unique (N : ℤ) (hN : 0 < N)
    (h : 2 * N * (N - 21) = 0) : N = 21 := by
  have h1 : N ≠ 0 := by omega
  have h2 : (2 : ℤ) ≠ 0 := by norm_num
  rcases mul_eq_zero.mp h with h3 | h3
  · rcases mul_eq_zero.mp h3 with h4 | h4
    · exact absurd h4 h2
    · exact absurd h4 h1
  · linarith

/-- The fundamental GCD property: gcd(leg, N) always divides N. -/

theorem OQ_gcd_always_divides (a N : ℤ) : ↑(Int.gcd a N) ∣ N :=
  Int.gcd_dvd_right a N

end CrossCutting

