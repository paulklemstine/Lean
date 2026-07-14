/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import MachineLearning.WhiteExchange.Basic
import MachineLearning.WhiteExchange.Uniform

/-!
# White's quadratic exchange conjecture, Part 3 — deepening

This file *deepens* the abstract quadratic-exchange engine of `Basic.lean` and the
uniform-matroid instances of `Uniform.lean`.  Where those files defined the open
conjecture `WhitePart3Holds` and verified it only on hand-picked configurations,
here we prove genuine **structural** and **classificatory** theorems:

## Main results

* **Congruence of reachability.**  Basis-preserving reachability `RReachable` is a
  congruence for multiset addition (`RReachable.add_right`, `RReachable.add_left`,
  `RReachable.add`) and for consing a fixed basis (`RReachable.cons`).  Moves can
  be performed inside a larger configuration; this is the compositional backbone
  needed for any inductive proof of White's conjecture.

* **The two-basis reconfiguration theorem.**  For *any* matroid basis family and
  *any* ambient configuration, replacing two of its bases by two others of the
  same family that preserve the total multiset union is a single legal move
  (`reconfig_two_bases_rreachable`).  In the uniform case *every* choice of two
  `r`-subsets with the same combined element-multiset is admissible
  (`uniform_two_basis_rreachable`).

* **White's Part 3 for rank-1 uniform matroids — fully proved.**
  `whitePart3_rank1 : WhitePart3Holds (IsUniformBasis 1)`.  For the rank-1
  uniform matroid `U_{1,n}` the multiset union *determines* the configuration
  (`rank1_config_eq_map`), so any two configurations with equal union are literally
  equal, hence reachable.  This is a complete, unconditional confirmation of
  White's Part 3 conjecture for an infinite family of matroids.

* **Single-basis classification.**  For any basis family, two one-basis
  configurations with the same union are equal (`singleBasis_eq`), a clean
  corollary of the injectivity of `Finset.val`.

## Relation to the open conjecture

The full conjecture `WhitePart3Holds 𝓑` (equal union ⟹ reachable) remains open
for general matroids; `whitePart3_rank1` settles it for rank-1 uniform matroids,
and the congruence + two-basis theorems are exactly the tools by which the
uniform case of higher rank is attacked (see `FUTURE_DIRECTIONS.md`).

## Lab Notes

`-- !-- Lab Notes -- !--`

* **Hypothesis.**  Reachability should be *local*: a move valid on two bases stays
  valid inside any larger multiset, so `RReachable` ought to be an additive
  congruence.  If so, White's conjecture reduces to a "make one basis match, then
  recurse" induction.

* **Experiment.**  `RQMove.add_right` peels the two exchanged bases with
  `Multiset.cons_add`; `RReachable.add_right` lifts it through `Relation.EqvGen`.
  `RReachable.cons` follows via `Multiset.singleton_add`.

* **Analysis.**  Rank 1 is the first fully solvable case: a basis is a singleton,
  `unionMS` is the multiset of chosen elements, and `Finset.card_eq_one` lets us
  reconstruct the configuration as `(unionMS C).map (fun a => {a})`.  Injectivity
  of this reconstruction is what makes equal-union ⇒ equal-configuration, hence
  reachable by reflexivity.

* **Critique.**  Rank 1 collapses because moves cannot actually *rearrange* which
  element lives in which basis (each basis holds exactly one element).  The content
  of White's conjecture reappears at rank ≥ 2; `reconfig_two_bases_rreachable`
  isolates the atomic step that a general induction must iterate.

* **Synthesis.**  A compositional theory of quadratic-exchange reachability plus a
  complete proof of White's Part 3 for rank-1 uniform matroids, with the exact
  inductive step for higher rank exhibited as a theorem.
-/

open Finset

namespace WhiteExchange

variable {α : Type*}

/-! ## Congruence of basis-preserving reachability under multiset addition -/

/-- A basis-preserving quadratic move stays valid inside a larger configuration:
appending a fixed multiset `E` of bases to both sides preserves the move. -/
theorem RQMove.add_right {𝓑 : Finset α → Prop} {C D : Multiset (Finset α)}
    (E : Multiset (Finset α)) (h : RQMove 𝓑 C D) : RQMove 𝓑 (C + E) (D + E) := by
  obtain ⟨rest, B₁, B₂, C₁, C₂, hC, hD, hval, h1, h2⟩ := h
  exact ⟨rest + E, B₁, B₂, C₁, C₂, by subst hC; simp [Multiset.cons_add],
    by subst hD; simp [Multiset.cons_add], hval, h1, h2⟩

/-- **Right congruence.**  Reachability is preserved by appending a fixed
configuration `E` on the right. -/
theorem RReachable.add_right {𝓑 : Finset α → Prop} {C D : Multiset (Finset α)}
    (E : Multiset (Finset α)) (h : RReachable 𝓑 C D) :
    RReachable 𝓑 (C + E) (D + E) := by
  induction h with
  | rel x y hxy => exact Relation.EqvGen.rel _ _ (hxy.add_right E)
  | refl x => exact Relation.EqvGen.refl _
  | symm x y _ ih => exact Relation.EqvGen.symm _ _ ih
  | trans x y z _ _ ih1 ih2 => exact Relation.EqvGen.trans _ _ _ ih1 ih2

/-- **Left congruence.**  Reachability is preserved by prepending a fixed
configuration `E` on the left. -/
theorem RReachable.add_left {𝓑 : Finset α → Prop} {C D : Multiset (Finset α)}
    (E : Multiset (Finset α)) (h : RReachable 𝓑 C D) :
    RReachable 𝓑 (E + C) (E + D) := by
  rw [add_comm E C, add_comm E D]; exact h.add_right E

/-- **Full congruence.**  Reachability is compatible with multiset addition on
both arguments. -/
theorem RReachable.add {𝓑 : Finset α → Prop} {C D C' D' : Multiset (Finset α)}
    (h : RReachable 𝓑 C D) (h' : RReachable 𝓑 C' D') :
    RReachable 𝓑 (C + C') (D + D') :=
  (h.add_right C').trans (h'.add_left D)

/-- **Cons congruence.**  Reachability is preserved by consing a fixed basis `B`. -/
theorem RReachable.cons {𝓑 : Finset α → Prop} {C D : Multiset (Finset α)}
    (B : Finset α) (h : RReachable 𝓑 C D) :
    RReachable 𝓑 (B ::ₘ C) (B ::ₘ D) := by
  have := h.add_left {B}
  rwa [Multiset.singleton_add, Multiset.singleton_add] at this

/-! ## The two-basis reconfiguration theorem -/

/-- **Reconfiguring two bases inside any configuration.**  In any ambient
configuration `rest`, replacing two bases `B₁, B₂` by two members `C₁, C₂` of the
family `𝓑` with the same combined element-multiset is a single legal move, hence a
reachability. -/
theorem reconfig_two_bases_rreachable {𝓑 : Finset α → Prop}
    (rest : Multiset (Finset α)) (B₁ B₂ C₁ C₂ : Finset α)
    (hval : B₁.val + B₂.val = C₁.val + C₂.val) (hC₁ : 𝓑 C₁) (hC₂ : 𝓑 C₂) :
    RReachable 𝓑 (B₁ ::ₘ B₂ ::ₘ rest) (C₁ ::ₘ C₂ ::ₘ rest) :=
  Relation.EqvGen.rel _ _ ⟨rest, B₁, B₂, C₁, C₂, rfl, rfl, hval, hC₁, hC₂⟩

/-- **Uniform two-basis connectivity.**  In `U_{r,n}` any two `r`-subsets `C₁, C₂`
whose combined element-multiset equals that of `B₁, B₂` are reachable from
`B₁, B₂` by a single basis-preserving quadratic move. -/
theorem uniform_two_basis_rreachable {n r : ℕ} (B₁ B₂ C₁ C₂ : Finset (Fin n))
    (hC₁ : C₁.card = r) (hC₂ : C₂.card = r)
    (hval : B₁.val + B₂.val = C₁.val + C₂.val) :
    RReachable (IsUniformBasis r) (B₁ ::ₘ B₂ ::ₘ 0) (C₁ ::ₘ C₂ ::ₘ 0) :=
  reconfig_two_bases_rreachable 0 B₁ B₂ C₁ C₂ hval hC₁ hC₂

/-! ## Single-basis classification -/

/-- **Single-basis rigidity.**  Two one-basis configurations with the same total
multiset union are equal.  (Consequence of the injectivity of `Finset.val`.) -/
theorem singleBasis_eq {B C : Finset α} (h : unionMS ({B} : Multiset (Finset α)) =
    unionMS ({C} : Multiset (Finset α))) : B = C := by
  have hB : unionMS ({B} : Multiset (Finset α)) = B.val := by
    simp [unionMS]
  have hC : unionMS ({C} : Multiset (Finset α)) = C.val := by
    simp [unionMS]
  rw [hB, hC] at h
  exact Finset.val_injective h

/-! ## White's Part 3 for rank-1 uniform matroids -/

/-- For a rank-1 configuration (every basis a singleton), the total multiset union
determines the configuration: it is recovered by mapping each element to its
singleton basis. -/
theorem rank1_config_eq_map [DecidableEq α] {C : Multiset (Finset α)}
    (h : SupportedOn (fun B : Finset α => B.card = 1) C) :
    C = (unionMS C).map (fun a => ({a} : Finset α)) := by
  induction C using Multiset.induction with
  | empty => simp
  | cons B C' ih =>
    have hB : B.card = 1 := h B (Multiset.mem_cons_self B C')
    obtain ⟨b, rfl⟩ := Finset.card_eq_one.mp hB
    have hC' : SupportedOn (fun B : Finset α => B.card = 1) C' :=
      fun X hX => h X (Multiset.mem_cons_of_mem hX)
    rw [unionMS_cons]
    have hval : ({b} : Finset α).val = ({b} : Multiset α) := rfl
    rw [hval, Multiset.map_add, Multiset.map_singleton, ← ih hC', Multiset.singleton_add]

/-- **White's Part 3 conjecture holds for rank-1 uniform matroids.**  For every `n`,
any two configurations of singleton bases of `U_{1,n}` with the same total
multiset union are connected by basis-preserving quadratic moves — indeed they are
equal.  This is a complete, unconditional instance of White's conjecture for an
infinite family of matroids. -/
theorem whitePart3_rank1 {n : ℕ} : WhitePart3Holds (IsUniformBasis (n := n) 1) := by
  intro C D hC hD hCD
  have eC : C = (unionMS C).map (fun a => ({a} : Finset (Fin n))) := rank1_config_eq_map hC
  have eD : D = (unionMS D).map (fun a => ({a} : Finset (Fin n))) := rank1_config_eq_map hD
  have hCeqD : C = D := by rw [eC, eD, hCD]
  exact hCeqD ▸ Relation.EqvGen.refl C

/-! ## Examples -/

section Examples

#check @whitePart3_rank1
#check @RReachable.add
#check @reconfig_two_bases_rreachable

/-- A three-basis rank-1 configuration on `Fin 3`. -/
example : WhitePart3Holds (IsUniformBasis (n := 5) 1) := whitePart3_rank1

/-- Two singleton configurations with the same union are the same multiset. -/
example :
    (({0} : Finset (Fin 3)) ::ₘ ({1} : Finset (Fin 3)) ::ₘ 0) =
    (({1} : Finset (Fin 3)) ::ₘ ({0} : Finset (Fin 3)) ::ₘ 0) := by
  decide

/-- A larger uniform reconfiguration: inside the ambient basis `{4,5}`, swap the
matching `{0,1},{2,3}` for `{0,2},{1,3}` in `U_{2,6}` by a single move. -/
example :
    RReachable (IsUniformBasis 2)
      (({0, 1} : Finset (Fin 6)) ::ₘ ({2, 3} : Finset (Fin 6)) ::ₘ
        ({4, 5} : Finset (Fin 6)) ::ₘ 0)
      (({0, 2} : Finset (Fin 6)) ::ₘ ({1, 3} : Finset (Fin 6)) ::ₘ
        ({4, 5} : Finset (Fin 6)) ::ₘ 0) := by
  refine reconfig_two_bases_rreachable _ _ _ _ _ ?_ ?_ ?_
  · decide
  · show ({0, 2} : Finset (Fin 6)).card = 2; decide
  · show ({1, 3} : Finset (Fin 6)).card = 2; decide

end Examples

end WhiteExchange