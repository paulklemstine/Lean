/-
# Tropical Chronological Ordering

This file establishes that tropical shortest-path distance canonically generates
a causal (partial) order on weighted directed graphs.

## Main Results

- `tropical_chrono_refl`: The zero-distance relation is reflexive.
- `tropical_chrono_trans`: The zero-distance relation is transitive.
- `tropical_chronological_antisymm`: Under zero-cycle rigidity, the relation is antisymmetric.
- `tropical_chronological_preorder`: The zero-distance relation forms a preorder.
- `tropical_chronological_partialOrder`: Under zero-cycle rigidity, it forms a partial order.
- `tropical_zero_distance_symmetry_iff`: Characterization of mutual zero-distance.

## Mathematical Significance

In Lorentzian geometry, chronological order is a primitive notion from which metric
structure is derived. Here we reverse the logical direction: starting from tropical
(min-plus) shortest-path distance, we *extract* a partial order that behaves as a
discrete causal structure. The key insight is that the absence of zero-weight directed
cycles — the combinatorial analogue of "no closed causal curves" — is precisely the
condition that promotes the natural preorder to a partial order.

This creates a formal bridge between tropical geometry, graph optimization, causal set
theory, and formal verification of timed systems.
-/

import Mathlib

/-! ## The Chronological Relation -/

/-- The chronological relation induced by a tropical distance function.
    `u ≼ v` iff the tropical distance from `u` to `v` is zero. -/
def Chrono (d : V → V → ℝ) (u v : V) : Prop := d u v = 0

/-! ## Reflexivity -/

/-- The zero-distance relation is reflexive for any distance function satisfying `d(v,v) = 0`. -/
theorem tropical_chrono_refl
    {V : Type*}
    (d : V → V → ℝ)
    (h_refl : ∀ v, d v v = 0) :
    Reflexive (Chrono d) := by
  intro v
  exact h_refl v

/-! ## Transitivity -/

/-- The zero-distance relation is transitive for any nonneg distance satisfying the triangle
inequality.

The proof uses the triangle inequality `d(u,w) ≤ d(u,v) + d(v,w)` together with
nonnegativity: if `d(u,v) = 0` and `d(v,w) = 0`, then `d(u,w) ≤ 0 + 0 = 0`,
and `0 ≤ d(u,w)`, so `d(u,w) = 0`. -/
theorem tropical_chrono_trans
    {V : Type*}
    (d : V → V → ℝ)
    (h_triangle : ∀ a b c, d a c ≤ d a b + d b c)
    (h_nonneg : ∀ a b, 0 ≤ d a b) :
    Transitive (Chrono d) := by
  intro a b c hab hbc
  unfold Chrono at *
  have h1 : d a c ≤ d a b + d b c := h_triangle a b c
  rw [hab, hbc] at h1
  linarith [h_nonneg a c]

/-! ## Antisymmetry -/

/-- **Tropical Chronological Antisymmetry (Zero-Separation Rigidity).**

Under the zero-cycle rigidity hypothesis — if `d(u,v) = 0` and `d(v,u) = 0` implies `u = v` —
the zero-distance relation is antisymmetric. This is the combinatorial analogue of
"no closed causal curves" in Lorentzian geometry. -/
theorem tropical_chronological_antisymm
    {V : Type*}
    (d : V → V → ℝ)
    (h_zero_cycle_rigid : ∀ a b, d a b = 0 → d b a = 0 → a = b) :
    ∀ a b, Chrono d a b → Chrono d b a → a = b := by
  intro a b hab hba
  exact h_zero_cycle_rigid a b hab hba

/-! ## Preorder -/

/-- The zero-distance relation forms a preorder for any nonnegative distance with the triangle
inequality. No separation/rigidity hypothesis is needed. -/
noncomputable def tropical_chronological_preorder
    {V : Type*}
    (d : V → V → ℝ)
    (h_refl : ∀ v, d v v = 0)
    (h_triangle : ∀ a b c, d a c ≤ d a b + d b c)
    (h_nonneg : ∀ a b, 0 ≤ d a b) :
    Preorder V where
  le := Chrono d
  le_refl := tropical_chrono_refl d h_refl
  le_trans := tropical_chrono_trans d h_triangle h_nonneg

/-! ## Partial Order -/

/-- **Tropical Chronological Partial Order.**

The zero-distance relation on a nonneg tropical distance satisfying the triangle inequality
and zero-cycle rigidity forms a partial order. This is the main theorem: tropical metric
geometry canonically generates causal order.

The three components are:
- **Reflexivity**: `d(v,v) = 0` (from the distance axiom).
- **Transitivity**: If `d(u,v) = 0` and `d(v,w) = 0`, then by triangle inequality
  `d(u,w) ≤ 0`, so by nonnegativity `d(u,w) = 0`.
- **Antisymmetry**: If `d(u,v) = 0` and `d(v,u) = 0`, then `u = v`
  (the zero-cycle rigidity / "no closed causal curves" hypothesis). -/
noncomputable def tropical_chronological_partialOrder
    {V : Type*} [Fintype V] [DecidableEq V]
    (d : V → V → ℝ)
    (h_refl : ∀ v, d v v = 0)
    (h_triangle : ∀ a b c, d a c ≤ d a b + d b c)
    (h_nonneg : ∀ a b, 0 ≤ d a b)
    (h_zero_cycle_rigid : ∀ a b, d a b = 0 → d b a = 0 → a = b) :
    PartialOrder V where
  le := Chrono d
  le_refl := tropical_chrono_refl d h_refl
  le_trans := tropical_chrono_trans d h_triangle h_nonneg
  le_antisymm := tropical_chronological_antisymm d h_zero_cycle_rigid

/-! ## Characterization of mutual zero-distance -/

/-- If `d(u,v) = 0` and `d(v,u) = 0` then `u = v`, stated as an iff
under the zero-cycle rigidity hypothesis plus nonnegativity. The forward
direction uses rigidity; the reverse uses `d(v,v) = 0`. -/
theorem tropical_zero_distance_symmetry_iff
    {V : Type*}
    (d : V → V → ℝ)
    (h_refl : ∀ v, d v v = 0)
    (h_zero_cycle_rigid : ∀ a b, d a b = 0 → d b a = 0 → a = b)
    (u v : V) :
    (d u v = 0 ∧ d v u = 0) ↔ u = v := by
  constructor
  · rintro ⟨huv, hvu⟩
    exact h_zero_cycle_rigid u v huv hvu
  · rintro rfl
    exact ⟨h_refl u, h_refl u⟩

/-! ## Monotonicity of the chronological relation under distance refinement -/

/-- If a distance function `d'` refines `d` (i.e., `d'(u,v) ≤ d(u,v)` everywhere) and
both are nonnegative, then the chronological relation of `d` is contained in that of `d'`
when `d` achieves zero. This formalizes the idea that tighter distance estimates preserve
causal reachability. -/
theorem chrono_monotone_of_le
    {V : Type*}
    (d d' : V → V → ℝ)
    (h_le : ∀ u v, d' u v ≤ d u v)
    (h_nonneg' : ∀ u v, 0 ≤ d' u v)
    (u v : V) :
    Chrono d u v → Chrono d' u v := by
  intro h
  unfold Chrono at *
  linarith [h_le u v, h_nonneg' u v]

/-! ## The chronological order respects distance composition -/

/-- For any intermediate vertex `w`, if `u ≼ w` and `w ≼ v` in the chronological order,
then `d(u,v) ≤ d(u,w) + d(w,v) = 0`, establishing `u ≼ v`. This is the transitivity
argument made explicit with the intermediate witness. -/
theorem chrono_via_intermediate
    {V : Type*}
    (d : V → V → ℝ)
    (h_triangle : ∀ a b c, d a c ≤ d a b + d b c)
    (h_nonneg : ∀ a b, 0 ≤ d a b)
    (u w v : V)
    (huw : Chrono d u w)
    (hwv : Chrono d w v) :
    Chrono d u v := by
  unfold Chrono at *
  have h1 : d u v ≤ d u w + d w v := h_triangle u w v
  rw [huw, hwv] at h1
  linarith [h_nonneg u v]

/-! ## Lawvere metric space formulation -/

/-- A Lawvere metric space structure: a nonnegative, reflexive distance satisfying the
triangle inequality. This is exactly a `(ℝ≥0, +)`-enriched category, and it encompasses
tropical shortest-path distances on weighted digraphs. -/
structure LawvereMetric (V : Type*) where
  dist : V → V → ℝ
  dist_self : ∀ v, dist v v = 0
  dist_nonneg : ∀ u v, 0 ≤ dist u v
  dist_triangle : ∀ u v w, dist u w ≤ dist u v + dist v w

/-- The zero-distance relation of a Lawvere metric is always a preorder. -/
noncomputable def LawvereMetric.toPreorder {V : Type*} (m : LawvereMetric V) : Preorder V where
  le := Chrono m.dist
  le_refl := tropical_chrono_refl m.dist m.dist_self
  le_trans := tropical_chrono_trans m.dist m.dist_triangle m.dist_nonneg

/-- A separated Lawvere metric: additionally requires that mutual zero distance implies equality.
This is the "no closed causal curves" condition. -/
structure SeparatedLawvereMetric (V : Type*) extends LawvereMetric V where
  dist_separated : ∀ u v, dist u v = 0 → dist v u = 0 → u = v

/-- **Main Theorem (Lawvere formulation).**
The zero-distance relation of a separated Lawvere metric is a partial order. -/
noncomputable def SeparatedLawvereMetric.toPartialOrder
    {V : Type*} [Fintype V] [DecidableEq V]
    (m : SeparatedLawvereMetric V) : PartialOrder V where
  le := Chrono m.dist
  le_refl := tropical_chrono_refl m.dist m.dist_self
  le_trans := tropical_chrono_trans m.dist m.dist_triangle m.dist_nonneg
  le_antisymm := tropical_chronological_antisymm m.dist m.dist_separated

/-! ## Decidability of the chronological relation (finite types) -/

/-- When the distance function has decidable equality to zero,
    the chronological relation is decidable. -/
instance chronoDecidable
    {V : Type*}
    (d : V → V → ℝ)
    [∀ u v, Decidable (d u v = 0)] :
    DecidableRel (Chrono d) :=
  fun u v => inferInstanceAs (Decidable (d u v = 0))

/-! ## Tropical distance from weighted digraph edges -/

/-- Given a weight function on edges and a list representing a directed path (as vertices),
    compute the total weight of the path. -/
noncomputable def pathWeight {V : Type*} (w : V → V → ℝ) : List V → ℝ
  | [] => 0
  | [_] => 0
  | u :: v :: rest => w u v + pathWeight w (v :: rest)

/-- The total weight of an empty path is zero. -/
@[simp]
theorem pathWeight_nil {V : Type*} (w : V → V → ℝ) : pathWeight w [] = 0 := rfl

/-- The total weight of a single-vertex path is zero. -/
@[simp]
theorem pathWeight_singleton {V : Type*} (w : V → V → ℝ) (v : V) :
    pathWeight w [v] = 0 := rfl

/-
**Zero-Walk Edge Decomposition.**
If all edge weights are nonneg and a path has total weight zero, then every
consecutive pair of vertices in the path has edge weight zero. This is because
each edge contributes a nonneg amount and they sum to zero.
-/
theorem zero_walk_implies_zero_edges
    {V : Type*}
    (w : V → V → ℝ)
    (h_nonneg : ∀ u v, 0 ≤ w u v)
    (p : List V)
    (hp : pathWeight w p = 0) :
    ∀ (i : ℕ) (hi : i + 1 < p.length),
      w (p.get ⟨i, by omega⟩) (p.get ⟨i+1, by omega⟩) = 0 := by
  induction' p with u p ih;
  · tauto;
  · rcases p with ( _ | ⟨ v, p ⟩ ) <;> simp_all +decide [ pathWeight ];
    -- Since $w u v + pathWeight w (v :: p) = 0$ and $w u v \geq 0$, it follows that $w u v = 0$ and $pathWeight w (v :: p) = 0$.
    have h_wuv_zero : w u v = 0 := by
      have h_pathWeight_nonneg : ∀ (p : List V), 0 ≤ pathWeight w p := by
        intro p
        induction' p with u p ih;
        · exact le_rfl;
        · cases p <;> simp +decide [ *, pathWeight ] ; linarith [ h_nonneg u ‹_› ];
      linarith [ h_nonneg u v, h_pathWeight_nonneg ( v :: p ) ]
    have h_pathWeight_zero : pathWeight w (v :: p) = 0 := by
      linarith;
    rintro ( _ | i ) hi <;> simp_all +decide;
    exact ih i ( Nat.lt_of_succ_le hi )

/-
**Nonnegativity of path weights.** If all edge weights are nonneg, then
every path has nonneg total weight.
-/
theorem pathWeight_nonneg
    {V : Type*}
    (w : V → V → ℝ)
    (h_nonneg : ∀ u v, 0 ≤ w u v)
    (p : List V) :
    0 ≤ pathWeight w p := by
  induction' p with u p ih;
  · exact le_rfl;
  · cases p <;> [ simp +decide ; exact add_nonneg ( h_nonneg _ _ ) ih ]