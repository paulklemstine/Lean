import Mathlib

/-! # The Lucas bridge for the Fibonacci rank of apparition

Domain: Number Theory / Applications (Bridges).

The catalog contains an extensive *entry-point* (rank-of-apparition) theory of the
Fibonacci numbers — the least positive index `α(m)` with `m ∣ F α(m)` — and the
ideal-structure theorem `m ∣ F k ↔ α(m) ∣ k` underlying Carmichael's primitive-divisor
theorem (`Catalog/Applications/RankOfApparition.lean`,
`Catalog/Pythagorean/FibonacciEntryPointCharacterization.lean`,
`Catalog/Novelty/FibonacciEntryPointMultiplicative.lean`,
`Catalog/Shared/CarmichaelProof.lean`).

Every one of those threads is built on the **Fibonacci** sequence alone.  The companion
**Lucas** sequence `L` — `L 0 = 2`, `L 1 = 1`, `L (n+2) = L n + L (n+1)` — is absent from
both Mathlib and the catalog, yet it is the missing half of the apparition story: the
classical *doubling bridge* `F (2n) = F n · L n` factors the even-index Fibonacci
divisibility through `L`, and lets us read off **exactly which Lucas numbers a prime
divides** purely from its Fibonacci rank of apparition.

This file develops that bridge from scratch against Mathlib:

* `fib_two_mul_eq_fib_mul_lucas` — the doubling identity `F (2n) = F n · L n`.
* `lucas_sq_sub_five_fib_sq`     — the fundamental identity `L n ² − 5 F n ² = 4·(−1)ⁿ` (over `ℤ`).
* `gcd_lucas_fib_dvd_two`        — `gcd (L n) (F n) ∣ 2`: Lucas and Fibonacci of equal index
  are coprime away from `2`.
* `exists_pos_dvd_fib`           — every positive modulus has a rank of apparition (pigeonhole).
* `dvd_fib_iff_rank_dvd`         — the ideal-structure theorem, restated self-containedly.
* `prime_dvd_lucas_iff_rank`     — **the marquee result**: for an *odd* prime `p` with rank
  `r = α(p)`,
  `p ∣ L n  ↔  (r ∣ 2n  ∧  ¬ r ∣ n)`.
  Equivalently, `p ∣ L n` iff the largest power of `2` dividing `2n/r`-index condition holds:
  `r ∣ 2n` but `r ∤ n`.  This is the Lucas analogue of the Fibonacci ideal theorem and is new
  to the catalog.

## Catalog synthesis

The entry-point definition and ideal theorem mirror `FibEntryChar.fibEntryPt` /
`fib_dvd_iff_entryPt_dvd` and `RankOfApparition.fibRank` / `fibRank_dvd_iff`, restated here
self-containedly (the catalog import graph is fragmented).  The genuinely new content is the
*Lucas* layer (`lucasNum` and its three identities) and `prime_dvd_lucas_iff_rank`, which the
Fibonacci-only catalog threads could not express.

-- !-- Lab Notebook -- !--
-- !-- Hypothesis: the even-index Fibonacci divisibility `α(p) ∣ 2n` splits, via the doubling
--     identity F(2n)=F n·L n, into a Fibonacci part (α(p) ∣ n) and a Lucas part, so the Lucas
--     apparition set of an odd prime is exactly {n : α(p) ∣ 2n ∧ α(p) ∤ n}. -- !--
-- !-- Result: proved the doubling bridge, the L²−5F²=4(−1)ⁿ identity, gcd(L n,F n)∣2,
--     existence of the rank, the Fibonacci ideal theorem, and the marquee Lucas iff. -- !--
-- !-- Insight: once gcd(L n,F n)∣2 is known, an *odd* prime cannot divide both F n and L n,
--     so primality + the factorization F(2n)=F n·L n turns "p∣L n" into the exact statement
--     "p∣F(2n) ∧ ¬p∣F n", which the ideal theorem translates into pure divisibility of ranks. -- !--
-- !-- Failure analysis: the only Fibonacci-specific inputs are `Nat.fib_gcd`, `Nat.fib_dvd`
--     and `Nat.fib_add_two`; everything else is divisibility/parity algebra in ℕ and ℤ. -- !--
-- !-- End Lab Notebook -- !--
-/

namespace FibLucasBridge

open scoped Classical

/-- The Lucas numbers: `L 0 = 2`, `L 1 = 1`, `L (n+2) = L n + L (n+1)`. -/
def lucasNum : ℕ → ℕ
  | 0 => 2
  | 1 => 1
  | (n + 2) => lucasNum n + lucasNum (n + 1)

@[simp] lemma lucasNum_zero : lucasNum 0 = 2 := rfl
@[simp] lemma lucasNum_one : lucasNum 1 = 1 := rfl
lemma lucasNum_add_two (n : ℕ) : lucasNum (n + 2) = lucasNum n + lucasNum (n + 1) := rfl

/-
!-- L(n+1) = F n + F(n+2): the Lucas number is the sum of the flanking Fibonacci numbers;
two-step induction using the shared recurrence. -- !--
-/
lemma lucasNum_succ_eq (n : ℕ) : lucasNum (n + 1) = Nat.fib n + Nat.fib (n + 2) := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide;
  simp +arith +decide [ *, Nat.fib_add_two, lucasNum_add_two ];
  induction' n with n ih <;> simp_all +arith +decide [ Nat.fib_add_two, lucasNum_add_two ]

/-
!-- Doubling bridge F(2n)=F n·L n: induction comparing F(2n+2)=F(2n)+2F(2n+1) against the
Lucas recurrence, or via `Nat.fib_add` and `lucasNum_succ_eq`. -- !--
-/
theorem fib_two_mul_eq_fib_mul_lucas (n : ℕ) :
    Nat.fib (2 * n) = Nat.fib n * lucasNum n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | _ | n ) <;> simp +arith +decide [ *, Nat.fib_add_two ];
  have := ih n ( by linarith ) ; have := ih ( n + 1 ) ( by linarith ) ; have := ih ( n + 2 ) ( by linarith ) ; simp_all +decide [ Nat.fib_add_two, Nat.mul_succ, lucasNum ] ; ring;
  grind

/-
!-- Fundamental identity L n²−5F n²=4(−1)ⁿ over ℤ: induction on n using the recurrences
and `lucasNum_succ_eq`, with `ring`/`omega` closing each step. -- !--
-/
theorem lucas_sq_sub_five_fib_sq (n : ℕ) :
    (lucasNum n : ℤ) ^ 2 - 5 * (Nat.fib n : ℤ) ^ 2 = 4 * (-1) ^ n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | _ | n ) <;> simp +arith +decide [ *, Nat.fib_add_two ];
  have := ih n ( by linarith ) ; have := ih ( n + 1 ) ( by linarith ) ; have := ih ( n + 2 ) ( by linarith ) ; norm_num [ Nat.fib_add_two, lucasNum_add_two, pow_succ' ] at * ; linarith;

/-
!-- gcd(L n,F n)∣2: any common divisor d divides L n²−5F n² = ±4 and also (over the
relevant 2-adic structure) divides 2; deduce from the fundamental identity that
d∣4 together with the recurrence forces d∣2. -- !--
-/
theorem gcd_lucas_fib_dvd_two (n : ℕ) : Nat.gcd (lucasNum n) (Nat.fib n) ∣ 2 := by
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ lucasNum_succ_eq ];
  simp +arith +decide [ Nat.fib_add_two ];
  norm_num [ ( by ring : Nat.fib n + 3 * Nat.fib ( n + 1 ) = Nat.fib n + Nat.fib ( n + 1 ) + 2 * Nat.fib ( n + 1 ) ) ];
  -- Since $\gcd(F_n, F_{n+1}) = 1$, it follows that $\gcd(2F_{n+1}, F_n + F_{n+1}) = \gcd(2, F_n + F_{n+1})$.
  have h_gcd : Nat.gcd (2 * Nat.fib (n + 1)) (Nat.fib n + Nat.fib (n + 1)) = Nat.gcd 2 (Nat.fib n + Nat.fib (n + 1)) := by
    apply_mod_cast Nat.Coprime.gcd_mul_right_cancel _;
    simpa using Nat.coprime_comm.mp ( Nat.fib_coprime_fib_succ n );
  exact h_gcd.symm ▸ Nat.gcd_dvd_left _ _

/-! ## Rank of apparition (restated self-containedly) -/

/-- `m` has a rank of apparition. -/
def HasRank (m : ℕ) : Prop := ∃ k, 0 < k ∧ m ∣ Nat.fib k

/-- The rank of apparition of `m`: least `k > 0` with `m ∣ F k`, else `0`. -/
noncomputable def rank (m : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ m ∣ Nat.fib k then Nat.find h else 0

/-
!-- Existence of the rank: the Fibonacci pair sequence (F k, F(k+1)) mod m is eventually
periodic by pigeonhole on the finite type (ZMod m)×(ZMod m), and reversibility of the
shift forces it to return to (0,1), giving m ∣ F k for some k>0. -- !--
-/
theorem exists_pos_dvd_fib (m : ℕ) (hm : 0 < m) : ∃ k, 0 < k ∧ m ∣ Nat.fib k := by
  by_contra h_contra;
  -- Consider the sequence of pairs (F_k, F_{k+1}) modulo m. Since there are only m^2 possible pairs, this sequence must eventually repeat.
  have h_pair_seq : ∃ i j, i < j ∧ (Nat.fib i % m, Nat.fib (i + 1) % m) = (Nat.fib j % m, Nat.fib (j + 1) % m) := by
    by_contra h_contra;
    exact absurd ( Set.infinite_range_of_injective ( fun i j hij => le_antisymm ( not_lt.1 fun hi => h_contra ⟨ j, i, hi, hij.symm ⟩ ) ( not_lt.1 fun hj => h_contra ⟨ i, j, hj, hij ⟩ ) ) ) ( Set.not_infinite.mpr <| Set.finite_iff_bddAbove.mpr ⟨ ( m, m ), by rintro a ⟨ i, rfl ⟩ ; exact ⟨ Nat.le_of_lt <| Nat.mod_lt _ hm, Nat.le_of_lt <| Nat.mod_lt _ hm ⟩ ⟩ );
  obtain ⟨ i, j, hij, h ⟩ := h_pair_seq;
  induction' i with i ih generalizing j;
  · exact h_contra ⟨ j, hij, Nat.dvd_of_mod_eq_zero ( by simpa using congr_arg Prod.fst h.symm ) ⟩;
  · rcases j <;> simp_all +decide [ Nat.fib_add_two ];
    simp_all +decide [ ← ZMod.natCast_eq_natCast_iff' ];
    grind

lemma rank_pos (m : ℕ) (h : HasRank m) : 0 < rank m := by
  obtain ⟨ k, hk ⟩ := h;
  unfold rank;
  split_ifs <;> aesop

lemma dvd_fib_rank (m : ℕ) (h : HasRank m) : m ∣ Nat.fib (rank m) := by
  -- By definition of rank, m divides F(rank m) since rank m is the smallest positive integer k for which m divides F k.
  have h_rank : m ∣ Nat.fib (Nat.find h) := by
    exact Nat.find_spec h |>.2;
  unfold rank; aesop;

/-
!-- The ideal-structure theorem m∣F k ↔ rank m ∣ k: (←) is `Nat.fib_dvd`; (→) uses
`Nat.fib_gcd` so m∣F(gcd(rank m,k)) and minimality forces gcd=rank m, i.e. rank m∣k. -- !--
-/
theorem dvd_fib_iff_rank_dvd (m k : ℕ) (h : HasRank m) :
    m ∣ Nat.fib k ↔ rank m ∣ k := by
  -- By definition of rank, if m divides k, then m divides the gcd of such k's, which is r.
  have h_rank_div : ∀ k, m ∣ Nat.fib k → rank m ∣ k := by
    -- By definition of rank, if m divides k, then m divides the gcd of such k's, which is r. Use this fact.
    intros k hk
    have h_gcd : m ∣ Nat.fib (Nat.gcd (rank m) k) := by
      convert Nat.dvd_gcd ( dvd_fib_rank m h ) hk using 1;
      exact Nat.fib_gcd (rank m) k;
    have h_min : ∀ k, 0 < k → m ∣ Nat.fib k → rank m ≤ k := by
      unfold rank; aesop;;
    contrapose! h_min;
    exact ⟨ Nat.gcd ( rank m ) k, Nat.gcd_pos_of_pos_left _ ( rank_pos m h ), h_gcd, lt_of_le_of_ne ( Nat.le_of_dvd ( rank_pos m h ) ( Nat.gcd_dvd_left _ _ ) ) fun con => h_min <| con.symm ▸ Nat.gcd_dvd_right _ _ ⟩;
  refine' ⟨ h_rank_div k, fun hk => _ ⟩;
  exact dvd_trans ( dvd_fib_rank m h ) ( by obtain ⟨ c, rfl ⟩ := hk; simpa [ Nat.fib_dvd ] )

/-! ## The marquee Lucas bridge -/

/-
!-- Odd prime cannot divide both F n and L n: gcd(L n,F n)∣2 and p odd would give p∣2. -- !--
-/
lemma odd_prime_not_dvd_fib_and_lucas (p n : ℕ) (hp : p.Prime) (hodd : Odd p)
    (hfib : p ∣ Nat.fib n) : ¬ p ∣ lucasNum n := by
  -- Any common divisor d of F n and L n divides F n and L n, hence d | gcd (lucasNum n) (fib n).
  intro hdiv
  have hdiv_gcd : p ∣ Nat.gcd (lucasNum n) (Nat.fib n) := by
    exact Nat.dvd_gcd hdiv hfib;
  have := Nat.dvd_trans hdiv_gcd ( gcd_lucas_fib_dvd_two n ) ; simp_all +decide [ Nat.prime_dvd_prime_iff_eq ] ;

/-
!-- p∣L n ↔ (p∣F(2n) ∧ ¬p∣F n) for odd prime p: factor F(2n)=F n·L n. (→) p∣L n gives
p∣F(2n), and ¬p∣F n by the previous lemma. (←) p prime divides F n·L n but not F n,
hence divides L n. -- !--
-/
lemma prime_dvd_lucas_iff_fib (p n : ℕ) (hp : p.Prime) (hodd : Odd p) :
    p ∣ lucasNum n ↔ (p ∣ Nat.fib (2 * n) ∧ ¬ p ∣ Nat.fib n) := by
  have h_eq := fib_two_mul_eq_fib_mul_lucas n; simp_all +decide [ Nat.Prime.dvd_mul ] ;
  exact ⟨ fun h => ⟨ Or.inr h, fun h' => odd_prime_not_dvd_fib_and_lucas p n hp hodd h' h ⟩, fun h => h.1.resolve_left h.2 ⟩

/-
**Marquee theorem.**  For an odd prime `p` with rank of apparition `r = rank p`,
the prime divides the `n`-th Lucas number exactly when `r ∣ 2n` but `r ∤ n`.
-/
theorem prime_dvd_lucas_iff_rank (p n : ℕ) (hp : p.Prime) (hodd : Odd p) :
    p ∣ lucasNum n ↔ (rank p ∣ 2 * n ∧ ¬ rank p ∣ n) := by
  convert prime_dvd_lucas_iff_fib p n hp hodd using 1;
  have hHR : HasRank p := ?_;
  · rw [ dvd_fib_iff_rank_dvd p ( 2 * n ) hHR, dvd_fib_iff_rank_dvd p n hHR ];
  · exact exists_pos_dvd_fib p hp.pos

end FibLucasBridge