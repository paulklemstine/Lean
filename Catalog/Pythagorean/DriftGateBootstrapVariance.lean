import Pythagorean.DriftGateClusterFloor

/-!
# The cluster bootstrap variance identity

`DriftGateClusterFloor.lean` defines `relClusterSD` and *asserts* that it is the relative
standard deviation of the nonparametric cluster bootstrap.  This file proves that
assertion, so the resolution floor is a statement about the actual resampling scheme used
in the run rather than about an ad-hoc dispersion functional.

Setup: `ι` is the (finite, nonempty) set of clusters, `m = |ι|`, and a *resample* is an
index vector `f : Fin n → ι` — draw `n` clusters i.i.d. uniformly with replacement.  All
`m ^ n` resamples are equally likely, so expectations are plain sums divided by `m ^ n`.

* `bootstrap_centred_sum_zero` — the resampled sum of a centred vector has total `0`
  across all resamples.
* `bootstrap_variance_identity` — the exact second-moment identity
  `m · ∑_f (∑_k d (f k))² = n · mⁿ · ∑_i dᵢ²` for any centred `d`.  Proof is by induction
  on the number of draws using the `Fin.consEquiv` decomposition; the cross terms vanish
  because `∑ d = 0`.
* `bootstrap_total_sq_dev` — specialised to `n = m` draws of the raw counts: the sum over
  all `m ^ m` resamples of `(T* − S)²` equals `m ^ m · ∑ (xᵢ − x̄)²`, i.e. the bootstrap
  variance of the resampled total is exactly `∑ (xᵢ − x̄)²`.
* `relClusterSD_eq_bootstrap_rel_sd` — hence `relClusterSD` *is* the relative bootstrap
  standard deviation, and the floor of `DriftGateClusterFloor.lean` applies verbatim to
  the intervals the round actually reported.
-/

namespace Catalog.Pythagorean.DriftGate

open Finset

variable {ι : Type*} [Fintype ι]

/-- Sum, over all resample index vectors of length `n`, of the resampled total of a
centred cluster vector.  It vanishes. -/
theorem bootstrap_centred_sum_zero (d : ι → ℝ) (hd : ∑ i, d i = 0) (n : ℕ) :
    ∑ f : Fin n → ι, (∑ k, d (f k)) = 0 := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [← Equiv.sum_comp (Fin.consEquiv (fun _ : Fin (n + 1) => ι))
        (fun f => ∑ k, d (f k)), Fintype.sum_prod_type]
      have hstep : ∀ a : ι, ∀ f : Fin n → ι,
          (∑ k, d (Fin.consEquiv (fun _ : Fin (n + 1) => ι) (a, f) k)) = d a + ∑ k, d (f k) := by
        intro a f
        rw [Fin.sum_univ_succ]
        simp [Fin.consEquiv]
      calc ∑ a : ι, ∑ f : Fin n → ι,
            (∑ k, d (Fin.consEquiv (fun _ : Fin (n + 1) => ι) (a, f) k))
          = ∑ a : ι, ∑ f : Fin n → ι, (d a + ∑ k, d (f k)) := by
            refine Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun f _ => hstep a f
        _ = ∑ a : ι, ((Fintype.card (Fin n → ι) : ℝ) * d a + 0) := by
            refine Finset.sum_congr rfl fun a _ => ?_
            rw [Finset.sum_add_distrib, ih, Finset.sum_const, nsmul_eq_mul]
            simp
        _ = (Fintype.card (Fin n → ι) : ℝ) * ∑ a : ι, d a := by
            rw [Finset.mul_sum]; simp
        _ = 0 := by rw [hd, mul_zero]

/-- **Cluster bootstrap second-moment identity.**  For a centred cluster vector `d` and
`n` draws with replacement from `m = |ι|` clusters,
`m · ∑_f (∑_k d (f k))² = n · mⁿ · ∑_i dᵢ²`.  Dividing by `m · mⁿ`: the resampled total
has variance `n · (∑ dᵢ²)/m`, the textbook `n · (population variance)`. -/
theorem bootstrap_variance_identity (d : ι → ℝ) (hd : ∑ i, d i = 0) (n : ℕ) :
    (Fintype.card ι : ℝ) * ∑ f : Fin n → ι, (∑ k, d (f k)) ^ 2
      = n * (Fintype.card ι : ℝ) ^ n * ∑ i, d i ^ 2 := by
  induction n with
  | zero => simp
  | succ n ih =>
      have hcard : (Fintype.card (Fin n → ι) : ℝ) = (Fintype.card ι : ℝ) ^ n := by
        simp
      have hstep : ∀ a : ι, ∀ f : Fin n → ι,
          (∑ k, d (Fin.consEquiv (fun _ : Fin (n + 1) => ι) (a, f) k)) = d a + ∑ k, d (f k) := by
        intro a f
        rw [Fin.sum_univ_succ]
        simp [Fin.consEquiv]
      have h1 : ∑ a : ι, ∑ _f : Fin n → ι, d a ^ 2
          = (Fintype.card ι : ℝ) ^ n * ∑ a : ι, d a ^ 2 := by
        simp only [Finset.sum_const, nsmul_eq_mul, Finset.card_univ, ← Finset.mul_sum]
        rw [hcard]
      have h2 : ∑ a : ι, ∑ f : Fin n → ι, 2 * d a * (∑ k, d (f k)) = 0 := by
        simp only [← Finset.mul_sum, bootstrap_centred_sum_zero d hd n, mul_zero,
          Finset.sum_const, smul_zero]
      have h3 : ∑ _a : ι, ∑ f : Fin n → ι, (∑ k, d (f k)) ^ 2
          = (Fintype.card ι : ℝ) * ∑ f : Fin n → ι, (∑ k, d (f k)) ^ 2 := by
        simp only [Finset.sum_const, nsmul_eq_mul, Finset.card_univ]
      have hcongr : ∀ (a : ι) (f : Fin n → ι),
          (∑ k, d (Fin.consEquiv (fun _ : Fin (n + 1) => ι) (a, f) k)) ^ 2
            = d a ^ 2 + 2 * d a * (∑ k, d (f k)) + (∑ k, d (f k)) ^ 2 := by
        intro a f
        rw [hstep a f]; ring
      have hsplit : ∑ f : Fin (n + 1) → ι, (∑ k, d (f k)) ^ 2
          = (Fintype.card ι : ℝ) ^ n * (∑ i, d i ^ 2)
            + (Fintype.card ι : ℝ) * ∑ f : Fin n → ι, (∑ k, d (f k)) ^ 2 := by
        rw [← Equiv.sum_comp (Fin.consEquiv (fun _ : Fin (n + 1) => ι))
          (fun f => (∑ k, d (f k)) ^ 2), Fintype.sum_prod_type]
        rw [Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun f _ => hcongr a f]
        simp only [Finset.sum_add_distrib]
        rw [h1, h2, h3, add_zero]
      rw [hsplit, mul_add, ih]
      push_cast
      ring

/-- **Bootstrap variance of the resampled total.**  Drawing `m = |ι|` clusters with
replacement, the sum over all `m ^ m` resamples of the squared deviation of the resampled
total `T*` from the observed total `S` is exactly `m ^ m · ∑ (xᵢ − x̄)²`. -/
theorem bootstrap_total_sq_dev (x : ι → ℝ) (hm : 0 < Fintype.card ι) :
    ∑ f : Fin (Fintype.card ι) → ι, ((∑ k, x (f k)) - ∑ i, x i) ^ 2
      = (Fintype.card ι : ℝ) ^ (Fintype.card ι)
        * ∑ i, (x i - (∑ i, x i) / (Fintype.card ι)) ^ 2 := by
  set m : ℕ := Fintype.card ι with hmdef
  set S : ℝ := ∑ i, x i with hS
  set d : ι → ℝ := fun i => x i - S / m with hd
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hdzero : ∑ i, d i = 0 := by
    rw [hd, Finset.sum_sub_distrib, Finset.sum_const, nsmul_eq_mul, Finset.card_univ,
      ← hmdef, ← hS]
    field_simp
    ring
  have hshift : ∀ f : Fin m → ι, ((∑ k, x (f k)) - S) = ∑ k, d (f k) := by
    intro f
    have : ∑ k, d (f k) = (∑ k, x (f k)) - (m : ℝ) * (S / m) := by
      rw [hd]
      simp only [Finset.sum_sub_distrib, Finset.sum_const, nsmul_eq_mul, Finset.card_univ,
        Fintype.card_fin]
    rw [this]
    field_simp
  have hid := bootstrap_variance_identity d hdzero m
  rw [Finset.sum_congr rfl (fun f _ => by rw [hshift f])]
  have : (m : ℝ) * ∑ f : Fin m → ι, (∑ k, d (f k)) ^ 2
      = (m : ℝ) * ((m : ℝ) ^ m * ∑ i, d i ^ 2) := by
    rw [hid]; ring
  exact mul_left_cancel₀ (ne_of_gt hmR) this

/-- **`relClusterSD` is the relative bootstrap standard deviation.**  Consequently the
resolution floor `share − 1/m ≤ relClusterSD` of `DriftGateClusterFloor.lean` is a
statement about the very quantity the round's cluster bootstrap estimates. -/
theorem relClusterSD_eq_bootstrap_rel_sd (x : ι → ℝ) (hm : 0 < Fintype.card ι) :
    relClusterSD (Finset.univ : Finset ι) x
      = Real.sqrt ((∑ f : Fin (Fintype.card ι) → ι, ((∑ k, x (f k)) - ∑ i, x i) ^ 2)
          / (Fintype.card ι : ℝ) ^ (Fintype.card ι)) / (∑ i, x i) := by
  have hmR : (0 : ℝ) < (Fintype.card ι : ℝ) := by exact_mod_cast hm
  have hinner : ((Fintype.card ι : ℝ) ^ (Fintype.card ι)
        * ∑ i, (x i - (∑ i, x i) / (Fintype.card ι)) ^ 2)
      / (Fintype.card ι : ℝ) ^ (Fintype.card ι)
      = ∑ i, (x i - (∑ i, x i) / (Fintype.card ι)) ^ 2 := by
    field_simp
    exact Finset.sum_congr rfl fun i _ => by ring
  rw [bootstrap_total_sq_dev x hm, hinner, relClusterSD, Finset.card_univ]

end Catalog.Pythagorean.DriftGate