import Mathlib
import Combinatorics.PowerSumFactorReveal

/-!
# A degree barrier for aggregated-sum factoring

The power-sum reveal of `Combinatorics.PowerSumFactorReveal` first produces a factor of
`N = pq` at the exponent `k = min (p-1, q-1)`.  Is that an artifact of using *monomials*
`a ↦ a^k` as the aggregation weights?  This file shows that it is not: **no** integer
polynomial of degree below `min (p-1, q-1)` can reveal anything.

For `f ∈ ℤ[X]` put `S_f(N) = ∑_{a=1}^{N} f(a)` (`polySum`).  The key local computation
(`cast_polySum`, a strict generalisation of `cast_powerSum`) is

`S_f(N) ≡ (N/p) · ∑_{x ∈ ZMod p} f̄(x)  (mod p)`  for every prime `p ∣ N`,

and over `ZMod p` the total sum of a polynomial of degree `< p - 1` vanishes
(`sum_eval_eq_zero_of_natDegree_lt`).  Hence:

* `polySum_dvd_of_natDegree_lt` — `p ∣ S_f(N)` whenever `p ∣ N` and `deg f < p - 1`;
* `polySum_degree_barrier` — for a semiprime `N = pq` and `deg f < min (p-1, q-1)` the whole
  modulus divides `S_f(N)`, so `gcd (S_f(N), N) = N`: **every** low-degree aggregation
  returns no information whatsoever;
* `polySum_barrier_sharp` — the bound is sharp: at degree exactly `p - 1` the monomial
  `X^{p-1}` does reveal a factor.

This turns the informal complexity remark ("first hit at `k* = min(p-1,q-1) ≈ √N`") into a
theorem about an entire family of algorithms rather than one particular weighting.
-/

namespace PowerSumReveal

open Finset Polynomial

/-- `S_f(N) = ∑_{a=1}^{N} f(a)` for an integer polynomial `f`. -/
def polySum (f : Polynomial ℤ) (N : ℕ) : ℤ := ∑ a ∈ Finset.Icc 1 N, f.eval (a : ℤ)

/-- The monomial `X ^ k` recovers the power sum. -/
theorem polySum_X_pow (N k : ℕ) : polySum (X ^ k) N = (powerSum N k : ℤ) := by
  simp [polySum, powerSum]

/-- Reduction of an integer polynomial evaluation modulo `p`. -/
theorem cast_eval (p : ℕ) (f : Polynomial ℤ) (a : ℤ) :
    ((f.eval a : ℤ) : ZMod p) = (f.map (Int.castRingHom (ZMod p))).eval ((a : ZMod p)) := by
  rw [Polynomial.eval_map]
  exact (Polynomial.eval₂_at_apply (Int.castRingHom (ZMod p)) a).symm

/-- **Local formula for a general aggregation polynomial.**  For a prime `p ∣ N`,
`S_f(N) ≡ (N/p) · ∑_{x ∈ ZMod p} f̄(x)` modulo `p`. -/
theorem cast_polySum (N p : ℕ) [Fact p.Prime] (hpN : p ∣ N) (f : Polynomial ℤ) :
    ((polySum f N : ℤ) : ZMod p)
      = (N / p) • ∑ x : ZMod p, (f.map (Int.castRingHom (ZMod p))).eval x := by
  set g : ZMod p → ZMod p := fun x => (f.map (Int.castRingHom (ZMod p))).eval x with hg
  have hcast : ((polySum f N : ℤ) : ZMod p) = ∑ a ∈ Finset.Icc 1 N, g ((a : ℕ) : ZMod p) := by
    rw [polySum]
    push_cast
    refine Finset.sum_congr rfl ?_
    intro a _
    rw [cast_eval p f (a : ℤ)]
    simp [hg]
  have hins : Finset.range (N + 1) = insert 0 (Finset.Icc 1 N) := by
    ext x; simp [Finset.mem_Icc]; omega
  have h1 : ∑ a ∈ Finset.range (N + 1), g ((a : ℕ) : ZMod p)
      = g 0 + ∑ a ∈ Finset.Icc 1 N, g ((a : ℕ) : ZMod p) := by
    rw [hins, Finset.sum_insert (by simp)]
    simp
  have hN0 : ((N : ℕ) : ZMod p) = 0 := (ZMod.natCast_eq_zero_iff N p).mpr hpN
  have h2 : ∑ a ∈ Finset.range (N + 1), g ((a : ℕ) : ZMod p)
      = ∑ a ∈ Finset.range N, g ((a : ℕ) : ZMod p) + g 0 := by
    rw [Finset.sum_range_succ, hN0]
  have hN : N = (N / p) * p := (Nat.div_mul_cancel hpN).symm
  have h3 : ∑ a ∈ Finset.Icc 1 N, g ((a : ℕ) : ZMod p)
      = ∑ a ∈ Finset.range N, g ((a : ℕ) : ZMod p) := by
    have := h1.symm.trans h2
    exact add_left_cancel (by rw [this]; ring)
  rw [hcast, h3, show (Finset.range N) = Finset.range ((N / p) * p) by rw [← hN],
    sum_range_mul_cast p g (N / p)]

/-- **Vanishing of low-degree total sums.**  Over `ZMod p` the sum of a polynomial of degree
`< p - 1` over all residues vanishes. -/
theorem sum_eval_eq_zero_of_natDegree_lt (p : ℕ) [Fact p.Prime] (F : Polynomial (ZMod p))
    (hdeg : F.natDegree < p - 1) : ∑ x : ZMod p, F.eval x = 0 := by
  have hstep : ∀ x : ZMod p, F.eval x = ∑ i ∈ range (F.natDegree + 1), F.coeff i * x ^ i :=
    fun x => Polynomial.eval_eq_sum_range x
  calc ∑ x : ZMod p, F.eval x
      = ∑ x : ZMod p, ∑ i ∈ range (F.natDegree + 1), F.coeff i * x ^ i := by
        exact Finset.sum_congr rfl (fun x _ => hstep x)
    _ = ∑ i ∈ range (F.natDegree + 1), F.coeff i * ∑ x : ZMod p, x ^ i := by
        rw [Finset.sum_comm]
        exact Finset.sum_congr rfl (fun i _ => (Finset.mul_sum _ _ _).symm)
    _ = 0 := by
        refine Finset.sum_eq_zero ?_
        intro i hi
        have hilt : i < Fintype.card (ZMod p) - 1 := by
          rw [ZMod.card p]
          have := Finset.mem_range.mp hi
          omega
        rw [FiniteField.sum_pow_lt_card_sub_one (ZMod p) i hilt, mul_zero]

/-- **Degree barrier, local form.**  If `p ∣ N` is prime and `deg f < p - 1`, then
`p ∣ ∑_{a=1}^{N} f(a)`, whatever the coefficients of `f` are. -/
theorem polySum_dvd_of_natDegree_lt {N p : ℕ} (hp : p.Prime) (hpN : p ∣ N) {f : Polynomial ℤ}
    (hdeg : f.natDegree < p - 1) : (p : ℤ) ∣ polySum f N := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hmap : (f.map (Int.castRingHom (ZMod p))).natDegree < p - 1 :=
    lt_of_le_of_lt Polynomial.natDegree_map_le hdeg
  have hzero : ∑ x : ZMod p, (f.map (Int.castRingHom (ZMod p))).eval x = 0 :=
    sum_eval_eq_zero_of_natDegree_lt p _ hmap
  have : ((polySum f N : ℤ) : ZMod p) = 0 := by
    rw [cast_polySum N p hpN f, hzero, smul_zero]
  exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ p).mp this

/-- **Degree barrier for semiprimes.**  For `N = p q` with distinct primes and any integer
polynomial of degree below `min (p-1, q-1)`, the aggregated sum `∑_{a=1}^N f(a)` is divisible
by `N`: the gcd is `N` and no factor is revealed.  In particular no aggregation of degree
below `min (p-1, q-1) ≈ √N` can factor `N`. -/
theorem polySum_degree_barrier {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    {f : Polynomial ℤ} (hdp : f.natDegree < p - 1) (hdq : f.natDegree < q - 1) :
    ((p * q : ℕ) : ℤ) ∣ polySum f (p * q) := by
  have h1 : (p : ℤ) ∣ polySum f (p * q) :=
    polySum_dvd_of_natDegree_lt hp ⟨q, rfl⟩ hdp
  have h2 : (q : ℤ) ∣ polySum f (p * q) :=
    polySum_dvd_of_natDegree_lt hq ⟨p, mul_comm p q⟩ hdq
  have hcop : IsCoprime (p : ℤ) (q : ℤ) := by
    rw [Int.isCoprime_iff_gcd_eq_one]
    simpa using (Nat.coprime_primes hp hq).mpr hpq
  push_cast
  exact hcop.mul_dvd h1 h2

/-- **Sharpness of the barrier.**  At degree exactly `p - 1` the barrier breaks: for `p < q`
the monomial `X^{p-1}` yields the proper factor `q`. -/
theorem polySum_barrier_sharp {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hlt : p < q) :
    (X ^ (p - 1) : Polynomial ℤ).natDegree = p - 1 ∧
      Nat.gcd (polySum (X ^ (p - 1)) (p * q)).toNat (p * q) = q := by
  have hpq : p ≠ q := by omega
  have hne : ¬ (q - 1) ∣ (p - 1) := by
    intro h
    have hp2 := hp.two_le
    have := Nat.le_of_dvd (by omega) h
    omega
  refine ⟨Polynomial.natDegree_X_pow _, ?_⟩
  rw [polySum_X_pow]
  simpa using powerSum_reveal hp hq hpq hne

/-- **Interpretation.**  Combining the two previous results: for `p < q` the *exact* degree
threshold at which integer-polynomial aggregation starts to reveal a factor of `N = pq`
is `p - 1 = min (p-1, q-1)`. -/
theorem degree_threshold {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hlt : p < q) :
    (∀ f : Polynomial ℤ, f.natDegree < p - 1 → ((p * q : ℕ) : ℤ) ∣ polySum f (p * q)) ∧
      Nat.gcd (polySum (X ^ (p - 1)) (p * q)).toNat (p * q) = q := by
  have hpq : p ≠ q := by omega
  refine ⟨fun f hf => polySum_degree_barrier hp hq hpq hf (by omega), ?_⟩
  exact (polySum_barrier_sharp hp hq hlt).2

end PowerSumReveal