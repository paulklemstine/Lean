import Mathlib
import Novelty.EmergentGeometryEntropyCone
import Novelty.EREPRBridge
import Novelty.EREPRThroatCapacity

/-!
# Bit threads: flows through an Einstein–Rosen bridge

The Ryu–Takayanagi prescription used in `Novelty.EmergentGeometryEntropyCone`
measures entanglement by *cutting* the bulk.  The dual "bit thread" picture
measures it by *flowing* through the bulk: entanglement is the maximal number of
Planck-thickness threads that can be routed from one boundary region to the
other.  This file introduces flows (`BitThreads`) on a bulk geometry and proves
the duality inequality

  `value(flow) ≤ area(any separating surface)`,

hence `value ≤ throat`, together with a matching flow for the elementary
one-throat wormhole, where the bound is attained: **max-flow = min-cut for a
single Einstein–Rosen bridge**.

Main results:

* `cutWeight_eq_crossSum` — the area of a surface as a one-sided double sum
  (the form flows interact with).
* `sum_antisymm_zero` — an antisymmetric flow contributes nothing inside a
  region; only the flux through its boundary survives.
* `BitThreads.value_le_cutWeight`, `BitThreads.value_le_throat` — **weak
  duality**: no thread configuration can carry more than the cross-section of the
  bridge.
* `pairThreads_value`, `pairModel_maxflow_eq_throat` — the bound is sharp: the
  elementary wormhole of weight `w` admits threads of value exactly `w`, equal to
  its throat capacity and to half its mutual information.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  If ER=EPR is more than a slogan, the entanglement of
a boundary pair should be *transportable* through the bridge: there should exist
a divergence-free, capacity-respecting flow whose flux equals the bridge
cross-section.

EXPERIMENT (Experimenter).  Weak duality is a two-step computation: (i) the flux
out of the source region equals the flux out of *any* admissible region
containing it (conservation kills the extra cells), and (ii) the internal part of
that flux cancels by antisymmetry, leaving a boundary term bounded by the
capacities.  Both steps are `Finset` identities: `Finset.sum_subset` and the
antisymmetric-sum-vanishing lemma.

ANALYSIS (Analyst).  The proof never uses finiteness beyond summability, and
never uses symmetry of the weights except through `cutWeight_eq_crossSum`.  The
converse (strong duality, i.e. existence of a saturating flow in general) is a
max-flow–min-cut theorem and is left as an explicit open direction; we verify it
by hand in the one-throat case.

CRITIQUE (Critic).  `capacity` is stated one-sidedly (`flow x y ≤ weight x y`);
combined with `antisymm` and symmetry of `weight` this is equivalent to
`|flow x y| ≤ weight x y`, so nothing is lost, and the sharp example shows the
class of flows is not degenerate.
-/

noncomputable section

namespace EmergentGeometry

open Finset

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Areas as one-sided sums -/

omit [Fintype V] [DecidableEq V] in
/-- An antisymmetric kernel summed over a square index set vanishes. -/
theorem sum_antisymm_zero (φ : V → V → ℝ) (hanti : ∀ x y, φ x y = -φ y x) (S : Finset V) :
    ∑ x ∈ S, ∑ y ∈ S, φ x y = 0 := by
  have key : ∑ x ∈ S, ∑ y ∈ S, φ x y = ∑ x ∈ S, ∑ y ∈ S, (-(φ x y)) := by
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl fun x _ => Finset.sum_congr rfl fun y _ => hanti y x
  simp only [Finset.sum_neg_distrib] at key
  linarith

omit [DecidableEq V] in
/-- The area of the surface bounding a region, written as a one-sided sum over
the pairs that cross it. -/
theorem cutWeight_eq_crossSum (G : BulkGraph V) (f : Region V) :
    cutWeight G f = ∑ x, ∑ y, (if f x = true ∧ f y = false then G.weight x y else 0) := by
  have h1 : ∀ x y : V, (sepBit (f x) (f y) : ℝ) * G.weight x y
      = (if f x = true ∧ f y = false then G.weight x y else 0)
        + (if f y = true ∧ f x = false then G.weight x y else 0) := by
    intro x y; cases hx : f x <;> cases hy : f y <;> simp [sepBit]
  have h2 : ∑ x, ∑ y, (if f y = true ∧ f x = false then G.weight x y else 0)
      = ∑ x, ∑ y, (if f x = true ∧ f y = false then G.weight x y else 0) := by
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl fun x _ => Finset.sum_congr rfl fun y _ => by
      rw [G.weight_symm]
  rw [cutWeight, Finset.sum_congr rfl (fun x _ => Finset.sum_congr rfl (fun y _ => h1 x y)),
    Finset.sum_congr rfl (fun x (_ : x ∈ univ) => Finset.sum_add_distrib),
    Finset.sum_add_distrib, h2]
  ring

omit [DecidableEq V] in
/-- The same area as a sum over the two sides of the surface. -/
theorem cutWeight_eq_sum_sides (G : BulkGraph V) (f : Region V) :
    cutWeight G f = ∑ x ∈ univ.filter (fun x => f x = true),
      ∑ y ∈ univ.filter (fun y => f y = false), G.weight x y := by
  rw [cutWeight_eq_crossSum, Finset.sum_filter]
  refine Finset.sum_congr rfl fun x _ => ?_
  by_cases hx : f x = true
  · rw [if_pos hx, Finset.sum_filter]
    exact Finset.sum_congr rfl fun y _ => by
      by_cases hy : f y = false <;> simp [hx, hy]
  · rw [if_neg hx]
    exact Finset.sum_eq_zero fun y _ => by simp [hx]

/-! ## Bit threads -/

/-- A **bit thread configuration** on a bulk geometry: an antisymmetric flow
whose magnitude never exceeds the local area element. -/
structure BitThreads (G : BulkGraph V) where
  /-- The oriented flux carried from one cell to another. -/
  flow : V → V → ℝ
  /-- Threads are oriented: reversing the orientation reverses the flux. -/
  antisymm : ∀ x y, flow x y = -flow y x
  /-- No more threads may cross a surface element than its area. -/
  capacity : ∀ x y, flow x y ≤ G.weight x y

variable {G : BulkGraph V}

/-- The net flux emanating from a cell. -/
def BitThreads.div (T : BitThreads G) (x : V) : ℝ := ∑ y, T.flow x y

/-- Threads are conserved away from the sources `A` and the sinks `B`. -/
def BitThreads.Conserved (T : BitThreads G) (A B : Region V) : Prop :=
  ∀ v, A v = false → B v = false → T.div v = 0

/-- The total flux emitted by the source region. -/
def BitThreads.value (T : BitThreads G) (A : Region V) : ℝ :=
  ∑ x ∈ univ.filter (fun x => A x = true), T.div x

/-- **Weak duality for bit threads.**  A conserved thread configuration cannot
carry more flux than the area of any surface separating its sources from its
sinks. -/
theorem BitThreads.value_le_cutWeight (T : BitThreads G) {A B σ : Region V}
    (hcons : T.Conserved A B) (hsep : Separates A B σ) :
    T.value A ≤ cutWeight G σ := by
  set S : Finset V := univ.filter (fun x => σ x = true) with hS
  set SA : Finset V := univ.filter (fun x => A x = true) with hSA
  -- (1) the flux out of the sources equals the flux out of the whole region `σ`
  have hsub : SA ⊆ S := by
    intro x hx
    rw [hSA, mem_filter] at hx
    rw [hS, mem_filter]
    exact ⟨mem_univ x, hsep.1 x hx.2⟩
  have hstep1 : T.value A = ∑ x ∈ S, T.div x := by
    refine Finset.sum_subset hsub fun x hxS hxA => ?_
    have hσx : σ x = true := by simpa [hS] using hxS
    have hA : A x = false := by simpa [hSA] using hxA
    have hB : B x = false := by
      by_contra hB'
      have hBx : B x = true := by
        cases h' : B x
        · exact absurd h' hB'
        · rfl
      rw [hsep.2 x hBx] at hσx
      exact Bool.noConfusion hσx
    exact hcons x hA hB
  -- (2) the flux inside `σ` cancels; only the flux through its surface survives
  have hsplit : ∀ x : V, T.div x = ∑ y ∈ S, T.flow x y + ∑ y ∈ Sᶜ, T.flow x y := by
    intro x
    rw [BitThreads.div, ← Finset.sum_add_sum_compl S (T.flow x)]
  have hstep2 : ∑ x ∈ S, T.div x = ∑ x ∈ S, ∑ y ∈ Sᶜ, T.flow x y := by
    rw [Finset.sum_congr rfl (fun x _ => hsplit x), Finset.sum_add_distrib,
      sum_antisymm_zero T.flow T.antisymm S, zero_add]
  -- (3) capacities bound the surviving flux by the area
  have hcompl : Sᶜ = univ.filter (fun y => σ y = false) := by
    ext y
    simp [hS, Bool.not_eq_true]
  have hstep3 : ∑ x ∈ S, ∑ y ∈ Sᶜ, T.flow x y ≤ cutWeight G σ := by
    rw [cutWeight_eq_sum_sides, ← hS, hcompl]
    exact Finset.sum_le_sum fun x _ => Finset.sum_le_sum fun y _ => T.capacity x y
  rw [hstep1, hstep2]
  exact hstep3

/-- **Bit threads cannot outrun the bridge.**  The flux of a conserved thread
configuration is at most the throat capacity of the Einstein–Rosen bridge
joining its sources to its sinks. -/
theorem BitThreads.value_le_throat (T : BitThreads G) {A B : Region V}
    (hcons : T.Conserved A B) (hAB : Disj A B) :
    T.value A ≤ throat G A B := by
  obtain ⟨σ, hσ, hval⟩ := exists_min_throat_surface G hAB
  rw [hval]
  exact T.value_le_cutWeight hcons hσ

/-! ## Sharpness: threading the elementary wormhole -/

/-- The thread configuration carrying `w` units through the single throat of the
two-cell wormhole. -/
def pairThreads (w : ℝ) (hw : 0 ≤ w) : BitThreads (pairModel w hw).toBulkGraph where
  flow x y := if x = 0 ∧ y = 1 then w else if x = 1 ∧ y = 0 then -w else 0
  antisymm x y := by
    fin_cases x <;> fin_cases y <;> norm_num
  capacity x y := by
    fin_cases x <;> fin_cases y
    all_goals simp [pairModel]
    all_goals linarith

lemma pairThreads_conserved (w : ℝ) (hw : 0 ≤ w) :
    (pairThreads w hw).Conserved (single 0) (single 1) := by
  intro v hA hB
  fin_cases v
  · simp [single] at hA
  · simp [single] at hB

/-- The elementary wormhole carries exactly `w` units of thread. -/
theorem pairThreads_value (w : ℝ) (hw : 0 ≤ w) :
    (pairThreads w hw).value (single 0) = w := by
  have hfilter : (univ.filter (fun x : Fin 2 => single 0 x = true)) = {0} := by
    ext x
    fin_cases x <;> simp [single]
  rw [BitThreads.value, hfilter]
  simp [BitThreads.div, pairThreads, Fin.sum_univ_two]

/-- **Max-flow = min-cut for a single Einstein–Rosen bridge.**  For the
elementary wormhole the thread configuration `pairThreads` is conserved, is
optimal among all conserved configurations, and exactly saturates the throat
capacity — which is in turn half the mutual information of the two mouths. -/
theorem pairModel_maxflow_eq_throat (w : ℝ) (hw : 0 ≤ w) :
    (pairThreads w hw).Conserved (single 0) (single 1) ∧
      (pairThreads w hw).value (single 0)
        = throat (pairModel w hw).toBulkGraph (single 0) (single 1) ∧
      (∀ T : BitThreads (pairModel w hw).toBulkGraph,
        T.Conserved (single 0) (single 1) →
          T.value (single 0) ≤ (pairThreads w hw).value (single 0)) ∧
      (pairThreads w hw).value (single 0)
        = mutualInfo (pairModel w hw) (single 0) (single 1) / 2 := by
  obtain ⟨hthroat, hI⟩ := pairModel_throat w hw
  have hdisj : Disj (single (0 : Fin 2)) (single 1) := by
    intro x hx
    fin_cases x <;> simp_all [single]
  have hval : (pairThreads w hw).value (single 0) = w := pairThreads_value w hw
  refine ⟨pairThreads_conserved w hw, by rw [hval, hthroat], fun T hT => ?_, ?_⟩
  · rw [hval]
    have := T.value_le_throat hT hdisj
    rwa [hthroat] at this
  · rw [hval, hI, hthroat]
    ring

end EmergentGeometry