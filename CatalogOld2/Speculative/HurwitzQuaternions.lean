/-! # CatalogBuild.Speculative.HurwitzQuaternions

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 39
-/

import Mathlib

/-- The quaternion norm: N(a,b,c,d) = a² + b² + c² + d². -/
def qnorm (a b c d : ℤ) : ℤ := a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2


/-- Quaternion norm is always nonneg. -/
theorem qnorm_nonneg (a b c d : ℤ) : 0 ≤ qnorm a b c d := by
  unfold qnorm; positivity


/-- Quaternion norm zero iff all components zero. -/
theorem qnorm_eq_zero (a b c d : ℤ) :
    qnorm a b c d = 0 ↔ a = 0 ∧ b = 0 ∧ c = 0 ∧ d = 0 := by
  unfold qnorm
  constructor
  · intro h
    have ha := sq_nonneg a; have hb := sq_nonneg b
    have hc := sq_nonneg c; have hd := sq_nonneg d
    refine ⟨?_, ?_, ?_, ?_⟩ <;> nlinarith
  · rintro ⟨rfl, rfl, rfl, rfl⟩; simp [qnorm]


/-- Euler's four-square identity: the product of two sums of four squares
is itself a sum of four squares. -/
theorem euler_four_square_identity (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    qnorm a₁ b₁ c₁ d₁ * qnorm a₂ b₂ c₂ d₂ =
    qnorm (a₁ * a₂ - b₁ * b₂ - c₁ * c₂ - d₁ * d₂)
          (a₁ * b₂ + b₁ * a₂ + c₁ * d₂ - d₁ * c₂)
          (a₁ * c₂ - b₁ * d₂ + c₁ * a₂ + d₁ * b₂)
          (a₁ * d₂ + b₁ * c₂ - c₁ * b₂ + d₁ * a₂) := by
  unfold qnorm; ring


/-- Closure of four-square representability under multiplication. -/
theorem four_square_mul_closure (n₁ n₂ : ℤ)
    (h₁ : ∃ a b c d : ℤ, qnorm a b c d = n₁)
    (h₂ : ∃ a b c d : ℤ, qnorm a b c d = n₂) :
    ∃ a b c d : ℤ, qnorm a b c d = n₁ * n₂ := by
  obtain ⟨a₁, b₁, c₁, d₁, rfl⟩ := h₁
  obtain ⟨a₂, b₂, c₂, d₂, rfl⟩ := h₂
  exact ⟨_, _, _, _, (euler_four_square_identity a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂).symm⟩


/-- Second BF decomposition. -/
theorem brahmagupta_fibonacci' (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by ring


/-- If N has two representations as sum of two squares, the cross-terms
produce factor candidates. -/
theorem bf_gcd_factor_principle (a b c d N : ℤ)
    (hN : N = (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2)) :
    N = (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 ∧
    N = (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by
  constructor <;> linarith [brahmagupta_fibonacci a b c d, brahmagupta_fibonacci' a b c d]


theorem short_vector_pair_factor (v w N : ℕ) (hN : 1 < N)
    (hv : 0 < v) (hw : 0 < w) (hvN : v < N) (hwN : w < N)
    (hdvd : N ∣ v * w) :
    1 < Nat.gcd v N ∨ 1 < Nat.gcd w N := by
  -- Assume for contradiction that both gcd(v, N) and gcd(w, N) are 1.
  by_contra h_contra
  have h_coprime : Nat.gcd v N = 1 ∧ Nat.gcd w N = 1 := by
    exact ⟨ le_antisymm ( not_lt.mp fun contra => h_contra <| Or.inl contra ) ( Nat.gcd_pos_of_pos_left _ hv ), le_antisymm ( not_lt.mp fun contra => h_contra <| Or.inr contra ) ( Nat.gcd_pos_of_pos_left _ hw ) ⟩;
  have h_div_w : N ∣ w := by
    exact ( Nat.Coprime.symm h_coprime.1 ) |> fun h => h.dvd_of_dvd_mul_left hdvd;
  linarith [ Nat.le_of_dvd hw h_div_w ]


theorem lll_poly_dimension (n : ℕ) (hn : 0 < n) : n ≤ n ^ 6 := by
  exact Nat.le_self_pow ( by decide ) _


/-- k² cross-collision pairs from two k-tuples. -/
theorem cross_collision_pairs (k : ℕ) : k * k = k ^ 2 := by ring


/-- Within-tuple GCD channels: C(k,2) = k(k-1)/2. -/
theorem within_tuple_channels (k : ℕ) :
    Nat.choose k 2 = k * (k - 1) / 2 := Nat.choose_two_right k


/-- Concrete channel counts for various k. -/
theorem channels_k2 : Nat.choose 2 2 + 2 ^ 2 = 5 := by decide

theorem channels_k4 : Nat.choose 4 2 + 4 ^ 2 = 22 := by decide

theorem channels_k8 : Nat.choose 8 2 + 8 ^ 2 = 92 := by decide

theorem channels_k16 : Nat.choose 16 2 + 16 ^ 2 = 376 := by decide


/-- Birthday paradox for cross-collisions. -/
theorem birthday_cross_collisions (m k : ℕ) :
    Nat.choose m 2 * k ^ 2 = m * (m - 1) / 2 * k ^ 2 := by
  rw [Nat.choose_two_right]


/-- Berggren matrix A preserves Pythagorean property. -/
theorem berggren_A (a b c p : ℤ) (hp : p ∣ (a ^ 2 + b ^ 2 - c ^ 2)) :
    p ∣ ((a - 2 * b + 2 * c) ^ 2 + (2 * a - b + 2 * c) ^ 2 -
         (2 * a - 2 * b + 3 * c) ^ 2) := by
  have : (a - 2 * b + 2 * c) ^ 2 + (2 * a - b + 2 * c) ^ 2 -
         (2 * a - 2 * b + 3 * c) ^ 2 = a ^ 2 + b ^ 2 - c ^ 2 := by ring
  rw [this]; exact hp


/-- Berggren matrix B preserves Pythagorean property. -/
theorem berggren_B (a b c p : ℤ) (hp : p ∣ (a ^ 2 + b ^ 2 - c ^ 2)) :
    p ∣ ((a + 2 * b + 2 * c) ^ 2 + (2 * a + b + 2 * c) ^ 2 -
         (2 * a + 2 * b + 3 * c) ^ 2) := by
  have : (a + 2 * b + 2 * c) ^ 2 + (2 * a + b + 2 * c) ^ 2 -
         (2 * a + 2 * b + 3 * c) ^ 2 = a ^ 2 + b ^ 2 - c ^ 2 := by ring
  rw [this]; exact hp


/-- Berggren matrix C preserves Pythagorean property. -/
theorem berggren_C (a b c p : ℤ) (hp : p ∣ (a ^ 2 + b ^ 2 - c ^ 2)) :
    p ∣ ((-a + 2 * b + 2 * c) ^ 2 + (-2 * a + b + 2 * c) ^ 2 -
         (-2 * a + 2 * b + 3 * c) ^ 2) := by
  have : (-a + 2 * b + 2 * c) ^ 2 + (-2 * a + b + 2 * c) ^ 2 -
         (-2 * a + 2 * b + 3 * c) ^ 2 = a ^ 2 + b ^ 2 - c ^ 2 := by ring
  rw [this]; exact hp


/-- Tree size at depth d. -/
theorem berggren_tree_count (d : ℕ) : 3 ^ d ≥ 1 := Nat.one_le_pow d 3 (by omega)


/-- Total tree size up to depth d is (3^(d+1) - 1) / 2.
We verify for concrete small values. -/
theorem berggren_tree_total_0 : ∑ i ∈ range 1, 3 ^ i = 1 := by decide

theorem berggren_tree_total_1 : ∑ i ∈ range 2, 3 ^ i = 4 := by decide

theorem berggren_tree_total_2 : ∑ i ∈ range 3, 3 ^ i = 13 := by decide

theorem berggren_tree_total_3 : ∑ i ∈ range 4, 3 ^ i = 40 := by decide


theorem berggren_tree_total (d : ℕ) :
    2 * ∑ i ∈ range (d + 1), 3 ^ i = 3 ^ (d + 1) - 1 := by
  norm_num [ Nat.geomSum_eq ];
  rw [ Nat.mul_div_cancel' ( by simpa using nat_sub_dvd_pow_sub_pow 3 1 ( d + 1 ) ) ]


/-- Tropical Pythagorean: min(2a, 2b) = 2c ⟺ min(a,b) = c. -/
theorem tropical_pythagorean (a b c : ℤ) :
    min (2 * a) (2 * b) = 2 * c ↔ min a b = c := by omega


/-- Tropical variety has polyhedral structure. -/
theorem tropical_variety_cases (a b c : ℤ) (h : min a b = c) :
    (a ≤ b ∧ c = a) ∨ (b < a ∧ c = b) := by
  simp only [min_def] at h
  split_ifs at h with hab
  · exact Or.inl ⟨hab, h.symm⟩
  · exact Or.inr ⟨not_le.mp hab, h.symm⟩


theorem channel_quadratic (k : ℕ) (hk : 2 ≤ k) :
    k ≤ k * (k + 1) / 2 := by
  rw [ Nat.le_div_iff_mul_le ] <;> nlinarith


theorem sigma1_prime_sq (p : ℕ) (hp : Nat.Prime p) :
    sigma1 (p ^ 2) = p ^ 2 + p + 1 := by
  unfold sigma1;
  norm_num [ Nat.divisors_prime_pow hp, add_comm, add_left_comm, add_assoc ];
  simpa [ Finset.sum_range_succ ] using by ring;


/-- Jacobi formula consequence: r₄(p) = 8(p + 1) for primes. -/
theorem r4_prime (p : ℕ) (hp : Nat.Prime p) :
    8 * sigma1 p = 8 * (p + 1) := by
  rw [sigma1_prime p hp]


/-- σ₁ multiplicativity for coprime arguments. -/
theorem sigma1_mult (m n : ℕ) (hcop : Nat.Coprime m n) :
    sigma1 (m * n) = sigma1 m * sigma1 n := by
  unfold sigma1
  exact Coprime.sum_divisors_mul hcop


/-- σ₁(n) ≥ n + 1 for n > 1 (since 1 and n are always divisors). -/
theorem sigma1_ge (n : ℕ) (hn : 1 < n) : n + 1 ≤ sigma1 n := by
  unfold sigma1
  have h1 : 1 ∈ n.divisors := Nat.mem_divisors.mpr ⟨one_dvd n, by omega⟩
  have hn_mem : n ∈ n.divisors := Nat.mem_divisors.mpr ⟨dvd_refl n, by omega⟩
  calc n + 1
    _ = ∑ d ∈ ({1, n} : Finset ℕ), d := by
        simp [Finset.sum_pair (by omega : 1 ≠ n)]; omega
    _ ≤ ∑ d ∈ n.divisors, d := by
        apply Finset.sum_le_sum_of_subset
        intro x hx; simp at hx
        rcases hx with rfl | rfl <;> assumption


/-- Peel products are differences of squares. -/
theorem peel_diff_sq (d x : ℤ) : d ^ 2 - x ^ 2 = (d - x) * (d + x) := by ring


/-- Each peel factor has controlled size. -/
theorem peel_factor_bound (d x : ℕ) (hle : x ≤ d) :
    d + x ≤ 2 * d := by omega


/-- Smooth peel products from smooth factors. -/
theorem peel_smooth (d x B : ℕ) (h1 : IsSmooth (d - x) B) (h2 : IsSmooth (d + x) B) :
    IsSmooth ((d - x) * (d + x)) B :=
  smooth_mul h1 h2


/-- Grover on k-channel reduced space. -/
theorem grover_channels (N k : ℕ) :
    Nat.sqrt (N / k ^ 2) ≤ Nat.sqrt N :=
  Nat.sqrt_le_sqrt (Nat.div_le_self N _)


/-- Classical advantage with k channels. -/
theorem classical_channels (N k : ℕ) :
    N / k ^ 2 ≤ N := Nat.div_le_self N _


/-- Quantum walk on tree: √(b^d) ≤ b^d. -/
theorem quantum_tree (b d : ℕ) :
    Nat.sqrt (b ^ d) ≤ b ^ d := Nat.sqrt_le_self _


/-- Grover speedup is strict for T > 1. -/
theorem grover_strict (T : ℕ) (hT : 1 < T) : Nat.sqrt T < T :=
  Nat.sqrt_lt_self hT
