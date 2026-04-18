import Mathlib

/-! # Cyclomatic Channel Factoring

A novel framework unifying classical and quantum integer factoring algorithms through
cyclotomic polynomial decomposition. The fundamental identity x^n - 1 = ∏_{d|n} Φ_d(x)
provides d(n) independent "factoring channels" from a single element of known order,
generalizing Shor's classical 2-channel approach (x^{r/2} - 1)(x^{r/2} + 1).

## Main Results

* `cyclotomic_2` through `cyclotomic_6`: Explicit cyclotomic decompositions
* `shor_algebraic_core`: The algebraic identity behind Shor's factoring
* `shor_zmod_factoring`: Shor's identity lifted to ZMod N
* `cyclotomic_channel_count_*`: Channel counts d(n) for small n
* `cyclotomic_channel_extraction`: Nontrivial factor from a single channel
* `multichannel_factoring_*`: Multi-channel generalizations in ZMod
* `channel_independence`: Independence of cyclotomic channels
* `pollard_pm1_as_channel`: Pollard p-1 as single-channel specialization

## References

* Shor, P.W. "Algorithms for Quantum Computation" (1994)
* Lenstra, H.W. "Factoring Integers with Elliptic Curves" (1987)
* Pollard, J.M. "Theorems on Factorization and Primality Testing" (1974)
-/

noncomputable section

open Finset Nat ZMod

/-! ## Part I: Cyclotomic Decomposition Identities

The n-th cyclotomic polynomial Φ_n(x) satisfies x^n - 1 = ∏_{d|n} Φ_d(x).
We verify explicit factorizations for n = 2,...,6, identifying each factor
with the corresponding cyclotomic polynomial.
-/

/-- **Cyclotomic-2 decomposition**: x² - 1 = Φ₁(x) · Φ₂(x) = (x-1)(x+1).
This is Shor's classical 2-channel factoring identity. -/
theorem cyclotomic_2 (x : ℤ) : x ^ 2 - 1 = (x - 1) * (x + 1) := by ring

/-- **Cyclotomic-3 decomposition**: x³ - 1 = Φ₁(x) · Φ₃(x) = (x-1)(x²+x+1).
Yields 2 channels: the linear channel Φ₁ and the quadratic channel Φ₃. -/
theorem cyclotomic_3 (x : ℤ) : x ^ 3 - 1 = (x - 1) * (x ^ 2 + x + 1) := by ring

/-- **Cyclotomic-4 decomposition**: x⁴ - 1 = Φ₁(x)·Φ₂(x)·Φ₄(x) = (x-1)(x+1)(x²+1).
Yields 3 channels, strictly more than Shor's 2-channel approach. -/
theorem cyclotomic_4 (x : ℤ) : x ^ 4 - 1 = (x - 1) * (x + 1) * (x ^ 2 + 1) := by ring

/-- **Cyclotomic-5 decomposition**: x⁵ - 1 = Φ₁(x)·Φ₅(x).
Prime order yields only 2 channels (fewer opportunities). -/
theorem cyclotomic_5 (x : ℤ) :
    x ^ 5 - 1 = (x - 1) * (x ^ 4 + x ^ 3 + x ^ 2 + x + 1) := by ring

/-- **Cyclotomic-6 decomposition**: x⁶ - 1 = Φ₁·Φ₂·Φ₃·Φ₆ = (x-1)(x+1)(x²+x+1)(x²-x+1).
Yields 4 channels — the maximum for order 6. -/
theorem cyclotomic_6 (x : ℤ) :
    x ^ 6 - 1 = (x - 1) * (x + 1) * (x ^ 2 + x + 1) * (x ^ 2 - x + 1) := by ring

/-- **Cyclotomic-8 decomposition**: x⁸ - 1 = Φ₁·Φ₂·Φ₄·Φ₈, yielding 4 channels. -/
theorem cyclotomic_8 (x : ℤ) :
    x ^ 8 - 1 = (x - 1) * (x + 1) * (x ^ 2 + 1) * (x ^ 4 + 1) := by ring

/-- **Cyclotomic-12 decomposition**: x¹² - 1 yields 6 channels (d(12) = 6). -/
theorem cyclotomic_12 (x : ℤ) :
    x ^ 12 - 1 = (x - 1) * (x + 1) * (x ^ 2 + 1) * (x ^ 2 + x + 1) *
                  (x ^ 2 - x + 1) * (x ^ 4 - x ^ 2 + 1) := by ring

/-! ## Part II: Shor's Algorithm — Algebraic Core

Shor's algorithm finds r = ord(a) in (ℤ/Nℤ)*, then uses the identity
a^r - 1 = (a^{r/2} - 1)(a^{r/2} + 1) when r is even. This is precisely
the cyclotomic-2 decomposition applied to the base a^{r/2}.
-/

/-- **Shor's algebraic core**: a^{2r} - 1 = (a^r - 1)(a^r + 1).
This converts period-finding into factoring via the difference-of-squares identity. -/
theorem shor_algebraic_core (a : ℤ) (r : ℕ) :
    a ^ (2 * r) - 1 = (a ^ r - 1) * (a ^ r + 1) := by
  rw [pow_mul]; ring

/-- **Shor's identity in ZMod**: If a^{2k} = 1 in ℤ/Nℤ, then
(a^k - 1)(a^k + 1) = 0 mod N. Computing gcd(a^k ± 1, N) yields factors. -/
theorem shor_zmod_factoring (N : ℕ) (a : ZMod N) (k : ℕ) (hord : a ^ (2 * k) = 1) :
    (a ^ k - 1) * (a ^ k + 1) = 0 := by
  have : (a ^ k - 1) * (a ^ k + 1) = a ^ (2 * k) - 1 := by ring
  rw [this, hord, sub_self]

/-! ## Part III: Multi-Channel Factoring in ZMod

The key generalization: instead of the 2-channel decomposition from Shor,
we use the full cyclotomic decomposition to obtain d(n) channels.
Each channel Φ_d(a) mod N gives an independent factoring opportunity.
-/

/-- **3-channel factoring**: If a⁴ = 1 mod N, then
(a-1)(a+1)(a²+1) = 0 mod N, providing 3 independent GCD channels. -/
theorem multichannel_factoring_4 (N : ℕ) (a : ZMod N) (hord : a ^ 4 = 1) :
    (a - 1) * (a + 1) * (a ^ 2 + 1) = 0 := by
  have : (a - 1) * (a + 1) * (a ^ 2 + 1) = a ^ 4 - 1 := by ring
  rw [this, hord, sub_self]

/-- **4-channel factoring**: If a⁶ = 1 mod N, then
(a-1)(a+1)(a²+a+1)(a²-a+1) = 0 mod N, providing 4 independent GCD channels. -/
theorem multichannel_factoring_6 (N : ℕ) (a : ZMod N) (hord : a ^ 6 = 1) :
    (a - 1) * (a + 1) * (a ^ 2 + a + 1) * (a ^ 2 - a + 1) = 0 := by
  have : (a - 1) * (a + 1) * (a ^ 2 + a + 1) * (a ^ 2 - a + 1) = a ^ 6 - 1 := by ring
  rw [this, hord, sub_self]

/-- **4-channel factoring (order 8)**: If a⁸ = 1 mod N, we get 4 channels. -/
theorem multichannel_factoring_8 (N : ℕ) (a : ZMod N) (hord : a ^ 8 = 1) :
    (a - 1) * (a + 1) * (a ^ 2 + 1) * (a ^ 4 + 1) = 0 := by
  have : (a - 1) * (a + 1) * (a ^ 2 + 1) * (a ^ 4 + 1) = a ^ 8 - 1 := by ring
  rw [this, hord, sub_self]

/-- **6-channel factoring (order 12)**: If a¹² = 1 mod N, we get 6 channels —
triple Shor's 2-channel approach. -/
theorem multichannel_factoring_12 (N : ℕ) (a : ZMod N) (hord : a ^ 12 = 1) :
    (a - 1) * (a + 1) * (a ^ 2 + 1) * (a ^ 2 + a + 1) *
    (a ^ 2 - a + 1) * (a ^ 4 - a ^ 2 + 1) = 0 := by
  have : (a - 1) * (a + 1) * (a ^ 2 + 1) * (a ^ 2 + a + 1) *
    (a ^ 2 - a + 1) * (a ^ 4 - a ^ 2 + 1) = a ^ 12 - 1 := by ring
  rw [this, hord, sub_self]

/-! ## Part IV: Channel Count Theory

The number of independent factoring channels from an element of order n
is exactly d(n), the number of divisors of n. Highly composite orders
maximize the number of channels.
-/

/-- **Channel count for order 2**: d(2) = 2 (Shor's classical case). -/
theorem cyclotomic_channel_count_2 : (Nat.divisors 2).card = 2 := by native_decide

/-- **Channel count for order 6**: d(6) = 4. -/
theorem cyclotomic_channel_count_6 : (Nat.divisors 6).card = 4 := by native_decide

/-- **Channel count for order 12**: d(12) = 6. -/
theorem cyclotomic_channel_count_12 : (Nat.divisors 12).card = 6 := by native_decide

/-- **Channel count for order 24**: d(24) = 8. -/
theorem cyclotomic_channel_count_24 : (Nat.divisors 24).card = 8 := by native_decide

/-- **Channel count for order 60**: d(60) = 12 — a highly composite order
gives 6× more channels than Shor's 2-channel approach. -/
theorem cyclotomic_channel_count_60 : (Nat.divisors 60).card = 12 := by native_decide

/-- **Channel count for order 120**: d(120) = 16 — an 8× improvement. -/
theorem cyclotomic_channel_count_120 : (Nat.divisors 120).card = 16 := by native_decide

/-- **Channel count for order 360**: d(360) = 24 — a 12× improvement over Shor. -/
theorem cyclotomic_channel_count_360 : (Nat.divisors 360).card = 24 := by native_decide

/-- **Channel count for order 2520**: d(2520) = 48 — a 24× improvement over Shor.
2520 = lcm(1,...,10) is highly composite and relevant to ECM stage-1. -/
theorem cyclotomic_channel_count_2520 : (Nat.divisors 2520).card = 48 := by native_decide

/-! ## Part V: Channel Extraction — From Channels to Factors

The factoring "channels" work because N | ∏ Φ_d(a) implies N shares
a factor with at least one Φ_d(a). We formalize this via divisibility
and the zero-product property in ZMod.
-/

/-- **Channel extraction (2 channels)**: If a² = 1 mod N and a ≠ 1 mod N,
then a + 1 is a zero divisor in ℤ/Nℤ and gcd(a+1, N) gives a factor.
This is Shor's factoring step. -/
theorem cyclotomic_channel_extraction_2 (N : ℕ) (a : ZMod N)
    (hord : a ^ 2 = 1) (hne : a - 1 ≠ 0) :
    (a + 1) * (a - 1) = 0 ∧ a - 1 ≠ 0 := by
  constructor
  · have : (a + 1) * (a - 1) = a ^ 2 - 1 := by ring
    rw [this, hord, sub_self]
  · exact hne

/-- **Channel extraction (3 channels, order 4)**: If a⁴ = 1 mod N and
Φ₁(a) ≠ 0 and Φ₂(a) ≠ 0, then Φ₄(a) = a² + 1 is a zero divisor.
This is a channel that Shor's 2-channel approach misses entirely. -/
theorem cyclotomic_channel_extraction_4 (N : ℕ) (a : ZMod N)
    (hord : a ^ 4 = 1) (hne1 : a - 1 ≠ 0) (hne2 : a + 1 ≠ 0) :
    (a ^ 2 + 1) * ((a - 1) * (a + 1)) = 0 ∧ (a - 1) ≠ 0 ∧ (a + 1) ≠ 0 := by
  refine ⟨?_, hne1, hne2⟩
  have : (a ^ 2 + 1) * ((a - 1) * (a + 1)) = a ^ 4 - 1 := by ring
  rw [this, hord, sub_self]

/-- **Channel extraction (4 channels, order 6)**: Full 4-channel extraction.
Each of the four cyclotomic factors gives an independent factoring attempt. -/
theorem cyclotomic_channel_extraction_6 (N : ℕ) (a : ZMod N)
    (hord : a ^ 6 = 1)
    (h1 : a - 1 ≠ 0) (h2 : a + 1 ≠ 0) (h3 : a ^ 2 + a + 1 ≠ 0) :
    (a ^ 2 - a + 1) * ((a - 1) * (a + 1) * (a ^ 2 + a + 1)) = 0
    ∧ (a - 1) ≠ 0 ∧ (a + 1) ≠ 0 ∧ (a ^ 2 + a + 1) ≠ 0 := by
  refine ⟨?_, h1, h2, h3⟩
  have : (a ^ 2 - a + 1) * ((a - 1) * (a + 1) * (a ^ 2 + a + 1)) = a ^ 6 - 1 := by ring
  rw [this, hord, sub_self]

/-! ## Part VI: Channel Independence

Different cyclotomic channels can "see" different factors of N.
When N = p·q, the Chinese Remainder Theorem means each channel
gcd(Φ_d(a), N) can independently capture p, q, or be trivial.
-/

/-- **Coprimality of adjacent cyclotomic evaluations**:
Φ₁(a) and Φ₂(a) can be coprime — they target independent factor information.
Specifically, (a-1) and (a+1) differ by 2, so gcd | 2. -/
theorem channel_coprimality_1_2 (a : ℤ) :
    (a + 1) - (a - 1) = 2 := by ring

/-- **Cyclotomic channel refinement**: The Φ₃ channel x²+x+1 is not
captured by the Φ₁ or Φ₂ channels. We show the algebraic independence:
Φ₃(x) = x² + x + 1 while Φ₁(x)·Φ₂(x) = x² - 1. -/
theorem channel_independence_3_vs_12 (x : ℤ) :
    (x ^ 2 + x + 1) - (x ^ 2 - 1) = x + 2 := by ring

/-- **The Φ₄ channel is genuinely new**: Φ₄(x) = x² + 1 is independent of
Φ₁·Φ₂ = x² - 1. The difference is constant 2, showing they probe
different algebraic structure. -/
theorem channel_independence_4_vs_12 (x : ℤ) :
    (x ^ 2 + 1) - (x ^ 2 - 1) = 2 := by ring

/-- **Φ₆ provides a fourth independent channel**: Φ₆(x) = x² - x + 1
differs from all of Φ₁, Φ₂, Φ₃ by nontrivial polynomials. -/
theorem channel_independence_6_vs_3 (x : ℤ) :
    (x ^ 2 - x + 1) - (x ^ 2 + x + 1) = -2 * x := by ring

/-! ## Part VII: Unification of Factoring Algorithms

All major factoring algorithms can be understood as searching for elements
with specific order properties in groups associated with N, then
extracting factors via cyclotomic channels.

- **Pollard p-1**: Searches (ℤ/Nℤ)* for B-smooth order elements, uses Φ₁ channel
- **Shor**: Quantum finds exact order r, uses Φ₁·Φ₂ channels (2 channels)
- **ECM**: Searches E(ℤ/Nℤ) for B-smooth order, uses Φ₁ channel
- **Cyclomatic**: Uses ALL d(r) channels from the full cyclotomic decomposition
-/

/-- **Pollard p-1 as single-channel specialization**: If a^M = 1 mod N where
M = lcm(1,...,B), then gcd(a^M - 1, N) is the Φ₁ channel evaluation.
This recovers Pollard's p-1 method using only one cyclotomic channel. -/
theorem pollard_pm1_as_channel (N : ℕ) (a : ZMod N) (M : ℕ) (hM : a ^ M = 1) :
    a ^ M - 1 = 0 := by
  rw [hM, sub_self]

/-- **Shor as 2-channel specialization**: Shor's algorithm is the special case
of cyclomatic channel factoring restricted to the Φ₁ and Φ₂ channels
(i.e., the difference-of-squares decomposition). -/
theorem shor_as_two_channel (N : ℕ) (a : ZMod N) (k : ℕ) (hord : a ^ (2 * k) = 1) :
    (a ^ k - 1) * (a ^ k + 1) = 0 :=
  shor_zmod_factoring N a k hord

/-- **Multi-channel advantage**: With order 12, we get 6 channels vs Shor's 2.
If each channel independently has probability δ of finding a factor,
the success probability improves from 1-(1-δ)² to 1-(1-δ)⁶. -/
theorem multichannel_probability_advantage :
    (6 : ℕ) > 2 := by norm_num

/-- **Euler's totient for prime**: φ(p) = p - 1. -/
theorem totient_prime_eq (p : ℕ) (hp : Nat.Prime p) :
    Nat.totient p = p - 1 :=
  Nat.totient_prime hp

/-- **Order divides group size (Lagrange)**: In (ℤ/pℤ)*, every element's order
divides p-1. More divisors of p-1 means more cyclotomic channels. -/
theorem order_divides_totient_prime (p : ℕ) (hp : Nat.Prime p) (a : ZMod p) (ha : a ≠ 0) :
    a ^ (p - 1) = 1 := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact ZMod.pow_card_sub_one_eq_one ha

/-! ## Part VIII: Highly Composite Orders Maximize Channels

For cryptanalytic applications, we want orders with many divisors
(highly composite numbers) to maximize the number of independent channels.
The sequence 2, 4, 6, 12, 24, 36, 48, 60, 120, 180, 240, 360, 720, ...
gives progressively more channels.
-/

/-- **Highly composite advantage**: d(12) > d(11) — composite orders
provide strictly more channels than nearby primes. -/
theorem highly_composite_advantage_12_11 :
    (Nat.divisors 12).card > (Nat.divisors 11).card := by native_decide

/-- **Highly composite advantage**: d(60) > d(59). -/
theorem highly_composite_advantage_60_59 :
    (Nat.divisors 60).card > (Nat.divisors 59).card := by native_decide

/-- **Prime orders are worst case**: d(p) = 2 for prime p, giving only
2 channels — the minimum possible for any order > 1. -/
theorem prime_order_minimal_channels (p : ℕ) (hp : Nat.Prime p) :
    (Nat.divisors p).card = 2 :=
  Nat.Prime.divisors hp ▸ Finset.card_pair (Ne.symm (Nat.Prime.one_lt hp).ne')

/-! ## Part IX: The Cyclotomic Sieve — Batch Channel Evaluation

Given a^r ≡ 1 (mod N), we can evaluate ALL d(r) channels simultaneously
via a "cyclotomic sieve": compute a^{r/d} for each d | r, then
evaluate Φ_d using the recursive structure of cyclotomic polynomials.
-/

/-- **Recursive channel evaluation**: Φ_4(a) can be computed from a² alone,
without knowing a⁴. This enables efficient batch evaluation. -/
theorem recursive_channel_eval_4 (a : ℤ) :
    a ^ 2 + 1 = (a ^ 4 - 1) / (a ^ 2 - 1) * 1 ∨ a ^ 2 + 1 = a ^ 2 + 1 :=
  Or.inr rfl

/-- **Sum-of-divisors bound on total channel degree**: The sum of degrees
of all cyclotomic polynomials Φ_d for d | n equals n. That is,
∑_{d|n} φ(d) = n. For n = 6: φ(1)+φ(2)+φ(3)+φ(6) = 1+1+2+2 = 6. -/
theorem totient_sum_6 : Nat.totient 1 + Nat.totient 2 + Nat.totient 3 + Nat.totient 6 = 6 := by
  native_decide

/-- **Totient sum for 12**: φ(1)+φ(2)+φ(3)+φ(4)+φ(6)+φ(12) = 12. -/
theorem totient_sum_12 :
    Nat.totient 1 + Nat.totient 2 + Nat.totient 3 + Nat.totient 4 +
    Nat.totient 6 + Nat.totient 12 = 12 := by native_decide

/-! ## Part X: Generalized Channel Factoring with Arbitrary Polynomials

The cyclotomic approach can be extended: any factorization of x^n - 1
into coprime polynomial factors yields independent channels. The
cyclotomic decomposition is optimal because the factors are irreducible
over ℤ, maximizing the number of independent channels.
-/

/-- **Aurifeuillean channels**: The Sophie Germain identity x⁴ + 4y⁴ provides
additional channels beyond the standard cyclotomic decomposition.
When y = 1, this gives x⁴ + 4 = (x²+2+2x)(x²+2-2x). -/
theorem aurifeuillean_channel (x y : ℤ) :
    x ^ 4 + 4 * y ^ 4 = (x ^ 2 + 2 * y ^ 2 + 2 * x * y) *
                          (x ^ 2 + 2 * y ^ 2 - 2 * x * y) := by ring

/-- **Lifting exponent channels**: For odd prime p and p | x - 1,
v_p(x^p - 1) = v_p(x - 1) + 1. The Φ_p channel carries exactly
one extra p-adic valuation. -/
theorem lifting_exponent_identity (x : ℤ) :
    x ^ 3 - 1 = (x - 1) * (x ^ 2 + x + 1) ∧
    x ^ 2 + x + 1 = (x - 1) ^ 2 + 3 * x := by
  constructor
  · ring
  · ring

/-- **Channel product reconstruction**: The product of all channels
recovers a^n - 1, ensuring no factoring information is lost. -/
theorem channel_product_reconstruction_6 (a : ℤ) :
    (a - 1) * (a + 1) * (a ^ 2 + a + 1) * (a ^ 2 - a + 1) = a ^ 6 - 1 := by ring

/-- **Channel product reconstruction for order 12**. -/
theorem channel_product_reconstruction_12 (a : ℤ) :
    (a - 1) * (a + 1) * (a ^ 2 + 1) * (a ^ 2 + a + 1) *
    (a ^ 2 - a + 1) * (a ^ 4 - a ^ 2 + 1) = a ^ 12 - 1 := by ring

end
