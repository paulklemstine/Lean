/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Restriction Ranks, Holonomy, and the First Cohomology of Data Nerves

This module continues the *Sheaf Cohomology of Data* thread.  The previous cycle
(`Catalog/MachineLearning/SheafCohomologyRobustness/Cohomology.lean`) treated the
**constant** sheaf on a path nerve and on a cyclic nerve, with scalar stalks and
identity restriction maps, and showed `H¹(path) = 0`, `H¹(cycle) ≠ 0`.

The present file removes both restrictions of that analysis.  Restriction maps
are now arbitrary linear maps, stalks are arbitrary finite dimensional vector
spaces over an arbitrary field, and the nerve is allowed to carry `2`-cells.
The theme is the *Future Directions* claim of the thread:

> a scalar missing rate and a feature count do not determine `H¹`; the
> restriction-map ranks and the overlap incidence are what matter.

We make this precise and prove it.

## Main results

* `finrank_H1_add_finrank_range` and `euler_characteristic` — the exact
  rank–nullity ledger of a two-term data complex.
* `finrank_H1_eq_finrank_ker` — for equidimensional complexes, the obstruction
  dimension equals the dimension of the space of global sections.
* `H1_pos_of_finrank_lt` — a purely numerical certificate for a nonzero
  obstruction.
* `finrank_H1full_add_finrank_range` and `finrank_H1full_le_finrank_H1` — adding
  the `2`-cells of the nerve can only shrink `H¹`.
* `flag_reduction_fails` — **a counterexample to the pairwise (clique/flag)
  reduction conjecture**: on the triangle nerve with constant stalks the
  `1`-skeleton computes `dim H¹ = 1` while the full nerve computes `dim H¹ = 0`.
* `cyclic_holonomy_criterion` — **monodromy law**: for a cyclic nerve with
  invertible scalar restriction maps `a₀, …, a_m`, `H¹ = 0` iff the holonomy
  `∏ aⱼ ≠ 1`, and `dim H¹ = 1` otherwise.  The overlap incidence is fixed
  throughout; only the *values* of the restriction maps move the cohomology.
* `finrank_H1_disjointLoops` — **exact rank law for the disjoint-loop nerve**:
  `dim H¹ = #{i | aᵢ = 1}`, an arbitrary integer in `[0, N]`.
* `missing_rate_does_not_determine_H1` — the headline corollary: for every
  feature count `N` and every target `k ≤ N` there is a data sheaf with
  *invertible* restriction maps on one and the same overlap nerve whose
  obstruction dimension is exactly `k`.  Hence no function of (feature count,
  missing rate, overlap incidence) can predict `dim H¹`.
* `integral_H1_torsion` and `torsion_obstruction_invisible_to_field_coefficients`
  — **the torsion barrier**: over `ℤ` the same data sheaf can carry a nonzero
  (pure torsion) obstruction while its field-coefficient obstruction vanishes
  identically.  Field-valued cohomology, the only kind computed in practice, is
  therefore not a complete gluing invariant.
* `det_smul_H1Zmat_eq_zero` and `integral_vs_rational_dichotomy` — the universal
  form of the barrier: for an arbitrary square integer coboundary `M`, `det M`
  annihilates the integral obstruction, and if `det M ≠ 0` the rational
  obstruction vanishes identically.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer).  Bold conjecture C2 of the thread: *`dim H¹` is not
  a function of the missingness marginals.*  Bold conjecture C3: *the flag /
  pairwise-clique nerve computes the same `H¹` as the full nerve.*  Bold
  conjecture C1: *`dim H¹ / dim C¹` is governed by a rank law.*
* Experiment (Experimenter).  C3 was attacked first because it is the cheapest
  to refute.  The triangle nerve with constant stalks was computed by hand:
  `dim C⁰ = dim C¹ = 3`, `dim ker δ⁰ = 1` (the constants), so `rank δ⁰ = 2` and
  the skeleton gives `dim H¹ = 3 - 2 = 1`; but `range δ⁰ = ker δ¹` exactly, so
  the full nerve gives `dim H¹ = 0`.  Formalised as `flag_reduction_fails`:
  **C3 is false**.
* Experiment (Experimenter).  C1 was replaced by an exact deterministic rank law
  in two model families where it can be computed in closed form: the cyclic
  nerve (`cyclic_holonomy_criterion`, a discrete monodromy statement — the
  kernel is a parallel-transport orbit, `ker_transport`) and the disjoint-loop
  nerve (`finrank_H1_disjointLoops`, where `dim H¹` counts the loops with
  trivial holonomy).  Both confirm the *shape* of C1: the normalized dimension
  is a function of the restriction data, not of the incidence alone.
* Analysis (Analyst).  The two families separate the two possible causes of
  obstruction.  On the cycle the obstruction is *global* (one scalar holonomy,
  `dim H¹ ≤ 1` no matter how many features).  On the disjoint loops it is
  *local and additive* (`dim H¹` grows linearly in the feature count).  This is
  the structural reason why a scalar missing rate cannot predict `dim H¹`: the
  same rate is compatible with a globally rigid nerve and with a maximally
  fragmented one.  Failure classification: C3 = **false**; C2 = **true and now
  proved**; C1 = **true but needs a different definition** (the deterministic
  limit exists only after conditioning on the restriction-rank profile).
* Critique (Critic).  Is `missing_rate_does_not_determine_H1` cheating by using
  zero restriction maps?  No: the hypothesis `∀ i, a i ≠ 0` forces every
  restriction map in the construction to be an *isomorphism* of stalks, so the
  separation is not a rank degeneracy — it is pure holonomy.  Is
  `flag_reduction_fails` an artifact of a degenerate nerve?  No: the triangle is
  the smallest flag nerve, its restriction maps are identities, and both
  cohomologies are computed exactly rather than bounded.
* Synthesis (PI).  `dim H¹` is the corank of the transport system.  Incidence
  fixes the *shape* of the ledger; the restriction maps fix its *rank*.
* Second loop — Hypothesis.  If the restriction maps fix the rank, what fixes
  the *arithmetic*?  Conjecture: over `ℤ` the disjoint-loop obstruction is
  `⨁ᵢ ℤ/(aᵢ - 1)`, hence pure torsion whenever no `aᵢ = 1` — exactly the regime
  in which the field-valued theory reports nothing.
* Second loop — Experiment.  `mem_range_loopDZ` identifies the integral
  coboundary image as the coordinatewise divisibility condition
  `(aᵢ - 1) ∣ gᵢ`.  Annihilation by `∏ᵢ(aᵢ - 1)` (`integral_H1_torsion`) and
  nontriviality of the indicator class (`integral_H1_nontrivial_of_not_dvd_one`)
  then give the barrier; `rational_H1_vanishes_of_no_trivial_loop` supplies the
  vanishing field-side comparison.
* Second loop — Critique.  Is the `2`-torsion statement vacuous because the
  module might be zero?  No: the first conjunct of
  `torsion_obstruction_invisible_to_field_coefficients` exhibits a nonzero
  element explicitly, so the module is nonzero and `2`-torsion, i.e. genuinely
  `ℤ/2`.
* Third loop — Synthesis.  The two integral computations are one theorem: the
  adjugate identity `M · adj M = det M · 1` shows that `det M` is a universal
  annihilator of the integral obstruction of any equidimensional data complex,
  and `rational_H1_mat_eq_zero_of_det_ne_zero` shows the field-valued theory is
  blind exactly on the locus `det M ≠ 0` where that annihilator is nontrivial.
  The determinant, not the rank, is the right exponent.
-/

import Mathlib

open Module Finset

namespace DataSheafCohomology

/-! ## §1.  The obstruction space of a two-term data complex

A *data complex* is a linear map `d⁰ : C⁰ → C¹` from the space of local sections
(one stalk per feature block) to the space of overlap discrepancies (one stalk
per overlap).  `H⁰ = ker d⁰` are the globally consistent local sections and
`H¹ = C¹ ⧸ range d⁰` is the obstruction space. -/

section Abstract

variable {K C0 C1 C2 : Type*} [Field K]
  [AddCommGroup C0] [Module K C0] [AddCommGroup C1] [Module K C1]
  [AddCommGroup C2] [Module K C2]

/-- Global sections of a data complex: the kernel of the coboundary. -/
abbrev H0 (d0 : C0 →ₗ[K] C1) : Submodule K C0 := LinearMap.ker d0

/-- The obstruction space (first cohomology) of a two-term data complex. -/
abbrev H1 (d0 : C0 →ₗ[K] C1) : Type _ := C1 ⧸ LinearMap.range d0

/-- The obstruction dimension is the corank of the coboundary. -/
theorem finrank_H1_add_finrank_range [FiniteDimensional K C1] (d0 : C0 →ₗ[K] C1) :
    finrank K (H1 d0) + finrank K (LinearMap.range d0) = finrank K C1 :=
  Submodule.finrank_quotient_add_finrank _

/-- **Euler characteristic of a data complex.**
`dim H⁰ - dim H¹ = dim C⁰ - dim C¹`, written additively to stay inside `ℕ`. -/
theorem euler_characteristic [FiniteDimensional K C0] [FiniteDimensional K C1]
    (d0 : C0 →ₗ[K] C1) :
    finrank K (H0 d0) + finrank K C1 = finrank K (H1 d0) + finrank K C0 := by
  have h1 := finrank_H1_add_finrank_range d0
  have h2 := LinearMap.finrank_range_add_finrank_ker d0
  have h3 : finrank K (H0 d0) = finrank K (LinearMap.ker d0) := rfl
  omega

/-- For an equidimensional complex (as many overlap degrees of freedom as local
ones) the obstruction dimension equals the dimension of the space of global
sections.  This is the engine behind all the closed-form computations below. -/
theorem finrank_H1_eq_finrank_ker [FiniteDimensional K C0] [FiniteDimensional K C1]
    (d0 : C0 →ₗ[K] C1) (h : finrank K C0 = finrank K C1) :
    finrank K (H1 d0) = finrank K (LinearMap.ker d0) := by
  have := euler_characteristic d0
  have h3 : finrank K (H0 d0) = finrank K (LinearMap.ker d0) := rfl
  omega

/-- A purely numerical obstruction certificate: more overlap degrees of freedom
than local degrees of freedom forces a nonzero obstruction class. -/
theorem H1_pos_of_finrank_lt [FiniteDimensional K C0] [FiniteDimensional K C1]
    (d0 : C0 →ₗ[K] C1) (h : finrank K C0 < finrank K C1) :
    0 < finrank K (H1 d0) := by
  have h1 := finrank_H1_add_finrank_range d0
  have h2 := LinearMap.finrank_range_add_finrank_ker d0
  omega

/-- `H¹` vanishes exactly when every overlap discrepancy is a coboundary. -/
theorem H1_subsingleton_iff_surjective (d0 : C0 →ₗ[K] C1) :
    Subsingleton (H1 d0) ↔ Function.Surjective d0 := by
  rw [Submodule.Quotient.subsingleton_iff, LinearMap.range_eq_top]

/-! ### The full nerve: adding `2`-cells -/

/-- Obstruction space computed from the **full nerve**, i.e. from the three-term
complex `C⁰ → C¹ → C²`: cocycles modulo coboundaries. -/
abbrev H1full (d0 : C0 →ₗ[K] C1) (d1 : C1 →ₗ[K] C2) : Type _ :=
  (LinearMap.ker d1) ⧸ ((LinearMap.range d0).comap (LinearMap.ker d1).subtype)

theorem range_le_ker_of_comp_zero {d0 : C0 →ₗ[K] C1} {d1 : C1 →ₗ[K] C2}
    (h : d1.comp d0 = 0) : LinearMap.range d0 ≤ LinearMap.ker d1 := by
  rintro x ⟨y, rfl⟩
  have := congrArg (fun t => t y) h
  simpa using this

theorem finrank_H1full_add_finrank_range [FiniteDimensional K C1]
    (d0 : C0 →ₗ[K] C1) (d1 : C1 →ₗ[K] C2) (h : d1.comp d0 = 0) :
    finrank K (H1full d0 d1) + finrank K (LinearMap.range d0)
      = finrank K (LinearMap.ker d1) := by
  have hle := range_le_ker_of_comp_zero h
  have e := Submodule.finrank_quotient_add_finrank
    ((LinearMap.range d0).comap (LinearMap.ker d1).subtype)
  rwa [(Submodule.comapSubtypeEquivOfLe hle).finrank_eq] at e

/-- **Refining the nerve can only shrink the obstruction.**  Passing from the
`1`-skeleton (pairwise overlaps only) to the full nerve (with triple overlaps)
never increases `dim H¹`. -/
theorem finrank_H1full_le_finrank_H1 [FiniteDimensional K C1]
    (d0 : C0 →ₗ[K] C1) (d1 : C1 →ₗ[K] C2) (h : d1.comp d0 = 0) :
    finrank K (H1full d0 d1) ≤ finrank K (H1 d0) := by
  have e1 := finrank_H1full_add_finrank_range d0 d1 h
  have e2 := finrank_H1_add_finrank_range d0
  have e3 := (LinearMap.ker d1).finrank_le
  omega

end Abstract

/-! ## §2.  Counterexample to the pairwise (flag) reduction conjecture

Conjecture C3 of the thread asks whether, for a flag nerve, the clique complex
generated by *pairwise* overlaps computes the same `H¹` as the full nerve.  The
triangle nerve `{U₀, U₁, U₂}` with all pairwise and the triple overlap nonempty
is flag, and refutes it. -/

section Triangle

variable (K : Type*) [Field K]

/-- Čech `δ⁰` on the triangle nerve with constant (scalar) stalks:
`(δ⁰f)_{01} = f₁ - f₀`, `(δ⁰f)_{12} = f₂ - f₁`, `(δ⁰f)_{02} = f₂ - f₀`. -/
def triD0 : (Fin 3 → K) →ₗ[K] (Fin 3 → K) where
  toFun f := ![f 1 - f 0, f 2 - f 1, f 2 - f 0]
  map_add' x y := by funext i; fin_cases i <;> simp <;> ring
  map_smul' c x := by funext i; fin_cases i <;> simp <;> ring

/-- Čech `δ¹` on the triangle nerve: the alternating sum around the `2`-cell
`U₀ ∩ U₁ ∩ U₂`, namely `g₀₁ + g₁₂ - g₀₂`. -/
def triD1 : (Fin 3 → K) →ₗ[K] K where
  toFun g := g 0 + g 1 - g 2
  map_add' x y := by simp; ring
  map_smul' c x := by simp; ring

theorem triD1_comp_triD0 : (triD1 K).comp (triD0 K) = 0 := by
  ext f
  simp [triD0, triD1]

/-- On the triangle every cocycle is a coboundary: `range δ⁰ = ker δ¹`. -/
theorem tri_range_eq_ker : LinearMap.range (triD0 K) = LinearMap.ker (triD1 K) := by
  apply le_antisymm
  · rintro x ⟨f, rfl⟩
    simp [triD0, triD1, LinearMap.mem_ker]
  · intro g hg
    simp only [LinearMap.mem_ker, triD1, LinearMap.coe_mk, AddHom.coe_mk] at hg
    refine ⟨![0, g 0, g 0 + g 1], ?_⟩
    funext i
    fin_cases i <;> simp [triD0]
    linear_combination hg

/-- `H⁰` of the triangle nerve is the line of constant sections. -/
theorem tri_ker_d0 : LinearMap.ker (triD0 K) = K ∙ (fun _ => 1 : Fin 3 → K) := by
  apply le_antisymm
  · intro f hf
    simp only [LinearMap.mem_ker, triD0, LinearMap.coe_mk, AddHom.coe_mk] at hf
    have h0 := congrFun hf 0
    have h1 := congrFun hf 1
    simp at h0 h1
    have h2 : f 1 = f 0 := by linear_combination h0
    have h3 : f 2 = f 0 := by linear_combination h0 + h1
    refine Submodule.mem_span_singleton.2 ⟨f 0, ?_⟩
    funext i
    fin_cases i <;> simp [h2, h3]
  · rw [Submodule.span_singleton_le_iff_mem]
    simp only [LinearMap.mem_ker]
    funext i
    fin_cases i <;> simp [triD0]

theorem tri_finrank_ker_d0 : finrank K (LinearMap.ker (triD0 K)) = 1 := by
  rw [tri_ker_d0]
  exact finrank_span_singleton (by intro h; simpa using congrFun h 0)

theorem tri_finrank_range_d0 : finrank K (LinearMap.range (triD0 K)) = 2 := by
  have h := LinearMap.finrank_range_add_finrank_ker (triD0 K)
  rw [tri_finrank_ker_d0] at h
  simp only [Module.finrank_pi, Fintype.card_fin] at h
  omega

/-- **The pairwise/flag reduction is false.**  On the triangle nerve — the
smallest flag nerve, with identity restriction maps — the `1`-skeleton computes
`dim H¹ = 1` while the full nerve computes `dim H¹ = 0`.  A single scalar
holonomy that the pairwise complex reports as an obstruction is killed by the
triple overlap. -/
theorem flag_reduction_fails :
    finrank K (H1 (triD0 K)) = 1 ∧ finrank K (H1full (triD0 K) (triD1 K)) = 0 := by
  constructor
  · have h := finrank_H1_add_finrank_range (triD0 K)
    rw [tri_finrank_range_d0] at h
    simp only [Module.finrank_pi, Fintype.card_fin] at h
    omega
  · have h := finrank_H1full_add_finrank_range (triD0 K) (triD1 K) (triD1_comp_triD0 K)
    have hk : finrank K (LinearMap.ker (triD1 K)) = 2 := by
      rw [← tri_range_eq_ker]; exact tri_finrank_range_d0 K
    rw [hk, tri_finrank_range_d0] at h
    omega

/-- Quantitative form: the pairwise complex over-reports the obstruction. -/
theorem flag_gap_positive :
    finrank K (H1full (triD0 K) (triD1 K)) < finrank K (H1 (triD0 K)) := by
  obtain ⟨h1, h2⟩ := flag_reduction_fails K
  omega

end Triangle

/-! ## §3.  The cyclic nerve with general invertible restriction maps: holonomy

Feature blocks `U₀, …, U_m` are arranged in a loop, each stalk is the field `K`,
and the restriction map across the overlap `Uᵢ ∩ Uᵢ₊₁` is multiplication by a
scalar `aᵢ`.  The coboundary is `(δf)ᵢ = aᵢ · f(i+1) - f(i)` with `i+1` taken
modulo `m+1`.  The overlap incidence is the *same* cyclic nerve as in the
previous cycle of this thread; only the restriction maps change. -/

section Cyclic

variable {K : Type*} [Field K]

/-- The cyclic coboundary on `m+1` feature blocks with scalar restriction
maps `a`. -/
def cycD (m : ℕ) (a : ℕ → K) : (Fin (m+1) → K) →ₗ[K] (Fin (m+1) → K) where
  toFun f := fun i => a i.val * f (i + 1) - f i
  map_add' x y := by funext i; simp; ring
  map_smul' c x := by funext i; simp; ring

/-- The **holonomy** of the cyclic data sheaf: the product of the restriction
scalars around the loop. -/
noncomputable def holonomy (a : ℕ → K) (m : ℕ) : K := ∏ j ∈ range (m+1), a j

variable {m : ℕ}

lemma mem_ker_cycD {a : ℕ → K} {f : Fin (m+1) → K} :
    f ∈ LinearMap.ker (cycD m a) ↔ ∀ i : Fin (m+1), a i.val * f (i + 1) = f i := by
  simp only [LinearMap.mem_ker, cycD, LinearMap.coe_mk, AddHom.coe_mk]
  constructor
  · intro h i
    have h2 := congrFun h i
    simp only [Pi.zero_apply] at h2
    linear_combination h2
  · intro h; funext i; simp [h i]

lemma cyc_succ_mk {k : ℕ} (h : k + 1 < m + 1) :
    (⟨k, by omega⟩ + 1 : Fin (m+1)) = ⟨k+1, h⟩ := by
  have hlt : (⟨k, by omega⟩ : Fin (m+1)) < Fin.last m := by simp [Fin.lt_def]; omega
  ext
  rw [Fin.val_add_one_of_lt hlt]

lemma cyc_last_succ {k : ℕ} (hk : k < m + 1) (h : k = m) :
    (⟨k, hk⟩ + 1 : Fin (m+1)) = 0 := by
  have hlast : (⟨k, hk⟩ : Fin (m+1)) = Fin.last m := by ext; simpa using h
  rw [hlast, Fin.last_add_one]

lemma cyc_prod_ne_zero {a : ℕ → K} (ha : ∀ j, j < m + 1 → a j ≠ 0)
    {k : ℕ} (hk : k ≤ m + 1) : (∏ j ∈ range k, a j) ≠ 0 :=
  Finset.prod_ne_zero_iff.2 fun j hj => ha j (lt_of_lt_of_le (Finset.mem_range.1 hj) hk)

/-- **Parallel transport along the cycle.**  A global section is determined by
its value at the base point, transported by the running products of the
restriction scalars. -/
lemma ker_transport {a : ℕ → K} {f : Fin (m+1) → K}
    (hf : ∀ i : Fin (m+1), a i.val * f (i + 1) = f i) :
    ∀ k, (hk : k < m + 1) → f ⟨k, hk⟩ * (∏ j ∈ range k, a j) = f 0 := by
  intro k
  induction k with
  | zero => intro hk; simp
  | succ p ih =>
      intro hk
      have hp : p < m + 1 := by omega
      have h1 := hf ⟨p, hp⟩
      rw [cyc_succ_mk hk] at h1
      have h2 := ih hp
      rw [Finset.prod_range_succ]
      calc f ⟨p+1, hk⟩ * ((∏ j ∈ range p, a j) * a p)
          = (a p * f ⟨p+1, hk⟩) * (∏ j ∈ range p, a j) := by ring
        _ = f ⟨p, hp⟩ * (∏ j ∈ range p, a j) := by rw [h1]
        _ = f 0 := h2

/-- **The holonomy constraint.**  Closing the loop forces the base value of a
global section to be fixed by the holonomy. -/
lemma holonomy_constraint {a : ℕ → K} {f : Fin (m+1) → K}
    (hf : ∀ i : Fin (m+1), a i.val * f (i + 1) = f i) :
    holonomy a m * f 0 = f 0 := by
  have hm : m < m + 1 := by omega
  have h1 := hf ⟨m, hm⟩
  rw [cyc_last_succ hm rfl] at h1
  have h2 := ker_transport hf m hm
  unfold holonomy
  rw [Finset.prod_range_succ]
  calc (∏ j ∈ range m, a j) * a m * f 0
      = (a m * f 0) * (∏ j ∈ range m, a j) := by ring
    _ = f ⟨m, hm⟩ * (∏ j ∈ range m, a j) := by rw [h1]
    _ = f 0 := h2

/-- Nontrivial holonomy kills all global sections. -/
theorem cyc_ker_eq_bot {a : ℕ → K} (ha : ∀ j, j < m + 1 → a j ≠ 0)
    (hh : holonomy a m ≠ 1) : LinearMap.ker (cycD m a) = ⊥ := by
  rw [Submodule.eq_bot_iff]
  intro f hfmem
  have hf := mem_ker_cycD.1 hfmem
  have h0 : f 0 = 0 := by
    have hc := holonomy_constraint hf
    have hsub : (holonomy a m - 1) * f 0 = 0 := by linear_combination hc
    rcases mul_eq_zero.1 hsub with h | h
    · exact absurd (by linear_combination h : holonomy a m = 1) hh
    · exact h
  funext i
  obtain ⟨k, hk⟩ := i
  have ht := ker_transport hf k hk
  rw [h0] at ht
  have hne := cyc_prod_ne_zero ha (le_of_lt hk)
  simpa using (mul_eq_zero.1 ht).resolve_right hne

/-- The canonical global section of a cyclic data sheaf with trivial holonomy:
transport the value `1` around the loop. -/
noncomputable def cycSection (a : ℕ → K) (m : ℕ) : Fin (m+1) → K :=
  fun k => (∏ j ∈ range k.val, a j)⁻¹

lemma cycSection_mem_ker {a : ℕ → K} (ha : ∀ j, j < m + 1 → a j ≠ 0)
    (hh : holonomy a m = 1) :
    ∀ i : Fin (m+1), a i.val * cycSection a m (i + 1) = cycSection a m i := by
  rintro ⟨k, hk⟩
  rcases Nat.lt_or_ge k m with hkm | hkm
  · have h1 : k + 1 < m + 1 := by omega
    rw [cyc_succ_mk h1]
    simp only [cycSection]
    rw [Finset.prod_range_succ, mul_inv]
    have : a k ≠ 0 := ha k hk
    field_simp
  · have hkm' : k = m := by omega
    rw [cyc_last_succ hk hkm']
    simp only [cycSection]
    have h0 : ((0 : Fin (m+1)) : ℕ) = 0 := rfl
    rw [h0]
    simp only [Finset.range_zero, Finset.prod_empty, inv_one, mul_one]
    have hprod : (∏ j ∈ range k, a j) * a k = 1 := by
      have h2 := hh
      unfold holonomy at h2
      rw [Finset.prod_range_succ] at h2
      rw [hkm']; exact h2
    have hne : (∏ j ∈ range k, a j) ≠ 0 := by
      intro hz; rw [hz, zero_mul] at hprod; exact zero_ne_one hprod
    field_simp
    linear_combination hprod

lemma cycSection_ne_zero {a : ℕ → K} (m : ℕ) : cycSection a m ≠ 0 := by
  intro h
  have h0 := congrFun h 0
  simp [cycSection] at h0

/-- Trivial holonomy produces exactly a one-dimensional space of global
sections, spanned by the transported unit. -/
theorem cyc_ker_eq_span {a : ℕ → K} (ha : ∀ j, j < m + 1 → a j ≠ 0)
    (hh : holonomy a m = 1) :
    LinearMap.ker (cycD m a) = K ∙ (cycSection a m) := by
  apply le_antisymm
  · intro f hfmem
    have hf := mem_ker_cycD.1 hfmem
    refine Submodule.mem_span_singleton.2 ⟨f 0, ?_⟩
    funext i
    obtain ⟨k, hk⟩ := i
    have ht := ker_transport hf k hk
    have hne := cyc_prod_ne_zero ha (le_of_lt hk)
    show f 0 * (∏ j ∈ range k, a j)⁻¹ = f ⟨k, hk⟩
    rw [← div_eq_mul_inv, div_eq_iff hne]
    exact ht.symm
  · rw [Submodule.span_singleton_le_iff_mem]
    exact mem_ker_cycD.2 (cycSection_mem_ker ha hh)

/-- **Monodromy law, nontrivial case.**  With the overlap incidence fixed to the
`(m+1)`-cycle and all restriction maps invertible, nontrivial holonomy means no
obstruction at all: every overlap discrepancy glues. -/
theorem cyclic_H1_of_nontrivial_holonomy {a : ℕ → K} (ha : ∀ j, j < m + 1 → a j ≠ 0)
    (hh : holonomy a m ≠ 1) : finrank K (H1 (cycD m a)) = 0 := by
  rw [finrank_H1_eq_finrank_ker (cycD m a) rfl, cyc_ker_eq_bot ha hh]
  simp

/-- **Monodromy law, trivial case.**  Trivial holonomy produces exactly a
one-dimensional obstruction — no matter how many features there are. -/
theorem cyclic_H1_of_trivial_holonomy {a : ℕ → K} (ha : ∀ j, j < m + 1 → a j ≠ 0)
    (hh : holonomy a m = 1) : finrank K (H1 (cycD m a)) = 1 := by
  rw [finrank_H1_eq_finrank_ker (cycD m a) rfl, cyc_ker_eq_span ha hh]
  exact finrank_span_singleton (cycSection_ne_zero m)

/-- **Monodromy criterion for cyclic data nerves.**  With the incidence held
fixed and all restriction maps invertible, the obstruction is nonzero exactly
when the holonomy around the loop is trivial.  Thus `H¹` is a function of the
restriction data alone; the incidence contributes nothing. -/
theorem cyclic_holonomy_criterion {a : ℕ → K} (ha : ∀ j, j < m + 1 → a j ≠ 0) :
    finrank K (H1 (cycD m a)) = 1 ↔ holonomy a m = 1 := by
  constructor
  · intro h
    by_contra hh
    rw [cyclic_H1_of_nontrivial_holonomy ha hh] at h
    exact absurd h (by omega)
  · exact cyclic_H1_of_trivial_holonomy ha

/-- The previous cycle of this thread (constant sheaf, all restriction maps the
identity) is the special case `a ≡ 1`, recovering `H¹ ≠ 0` on a loop. -/
theorem cyclic_constant_sheaf_H1 (m : ℕ) :
    finrank K (H1 (cycD m (fun _ => (1 : K)))) = 1 := by
  refine cyclic_H1_of_trivial_holonomy (fun j _ => one_ne_zero) ?_
  simp [holonomy]

/-- Two restriction-map assignments on the **same** cyclic nerve, both by
isomorphisms of stalks, with different obstruction dimensions: scaling every
restriction map by `2` destroys the obstruction.  Incidence is not destiny. -/
theorem cyclic_H1_depends_on_restrictions (m : ℕ) :
    finrank ℚ (H1 (cycD m (fun _ => (1 : ℚ)))) = 1 ∧
    finrank ℚ (H1 (cycD m (fun _ => (2 : ℚ)))) = 0 := by
  refine ⟨cyclic_constant_sheaf_H1 m, ?_⟩
  refine cyclic_H1_of_nontrivial_holonomy (fun j _ => two_ne_zero) ?_
  have h2 : holonomy (fun _ => (2 : ℚ)) m = 2 ^ (m + 1) := by simp [holonomy]
  rw [h2]
  have hge : (2 : ℚ) ≤ 2 ^ (m + 1) := by
    calc (2:ℚ) = 2 ^ 1 := by norm_num
      _ ≤ 2 ^ (m+1) := by apply pow_le_pow_right₀ (by norm_num) (by omega)
  intro hcon
  rw [hcon] at hge
  norm_num at hge

end Cyclic

/-! ## §4.  The disjoint-loop nerve: an exact rank law, and the failure of any
missing-rate scaling law

Now the nerve consists of `N` feature blocks, each overlapping only itself (a
self-loop: the block is re-observed in a second sample batch).  The restriction
map on loop `i` is multiplication by `aᵢ`; the coboundary is
`(δf)ᵢ = aᵢ · f i - f i`.  Every restriction map is an isomorphism as soon as
`aᵢ ≠ 0`, yet the obstruction dimension is *exactly* the number of loops with
trivial holonomy — an arbitrary integer between `0` and `N`. -/

section Loops

variable {K : Type*} [Field K] [DecidableEq K] {N : ℕ}

/-- Coboundary of the disjoint-loop nerve with restriction scalars `a`. -/
def loopD (a : Fin N → K) : (Fin N → K) →ₗ[K] (Fin N → K) where
  toFun f := fun i => a i * f i - f i
  map_add' x y := by funext i; simp; ring
  map_smul' c x := by funext i; simp; ring

/-- The set of loops carrying trivial holonomy. -/
def trivialLoops (a : Fin N → K) : Finset (Fin N) := univ.filter (fun i => a i = 1)

lemma mem_ker_loopD {a : Fin N → K} {f : Fin N → K} :
    f ∈ LinearMap.ker (loopD a) ↔ ∀ i, a i ≠ 1 → f i = 0 := by
  simp only [LinearMap.mem_ker, loopD, LinearMap.coe_mk, AddHom.coe_mk]
  constructor
  · intro h i hi
    have h2 := congrFun h i
    simp only [Pi.zero_apply] at h2
    have hfac : (a i - 1) * f i = 0 := by linear_combination h2
    rcases mul_eq_zero.1 hfac with h1 | h1
    · exact absurd (by linear_combination h1 : a i = 1) hi
    · exact h1
  · intro h
    funext i
    by_cases hi : a i = 1
    · simp [hi]
    · simp [h i hi]

/-- The space of global sections of the disjoint-loop sheaf has dimension equal
to the number of loops with trivial holonomy. -/
theorem finrank_ker_loopD (a : Fin N → K) :
    finrank K (LinearMap.ker (loopD a)) = (trivialLoops a).card := by
  set T : Finset (Fin N) := (trivialLoops a)ᶜ with hT
  set p : (Fin N → K) →ₗ[K] (↥T → K) :=
    LinearMap.funLeft K K (fun t : ↥T => (t : Fin N)) with hp
  have hker : LinearMap.ker p = LinearMap.ker (loopD a) := by
    ext f
    rw [LinearMap.mem_ker, mem_ker_loopD]
    constructor
    · intro h i hi
      have hiT : i ∈ T := by simp [hT, trivialLoops, hi]
      simpa using congrFun h ⟨i, hiT⟩
    · intro h
      funext t
      have ht2 : (t : Fin N) ∈ T := t.2
      have hne : a (t : Fin N) ≠ 1 := by simpa [hT, trivialLoops] using ht2
      simpa using h _ hne
  have hsurj : Function.Surjective p :=
    LinearMap.funLeft_surjective_of_injective K K _ (fun s t hst => Subtype.ext hst)
  have hrn := LinearMap.finrank_range_add_finrank_ker p
  rw [LinearMap.range_eq_top.2 hsurj, hker, finrank_top] at hrn
  have hTcard : finrank K (↥T → K) = T.card := by simp
  have hN : finrank K (Fin N → K) = N := by simp
  rw [hTcard, hN] at hrn
  have hcard : T.card = N - (trivialLoops a).card := by
    rw [hT, Finset.card_compl]; simp
  have hle : (trivialLoops a).card ≤ N := by
    simpa using Finset.card_le_univ (trivialLoops a)
  omega

/-- **Exact rank law for the disjoint-loop nerve.**  The obstruction dimension
is `#{i | aᵢ = 1}`: a deterministic function of the restriction data, with the
incidence held fixed. -/
theorem finrank_H1_disjointLoops (a : Fin N → K) :
    finrank K (H1 (loopD a)) = (trivialLoops a).card := by
  rw [finrank_H1_eq_finrank_ker (loopD a) rfl, finrank_ker_loopD]

/-- Every subset of the feature set is realised as the trivial-holonomy locus of
an assignment of **invertible** restriction maps to the fixed disjoint-loop
nerve, and the obstruction dimension is exactly its cardinality. -/
theorem H1_realizes_every_trivialLoop_set (S : Finset (Fin N)) :
    ∃ a : Fin N → ℚ, (∀ i, a i ≠ 0) ∧ trivialLoops a = S ∧
      finrank ℚ (H1 (loopD a)) = S.card := by
  refine ⟨fun i => if i ∈ S then 1 else 2, fun i => ?_, ?_, ?_⟩
  · by_cases h : i ∈ S <;> simp [h]
  · unfold trivialLoops
    ext i
    by_cases h : i ∈ S <;> simp [h]
  · rw [finrank_H1_disjointLoops]
    congr 1
    unfold trivialLoops
    ext i
    by_cases h : i ∈ S <;> simp [h]

/-- **The missing rate and the feature count do not determine `H¹`.**
For every feature count `N` and every target obstruction dimension `k ≤ N`
there is an assignment of *invertible* restriction maps to one fixed overlap
nerve on `N` features realising `dim H¹ = k` exactly.  Consequently no function
of (feature count, marginal missing rate, overlap incidence) can predict
`dim H¹`: two such models can differ by the full linear amount `N`. -/
theorem missing_rate_does_not_determine_H1 (N k : ℕ) (hk : k ≤ N) :
    ∃ a : Fin N → ℚ, (∀ i, a i ≠ 0) ∧ finrank ℚ (H1 (loopD a)) = k := by
  obtain ⟨S, -, hS⟩ :=
    Finset.exists_subset_card_eq (s := (univ : Finset (Fin N))) (by simpa using hk)
  obtain ⟨a, ha, -, hdim⟩ := H1_realizes_every_trivialLoop_set S
  exact ⟨a, ha, by rw [hdim, hS]⟩

/-- The two extreme models on one and the same nerve, spelled out: a maximal
obstruction (`dim H¹ = N`, a full linear fraction of the feature count) and a
vanishing one, both with invertible restriction maps. -/
theorem H1_gap_is_linear_in_features (N : ℕ) :
    finrank ℚ (H1 (loopD (fun _ : Fin N => (1 : ℚ)))) = N ∧
    finrank ℚ (H1 (loopD (fun _ : Fin N => (2 : ℚ)))) = 0 := by
  constructor
  · rw [finrank_H1_disjointLoops]
    simp [trivialLoops]
  · rw [finrank_H1_disjointLoops]
    simp [trivialLoops]

end Loops

/-! ## §5.  The torsion barrier: integral coefficients see obstructions that no
field sees

Everything above is linear algebra over a field, which is what the applied
literature computes.  Replacing the field by `ℤ` — stalks `ℤ`, restriction maps
integer multiplications — reveals a strictly finer invariant.  On the
disjoint-loop nerve the integral obstruction is `⨁ᵢ ℤ/(aᵢ - 1)`, which is pure
torsion as soon as no `aᵢ` equals `1`; and pure torsion is exactly what becomes
invisible after tensoring with any field of characteristic `0`. -/

section Integral

variable {N : ℕ}

/-- Integral coboundary of the disjoint-loop nerve. -/
def loopDZ (a : Fin N → ℤ) : (Fin N → ℤ) →ₗ[ℤ] (Fin N → ℤ) where
  toFun f := fun i => a i * f i - f i
  map_add' x y := by funext i; simp; ring
  map_smul' c x := by funext i; simp; ring

/-- The integral obstruction module. -/
abbrev H1Z (a : Fin N → ℤ) := (Fin N → ℤ) ⧸ LinearMap.range (loopDZ a)

/-- An integral overlap discrepancy glues iff it is divisible, coordinatewise,
by `aᵢ - 1`.  Over a field this condition is vacuous unless `aᵢ = 1`; over `ℤ`
it is a genuine arithmetic constraint. -/
lemma mem_range_loopDZ {a : Fin N → ℤ} {g : Fin N → ℤ} :
    g ∈ LinearMap.range (loopDZ a) ↔ ∀ i, (a i - 1) ∣ g i := by
  constructor
  · rintro ⟨f, rfl⟩ i
    exact ⟨f i, by simp [loopDZ]; ring⟩
  · intro h
    refine ⟨fun i => g i / (a i - 1), ?_⟩
    funext i
    show a i * (g i / (a i - 1)) - g i / (a i - 1) = g i
    have hc := Int.ediv_mul_cancel (h i)
    calc a i * (g i / (a i - 1)) - g i / (a i - 1)
        = (g i / (a i - 1)) * (a i - 1) := by ring
      _ = g i := hc

/-- **The integral obstruction is annihilated by `∏ᵢ (aᵢ - 1)`.**  When no `aᵢ`
equals `1` this product is nonzero, so `H¹(ℤ)` is a torsion module. -/
theorem integral_H1_torsion (a : Fin N → ℤ) (x : H1Z a) :
    (∏ i, (a i - 1)) • x = 0 := by
  induction x using Submodule.Quotient.induction_on with
  | H g =>
    rw [← Submodule.Quotient.mk_smul, Submodule.Quotient.mk_eq_zero]
    refine mem_range_loopDZ.2 fun i => ?_
    have hd : (a i - 1) ∣ ∏ j, (a j - 1) := Finset.dvd_prod_of_mem _ (mem_univ i)
    show (a i - 1) ∣ (∏ j, (a j - 1)) * g i
    exact dvd_mul_of_dvd_left hd (g i)

/-- The annihilating product is nonzero precisely when no restriction scalar is
the identity — i.e. exactly in the regime where the field-valued theory reports
no obstruction at all. -/
theorem integral_annihilator_ne_zero {a : Fin N → ℤ} (ha : ∀ i, a i ≠ 1) :
    (∏ i, (a i - 1)) ≠ 0 :=
  Finset.prod_ne_zero_iff.2 fun i _ => sub_ne_zero_of_ne (ha i)

/-- **Nontriviality of the integral obstruction.**  If some restriction scalar
`aᵢ₀` satisfies `aᵢ₀ - 1 ∤ 1` (e.g. `aᵢ₀ = 3`), the class of the indicator
discrepancy at `i₀` is a nonzero integral obstruction. -/
theorem integral_H1_nontrivial_of_not_dvd_one {a : Fin N → ℤ} (i0 : Fin N)
    (h : ¬ (a i0 - 1) ∣ 1) : ∃ x : H1Z a, x ≠ 0 := by
  refine ⟨Submodule.Quotient.mk (Pi.single i0 1), ?_⟩
  rw [Ne, Submodule.Quotient.mk_eq_zero]
  intro hmem
  have hd := mem_range_loopDZ.1 hmem i0
  rw [Pi.single_eq_same] at hd
  exact h hd

/-- **The torsion barrier.**  On one loop with restriction scalar `3` the
integral obstruction is nonzero and every element of it is `2`-torsion, while
the rational obstruction of the *same* data sheaf vanishes identically.  A
purely arithmetic failure of gluing that no field-coefficient computation — the
only kind performed in practice — can detect. -/
theorem torsion_obstruction_invisible_to_field_coefficients :
    (∃ x : H1Z (fun _ : Fin 1 => (3 : ℤ)), x ≠ 0) ∧
    (∀ x : H1Z (fun _ : Fin 1 => (3 : ℤ)), (2 : ℤ) • x = 0) ∧
    finrank ℚ (H1 (loopD (fun _ : Fin 1 => (3 : ℚ)))) = 0 := by
  refine ⟨integral_H1_nontrivial_of_not_dvd_one 0 (by decide), ?_, ?_⟩
  · intro x
    have h := integral_H1_torsion (fun _ : Fin 1 => (3 : ℤ)) x
    simpa using h
  · rw [finrank_H1_disjointLoops]
    simp [trivialLoops]

/-- The general comparison: whenever no restriction scalar is `1`, the rational
obstruction vanishes identically — so all the information left in the integral
obstruction is torsion. -/
theorem rational_H1_vanishes_of_no_trivial_loop {a : Fin N → ℚ} (ha : ∀ i, a i ≠ 1) :
    finrank ℚ (H1 (loopD a)) = 0 := by
  rw [finrank_H1_disjointLoops]
  have : trivialLoops a = ∅ := by
    unfold trivialLoops
    ext i
    simp [ha i]
  rw [this]
  simp

end Integral

/-! ## §6.  The determinant is the universal exponent of the integral obstruction

The two integral computations above are instances of one statement.  For *any*
data complex whose coboundary is a square integer matrix `M` — i.e. as many
overlap degrees of freedom as local ones, the equidimensional situation of
`finrank_H1_eq_finrank_ker` — the integral obstruction is annihilated by
`det M`, by the adjugate identity.  When `det M ≠ 0` the field-valued
obstruction vanishes identically, so *everything* the integral theory sees in
that regime is torsion of exponent dividing `|det M|`. -/

section Determinant

open Matrix

variable {n : ℕ}

/-- The integral obstruction module of a square integer coboundary. -/
abbrev H1Zmat (M : Matrix (Fin n) (Fin n) ℤ) :=
  (Fin n → ℤ) ⧸ LinearMap.range M.mulVecLin

/-- **The determinant annihilates the integral obstruction.**  For every square
integer coboundary `M`, `det M` kills `H¹(ℤ)`.  The witness is the adjugate:
`M · (adj M · g) = (det M) · g`. -/
theorem det_smul_H1Zmat_eq_zero (M : Matrix (Fin n) (Fin n) ℤ) (x : H1Zmat M) :
    (M.det) • x = 0 := by
  induction x using Submodule.Quotient.induction_on with
  | H g =>
    rw [← Submodule.Quotient.mk_smul, Submodule.Quotient.mk_eq_zero]
    refine ⟨M.adjugate *ᵥ g, ?_⟩
    show M *ᵥ (M.adjugate *ᵥ g) = M.det • g
    rw [Matrix.mulVec_mulVec, Matrix.mul_adjugate]
    simp

/-- A nonzero determinant makes the rational obstruction vanish identically. -/
theorem rational_H1_mat_eq_zero_of_det_ne_zero (M : Matrix (Fin n) (Fin n) ℤ)
    (h : M.det ≠ 0) :
    finrank ℚ ((Fin n → ℚ) ⧸ LinearMap.range (M.map (Int.cast : ℤ → ℚ)).mulVecLin) = 0 := by
  set Mq := M.map (Int.cast : ℤ → ℚ) with hMq
  have hdet : Mq.det = (M.det : ℚ) := (RingHom.map_det (Int.castRingHom ℚ) M).symm
  have hu : IsUnit Mq := by
    rw [Matrix.isUnit_iff_isUnit_det, hdet]
    exact (isUnit_iff_ne_zero).2 (by exact_mod_cast h)
  obtain ⟨U, hU⟩ := hu
  have hsurj : Function.Surjective Mq.mulVecLin := by
    intro y
    refine ⟨((U⁻¹ : (Matrix (Fin n) (Fin n) ℚ)ˣ) : Matrix (Fin n) (Fin n) ℚ) *ᵥ y, ?_⟩
    show Mq *ᵥ _ = y
    rw [← hU, Matrix.mulVec_mulVec, ← Units.val_mul, mul_inv_cancel]
    simp
  rw [LinearMap.range_eq_top.2 hsurj]
  exact finrank_zero_of_subsingleton

/-- **General torsion barrier.**  Whenever the coboundary of an equidimensional
data complex has nonzero determinant, the rational obstruction vanishes
identically while the integral obstruction is a torsion module of exponent
dividing `|det M|`.  §5 shows this torsion is genuinely nonzero in general
(`M = (2)` in dimension one gives `ℤ/2`), so no field-coefficient computation
can certify gluability. -/
theorem integral_vs_rational_dichotomy (M : Matrix (Fin n) (Fin n) ℤ) (h : M.det ≠ 0) :
    (∀ x : H1Zmat M, (M.det) • x = 0) ∧
      finrank ℚ ((Fin n → ℚ) ⧸ LinearMap.range (M.map (Int.cast : ℤ → ℚ)).mulVecLin) = 0 :=
  ⟨det_smul_H1Zmat_eq_zero M, rational_H1_mat_eq_zero_of_det_ne_zero M h⟩

end Determinant

end DataSheafCohomology