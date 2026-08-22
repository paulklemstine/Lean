/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.ShallowProductCoinFullBox

/-!
# The sharp universal rigidity constant is `2 - φ = (3 - √5)/2`

`Catalog/Geometry/ShallowProductCoinRigidity.lean` proves the gap
`‖A(f ⊗ g)‖² ≤ |R| - 1/(9|R|)` for non-box resonance sets.  Exhaustive computation over
all non-box sets in grids up to `4 × 4` (and random sampling in `5 × 5`) shows that the
true gap never drops below `(3 - √5)/2 = 0.381966…`, and that this value is attained
exactly by the `L`-shape.  This file proves that sharp, **`|R|`-independent** bound.

## Main results

* `goldenGap` — the constant `(3 - √5)/2 = 2 - φ`, `φ` the golden ratio.
* `productCoin_amplitude_sq_le_golden` — for `R ⊆ A × B` not a box and any unit product
  coin, `‖A(f ⊗ g)‖² ≤ |R| - (3 - √5)/2`.
* `goldenGap_optimal` — the constant cannot be improved: the `L`-shape attains it.
* `productCoin_depth_amplitude_sq_le_golden` — the same bound at any depth and any
  coordinate split, and `productCoin_depth_golden_gap_of_not_isFullBox` for non-full-boxes.

## Proof mechanism

The key upgrade over the crude `1/(9|R|)` bound is an exact Eckart–Young step in
dimension two.  A rank-one matrix `X` kills a unit vector `n`; hence for the indicator
matrix `M` of `R`, restricted to the `2 × 2` block `!![1, 0; m₃, 1]` supplied by the
non-box witness,

  `‖M - X‖_F² ≥ ‖(M - X) n‖² = ‖M n‖² ≥ σ_min(M_block)²`,

and `σ_min !![1,0;1,1]² = (3 - √5)/2` is exactly the golden constant, minimal over
`m₃ ∈ [0,1]`.
-/

namespace Catalog.Geometry.ShallowProductCoin

open Finset

/-! ## 1. The golden constant -/

/-- The sharp universal rigidity constant `(3 - √5)/2 = 2 - φ`. -/
noncomputable def goldenGap : ℝ := (3 - Real.sqrt 5) / 2

lemma sqrt5_lt_nine_quarters : Real.sqrt 5 < 9 / 4 := by
  nlinarith [sqrt5_sq, Real.sqrt_nonneg (5:ℝ)]

lemma goldenGap_pos : 0 < goldenGap := by
  rw [goldenGap]
  have := sqrt5_bounds.2
  linarith

lemma goldenGap_lt_one : goldenGap < 1 := by
  rw [goldenGap]
  have := sqrt5_bounds.1
  linarith

/-- The golden constant is the small root of `g² - 3g + 1 = 0`. -/
lemma goldenGap_quadratic : goldenGap ^ 2 = 3 * goldenGap - 1 := by
  rw [goldenGap]
  nlinarith [sqrt5_sq]

/-! ## 2. The exact two-dimensional Eckart–Young step -/

/-- A singular `2 × 2` block annihilates some unit vector. -/
private lemma exists_unit_kernel (x1 x2 x3 x4 : ℝ) (h : x1 * x4 = x2 * x3) :
    ∃ n1 n2 : ℝ, n1 ^ 2 + n2 ^ 2 = 1 ∧ x1 * n1 + x2 * n2 = 0 ∧ x3 * n1 + x4 * n2 = 0 := by
  by_cases h12 : x1 ^ 2 + x2 ^ 2 = 0
  · have hx1 : x1 = 0 := by
      have : x1 ^ 2 = 0 := by linarith [sq_nonneg x1, sq_nonneg x2]
      exact (pow_eq_zero_iff two_ne_zero).mp this
    have hx2 : x2 = 0 := by
      have : x2 ^ 2 = 0 := by linarith [sq_nonneg x1, sq_nonneg x2]
      exact (pow_eq_zero_iff two_ne_zero).mp this
    by_cases h34 : x3 ^ 2 + x4 ^ 2 = 0
    · have hx3 : x3 = 0 := by
        have : x3 ^ 2 = 0 := by linarith [sq_nonneg x3, sq_nonneg x4]
        exact (pow_eq_zero_iff two_ne_zero).mp this
      have hx4 : x4 = 0 := by
        have : x4 ^ 2 = 0 := by linarith [sq_nonneg x3, sq_nonneg x4]
        exact (pow_eq_zero_iff two_ne_zero).mp this
      exact ⟨1, 0, by norm_num, by simp [hx1, hx2], by simp [hx3, hx4]⟩
    · have hpos : 0 < x3 ^ 2 + x4 ^ 2 :=
        lt_of_le_of_ne (by positivity) (Ne.symm h34)
      obtain ⟨r, hr⟩ : ∃ r : ℝ, r = Real.sqrt (x3 ^ 2 + x4 ^ 2) := ⟨_, rfl⟩
      have hrpos : 0 < r := by rw [hr]; exact Real.sqrt_pos.mpr hpos
      have hr2 : r ^ 2 = x3 ^ 2 + x4 ^ 2 := by
        rw [hr]; exact Real.sq_sqrt (le_of_lt hpos)
      refine ⟨-x4 / r, x3 / r, ?_, ?_, ?_⟩
      · field_simp
        linarith [hr2]
      · rw [hx1, hx2]; ring
      · field_simp
        ring
  · have hpos : 0 < x1 ^ 2 + x2 ^ 2 := lt_of_le_of_ne (by positivity) (Ne.symm h12)
    obtain ⟨r, hr⟩ : ∃ r : ℝ, r = Real.sqrt (x1 ^ 2 + x2 ^ 2) := ⟨_, rfl⟩
    have hrpos : 0 < r := by rw [hr]; exact Real.sqrt_pos.mpr hpos
    have hr2 : r ^ 2 = x1 ^ 2 + x2 ^ 2 := by
      rw [hr]; exact Real.sq_sqrt (le_of_lt hpos)
    refine ⟨-x2 / r, x1 / r, ?_, ?_, ?_⟩
    · field_simp
      linarith [hr2]
    · field_simp
      ring
    · field_simp
      linarith [h]

/-- The quadratic form of `!![1, 0; m₃, 1]` is bounded below by the golden constant on the
unit circle, for every `m₃ ∈ [0,1]`. -/
private lemma golden_quadratic_form (m3 n1 n2 : ℝ) (hm0 : 0 ≤ m3) (hm1 : m3 ≤ 1)
    (hn : n1 ^ 2 + n2 ^ 2 = 1) : goldenGap ≤ n1 ^ 2 + (m3 * n1 + n2) ^ 2 := by
  have hg1 : goldenGap < 1 := goldenGap_lt_one
  have hg0 : 0 < goldenGap := goldenGap_pos
  have hq := goldenGap_quadratic
  -- `(1 - g) * (form - g) = ((1 - g) n₂ + m₃ n₁)² + g (1 - m₃²) n₁²`
  have key : (1 - goldenGap) * (n1 ^ 2 + (m3 * n1 + n2) ^ 2 - goldenGap)
      = ((1 - goldenGap) * n2 + m3 * n1) ^ 2 + goldenGap * (1 - m3 ^ 2) * n1 ^ 2 := by
    have hn2 : n2 ^ 2 = 1 - n1 ^ 2 := by linarith
    nlinarith [hq, hn2, hn]
  nlinarith [sq_nonneg ((1 - goldenGap) * n2 + m3 * n1), sq_nonneg n1,
    mul_nonneg hg0.le (mul_nonneg (by nlinarith : (0:ℝ) ≤ 1 - m3 ^ 2) (sq_nonneg n1))]

/-- **Sharp algebraic core.**  A `2 × 2` block `!![1, 0; m₃, 1]` with `m₃ ∈ [0,1]` is at
squared Frobenius distance at least `(3 - √5)/2` from every singular block. -/
private lemma golden_core {m3 x1 x2 x3 x4 : ℝ} (hm0 : 0 ≤ m3) (hm1 : m3 ≤ 1)
    (hx : x1 * x4 = x2 * x3) :
    goldenGap ≤ (1 - x1) ^ 2 + (0 - x2) ^ 2 + (m3 - x3) ^ 2 + (1 - x4) ^ 2 := by
  obtain ⟨n1, n2, hn, hk1, hk2⟩ := exists_unit_kernel x1 x2 x3 x4 hx
  -- the error block sends `n` to `M n`
  have hE1 : (1 - x1) * n1 + (0 - x2) * n2 = n1 := by linarith [hk1]
  have hE2 : (m3 - x3) * n1 + (1 - x4) * n2 = m3 * n1 + n2 := by linarith [hk2]
  -- Cauchy–Schwarz row by row
  have hCS1 : ((1 - x1) * n1 + (0 - x2) * n2) ^ 2 ≤ (1 - x1) ^ 2 + (0 - x2) ^ 2 := by
    nlinarith [sq_nonneg ((1 - x1) * n2 - (0 - x2) * n1), hn]
  have hCS2 : ((m3 - x3) * n1 + (1 - x4) * n2) ^ 2 ≤ (m3 - x3) ^ 2 + (1 - x4) ^ 2 := by
    nlinarith [sq_nonneg ((m3 - x3) * n2 - (1 - x4) * n1), hn]
  rw [hE1] at hCS1
  rw [hE2] at hCS2
  have := golden_quadratic_form m3 n1 n2 hm0 hm1 hn
  linarith

/-! ## 3. The sharp gap at depth 2 -/

section Depth2

variable {A B : Type*} [Fintype A] [Fintype B] [DecidableEq A] [DecidableEq B]

/-- **Sharp rigidity gap.**  If `R ⊆ A × B` is not a combinatorial box, then every unit
product coin satisfies `‖A(f ⊗ g)‖² ≤ |R| - (3 - √5)/2`.  The loss is an absolute
constant, independent of `|R|` and of the ambient dimensions. -/
theorem productCoin_amplitude_sq_le_golden (R : Finset (A × B))
    (f : A → ℝ) (g : B → ℝ) (hf : ∑ a, f a ^ 2 = 1) (hg : ∑ b, g b ^ 2 = 1)
    (hbox : ¬ IsBox R) :
    resonanceAmplitude R (prodCoin f g) ^ 2 ≤ (R.card : ℝ) - goldenGap := by
  obtain ⟨a, a', b, b', hab, hab', hmix⟩ :
      ∃ a a' b b', (a, b) ∈ R ∧ (a', b') ∈ R ∧ (a, b') ∉ R := by
    unfold IsBox at hbox
    push_neg at hbox
    obtain ⟨a, a', b, b', h1, h2, h3⟩ := hbox
    exact ⟨a, a', b, b', h1, h2, h3⟩
  have haa : a ≠ a' := by rintro rfl; exact hmix hab'
  have hbb : b ≠ b' := by rintro rfl; exact hmix hab
  set t := resonanceAmplitude R (prodCoin f g) with ht
  set M : A × B → ℝ := fun p => if p ∈ R then (1:ℝ) else 0 with hM
  set E : A × B → ℝ := fun p => M p - t * f p.1 * g p.2 with hE
  have hSid : ∑ p : A × B, E p ^ 2 = (R.card : ℝ) - t ^ 2 :=
    prod_defect_identity R f g hf hg
  have d1 : (a, b) ≠ (a, b') := by simp [Prod.ext_iff, hbb]
  have d2 : (a, b) ≠ (a', b) := by simp [Prod.ext_iff, haa]
  have d3 : (a, b) ≠ (a', b') := by simp [Prod.ext_iff, haa]
  have d4 : (a, b') ≠ (a', b) := by simp [Prod.ext_iff, haa]
  have d5 : (a, b') ≠ (a', b') := by simp [Prod.ext_iff, haa]
  have d6 : (a', b) ≠ (a', b') := by simp [Prod.ext_iff, hbb]
  have hm1v : M (a, b) = 1 := by simp [hM, hab]
  have hm2v : M (a, b') = 0 := by simp [hM, hmix]
  have hm4v : M (a', b') = 1 := by simp [hM, hab']
  have hm3nn : (0:ℝ) ≤ M (a', b) := by simp only [hM]; positivity
  have hm3le : M (a', b) ≤ 1 := by simp only [hM]; split <;> norm_num
  have hPS : E (a, b) ^ 2 + E (a, b') ^ 2 + E (a', b) ^ 2 + E (a', b') ^ 2
      ≤ (R.card : ℝ) - t ^ 2 := by
    rw [← hSid]
    exact four_point_le_total (fun p => E p ^ 2) (fun _ => sq_nonneg _) d1 d2 d3 d4 d5 d6
  have hcore : goldenGap ≤ (1 - t * f a * g b) ^ 2 + (0 - t * f a * g b') ^ 2
      + (M (a', b) - t * f a' * g b) ^ 2 + (1 - t * f a' * g b') ^ 2 :=
    golden_core hm3nn hm3le (by ring)
  have hEeq : E (a, b) ^ 2 + E (a, b') ^ 2 + E (a', b) ^ 2 + E (a', b') ^ 2
      = (1 - t * f a * g b) ^ 2 + (0 - t * f a * g b') ^ 2
        + (M (a', b) - t * f a' * g b) ^ 2 + (1 - t * f a' * g b') ^ 2 := by
    simp only [hE, hm1v, hm2v, hm4v]
  linarith [hEeq ▸ hPS]

/-- Multiplicative form of the sharp gap. -/
theorem productCoin_amplitude_sq_le_golden_mul (R : Finset (A × B))
    (f : A → ℝ) (g : B → ℝ) (hf : ∑ a, f a ^ 2 = 1) (hg : ∑ b, g b ^ 2 = 1)
    (hbox : ¬ IsBox R) :
    resonanceAmplitude R (prodCoin f g) ^ 2
      ≤ (1 - goldenGap / (R.card : ℝ)) * (R.card : ℝ) := by
  have hmain := productCoin_amplitude_sq_le_golden R f g hf hg hbox
  have hR2 : (2:ℝ) ≤ (R.card : ℝ) := by exact_mod_cast two_le_card_of_not_box hbox
  have heq : (1 - goldenGap / (R.card : ℝ)) * (R.card : ℝ)
      = (R.card : ℝ) - goldenGap := by
    have hne : (R.card : ℝ) ≠ 0 := by linarith
    field_simp
  linarith [heq ▸ hmain]

omit [Fintype A] [Fintype B] in
/-- The sharp gap strictly improves the crude `1/(9|R|)` bound for every non-box `R`. -/
theorem golden_improves_crude (R : Finset (A × B)) (hbox : ¬ IsBox R) :
    1 / (9 * (R.card : ℝ)) < goldenGap := by
  have hR2 : (2:ℝ) ≤ (R.card : ℝ) := by exact_mod_cast two_le_card_of_not_box hbox
  have hg : goldenGap = (3 - Real.sqrt 5) / 2 := rfl
  have h5 := sqrt5_lt_nine_quarters
  have h1 : 1 / (9 * (R.card : ℝ)) ≤ 1 / 18 := by
    apply one_div_le_one_div_of_le (by norm_num); linarith
  rw [hg]
  linarith

end Depth2

/-! ## 4. Optimality of the constant -/

/-- The golden gap is exactly what the `L`-shape loses. -/
lemma Lshape_golden : (Lshape.card : ℝ) - goldenGap = goldenOpt := by
  rw [Lshape_card, goldenGap, goldenOpt]
  push_cast
  ring

/-- **The constant `(3 - √5)/2` is optimal.**  There is a non-box resonance set and a unit
product coin attaining `‖A(f ⊗ g)‖² = |R| - (3 - √5)/2` exactly, so no larger constant
works in `productCoin_amplitude_sq_le_golden`. -/
theorem goldenGap_optimal :
    ∃ (R : Finset (Bool × Bool)) (f g : Bool → ℝ), ¬ IsBox R ∧
      (∑ a, f a ^ 2 = 1) ∧ (∑ b, g b ^ 2 = 1) ∧
      resonanceAmplitude R (prodCoin f g) ^ 2 = (R.card : ℝ) - goldenGap := by
  obtain ⟨f, g, hf, hg, hopt⟩ := Lshape_optimum
  exact ⟨Lshape, f, g, Lshape_not_isBox, hf, hg, by rw [Lshape_golden]; exact hopt⟩

/-! ## 5. The sharp gap at depth `n` -/

section DepthN

variable {D : Type*} [Fintype D] [DecidableEq D]

/-- The sharp depth-`n` gap for the split at the first coordinate. -/
theorem productCoin_depth_amplitude_sq_le_golden {n : ℕ}
    (R : Finset (Fin (n + 1) → D)) (f : Fin (n + 1) → D → ℝ)
    (hf : ∀ i, ∑ d, f i d ^ 2 = 1)
    (hbox : ¬ IsBox (R.map (peel n).toEmbedding)) :
    resonanceAmplitude R (depthCoin f) ^ 2 ≤ (R.card : ℝ) - goldenGap := by
  set R' := R.map (peel n).toEmbedding with hR'
  set g : (Fin n → D) → ℝ := depthCoin (fun i => f i.succ) with hg
  have hgu : ∑ z : Fin n → D, g z ^ 2 = 1 :=
    depthCoin_isUnitCoin (fun i => f i.succ) (fun i => hf i.succ)
  have hamp : resonanceAmplitude R' (prodCoin (f 0) g)
      = resonanceAmplitude R (depthCoin f) := by
    unfold resonanceAmplitude
    rw [hR', Finset.sum_map]
    refine Finset.sum_congr rfl fun x _ => ?_
    simp only [Equiv.coe_toEmbedding, peel_apply, prodCoin, hg, depthCoin]
    rw [Fin.prod_univ_succ]
  have hcard : R'.card = R.card := by rw [hR', Finset.card_map]
  have hmain := productCoin_amplitude_sq_le_golden R' (f 0) g (hf 0) hgu hbox
  rw [hamp, hcard] at hmain
  exact hmain

/-- The sharp depth-`n` gap at an arbitrary coordinate split. -/
theorem productCoin_depth_amplitude_sq_le_golden_at {n : ℕ} (i : Fin (n + 1))
    (R : Finset (Fin (n + 1) → D)) (f : Fin (n + 1) → D → ℝ)
    (hf : ∀ k, ∑ d, f k d ^ 2 = 1)
    (hbox : ¬ IsBox (R.map (splitAt i).toEmbedding)) :
    resonanceAmplitude R (depthCoin f) ^ 2 ≤ (R.card : ℝ) - goldenGap := by
  set R' := R.map (splitAt i).toEmbedding with hR'
  set g : (Fin n → D) → ℝ := depthCoin (fun j => f (i.succAbove j)) with hg
  have hgu : ∑ z : Fin n → D, g z ^ 2 = 1 :=
    depthCoin_isUnitCoin (fun j => f (i.succAbove j)) (fun j => hf (i.succAbove j))
  have hamp : resonanceAmplitude R' (prodCoin (f i) g)
      = resonanceAmplitude R (depthCoin f) := by
    unfold resonanceAmplitude
    rw [hR', Finset.sum_map]
    refine Finset.sum_congr rfl fun x _ => ?_
    simp only [Equiv.coe_toEmbedding, splitAt_apply, prodCoin, hg, depthCoin]
    rw [Fin.prod_univ_succAbove (fun k => f k (x k)) i]
  have hcard : R'.card = R.card := by rw [hR', Finset.card_map]
  have hmain := productCoin_amplitude_sq_le_golden R' (f i) g (hf i) hgu hbox
  rw [hamp, hcard] at hmain
  exact hmain

/-- **Sharp Conjecture 3″ at fixed depth.**  If `R ⊆ D^(n+1)` is not a full combinatorial
box, every depth-`(n+1)` product coin loses at least the absolute constant `(3 - √5)/2`
against the Cauchy–Schwarz optimum. -/
theorem productCoin_depth_golden_gap_of_not_isFullBox {n : ℕ}
    (R : Finset (Fin (n + 1) → D)) (f : Fin (n + 1) → D → ℝ)
    (hf : ∀ k, ∑ d, f k d ^ 2 = 1) (hfull : ¬ IsFullBox R) :
    resonanceAmplitude R (depthCoin f) ^ 2 ≤ (R.card : ℝ) - goldenGap := by
  obtain ⟨i, hi⟩ := exists_coord_not_box_of_not_isFullBox R hfull
  exact productCoin_depth_amplitude_sq_le_golden_at i R f hf hi

end DepthN

end Catalog.Geometry.ShallowProductCoin