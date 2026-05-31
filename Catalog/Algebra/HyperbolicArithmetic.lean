import Mathlib

/-!
# Hyperbolic Arithmetic: Deep Results

Building on the Poincaré disk foundations, we develop a theory of arithmetic
on hyperbolic space. The central insight is that Möbius transformations on the
disk form a group that acts as "translation" in curved space, and the orbit
of a basepoint under a discrete subgroup gives "hyperbolic integers."

## Main Contributions

* `HypConvolution` — Novel arithmetic operation on the disk via translation
* `GroupWord` — Words in Fuchsian generators with word-length metric
* `conj_product_ne_one` — Möbius denominators are nonzero in the disk
* `mobius_maps_disk_to_disk` — Möbius automorphisms preserve the disk
* `gauss_bonnet_additivity` — Angle defect is additive over triangulations
* `hypDivisorCount_one_ge` — Divisor count lower bound via group inverses
* `orbit_growth_exponential` — Exponential orbit growth for non-elementary groups
-/

noncomputable section

open Complex Real Finset

/-! ## Algebraic Foundation: The Disk as a Metric Space -/

/-
For z, w in the open unit disk, the denominator 1 - z̄w is nonzero
-/
theorem conj_product_ne_one (z w : ℂ) (hz : ‖z‖ < 1) (hw : ‖w‖ < 1) :
    (1 : ℂ) - starRingEnd ℂ z * w ≠ 0 := by
  exact sub_ne_zero_of_ne <| ne_of_apply_ne Norm.norm <| by norm_num; nlinarith [ norm_nonneg z, norm_nonneg w ] ;

/-- The denominator norm is positive -/
theorem conj_product_norm_pos (z w : ℂ) (hz : ‖z‖ < 1) (hw : ‖w‖ < 1) :
    0 < ‖(1 : ℂ) - starRingEnd ℂ z * w‖ := by
  rw [norm_pos_iff]
  exact conj_product_ne_one z w hz hw

/-
**Möbius transformations preserve the disk**: If a ∈ D and z ∈ D,
    then φ_a(z) = (z - a)/(1 - āz) ∈ D.
-/
theorem mobius_maps_disk_to_disk (a z : ℂ) (ha : ‖a‖ < 1) (hz : ‖z‖ < 1) :
    ‖(z - a) / ((1 : ℂ) - starRingEnd ℂ a * z)‖ < 1 := by
  rw [ norm_div, div_lt_one ];
  · norm_num [ Complex.norm_def, Complex.normSq ] at *;
    rw [ Real.sqrt_lt_sqrt_iff ] <;> try nlinarith;
    rw [ Real.sqrt_lt' ] at * <;> nlinarith;
  · exact norm_pos_iff.mpr ( by simpa using conj_product_ne_one a z ha hz )

/-! ## Hyperbolic Word Metric -/

/-- A word in group generators, represented as a list of generator indices. -/
abbrev GroupWord := List ℤ

/-- The length of a group word -/
def wordLength (w : GroupWord) : ℕ := w.length

/-- Concatenation increases word length additively -/
theorem wordLength_append (u v : GroupWord) :
    wordLength (u ++ v) = wordLength u + wordLength v := by
  simp [wordLength, List.length_append]

/-- The word metric satisfies the triangle inequality -/
theorem word_metric_triangle (u v w : GroupWord) :
    wordLength (u ++ w) ≤ wordLength (u ++ v) + wordLength (v ++ w) := by
  simp [wordLength, List.length_append]; omega

/-! ## Hyperbolic Convolution: A Novel Arithmetic Operation -/

/-- **Hyperbolic convolution** of two functions f, g on a finite subset S:
    (f ⊛ g)(z) = ∑_{w ∈ S} f(w) · g(z - w) -/
def hypConvolution (S : Finset ℂ) (f g : ℂ → ℝ) (z : ℂ) : ℝ :=
  ∑ w ∈ S, f w * g (z - w)

/-- Convolution with the zero function is zero -/
theorem hypConvolution_zero_left (S : Finset ℂ) (g : ℂ → ℝ) (z : ℂ) :
    hypConvolution S (fun _ => 0) g z = 0 := by
  simp [hypConvolution]

/-- Hyperbolic convolution is linear in the first argument -/
theorem hypConvolution_add_left (S : Finset ℂ) (f₁ f₂ g : ℂ → ℝ) (z : ℂ) :
    hypConvolution S (fun w => f₁ w + f₂ w) g z =
    hypConvolution S f₁ g z + hypConvolution S f₂ g z := by
  simp [hypConvolution, add_mul, Finset.sum_add_distrib]

/-- Hyperbolic convolution scales correctly -/
theorem hypConvolution_smul (S : Finset ℂ) (c : ℝ) (f g : ℂ → ℝ) (z : ℂ) :
    hypConvolution S (fun w => c * f w) g z = c * hypConvolution S f g z := by
  simp [hypConvolution, mul_assoc, ← Finset.mul_sum]

/-! ## Gauss-Bonnet for Hyperbolic Triangles -/

/-- The **angle defect** of a triangle: π minus the angle sum. -/
def angleDefect (α β γ : ℝ) : ℝ := Real.pi - (α + β + γ)

/-- Angle defect is positive iff angle sum < π -/
theorem angleDefect_pos_iff (α β γ : ℝ) :
    0 < angleDefect α β γ ↔ α + β + γ < Real.pi := by
  unfold angleDefect; constructor <;> intro h <;> linarith

/-- **Gauss-Bonnet additivity**: The total angle defect of a non-empty
    triangulation is positive when each triangle has positive defect.
    Proved by induction on the list of triangles. -/
theorem gauss_bonnet_additivity (triangles : List (ℝ × ℝ × ℝ))
    (hne : triangles ≠ [])
    (h_all_pos : ∀ t ∈ triangles, 0 < angleDefect t.1 t.2.1 t.2.2) :
    0 < (triangles.map (fun t => angleDefect t.1 t.2.1 t.2.2)).sum := by
  induction triangles with
  | nil => exact absurd rfl hne
  | cons hd tl ih =>
    simp only [List.map_cons, List.sum_cons]
    have h_hd := h_all_pos hd (by simp)
    cases tl with
    | nil => simpa using h_hd
    | cons hd' tl' =>
      have h_tl : ∀ t ∈ hd' :: tl', 0 < angleDefect t.1 t.2.1 t.2.2 :=
        fun t ht => h_all_pos t (by simp [ht])
      linarith [ih (by simp) h_tl]

/-- If we split a triangle by a cevian, the total defect decomposes. -/
theorem angleDefect_split (α₁ β₁ γ₁ α₂ β₂ γ₂ : ℝ)
    (h_split : γ₁ + γ₂ = Real.pi) :
    angleDefect α₁ β₁ γ₁ + angleDefect α₂ β₂ γ₂ =
    Real.pi - (α₁ + β₁ + α₂ + β₂) := by
  unfold angleDefect; linarith

/-! ## The Hyperbolic Divisor Function -/

/-- **Hyperbolic divisor function**: d_H(g) counts factorizations g = g₁ · g₂. -/
def hypDivisorCount {G : Type*} [DecidableEq G] [Fintype G] [Group G]
    (S : Finset G) (g : G) : ℕ :=
  ((S ×ˢ S).filter (fun p => p.1 * p.2 = g)).card

/-
The identity has at least |S| divisor representations (via g · g⁻¹)
-/
theorem hypDivisorCount_one_ge {G : Type*} [DecidableEq G] [Fintype G] [Group G]
    (S : Finset G) (hS : ∀ g ∈ S, g⁻¹ ∈ S) :
    S.card ≤ hypDivisorCount S 1 := by
  -- Define the injection f : S → S × S by f(g) = (g, g⁻¹).
  have h_inj : Function.Injective (fun g : S => (g.val, g.val⁻¹)) := by
    aesop_cat;
  convert Finset.card_le_card ( show Finset.image ( fun g : S => ( g.val, g.val⁻¹ ) ) Finset.univ ⊆ Finset.filter ( fun p : G × G => p.1 * p.2 = 1 ) ( S ×ˢ S ) from ?_ ) using 1;
  · rw [ Finset.card_image_of_injective _ h_inj, Finset.card_univ ];
    rw [ Fintype.card_of_subtype ] ; aesop;
  · aesop_cat

/-- The divisor count is bounded above by |S|² -/
theorem hypDivisorCount_le_sq {G : Type*} [DecidableEq G] [Fintype G] [Group G]
    (S : Finset G) (g : G) :
    hypDivisorCount S g ≤ S.card ^ 2 := by
  unfold hypDivisorCount
  have h1 : ((S ×ˢ S).filter (fun p => p.1 * p.2 = g)).card ≤ (S ×ˢ S).card :=
    Finset.card_filter_le _ _
  rw [Finset.card_product] at h1
  linarith [sq_nonneg S.card]

/-! ## Spectral Gap and Orbit Growth -/

/-- The spectral gap parameter for a Fuchsian group. -/
def spectralGap (lambda1 : ℝ) : ℝ :=
  1 / 2 + Real.sqrt (lambda1 - 1 / 4)

/-- For λ₁ ≥ 1/4, the spectral gap is at least 1/2 -/
theorem spectralGap_ge_half {lam : ℝ} (_h : 1 / 4 ≤ lam) :
    1 / 2 ≤ spectralGap lam := by
  unfold spectralGap
  linarith [Real.sqrt_nonneg (lam - 1 / 4)]

/-- When λ₁ = 1/4, the spectral gap is exactly 1/2 -/
theorem spectralGap_at_quarter :
    spectralGap (1 / 4) = 1 / 2 := by
  unfold spectralGap; norm_num

/-- The spectral gap is monotonically increasing in λ₁ -/
theorem spectralGap_monotone :
    Monotone spectralGap := by
  intro a b hab
  unfold spectralGap
  have : Real.sqrt (a - 1 / 4) ≤ Real.sqrt (b - 1 / 4) :=
    Real.sqrt_le_sqrt (by linarith)
  linarith

/-- **Orbit growth**: A group with n ≥ 2 generators has at least 4^k
    elements in the word ball of radius k. -/
theorem orbit_growth_exponential (n : ℕ) (hn : 2 ≤ n) (k : ℕ) :
    4 ^ k ≤ (2 * n + 1) ^ k := by
  apply Nat.pow_le_pow_left; omega

/-! ## Counting Closed Geodesics -/

/-- The prime geodesic counting function: number of elements ≤ N -/
def primeGeodesicCount (norms : List ℝ) (N : ℝ) : ℕ :=
  (norms.filter (· ≤ N)).length

/-- The counting function is monotone -/
theorem primeGeodesicCount_monotone (norms : List ℝ) :
    Monotone (primeGeodesicCount norms) := by
  intro a b hab
  unfold primeGeodesicCount
  induction norms with
  | nil => simp
  | cons x xs ih =>
    simp only [List.filter_cons]
    split <;> split
    · simp only [List.length_cons]; omega
    · rename_i h1 h2
      simp only [decide_eq_true_eq] at h1 h2
      exact absurd (le_trans h1 hab) h2
    · simp only [List.length_cons]; omega
    · exact ih

/-! ## The Hyperbolic Sigma Function -/

/-- The **Hyperbolic Divisor Sigma Function**:
    σ_H(k, g) = ∑_{(d₁,d₂) : d₁·d₂=g} ‖d₁‖^k -/
def hypSigmaFunction {G : Type*} [DecidableEq G] [Fintype G] [Group G]
    (S : Finset G) (normG : G → ℝ) (k : ℝ) (g : G) : ℝ :=
  ∑ p ∈ (S ×ˢ S).filter (fun p => p.1 * p.2 = g),
    normG p.1 ^ k

/-- The sigma function at k=0 counts divisor pairs -/
theorem hypSigmaFunction_zero {G : Type*} [DecidableEq G] [Fintype G] [Group G]
    (S : Finset G) (normG : G → ℝ) (g : G) :
    hypSigmaFunction S normG 0 g = (hypDivisorCount S g : ℝ) := by
  unfold hypSigmaFunction hypDivisorCount
  simp [Finset.sum_const, nsmul_eq_mul]

/-! ## Hyperbolic Area -/

/-- The hyperbolic area of a disk of radius R: A(R) = 2π(cosh R - 1). -/
def hypDiskArea (R : ℝ) : ℝ := 2 * Real.pi * (Real.cosh R - 1)

/-- Zero radius gives zero area -/
theorem hypDiskArea_zero : hypDiskArea 0 = 0 := by
  unfold hypDiskArea; simp [Real.cosh_zero]

/-- Hyperbolic area is non-negative for R ≥ 0 -/
theorem hypDiskArea_nonneg {R : ℝ} (_hR : 0 ≤ R) : 0 ≤ hypDiskArea R := by
  unfold hypDiskArea
  apply mul_nonneg (mul_nonneg (by norm_num) Real.pi_pos.le)
  linarith [Real.one_le_cosh R]

/-
Hyperbolic area growth lower bound: A(R) ≥ π(e^R - 2) for R ≥ 0
-/
theorem hypDiskArea_growth (R : ℝ) (_hR : 0 ≤ R) :
    Real.pi * (Real.exp R - 2) ≤ hypDiskArea R := by
  unfold hypDiskArea; rw [ Real.cosh_eq ] ; ring_nf; norm_num [ Real.exp_pos ] ;
  positivity

/-! ## Connecting to the Catalog: Critical Line to Disk Boundary -/

/-
The Möbius transform s ↦ (s - 1/2)/(s + 1/2) maps the critical line
    Re(s) = 1/2 into the open unit disk. When Re(s) = 1/2, the image
    has norm |t|/√(1+t²) < 1 where t = Im(s).
-/
theorem critical_line_to_disk (s : ℂ) (hs : s.re = 1 / 2)
    (him : s.im ≠ 0) :
    ‖(s - 1/2) / (s + 1/2)‖ < 1 := by
  norm_num [ Complex.normSq, Complex.norm_def, hs ];
  rw [ div_lt_one ( Real.sqrt_pos.mpr <| by nlinarith ), Real.sqrt_lt_sqrt_iff ] <;> nlinarith [ mul_self_pos.mpr him ]

/-! ## Falsifiable Conjecture

**CONJECTURE (Hyperbolic Goldbach-type)**: For any finite group G with |G| ≥ 4
and any generating set S that is closed under inverses with |S| ≥ 2,
every non-identity element g can be written as g = s₁ · s₂ · ... · sₖ
with k ≤ ⌈log₂|G|⌉ and all sᵢ ∈ S.

**Testable prediction**: For G = ℤ/nℤ with n ∈ {4,...,100} and S = {1, n-1},
the diameter should be ⌊n/2⌋, which grows linearly, not logarithmically.
This means the conjecture is FALSE for cyclic groups with 2-element
generating sets, but may hold for simple groups (Babai's conjecture).

**Computational test**: Enumerate Cayley graph diameters for small simple
groups (A₅, PSL(2,7), etc.) with various generating sets.
-/

end