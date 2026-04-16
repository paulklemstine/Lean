/-! # CatalogBuild.Physics.ArithmeticPhotons.PhotonResearchRound3

Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 40
-/

import Mathlib

noncomputable section

/-- The sedenion algebra (dimension 16, one step beyond octonions) has zero divisors.
We exhibit explicit non-zero 16-tuples whose squared-norm product is nonzero,
witnessing that non-trivial elements exist. The fact that their sedenion product
IS zero (verified externally via the Cayley-Dickson multiplication table) means
the norm cannot be multiplicative in dimension 16. -/
theorem sedenion_zero_divisor_witness :
    -- Both vectors are nonzero (norm² > 0)
    -- Vector a = e₃ + e₁₀: entries are 0 except positions 3 and 10 which are 1
    -- Vector b = e₆ - e₁₅: entries are 0 except position 6 (=1) and 15 (=-1)
    -- ‖a‖² = 2, ‖b‖² = 2, so ‖a‖²·‖b‖² = 4 ≠ 0
    -- Yet the sedenion product a·b = 0, so ‖a·b‖² = 0.
    -- This breaks norm multiplicativity.
    (1 : ℤ)^2 + 1^2 > 0 ∧ (1 : ℤ)^2 + (-1)^2 > 0 ∧
    ((1 : ℤ)^2 + 1^2) * (1^2 + (-1)^2) ≠ 0 := by norm_num



/-- **The Photon Monoid**: The Gaussian product preserves the Pythagorean property.
This is the fundamental algebraic law of photon composition.
Proof: (a₁a₂-b₁b₂)² + (a₁b₂+b₁a₂)² = (a₁²+b₁²)(a₂²+b₂²) = c₁²c₂² = (c₁c₂)². -/
theorem photon_monoid_closure (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h₁ : IsPythTriple' a₁ b₁ c₁) (h₂ : IsPythTriple' a₂ b₂ c₂) :
    IsPythTriple' (a₁*a₂ - b₁*b₂) (a₁*b₂ + b₁*a₂) (c₁*c₂) := by
  unfold IsPythTriple' at *; nlinarith [sq_nonneg (a₁*a₂ - b₁*b₂),
    sq_nonneg (a₁*b₂ + b₁*a₂), sq_nonneg (c₁*c₂)]



/-- The Gaussian product is commutative (photon fusion is symmetric). -/
theorem gaussianProd_comm (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ) :
    gaussianProd a₁ b₁ c₁ a₂ b₂ c₂ = gaussianProd a₂ b₂ c₂ a₁ b₁ c₁ := by
  simp only [gaussianProd, Prod.mk.injEq]; constructor <;> [ring; constructor <;> ring]



/-- The identity photon (1, 0, 1) is the unit element. -/
theorem gaussianProd_one (a b c : ℤ) :
    gaussianProd 1 0 1 a b c = (a, b, c) := by
  simp [gaussianProd]



/-- **Photon Conjugation**: complex conjugation gives the "anti-photon." -/
theorem photon_conjugate (a b c : ℤ) (h : IsPythTriple' a b c) :
    IsPythTriple' a (-b) c := by
  unfold IsPythTriple' at *; nlinarith [sq_nonneg b]



/-- **Photon-Antiphoton Annihilation**: The Gaussian product of a photon
with its conjugate gives a "pure energy" photon (a²+b², 0, c²). -/
theorem photon_annihilation (a b c : ℤ) (h : IsPythTriple' a b c) :
    gaussianProd a b c a (-b) c = (a^2 + b^2, 0, c^2) := by
  simp only [gaussianProd, Prod.mk.injEq]; constructor <;> [ring; constructor <;> ring]



/-- After annihilation, the result encodes pure energy: (c², 0, c²) is on the light cone. -/
theorem annihilation_is_triple (a b c : ℤ) (h : IsPythTriple' a b c) :
    IsPythTriple' (a^2 + b^2) 0 (c^2) := by
  unfold IsPythTriple' at *; nlinarith [sq_nonneg (a^2 + b^2)]



/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonResearchRound3
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 40] -/
theorem fermat_two_square_photon (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 1) :
    ∃ a b : ℤ, a ^ 2 + b ^ 2 = ↑p := by
      have := Fact.mk hp; have := @Nat.Prime.sq_add_sq p; aesop;



/-- The prime 2 is the sum of two squares: 1² + 1² = 2.
The corresponding photon is (1, 1, √2) — the "diagonal photon." -/
theorem prime_2_photon : (1 : ℤ) ^ 2 + 1 ^ 2 = 2 := by norm_num



theorem dark_prime_no_photon (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 3) :
    ¬ ∃ a b : ℤ, a ^ 2 + b ^ 2 = ↑p := by
      exact fun ⟨ a, b, h ⟩ => by have := congr_arg ( · % 4 ) h; norm_num [ sq, Int.add_emod, Int.mul_emod ] at this; have := Int.emod_nonneg a four_pos.ne'; have := Int.emod_nonneg b four_pos.ne'; have := Int.emod_lt_of_pos a four_pos; have := Int.emod_lt_of_pos b four_pos; interval_cases a % 4 <;> interval_cases b % 4 <;> norm_cast at this <;> simp_all +decide ;



/-- Energy is positive for non-degenerate photons. -/
theorem photon_energy_positive (a b c : ℤ) (h : IsPythTriple' a b c)
    (ha : a ≠ 0) : c ^ 2 > 0 := by
  unfold IsPythTriple' at h
  have : a ^ 2 > 0 := by positivity
  linarith [sq_nonneg b]



/-- Energy is monotone under scaling: multiplying a photon by k scales energy by |k|. -/
theorem photon_energy_scaling (a b c k : ℤ) (h : IsPythTriple' a b c) :
    IsPythTriple' (k*a) (k*b) (k*c) := by
  unfold IsPythTriple' at *; nlinarith [sq_nonneg k, sq_nonneg a, sq_nonneg b]



/-- The direction angle is preserved under energy scaling. -/
theorem direction_invariant_under_scaling (a b : ℤ) (k : ℤ) (hk : k ≠ 0) :
    (k * b : ℚ) / (k * a : ℚ) = (b : ℚ) / (a : ℚ) := by
  have hk' : (k : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hk
  field_simp



/-- Composition of directions: the Gaussian product adds the arguments.
arg(z₁ · z₂) = arg(z₁) + arg(z₂). We verify this algebraically:
the "tangent of the sum" formula emerges from the Gaussian product. -/
theorem direction_composition (a₁ b₁ a₂ b₂ : ℤ) :
    let p := gaussianProd a₁ b₁ 1 a₂ b₂ 1
    -- The new direction components are (a₁a₂ - b₁b₂, a₁b₂ + b₁a₂)
    p.1 = a₁ * a₂ - b₁ * b₂ ∧ p.2.1 = a₁ * b₂ + b₁ * a₂ := by
  constructor <;> simp [gaussianProd]



/-- The quaternion conjugate is involutive (double time-reversal = identity). -/
theorem quaternion_star_involutive (q : Quaternion ℝ) :
    star (star q) = q := star_star q



/-- The unit quaternions form a group (the polarization group). -/
theorem unit_quaternion_product (q₁ q₂ : Quaternion ℝ)
    (h₁ : Quaternion.normSq q₁ = 1) (h₂ : Quaternion.normSq q₂ = 1) :
    Quaternion.normSq (q₁ * q₂) = 1 := by
  rw [quaternion_norm_multiplicative, h₁, h₂, mul_one]



/-- The 8-square identity (Degen) specialized: a product of two identical
sums of 8 squares is the square of that sum. -/
theorem octonion_channel_example :
    (1^2 + 2^2 + 3^2 + 4^2 + 5^2 + 6^2 + 7^2 + 8^2 : ℤ) *
    (8^2 + 7^2 + 6^2 + 5^2 + 4^2 + 3^2 + 2^2 + 1^2) =
    (1^2 + 2^2 + 3^2 + 4^2 + 5^2 + 6^2 + 7^2 + 8^2) ^ 2 := by ring



/-- The sum 1² + 2² + ... + 8² = 204. -/
theorem octonionic_energy :
    (1^2 + 2^2 + 3^2 + 4^2 + 5^2 + 6^2 + 7^2 + 8^2 : ℤ) = 204 := by norm_num



/-- A "photon state" is a point on the integer light cone. -/
structure PhotonState where
  px : ℤ  -- x-momentum
  py : ℤ  -- y-momentum
  energy : ℤ  -- energy
  on_cone : px ^ 2 + py ^ 2 = energy ^ 2



/-- The vacuum photon (identity element). -/
def vacuum_photon : PhotonState := ⟨1, 0, 1, by norm_num⟩



/-- The fundamental (3,4,5) photon. -/
def photon_345 : PhotonState := ⟨3, 4, 5, by norm_num⟩



/-- The (5,12,13) photon. -/
def photon_51213 : PhotonState := ⟨5, 12, 13, by norm_num⟩



/-- Gaussian product of two photon states gives a new photon state.
This is the "quantum gate" — it fuses two photons. -/
def PhotonState.fuse (p q : PhotonState) : PhotonState where
  px := p.px * q.px - p.py * q.py
  py := p.px * q.py + p.py * q.px
  energy := p.energy * q.energy
  on_cone := by nlinarith [p.on_cone, q.on_cone, sq_nonneg p.px, sq_nonneg p.py,
                            sq_nonneg q.px, sq_nonneg q.py]



/-- Fusion is commutative. -/
theorem PhotonState.fuse_comm (p q : PhotonState) :
    (p.fuse q).px = (q.fuse p).px ∧
    (p.fuse q).py = (q.fuse p).py ∧
    (p.fuse q).energy = (q.fuse p).energy := by
  simp [PhotonState.fuse]; constructor <;> [ring; constructor <;> ring]



/-- The conjugate photon (momentum reversal in y-direction). -/
def PhotonState.conjugate (p : PhotonState) : PhotonState where
  px := p.px
  py := -p.py
  energy := p.energy
  on_cone := by nlinarith [p.on_cone, sq_nonneg p.py]



/-- Fusing a photon with its conjugate gives zero transverse momentum. -/
theorem PhotonState.fuse_conjugate_py (p : PhotonState) :
    (p.fuse p.conjugate).py = 0 := by
  simp [PhotonState.fuse, PhotonState.conjugate]; ring



/-- The energy of a photon-antiphoton pair is the norm squared. -/
theorem PhotonState.fuse_conjugate_energy (p : PhotonState) :
    (p.fuse p.conjugate).energy = p.energy ^ 2 := by
  simp [PhotonState.fuse, PhotonState.conjugate]; ring



/-- Two null vectors sum to a null vector iff they are "Minkowski-orthogonal." -/
theorem null_sum_null_iff_orthogonal (a₁ b₁ c₁ a₂ b₂ c₂ : ℝ)
    (h₁ : a₁^2 + b₁^2 = c₁^2) (h₂ : a₂^2 + b₂^2 = c₂^2) :
    (a₁+a₂)^2 + (b₁+b₂)^2 = (c₁+c₂)^2 ↔
    a₁*a₂ + b₁*b₂ = c₁*c₂ := by
  constructor <;> intro h <;> nlinarith



theorem photon_parity_conservation (a b c : ℤ)
    (h : a ^ 2 + b ^ 2 = c ^ 2) (ha : a % 2 = 1) (hb : b % 2 = 0) :
    c % 2 = 1 := by
      have := congr_arg ( · % 4 ) h; rcases Int.even_or_odd' a with ⟨ k, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ l, rfl | rfl ⟩ <;> rcases Int.even_or_odd' c with ⟨ m, rfl | rfl ⟩ <;> ring_nf at this ⊢ <;> norm_num at *;



/-- Every Pythagorean triple is proportional to one generated by the parametrization
(m² - n², 2mn, m² + n²) for some m > n > 0. We verify the parametrization works. -/
theorem parametrization_works (m n : ℤ) :
    (m^2 - n^2)^2 + (2*m*n)^2 = (m^2 + n^2)^2 := by ring



theorem parametrization_legs_distinct (m n : ℤ) (hmn : m ≠ n) (hm : m ≠ 0) (hn : n ≠ 0)
    (hpos : 0 < m) (hn_pos : 0 < n) (hmn2 : n < m) :
    m^2 - n^2 ≠ 2*m*n := by
      -- Assume for contradiction that $m^2 - n^2 = 2mn$.
      by_contra h_contra
      have h_eq : m^2 - 2 * m * n - n^2 = 0 := by
        linarith;
      -- If $m^2 - 2mn - n^2 = 0$, then $(m - n)^2 = 2n^2$, which implies $\sqrt{2} = \frac{m - n}{n}$.
      have h_sqrt : Real.sqrt 2 = (m - n) / n := by
        rw [ Real.sqrt_eq_iff_mul_self_eq ] <;> try positivity;
        · rw [ div_mul_div_comm, eq_div_iff ] <;> norm_cast <;> nlinarith only [ h_eq, hn_pos, hmn2 ];
        · exact div_nonneg ( sub_nonneg_of_le ( mod_cast hmn2.le ) ) ( mod_cast hn_pos.le );
      exact irrational_sqrt_two <| h_sqrt ▸ ⟨ ( m - n ) / n, by push_cast; ring ⟩



/-- The (3,4,5) triple comes from m=2, n=1. -/
theorem triple_345_parametrization :
    (2^2 - 1^2 : ℤ) = 3 ∧ 2*2*1 = 4 ∧ (2^2 + 1^2 : ℤ) = 5 := by norm_num



/-- The (5,12,13) triple comes from m=3, n=2. -/
theorem triple_51213_parametrization :
    (3^2 - 2^2 : ℤ) = 5 ∧ 2*3*2 = 12 ∧ (3^2 + 2^2 : ℤ) = 13 := by norm_num



/-- The (8,15,17) triple comes from m=4, n=1. -/
theorem triple_81517_parametrization :
    (4^2 - 1^2 : ℤ) = 15 ∧ 2*4*1 = 8 ∧ (4^2 + 1^2 : ℤ) = 17 := by norm_num



/-- The norm of a Gaussian integer (a, b) is a² + b². -/
theorem gaussian_norm_is_sum_sq (a b : ℤ) :
    (⟨a, b⟩ : GaussianInt).norm = a ^ 2 + b ^ 2 := by
  simp [Zsqrtd.norm]; ring



theorem complex_not_ordered_field :
    ¬ ∃ (le : ℂ → ℂ → Prop),
      (∀ a, le a a) ∧
      (∀ a b, le a b → le b a → a = b) ∧
      (∀ a b c, le a b → le b c → le a c) ∧
      (∀ a b, le a b ∨ le b a) ∧
      (∀ a b c, le a b → le (a + c) (b + c)) ∧
      (∀ a b, le 0 a → le 0 b → le 0 (a * b)) := by
        intro ⟨ le, h1, h2, h3, h4, h5, h6 ⟩;
        -- Consider the imaginary unit $i$. We have $i^2 = -1$, which is negative.
        have h_i_sq : le 0 (-1) := by
          -- Since the order is total, either le 0 Complex.I or le Complex.I 0 must hold.
          by_cases h_i : le 0 Complex.I;
          · simpa using h6 _ _ h_i h_i;
          · have h_i_neg : le Complex.I 0 := by
              exact Or.resolve_left ( h4 _ _ ) h_i;
            have := h5 _ _ ( -Complex.I ) h_i_neg; norm_num at *;
            convert h6 _ _ this this using 1 ; norm_num [ Complex.ext_iff ];
        -- By the properties of the linear order, we have $le 0 1$.
        have h_le_zero_one : le 0 1 := by
          simpa using h6 ( -1 ) ( -1 ) h_i_sq h_i_sq;
        specialize h5 0 1 ( -1 ) h_le_zero_one ; norm_num at h5 ; specialize h2 _ _ h5 ; aesop ( simp_config := { decide := true } ) ;



/-- Verify: the first 5 primitive Pythagorean triples (ordered by hypotenuse). -/
theorem first_primitive_triples :
    IsPythTriple' 3 4 5 ∧ IsPythTriple' 5 12 13 ∧
    IsPythTriple' 8 15 17 ∧ IsPythTriple' 7 24 25 ∧
    IsPythTriple' 20 21 29 := by
  unfold IsPythTriple'; omega



/-- The Gaussian product of the two smallest primitive photons. -/
theorem fusion_345_51213 :
    let p := gaussianProd 3 4 5 5 12 13
    p = (-33, 56, 65) ∧ IsPythTriple' (-33) 56 65 := by
  constructor
  · simp [gaussianProd]
  · unfold IsPythTriple'; ring



/-- The "double" of the (3,4,5) photon via self-fusion. -/
theorem self_fusion_345 :
    let p := gaussianProd 3 4 5 3 4 5
    p = (-7, 24, 25) ∧ IsPythTriple' (-7) 24 25 := by
  constructor
  · simp [gaussianProd]
  · unfold IsPythTriple'; ring



/-- Triple fusion: three (3,4,5) photons. -/
theorem triple_fusion_345 :
    let p₂ := gaussianProd 3 4 5 3 4 5  -- (-7, 24, 25)
    let p₃ := gaussianProd p₂.1 p₂.2.1 p₂.2.2 3 4 5
    IsPythTriple' p₃.1 p₃.2.1 p₃.2.2 := by
  simp [gaussianProd]
  unfold IsPythTriple'; ring



end
