import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep
import Cryptography.PoleOrderSplitting

/-!
# Cycle 7: normalized series form a torsor, and `q^{m-1}` re-normalizes a product

The running theme of cycles 1–6 is that the pole order of a product of `m`
normalized `q`-series is a complete, rigid and indestructible obstruction to the
product being normalized again.  This cycle closes the loop by describing the
*repair*: which multiplication turns the product back into a **normalized**
series (not merely a power series), and how much freedom there is in the choice.

* `PoleOrderTorsor.isNormalized_iff` — a clean characterization: `f` is
  normalized iff `f ≠ 0`, `order f = -1` and `leadingCoeff f = 1`.  This replaces
  the coefficient-wise definition by a valuation-theoretic one.
* `PoleOrderTorsor.isNormalized_qPow_mul_prod` — for a product of `m ≥ 1`
  normalized series, multiplying by `q ^ (m - 1)` — one power *less* than the
  correction to order `0` — lands back in the set of normalized series.  So the
  set of normalized series is not a monoid but it is stable under the corrected
  product operation `(f, g) ↦ q · f · g`.
* `PoleOrderTorsor.isNormalized_monsterProd_q193` — the Monster case: `q ^ 193`
  times the `194`-fold moonshine product is again a McKay–Thompson-shaped series.
* `PoleOrderTorsor.exists_unique_ratio` — the set of normalized series is a
  **torsor** under the group of power series with constant term `1`: for any two
  normalized `f, g` there is a *unique* power series `u` with constant term `1`
  and `f = u · g`.  Hence normalized series form a principal homogeneous space,
  the group being exactly the blinding group of cycle 3.
-/

namespace PoleOrderTorsor

open HahnSeries Finset PoleOrderObstruction PoleOrderSplitting

variable {ι : Type*}

/-! ## 1. A valuation-theoretic characterization of normalization -/

theorem isNormalized_iff (f : LC) :
    IsNormalized f ↔ f ≠ 0 ∧ f.order = (-1 : ℤ) ∧ f.leadingCoeff = 1 := by
  constructor
  · intro h
    exact ⟨h.ne_zero, h.order_eq, h.leadingCoeff_eq⟩
  · rintro ⟨hne, hord, hlead⟩
    refine ⟨?_, ?_⟩
    · rw [HahnSeries.leadingCoeff_eq, hord] at hlead
      exact hlead
    · intro n hn
      refine HahnSeries.coeff_eq_zero_of_lt_orderTop ?_
      rw [← HahnSeries.order_eq_orderTop_of_ne_zero hne, hord]
      exact_mod_cast hn

/-! ## 2. `q ^ (m-1)` re-normalizes a product of `m` normalized series -/

/-- Multiplying a product of `m` normalized series by `q ^ (m - 1)` gives back a
normalized series: the pole is trimmed from order `m` to order `1`, and the
leading coefficient stays `1`. -/
theorem isNormalized_qPow_mul_prod (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) (k : ℕ) (hk : s.card = k + 1) :
    IsNormalized (qSeries ^ k * ∏ i ∈ s, f i) := by
  have hprod_ne : (∏ i ∈ s, f i) ≠ 0 := prod_normalized_ne_zero s f h
  have hq_ne : (qSeries ^ k : LC) ≠ 0 := pow_ne_zero _ qSeries_ne_zero
  have hne : (qSeries ^ k * ∏ i ∈ s, f i) ≠ 0 := mul_ne_zero hq_ne hprod_ne
  refine (isNormalized_iff _).mpr ⟨hne, ?_, ?_⟩
  · have hqord : (qSeries ^ k : LC).order = (k : ℤ) := by
      rw [qSeries_pow]
      have hs : (HahnSeries.single (k : ℤ) (1 : ℂ) : LC) ≠ 0 :=
        HahnSeries.single_ne_zero one_ne_zero
      have := HahnSeries.orderTop_single (Γ := ℤ) (a := (k : ℤ)) (one_ne_zero (α := ℂ))
      rw [← HahnSeries.order_eq_orderTop_of_ne_zero hs] at this
      exact_mod_cast this
    rw [order_mul_of_ne_zero' hq_ne hprod_ne, hqord, order_prod_normalized s f h, hk]
    push_cast
    ring
  · rw [HahnSeries.leadingCoeff_mul, qSeries_pow, HahnSeries.leadingCoeff_of_single,
      leadingCoeff_prod_normalized s f h, one_mul]

/-- The corrected product of two normalized series, `q · f · g`, is normalized:
the set of normalized series carries the binary operation `(f, g) ↦ q · f · g`. -/
theorem isNormalized_q_mul_mul {f g : LC} (hf : IsNormalized f) (hg : IsNormalized g) :
    IsNormalized (qSeries * (f * g)) := by
  classical
  have h := isNormalized_qPow_mul_prod (Finset.univ : Finset (Fin 2)) ![f, g]
    (by intro i _; fin_cases i <;> simpa) 1 (by simp)
  simpa [Fin.prod_univ_two] using h

/-- **Monster case.**  `q ^ 193` times the `194`-fold moonshine product is again a
normalized (McKay–Thompson-shaped) series. -/
theorem isNormalized_monsterProd_q193 (c : Fin monsterClassCount → ℕ → ℂ) :
    IsNormalized (qSeries ^ 193 * ∏ i, traceLaurent (c i)) :=
  isNormalized_qPow_mul_prod Finset.univ (fun i => traceLaurent (c i))
    (fun i _ => isNormalized_traceLaurent (c i)) 193 (by simp [monsterClassCount])

/-! ## 3. Normalized series form a torsor under the blinding group -/

/-- **Torsor structure.**  For any two normalized series `f, g` there is a unique
power series `u` with constant term `1` such that `f = u · g`.  The group of such
`u` — exactly the blinding group of cycle 3, up to the scalar `ℂˣ` — acts simply
transitively on the set of normalized series. -/
theorem exists_unique_ratio {f g : LC} (hf : IsNormalized f) (hg : IsNormalized g) :
    ∃! u : PowerSeries ℂ, PowerSeries.constantCoeff u = 1 ∧
      f = HahnSeries.ofPowerSeries ℤ ℂ u * g := by
  classical
  have hgu : IsUnit (normalizedPart g) := isUnit_normalizedPart g hg
  set v : (PowerSeries ℂ)ˣ := hgu.unit with hv
  refine ⟨normalizedPart f * ((v⁻¹ : (PowerSeries ℂ)ˣ) : PowerSeries ℂ), ⟨?_, ?_⟩, ?_⟩
  · have h1 : PowerSeries.constantCoeff (normalizedPart f) = 1 :=
      constantCoeff_normalizedPart f hf
    have h2 : PowerSeries.constantCoeff ((v : PowerSeries ℂ)) = 1 := by
      rw [hv]
      exact constantCoeff_normalizedPart g hg
    have h3 : PowerSeries.constantCoeff ((v : PowerSeries ℂ)) *
        PowerSeries.constantCoeff ((v⁻¹ : (PowerSeries ℂ)ˣ) : PowerSeries ℂ) = 1 := by
      rw [← map_mul]
      simp
    rw [map_mul, h1, one_mul]
    rw [h2, one_mul] at h3
    exact h3
  · have hgq : HahnSeries.ofPowerSeries ℤ ℂ (normalizedPart g) = qSeries * g :=
      ofPowerSeries_normalizedPart g hg
    have hfq : HahnSeries.ofPowerSeries ℤ ℂ (normalizedPart f) = qSeries * f :=
      ofPowerSeries_normalizedPart f hf
    have hvv : HahnSeries.ofPowerSeries ℤ ℂ ((v : PowerSeries ℂ)) *
        HahnSeries.ofPowerSeries ℤ ℂ (((v⁻¹ : (PowerSeries ℂ)ˣ)) : PowerSeries ℂ) = 1 := by
      rw [← map_mul]
      simp
    have hqg : HahnSeries.ofPowerSeries ℤ ℂ ((v : PowerSeries ℂ)) = qSeries * g := by
      rw [hv]; exact hgq
    have key : HahnSeries.ofPowerSeries ℤ ℂ
        (normalizedPart f * ((v⁻¹ : (PowerSeries ℂ)ˣ) : PowerSeries ℂ)) * (qSeries * g)
        = qSeries * f := by
      rw [map_mul, ← hqg, mul_assoc, mul_comm (HahnSeries.ofPowerSeries ℤ ℂ
        (((v⁻¹ : (PowerSeries ℂ)ˣ)) : PowerSeries ℂ)), ← mul_assoc _ _
        (HahnSeries.ofPowerSeries ℤ ℂ (((v⁻¹ : (PowerSeries ℂ)ˣ)) : PowerSeries ℂ)),
        mul_assoc, hvv, mul_one, hfq]
    have hqne : (qSeries : LC) ≠ 0 := qSeries_ne_zero
    refine mul_left_cancel₀ hqne ?_
    rw [← key]
    ring
  · rintro w ⟨hw1, hw2⟩
    have hgne : g ≠ 0 := hg.ne_zero
    have hfw : HahnSeries.ofPowerSeries ℤ ℂ w * g
        = HahnSeries.ofPowerSeries ℤ ℂ
            (normalizedPart f * ((v⁻¹ : (PowerSeries ℂ)ˣ) : PowerSeries ℂ)) * g := by
      rw [← hw2]
      have hgq : HahnSeries.ofPowerSeries ℤ ℂ (normalizedPart g) = qSeries * g :=
        ofPowerSeries_normalizedPart g hg
      have hfq : HahnSeries.ofPowerSeries ℤ ℂ (normalizedPart f) = qSeries * f :=
        ofPowerSeries_normalizedPart f hf
      have hvv : HahnSeries.ofPowerSeries ℤ ℂ (((v⁻¹ : (PowerSeries ℂ)ˣ)) : PowerSeries ℂ)
          * (qSeries * g) = 1 := by
        rw [← hgq, ← map_mul, hv]
        simp
      have hqne : (qSeries : LC) ≠ 0 := qSeries_ne_zero
      refine mul_left_cancel₀ hqne ?_
      rw [map_mul]
      calc qSeries * f = HahnSeries.ofPowerSeries ℤ ℂ (normalizedPart f) := hfq.symm
        _ = HahnSeries.ofPowerSeries ℤ ℂ (normalizedPart f) * 1 := by rw [mul_one]
        _ = HahnSeries.ofPowerSeries ℤ ℂ (normalizedPart f) *
              (HahnSeries.ofPowerSeries ℤ ℂ
                (((v⁻¹ : (PowerSeries ℂ)ˣ)) : PowerSeries ℂ) * (qSeries * g)) := by
              rw [hvv]
        _ = qSeries * (HahnSeries.ofPowerSeries ℤ ℂ (normalizedPart f) *
              HahnSeries.ofPowerSeries ℤ ℂ
                (((v⁻¹ : (PowerSeries ℂ)ˣ)) : PowerSeries ℂ) * g) := by ring
    have := mul_right_cancel₀ hgne hfw
    exact HahnSeries.ofPowerSeries_injective (Γ := ℤ) this

end PoleOrderTorsor