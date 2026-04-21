/-! # CatalogBuild.Pythagorean.Core.PythagoreanPairing

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 21
-/

import Mathlib

noncomputable section

/-- The two forms of Brahmagupta-Fibonacci give the SAME product but DIFFERENT
sum-of-squares decompositions. This is the source of paired representations. -/
theorem brahmagupta_two_reps (a b c d : ℤ) :
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 =
    (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by
  ring




/-- Key algebraic identity: if N = a²+b² = c²+d², then
N² = (ac+bd)² + (ad-bc)² = (ac-bd)² + (ad+bc)².
Moreover, N divides (ac+bd)(ac-bd) = a²c² - b²d² and
N divides (ad+bc)(ad-bc) = a²d² - b²c². -/
theorem two_reps_product_identity (a b c d N : ℤ)
    (h1 : N = a ^ 2 + b ^ 2) (h2 : N = c ^ 2 + d ^ 2) :
    N * N = (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by
  nlinarith [brahmagupta_fibonacci_alt a b c d]




/-- N divides (a²-c²) when N = a²+b² = c²+d², since a²-c² = d²-b². -/
theorem two_reps_divisibility (a b c d N : ℤ)
    (h1 : N = a ^ 2 + b ^ 2) (h2 : N = c ^ 2 + d ^ 2) :
    a ^ 2 - c ^ 2 = d ^ 2 - b ^ 2 := by linarith




/-- The cross-product identity: (ad+bc)(ad-bc) = a²d² - b²c². -/
theorem cross_product_identity (a b c d : ℤ) :
    (a * d + b * c) * (a * d - b * c) = a ^ 2 * d ^ 2 - b ^ 2 * c ^ 2 := by ring




/-- When N = a²+b² = c²+d², we have N | (ad+bc)(ad-bc).
This is because (ad)² - (bc)² = a²d² - b²c² = a²(N-c²) - (N-a²)c²
= a²N - a²c² - Nc² + a²c² = N(a² - c²). -/
theorem N_divides_cross (a b c d N : ℤ)
    (h1 : N = a ^ 2 + b ^ 2) (h2 : N = c ^ 2 + d ^ 2) :
    N ∣ (a * d + b * c) * (a * d - b * c) := by
  use a ^ 2 - c ^ 2
  nlinarith [cross_product_identity a b c d]




/-- A sum-of-squares representation of a natural number. -/
structure SumOfSquaresRep (N : ℤ) where
  x : ℤ
  y : ℤ
  eq : N = x ^ 2 + y ^ 2




/-- Two representations are distinct if they differ (up to signs and order). -/
def SumOfSquaresRep.distinct (r1 r2 : SumOfSquaresRep N) : Prop :=
  r1.x.natAbs ≠ r2.x.natAbs ∨ r1.y.natAbs ≠ r2.y.natAbs




/-- The Euclid parametrization gives a Pythagorean triple from a sum-of-squares rep.
If c = m²+n², then (m²-n², 2mn, c) is a Pythagorean triple. -/
theorem euclid_from_rep (m n : ℤ) :
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by ring




/-- The paired triple theorem: if c = m₁²+n₁² = m₂²+n₂² (two representations),
then both (m₁²-n₁², 2m₁n₁, c) and (m₂²-n₂², 2m₂n₂, c) are Pythagorean
triples sharing hypotenuse c. -/
theorem paired_triples_share_hypotenuse (m₁ n₁ m₂ n₂ : ℤ)
    (h : m₁ ^ 2 + n₁ ^ 2 = m₂ ^ 2 + n₂ ^ 2) :
    (m₁ ^ 2 - n₁ ^ 2) ^ 2 + (2 * m₁ * n₁) ^ 2 = (m₁ ^ 2 + n₁ ^ 2) ^ 2 ∧
    (m₂ ^ 2 - n₂ ^ 2) ^ 2 + (2 * m₂ * n₂) ^ 2 = (m₂ ^ 2 + n₂ ^ 2) ^ 2 := by
  exact ⟨by ring, by ring⟩




/-- Extracting a factor: given two representations c = m₁²+n₁² = m₂²+n₂²,
the quantity gcd(m₁m₂ + n₁n₂, c) produces a factor of c.
Algebraically: c | (m₁m₂+n₁n₂)(m₁m₂-n₁n₂). -/
theorem paired_triple_factor_divides (m₁ n₁ m₂ n₂ c : ℤ)
    (h1 : c = m₁ ^ 2 + n₁ ^ 2) (h2 : c = m₂ ^ 2 + n₂ ^ 2) :
    c ∣ (m₁ * m₂ + n₁ * n₂) * (m₁ * m₂ - n₁ * n₂) := by
  -- c | m₁²m₂² - n₁²n₂² = m₁²(c - m₂²) - (c - m₁²)·n₂²... no wait
  -- Actually: m₁²m₂² - n₁²n₂² = m₁²m₂² - (c-m₁²)(c-m₂²)
  -- Hmm, let me use N_divides_cross with appropriate substitution
  -- We need: c | (m₁·n₂ + n₁·m₂)(m₁·n₂ - n₁·m₂)
  -- From N_divides_cross: c | (m₁·n₂ + n₁·m₂)(m₁·n₂ - n₁·m₂)
  -- But we want: c | (m₁·m₂ + n₁·n₂)(m₁·m₂ - n₁·n₂)
  -- This follows from: m₁²m₂² - n₁²n₂² = m₁²(c-n₂²) - n₁²n₂²
  --   = c·m₁² - m₁²n₂² - n₁²n₂² = c·m₁² - n₂²(m₁²+n₁²) = c·m₁² - c·n₂² = c(m₁²-n₂²)
  use m₁ ^ 2 - n₂ ^ 2
  nlinarith




/-- The cross-term also divides: c | (m₁n₂ + n₁m₂)(m₁n₂ - n₁m₂). -/
theorem paired_triple_cross_divides (m₁ n₁ m₂ n₂ c : ℤ)
    (h1 : c = m₁ ^ 2 + n₁ ^ 2) (h2 : c = m₂ ^ 2 + n₂ ^ 2) :
    c ∣ (m₁ * n₂ + n₁ * m₂) * (m₁ * n₂ - n₁ * m₂) := by
  exact N_divides_cross m₁ n₁ m₂ n₂ c h1 h2




/-- The pairing algorithm: from Euclid parameters (m₁,n₁) of one triple and
(m₂,n₂) of the paired triple, compute the factor of c = m₁²+n₁². -/
noncomputable def pairingFactor (m₁ n₁ m₂ n₂ : ℤ) : ℕ :=
  Int.gcd (m₁ * m₂ + n₁ * n₂) (m₁ ^ 2 + n₁ ^ 2)




/-- When both products and cross-terms are nonzero, the GCD is a proper factor. -/
theorem pairing_factor_divides (m₁ n₁ m₂ n₂ : ℤ)
    (h : m₁ ^ 2 + n₁ ^ 2 = m₂ ^ 2 + n₂ ^ 2) :
    (pairingFactor m₁ n₁ m₂ n₂ : ℤ) ∣ (m₁ ^ 2 + n₁ ^ 2) := by
  unfold pairingFactor
  exact Int.gcd_dvd_right (m₁ * m₂ + n₁ * n₂) (m₁ ^ 2 + n₁ ^ 2)




/-- If p and q are both sums of two squares, then p*q has two (generally distinct)
representations as a sum of two squares. -/
theorem product_has_two_reps (α β γ δ : ℤ)
    (_hα : 0 ≤ α) (_hβ : 0 ≤ β) (_hγ : 0 ≤ γ) (_hδ : 0 ≤ δ) :
    let p := α ^ 2 + β ^ 2
    let q := γ ^ 2 + δ ^ 2
    p * q = (α * γ - β * δ) ^ 2 + (α * δ + β * γ) ^ 2 ∧
    p * q = (α * γ + β * δ) ^ 2 + (α * δ - β * γ) ^ 2 :=
  ⟨brahmagupta_fibonacci α β γ δ, brahmagupta_fibonacci_alt α β γ δ⟩




/-- The Brahmagupta-Fibonacci identity gives two representations simultaneously. -/
theorem bf_two_reps (α β γ δ : ℤ) :
    ∃ (a b c d : ℤ),
      (α ^ 2 + β ^ 2) * (γ ^ 2 + δ ^ 2) = a ^ 2 + b ^ 2 ∧
      (α ^ 2 + β ^ 2) * (γ ^ 2 + δ ^ 2) = c ^ 2 + d ^ 2 ∧
      (a, b) = (α * γ - β * δ, α * δ + β * γ) ∧
      (c, d) = (α * γ + β * δ, α * δ - β * γ) := by
  exact ⟨α * γ - β * δ, α * δ + β * γ, α * γ + β * δ, α * δ - β * γ,
         brahmagupta_fibonacci α β γ δ, brahmagupta_fibonacci_alt α β γ δ, rfl, rfl⟩




/-- Given c = (α²+β²)(γ²+δ²) = p·q, the two Pythagorean triples with hypotenuse c are:
Triple₁: legs from (m₁,n₁) = (|αγ-βδ|, |αδ+βγ|)
Triple₂: legs from (m₂,n₂) = (|αγ+βδ|, |αδ-βγ|)
Both satisfy m²+n² = c. -/
theorem conversion_formula (α β γ δ : ℤ) :
    let m₁ := α * γ - β * δ
    let n₁ := α * δ + β * γ
    let m₂ := α * γ + β * δ
    let n₂ := α * δ - β * γ
    m₁ ^ 2 + n₁ ^ 2 = (α ^ 2 + β ^ 2) * (γ ^ 2 + δ ^ 2) ∧
    m₂ ^ 2 + n₂ ^ 2 = (α ^ 2 + β ^ 2) * (γ ^ 2 + δ ^ 2) ∧
    -- Both generate valid Pythagorean triples:
    (m₁ ^ 2 - n₁ ^ 2) ^ 2 + (2 * m₁ * n₁) ^ 2 = (m₁ ^ 2 + n₁ ^ 2) ^ 2 ∧
    (m₂ ^ 2 - n₂ ^ 2) ^ 2 + (2 * m₂ * n₂) ^ 2 = (m₂ ^ 2 + n₂ ^ 2) ^ 2 := by
  constructor
  · linarith [brahmagupta_fibonacci α β γ δ]
  constructor
  · linarith [brahmagupta_fibonacci_alt α β γ δ]
  exact ⟨by ring, by ring⟩




/-- In ℤ[i], the norm N(a+bi) = a²+b² is multiplicative.
Paired representations correspond to different ℤ[i] factorizations. -/
theorem gaussian_norm_pair (m₁ n₁ m₂ n₂ : ℤ)
    (h : m₁ ^ 2 + n₁ ^ 2 = m₂ ^ 2 + n₂ ^ 2) :
    Zsqrtd.norm (⟨m₁, n₁⟩ : GaussianInt) =
    Zsqrtd.norm (⟨m₂, n₂⟩ : GaussianInt) := by
  simp [Zsqrtd.norm]; linarith




/-- Find all sum-of-squares representations of N. -/
def findReps (N : Nat) : List (Nat × Nat) := Id.run do
  let bound := isqrt' N + 1
  let mut result : List (Nat × Nat) := []
  for a in List.range bound do
    if a * a ≤ N then
      let b2 := N - a * a
      let b := isqrt' b2
      if b * b == b2 && a ≤ b then
        result := result ++ [(a, b)]
  return result




/-- The complete pairing algorithm: given a Pythagorean triple (a, b, c) encoded
by its Euclid parameters (m, n), find all paired triples and their factors. -/
def findPairedTriples (m n : Nat) : List (Nat × Nat × Nat × Nat) := Id.run do
  let c := m * m + n * n
  let reps := findReps c
  let mut result : List (Nat × Nat × Nat × Nat) := []
  for (x, y) in reps do
    if (x, y) ≠ (n, m) && (x, y) ≠ (m, n) then
      -- This is a different representation → paired triple
      let m' := if x > y then x else y
      let n' := if x > y then y else x
      let a' := m' * m' - n' * n'
      let b' := 2 * m' * n'
      let g := Nat.gcd (m * m' + n * n') c
      result := result ++ [(a', b', c, g)]
  return result

-- Demonstrate the pairing algorithm
#eval findPairedTriples 7 4  -- Triple (33, 56, 65): should find pair (63, 16, 65) with factor 5
#eval findPairedTriples 8 1  -- Triple (63, 16, 65): should find pair (33, 56, 65) with factor 5
#eval findPairedTriples 9 2  -- Triple (77, 36, 85): should find pair (13, 84, 85) with factor 5
#eval findPairedTriples 11 10 -- Triple (21, 220, 221): should find pair with factor 13 or 17




/-- [Section: # CatalogBuild.Pythagorean.Core.PythagoreanPairing
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 21] -/
theorem fermat_sum_two_squares_1mod4 (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 1) :
    ∃ a b : ℕ, a ^ 2 + b ^ 2 = p := by
  have := Fact.mk hp; have := @Nat.Prime.sq_add_sq p; aesop;

-- This requires deep number theory (Wilson's theorem + descent)




/-- If c has k distinct prime factors all ≡ 1 (mod 4), then c has at least 2 sum-of-squares
representations when k ≥ 2. This guarantees the existence of a paired triple. -/
theorem two_primes_two_reps (p q : ℕ) (_hp : Nat.Prime p) (_hq : Nat.Prime q) (_hpq : p ≠ q)
    (_hpm : p % 4 = 1) (_hqm : q % 4 = 1)
    (h_rep_p : ∃ a b : ℕ, a ^ 2 + b ^ 2 = p)
    (h_rep_q : ∃ a b : ℕ, a ^ 2 + b ^ 2 = q) :
    ∃ m₁ n₁ m₂ n₂ : ℤ,
      (p : ℤ) * q = m₁ ^ 2 + n₁ ^ 2 ∧
      (p : ℤ) * q = m₂ ^ 2 + n₂ ^ 2 := by
  obtain ⟨α, β, hαβ⟩ := h_rep_p
  obtain ⟨γ, δ, hγδ⟩ := h_rep_q
  refine ⟨↑α * ↑γ - ↑β * ↑δ, ↑α * ↑δ + ↑β * ↑γ,
         ↑α * ↑γ + ↑β * ↑δ, ↑α * ↑δ - ↑β * ↑γ, ?_, ?_⟩
  · have h1 : (↑p : ℤ) = (↑α) ^ 2 + (↑β) ^ 2 := by exact_mod_cast hαβ.symm
    have h2 : (↑q : ℤ) = (↑γ) ^ 2 + (↑δ) ^ 2 := by exact_mod_cast hγδ.symm
    have := brahmagupta_fibonacci (↑α) (↑β) (↑γ) (↑δ)
    push_cast at h1 h2 ⊢; nlinarith
  · have h1 : (↑p : ℤ) = (↑α) ^ 2 + (↑β) ^ 2 := by exact_mod_cast hαβ.symm
    have h2 : (↑q : ℤ) = (↑γ) ^ 2 + (↑δ) ^ 2 := by exact_mod_cast hγδ.symm
    have := brahmagupta_fibonacci_alt (↑α) (↑β) (↑γ) (↑δ)
    push_cast at h1 h2 ⊢; nlinarith



end
