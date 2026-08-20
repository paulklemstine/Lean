import Probability.TalagrandHypercube

/-!
# Talagrand's inequality for certifiable functionals

The corollary `Talagrand.lipschitz_concentration` uses the Lipschitz hypothesis
only to produce, for each far point `x`, a *witness weight vector* certifying
that `x` is far from `A` in a weighted Hamming metric.  Because the convex
distance dominates *every* admissible weighted Hamming distance
(`Talagrand.dHamming_sq_le_dTsq` holds for an arbitrary `w`), the witness is
allowed to depend on `x`.  This is exactly the extra freedom that makes
Talagrand's inequality strictly stronger than the bounded-differences
(Azuma–Hoeffding) inequality, and it is what the notion of a *certifiable*
functional exploits.

## Main results

* `Talagrand.certifiable_concentration` — let `f` be `1`-Lipschitz for the plain
  Hamming metric.  Suppose that every `x ∈ S` admits a *certificate* `J x`, a set
  of at most `K` coordinates such that *any* point agreeing with `x` on `J x`
  already satisfies `f ≥ m`.  If `f ≤ b` on `A` and `b ≤ m`, then
  `mass A * mass S ≤ exp (-(m - b)² / (4 K))`.
  Note that the deviation is measured on the scale `√K`, the size of a
  certificate, and **not** on the scale `√n`.
* `Talagrand.cube_ones_count_concentration` — the resulting sharpened
  concentration for the (unnormalised) number-of-ones functional on a product of
  arbitrary independent coins: the tail scale is `√m` rather than `√n`, so the
  bound is nontrivial for level sets of size `m = o(n)` where the weighted
  Lipschitz form gives nothing.
-/

namespace Talagrand

open Finset Real

variable {α : Type*} [Fintype α] [DecidableEq α]

section Certifiable

variable {n : ℕ}

/-- The weight vector attached to a certificate `J`: mass `1/√|J|` spread over the
coordinates of `J`.  It has Euclidean norm `1` when `J` is nonempty (and `0`
otherwise), so it is always admissible in `Talagrand.dHamming_sq_le_dTsq`. -/
noncomputable def certWeight (J : Finset (Fin n)) : Fin n → ℝ :=
  fun i => if i ∈ J then 1 / Real.sqrt (J.card) else 0

lemma certWeight_nonneg (J : Finset (Fin n)) (i : Fin n) : 0 ≤ certWeight J i := by
  unfold certWeight
  split
  · positivity
  · exact le_rfl

lemma certWeight_sq_le_one (J : Finset (Fin n)) : ∑ i, (certWeight J i) ^ 2 ≤ 1 := by
  classical
  rcases Nat.eq_zero_or_pos J.card with hc | hc
  · have hJ : J = ∅ := Finset.card_eq_zero.mp hc
    simp [certWeight, hJ]
  · have hcR : (0 : ℝ) < J.card := by exact_mod_cast hc
    have hsq : (1 / Real.sqrt (J.card)) ^ 2 = 1 / (J.card : ℝ) := by
      rw [div_pow, one_pow, Real.sq_sqrt hcR.le]
    have hstep : ∀ i : Fin n, (certWeight J i) ^ 2
        = if i ∈ J then (1 / (J.card : ℝ)) else 0 := by
      intro i
      unfold certWeight
      split
      · exact hsq
      · norm_num
    have hsum : ∑ i, (certWeight J i) ^ 2 = 1 := by
      calc ∑ i, (certWeight J i) ^ 2
          = ∑ i : Fin n, (if i ∈ J then (1 / (J.card : ℝ)) else 0) :=
            Finset.sum_congr rfl fun i _ => hstep i
        _ = ∑ _i ∈ J, (1 / (J.card : ℝ)) := by
            rw [Finset.sum_ite_mem, Finset.univ_inter]
        _ = 1 := by
            rw [Finset.sum_const, nsmul_eq_mul]
            field_simp
    exact le_of_eq hsum

omit [Fintype α] in
/-- The `certWeight J`-weighted Hamming contribution of a point `y`, computed on the
certificate. -/
lemma certWeight_sum (J : Finset (Fin n)) (x y : Fin n → α) :
    ∑ i, certWeight J i * hamm (x i) (y i)
      = (1 / Real.sqrt (J.card)) * ∑ i ∈ J, hamm (x i) (y i) := by
  classical
  have hstep : ∀ i : Fin n, certWeight J i * hamm (x i) (y i)
      = if i ∈ J then (1 / Real.sqrt (J.card)) * hamm (x i) (y i) else 0 := by
    intro i
    unfold certWeight
    split
    · rfl
    · rw [zero_mul]
  calc ∑ i, certWeight J i * hamm (x i) (y i)
      = ∑ i : Fin n, (if i ∈ J then (1 / Real.sqrt (J.card)) * hamm (x i) (y i) else 0) :=
        Finset.sum_congr rfl fun i _ => hstep i
    _ = ∑ i ∈ J, (1 / Real.sqrt (J.card)) * hamm (x i) (y i) := by
        rw [Finset.sum_ite_mem, Finset.univ_inter]
    _ = (1 / Real.sqrt (J.card)) * ∑ i ∈ J, hamm (x i) (y i) := by
        rw [Finset.mul_sum]

omit [Fintype α] in
/-- **The certificate bound.**  If `f` is `1`-Lipschitz for the plain Hamming metric
and every point agreeing with `x` on `J` has `f ≥ m`, then any point `y` with
`f y ≤ b` differs from `x` in at least `m - b` coordinates *of the certificate*. -/
lemma card_diff_ge_of_cert {f : (Fin n → α) → ℝ}
    (hLip : ∀ z y : Fin n → α, f z ≤ f y + ∑ i, hamm (z i) (y i))
    {J : Finset (Fin n)} {x : Fin n → α} {m b : ℝ}
    (hcert : ∀ y : Fin n → α, (∀ i ∈ J, y i = x i) → m ≤ f y)
    {y : Fin n → α} (hy : f y ≤ b) :
    m - b ≤ ∑ i ∈ J, hamm (x i) (y i) := by
  classical
  set z : Fin n → α := fun i => if i ∈ J then x i else y i with hz
  have hzJ : ∀ i ∈ J, z i = x i := by
    intro i hi; simp [hz, hi]
  have hmz : m ≤ f z := hcert z hzJ
  have hsum : ∑ i, hamm (z i) (y i) = ∑ i ∈ J, hamm (x i) (y i) := by
    have hstep : ∀ i : Fin n, hamm (z i) (y i)
        = if i ∈ J then hamm (x i) (y i) else 0 := by
      intro i
      by_cases hi : i ∈ J <;> simp [hz, hi]
    calc ∑ i, hamm (z i) (y i)
        = ∑ i : Fin n, (if i ∈ J then hamm (x i) (y i) else 0) :=
          Finset.sum_congr rfl fun i _ => hstep i
      _ = ∑ i ∈ J, hamm (x i) (y i) := by rw [Finset.sum_ite_mem, Finset.univ_inter]
  have := hLip z y
  rw [hsum] at this
  linarith

omit [Fintype α] in
/-- The certificate produces a lower bound for the convex distance on the scale of
the *certificate size* `K`, not of the dimension. -/
lemma dTsq_ge_of_cert {f : (Fin n → α) → ℝ}
    (hLip : ∀ z y : Fin n → α, f z ≤ f y + ∑ i, hamm (z i) (y i))
    {A : Finset (Fin n → α)} (hA : A.Nonempty) {b m K : ℝ} (hK : 0 < K) (hbm : b ≤ m)
    (hAle : ∀ y ∈ A, f y ≤ b) {x : Fin n → α} {J : Finset (Fin n)}
    (hJK : ((J.card : ℝ)) ≤ K)
    (hcert : ∀ y : Fin n → α, (∀ i ∈ J, y i = x i) → m ≤ f y) :
    (m - b) ^ 2 / K ≤ dTsq A x := by
  classical
  have hmb : 0 ≤ m - b := by linarith
  have hKs : 0 < Real.sqrt K := Real.sqrt_pos.mpr hK
  -- the weighted Hamming distance from `x` to `A` is at least `(m - b)/√K`
  have hlow : (m - b) / Real.sqrt K ≤ dHamming (certWeight J) A x := by
    refine le_dHamming hA fun y hy => ?_
    have hD : m - b ≤ ∑ i ∈ J, hamm (x i) (y i) :=
      card_diff_ge_of_cert hLip hcert (hAle y hy)
    rw [certWeight_sum]
    rcases Nat.eq_zero_or_pos J.card with hc | hc
    · -- an empty certificate forces `m = b`, and both sides vanish
      have hJ : J = ∅ := Finset.card_eq_zero.mp hc
      have : m - b ≤ 0 := by simpa [hJ] using hD
      have hmb0 : m - b = 0 := le_antisymm this hmb
      simp [hJ, hmb0]
    · have hcR : (0 : ℝ) < J.card := by exact_mod_cast hc
      have hcs : 0 < Real.sqrt (J.card) := Real.sqrt_pos.mpr hcR
      have hle : Real.sqrt (J.card) ≤ Real.sqrt K := Real.sqrt_le_sqrt hJK
      have h1 : (m - b) / Real.sqrt K ≤ (m - b) / Real.sqrt (J.card) :=
        div_le_div_of_nonneg_left hmb hcs hle
      have h2 : (m - b) / Real.sqrt (J.card)
          ≤ (1 / Real.sqrt (J.card)) * ∑ i ∈ J, hamm (x i) (y i) := by
        rw [one_div, inv_mul_eq_div, div_le_div_iff_of_pos_right hcs]
        exact hD
      linarith
  -- and the convex distance dominates its square
  have hnn : 0 ≤ (m - b) / Real.sqrt K := div_nonneg hmb hKs.le
  have hsq : ((m - b) / Real.sqrt K) ^ 2 ≤ (dHamming (certWeight J) A x) ^ 2 := by
    nlinarith
  have hdt : (dHamming (certWeight J) A x) ^ 2 ≤ dTsq A x :=
    dHamming_sq_le_dTsq (certWeight_nonneg J) (certWeight_sq_le_one J) hA x
  have hval : ((m - b) / Real.sqrt K) ^ 2 = (m - b) ^ 2 / K := by
    rw [div_pow, Real.sq_sqrt hK.le]
  linarith [hval ▸ hsq]

/-- **Talagrand's inequality for certifiable functionals.**  Let `f` be `1`-Lipschitz
for the plain (unweighted) Hamming metric, let `f ≤ b` on `A`, and suppose every
point `x` of `S` carries a *certificate*: a set `J` of at most `K` coordinates such
that every point agreeing with `x` on `J` satisfies `f ≥ m`.  Then

`mass A * mass S ≤ exp (-(m - b)² / (4 K))`.

The certificate is allowed to depend on `x`, and the deviation `m - b` is measured
on the scale `√K` of the certificate size — this is the gain over the
bounded-differences inequality, whose scale is `√n`. -/
theorem certifiable_concentration {p : Fin n → α → ℝ} (hp0 : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a, p i a = 1) {f : (Fin n → α) → ℝ}
    (hLip : ∀ z y : Fin n → α, f z ≤ f y + ∑ i, hamm (z i) (y i))
    (A S : Finset (Fin n → α)) (hA : A.Nonempty) {b m K : ℝ} (hK : 0 < K) (hbm : b ≤ m)
    (hAle : ∀ y ∈ A, f y ≤ b)
    (hcert : ∀ x ∈ S, ∃ J : Finset (Fin n), ((J.card : ℝ)) ≤ K ∧
      ∀ y : Fin n → α, (∀ i ∈ J, y i = x i) → m ≤ f y) :
    mass p A * mass p S ≤ Real.exp (-((m - b) ^ 2 / (4 * K))) := by
  have hmain := mass_mul_mass_le_exp hp0 hp1 A S
    (t := (m - b) ^ 2 / K) (fun x hx => by
      obtain ⟨J, hJK, hJ⟩ := hcert x hx
      exact dTsq_ge_of_cert hLip hA hK hbm hAle hJK hJ)
  have hrw : (m - b) ^ 2 / K / 4 = (m - b) ^ 2 / (4 * K) := by
    field_simp
  rwa [hrw] at hmain

end Certifiable

/-! ### Application: the number of ones on a product of arbitrary independent coins -/

/-- The (unnormalised) number of ones of a point of the discrete cube. -/
noncomputable def onesCount {n : ℕ} (x : Fin n → Bool) : ℝ :=
  ∑ i, (if x i then (1 : ℝ) else 0)

lemma onesCount_nonneg {n : ℕ} (x : Fin n → Bool) : 0 ≤ onesCount x :=
  Finset.sum_nonneg fun i _ => by positivity

/-- The number-of-ones functional is `1`-Lipschitz for the plain Hamming metric. -/
lemma onesCount_lipschitz {n : ℕ} (z y : Fin n → Bool) :
    onesCount z ≤ onesCount y + ∑ i, hamm (z i) (y i) := by
  have hstep : ∀ i : Fin n, (if z i then (1 : ℝ) else 0)
      ≤ (if y i then (1 : ℝ) else 0) + hamm (z i) (y i) := by
    intro i
    by_cases h : z i = y i
    · rw [h]; simp [hamm]
    · have hh : hamm (z i) (y i) = 1 := by simp [hamm, h]
      rw [hh]
      by_cases hz : z i = true <;> by_cases hy : y i = true <;> simp [hz, hy]
  have := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => hstep i)
  simpa [onesCount, Finset.sum_add_distrib] using this

/-- The number of ones is a *certifiable* functional: any `⌈m⌉` of the coordinates
carrying a one certify that the value is at least `m`. -/
lemma onesCount_cert {n : ℕ} {m : ℝ} {x : Fin n → Bool} (hx : m ≤ onesCount x) :
    ∃ J : Finset (Fin n), ((J.card : ℝ)) ≤ (⌈m⌉₊ : ℝ) ∧
      ∀ y : Fin n → Bool, (∀ i ∈ J, y i = x i) → m ≤ onesCount y := by
  classical
  set T : Finset (Fin n) := Finset.univ.filter (fun i => x i = true) with hT
  have hcard : onesCount x = (T.card : ℝ) := by
    simp [onesCount, hT, Finset.sum_boole]
  have hmT : (⌈m⌉₊ : ℕ) ≤ T.card := by
    apply Nat.ceil_le.mpr
    rw [← hcard]; exact hx
  obtain ⟨J, hJT, hJcard⟩ := Finset.exists_subset_card_eq hmT
  refine ⟨J, by rw [hJcard], fun y hy => ?_⟩
  have hone : ∀ i ∈ J, (if y i then (1 : ℝ) else 0) = 1 := by
    intro i hi
    have hxi : x i = true := by
      have := hJT hi
      simpa [hT] using this
    rw [hy i hi, hxi]
    norm_num
  have hge : (J.card : ℝ) ≤ onesCount y := by
    calc (J.card : ℝ) = ∑ i ∈ J, (if y i then (1 : ℝ) else 0) := by
          rw [Finset.sum_congr rfl hone]; simp
      _ ≤ ∑ i, (if y i then (1 : ℝ) else 0) := by
          refine Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ J) fun i _ _ => ?_
          positivity
      _ = onesCount y := rfl
  have : m ≤ (J.card : ℝ) := by
    rw [hJcard]; exact Nat.le_ceil m
  linarith

/-- **Sharpened concentration for the number of ones**, for a product of arbitrary
independent coins.  The tail scale is `√⌈m⌉`, the size of a certificate, rather
than `√n`: the bound is informative for level sets with `m = o(n)`, where the
weighted-Lipschitz form `Talagrand.lipschitz_concentration` (with the uniform
weight `1/√n`) degenerates. -/
theorem cube_ones_count_concentration {n : ℕ} {p : Fin n → Bool → ℝ}
    (hp0 : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (A S : Finset (Fin n → Bool)) (hA : A.Nonempty) {b m : ℝ} (hm : 0 < m) (hbm : b ≤ m)
    (hAle : ∀ y ∈ A, onesCount y ≤ b) (hSge : ∀ x ∈ S, m ≤ onesCount x) :
    mass p A * mass p S ≤ Real.exp (-((m - b) ^ 2 / (4 * (⌈m⌉₊ : ℝ)))) := by
  have hK : (0 : ℝ) < (⌈m⌉₊ : ℝ) := by
    have : 0 < ⌈m⌉₊ := Nat.ceil_pos.mpr hm
    exact_mod_cast this
  exact certifiable_concentration hp0 hp1 onesCount_lipschitz A S hA hK hbm hAle
    (fun x hx => onesCount_cert (hSge x hx))

/-- The same statement for independent coins with arbitrary coordinate-dependent
biases `θ i ∈ [0, 1]`. -/
theorem biased_cube_ones_count_concentration {n : ℕ} {θ : Fin n → ℝ}
    (h0 : ∀ i, 0 ≤ θ i) (h1 : ∀ i, θ i ≤ 1)
    (A S : Finset (Fin n → Bool)) (hA : A.Nonempty) {b m : ℝ} (hm : 0 < m) (hbm : b ≤ m)
    (hAle : ∀ y ∈ A, onesCount y ≤ b) (hSge : ∀ x ∈ S, m ≤ onesCount x) :
    mass (biased θ) A * mass (biased θ) S
      ≤ Real.exp (-((m - b) ^ 2 / (4 * (⌈m⌉₊ : ℝ)))) :=
  cube_ones_count_concentration (biased_nonneg h0 h1) (biased_sum θ) A S hA hm hbm hAle hSge

end Talagrand