import Catalog.Bridges.BerggrenHarmonicMeasure

/-!
# The Berggren boundary is a Cantor set

The boundary `Bdry = ℕ → Fin 3` of the Berggren tree of primitive Pythagorean triples,
carrying the product of the discrete topologies (equivalently, the 3-adic topology in which
two boundary points are close when they share a long common prefix), satisfies the four
defining properties of a Cantor space.

## Main results

* `cyl_isClopen`, `cyl_mem_nhds`, `cyl_nhds_basis` : the cylinders `cyl n x` are clopen and
  form a neighbourhood basis at `x`; so the topology really is the 3-adic prefix topology.
* `compactSpace_bdry`, `totallyDisconnectedSpace_bdry`, `secondCountable_bdry` : the boundary
  is compact, totally disconnected and metrizable.
* `perfectSpace_bdry` : it has **no isolated points**: from any boundary point one can
  perturb a single (arbitrarily deep) letter, and the resulting sequence of distinct points
  converges back to it.
* `cyl_nontrivial` : every cylinder — every node of the Berggren tree — has at least two
  distinct boundary points below it, i.e. every subtree branches forever.
* `berggren_boundary_is_cantor` : the package of the four Cantor axioms.  By Brouwer's
  characterisation of the Cantor set (a nonempty compact, perfect, totally disconnected,
  metrizable space), the Berggren boundary is homeomorphic to the classical middle-thirds
  Cantor set; the homeomorphism itself is not formalised here since Brouwer's theorem is not
  available in Mathlib.
-/

namespace BerggrenHarmonic

open Filter Topology Set

/-! ## Cylinders are a clopen basis -/

lemma cyl_isOpen (n : ℕ) (v : Bdry) : IsOpen (cyl n v) := by
  have hrw : cyl n v = ⋂ i ∈ Finset.range n, (fun x : Bdry => x i) ⁻¹' {v i} := by
    ext x; simp [cyl]
  rw [hrw]
  exact isOpen_biInter_finset (fun i _ => (isOpen_discrete _).preimage (continuous_apply i))

lemma cyl_isClosed (n : ℕ) (v : Bdry) : IsClosed (cyl n v) := by
  have hrw : cyl n v = ⋂ i ∈ Finset.range n, (fun x : Bdry => x i) ⁻¹' {v i} := by
    ext x; simp [cyl]
  rw [hrw]
  exact isClosed_biInter (fun i _ => (isClosed_discrete _).preimage (continuous_apply i))

lemma cyl_isClopen (n : ℕ) (v : Bdry) : IsClopen (cyl n v) :=
  ⟨cyl_isClosed n v, cyl_isOpen n v⟩

lemma mem_cyl_self (n : ℕ) (x : Bdry) : x ∈ cyl n x := fun _ _ => rfl

lemma cyl_mem_nhds (n : ℕ) (x : Bdry) : cyl n x ∈ 𝓝 x :=
  (cyl_isOpen n x).mem_nhds (mem_cyl_self n x)

/-- The cylinders form a neighbourhood basis of the boundary topology: the topology of the
Berggren boundary is exactly the 3-adic (common prefix) topology. -/
theorem cyl_nhds_basis (x : Bdry) (U : Set Bdry) (hU : U ∈ 𝓝 x) : ∃ n, cyl n x ⊆ U := by
  rw [nhds_pi, Filter.mem_pi] at hU
  obtain ⟨I, hI, t, ht, hsub⟩ := hU
  obtain ⟨N, hN⟩ := hI.bddAbove
  refine ⟨N + 1, subset_trans (fun y hy => ?_) hsub⟩
  intro i hi
  have hle : i ≤ N := hN hi
  have : y i = x i := hy i (by omega)
  rw [this]
  exact mem_of_mem_nhds (ht i)

/-! ## The four Cantor axioms -/

theorem compactSpace_bdry : CompactSpace Bdry := inferInstance

theorem totallyDisconnectedSpace_bdry : TotallyDisconnectedSpace Bdry := inferInstance

theorem secondCountable_bdry : SecondCountableTopology Bdry := inferInstance

theorem nonempty_bdry : Nonempty Bdry := ⟨fun _ => 0⟩

/-- Changing the `k`-th letter produces a different boundary point. -/
lemma flip_ne (x : Bdry) (k : ℕ) : Function.update x k (x k + 1) ≠ x := by
  intro h
  have hk := congrFun h k
  simp at hk

/-- Perturbing deeper and deeper letters gives a sequence of distinct points converging to
`x`: the Berggren boundary has no isolated points. -/
lemma tendsto_flip (x : Bdry) :
    Tendsto (fun k : ℕ => Function.update x k (x k + 1)) atTop (𝓝 x) := by
  rw [tendsto_pi_nhds]
  intro i
  refine Tendsto.congr' ?_ (tendsto_const_nhds (x := x i))
  filter_upwards [eventually_gt_atTop i] with k hk
  rw [Function.update_of_ne (by omega)]

/-- **The Berggren boundary is perfect.** -/
theorem perfectSpace_bdry : PerfectSpace Bdry := by
  constructor
  intro x _
  have h : Tendsto (fun k : ℕ => Function.update x k (x k + 1)) atTop (𝓝[≠] x) :=
    tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within _ (tendsto_flip x)
      (Eventually.of_forall (fun k => flip_ne x k))
  have hne := h.neBot
  simpa [AccPt, principal_univ] using hne

/-- **Every node of the Berggren tree branches forever.**  Each cylinder contains two
distinct boundary points. -/
theorem cyl_nontrivial (n : ℕ) (v : Bdry) :
    ∃ x y : Bdry, x ∈ cyl n v ∧ y ∈ cyl n v ∧ x ≠ y := by
  refine ⟨v, Function.update v n (v n + 1), mem_cyl_self n v, ?_, ?_⟩
  · intro i hi
    rw [Function.update_of_ne (by omega)]
  · exact fun h => flip_ne v n h.symm

/-- **The Berggren boundary is a Cantor space**: nonempty, compact, metrizable, totally
disconnected and perfect. -/
theorem berggren_boundary_is_cantor :
    Nonempty Bdry ∧ CompactSpace Bdry ∧ SecondCountableTopology Bdry ∧
      TotallyDisconnectedSpace Bdry ∧ PerfectSpace Bdry :=
  ⟨nonempty_bdry, compactSpace_bdry, secondCountable_bdry, totallyDisconnectedSpace_bdry,
    perfectSpace_bdry⟩

end BerggrenHarmonic