import Mathlib

/-!
# Head complexity of block-diagonal tasks: subadditivity is an equality

`Catalog/MachineLearning/TransformerUniversality/HeadComplexity.lean` shows that the minimal
number of heads of a value-sum architecture computing a finite value table equals the rank of
that table, and `HeadComposition.lean` shows that this resource is *subadditive*:
`minHeads (f + g) ≤ minHeads f + minHeads g`.  The second next-cycle sub-conjecture of
`FUTURE_DIRECTIONS.md` asked for the equality case.

Subadditivity is genuinely strict for a plain sum of tasks (take `g = -f`: the sum is the zero
task, which needs no heads at all).  The equality case is the *block-diagonal* task: run `f` on
one group of inputs and `g` on a disjoint group, writing their outputs into disjoint groups of
output features.  This file proves that heads then add exactly:

* `blockTask` — the block-diagonal combination of `f : X → Y → ℝ` and `g : X' → Y' → ℝ`, a task
  on `X ⊕ X'` with feature space `Y ⊕ Y'`;
* `span_range_blockTask` — its output span is the (internal direct) sum of the two output
  spans, pushed forward along the two coordinate inclusions;
* `rankOf_blockTask` — hence `rank (f ⊞ g) = rank f + rank g`;
* `minHeads_blockTask` — **no sharing is possible**: `minHeads (f ⊞ g) = minHeads f + minHeads g`,
  the equality case of `HeadComposition.minHeads_add_le`;
* `minHeads_add_lt_of_neg` — and the inequality really is strict without the block structure.

Interpretation: attention heads cannot be amortized across independent sub-tasks.  A
transformer that must solve `k` unrelated lookup problems in disjoint feature blocks needs the
sum of the individual head budgets — the parallelism of multi-head attention buys no
compression, only the freedom to allocate.  Since `minHeads` is also invariant under linear
isomorphisms (`HeadComposition.minHeads_postcomp_of_injective`), this pins down `minHeads` as
an additive invariant of the value table.

As every catalog file is self-contained, the definitions and the rank characterization of
`HeadComplexity.lean` are repeated here.
-/

open scoped BigOperators
open Submodule Set Module

namespace BlockDiagonalHeads

/-! ## The head-complexity measure (as in `HeadComplexity.lean`) -/

variable {X X' Y Y' : Type*}

/-- A value-sum architecture with `H` heads: input-dependent scalar gates times
input-independent value vectors. -/
def Representable (f : X → Y → ℝ) (H : ℕ) : Prop :=
  ∃ (c : Fin H → X → ℝ) (v : Fin H → (Y → ℝ)), ∀ x, f x = ∑ h, c h x • v h

/-- The rank of the value table. -/
noncomputable def rankOf (f : X → Y → ℝ) : ℕ := finrank ℝ (span ℝ (Set.range f))

/-- The minimal number of heads of a value-sum architecture computing `f`. -/
noncomputable def minHeads (f : X → Y → ℝ) : ℕ := sInf {H | Representable f H}

instance finiteSpanRange [Finite X] (f : X → Y → ℝ) : Module.Finite ℝ (span ℝ (Set.range f)) :=
  Module.Finite.span_of_finite ℝ (Set.finite_range f)

/-- **Head lower bound**: an `H`-head model confines all outputs to an `H`-dimensional
subspace. -/
theorem Representable.finrank_le [Finite X] {f : X → Y → ℝ} {H : ℕ} (hf : Representable f H) :
    rankOf f ≤ H := by
  classical
  obtain ⟨c, v, hcv⟩ := hf
  have hsub : span ℝ (Set.range f) ≤ span ℝ (Set.range v) := by
    rw [Submodule.span_le]
    rintro _ ⟨x, rfl⟩
    rw [hcv x]
    exact Submodule.sum_mem _ fun h _ =>
      Submodule.smul_mem _ _ (Submodule.subset_span ⟨h, rfl⟩)
  have hfin : Module.Finite ℝ (span ℝ (Set.range v)) :=
    Module.Finite.span_of_finite ℝ (Set.finite_range v)
  have hmono : finrank ℝ (span ℝ (Set.range f)) ≤ finrank ℝ (span ℝ (Set.range v)) :=
    Submodule.finrank_mono hsub
  have hcard : finrank ℝ (span ℝ (Set.range v)) ≤ H := by
    have h1 := finrank_span_le_card (R := ℝ) (Set.range v)
    have h2 : (Set.range v).toFinset.card ≤ H := by
      rw [Set.toFinset_range]
      exact le_trans Finset.card_image_le (by simp)
    exact le_trans h1 h2
  exact le_trans hmono hcard

/-- **Matching construction**: a basis of the output span gives a `rankOf f`-head model. -/
theorem representable_rankOf [Finite X] (f : X → Y → ℝ) : Representable f (rankOf f) := by
  classical
  set W : Submodule ℝ (Y → ℝ) := span ℝ (Set.range f) with hW
  set b : Basis (Fin (finrank ℝ W)) ℝ W := Module.finBasis ℝ W with hb
  set v : Fin (rankOf f) → (Y → ℝ) := fun i => (b i : Y → ℝ) with hv
  have hspan : span ℝ (Set.range v) = W := by
    have h : Set.range v = W.subtype '' (Set.range b) := by
      rw [← Set.range_comp]; rfl
    rw [hv] at h ⊢
    rw [h, ← Submodule.map_span, b.span_eq, Submodule.map_top, Submodule.range_subtype]
  have hmem : ∀ x, ∃ c : Fin (rankOf f) → ℝ, ∑ i, c i • v i = f x := by
    intro x
    have hx : f x ∈ span ℝ (Set.range v) := by
      rw [hspan, hW]
      exact Submodule.subset_span ⟨x, rfl⟩
    exact (mem_span_range_iff_exists_fun ℝ).mp hx
  choose c hc using hmem
  exact ⟨fun i x => c x i, v, fun x => (hc x).symm⟩

/-- **Exact head complexity**: minimal head count = rank of the value table. -/
theorem minHeads_eq_rankOf [Finite X] (f : X → Y → ℝ) : minHeads f = rankOf f := by
  have hmem : rankOf f ∈ {H | Representable f H} := representable_rankOf f
  refine le_antisymm (Nat.sInf_le hmem) ?_
  exact (Nat.sInf_mem (⟨rankOf f, hmem⟩ : {H | Representable f H}.Nonempty) :
    Representable f (minHeads f)).finrank_le

/-! ## Coordinate inclusions of the two feature blocks -/

/-- The inclusion of the first feature block `Y ↪ Y ⊕ Y'`, as a linear map on functions. -/
def inclL (Y Y' : Type*) : (Y → ℝ) →ₗ[ℝ] (Y ⊕ Y' → ℝ) where
  toFun u := Sum.elim u 0
  map_add' u v := by funext z; cases z <;> simp
  map_smul' a u := by funext z; cases z <;> simp

/-- The inclusion of the second feature block `Y' ↪ Y ⊕ Y'`. -/
def inclR (Y Y' : Type*) : (Y' → ℝ) →ₗ[ℝ] (Y ⊕ Y' → ℝ) where
  toFun w := Sum.elim 0 w
  map_add' u v := by funext z; cases z <;> simp
  map_smul' a u := by funext z; cases z <;> simp

theorem inclL_injective : Function.Injective (inclL Y Y') := by
  intro u v huv
  funext y
  have := congrFun huv (Sum.inl y)
  simpa [inclL] using this

theorem inclR_injective : Function.Injective (inclR Y Y') := by
  intro u v huv
  funext y
  have := congrFun huv (Sum.inr y)
  simpa [inclR] using this

/-- The images of the two inclusions intersect trivially. -/
theorem disjoint_incl_ranges (A : Submodule ℝ (Y → ℝ)) (B : Submodule ℝ (Y' → ℝ)) :
    Submodule.map (inclL Y Y') A ⊓ Submodule.map (inclR Y Y') B = ⊥ := by
  refine le_antisymm ?_ bot_le
  rintro z ⟨⟨u, -, rfl⟩, ⟨w, -, hw⟩⟩
  have hL : ∀ y : Y, (Sum.elim u (0 : Y' → ℝ)) (Sum.inl y) = (0 : ℝ) := by
    intro y
    have := congrFun hw (Sum.inl y)
    simpa [inclL, inclR] using this.symm
  have hu : u = 0 := by
    funext y
    simpa [inclL] using hL y
  simp only [Submodule.mem_bot]
  funext z
  cases z <;> simp [inclL, hu]

/-! ## The block-diagonal task -/

/-- The **block-diagonal combination** of two tasks: on inputs from `X` it computes `f` in the
first feature block and zero in the second, and symmetrically on inputs from `X'`. -/
def blockTask (f : X → Y → ℝ) (g : X' → Y' → ℝ) : (X ⊕ X') → (Y ⊕ Y' → ℝ) :=
  Sum.elim (fun x => inclL Y Y' (f x)) (fun x' => inclR Y Y' (g x'))

theorem range_blockTask (f : X → Y → ℝ) (g : X' → Y' → ℝ) :
    Set.range (blockTask f g) =
      (inclL Y Y' '' Set.range f) ∪ (inclR Y Y' '' Set.range g) := by
  ext z
  constructor
  · rintro ⟨w, rfl⟩
    cases w with
    | inl x => exact Or.inl ⟨f x, ⟨x, rfl⟩, rfl⟩
    | inr x' => exact Or.inr ⟨g x', ⟨x', rfl⟩, rfl⟩
  · rintro (⟨_, ⟨x, rfl⟩, rfl⟩ | ⟨_, ⟨x', rfl⟩, rfl⟩)
    · exact ⟨Sum.inl x, rfl⟩
    · exact ⟨Sum.inr x', rfl⟩

/-- The output span of the block-diagonal task is the sum of the two pushed-forward spans. -/
theorem span_range_blockTask (f : X → Y → ℝ) (g : X' → Y' → ℝ) :
    span ℝ (Set.range (blockTask f g)) =
      Submodule.map (inclL Y Y') (span ℝ (Set.range f)) ⊔
        Submodule.map (inclR Y Y') (span ℝ (Set.range g)) := by
  rw [range_blockTask, Submodule.span_union, Submodule.span_image, Submodule.span_image]

/-- Pushing a span forward along an injective linear map preserves its dimension. -/
theorem finrank_map_incl_left [Finite X] (f : X → Y → ℝ) :
    finrank ℝ (Submodule.map (inclL Y Y') (span ℝ (Set.range f))) = rankOf f :=
  ((Submodule.equivMapOfInjective (inclL Y Y') inclL_injective
    (span ℝ (Set.range f))).finrank_eq).symm

theorem finrank_map_incl_right [Finite X'] (g : X' → Y' → ℝ) :
    finrank ℝ (Submodule.map (inclR Y Y') (span ℝ (Set.range g))) = rankOf g :=
  ((Submodule.equivMapOfInjective (inclR Y Y') inclR_injective
    (span ℝ (Set.range g))).finrank_eq).symm

/-- **Ranks add on block-diagonal tasks.** -/
theorem rankOf_blockTask [Finite X] [Finite X'] (f : X → Y → ℝ) (g : X' → Y' → ℝ) :
    rankOf (blockTask f g) = rankOf f + rankOf g := by
  classical
  set A := Submodule.map (inclL Y Y') (span ℝ (Set.range f)) with hA
  set B := Submodule.map (inclR Y Y') (span ℝ (Set.range g)) with hB
  have hAeq : A = span ℝ (Set.range fun x => inclL Y Y' (f x)) := by
    rw [hA, ← Submodule.span_image, ← Set.range_comp]; rfl
  have hBeq : B = span ℝ (Set.range fun x' => inclR Y Y' (g x')) := by
    rw [hB, ← Submodule.span_image, ← Set.range_comp]; rfl
  haveI : Module.Finite ℝ A := by
    rw [hAeq]; exact Module.Finite.span_of_finite ℝ (Set.finite_range _)
  haveI : Module.Finite ℝ B := by
    rw [hBeq]; exact Module.Finite.span_of_finite ℝ (Set.finite_range _)
  have hinf : A ⊓ B = ⊥ := disjoint_incl_ranges _ _
  have hsum := Submodule.finrank_sup_add_finrank_inf_eq A B
  rw [hinf] at hsum
  simp only [finrank_bot, add_zero] at hsum
  have hspan : span ℝ (Set.range (blockTask f g)) = A ⊔ B := span_range_blockTask f g
  rw [rankOf, hspan, hsum, hA, hB, finrank_map_incl_left, finrank_map_incl_right]

/-- **Head counts add on block-diagonal tasks.**  This is the equality case of subadditivity:
independent sub-tasks in disjoint feature blocks cannot share heads. -/
theorem minHeads_blockTask [Finite X] [Finite X'] (f : X → Y → ℝ) (g : X' → Y' → ℝ) :
    minHeads (blockTask f g) = minHeads f + minHeads g := by
  rw [minHeads_eq_rankOf, minHeads_eq_rankOf, minHeads_eq_rankOf, rankOf_blockTask]

/-! ## Without the block structure, subadditivity is strict -/

/-- **Strictness of plain subadditivity.**  For a nonzero task `f`, the pair `(f, -f)` has
`minHeads f + minHeads (-f) = 2 · minHeads f > 0 = minHeads (f + (-f))`, so the block structure
in `minHeads_blockTask` is essential. -/
theorem minHeads_add_lt_of_neg [Finite X] (f : X → Y → ℝ) (hf : f ≠ 0) :
    minHeads (fun x => f x + (-f) x) < minHeads f + minHeads (-f) := by
  have hzero : minHeads (fun x => f x + (-f) x) = 0 := by
    have : Representable (fun x => f x + (-f) x) 0 :=
      ⟨fun h => Fin.elim0 h, fun h => Fin.elim0 h, fun x => by simp⟩
    exact Nat.le_zero.mp (Nat.sInf_le this)
  have hpos : 0 < minHeads f := by
    rw [minHeads_eq_rankOf]
    obtain ⟨x, hx⟩ := Function.ne_iff.mp hf
    have hmem : f x ∈ span ℝ (Set.range f) := Submodule.subset_span ⟨x, rfl⟩
    have hne : (span ℝ (Set.range f) : Submodule ℝ (Y → ℝ)) ≠ ⊥ := by
      intro hbot
      rw [hbot, Submodule.mem_bot] at hmem
      exact hx (by simpa using hmem)
    have hnt : Nontrivial (span ℝ (Set.range f)) :=
      Submodule.nontrivial_iff_ne_bot.mpr hne
    exact Module.finrank_pos
  omega

end BlockDiagonalHeads