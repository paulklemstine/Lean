/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib
import Catalog.Novelty.Z2CoindexSuspension

/-!
# Deepening: suspension is a functor and the sharp excess of the ℤ₂-coindex

This file deepens the constructive lower-bound theory of the `ℤ₂`-coindex of combinatorial
spheres developed in `Catalog.Novelty.Z2CoindexSuspension`.  There the *suspension of a
`ℤ₂`-map* was introduced as a construction on objects; here we prove that it assembles into a
genuine **endofunctor** of the category of free `ℤ₂`-complexes (combinatorial spheres and
equivariant simplicial maps), and we iterate it to obtain the full constructive tower.

## Main results

* `Z2Map.ext` — extensionality: a `ℤ₂`-map is determined by its underlying vertex map.
* `Z2Map.susp_id` — suspension preserves identities: `Σ(id_Sⁿ) = id_{Sⁿ⁺¹}`.
* `Z2Map.susp_comp` — suspension preserves composition: `Σ(G ∘ F) = ΣG ∘ ΣF`.
  Together with `susp_id` this states that `Σ` is a **functor**.
* `Z2Map.suspIter` — the `k`-fold suspension `Σᵏ : Z2Map m n → Z2Map (m+k) (n+k)`, with its
  own functor laws `suspIter_id`, `suspIter_comp`, and the recursion laws `suspIter_zero`,
  `suspIter_succ`.
* `suspension_raises_coindex_iter` — iterating suspension raises the constructive coindex
  bound by `k`: `coind witness for Sⁿ ⟹ coind witness for Sⁿ⁺ᵏ`.
* `iterated_suspension_of_point` — the entire constructive lower-bound tower
  `coind(Sⁿ) ≥ n` is obtained by `n`-fold suspension of the single map `S⁰ → S⁰`, exhibiting
  `Sⁿ` as the `n`-fold suspension of `S⁰` at the level of coindex witnesses.
* `borsuk_ulam_S3_S2` — a new finite Borsuk–Ulam instance `IsEmpty (Z2Map 3 2)`, pushing the
  verified sharpness of `coind(Sⁿ) = n` one dimension higher, to `coind(S²) = 2`.
* `sharp_excess_tower_S2` — the sharp-excess statement for the base tower up to `S²`: at each
  of the first three levels a coindex witness of the exact expected dimension exists, and the
  next one does not, so each suspension raises the coindex by **exactly one**.

The unifying structural insight is that the suspension increment of the coindex is realised
*functorially*: the lower bound is not merely an existence statement but a functor `Σ` from
the tower to itself, and the sharpness certificates pin the excess of that functor to exactly
one at every verified level.
-/

namespace Z2CoindexSuspension

namespace Z2Map

/-! ## Extensionality -/

/-- **Extensionality for `ℤ₂`-maps.**  Since equivariance and simpliciality are propositions,
a `ℤ₂`-map is completely determined by its underlying vertex map. -/
@[ext] theorem ext {m n : ℕ} {F G : Z2Map m n} (h : F.toFun = G.toFun) : F = G := by
  cases F; cases G; cases h; rfl

/-! ## Suspension is a functor -/

/-- **Suspension preserves the identity.**  The suspension of the identity `ℤ₂`-map on `Sⁿ`
is the identity `ℤ₂`-map on `Sⁿ⁺¹`. -/
theorem susp_id (n : ℕ) : (Z2Map.id n).susp = Z2Map.id (n + 1) := by
  refine Z2Map.ext (funext fun p => ?_)
  obtain ⟨i, b⟩ := p
  refine Fin.lastCases ?_ ?_ i
  · change (Z2Map.id n).suspFun (Fin.last (n + 1), b) = _
    rw [suspFun_last]; rfl
  · intro j
    change (Z2Map.id n).suspFun (j.castSucc, b) = _
    rw [suspFun_castSucc]; rfl

/-- **Suspension preserves composition.**  The suspension of a composite `ℤ₂`-map is the
composite of the suspensions: `Σ(G ∘ F) = ΣG ∘ ΣF`.  Together with `susp_id` this exhibits
`Σ` as an endofunctor of the category of free `ℤ₂`-spheres. -/
theorem susp_comp {m n k : ℕ} (G : Z2Map n k) (F : Z2Map m n) :
    (G.comp F).susp = G.susp.comp F.susp := by
  refine Z2Map.ext (funext fun p => ?_)
  obtain ⟨i, b⟩ := p
  refine Fin.lastCases ?_ ?_ i
  · change (G.comp F).suspFun (Fin.last (m + 1), b) = G.suspFun (F.suspFun (Fin.last (m + 1), b))
    rw [suspFun_last, suspFun_last, suspFun_last]
  · intro j
    change (G.comp F).suspFun (j.castSucc, b) = G.suspFun (F.suspFun (j.castSucc, b))
    rw [suspFun_castSucc, suspFun_castSucc]
    show suspV ((G.comp F).toFun (j, b)) = G.suspFun (suspV (F.toFun (j, b)))
    rw [show suspV (F.toFun (j, b)) = ((F.toFun (j, b)).1.castSucc, (F.toFun (j, b)).2) from rfl,
        suspFun_castSucc]
    rfl

/-! ## Iterated suspension -/

/-- The `k`-fold suspension of a `ℤ₂`-map: `Σᵏ : Sᵐ → Sⁿ  ⟹  Sᵐ⁺ᵏ → Sⁿ⁺ᵏ`. -/
def suspIter {m n : ℕ} : (k : ℕ) → Z2Map m n → Z2Map (m + k) (n + k)
  | 0, F => F
  | k + 1, F => (suspIter k F).susp

@[simp] theorem suspIter_zero {m n : ℕ} (F : Z2Map m n) : F.suspIter 0 = F := rfl

@[simp] theorem suspIter_succ {m n : ℕ} (k : ℕ) (F : Z2Map m n) :
    F.suspIter (k + 1) = (F.suspIter k).susp := rfl

/-- **Iterated suspension preserves identities.**  `Σᵏ(id_Sⁿ) = id_{Sⁿ⁺ᵏ}`. -/
theorem suspIter_id (n k : ℕ) : (Z2Map.id n).suspIter k = Z2Map.id (n + k) := by
  induction k with
  | zero => rfl
  | succ k ih => rw [suspIter_succ, ih, susp_id]; rfl

/-- **Iterated suspension preserves composition.**  `Σᵏ(G ∘ F) = ΣᵏG ∘ ΣᵏF`. -/
theorem suspIter_comp {m n k : ℕ} (j : ℕ) (G : Z2Map n k) (F : Z2Map m n) :
    (G.comp F).suspIter j = (G.suspIter j).comp (F.suspIter j) := by
  induction j with
  | zero => rfl
  | succ j ih => rw [suspIter_succ, ih, suspIter_succ, suspIter_succ, susp_comp]

/-! ## The constructive tower, functorially -/

/-- **Iterating suspension raises the coindex bound by `k`.**  Any coindex witness for `Sⁿ`
suspends `k` times to a coindex witness, larger by `k`, for `Sⁿ⁺ᵏ`. -/
theorem suspension_raises_coindex_iter {m n : ℕ} (k : ℕ) (h : Nonempty (Z2Map m n)) :
    Nonempty (Z2Map (m + k) (n + k)) :=
  h.elim fun F => ⟨F.suspIter k⟩

/-- **The whole constructive tower is a tower of suspensions of a point.**  The `n`-fold
suspension of the identity map of `S⁰` is a `ℤ₂`-map `Sⁿ → Sⁿ`; concretely it equals the
identity of `Sⁿ`.  Thus the diagonal coindex witnesses `coind(Sⁿ) ≥ n` are produced,
uniformly, by iterating the suspension functor on the single base map of `S⁰`. -/
theorem iterated_suspension_of_point (n : ℕ) :
    (Z2Map.id 0).suspIter n = Z2Map.id (0 + n) := suspIter_id 0 n

end Z2Map

/-! ## Sharpness one dimension higher: a new finite Borsuk–Ulam instance -/

/-- **Borsuk–Ulam, instance `S³ → S²`.**  There is no `ℤ₂`-map `S³ → S²`; equivalently
`coind(S²) < 3`.  Combined with the constructive lower bound `coind(S²) ≥ 2`, this pins
`coind(S²) = 2`, extending the verified sharpness of `coind(Sⁿ) = n` to dimension two. -/
theorem borsuk_ulam_S3_S2 : IsEmpty (Z2Map 3 2) := by
  set_option maxRecDepth 4000 in
  rw [← not_nonempty_iff, nonempty_iff_exists_pos]
  native_decide

/-- **Sharp excess of the coindex under suspension, base tower up to `S²`.**  At levels
`0, 1, 2` a coindex witness of the exact expected dimension exists, while the next dimension
up admits none.  Hence each suspension `S⁰ ⤳ S¹ ⤳ S²` raises the coindex by *exactly one*:
the excess of the suspension functor is sharp along the whole verified base of the tower. -/
theorem sharp_excess_tower_S2 :
    (Nonempty (Z2Map 0 0) ∧ IsEmpty (Z2Map 1 0)) ∧
    (Nonempty (Z2Map 1 1) ∧ IsEmpty (Z2Map 2 1)) ∧
    (Nonempty (Z2Map 2 2) ∧ IsEmpty (Z2Map 3 2)) :=
  ⟨⟨coindex_self 0, borsuk_ulam_S1_S0⟩,
    ⟨coindex_self 1, borsuk_ulam_S2_S1⟩,
    ⟨coindex_self 2, borsuk_ulam_S3_S2⟩⟩

/-!
-- !-- Lab Notes -- !--

**Hypothesis (Hypothesizer).**  The constructive suspension of a `ℤ₂`-map should not be an
isolated construction but the object part of a *functor* on the category of free `ℤ₂`-spheres;
if so, the constructive lower bound `coind(Sⁿ) ≥ n` is a purely functorial phenomenon — the
`n`-fold image of a single base map — and its sharpness can be certified level by level by
finite Borsuk–Ulam obstructions.

**Experiment (Experimenter).**  We proved extensionality of `Z2Map` (equivariance and
simpliciality are propositions, so the vertex map determines the morphism) and used it to
verify the two functor laws `susp_id` and `susp_comp` by a `Fin.lastCases` split on the
suspension coordinate.  Iterating gives `suspIter` with matching functor laws, and the tower
`coind(Sⁿ) ≥ n` reappears as `Σⁿ(id_{S⁰})`.  On the sharpness side we pushed the finite
Borsuk–Ulam check from `S² → S¹` up to `S³ → S²` over the decidable positive-vertex
reformulation.

**Analysis (Analyst).**  Everything that survived did so *structurally*: the functor laws
reduce, after extensionality, to the two cases of `Fin.lastCases` (poles fixed, equator
transported), exactly mirroring the geometric picture of suspension.  The `S³ → S²`
obstruction is "true but finite": the search space of positive-vertex data is large enough
that structural recursion overflows, but the finite reformulation is decidable and the
obstruction holds.  The matching *upper* bound in *every* dimension is the full Borsuk–Ulam
theorem and remains out of reach of a finite check.

**Critique (Critic).**  No result here is vacuous: `susp_id`/`susp_comp` are genuine equalities
of morphisms proved by case analysis, `suspIter_id`/`suspIter_comp` by induction, and the
existence/emptiness certificates combine constructive maps with finite obstructions of
*opposite* polarity, so `sharp_excess_tower_S2` cannot hold trivially.  The finite instances
rely only on the decidable reformulation from the base file.

**Synthesis (Principal Investigator).**  Suspension of free `ℤ₂`-spheres is an endofunctor;
the constructive coindex lower bound is its orbit on the base point; and the excess of the
coindex under suspension is exactly one throughout the verified base of the tower.
-/

end Z2CoindexSuspension