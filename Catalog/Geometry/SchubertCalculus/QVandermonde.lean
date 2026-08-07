/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.SchubertCalculus.FiniteField

/-!
# Schubert calculus VII: the q-Vandermonde convolution

This file settles sub-conjecture **(C3′)** of the previous research cycle: the ratio formula
`poincare_mul_qFact` and the product formula `poincare_mul_gaussProd` are both shadows of a
single *convolution* identity for the Gaussian binomial coefficients, namely the
**q-Vandermonde (Chu–Vandermonde) convolution**

`[m + n choose k]_q = ∑_{a + b = k} q^{(m-a) b} · [m choose a]_q · [n choose b]_q`.

Geometrically this is the decomposition of the Grassmannian `Gr(k, U ⊕ W)` according to
`a = dim (X ∩ U)`: the stratum with `dim (X ∩ U) = a` fibres over
`Gr(a, U) × Gr(b, W)` (`b = k - a`) with affine fibre `Hom(W-part, U/(X ∩ U))` of dimension
`(m - a) · b`.  The identity proved here is the point-count / Poincaré-polynomial shadow of
that stratification, and it is proved over an *arbitrary commutative semiring* by induction
from the `q`-Pascal recursion `poincare_succ`.

Main results:

* `SchubertCalculus.poincare_add` — the q-Vandermonde convolution;
* `SchubertCalculus.poincare_add_symm` — the resulting `m ↔ n` symmetry of the convolution,
  which is *not* visible term by term (the exponent `(m-a)b` is not symmetric);
* `SchubertCalculus.choose_add_convolution` — the classical Vandermonde convolution
  `(m+n).choose k = ∑_{a+b=k} m.choose a · n.choose b`, obtained by setting `q = 1`;
* `SchubertCalculus.poincare_succ_of_add` — the `q`-Pascal recursion recovered as the case
  `n = 1`, confirming that the convolution really is a strengthening of the recursion it was
  proved from;
* `SchubertCalculus.card_grassmannian_add` — the geometric form: over a finite field, the
  point count of `Gr(k, V)` for `dim V = m + n` is the above convolution of the point counts
  of `Gr(a, 𝔽_q^m)` and `Gr(b, 𝔽_q^n)`.
-/

namespace SchubertCalculus

open Finset

variable {R : Type*} [CommSemiring R] (q : R)

/-! ### The key exponent bookkeeping -/

/-- The arithmetic heart of the induction: for `a + c = k` with `a ≤ m` and `c ≤ n`,
`(m - a)(c + 1) + (n - c) = (m + n - k) + (m - a) c`.  This is what makes the global
prefactor `q^{m+n-k}` produced by `q`-Pascal on `Gr(k, m+n)` agree, term by term, with the
local prefactors `q^{(m-a)(c+1)}` and `q^{n-c}` produced by `q`-Pascal in the two factors. -/
lemma qvandermonde_exponent {m n k a c : ℕ} (ham : a ≤ m) (hcn : c ≤ n) (hac : a + c = k) :
    (m - a) * (c + 1) + (n - c) = (m + n - k) + (m - a) * c := by
  rw [Nat.mul_succ]; omega

/-- The shift lemma driving the induction: multiplying the `k`-th convolution by the Pascal
prefactor `q^{m+n-k}` is the same as applying, inside each term, the Pascal prefactor of the
second factor.  Terms in which either Gaussian binomial vanishes are handled separately, so no
hypothesis `k ≤ m + n` is needed. -/
lemma mul_pow_sum_antidiagonal (m n k : ℕ) :
    q ^ (m + n - k) *
        ∑ p ∈ Finset.antidiagonal k,
          q ^ ((m - p.1) * p.2) * poincare R p.1 m q * poincare R p.2 n q
      = ∑ p ∈ Finset.antidiagonal k,
          q ^ ((m - p.1) * (p.2 + 1)) * poincare R p.1 m q *
            (q ^ (n - p.2) * poincare R p.2 n q) := by
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl ?_
  rintro ⟨a, c⟩ hp
  have hac : a + c = k := Finset.mem_antidiagonal.mp hp
  by_cases ham : m < a
  · rw [poincare_eq_zero q ham]; ring
  by_cases hcn : n < c
  · rw [poincare_eq_zero q hcn]; ring
  push_neg at ham hcn
  have hexp := qvandermonde_exponent ham hcn hac
  have hL : q ^ (m + n - k) *
      (q ^ ((m - a) * c) * poincare R a m q * poincare R c n q)
      = q ^ ((m + n - k) + (m - a) * c) * (poincare R a m q * poincare R c n q) := by
    rw [pow_add]; ring
  have hR : q ^ ((m - a) * (c + 1)) * poincare R a m q * (q ^ (n - c) * poincare R c n q)
      = q ^ ((m - a) * (c + 1) + (n - c)) * (poincare R a m q * poincare R c n q) := by
    rw [pow_add]; ring
  simp only []
  rw [hL, hR, hexp]

/-! ### The convolution -/

/-- **The q-Vandermonde convolution.**
`[m + n choose k]_q = ∑_{a + b = k} q^{(m-a)·b} · [m choose a]_q · [n choose b]_q`,
over an arbitrary commutative semiring and with no restriction on `k`, `m`, `n`.

Geometrically: stratifying `Gr(k, U ⊕ W)` (with `dim U = m`, `dim W = n`) by
`a = dim (X ∩ U)` gives strata that are affine bundles of rank `(m - a)(k - a)` over
`Gr(a, U) × Gr(k - a, W)`. -/
theorem poincare_add (k m n : ℕ) :
    poincare R k (m + n) q =
      ∑ p ∈ Finset.antidiagonal k,
        q ^ ((m - p.1) * p.2) * poincare R p.1 m q * poincare R p.2 n q := by
  induction n generalizing k with
  | zero =>
    have hzero : ∀ p ∈ Finset.antidiagonal k, p ≠ (k, 0) →
        q ^ ((m - p.1) * p.2) * poincare R p.1 m q * poincare R p.2 0 q = 0 := by
      rintro ⟨a, b⟩ hp hne
      have hab : a + b = k := Finset.mem_antidiagonal.mp hp
      have hb : 0 < b := by
        rcases Nat.eq_zero_or_pos b with rfl | hb
        · exact absurd (by simp only [Nat.add_zero] at hab; rw [hab]) hne
        · exact hb
      rw [poincare_eq_zero q hb, mul_zero]
    rw [Nat.add_zero,
      Finset.sum_eq_single_of_mem (s := Finset.antidiagonal k) (f := fun p : ℕ × ℕ =>
          q ^ ((m - p.1) * p.2) * poincare R p.1 m q * poincare R p.2 0 q)
        (k, 0) (Finset.mem_antidiagonal.mpr rfl) hzero]
    simp
  | succ n ih =>
    match k with
    | 0 => simp
    | (k + 1) =>
      have hassoc : m + (n + 1) = (m + n) + 1 := by omega
      rw [hassoc, poincare_succ, ih (k + 1), ih k,
        Finset.Nat.sum_antidiagonal_succ'
          (f := fun p : ℕ × ℕ =>
            q ^ ((m - p.1) * p.2) * poincare R p.1 m q * poincare R p.2 n q),
        Finset.Nat.sum_antidiagonal_succ'
          (f := fun p : ℕ × ℕ =>
            q ^ ((m - p.1) * p.2) * poincare R p.1 m q * poincare R p.2 (n + 1) q)]
      simp only [Nat.mul_zero, pow_zero, poincare_zero_left, mul_one, one_mul]
      rw [add_assoc]
      congr 1
      have hsucc : ∀ p ∈ Finset.antidiagonal k,
          q ^ ((m - p.1) * (p.2 + 1)) * poincare R p.1 m q * poincare R (p.2 + 1) (n + 1) q
            = q ^ ((m - p.1) * (p.2 + 1)) * poincare R p.1 m q * poincare R (p.2 + 1) n q
              + q ^ ((m - p.1) * (p.2 + 1)) * poincare R p.1 m q *
                  (q ^ (n - p.2) * poincare R p.2 n q) := by
        intro p _
        rw [poincare_succ, mul_add]
      rw [Finset.sum_congr rfl hsucc, Finset.sum_add_distrib,
        mul_pow_sum_antidiagonal q m n k]

/-- The `m ↔ n` symmetry of the q-Vandermonde convolution.  Each side is the Poincaré
polynomial of the *same* Grassmannian, but the two expressions differ term by term: the
exponent `(m - a)·b` is not symmetric in `m` and `n`. -/
theorem poincare_add_symm (k m n : ℕ) :
    ∑ p ∈ Finset.antidiagonal k,
        q ^ ((m - p.1) * p.2) * poincare R p.1 m q * poincare R p.2 n q
      = ∑ p ∈ Finset.antidiagonal k,
        q ^ ((n - p.1) * p.2) * poincare R p.1 n q * poincare R p.2 m q := by
  rw [← poincare_add q k m n, ← poincare_add q k n m, Nat.add_comm]

/-- The `q`-Pascal recursion is the case `n = 1` of the convolution: the Grassmannian of a
space split off a line.  (Proved *from* the convolution, so this is a genuine consistency
check that the convolution strengthens the recursion it was derived from.) -/
theorem poincare_succ_of_add (k m : ℕ) :
    poincare R (k + 1) (m + 1) q =
      poincare R (k + 1) m q + q ^ (m - k) * poincare R k m q := by
  rw [poincare_add q (k + 1) m 1, Finset.Nat.sum_antidiagonal_succ'
        (f := fun p : ℕ × ℕ =>
          q ^ ((m - p.1) * p.2) * poincare R p.1 m q * poincare R p.2 1 q)]
  have hzero : ∀ p ∈ Finset.antidiagonal k, p ≠ (k, 0) →
      q ^ ((m - p.1) * (p.2 + 1)) * poincare R p.1 m q * poincare R (p.2 + 1) 1 q = 0 := by
    rintro ⟨a, b⟩ hp hne
    have hab : a + b = k := Finset.mem_antidiagonal.mp hp
    have hb : 1 < b + 1 := by
      rcases Nat.eq_zero_or_pos b with rfl | hb
      · exact absurd (by simp only [Nat.add_zero] at hab; rw [hab]) hne
      · omega
    rw [poincare_eq_zero q hb, mul_zero]
  dsimp only
  rw [Finset.sum_eq_single_of_mem (s := Finset.antidiagonal k) (f := fun p : ℕ × ℕ =>
        q ^ ((m - p.1) * (p.2 + 1)) * poincare R p.1 m q * poincare R (p.2 + 1) 1 q)
      (k, 0) (Finset.mem_antidiagonal.mpr rfl) hzero]
  have hset : Finset.powersetCard 1 (Finset.range 1) = {{0}} := by decide
  have h1 : poincare R 1 1 q = 1 := by
    rw [poincare, hset]
    simp [dimCell]
  simp [h1]

/-- **Vandermonde's convolution** for ordinary binomial coefficients, recovered at `q = 1`
(i.e. by counting Schubert cells rather than points). -/
theorem choose_add_convolution (k m n : ℕ) :
    (m + n).choose k = ∑ p ∈ Finset.antidiagonal k, m.choose p.1 * n.choose p.2 := by
  have h := poincare_add (R := ℕ) 1 k m n
  simpa [poincare_one, one_pow] using h

/-! ### Geometric form over a finite field -/

open Module

variable {K : Type*} [Field K] {V : Type*} [AddCommGroup V] [Module K V]
  [FiniteDimensional K V]

/-- **Geometric q-Vandermonde.**  If `dim V = m + n` over a finite field `K` with `q`
elements, then the number of `k`-dimensional subspaces of `V` is
`∑_{a+b=k} q^{(m-a)b} · #Gr(a, K^m) · #Gr(b, K^n)`.

This is the point count of the stratification of `Gr(k, U ⊕ W)` by `dim (X ∩ U)`, for any
splitting `V = U ⊕ W` with `dim U = m`, `dim W = n`. -/
theorem card_grassmannian_add [Fintype K] {k m n : ℕ} (hV : finrank K V = m + n)
    (hk : k ≤ m + n) :
    Nat.card {W : Submodule K V // finrank K W = k}
      = ∑ p ∈ Finset.antidiagonal k,
          Fintype.card K ^ ((m - p.1) * p.2) *
            poincare ℕ p.1 m (Fintype.card K) * poincare ℕ p.2 n (Fintype.card K) := by
  rw [card_grassmannian_eq_poincare (K := K) (V := V) (by omega), hV,
    poincare_add (R := ℕ) (Fintype.card K) k m n]

/-! ### Numerical checks -/

/-- `Gr(2, 4)` over `𝔽₂` from the splitting `4 = 2 + 2`:
`35 = 1·1·6 + 2·3·3 + 1·6·1`. -/
theorem poincare_two_four_two_split :
    ∑ p ∈ Finset.antidiagonal 2,
        (2 : ℕ) ^ ((2 - p.1) * p.2) * poincare ℕ p.1 2 2 * poincare ℕ p.2 2 2 = 35 := by
  rw [← poincare_add (R := ℕ) 2 2 2 2]
  decide

/-- `Gr(3, 6)` over `𝔽₂` from the splitting `6 = 4 + 2`: `1395` points. -/
theorem poincare_three_six_two_split :
    ∑ p ∈ Finset.antidiagonal 3,
        (2 : ℕ) ^ ((4 - p.1) * p.2) * poincare ℕ p.1 4 2 * poincare ℕ p.2 2 2 = 1395 := by
  rw [← poincare_add (R := ℕ) 2 3 4 2]
  decide

end SchubertCalculus