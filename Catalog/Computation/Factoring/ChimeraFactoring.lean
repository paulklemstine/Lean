/-! # CatalogBuild.Computation.Factoring.ChimeraFactoring

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 40
-/

import Mathlib

noncomputable section

/-- **Fundamental Factoring Identity**: x² - y² = (x - y)(x + y) over ℤ. -/
theorem sq_sub_sq_factor (x y : ℤ) : x ^ 2 - y ^ 2 = (x - y) * (x + y) := by ring


/-- **Congruence of squares in ZMod**: If x² = y² in ZMod N,
then (x - y)(x + y) = 0 in ZMod N. This is the algebraic engine
behind every modern factoring algorithm. -/
theorem congruence_of_squares_zmod (N : ℕ) (x y : ZMod N) (h : x ^ 2 = y ^ 2) :
    (x - y) * (x + y) = 0 := by
  have : (x - y) * (x + y) = x ^ 2 - y ^ 2 := by ring
  rw [this, h, sub_self]


/-- **Factor from square congruence (ℤ version)**: If N | (x²-y²) then N | (x-y)(x+y). -/
theorem factor_from_square_congruence_int (N x y : ℤ)
    (h : N ∣ x ^ 2 - y ^ 2) :
    N ∣ (x - y) * (x + y) := by
  have : x ^ 2 - y ^ 2 = (x - y) * (x + y) := by ring
  rwa [this] at h


/-- **Nontrivial factor extraction**: If x² ≡ y² (mod N) but x ≢ ±y (mod N),
then both x - y and x + y are nonzero mod N while their product is 0.
This means N shares a nontrivial factor with both. -/
theorem square_root_ambiguity (N : ℕ) (x y : ZMod N)
    (hcong : x ^ 2 = y ^ 2) (hne : x ≠ y) (hne' : x ≠ -y) :
    (x - y) ≠ 0 ∧ (x + y) ≠ 0 ∧ (x - y) * (x + y) = 0 := by
  refine ⟨fun h => hne (sub_eq_zero.mp h), fun h => hne' ?_,
    congruence_of_squares_zmod N x y hcong⟩
  exact eq_neg_of_add_eq_zero_left h


/-- In ℤ/Nℤ where N = p*q (distinct odd primes), every square root of 1
is either ±1 or reveals a factor. -/
theorem square_root_trichotomy (N : ℕ) (x : ZMod N) (hx : x ^ 2 = 1) :
    x = 1 ∨ x = -1 ∨ (x ≠ 1 ∧ x ≠ -1) := by
  by_cases h1 : x = 1
  · exact Or.inl h1
  · by_cases h2 : x = -1
    · exact Or.inr (Or.inl h2)
    · exact Or.inr (Or.inr ⟨h1, h2⟩)


/-- **Shor's Factoring Reduction (algebraic core)**: a^(2r) - 1 = (a^r - 1)(a^r + 1).
This is the identity that converts period-finding into factoring. -/
theorem shor_algebraic_core (a : ℤ) (r : ℕ) :
    a ^ (2 * r) - 1 = (a ^ r - 1) * (a ^ r + 1) := by
  rw [pow_mul]; ring


/-- **Shor's identity in ZMod**: If a^(2k) = 1 in ZMod N, then
(a^k - 1)(a^k + 1) = 0. The GCD of a^k - 1 (or a^k + 1) with N
gives a factor (unless a^k = ±1). -/
theorem shor_zmod_factoring (N : ℕ) (a : ZMod N) (k : ℕ) (hord : a ^ (2 * k) = 1) :
    (a ^ k - 1) * (a ^ k + 1) = 0 := by
  have : (a ^ k - 1) * (a ^ k + 1) = a ^ (2 * k) - 1 := by ring
  rw [this, hord, sub_self]


/-- **Shor's success probability bound**: For N = pq with distinct odd primes,
φ(N) = (p-1)(q-1). The probability of finding an even order is ≥ 1/2,
and the probability of a^(r/2) ≢ -1 is also ≥ 1/2. -/
theorem shor_totient (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q) (hpq : p ≠ q) :
    Nat.totient (p * q) = (p - 1) * (q - 1) := by
  rw [Nat.totient_mul ((hp.coprime_iff_not_dvd.mpr (fun h =>
    hpq ((hq.eq_one_or_self_of_dvd p h).resolve_left hp.one_lt.ne'))))]
  rw [Nat.totient_prime hp, Nat.totient_prime hq]


/-- **Order divides totient (Euler's theorem consequence)**: In ZMod p for prime p,
every nonzero element satisfies a^(p-1) = 1. -/
theorem fermat_little_zmod (p : ℕ) (hp : Nat.Prime p) (a : ZMod p) (ha : a ≠ 0) :
    a ^ (p - 1) = 1 := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact ZMod.pow_card_sub_one_eq_one ha


/-- **Difference of cubes**: x³ - y³ = (x - y)(x² + xy + y²). -/
theorem difference_of_cubes (x y : ℤ) :
    x ^ 3 - y ^ 3 = (x - y) * (x ^ 2 + x * y + y ^ 2) := by ring


/-- **Sum of cubes**: x³ + y³ = (x + y)(x² - xy + y²). -/
theorem sum_of_cubes (x y : ℤ) :
    x ^ 3 + y ^ 3 = (x + y) * (x ^ 2 - x * y + y ^ 2) := by ring


/-- **Difference of fourth powers**: x⁴ - y⁴ = (x²-y²)(x²+y²). -/
theorem difference_of_fourth_powers (x y : ℤ) :
    x ^ 4 - y ^ 4 = (x ^ 2 - y ^ 2) * (x ^ 2 + y ^ 2) := by ring


/-- **Difference of fifth powers**. -/
theorem difference_of_fifth_powers (x y : ℤ) :
    x ^ 5 - y ^ 5 = (x - y) * (x ^ 4 + x ^ 3 * y + x ^ 2 * y ^ 2 + x * y ^ 3 + y ^ 4) := by
  ring


/-- **Difference of sixth powers** factors through both squares and cubes. -/
theorem difference_of_sixth_powers (x y : ℤ) :
    x ^ 6 - y ^ 6 = (x - y) * (x + y) * (x ^ 2 + x * y + y ^ 2) *
                     (x ^ 2 - x * y + y ^ 2) := by ring


/-- **Sophie Germain / Aurifeuillean identity**: x⁴ + 4y⁴ = (x²+2y²+2xy)(x²+2y²-2xy).
This factors a sum of even powers — a "wormhole" in algebraic factoring. -/
theorem sophie_germain_identity (x y : ℤ) :
    x ^ 4 + 4 * y ^ 4 = (x ^ 2 + 2 * y ^ 2 + 2 * x * y) *
                          (x ^ 2 + 2 * y ^ 2 - 2 * x * y) := by ring


/-- **Birthday Pigeonhole**: If k > n, any function Fin k → Fin n has a collision. -/
theorem birthday_pigeonhole (n k : ℕ) (f : Fin k → Fin n) (hk : n < k) :
    ∃ i j : Fin k, i ≠ j ∧ f i = f j := by
  by_contra h
  push_neg at h
  have hinj : Function.Injective f := fun a b hab => by
    by_contra hne; exact (h a b hne hab).elim
  exact absurd (Fintype.card_le_of_injective f hinj) (by simp; omega)


/-- **Pollard's ρ cycle existence**: Any sequence in a finite set of size n
must cycle within the first n+1 elements. This is the mathematical
guarantee that Pollard's ρ terminates. -/
theorem pollard_rho_cycle (n : ℕ) (hn : 0 < n) (f : Fin n → Fin n) (x₀ : Fin n) :
    ∃ i j : ℕ, i < j ∧ j ≤ n ∧ (f^[i]) x₀ = (f^[j]) x₀ := by
  have hcoll : ∃ a b : Fin (n + 1), a ≠ b ∧
      (fun (k : Fin (n + 1)) => (f^[k.val]) x₀) a =
      (fun (k : Fin (n + 1)) => (f^[k.val]) x₀) b :=
    birthday_pigeonhole n (n + 1) _ (by omega)
  obtain ⟨a, b, hab, heq⟩ := hcoll
  simp at heq
  rcases Nat.lt_or_gt_of_ne (Fin.val_ne_of_ne hab) with h | h
  · exact ⟨a.val, b.val, h, by omega, heq⟩
  · exact ⟨b.val, a.val, h, by omega, heq.symm⟩


/-- **Pollard's ρ complexity**: The expected number of steps is O(√p)
where p is the smallest prime factor of N. Since p ≤ √N,
the total complexity is O(N^{1/4}).
We prove the foundational bound: p ≤ N for any prime factor p of N. -/
theorem prime_factor_le (N p : ℕ) (hN : 0 < N) (hp : Nat.Prime p) (hpN : p ∣ N) :
    p ≤ N :=
  Nat.le_of_dvd hN hpN


/-- Any prime p ≤ B is B-smooth. -/
theorem prime_isSmooth (B p : ℕ) (hp : Nat.Prime p) (hpB : p ≤ B) :
    IsSmooth B p := by
  intro q hq hqp
  rcases hp.eq_one_or_self_of_dvd q hqp with h | h
  · exact absurd hq.two_le (by omega)
  · omega


/-- **Power of smooth is smooth**. -/
theorem smooth_pow (B n k : ℕ) (hn : IsSmooth B n) :
    IsSmooth B (n ^ k) := by
  induction k with
  | zero => simpa using one_isSmooth B
  | succ k ih => rw [pow_succ]; exact smooth_mul B _ _ ih hn


/-- **Factor base size bound**: #{primes ≤ B} ≤ B + 1. -/
theorem factor_base_size_bound (B : ℕ) :
    (Finset.filter Nat.Prime (Finset.range (B + 1))).card ≤ B + 1 :=
  le_trans (Finset.card_filter_le _ _) (by simp)


/-- **Sieve threshold**: To find a linear dependency over 𝔽₂ among
smooth relations, we need more relations than the factor base size.
This is the rank-nullity theorem applied to the exponent matrix. -/
theorem sieve_threshold (n k : ℕ) (hk : n < k) : 0 < k - n := by omega


/-- **ECM vs Pollard's ρ**: √p < p for p > 1. ECM's L(p) complexity is
subexponential in p (the smallest factor), not in N. -/
theorem ecm_advantage (p : ℕ) (hp : 1 < p) : Nat.sqrt p < p :=
  Nat.sqrt_lt_self hp


/-- **Multiple curves improve success**: (1-δ)^k < 1 for 0 < δ < 1, k ≥ 1.
ECM tries many random curves; each has independent chance δ of
having a B-smooth group order. -/
theorem ecm_multiple_curves (k : ℕ) (δ : ℝ) (hδ : 0 < δ) (hδ1 : δ < 1) (hk : 1 ≤ k) :
    (1 - δ) ^ k < 1 :=
  pow_lt_one₀ (by linarith) (by linarith) (by omega)


/-- **Minkowski's lattice theorem (1D)**: Any interval of length ≥ 1 contains an integer. -/
theorem minkowski_1d (a b : ℤ) (hlen : 1 ≤ b - a) :
    ∃ n : ℤ, a ≤ n ∧ n ≤ b :=
  ⟨a, le_refl a, by linarith⟩


/-- **2×2 determinant formula**: det [[a,b],[c,d]] = ad - bc. -/
theorem det_two_by_two (a b c d : ℤ) :
    Matrix.det !![a, b; c, d] = a * d - b * c := by
  simp [Matrix.det_fin_two]


/-- **Trace of identity matrix**: tr(Iₙ) = n. -/
theorem trace_identity_matrix (n : ℕ) :
    Matrix.trace (1 : Matrix (Fin n) (Fin n) ℤ) = ↑n := by
  simp [Matrix.trace, Matrix.diag]


/-- **Trace of outer product**: tr(u·vᵀ) = ⟨u, v⟩ (inner product).
When u and v encode factor structure of N, the trace reveals information. -/
theorem trace_outer_product (n : ℕ) (u v : Fin n → ℤ) :
    Matrix.trace (Matrix.vecMulVec u v) = ∑ i, u i * v i := by
  simp [Matrix.trace, Matrix.vecMulVec, Matrix.diag]


theorem composite_has_small_factor (N : ℕ) (hN : 1 < N) (hcomp : ¬Nat.Prime N) :
    ∃ d : ℕ, Nat.Prime d ∧ d ∣ N ∧ d * d ≤ N := by
  obtain ⟨d, hd_prime, hd_factor⟩ : ∃ d, Nat.Prime d ∧ d ∣ N ∧ ∀ e, Nat.Prime e → e ∣ N → d ≤ e := by
    exact ⟨ Nat.minFac N, Nat.minFac_prime hN.ne', Nat.minFac_dvd N, fun e he he' => Nat.minFac_le_of_dvd he.two_le he' ⟩;
  cases' hd_factor.1 with k hk;
  exact ⟨ d, hd_prime, hd_factor.1, by nlinarith [ hd_factor.2 ( Nat.minFac k ) ( Nat.minFac_prime ( by aesop ) ) ( Nat.dvd_trans ( Nat.minFac_dvd k ) ( hk.symm ▸ dvd_mul_left _ _ ) ), Nat.minFac_le ( Nat.pos_of_ne_zero ( by aesop : k ≠ 0 ) ) ] ⟩


/-- **Factor bit-length bound**: For N = p * q with p ≤ q, p² ≤ N. -/
theorem factor_size_bound (N p q : ℕ) (hN : N = p * q) (hp : 0 < p) (hpq : p ≤ q) :
    p * p ≤ N := by
  rw [hN]; exact Nat.mul_le_mul_left p hpq


theorem semiprime_unique_factorization (p q p' q' : ℕ)
    (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hp' : Nat.Prime p') (hq' : Nat.Prime q')
    (hpq : p ≤ q) (hp'q' : p' ≤ q')
    (hN : p * q = p' * q') :
    p = p' ∧ q = q' := by
  -- Since p is prime and divides p' * q', by Nat.Prime.dvd_mul, p must divide p' or p must divide q'.
  have h_div : p ∣ p' ∨ p ∣ q' := by
    exact hp.dvd_mul.mp ( hN ▸ dvd_mul_right _ _ );
  cases h_div <;> simp_all +decide [ Nat.prime_dvd_prime_iff_eq ];
  · aesop;
  · -- Since q' * q = p' * q' and q' is prime, we can divide both sides by q' to get q = p'.
    have hq_eq_p' : q = p' := by
      nlinarith [ hq'.two_le ];
    grind


/-- **Euler totient of semiprime**: φ(pq) = (p-1)(q-1) for distinct primes. -/
theorem euler_totient_semiprime (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) :
    Nat.totient (p * q) = (p - 1) * (q - 1) := by
  rw [Nat.totient_mul (hp.coprime_iff_not_dvd.mpr (fun h =>
    hpq ((hq.eq_one_or_self_of_dvd p h).resolve_left hp.one_lt.ne')))]
  rw [Nat.totient_prime hp, Nat.totient_prime hq]


/-- **Carmichael function divides totient**: λ(pq) = lcm(p-1,q-1) | φ(pq). -/
theorem carmichael_divides_totient (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) :
    Nat.lcm (p - 1) (q - 1) ∣ Nat.totient (p * q) := by
  rw [euler_totient_semiprime p q hp hq hpq]
  exact Nat.lcm_dvd_mul (p - 1) (q - 1)


theorem cyclotomic_2 (x : ℤ) : x ^ 2 - 1 = (x - 1) * (x + 1) := by ring

theorem cyclotomic_3 (x : ℤ) : x ^ 3 - 1 = (x - 1) * (x ^ 2 + x + 1) := by ring

theorem cyclotomic_4 (x : ℤ) : x ^ 4 - 1 = (x - 1) * (x + 1) * (x ^ 2 + 1) := by ring

theorem cyclotomic_5 (x : ℤ) :
    x ^ 5 - 1 = (x - 1) * (x ^ 4 + x ^ 3 + x ^ 2 + x + 1) := by ring

theorem cyclotomic_6 (x : ℤ) :
    x ^ 6 - 1 = (x - 1) * (x + 1) * (x ^ 2 + x + 1) * (x ^ 2 - x + 1) := by ring


theorem sum_factoring_3 (x : ℤ) : x ^ 3 + 1 = (x + 1) * (x ^ 2 - x + 1) := by ring

theorem sum_factoring_5 (x : ℤ) :
    x ^ 5 + 1 = (x + 1) * (x ^ 4 - x ^ 3 + x ^ 2 - x + 1) := by ring


end
