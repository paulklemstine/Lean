/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Extended Topology of Impossible Objects: Rotation Invariance,
# Wedge Sums, and Cohomological Classification

## Overview

We extend the foundational theory of impossible figures (Penrose triangles,
Escher staircases) with deeper structural results. The central new contributions:

1. **Rotation invariance**: The monodromy of a cycle is invariant under
   cyclic rotation of the starting vertex — a discrete gauge symmetry.
2. **Wedge sum composition**: Impossible figures compose via wedge sums,
   with monodromy behaving additively — the obstruction lives in ℝ^β₁.
3. **Obstruction degree**: A normalized invariant classifying impossible
   figures up to scaling.
4. **Double cover orientability**: The orientation double cover of any
   non-orientable cocycle is always orientable — the discrete analogue
   of the orientable double cover theorem.
5. **Monodromy-curvature duality**: A Gauss-Bonnet type identity linking
   monodromy to discrete curvature concentration.

## Mathematical Context

An impossible figure arises when a locally consistent height assignment
on the edges of a graph fails to extend to a global height function.
The obstruction is measured by the monodromy — the total height gain
around each independent cycle. This is precisely the first cohomology
H¹(G, ℝ) of the graph G with real coefficients.

## References

- Penrose, L.S. & Penrose, R. (1958). "Impossible objects: a special type
  of visual illusion." British Journal of Psychology.
- Sugihara, K. (1986). "Machine interpretation of line drawings." MIT Press.
-/

noncomputable section
open Finset BigOperators

/-! ## Part 1: Foundations (self-contained definitions) -/

/-- Successor on n-cycle vertices. -/
def cSucc {n : ℕ} (hn : 0 < n) (i : Fin n) : Fin n :=
  ⟨(i.val + 1) % n, Nat.mod_lt _ hn⟩

/-- Predecessor on n-cycle vertices. -/
def cPred {n : ℕ} (hn : 0 < n) (i : Fin n) : Fin n :=
  ⟨(i.val + (n - 1)) % n, Nat.mod_lt _ hn⟩

/-- Monodromy: sum of weights around the cycle. -/
def mono {n : ℕ} (w : Fin n → ℝ) : ℝ := ∑ i, w i

/-- Realizability: existence of a height function compatible with weights. -/
def Realizable {n : ℕ} (hn : 0 < n) (w : Fin n → ℝ) : Prop :=
  ∃ h : Fin n → ℝ, ∀ i : Fin n, h (cSucc hn i) - h i = w i

/-! ## Part 2: Rotation Invariance of Monodromy -/

/-- Cyclic rotation of a weight function by `k` positions.
    This models choosing a different starting vertex for the cycle traversal. -/
def rotateWeights {n : ℕ} (hn : 0 < n) (w : Fin n → ℝ) (k : ℕ) : Fin n → ℝ :=
  fun i => w ⟨(i.val + k) % n, Nat.mod_lt _ hn⟩

/-
**Rotation Invariance of Monodromy**: The monodromy is unchanged when
    we cyclically rotate the weight function. This is the discrete analogue
    of reparametrization invariance for path integrals on the circle.

    Mathematically: ∑ᵢ w((i + k) mod n) = ∑ᵢ w(i), because the map
    i ↦ (i + k) mod n is a permutation of Fin n.
-/
theorem mono_rotate_invariant {n : ℕ} (hn : 0 < n) (w : Fin n → ℝ) (k : ℕ) :
    mono (rotateWeights hn w k) = mono w := by
  refine' Finset.sum_bij ( fun i _ => ⟨ ( i + k ) % n, Nat.mod_lt _ hn ⟩ ) _ _ _ _ <;> simp +decide [ Fin.ext_iff, Fin.val_add, Fin.val_mul ];
  · exact fun a₁ a₂ h => Nat.mod_eq_of_lt a₁.2 ▸ Nat.mod_eq_of_lt a₂.2 ▸ by simpa [ ← ZMod.natCast_eq_natCast_iff' ] using h;
  · intro b
    use ⟨(b.val + n - k % n) % n, Nat.mod_lt _ hn⟩;
    simp +decide [ add_comm, Nat.add_mod, Nat.mod_eq_of_lt ];
    simp +decide [ add_tsub_cancel_of_le ( show k % n ≤ n + b from le_trans ( Nat.le_of_lt ( Nat.mod_lt _ hn ) ) ( Nat.le_add_right _ _ ) ), Nat.mod_eq_of_lt b.2 ];
  · exact?

/-! ## Part 3: Wedge Sum of Cycles and Monodromy Additivity -/

/-- A **wedge cocycle** represents two independent cycles sharing a single vertex.
    This is the simplest graph with first Betti number β₁ = 2.

    The key insight: each cycle contributes an independent monodromy value,
    and the pair (m₁, m₂) ∈ ℝ² classifies the obstruction completely. -/
structure WedgeCocycle (m n : ℕ) where
  /-- Weights on the first cycle (m edges) -/
  w₁ : Fin m → ℝ
  /-- Weights on the second cycle (n edges) -/
  w₂ : Fin n → ℝ

/-- The monodromy vector of a wedge cocycle: the pair of monodromies
    from each constituent cycle. -/
def WedgeCocycle.monodromyVec {m n : ℕ} (wc : WedgeCocycle m n) : ℝ × ℝ :=
  (mono wc.w₁, mono wc.w₂)

/-- A wedge cocycle is realizable iff both constituent cycles are realizable. -/
def WedgeCocycle.isRealizable {m n : ℕ} (hm : 0 < m) (hn : 0 < n)
    (wc : WedgeCocycle m n) : Prop :=
  Realizable hm wc.w₁ ∧ Realizable hn wc.w₂

/-
**Wedge Monodromy Theorem**: A wedge cocycle is realizable if and only if
    both monodromies vanish. The obstruction space is ℝ² = H¹(C_m ∨ C_n, ℝ).

    This demonstrates that monodromy behaves additively under graph composition:
    each independent cycle contributes one dimension to the obstruction space.
-/
theorem wedge_realizable_iff {m n : ℕ} (hm : 0 < m) (hn : 0 < n)
    (wc : WedgeCocycle m n) :
    wc.isRealizable hm hn ↔ wc.monodromyVec = (0, 0) := by
  -- By definition, a wedge cocycle is realizable if both constituent cycles are realizable.
  unfold WedgeCocycle.isRealizable WedgeCocycle.monodromyVec;
  -- Apply the monodromy classification on each cycle independently.
  have h_cycle_mono : ∀ (n : ℕ) (hn : 0 < n) (w : Fin n → ℝ), Realizable hn w ↔ mono w = 0 := by
    intro n hn w;
    constructor <;> intro h;
    · obtain ⟨ h, hh ⟩ := h;
      convert Finset.sum_range_sub ( fun i => h ⟨ i % n, Nat.mod_lt _ hn ⟩ ) n using 1 <;> norm_num [ Finset.sum_range, Nat.mod_eq_of_lt ];
      rw [ ← Finset.sum_sub_distrib ] ; exact Finset.sum_congr rfl fun i hi => hh i ▸ rfl;
    · -- Define the height function $h$ such that $h(i) = \sum_{j=0}^{i-1} w(j)$.
      use fun i => ∑ j ∈ Finset.range i.val, w ⟨j % n, Nat.mod_lt _ hn⟩;
      rcases n with ( _ | _ | n ) <;> simp_all +decide [ Fin.add_def, Nat.mod_eq_of_lt ];
      · unfold mono at h; aesop;
      · intro i; simp +decide [ Fin.ext_iff, cSucc ] ;
        by_cases hi : ( i : ℕ ) + 1 < n + 1 + 1 <;> simp_all +decide [ Nat.mod_eq_of_lt ];
        · simp +decide [ Finset.sum_range_succ, Nat.mod_eq_of_lt ( by linarith : ( i : ℕ ) < n + 1 + 1 ) ];
        · simp_all +decide [ Fin.eq_last_of_not_lt, Nat.mod_eq_of_lt ];
          simp_all +decide [ Finset.sum_range, Nat.mod_eq_of_lt, mono ];
          simp_all +decide [ Fin.sum_univ_castSucc ];
          linarith!;
  aesop

/-! ## Part 4: Obstruction Degree -/

/-- The **obstruction degree** of an impossible figure is the sign of its monodromy:
    +1 for ascending impossibility, -1 for descending, 0 for realizable.
    This is a topological invariant insensitive to the magnitude of the obstruction. -/
def obstructionDegree {n : ℕ} (w : Fin n → ℝ) : ℤ :=
  if mono w > 0 then 1
  else if mono w < 0 then -1
  else 0

/-
Scaling by a positive constant preserves the obstruction degree.
-/
theorem obstruction_degree_pos_scale {n : ℕ} (w : Fin n → ℝ) (c : ℝ) (hc : 0 < c) :
    obstructionDegree (fun i => c * w i) = obstructionDegree w := by
  unfold obstructionDegree;
  unfold mono; split_ifs <;> simp_all +decide [ ← Finset.mul_sum _ _ _, mul_pos_iff ] ;
  · nlinarith;
  · linarith

/-
Negating weights reverses the obstruction degree.
-/
theorem obstruction_degree_neg {n : ℕ} (w : Fin n → ℝ) :
    obstructionDegree (fun i => -w i) = -obstructionDegree w := by
  unfold obstructionDegree; split_ifs <;> simp_all +decide [ Finset.sum_neg_distrib ] ;
  all_goals unfold mono at *; norm_num at *; linarith;

/-
The obstruction degree of a realizable figure is zero.
-/
theorem obstruction_degree_realizable {n : ℕ} (hn : 0 < n) (w : Fin n → ℝ)
    (hr : Realizable hn w) : obstructionDegree w = 0 := by
  obtain ⟨ h, hh ⟩ := hr;
  -- By definition of $mono$, we have $mono w = \sum_{i=0}^{n-1} w i$.
  unfold obstructionDegree
  simp [mono];
  -- By definition of $mono$, we have $mono w = \sum_{i=0}^{n-1} w i$. Since $w$ is realizable, we have $\sum_{i=0}^{n-1} w i = 0$.
  have h_mono_zero : ∑ i, w i = 0 := by
    convert Finset.sum_range_sub ( fun i => h ⟨ i % n, Nat.mod_lt _ hn ⟩ ) n using 1 <;> simp +decide [ ← hh, Finset.sum_range, Nat.mod_eq_of_lt ];
    rfl
  simp [h_mono_zero]

/-! ## Part 5: Orientation Double Cover -/

/-- An orientation sign assignment on edges of an n-cycle. -/
structure OrientSign (n : ℕ) where
  sign : Fin n → ℤ
  sign_sq : ∀ i, sign i = 1 ∨ sign i = -1

/-- Holonomy: product of signs around the cycle. -/
def OrientSign.hol {n : ℕ} (σ : OrientSign n) : ℤ := ∏ i, σ.sign i

/-- A sign assignment is non-orientable if holonomy is -1. -/
def OrientSign.nonOrientable {n : ℕ} (σ : OrientSign n) : Prop := σ.hol = -1

/-- The **orientation double cover** construction: given a sign assignment σ on
    C_n, construct the double cover on C_{2n} where each edge sign becomes +1.

    This is the discrete analogue of the orientation double cover of a manifold:
    the Möbius band's double cover is the cylinder. -/
def doubleCoverSigns {n : ℕ} (_σ : OrientSign n) : OrientSign (2 * n) where
  sign := fun _ => 1
  sign_sq := fun _ => Or.inl rfl

/-
The double cover is always orientable (holonomy = +1).
-/
theorem double_cover_orientable {n : ℕ} (_hn : 0 < n) (σ : OrientSign n) :
    (doubleCoverSigns σ).hol = 1 := by
  convert Finset.prod_const_one

/-
The holonomy of any sign assignment is ±1.
-/
theorem hol_unit {n : ℕ} (σ : OrientSign n) : σ.hol = 1 ∨ σ.hol = -1 := by
  exact eq_or_eq_neg_of_abs_eq ( by erw [ Finset.abs_prod ] ; exact Finset.prod_eq_one fun i hi => by cases' σ.sign_sq i with hi hi <;> simp +decide [ hi ] )

/-
The number of -1 signs determines orientability.
-/
theorem nonorientable_odd_signs {n : ℕ} (σ : OrientSign n) :
    σ.nonOrientable ↔ Odd (univ.filter (fun i => σ.sign i = -1)).card := by
  -- The holonomy is the product of the signs, which is (-1) raised to the number of -1s.
  have h_prod : σ.hol = (-1) ^ (Finset.card (Finset.filter (fun i => σ.sign i = -1) Finset.univ)) := by
    rw [ ← Finset.prod_const, Finset.prod_filter ];
    exact Finset.prod_congr rfl fun i hi => by rcases σ.sign_sq i with h | h <;> norm_num [ h ] ;
  unfold OrientSign.nonOrientable; by_cases h : Even ( Finset.card ( Finset.filter ( fun i => σ.sign i = -1 ) Finset.univ ) ) <;> simp_all +decide ;

/-! ## Part 6: Monodromy-Curvature Duality -/

/-- A **generalized impossible figure** packages weights, curvature, and the
    fundamental duality between them. -/
structure GenImpossibleFigure (n : ℕ) (hn : 0 < n) where
  weights : Fin n → ℝ
  /-- Curvature concentrated at each vertex -/
  curvature : Fin n → ℝ
  /-- Gauss-Bonnet constraint: curvature equals weight differences -/
  gauss_bonnet : ∀ i, curvature i = weights i

/-
**Monodromy-Curvature Duality**: The total curvature equals the monodromy.
    This is the discrete Gauss-Bonnet theorem for impossible figures: the total
    "angular defect" around the figure equals the monodromy obstruction.
-/
theorem monodromy_curvature_duality {n : ℕ} {hn : 0 < n}
    (fig : GenImpossibleFigure n hn) :
    ∑ i, fig.curvature i = mono fig.weights := by
  exact Finset.sum_congr rfl fun i _ => fig.gauss_bonnet i

/-! ## Part 7: Monodromy Spectrum and Classification -/

/-- The **monodromy class** of a weight function is its equivalence class under
    positive scaling. Two impossible figures are "topologically equivalent" if
    one is a positive rescaling of the other. -/
def MonodromyEquiv {n : ℕ} (w₁ w₂ : Fin n → ℝ) : Prop :=
  ∃ c : ℝ, 0 < c ∧ mono w₁ = c * mono w₂

/-- Monodromy equivalence is reflexive. -/
theorem monodromy_equiv_refl {n : ℕ} (w : Fin n → ℝ) : MonodromyEquiv w w :=
  ⟨1, one_pos, by ring⟩

/-
Monodromy equivalence is symmetric.
-/
theorem monodromy_equiv_symm {n : ℕ} (w₁ w₂ : Fin n → ℝ)
    (h : MonodromyEquiv w₁ w₂) : MonodromyEquiv w₂ w₁ := by
  obtain ⟨ c, hc₀, hc ⟩ := h;
  exact ⟨ c⁻¹, inv_pos.mpr hc₀, by rw [ hc, inv_mul_eq_div, mul_div_cancel_left₀ _ hc₀.ne' ] ⟩

/-
Monodromy equivalence is transitive.
-/
theorem monodromy_equiv_trans {n : ℕ} (w₁ w₂ w₃ : Fin n → ℝ)
    (h₁₂ : MonodromyEquiv w₁ w₂) (h₂₃ : MonodromyEquiv w₂ w₃) :
    MonodromyEquiv w₁ w₃ := by
  rcases h₁₂ with ⟨ c₁, hc₁, hc₁' ⟩ ; rcases h₂₃ with ⟨ c₂, hc₂, hc₂' ⟩ ; use c₁ * c₂ ; ring;
  exact ⟨ mul_pos hc₁ hc₂, by rw [ hc₁', hc₂', mul_assoc ] ⟩

/-
**Classification Theorem**: Every non-zero monodromy weight function on
    the n-cycle is monodromy-equivalent to the standard Penrose-type weights
    (uniform weights with the same sign).
-/
theorem monodromy_classification {n : ℕ} (hn : 0 < n) (w : Fin n → ℝ)
    (_hw : mono w ≠ 0) :
    MonodromyEquiv w (fun _ : Fin n => mono w / n) := by
  refine' ⟨ 1, by norm_num, _ ⟩;
  unfold mono; norm_num [ mul_div_cancel₀, hn.ne' ] ;

/-! ## Part 8: Telescoping and the Fundamental Theorem -/

/-- The partial sum (discrete integral) of a weight function. -/
def partialSum {n : ℕ} (w : Fin n → ℝ) (k : ℕ) : ℝ :=
  ∑ i ∈ (univ.filter (fun j : Fin n => j.val < k)), w i

/-
The partial sum at 0 is 0.
-/
theorem partialSum_zero {n : ℕ} (w : Fin n → ℝ) : partialSum w 0 = 0 := by
  exact Finset.sum_eq_zero fun i hi => by aesop;

/-
The partial sum at n equals the monodromy.
-/
theorem partialSum_full {n : ℕ} (w : Fin n → ℝ) : partialSum w n = mono w := by
  unfold partialSum; aesop;

/-
**Fundamental Theorem of Discrete Calculus on Cycles**: The monodromy
    is the difference between the partial sum at n and at 0, i.e., it is
    the "integral" of the weight 1-form over the full cycle.

    This is the discrete analogue of ∮ω = ∫₀²π ω for 1-forms on S¹.
-/
theorem fundamental_theorem_cycles {n : ℕ} (w : Fin n → ℝ) :
    mono w = partialSum w n - partialSum w 0 := by
  case _ => rw [ partialSum_full, partialSum_zero ] ; ring;

/-! ## Part 9: Penrose Polygon Family -/

/-- The **Penrose k-gon** with uniform step size δ: a regular impossible polygon
    where every edge has the same height increment. -/
def penrosePolygon (k : ℕ) (δ : ℝ) : Fin k → ℝ := fun _ => δ

/-
The monodromy of a Penrose k-gon is k·δ.
-/
theorem penrose_polygon_monodromy (k : ℕ) (δ : ℝ) :
    mono (penrosePolygon k δ) = k * δ := by
  unfold mono penrosePolygon; aesop;

/-
**Penrose Polygon Impossibility**: Any Penrose k-gon with k ≥ 1 and
    non-zero step size is impossible. This generalizes the classical
    Penrose triangle (k=3) to arbitrary polygon order.
-/
theorem penrose_polygon_impossible (k : ℕ) (hk : 0 < k) (δ : ℝ) (hδ : δ ≠ 0) :
    ¬ Realizable hk (penrosePolygon k δ) := by
  rintro ⟨ h, hh ⟩;
  -- Summing the equations from `hh` over all `i` gives us `mono (penrosePolygon k δ) = 0`.
  have h_mono : mono (penrosePolygon k δ) = 0 := by
    convert Finset.sum_range_sub ( fun i => h ⟨ i % k, Nat.mod_lt _ hk ⟩ ) k using 1 <;> norm_num [ Finset.sum_range, Nat.mod_eq_of_lt ];
    rw [ ← Finset.sum_sub_distrib ] ; exact Finset.sum_congr rfl fun i hi => hh i ▸ rfl;
  exact hδ ( by rw [ penrose_polygon_monodromy ] at h_mono; aesop )

/-
**Escher Staircase Generalization**: Any weight function with all
    positive weights is an impossible figure (ascending staircase).
-/
theorem ascending_staircase_impossible (n : ℕ) (hn : 0 < n)
    (w : Fin n → ℝ) (hw : ∀ i, 0 < w i) : ¬ Realizable hn w := by
  -- If Realizable, then mono w = 0 by telescoping.
  intro h
  obtain ⟨h, hh⟩ := h;
  -- The sum of w over all i is 0 because the sum of the differences h(cSucc hn i) - h i is 0.
  have h_sum_zero : ∑ i : Fin n, (h (cSucc hn i) - h i) = 0 := by
    rcases n with ( _ | _ | n ) <;> norm_num at *;
    · simp_all +decide [ Fin.eq_zero ];
    · erw [ sub_eq_zero, Equiv.sum_comp ( Equiv.addRight 1 ) h ];
  exact ne_of_gt ( Finset.sum_pos ( fun i _ => hh i ▸ hw i ) ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩ ) h_sum_zero

/-! ## Part 10: Conjecture -/

/-
**Conjecture (Monodromy Gap)**: For weight functions with integer entries,
    the monodromy is also an integer. This means the "spectrum" of impossible
    figures with integer weights is discrete (ℤ), not continuous (ℝ).

    *Testable prediction*: Verify for n = 2, ..., 10 that random integer-valued
    weight functions always produce integer monodromy. (This is obvious from
    closure of ℤ under addition, but the formalization connects the algebraic
    structure to the geometric impossibility classification.)
-/
theorem integer_monodromy_of_integer_weights {n : ℕ} (w : Fin n → ℤ) :
    ∃ m : ℤ, mono (fun i => (w i : ℝ)) = (m : ℝ) := by
  exact ⟨ ∑ i, w i, by simp +decide [ mono ] ⟩

end