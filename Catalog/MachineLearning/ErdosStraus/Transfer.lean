/-
# Erdős–Straus: Scaling and Transfer Principles

This module proves the multiplicative transfer principle: if 4/n has
an Egyptian fraction decomposition, then so does 4/(kn) for any k ≥ 1.

This is strategically powerful: it turns seed families (even numbers,
n ≡ 3 mod 4) into infinite cones of solutions and creates a formal
mechanism for "covering sets" of denominators.

The key identity: if 4/n = 1/x + 1/y + 1/z, then
  4/(kn) = 1/(kx) + 1/(ky) + 1/(kz).
-/

import Mathlib
import Speculative.ErdosStraus.Defs

/-! ## Scaling for the integer witness form -/

/-
Scaling principle for ESWitness: if (n, x, y, z) is a witness,
    then (kn, kx, ky, kz) is also a witness for any k ≥ 1.

    In terms of the cubic surface 4xyz = n(xy + xz + yz),
    scaling by k transforms the surface point (x,y,z) on the n-surface
    to (kx,ky,kz) on the (kn)-surface.
-/
theorem ESWitness.scale
    {n x y z : ℕ} (h : ESWitness n x y z) (k : ℕ) (hk : 1 ≤ k) :
    ESWitness (k * n) (k * x) (k * y) (k * z) := by
  exact ⟨ by nlinarith [ h.1 ], by nlinarith [ h.2.1 ], by nlinarith [ h.2.2.1 ], by push_cast; nlinarith [ h.2.2.2, pow_pos ( by linarith : 0 < k ) 3 ] ⟩

/-! ## Scaling for the rational decomposition form -/

/-
Scaling principle for ESDecomposition: if 4/n = 1/x + 1/y + 1/z,
    then 4/(kn) = 1/(kx) + 1/(ky) + 1/(kz).

    This is the multiplicative transfer principle that turns seed
    families into infinite solution cones.
-/
noncomputable def ESDecomposition.scale
    {n : ℕ} (d : ESDecomposition n) (k : ℕ) (hk : 1 ≤ k) :
    ESDecomposition (k * n) where
  x := k * d.x
  y := k * d.y
  z := k * d.z
  hx := by nlinarith [d.hx]
  hy := by nlinarith [d.hy]
  hz := by nlinarith [d.hz]
  eqn := by
    convert congr_arg ( fun x : ℚ => x / k ) d.eqn using 1 <;> ring;
    · norm_num [ mul_comm ];
    · push_cast; ring

/-! ## Symmetry: the solution surface is invariant under permutation -/

/-
Permuting the denominators preserves the witness property.
-/
theorem ESWitness.perm_xy {n x y z : ℕ} (h : ESWitness n x y z) :
    ESWitness n y x z := by
  exact ⟨ h.2.1, h.1, h.2.2.1, by linarith [ h.2.2.2 ] ⟩

theorem ESWitness.perm_xz {n x y z : ℕ} (h : ESWitness n x y z) :
    ESWitness n z y x := by
  exact ⟨ h.2.2.1, h.2.1, h.1, by linarith [ h.2.2.2 ] ⟩

/-
Any witness can be sorted to produce an ordered witness.
-/
theorem ESWitness.toOrdered {n x y z : ℕ} (h : ESWitness n x y z) :
    ∃ a b c, OrderedESWitness n a b c := by
  -- By definition of $ESWitness$, we know that $x$, $y$, and $z$ are positive integers and satisfy the equation.
  obtain ⟨hx_pos, hy_pos, hz_pos, h_eq⟩ := h;
  cases le_total x y <;> cases le_total y z <;> cases le_total z x <;> first | exact ⟨ x, y, z, ⟨ hx_pos, hy_pos, hz_pos, h_eq ⟩, by linarith, by linarith ⟩ | skip;
  · exact ⟨ z, x, y, ⟨ ⟨ hz_pos, hx_pos, hy_pos, by linarith ⟩, by linarith, by linarith ⟩ ⟩;
  · exact ⟨ x, z, y, ⟨ ⟨ hx_pos, hz_pos, hy_pos, by linarith ⟩, by linarith, by linarith ⟩ ⟩;
  · exact ⟨ y, z, x, ⟨ ⟨ hy_pos, hz_pos, hx_pos, by linarith ⟩, by linarith, by linarith ⟩ ⟩;
  · exact ⟨ y, x, z, ⟨ ⟨ hy_pos, hx_pos, hz_pos, by linarith ⟩, by linarith, by linarith ⟩ ⟩;
  · exact ⟨ z, y, x, ⟨ ⟨ hz_pos, hy_pos, hx_pos, by linarith ⟩, by linarith, by linarith ⟩ ⟩