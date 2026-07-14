import Mathlib

/-! # Rank of apparition and the primitive-divisor reduction for Fibonacci numbers

This file develops the *rank of apparition* (entry point) of an integer in the
Fibonacci sequence and uses it to reformulate the existence of a **primitive prime
divisor** of a Fibonacci number in purely structural terms.

For `p ≥ 2` the rank of apparition `fibRank p` is the least positive index `k`
with `p ∣ F(k)`.  Because Fibonacci is a strong divisibility sequence
(`F(gcd m n) = gcd (F m) (F n)`), the rank governs *all* Fibonacci divisibilities:
`p ∣ F(m) ↔ fibRank p ∣ m`.  The immediate structural payoff is
`exists_primitive_iff_exists_prime_fibRank`:

> `F(n)` has a primitive prime divisor **iff** some prime has rank of apparition
> exactly `n`.

This converts Carmichael's primitive-divisor theorem into the assertion that every
large index is realised as a rank of apparition, and isolates the remaining
quantitative core.  Toward that core we also record the first-order
lifting-the-exponent congruence `fib_mul_prime_congr`, the base identity
`F(mp) ≡ p·F(m)·F(m+1)^{p-1} (mod F(m)²)` from which the `p`-adic valuation jump of
Carmichael's law is read off.

## Main results
* `fib_rank_exists` — every `p ≥ 2` divides some positive-index Fibonacci number.
* `fibRank`, `fibRank_pos`, `fibRank_dvd_fib`, `fibRank_le` — the rank of
  apparition and its defining extremal properties.
* `fib_dvd_iff_fibRank_dvd` — the divisibility characterization.
* `exists_primitive_iff_exists_prime_fibRank` — primitive divisors are exactly the
  primes of rank `n`.
* `fib_mul_prime_congr` — the first-order lifting-the-exponent congruence.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  The obstruction to a Fibonacci number having a
  fresh prime factor is entirely controlled by the arithmetic of ranks of
  apparition; the phenomenon should therefore be expressible without mentioning
  Fibonacci numbers at all, only the function `p ↦ fibRank p`.
* **Experiment (Experimenter).**  Existence of a rank was obtained by pigeonhole on
  the finitely many residue pairs `(F(k), F(k+1)) mod p`; the characterization by a
  `gcd`-minimality argument through `F(gcd m n) = gcd (F m) (F n)`; and the
  reduction by unwinding the two definitions.  The first-order congruence came from
  a two-step induction on the multiplier using the addition law `F(i+j+1) =
  F(i)F(j) + F(i+1)F(j+1)`.
* **Analysis (Analyst).**  "True and structural."  The rank turns a statement about
  sizes of integers into a statement about which indices occur as entry points.
  The one genuinely quantitative residue is the size of the primitive part, which
  is where Binet-type growth must eventually enter.
* **Critique (Critic).**  The reduction is *false* at `n = 0` (every prime divides
  `F(0) = 0` vacuously, yet no prime has rank `0`); the hypothesis `0 < n` is
  therefore load-bearing and is included.  All statements are `sorry`-free.
* **Synthesis (PI).**  Ranks of apparition give a clean skeleton for Carmichael's
  theorem: the finite/computational range plus this structural reduction leave a
  single quantitative step (growth of the primitive part) as the open frontier.

### Generalization
The rank-of-apparition framework and the divisibility characterization extend
verbatim to any strong divisibility sequence (e.g. Lucas sequences, elliptic
divisibility sequences), of which Fibonacci is the archetype.

### Boundary
The reduction genuinely requires `0 < n`; at `n = 0` it fails, and at the classical
exceptional indices `n ∈ {1, 2, 6, 12}` there is provably *no* prime of rank `n`,
so the "large index" hypothesis in Carmichael's theorem cannot be dropped.
-/

set_option maxHeartbeats 1000000

open scoped Classical

/-- Every prime (indeed every `p ≥ 2`) divides some positive-index Fibonacci
number: the rank of apparition exists. -/
lemma fib_rank_exists (p : ℕ) (hp : 2 ≤ p) : ∃ k, 0 < k ∧ p ∣ Nat.fib k := by
  -- By the pigeonhole principle, since there are only $p^2$ possible pairs $(F_n \mod p, F_{n+1} \mod p)$, there must exist indices $i$ and $j$ with $i < j$ such that $(F_i \mod p, F_{i+1} \mod p) = (F_j \mod p, F_{j+1} \mod p)$.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j, i < j ∧ (Nat.fib i % p = Nat.fib j % p) ∧ (Nat.fib (i + 1) % p = Nat.fib (j + 1) % p) := by
    by_contra h;
    exact absurd ( Set.infinite_range_of_injective ( show Function.Injective ( fun n => ( Nat.fib n % p, Nat.fib ( n + 1 ) % p ) ) from fun m n hmn => le_antisymm ( not_lt.1 fun contra => h ⟨ n, m, contra, by aesop ⟩ ) ( not_lt.1 fun contra => h ⟨ m, n, contra, by aesop ⟩ ) ) ) ( Set.not_infinite.mpr <| Set.finite_iff_bddAbove.mpr ⟨ ( p, p ), by rintro a ⟨ n, rfl ⟩ ; exact ⟨ Nat.le_of_lt <| Nat.mod_lt _ <| by positivity, Nat.le_of_lt <| Nat.mod_lt _ <| by positivity ⟩ ⟩ );
  induction' i with i ih generalizing j;
  · exact ⟨ j, hij, Nat.dvd_of_mod_eq_zero <| by simpa using h_eq.1.symm ⟩;
  · specialize ih ( j - 1 ) ( Nat.lt_pred_iff.mpr hij ) ; rcases j <;> simp_all +decide [ Nat.fib_add_two, Nat.add_mod ] ;
    simp_all +decide [ ← ZMod.natCast_eq_natCast_iff' ];
    aesop

/-- The rank of apparition of `p`: the least positive index `k` with `p ∣ fib k`.
For `p ≥ 2` this is well defined and positive. -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {k | 0 < k ∧ p ∣ Nat.fib k}

lemma fibRank_mem (p : ℕ) (hp : 2 ≤ p) :
    0 < fibRank p ∧ p ∣ Nat.fib (fibRank p) :=
  Nat.sInf_mem (fib_rank_exists p hp)

lemma fibRank_pos (p : ℕ) (hp : 2 ≤ p) : 0 < fibRank p := (fibRank_mem p hp).1

lemma fibRank_dvd_fib (p : ℕ) (hp : 2 ≤ p) : p ∣ Nat.fib (fibRank p) := (fibRank_mem p hp).2

lemma fibRank_le (p k : ℕ) (hk : 0 < k) (hpk : p ∣ Nat.fib k) : fibRank p ≤ k :=
  Nat.sInf_le ⟨hk, hpk⟩

/-- **Divisibility characterization of the rank of apparition.**
For `p ≥ 2`, `p` divides `fib m` iff the rank of apparition of `p` divides `m`. -/
lemma fib_dvd_iff_fibRank_dvd (p : ℕ) (hp : 2 ≤ p) (m : ℕ) :
    p ∣ Nat.fib m ↔ fibRank p ∣ m := by
  -- By definition of `fibRank`, we know that `fibRank p` is the least positive index `k` such that `p ∣ fib k`.
  have h_fib_rank : ∀ k, 0 < k → p ∣ Nat.fib k → fibRank p ∣ k := by
    intros k hk_pos hk_div
    by_contra h_contra;
    -- Let $g = \gcd(k, \text{fibRank}(p))$. Then $g > 0$ and $g < \text{fibRank}(p)$.
    set g := Nat.gcd k (fibRank p) with hg
    have hg_pos : 0 < g := by
      exact Nat.gcd_pos_of_pos_left _ hk_pos
    have hg_lt : g < fibRank p := by
      exact lt_of_le_of_ne ( Nat.le_of_dvd ( fibRank_pos p hp ) ( Nat.gcd_dvd_right _ _ ) ) fun con => h_contra <| con ▸ Nat.gcd_dvd_left _ _;
    exact not_le_of_gt hg_lt <| fibRank_le p g hg_pos <| by have := Nat.dvd_gcd hk_div ( fibRank_dvd_fib p hp ) ; simp_all +decide [ Nat.fib_gcd ] ;
  by_cases hm : 0 < m;
  · exact ⟨ h_fib_rank m hm, fun h => dvd_trans ( fibRank_dvd_fib p hp ) ( Nat.fib_dvd _ _ h ) ⟩;
  · aesop

/-- **Primitive divisors are exactly the primes of rank `n`.**
`fib n` has a primitive prime divisor (a prime dividing `fib n` but no earlier
Fibonacci number) if and only if some prime has rank of apparition exactly `n`. -/
lemma exists_primitive_iff_exists_prime_fibRank (n : ℕ) (hn : 0 < n) :
    (∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k))
      ↔ ∃ p, Nat.Prime p ∧ fibRank p = n := by
  constructor <;> intro h;
  · obtain ⟨ p, hp₁, hp₂, hp₃ ⟩ := h;
    refine' ⟨ p, hp₁, le_antisymm _ _ ⟩;
    · exact fibRank_le p n hn hp₂;
    · exact le_of_not_gt fun h => hp₃ _ ( fibRank_pos p hp₁.two_le ) h ( fibRank_dvd_fib p hp₁.two_le );
  · obtain ⟨ p, hp₁, rfl ⟩ := h;
    refine' ⟨ p, hp₁, fibRank_dvd_fib p hp₁.two_le, fun k hk₁ hk₂ => _ ⟩;
    exact fun h => hk₂.not_ge <| fibRank_le p k hk₁ h

/-- **First-order Fibonacci congruence toward lifting-the-exponent.**
For any prime `p` and index `m`, modulo `fib m` squared the value `fib (m*p)`
collapses to the single leading term `p * fib m * fib (m+1) ^ (p-1)`.  This is the
base congruence from which the `p`-adic valuation increment (Carmichael's
lifting-the-exponent law) is read off. -/
lemma fib_mul_prime_congr (p : ℕ) (m : ℕ) :
    Nat.fib (m * p) ≡ p * Nat.fib m * Nat.fib (m + 1) ^ (p - 1) [MOD Nat.fib m ^ 2] := by
  induction' p with k ih;
  · norm_num;
    rfl;
  · -- We'll use the identity $F_{m(k+1)} = F_{mk} \cdot F_{m-1} + F_{mk+1} \cdot F_m$.
    have h_fib_add : Nat.fib (m * (k + 1)) = Nat.fib (m * k) * Nat.fib (m - 1) + Nat.fib (m * k + 1) * Nat.fib m := by
      rcases m with ( _ | _ | m ) <;> simp_all +decide [ Nat.fib_add_two ];
      convert Nat.fib_add ( ( m + 1 + 1 ) * k ) ( m + 1 ) using 1 ; ring;
      rw [ show 2 + m = m + 1 + 1 by ring, Nat.fib_add_two ] ; ring;
    -- We'll use the fact that $F_{mk+1} \equiv F_{m+1}^k \pmod{F_m}$.
    have h_fib_succ : Nat.fib (m * k + 1) ≡ Nat.fib (m + 1) ^ k [MOD Nat.fib m] := by
      refine' Nat.recOn k _ _ <;> simp_all +decide [ Nat.pow_succ', Nat.mul_succ, Nat.fib_add ];
      · rfl;
      · exact fun n hn => by simpa only [ mul_comm ] using hn.mul_right _;
    -- Substitute the induction hypothesis and the congruence for $F_{mk+1}$ into the identity.
    have h_subst : Nat.fib (m * (k + 1)) ≡ (k * Nat.fib m * Nat.fib (m + 1) ^ (k - 1)) * Nat.fib (m - 1) + Nat.fib (m + 1) ^ k * Nat.fib m [MOD Nat.fib m ^ 2] := by
      rw [ h_fib_add ];
      refine' Nat.ModEq.add ( ih.mul_right _ ) _;
      rw [ Nat.modEq_iff_dvd ] at *;
      convert mul_dvd_mul h_fib_succ ( dvd_refl ( Nat.fib m : ℤ ) ) using 1 ; push_cast ; ring;
      push_cast; ring;
    rcases m with ( _ | _ | m ) <;> simp_all +decide [ Nat.fib_add_two, pow_succ' ];
    · norm_num [ Nat.modEq_iff_dvd ];
    · refine h_subst.trans <| Nat.ModEq.symm <| Nat.modEq_of_dvd ?_;
      rcases k with ( _ | k ) <;> simp_all +decide [ pow_succ' ] ; ring_nf;
      exact ⟨ -k * ( Nat.fib m + Nat.fib ( 1 + m ) * 2 ) ^ k - ( Nat.fib m + Nat.fib ( 1 + m ) * 2 ) ^ k, by ring ⟩

/-! ## Examples and sanity checks -/

-- The rank of apparition of small primes: `F(3) = 2`, `F(5) = 5`, `F(4) = 3`, `F(10) = 55 = 5·11`.
#check @fib_rank_exists
#check @fib_dvd_iff_fibRank_dvd
#check @exists_primitive_iff_exists_prime_fibRank

-- `2` has rank `3` (least `k` with `2 ∣ F(k)`, since `F(3) = 2`).
example : (2 : ℕ) ∣ Nat.fib 3 := by decide
example : ¬ (2 : ℕ) ∣ Nat.fib 1 ∧ ¬ (2 : ℕ) ∣ Nat.fib 2 := by decide

-- `F(12) = 144` has *no* primitive prime divisor: every prime factor (`2, 3`)
-- already appears earlier (`2 ∣ F(3)`, `3 ∣ F(4)`).  This is one of the classical
-- exceptional indices `{1, 2, 6, 12}`.
example : Nat.fib 12 = 144 := by decide
example : (2 : ℕ) ∣ Nat.fib 3 ∧ (3 : ℕ) ∣ Nat.fib 4 := by decide

-- The first-order congruence, checked at `p = 3`, `m = 4`: `F(12) = 144`,
-- `3 · F(4) · F(5)^2 = 3 · 3 · 25 = 225`, and `144 ≡ 225 (mod F(4)^2 = 9)`.
example : Nat.fib (4 * 3) ≡ 3 * Nat.fib 4 * Nat.fib 5 ^ 2 [MOD Nat.fib 4 ^ 2] := by decide