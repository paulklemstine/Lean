/-! # CatalogBuild.Physics.ArithmeticPhotons.PhotonResearchRound2

Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 24
-/

import Mathlib

noncomputable section

/-- Minkowski form Q(a,b,c) = a² + b² - c² -/
def minkQ (a b c : ℝ) : ℝ := a ^ 2 + b ^ 2 - c ^ 2

/-- Integer Pythagorean triple -/

theorem null_gaussian_product (a₁ b₁ c₁ a₂ b₂ c₂ : ℝ)
    (h₁ : IsNull a₁ b₁ c₁) (h₂ : IsNull a₂ b₂ c₂) :
    IsNull (a₁ * a₂ - b₁ * b₂) (a₁ * b₂ + a₂ * b₁) (c₁ * c₂) := by
  -- By definition of IsNull, we have minkQ a₁ b₁ c₁ = 0 and minkQ a₂ b₂ c₂ = 0.
  unfold IsNull at *;
  unfold minkQ at *; nlinarith;

/-! ## Experiment 2: Conjugate Photons (H4)

**Hypothesis**: Negating one leg preserves the Pythagorean property.
This is the "anti-photon" — the complex conjugate of the Gaussian integer.
-/

/-
PROBLEM
Negating the second component preserves the Pythagorean property.

PROVIDED SOLUTION
IsPythTriple a (-b) c means a² + (-b)² = c². Since (-b)² = b², this equals a² + b² = c² = h.
-/

theorem conjugate_photon (a b c : ℤ) (h : IsPythTriple a b c) :
    IsPythTriple a (-b) c := by
  unfold IsPythTriple at *; linarith [ pow_two_nonneg b ] ;

/-
PROBLEM
Negating the first component preserves the Pythagorean property.

PROVIDED SOLUTION
(-a)² = a², so IsPythTriple (-a) b c reduces to h.
-/

theorem conjugate_photon' (a b c : ℤ) (h : IsPythTriple a b c) :
    IsPythTriple (-a) b c := by
  unfold IsPythTriple at *; linarith;

/-
PROBLEM
Negating both legs preserves the Pythagorean property.

PROVIDED SOLUTION
(-a)² + (-b)² = a² + b² = c². Use neg_sq.
-/

theorem antipodal_photon (a b c : ℤ) (h : IsPythTriple a b c) :
    IsPythTriple (-a) (-b) c := by
  unfold IsPythTriple at *; linarith [ pow_two ( -a ), pow_two ( -b ) ] ;

/-! ## Experiment 3: The Gaussian Product is Associative and Commutative

The photon multiplication inherits associativity and commutativity from ℤ[i].
-/

/-- Gaussian product operation on triples -/

def gaussProd (t₁ t₂ : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (t₁.1 * t₂.1 - t₁.2.1 * t₂.2.1,
   t₁.1 * t₂.2.1 + t₁.2.1 * t₂.1,
   t₁.2.2 * t₂.2.2)

/-
PROBLEM
The Gaussian product is commutative.

PROVIDED SOLUTION
Unfold gaussProd and use ext (Prod.ext). For the first component: a₁a₂ - b₁b₂ = a₂a₁ - b₂b₁ by ring. For the second: a₁b₂ + b₁a₂ = a₂b₁ + b₂a₁ by ring. For the third: c₁c₂ = c₂c₁ by ring.
-/

theorem gaussProd_comm (t₁ t₂ : ℤ × ℤ × ℤ) :
    gaussProd t₁ t₂ = gaussProd t₂ t₁ := by
  unfold gaussProd; ring;

/-
PROBLEM
The Gaussian product is associative.

PROVIDED SOLUTION
Unfold gaussProd and check component-by-component using ring.
-/

theorem gaussProd_assoc (t₁ t₂ t₃ : ℤ × ℤ × ℤ) :
    gaussProd (gaussProd t₁ t₂) t₃ = gaussProd t₁ (gaussProd t₂ t₃) := by
  unfold gaussProd; ring;

/-
PROBLEM
The identity photon (1, 0, 1) is the unit of the Gaussian product.

PROVIDED SOLUTION
Unfold gaussProd. (1*a - 0*b, 1*b + 0*a, 1*c) = (a, b, c). Use simp and ext.
-/

theorem gaussProd_identity (t : ℤ × ℤ × ℤ) :
    gaussProd (1, 0, 1) t = t := by
  -- By definition of gaussProd, we have:
  simp [gaussProd]

/-
PROBLEM
(1, 0, 1) is itself a Pythagorean triple (the degenerate photon).

PROVIDED SOLUTION
1² + 0² = 1 = 1². Use norm_num or decide.
-/

theorem identity_is_triple : IsPythTriple 1 0 1 := by
  exact?

/-! ## Experiment 4: Brahmagupta–Fibonacci Identity (The Photon Product Formula)

The norm multiplicativity is equivalent to the Brahmagupta–Fibonacci identity:
(a₁² + b₁²)(a₂² + b₂²) = (a₁a₂ - b₁b₂)² + (a₁b₂ + a₂b₁)²
-/

/-
PROBLEM
Brahmagupta–Fibonacci identity: the product of sums of two squares
    is itself a sum of two squares. This is the algebraic heart of photon multiplication.

PROVIDED SOLUTION
Pure algebraic identity. Use ring.
-/

theorem photon_squared (a b c : ℤ) (h : IsPythTriple a b c) :
    IsPythTriple (a ^ 2 - b ^ 2) (2 * a * b) (c ^ 2) := by
  unfold IsPythTriple at *; nlinarith;

/-! ## Experiment 6: Minkowski Reverse Cauchy–Schwarz (H7)

For timelike vectors, the "reverse Cauchy–Schwarz" inequality holds.
For null vectors, it degenerates.
-/

/-
PROBLEM
For null vectors, the Minkowski inner product squared equals
    the product of the Minkowski forms (both zero).

PROVIDED SOLUTION
Since h₁ says minkQ a₁ b₁ c₁ = 0 and h₂ says minkQ a₂ b₂ c₂ = 0, the RHS is 0*0 = 0. So we need minkInner² ≥ 0, which is true since it's a square. Use simp [IsNull, minkQ] at h₁ h₂, rewrite, and apply sq_nonneg.
-/

theorem null_inner_vanishes_product (a₁ b₁ c₁ a₂ b₂ c₂ : ℝ)
    (h₁ : IsNull a₁ b₁ c₁) (h₂ : IsNull a₂ b₂ c₂) :
    minkInner a₁ b₁ c₁ a₂ b₂ c₂ ^ 2 ≥ minkQ a₁ b₁ c₁ * minkQ a₂ b₂ c₂ := by
  unfold IsNull at *; unfold minkQ at *; unfold minkInner at *; nlinarith;

/-! ## Experiment 7: Light Cone Intersections

The intersection of two light cones centered at different spacetime points
gives the set of events equidistant (in Minkowski sense) from both — a hyperboloid.
-/

/-
PROBLEM
Two light cones intersect in a surface where the Minkowski inner product
    with the separation vector is constant.

PROVIDED SOLUTION
Expand IsNull in h₁ and h₂. h₁: a²+b²-c² = 0. h₂: (a-dx)²+(b-dy)²-(c-dt)² = 0. Expand h₂: a²-2a·dx+dx²+b²-2b·dy+dy²-c²+2c·dt-dt² = 0. Using h₁ (a²+b²-c²=0), this simplifies to -2a·dx-2b·dy+2c·dt+dx²+dy²-dt² = 0. So 2(a·dx+b·dy-c·dt) = dx²+dy²-dt². The LHS is 2·minkInner a b c dx dy dt and RHS is minkQ dx dy dt. Use nlinarith or linarith.
-/

theorem light_cone_intersection (a b c dx dy dt : ℝ)
    (h₁ : IsNull a b c) (h₂ : IsNull (a - dx) (b - dy) (c - dt)) :
    2 * minkInner a b c dx dy dt = minkQ dx dy dt := by
  unfold IsNull minkInner minkQ at *; linarith;

/-! ## Experiment 8: Photon Number Theory — Counting Representations

The number of ways to write n as a sum of two squares is connected to
the divisors of n. For the light cone: the number of integer points
on the light cone with c = n equals 4 times the number of representations
of n² as a sum of two squares.
-/

/-
PROBLEM
The (3,4,5) photon squared via Gaussian product gives (7,24,25).
    Computational verification.

PROVIDED SOLUTION
Unfold gaussProd and compute: (3*3 - 4*4, 3*4 + 4*3, 5*5) = (9-16, 12+12, 25) = (-7, 24, 25). Use native_decide or norm_num/simp.
-/

theorem photon_345_squared :
    gaussProd (3, 4, 5) (3, 4, 5) = (-7, 24, 25) := by
  decide +kernel

/-
PROBLEM
Actually, let's verify: 3² - 4² = -7, but we want the absolute triple.
    The Gaussian square of (3,4,5) gives (-7, 24, 25), which is indeed
    a Pythagorean triple since (-7)² + 24² = 49 + 576 = 625 = 25².

PROVIDED SOLUTION
(-7)² + 24² = 49 + 576 = 625 = 25². Use norm_num or decide.
-/

theorem photon_345_squared_is_triple :
    IsPythTriple (-7) 24 25 := by
  norm_num [ IsPythTriple ]

/-
PROBLEM
The Gaussian product of (3,4,5) and (5,12,13) gives a new photon.

PROVIDED SOLUTION
Compute: (3*5 - 4*12, 3*12 + 4*5, 5*13) = (15-48, 36+20, 65) = (-33, 56, 65). Use native_decide or simp [gaussProd].
-/

theorem photon_product_345_51213 :
    gaussProd (3, 4, 5) (5, 12, 13) = (-33, 56, 65) := by
  native_decide +revert

/-
PROBLEM
Verify the product is a valid triple.

PROVIDED SOLUTION
(-33)² + 56² = 1089 + 3136 = 4225 = 65². Use norm_num or decide.
-/

theorem photon_product_is_triple :
    IsPythTriple (-33) 56 65 := by
  exact show ( -33 ) ^ 2 + 56 ^ 2 = 65 ^ 2 by norm_num;

/-! ## Experiment 9: The Photon Energy Spectrum

For primitive Pythagorean triples, the hypotenuse c must be of a specific form:
c must be expressible as a product of primes ≡ 1 (mod 4).
-/

/-
PROBLEM
Every primitive triple has odd hypotenuse. If a² + b² = c² with
    gcd(a,b) = 1, then c is odd.

PROVIDED SOLUTION
We have a odd, b even, a²+b²=c². a odd means a² ≡ 1 (mod 2). b even means b² ≡ 0 (mod 2). So c² = a²+b² ≡ 1 (mod 2), hence c is odd. Use Int.emod_emod_of_dvd or omega-style reasoning on the mod 2 condition.
-/

theorem primitive_triple_odd_hypotenuse (a b c : ℤ)
    (h : IsPythTriple a b c) (ha : a % 2 = 1) (hb : b % 2 = 0) :
    c % 2 = 1 := by
  cases Int.emod_two_eq_zero_or_one c <;> ( unfold IsPythTriple at h ; ( replace h := congr_arg ( · % 4 ) h ; rcases Int.even_or_odd' a with ⟨ k, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ l, rfl | rfl ⟩ <;> rcases Int.even_or_odd' c with ⟨ m, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Int.add_emod, Int.mul_emod ] at *; ) )

/-! ## Experiment 10: Lorentz Group Structure

The set of integer matrices preserving the Minkowski form on ℤ³
is the discrete Lorentz group O(2,1;ℤ). The Berggren matrices
generate a subgroup of index related to the structure of this group.
-/

/-- The identity matrix preserves the Minkowski form. -/

theorem identity_preserves_minkQ (a b c : ℝ) :
    minkQ a b c = minkQ a b c := rfl

/-
PROBLEM
Composition of form-preserving maps preserves the form.

PROVIDED SOLUTION
Let v := f a b c. By hg, minkQ (g v.1 v.2.1 v.2.2) = minkQ v.1 v.2.1 v.2.2. By hf, minkQ v.1 v.2.1 v.2.2 = minkQ a b c. Chain them with trans.
-/

theorem comp_preserves_minkQ
    (f g : ℝ → ℝ → ℝ → ℝ × ℝ × ℝ)
    (hf : ∀ a b c, minkQ (f a b c).1 (f a b c).2.1 (f a b c).2.2 = minkQ a b c)
    (hg : ∀ a b c, minkQ (g a b c).1 (g a b c).2.1 (g a b c).2.2 = minkQ a b c)
    (a b c : ℝ) :
    let v := f a b c
    minkQ (g v.1 v.2.1 v.2.2).1 (g v.1 v.2.1 v.2.2).2.1 (g v.1 v.2.1 v.2.2).2.2 =
      minkQ a b c := by
  aesop

/-! ## Experiment 11: Null Tetrad Construction

In (2+1)d, we can construct a null basis: two null vectors and one spacelike vector
that form a basis. This is the null tetrad (triad in 2+1d).
-/

/-
PROBLEM
The vectors (1,0,1) and (1,0,-1) are both null.

PROVIDED SOLUTION
Split into two goals. IsNull 1 0 1: minkQ 1 0 1 = 1+0-1 = 0. IsNull 1 0 (-1): minkQ 1 0 (-1) = 1+0-1 = 0. Use simp [IsNull, minkQ] and norm_num.
-/

theorem null_basis_vectors :
    IsNull 1 0 1 ∧ IsNull 1 0 (-1) := by
  exact ⟨ by unfold IsNull; unfold minkQ; norm_num, by unfold IsNull; unfold minkQ; norm_num ⟩

/-- The null vectors (1,0,1) and (1,0,-1) are not proportional (linearly independent
    when combined with (0,1,0)). -/
-- Original hypothesis minkInner = -1 was DISPROVED: actual value is 2.
-- The two null vectors have positive Minkowski inner product, meaning they
-- point into the same light cone sheet (both future-directed or both past-directed).

theorem null_basis_inner :
    minkInner 1 0 1 1 0 (-1) = 2 := by
  simp [minkInner]; norm_num

/-
PROBLEM
The vector (0,1,0) is spacelike.

PROVIDED SOLUTION
minkQ 0 1 0 = 0² + 1² - 0² = 1 > 0. Use simp [minkQ] and norm_num.
-/

theorem spacelike_basis :
    minkQ 0 1 0 > 0 := by
  unfold minkQ; norm_num;

/-! ## Experiment 12: Photon Helicity from Cross Product

In (2+1)d, the "angular momentum" of a photon (a,b,c) can be measured by the
quantity L = a·b, which represents the coupling between the two spatial components.
For a photon moving purely in x (b=0), L = 0. For a photon with equal components, L is maximal.
-/

/-
PROBLEM
For a null vector with c > 0, the helicity ratio ab/c² lies in [-1/2, 1/2].

PROVIDED SOLUTION
From IsNull: a² + b² = c². We need |ab|/c² ≤ 1/2, i.e., |ab| ≤ c²/2 = (a²+b²)/2. This follows from AM-GM: (a²+b²)/2 ≥ |ab|, which is equivalent to (a-b)² ≥ 0 and (a+b)² ≥ 0. Use abs_mul_le_of_sq_le or derive from (|a|-|b|)² ≥ 0. More precisely, 2|ab| ≤ a²+b² follows from 0 ≤ (|a|-|b|)² = a²-2|ab|+b². So |ab| ≤ (a²+b²)/2 = c²/2. Then |ab|/c² ≤ 1/2. Use div_le_div and the fact c² > 0 (since c ≠ 0).
-/

theorem photon_helicity_bound (a b c : ℝ) (h : IsNull a b c) (hc : c ≠ 0) :
    |a * b| / c ^ 2 ≤ 1 / 2 := by
  rw [ div_le_iff₀ ] <;> norm_num [ IsNull ] at *;
  · unfold minkQ at h; nlinarith [ sq_nonneg ( |a| - |b| ), abs_mul_abs_self a, abs_mul_abs_self b ] ;
  · positivity


end
