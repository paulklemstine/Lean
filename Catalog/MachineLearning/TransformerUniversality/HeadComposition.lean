import Mathlib

/-!
# Compositional behaviour of head complexity

`Catalog/MachineLearning/TransformerUniversality/HeadComplexity.lean` characterizes the minimal
number of heads of a value-sum architecture computing a finite value table `f` as the rank of
that table.  The second next-cycle sub-conjecture of `FUTURE_DIRECTIONS.md` asked how this
resource behaves under composition.  This file settles it.

We repeat the definitions of that file (each catalog file is self-contained):
a *value-sum architecture with `H` heads* computes `model x = ∑ h : Fin H, c h x • v h`, with
arbitrary input-dependent scalar gates `c h` and input-independent value vectors `v h`.

Main results:

* `Representable.postcomp` / `minHeads_postcomp_le` — post-composition with a **linear**
  read-out never increases the head count;
* `minHeads_postcomp_of_injective` — and never decreases it either when the read-out is
  injective, because an injective linear map between vector spaces has a linear left inverse;
  hence head complexity is an invariant of the value table up to linear isomorphism;
* `minHeads_postcomp_zero` — the inequality really can be strict (the zero read-out), so
  injectivity is not a technical artifact;
* `Representable.add` / `minHeads_add_le` — **subadditivity**: heads of a sum of tasks are at
  most the sum of the heads, realized by concatenating the two head sets (`Fin.append`);
* `minHeads_smul_le`, `minHeads_precomp_le` — scaling the task and restricting the input
  domain do not increase head complexity;
* `minHeads_le_card` — the catalog's exact-lookup construction as an upper bound, which is
  also what makes `minHeads` a genuine minimum (the defining set is nonempty).

Together these say that `minHeads` is a *monotone, subadditive, linear-isomorphism invariant*
of the value table: exactly the formal properties one wants from a complexity measure, and the
properties needed to reason about stacked attention blocks rather than a single layer.
-/

open scoped BigOperators

namespace HeadComposition

variable {X X' Y Z : Type*} [Fintype X]

/-- A value-sum architecture with `H` heads (cf. `HeadComplexity.Representable`). -/
def Representable (f : X → Y → ℝ) (H : ℕ) : Prop :=
  ∃ (c : Fin H → X → ℝ) (v : Fin H → (Y → ℝ)), ∀ x, f x = ∑ h, c h x • v h

/-- The minimal number of heads of a value-sum architecture computing `f`. -/
noncomputable def minHeads (f : X → Y → ℝ) : ℕ := sInf {H | Representable f H}

/-- The catalog's one-head-per-input construction: `|X|` heads always suffice. -/
theorem representable_card [DecidableEq X] (f : X → Y → ℝ) :
    Representable f (Fintype.card X) := by
  classical
  obtain ⟨e⟩ : Nonempty (Fin (Fintype.card X) ≃ X) := ⟨(Fintype.equivFin X).symm⟩
  refine ⟨fun h x => if x = e h then 1 else 0, fun h => f (e h), fun x => ?_⟩
  rw [Finset.sum_eq_single (e.symm x)]
  · simp
  · intro h _ hne
    have hx : x ≠ e h := fun hx => hne (by rw [hx, Equiv.symm_apply_apply])
    simp [hx]
  · intro hx
    exact absurd (Finset.mem_univ _) hx

theorem minHeads_le_card [DecidableEq X] (f : X → Y → ℝ) : minHeads f ≤ Fintype.card X :=
  Nat.sInf_le (representable_card f)

/-- The defining set of `minHeads` is nonempty, so `minHeads` is attained. -/
theorem representable_minHeads [DecidableEq X] (f : X → Y → ℝ) :
    Representable f (minHeads f) :=
  Nat.sInf_mem (s := {H | Representable f H}) ⟨Fintype.card X, representable_card f⟩

section PostComposition

omit [Fintype X] in
/-- **Linear read-outs are free.**  Applying a linear map to the output of an `H`-head model
gives an `H`-head model. -/
theorem Representable.postcomp {f : X → Y → ℝ} {H : ℕ} (hf : Representable f H)
    (L : (Y → ℝ) →ₗ[ℝ] (Z → ℝ)) : Representable (fun x => L (f x)) H := by
  obtain ⟨c, v, hcv⟩ := hf
  refine ⟨c, fun h => L (v h), fun x => ?_⟩
  show L (f x) = _
  rw [hcv x, map_sum]
  exact Finset.sum_congr rfl fun h _ => by rw [map_smul]

theorem minHeads_postcomp_le [DecidableEq X] (f : X → Y → ℝ) (L : (Y → ℝ) →ₗ[ℝ] (Z → ℝ)) :
    minHeads (fun x => L (f x)) ≤ minHeads f :=
  Nat.sInf_le ((representable_minHeads f).postcomp L)

/-- **Head complexity is a linear-isomorphism invariant.**  An injective linear read-out
changes nothing: it has a linear left inverse, so the two models transform into each other. -/
theorem minHeads_postcomp_of_injective [DecidableEq X] (f : X → Y → ℝ)
    (L : (Y → ℝ) →ₗ[ℝ] (Z → ℝ)) (hL : Function.Injective L) :
    minHeads (fun x => L (f x)) = minHeads f := by
  refine le_antisymm (minHeads_postcomp_le f L) ?_
  obtain ⟨G, hG⟩ := L.exists_leftInverse_of_injective (LinearMap.ker_eq_bot.mpr hL)
  have hGL : ∀ y, G (L y) = y := fun y => by simpa using LinearMap.congr_fun hG y
  have hrep : Representable f (minHeads (fun x => L (f x))) := by
    have h := (representable_minHeads (fun x => L (f x))).postcomp G
    obtain ⟨c, v, hcv⟩ := h
    exact ⟨c, v, fun x => by simpa [hGL] using hcv x⟩
  exact Nat.sInf_le hrep

omit [Fintype X] in
/-- **The inequality is genuinely strict in general.**  The zero read-out collapses every task
to a zero-head model, whatever the head complexity of the task. -/
theorem minHeads_postcomp_zero [DecidableEq X] (f : X → Y → ℝ) :
    minHeads (fun x => (0 : (Y → ℝ) →ₗ[ℝ] (Z → ℝ)) (f x)) = 0 := by
  have hrep : Representable (fun x => (0 : (Y → ℝ) →ₗ[ℝ] (Z → ℝ)) (f x)) 0 :=
    ⟨fun h => Fin.elim0 h, fun h => Fin.elim0 h, fun x => by simp⟩
  exact Nat.le_zero.mp (Nat.sInf_le hrep)

end PostComposition

section Additivity

omit [Fintype X] in
/-- **Concatenating head sets.**  A model for `f` with `H₁` heads and a model for `g` with `H₂`
heads combine into a model for `f + g` with `H₁ + H₂` heads. -/
theorem Representable.add {f g : X → Y → ℝ} {H₁ H₂ : ℕ}
    (hf : Representable f H₁) (hg : Representable g H₂) :
    Representable (fun x => f x + g x) (H₁ + H₂) := by
  obtain ⟨c₁, v₁, h₁⟩ := hf
  obtain ⟨c₂, v₂, h₂⟩ := hg
  refine ⟨Fin.append c₁ c₂, Fin.append v₁ v₂, fun x => ?_⟩
  rw [Fin.sum_univ_add]
  have e₁ : ∑ i : Fin H₁, (Fin.append c₁ c₂) (Fin.castAdd H₂ i) x •
      (Fin.append v₁ v₂) (Fin.castAdd H₂ i) = ∑ i : Fin H₁, c₁ i x • v₁ i := by
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [Fin.append_left, Fin.append_left]
  have e₂ : ∑ i : Fin H₂, (Fin.append c₁ c₂) (Fin.natAdd H₁ i) x •
      (Fin.append v₁ v₂) (Fin.natAdd H₁ i) = ∑ i : Fin H₂, c₂ i x • v₂ i := by
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [Fin.append_right, Fin.append_right]
  rw [e₁, e₂, ← h₁ x, ← h₂ x]

/-- **Subadditivity of head complexity.** -/
theorem minHeads_add_le [DecidableEq X] (f g : X → Y → ℝ) :
    minHeads (fun x => f x + g x) ≤ minHeads f + minHeads g :=
  Nat.sInf_le ((representable_minHeads f).add (representable_minHeads g))

/-- Rescaling a task does not increase its head complexity. -/
theorem minHeads_smul_le [DecidableEq X] (a : ℝ) (f : X → Y → ℝ) :
    minHeads (fun x => a • f x) ≤ minHeads f := by
  obtain ⟨c, v, hcv⟩ := representable_minHeads f
  refine Nat.sInf_le ⟨fun h x => a * c h x, v, fun x => ?_⟩
  show a • f x = _
  rw [hcv x, Finset.smul_sum]
  exact Finset.sum_congr rfl fun h _ => by rw [smul_smul]

/-- Restricting (or reindexing) the input domain does not increase head complexity. -/
theorem minHeads_precomp_le [DecidableEq X] [Fintype X'] [DecidableEq X']
    (f : X → Y → ℝ) (r : X' → X) :
    minHeads (fun x' => f (r x')) ≤ minHeads f := by
  obtain ⟨c, v, hcv⟩ := representable_minHeads f
  exact Nat.sInf_le ⟨fun h x' => c h (r x'), v, fun x' => hcv (r x')⟩

end Additivity

/-- **Summary: `minHeads` is a well-behaved complexity measure.**  It is bounded by the domain
size, invariant under injective linear read-outs, monotone under arbitrary linear read-outs,
and subadditive. -/
theorem minHeads_structure [DecidableEq X] (f g : X → Y → ℝ)
    (L : (Y → ℝ) →ₗ[ℝ] (Z → ℝ)) (hL : Function.Injective L) :
    minHeads f ≤ Fintype.card X ∧
      minHeads (fun x => L (f x)) = minHeads f ∧
      minHeads (fun x => f x + g x) ≤ minHeads f + minHeads g :=
  ⟨minHeads_le_card f, minHeads_postcomp_of_injective f L hL, minHeads_add_le f g⟩

end HeadComposition