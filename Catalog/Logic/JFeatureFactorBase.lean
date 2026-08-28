/-
# The factor-base deficit law: `cov = -Σ_{q ∈ F} 4/q²`

`Logic.JFeatureCRTAdditivity` proved covariance additivity across *two*
Chinese-remainder coordinates and evaluated the adjacent covariance of the
factor-base count for a two-element factor base.  This file closes the
pre-registered direction D1 in full generality.

* `cov_sum_pi` : **covariance additivity across an arbitrary finite family of
  independent coordinates.**  For statistics of the form `v ↦ Σ_i f_i (v i)` on
  a product space, the empirical covariance is `Σ_i cov (f_i) (g_i)`: all
  `n(n-1)` cross terms vanish identically.  Proved by induction on the number of
  coordinates, splitting off one factor at a time with `cov_split_of_equiv`.
* `cov_fbCountPi` : applied to the sieve polynomial `y_v = (s+v)² - N` over a
  factor base of odd primes `q_0, …, q_{n-1}` with generic square targets, the
  counts of factor-base primes dividing `y_v` and `y_{v+1}` have covariance
  exactly `-Σ_i 4/q_i²`.  Every prime contributes its own strictly negative
  deficit and nothing cancels.
* `factorBase_deficit_le_two` : for a factor base of **distinct** odd primes the
  accumulated deficit is bounded by `2`, uniformly in the size of the base — the
  Mertens-type tail estimate.  So the adjacent dependency is a genuine `O(1)`
  effect, dominated by the head of the factor base, and it neither diverges nor
  washes out as the base grows.

Together with `Logic.JFeatureMarginalBlindness` this is the quantitative content
of the paper-248 routing decision: the marginal-on-`j` sweep is provably blind to
this carrier, while the pair statistic sees an effect of exactly known size.
-/
import Logic.JFeatureCRTAdditivity

namespace Logic.JFeature

open Finset Logic.PhaseRoute

/-! ## Covariance additivity over an arbitrary family of coordinates -/

section PiIndependence

/-- **Covariance additivity across independent coordinates, `n`-fold version.**
On a product space `Π i, A i`, statistics that are sums of functions of the
separate coordinates have covariance equal to the sum of the coordinatewise
covariances: every cross term vanishes. -/
theorem cov_sum_pi : ∀ {n : ℕ} {A : Fin n → Type} [∀ i, Fintype (A i)]
    [∀ i, Nonempty (A i)] (f g : ∀ i, A i → ℝ),
    cov (fun v : (∀ i, A i) => ∑ i, f i (v i)) (fun v : (∀ i, A i) => ∑ i, g i (v i))
      = ∑ i, cov (f i) (g i) := by
  intro n
  induction n with
  | zero =>
      intro A _ _ f g
      simp [cov, avg]
  | succ m ih =>
      intro A _ _ f g
      set e : (∀ i : Fin (m + 1), A i) ≃ A 0 × (∀ i : Fin m, A i.succ) :=
        (Fin.consEquiv A).symm
      have hfst : ∀ v : (∀ i : Fin (m + 1), A i), (e v).1 = v 0 := fun _ => rfl
      have hsnd : ∀ (v : (∀ i : Fin (m + 1), A i)) (i : Fin m), (e v).2 i = v i.succ :=
        fun _ _ => rfl
      have hrw : ∀ h : (∀ i : Fin (m + 1), A i) → ℝ, ∀ hf : ∀ i, A i → ℝ,
          h = (fun v => ∑ i, hf i (v i)) →
          h = fun v => hf 0 ((e v).1)
            + (fun w : (∀ i : Fin m, A i.succ) => ∑ i, hf i.succ (w i)) ((e v).2) := by
        intro h hf hh
        funext v
        rw [hh]
        simp only [hfst, hsnd]
        exact Fin.sum_univ_succ (fun i => hf i (v i))
      rw [hrw _ f rfl, hrw _ g rfl,
        cov_split_of_equiv e (f 0) (g 0)
          (fun w : (∀ i : Fin m, A i.succ) => ∑ i, f i.succ (w i))
          (fun w : (∀ i : Fin m, A i.succ) => ∑ i, g i.succ (w i)),
        ih (fun i => f i.succ) (fun i => g i.succ)]
      exact (Fin.sum_univ_succ (fun i => cov (f i) (g i))).symm

end PiIndependence

/-! ## The factor-base count over an arbitrary base -/

section FactorBasePi

variable {n : ℕ} {q : Fin n → ℕ} [∀ i, Fact (Nat.Prime (q i))]

/-- The number of primes of the factor base `q_0, …, q_{n-1}` dividing `y_v`,
as a statistic on the product of the local position spaces.  Chinese remainder
identifies this product with `ZMod (∏ q_i)`. -/
noncomputable def fbCountPi (s N : ∀ i, ZMod (q i)) (v : ∀ i, ZMod (q i)) : ℝ :=
  ∑ i, hitInd (s i) (N i) (v i)

lemma fbCountPi_shift (s N v : ∀ i, ZMod (q i)) :
    fbCountPi s N (v + 1) = ∑ i, hitIndShift (s i) (N i) (v i) := by
  simp [fbCountPi, hitIndShift]

/-- **Covariance additivity for the factor-base count.** -/
theorem cov_fbCountPi_split (s N : ∀ i, ZMod (q i)) :
    cov (fbCountPi s N) (fun v => fbCountPi s N (v + 1))
      = ∑ i, cov (hitInd (s i) (N i)) (hitIndShift (s i) (N i)) := by
  have h1 : (fun v : (∀ i, ZMod (q i)) => fbCountPi s N (v + 1))
      = fun v => ∑ i, hitIndShift (s i) (N i) (v i) := by
    funext v; exact fbCountPi_shift s N v
  have h2 : (fbCountPi s N : (∀ i, ZMod (q i)) → ℝ)
      = fun v => ∑ i, hitInd (s i) (N i) (v i) := rfl
  rw [h1, h2]
  exact cov_sum_pi (fun i => hitInd (s i) (N i)) (fun i => hitIndShift (s i) (N i))

/-- **The factor-base deficit law.**  For a factor base of odd primes and
generic nonzero square targets, the counts of factor-base primes dividing the
sieve polynomial at consecutive positions have covariance exactly
`-Σ_i 4/q_i²`.  The per-prime deficits accumulate additively; none cancels. -/
theorem cov_fbCountPi (s r : ∀ i, ZMod (q i)) (hq : ∀ i, q i ≠ 2)
    (hr : ∀ i, r i ≠ 0) (hN : ∀ i, 4 * r i ^ 2 ≠ 1) :
    cov (fbCountPi s (fun i => r i ^ 2)) (fun v => fbCountPi s (fun i => r i ^ 2) (v + 1))
      = -∑ i, 4 / (q i : ℝ) ^ 2 := by
  rw [cov_fbCountPi_split, ← Finset.sum_neg_distrib]
  exact Finset.sum_congr rfl fun i _ => cov_adjacent_neg (s i) (hq i) (r i) (hr i) (hN i)

/-- The accumulated deficit is strictly negative as soon as the factor base is
nonempty. -/
theorem cov_fbCountPi_neg (hn : 0 < n) (s r : ∀ i, ZMod (q i)) (hq : ∀ i, q i ≠ 2)
    (hr : ∀ i, r i ≠ 0) (hN : ∀ i, 4 * r i ^ 2 ≠ 1) :
    cov (fbCountPi s (fun i => r i ^ 2)) (fun v => fbCountPi s (fun i => r i ^ 2) (v + 1)) < 0 := by
  rw [cov_fbCountPi s r hq hr hN, neg_lt, neg_zero]
  have hpos : ∀ i : Fin n, (0 : ℝ) < 4 / (q i : ℝ) ^ 2 := by
    intro i
    have : 0 < q i := (Fact.out : Nat.Prime (q i)).pos
    have : (0 : ℝ) < (q i : ℝ) := by exact_mod_cast this
    positivity
  have hne : (univ : Finset (Fin n)).Nonempty := by
    rw [Finset.univ_nonempty_iff]
    exact Fin.pos_iff_nonempty.1 hn
  exact Finset.sum_pos (fun i _ => hpos i) hne

end FactorBasePi

/-! ## The Mertens-type tail bound: the deficit is `O(1)` -/

section TailBound

/-- Telescoping estimate `Σ_{m=3}^{M-1} 4/m² ≤ 2 - 4/(M-1)`. -/
lemma sum_four_div_sq_Ico (M : ℕ) (hM : 3 ≤ M) :
    ∑ m ∈ Finset.Ico 3 M, (4 : ℝ) / (m : ℝ) ^ 2 ≤ 2 - 4 / ((M : ℝ) - 1) := by
  induction M, hM using Nat.le_induction with
  | base => norm_num
  | succ M hM ih =>
      rw [Finset.sum_Ico_succ_top (by omega)]
      have hM3 : (3 : ℝ) ≤ (M : ℝ) := by exact_mod_cast hM
      have h1 : (0 : ℝ) < (M : ℝ) - 1 := by linarith
      have h2 : (0 : ℝ) < (M : ℝ) := by linarith
      have hid : (4 : ℝ) / ((M : ℝ) - 1) - 4 / (M : ℝ) = 4 / (((M : ℝ) - 1) * (M : ℝ)) := by
        rw [div_sub_div _ _ h1.ne' h2.ne']
        congr 1
        ring
      have hstep : (4 : ℝ) / (M : ℝ) ^ 2 ≤ 4 / ((M : ℝ) - 1) - 4 / (M : ℝ) := by
        rw [hid, div_le_div_iff₀ (by positivity) (by positivity)]
        nlinarith
      have hcast : ((M + 1 : ℕ) : ℝ) - 1 = (M : ℝ) := by push_cast; ring
      calc ∑ m ∈ Finset.Ico 3 M, (4 : ℝ) / (m : ℝ) ^ 2 + 4 / (M : ℝ) ^ 2
          ≤ (2 - 4 / ((M : ℝ) - 1)) + (4 / ((M : ℝ) - 1) - 4 / (M : ℝ)) := add_le_add ih hstep
        _ = 2 - 4 / (M : ℝ) := by ring
        _ = 2 - 4 / (((M + 1 : ℕ) : ℝ) - 1) := by rw [hcast]

/-- **The accumulated deficit is uniformly bounded.**  For any factor base of
*distinct* odd primes the total adjacent deficit `Σ_i 4/q_i²` is at most `2`,
no matter how large the base is.  Hence the consecutive-position dependency of
the smoothness indicator is an `O(1)` effect concentrated on the smallest
primes, rather than something that grows with, or vanishes into, the size of the
factor base. -/
theorem factorBase_deficit_le_two {n : ℕ} (q : Fin n → ℕ) [∀ i, Fact (Nat.Prime (q i))]
    (hq : ∀ i, q i ≠ 2) (hinj : Function.Injective q) :
    ∑ i, (4 : ℝ) / (q i : ℝ) ^ 2 ≤ 2 := by
  classical
  set M : ℕ := (univ.sup q) + 3 with hMdef
  have hqge : ∀ i : Fin n, 3 ≤ q i := by
    intro i
    have hp : Nat.Prime (q i) := Fact.out
    have h2 := hp.two_le
    have hne := hq i
    omega
  have hsub : (univ.image q) ⊆ Finset.Ico 3 M := by
    intro m hm
    rw [Finset.mem_image] at hm
    obtain ⟨i, _, rfl⟩ := hm
    rw [Finset.mem_Ico]
    refine ⟨hqge i, ?_⟩
    have : q i ≤ univ.sup q := Finset.le_sup (Finset.mem_univ i)
    omega
  have himg : ∑ i, (4 : ℝ) / (q i : ℝ) ^ 2
      = ∑ m ∈ univ.image q, (4 : ℝ) / (m : ℝ) ^ 2 := by
    rw [Finset.sum_image (fun a _ b _ h => hinj h)]
  have hle : ∑ m ∈ univ.image q, (4 : ℝ) / (m : ℝ) ^ 2
      ≤ ∑ m ∈ Finset.Ico 3 M, (4 : ℝ) / (m : ℝ) ^ 2 := by
    refine Finset.sum_le_sum_of_subset_of_nonneg hsub ?_
    intro m _ _
    positivity
  have hM3 : 3 ≤ M := by omega
  have hbound := sum_four_div_sq_Ico M hM3
  have hMR : (3 : ℝ) ≤ (M : ℝ) := by exact_mod_cast hM3
  have hpos : (0 : ℝ) < (M : ℝ) - 1 := by linarith
  have : (0 : ℝ) < 4 / ((M : ℝ) - 1) := by positivity
  rw [himg]
  linarith

end TailBound

end Logic.JFeature