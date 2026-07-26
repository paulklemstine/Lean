import Mathlib

set_option autoImplicit false

open Set Filter
open scoped Topology

/-!
# Surreal topology: open sets at infinity

We equip Mathlib's universe-relative Conway surreal numbers with their order topology.
The central result is that this topology is not first-countable.  The proof uses the
set-theoretic feature distinguishing `No` from ordinary ordered fields: every small
family of surreals has a common upper and lower bound.

From a hypothetical countable neighborhood basis at zero, choose one point to the
right of zero inside each basis neighborhood.  A single positive surreal lies below
all chosen points.  Its symmetric interval is a neighborhood of zero that contains
none of the basis neighborhoods, a contradiction.

The same boundedness principle also produces a nontrivial clopen set of finite
surreals.  Thus the interval topology is disconnected and noncompact.
-/

namespace SurrealOpenSetsAtInfinity

namespace Surreal

noncomputable instance instTopologicalSpace : TopologicalSpace Surreal.{0} :=
  Preorder.topology Surreal.{0}

instance instOrderTopology : OrderTopology Surreal.{0} := ⟨rfl⟩

instance instT2Space : T2Space Surreal.{0} := inferInstance

instance instNoMaxOrder : NoMaxOrder Surreal.{0} :=
  ⟨fun x => ⟨x + 1, by linarith [zero_lt_one (α := Surreal.{0})]⟩⟩

instance instNoMinOrder : NoMinOrder Surreal.{0} :=
  ⟨fun x => ⟨x - 1, by linarith [zero_lt_one (α := Surreal.{0})]⟩⟩

/-- Every sequence of positive surreals admits a common positive strict lower bound. -/
theorem exists_pos_lt_all (u : ℕ → Surreal.{0}) (hu : ∀ n, 0 < u n) :
    ∃ d : Surreal.{0}, 0 < d ∧ ∀ n, d < u n := by
  induction u using Quotient.induction_on_pi with | _ f =>
  let g : ℕ → SetTheory.PGame.{0} := Subtype.val ∘ f
  have hg (n : ℕ) : (g n).Numeric := Subtype.prop _
  have hpos (n : ℕ) : (0 : SetTheory.PGame.{0}) < g n := hu n
  let x : SetTheory.PGame.{0} :=
    SetTheory.PGame.mk PUnit ℕ (fun _ => 0) (fun n => g n)
  have hx : x.Numeric := SetTheory.PGame.Numeric.mk
    (fun _ n => hpos n) (fun _ => SetTheory.PGame.numeric_zero) hg
  refine ⟨Surreal.mk x hx, ?_, ?_⟩
  · simpa [x] using Surreal.mk_moveLeft_lt_mk hx PUnit.unit
  · intro n
    simpa [x, g] using Surreal.mk_lt_mk_moveRight hx n

/-
A neighborhood of zero contains a positive surreal point.
-/
theorem exists_pos_mem_of_mem_nhds_zero {U : Set Surreal.{0}} (hU : U ∈ 𝓝 0) :
    ∃ x : Surreal.{0}, 0 < x ∧ x ∈ U := by
  obtain ⟨ y, hy ⟩ := exists_Ico_subset_of_mem_nhds hU ( exists_gt 0 );
  obtain ⟨ z, hz ⟩ := exists_pos_lt_all ( fun _ => y ) ( fun _ => hy.1 );
  exact ⟨ z, hz.1, hy.2 ⟨ hz.1.le, hz.2 0 ⟩ ⟩

/-
No countable family of neighborhoods can be cofinal in the neighborhood filter at zero.
-/
theorem no_countable_nhds_basis_at_zero :
    ¬ ∃ B : ℕ → Set Surreal.{0},
      (∀ n, B n ∈ 𝓝 0) ∧ (∀ U ∈ 𝓝 0, ∃ n, B n ⊆ U) := by
  -- Assume B is such a basis. For each n choose positive u n in B n using exists_pos_mem_of_mem_nhds_zero.
  by_contra h
  obtain ⟨B, hB⟩ := h
  obtain ⟨u, hu⟩ : ∃ u : ℕ → Surreal.{0}, (∀ n, 0 < u n ∧ u n ∈ B n) := by
    exact ⟨ fun n => Classical.choose ( exists_pos_mem_of_mem_nhds_zero ( hB.1 n ) ), fun n => Classical.choose_spec ( exists_pos_mem_of_mem_nhds_zero ( hB.1 n ) ) ⟩;
  -- Use `exists_pos_lt_all u` to obtain `d > 0` with `d < u n` all `n`.
  obtain ⟨d, hd_pos, hd_lt⟩ : ∃ d : Surreal.{0}, 0 < d ∧ ∀ n, d < u n := by
    exact exists_pos_lt_all u fun n => hu n |>.1;
  obtain ⟨ n, hn ⟩ := hB.2 ( Set.Iio d ) ( Iio_mem_nhds hd_pos ) ; exact not_lt_of_ge ( hn ( hu n |>.2 ) |> le_of_lt ) ( hd_lt n ) ;

/-
**Main theorem.** The order (interval) topology on Conway's surreal numbers is
not first-countable.
-/
theorem not_firstCountableTopology : ¬ FirstCountableTopology Surreal.{0} := by
  intro h
  obtain ⟨B, hB⟩ : ∃ B : ℕ → Set Surreal.{0}, (∀ n, B n ∈ nhds (0 : Surreal.{0})) ∧ (∀ U ∈ nhds (0 : Surreal.{0}), ∃ n, B n ⊆ U) := by
    rcases ( nhds_basis_opens ( 0 : Surreal ) ).exists_antitone_subbasis with ⟨ B, hB ⟩;
    exact ⟨ B, fun n => IsOpen.mem_nhds ( hB.1 n |>.2 ) ( hB.1 n |>.1 ), fun U hU => hB.2.mem_iff.mp hU ⟩;
  contrapose! hB; have := no_countable_nhds_basis_at_zero; aesop;

/-
In particular, the surreal order topology is not metrizable.
-/
theorem not_metrizableSpace : ¬ TopologicalSpace.MetrizableSpace Surreal.{0} := by
  -- Assume the MetrizableSpace instance and install it locally with `letI := h`;
  -- then infer a FirstCountableTopology instance, contradicting not_firstCountableTopology.
  intro h
  letI := h;
  exact not_firstCountableTopology ( inferInstance )

/-
There is a surreal strictly greater than every natural number.
-/
theorem exists_gt_natCast : ∃ M : Surreal.{0}, ∀ n : ℕ, (n : Surreal.{0}) < M := by
  obtain ⟨M, hM⟩ : ∃ M : Surreal.{0}, ∀ n : ℕ, (n : Surreal.{0}) ≤ M := by
    obtain ⟨ M, hM ⟩ := Surreal.bddAbove_range_of_small ( fun n : ℕ => ( n : Surreal.{0} ) );
    exact ⟨ M, fun n => hM ⟨ n, rfl ⟩ ⟩;
  exact ⟨ M + 1, fun n => lt_of_le_of_lt ( hM n ) ( lt_add_one _ ) ⟩

/-- The lower region bounded by some natural number. -/
def FiniteSurreals : Set Surreal.{0} :=
  {x | ∃ n : ℕ, x < (n : Surreal.{0})}

/-
The finite-surreal region is open.
-/
theorem finiteSurreals_isOpen : IsOpen FiniteSurreals := by
  rw [ show FiniteSurreals = ⋃ n : ℕ, Set.Iio ( n : Surreal ) from ?_ ];
  · exact isOpen_iUnion fun n => isOpen_Iio;
  · exact Set.ext fun x => ⟨ fun ⟨ n, hn ⟩ => Set.mem_iUnion.2 ⟨ n, hn ⟩, fun hx => by obtain ⟨ n, hn ⟩ := Set.mem_iUnion.1 hx; exact ⟨ n, hn ⟩ ⟩

/-
The finite-surreal region is closed.
-/
theorem finiteSurreals_isClosed : IsClosed FiniteSurreals := by
  refine' isClosed_of_closure_subset _;
  intro x hx; by_contra h; simp_all +decide [ mem_closure_iff_nhds ] ;
  specialize hx ( Set.Ioi ( x - 1 ) ) ( Ioi_mem_nhds ( show x - 1 < x from sub_one_lt x ) ) ; obtain ⟨ y, hy₁, hy₂ ⟩ := hx ; simp_all +decide [ FiniteSurreals ] ;
  obtain ⟨ n, hn ⟩ := hy₂; have := h ( n + 1 ) ; norm_num at * ; linarith;

/-
The finite-surreal region is a nontrivial clopen subset.
-/
theorem finiteSurreals_isClopen :
    IsClopen FiniteSurreals ∧ FiniteSurreals.Nonempty ∧ FiniteSurreals ≠ univ := by
  refine' ⟨ _, _, _ ⟩;
  · exact ⟨finiteSurreals_isClosed, finiteSurreals_isOpen⟩;
  · exact ⟨ 0, ⟨ 1, by norm_num ⟩ ⟩;
  · norm_num [ Set.ext_iff, FiniteSurreals ];
    exact ⟨ _, fun n => le_of_lt ( exists_gt_natCast.choose_spec n ) ⟩

/-
The interval-topological surreal line is disconnected.
-/
theorem not_connectedSpace : ¬ ConnectedSpace Surreal.{0} := by
  by_contra h_connected
  obtain ⟨h_preconnected⟩ : PreconnectedSpace Surreal := by
    infer_instance
  have h_clopen : IsClopen (FiniteSurreals) := by
    exact ⟨ finiteSurreals_isClosed, finiteSurreals_isOpen ⟩
  have h_empty_or_univ : FiniteSurreals = ∅ ∨ FiniteSurreals = Set.univ := by
    grind +suggestions
  have h_contradiction : False := by
    cases h_empty_or_univ <;> have := finiteSurreals_isClopen <;> aesop
  exact h_contradiction

/-
The interval-topological surreal line is not compact.
-/
theorem not_compactSpace : ¬ CompactSpace Surreal.{0} := by
  by_contra h_compact
  obtain ⟨m, -, hm⟩ := (isCompact_univ (X := Surreal)).exists_isGreatest ⟨0, Set.mem_univ 0⟩
  obtain ⟨y, hy⟩ := exists_gt m
  exact absurd (hm (Set.mem_univ y)) (not_le.2 hy)

end Surreal

end SurrealOpenSetsAtInfinity