/-
# Chebotarev's theorem on the minors of the prime-order DFT matrix

Let `p` be a prime and `ζ` a primitive `p`-th root of unity.  Chebotarev's theorem states that
*every* square submatrix of the `p × p` DFT matrix `(ζ^{xy})_{x,y ∈ ZMod p}` is nonsingular.

This file gives a complete, elementary formalisation following Frenkel's argument:

* the determinant `det (X^{a_i b_j})` is a polynomial `F ∈ ℤ[X]`;
* after the substitution `X ↦ X + 1` the resulting polynomial `G` vanishes to order exactly
  `N = 0 + 1 + ⋯ + (k-1)` at `0`, with `N`-th coefficient `c_N` satisfying
  `(∏_{j<k} j!) * c_N = V(a) * V(b)` (a product of two Vandermonde determinants);
* if `F(ζ) = 0` then the cyclotomic polynomial divides `F`, hence `Φ_p(X+1) ∣ G`; since
  `Φ_p(X+1)` has constant coefficient `p`, multiplicativity of trailing coefficients forces
  `p ∣ c_N`, contradicting `p ∤ V(a) V(b)`.

Main result: `Chebotarev.det_pow_ne_zero`.
-/

import Mathlib

open Finset Polynomial

namespace Chebotarev

/-! ## Combinatorial preliminaries -/

/-- The sum of a finite set of `k` distinct naturals is at least `0 + 1 + ⋯ + (k-1)`. -/
theorem sum_range_card_le (S : Finset ℕ) : ∑ i ∈ range S.card, i ≤ ∑ x ∈ S, x := by
  induction S using Finset.induction_on_max with
  | h0 => simp
  | step a s ha ih =>
    have hmem : a ∉ s := fun h => absurd (ha a h) (lt_irrefl a)
    rw [Finset.card_insert_of_notMem hmem, Finset.sum_insert hmem, Finset.sum_range_succ]
    have hcard : s.card ≤ a := by
      have : s ⊆ range a := fun x hx => Finset.mem_range.2 (ha x hx)
      simpa using Finset.card_le_card this
    omega

/-- Equality in `sum_range_card_le` forces the set to be an initial segment. -/
theorem eq_range_of_sum_eq (S : Finset ℕ) (h : ∑ x ∈ S, x = ∑ i ∈ range S.card, i) :
    S = range S.card := by
  induction S using Finset.induction_on_max with
  | h0 => simp
  | step a s ha ih =>
    have hmem : a ∉ s := fun h => absurd (ha a h) (lt_irrefl a)
    rw [Finset.card_insert_of_notMem hmem, Finset.sum_insert hmem, Finset.sum_range_succ] at h
    rw [Finset.card_insert_of_notMem hmem]
    have hcard : s.card ≤ a := by
      have : s ⊆ range a := fun x hx => Finset.mem_range.2 (ha x hx)
      simpa using Finset.card_le_card this
    have h2 := sum_range_card_le s
    have ha' : a = s.card := by omega
    have hs : ∑ x ∈ s, x = ∑ i ∈ range s.card, i := by omega
    rw [Finset.range_add_one, ha']
    exact congrArg _ (ih hs)

variable {k : ℕ}

/-- An injective `m : Fin k → ℕ` has sum at least `0 + 1 + ⋯ + (k-1)`. -/
theorem inj_sum_ge {m : Fin k → ℕ} (hm : Function.Injective m) :
    ∑ i ∈ range k, i ≤ ∑ i, m i := by
  have hcard : (Finset.image m univ).card = k := by
    rw [Finset.card_image_of_injective _ hm]; simp
  have hsum : ∑ x ∈ Finset.image m univ, x = ∑ i, m i :=
    Finset.sum_image (fun x _ y _ h => hm h)
  have := sum_range_card_le (Finset.image m univ)
  rw [hcard, hsum] at this
  exact this

/-- An injective `m : Fin k → ℕ` of minimal sum takes values in `{0, …, k-1}`. -/
theorem inj_lt_of_sum_eq {m : Fin k → ℕ} (hm : Function.Injective m)
    (h : ∑ i, m i = ∑ i ∈ range k, i) (i : Fin k) : m i < k := by
  have hcard : (Finset.image m univ).card = k := by
    rw [Finset.card_image_of_injective _ hm]; simp
  have hsum : ∑ x ∈ Finset.image m univ, x = ∑ i, m i :=
    Finset.sum_image (fun x _ y _ h => hm h)
  have himg := eq_range_of_sum_eq (Finset.image m univ) (by rw [hcard, hsum]; exact h)
  rw [hcard] at himg
  have : m i ∈ Finset.range k := by
    rw [← himg]; exact Finset.mem_image_of_mem m (mem_univ i)
  exact Finset.mem_range.1 this

/-- `d! * C(n, d) = n (n-1) ⋯ (n-d+1)`, as an identity in `ℤ`. -/
theorem factorial_mul_choose (n d : ℕ) :
    ((Nat.factorial d : ℤ)) * (n.choose d) = ∏ j ∈ range d, ((n : ℤ) - j) := by
  induction d with
  | zero => simp
  | succ d ih =>
    rw [Finset.prod_range_succ, ← ih, Nat.factorial_succ]
    have h := Nat.choose_succ_right_eq n d
    rcases Nat.lt_or_ge n d with hd | hd
    · have h1 : n.choose (d + 1) = 0 := Nat.choose_eq_zero_of_lt (by omega)
      have h2 : n.choose d = 0 := Nat.choose_eq_zero_of_lt (by omega)
      simp [h1, h2]
    · have key : ((n.choose (d + 1) : ℤ)) * (d + 1) = (n.choose d : ℤ) * ((n : ℤ) - d) := by
        have := congrArg (fun x : ℕ => (x : ℤ)) h
        push_cast at this
        rw [this]
        congr 1
        omega
      push_cast
      nlinarith [key]

/-- The falling-factorial polynomial `X (X-1) ⋯ (X-d+1)`. -/
noncomputable def Dpoly (d : ℕ) : ℤ[X] := ∏ j ∈ range d, (X - C (j : ℤ))

theorem Dpoly_monic (d : ℕ) : (Dpoly d).Monic :=
  monic_prod_of_monic _ _ fun _ _ => monic_X_sub_C _

theorem Dpoly_natDegree (d : ℕ) : (Dpoly d).natDegree = d := by
  rw [Dpoly, Polynomial.natDegree_prod _ _ (fun j _ => X_sub_C_ne_zero _)]
  simp only [Polynomial.natDegree_X_sub_C]
  simp

theorem Dpoly_eval (d : ℕ) (y : ℤ) : (Dpoly d).eval y = ∏ j ∈ range d, (y - j) := by
  simp [Dpoly, Polynomial.eval_prod]

theorem Dpoly_coeff_top (d : ℕ) : (Dpoly d).coeff d = 1 := by
  have := (Dpoly_monic d).leadingCoeff
  rwa [Polynomial.leadingCoeff, Dpoly_natDegree] at this

/-! ## The alternating power sums -/

/-- `Nsum k = 0 + 1 + ⋯ + (k-1)`, the order of vanishing. -/
def Nsum (k : ℕ) : ℕ := ∑ i ∈ range k, i

/-- The superfactorial `∏_{j<k} j!`. -/
def SuperFactorial (k : ℕ) : ℕ := ∏ j ∈ range k, Nat.factorial j

theorem superFactorial_pos (k : ℕ) : 0 < SuperFactorial k :=
  Finset.prod_pos fun j _ => Nat.factorial_pos j

/-- The alternating power sums `T_r = ∑_σ sgn(σ) (∑_i a_{σ i} b_i)^r`. -/
def PowSum (a b : Fin k → ℕ) (r : ℕ) : ℤ :=
  ∑ σ : Equiv.Perm (Fin k), (Equiv.Perm.sign σ : ℤ) * ((∑ i, a (σ i) * b i : ℕ) : ℤ) ^ r

/-- Multinomial expansion of the alternating power sums. -/
theorem powSum_expand (a b : Fin k → ℕ) (r : ℕ) :
    PowSum a b r = ∑ m ∈ (univ : Finset (Fin k)).piAntidiag r,
      (Nat.multinomial univ m : ℤ) * (∏ i, (b i : ℤ) ^ (m i)) *
        (Matrix.of fun i j => (a i : ℤ) ^ (m j)).det := by
  unfold PowSum
  have h1 : ∀ σ : Equiv.Perm (Fin k),
      ((∑ i, a (σ i) * b i : ℕ) : ℤ) = ∑ i, (a (σ i) : ℤ) * (b i) := by
    intro σ; push_cast; ring
  simp only [h1, Finset.sum_pow_eq_sum_piAntidiag, Finset.mul_sum]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun m _ => ?_
  rw [Matrix.det_apply, Finset.mul_sum]
  refine Finset.sum_congr rfl fun σ _ => ?_
  simp only [Matrix.of_apply, Units.smul_def, zsmul_eq_mul, mul_pow, Finset.prod_mul_distrib]
  push_cast
  ring

/-- A non-injective exponent vector contributes nothing: two columns coincide. -/
theorem det_pow_eq_zero_of_not_injective (b : Fin k → ℕ) {m : Fin k → ℕ}
    (hm : ¬ Function.Injective m) :
    (Matrix.of fun i j => (b i : ℤ) ^ (m j)).det = 0 := by
  rw [Function.not_injective_iff] at hm
  obtain ⟨x, y, hxy, hne⟩ := hm
  exact Matrix.det_zero_of_column_eq hne fun i => by simp [hxy]

/-- Below the critical order all alternating power sums vanish. -/
theorem powSum_eq_zero_of_lt (a b : Fin k → ℕ) {r : ℕ} (hr : r < Nsum k) :
    PowSum a b r = 0 := by
  rw [powSum_expand]
  refine Finset.sum_eq_zero fun m hm => ?_
  rw [Finset.mem_piAntidiag] at hm
  have hmi : ¬ Function.Injective m := by
    intro hinj
    have h2 := inj_sum_ge hinj
    rw [show (univ : Finset (Fin k)).sum m = ∑ i, m i from rfl] at hm
    rw [hm.1] at h2
    exact absurd (h2.trans_lt hr) (lt_irrefl _)
  rw [det_pow_eq_zero_of_not_injective a hmi, mul_zero]

/-- The Vandermonde determinant attached to `a : Fin k → ℕ`. -/
def Vand (a : Fin k → ℕ) : ℤ := (Matrix.vandermonde fun i => (a i : ℤ)).det

theorem vand_eq (a : Fin k → ℕ) :
    Vand a = ∑ σ : Equiv.Perm (Fin k), (Equiv.Perm.sign σ : ℤ) * ∏ i, (a i : ℤ) ^ (σ i : ℕ) := by
  rw [Vand, ← Matrix.det_transpose, Matrix.det_apply]
  refine Finset.sum_congr rfl fun σ _ => ?_
  simp [Matrix.vandermonde, Units.smul_def]

/-- The exponent vector attached to a permutation. -/
def Theta (τ : Equiv.Perm (Fin k)) : Fin k → ℕ := fun j => ((τ j : Fin k) : ℕ)

theorem theta_inj : Function.Injective (Theta (k := k)) := by
  intro τ τ' h
  ext j
  have := congrFun h j
  simpa [Theta, Fin.val_inj] using this

theorem theta_mem (τ : Equiv.Perm (Fin k)) :
    Theta τ ∈ (univ : Finset (Fin k)).piAntidiag (Nsum k) := by
  rw [Finset.mem_piAntidiag]
  refine ⟨?_, fun i _ => mem_univ i⟩
  have h : ∑ j, Theta τ j = ∑ j : Fin k, (j : ℕ) := Equiv.sum_comp τ (fun i : Fin k => (i : ℕ))
  rw [show (univ : Finset (Fin k)).sum (Theta τ) = ∑ j, Theta τ j from rfl, h, Nsum,
    Fin.sum_univ_eq_sum_range (fun i => i) k]

theorem exists_theta {m : Fin k → ℕ} (hinj : Function.Injective m)
    (hsum : ∑ i, m i = Nsum k) : ∃ τ : Equiv.Perm (Fin k), Theta τ = m := by
  have hlt : ∀ i, m i < k := inj_lt_of_sum_eq hinj hsum
  let g : Fin k → Fin k := fun i => ⟨m i, hlt i⟩
  have hg : Function.Injective g := by
    intro x y hxy
    exact hinj (by simpa [g, Fin.mk_eq_mk] using hxy)
  exact ⟨Equiv.ofBijective g (Finite.injective_iff_bijective.1 hg), rfl⟩

theorem superFactorial_mul_multinomial (τ : Equiv.Perm (Fin k)) :
    (SuperFactorial k : ℤ) * (Nat.multinomial univ (Theta τ) : ℤ)
      = (Nat.factorial (Nsum k) : ℤ) := by
  have h := Nat.multinomial_spec (univ : Finset (Fin k)) (Theta τ)
  have hprod : ∏ i, Nat.factorial (Theta τ i) = SuperFactorial k := by
    rw [show (∏ i, Nat.factorial (Theta τ i)) = ∏ i : Fin k, Nat.factorial (i : ℕ) from
      Equiv.prod_comp τ (fun i : Fin k => Nat.factorial (i : ℕ)), SuperFactorial,
      Fin.prod_univ_eq_prod_range (fun i => Nat.factorial i) k]
  have hsum : ∑ i, Theta τ i = Nsum k := by
    have h2 := theta_mem τ
    rw [Finset.mem_piAntidiag] at h2
    exact h2.1
  rw [hprod, hsum] at h
  exact_mod_cast congrArg (fun n : ℕ => (n : ℤ)) h

theorem det_theta (a : Fin k → ℕ) (τ : Equiv.Perm (Fin k)) :
    (Matrix.of fun i j => (a i : ℤ) ^ (Theta τ j)).det = (Equiv.Perm.sign τ : ℤ) * Vand a := by
  have h : (Matrix.of fun i j => (a i : ℤ) ^ (Theta τ j))
      = (Matrix.vandermonde fun i => (a i : ℤ)).submatrix id τ := by
    ext i j; simp [Matrix.vandermonde, Theta]
  rw [h, Matrix.det_permute', Vand]
  push_cast
  ring

/-- **The critical power sum.**  `T_N` is, up to factorials, the product of the two
Vandermonde determinants of the exponent vectors. -/
theorem powSum_top (a b : Fin k → ℕ) :
    (SuperFactorial k : ℤ) * PowSum a b (Nsum k) =
      (Nat.factorial (Nsum k) : ℤ) * Vand a * Vand b := by
  rw [powSum_expand, Finset.mul_sum]
  rw [← Finset.sum_subset (s₁ := Finset.image Theta univ)
      (fun m hm => by
        obtain ⟨τ, _, rfl⟩ := Finset.mem_image.1 hm
        exact theta_mem τ)
      (fun m hm hnm => ?_)]
  · rw [Finset.sum_image (fun x _ y _ h => theta_inj h), vand_eq b, Finset.mul_sum]
    refine Finset.sum_congr rfl fun τ _ => ?_
    rw [det_theta]
    rw [show (SuperFactorial k : ℤ) * ((Nat.multinomial univ (Theta τ) : ℤ) *
        (∏ i, (b i : ℤ) ^ (Theta τ i)) * ((Equiv.Perm.sign τ : ℤ) * Vand a))
      = ((SuperFactorial k : ℤ) * (Nat.multinomial univ (Theta τ) : ℤ)) * Vand a *
        ((Equiv.Perm.sign τ : ℤ) * ∏ i, (b i : ℤ) ^ (Theta τ i)) by ring]
    rw [superFactorial_mul_multinomial]
    rfl
  · rw [Finset.mem_piAntidiag] at hm
    have hni : ¬ Function.Injective m := by
      intro hinj
      obtain ⟨τ, hτ⟩ := exists_theta hinj hm.1
      exact hnm (Finset.mem_image.2 ⟨τ, mem_univ τ, hτ⟩)
    rw [det_pow_eq_zero_of_not_injective a hni]
    ring

/-! ## The polynomial `F` and its shift -/

/-- The determinant `det (X^{a_i b_j}) ∈ ℤ[X]`. -/
noncomputable def dftPoly (a b : Fin k → ℕ) : ℤ[X] :=
  (Matrix.of fun i j => (X : ℤ[X]) ^ (a i * b j)).det

/-- The shifted polynomial `G(X) = F(X+1)`. -/
noncomputable def shifted (a b : Fin k → ℕ) : ℤ[X] := (dftPoly a b).comp (X + 1)

theorem shifted_eq (a b : Fin k → ℕ) :
    shifted a b = (Matrix.of fun i j => ((X : ℤ[X]) + 1) ^ (a i * b j)).det := by
  have h : shifted a b = ((aeval ((X : ℤ[X]) + 1) : ℤ[X] →ₐ[ℤ] ℤ[X]).toRingHom)
      (Matrix.of fun i j => (X : ℤ[X]) ^ (a i * b j)).det := by
    rw [shifted, dftPoly, Polynomial.comp_eq_aeval]; rfl
  rw [h, RingHom.map_det]
  congr 1
  ext i j
  simp

theorem shifted_coeff (a b : Fin k → ℕ) (d : ℕ) :
    (shifted a b).coeff d =
      ∑ σ : Equiv.Perm (Fin k), (Equiv.Perm.sign σ : ℤ) * ((∑ i, a (σ i) * b i).choose d : ℤ) := by
  rw [shifted_eq, Matrix.det_apply, Polynomial.finset_sum_coeff]
  refine Finset.sum_congr rfl fun σ _ => ?_
  simp only [Matrix.of_apply, Units.smul_def, zsmul_eq_mul, Finset.prod_pow_eq_pow_sum]
  rw [Polynomial.coeff_intCast_mul, Polynomial.coeff_X_add_one_pow]
  push_cast
  ring

/-- The `d`-th coefficient of `G`, times `d!`, is an integer combination of power sums. -/
theorem factorial_mul_shifted_coeff (a b : Fin k → ℕ) (d : ℕ) :
    (Nat.factorial d : ℤ) * (shifted a b).coeff d =
      ∑ r ∈ range (d + 1), (Dpoly d).coeff r * PowSum a b r := by
  rw [shifted_coeff a b d, Finset.mul_sum]
  have step1 : ∀ σ : Equiv.Perm (Fin k),
      (Nat.factorial d : ℤ) * ((Equiv.Perm.sign σ : ℤ) * ((∑ i, a (σ i) * b i).choose d : ℤ))
        = ∑ r ∈ range (d + 1), (Equiv.Perm.sign σ : ℤ) *
            ((Dpoly d).coeff r * ((∑ i, a (σ i) * b i : ℕ) : ℤ) ^ r) := by
    intro σ
    rw [← Finset.mul_sum, ← Polynomial.eval_eq_sum_range' (by rw [Dpoly_natDegree]; omega),
      Dpoly_eval, ← factorial_mul_choose]
    ring
  simp only [step1]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun r _ => ?_
  rw [PowSum, Finset.mul_sum]
  refine Finset.sum_congr rfl fun σ _ => ?_
  ring

/-- `G` vanishes to order at least `N`. -/
theorem shifted_coeff_eq_zero (a b : Fin k → ℕ) {d : ℕ} (hd : d < Nsum k) :
    (shifted a b).coeff d = 0 := by
  have h := factorial_mul_shifted_coeff a b d
  rw [Finset.sum_eq_zero (fun r hr => by
    rw [powSum_eq_zero_of_lt a b (lt_of_le_of_lt (by
      have := Finset.mem_range.1 hr; omega) hd), mul_zero])] at h
  have hfac : (Nat.factorial d : ℤ) ≠ 0 := by
    exact_mod_cast Nat.factorial_ne_zero d
  exact (mul_eq_zero.1 h).resolve_left hfac

/-- **The critical coefficient of `G`.** -/
theorem superFactorial_mul_shifted_coeff_top (a b : Fin k → ℕ) :
    (SuperFactorial k : ℤ) * (shifted a b).coeff (Nsum k) = Vand a * Vand b := by
  have h := factorial_mul_shifted_coeff a b (Nsum k)
  rw [Finset.sum_range_succ, Dpoly_coeff_top, one_mul,
    Finset.sum_eq_zero (fun r hr => by
      rw [powSum_eq_zero_of_lt a b (Finset.mem_range.1 hr), mul_zero]), zero_add] at h
  have h2 : (Nat.factorial (Nsum k) : ℤ) * ((SuperFactorial k : ℤ) * (shifted a b).coeff (Nsum k))
      = (Nat.factorial (Nsum k) : ℤ) * (Vand a * Vand b) := by
    have h3 := powSum_top a b
    rw [← h] at h3
    linarith [h3]
  have hfac : (Nat.factorial (Nsum k) : ℤ) ≠ 0 := by
    exact_mod_cast Nat.factorial_ne_zero _
  exact mul_left_cancel₀ hfac h2

/-! ## Non-divisibility of the Vandermonde product -/

theorem prime_not_dvd_vand {p : ℕ} (hp : p.Prime) (a : Fin k → ℕ) (ha : ∀ i, a i < p)
    (hainj : Function.Injective a) : ¬ ((p : ℤ) ∣ Vand a) := by
  rw [Vand, Matrix.det_vandermonde]
  intro hdvd
  have hpz : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  rw [Prime.dvd_finset_prod_iff hpz] at hdvd
  obtain ⟨i, _, hi⟩ := hdvd
  rw [Prime.dvd_finset_prod_iff hpz] at hi
  obtain ⟨j, hj, hij⟩ := hi
  have hne : a j ≠ a i := fun h => absurd (hainj h) (by
    have := Finset.mem_Ioi.1 hj
    exact fun hh => absurd hh (by omega))
  have h1 : ((a j : ℤ) - a i) ≠ 0 := by
    intro h
    exact hne (by exact_mod_cast sub_eq_zero.1 h)
  have h2 : |(a j : ℤ) - a i| < p := by
    have := ha i; have := ha j
    rw [abs_lt]; constructor <;> omega
  have h3 : (p : ℤ) ≤ |(a j : ℤ) - a i| := Int.le_of_dvd (abs_pos.2 h1) ((dvd_abs _ _).2 hij)
  omega

/-! ## Chebotarev's theorem -/

/-- **Chebotarev's theorem.**  If `ζ` is a primitive `p`-th root of unity with `p` prime and
`a, b : Fin k → ℕ` are injective with values `< p`, then the `k × k` matrix `(ζ^{a_i b_j})` is
nonsingular.  Equivalently: every minor of the DFT matrix of prime order is nonzero. -/
theorem det_pow_ne_zero {p : ℕ} (hp : p.Prime) {ζ : ℂ} (hζ : IsPrimitiveRoot ζ p)
    {k : ℕ} (a b : Fin k → ℕ) (ha : ∀ i, a i < p) (hb : ∀ j, b j < p)
    (hainj : Function.Injective a) (hbinj : Function.Injective b) :
    (Matrix.of fun i j => ζ ^ (a i * b j)).det ≠ 0 := by
  haveI : Fact p.Prime := ⟨hp⟩
  intro hdet
  -- The determinant is the value of the integer polynomial `F` at `ζ`.
  have hFζ : (Polynomial.aeval ζ) (dftPoly a b) = 0 := by
    have h : (Polynomial.aeval ζ : ℤ[X] →ₐ[ℤ] ℂ).toRingHom (dftPoly a b)
        = (Matrix.of fun i j => ζ ^ (a i * b j)).det := by
      rw [dftPoly, RingHom.map_det]
      congr 1
      ext i j
      simp
    rw [show (Polynomial.aeval ζ) (dftPoly a b)
      = (Polynomial.aeval ζ : ℤ[X] →ₐ[ℤ] ℂ).toRingHom (dftPoly a b) from rfl, h, hdet]
  -- Hence the cyclotomic polynomial divides `F`.
  have hcyc : (cyclotomic p ℤ) ∣ dftPoly a b := by
    rw [Polynomial.cyclotomic_eq_minpoly hζ hp.pos]
    exact minpoly.isIntegrallyClosed_dvd (hζ.isIntegral hp.pos) hFζ
  obtain ⟨h, hh⟩ := hcyc
  -- ... and therefore `Φ_p(X+1)` divides `G`.
  set g : ℤ[X] := (cyclotomic p ℤ).comp (X + 1) with hg
  have hGg : shifted a b = g * h.comp (X + 1) := by
    rw [shifted, hh, Polynomial.mul_comp, hg]
  -- `g` has constant coefficient `p`.
  have hg0 : g.coeff 0 = (p : ℤ) := by
    rw [Polynomial.coeff_zero_eq_eval_zero, hg, Polynomial.eval_comp]
    simp [Polynomial.eval_one_cyclotomic_prime]
  -- The critical coefficient of `G` is nonzero and not divisible by `p`.
  set c : ℤ := (shifted a b).coeff (Nsum k) with hc
  have hkey := superFactorial_mul_shifted_coeff_top a b
  have hpV : ¬ ((p : ℤ) ∣ Vand a * Vand b) := by
    intro hdvdv
    have hpz : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
    rcases hpz.dvd_mul.1 hdvdv with h1 | h1
    · exact prime_not_dvd_vand hp a ha hainj h1
    · exact prime_not_dvd_vand hp b hb hbinj h1
  have hcne : c ≠ 0 := by
    intro h0
    have h2 : Vand a * Vand b = 0 := by rw [← hkey, ← hc, h0, mul_zero]
    exact hpV (h2 ▸ dvd_zero _)
  -- `G` has trailing degree exactly `N`.
  have hGne : shifted a b ≠ 0 := fun h0 => hcne (by rw [hc, h0, Polynomial.coeff_zero])
  have htd : (shifted a b).natTrailingDegree = Nsum k := by
    refine le_antisymm (Polynomial.natTrailingDegree_le_of_ne_zero hcne) ?_
    by_contra hlt
    push_neg at hlt
    have := shifted_coeff_eq_zero a b hlt
    rw [← Polynomial.trailingCoeff] at this
    exact hGne (Polynomial.trailingCoeff_eq_zero.1 this)
  -- Multiplicativity of trailing coefficients forces `p ∣ c`.
  have htg : g.natTrailingDegree = 0 :=
    Nat.le_zero.1 (Polynomial.natTrailingDegree_le_of_ne_zero (by
      rw [hg0]; exact_mod_cast hp.ne_zero))
  have hpc : (p : ℤ) ∣ c := by
    have h1 : (shifted a b).trailingCoeff = g.trailingCoeff * (h.comp (X + 1)).trailingCoeff := by
      rw [hGg, Polynomial.trailingCoeff_mul]
    rw [Polynomial.trailingCoeff, htd, ← hc] at h1
    rw [Polynomial.trailingCoeff, htg, hg0] at h1
    exact ⟨_, h1⟩
  exact hpV (hkey ▸ Dvd.dvd.mul_left hpc _)

end Chebotarev