import Novelty.BekensteinHawkingCharacteristicRoot

/-!
# The characteristic root determines the entropy density — without finite support

`Novelty.BekensteinHawkingCharacteristicRoot` identifies the entropy density of a
puncture model with `-log r`, `r` the root of `∑_k deg(k) r^k = 1`, under the
hypothesis that only finitely many puncture types occur.  This file removes that
hypothesis: for *any* degeneracy function, a positive `r` with
`∑_{k ≥ 1} deg(k) r^k = 1` (an infinite series) already forces the entropy
density to be `-log r`.

## Main results

* `gW_le_inv_root_pow_general` : `W(A) ≤ r^{-A}`, by the same renewal induction —
  only the partial sums of the characteristic series are needed, and they are
  bounded by its total value `1`;
* `exists_charPoly_gt_one` : beyond the root the *truncated* characteristic
  polynomials eventually exceed `1`.  This is the crux: it holds both when the
  characteristic series converges at `x > r` (then its value is `> 1` by strict
  termwise comparison) and when it diverges (then the partial sums tend to `∞`);
* `gEntropy_eq_neg_log_charRoot_general` : consequently the truncated models —
  to which the finite-support theorem applies — have roots accumulating at `r`
  from above, and squeezing them against the upper bound gives `L = -log r`;
* `gDensity_strict_mono_general` : the same truncation technique upgrades the
  Barbero–Immirzi rigidity statement to arbitrary degeneracy functions;
* `entropyDensity_eq_neg_log_of_characteristic` : applied to the concrete
  isolated-horizon model, the entropy density `log (2+√2)` is *determined* by the
  Ashtekar–Baez–Corichi–Krasnov characteristic equation `∑_{k≥1}(k+1)y^k = 1`:
  any positive solution `y` of that equation satisfies `entropyDensity = -log y`.

This closes Conjecture 2′ of `FUTURE_DIRECTIONS.md` (and the general form of
Conjecture 3).
-/

open Finset Filter

namespace BekensteinHawking
namespace Universal

/-- The terms of the characteristic series `∑_{k ≥ 1} deg(k) r^k`. -/
noncomputable def charTerm (deg : ℕ → ℕ) (r : ℝ) (i : ℕ) : ℝ := (deg (i + 1) : ℝ) * r ^ (i + 1)

lemma charTerm_nonneg (deg : ℕ → ℕ) {r : ℝ} (hr : 0 ≤ r) (i : ℕ) : 0 ≤ charTerm deg r i := by
  have : (0:ℝ) ≤ (deg (i + 1) : ℝ) := Nat.cast_nonneg _
  rw [charTerm]
  positivity

/-- A degeneracy function with total characteristic mass `1` has a summable
characteristic series (otherwise the sum would be `0`). -/
lemma summable_charTerm (deg : ℕ → ℕ) {r : ℝ} (htsum : ∑' i, charTerm deg r i = 1) :
    Summable (charTerm deg r) := by
  by_contra h
  rw [tsum_eq_zero_of_not_summable h] at htsum
  exact zero_ne_one htsum

lemma sum_charTerm_le_one (deg : ℕ → ℕ) {r : ℝ} (hr : 0 ≤ r)
    (htsum : ∑' i, charTerm deg r i = 1) (m : ℕ) :
    ∑ i ∈ range m, charTerm deg r i ≤ 1 := by
  rw [← htsum]
  exact (summable_charTerm deg htsum).sum_le_tsum _ (fun i _ => charTerm_nonneg deg hr i)

/-- **The characteristic root bounds the microstate count**, with no finiteness
assumption on the set of puncture types. -/
theorem gW_le_inv_root_pow_general (deg : ℕ → ℕ) {r : ℝ} (hr0 : 0 < r)
    (htsum : ∑' i, charTerm deg r i = 1) (n : ℕ) :
    (gW deg n : ℝ) ≤ (r⁻¹) ^ n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => simp
    | (n + 1) =>
      have hstep : (gW deg (n + 1) : ℝ)
          = ∑ i ∈ range (n + 1), (deg (i + 1) : ℝ) * (gW deg (n - i) : ℝ) := by
        rw [gW_succ]
        push_cast
        ring
      have hbound : ∀ i ∈ range (n + 1),
          (deg (i + 1) : ℝ) * (gW deg (n - i) : ℝ)
            ≤ (deg (i + 1) : ℝ) * ((r⁻¹) ^ (n + 1) * r ^ (i + 1)) := by
        intro i hi
        simp only [Finset.mem_range] at hi
        have hsplit : n + 1 = (n - i) + (i + 1) := by omega
        have hpow : (r⁻¹) ^ (n + 1) * r ^ (i + 1) = (r⁻¹) ^ (n - i) := by
          rw [hsplit, pow_add, mul_assoc, ← mul_pow, inv_mul_cancel₀ (ne_of_gt hr0),
            one_pow, mul_one]
        rw [hpow]
        have hIH := ih (n - i) (by omega)
        have hd : (0:ℝ) ≤ (deg (i + 1) : ℝ) := Nat.cast_nonneg _
        nlinarith
      have hsum : (gW deg (n + 1) : ℝ)
          ≤ ∑ i ∈ range (n + 1), (deg (i + 1) : ℝ) * ((r⁻¹) ^ (n + 1) * r ^ (i + 1)) := by
        rw [hstep]
        exact Finset.sum_le_sum hbound
      have hfact : ∑ i ∈ range (n + 1), (deg (i + 1) : ℝ) * ((r⁻¹) ^ (n + 1) * r ^ (i + 1))
          = (r⁻¹) ^ (n + 1) * ∑ i ∈ range (n + 1), charTerm deg r i := by
        rw [Finset.mul_sum]
        refine Finset.sum_congr rfl (fun i _ => by rw [charTerm]; ring)
      have hchar : ∑ i ∈ range (n + 1), charTerm deg r i ≤ 1 :=
        sum_charTerm_le_one deg (le_of_lt hr0) htsum (n + 1)
      have hinvpos : (0:ℝ) < (r⁻¹) ^ (n + 1) := by positivity
      calc (gW deg (n + 1) : ℝ)
          ≤ (r⁻¹) ^ (n + 1) * ∑ i ∈ range (n + 1), charTerm deg r i := by
            rw [← hfact]; exact hsum
        _ ≤ (r⁻¹) ^ (n + 1) * 1 := by nlinarith
        _ = (r⁻¹) ^ (n + 1) := by ring

/-- The density is at most `-log r`. -/
theorem gDensity_le_neg_log_root (deg : ℕ → ℕ) (hdeg1 : 1 ≤ deg 1) {r : ℝ} (hr0 : 0 < r)
    (htsum : ∑' i, charTerm deg r i = 1) {L : ℝ}
    (hL : Tendsto (fun n : ℕ => Real.log (gW deg n) / n) atTop (nhds L)) :
    L ≤ -Real.log r := by
  refine le_of_tendsto_of_tendsto hL tendsto_const_nhds ?_
  filter_upwards [eventually_ge_atTop 1] with n hn
  have hnpos : (0:ℝ) < n := by exact_mod_cast hn
  have hpos : (0:ℝ) < (gW deg n : ℝ) := by
    have : (1:ℝ) ≤ (gW deg n : ℝ) := by exact_mod_cast one_le_gW deg hdeg1 n
    linarith
  have hle := gW_le_inv_root_pow_general deg hr0 htsum n
  have hlog := Real.log_le_log hpos hle
  rw [Real.log_pow, Real.log_inv] at hlog
  rw [div_le_iff₀ hnpos]
  linarith

/-! ## Truncated models -/

/-- The model `deg` truncated to puncture areas `≤ K`. -/
def degTrunc (deg : ℕ → ℕ) (K : ℕ) : ℕ → ℕ := fun k => if k ≤ K then deg k else 0

lemma degTrunc_le (deg : ℕ → ℕ) (K : ℕ) : ∀ k, degTrunc deg K k ≤ deg k := by
  intro k
  rw [degTrunc]
  split <;> simp

lemma degTrunc_supp (deg : ℕ → ℕ) (K : ℕ) : ∀ k, K < k → degTrunc deg K k = 0 := by
  intro k hk
  rw [degTrunc, if_neg (by omega)]

lemma degTrunc_one (deg : ℕ → ℕ) {K : ℕ} (hK : 1 ≤ K) : degTrunc deg K 1 = deg 1 := by
  rw [degTrunc, if_pos hK]

lemma charPoly_degTrunc (deg : ℕ → ℕ) (K : ℕ) (x : ℝ) :
    charPoly (degTrunc deg K) K x = ∑ i ∈ range K, charTerm deg x i := by
  refine Finset.sum_congr rfl (fun i hi => ?_)
  simp only [Finset.mem_range] at hi
  rw [charTerm, degTrunc, if_pos (by omega)]

/-- **Beyond the root the truncated characteristic polynomials exceed `1`.**
Either the characteristic series converges at `x > r`, and then its value is
strictly larger than its value `1` at `r`, or it diverges and its partial sums
tend to infinity. -/
theorem exists_charPoly_gt_one (deg : ℕ → ℕ) (hdeg1 : 1 ≤ deg 1) {r x : ℝ} (hr0 : 0 < r)
    (hx : r < x) (htsum : ∑' i, charTerm deg r i = 1) :
    ∃ K, 1 ≤ K ∧ 1 < charPoly (degTrunc deg K) K x := by
  have hx0 : (0:ℝ) < x := lt_trans hr0 hx
  have hmono : ∀ i, charTerm deg r i ≤ charTerm deg x i := by
    intro i
    have hpow : r ^ (i + 1) ≤ x ^ (i + 1) := pow_le_pow_left₀ (le_of_lt hr0) (le_of_lt hx) _
    have hd : (0:ℝ) ≤ (deg (i + 1) : ℝ) := Nat.cast_nonneg _
    rw [charTerm, charTerm]
    nlinarith
  have hstrict : charTerm deg r 0 < charTerm deg x 0 := by
    have hd : (1:ℝ) ≤ (deg 1 : ℝ) := by exact_mod_cast hdeg1
    rw [charTerm, charTerm]
    simp only [zero_add, pow_one]
    nlinarith
  have hkey : ∃ K, 1 < ∑ i ∈ range K, charTerm deg x i := by
    by_cases hsx : Summable (charTerm deg x)
    · have hlt : ∑' i, charTerm deg r i < ∑' i, charTerm deg x i :=
        (summable_charTerm deg htsum).tsum_lt_tsum hmono hstrict hsx
      rw [htsum] at hlt
      have htend : Tendsto (fun K => ∑ i ∈ range K, charTerm deg x i) atTop
          (nhds (∑' i, charTerm deg x i)) := hsx.hasSum.tendsto_sum_nat
      obtain ⟨K, hK⟩ := (htend.eventually_const_lt hlt).exists
      exact ⟨K, hK⟩
    · have htend : Tendsto (fun K => ∑ i ∈ range K, charTerm deg x i) atTop atTop :=
        (not_summable_iff_tendsto_nat_atTop_of_nonneg
          (fun i => charTerm_nonneg deg (le_of_lt hx0) i)).1 hsx
      obtain ⟨K, hK⟩ := (htend.eventually_gt_atTop 1).exists
      exact ⟨K, hK⟩
  obtain ⟨K, hK⟩ := hkey
  refine ⟨K, ?_, ?_⟩
  · by_contra h
    have hK0 : K = 0 := by omega
    rw [hK0] at hK
    simp only [Finset.range_zero, Finset.sum_empty] at hK
    linarith
  · rwa [charPoly_degTrunc]

/-! ## The general identification of the density -/

/-- **The entropy density is the characteristic root, in general.**  For an
arbitrary degeneracy function, any positive solution `r` of the isolated-horizon
characteristic equation `∑_{k ≥ 1} deg(k) r^k = 1` computes the entropy density
as `-log r`.  (In particular the equation has at most one positive solution.) -/
theorem gEntropy_eq_neg_log_charRoot_general (deg : ℕ → ℕ) (hdeg1 : 1 ≤ deg 1) {r : ℝ}
    (hr0 : 0 < r) (htsum : ∑' i, charTerm deg r i = 1) {L : ℝ}
    (hL : Tendsto (fun n : ℕ => Real.log (gW deg n) / n) atTop (nhds L)) :
    L = -Real.log r := by
  refine le_antisymm (gDensity_le_neg_log_root deg hdeg1 hr0 htsum hL) ?_
  by_contra hcon
  push_neg at hcon
  -- `x = e^{-L} > r`, and the truncation at some `K` already has its root below `x`
  set x : ℝ := Real.exp (-L) with hxdef
  have hx0 : 0 < x := Real.exp_pos _
  have hlogx : Real.log x = -L := by rw [hxdef, Real.log_exp]
  have hxr : r < x := by
    have h1 : Real.log r < -L := by linarith
    have h2 : Real.exp (Real.log r) < Real.exp (-L) := Real.exp_lt_exp.2 h1
    rwa [Real.exp_log hr0] at h2
  obtain ⟨K, hK1, hKgt⟩ := exists_charPoly_gt_one deg hdeg1 hr0 hxr htsum
  have hd1 : 1 ≤ degTrunc deg K 1 := by rw [degTrunc_one deg hK1]; exact hdeg1
  obtain ⟨rK, hrK0, _, hrK⟩ := exists_charRoot (degTrunc deg K) K hd1 hK1
  have hrKx : rK < x := by
    have hstrict : charPoly (degTrunc deg K) K rK < charPoly (degTrunc deg K) K x := by
      rw [hrK]; exact hKgt
    exact ((charPoly_strictMonoOn (degTrunc deg K) K hd1 hK1).lt_iff_lt
      (le_of_lt hrK0) (le_of_lt hx0)).1 hstrict
  have hLK : Tendsto (fun n : ℕ => Real.log (gW (degTrunc deg K) n) / n) atTop
      (nhds (-Real.log rK)) :=
    gEntropy_eq_neg_log_charRoot (degTrunc deg K) K hd1 (degTrunc_supp deg K) hrK0 hrK
  have hle : -Real.log rK ≤ L := gDensity_mono (degTrunc_le deg K) hLK hL
  have hlt : Real.log rK < Real.log x := Real.log_lt_log hrK0 hrKx
  rw [hlogx] at hlt
  linarith

/-! ## Strict monotonicity in the degeneracies, without finite support -/

/-- If a degeneracy is strictly raised anywhere, the truncated characteristic
polynomials of the larger model already exceed `1` at the root of the smaller
model. -/
lemma exists_charPoly_gt_one_of_deg_lt {deg deg' : ℕ → ℕ} (hmono : ∀ k, deg k ≤ deg' k)
    {i₀ : ℕ} (hlt : deg (i₀ + 1) < deg' (i₀ + 1)) {r : ℝ} (hr0 : 0 < r)
    (htsum : ∑' i, charTerm deg r i = 1) :
    ∃ K, 1 ≤ K ∧ 1 < charPoly (degTrunc deg' K) K r := by
  set d : ℝ := charTerm deg' r i₀ - charTerm deg r i₀ with hd
  have hdpos : 0 < d := by
    have hcast : ((deg (i₀ + 1) : ℕ) : ℝ) < ((deg' (i₀ + 1) : ℕ) : ℝ) := by exact_mod_cast hlt
    have hp : (0:ℝ) < r ^ (i₀ + 1) := by positivity
    rw [hd, charTerm, charTerm]
    nlinarith
  have htend : Tendsto (fun K => ∑ i ∈ range K, charTerm deg r i) atTop (nhds 1) := by
    have := (summable_charTerm deg htsum).hasSum.tendsto_sum_nat
    rwa [htsum] at this
  have hev : ∀ᶠ K in atTop, 1 - d < ∑ i ∈ range K, charTerm deg r i :=
    htend.eventually_const_lt (by linarith)
  obtain ⟨K, hK, hKi₀⟩ := ((hev.and (eventually_ge_atTop (i₀ + 1))).exists)
  refine ⟨K, by omega, ?_⟩
  rw [charPoly_degTrunc]
  have hterm : ∀ i ∈ range K, charTerm deg r i ≤ charTerm deg' r i := by
    intro i _
    have hcast : ((deg (i + 1) : ℕ) : ℝ) ≤ ((deg' (i + 1) : ℕ) : ℝ) := by
      exact_mod_cast hmono (i + 1)
    have hp : (0:ℝ) ≤ r ^ (i + 1) := by positivity
    rw [charTerm, charTerm]
    nlinarith
  have hi₀mem : i₀ ∈ range K := Finset.mem_range.2 (by omega)
  have hsplit : ∑ i ∈ range K, charTerm deg r i + d ≤ ∑ i ∈ range K, charTerm deg' r i := by
    have := Finset.sum_le_sum hterm
    have hstrictterm : charTerm deg r i₀ + d = charTerm deg' r i₀ := by rw [hd]; ring
    -- isolate the index `i₀` on both sides
    rw [← Finset.add_sum_erase _ _ hi₀mem, ← Finset.add_sum_erase _ (charTerm deg' r) hi₀mem,
      ← hstrictterm]
    have hrest : ∑ i ∈ (range K).erase i₀, charTerm deg r i
        ≤ ∑ i ∈ (range K).erase i₀, charTerm deg' r i := by
      refine Finset.sum_le_sum (fun i hi => hterm i (Finset.mem_of_mem_erase hi))
    linarith
  linarith

/-- **Barbero–Immirzi rigidity, in general.**  Strictly raising any single
degeneracy strictly increases the entropy density of the horizon, with no
finiteness assumption on the set of puncture types. -/
theorem gDensity_strict_mono_general {deg deg' : ℕ → ℕ} (hdeg1 : 1 ≤ deg 1)
    (hmono : ∀ k, deg k ≤ deg' k) {i₀ : ℕ} (hlt : deg (i₀ + 1) < deg' (i₀ + 1))
    {r : ℝ} (hr0 : 0 < r) (htsum : ∑' i, charTerm deg r i = 1) {L L' : ℝ}
    (hL : Tendsto (fun n : ℕ => Real.log (gW deg n) / n) atTop (nhds L))
    (hL' : Tendsto (fun n : ℕ => Real.log (gW deg' n) / n) atTop (nhds L')) :
    L < L' := by
  have hdeg1' : 1 ≤ deg' 1 := le_trans hdeg1 (hmono 1)
  obtain ⟨K, hK1, hKgt⟩ := exists_charPoly_gt_one_of_deg_lt hmono hlt hr0 htsum
  have hd1 : 1 ≤ degTrunc deg' K 1 := by rw [degTrunc_one deg' hK1]; exact hdeg1'
  obtain ⟨rK, hrK0, _, hrK⟩ := exists_charRoot (degTrunc deg' K) K hd1 hK1
  have hrKr : rK < r := by
    have hstrict : charPoly (degTrunc deg' K) K rK < charPoly (degTrunc deg' K) K r := by
      rw [hrK]; exact hKgt
    exact ((charPoly_strictMonoOn (degTrunc deg' K) K hd1 hK1).lt_iff_lt
      (le_of_lt hrK0) (le_of_lt hr0)).1 hstrict
  have hLK : Tendsto (fun n : ℕ => Real.log (gW (degTrunc deg' K) n) / n) atTop
      (nhds (-Real.log rK)) :=
    gEntropy_eq_neg_log_charRoot (degTrunc deg' K) K hd1 (degTrunc_supp deg' K) hrK0 hrK
  have hle : -Real.log rK ≤ L' := gDensity_mono (degTrunc_le deg' K) hLK hL'
  have hLr : L = -Real.log r := gEntropy_eq_neg_log_charRoot_general deg hdeg1 hr0 htsum hL
  have hloglt : Real.log rK < Real.log r := Real.log_lt_log hrK0 hrKr
  rw [hLr]
  linarith

/-! ## The concrete isolated-horizon model -/

/-- **The Ashtekar–Baez–Corichi–Krasnov characteristic equation determines the
horizon entropy density.**  Any positive solution `y` of `∑_{k ≥ 1} (k+1) y^k = 1`
satisfies `entropyDensity = -log y`; combined with `characteristic_equation`
(`y = 1/(2+√2)` is a solution) this is a second, purely structural derivation of
`entropyDensity = log (2+√2)`, and it shows the solution is unique. -/
theorem hStates_density_eq_neg_log_of_characteristic {y : ℝ} (hy : 0 < y)
    (heq : ∑' i : ℕ, ((i : ℝ) + 2) * y ^ (i + 1) = 1) {L : ℝ}
    (hL : Tendsto (fun n : ℕ => Real.log (hStates n) / n) atTop (nhds L)) :
    L = -Real.log y := by
  have hterm : charTerm (fun k => k + 1) y = fun i : ℕ => ((i : ℝ) + 2) * y ^ (i + 1) := by
    funext i
    rw [charTerm]
    push_cast
    ring
  have hL' : Tendsto (fun n : ℕ => Real.log (gW (fun k => k + 1) n) / n) atTop (nhds L) := by
    refine hL.congr (fun n => ?_)
    rw [gW_eq_hStates]
  refine gEntropy_eq_neg_log_charRoot_general (fun k => k + 1) (by norm_num) hy ?_ hL'
  rw [hterm]
  exact heq

/-- The same statement for the entropy density of the concrete model. -/
theorem entropyDensity_eq_neg_log_of_characteristic {y : ℝ} (hy : 0 < y)
    (heq : ∑' i : ℕ, ((i : ℝ) + 2) * y ^ (i + 1) = 1) :
    entropyDensity = -Real.log y :=
  hStates_density_eq_neg_log_of_characteristic hy heq entropy_area_law

/-- **Uniqueness of the positive solution of the characteristic equation.** -/
theorem characteristic_solution_unique {y y' : ℝ} (hy : 0 < y) (hy' : 0 < y')
    (heq : ∑' i : ℕ, ((i : ℝ) + 2) * y ^ (i + 1) = 1)
    (heq' : ∑' i : ℕ, ((i : ℝ) + 2) * y' ^ (i + 1) = 1) : y = y' := by
  have h1 := entropyDensity_eq_neg_log_of_characteristic hy heq
  have h2 := entropyDensity_eq_neg_log_of_characteristic hy' heq'
  have hlog : Real.log y = Real.log y' := by
    rw [h1] at h2
    linarith
  have := congrArg Real.exp hlog
  rwa [Real.exp_log hy, Real.exp_log hy'] at this

/-- Consistency: the concrete model's characteristic equation is solved by
`1/(2+√2)`, so the two derivations of the entropy density agree. -/
theorem entropyDensity_eq_log_growth_via_characteristic :
    entropyDensity = -Real.log (growth⁻¹) :=
  entropyDensity_eq_neg_log_of_characteristic (inv_pos.2 growth_pos) characteristic_equation

end Universal
end BekensteinHawking