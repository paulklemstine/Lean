/-
# CRT Realization and Sieve Pre-processing for Admissible Tuples

This file proves that admissible tuples can be "realized" via the Chinese Remainder
Theorem: for any admissible tuple `H` and any finite set of primes `P`, there exist
(infinitely many) translates `n` such that no `n + h` is divisible by any prime in `P`.

This is the exact local sieve setup theorem — it formalizes the pre-processing step
that all modern sieve methods rely on before applying analytic estimates.

## Main results

* `exists_translate_avoiding_prime_set` — CRT avoidance: for admissible `H` and finite
  prime set `P`, there exists `n` such that `p ∤ (n + h)` for all `h ∈ H, p ∈ P`.
* `infinitely_many_translates_avoiding_prime_set` — The set of such `n` is infinite.

-/

import Mathlib
import Speculative.PrimeGaps.Admissible

open Finset Nat Filter

/-
**CRT avoidance theorem.** For any admissible tuple `H` and any finite set of
primes `P`, there exists a natural number `n` such that for every `h ∈ H` and
every `p ∈ P`, `p` does not divide `n + h`. This follows from admissibility
(which gives an avoided residue class for each prime) combined with the Chinese
Remainder Theorem (which realizes all residue conditions simultaneously).
-/
theorem exists_translate_avoiding_prime_set
    (H P : Finset ℕ)
    (hAdm : Admissible H)
    (hPprime : ∀ p, p ∈ P → Nat.Prime p) :
    ∃ n : ℕ, ∀ h, h ∈ H → ∀ p, p ∈ P → ¬p ∣ (n + h) := by
  -- By the Chinese Remainder Theorem, there exists an integer $n$ such that $n \equiv a_p \pmod{p}$ for each $p \in P$, where $a_p$ is chosen such that $p \nmid (a_p + h)$ for all $h \in H$.
  obtain ⟨n, hn⟩ : ∃ n : ℕ, ∀ p ∈ P, ∀ h ∈ H, (n + h) % p ≠ 0 := by
    -- Fix a prime $p \in P$. Since $H$ is admissible, there exists $a_p < p$ such that $n \equiv a_p \pmod{p}$ avoids all residues modulo $p$.
    have h_avoid : ∀ p ∈ P, ∃ a_p : ℕ, a_p < p ∧ ∀ h ∈ H, (a_p + h) % p ≠ 0 := by
      exact fun p hp => hAdm p ( hPprime p hp );
    choose! a ha using h_avoid;
    -- By the Chinese Remainder Theorem, there exists an integer $n$ such that $n \equiv a_p \pmod{p}$ for each $p \in P$, where $a_p$ is chosen such that $p \nmid (a_p + h)$ for all $h \in H$. Hence, $p \nmid (n + h)$ for all $h \in H$ and $p \in P$.
    have h_crt : ∃ n : ℕ, ∀ p ∈ P, n ≡ a p [MOD p] := by
      -- Applying the Chinese Remainder Theorem.
      have h_crt : ∀ p ∈ P, ∃ x : ℕ, x ≡ a p [MOD p] ∧ ∀ q ∈ P, q ≠ p → x ≡ 0 [MOD q] := by
        -- For each prime $p \in P$, let $y_p$ be the multiplicative inverse of $\prod_{q \in P, q \neq p} q$ modulo $p$.
        intro p hp
        obtain ⟨y_p, hy_p⟩ : ∃ y_p : ℕ, y_p * (∏ q ∈ P.erase p, q) ≡ 1 [MOD p] := by
          have := Nat.exists_mul_mod_eq_one_of_coprime ( show Nat.Coprime ( ∏ q ∈ Finset.erase P p, q ) p from Nat.Coprime.prod_left fun q hq => Nat.coprime_comm.mp <| hPprime p hp |> Nat.Prime.coprime_iff_not_dvd |>.2 <| fun h => by have := Nat.prime_dvd_prime_iff_eq ( hPprime p hp ) ( hPprime q <| Finset.mem_of_mem_erase hq ) ; aesop );
          exact Exists.elim ( this ( Nat.Prime.one_lt ( hPprime p hp ) ) ) fun m hm => ⟨ m, by rw [ mul_comm, ← Nat.mod_add_div ( ( ∏ q ∈ Finset.erase P p, q ) * m ) p, hm.2 ] ; norm_num [ Nat.ModEq, Nat.mod_eq_of_lt ( Nat.Prime.one_lt ( hPprime p hp ) ) ] ⟩;
        use y_p * (∏ q ∈ P.erase p, q) * a p;
        exact ⟨ by simpa using hy_p.mul_right _, fun q hq hqp => Nat.modEq_zero_iff_dvd.mpr <| dvd_mul_of_dvd_left ( dvd_mul_of_dvd_right ( Finset.dvd_prod_of_mem _ <| by aesop ) _ ) _ ⟩;
      choose! x hx₁ hx₂ using h_crt;
      use ∑ p ∈ P, x p;
      intro p hp; simp_all +decide [ ← ZMod.natCast_eq_natCast_iff ] ;
      rw [ Finset.sum_eq_single p ] <;> aesop;
    obtain ⟨ n, hn ⟩ := h_crt; use n; intro p hp h hh; specialize hn p hp; simp_all +decide [ Nat.ModEq, Nat.add_mod ] ;
  exact ⟨ n, fun h hh p hp => fun h' => hn p hp h hh <| Nat.mod_eq_zero_of_dvd h' ⟩

/-
**Infinite realization theorem.** For any admissible tuple `H` and finite set of
primes `P`, the set of translates `n` avoiding all prime divisors from `P` across
all shifts in `H` is infinite. This follows from the CRT avoidance theorem plus
the fact that solutions to a system of congruences form an arithmetic progression.
-/
theorem infinitely_many_translates_avoiding_prime_set
    (H P : Finset ℕ)
    (hAdm : Admissible H)
    (hPprime : ∀ p, p ∈ P → Nat.Prime p) :
    Set.Infinite {n : ℕ | ∀ h, h ∈ H → ∀ p, p ∈ P → ¬p ∣ (n + h)} := by
  obtain ⟨ n₀, hn₀ ⟩ := exists_translate_avoiding_prime_set H P hAdm hPprime;
  -- Let $M = \prod_{p \in P} p$. Then for any $k$, $n₀ + kM$ is also in the set.
  set M := ∏ p ∈ P, p with hM;
  refine Set.infinite_iff_exists_gt.mpr ?_;
  intro a;
  refine' ⟨ n₀ + ( a + 1 ) * M, _, _ ⟩ <;> simp_all +decide [ Nat.dvd_add_right, dvd_mul_of_dvd_right, Finset.prod_eq_zero_iff ];
  · intro h hh p hp; specialize hn₀ h hh p hp; simp_all +decide [ ← ZMod.natCast_eq_zero_iff, add_assoc ] ;
    simp_all +decide [ Finset.prod_eq_prod_diff_singleton_mul hp ];
  · nlinarith [ show 0 < ∏ p ∈ P, p from Finset.prod_pos fun p hp => Nat.Prime.pos ( hPprime p hp ) ]

/-
For any admissible `H`, there are infinitely many `n` such that every `n + h`
is coprime to every prime `p ≤ |H|`. This is a concrete unconditional sieve theorem.
-/
theorem infinitely_many_coprime_shifts
    (H : Finset ℕ) (h0 : Admissible H) :
    ∀ m : ℕ, ∃ n ≥ m, ∀ p : ℕ, Nat.Prime p → p ≤ H.card →
      ∃ h, h ∈ H ∧ Nat.Coprime (n + h) p := by
  by_cases h1 : H.Nonempty <;> simp_all +decide [ Nat.coprime_mul_iff_left, Nat.coprime_mul_iff_right ];
  · intro m
    obtain ⟨n₀, hn₀⟩ : ∃ n₀, ∀ h, h ∈ H → ∀ p, Nat.Prime p → p ≤ H.card → ¬(p ∣ (n₀ + h)) := by
      exact Exists.elim ( exists_translate_avoiding_prime_set H ( Finset.filter Nat.Prime ( Finset.Iic H.card ) ) h0 fun p hp => Finset.mem_filter.mp hp |>.2 ) fun n hn => ⟨ n, fun h hh p hp hp' => hn h hh p ( Finset.mem_filter.mpr ⟨ Finset.mem_Iic.mpr hp', hp ⟩ ) ⟩;
    -- Let $M = \prod_{p \leq |H|} p$.
    set M := ∏ p ∈ Finset.filter Nat.Prime (Finset.range (H.card + 1)), p with hM_def;
    refine' ⟨ n₀ + m * M, _, _ ⟩;
    · nlinarith [ show 0 < M from Finset.prod_pos fun p hp => Nat.Prime.pos <| by aesop ];
    · intro p pp p1; use h1.choose, h1.choose_spec; simp_all +decide [ Nat.coprime_add_self_right, Nat.Prime.dvd_mul ] ;
      refine' Nat.Coprime.symm ( pp.coprime_iff_not_dvd.mpr _ );
      rw [ add_right_comm, Nat.dvd_add_left ];
      · exact hn₀ _ h1.choose_spec _ pp p1;
      · exact dvd_mul_of_dvd_right ( Finset.dvd_prod_of_mem _ ( Finset.mem_filter.mpr ⟨ Finset.mem_range.mpr ( by linarith ), pp ⟩ ) ) _;
  · exact fun m => ⟨ ⟨ m, le_rfl ⟩, fun p hp => hp.ne_zero ⟩