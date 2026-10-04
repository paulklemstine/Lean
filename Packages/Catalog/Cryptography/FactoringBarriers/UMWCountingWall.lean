import Mathlib

/-!
# The UMW divisor-cover counting wall

Machine-checked companion to the round-96 note. **No `sorry`, no `axiom`.**

Umans–Wang (arXiv:2511.10851) reduce deterministic integer factoring below
Harvey's `N^(1/5)` to their `(α,β)`-Divisor Conjecture: one needs sets `S, T`
with `|S|,|T| <= n^β`, elements `<= exp(n^α)`, such that every `i <= n` divides
some difference `s - t`.  Their differences form a list `A`; the **counting
wall** below is the exact arithmetic any such cover must clear: every prime
`<= n` must divide some member of `A`, hence the primorial of `n` divides the
product `A.prod`.  Combined with "every member `<= M`" and "`|A| = m`" this
gives `primorial n <= M^m`, which asymptotically forces `α + 2β >= 1`.

These statements are elementary and unconditional. They are the wall; they are
NOT a construction, and they do NOT decide the conjecture.
-/

namespace UMWTest

noncomputable def primesUpTo (n : ℕ) : Finset ℕ := (Finset.range (n + 1)).filter Nat.Prime
noncomputable def primorial (n : ℕ) : ℕ := (primesUpTo n).prod id

/-- `A` covers the primes up to `n` if every prime `≤ n` divides some member. -/
def PrimeCover (n : ℕ) (A : List ℕ) : Prop :=
  ∀ p, Nat.Prime p → p ≤ n → ∃ a ∈ A, p ∣ a

theorem dvd_mul_right' (p a c : ℕ) (h : p ∣ a) : p ∣ a * c := by
  rcases h with ⟨k, rfl⟩; exact ⟨k * c, by ring⟩
theorem mul_dvd_mul_left' (p b c : ℕ) (h : p ∣ c) : p ∣ b * c := by
  rcases h with ⟨k, rfl⟩; exact ⟨b * k, by ring⟩

theorem prime_dvd_prod (p : ℕ) (A : List ℕ) (a : ℕ) (ha : a ∈ A) (hpa : p ∣ a) :
    p ∣ A.prod := by
  induction A with
  | nil => simp at ha
  | cons b B ih =>
    simp only [List.mem_cons] at ha
    rcases ha with hba | ha
    · subst hba; exact dvd_mul_right' p a (List.prod B) hpa
    · exact mul_dvd_mul_left' p b (List.prod B) (ih ha)

theorem pairwiseCoprime_prod_dvd {S : Finset ℕ} {c : ℕ}
    (hc : ∀ p ∈ S, p ∣ c)
    (hcop : ∀ p ∈ S, ∀ q ∈ S, p ≠ q → Nat.Coprime p q) : S.prod id ∣ c := by
  classical
  induction S using Finset.induction with
  | empty => exact Nat.one_dvd c
  | @insert a s ha ih =>
    rw [Finset.prod_insert ha]
    have hstep : Nat.Coprime a (s.prod id) := by
      refine Nat.Coprime.prod_right (fun q hq => hcop a (Finset.mem_insert_self a s)
        q (Finset.mem_insert_of_mem hq) (by by_contra h; exact ha (h ▸ hq)))
    have hsub : ∀ q ∈ s, q ∣ c := fun q hq => hc q (Finset.mem_insert_of_mem hq)
    have hcopS : ∀ p ∈ s, ∀ q ∈ s, p ≠ q → Nat.Coprime p q :=
      fun p hp q hq hne => hcop p (Finset.mem_insert_of_mem hp) q (Finset.mem_insert_of_mem hq) hne
    have hsC : s.prod id ∣ c := ih hsub hcopS
    rcases hsC with ⟨t, ht⟩
    have haC : a ∣ c := hc a (Finset.mem_insert_self a s)
    have hat : a ∣ t := hstep.dvd_of_dvd_mul_left (by rw [← ht]; exact haC)
    rcases hat with ⟨v, hv⟩
    refine ⟨v, ?_⟩
    calc c = s.prod id * t := ht
      _ = s.prod id * (a * v) := by rw [hv]
      _ = (a * s.prod id) * v := by ring

theorem primes_pairwise_coprime (n : ℕ) (p q : ℕ)
    (hp : p ∈ primesUpTo n) (hq : q ∈ primesUpTo n) (hne : p ≠ q) : Nat.Coprime p q :=
  (Nat.coprime_primes (Finset.mem_filter.mp hp).2 (Finset.mem_filter.mp hq).2).mpr hne

/-- **THE COUNTING WALL.** If every prime up to `n` divides some member of a list
of positive integers `A`, then the primorial of `n` divides `A.prod`. -/
theorem primorial_le_prod (n : ℕ) (A : List ℕ) (hA : ∀ a ∈ A, 0 < a)
    (hcover : PrimeCover n A) : primorial n ≤ A.prod := by
  classical
  have key : ∀ p ∈ primesUpTo n, p ∣ A.prod := by
    intro p hp
    have hp' : p ≤ n := by
      have hmem : p ∈ Finset.range (n + 1) := (Finset.mem_filter.mp hp).1
      simp only [Finset.mem_range] at hmem
      omega
    have hpPrime : Nat.Prime p := (Finset.mem_filter.mp hp).2
    obtain ⟨a, haA, hpa⟩ := hcover p hpPrime hp'
    exact prime_dvd_prod p A a haA hpa
  have hdiv : primorial n ∣ A.prod :=
    pairwiseCoprime_prod_dvd key (fun p hp q hq hne => primes_pairwise_coprime n p q hp hq hne)
  exact Nat.le_of_dvd (List.prod_pos hA) hdiv

theorem prod_le_pow_of_le (A : List ℕ) (M : ℕ) (h : ∀ a ∈ A, a ≤ M) : A.prod ≤ M ^ A.length := by
  induction A with
  | nil => simp
  | cons b B ih =>
    have hb0 : b ≤ M := h b (List.mem_cons_self)
    have hB : ∀ a ∈ B, a ≤ M := fun a ha => h a (List.mem_cons_of_mem b ha)
    have ihb : B.prod ≤ M ^ B.length := ih hB
    have hm := Nat.mul_le_mul hb0 ihb
    have hm' : b * B.prod ≤ M ^ B.length * M := by
      calc b * B.prod ≤ M * M ^ B.length := hm
        _ = M ^ B.length * M := Nat.mul_comm _ _
    simpa only [List.prod_cons, List.length_cons, Nat.pow_succ] using hm'

/-- **The explicit wall.** If a list `A` of `m` positive integers, each `<= M`,
covers every prime up to `n`, then `primorial n <= M^m`. -/
theorem primorial_le_pow (n m M : ℕ) (A : List ℕ)
    (hlen : A.length = m) (hA : ∀ a ∈ A, 0 < a) (hA_le : ∀ a ∈ A, a ≤ M)
    (hcover : PrimeCover n A) : primorial n ≤ M ^ m := by
  have h1 : primorial n ≤ A.prod := primorial_le_prod n A hA hcover
  have h2 : A.prod ≤ M ^ A.length := prod_le_pow_of_le A M hA_le
  rw [hlen] at h2
  exact h1.trans h2

/-- Sanity: the trivial one-set cover `A = [n!]` clears the wall for every `n`.
For `n ≥ 1`, every prime `≤ n` divides `n!`. -/
example (n : ℕ) (_hn : 1 ≤ n) (h : ∀ p, Nat.Prime p → p ≤ n → p ∣ n.factorial) :
    primorial n ≤ n.factorial := by
  have hpos : 0 < n.factorial := Nat.factorial_pos n
  refine Nat.le_of_dvd hpos ?_
  refine pairwiseCoprime_prod_dvd ?_ (fun p hp q hq hne => primes_pairwise_coprime n p q hp hq hne)
  intro p hp
  have hp' : p ≤ n := by
    have hmem : p ∈ Finset.range (n + 1) := (Finset.mem_filter.mp hp).1
    simp only [Finset.mem_range] at hmem
    omega
  exact h p (Finset.mem_filter.mp hp).2 hp'

end UMWTest
