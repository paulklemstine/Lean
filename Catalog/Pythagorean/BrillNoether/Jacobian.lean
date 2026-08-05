/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Catalog.Pythagorean.BrillNoether.Divisors
import Catalog.Pythagorean.BrillNoether.Reduced
import Catalog.Pythagorean.BrillNoether.ReducedUnique

/-!
# Finiteness of the Jacobian and a bound on the number of divisor classes

Reduction at a base vertex `q` gives a canonical representative in every linear
equivalence class of divisors (`BrillNoetherReducedUnique.exists_isReduced` and
`BrillNoetherReducedUnique.reduced_unique`).  A `q`-reduced divisor `D` satisfies
`0 ≤ D v ≤ deg v - 1` for every `v ≠ q`, and its value at `q` is determined by the
degree.  Hence the reduced divisors of a fixed degree form a *finite* set of size
at most `∏_{v ≠ q} deg v`, and this set is a complete and irredundant system of
representatives for the divisor classes of that degree.

Main results:

* `BrillNoetherJacobian.exists_reps` — for every degree `d` there is a finite set
  `R` of divisors such that every divisor of degree `d` is linearly equivalent to a
  member of `R`, distinct members of `R` are inequivalent, and
  `#R ≤ ∏_{v ≠ q} deg v`.  In particular the group of degree-zero divisor classes
  (the Jacobian, or critical group, of the graph) is finite.
* `BrillNoetherJacobian.card_le_prod_degree` — any family of pairwise inequivalent
  divisors of a fixed degree has at most `∏_{v ≠ q} deg v` members.

The Jacobian of a connected graph in fact has exactly `κ(G)` elements, the number
of spanning trees (Kirchhoff's matrix-tree theorem); the bound proved here is the
elementary one coming from the reduced-divisor normal form.
-/

open Finset SimpleGraph

namespace BrillNoetherJacobian

open BrillNoetherDivisor BrillNoetherReduced BrillNoetherReducedUnique

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- The box of vertex data of a `q`-reduced divisor: `0` at `q` and a value in
`[0, deg v - 1]` at every other vertex. -/
def box (q : V) : Finset (V → ℤ) :=
  Fintype.piFinset fun v => if v = q then {0} else Finset.Icc (0 : ℤ) ((G.degree v : ℤ) - 1)

lemma card_box (q : V) : #(box G q) = ∏ v ∈ univ.erase q, G.degree v := by
  classical
  rw [box, Fintype.card_piFinset,
    ← Finset.prod_erase_mul (univ : Finset V)
      (fun v => #(if v = q then ({0} : Finset ℤ) else Finset.Icc (0 : ℤ) ((G.degree v : ℤ) - 1)))
      (Finset.mem_univ q)]
  have hq : #(if q = q then ({0} : Finset ℤ) else Finset.Icc (0 : ℤ) ((G.degree q : ℤ) - 1)) = 1 := by
    simp
  rw [hq, mul_one]
  refine Finset.prod_congr rfl fun v hv => ?_
  rw [if_neg (Finset.ne_of_mem_erase hv), Int.card_Icc]
  simp

/-- Rebuild a divisor of degree `d` from its values away from `q`. -/
def fromBox (q : V) (d : ℤ) (g : V → ℤ) : Divisor V :=
  fun v => if v = q then d - ∑ u ∈ univ.erase q, g u else g v

/-- The candidate set of `q`-reduced divisors of degree `d`. -/
noncomputable def reps (q : V) (d : ℤ) : Finset (Divisor V) :=
  letI := Classical.decPred (IsReduced G q)
  ((box G q).image (fromBox q d)).filter (IsReduced G q)

lemma card_reps_le (q : V) (d : ℤ) : #(reps G q d) ≤ ∏ v ∈ univ.erase q, G.degree v := by
  classical
  calc #(reps G q d) ≤ #((box G q).image (fromBox q d)) := by
        rw [reps]; exact Finset.card_filter_le _ _
    _ ≤ #(box G q) := Finset.card_image_le
    _ = ∏ v ∈ univ.erase q, G.degree v := card_box G q

lemma isReduced_of_mem_reps {q : V} {d : ℤ} {D : Divisor V} (h : D ∈ reps G q d) :
    IsReduced G q D := by
  classical
  rw [reps] at h
  exact (Finset.mem_filter.mp h).2

/-- Every `q`-reduced divisor of degree `d` belongs to `reps G q d`. -/
lemma mem_reps_of_isReduced {q : V} {d : ℤ} {D : Divisor V} (hred : IsReduced G q D)
    (hdeg : deg D = d) : D ∈ reps G q d := by
  classical
  rw [reps]
  refine Finset.mem_filter.mpr ⟨Finset.mem_image.mpr ⟨fun v => if v = q then 0 else D v, ?_, ?_⟩,
    hred⟩
  · refine Fintype.mem_piFinset.mpr fun v => ?_
    by_cases hv : v = q
    · simp [hv]
    · have h0 : 0 ≤ D v := hred.1 v hv
      have h1 : D v ≤ (G.degree v : ℤ) - 1 := by
        have := hred.lt_degree G hv
        omega
      simp [hv, Finset.mem_Icc, h0, h1]
  · funext v
    by_cases hv : v = q
    · subst hv
      have hsplit : deg D = D v + ∑ u ∈ univ.erase v, D u :=
        (Finset.add_sum_erase _ _ (Finset.mem_univ v)).symm
      have hsum : ∑ u ∈ univ.erase v, (if u = v then (0 : ℤ) else D u)
          = ∑ u ∈ univ.erase v, D u :=
        Finset.sum_congr rfl fun u hu => by rw [if_neg (Finset.ne_of_mem_erase hu)]
      simp only [fromBox, hsum, if_true]
      omega
    · simp [fromBox, hv]

/-- **A finite, complete and irredundant system of representatives.**  On a
connected graph, for every degree `d` the set `reps G q d` of `q`-reduced divisors
of degree `d` meets every linear equivalence class of degree-`d` divisors exactly
once, and it has at most `∏_{v ≠ q} deg v` elements.  In particular there are only
finitely many divisor classes of each degree: the Jacobian of a connected graph is
finite. -/
theorem exists_reps (hG : G.Connected) (q : V) (d : ℤ) :
    ∃ R : Finset (Divisor V),
      (∀ D : Divisor V, deg D = d → ∃ D₀ ∈ R, LinEquiv G D D₀) ∧
      (∀ D₀ ∈ R, ∀ D₁ ∈ R, LinEquiv G D₀ D₁ → D₀ = D₁) ∧
      #R ≤ ∏ v ∈ univ.erase q, G.degree v := by
  refine ⟨reps G q d, fun D hD => ?_, fun D₀ h₀ D₁ h₁ hlin => ?_, card_reps_le G q d⟩
  · obtain ⟨f, hf⟩ := exists_isReduced G hG q D
    have hdeg : deg (D + lap G f) = d := by rw [deg_add, deg_lap, add_zero, hD]
    exact ⟨D + lap G f, mem_reps_of_isReduced G hf hdeg, ⟨f, rfl⟩⟩
  · exact reduced_unique G (isReduced_of_mem_reps G h₀) (isReduced_of_mem_reps G h₁) hlin

/-- **A bound on the number of divisor classes of a fixed degree.**  On a connected
graph, any family of pairwise linearly inequivalent divisors of the same degree has
at most `∏_{v ≠ q} deg v` members, for every choice of base vertex `q`. -/
theorem card_le_prod_degree (hG : G.Connected) (q : V) (d : ℤ) (T : Finset (Divisor V))
    (hdeg : ∀ D ∈ T, deg D = d)
    (hpw : ∀ D ∈ T, ∀ D' ∈ T, LinEquiv G D D' → D = D') :
    #T ≤ ∏ v ∈ univ.erase q, G.degree v := by
  classical
  obtain ⟨R, hcomplete, hirred, hcard⟩ := exists_reps G hG q d
  refine le_trans (Finset.card_le_card_of_injOn
    (fun D => if h : ∃ D₀ ∈ R, LinEquiv G D D₀ then h.choose else D) ?_ ?_) hcard
  · intro D hD
    have h : ∃ D₀ ∈ R, LinEquiv G D D₀ := hcomplete D (hdeg D hD)
    dsimp only
    rw [dif_pos h]
    exact h.choose_spec.1
  · intro D hD D' hD' hEq
    have h : ∃ D₀ ∈ R, LinEquiv G D D₀ := hcomplete D (hdeg D hD)
    have h' : ∃ D₀ ∈ R, LinEquiv G D' D₀ := hcomplete D' (hdeg D' hD')
    dsimp only at hEq
    rw [dif_pos h, dif_pos h'] at hEq
    have hlin : LinEquiv G D D' :=
      linEquiv_trans G h.choose_spec.2
        (hEq ▸ linEquiv_symm G h'.choose_spec.2 : LinEquiv G h.choose D')
    exact hpw D hD D' hD' hlin

end BrillNoetherJacobian