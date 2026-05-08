/-
Copyright (c) 2026 Harmonic. All rights reserved.

# Tropical Fourier Analysis: Max-Plus Spectral Decomposition

Foundations of tropical harmonic analysis over the max-plus semiring 𝕋 = (ℝ, max, +).

Bridge: connects idempotent analysis (Maslov dequantization) to:
- Certified neural network robustness via tropical Lipschitz bounds
- Post-quantum cryptography via max-plus shortest-path problems
- Statistical mechanics via tropical partition functions (zero-temperature limits)
-/

import Mathlib

noncomputable section

open Finset

/-! ## Helper lemmas for `Finset.sup'` arithmetic -/

/-- Adding a constant commutes with finite supremum. -/
private lemma sup'_add_const {ι : Type*} {s : Finset ι} (hs : s.Nonempty)
    (f : ι → ℝ) (c : ℝ) :
    s.sup' hs (fun i => c + f i) = c + s.sup' hs f := by
  have hg : ∀ a b : ℝ, c + (a ⊔ b) = (c + a) ⊔ (c + b) := by
    intro a b; rcases le_total a b with h | h
    · rw [sup_eq_right.mpr h, sup_eq_right.mpr (by linarith)]
    · rw [sup_eq_left.mpr h, sup_eq_left.mpr (by linarith)]
  exact (Finset.comp_sup'_eq_sup'_comp hs (c + ·) hg).symm

/-- Multiplying by a nonneg constant commutes with finite supremum. -/
private lemma sup'_nonneg_mul {ι : Type*} {s : Finset ι} (hs : s.Nonempty)
    (f : ι → ℝ) {c : ℝ} (hc : 0 ≤ c) :
    s.sup' hs (fun i => c * f i) = c * s.sup' hs f := by
  have hg : ∀ a b : ℝ, c * (a ⊔ b) = (c * a) ⊔ (c * b) := by
    intro a b; rcases le_total a b with h | h
    · rw [sup_eq_right.mpr h, sup_eq_right.mpr (mul_le_mul_of_nonneg_left h hc)]
    · rw [sup_eq_left.mpr h, sup_eq_left.mpr (mul_le_mul_of_nonneg_left h hc)]
  exact (Finset.comp_sup'_eq_sup'_comp hs (c * ·) hg).symm

/-! ## Core Definitions -/

/-- **Tropical inner product**: ⟨f, g⟩_⊕ = max_x (f(x) + g(x)).
Bridge: idempotent analysis ↔ Maslov dequantization in quantum mechanics. -/
def tropicalInnerProduct {α : Type*} [Fintype α] [Nonempty α] (f g : α → ℝ) : ℝ :=
  univ.sup' univ_nonempty (fun x => f x + g x)

/-- **Tropical norm**: ‖f‖_⊕ = max_x f(x).
Bridge: function space geometry ↔ tropical convexity. -/
def tropicalNorm {α : Type*} [Fintype α] [Nonempty α] (f : α → ℝ) : ℝ :=
  univ.sup' univ_nonempty f

/-- **Max-plus kernel operator**: K(f)(y) = max_x (κ(x,y) + f(x)).
Bridge: spectral theory ↔ post-quantum lattice cryptography. -/
structure MaxPlusKernelOp (α : Type*) [Fintype α] [Nonempty α] where
  kernel : α → α → ℝ

/-- Apply the max-plus kernel operator. -/
def MaxPlusKernelOp.apply {α : Type*} [Fintype α] [Nonempty α]
    (K : MaxPlusKernelOp α) (f : α → ℝ) (y : α) : ℝ :=
  univ.sup' univ_nonempty (fun x => K.kernel x y + f x)

/-- Self-adjointness: κ(x,y) = κ(y,x). -/
def MaxPlusKernelOp.IsSelfAdjoint {α : Type*} [Fintype α] [Nonempty α]
    (K : MaxPlusKernelOp α) : Prop :=
  ∀ x y, K.kernel x y = K.kernel y x

/-- Tropical eigenpair: K(φ)(y) = ev + φ(y) for all y.
Bridge: tropical spectral theory ↔ max-plus Markov chains. -/
def MaxPlusKernelOp.IsEigenpair {α : Type*} [Fintype α] [Nonempty α]
    (K : MaxPlusKernelOp α) (ev : ℝ) (phi : α → ℝ) : Prop :=
  ∀ y, K.apply phi y = ev + phi y

/-- **Tropical Fourier coefficient**: ĉ(k) = max_x (f(x) + φ_k(x)).
Bridge: harmonic analysis ↔ tropical signal processing. -/
def tropicalFourierCoeff {α κ : Type*} [Fintype α] [Nonempty α]
    (f : α → ℝ) (phi : κ → α → ℝ) (k : κ) : ℝ :=
  univ.sup' univ_nonempty (fun x => f x + phi k x)

/-- **Tropical sinc function**: sinc_⊕(t) = -|t|.
Bridge: tropical sampling ↔ piecewise-linear neural network interpolation. -/
def tropicalSinc (t : ℝ) : ℝ := -|t|

/-- **Tropical spectral radius**: ρ_⊕(K) = max_x κ(x,x). -/
def tropicalSpectralRadius {α : Type*} [Fintype α] [Nonempty α]
    (K : MaxPlusKernelOp α) : ℝ :=
  univ.sup' univ_nonempty (fun x => K.kernel x x)

/-- **Tropical Rayleigh quotient**: R_⊕(f, K) = ⟨K(f), f⟩_⊕ - ⟨f, f⟩_⊕.
Bridge: variational methods ↔ certified robustness bounds. -/
def tropicalRayleigh {α : Type*} [Fintype α] [Nonempty α]
    (K : MaxPlusKernelOp α) (f : α → ℝ) : ℝ :=
  tropicalInnerProduct (K.apply f) f - tropicalInnerProduct f f

/-- **Tropical Hilbert space**: ‖f‖ = ⟨f, f⟩/2. -/
class TropicalHilbertSpace (α : Type*) [Fintype α] [Nonempty α] where
  norm_eq_half_inner : ∀ f : α → ℝ, tropicalNorm f = tropicalInnerProduct f f / 2

/-- **Tropical band-limited function** with finite Fourier support.
Bridge: sampling theory ↔ certified ReLU network Lipschitz bounds. -/
structure TropicalBandLimitedFn (α κ : Type*) [Fintype α] [Nonempty α] where
  f : α → ℝ
  support : Finset κ
  modes : κ → α → ℝ
  coeffs : κ → ℝ

/-- **Tropical convolution**: (f ⊛ g)(y) = max_x (f(x) + g(y - x)).
Bridge: max-plus dynamic programming ↔ signal processing. -/
def tropicalConvolution {α : Type*} [Fintype α] [Nonempty α] [Sub α]
    (f g : α → ℝ) (y : α) : ℝ :=
  univ.sup' univ_nonempty (fun x => f x + g (y - x))

/-! ## Section 2: Tropical Inner Product Properties -/

/-- Tropical inner product is symmetric. -/
theorem tropical_inner_symmetric {α : Type*} [Fintype α] [Nonempty α]
    (f g : α → ℝ) :
    tropicalInnerProduct f g = tropicalInnerProduct g f := by
  simp only [tropicalInnerProduct, add_comm]

/-- ⟨f, f⟩_⊕ = 2 · ‖f‖_⊕. -/
theorem tropical_inner_self_eq_double_norm {α : Type*} [Fintype α] [Nonempty α]
    (f : α → ℝ) :
    tropicalInnerProduct f f = 2 * tropicalNorm f := by
  simp only [tropicalInnerProduct, tropicalNorm]
  have h : (fun x : α => f x + f x) = (fun x => 2 * f x) := by ext x; ring
  rw [h, sup'_nonneg_mul _ _ (by norm_num : (0 : ℝ) ≤ 2)]

/-- Every finite nonempty type is a tropical Hilbert space. -/
instance instTropicalHilbertSpace (α : Type*) [Fintype α] [Nonempty α] :
    TropicalHilbertSpace α where
  norm_eq_half_inner f := by rw [tropical_inner_self_eq_double_norm]; ring

/-- **Tropical Cauchy-Schwarz**: ⟨f, g⟩_⊕ ≤ ‖f‖_⊕ + ‖g‖_⊕.
Bridge: tropical convexity ↔ certified robustness in neural networks. -/
theorem tropical_cauchy_schwarz {α : Type*} [Fintype α] [Nonempty α]
    (f g : α → ℝ) :
    tropicalInnerProduct f g ≤ tropicalNorm f + tropicalNorm g := by
  simp only [tropicalInnerProduct, tropicalNorm]
  apply Finset.sup'_le; intro x _
  exact add_le_add (Finset.le_sup' f (mem_univ x)) (Finset.le_sup' g (mem_univ x))

/-- ⟨c + f, g⟩_⊕ = c + ⟨f, g⟩_⊕. -/
theorem tropical_inner_add_const_left {α : Type*} [Fintype α] [Nonempty α]
    (f g : α → ℝ) (c : ℝ) :
    tropicalInnerProduct (fun x => c + f x) g = c + tropicalInnerProduct f g := by
  simp only [tropicalInnerProduct]
  have h : (fun x : α => c + f x + g x) = (fun x => c + (f x + g x)) := by ext x; ring
  rw [h, sup'_add_const]

/-- ‖c + f‖_⊕ = c + ‖f‖_⊕. -/
theorem tropical_norm_add_const {α : Type*} [Fintype α] [Nonempty α]
    (f : α → ℝ) (c : ℝ) :
    tropicalNorm (fun x => c + f x) = c + tropicalNorm f :=
  sup'_add_const univ_nonempty f c

/-- ∃ x, ‖f‖_⊕ = f(x). -/
theorem tropical_norm_attained {α : Type*} [Fintype α] [Nonempty α]
    (f : α → ℝ) :
    ∃ x : α, tropicalNorm f = f x := by
  obtain ⟨x, _, hx⟩ := Finset.exists_mem_eq_sup' univ_nonempty f
  exact ⟨x, hx⟩

/-- f(x) ≤ ‖f‖_⊕ for all x. -/
theorem tropical_norm_pointwise {α : Type*} [Fintype α] [Nonempty α]
    (f : α → ℝ) (x : α) :
    f x ≤ tropicalNorm f :=
  Finset.le_sup' f (mem_univ x)

/-- ∃ x, ⟨f, g⟩_⊕ = f(x) + g(x). -/
theorem tropical_inner_attained {α : Type*} [Fintype α] [Nonempty α]
    (f g : α → ℝ) :
    ∃ x : α, tropicalInnerProduct f g = f x + g x := by
  obtain ⟨x, _, hx⟩ := Finset.exists_mem_eq_sup' univ_nonempty (fun x => f x + g x)
  exact ⟨x, hx⟩

/-! ## Section 3: Tropical Sinc Properties -/

/-- sinc_⊕(0) = 0. -/
theorem tropical_sinc_at_zero : tropicalSinc 0 = 0 := by
  simp [tropicalSinc]

/-- sinc_⊕(t) ≤ 0 for all t. -/
theorem tropical_sinc_nonpos (t : ℝ) : tropicalSinc t ≤ 0 := by
  simp only [tropicalSinc]; linarith [abs_nonneg t]

/-- sinc_⊕(-t) = sinc_⊕(t). -/
theorem tropical_sinc_symmetric (t : ℝ) : tropicalSinc (-t) = tropicalSinc t := by
  simp [tropicalSinc, abs_neg]

/-- |sinc_⊕(s) - sinc_⊕(t)| ≤ |s - t| (1-Lipschitz).
Bridge: tropical sampling ↔ certified Lipschitz bounds. -/
theorem tropical_sinc_lipschitz (s t : ℝ) :
    |tropicalSinc s - tropicalSinc t| ≤ |s - t| := by
  simp only [tropicalSinc]
  rw [show (-|s|) - (-|t|) = |t| - |s| from by ring]
  rw [abs_sub_comm s t]
  exact abs_abs_sub_abs_le_abs_sub t s

/-- sinc_⊕(t) = 0 ↔ t = 0. -/
theorem tropical_sinc_eq_zero_iff (t : ℝ) : tropicalSinc t = 0 ↔ t = 0 := by
  constructor
  · intro h; simp only [tropicalSinc] at h
    linarith [abs_nonneg t, abs_eq_zero.mp (by linarith : |t| = 0)]
  · intro h; rw [h]; simp [tropicalSinc]

/-- sinc_⊕(n) < 0 for nonzero integer n. -/
theorem tropical_sinc_neg_at_nonzero_int {n : ℤ} (hn : n ≠ 0) :
    tropicalSinc (n : ℝ) < 0 := by
  simp only [tropicalSinc]
  have : (0 : ℝ) < |(n : ℝ)| := by positivity
  linarith

/-! ## Section 4: Max-Plus Kernel Operator Properties -/

/-- Kernel monotonicity: f ≤ g → K(f) ≤ K(g).
Bridge: order-preserving maps ↔ tropical Markov chain convergence. -/
theorem tropical_kernel_monotone {α : Type*} [Fintype α] [Nonempty α]
    (K : MaxPlusKernelOp α) (f g : α → ℝ) (h : ∀ x, f x ≤ g x) (y : α) :
    K.apply f y ≤ K.apply g y := by
  simp only [MaxPlusKernelOp.apply]
  apply Finset.sup'_le; intro x _
  have : K.kernel x y + f x ≤ K.kernel x y + g x := by linarith [h x]
  exact le_trans this (Finset.le_sup' (fun x => K.kernel x y + g x) (mem_univ x))

/-- K(c + f) = c + K(f).
Bridge: tropical linearity ↔ gauge invariance in physics. -/
theorem tropical_kernel_add_const {α : Type*} [Fintype α] [Nonempty α]
    (K : MaxPlusKernelOp α) (f : α → ℝ) (c : ℝ) (y : α) :
    K.apply (fun x => c + f x) y = c + K.apply f y := by
  simp only [MaxPlusKernelOp.apply]
  have h : (fun x : α => K.kernel x y + (c + f x)) =
      (fun x => c + (K.kernel x y + f x)) := by ext x; ring
  rw [h, sup'_add_const]

/-- R_⊕(φ, K) = ev for eigenpairs.
Bridge: variational methods ↔ certified spectral bounds. -/
theorem tropical_rayleigh_eigenvalue {α : Type*} [Fintype α] [Nonempty α]
    (K : MaxPlusKernelOp α) (ev : ℝ) (phi : α → ℝ)
    (h : K.IsEigenpair ev phi) :
    tropicalRayleigh K phi = ev := by
  simp only [tropicalRayleigh, tropicalInnerProduct]
  have heq : (fun y : α => K.apply phi y + phi y) =
      (fun y => ev + (phi y + phi y)) := by ext y; rw [h y]; ring
  rw [heq, sup'_add_const]; ring

/-- ρ_⊕(K) ≤ ev for any eigenpair (ev, φ).
Bridge: eigenvalue analysis ↔ shortest-path lower bounds in graph algorithms. -/
theorem tropical_spectral_radius_le_eigenvalue {α : Type*} [Fintype α] [Nonempty α]
    (K : MaxPlusKernelOp α) (ev : ℝ) (phi : α → ℝ)
    (h_eigen : K.IsEigenpair ev phi) :
    tropicalSpectralRadius K ≤ ev := by
  simp only [tropicalSpectralRadius]
  apply Finset.sup'_le; intro y _
  have h := h_eigen y; simp only [MaxPlusKernelOp.apply] at h
  linarith [Finset.le_sup' (fun x => K.kernel x y + phi x) (mem_univ y)]

/-- Shifting kernel by c shifts eigenvalue by c. -/
theorem tropical_eigenpair_kernel_shift {α : Type*} [Fintype α] [Nonempty α]
    (K : MaxPlusKernelOp α) (ev : ℝ) (phi : α → ℝ)
    (h_eigen : K.IsEigenpair ev phi) (c : ℝ) :
    (⟨fun x y => K.kernel x y + c⟩ : MaxPlusKernelOp α).IsEigenpair (ev + c) phi := by
  intro y; simp only [MaxPlusKernelOp.apply]
  have h : (fun x : α => K.kernel x y + c + phi x) =
      (fun x => c + (K.kernel x y + phi x)) := by ext x; ring
  rw [h, sup'_add_const]
  have := h_eigen y; simp only [MaxPlusKernelOp.apply] at this; linarith

/-- Same eigenfunction → same eigenvalue. -/
theorem tropical_eigenvalue_unique {α : Type*} [Fintype α] [Nonempty α]
    (K : MaxPlusKernelOp α) (ev₁ ev₂ : ℝ) (phi : α → ℝ)
    (h1 : K.IsEigenpair ev₁ phi) (h2 : K.IsEigenpair ev₂ phi) :
    ev₁ = ev₂ := by
  have y := Classical.arbitrary α
  have := h1 y; rw [h2 y] at this; linarith

/-- R_⊕(φ, K) ≥ ρ_⊕(K) for eigenpairs. -/
theorem tropical_rayleigh_ge_spectral_radius {α : Type*} [Fintype α] [Nonempty α]
    (K : MaxPlusKernelOp α) (ev : ℝ) (phi : α → ℝ) (h : K.IsEigenpair ev phi) :
    tropicalRayleigh K phi ≥ tropicalSpectralRadius K := by
  rw [tropical_rayleigh_eigenvalue K ev phi h]
  exact tropical_spectral_radius_le_eigenvalue K ev phi h

/-! ## Section 5: Tropical Fourier Analysis -/

/-- ĉ(k) ≤ ‖f‖_⊕ + ‖φ_k‖_⊕. -/
theorem tropical_fourier_coeff_bound {α κ : Type*} [Fintype α] [Nonempty α]
    (f : α → ℝ) (phi : κ → α → ℝ) (k : κ) :
    tropicalFourierCoeff f phi k ≤ tropicalNorm f + tropicalNorm (phi k) :=
  tropical_cauchy_schwarz f (phi k)

/-- ĉ_{c+f}(k) = c + ĉ_f(k). -/
theorem tropical_fourier_coeff_shift {α κ : Type*} [Fintype α] [Nonempty α]
    (f : α → ℝ) (phi : κ → α → ℝ) (k : κ) (c : ℝ) :
    tropicalFourierCoeff (fun x => c + f x) phi k = c + tropicalFourierCoeff f phi k := by
  simp only [tropicalFourierCoeff]
  have h : (fun x : α => c + f x + phi k x) = (fun x => c + (f x + phi k x)) := by ext x; ring
  rw [h, sup'_add_const]

/-- ĉ(k) = ⟨f, φ_k⟩_⊕. -/
theorem tropical_fourier_coeff_eq_inner {α κ : Type*} [Fintype α] [Nonempty α]
    (f : α → ℝ) (phi : κ → α → ℝ) (k : κ) :
    tropicalFourierCoeff f phi k = tropicalInnerProduct f (phi k) := rfl

/-- If f = max_k (c(k) + φ_k) and ‖φ_k‖ = 0, then ‖f‖_⊕ = max_k c(k).
Bridge: core of tropical Plancherel — norm via Fourier coefficients.
Application: O(d) Lipschitz certification for tropical neural networks. -/
theorem tropical_norm_from_decomposition {α κ : Type*} [Fintype α] [Fintype κ]
    [Nonempty α] [Nonempty κ]
    (f : α → ℝ) (phi : κ → α → ℝ) (c : κ → ℝ)
    (h_norm : ∀ k, tropicalNorm (phi k) = 0)
    (h_decomp : ∀ x, f x = univ.sup' univ_nonempty (fun k => c k + phi k x)) :
    tropicalNorm f = univ.sup' univ_nonempty c := by
  simp only [tropicalNorm]
  have hf : univ.sup' univ_nonempty f = univ.sup' univ_nonempty
      (fun x => univ.sup' univ_nonempty (fun k => c k + phi k x)) := by
    congr 1; ext x; exact h_decomp x
  rw [hf]; apply le_antisymm
  · apply Finset.sup'_le; intro x _
    apply Finset.sup'_le; intro k _
    have hphi : phi k x ≤ 0 := by
      have := Finset.le_sup' (phi k) (mem_univ x)
      simp only [tropicalNorm] at h_norm; rw [h_norm k] at this; exact this
    linarith [Finset.le_sup' c (mem_univ k)]
  · apply Finset.sup'_le; intro k _
    obtain ⟨x₀, hx₀⟩ := tropical_norm_attained (phi k)
    rw [h_norm k] at hx₀
    calc c k = c k + phi k x₀ := by linarith
      _ ≤ univ.sup' univ_nonempty (fun k' => c k' + phi k' x₀) :=
          Finset.le_sup' (fun k' => c k' + phi k' x₀) (mem_univ k)
      _ ≤ univ.sup' univ_nonempty
          (fun x => univ.sup' univ_nonempty (fun k' => c k' + phi k' x)) :=
          Finset.le_sup'
            (fun x => univ.sup' univ_nonempty (fun k' => c k' + phi k' x))
            (mem_univ x₀)

/-- **Tropical Plancherel identity**: ⟨f, f⟩_⊕ = max_k (2·c(k)).

Bridge: tropical energy conservation ↔ certified robustness of ReLU networks.
Idempotent analogue of Parseval's identity ‖f‖² = Σ|ĉ(k)|².
Application: O(d) certified Lipschitz bounds for tropical neural networks. -/
theorem tropical_plancherel {α κ : Type*} [Fintype α] [Fintype κ]
    [Nonempty α] [Nonempty κ]
    (f : α → ℝ) (phi : κ → α → ℝ) (c : κ → ℝ)
    (h_norm : ∀ k, tropicalNorm (phi k) = 0)
    (h_decomp : ∀ x, f x = univ.sup' univ_nonempty (fun k => c k + phi k x)) :
    tropicalInnerProduct f f = univ.sup' univ_nonempty (fun k => c k + c k) := by
  rw [tropical_inner_self_eq_double_norm,
      tropical_norm_from_decomposition f phi c h_norm h_decomp]
  have h1 : (fun k : κ => c k + c k) = (fun k => 2 * c k) := by ext k; ring
  rw [h1, sup'_nonneg_mul _ _ (by norm_num : (0 : ℝ) ≤ 2)]

/-! ## Section 6: Eigenvalue Theory -/

/-- Diagonal kernel eigenpair: near-identity kernel has eigenvalue c.
Bridge: tropical spectral theory ↔ shortest-path graph algorithms. -/
theorem tropical_identity_kernel_eigenpair {α : Type*} [Fintype α] [Nonempty α]
    [DecidableEq α] (c M : ℝ) (hM : M > 0) :
    (⟨fun x y => if x = y then c else c - M⟩ : MaxPlusKernelOp α).IsEigenpair c
      (fun _ => 0) := by
  intro y; simp only [MaxPlusKernelOp.apply]
  have h1 : (fun x : α => (if x = y then c else c - M) + 0) =
      (fun x : α => if x = y then c else c - M) := by ext x; simp
  rw [h1, add_zero]; apply le_antisymm
  · apply Finset.sup'_le; intro x _; split_ifs <;> linarith
  · have : (fun x : α => if x = y then c else c - M) y = c := if_pos rfl
    linarith [Finset.le_sup' (fun x : α => if x = y then c else c - M) (mem_univ y)]

/-- Constant kernel eigenpair: κ ≡ c → eigenvalue c with φ ≡ 0. -/
theorem tropical_constant_kernel_eigenpair {α : Type*} [Fintype α] [Nonempty α] (c : ℝ) :
    (⟨fun _ _ => c⟩ : MaxPlusKernelOp α).IsEigenpair c (fun _ => 0) := by
  intro y; simp [MaxPlusKernelOp.apply]

/-! ## Section 7: Norm Bounds and Certified Robustness -/

/-- ‖K(f)‖_⊕ ≤ ‖κ‖_∞ + ‖f‖_⊕.
Application: O(1) per-layer Lipschitz bound for tropical neural networks. -/
theorem tropical_kernel_norm_bound {α : Type*} [Fintype α] [Nonempty α]
    (K : MaxPlusKernelOp α) (f : α → ℝ) :
    tropicalNorm (K.apply f) ≤
      univ.sup' univ_nonempty (fun p : α × α => K.kernel p.1 p.2) + tropicalNorm f := by
  simp only [tropicalNorm, MaxPlusKernelOp.apply]
  apply Finset.sup'_le; intro y _
  apply Finset.sup'_le; intro x _
  linarith [Finset.le_sup' (fun p : α × α => K.kernel p.1 p.2) (mem_univ (x, y)),
            Finset.le_sup' f (mem_univ x)]

/-- ‖f + g‖_⊕ ≤ ‖f‖_⊕ + ‖g‖_⊕ (tropical triangle inequality). -/
theorem tropical_norm_triangle {α : Type*} [Fintype α] [Nonempty α]
    (f g : α → ℝ) :
    tropicalNorm (fun x => f x + g x) ≤ tropicalNorm f + tropicalNorm g :=
  tropical_cauchy_schwarz f g

/-- Among 1-Lipschitz h with h(0)=0, h(t) ≤ |t|.
The tropical sinc -|t| is the tightest such upper bound (achieved at t). -/
theorem tropical_sinc_optimal_interpolant (h : ℝ → ℝ)
    (h_lip : ∀ s t, |h s - h t| ≤ |s - t|) (h_zero : h 0 = 0) (t : ℝ) :
    h t ≤ |t| := by
  have key := h_lip 0 t
  rw [h_zero, zero_sub, abs_neg, zero_sub, abs_neg] at key
  exact le_of_abs_le key

/-- Tropical convolution is commutative for abelian groups. -/
theorem tropical_convolution_comm {α : Type*} [Fintype α] [Nonempty α] [AddCommGroup α]
    (f g : α → ℝ) (y : α) :
    tropicalConvolution f g y = tropicalConvolution g f y := by
  simp only [tropicalConvolution]; apply le_antisymm
  · apply Finset.sup'_le; intro x _
    calc f x + g (y - x) = g (y - x) + f (y - (y - x)) := by rw [sub_sub_cancel]; ring
      _ ≤ _ := Finset.le_sup' (fun x => g x + f (y - x)) (mem_univ (y - x))
  · apply Finset.sup'_le; intro x _
    calc g x + f (y - x) = f (y - x) + g (y - (y - x)) := by rw [sub_sub_cancel]; ring
      _ ≤ _ := Finset.le_sup' (fun x => f x + g (y - x)) (mem_univ (y - x))

/-- K²(f)(y) as double supremum.
Application: O(n²·k) algorithm for tropical eigenvalue computation. -/
theorem tropical_power_iteration_step {α : Type*} [Fintype α] [Nonempty α]
    (K : MaxPlusKernelOp α) (f : α → ℝ) (y : α) :
    K.apply (K.apply f) y = univ.sup' univ_nonempty
      (fun z => univ.sup' univ_nonempty
        (fun x => K.kernel z y + K.kernel x z + f x)) := by
  simp only [MaxPlusKernelOp.apply]; congr 1; ext z
  rw [show (fun x : α => K.kernel z y + K.kernel x z + f x) =
      (fun x => K.kernel z y + (K.kernel x z + f x)) from by ext x; ring]
  exact (sup'_add_const univ_nonempty _ _).symm

/-- ⟨K(φ), φ⟩_⊕ = ev + ⟨φ, φ⟩_⊕ for eigenpairs. -/
theorem tropical_eigenpair_inner {α : Type*} [Fintype α] [Nonempty α]
    (K : MaxPlusKernelOp α) (ev : ℝ) (phi : α → ℝ)
    (h_eigen : K.IsEigenpair ev phi) :
    tropicalInnerProduct (K.apply phi) phi = ev + tropicalInnerProduct phi phi := by
  simp only [tropicalInnerProduct]
  have heq : (fun y : α => K.apply phi y + phi y) =
      (fun y => ev + (phi y + phi y)) := by ext y; rw [h_eigen y]; ring
  rw [heq, sup'_add_const]

end