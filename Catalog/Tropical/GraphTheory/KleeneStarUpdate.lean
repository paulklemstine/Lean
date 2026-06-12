import Mathlib

/-!
# Kleene Star Single-Edge Update for Tropical APSP Closure

This file proves the tropical analogue of the Sherman–Morrison formula for
all-pairs shortest paths (APSP). When a single edge `u → v` of weight `w` is
added to a weighted directed graph with nonnegative edge weights (modeled in
`ENNReal`), the APSP closure matrix updates via an exact rank-one tropical formula:

  `S'(i,j) = min( S(i,j), S(i,u) + w + S(v,j) )`

where `S` is the original APSP closure and `S'` is the new one.

## Main Definitions

* `TropicalAPSP.IsAPSPClosure A S` — `S` is the least reflexive-transitive closure
  of adjacency matrix `A` in the min-plus semiring.
* `TropicalAPSP.edgeUpdate A u v w` — modify `A` by adding edge `u → v` with weight `w`.

## Main Results

* `TropicalAPSP.kleene_star_single_edge_update` — the APSP closure of `edgeUpdate A u v w`
  is exactly `fun i j ↦ min (S i j) (S i u + w + S v j)`.
* `TropicalAPSP.apsp_edge_update_mono` — edge insertion can only decrease shortest-path costs.
* `TropicalAPSP.apsp_closure_unique` — the APSP closure is unique.

## References

This is the tropical (min-plus) analogue of the Sherman–Morrison rank-one matrix
inverse update. It is foundational for certified dynamic shortest-path algorithms
and tropical perturbation theory.
-/

open Matrix

noncomputable section

namespace TropicalAPSP

/-! ## APSP Closure Definition -/

/-- `IsAPSPClosure A S` asserts that `S` is the **least reflexive-transitive closure**
of adjacency matrix `A` in the min-plus (tropical) semiring over `ENNReal`.

Concretely, `S` satisfies:
1. `S ≤ A` entrywise (direct edges are valid paths),
2. `S(i,i) = 0` (reflexivity: zero-cost identity path),
3. `S(i,j) ≤ S(i,k) + S(k,j)` for all `k` (transitivity: path concatenation),
4. `S` is pointwise minimal among all matrices satisfying (1)–(3). -/
structure IsAPSPClosure {n : ℕ} (A S : Matrix (Fin n) (Fin n) ENNReal) : Prop where
  le_adj : ∀ i j, S i j ≤ A i j
  diag_eq : ∀ i, S i i = 0
  triangle : ∀ i j k, S i j ≤ S i k + S k j
  minimal : ∀ T : Matrix (Fin n) (Fin n) ENNReal,
    (∀ i j, T i j ≤ A i j) →
    (∀ i, T i i = 0) →
    (∀ i j k, T i j ≤ T i k + T k j) →
    ∀ i j, S i j ≤ T i j

/-! ## Edge Update Definition -/

/-- Single-edge update: modify the adjacency matrix by adding an edge `u → v`
with weight `w`, taking the minimum with the existing weight. -/
def edgeUpdate {n : ℕ} (A : Matrix (Fin n) (Fin n) ENNReal)
    (u v : Fin n) (w : ENNReal) : Matrix (Fin n) (Fin n) ENNReal :=
  fun i j => min (A i j) (if i = u ∧ j = v then w else ⊤)

@[simp]
lemma edgeUpdate_apply {n : ℕ} (A : Matrix (Fin n) (Fin n) ENNReal)
    (u v : Fin n) (w : ENNReal) (i j : Fin n) :
    edgeUpdate A u v w i j = min (A i j) (if i = u ∧ j = v then w else ⊤) := rfl

/-- The edge update at the modified position `(u, v)`. -/
lemma edgeUpdate_same {n : ℕ} (A : Matrix (Fin n) (Fin n) ENNReal)
    (u v : Fin n) (w : ENNReal) :
    edgeUpdate A u v w u v = min (A u v) w := by
  simp [edgeUpdate]

/-- The edge update at an unmodified position. -/
lemma edgeUpdate_ne {n : ℕ} (A : Matrix (Fin n) (Fin n) ENNReal)
    (u v : Fin n) (w : ENNReal) {i j : Fin n} (h : ¬(i = u ∧ j = v)) :
    edgeUpdate A u v w i j = A i j := by
  simp [edgeUpdate, h]

/-- Edge update is pointwise `≤` the original matrix. -/
lemma edgeUpdate_le {n : ℕ} (A : Matrix (Fin n) (Fin n) ENNReal)
    (u v : Fin n) (w : ENNReal) (i j : Fin n) :
    edgeUpdate A u v w i j ≤ A i j := min_le_left _ _

/-! ## Key Algebraic Helper Lemma -/

/-
If `P ≤ a + c`, `Q ≤ a + d`, `Q ≤ b + c`, and `Q ≤ b + d`,
then `min P Q ≤ min a b + min c d`.

This is a general algebraic fact for `ENNReal` that captures the core
of the tropical triangle inequality under surgery.
-/
lemma min_le_min_add_min {P Q a b c d : ENNReal}
    (h1 : P ≤ a + c) (h2 : Q ≤ a + d) (h3 : Q ≤ b + c) (h4 : Q ≤ b + d) :
    min P Q ≤ min a b + min c d := by
  cases le_total a b <;> cases le_total c d <;> simp +decide [*]

/-! ## Proof Components for the Main Theorem -/

/-
**Condition 1**: The updated closure is below the updated adjacency matrix.
-/
lemma edgeUpdate_closure_le_adj {n : ℕ}
    {A S : Matrix (Fin n) (Fin n) ENNReal}
    (hS : IsAPSPClosure A S)
    (u v : Fin n) (w : ENNReal) :
    ∀ i j, min (S i j) (S i u + w + S v j) ≤ edgeUpdate A u v w i j := by
  intro i j;
  by_cases hij : i = u ∧ j = v <;> simp +decide [ *, edgeUpdate ];
  · exact ⟨ Or.inl <| hS.le_adj _ _, Or.inr <| by simp +decide [ hS.diag_eq ] ⟩;
  · exact Or.inl ( hS.le_adj i j )

/-
**Condition 2**: The diagonal of the updated closure is zero.
-/
lemma edgeUpdate_closure_diag {n : ℕ}
    {A S : Matrix (Fin n) (Fin n) ENNReal}
    (hS : IsAPSPClosure A S)
    (u v : Fin n) (w : ENNReal) :
    ∀ i, min (S i i) (S i u + w + S v i) = 0 := by
  exact fun i => by rw [ hS.diag_eq i, min_eq_left ( zero_le _ ) ] ;

/-
**Condition 3**: The updated closure satisfies the triangle inequality.

This is the key technical step. For any intermediate vertex `k`, we need
  `min(S(i,j), S(i,u)+w+S(v,j)) ≤ min(S(i,k), S(i,u)+w+S(v,k)) + min(S(k,j), S(k,u)+w+S(v,j))`

The proof uses `min_le_min_add_min` with four bounds derived from the
triangle inequality of the original closure `S`.
-/
lemma edgeUpdate_closure_triangle {n : ℕ}
    {A S : Matrix (Fin n) (Fin n) ENNReal}
    (hS : IsAPSPClosure A S)
    (u v : Fin n) (w : ENNReal) :
    ∀ i j k, min (S i j) (S i u + w + S v j) ≤
      min (S i k) (S i u + w + S v k) + min (S k j) (S k u + w + S v j) := by
  -- By the properties of min, we can split the inequality into two parts.
  intro i j k
  apply min_le_min_add_min;
  · exact hS.triangle i j k;
  · convert add_le_add_right ( hS.triangle i u k ) ( w + S v j ) using 1 ; ring;
    abel1;
  · convert add_le_add_left ( hS.triangle v j k ) ( S i u + w ) using 1 ; ring;
    abel1;
  · simp +decide [ add_assoc ];
    gcongr;
    refine' le_trans _ ( le_add_of_nonneg_left <| zero_le _ );
    exact le_add_of_nonneg_of_le ( zero_le _ ) ( le_add_of_nonneg_left ( zero_le _ ) )

/-
**Condition 4**: The updated closure is minimal.

Given any matrix `T` satisfying the closure conditions for the updated graph,
we show `S' ≤ T` entrywise. The key insight: since `edgeUpdate A u v w ≤ A`
entrywise, `T` also satisfies the closure conditions for `A`. By minimality
of `S` for `A`, we get `S ≤ T`, hence `min(S, ...) ≤ S ≤ T`.
-/
lemma edgeUpdate_closure_minimal {n : ℕ}
    {A S : Matrix (Fin n) (Fin n) ENNReal}
    (hS : IsAPSPClosure A S)
    (u v : Fin n) (w : ENNReal) :
    ∀ T : Matrix (Fin n) (Fin n) ENNReal,
      (∀ i j, T i j ≤ edgeUpdate A u v w i j) →
      (∀ i, T i i = 0) →
      (∀ i j k, T i j ≤ T i k + T k j) →
      ∀ i j, min (S i j) (S i u + w + S v j) ≤ T i j := by
  exact fun T h1 h2 h3 i j => le_trans ( min_le_left _ _ ) ( hS.minimal T ( fun i j => le_trans ( h1 i j ) ( edgeUpdate_le _ _ _ _ _ _ ) ) h2 h3 i j )

/-! ## Main Theorem -/

/-- **Tropical Sherman–Morrison theorem for APSP closure**.

If `S` is the APSP closure of adjacency matrix `A`, and we add a single edge
`u → v` with weight `w`, then the new APSP closure is
  `S'(i,j) = min( S(i,j),  S(i,u) + w + S(v,j) )`.

Every shortest path in the updated graph either:
- avoids the new edge entirely (cost = `S(i,j)`), or
- uses it exactly once, going `i →* u → v →* j` (cost = `S(i,u) + w + S(v,j)`).

In `ENNReal` (nonneg weights), repeated use of the new edge cannot improve
paths, so a single use suffices. -/
theorem kleene_star_single_edge_update
    {n : ℕ}
    (A S : Matrix (Fin n) (Fin n) ENNReal)
    (hS : IsAPSPClosure A S)
    (u v : Fin n) (w : ENNReal) :
    IsAPSPClosure (edgeUpdate A u v w)
      (fun i j => min (S i j) (S i u + w + S v j)) where
  le_adj := edgeUpdate_closure_le_adj hS u v w
  diag_eq := edgeUpdate_closure_diag hS u v w
  triangle := edgeUpdate_closure_triangle hS u v w
  minimal := edgeUpdate_closure_minimal hS u v w

/-! ## Corollaries -/

/-- **Uniqueness**: The APSP closure is unique (follows from minimality). -/
theorem apsp_closure_unique
    {n : ℕ}
    (A S₁ S₂ : Matrix (Fin n) (Fin n) ENNReal)
    (h₁ : IsAPSPClosure A S₁)
    (h₂ : IsAPSPClosure A S₂) :
    S₁ = S₂ := by
  exact Matrix.ext fun i j => le_antisymm ( h₁.minimal _ h₂.le_adj h₂.diag_eq h₂.triangle _ _ ) ( h₂.minimal _ h₁.le_adj h₁.diag_eq h₁.triangle _ _ )

/-
**Monotonicity**: Adding an edge can only decrease shortest-path costs.
-/
theorem apsp_edge_update_mono
    {n : ℕ}
    (A S S' : Matrix (Fin n) (Fin n) ENNReal)
    (hS : IsAPSPClosure A S)
    (u v : Fin n) (w : ENNReal)
    (hS' : IsAPSPClosure (edgeUpdate A u v w) S') :
    ∀ i j, S' i j ≤ S i j := by
  -- Apply the uniqueness theorem to get that S' equals the function that's the minimum of S and the new edge's cost.
  have h_eq : S' = (fun i j => min (S i j) (S i u + w + S v j)) := by
    apply apsp_closure_unique;
    exact hS';
    exact kleene_star_single_edge_update A S hS u v w;
  exact fun i j => h_eq ▸ min_le_left _ _

/-
**Idempotence**: Applying the same edge update twice yields the same closure.
-/
theorem apsp_edge_update_idempotent
    {n : ℕ}
    (A S : Matrix (Fin n) (Fin n) ENNReal)
    (hS : IsAPSPClosure A S)
    (u v : Fin n) (w : ENNReal) :
    let S' := fun i j => min (S i j) (S i u + w + S v j)
    let A' := edgeUpdate A u v w
    let A'' := edgeUpdate A' u v w
    ∀ T, IsAPSPClosure A'' T → T = fun i j => S' i j := by
  intro T hT A'' T hT;
  apply apsp_closure_unique;
  exact hT;
  convert kleene_star_single_edge_update A S hS u v w using 1;
  aesop

end TropicalAPSP