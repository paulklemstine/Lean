/-
  # Evolutionary Paths in Arithmetic: the Multiplicative Quotient System

  This file instantiates the abstract theory of `Shared.EvolutionaryPathCore`
  in the multiplicative monoid of natural numbers, where

  * a **quotient step** `n --p--> m` is division by a prime: `p.Prime`, `0 < m`,
    `n = p * m`;
  * an **evolutionary path** is a chain of such divisions;
  * the terminal objects are exactly `0` and `1`.

  The abstract Jordan–Hölder / decomposition theorem then *specialises to the
  fundamental theorem of arithmetic*: `natDecomp_prod`, `prime_list_multiset_unique`.
  This is a genuine derivation — the uniqueness of factorisation is obtained
  from the abstract exchange (butterfly) axiom, whose verification here is the
  elementary "Euclid" step `q ∣ p * m → q ∣ m` for distinct primes.

  Highlights:
  * `natSystem`                 : the quotient system on `ℕ`.
  * `natSystem_terminal_iff`    : terminal ↔ `n ≤ 1`.
  * `natDecomp_prod`            : `decomp natSystem (L.prod) = ↑L` for a list of primes.
  * `prime_list_multiset_unique`: unique factorisation, derived abstractly.
  * `natDecomp_eq_primeFactorsList`, `natHeight_eq_card_factors` : the invariant
    is `Ω`, the number of prime factors with multiplicity.
  * `natDecomp_count_eq_factorization` : the label-count invariant is the
    `p`-adic valuation.
-/
import Shared.EvolutionaryPathCore

namespace Shared.EvolutionaryPath

open Nat

/-- A multiplicative quotient step `n --p--> m`: division by the prime `p`. -/
def natStep (n p m : ℕ) : Prop := p.Prime ∧ 0 < m ∧ n = p * m

theorem natStep_rank_lt {n p m : ℕ} (h : natStep n p m) :
    (primeFactorsList m).length < (primeFactorsList n).length := by
  obtain ⟨hp, hm, rfl⟩ := h
  have hperm := Nat.perm_primeFactorsList_mul (a := p) (b := m) hp.ne_zero hm.ne'
  have hlen := hperm.length_eq
  rw [List.length_append, Nat.primeFactorsList_prime hp] at hlen
  simp only [List.length_singleton] at hlen
  omega

theorem natStep_label_unique {n p₁ p₂ m : ℕ} (h₁ : natStep n p₁ m) (h₂ : natStep n p₂ m) :
    p₁ = p₂ := by
  obtain ⟨-, hm, e₁⟩ := h₁
  obtain ⟨-, -, e₂⟩ := h₂
  exact Nat.eq_of_mul_eq_mul_right hm (e₁ ▸ e₂ ▸ rfl)

/-- The **exchange (butterfly) axiom** for arithmetic: two different prime
quotients of `n` complete to a diamond with the labels swapped.  This is
Euclid's lemma in disguise. -/
theorem natStep_exchange {n p₁ m₁ p₂ m₂ : ℕ} (h₁ : natStep n p₁ m₁) (h₂ : natStep n p₂ m₂)
    (hne : m₁ ≠ m₂) : ∃ z, natStep m₁ p₂ z ∧ natStep m₂ p₁ z := by
  obtain ⟨hp₁, hm₁, e₁⟩ := h₁
  obtain ⟨hp₂, hm₂, e₂⟩ := h₂
  have hpq : p₁ ≠ p₂ := by
    rintro rfl
    exact hne (Nat.eq_of_mul_eq_mul_left hp₁.pos (e₁ ▸ e₂))
  have hdvd : p₂ ∣ m₁ := by
    have hd : p₂ ∣ p₁ * m₁ := by rw [← e₁, e₂]; exact Dvd.intro _ rfl
    rcases (Nat.Prime.dvd_mul hp₂).1 hd with h | h
    · exact absurd ((Nat.prime_dvd_prime_iff_eq hp₂ hp₁).1 h) (Ne.symm hpq)
    · exact h
  obtain ⟨z, hz⟩ := hdvd
  have hz0 : 0 < z := by
    rcases Nat.eq_zero_or_pos z with rfl | h
    · simp [hz] at hm₁
    · exact h
  refine ⟨z, ⟨hp₂, hz0, hz⟩, ⟨hp₁, hz0, ?_⟩⟩
  refine Nat.eq_of_mul_eq_mul_left hp₂.pos ?_
  calc p₂ * m₂ = n := e₂.symm
    _ = p₁ * m₁ := e₁
    _ = p₁ * (p₂ * z) := by rw [hz]
    _ = p₂ * (p₁ * z) := by ring

/-- The multiplicative quotient system on `ℕ`: steps divide out one prime, the
rank is the number of prime factors counted with multiplicity. -/
def natSystem : QuotientSystem ℕ ℕ where
  step := natStep
  rank n := (primeFactorsList n).length
  rank_lt := natStep_rank_lt
  label_unique := natStep_label_unique
  exchange := natStep_exchange

@[simp] theorem natSystem_step {n p m : ℕ} : natSystem.step n p m ↔ natStep n p m := Iff.rfl

theorem terminal_one : Terminal natSystem 1 := by
  rintro p m ⟨hp, -, e⟩
  exact hp.ne_one (Nat.dvd_one.1 ⟨m, e⟩)

theorem terminal_zero : Terminal natSystem 0 := by
  rintro p m ⟨hp, hm, e⟩
  exact Nat.mul_ne_zero hp.ne_zero hm.ne' e.symm

/-- Terminal objects of the arithmetic quotient system are exactly `0` and `1`:
the "simple" objects are the units and the zero object. -/
theorem natSystem_terminal_iff (n : ℕ) : Terminal natSystem n ↔ n ≤ 1 := by
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    have h2 : 2 ≤ n := hc
    have hp : (minFac n).Prime := Nat.minFac_prime (by omega)
    have hd : minFac n ∣ n := Nat.minFac_dvd n
    obtain ⟨m, hm⟩ := hd
    have hm0 : 0 < m := by
      rcases Nat.eq_zero_or_pos m with rfl | h' <;> omega
    exact h (minFac n) m ⟨hp, hm0, hm⟩
  · intro h
    interval_cases n
    · exact terminal_zero
    · exact terminal_one

/-- Every list of primes gives an evolutionary path from its product down to `1`. -/
theorem evolPath_of_primeList : ∀ (L : List ℕ), (∀ p ∈ L, p.Prime) →
    EvolPath natSystem L.prod 1 L := by
  intro L
  induction L with
  | nil => intro _; simpa using EvolPath.nil (Q := natSystem) 1
  | cons p L ih =>
      intro hL
      have hp : p.Prime := hL p (List.mem_cons_self ..)
      have hL' : ∀ q ∈ L, q.Prime := fun q hq => hL q (List.mem_cons_of_mem _ hq)
      have hpos : 0 < L.prod := by
        refine List.prod_pos ?_
        intro q hq
        exact (hL' q hq).pos
      refine EvolPath.cons (l := p) (y := L.prod) ⟨hp, hpos, by simp⟩ (ih hL')
  
/-- **Fundamental theorem of arithmetic, abstract form.**  The decomposition
invariant of a product of primes is the multiset of those primes. -/
theorem natDecomp_prod (L : List ℕ) (hL : ∀ p ∈ L, p.Prime) :
    decomp natSystem L.prod = (L : Multiset ℕ) :=
  (decomp_eq_of_path (evolPath_of_primeList L hL) terminal_one).1

/-- **Uniqueness of prime factorisation**, obtained purely from the abstract
Jordan–Hölder theorem for evolutionary paths. -/
theorem prime_list_multiset_unique {n : ℕ} (L₁ L₂ : List ℕ)
    (h₁ : ∀ p ∈ L₁, p.Prime) (h₂ : ∀ p ∈ L₂, p.Prime)
    (e₁ : L₁.prod = n) (e₂ : L₂.prod = n) : (L₁ : Multiset ℕ) = (L₂ : Multiset ℕ) := by
  have d₁ := natDecomp_prod L₁ h₁
  have d₂ := natDecomp_prod L₂ h₂
  rw [e₁] at d₁
  rw [e₂] at d₂
  rw [← d₁, ← d₂]

/-- For a positive integer the invariant is the multiset of its prime factors. -/
theorem natDecomp_eq_primeFactorsList {n : ℕ} (hn : 0 < n) :
    decomp natSystem n = (n.primeFactorsList : Multiset ℕ) := by
  have hprod : (n.primeFactorsList).prod = n := Nat.prod_primeFactorsList hn.ne'
  have := natDecomp_prod n.primeFactorsList (fun p hp => Nat.prime_of_mem_primeFactorsList hp)
  rwa [hprod] at this

/-- The height of `n` (the common length of every complete evolutionary path
out of `n`) is `Ω n`, the number of prime factors with multiplicity. -/
theorem natHeight_eq_card_factors {n : ℕ} (hn : 0 < n) :
    height (Q := natSystem) n = (n.primeFactorsList).length := by
  simp [height, natDecomp_eq_primeFactorsList hn]

/-- The multiplicity of the label `p` in the decomposition invariant is exactly
the `p`-adic valuation of `n`: the abstract invariant *is* the factorisation. -/
theorem natDecomp_count_eq_factorization {n : ℕ} (hn : 0 < n) (p : ℕ) :
    (decomp natSystem n).count p = n.factorization p := by
  rw [natDecomp_eq_primeFactorsList hn]
  simp [Nat.primeFactorsList_count_eq]

/-- One-step multiplicativity of the invariant, i.e. `Ω(p·m) = Ω(m) + 1`
upgraded to multisets. -/
theorem natDecomp_mul_prime {p m : ℕ} (hp : p.Prime) (hm : 0 < m) :
    decomp natSystem (p * m) = p ::ₘ decomp natSystem m :=
  decomp_step (Q := natSystem) (show natStep (p * m) p m from ⟨hp, hm, rfl⟩)

/-- Reachability implies divisibility (no positivity needed). -/
theorem natDvd_of_reach {n m : ℕ} (h : Reach natSystem n m) : m ∣ n := by
  obtain ⟨ls, hp⟩ := h
  induction hp with
  | nil x => exact dvd_rfl
  | @cons x l y t ls hs _ ih =>
      obtain ⟨-, -, rfl⟩ := hs
      exact ih.trans (dvd_mul_left y l)

/-- Divisibility is exactly reachability in the arithmetic quotient system
(for positive integers): `m ∣ n ↔ n` evolves to `m`. -/
theorem natReach_iff_dvd {n m : ℕ} (hn : 0 < n) (hm : 0 < m) :
    Reach natSystem n m ↔ m ∣ n := by
  constructor
  · exact natDvd_of_reach
  · rintro ⟨k, rfl⟩
    have hk : 0 < k := by
      rcases Nat.eq_zero_or_pos k with rfl | h
      · simp at hn
      · exact h
    -- evolve `m * k` down to `m` by dividing out the primes of `k`
    have hkprod : (k.primeFactorsList).prod = k := Nat.prod_primeFactorsList hk.ne'
    have key : ∀ (L : List ℕ), (∀ p ∈ L, p.Prime) → EvolPath natSystem (m * L.prod) m L := by
      intro L
      induction L with
      | nil => intro _; simpa using EvolPath.nil (Q := natSystem) m
      | cons p L ih =>
          intro hL
          have hp : p.Prime := hL p (List.mem_cons_self ..)
          have hL' : ∀ q ∈ L, q.Prime := fun q hq => hL q (List.mem_cons_of_mem _ hq)
          have hpos : 0 < m * L.prod :=
            Nat.mul_pos hm (List.prod_pos fun q hq => (hL' q hq).pos)
          refine EvolPath.cons (l := p) (y := m * L.prod) ⟨hp, hpos, ?_⟩ (ih hL')
          rw [List.prod_cons]; ring
    refine ⟨k.primeFactorsList, ?_⟩
    have hpath := key k.primeFactorsList (fun p hp => Nat.prime_of_mem_primeFactorsList hp)
    rwa [hkprod] at hpath

/-- Consequently the normal form of any positive integer is `1`. -/
theorem natNormalForm {n : ℕ} (hn : 0 < n) : normalForm natSystem n = 1 := by
  have h := (decomp_eq_of_path (evolPath_of_primeList n.primeFactorsList
    (fun p hp => Nat.prime_of_mem_primeFactorsList hp)) terminal_one).2
  rwa [Nat.prod_primeFactorsList hn.ne'] at h

end Shared.EvolutionaryPath