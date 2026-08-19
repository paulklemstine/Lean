import Mathlib

/-!
# The pole-order obstruction for products of normalized `q`-series

A *normalized* Laurent series (in the sense used for McKay–Thompson series of
Monstrous Moonshine) is a series of the shape

`f = q⁻¹ + a₀ + a₁ q + a₂ q² + ⋯`

i.e. a Laurent series over `ℂ` whose coefficient at `-1` equals `1` and whose
coefficients in degrees `< -1` all vanish.  Every McKay–Thompson series `T_g`
of the Monster has this shape.

The theme of this file is the *pole-order obstruction*: normalized series are
**not** closed under multiplication, and the obstruction is measured exactly by
the additive valuation `orderTop`.  Concretely:

* `PoleOrderObstruction.orderTop_prod_normalized` — a product of `m` normalized
  series has `orderTop` exactly `-m`;
* `PoleOrderObstruction.prod_isNormalized_iff` — hence the product is again
  normalized **iff** `m = 1`;
* `PoleOrderObstruction.prod_notMem_range_ofPowerSeries` — for `m ≥ 1` the
  product is genuinely not a power series (it has a pole);
* `PoleOrderObstruction.orderTop_qPow_mul_prod` — multiplying by `q ^ m`
  restores `orderTop = 0`, and `PoleOrderObstruction.orderTop_qPow_mul_prod_eq_zero_iff`
  shows `m` is the *unique* exponent that does so;
* `PoleOrderObstruction.isUnit_normalizedProduct` — the corrected product
  `q ^ m * ∏ fᵢ` is the image of a **unit** of `ℂ⟦X⟧`, so the correction lands
  in the group of units of the power-series ring, not merely in the ring;
* `PoleOrderObstruction.coeff_prod_normalized_subleading` — the subleading
  Laurent coefficient of the product, at degree `1 - m`, is the *sum* of the
  constant terms of the factors.  (For genuine McKay–Thompson series, whose
  constant terms are `0`, this subleading coefficient therefore vanishes.)

Specializing to the Monster simple group, which has `194` conjugacy classes and
hence `194` McKay–Thompson series, gives
`PoleOrderObstruction.orderTop_prod_traceLaurent_194`: the full Monstrous
Moonshine product has a pole of order exactly `194`.

All of this is developed over `LaurentSeries ℂ = HahnSeries ℤ ℂ`, using the
Hahn-series valuation machinery of Mathlib.
-/

namespace PoleOrderObstruction

open HahnSeries Finset

/-- The ambient ring: Laurent series in `q` over `ℂ`. -/
abbrev LC := LaurentSeries ℂ

/-- The uniformizer `q`, i.e. the Laurent series `q = q¹`. -/
noncomputable def qSeries : LC := HahnSeries.single (1 : ℤ) (1 : ℂ)

@[simp] theorem coeff_qSeries (n : ℤ) :
    (qSeries).coeff n = if n = 1 then (1 : ℂ) else 0 := by
  simp [qSeries, HahnSeries.coeff_single]

theorem qSeries_ne_zero : qSeries ≠ 0 := by
  intro h
  have := congrArg (fun x : LC => x.coeff 1) h
  simp at this

@[simp] theorem orderTop_qSeries : (qSeries).orderTop = ((1 : ℤ) : WithTop ℤ) := by
  simp [qSeries, HahnSeries.orderTop_single (Γ := ℤ) (a := (1 : ℤ)) (one_ne_zero (α := ℂ))]

theorem qSeries_pow (m : ℕ) : qSeries ^ m = HahnSeries.single (m : ℤ) (1 : ℂ) := by
  simp [qSeries, HahnSeries.single_pow]

@[simp] theorem orderTop_qSeries_pow (m : ℕ) :
    (qSeries ^ m).orderTop = ((m : ℤ) : WithTop ℤ) := by
  rw [qSeries_pow]
  exact HahnSeries.orderTop_single (one_ne_zero (α := ℂ))

/-! ## Normalized series -/

/-- A Laurent series is *normalized* when it has the shape `q⁻¹ + a₀ + a₁ q + ⋯`:
the coefficient in degree `-1` is `1`, and all coefficients in degrees `< -1`
vanish.  This is the shape of every McKay–Thompson series of the Monster. -/
structure IsNormalized (f : LC) : Prop where
  /-- The `q⁻¹`-coefficient is `1`. -/
  coeff_neg_one : f.coeff (-1) = 1
  /-- Nothing below `q⁻¹`. -/
  coeff_eq_zero_of_lt : ∀ n : ℤ, n < -1 → f.coeff n = 0

namespace IsNormalized

variable {f : LC}

theorem ne_zero (h : IsNormalized f) : f ≠ 0 := by
  intro hf
  have := h.coeff_neg_one
  rw [hf] at this
  simp at this

theorem orderTop_eq (h : IsNormalized f) : f.orderTop = ((-1 : ℤ) : WithTop ℤ) := by
  refine HahnSeries.orderTop_eq_of_le (g := (-1 : ℤ)) ?_ ?_
  · simp [HahnSeries.mem_support, h.coeff_neg_one]
  · intro g' hg'
    by_contra hlt
    push_neg at hlt
    exact (HahnSeries.mem_support _ _).mp hg' (h.coeff_eq_zero_of_lt g' hlt)

theorem order_eq (h : IsNormalized f) : f.order = (-1 : ℤ) := by
  have := h.orderTop_eq
  rw [← HahnSeries.order_eq_orderTop_of_ne_zero h.ne_zero] at this
  exact_mod_cast this

theorem leadingCoeff_eq (h : IsNormalized f) : f.leadingCoeff = 1 := by
  rw [HahnSeries.leadingCoeff_eq, h.order_eq, h.coeff_neg_one]

end IsNormalized

/-! ## The main pole-order computation -/

variable {ι : Type*}

/-- The leading coefficient of a product of normalized series is `1`. -/
theorem leadingCoeff_prod_normalized (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) : (∏ i ∈ s, f i).leadingCoeff = 1 := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih =>
      rw [Finset.prod_insert ha, HahnSeries.leadingCoeff_mul,
        (h a (Finset.mem_insert_self a s)).leadingCoeff_eq,
        ih (fun i hi => h i (Finset.mem_insert_of_mem hi)), one_mul]

/-- A product of normalized series is nonzero. -/
theorem prod_normalized_ne_zero (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) : (∏ i ∈ s, f i) ≠ 0 := by
  intro hzero
  have := leadingCoeff_prod_normalized s f h
  rw [hzero] at this
  simp at this

/-- **Pole-order theorem.** A product of `m = s.card` normalized `q`-series has
`orderTop` exactly `-m`: the poles add up, with no cancellation. -/
theorem orderTop_prod_normalized (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) :
    (∏ i ∈ s, f i).orderTop = ((-(s.card : ℤ) : ℤ) : WithTop ℤ) := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih =>
      rw [Finset.prod_insert ha, HahnSeries.orderTop_mul,
        (h a (Finset.mem_insert_self a s)).orderTop_eq,
        ih (fun i hi => h i (Finset.mem_insert_of_mem hi)),
        Finset.card_insert_of_notMem ha, ← WithTop.coe_add]
      norm_num

/-- The same statement for `order` rather than `orderTop`. -/
theorem order_prod_normalized (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) :
    (∏ i ∈ s, f i).order = -(s.card : ℤ) := by
  have h0 := HahnSeries.order_eq_orderTop_of_ne_zero (prod_normalized_ne_zero s f h)
  have h1 := orderTop_prod_normalized s f h
  rw [← h0] at h1
  exact_mod_cast h1

/-- **Non-closure.** A product of normalized series is normalized precisely when
there is exactly one factor: the pole order is a complete obstruction. -/
theorem prod_isNormalized_iff (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) :
    IsNormalized (∏ i ∈ s, f i) ↔ s.card = 1 := by
  constructor
  · intro hp
    have h1 := hp.orderTop_eq
    rw [orderTop_prod_normalized s f h] at h1
    have : (-(s.card : ℤ)) = (-1 : ℤ) := by exact_mod_cast h1
    omega
  · intro hcard
    obtain ⟨a, rfl⟩ := Finset.card_eq_one.mp hcard
    simpa using h a (Finset.mem_singleton_self a)

/-- For a nonempty family, the product really is not a power series: it lies
outside the image of `ℂ⟦X⟧ → ℂ⸨X⸩`. -/
theorem prod_notMem_range_ofPowerSeries (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) (hs : s.Nonempty) :
    (∏ i ∈ s, f i) ∉ Set.range (HahnSeries.ofPowerSeries ℤ ℂ) := by
  rintro ⟨x, hx⟩
  have hcard : 0 < (s.card : ℤ) := by exact_mod_cast Finset.card_pos.mpr hs
  have hcoeff : (∏ i ∈ s, f i).coeff (-(s.card : ℤ)) = 1 := by
    have := leadingCoeff_prod_normalized s f h
    rwa [HahnSeries.leadingCoeff_eq, order_prod_normalized s f h] at this
  rw [← hx] at hcoeff
  rw [show (HahnSeries.ofPowerSeries ℤ ℂ) x = ((x : PowerSeries ℂ) : LC) from rfl,
    PowerSeries.coeff_coe, if_pos (by omega)] at hcoeff
  exact zero_ne_one hcoeff

/-! ## Restoring order `0` by multiplying with `q ^ m` -/

/-- Multiplying the product by `q ^ m`, with `m` the number of factors, exactly
cancels the pole. -/
theorem orderTop_qPow_mul_prod (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) :
    (qSeries ^ s.card * ∏ i ∈ s, f i).orderTop = 0 := by
  rw [HahnSeries.orderTop_mul, orderTop_qSeries_pow, orderTop_prod_normalized s f h,
    ← WithTop.coe_add]
  norm_num

/-- `m` is the **unique** exponent restoring order `0`. -/
theorem orderTop_qPow_mul_prod_eq_zero_iff (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) (k : ℕ) :
    (qSeries ^ k * ∏ i ∈ s, f i).orderTop = 0 ↔ k = s.card := by
  rw [HahnSeries.orderTop_mul, orderTop_qSeries_pow, orderTop_prod_normalized s f h,
    ← WithTop.coe_add]
  constructor
  · intro hk
    have : ((k : ℤ) + -(s.card : ℤ)) = 0 := by exact_mod_cast hk
    omega
  · rintro rfl
    norm_num

/-- The leading coefficient survives the correction. -/
theorem leadingCoeff_qPow_mul_prod (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) :
    (qSeries ^ s.card * ∏ i ∈ s, f i).leadingCoeff = 1 := by
  rw [HahnSeries.leadingCoeff_mul, qSeries_pow, HahnSeries.leadingCoeff_of_single,
    leadingCoeff_prod_normalized s f h, one_mul]

/-! ## The corrected product as a unit power series

We upgrade "order `0`" to a genuinely structural statement: `q * f` is the image
of a power series with constant term `1` for every normalized `f`, hence a unit
of `ℂ⟦X⟧`, and the corrected Monster-type product `q ^ m * ∏ fᵢ` is the image of
the corresponding product of units. -/

/-- The power series `q * f` attached to a normalized Laurent series `f`. -/
noncomputable def normalizedPart (f : LC) : PowerSeries ℂ :=
  (qSeries * f).powerSeriesPart

theorem order_qSeries_mul (f : LC) (h : IsNormalized f) : (qSeries * f).order = 0 := by
  have hne : qSeries * f ≠ 0 := mul_ne_zero qSeries_ne_zero h.ne_zero
  have := HahnSeries.orderTop_mul (R := ℂ) qSeries f
  rw [orderTop_qSeries, h.orderTop_eq, ← WithTop.coe_add,
    ← HahnSeries.order_eq_orderTop_of_ne_zero hne] at this
  have : ((qSeries * f).order : ℤ) = (1 : ℤ) + (-1 : ℤ) := by exact_mod_cast this
  omega

theorem ofPowerSeries_normalizedPart (f : LC) (h : IsNormalized f) :
    HahnSeries.ofPowerSeries ℤ ℂ (normalizedPart f) = qSeries * f := by
  rw [normalizedPart, LaurentSeries.ofPowerSeries_powerSeriesPart, order_qSeries_mul f h]
  simp

@[simp] theorem constantCoeff_normalizedPart (f : LC) (h : IsNormalized f) :
    PowerSeries.constantCoeff (normalizedPart f) = 1 := by
  rw [PowerSeries.coeff_zero_eq_constantCoeff.symm, normalizedPart,
    LaurentSeries.powerSeriesPart_coeff, order_qSeries_mul f h]
  rw [show ((0 : ℤ) + ((0 : ℕ) : ℤ)) = (0 : ℤ) by norm_num]
  rw [qSeries, show (0 : ℤ) = 0 by rfl, HahnSeries.coeff_single_mul]
  simpa using h.coeff_neg_one

theorem coeff_one_normalizedPart (f : LC) (h : IsNormalized f) :
    PowerSeries.coeff 1 (normalizedPart f) = f.coeff 0 := by
  rw [normalizedPart, LaurentSeries.powerSeriesPart_coeff, order_qSeries_mul f h]
  rw [show ((0 : ℤ) + ((1 : ℕ) : ℤ)) = (1 : ℤ) by norm_num]
  rw [qSeries, HahnSeries.coeff_single_mul]
  simp

/-- Every normalized series becomes a **unit** power series after multiplication
by `q`. -/
theorem isUnit_normalizedPart (f : LC) (h : IsNormalized f) :
    IsUnit (normalizedPart f) :=
  PowerSeries.isUnit_iff_constantCoeff.mpr
    (by rw [constantCoeff_normalizedPart f h]; exact isUnit_one)

/-- The corrected product `q ^ m * ∏ fᵢ` is the image of the power series
`∏ normalizedPart (fᵢ)`. -/
theorem ofPowerSeries_prod_normalizedPart (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) :
    HahnSeries.ofPowerSeries ℤ ℂ (∏ i ∈ s, normalizedPart (f i))
      = qSeries ^ s.card * ∏ i ∈ s, f i := by
  classical
  rw [map_prod]
  rw [Finset.prod_congr rfl (fun i hi => ofPowerSeries_normalizedPart (f i) (h i hi))]
  rw [Finset.prod_mul_distrib, Finset.prod_const]

/-- **Unit structure of the corrected product.** The `q ^ m`-corrected product of
`m` normalized series is the image of a unit of `ℂ⟦X⟧`. -/
theorem isUnit_normalizedProduct (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) :
    IsUnit (∏ i ∈ s, normalizedPart (f i)) ∧
      HahnSeries.ofPowerSeries ℤ ℂ (∏ i ∈ s, normalizedPart (f i))
        = qSeries ^ s.card * ∏ i ∈ s, f i := by
  refine ⟨?_, ofPowerSeries_prod_normalizedPart s f h⟩
  exact Finset.prod_induction _ _ (fun _ _ => IsUnit.mul) isUnit_one
    (fun i hi => isUnit_normalizedPart (f i) (h i hi))

/-! ## The subleading Laurent coefficient -/

/-- For power series all of whose constant terms are `1`, the linear coefficient
of the product is the sum of the linear coefficients. -/
theorem coeff_one_prod_of_constantCoeff_one (s : Finset ι) (g : ι → PowerSeries ℂ)
    (h : ∀ i ∈ s, PowerSeries.constantCoeff (g i) = 1) :
    PowerSeries.coeff 1 (∏ i ∈ s, g i) = ∑ i ∈ s, PowerSeries.coeff 1 (g i) := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih =>
      have hconst : PowerSeries.constantCoeff (∏ i ∈ s, g i) = 1 := by
        rw [map_prod, Finset.prod_congr rfl (fun i hi => h i (Finset.mem_insert_of_mem hi)),
          Finset.prod_const_one]
      rw [Finset.prod_insert ha, PowerSeries.coeff_one_mul, hconst,
        h a (Finset.mem_insert_self a s), ih (fun i hi => h i (Finset.mem_insert_of_mem hi)),
        Finset.sum_insert ha]
      ring

/-- **Subleading coefficient.** For a product of `m` normalized series the
coefficient in degree `1 - m` — one step above the pole — is the sum of the
constant terms `a₀` of the factors.  In particular, for genuine McKay–Thompson
series (whose constant terms vanish) this coefficient is `0`. -/
theorem coeff_prod_normalized_subleading (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) :
    (∏ i ∈ s, f i).coeff (1 - (s.card : ℤ)) = ∑ i ∈ s, (f i).coeff 0 := by
  classical
  have hkey : PowerSeries.coeff 1 (∏ i ∈ s, normalizedPart (f i))
      = ∑ i ∈ s, (f i).coeff 0 := by
    rw [coeff_one_prod_of_constantCoeff_one s _
      (fun i hi => constantCoeff_normalizedPart (f i) (h i hi))]
    exact Finset.sum_congr rfl (fun i hi => coeff_one_normalizedPart (f i) (h i hi))
  have hcoe : (HahnSeries.ofPowerSeries ℤ ℂ (∏ i ∈ s, normalizedPart (f i))).coeff (1 : ℤ)
      = PowerSeries.coeff 1 (∏ i ∈ s, normalizedPart (f i)) := by
    simpa using HahnSeries.ofPowerSeries_apply_coeff
      (Γ := ℤ) (∏ i ∈ s, normalizedPart (f i)) 1
  rw [ofPowerSeries_prod_normalizedPart s f h] at hcoe
  rw [qSeries_pow, HahnSeries.coeff_single_mul, one_mul] at hcoe
  rw [hcoe, hkey]

/-! ## Concrete normalized series and the Monster -/

/-- The Laurent series `q⁻¹ + ∑_{n ≥ 0} c n qⁿ`.  This is the shape of a
normalized McKay–Thompson (trace) series. -/
noncomputable def traceLaurent (c : ℕ → ℂ) : LC :=
  HahnSeries.single (-1 : ℤ) (1 : ℂ) + HahnSeries.ofPowerSeries ℤ ℂ (PowerSeries.mk c)

theorem isNormalized_traceLaurent (c : ℕ → ℂ) : IsNormalized (traceLaurent c) := by
  constructor
  · have h1 : (HahnSeries.ofPowerSeries ℤ ℂ (PowerSeries.mk c)).coeff (-1 : ℤ) = 0 := by
      rw [show (HahnSeries.ofPowerSeries ℤ ℂ) (PowerSeries.mk c)
            = ((PowerSeries.mk c : PowerSeries ℂ) : LC) from rfl,
        PowerSeries.coeff_coe, if_pos (by norm_num)]
    simp [traceLaurent, h1]
  · intro n hn
    have h1 : (HahnSeries.ofPowerSeries ℤ ℂ (PowerSeries.mk c)).coeff n = 0 := by
      rw [show (HahnSeries.ofPowerSeries ℤ ℂ) (PowerSeries.mk c)
            = ((PowerSeries.mk c : PowerSeries ℂ) : LC) from rfl,
        PowerSeries.coeff_coe, if_pos (by omega)]
    have h2 : n ≠ (-1 : ℤ) := by omega
    simp [traceLaurent, h1, h2]

/-- The number of conjugacy classes of the Monster simple group `𝕄`, equal to
the number of McKay–Thompson series appearing in Monstrous Moonshine. -/
def monsterClassCount : ℕ := 194

/-- **Monster-sized pole.** A product of `194` normalized `q`-series — one for
each conjugacy class of the Monster — has a pole of order exactly `194`. -/
theorem orderTop_prod_normalized_194 (T : Fin monsterClassCount → LC)
    (h : ∀ i, IsNormalized (T i)) :
    (∏ i, T i).orderTop = ((-194 : ℤ) : WithTop ℤ) := by
  have := orderTop_prod_normalized Finset.univ T (fun i _ => h i)
  simpa [monsterClassCount] using this

/-- The same statement for the concrete trace-series model: the product of the
`194` McKay–Thompson-shaped series `q⁻¹ + ∑ c_g(n) qⁿ` has `orderTop = -194`. -/
theorem orderTop_prod_traceLaurent_194 (c : Fin monsterClassCount → ℕ → ℂ) :
    (∏ i, traceLaurent (c i)).orderTop = ((-194 : ℤ) : WithTop ℤ) :=
  orderTop_prod_normalized_194 _ (fun i => isNormalized_traceLaurent (c i))

/-- Multiplying the Monster-sized product by `q ^ 194` restores order `0`. -/
theorem orderTop_q194_mul_prod_traceLaurent (c : Fin monsterClassCount → ℕ → ℂ) :
    (qSeries ^ 194 * ∏ i, traceLaurent (c i)).orderTop = 0 := by
  have := orderTop_qPow_mul_prod Finset.univ (fun i => traceLaurent (c i))
    (fun i _ => isNormalized_traceLaurent (c i))
  simpa [monsterClassCount] using this

/-- `194` is the unique exponent with that property. -/
theorem orderTop_qPow_mul_prod_traceLaurent_eq_zero_iff
    (c : Fin monsterClassCount → ℕ → ℂ) (k : ℕ) :
    (qSeries ^ k * ∏ i, traceLaurent (c i)).orderTop = 0 ↔ k = 194 := by
  have := orderTop_qPow_mul_prod_eq_zero_iff Finset.univ (fun i => traceLaurent (c i))
    (fun i _ => isNormalized_traceLaurent (c i)) k
  simpa [monsterClassCount] using this

/-- The Monster-sized product is not a power series: it has a genuine pole. -/
theorem prod_traceLaurent_194_notMem_range (c : Fin monsterClassCount → ℕ → ℂ) :
    (∏ i, traceLaurent (c i)) ∉ Set.range (HahnSeries.ofPowerSeries ℤ ℂ) :=
  prod_notMem_range_ofPowerSeries Finset.univ _
    (fun i _ => isNormalized_traceLaurent (c i))
    ⟨⟨0, by norm_num [monsterClassCount]⟩, Finset.mem_univ _⟩

/-- Subleading coefficient of the Monster-sized product: at degree `-193` it is
the sum of the `194` constant terms.  For honest McKay–Thompson series, which
are normalized to have constant term `0`, this coefficient vanishes. -/
theorem coeff_prod_traceLaurent_194_subleading (c : Fin monsterClassCount → ℕ → ℂ) :
    (∏ i, traceLaurent (c i)).coeff (-193 : ℤ)
      = ∑ i, (traceLaurent (c i)).coeff 0 := by
  have := coeff_prod_normalized_subleading Finset.univ (fun i => traceLaurent (c i))
    (fun i _ => isNormalized_traceLaurent (c i))
  simpa [monsterClassCount] using this

/-- The constant term of `traceLaurent c` is `c 0`. -/
@[simp] theorem coeff_zero_traceLaurent (c : ℕ → ℂ) : (traceLaurent c).coeff 0 = c 0 := by
  have h1 : (HahnSeries.ofPowerSeries ℤ ℂ (PowerSeries.mk c)).coeff (0 : ℤ) = c 0 := by
    simpa using HahnSeries.ofPowerSeries_apply_coeff (Γ := ℤ) (PowerSeries.mk c) 0
  simp [traceLaurent, h1]

/-- **Moonshine normalization.** If every trace series has vanishing constant
term (the standard normalization of McKay–Thompson series), the Monster-sized
product has vanishing subleading coefficient: its Laurent expansion begins
`q⁻¹⁹⁴ + 0 · q⁻¹⁹³ + ⋯`. -/
theorem coeff_prod_traceLaurent_194_subleading_eq_zero
    (c : Fin monsterClassCount → ℕ → ℂ) (hc : ∀ i, c i 0 = 0) :
    (∏ i, traceLaurent (c i)).coeff (-193 : ℤ) = 0 := by
  rw [coeff_prod_traceLaurent_194_subleading]
  simp [hc]

/-- The leading coefficient of the Monster-sized product is `1`: it is
`q⁻¹⁹⁴ + ⋯`. -/
theorem leadingCoeff_prod_traceLaurent_194 (c : Fin monsterClassCount → ℕ → ℂ) :
    (∏ i, traceLaurent (c i)).leadingCoeff = 1 :=
  leadingCoeff_prod_normalized Finset.univ _ (fun i _ => isNormalized_traceLaurent (c i))

end PoleOrderObstruction