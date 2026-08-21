/-
# One dense set avoiding proper cubes of *every* large dimension

`Bridges.DenseSumsetLower.CubeSharp` produces, for each single dimension `d` above the
first-moment threshold, a `δ`-dense set `S ⊆ [n]` with no proper `d`-dimensional cube.  Here
the union bound is run over all dimensions at once, using the variable-size first-moment
principle `DenseSumsetLower.exists_card_eq_avoiding_weighted` of `Optimal.lean`: the total
first moment is `∑_{d ≥ d₀} n^{d+1} (m/n)^{2^d}`, a geometrically convergent series once the
first term is small, so a *single* `δ`-dense set avoids proper cubes of **every** dimension
`d ≥ d₀` simultaneously.

Two observations make the sum finite and the estimate clean:

* a proper cube of dimension `d` inside `[n]` has `2^d ≤ n` points, so only dimensions
  `d ≤ n` can occur at all;
* the ratio `(d+1)/2^d` is nonincreasing, so the threshold condition needs to be checked
  only at `d = d₀` (`DenseSumsetLower.linear_le_pow_two_of_base`).

Contents:
* `DenseSumsetLower.cubeIdx` — the parameter set of `d`-dimensional cubes in `[n]`;
* `DenseSumsetLower.exists_card_eq_no_cube_all` — the counting statement;
* `DenseSumsetLower.eventually_exists_dense_no_cube_all` — the asymptotic packaging: for all
  large `n` and every `d₀` with `(1+ε)(d₀+1)·log (4n) ≤ 2^{d₀}·log (1/δ)` there is a
  `δ`-dense `S ⊆ [n]` containing no proper cube of any dimension `d ≥ d₀`.
-/
import Bridges.DenseSumsetLower.CubeSharp
import Bridges.DenseSumsetLower.Optimal

namespace DenseSumsetLower

open Finset DeltaDense

/-! ## Elementary inequalities -/

/-- `(d+1)·A ≤ 2^d·B` propagates upwards in `d`: the ratio `(d+1)/2^d` is nonincreasing. -/
lemma linear_le_pow_two_of_base {A B : ℝ} (hA : 0 ≤ A) {d₀ : ℕ}
    (h : ((d₀ : ℝ) + 1) * A ≤ 2 ^ d₀ * B) :
    ∀ d, d₀ ≤ d → ((d : ℝ) + 1) * A ≤ 2 ^ d * B := by
  intro d hd
  induction d, hd using Nat.le_induction with
  | base => exact h
  | succ k hk ih =>
      have hk0 : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
      have hstep : ((k : ℝ) + 1 + 1) * A ≤ 2 * (((k : ℝ) + 1) * A) := by nlinarith
      calc (((k + 1 : ℕ) : ℝ) + 1) * A = ((k : ℝ) + 1 + 1) * A := by push_cast; ring
        _ ≤ 2 * (((k : ℝ) + 1) * A) := hstep
        _ ≤ 2 * (2 ^ k * B) := by linarith
        _ = 2 ^ (k + 1) * B := by ring

/-- The geometric tail used in the union bound. -/
lemma sum_quarter_pow_le (N : ℕ) : ∑ d ∈ range N, ((1 : ℝ) / 4) ^ (d + 1) ≤ 1 / 3 := by
  have hgeom : ∑ d ∈ range N, ((1 : ℝ) / 4) ^ d = (1 - (1 / 4) ^ N) / (1 - 1 / 4) := by
    rw [geom_sum_eq (by norm_num)]
    field_simp
    ring
  have hpos : (0 : ℝ) ≤ (1 / 4 : ℝ) ^ N := by positivity
  calc ∑ d ∈ range N, ((1 : ℝ) / 4) ^ (d + 1)
      = (1 / 4) * ∑ d ∈ range N, ((1 : ℝ) / 4) ^ d := by
        rw [Finset.mul_sum]
        exact Finset.sum_congr rfl fun d _ => by ring
    _ = (1 / 4) * ((1 - (1 / 4) ^ N) / (1 - 1 / 4)) := by rw [hgeom]
    _ = (1 - (1 / 4) ^ N) / 3 := by norm_num; ring
    _ ≤ 1 / 3 := by linarith

/-! ## The parameter set of `d`-dimensional cubes -/

/-- The parameters `(u, a₁, …, a_d)` of a `d`-dimensional cube inside `[n]`: a base point
below `n` and `d` generators in `[1, n]`. -/
def cubeIdx (n d : ℕ) : Finset (ℕ × (Fin d → ℕ)) :=
  (range n) ×ˢ (Fintype.piFinset fun _ : Fin d => Icc 1 n)

lemma card_cubeIdx (n d : ℕ) : (cubeIdx n d).card = n ^ (d + 1) := by
  rw [cubeIdx, Finset.card_product, Fintype.card_piFinset, Finset.card_range]
  simp [Nat.card_Icc, pow_succ, mul_comm]

/-! ## The counting statement -/

/-- **Avoiding proper cubes of every dimension `d ≥ d₀` at once.**  If
`n^{d+1}·(m/n)^{2^d} ≤ 4^{-(d+1)}` for every `d ≥ d₀`, then some `m`-element `S ⊆ [n]`
contains no proper cube of any dimension `d ≥ d₀`. -/
theorem exists_card_eq_no_cube_all {n m d₀ : ℕ} (hmn : m ≤ n) (hm : 1 ≤ m)
    (hcond : ∀ d, d₀ ≤ d →
      ((n : ℝ)) ^ (d + 1) * ((m : ℝ) / n) ^ (2 ^ d) ≤ (1 / 4) ^ (d + 1)) :
    ∃ S ⊆ range n, S.card = m ∧
      ∀ d : ℕ, d₀ ≤ d → ∀ (u : ℕ) (f : Fin d → ℕ), (∀ i, 0 < f i) →
        (funCube u f).card = 2 ^ d → ¬ (funCube u f ⊆ S) := by
  classical
  have hn : 1 ≤ n := le_trans hm hmn
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hx0 : (0 : ℝ) ≤ (m : ℝ) / n := by positivity
  set J : Finset ((d : ℕ) × (ℕ × (Fin d → ℕ))) :=
    (Finset.Ico d₀ (n + 1)).sigma (fun d => cubeIdx n d) with hJ
  set I : Finset ((d : ℕ) × (ℕ × (Fin d → ℕ))) :=
    J.filter (fun i => 2 ^ i.1 ≤ (funCube i.2.1 i.2.2).card) with hI
  -- the first moment
  have hsumJ : ∑ i ∈ J, ((m : ℝ) / n) ^ (2 ^ i.1)
      = ∑ d ∈ Finset.Ico d₀ (n + 1), (n : ℝ) ^ (d + 1) * ((m : ℝ) / n) ^ (2 ^ d) := by
    rw [hJ, Finset.sum_sigma]
    refine Finset.sum_congr rfl fun d _ => ?_
    simp only [Finset.sum_const, card_cubeIdx, nsmul_eq_mul]
    push_cast
    ring
  have hsumbound : ∑ i ∈ J, ((m : ℝ) / n) ^ (2 ^ i.1) < 1 := by
    rw [hsumJ]
    have hterm : ∀ d ∈ Finset.Ico d₀ (n + 1),
        (n : ℝ) ^ (d + 1) * ((m : ℝ) / n) ^ (2 ^ d) ≤ (1 / 4) ^ (d + 1) := by
      intro d hd
      exact hcond d (Finset.mem_Ico.mp hd).1
    refine lt_of_le_of_lt (Finset.sum_le_sum hterm) ?_
    have hsub : Finset.Ico d₀ (n + 1) ⊆ range (n + 1) := by
      intro d hd
      exact Finset.mem_range.2 (Finset.mem_Ico.mp hd).2
    have hle : ∑ d ∈ Finset.Ico d₀ (n + 1), ((1 : ℝ) / 4) ^ (d + 1)
        ≤ ∑ d ∈ range (n + 1), ((1 : ℝ) / 4) ^ (d + 1) := by
      refine Finset.sum_le_sum_of_subset_of_nonneg hsub ?_
      intro d _ _
      positivity
    have := sum_quarter_pow_le (n + 1)
    linarith
  have hsumI : ∑ i ∈ I, ((m : ℝ) / n) ^ (2 ^ i.1) < 1 := by
    refine lt_of_le_of_lt ?_ hsumbound
    refine Finset.sum_le_sum_of_subset_of_nonneg (by rw [hI]; exact Finset.filter_subset _ _) ?_
    intro i _ _
    positivity
  obtain ⟨S, hSsub, hScard, hSno⟩ :=
    exists_card_eq_avoiding_weighted (n := n) (m := m) I
      (fun i => funCube i.2.1 i.2.2) (fun i => 2 ^ i.1)
      (fun i hi => by rw [hI, Finset.mem_filter] at hi; exact hi.2)
      hmn hm hsumI
  refine ⟨S, hSsub, hScard, ?_⟩
  intro d hd u f hf hcard hsub
  -- a proper cube of dimension `d` inside `[n]` forces `2^d ≤ n`, hence `d ≤ n`
  have hcardn : 2 ^ d ≤ n := by
    have h1 : (funCube u f).card ≤ (range n).card :=
      Finset.card_le_card (hsub.trans hSsub)
    rw [hcard, Finset.card_range] at h1
    exact h1
  have hdn : d < n + 1 := by
    have := Nat.lt_two_pow_self (n := d)
    omega
  refine hSno ⟨d, (u, f)⟩ ?_ hsub
  rw [hI, Finset.mem_filter, hJ, Finset.mem_sigma, cubeIdx, Finset.mem_product,
    Fintype.mem_piFinset, Finset.mem_Ico]
  refine ⟨⟨⟨hd, hdn⟩, ?_, ?_⟩, le_of_eq hcard.symm⟩
  · simpa using hSsub (hsub (self_mem_funCube u f))
  · intro i
    have hmem : u + f i < n := by
      simpa using hSsub (hsub (add_mem_funCube u f i))
    show f i ∈ Icc 1 n
    exact Finset.mem_Icc.2 ⟨hf i, by omega⟩

/-! ## The asymptotic form -/

/-- **A single dense set with no proper cube above the threshold.**  For every
`0 < δ < 1` and `ε > 0`, for all large `n` and every `d₀` with

`(1 + ε)·(d₀ + 1)·log (4n) ≤ 2^{d₀}·log (1/δ)`,

there is a `δ`-dense `S ⊆ [n]` containing no proper affine cube of **any** dimension
`d ≥ d₀`.  This strengthens `DenseSumsetLower.eventually_exists_dense_no_cube`, where the
set depends on the dimension. -/
theorem eventually_exists_dense_no_cube_all {δ ε : ℝ} (h0 : 0 < δ) (h1 : δ < 1) (hε : 0 < ε) :
    ∀ᶠ n : ℕ in Filter.atTop, ∀ d₀ : ℕ,
      (1 + ε) * (((d₀ : ℝ) + 1) * Real.log (4 * n)) ≤ (2 ^ d₀ : ℕ) * Real.log (1 / δ) →
      ∃ S ⊆ range n, δ * n ≤ S.card ∧
        ∀ d : ℕ, d₀ ≤ d → ∀ (u : ℕ) (f : Fin d → ℕ), (∀ i, 0 < f i) →
          (funCube u f).card = 2 ^ d → ¬ (funCube u f ⊆ S) := by
  have hlpos : 0 < Real.log (1 / δ) := by
    simp only [one_div]
    exact Real.log_pos (by rw [lt_inv_comm₀ (by norm_num) h0]; simpa using h1)
  -- eventually the rounded density `⌈δn⌉/n` loses at most a factor `1 + ε` in the logarithm
  have hshift : ∀ᶠ n : ℕ in Filter.atTop,
      Real.log (1 / δ) / (1 + ε) < Real.log (1 / (δ + 1 / (n : ℝ))) := by
    have hlim : Filter.Tendsto (fun n : ℕ => Real.log (1 / (δ + 1 / (n : ℝ))))
        Filter.atTop (nhds (Real.log (1 / δ))) := by
      have h1n : Filter.Tendsto (fun n : ℕ => δ + 1 / (n : ℝ)) Filter.atTop (nhds (δ + 0)) :=
        Filter.Tendsto.const_add δ tendsto_one_div_atTop_nhds_zero_nat
      rw [add_zero] at h1n
      have h2 : Filter.Tendsto (fun n : ℕ => 1 / (δ + 1 / (n : ℝ))) Filter.atTop
          (nhds (1 / δ)) := tendsto_const_nhds.div h1n (ne_of_gt h0)
      exact (Real.continuousAt_log (by positivity)).tendsto.comp h2
    have hlt : Real.log (1 / δ) / (1 + ε) < Real.log (1 / δ) := by
      rw [div_lt_iff₀ (by linarith)]
      nlinarith
    exact hlim.eventually (eventually_gt_nhds hlt)
  filter_upwards [hshift, Filter.eventually_ge_atTop 2] with n hn hn2
  intro d₀ hd₀
  have hn0 : (0 : ℝ) < n := by
    have : (2 : ℝ) ≤ n := by exact_mod_cast hn2
    linarith
  have hlog4n : 0 < Real.log (4 * n) := by
    refine Real.log_pos ?_
    have : (2 : ℝ) ≤ n := by exact_mod_cast hn2
    linarith
  have hepos : 0 < δ + 1 / (n : ℝ) := by positivity
  set m : ℕ := ⌈δ * (n : ℝ)⌉₊ with hm
  have hδn : δ * n ≤ n := by nlinarith
  have hmn : m ≤ n := Nat.ceil_le.2 hδn
  have hm1 : 1 ≤ m := by
    rw [hm]
    refine Nat.one_le_ceil_iff.2 ?_
    positivity
  -- the per-dimension condition
  have hbase : ((d₀ : ℝ) + 1) * Real.log (4 * n) ≤ 2 ^ d₀ * Real.log (1 / (δ + 1 / (n : ℝ))) := by
    have hpow : (0 : ℝ) < ((2 ^ d₀ : ℕ) : ℝ) := by positivity
    have hstep : ((d₀ : ℝ) + 1) * Real.log (4 * n)
        ≤ ((2 ^ d₀ : ℕ) : ℝ) * (Real.log (1 / δ) / (1 + ε)) := by
      have hrw : ((2 ^ d₀ : ℕ) : ℝ) * (Real.log (1 / δ) / (1 + ε))
          = (((2 ^ d₀ : ℕ) : ℝ) * Real.log (1 / δ)) / (1 + ε) := by ring
      rw [hrw, le_div_iff₀ (by linarith)]
      nlinarith [hd₀]
    have hlt : ((2 ^ d₀ : ℕ) : ℝ) * (Real.log (1 / δ) / (1 + ε))
        < ((2 ^ d₀ : ℕ) : ℝ) * Real.log (1 / (δ + 1 / (n : ℝ))) :=
      mul_lt_mul_of_pos_left hn hpow
    have hcast : ((2 ^ d₀ : ℕ) : ℝ) = 2 ^ d₀ := by push_cast; ring
    rw [hcast] at hstep hlt
    linarith
  have hall : ∀ d, d₀ ≤ d →
      ((d : ℝ) + 1) * Real.log (4 * n) ≤ 2 ^ d * Real.log (1 / (δ + 1 / (n : ℝ))) :=
    linear_le_pow_two_of_base (le_of_lt hlog4n) hbase
  have hcondfinal : ∀ d, d₀ ≤ d →
      ((n : ℝ)) ^ (d + 1) * ((m : ℝ) / n) ^ (2 ^ d) ≤ (1 / 4) ^ (d + 1) := by
    intro d hd
    have hmle : (m : ℝ) ≤ (δ + 1 / (n : ℝ)) * n := by
      have h1 : δ * (n : ℝ) + 1 = (δ + 1 / (n : ℝ)) * n := by field_simp
      exact le_trans (le_of_lt (Nat.ceil_lt_add_one (by positivity))) (le_of_eq h1)
    have hratio : (m : ℝ) / n ≤ δ + 1 / (n : ℝ) := by
      rw [div_le_iff₀ hn0]
      exact hmle
    have hxpos : (0 : ℝ) ≤ (m : ℝ) / n := by positivity
    have hstep1 : ((m : ℝ) / n) ^ (2 ^ d) ≤ (δ + 1 / (n : ℝ)) ^ (2 ^ d) :=
      pow_le_pow_left₀ hxpos hratio _
    have hkey : (4 * (n : ℝ)) ^ (d + 1) * (δ + 1 / (n : ℝ)) ^ (2 ^ d) ≤ 1 := by
      have hlog : ((d : ℝ) + 1) * Real.log (4 * n)
          + (2 ^ d : ℝ) * Real.log (δ + 1 / (n : ℝ)) ≤ 0 := by
        have hinv : Real.log (1 / (δ + 1 / (n : ℝ))) = -Real.log (δ + 1 / (n : ℝ)) := by
          rw [one_div, Real.log_inv]
        have := hall d hd
        rw [hinv] at this
        linarith
      have hpos : (0 : ℝ) < (4 * (n : ℝ)) ^ (d + 1) * (δ + 1 / (n : ℝ)) ^ (2 ^ d) := by
        positivity
      have hlt : Real.log ((4 * (n : ℝ)) ^ (d + 1) * (δ + 1 / (n : ℝ)) ^ (2 ^ d))
          ≤ Real.log 1 := by
        rw [Real.log_mul (by positivity) (by positivity), Real.log_pow, Real.log_pow,
          Real.log_one]
        push_cast
        linarith
      rw [Real.log_one] at hlt
      have hexp := Real.exp_le_exp.2 hlt
      rwa [Real.exp_log hpos, Real.exp_zero] at hexp
    have hfinal : (n : ℝ) ^ (d + 1) * ((m : ℝ) / n) ^ (2 ^ d) ≤ (1 / 4) ^ (d + 1) := by
      have hsplit : (4 * (n : ℝ)) ^ (d + 1) = 4 ^ (d + 1) * (n : ℝ) ^ (d + 1) := by
        rw [mul_pow]
      have h4 : (0 : ℝ) < (4 : ℝ) ^ (d + 1) := by positivity
      have hchain : 4 ^ (d + 1) * ((n : ℝ) ^ (d + 1) * ((m : ℝ) / n) ^ (2 ^ d)) ≤ 1 := by
        calc 4 ^ (d + 1) * ((n : ℝ) ^ (d + 1) * ((m : ℝ) / n) ^ (2 ^ d))
            = (4 * (n : ℝ)) ^ (d + 1) * ((m : ℝ) / n) ^ (2 ^ d) := by rw [hsplit]; ring
          _ ≤ (4 * (n : ℝ)) ^ (d + 1) * (δ + 1 / (n : ℝ)) ^ (2 ^ d) := by
              exact mul_le_mul_of_nonneg_left hstep1 (by positivity)
          _ ≤ 1 := hkey
      have h14 : ((1 : ℝ) / 4) ^ (d + 1) = 1 / (4 : ℝ) ^ (d + 1) := by
        rw [div_pow, one_pow]
      rw [h14, le_div_iff₀ h4]
      calc ((n : ℝ) ^ (d + 1) * ((m : ℝ) / n) ^ (2 ^ d)) * 4 ^ (d + 1)
          = 4 ^ (d + 1) * ((n : ℝ) ^ (d + 1) * ((m : ℝ) / n) ^ (2 ^ d)) := by ring
        _ ≤ 1 := hchain
    exact hfinal

  obtain ⟨S, hSsub, hScard, hSno⟩ :=
    exists_card_eq_no_cube_all (n := n) (m := m) (d₀ := d₀) hmn hm1 hcondfinal
  exact ⟨S, hSsub, by rw [hScard, hm]; exact Nat.le_ceil _, hSno⟩

end DenseSumsetLower