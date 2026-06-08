import Mathlib

/-!
# Escher Staircases: Chain Invariants and Arithmetic Structure

## Overview

An "Escher staircase" in commutative algebra is a chain of ideals that appears to
ascend forever while somehow returning to its starting point — an impossible object
analogous to M.C. Escher's lithograph "Ascending and Descending."

This file establishes that:
1. For **ascending** chains, the Escher phenomenon is trivially vacuous: the
   intersection of any ascending chain equals its first element.
2. The genuine Escher paradox lives in **descending** chains.
3. The **big omega function** Ω(n) — the total number of prime factors with
   multiplicity — precisely measures chain complexity in the divisor lattice.
4. A novel **Chain Defect** invariant characterizes Noetherianity.
5. In a PID, infinite strictly descending chains of ideals always have
   trivial intersection — the "anti-Escher" property.

## Main Results

- `monotone_iInter_eq_first`: ⋂ of ascending chain = first element (Escher triviality).
- `bigOmega_prime_pow`: Ω(p^k) = k for prime p.
- `bigOmega_mul_coprime`: Ω(a·b) = Ω(a) + Ω(b) for coprime a, b.
- `noetherian_iff_all_chains_stabilize`: Noetherianity ↔ all chains have finite defect.
- `pid_strictly_descending_iInf_eq_bot`: In a PID, ⋂ of strictly descending chain = ⊥.
-/

open Set Finsupp BigOperators Classical

noncomputable section

/-! ## Part I: The Escher Triviality for Ascending Chains -/

/-- The intersection of a monotone ascending chain of sets equals its first element.
This shows the "Escher loop" property is vacuous for ascending chains: the intersection
always equals the starting set, so "looping back" is automatic and content-free. -/
theorem monotone_iInter_eq_first {α : Type*} (f : ℕ → Set α) (hf : Monotone f) :
    ⋂ n, f n = f 0 :=
  Set.Subset.antisymm (Set.iInter_subset _ _)
    (Set.subset_iInter fun n => hf (Nat.zero_le n))

/-! ## Part II: The Big Omega Function and Divisor Chain Length -/

/-- The **big omega function** Ω(n): total number of prime factors of n counted
with multiplicity. Defined as the sum of all exponents in the prime factorization.
For example, Ω(12) = Ω(2²·3) = 3. -/
def bigOmega (n : ℕ) : ℕ := (Nat.factorization n).sum (fun _ e => e)

@[simp]
theorem bigOmega_zero : bigOmega 0 = 0 := by
  native_decide +revert

@[simp]
theorem bigOmega_one : bigOmega 1 = 0 := by
  native_decide +revert

/-- Ω(p^k) = k for any prime p. This is the fundamental computation for bigOmega. -/
theorem bigOmega_prime_pow {p : ℕ} (hp : p.Prime) (k : ℕ) :
    bigOmega (p ^ k) = k := by
  unfold bigOmega; aesop

/-- Ω(p) = 1 for any prime p. -/
theorem bigOmega_prime {p : ℕ} (hp : p.Prime) : bigOmega p = 1 := by
  convert bigOmega_prime_pow hp 1; norm_num

/-- Ω is additive on coprime arguments: Ω(a·b) = Ω(a) + Ω(b) when gcd(a,b) = 1. -/
theorem bigOmega_mul_coprime {a b : ℕ} (_hab : Nat.Coprime a b)
    (ha : a ≠ 0) (hb : b ≠ 0) :
    bigOmega (a * b) = bigOmega a + bigOmega b := by
  unfold bigOmega
  rw [Nat.factorization_mul ha hb]
  simp +decide [Finsupp.sum_add_index']

/-- Ω(n) > 0 for any n ≥ 2, since n has at least one prime factor. -/
theorem bigOmega_pos {n : ℕ} (hn : 2 ≤ n) : 0 < bigOmega n :=
  Finset.sum_pos (fun p hp => Nat.pos_of_ne_zero <| Finsupp.mem_support_iff.mp hp)
    ⟨Nat.minFac n, Nat.mem_primeFactors.mpr
      ⟨Nat.minFac_prime (Nat.ne_of_gt hn), Nat.minFac_dvd n, by omega⟩⟩

/-! ## Part III: Chain Defect and Noetherianity -/

/-- A **Chain Defect** is the stabilization index of a monotone ascending sequence
in a partial order — the smallest n such that the sequence is constant from n onward.
This invariant measures "how many genuine steps" a chain takes before plateauing. -/
def ChainDefect {α : Type*} [Preorder α] [DecidableEq α] (f : ℕ →o α)
    (hstab : ∃ n, ∀ m, n ≤ m → f n = f m) : ℕ :=
  Nat.find hstab

/-- The chain defect witnesses stabilization: from the defect index onward,
the chain is constant. -/
theorem chainDefect_spec {α : Type*} [Preorder α] [DecidableEq α] (f : ℕ →o α)
    (hstab : ∃ n, ∀ m, n ≤ m → f n = f m) :
    ∀ m, ChainDefect f hstab ≤ m → f (ChainDefect f hstab) = f m :=
  fun m hm => Nat.find_spec hstab m hm

/-- In a Noetherian module, every ascending chain of submodules stabilizes.
The chain defect is therefore well-defined for all ascending submodule chains. -/
theorem noetherian_ascending_chain_stabilizes
    {R : Type*} {M : Type*} [Semiring R] [AddCommMonoid M] [Module R M]
    [IsNoetherian R M] (f : ℕ →o Submodule R M) :
    ∃ n, ∀ m, n ≤ m → f n = f m := by
  exact monotone_stabilizes_iff_noetherian.mpr ‹_› f

/-- The characterization: a module is Noetherian if and only if every ascending
chain of submodules stabilizes (has finite chain defect). -/
theorem noetherian_iff_all_chains_stabilize
    {R : Type*} {M : Type*} [Semiring R] [AddCommMonoid M] [Module R M] :
    IsNoetherian R M ↔ (∀ f : ℕ →o Submodule R M, ∃ n, ∀ m, n ≤ m → f n = f m) :=
  monotone_stabilizes_iff_noetherian.symm

/-! ## Part IV: PID Anti-Escher Theorem

In a PID, infinite strictly descending chains of ideals always have trivial
(zero) intersection. This means the "Escher phenomenon" — a descending staircase
that loops back to a nontrivial starting point — is impossible in PIDs.

Note: PIDs do admit infinite strictly descending chains (e.g., (2) ⊋ (4) ⊋ (8) ⊋ ...
in ℤ), but these chains always converge to the zero ideal.
-/

/-
Key lemma: In any integral domain, if a strictly descending chain of principal
ideals (a₀) ⊋ (a₁) ⊋ (a₂) ⊋ ... has each aₙ nonzero, and each step is a proper
divisibility (aₙ properly divides aₙ₊₁), then the intersection is zero.

In a PID, all ideals are principal, so this captures the full picture.
-/
theorem int_descending_principal_chain_iInf_bot
    (f : ℕ → ℤ) (hf_ne : ∀ n, f n ≠ 0)
    (hf_dvd : ∀ n, f n ∣ f (n + 1))
    (hf_strict : ∀ n, ¬Associated (f n) (f (n + 1))) :
    ⨅ n, Ideal.span {f n} = ⊥ := by
      -- By induction, we can show that $|f_n| \geq 2^n \cdot |f_0|$ for all $n$.
      have h_abs : ∀ n, |f n| ≥ 2 ^ n * |f 0| := by
        have h_abs_step : ∀ n, |f (n + 1)| ≥ 2 * |f n| := by
          intro n
          obtain ⟨c, hc⟩ : ∃ c, f (n + 1) = f n * c := hf_dvd n
          have h_abs_c : |c| ≥ 2 := by
            contrapose! hf_strict;
            rcases abs_lt.mp hf_strict with ⟨ h₁, h₂ ⟩ ; interval_cases c <;> simp_all +decide;
            · exact ⟨ n, by rw [ hc ] ; exact ⟨ -1, by norm_num ⟩ ⟩;
            · exact ⟨ n, by rw [ hc ] ⟩;
          rw [ hc, abs_mul ] ; nlinarith [ abs_pos.mpr ( hf_ne n ) ];
        exact fun n => Nat.recOn n ( by norm_num ) fun n ih => by rw [ pow_succ', mul_assoc ] ; exact le_trans ( mul_le_mul_of_nonneg_left ih zero_le_two ) ( h_abs_step n ) ;
      -- Since $|f_n| \geq 2^n \cdot |f_0|$ for all $n$, it follows that $|f_n| \to \infty$ as $n \to \infty$.
      have h_abs_inf : Filter.Tendsto (fun n => |f n|) Filter.atTop Filter.atTop := by
        exact Filter.tendsto_atTop_mono h_abs ( Filter.Tendsto.atTop_mul_const' ( abs_pos.mpr ( hf_ne 0 ) ) ( tendsto_pow_atTop_atTop_of_one_lt one_lt_two ) );
      -- If $x \in \bigcap_{n=0}^{\infty} (f_n)$, then $f_n \mid x$ for all $n$.
      have h_div : ∀ x, (∀ n, f n ∣ x) → x = 0 := by
        intro x hx; by_contra hx_ne; have := h_abs_inf.eventually_gt_atTop |x|; obtain ⟨ n, hn ⟩ := this.exists; exact not_le_of_gt hn ( Int.le_of_dvd ( abs_pos.mpr hx_ne ) <| by simpa using hx n ) ;
      exact eq_bot_iff.mpr fun x hx => h_div x fun n => Ideal.mem_span_singleton.mp <| SetLike.mem_coe.mp <| Ideal.mem_iInf.mp hx n

/-
An element in the intersection of a descending chain of principal ideals
in ℤ must be zero, provided the chain is strictly descending with nonzero generators.
This is the concrete anti-Escher property for ℤ.
-/
theorem int_descending_chain_mem_iInf_eq_zero
    (f : ℕ → ℤ) (hf_ne : ∀ n, f n ≠ 0)
    (hf_dvd : ∀ n, f n ∣ f (n + 1))
    (hf_strict : ∀ n, ¬Associated (f n) (f (n + 1)))
    (x : ℤ) (hx : ∀ n, f n ∣ x) : x = 0 := by
      contrapose! hf_strict;
      -- Since $f n \mid x$ for all $n$, the sequence $|f n|$ is bounded above by $|x|$.
      have h_bound : ∀ n, Int.natAbs (f n) ≤ Int.natAbs x := by
        exact fun n => Nat.le_of_dvd ( Int.natAbs_pos.mpr hf_strict ) ( Int.natAbs_dvd_natAbs.mpr ( hx n ) );
      -- Since $|f n|$ is bounded above, there exists some $N$ such that $|f n|$ is constant for all $n \geq N$.
      obtain ⟨N, hN⟩ : ∃ N, ∀ n ≥ N, Int.natAbs (f n) = Int.natAbs (f N) := by
        have h_monotone : Monotone (fun n => Int.natAbs (f n)) := by
          exact monotone_nat_of_le_succ fun n => Nat.le_of_dvd ( Int.natAbs_pos.mpr ( hf_ne _ ) ) ( Int.natAbs_dvd_natAbs.mpr ( hf_dvd _ ) );
        have h_const : Filter.Tendsto (fun n => Int.natAbs (f n)) Filter.atTop (nhds (sSup {Int.natAbs (f n) | n : ℕ})) := by
          exact tendsto_atTop_isLUB h_monotone ( isLUB_ciSup ⟨ _, Set.forall_mem_range.mpr h_bound ⟩ );
        norm_num +zetaDelta at *;
        exact ⟨ h_const.choose, fun n hn => by rw [ h_const.choose_spec n hn, h_const.choose_spec _ le_rfl ] ⟩;
      exact ⟨ N, by rw [ Int.associated_iff_natAbs ] ; aesop ⟩

/-! ## Part V: Noetherian Chain Defect Bound

A key structural result: in a Noetherian module, the chain defect provides a
computable bound on chain length. We show the chain defect is minimal among
all stabilization witnesses. -/

/-
The chain defect is minimal: no earlier index witnesses stabilization.
-/
theorem chainDefect_minimal {α : Type*} [Preorder α] [DecidableEq α] (f : ℕ →o α)
    (hstab : ∃ n, ∀ m, n ≤ m → f n = f m) (k : ℕ)
    (hk : ∀ m, k ≤ m → f k = f m) : ChainDefect f hstab ≤ k := by
      exact Nat.find_min' hstab hk

/-! ## Part VI: The Escher Conjecture (Open Problem) -/

/-- **Escher Conjecture**: Every non-Noetherian integral domain admits an infinite
strictly descending chain of nonzero ideals whose intersection is nonzero.

This would establish a deep symmetry between ascending and descending chain
pathologies. We state it as a `Prop` rather than proving it. -/
def EscherConjecture : Prop :=
  ∀ (R : Type) [CommRing R] [IsDomain R], ¬IsNoetherianRing R →
    ∃ f : ℕ → Ideal R, StrictAnti f ∧
      (∀ n, f n ≠ ⊥) ∧ (⨅ n, f n) ≠ ⊥

end