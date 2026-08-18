/-
# Chebotarev's theorem on the roots of unity (Chebotarev–Frenkel)

Every square submatrix of the `p × p` DFT matrix `(ζ^{jk})` (`p` prime, `ζ` a primitive
`p`-th root of unity) is nonsingular.

The proof formalized here is Frenkel's argument:

* Let `A = {a i}`, `B = {b j}` be two `n`-element sets of residues mod `p`, and consider the
  integer polynomial `P(X) = det ((1 + X)^{a i * b j})`.
* Expanding `(1 + X)^{a i b j} = (1 + s_i)^{b_j}` with `s_i = (1+X)^{a i} - 1` and using
  multilinearity of the determinant in the rows, `P` is a sum over functions
  `f : Fin n → Fin p` of `(∏ i, s_i ^ f i) * det (choose (b j) (f i))`.
* The terms with non-injective `f` vanish, and the remaining ones are divisible by
  `X ^ (∑ i, f i)` with `∑ i, f i ≥ N := 0 + 1 + ⋯ + (n-1)`. Hence `X^N ∣ P`, and the
  coefficient of `X^N` is `det (vandermonde a) * det (choose (b i) j)`, which is **prime to `p`**
  (a Vandermonde determinant of distinct residues, divided by a superfactorial).
* If some `ζ^{a i b j}` determinant vanished, the shifted cyclotomic polynomial
  `Φ_p(X + 1)` would divide `P`.  Its coefficients are `p ∣ C(p, k+1)` for `k < p - 1` and
  `1` in degree `p - 1`; combined with `X^N ∣ P` this forces `p ∣ P.coeff N`, a contradiction.
-/
import Mathlib

namespace ChebotarevDFT

open Polynomial Matrix Finset

/-! ## Combinatorial preliminaries -/

/-- The sum of `#s` distinct natural numbers is at least `0 + 1 + ⋯ + (#s - 1)`. -/
theorem sum_le_sum_of_injOn {ι : Type*} (s : Finset ι) (f : ι → ℕ) (hf : Set.InjOn f s) :
    ∑ i ∈ Finset.range s.card, i ≤ ∑ i ∈ s, f i := by
  classical
  have hinj : Set.InjOn (fun i => (f i : ℤ)) s := by
    intro x hx y hy h
    simp only at h
    exact hf hx hy (by exact_mod_cast h)
  set T : Finset ℤ := s.image (fun i => (f i : ℤ)) with hT
  have hcard : T.card = s.card := Finset.card_image_of_injOn hinj
  have hsum : ∑ x ∈ T, x = ∑ i ∈ s, (f i : ℤ) :=
    Finset.sum_image (by intro x hx y hy h; exact hinj hx hy h)
  have h := Finset.sum_range_le_sum (s := T) (c := 0) (by
    intro x hx
    simp only [hT, Finset.mem_image] at hx
    obtain ⟨i, _, rfl⟩ := hx
    positivity)
  rw [hcard, hsum] at h
  simp only [zero_add] at h
  have : ((∑ i ∈ Finset.range s.card, i : ℕ) : ℤ) ≤ ((∑ i ∈ s, f i : ℕ) : ℤ) := by
    push_cast; exact h
  exact_mod_cast this

/-- The staircase number `N = 0 + 1 + ⋯ + (n-1)`. -/
def stair (n : ℕ) : ℕ := ∑ i ∈ Finset.range n, i

theorem stair_le_sum {n p : ℕ} (f : Fin n → Fin p) (hinj : Function.Injective f) :
    stair n ≤ ∑ i, (f i : ℕ) := by
  have h := sum_le_sum_of_injOn (Finset.univ : Finset (Fin n)) (fun i => (f i : ℕ))
    (by intro x _ y _ h; exact hinj (Fin.ext h))
  simpa [stair] using h

theorem lt_of_sum_eq_stair {n p : ℕ} (f : Fin n → Fin p) (hinj : Function.Injective f)
    (h : ∑ i, (f i : ℕ) = stair n) (i0 : Fin n) : (f i0 : ℕ) < n := by
  by_contra hle
  push_neg at hle
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by have := i0.pos; omega⟩
  have hcard : (Finset.univ.erase i0).card = m := by simp [Finset.card_erase_of_mem]
  have h2 := sum_le_sum_of_injOn (Finset.univ.erase i0) (fun i => (f i : ℕ))
    (by intro x _ y _ h; exact hinj (Fin.ext h))
  rw [hcard] at h2
  simp only at h2
  have hsplit : ∑ i, (f i : ℕ) = (f i0 : ℕ) + ∑ i ∈ Finset.univ.erase i0, (f i : ℕ) :=
    (Finset.add_sum_erase _ _ (Finset.mem_univ i0)).symm
  have hst : stair (m + 1) = stair m + m := by simp [stair, Finset.sum_range_succ]
  have : stair m ≤ ∑ i ∈ Finset.univ.erase i0, (f i : ℕ) := h2
  omega

/-! ## Polynomial preliminaries -/

/-- `(1 + X)^m - 1 = X * w` with `w.coeff 0 = m`. -/
theorem exists_shift (m : ℕ) :
    ∃ w : ℤ[X], (1 + X : ℤ[X]) ^ m - 1 = X * w ∧ w.coeff 0 = (m : ℤ) := by
  induction m with
  | zero => exact ⟨0, by ring, by simp⟩
  | succ m ih =>
      obtain ⟨w, hw, hw0⟩ := ih
      refine ⟨(1 + X) * w + 1, ?_, ?_⟩
      · have h : (1 + X : ℤ[X]) ^ (m + 1) - 1 = (1 + X) * ((1 + X) ^ m - 1) + X := by ring
        rw [h, hw]; ring
      · simp [hw0]

/-- Binomial expansion with a uniform index range. -/
theorem one_add_pow_eq {R : Type*} [CommRing R] (s : R) (m p : ℕ) (h : m < p) :
    (1 + s) ^ m = ∑ k : Fin p, s ^ (k : ℕ) * (m.choose k : R) := by
  rw [Fin.sum_univ_eq_sum_range (fun k => s ^ k * (m.choose k : R)) p]
  rw [add_comm, add_pow]
  rw [Finset.sum_subset (s₁ := Finset.range (m + 1)) (s₂ := Finset.range p)
      (by intro x hx; simp only [Finset.mem_range] at *; omega)]
  · exact Finset.sum_congr rfl fun k _ => by simp
  · intro k _ hk
    simp only [Finset.mem_range, not_lt] at hk
    rw [Nat.choose_eq_zero_of_lt (by omega)]
    simp

/-- Multilinear (Cauchy–Binet style) expansion of the determinant of a matrix whose entries
are sums of products. -/
theorem det_sum_expansion {R : Type*} [CommRing R] {n m : ℕ} (c : Fin n → Fin m → R)
    (E : Fin m → Fin n → R) :
    (Matrix.of fun i j : Fin n => ∑ k : Fin m, c i k * E k j).det
      = ∑ g : Fin n → Fin m, (∏ i : Fin n, c i (g i)) *
          (Matrix.of fun i j : Fin n => E (g i) j).det := by
  classical
  have hM : (Matrix.of fun i j : Fin n => ∑ k : Fin m, c i k * E k j)
      = (fun i => ∑ k : Fin m, (fun j : Fin n => c i k * E k j)) := by
    funext i j; simp
  rw [show ((Matrix.of fun i j : Fin n => ∑ k : Fin m, c i k * E k j).det)
      = Matrix.detRowAlternating.toMultilinearMap
          (fun i => ∑ k : Fin m, (fun j : Fin n => c i k * E k j)) from by rw [← hM]; rfl]
  rw [MultilinearMap.map_sum]
  refine Finset.sum_congr rfl fun g _ => ?_
  show (Matrix.of fun i j : Fin n => c i (g i) * E (g i) j).det = _
  rw [Matrix.det_mul_column]
  rfl

/-! ## The auxiliary polynomial -/

variable {n p : ℕ}

/-- The integral polynomial `P(X) = det ((1+X)^{a i * b j})`. -/
noncomputable def chebPoly (a b : Fin n → ℕ) : ℤ[X] :=
  (Matrix.of fun i j : Fin n => (1 + X : ℤ[X]) ^ (a i * b j)).det

/-- The determinant of the matrix of binomial coefficients `C(b i, j)`. -/
noncomputable def chooseDet (b : Fin n → ℕ) : ℤ :=
  (Matrix.of fun i j : Fin n => ((b i).choose (j : ℕ) : ℤ)).det

/-- Row-multilinear expansion of `chebPoly`. -/
theorem chebPoly_expansion (a b : Fin n → ℕ) (hb : ∀ j, b j < p) :
    chebPoly a b = ∑ f : Fin n → Fin p,
      (∏ i : Fin n, ((1 + X : ℤ[X]) ^ (a i) - 1) ^ (f i : ℕ)) *
        C ((Matrix.of fun i j : Fin n => ((b j).choose (f i : ℕ) : ℤ)).det) := by
  classical
  have hentry : ∀ i j : Fin n, (1 + X : ℤ[X]) ^ (a i * b j)
      = ∑ k : Fin p, ((1 + X : ℤ[X]) ^ (a i) - 1) ^ (k : ℕ) * ((b j).choose (k : ℕ) : ℤ[X]) := by
    intro i j
    have h := one_add_pow_eq (R := ℤ[X]) ((1 + X : ℤ[X]) ^ (a i) - 1) (b j) p (hb j)
    rw [show (1 : ℤ[X]) + ((1 + X) ^ (a i) - 1) = (1 + X) ^ (a i) by ring] at h
    rw [pow_mul]
    exact h
  rw [chebPoly, show (Matrix.of fun i j : Fin n => (1 + X : ℤ[X]) ^ (a i * b j))
      = Matrix.of fun i j : Fin n =>
          ∑ k : Fin p, ((1 + X : ℤ[X]) ^ (a i) - 1) ^ (k : ℕ) * ((b j).choose (k : ℕ) : ℤ[X])
      from by funext i j; exact hentry i j]
  rw [det_sum_expansion]
  refine Finset.sum_congr rfl fun f _ => ?_
  congr 1
  rw [RingHom.map_det (Polynomial.C : ℤ →+* ℤ[X])]
  congr 1

/-- Terms of the expansion indexed by a non-injective `f` vanish. -/
theorem term_eq_zero_of_not_injective (b : Fin n → ℕ) {f : Fin n → Fin p}
    (hf : ¬ Function.Injective f) :
    (Matrix.of fun i j : Fin n => ((b j).choose (f i : ℕ) : ℤ)).det = 0 := by
  rw [Function.not_injective_iff] at hf
  obtain ⟨i₁, i₂, heq, hne⟩ := hf
  exact Matrix.det_zero_of_row_eq hne (by funext j; simp [heq])

/-- `X ^ N` divides `chebPoly a b`, where `N` is the staircase number. -/
theorem stair_pow_dvd_chebPoly (a b : Fin n → ℕ) (hb : ∀ j, b j < p) :
    (X : ℤ[X]) ^ stair n ∣ chebPoly a b := by
  classical
  rw [chebPoly_expansion (p := p) a b hb]
  refine Finset.dvd_sum fun f _ => ?_
  by_cases hinj : Function.Injective f
  · refine Dvd.dvd.mul_right ?_ _
    choose w hw _ using fun i : Fin n => exists_shift (a i)
    have hprod : (∏ i : Fin n, ((1 + X : ℤ[X]) ^ (a i) - 1) ^ (f i : ℕ))
        = X ^ (∑ i, (f i : ℕ)) * ∏ i : Fin n, (w i) ^ (f i : ℕ) := by
      simp only [hw, mul_pow]
      rw [Finset.prod_mul_distrib, Finset.prod_pow_eq_pow_sum]
    rw [hprod]
    exact Dvd.dvd.mul_right (pow_dvd_pow _ (stair_le_sum f hinj)) _
  · rw [term_eq_zero_of_not_injective b hinj]
    simp

/-! ## The lowest coefficient -/

/-- Each term of the expansion factors as `X ^ (∑ f i)` times a polynomial with known
constant coefficient. -/
theorem term_factor (a : Fin n → ℕ) (f : Fin n → Fin p) (d : ℤ) :
    ∃ U : ℤ[X], (∏ i : Fin n, ((1 + X : ℤ[X]) ^ (a i) - 1) ^ (f i : ℕ)) * C d
        = X ^ (∑ i, (f i : ℕ)) * U ∧ U.coeff 0 = (∏ i, (a i : ℤ) ^ (f i : ℕ)) * d := by
  classical
  choose w hw hw0 using fun i : Fin n => exists_shift (a i)
  refine ⟨(∏ i : Fin n, (w i) ^ (f i : ℕ)) * C d, ?_, ?_⟩
  · simp only [hw, mul_pow]
    rw [Finset.prod_mul_distrib, Finset.prod_pow_eq_pow_sum, mul_assoc]
  · rw [Polynomial.mul_coeff_zero, Polynomial.coeff_C_zero]
    congr 1
    simp only [← Polynomial.constantCoeff_apply, map_prod, map_pow]
    exact Finset.prod_congr rfl fun i _ => by rw [Polynomial.constantCoeff_apply, hw0]

theorem coeff_term_of_lt (a : Fin n → ℕ) (f : Fin n → Fin p) (d : ℤ)
    (h : stair n < ∑ i, (f i : ℕ)) :
    ((∏ i : Fin n, ((1 + X : ℤ[X]) ^ (a i) - 1) ^ (f i : ℕ)) * C d).coeff (stair n) = 0 := by
  obtain ⟨U, hU, _⟩ := term_factor a f d
  rw [hU, mul_comm, Polynomial.coeff_mul_X_pow']
  simp [Nat.not_le.mpr h]

theorem coeff_term_of_eq (a : Fin n → ℕ) (f : Fin n → Fin p) (d : ℤ)
    (h : ∑ i, (f i : ℕ) = stair n) :
    ((∏ i : Fin n, ((1 + X : ℤ[X]) ^ (a i) - 1) ^ (f i : ℕ)) * C d).coeff (stair n)
      = (∏ i, (a i : ℤ) ^ (f i : ℕ)) * d := by
  obtain ⟨U, hU, hU0⟩ := term_factor a f d
  rw [hU, h, mul_comm, Polynomial.coeff_mul_X_pow']
  simp [hU0]

/-- The coefficient of `X^N` in `chebPoly a b` is `det (vandermonde a) * chooseDet b`. -/
theorem chebPoly_coeff_stair (a b : Fin n → ℕ) (hb : ∀ j, b j < p) (hnp : n ≤ p) :
    (chebPoly a b).coeff (stair n)
      = (Matrix.vandermonde fun i : Fin n => (a i : ℤ)).det * chooseDet b := by
  classical
  rw [chebPoly_expansion (p := p) a b hb, Polynomial.finset_sum_coeff]
  set F : (Fin n → Fin p) → ℤ := fun f =>
    ((∏ i : Fin n, ((1 + X : ℤ[X]) ^ (a i) - 1) ^ (f i : ℕ)) *
      C ((Matrix.of fun i j : Fin n => ((b j).choose (f i : ℕ) : ℤ)).det)).coeff (stair n) with hF
  set Φ : (Fin n → Fin n) → (Fin n → Fin p) := fun g i => Fin.castLE hnp (g i) with hΦ
  have hΦinj : Function.Injective Φ := by
    intro g₁ g₂ h
    funext i
    have := congrFun h i
    simpa [hΦ] using this
  have hzero : ∀ f ∈ (Finset.univ : Finset (Fin n → Fin p)),
      f ∉ Finset.univ.image Φ → F f = 0 := by
    intro f _ hf
    have hex : ∃ i, n ≤ (f i : ℕ) := by
      by_contra hcon
      push_neg at hcon
      exact hf (Finset.mem_image.mpr ⟨fun i => ⟨f i, hcon i⟩, Finset.mem_univ _,
        by funext i; simp [hΦ]⟩)
    by_cases hinj : Function.Injective f
    · refine coeff_term_of_lt a f _ ?_
      rcases lt_or_eq_of_le (stair_le_sum f hinj) with h | h
      · exact h
      · obtain ⟨i, hi⟩ := hex
        exact absurd (lt_of_sum_eq_stair f hinj h.symm i) (by omega)
    · rw [hF]
      simp [term_eq_zero_of_not_injective b hinj]
  rw [← Finset.sum_subset (Finset.subset_univ (Finset.univ.image Φ)) hzero]
  rw [Finset.sum_image (fun x _ y _ h => hΦinj h)]
  have hterm : ∀ g : Fin n → Fin n, F (Φ g)
      = (∏ i, (a i : ℤ) ^ (g i : ℕ)) *
        (Matrix.of fun i j : Fin n => ((b j).choose (g i : ℕ) : ℤ)).det := by
    intro g
    by_cases hg : Function.Injective g
    · have hsum : ∑ i, ((Φ g) i : ℕ) = stair n := by
        have hb2 : Function.Bijective g := Finite.injective_iff_bijective.mp hg
        have hs : ∑ i, (g i : ℕ) = ∑ i : Fin n, (i : ℕ) :=
          Fintype.sum_bijective g hb2 _ _ fun i => rfl
        simpa [hΦ, stair, Fin.sum_univ_eq_sum_range (fun i => i) n] using hs
      rw [hF]
      simp only
      rw [coeff_term_of_eq a (Φ g) _ hsum]
      simp [hΦ]
    · have hΦg : ¬ Function.Injective (Φ g) := fun h => hg fun x y hxy => h (by simp [hΦ, hxy])
      rw [hF]
      simp only
      rw [term_eq_zero_of_not_injective b hΦg]
      have hz : (Matrix.of fun i j : Fin n => ((b j).choose (g i : ℕ) : ℤ)).det = 0 := by
        rw [Function.not_injective_iff] at hg
        obtain ⟨i₁, i₂, heq, hne⟩ := hg
        exact Matrix.det_zero_of_row_eq hne (by funext j; simp [heq])
      simp [hz]
  rw [Finset.sum_congr rfl fun g _ => hterm g]
  rw [← det_sum_expansion (fun (i : Fin n) (k : Fin n) => (a i : ℤ) ^ (k : ℕ))
      (fun (k : Fin n) (j : Fin n) => ((b j).choose (k : ℕ) : ℤ))]
  rw [show (Matrix.of fun i j : Fin n =>
        ∑ k : Fin n, (a i : ℤ) ^ (k : ℕ) * ((b j).choose (k : ℕ) : ℤ))
      = (Matrix.vandermonde fun i : Fin n => (a i : ℤ)) *
        (Matrix.of fun k j : Fin n => ((b j).choose (k : ℕ) : ℤ)) from by
    funext i j; simp [Matrix.mul_apply, Matrix.vandermonde_apply]]
  rw [Matrix.det_mul, chooseDet]
  congr 1
  rw [← Matrix.det_transpose]
  rfl

/-! ## The coefficient is prime to `p` -/

theorem not_dvd_vandermonde (hp : p.Prime) (a : Fin n → ℕ) (ha : Function.Injective a)
    (ha' : ∀ i, a i < p) :
    ¬ ((p : ℤ) ∣ (Matrix.vandermonde fun i : Fin n => (a i : ℤ)).det) := by
  rw [Matrix.det_vandermonde]
  intro hdvd
  have hpz : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  rw [hpz.dvd_finset_prod_iff] at hdvd
  obtain ⟨i, _, hi⟩ := hdvd
  rw [hpz.dvd_finset_prod_iff] at hi
  obtain ⟨j, hj, hij⟩ := hi
  have hne : a j ≠ a i := fun h => (Finset.mem_Ioi.mp hj).ne' (ha h)
  obtain ⟨k, hk⟩ := hij
  have h1 := ha' i
  have h2 := ha' j
  have hnz : (a j : ℤ) - (a i : ℤ) ≠ 0 := by
    simp only [sub_ne_zero]; exact_mod_cast hne
  have hp0 : 0 < (p : ℤ) := by exact_mod_cast hp.pos
  rcases lt_trichotomy k 0 with h | h | h
  · nlinarith [hk]
  · simp [h] at hk; exact hnz hk
  · nlinarith [hk]

theorem superFactorial_mul_chooseDet (b : Fin n → ℕ) :
    (∏ j : Fin n, (Nat.factorial (j : ℕ) : ℤ)) * chooseDet b
      = (Matrix.vandermonde fun i : Fin n => (b i : ℤ)).det := by
  rw [Matrix.det_eval_matrixOfPolynomials_eq_det_vandermonde (fun i => (b i : ℤ))
      (fun j => descPochhammer ℤ j) (fun j => descPochhammer_natDegree ℤ j)
      (fun j => monic_descPochhammer ℤ j)]
  rw [chooseDet, ← Matrix.det_mul_row (fun j : Fin n => (Nat.factorial (j : ℕ) : ℤ))]
  congr 1
  ext i j
  simp only [Matrix.of_apply]
  rw [descPochhammer_eval_eq_descFactorial ℤ, Nat.descFactorial_eq_factorial_mul_choose]
  push_cast
  ring

theorem not_dvd_chooseDet (hp : p.Prime) (b : Fin n → ℕ) (hb : Function.Injective b)
    (hb' : ∀ j, b j < p) : ¬ ((p : ℤ) ∣ chooseDet b) := by
  intro h
  refine not_dvd_vandermonde hp b hb hb' ?_
  rw [← superFactorial_mul_chooseDet b]
  exact Dvd.dvd.mul_left h _

/-! ## The shifted cyclotomic polynomial -/

/-- `Φ_p(X + 1)`. -/
noncomputable def shiftedCyclotomic (p : ℕ) : ℤ[X] := (cyclotomic p ℤ).comp (X + 1)

theorem X_mul_shiftedCyclotomic (hp : p.Prime) :
    X * shiftedCyclotomic p = (1 + X : ℤ[X]) ^ p - 1 := by
  haveI := Fact.mk hp
  rw [shiftedCyclotomic, Polynomial.cyclotomic_prime ℤ p, Polynomial.sum_comp]
  simp only [Polynomial.X_pow_comp]
  have h := geom_sum_mul (X + 1 : ℤ[X]) p
  rw [show (X + 1 : ℤ[X]) - 1 = X by ring] at h
  rw [mul_comm, h]
  ring_nf

theorem coeff_shiftedCyclotomic (hp : p.Prime) (k : ℕ) :
    (shiftedCyclotomic p).coeff k = (p.choose (k + 1) : ℤ) := by
  have h := X_mul_shiftedCyclotomic hp
  have h2 : (X * shiftedCyclotomic p).coeff (k + 1) = (shiftedCyclotomic p).coeff k :=
    Polynomial.coeff_X_mul _ _
  rw [h] at h2
  rw [← h2, Polynomial.coeff_sub, Polynomial.coeff_one_add_X_pow]
  simp [Polynomial.coeff_one]

/-- Frenkel's divisibility step: if the shifted cyclotomic polynomial divides `P` and `P`
vanishes to order `N` at `0`, then `p` divides the `N`-th coefficient of `P`. -/
theorem prime_dvd_coeff_of_shiftedCyclotomic_dvd (hp : p.Prime) (P : ℤ[X]) (N : ℕ)
    (hdvd : shiftedCyclotomic p ∣ P) (hlow : ∀ m < N, P.coeff m = 0) :
    (p : ℤ) ∣ P.coeff N := by
  obtain ⟨Q, rfl⟩ := hdvd
  set Φ := shiftedCyclotomic p with hΦ
  have hp2 : 2 ≤ p := hp.two_le
  have hΦ0 : Φ.coeff 0 = (p : ℤ) := by rw [hΦ, coeff_shiftedCyclotomic hp]; simp
  have hQ : ∀ m : ℕ, m + (p - 1) ≤ N → Q.coeff m = 0 := by
    intro m
    induction m using Nat.strong_induction_on with
    | _ m ih =>
      intro hm
      have hcoeff : (Φ * Q).coeff m = Φ.coeff 0 * Q.coeff m := by
        rw [Polynomial.coeff_mul]
        refine Finset.sum_eq_single (0, m) ?_ ?_
        · rintro ⟨k, l⟩ hkl hne
          rw [Finset.mem_antidiagonal] at hkl
          have hl : l < m := by
            rcases Nat.eq_zero_or_pos k with hk | hk
            · exfalso; apply hne; subst hk; simp at hkl ⊢; omega
            · omega
          rw [ih l hl (by omega)]
          ring
        · intro h; exact absurd (Finset.mem_antidiagonal.mpr (by omega)) h
      have hz : (Φ * Q).coeff m = 0 := hlow m (by omega)
      rw [hcoeff, hΦ0] at hz
      have hpne : (p : ℤ) ≠ 0 := by exact_mod_cast hp.ne_zero
      exact (mul_eq_zero.mp hz).resolve_left hpne
  rw [Polynomial.coeff_mul]
  refine Finset.dvd_sum ?_
  rintro ⟨k, l⟩ hkl
  rw [Finset.mem_antidiagonal] at hkl
  by_cases hk : k + 1 < p
  · refine Dvd.dvd.mul_right ?_ _
    rw [hΦ, coeff_shiftedCyclotomic hp]
    exact_mod_cast Int.natCast_dvd_natCast.mpr (hp.dvd_choose_self (by omega) hk)
  · rw [hQ l (by omega)]; simp

/-! ## Main theorem -/

/-- **Chebotarev's theorem**: for `p` prime and `ζ` a primitive `p`-th root of unity in a
field of characteristic zero, every square submatrix `(ζ^{a i * b j})` of the DFT matrix
indexed by distinct residues `a i`, `b j` is nonsingular. -/
theorem det_ne_zero {K : Type*} [Field K] [CharZero K] {ζ : K} (hp : p.Prime)
    (hζ : IsPrimitiveRoot ζ p) (a b : Fin n → ℕ)
    (ha : Function.Injective a) (ha' : ∀ i, a i < p)
    (hb : Function.Injective b) (hb' : ∀ j, b j < p) :
    (Matrix.of fun i j : Fin n => ζ ^ (a i * b j)).det ≠ 0 := by
  intro hdet
  have hnp : n ≤ p := by
    have hinj : Function.Injective (fun i : Fin n => (⟨a i, ha' i⟩ : Fin p)) := by
      intro x y h; exact ha (by simpa using congrArg Fin.val h)
    simpa using Fintype.card_le_of_injective _ hinj
  set P := chebPoly a b with hP
  -- Step 1: `P` vanishes at `ζ - 1`.
  have h1 : (Polynomial.aeval (ζ - 1)) P = 0 := by
    rw [hP, chebPoly, AlgHom.map_det (Polynomial.aeval (ζ - 1) : ℤ[X] →ₐ[ℤ] K), ← hdet]
    congr 1
    ext i j
    simp
  -- Step 2: the shifted cyclotomic polynomial divides `P`.
  have h2 : shiftedCyclotomic p ∣ P := by
    have hint : IsIntegral ℤ ζ := by
      refine ⟨X ^ p - C 1, monic_X_pow_sub_C (1 : ℤ) (by have := hp.pos; omega), ?_⟩
      simp [hζ.pow_eq_one]
    have hroot : (Polynomial.aeval ζ) (P.comp (X - 1)) = 0 := by
      rw [Polynomial.aeval_comp]; simpa using h1
    have hdvd : cyclotomic p ℤ ∣ P.comp (X - 1) := by
      rw [Polynomial.cyclotomic_eq_minpoly hζ hp.pos]
      exact minpoly.isIntegrallyClosed_dvd hint hroot
    obtain ⟨D, hD⟩ := hdvd
    refine ⟨D.comp (X + 1), ?_⟩
    have hcomp := congrArg (fun q : ℤ[X] => q.comp (X + 1)) hD
    simp only [Polynomial.mul_comp] at hcomp
    rw [Polynomial.comp_assoc] at hcomp
    simpa [show ((X : ℤ[X]) - 1).comp (X + 1) = X by simp] using hcomp
  -- Step 3: the coefficients below `N` vanish.
  have h3 : ∀ m < stair n, P.coeff m = 0 := by
    obtain ⟨R, hR⟩ := stair_pow_dvd_chebPoly (p := p) a b hb'
    intro m hm
    rw [hP, hR, mul_comm, Polynomial.coeff_mul_X_pow']
    simp [Nat.not_le.mpr hm]
  -- Step 4: `p` would divide the leading coefficient, which is impossible.
  have h4 := prime_dvd_coeff_of_shiftedCyclotomic_dvd hp P (stair n) h2 h3
  rw [hP, chebPoly_coeff_stair (p := p) a b hb' hnp] at h4
  have hpz : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  rcases hpz.dvd_mul.mp h4 with h | h
  · exact not_dvd_vandermonde hp a ha ha' h
  · exact not_dvd_chooseDet hp b hb hb' h

/-- Quantitative form: the order of vanishing at `X = 0` of `det ((1+X)^{a i b j})` is exactly
`N = 0 + 1 + ⋯ + (n-1)`, since the `N`-th coefficient is prime to `p` (in particular nonzero). -/
theorem not_dvd_chebPoly_coeff_stair (hp : p.Prime) (a b : Fin n → ℕ)
    (ha : Function.Injective a) (ha' : ∀ i, a i < p)
    (hb : Function.Injective b) (hb' : ∀ j, b j < p) :
    ¬ ((p : ℤ) ∣ (chebPoly a b).coeff (stair n)) := by
  have hnp : n ≤ p := by
    have hinj : Function.Injective (fun i : Fin n => (⟨a i, ha' i⟩ : Fin p)) := by
      intro x y h; exact ha (by simpa using congrArg Fin.val h)
    simpa using Fintype.card_le_of_injective _ hinj
  rw [chebPoly_coeff_stair (p := p) a b hb' hnp]
  intro hdvd
  have hpz : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  rcases hpz.dvd_mul.mp hdvd with h | h
  · exact not_dvd_vandermonde hp a ha ha' h
  · exact not_dvd_chooseDet hp b hb hb' h

/-- **Rectangular Chebotarev.** Any `n × m` submatrix of the `p × p` DFT matrix with `n ≤ m`
has full row rank: only the zero vector annihilates all its columns. -/
theorem eq_zero_of_forall_sum_eq_zero {K : Type*} [Field K] [CharZero K] {ζ : K}
    (hp : p.Prime) (hζ : IsPrimitiveRoot ζ p) {m : ℕ} (hnm : n ≤ m)
    (a : Fin n → ℕ) (b : Fin m → ℕ)
    (ha : Function.Injective a) (ha' : ∀ i, a i < p)
    (hb : Function.Injective b) (hb' : ∀ j, b j < p)
    (v : Fin n → K) (hv : ∀ j : Fin m, ∑ i, v i * ζ ^ (a i * b j) = 0) : v = 0 := by
  classical
  set b' : Fin n → ℕ := fun j => b (Fin.castLE hnm j) with hb'def
  have hb'inj : Function.Injective b' := fun x y h => by
    have := hb h
    simpa [Fin.ext_iff] using this
  have hdet := det_ne_zero hp hζ a b' ha ha' hb'inj (fun j => hb' _)
  refine Matrix.eq_zero_of_vecMul_eq_zero hdet ?_
  funext j
  simpa [Matrix.vecMul, dotProduct, hb'def] using hv (Fin.castLE hnm j)

/-- **Converse of Chebotarev's theorem: primality is exactly what is needed.** For every
composite modulus `N > 1` and every primitive `N`-th root of unity `ζ` in a field there is a
singular `2 × 2` submatrix of the `N × N` DFT matrix, indexed by distinct residues. Combined
with `det_ne_zero`, nonsingularity of *all* square submatrices holds precisely for `N` prime. -/
theorem exists_singular_submatrix_of_not_prime {K : Type*} [Field K] {N : ℕ} {ζ : K}
    (hN : 1 < N) (hnp : ¬ N.Prime) (hζ : IsPrimitiveRoot ζ N) :
    ∃ a b : Fin 2 → ℕ, Function.Injective a ∧ Function.Injective b ∧
      (∀ i, a i < N) ∧ (∀ j, b j < N) ∧
      (Matrix.of fun i j : Fin 2 => ζ ^ (a i * b j)).det = 0 := by
  obtain ⟨d, hdvd, hd2, hdN⟩ := Nat.exists_dvd_of_not_prime2 hN hnp
  obtain ⟨e, he⟩ := hdvd
  have he0 : e ≠ 0 := by rintro rfl; omega
  have he2 : 2 ≤ e := by
    rcases Nat.lt_or_ge e 2 with h | h
    · interval_cases e <;> omega
    · exact h
  have heN : e < N := by nlinarith
  refine ⟨![0, e], ![0, d], ?_, ?_, ?_, ?_, ?_⟩
  · intro i j h; fin_cases i <;> fin_cases j <;> simp_all
  · intro i j h
    fin_cases i <;> fin_cases j <;> simp_all
    omega
  · intro i; fin_cases i <;> simp <;> omega
  · intro j; fin_cases j <;> simp <;> omega
  · have hEN : ζ ^ (e * d) = 1 := by
      rw [(mul_comm e d).trans he.symm]
      exact hζ.pow_eq_one
    rw [Matrix.det_fin_two]
    simp [Matrix.of_apply, hEN]

end ChebotarevDFT