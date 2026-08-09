import Mathlib

/-!
# Noise gauges: the analytic layer of FHE noise accounting

A *noise gauge* on a commutative ring `R` is a subadditive, symmetric,
submultiplicative-up-to-an-expansion-factor size function `ν : R → ℝ`.  It
abstracts the canonical/coefficient norms used in BGV/BFV noise analysis:

* `R = ℤ` with `ν = |·|` and expansion factor `γ = 1`;
* `R = ℤ[X]/(X^n - 1)` (a group algebra) with the `ℓ¹` coefficient norm and
  `γ = 1`;
* the same ring with the `ℓ^∞` norm and `γ = n` (the classical *ring expansion
  factor* `δ_R`).

Everything downstream (noise growth of homomorphic addition, multiplication,
relinearization, modulus switching, bootstrapping) is proved once and for all at
this level of generality, so it applies verbatim to every concrete instance.

Main definitions and results of this file:

* `FHENoise.NoiseGauge` — the structure itself;
* `NoiseGauge.nu_sub_le`, `nu_sum_le` — subadditivity, including over `Finset`s;
* `NoiseGauge.gamma_nu_pow_le` — `γ · ν (x ^ n) ≤ (γ · ν x) ^ n` for `n ≥ 1`,
  the multiplicative-depth engine;
* `FHENoise.intGauge` — the integer instance;
* `FHENoise.l1Gauge` — the `ℓ¹` gauge on a commutative group algebra
  `AddMonoidAlgebra ℤ A`, i.e. on cyclotomic-style convolution rings.
-/

namespace FHENoise

open Finset BigOperators

/-- A *noise gauge*: a size function on a commutative ring which is subadditive,
symmetric and submultiplicative up to a ring expansion factor `gamma ≥ 1`. -/
structure NoiseGauge (R : Type*) [CommRing R] where
  /-- The size (norm) of a ring element. -/
  nu : R → ℝ
  /-- The ring expansion factor, `δ_R` in the FHE literature. -/
  gamma : ℝ
  gamma_one_le : 1 ≤ gamma
  nu_nonneg : ∀ x, 0 ≤ nu x
  nu_zero : nu 0 = 0
  nu_add_le : ∀ x y, nu (x + y) ≤ nu x + nu y
  nu_neg : ∀ x, nu (-x) = nu x
  nu_mul_le : ∀ x y, nu (x * y) ≤ gamma * nu x * nu y

namespace NoiseGauge

variable {R : Type*} [CommRing R] (G : NoiseGauge R)

lemma gamma_pos : 0 < G.gamma := lt_of_lt_of_le zero_lt_one G.gamma_one_le

lemma gamma_nonneg : 0 ≤ G.gamma := le_of_lt G.gamma_pos

/-- Subadditivity for differences. -/
lemma nu_sub_le (x y : R) : G.nu (x - y) ≤ G.nu x + G.nu y := by
  have h := G.nu_add_le x (-y)
  rw [G.nu_neg] at h
  rwa [sub_eq_add_neg]

/-- The reverse triangle inequality: sizes cannot change by more than the size
of the perturbation.  This is the lemma that turns "relinearization changes the
phase by a small element" into a noise bound. -/
lemma nu_le_of_sub (x y : R) : G.nu x ≤ G.nu y + G.nu (x - y) := by
  have h : G.nu (y + (x - y)) ≤ G.nu y + G.nu (x - y) := G.nu_add_le _ _
  simpa using h

/-- Subadditivity over a finite sum. -/
lemma nu_sum_le {ι : Type*} (s : Finset ι) (f : ι → R) :
    G.nu (∑ i ∈ s, f i) ≤ ∑ i ∈ s, G.nu (f i) := by
  classical
  induction s using Finset.induction with
  | empty => simp [G.nu_zero]
  | insert a s ha ih =>
      rw [Finset.sum_insert ha, Finset.sum_insert ha]
      exact le_trans (G.nu_add_le _ _) (by linarith)

/-- Products: the normalized ("γ-scaled") size is genuinely submultiplicative. -/
lemma gamma_nu_mul_le (x y : R) :
    G.gamma * G.nu (x * y) ≤ (G.gamma * G.nu x) * (G.gamma * G.nu y) := by
  have h := G.nu_mul_le x y
  have hg := G.gamma_nonneg
  nlinarith [G.nu_nonneg x, G.nu_nonneg y, G.gamma_pos]

/-- Product bound in terms of external bounds on the factors: the workhorse of
noise accounting. -/
lemma nu_mul_le_bounds {x y : R} {a b : ℝ} (hx : G.nu x ≤ a) (hy : G.nu y ≤ b) :
    G.nu (x * y) ≤ G.gamma * a * b := by
  have hx0 := G.nu_nonneg x
  have hy0 := G.nu_nonneg y
  have ha : 0 ≤ a := le_trans hx0 hx
  calc G.nu (x * y) ≤ G.gamma * G.nu x * G.nu y := G.nu_mul_le x y
    _ ≤ G.gamma * a * G.nu y :=
        mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left hx G.gamma_nonneg) hy0
    _ ≤ G.gamma * a * b := mul_le_mul_of_nonneg_left hy (mul_nonneg G.gamma_nonneg ha)

/-- Normalized submultiplicativity iterated: `γ · ν (x ^ n) ≤ (γ · ν x) ^ n`
for every `n ≥ 1`.  This inequality is the exact reason FHE noise grows
*doubly* exponentially in multiplicative depth. -/
lemma gamma_nu_pow_le (x : R) : ∀ n : ℕ, 1 ≤ n →
    G.gamma * G.nu (x ^ n) ≤ (G.gamma * G.nu x) ^ n := by
  intro n hn
  induction n with
  | zero => omega
  | succ k ih =>
      rcases Nat.eq_zero_or_pos k with hk | hk
      · subst hk; simp
      · have hik := ih hk
        have hstep : G.gamma * G.nu (x ^ k * x) ≤
            (G.gamma * G.nu (x ^ k)) * (G.gamma * G.nu x) :=
          G.gamma_nu_mul_le _ _
        have hxpos : 0 ≤ G.gamma * G.nu x :=
          mul_nonneg G.gamma_nonneg (G.nu_nonneg x)
        calc G.gamma * G.nu (x ^ (k + 1))
            = G.gamma * G.nu (x ^ k * x) := by rw [pow_succ]
          _ ≤ (G.gamma * G.nu (x ^ k)) * (G.gamma * G.nu x) := hstep
          _ ≤ (G.gamma * G.nu x) ^ k * (G.gamma * G.nu x) :=
              mul_le_mul_of_nonneg_right hik hxpos
          _ = (G.gamma * G.nu x) ^ (k + 1) := by rw [pow_succ]

/-- Repeated doubling of a noise level: `ν (2^k • x) ≤ 2^k · ν x`. -/
lemma nu_nsmul_le (x : R) : ∀ n : ℕ, G.nu (n • x) ≤ n * G.nu x := by
  intro n
  induction n with
  | zero => simp [G.nu_zero]
  | succ k ih =>
      have : G.nu (k • x + x) ≤ G.nu (k • x) + G.nu x := G.nu_add_le _ _
      rw [succ_nsmul]
      push_cast
      linarith

/-- **Normalization of a gauge.**  Rescaling a gauge by `λ ∈ [1, γ]` yields a
gauge with expansion factor `γ/λ`; taking `λ = γ` normalizes the expansion
factor to `1`, which is the "relative noise" convention in which the depth law
`(γ·B)^(2^d)` becomes a plain iterated square. -/
noncomputable def rescale (lam : ℝ) (h1 : 1 ≤ lam) (h2 : lam ≤ G.gamma) : NoiseGauge R where
  nu x := lam * G.nu x
  gamma := G.gamma / lam
  gamma_one_le := (one_le_div (by linarith)).mpr h2
  nu_nonneg x := mul_nonneg (by linarith) (G.nu_nonneg x)
  nu_zero := by simp [G.nu_zero]
  nu_add_le x y := by nlinarith [G.nu_add_le x y]
  nu_neg x := by rw [G.nu_neg]
  nu_mul_le x y := by
    have hlam : 0 < lam := by linarith
    have h := G.nu_mul_le x y
    have : G.gamma / lam * (lam * G.nu x) * (lam * G.nu y)
        = lam * (G.gamma * G.nu x * G.nu y) := by field_simp
    rw [this]
    nlinarith [G.nu_nonneg (x * y)]

@[simp] lemma rescale_nu (lam : ℝ) (h1 : 1 ≤ lam) (h2 : lam ≤ G.gamma) (x : R) :
    (G.rescale lam h1 h2).nu x = lam * G.nu x := rfl

@[simp] lemma rescale_gamma (lam : ℝ) (h1 : 1 ≤ lam) (h2 : lam ≤ G.gamma) :
    (G.rescale lam h1 h2).gamma = G.gamma / lam := rfl

end NoiseGauge

/-! ### Concrete gauge 1: the integers -/

/-- The absolute value on `ℤ` is a noise gauge with expansion factor `1`. -/
def intGauge : NoiseGauge ℤ where
  nu x := |(x : ℝ)|
  gamma := 1
  gamma_one_le := le_refl _
  nu_nonneg _ := abs_nonneg _
  nu_zero := by simp
  nu_add_le x y := by push_cast; exact abs_add_le _ _
  nu_neg x := by push_cast; exact abs_neg _
  nu_mul_le x y := by push_cast; simp [abs_mul]

@[simp] lemma intGauge_nu (x : ℤ) : intGauge.nu x = |(x : ℝ)| := rfl

@[simp] lemma intGauge_gamma : intGauge.gamma = 1 := rfl

/-! ### Concrete gauge 2: the `ℓ¹` norm on a convolution (group) algebra

`AddMonoidAlgebra ℤ A` for an additive commutative group `A` is the ring of
`ℤ`-valued functions on `A` under convolution; taking `A = ZMod n` gives
`ℤ[X]/(Xⁿ - 1)`, the negacyclic sibling of the cyclotomic rings used by BGV/BFV.
The `ℓ¹` coefficient norm is submultiplicative there, i.e. the expansion factor
is `1`. -/

section L1

variable {A : Type*}

/-- The `ℓ¹` coefficient norm of an element of a group algebra. -/
noncomputable def l1norm (f : AddMonoidAlgebra ℤ A) : ℝ :=
  ∑ a ∈ f.support, |(f a : ℝ)|

lemma l1norm_nonneg (f : AddMonoidAlgebra ℤ A) : 0 ≤ l1norm f :=
  Finset.sum_nonneg fun _ _ => abs_nonneg _

/-- The `ℓ¹` norm as a sum over any finite superset of the support. -/
lemma l1norm_eq_sum_of_subset {f : AddMonoidAlgebra ℤ A} {s : Finset A}
    (hs : f.support ⊆ s) : l1norm f = ∑ a ∈ s, |(f a : ℝ)| := by
  refine Finset.sum_subset hs ?_
  intro a _ ha
  simp [Finsupp.notMem_support_iff.mp ha]

@[simp] lemma l1norm_zero : l1norm (0 : AddMonoidAlgebra ℤ A) = 0 := by
  simp [l1norm]

lemma l1norm_neg (f : AddMonoidAlgebra ℤ A) : l1norm (-f) = l1norm f := by
  classical
  have hsupp : (-f).support = f.support := Finsupp.support_neg f
  simp [l1norm, hsupp]

lemma l1norm_add_le (f g : AddMonoidAlgebra ℤ A) :
    l1norm (f + g) ≤ l1norm f + l1norm g := by
  classical
  set s : Finset A := f.support ∪ g.support ∪ (f + g).support with hs
  have h1 : l1norm (f + g) = ∑ a ∈ s, |((f + g) a : ℝ)| :=
    l1norm_eq_sum_of_subset (by intro a ha; simp [hs, ha])
  have h2 : l1norm f = ∑ a ∈ s, |(f a : ℝ)| :=
    l1norm_eq_sum_of_subset (by intro a ha; simp [hs, ha])
  have h3 : l1norm g = ∑ a ∈ s, |(g a : ℝ)| :=
    l1norm_eq_sum_of_subset (by intro a ha; simp [hs, ha])
  rw [h1, h2, h3, ← Finset.sum_add_distrib]
  refine Finset.sum_le_sum fun a _ => ?_
  have hadd : ((f + g) a : ℝ) = (f a : ℝ) + (g a : ℝ) := by simp
  rw [hadd]
  exact abs_add_le _ _

/-- Subadditivity of the `ℓ¹` norm over finite sums. -/
lemma l1norm_sum_le {ι : Type*} (s : Finset ι) (F : ι → AddMonoidAlgebra ℤ A) :
    l1norm (∑ i ∈ s, F i) ≤ ∑ i ∈ s, l1norm (F i) := by
  classical
  induction s using Finset.induction with
  | empty => simp [l1norm]
  | insert a s ha ih =>
      rw [Finset.sum_insert ha, Finset.sum_insert ha]
      exact le_trans (l1norm_add_le _ _) (by linarith)

@[simp] lemma l1norm_single (a : A) (c : ℤ) : l1norm (Finsupp.single a c) = |(c : ℝ)| := by
  classical
  rcases eq_or_ne c 0 with rfl | hc
  · simp [l1norm]
  · simp [l1norm, Finsupp.support_single_ne_zero a hc]

/-- **Submultiplicativity of the `ℓ¹` norm under convolution.**  Group algebras
therefore have ring expansion factor `1` for the `ℓ¹` coefficient norm — the
sharpest possible value. -/
lemma l1norm_mul_le [AddMonoid A] (f g : AddMonoidAlgebra ℤ A) :
    l1norm (f * g) ≤ l1norm f * l1norm g := by
  classical
  rw [AddMonoidAlgebra.mul_def, Finsupp.sum]
  refine le_trans (l1norm_sum_le _ _) ?_
  have hstep : ∀ a ∈ f.support,
      l1norm (Finsupp.sum g fun m₂ r₂ => Finsupp.single (a + m₂) (f a * r₂))
        ≤ ∑ b ∈ g.support, |(f a : ℝ)| * |(g b : ℝ)| := by
    intro a _
    rw [Finsupp.sum]
    refine le_trans (l1norm_sum_le _ _) ?_
    refine Finset.sum_le_sum fun b _ => ?_
    rw [l1norm_single]
    push_cast
    rw [abs_mul]
  refine le_trans (Finset.sum_le_sum hstep) ?_
  rw [l1norm, l1norm, Finset.sum_mul_sum]

/-- The `ℓ¹` noise gauge on a convolution algebra, with expansion factor `1`.
Taking `A = ZMod n` this is the coefficient-`ℓ¹` gauge on `ℤ[X]/(Xⁿ - 1)`. -/
noncomputable def l1Gauge (A : Type*) [AddCommMonoid A] : NoiseGauge (AddMonoidAlgebra ℤ A) where
  nu := l1norm
  gamma := 1
  gamma_one_le := le_refl _
  nu_nonneg := l1norm_nonneg
  nu_zero := l1norm_zero
  nu_add_le := l1norm_add_le
  nu_neg := l1norm_neg
  nu_mul_le x y := by simpa using l1norm_mul_le x y

@[simp] lemma l1Gauge_gamma (A : Type*) [AddCommMonoid A] : (l1Gauge A).gamma = 1 := rfl

@[simp] lemma l1Gauge_nu (A : Type*) [AddCommMonoid A] (f : AddMonoidAlgebra ℤ A) :
    (l1Gauge A).nu f = l1norm f := rfl

end L1

end FHENoise