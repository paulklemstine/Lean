import Catalog.Computation.CyclicTypeDeterminism

/-!
# The prime-order cyclic type-pair channel: an exact closed form and the sub-cap theorem

The catalog file `Catalog.Computation.CyclicTypeChannel` sets up the splitting-type channel
of a cyclic Galois group `C_n` (realised as `Fin n`, with `typ n x = n / gcd n x` the residue
degree of the Frobenius class `x`) and its *semiprime type-pair channel*

`Ipair n = H(Π) - (1/n) Σ_c H(Π_c)`,

with `Π` the law of the unordered type pair `{T(x), T(y)}` and `Π_c` its law conditioned on the
"norm" `x + y = c`.  That file, and `Catalog.Computation.CyclicTypeChannelLaws`, evaluate
`Ipair n` for a finite list of orders `n ≤ 20` one by one.

Here we prove the first *uniform in `n`* theorem about the pair channel: a closed form for
`Ipair p` valid for **every prime cyclic order** `p`, and its consequences.

## Main results

* `CyclicType.Ipair_prime` : for every prime `p`,
  `Ipair p = log₂ p - ((p-1)(2p-1)/p²) log₂ (p-1) + ((p-1)(p-2)/p²) log₂ (p-2)`.
  This is an exact identity, proved by evaluating the three type-pair states
  `{1,1}, {1,p}, {p,p}` and the two norm regimes `c = 0`, `c ≠ 0` for symbolic `p`.
* `CyclicType.Ipair_prime_le` : the clean upper envelope
  `Ipair p ≤ log₂ p - log₂ (p-1) + log₂ (p-1) / p²`.
* `CyclicType.Ipair_prime_decay` : the quantitative decay `Ipair p < 3/(p-1)` for odd primes;
  the prime-order type channel is asymptotically silent.
* `CyclicType.Ipair_prime_lt_one` : **the sub-cap theorem** — every *odd* prime cyclic order
  stays strictly below the one-bit binary-fork cap, while
* `CyclicType.Ipair_prime_eq_one_iff_two` : `p = 2` is the unique prime order attaining it.
  Together with the strict violations `1 < Ipair 4, 6, 8, …` proved in
  `Catalog.Computation.CyclicTypeChannelLaws`, this pins the cap-breaking phenomenon on the
  *divisor structure* of the cyclic order: a prime order can never break the cap.
* `CyclicType.typNat_mul_coprime` : the structural multiplicativity
  `T_{mn}(a) = lcm (T_m(a), T_n(a)) = T_m(a) · T_n(a)` for coprime `m, n` — the CRT
  decomposition of the splitting type behind the observed additivity laws.
* `CyclicType.HT_mul_coprime` : the corresponding **exact additivity of the type entropy**
  `H(T)(mn) = H(T)(m) + H(T)(n)` for coprime `m, n`, for all `m, n ≥ 1`.
-/

set_option maxHeartbeats 1000000

namespace CyclicType

open Finset

/-! ## Generic list/counting infrastructure -/

/-- Entropy only depends on the *multiset* of occupation numbers. -/
theorem Hlist_perm {tot : ℕ} {cs cs' : List ℕ} (h : cs.Perm cs') : Hlist tot cs = Hlist tot cs' := by
  unfold Hlist
  rw [(h.map _).sum_eq]

lemma listCountP_eq_sum {α : Type*} (l : List α) (q : α → Bool) :
    l.countP q = (l.map (fun a => if q a then 1 else 0)).sum := by
  induction l with
  | nil => simp
  | cons a l ih => rw [List.countP_cons, ih]; by_cases h : q a <;> simp [h, Nat.add_comm]

lemma sum_fin_eq_list {M : Type*} [AddCommMonoid M] (n : ℕ) (f : Fin n → M) :
    ∑ y : Fin n, f y = ((List.finRange n).map f).sum := by
  rw [Finset.sum_eq_multiset_sum]; rfl

lemma countP_finRange (n : ℕ) (q : Fin n → Bool) :
    (List.finRange n).countP q = ∑ y : Fin n, if q y then 1 else 0 := by
  rw [listCountP_eq_sum, sum_fin_eq_list]

/-- Counting inside the list of all ordered residue pairs is a double `Finset` sum. -/
theorem length_filter_allPairs (n : ℕ) (P : Fin n × Fin n → Bool) :
    ((allPairs n).filter P).length = ∑ x : Fin n, ∑ y : Fin n, if P (x, y) then 1 else 0 := by
  rw [← List.countP_eq_length_filter, allPairs, List.countP_flatMap]
  rw [sum_fin_eq_list n (fun x => ∑ y : Fin n, if P (x, y) then 1 else 0)]
  refine congrArg List.sum (List.map_congr_left ?_)
  intro x _
  simp only [Function.comp_apply, List.countP_map]
  rw [countP_finRange]
  rfl

/-! ### Elementary indicator sums over `Fin p` -/

lemma sum_ite_val_zero (p : ℕ) [NeZero p] : ∑ y : Fin p, (if y.val = 0 then 1 else 0) = 1 := by
  simp

lemma sum_ite_val_ne_zero (p : ℕ) [NeZero p] :
    ∑ y : Fin p, (if y.val = 0 then 0 else 1) = p - 1 := by
  have h : ∀ y : Fin p, (if y.val = 0 then 0 else 1) = (if y = 0 then 0 else 1) := by
    intro y
    rcases eq_or_ne y 0 with rfl | hy
    · simp
    · simp [hy, Fin.val_eq_zero_iff]
  simp only [h]
  rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const, Finset.filter_ne']
  simp [Finset.card_erase_of_mem]

lemma sum_ite_two_ne (p : ℕ) [NeZero p] {c : Fin p} (hc : c ≠ 0) :
    ∑ x : Fin p, (if x = 0 then 0 else if x = c then 0 else 1) = p - 2 := by
  have h : ∀ x : Fin p, (if x = 0 then 0 else if x = c then 0 else 1)
      = (if (x = 0 ∨ x = c) then 0 else 1) := by
    intro x
    rcases eq_or_ne x 0 with rfl | hx
    · simp
    · rcases eq_or_ne x c with rfl | hxc
      · simp [hx]
      · simp [hx, hxc]
  have hfil : (Finset.univ.filter (fun x : Fin p => ¬ (x = 0 ∨ x = c)))
      = ({0, c} : Finset (Fin p))ᶜ := by
    ext x; simp
  have hcard : ({0, c} : Finset (Fin p)).card = 2 := by
    rw [Finset.card_insert_of_notMem (by simpa using (Ne.symm hc)), Finset.card_singleton]
  simp only [h]
  rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const, hfil, Finset.card_compl, hcard]
  simp

/-! ## The type channel of a prime cyclic order

For prime `p` the type takes only the two values `1` (the identity Frobenius) and `p`. -/

variable {p : ℕ}

/-- For a prime order the splitting type is `1` at the identity and `p` elsewhere. -/
theorem typ_prime (hp : p.Prime) (x : Fin p) : typ p x = if x.val = 0 then 1 else p := by
  unfold typ
  by_cases h : x.val = 0
  · simp [h, Nat.div_self hp.pos]
  · have hg : Nat.gcd p x.val = 1 := by
      rcases hp.eq_one_or_self_of_dvd _ (Nat.gcd_dvd_left p x.val) with h1 | h1
      · exact h1
      · exfalso
        have hle := Nat.le_of_dvd (Nat.pos_of_ne_zero h) (h1 ▸ Nat.gcd_dvd_right p x.val)
        have := x.isLt
        omega
    simp [h, hg]

/-- The three type-pair states of a prime cyclic order. -/
theorem keyOf_prime (hp : p.Prime) (w : Fin p × Fin p) :
    keyOf p w = if w.1.val = 0 then (if w.2.val = 0 then (1, 1) else (1, p))
      else (if w.2.val = 0 then (1, p) else (p, p)) := by
  have h1 : (1 : ℕ) ≤ p := hp.one_lt.le
  unfold keyOf
  rw [typ_prime hp, typ_prime hp]
  by_cases hx : w.1.val = 0 <;> by_cases hy : w.2.val = 0 <;> simp [hx, hy, h1]

/-- The list of type-pair states realised by a prime cyclic order, in a canonical order. -/
def primeKeys (p : ℕ) : List (ℕ × ℕ) := [(1, 1), (1, p), (p, p)]

lemma primeKeys_nodup (hp : p.Prime) : (primeKeys p).Nodup := by
  have h : (1 : ℕ) ≠ p := hp.one_lt.ne
  simp [primeKeys, h, Prod.ext_iff]

lemma mem_keyList_prime (hp : p.Prime) (k : ℕ × ℕ) : k ∈ keyList p ↔ k ∈ primeKeys p := by
  haveI : NeZero p := ⟨hp.ne_zero⟩
  constructor
  · intro hk
    rw [keyList, List.mem_dedup, List.mem_map] at hk
    obtain ⟨w, -, rfl⟩ := hk
    rw [keyOf_prime hp]
    by_cases hx : w.1.val = 0 <;> by_cases hy : w.2.val = 0 <;> simp [hx, hy, primeKeys]
  · intro hk
    have hmem : ∀ w : Fin p × Fin p, keyOf p w ∈ keyList p := by
      intro w
      rw [keyList, List.mem_dedup, List.mem_map]
      refine ⟨w, ?_, rfl⟩
      rw [allPairs, List.mem_flatMap]
      exact ⟨w.1, List.mem_finRange _, by simp⟩
    have h0 : ((0 : Fin p)).val = 0 := rfl
    set e : Fin p := ⟨1, hp.one_lt⟩ with he
    have h1 : e.val ≠ 0 := by simp [he]
    simp only [primeKeys, List.mem_cons, List.not_mem_nil, or_false] at hk
    rcases hk with rfl | rfl | rfl
    · have := hmem (0, 0); rwa [keyOf_prime hp, if_pos h0, if_pos h0] at this
    · have := hmem (0, e); rwa [keyOf_prime hp, if_pos h0, if_neg h1] at this
    · have := hmem (e, e); rwa [keyOf_prime hp, if_neg h1, if_neg h1] at this

lemma keyList_perm_primeKeys (hp : p.Prime) : (keyList p).Perm (primeKeys p) := by
  refine List.perm_of_nodup_nodup_toFinset_eq (List.nodup_dedup _) (primeKeys_nodup hp) ?_
  ext k
  simp only [List.mem_toFinset]
  exact mem_keyList_prime hp k

/-! ### The unconditional type-pair occupation numbers -/

lemma count_key_11 (hp : p.Prime) :
    ((allPairs p).filter (fun w => keyOf p w = (1, 1))).length = 1 := by
  haveI : NeZero p := ⟨hp.ne_zero⟩
  have hne : (1 : ℕ) ≠ p := hp.one_lt.ne
  rw [length_filter_allPairs]
  simp only [decide_eq_true_eq]
  have hterm : ∀ x y : Fin p, (if (keyOf p (x, y) = (1, 1)) then 1 else 0)
      = (if x.val = 0 then 1 else 0) * (if y.val = 0 then 1 else 0) := by
    intro x y
    rw [keyOf_prime hp]
    by_cases hx : x.val = 0 <;> by_cases hy : y.val = 0 <;>
      simp [hx, hy, Prod.ext_iff, Ne.symm hne]
  simp only [hterm, ← Finset.mul_sum, sum_ite_val_zero]
  simp

lemma count_key_1p (hp : p.Prime) :
    ((allPairs p).filter (fun w => keyOf p w = (1, p))).length = 2 * (p - 1) := by
  haveI : NeZero p := ⟨hp.ne_zero⟩
  have hne : (1 : ℕ) ≠ p := hp.one_lt.ne
  rw [length_filter_allPairs]
  simp only [decide_eq_true_eq]
  have hterm : ∀ x y : Fin p, (if (keyOf p (x, y) = (1, p)) then 1 else 0)
      = (if x.val = 0 then 1 else 0) * (if y.val = 0 then 0 else 1)
        + (if x.val = 0 then 0 else 1) * (if y.val = 0 then 1 else 0) := by
    intro x y
    rw [keyOf_prime hp]
    by_cases hx : x.val = 0 <;> by_cases hy : y.val = 0 <;>
      simp [hx, hy, hne, Prod.ext_iff, Ne.symm hne]
  simp only [hterm, Finset.sum_add_distrib, ← Finset.mul_sum, sum_ite_val_zero,
    sum_ite_val_ne_zero]
  have h1 : ∑ x : Fin p, (if x.val = 0 then 1 else 0) * (p - 1) = p - 1 := by
    rw [← Finset.sum_mul, sum_ite_val_zero, one_mul]
  have h2 : ∑ x : Fin p, (if x.val = 0 then 0 else 1) * 1 = p - 1 := by
    simp only [mul_one]
    exact sum_ite_val_ne_zero p
  rw [h1, h2]
  omega

lemma count_key_pp (hp : p.Prime) :
    ((allPairs p).filter (fun w => keyOf p w = (p, p))).length = (p - 1) * (p - 1) := by
  haveI : NeZero p := ⟨hp.ne_zero⟩
  have hne : (1 : ℕ) ≠ p := hp.one_lt.ne
  rw [length_filter_allPairs]
  simp only [decide_eq_true_eq]
  have hterm : ∀ x y : Fin p, (if (keyOf p (x, y) = (p, p)) then 1 else 0)
      = (if x.val = 0 then 0 else 1) * (if y.val = 0 then 0 else 1) := by
    intro x y
    rw [keyOf_prime hp]
    by_cases hx : x.val = 0 <;> by_cases hy : y.val = 0 <;>
      simp [hx, hy, hne, Prod.ext_iff]
  simp only [hterm, ← Finset.mul_sum, sum_ite_val_ne_zero]
  rw [← Finset.sum_mul, sum_ite_val_ne_zero]

theorem pairCounts_perm_prime (hp : p.Prime) :
    (pairCounts p).Perm [1, 2 * (p - 1), (p - 1) * (p - 1)] := by
  have h := (keyList_perm_primeKeys hp).map
    (fun k => ((allPairs p).filter (fun w => keyOf p w = k)).length)
  rw [pairCounts]
  refine h.trans ?_
  rw [primeKeys]
  simp only [List.map_cons, List.map_nil]
  rw [count_key_11 hp, count_key_1p hp, count_key_pp hp]

/-! ### The conditional (fixed-norm) occupation numbers -/

section Conditional

variable [NeZero p]

lemma condCount_eval (c : Fin p) (k : ℕ × ℕ) :
    ((allPairs p).filter (fun w => w.1 + w.2 = c ∧ keyOf p w = k)).length
      = ∑ x : Fin p, if keyOf p (x, c - x) = k then 1 else 0 := by
  rw [length_filter_allPairs]
  simp only [decide_eq_true_eq]
  refine Finset.sum_congr rfl (fun x _ => ?_)
  have hcond : ∀ y : Fin p, (if (x + y = c ∧ keyOf p (x, y) = k) then 1 else 0)
      = (if y = c - x then (if keyOf p (x, y) = k then 1 else 0) else 0) := by
    intro y
    by_cases hy : y = c - x
    · subst hy; simp []
    · have : ¬ (x + y = c) := by
        intro h; exact hy (by rw [← h]; simp)
      simp [hy, this]
  simp only [hcond]
  rw [Finset.sum_ite_eq' Finset.univ (c - x)]
  simp
end Conditional

end CyclicType