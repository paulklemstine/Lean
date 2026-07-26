import Mathlib

/-! # The rank of apparition as the spine of Fibonacci primitive-divisor theory

Domain: Number Theory / Applications (Bridges).

The *rank of apparition* (Fibonacci entry point) of a modulus `m` is the least positive
index `k` with `m ∣ F k`.  The catalog already contains several **parallel** developments of
this object, each turning on the same biconditional `m ∣ F n ↔ rank ∣ n`:

* `Catalog/Novelty/FibApparitionExistence.lean`
  (`FibApparition.apparitionRank`, `fib_apparition_exists`, `fib_dvd_iff_apparitionRank_dvd`);
* `Catalog/Applications/FibonacciEntryPoints.lean`
  (`FibonacciEntryPoints.entryPoint`, `dvd_fib_iff_entry_dvd`, `primitive_iff_entry_eq`);
* `Catalog/Applications/FibonacciApparitionLattice.lean`
  (`fibEntry_lcm`, `fibEntry_monotone`, `fibEntry_gcd_dvd`);
* `Catalog/Applications/FibonacciPrimitiveDivisors.lean`
  (`dvd_fib_iff_index_dvd_of_primitive`, `simultaneous_apparition`);
* `Catalog/Applications/StrongDivisibilitySequences.lean`
  (`IsStrongDivSeq`, `dvd_iff_index_dvd_of_primitive`, `apparition_count`);
* `Catalog/Algebra/Tropical_p_adic_..._Fibonacci_Primitive_Divisors.lean`
  (`fib_prime_has_primitive` for primes `p ≥ 5`).

This file is **self-contained against Mathlib** (the catalog's `import` graph is currently
fragmented, so we restate the short existence/biconditional core rather than depend on a
non-default build target), and it adds the results the parallel threads were missing:

* `fibRank_fib`            — *new*: `fibRank (F k) = k` for `k ≥ 3`.  The rank pins the
  Fibonacci values **exactly**; not present anywhere in the catalog or in Mathlib.
* `fib_dvd_fib_iff`        — *new corollary*: `F a ∣ F b ↔ a ∣ b` for `a ≥ 3`.  Mathlib has
  only the forward implication `Nat.fib_dvd`; the biconditional is absent (`exact?` fails).
* `fib_prime_index_has_primitive` — Carmichael's prime case for **all** primes `p ≥ 3`
  (the catalog's `fib_prime_has_primitive` requires `p ≥ 5`), derived in a few lines from the
  spine: the chosen prime divisor of `F p` has rank exactly `p`.
* `fibRank_dvd_of_dvd`     — the order-morphism law packaged with existence:
  `b ∣ a → 0 < a → fibRank b ∣ fibRank a`.

The reusable core (`hasFibRank_of_pos`, `fibRank_dvd_iff`) is stated *without* any
primitivity hypothesis, generalizing `FibonacciPrimitiveDivisors.dvd_fib_iff_index_dvd_of_primitive`.
-/

namespace RankOfApparition

open scoped Classical

/-- `m` *has a rank of apparition* if it divides some positive-index Fibonacci number. -/
def HasFibRank (m : ℕ) : Prop := ∃ k, 0 < k ∧ m ∣ Nat.fib k

/-! ## §0. Existence of the rank (pigeonhole on the Fibonacci shift) -/

/-- The Fibonacci "shift" permutation on pairs over `ZMod m`: `(a, b) ↦ (b, a + b)`,
with inverse `(a, b) ↦ (b - a, a)`.  Its reversibility is the reason apparition occurs. -/
def fibStep (m : ℕ) : ZMod m × ZMod m ≃ ZMod m × ZMod m where
  toFun p := (p.2, p.1 + p.2)
  invFun p := (p.2 - p.1, p.1)
  left_inv := by intro p; simp
  right_inv := by intro p; simp [add_comm]

-- !-- Iterating the shift from `(0,1)` yields consecutive Fibonacci pairs; induction on `k`
-- using `F (k+2) = F k + F (k+1)`. -- !--
theorem fibStep_iterate (m k : ℕ) :
    (fibStep m)^[k] (0, 1) = ((Nat.fib k : ZMod m), (Nat.fib (k + 1) : ZMod m)) := by
  induction k <;> simp_all +decide [ Function.iterate_succ_apply' ];
  simp +decide [ fibStep, Nat.fib_add_two ]

/-
!-- Lab Notebook: hasFibRank_of_pos -- !--
!-- Hypothesis: Every positive modulus has a rank of apparition (apparition is total). -- !--
!-- Result: Proved by pigeonhole on the finite set `(ZMod m)²`: two indices `i < j` share
the pair `(F·, F·₊₁) mod m`; back-stepping `i` to `0` via the reversible shift produces a
positive `k = j - i` with `m ∣ F k`. -- !--
!-- Insight: Reversibility of the Fibonacci shift (a unit determinant matrix over `ZMod m`)
is the abstract Pisano-period mechanism; Mathlib has no Pisano theory, so this is built here. -- !--
!-- Failure analysis: the `m = 0` degenerate `ZMod` case must be split off (`cases m`). -- !--
!-- End Lab Notebook -- !--
-/
theorem hasFibRank_of_pos (m : ℕ) (hm : 0 < m) : HasFibRank m := by
  obtain ⟨i, j, hij, h_pair⟩ :
      ∃ i j : ℕ, i < j ∧
        ((Nat.fib i : ZMod m) = (Nat.fib j : ZMod m) ∧
          (Nat.fib (i + 1) : ZMod m) = (Nat.fib (j + 1) : ZMod m)) := by
    have h_pigeonhole :
        ∃ i j : ℕ, i < j ∧
          ((Nat.fib i : ZMod m), (Nat.fib (i + 1) : ZMod m))
            = ((Nat.fib j : ZMod m), (Nat.fib (j + 1) : ZMod m)) := by
      by_contra! h
      have h_finite :
          Set.Finite (Set.range
            (fun n : ℕ => ((Nat.fib n : ZMod m), (Nat.fib (n + 1) : ZMod m)))) := by
        cases m <;> [ aesop; exact Set.toFinite _ ]
      exact h_finite.not_infinite <| Set.infinite_range_of_injective fun i j hij =>
        le_antisymm (le_of_not_gt fun hi => h _ _ hi hij.symm)
          (le_of_not_gt fun hj => h _ _ hj hij)
    aesop
  induction' i with i ih generalizing j
  · exact ⟨ j, hij, by simpa [ ← ZMod.natCast_eq_zero_iff ] using h_pair.1.symm ⟩
  · specialize ih ( j - 1 ) ( Nat.lt_pred_iff.mpr hij )
    rcases j <;> simp_all +decide [ Nat.fib_add_two ]
    grind

/-! ## §1. The rank function and its defining properties -/

/-- The Fibonacci rank of apparition of `m`: the least positive `k` with `m ∣ F k`
(or `0` if none exists; for `m ≥ 1` existence is `hasFibRank_of_pos`). -/
noncomputable def fibRank (m : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ m ∣ Nat.fib k then Nat.find h else 0

theorem fibRank_pos {m : ℕ} (hm : HasFibRank m) : 0 < fibRank m := by
  unfold fibRank; split_ifs with h
  · exact (Nat.find_spec h).1
  · exact absurd hm h

theorem dvd_fib_fibRank {m : ℕ} (hm : HasFibRank m) : m ∣ Nat.fib (fibRank m) := by
  unfold fibRank; split_ifs with h
  · exact (Nat.find_spec h).2
  · exact absurd hm h

theorem fibRank_min {m k : ℕ} (hk : 0 < k) (hlt : k < fibRank m) : ¬ m ∣ Nat.fib k := by
  unfold fibRank at hlt; split_ifs at hlt with h
  · exact fun hd => Nat.find_min h hlt ⟨hk, hd⟩
  · simp at hlt

/-! ## §2. The spine: `m ∣ F n ↔ fibRank m ∣ n` -/

/-
!-- Lab Notebook: fibRank_dvd_iff -- !--
!-- Hypothesis: For any modulus with a rank, `m ∣ F n ↔ fibRank m ∣ n`. -- !--
!-- Result: Proved with NO primitivity hypothesis (generalizing the catalog's
`dvd_fib_iff_index_dvd_of_primitive`). (←) `fibRank m ∣ n → F (fibRank m) ∣ F n` (`Nat.fib_dvd`)
and `m ∣ F (fibRank m)`. (→) push `m` into `F (gcd (fibRank m) n) = gcd (F …) (F n)`
(`Nat.fib_gcd`); minimality of the rank forces `gcd (fibRank m) n = fibRank m`, i.e. divisibility. -- !--
!-- Insight: This single biconditional is the load-bearing fact behind every parallel
apparition thread in the catalog; dropping primitivity makes it the genuine spine. -- !--
!-- Failure analysis: needs `HasFibRank m` so the rank is positive; for `m = 0` it is vacuous. -- !--
!-- End Lab Notebook -- !--
-/
theorem fibRank_dvd_iff {m : ℕ} (hm : HasFibRank m) (n : ℕ) :
    m ∣ Nat.fib n ↔ fibRank m ∣ n := by
  have hz : 0 < fibRank m := fibRank_pos hm
  have hmz : m ∣ Nat.fib (fibRank m) := dvd_fib_fibRank hm
  constructor <;> intro hn
  · contrapose! hn
    have hgcd_lt : Nat.gcd (fibRank m) n < fibRank m :=
      lt_of_le_of_ne (Nat.le_of_dvd hz (Nat.gcd_dvd_left _ _))
        (fun h => hn (h ▸ Nat.gcd_dvd_right _ _))
    refine fun hcontra => fibRank_min (Nat.gcd_pos_of_pos_left _ hz) hgcd_lt ?_
    have := Nat.dvd_gcd hmz hcontra
    simpa [Nat.fib_gcd] using this
  · obtain ⟨k, rfl⟩ := hn
    exact dvd_trans hmz (Nat.fib_dvd _ _ ⟨k, rfl⟩)

/-! ## §3. Order-morphism law (with existence) -/

/-
!-- Lab Notebook: fibRank_dvd_of_dvd -- !--
!-- Hypothesis: `fibRank` is an order morphism of divisibility posets:
`b ∣ a → fibRank b ∣ fibRank a` (for `a > 0`). -- !--
!-- Result: Proved from the spine: `b ∣ a ∣ F (fibRank a)`, so `b ∣ F (fibRank a)`, and the
spine for `b` gives `fibRank b ∣ fibRank a`. -- !--
!-- Insight: Packages monotonicity together with existence of the rank of the divisor, so it
needs no positivity side-condition on `b` (it follows from `b ∣ a`, `0 < a`). -- !--
!-- Failure analysis: requires `0 < a` so that `a` (hence `b`) has a rank. -- !--
!-- End Lab Notebook -- !--
-/
theorem fibRank_dvd_of_dvd {a b : ℕ} (ha : 0 < a) (hab : b ∣ a) :
    fibRank b ∣ fibRank a := by
  have hb : 0 < b := Nat.pos_of_dvd_of_pos hab ha
  have hrb : HasFibRank b := hasFibRank_of_pos b hb
  have hra : HasFibRank a := hasFibRank_of_pos a ha
  have hbdvd : b ∣ Nat.fib (fibRank a) := dvd_trans hab (dvd_fib_fibRank hra)
  exact (fibRank_dvd_iff hrb (fibRank a)).1 hbdvd

/-! ## §4. The rank pins Fibonacci values exactly: `fibRank (F k) = k` -/

/-
!-- Lab Notebook: fibRank_fib -- !--
!-- Hypothesis: `fibRank (F k) = k` for `k ≥ 3`: a Fibonacci number's rank is its own index. -- !--
!-- Result: Proved via `Nat.find_eq_iff`: `F k ∣ F k` trivially, and for `0 < j < k` we have
`0 < F j < F k` (strict monotonicity `Nat.fib_strictMonoOn` for `j ≥ 2`, and `F 1 = F 2 = 1`
for small `j`), so `F k ∤ F j`. -- !--
!-- Insight: The rank labelling is injective on the Fibonacci numbers themselves — the
sharpest possible rigidity, absent from every catalog thread. -- !--
!-- Failure analysis: `k = 1, 2` give `F 1 = F 2 = 1` with rank `1 ≠ k`, so `k ≥ 3` is sharp. -- !--
!-- End Lab Notebook -- !--
-/
theorem fibRank_fib {k : ℕ} (hk : 3 ≤ k) : fibRank (Nat.fib k) = k := by
  unfold fibRank;
  split_ifs <;> simp_all +decide [ Nat.find_eq_iff ];
  · refine' ⟨ by linarith, fun n hn hn' h => _ ⟩;
    exact absurd h ( Nat.not_dvd_of_pos_of_lt ( Nat.fib_pos.mpr hn' ) ( by rw [ Nat.fib_lt_fib ] <;> linarith [ show n > 1 from lt_of_le_of_ne hn' ( Ne.symm <| by rintro rfl; have := Nat.fib_mono hk; norm_num at * ; linarith [ Nat.fib_pos.mpr ( by linarith : 0 < k ) ] ) ] ) );
  · exact absurd ( ‹∀ x : ℕ, 0 < x → ¬Nat.fib k ∣ Nat.fib x› k ( by linarith ) ) ( by norm_num )

/-! ## §5. New corollary: the Fibonacci divisibility biconditional -/

/-
!-- Lab Notebook: fib_dvd_fib_iff -- !--
!-- Hypothesis: `F a ∣ F b ↔ a ∣ b` for `a ≥ 3` (Mathlib has only the forward `Nat.fib_dvd`). -- !--
!-- Result: Proved from `fibRank_fib` + spine: `F a ∣ F b ↔ fibRank (F a) ∣ b ↔ a ∣ b`. -- !--
!-- Insight: The spine converts a statement about Fibonacci numbers into a statement about
their indices, instantly upgrading `Nat.fib_dvd` to a biconditional. -- !--
!-- Failure analysis: `a = 1, 2` break it (`F 1 = F 2 = 1` divides everything), so `a ≥ 3`. -- !--
!-- End Lab Notebook -- !--
-/
theorem fib_dvd_fib_iff {a b : ℕ} (ha : 3 ≤ a) : Nat.fib a ∣ Nat.fib b ↔ a ∣ b := by
  have := fibRank_dvd_iff ( show HasFibRank ( Nat.fib a ) from ⟨ a, by linarith, dvd_rfl ⟩ ) b; simp_all +decide [ fibRank_fib ] ;

/-! ## §6. Carmichael's prime case for all primes `p ≥ 3` -/

/-- `q` is a *primitive divisor* of `F n`: it divides `F n` but no earlier positive-index
Fibonacci number. -/
def IsPrimitive (q n : ℕ) : Prop :=
  q ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬ q ∣ Nat.fib k

/-
!-- Lab Notebook: fib_prime_index_has_primitive -- !--
!-- Hypothesis: For every prime `p ≥ 3`, `F p` has a primitive prime divisor (Carmichael's
prime case), with the catalog's `p ≥ 5` restriction removed. -- !--
!-- Result: Proved from the spine. Take a prime divisor `q` of `F p` (which exists since
`F p ≠ 1`); it has a rank dividing `p` (spine, `q ∣ F p`). The rank is not `1` (else `q ∣ F 1 = 1`), and `p` is
prime, so the rank equals `p`; hence `q ∤ F k` for every `0 < k < p`. -- !--
!-- Insight: Primitivity at the prime index is forced purely by the rank dividing a prime —
no growth estimates, unlike the composite case. -- !--
!-- Failure analysis: `p = 3` gives `F 3 = 2`, primitive divisor `2`; the bound is sharp since
`F 1 = F 2 = 1` have no prime divisor. -- !--
!-- End Lab Notebook -- !--
-/
theorem fib_prime_index_has_primitive {p : ℕ} (hp : Nat.Prime p) (hp3 : 3 ≤ p) :
    ∃ q, Nat.Prime q ∧ IsPrimitive q p := by
  -- By the spine, `q` has a rank dividing `p`.
  obtain ⟨q, hq_prime, hqdvd⟩ : ∃ q, Nat.Prime q ∧ q ∣ Nat.fib p := by
    exact Nat.exists_prime_and_dvd ( by linarith [ Nat.le_fib_add_one p ] )
  have hq_rank : fibRank q ∣ p := by
    exact fibRank_dvd_iff ( show HasFibRank q from ⟨ p, by linarith, hqdvd ⟩ ) p |>.1 hqdvd;
  -- Since `p` is prime, `fibRank q` must be either `1` or `p`.
  have hq_rank_cases : fibRank q = 1 ∨ fibRank q = p := by
    rwa [ Nat.dvd_prime hp ] at hq_rank;
  cases hq_rank_cases <;> simp_all +decide [ IsPrimitive ];
  · have := dvd_fib_fibRank ( show HasFibRank q from by
                                exact ⟨ p, by linarith, hqdvd ⟩ ) ; simp_all +decide [ Nat.fib_one ];
  · exact ⟨ q, hq_prime, hqdvd, fun k hk hk' hk'' => by have := fibRank_min ( show 0 < k from hk ) ( by linarith ) hk''; aesop ⟩

end RankOfApparition