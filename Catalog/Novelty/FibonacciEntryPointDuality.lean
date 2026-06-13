import Mathlib

/-!
# Entry-Point Duality for the Fibonacci sequence

For a modulus `p`, the **entry point** (rank of apparition) `z(p) = fibEntry p` is the
least positive index `k` with `p ∣ F k` (and `0` if no such index exists).  This file
isolates the single biconditional from which the scattered, one-directional
entry-point lemmas of the catalog all follow:

* `fib_dvd_iff_fibEntry_dvd` — the master *duality* `p ∣ F n ↔ z(p) ∣ n`.  It turns a
  divisibility question about Fibonacci numbers into a divisibility question about a
  single arithmetic function `z`.
* `isFibPrimitiveDivisor_iff_entry` — a prime `p` is a *primitive* divisor of `F n`
  iff `z(p) = n`; primitivity collapses to one equation.
* `fib_dvd_iff` — the strong-divisibility law `F m ∣ F n ↔ m ∣ n` for `m ≥ 3`,
  recovered as the special case `p = F m` of the duality.
* `fib_primitive_divisor_verified` — a `native_decide` certificate of Carmichael's
  primitive-divisor theorem for `1 ≤ n ≤ 40`, `n ∉ {1,2,6,12}`.

The whole development is self-contained over Mathlib: the only Fibonacci-specific
inputs are `Nat.fib_gcd` and `Nat.fib_dvd`.

## Catalog synthesis

This unifies and generalizes the one-directional entry-point lemmas previously
scattered across the catalog: `CarmichaelComposite.fibEntryPt_dvd_of_fib_dvd`
(forward direction only, stated for primes), the LTE file's `fibEntryPoint`, and the
primitive-divisor predicates of `Applications.FibonacciPrimitiveDivisors`.  The new
content is that all of these are corollaries of one biconditional, which moreover
needs no primality hypothesis.

-- !-- Lab Notebook -- !--
-- !-- Hypothesis: the divisibility relation `p ∣ F n` is governed entirely by the
--     entry-point map `z`, via the principal-ideal identity `p ∣ F n ↔ z(p) ∣ n`,
--     with no primality hypothesis required. -- !--
-- !-- Result: proved the biconditional for arbitrary `p`, derived the primitive-divisor
--     characterization `z(p)=n`, the strong-divisibility law `F m ∣ F n ↔ m ∣ n`
--     (`m ≥ 3`), and a finite Carmichael certificate. -- !--
-- !-- Insight: `Nat.fib_gcd` collapses "two simultaneous apparitions" into one
--     apparition at the gcd, so minimality of `z(p)` forces `z(p) ∣ n`; the converse
--     is pure `Nat.fib_dvd`.  Everything else is divisibility algebra in ℕ. -- !--
-- !-- Failure analysis: the only care needed is the `n = 0` / "no entry point" boundary,
--     handled uniformly because `0 ∣ n ↔ n = 0` and `F 0 = 0`. -- !--
-- !-- End Lab Notebook -- !--
-/

namespace FibEntryDuality

open Classical in
/-- The **Fibonacci entry point** (rank of apparition) of `p`: the least positive `k`
with `p ∣ F k`, or `0` if no such `k` exists. -/
noncomputable def fibEntry (p : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ p ∣ Nat.fib k then Nat.find h else 0

/-
!-- If `p ∣ F a` and `p ∣ F b` then `p ∣ F (gcd a b)`, since `F (gcd a b) = gcd (F a) (F b)`. -- !--
-/
lemma fib_dvd_gcd {p a b : ℕ} (ha : p ∣ Nat.fib a) (hb : p ∣ Nat.fib b) :
    p ∣ Nat.fib (Nat.gcd a b) := by
  exact Nat.dvd_gcd ha hb |> fun h => dvd_trans h ( by simp +decide [ Nat.fib_gcd ] )

/-
!-- The master duality: `p ∣ F n` iff the entry point of `p` divides `n`.  Forward by
minimality of the entry point applied to `F (gcd n (z p)) = gcd (F n) (F (z p))`;
backward by `Nat.fib_dvd`.  Boundary `n = 0` is handled by `0 ∣ n ↔ n = 0`. -- !--
-/
theorem fib_dvd_iff_fibEntry_dvd (p n : ℕ) :
    p ∣ Nat.fib n ↔ fibEntry p ∣ n := by
  constructor;
  · by_cases h : ∃ k, 0 < k ∧ p ∣ Nat.fib k <;> simp_all +decide [ fibEntry ];
    · intro hn
      have h_gcd : p ∣ Nat.fib (Nat.gcd n (Nat.find h)) := by
        exact fib_dvd_gcd hn ( Nat.find_spec h |>.2 );
      contrapose! h_gcd;
      exact fun h' => not_le_of_gt ( Nat.lt_of_le_of_ne ( Nat.le_of_dvd ( Nat.find_spec h |>.1 ) ( Nat.gcd_dvd_right _ _ ) ) fun con => h_gcd <| con.symm ▸ Nat.gcd_dvd_left _ _ ) ( Nat.find_min' h ⟨ Nat.gcd_pos_of_pos_right _ ( Nat.find_spec h |>.1 ), h' ⟩ );
    · cases n <;> aesop;
  · by_cases h : ∃ k, 0 < k ∧ p ∣ Nat.fib k <;> simp_all +decide [ fibEntry ];
    · exact fun hn => Nat.dvd_trans ( Nat.find_spec h |>.2 ) ( Nat.fib_dvd _ _ hn );
    · cases n <;> aesop

/-- `p` is a **primitive prime divisor** of `F n`: a prime dividing `F n` but none of
the earlier (positive index) Fibonacci numbers. -/
def IsFibPrimitiveDivisor (p n : ℕ) : Prop :=
  Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, k < n → 0 < k → ¬ p ∣ Nat.fib k

/-
!-- Primitivity collapses to the single equation `z(p) = n`: a prime dividing `F n`
(with `n > 0`) is primitive iff its entry point is exactly `n`, both directions
via `fib_dvd_iff_fibEntry_dvd`. -- !--
-/
theorem isFibPrimitiveDivisor_iff_entry {p n : ℕ} (hn : 0 < n) :
    IsFibPrimitiveDivisor p n ↔ Nat.Prime p ∧ p ∣ Nat.fib n ∧ fibEntry p = n := by
  constructor <;> intro h;
  · obtain ⟨ hp₁, hp₂, hp₃ ⟩ := h;
    unfold fibEntry;
    split_ifs <;> simp_all +decide [ Nat.find_eq_iff ];
  · refine' ⟨ h.1, h.2.1, fun k hk₁ hk₂ hk₃ => _ ⟩;
    -- By `fib_dvd_iff_fibEntry_dvd`, we have `fibEntry p ∣ k`.
    have h_div : fibEntry p ∣ k := by
      exact fib_dvd_iff_fibEntry_dvd p k |>.1 hk₃;
    linarith [ Nat.le_of_dvd hk₂ h_div ]

/-
!-- The entry point of `F m` is `m` for `m ≥ 3`: `z(F m) ∣ m` by the duality, and
`F (z) = F m` by mutual divisibility forces `z = m` since `fib` is injective on
indices `≥ 3`. -- !--
-/
lemma fibEntry_fib {m : ℕ} (hm : 3 ≤ m) : fibEntry (Nat.fib m) = m := by
  obtain a | a := Nat.eq_zero_or_pos ( Nat.fib m ) <;> simp_all +decide;
  have h_fibEntry : fibEntry (Nat.fib m) ∣ m ∧ Nat.fib (fibEntry (Nat.fib m)) = Nat.fib m := by
    refine' ⟨ fib_dvd_iff_fibEntry_dvd ( Nat.fib m ) m |>.1 ( by simp +decide ), Nat.dvd_antisymm _ _ ⟩;
    · exact Nat.fib_dvd _ _ ( fib_dvd_iff_fibEntry_dvd _ _ |>.1 ( by simp +decide ) );
    · exact fib_dvd_iff_fibEntry_dvd _ _ |>.2 ( dvd_refl _ );
  have h_fibEntry_ge : Nat.fib (fibEntry (Nat.fib m)) ≥ 2 := by
    exact h_fibEntry.2.symm ▸ le_trans ( by decide ) ( Nat.fib_mono hm );
  exact le_antisymm ( Nat.le_of_dvd a h_fibEntry.1 ) ( Nat.le_of_not_lt fun h => by linarith [ Nat.fib_lt_fib_succ ( show 2 ≤ fibEntry ( Nat.fib m ) from le_of_not_gt fun h' => by interval_cases fibEntry ( Nat.fib m ) <;> simp_all +decide ), Nat.fib_mono h ] )

/-
!-- Strong divisibility: `F m ∣ F n ↔ m ∣ n` for `m ≥ 3`, the special case `p = F m`
of the duality together with `fibEntry_fib`. -- !--
-/
theorem fib_dvd_iff {m n : ℕ} (hm : 3 ≤ m) :
    Nat.fib m ∣ Nat.fib n ↔ m ∣ n := by
  convert fib_dvd_iff_fibEntry_dvd ( Nat.fib m ) n using 1;
  rw [ fibEntry_fib hm ]

/-- An explicit table of least primitive prime divisors of `F n` for `n ≤ 40`
(`0` for the exceptional indices `1,2,6,12`). -/
def fibPrimWitness : ℕ → ℕ
  | 3 => 2 | 4 => 3 | 5 => 5 | 7 => 13 | 8 => 7 | 9 => 17 | 10 => 11 | 11 => 89
  | 13 => 233 | 14 => 29 | 15 => 61 | 16 => 47 | 17 => 1597 | 18 => 19 | 19 => 37
  | 20 => 41 | 21 => 421 | 22 => 199 | 23 => 28657 | 24 => 23 | 25 => 3001
  | 26 => 521 | 27 => 53 | 28 => 281 | 29 => 514229 | 30 => 31 | 31 => 557
  | 32 => 2207 | 33 => 19801 | 34 => 3571 | 35 => 141961 | 36 => 107 | 37 => 73
  | 38 => 9349 | 39 => 135721 | 40 => 2161 | _ => 0

/-
!-- Carmichael's primitive-divisor theorem for `1 ≤ n ≤ 40`, `n ∉ {1,2,6,12}`:
the tabulated witness is a primitive divisor in every case (`native_decide`). -- !--
-/
theorem fib_primitive_divisor_verified (n : ℕ) (h1 : 1 ≤ n) (h2 : n ≤ 40)
    (h3 : n ≠ 1) (h4 : n ≠ 2) (h5 : n ≠ 6) (h6 : n ≠ 12) :
    IsFibPrimitiveDivisor (fibPrimWitness n) n := by
  unfold IsFibPrimitiveDivisor fibPrimWitness;
  native_decide +revert

end FibEntryDuality