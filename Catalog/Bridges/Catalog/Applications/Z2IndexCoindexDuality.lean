/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib
import Novelty.Z2CoindexSuspensionTower

/-!
# Functoriality, the ℤ₂-index, and the exact enumeration of ℤ₂-maps of combinatorial spheres

This file deepens the exact-coindex development of the cross-polytope model.  A companion file
established the *existence* dichotomy `Nonempty (Z2Map m n) ↔ m ≤ n`, the exact coindex
`coind(Sⁿ) = n`, and a sharp suspension tower.  Here we go from *existence* to *structure* and
*quantity*:

1. **Functoriality.** `ℤ₂`-maps compose (`Z2Map.comp`); this realises transitivity of the existence
   relation constructively and makes the combinatorial spheres a thin category under `m ≤ n`.

2. **The ℤ₂-index equals the coindex.** Dual to the coindex — the largest sphere mapping *into* `Sⁿ`
   — the *index* is the smallest sphere `Sⁿ` maps *out of*: `ind(Sᵐ) := inf {n | Sᵐ → Sⁿ}`.  We show
   `ind(Sᵐ) = m` and hence `coind(Sⁿ) = ind(Sⁿ)`: for cross-polytope spheres the index/coindex gap
   vanishes.

3. **Exact enumeration.** A `ℤ₂`-map is exactly an injection of coordinate axes together with an
   independent choice of sign on each axis.  This is packaged as an equivalence
   `Z2Map m n ≃ (Fin (m+1) ↪ Fin (n+1)) × (Fin (m+1) → Bool)`, whence the exact count
   `#(Z2Map m n) = (n+1)^{\underline{m+1}} · 2^{m+1}`, where `(n+1)^{\underline{m+1}}` is the falling
   factorial.  In particular the count is positive iff `m ≤ n`, recovering Borsuk–Ulam
   quantitatively.

## Main results

* `Z2Map.comp`, `nonempty_comp` — composition / functoriality.
* `ind`, `ind_eq`, `coind_eq_ind` — the ℤ₂-index and its coincidence with the coindex.
* `equivEmbeddingSign` — `Z2Map m n ≃ (Fin (m+1) ↪ Fin (n+1)) × (Fin (m+1) → Bool)`.
* `card_Z2Map` — `#(Z2Map m n) = (n+1).descFactorial (m+1) * 2^(m+1)`.
* `card_Z2Map_pos_iff`, `card_Z2Map_eq_zero_iff` — the count detects the Borsuk–Ulam threshold.
-/

namespace Z2SuspensionTower

open Function

/-! ## Functoriality: ℤ₂-maps compose -/

/-- **Composition of `ℤ₂`-maps.** If `Sᵐ → Sⁿ` and `Sⁿ → Sᵖ` are `ℤ₂`-maps, so is their composite
`Sᵐ → Sᵖ`.  Equivariance is immediate; simpliciality follows by peeling off the two simpliciality
witnesses in turn. -/
def Z2Map.comp {m n p : ℕ} (G : Z2Map n p) (F : Z2Map m n) : Z2Map m p where
  toFun := G.toFun ∘ F.toFun
  equiv := by
    intro x
    simp only [Function.comp_apply, F.equiv, G.equiv]
  simpl := by
    intro x y h
    exact F.simpl x y (G.simpl _ _ h)

@[simp] lemma Z2Map.comp_toFun {m n p : ℕ} (G : Z2Map n p) (F : Z2Map m n) :
    (G.comp F).toFun = G.toFun ∘ F.toFun := rfl

/-- The underlying vertex map determines a `ℤ₂`-map (the equivariance and simpliciality data are
propositional). -/
lemma Z2Map.toFun_injective {m n : ℕ} : Function.Injective (Z2Map.toFun (m := m) (n := n)) := by
  intro F G h
  cases F; cases G; cases h; rfl

/-- **Composition realises transitivity of existence.** -/
theorem nonempty_comp {m n p : ℕ} (h1 : Nonempty (Z2Map n p)) (h2 : Nonempty (Z2Map m n)) :
    Nonempty (Z2Map m p) :=
  h1.elim fun G => h2.elim fun F => ⟨G.comp F⟩

/-! ## The ℤ₂-index and its coincidence with the coindex -/

/-- The `ℤ₂`-**index** of the combinatorial sphere `Sᵐ`: the least target dimension `n` admitting a
`ℤ₂`-map `Sᵐ → Sⁿ`.  (Dual to `coind`, which is the greatest *source* dimension.) -/
noncomputable def ind (m : ℕ) : ℕ := sInf {n | Nonempty (Z2Map m n)}

/-- The admissible target dimensions of `Sᵐ` are exactly `{m, m+1, …}`. -/
theorem admissible_targets (m : ℕ) : {n | Nonempty (Z2Map m n)} = Set.Ici m := by
  ext n; simp [nonempty_iff_le]

/-- **The index of `Sᵐ` is exactly `m`.** -/
theorem ind_eq (m : ℕ) : ind m = m := by
  rw [ind, admissible_targets]
  simp

/-- **Index equals coindex for cross-polytope spheres.** The index/coindex gap vanishes:
`ind(Sⁿ) = coind(Sⁿ) = n`. -/
theorem coind_eq_ind (n : ℕ) : coind n = ind n := by
  rw [coind_eq, ind_eq]

/-! ## Positive-vertex data and the enumeration equivalence -/

/-- The positive-vertex data of a `ℤ₂`-map: the images of the vertices `(i, true)`. -/
def posData {m n : ℕ} (F : Z2Map m n) : Fin (m + 1) → SVert n := fun i => F.toFun (i, true)

/-- A `ℤ₂`-map is reconstructed from its positive-vertex data. -/
lemma induced_posData {m n : ℕ} (F : Z2Map m n) : induced (posData F) = F.toFun := by
  funext p
  obtain ⟨i, b⟩ := p
  cases b with
  | true => rfl
  | false => exact (F.equiv (i, true)).symm

/-- The coordinate map of the positive-vertex data of a `ℤ₂`-map is injective. -/
lemma coordMap_posData_injective {m n : ℕ} (F : Z2Map m n) :
    Injective (coordMap (posData F)) := by
  apply (induced_simplicial_iff_injective _).1
  rw [induced_posData]
  exact F.simpl

/-- **The enumeration equivalence.** A `ℤ₂`-map `Sᵐ → Sⁿ` is exactly an injection of coordinate axes
`Fin (m+1) ↪ Fin (n+1)` together with an independent sign `Fin (m+1) → Bool` on each source axis. -/
def equivEmbeddingSign (m n : ℕ) :
    Z2Map m n ≃ (Fin (m + 1) ↪ Fin (n + 1)) × (Fin (m + 1) → Bool) where
  toFun F := (⟨coordMap (posData F), coordMap_posData_injective F⟩, fun i => (posData F i).2)
  invFun p :=
    { toFun := induced (fun i => (p.1 i, p.2 i))
      equiv := induced_equiv _
      simpl := (induced_simplicial_iff_injective _).2 (by
        intro i j h
        exact p.1.injective h) }
  left_inv F := by
    apply Z2Map.toFun_injective
    show induced (fun i => ((coordMap (posData F) i), (posData F i).2)) = F.toFun
    have hg : (fun i => ((coordMap (posData F) i), (posData F i).2)) = posData F := by
      funext i; simp [coordMap]
    rw [hg, induced_posData]
  right_inv p := by
    ext i
    · simp [coordMap, posData, induced]
    · simp [posData, induced]

/-- `Z2Map m n` is a finite type. -/
noncomputable instance instFintypeZ2Map (m n : ℕ) : Fintype (Z2Map m n) :=
  Fintype.ofEquiv _ (equivEmbeddingSign m n).symm

/-! ## Exact enumeration of ℤ₂-maps -/

/-- **The exact number of `ℤ₂`-maps `Sᵐ → Sⁿ`.** It equals the number of ways to inject the `m+1`
source axes into the `n+1` target axes — the falling factorial `(n+1)^{\underline{m+1}}` — times
`2^{m+1}` independent sign choices. -/
theorem card_Z2Map (m n : ℕ) :
    Fintype.card (Z2Map m n) = (n + 1).descFactorial (m + 1) * 2 ^ (m + 1) := by
  rw [Fintype.card_congr (equivEmbeddingSign m n), Fintype.card_prod, Fintype.card_embedding_eq]
  simp [Fintype.card_fin]

/-- **The count detects the Borsuk–Ulam threshold.** There is at least one `ℤ₂`-map `Sᵐ → Sⁿ` iff
`m ≤ n`. -/
theorem card_Z2Map_pos_iff (m n : ℕ) : 0 < Fintype.card (Z2Map m n) ↔ m ≤ n := by
  rw [Fintype.card_pos_iff]
  exact ⟨fun h => (nonempty_iff_le m n).1 h, fun h => (nonempty_iff_le m n).2 h⟩

/-- **Quantitative Borsuk–Ulam.** There are *no* `ℤ₂`-maps `Sᵐ → Sⁿ` exactly when `n < m`; in
particular the count vanishes for the critical case `Sⁿ⁺¹ → Sⁿ`. -/
theorem card_Z2Map_eq_zero_iff (m n : ℕ) : Fintype.card (Z2Map m n) = 0 ↔ n < m := by
  rw [Fintype.card_eq_zero_iff, ← not_nonempty_iff, nonempty_iff_le]
  omega

/-- The number of antipodal simplicial self-maps of `Sⁿ` is `(n+1)! · 2^{n+1}`: the signed
permutations of coordinate axes (the hyperoctahedral group `B_{n+1}`). -/
theorem card_Z2Map_self (n : ℕ) :
    Fintype.card (Z2Map n n) = (n + 1).factorial * 2 ^ (n + 1) := by
  rw [card_Z2Map, Nat.descFactorial_self]

/-!
-- !-- Lab Notes -- !--

**Hypothesis.** In the rigid cross-polytope model the existence dichotomy
`Nonempty (Z2Map m n) ↔ m ≤ n` should upgrade from a mere yes/no statement to a full structural and
enumerative description: `ℤ₂`-maps should compose (making spheres a thin category), the dual *index*
invariant should coincide with the coindex, and the set of maps should be finite with an explicit
count.

**Experiment.** We proved composition `Z2Map.comp` directly from the two simpliciality witnesses,
defined `ind` dually to `coind`, and searched for the right combinatorial normal form of a map. The
decisive step was recognising a `ℤ₂`-map as *positive-vertex data* `g` whose coordinate part is
forced to be injective (`coordMap_posData_injective`), with the sign part entirely free. This yields
the equivalence `equivEmbeddingSign : Z2Map m n ≃ (Fin (m+1) ↪ Fin (n+1)) × (Fin (m+1) → Bool)`.

**Analysis.** The equivalence collapses the topology to two independent combinatorial choices: an
injection of axes and a sign vector. Counting them gives `#(Z2Map m n) = (n+1)^{\underline{m+1}} ·
2^{m+1}`. Small cases: the table of counts is `[[2,4,6,8,10],[0,8,24,48,80],[0,0,48,192,480],…]`;
the diagonal `2,8,48,384` is the order `2^{n+1}(n+1)!` of the hyperoctahedral group `B_{n+1}` — the
symmetry group of the cross-polytope, as it must be. The count is positive iff `m ≤ n`, so the
enumeration re-proves Borsuk–Ulam quantitatively.

**Critique.** None of the main results are vacuous: `card_Z2Map` produces a nontrivial closed form
verified against independent small-case computation; `coind_eq_ind` genuinely combines two dual
infima/suprema; the enumeration equivalence is a real bijection, not a renaming. The vanishing of
the index/coindex gap is *special to spheres* — the general case needs Tucker's lemma and is left
open. The proofs use only lemmas appearing earlier in this file or the imported development; no
theorem refers to itself.

**Synthesis.** The coindex, the index, and the raw cardinality of the map-space are three facets of
the single invariant `m ≤ n`. Suspension shifts all three in lockstep, and the map-count's diagonal
recovers the hyperoctahedral group. Future work: enumerate `ℤ₂`-maps for non-octahedral free
complexes, where the index and coindex genuinely diverge.
-/

end Z2SuspensionTower