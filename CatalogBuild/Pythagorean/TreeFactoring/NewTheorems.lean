/-! # CatalogBuild.Pythagorean.TreeFactoring.NewTheorems

Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 44
-/

import Mathlib

/-- **Triple Channel Product**: The product of the three channel "left factors"
(d-a)(d-b)(d-c) has a specific expansion in terms of the quadruple. -/
theorem triple_channel_left_product (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (d - a) * (d - b) * (d - c) =
    d^3 - d^2*(a+b+c) + d*(a*b + a*c + b*c) - a*b*c := by
  ring


/-- **Triple Channel Right Product**: Similarly for (d+a)(d+b)(d+c). -/
theorem triple_channel_right_product (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (d + a) * (d + b) * (d + c) =
    d^3 + d^2*(a+b+c) + d*(a*b + a*c + b*c) + a*b*c := by
  ring


/-- **Channel Product Identity**: The product of all six channel factors
(d-a)(d+a)(d-b)(d+b)(d-c)(d+c) relates to a product of sums of squares. -/
theorem full_channel_product (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (d - a) * (d + a) * ((d - b) * (d + b)) * ((d - c) * (d + c)) =
    (b^2 + c^2) * (a^2 + c^2) * (a^2 + b^2) := by
  have h1 : (d - a) * (d + a) = b^2 + c^2 := by nlinarith
  have h2 : (d - b) * (d + b) = a^2 + c^2 := by nlinarith
  have h3 : (d - c) * (d + c) = a^2 + b^2 := by nlinarith
  rw [h1, h2, h3]


/-- **Channel Sum**: Sum of all three channels equals 2d². -/
theorem channel_sum_eq_2d_sq (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (a^2 + b^2) + (a^2 + c^2) + (b^2 + c^2) = 2 * d ^ 2 := by
  linarith


/-- **Channel Independence Constraint**: Any one channel value determines the
remaining two up to a single free parameter. Specifically, if we know
channel 1 = a²+b² and channel 2 = a²+c², then channel 3 = 2d² - (a²+b²) - (a²+c²). -/
theorem channel_determined (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    b^2 + c^2 = 2 * d^2 - (a^2 + b^2) - (a^2 + c^2) := by
  linarith


/-- **Cross-Channel GCD Lemma**: For a prime p, if p divides two different
channel values (a²+b²) and (a²+c²), then p divides (b²-c²). -/
theorem cross_channel_gcd_prime (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (p : ℤ) (hp : p ∣ (a^2 + b^2)) (hp2 : p ∣ (a^2 + c^2)) :
    p ∣ (b^2 - c^2) := by
  have : b^2 - c^2 = (a^2 + b^2) - (a^2 + c^2) := by ring
  rw [this]
  exact dvd_sub hp hp2


/-- **Factor Cascade**: If p | (b²-c²) = (b-c)(b+c) and p is prime, then
p | (b-c) or p | (b+c), giving direct information about b,c mod p. -/
theorem factor_cascade (b c p : ℤ) (hp : Prime p) (hdvd : p ∣ (b^2 - c^2)) :
    p ∣ (b - c) ∨ p ∣ (b + c) := by
  have : b^2 - c^2 = (b - c) * (b + c) := by ring
  rw [this] at hdvd
  exact hp.dvd_or_dvd hdvd


/-- **Dual Channel Factor**: If p divides both channel 1 and channel 3,
then p divides (a²-c²). -/
theorem dual_channel_factor (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (p : ℤ) (hp1 : p ∣ (a^2 + b^2)) (hp3 : p ∣ (b^2 + c^2)) :
    p ∣ (a^2 - c^2) := by
  have : a^2 - c^2 = (a^2 + b^2) - (b^2 + c^2) := by ring
  rw [this]
  exact dvd_sub hp1 hp3


/-- **Quadruple Scaling Preserves Channels**: Scaling (a,b,c,d) → (ka,kb,kc,kd)
multiplies each channel value by k². -/
theorem scaling_channels (a b c d k : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    (k*a)^2 + (k*b)^2 = k^2 * (a^2 + b^2) := by ring


/-- **Product Quadruple from d-values**: If (a₁,b₁,c₁,d₁) and (a₂,b₂,c₂,d₂) are
quadruples, then d₁²·d₂² = (d₁·d₂)², and we can build a new quadruple
via scaling. The product d₁·d₂ inherits factors from both. -/
theorem product_d_factoring (d₁ d₂ : ℤ) :
    (d₁ * d₂) ^ 2 = d₁ ^ 2 * d₂ ^ 2 := by ring


/-- **Mod-p Fingerprint**: For a prime p | d, the triple (a mod p, b mod p, c mod p)
satisfies a² + b² + c² ≡ 0 (mod p²). This constrains the point to a conic mod p. -/
theorem mod_p_fingerprint (a b c d p : ℤ) (h : a^2 + b^2 + c^2 = d^2)
    (hp : p ∣ d) : p^2 ∣ (a^2 + b^2 + c^2) := by
  rw [h]; exact pow_dvd_pow_of_dvd hp 2


/-- **Fingerprint Compatibility**: Two quadruples with the same d have
compatible mod-p fingerprints: both satisfy the same conic equation mod p. -/
theorem fingerprint_compatibility (a₁ b₁ c₁ a₂ b₂ c₂ d p : ℤ)
    (h₁ : a₁^2 + b₁^2 + c₁^2 = d^2)
    (h₂ : a₂^2 + b₂^2 + c₂^2 = d^2)
    (hp : p ∣ d) :
    p^2 ∣ (a₁^2 + b₁^2 + c₁^2) ∧ p^2 ∣ (a₂^2 + b₂^2 + c₂^2) := by
  exact ⟨mod_p_fingerprint a₁ b₁ c₁ d p h₁ hp,
         mod_p_fingerprint a₂ b₂ c₂ d p h₂ hp⟩


/-- **Fingerprint Difference**: The difference of fingerprints is divisible by p². -/
theorem fingerprint_difference (a₁ b₁ c₁ a₂ b₂ c₂ d p : ℤ)
    (h₁ : a₁^2 + b₁^2 + c₁^2 = d^2)
    (h₂ : a₂^2 + b₂^2 + c₂^2 = d^2)
    (hp : p ∣ d) :
    p^2 ∣ ((a₁^2 + b₁^2 + c₁^2) - (a₂^2 + b₂^2 + c₂^2)) := by
  have : (a₁^2 + b₁^2 + c₁^2) - (a₂^2 + b₂^2 + c₂^2) = 0 := by linarith
  simp [this]


/-- A Pythagorean quintuple is (a,b,c,d,e) with a²+b²+c²+d² = e². -/
structure PythagoreanQuintuple where
  a : ℤ
  b : ℤ
  c : ℤ
  d : ℤ
  e : ℤ
  quint_eq : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = e ^ 2


/-- **Six Channels for Quintuples**: Each quintuple gives six channel values
(one for each pair of the four spatial components). -/
theorem quint_channel_ab (q : PythagoreanQuintuple) :
    (q.e - q.a) * (q.e + q.a) = q.b^2 + q.c^2 + q.d^2 := by
  have := q.quint_eq; nlinarith


/-- [Section: # CatalogBuild.Pythagorean.TreeFactoring.NewTheorems
Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 44] -/
theorem quint_channel_cd (q : PythagoreanQuintuple) :
    (q.e - q.c) * (q.e + q.c) = q.a^2 + q.b^2 + q.d^2 := by
  have := q.quint_eq; nlinarith


/-- **Quintuple Channel Sum**: Sum of all four single-variable channels = 3e². -/
theorem quint_channel_sum (a b c d e : ℤ) (h : a^2 + b^2 + c^2 + d^2 = e^2) :
    (b^2+c^2+d^2) + (a^2+c^2+d^2) + (a^2+b^2+d^2) + (a^2+b^2+c^2) = 3 * e^2 := by
  linarith


/-- **Quintuple Pair Channels**: Removing two components gives a sum of two squares.
There are C(4,2) = 6 such channels. -/
theorem quint_pair_channel_ab (a b c d e : ℤ) (h : a^2 + b^2 + c^2 + d^2 = e^2) :
    (e^2 - a^2 - b^2) = c^2 + d^2 := by linarith


/-- [Section: # CatalogBuild.Pythagorean.TreeFactoring.NewTheorems
Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 44] -/
theorem quint_pair_channel_ac (a b c d e : ℤ) (h : a^2 + b^2 + c^2 + d^2 = e^2) :
    (e^2 - a^2 - c^2) = b^2 + d^2 := by linarith


/-- [Section: # CatalogBuild.Pythagorean.TreeFactoring.NewTheorems
Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 44] -/
theorem quint_pair_channel_ad (a b c d e : ℤ) (h : a^2 + b^2 + c^2 + d^2 = e^2) :
    (e^2 - a^2 - d^2) = b^2 + c^2 := by linarith


theorem quint_pair_channel_bc (a b c d e : ℤ) (h : a^2 + b^2 + c^2 + d^2 = e^2) :
    (e^2 - b^2 - c^2) = a^2 + d^2 := by linarith


theorem quint_pair_channel_bd (a b c d e : ℤ) (h : a^2 + b^2 + c^2 + d^2 = e^2) :
    (e^2 - b^2 - d^2) = a^2 + c^2 := by linarith


theorem quint_pair_channel_cd (a b c d e : ℤ) (h : a^2 + b^2 + c^2 + d^2 = e^2) :
    (e^2 - c^2 - d^2) = a^2 + b^2 := by linarith


/-- **Six-Channel Sum for Quintuples**: The sum of all six pair channels = 3e². -/
theorem quint_six_channel_sum (a b c d e : ℤ) (h : a^2 + b^2 + c^2 + d^2 = e^2) :
    (c^2+d^2) + (b^2+d^2) + (b^2+c^2) + (a^2+d^2) + (a^2+c^2) + (a^2+b^2) = 3 * e^2 := by
  linarith


theorem primitive_parity (a b c d : ℤ)
    (h : a^2 + b^2 + c^2 = d^2)
    (ha : 2 ∣ a) (hb : 2 ∣ b) (hc : 2 ∣ c) :
    2 ∣ d := by
  exact Int.prime_two.dvd_of_dvd_pow ( h ▸ dvd_add ( dvd_add ( dvd_pow ha two_ne_zero ) ( dvd_pow hb two_ne_zero ) ) ( dvd_pow hc two_ne_zero ) )


/-- **Two Quadruples Factor Extraction**: Given two quadruples (a₁,b₁,c₁,d) and
(a₂,b₂,c₂,d), the value gcd(d-c₁, d-c₂) divides d when c₁ ≢ c₂ (mod d). -/
theorem two_quad_gcd_divides (c₁ c₂ d : ℤ) :
    ∃ k : ℤ, (d - c₁) - (d - c₂) = c₂ - c₁ := by
  exact ⟨1, by ring⟩


/-- **The difference d-c₁ and d-c₂ share a gcd that divides c₂-c₁.**
Key insight: gcd(d-c₁, d-c₂) | (c₂-c₁), so if we know factors
of c₂-c₁, we constrain gcd(d-c₁, d-c₂). -/
theorem cross_rep_gcd_constraint (c₁ c₂ d g : ℤ)
    (hg1 : g ∣ (d - c₁)) (hg2 : g ∣ (d - c₂)) :
    g ∣ (c₂ - c₁) := by
  have : c₂ - c₁ = (d - c₁) - (d - c₂) := by ring
  rw [this]
  exact dvd_sub hg1 hg2


theorem no_balanced_quadruple (a d : ℤ) (ha : a ≠ 0)
    (h : a^2 + a^2 + a^2 = d^2) : False := by
  have h3 : 3 * a^2 = d^2 := by linarith
  -- 3 * a² = d² implies 3 | d, say d = 3k, then 3a² = 9k², so a² = 3k²
  -- Then 3 | a, say a = 3m, then 9m² = 3k², so 3m² = k². Infinite descent.
  -- From $3 * a^2 = d^2$, we get that $d = \pm a\sqrt{3}$.
  have hd : d = a * Real.sqrt 3 ∨ d = -a * Real.sqrt 3 := by
    exact or_iff_not_imp_left.mpr fun h => mul_left_cancel₀ ( sub_ne_zero_of_ne h ) <| by ring_nf; norm_num; norm_cast; linarith;
  obtain hd | hd := hd <;> [ exact Nat.Prime.irrational_sqrt ( by norm_num : Nat.Prime 3 ) ⟨ d / a, by norm_num [ *, mul_div_cancel_left₀ ] ⟩ ; exact Nat.Prime.irrational_sqrt ( by norm_num : Nat.Prime 3 ) ⟨ -d / a, by norm_num [ *, mul_div_cancel_left₀ ] ⟩ ]


/-- **Near-Balanced Channels**: When two components are equal (a = b),
we get 2a² + c² = d², i.e., (d-c)(d+c) = 2a². -/
theorem near_balanced_channel (a c d : ℤ)
    (h : a^2 + a^2 + c^2 = d^2) :
    (d - c) * (d + c) = 2 * a^2 := by nlinarith


/-- **Pell Connection**: The near-balanced case 2a² + c² = d² is a generalized Pell equation.
When c = 1, 2a² + 1 = d² ↔ d² - 2a² = 1, which is the Pell equation for √2. -/
theorem pell_connection (a d : ℤ) (h : a^2 + a^2 + 1 = d^2) :
    d^2 - 2 * a^2 = 1 := by linarith


/-- **Three-Rep Extraction**: Given three representations of d², we get
three pairs of channel values. The pairwise GCDs form a lattice
that constrains d's factorization.
Key identity: if (a₁,b₁,c₁,d) and (a₂,b₂,c₂,d) are quadruples, then
(d-c₁)(d+c₁) = a₁²+b₁² and (d-c₂)(d+c₂) = a₂²+b₂², so
(d-c₁)(d+c₁) - (d-c₂)(d+c₂) = (a₁²+b₁²) - (a₂²+b₂²). -/
theorem three_rep_difference (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h₁ : a₁^2 + b₁^2 + c₁^2 = d^2)
    (h₂ : a₂^2 + b₂^2 + c₂^2 = d^2) :
    (a₁^2 + b₁^2) - (a₂^2 + b₂^2) = c₂^2 - c₁^2 := by
  linarith


/-- **Channel-Cross Product**: For two quadruples with the same d,
(d-c₁)(d+c₁)(d-c₂)(d+c₂) = (a₁²+b₁²)(a₂²+b₂²), which by
Brahmagupta-Fibonacci can be written as a sum of two squares in two ways.
This gives FOUR difference-of-squares factorizations from just two quadruples. -/
theorem channel_cross_product (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h₁ : a₁^2 + b₁^2 + c₁^2 = d^2)
    (h₂ : a₂^2 + b₂^2 + c₂^2 = d^2) :
    (d - c₁) * (d + c₁) * ((d - c₂) * (d + c₂)) =
    (a₁^2 + b₁^2) * (a₂^2 + b₂^2) := by
  have hc1 : (d - c₁) * (d + c₁) = a₁^2 + b₁^2 := by nlinarith
  have hc2 : (d - c₂) * (d + c₂) = a₂^2 + b₂^2 := by nlinarith
  rw [hc1, hc2]


/-- **Brahmagupta Dual Representations from Two Quadruples**: The cross-product
(a₁²+b₁²)(a₂²+b₂²) equals both (a₁a₂-b₁b₂)²+(a₁b₂+b₁a₂)² and
(a₁a₂+b₁b₂)²+(a₁b₂-b₁a₂)². The difference between these two representations
is 2·(a₁a₂)(b₁b₂) - (-2·a₁a₂·b₁b₂) = 4a₁a₂b₁b₂, which is related to
the product of the four original components. -/
theorem brahmagupta_cross_factoring (a₁ b₁ a₂ b₂ : ℤ) :
    (a₁*a₂ - b₁*b₂)^2 + (a₁*b₂ + b₁*a₂)^2 -
    ((a₁*a₂ + b₁*b₂)^2 + (a₁*b₂ - b₁*a₂)^2) = 0 := by ring


/-- **Multi-Channel Congruence**: If p is an odd prime dividing d,
and (a,b,c,d) is a quadruple, then from channel 1:
p | (d-c) or p | (d+c). Combined with p | d, this gives p | c or p | c.
More precisely: p | d and p | (d±c) implies p | c. -/
theorem multi_channel_congruence_c (c d p : ℤ)
    (hp_d : p ∣ d) (hp_dc : p ∣ (d - c)) :
    p ∣ c := by
  have : c = d - (d - c) := by ring
  rw [this]
  exact dvd_sub hp_d hp_dc


theorem multi_channel_congruence_c' (c d p : ℤ)
    (hp_d : p ∣ d) (hp_dc : p ∣ (d + c)) :
    p ∣ c := by
  have : c = (d + c) - d := by ring
  rw [this]
  exact dvd_sub hp_dc hp_d


/-- **Strengthened Factor Dichotomy**: If p | d and p is prime, then for
channel 1, we know p² | (d-c)(d+c) = a²+b². Since p | d, we have:
- If p | c: then p | (d-c) AND p | (d+c), so p² | (d-c)(d+c)
- If p ∤ c: then p ∤ (d-c) and p ∤ (d+c), but p² | (d-c)(d+c) -/
theorem strengthened_dichotomy (a b c d p : ℤ)
    (h : a^2 + b^2 + c^2 = d^2)
    (hp : p ∣ d) (hpc : p ∣ c) :
    p ∣ (d - c) ∧ p ∣ (d + c) := by
  exact ⟨dvd_sub hp hpc, dvd_add hp hpc⟩


/-- **Norm Map**: Define N(a,b,c) = a²+b²+c² as the "quadruple norm".
A Pythagorean quadruple is an integer point where N(a,b,c) is a perfect square. -/
def quadNorm (a b c : ℤ) : ℤ := a^2 + b^2 + c^2


/-- **Norm is non-negative**. -/
theorem quadNorm_nonneg (a b c : ℤ) : 0 ≤ quadNorm a b c := by
  unfold quadNorm
  positivity


/-- **Norm multiplicativity under scaling**. -/
theorem quadNorm_scaling (a b c k : ℤ) :
    quadNorm (k*a) (k*b) (k*c) = k^2 * quadNorm a b c := by
  unfold quadNorm; ring


/-- **Norm of sum**: N(a₁+a₂, b₁+b₂, c₁+c₂) expands with cross terms. -/
theorem quadNorm_sum (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ) :
    quadNorm (a₁+a₂) (b₁+b₂) (c₁+c₂) =
    quadNorm a₁ b₁ c₁ + quadNorm a₂ b₂ c₂ +
    2*(a₁*a₂ + b₁*b₂ + c₁*c₂) := by
  unfold quadNorm; ring


/-- **Representation Inner Product**: For two quadruples with the same d,
define their inner product as a₁a₂ + b₁b₂ + c₁c₂. -/
def repInnerProduct (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ) : ℤ :=
  a₁*a₂ + b₁*b₂ + c₁*c₂


theorem inner_product_sq_bound (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h₁ : a₁^2 + b₁^2 + c₁^2 = d^2)
    (h₂ : a₂^2 + b₂^2 + c₂^2 = d^2) :
    (repInnerProduct a₁ b₁ c₁ a₂ b₂ c₂)^2 ≤ d^2 * d^2 := by
  rw [ repInnerProduct ];
  nlinarith only [ sq_nonneg ( a₁ * b₂ - a₂ * b₁ ), sq_nonneg ( a₁ * c₂ - a₂ * c₁ ), sq_nonneg ( b₁ * c₂ - b₂ * c₁ ), h₁, h₂ ]


/-- **Difference Norm via Inner Product**: ‖v₁-v₂‖² = 2d² - 2⟨v₁,v₂⟩. -/
theorem diff_norm_from_inner (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h₁ : a₁^2 + b₁^2 + c₁^2 = d^2)
    (h₂ : a₂^2 + b₂^2 + c₂^2 = d^2) :
    quadNorm (a₁-a₂) (b₁-b₂) (c₁-c₂) =
    2 * d^2 - 2 * repInnerProduct a₁ b₁ c₁ a₂ b₂ c₂ := by
  unfold quadNorm repInnerProduct; nlinarith


/-- **Factor Orbit Lattice**: Points (a,b,c) on the d-sphere with p | gcd(a,b,c)
lie on a sub-lattice of index p³ in ℤ³. We can write a = pa', b = pb', c = pc',
and then p²(a'²+b'²+c'²) = d², so p | d and (a',b',c',d/p) is a quadruple. -/
theorem factor_orbit_reduction (a b c d p : ℤ) (hp : p ≠ 0)
    (h : a^2 + b^2 + c^2 = d^2)
    (ha : p ∣ a) (hb : p ∣ b) (hc : p ∣ c) :
    ∃ a' b' c', a = p * a' ∧ b = p * b' ∧ c = p * c' ∧
    p^2 * (a'^2 + b'^2 + c'^2) = d^2 := by
  obtain ⟨a', rfl⟩ := ha
  obtain ⟨b', rfl⟩ := hb
  obtain ⟨c', rfl⟩ := hc
  exact ⟨a', b', c', rfl, rfl, rfl, by nlinarith⟩


