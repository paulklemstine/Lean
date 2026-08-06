/-
# The generalization bound: symmetrization

For a finite hypothesis class `F` of real valued functions on a finite domain `X`,
an arbitrary probability vector `p` on `X`, and i.i.d. samples `S ∈ Xⁿ`, the expected
uniform deviation between the true mean and the empirical mean is at most twice the
expected empirical Rademacher complexity:

  `𝔼_S sup_{f ∈ F} (𝔼_p f − Ê_S f) ≤ 2 · 𝔼_S R̂_S(F)`.

This is the classical *symmetrization* inequality, the reason Rademacher complexity
controls generalization.  Everything is finite here: expectations are explicit weighted
sums over `Xⁿ`, so no measure theory is required and the argument is completely
elementary — but not trivial: the heart of the proof is that for each sign pattern `ε`
the map exchanging the `i`-th points of the sample and of the ghost sample whenever
`ε i = false` is a weight preserving involution of `Xⁿ × Xⁿ`.

This file is self-contained.
-/
import Mathlib

namespace RademacherSymmetrization

open Finset

variable {X : Type*} [Fintype X] [DecidableEq X] {n : ℕ}

/-- The sign vector attached to a boolean vector: `true ↦ 1`, `false ↦ -1`. -/
def sgn (ε : Fin n → Bool) (i : Fin n) : ℝ := if ε i then 1 else -1

lemma sgn_not (ε : Fin n → Bool) (i : Fin n) : sgn (fun j => !(ε j)) i = -sgn ε i := by
  simp only [sgn]
  rcases Bool.eq_false_or_eq_true (ε i) with h | h <;> simp [h]

lemma sum_sign_neg (g : (Fin n → Bool) → ℝ) :
    ∑ ε : Fin n → Bool, g (fun j => !(ε j)) = ∑ ε : Fin n → Bool, g ε := by
  refine Finset.sum_nbij' (fun ε => fun j => !(ε j)) (fun ε => fun j => !(ε j))
    ?_ ?_ ?_ ?_ ?_ <;> intros <;> simp

/-- The probability of the sample `S` under the product measure. -/
def wt (p : X → ℝ) (S : Fin n → X) : ℝ := ∏ i, p (S i)

/-- The empirical mean of `f` on the sample `S`. -/
noncomputable def emp (S : Fin n → X) (f : X → ℝ) : ℝ := (1 / (n:ℝ)) * ∑ i, f (S i)

/-- The true mean of `f` under `p`. -/
def mean (p : X → ℝ) (f : X → ℝ) : ℝ := ∑ x, p x * f x

/-- The signed empirical average of `f` on the sample `S` for the sign pattern `ε`. -/
noncomputable def corr (ε : Fin n → Bool) (S : Fin n → X) (f : X → ℝ) : ℝ :=
  (1 / (n:ℝ)) * ∑ i, sgn ε i * f (S i)

/-- The maximal signed empirical average over the class. -/
noncomputable def maxCorr (F : Finset (X → ℝ)) (hne : F.Nonempty) (ε : Fin n → Bool)
    (S : Fin n → X) : ℝ := F.sup' hne (corr ε S)

/-- The empirical Rademacher complexity of `F` on the sample `S`. -/
noncomputable def radS (F : Finset (X → ℝ)) (hne : F.Nonempty) (S : Fin n → X) : ℝ :=
  (∑ ε : Fin n → Bool, maxCorr F hne ε S) / 2 ^ n

/-- The uniform deviation between true and empirical means on the sample `S`. -/
noncomputable def gap (F : Finset (X → ℝ)) (hne : F.Nonempty) (p : X → ℝ)
    (S : Fin n → X) : ℝ := F.sup' hne (fun f => mean p f - emp S f)

/-! ### The product measure -/

omit [Fintype X] [DecidableEq X] in
lemma wt_nonneg {p : X → ℝ} (hp : ∀ x, 0 ≤ p x) (S : Fin n → X) : 0 ≤ wt p S :=
  Finset.prod_nonneg fun i _ => hp (S i)

omit [DecidableEq X] in
lemma sum_wt {p : X → ℝ} (hp1 : ∑ x, p x = 1) : ∑ S : Fin n → X, wt p S = 1 := by
  classical
  have h := Finset.prod_univ_sum (κ := fun _ : Fin n => X)
      (fun _ => (Finset.univ : Finset X)) (fun _ x => p x)
  rw [Fintype.piFinset_univ] at h
  unfold wt
  rw [← h, hp1, Finset.prod_const_one]

omit [DecidableEq X] in
/-- The `i`-th marginal of the product measure is `p`. -/
lemma marginal {p : X → ℝ} (hp1 : ∑ x, p x = 1) (i : Fin n) (g : X → ℝ) :
    ∑ S : Fin n → X, wt p S * g (S i) = ∑ x, p x * g x := by
  classical
  have hfac : ∀ S : Fin n → X, wt p S * g (S i)
      = ∏ j, (if j = i then p (S j) * g (S j) else p (S j)) := by
    intro S
    rw [← Finset.mul_prod_erase _ _ (Finset.mem_univ i), if_pos rfl]
    unfold wt
    rw [← Finset.mul_prod_erase _ (fun j => p (S j)) (Finset.mem_univ i)]
    have hrest : ∀ j ∈ (Finset.univ.erase i),
        (if j = i then p (S j) * g (S j) else p (S j)) = p (S j) := by
      intro j hj
      rw [if_neg (Finset.ne_of_mem_erase hj)]
    rw [Finset.prod_congr rfl hrest]
    ring
  have h := Finset.prod_univ_sum (κ := fun _ : Fin n => X)
      (fun _ => (Finset.univ : Finset X))
      (fun j x => if j = i then p x * g x else p x)
  rw [Fintype.piFinset_univ] at h
  rw [Finset.sum_congr rfl fun S _ => hfac S, ← h]
  have hterm : ∀ i₁ : Fin n, (∑ x, if i₁ = i then p x * g x else p x)
      = if i₁ = i then (∑ x, p x * g x) else 1 := by
    intro i₁
    by_cases hi : i₁ = i
    · simp [hi]
    · simp [hi, hp1]
  rw [Finset.prod_congr rfl fun i₁ _ => hterm i₁,
    ← Finset.mul_prod_erase _ _ (Finset.mem_univ i), if_pos rfl]
  have hrest : ∀ j ∈ (Finset.univ.erase i),
      (if j = i then (∑ x, p x * g x) else (1:ℝ)) = 1 := by
    intro j hj
    rw [if_neg (Finset.ne_of_mem_erase hj)]
  rw [Finset.prod_congr rfl hrest, Finset.prod_const_one, mul_one]

omit [DecidableEq X] in
/-- The empirical mean is unbiased. -/
lemma sum_wt_emp {p : X → ℝ} (hp1 : ∑ x, p x = 1) (hn : 0 < n) (f : X → ℝ) :
    ∑ S : Fin n → X, wt p S * emp S f = mean p f := by
  have hn' : (0:ℝ) < n := by exact_mod_cast hn
  unfold emp mean
  have hstep : ∀ S : Fin n → X, wt p S * ((1 / (n:ℝ)) * ∑ i, f (S i))
      = (1 / (n:ℝ)) * ∑ i, wt p S * f (S i) := by
    intro S
    rw [← Finset.mul_sum]
    ring
  rw [Finset.sum_congr rfl fun S _ => hstep S, ← Finset.mul_sum, Finset.sum_comm]
  rw [Finset.sum_congr rfl fun i _ => marginal hp1 i f]
  rw [Finset.sum_const, nsmul_eq_mul, Finset.card_univ, Fintype.card_fin]
  field_simp

/-! ### Step 1: introducing the ghost sample -/

/-- The maximal difference of empirical means between the ghost sample `S'` and the
sample `S`. -/
noncomputable def ghostGap (F : Finset (X → ℝ)) (hne : F.Nonempty)
    (S S' : Fin n → X) : ℝ := F.sup' hne (fun f => emp S' f - emp S f)

omit [DecidableEq X] in
lemma gap_le_ghost {p : X → ℝ} (hp : ∀ x, 0 ≤ p x) (hp1 : ∑ x, p x = 1) (hn : 0 < n)
    (F : Finset (X → ℝ)) (hne : F.Nonempty) (S : Fin n → X) :
    gap F hne p S ≤ ∑ S' : Fin n → X, wt p S' * ghostGap F hne S S' := by
  unfold gap
  refine Finset.sup'_le _ _ fun f hf => ?_
  have hrw : mean p f - emp S f = ∑ S' : Fin n → X, wt p S' * (emp S' f - emp S f) := by
    have h1 : ∑ S' : Fin n → X, wt p S' * (emp S' f - emp S f)
        = (∑ S' : Fin n → X, wt p S' * emp S' f) - (∑ S' : Fin n → X, wt p S') * emp S f := by
      rw [Finset.sum_mul, ← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun S' _ => by ring
    rw [h1, sum_wt_emp hp1 hn f, sum_wt hp1, one_mul]
  rw [hrw]
  refine Finset.sum_le_sum fun S' _ => ?_
  have hle : emp S' f - emp S f ≤ ghostGap F hne S S' :=
    Finset.le_sup' (fun f => emp S' f - emp S f) hf
  exact mul_le_mul_of_nonneg_left hle (wt_nonneg hp S')

/-! ### Step 2: the swapping involution -/

/-- Exchange the `i`-th points of the sample and the ghost sample whenever `ε i = false`. -/
def swapPair (ε : Fin n → Bool) (q : (Fin n → X) × (Fin n → X)) :
    (Fin n → X) × (Fin n → X) :=
  (fun i => if ε i then q.1 i else q.2 i, fun i => if ε i then q.2 i else q.1 i)

omit [Fintype X] [DecidableEq X] in
lemma swapPair_involutive (ε : Fin n → Bool) :
    Function.Involutive (swapPair (X := X) ε) := by
  intro q
  ext i <;> by_cases h : ε i = true <;> simp [swapPair, h]

omit [Fintype X] [DecidableEq X] in
lemma wt_swapPair {p : X → ℝ} (ε : Fin n → Bool) (q : (Fin n → X) × (Fin n → X)) :
    wt p (swapPair ε q).1 * wt p (swapPair ε q).2 = wt p q.1 * wt p q.2 := by
  unfold wt swapPair
  rw [← Finset.prod_mul_distrib, ← Finset.prod_mul_distrib]
  refine Finset.prod_congr rfl fun i _ => ?_
  by_cases h : ε i = true <;> simp [h, mul_comm]

omit [Fintype X] [DecidableEq X] in
lemma ghostGap_swapPair (F : Finset (X → ℝ)) (hne : F.Nonempty)
    (ε : Fin n → Bool) (q : (Fin n → X) × (Fin n → X)) :
    ghostGap F hne (swapPair ε q).1 (swapPair ε q).2
      = F.sup' hne (fun f => (1 / (n:ℝ)) * ∑ i, sgn ε i * (f (q.2 i) - f (q.1 i))) := by
  unfold ghostGap
  refine Finset.sup'_congr hne rfl fun f _ => ?_
  unfold emp swapPair
  simp only
  rw [← mul_sub, ← Finset.sum_sub_distrib]
  congr 1
  refine Finset.sum_congr rfl fun i _ => ?_
  by_cases h : ε i = true <;> simp [sgn, h]

/-! ### Step 3: the symmetrized quantity is bounded by two Rademacher terms -/

omit [Fintype X] [DecidableEq X] in
lemma symmetrized_le (F : Finset (X → ℝ)) (hne : F.Nonempty) (ε : Fin n → Bool)
    (q : (Fin n → X) × (Fin n → X)) :
    F.sup' hne (fun f => (1 / (n:ℝ)) * ∑ i, sgn ε i * (f (q.2 i) - f (q.1 i)))
      ≤ maxCorr F hne ε q.2 + maxCorr F hne (fun j => !(ε j)) q.1 := by
  refine Finset.sup'_le _ _ fun f hf => ?_
  have hsplit : (1 / (n:ℝ)) * ∑ i, sgn ε i * (f (q.2 i) - f (q.1 i))
      = corr ε q.2 f + corr (fun j => !(ε j)) q.1 f := by
    unfold corr
    rw [← mul_add, ← Finset.sum_add_distrib]
    congr 1
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [sgn_not]
    ring
  rw [hsplit]
  exact add_le_add (Finset.le_sup' (corr ε q.2) hf)
    (Finset.le_sup' (corr (fun j => !(ε j)) q.1) hf)

/-! ### The generalization bound -/

omit [DecidableEq X] in
/-- **Symmetrization / generalization bound.**  The expected uniform deviation of
empirical means from true means is at most twice the expected empirical Rademacher
complexity of the class. -/
theorem generalization_bound {p : X → ℝ} (hp : ∀ x, 0 ≤ p x) (hp1 : ∑ x, p x = 1)
    (hn : 0 < n) (F : Finset (X → ℝ)) (hne : F.Nonempty) :
    ∑ S : Fin n → X, wt p S * gap F hne p S
      ≤ 2 * ∑ S : Fin n → X, wt p S * radS F hne S := by
  classical
  have hpow : (0:ℝ) < 2 ^ n := by positivity
  set G : (Fin n → X) × (Fin n → X) → ℝ :=
    fun q => wt p q.1 * wt p q.2 * ghostGap F hne q.1 q.2 with hG
  set K : (Fin n → Bool) → ℝ := fun ε =>
    ∑ q : (Fin n → X) × (Fin n → X), wt p q.1 * wt p q.2 *
      F.sup' hne (fun f => (1 / (n:ℝ)) * ∑ i, sgn ε i * (f (q.2 i) - f (q.1 i))) with hK
  -- Step 1: compare with the ghost sample
  have step1 : ∑ S : Fin n → X, wt p S * gap F hne p S
      ≤ ∑ q : (Fin n → X) × (Fin n → X), G q := by
    rw [Fintype.sum_prod_type]
    refine Finset.sum_le_sum fun S _ => ?_
    have h := gap_le_ghost hp hp1 hn F hne S
    calc wt p S * gap F hne p S
        ≤ wt p S * ∑ S' : Fin n → X, wt p S' * ghostGap F hne S S' :=
          mul_le_mul_of_nonneg_left h (wt_nonneg hp S)
      _ = ∑ S' : Fin n → X, G (S, S') := by
          rw [Finset.mul_sum]
          refine Finset.sum_congr rfl fun S' _ => ?_
          simp only [hG]
          ring
  -- Step 2: for each sign pattern the swap is a weight preserving involution
  have step2 : ∀ ε : Fin n → Bool, ∑ q : (Fin n → X) × (Fin n → X), G q = K ε := by
    intro ε
    have hperm := Equiv.sum_comp (swapPair_involutive (X := X) ε).toPerm G
    rw [← hperm]
    refine Finset.sum_congr rfl fun q _ => ?_
    show G (swapPair ε q) = _
    simp only [hG]
    rw [wt_swapPair ε q, ghostGap_swapPair F hne ε q]
  -- Step 3: split the symmetrized term into two Rademacher terms
  have step3 : ∀ ε : Fin n → Bool, K ε
      ≤ ∑ S : Fin n → X, wt p S * maxCorr F hne ε S
        + ∑ S : Fin n → X, wt p S * maxCorr F hne (fun j => !(ε j)) S := by
    intro ε
    have hle : K ε ≤ ∑ q : (Fin n → X) × (Fin n → X), wt p q.1 * wt p q.2 *
        (maxCorr F hne ε q.2 + maxCorr F hne (fun j => !(ε j)) q.1) := by
      simp only [hK]
      refine Finset.sum_le_sum fun q _ => ?_
      exact mul_le_mul_of_nonneg_left (symmetrized_le F hne ε q)
        (mul_nonneg (wt_nonneg hp q.1) (wt_nonneg hp q.2))
    refine hle.trans (le_of_eq ?_)
    rw [Fintype.sum_prod_type]
    have hsplit : ∀ S : Fin n → X, (∑ S' : Fin n → X, wt p S * wt p S' *
        (maxCorr F hne ε S' + maxCorr F hne (fun j => !(ε j)) S))
        = wt p S * (∑ S' : Fin n → X, wt p S' * maxCorr F hne ε S')
          + wt p S * maxCorr F hne (fun j => !(ε j)) S := by
      intro S
      have h1 : ∀ S' : Fin n → X, wt p S * wt p S' *
          (maxCorr F hne ε S' + maxCorr F hne (fun j => !(ε j)) S)
          = wt p S * (wt p S' * maxCorr F hne ε S')
            + (wt p S * maxCorr F hne (fun j => !(ε j)) S) * wt p S' := fun S' => by ring
      rw [Finset.sum_congr rfl fun S' _ => h1 S', Finset.sum_add_distrib,
        ← Finset.mul_sum, ← Finset.mul_sum, sum_wt hp1, mul_one]
    rw [Finset.sum_congr rfl fun S _ => hsplit S, Finset.sum_add_distrib,
      ← Finset.sum_mul, sum_wt hp1, one_mul]
  -- averaging the identity of Step 2 over all sign patterns
  have hconst : ∑ ε : Fin n → Bool, K ε
      = 2 ^ n * ∑ q : (Fin n → X) × (Fin n → X), G q := by
    rw [Finset.sum_congr rfl fun ε _ => (step2 ε).symm, Finset.sum_const, nsmul_eq_mul,
      Finset.card_univ]
    simp only [Fintype.card_fun, Fintype.card_bool, Fintype.card_fin]
    push_cast
    ring
  have hswap : ∑ ε : Fin n → Bool, ∑ S : Fin n → X,
        wt p S * maxCorr F hne (fun j => !(ε j)) S
      = ∑ ε : Fin n → Bool, ∑ S : Fin n → X, wt p S * maxCorr F hne ε S :=
    sum_sign_neg (fun ε => ∑ S : Fin n → X, wt p S * maxCorr F hne ε S)
  have hradsum : ∑ ε : Fin n → Bool, ∑ S : Fin n → X, wt p S * maxCorr F hne ε S
      = 2 ^ n * ∑ S : Fin n → X, wt p S * radS F hne S := by
    rw [Finset.sum_comm, Finset.mul_sum]
    refine Finset.sum_congr rfl fun S _ => ?_
    unfold radS
    rw [← Finset.mul_sum]
    field_simp
  have hsum : ∑ ε : Fin n → Bool, K ε
      ≤ 2 * (2 ^ n * ∑ S : Fin n → X, wt p S * radS F hne S) := by
    calc ∑ ε : Fin n → Bool, K ε
        ≤ ∑ ε : Fin n → Bool, (∑ S : Fin n → X, wt p S * maxCorr F hne ε S
            + ∑ S : Fin n → X, wt p S * maxCorr F hne (fun j => !(ε j)) S) :=
          Finset.sum_le_sum fun ε _ => step3 ε
      _ = 2 * (2 ^ n * ∑ S : Fin n → X, wt p S * radS F hne S) := by
          rw [Finset.sum_add_distrib, hswap, hradsum]
          ring
  have hGle : ∑ q : (Fin n → X) × (Fin n → X), G q
      ≤ 2 * ∑ S : Fin n → X, wt p S * radS F hne S := by
    have h1 : 2 ^ n * ∑ q : (Fin n → X) × (Fin n → X), G q
        ≤ 2 ^ n * (2 * ∑ S : Fin n → X, wt p S * radS F hne S) := by
      rw [← hconst]
      calc ∑ ε : Fin n → Bool, K ε
          ≤ 2 * (2 ^ n * ∑ S : Fin n → X, wt p S * radS F hne S) := hsum
        _ = 2 ^ n * (2 * ∑ S : Fin n → X, wt p S * radS F hne S) := by ring
    exact le_of_mul_le_mul_left h1 hpow
  exact step1.trans hGle

/-! ### A Massart bound for the empirical Rademacher complexity of a finite class

To turn the symmetrization inequality into a concrete generalization bound we bound the
empirical Rademacher complexity of a finite class of uniformly bounded functions by the
Chernoff/moment generating function argument, exactly as in Massart's finite class
lemma.
-/

omit [Fintype X] [DecidableEq X] in
/-- Jensen's inequality for `exp` over the uniform distribution on sign patterns. -/
lemma exp_avg_le (y : (Fin n → Bool) → ℝ) :
    Real.exp ((∑ ε : Fin n → Bool, y ε) / 2 ^ n)
      ≤ (∑ ε : Fin n → Bool, Real.exp (y ε)) / 2 ^ n := by
  have hw : ∀ ε ∈ (Finset.univ : Finset (Fin n → Bool)), (0:ℝ) ≤ 1 / 2 ^ n := by
    intro ε _; positivity
  have hsum : ∑ _ε : Fin n → Bool, (1:ℝ) / 2 ^ n = 1 := by
    rw [Finset.sum_const, nsmul_eq_mul, Finset.card_univ]
    simp
  have key := ConvexOn.map_sum_le (𝕜 := ℝ) (t := (Finset.univ : Finset (Fin n → Bool)))
    (w := fun _ => 1 / (2:ℝ) ^ n) (p := y) convexOn_exp hw hsum (fun ε _ => Set.mem_univ _)
  simp only [smul_eq_mul] at key
  calc Real.exp ((∑ ε : Fin n → Bool, y ε) / 2 ^ n)
      = Real.exp (∑ ε : Fin n → Bool, (1 / (2:ℝ) ^ n) * y ε) := by
        rw [← Finset.mul_sum]; ring_nf
    _ ≤ ∑ ε : Fin n → Bool, (1 / (2:ℝ) ^ n) * Real.exp (y ε) := key
    _ = (∑ ε : Fin n → Bool, Real.exp (y ε)) / 2 ^ n := by
        rw [← Finset.mul_sum]; ring

omit [Fintype X] [DecidableEq X] in
/-- Factorisation of the Rademacher moment generating function. -/
lemma sum_exp_signed (v : Fin n → ℝ) (l : ℝ) :
    ∑ ε : Fin n → Bool, Real.exp (l * ∑ i, sgn ε i * v i)
      = ∏ i, (Real.exp (l * v i) + Real.exp (-(l * v i))) := by
  classical
  have hfac : ∀ ε : Fin n → Bool,
      Real.exp (l * ∑ i, sgn ε i * v i) = ∏ i, Real.exp (l * sgn ε i * v i) := by
    intro ε
    rw [← Real.exp_sum, Finset.mul_sum]
    congr 1
    exact Finset.sum_congr rfl fun i _ => by ring
  have h := Finset.prod_univ_sum (κ := fun _ : Fin n => Bool)
      (fun _ => (Finset.univ : Finset Bool))
      (fun i b => Real.exp (l * (if b then (1:ℝ) else -1) * v i))
  rw [Fintype.piFinset_univ] at h
  rw [Finset.sum_congr rfl (fun ε _ => hfac ε)]
  simp only [sgn]
  rw [← h]
  refine Finset.prod_congr rfl fun i _ => ?_
  rw [Fintype.sum_bool]
  norm_num

omit [Fintype X] [DecidableEq X] in
/-- The sub-Gaussian bound for a Rademacher sum. -/
lemma prod_exp_le (v : Fin n → ℝ) (l : ℝ) :
    ∏ i, (Real.exp (l * v i) + Real.exp (-(l * v i)))
      ≤ 2 ^ n * Real.exp (l ^ 2 * (∑ i, (v i) ^ 2) / 2) := by
  have hstep : ∀ i : Fin n, Real.exp (l * v i) + Real.exp (-(l * v i))
      ≤ 2 * Real.exp ((l * v i) ^ 2 / 2) := by
    intro i
    have h := Real.cosh_le_exp_half_sq (l * v i)
    rw [Real.cosh_eq] at h
    linarith
  calc ∏ i, (Real.exp (l * v i) + Real.exp (-(l * v i)))
      ≤ ∏ i, (2 * Real.exp ((l * v i) ^ 2 / 2)) :=
        Finset.prod_le_prod (fun i _ => by positivity) (fun i _ => hstep i)
    _ = 2 ^ n * ∏ i, Real.exp ((l * v i) ^ 2 / 2) := by
        rw [Finset.prod_mul_distrib]; simp
    _ = 2 ^ n * Real.exp (∑ i, (l * v i) ^ 2 / 2) := by rw [Real.exp_sum]
    _ = 2 ^ n * Real.exp (l ^ 2 * (∑ i, (v i) ^ 2) / 2) := by
        congr 2
        rw [Finset.mul_sum, Finset.sum_div]
        exact Finset.sum_congr rfl fun i _ => by ring

omit [Fintype X] [DecidableEq X] in
/-- The optimal choice of the Chernoff parameter. -/
lemma optimal_lambda {c L s : ℝ} (hc : 0 < c) (hs : 0 < s) (hsq : s * s = 2 * L / c) :
    L / s + s * c / 2 = Real.sqrt (2 * L * c) := by
  have hL : L = s * s * c / 2 := by
    field_simp at hsq ⊢
    linarith [hsq]
  have hpos : 2 * L * c = (s * c) ^ 2 := by rw [hL]; ring
  rw [hpos, Real.sqrt_sq (by positivity)]
  rw [hL]
  field_simp
  ring

omit [Fintype X] [DecidableEq X] in
/-- The Chernoff bound for the empirical Rademacher complexity of a finite class of
functions bounded by `B` on the sample `S`. -/
lemma radS_chernoff (hn : 0 < n) (F : Finset (X → ℝ)) (hne : F.Nonempty) (S : Fin n → X)
    {B l : ℝ} (hl : 0 < l) (hbd : ∀ f ∈ F, ∀ x, |f x| ≤ B) :
    radS F hne S ≤ Real.log F.card / l + l * (B ^ 2 / n) / 2 := by
  classical
  have hn' : (0:ℝ) < n := by exact_mod_cast hn
  have hpow : (0:ℝ) < 2 ^ n := by positivity
  have hBnn : 0 ≤ B := by
    obtain ⟨f, hf⟩ := hne
    obtain ⟨x⟩ : Nonempty X := ⟨S ⟨0, hn⟩⟩
    exact le_trans (abs_nonneg (f x)) (hbd f hf x)
  set A := radS F hne S with hA
  have hstep1 : Real.exp (l * A)
      ≤ (∑ ε : Fin n → Bool, Real.exp (l * maxCorr F hne ε S)) / 2 ^ n := by
    have hrw : l * A = (∑ ε : Fin n → Bool, l * maxCorr F hne ε S) / 2 ^ n := by
      rw [← Finset.mul_sum, hA]
      unfold radS
      ring
    rw [hrw]
    exact exp_avg_le _
  have hstep2 : ∀ ε : Fin n → Bool, Real.exp (l * maxCorr F hne ε S)
      ≤ ∑ f ∈ F, Real.exp ((l / n) * ∑ i, sgn ε i * f (S i)) := by
    intro ε
    obtain ⟨f₀, hf₀, hval⟩ := Finset.exists_mem_eq_sup' hne (corr ε S)
    have he : Real.exp (l * maxCorr F hne ε S)
        = Real.exp ((l / n) * ∑ i, sgn ε i * f₀ (S i)) := by
      unfold maxCorr
      rw [hval]
      congr 1
      unfold corr
      field_simp
    rw [he]
    exact Finset.single_le_sum
      (f := fun f => Real.exp ((l / n) * ∑ i, sgn ε i * f (S i)))
      (fun f _ => (Real.exp_pos _).le) hf₀
  have hstep3 : ∑ ε : Fin n → Bool, Real.exp (l * maxCorr F hne ε S)
      ≤ 2 ^ n * (F.card * Real.exp (l ^ 2 * (B ^ 2 / n) / 2)) := by
    calc ∑ ε : Fin n → Bool, Real.exp (l * maxCorr F hne ε S)
        ≤ ∑ ε : Fin n → Bool, ∑ f ∈ F, Real.exp ((l / n) * ∑ i, sgn ε i * f (S i)) :=
          Finset.sum_le_sum fun ε _ => hstep2 ε
      _ = ∑ f ∈ F, ∑ ε : Fin n → Bool, Real.exp ((l / n) * ∑ i, sgn ε i * f (S i)) :=
          Finset.sum_comm
      _ ≤ ∑ _f ∈ F, 2 ^ n * Real.exp (l ^ 2 * (B ^ 2 / n) / 2) := by
          refine Finset.sum_le_sum fun f hf => ?_
          rw [sum_exp_signed (fun i => f (S i)) (l / n)]
          have hnorm : ∑ i, (f (S i)) ^ 2 ≤ (n:ℝ) * B ^ 2 := by
            calc ∑ i, (f (S i)) ^ 2 ≤ ∑ _i : Fin n, B ^ 2 := by
                  refine Finset.sum_le_sum fun i _ => ?_
                  have := hbd f hf (S i)
                  nlinarith [abs_nonneg (f (S i)), sq_abs (f (S i))]
              _ = (n:ℝ) * B ^ 2 := by simp [Finset.sum_const]
          calc ∏ i, (Real.exp ((l / n) * f (S i)) + Real.exp (-((l / n) * f (S i))))
              ≤ 2 ^ n * Real.exp ((l / n) ^ 2 * (∑ i, (f (S i)) ^ 2) / 2) :=
                prod_exp_le (fun i => f (S i)) (l / n)
            _ ≤ 2 ^ n * Real.exp (l ^ 2 * (B ^ 2 / n) / 2) := by
                have hmono : (l / n) ^ 2 * (∑ i, (f (S i)) ^ 2) / 2
                    ≤ l ^ 2 * (B ^ 2 / n) / 2 := by
                  have hexp1 : (l / (n:ℝ)) ^ 2 * (∑ i, (f (S i)) ^ 2) / 2
                      = l ^ 2 * (∑ i, (f (S i)) ^ 2) / (2 * (n:ℝ) ^ 2) := by
                    field_simp
                  have hexp2 : l ^ 2 * (B ^ 2 / (n:ℝ)) / 2
                      = l ^ 2 * ((n:ℝ) * B ^ 2) / (2 * (n:ℝ) ^ 2) := by
                    field_simp
                  rw [hexp1, hexp2]
                  exact div_le_div_of_nonneg_right
                    (by nlinarith [hnorm, sq_nonneg l]) (by positivity)
                have := Real.exp_le_exp.mpr hmono
                nlinarith [Real.exp_pos ((l / n) ^ 2 * (∑ i, (f (S i)) ^ 2) / 2), hpow]
      _ = 2 ^ n * (F.card * Real.exp (l ^ 2 * (B ^ 2 / n) / 2)) := by
          rw [Finset.sum_const, nsmul_eq_mul]; ring
  have hcard : (0:ℝ) < F.card := by exact_mod_cast Finset.card_pos.mpr hne
  have hexp : Real.exp (l * A) ≤ F.card * Real.exp (l ^ 2 * (B ^ 2 / n) / 2) := by
    calc Real.exp (l * A)
        ≤ (∑ ε : Fin n → Bool, Real.exp (l * maxCorr F hne ε S)) / 2 ^ n := hstep1
      _ ≤ (2 ^ n * (F.card * Real.exp (l ^ 2 * (B ^ 2 / n) / 2))) / 2 ^ n :=
          div_le_div_of_nonneg_right hstep3 hpow.le
      _ = F.card * Real.exp (l ^ 2 * (B ^ 2 / n) / 2) := by field_simp
  have hlog : l * A ≤ Real.log F.card + l ^ 2 * (B ^ 2 / n) / 2 := by
    have hrhs : (F.card : ℝ) * Real.exp (l ^ 2 * (B ^ 2 / n) / 2)
        = Real.exp (Real.log F.card + l ^ 2 * (B ^ 2 / n) / 2) := by
      rw [Real.exp_add, Real.exp_log hcard]
    rw [hrhs] at hexp
    exact Real.exp_le_exp.mp hexp
  rw [div_add' _ _ _ hl.ne', le_div_iff₀ hl]
  nlinarith [hlog]

omit [Fintype X] [DecidableEq X] in
/-- **Massart's bound on the sample.**  A finite class of `N` functions bounded by `B`
has empirical Rademacher complexity at most `B √(2 log N / n)` on every sample. -/
theorem radS_le_massart (hn : 0 < n) (F : Finset (X → ℝ)) (hne : F.Nonempty)
    (S : Fin n → X) {B : ℝ} (hbd : ∀ f ∈ F, ∀ x, |f x| ≤ B) :
    radS F hne S ≤ B * Real.sqrt (2 * Real.log F.card) / Real.sqrt n := by
  classical
  have hn' : (0:ℝ) < n := by exact_mod_cast hn
  have hBnn : 0 ≤ B := by
    obtain ⟨f, hf⟩ := hne
    exact le_trans (abs_nonneg (f (S ⟨0, hn⟩))) (hbd f hf (S ⟨0, hn⟩))
  by_cases hcard1 : F.card = 1
  · -- singleton class: the complexity vanishes
    obtain ⟨f, hf⟩ := Finset.card_eq_one.mp hcard1
    have hzero : radS F hne S = 0 := by
      unfold radS
      have hmem : ∀ g ∈ F, g = f := by
        intro g hg
        rw [hf] at hg
        simpa using hg
      have hfF : f ∈ F := by rw [hf]; simp
      have hmax : ∀ ε : Fin n → Bool, maxCorr F hne ε S = corr ε S f := by
        intro ε
        unfold maxCorr
        refine le_antisymm (Finset.sup'_le _ _ fun g hg => ?_) (Finset.le_sup' (corr ε S) hfF)
        rw [hmem g hg]
      rw [Finset.sum_congr rfl fun ε _ => hmax ε]
      have : ∑ ε : Fin n → Bool, corr ε S f = 0 := by
        unfold corr
        rw [← Finset.mul_sum, Finset.sum_comm]
        have hz : ∀ i : Fin n, ∑ ε : Fin n → Bool, sgn ε i * f (S i) = 0 := by
          intro i
          rw [← Finset.sum_mul]
          have hsgn : ∑ ε : Fin n → Bool, sgn ε i = 0 := by
            have h := sum_sign_neg (fun ε => sgn ε i)
            simp only [sgn_not] at h
            rw [Finset.sum_neg_distrib] at h
            linarith
          rw [hsgn, zero_mul]
        simp [hz]
      rw [this]
      simp
    rw [hzero, hcard1]
    simp
  · have hcard2 : 2 ≤ F.card := by
      have := Finset.card_pos.mpr hne
      omega
    have hcardR : (2:ℝ) ≤ F.card := by exact_mod_cast hcard2
    have hlogpos : 0 < Real.log F.card := Real.log_pos (by linarith)
    rcases eq_or_lt_of_le hBnn with hB0 | hBpos
    · -- `B = 0` forces the class to be the single zero function
      exfalso
      have hzero : ∀ f ∈ F, f = 0 := by
        intro f hf
        funext x
        have := hbd f hf x
        rw [← hB0] at this
        simpa using abs_nonpos_iff.mp this
      have hsub : F ⊆ {0} := fun f hf => by simp [hzero f hf]
      have := Finset.card_le_card hsub
      simp at this
      omega
    · set L := Real.log F.card with hL
      set c := B ^ 2 / (n:ℝ) with hc
      have hcpos : 0 < c := by rw [hc]; positivity
      set l := Real.sqrt (2 * L / c) with hl
      have hlpos : 0 < l := Real.sqrt_pos.mpr (by positivity)
      have hsq : l * l = 2 * L / c := Real.mul_self_sqrt (by positivity)
      have hbound := radS_chernoff hn F hne S hlpos hbd
      have hval : L / l + l * c / 2 = Real.sqrt (2 * L * c) :=
        optimal_lambda hcpos hlpos hsq
      have hfinal : Real.sqrt (2 * L * c) = B * Real.sqrt (2 * L) / Real.sqrt n := by
        rw [hc]
        rw [show 2 * L * (B ^ 2 / (n:ℝ)) = (2 * L) * (B ^ 2 / (n:ℝ)) by ring]
        rw [Real.sqrt_mul (by positivity), Real.sqrt_div (by positivity),
          Real.sqrt_sq hBnn]
        ring
      rw [hval, hfinal] at hbound
      exact hbound

omit [DecidableEq X] in
/-- **Generalization bound for a finite hypothesis class.**  For a class of `N`
functions bounded by `B`, the expected uniform deviation between empirical and true
means over an i.i.d. sample of size `n` is at most `2 B √(2 log N / n)`. -/
theorem finite_class_generalization {p : X → ℝ} (hp : ∀ x, 0 ≤ p x) (hp1 : ∑ x, p x = 1)
    (hn : 0 < n) (F : Finset (X → ℝ)) (hne : F.Nonempty) {B : ℝ}
    (hbd : ∀ f ∈ F, ∀ x, |f x| ≤ B) :
    ∑ S : Fin n → X, wt p S * gap F hne p S
      ≤ 2 * (B * Real.sqrt (2 * Real.log F.card) / Real.sqrt n) := by
  have hmain := generalization_bound hp hp1 hn F hne
  have hsum : ∑ S : Fin n → X, wt p S * radS F hne S
      ≤ B * Real.sqrt (2 * Real.log F.card) / Real.sqrt n := by
    calc ∑ S : Fin n → X, wt p S * radS F hne S
        ≤ ∑ S : Fin n → X, wt p S * (B * Real.sqrt (2 * Real.log F.card) / Real.sqrt n) := by
          refine Finset.sum_le_sum fun S _ => ?_
          exact mul_le_mul_of_nonneg_left (radS_le_massart hn F hne S hbd) (wt_nonneg hp S)
      _ = B * Real.sqrt (2 * Real.log F.card) / Real.sqrt n := by
          rw [← Finset.sum_mul, sum_wt hp1, one_mul]
  linarith

end RademacherSymmetrization