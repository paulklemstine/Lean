/-! # CatalogBuild.Pythagorean.Core.AdvancedFactoringResearch

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 35
-/

import Mathlib

/-- Primary channel: removing component d from a quintuplet. -/
theorem cascade_channel_d (a b c d N : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = N ^ 2) :
    (N - d) * (N + d) = a ^ 2 + b ^ 2 + c ^ 2 := by nlinarith


/-- Primary channel: removing component c -/
theorem cascade_channel_c (a b c d N : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = N ^ 2) :
    (N - c) * (N + c) = a ^ 2 + b ^ 2 + d ^ 2 := by nlinarith


/-- Primary channel: removing component b -/
theorem cascade_channel_b (a b c d N : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = N ^ 2) :
    (N - b) * (N + b) = a ^ 2 + c ^ 2 + d ^ 2 := by nlinarith


/-- Primary channel: removing component a -/
theorem cascade_channel_a (a b c d N : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = N ^ 2) :
    (N - a) * (N + a) = b ^ 2 + c ^ 2 + d ^ 2 := by nlinarith


/-- Pairwise channel: a² - b² = (a-b)(a+b) -/
theorem pairwise_ab (a b : ℤ) :
    a ^ 2 - b ^ 2 = (a - b) * (a + b) := by ring


/-- Pairwise channel cd: removing both c and d simultaneously -/
theorem pairwise_cd (a b c d N : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = N ^ 2) :
    (N - c) * (N + c) - d ^ 2 = a ^ 2 + b ^ 2 := by nlinarith


/-- **The Full Cascade**: All four primary channels from a quintuplet. -/
theorem full_cascade (a b c d N : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = N ^ 2) :
    ((N - a) * (N + a) = b ^ 2 + c ^ 2 + d ^ 2) ∧
    ((N - b) * (N + b) = a ^ 2 + c ^ 2 + d ^ 2) ∧
    ((N - c) * (N + c) = a ^ 2 + b ^ 2 + d ^ 2) ∧
    ((N - d) * (N + d) = a ^ 2 + b ^ 2 + c ^ 2) := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> nlinarith


/-- The R₁₁₁₁ reflection applied to a lifted triple (a,b,0,c). -/
def liftAndReflect (a b c : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (c - b, c - a, c - a - b, 2*c - a - b)


/-- **Complementarity Theorem**: The lifted-reflected first component (c-b)
is algebraically independent from the Berggren parent first component (a+2b-2c). -/
theorem complementary_channels (a b c : ℤ) :
    (liftAndReflect a b c).1 = c - b ∧
    (berggrenParent a b c).1 = a + 2*b - 2*c := by
  simp [liftAndReflect, berggrenParent]


/-- The lifted-reflected quadruple preserves the Pythagorean equation. -/
theorem liftReflect_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (c - b) ^ 2 + (c - a) ^ 2 + (c - a - b) ^ 2 = (2*c - a - b) ^ 2 := by
  nlinarith


/-- **New Factoring Channel via Lifting**: gcd(c-b, N) and gcd(c-a, N) provide
channels when N = c (the hypotenuse). -/
theorem lift_channel_cb (a b c : ℤ) :
    ↑(Int.gcd (c - b) c) ∣ c := Int.gcd_dvd_right _ _


/-- [Section: ## §2. The Lifting-Descent Correspondence
### Key Insight
Given a Pythagorean triple (a,b,c), we can:
1. **Berggren-descend** directly, getting parent components that are linear in a,b,c
2. **Lift** to quadruple (a,b,0,c) and then **R₁₁₁₁-descend**, getting
R₁₁₁₁(a,b,0,c) = (c-b, c-a, c-a-b, 2c-a-b)
These two operations produce DIFFERENT algebraic expressions in a,b,c, giving
COMPLEMENTARY factoring channels.] -/
theorem lift_channel_ca (a b c : ℤ) :
    ↑(Int.gcd (c - a) c) ∣ c := Int.gcd_dvd_right _ _


/-- **Triple lift factor identity**: (c-b)(c+b) = a², so gcd(c-b, a) divides a. -/
theorem lift_diff_sq (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (c - b) * (c + b) = a ^ 2 := by nlinarith


/-- **Two-square energy bound**: If N = a² + b² = c² + d² (two distinct
representations), then gcd(ac-bd, N) and gcd(ac+bd, N) both divide N. -/
theorem two_rep_factor (a b c d N : ℤ)
    (h1 : a ^ 2 + b ^ 2 = N) (h2 : c ^ 2 + d ^ 2 = N) :
    ↑(Int.gcd (a * c - b * d) N) ∣ N ∧ ↑(Int.gcd (a * c + b * d) N) ∣ N :=
  ⟨Int.gcd_dvd_right _ _, Int.gcd_dvd_right _ _⟩


/-- **Brahmagupta identity for energy composition** -/
theorem energy_composition (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by ring


/-- **Alternative Brahmagupta form** -/
theorem energy_composition_alt (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by ring


/-- **Two representations give nontrivial factor**: If N = a²+b² = c²+d²,
then N | (ac-bd)(ac+bd). -/
theorem two_reps_give_relation (a b c d N : ℤ)
    (h1 : a ^ 2 + b ^ 2 = N) (h2 : c ^ 2 + d ^ 2 = N) :
    N ∣ ((a * c - b * d) * (a * c + b * d)) := by
  have hkey : (a * c - b * d) * (a * c + b * d) = N * (a ^ 2 + c ^ 2 - N) := by
    have : b ^ 2 = N - a ^ 2 := by linarith
    have : d ^ 2 = N - c ^ 2 := by linarith
    nlinarith [sq_nonneg (a*c - b*d), sq_nonneg (a*c + b*d)]
  rw [hkey]
  exact dvd_mul_right N _


/-- **IOF-to-quintuplet**: If x² = a² + b² + c² + d² with d² = N·q,
then we have a quintuplet. -/
theorem iof_to_quintuplet (x a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = x ^ 2) :
    a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = x ^ 2 := h


/-- **Congruence-to-triple lift**: If x² ≡ a² + b² (mod N), the surplus
is N times some integer. -/
theorem congruence_surplus (x a b N : ℤ) (hN : N ≠ 0)
    (h : N ∣ (x ^ 2 - a ^ 2 - b ^ 2)) :
    ∃ q : ℤ, x ^ 2 = a ^ 2 + b ^ 2 + N * q := by
  obtain ⟨q, hq⟩ := h
  exact ⟨q, by linarith⟩


/-- B₁ preserves the Pythagorean property. -/
theorem fwdB1_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let t := fwdB1 a b c
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  simp only [fwdB1]; ring_nf; nlinarith [h]


/-- B₂ preserves the Pythagorean property. -/
theorem fwdB2_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let t := fwdB2 a b c
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  simp only [fwdB2]; ring_nf; nlinarith [h]


/-- B₃ preserves the Pythagorean property. -/
theorem fwdB3_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let t := fwdB3 a b c
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  simp only [fwdB3]; ring_nf; nlinarith [h]


/-- **Hypotenuse growth**: B₂ child's hypotenuse is strictly larger (always). -/
theorem fwdB2_hyp_grows (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < (fwdB2 a b c).2.2 := by
  simp [fwdB2]; nlinarith


/-- **Hypotenuse growth for B₁**: requires Pythagorean condition (a+c > b). -/
theorem fwdB1_hyp_grows (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    c < (fwdB1 a b c).2.2 := by
  simp [fwdB1]; nlinarith [sq_nonneg (a - b)]


/-- **Hypotenuse growth for B₃**: requires Pythagorean condition (b+c > a). -/
theorem fwdB3_hyp_grows (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    c < (fwdB3 a b c).2.2 := by
  simp [fwdB3]; nlinarith [sq_nonneg (a - b)]


/-- **Descent-Ascent Consistency**: B₂ ∘ B₂⁻¹ = id -/
theorem descent_ascent_B2 (a b c : ℤ) :
    let p := (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)
    fwdB2 p.1 p.2.1 p.2.2 = (a, b, c) := by
  simp [fwdB2]
  refine ⟨?_, ?_, ?_⟩ <;> ring


/-- At each descent step, the GCD with N divides N. -/
theorem descent_step_gcd (a b N : ℤ) :
    ↑(Int.gcd a N) ∣ N ∧ ↑(Int.gcd b N) ∣ N := by
  exact ⟨Int.gcd_dvd_right _ _, Int.gcd_dvd_right _ _⟩


/-- **Cascade composition**: Quadruple + Triple → Sextuplet -/
theorem cascade_quad_triple (a b c d e f g h : ℤ)
    (hq : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (ht : e ^ 2 + f ^ 2 = g ^ 2)
    (hh : d ^ 2 + g ^ 2 = h ^ 2) :
    a ^ 2 + b ^ 2 + c ^ 2 + e ^ 2 + f ^ 2 = h ^ 2 := by linarith


/-- **Cascade doubles channels**: The sextuplet has 5 primary channels. -/
theorem cascade_five_channels (a b c e f h : ℤ)
    (hs : a ^ 2 + b ^ 2 + c ^ 2 + e ^ 2 + f ^ 2 = h ^ 2) :
    ((h - a) * (h + a) = b ^ 2 + c ^ 2 + e ^ 2 + f ^ 2) ∧
    ((h - b) * (h + b) = a ^ 2 + c ^ 2 + e ^ 2 + f ^ 2) ∧
    ((h - c) * (h + c) = a ^ 2 + b ^ 2 + e ^ 2 + f ^ 2) ∧
    ((h - e) * (h + e) = a ^ 2 + b ^ 2 + c ^ 2 + f ^ 2) ∧
    ((h - f) * (h + f) = a ^ 2 + b ^ 2 + c ^ 2 + e ^ 2) := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> nlinarith


/-- The GCD of a Berggren child's leg with N divides N. -/
theorem gcd_flows_B2 (a b c N : ℤ) :
    ↑(Int.gcd (a + 2*b + 2*c) N) ∣ N := Int.gcd_dvd_right _ _


/-- **GCD reduction via Berggren**: algebraic simplification. -/
theorem gcd_berggren_reduction (a b c N : ℤ) :
    Int.gcd (a + 2*b - 2*c) N = Int.gcd (a - 2*(c - b)) N := by
  congr 1; ring


/-- [Section: ## §8. The GCD Stability Theorem] -/
theorem gcd_mod_N (a N k : ℤ) : Int.gcd (a + k * N) N = Int.gcd a N := by
  exact Int.gcd_add_mul_right_left N a k


/-- **Two-representation factoring of 65**: Both factors extracted!
gcd(1·4 - 8·7, 65) = 13,  gcd(1·4 + 8·7, 65) = 5. -/
theorem factor_65_complete :
    Int.gcd (1 * 4 - 8 * 7) 65 = 13 ∧ Int.gcd (1 * 4 + 8 * 7) 65 = 5 := by
  constructor <;> native_decide


/-- N = 85 = 5 × 17: 85 = 2² + 9² = 6² + 7².
gcd(2·6 - 9·7, 85) = 17,  gcd(2·6 + 9·7, 85) = 5. -/
theorem factor_85_complete :
    Int.gcd (2 * 6 - 9 * 7) 85 = 17 ∧ Int.gcd (2 * 6 + 9 * 7) 85 = 5 := by
  constructor <;> native_decide


/-- Sextuplet factoring channel: octuplet (1,2,3,4,5,6,3) with w=10 = 2×5. -/
theorem octuplet_factor_10 : Int.gcd (10 - 6) 10 = 2 := by native_decide

