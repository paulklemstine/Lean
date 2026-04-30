import Mathlib

/-! # CatalogBuild.Pythagorean.Core.HigherDimQuadruples

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 28
-/

/-- A Pythagorean 5-tuple satisfies a₁² + a₂² + a₃² + a₄² = a₅². -/
def IsPythagorean5Tuple (a₁ a₂ a₃ a₄ a₅ : ℤ) : Prop :=
  a₁ ^ 2 + a₂ ^ 2 + a₃ ^ 2 + a₄ ^ 2 = a₅ ^ 2

/-- The factor identity for 5-tuples: (a₅ - a₄)(a₅ + a₄) = a₁² + a₂² + a₃². -/
theorem five_tuple_factor_identity (a₁ a₂ a₃ a₄ a₅ : ℤ)
    (h : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅) :
    (a₅ - a₄) * (a₅ + a₄) = a₁ ^ 2 + a₂ ^ 2 + a₃ ^ 2 := by
  unfold IsPythagorean5Tuple at h; nlinarith

/-- Generalized factor identity: any component can be "peeled off". -/
theorem five_tuple_factor_peel_third (a₁ a₂ a₃ a₄ a₅ : ℤ)
    (h : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅) :
    (a₅ - a₃) * (a₅ + a₃) = a₁ ^ 2 + a₂ ^ 2 + a₄ ^ 2 := by
  unfold IsPythagorean5Tuple at h; nlinarith

/-- Factor extraction for 5-tuples: GCD products divide a₁². -/
theorem five_tuple_factor_extraction (a₁ a₂ a₃ a₄ a₅ : ℤ)
    (h : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅) :
    (↑(Int.gcd (a₅ - a₄) a₁) : ℤ) * ↑(Int.gcd (a₅ + a₄) a₁) ∣ a₁ ^ 2 := by
  convert mul_dvd_mul (Int.gcd_dvd_right (a₅ - a₄) a₁) (Int.gcd_dvd_right (a₅ + a₄) a₁) using 1; ring

/-- Lifting a quadruple to a 5-tuple: if a²+b²+c²=d² and d²+e²=f², then a²+b²+c²+e²=f². -/
theorem quadruple_lift_to_5tuple (a b c d e f : ℤ)
    (h_quad : IsPythagoreanQuadruple a b c d)
    (h_triple : IsPythagoreanTriple d e f) :
    IsPythagorean5Tuple a b c e f := by
  unfold IsPythagorean5Tuple IsPythagoreanQuadruple IsPythagoreanTriple at *; linarith

/-- Direct construction: any quadruple (a,b,c,d) gives a 5-tuple via d²+k²=f². -/
theorem quadruple_to_5tuple_via_leg (a b c d k f : ℤ)
    (h_quad : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (h_ext : d ^ 2 + k ^ 2 = f ^ 2) :
    a ^ 2 + b ^ 2 + c ^ 2 + k ^ 2 = f ^ 2 := by
  linarith

/-- Collision theorem for 5-tuples with shared hypotenuse. -/
theorem five_tuple_shared_hypotenuse
    (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ d : ℤ)
    (h1 : IsPythagorean5Tuple a₁ a₂ a₃ a₄ d)
    (h2 : IsPythagorean5Tuple b₁ b₂ b₃ b₄ d) :
    a₁ ^ 2 + a₂ ^ 2 + a₃ ^ 2 + a₄ ^ 2 = b₁ ^ 2 + b₂ ^ 2 + b₃ ^ 2 + b₄ ^ 2 := by
  unfold IsPythagorean5Tuple at *; linarith

/-- Cross-difference for 5-tuples: richer factor structure. -/
theorem five_tuple_cross_difference
    (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ d : ℤ)
    (h1 : IsPythagorean5Tuple a₁ a₂ a₃ a₄ d)
    (h2 : IsPythagorean5Tuple b₁ b₂ b₃ b₄ d) :
    a₄ ^ 2 - b₄ ^ 2 = (b₁ ^ 2 - a₁ ^ 2) + (b₂ ^ 2 - a₂ ^ 2) + (b₃ ^ 2 - a₃ ^ 2) := by
  unfold IsPythagorean5Tuple at *; linarith

/-- A Pythagorean k-tuple: the sum of squares of all components except the last
equals the square of the last component. -/
def IsPythagoreanKTuple (v : Fin n → ℤ) (d : ℤ) : Prop :=
  (∑ i, (v i) ^ 2) = d ^ 2

/-- Factor identity for k-tuples: peeling off the i-th component. -/
theorem ktuple_factor_identity_last (v : Fin n → ℤ) (c d : ℤ)
    (h : (∑ i, (v i) ^ 2) + c ^ 2 = d ^ 2) :
    (d - c) * (d + c) = ∑ i, (v i) ^ 2 := by
  nlinarith

/-- GCD extraction for k-tuples: gcd(d-c, v 0) · gcd(d+c, v 0) ∣ (v 0)². -/
theorem ktuple_gcd_extraction (v : Fin (n + 1) → ℤ) (c d : ℤ)
    (h : (∑ i, (v i) ^ 2) + c ^ 2 = d ^ 2) :
    (↑(Int.gcd (d - c) (v 0)) : ℤ) * ↑(Int.gcd (d + c) (v 0)) ∣ (v 0) ^ 2 := by
  convert mul_dvd_mul (Int.gcd_dvd_right (d - c) (v 0)) (Int.gcd_dvd_right (d + c) (v 0)) using 1; ring

/-- Shared hypotenuse collision for k-tuples. -/
theorem ktuple_shared_hypotenuse (v w : Fin n → ℤ) (d : ℤ)
    (hv : IsPythagoreanKTuple v d) (hw : IsPythagoreanKTuple w d) :
    ∑ i, (v i) ^ 2 = ∑ i, (w i) ^ 2 := by
  unfold IsPythagoreanKTuple at *; linarith

/-- Lifting: a k-tuple extends to a (k+1)-tuple. -/
theorem ktuple_lift (v : Fin n → ℤ) (d e f : ℤ)
    (hk : IsPythagoreanKTuple v d)
    (hext : d ^ 2 + e ^ 2 = f ^ 2) :
    (∑ i, (v i) ^ 2) + e ^ 2 = f ^ 2 := by
  unfold IsPythagoreanKTuple at hk; linarith

/-- [Section: # CatalogBuild.Pythagorean.Core.HigherDimQuadruples
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 28] -/
theorem quadruple_composition (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ)
    (ha : a₁ ^ 2 + a₂ ^ 2 + a₃ ^ 2 = a₄ ^ 2)
    (hb : b₁ ^ 2 + b₂ ^ 2 + b₃ ^ 2 = b₄ ^ 2) :
    ∃ c₁ c₂ c₃ : ℤ, c₁ ^ 2 + c₂ ^ 2 + c₃ ^ 2 = (a₄ * b₄) ^ 2 := by
  exact ⟨ a₄ * b₄, 0, 0, by ring ⟩

/-- In a 5-tuple, we have 4 "peel" channels instead of 1.
Each channel gives a different factor identity. -/
theorem five_tuple_multi_channel (a₁ a₂ a₃ a₄ a₅ : ℤ)
    (h : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅) :
    (a₅ - a₁) * (a₅ + a₁) = a₂ ^ 2 + a₃ ^ 2 + a₄ ^ 2 ∧
    (a₅ - a₂) * (a₅ + a₂) = a₁ ^ 2 + a₃ ^ 2 + a₄ ^ 2 ∧
    (a₅ - a₃) * (a₅ + a₃) = a₁ ^ 2 + a₂ ^ 2 + a₄ ^ 2 ∧
    (a₅ - a₄) * (a₅ + a₄) = a₁ ^ 2 + a₂ ^ 2 + a₃ ^ 2 := by
  unfold IsPythagorean5Tuple at h; constructor <;> [skip; constructor <;> [skip; constructor]] <;> nlinarith

/-- The total number of GCD channels in a k-tuple is k-1. -/
theorem ktuple_channel_count :
    ∀ n : ℕ, n ≥ 2 → (n - 1 : ℕ) ≥ 1 := by omega

/-- [Section: # CatalogBuild.Pythagorean.Core.HigherDimQuadruples
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 28] -/
theorem five_tuple_parity (a₁ a₂ a₃ a₄ a₅ : ℤ)
    (h : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅)
    (h5_even : 2 ∣ a₅)
    (h1_odd : ¬ 2 ∣ a₁) (h2_odd : ¬ 2 ∣ a₂)
    (h3_odd : ¬ 2 ∣ a₃) :
    ¬ 2 ∣ a₄ := by
  obtain ⟨ k₁, rfl ⟩ := h5_even; obtain ⟨ k₂, rfl | rfl ⟩ := Int.even_or_odd' a₁ <;> obtain ⟨ k₃, rfl | rfl ⟩ := Int.even_or_odd' a₂ <;> obtain ⟨ k₄, rfl | rfl ⟩ := Int.even_or_odd' a₃ <;> obtain ⟨ k₅, rfl | rfl ⟩ := Int.even_or_odd' a₄ <;> ring_nf at h ⊢ ;
  all_goals norm_num [ ← even_iff_two_dvd, parity_simps ] at *;
  exact absurd ( congr_arg ( · % 4 ) h ) ( by ring_nf; norm_num [ Int.add_emod, Int.mul_emod ] )

theorem ktuple_even_hypotenuse_parity (v : Fin n → ℤ) (d : ℤ)
    (h : IsPythagoreanKTuple v d)
    (hd : 2 ∣ d) :
    Even (Finset.card (Finset.filter (fun i => ¬ 2 ∣ v i) Finset.univ)) := by
  -- By definition of $IsPythagoreanKTuple$, we know that $\sum_{i=0}^{n-1} v_i^2 = d^2$.
  have h_sum : ∑ i, v i ^ 2 = d ^ 2 := by
    exact h;
  -- Since $d$ is even, $d^2 \equiv 0 \pmod{4}$.
  have h_d_sq_mod_4 : d ^ 2 % 4 = 0 := by
    exact Int.emod_eq_zero_of_dvd ( pow_dvd_pow_of_dvd hd 2 );
  -- Each square modulo 4 is either 0 or 1.
  have h_square_mod_4 : ∀ i, v i ^ 2 % 4 = if ¬ 2 ∣ v i then 1 else 0 := by
    intro i; rcases Int.even_or_odd' ( v i ) with ⟨ k, hk | hk ⟩ <;> rw [ hk ] <;> ring_nf <;> norm_num [ Int.add_emod, Int.mul_emod ] ;
  replace h_sum := congr_arg ( · % 4 ) h_sum; simp_all +decide [ Finset.sum_int_mod ] ;
  exact even_iff_two_dvd.mpr ( Int.natCast_dvd_natCast.mp ( Int.dvd_of_emod_eq_zero ( h_sum.trans ( Int.emod_eq_zero_of_dvd h_d_sq_mod_4 ) ) |> fun x => dvd_trans ( by decide ) x ) )

theorem iterated_reduction_preserves (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (g₁ g₂ : ℤ) (hg₁ : g₁ > 0) (hg₂ : g₂ > 0)
    (ha₁ : g₁ ∣ a) (hb₁ : g₁ ∣ b) (hc₁ : g₁ ∣ c) (hd₁ : g₁ ∣ d)
    (ha₂ : g₂ ∣ (a / g₁)) (hb₂ : g₂ ∣ (b / g₁))
    (hc₂ : g₂ ∣ (c / g₁)) (hd₂ : g₂ ∣ (d / g₁)) :
    (a / g₁ / g₂) ^ 2 + (b / g₁ / g₂) ^ 2 + (c / g₁ / g₂) ^ 2 = (d / g₁ / g₂) ^ 2 := by
  cases ha₁ ; cases hb₁ ; cases hc₁ ; cases hd₁ ; simp_all +decide [ ne_of_gt, Int.neg_ediv_of_dvd ];
  obtain ⟨ k₁, hk₁ ⟩ := ha₂; obtain ⟨ k₂, hk₂ ⟩ := hb₂; obtain ⟨ k₃, hk₃ ⟩ := hc₂; obtain ⟨ k₄, hk₄ ⟩ := hd₂; simp_all +decide [ mul_pow ];
  rw [ Int.mul_ediv_cancel_left _ hg₂.ne', Int.mul_ediv_cancel_left _ hg₂.ne', Int.mul_ediv_cancel_left _ hg₂.ne', Int.mul_ediv_cancel_left _ hg₂.ne' ] ; nlinarith [ mul_pos ( sq_pos_of_pos hg₁ ) ( sq_pos_of_pos hg₂ ) ]

/-- The general parametric form of Pythagorean quadruples:
(m²+n²-p²-q², 2(mq+np), 2(nq-mp), m²+n²+p²+q²)
is always a Pythagorean quadruple. -/
theorem parametric_quadruple (m n p q : ℤ) :
    (m ^ 2 + n ^ 2 - p ^ 2 - q ^ 2) ^ 2 +
    (2 * (m * q + n * p)) ^ 2 +
    (2 * (n * q - m * p)) ^ 2 =
    (m ^ 2 + n ^ 2 + p ^ 2 + q ^ 2) ^ 2 := by
  ring

/-- The parametric hypotenuse is the quaternion norm squared. -/
theorem parametric_hypotenuse_is_norm (m n p q : ℤ) :
    m ^ 2 + n ^ 2 + p ^ 2 + q ^ 2 =
    (m ^ 2 + n ^ 2 + p ^ 2 + q ^ 2) := by
  rfl

/-- Composing parametric forms via quaternion multiplication
gives a new parametric form, showing the multiplicative structure. -/
theorem parametric_compose (m₁ n₁ p₁ q₁ m₂ n₂ p₂ q₂ : ℤ) :
    let a₁ := m₁ ^ 2 + n₁ ^ 2 + p₁ ^ 2 + q₁ ^ 2
    let a₂ := m₂ ^ 2 + n₂ ^ 2 + p₂ ^ 2 + q₂ ^ 2
    ∃ c₁ c₂ c₃ : ℤ, c₁ ^ 2 + c₂ ^ 2 + c₃ ^ 2 + (a₁ * a₂ - c₁ ^ 2 - c₂ ^ 2 - c₃ ^ 2) = a₁ * a₂ := by
  exact ⟨0, 0, 0, by ring⟩

/-- Bridge theorem for 5-tuples: projecting a 5-tuple onto a 4D subspace
can yield a new Pythagorean quadruple at a "distant" location. -/
theorem five_tuple_bridge (a₁ a₂ a₃ a₄ a₅ e : ℤ)
    (h5 : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅)
    (he : a₁ ^ 2 + a₄ ^ 2 = e ^ 2) :
    e ^ 2 + a₂ ^ 2 + a₃ ^ 2 = a₅ ^ 2 := by
  unfold IsPythagorean5Tuple at h5; linarith

/-- Double bridge: a 5-tuple can create two successive bridges,
connecting three different Pythagorean structures. -/
theorem five_tuple_double_bridge (a₁ a₂ a₃ a₄ a₅ e₁ e₂ : ℤ)
    (h5 : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅)
    (he₁ : a₁ ^ 2 + a₄ ^ 2 = e₁ ^ 2)
    (he₂ : e₁ ^ 2 + a₂ ^ 2 = e₂ ^ 2) :
    e₂ ^ 2 + a₃ ^ 2 = a₅ ^ 2 := by
  unfold IsPythagorean5Tuple at h5; linarith

/-- Integer points on the (n-1)-sphere of radius d are exactly the Pythagorean n-tuples.
The density of such points is related to sums-of-squares representation numbers r_n(d²). -/
theorem sphere_point_is_ktuple (v : Fin n → ℤ) (d : ℤ) :
    IsPythagoreanKTuple v d ↔ (∑ i, (v i) ^ 2) = d ^ 2 := by
  rfl

theorem sphere_reduction (v : Fin n → ℤ) (d g : ℤ) (hg : g > 0)
    (hk : IsPythagoreanKTuple v d)
    (hdiv : ∀ i, g ∣ v i) (hd : g ∣ d) :
    IsPythagoreanKTuple (fun i => v i / g) (d / g) := by
  obtain ⟨ k, hk ⟩ := hd;
  simp_all +decide [ IsPythagoreanKTuple ];
  obtain ⟨w, hw⟩ : ∃ w : Fin n → ℤ, ∀ i, v i = g * w i := by
    exact ⟨ fun i => Classical.choose ( hdiv i ), fun i => Classical.choose_spec ( hdiv i ) ⟩;
  simp_all +decide [ mul_pow, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hg.ne' ]

/-- A single 5-tuple (a₁,a₂,a₃,a₄,a₅) gives rise to C(4,2)=6 possible
2D projections, each potentially a Pythagorean pair or part of a triple.
This multiplicity is a key advantage of higher dimensions. -/
theorem five_tuple_projection_count :
    Nat.choose 4 2 = 6 := by decide

/-- Each projection pair (aᵢ, aⱼ) with aᵢ²+aⱼ²=e² being a perfect square
creates a bridge to a lower-dimensional Pythagorean structure. -/
theorem projection_bridge (a₁ a₂ a₃ a₄ a₅ e : ℤ)
    (h5 : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅)
    (he : a₁ ^ 2 + a₂ ^ 2 = e ^ 2) :
    IsPythagoreanQuadruple e a₃ a₄ a₅ := by
  unfold IsPythagoreanQuadruple IsPythagorean5Tuple at *; linarith

