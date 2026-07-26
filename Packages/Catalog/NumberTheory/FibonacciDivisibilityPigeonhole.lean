import Mathlib.Data.Nat.Fib.Basic
import Mathlib.Data.Nat.Factorization.Basic
import Mathlib

/-!
# Fibonacci-Divisibility Pigeonhole Bridge

This file contains three theorems:

* `fib_dvd_of_dvd`: divisibility of indices implies divisibility of Fibonacci numbers.
* `fib_dvd_iff`: for `3 ≤ m`, `Nat.fib m ∣ Nat.fib n ↔ m ∣ n`.
* `divisibility_pigeonhole`: any `n+1` distinct numbers in `[1, 2n]` contain a
  divisibility pair.
-/

/-- If `m ∣ n` then `Nat.fib m ∣ Nat.fib n`. -/
theorem fib_dvd_of_dvd {m n : ℕ} (h : m ∣ n) : Nat.fib m ∣ Nat.fib n :=
  Nat.fib_dvd m n h

/-- For `3 ≤ m`, `Nat.fib m ∣ Nat.fib n ↔ m ∣ n`. -/
theorem fib_dvd_iff {m n : ℕ} (hm : 3 ≤ m) : Nat.fib m ∣ Nat.fib n ↔ m ∣ n := by
  have hgcd : Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n) :=
    (Nat.fib_gcd m n).symm
  by_cases h : m ∣ n <;> simp_all +decide [ Nat.dvd_iff_mod_eq_zero ];
  · exact Nat.mod_eq_zero_of_dvd <| fib_dvd_of_dvd <| Nat.dvd_of_mod_eq_zero h;
  · -- Since $n \not\equiv 0 \pmod{m}$, we have $\gcd(m, n) < m$.
    have h_gcd_lt_m : Nat.gcd m n < m := by
      exact lt_of_le_of_ne ( Nat.le_of_dvd ( by linarith ) ( Nat.gcd_dvd_left _ _ ) ) fun con => h <| Nat.mod_eq_zero_of_dvd <| con ▸ Nat.gcd_dvd_right _ _;
    -- Since $n \not\equiv 0 \pmod{m}$, we have $\gcd(m, n) < m$, and thus $F_{\gcd(m, n)} < F_m$.
    have h_fib_gcd_lt_fib_m : Nat.fib (Nat.gcd m n) < Nat.fib m := by
      by_cases h_gcd_ge_2 : 2 ≤ Nat.gcd m n;
      · rw [ Nat.fib_lt_fib ] <;> linarith;
      · interval_cases _ : Nat.gcd m n <;> simp_all +decide;
        exact Nat.le_trans ( by decide ) ( Nat.fib_mono hm );
    exact fun h' => h_fib_gcd_lt_fib_m.ne <| by have := Nat.gcd_eq_left ( Nat.dvd_of_mod_eq_zero h' ) ; linarith;

/-- The odd part of a natural number: dividing out all factors of 2. -/
def oddPart (x : ℕ) : ℕ := x / (2 ^ x.factorization 2)

/-- Pigeonhole: any `n+1` distinct numbers in `[1, 2n]` contain a divisibility pair.

The hypothesis `hn : n ≥ 1` is retained because it was part of the requested
statement, but it is not actually needed for the proof. -/
theorem divisibility_pigeonhole (n : ℕ) (S : Finset ℕ) (hn : n ≥ 1)
    (hcard : S.card = n + 1) (hsub : S ⊆ Finset.Icc 1 (2 * n)) :
    ∃ a ∈ S, ∃ b ∈ S, a ≠ b ∧ a ∣ b := by
  -- Map each element of S to its oddPart. The image lands in the set of odd numbers in Icc 1 (2n).
  have h_map : (S.image oddPart).card ≤ n := by
    -- The image of $S$ under $oddPart$ is a subset of the set of odd numbers in $[1, 2n]$, which has cardinality $n$.
    have h_image_subset : Finset.image oddPart S ⊆ Finset.image (fun k => 2 * k + 1) (Finset.range n) := by
      intro m hm
      obtain ⟨x, hx⟩ : ∃ x ∈ S, oddPart x = m := by
        aesop
      have h_odd : Odd m := by
        exact hx.2 ▸ Nat.odd_iff.mpr ( Nat.mod_two_ne_zero.mp fun h => absurd ( Nat.dvd_of_mod_eq_zero h ) ( Nat.not_dvd_ordCompl ( by norm_num ) ( by linarith [ Finset.mem_Icc.mp ( hsub hx.1 ) ] ) ) )
      have h_range : m ≤ 2 * n := by
        exact hx.2 ▸ Nat.le_trans ( Nat.div_le_self _ _ ) ( Finset.mem_Icc.mp ( hsub hx.1 ) |>.2 );
      obtain ⟨ k, rfl ⟩ := h_odd; exact Finset.mem_image.mpr ⟨ k, Finset.mem_range.mpr ( by linarith ), rfl ⟩ ;
    exact le_trans ( Finset.card_le_card h_image_subset ) ( Finset.card_image_le.trans ( by simp ) );
  -- Since $S$ has $n+1$ elements and there are only $n$ possible odd parts, by the pigeonhole principle, there must be at least two elements in $S$ with the same odd part.
  obtain ⟨a, haS, b, hbS, hab⟩ : ∃ a ∈ S, ∃ b ∈ S, a ≠ b ∧ oddPart a = oddPart b := by
    contrapose! h_map;
    rw [ Finset.card_image_of_injOn fun a ha b hb hab => by contrapose! hab; exact h_map a ha b hb hab ] ; linarith;
  -- Given that $oddPart a = oddPart b$, we can write $a = oddPart a * 2^{v_2(a)}$ and $b = oddPart b * 2^{v_2(b)}$.
  obtain ⟨va, hva⟩ : ∃ va, a = oddPart a * 2 ^ va := by
    exact ⟨ _, Eq.symm ( Nat.div_mul_cancel ( Nat.ordProj_dvd _ _ ) ) ⟩
  obtain ⟨vb, hvb⟩ : ∃ vb, b = oddPart b * 2 ^ vb := by
    exact ⟨ _, Eq.symm ( Nat.div_mul_cancel ( Nat.ordProj_dvd _ _ ) ) ⟩;
  -- Without loss of generality, assume $va \leq vb$.
  by_cases h_cases : va ≤ vb;
  · exact ⟨ a, haS, b, hbS, hab.1, hva.symm ▸ hvb.symm ▸ mul_dvd_mul ( by simp +decide [ hab.2 ] ) ( pow_dvd_pow _ h_cases ) ⟩;
  · exact ⟨ b, hbS, a, haS, hab.1.symm, hvb.symm ▸ hva.symm ▸ hab.2.symm ▸ Nat.mul_dvd_mul_left _ ( pow_dvd_pow _ ( le_of_not_ge h_cases ) ) ⟩