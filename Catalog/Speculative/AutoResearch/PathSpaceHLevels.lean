/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Logic.HomotopyTypeTheory

set_option autoImplicit false

/-!
# Path Spaces, h-Levels, and the Fibrewise Characterisation of Equivalences

This file *extends* the synthetic homotopy development of `Logic.HomotopyTypeTheory`
(`HoTT.IsContr`, `HoTT.IsMereProp`, `HoTT.HFiber`, …) toward the heart of the
"homotopy & path spaces" program: **contractibility of path spaces**, the
**closure of the h-level hierarchy** under the basic type formers, and the
fundamental bridge

    a map is an equivalence  ⇔  all of its homotopy fibres are contractible.

It then *unifies* the synthetic picture with Mathlib's classical topology, proving
that every continuous map into a contractible space is null-homotopic, hence that
the mapping space into a contractible target is connected up to homotopy. This is
the "localization/universality" face of contractibility: a contractible object is a
*terminal object of the homotopy category*, so the path space `Map(X, *)` is itself
contractible-by-homotopy.

## Main results

* `HoTT.isContr_based_paths` — the based path space `{ b // a = b }` is contractible
  (synthetic *path induction* / contractibility of singletons).
* `HoTT.isContr_retract` — contractibility is inherited by retracts.
* `HoTT.isContr_sigma` / `HoTT.isMereProp_sigma` — Σ-closure of the h-levels.
* `HoTT.isContr_fun` — a product of contractible types is contractible.
* `HoTT.isContr_iff` — `IsContr A ↔ Nonempty A ∧ IsMereProp A`.
* `HoTT.bijective_iff_contr_fibers` — **equivalences are exactly the maps with
  contractible homotopy fibres** (both directions).
* `HoTT.isContr_unique_equiv` — any two contractible types are equivalent
  (uniqueness of the terminal homotopy type).
* `HoTT.map_to_contractible_nullhomotopic` /
  `HoTT.maps_to_contractible_homotopic` — classical-topology realisation: every
  `C(X, Y)` into a contractible `Y` is null-homotopic, and any two such maps are
  homotopic.
-/

-- !-- Lab Notebook -- !--
-- Hypothesis: The h-level predicates `IsContr`/`IsMereProp` of the catalog HoTT
--   file should be closed under Σ, Π and retracts, and contractibility should be
--   characterisable purely fibrewise ("equivalence = contractible fibres"), with a
--   classical shadow in Mathlib's `ContractibleSpace`/`ContinuousMap.Homotopic`.
-- Result: All eight target theorems proved with `sorry = 0`. The fibrewise
--   characterisation `bijective_iff_contr_fibers` upgrades the catalog's one-way
--   `bijective_of_contr_fibers` to a genuine ↔, and the topological corollaries
--   show a contractible space is terminal in the homotopy category.
-- Insight: In Lean's proof-irrelevant `Prop`, `IsHSet` is *automatically* true
--   (every equality type is a subsingleton), so the only homotopically non-trivial
--   h-levels are (-2) `IsContr` and (-1) `IsMereProp`. The substantive content of
--   "path spaces" therefore lives entirely in `IsContr` of based path spaces and in
--   the fibrewise picture — which is exactly where we concentrated the proofs.
-- Failure analysis: (1) `Σ b, a = b` does not typecheck because `a = b : Prop`
--   sits in `Sort 0` while `Sigma` wants `Type`; the based path space must be the
--   subtype `{ b // a = b }`. (2) `ContinuousMap.homotopic_const_iff` carries a
--   `[Nonempty (domain)]` side condition, so `maps_to_contractible_homotopic` must
--   case-split on whether the source `X` is empty (where the map space is a
--   subsingleton and `refl` finishes).

noncomputable section

namespace HoTT

universe u v

/-! ## Contractibility of path spaces -/

-- !-- The based path space `{ b // a = b }` is contractible: its centre is
-- `⟨a, rfl⟩`, and `rintro ⟨b, rfl⟩` collapses every other point to the centre.
-- This is the synthetic form of *path induction* (the "J rule"). -- !--
/-- **Contractibility of singletons.** The based path space `{ b // a = b }` —
the homotopy-theoretic "space of paths out of `a`" — is contractible. -/
theorem isContr_based_paths {A : Type u} (a : A) : IsContr { b : A // a = b } := by
  refine ⟨⟨a, rfl⟩, ?_⟩
  rintro ⟨b, rfl⟩
  rfl

-- !-- Push the centre `c` of `A` forward to `r c`; for any `b`, rewrite
-- `b = r (s b) = r c` using the retraction `h` and contractibility `hc`. -- !--
/-- Contractibility is inherited by retracts: if `r ∘ s = id` and `A` is
contractible, so is `B`. -/
theorem isContr_retract {A : Type u} {B : Type v} (r : A → B) (s : B → A)
    (h : ∀ b, r (s b) = b) (hA : IsContr A) : IsContr B := by
  obtain ⟨c, hc⟩ := hA
  refine ⟨r c, fun b => ?_⟩
  rw [← h b, hc (s b)]

/-! ## Σ- and Π-closure of the h-level hierarchy -/

-- !-- Centre `⟨c, d⟩` with `c` the centre of `A` and `d` that of the fibre `B c`;
-- `obtain rfl := hc a` aligns the base, then `Sigma.ext` reduces to the fibre. -- !--
/-- A Σ-type with contractible base and contractible fibres is contractible. -/
theorem isContr_sigma {A : Type u} {B : A → Type v}
    (hA : IsContr A) (hB : ∀ a, IsContr (B a)) : IsContr (Σ a, B a) := by
  obtain ⟨c, hc⟩ := hA
  obtain ⟨d, hd⟩ := hB c
  refine ⟨⟨c, d⟩, ?_⟩
  rintro ⟨a, x⟩
  obtain rfl := hc a
  exact Sigma.ext rfl (by simpa using hd x)

-- !-- Align the bases with the base-level propositionality, then conclude the
-- fibre equality from `hB`; `Sigma.ext` glues the two. -- !--
/-- A Σ-type with mere-propositional base and mere-propositional fibres is a mere
proposition. -/
theorem isMereProp_sigma {A : Type u} {B : A → Type v}
    (hA : IsMereProp A) (hB : ∀ a, IsMereProp (B a)) : IsMereProp (Σ a, B a) := by
  rintro ⟨a, x⟩ ⟨a', x'⟩
  obtain rfl := hA a a'
  exact Sigma.ext rfl (by simpa using hB a x x')

-- !-- Choose the centre of each fibre pointwise; `funext` together with each
-- fibre's contraction collapses any dependent function to that choice. -- !--
/-- A dependent product of contractible types is contractible. -/
theorem isContr_fun {A : Type u} {B : A → Type v}
    (hB : ∀ a, IsContr (B a)) : IsContr (∀ a, B a) := by
  refine ⟨fun a => (hB a).choose, fun f => ?_⟩
  exact funext fun a => (hB a).choose_spec (f a)

/-! ## Characterisations of contractibility -/

-- !-- `IsContr` packages "pointed" (`Nonempty`) and "all points equal"
-- (`IsMereProp`); each direction is a one-line repackaging. -- !--
/-- A type is contractible iff it is inhabited and a mere proposition: the bridge
between h-level `(-2)` and h-level `(-1)`. -/
theorem isContr_iff {A : Type u} : IsContr A ↔ Nonempty A ∧ IsMereProp A := by
  constructor
  · rintro ⟨c, hc⟩
    exact ⟨⟨c⟩, fun a b => (hc a).trans (hc b).symm⟩
  · rintro ⟨⟨c⟩, hp⟩
    exact ⟨c, fun a => hp a c⟩

-- !-- (→) surjectivity gives the fibre's centre, injectivity its uniqueness.
-- (←) a centre over `f a` forces injectivity, and the centre itself gives a
-- preimage, hence surjectivity. -- !--
/-- **Equivalences are exactly the maps with contractible homotopy fibres.**
This upgrades the catalog's one-directional `HoTT.bijective_of_contr_fibers`
to a full characterisation, the cornerstone of the homotopical theory of
equivalences. -/
theorem bijective_iff_contr_fibers {A : Type u} {B : Type v} (f : A → B) :
    Function.Bijective f ↔ ∀ b, IsContr (HFiber f b) := by
  constructor
  · rintro ⟨hinj, hsurj⟩ b
    obtain ⟨a, ha⟩ := hsurj b
    refine ⟨⟨a, ha⟩, ?_⟩
    rintro ⟨a', ha'⟩
    exact Subtype.ext (hinj (ha'.trans ha.symm))
  · intro hf
    refine ⟨fun a a' h => ?_, fun b => ?_⟩
    · obtain ⟨c, hc⟩ := hf (f a)
      exact congrArg Subtype.val ((hc ⟨a, rfl⟩).trans (hc ⟨a', h.symm⟩).symm)
    · obtain ⟨c, _⟩ := hf b
      exact ⟨c.1, c.2⟩

-- !-- Both types are pointed singletons, so the constant maps to each centre are
-- mutually inverse, exhibiting the equivalence. -- !--
/-- Any two contractible types are equivalent: the homotopy category has a unique
terminal object up to equivalence. -/
theorem isContr_unique_equiv {A : Type u} {B : Type v}
    (hA : IsContr A) (hB : IsContr B) : Nonempty (A ≃ B) := by
  obtain ⟨a₀, ha⟩ := hA
  obtain ⟨b₀, hb⟩ := hB
  exact ⟨⟨fun _ => b₀, fun _ => a₀, fun a => (ha a).symm, fun b => (hb b).symm⟩⟩

/-! ## Classical realisation: contractible targets are terminal up to homotopy -/

-- !-- `id_nullhomotopic Y` says `id_Y` is null-homotopic; precomposing with `f`
-- via `Nullhomotopic.comp_left` and `id.comp f = f` transfers null-homotopy. -- !--
/-- Every continuous map into a contractible space is null-homotopic. -/
theorem map_to_contractible_nullhomotopic {X : Type u} {Y : Type v}
    [TopologicalSpace X] [TopologicalSpace Y] [ContractibleSpace Y] (f : C(X, Y)) :
    f.Nullhomotopic := by
  simpa using (id_nullhomotopic Y).comp_left f

-- !-- Each map is homotopic to a constant; the two constants are homotopic since a
-- contractible space is path-connected (`homotopic_const_iff` + `Joined`). The
-- empty-source case is handled separately since the map space is then a
-- subsingleton. -- !--
/-- Any two continuous maps into a contractible space are homotopic; i.e. the
mapping space `C(X, Y)` with `Y` contractible is connected up to homotopy. -/
theorem maps_to_contractible_homotopic {X : Type u} {Y : Type v}
    [TopologicalSpace X] [TopologicalSpace Y] [ContractibleSpace Y] (f g : C(X, Y)) :
    f.Homotopic g := by
  rcases isEmpty_or_nonempty X with hX | hX
  · have hfg : f = g := by ext x; exact (hX.false x).elim
    exact hfg ▸ ContinuousMap.Homotopic.refl f
  · obtain ⟨y, hy⟩ := map_to_contractible_nullhomotopic f
    obtain ⟨y', hy'⟩ := map_to_contractible_nullhomotopic g
    have hj : Joined y y' := PathConnectedSpace.joined y y'
    exact hy.trans ((ContinuousMap.homotopic_const_iff.mpr hj).trans hy'.symm)

end HoTT

end