import Mathlib

/-!
# Exactness of product-tree batch smoothness testing

Experiment 561 ("BATCH-WINS-TESTING") compared *product-tree batch smoothness
testing* against *solo trial division* on pools of `k ∈ {1, 8, 64, 512}`
candidates with smoothness bound `B = 100` and candidates of bit length `40`.
Alongside the cost measurement (formalised in
`Catalog/Applications/BatchSmoothnessCost.lean`) the experiment ran an
**exact-match audit**: the smooth set reported by the batch algorithm agreed
with per-item trial division on 500/500 samples, in all three variants
(tree-vs-trial, direct-vs-trial, vector).

This file replaces that finite audit by a theorem: the batch criterion and
trial division agree on *every* input in the tested range, not merely on 500
samples.

## The algorithm being modelled

Let `P = ∏ {p prime : p ≤ B}` (`primorialUpTo B`).  Bernstein's batch test
computes, for each candidate `n`, the residue `P mod n` in a remainder tree and
then squares it `e` times modulo `n`; it declares `n` smooth exactly when the
result is `0 mod n`, i.e. exactly when `n ∣ P ^ (2 ^ e)`.

## Main results

* `smooth_iff_dvd_primorial_pow` — the exponent criterion:
  for `0 < n < 2 ^ t`, `n` is `B`-smooth **iff** `n ∣ P ^ t`.
  (Both directions are needed: `←` is soundness, `→` is completeness, and
  completeness is exactly where the bit-length bound `n < 2 ^ t` enters.)
* `smooth_iff_dvd_primorial_pow_two_pow` — the repeated-squaring form actually
  implemented: any `e` with `t ≤ 2 ^ e` works.
* `smooth_iff_mod_criterion` — the criterion survives the modular reduction
  performed by the remainder tree.
* `exponent_sharp` — the bit-length bound is sharp: `2 ^ t ∤ P ^ s` for `s < t`,
  so no smaller exponent can be used.
* `ProdTree.eval_eq_leaves_prod` and `ProdTree.eval_eq_primorial` — the value of
  a product tree is independent of its shape, which is why the "tree" and
  "direct" arms of the audit cannot disagree.
* `batch_filter_eq_trial_filter` — the audit statement itself: on any finite
  pool of candidates below `2 ^ t`, the batch-detected smooth set **equals** the
  trial-division smooth set.
* `batch_audit_500` — a machine-checked instance of the audit on the pool
  `{1, …, 500}` with `B = 100`.
-/

namespace BatchSmoothness

open Finset

/-! ## The batch modulus -/

/-- `primorialUpTo B` is the product of all primes `≤ B`; the modulus at the
root of the product tree of the factor base. -/
def primorialUpTo (B : ℕ) : ℕ := ∏ p ∈ Nat.primesBelow (B + 1), p

lemma primorial_pos (B : ℕ) : 0 < primorialUpTo B :=
  Finset.prod_pos fun _ hp => (Nat.prime_of_mem_primesBelow hp).pos

lemma primorial_ne_zero (B : ℕ) : primorialUpTo B ≠ 0 := (primorial_pos B).ne'

/-- The factor base is squarefree: every prime `≤ B` occurs in `P` exactly once. -/
lemma factorization_primorial {B p : ℕ} (hp : p.Prime) (hpB : p ≤ B) :
    (primorialUpTo B).factorization p = 1 := by
  unfold primorialUpTo
  rw [Nat.factorization_prod (fun q hq => (Nat.prime_of_mem_primesBelow hq).ne_zero)]
  simp only [Finsupp.coe_finset_sum, Finset.sum_apply]
  rw [Finset.sum_eq_single p]
  · simp [Nat.Prime.factorization hp]
  · intro q hq hqp
    rw [Nat.Prime.factorization (Nat.prime_of_mem_primesBelow hq)]
    simp [Ne.symm hqp]
  · intro h
    exact absurd (Nat.mem_primesBelow.mpr ⟨by omega, hp⟩) h

/-- A prime divides the batch modulus exactly when it lies in the factor base. -/
lemma prime_dvd_primorial_iff {B p : ℕ} (hp : p.Prime) :
    p ∣ primorialUpTo B ↔ p ≤ B := by
  constructor
  · intro h
    obtain ⟨q, hq, hpq⟩ := (Nat.Prime.prime hp).exists_mem_finset_dvd h
    have hq' := Nat.prime_of_mem_primesBelow hq
    have hpq' : p = q := (Nat.prime_dvd_prime_iff_eq hp hq').mp hpq
    have := Nat.lt_of_mem_primesBelow hq
    omega
  · intro h
    exact Nat.dvd_of_factorization_pos (by rw [factorization_primorial hp h]; omega)

/-! ## Smoothness -/

/-- `n` is `B`-smooth: all of its prime factors are at most `B`.  This is the
predicate that solo trial division against the factor base decides. -/
def IsSmooth (B n : ℕ) : Prop := ∀ p, p.Prime → p ∣ n → p ≤ B

/-- Trial division decides smoothness: the decidable `Finset` form. -/
lemma isSmooth_iff_primeFactors {B n : ℕ} (hn : n ≠ 0) :
    IsSmooth B n ↔ ∀ p ∈ n.primeFactors, p ≤ B := by
  constructor
  · intro h p hp
    exact h p (Nat.prime_of_mem_primeFactors hp) (Nat.dvd_of_mem_primeFactors hp)
  · intro h p hp hpn
    exact h p (Nat.mem_primeFactors.mpr ⟨hp, hpn, hn⟩)

/-! ## The batch criterion is exactly smoothness -/

/-- **Batch smoothness criterion (exactness).**  For a positive candidate `n`
of bit length at most `t` (i.e. `n < 2 ^ t`), `n` is `B`-smooth if and only if
`n` divides `P ^ t`, where `P` is the product of the primes `≤ B`.

Soundness (`←`) is elementary; completeness (`→`) uses that no prime exponent in
`n` can reach `t`, because `2 ^ e ≤ p ^ e ≤ n < 2 ^ t`. -/
theorem smooth_iff_dvd_primorial_pow {B n t : ℕ} (hn : 0 < n) (hnt : n < 2 ^ t) :
    IsSmooth B n ↔ n ∣ (primorialUpTo B) ^ t := by
  constructor
  · intro hs
    rw [← Nat.factorization_le_iff_dvd hn.ne' (pow_ne_zero _ (primorial_ne_zero B))]
    intro p
    by_cases hp : p.Prime
    · by_cases hpn : p ∣ n
      · have hpB := hs p hp hpn
        rw [Nat.factorization_pow]
        simp only [Finsupp.smul_apply, smul_eq_mul, factorization_primorial hp hpB, mul_one]
        have hdvd : p ^ (n.factorization p) ∣ n := Nat.ordProj_dvd n p
        have h2 : 2 ^ (n.factorization p) ≤ p ^ (n.factorization p) :=
          Nat.pow_le_pow_left hp.two_le _
        have h3 : p ^ (n.factorization p) ≤ n := Nat.le_of_dvd hn hdvd
        have h4 : (2 : ℕ) ^ (n.factorization p) < 2 ^ t := lt_of_le_of_lt (le_trans h2 h3) hnt
        have := (Nat.pow_lt_pow_iff_right (a := 2) (by norm_num)).mp h4
        omega
      · simp [Nat.factorization_eq_zero_of_not_dvd hpn]
    · simp [Nat.factorization_eq_zero_of_not_prime _ hp]
  · intro hd p hp hpn
    exact (prime_dvd_primorial_iff hp).mp (hp.dvd_of_dvd_pow (hpn.trans hd))

/-- **Repeated-squaring form.**  The implementation raises the residue to the
`2 ^ e`-th power by `e` squarings; any `e` with `t ≤ 2 ^ e` is exact. -/
theorem smooth_iff_dvd_primorial_pow_two_pow {B n t e : ℕ} (hn : 0 < n)
    (hnt : n < 2 ^ t) (het : t ≤ 2 ^ e) :
    IsSmooth B n ↔ n ∣ (primorialUpTo B) ^ (2 ^ e) :=
  smooth_iff_dvd_primorial_pow hn (lt_of_lt_of_le hnt (Nat.pow_le_pow_right (by norm_num) het))

/-- **Remainder-tree form.**  Reducing the batch modulus modulo the candidate
before exponentiating — what the remainder tree does — does not change the
verdict. -/
theorem smooth_iff_mod_criterion {B n t : ℕ} (hn : 0 < n) (hnt : n < 2 ^ t) :
    IsSmooth B n ↔ (primorialUpTo B % n) ^ t % n = 0 := by
  rw [smooth_iff_dvd_primorial_pow hn hnt, ← Nat.pow_mod, Nat.dvd_iff_mod_eq_zero]

/-- **Sharpness of the exponent.**  For `2 ≤ B` the criterion fails for every
exponent below the bit length: `2 ^ t` is `B`-smooth but does not divide
`P ^ s` for `s < t`.  Hence the bit-length bound in
`smooth_iff_dvd_primorial_pow` cannot be weakened. -/
theorem exponent_sharp {B t s : ℕ} (hB : 2 ≤ B) :
    (2 : ℕ) ^ t ∣ (primorialUpTo B) ^ s ↔ t ≤ s := by
  have hP : (primorialUpTo B ^ s).factorization 2 = s := by
    rw [Nat.factorization_pow]
    simp [factorization_primorial Nat.prime_two hB]
  rw [Nat.Prime.pow_dvd_iff_le_factorization Nat.prime_two
      (pow_ne_zero _ (primorial_ne_zero B)), hP]

/-- The completeness direction genuinely needs the size bound: with `t = 1`
the smooth number `4` fails the criterion for every bound `B`. -/
theorem criterion_fails_without_size_bound (B : ℕ) (hB : 2 ≤ B) :
    IsSmooth B 4 ∧ ¬ (4 ∣ (primorialUpTo B) ^ 1) := by
  refine ⟨?_, ?_⟩
  · intro p hp hp4
    have h4 : (4 : ℕ) = 2 ^ 2 := by norm_num
    rw [h4] at hp4
    have : p = 2 :=
      (Nat.prime_dvd_prime_iff_eq hp Nat.prime_two).mp (hp.dvd_of_dvd_pow hp4)
    omega
  · intro h
    have : (2 : ℕ) ^ 2 ∣ (primorialUpTo B) ^ 1 := by simpa using h
    have := (exponent_sharp (B := B) (t := 2) (s := 1) hB).mp this
    omega

/-! ## Tree shape is irrelevant (the "tree vs direct" arm of the audit) -/

/-- A binary product tree over a list of leaves. -/
inductive ProdTree : Type
  | leaf : ℕ → ProdTree
  | node : ProdTree → ProdTree → ProdTree
  deriving Repr

namespace ProdTree

/-- The value computed at the root: multiply children bottom-up. -/
def eval : ProdTree → ℕ
  | leaf n => n
  | node l r => l.eval * r.eval

/-- The leaves, left to right. -/
def leaves : ProdTree → List ℕ
  | leaf n => [n]
  | node l r => l.leaves ++ r.leaves

/-- **Shape independence.**  Whatever the shape of the product tree, the root
holds the product of the leaves. -/
theorem eval_eq_leaves_prod (T : ProdTree) : T.eval = T.leaves.prod := by
  induction T with
  | leaf n => simp [eval, leaves]
  | node l r hl hr => simp [eval, leaves, hl, hr]

/-- Any product tree whose leaves are the factor base (in any order and with any
shape) evaluates to the batch modulus.  Consequently the "tree" and "direct"
arms of the audit test literally the same divisibility. -/
theorem eval_eq_primorial {B : ℕ} {T : ProdTree}
    (h : T.leaves.Perm (Nat.primesBelow (B + 1)).toList) :
    T.eval = primorialUpTo B := by
  rw [eval_eq_leaves_prod, h.prod_eq, Finset.prod_toList]
  rfl

end ProdTree

/-! ## The audit, as a theorem -/

/-- **Exact-match audit.**  On any finite pool of positive candidates of bit
length at most `t`, the set of candidates accepted by the batch criterion is
*equal* to the set accepted by per-item trial division.  The 500/500 agreement
observed in exp 561 is not a sample statistic: disagreement is impossible. -/
theorem batch_filter_eq_trial_filter (B t : ℕ) (S : Finset ℕ)
    (hS : ∀ n ∈ S, 0 < n ∧ n < 2 ^ t) :
    S.filter (fun n => n ∣ (primorialUpTo B) ^ t)
      = S.filter (fun n => ∀ p ∈ n.primeFactors, p ≤ B) := by
  apply Finset.filter_congr
  intro n hn
  obtain ⟨hpos, hlt⟩ := hS n hn
  rw [← isSmooth_iff_primeFactors hpos.ne', smooth_iff_dvd_primorial_pow hpos hlt]

/-- The audit run of exp 561, machine-checked: on the pool `{1, …, 500}` with
`B = 100` (every candidate is `< 2 ^ 9`) the two smooth sets coincide. -/
theorem batch_audit_500 :
    (Finset.Icc 1 500).filter (fun n => n ∣ (primorialUpTo 100) ^ 9)
      = (Finset.Icc 1 500).filter (fun n => ∀ p ∈ n.primeFactors, p ≤ 100) := by
  refine batch_filter_eq_trial_filter 100 9 _ ?_
  intro n hn
  simp only [Finset.mem_Icc] at hn
  omega

end BatchSmoothness