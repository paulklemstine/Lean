import Mathlib

/-!
# Upper-bound-driven reductions for maximum clique

This file isolates the mathematical core of upper-bound-enhanced core and truss
reductions. An upper-bound oracle is treated extensionally: on every vertex set
it bounds the cardinality of every finite clique contained there. The results
show that a clique can contain a proposed pattern only when the oracle value on
its common neighborhood is large enough, and that repeated certified vertex
peeling preserves every clique above the target size.
-/

open Set

namespace MaximumCliqueReductions

variable {V : Type*} (G : SimpleGraph V)

/-- A set of vertices is a clique when every two distinct members are adjacent. -/
def IsClique (C : Set V) : Prop := C.Pairwise G.Adj

/-- The vertices adjacent to every vertex of `D`. -/
def commonNeighbors (D : Set V) : Set V := {v | ∀ w ∈ D, G.Adj v w}

/-- An extensional upper-bound oracle for clique size on each vertex set. -/
def IsCliqueUpperBound (ub : Set V → ℕ) : Prop :=
  ∀ S C : Set V, C.Finite → IsClique G C → C ⊆ S → C.ncard ≤ ub S

/-- The pointwise minimum of two valid clique upper bounds is again valid. This
formalizes the soundness of combining independent bounding procedures. -/
theorem upperBound_min {ub₁ ub₂ : Set V → ℕ}
    (h₁ : IsCliqueUpperBound G ub₁) (h₂ : IsCliqueUpperBound G ub₂) :
    IsCliqueUpperBound G (fun S => min (ub₁ S) (ub₂ S)) := by
  exact fun S C hC hC' hC'' => le_min ( h₁ S C hC hC' hC'' ) ( h₂ S C hC hC' hC'' )

/-- The portion of a clique outside a contained pattern is itself a clique in the
pattern's common neighborhood. Consequently its size is bounded by any clique
upper-bound oracle evaluated on that common neighborhood. -/
theorem clique_extension_bound {ub : Set V → ℕ} (hub : IsCliqueUpperBound G ub)
    {S C D : Set V} (hCfin : C.Finite) (hC : IsClique G C)
    (hD : D ⊆ C) (hCS : C ⊆ S) :
    C.ncard ≤ D.ncard + ub (S ∩ commonNeighbors G D) := by
  -- Let $E = C \setminus D$. Then $E$ is a finite clique in $S \cap \text{commonNeighbors } D$.
  set E := C \ D
  have hE_fin : E.Finite := by
    exact hCfin.subset fun x hx => hx.1
  have hE_clique : IsClique G E := by
    exact fun x hx y hy hxy => hC hx.1 hy.1 hxy
  have hE_subset : E ⊆ S ∩ commonNeighbors G D := by
    intro v hv; have := hCS hv.1; simp_all +decide [ commonNeighbors ] ;
    exact fun w hw => hC hv.1 ( hD hw ) ( by aesop );
  convert Nat.add_le_add_left ( hub ( S ∩ commonNeighbors G D ) E hE_fin hE_clique hE_subset ) D.ncard using 1;
  rw [ ← @Set.ncard_union_eq ];
  · rw [ Set.union_diff_cancel hD ];
  · exact disjoint_sdiff_self_right;
  · exact hCfin.subset hD;
  · exact hE_fin

/-- A failed common-neighborhood test certifies that no sufficiently large clique
inside `S` can contain the proposed vertex pattern `D`. -/
theorem failed_extension_test_excludes_pattern {ub : Set V → ℕ}
    (hub : IsCliqueUpperBound G ub) {k : ℕ} {S D : Set V}
    (hfail : D.ncard + ub (S ∩ commonNeighbors G D) < k) :
    ∀ C : Set V, C.Finite → IsClique G C → C ⊆ S → k ≤ C.ncard → ¬ D ⊆ C := by
  contrapose! hfail;
  obtain ⟨ C, hC₁, hC₂, hC₃, hC₄, hC₅ ⟩ := hfail; exact le_trans hC₄ ( MaximumCliqueReductions.clique_extension_bound G hub hC₁ hC₂ hC₅ hC₃ ) ;

/-- A vertex in a clique of size at least `k` passes the upper-bound-enhanced
core test on its neighborhood inside the current search set. -/
theorem vertex_core_test {ub : Set V → ℕ} (hub : IsCliqueUpperBound G ub)
    {k : ℕ} {S C : Set V} {v : V} (hCfin : C.Finite) (hC : IsClique G C)
    (hCS : C ⊆ S) (hv : v ∈ C) (hk : k ≤ C.ncard) :
    k ≤ 1 + ub (S ∩ commonNeighbors G {v}) := by
  refine' le_trans hk ( le_trans ( clique_extension_bound G hub hCfin hC ( Set.singleton_subset_iff.mpr hv ) hCS ) _ );
  simp +decide

/-- An edge in a clique of size at least `k` passes the upper-bound-enhanced
truss test on its common neighborhood. -/
theorem edge_truss_test {ub : Set V → ℕ} (hub : IsCliqueUpperBound G ub)
    {k : ℕ} {S C : Set V} {u v : V} (hCfin : C.Finite) (hC : IsClique G C)
    (hCS : C ⊆ S) (hu : u ∈ C) (hv : v ∈ C) (huv : u ≠ v)
    (hk : k ≤ C.ncard) :
    k ≤ 2 + ub (S ∩ commonNeighbors G {u, v}) := by
  refine' le_trans hk ( _ : C.ncard ≤ 2 + ub ( S ∩ commonNeighbors G { u, v } ) );
  convert clique_extension_bound G hub hCfin hC ( Set.insert_subset hu ( Set.singleton_subset_iff.mpr hv ) ) hCS using 1;
  rw [ Set.ncard_pair huv ]

/-- A certified core-peeling step deletes one vertex whose neighborhood upper
bound is too small to support a clique of the target size. -/
def CoreStep (ub : Set V → ℕ) (k : ℕ) (S T : Set V) : Prop :=
  ∃ v ∈ S, 1 + ub (S ∩ commonNeighbors G {v}) < k ∧ T = S \ {v}

/-- One upper-bound-enhanced core-peeling step preserves every finite clique of
size at least the target. -/
theorem coreStep_preserves_large_clique {ub : Set V → ℕ}
    (hub : IsCliqueUpperBound G ub) {k : ℕ} {S T C : Set V}
    (hstep : CoreStep G ub k S T) (hCfin : C.Finite) (hC : IsClique G C)
    (hCS : C ⊆ S) (hk : k ≤ C.ncard) : C ⊆ T := by
  obtain ⟨ v, hvS, hvk, rfl ⟩ := hstep;
  intro x hx
  by_contra h_contra
  have hx_v : x = v := by
    exact Classical.not_not.1 fun h => h_contra ⟨ hCS hx, h ⟩;
  exact absurd ( vertex_core_test G hub hCfin hC hCS ( hx_v ▸ hx ) hk ) ( by linarith )

/-- Correctness of the complete peeling process: any finite sequence of
certified core steps preserves every clique of size at least `k`. -/
theorem corePeeling_preserves_large_clique {ub : Set V → ℕ}
    (hub : IsCliqueUpperBound G ub) {k : ℕ} {S T C : Set V}
    (hsteps : Relation.ReflTransGen (CoreStep G ub k) S T)
    (hCfin : C.Finite) (hC : IsClique G C) (hCS : C ⊆ S)
    (hk : k ≤ C.ncard) : C ⊆ T := by
  induction hsteps;
  · assumption;
  · grind +suggestions

end MaximumCliqueReductions