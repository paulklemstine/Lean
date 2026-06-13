/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Chip-Firing and Divisor Theory on a Finite Graph — Theorems

Building on `Tropical.ChipFiring.Defs`, this file assembles the structural theory:

* the **algebraic layer** — linear (chip-firing) equivalence is a genuine `Equivalence`
  (hence a `Setoid`, making the Picard group a well-defined quotient), with degree a class
  invariant and the easy direction of Riemann–Roch (`neg_deg_no_effective_equiv`);
* the **analytic layer** — the discrete maximum principle, culminating in
  `lap_kernel_const_of_connected`: on a connected graph the Laplacian kernel is *exactly*
  the constant functions;
* the **numerical layer** — Serre duality, the genus-0 formula, monotonicity, and the unit
  increment of the Brill–Noether number;
* the **canonical divisor degree** `2g − 2`.

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)

-- !-- Lab Notebook -- !--
Hypothesis: Once `lap` is known to be an additive degree-zero constant-killing map, the
  *entire* algebraic layer is forced, and connectivity enters the theory at exactly one
  point — the maximum principle.
Result: Confirmed.  `linEquiv_equivalence` is a three-line application of
  `lap_zero`/`lap_neg`/`lap_add`; `linEquiv_deg` is `lap_deg_zero`; and
  `lap_kernel_const_of_connected` isolates connectivity to a single
  `Connected.preconnected` step propagating the argmax level set along walks.
Insight: The kernel-is-constants theorem is the *equality case* of the maximum principle:
  at a global maximum a harmonic firing pattern is flat across every incident edge
  (`lapNeighborConst`); `reachClosed` then spreads flatness across the whole graph.
Failure analysis: No statement here was disproved.  The only care needed was to feed the
  argmax both as a global bound (`hmax`) and as a per-vertex local bound (`hvmax`) so that
  `lapNeighborConst` applies at *every* vertex of the maximal level set, not just one.
-- !-- end -- !--
-/

import Tropical.ChipFiring.Defs

open Finset BigOperators SimpleGraph

variable {V : Type*} [Fintype V] (G : SimpleGraph V) [DecidableRel G.Adj]

/-! ## Effective divisors have non-negative degree -/

-- !-- A sum of non-negative coefficients is non-negative. -- !--
theorem Effective.divisorDegree_nonneg {D : Divisor V} (hD : Effective D) :
    0 ≤ divisorDegree D :=
  Finset.sum_nonneg (fun v _ => hD v)

/-! ## Linear (chip-firing) equivalence -/

/-- Two divisors are **linearly equivalent** when they differ by the Laplacian of some
firing pattern: `E = D + lap G f`.  This is the chip-firing relation. -/
def linEquiv (D E : Divisor V) : Prop := ∃ f : V → ℤ, E = D + lap G f

-- !-- Reflexivity is `lap_zero`: fire the zero pattern. -- !--
theorem linEquiv_refl (D : Divisor V) : linEquiv G D D :=
  ⟨0, by rw [lap_zero, add_zero]⟩

-- !-- Symmetry is `lap_neg`: reverse the firing pattern. -- !--
theorem linEquiv_symm {D E : Divisor V} (h : linEquiv G D E) : linEquiv G E D := by
  obtain ⟨f, rfl⟩ := h
  exact ⟨-f, by rw [lap_neg]; abel⟩

-- !-- Transitivity is `lap_add`: compose firing patterns. -- !--
theorem linEquiv_trans {D E F : Divisor V}
    (h₁ : linEquiv G D E) (h₂ : linEquiv G E F) : linEquiv G D F := by
  obtain ⟨f, rfl⟩ := h₁
  obtain ⟨g, rfl⟩ := h₂
  exact ⟨f + g, by rw [lap_add]; abel⟩

/-- Chip-firing (linear) equivalence is an equivalence relation. -/
theorem linEquiv_equivalence : Equivalence (linEquiv G) :=
  ⟨linEquiv_refl G, linEquiv_symm G, linEquiv_trans G⟩

/-- The setoid of linear equivalence; its quotient is the Picard group of `G`. -/
def linSetoid : Setoid (Divisor V) := ⟨linEquiv G, linEquiv_equivalence G⟩

-- !-- Degree is a class invariant because every Laplacian has degree zero
--     (`lap_deg_zero`). -- !--
theorem linEquiv_deg {D E : Divisor V} (h : linEquiv G D E) :
    divisorDegree D = divisorDegree E := by
  obtain ⟨f, rfl⟩ := h
  rw [divisorDegree_add, lap_deg_zero, add_zero]

-- !-- Easy direction of Baker–Norine (rank −1): a negative-degree divisor cannot be
--     equivalent to an effective one, since degree is invariant but effective degree is
--     `≥ 0`. -- !--
theorem neg_deg_no_effective_equiv {D : Divisor V} (hD : divisorDegree D < 0) :
    ¬ ∃ E, linEquiv G D E ∧ Effective E := by
  rintro ⟨E, hEq, hEff⟩
  have hdeg : divisorDegree D = divisorDegree E := linEquiv_deg G hEq
  have : 0 ≤ divisorDegree E := hEff.divisorDegree_nonneg
  linarith

/-! ## The discrete maximum principle -/

-- !-- At a global maximum every summand `f v − f u ≥ 0`, so the Laplacian is `≥ 0`. -- !--
theorem lap_max_principle (f : V → ℤ) (v : V) (h : ∀ u, f u ≤ f v) :
    0 ≤ (lap G f).coeff v := by
  rw [lap_coeff]
  exact Finset.sum_nonneg (fun u _ => by linarith [h u])

-- !-- Equality case: if `f` peaks at `v` and `lap G f` vanishes there, then a sum of
--     non-negative terms is zero, so each neighbour ties the maximum. -- !--
theorem lapNeighborConst (f : V → ℤ) (v : V) (hmax : ∀ u, f u ≤ f v)
    (hker : (lap G f).coeff v = 0) (w : V) (hw : G.Adj v w) : f w = f v := by
  rw [lap_coeff] at hker
  have hnn : ∀ u ∈ G.neighborFinset v, 0 ≤ f v - f u := fun u _ => by linarith [hmax u]
  have hzero := (Finset.sum_eq_zero_iff_of_nonneg hnn).1 hker
  have : f v - f w = 0 := hzero w (by rw [mem_neighborFinset]; exact hw)
  linarith

-- !-- A predicate closed under taking adjacent vertices is closed under reachability,
--     by induction on a connecting walk. -- !--
omit [Fintype V] [DecidableRel G.Adj] in
theorem reachClosed (p : V → Prop) (hcl : ∀ v, p v → ∀ w, G.Adj v w → p w)
    {a b : V} (hr : G.Reachable a b) (ha : p a) : p b := by
  obtain ⟨w⟩ := hr
  induction w with
  | nil => exact ha
  | cons hadj _ ih => exact ih (hcl _ ha _ hadj)

-- !-- Discrete maximum principle: on a connected graph the kernel of the Laplacian is
--     exactly the constants.  Spread the (adjacency-closed) maximal level set across the
--     graph using `reachClosed` and `Connected.preconnected`. -- !--
theorem lap_kernel_const_of_connected (hG : G.Connected) (f : V → ℤ)
    (hker : ∀ v, (lap G f).coeff v = 0) (a b : V) : f a = f b := by
  haveI : Nonempty V := hG.nonempty
  obtain ⟨m, -, hm⟩ :=
    Finset.exists_max_image (Finset.univ) f ⟨Classical.arbitrary V, Finset.mem_univ _⟩
  have hmax : ∀ u, f u ≤ f m := fun u => hm u (Finset.mem_univ u)
  have hcl : ∀ v, f v = f m → ∀ w, G.Adj v w → f w = f m := by
    intro v hv w hw
    have hvmax : ∀ u, f u ≤ f v := fun u => by rw [hv]; exact hmax u
    exact (lapNeighborConst G f v hvmax (hker v) w hw).trans hv
  have key : ∀ x, f x = f m := fun x =>
    reachClosed G (fun y => f y = f m) hcl (hG.preconnected m x) rfl
  rw [key a, key b]

/-- On a connected graph, a firing pattern is harmonic (in the Laplacian kernel) **iff**
it is constant. -/
theorem lap_kernel_iff_const (hG : G.Connected) (f : V → ℤ) :
    (∀ v, (lap G f).coeff v = 0) ↔ ∃ c, ∀ v, f v = c := by
  constructor
  · intro hker
    haveI : Nonempty V := hG.nonempty
    exact ⟨f (Classical.arbitrary V),
      fun v => lap_kernel_const_of_connected G hG f hker v (Classical.arbitrary V)⟩
  · rintro ⟨c, hc⟩ v
    have : f = fun _ => c := funext hc
    rw [this, lap_const]; rfl

/-! ## Degree of the canonical divisor -/

-- !-- `∑ (deg v − 2) = (∑ deg v) − 2|V| = 2|E| − 2|V| = 2g − 2`, using the handshake
--     lemma `sum_degrees_eq_twice_card_edges`. -- !--
theorem degree_canonicalDivisor :
    divisorDegree (canonicalDivisor G) = 2 * genus G - 2 := by
  unfold divisorDegree canonicalDivisor genus
  have hand : (∑ v, (G.degree v : ℤ)) = 2 * (G.edgeFinset.card : ℤ) := by
    have h := G.sum_degrees_eq_twice_card_edges
    have h2 : ((∑ v, G.degree v : ℕ) : ℤ) = ((2 * G.edgeFinset.card : ℕ) : ℤ) := by
      exact_mod_cast h
    push_cast at h2 ⊢; linarith [h2]
  rw [Finset.sum_sub_distrib, hand]
  simp [Finset.sum_const, Finset.card_univ]
  ring

/-! ## The Brill–Noether number `ρ(g,r,d) = g − (r+1)(g − d + r)` -/

-- !-- Serre duality: substitute `r ↦ g−1−d+r`, `d ↦ 2g−2−d` and expand with `ring`. -- !--
theorem bnNumber_serre_duality (g r d : ℤ) :
    bnNumber g r d = bnNumber g (g - 1 - d + r) (2 * g - 2 - d) := by
  unfold bnNumber; ring

-- !-- Genus-0 specialization: `ρ(0,r,d) = (r+1)(d−r)`. -- !--
theorem bnNumber_genus_zero (r d : ℤ) : bnNumber 0 r d = (r + 1) * (d - r) := by
  unfold bnNumber; ring

-- !-- Unit increment: raising the degree by one adds exactly `r+1`. -- !--
theorem bnNumber_succ_d (g r d : ℤ) :
    bnNumber g r (d + 1) = bnNumber g r d + (r + 1) := by
  unfold bnNumber; ring

-- !-- Strict monotonicity in degree for `r ≥ 0`, since the slope `r+1 ≥ 1 > 0`. -- !--
theorem bnNumber_strict_mono_d (g r : ℤ) (hr : 0 ≤ r) {d d' : ℤ} (h : d < d') :
    bnNumber g r d < bnNumber g r d' := by
  unfold bnNumber; nlinarith [h, hr]