/-! # CatalogBuild.InformationTheory.InfiniteCompression

Auto-generated from theorem catalog database.
Domain: InformationTheory
Declarations: 22
-/

import Mathlib

noncomputable section

theorem stereo_denom_ne_zero (u v : ℝ) : u ^ 2 + v ^ 2 + 1 ≠ 0 := by
  nlinarith [sq_nonneg u, sq_nonneg v]

/-
PROBLEM
**Main theorem**: Inverse stereographic projection lands on S².
For any (u, v) ∈ ℝ², let D = u² + v² + 1. Then:
  (2u/D)² + (2v/D)² + ((u²+v²−1)/D)² = 1

PROVIDED SOLUTION
Clear denominators with field_simp [stereo_denom_ne_zero], then use ring to verify the polynomial identity (2u)² + (2v)² + (u²+v²−1)² = (u²+v²+1)².
-/

theorem inverse_stereo_on_sphere (u v : ℝ) :
    (2 * u / (u ^ 2 + v ^ 2 + 1)) ^ 2 +
    (2 * v / (u ^ 2 + v ^ 2 + 1)) ^ 2 +
    ((u ^ 2 + v ^ 2 - 1) / (u ^ 2 + v ^ 2 + 1)) ^ 2 = 1 := by
  -- Combine the fractions over a common denominator.
  field_simp
  ring

/-! ## §2: 1D Stereographic Projection (Circle)

The 1D version maps ℝ to S¹ \ {(0, 1)} via:
  σ⁻¹(t) = (2t/(t²+1), (t²−1)/(t²+1))
-/

/-- The 1D denominator t² + 1 is always positive. -/

theorem stereo_1d_denom_pos (t : ℝ) : 0 < t ^ 2 + 1 := by
  nlinarith [sq_nonneg t]

/-- The 1D denominator t² + 1 is never zero. -/

theorem stereo_1d_denom_ne_zero (t : ℝ) : t ^ 2 + 1 ≠ 0 := by
  nlinarith [sq_nonneg t]

/-
PROBLEM
**1D sphere landing**: Inverse stereographic projection maps to S¹.
  (2t/(t²+1))² + ((t²−1)/(t²+1))² = 1

PROVIDED SOLUTION
Clear denominators with field_simp [stereo_1d_denom_ne_zero], then use ring to verify (2t)² + (t²−1)² = (t²+1)².
-/

theorem inverse_stereo_on_circle (t : ℝ) :
    (2 * t / (t ^ 2 + 1)) ^ 2 +
    ((t ^ 2 - 1) / (t ^ 2 + 1)) ^ 2 = 1 := by
  -- Combine the fractions over a common denominator.
  field_simp
  ring

/-! ## §3: Stereographic Roundtrip

Forward stereographic projection σ(x, y) = x/(1+y) is the inverse
of σ⁻¹(t) = (2t/(t²+1), (t²−1)/(t²+1)), provided y ≠ −1.
-/

/-
PROBLEM
**Forward ∘ Inverse = Identity**: Applying forward stereographic projection
(from the north pole) to the image of inverse stereographic projection recovers
the original parameter. The north-pole forward projection is σ(x,y) = x/(1−y).

  σ(σ⁻¹(t)) = (2t/(t²+1)) / (1 − (t²−1)/(t²+1)) = t

PROVIDED SOLUTION
1 - (t²-1)/(t²+1) = (t²+1-t²+1)/(t²+1) = 2/(t²+1). So the expression is (2t/(t²+1)) / (2/(t²+1)) = t. Use field_simp [stereo_1d_denom_ne_zero] and ring.
-/

theorem stereo_roundtrip (t : ℝ) :
    (2 * t / (t ^ 2 + 1)) / (1 - (t ^ 2 - 1) / (t ^ 2 + 1)) = t := by
  field_simp;
  ring

/-
PROBLEM
**Inverse ∘ Forward = Identity (first component)**: For (x,y) on S¹ with y ≠ −1,
the first component of σ⁻¹(σ(x,y)) equals x.

PROVIDED SOLUTION
Use field_simp to clear denominators using hy and the fact that (x/(1+y))²+1 ≠ 0. Then use nlinarith or linear_combination with hunit to close the polynomial identity.
-/

theorem stereo_inverse_forward_fst (x y : ℝ) (hunit : x ^ 2 + y ^ 2 = 1)
    (hy : 1 + y ≠ 0) :
    2 * (x / (1 + y)) / ((x / (1 + y)) ^ 2 + 1) = x := by
  grind

/-
PROBLEM
**Inverse ∘ Forward = Identity (second component)**: For (x,y) on S¹ with y ≠ 1,
the second component of σ⁻¹(σ(x,y)) equals y, where σ(x,y) = x/(1−y).

PROVIDED SOLUTION
Use field_simp to clear denominators using hy and the fact that (x/(1-y))²+1 > 0. Then nlinarith or linear_combination using hunit : x²+y²=1.
-/

theorem stereo_inverse_forward_snd (x y : ℝ) (hunit : x ^ 2 + y ^ 2 = 1)
    (hy : 1 - y ≠ 0) :
    ((x / (1 - y)) ^ 2 - 1) / ((x / (1 - y)) ^ 2 + 1) = y := by
  grind

/-! ## §4: The Z-Coordinate and Solid Angle

The Z-coordinate of the stereographic image controls how close a point
is to the north pole. As (u,v) → ∞, Z → 1 (approaching the pole).
The solid angle subtended from the pole is 2π(1 − Z).
-/

/-
PROBLEM
The Z-coordinate is always in [−1, 1] (it's on the unit sphere).

PROVIDED SOLUTION
Split into two inequalities. For -1 ≤ Z: have D = u²+v²+1 > 0 (stereo_denom_pos). Then Z = (u²+v²-1)/D. We need u²+v²-1 ≥ -D = -(u²+v²+1), i.e., 2(u²+v²) ≥ 0, true. For Z ≤ 1: need u²+v²-1 ≤ D = u²+v²+1, i.e., -1 ≤ 1, true. Use div_le_one and le_div_iff with stereo_denom_pos.
-/

theorem stereo_z_bounded (u v : ℝ) :
    -1 ≤ (u ^ 2 + v ^ 2 - 1) / (u ^ 2 + v ^ 2 + 1) ∧
    (u ^ 2 + v ^ 2 - 1) / (u ^ 2 + v ^ 2 + 1) ≤ 1 := by
  exact ⟨ by rw [ le_div_iff₀ <| by positivity ] ; nlinarith, by rw [ div_le_iff₀ <| by positivity ] ; nlinarith ⟩

/-- At the origin (u=0, v=0), Z = −1 (south pole). -/

theorem stereo_origin_south_pole :
    ((0 : ℝ) ^ 2 + (0 : ℝ) ^ 2 - 1) / ((0 : ℝ) ^ 2 + (0 : ℝ) ^ 2 + 1) = -1 := by
  norm_num

/-
PROBLEM
The "solid angle factor" 1 − Z is always non-negative.

PROVIDED SOLUTION
Rewrite using solid_angle_formula to get 0 ≤ 2/(u²+v²+1). This follows since the denominator is positive (stereo_denom_pos). Alternatively, direct: 1 - Z ≥ 0 follows from Z ≤ 1, which is the second part of stereo_z_bounded.
-/

theorem solid_angle_nonneg (u v : ℝ) :
    0 ≤ 1 - (u ^ 2 + v ^ 2 - 1) / (u ^ 2 + v ^ 2 + 1) := by
  exact sub_nonneg_of_le ( div_le_one_of_le₀ ( by nlinarith ) ( by nlinarith ) )

/-
PROBLEM
The solid angle factor simplifies to 2/(u²+v²+1).

PROVIDED SOLUTION
1 - (u²+v²-1)/(u²+v²+1) = (u²+v²+1 - u² - v² + 1)/(u²+v²+1) = 2/(u²+v²+1). Use field_simp [stereo_denom_ne_zero] and ring.
-/

theorem solid_angle_formula (u v : ℝ) :
    1 - (u ^ 2 + v ^ 2 - 1) / (u ^ 2 + v ^ 2 + 1) =
    2 / (u ^ 2 + v ^ 2 + 1) := by
  rw [ one_sub_div ] <;> ring ; positivity

/-
PROBLEM
As stereographic radius r = √(u²+v²) grows, the solid angle factor
shrinks. Specifically, for r₁ ≤ r₂, the solid angle at r₂ is ≤ that at r₁.
(We prove this for points on the u-axis for simplicity.)

PROVIDED SOLUTION
Since r₁ ≤ r₂ and both nonneg, r₁² ≤ r₂², so r₁²+1 ≤ r₂²+1. Both are positive. Then 2/(r₂²+1) ≤ 2/(r₁²+1) by div_le_div_of_nonneg_left or similar. Use `apply div_le_div_of_nonneg_left` with positivity for the numerator and denominators, and use `nlinarith [sq_le_sq']` or `mono` for r₁² ≤ r₂².
-/

theorem solid_angle_decreasing (r₁ r₂ : ℝ) (hr₁ : 0 ≤ r₁) (_hr₂ : 0 ≤ r₂)
    (h : r₁ ≤ r₂) :
    2 / (r₂ ^ 2 + 1) ≤ 2 / (r₁ ^ 2 + 1) := by
  gcongr

/-! ## §5: Compression Impossibility — Pigeonhole Meets Stereographic Projection

No matter how cleverly we use stereographic projection (or any other
mathematical device), we cannot losslessly compress ALL n-bit strings
to fewer bits. The pigeonhole principle is inescapable.
-/

/-
PROBLEM
**Fundamental compression impossibility (pigeonhole).**
No injection exists from a set of size M to a set of size N when N < M.

PROVIDED SOLUTION
Intro the existential, get f and hf : Injective f. Then Fintype.card_le_of_injective gives card (Fin M) ≤ card (Fin N), i.e. M ≤ N, contradicting h : N < M.
-/

theorem compression_pigeonhole {M N : ℕ} (h : N < M) :
    ¬ ∃ f : Fin M → Fin N, Function.Injective f := by
  exact fun ⟨ f, hf ⟩ => absurd ( Nat.card_le_card_of_injective f hf ) ( by simpa )

/-
PROBLEM
**Stereographic encoding cannot beat pigeonhole.**
Even if we encode n-bit strings as points on a sphere using stereographic
projection, and then discretize to (n−1)-bit indices, we lose injectivity.

PROVIDED SOLUTION
Apply compression_pigeonhole. Need 2^(n-1) < 2^n. Use Nat.pow_lt_pow_right with base 2 and n-1 < n (from hn).
-/

theorem stereo_compression_impossible (n : ℕ) (hn : 1 ≤ n) :
    ¬ ∃ f : Fin (2^n) → Fin (2^(n-1)), Function.Injective f := by
  convert compression_pigeonhole _;
  exact pow_lt_pow_right₀ ( by decide ) ( Nat.pred_lt ( ne_bot_of_gt hn ) )

/-
PROBLEM
**Lossless encoding requires injectivity.**
If decode ∘ encode = id, then encode is injective.

PROVIDED SOLUTION
intro a b hab. Then decode (encode a) = decode (encode b) by congr. By h, decode (encode a) = a and decode (encode b) = b. So a = b.
-/

theorem lossless_is_injective {α β : Type*} (encode : α → β) (decode : β → α)
    (h : ∀ x, decode (encode x) = x) : Function.Injective encode := by
  exact fun x y hxy => h x ▸ h y ▸ hxy ▸ rfl

/-
PROBLEM
**The impossibility theorem for "infinite compression".**
No lossless encoder-decoder pair can map 2^n values into 2^(n−1) slots.

PROVIDED SOLUTION
Use lossless_is_injective to get that encode is injective. Then use stereo_compression_impossible to get a contradiction: ⟨encode, hinj⟩ contradicts the non-existence.
-/

theorem infinite_compression_impossible (n : ℕ) (hn : 1 ≤ n)
    (encode : Fin (2^n) → Fin (2^(n-1)))
    (decode : Fin (2^(n-1)) → Fin (2^n))
    (h : ∀ x, decode (encode x) = x) : False := by
  exact stereo_compression_impossible n hn ⟨encode, lossless_is_injective encode decode h⟩

/-! ## §6: Quantization Error Grows with Compression

When we pack data closer to the pole (higher compression level), the
stereographic coordinates shrink (u, v → 0). Any finite-precision
quantization of these coordinates loses information — the reconstruction
error grows as precision requirements exceed the available bits.
-/

/-
PROBLEM
**Quantization resolution lemma**: Dividing the interval [0, R] into
2^k equal bins gives bin width R / 2^k. To represent M distinct values
in this interval with no collisions, we need M ≤ 2^k.

PROVIDED SOLUTION
This is just compression_pigeonhole applied with N = 2^k and M = M.
-/

theorem quantization_resolution (M k : ℕ) (h : 2 ^ k < M) :
    ¬ ∃ f : Fin M → Fin (2 ^ k), Function.Injective f := by
  exact fun ⟨ f, hf ⟩ => absurd ( Fintype.card_le_of_injective f hf ) ( by simpa using h )

/-! ## §7: Warped Arithmetic Properties

The Python script defines "warped addition" using the stereographic circle group.
At warp factor 0, this reduces to standard addition. We prove the key algebraic
identities underlying this construction.
-/

/-
PROBLEM
The stereographic "circle multiplication" formula:
if (x₁,y₁) and (x₂,y₂) are on S¹, then
(x₁x₂ − y₁y₂, x₁y₂ + y₁x₂) is also on S¹.
(This is just complex multiplication restricted to the unit circle.)

PROVIDED SOLUTION
Expand and use nlinarith with h₁ and h₂. The polynomial identity: (x₁x₂-y₁y₂)² + (x₁y₂+y₁x₂)² = x₁²x₂² - 2x₁x₂y₁y₂ + y₁²y₂² + x₁²y₂² + 2x₁y₂y₁x₂ + y₁²x₂² = x₁²(x₂²+y₂²) + y₁²(x₂²+y₂²) = (x₁²+y₁²)(x₂²+y₂²) = 1. So nlinarith [h₁, h₂] or linear_combination (x₁^2+y₁^2-1)*(x₂^2+y₂^2) + h₁.
-/

theorem circle_mul_on_circle (x₁ y₁ x₂ y₂ : ℝ)
    (h₁ : x₁ ^ 2 + y₁ ^ 2 = 1) (h₂ : x₂ ^ 2 + y₂ ^ 2 = 1) :
    (x₁ * x₂ - y₁ * y₂) ^ 2 + (x₁ * y₂ + y₁ * x₂) ^ 2 = 1 := by
  linear_combination' h₁ * h₂

/-
PROBLEM
The stereographic "tangent addition" formula:
(a + b) / (1 − ab) is the tangent addition formula, which corresponds
to angle addition on the circle via t ↦ (2t/(1+t²), (t²−1)/(1+t²)).

PROVIDED SOLUTION
The let t := ... just defines t. Then the goal is inverse_stereo_on_circle t, which is already proved. Apply inverse_stereo_on_circle.
-/

theorem tangent_addition (a b : ℝ) (_hab : 1 - a * b ≠ 0) :
    let t := (a + b) / (1 - a * b)
    (2 * t / (t ^ 2 + 1)) ^ 2 + ((t ^ 2 - 1) / (t ^ 2 + 1)) ^ 2 = 1 := by
  exact inverse_stereo_on_circle _

/-! ## §8: Information-Theoretic Density

The "informational mass" concept from the Python script measures
bits per solid angle. We prove that as the solid angle approaches 0
(data packed near the pole), the density grows without bound —
but this does NOT enable lossless compression of more data than
the pigeonhole principle allows.
-/

/-
PROBLEM
**Density divergence**: For n bits packed into solid angle Ω,
the density n/Ω → ∞ as Ω → 0⁺. Formally, for any bound B,
there exists a small enough Ω such that n/Ω > B.

PROVIDED SOLUTION
Choose Ω = n / (|B| + 1). Then Ω > 0 since n > 0 and |B|+1 > 0. And n/Ω = |B|+1 > B. Actually more carefully: if B ≤ 0, choose Ω = 1, then n/1 = n ≥ 1 > B. If B > 0, choose Ω = n/(B+1), then n/Ω = B+1 > B. Use refine ⟨(n : ℝ) / (max B 0 + 1), ?_, ?_⟩ and verify.
-/

theorem density_diverges (n : ℕ) (hn : 0 < n) (B : ℝ) :
    ∃ Ω : ℝ, 0 < Ω ∧ (n : ℝ) / Ω > B := by
  exact ⟨ n / ( |B| + 1 ), by positivity, by rw [ div_div_cancel₀ ( by positivity ) ] ; cases abs_cases B <;> linarith ⟩

/-
PROBLEM
**The central impossibility**: Infinite informational density does not
enable infinite compression. Even with density → ∞, the number of
distinguishable states in any finite-precision representation is bounded.

PROVIDED SOLUTION
Apply compression_pigeonhole. Need 2^k < 2^n. Use Nat.pow_lt_pow_right with hk.
-/

theorem density_vs_pigeonhole (n k : ℕ) (hk : k < n) :
    ¬ ∃ f : Fin (2^n) → Fin (2^k), Function.Injective f := by
  convert compression_pigeonhole _;
  exact pow_lt_pow_right₀ ( by norm_num ) hk


end
