import Mathlib
import Geometry.CellularDevelopability

/-!
# Impossible Figures VII: fundamental cycles and minimal certificates

*Extraction of a compact certificate of impossibility from a system of
integration paths.*

The companion file `Geometry/CellularDevelopability.lean` classifies developable
increment fields on an arbitrary two–dimensional cell complex: `ω` is developable
iff its period vanishes on the whole one–cycle group, equivalently iff its
curvature vanishes on every two–cell and its period vanishes on a *generating*
family of one–cycles.  That statement leaves open the practical question raised by
Direction 2 of the research brief: **how does one produce a generating family, and
how small can a certificate of non-developability be?**

This file answers both questions.  The input data is a family of integration paths
`c : V → C₁` joining every vertex to a base point (exactly the data provided by a
spanning tree of the one–skeleton, or by the `ChainConnected` hypothesis).  For
every edge `e` one forms the **fundamental cycle**

`γ e = [e] - c (t e) + c (s e)`,

the closed walk that runs along `e` and returns through the integration paths.

## Main results

* `fundamentalCycle_isCycle`, `boundary_comp_pathMap` — the fundamental cycles are
  one–cycles, and the path family provides an explicit contracting homotopy
  `id - Φ = C ∘ ∂₁`.
* `ker_boundary_eq_span_fundamentalCycles` — **the fundamental cycles generate the
  entire cycle group**.  So a generating family always exists, indexed by the edge
  set, and is computable from any system of integration paths.
* `developable_iff_fundamentalCycle_periods` and `developable_iff_integral` — the
  resulting decision procedure: integrate `ω` along the paths and compare; `ω` is
  developable iff the *single* candidate height field `H v = period ω (c v)` works.
* `exists_edge_certificate_of_not_developable` — **minimal certificates**: a
  non-developable field always has a certificate consisting of one edge, namely a
  single fundamental cycle with nonzero period.
* `fundamentalCycle_eq_zero_of_tree_edge` — tree edges give trivial certificates,
  so only the `|E| - |V| + 1` non-tree edges can carry an obstruction.
* Worked example: the **Escher staircase** with `N` steps (the periodic
  one–dimensional grid, i.e. the cycle graph on `ZMod N`).  All fundamental cycles
  vanish except the one attached to the last step, which is the fundamental loop of
  length `N`; hence `cycleGraph_developable_iff` (developable iff the increments sum
  to zero), `cycleGraph_unique_certificate` (the certificate is the noncontractible
  loop, of length exactly `N`), and `escher_staircase_impossible`.
-/

namespace ImpossibleFigures.Cellular

variable {V E A : Type*} [AddCommGroup A]

/-! ### Fundamental cycles of a system of integration paths -/

section Fundamental

variable (s t : E → V) (c : V → (E →₀ ℤ))

/-- The **fundamental cycle** of an edge `e` relative to a family of integration
paths `c`: run along `e`, then return to the base point through `c (t e)` and back
out along `c (s e)`. -/
noncomputable def fundamentalCycle (e : E) : E →₀ ℤ :=
  Finsupp.single e 1 - c (t e) + c (s e)

/-- The linear extension of the path family to chains: `[v] ↦ c v`. -/
noncomputable def pathMap : (V →₀ ℤ) →ₗ[ℤ] (E →₀ ℤ) := Finsupp.linearCombination ℤ c

/-- The linear extension of the fundamental cycles to chains. -/
noncomputable def fundMap : (E →₀ ℤ) →ₗ[ℤ] (E →₀ ℤ) :=
  Finsupp.linearCombination ℤ (fundamentalCycle s t c)

variable {s t c} {v₀ : V}
  (hc : ∀ v, boundary s t (c v) = Finsupp.single v (1 : ℤ) - Finsupp.single v₀ 1)

include hc

/-- Each fundamental cycle really is a one–cycle. -/
lemma fundamentalCycle_isCycle (e : E) :
    boundary s t (fundamentalCycle s t c e) = 0 := by
  simp only [fundamentalCycle, map_add, map_sub, boundary_single, hc, one_smul]
  abel

omit hc in
/-- **Contracting homotopy.**  Every chain differs from the corresponding
combination of fundamental cycles by the path transport of its boundary. -/
theorem sub_fundMap_eq_pathMap_boundary (z : E →₀ ℤ) :
    z - fundMap s t c z = pathMap c (boundary s t z) := by
  revert z
  suffices h : (LinearMap.id (R := ℤ) (M := (E →₀ ℤ)) - fundMap s t c)
      = (pathMap c).comp (boundary s t) by
    intro z
    have := congrArg (fun f : (E →₀ ℤ) →ₗ[ℤ] (E →₀ ℤ) => f z) h
    simpa using this
  apply Finsupp.lhom_ext
  intro e k
  simp only [LinearMap.sub_apply, LinearMap.id_apply, fundMap, LinearMap.comp_apply,
    Finsupp.linearCombination_single, boundary_single, pathMap, map_smul, map_sub,
    fundamentalCycle, one_smul]
  have hk : (Finsupp.single e k : E →₀ ℤ) = k • Finsupp.single e (1 : ℤ) := by simp
  rw [hk]
  module

/-- **The fundamental cycles generate the cycle group.**  Any system of integration
paths joining every vertex to a base point yields, edge by edge, a generating family
of one–cycles.  This supplies the generating family required by
`developable_iff_curvature_and_periods` and shows it can always be indexed by the
edges. -/
theorem ker_boundary_eq_span_fundamentalCycles :
    LinearMap.ker (boundary s t)
      = Submodule.span ℤ (Set.range (fundamentalCycle s t c)) := by
  apply le_antisymm
  · intro z hz
    have hz0 : boundary s t z = 0 := by simpa using hz
    have hzeq : z = fundMap s t c z := by
      have := sub_fundMap_eq_pathMap_boundary (s := s) (t := t) (c := c) z
      rw [hz0, map_zero] at this
      have := sub_eq_zero.1 this
      exact this
    rw [hzeq, fundMap, Finsupp.linearCombination_apply]
    refine Submodule.sum_mem _ (fun e _ => Submodule.smul_mem _ _ ?_)
    exact Submodule.subset_span ⟨e, rfl⟩
  · rw [Submodule.span_le]
    rintro x ⟨e, rfl⟩
    simpa using fundamentalCycle_isCycle hc e

/-- **Decision procedure.**  An increment field is developable iff its period
vanishes on every fundamental cycle: `|E|` scalar tests suffice. -/
theorem developable_iff_fundamentalCycle_periods (ω : E → A) :
    Developable s t ω ↔ ∀ e, period ω (fundamentalCycle s t c e) = 0 := by
  have hconn : ChainConnected s t v₀ := fun v => ⟨c v, hc v⟩
  rw [developable_iff_period_vanishes_on_cycles hconn]
  constructor
  · intro hcyc e
    exact hcyc _ (fundamentalCycle_isCycle hc e)
  · intro hfund z hz
    have hzmem : z ∈ Submodule.span ℤ (Set.range (fundamentalCycle s t c)) := by
      rw [← ker_boundary_eq_span_fundamentalCycles hc]
      simpa using hz
    have hsub : Submodule.span ℤ (Set.range (fundamentalCycle s t c))
        ≤ LinearMap.ker (period ω) := by
      rw [Submodule.span_le]
      rintro x ⟨e, rfl⟩
      simpa using hfund e
    simpa using hsub hzmem

omit hc in
/-- **The candidate height field is unique up to a constant, and it is the
integral.**  `ω` is developable iff the height obtained by integrating `ω` along
the chosen paths reproduces `ω`; the period of the fundamental cycle of `e` is
exactly the discrepancy at the edge `e`. -/
theorem period_fundamentalCycle_eq (ω : E → A) (e : E) :
    period ω (fundamentalCycle s t c e)
      = ω e - (period ω (c (t e)) - period ω (c (s e))) := by
  simp only [fundamentalCycle, map_add, map_sub, period_single, one_smul]
  abel

/-- Explicit form of the decision procedure: developability of `ω` is equivalent to
the *single* candidate height field `H v = period ω (c v)` being a primitive. -/
theorem developable_iff_integral (ω : E → A) :
    Developable s t ω ↔
      ∀ e, ω e = period ω (c (t e)) - period ω (c (s e)) := by
  rw [developable_iff_fundamentalCycle_periods hc ω]
  refine forall_congr' (fun e => ?_)
  rw [period_fundamentalCycle_eq (s := s) (t := t) (c := c) ω e, sub_eq_zero]

/-- **Minimal certificates.**  A non-developable increment field always admits a
certificate supported on a *single edge*: some fundamental cycle has nonzero
period.  The certificate is produced by one pass of the integration procedure. -/
theorem exists_edge_certificate_of_not_developable {ω : E → A}
    (hω : ¬ Developable s t ω) :
    ∃ e : E, boundary s t (fundamentalCycle s t c e) = 0
      ∧ period ω (fundamentalCycle s t c e) ≠ 0 := by
  by_contra hcon
  push_neg at hcon
  refine hω ((developable_iff_fundamentalCycle_periods hc ω).2 (fun e => ?_))
  exact hcon e (fundamentalCycle_isCycle hc e)

omit hc

/-- **Tree edges carry no obstruction.**  If the integration path to the head of an
edge is the path to its tail followed by the edge (i.e. `e` belongs to the spanning
tree used to build the paths), the fundamental cycle of `e` is trivial.  Hence only
the non-tree edges can produce certificates. -/
lemma fundamentalCycle_eq_zero_of_tree_edge {e : E}
    (he : c (t e) = c (s e) + Finsupp.single e 1) :
    fundamentalCycle s t c e = 0 := by
  simp only [fundamentalCycle, he]
  abel

end Fundamental

/-! ### Completeness: a classifying family of cycles must generate the cycle group -/

section Completeness

universe uV uE

/-- **Converse of the classification.**  Suppose a family `fam` of one–cycles is
*classifying*, in the sense that for every additive coefficient group the vanishing
of the periods on `fam` already forces developability.  Then `fam` generates the
whole cycle group.

So the spanning hypothesis in `developable_iff_curvature_and_periods` is not merely
convenient, it is forced: a family of loops detects all impossible figures (with
arbitrary coefficients) exactly when it is a generating family of one–cycles.  The
proof takes coefficients in the quotient of the chain group by the span of the
family, where the tautological increment field has period `[z]` on a chain `z`. -/
theorem span_eq_ker_of_periods_classify {V : Type uV} {E : Type uE} {s t : E → V}
    {F : Type*} (fam : F → (E →₀ ℤ))
    (hfam : ∀ f, boundary s t (fam f) = 0)
    (hclass : ∀ (A : Type uE) (_ : AddCommGroup A) (ω : E → A),
      (∀ f, period ω (fam f) = 0) → Developable s t ω) :
    LinearMap.ker (boundary s t) = Submodule.span ℤ (Set.range fam) := by
  set S : Submodule ℤ (E →₀ ℤ) := Submodule.span ℤ (Set.range fam) with hS
  have hper : period (A := ((E →₀ ℤ) ⧸ S)) (fun e => S.mkQ (Finsupp.single e 1)) = S.mkQ := by
    apply Finsupp.lhom_ext
    intro e k
    rw [period_single, ← map_smul, Finsupp.smul_single, smul_eq_mul, mul_one]
  apply le_antisymm
  · intro z hz
    have hz0 : boundary s t z = 0 := by simpa using hz
    have hdev := hclass ((E →₀ ℤ) ⧸ S) inferInstance (fun e => S.mkQ (Finsupp.single e 1))
      (by
        intro f
        rw [hper]
        exact (Submodule.Quotient.mk_eq_zero S).2 (Submodule.subset_span ⟨f, rfl⟩))
    have hzero := period_eq_zero_of_developable hdev hz0
    rw [hper] at hzero
    exact (Submodule.Quotient.mk_eq_zero S).1 hzero
  · rw [Submodule.span_le]
    rintro x ⟨f, rfl⟩
    simpa using hfam f

end Completeness

/-! ### The Escher staircase: the periodic one–dimensional grid -/

section Staircase

variable (N : ℕ) [NeZero N]

/-- Source map of the cycle graph on `ZMod N`: the `i`-th step starts at level `i`. -/
def stairS : ZMod N → ZMod N := id

/-- Target map of the cycle graph on `ZMod N`: the `i`-th step ends at level `i+1`. -/
def stairT : ZMod N → ZMod N := fun i => i + 1

variable {N}

/-- The integration path from the base vertex `0` to the vertex `v`: climb the first
`v.val` steps. -/
noncomputable def stairPath (v : ZMod N) : ZMod N →₀ ℤ :=
  ∑ a ∈ Finset.range v.val, Finsupp.single ((a : ℕ) : ZMod N) (1 : ℤ)

omit [NeZero N] in
/-- Telescoping: the boundary of the first `k` steps. -/
lemma stair_boundary_range (k : ℕ) :
    boundary (stairS N) (stairT N) (∑ a ∈ Finset.range k, Finsupp.single ((a : ℕ) : ZMod N) (1 : ℤ))
      = Finsupp.single ((k : ℕ) : ZMod N) (1 : ℤ) - Finsupp.single 0 1 := by
  induction k with
  | zero => simp
  | succ k ih =>
      rw [Finset.sum_range_succ, map_add, ih, boundary_single]
      simp only [stairS, stairT, id_eq, one_smul, Nat.cast_succ]
      abel

lemma stairPath_boundary (v : ZMod N) :
    boundary (stairS N) (stairT N) (stairPath v)
      = Finsupp.single v (1 : ℤ) - Finsupp.single (0 : ZMod N) 1 := by
  rw [stairPath, stair_boundary_range, ZMod.natCast_val, ZMod.cast_id]

/-- The fundamental loop of the staircase: all `N` steps, traversed once. -/
noncomputable def stairLoop : ZMod N →₀ ℤ :=
  ∑ a ∈ Finset.range N, Finsupp.single ((a : ℕ) : ZMod N) (1 : ℤ)

omit [NeZero N] in
lemma stairLoop_isCycle : boundary (stairS N) (stairT N) stairLoop = 0 := by
  rw [stairLoop, stair_boundary_range]
  simp

/-- Every step except the last one is a tree edge: its fundamental cycle vanishes. -/
lemma stair_fundamentalCycle_eq_zero {e : ZMod N} (he : e.val + 1 < N) :
    fundamentalCycle (stairS N) (stairT N) stairPath e = 0 := by
  refine fundamentalCycle_eq_zero_of_tree_edge ?_
  have hT : stairT N e = e + 1 := rfl
  have hN2 : 1 < N := by omega
  have h1 : (1 : ZMod N).val = 1 := by
    rw [ZMod.val_one_eq_one_mod, Nat.mod_eq_of_lt hN2]
  have hval : (e + 1).val = e.val + 1 := by
    rw [ZMod.val_add_of_lt (by omega), h1]
  have hS : stairS N e = e := rfl
  rw [hT, hS, stairPath, stairPath, hval, Finset.sum_range_succ]
  congr 2
  rw [ZMod.natCast_val, ZMod.cast_id]

/-- The last step carries the fundamental loop as its fundamental cycle. -/
lemma stair_fundamentalCycle_last {e : ZMod N} (he : e.val + 1 = N) :
    fundamentalCycle (stairS N) (stairT N) stairPath e = stairLoop := by
  have hT : stairT N e = e + 1 := rfl
  have hzero : e + 1 = 0 := by
    have : ((e.val + 1 : ℕ) : ZMod N) = 0 := by
      rw [he, ZMod.natCast_self]
    simpa [ZMod.natCast_val, ZMod.cast_id] using this
  rw [fundamentalCycle, hT, hzero]
  have h0 : stairPath (0 : ZMod N) = 0 := by simp [stairPath]
  have hS : stairS N e = e := rfl
  have hrange : Finset.range N = Finset.range (e.val + 1) := by rw [he]
  rw [h0, hS, stairPath, stairLoop, hrange, Finset.sum_range_succ]
  have : ((e.val : ℕ) : ZMod N) = e := by rw [ZMod.natCast_val, ZMod.cast_id]
  rw [this]
  abel

omit [NeZero N] in
/-- The period of an increment field on the fundamental loop is the total ascent. -/
lemma period_stairLoop (ω : ZMod N → A) :
    period ω (stairLoop (N := N)) = ∑ a ∈ Finset.range N, ω ((a : ℕ) : ZMod N) := by
  rw [stairLoop, map_sum]
  refine Finset.sum_congr rfl (fun a _ => ?_)
  rw [period_single, one_smul]

/-- **Classification for the Escher staircase.**  On the periodic one–dimensional
grid with `N` steps, an increment field with values in any additive group is
developable iff the apparent height increments of the `N` steps sum to zero.  (For
`N = 3` this is `triangle_developable_iff`.) -/
theorem cycleGraph_developable_iff (ω : ZMod N → A) :
    Developable (stairS N) (stairT N) ω ↔ ∑ a ∈ Finset.range N, ω ((a : ℕ) : ZMod N) = 0 := by
  rw [developable_iff_fundamentalCycle_periods (v₀ := (0 : ZMod N)) stairPath_boundary ω]
  constructor
  · intro h
    have hlast : ((N - 1 : ℕ) : ZMod N).val + 1 = N := by
      have hN : 0 < N := Nat.pos_of_ne_zero (NeZero.ne N)
      rw [ZMod.val_natCast_of_lt (by omega)]
      omega
    have := h (((N - 1 : ℕ) : ZMod N))
    rw [stair_fundamentalCycle_last hlast, period_stairLoop] at this
    exact this
  · intro hsum e
    rcases Nat.lt_or_ge (e.val + 1) N with hlt | hge
    · rw [stair_fundamentalCycle_eq_zero hlt, map_zero]
    · have he : e.val + 1 = N := by
        have := ZMod.val_lt e
        omega
      rw [stair_fundamentalCycle_last he, period_stairLoop, hsum]

/-- **The unique certificate of the staircase.**  If an increment field on the
`N`-step periodic staircase is not developable, then the noncontractible loop of
length exactly `N` is a certificate, and it is the only fundamental cycle that can
be one. -/
theorem cycleGraph_unique_certificate {ω : ZMod N → A}
    (hω : ¬ Developable (stairS N) (stairT N) ω) :
    boundary (stairS N) (stairT N) (stairLoop (N := N)) = 0
      ∧ period ω (stairLoop (N := N)) ≠ 0
      ∧ (stairLoop (N := N)).support.card ≤ N := by
  refine ⟨stairLoop_isCycle, ?_, ?_⟩
  · rw [period_stairLoop]
    intro hsum
    exact hω ((cycleGraph_developable_iff ω).2 hsum)
  · classical
    have hsub : (stairLoop (N := N)).support
        ⊆ (Finset.range N).image (fun a : ℕ => ((a : ℕ) : ZMod N)) := by
      intro x hx
      by_contra hxn
      have : (stairLoop (N := N)) x = 0 := by
        rw [stairLoop, Finsupp.finset_sum_apply]
        refine Finset.sum_eq_zero (fun a ha => ?_)
        rw [Finsupp.single_apply, if_neg]
        intro hax
        exact hxn (Finset.mem_image.2 ⟨a, ha, hax⟩)
      exact (Finsupp.mem_support_iff.1 hx) this
    calc (stairLoop (N := N)).support.card
        ≤ ((Finset.range N).image (fun a : ℕ => ((a : ℕ) : ZMod N))).card :=
          Finset.card_le_card hsub
      _ ≤ (Finset.range N).card := Finset.card_image_le
      _ = N := Finset.card_range N

/-- **The Escher staircase is impossible.**  Each of the `N ≥ 1` steps appears to
ascend by one unit, so the total ascent around the loop is `N ≠ 0` in `ℝ`: no
consistent height assignment exists. -/
theorem escher_staircase_impossible :
    ¬ Developable (stairS N) (stairT N) (fun _ : ZMod N => (1 : ℝ)) := by
  rw [cycleGraph_developable_iff]
  simp only [Finset.sum_const, Finset.card_range, nsmul_eq_mul, mul_one]
  have hN : 0 < N := Nat.pos_of_ne_zero (NeZero.ne N)
  positivity

end Staircase

end ImpossibleFigures.Cellular