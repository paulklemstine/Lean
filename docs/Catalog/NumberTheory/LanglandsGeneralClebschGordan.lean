import Catalog.Shared.LanglandsTensorTransfer

/-!
# Langlands functoriality, V: the general Clebsch–Gordan decomposition of `Sym^m × Sym^n`

This file proves the general local Rankin–Selberg / functoriality statement for symmetric
power lifts of an unramified `GL(2)` representation: for all `n ≤ m`,

`L(s, Sym^m π × Sym^n π) = ∏_{r=0}^{n} L(s, Sym^{m+n-2r} π ⊗ χ^r)`,

the L-function avatar of the Clebsch–Gordan decomposition
`Sym^m ⊗ Sym^n = ⨁_{r=0}^{n} Sym^{m+n-2r} ⊗ det^r`.

The proof isolates the entire combinatorial content in `prod_grid_eq`, a statement about an
arbitrary commutative monoid: the multiset of index sums `{i + j : i ≤ m, j ≤ n}` coincides
with `⨄_{r ≤ n} {r, r+1, …, r + (m+n-2r)}`.  The Langlands content is then the observation
that the Satake parameters of `Sym^m π ⊗ Sym^n π` and of `⨁_r Sym^{m+n-2r} π ⊗ χ^r` are both
of the form `a^t b^{m+n-t}` with exactly those index multisets
(`satake_mul_satake` and `satake_twist_gen`).

This generalises `symEuler_tensor_one` (`n = 1`) and `symEuler_tensor_two` (`n = 2`), and its
`m = n = 1` case is the local Gelbart–Jacquet identity `L(π × π) = L(Sym^2 π) L(χ)`.
-/

namespace Langlands

open Finset PowerSeries

section Grid

/-- **The Clebsch–Gordan index identity.**  In any commutative monoid, the product of `F`
over the multiset of sums `i + j` with `i ≤ m`, `j ≤ n` (`n ≤ m`) equals the product over
`⨄_{r ≤ n} {r, …, r + (m + n - 2r)}`.  This is the combinatorial heart of the decomposition
`Sym^m ⊗ Sym^n = ⨁_r Sym^{m+n-2r} ⊗ det^r`. -/
theorem prod_grid_eq {M : Type*} [CommMonoid M] (F : ℕ → M) :
    ∀ n m : ℕ, n ≤ m →
      (∏ i ∈ range (m + 1), ∏ j ∈ range (n + 1), F (i + j))
        = ∏ r ∈ range (n + 1), ∏ i ∈ range (m + n - 2 * r + 1), F (r + i) := by
  intro n
  induction n with
  | zero => intro m _; simp
  | succ n ih =>
      intro m hm
      have hnm : n ≤ m := Nat.le_of_succ_le hm
      have hL : (∏ i ∈ range (m + 1), ∏ j ∈ range (n + 1 + 1), F (i + j))
          = (∏ i ∈ range (m + 1), ∏ j ∈ range (n + 1), F (i + j))
            * ∏ i ∈ range (m + 1), F (i + (n + 1)) := by
        rw [← Finset.prod_mul_distrib]
        exact Finset.prod_congr rfl fun i _ => Finset.prod_range_succ _ _
      have hR : (∏ r ∈ range (n + 1 + 1), ∏ i ∈ range (m + (n + 1) - 2 * r + 1), F (r + i))
          = ((∏ r ∈ range (n + 1), ∏ i ∈ range (m + n - 2 * r + 1), F (r + i))
              * ∏ r ∈ range (n + 1), F (m + n + 1 - r))
            * ∏ i ∈ range (m - n), F ((n + 1) + i) := by
        rw [Finset.prod_range_succ]
        congr 1
        · rw [← Finset.prod_mul_distrib]
          refine Finset.prod_congr rfl ?_
          intro r hr
          have hrn : r ≤ n := Nat.lt_succ_iff.mp (Finset.mem_range.mp hr)
          rw [show m + (n + 1) - 2 * r + 1 = (m + n - 2 * r + 1) + 1 by omega,
            Finset.prod_range_succ]
          congr 2
          omega
        · rw [show m + (n + 1) - 2 * (n + 1) + 1 = m - n by omega]
      rw [hL, hR, ih m hnm]
      have hsplit : (∏ i ∈ range (m + 1), F (i + (n + 1)))
          = (∏ i ∈ range (m - n), F ((n + 1) + i)) * ∏ r ∈ range (n + 1), F (m + n + 1 - r) := by
        have hmn : m + 1 = (m - n) + (n + 1) := by omega
        rw [hmn, Finset.prod_range_add]
        congr 1
        · exact Finset.prod_congr rfl fun i _ => by rw [Nat.add_comm]
        · rw [← Finset.prod_range_reflect]
          refine Finset.prod_congr rfl ?_
          intro i hi
          have := Finset.mem_range.mp hi
          congr 1
          omega
      rw [hsplit]
      ac_rfl

end Grid

section GeneralTransfer

variable {R : Type*} [CommRing R]

/-- Satake parameters multiply according to index sums:
`γ^{(m)}_i · γ^{(n)}_j = γ^{(m+n)}_{i+j}`. -/
lemma satake_mul_satake (m n : ℕ) (a b : R) (i j : ℕ) (hi : i ≤ m) (hj : j ≤ n) :
    symSatake m a b i * symSatake n a b j = symSatake (m + n) a b (i + j) := by
  rw [symSatake, symSatake, symSatake, show m + n - (i + j) = (m - i) + (n - j) by omega,
    pow_add, pow_add]
  ring

/-- The `r`-th twisted summand `Sym^{m+n-2r} ⊗ det^r` has Satake parameters
`γ^{(m+n)}_{r+i}`. -/
lemma satake_twist_gen (m n : ℕ) (a b : R) (r i : ℕ) (hr : r ≤ n) (hnm : n ≤ m)
    (hi : i ≤ m + n - 2 * r) :
    (a * b) ^ r * symSatake (m + n - 2 * r) a b i = symSatake (m + n) a b (r + i) := by
  rw [symSatake, symSatake, mul_pow,
    show m + n - (r + i) = r + (m + n - 2 * r - i) by omega, pow_add, pow_add]
  ring

/-- **General Clebsch–Gordan decomposition of Euler factors.**  For `n ≤ m`, the degree
`(m+1)(n+1)` Euler factor of `Sym^m π × Sym^n π` factors as the product of the Euler factors
of `Sym^{m+n-2r} π ⊗ χ^r`, `0 ≤ r ≤ n`. -/
theorem symEuler_tensor_general (m n : ℕ) (hnm : n ≤ m) (a b : R) :
    (∏ i ∈ range (m + 1), ∏ j ∈ range (n + 1),
        (1 - C (symSatake m a b i * symSatake n a b j) * X))
      = ∏ r ∈ range (n + 1), ∏ i ∈ range (m + n - 2 * r + 1),
          (1 - C ((a * b) ^ r * symSatake (m + n - 2 * r) a b i) * X) := by
  set F : ℕ → PowerSeries R := fun t => 1 - C (symSatake (m + n) a b t) * X with hF
  have hL : (∏ i ∈ range (m + 1), ∏ j ∈ range (n + 1),
      (1 - C (symSatake m a b i * symSatake n a b j) * X))
      = ∏ i ∈ range (m + 1), ∏ j ∈ range (n + 1), F (i + j) := by
    refine Finset.prod_congr rfl ?_
    intro i hi
    refine Finset.prod_congr rfl ?_
    intro j hj
    have hi' : i ≤ m := Nat.lt_succ_iff.mp (Finset.mem_range.mp hi)
    have hj' : j ≤ n := Nat.lt_succ_iff.mp (Finset.mem_range.mp hj)
    rw [satake_mul_satake m n a b i j hi' hj']
  have hR : (∏ r ∈ range (n + 1), ∏ i ∈ range (m + n - 2 * r + 1),
      (1 - C ((a * b) ^ r * symSatake (m + n - 2 * r) a b i) * X))
      = ∏ r ∈ range (n + 1), ∏ i ∈ range (m + n - 2 * r + 1), F (r + i) := by
    refine Finset.prod_congr rfl ?_
    intro r hr
    refine Finset.prod_congr rfl ?_
    intro i hi
    have hr' : r ≤ n := Nat.lt_succ_iff.mp (Finset.mem_range.mp hr)
    have hi' : i ≤ m + n - 2 * r := Nat.lt_succ_iff.mp (Finset.mem_range.mp hi)
    rw [satake_twist_gen m n a b r i hr' hnm hi']
  rw [hL, hR]
  exact prod_grid_eq F n m hnm

/-- **General Clebsch–Gordan decomposition of local L-functions.**  For `n ≤ m`,
`L(Sym^m π × Sym^n π, X) = ∏_{r=0}^{n} L(Sym^{m+n-2r} π ⊗ χ^r, X)`. -/
theorem symL_tensor_general (m n : ℕ) (hnm : n ≤ m) (a b : R) :
    (∏ i ∈ range (m + 1), ∏ j ∈ range (n + 1),
        L1 (symSatake m a b i * symSatake n a b j))
      = ∏ r ∈ range (n + 1), ∏ i ∈ range (m + n - 2 * r + 1),
          L1 ((a * b) ^ r * symSatake (m + n - 2 * r) a b i) := by
  refine inv_unique (e := ∏ i ∈ range (m + 1), ∏ j ∈ range (n + 1),
      (1 - C (symSatake m a b i * symSatake n a b j) * X)) ?_ ?_
  · rw [← Finset.prod_mul_distrib]
    refine Finset.prod_eq_one ?_
    intro i _
    rw [← Finset.prod_mul_distrib]
    exact Finset.prod_eq_one fun j _ => L1_mul_euler _
  · rw [symEuler_tensor_general m n hnm]
    rw [← Finset.prod_mul_distrib]
    refine Finset.prod_eq_one ?_
    intro r _
    rw [← Finset.prod_mul_distrib]
    exact Finset.prod_eq_one fun i _ => L1_mul_euler _

/-- The `n = 1` specialisation: `L(Sym^m π × π) = L(Sym^{m+1} π) L(Sym^{m-1} π ⊗ χ)`
in the index form produced by the general theorem. -/
theorem symEuler_tensor_general_one (m : ℕ) (hm : 1 ≤ m) (a b : R) :
    (∏ i ∈ range (m + 1), ∏ j ∈ range 2,
        (1 - C (symSatake m a b i * symSatake 1 a b j) * X))
      = ∏ r ∈ range 2, ∏ i ∈ range (m + 1 - 2 * r + 1),
          (1 - C ((a * b) ^ r * symSatake (m + 1 - 2 * r) a b i) * X) :=
  symEuler_tensor_general m 1 hm a b

/-- The diagonal case `m = n`: `L(Sym^n π × Sym^n π) = ∏_{r=0}^{n} L(Sym^{2n-2r} π ⊗ χ^r)`,
whose `r = n` factor is the local zeta factor `L(χ^n)`.  For `n = 1` this is the
Gelbart–Jacquet identity `L(π × π) = L(Sym^2 π) L(χ)`. -/
theorem symEuler_tensor_diagonal (n : ℕ) (a b : R) :
    (∏ i ∈ range (n + 1), ∏ j ∈ range (n + 1),
        (1 - C (symSatake n a b i * symSatake n a b j) * X))
      = ∏ r ∈ range (n + 1), ∏ i ∈ range (2 * n - 2 * r + 1),
          (1 - C ((a * b) ^ r * symSatake (2 * n - 2 * r) a b i) * X) := by
  have h := symEuler_tensor_general n n le_rfl a b
  rw [show n + n = 2 * n by ring] at h
  exact h

end GeneralTransfer

end Langlands