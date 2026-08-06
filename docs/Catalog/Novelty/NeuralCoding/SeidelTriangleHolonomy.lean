/-
# Seidel third moment as signed-triangle holonomy

This file connects the third spectral moment of a Seidel matrix with a purely
combinatorial parity statistic on triples of vertices.  Each ordered triple of
distinct vertices contributes `-1` when it spans an odd number of graph edges
and `+1` when it spans an even number.  Thus the matrix trace is exactly the
imbalance between even- and odd-edge ordered triples.

The same product is the holonomy of a signed graph around a triangle.  A vertex
switching multiplies an edge sign by one sign at each endpoint; all vertex signs
cancel around a triangle.  This gives a local, gauge-theoretic explanation of
the invariance of the cubic trace under Seidel switching.
-/
import Mathlib

open Matrix BigOperators

namespace SeidelTriangleHolonomy

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- The Seidel matrix of a loopless adjacency relation. -/
def seidel (adj : V → V → Prop) [DecidableRel adj] : Matrix V V ℝ :=
  fun i j => if i = j then 0 else if adj i j then -1 else 1

/-- An odd number of the three cyclic pairs are edges. -/
def OddEdgeTriple (adj : V → V → Prop) (i j k : V) : Prop :=
  (adj i j ∧ ¬ adj j k ∧ ¬ adj k i) ∨
  (¬ adj i j ∧ adj j k ∧ ¬ adj k i) ∨
  (¬ adj i j ∧ ¬ adj j k ∧ adj k i) ∨
  (adj i j ∧ adj j k ∧ adj k i)

instance (adj : V → V → Prop) [DecidableRel adj] (i j k : V) :
    Decidable (OddEdgeTriple adj i j k) := by
  unfold OddEdgeTriple
  infer_instance

/-- The parity weight of an ordered triple: repeated vertices contribute zero;
otherwise odd-edge triples contribute `-1` and even-edge triples `+1`. -/
def parityWeight (adj : V → V → Prop) [DecidableRel adj] (i j k : V) : ℝ :=
  if i = j ∨ j = k ∨ k = i then 0
  else if OddEdgeTriple adj i j k then -1 else 1

omit [Fintype V] in
/-- A Seidel product around a triangle is precisely its edge-parity sign. -/
theorem seidel_triangle_product_eq_parity
    (adj : V → V → Prop) [DecidableRel adj] (i j k : V) :
    seidel adj i j * seidel adj j k * seidel adj k i = parityWeight adj i j k := by
  unfold seidel parityWeight;
  unfold OddEdgeTriple; split_ifs <;> simp_all +decide ;

/-- **Spectral/combinatorial connector.**  The cubic Seidel trace is the signed
imbalance of ordered triples with an even versus odd number of induced edges. -/
theorem trace_cube_eq_parity_imbalance
    (adj : V → V → Prop) [DecidableRel adj] :
    (seidel adj * seidel adj * seidel adj).trace =
      ∑ i : V, ∑ j : V, ∑ k : V, parityWeight adj i j k := by
  simp +decide [ Matrix.trace, Matrix.mul_apply ];
  simp +decide only [Finset.sum_mul, seidel_triangle_product_eq_parity adj];
  exact Finset.sum_congr rfl fun _ _ => Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by unfold parityWeight; aesop )

omit [Fintype V] [DecidableEq V] in
/-- Switching a signed complete graph by vertex signs leaves every triangular
holonomy unchanged.  This is the local cancellation law behind switching
invariance of the third moment. -/
theorem triangle_holonomy_switch_invariant
    (S : Matrix V V ℝ) (d : V → ℝ) (hd : ∀ i, d i * d i = 1)
    (i j k : V) :
    (d i * S i j * d j) * (d j * S j k * d k) * (d k * S k i * d i) =
      S i j * S j k * S k i := by
  grind

omit [DecidableEq V] in
/-- Consequently, diagonal sign switching preserves the cubic trace, proved
locally from triangle holonomy rather than globally from spectral similarity. -/
theorem trace_cube_switch_invariant
    (S : Matrix V V ℝ) (d : V → ℝ) (hd : ∀ i, d i * d i = 1) :
    let switched : Matrix V V ℝ := fun i j => d i * S i j * d j
    (switched * switched * switched).trace = (S * S * S).trace := by
  simp +decide only [trace];
  simp +decide [ Matrix.mul_apply, mul_assoc ];
  simp +decide [ mul_comm, mul_left_comm, Finset.mul_sum _ _ _, hd ]

/-! ## A concrete three-vertex check -/

/-
On three vertices, the complete graph has cubic Seidel trace `-6`, while
its complement has trace `6`; the parity formula gives the same values.
-/
theorem fin3_complete_empty_cubic_witness :
    let complete : Fin 3 → Fin 3 → Prop := fun i j => i ≠ j
    let empty : Fin 3 → Fin 3 → Prop := fun _ _ => False
    (seidel complete * seidel complete * seidel complete).trace = -6 ∧
    (∑ i : Fin 3, ∑ j : Fin 3, ∑ k : Fin 3, parityWeight complete i j k) = -6 ∧
    (seidel empty * seidel empty * seidel empty).trace = 6 ∧
    (∑ i : Fin 3, ∑ j : Fin 3, ∑ k : Fin 3, parityWeight empty i j k) = 6 := by
  unfold seidel parityWeight; norm_num [ Fin.sum_univ_succ ] ;
  simp +decide [ Matrix.mul_apply, Matrix.trace ];
  norm_cast

end SeidelTriangleHolonomy