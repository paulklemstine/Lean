import Mathlib

/-!
# The Iwasawa invariant pair as a monoid homomorphism: a bridge to valuation theory

## Overview

This file *deepens* the algebraic model of the two classical **Iwasawa invariants**
`μ` and `λ` of a characteristic element built in `MatsunoIwasawaBridge.lean`.  There,
for `f = Σ aᵢ Xⁱ ∈ ℤ[X]` one sets

* `μ_p(f) = padicValInt p (content f)` — the least `p`-adic valuation of a coefficient
  (a `ℤ`-arithmetic / commutative-algebra datum), and
* `λ_p(f) = natTrailingDegree (reduce_p (primPart f))` — the first index at which that
  minimum is attained (a `𝔽_p[X]` combinatorial datum),

and proved that both are **additive under multiplication**.

Here we go one structural level higher and package this additivity as a genuine
**cross-domain bridge**:

1. **Monoid homomorphism (`iwasawaHom`).**  The pair `f ↦ (μ_p f, λ_p f)` is a
   *monoid homomorphism* from the multiplicative monoid `ℤ[X]⁰` of nonzero integer
   polynomials to the additive monoid `ℕ × ℕ` (viewed multiplicatively).  This is
   the precise statement that the Iwasawa invariants define a **valuation-type
   object**: an additive invariant of the multiplicative structure, connecting
   number theory (Iwasawa `μ`, `λ`) with the algebra of ordered monoids.

2. **Divisibility monotonicity (`muInv_le_of_dvd`, `lambdaInv_le_of_dvd`).**  Both
   invariants are *monotone under divisibility* — the hallmark of a valuation.  This
   bridges the **ring-theoretic** divisibility order on `ℤ[X]` with the numerical
   order on the invariants.

3. **`λ` = order of vanishing at `0` (`lambdaInv_eq_rootMultiplicity`).**  The
   `λ`-invariant literally equals `rootMultiplicity 0` of the reduced primitive part,
   i.e. the **order of vanishing at the origin** of the mod-`p` reduction.  This
   connects Iwasawa theory to the local (algebro-geometric) notion of multiplicity of
   a root.

4. **Finite-product formulas (`muInv_prod`, `lambdaInv_prod`).**  Both invariants
   turn a finite product of characteristic elements into a finite sum of invariants —
   the Iwasawa invariant of a product of many characteristic elements.

5. **Iterated Matsuno twist (`matsuno_iterated_twist`).**  Twisting a characteristic
   element by a family of twist factors shifts the `λ`-invariant by the sum of the
   individual `μ`-proportional contributions.

All statements are self-contained and depend only on Mathlib.
-/

namespace IwasawaMonoidHom

open Polynomial BigOperators

variable (p : ℕ) [Fact p.Prime]

/-- Reduction of an integer polynomial modulo the prime `p`. -/
noncomputable def reduce (f : Polynomial ℤ) : Polynomial (ZMod p) :=
  f.map (Int.castRingHom (ZMod p))

/-- The **Iwasawa μ-invariant** of `f`: the `p`-adic valuation of its content. -/
noncomputable def muInv (f : Polynomial ℤ) : ℕ :=
  padicValInt p f.content

/-- The **Iwasawa λ-invariant** of `f`: the trailing degree of the mod-`p`
reduction of the primitive part of `f`. -/
noncomputable def lambdaInv (f : Polynomial ℤ) : ℕ :=
  (reduce p f.primPart).natTrailingDegree

/-! ### Base additivity facts (self-contained restatement of the bridge) -/

/-- Reduction is a ring homomorphism, hence multiplicative. -/
theorem reduce_mul (a b : Polynomial ℤ) : reduce p (a * b) = reduce p a * reduce p b :=
  Polynomial.map_mul _

/-- The reduction of a primitive polynomial modulo `p` is nonzero. -/
theorem reduce_primPart_ne_zero (f : Polynomial ℤ) :
    reduce p f.primPart ≠ 0 := by
  intro h
  have hprim : f.primPart.IsPrimitive := isPrimitive_primPart f
  have hall : ∀ i, (p : ℤ) ∣ f.primPart.coeff i := by
    intro i
    have hz : ((f.primPart.coeff i : ℤ) : ZMod p) = 0 := by
      have := congrArg (fun q => Polynomial.coeff q i) h
      simpa [reduce, Polynomial.coeff_map] using this
    rwa [ZMod.intCast_zmod_eq_zero_iff_dvd] at hz
  have hCd : C (p : ℤ) ∣ f.primPart := (C_dvd_iff_dvd_coeff _ _).2 hall
  have hu := hprim (p : ℤ) hCd
  have hp := (Fact.out : p.Prime)
  have hp2 : (2 : ℤ) ≤ (p : ℤ) := by exact_mod_cast hp.two_le
  rw [Int.isUnit_iff] at hu
  rcases hu with h1 | h1 <;> omega

/-- **μ is additive** (Gauss's lemma + additivity of the `p`-adic valuation). -/
theorem muInv_mul {f g : Polynomial ℤ} (hf : f ≠ 0) (hg : g ≠ 0) :
    muInv p (f * g) = muInv p f + muInv p g := by
  have hcf : f.content ≠ 0 := by rwa [Ne, content_eq_zero_iff]
  have hcg : g.content ≠ 0 := by rwa [Ne, content_eq_zero_iff]
  unfold muInv
  rw [content_mul, padicValInt.mul hcf hcg]

/-- **λ is additive** (additivity of the trailing degree in the domain `𝔽_p[X]`). -/
theorem lambdaInv_mul {f g : Polynomial ℤ} (hf : f ≠ 0) (hg : g ≠ 0) :
    lambdaInv p (f * g) = lambdaInv p f + lambdaInv p g := by
  have hfg : f * g ≠ 0 := mul_ne_zero hf hg
  unfold lambdaInv
  rw [primPart_mul hfg, reduce_mul,
    natTrailingDegree_mul (reduce_primPart_ne_zero p f) (reduce_primPart_ne_zero p g)]

/-! ### The invariants at the identity -/

omit [Fact p.Prime] in
/-- The `μ`-invariant of `1` is `0`. -/
theorem muInv_one : muInv p (1 : Polynomial ℤ) = 0 := by
  unfold muInv
  rw [content_one]
  simp [padicValInt]

/-- The `λ`-invariant of `1` is `0`. -/
theorem lambdaInv_one : lambdaInv p (1 : Polynomial ℤ) = 0 := by
  have hprim : (1 : Polynomial ℤ).primPart = 1 :=
    (Polynomial.isPrimitive_one).primPart_eq
  unfold lambdaInv reduce
  rw [hprim]
  simp

/-! ### `λ` as an order of vanishing (bridge to local multiplicity) -/

/-- **The `λ`-invariant is the order of vanishing at the origin** of the mod-`p`
reduction of the primitive part: `λ_p(f) = rootMultiplicity 0 (reduce_p (primPart f))`.
This connects the Iwasawa `λ`-invariant with the algebro-geometric notion of the
multiplicity of a root. -/
theorem lambdaInv_eq_rootMultiplicity (f : Polynomial ℤ) :
    lambdaInv p f = rootMultiplicity 0 (reduce p f.primPart) := by
  unfold lambdaInv
  rw [rootMultiplicity_eq_natTrailingDegree']

/-! ### Divisibility monotonicity (bridge to the divisibility order) -/

/-- **`μ` is monotone under divisibility.**  If `f ∣ g` with `g ≠ 0`, then
`μ_p(f) ≤ μ_p(g)`. -/
theorem muInv_le_of_dvd {f g : Polynomial ℤ} (hdvd : f ∣ g) (hg : g ≠ 0) :
    muInv p f ≤ muInv p g := by
  obtain ⟨h, rfl⟩ := hdvd
  have hf : f ≠ 0 := left_ne_zero_of_mul hg
  have hh : h ≠ 0 := right_ne_zero_of_mul hg
  rw [muInv_mul p hf hh]
  exact Nat.le_add_right _ _

/-- **`λ` is monotone under divisibility.**  If `f ∣ g` with `g ≠ 0`, then
`λ_p(f) ≤ λ_p(g)`. -/
theorem lambdaInv_le_of_dvd {f g : Polynomial ℤ} (hdvd : f ∣ g) (hg : g ≠ 0) :
    lambdaInv p f ≤ lambdaInv p g := by
  obtain ⟨h, rfl⟩ := hdvd
  have hf : f ≠ 0 := left_ne_zero_of_mul hg
  have hh : h ≠ 0 := right_ne_zero_of_mul hg
  rw [lambdaInv_mul p hf hh]
  exact Nat.le_add_right _ _

/-! ### Finite-product formulas -/

/-- **`μ` of a finite product** is the sum of the `μ`-invariants. -/
theorem muInv_prod {ι : Type*} (s : Finset ι) (f : ι → Polynomial ℤ)
    (hf : ∀ i ∈ s, f i ≠ 0) :
    muInv p (∏ i ∈ s, f i) = ∑ i ∈ s, muInv p (f i) := by
  classical
  induction s using Finset.induction with
  | empty => simp [muInv_one]
  | insert a s ha ih =>
      rw [Finset.prod_insert ha, Finset.sum_insert ha]
      have hfa : f a ≠ 0 := hf a (Finset.mem_insert_self a s)
      have hrest : ∀ i ∈ s, f i ≠ 0 := fun i hi => hf i (Finset.mem_insert_of_mem hi)
      have hprod : (∏ i ∈ s, f i) ≠ 0 := Finset.prod_ne_zero_iff.2 hrest
      rw [muInv_mul p hfa hprod, ih hrest]

/-- **`λ` of a finite product** is the sum of the `λ`-invariants. -/
theorem lambdaInv_prod {ι : Type*} (s : Finset ι) (f : ι → Polynomial ℤ)
    (hf : ∀ i ∈ s, f i ≠ 0) :
    lambdaInv p (∏ i ∈ s, f i) = ∑ i ∈ s, lambdaInv p (f i) := by
  classical
  induction s using Finset.induction with
  | empty => simp [lambdaInv_one]
  | insert a s ha ih =>
      rw [Finset.prod_insert ha, Finset.sum_insert ha]
      have hfa : f a ≠ 0 := hf a (Finset.mem_insert_self a s)
      have hrest : ∀ i ∈ s, f i ≠ 0 := fun i hi => hf i (Finset.mem_insert_of_mem hi)
      have hprod : (∏ i ∈ s, f i) ≠ 0 := Finset.prod_ne_zero_iff.2 hrest
      rw [lambdaInv_mul p hfa hprod, ih hrest]

/-! ### The monoid homomorphism: the central cross-domain bridge -/

/-- **The Iwasawa invariant pair as a monoid homomorphism.**  The map
`f ↦ (μ_p f, λ_p f)` is a monoid homomorphism from the multiplicative monoid
`ℤ[X]⁰` of nonzero integer polynomials to the additive monoid `ℕ × ℕ` (viewed
multiplicatively).  This packages the additivity of both invariants as a single
structural statement, exhibiting the Iwasawa invariants as a **valuation-type**
homomorphism from a multiplicative structure (number theory) into an ordered
additive monoid (algebra). -/
noncomputable def iwasawaHom : (nonZeroDivisors (Polynomial ℤ)) →* Multiplicative (ℕ × ℕ) where
  toFun f := Multiplicative.ofAdd (muInv p (f : Polynomial ℤ), lambdaInv p (f : Polynomial ℤ))
  map_one' := by
    simp only [Submonoid.coe_one]
    rw [muInv_one, lambdaInv_one]
    rfl
  map_mul' a b := by
    have ha : (a : Polynomial ℤ) ≠ 0 := mem_nonZeroDivisors_iff_ne_zero.1 a.2
    have hb : (b : Polynomial ℤ) ≠ 0 := mem_nonZeroDivisors_iff_ne_zero.1 b.2
    simp only [Submonoid.coe_mul]
    rw [muInv_mul p ha hb, lambdaInv_mul p ha hb]
    rfl

@[simp]
theorem iwasawaHom_apply (f : nonZeroDivisors (Polynomial ℤ)) :
    iwasawaHom p f = Multiplicative.ofAdd (muInv p (f : Polynomial ℤ),
      lambdaInv p (f : Polynomial ℤ)) := rfl

/-- The homomorphism recovers `μ` in its first component. -/
theorem iwasawaHom_fst (f : nonZeroDivisors (Polynomial ℤ)) :
    ((Multiplicative.toAdd (iwasawaHom p f)).1) = muInv p (f : Polynomial ℤ) := rfl

/-- The homomorphism recovers `λ` in its second component. -/
theorem iwasawaHom_snd (f : nonZeroDivisors (Polynomial ℤ)) :
    ((Multiplicative.toAdd (iwasawaHom p f)).2) = lambdaInv p (f : Polynomial ℤ) := rfl

/-! ### The Matsuno-type twist factor and its iteration -/

/-- The modelled quadratic-twist factor `p^k · X^(c·k)`. -/
noncomputable def twistFactor (c k : ℕ) : Polynomial ℤ :=
  C ((p : ℤ) ^ k) * X ^ (c * k)

theorem twistFactor_ne_zero (c k : ℕ) : twistFactor p c k ≠ 0 := by
  have hp0 : (p : ℤ) ≠ 0 := by exact_mod_cast (Fact.out : p.Prime).pos.ne'
  unfold twistFactor
  exact mul_ne_zero (by simpa using pow_ne_zero k hp0) (pow_ne_zero _ X_ne_zero)

/-- The `μ`-invariant of the constant `p^k` is `k`. -/
theorem muInv_C_pow (k : ℕ) : muInv p (C ((p : ℤ) ^ k)) = k := by
  unfold muInv
  rw [content_C, Int.normalize_of_nonneg (by positivity)]
  unfold padicValInt
  simp [padicValNat.prime_pow]

/-- A nonzero constant `p^k` has `λ`-invariant `0`. -/
theorem lambdaInv_C_pow (k : ℕ) : lambdaInv p (C ((p : ℤ) ^ k)) = 0 := by
  have hp0 : (p : ℤ) ≠ 0 := by exact_mod_cast (Fact.out : p.Prime).pos.ne'
  have hm : ((p : ℤ) ^ k) ≠ 0 := pow_ne_zero k hp0
  have hprim : (C ((p : ℤ) ^ k)).primPart = 1 := by
    have h := eq_C_content_mul_primPart (C ((p : ℤ) ^ k))
    rw [content_C, Int.normalize_of_nonneg (by positivity)] at h
    have hCm : C ((p : ℤ) ^ k) ≠ 0 := by simpa using hm
    have h' : C ((p : ℤ) ^ k) * 1 = C ((p : ℤ) ^ k) * (C ((p : ℤ) ^ k)).primPart := by
      rw [mul_one]; exact h
    exact (mul_left_cancel₀ hCm h').symm
  unfold lambdaInv reduce
  rw [hprim]
  simp

omit [Fact p.Prime] in
/-- The `μ`-invariant of `X^n` is `0`. -/
theorem muInv_X_pow (n : ℕ) : muInv p ((X : Polynomial ℤ) ^ n) = 0 := by
  unfold muInv
  rw [content_X_pow]
  simp [padicValInt]

/-- The `λ`-invariant of `X^n` is `n`. -/
theorem lambdaInv_X_pow (n : ℕ) : lambdaInv p ((X : Polynomial ℤ) ^ n) = n := by
  have hprim : ((X : Polynomial ℤ) ^ n).primPart = X ^ n :=
    ((Polynomial.monic_X_pow n).isPrimitive).primPart_eq
  unfold lambdaInv reduce
  rw [hprim, Polynomial.map_pow, Polynomial.map_X]
  exact Polynomial.natTrailingDegree_X_pow n

/-- The twist factor has `μ`-invariant `k`. -/
theorem muInv_twistFactor (c k : ℕ) : muInv p (twistFactor p c k) = k := by
  have hp0 : (p : ℤ) ≠ 0 := by exact_mod_cast (Fact.out : p.Prime).pos.ne'
  unfold twistFactor
  have hC : C ((p : ℤ) ^ k) ≠ 0 := by simpa using pow_ne_zero k hp0
  have hX : (X : Polynomial ℤ) ^ (c * k) ≠ 0 := pow_ne_zero _ X_ne_zero
  rw [muInv_mul p hC hX, muInv_C_pow, muInv_X_pow, add_zero]

/-- The twist factor has `λ`-invariant `c · k`. -/
theorem lambdaInv_twistFactor (c k : ℕ) : lambdaInv p (twistFactor p c k) = c * k := by
  have hp0 : (p : ℤ) ≠ 0 := by exact_mod_cast (Fact.out : p.Prime).pos.ne'
  unfold twistFactor
  have hC : C ((p : ℤ) ^ k) ≠ 0 := by simpa using pow_ne_zero k hp0
  have hX : (X : Polynomial ℤ) ^ (c * k) ≠ 0 := pow_ne_zero _ X_ne_zero
  rw [lambdaInv_mul p hC hX, lambdaInv_C_pow, lambdaInv_X_pow, zero_add]

/-- **Iterated Matsuno twist formula.**  Twisting `f` by a finite family of twist
factors `twistFactor (c i) (k i)` shifts the `λ`-invariant by the sum of the
individual `μ`-proportional contributions `c i · μ_p(twistFactor (c i) (k i))`:

`λ_p(f · ∏ twist_i) = λ_p(f) + Σ c i · μ_p(twist_i)`. -/
theorem matsuno_iterated_twist {f : Polynomial ℤ} (hf : f ≠ 0)
    {ι : Type*} (s : Finset ι) (c k : ι → ℕ) :
    lambdaInv p (f * ∏ i ∈ s, twistFactor p (c i) (k i))
      = lambdaInv p f + ∑ i ∈ s, c i * muInv p (twistFactor p (c i) (k i)) := by
  have hprod : (∏ i ∈ s, twistFactor p (c i) (k i)) ≠ 0 :=
    Finset.prod_ne_zero_iff.2 (fun i _ => twistFactor_ne_zero p (c i) (k i))
  rw [lambdaInv_mul p hf hprod, lambdaInv_prod p s _ (fun i _ => twistFactor_ne_zero p (c i) (k i))]
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  rw [lambdaInv_twistFactor, muInv_twistFactor]

/-! ### Worked numerical instances (machine-checked) -/

example : lambdaInv 2 (twistFactor 2 2 3) = 6 := by rw [lambdaInv_twistFactor]

example : muInv 2 (twistFactor 2 2 3) = 3 := by rw [muInv_twistFactor]

/-- The homomorphism value on `X`: `(μ, λ) = (0, 1)`. -/
example :
    iwasawaHom 2 ⟨(X : Polynomial ℤ), mem_nonZeroDivisors_iff_ne_zero.2 X_ne_zero⟩
      = Multiplicative.ofAdd (0, 1) := by
  have hx1 : ((X : Polynomial ℤ)) = (X : Polynomial ℤ) ^ 1 := by rw [pow_one]
  simp only [iwasawaHom_apply]
  rw [hx1, muInv_X_pow, lambdaInv_X_pow]

end IwasawaMonoidHom