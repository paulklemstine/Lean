/-
# Biased Fourier analysis on the cube and the square-root law for influences

The summed reverse Poincaré inequality of
`Catalog/Combinatorics/BernoulliReversePoincare.lean` bounds the total influence
of an increasing event by `|ι|` times the variance divided by `p(1-p)`.  The
factor `|ι|` is the trivial one obtained by adding `|ι|` sharp per-site
inequalities, and exhaustive enumeration over all monotone events on at most
four sites shows that it is far from optimal.

This file proves the optimal square-root bound by developing, from scratch, the
`p`-biased Fourier analysis of the discrete cube:

* `psi p v η = 1-p` or `-p` is the centred (unnormalized) Walsh character of the
  site `v` for the Bernoulli measure of density `p`;
* `expP p f` is the expectation of `f` under that measure;
* `expP_split` reduces every expectation to a one-coordinate computation, and
  from it `expP_psi`, `expP_psi_mul_psi` give the orthogonality relations
  `E[ψ_v] = 0` and `E[ψ_u ψ_v] = [u = v] · p(1-p)`;
* `expP_signInd_mul_psi` identifies the degree-one Fourier coefficient of the
  `±1`-indicator of an increasing event with the influence
  `I_v = bernProb p (pivotalSet A v)`: `E[g ψ_v] = 2 p(1-p) I_v`.  This is the
  Fourier-analytic form of the Margulis–Russo formula;
* `bessel_aux` is Bessel's inequality for the orthogonal family `{1} ∪ {ψ_v}`;
* `sum_sq_influence_le` is the resulting `ℓ²` influence bound
  `p(1-p) ∑_v I_v² ≤ P (1-P)`, valid at *every* density;
* `sq_sum_influence_le` and `sum_influence_le_sqrt_card` convert it, by
  Cauchy–Schwarz, into the square-root law
  `(∑_v I_v)² ≤ |ι| P(1-P) / (p(1-p))`, in particular `∑_v I_v ≤ sqrt |ι|` at
  `p = 1/2`.

The square-root law is sharp up to a constant: majority on `2m+1` sites has
total influence of order `sqrt |ι|` at `p = 1/2`.  It improves the factor `|ι|`
of `sum_pivotal_le_card_variance` and says that no increasing event on `|ι|`
sites can have a threshold window of width smaller than of order
`1 / sqrt |ι|`.

Everything here is proved by finite algebra: no measure theory, no
hypercontractivity, and no analysis beyond a single square root.
-/

import Combinatorics.BernoulliReversePoincare

open Finset

namespace BernoulliThresholdCoupling

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## The biased Walsh characters and the biased expectation -/

/-- The centred Walsh character of a single site for the density `p`:
`1 - p` if the site is open, `-p` if it is closed.  It has mean zero and
variance `p(1-p)`. -/
def psi (p : ℝ) (v : ι) (η : ι → Bool) : ℝ := if η v then 1 - p else -p

/-- Expectation with respect to the Bernoulli measure of density `p`. -/
noncomputable def expP (p : ℝ) (f : (ι → Bool) → ℝ) : ℝ :=
  ∑ η : ι → Bool, weight p η * f η

open Classical in
/-- The `±1` indicator of an event. -/
noncomputable def signInd (A : Set (ι → Bool)) (η : ι → Bool) : ℝ :=
  if η ∈ A then 1 else -1

/-! ### Linearity -/

theorem expP_sub (p : ℝ) (f g : (ι → Bool) → ℝ) :
    expP p (fun η => f η - g η) = expP p f - expP p g := by
  unfold expP
  rw [← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl fun η _ => by ring

theorem expP_const_mul (p c : ℝ) (f : (ι → Bool) → ℝ) :
    expP p (fun η => c * f η) = c * expP p f := by
  unfold expP
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun η _ => by ring

theorem expP_const (p c : ℝ) : expP p (fun _ : ι → Bool => c) = c := by
  unfold expP
  rw [← Finset.sum_mul, sum_weight, one_mul]

theorem expP_nonneg {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {f : (ι → Bool) → ℝ}
    (hf : ∀ η, 0 ≤ f η) : 0 ≤ expP p f :=
  Finset.sum_nonneg fun η _ => mul_nonneg (weight_nonneg hp0 hp1 η) (hf η)

/-! ### The one-coordinate splitting of an expectation -/

/-- Every expectation can be computed by conditioning on a single coordinate. -/
theorem expP_split (p : ℝ) (v : ι) (f : (ι → Bool) → ℝ) :
    expP p f = ∑ η ∈ univ.filter (fun η : ι → Bool => η v = true),
      offWeight p v η * (p * f η + (1 - p) * f (Function.update η v false)) := by
  rw [expP, sum_split v]
  refine Finset.sum_congr rfl fun η hη => ?_
  simp only [mem_filter, mem_univ, true_and] at hη
  have hoff : offWeight p v (Function.update η v false) = offWeight p v η :=
    offWeight_update p v η false
  have hw1 : weight p η = p * offWeight p v η := by
    rw [weight_eq_mul_offWeight p v η, hη]; norm_num
  have hw2 : weight p (Function.update η v false) = (1 - p) * offWeight p v η := by
    rw [weight_eq_mul_offWeight p v (Function.update η v false), Function.update_self, hoff]
    norm_num
  rw [hw1, hw2]
  ring

/-! ### Orthogonality of the biased characters -/

theorem expP_psi (p : ℝ) (v : ι) : expP p (psi p v) = 0 := by
  rw [expP_split p v]
  refine Finset.sum_eq_zero fun η hη => ?_
  simp only [mem_filter, mem_univ, true_and] at hη
  have h1 : psi p v η = 1 - p := by rw [psi, hη]; norm_num
  have h2 : psi p v (Function.update η v false) = -p := by
    rw [psi, Function.update_self]; norm_num
  rw [h1, h2]
  ring

/-- The variance of a biased character is `p(1-p)`. -/
theorem expP_psi_sq (p : ℝ) (v : ι) :
    expP p (fun η => psi p v η * psi p v η) = p * (1 - p) := by
  rw [expP_split p v]
  have hterm : ∀ η ∈ univ.filter (fun η : ι → Bool => η v = true),
      offWeight p v η * (p * (psi p v η * psi p v η)
        + (1 - p) * (psi p v (Function.update η v false)
            * psi p v (Function.update η v false)))
      = p * (1 - p) * offWeight p v η := by
    intro η hη
    simp only [mem_filter, mem_univ, true_and] at hη
    have h1 : psi p v η = 1 - p := by rw [psi, hη]; norm_num
    have h2 : psi p v (Function.update η v false) = -p := by
      rw [psi, Function.update_self]; norm_num
    rw [h1, h2]
    ring
  rw [Finset.sum_congr rfl hterm, ← Finset.mul_sum, sum_offWeight_filter, mul_one]

theorem expP_psi_mul_psi_of_ne (p : ℝ) {u v : ι} (huv : u ≠ v) :
    expP p (fun η => psi p u η * psi p v η) = 0 := by
  rw [expP_split p u]
  refine Finset.sum_eq_zero fun η hη => ?_
  simp only [mem_filter, mem_univ, true_and] at hη
  have h1 : psi p u η = 1 - p := by rw [psi, hη]; norm_num
  have h2 : psi p u (Function.update η u false) = -p := by
    rw [psi, Function.update_self]; norm_num
  have h3 : psi p v (Function.update η u false) = psi p v η := by
    rw [psi, psi, Function.update_of_ne (Ne.symm huv)]
  rw [h1, h2, h3]
  ring

/-- **Orthogonality.**  The biased characters are pairwise orthogonal with
squared norm `p(1-p)`. -/
theorem expP_psi_mul_psi (p : ℝ) (u v : ι) :
    expP p (fun η => psi p u η * psi p v η) = if u = v then p * (1 - p) else 0 := by
  by_cases huv : u = v
  · subst huv
    rw [if_pos rfl, expP_psi_sq]
  · rw [if_neg huv, expP_psi_mul_psi_of_ne p huv]

/-! ## Fourier coefficients of an increasing event -/

theorem expP_signInd (p : ℝ) (A : Set (ι → Bool)) :
    expP p (fun η => signInd A η) = 2 * bernProb p A - 1 := by
  classical
  have hfun : (fun η : ι → Bool => signInd A η)
      = fun η => 2 * (A.indicator (fun _ => (1 : ℝ)) η) - 1 := by
    funext η
    rw [signInd, Set.indicator_apply]
    by_cases h : η ∈ A <;> simp [h]
    norm_num
  rw [hfun, expP_sub, expP_const_mul, expP_const]
  congr 2
  unfold expP bernProb
  refine Finset.sum_congr rfl fun η _ => ?_
  by_cases h : η ∈ A
  · rw [Set.indicator_of_mem h, Set.indicator_of_mem h, mul_one]
  · rw [Set.indicator_of_notMem h, Set.indicator_of_notMem h, mul_zero]

omit [Fintype ι] [DecidableEq ι] in
theorem signInd_mul_self (A : Set (ι → Bool)) (η : ι → Bool) :
    signInd A η * signInd A η = 1 := by
  unfold signInd
  by_cases h : η ∈ A <;> simp [h]

theorem expP_signInd_sq (p : ℝ) (A : Set (ι → Bool)) :
    expP p (fun η => signInd A η * signInd A η) = 1 := by
  have hfun : (fun η : ι → Bool => signInd A η * signInd A η) = fun _ => (1 : ℝ) :=
    funext fun η => signInd_mul_self A η
  rw [hfun, expP_const]

/-- **The Fourier form of the Margulis–Russo formula.**  The degree-one Fourier
coefficient of the `±1`-indicator of an increasing event at the site `v` equals
`2 p (1-p)` times the influence of `v`. -/
theorem expP_signInd_mul_psi {A : Set (ι → Bool)} (hA : IsIncreasing A) (p : ℝ) (v : ι) :
    expP p (fun η => signInd A η * psi p v η)
      = 2 * bernProb p (pivotalSet A v) * (p * (1 - p)) := by
  classical
  rw [expP_split p v, bernProb_pivotalSet_eq_offProb, offProb, Finset.mul_sum,
    Finset.sum_mul]
  refine Finset.sum_congr rfl fun η hη => ?_
  simp only [mem_filter, mem_univ, true_and] at hη
  have hupd : Function.update η v true = η := Function.update_eq_self_iff.mpr hη.symm
  have h1 : psi p v η = 1 - p := by rw [psi, hη]; norm_num
  have h2 : psi p v (Function.update η v false) = -p := by
    rw [psi, Function.update_self]; norm_num
  rw [h1, h2]
  by_cases hin : η ∈ A
  · by_cases hboth : Function.update η v false ∈ A
    · have hpiv : η ∉ pivotalSet A v := fun h => h.2 hboth
      rw [Set.indicator_of_notMem hpiv, signInd, signInd, if_pos hin, if_pos hboth]
      ring
    · have hpiv : η ∈ pivotalSet A v := ⟨by rwa [hupd], hboth⟩
      rw [Set.indicator_of_mem hpiv, signInd, signInd, if_pos hin, if_neg hboth]
      ring
  · have hboth : Function.update η v false ∉ A := by
      intro hc
      refine hin (hA _ _ (fun u hu => ?_) hc)
      by_cases huv : u = v
      · subst huv; exact hη
      · rwa [Function.update_of_ne huv] at hu
    have hpiv : η ∉ pivotalSet A v := fun h => hin (by rw [← hupd]; exact h.1)
    rw [Set.indicator_of_notMem hpiv, signInd, signInd, if_neg hin, if_neg hboth]
    ring

/-! ## Bessel's inequality -/

/-- The residual of the `±1`-indicator after removing a candidate degree-`≤ 1`
Fourier part. -/
noncomputable def resid (A : Set (ι → Bool)) (p c0 : ℝ) (a : ι → ℝ) (η : ι → Bool) : ℝ :=
  signInd A η - c0 - ∑ v : ι, a v * psi p v η

/-- Linearity of the expectation against the residual. -/
theorem expP_resid_mul (A : Set (ι → Bool)) (p c0 : ℝ) (a : ι → ℝ)
    (f : (ι → Bool) → ℝ) :
    expP p (fun η => resid A p c0 a η * f η)
      = expP p (fun η => signInd A η * f η) - c0 * expP p (fun η => f η)
        - ∑ v : ι, a v * expP p (fun η => psi p v η * f η) := by
  have hterm : ∀ η : ι → Bool,
      weight p η * (resid A p c0 a η * f η)
        = weight p η * (signInd A η * f η) - c0 * (weight p η * f η)
          - ∑ v : ι, a v * (weight p η * (psi p v η * f η)) := by
    intro η
    have hs : ∑ v : ι, a v * (weight p η * (psi p v η * f η))
        = (weight p η * f η) * ∑ v : ι, a v * psi p v η := by
      rw [Finset.mul_sum]
      exact Finset.sum_congr rfl fun v _ => by ring
    rw [hs, resid]
    ring
  unfold expP
  simp only [hterm]
  rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, Finset.sum_comm]
  congr 1
  refine Finset.sum_congr rfl fun v _ => ?_
  rw [← Finset.mul_sum]

/-- **Bessel's inequality** for the orthogonal family `{1} ∪ {ψ_v}` in the space
of real functions on the discrete cube with the `p`-biased inner product. -/
theorem bessel_aux {A : Set (ι → Bool)} {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    (c0 : ℝ) (a : ι → ℝ)
    (hc0 : expP p (fun η => signInd A η) = c0)
    (ha : ∀ v : ι, expP p (fun η => signInd A η * psi p v η) = a v * (p * (1 - p))) :
    c0 ^ 2 + (p * (1 - p)) * ∑ v : ι, (a v) ^ 2 ≤ 1 := by
  set q := p * (1 - p) with hq
  have h1 : expP p (fun η => resid A p c0 a η) = 0 := by
    have h := expP_resid_mul A p c0 a (fun _ => (1 : ℝ))
    simp only [mul_one] at h
    rw [h, hc0, expP_const]
    have hz : ∀ v : ι, expP p (fun η : ι → Bool => psi p v η) = 0 := fun v => expP_psi p v
    simp only [hz, mul_zero, Finset.sum_const_zero]
    ring
  have h2 : ∀ u : ι, expP p (fun η => resid A p c0 a η * psi p u η) = 0 := by
    intro u
    rw [expP_resid_mul A p c0 a (psi p u), ha u, expP_psi p u]
    simp only [expP_psi_mul_psi, mul_ite, mul_zero, ← hq,
      Finset.sum_ite_eq' univ u (fun v => a v * q), Finset.mem_univ, if_true]
    ring
  have h3 : expP p (fun η => resid A p c0 a η * signInd A η)
      = 1 - c0 ^ 2 - q * ∑ v : ι, (a v) ^ 2 := by
    rw [expP_resid_mul A p c0 a (signInd A), expP_signInd_sq p A, hc0]
    have e3 : ∀ v : ι, expP p (fun η : ι → Bool => psi p v η * signInd A η) = a v * q := by
      intro v
      rw [show (fun η : ι → Bool => psi p v η * signInd A η)
        = fun η : ι → Bool => signInd A η * psi p v η from funext fun η => mul_comm _ _]
      exact ha v
    simp only [e3]
    have hs : ∑ v : ι, a v * (a v * q) = q * ∑ v : ι, (a v) ^ 2 := by
      rw [Finset.mul_sum]
      exact Finset.sum_congr rfl fun v _ => by ring
    rw [hs]
    ring
  have hexp : expP p (fun η => resid A p c0 a η * resid A p c0 a η)
      = 1 - c0 ^ 2 - q * ∑ v : ι, (a v) ^ 2 := by
    rw [expP_resid_mul A p c0 a (resid A p c0 a), h1]
    have e1 : expP p (fun η => signInd A η * resid A p c0 a η)
        = 1 - c0 ^ 2 - q * ∑ v : ι, (a v) ^ 2 := by
      rw [show (fun η : ι → Bool => signInd A η * resid A p c0 a η)
        = fun η : ι → Bool => resid A p c0 a η * signInd A η from
          funext fun η => mul_comm _ _]
      exact h3
    have e3 : ∀ v : ι, expP p (fun η : ι → Bool => psi p v η * resid A p c0 a η) = 0 := by
      intro v
      rw [show (fun η : ι → Bool => psi p v η * resid A p c0 a η)
        = fun η : ι → Bool => resid A p c0 a η * psi p v η from funext fun η => mul_comm _ _]
      exact h2 v
    rw [e1]
    simp only [e3, mul_zero, Finset.sum_const_zero]
    ring
  have hnn : 0 ≤ expP p (fun η => resid A p c0 a η * resid A p c0 a η) :=
    expP_nonneg hp0 hp1 fun η => mul_self_nonneg _
  rw [hexp] at hnn
  linarith

/-- **Bessel's inequality for influences.** -/
theorem bessel_influence {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {A : Set (ι → Bool)}
    (hA : IsIncreasing A) :
    (2 * bernProb p A - 1) ^ 2
      + (p * (1 - p)) * ∑ v : ι, (2 * bernProb p (pivotalSet A v)) ^ 2 ≤ 1 :=
  bessel_aux hp0 hp1 _ _ (expP_signInd p A) (fun v => expP_signInd_mul_psi hA p v)

/-- **The `ℓ²` influence bound.**  At every density, the influences of an
increasing event satisfy `p(1-p) ∑_v I_v² ≤ P (1 - P)`.  For a one-site event
this is an equality. -/
theorem sum_sq_influence_le {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {A : Set (ι → Bool)}
    (hA : IsIncreasing A) :
    (p * (1 - p)) * ∑ v : ι, (bernProb p (pivotalSet A v)) ^ 2
      ≤ bernProb p A * (1 - bernProb p A) := by
  have h := bessel_influence hp0 hp1 hA
  have hrw : ∑ v : ι, (2 * bernProb p (pivotalSet A v)) ^ 2
      = 4 * ∑ v : ι, (bernProb p (pivotalSet A v)) ^ 2 := by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun v _ => by ring
  rw [hrw] at h
  nlinarith [h]

/-! ## The square-root law -/

/-- **Square-root law, squared form.**  `(∑_v I_v)² · p(1-p) ≤ |ι| · P (1-P)`. -/
theorem sq_sum_influence_le {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {A : Set (ι → Bool)}
    (hA : IsIncreasing A) :
    (p * (1 - p)) * (∑ v : ι, bernProb p (pivotalSet A v)) ^ 2
      ≤ (Fintype.card ι : ℝ) * (bernProb p A * (1 - bernProb p A)) := by
  have hq : 0 ≤ p * (1 - p) := mul_nonneg hp0 (by linarith)
  have hcs : (∑ v : ι, bernProb p (pivotalSet A v)) ^ 2
      ≤ ((univ : Finset ι).card : ℝ) * ∑ v : ι, (bernProb p (pivotalSet A v)) ^ 2 :=
    sq_sum_le_card_mul_sum_sq
  have hcard : ((univ : Finset ι).card : ℝ) = (Fintype.card ι : ℝ) := by
    rw [Finset.card_univ]
  rw [hcard] at hcs
  have hstep : (p * (1 - p)) * (∑ v : ι, bernProb p (pivotalSet A v)) ^ 2
      ≤ (Fintype.card ι : ℝ) *
        ((p * (1 - p)) * ∑ v : ι, (bernProb p (pivotalSet A v)) ^ 2) := by
    have := mul_le_mul_of_nonneg_left hcs hq
    linarith [this]
  refine hstep.trans (mul_le_mul_of_nonneg_left (sum_sq_influence_le hp0 hp1 hA)
    (Nat.cast_nonneg _))

/-- **The square-root law at density `1/2`.**  `∑_v I_v ≤ sqrt |ι|` for every
increasing event.  Majority on `2m+1` sites shows the order is optimal. -/
theorem sum_influence_le_sqrt_card {A : Set (ι → Bool)} (hA : IsIncreasing A) :
    ∑ v : ι, bernProb (1 / 2 : ℝ) (pivotalSet A v) ≤ Real.sqrt (Fintype.card ι) := by
  have hP0 : 0 ≤ bernProb (1 / 2 : ℝ) A := bernProb_nonneg (by norm_num) (by norm_num) A
  have hP1 : bernProb (1 / 2 : ℝ) A ≤ 1 := by
    have h := bernProb_add_bernProb_compl (ι := ι) (1 / 2 : ℝ) A
    have h2 : 0 ≤ bernProb (1 / 2 : ℝ) (Aᶜ) :=
      bernProb_nonneg (by norm_num) (by norm_num) _
    linarith
  have hkey := sq_sum_influence_le (p := (1 / 2 : ℝ)) (by norm_num) (by norm_num) hA
  norm_num at hkey
  have hsq : (∑ v : ι, bernProb (1 / 2 : ℝ) (pivotalSet A v)) ^ 2
      ≤ (Fintype.card ι : ℝ) := by
    nlinarith [sq_nonneg (2 * bernProb (1 / 2 : ℝ) A - 1),
      Nat.cast_nonneg (α := ℝ) (Fintype.card ι)]
  have hnn : 0 ≤ ∑ v : ι, bernProb (1 / 2 : ℝ) (pivotalSet A v) :=
    Finset.sum_nonneg fun v _ => bernProb_nonneg (by norm_num) (by norm_num) _
  have := Real.sqrt_le_sqrt hsq
  rwa [Real.sqrt_sq hnn] at this

/-- **The slope of the Bernoulli probability polynomial at `p = 1/2`** is at most
`sqrt |ι|` for every increasing event: the density window on which the
probability moves from `ε` to `1 - ε` has width at least `(1 - 2ε) / sqrt |ι|`
around `1/2`. -/
theorem deriv_bernProb_half_le_sqrt_card {A : Set (ι → Bool)} (hA : IsIncreasing A) :
    deriv (fun t : ℝ => bernProb t A) (1 / 2 : ℝ) ≤ Real.sqrt (Fintype.card ι) := by
  rw [deriv_bernProb hA]
  exact sum_influence_le_sqrt_card hA

/-- **A quantitative Russo bound at every density.**  The derivative of the
Bernoulli probability polynomial of an increasing event obeys
`p(1-p) · (P'(p))² ≤ |ι| · P(1-P)`.  This is the square-root law in
differential form; compare `bernProb_variance_sandwich`, which only gives
`p(1-p) · P'(p) ≤ |ι| · P(1-P)`. -/
theorem sq_deriv_bernProb_le {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {A : Set (ι → Bool)}
    (hA : IsIncreasing A) :
    (p * (1 - p)) * (deriv (fun t : ℝ => bernProb t A) p) ^ 2
      ≤ (Fintype.card ι : ℝ) * (bernProb p A * (1 - bernProb p A)) := by
  rw [deriv_bernProb hA]
  exact sq_sum_influence_le hp0 hp1 hA

/-- **The grid instance.**  The total influence of the horizontal crossing event
of the `n × n` grid at density `1/2` is at most `n`. -/
theorem crossing_sum_influence_le (n : ℕ) (hn : 0 < n) :
    ∑ v : Fin n × Fin n, bernProb (1 / 2 : ℝ) (pivotalSet (crossingEvent n hn) v)
      ≤ (n : ℝ) := by
  have h := sum_influence_le_sqrt_card (crossingEvent_isIncreasing n hn)
  have hcard : (Fintype.card (Fin n × Fin n) : ℝ) = (n : ℝ) ^ 2 := by
    simp [Fintype.card_prod]
    ring
  rw [hcard, Real.sqrt_sq (by positivity)] at h
  exact h

end BernoulliThresholdCoupling