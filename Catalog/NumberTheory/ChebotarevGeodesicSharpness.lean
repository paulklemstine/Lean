/-
# Sharpness, log-absorption and abelian covers for the Chebotarev geodesic framework

This file is the *adversarial* companion to `Shared.ChebotarevGeodesic`.  Its purpose is to
show that the predicate `HasErrorExponent` is neither vacuous nor over-restrictive, and to
supply the two structural facts that make it usable in the setting of the paper
*"Chebotarev geodesic theorem: non-split case"*:

* **Log-absorption** (`hasErrorExponent_of_log_pow_bound`): a bound of the shape
  `|π x − M x| ≤ K x^θ (log x)^k`, which is what trace-formula arguments actually produce,
  implies the clean `x^{θ+ε}` statement.  The quantitative input is
  `Real.log x ≤ x^δ / δ`.
* **Little-o characterisation** (`hasErrorExponent_iff_littleO`): `HasErrorExponent π M θ`
  holds iff `(π − M)/x^{θ'} → 0` for every `θ' > θ`.  This pins the definition down and shows
  it is the standard notion.
* **Sharpness / non-vacuity** (`not_hasErrorExponent_of_growth`, `sharpness_example`): an error
  term of true size `x^β` with `β > θ` provably destroys the exponent `θ`.  In particular the
  statement "prime geodesic theorem with exponent `25/36`" is a genuine restriction: it fails
  for the (hypothetical) error term `x^{9/10}`.
* **Abelian covers** (`classDensity_of_comm`): for an abelian Galois group every conjugacy
  class is a singleton, so the Chebotarev densities are all `1/|G|` — equidistribution among
  the `|G|` classes.  Combined with `prime_geodesic_of_chebotarev` this is the classical
  "equidistribution of Frobenius" shape of the theorem.
-/

import Mathlib
import Catalog.Shared.ChebotarevGeodesic

open Finset Filter
open scoped Topology

namespace ChebotarevGeodesic

/-! ## Log-absorption -/

/-- The elementary inequality `log x ≤ x^δ / δ` for `x > 0` and `δ > 0`, obtained from
`log t ≤ t - 1` applied to `t = x^δ`. -/
theorem log_le_rpow_div {δ : ℝ} (hδ : 0 < δ) {x : ℝ} (hx : 0 < x) :
    Real.log x ≤ x ^ δ / δ := by
  have hxδ : (0 : ℝ) < x ^ δ := Real.rpow_pos_of_pos hx δ
  have h1 : Real.log (x ^ δ) ≤ x ^ δ - 1 := Real.log_le_sub_one_of_pos hxδ
  rw [Real.log_rpow hx] at h1
  rw [le_div_iff₀ hδ]
  nlinarith

/-- Powers of the logarithm are absorbed by an arbitrarily small power of `x`. -/
theorem log_pow_le {k : ℕ} {ε : ℝ} (hε : 0 < ε) {x : ℝ} (hx : 1 ≤ x) :
    (Real.log x) ^ k ≤ ((k + 1) / ε) ^ k * x ^ ε := by
  set δ : ℝ := ε / (k + 1) with hδdef
  have hk1 : (0 : ℝ) < (k : ℝ) + 1 := by positivity
  have hδ : 0 < δ := by rw [hδdef]; positivity
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx
  have hlog : 0 ≤ Real.log x := Real.log_nonneg hx
  have hstep : (Real.log x) ^ k ≤ (x ^ δ / δ) ^ k :=
    pow_le_pow_left₀ hlog (log_le_rpow_div hδ hx0) k
  have hpow : (x ^ δ / δ) ^ k = (1 / δ) ^ k * x ^ (δ * k) := by
    rw [div_pow, ← Real.rpow_natCast (x ^ δ) k, ← Real.rpow_mul hx0.le, one_div, inv_pow]
    ring
  have hle : x ^ (δ * k) ≤ x ^ ε := by
    refine Real.rpow_le_rpow_of_exponent_le hx ?_
    rw [hδdef, div_mul_eq_mul_div, div_le_iff₀ hk1]
    nlinarith [Nat.cast_nonneg (α := ℝ) k]
  have hcoef : (1 / δ : ℝ) = ((k : ℝ) + 1) / ε := by
    rw [hδdef]; field_simp
  calc (Real.log x) ^ k ≤ (x ^ δ / δ) ^ k := hstep
    _ = (1 / δ) ^ k * x ^ (δ * k) := hpow
    _ ≤ (1 / δ) ^ k * x ^ ε := by
        exact mul_le_mul_of_nonneg_left hle (by positivity)
    _ = (((k : ℝ) + 1) / ε) ^ k * x ^ ε := by rw [hcoef]

/-- **Log-absorption.**  An error bound `K x^θ (log x)^k`, the typical output of a trace
formula computation, yields the clean error exponent `θ`. -/
theorem hasErrorExponent_of_log_pow_bound {π M : ℝ → ℝ} {θ K : ℝ} {k : ℕ} (hK : 0 ≤ K)
    (hb : ∀ x ≥ (1 : ℝ), |π x - M x| ≤ K * x ^ θ * (Real.log x) ^ k) :
    HasErrorExponent π M θ := by
  intro ε hε
  refine ⟨K * ((k + 1) / ε) ^ k + 1, by positivity, 1, le_rfl, fun x hx => ?_⟩
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx
  have hxθ : (0 : ℝ) < x ^ θ := Real.rpow_pos_of_pos hx0 θ
  have hlogk : (Real.log x) ^ k ≤ ((k + 1) / ε) ^ k * x ^ ε := log_pow_le hε hx
  have hsplit : x ^ (θ + ε) = x ^ θ * x ^ ε := Real.rpow_add hx0 θ ε
  have hxε : (0 : ℝ) < x ^ ε := Real.rpow_pos_of_pos hx0 ε
  calc |π x - M x| ≤ K * x ^ θ * (Real.log x) ^ k := hb x hx
    _ ≤ K * x ^ θ * (((k + 1) / ε) ^ k * x ^ ε) := by
        exact mul_le_mul_of_nonneg_left hlogk (by positivity)
    _ = (K * ((k + 1) / ε) ^ k) * (x ^ θ * x ^ ε) := by ring
    _ ≤ (K * ((k + 1) / ε) ^ k + 1) * (x ^ θ * x ^ ε) := by
        have : (0 : ℝ) < x ^ θ * x ^ ε := by positivity
        nlinarith
    _ = (K * ((k + 1) / ε) ^ k + 1) * x ^ (θ + ε) := by rw [hsplit]

/-! ## Little-o characterisation -/

/-- One direction: an error exponent `θ` forces `(π − M)/x^{θ'} → 0` for `θ' > θ`. -/
theorem tendsto_div_rpow_of_hasErrorExponent {π M : ℝ → ℝ} {θ θ' : ℝ}
    (h : HasErrorExponent π M θ) (hlt : θ < θ') :
    Tendsto (fun x => (π x - M x) / x ^ θ') atTop (𝓝 0) := by
  set ε := (θ' - θ) / 2 with hεdef
  have hε : 0 < ε := by rw [hεdef]; linarith
  obtain ⟨C, hC, X, hX, hb⟩ := h ε hε
  have hneg : θ + ε - θ' < 0 := by rw [hεdef]; linarith
  have hgoal : Tendsto (fun x : ℝ => C * x ^ (-(θ' - (θ + ε)))) atTop (𝓝 0) := by
    have h0 : Tendsto (fun x : ℝ => x ^ (-(θ' - (θ + ε)))) atTop (𝓝 0) :=
      tendsto_rpow_neg_atTop (by rw [hεdef]; linarith)
    simpa using h0.const_mul C
  refine squeeze_zero_norm' ?_ hgoal
  filter_upwards [eventually_ge_atTop X, eventually_gt_atTop (0:ℝ)] with x hxX hx0
  have hxθ' : (0 : ℝ) < x ^ θ' := Real.rpow_pos_of_pos hx0 θ'
  have h1 : |π x - M x| ≤ C * x ^ (θ + ε) := hb x hxX
  have : ‖(π x - M x) / x ^ θ'‖ = |π x - M x| / x ^ θ' := by
    rw [Real.norm_eq_abs, abs_div, abs_of_pos hxθ']
  rw [this, div_le_iff₀ hxθ']
  have hmul : C * x ^ (-(θ' - (θ + ε))) * x ^ θ' = C * x ^ (θ + ε) := by
    rw [mul_assoc, ← Real.rpow_add hx0]
    ring_nf
  rw [hmul]
  exact h1

/-- The converse direction. -/
theorem hasErrorExponent_of_tendsto_div_rpow {π M : ℝ → ℝ} {θ : ℝ}
    (h : ∀ θ' > θ, Tendsto (fun x => (π x - M x) / x ^ θ') atTop (𝓝 0)) :
    HasErrorExponent π M θ := by
  intro ε hε
  have hlim := h (θ + ε) (by linarith)
  have hev : ∀ᶠ x in atTop, |π x - M x| / |x ^ (θ + ε)| < 1 := by
    have := hlim.eventually (Metric.ball_mem_nhds (0 : ℝ) one_pos)
    simpa [Real.dist_eq, abs_div] using this
  obtain ⟨X₀, hX₀⟩ := (hev.and (eventually_gt_atTop (0:ℝ))).exists_forall_of_atTop
  refine ⟨1, one_pos, max X₀ 1, le_max_right _ _, fun x hx => ?_⟩
  have hxX₀ : X₀ ≤ x := le_trans (le_max_left _ _) hx
  obtain ⟨h1, hx0⟩ := hX₀ x hxX₀
  have hxpos : (0 : ℝ) < x ^ (θ + ε) := Real.rpow_pos_of_pos hx0 _
  have : |π x - M x| / x ^ (θ + ε) < 1 := by
    rwa [abs_of_pos hxpos] at h1
  rw [one_mul]
  exact le_of_lt ((div_lt_one hxpos).mp this)

/-- **Characterisation.**  `HasErrorExponent π M θ` is exactly the statement
`π − M = o(x^{θ'})` for every `θ' > θ`. -/
theorem hasErrorExponent_iff_littleO {π M : ℝ → ℝ} {θ : ℝ} :
    HasErrorExponent π M θ ↔
      ∀ θ' > θ, Tendsto (fun x => (π x - M x) / x ^ θ') atTop (𝓝 0) :=
  ⟨fun h _ hθ' => tendsto_div_rpow_of_hasErrorExponent h hθ',
   hasErrorExponent_of_tendsto_div_rpow⟩

/-! ## A concrete character-table instance of the reduction -/

/-- The `2 × 2` Hadamard matrix is the (real) character table of `ℤ/2`.  Instantiating the
abstract reduction lemma with it recovers the split/non-split dichotomy: control of the two
character-twisted counting functions gives control of each individual one. -/
theorem exponent_of_hadamard_transform (f M : Fin 2 → ℝ → ℝ) (θ : ℝ)
    (h : ∀ j, HasErrorExponent
        (fun x => ∑ i, (!![1, 1; 1, -1] : Matrix (Fin 2) (Fin 2) ℝ) j i * f i x)
        (fun x => ∑ i, (!![1, 1; 1, -1] : Matrix (Fin 2) (Fin 2) ℝ) j i * M i x) θ)
    (i : Fin 2) :
    HasErrorExponent (f i) (M i) θ := by
  refine exponent_of_inverse_transform (!![1, 1; 1, -1] : Matrix (Fin 2) (Fin 2) ℝ)
    (!![1/2, 1/2; 1/2, -1/2] : Matrix (Fin 2) (Fin 2) ℝ) ?_ f M θ h i
  ext a b
  fin_cases a <;> fin_cases b <;>
    simp [Matrix.mul_apply, Fin.sum_univ_succ] <;> norm_num

/-! ## Sharpness: the exponent is a genuine restriction -/

/-- If the error term really is of size `x^β` with `β > θ`, then the exponent `θ` fails.
Hence `HasErrorExponent` is not vacuous, and improving the exponent is a genuine gain. -/
theorem not_hasErrorExponent_of_growth {π M : ℝ → ℝ} {θ β c : ℝ} (hc : 0 < c) (hlt : θ < β)
    (hgrow : ∀ x ≥ (1 : ℝ), c * x ^ β ≤ |π x - M x|) :
    ¬ HasErrorExponent π M θ := by
  intro h
  set ε := (β - θ) / 2 with hεdef
  have hε : 0 < ε := by rw [hεdef]; linarith
  obtain ⟨C, hC, X, hX, hb⟩ := h ε hε
  have hpos : 0 < β - (θ + ε) := by rw [hεdef]; linarith
  have hbig : Tendsto (fun x : ℝ => x ^ (β - (θ + ε))) atTop atTop := tendsto_rpow_atTop hpos
  obtain ⟨x, hx1, hxX, hxbig⟩ :
      ∃ x : ℝ, 1 ≤ x ∧ X ≤ x ∧ C / c < x ^ (β - (θ + ε)) := by
    obtain ⟨x, hx⟩ := ((hbig.eventually_gt_atTop (C / c)).and
      ((eventually_ge_atTop (1:ℝ)).and (eventually_ge_atTop X))).exists
    exact ⟨x, hx.2.1, hx.2.2, hx.1⟩
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx1
  have h1 : c * x ^ β ≤ C * x ^ (θ + ε) := le_trans (hgrow x hx1) (hb x hxX)
  have hsplit : x ^ β = x ^ (β - (θ + ε)) * x ^ (θ + ε) := by
    rw [← Real.rpow_add hx0]; ring_nf
  have hxe : (0 : ℝ) < x ^ (θ + ε) := Real.rpow_pos_of_pos hx0 _
  rw [hsplit] at h1
  have h2 : c * x ^ (β - (θ + ε)) ≤ C :=
    le_of_mul_le_mul_right (by rw [mul_assoc]; exact h1) hxe
  have h3 : C / c < x ^ (β - (θ + ε)) := hxbig
  rw [div_lt_iff₀ hc] at h3
  nlinarith

/-- A concrete witness of non-triviality: an error term of true size `x^{9/10}` is *not*
compatible with the exponent `25/36` of the paper. -/
theorem sharpness_example :
    ¬ HasErrorExponent (fun x : ℝ => x ^ ((9 : ℝ) / 10)) (fun _ => 0) (25 / 36) := by
  refine not_hasErrorExponent_of_growth (c := 1) (β := 9 / 10) one_pos (by norm_num) ?_
  intro x hx
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx
  have : (0 : ℝ) ≤ x ^ ((9:ℝ)/10) := (Real.rpow_pos_of_pos hx0 _).le
  simp [abs_of_nonneg this]

/-! ## Abelian Galois groups: equidistribution among `|G|` classes -/

section Abelian

variable (G : Type*) [CommGroup G] [Fintype G] [DecidableEq G] [Fintype (ConjClasses G)]

open scoped Classical in
/-- In an abelian group every conjugacy class is a singleton. -/
theorem classSize_of_comm (C : ConjClasses G) : classSize G C = 1 := by
  classical
  obtain ⟨g, rfl⟩ := ConjClasses.mk_surjective C
  rw [classSize, Finset.card_eq_one]
  refine ⟨g, ?_⟩
  ext h
  simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton]
  exact ⟨fun hh => ConjClasses.mk_injective hh, fun hh => by rw [hh]⟩

open scoped Classical in
/-- Consequently the Chebotarev densities of an abelian cover are all equal to `1/|G|`:
the geodesics equidistribute among the `|G|` classes. -/
theorem classDensity_of_comm (C : ConjClasses G) :
    classDensity G C = 1 / (Fintype.card G : ℝ) := by
  rw [classDensity, classSize_of_comm]
  norm_num

open scoped Classical in
/-- **Chebotarev for abelian covers.**  If each class-counting function of an abelian cover
satisfies the estimate with the equidistributed main term `li(x)/|G|` and exponent `θ`, the
prime geodesic theorem holds with exponent `θ`. -/
theorem prime_geodesic_of_chebotarev_abelian
    (piC : ConjClasses G → ℝ → ℝ) (li : ℝ → ℝ) (θ : ℝ)
    (h : ∀ C, HasErrorExponent (piC C) (fun x => li x / (Fintype.card G : ℝ)) θ) :
    HasErrorExponent (fun x => ∑ C : ConjClasses G, piC C x) li θ := by
  refine prime_geodesic_of_chebotarev G piC li θ (fun C => ?_)
  have := h C
  have e : (fun x => li x / (Fintype.card G : ℝ)) = fun x => classDensity G C * li x := by
    funext x
    rw [classDensity_of_comm]
    ring
  rwa [e] at this

end Abelian

end ChebotarevGeodesic