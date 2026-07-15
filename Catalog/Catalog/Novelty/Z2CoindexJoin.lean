/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib
import Novelty.Z2CoindexSuspensionTower

/-!
# The join bifunctor and the sharp join law for the ℤ₂-coindex

This file *deepens* the combinatorial coindex theory of `Novelty.Z2CoindexSuspensionTower`
(the exact suspension tower `coind(Sⁿ) = n`) by developing the **join** `K ⋆ L` of free
`ℤ₂`-complexes and proving the constructive lower-bound half of the join law together with the
*sharp* value on the octahedral tower.

## The general model

A **free `ℤ₂`-set** (`FreeZ2`) is a type `V` with a fixed-point-free involution `anti` (the
antipodal action).  Its simplicial structure is the octahedral / cross-polytope one: faces are the
antipodal-pair-free finite subsets, so a *simplicial equivariant map* (`GMap K L`) is an
antipodally-equivariant vertex map that never sends a non-antipodal pair to an antipodal pair
(`simpl`).  The octahedral sphere `Sⁿ = Oct n` is the free `ℤ₂`-set of signed unit vectors
`SVert n = Fin (n+1) × Bool` with `anti (i,b) = (i,!b)`; it reuses the machinery of the base file
(`nonempty_iff_le : Nonempty (Z2Map m n) ↔ m ≤ n`).

The **`ℤ₂`-coindex** of a free `ℤ₂`-set is `coind K = sSup {m | Nonempty (GMap (Oct m) K)}`,
the largest sphere admitting an equivariant simplicial map into `K`.

## Main results

* `GMap.joinMap` — the **join bifunctor**: `GMap A K → GMap B L → GMap (A ⋆ B) (K ⋆ L)`.
* `octJoinEquiv`, `octJoinIso`, `octJoinIsoInv` — the **join-monoid isomorphism**
  `Oct m ⋆ Oct n ≅ Oct (m+n+1)`, realised by an explicit coordinate-splitting equivariant
  bijection.
* `coindex_join_lower_bound` — the **constructive lower bound** (the headline of the programme):
  for arbitrary free `ℤ₂`-sets, coindex witnesses of the factors combine to a witness for the join
  that is larger by one, i.e. `coind(K ⋆ L) ≥ coind(K) + coind(L) + 1`.
* `coind_octJoin`, `coind_join_eq_add` — the **sharp join law on the octahedral tower**:
  `coind(Oct m ⋆ Oct n) = m + n + 1 = coind(Oct m) + coind(Oct n) + 1`.
* `coind_join_S0` — the classical **suspension jump** recovered as the special case `L = S⁰ = Oct 0`:
  `coind(Oct m ⋆ Oct 0) = m + 1`.
* `coind_join_comm`, `coind_join_left`, `coind_join_right`, `coind_join_assoc` — the octahedral
  spheres form a **commutative associative join-monoid** on the level of the coindex.

The upper-bound half of the join law for *arbitrary* free `ℤ₂`-sets (a genuine equivariant
cohomological obstruction) is beyond this combinatorial model; here it is proved *exactly* on the
octahedral tower, where the coindex equals the dimension.
-/

namespace Z2CoindexJoin

open Z2SuspensionTower Function

/-! ## Free ℤ₂-sets and their equivariant simplicial maps -/

/-- A **free `ℤ₂`-set**: a type with a fixed-point-free involution (the antipodal action).  Its
simplicial structure is the octahedral one — faces are the antipodal-pair-free subsets. -/
structure FreeZ2 where
  /-- The vertex type. -/
  V : Type
  /-- The antipodal involution. -/
  anti : V → V
  /-- The involution is an involution. -/
  anti_anti : ∀ v, anti (anti v) = v
  /-- The involution is fixed-point free (freeness of the `ℤ₂`-action). -/
  anti_ne : ∀ v, anti v ≠ v

/-- A **`ℤ₂`-map** `K → L`: an antipodally-equivariant vertex map that is simplicial, i.e. sends no
non-antipodal pair to an antipodal pair. -/
structure GMap (K L : FreeZ2) where
  /-- The underlying vertex map. -/
  toFun : K.V → L.V
  /-- Equivariance with respect to the antipodal actions. -/
  equiv : ∀ p, toFun (K.anti p) = L.anti (toFun p)
  /-- Simpliciality (no non-antipodal pair maps to an antipodal pair). -/
  simpl : ∀ p q, toFun p = L.anti (toFun q) → p = K.anti q

namespace GMap

/-- The identity `ℤ₂`-map. -/
def id (K : FreeZ2) : GMap K K where
  toFun := _root_.id
  equiv := fun _ => rfl
  simpl := fun _ _ h => by simpa using h

/-- Composition of `ℤ₂`-maps. -/
def comp {K L M : FreeZ2} (G : GMap L M) (F : GMap K L) : GMap K M where
  toFun := G.toFun ∘ F.toFun
  equiv := fun p => by simp [Function.comp, F.equiv, G.equiv]
  simpl := fun p q h => F.simpl p q (G.simpl _ _ h)

/-- An equivariant bijection is a `ℤ₂`-map (simpliciality is automatic from injectivity). -/
def ofEquiv {K L : FreeZ2} (e : K.V ≃ L.V)
    (he : ∀ p, e (K.anti p) = L.anti (e p)) : GMap K L where
  toFun := e
  equiv := he
  simpl := fun p q h => by
    have : e p = e (K.anti q) := by rw [he]; exact h
    exact e.injective this

/-- The inverse of an equivariant bijection is again equivariant. -/
lemma symm_equiv {K L : FreeZ2} (e : K.V ≃ L.V)
    (he : ∀ p, e (K.anti p) = L.anti (e p)) :
    ∀ p, e.symm (L.anti p) = K.anti (e.symm p) := by
  intro p; apply e.injective; rw [he, e.apply_symm_apply, e.apply_symm_apply]

/-- Equivariance is preserved by composing equivariant bijections. -/
lemma trans_equiv {K L M : FreeZ2} (e : K.V ≃ L.V) (f : L.V ≃ M.V)
    (he : ∀ p, e (K.anti p) = L.anti (e p)) (hf : ∀ p, f (L.anti p) = M.anti (f p)) :
    ∀ p, (e.trans f) (K.anti p) = M.anti ((e.trans f) p) := by
  intro p; simp only [Equiv.trans_apply, he, hf]

end GMap

/-! ## The octahedral sphere as a free ℤ₂-set -/

/-- The `n`-dimensional octahedral sphere `Sⁿ` as a free `ℤ₂`-set. -/
def Oct (n : ℕ) : FreeZ2 := ⟨SVert n, anti, anti_anti, anti_ne⟩

/-- On octahedral spheres a `GMap` is exactly a `Z2Map` of the base file, so its existence is the
exact criterion `m ≤ n`. -/
lemma nonempty_gmapOct_iff (m n : ℕ) : Nonempty (GMap (Oct m) (Oct n)) ↔ m ≤ n := by
  rw [← nonempty_iff_le]
  exact ⟨fun ⟨F⟩ => ⟨⟨F.toFun, F.equiv, F.simpl⟩⟩, fun ⟨F⟩ => ⟨⟨F.toFun, F.equiv, F.simpl⟩⟩⟩

/-! ## The ℤ₂-coindex -/

/-- The **`ℤ₂`-coindex** of a free `ℤ₂`-set: the largest octahedral sphere admitting an equivariant
simplicial map into it. -/
noncomputable def coind (K : FreeZ2) : ℕ := sSup {m | Nonempty (GMap (Oct m) K)}

/-- **The coindex of `Sⁿ` is exactly `n`.** -/
lemma coind_Oct (n : ℕ) : coind (Oct n) = n := by
  have h : {m | Nonempty (GMap (Oct m) (Oct n))} = Set.Iic n := by
    ext m; simp [nonempty_gmapOct_iff]
  rw [coind, h]; simp

/-- The coindex is invariant under `ℤ₂`-isomorphism (equivariant bijection). -/
lemma coind_congr {K L : FreeZ2} (e : K.V ≃ L.V)
    (he : ∀ p, e (K.anti p) = L.anti (e p)) : coind K = coind L := by
  have h : {m | Nonempty (GMap (Oct m) K)} = {m | Nonempty (GMap (Oct m) L)} := by
    ext m
    exact ⟨fun ⟨F⟩ => ⟨(GMap.ofEquiv e he).comp F⟩,
           fun ⟨F⟩ => ⟨(GMap.ofEquiv e.symm (GMap.symm_equiv e he)).comp F⟩⟩
  rw [coind, coind, h]

/-! ## The join bifunctor -/

/-- The **join** `K ⋆ L` of two free `ℤ₂`-sets: disjoint union of vertices, with the antipodal
action acting on each summand. -/
def join (K L : FreeZ2) : FreeZ2 where
  V := K.V ⊕ L.V
  anti := Sum.map K.anti L.anti
  anti_anti := by rintro (v|v) <;> simp [K.anti_anti, L.anti_anti]
  anti_ne := by
    rintro (v|v) h
    · exact K.anti_ne v (by simpa using h)
    · exact L.anti_ne v (by simpa using h)

@[inherit_doc] scoped infixr:70 " ⋆ " => join

/-- **The join is a bifunctor on `ℤ₂`-maps.** -/
def GMap.joinMap {A B K L : FreeZ2} (F : GMap A K) (G : GMap B L) :
    GMap (A ⋆ B) (K ⋆ L) where
  toFun := Sum.map F.toFun G.toFun
  equiv := by rintro (p|p) <;> simp [join, F.equiv, G.equiv]
  simpl := by
    rintro (p|p) (q|q) h
    · have hh : F.toFun p = K.anti (F.toFun q) := by simpa [join] using h
      simpa [join] using F.simpl p q hh
    · simp [join] at h
    · simp [join] at h
    · have hh : G.toFun p = L.anti (G.toFun q) := by simpa [join] using h
      simpa [join] using G.simpl p q hh

/-- Congruence of joins under `ℤ₂`-isomorphisms of the factors (vertex level). -/
def joinEquivVert {A A' B B' : FreeZ2} (e : A.V ≃ A'.V) (f : B.V ≃ B'.V) :
    (A ⋆ B).V ≃ (A' ⋆ B').V := Equiv.sumCongr e f

lemma joinEquivVert_anti {A A' B B' : FreeZ2} (e : A.V ≃ A'.V) (f : B.V ≃ B'.V)
    (he : ∀ p, e (A.anti p) = A'.anti (e p)) (hf : ∀ p, f (B.anti p) = B'.anti (f p)) :
    ∀ p, joinEquivVert e f ((A ⋆ B).anti p) = (A' ⋆ B').anti (joinEquivVert e f p) := by
  rintro (p|p) <;> simp [joinEquivVert, join, he, hf]

/-! ## The join-monoid isomorphism `Oct m ⋆ Oct n ≅ Oct (m+n+1)` -/

/-- The **octahedral join isomorphism** at vertex level: the coordinate axes of `Oct m` and `Oct n`
are concatenated (with signs preserved) into those of `Oct (m+n+1)`. -/
def octJoinEquiv (m n : ℕ) : (Oct m ⋆ Oct n).V ≃ (Oct (m+n+1)).V :=
  (Equiv.sumProdDistrib (Fin (m+1)) (Fin (n+1)) Bool).symm.trans
    (Equiv.prodCongr (finSumFinEquiv.trans (finCongr (by omega))) (Equiv.refl Bool))

lemma octJoinEquiv_anti (m n : ℕ) (p : (Oct m ⋆ Oct n).V) :
    octJoinEquiv m n ((Oct m ⋆ Oct n).anti p)
      = (Oct (m+n+1)).anti (octJoinEquiv m n p) := by
  rcases p with ⟨i,b⟩ | ⟨j,b⟩ <;>
    simp [octJoinEquiv, Oct, join, anti, Equiv.sumProdDistrib]

/-- **Join-monoid isomorphism**, forward direction `Oct m ⋆ Oct n → Oct (m+n+1)`. -/
def octJoinIso (m n : ℕ) : GMap (Oct m ⋆ Oct n) (Oct (m+n+1)) :=
  GMap.ofEquiv (octJoinEquiv m n) (octJoinEquiv_anti m n)

/-- **Join-monoid isomorphism**, backward direction `Oct (m+n+1) → Oct m ⋆ Oct n`. -/
def octJoinIsoInv (m n : ℕ) : GMap (Oct (m+n+1)) (Oct m ⋆ Oct n) :=
  GMap.ofEquiv (octJoinEquiv m n).symm (GMap.symm_equiv _ (octJoinEquiv_anti m n))

/-! ## The join law -/

/-- **Constructive lower bound (headline).** For arbitrary free `ℤ₂`-sets, coindex witnesses of the
factors combine, via the join bifunctor and the join-monoid isomorphism, into a coindex witness for
the join that is larger by one:  `coind(K ⋆ L) ≥ coind(K) + coind(L) + 1`. -/
theorem coindex_join_lower_bound {K L : FreeZ2} {a b : ℕ}
    (hK : Nonempty (GMap (Oct a) K)) (hL : Nonempty (GMap (Oct b) L)) :
    Nonempty (GMap (Oct (a + b + 1)) (K ⋆ L)) := by
  obtain ⟨F⟩ := hK; obtain ⟨G⟩ := hL
  exact ⟨(F.joinMap G).comp (octJoinIsoInv a b)⟩

/-- **Sharp join law on the octahedral tower.** `coind(Oct m ⋆ Oct n) = m + n + 1`. -/
theorem coind_octJoin (m n : ℕ) : coind (Oct m ⋆ Oct n) = m + n + 1 := by
  rw [coind_congr (octJoinEquiv m n) (octJoinEquiv_anti m n), coind_Oct]

/-- **Exact additivity with a shift** on the octahedral tower:
`coind(Oct m ⋆ Oct n) = coind(Oct m) + coind(Oct n) + 1`. -/
theorem coind_join_eq_add (m n : ℕ) :
    coind (Oct m ⋆ Oct n) = coind (Oct m) + coind (Oct n) + 1 := by
  rw [coind_octJoin, coind_Oct, coind_Oct]

/-- **Suspension jump as the special case `L = S⁰ = Oct 0`.** `coind(Oct m ⋆ Oct 0) = m + 1`. -/
theorem coind_join_S0 (m : ℕ) : coind (Oct m ⋆ Oct 0) = m + 1 := by
  simpa using coind_octJoin m 0

/-! ## The octahedral join-monoid -/

/-- The join-monoid is **commutative** on the level of the coindex. -/
theorem coind_join_comm (m n : ℕ) : coind (Oct m ⋆ Oct n) = coind (Oct n ⋆ Oct m) := by
  rw [coind_octJoin, coind_octJoin]; omega

/-- Left-associated triple join: `coind((Oct m ⋆ Oct n) ⋆ Oct k) = m + n + k + 2`. -/
theorem coind_join_left (m n k : ℕ) :
    coind ((Oct m ⋆ Oct n) ⋆ Oct k) = m + n + k + 2 := by
  have he :=
    joinEquivVert_anti (octJoinEquiv m n) (Equiv.refl (Oct k).V)
      (octJoinEquiv_anti m n) (fun _ => rfl)
  rw [coind_congr
        ((joinEquivVert (octJoinEquiv m n) (Equiv.refl (Oct k).V)).trans (octJoinEquiv (m+n+1) k))
        (GMap.trans_equiv _ _ he (octJoinEquiv_anti (m+n+1) k)),
      coind_Oct]
  omega

/-- Right-associated triple join: `coind(Oct m ⋆ (Oct n ⋆ Oct k)) = m + n + k + 2`. -/
theorem coind_join_right (m n k : ℕ) :
    coind (Oct m ⋆ (Oct n ⋆ Oct k)) = m + n + k + 2 := by
  have he :=
    joinEquivVert_anti (Equiv.refl (Oct m).V) (octJoinEquiv n k)
      (fun _ => rfl) (octJoinEquiv_anti n k)
  rw [coind_congr
        ((joinEquivVert (Equiv.refl (Oct m).V) (octJoinEquiv n k)).trans (octJoinEquiv m (n+k+1)))
        (GMap.trans_equiv _ _ he (octJoinEquiv_anti m (n+k+1))),
      coind_Oct]
  omega

/-- The join-monoid is **associative** on the level of the coindex. -/
theorem coind_join_assoc (m n k : ℕ) :
    coind ((Oct m ⋆ Oct n) ⋆ Oct k) = coind (Oct m ⋆ (Oct n ⋆ Oct k)) := by
  rw [coind_join_left, coind_join_right]

end Z2CoindexJoin