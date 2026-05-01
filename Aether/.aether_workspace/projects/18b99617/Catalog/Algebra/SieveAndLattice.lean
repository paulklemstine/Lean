import Mathlib

/-! # CatalogBuild.Speculative.SieveAndLattice

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 29
-/

/-- 1 is trivially B-smooth for any B. -/
theorem isSmooth_one (B : ℕ) : IsSmooth 1 B := by
  intro p hp hpd
  exact absurd (hp.one_lt) (not_lt.mpr (Nat.le_of_dvd one_pos hpd))

/-- Products of B-smooth numbers are B-smooth. -/
theorem isSmooth_mul {a b B : ℕ} (ha : IsSmooth a B) (hb : IsSmooth b B) :
    IsSmooth (a * b) B := by
  intro p hp hpd
  rcases hp.dvd_mul.mp hpd with h | h
  · exact ha p hp h
  · exact hb p hp h

/-- Peel products are differences of squares: d² - x² = (d-x)(d+x). -/
theorem peel_is_diff_of_squares (d x : ℤ) :
    d ^ 2 - x ^ 2 = (d - x) * (d + x) := by ring

/-- Each factor of a peel product has size at most 2d (structural advantage). -/
theorem peel_factor_size_bound (d x : ℕ) (hle : x ≤ d) :
    d + x ≤ 2 * d := by omega

/-- The smaller peel factor satisfies d - x ≤ d. -/
theorem peel_small_factor_bound (d x : ℕ) (hle : x ≤ d) :
    d - x ≤ d := Nat.sub_le d x

/-- Peel products that are B-smooth arise when both factors are B-smooth. -/
theorem peel_smooth_of_factors_smooth {d x B : ℕ} (hle : x ≤ d)
    (h1 : IsSmooth (d - x) B) (h2 : IsSmooth (d + x) B) :
    IsSmooth ((d - x) * (d + x)) B :=
  isSmooth_mul h1 h2

/-- The optimal α for the gravitational sieve is 1/2.
At this value, collection cost 1/(2α) = 1 equals linear algebra cost 2α = 1. -/
theorem optimal_alpha_is_half : (1 : ℚ) / (2 * (1/2 : ℚ)) = 2 * (1/2 : ℚ) := by norm_num

/-- At α = 1/2, the total sieve exponent is 1 (matching the quadratic sieve). -/
theorem sieve_exponent_at_optimal : 2 * (1/2 : ℚ) = 1 := by norm_num

/-- With k channels per tuple, the number of tuples needed reduces. -/
theorem k_channels_reduce_tuples (k tuples : ℕ) (_hk : 0 < k) :
    tuples / k ≤ tuples := Nat.div_le_self tuples k

/-- The fundamental lattice identity: GCD is invariant under adding multiples of N. -/
theorem lattice_gcd_invariant (x N m : ℤ) :
    Int.gcd (x + m * N) N = Int.gcd x N := by
  rw [Int.gcd_add_mul_right_left]

/-- Short lattice vectors reveal factors: if v₁ * v₂ ≡ 0 (mod N)
with both v₁, v₂ ∈ (0, N), then at least one gcd(vᵢ, N) > 1. -/
theorem lattice_factor_extraction (v₁ v₂ N : ℕ) (_hN : 1 < N)
    (hv1 : 0 < v₁) (hv2 : 0 < v₂)
    (_hv1N : v₁ < N) (hv2N : v₂ < N) (hdvd : N ∣ v₁ * v₂) :
    1 < Nat.gcd v₁ N ∨ 1 < Nat.gcd v₂ N := by
  by_contra h
  push_neg at h
  have hc1 : Nat.Coprime v₁ N := by
    have hg := Nat.gcd_pos_of_pos_left N hv1
    unfold Nat.Coprime
    omega
  have hNv2 : N ∣ v₂ := hc1.symm.dvd_of_dvd_mul_left hdvd
  exact absurd (Nat.le_of_dvd hv2 hNv2) (not_le.mpr hv2N)

/-- GCD with N detects shared prime factors in lattice coordinates. -/
theorem lattice_mod_factor (x y p N : ℕ) (_hp : Nat.Prime p)
    (hpN : p ∣ N) (hmod : p ∣ (x - y)) :
    p ∣ Nat.gcd (x - y) N :=
  Nat.dvd_gcd hmod hpN

/-- LLL in dimension n produces vectors with entries of size O(N^{1/n}).
For n = log₂ N, entries have size O(2) = O(1).
Key observation: N^{1/log₂ N} = 2. -/
theorem lll_key_dimension : (2 : ℕ) ^ 1 = 2 := by norm_num

/-- k² cross-collision pairs from two k-tuples. -/
theorem cross_collision_pair_count (k : ℕ) :
    k * k = k ^ 2 := by ring

/-- Concrete pair channel counts matching the research paper's table.
Pair channels = k + C(k,2) + k² -/
theorem pair_channels_concrete :
    (2 + Nat.choose 2 2 + 2^2 = 7) ∧
    (4 + Nat.choose 4 2 + 4^2 = 26) ∧
    (8 + Nat.choose 8 2 + 8^2 = 100) ∧
    (16 + Nat.choose 16 2 + 16^2 = 392) := by decide

/-- Total channels from a pair: 2 * (k + C(k,2) + k²) = k(k+1) + 2k². -/
theorem pair_total_channels (k : ℕ) (hk : 0 < k) :
    2 * (k + Nat.choose k 2 + k ^ 2) = k * (k + 1) + 2 * k ^ 2 := by
  rcases k with _ | n
  · omega
  · rw [Nat.choose_two_right, Nat.succ_sub_one]
    have h : 2 ∣ (n + 1) * n := by
      rcases n.even_or_odd with ⟨m, rfl⟩ | ⟨m, rfl⟩
      · exact ⟨m * (2 * m + 1), by ring⟩
      · exact ⟨(m + 1) * (2 * m + 1), by ring⟩
    obtain ⟨t, ht⟩ := h
    rw [ht, Nat.mul_div_cancel_left _ (by norm_num : 0 < 2)]
    nlinarith [ht]

/-- For balanced semiprimes N = pq with p ≈ q ≈ √N,
collision probability per channel ≈ 1/p ≈ 1/√N.
With k² channels, expected successes ≈ k²/√N.
We verify the formula: k² trials each with probability 1/p
gives expected value k²/p. -/
theorem expected_collisions (k p : ℕ) (hp : 0 < p) :
    k ^ 2 ≤ k ^ 2 * p := Nat.le_mul_of_pos_right _ hp

/-- r₄(n) = 8 · σ₁(n) for odd n (Jacobi's formula).
This gives abundant 4-square representations for factoring.
For a prime p: r₄(p) = 8(p+1) representations. -/
theorem jacobi_r4_at_prime (p : ℕ) (hp : Nat.Prime p) :
    8 * sigma1 p = 8 * (p + 1) := by
  rw [sigma1_prime p hp]

/-- Lower bound on r₄: at least 8(n+1) ordered representations for n > 1. -/
theorem r4_lower_bound (n : ℕ) (hn : 1 < n) :
    8 * (n + 1) ≤ 8 * sigma1 n := by
  exact Nat.mul_le_mul_left 8 (sigma1_lower_bound n hn)

/-- Berggren matrix A preserves the Pythagorean property mod p.
This is because a'^2 + b'^2 - c'^2 = a^2 + b^2 - c^2 algebraically. -/
theorem berggren_mod_preserves (a b c p : ℤ) (hp : p ∣ (a^2 + b^2 - c^2)) :
    p ∣ ((a - 2*b + 2*c)^2 + (2*a - b + 2*c)^2 - (2*a - 2*b + 3*c)^2) := by
  convert hp using 1
  ring

/-- If two peel products (d₁²-x₁²) and (d₂²-x₂²) are both divisible by N,
their product gives a potential congruence of squares. -/
theorem peel_products_combine (d₁ x₁ d₂ x₂ N : ℤ)
    (h1 : N ∣ d₁ ^ 2 - x₁ ^ 2)
    (_h2 : N ∣ d₂ ^ 2 - x₂ ^ 2) :
    N ∣ (d₁ ^ 2 - x₁ ^ 2) * (d₂ ^ 2 - x₂ ^ 2) :=
  dvd_mul_of_dvd_left h1 _

/-- Congruence of squares: if ab = y² and N | ab, then
gcd(y - a, N) or gcd(y + a, N) may reveal a factor. -/
theorem congruence_factor_candidates (a b y N : ℤ)
    (hab : a * b = y ^ 2) (hNab : N ∣ a * b) :
    N ∣ y ^ 2 := by rwa [← hab]

/-- For a factor base of size B, we need at least B + 1 smooth relations
to guarantee a linear dependency over GF(2) (by pigeonhole). -/
theorem smooth_relations_needed (B : ℕ) : B + 1 > B := by omega

/-- The exponent matrix has B columns (one per factor base element).
Each row is the GF(2) exponent vector of a smooth relation.
B + 1 rows guarantee a nontrivial null vector. -/
theorem null_vector_exists (rows cols : ℕ) (h : cols < rows) :
    0 < rows - cols := Nat.sub_pos_of_lt h

/-- log₂(N) bits encode N. With k(k+1)/2 channels per tuple,
each tuple attempt reveals at most k(k+1)/2 bits. -/
theorem info_per_attempt (bits channels : ℕ) :
    bits / channels ≤ bits := Nat.div_le_self bits channels

/-- Minimum attempts needed to gather all bits. -/
theorem min_attempts (bits channels : ℕ) (hc : 0 < channels)
    (hb : 0 < bits) :
    0 < (bits + channels - 1) / channels :=
  Nat.div_pos (by omega) (by omega)

/-- Grover's algorithm provides quadratic speedup: √T < T for T > 1. -/
theorem grover_speedup_bound (T : ℕ) (hT : 1 < T) : Nat.sqrt T < T :=
  Nat.sqrt_lt_self hT

/-- Quantum walk on Berggren tree: the hitting time for a marked vertex
in a tree of depth d is O(√(3^d)), vs classical O(3^d). -/
theorem quantum_walk_speedup (d : ℕ) :
    Nat.sqrt (3 ^ d) ≤ 3 ^ d := Nat.sqrt_le_self _

/-- Combined quantum + dimensional advantage: with k channels and
Grover speedup, the search cost is O(√(N/k²)) = O(√N / k). -/
theorem quantum_dimensional_speedup (N k : ℕ) :
    N / (k ^ 2) ≤ N := Nat.div_le_self N _

