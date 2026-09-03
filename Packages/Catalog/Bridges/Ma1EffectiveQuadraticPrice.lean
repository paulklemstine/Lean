import Bridges.Ma1EffectiveTotalPrice

/-!
# The quadratic (chi-square) information price of MA-1, and the failure of the
# vanishing-order dichotomy

Fifth cycle of the MA-1 effectivization loop.  Cycle 3
(`Bridges.Ma1EffectiveEntropy`) prices the equidistribution assumption at one scale by
`2ε/(1−ε)` nats, and cycle 4 (`Bridges.Ma1EffectiveTotalPrice`) sums that *linear* envelope
over all dyadic scales to `4ε₀/(1−ρ)` nats.  Both bounds are linear in the certificate.  The
first open direction recorded at the end of cycle 4 ("Quadratic Total Information Price")
conjectured that the honest price is **quadratic**.  This file proves it.

* `kl_le_chiSq` — the classical comparison of Kullback–Leibler divergence with the
  chi-square divergence from uniform: `D(p‖u) ≤ n·Σ (p a − 1/n)²`, proved from `log t ≤ t − 1`
  and the exact identity `n·Σ (p a − 1/n)² = n·Σ p a² − 1` (`chiSq_eq`).
* `classDist_dev_abs_le` — a certificate pins each class probability to within
  `2ε/(n(1−ε))` of `1/n` (two-sided, using both the upper and the new lower bound
  `total_le` on the total count).
* `kl_le_sq_of_equiCert` — hence **the quadratic price**: `D(p‖u) ≤ (2ε/(1−ε))²`, the square
  of the linear bound of cycle 3.  At the recorded `ε = 0.000446` this is below
  `8·10⁻⁷` nats (`exp509_kl_quadratic`), three orders of magnitude better than the `9·10⁻⁴`
  of cycle 3.
* `quadratic_total_information_price_le` — summed over all dyadic scales with geometrically
  decaying certificates the *total* price is at most `16ε₀²/(1−ρ²)` nats, below `4.3·10⁻⁶`
  at the recorded input with halving certificates (`exp509_quadratic_total_price`).  This
  settles the conjecture in the affirmative with the explicit constant `16`; the
  conjectured target `10⁻⁶` is not reached by this envelope, the honest value is `4.3·10⁻⁶`.

The second half of the file **refutes** the other open direction ("Vanishing-Order
Dichotomy for Transfer Costs"), which conjectured that a readout pays `O(ε²)` *iff* it
annihilates constant vectors.

* `quadOnDeviations_annihilates` — the easy half is true: a deviation-energy readout kills
  constants.
* `coordDiff_annihilates`, `coordDiff_not_quadOnDeviations` — the converse is false.  The
  coordinate difference `f ↦ f a − f b` annihilates every constant vector, yet it is not a
  deviation-energy readout for *any* constant `L`, because it is homogeneous of degree one
  while the deviation energy is homogeneous of degree two.
* `coordDiff_cost_linear_sharp` — and the failure is not an artefact of the definition: on
  certificates the coordinate difference really does attain the linear cost `2εμ`, not
  `O(ε²)`.  So annihilating constants is necessary but *not* sufficient for a quadratic
  price; the correct dividing line is degree of homogeneity, not order of vanishing.
-/

namespace Ma1Effective

open Finset

variable {ι : Type*} [Fintype ι] {N : ι → ℝ} {μ ε : ℝ}

/-! ## Chi-square divergence from uniform -/

section ChiSquare

variable [Nonempty ι]

/-- The exact algebraic identity behind the chi-square divergence: for a probability vector,
`n·Σ (p a − 1/n)² = n·Σ p a² − 1`. -/
theorem chiSq_eq {p : ι → ℝ} (hsum : ∑ a, p a = 1) :
    (Fintype.card ι : ℝ) * ∑ a, (p a - 1 / (Fintype.card ι : ℝ)) ^ 2
      = (Fintype.card ι : ℝ) * ∑ a, p a ^ 2 - 1 := by
  have hc : (0 : ℝ) < (Fintype.card ι : ℝ) := card_pos_real (ι := ι)
  have hexp : ∀ a : ι, (p a - 1 / (Fintype.card ι : ℝ)) ^ 2
      = p a ^ 2 - 2 * (1 / (Fintype.card ι : ℝ)) * p a + (1 / (Fintype.card ι : ℝ)) ^ 2 := by
    intro a; ring
  rw [Finset.sum_congr rfl fun a _ => hexp a, Finset.sum_add_distrib, Finset.sum_sub_distrib,
    ← Finset.mul_sum, hsum, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  field_simp
  ring

/-- **Kullback–Leibler is dominated by chi-square.**  For any positive probability vector on
the classes, `D(p‖u) ≤ n·Σ (p a − 1/n)²`.  The proof is `log t ≤ t − 1` at `t = n·p a`,
followed by `chiSq_eq`. -/
theorem kl_le_chiSq {p : ι → ℝ} (hpos : ∀ a, 0 < p a) (hsum : ∑ a, p a = 1) :
    klFromUniform p ≤ (Fintype.card ι : ℝ) * ∑ a, (p a - 1 / (Fintype.card ι : ℝ)) ^ 2 := by
  have hc : (0 : ℝ) < (Fintype.card ι : ℝ) := card_pos_real (ι := ι)
  have hpt : ∀ a ∈ (Finset.univ : Finset ι),
      p a * Real.log ((Fintype.card ι : ℝ) * p a)
        ≤ p a * ((Fintype.card ι : ℝ) * p a - 1) := by
    intro a _
    have hposa : 0 < (Fintype.card ι : ℝ) * p a := mul_pos hc (hpos a)
    exact mul_le_mul_of_nonneg_left (Real.log_le_sub_one_of_pos hposa) (le_of_lt (hpos a))
  have hstep : klFromUniform p ≤ ∑ a, p a * ((Fintype.card ι : ℝ) * p a - 1) :=
    Finset.sum_le_sum hpt
  have hrw : ∑ a, p a * ((Fintype.card ι : ℝ) * p a - 1)
      = (Fintype.card ι : ℝ) * ∑ a, p a ^ 2 - 1 := by
    have hterm : ∀ a : ι, p a * ((Fintype.card ι : ℝ) * p a - 1)
        = (Fintype.card ι : ℝ) * p a ^ 2 - p a := by intro a; ring
    rw [Finset.sum_congr rfl fun a _ => hterm a, Finset.sum_sub_distrib, ← Finset.mul_sum, hsum]
  rw [chiSq_eq hsum, ← hrw]
  exact hstep

end ChiSquare

/-! ## Two-sided control of the class probabilities -/

section Deviation

variable [Nonempty ι]

omit [Nonempty ι] in
/-- The total count is bounded above by `n(1+ε)μ`. -/
theorem total_le (h : EquiCert N μ ε) :
    ∑ b, N b ≤ (Fintype.card ι : ℝ) * ((1 + ε) * μ) := by
  calc ∑ b, N b ≤ ∑ _b : ι, (1 + ε) * μ := Finset.sum_le_sum fun b _ => h.upper b
    _ = (Fintype.card ι : ℝ) * ((1 + ε) * μ) := by
        rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

/-- The certificate bounds every class probability below by `(1−ε)/(n(1+ε))`. -/
theorem classDist_ge (h : EquiCert N μ ε) (hμ : 0 < μ) (hε : ε < 1) (a : ι) :
    (1 - ε) / ((Fintype.card ι : ℝ) * (1 + ε)) ≤ classDist N a := by
  have hc := card_pos_real (ι := ι)
  have hε0 : 0 ≤ ε := eps_nonneg_of_equiCert h hμ
  have hS : 0 < ∑ b, N b := total_pos h hμ hε
  have hup := total_le h
  have hlow := h.lower a
  have hden : (0 : ℝ) < (Fintype.card ι : ℝ) * (1 + ε) := by positivity
  unfold classDist
  rw [div_le_div_iff₀ hden hS]
  nlinarith [mul_le_mul_of_nonneg_left hup (by linarith : (0:ℝ) ≤ 1 - ε),
    mul_le_mul_of_nonneg_right hlow (by positivity : (0:ℝ) ≤ (Fintype.card ι : ℝ) * (1 + ε))]

/-- **Two-sided deviation bound.**  Under an `ε`-certificate every class probability is
within `2ε/(n(1−ε))` of the uniform value `1/n`. -/
theorem classDist_dev_abs_le (h : EquiCert N μ ε) (hμ : 0 < μ) (hε : ε < 1) (a : ι) :
    |classDist N a - 1 / (Fintype.card ι : ℝ)| ≤ 2 * ε / ((Fintype.card ι : ℝ) * (1 - ε)) := by
  have hc := card_pos_real (ι := ι)
  have hε0 : 0 ≤ ε := eps_nonneg_of_equiCert h hμ
  have h1e : (0 : ℝ) < 1 - ε := by linarith
  have hden : (0 : ℝ) < (Fintype.card ι : ℝ) * (1 - ε) := by positivity
  have hupper : classDist N a ≤ (1 + ε) / ((Fintype.card ι : ℝ) * (1 - ε)) := by
    have hb := classDist_le h hμ hε a
    have hrw : (1 + ε) * μ / ((Fintype.card ι : ℝ) * ((1 - ε) * μ))
        = (1 + ε) / ((Fintype.card ι : ℝ) * (1 - ε)) := by field_simp
    rwa [hrw] at hb
  have hlower := classDist_ge h hμ hε a
  rw [abs_le]
  constructor
  · -- `1/n − p a ≤ 2ε/(n(1+ε)) ≤ 2ε/(n(1−ε))`
    have hstep : 1 / (Fintype.card ι : ℝ) - (1 - ε) / ((Fintype.card ι : ℝ) * (1 + ε))
        ≤ 2 * ε / ((Fintype.card ι : ℝ) * (1 - ε)) := by
      rw [div_sub_div _ _ (ne_of_gt hc) (by positivity), div_le_div_iff₀ (by positivity) hden]
      nlinarith [sq_nonneg ((Fintype.card ι : ℝ) * ε), sq_nonneg ε, hc.le, mul_nonneg hc.le hε0,
        mul_nonneg (mul_nonneg hc.le hc.le) (mul_nonneg hε0 hε0)]
    linarith
  · have hstep : (1 + ε) / ((Fintype.card ι : ℝ) * (1 - ε)) - 1 / (Fintype.card ι : ℝ)
        = 2 * ε / ((Fintype.card ι : ℝ) * (1 - ε)) := by
      field_simp
      ring
    rw [← hstep]
    linarith

end Deviation

/-! ## The quadratic price at one scale -/

section QuadraticPrice

variable [Nonempty ι]

/-- **The quadratic information price of MA-1.**  An `ε`-certificate forces the empirical
class distribution to be within `(2ε/(1−ε))²` nats of uniform — the *square* of the linear
bound `2ε/(1−ε)` of cycle 3. -/
theorem kl_le_sq_of_equiCert (h : EquiCert N μ ε) (hμ : 0 < μ) (hε : ε < 1) :
    klFromUniform (classDist N) ≤ (2 * ε / (1 - ε)) ^ 2 := by
  have hc := card_pos_real (ι := ι)
  have hε0 : 0 ≤ ε := eps_nonneg_of_equiCert h hμ
  have h1e : (0 : ℝ) < 1 - ε := by linarith
  set p : ι → ℝ := classDist N with hp
  have hpos : ∀ a, 0 < p a := fun a => classDist_pos h hμ hε a
  have hsum : ∑ a, p a = 1 := classDist_sum_one h hμ hε
  have hchi := kl_le_chiSq hpos hsum
  set d : ℝ := 2 * ε / ((Fintype.card ι : ℝ) * (1 - ε)) with hd
  have hdnn : 0 ≤ d := by positivity
  have hptw : ∀ a ∈ (Finset.univ : Finset ι),
      (p a - 1 / (Fintype.card ι : ℝ)) ^ 2 ≤ d ^ 2 := by
    intro a _
    have habs := classDist_dev_abs_le h hμ hε a
    exact sq_le_sq' (by linarith [abs_le.mp habs |>.1]) (abs_le.mp habs).2
  have hsum2 : ∑ a, (p a - 1 / (Fintype.card ι : ℝ)) ^ 2 ≤ (Fintype.card ι : ℝ) * d ^ 2 := by
    calc ∑ a, (p a - 1 / (Fintype.card ι : ℝ)) ^ 2 ≤ ∑ _a : ι, d ^ 2 := Finset.sum_le_sum hptw
      _ = (Fintype.card ι : ℝ) * d ^ 2 := by
          rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  have hfin : (Fintype.card ι : ℝ) * ((Fintype.card ι : ℝ) * d ^ 2) = (2 * ε / (1 - ε)) ^ 2 := by
    rw [hd]
    field_simp
  calc klFromUniform p ≤ (Fintype.card ι : ℝ) * ∑ a, (p a - 1 / (Fintype.card ι : ℝ)) ^ 2 := hchi
    _ ≤ (Fintype.card ι : ℝ) * ((Fintype.card ι : ℝ) * d ^ 2) :=
        mul_le_mul_of_nonneg_left hsum2 hc.le
    _ = (2 * ε / (1 - ε)) ^ 2 := hfin

/-- **The numeric payload at one scale.**  At the recorded `ε = 0.000446` the class
distribution of primes below `2^30` is within `8·10⁻⁷` nats of uniform: three orders of
magnitude below the linear estimate `9·10⁻⁴` of cycle 3. -/
theorem exp509_kl_quadratic (h : EquiCert N μ 0.000446) (hμ : 0 < μ) :
    klFromUniform (classDist N) ≤ 0.0000008 := by
  have hbase := kl_le_sq_of_equiCert h hμ (by norm_num)
  have hnum : (2 * (0.000446 : ℝ) / (1 - 0.000446)) ^ 2 ≤ 0.0000008 := by norm_num
  linarith

/-- The quadratic price in its simplest form: for `ε ≤ 1/2` the divergence is at most
`16ε²` nats. -/
theorem kl_le_sixteen_eps_sq (h : EquiCert N μ ε) (hμ : 0 < μ) (hε : ε ≤ 1 / 2) :
    klFromUniform (classDist N) ≤ 16 * ε ^ 2 := by
  have hε0 : 0 ≤ ε := eps_nonneg_of_equiCert h hμ
  have hbase := kl_le_sq_of_equiCert h hμ (by linarith)
  have h1e : (0 : ℝ) < 1 - ε := by linarith
  have hq : (1 : ℝ) / 4 ≤ (1 - ε) ^ 2 := by nlinarith
  have hstep : (2 * ε / (1 - ε)) ^ 2 ≤ 16 * ε ^ 2 := by
    rw [div_pow, div_le_iff₀ (by positivity)]
    nlinarith [sq_nonneg ε, mul_le_mul_of_nonneg_left hq (by positivity : (0:ℝ) ≤ 16 * ε ^ 2)]
  linarith

end QuadraticPrice

/-! ## The quadratic total price across all scales -/

section QuadraticTotal

variable [Nonempty ι]

/-- Each scale's price is dominated by the *squared* geometric envelope. -/
theorem kl_le_geom_sq {Nf : ℕ → ι → ℝ} {m : ℕ → ℝ} {e : ℕ → ℝ} {ρ : ℝ}
    (hcert : ∀ k, EquiCert (Nf k) (m k) (e k)) (hm : ∀ k, 0 < m k) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hstep : ∀ k, e (k + 1) ≤ ρ * e k) (he0 : e 0 ≤ 1 / 2) (k : ℕ) :
    klFromUniform (classDist (Nf k)) ≤ 16 * e 0 ^ 2 * (ρ ^ 2) ^ k := by
  have hnn : ∀ j, 0 ≤ e j := fun j => eps_nonneg_of_equiCert (hcert j) (hm j)
  have hhalf := eps_le_half_of_geom hnn hρ0 hρ1 hstep he0 k
  have hbase := kl_le_sixteen_eps_sq (hcert k) (hm k) hhalf
  have hgeom := eps_geom_bound e ρ hρ0 hstep k
  have hsq : e k ^ 2 ≤ (ρ ^ k * e 0) ^ 2 := by
    have := hnn k
    nlinarith
  have hpow : (ρ ^ k * e 0) ^ 2 = e 0 ^ 2 * (ρ ^ 2) ^ k := by
    rw [mul_pow, ← pow_mul, ← pow_mul, Nat.mul_comm]
    ring
  nlinarith [hsq, hpow]

/-- The squared prices are summable. -/
theorem kl_summable_sq_of_geom {Nf : ℕ → ι → ℝ} {m : ℕ → ℝ} {e : ℕ → ℝ} {ρ : ℝ}
    (hcert : ∀ k, EquiCert (Nf k) (m k) (e k)) (hm : ∀ k, 0 < m k) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hstep : ∀ k, e (k + 1) ≤ ρ * e k) (he0 : e 0 ≤ 1 / 2) :
    Summable fun k => klFromUniform (classDist (Nf k)) :=
  kl_summable_of_geom hcert hm hρ0 hρ1 hstep he0

/-- **The quadratic total information price of MA-1.**  Summed over all dyadic scales, the
information lost to the equidistribution assumption is at most `16ε₀²/(1−ρ²)` nats — the
conjecture of cycle 4, with the explicit constant `16`. -/
theorem quadratic_total_information_price_le {Nf : ℕ → ι → ℝ} {m : ℕ → ℝ} {e : ℕ → ℝ} {ρ : ℝ}
    (hcert : ∀ k, EquiCert (Nf k) (m k) (e k)) (hm : ∀ k, 0 < m k) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hstep : ∀ k, e (k + 1) ≤ ρ * e k) (he0 : e 0 ≤ 1 / 2) :
    ∑' k, klFromUniform (classDist (Nf k)) ≤ 16 * e 0 ^ 2 / (1 - ρ ^ 2) := by
  have hρ2 : (0 : ℝ) ≤ ρ ^ 2 := sq_nonneg ρ
  have hρ2lt : ρ ^ 2 < 1 := by nlinarith
  have hsum := kl_summable_sq_of_geom hcert hm hρ0 hρ1 hstep he0
  have hmaj : Summable fun k : ℕ => 16 * e 0 ^ 2 * (ρ ^ 2) ^ k :=
    (summable_geometric_of_lt_one hρ2 hρ2lt).mul_left _
  have hle : ∑' k, klFromUniform (classDist (Nf k)) ≤ ∑' k : ℕ, 16 * e 0 ^ 2 * (ρ ^ 2) ^ k :=
    Summable.tsum_le_tsum (fun k => kl_le_geom_sq hcert hm hρ0 hρ1 hstep he0 k) hsum hmaj
  have hgeom : ∑' k : ℕ, 16 * e 0 ^ 2 * (ρ ^ 2) ^ k = 16 * e 0 ^ 2 * (1 - ρ ^ 2)⁻¹ := by
    rw [tsum_mul_left, tsum_geometric_of_lt_one hρ2 hρ2lt]
  rw [hgeom, ← div_eq_mul_inv] at hle
  exact hle

/-- **The numeric payload across all scales.**  At the recorded `ε₀ = 0.000446`, with
certificates that at worst halve from one dyadic scale to the next, the *total* information
ever lost to MA-1 is below `4.3·10⁻⁶` nats — against the `3.6·10⁻³` of the linear envelope of
cycle 4, an improvement by a factor of more than 800. -/
theorem exp509_quadratic_total_price {Nf : ℕ → ι → ℝ} {m : ℕ → ℝ} {e : ℕ → ℝ}
    (hcert : ∀ k, EquiCert (Nf k) (m k) (e k)) (hm : ∀ k, 0 < m k)
    (hstep : ∀ k, e (k + 1) ≤ (1 / 2) * e k) (he0 : e 0 ≤ 0.000446) :
    ∑' k, klFromUniform (classDist (Nf k)) ≤ 0.0000043 := by
  have hnn : 0 ≤ e 0 := eps_nonneg_of_equiCert (hcert 0) (hm 0)
  have hbase :=
    quadratic_total_information_price_le (ρ := 1 / 2) hcert hm (by norm_num) (by norm_num) hstep
      (by linarith)
  have hstep2 : 16 * e 0 ^ 2 / (1 - (1 / 2 : ℝ) ^ 2) ≤ 0.0000043 := by
    rw [div_le_iff₀ (by norm_num : (0:ℝ) < 1 - (1 / 2 : ℝ) ^ 2)]
    nlinarith
  linarith

end QuadraticTotal

/-! ## Refutation of the vanishing-order dichotomy -/

section Dichotomy

/-- **The easy half of the dichotomy is true.**  A deviation-energy readout annihilates every
constant vector. -/
theorem quadOnDeviations_annihilates {Φ : (ι → ℝ) → ℝ} {L : ℝ} (hΦ : QuadOnDeviations Φ L)
    (c : ℝ) : Φ (fun _ => c) = 0 := by
  have h := hΦ (fun _ => c) c
  simp only [sub_self] at h
  have hz : (∑ _a : ι, (0 : ℝ) ^ 2) = 0 := by simp
  rw [hz, mul_zero] at h
  exact abs_nonpos_iff.mp h

/-- The coordinate difference readout `f ↦ f a − f b`. -/
def coordDiff (a b : ι) : (ι → ℝ) → ℝ := fun f => f a - f b

omit [Fintype ι] in
/-- The coordinate difference annihilates every constant vector. -/
theorem coordDiff_annihilates (a b : ι) (c : ℝ) : coordDiff a b (fun _ => c) = 0 := by
  simp [coordDiff]

/-- **The converse half of the dichotomy is false.**  For two distinct classes the
coordinate difference annihilates the constants, yet it is *not* a deviation-energy readout
for any constant `L`: it is homogeneous of degree one, while the deviation energy is
homogeneous of degree two, so no linear bound can hold near the constants. -/
theorem coordDiff_not_quadOnDeviations {a b : ι} (hab : a ≠ b) (L : ℝ) :
    ¬ QuadOnDeviations (coordDiff a b) L := by
  classical
  intro hΦ
  set t : ℝ := 1 / (|L| + 1) with ht
  have hLnn : (0 : ℝ) ≤ |L| := abs_nonneg L
  have htpos : 0 < t := by positivity
  set f : ι → ℝ := fun x => if x = a then t else 0 with hf
  have hval : coordDiff a b f = t := by
    simp [coordDiff, hf, hab.symm]
  have hsum : ∑ x, (f x - 0) ^ 2 = t ^ 2 := by
    have hterm : ∀ x : ι, (f x - 0) ^ 2 = if x = a then t ^ 2 else 0 := by
      intro x
      by_cases hx : x = a <;> simp [hf, hx]
    rw [Finset.sum_congr rfl fun x _ => hterm x, Finset.sum_ite_eq' Finset.univ a fun _ => t ^ 2]
    simp
  have h := hΦ f 0
  rw [hval, hsum, abs_of_pos htpos] at h
  have hL : L * t ^ 2 ≤ |L| * t ^ 2 := by
    have := le_abs_self L
    nlinarith [sq_nonneg t]
  have hkey : |L| * t ^ 2 < t := by
    have hpos : (0 : ℝ) < |L| + 1 := by positivity
    have hlt : |L| * t < 1 := by
      rw [ht, mul_one_div, div_lt_one hpos]
      linarith
    calc |L| * t ^ 2 = (|L| * t) * t := by ring
      _ < 1 * t := mul_lt_mul_of_pos_right hlt htpos
      _ = t := one_mul t
  linarith

omit [Fintype ι] in
/-- **And the failure is real, not definitional.**  On certificates the coordinate difference
attains the *linear* cost `2εμ`: there is a count vector satisfying the `ε`-certificate on
which the readout equals `2εμ`, which for small `ε` dwarfs any `O(ε²)` bound. -/
theorem coordDiff_cost_linear_sharp [DecidableEq ι] {a b : ι} (hab : a ≠ b) (hμ : 0 < μ)
    (hε : 0 ≤ ε) :
    ∃ N : ι → ℝ, EquiCert N μ ε ∧ coordDiff a b N = 2 * ε * μ := by
  refine ⟨fun x => if x = a then (1 + ε) * μ else if x = b then (1 - ε) * μ else μ, ?_, ?_⟩
  · intro x
    show |(if x = a then (1 + ε) * μ else if x = b then (1 - ε) * μ else μ) - μ| ≤ ε * μ
    by_cases hx : x = a
    · rw [if_pos hx, show (1 + ε) * μ - μ = ε * μ by ring, abs_of_nonneg (by positivity)]
    · rw [if_neg hx]
      by_cases hy : x = b
      · rw [if_pos hy, show (1 - ε) * μ - μ = -(ε * μ) by ring, abs_neg,
          abs_of_nonneg (by positivity)]
      · rw [if_neg hy, sub_self, abs_zero]
        positivity
  · show ((if a = a then (1 + ε) * μ else if a = b then (1 - ε) * μ else μ)
        - (if b = a then (1 + ε) * μ else if b = b then (1 - ε) * μ else μ)) = 2 * ε * μ
    rw [if_pos rfl, if_neg (Ne.symm hab), if_pos rfl]
    ring

end Dichotomy

end Ma1Effective