import Computation.BerggrenHyperbolicGeodesics

/-!
# Classification of the exact "straight lines" through the centre

Second research cycle on the hyperbolic picture of the Berggren tree.  The first cycle
(`Computation.BerggrenHyperbolicGeodesics`) produced

* the master identity for `cosh` of the distance between two Euclid-seed nodes,
* the Gram invariant `Φ` as an exact test for hyperbolic collinearity,
* the arithmetic bridge `Φ = (Δ / 2 m₁m₂m₃)²` with `Δ` an integer determinant,
* families of exactly collinear seeds coming from the Pell-like conics `m² - k m n - n² = 1`.

This file closes the loop on the *classification* question: which nodes lie on a straight line
through the centre, and where exactly are they?

## Main results

* `seedDet_base_eq`, `seedDet_base_eq_zero_iff_radial` — the determinant of a triangle with a
  vertex at the base point factors through the **radial invariant** `ϱ(m,n) = (m²-n²-1)/(mn)`:
  two seeds are radially aligned with `i` iff their radial invariants agree.  The level sets of
  `ϱ` are exactly the conics `m² - ϱ m n - n² = 1`.
* `seedDet_eq_zero_of_onConic` — *any* three points of one conic `m² - k m n - n² = 1` are
  hyperbolically collinear (a one-line proof once the determinant is available: the first column
  becomes `col₃ - k col₂`).
* `pell_classification` — every integral point of the conic with `m > 0`, `n ≥ 0` is on the
  forward orbit of `(1,0)` under the conic automorphism; the proof is a Vieta descent using the
  auxiliary bound `conic_k_le_n`.
* `dist_base_quantized` — **quantization of distance**: the hyperbolic distance from `i` to any
  conic node is an exact integer multiple of `2 log λ_k`, `λ_k` the `k`-th metallic ratio.
* `dist_pellOrbit` — the orbit is an isometric copy of `ℕ`: `d(Pᵢ, Pⱼ) = |i - j| · 2 log λ_k`.
  So each conic is a perfectly evenly spaced discrete geodesic — the straight lines of the
  picture are arithmetic progressions in disguise.

## Lab notes

`ϱ(2,1) = ϱ(5,3) = ϱ(13,8) = 1`, `ϱ(5,2) = ϱ(29,12) = ϱ(169,70) = 2`, `ϱ(10,3) = ϱ(109,33) = 3`:
the Fibonacci pairs, the even Pell spine and the "bronze" family are the first three exact rays.
Distances from `i` on the `k = 2` ray: `0, 1.7627…, 3.5255…, 5.2882…` — exactly `j · 2 log λ₂`
with `λ₂ = 1 + √2`.
-/

noncomputable section

open UpperHalfPlane Real

namespace BerggrenHyperbolic

/-! ## 1. The radial invariant -/

/-- Radial invariant of a Euclid seed: the parameter of the geodesic through `i` on which the
node lies.  Two seeds are aligned with the base point exactly when these agree. -/
def radial (m n : ℝ) : ℝ := (m ^ 2 - n ^ 2 - 1) / (m * n)

/-- The seed determinant of a triangle with one vertex at the base point `i = z(1,0)`. -/
theorem seedDet_base_eq (m₁ n₁ m₂ n₂ : ℝ) :
    seedDet 1 0 m₁ n₁ m₂ n₂
      = n₁ * m₁ * (m₂ ^ 2 - n₂ ^ 2 - 1) - n₂ * m₂ * (m₁ ^ 2 - n₁ ^ 2 - 1) := by
  simp only [seedDet]
  ring

/-- Radial alignment with the base point is exactly equality of radial invariants. -/
theorem seedDet_base_eq_zero_iff_radial (m₁ n₁ m₂ n₂ : ℝ) (hm₁ : 0 < m₁) (hn₁ : 0 < n₁)
    (hm₂ : 0 < m₂) (hn₂ : 0 < n₂) :
    seedDet 1 0 m₁ n₁ m₂ n₂ = 0 ↔ radial m₁ n₁ = radial m₂ n₂ := by
  rw [seedDet_base_eq, radial, radial, div_eq_div_iff (by positivity) (by positivity)]
  constructor <;> intro h <;> nlinarith [h]

/-- **Any three points of one Pell-like conic are hyperbolically collinear.**  The determinant
vanishes because the conic makes the first column of the defining matrix equal to
`col₃ - k · col₂`. -/
theorem seedDet_eq_zero_of_onConic (k m₁ n₁ m₂ n₂ m₃ n₃ : ℝ)
    (h₁ : m₁ ^ 2 - k * m₁ * n₁ - n₁ ^ 2 = 1) (h₂ : m₂ ^ 2 - k * m₂ * n₂ - n₂ ^ 2 = 1)
    (h₃ : m₃ ^ 2 - k * m₃ * n₃ - n₃ ^ 2 = 1) :
    seedDet m₁ n₁ m₂ n₂ m₃ n₃ = 0 := by
  simp only [seedDet]
  linear_combination (-(n₂ * m₂ * m₃ ^ 2 - m₂ ^ 2 * (n₃ * m₃))) * h₁
    + (n₁ * m₁ * m₃ ^ 2 - m₁ ^ 2 * (n₃ * m₃)) * h₂
    + (-(n₁ * m₁ * m₂ ^ 2 - m₁ ^ 2 * (n₂ * m₂))) * h₃

/-- Bridge: a vanishing seed determinant plus the correct ordering gives exact additivity of
hyperbolic distances. -/
theorem dist_add_dist_of_seedDet_zero (m₁ n₁ m₂ n₂ m₃ n₃ : ℝ) (h₁ : 0 < m₁) (h₂ : 0 < m₂)
    (h₃ : 0 < m₃) (hdet : seedDet m₁ n₁ m₂ n₂ m₃ n₃ = 0)
    (hle : coshK m₁ n₁ m₂ n₂ * coshK m₂ n₂ m₃ n₃ ≤ coshK m₁ n₁ m₃ n₃) :
    dist (node m₁ n₁) (node m₂ n₂) + dist (node m₂ n₂) (node m₃ n₃)
      = dist (node m₁ n₁) (node m₃ n₃) := by
  refine dist_add_dist_of_gram_zero _ _ _ ?_ ?_
  · rw [cosh_dist_node _ _ _ _ h₁ h₂, cosh_dist_node _ _ _ _ h₂ h₃, cosh_dist_node _ _ _ _ h₁ h₃,
      gram_eq_seedDet_sq _ _ _ _ _ _ h₁.ne' h₂.ne' h₃.ne', hdet]
    simp
  · rwa [cosh_dist_node _ _ _ _ h₁ h₂, cosh_dist_node _ _ _ _ h₂ h₃,
      cosh_dist_node _ _ _ _ h₁ h₃]

/-- Conversely, collinear seed nodes have vanishing determinant. -/
theorem seedDet_eq_zero_of_dist_add_dist (m₁ n₁ m₂ n₂ m₃ n₃ : ℝ) (h₁ : 0 < m₁) (h₂ : 0 < m₂)
    (h₃ : 0 < m₃)
    (h : dist (node m₁ n₁) (node m₂ n₂) + dist (node m₂ n₂) (node m₃ n₃)
      = dist (node m₁ n₁) (node m₃ n₃)) :
    seedDet m₁ n₁ m₂ n₂ m₃ n₃ = 0 := by
  have hg := gram_eq_zero_of_dist_add_dist _ _ _ h
  rw [cosh_dist_node _ _ _ _ h₁ h₂, cosh_dist_node _ _ _ _ h₂ h₃, cosh_dist_node _ _ _ _ h₁ h₃,
    gram_eq_seedDet_sq _ _ _ _ _ _ h₁.ne' h₂.ne' h₃.ne'] at hg
  have h0 := pow_eq_zero_iff (n := 2) (by norm_num) |>.1 hg
  rcases div_eq_zero_iff.1 h0 with h' | h'
  · exact h'
  · exact absurd h' (by positivity)

/-! ## 2. Vieta descent: the conic is exactly one orbit -/

/-- On the positive branch of the conic the second coordinate is at least `k`. -/
theorem conic_k_le_n {k m n : ℤ} (hm : 0 < m) (hn : 0 < n)
    (hc : m ^ 2 - k * m * n - n ^ 2 = 1) : k ≤ n := by
  by_contra hlt
  push_neg at hlt
  have hu : 0 < m - k * n := by nlinarith
  have hu1 : 1 ≤ m - k * n := hu
  nlinarith [hu1, mul_pos hm hn, mul_pos hn hn]

/-- The Vieta predecessor of a conic point. -/
def pellPred (k : ℤ) (p : ℤ × ℤ) : ℤ × ℤ := (p.1 - k * p.2, (k ^ 2 + 1) * p.2 - k * p.1)

theorem pellStep_pellPred (k : ℤ) (p : ℤ × ℤ) : pellStep k (pellPred k p) = p := by
  obtain ⟨m, n⟩ := p
  simp only [pellStep, pellPred, Prod.mk.injEq]
  constructor <;> ring

theorem onConic_pellPred {k : ℤ} {p : ℤ × ℤ} (h : OnConic k p) : OnConic k (pellPred k p) := by
  obtain ⟨m, n⟩ := p
  simp only [OnConic, pellPred] at *
  nlinarith [h]

theorem pellPred_pos {k : ℤ} (hk : 0 < k) {p : ℤ × ℤ} (hc : OnConic k p) (hm : 0 < p.1)
    (hn : 0 < p.2) : 0 < (pellPred k p).1 ∧ 0 ≤ (pellPred k p).2 ∧ (pellPred k p).1 < p.1 := by
  obtain ⟨m, n⟩ := p
  simp only [OnConic] at hc
  simp only at hm hn
  have hkn : k ≤ n := conic_k_le_n hm hn hc
  have hu : 0 < m - k * n := by nlinarith
  -- `k (m - k n) ≤ n`, i.e. the new second coordinate stays nonnegative
  have hv : k * (m - k * n) ≤ n := by
    nlinarith [mul_pos hk hu, sq_nonneg (k * (m - k * n) - n), mul_pos hm hn]
  refine ⟨by simpa [pellPred] using hu, ?_, ?_⟩
  · simp only [pellPred]
    nlinarith
  · simp only [pellPred]
    nlinarith [mul_pos hk hn]

/-- **Classification.**  Every integral point of the conic `m² - k m n - n² = 1` with `m > 0`,
`n ≥ 0` lies on the forward orbit of the base point `(1,0)`. -/
theorem pell_classification {k : ℤ} (hk : 0 < k) :
    ∀ N : ℕ, ∀ p : ℤ × ℤ, p.1.toNat ≤ N → OnConic k p → 0 < p.1 → 0 ≤ p.2 →
      ∃ j : ℕ, pellOrbit k j = p := by
  intro N
  induction N with
  | zero =>
      intro p hN _ hm _
      omega
  | succ N ih =>
      intro p hN hc hm hn
      rcases eq_or_lt_of_le hn with h0 | h0
      · -- `n = 0` forces `m = 1`
        refine ⟨0, ?_⟩
        simp only [OnConic, ← h0] at hc
        have : p.1 = 1 := by nlinarith
        simp only [pellOrbit]
        exact Prod.ext this.symm h0
      · obtain ⟨hp1, hp2, hp3⟩ := pellPred_pos hk hc hm h0
        obtain ⟨j, hj⟩ := ih (pellPred k p) (by omega) (onConic_pellPred hc) hp1 hp2
        exact ⟨j + 1, by rw [show pellOrbit k (j + 1) = pellStep k (pellOrbit k j) from rfl, hj,
          pellStep_pellPred]⟩

/-! ## 3. Quantization of the distance to the centre -/

/-- **Distance quantization.**  The hyperbolic distance from the base point to a conic node is an
exact integer multiple of the step `2 log λ_k`. -/
theorem dist_base_quantized {k : ℤ} (hk : 0 < k) {m n : ℤ} (hc : OnConic k (m, n)) (hm : 0 < m)
    (hn : 0 ≤ n) :
    ∃ j : ℕ, dist base (node (m : ℝ) (n : ℝ)) = j * pellStepLength (k : ℝ) := by
  obtain ⟨j, hj⟩ := pell_classification hk m.toNat (m, n) le_rfl hc hm hn
  refine ⟨j, ?_⟩
  rw [← dist_base_pellOrbit k hk j, hj]

/-- Consecutive orbit points are at the constant distance `pellStepLength k`. -/
theorem dist_pellOrbit_succ {k : ℤ} (hk : 0 < k) (j : ℕ) :
    dist (node ((pellOrbit k j).1 : ℝ) ((pellOrbit k j).2 : ℝ))
      (node ((pellOrbit k (j + 1)).1 : ℝ) ((pellOrbit k (j + 1)).2 : ℝ))
      = pellStepLength (k : ℝ) := by
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  obtain ⟨hp1, hp2⟩ := pellOrbit_pos k hk j
  have hm : (0 : ℝ) < ((pellOrbit k j).1 : ℝ) := by exact_mod_cast hp1
  have hn : (0 : ℝ) ≤ ((pellOrbit k j).2 : ℝ) := by exact_mod_cast hp2
  have hc : ((pellOrbit k j).1 : ℝ) ^ 2 - (k : ℝ) * ((pellOrbit k j).1 : ℝ)
      * ((pellOrbit k j).2 : ℝ) - ((pellOrbit k j).2 : ℝ) ^ 2 = 1 := by
    have := onConic_pellOrbit k j
    simp only [OnConic] at this
    exact_mod_cast congrArg (fun x : ℤ => (x : ℝ)) this
  have e1 : ((pellOrbit k (j + 1)).1 : ℝ)
      = ((k : ℝ) ^ 2 + 1) * ((pellOrbit k j).1 : ℝ) + (k : ℝ) * ((pellOrbit k j).2 : ℝ) := by
    simp only [pellOrbit, pellStep]; push_cast; ring
  have e2 : ((pellOrbit k (j + 1)).2 : ℝ)
      = (k : ℝ) * ((pellOrbit k j).1 : ℝ) + ((pellOrbit k j).2 : ℝ) := by
    simp only [pellOrbit, pellStep]; push_cast; ring
  rw [e1, e2, dist_pellStep_eq _ _ _ hkR hm hn hc]

private lemma dist_pellOrbit_le {k : ℤ} (hk : 0 < k) (i : ℕ) :
    ∀ j : ℕ, dist (node ((pellOrbit k i).1 : ℝ) ((pellOrbit k i).2 : ℝ))
      (node ((pellOrbit k (i + j)).1 : ℝ) ((pellOrbit k (i + j)).2 : ℝ))
      ≤ j * pellStepLength (k : ℝ) := by
  intro j
  induction j with
  | zero => simp
  | succ j ih =>
      have htri := dist_triangle
        (node ((pellOrbit k i).1 : ℝ) ((pellOrbit k i).2 : ℝ))
        (node ((pellOrbit k (i + j)).1 : ℝ) ((pellOrbit k (i + j)).2 : ℝ))
        (node ((pellOrbit k (i + j + 1)).1 : ℝ) ((pellOrbit k (i + j + 1)).2 : ℝ))
      rw [dist_pellOrbit_succ hk (i + j)] at htri
      have : i + (j + 1) = i + j + 1 := by omega
      rw [this]
      push_cast
      linarith

/-- **The Pell orbit is an isometric copy of `ℕ`.**  Any two conic nodes are at distance exactly
`|i - j|` times the metallic step, so a Pell conic maps onto a perfectly evenly spaced discrete
geodesic of the hyperbolic plane. -/
theorem dist_pellOrbit {k : ℤ} (hk : 0 < k) (i j : ℕ) :
    dist (node ((pellOrbit k i).1 : ℝ) ((pellOrbit k i).2 : ℝ))
      (node ((pellOrbit k j).1 : ℝ) ((pellOrbit k j).2 : ℝ))
      = |(i : ℝ) - (j : ℝ)| * pellStepLength (k : ℝ) := by
  -- reduce to the case `i ≤ j`
  have key : ∀ a b : ℕ, a ≤ b →
      dist (node ((pellOrbit k a).1 : ℝ) ((pellOrbit k a).2 : ℝ))
        (node ((pellOrbit k b).1 : ℝ) ((pellOrbit k b).2 : ℝ))
        = ((b : ℝ) - (a : ℝ)) * pellStepLength (k : ℝ) := by
    intro a b hab
    obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le hab
    have hup := dist_pellOrbit_le hk a d
    have hlow := abs_dist_sub_le
      (node ((pellOrbit k a).1 : ℝ) ((pellOrbit k a).2 : ℝ))
      (node ((pellOrbit k (a + d)).1 : ℝ) ((pellOrbit k (a + d)).2 : ℝ)) base
    rw [dist_comm (node ((pellOrbit k a).1 : ℝ) _) base,
      dist_comm (node ((pellOrbit k (a + d)).1 : ℝ) _) base,
      dist_base_pellOrbit k hk a, dist_base_pellOrbit k hk (a + d)] at hlow
    have hL : 0 ≤ pellStepLength (k : ℝ) := by
      have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
      exact Real.arcosh_nonneg (by nlinarith)
    rw [abs_of_nonpos (by push_cast; nlinarith)] at hlow
    push_cast at hup hlow ⊢
    linarith
  rcases le_total i j with h | h
  · have hc : (i : ℝ) ≤ (j : ℝ) := by exact_mod_cast h
    rw [key i j h, abs_of_nonpos (by linarith)]
    ring
  · have hc : (j : ℝ) ≤ (i : ℝ) := by exact_mod_cast h
    rw [dist_comm, key j i h, abs_of_nonneg (by linarith)]

end BerggrenHyperbolic