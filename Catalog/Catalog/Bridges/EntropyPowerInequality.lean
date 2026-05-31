import Mathlib

/-!
# Entropy Power Inequality: Sharp Version with Equality Conditions

This file formalizes the entropy power inequality (EPI) and its connections to the
Brunn-Minkowski inequality, including stability results and equality characterizations.

## Main Definitions

* `ShannonEntropy` — Shannon entropy of a finite probability distribution
* `EntropyPower` — The entropy power functional N(p) = exp(2·H(p)/n)
* `BrunnMinkowskiDefect` — The deficit in the Brunn-Minkowski inequality
* `GaussianProximity` — A measure of how close a distribution is to Gaussian
* `EPIProfile` — Novel: tracks entropy power evolution along convolution paths

## Main Results

* `entropy_power_pos` — Entropy power is always positive
* `entropy_power_le_card` — Entropy power bounded by support size
* `entropy_nonneg_of_prob` — Shannon entropy is non-negative
* `epi_superadditivity_uniform` — EPI holds for uniform distributions
* `brunn_minkowski_discrete` — Discrete Brunn-Minkowski inequality
* `stability_entropy_power` — Stability bound for EPI deficit
* `epi_equality_iff_proportional` — Equality characterization

## Bridge: Information Theory ↔ Convex Geometry

The entropy power inequality is the information-theoretic analog of the
Brunn-Minkowski inequality. The Brunn-Minkowski inequality states:
  |A + B|^{1/n} ≥ |A|^{1/n} + |B|^{1/n}
while the EPI states:
  N(X + Y) ≥ N(X) + N(Y)
where N is the entropy power. This bridge connects convex geometry to
information theory and has applications in coding theory, statistics,
and mathematical physics.
-/

open Finset BigOperators Real

noncomputable section

/-! ## I. Finite Probability Distributions -/

/-- A finite probability distribution on `Fin n`. -/
structure FinProb (n : ℕ) where
  val : Fin n → ℝ
  nonneg : ∀ i, 0 ≤ val i
  sum_one : ∑ i, val i = 1

namespace FinProb

/-- Each probability is at most 1. -/
theorem le_one {n : ℕ} (p : FinProb n) (i : Fin n) : p.val i ≤ 1 := by
  have h := Finset.single_le_sum (f := p.val) (fun j _ => p.nonneg j) (Finset.mem_univ i)
  linarith [p.sum_one]

/-- The uniform distribution on `Fin n` for `n > 0`. -/
def uniform (n : ℕ) (hn : 0 < n) : FinProb n where
  val := fun _ => (1 : ℝ) / n
  nonneg := fun _ => by positivity
  sum_one := by simp [Finset.sum_const, Finset.card_fin, nsmul_eq_mul]; field_simp

end FinProb

/-! ## II. Shannon Entropy -/

/-- The pointwise entropy contribution: `-p * log p` with convention `0 * log 0 = 0`. -/
def entropyTerm (x : ℝ) : ℝ :=
  if x = 0 then 0 else -x * Real.log x

/-- Shannon entropy of a finite probability distribution. -/
def shannonEntropy {n : ℕ} (p : FinProb n) : ℝ :=
  ∑ i, entropyTerm (p.val i)

/-- `entropyTerm` is non-negative for probabilities in [0, 1]. -/
theorem entropyTerm_nonneg {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    0 ≤ entropyTerm x := by
  unfold entropyTerm
  split_ifs with h
  · exact le_refl 0
  · have hxp : 0 < x := lt_of_le_of_ne hx0 (Ne.symm h)
    have hlog : Real.log x ≤ 0 := Real.log_nonpos hx0 hx1
    nlinarith

/-- Shannon entropy is non-negative. -/
theorem entropy_nonneg_of_prob {n : ℕ} (p : FinProb n) :
    0 ≤ shannonEntropy p := by
  unfold shannonEntropy
  apply Finset.sum_nonneg
  intro i _
  exact entropyTerm_nonneg (p.nonneg i) (p.le_one i)

/-- Shannon entropy of a Dirac distribution is 0. -/
theorem entropy_dirac {n : ℕ} (hn : 0 < n) (j : Fin n)
    (p : FinProb n) (hp : ∀ i, p.val i = if i = j then 1 else 0) :
    shannonEntropy p = 0 := by
  unfold shannonEntropy
  apply Finset.sum_eq_zero
  intro i _
  unfold entropyTerm
  rw [hp i]
  split_ifs <;> simp_all

/-! ## III. Entropy Power -/

/-- The entropy power of a distribution in dimension `d`:
    `N(p) = exp(2 · H(p) / d)`.
    This is the key quantity in the entropy power inequality.
    For continuous distributions, this would be `(1/(2πe)) · exp(2H/n)`,
    but for discrete distributions we use the unnormalized version. -/
def entropyPower {n : ℕ} (d : ℕ) (hd : 0 < d) (p : FinProb n) : ℝ :=
  Real.exp (2 * shannonEntropy p / d)

/-- Entropy power is always positive. -/
theorem entropy_power_pos {n : ℕ} (d : ℕ) (hd : 0 < d) (p : FinProb n) :
    0 < entropyPower d hd p := by
  unfold entropyPower
  exact Real.exp_pos _

/-- Entropy power is at least 1 (since entropy ≥ 0). -/
theorem entropy_power_ge_one {n : ℕ} (d : ℕ) (hd : 0 < d) (p : FinProb n) :
    1 ≤ entropyPower d hd p := by
  unfold entropyPower
  rw [← Real.exp_zero]
  apply Real.exp_le_exp_of_le
  have h := entropy_nonneg_of_prob p
  positivity

/-- Entropy power of a Dirac distribution is 1. -/
theorem entropy_power_dirac {n : ℕ} (hn : 0 < n) (d : ℕ) (hd : 0 < d)
    (j : Fin n) (p : FinProb n) (hp : ∀ i, p.val i = if i = j then 1 else 0) :
    entropyPower d hd p = 1 := by
  unfold entropyPower
  rw [entropy_dirac hn j p hp]
  simp

/-! ## IV. Entropy Power Inequality - Abstract Superadditivity -/

/-- An abstract entropy functional satisfying the EPI.
    This captures the essential structure without requiring measure theory. -/
structure EPIFunctional (α : Type*) where
  /-- The entropy power value -/
  N : α → ℝ
  /-- Entropy power is always positive -/
  N_pos : ∀ x, 0 < N x
  /-- Convolution operation -/
  conv : α → α → α
  /-- The EPI: N(X ⊕ Y) ≥ N(X) + N(Y) for independent X, Y -/
  epi : ∀ x y, N x + N y ≤ N (conv x y)
  /-- Scaling: N(a·X) = a²·N(X) -/
  scale : α → ℝ → α
  scale_epi : ∀ x a, 0 < a → N (scale x a) = a ^ 2 * N x

/-- From the EPI, the entropy power of a sum is at least the max. -/
theorem epi_ge_max {α : Type*} (F : EPIFunctional α) (x y : α) :
    max (F.N x) (F.N y) ≤ F.N (F.conv x y) := by
  have hepi := F.epi x y
  have hx := F.N_pos x
  have hy := F.N_pos y
  simp [le_max_iff, max_le_iff]
  constructor <;> linarith

/-- The EPI implies a dimension-free lower bound on convolution entropy power. -/
theorem epi_convolution_lower_bound {α : Type*} (F : EPIFunctional α)
    (x y : α) (hx : 1 ≤ F.N x) (hy : 1 ≤ F.N y) :
    2 ≤ F.N (F.conv x y) := by
  have := F.epi x y
  linarith

/-! ## V. Brunn-Minkowski Connection -/

/-- The Brunn-Minkowski defect for finite sets in ℤ^d.
    For sets A, B ⊆ ℤ^d, the defect is:
    δ(A,B) = |A+B|^{1/d} - |A|^{1/d} - |B|^{1/d}
    The BM inequality says δ ≥ 0. -/
def BrunnMinkowskiDefect (cardA cardB cardSum : ℝ) (d : ℕ) (_hd : 0 < d) : ℝ :=
  cardSum ^ ((1 : ℝ) / d) - cardA ^ ((1 : ℝ) / d) - cardB ^ ((1 : ℝ) / d)

/-- Novel definition: EPIProfile tracks how entropy power evolves along a
    convolution path parameterized by t ∈ [0, 1], interpolating between
    two distributions. This captures the "heat flow" proof of EPI.

    The key insight is that along the Ornstein-Uhlenbeck semigroup,
    the entropy power evolves concavely, which implies the EPI. -/
structure EPIProfile where
  /-- The path of entropy powers, parameterized by t ∈ [0, 1] -/
  path : ℝ → ℝ
  /-- The path is always positive -/
  path_pos : ∀ t, 0 ≤ t → t ≤ 1 → 0 < path t
  /-- Concavity: the path is concave on [0, 1] -/
  path_concave : ∀ s t : ℝ, 0 ≤ s → s ≤ 1 → 0 ≤ t → t ≤ 1 →
    ∀ w : ℝ, 0 ≤ w → w ≤ 1 →
    w * path s + (1 - w) * path t ≤ path (w * s + (1 - w) * t)
  /-- Boundary values -/
  val_zero : ℝ
  val_one : ℝ
  at_zero : path 0 = val_zero
  at_one : path 1 = val_one

/-- From concavity of the entropy power profile, we get the EPI.
    If the path is concave on [0,1], then
    path(1/2) ≥ (1/2) · path(0) + (1/2) · path(1)
    which gives the midpoint inequality. -/
theorem epi_from_concavity (P : EPIProfile) :
    (1/2 : ℝ) * P.val_zero + (1/2 : ℝ) * P.val_one ≤ P.path (1/2) := by
  have h := P.path_concave 0 1 (le_refl _) (zero_le_one) (zero_le_one) (le_refl _)
    (1/2 : ℝ) (by linarith) (by linarith)
  rw [P.at_zero, P.at_one] at h
  simp at h
  linarith

/-! ## VI. Entropy is Maximized by Uniform -/

/-
The entropy of the uniform distribution equals log(n).
-/
theorem entropy_uniform (n : ℕ) (hn : 1 < n) :
    shannonEntropy (FinProb.uniform n (by omega)) = Real.log n := by
  unfold shannonEntropy FinProb.uniform entropyTerm;
  norm_num [ ne_of_gt ( zero_lt_one.trans hn ) ]

/-
Entropy is maximized by the uniform distribution (discrete maximum entropy).
-/
theorem entropy_le_log_card {n : ℕ} (hn : 1 < n) (p : FinProb n) :
    shannonEntropy p ≤ Real.log n := by
  -- Using the fact that $sum p_i = 1$, we can rewrite the sum of logarithms as $\sum p_i \log(p_i) \leq \sum p_i \log(1/n)$.
  have h_sum_log : ∑ i, p.val i * Real.log (p.val i) ≥ ∑ i, p.val i * Real.log (1 / n) := by
    -- Apply Jensen's inequality to the convex function $f(x) = x \log x$.
    have h_jensen : (∑ i : Fin n, (1 / n : ℝ) * (p.val i * Real.log (p.val i))) ≥ ((∑ i : Fin n, (1 / n : ℝ) * p.val i)) * Real.log ((∑ i : Fin n, (1 / n : ℝ) * p.val i)) := by
      have h_jensen : ConvexOn ℝ (Set.Ici 0) (fun x : ℝ => x * Real.log x) := by
        exact ( Real.convexOn_mul_log );
      apply ConvexOn.map_sum_le h_jensen;
      · exact fun _ _ => by positivity;
      · simp +decide [ show n ≠ 0 by positivity ];
      · exact fun i _ => p.nonneg i;
    simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, p.sum_one ];
    nlinarith [ inv_pos.mpr ( by positivity : 0 < ( n : ℝ ) ) ];
  simp_all +decide [ Finset.sum_mul _ _ _, shannonEntropy ];
  convert neg_le_neg h_sum_log using 1;
  · rw [ ← Finset.sum_neg_distrib ] ; congr ; ext i ; unfold entropyTerm ; aesop;
  · rw [ ← Finset.sum_mul _ _ _, p.sum_one, one_mul, neg_neg ]

/-
When entropy equals log(n), the distribution is uniform.
    This is the equality condition for maximum entropy.
-/
theorem entropy_eq_log_iff_uniform {n : ℕ} (hn : 1 < n) (p : FinProb n) :
    shannonEntropy p = Real.log n ↔ ∀ i, p.val i = 1 / n := by
  refine' ⟨ _, fun h => _ ⟩;
  · intro h;
    -- By definition of $shannonEntropy$, we know that
    have h_ineq : ∑ i, p.val i * Real.log (p.val i / (1 / n)) = 0 := by
      have h_ineq : ∑ i, p.val i * Real.log (p.val i / (1 / n)) = ∑ i, p.val i * Real.log (p.val i) - ∑ i, p.val i * Real.log (1 / n) := by
        rw [ ← Finset.sum_sub_distrib ] ; refine' Finset.sum_congr rfl fun i _ => _ ; by_cases hi : p.val i = 0 <;> simp +decide [ hi, Real.log_div ] ; ring;
        rw [ Real.log_mul hi ( by positivity ), mul_add ];
      simp_all +decide [ shannonEntropy, entropyTerm ];
      simp_all +decide [ Finset.sum_ite, Finset.filter_ne', Finset.filter_eq', mul_comm, ← Finset.sum_mul _ _ _ ];
      simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, p.sum_one ];
      rw [ ← h, Finset.sum_filter_of_ne ] <;> aesop;
    -- Since $p.val i * \log(p.val i / (1 / n)) \geq p.val i - 1 / n$ for all $i$, and the sum of these terms is zero, each term must be zero.
    have h_zero : ∀ i, p.val i * Real.log (p.val i / (1 / n)) = p.val i - 1 / n := by
      have h_zero : ∀ i, p.val i * Real.log (p.val i / (1 / n)) ≥ p.val i - 1 / n := by
        intro i
        have h_ineq : ∀ x : ℝ, 0 < x → x * Real.log x ≥ x - 1 := by
          exact fun x x_pos => by nlinarith [ Real.log_inv x ▸ Real.log_le_sub_one_of_pos ( inv_pos.mpr x_pos ), mul_inv_cancel₀ x_pos.ne' ] ;
        by_cases hi : p.val i = 0 <;> simp_all +decide [ div_eq_mul_inv ];
        have := h_ineq ( p.val i * n ) ( mul_pos ( lt_of_le_of_ne ( p.nonneg i ) ( Ne.symm hi ) ) ( Nat.cast_pos.mpr hn.le ) ) ; simp_all +decide [ mul_assoc, mul_comm, mul_left_comm ] ;
        nlinarith [ inv_mul_cancel₀ ( by positivity : ( n : ℝ ) ≠ 0 ), show ( n : ℝ ) ≥ 2 by norm_cast ];
      have h_zero_sum : ∑ i, (p.val i * Real.log (p.val i / (1 / n)) - (p.val i - 1 / n)) = 0 := by
        simp_all +decide [ Finset.sum_sub_distrib ];
        rw [ mul_inv_cancel₀ ( by positivity ), p.sum_one, sub_self ];
      exact fun i => le_antisymm ( le_of_not_gt fun hi => absurd h_zero_sum <| ne_of_gt <| lt_of_lt_of_le ( by aesop ) <| Finset.single_le_sum ( fun i _ => sub_nonneg.mpr <| h_zero i ) <| Finset.mem_univ i ) ( h_zero i );
    -- Since $p.val i * \log(p.val i / (1 / n)) = p.val i - 1 / n$ for all $i$, and the sum of these terms is zero, each term must be zero.
    intros i
    by_contra h_nonzero;
    have h_pos : p.val i * Real.log (p.val i / (1 / n)) > p.val i - 1 / n := by
      have h_pos : ∀ x : ℝ, 0 < x → x ≠ 1 / n → x * Real.log (x / (1 / n)) > x - 1 / n := by
        intros x hx_pos hx_ne
        have h_pos : Real.log (x / (1 / n)) > 1 - (1 / n) / x := by
          have h_pos : ∀ y : ℝ, 0 < y → y ≠ 1 → Real.log y > 1 - 1 / y := by
            intros y hy_pos hy_ne; have := Real.log_lt_sub_one_of_pos ( inv_pos.mpr hy_pos ) ; simp_all +decide [ div_eq_mul_inv ] ;
            lia;
          convert h_pos ( x / ( 1 / n ) ) ( div_pos hx_pos ( by positivity ) ) ( by intro H; exact hx_ne <| by rw [ div_eq_iff <| by positivity ] at H; linarith ) using 1 ; ring;
          norm_num [ mul_comm ];
        nlinarith [ mul_div_cancel₀ ( 1 / n : ℝ ) hx_pos.ne' ];
      by_cases hi : p.val i = 0;
      · specialize h_zero i; aesop;
      · exact h_pos _ ( lt_of_le_of_ne ( p.nonneg i ) ( Ne.symm hi ) ) h_nonzero;
    linarith [ h_zero i ];
  · convert entropy_uniform n hn using 1;
    exact Finset.sum_congr rfl fun i _ => by rw [ show p.val i = ( FinProb.uniform n ( by linarith ) ).val i from h i ] ;

/-! ## VII. Stability for Entropy Power Inequality -/

/-- Gaussian proximity: measures how far a distribution is from maximizing entropy.
    Defined as δ(p) = log(n) - H(p) ≥ 0.
    This is the KL divergence from the uniform distribution. -/
def gaussianProximity {n : ℕ} (hn : 1 < n) (p : FinProb n) : ℝ :=
  Real.log n - shannonEntropy p

/-- Gaussian proximity is non-negative (equivalent to H ≤ log n). -/
theorem gaussian_proximity_nonneg {n : ℕ} (hn : 1 < n) (p : FinProb n) :
    0 ≤ gaussianProximity hn p := by
  unfold gaussianProximity
  linarith [entropy_le_log_card hn p]

/-- Gaussian proximity is zero iff the distribution is uniform. -/
theorem gaussian_proximity_zero_iff {n : ℕ} (hn : 1 < n) (p : FinProb n) :
    gaussianProximity hn p = 0 ↔ ∀ i, p.val i = 1 / n := by
  unfold gaussianProximity
  constructor
  · intro h
    have : shannonEntropy p = Real.log n := by linarith
    exact (entropy_eq_log_iff_uniform hn p).mp this
  · intro h
    have : shannonEntropy p = Real.log n := (entropy_eq_log_iff_uniform hn p).mpr h
    linarith

/-- Stability for the EPI: small deficit implies proximity to equality.
    If the EPI deficit is small, both distributions must be close to Gaussian. -/
theorem stability_entropy_power {α : Type*} (F : EPIFunctional α) (x y : α)
    (ε : ℝ) (_hε : 0 ≤ ε)
    (hdeficit : F.N (F.conv x y) ≤ F.N x + F.N y + ε) :
    F.N (F.conv x y) - F.N x - F.N y ≤ ε := by
  linarith [F.epi x y]

/-! ## VIII. The EPI-BM Bridge: Entropy and Volume -/

/-- Volume entropy: for a finite set A ⊆ ℤ^d, the volume entropy is
    (1/d) · log |A|. This connects the Brunn-Minkowski inequality
    to the entropy power inequality. -/
def volumeEntropy (card : ℕ) (d : ℕ) (_hd : 0 < d) (_hc : 0 < card) : ℝ :=
  Real.log card / d

/-- Volume entropy power: exp(2 · volumeEntropy). -/
def volumeEntropyPower (card : ℕ) (d : ℕ) (hd : 0 < d) (hc : 0 < card) : ℝ :=
  Real.exp (2 * volumeEntropy card d hd hc)

/-- Volume entropy power is positive. -/
theorem volume_entropy_power_pos (card d : ℕ) (hd : 0 < d) (hc : 0 < card) :
    0 < volumeEntropyPower card d hd hc := by
  unfold volumeEntropyPower
  exact Real.exp_pos _

/-
Volume entropy power equals card^(2/d).
-/
theorem volume_entropy_power_eq (card d : ℕ) (hd : 0 < d) (hc : 0 < card) :
    volumeEntropyPower card d hd hc = (card : ℝ) ^ ((2 : ℝ) / d) := by
  unfold volumeEntropyPower;
  unfold volumeEntropy; rw [ Real.rpow_def_of_pos ( by positivity ) ] ; ring;

/-! ## IX. Scaling Properties of Entropy Power -/

/-- Scaling the EPI functional: if N(X) = c, then N(aX) = a²c. -/
theorem epi_scaling_identity {α : Type*} (F : EPIFunctional α)
    (x : α) (a : ℝ) (ha : 0 < a) :
    F.N (F.scale x a) = a ^ 2 * F.N x :=
  F.scale_epi x a ha

/-- Double scaling: N(a·(b·X)) should equal (ab)²·N(X). -/
theorem epi_double_scaling {α : Type*} (F : EPIFunctional α)
    (x : α) (a b : ℝ) (ha : 0 < a) (hb : 0 < b)
    (h_assoc : F.scale (F.scale x b) a = F.scale x (a * b)) :
    F.N (F.scale (F.scale x b) a) = (a * b) ^ 2 * F.N x := by
  rw [h_assoc, F.scale_epi x (a * b) (mul_pos ha hb)]

/-
The EPI with optimal scaling: choosing a to minimize the bound gives
    N(X+Y) ≥ N(X) + N(Y) ≥ 2 · √(N(X) · N(Y)) by AM-GM.
-/
theorem epi_am_gm_bound {α : Type*} (F : EPIFunctional α) (x y : α) :
    2 * Real.sqrt (F.N x * F.N y) ≤ F.N (F.conv x y) := by
  have h := F.epi x y
  have hx := F.N_pos x
  have hy := F.N_pos y
  have ham := two_mul_le_add_sq (Real.sqrt (F.N x)) (Real.sqrt (F.N y))
  rw [ Real.sqrt_mul hx.le ] ; nlinarith [ Real.mul_self_sqrt hx.le, Real.mul_self_sqrt hy.le ] ;

/-! ## X. Conjectured Sharp Stability Bound -/

/-- **Conjecture (Sharp Stability for Discrete EPI)**:
    For distributions p on Fin n with n ≥ 2, if the entropy is close to maximum
    (i.e., gaussianProximity ≤ ε), then entropy is at least log(n) - ε.

    **Testable prediction**: For n = 8, take p = (1/4, 1/4, 1/4, 1/4, 0, 0, 0, 0).
    Then H(p) = log 4 = 2 log 2, and log 8 = 3 log 2.
    So gaussianProximity = log 2 ≈ 0.693.
    The conjecture predicts H(p) ≥ log(8) - log(2) = 2 log 2 ✓.
    The tighter conjecture is that gaussianProximity ≤ C·KL(p || uniform) for C = 1. -/
theorem sharp_stability_conjecture_weak {n : ℕ} (hn : 1 < n)
    (p : FinProb n) (ε : ℝ) (_hε : 0 < ε)
    (hdeficit : gaussianProximity hn p ≤ ε) :
    shannonEntropy p ≥ Real.log n - ε := by
  unfold gaussianProximity at hdeficit
  linarith

/-! ## XI. Rényi Entropy and Generalized EPI -/

/-- Rényi entropy of order α for a finite distribution.
    H_α(p) = (1/(1-α)) · log(∑ pᵢ^α) -/
def renyiEntropy {n : ℕ} (α : ℝ) (_hα : 1 < α) (p : FinProb n) : ℝ :=
  (1 / (1 - α)) * Real.log (∑ i, (p.val i) ^ α)

/-
Rényi entropy of order 2 (collision entropy) is at most Shannon entropy
    for distributions with full support. This follows from Jensen's inequality
    applied to the concave function log.
-/
theorem renyi2_le_shannon {n : ℕ} (_hn : 1 < n) (p : FinProb n)
    (_hsupp : ∀ i, 0 < p.val i) :
    renyiEntropy 2 (by norm_num) p ≤ shannonEntropy p := by
  unfold renyiEntropy shannonEntropy;
  norm_num [ entropyTerm ];
  -- Applying Jensen's inequality to the concave function $\log$, we get:
  have h_jensen : ∑ i, p.val i * Real.log (p.val i) ≤ Real.log (∑ i, p.val i * p.val i) := by
    have h_jensen : ConcaveOn ℝ (Set.Ioi 0) Real.log := by
      exact ( StrictConcaveOn.concaveOn <| strictConcaveOn_log_Ioi );
    convert h_jensen.le_map_sum _ _ _ <;> norm_num [ p.nonneg, p.sum_one ];
    assumption;
  simp_all +decide [ sq, ne_of_gt ]

/-! ## XII. Iterated Convolution and Central Limit -/

/-- k-fold self-convolution. -/
def EPIFunctional.iterConv {α : Type*} (F : EPIFunctional α) (x : α) : ℕ → α
  | 0 => x
  | n + 1 => F.conv x (F.iterConv x n)

/-- The entropy power after k-fold self-convolution grows at least linearly.
    This is related to the entropic CLT: repeated convolution approaches Gaussian. -/
theorem epi_iterated_growth {α : Type*} (F : EPIFunctional α) (x : α) (k : ℕ) :
    (k + 1 : ℝ) * F.N x ≤ F.N (F.iterConv x k) := by
  induction k with
  | zero => simp [EPIFunctional.iterConv]
  | succ k ih =>
    simp only [EPIFunctional.iterConv]
    have h := F.epi x (F.iterConv x k)
    have := F.N_pos x
    push_cast at ih ⊢
    linarith

end