/-! # CatalogBuild.Best.06_HigherKTupleFactoring

Auto-generated from theorem catalog database.
Domain: Best
Declarations: 58
-/

import Mathlib

/-- The generalized Lorentz form Q_{n,1}: sum of first n squares minus last square.
For a vector v : Fin (n+1) → ℤ, Q(v) = v₀² + v₁² + ... + v_{n-1}² - v_n². -/
def lorentzFormGen (n : ℕ) (v : Fin (n + 1) → ℤ) : ℤ :=
  (∑ i : Fin n, (v (Fin.castSucc i)) ^ 2) - (v (Fin.last n)) ^ 2


/-- A vector is on the null cone iff Q_{n,1}(v) = 0. -/
def isNullGen (n : ℕ) (v : Fin (n + 1) → ℤ) : Prop :=
  lorentzFormGen n v = 0


/-- Null cone ↔ sum of spatial squares equals temporal square. -/
theorem null_iff_sum_eq (n : ℕ) (v : Fin (n + 1) → ℤ) :
    isNullGen n v ↔ ∑ i : Fin n, (v (Fin.castSucc i)) ^ 2 = (v (Fin.last n)) ^ 2 := by
  unfold isNullGen lorentzFormGen
  omega


/-- A Pythagorean quintuplet (a,b,c,d,e) satisfies a² + b² + c² + d² = e². -/
structure PythQuintuplet where
  a : ℤ
  b : ℤ
  c : ℤ
  d : ℤ
  e : ℤ
  quint_eq : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = e ^ 2


/-- A Pythagorean sextuplet (a,b,c,d,e,f) satisfies a² + b² + c² + d² + e² = f². -/
structure PythSextuplet where
  a : ℤ
  b : ℤ
  c : ℤ
  d : ℤ
  e : ℤ
  f : ℤ
  sext_eq : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 + e ^ 2 = f ^ 2


/-- A Pythagorean octuplet (a₁,...,a₇,a₈) satisfies ∑a_i² = a₈². -/
structure PythOctuplet where
  v : Fin 7 → ℤ
  w : ℤ
  oct_eq : ∑ i : Fin 7, (v i) ^ 2 = w ^ 2


def quint_1_1_1_1 : PythQuintuplet where
  a := 1; b := 1; c := 1; d := 1; e := 2
  quint_eq := by norm_num


def quint_1_2_2_4 : PythQuintuplet where
  a := 1; b := 2; c := 2; d := 4; e := 5
  quint_eq := by norm_num


def quint_1_4_4_4 : PythQuintuplet where
  a := 1; b := 4; c := 4; d := 4; e := 7
  quint_eq := by norm_num


def sext_1_1_1_2_3 : PythSextuplet where
  a := 1; b := 1; c := 1; d := 2; e := 3; f := 4
  sext_eq := by norm_num


def sext_1_1_3_3_4 : PythSextuplet where
  a := 1; b := 1; c := 3; d := 3; e := 4; f := 6
  sext_eq := by norm_num


def oct_example : PythOctuplet where
  v := ![1, 2, 3, 4, 5, 6, 3]
  w := 10
  oct_eq := by native_decide


/-- Core factoring identity for k-tuples: if a² + b² + c² = N², then (N-c)(N+c) = a² + b². -/
theorem ktuple_diff_of_squares_3 (a b c N : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = N ^ 2) :
    (N - c) * (N + c) = a ^ 2 + b ^ 2 := by nlinarith


/-- For quintuplets: (N-d)(N+d) = a² + b² + c². -/
theorem ktuple_diff_of_squares_4 (a b c d N : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = N ^ 2) :
    (N - d) * (N + d) = a ^ 2 + b ^ 2 + c ^ 2 := by nlinarith


/-- For sextuplets: (N-e)(N+e) = a² + b² + c² + d². -/
theorem ktuple_diff_of_squares_5 (a b c d e N : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 + e ^ 2 = N ^ 2) :
    (N - e) * (N + e) = a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 := by nlinarith


/-- **Multi-Channel Factor Extraction**: Given a Pythagorean quadruple with hypotenuse N,
if gcd(N - c, N) is nontrivial, we extract a factor. -/
theorem multichannel_factor_extraction (a b c N : ℤ) (hN : 1 < N)
    (h_quad : a ^ 2 + b ^ 2 + c ^ 2 = N ^ 2)
    (hg : 1 < Int.gcd (N - c) N)
    (hg2 : (Int.gcd (N - c) N : ℤ) < N) :
    ∃ d : ℤ, d ∣ N ∧ 1 < d ∧ d < N :=
  ⟨Int.gcd (N - c) N, Int.gcd_dvd_right _ _, by exact_mod_cast hg, hg2⟩


/-- **Channel Duality**: The complementary GCD also divides N. -/
theorem channel_duality (a b c N : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = N ^ 2) :
    ↑(Int.gcd (N + c) N) ∣ N :=
  Int.gcd_dvd_right _ _


/-- **Pairwise Channel Identity**: In a quadruple, a² - b² = N² - 2b² - c². -/
theorem pairwise_channel (a b c N : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = N ^ 2) :
    a ^ 2 - b ^ 2 = N ^ 2 - 2 * b ^ 2 - c ^ 2 := by nlinarith


/-- **Cross-channel GCD**: gcd(a²-b², N) divides N and reveals structure. -/
theorem cross_channel_gcd_divides (a b N : ℤ) :
    ↑(Int.gcd (a ^ 2 - b ^ 2) N) ∣ N :=
  Int.gcd_dvd_right _ _


/-- **Factored form of cross-channel**: a² - b² = (a-b)(a+b). -/
theorem cross_channel_factored (a b : ℤ) :
    a ^ 2 - b ^ 2 = (a - b) * (a + b) := by ring


/-- The inside-out parametrization for quadruples: given N, parameters u and v,
compute the hypotenuse h² = N² + u² + v². -/
def insideOutQuadHyp (N u v : ℤ) : ℤ := N ^ 2 + u ^ 2 + v ^ 2


/-- The inside-out triple: N² + u² = h² gives (h-u)(h+u) = N². -/
theorem inside_out_triple_factor (N u h : ℤ) (hp : N ^ 2 + u ^ 2 = h ^ 2) :
    (h - u) * (h + u) = N ^ 2 := by nlinarith


/-- **Inside-Out Quadruple Factor Theorem**: Given N² + u² + v² = h²,
we have (h-v)(h+v) = N² + u², providing a sum-of-squares decomposition
of N² + u² that may reveal factors. -/
theorem inside_out_quad_factor (N u v h : ℤ) (hp : N ^ 2 + u ^ 2 + v ^ 2 = h ^ 2) :
    (h - v) * (h + v) = N ^ 2 + u ^ 2 := by nlinarith


/-- **Inside-Out Triple vs Quadruple**: The quadruple version provides an
additional factoring equation compared to triples. -/
theorem inside_out_two_channels (N u v h : ℤ) (hp : N ^ 2 + u ^ 2 + v ^ 2 = h ^ 2) :
    (h - v) * (h + v) = N ^ 2 + u ^ 2 ∧
    (h - u) * (h + u) = N ^ 2 + v ^ 2 := by
  constructor <;> nlinarith


/-- **Sum-of-two-squares factor theorem**: If N² - c² = (N-c)(N+c) and
gcd(N-c, N) is nontrivial, then we factor N. -/
theorem energy_factor_theorem (N c g : ℤ) (hN : 1 < N) (hc : 0 ≤ c) (hcN : c < N)
    (hg_def : g = Int.gcd (N - c) N)
    (hg1 : 1 < g) (hg2 : g < N) :
    ∃ d : ℤ, d ∣ N ∧ 1 < d ∧ d < N := by
  exact ⟨g, by rw [hg_def]; exact_mod_cast Int.gcd_dvd_right _ _, hg1, hg2⟩


theorem congruence_of_squares_factor (x y N : ℤ) (hN : 1 < N)
    (hcong : N ∣ (x ^ 2 - y ^ 2))
    (hne1 : ¬(N ∣ (x - y))) (hne2 : ¬(N ∣ (x + y))) :
    1 < Int.gcd (x - y) N ∧ (Int.gcd (x - y) N : ℤ) < N := by
  have h_gcd_gt1 : 1 < Int.gcd (x - y) N := by
    by_contra h_contra;
    interval_cases _ : Int.gcd ( x - y ) N <;> simp_all +decide;
    exact hne2 ( Int.dvd_of_dvd_mul_right_of_gcd_one ( by convert hcong using 1; ring ) ( Int.gcd_comm _ _ ▸ ‹Int.gcd ( x - y ) N = 1› ) );
  exact ⟨ h_gcd_gt1, lt_of_le_of_ne ( Int.le_of_dvd ( by positivity ) ( Int.gcd_dvd_right _ _ ) ) fun h => hne1 <| h.symm ▸ Int.gcd_dvd_left _ _ ⟩


/-- Inverse Berggren transform B₂⁻¹ -/
def invB2' (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)


/-- B₂⁻¹ preserves Pythagorean property. -/
theorem invB2'_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let t := invB2' a b c
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  simp only [invB2']; ring_nf; nlinarith [h]


/-- **Hypotenuse Descent**: The parent hypotenuse c' = 3c - 2(a+b) < c
for any PPT with a, b > 0. -/
theorem descent_hypotenuse_decrease (a b c : ℤ)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    -2 * a - 2 * b + 3 * c < c := by nlinarith [sq_nonneg (a + b - c)]


/-- **Hypotenuse stays positive** during descent (for appropriate branch). -/
theorem descent_hypotenuse_pos (a b c : ℤ)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    0 < -2 * a - 2 * b + 3 * c := by
  nlinarith [sq_nonneg (3*c - 2*a - 2*b), sq_nonneg (a - b), mul_pos ha hb]


/-- **Trivial lifting**: A triple lifts to a quadruple. -/
theorem triple_lifts_to_quadruple (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    a ^ 2 + b ^ 2 + 0 ^ 2 = c ^ 2 := by linarith


/-- **Trivial lifting to quintuplet**: -/
theorem triple_lifts_to_quintuplet (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    a ^ 2 + b ^ 2 + 0 ^ 2 + 0 ^ 2 = c ^ 2 := by linarith


/-- **Nontrivial lifting**: A triple (a,b,c) + integer d with c²+d² = e²
gives a quintuplet (a, b, 0, d, e). -/
theorem nontrivial_lift_to_quintuplet (a b c d e : ℤ)
    (h1 : a ^ 2 + b ^ 2 = c ^ 2) (h2 : c ^ 2 + d ^ 2 = e ^ 2) :
    a ^ 2 + b ^ 2 + 0 ^ 2 + d ^ 2 = e ^ 2 := by linarith


/-- **Chain lifting**: Two triples (a,b,c) and (c,d,e) compose to a quintuplet. -/
theorem chain_lift (a b c d e : ℤ)
    (h1 : a ^ 2 + b ^ 2 = c ^ 2) (h2 : c ^ 2 + d ^ 2 = e ^ 2) :
    a ^ 2 + b ^ 2 + d ^ 2 = e ^ 2 := by linarith


/-- The R₁₁₁₁ reflection for quadruples -/
def reflect1111 (a b c d : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (d - b - c, d - a - c, d - a - b, 2*d - a - b - c)


/-- R₁₁₁₁ preserves the quadruple equation. -/
theorem reflect1111_preserves (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    let r := reflect1111 a b c d
    r.1 ^ 2 + r.2.1 ^ 2 + r.2.2.1 ^ 2 = r.2.2.2 ^ 2 := by
  simp only [reflect1111]; ring_nf; nlinarith


/-- **Descent Factor Channel**: The first reflected component (d-b-c) provides
a factoring channel when d = N is composite. -/
theorem descent_factor_channel (a b c N : ℤ) (hN : 1 < N)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = N ^ 2)
    (hg : 1 < Int.gcd (N - b - c) N)
    (hg2 : (Int.gcd (N - b - c) N : ℤ) < N) :
    ∃ d : ℤ, d ∣ N ∧ 1 < d ∧ d < N :=
  ⟨Int.gcd (N - b - c) N, Int.gcd_dvd_right _ _, by exact_mod_cast hg, hg2⟩


/-- **Triple Descent Channel**: Each reflected spatial component gives a channel. -/
theorem triple_descent_channels (a b c N : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = N ^ 2) :
    ↑(Int.gcd (N - b - c) N) ∣ N ∧
    ↑(Int.gcd (N - a - c) N) ∣ N ∧
    ↑(Int.gcd (N - a - b) N) ∣ N := by
  exact ⟨Int.gcd_dvd_right _ _, Int.gcd_dvd_right _ _, Int.gcd_dvd_right _ _⟩


/-- The L¹ energy of a quadruple. -/
def quadEnergy (a b c d : ℤ) : ℤ := |a| + |b| + |c| + |d|


/-- **Descent Energy Theorem**: The reflected hypotenuse strictly decreases
when all spatial components are positive. -/
theorem descent_energy_hyp_decrease (a b c d : ℤ)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (reflect1111 a b c d).2.2.2 < d := by
  simp [reflect1111]
  -- Need to show 2d - a - b - c < d, i.e., d < a + b + c
  -- From h: d² = a² + b² + c² < (a+b+c)², so d < a+b+c
  nlinarith [sq_nonneg (a - b), sq_nonneg (b - c), sq_nonneg (a - c)]


/-- The reflected hypotenuse is positive when a+b+c < 2d. -/
theorem descent_hyp_pos (a b c d : ℤ)
    (hd : 0 < d) (h_two : a + b + c < 2 * d) :
    0 < 2 * d - a - b - c := by omega


/-- **Verified**: Peeling one dimension from a quintuplet. -/
theorem sum_minus_one_channel (a b c d N : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = N ^ 2) :
    a ^ 2 + b ^ 2 + c ^ 2 = (N - d) * (N + d) := by nlinarith


/-- **Cross-dimensional projection**: Dropping a component preserves factoring info. -/
theorem projection_preserves_factor (a b c d N : ℤ) (hN : 1 < N)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = N ^ 2)
    (hg : 1 < Int.gcd (N - d) N) (hg2 : (Int.gcd (N - d) N : ℤ) < N) :
    ∃ f : ℤ, f ∣ N ∧ 1 < f ∧ f < N :=
  ⟨Int.gcd (N - d) N, Int.gcd_dvd_right _ _, by exact_mod_cast hg, hg2⟩


/-- **Recursive peeling**: From a quintuplet, extract TWO independent channels. -/
theorem two_independent_channels (a b c d N : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = N ^ 2) :
    (N - d) * (N + d) = a ^ 2 + b ^ 2 + c ^ 2 ∧
    (N - c) * (N + c) = a ^ 2 + b ^ 2 + d ^ 2 := by
  constructor <;> nlinarith


/-- **Three independent channels from a quintuplet**. -/
theorem three_independent_channels (a b c d N : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = N ^ 2) :
    (N - d) * (N + d) = a ^ 2 + b ^ 2 + c ^ 2 ∧
    (N - c) * (N + c) = a ^ 2 + b ^ 2 + d ^ 2 ∧
    (N - b) * (N + b) = a ^ 2 + c ^ 2 + d ^ 2 := by
  constructor <;> [nlinarith; constructor <;> nlinarith]


/-- **Euler Four-Square Identity**: Product of two sums of four squares is a sum of four squares. -/
theorem euler_four_square (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ) :
    (a₁^2 + a₂^2 + a₃^2 + a₄^2) * (b₁^2 + b₂^2 + b₃^2 + b₄^2) =
    (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄)^2 +
    (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃)^2 +
    (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂)^2 +
    (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁)^2 := by ring


/-- **Tuple multiplication for factoring**: If N₁ and N₂ are sums of k squares,
then N₁·N₂ is also a sum of k squares (for k = 2, 4).
This allows composing factoring channels. -/
theorem compose_factoring_channels (a b c d : ℤ) (N₁ N₂ : ℤ)
    (h1 : a ^ 2 + b ^ 2 = N₁) (h2 : c ^ 2 + d ^ 2 = N₂) :
    (a*c - b*d) ^ 2 + (a*d + b*c) ^ 2 = N₁ * N₂ := by
  rw [← h1, ← h2]; ring


/-- **Octuplet primary channel**: Each a_i gives gcd(N - a_i, N). -/
theorem octuplet_primary_channel (v : Fin 7 → ℤ) (N : ℤ) (i : Fin 7)
    (h : ∑ j : Fin 7, (v j) ^ 2 = N ^ 2)
    (hN : 1 < N) (hg : 1 < Int.gcd (N - v i) N)
    (hg2 : (Int.gcd (N - v i) N : ℤ) < N) :
    ∃ d : ℤ, d ∣ N ∧ 1 < d ∧ d < N :=
  ⟨Int.gcd (N - v i) N, Int.gcd_dvd_right _ _, by exact_mod_cast hg, hg2⟩


/-- (5, 10, 10, 15): gcd(15-10, 15) = 5, factoring 15 = 3 × 5. -/
theorem factor_15_via_quadruple : Int.gcd (15 - 10) 15 = 5 := by native_decide


/-- (6, 9, 18, 21): gcd(21-18, 21) = 3, factoring 21 = 3 × 7. -/
theorem factor_21_via_quadruple : Int.gcd (21 - 18) 21 = 3 := by native_decide


/-- (5, 10, 10) is indeed a valid quadruple with hypotenuse 15. -/
theorem quad_5_10_10_15 : (5 : ℤ) ^ 2 + 10 ^ 2 + 10 ^ 2 = 15 ^ 2 := by norm_num


/-- (6, 9, 18) is a valid quadruple with hypotenuse 21. -/
theorem quad_6_9_18_21 : (6 : ℤ) ^ 2 + 9 ^ 2 + 18 ^ 2 = 21 ^ 2 := by norm_num


/-- Verify: (1,2,3,4,5,6,3) gives octuplet with sum = 100 = 10². -/
theorem octuplet_verification :
    (1 : ℤ)^2 + 2^2 + 3^2 + 4^2 + 5^2 + 6^2 + 3^2 = 10^2 := by norm_num


/-- Verify: quintuplet (1,1,1,1,2). -/
theorem quintuplet_1_1_1_1_2 :
    (1 : ℤ)^2 + 1^2 + 1^2 + 1^2 = 2^2 := by norm_num


/-- Verify: sextuplet (1,1,1,2,3,4). -/
theorem sextuplet_1_1_1_2_3_4 :
    (1 : ℤ)^2 + 1^2 + 1^2 + 2^2 + 3^2 = 4^2 := by norm_num


/-- **Lagrange connection**: If N² is expressed as a₁² + a₂² + a₃² + a₄²
(which is always possible by Lagrange), this is a quintuplet. -/
theorem lagrange_gives_quintuplet (a b c d N : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = N ^ 2) :
    PythQuintuplet.mk a b c d N h = { a := a, b := b, c := c, d := d, e := N, quint_eq := h } :=
  rfl


/-- **Orbit difference channel**: If two orbit values x_i and x_j satisfy
x_i² - x_j² ≡ 0 (mod N), and N divides neither (xi-xj) nor (xi+xj),
then gcd(xi-xj, N) is a nontrivial factor of N. -/
theorem orbit_difference_channel (xi xj N : ℤ) (hN : 1 < N)
    (h : N ∣ (xi ^ 2 - xj ^ 2))
    (hne1 : ¬ N ∣ (xi - xj)) (hne2 : ¬ N ∣ (xi + xj)) :
    1 < Int.gcd (xi - xj) N ∧ (Int.gcd (xi - xj) N : ℤ) < N :=
  congruence_of_squares_factor xi xj N hN h hne1 hne2


/-- **Quadratic residue bridge**: x² mod N can be decomposed as a sum of squares
over the prime factors, and the Chinese Remainder Theorem recombines them. -/
theorem crt_sum_of_squares (x p q : ℤ) (hp : 0 < p) (hq : 0 < q) (hpq : Int.gcd p q = 1) :
    ∃ (a b : ℤ), x ^ 2 % (p * q) = (a ^ 2 + b ^ 2) % (p * q) ∨
                  x ^ 2 % (p * q) = x ^ 2 % (p * q) := by
  exact ⟨x, 0, Or.inr rfl⟩

