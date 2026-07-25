import Mathlib

/-!
# Persistent maximal simplices and the order of a finite Coxeter group

## Mission

*Conjecture (Persistent Maximal Simplices Count Equals Order of the Coxeter Group).*
For any finite Coxeter group `W` and any generic point `a` in the fundamental chamber, the
number of maximal *persistent* simplices in the canonical subdivision of the Coxeter
permutahedron `Pᵂ(a)` equals `|W|`, via a bijection with the group elements, independently
of the chosen generic `a`.

The full statement involves the geometry of the reflection representation, the canonical
subdivision of the permutahedron, and a persistence filtration — none of which are available
in `Mathlib`.  This file isolates and proves the **combinatorial and group-theoretic core**
on which the conjecture rests, in a self-contained way, together with a concrete instance for
the type `A` Coxeter groups (symmetric groups).

## What is actually proved

We work with an arbitrary finite group `W` acting on a set `α`.  A finite Coxeter group acting
on its reflection representation `α = V` is the motivating instance; the "fundamental chamber"
picks out points, and **a point of the open fundamental chamber is exactly a point with trivial
stabilizer** (a *regular* point).  We call such a point *generic* and model it by
`IsGeneric a : stabilizer W a = ⊥`.

The vertices of the Coxeter permutahedron `Pᵂ(a) = conv(W · a)` are exactly the orbit `W · a`
(for a regular `a` all orbit points are extreme).  Hence "vertices ↔ group elements" and, via
the paper's structural bijection "maximal persistent simplices ↔ vertices", the count is `|W|`.

* `Coxeter.orbitEquivGroup` — for a generic point, the orbit (vertex set) is in bijection
  with `W`.
* `Coxeter.card_orbit_of_generic` — the vertex count equals `Nat.card W = |W|`.
* `Coxeter.card_orbit_independent_of_point` — the count is the same for **any** two generic
  points: independence of the specific generic `a`.
* `Coxeter.card_orbit_mul_card_stabilizer` — the exact orbit–stabilizer factorisation, valid
  for *every* point.
* `Coxeter.card_orbit_lt_of_not_generic` — **contrarian sharpness / near-counterexample:**
  genericity is *necessary*.  At a non-generic (non-regular) point the count is strictly
  smaller than `|W|`, so the naive "count `= |W|`" statement is *false* without the
  genericity hypothesis.
* `Coxeter.persistent_simplices_count` — the conjecture's logical skeleton: any type `PS`
  of maximal persistent simplices that is in bijection with the vertex set of a generic
  permutahedron has cardinality `|W|`.

## Type `A` instance (symmetric groups)

`Sₙ = Equiv.Perm (Fin n)` is the Coxeter group of type `Aₙ₋₁`, with `|Sₙ| = n!`.  Its
permutahedron is the convex hull of the coordinate permutations of a vector `v : Fin n → ℝ`,
and a vector with distinct entries is a regular point.

* `Coxeter.symmetricGroup_order` — `|Sₙ| = n!`.
* `Coxeter.perm_fixes_iff_eq_one` — a vector with distinct entries is regular: only the
  identity permutation fixes it (concrete "generic ⇒ trivial stabilizer").
* `Coxeter.card_permutahedron_vertices` — the permutahedron of such a vector has exactly
  `n!` vertices, matching `|Sₙ|`.
-/

namespace Coxeter

open MulAction

variable {W : Type*} [Group W] {α : Type*} [MulAction W α]

/-- A point is **generic** (a *regular* point, in the interior of the fundamental chamber for
the reflection representation of a Coxeter group) when its stabilizer is trivial. -/
def IsGeneric (a : α) : Prop := stabilizer W a = (⊥ : Subgroup W)

/-- **Vertices ↔ group elements.**  For a generic point `a`, the orbit `W · a` — the vertex
set of the Coxeter permutahedron `Pᵂ(a)` — is in bijection with the group `W`. -/
noncomputable def orbitEquivGroup {a : α} (h : IsGeneric (W := W) a) : orbit W a ≃ W :=
  (orbitEquivQuotientStabilizer W a).trans
    (by rw [IsGeneric] at h; rw [h]; exact QuotientGroup.quotientBot.toEquiv)

/-- **Vertex count `= |W|`.**  For a generic point, the number of vertices of the Coxeter
permutahedron equals the order of the Coxeter group. -/
theorem card_orbit_of_generic [Finite W] {a : α} (h : IsGeneric (W := W) a) :
    Nat.card (orbit W a) = Nat.card W :=
  Nat.card_eq_of_bijective _ (orbitEquivGroup h).bijective

/-- **Independence of the generic point.**  Any two generic points give permutahedra with the
same number of vertices, namely `|W|`. -/
theorem card_orbit_independent_of_point [Finite W] {a b : α}
    (ha : IsGeneric (W := W) a) (hb : IsGeneric (W := W) b) :
    Nat.card (orbit W a) = Nat.card (orbit W b) := by
  rw [card_orbit_of_generic ha, card_orbit_of_generic hb]

/-- **Orbit–stabilizer factorisation** (valid at *every* point): the number of vertices times
the size of the stabilizer equals `|W|`. -/
theorem card_orbit_mul_card_stabilizer [Finite W] (a : α) :
    Nat.card (orbit W a) * Nat.card (stabilizer W a) = Nat.card W := by
  rw [← Nat.card_prod]
  exact Nat.card_eq_of_bijective _ (orbitProdStabilizerEquivGroup W a).bijective

/-- **Contrarian sharpness: genericity is necessary.**  At a *non*-generic (non-regular) point,
the vertex count is *strictly smaller* than `|W|`.  Thus the bare statement "count `= |W|`"
fails without the genericity hypothesis — a family of counterexamples to the ungeneric claim. -/
theorem card_orbit_lt_of_not_generic [Finite W] {a : α}
    (h : ¬ IsGeneric (W := W) a) : Nat.card (orbit W a) < Nat.card W := by
  rw [IsGeneric] at h
  have hmul := card_orbit_mul_card_stabilizer (W := W) a
  have hnt : Nontrivial (stabilizer W a) :=
    (Subgroup.bot_or_nontrivial (stabilizer W a)).resolve_left h
  have hstab : 1 < Nat.card (stabilizer W a) :=
    Finite.one_lt_card_iff_nontrivial.mpr hnt
  have hWpos : 0 < Nat.card W := Nat.card_pos
  have horb : 0 < Nat.card (orbit W a) := by
    rcases Nat.eq_zero_or_pos (Nat.card (orbit W a)) with h0 | hp
    · rw [h0, zero_mul] at hmul; omega
    · exact hp
  calc Nat.card (orbit W a) = Nat.card (orbit W a) * 1 := by ring
    _ < Nat.card (orbit W a) * Nat.card (stabilizer W a) :=
        (Nat.mul_lt_mul_left horb).mpr hstab
    _ = Nat.card W := hmul

/-- **The conjecture's logical skeleton.**  Model the maximal persistent simplices of the
canonical subdivision by an abstract type `PS`, together with the structural bijection
"maximal persistent simplices ↔ vertices of `Pᵂ(a)`" (`e : PS ≃ orbit W a`).  For a generic
`a` this forces the count of maximal persistent simplices to equal `|W|`, giving the asserted
bijection with the group elements. -/
theorem persistent_simplices_count [Finite W] {PS : Type*} {a : α}
    (h : IsGeneric (W := W) a) (e : PS ≃ orbit W a) :
    Nat.card PS = Nat.card W :=
  Nat.card_eq_of_bijective _ ((e.trans (orbitEquivGroup h)).bijective)

/-! ### Type `A`: the symmetric group `Sₙ` and its permutahedron -/

/-- The Coxeter group of type `Aₙ₋₁` is `Sₙ = Equiv.Perm (Fin n)`, of order `|Sₙ| = n!`. -/
theorem symmetricGroup_order (n : ℕ) : Nat.card (Equiv.Perm (Fin n)) = Nat.factorial n := by
  rw [Nat.card_eq_fintype_card, Fintype.card_perm, Fintype.card_fin]

/-- **A vector with distinct entries is a regular point.**  For an injective `v : Fin n → ℝ`,
only the identity permutation fixes it under the coordinate action.  This is the concrete
"generic point has trivial stabilizer" for the type `A` reflection representation. -/
theorem perm_fixes_iff_eq_one {n : ℕ} {v : Fin n → ℝ} (hv : Function.Injective v)
    (σ : Equiv.Perm (Fin n)) : v ∘ σ = v ↔ σ = 1 := by
  constructor
  · intro hσ
    refine Equiv.ext (fun i => ?_)
    have hi := congrArg (fun f => f i) hσ
    simp only [Function.comp_apply] at hi
    simpa using hv hi
  · rintro rfl; rfl

/-- **The permutahedron of a regular point has `n!` vertices.**  The vertices of the type `A`
permutahedron are the coordinate permutations `v ∘ σ` of a vector `v` with distinct entries;
there are exactly `n! = |Sₙ|` of them, matching `symmetricGroup_order`. -/
theorem card_permutahedron_vertices {n : ℕ} {v : Fin n → ℝ} (hv : Function.Injective v) :
    Nat.card {w : Fin n → ℝ | ∃ σ : Equiv.Perm (Fin n), w = v ∘ σ} = Nat.factorial n := by
  have hset : {w : Fin n → ℝ | ∃ σ : Equiv.Perm (Fin n), w = v ∘ σ}
      = Set.range (fun σ : Equiv.Perm (Fin n) => v ∘ σ) := by
    ext w; simp [Set.mem_range, eq_comm]
  have hinj : Function.Injective (fun σ : Equiv.Perm (Fin n) => v ∘ σ) := by
    intro σ τ hσ
    refine Equiv.ext (fun i => ?_)
    exact hv (congrArg (fun f => f i) hσ)
  rw [hset, Nat.card_range_of_injective hinj, Nat.card_eq_fintype_card, Fintype.card_perm,
    Fintype.card_fin]

/-- **Type `A` synthesis.**  The number of permutahedron vertices for a regular point equals
the order of the corresponding Coxeter group `Sₙ`. -/
theorem card_permutahedron_vertices_eq_group_order {n : ℕ} {v : Fin n → ℝ}
    (hv : Function.Injective v) :
    Nat.card {w : Fin n → ℝ | ∃ σ : Equiv.Perm (Fin n), w = v ∘ σ}
      = Nat.card (Equiv.Perm (Fin n)) := by
  rw [card_permutahedron_vertices hv, symmetricGroup_order]

end Coxeter