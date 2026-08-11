import Novelty.StrangeAttractorInverseLimit

/-!
# Strange attractors as algebraic objects, IV: the topology of the inverse limit

The inverse limit of the finite path diagram of a finite directed graph is not merely a set:
it carries the inverse-limit topology, inherited from the product of discrete finite sets.
Here we prove that it has exactly the topological features expected of a strange attractor's
transversal structure:

* `isClosed_pathSet`, `isCompact_pathSet` : the orbit space is a compact (closed) subset of
  the Cantor-type product space, so the inverse limit of finite graphs is compact;
* `continuous_shift` : the shift is continuous, so `(PathSpace E, shift)` is a topological
  dynamical system;
* `cantorMap_isClosedEmbedding` : if every vertex branches (out-degree `≥ 2`) the attractor
  contains a topologically embedded Cantor set;
* `uncountable_pathSpace` : consequently the attractor is uncountable, while every finite
  approximant is finite — the inverse limit is a genuinely infinite object;
* `perfect_pathSet` : a branching attractor has no isolated orbits, so it is a perfect,
  compact, totally disconnected, Hausdorff space.

Together with the compactness, total disconnectedness and Hausdorffness instances this says
that a branching symbolic attractor is a Cantor-type space.
-/

namespace LorenzLimit

variable {V : Type*} [Fintype V] [TopologicalSpace V] [DiscreteTopology V] {E : V → V → Bool}

/-! ## Compactness and total disconnectedness -/

omit [Fintype V] in
theorem isClosed_pathSet : IsClosed (pathSet E) := by
  have : pathSet E = ⋂ n : ℕ, {x : ℕ → V | E (x n) (x (n + 1)) = true} := by
    ext x; simp [pathSet]
  rw [this]
  refine isClosed_iInter fun n => ?_
  have hcont : Continuous (fun x : ℕ → V => (x n, x (n + 1))) :=
    (continuous_apply n).prodMk (continuous_apply (n + 1))
  have : {x : ℕ → V | E (x n) (x (n + 1)) = true}
      = (fun x : ℕ → V => (x n, x (n + 1))) ⁻¹' {p : V × V | E p.1 p.2 = true} := rfl
  rw [this]
  exact (isClosed_discrete _).preimage hcont

theorem isCompact_pathSet : IsCompact (pathSet E) :=
  isClosed_pathSet.isCompact

instance instTopologicalSpacePathSpace : TopologicalSpace (PathSpace E) :=
  inferInstanceAs (TopologicalSpace (pathSet E))

instance instCompactSpacePathSpace : CompactSpace (PathSpace E) :=
  isCompact_iff_compactSpace.1 isCompact_pathSet

instance instT2SpacePathSpace : T2Space (PathSpace E) :=
  inferInstanceAs (T2Space (pathSet E))

instance instTotallyDisconnectedPathSpace : TotallyDisconnectedSpace (PathSpace E) :=
  inferInstanceAs (TotallyDisconnectedSpace (pathSet E))

/-! ## The shift is continuous -/

omit [Fintype V] [DiscreteTopology V] in
theorem continuous_shift : Continuous (shift : PathSpace E → PathSpace E) := by
  apply Continuous.subtype_mk
  apply continuous_pi
  intro n
  exact (continuous_apply (n + 1)).comp continuous_subtype_val

/-! ## An embedded Cantor set -/

section Branching

variable (h : Branching E)

/-- The first of two chosen successors of a vertex. -/
noncomputable def succ₀ (v : V) : V := (h v).choose

/-- The second of two chosen successors of a vertex. -/
noncomputable def succ₁ (v : V) : V := (h v).choose_spec.choose

omit [Fintype V] [TopologicalSpace V] [DiscreteTopology V] in
theorem succ_ne (v : V) : succ₀ h v ≠ succ₁ h v := (h v).choose_spec.choose_spec.1

omit [Fintype V] [TopologicalSpace V] [DiscreteTopology V] in
theorem edge_succ₀ (v : V) : E v (succ₀ h v) = true := (h v).choose_spec.choose_spec.2.1

omit [Fintype V] [TopologicalSpace V] [DiscreteTopology V] in
theorem edge_succ₁ (v : V) : E v (succ₁ h v) = true := (h v).choose_spec.choose_spec.2.2

/-- The binary tree of orbits determined by the branching structure. -/
noncomputable def cantorSeq (v₀ : V) (b : ℕ → Bool) : ℕ → V
  | 0 => v₀
  | k + 1 => if b k then succ₁ h (cantorSeq v₀ b k) else succ₀ h (cantorSeq v₀ b k)

/-- Every binary sequence names an orbit of the attractor. -/
noncomputable def cantorMap (v₀ : V) (b : ℕ → Bool) : PathSpace E :=
  ⟨cantorSeq h v₀ b, by
    intro n
    by_cases hb : b n
    · show E _ (if b n then _ else _) = true
      rw [if_pos hb]
      exact edge_succ₁ h _
    · show E _ (if b n then _ else _) = true
      rw [if_neg hb]
      exact edge_succ₀ h _⟩

omit [Fintype V] [TopologicalSpace V] [DiscreteTopology V] in
theorem cantorMap_injective (v₀ : V) : Function.Injective (cantorMap h v₀) := by
  intro b c hbc
  have hseq : ∀ n, cantorSeq h v₀ b n = cantorSeq h v₀ c n := fun n =>
    congrFun (congrArg Subtype.val hbc) n
  funext n
  have hn := hseq (n + 1)
  have hn0 := hseq n
  by_cases hb : b n <;> by_cases hc : c n
  · simp [hb, hc]
  · exfalso
    rw [show cantorSeq h v₀ b (n + 1) = succ₁ h (cantorSeq h v₀ b n) by
      simp [cantorSeq, hb],
      show cantorSeq h v₀ c (n + 1) = succ₀ h (cantorSeq h v₀ c n) by
      simp [cantorSeq, hc], ← hn0] at hn
    exact succ_ne h _ hn.symm
  · exfalso
    rw [show cantorSeq h v₀ b (n + 1) = succ₀ h (cantorSeq h v₀ b n) by
      simp [cantorSeq, hb],
      show cantorSeq h v₀ c (n + 1) = succ₁ h (cantorSeq h v₀ c n) by
      simp [cantorSeq, hc], ← hn0] at hn
    exact succ_ne h _ hn
  · simp at hb hc
    simp [hb, hc]

omit [Fintype V] in
theorem continuous_cantorSeq (v₀ : V) (n : ℕ) :
    Continuous (fun b : ℕ → Bool => cantorSeq h v₀ b n) := by
  induction n with
  | zero => exact continuous_const
  | succ n ih =>
      have hpair : Continuous (fun b : ℕ → Bool => (b n, cantorSeq h v₀ b n)) :=
        (continuous_apply n).prodMk ih
      exact (continuous_of_discreteTopology
        (f := fun p : Bool × V => if p.1 then succ₁ h p.2 else succ₀ h p.2)).comp hpair

omit [Fintype V] in
theorem continuous_cantorMap (v₀ : V) : Continuous (cantorMap h v₀) := by
  apply Continuous.subtype_mk
  exact continuous_pi (continuous_cantorSeq h v₀)

/-- **A branching symbolic attractor contains an embedded Cantor set.**  If every vertex of
the graph has two distinct successors, the Cantor space of binary sequences embeds as a
closed subspace of the inverse limit. -/
theorem cantorMap_isClosedEmbedding (v₀ : V) :
    Topology.IsClosedEmbedding (cantorMap h v₀) :=
  (continuous_cantorMap h v₀).isClosedEmbedding (cantorMap_injective h v₀)

theorem not_countable_cantorSpace : ¬ Countable (ℕ → Bool) := by
  intro hc
  have hle : Cardinal.mk (ℕ → Bool) ≤ Cardinal.aleph0 := Cardinal.mk_le_aleph0
  rw [Cardinal.mk_arrow] at hle
  simp at hle
  exact absurd hle (not_le.2 (Cardinal.cantor _))

omit [Fintype V] [TopologicalSpace V] [DiscreteTopology V] in
include h in
/-- **The attractor is uncountable** as soon as every vertex branches, even though each of
its finite graph approximants is a finite set. -/
theorem uncountable_pathSpace (v₀ : V) : ¬ Countable (PathSpace E) := by
  intro hc
  exact not_countable_cantorSpace
    (Function.Injective.countable (cantorMap_injective h v₀))

/-! ## No isolated orbits: the attractor is perfect -/

include h in
open Classical in
/-- A successor of `v` different from a prescribed vertex `w`. -/
noncomputable def altSucc (v w : V) : V :=
  if succ₀ h v = w then succ₁ h v else succ₀ h v

omit [Fintype V] [TopologicalSpace V] [DiscreteTopology V] in
theorem altSucc_ne (v w : V) : altSucc h v w ≠ w := by
  unfold altSucc
  by_cases hc : succ₀ h v = w
  · rw [if_pos hc]
    intro hcon
    exact succ_ne h v (hc.trans hcon.symm)
  · rw [if_neg hc]
    exact hc

omit [Fintype V] [TopologicalSpace V] [DiscreteTopology V] in
theorem edge_altSucc (v w : V) : E v (altSucc h v w) = true := by
  unfold altSucc
  by_cases hc : succ₀ h v = w
  · rw [if_pos hc]; exact edge_succ₁ h v
  · rw [if_neg hc]; exact edge_succ₀ h v

include h in
/-- An orbit agreeing with `x` up to time `n` and branching away at time `n + 1`. -/
noncomputable def altPath (x : PathSpace E) (n : ℕ) : PathSpace E := by
  refine ⟨fun k => if k ≤ n then x.1 k else
    deadEndFreeSeq h.noDeadEnds (altSucc h (x.1 n) (x.1 (n + 1))) (k - (n + 1)), ?_⟩
  intro k
  dsimp only
  rcases lt_trichotomy k n with hk | hk | hk
  · rw [if_pos (by omega), if_pos (by omega)]
    exact x.2 k
  · subst hk
    rw [if_pos (le_refl k), if_neg (by omega)]
    simp only [Nat.sub_self, deadEndFreeSeq]
    exact edge_altSucc h (x.1 k) (x.1 (k + 1))
  · rw [if_neg (by omega), if_neg (by omega)]
    have hstep : k + 1 - (n + 1) = (k - (n + 1)) + 1 := by omega
    rw [hstep]
    exact (h.noDeadEnds _).choose_spec

omit [Fintype V] [TopologicalSpace V] [DiscreteTopology V] in
theorem altPath_agree (x : PathSpace E) (n : ℕ) {k : ℕ} (hk : k ≤ n) :
    (altPath h x n).1 k = x.1 k := by
  show (if k ≤ n then _ else _) = _
  rw [if_pos hk]

omit [Fintype V] [TopologicalSpace V] [DiscreteTopology V] in
theorem altPath_ne (x : PathSpace E) (n : ℕ) : (altPath h x n).1 (n + 1) ≠ x.1 (n + 1) := by
  show (if n + 1 ≤ n then _ else _) ≠ _
  rw [if_neg (by omega)]
  simpa [deadEndFreeSeq] using altSucc_ne h (x.1 n) (x.1 (n + 1))

omit [Fintype V] in
include h in
/-- **A branching symbolic attractor has no isolated orbits.**  Together with closedness
this says the inverse limit is a perfect set: every orbit is approximated arbitrarily well
by different orbits, which is the transverse Cantor structure of a strange attractor. -/
theorem perfect_pathSet : Perfect (pathSet E) := by
  refine ⟨isClosed_pathSet, ?_⟩
  intro x hx
  rw [accPt_iff_nhds]
  intro U hU
  obtain ⟨W, hWU, hWopen, hxW⟩ := mem_nhds_iff.1 hU
  obtain ⟨I, u, hu, hIW⟩ := isOpen_pi_iff.1 hWopen x hxW
  set n := I.sup id with hn
  refine ⟨(altPath h ⟨x, hx⟩ n).1, ⟨hWU ?_, (altPath h ⟨x, hx⟩ n).2⟩, ?_⟩
  · apply hIW
    intro i hi
    have hile : i ≤ n := Finset.le_sup (f := id) hi
    rw [altPath_agree h ⟨x, hx⟩ n hile]
    exact (hu i hi).2
  · intro hcon
    exact altPath_ne h ⟨x, hx⟩ n (congrFun hcon (n + 1))

end Branching

end LorenzLimit