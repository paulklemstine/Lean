import Catalog.Shared.LanglandsSymmetricPower

/-!
# Langlands functoriality, III: tensor transfer and Ramanujan bounds for the lifts

This file proves two families of results that go beyond the individual liftings of
`Shared.LanglandsSymmetricPower`.

## Tensor (Rankin–Selberg) functoriality in arbitrary symmetric power degree

`symEuler_tensor_one` and `symL_tensor_one` prove, for **every** `m`, the local
Rankin–Selberg factorisation

`L(Sym^m π × π, X) = L(Sym^{m+1} π, X) · L(Sym^{m-1} π ⊗ χ, X)`,

i.e. the functorial decomposition `Sym^m ⊗ Sym^1 = Sym^{m+1} ⊕ (Sym^{m-1} ⊗ det)` realised
on Satake parameters, Euler factors and Dirichlet coefficients.  The `m = 1` case is the
Gelbart–Jacquet identity `L(π × π) = L(Sym^2 π) L(χ)` already visible in
`rankin_selberg_sym_two`.

## Ramanujan bounds transported along functoriality

`hecke3_eq_prod` identifies the abstract `GL(3)` Hecke eigenvalues with the complete
homogeneous symmetric functions of the three Satake parameters, and `symL_two_coeff_norm_le`
deduces the full Ramanujan bound `|b_{p^k}| ≤ (k+1)(k+2)/2` for **all** powers of `p` for the
Gelbart–Jacquet lift of a tempered representation — not merely for `k = 1`.
-/

namespace Langlands

open Finset PowerSeries

section TensorTransfer

variable {R : Type*} [CommRing R]

lemma satake_mul_a (m : ℕ) (a b : R) (i : ℕ) :
    a * symSatake m a b i = symSatake (m + 1) a b (i + 1) := by
  rw [symSatake, symSatake, show m + 1 - (i + 1) = m - i by omega]
  ring

lemma satake_mul_b (m : ℕ) (a b : R) (i : ℕ) (hi : i ≤ m) :
    b * symSatake m a b i = symSatake (m + 1) a b i := by
  rw [symSatake, symSatake, show m + 1 - i = (m - i) + 1 by omega, pow_succ]
  ring

lemma satake_twist (m : ℕ) (a b : R) (j : ℕ) (hj : j < m) :
    (a * b) * symSatake (m - 1) a b j = symSatake (m + 1) a b (j + 1) := by
  rw [symSatake, symSatake, show m + 1 - (j + 1) = (m - 1 - j) + 1 by omega, pow_succ, pow_succ]
  ring

/-- **Tensor functoriality of Euler factors.**  For every `m`, the degree `2(m+1)` Euler
factor of `Sym^m π ⊗ π` factors as the `Sym^{m+1}` Euler factor times the twisted
`Sym^{m-1}` Euler factor.  This is `Sym^m ⊗ Sym^1 = Sym^{m+1} ⊕ Sym^{m-1} ⊗ det` at the level
of Satake parameters. -/
theorem symEuler_tensor_one (m : ℕ) (a b : R) :
    (∏ i ∈ range (m + 1),
        ((1 - C (a * symSatake m a b i) * X) * (1 - C (b * symSatake m a b i) * X)))
      = symEuler (m + 1) a b
          * ∏ j ∈ range m, (1 - C ((a * b) * symSatake (m - 1) a b j) * X) := by
  set f : ℕ → PowerSeries R := fun i => 1 - C (symSatake (m + 1) a b i) * X with hf
  have hLHS : (∏ i ∈ range (m + 1),
      ((1 - C (a * symSatake m a b i) * X) * (1 - C (b * symSatake m a b i) * X)))
      = ∏ i ∈ range (m + 1), (f (i + 1) * f i) := by
    refine Finset.prod_congr rfl ?_
    intro i hi
    have him : i ≤ m := Nat.lt_succ_iff.mp (Finset.mem_range.mp hi)
    rw [satake_mul_a, satake_mul_b m a b i him]
  have hTwist : (∏ j ∈ range m, (1 - C ((a * b) * symSatake (m - 1) a b j) * X))
      = ∏ j ∈ range m, f (j + 1) := by
    refine Finset.prod_congr rfl ?_
    intro j hj
    rw [satake_twist m a b j (Finset.mem_range.mp hj)]
  have hSym : symEuler (m + 1) a b = ∏ i ∈ range (m + 2), f i := rfl
  rw [hLHS, hTwist, hSym, Finset.prod_mul_distrib]
  rw [Finset.prod_range_succ' f (m + 1), Finset.prod_range_succ' f m]
  ring

/-- **Tensor functoriality of local L-functions.**
`L(Sym^m π × π, X) = L(Sym^{m+1} π, X) · L(Sym^{m-1} π ⊗ χ, X)` for every `m ≥ 0`. -/
theorem symL_tensor_one (m : ℕ) (a b : R) :
    (∏ i ∈ range (m + 1), (L1 (a * symSatake m a b i) * L1 (b * symSatake m a b i)))
      = symL (m + 1) a b * ∏ j ∈ range m, L1 ((a * b) * symSatake (m - 1) a b j) := by
  refine inv_unique (e := ∏ i ∈ range (m + 1),
      ((1 - C (a * symSatake m a b i) * X) * (1 - C (b * symSatake m a b i) * X))) ?_ ?_
  · rw [← Finset.prod_mul_distrib]
    refine Finset.prod_eq_one ?_
    intro i _
    calc L1 (a * symSatake m a b i) * L1 (b * symSatake m a b i)
        * ((1 - C (a * symSatake m a b i) * X) * (1 - C (b * symSatake m a b i) * X))
        = (L1 (a * symSatake m a b i) * (1 - C (a * symSatake m a b i) * X))
          * (L1 (b * symSatake m a b i) * (1 - C (b * symSatake m a b i) * X)) := by ring
      _ = 1 := by rw [L1_mul_euler, L1_mul_euler, mul_one]
  · rw [symEuler_tensor_one]
    calc symL (m + 1) a b * (∏ j ∈ range m, L1 ((a * b) * symSatake (m - 1) a b j))
          * (symEuler (m + 1) a b
              * ∏ j ∈ range m, (1 - C ((a * b) * symSatake (m - 1) a b j) * X))
        = (symL (m + 1) a b * symEuler (m + 1) a b)
          * ∏ j ∈ range m, (L1 ((a * b) * symSatake (m - 1) a b j)
              * (1 - C ((a * b) * symSatake (m - 1) a b j) * X)) := by
          rw [Finset.prod_mul_distrib]; ring
      _ = 1 := by
          rw [symL_mul_symEuler]
          rw [Finset.prod_eq_one (fun j _ => L1_mul_euler _)]
          ring

lemma satake_mul_sq_a (m : ℕ) (a b : R) (i : ℕ) :
    a ^ 2 * symSatake m a b i = symSatake (m + 2) a b (i + 2) := by
  rw [symSatake, symSatake, show m + 2 - (i + 2) = m - i by omega]
  ring

lemma satake_mul_sq_b (m : ℕ) (a b : R) (i : ℕ) (hi : i ≤ m) :
    b ^ 2 * symSatake m a b i = symSatake (m + 2) a b i := by
  rw [symSatake, symSatake, show m + 2 - i = (m - i) + 2 by omega, pow_add]
  ring

lemma satake_twist_two (m : ℕ) (a b : R) (j : ℕ) (hj : j < m) :
    (a * b) ^ 2 * symSatake (m - 1) a b j = symSatake (m + 3) a b (j + 2) := by
  rw [symSatake, symSatake, show m + 3 - (j + 2) = (m - 1 - j) + 2 by omega, pow_add, mul_pow]
  ring

/-- Shifting a product by two positions. -/
lemma prod_shift_two (f : ℕ → PowerSeries R) (n : ℕ) :
    (∏ i ∈ range n, f (i + 2)) * (f 1 * f 0) = ∏ i ∈ range (n + 2), f i := by
  rw [Finset.prod_range_succ' f (n + 1), Finset.prod_range_succ' (fun i => f (i + 1)) n]
  ring

/-- **Tensor functoriality with the symmetric square.**  For every `m ≥ 1` (written `m + 1`),
the Euler factor of `Sym^{m+1} π ⊗ Sym^2 π` factors as `Sym^{m+3}` times the `det`-twist of
`Sym^{m+1}` times the `det^2`-twist of `Sym^{m-1}`; i.e.
`Sym^{m+1} ⊗ Sym^2 = Sym^{m+3} ⊕ (Sym^{m+1} ⊗ det) ⊕ (Sym^{m-1} ⊗ det^2)`. -/
theorem symEuler_tensor_two (m : ℕ) (a b : R) :
    (∏ i ∈ range (m + 2),
        ((1 - C (a ^ 2 * symSatake (m + 1) a b i) * X)
          * (1 - C ((a * b) * symSatake (m + 1) a b i) * X)
          * (1 - C (b ^ 2 * symSatake (m + 1) a b i) * X)))
      = symEuler (m + 3) a b
          * (∏ i ∈ range (m + 2), (1 - C ((a * b) * symSatake (m + 1) a b i) * X))
          * ∏ j ∈ range m, (1 - C ((a * b) ^ 2 * symSatake (m - 1) a b j) * X) := by
  set f : ℕ → PowerSeries R := fun i => 1 - C (symSatake (m + 3) a b i) * X with hf
  set g : ℕ → PowerSeries R := fun i => 1 - C ((a * b) * symSatake (m + 1) a b i) * X with hg
  have hLHS : (∏ i ∈ range (m + 2),
      ((1 - C (a ^ 2 * symSatake (m + 1) a b i) * X)
        * (1 - C ((a * b) * symSatake (m + 1) a b i) * X)
        * (1 - C (b ^ 2 * symSatake (m + 1) a b i) * X)))
      = ∏ i ∈ range (m + 2), (f (i + 2) * g i * f i) := by
    refine Finset.prod_congr rfl ?_
    intro i hi
    have him : i ≤ m + 1 := Nat.lt_succ_iff.mp (Finset.mem_range.mp hi)
    rw [satake_mul_sq_a (m + 1) a b i, satake_mul_sq_b (m + 1) a b i him]
  have hTwist : (∏ j ∈ range m, (1 - C ((a * b) ^ 2 * symSatake (m - 1) a b j) * X))
      = ∏ j ∈ range m, f (j + 2) := by
    refine Finset.prod_congr rfl ?_
    intro j hj
    rw [satake_twist_two m a b j (Finset.mem_range.mp hj)]
  have hSym : symEuler (m + 3) a b = ∏ i ∈ range (m + 4), f i := rfl
  rw [hLHS, hTwist, hSym, Finset.prod_mul_distrib, Finset.prod_mul_distrib,
    ← prod_shift_two f (m + 2), ← prod_shift_two f m]
  ring

/-- The L-series form of `Sym^{m+1} ⊗ Sym^2` functoriality:
`L(Sym^{m+1} π × Sym^2 π) = L(Sym^{m+3} π) L(Sym^{m+1} π ⊗ χ) L(Sym^{m-1} π ⊗ χ^2)`. -/
theorem symL_tensor_two (m : ℕ) (a b : R) :
    (∏ i ∈ range (m + 2),
        (L1 (a ^ 2 * symSatake (m + 1) a b i) * L1 ((a * b) * symSatake (m + 1) a b i)
          * L1 (b ^ 2 * symSatake (m + 1) a b i)))
      = symL (m + 3) a b
          * (∏ i ∈ range (m + 2), L1 ((a * b) * symSatake (m + 1) a b i))
          * ∏ j ∈ range m, L1 ((a * b) ^ 2 * symSatake (m - 1) a b j) := by
  refine inv_unique (e := ∏ i ∈ range (m + 2),
      ((1 - C (a ^ 2 * symSatake (m + 1) a b i) * X)
        * (1 - C ((a * b) * symSatake (m + 1) a b i) * X)
        * (1 - C (b ^ 2 * symSatake (m + 1) a b i) * X))) ?_ ?_
  · rw [← Finset.prod_mul_distrib]
    refine Finset.prod_eq_one ?_
    intro i _
    calc L1 (a ^ 2 * symSatake (m + 1) a b i) * L1 ((a * b) * symSatake (m + 1) a b i)
          * L1 (b ^ 2 * symSatake (m + 1) a b i)
        * ((1 - C (a ^ 2 * symSatake (m + 1) a b i) * X)
            * (1 - C ((a * b) * symSatake (m + 1) a b i) * X)
            * (1 - C (b ^ 2 * symSatake (m + 1) a b i) * X))
        = (L1 (a ^ 2 * symSatake (m + 1) a b i) * (1 - C (a ^ 2 * symSatake (m + 1) a b i) * X))
          * ((L1 ((a * b) * symSatake (m + 1) a b i)
                * (1 - C ((a * b) * symSatake (m + 1) a b i) * X))
            * (L1 (b ^ 2 * symSatake (m + 1) a b i)
                * (1 - C (b ^ 2 * symSatake (m + 1) a b i) * X))) := by ring
      _ = 1 := by rw [L1_mul_euler, L1_mul_euler, L1_mul_euler]; ring
  · rw [symEuler_tensor_two]
    calc symL (m + 3) a b * (∏ i ∈ range (m + 2), L1 ((a * b) * symSatake (m + 1) a b i))
            * (∏ j ∈ range m, L1 ((a * b) ^ 2 * symSatake (m - 1) a b j))
          * (symEuler (m + 3) a b
              * (∏ i ∈ range (m + 2), (1 - C ((a * b) * symSatake (m + 1) a b i) * X))
              * ∏ j ∈ range m, (1 - C ((a * b) ^ 2 * symSatake (m - 1) a b j) * X))
        = (symL (m + 3) a b * symEuler (m + 3) a b)
          * (∏ i ∈ range (m + 2), (L1 ((a * b) * symSatake (m + 1) a b i)
              * (1 - C ((a * b) * symSatake (m + 1) a b i) * X)))
          * (∏ j ∈ range m, (L1 ((a * b) ^ 2 * symSatake (m - 1) a b j)
              * (1 - C ((a * b) ^ 2 * symSatake (m - 1) a b j) * X))) := by
          rw [Finset.prod_mul_distrib, Finset.prod_mul_distrib]; ring
      _ = 1 := by
          rw [symL_mul_symEuler, Finset.prod_eq_one (fun j _ => L1_mul_euler _),
            Finset.prod_eq_one (fun j _ => L1_mul_euler _)]
          ring

end TensorTransfer

section GL3Coefficients

variable {R : Type*} [CommRing R]

/-- **The GL(3) Hecke eigenvalues are the complete homogeneous symmetric functions of the
Satake parameters.**  Equivalently, the L-series defined by the GL(3) three-term recursion is
the product of the three `GL(1)` geometric factors. -/
theorem hecke3_eq_prod (x y z : R) :
    PowerSeries.mk (hecke3 (x + y + z) (x * y + y * z + z * x) (x * y * z))
      = L1 x * L1 y * L1 z := by
  refine inv_unique (e := gl3Euler (x + y + z) (x * y + y * z + z * x) (x * y * z))
    (hecke3_L_mul_euler _ _ _) ?_
  rw [← euler_three_expand]
  calc L1 x * L1 y * L1 z * ((1 - C x * X) * (1 - C y * X) * (1 - C z * X))
      = (L1 x * (1 - C x * X)) * ((L1 y * (1 - C y * X)) * (L1 z * (1 - C z * X))) := by ring
    _ = 1 := by rw [L1_mul_euler, L1_mul_euler, L1_mul_euler]; ring

/-- The Gelbart–Jacquet lift as an explicit Euler product over its three Satake parameters. -/
theorem symL_two_eq_prod (a b : R) :
    symL 2 a b = L1 (a ^ 2) * L1 (a * b) * L1 (b ^ 2) := by
  rw [symL, Finset.prod_range_succ, Finset.prod_range_succ, Finset.prod_range_one]
  have h0 : symSatake 2 a b 0 = b ^ 2 := by simp [symSatake]
  have h1 : symSatake 2 a b 1 = a * b := by simp [symSatake]
  have h2 : symSatake 2 a b 2 = a ^ 2 := by simp [symSatake]
  rw [h0, h1, h2]
  ring

end GL3Coefficients

section RamanujanTransfer

/-- Multiplying by a unitary `GL(1)` Euler factor turns a coefficient bound `B` into the
bound `∑_{j ≤ k} B j`. -/
lemma coeff_L1_mul_norm_le (x : ℂ) (hx : ‖x‖ = 1) (G : PowerSeries ℂ) (B : ℕ → ℝ)
    (hB : ∀ j, ‖coeff j G‖ ≤ B j) (k : ℕ) :
    ‖coeff k (L1 x * G)‖ ≤ ∑ j ∈ range (k + 1), B j := by
  rw [coeff_mul]
  have step : ∀ ij ∈ Finset.antidiagonal k,
      ‖coeff ij.1 (L1 x) * coeff ij.2 G‖ ≤ B ij.2 := by
    intro ij _
    rw [norm_mul]
    have : ‖coeff ij.1 (L1 x)‖ = 1 := by
      rw [L1]
      simp [norm_pow, hx]
    rw [this, one_mul]
    exact hB ij.2
  calc ‖∑ ij ∈ Finset.antidiagonal k, coeff ij.1 (L1 x) * coeff ij.2 G‖
      ≤ ∑ ij ∈ Finset.antidiagonal k, ‖coeff ij.1 (L1 x) * coeff ij.2 G‖ := norm_sum_le _ _
    _ ≤ ∑ ij ∈ Finset.antidiagonal k, B ij.2 := Finset.sum_le_sum step
    _ = ∑ i ∈ range (k + 1), B (k - i) := by
        rw [Finset.Nat.sum_antidiagonal_eq_sum_range_succ (f := fun _ j => B j)]
    _ = ∑ j ∈ range (k + 1), B j := by
        rw [← Finset.sum_range_reflect (fun j => B j) (k + 1)]
        refine Finset.sum_congr rfl ?_
        intro i hi
        have := Finset.mem_range.mp hi
        congr 1

lemma coeff_L1_norm (x : ℂ) (hx : ‖x‖ = 1) (k : ℕ) : ‖coeff k (L1 x)‖ = 1 := by
  rw [L1]; simp [norm_pow, hx]

lemma sum_range_one_eq (k : ℕ) : ∑ _j ∈ range (k + 1), (1 : ℝ) = k + 1 := by simp

lemma sum_range_succ_real (k : ℕ) :
    ∑ j ∈ range (k + 1), ((j : ℝ) + 1) = (k + 1) * (k + 2) / 2 := by
  induction k with
  | zero => norm_num
  | succ n ih =>
      rw [Finset.sum_range_succ, ih]
      push_cast
      ring

/-- Ramanujan bound for a product of two unitary `GL(1)` factors: `|coeff k| ≤ k + 1`. -/
theorem coeff_two_norm_le (x y : ℂ) (hx : ‖x‖ = 1) (hy : ‖y‖ = 1) (k : ℕ) :
    ‖coeff k (L1 x * L1 y)‖ ≤ k + 1 := by
  have := coeff_L1_mul_norm_le x hx (L1 y) (fun _ => 1)
    (fun j => le_of_eq (coeff_L1_norm y hy j)) k
  simpa using this

/-- **Ramanujan bound for the Gelbart–Jacquet lift at every power of `p`.**  If `π` is
tempered at `p` (unitary Satake parameters), the Dirichlet coefficients of `L(s, Sym^2 π)`
satisfy `|b_{p^k}| ≤ (k+1)(k+2)/2`, the trivial tempered bound on `GL(3)`. -/
theorem symL_two_coeff_norm_le (a b : ℂ) (ha : ‖a‖ = 1) (hb : ‖b‖ = 1) (k : ℕ) :
    ‖coeff k (symL 2 a b)‖ ≤ (k + 1) * (k + 2) / 2 := by
  have hA : ‖a ^ 2‖ = 1 := by rw [norm_pow, ha, one_pow]
  have hB : ‖a * b‖ = 1 := by rw [norm_mul, ha, hb, one_mul]
  have hC : ‖b ^ 2‖ = 1 := by rw [norm_pow, hb, one_pow]
  have hbound : ∀ j, ‖coeff j (L1 (a * b) * L1 (b ^ 2))‖ ≤ (j : ℝ) + 1 :=
    fun j => coeff_two_norm_le _ _ hB hC j
  have := coeff_L1_mul_norm_le (a ^ 2) hA (L1 (a * b) * L1 (b ^ 2)) (fun j => (j : ℝ) + 1)
    hbound k
  rw [sum_range_succ_real] at this
  rw [symL_two_eq_prod, mul_assoc]
  exact this

/-- Temperedness of the symmetric cube lift at the prime `p`: `|c_p| ≤ 4`. -/
theorem symcube_tempered (a b : ℂ) (ha : ‖a‖ = 1) (hb : ‖b‖ = 1) :
    ‖hecke a b 3‖ ≤ 4 := by
  have h := hecke_norm_le a b ha hb 3
  norm_num at h
  exact h

end RamanujanTransfer

end Langlands