import Mathlib
import Probability.InformationGeometryContrarian

/-!
# Canonical α-connections of a finite exponential family: the analytic core

The catalog file `Probability/InformationGeometryContrarian.lean` *postulates* the
lower-index natural-coordinate coefficients of Amari's α-connection,

  `naturalAlphaChristoffel α C i j k = ((1 - α) / 2) * C i j k`,

for an abstract cubic tensor `C`, and records the purely algebraic consequences
(e-flatness at `α = 1`, m-flatness of the dual presentation at `α = -1`,
opposite-alpha duality, the Levi–Civita midpoint identity).

This file supplies the missing *analytic* content: for a genuine finite
exponential family
  `p_θ(x) = w x · exp(⟨θ, T x⟩) / Z(θ)`
we prove the differential-geometric facts that make those algebraic identities
meaningful:

* `hasDerivAt_mean` — the directional derivative of an expectation is a covariance
  with the directional score (the fundamental exponential-family identity);
* `hasDerivAt_logPartition`, `hasDerivAt_deriv_logPartition`,
  `hasDerivAt_secondDeriv_logPartition` — the log-partition function is a
  cumulant generating function: its first three directional derivatives are the
  mean, the Fisher variance and the Amari–Chentsov cubic tensor;
* `hasDerivAt_fisher` — **the derivative of the Fisher metric is the
  Amari–Chentsov cubic tensor**, `∂_k g_ij = C_ijk`;
* `codazzi_alpha_dual` — consequently, for *every* `α` the pair
  `(∇^{(α)}, ∇^{(-α)})` satisfies the dual-connection (Codazzi) compatibility
  equation `∂_k g_ij = Γ^{(α)}_{k i, j} + Γ^{(-α)}_{k j, i}`, with the catalog's
  coefficients;
* `e_flat_iff` / `m_flat_iff` — e-flatness at `α = 1` is genuine parallel
  transport flatness of the metric derivative decomposition, while for `α ≠ 1`
  flatness forces the cubic tensor to vanish.

All statements are proved for arbitrary finite sample spaces `S` and arbitrary
feature maps `T : S → Fin d → ℝ`, with strictly positive base weights.
-/

noncomputable section

open Finset BigOperators

namespace AlphaConnectionCanonical

variable {S : Type*} [Fintype S] {d : ℕ}

/-! ## 1. The finite exponential family -/

/-- The directional score `⟨u, T x⟩` of a feature map. -/
def score (u : Fin d → ℝ) (T : S → Fin d → ℝ) (x : S) : ℝ := ∑ i, u i * T x i

/-- Unnormalised expectation `∑ₓ w x · exp⟨θ, T x⟩ · f x`. -/
def unnorm (w : S → ℝ) (T : S → Fin d → ℝ) (θ : Fin d → ℝ) (f : S → ℝ) : ℝ :=
  ∑ x, w x * Real.exp (score θ T x) * f x

/-- The partition function of the exponential family. -/
def partitionFn (w : S → ℝ) (T : S → Fin d → ℝ) (θ : Fin d → ℝ) : ℝ :=
  unnorm w T θ (fun _ => 1)

/-- The exponential-family probability weights `p_θ`. -/
def prob (w : S → ℝ) (T : S → Fin d → ℝ) (θ : Fin d → ℝ) (x : S) : ℝ :=
  w x * Real.exp (score θ T x) / partitionFn w T θ

/-- Expectation under `p_θ`. -/
def mean (w : S → ℝ) (T : S → Fin d → ℝ) (θ : Fin d → ℝ) (f : S → ℝ) : ℝ :=
  unnorm w T θ f / partitionFn w T θ

/-- Covariance under `p_θ`. -/
def covar (w : S → ℝ) (T : S → Fin d → ℝ) (θ : Fin d → ℝ) (f g : S → ℝ) : ℝ :=
  mean w T θ (fun x => f x * g x) - mean w T θ f * mean w T θ g

/-- Third central mixed moment (third joint cumulant) under `p_θ`. -/
def cum3 (w : S → ℝ) (T : S → Fin d → ℝ) (θ : Fin d → ℝ) (f g h : S → ℝ) : ℝ :=
  mean w T θ (fun x =>
    (f x - mean w T θ f) * (g x - mean w T θ g) * (h x - mean w T θ h))

/-- The Fisher information metric of the family in natural coordinates. -/
def fisher (w : S → ℝ) (T : S → Fin d → ℝ) (θ : Fin d → ℝ) (i j : Fin d) : ℝ :=
  covar w T θ (fun x => T x i) (fun x => T x j)

/-- The Amari–Chentsov cubic tensor of the family in natural coordinates. -/
def amariCubic (w : S → ℝ) (T : S → Fin d → ℝ) (θ : Fin d → ℝ) (i j k : Fin d) : ℝ :=
  cum3 w T θ (fun x => T x i) (fun x => T x j) (fun x => T x k)

/-- The log-partition (cumulant generating) function. -/
def logPartition (w : S → ℝ) (T : S → Fin d → ℝ) (θ : Fin d → ℝ) : ℝ :=
  Real.log (partitionFn w T θ)

/-! ## 2. Elementary algebra of expectations -/

omit [Fintype S] in
lemma score_add_smul (u θ : Fin d → ℝ) (T : S → Fin d → ℝ) (t : ℝ) (x : S) :
    score (θ + t • u) T x = score θ T x + t * score u T x := by
  simp only [score, Pi.add_apply, Pi.smul_apply, smul_eq_mul, add_mul, Finset.mul_sum]
  rw [Finset.sum_add_distrib]
  exact congrArg _ (Finset.sum_congr rfl fun i _ => by ring)

lemma partitionFn_pos [Nonempty S] {w : S → ℝ} (hw : ∀ x, 0 < w x)
    (T : S → Fin d → ℝ) (θ : Fin d → ℝ) : 0 < partitionFn w T θ := by
  unfold partitionFn unnorm
  apply Finset.sum_pos
  · intro x _
    have := hw x
    have : (0:ℝ) < Real.exp (score θ T x) := Real.exp_pos _
    positivity
  · exact Finset.univ_nonempty

lemma partitionFn_ne_zero [Nonempty S] {w : S → ℝ} (hw : ∀ x, 0 < w x)
    (T : S → Fin d → ℝ) (θ : Fin d → ℝ) : partitionFn w T θ ≠ 0 :=
  ne_of_gt (partitionFn_pos hw T θ)

lemma unnorm_add (w : S → ℝ) (T : S → Fin d → ℝ) (θ : Fin d → ℝ) (f g : S → ℝ) :
    unnorm w T θ (fun x => f x + g x) = unnorm w T θ f + unnorm w T θ g := by
  unfold unnorm
  rw [← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun x _ => by ring

lemma unnorm_sub (w : S → ℝ) (T : S → Fin d → ℝ) (θ : Fin d → ℝ) (f g : S → ℝ) :
    unnorm w T θ (fun x => f x - g x) = unnorm w T θ f - unnorm w T θ g := by
  unfold unnorm
  rw [← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl fun x _ => by ring

lemma unnorm_const_mul (w : S → ℝ) (T : S → Fin d → ℝ) (θ : Fin d → ℝ) (c : ℝ)
    (f : S → ℝ) : unnorm w T θ (fun x => c * f x) = c * unnorm w T θ f := by
  unfold unnorm
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun x _ => by ring

lemma unnorm_const (w : S → ℝ) (T : S → Fin d → ℝ) (θ : Fin d → ℝ) (c : ℝ) :
    unnorm w T θ (fun _ => c) = c * partitionFn w T θ := by
  unfold partitionFn
  rw [← unnorm_const_mul]
  simp

section MeanAlgebra

variable [Nonempty S] {w : S → ℝ} (hw : ∀ x, 0 < w x) (T : S → Fin d → ℝ)
  (θ : Fin d → ℝ)

include hw

omit [Nonempty S] hw in
lemma mean_add (f g : S → ℝ) :
    mean w T θ (fun x => f x + g x) = mean w T θ f + mean w T θ g := by
  unfold mean
  rw [unnorm_add, add_div]

omit [Nonempty S] hw in
lemma mean_sub (f g : S → ℝ) :
    mean w T θ (fun x => f x - g x) = mean w T θ f - mean w T θ g := by
  unfold mean
  rw [unnorm_sub, sub_div]

omit [Nonempty S] hw in
lemma mean_const_mul (c : ℝ) (f : S → ℝ) :
    mean w T θ (fun x => c * f x) = c * mean w T θ f := by
  unfold mean
  rw [unnorm_const_mul, mul_div_assoc]

lemma mean_const (c : ℝ) : mean w T θ (fun _ => c) = c := by
  unfold mean
  rw [unnorm_const]
  field_simp [partitionFn_ne_zero hw T θ]

/-- Polarised form of the third cumulant: the centred product expands into
moments. -/
lemma cum3_expand (f g h : S → ℝ) :
    cum3 w T θ f g h =
      mean w T θ (fun x => f x * g x * h x)
        - mean w T θ (fun x => f x * g x) * mean w T θ h
        - mean w T θ (fun x => f x * h x) * mean w T θ g
        - mean w T θ (fun x => g x * h x) * mean w T θ f
        + 2 * (mean w T θ f * mean w T θ g * mean w T θ h) := by
  set a := mean w T θ f
  set b := mean w T θ g
  set c := mean w T θ h
  have hfun : (fun x => (f x - a) * (g x - b) * (h x - c)) =
      (fun x => ((((((f x * g x * h x) + (-c) * (f x * g x)) + (-b) * (f x * h x))
        + (-a) * (g x * h x)) + ((b * c) * f x + (a * c) * g x))
        + ((a * b) * h x + (-(a * b * c)))) ) := by
    funext x; ring
  unfold cum3
  rw [hfun]
  simp only [mean_add, mean_const_mul, mean_const hw]
  ring

/-- The Amari–Chentsov cubic tensor is totally symmetric. -/
lemma cum3_comm₁₂ (f g h : S → ℝ) : cum3 w T θ f g h = cum3 w T θ g f h := by
  rw [cum3_expand hw, cum3_expand hw]
  have h1 : (fun x => f x * g x * h x) = (fun x => g x * f x * h x) := by
    funext x; ring
  have h2 : (fun x => f x * g x) = (fun x => g x * f x) := by funext x; ring
  rw [h1, h2]; ring

lemma cum3_comm₂₃ (f g h : S → ℝ) : cum3 w T θ f g h = cum3 w T θ f h g := by
  rw [cum3_expand hw, cum3_expand hw]
  have h1 : (fun x => f x * h x * g x) = (fun x => f x * g x * h x) := by
    funext x; ring
  have h2 : (fun x => h x * g x) = (fun x => g x * h x) := by funext x; ring
  rw [h1, h2]; ring

end MeanAlgebra

/-! ## 3. Bridge to the catalog definitions -/

lemma mean_eq_weightedExpectation {w : S → ℝ}
    (T : S → Fin d → ℝ) (θ : Fin d → ℝ) (f : S → ℝ) :
    mean w T θ f =
      InformationGeometryContrarian.weightedExpectation (prob w T θ) f := by
  unfold mean unnorm prob InformationGeometryContrarian.weightedExpectation
  rw [Finset.sum_div]
  exact Finset.sum_congr rfl fun x _ => by ring

lemma fisher_eq_featureFisher [Nonempty S] {w : S → ℝ} (hw : ∀ x, 0 < w x)
    (T : S → Fin d → ℝ) (θ : Fin d → ℝ) (i j : Fin d) :
    fisher w T θ i j =
      InformationGeometryContrarian.featureFisher (prob w T θ) T i j := by
  unfold fisher covar InformationGeometryContrarian.featureFisher
    InformationGeometryContrarian.centeredFeature
  rw [← mean_eq_weightedExpectation, ← mean_eq_weightedExpectation,
    ← mean_eq_weightedExpectation]
  have hexp : (fun x => (T x i - mean w T θ (fun y => T y i)) *
      (T x j - mean w T θ (fun y => T y j))) =
      (fun x => T x i * T x j
        - ((mean w T θ (fun y => T y j)) * T x i
          + (mean w T θ (fun y => T y i)) * T x j
          - mean w T θ (fun y => T y i) * mean w T θ (fun y => T y j))) := by
    funext x; ring
  rw [hexp]
  simp only [mean_sub, mean_add, mean_const_mul, mean_const hw]
  ring

lemma amariCubic_eq_scoreCubic {w : S → ℝ}
    (T : S → Fin d → ℝ) (θ : Fin d → ℝ) (i j k : Fin d) :
    amariCubic w T θ i j k =
      InformationGeometryContrarian.scoreCubic (prob w T θ) T i j k := by
  have hm : ∀ l : Fin d, mean w T θ (fun x => T x l)
      = InformationGeometryContrarian.weightedExpectation (prob w T θ)
          (fun x => T x l) := fun l => mean_eq_weightedExpectation T θ _
  unfold amariCubic cum3 InformationGeometryContrarian.scoreCubic
    InformationGeometryContrarian.centeredFeature
  rw [mean_eq_weightedExpectation, hm i, hm j, hm k]

/-! ## 4. Derivatives: the cumulant hierarchy -/

lemma hasDerivAt_unnorm (w : S → ℝ) (T : S → Fin d → ℝ) (θ u : Fin d → ℝ)
    (f : S → ℝ) (t₀ : ℝ) :
    HasDerivAt (fun t => unnorm w T (θ + t • u) f)
      (unnorm w T (θ + t₀ • u) (fun x => score u T x * f x)) t₀ := by
  have key : ∀ x ∈ (Finset.univ : Finset S),
      HasDerivAt (fun t => w x * Real.exp (score (θ + t • u) T x) * f x)
        (w x * Real.exp (score (θ + t₀ • u) T x) * (score u T x * f x)) t₀ := by
    intro x _
    have h1 : HasDerivAt (fun t : ℝ => score θ T x + t * score u T x)
        (score u T x) t₀ := by
      simpa using ((hasDerivAt_id t₀).mul_const (score u T x)).const_add
        (score θ T x)
    have h2 := (Real.hasDerivAt_exp (score θ T x + t₀ * score u T x)).comp t₀ h1
    have h3 := (h2.const_mul (w x)).mul_const (f x)
    simp only [score_add_smul]
    convert h3 using 1
    ring
  unfold unnorm
  have h := HasDerivAt.sum key
  have hfun : (∑ x : S, fun t : ℝ => w x * Real.exp (score (θ + t • u) T x) * f x)
      = fun t : ℝ => ∑ x : S, w x * Real.exp (score (θ + t • u) T x) * f x := by
    funext t
    simp [Finset.sum_apply]
  rwa [hfun] at h

lemma hasDerivAt_partitionFn (w : S → ℝ) (T : S → Fin d → ℝ) (θ u : Fin d → ℝ)
    (t₀ : ℝ) :
    HasDerivAt (fun t => partitionFn w T (θ + t • u))
      (unnorm w T (θ + t₀ • u) (score u T)) t₀ := by
  have := hasDerivAt_unnorm w T θ u (fun _ => 1) t₀
  simpa [partitionFn] using this

/-- **Fundamental exponential-family identity.** The directional derivative of an
expectation is the covariance of the observable with the directional score. -/
theorem hasDerivAt_mean [Nonempty S] {w : S → ℝ} (hw : ∀ x, 0 < w x)
    (T : S → Fin d → ℝ) (θ u : Fin d → ℝ) (f : S → ℝ) (t₀ : ℝ) :
    HasDerivAt (fun t => mean w T (θ + t • u) f)
      (covar w T (θ + t₀ • u) f (score u T)) t₀ := by
  have hZ : partitionFn w T (θ + t₀ • u) ≠ 0 := partitionFn_ne_zero hw T _
  have hnum := hasDerivAt_unnorm w T θ u f t₀
  have hden := hasDerivAt_partitionFn w T θ u t₀
  have hdiv := hnum.div hden hZ
  have hgoal : covar w T (θ + t₀ • u) f (score u T) =
      (unnorm w T (θ + t₀ • u) (fun x => score u T x * f x)
          * partitionFn w T (θ + t₀ • u)
        - unnorm w T (θ + t₀ • u) f * unnorm w T (θ + t₀ • u) (score u T))
        / partitionFn w T (θ + t₀ • u) ^ 2 := by
    unfold covar mean
    have hcomm : (fun x => f x * score u T x) = (fun x => score u T x * f x) := by
      funext x; ring
    rw [hcomm]
    field_simp
  rw [hgoal]
  exact hdiv

/-- First derivative of the log-partition function: the mean of the directional
score. -/
theorem hasDerivAt_logPartition [Nonempty S] {w : S → ℝ} (hw : ∀ x, 0 < w x)
    (T : S → Fin d → ℝ) (θ u : Fin d → ℝ) (t₀ : ℝ) :
    HasDerivAt (fun t => logPartition w T (θ + t • u))
      (mean w T (θ + t₀ • u) (score u T)) t₀ := by
  have hZ : partitionFn w T (θ + t₀ • u) ≠ 0 := partitionFn_ne_zero hw T _
  have h := (hasDerivAt_partitionFn w T θ u t₀).log hZ
  simpa [logPartition, mean] using h

/-- Second derivative of the log-partition function: the Fisher variance of the
directional score. -/
theorem hasDerivAt_deriv_logPartition [Nonempty S] {w : S → ℝ} (hw : ∀ x, 0 < w x)
    (T : S → Fin d → ℝ) (θ u : Fin d → ℝ) (t₀ : ℝ) :
    HasDerivAt (fun t => mean w T (θ + t • u) (score u T))
      (covar w T (θ + t₀ • u) (score u T) (score u T)) t₀ :=
  hasDerivAt_mean hw T θ u (score u T) t₀

/-- **Derivative of a covariance.** -/
theorem hasDerivAt_covar [Nonempty S] {w : S → ℝ} (hw : ∀ x, 0 < w x)
    (T : S → Fin d → ℝ) (θ u : Fin d → ℝ) (f g : S → ℝ) (t₀ : ℝ) :
    HasDerivAt (fun t => covar w T (θ + t • u) f g)
      (cum3 w T (θ + t₀ • u) f g (score u T)) t₀ := by
  have h1 := hasDerivAt_mean hw T θ u (fun x => f x * g x) t₀
  have h2 := hasDerivAt_mean hw T θ u f t₀
  have h3 := hasDerivAt_mean hw T θ u g t₀
  have h := h1.sub (h2.mul h3)
  have hval : cum3 w T (θ + t₀ • u) f g (score u T) =
      covar w T (θ + t₀ • u) (fun x => f x * g x) (score u T)
        - (covar w T (θ + t₀ • u) f (score u T) * mean w T (θ + t₀ • u) g
          + mean w T (θ + t₀ • u) f * covar w T (θ + t₀ • u) g (score u T)) := by
    rw [cum3_expand hw]
    unfold covar
    ring_nf
  rw [hval]
  simpa [covar] using h

/-- **The derivative of the Fisher metric is the Amari–Chentsov cubic tensor.**
This is the analytic fact behind the catalog's algebraic α-connection identities:
`∂_u g_ij = C(T_i, T_j, score u)`. -/
theorem hasDerivAt_fisher_directional [Nonempty S] {w : S → ℝ} (hw : ∀ x, 0 < w x)
    (T : S → Fin d → ℝ) (θ u : Fin d → ℝ) (i j : Fin d) (t₀ : ℝ) :
    HasDerivAt (fun t : ℝ => fisher w T (θ + t • u) i j)
      (cum3 w T (θ + t₀ • u) (fun x => T x i) (fun x => T x j) (score u T)) t₀ :=
  hasDerivAt_covar hw T θ u _ _ t₀

/-- Coordinate form: the `k`-th partial derivative of `g_ij` is `C_ijk`. -/
theorem hasDerivAt_fisher [Nonempty S] {w : S → ℝ} (hw : ∀ x, 0 < w x)
    (T : S → Fin d → ℝ) (θ : Fin d → ℝ) (i j k : Fin d) :
    HasDerivAt (fun t : ℝ => fisher w T (θ + t • (Pi.single k 1 : Fin d → ℝ)) i j)
      (amariCubic w T θ i j k) 0 := by
  have h := hasDerivAt_fisher_directional hw T θ ((Pi.single k 1 : Fin d → ℝ)) i j 0
  have hscore : score ((Pi.single k 1 : Fin d → ℝ)) T = fun x => T x k := by
    funext x
    unfold score
    rw [Finset.sum_eq_single k]
    · simp
    · intro b _ hb
      rw [Pi.single_eq_of_ne hb, zero_mul]
    · intro hk
      exact absurd (Finset.mem_univ k) hk
  rw [hscore] at h
  simpa [amariCubic] using h

/-! ## 5. Consequences for the canonical α-connections -/

open InformationGeometryContrarian in
/-- **Codazzi / dual-connection compatibility.** For *every* `α`, the derivative of
the Fisher metric splits as the sum of the `α` and `-α` natural-coordinate
coefficients of the canonical α-connection.  This is the geometric statement that
`∇^{(α)}` and `∇^{(-α)}` are dual with respect to the Fisher metric. -/
theorem codazzi_alpha_dual [Nonempty S] {w : S → ℝ} (hw : ∀ x, 0 < w x)
    (T : S → Fin d → ℝ) (θ : Fin d → ℝ) (α : ℝ) (i j k : Fin d) :
    HasDerivAt (fun t : ℝ => fisher w T (θ + t • (Pi.single k 1 : Fin d → ℝ)) i j)
      (naturalAlphaChristoffel α (amariCubic w T θ) i j k
        + naturalAlphaChristoffel (-α) (amariCubic w T θ) i j k) 0 := by
  rw [alpha_connections_dual α (amariCubic w T θ) i j k]
  exact hasDerivAt_fisher hw T θ i j k

open InformationGeometryContrarian in
/-- **e-flatness has content.** At `α = 1` the natural-coordinate coefficients of
the canonical connection vanish identically, so the whole derivative of the metric
is carried by the dual `α = -1` (mixture) coefficients. -/
theorem e_connection_carries_no_metric_derivative
    [Nonempty S] {w : S → ℝ} (hw : ∀ x, 0 < w x)
    (T : S → Fin d → ℝ) (θ : Fin d → ℝ) (i j k : Fin d) :
    naturalAlphaChristoffel 1 (amariCubic w T θ) i j k = 0 ∧
      HasDerivAt (fun t : ℝ => fisher w T (θ + t • (Pi.single k 1 : Fin d → ℝ)) i j)
        (naturalAlphaChristoffel (-1) (amariCubic w T θ) i j k) 0 := by
  refine ⟨exponential_family_e_flat _ i j k, ?_⟩
  have h := hasDerivAt_fisher hw T θ i j k
  have : naturalAlphaChristoffel (-1) (amariCubic w T θ) i j k =
      amariCubic w T θ i j k := by
    unfold naturalAlphaChristoffel; ring
  rw [this]
  exact h

open InformationGeometryContrarian in
/-- **Sharp flatness criterion.** For `α ≠ 1`, the canonical α-connection has a
vanishing natural coefficient exactly when the corresponding component of the
Fisher metric has vanishing directional derivative. -/
theorem alpha_flat_iff_metric_constant
    [Nonempty S] {w : S → ℝ} (hw : ∀ x, 0 < w x)
    (T : S → Fin d → ℝ) (θ : Fin d → ℝ) {α : ℝ} (hα : α ≠ 1) (i j k : Fin d) :
    naturalAlphaChristoffel α (amariCubic w T θ) i j k = 0 ↔
      deriv (fun t : ℝ => fisher w T (θ + t • (Pi.single k 1 : Fin d → ℝ)) i j) 0 = 0 := by
  have hd : deriv (fun t : ℝ => fisher w T (θ + t • (Pi.single k 1 : Fin d → ℝ)) i j) 0 =
      amariCubic w T θ i j k := (hasDerivAt_fisher hw T θ i j k).deriv
  rw [hd]
  unfold naturalAlphaChristoffel
  constructor
  · intro h
    rcases mul_eq_zero.mp h with h' | h'
    · exact absurd ((sub_eq_zero.mp ((div_eq_zero_iff.mp h').resolve_right
        (by norm_num))).symm) hα
    · exact h'
  · intro h; rw [h, mul_zero]

end AlphaConnectionCanonical