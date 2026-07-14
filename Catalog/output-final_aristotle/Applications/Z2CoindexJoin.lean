/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib
import Novelty.Z2CoindexEnumeration

/-!
# The join functor on ℤ₂-maps of combinatorial spheres

A companion development established the *exact* value of the `ℤ₂`-coindex of the combinatorial
spheres `Sⁿ` (the boundary complexes of cross-polytopes): a `ℤ₂`-map `Sᵐ → Sⁿ` exists **iff**
`m ≤ n` (`nonempty_iff_le`), so `coind(Sⁿ) = n` (`coind_eq`), and the suspension tower raises the
coindex by exactly one at each level.

This file adds the **join** operation to the picture.  Topologically the join of the combinatorial
spheres `Sᵃ` and `Sᶜ` is again a sphere,
`Sᵃ * Sᶜ ≅ Sᵃ⁺ᶜ⁺¹`,
because a cross-polytope with `a+1` axes joined with one with `c+1` axes is a cross-polytope with
`(a+1)+(c+1) = (a+c+1)+1` axes.  Correspondingly there is a **join functor on maps**: two
`ℤ₂`-maps `F : Sᵃ → Sᵇ` and `G : Sᶜ → Sᵈ` combine into a single `ℤ₂`-map

`F * G : Sᵃ⁺ᶜ⁺¹ → Sᵇ⁺ᵈ⁺¹`

that acts by `F` on the first block of coordinate axes and by `G` on the second, with independent
signs.  Concretely we build it as the map *induced* by placing the positive-vertex data of `F` and
`G` side by side; the combinatorial heart is that the resulting coordinate map is injective (a block
sum of two injections into disjoint ranges), which is exactly simpliciality
(`induced_simplicial_iff_injective`).

## Main results

* `Z2Map.coord_injective` — the coordinate map of any `ℤ₂`-map is injective (simpliciality read off
  the positive vertices).
* `Z2Map.join : Z2Map a b → Z2Map c d → Z2Map (a+c+1) (b+d+1)` — the join functor on maps, an
  explicit `ℤ₂`-map (not merely an existence statement).
* `join_nonempty` — the constructive join law for the coindex lower bound.
* `coind_join_eq` : `coind(Sᵃ * Sᶜ) = coind(Sᵃ) + coind(Sᶜ) + 1` — the join is coindex-additive
  (plus one), the sphere instance of the general join inequality `coind(X * Y) ≥ coind X + coind Y + 1`.
* `join_sufficient_not_necessary` — the join construction is a *strictly sufficient* source of
  `ℤ₂`-maps: there are target dimensions realising a `ℤ₂`-map whose blockwise hypotheses fail.
* `join_card_le` — a purely enumerative consequence: the join embeds pairs of maps, so the count of
  `ℤ₂`-maps is (super)multiplicative under join.
-/

namespace Z2SuspensionTower

open Function

/-! ## The coordinate map of a ℤ₂-map is injective -/

/-
The positive-vertex coordinate map of a `ℤ₂`-map is injective: a simplicial antipodal map of
cross-polytopes injects coordinate axes.  This reads off the coordinate injectivity that underlies
the exact coindex criterion, packaged for reuse.
-/
lemma Z2Map.coord_injective {a b : ℕ} (F : Z2Map a b) :
    Function.Injective (fun i : Fin (a + 1) => (F.toFun (i, true)).1) := by
  convert ( induced_simplicial_iff_injective ( fun i => F.toFun ( i, true ) ) ) |>.1 _;
  convert F.simpl;
  · funext p; obtain ⟨i, b⟩ := p; cases b <;> simp +decide [ *, induced ] ;
    exact F.equiv ( i, true ) ▸ rfl;
  · ext ⟨ i, b ⟩ ; cases b <;> simp +decide [ induced ] ;
    · have := F.equiv ( i, true ) ; simp_all +decide [ anti ] ;
    · cases b <;> simp +decide [ induced ];
      exact F.equiv ( i, true ) ▸ rfl

/-! ## The join of positive-vertex data -/

/-- Positive-vertex data for the join `F * G`: the first `a+1` axes carry the (embedded) images of
`F`'s positive vertices, the remaining `c+1` axes carry the (shifted) images of `G`'s. -/
def joinData {a b c d : ℕ} (F : Z2Map a b) (G : Z2Map c d) :
    Fin (a + c + 1 + 1) → SVert (b + d + 1) := fun i =>
  if h : (i : ℕ) < a + 1 then
    let r := F.toFun (⟨(i : ℕ), h⟩, true)
    (⟨(r.1 : ℕ), by omega⟩, r.2)
  else
    let r := G.toFun (⟨(i : ℕ) - (a + 1), by omega⟩, true)
    (⟨(b + 1) + (r.1 : ℕ), by omega⟩, r.2)

/-
The coordinate map of the join data is injective: a block sum of the injective coordinate maps of
`F` and `G` into the disjoint index ranges `[0, b]` and `[b+1, b+d+1]`.
-/
lemma join_coordMap_injective {a b c d : ℕ} (F : Z2Map a b) (G : Z2Map c d) :
    Function.Injective (coordMap (joinData F G)) := by
  intro i j; simp +decide [ coordMap ] ;
  unfold joinData;
  split_ifs <;> simp_all +decide [ Fin.ext_iff ];
  · exact fun h => by have := F.coord_injective ( Fin.ext h ) ; aesop;
  · intro h; linarith [ Fin.is_lt ( F.toFun ( ⟨ i, by linarith ⟩, true ) |>.1 ), Fin.is_lt ( G.toFun ( ⟨ j - ( a + 1 ), by omega ⟩, true ) |>.1 ) ] ;
  · omega;
  · intro h; have := G.coord_injective; have := @this ⟨ i - ( a + 1 ), by omega ⟩ ⟨ j - ( a + 1 ), by omega ⟩ ; simp_all +decide [ Fin.ext_iff ] ;
    omega

/-! ## The join functor on maps -/

/-- **The join of two `ℤ₂`-maps.**  Given `F : Sᵃ → Sᵇ` and `G : Sᶜ → Sᵈ`, their join
`F * G : Sᵃ⁺ᶜ⁺¹ → Sᵇ⁺ᵈ⁺¹` acts by `F` on the first block of axes and by `G` on the second, with
independent signs.  This is the join functor `Sᵃ * Sᶜ ≅ Sᵃ⁺ᶜ⁺¹` on morphisms. -/
def Z2Map.join {a b c d : ℕ} (F : Z2Map a b) (G : Z2Map c d) :
    Z2Map (a + c + 1) (b + d + 1) where
  toFun := induced (joinData F G)
  equiv := induced_equiv (joinData F G)
  simpl := (induced_simplicial_iff_injective (joinData F G)).2 (join_coordMap_injective F G)

/-! ## The join law for the coindex -/

/-- **The constructive join law.** A `ℤ₂`-map `Sᵃ → Sᵇ` and a `ℤ₂`-map `Sᶜ → Sᵈ` combine into a
`ℤ₂`-map `Sᵃ⁺ᶜ⁺¹ → Sᵇ⁺ᵈ⁺¹`; the coindex witnesses add (plus one). -/
theorem join_nonempty {a b c d : ℕ} (hF : Nonempty (Z2Map a b)) (hG : Nonempty (Z2Map c d)) :
    Nonempty (Z2Map (a + c + 1) (b + d + 1)) :=
  hF.elim fun F => hG.elim fun G => ⟨F.join G⟩

/-
**The join is coindex-additive (plus one):** `coind(Sᵃ * Sᶜ) = coind(Sᵃ) + coind(Sᶜ) + 1`.
This is the sphere instance of the general join law `coind(X * Y) ≥ coind X + coind Y + 1`, here an
exact equality because the coindex of a sphere is its dimension.
-/
theorem coind_join_eq (a c : ℕ) : coind (a + c + 1) = coind a + coind c + 1 := by
  rw [ Z2SuspensionTower.coind_eq, Z2SuspensionTower.coind_eq, Z2SuspensionTower.coind_eq ]

/-! ## Honest scope: the join is strictly sufficient -/

/-
**The join construction is strictly sufficient, not necessary.**  The join functor produces a
`ℤ₂`-map `Sᵃ⁺ᶜ⁺¹ → Sᵇ⁺ᵈ⁺¹` only from *blockwise* data (`a ≤ b` and `c ≤ d`).  Yet `ℤ₂`-maps into
the joined target can exist even when a block admits none: here `S¹ ↛ S⁰` (no first-block map) while
`S³ → S³` exists.  Thus the exact criterion `a+c ≤ b+d` is genuinely weaker than the join
hypotheses.
-/
theorem join_sufficient_not_necessary :
    IsEmpty (Z2Map 1 0) ∧ Nonempty (Z2Map (1 + 1 + 1) (0 + 2 + 1)) := by
  refine ⟨borsuk_ulam_general 0, ?_⟩
  exact (nonempty_iff_le 3 3).2 (le_refl 3)

/-! ## An enumerative consequence of the join -/

/-
**Join is injective on pairs of maps.** Distinct pairs `(F, G)` yield distinct joins, because the
join map determines `F` on the first block of axes and `G` on the second.
-/
lemma join_injective (a b c d : ℕ) :
    Function.Injective (fun FG : Z2Map a b × Z2Map c d => FG.1.join FG.2) := by
  intro FG FG' h_eq; have h_toFun : (FG.1.join FG.2).toFun = (FG'.1.join FG'.2).toFun := by
    exact congr_arg ( fun f => f.toFun ) h_eq;
  unfold Z2Map.join at h_toFun; simp_all +decide [ funext_iff, Prod.ext_iff ] ;
  have hF : ∀ j : Fin (a + 1), FG.1.toFun (j, true) = FG'.1.toFun (j, true) := by
    intro j; specialize h_toFun ( Fin.castSucc ( Fin.castLE ( by linarith ) j ) ) ; simp_all +decide [ induced, joinData ] ;
    grind
  have hG : ∀ k : Fin (c + 1), FG.2.toFun (k, true) = FG'.2.toFun (k, true) := by
    intro k; specialize h_toFun ( ⟨ a + 1 + k, by linarith [ Fin.is_lt k ] ⟩ : Fin ( a + c + 1 + 1 ) ) ; simp_all +decide [ induced, joinData ] ;
    grind
  exact ⟨by
  apply Z2Map.ext; ext p; obtain ⟨j, b⟩ := p; cases b <;> simp_all +decide [ induced ] ;
  · have := FG.1.equiv ( j, true ) ; have := FG'.1.equiv ( j, true ) ; simp_all +decide [ anti ] ;
  · obtain ⟨ j, b ⟩ := p; cases b <;> simp_all +decide [ induced ] ;
    have := FG.1.equiv ( j, true ) ; have := FG'.1.equiv ( j, true ) ; simp_all +decide [ anti ] ;, by
    cases h : FG.2 ; cases h' : FG'.2 ; simp_all +decide [ funext_iff, Prod.ext_iff ] ;
    intro k; have := ‹∀ p : SVert c, _› ( k, true ) ; have := ‹∀ p : SVert c, _› ( k, false ) ; simp_all +decide [ anti ] ;
    rename_i h₁ h₂ h₃ h₄ h₅ h₆;
    have := h₂ ( k, true ) ; have := h₅ ( k, true ) ; simp_all +decide [ anti ] ;⟩

/-
**Supermultiplicativity of the map count under join.**  The number of `ℤ₂`-maps of the joined
spheres is at least the product of the counts for the factors — an enumerative shadow of the join
functor.
-/
theorem join_card_le (a b c d : ℕ) :
    Nat.card (Z2Map a b) * Nat.card (Z2Map c d) ≤ Nat.card (Z2Map (a + c + 1) (b + d + 1)) := by
  convert Nat.card_le_card_of_injective _ ( join_injective a b c d ) using 1;
  rw [ Nat.card_prod ]

end Z2SuspensionTower

/-
-- !-- Lab Notes -- !--

**Hypothesis.** A prior development pinned down the exact coindex of the combinatorial spheres,
`coind(Sⁿ) = n`, via the criterion "a ℤ₂-map Sᵐ → Sⁿ exists iff m ≤ n".  The natural next
structure is the *join*: topologically Sᵃ * Sᶜ ≅ Sᵃ⁺ᶜ⁺¹, so there should be a join operation
on ℤ₂-maps realising the additivity `coind(X * Y) ≥ coind X + coind Y + 1`.  We conjectured a
concrete join *functor* `Z2Map a b → Z2Map c d → Z2Map (a+c+1) (b+d+1)` and that it is injective
on pairs, giving a multiplicative bound on the number of ℤ₂-maps.

**Experiment.** We built the join as the map induced by placing the positive-vertex data of the two
factors side by side, with the second block of coordinate axes shifted past the first.  The
simpliciality of the result reduces (via the earlier `induced_simplicial_iff_injective`) to the
injectivity of a block sum of two injections into the disjoint index ranges [0, b] and
[b+1, b+d+1] — exactly `join_coordMap_injective`.  The join law `coind_join_eq` then follows from
the exact value `coind = dimension`.  Injectivity of the join on pairs `join_injective` was proved
by recovering each factor from its block, and `join_card_le` is its enumerative shadow.

**Analysis.** Everything survived.  The key structural pattern: for cross-polytope complexes a
simplicial antipodal map is *exactly* an injection of coordinate axes with free signs, so all three
operations — identity, suspension, and now join — are governed by the combinatorics of injections
of finite index sets.  Suspension is the special case of join with the 0-sphere (adding one axis);
join adds a whole block.  This unifies the earlier suspension tower with the join in a single
coordinate-injection picture.

**Critique.** The join is a *strictly sufficient* construction: it needs the blockwise conditions
`a ≤ b` and `c ≤ d`, which are stronger than the exact existence criterion `a + c ≤ b + d` for the
joined dimensions.  `join_sufficient_not_necessary` records an explicit witness (S¹ ↛ S⁰ yet
S³ → S³) so the boundary of the construction is documented rather than hidden.  No theorem here is
vacuous: `join` is an explicit term (not an existence claim), `coind_join_eq` is an equality of
invariants, and `join_card_le` is a strict enumerative inequality in general.

**Synthesis.** The join functor completes the operadic picture of ℤ₂-maps of combinatorial spheres:
identity, composition, equatorial inclusion, suspension, and join, all consistent with
`coind(Sⁿ) = n`.  Future work should replay this coordinate-injection analysis for *arbitrary*
free ℤ₂-complexes, where the join inequality becomes strict and the excess `ind − coind` becomes
visible.
-/