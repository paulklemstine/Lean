import Mathlib

/-! # The Rank of Apparition and Primitive Prime Divisors of Fibonacci Numbers

Domain: Tropical / Number Theory (cross-domain bridge to the Carmichael catalog targets).

This file develops, from scratch and `sorry`-free, the theory of the **Fibonacci entry
point** (a.k.a. the *rank of apparition*) `fibEntry m`: the least `k > 0` with `m ∣ F k`.

The key structural results are:

* `exists_pos_dvd_fib`  — every modulus `m > 0` divides some positive Fibonacci number
  (well-definedness of the rank of apparition, proved via the periodicity of the
  Fibonacci pair-sequence modulo `m`);
* `fib_dvd_iff_fibEntry_dvd` — the **law of apparition**: `m ∣ F k ↔ fibEntry m ∣ k`;
* `prime_primitive_divisor_iff` — a prime `p` is a **primitive prime divisor** of `F n`
  iff `fibEntry p = n`.

These results are the conceptual core underlying the catalog's Carmichael primitive-divisor
theorems (`fib_primitive_divisor`, `fib_carmichael`): the law of apparition is exactly the
mechanism that turns a "coprime part" computation into a primitive-divisor statement.

The whole development rests only on `Nat.fib_gcd` and `Nat.fib_dvd` from Mathlib.
-/

namespace FibonacciApparition

/-! ## §1. Periodicity of the Fibonacci pair-sequence modulo `m` -/

/-- The pair `(F n, F (n+1))` reduced modulo `m`. The Fibonacci recurrence makes this a
deterministic dynamical system on the finite set `ZMod m × ZMod m`. -/
def fibPair (m n : ℕ) : ZMod m × ZMod m := ((Nat.fib n : ZMod m), (Nat.fib (n + 1) : ZMod m))

/-
!-- The backward step: the recurrence `F(n+2) = F(n) + F(n+1)` is invertible, so equal
successor-pairs force equal predecessor-pairs (subtraction in `ZMod m`). -- !--

The Fibonacci pair-map is *backward* deterministic: if the pairs at `a+1` and `b+1`
agree mod `m`, then so do the pairs at `a` and `b`.
-/
-- !-- The recurrence F(n+2)=F(n)+F(n+1) is invertible over ZMod m, so equal successor-pairs force equal predecessor-pairs via subtraction. -- !--
lemma fibPair_back (m a b : ℕ) (h : fibPair m (a + 1) = fibPair m (b + 1)) :
    fibPair m a = fibPair m b := by
  unfold fibPair at *;
  simp_all +decide [ Nat.fib_add_two ];
  linear_combination' h.2 - h.1

/-
!-- Descent: iterate `fibPair_back` `i` times to pull any coincidence back to time `0`. -- !--

Descent to the origin: a coincidence `fibPair m i = fibPair m j` with `i ≤ j` forces
`fibPair m 0 = fibPair m (j - i)`.
-/
-- !-- Iterate the backward step i times to pull any coincidence of pairs back to time 0. -- !--
lemma fibPair_descent (m : ℕ) :
    ∀ i j, i ≤ j → fibPair m i = fibPair m j → fibPair m 0 = fibPair m (j - i) := by
  intros i j hij h_eq
  induction' i with i ih generalizing j;
  · simpa using h_eq;
  · rcases j with ( _ | j ) <;> simp_all +decide [ Nat.succ_sub_succ ];
    exact ih j hij ( fibPair_back m i j h_eq )

/-
!-- Pigeonhole on the finite type `ZMod m × ZMod m` gives a coincidence; descent sends
it to a zero `F(j-i) ≡ 0`, i.e. `m ∣ F (j-i)`. -- !--

**Well-definedness of the rank of apparition.** Every `m > 0` divides some positive
Fibonacci number.
-/
-- !-- Pigeonhole on the finite set of Fibonacci pairs mod m yields a coincidence; descent sends it to F(j-i) ≡ 0, i.e. m ∣ F(j-i). -- !--
theorem exists_pos_dvd_fib (m : ℕ) (hm : 0 < m) : ∃ k, 0 < k ∧ m ∣ Nat.fib k := by
  -- Use the pigeonhole principle to find a repeat in the sequence of pairs.
  have h_pigeonhole : ∃ i j, i < j ∧ (Nat.fib i ≡ Nat.fib j [MOD m]) ∧ (Nat.fib (i + 1) ≡ Nat.fib (j + 1) [MOD m]) := by
    have h_finite : Set.Finite ((fun n => (Nat.fib n % m, Nat.fib (n + 1) % m)) '' Set.univ) := by
      exact Set.finite_iff_bddAbove.mpr ⟨ ( m - 1, m - 1 ), by rintro x ⟨ n, -, rfl ⟩ ; exact ⟨ Nat.le_sub_one_of_lt ( Nat.mod_lt _ hm ), Nat.le_sub_one_of_lt ( Nat.mod_lt _ hm ) ⟩ ⟩;
    contrapose! h_finite;
    exact Set.infinite_of_injective_forall_mem ( fun i j hij => le_antisymm ( not_lt.1 fun hi => h_finite _ _ hi ( by simp_all +decide [ Nat.ModEq ] ) ( by simp_all +decide [ Nat.ModEq ] ) ) ( not_lt.1 fun hj => h_finite _ _ hj ( by simp_all +decide [ Nat.ModEq ] ) ( by simp_all +decide [ Nat.ModEq ] ) ) ) fun n => Set.mem_image_of_mem _ ( Set.mem_univ n );
  obtain ⟨ i, j, hij, hi, hj ⟩ := h_pigeonhole;
  induction' i with i ih generalizing j;
  · exact ⟨ j, hij, Nat.dvd_of_mod_eq_zero hi.symm ⟩;
  · contrapose! ih;
    refine' ⟨ j - 1, _, _, _, ih ⟩ <;> rcases j with ( _ | _ | j ) <;> simp_all +decide [ Nat.fib_add_two, ← ZMod.natCast_eq_natCast_iff ]

/-! ## §2. The Fibonacci entry point (rank of apparition) -/

open Classical in
/-- The **Fibonacci entry point** of `m`: the least `k > 0` with `m ∣ F k`
(`0` if none exists; by `exists_pos_dvd_fib` that fallback never triggers for `m > 0`). -/
noncomputable def fibEntry (m : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ m ∣ Nat.fib k then Nat.find h else 0

/-
For `m > 0` the entry point is positive.
-/
lemma fibEntry_pos (m : ℕ) (hm : 0 < m) : 0 < fibEntry m := by
  have h := exists_pos_dvd_fib m hm; unfold fibEntry; aesop;

/-
`m` divides the Fibonacci number at its own entry point.
-/
lemma fibEntry_dvd_fib (m : ℕ) (hm : 0 < m) : m ∣ Nat.fib (fibEntry m) := by
  unfold fibEntry;
  split_ifs <;> simp_all +decide [ Nat.find_spec ( exists_pos_dvd_fib m hm ) ]

/-
Minimality: the entry point is `≤` any positive `k` with `m ∣ F k`.
-/
lemma fibEntry_le (m k : ℕ) (hk : 0 < k) (hmk : m ∣ Nat.fib k) : fibEntry m ≤ k := by
  by_cases h : ∃ k, 0 < k ∧ m ∣ Nat.fib k;
  · unfold fibEntry;
    split_ifs ; exact Nat.find_min' _ ⟨ hk, hmk ⟩;
  · exact False.elim <| h ⟨ k, hk, hmk ⟩

/-
Below the entry point, `m` divides no positive Fibonacci number.
-/
lemma fibEntry_min (m k : ℕ) (hk : 0 < k) (hlt : k < fibEntry m) : ¬ m ∣ Nat.fib k := by
  unfold fibEntry at hlt;
  split_ifs at hlt <;> simp_all +decide

/-! ## §3. The law of apparition -/

/-
!-- `m ∣ F k` and `m ∣ F e` give `m ∣ gcd (F k) (F e) = F (gcd k e)` (`Nat.fib_gcd`);
minimality of `e` forces `gcd k e = e`, i.e. `e ∣ k`. Conversely `e ∣ k ⇒ F e ∣ F k`. -- !--

**Law of apparition.** A modulus `m > 0` divides `F k` exactly when its entry point
divides `k`. This is the divisibility backbone of the entire Fibonacci/Lucas primitive
divisor theory.
-/
-- !-- From m ∣ F k and m ∣ F e get m ∣ gcd(F k, F e) = F(gcd k e); minimality of e forces gcd k e = e, hence e ∣ k. Converse is fib_dvd. -- !--
theorem fib_dvd_iff_fibEntry_dvd (m : ℕ) (hm : 0 < m) (k : ℕ) :
    m ∣ Nat.fib k ↔ fibEntry m ∣ k := by
  constructor <;> intro hk;
  · contrapose! hk;
    -- By definition of `fibEntry`, if `fibEntry m` does not divide `k`, then `m` cannot divide `Nat.fib k`.
    have h_not_div : ¬m ∣ Nat.fib (Nat.gcd k (fibEntry m)) := by
      apply fibEntry_min;
      · exact Nat.gcd_pos_of_pos_right _ ( fibEntry_pos m hm );
      · exact lt_of_le_of_ne ( Nat.le_of_dvd ( fibEntry_pos m hm ) ( Nat.gcd_dvd_right _ _ ) ) fun h => hk <| h ▸ Nat.gcd_dvd_left _ _;
    exact fun h => h_not_div <| Nat.dvd_trans ( by simpa [ Nat.gcd_comm ] using Nat.dvd_gcd h ( fibEntry_dvd_fib m hm ) ) ( by simp +decide [ Nat.fib_gcd ] );
  · exact dvd_trans ( fibEntry_dvd_fib m hm ) ( Nat.fib_dvd _ _ hk )

/-! ## §4. Characterisation of primitive prime divisors -/

/-
!-- Forward: primitivity rules out `fibEntry p < n`, and `p ∣ F n` gives `fibEntry p ≤ n`,
so `fibEntry p = n`. Backward: `fibEntry_dvd_fib` and `fibEntry_min` give both halves. -- !--

**Primitive prime divisor characterisation.** A prime `p` is a primitive prime divisor
of `F n` (it divides `F n` but no earlier positive Fibonacci number) precisely when the
rank of apparition of `p` equals `n`. This recasts Carmichael's theorem as a statement
about the entry-point function.
-/
-- !-- Primitivity forbids fibEntry p < n while p ∣ F n gives fibEntry p ≤ n, so fibEntry p = n; the converse uses fibEntry_dvd_fib and fibEntry_min. -- !--
theorem prime_primitive_divisor_iff (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n) :
    (p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k) ↔ fibEntry p = n := by
  constructor <;> intro h;
  · refine' le_antisymm _ _;
    · exact fibEntry_le p n hn h.1;
    · exact le_of_not_gt fun h' => h.2 _ ( fibEntry_pos _ hp.pos ) h' ( fibEntry_dvd_fib _ hp.pos );
  · exact ⟨ h ▸ fibEntry_dvd_fib p hp.pos, fun k hk₁ hk₂ => by have := fibEntry_min p k hk₁ ( by linarith ) ; aesop ⟩

/-! ## §5. Corollaries connecting to the catalog -/

/-- The classical gcd identity `gcd (F m) (F n) = F (gcd m n)`, restated for reference. -/
lemma fib_gcd_eq (m n : ℕ) : Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n) :=
  (Nat.fib_gcd m n).symm

/-- A primitive prime divisor of `F n` (for `n ≥ 1`) is automatically a fresh prime:
its rank of apparition pins down `n`, so distinct indices have disjoint primitive divisors. -/
theorem primitive_divisor_unique_index (p m n : ℕ) (hp : Nat.Prime p) (hm : 0 < m) (hn : 0 < n)
    (hpm : p ∣ Nat.fib m ∧ ∀ k, 0 < k → k < m → ¬ p ∣ Nat.fib k)
    (hpn : p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k) : m = n := by
  have h1 := (prime_primitive_divisor_iff p m hp hm).mp hpm
  have h2 := (prime_primitive_divisor_iff p n hp hn).mp hpn
  rw [← h1, ← h2]

end FibonacciApparition