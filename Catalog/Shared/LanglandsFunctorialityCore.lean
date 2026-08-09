import Mathlib

/-!
# Langlands functoriality, I: Satake parameters, Hecke eigenvalues and local L-factors

This file develops, over an arbitrary commutative ring, the algebraic skeleton of the
local theory that underlies the Langlands program for `GL(2)`:

* the **Satake parameters** `(a, b)` of an unramified local representation of `GL(2)`;
* the associated **Hecke eigenvalue sequence** `hecke a b k` (the coefficient of the local
  L-function at `p ^ k`), defined by the classical degree-two recursion
  `a_{p^{k+2}} = a_p * a_{p^{k+1}} - χ(p) * a_{p^k}`;
* the **local L-function** as a formal power series, and the fact that it is the inverse of
  the degree-two Euler factor `(1 - a X)(1 - b X)`;
* the **Clebsch–Gordan / Hecke multiplicativity** identity
  `h_{n+d} * h_n = ∑_{i ≤ n} (ab)^{n-i} h_{d + 2i}`,
  which is the Satake-parameter shadow of the decomposition
  `Sym^m ⊗ Sym^n = ⊕_j Sym^{m+n-2j} ⊗ det^j`, and hence the local engine of functoriality;
* the **Ramanujan bound** `‖h_k‖ ≤ k + 1` for tempered (unitary) Satake parameters.

The general power-series lemma `PowerSeriesRecursion.mk_mul_eulerFactor` records the exact
equivalence "linear recursion of Hecke eigenvalues ↔ rationality of the local L-series with
prescribed Euler factor"; it is the workhorse for the `GL(3)` and `GL(4)` transfers in
`LanglandsSymmetricPower.lean`.
-/

namespace Langlands

open Finset PowerSeries

section PowerSeriesTools

variable {R : Type*} [CommRing R]

/-- Coefficient of `mk u * (C c * X ^ j)`: a shifted, scaled coefficient of `u`. -/
lemma coeff_mk_mul_CX (u : ℕ → R) (c : R) (j m : ℕ) :
    coeff m (PowerSeries.mk u * (C c * X ^ j)) = if j ≤ m then c * u (m - j) else 0 := by
  rw [show PowerSeries.mk u * (C c * X ^ j) = (C c * PowerSeries.mk u) * X ^ j by ring,
    coeff_mul_X_pow']
  split <;> simp

/-- Coefficient of a monomial `C a * X ^ j`. -/
lemma coeff_CX (a : R) (j m : ℕ) : coeff m (C a * X ^ j) = if m = j then a else 0 := by
  rw [coeff_C_mul, coeff_X_pow]; split <;> simp

/-- **Rationality from a linear recursion.**  If the sequence `u` satisfies the linear
recursion whose characteristic polynomial has coefficients `e 0, …, e d`, then the generating
series `∑ u k X ^ k` multiplied by the Euler factor `∑_{j ≤ d} e j X ^ j` is a polynomial of
degree `< d`, with explicitly computed coefficients.  This is the formal statement that a
local L-function is the reciprocal of a polynomial of degree `d`. -/
theorem mk_mul_eulerFactor (u : ℕ → R) (e : ℕ → R) (d : ℕ) (B : ℕ → R)
    (hB : ∀ m, B m = ∑ j ∈ range (m + 1), e j * u (m - j))
    (hrec : ∀ k, ∑ j ∈ range (d + 1), e j * u (k + d - j) = 0) :
    PowerSeries.mk u * (∑ j ∈ range (d + 1), C (e j) * X ^ j)
      = ∑ m ∈ range d, C (B m) * X ^ m := by
  ext m
  rw [Finset.mul_sum]
  simp only [map_sum, coeff_mk_mul_CX, coeff_CX]
  by_cases hm : m < d
  · -- low-degree coefficients: both sides are the truncated convolution
    have hR : ∑ m' ∈ range d, (if m = m' then B m' else 0) = B m := by
      rw [Finset.sum_ite_eq (range d) m B, if_pos (Finset.mem_range.mpr hm)]
    have hL : ∑ j ∈ range (d + 1), (if j ≤ m then e j * u (m - j) else 0) = B m := by
      have hcast : ∀ j ∈ range (d + 1), (if j ≤ m then e j * u (m - j) else 0)
          = if j ∈ range (m + 1) then e j * u (m - j) else 0 := by
        intro j _
        simp
      rw [Finset.sum_congr rfl hcast, Finset.sum_ite_mem,
        Finset.inter_eq_right.mpr (by
          intro x hx
          simp only [Finset.mem_range] at hx ⊢
          omega), hB]
    rw [hL, hR]
  · -- high-degree coefficients: the recursion makes them vanish
    push_neg at hm
    have hzero : ∑ j ∈ range (d + 1), (if j ≤ m then e j * u (m - j) else 0) = 0 := by
      have hshift : ∀ j ∈ range (d + 1), (if j ≤ m then e j * u (m - j) else 0)
          = e j * u ((m - d) + d - j) := by
        intro j hj
        have hjd : j ≤ d := Nat.lt_succ_iff.mp (Finset.mem_range.mp hj)
        have hjm : j ≤ m := le_trans hjd hm
        rw [if_pos hjm, Nat.sub_add_cancel hm]
      rw [Finset.sum_congr rfl hshift]
      exact hrec (m - d)
    rw [hzero, Finset.sum_eq_zero]
    intro m' hm'
    have hne : ¬ (m = m') := by
      have := Finset.mem_range.mp hm'
      omega
    simp [hne]

/-- Rationality of a local L-series attached to a degree-two linear recursion. -/
theorem mk_mul_quadratic (u : ℕ → R) (c1 c2 : R)
    (h : ∀ k, u (k + 2) = c1 * u (k + 1) - c2 * u k) :
    PowerSeries.mk u * (1 - C c1 * X + C c2 * X ^ 2)
      = C (u 0) * X ^ 0 + C (u 1 - c1 * u 0) * X ^ 1 := by
  have expand : PowerSeries.mk u * (1 - C c1 * X + C c2 * X ^ 2)
      = PowerSeries.mk u * (C 1 * X ^ 0) - PowerSeries.mk u * (C c1 * X ^ 1)
        + PowerSeries.mk u * (C c2 * X ^ 2) := by
    simp [pow_zero, pow_one]; ring
  set A0 : R := u 0 with hA0
  set A1 : R := u 1 - c1 * u 0 with hA1
  ext m
  rw [expand]
  simp only [map_sub, map_add, coeff_mk_mul_CX, coeff_CX]
  match m with
  | 0 => simp [hA0]
  | 1 => simp [hA1]
  | (n + 2) =>
      have hn := h n
      simp only [show n + 2 - 1 = n + 1 from rfl, show n + 2 - 2 = n from rfl,
        show n + 2 - 0 = n + 2 from rfl]
      simp
      linear_combination hn

/-- Rationality of a local L-series attached to a degree-three linear recursion:
the GL(3) shape. -/
theorem mk_mul_cubic (u : ℕ → R) (c1 c2 c3 : R)
    (h : ∀ k, u (k + 3) = c1 * u (k + 2) - c2 * u (k + 1) + c3 * u k) :
    PowerSeries.mk u * (1 - C c1 * X + C c2 * X ^ 2 - C c3 * X ^ 3)
      = C (u 0) * X ^ 0 + C (u 1 - c1 * u 0) * X ^ 1
        + C (u 2 - c1 * u 1 + c2 * u 0) * X ^ 2 := by
  have expand : PowerSeries.mk u * (1 - C c1 * X + C c2 * X ^ 2 - C c3 * X ^ 3)
      = PowerSeries.mk u * (C 1 * X ^ 0) - PowerSeries.mk u * (C c1 * X ^ 1)
        + PowerSeries.mk u * (C c2 * X ^ 2) - PowerSeries.mk u * (C c3 * X ^ 3) := by
    simp [pow_zero, pow_one]; ring
  set A0 : R := u 0 with hA0
  set A1 : R := u 1 - c1 * u 0 with hA1
  set A2 : R := u 2 - c1 * u 1 + c2 * u 0 with hA2
  ext m
  rw [expand]
  simp only [map_sub, map_add, coeff_mk_mul_CX, coeff_CX]
  match m with
  | 0 => simp [hA0]
  | 1 => simp [hA1]
  | 2 => simp [hA2]
  | (n + 3) =>
      have hn := h n
      simp only [show n + 3 - 1 = n + 2 from rfl, show n + 3 - 2 = n + 1 from rfl,
        show n + 3 - 3 = n from rfl, show n + 3 - 0 = n + 3 from rfl]
      simp
      linear_combination hn

/-- Rationality of a local L-series attached to a degree-four linear recursion:
the GL(4) shape. -/
theorem mk_mul_quartic (u : ℕ → R) (c1 c2 c3 c4 : R)
    (h : ∀ k, u (k + 4) = c1 * u (k + 3) - c2 * u (k + 2) + c3 * u (k + 1) - c4 * u k) :
    PowerSeries.mk u * (1 - C c1 * X + C c2 * X ^ 2 - C c3 * X ^ 3 + C c4 * X ^ 4)
      = C (u 0) * X ^ 0 + C (u 1 - c1 * u 0) * X ^ 1
        + C (u 2 - c1 * u 1 + c2 * u 0) * X ^ 2
        + C (u 3 - c1 * u 2 + c2 * u 1 - c3 * u 0) * X ^ 3 := by
  have expand : PowerSeries.mk u * (1 - C c1 * X + C c2 * X ^ 2 - C c3 * X ^ 3 + C c4 * X ^ 4)
      = PowerSeries.mk u * (C 1 * X ^ 0) - PowerSeries.mk u * (C c1 * X ^ 1)
        + PowerSeries.mk u * (C c2 * X ^ 2) - PowerSeries.mk u * (C c3 * X ^ 3)
        + PowerSeries.mk u * (C c4 * X ^ 4) := by
    simp [pow_zero, pow_one]; ring
  set A0 : R := u 0 with hA0
  set A1 : R := u 1 - c1 * u 0 with hA1
  set A2 : R := u 2 - c1 * u 1 + c2 * u 0 with hA2
  set A3 : R := u 3 - c1 * u 2 + c2 * u 1 - c3 * u 0 with hA3
  ext m
  rw [expand]
  simp only [map_sub, map_add, coeff_mk_mul_CX, coeff_CX]
  match m with
  | 0 => simp [hA0]
  | 1 => simp [hA1]
  | 2 => simp [hA2]
  | 3 => simp [hA3]
  | (n + 4) =>
      have hn := h n
      simp only [show n + 4 - 1 = n + 3 from rfl, show n + 4 - 2 = n + 2 from rfl,
        show n + 4 - 3 = n + 1 from rfl, show n + 4 - 4 = n from rfl,
        show n + 4 - 0 = n + 4 from rfl]
      simp
      linear_combination hn

end PowerSeriesTools

section Hecke

variable {R : Type*} [CommRing R]

/-- The Hecke eigenvalue sequence attached to a pair of Satake parameters `(a, b)`:
`hecke a b k` is the coefficient of the local L-function of an unramified representation of
`GL(2)` at `p ^ k`, i.e. the complete homogeneous symmetric polynomial `h_k (a, b)`. -/
def hecke (a b : R) : ℕ → R
  | 0 => 1
  | 1 => a + b
  | (k + 2) => (a + b) * hecke a b (k + 1) - (a * b) * hecke a b k

@[simp] lemma hecke_zero (a b : R) : hecke a b 0 = 1 := rfl

@[simp] lemma hecke_one (a b : R) : hecke a b 1 = a + b := rfl

lemma hecke_add_two (a b : R) (k : ℕ) :
    hecke a b (k + 2) = (a + b) * hecke a b (k + 1) - (a * b) * hecke a b k := rfl

/-- The Hecke relation in the form `a_p · a_{p^{k+1}} = a_{p^{k+2}} + χ(p) · a_{p^k}`. -/
lemma hecke_mul_hecke_one (a b : R) (k : ℕ) :
    hecke a b 1 * hecke a b (k + 1) = hecke a b (k + 2) + (a * b) * hecke a b k := by
  rw [hecke_add_two, hecke_one]; ring

/-- **Master identity.**  For all `n, d`:
`h_{n+d+1} h_{n+1} = (ab) · h_{n+d} h_n + h_{2n+d+2}`.
This single two-parameter identity contains every Clebsch–Gordan relation for the
Satake parameters of `GL(2)`; the proof is an induction on `n` with `d` universally
quantified, feeding the inductive hypothesis back at both `d` and `d + 1`. -/
theorem hecke_master (a b : R) : ∀ n d : ℕ,
    hecke a b (n + d + 1) * hecke a b (n + 1)
      = (a * b) * (hecke a b (n + d) * hecke a b n) + hecke a b (2 * n + d + 2) := by
  intro n
  induction n with
  | zero =>
      intro d
      have h := hecke_add_two a b d
      simp only [Nat.zero_add, hecke_zero, hecke_one, mul_one]
      rw [show 2 * 0 + d + 2 = d + 2 by ring]
      rw [h]; ring
  | succ n ih =>
      intro d
      have i1 := ih (d + 1)
      have i2 := ih d
      have r1 := hecke_add_two a b n
      have r2 := hecke_add_two a b (n + d)
      have r3 := hecke_add_two a b (2 * n + d + 2)
      rw [show n + 1 + d + 1 = n + d + 2 by ring, show n + 1 + 1 = n + 2 by ring,
        show n + 1 + d = n + d + 1 by ring, show 2 * (n + 1) + d + 2 = 2 * n + d + 4 by ring]
      rw [show n + (d + 1) + 1 = n + d + 2 by ring, show n + (d + 1) = n + d + 1 by ring,
        show 2 * n + (d + 1) + 2 = 2 * n + d + 3 by ring] at i1
      rw [show n + d + 2 = n + d + 2 from rfl] at r2
      rw [show 2 * n + d + 2 + 2 = 2 * n + d + 4 by ring,
        show 2 * n + d + 2 + 1 = 2 * n + d + 3 by ring] at r3
      rw [show n + d + 1 + 1 = n + d + 2 by ring] at r2
      linear_combination (hecke a b (n + d + 2)) * r1 - r3 + (a + b) * i1 - (a * b) * i2
        - (a * b) * hecke a b n * r2

/-- **Clebsch–Gordan for Satake parameters** (Hecke multiplicativity).
`h_{n+d} · h_n = ∑_{i=0}^{n} (ab)^{n-i} h_{d + 2i}`.

This is the local avatar of `Sym^{n+d} ⊗ Sym^n = ⊕_{i=0}^{n} Sym^{d+2i} ⊗ det^{n-i}`,
i.e. of the Rankin–Selberg decomposition of a product of two Hecke eigenvalues. -/
theorem hecke_clebsch_gordan (a b : R) : ∀ n d : ℕ,
    hecke a b (n + d) * hecke a b n
      = ∑ i ∈ range (n + 1), (a * b) ^ (n - i) * hecke a b (d + 2 * i) := by
  intro n
  induction n with
  | zero => intro d; simp
  | succ n ih =>
      intro d
      have hm := hecke_master a b n d
      rw [show n + 1 + d = n + d + 1 by ring]
      rw [hm, ih d, Finset.mul_sum,
        Finset.sum_range_succ (f := fun i => (a * b) ^ (n + 1 - i) * hecke a b (d + 2 * i)) (n := n + 1)]
      have hstep : ∀ i ∈ range (n + 1),
          (a * b) * ((a * b) ^ (n - i) * hecke a b (d + 2 * i))
            = (a * b) ^ (n + 1 - i) * hecke a b (d + 2 * i) := by
        intro i hi
        have hin : i ≤ n := Nat.lt_succ_iff.mp (Finset.mem_range.mp hi)
        rw [← mul_assoc, ← pow_succ']
        congr 2
        omega
      rw [Finset.sum_congr rfl hstep]
      congr 1
      rw [show n + 1 - (n + 1) = 0 by omega, pow_zero, one_mul]
      congr 1
      omega

/-- The Hecke square identity `h_{n+1}^2 - (ab) h_n^2 = h_{2n+2}`, the `d = 0` case of the
master identity.  It is the local Rankin–Selberg relation `a_{p^n}^2 = ∑_j χ(p)^j a_{p^{2n-2j}}`
in telescoped form. -/
theorem hecke_sq_sub (a b : R) (n : ℕ) :
    hecke a b (n + 1) ^ 2 - (a * b) * hecke a b n ^ 2 = hecke a b (2 * n + 2) := by
  have h := hecke_master a b n 0
  simp only [Nat.add_zero] at h
  linear_combination h

/-- Two-step recursion for the even-indexed Hecke eigenvalues: they are the Hecke
eigenvalues of the Satake pair `(a^2, b^2)`. -/
theorem hecke_even_rec (a b : R) (m : ℕ) :
    hecke a b (m + 4) = (a ^ 2 + b ^ 2) * hecke a b (m + 2) - (a * b) ^ 2 * hecke a b m := by
  have r1 := hecke_add_two a b (m + 2)
  have r2 := hecke_add_two a b (m + 1)
  have r3 := hecke_add_two a b m
  rw [show m + 2 + 2 = m + 4 by ring, show m + 2 + 1 = m + 3 by ring] at r1
  rw [show m + 1 + 2 = m + 3 by ring, show m + 1 + 1 = m + 2 by ring] at r2
  linear_combination r1 + (a + b) * r2 + (a * b) * r3

end Hecke

section LSeries

variable {R : Type*} [CommRing R]

/-- The local L-series of the unramified `GL(2)`-representation with Satake parameters
`(a, b)`: the generating series `∑ a_{p^k} X^k`. -/
noncomputable def L2 (a b : R) : PowerSeries R := mk (hecke a b)

/-- The geometric series `∑ c^k X^k`, i.e. the local L-function of a `GL(1)` character. -/
noncomputable def L1 (c : R) : PowerSeries R := mk fun k => c ^ k

/-- The `GL(1)` local L-function inverts its Euler factor. -/
theorem L1_mul_euler (c : R) : L1 c * (1 - C c * X) = 1 := by
  ext n
  cases n with
  | zero => simp [L1]
  | succ m => simp [L1, mul_sub, mul_comm, mul_left_comm, pow_succ]

/-- **The GL(2) local L-function inverts the degree-two Euler factor.**
`(∑_k a_{p^k} X^k) · (1 - a X)(1 - b X) = 1`. -/
theorem L2_mul_euler (a b : R) : L2 a b * ((1 - C a * X) * (1 - C b * X)) = 1 := by
  have key := mk_mul_quadratic (hecke a b) (a + b) (a * b) (fun k => hecke_add_two a b k)
  rw [show (1 - C a * X) * (1 - C b * X) = 1 - C (a + b) * X + C (a * b) * X ^ 2 by
    rw [map_add, map_mul]; ring]
  rw [L2, key]
  simp

/-- Inverses in a commutative power series ring are unique. -/
lemma inv_unique {f g e : PowerSeries R} (hf : f * e = 1) (hg : g * e = 1) : f = g := by
  calc f = f * (e * g) := by rw [mul_comm e g, hg, mul_one]
  _ = (f * e) * g := by ring
  _ = g := by rw [hf, one_mul]

/-- **Factorisation of the GL(2) local L-function into GL(1) factors.**
`L(π, X) = L(a, X) · L(b, X)`; equivalently the Hecke eigenvalues are the complete
homogeneous symmetric functions of the Satake parameters. -/
theorem L2_eq_L1_mul_L1 (a b : R) : L2 a b = L1 a * L1 b := by
  refine inv_unique (e := (1 - C a * X) * (1 - C b * X)) (L2_mul_euler a b) ?_
  calc L1 a * L1 b * ((1 - C a * X) * (1 - C b * X))
      = (L1 a * (1 - C a * X)) * (L1 b * (1 - C b * X)) := by ring
    _ = 1 := by rw [L1_mul_euler, L1_mul_euler, mul_one]

/-- **Closed form for the Hecke eigenvalues**: `a_{p^k} = ∑_{i+j=k} a^i b^j`. -/
theorem hecke_eq_antidiagonal_sum (a b : R) (k : ℕ) :
    hecke a b k = ∑ ij ∈ Finset.antidiagonal k, a ^ ij.1 * b ^ ij.2 := by
  have h := congrArg (fun f => coeff k f) (L2_eq_L1_mul_L1 a b)
  simpa [L2, L1, coeff_mul] using h

/-- **Closed form, single-index version**: `a_{p^k} = ∑_{i=0}^{k} a^i b^{k-i}`. -/
theorem hecke_eq_sum_range (a b : R) (k : ℕ) :
    hecke a b k = ∑ i ∈ range (k + 1), a ^ i * b ^ (k - i) := by
  rw [hecke_eq_antidiagonal_sum, Finset.Nat.sum_antidiagonal_eq_sum_range_succ
    (f := fun i j => a ^ i * b ^ j)]

end LSeries

section Ramanujan

/-- **Ramanujan–Petersson bound at a tempered place.**  If the Satake parameters are unitary
(`‖a‖ = ‖b‖ = 1`, the temperedness condition), then `‖a_{p^k}‖ ≤ k + 1`. -/
theorem hecke_norm_le (a b : ℂ) (ha : ‖a‖ = 1) (hb : ‖b‖ = 1) (k : ℕ) :
    ‖hecke a b k‖ ≤ k + 1 := by
  rw [hecke_eq_sum_range]
  calc ‖∑ i ∈ range (k + 1), a ^ i * b ^ (k - i)‖
      ≤ ∑ i ∈ range (k + 1), ‖a ^ i * b ^ (k - i)‖ := norm_sum_le _ _
    _ = ∑ i ∈ range (k + 1), (1 : ℝ) := by
        refine Finset.sum_congr rfl ?_
        intro i _
        rw [norm_mul, norm_pow, norm_pow, ha, hb, one_pow, one_pow, one_mul]
    _ = k + 1 := by simp

end Ramanujan

end Langlands