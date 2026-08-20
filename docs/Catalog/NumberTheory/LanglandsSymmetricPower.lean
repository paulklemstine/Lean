import Catalog.Shared.LanglandsFunctorialityCore

/-!
# Langlands functoriality, II: symmetric power liftings and the GL(2) → GL(3) transfer

Building on `Shared.LanglandsFunctorialityCore`, this file constructs the symmetric power
liftings of an unramified `GL(2)` representation at the level of Satake parameters and local
L-functions, and proves the defining properties of the transfers

* `Sym^1` : the identity transfer `GL(2) → GL(2)`;
* `Sym^2` : the **Gelbart–Jacquet lift** `GL(2) → GL(3)`;
* `Sym^3` : the symmetric cube lift `GL(2) → GL(4)`.

The main results are:

* `symL_mul_symEuler` — the Sym^n L-factor inverts the degree `n+1` Euler polynomial;
* `symEuler_two_eq`, `gelbart_jacquet` — the GL(3) Euler factor of `Sym^2 π` has coefficients
  that are *polynomials in the GL(2) Hecke eigenvalues*: `b_p = a_p^2 - χ(p)`,
  `b_{p^2}`-coefficient `= χ(p) b_p`, `det = χ(p)^3`; consequently the Dirichlet coefficients
  of `L(s, Sym^2 π)` satisfy the GL(3) three-term recursion, which is the local statement of
  the Gelbart–Jacquet functorial transfer;
* `symEuler_three_eq`, `symcube_transfer` — the same for the symmetric cube on `GL(4)`;
* `rankin_selberg_sym_two` — the local Rankin–Selberg identity
  `∑_k a_{p^k}^2 X^k · L(Sym^2, X)^{-1} = 1 + χ(p) X`, i.e.
  `L(s, π × π) = ζ_p(s, χ) · L(s, Sym^2 π)` after removing the `ζ`-factor;
* `symL_coeff_one` — the transferred `p`-th Hecke eigenvalue of `Sym^n π` is `h_n(a, b)`;
* `sym_tempered` — temperedness is preserved by every symmetric power lift;
* `symSatake_selfdual`, `symEuler_two_selfdual` — self-duality of the lifts of a
  representation with trivial central character.
-/

namespace Langlands

open Finset PowerSeries

section SymmetricPower

variable {R : Type*} [CommRing R]

/-- The Satake parameters of the `n`-th symmetric power lift: the multiset
`{a^i b^{n-i} : 0 ≤ i ≤ n}`, i.e. the image of the Satake matrix `diag(a,b)` under
`Sym^n : GL(2,ℂ) → GL(n+1,ℂ)`. -/
def symSatake (n : ℕ) (a b : R) (i : ℕ) : R := a ^ i * b ^ (n - i)

/-- The local L-factor of the `n`-th symmetric power lift. -/
noncomputable def symL (n : ℕ) (a b : R) : PowerSeries R :=
  ∏ i ∈ range (n + 1), L1 (symSatake n a b i)

/-- The Euler polynomial of the `n`-th symmetric power lift (degree `n + 1`). -/
noncomputable def symEuler (n : ℕ) (a b : R) : PowerSeries R :=
  ∏ i ∈ range (n + 1), (1 - C (symSatake n a b i) * X)

/-- **The symmetric power L-factor inverts its Euler polynomial.** -/
theorem symL_mul_symEuler (n : ℕ) (a b : R) : symL n a b * symEuler n a b = 1 := by
  rw [symL, symEuler, ← Finset.prod_mul_distrib]
  refine Finset.prod_eq_one ?_
  intro i _
  exact L1_mul_euler _

/-- `Sym^0` is the trivial lift: its L-factor is the local zeta factor. -/
theorem symL_zero (a b : R) : symL 0 a b = L1 1 := by
  simp [symL, symSatake]

/-- `Sym^1` is the identity transfer: it returns the original `GL(2)` L-function. -/
theorem symL_one (a b : R) : symL 1 a b = L2 a b := by
  rw [symL, L2_eq_L1_mul_L1]
  rw [Finset.prod_range_succ, Finset.prod_range_one]
  simp [symSatake, mul_comm]

/-- The product of all `Sym^n` Satake parameters is `(ab)^{n(n+1)/2}`: the central character
of the lift is the `n(n+1)/2`-th power of the central character of `π`. -/
theorem symSatake_prod (n : ℕ) (a b : R) :
    ∏ i ∈ range (n + 1), symSatake n a b i = (a * b) ^ (∑ i ∈ range (n + 1), i) := by
  have hsum : ∑ i ∈ range (n + 1), (n - i) = ∑ i ∈ range (n + 1), i := by
    rw [← Finset.sum_range_reflect (fun i => i) (n + 1)]
    refine Finset.sum_congr rfl ?_
    intro i hi
    have := Finset.mem_range.mp hi
    omega
  calc ∏ i ∈ range (n + 1), symSatake n a b i
      = (∏ i ∈ range (n + 1), a ^ i) * ∏ i ∈ range (n + 1), b ^ (n - i) := by
        rw [← Finset.prod_mul_distrib]; rfl
    _ = a ^ (∑ i ∈ range (n + 1), i) * b ^ (∑ i ∈ range (n + 1), (n - i)) := by
        rw [Finset.prod_pow_eq_pow_sum, Finset.prod_pow_eq_pow_sum]
    _ = (a * b) ^ (∑ i ∈ range (n + 1), i) := by rw [hsum, mul_pow]

/-- **Self-duality of symmetric power lifts.**  If the central character is trivial
(`ab = 1`), the Satake multiset of `Sym^n π` is stable under inversion: the parameters pair
off as `γ_i γ_{n-i} = 1`. -/
theorem symSatake_selfdual (n : ℕ) (a b : R) (hab : a * b = 1) (i : ℕ) (hi : i ≤ n) :
    symSatake n a b i * symSatake n a b (n - i) = 1 := by
  have h1 : n - (n - i) = i := by omega
  rw [symSatake, symSatake, h1]
  calc a ^ i * b ^ (n - i) * (a ^ (n - i) * b ^ i)
      = (a * b) ^ i * (a * b) ^ (n - i) := by rw [mul_pow, mul_pow]; ring
    _ = 1 := by rw [hab, one_pow, one_pow, one_mul]

end SymmetricPower

section GL3

variable {R : Type*} [CommRing R]

/-- The degree-three Euler factor of an unramified `GL(3)` representation. -/
noncomputable def gl3Euler (c1 c2 c3 : R) : PowerSeries R :=
  1 - C c1 * X + C c2 * X ^ 2 - C c3 * X ^ 3

/-- The Hecke eigenvalue sequence of an unramified `GL(3)` representation with Satake
elementary symmetric data `(c1, c2, c3)`. -/
def hecke3 (c1 c2 c3 : R) : ℕ → R
  | 0 => 1
  | 1 => c1
  | 2 => c1 ^ 2 - c2
  | (k + 3) => c1 * hecke3 c1 c2 c3 (k + 2) - c2 * hecke3 c1 c2 c3 (k + 1)
      + c3 * hecke3 c1 c2 c3 k

@[simp] lemma hecke3_zero (c1 c2 c3 : R) : hecke3 c1 c2 c3 0 = 1 := rfl
@[simp] lemma hecke3_one (c1 c2 c3 : R) : hecke3 c1 c2 c3 1 = c1 := rfl
@[simp] lemma hecke3_two (c1 c2 c3 : R) : hecke3 c1 c2 c3 2 = c1 ^ 2 - c2 := rfl

lemma hecke3_add_three (c1 c2 c3 : R) (k : ℕ) :
    hecke3 c1 c2 c3 (k + 3) = c1 * hecke3 c1 c2 c3 (k + 2) - c2 * hecke3 c1 c2 c3 (k + 1)
      + c3 * hecke3 c1 c2 c3 k := rfl

/-- The GL(3) L-series inverts the GL(3) Euler factor. -/
theorem hecke3_L_mul_euler (c1 c2 c3 : R) :
    PowerSeries.mk (hecke3 c1 c2 c3) * gl3Euler c1 c2 c3 = 1 := by
  rw [gl3Euler, mk_mul_cubic _ c1 c2 c3 (fun k => hecke3_add_three c1 c2 c3 k)]
  have e1 : hecke3 c1 c2 c3 1 - c1 * hecke3 c1 c2 c3 0 = 0 := by
    rw [hecke3_zero, hecke3_one]; ring
  have e2 : hecke3 c1 c2 c3 2 - c1 * hecke3 c1 c2 c3 1 + c2 * hecke3 c1 c2 c3 0 = 0 := by
    rw [hecke3_zero, hecke3_one, hecke3_two]; ring
  rw [e1, e2, hecke3_zero]
  simp

/-- Congruence lemma for the GL(3) Euler factor. -/
lemma gl3Euler_congr {c1 c2 c3 d1 d2 d3 : R} (h1 : c1 = d1) (h2 : c2 = d2) (h3 : c3 = d3) :
    gl3Euler c1 c2 c3 = gl3Euler d1 d2 d3 := by rw [h1, h2, h3]

/-- Expansion of a product of three linear Euler factors. -/
lemma euler_three_expand (x y z : R) :
    (1 - C x * X) * (1 - C y * X) * (1 - C z * X)
      = gl3Euler (x + y + z) (x * y + y * z + z * x) (x * y * z) := by
  rw [gl3Euler]
  simp only [map_add, map_mul]
  ring

lemma hecke_two_eq (a b : R) : hecke a b 2 = a ^ 2 + a * b + b ^ 2 := by
  rw [hecke_add_two]; simp; ring

/-- **The Gelbart–Jacquet Euler factor.**  The degree-three Euler polynomial of `Sym^2 π`
has coefficients that are explicit polynomials in the `GL(2)` Hecke data:
the `p`-th coefficient of the lift is `a_p^2 - χ(p) = a_{p^2}`, the second is
`χ(p) · a_{p^2}` and the determinant is `χ(p)^3`. -/
theorem symEuler_two_eq (a b : R) :
    symEuler 2 a b
      = gl3Euler (hecke a b 2) ((a * b) * hecke a b 2) ((a * b) ^ 3) := by
  rw [symEuler]
  rw [Finset.prod_range_succ, Finset.prod_range_succ, Finset.prod_range_one]
  have h0 : symSatake 2 a b 0 = b ^ 2 := by simp [symSatake]
  have h1 : symSatake 2 a b 1 = a * b := by simp [symSatake]
  have h2 : symSatake 2 a b 2 = a ^ 2 := by simp [symSatake]
  rw [h0, h1, h2, euler_three_expand, hecke_two_eq]
  exact gl3Euler_congr (by ring) (by ring) (by ring)

/-- The `p`-th Hecke eigenvalue of the Gelbart–Jacquet lift is `a_p^2 - χ(p)`. -/
theorem gelbart_jacquet_eigenvalue (a b : R) :
    hecke a b 2 = hecke a b 1 ^ 2 - a * b := by
  rw [hecke_two_eq, hecke_one]; ring

/-- **Gelbart–Jacquet transfer (local form).**  The L-factor of the symmetric square lift of
`π` coincides with the L-factor of the unramified `GL(3)` representation whose Hecke
eigenvalues obey the three-term recursion with data
`(a_p^2 - χ(p), χ(p)(a_p^2 - χ(p)), χ(p)^3)`.  In particular the Dirichlet coefficients of
`L(s, Sym^2 π)` are the `GL(3)` Hecke eigenvalues `hecke3`. -/
theorem gelbart_jacquet (a b : R) :
    symL 2 a b
      = PowerSeries.mk (hecke3 (hecke a b 2) ((a * b) * hecke a b 2) ((a * b) ^ 3)) := by
  refine inv_unique (e := symEuler 2 a b) (symL_mul_symEuler 2 a b) ?_
  rw [symEuler_two_eq]
  exact hecke3_L_mul_euler _ _ _

/-- Self-duality of the Gelbart–Jacquet lift for trivial central character: the GL(3) Euler
polynomial is palindromic, `1 - c X + c X^2 - X^3`. -/
theorem symEuler_two_selfdual (a b : R) (hab : a * b = 1) :
    symEuler 2 a b = gl3Euler (hecke a b 2) (hecke a b 2) 1 := by
  rw [symEuler_two_eq, hab, one_mul, one_pow]

end GL3

section RankinSelberg

variable {R : Type*} [CommRing R]

/-- The squares of the Hecke eigenvalues satisfy the `GL(3)` three-term recursion attached to
the symmetric square Satake data.  This is the local Rankin–Selberg phenomenon:
`L(s, π × π)` is, up to the factor `1 + χ(p)X`, a `GL(3)` L-function. -/
theorem hecke_sq_rec (a b : R) (k : ℕ) :
    hecke a b (k + 3) ^ 2
      = hecke a b 2 * hecke a b (k + 2) ^ 2 - ((a * b) * hecke a b 2) * hecke a b (k + 1) ^ 2
        + (a * b) ^ 3 * hecke a b k ^ 2 := by
  have d0 := hecke_sq_sub a b k
  have d1 := hecke_sq_sub a b (k + 1)
  have d2 := hecke_sq_sub a b (k + 2)
  have e := hecke_even_rec a b (2 * k + 2)
  rw [show 2 * (k + 1) + 2 = 2 * k + 4 by ring] at d1
  rw [show 2 * (k + 2) + 2 = 2 * k + 6 by ring] at d2
  rw [show 2 * k + 2 + 4 = 2 * k + 6 by ring, show 2 * k + 2 + 2 = 2 * k + 4 by ring] at e
  rw [hecke_two_eq]
  linear_combination d2 + e - (a ^ 2 + b ^ 2) * d1 + (a * b) ^ 2 * d0

/-- **Local Rankin–Selberg identity.**
`(∑_k a_{p^k}^2 X^k) · L(Sym^2 π, X)^{-1} = 1 + χ(p) X`, i.e.
`L(s, π × π) = (1 + χ(p) p^{-s}) · L(s, Sym^2 π)` locally at `p`.
Equivalently `L(s, π × π) = ζ_p(s) L(s, Sym^2 π) / ζ_p(2s)` in the classical normalisation. -/
theorem rankin_selberg_sym_two (a b : R) :
    PowerSeries.mk (fun k => hecke a b k ^ 2) * symEuler 2 a b = 1 + C (a * b) * X := by
  rw [symEuler_two_eq, gl3Euler]
  rw [mk_mul_cubic (fun k => hecke a b k ^ 2) (hecke a b 2) ((a * b) * hecke a b 2)
      ((a * b) ^ 3) (fun k => hecke_sq_rec a b k)]
  have hC : (C (hecke a b 2) : PowerSeries R) = C a ^ 2 + C a * C b + C b ^ 2 := by
    rw [hecke_two_eq]
    simp only [map_add, map_mul, map_pow]
  simp only [hecke_zero, hecke_one, map_sub, map_add, map_mul, map_pow, map_one,
    pow_zero, pow_one, mul_one]
  rw [hC]
  ring

end RankinSelberg

section GL4

variable {R : Type*} [CommRing R]

/-- The degree-four Euler factor of an unramified `GL(4)` representation. -/
noncomputable def gl4Euler (c1 c2 c3 c4 : R) : PowerSeries R :=
  1 - C c1 * X + C c2 * X ^ 2 - C c3 * X ^ 3 + C c4 * X ^ 4

/-- The Hecke eigenvalue sequence of an unramified `GL(4)` representation. -/
def hecke4 (c1 c2 c3 c4 : R) : ℕ → R
  | 0 => 1
  | 1 => c1
  | 2 => c1 ^ 2 - c2
  | 3 => c1 ^ 3 - 2 * c1 * c2 + c3
  | (k + 4) => c1 * hecke4 c1 c2 c3 c4 (k + 3) - c2 * hecke4 c1 c2 c3 c4 (k + 2)
      + c3 * hecke4 c1 c2 c3 c4 (k + 1) - c4 * hecke4 c1 c2 c3 c4 k

lemma hecke4_add_four (c1 c2 c3 c4 : R) (k : ℕ) :
    hecke4 c1 c2 c3 c4 (k + 4) = c1 * hecke4 c1 c2 c3 c4 (k + 3) - c2 * hecke4 c1 c2 c3 c4 (k + 2)
      + c3 * hecke4 c1 c2 c3 c4 (k + 1) - c4 * hecke4 c1 c2 c3 c4 k := rfl

/-- The GL(4) L-series inverts the GL(4) Euler factor. -/
theorem hecke4_L_mul_euler (c1 c2 c3 c4 : R) :
    PowerSeries.mk (hecke4 c1 c2 c3 c4) * gl4Euler c1 c2 c3 c4 = 1 := by
  rw [gl4Euler, mk_mul_quartic _ c1 c2 c3 c4 (fun k => hecke4_add_four c1 c2 c3 c4 k)]
  show (C ((hecke4 c1 c2 c3 c4) 0) * X ^ 0 + C ((hecke4 c1 c2 c3 c4) 1 - c1 * (hecke4 c1 c2 c3 c4) 0) * X ^ 1
      + C ((hecke4 c1 c2 c3 c4) 2 - c1 * (hecke4 c1 c2 c3 c4) 1 + c2 * (hecke4 c1 c2 c3 c4) 0) * X ^ 2
      + C ((hecke4 c1 c2 c3 c4) 3 - c1 * (hecke4 c1 c2 c3 c4) 2 + c2 * (hecke4 c1 c2 c3 c4) 1
          - c3 * (hecke4 c1 c2 c3 c4) 0) * X ^ 3) = 1
  have e0 : (hecke4 c1 c2 c3 c4) 0 = 1 := rfl
  have e1 : (hecke4 c1 c2 c3 c4) 1 = c1 := rfl
  have e2 : (hecke4 c1 c2 c3 c4) 2 = c1 ^ 2 - c2 := rfl
  have e3 : (hecke4 c1 c2 c3 c4) 3 = c1 ^ 3 - 2 * c1 * c2 + c3 := rfl
  rw [e0, e1, e2, e3]
  have z1 : (c1 : R) - c1 * 1 = 0 := by ring
  have z2 : (c1 : R) ^ 2 - c2 - c1 * c1 + c2 * 1 = 0 := by ring
  have z3 : (c1 : R) ^ 3 - 2 * c1 * c2 + c3 - c1 * (c1 ^ 2 - c2) + c2 * c1 - c3 * 1 = 0 := by ring
  rw [z1, z2, z3]
  simp

/-- Congruence lemma for the GL(4) Euler factor. -/
lemma gl4Euler_congr {c1 c2 c3 c4 d1 d2 d3 d4 : R} (h1 : c1 = d1) (h2 : c2 = d2) (h3 : c3 = d3)
    (h4 : c4 = d4) : gl4Euler c1 c2 c3 c4 = gl4Euler d1 d2 d3 d4 := by rw [h1, h2, h3, h4]

/-- Expansion of a product of four linear Euler factors. -/
lemma euler_four_expand (w x y z : R) :
    (1 - C w * X) * (1 - C x * X) * (1 - C y * X) * (1 - C z * X)
      = gl4Euler (w + x + y + z)
          (w * x + w * y + w * z + x * y + x * z + y * z)
          (w * x * y + w * x * z + w * y * z + x * y * z) (w * x * y * z) := by
  rw [gl4Euler]
  simp only [map_add, map_mul]
  ring

lemma hecke_three_eq (a b : R) : hecke a b 3 = a ^ 3 + a ^ 2 * b + a * b ^ 2 + b ^ 3 := by
  rw [hecke_add_two, hecke_two_eq]; simp; ring

lemma hecke_four_eq (a b : R) :
    hecke a b 4 = a ^ 4 + a ^ 3 * b + a ^ 2 * b ^ 2 + a * b ^ 3 + b ^ 4 := by
  rw [show (4 : ℕ) = 2 + 2 from rfl, hecke_add_two, hecke_three_eq, hecke_two_eq]
  ring

/-- **The symmetric cube Euler factor.**  The degree-four Euler polynomial of `Sym^3 π` has
coefficients expressed through the `GL(2)` Hecke eigenvalues:
`(a_{p^3}, χ(p)(a_{p^4} + χ(p)^2), χ(p)^3 a_{p^3}, χ(p)^6)`. -/
theorem symEuler_three_eq (a b : R) :
    symEuler 3 a b
      = gl4Euler (hecke a b 3) ((a * b) * (hecke a b 4 + (a * b) ^ 2))
          ((a * b) ^ 3 * hecke a b 3) ((a * b) ^ 6) := by
  rw [symEuler]
  rw [Finset.prod_range_succ, Finset.prod_range_succ, Finset.prod_range_succ,
    Finset.prod_range_one]
  have h0 : symSatake 3 a b 0 = b ^ 3 := by simp [symSatake]
  have h1 : symSatake 3 a b 1 = a * b ^ 2 := by simp [symSatake]
  have h2 : symSatake 3 a b 2 = a ^ 2 * b := by simp [symSatake]
  have h3 : symSatake 3 a b 3 = a ^ 3 := by simp [symSatake]
  rw [h0, h1, h2, h3, euler_four_expand, hecke_three_eq, hecke_four_eq]
  exact gl4Euler_congr (by ring) (by ring) (by ring) (by ring)

/-- **Symmetric cube transfer (local form).**  The L-factor of `Sym^3 π` is the L-factor of
the unramified `GL(4)` representation whose Hecke eigenvalues obey the four-term recursion
with the explicit `GL(2)` data. -/
theorem symcube_transfer (a b : R) :
    symL 3 a b
      = PowerSeries.mk (hecke4 (hecke a b 3) ((a * b) * (hecke a b 4 + (a * b) ^ 2))
          ((a * b) ^ 3 * hecke a b 3) ((a * b) ^ 6)) := by
  refine inv_unique (e := symEuler 3 a b) (symL_mul_symEuler 3 a b) ?_
  rw [symEuler_three_eq]
  exact hecke4_L_mul_euler _ _ _ _

end GL4

section Transfer

variable {R : Type*} [CommRing R]

lemma constantCoeff_L1 (c : R) : constantCoeff (L1 c) = 1 := by
  simp [L1]

lemma constantCoeff_prod_L1 (γ : ℕ → R) (n : ℕ) :
    constantCoeff (∏ i ∈ range n, L1 (γ i)) = 1 := by
  rw [map_prod]
  exact Finset.prod_eq_one fun i _ => constantCoeff_L1 (γ i)

lemma coeff_one_L1 (c : R) : coeff 1 (L1 c) = c := by
  simp [L1]

/-- The linear (i.e. `p`-th) Dirichlet coefficient of a product of `GL(1)` L-factors is the
sum of the corresponding Satake parameters. -/
lemma coeff_one_prod_L1 (γ : ℕ → R) (n : ℕ) :
    coeff 1 (∏ i ∈ range n, L1 (γ i)) = ∑ i ∈ range n, γ i := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [Finset.prod_range_succ, Finset.sum_range_succ, coeff_mul]
      rw [Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk]
      rw [Finset.sum_range_succ, Finset.sum_range_one]
      have hc : (coeff 0) (∏ i ∈ range n, L1 (γ i)) = 1 := by
        rw [PowerSeries.coeff_zero_eq_constantCoeff]
        exact constantCoeff_prod_L1 γ n
      rw [hc, ih]
      simp [L1]
      ring

/-- **Transfer of Hecke eigenvalues.**  The `p`-th Hecke eigenvalue of the symmetric power
lift `Sym^n π` is the complete homogeneous symmetric function `h_n(a, b) = a_{p^n}`:
the functorial lift sends `a_p ↦ a_{p^n}`. -/
theorem symL_coeff_one (n : ℕ) (a b : R) :
    coeff 1 (symL n a b) = hecke a b n := by
  rw [symL, coeff_one_prod_L1, hecke_eq_sum_range]
  rfl

end Transfer

section Temperedness

/-- Unitarity of the `GL(2)` Satake parameters propagates to every symmetric power lift. -/
theorem symSatake_norm (n : ℕ) (a b : ℂ) (ha : ‖a‖ = 1) (hb : ‖b‖ = 1) (i : ℕ) :
    ‖symSatake n a b i‖ = 1 := by
  rw [symSatake, norm_mul, norm_pow, norm_pow, ha, hb, one_pow, one_pow, one_mul]

/-- **Functoriality preserves temperedness.**  If `π` satisfies the Ramanujan bound at `p`
(unitary Satake parameters), then the `p`-th Hecke eigenvalue of `Sym^n π` is bounded by
`n + 1`, the trivial bound for a tempered representation of `GL(n+1)`. -/
theorem sym_tempered (n : ℕ) (a b : ℂ) (ha : ‖a‖ = 1) (hb : ‖b‖ = 1) :
    ‖coeff 1 (symL n a b)‖ ≤ n + 1 := by
  rw [symL_coeff_one]
  exact hecke_norm_le a b ha hb n

/-- The Gelbart–Jacquet lift of a tempered representation is tempered at `p`:
`|a_p^2 - χ(p)| ≤ 3`. -/
theorem gelbart_jacquet_tempered (a b : ℂ) (ha : ‖a‖ = 1) (hb : ‖b‖ = 1) :
    ‖hecke a b 1 ^ 2 - a * b‖ ≤ 3 := by
  have h := hecke_norm_le a b ha hb 2
  rw [gelbart_jacquet_eigenvalue] at h
  norm_num at h
  exact h

end Temperedness

end Langlands