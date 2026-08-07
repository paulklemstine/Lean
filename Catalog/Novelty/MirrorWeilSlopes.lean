import Mathlib
import Novelty.MirrorWeilNewton

/-!
# Arithmetic Mirror Symmetry VIII — the reciprocity sign is the normalized Frobenius
determinant, and the Newton polygon reflects

This file is cycle 4 of the research thread.  It settles two of the open items recorded in
`FUTURE_DIRECTIONS.md` after cycle 3:

* **Conjecture E′ (Newton-polygon reflection symmetry)** — the *equality* half of the Hodge
  bound.  Cycle 3 proved the divisibility `q^j ∣ b_i`; here the graded palindromy is read
  `p`-adically and gives the exact reflection identity
  `v_p(b_{d−i}) + a·m = v_p(b_i) + a·n·i` for `q = p^a`, i.e. the Newton polygon of the
  middle factor is symmetric under reflection in the vertical line through its midpoint,
  with slope sum `a·n`.
* **Conjecture F′ / sub-conjecture N2′ (the sign)** — cycle 3 showed `ε = +1` in even degree
  with nonvanishing middle coefficient, and conjectured (N2′) that odd degree forces
  `ε = −1`.  **N2′ is false.**  The correct statement, proved here, is a closed formula:
  the sign is *uniquely determined* and equals the normalized Frobenius determinant,

  `∏ α_i = ε · (−1)^d · q^m`,   equivalently   `ε = (−1)^d · (∏ α_i) / q^m`.

  In odd degree both signs genuinely occur: the degree-one data `q = 2`, `n = 2`, `m = 1`
  with reciprocal root `−2` has `ε = +1`, while the root `+2` has `ε = −1`.

## Main results

* `middlePoly_monic`, `middlePoly_natDegree_eq`, `middlePoly_coeff_natDegree`,
  `middlePoly_coeff_zero_eq` — the two extreme coefficients of the middle factor.
* `middlePoly_sign_eq_normalized_det` — **the sign formula**: any `ε` satisfying the graded
  palindromy satisfies `∏ α_i = ε · (−1)^d · q^m`.  Only `q ≠ 0` is needed; root duality is
  not even required, so the sign is a function of the Frobenius determinant alone.
* `middlePoly_sign_unique` — consequently the sign in the Weil functional equation is
  unique, so "the" sign is well defined.
* `middlePoly_palindromy_of_det` — the converse: if `∏ α_i = ε (−1)^d q^m` then the graded
  palindromy holds with that `ε`.  Together with the previous two theorems this is an
  *iff*, `middlePoly_sign_iff_det`.
* `middlePoly_sign_eq_one_iff_det` — `ε = 1 ↔ ∏ α_i = (−1)^d q^m`.
* `odd_degree_sign_not_determined`, `N2_prime_refuted` — the refutation of N2′, with both
  signs realized in degree one.
* `middlePoly_newton_reflection` — **Conjecture E′**: `v_p(b_{d−i}) + a·m = v_p(b_i) + a·n·i`
  over `ℤ` with `q = p^a`.
* `middlePoly_newton_extreme`, `middlePoly_hodge_bound_sharp_iff` — the extreme case
  `v_p(b_0) = a·m` and the exact criterion for sharpness of cycle 3's Hodge bound.
* `k3_newton_reflection` — the reflection identity for a K3-type middle factor with
  reciprocal roots `1, 4, 2, 2` over `𝔽_2`.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  Cycle 3 left the sign `ε` as a case distinction.  But the
  cycle-2 identity `b_{d−i} q^{nd} = (−1)^d (∏ α) q^{ni} b_i` evaluated at `i = 0` involves
  only the two extreme coefficients `b_d = 1` and `b_0 = (−1)^d ∏ α`, so it should pin `ε`
  down completely.  Guess: `ε = (−1)^d (∏ α)/q^m`, i.e. the sign is the *normalized
  determinant of Frobenius on middle cohomology*, and parity of `d` alone cannot decide it.
* **Experiment (Experimenter).**  Instantiating at `i = 0` gives `q^{2m} = ε q^m (−1)^d ∏ α`;
  cancelling `q^m` (a domain, `q ≠ 0`) and multiplying by the unit `ε(−1)^d` yields the
  formula with no hypothesis on `σ` at all.  Testing parity: `d = 1`, `n = 2`, `m = 1`,
  `q = 2` and reciprocal root `α = −2` (self-dual, `α² = q²`) gives
  `∏ α = −2 = 1·(−1)^1·2`, so `ε = +1` in *odd* degree — N2′ dies on a one-root example.
  With `α = +2` the same shape gives `ε = −1`.
* **Analysis (Analyst).**  The failure of N2′ is not an accident of small degree: the sign
  is the normalized determinant, and the determinant is free to be `±q^m` independently of
  the parity of `d`.  What cycle 3 proved (even `d`, `b_{d/2} ≠ 0` ⟹ `ε = 1`) is therefore
  a statement about determinants: a nonvanishing middle coefficient forces
  `det = (−1)^d q^m`.  The right invariant is `det`, not `d`.
* **Critique (Critic).**  `middlePoly_sign_eq_normalized_det` is not definitional: it uses
  monicity of the middle factor (`Polynomial.monic_prod_of_monic`), the evaluation
  `b_0 = (−1)^d ∏ α`, and cancellation in a domain.  The refutation of N2′ is an explicit
  pair of witnesses with the duality hypothesis verified, not an assertion.  The Newton
  reflection uses `padicValInt.mul`, which needs both coefficients nonzero; that hypothesis
  is discharged on one side by cycle 2's `middlePoly_coeff_eq_zero_iff`, so only one
  nonvanishing assumption is carried, and it cannot be dropped (`b_i = 0` makes `v_p` a
  junk value).
* **Synthesis (PI).**  Poincaré duality ⟹ graded palindromy (cycle 2) ⟹ Hodge divisibility
  (cycle 3) ⟹ exact Newton-polygon reflection and a *computed* functional-equation sign
  (cycle 4).  The Weil sign is no longer an unknown: it is `(−1)^d det(Frob)/q^m`.
-/

namespace Novelty.MirrorBridge

open Polynomial Finset

section Extremes

variable {R : Type*} [CommRing R]

/-- The middle factor is monic. -/
theorem middlePoly_monic [Nontrivial R] {d : ℕ} (α : Fin d → R) : (middlePoly α).Monic := by
  unfold middlePoly
  exact monic_prod_of_monic _ _ (fun i _ => monic_X_sub_C _)

/-- The middle factor has degree exactly `d`. -/
theorem middlePoly_natDegree_eq [Nontrivial R] {d : ℕ} (α : Fin d → R) :
    (middlePoly α).natDegree = d := by
  unfold middlePoly
  rw [natDegree_prod_of_monic _ _ (fun i _ => monic_X_sub_C _)]
  simp

/-- The leading coefficient `b_d` of the middle factor is `1`. -/
@[simp] theorem middlePoly_coeff_natDegree [Nontrivial R] {d : ℕ} (α : Fin d → R) :
    (middlePoly α).coeff d = 1 := by
  have h := (middlePoly_monic α).coeff_natDegree
  rwa [middlePoly_natDegree_eq α] at h

/-- The constant coefficient `b_0` of the middle factor is `(−1)^d · det(Frob)`. -/
theorem middlePoly_coeff_zero_eq {d : ℕ} (α : Fin d → R) :
    (middlePoly α).coeff 0 = (-1) ^ d * ∏ i, α i := by
  rw [Polynomial.coeff_zero_eq_eval_zero]
  unfold middlePoly
  rw [eval_prod]
  simp only [eval_sub, eval_X, eval_C, zero_sub]
  rw [show (∏ i, -α i) = ∏ i, ((-1 : R) * α i) by simp, Finset.prod_mul_distrib]
  simp

/-- A sign times itself is one, and `(−1)^d` squares to one. -/
theorem neg_one_pow_mul_self (d : ℕ) : ((-1 : R)) ^ d * ((-1 : R)) ^ d = 1 := by
  rw [← pow_add]
  exact Even.neg_one_pow ⟨d, rfl⟩

end Extremes

section SignFormula

variable {R : Type*} [CommRing R] [IsDomain R]

/-- **The reciprocity sign is the normalized Frobenius determinant.**

Let `P(X) = ∏ (X − α_i)` be the monic middle factor of degree `d` and suppose a sign
`ε ∈ {−1, 1}` realizes the graded palindromy
`q^{2m} · b_{d−i} = ε · q^{m + n i} · b_i` (for `i = 0` already suffices).  Then

`∏ α_i = ε · (−1)^d · q^m`,

i.e. `ε = (−1)^d · det(Frob | H^n) / q^m`.  No root-duality permutation is needed: the sign
is a function of the Frobenius determinant alone. -/
theorem middlePoly_sign_eq_normalized_det {d n m : ℕ} (q : R) (hq : q ≠ 0) (α : Fin d → R)
    (ε : R) (hε : ε = 1 ∨ ε = -1)
    (h : ∀ i ≤ d, q ^ (2 * m) * (middlePoly α).coeff (d - i)
        = ε * q ^ (m + n * i) * (middlePoly α).coeff i) :
    ∏ i, α i = ε * (-1) ^ d * q ^ m := by
  have h0 := h 0 (Nat.zero_le d)
  rw [Nat.sub_zero, Nat.mul_zero, Nat.add_zero, middlePoly_coeff_natDegree,
    middlePoly_coeff_zero_eq] at h0
  -- `h0 : q^{2m} * 1 = ε * q^m * ((-1)^d * ∏ α)`
  have hqm : q ^ m ≠ 0 := pow_ne_zero _ hq
  have hcancel : q ^ m = ε * ((-1) ^ d * ∏ i, α i) := by
    refine mul_left_cancel₀ hqm ?_
    rw [two_mul, pow_add] at h0
    linear_combination h0
  have hεε : ε * ε = 1 := sign_mul_self hε
  have hdd : ((-1 : R)) ^ d * ((-1 : R)) ^ d = 1 := neg_one_pow_mul_self d
  calc ∏ i, α i = (ε * ε) * (((-1 : R)) ^ d * ((-1 : R)) ^ d) * ∏ i, α i := by
        rw [hεε, hdd]; ring
    _ = ε * (-1) ^ d * (ε * ((-1) ^ d * ∏ i, α i)) := by ring
    _ = ε * (-1) ^ d * q ^ m := by rw [← hcancel]

/-- **Uniqueness of the reciprocity sign.**  At most one `ε` can realize the graded
palindromy, so "the sign of the Weil functional equation" is well defined. -/
theorem middlePoly_sign_unique {d n m : ℕ} (q : R) (hq : q ≠ 0) (α : Fin d → R)
    (ε ε' : R) (hε : ε = 1 ∨ ε = -1) (hε' : ε' = 1 ∨ ε' = -1)
    (h : ∀ i ≤ d, q ^ (2 * m) * (middlePoly α).coeff (d - i)
        = ε * q ^ (m + n * i) * (middlePoly α).coeff i)
    (h' : ∀ i ≤ d, q ^ (2 * m) * (middlePoly α).coeff (d - i)
        = ε' * q ^ (m + n * i) * (middlePoly α).coeff i) :
    ε = ε' := by
  have e1 := middlePoly_sign_eq_normalized_det (n := n) q hq α ε hε h
  have e2 := middlePoly_sign_eq_normalized_det (n := n) q hq α ε' hε' h'
  have hkey : (ε - ε') * ((-1 : R) ^ d * q ^ m) = 0 := by linear_combination e2 - e1
  have hne : ((-1 : R) ^ d * q ^ m) ≠ 0 := by
    refine mul_ne_zero ?_ (pow_ne_zero _ hq)
    rcases neg_one_pow_is_sign (R := R) d with hs | hs <;> rw [hs] <;> norm_num
  exact sub_eq_zero.mp ((mul_eq_zero.mp hkey).resolve_right hne)

omit [IsDomain R] in
/-- **Converse of the sign formula.**  If the Frobenius determinant is `ε (−1)^d q^m`, then
the graded palindromy holds with exactly that sign.  (Here root duality *is* needed: it is
what makes a palindromy hold at all.) -/
theorem middlePoly_palindromy_of_det {d n m : ℕ} (hm : n * d = 2 * m) (q : R)
    (α : Fin d → R) (σ : Equiv.Perm (Fin d)) (hdual : ∀ i, α i * α (σ i) = q ^ n)
    (ε : R) (hdet : ∏ i, α i = ε * (-1) ^ d * q ^ m) :
    ∀ i ≤ d, q ^ (2 * m) * (middlePoly α).coeff (d - i)
      = ε * q ^ (m + n * i) * (middlePoly α).coeff i := by
  intro i hi
  have hkey := middlePoly_coeff_palindromy_pow q α σ hdual hi
  rw [hm, hdet] at hkey
  have hdd : ((-1 : R)) ^ d * ((-1 : R)) ^ d = 1 := neg_one_pow_mul_self d
  rw [pow_add]
  calc q ^ (2 * m) * (middlePoly α).coeff (d - i)
      = (-1) ^ d * (ε * (-1) ^ d * q ^ m) * q ^ (n * i) * (middlePoly α).coeff i := by
        linear_combination hkey
    _ = ((-1 : R) ^ d * (-1) ^ d) * (ε * (q ^ m * q ^ (n * i))) * (middlePoly α).coeff i := by
        ring
    _ = ε * (q ^ m * q ^ (n * i)) * (middlePoly α).coeff i := by rw [hdd]; ring

/-- **The sign is exactly the normalized determinant** (both directions). -/
theorem middlePoly_sign_iff_det {d n m : ℕ} (hm : n * d = 2 * m) (q : R) (hq : q ≠ 0)
    (α : Fin d → R) (σ : Equiv.Perm (Fin d)) (hdual : ∀ i, α i * α (σ i) = q ^ n)
    (ε : R) (hε : ε = 1 ∨ ε = -1) :
    (∀ i ≤ d, q ^ (2 * m) * (middlePoly α).coeff (d - i)
        = ε * q ^ (m + n * i) * (middlePoly α).coeff i)
      ↔ ∏ i, α i = ε * (-1) ^ d * q ^ m :=
  ⟨fun h => middlePoly_sign_eq_normalized_det (n := n) q hq α ε hε h,
   fun hdet => middlePoly_palindromy_of_det hm q α σ hdual ε hdet⟩

/-- The sign is `+1` exactly when the Frobenius determinant equals `(−1)^d q^m`. -/
theorem middlePoly_sign_eq_one_iff_det {d n m : ℕ} (hm : n * d = 2 * m) (q : R) (hq : q ≠ 0)
    (α : Fin d → R) (σ : Equiv.Perm (Fin d)) (hdual : ∀ i, α i * α (σ i) = q ^ n) :
    (∀ i ≤ d, q ^ (2 * m) * (middlePoly α).coeff (d - i)
        = q ^ (m + n * i) * (middlePoly α).coeff i)
      ↔ ∏ i, α i = (-1) ^ d * q ^ m := by
  have h := middlePoly_sign_iff_det hm q hq α σ hdual 1 (Or.inl rfl)
  simpa using h

end SignFormula

section OddDegree

/-- The middle factor of a single reciprocal root. -/
theorem middlePoly_one {R : Type*} [CommRing R] (a : R) :
    middlePoly ![a] = X - C a := by
  unfold middlePoly
  rw [Fin.prod_univ_one]
  simp

/-- Root duality for a single self-dual root: `α² = q^n`. -/
theorem rootDuality_one {R : Type*} [CommRing R] {n : ℕ} (q a : R) (ha : a * a = q ^ n) :
    ∀ i, (![a] : Fin 1 → R) i * (![a] : Fin 1 → R) (Equiv.refl (Fin 1) i) = q ^ n := by
  intro i
  fin_cases i
  simpa using ha

/-- **Sub-conjecture N2′ is false: odd degree does not force the sign `−1`.**

Degree `d = 1`, `n = 2`, `m = 1`, `q = 2`.  The self-dual reciprocal root `α = −2`
(`α² = q² = 4`) gives middle factor `P(X) = X + 2` and reciprocity sign `ε = +1`; the
root `α = +2` gives `P(X) = X − 2` and sign `ε = −1`.  Both are odd degree. -/
theorem odd_degree_sign_not_determined :
    (∀ i ≤ 1, (2 : ℤ) ^ (2 * 1) * (middlePoly ![(-2 : ℤ)]).coeff (1 - i)
        = 1 * (2 : ℤ) ^ (1 + 2 * i) * (middlePoly ![(-2 : ℤ)]).coeff i)
      ∧ ¬ (∀ i ≤ 1, (2 : ℤ) ^ (2 * 1) * (middlePoly ![(-2 : ℤ)]).coeff (1 - i)
        = (-1) * (2 : ℤ) ^ (1 + 2 * i) * (middlePoly ![(-2 : ℤ)]).coeff i)
      ∧ (∀ i ≤ 1, (2 : ℤ) ^ (2 * 1) * (middlePoly ![(2 : ℤ)]).coeff (1 - i)
        = (-1) * (2 : ℤ) ^ (1 + 2 * i) * (middlePoly ![(2 : ℤ)]).coeff i) := by
  refine ⟨?_, ?_, ?_⟩
  · refine middlePoly_palindromy_of_det (d := 1) (n := 2) (m := 1) (by norm_num) 2
      ![(-2 : ℤ)] (Equiv.refl (Fin 1)) (rootDuality_one 2 (-2) (by norm_num)) 1 ?_
    rw [Fin.prod_univ_one]; norm_num
  · intro h
    have h0 := h 0 (by norm_num)
    rw [middlePoly_one] at h0
    norm_num at h0
  · refine middlePoly_palindromy_of_det (d := 1) (n := 2) (m := 1) (by norm_num) 2
      ![(2 : ℤ)] (Equiv.refl (Fin 1)) (rootDuality_one 2 2 (by norm_num)) (-1) ?_
    rw [Fin.prod_univ_one]; norm_num

/-- **N2′ refuted, in quantified form.**  It is *not* true that odd degree forces the
reciprocity sign to be `−1`. -/
theorem N2_prime_refuted :
    ¬ ∀ (d n m : ℕ) (α : Fin d → ℤ) (σ : Equiv.Perm (Fin d)) (q ε : ℤ),
        Odd d → q ≠ 0 → n * d = 2 * m → (∀ i, α i * α (σ i) = q ^ n) →
        (ε = 1 ∨ ε = -1) →
        (∀ i ≤ d, q ^ (2 * m) * (middlePoly α).coeff (d - i)
          = ε * q ^ (m + n * i) * (middlePoly α).coeff i) →
        ε = -1 := by
  intro h
  have := h 1 2 1 ![(-2 : ℤ)] (Equiv.refl (Fin 1)) 2 1 ⟨0, by norm_num⟩ (by norm_num)
    (by norm_num) (rootDuality_one 2 (-2) (by norm_num)) (Or.inl rfl)
    odd_degree_sign_not_determined.1
  norm_num at this

end OddDegree

section Newton

/-- `p`-adic valuation of a power. -/
theorem padicValInt_pow {p : ℕ} [Fact p.Prime] {a : ℤ} (ha : a ≠ 0) (k : ℕ) :
    padicValInt p (a ^ k) = k * padicValInt p a := by
  induction k with
  | zero => simp
  | succ t ih => rw [pow_succ, padicValInt.mul (pow_ne_zero _ ha) ha, ih]; ring

/-- `v_p(p^k) = k`. -/
theorem padicValInt_prime_pow {p : ℕ} [Fact p.Prime] (k : ℕ) :
    padicValInt p ((p : ℤ) ^ k) = k := by
  simp [padicValInt, Int.natAbs_pow, padicValNat.prime_pow]

/-- The `p`-adic valuation ignores signs. -/
theorem padicValInt_neg {p : ℕ} (a : ℤ) : padicValInt p (-a) = padicValInt p a := by
  simp [padicValInt]

/-- **Conjecture E′ — reflection symmetry of the Newton polygon.**

Let `P(X) = ∏ (X − α_i) ∈ ℤ[X]` be the monic middle factor of a smooth proper Calabi–Yau
`n`-fold over `𝔽_q` with `q = p^a`, `deg P = d`, `n·d = 2m`, and Poincaré root duality
`α_i · α_{σ i} = q^n`.  Then for every index `i ≤ d` at which the coefficient is nonzero,

`v_p(b_{d−i}) + a·m = v_p(b_i) + a·n·i`.

Equivalently `v_p(b_{d−i}) − v_p(b_i) = a(n·i − m)`: the Newton polygon of `P` is carried
to itself by reflection about the vertical line `x = d/2` composed with the shear of slope
`a·n`.  Cycle 3 proved the inequality half (`middlePoly_hodge_divisibility`); this is the
matching equality. -/
theorem middlePoly_newton_reflection {d n m : ℕ} (hm : n * d = 2 * m) {p : ℕ} (hp : p.Prime)
    (a : ℕ) (α : Fin d → ℤ) (σ : Equiv.Perm (Fin d))
    (hdual : ∀ i, α i * α (σ i) = ((p : ℤ) ^ a) ^ n)
    (i : ℕ) (hi : i ≤ d) (hbi : (middlePoly α).coeff i ≠ 0) :
    padicValInt p ((middlePoly α).coeff (d - i)) + a * m
      = padicValInt p ((middlePoly α).coeff i) + a * (n * i) := by
  haveI : Fact p.Prime := ⟨hp⟩
  set q : ℤ := (p : ℤ) ^ a with hqdef
  have hp0 : (p : ℤ) ≠ 0 := Int.natCast_ne_zero.mpr hp.ne_zero
  have hq : q ≠ 0 := pow_ne_zero _ hp0
  -- the reflected coefficient is nonzero too
  have hbd : (middlePoly α).coeff (d - i) ≠ 0 := by
    intro hzero
    exact hbi ((middlePoly_coeff_eq_zero_iff hm q hq α σ hdual i hi).mpr hzero)
  obtain ⟨ε, hε, h⟩ := middlePoly_graded_palindromy hm q α σ hdual
  have hkey := h i hi
  -- valuations of the two pure powers of `q`
  have hv1 : padicValInt p (q ^ (2 * m)) = a * (2 * m) := by
    rw [hqdef, ← pow_mul, padicValInt_prime_pow]
  have hv2 : padicValInt p (q ^ (m + n * i)) = a * (m + n * i) := by
    rw [hqdef, ← pow_mul, padicValInt_prime_pow]
  have hqm1 : q ^ (2 * m) ≠ 0 := pow_ne_zero _ hq
  have hqm2 : q ^ (m + n * i) ≠ 0 := pow_ne_zero _ hq
  -- take `v_p` of both sides of the graded palindromy
  have hLHS : padicValInt p (q ^ (2 * m) * (middlePoly α).coeff (d - i))
      = a * (2 * m) + padicValInt p ((middlePoly α).coeff (d - i)) := by
    rw [padicValInt.mul hqm1 hbd, hv1]
  have hRHS : padicValInt p (ε * q ^ (m + n * i) * (middlePoly α).coeff i)
      = a * (m + n * i) + padicValInt p ((middlePoly α).coeff i) := by
    rcases hε with rfl | rfl
    · rw [one_mul, padicValInt.mul hqm2 hbi, hv2]
    · rw [show (-1 : ℤ) * q ^ (m + n * i) * (middlePoly α).coeff i
            = -(q ^ (m + n * i) * (middlePoly α).coeff i) by ring,
        padicValInt_neg, padicValInt.mul hqm2 hbi, hv2]
  have hval : a * (2 * m) + padicValInt p ((middlePoly α).coeff (d - i))
      = a * (m + n * i) + padicValInt p ((middlePoly α).coeff i) := by
    rw [← hLHS, ← hRHS, hkey]
  have e1 : a * (2 * m) = a * m + a * m := by ring
  have e2 : a * (m + n * i) = a * m + a * (n * i) := by ring
  omega

/-- **Slope form of the reflection.**  Writing `s_i = v_p(b_i)` for the vertices of the
Newton polygon, the reflection identity says that the "reflected slope" `s_{d−i} − s_i`
grows linearly with slope `a·n`; in particular, at `i = 0` it recovers exactly the Hodge
bound `v_p(b_0) = a·m`, which is the extreme case of cycle 3's divisibility. -/
theorem middlePoly_newton_extreme {d n m : ℕ} (hm : n * d = 2 * m) {p : ℕ} (hp : p.Prime)
    (a : ℕ) (α : Fin d → ℤ) (σ : Equiv.Perm (Fin d))
    (hdual : ∀ i, α i * α (σ i) = ((p : ℤ) ^ a) ^ n)
    (hb0 : (middlePoly α).coeff 0 ≠ 0) :
    padicValInt p ((middlePoly α).coeff 0) = a * m := by
  have h := middlePoly_newton_reflection hm hp a α σ hdual 0 (Nat.zero_le d) hb0
  rw [Nat.sub_zero, middlePoly_coeff_natDegree] at h
  have hone : padicValInt p (1 : ℤ) = 0 := by simp [padicValInt]
  rw [hone] at h
  omega

/-- **Exact sharpness criterion for the Hodge bound.**  Cycle 3 proved `q^{m−n i} ∣ b_i`.
The reflection identity says precisely *when* that divisibility is sharp: the Hodge bound is
attained at `i` if and only if the reflected coefficient `b_{d−i}` is a `p`-adic unit. -/
theorem middlePoly_hodge_bound_sharp_iff {d n m : ℕ} (hm : n * d = 2 * m) {p : ℕ}
    (hp : p.Prime) (a : ℕ) (α : Fin d → ℤ) (σ : Equiv.Perm (Fin d))
    (hdual : ∀ i, α i * α (σ i) = ((p : ℤ) ^ a) ^ n)
    (i : ℕ) (hi : i ≤ d) (hbi : (middlePoly α).coeff i ≠ 0) :
    padicValInt p ((middlePoly α).coeff i) + a * (n * i) = a * m
      ↔ padicValInt p ((middlePoly α).coeff (d - i)) = 0 := by
  have h := middlePoly_newton_reflection hm hp a α σ hdual i hi hbi
  omega

/-- **A K3-type instance.**  Reciprocal roots `1, 4, 2, 2` over `𝔽_2` (so `q = 2`, `n = 2`,
`d = 4`, `m = 4`), Poincaré-dual under the transposition swapping `1 ↔ 4` and fixing the
two copies of `2`.  The middle factor is `X⁴ − 9X³ + 28X² − 36X + 16`, and the reflection
identity reads `v₂(b_{4−i}) + 4 = v₂(b_i) + 2i`. -/
theorem k3_newton_reflection (i : ℕ) (hi : i ≤ 4)
    (hbi : (middlePoly ![(1 : ℤ), 4, 2, 2]).coeff i ≠ 0) :
    padicValInt 2 ((middlePoly ![(1 : ℤ), 4, 2, 2]).coeff (4 - i)) + 4
      = padicValInt 2 ((middlePoly ![(1 : ℤ), 4, 2, 2]).coeff i) + 2 * i := by
  have hdual : ∀ j, (![(1 : ℤ), 4, 2, 2]) j
      * (![(1 : ℤ), 4, 2, 2]) ((Equiv.swap 0 1 : Equiv.Perm (Fin 4)) j)
      = ((2 : ℤ) ^ 1) ^ 2 := by
    intro j
    fin_cases j <;>
      simp [Equiv.swap_apply_left, Equiv.swap_apply_right, Equiv.swap_apply_of_ne_of_ne]
  have h := middlePoly_newton_reflection (d := 4) (n := 2) (m := 4) (by norm_num)
    (p := 2) (by norm_num) 1 ![(1 : ℤ), 4, 2, 2] (Equiv.swap 0 1) hdual i hi hbi
  have e1 : 1 * 4 = 4 := by norm_num
  have e2 : 1 * (2 * i) = 2 * i := by ring
  rw [e1, e2] at h
  exact h

end Newton

end Novelty.MirrorBridge