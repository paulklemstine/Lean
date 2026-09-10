import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep
import Shared.PoleOrderObstructionSymmetric
import Bridges.PoleOrderNewtonLevelK

/-!
# Cycle 6: the Newton bridge — Moonshine pole recursions ⟹ classical Newton identities

`Bridges.PoleOrderNewtonLevelK` proved, for a product of `m` normalized
`q`-series `fᵢ = q⁻¹ + a₀ + a₁ q + ⋯`, the level-`k` Newton recursion
```
(k+1) c_{k+1} = ∑_{j ≤ k} c_j p_{k-j},   c_j = coeff (j - m) (∏ fᵢ),
                                          p_r = ∑ᵢ coeff r (uᵢ'/uᵢ),
```
where `uᵢ = q · fᵢ` are the unit power series of the factorization
`∏ fᵢ = q⁻ᵐ · (unit of ℂ⟦X⟧)`.

This cycle exploits the recursion in two directions.

## 1. Downward: the classical Newton identities fall out

For the *linear* normalized series `q⁻¹ + a` the unit part is `1 + aX`, whose
logarithmic derivative is the geometric series
`a/(1 + aX) = ∑_r (-1)^r a^{r+1} X^r` (`coeff_psLogDeriv_linear`).  Feeding this
into the recursion, and using that the Laurent coefficients of `∏ (q⁻¹ + aᵢ)` are
the elementary symmetric functions, gives **Newton's identity**
```
(k+1) e_{k+1} = ∑_{j ≤ k} (-1)^{k-j} e_j p_{k-j+1}
```
for arbitrary finite families of complex numbers (`newton_identity_esymm`).  So
the pole-order machinery is not merely *analogous* to symmetric-function theory:
it contains it.  `newton_identity_one` and `newton_identity_two` extract the two
classical low-degree cases `e₁ = p₁` and `2 e₂ = p₁² - p₂`.

## 2. Upward: genuine McKay–Thompson series halve the locality bound

A genuine McKay–Thompson series has *vanishing constant term*,
`T_g = q⁻¹ + 0 + c_g(1) q + ⋯`.  Cycle 5 showed that at level `k` at most `k` of
the factors interact.  Under the vanishing-constant-term normalization this
improves to `k / 2`: every exponent occurring in a surviving term is `0` or `≥ 2`
(`coeff_prod_normalized_level_no_ones`, `support_card_two_mul_le`).  For the
Monster this says the coefficient of `q^{k-194}` only sees `k / 2` of the `194`
classes (`monster_locality_half`).

## 3. Integrality transfer

The level-`k` formula is a sum of products of factor coefficients, so any
subring of `ℂ` containing all tail coefficients contains all Laurent
coefficients of the product (`coeff_prod_normalized_level_mem`).  With `R = ℤ`
this says integrality of the McKay–Thompson coefficients propagates to the whole
Moonshine product.
-/

namespace PoleOrderObstruction

open HahnSeries Finset PowerSeries

variable {ι : Type*} [DecidableEq ι]

/-! ## 1. The logarithmic derivative of a linear unit -/

/-- The linear unit `1 + aX` has constant term `1`. -/
theorem constantCoeff_linear_unit (a : ℂ) :
    PowerSeries.constantCoeff (PowerSeries.C a * PowerSeries.X + 1) = 1 := by
  rw [map_add, map_mul, PowerSeries.constantCoeff_X, mul_zero, zero_add, map_one]

/-- The geometric series `∑ (-a)ⁿ Xⁿ` inverts the linear unit `1 + aX`. -/
theorem geom_mul_linear_unit (a : ℂ) :
    PowerSeries.mk (fun n => (-a) ^ n) * (PowerSeries.C a * PowerSeries.X + 1) = 1 := by
  refine PowerSeries.ext fun n => ?_
  have hsplit : PowerSeries.mk (fun n => (-a) ^ n) * (PowerSeries.C a * PowerSeries.X + 1)
      = PowerSeries.C a * (PowerSeries.X * PowerSeries.mk (fun n => (-a) ^ n))
        + PowerSeries.mk (fun n => (-a) ^ n) := by ring
  match n with
  | 0 =>
      have hG : PowerSeries.constantCoeff (PowerSeries.mk (fun n => (-a) ^ n)) = 1 := by
        rw [← PowerSeries.coeff_zero_eq_constantCoeff_apply, PowerSeries.coeff_mk, pow_zero]
      rw [PowerSeries.coeff_zero_eq_constantCoeff_apply,
        PowerSeries.coeff_zero_eq_constantCoeff_apply, map_mul, hG,
        constantCoeff_linear_unit, one_mul, map_one]
  | (n + 1) =>
      rw [hsplit, map_add, PowerSeries.coeff_C_mul, PowerSeries.coeff_succ_X_mul,
        PowerSeries.coeff_mk, PowerSeries.coeff_mk, PowerSeries.coeff_one,
        if_neg (Nat.succ_ne_zero n)]
      ring

/-- The inverse of the linear unit `1 + aX` is the geometric series `∑ (-a)ⁿ Xⁿ`. -/
theorem inv_linear_unit (a : ℂ) :
    (PowerSeries.C a * PowerSeries.X + 1)⁻¹ = PowerSeries.mk (fun n => (-a) ^ n) := by
  have hconst : PowerSeries.constantCoeff (PowerSeries.C a * PowerSeries.X + 1) ≠ 0 := by
    rw [constantCoeff_linear_unit]
    exact one_ne_zero
  rw [PowerSeries.inv_eq_iff_mul_eq_one hconst]
  exact geom_mul_linear_unit a

/-- The derivative of the linear unit `1 + aX` is the constant `a`. -/
theorem derivative_linear_unit (a : ℂ) :
    (PowerSeries.derivative ℂ) (PowerSeries.C a * PowerSeries.X + 1) = PowerSeries.C a := by
  rw [map_add, Derivation.leibniz, PowerSeries.derivative_X, PowerSeries.derivative_C,
    Derivation.map_one_eq_zero, smul_zero, add_zero, smul_eq_mul, mul_one, add_zero]

/-- **The logarithmic derivative of a linear unit is a geometric series.**
`(1 + aX)'/(1 + aX) = ∑_r (-1)^r a^{r+1} X^r`. -/
theorem coeff_psLogDeriv_linear (a : ℂ) (r : ℕ) :
    PowerSeries.coeff r (psLogDeriv (PowerSeries.C a * PowerSeries.X + 1))
      = (-1 : ℂ) ^ r * a ^ (r + 1) := by
  rw [psLogDeriv, derivative_linear_unit, inv_linear_unit, PowerSeries.coeff_C_mul,
    PowerSeries.coeff_mk, neg_pow]
  ring

/-- The same computation for the unit part of the linear normalized series
`q⁻¹ + a`. -/
theorem coeff_psLogDeriv_normalizedPart_linTrace (a : ℂ) (r : ℕ) :
    PowerSeries.coeff r (psLogDeriv (normalizedPart (linTrace a)))
      = (-1 : ℂ) ^ r * a ^ (r + 1) := by
  rw [normalizedPart_linTrace, coeff_psLogDeriv_linear]

/-! ## 2. Newton's identities for elementary symmetric functions -/

/-- **Newton's identity, obtained from the Moonshine pole recursion.**  For any
finite family `a : ι → ℂ`,
`(k+1) e_{k+1} = ∑_{j ≤ k} (-1)^{k-j} e_j p_{k-j+1}`,
where `e_j = ∑_{|t| = j} ∏_{i ∈ t} aᵢ` and `p_r = ∑ᵢ aᵢ^r`.

The proof runs entirely through Laurent series: the `e_j` are the Laurent
coefficients of `∏ᵢ (q⁻¹ + aᵢ)`, the `p_r` come from the logarithmic derivatives
of the unit parts `1 + aᵢX`, and the identity is the level-`k` Newton recursion
of the previous cycle. -/
theorem newton_identity_esymm (s : Finset ι) (a : ι → ℂ) (k : ℕ) :
    ((k : ℂ) + 1) * (∑ t ∈ s.powersetCard (k + 1), ∏ i ∈ t, a i)
      = ∑ j ∈ Finset.range (k + 1),
          (∑ t ∈ s.powersetCard j, ∏ i ∈ t, a i) *
            ((-1 : ℂ) ^ (k - j) * ∑ i ∈ s, a i ^ (k - j + 1)) := by
  have hrec := newton_recursion_normalized s (fun i => linTrace (a i))
    (fun i _ => isNormalized_linTrace (a i)) k
  have hcast : ((k : ℤ) + 1) - (s.card : ℤ) = (((k + 1 : ℕ) : ℤ)) - (s.card : ℤ) := by
    push_cast; ring
  rw [hcast, coeff_prod_linTrace s a (k + 1)] at hrec
  rw [hrec]
  refine Finset.sum_congr rfl fun j _ => ?_
  rw [coeff_prod_linTrace s a j]
  congr 1
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun i _ => coeff_psLogDeriv_normalizedPart_linTrace (a i) (k - j)

/-- The first Newton identity `e₁ = p₁`, as an instance of the general theorem. -/
theorem newton_identity_one (s : Finset ι) (a : ι → ℂ) :
    ∑ t ∈ s.powersetCard 1, ∏ i ∈ t, a i = ∑ i ∈ s, a i := by
  have h := newton_identity_esymm s a 0
  rw [Finset.range_one, Finset.sum_singleton, Finset.powersetCard_zero,
    Finset.sum_singleton, Finset.prod_empty, Nat.cast_zero, zero_add, one_mul,
    Nat.sub_self, pow_zero, one_mul, zero_add, one_mul] at h
  rw [h]
  exact Finset.sum_congr rfl fun i _ => pow_one (a i)

/-- The second Newton identity `2 e₂ = p₁² - p₂`, as an instance of the general
theorem. -/
theorem newton_identity_two (s : Finset ι) (a : ι → ℂ) :
    2 * ∑ t ∈ s.powersetCard 2, ∏ i ∈ t, a i
      = (∑ i ∈ s, a i) * (∑ i ∈ s, a i) - ∑ i ∈ s, a i ^ 2 := by
  have h := newton_identity_esymm s a 1
  rw [Finset.sum_range_succ, Finset.sum_range_one, Finset.powersetCard_zero,
    Finset.sum_singleton, Finset.prod_empty, newton_identity_one s a,
    show ((1 : ℕ) : ℂ) + 1 = 2 by norm_num] at h
  rw [h]
  have hpow : ∑ i ∈ s, a i ^ (1 - 1 + 1) = ∑ i ∈ s, a i :=
    Finset.sum_congr rfl fun i _ => pow_one (a i)
  rw [show (1 : ℕ) - 0 = 1 from rfl, show (1 : ℕ) - 1 = 0 from rfl, pow_one, pow_zero,
    hpow, show (1 : ℕ) - 0 + 1 = 2 from rfl]
  ring

/-! ## 3. Vanishing constant terms halve the locality bound -/

/-- For genuine McKay–Thompson-shaped series (vanishing constant term) every
exponent vector containing a `1` contributes `0`, so the level-`k` sum runs over
exponent vectors with all entries `0` or `≥ 2`. -/
theorem coeff_prod_normalized_level_no_ones (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) (h0 : ∀ i ∈ s, (f i).coeff 0 = 0) (k : ℕ) :
    (∏ i ∈ s, f i).coeff ((k : ℤ) - (s.card : ℤ))
      = ∑ ν ∈ s.finsuppAntidiag k with ∀ i ∈ s, ν i ≠ 1,
          ∏ i ∈ s, (f i).coeff ((ν i : ℤ) - 1) := by
  rw [coeff_prod_normalized_level s f h k]
  refine (Finset.sum_filter_of_ne ?_).symm
  intro ν _ hne i hi hone
  refine hne (Finset.prod_eq_zero hi ?_)
  rw [hone, Nat.cast_one, sub_self]
  exact h0 i hi

/-- **Half locality.**  An exponent vector of weight `k` avoiding the value `1`
has support of size at most `k / 2`. -/
theorem support_card_two_mul_le {s : Finset ι} {k : ℕ} {ν : ι →₀ ℕ}
    (hν : ν ∈ s.finsuppAntidiag k) (h1 : ∀ i ∈ s, ν i ≠ 1) :
    2 * ν.support.card ≤ k := by
  rw [Finset.mem_finsuppAntidiag] at hν
  obtain ⟨hsum, hsupp⟩ := hν
  have hres : ∑ i ∈ ν.support, ν i = k := by
    rw [← hsum]
    exact Finset.sum_subset hsupp (by intro x _ hx; simpa using hx)
  calc 2 * ν.support.card = ∑ _i ∈ ν.support, 2 := by
        rw [Finset.sum_const, smul_eq_mul]; ring
    _ ≤ ∑ i ∈ ν.support, ν i := by
        refine Finset.sum_le_sum fun i hi => ?_
        have hne0 : ν i ≠ 0 := by simpa using hi
        have hne1 : ν i ≠ 1 := h1 i (hsupp hi)
        omega
    _ = k := hres

set_option maxRecDepth 10000 in
/-- **Monster half locality.**  For the `194` genuine McKay–Thompson series
(constant terms `0`) only exponent vectors supported on at most `k / 2` of the
classes contribute to the coefficient at degree `k - 194`. -/
theorem monster_locality_half (k : ℕ) (ν : Fin monsterClassCount →₀ ℕ)
    (hν : ν ∈ (Finset.univ : Finset (Fin monsterClassCount)).finsuppAntidiag k)
    (h1 : ∀ i, ν i ≠ 1) :
    2 * ν.support.card ≤ k :=
  support_card_two_mul_le hν (fun i _ => h1 i)

/-- **Monster half locality, term form.**  For the Monster product with
vanishing constant terms, any exponent vector that excites some factor exactly
once contributes `0` to the level-`k` sum.  Together with
`monster_locality_half` this says that only exponent vectors supported on at
most `k / 2` of the `194` classes survive. -/
theorem monster_term_eq_zero_of_one (c : Fin monsterClassCount → ℕ → ℂ)
    (h0 : ∀ i, c i 0 = 0) (ν : Fin monsterClassCount →₀ ℕ) (i : Fin monsterClassCount)
    (h1 : ν i = 1) :
    ∏ j, (traceLaurent (c j)).coeff ((ν j : ℤ) - 1) = 0 := by
  refine Finset.prod_eq_zero (Finset.mem_univ i) ?_
  rw [h1, Nat.cast_one, sub_self]
  have hc := coeff_traceLaurent (c i) 0
  rw [Nat.cast_zero] at hc
  rw [hc, h0 i]

/-! ## 4. Integrality transfer -/

/-- **Integrality transfer.**  If every coefficient of every factor lies in a
subring `R ⊆ ℂ`, then so does every Laurent coefficient of the product.  With
`R = ℤ` this is the statement that integrality of McKay–Thompson coefficients
propagates through the Moonshine product. -/
theorem coeff_prod_normalized_level_mem (R : Subring ℂ) (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) (hR : ∀ i ∈ s, ∀ n : ℤ, (f i).coeff n ∈ R) (k : ℕ) :
    (∏ i ∈ s, f i).coeff ((k : ℤ) - (s.card : ℤ)) ∈ R := by
  rw [coeff_prod_normalized_level s f h k]
  exact Subring.sum_mem R fun ν _ => Subring.prod_mem R fun i hi => hR i hi _

/-- The Monster instance of integrality transfer. -/
theorem coeff_prod_traceLaurent_194_mem (R : Subring ℂ) (c : Fin monsterClassCount → ℕ → ℂ)
    (hR : ∀ i (n : ℕ), c i n ∈ R) (k : ℕ) :
    (∏ i, traceLaurent (c i)).coeff ((k : ℤ) - 194) ∈ R := by
  have hcoeff : ∀ i ∈ (Finset.univ : Finset (Fin monsterClassCount)), ∀ n : ℤ,
      (traceLaurent (c i)).coeff n ∈ R := by
    intro i _ n
    rcases lt_or_ge n 0 with hneg | hpos
    · rcases eq_or_lt_of_le (by omega : n ≤ -1) with hm1 | hlt
      · rw [hm1, (isNormalized_traceLaurent (c i)).coeff_neg_one]
        exact one_mem R
      · rw [(isNormalized_traceLaurent (c i)).coeff_eq_zero_of_lt n (by omega)]
        exact zero_mem R
    · obtain ⟨m, rfl⟩ : ∃ m : ℕ, n = (m : ℤ) := ⟨n.toNat, by omega⟩
      rw [coeff_traceLaurent]
      exact hR i m
  have h := coeff_prod_normalized_level_mem R (Finset.univ : Finset (Fin monsterClassCount))
    (fun i => traceLaurent (c i)) (fun i _ => isNormalized_traceLaurent (c i)) hcoeff k
  rw [Finset.card_univ, Fintype.card_fin,
    show ((monsterClassCount : ℕ) : ℤ) = (194 : ℤ) from by norm_num [monsterClassCount]] at h
  exact h

/-! ## 5. Lab notes

Two numerical instances computed inside Lean from the general theorems.

* The logarithmic derivative of `1 + 2X` has `X³`-coefficient `(-1)³·2⁴ = -16`.
* Half locality: for two McKay–Thompson-shaped factors with vanishing constant
  terms, `f = q⁻¹ + 3q + 4q²` and `g = q⁻¹ + 7q + 9q²`, the level-`3`
  coefficient (degree `1`) is `4 + 9 = 13`.  Only one factor is excited at a
  time, exactly as the bound `2 · |support| ≤ 3` predicts. -/

/-- Lab note: `coeff 3 ((1+2X)'/(1+2X)) = -16`. -/
theorem lab_note_logDeriv_linear :
    PowerSeries.coeff 3 (psLogDeriv (PowerSeries.C (2 : ℂ) * PowerSeries.X + 1)) = -16 := by
  rw [coeff_psLogDeriv_linear]
  norm_num

/-- Lab note: half locality in action.  For two normalized series with vanishing
constant terms the level-`3` coefficient is `a₂ + b₂`; with `a₂ = 4`, `b₂ = 9`
this is `13`. -/
theorem lab_note_half_locality :
    (traceLaurent (fun n => if n = 1 then (3 : ℂ) else if n = 2 then 4 else 0) *
      traceLaurent (fun n => if n = 1 then (7 : ℂ) else if n = 2 then 9 else 0)).coeff (1 : ℤ)
      = 13 := by
  set a : ℕ → ℂ := fun n => if n = 1 then (3 : ℂ) else if n = 2 then 4 else 0 with ha
  set b : ℕ → ℂ := fun n => if n = 1 then (7 : ℂ) else if n = 2 then 9 else 0 with hb
  have h := coeff_mul_normalized_level (traceLaurent a) (traceLaurent b)
    (isNormalized_traceLaurent a) (isNormalized_traceLaurent b) 3
  rw [show ((3 : ℕ) : ℤ) - 2 = (1 : ℤ) by norm_num] at h
  rw [h]
  have hm1 : ∀ c : ℕ → ℂ, (traceLaurent c).coeff (-1 : ℤ) = 1 :=
    fun c => (isNormalized_traceLaurent c).coeff_neg_one
  have hc0 : ∀ c : ℕ → ℂ, (traceLaurent c).coeff (0 : ℤ) = c 0 := fun c => by
    have := coeff_traceLaurent c 0
    rwa [Nat.cast_zero] at this
  have hc1 : ∀ c : ℕ → ℂ, (traceLaurent c).coeff (1 : ℤ) = c 1 := fun c => by
    have := coeff_traceLaurent c 1
    rwa [Nat.cast_one] at this
  have hc2 : ∀ c : ℕ → ℂ, (traceLaurent c).coeff (2 : ℤ) = c 2 := fun c => by
    have := coeff_traceLaurent c 2
    norm_num at this
    exact this
  rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_one]
  norm_num [hm1, hc0, hc1, hc2, ha, hb]

end PoleOrderObstruction