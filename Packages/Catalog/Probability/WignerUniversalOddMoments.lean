/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Universality at all orders: the walk–moment formula, tightness, and vanishing odd moments

`Probability.WignerUniversalFourthMoment` proves universality of the spectral
moments of a general Wigner ensemble (arbitrary finitely supported, centred,
unit-variance entry law) up to order four, and
`Probability.WignerAllOrderParity` handles all orders for the Rademacher ensemble.
This file removes both restrictions at once, for the two statements that do not
require the Catalan bookkeeping:

* `WignerUniversal.gexpect_walk_prod` — the **walk–moment formula**: for a loop-free
  family of steps, the ensemble average of the walk monomial is the product, over
  edges, of the entry-law moment of order equal to the multiplicity of that edge.
  Independence enters exactly once, through `gexpect_prod`.

* `WignerUniversal.gexpect_walk_prod_eq_zero_of_edgeMult_one` — a walk traversing
  some edge exactly once averages to `0`, because the entry law is centred.  This is
  the general-law replacement for the sign-flip involution of the Rademacher case.

* `WignerUniversal.gexpect_trace_pow_bound` — combining the vanishing with the
  spanning-tree counting of `Probability.WignerMomentGrowth`: a walk contributing to
  `E [tr (W^(m+1))]` uses no edge just once, hence visits at most `k+1` vertices
  whenever `m ≤ 2k`, and therefore

    `|E [tr (W^(m+1))]| ≤ N^(k+1) (k+1)^(m+1) B^(m+1)`,

  where `B` bounds the support of the entry law.

* `WignerUniversal.gexpect_normalizedMoment_even_le` — hence all even normalised
  moments are bounded uniformly in `N` (tightness), and

* `WignerUniversal.tendsto_gexpect_normalizedMoment_odd` — every **odd** normalised
  moment tends to `0` like `N^{-1/2}`, matching the vanishing odd moments of the
  semicircle law, for *every* entry law and at *every* odd order.
-/
import Probability.WignerMomentGrowth
import Probability.WignerSecondMomentConcentration

open Matrix BigOperators Finset Filter Topology
open RademacherWigner (edgeOf edgeMult edgeOf_comm card_eq_sum_edgeMult
  trace_pow_succ_sum_walks card_filter_le_pow card_image_cons_le_of_ne_one)

namespace WignerUniversal

variable {S : Type*} [Fintype S] {N : ℕ}

/-! ### A crude bound on the support of the entry law -/

/-- A bound for the values taken by the entry law. -/
noncomputable def EntryLaw.vBound (L : EntryLaw S) : ℝ := ∑ s, |L.v s|

theorem EntryLaw.vBound_nonneg (L : EntryLaw S) : 0 ≤ L.vBound :=
  Finset.sum_nonneg fun _ _ => abs_nonneg _

theorem EntryLaw.abs_v_le (L : EntryLaw S) (s : S) : |L.v s| ≤ L.vBound :=
  Finset.single_le_sum (f := fun s => |L.v s|) (fun _ _ => abs_nonneg _) (Finset.mem_univ s)

/-- The moments of the entry law grow at most like the powers of `vBound`. -/
theorem abs_moment_le (L : EntryLaw S) (j : ℕ) :
    |∑ s, L.w s * L.v s ^ j| ≤ L.vBound ^ j := by
  calc |∑ s, L.w s * L.v s ^ j| ≤ ∑ s, |L.w s * L.v s ^ j| := Finset.abs_sum_le_sum_abs _ _
    _ = ∑ s, L.w s * |L.v s| ^ j := by
        refine Finset.sum_congr rfl fun s _ => ?_
        rw [abs_mul, abs_of_nonneg (L.w_nonneg s), abs_pow]
    _ ≤ ∑ s, L.w s * L.vBound ^ j := by
        refine Finset.sum_le_sum fun s _ => ?_
        exact mul_le_mul_of_nonneg_left
          (pow_le_pow_left₀ (abs_nonneg _) (L.abs_v_le s) j) (L.w_nonneg s)
    _ = L.vBound ^ j := by rw [← Finset.sum_mul, L.total, one_mul]

/-! ### The walk–moment formula -/

variable {ι : Type*} [Fintype ι]

/-- **Walk–moment formula.**  For a loop-free family of steps, the ensemble average
of the walk monomial factorises over edges into entry-law moments, the order of the
moment at an edge being the multiplicity of that edge in the walk. -/
theorem gexpect_walk_prod (L : EntryLaw S) (a b : ι → Fin N) (hne : ∀ t, a t ≠ b t) :
    gexpect L (fun ω : Conf N S => ∏ t, gentry L ω (a t) (b t))
      = ∏ e : Fin N × Fin N, ∑ s, L.w s * L.v s ^ edgeMult a b e := by
  have h1 : ∀ ω : Conf N S, (∏ t, gentry L ω (a t) (b t))
      = ∏ e : Fin N × Fin N, L.v (ω e) ^ edgeMult a b e := by
    intro ω
    rw [Finset.prod_congr rfl fun t _ => gentry_of_ne L ω (hne t),
      ← Finset.prod_fiberwise Finset.univ (fun t => edgeOf (a t) (b t))
        (fun t => L.v (ω (edgeOf (a t) (b t))))]
    refine Finset.prod_congr rfl fun e _ => ?_
    have h2 : ∀ t ∈ Finset.univ.filter (fun t => edgeOf (a t) (b t) = e),
        L.v (ω (edgeOf (a t) (b t))) = L.v (ω e) := by
      intro t ht
      rw [(Finset.mem_filter.1 ht).2]
    rw [Finset.prod_congr rfl h2, Finset.prod_const, edgeMult]
  simp only [h1]
  exact gexpect_prod L fun e s => L.v s ^ edgeMult a b e

/-- **Centredness kills walks with a simply-traversed edge.**  If some edge occurs
exactly once along the walk, the ensemble average of the walk monomial is `0`. -/
theorem gexpect_walk_prod_eq_zero_of_edgeMult_one (L : EntryLaw S) (a b : ι → Fin N)
    (hne : ∀ t, a t ≠ b t) {p : Fin N × Fin N} (hp : edgeMult a b p = 1) :
    gexpect L (fun ω : Conf N S => ∏ t, gentry L ω (a t) (b t)) = 0 := by
  rw [gexpect_walk_prod L a b hne]
  refine Finset.prod_eq_zero (Finset.mem_univ p) ?_
  rw [hp]
  simpa using L.mean

/-- A walk with a loop step (one that stays at its vertex) contributes `0`, because
the model has zero diagonal. -/
theorem gexpect_walk_prod_eq_zero_of_loop (L : EntryLaw S) (a b : ι → Fin N) {t₀ : ι}
    (ht : a t₀ = b t₀) :
    gexpect L (fun ω : Conf N S => ∏ t, gentry L ω (a t) (b t)) = 0 := by
  have h0 : ∀ ω : Conf N S, (∏ t, gentry L ω (a t) (b t)) = 0 := by
    intro ω
    refine Finset.prod_eq_zero (Finset.mem_univ t₀) ?_
    rw [gentry, if_pos ht]
  simp only [h0]
  exact gexpect_zero L

/-- The absolute value of a walk average is at most `B` to the number of steps. -/
theorem abs_gexpect_walk_prod_le (L : EntryLaw S) (a b : ι → Fin N) (hne : ∀ t, a t ≠ b t) :
    |gexpect L (fun ω : Conf N S => ∏ t, gentry L ω (a t) (b t))|
      ≤ L.vBound ^ Fintype.card ι := by
  rw [gexpect_walk_prod L a b hne, Finset.abs_prod]
  calc ∏ e : Fin N × Fin N, |∑ s, L.w s * L.v s ^ edgeMult a b e|
      ≤ ∏ e : Fin N × Fin N, L.vBound ^ edgeMult a b e := by
        refine Finset.prod_le_prod (fun e _ => abs_nonneg _) fun e _ => abs_moment_le L _
    _ = L.vBound ^ ∑ e : Fin N × Fin N, edgeMult a b e := by
        rw [Finset.prod_pow_eq_pow_sum]
    _ = L.vBound ^ Fintype.card ι := by rw [← card_eq_sum_edgeMult a b]

/-! ### The trace moments of a general Wigner ensemble -/

/-- Closed-walk expansion of a trace moment of the general ensemble. -/
theorem gexpect_trace_pow_eq_sum (L : EntryLaw S) (m : ℕ) :
    gexpect L (fun ω : Conf N S => ((GW L ω) ^ (m + 1)).trace)
      = ∑ i : Fin N, ∑ v : Fin m → Fin N, gexpect L (fun ω : Conf N S =>
          ∏ t : Fin (m + 1), gentry L ω ((Fin.cons i v : Fin (m + 1) → Fin N) t)
            ((Fin.snoc v i : Fin (m + 1) → Fin N) t)) := by
  have h1 : ∀ ω : Conf N S, ((GW L ω) ^ (m + 1)).trace
      = ∑ i : Fin N, ∑ v : Fin m → Fin N, ∏ t : Fin (m + 1),
        gentry L ω ((Fin.cons i v : Fin (m + 1) → Fin N) t)
          ((Fin.snoc v i : Fin (m + 1) → Fin N) t) := by
    intro ω
    simpa using trace_pow_succ_sum_walks (GW L ω) m
  simp only [h1]
  rw [gexpect_sum]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [gexpect_sum]

/-- The walks that can contribute to a trace moment: loop-free, and with no edge
traversed exactly once. -/
def Contributing (m : ℕ) (x : Fin N × (Fin m → Fin N)) : Prop :=
  (∀ t : Fin (m + 1), (Fin.cons x.1 x.2 : Fin (m + 1) → Fin N) t
      ≠ (Fin.snoc x.2 x.1 : Fin (m + 1) → Fin N) t) ∧
  (∀ p, edgeMult (Fin.cons x.1 x.2 : Fin (m + 1) → Fin N)
      (Fin.snoc x.2 x.1 : Fin (m + 1) → Fin N) p ≠ 1)

open scoped Classical in
/-- **Uniform bound on all trace moments of a general Wigner ensemble.**  Only
loop-free walks with no simply-traversed edge contribute, and those visit at most
`k + 1` vertices whenever `m ≤ 2k`; there are at most `N^(k+1) (k+1)^(m+1)` of them,
each contributing at most `B^(m+1)`. -/
theorem gexpect_trace_pow_bound (L : EntryLaw S) {m k : ℕ} (hmk : m ≤ 2 * k) (hkm : k ≤ m) :
    |gexpect L (fun ω : Conf N S => ((GW L ω) ^ (m + 1)).trace)|
      ≤ (N : ℝ) ^ (k + 1) * ((k : ℝ) + 1) ^ (m + 1) * L.vBound ^ (m + 1) := by
  set F : Fin N × (Fin m → Fin N) → ℝ := fun x => gexpect L (fun ω : Conf N S =>
    ∏ t : Fin (m + 1), gentry L ω ((Fin.cons x.1 x.2 : Fin (m + 1) → Fin N) t)
      ((Fin.snoc x.2 x.1 : Fin (m + 1) → Fin N) t)) with hF
  have hexp : gexpect L (fun ω : Conf N S => ((GW L ω) ^ (m + 1)).trace)
      = ∑ x : Fin N × (Fin m → Fin N), F x := by
    rw [gexpect_trace_pow_eq_sum L m, Fintype.sum_prod_type]
  have hzero : ∀ x : Fin N × (Fin m → Fin N), ¬ Contributing m x → F x = 0 := by
    intro x hx
    rw [Contributing] at hx
    push_neg at hx
    by_cases hloop : ∀ t : Fin (m + 1), (Fin.cons x.1 x.2 : Fin (m + 1) → Fin N) t
        ≠ (Fin.snoc x.2 x.1 : Fin (m + 1) → Fin N) t
    · obtain ⟨p, hp⟩ := hx hloop
      exact gexpect_walk_prod_eq_zero_of_edgeMult_one L _ _ hloop hp
    · push_neg at hloop
      obtain ⟨t, ht⟩ := hloop
      exact gexpect_walk_prod_eq_zero_of_loop L _ _ ht
  have hsum : ∑ x : Fin N × (Fin m → Fin N), F x
      = ∑ x ∈ (univ : Finset (Fin N × (Fin m → Fin N))).filter (Contributing m), F x := by
    refine (Finset.sum_subset (Finset.filter_subset _ _) ?_).symm
    intro x _ hx
    exact hzero x fun hc => hx (Finset.mem_filter.2 ⟨Finset.mem_univ x, hc⟩)
  have hbound : ∀ x ∈ (univ : Finset (Fin N × (Fin m → Fin N))).filter (Contributing m),
      |F x| ≤ L.vBound ^ (m + 1) := by
    intro x hx
    have hc : Contributing m x := (Finset.mem_filter.1 hx).2
    have h := abs_gexpect_walk_prod_le L (ι := Fin (m + 1))
      (Fin.cons x.1 x.2 : Fin (m + 1) → Fin N) (Fin.snoc x.2 x.1 : Fin (m + 1) → Fin N) hc.1
    rwa [Fintype.card_fin] at h
  have hcard : (((univ : Finset (Fin N × (Fin m → Fin N))).filter (Contributing m)).card : ℝ)
      ≤ (N : ℝ) ^ (k + 1) * ((k : ℝ) + 1) ^ (m + 1) := by
    have h := card_filter_le_pow (N := N) (m := m) (k := k) hkm (Contributing m)
      (fun x hx => card_image_cons_le_of_ne_one hmk hx.2)
    have h' : (((univ : Finset (Fin N × (Fin m → Fin N))).filter (Contributing m)).card : ℝ)
        ≤ ((N ^ (k + 1) * (k + 1) ^ (m + 1) : ℕ) : ℝ) := by exact_mod_cast h
    refine h'.trans (le_of_eq ?_)
    push_cast
    ring
  rw [hexp, hsum]
  calc |∑ x ∈ (univ : Finset (Fin N × (Fin m → Fin N))).filter (Contributing m), F x|
      ≤ ∑ x ∈ (univ : Finset (Fin N × (Fin m → Fin N))).filter (Contributing m), |F x| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _x ∈ (univ : Finset (Fin N × (Fin m → Fin N))).filter (Contributing m),
          L.vBound ^ (m + 1) := Finset.sum_le_sum hbound
    _ = (((univ : Finset (Fin N × (Fin m → Fin N))).filter (Contributing m)).card : ℝ)
          * L.vBound ^ (m + 1) := by rw [Finset.sum_const, nsmul_eq_mul]
    _ ≤ ((N : ℝ) ^ (k + 1) * ((k : ℝ) + 1) ^ (m + 1)) * L.vBound ^ (m + 1) :=
        mul_le_mul_of_nonneg_right hcard (pow_nonneg L.vBound_nonneg _)

/-! ### Consequences for the normalised spectral moments -/

theorem sqrt_inv_pow (N : ℕ) (j : ℕ) :
    (Real.sqrt (N : ℝ))⁻¹ ^ (2 * j) = ((N : ℝ) ^ j)⁻¹ := by
  rw [pow_mul, ← Real.sqrt_inv, Real.sq_sqrt (by positivity), inv_pow]

/-- **Universal tightness.**  For every entry law and every `k ≥ 1`, the expected
`2k`-th normalised spectral moment is bounded by `(k+1)^(2k) B^(2k)`, uniformly in
the dimension `N`. -/
theorem gexpect_normalizedMoment_even_le (L : EntryLaw S) {k : ℕ} (hk : 1 ≤ k) (hN : 0 < N) :
    |gexpect L (fun ω : Conf N S => WignerBridge.normalizedMoment (GW L ω) (2 * k))|
      ≤ ((k : ℝ) + 1) ^ (2 * k) * L.vBound ^ (2 * k) := by
  obtain ⟨m, hm⟩ : ∃ m, m + 1 = 2 * k := ⟨2 * k - 1, by omega⟩
  have hNR : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  have hcard : (Fintype.card (Fin N) : ℝ) = (N : ℝ) := by simp
  have hconst : ∀ ω : Conf N S, WignerBridge.normalizedMoment (GW L ω) (2 * k)
      = ((1 / (N : ℝ)) * ((N : ℝ) ^ k)⁻¹) * ((GW L ω) ^ (2 * k)).trace := by
    intro ω
    rw [WignerBridge.normalizedMoment_eq, hcard, sqrt_inv_pow]
  simp only [hconst]
  rw [gexpect_const_mul, abs_mul]
  have habs : |(1 / (N : ℝ)) * ((N : ℝ) ^ k)⁻¹| = (1 / (N : ℝ)) * ((N : ℝ) ^ k)⁻¹ :=
    abs_of_nonneg (by positivity)
  rw [habs]
  have hb : |gexpect L (fun ω : Conf N S => ((GW L ω) ^ (2 * k)).trace)|
      ≤ (N : ℝ) ^ (k + 1) * ((k : ℝ) + 1) ^ (2 * k) * L.vBound ^ (2 * k) := by
    have h := gexpect_trace_pow_bound (N := N) L (m := m) (k := k) (by omega) (by omega)
    rwa [hm] at h
  calc (1 / (N : ℝ)) * ((N : ℝ) ^ k)⁻¹
        * |gexpect L (fun ω : Conf N S => ((GW L ω) ^ (2 * k)).trace)|
      ≤ (1 / (N : ℝ)) * ((N : ℝ) ^ k)⁻¹
        * ((N : ℝ) ^ (k + 1) * ((k : ℝ) + 1) ^ (2 * k) * L.vBound ^ (2 * k)) :=
        mul_le_mul_of_nonneg_left hb (by positivity)
    _ = ((k : ℝ) + 1) ^ (2 * k) * L.vBound ^ (2 * k) := by
        field_simp
        ring

/-- The odd normalised moments are `O(N^{-1/2})`, uniformly over the ensemble. -/
theorem abs_gexpect_normalizedMoment_odd_le (L : EntryLaw S) (k : ℕ) (hN : 0 < N) :
    |gexpect L (fun ω : Conf N S => WignerBridge.normalizedMoment (GW L ω) (2 * k + 1))|
      ≤ (((k : ℝ) + 1) ^ (2 * k + 1) * L.vBound ^ (2 * k + 1)) * (Real.sqrt (N : ℝ))⁻¹ := by
  have hNR : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  have hsqrt : (0 : ℝ) < Real.sqrt (N : ℝ) := Real.sqrt_pos.2 hNR
  have hcard : (Fintype.card (Fin N) : ℝ) = (N : ℝ) := by simp
  have hpow : (Real.sqrt (N : ℝ))⁻¹ ^ (2 * k + 1)
      = ((N : ℝ) ^ k)⁻¹ * (Real.sqrt (N : ℝ))⁻¹ := by
    rw [pow_succ, sqrt_inv_pow]
  have hconst : ∀ ω : Conf N S, WignerBridge.normalizedMoment (GW L ω) (2 * k + 1)
      = ((1 / (N : ℝ)) * (((N : ℝ) ^ k)⁻¹ * (Real.sqrt (N : ℝ))⁻¹))
        * ((GW L ω) ^ (2 * k + 1)).trace := by
    intro ω
    rw [WignerBridge.normalizedMoment_eq, hcard, hpow]
  simp only [hconst]
  rw [gexpect_const_mul, abs_mul]
  have habs : |(1 / (N : ℝ)) * (((N : ℝ) ^ k)⁻¹ * (Real.sqrt (N : ℝ))⁻¹)|
      = (1 / (N : ℝ)) * (((N : ℝ) ^ k)⁻¹ * (Real.sqrt (N : ℝ))⁻¹) :=
    abs_of_nonneg (by positivity)
  rw [habs]
  have hb : |gexpect L (fun ω : Conf N S => ((GW L ω) ^ (2 * k + 1)).trace)|
      ≤ (N : ℝ) ^ (k + 1) * ((k : ℝ) + 1) ^ (2 * k + 1) * L.vBound ^ (2 * k + 1) :=
    gexpect_trace_pow_bound (N := N) L (m := 2 * k) (k := k) le_rfl (by omega)
  calc (1 / (N : ℝ)) * (((N : ℝ) ^ k)⁻¹ * (Real.sqrt (N : ℝ))⁻¹)
        * |gexpect L (fun ω : Conf N S => ((GW L ω) ^ (2 * k + 1)).trace)|
      ≤ (1 / (N : ℝ)) * (((N : ℝ) ^ k)⁻¹ * (Real.sqrt (N : ℝ))⁻¹)
        * ((N : ℝ) ^ (k + 1) * ((k : ℝ) + 1) ^ (2 * k + 1) * L.vBound ^ (2 * k + 1)) :=
        mul_le_mul_of_nonneg_left hb (by positivity)
    _ = (((k : ℝ) + 1) ^ (2 * k + 1) * L.vBound ^ (2 * k + 1)) * (Real.sqrt (N : ℝ))⁻¹ := by
        field_simp
        ring

/-- **Universal vanishing of the odd spectral moments in the limit.**  For every
finitely supported centred unit-variance entry law and every `k`, the expected
`(2k+1)`-st moment of the empirical spectral distribution of `W/√N` tends to `0` as
`N → ∞` — matching `semicircleMoment (2k+1) = 0`.  This is the odd half of the
semicircle law, at all orders and for all entry laws. -/
theorem tendsto_gexpect_normalizedMoment_odd (L : EntryLaw S) (k : ℕ) :
    Tendsto (fun N : ℕ =>
        gexpect L (fun ω : Conf N S => WignerBridge.normalizedMoment (GW L ω) (2 * k + 1)))
      atTop (𝓝 0) := by
  have hC : (0 : ℝ) ≤ ((k : ℝ) + 1) ^ (2 * k + 1) * L.vBound ^ (2 * k + 1) := by
    have := L.vBound_nonneg
    positivity
  have hsq : Tendsto (fun N : ℕ => (Real.sqrt (N : ℝ))⁻¹) atTop (𝓝 0) := by
    refine Filter.Tendsto.comp tendsto_inv_atTop_zero ?_
    exact Filter.Tendsto.comp Real.tendsto_sqrt_atTop tendsto_natCast_atTop_atTop
  have hlim : Tendsto (fun N : ℕ =>
      (((k : ℝ) + 1) ^ (2 * k + 1) * L.vBound ^ (2 * k + 1)) * (Real.sqrt (N : ℝ))⁻¹)
      atTop (𝓝 0) := by
    simpa using hsq.const_mul (((k : ℝ) + 1) ^ (2 * k + 1) * L.vBound ^ (2 * k + 1))
  refine squeeze_zero_norm' ?_ hlim
  filter_upwards [eventually_gt_atTop 0] with N hN
  simpa using abs_gexpect_normalizedMoment_odd_le (N := N) L k hN

end WignerUniversal