/-
# The Thermodynamic Horizon of Discovery

A finite alphabet generates *countably infinitely* many statements, yet any
physically realizable enumerator has a finite operation budget.  This file makes
several strands of that picture precise and proves them in full.

The recurring model is deliberately elementary: the discoverable statements up to
"index" `N` are the first `N` naturals, a finite *budget* is a finite set (or a
finite element of `ℝ≥0∞`), and the *discoverable fraction* is `|discovered|/N`.

Results:

* `statements_countable` / `statements_infinite` — the statements over a finite
  alphabet (`List (Fin (k+1))`) form a countably infinite type.
* `discoverable_fraction_tendsto_zero` — a finite budget has discoverable
  fraction tending to `0` (the "measure zero of the discoverable set").
* `discoverable_fraction_upper_bound` / `discoverable_fraction_reciprocal_lower` —
  the decay is exactly of order `1/N`: bounded above by `|S|/N` and, once `N`
  exceeds every discovered index, bounded below by `1/N`.
* `robustness_finite_iff` — replacing the budget by *any* value in `ℝ≥0∞`, the
  discoverable fraction tends to `0` **iff** the budget is finite; a positive
  limit requires an actually infinite budget.  This is the finite-versus-infinite
  dichotomy: the growth *law* is irrelevant.
* `area_law_crossover` — for area-law (quadratic-in-mass) capacity `c·m²` versus a
  linear budget `L·m`, the quadratic dominates exactly at and above the crossover
  mass `L/c`.
* `linear_over_quadratic_tendsto_zero` — above the crossover the linear budget is
  an asymptotically vanishing fraction of the area-law capacity.
* `discovery_comparison_factors` — between any two countably infinite systems the
  comparison bijection factors through the shared enumeration of `ℕ`
  (countability transfer).
-/

import Mathlib

open Filter Topology

namespace ThermodynamicHorizon

/-! ## Countable infinitude of the statements -/

/--
The statements over a finite alphabet with `k+1` symbols — modelled as finite
strings `List (Fin (k+1))` — form a **countable** type.
-/
theorem statements_countable (k : ℕ) : Countable (List (Fin (k + 1))) := by
  infer_instance

/--
The statements over a finite alphabet with `k+1` symbols form an **infinite**
type: arbitrarily long strings exist.  Together with `statements_countable` this
is the "countably infinite collection of statements over a finite alphabet".
-/
theorem statements_infinite (k : ℕ) : Infinite (List (Fin (k + 1))) := by
  exact Infinite.of_injective ( fun n => List.replicate n 0 ) fun a b h => by simpa using congr_arg List.length h;

/-! ## Discoverable fraction of a finite budget -/

/--
The discoverable fraction of a finite budget `S` up to index `N` is at most
`|S|/N`.
-/
theorem discoverable_fraction_upper_bound (S : Finset ℕ) (N : ℕ) :
    ((S.filter (· < N)).card : ℝ) / N ≤ (S.card : ℝ) / N := by
  gcongr ; aesop

/--
**Measure zero of the discoverable set.** For any finite budget `S` the
discoverable fraction `|S ∩ [0,N)| / N` tends to `0` as the enumeration index
`N → ∞`.
-/
theorem discoverable_fraction_tendsto_zero (S : Finset ℕ) :
    Tendsto (fun N : ℕ => ((S.filter (· < N)).card : ℝ) / N) atTop (𝓝 0) := by
  refine' squeeze_zero_norm' _ _;
  exacts [ fun n => ( S.card : ℝ ) / n, Filter.eventually_atTop.mpr ⟨ 1, fun n hn => by rw [ Real.norm_of_nonneg ( by positivity ) ] ; exact div_le_div_of_nonneg_right ( mod_cast Finset.card_filter_le _ _ ) ( by positivity ) ⟩, tendsto_const_nhds.div_atTop tendsto_natCast_atTop_atTop ]

/--
**Optimality of the `1/N` rate.** Once the index `N` exceeds every discovered
element of a nonempty budget `S`, the discoverable fraction is at least `1/N`, so
the decay is no faster than the reciprocal of the index.
-/
theorem discoverable_fraction_reciprocal_lower (S : Finset ℕ) (hS : S.Nonempty)
    (N : ℕ) (hN : ∀ x ∈ S, x < N) :
    (1 : ℝ) / N ≤ ((S.filter (· < N)).card : ℝ) / N := by
  gcongr;
  exact_mod_cast Finset.card_pos.mpr ⟨ _, Finset.mem_filter.mpr ⟨ hS.choose_spec, hN _ hS.choose_spec ⟩ ⟩

/-! ## Robustness: the finite-versus-infinite dichotomy -/

/--
**Robustness of fraction-zero.** Modelling the total budget as a value
`s : ℝ≥0∞`, the discoverable fraction `s / N` tends to `0` **iff** `s` is finite.
The decay is controlled purely by finiteness of the budget, not by any growth
law: a positive limit is possible only for an actually infinite budget.
-/
theorem robustness_finite_iff (s : ENNReal) :
    Tendsto (fun N : ℕ => s / (N : ENNReal)) atTop (𝓝 0) ↔ s ≠ ⊤ := by
  by_cases hs : s = ⊤ <;> simp_all +decide [ division_def ];
  convert ENNReal.Tendsto.const_mul ( ENNReal.tendsto_inv_nat_nhds_zero ) _ using 1 ; aesop;
  tauto

/-! ## Area-law capacity versus a linear budget -/

/--
**Crossover mass.** For area-law (quadratic-in-mass) capacity `c·m²` with
`c > 0` and a linear budget `L·m` (any coefficient `L`), the quadratic capacity
meets or exceeds the linear budget, at nonnegative mass `m`, exactly at the origin
or at and above the crossover mass `L/c`.
-/
theorem area_law_crossover (c L m : ℝ) (hc : 0 < c) (hm : 0 ≤ m) :
    L * m ≤ c * m ^ 2 ↔ (m = 0 ∨ L / c ≤ m) := by
  constructor
  · intro h
    refine or_iff_not_imp_left.mpr fun hm' => ?_
    rw [div_le_iff₀ hc]
    nlinarith [mul_self_pos.mpr hm']
  · rintro (rfl | h)
    · nlinarith
    · rw [div_le_iff₀ hc] at h
      nlinarith

/--
**Area-law dominance.** Above the crossover the linear budget is an
asymptotically vanishing fraction of the area-law capacity: `(L·m)/(c·m²) → 0`
as `m → ∞`.
-/
theorem linear_over_quadratic_tendsto_zero (c L : ℝ) (hc : 0 < c) :
    Tendsto (fun m : ℝ => (L * m) / (c * m ^ 2)) atTop (𝓝 0) := by
  have h : Tendsto (fun m : ℝ => (L / c) * m⁻¹) atTop (𝓝 0) := by
    simpa using tendsto_inv_atTop_zero.const_mul (L / c)
  refine h.congr' ?_
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with m hm
  field_simp

/-! ## Countability transfer across systems -/

/--
**Countability transfer.** Between any two countably infinite deductive
systems `α` and `β` there is a comparison bijection that factors through the
shared enumeration of `ℕ`: it is exactly "encode in `α`, decode in `β`".  Thus
relative discovery rates are governed by a single syntax-free comparison.
-/
theorem discovery_comparison_factors (α β : Type) [Denumerable α] [Denumerable β] :
    ∃ f : α ≃ β, ∀ a : α,
      f a = (Denumerable.eqv β).symm (Denumerable.eqv α a) := by
  exact ⟨(Denumerable.eqv α).trans (Denumerable.eqv β).symm, fun _ => rfl⟩

end ThermodynamicHorizon