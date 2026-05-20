/-
# Erdős–Straus: Covering Theorem and Geometric Bounds

This module combines the even and mod-4≡3 families with the scaling
principle to prove that 3/4 of all integers ≥ 2 satisfy the conjecture.

It also proves geometric bounds on ordered witnesses, interpreting
decompositions as lattice points on an affine cubic surface.

## Main results

* `erdos_straus_cover_large_subfamily` — Every n ≥ 2 that is either
  even or ≡ 3 (mod 4) has a decomposition.

* `ordered_witness_first_denominator_bound` — For ordered witnesses,
  4x ≤ 3n: the smallest denominator is bounded.

* `witness_normalized_mass_sum_one` — Simplex normalization: the
  "mass distribution" n/(4x) + n/(4y) + n/(4z) = 1.
-/

import Mathlib
import Speculative.ErdosStraus.Defs
import Speculative.ErdosStraus.Families
import Speculative.ErdosStraus.Transfer

/-! ## The covering theorem: density 3/4 -/

/-
Every n ≥ 2 that is either even or ≡ 3 mod 4 has a decomposition.
    This covers exactly 3 out of every 4 residue classes mod 4
    (classes 0, 2, 3), leaving only n ≡ 1 mod 4 uncovered.

    The proof combines:
    - `erdos_straus_even` for even n
    - `erdos_straus_mod4_eq3` for n ≡ 3 mod 4
-/
theorem erdos_straus_cover_large_subfamily
    (n : ℕ) (hn : 2 ≤ n)
    (hcover : Even n ∨ n % 4 = 3) :
    ∃ d : ESDecomposition n, True := by
  obtain h | h := hcover;
  · exact Exists.elim ( erdos_straus_of_even n hn h ) fun d hd => ⟨ d, hd ⟩;
  · -- Since $n \equiv 3 \pmod{4}$, we can write $n = 4k + 3$ for some integer $k$.
    obtain ⟨k, rfl⟩ : ∃ k, n = 4 * k + 3 := by
      exact ⟨ n / 4, by rw [ ← h, Nat.div_add_mod ] ⟩;
    exact ⟨ erdos_straus_mod4_eq3 k, trivial ⟩

/-! ## Geometric bound: first denominator in ordered witnesses

For an ordered witness (x ≤ y ≤ z), since 4/n = 1/x + 1/y + 1/z ≤ 3/x,
we get x ≤ 3n/4, or equivalently 4x ≤ 3n.

This is a genuine bridge from number theory to discrete geometry:
the feasible region for x is a bounded interval [1, 3n/4]. -/

/-
If (x, y, z) is an ordered witness for n with x ≤ y ≤ z,
    then 4x ≤ 3n. This bounds the search space for the smallest
    denominator to a linear function of n.
-/
theorem ordered_witness_first_denominator_bound
    {n x y z : ℕ} (hn : 1 ≤ n)
    (h : OrderedESWitness n x y z) :
    4 * x ≤ 3 * n := by
  obtain ⟨ hx, hy, hz, h_eq ⟩ := h;
  · nlinarith [ hx.1, hx.2.1, hx.2.2.1, hx.2.2.2, mul_pos ( by linarith [ hx.1 ] : 0 < x ) ( by linarith [ hx.2.1 ] : 0 < y ) ];
  · obtain ⟨ hx', hy', hz', h_eq ⟩ := hx;
    norm_cast at h_eq;
    nlinarith [ Nat.mul_le_mul_left x hy, Nat.mul_le_mul_left y ‹y ≤ _›, Nat.mul_le_mul_left x ‹y ≤ _› ]

/-! ## Simplex normalization: mass distribution interpretation

When 4/n = 1/x + 1/y + 1/z, multiplying both sides by n/4 gives:
  n/(4x) + n/(4y) + n/(4z) = 1.

This means the triple (n/(4x), n/(4y), n/(4z)) lies on the probability
simplex Δ², interpreting Egyptian decompositions as 3-atom rational
probability distributions constrained by reciprocal denominators. -/

/-
The normalized mass distribution from an ESDecomposition sums to 1.
    This interprets decompositions as points on the probability simplex.
-/
theorem witness_normalized_mass_sum_one
    {n : ℕ} (d : ESDecomposition n) :
    ((n : ℚ) / (4 * d.x)) + ((n : ℚ) / (4 * d.y)) + ((n : ℚ) / (4 * d.z)) = 1 := by
  have := d.eqn;
  convert congr_arg ( fun x : ℚ => x * ( n : ℚ ) / 4 ) this.symm using 1 <;> ring;
  rw [ mul_inv_cancel₀ ] ; norm_cast ; rintro rfl ; norm_num at this;
  exact absurd this ( by linarith [ inv_pos.mpr ( show 0 < ( d.x : ℚ ) by norm_cast; linarith [ d.hx ] ), inv_pos.mpr ( show 0 < ( d.y : ℚ ) by norm_cast; linarith [ d.hy ] ), inv_pos.mpr ( show 0 < ( d.z : ℚ ) by norm_cast; linarith [ d.hz ] ) ] )