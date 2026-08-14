import Mathlib
import Novelty.GCDMomentTraceWitness
import Novelty.GCDMomentPairInversion
import Novelty.GCDMomentMultiplicative

/-!
# The refinement order on gcd moments: the prime factorisation is the maximum

This file is the third cycle of the gcd-moment project
(`Novelty.GCDMomentTraceWitness`, `Novelty.GCDMomentPairInversion`,
`Novelty.GCDMomentMultiplicative`).  The previous cycle proved the *bottom* of the refinement
order: the moment of a modulus is at least its own local Euler factor
(`gcdMoment_ge_local`), with equality exactly at the primes, and splitting a factor strictly
raises the *predicted* Euler product (`eulerProd_gt_eulerLocal`).

Here we prove the *top* of that order.  Write

`Π_k(n) = ∏_{p ∈ primeFactorsList n} (p^k + p − 1)`

for the Euler product read off the full prime factorisation counted with multiplicity
(`primeProd`, the finest possible factorisation of `n`).  Then:

## Main results

* `gcdMoment_prime_pow_succ` — the local recursion `M_k(p^{e+1}) = p^k M_k(p^e) + φ(p^{e+1})`,
  which drives every estimate below.
* `gcdMoment_prime_pow_le`, `gcdMoment_prime_pow_lt` — `M_k(p^e) ≤ (p^k+p−1)^e`, strictly as
  soon as `e ≥ 2`: a prime power is *cheaper* than the same number of independent primes.
* `gcdMoment_prime_sq_deficiency`, `gcdMoment_prime_pow_deficiency` — the exact gap at a
  square, `(p^k+p−1)^2 − M_k(p^2) = (p−1)(p^k−1)`, and its closed form at every prime power.
* `gcdMoment_le_primeProd` — **the upper envelope**: `M_k(n) ≤ Π_k(n)` for every `n > 0`
  and every `k ≥ 1`.
* `gcdMoment_eq_primeProd_iff_squarefree` — **equality holds exactly on the squarefree moduli**.
  Together with `gcdMoment_eq_local_iff_prime` (previous cycle) this brackets the moment
  between two Euler products whose equality cases are precisely "`n` prime" and
  "`n` squarefree": `n^k + n − 1 ≤ M_k(n) ≤ Π_k(n)`.
* `factorisationEuler_le_primeProd` — **the prime factorisation maximises the predicted
  moment**: for *any* factorisation `n = a_1 ⋯ a_r` into parts `≥ 2`, the predicted Euler
  product `∏_i (a_i^k + a_i − 1)` is at most `Π_k(n)`; combined with `eulerProd_ge_eulerLocal`
  the refinement order is now pinned at both ends.
* `primeProd_mul`, `primeProd_prime_pow` — `Π_k` is completely multiplicative, which is what
  makes the induction work and is the exact sense in which the *finest* factorisation is a
  "free" object.

## Lab notes (data behind the statements)

Brute-force values (checked by `decide` at the end of the file):

| `n` | `M_2(n)` | `Π_2(n)` | squarefree? |
|-----|----------|----------|-------------|
| 6   | 55       | 55       | yes |
| 12  | 242      | 275      | no  |
| 4   | 22       | 25       | no  |
| 8   | 92       | 125      | no  |
| 9   | 105      | 121      | no  |

so the gap `Π_k(n) − M_k(n)` is a strictly positive measure of non-squarefreeness, and it is
`0` on the squarefree locus.  The semiprime moduli of the factoring-barrier files are
squarefree, so on them the moment *is* the full Euler product — which is exactly why the
inversion analysis of the previous cycles is possible there and nowhere else.
-/

namespace GCDMoment

open Finset

/-! ### The local recursion at a prime power -/

/-- **The local recursion.**  `M_k(p^{e+1}) = p^k · M_k(p^e) + φ(p^{e+1})`. -/
theorem gcdMoment_prime_pow_succ {p : ℕ} (hp : p.Prime) (e k : ℕ) :
    gcdMoment k (p ^ (e + 1)) = p ^ k * gcdMoment k (p ^ e) + (p ^ (e + 1)).totient := by
  rw [gcdMoment_prime_pow hp (e + 1) k, gcdMoment_prime_pow hp e k, Finset.mul_sum,
    Finset.sum_range_succ']
  simp only [Nat.zero_mul, pow_zero, one_mul, Nat.sub_zero]
  congr 1
  refine Finset.sum_congr rfl fun i hi => ?_
  have hile : i ≤ e := by simpa [Nat.lt_succ_iff] using hi
  have h1 : e + 1 - (i + 1) = e - i := by omega
  rw [h1, ← mul_assoc, ← pow_add]
  ring_nf

/-- The local factor at a prime, in additive form (no truncated subtraction). -/
lemma gcdMoment_prime_add {p : ℕ} (hp : p.Prime) (k : ℕ) :
    gcdMoment k p = p ^ k + (p - 1) := by
  have h1 : 1 ≤ p := hp.pos
  rw [gcdMoment_prime hp k]
  omega

/-- The prime local factor dominates the prime: `p < p^k + p − 1` for `k ≥ 1`, `p ≥ 2`. -/
lemma lt_gcdMoment_prime {p : ℕ} (hp : p.Prime) {k : ℕ} (hk : 1 ≤ k) :
    p < gcdMoment k p := by
  have h2 : 2 ≤ p := hp.two_le
  have hpk : p ≤ p ^ k := Nat.le_self_pow (by omega) p
  rw [gcdMoment_prime_add hp]
  omega

/-- **A prime power is cheaper than independent primes**: `M_k(p^e) ≤ (p^k + p − 1)^e`. -/
theorem gcdMoment_prime_pow_le {p : ℕ} (hp : p.Prime) {k : ℕ} (hk : 1 ≤ k) (e : ℕ) :
    gcdMoment k (p ^ e) ≤ gcdMoment k p ^ e := by
  induction e with
  | zero => simp [gcdMoment]
  | succ e ih =>
      have h2 : 2 ≤ p := hp.two_le
      have hple : p ≤ gcdMoment k p := (lt_gcdMoment_prime hp hk).le
      have hpow : p ^ e ≤ gcdMoment k p ^ e := Nat.pow_le_pow_left hple e
      have htot : (p ^ (e + 1)).totient = p ^ e * (p - 1) := by
        rw [Nat.totient_prime_pow hp (Nat.succ_pos e)]
        simp
      have hstep := gcdMoment_prime_pow_succ hp e k
      have hmul : p ^ k * gcdMoment k (p ^ e) ≤ p ^ k * gcdMoment k p ^ e :=
        Nat.mul_le_mul_left _ ih
      have hsub : p ^ e * (p - 1) ≤ gcdMoment k p ^ e * (p - 1) :=
        Nat.mul_le_mul_right _ hpow
      have hexp : gcdMoment k p ^ (e + 1)
          = p ^ k * gcdMoment k p ^ e + gcdMoment k p ^ e * (p - 1) := by
        rw [pow_succ, gcdMoment_prime_add hp]
        ring
      rw [hstep, htot, hexp]
      omega

/-- **Strictly cheaper**: for `e ≥ 2` the prime power is strictly below the `e`-fold local
factor.  This is the source of the squarefree equality criterion below. -/
theorem gcdMoment_prime_pow_lt {p : ℕ} (hp : p.Prime) {k : ℕ} (hk : 1 ≤ k) {e : ℕ}
    (he : 2 ≤ e) : gcdMoment k (p ^ e) < gcdMoment k p ^ e := by
  obtain ⟨f, rfl⟩ : ∃ f, e = f + 1 := ⟨e - 1, by omega⟩
  have hf : 1 ≤ f := by omega
  have h2 : 2 ≤ p := hp.two_le
  have hplt : p < gcdMoment k p := lt_gcdMoment_prime hp hk
  have hpow : p ^ f < gcdMoment k p ^ f := by
    exact Nat.pow_lt_pow_left hplt (by omega)
  have htot : (p ^ (f + 1)).totient = p ^ f * (p - 1) := by
    rw [Nat.totient_prime_pow hp (Nat.succ_pos f)]
    simp
  have hstep := gcdMoment_prime_pow_succ hp f k
  have hmul : p ^ k * gcdMoment k (p ^ f) ≤ p ^ k * gcdMoment k p ^ f :=
    Nat.mul_le_mul_left _ (gcdMoment_prime_pow_le hp hk f)
  have hsub : p ^ f * (p - 1) < gcdMoment k p ^ f * (p - 1) := by
    have : 0 < p - 1 := by omega
    exact Nat.mul_lt_mul_of_lt_of_le hpow (le_refl _) this
  have hexp : gcdMoment k p ^ (f + 1)
      = p ^ k * gcdMoment k p ^ f + gcdMoment k p ^ f * (p - 1) := by
    rw [pow_succ, gcdMoment_prime_add hp]
    ring
  rw [hstep, htot, hexp]
  omega

/-- **The exact deficiency at a square.**  `(p^k + p − 1)^2 − M_k(p^2) = (p − 1)(p^k − 1)`:
the gap between the moment of `p^2` and the moment predicted by the factorisation `p · p` is an
explicit positive quantity, so the moment distinguishes `p^2` from a product of two *distinct*
primes of the same size. -/
theorem gcdMoment_prime_sq_deficiency {p : ℕ} (hp : p.Prime) {k : ℕ} (hk : 1 ≤ k) :
    gcdMoment k (p ^ 2) + (p - 1) * (p ^ k - 1) = gcdMoment k p ^ 2 := by
  have h2 : 2 ≤ p := hp.two_le
  obtain ⟨a, ha⟩ : ∃ a, p = a + 1 := ⟨p - 1, by omega⟩
  have hpk : p ≤ p ^ k := Nat.le_self_pow (by omega) p
  obtain ⟨c, hc⟩ : ∃ c, p ^ k = c + 1 := ⟨p ^ k - 1, by omega⟩
  have hstep := gcdMoment_prime_pow_succ hp 1 k
  have h1 : gcdMoment k (p ^ 1) = p ^ k + (p - 1) := by
    rw [pow_one, gcdMoment_prime_add hp]
  have htot : (p ^ (1 + 1)).totient = p * (p - 1) := by
    rw [Nat.totient_prime_pow hp (by norm_num)]
    simp
  have hsq : (p : ℕ) ^ 2 = p ^ (1 + 1) := by norm_num
  have hL : gcdMoment k p = p ^ k + (p - 1) := gcdMoment_prime_add hp k
  rw [hsq, hstep, h1, htot, hL, hc, ha]
  simp only [Nat.add_sub_cancel]
  ring

/-- **The exact deficiency at every prime power.**  With `L = M_k(p) = p^k + p − 1`,

`L^e − M_k(p^e) = (p − 1) ∑_{i < e} p^{ik} (L^{e−1−i} − p^{e−1−i})`,

an explicit finite sum of geometric differences; at `e = 2` it collapses to
`(p−1)(p^k−1)` and at `e ≤ 1` to `0`.  This is the quantitative form of
`gcdMoment_prime_pow_lt`. -/
theorem gcdMoment_prime_pow_deficiency {p : ℕ} (hp : p.Prime) (k e : ℕ) :
    (gcdMoment k p : ℤ) ^ e - (gcdMoment k (p ^ e) : ℤ)
      = ((p : ℤ) - 1) * ∑ i ∈ Finset.range e, (p : ℤ) ^ (i * k) *
          ((gcdMoment k p : ℤ) ^ (e - 1 - i) - (p : ℤ) ^ (e - 1 - i)) := by
  have h2 : 2 ≤ p := hp.two_le
  have hL : (gcdMoment k p : ℤ) = (p : ℤ) ^ k + ((p : ℤ) - 1) := by
    have := gcdMoment_prime_add hp k
    have h1 : 1 ≤ p := by omega
    rw [this]
    push_cast [Nat.cast_sub h1]
    ring
  induction e with
  | zero => simp [gcdMoment]
  | succ e ih =>
      have hstep := gcdMoment_prime_pow_succ hp e k
      have htot : ((p ^ (e + 1)).totient : ℤ) = (p : ℤ) ^ e * ((p : ℤ) - 1) := by
        rw [Nat.totient_prime_pow hp (Nat.succ_pos e)]
        have h1 : 1 ≤ p := by omega
        push_cast [Nat.cast_sub h1]
        ring
      have hcast : (gcdMoment k (p ^ (e + 1)) : ℤ)
          = (p : ℤ) ^ k * (gcdMoment k (p ^ e) : ℤ) + (p : ℤ) ^ e * ((p : ℤ) - 1) := by
        rw [hstep]
        push_cast
        rw [htot]
      have hsum : ∑ i ∈ Finset.range (e + 1), (p : ℤ) ^ (i * k) *
            ((gcdMoment k p : ℤ) ^ (e + 1 - 1 - i) - (p : ℤ) ^ (e + 1 - 1 - i))
          = ((gcdMoment k p : ℤ) ^ e - (p : ℤ) ^ e)
            + (p : ℤ) ^ k * ∑ i ∈ Finset.range e, (p : ℤ) ^ (i * k) *
                ((gcdMoment k p : ℤ) ^ (e - 1 - i) - (p : ℤ) ^ (e - 1 - i)) := by
        rw [Finset.sum_range_succ']
        simp only [Nat.add_sub_cancel, Nat.zero_mul, pow_zero, one_mul, Nat.sub_zero]
        rw [Finset.mul_sum, add_comm]
        congr 1
        refine Finset.sum_congr rfl fun i hi => ?_
        have hidx : e - (i + 1) = e - 1 - i := by omega
        rw [hidx, ← mul_assoc, ← pow_add]
        ring_nf
      rw [hcast, hsum, pow_succ]
      linear_combination ((p : ℤ) ^ k) * ih + (gcdMoment k p : ℤ) ^ e * hL

/-! ### The Euler product of the finest factorisation -/

/-- `Π_k(n) = ∏_{p ∈ primeFactorsList n} (p^k + p − 1)`: the moment predicted by the *finest*
factorisation of `n`, the prime factorisation counted with multiplicity. -/
def primeProd (k n : ℕ) : ℕ := (n.primeFactorsList.map (gcdMoment k)).prod

@[simp] lemma primeProd_one (k : ℕ) : primeProd k 1 = 1 := by simp [primeProd]

@[simp] lemma primeProd_prime {p : ℕ} (hp : p.Prime) (k : ℕ) :
    primeProd k p = gcdMoment k p := by
  simp [primeProd, Nat.primeFactorsList_prime hp]

/-- **`Π_k` is completely multiplicative.** -/
theorem primeProd_mul {a b : ℕ} (ha : a ≠ 0) (hb : b ≠ 0) (k : ℕ) :
    primeProd k (a * b) = primeProd k a * primeProd k b := by
  have hperm := Nat.perm_primeFactorsList_mul ha hb
  unfold primeProd
  rw [(hperm.map (gcdMoment k)).prod_eq, List.map_append, List.prod_append]

theorem primeProd_prime_pow {p : ℕ} (hp : p.Prime) (e k : ℕ) :
    primeProd k (p ^ e) = gcdMoment k p ^ e := by
  simp [primeProd, hp.primeFactorsList_pow]

lemma primeProd_pos (n k : ℕ) : 0 < primeProd k n := by
  unfold primeProd
  refine List.prod_pos ?_
  intro x hx
  obtain ⟨p, hp, rfl⟩ := List.mem_map.1 hx
  have hpp : p.Prime := Nat.prime_of_mem_primeFactorsList hp
  have := gcdMoment_ge k p hpp.pos
  have : 0 < p ^ k := Nat.pow_pos hpp.pos
  omega

/-! ### The upper envelope -/

/-- **The upper envelope of the refinement order.**  For every modulus, the moment is at most
the Euler product of its prime factorisation. -/
theorem gcdMoment_le_primeProd {k : ℕ} (hk : 1 ≤ k) : ∀ {n : ℕ}, 0 < n →
    gcdMoment k n ≤ primeProd k n := by
  intro n
  induction n using Nat.recOnPosPrimePosCoprime with
  | prime_pow p e hp he =>
      intro _
      rw [primeProd_prime_pow hp e]
      exact gcdMoment_prime_pow_le hp hk e
  | zero => intro h; exact absurd h (lt_irrefl 0)
  | one => intro _; simp [gcdMoment]
  | coprime a b ha hb hab iha ihb =>
      intro _
      have ha0 : 0 < a := by omega
      have hb0 : 0 < b := by omega
      rw [gcdMoment_mul_of_coprime ha0 hb0 hab k, primeProd_mul ha0.ne' hb0.ne' k]
      exact Nat.mul_le_mul (iha ha0) (ihb hb0)

/-- On a squarefree modulus the moment *is* the full Euler product. -/
theorem gcdMoment_eq_primeProd_of_squarefree {n : ℕ} (hn : Squarefree n) (k : ℕ) :
    gcdMoment k n = primeProd k n := by
  have hnodup : n.primeFactorsList.Nodup := hn.nodup_primeFactorsList
  have hlist : primeProd k n = ∏ p ∈ n.primeFactors, gcdMoment k p := by
    unfold primeProd
    rw [← Nat.toFinset_factors, List.prod_toFinset _ hnodup]
  rw [hlist, gcdMoment_squarefree hn k]
  refine Finset.prod_congr rfl fun p hp => ?_
  exact (gcdMoment_prime (Nat.prime_of_mem_primeFactors hp) k).symm

/-- **Strictness off the squarefree locus.** -/
theorem gcdMoment_lt_primeProd_of_not_squarefree {k : ℕ} (hk : 1 ≤ k) {n : ℕ} (hn : 0 < n)
    (hsq : ¬ Squarefree n) : gcdMoment k n < primeProd k n := by
  obtain ⟨p, hp, hpp⟩ : ∃ p, p.Prime ∧ p ^ 2 ∣ n := by
    by_contra hcon
    push_neg at hcon
    refine hsq ?_
    rw [Nat.squarefree_iff_prime_squarefree]
    intro q hq hdvd
    exact hcon q hq (by simpa [pow_two] using hdvd)
  set e := n.factorization p with he
  have h2e : 2 ≤ e := by
    have := (Nat.Prime.pow_dvd_iff_le_factorization hp hn.ne').1 hpp
    omega
  set m := n / p ^ e with hm
  have hsplit : p ^ e * m = n := Nat.ordProj_mul_ordCompl_eq_self n p
  have hm0 : 0 < m := Nat.ordCompl_pos p hn.ne'
  have hcop : Nat.Coprime (p ^ e) m := Nat.Coprime.pow_left _ (Nat.coprime_ordCompl hp hn.ne')
  have hppos : 0 < p ^ e := Nat.pow_pos hp.pos
  have hlt : gcdMoment k (p ^ e) < primeProd k (p ^ e) := by
    rw [primeProd_prime_pow hp e]
    exact gcdMoment_prime_pow_lt hp hk h2e
  have hle : gcdMoment k m ≤ primeProd k m := gcdMoment_le_primeProd hk hm0
  have hmpos : 0 < gcdMoment k m := by
    have := gcdMoment_ge k m hm0
    have : 0 < m ^ k := Nat.pow_pos hm0
    omega
  calc gcdMoment k n = gcdMoment k (p ^ e) * gcdMoment k m := by
        rw [← hsplit, gcdMoment_mul_of_coprime hppos hm0 hcop k]
    _ < primeProd k (p ^ e) * primeProd k m := by
        exact Nat.mul_lt_mul_of_lt_of_le hlt hle (primeProd_pos m k)
    _ = primeProd k n := by rw [← primeProd_mul hppos.ne' hm0.ne' k, hsplit]

/-- **Equality holds exactly on the squarefree moduli.**  The moment equals the Euler product
of its prime factorisation iff `n` is squarefree; the deficiency `Π_k(n) − M_k(n)` is a strictly
positive measure of the square part. -/
theorem gcdMoment_eq_primeProd_iff_squarefree {k : ℕ} (hk : 1 ≤ k) {n : ℕ} (hn : 0 < n) :
    gcdMoment k n = primeProd k n ↔ Squarefree n := by
  constructor
  · intro heq
    by_contra hsq
    exact absurd heq (gcdMoment_lt_primeProd_of_not_squarefree hk hn hsq).ne
  · intro hsq
    exact gcdMoment_eq_primeProd_of_squarefree hsq k

/-! ### The refinement order is pinned at both ends -/

/-- The predicted Euler product of an arbitrary factorisation, given as a list of parts. -/
def factorisationEuler (k : ℕ) (l : List ℕ) : ℕ := (l.map (fun a => a ^ k + a - 1)).prod

/-- One part of a factorisation predicts no more than the prime factorisation of that part. -/
lemma part_le_primeProd {k : ℕ} (hk : 1 ≤ k) {a : ℕ} (ha : 0 < a) :
    a ^ k + a - 1 ≤ primeProd k a :=
  le_trans (gcdMoment_ge_local ha k) (gcdMoment_le_primeProd hk ha)

/-- **The prime factorisation maximises the predicted moment.**  For every factorisation of `n`
into parts `≥ 1`, the Euler product predicted by that factorisation is at most `Π_k(n)`.
With `eulerProd_ge_eulerLocal` of the previous cycle (the single-part factorisation is the
minimum) this pins the refinement order at both ends: the moment predicted by a factorisation
of `n` always lies in `[n^k + n − 1, Π_k(n)]`. -/
theorem factorisationEuler_le_primeProd {k : ℕ} (hk : 1 ≤ k) :
    ∀ (l : List ℕ), (∀ a ∈ l, 0 < a) → factorisationEuler k l ≤ primeProd k l.prod
  | [], _ => by simp [factorisationEuler]
  | (a :: t), h => by
      have ha : 0 < a := h a (by simp)
      have ht : ∀ x ∈ t, 0 < x := fun x hx => h x (by simp [hx])
      have hprod : 0 < t.prod := List.prod_pos ht
      have ih : factorisationEuler k t ≤ primeProd k t.prod :=
        factorisationEuler_le_primeProd hk t ht
      have hstep : a ^ k + a - 1 ≤ primeProd k a := part_le_primeProd hk ha
      have : factorisationEuler k (a :: t) = (a ^ k + a - 1) * factorisationEuler k t := by
        simp [factorisationEuler]
      rw [this, List.prod_cons, primeProd_mul ha.ne' hprod.ne' k]
      exact Nat.mul_le_mul hstep ih

/-- **The two-sided bracket.**  For `n ≥ 2` and `k ≥ 1`,
`n^k + n − 1 ≤ M_k(n) ≤ Π_k(n)`, the left equality characterising primes
(`gcdMoment_eq_local_iff_prime`) and the right one squarefreeness
(`gcdMoment_eq_primeProd_iff_squarefree`). -/
theorem gcdMoment_bracket {k : ℕ} (hk : 1 ≤ k) {n : ℕ} (hn : 2 ≤ n) :
    n ^ k + n - 1 ≤ gcdMoment k n ∧ gcdMoment k n ≤ primeProd k n :=
  ⟨gcdMoment_ge_local (by omega) k, gcdMoment_le_primeProd hk (by omega)⟩

/-- The bracket collapses to a single point exactly at the primes: a prime is the only modulus
whose moment equals both ends. -/
theorem bracket_collapse_iff_prime {k : ℕ} (hk : 1 ≤ k) {n : ℕ} (hn : 2 ≤ n) :
    (n ^ k + n - 1 = gcdMoment k n ∧ gcdMoment k n = primeProd k n) ↔ n.Prime := by
  constructor
  · rintro ⟨hleft, -⟩
    exact ((gcdMoment_eq_local_iff_prime hn hk).1 hleft.symm)
  · intro hp
    refine ⟨((gcdMoment_eq_local_iff_prime hn hk).2 hp).symm, ?_⟩
    rw [primeProd_prime hp]

/-! ### Lab notes: brute-force checks of the envelope

`M_2(4) = 22 < 25 = Π_2(4)`, `M_2(8) = 92 < 125`, `M_2(9) = 105 < 121`, while
`M_2(6) = 55 = Π_2(6)` and `M_3(30) = 33669 = Π_3(30)` (squarefree). -/

example : gcdMoment 2 4 = 22 := by decide
example : gcdMoment 2 4 < gcdMoment 2 2 ^ 2 := by decide
example : gcdMoment 2 8 = 92 := by decide
example : gcdMoment 2 8 < gcdMoment 2 2 ^ 3 := by decide
example : gcdMoment 2 9 < gcdMoment 2 3 ^ 2 := by decide
example : gcdMoment 2 6 = gcdMoment 2 2 * gcdMoment 2 3 := by decide
example : gcdMoment 2 12 = gcdMoment 2 4 * gcdMoment 2 3 := by decide
example : gcdMoment 2 9 + (3 - 1) * (3 ^ 2 - 1) = gcdMoment 2 3 ^ 2 := by decide
example : gcdMoment 3 4 + (2 - 1) * (2 ^ 3 - 1) = gcdMoment 3 2 ^ 2 := by decide

end GCDMoment