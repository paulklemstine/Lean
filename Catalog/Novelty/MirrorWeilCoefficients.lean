import Mathlib
import Novelty.MirrorWeilReciprocity

/-!
# Arithmetic Mirror Symmetry VI — the coefficient-level Weil functional equation

This file closes **Conjecture A** of the previous cycle's `FUTURE_DIRECTIONS.md`: the
functional equation of the middle zeta factor of a Calabi–Yau `n`-fold over `𝔽_q` is a
*palindromy of the integer coefficient vector with graded weights*, and can be stated and
proved entirely inside `R[X]` — no roots, no field extension, no analysis, no division.

The previous cycle proved the *root-level* reciprocity
`∏ (q^n T − α_i) = ε (−1)^d q^m ∏ (1 − α_i T)` (`Novelty.MirrorBridge.middleFactor_reciprocal`).
Here the same single hypothesis — Poincaré root duality, i.e. a permutation `σ` with
`α_i α_{σ i} = Q` — is converted into a statement about `Polynomial.coeff`, which is the
form in which Frobenius polynomials are actually tabulated.

## Main results

* `middlePoly` — the monic middle factor `P(X) = ∏ (X − α_i)`.
* `middleFactor_eq_eval_reflect` — the bridge to the previous cycle: the reciprocal-root
  factor `∏ (1 − α_i T)` is the evaluation of `Polynomial.reflect d P`.
* `reflect_middlePoly_comp` — the structural core, over an arbitrary commutative ring:
  `reflect d (P ∘ (Q·X)) = C ((−1)^d ∏ α_i) · P`.
* `middlePoly_coeff_palindromy` — the coefficient identity
  `b_{d−k} · Q^{d−k} = (−1)^d (∏ α_i) · b_k` for all `k ≤ d`; division-free, over an
  arbitrary commutative ring.
* `middlePoly_graded_palindromy` — over a domain, with `Q = q^n` and `n·d = 2m`, there is a
  sign `ε ∈ {−1,1}` with `q^{2m}·b_{d−i} = ε·q^{m+n i}·b_i` for all `i ≤ d`.
* `middlePoly_graded_palindromy_field` — the cancelled field form
  `q^m · b_{d−i} = ε · q^{n i} · b_i`, which is the corrected version of the exponent
  displayed in the conjecture (`prompt_coefficient_exponent_refuted` refutes the displayed
  one).
* `middlePoly_coeff_eq_zero_iff` — consequently the **support** of the middle factor is
  palindromic: `b_i = 0 ↔ b_{d−i} = 0`.
* `cy_threefold_middlePoly`, `cy_threefold_graded_palindromy` — the Calabi–Yau threefold
  corner `d = 2`, `n = 3`: `P(X) = X² − aX + q³`, with `ε = +1`.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  The root-level identity of cycle 1 should be the
  generating-function shadow of a weighted palindromy of the coefficient vector; the right
  operation is `Polynomial.reflect d` applied to the *scaled* polynomial `P(QX)`, because
  `reflect` is exactly "reverse the coefficient list" and the scaling supplies the grading.
* **Experiment (Experimenter).**  `Polynomial.reflect_mul` is multiplicative only with
  degree bookkeeping, so the product over the `d` roots had to be reflected one factor at a
  time (`reflect_prod_of_natDegree_le_one`, proved by `Finset.induction` with
  `Polynomial.natDegree_prod_le`).  Each linear factor reflects as
  `reflect 1 (C Q · X − C α) = C Q − C α · X`, and root duality `Q = α_i α_{σ i}` turns that
  into `(−1)·α_i·(X − α_{σ i})`; reindexing by `σ` collapses the product back to `P`.
* **Analysis (Analyst).**  Numerically (`ComputationalEvidence.md`, §5) the exponent
  displayed in Conjecture A (`b_{d−i} = ε q^{m−n i} b_i`) is inverted, exactly as the
  displayed exponent of Conjecture 4 was in cycle 1: already for the Calabi–Yau threefold
  factor `X² − aX + q³` one has `b₂ = 1`, `b₀ = q³`, `m = 3`, `n = 3`, so
  `b_{2−0} = q^{0−3} b_0`, not `q^{3−0} b_0`.  The correct exponent is `q^{n i − m}`,
  equivalently `q^m b_{d−i} = ε q^{n i} b_i`, which is division-free.
* **Critique (Critic).**  The core theorem is stated over an arbitrary `CommRing` with no
  invertibility, no `decide` and no `native_decide`; the refutation of the displayed
  exponent is an explicit evaluation in `ℚ` closed by `norm_num`, hence a genuine
  counterexample and not a vacuous statement.  The hypothesis `hdual` is load-bearing:
  without it `reflect_middlePoly_comp` is false (take `d = 1`, `α = 0`, `Q = 1`).
* **Synthesis (PI).**  Poincaré duality on `H^n` ⟹ weighted palindromy of the Frobenius
  coefficient vector, uniformly in `(n, d, q)` and over any commutative ring.  Together
  with cycle 1 this makes the Weil functional equation a purely combinatorial consequence
  of root duality at *both* the product level and the coefficient level.
-/

namespace Novelty.MirrorBridge

open Polynomial Finset

section CommRing

variable {R : Type*} [CommRing R]

/-- The **monic middle factor** `P(X) = ∏ (X − α_i)` attached to the reciprocal Frobenius
roots `α : Fin d → R` of `H^n`.  Its coefficient vector is the tabulated data of a
Frobenius polynomial. -/
noncomputable def middlePoly {d : ℕ} (α : Fin d → R) : R[X] := ∏ i, (X - C (α i))

/-- Reflection of a product of linear polynomials is the product of the reflections.
`Polynomial.reflect_mul` needs degree bookkeeping, supplied here by
`Polynomial.natDegree_prod_le`. -/
theorem reflect_prod_of_natDegree_le_one {ι : Type*} (s : Finset ι) (f : ι → R[X])
    (hf : ∀ i ∈ s, (f i).natDegree ≤ 1) :
    reflect s.card (∏ i ∈ s, f i) = ∏ i ∈ s, reflect 1 (f i) := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih =>
      rw [Finset.prod_insert ha, Finset.prod_insert ha, Finset.card_insert_of_notMem ha]
      have hdeg : (∏ i ∈ s, f i).natDegree ≤ s.card := by
        refine le_trans (Polynomial.natDegree_prod_le s f) ?_
        calc ∑ i ∈ s, (f i).natDegree ≤ ∑ _i ∈ s, 1 :=
              Finset.sum_le_sum (fun i hi => hf i (Finset.mem_insert_of_mem hi))
          _ = s.card := by simp
      rw [show s.card + 1 = 1 + s.card from Nat.add_comm _ _,
        Polynomial.reflect_mul _ _ (hf a (Finset.mem_insert_self a s)) hdeg,
        ih (fun i hi => hf i (Finset.mem_insert_of_mem hi))]

/-- Reflecting a linear polynomial swaps its two coefficients. -/
theorem reflect_one_linear (a b : R) : reflect 1 (C a * X - C b) = C a - C b * X := by
  rw [sub_eq_add_neg, ← C_neg, Polynomial.reflect_add,
    show (C a * X : R[X]) = C a * X ^ 1 by ring, Polynomial.reflect_C_mul_X_pow,
    show (C (-b) : R[X]) = C (-b) * X ^ 0 by ring, Polynomial.reflect_C_mul_X_pow]
  simp [Polynomial.revAt]
  ring

/-- Every linear factor `C Q * X - C a` has degree at most one. -/
theorem natDegree_linear_le (Q a : R) : (C Q * X - C a).natDegree ≤ 1 := by
  refine le_trans (Polynomial.natDegree_sub_le _ _) ?_
  exact max_le (le_trans (Polynomial.natDegree_C_mul_le _ _) Polynomial.natDegree_X_le)
    (by simp)

/-- **Bridge to the root-level cycle.**  The reciprocal-root middle factor
`P̃(T) = ∏ (1 − α_i T)` used in `Novelty.MirrorBridge.middleFactor` is the evaluation of the
reflection of the monic middle factor `P(X) = ∏ (X − α_i)`. -/
theorem middleFactor_eq_eval_reflect {d : ℕ} (α : Fin d → R) (T : R) :
    middleFactor α T = (reflect d (middlePoly α)).eval T := by
  have hcard : (Finset.univ : Finset (Fin d)).card = d := by simp
  have hdegs : ∀ i ∈ (Finset.univ : Finset (Fin d)), (X - C (α i) : R[X]).natDegree ≤ 1 := by
    intro i _
    exact Polynomial.natDegree_X_sub_C_le _
  have hR := reflect_prod_of_natDegree_le_one (Finset.univ : Finset (Fin d))
    (fun i => X - C (α i)) hdegs
  rw [hcard] at hR
  have hlin : ∀ i : Fin d, reflect 1 (X - C (α i) : R[X]) = 1 - C (α i) * X := by
    intro i
    have hX : (X - C (α i) : R[X]) = C 1 * X - C (α i) := by rw [map_one, one_mul]
    rw [hX, reflect_one_linear, map_one]
  unfold middlePoly middleFactor
  rw [hR, Finset.prod_congr rfl (fun i (_ : i ∈ Finset.univ) => hlin i)]
  simp [Polynomial.eval_prod]

/-- **Structural core: root duality ⟹ reflected scaling is the original.**
If the reciprocal roots are permuted by `α ↦ Q/α`, then reflecting the `Q`-scaled middle
polynomial returns the middle polynomial itself, up to the scalar `(−1)^d ∏ α_i`.
Division-free, over an arbitrary commutative ring. -/
theorem reflect_middlePoly_comp {d : ℕ} (Q : R) (α : Fin d → R)
    (σ : Equiv.Perm (Fin d)) (hdual : ∀ i, α i * α (σ i) = Q) :
    reflect d ((middlePoly α).comp (C Q * X))
      = C ((-1) ^ d * ∏ i, α i) * middlePoly α := by
  have hcomp : (middlePoly α).comp (C Q * X) = ∏ i, (C Q * X - C (α i)) := by
    unfold middlePoly
    rw [Polynomial.prod_comp]
    exact Finset.prod_congr rfl (fun i _ => by simp)
  have hcard : (Finset.univ : Finset (Fin d)).card = d := by simp
  have hdegs : ∀ i ∈ (Finset.univ : Finset (Fin d)), (C Q * X - C (α i)).natDegree ≤ 1 :=
    fun i _ => natDegree_linear_le Q (α i)
  have hR := reflect_prod_of_natDegree_le_one (Finset.univ : Finset (Fin d))
    (fun i => C Q * X - C (α i)) hdegs
  rw [hcard] at hR
  rw [hcomp, hR,
    Finset.prod_congr rfl (fun i (_ : i ∈ Finset.univ) => reflect_one_linear Q (α i))]
  have step : ∀ i : Fin d,
      (C Q - C (α i) * X : R[X]) = (-1) * (C (α i) * (X - C (α (σ i)))) := by
    intro i
    have hQ : (C Q : R[X]) = C (α i) * C (α (σ i)) := by rw [← C_mul, hdual i]
    rw [hQ]; ring
  rw [Finset.prod_congr rfl (fun i (_ : i ∈ Finset.univ) => step i), Finset.prod_mul_distrib,
    Finset.prod_const, hcard, Finset.prod_mul_distrib]
  have hperm : (∏ i, (X - C (α (σ i))) : R[X]) = ∏ i, (X - C (α i)) :=
    Fintype.prod_equiv σ _ _ (fun i => rfl)
  have hC : (∏ i, C (α i) : R[X]) = C (∏ i, α i) := by rw [map_prod]
  rw [hperm, hC, map_mul, map_pow, map_neg, map_one]
  unfold middlePoly
  ring

/-- **Conjecture A, division-free form.**  Poincaré root duality forces a *weighted
palindromy* of the coefficient vector `b_k = coeff P k` of the middle factor:

`b_{d−k} · Q^{d−k} = (−1)^d · (∏ α_i) · b_k` for every `k ≤ d`.

No roots are extracted, no division is used, and `R` is an arbitrary commutative ring. -/
theorem middlePoly_coeff_palindromy {d : ℕ} (Q : R) (α : Fin d → R)
    (σ : Equiv.Perm (Fin d)) (hdual : ∀ i, α i * α (σ i) = Q) {k : ℕ} (hk : k ≤ d) :
    (middlePoly α).coeff (d - k) * Q ^ (d - k)
      = (-1) ^ d * (∏ i, α i) * (middlePoly α).coeff k := by
  have h := congrArg (fun p : R[X] => p.coeff k) (reflect_middlePoly_comp Q α σ hdual)
  simp only [Polynomial.coeff_reflect, Polynomial.revAt_le hk,
    Polynomial.comp_C_mul_X_coeff, Polynomial.coeff_C_mul] at h
  rw [h]

/-- `(−1)^d` is a sign. -/
theorem neg_one_pow_is_sign (d : ℕ) : ((-1 : R)) ^ d = 1 ∨ ((-1 : R)) ^ d = -1 := by
  rcases Nat.even_or_odd d with he | ho
  · exact Or.inl he.neg_one_pow
  · exact Or.inr ho.neg_one_pow

/-- The weighted palindromy with the weight moved onto a single power `q^{n d}`. -/
theorem middlePoly_coeff_palindromy_pow {d n : ℕ} (q : R) (α : Fin d → R)
    (σ : Equiv.Perm (Fin d)) (hdual : ∀ i, α i * α (σ i) = q ^ n) {i : ℕ} (hi : i ≤ d) :
    (middlePoly α).coeff (d - i) * q ^ (n * d)
      = (-1) ^ d * (∏ j, α j) * q ^ (n * i) * (middlePoly α).coeff i := by
  have hpal := middlePoly_coeff_palindromy (q ^ n) α σ hdual hi
  have hexp : n * (d - i) + n * i = n * d := by
    rw [← Nat.mul_add, Nat.sub_add_cancel hi]
  calc (middlePoly α).coeff (d - i) * q ^ (n * d)
      = ((middlePoly α).coeff (d - i) * (q ^ n) ^ (d - i)) * q ^ (n * i) := by
        rw [← pow_mul, mul_assoc, ← pow_add, hexp]
    _ = ((-1) ^ d * (∏ j, α j) * (middlePoly α).coeff i) * q ^ (n * i) := by rw [hpal]
    _ = (-1) ^ d * (∏ j, α j) * q ^ (n * i) * (middlePoly α).coeff i := by ring

/-- The explicit-sign version of the graded palindromy: when the Frobenius determinant on
`H^n` is `+q^m` the sign is exactly `(−1)^d`. -/
theorem middlePoly_graded_palindromy_of_prod_eq {d n m : ℕ} (hm : n * d = 2 * m) (q : R)
    (α : Fin d → R) (σ : Equiv.Perm (Fin d)) (hdual : ∀ i, α i * α (σ i) = q ^ n)
    (hprod : ∏ j, α j = q ^ m) (i : ℕ) (hi : i ≤ d) :
    q ^ (2 * m) * (middlePoly α).coeff (d - i)
      = (-1) ^ d * q ^ (m + n * i) * (middlePoly α).coeff i := by
  have hkey := middlePoly_coeff_palindromy_pow q α σ hdual hi
  rw [hm, hprod] at hkey
  rw [pow_add]
  linear_combination hkey

end CommRing

section Domain

variable {R : Type*} [CommRing R] [IsDomain R]

/-- **Conjecture A, graded form (division-free).**  For the middle factor of a smooth
proper Calabi–Yau `n`-fold over `𝔽_q` with `deg P = d` and `n·d = 2m`, there is a sign
`ε ∈ {−1, 1}` such that the coefficient vector satisfies

`q^{2m} · b_{d−i} = ε · q^{m + n i} · b_i` for every `i ≤ d`.

Dividing by `q^m` (legitimate when `q ≠ 0`, see `middlePoly_graded_palindromy_field`) this
is the graded palindromy `b_{d−i} = ε q^{n i − m} b_i`. -/
theorem middlePoly_graded_palindromy {d n m : ℕ} (hm : n * d = 2 * m) (q : R)
    (α : Fin d → R) (σ : Equiv.Perm (Fin d)) (hdual : ∀ i, α i * α (σ i) = q ^ n) :
    ∃ ε : R, (ε = 1 ∨ ε = -1) ∧ ∀ i ≤ d,
      q ^ (2 * m) * (middlePoly α).coeff (d - i)
        = ε * q ^ (m + n * i) * (middlePoly α).coeff i := by
  rcases prod_roots_eq_sign_mul_pow hm q α σ hdual with h | h
  · refine ⟨(-1) ^ d, neg_one_pow_is_sign d, fun i hi => ?_⟩
    have hkey := middlePoly_coeff_palindromy_pow q α σ hdual hi
    rw [hm] at hkey
    rw [h] at hkey
    rw [pow_add]
    linear_combination hkey
  · refine ⟨-((-1) ^ d), ?_, fun i hi => ?_⟩
    · rcases neg_one_pow_is_sign (R := R) d with hs | hs
      · exact Or.inr (by rw [hs])
      · exact Or.inl (by rw [hs]; ring)
    · have hkey := middlePoly_coeff_palindromy_pow q α σ hdual hi
      rw [hm] at hkey
      rw [h] at hkey
      rw [pow_add]
      linear_combination hkey

/-- **Palindromic support.**  Over a domain with `q ≠ 0`, the coefficient `b_i` of the
middle factor vanishes exactly when `b_{d−i}` does: the Newton polygon of `P` is symmetric
about its midpoint. -/
theorem middlePoly_coeff_eq_zero_iff {d n m : ℕ} (hm : n * d = 2 * m) (q : R) (hq : q ≠ 0)
    (α : Fin d → R) (σ : Equiv.Perm (Fin d)) (hdual : ∀ i, α i * α (σ i) = q ^ n)
    (i : ℕ) (hi : i ≤ d) :
    (middlePoly α).coeff i = 0 ↔ (middlePoly α).coeff (d - i) = 0 := by
  obtain ⟨ε, hε, h⟩ := middlePoly_graded_palindromy hm q α σ hdual
  have hq2 : q ^ (2 * m) ≠ 0 := pow_ne_zero _ hq
  have hqe : ε * q ^ (m + n * i) ≠ 0 := by
    have : ε ≠ 0 := by rcases hε with rfl | rfl <;> norm_num
    exact mul_ne_zero this (pow_ne_zero _ hq)
  constructor
  · intro h0
    have := h i hi
    rw [h0, mul_zero] at this
    exact (mul_eq_zero.mp this).resolve_left hq2
  · intro h0
    have := h i hi
    rw [h0, mul_zero] at this
    exact (mul_eq_zero.mp this.symm).resolve_left hqe

end Domain

section Field

variable {K : Type*} [Field K]

/-- **Conjecture A, cancelled field form.**  With `q ≠ 0` the graded palindromy reads
`q^m · b_{d−i} = ε · q^{n i} · b_i`, i.e. `b_{d−i} = ε q^{n i − m} b_i`. -/
theorem middlePoly_graded_palindromy_field {d n m : ℕ} (hm : n * d = 2 * m) (q : K)
    (hq : q ≠ 0) (α : Fin d → K) (σ : Equiv.Perm (Fin d))
    (hdual : ∀ i, α i * α (σ i) = q ^ n) :
    ∃ ε : K, (ε = 1 ∨ ε = -1) ∧ ∀ i ≤ d,
      q ^ m * (middlePoly α).coeff (d - i) = ε * q ^ (n * i) * (middlePoly α).coeff i := by
  obtain ⟨ε, hε, h⟩ := middlePoly_graded_palindromy hm q α σ hdual
  refine ⟨ε, hε, fun i hi => ?_⟩
  have hqm : (q : K) ^ m ≠ 0 := pow_ne_zero _ hq
  refine mul_left_cancel₀ hqm ?_
  have hkey := h i hi
  rw [two_mul, pow_add] at hkey
  rw [pow_add] at hkey
  linear_combination hkey

end Field

section Examples

variable {R : Type*} [CommRing R]

/-- The middle factor of a Calabi–Yau threefold with `b₃ = 2`: `P(X) = X² − (a+b)X + ab`. -/
theorem middlePoly_two (a b : R) :
    middlePoly ![a, b] = X ^ 2 - C (a + b) * X + C (a * b) := by
  unfold middlePoly
  rw [Fin.prod_univ_two]
  simp only [Matrix.cons_val_zero, Matrix.cons_val_one, map_add, map_mul]
  ring

@[simp] theorem middlePoly_two_coeff_zero (a b : R) : (middlePoly ![a, b]).coeff 0 = a * b := by
  rw [middlePoly_two]; simp

@[simp] theorem middlePoly_two_coeff_one (a b : R) :
    (middlePoly ![a, b]).coeff 1 = -(a + b) := by
  rw [middlePoly_two]; simp

@[simp] theorem middlePoly_two_coeff_two (a b : R) : (middlePoly ![a, b]).coeff 2 = 1 := by
  rw [middlePoly_two]; simp

/-- Root duality for a rank-two middle factor is exactly `a·b = q^n`, realized by the
transposition of the two roots. -/
theorem rootDuality_two {n : ℕ} (q a b : R) (hab : a * b = q ^ n) :
    ∀ i, (![a, b] : Fin 2 → R) i * (![a, b] : Fin 2 → R) (Equiv.swap 0 1 i) = q ^ n := by
  intro i
  fin_cases i <;> simp [Equiv.swap_apply_left, Equiv.swap_apply_right] <;>
    linear_combination hab

/-- **Calabi–Yau threefold corner of Conjecture A.**  For `n = 3`, `d = 2`, `m = 3` the
graded palindromy of `P(X) = X² − aX + q³` holds with sign `ε = +1`:
`q⁶ · b_{2−i} = q^{3+3i} · b_i` for `i = 0, 1, 2`. -/
theorem cy_threefold_graded_palindromy (q a b : R) (hab : a * b = q ^ 3) (i : ℕ) (hi : i ≤ 2) :
    q ^ 6 * (middlePoly ![a, b]).coeff (2 - i)
      = q ^ (3 + 3 * i) * (middlePoly ![a, b]).coeff i := by
  have hprod : ∏ j, (![a, b] : Fin 2 → R) j = q ^ 3 := by
    rw [Fin.prod_univ_two]; simpa using hab
  have h := middlePoly_graded_palindromy_of_prod_eq (d := 2) (n := 3) (m := 3) (by norm_num)
    q ![a, b] (Equiv.swap 0 1) (rootDuality_two q a b hab) hprod i hi
  simpa using h

end Examples

section Refutation

/-- **The exponent displayed in Conjecture A is refuted.**  The conjecture as displayed
asks for `b_{d−i} = ε q^{m − n i} b_i`, i.e. (division-free) `q^{n i} b_{d−i} = ε q^m b_i`.
Already for the Calabi–Yau threefold factor with `q = 2` and reciprocal roots `2, 4`
(so `P(X) = X² − 6X + 8`, `d = 2`, `n = m = 3`) no such sign exists: at `i = 0` the identity
reads `1 = 64 ε`.  The correct exponent is the one proved in
`middlePoly_graded_palindromy_field`, namely `q^m b_{d−i} = ε q^{n i} b_i`. -/
theorem prompt_coefficient_exponent_refuted :
    ¬ ∃ ε : ℚ, (ε = 1 ∨ ε = -1) ∧ ∀ i ≤ 2,
      (2 : ℚ) ^ (3 * i) * (middlePoly ![(2 : ℚ), 4]).coeff (2 - i)
        = ε * 2 ^ 3 * (middlePoly ![(2 : ℚ), 4]).coeff i := by
  rintro ⟨ε, hε, h⟩
  have h0 := h 0 (by norm_num)
  simp only [Nat.mul_zero, pow_zero, one_mul, Nat.sub_zero,
    middlePoly_two_coeff_two, middlePoly_two_coeff_zero] at h0
  rcases hε with rfl | rfl <;> norm_num at h0

/-- The *corrected* graded palindromy does hold for the same data, with `ε = +1`:
`2³·b_{2−i} = 2^{3i}·b_i` for `i = 0, 1, 2`. -/
theorem corrected_exponent_holds (i : ℕ) (hi : i ≤ 2) :
    (2 : ℚ) ^ 3 * (middlePoly ![(2 : ℚ), 4]).coeff (2 - i)
      = 2 ^ (3 * i) * (middlePoly ![(2 : ℚ), 4]).coeff i := by
  have h := cy_threefold_graded_palindromy (2 : ℚ) 2 4 (by norm_num) i hi
  have h2 : (2 : ℚ) ^ 6 = 2 ^ 3 * 2 ^ 3 := by norm_num
  have h3 : (2 : ℚ) ^ (3 + 3 * i) = 2 ^ 3 * 2 ^ (3 * i) := by rw [pow_add]
  rw [h2, h3] at h
  have hne : (2 : ℚ) ^ 3 ≠ 0 := by norm_num
  refine mul_left_cancel₀ hne ?_
  linear_combination h

end Refutation

end Novelty.MirrorBridge