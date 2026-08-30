import Mathlib
import Shared.NumberTheory.IsSmooth

/-!
# Rigorous sparsity of the smooth pool, from the exponent-vector injection

Context (experiment 465, paper 130).  The quadratic sieve needs `B`-smooth values
`x^2 - N`; the whole subexponential run time is a trade-off between the *size* of
the factor base (`π(B)` relations must be collected) and the *rarity* of smooth
values.  Everything asymptotic about that trade-off is Dickman heuristics; this
file records the part that is an unconditional theorem, and which is the true
reason the smooth pool is thin at fixed `B`:

> a `B`-smooth number `n ≤ x` is *determined* by its exponent vector, whose
> entries are at most `log₂ x`, so there are at most `(log₂ x + 1) ^ π(B)` of
> them — polylogarithmic in `x` for fixed `B`.

This is the finite, unconditional skeleton underneath the `ρ(u)` model: it forces
`B → ∞` with `x`, which is what makes the sieve subexponential rather than
polynomial.  It is proved here by an explicit injection of the smooth pool into
the space of exponent vectors, using the catalog predicate `isSmooth` of
`Catalog.Shared.NumberTheory.IsSmooth`.

Main results:

* `mem_smoothPool_iff` — the decidable pool predicate agrees with the catalog
  predicate `isSmooth`.
* `factorization_le_log_two` — every exponent of a number `≤ x` is `≤ log₂ x`.
* `smoothPool_card_le` — `Ψ(x,B) ≤ (log₂ x + 1) ^ π(B)`.
* `smoothPool_card_le_pow_pi` — the same bound with the factor base written as
  the prime-counting function.
* `smoothPool_one` — the extreme case `B = 1`: only `n = 1` is `1`-smooth.
-/

namespace SmoothSparsity

open Finset

/-- The factor base: primes `p ≤ B`. -/
def factorBase (B : ℕ) : Finset ℕ := (Finset.range (B + 1)).filter Nat.Prime

/-- The smooth pool `Ψ(x,B)` as a finset: the `B`-smooth integers in `[1, x]`. -/
def smoothPool (B x : ℕ) : Finset ℕ :=
  (Finset.Icc 1 x).filter (fun n => ∀ p ∈ n.primeFactors, p ≤ B)

theorem mem_factorBase {B p : ℕ} : p ∈ factorBase B ↔ p.Prime ∧ p ≤ B := by
  simp [factorBase, and_comm]

/-- The decidable pool predicate is the catalog predicate `isSmooth`, on positive
integers. -/
theorem mem_smoothPool_iff {B x n : ℕ} (hn : n ≠ 0) :
    n ∈ smoothPool B x ↔ (1 ≤ n ∧ n ≤ x) ∧ isSmooth B n := by
  simp only [smoothPool, Finset.mem_filter, Finset.mem_Icc, isSmooth,
    Nat.mem_primeFactors]
  constructor
  · rintro ⟨h1, h2⟩
    exact ⟨h1, fun p hp hpd => h2 p ⟨hp, hpd, hn⟩⟩
  · rintro ⟨h1, h2⟩
    exact ⟨h1, fun p hp => h2 p hp.1 hp.2.1⟩

/-- Only the primes of the factor base occur in a pooled number. -/
theorem primeFactors_subset {B x n : ℕ} (hn : n ∈ smoothPool B x) :
    n.primeFactors ⊆ factorBase B := by
  intro p hp
  have h := (Finset.mem_filter.1 hn).2 p hp
  exact mem_factorBase.2 ⟨Nat.prime_of_mem_primeFactors hp, h⟩

/-- **Every exponent is small.**  If `0 < n ≤ x` then each exponent in the prime
factorisation of `n` is at most `log₂ x`. -/
theorem factorization_le_log_two {x n p : ℕ} (hn : n ≠ 0) (hx : n ≤ x) :
    n.factorization p ≤ Nat.log 2 x := by
  rcases eq_or_ne (n.factorization p) 0 with h | h
  · simp [h]
  have hmem : p ∈ n.primeFactors := by
    rw [← Nat.support_factorization]
    exact Finsupp.mem_support_iff.2 h
  have hp : p.Prime := Nat.prime_of_mem_primeFactors hmem
  have hx0 : x ≠ 0 := by rintro rfl; omega
  have hdvd : p ^ n.factorization p ∣ n := Nat.ordProj_dvd n p
  have hple : p ^ n.factorization p ≤ n := Nat.le_of_dvd (Nat.pos_of_ne_zero hn) hdvd
  have h2 : 2 ^ n.factorization p ≤ p ^ n.factorization p :=
    Nat.pow_le_pow_left hp.two_le _
  exact (Nat.le_log_iff_pow_le (by norm_num) hx0).2 (le_trans h2 (le_trans hple hx))
/-- **Sparsity of the smooth pool.**  There are at most `(log₂ x + 1) ^ π(B)`
`B`-smooth numbers in `[1, x]`: for a fixed factor base the pool grows only
polylogarithmically in `x`. -/
theorem smoothPool_card_le (B x : ℕ) :
    (smoothPool B x).card ≤ (Nat.log 2 x + 1) ^ (factorBase B).card := by
  classical
  set k := Nat.log 2 x with hk
  -- the exponent-vector map
  set f : ℕ → (factorBase B → Fin (k + 1)) :=
    fun n p => ⟨min (n.factorization p) k, by omega⟩ with hf
  have hcard : Fintype.card (factorBase B → Fin (k + 1)) = (k + 1) ^ (factorBase B).card := by
    simp
  have hinj : Set.InjOn f (smoothPool B x) := by
    intro a ha b hb hab
    simp only [Finset.mem_coe, smoothPool, Finset.mem_filter, Finset.mem_Icc] at ha hb
    have ha0 : a ≠ 0 := by omega
    have hb0 : b ≠ 0 := by omega
    have hfa : ∀ p, a.factorization p = b.factorization p := by
      intro p
      by_cases hp : p ∈ factorBase B
      · have := congrFun hab ⟨p, hp⟩
        simp only [hf, Fin.mk.injEq] at this
        have h1 : a.factorization p ≤ k :=
          factorization_le_log_two ha0 ha.1.2
        have h2 : b.factorization p ≤ k :=
          factorization_le_log_two hb0 hb.1.2
        omega
      · have hA : a.factorization p = 0 := by
          by_contra hcon
          have hmem : p ∈ a.primeFactors := by
            rw [← Nat.support_factorization]
            exact Finsupp.mem_support_iff.2 hcon
          exact hp (mem_factorBase.2
            ⟨Nat.prime_of_mem_primeFactors hmem, ha.2 p hmem⟩)
        have hB : b.factorization p = 0 := by
          by_contra hcon
          have hmem : p ∈ b.primeFactors := by
            rw [← Nat.support_factorization]
            exact Finsupp.mem_support_iff.2 hcon
          exact hp (mem_factorBase.2
            ⟨Nat.prime_of_mem_primeFactors hmem, hb.2 p hmem⟩)
        rw [hA, hB]
    have : a.factorization = b.factorization := Finsupp.ext hfa
    exact Nat.factorization_inj (Set.mem_setOf_eq ▸ ha0) (Set.mem_setOf_eq ▸ hb0) this
  calc (smoothPool B x).card
      ≤ (Finset.univ : Finset (factorBase B → Fin (k + 1))).card :=
        Finset.card_le_card_of_injOn f (fun n _ => Finset.mem_univ _) hinj
    _ = (k + 1) ^ (factorBase B).card := by rw [← hcard]; rfl

/-- The same bound with the factor base size written as `π(B)`, the number of
primes up to `B`. -/
theorem smoothPool_card_le_pow_pi (B x : ℕ) :
    (smoothPool B x).card ≤ (Nat.log 2 x + 1) ^ ((Finset.range (B + 1)).filter Nat.Prime).card :=
  smoothPool_card_le B x

/-- The extreme case: with an empty factor base (`B = 1`) the pool is `{1}`. -/
theorem smoothPool_one (x : ℕ) (hx : 1 ≤ x) : smoothPool 1 x = {1} := by
  ext n
  simp only [smoothPool, Finset.mem_filter, Finset.mem_Icc, Finset.mem_singleton]
  constructor
  · rintro ⟨⟨h1, h2⟩, h3⟩
    by_contra hne
    have hn : 2 ≤ n := by omega
    obtain ⟨p, hp, hpd⟩ := Nat.exists_prime_and_dvd (n := n) (by omega)
    have hmem : p ∈ n.primeFactors := Nat.mem_primeFactors.2 ⟨hp, hpd, by omega⟩
    have := h3 p hmem
    have := hp.two_le
    omega
  · rintro rfl
    simp [hx]

end SmoothSparsity