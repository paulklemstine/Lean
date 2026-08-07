import Mathlib

/-!
# The Bekenstein–Hawking area law from microstate counting

This file develops, from scratch and in full rigour, an *exact* area law for the
entropy of a quantum isolated horizon, in the combinatorial model that underlies
the loop-quantum-gravity / isolated-horizon derivation of black hole entropy.

## The model

A quantum isolated horizon is described by a finite ordered family of *punctures*.
Each puncture carries an `SU(2)` spin `j ∈ {1/2, 1, 3/2, …}`, encoded by the
integer `k = 2j ≥ 1`, and a magnetic quantum number `m ∈ {-j, …, j}`, encoded by
`M = 2m ∈ {-k, -k+2, …, k}` (so `M` has the same parity as `k` and `|M| ≤ k`).
The horizon area is the sum of the individual puncture areas; we use the
*equidistant* (large-spin / "k-linear") area spectrum, in which a puncture of
label `k` contributes `k` area quanta.  The degeneracy of a spin-`j` puncture is
`2j + 1 = k + 1`.

`horizonStates n` is the (finite) set of all horizon configurations of total area
`n`, and `hStates n = (horizonStates n).card` is the number of microstates.

## Main results

* `hStates_succ` : the fundamental renewal-type recursion
  `hStates (n+1) = ∑_{i<n+1} (i+2) * hStates (n-i)`;
* `hStates_linear_rec` : the microstate count satisfies the *finite* linear
  recursion `hStates (n+2) + 2 * hStates n = 4 * hStates (n+1)` (`n ≥ 1`), a
  nontrivial consequence of the infinite-order renewal recursion;
* `hStates_closed_form` : the exact closed form
  `4 * hStates n = (1+√2)(2+√2)^n + (1-√2)(2-√2)^n`;
* `hStates_bounds` : the two-sided bound `(2+√2)^n / 2 ≤ hStates n ≤ (2+√2)^n`;
* `entropy_sub_area_law_abs_le` : the entropy `log (hStates n)` differs from
  `n * log (2+√2)` by at most `log 2` — an area law with *bounded* correction;
* `entropy_area_law` : `log (hStates n) / n → log (2+√2)`, i.e. the entropy is
  asymptotically proportional to the horizon area;
* `bekenstein_hawking_normalisation` : the area quantum `γ` for which the
  microscopic entropy equals the Bekenstein–Hawking value `A/4` is *unique*, and
  equals `4 log (2+√2)`.  This is the exact analogue of the fixing of the
  Barbero–Immirzi parameter in loop quantum gravity;
* `characteristic_equation` : the growth rate `2+√2` is characterised
  intrinsically by the transcendental "isolated-horizon characteristic equation"
  `∑_{k≥1} (k+1) e^{-λ k} = 1` at `e^{-λ} = 1/(2+√2)`, exactly as in the
  Ashtekar–Baez–Corichi–Krasnov state counting.
-/

open Finset

namespace BekensteinHawking

/-! ## The microstate model -/

/-- The admissible magnetic numbers `M = 2m` of a puncture with spin label
`k = 2j`: the `k+1` integers `k, k-2, …, -k`. -/
def punctureLabels (k : ℕ) : Finset ℤ :=
  (Finset.range (k + 1)).image (fun i : ℕ => (k : ℤ) - 2 * (i : ℤ))

lemma card_punctureLabels (k : ℕ) : (punctureLabels k).card = k + 1 := by
  rw [punctureLabels, Finset.card_image_of_injective _ (by
    intro a b h; simp only at h; omega), Finset.card_range]

/-- All horizon configurations of total area `n`: finite lists of punctures
`(k, M)` with `k ≥ 1`, `M ∈ punctureLabels k`, whose spin labels sum to `n`. -/
def horizonStates : ℕ → Finset (List (ℕ × ℤ))
  | 0 => {[]}
  | (n + 1) => (Finset.range (n + 1)).biUnion (fun i =>
      (punctureLabels (i + 1)).biUnion (fun M =>
        (horizonStates (n - i)).image (fun l => (i + 1, M) :: l)))

/-- The number of quantum microstates of an isolated horizon of area `n`. -/
def hStates (n : ℕ) : ℕ := (horizonStates n).card

lemma cons_injective (p : ℕ × ℤ) :
    Function.Injective (fun l : List (ℕ × ℤ) => p :: l) := by
  intro a b h; simpa using h

@[simp] lemma hStates_zero : hStates 0 = 1 := by
  simp [hStates, horizonStates]

/-- The renewal recursion: peeling off the first puncture. -/
lemma hStates_succ (n : ℕ) :
    hStates (n + 1) = ∑ i ∈ Finset.range (n + 1), (i + 2) * hStates (n - i) := by
  unfold hStates
  rw [horizonStates, Finset.card_biUnion]
  · refine Finset.sum_congr rfl ?_
    intro i _
    rw [Finset.card_biUnion]
    · have h : ∀ M ∈ punctureLabels (i + 1),
          ((horizonStates (n - i)).image (fun l => ((i + 1, M) :: l))).card
            = (horizonStates (n - i)).card :=
        fun M _ => Finset.card_image_of_injective _ (cons_injective _)
      rw [Finset.sum_congr rfl h, Finset.sum_const, card_punctureLabels]
      ring
    · intro M _ M' _ hne
      simp only [Finset.disjoint_left, Finset.mem_image]
      rintro l ⟨a, ha, rfl⟩ ⟨b, hb, hb2⟩
      simp only [List.cons.injEq, Prod.mk.injEq] at hb2
      exact hne hb2.1.2.symm
  · intro i _ j _ hne
    simp only [Finset.disjoint_left, Finset.mem_biUnion, Finset.mem_image]
    rintro l ⟨M, hM, a, ha, rfl⟩ ⟨M', hM', b, hb, hb2⟩
    simp only [List.cons.injEq, Prod.mk.injEq] at hb2
    omega

/-- The renewal recursion, reindexed by the area of the remaining horizon. -/
lemma hStates_succ' (n : ℕ) :
    hStates (n + 1) = ∑ j ∈ Finset.range (n + 1), (n - j + 2) * hStates j := by
  rw [hStates_succ n, ← Finset.sum_range_reflect]
  refine Finset.sum_congr rfl ?_
  intro j hj
  simp only [Finset.mem_range] at hj
  congr 2
  all_goals omega

/-- Summing the renewal recursion once: a three-term form. -/
lemma hStates_succ_partial (n : ℕ) (hn : 1 ≤ n) :
    hStates (n + 1) = 3 * hStates n + ∑ j ∈ Finset.range n, hStates j := by
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  rw [hStates_succ' (m + 1), Finset.sum_range_succ]
  have key : ∑ j ∈ Finset.range (m + 1), (m + 1 - j + 2) * hStates j
      = (∑ j ∈ Finset.range (m + 1), (m - j + 2) * hStates j)
        + ∑ j ∈ Finset.range (m + 1), hStates j := by
    rw [← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl ?_
    intro j hj
    simp only [Finset.mem_range] at hj
    have h : m + 1 - j + 2 = (m - j + 2) + 1 := by omega
    rw [h]; ring
  rw [key, ← hStates_succ' m]
  simp
  ring

/-- **Finite linear recursion.**  Although the microstate count is defined by an
infinite-order renewal recursion, it obeys the two-term linear recursion with
characteristic polynomial `x² - 4x + 2`. -/
theorem hStates_linear_rec (n : ℕ) (hn : 1 ≤ n) :
    hStates (n + 2) + 2 * hStates n = 4 * hStates (n + 1) := by
  have h1 := hStates_succ_partial n hn
  have h2 : hStates (n + 2) = 3 * hStates (n + 1) + ∑ j ∈ Finset.range (n + 1), hStates j :=
    hStates_succ_partial (n + 1) (by omega)
  rw [Finset.sum_range_succ] at h2
  omega

/-! ## Small values -/

lemma hStates_one : hStates 1 = 2 := by
  rw [hStates_succ 0]; simp

lemma hStates_two : hStates 2 = 7 := by
  rw [hStates_succ 1, Finset.sum_range_succ, Finset.sum_range_one, hStates_one]
  simp

/-! ## The exact closed form -/

/-- The dominant growth rate of the microstate count. -/
noncomputable def growth : ℝ := 2 + Real.sqrt 2

/-- The subdominant root of the characteristic polynomial. -/
noncomputable def growth' : ℝ := 2 - Real.sqrt 2

lemma sqrt_two_sq : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)

lemma sqrt_two_lt_two : Real.sqrt 2 < 2 := by
  nlinarith [sqrt_two_sq, Real.sqrt_nonneg 2]

lemma one_lt_sqrt_two : 1 < Real.sqrt 2 := by
  nlinarith [sqrt_two_sq, Real.sqrt_nonneg 2]

lemma growth'_pos : 0 < growth' := by
  unfold growth'; linarith [sqrt_two_lt_two]

lemma growth'_le_growth : growth' ≤ growth := by
  unfold growth growth'; linarith [Real.sqrt_nonneg 2]

lemma one_lt_growth : 1 < growth := by
  unfold growth; linarith [Real.sqrt_nonneg 2]

lemma growth_pos : 0 < growth := by linarith [one_lt_growth]

lemma growth_sq : growth ^ 2 = 4 * growth - 2 := by
  unfold growth; nlinarith [sqrt_two_sq]

lemma growth'_sq : growth' ^ 2 = 4 * growth' - 2 := by
  unfold growth'; nlinarith [sqrt_two_sq]

/-- **Exact closed form for the microstate count.** -/
theorem hStates_closed_form (n : ℕ) (hn : 1 ≤ n) :
    4 * (hStates n : ℝ)
      = (1 + Real.sqrt 2) * growth ^ n + (1 - Real.sqrt 2) * growth' ^ n := by
  have key : ∀ m : ℕ,
      (4 * (hStates (m + 1) : ℝ)
        = (1 + Real.sqrt 2) * growth ^ (m + 1) + (1 - Real.sqrt 2) * growth' ^ (m + 1))
      ∧ (4 * (hStates (m + 2) : ℝ)
        = (1 + Real.sqrt 2) * growth ^ (m + 2) + (1 - Real.sqrt 2) * growth' ^ (m + 2)) := by
    intro m
    induction m with
    | zero =>
      refine ⟨?_, ?_⟩
      · rw [hStates_one]; unfold growth growth'; push_cast; ring_nf; nlinarith [sqrt_two_sq]
      · rw [hStates_two]; unfold growth growth'; push_cast; ring_nf; nlinarith [sqrt_two_sq]
    | succ m ih =>
      obtain ⟨ihA, ihB⟩ := ih
      refine ⟨ihB, ?_⟩
      have hnat := hStates_linear_rec (m + 1) (by omega)
      have hr : (hStates (m + 3) : ℝ) = 4 * hStates (m + 2) - 2 * hStates (m + 1) := by
        have hcast : ((hStates (m + 1 + 2) : ℕ) : ℝ) + 2 * ((hStates (m + 1) : ℕ) : ℝ)
            = 4 * ((hStates (m + 1 + 1) : ℕ) : ℝ) := by exact_mod_cast hnat
        push_cast at hcast ⊢
        linarith
      have e1 : growth ^ (m + 3) = 4 * growth ^ (m + 2) - 2 * growth ^ (m + 1) := by
        have h : growth ^ (m + 3) = growth ^ (m + 1) * growth ^ 2 := by ring
        rw [h, growth_sq]; ring
      have e2 : growth' ^ (m + 3) = 4 * growth' ^ (m + 2) - 2 * growth' ^ (m + 1) := by
        have h : growth' ^ (m + 3) = growth' ^ (m + 1) * growth' ^ 2 := by ring
        rw [h, growth'_sq]; ring
      show 4 * (hStates (m + 3) : ℝ) = _
      rw [hr, e1, e2]
      linarith
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  exact (key m).1

/-- **Two-sided exponential bounds**: the microstate count is `(2+√2)^n` up to a
factor of two. -/
theorem hStates_bounds (n : ℕ) (hn : 1 ≤ n) :
    growth ^ n / 2 ≤ (hStates n : ℝ) ∧ (hStates n : ℝ) ≤ growth ^ n := by
  have hcf := hStates_closed_form n hn
  have hgp : (0:ℝ) < growth ^ n := pow_pos growth_pos n
  have hg'p : (0:ℝ) < growth' ^ n := pow_pos growth'_pos n
  have hle : growth' ^ n ≤ growth ^ n :=
    pow_le_pow_left₀ (le_of_lt growth'_pos) growth'_le_growth n
  have h2 := one_lt_sqrt_two
  have h3 := sqrt_two_lt_two
  constructor
  · nlinarith
  · nlinarith

/-! ## The area law for the entropy -/

/-- The microscopic (Boltzmann) entropy of an isolated horizon of area `n`. -/
noncomputable def entropy (n : ℕ) : ℝ := Real.log (hStates n)

/-- The entropy density per area quantum. -/
noncomputable def entropyDensity : ℝ := Real.log growth

lemma entropyDensity_pos : 0 < entropyDensity :=
  Real.log_pos one_lt_growth

/-- **Area law with bounded correction.**  The microscopic entropy of an isolated
horizon equals `entropyDensity * area` up to an additive error of at most
`log 2`, uniformly in the area. -/
theorem entropy_sub_area_law_abs_le (n : ℕ) (hn : 1 ≤ n) :
    |entropy n - n * entropyDensity| ≤ Real.log 2 := by
  obtain ⟨hlow, hupp⟩ := hStates_bounds n hn
  have hgp : (0:ℝ) < growth ^ n := pow_pos growth_pos n
  have hpos : (0:ℝ) < (hStates n : ℝ) := lt_of_lt_of_le (by positivity) hlow
  have hlog : Real.log (growth ^ n) = n * entropyDensity := by
    rw [Real.log_pow]; rfl
  have h1 : entropy n ≤ n * entropyDensity := by
    unfold entropy
    rw [← hlog]
    exact Real.log_le_log hpos hupp
  have h2 : n * entropyDensity - Real.log 2 ≤ entropy n := by
    unfold entropy
    have := Real.log_le_log (by positivity) hlow
    rw [Real.log_div (ne_of_gt hgp) (by norm_num), hlog] at this
    linarith
  rw [abs_le]
  constructor
  · linarith
  · have : (0:ℝ) ≤ Real.log 2 := Real.log_nonneg (by norm_num)
    linarith

/-- **Bekenstein–Hawking area law.**  The entropy per unit horizon area converges
to the entropy density `log (2+√2)`; in particular the entropy is proportional to
the *area*, not to the volume, of the horizon. -/
theorem entropy_area_law :
    Filter.Tendsto (fun n : ℕ => entropy n / n) Filter.atTop (nhds entropyDensity) := by
  rw [← tendsto_sub_nhds_zero_iff]
  apply squeeze_zero_norm' (a := fun n : ℕ => Real.log 2 / n)
  · filter_upwards [Filter.eventually_ge_atTop 1] with n hn
    have hnpos : (0:ℝ) < n := by exact_mod_cast hn
    have he : entropy n / n - entropyDensity = (entropy n - n * entropyDensity) / n := by
      field_simp
    rw [Real.norm_eq_abs, he, abs_div, abs_of_pos hnpos]
    gcongr
    exact entropy_sub_area_law_abs_le n hn
  · exact tendsto_const_div_atTop_nhds_zero_nat (Real.log 2)

/-- **Fixing the area quantum (Barbero–Immirzi parameter).**  If the physical
horizon area is `γ` times the number of area quanta, then the microscopic entropy
matches the Bekenstein–Hawking value `A/4` in the large-area limit *iff*
`γ = 4 log (2+√2)`.  In particular the normalisation is unique. -/
theorem bekenstein_hawking_normalisation (γ : ℝ) (hγ : 0 < γ) :
    Filter.Tendsto (fun n : ℕ => entropy n / (γ * n)) Filter.atTop (nhds (1/4))
      ↔ γ = 4 * entropyDensity := by
  have hD : 0 < entropyDensity := entropyDensity_pos
  have key : Filter.Tendsto (fun n : ℕ => entropy n / (γ * n)) Filter.atTop
      (nhds (entropyDensity / γ)) := by
    refine (entropy_area_law.div_const γ).congr ?_
    intro n; rw [div_div, mul_comm]
  constructor
  · intro h
    have hq : entropyDensity / γ = 1 / 4 := tendsto_nhds_unique key h
    field_simp at hq
    linarith
  · intro h
    have hq : entropyDensity / γ = 1 / 4 := by rw [h]; field_simp
    rwa [hq] at key

/-! ## The characteristic equation -/

/-- **The isolated-horizon characteristic equation.**  The growth rate `2+√2` is
the intrinsic solution of `∑_{k ≥ 1} (k+1) x^k = 1`, the equation that in the
Ashtekar–Baez–Corichi–Krasnov counting fixes the entropy density: the entropy
density is `-log x₀` for the unique root `x₀ ∈ (0,1)` of that equation. -/
theorem characteristic_equation :
    ∑' k : ℕ, ((k : ℝ) + 2) * (growth⁻¹) ^ (k + 1) = 1 := by
  have hs2 := sqrt_two_sq
  have hs2pos : 0 < Real.sqrt 2 := Real.sqrt_pos.mpr (by norm_num)
  have hginv : growth⁻¹ = 1 - Real.sqrt 2 / 2 := by
    have hne : (2 : ℝ) + Real.sqrt 2 ≠ 0 := by positivity
    rw [growth]; field_simp; nlinarith
  set x : ℝ := growth⁻¹ with hxdef
  have hxpos : 0 < x := by rw [hginv]; nlinarith [sqrt_two_lt_two]
  have hxlt : x < 1 := by rw [hginv]; nlinarith
  have hnorm : ‖x‖ < 1 := by rw [Real.norm_eq_abs, abs_of_pos hxpos]; exact hxlt
  have hsum1 : Summable (fun k : ℕ => (k : ℝ) * x ^ k) := by
    simpa using summable_pow_mul_geometric_of_norm_lt_one (R := ℝ) 1 hnorm
  have hsum2 : Summable (fun k : ℕ => x ^ k) := summable_geometric_of_lt_one (le_of_lt hxpos) hxlt
  have h1 : ∑' k : ℕ, (k : ℝ) * x ^ k = x / (1 - x) ^ 2 :=
    tsum_coe_mul_geometric_of_norm_lt_one hnorm
  have h2 : ∑' k : ℕ, x ^ k = (1 - x)⁻¹ := tsum_geometric_of_lt_one (le_of_lt hxpos) hxlt
  have hsplit : ∀ k : ℕ, ((k : ℝ) + 2) * x ^ (k + 1) = x * ((k : ℝ) * x ^ k) + (2 * x) * x ^ k := by
    intro k; ring
  rw [tsum_congr hsplit, Summable.tsum_add (hsum1.mul_left x) (hsum2.mul_left (2 * x)),
    tsum_mul_left, tsum_mul_left, h1, h2]
  have hne : (1 : ℝ) - x ≠ 0 := by linarith
  field_simp
  rw [hginv]
  nlinarith

end BekensteinHawking