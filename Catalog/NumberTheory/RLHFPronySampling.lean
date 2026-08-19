import NumberTheory.RLHFSpectralRigidity

/-!
# Finite-sample spectral rigidity: how many temperatures does a reward audit need?

`RLHF.spectral_rigidity` recovers the reward spectrum of an RLHF problem from the value of
the partition function at *every* positive temperature.  This file makes the statement
finite, in both directions, settling the two-atom case of the "Prony count" conjecture
recorded in `FUTURE_DIRECTIONS.md`.

* `RLHF.exp_sample_uniqueness` — **known levels, `n` samples suffice.**  If the candidate
  reward levels `v₀, …, v_{n-1}` are known and distinct, then the masses carried by them are
  determined by the partition function at the `n` arithmetically spaced inverse temperatures
  `t₀, t₀ + τ, …, t₀ + (n−1)τ`.  The engine is a *generalized Vandermonde* determinant: on an
  arithmetic grid of temperatures the exponential-sum system becomes an honest Vandermonde
  system in the variables `e^{v_j τ}`, which are distinct because `exp` is injective.
* `RLHF.spectral_rigidity_sampled` — the RLHF form of the same statement: two RLHF problems
  whose reward values lie in a common known finite list and whose partition functions agree
  at `n` equally spaced inverse temperatures have identical reward spectra.
* `RLHF.prony_three_samples_insufficient` — **unknown levels: three temperatures are not
  enough.**  Two explicit two-atom RLHF problems on `Bool`, with pairwise distinct reward
  levels, whose partition functions agree at the three inverse temperatures `t = 0, 1, 2`,
  and whose reward spectra differ.  The construction is a moment coincidence: the two-point
  distributions `{1, 3}` with masses `(1/2, 1/2)` and `{3/2, 4}` with masses `(4/5, 1/5)`
  have the same mean `2` and the same second moment `5`, and taking logarithms of the
  support turns those two moment equations into agreement of the partition functions at
  `t = 1` and `t = 2` (agreement at `t = 0` being normalization).

Together: the sampling count is governed by whether the reward *levels* are known.  With
known levels `n` measurements are enough; with unknown levels, `2n − 1 = 3` measurements are
provably not enough for `n = 2` atoms.
-/

namespace RLHF

open Finset

/-! ## 1. Known levels: an arithmetic grid of `n` temperatures suffices -/

/-- **Prony sampling / generalized Vandermonde uniqueness.**  Two mass vectors on the same
`n` distinct known levels that produce the same exponential sum at `n` arithmetically spaced
sample points are equal. -/
theorem exp_sample_uniqueness {n : ℕ} {v : Fin n → ℝ} (hv : Function.Injective v)
    {t₀ tau : ℝ} (htau : tau ≠ 0) {a b : Fin n → ℝ}
    (h : ∀ i : Fin n, ∑ j, a j * Real.exp (v j * (t₀ + (i : ℕ) * tau))
      = ∑ j, b j * Real.exp (v j * (t₀ + (i : ℕ) * tau))) :
    a = b := by
  classical
  set x : Fin n → ℝ := fun j => Real.exp (v j * tau) with hxdef
  have hxinj : Function.Injective x := by
    intro j k hjk
    have h1 : v j * tau = v k * tau := Real.exp_eq_exp.mp hjk
    exact hv (mul_right_cancel₀ htau h1)
  have hdet : (Matrix.vandermonde x).det ≠ 0 := by
    rw [Matrix.det_vandermonde]
    refine Finset.prod_ne_zero_iff.mpr (fun i _ => Finset.prod_ne_zero_iff.mpr (fun j hj => ?_))
    have hij : i ≠ j := ne_of_lt (Finset.mem_Ioi.mp hj)
    exact sub_ne_zero.mpr (fun hc => hij (hxinj hc).symm)
  set c : Fin n → ℝ := fun j => (a j - b j) * Real.exp (v j * t₀) with hcdef
  have hmul : Matrix.mulVec (Matrix.transpose (Matrix.vandermonde x)) c = 0 := by
    funext i
    have hi := h i
    have hterm : ∀ j : Fin n, x j ^ (i : ℕ) * c j
        = a j * Real.exp (v j * (t₀ + (i : ℕ) * tau))
          - b j * Real.exp (v j * (t₀ + (i : ℕ) * tau)) := by
      intro j
      have hexp : Real.exp (v j * tau) ^ (i : ℕ) * Real.exp (v j * t₀)
          = Real.exp (v j * (t₀ + (i : ℕ) * tau)) := by
        rw [← Real.exp_nat_mul, ← Real.exp_add]
        congr 1
        ring
      simp only [hxdef, hcdef]
      calc Real.exp (v j * tau) ^ (i : ℕ) * ((a j - b j) * Real.exp (v j * t₀))
          = (a j - b j) * (Real.exp (v j * tau) ^ (i : ℕ) * Real.exp (v j * t₀)) := by ring
        _ = (a j - b j) * Real.exp (v j * (t₀ + (i : ℕ) * tau)) := by rw [hexp]
        _ = a j * Real.exp (v j * (t₀ + (i : ℕ) * tau))
              - b j * Real.exp (v j * (t₀ + (i : ℕ) * tau)) := by ring
    simp only [Matrix.mulVec, Matrix.transpose_apply, Matrix.vandermonde_apply, dotProduct,
      Pi.zero_apply]
    rw [Finset.sum_congr rfl (fun j _ => hterm j), Finset.sum_sub_distrib, hi, sub_self]
  have hc0 : c = 0 :=
    Matrix.eq_zero_of_mulVec_eq_zero (M := Matrix.transpose (Matrix.vandermonde x))
      (by rwa [Matrix.det_transpose]) hmul
  funext j
  have hj := congrFun hc0 j
  rw [hcdef] at hj
  simp only [Pi.zero_apply] at hj
  have hexp : Real.exp (v j * t₀) ≠ 0 := (Real.exp_pos _).ne'
  have : a j - b j = 0 := by
    rcases mul_eq_zero.mp hj with h1 | h1
    · exact h1
    · exact absurd h1 hexp
  linarith

/-- **Finite-sample spectral rigidity.**  If the reward values of two RLHF problems are known
to lie in a common list of `n` distinct candidate levels, then agreement of the two partition
functions at the `n` inverse temperatures `t₀ + i·τ` already forces the two reward spectra to
coincide — a finite reward audit. -/
theorem spectral_rigidity_sampled {Ω₁ Ω₂ : Type*} [Fintype Ω₁] [Fintype Ω₂]
    {r₁ p₁ : Ω₁ → ℝ} {r₂ p₂ : Ω₂ → ℝ} {n : ℕ} {v : Fin n → ℝ} (hv : Function.Injective v)
    (h₁ : image r₁ univ ⊆ image v univ) (h₂ : image r₂ univ ⊆ image v univ)
    {t₀ tau : ℝ} (htau : tau ≠ 0)
    (h : ∀ i : Fin n, ∑ y, p₁ y * Real.exp (r₁ y * (t₀ + (i : ℕ) * tau))
      = ∑ y, p₂ y * Real.exp (r₂ y * (t₀ + (i : ℕ) * tau))) :
    ∀ w : ℝ, rewardMass r₁ p₁ w = rewardMass r₂ p₂ w := by
  classical
  have hre₁ : ∀ i : Fin n, ∑ y, p₁ y * Real.exp (r₁ y * (t₀ + (i : ℕ) * tau))
      = ∑ j, rewardMass r₁ p₁ (v j) * Real.exp (v j * (t₀ + (i : ℕ) * tau)) := by
    intro i
    rw [sum_exp_eq_rewardMass_sum h₁ (t₀ + (i : ℕ) * tau),
      Finset.sum_image (fun j _ k _ hjk => hv hjk)]
  have hre₂ : ∀ i : Fin n, ∑ y, p₂ y * Real.exp (r₂ y * (t₀ + (i : ℕ) * tau))
      = ∑ j, rewardMass r₂ p₂ (v j) * Real.exp (v j * (t₀ + (i : ℕ) * tau)) := by
    intro i
    rw [sum_exp_eq_rewardMass_sum h₂ (t₀ + (i : ℕ) * tau),
      Finset.sum_image (fun j _ k _ hjk => hv hjk)]
  have hsample : ∀ i : Fin n,
      ∑ j, rewardMass r₁ p₁ (v j) * Real.exp (v j * (t₀ + (i : ℕ) * tau))
        = ∑ j, rewardMass r₂ p₂ (v j) * Real.exp (v j * (t₀ + (i : ℕ) * tau)) := by
    intro i
    rw [← hre₁ i, ← hre₂ i]
    exact h i
  have hmass := exp_sample_uniqueness hv htau hsample
  intro w
  by_cases hw : w ∈ image v univ
  · obtain ⟨j, _, hj⟩ := Finset.mem_image.mp hw
    have := congrFun hmass j
    rwa [hj] at this
  · have hw₁ : w ∉ image r₁ univ := fun hmem => hw (h₁ hmem)
    have hw₂ : w ∉ image r₂ univ := fun hmem => hw (h₂ hmem)
    rw [rewardMass_eq_zero hw₁, rewardMass_eq_zero hw₂]

/-! ## 2. Unknown levels: three temperatures are not enough -/

/-- The partition function of a two-atom reward spectrum: mass `w` at level `u` and mass
`1 − w` at level `v`, read at inverse temperature `t`. -/
noncomputable def twoAtomZ (w u v t : ℝ) : ℝ :=
  w * Real.exp (u * t) + (1 - w) * Real.exp (v * t)

/-- A two-atom spectrum is an honest RLHF problem on a two-element response space. -/
theorem twoAtomZ_eq_partition (w u v t : ℝ) :
    partition t⁻¹ (fun b : Bool => if b then u else v)
      (fun b : Bool => if b then w else 1 - w) = twoAtomZ w u v t := by
  unfold partition twoAtomZ
  rw [Fintype.sum_bool]
  simp [div_eq_mul_inv, inv_inv]

/-- The two-point distribution `{1, 3}` with masses `(1/2, 1/2)`. -/
private theorem twoAtom_first_values :
    twoAtomZ (1 / 2) (Real.log 3) 0 0 = 1 ∧ twoAtomZ (1 / 2) (Real.log 3) 0 1 = 2 ∧
      twoAtomZ (1 / 2) (Real.log 3) 0 2 = 5 := by
  have h3 : Real.exp (Real.log 3) = 3 := Real.exp_log (by norm_num)
  have h9 : Real.exp (Real.log 3 * 2) = 9 := by
    have : Real.log 3 * 2 = Real.log 9 := by
      rw [show (9 : ℝ) = 3 * 3 by norm_num, Real.log_mul (by norm_num) (by norm_num)]
      ring
    rw [this]
    exact Real.exp_log (by norm_num)
  refine ⟨by simp [twoAtomZ], ?_, ?_⟩
  · simp only [twoAtomZ, mul_one, Real.exp_zero, h3]
    norm_num
  · simp only [twoAtomZ, zero_mul, Real.exp_zero, h9]
    norm_num

/-- The two-point distribution `{3/2, 4}` with masses `(4/5, 1/5)` has the same mean and
second moment. -/
private theorem twoAtom_second_values :
    twoAtomZ (1 / 5) (Real.log 4) (Real.log (3 / 2)) 0 = 1 ∧
      twoAtomZ (1 / 5) (Real.log 4) (Real.log (3 / 2)) 1 = 2 ∧
        twoAtomZ (1 / 5) (Real.log 4) (Real.log (3 / 2)) 2 = 5 := by
  have h4 : Real.exp (Real.log 4) = 4 := Real.exp_log (by norm_num)
  have h32 : Real.exp (Real.log (3 / 2)) = 3 / 2 := Real.exp_log (by norm_num)
  have h16 : Real.exp (Real.log 4 * 2) = 16 := by
    have : Real.log 4 * 2 = Real.log 16 := by
      rw [show (16 : ℝ) = 4 * 4 by norm_num, Real.log_mul (by norm_num) (by norm_num)]
      ring
    rw [this]
    exact Real.exp_log (by norm_num)
  have h94 : Real.exp (Real.log (3 / 2) * 2) = 9 / 4 := by
    have : Real.log (3 / 2) * 2 = Real.log (9 / 4) := by
      rw [show (9 / 4 : ℝ) = (3 / 2) * (3 / 2) by norm_num,
        Real.log_mul (by norm_num) (by norm_num)]
      ring
    rw [this]
    exact Real.exp_log (by norm_num)
  refine ⟨by simp [twoAtomZ], ?_, ?_⟩
  · simp only [twoAtomZ, mul_one, h4, h32]
    norm_num
  · simp only [twoAtomZ, h16, h94]
    norm_num

/-- The four reward levels involved are pairwise distinct. -/
private theorem twoAtom_levels_distinct :
    Real.log 3 ≠ 0 ∧ Real.log 4 ≠ Real.log (3 / 2) ∧ Real.log 3 ≠ Real.log 4 ∧
      Real.log 3 ≠ Real.log (3 / 2) ∧ (0 : ℝ) ≠ Real.log 4 ∧ (0 : ℝ) ≠ Real.log (3 / 2) := by
  have hlt1 : Real.log (3 / 2) < Real.log 3 := Real.log_lt_log (by norm_num) (by norm_num)
  have hlt2 : Real.log 3 < Real.log 4 := Real.log_lt_log (by norm_num) (by norm_num)
  have hpos : (0 : ℝ) < Real.log (3 / 2) := Real.log_pos (by norm_num)
  refine ⟨by linarith, by linarith, by linarith, by linarith, by linarith, by linarith⟩

/-- **Three temperatures do not determine a two-atom reward spectrum.**  There are two
two-atom RLHF problems with strictly positive reference policies, pairwise distinct reward
levels, whose partition functions agree at the three inverse temperatures `t = 0, 1, 2`.
Hence the `2n`-sample Prony count cannot be lowered to `2n − 1` when the reward levels are
unknown; contrast `RLHF.spectral_rigidity_sampled`, where knowing the levels makes `n`
samples enough. -/
theorem prony_three_samples_insufficient :
    ∃ w u v w' u' v' : ℝ,
      0 < w ∧ w < 1 ∧ 0 < w' ∧ w' < 1 ∧
      u ≠ v ∧ u' ≠ v' ∧ u ≠ u' ∧ u ≠ v' ∧ v ≠ u' ∧ v ≠ v' ∧
      (∀ t ∈ ({0, 1, 2} : Set ℝ), twoAtomZ w u v t = twoAtomZ w' u' v' t) := by
  obtain ⟨e0, e1, e2⟩ := twoAtom_first_values
  obtain ⟨f0, f1, f2⟩ := twoAtom_second_values
  obtain ⟨d1, d2, d3, d4, d5, d6⟩ := twoAtom_levels_distinct
  refine ⟨1 / 2, Real.log 3, 0, 1 / 5, Real.log 4, Real.log (3 / 2), by norm_num, by norm_num,
    by norm_num, by norm_num, d1, d2, d3, d4, d5, d6, ?_⟩
  rintro t (rfl | rfl | rfl)
  · rw [e0, f0]
  · rw [e1, f1]
  · rw [e2, f2]

/-- The same counterexample stated inside the RLHF framework: two genuine RLHF problems on a
two-element response space, with strictly positive reference policies, whose partition
functions agree at the three inverse temperatures `t = 0, 1, 2` but whose reward spectra
differ. -/
theorem prony_three_samples_insufficient_spectra :
    ∃ r₁ p₁ r₂ p₂ : Bool → ℝ, IsPosDist p₁ ∧ IsPosDist p₂ ∧
      (∀ t ∈ ({0, 1, 2} : Set ℝ), partition t⁻¹ r₁ p₁ = partition t⁻¹ r₂ p₂) ∧
      rewardMass r₁ p₁ (Real.log 3) ≠ rewardMass r₂ p₂ (Real.log 3) := by
  classical
  obtain ⟨e0, e1, e2⟩ := twoAtom_first_values
  obtain ⟨f0, f1, f2⟩ := twoAtom_second_values
  obtain ⟨d1, _, d3, d4, _, _⟩ := twoAtom_levels_distinct
  refine ⟨fun b => if b then Real.log 3 else 0, fun b => if b then (1 / 2 : ℝ) else 1 - 1 / 2,
    fun b => if b then Real.log 4 else Real.log (3 / 2),
    fun b => if b then (1 / 5 : ℝ) else 1 - 1 / 5, ?_, ?_, ?_, ?_⟩
  · refine ⟨fun b => by cases b <;> norm_num, ?_⟩
    rw [Fintype.sum_bool]; norm_num
  · refine ⟨fun b => by cases b <;> norm_num, ?_⟩
    rw [Fintype.sum_bool]; norm_num
  · rintro t (rfl | rfl | rfl) <;>
      rw [twoAtomZ_eq_partition, twoAtomZ_eq_partition]
    · rw [e0, f0]
    · rw [e1, f1]
    · rw [e2, f2]
  · have hfilter : (univ.filter fun b : Bool => (if b then Real.log 3 else 0) = Real.log 3)
        = {true} := by
      ext b
      cases b <;> simp [Ne.symm d1]
    have h₁ : rewardMass (fun b : Bool => if b then Real.log 3 else 0)
        (fun b : Bool => if b then (1 / 2 : ℝ) else 1 - 1 / 2) (Real.log 3) = 1 / 2 := by
      rw [rewardMass, hfilter]
      norm_num
    have hnot : Real.log 3 ∉ image (fun b : Bool => if b then Real.log 4 else Real.log (3 / 2))
        univ := by
      simp only [Finset.mem_image, not_exists]
      rintro b ⟨-, hb⟩
      cases b
      · have hb' : Real.log (3 / 2) = Real.log 3 := by simpa using hb
        exact d4 hb'.symm
      · have hb' : Real.log 4 = Real.log 3 := by simpa using hb
        exact d3 hb'.symm
    rw [h₁, rewardMass_eq_zero hnot]
    norm_num

end RLHF