import Mathlib

/-! # The Fibonacci rank of apparition as a local-to-global sheaf

Domain: Number Theory / Applications (Duality & Representation).

The *rank of apparition* `rank m = fibRank m` of a modulus `m` is the least positive index
`k` with `m ∣ F k`.  This file develops `rank` as a **local-to-global section** over the
divisibility site of moduli.

Following the catalog convention (`Catalog/Applications/RankOfApparition.lean`,
`Catalog/Novelty/FibApparitionExistence.lean`), the file is **self-contained against Mathlib**:
the short existence/biconditional *spine* (`fibStep`, `hasFibRank_of_pos`, `fibRank`,
`fibRank_dvd_iff`, `IsPrimitive`) is restated here, and the genuinely new layer is built on
top of it.  The four headline results are:

* `fib_dvd_iff_fibRank_dvd` — the **law of apparition** `m ∣ F n ↔ rank m ∣ n` (for `m > 0`),
  the global/local dictionary that drives everything else.
* `isPrimitive_iff_fibRank_eq` — the **Carmichael bridge / stalk condition**: `m` is a
  primitive divisor of `F n` iff `rank m = n`.  Primitivity *is* rank-maximality; this turns
  the global primitive-divisor statement into a purely local condition on a single stalk.
  (Compare `Shared.CarmichaelProof.bridge_lemma`, the global avoidance form.)
* `fibRank_mul_coprime` — **CRT gluing of stalks**: `rank (a*b) = lcm (rank a, rank b)` for
  coprime `a, b`.  (Compare `FibonacciApparitionLattice.fibEntry_lcm`, the join law in the
  parallel `fibEntry` thread.)
* `fibRank_eq_factorization_lcm` — the **full local-to-global reconstruction**:
  `rank n = lcm_{p ∈ supp n} rank (p ^ v_p n)`.  The global rank is the section glued from the
  prime-power stalk ranks; this strictly generalises the binary gluing law.

The unifying principle is *duality*: `rank` is the dictionary between the divisibility lattice
of **moduli** and the divisibility lattice of **indices**; it is an exact join-morphism
(lcm ↦ lcm), and the prime-power decomposition reconstructs the global section from local
stalks.
-/

namespace FibonacciApparitionSheaf

open scoped Classical

/-! ## §0. The spine (restated self-contained against Mathlib) -/

/-- `m` *has a rank of apparition* if it divides some positive-index Fibonacci number. -/
def HasFibRank (m : ℕ) : Prop := ∃ k, 0 < k ∧ m ∣ Nat.fib k

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
  induction k <;> simp_all +decide [ Function.iterate_succ_apply' ]
  simp +decide [ fibStep, Nat.fib_add_two ]

/-
!-- Lab Notebook: hasFibRank_of_pos -- !--
!-- Hypothesis: Every positive modulus has a rank of apparition (apparition is total). -- !--
!-- Result: Pigeonhole on the finite set `(ZMod m)²`: two indices `i < j` share the pair
`(F·, F·₊₁) mod m`; back-stepping `i` to `0` via the reversible shift gives a positive
`k = j - i` with `m ∣ F k`. -- !--
!-- Insight: Reversibility of the Fibonacci shift (a unit-determinant matrix over `ZMod m`) is
the abstract Pisano-period mechanism; Mathlib has no Pisano theory, so this is built here. -- !--
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

/-- The reusable core biconditional (no primitivity hypothesis): `m ∣ F n ↔ rank m ∣ n`. -/
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

/-- `q` is a *primitive divisor* of `F n`: it divides `F n` but no earlier positive-index
Fibonacci number. -/
def IsPrimitive (q n : ℕ) : Prop :=
  q ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬ q ∣ Nat.fib k

/-- Two naturals that are divisibility-equivalent (`d ∣ k ↔ e ∣ k` for all `k`) coincide. -/
-- !-- Apply the equivalence at `k = e` and `k = d` and use antisymmetry of `∣`. -- !--
lemma nat_eq_of_dvd_iff {d e : ℕ} (h : ∀ k, d ∣ k ↔ e ∣ k) : d = e :=
  Nat.dvd_antisymm ((h e).mpr dvd_rfl) ((h d).mp dvd_rfl)

/-! ## §1. The law of apparition -/

/-
!-- Lab Notebook: fib_dvd_iff_fibRank_dvd -- !--
!-- Hypothesis: For every `m > 0`, `m ∣ F n ↔ rank m ∣ n`. -- !--
!-- Result: Immediate from `fibRank_dvd_iff` once existence of the rank is supplied
unconditionally by `hasFibRank_of_pos`. -- !--
!-- Insight: This is the global/local dictionary — the single fact through which every later
gluing law is proved. -- !--
!-- Failure analysis: needs `0 < m` so the modulus actually has a rank. -- !--
!-- End Lab Notebook -- !--
-/
/-- **Law of apparition.** For `m > 0`, `m ∣ F n ↔ rank m ∣ n`. -/
theorem fib_dvd_iff_fibRank_dvd {m : ℕ} (hm : 0 < m) (n : ℕ) :
    m ∣ Nat.fib n ↔ fibRank m ∣ n :=
  fibRank_dvd_iff (hasFibRank_of_pos m hm) n

/-! ## §2. The Carmichael bridge: primitivity is rank-maximality -/

/-
!-- Lab Notebook: isPrimitive_iff_fibRank_eq -- !--
!-- Hypothesis: `m` is a primitive divisor of `F n` iff `rank m = n` (for `m, n > 0`). -- !--
!-- Result: (→) primitivity gives `m ∣ F n`, so `rank m ∣ n` (law of apparition) hence
`rank m ≤ n`; if `rank m < n` then `m ∣ F (rank m)` at a smaller positive index contradicts
primitivity, so `rank m = n`. (←) `rank m = n` gives `m ∣ F n` by `dvd_fib_fibRank`, and
`fibRank_min` rules out every earlier positive index. -- !--
!-- Insight: Primitivity, a global avoidance condition over all earlier indices, collapses to
the single local equation `rank m = n` — the stalk-level reformulation of Carmichael. -- !--
!-- Failure analysis: needs `0 < n` to convert `rank m ∣ n` into `rank m ≤ n`. -- !--
!-- End Lab Notebook -- !--

**Carmichael bridge.** For `m, n > 0`, `m` is a primitive divisor of `F n` iff its rank of
apparition equals `n`.
-/
theorem isPrimitive_iff_fibRank_eq {m n : ℕ} (hm : 0 < m) (hn : 0 < n) :
    IsPrimitive m n ↔ fibRank m = n := by
  constructor <;> intro h;
  · -- From `m ∣ Nat.fib n` and `hasFibRank_of_pos m hm`, the law `fibRank_dvd_iff` gives `fibRank m ∣ n`, so `fibRank m ≤ n`.
    have h_le : fibRank m ∣ n := by
      exact fib_dvd_iff_fibRank_dvd hm n |>.1 h.1;
    exact le_antisymm ( Nat.le_of_dvd hn h_le ) ( Nat.le_of_not_lt fun h_lt => h.2 _ ( fibRank_pos ( hasFibRank_of_pos m hm ) ) h_lt ( dvd_fib_fibRank ( hasFibRank_of_pos m hm ) ) );
  · exact ⟨ h ▸ dvd_fib_fibRank ( hasFibRank_of_pos m hm ), fun k hk₁ hk₂ hk₃ => fibRank_min hk₁ ( h ▸ hk₂ ) hk₃ ⟩

/-! ## §3. CRT gluing of stalks: the coprime product law -/

/-
!-- Lab Notebook: fibRank_mul_coprime -- !--
!-- Hypothesis: For coprime `a, b > 0`, `rank (a*b) = lcm (rank a, rank b)`. -- !--
!-- Result: Both sides have the same divisor set `k`. For each `k`:
`a*b ∣ F k ↔ a ∣ F k ∧ b ∣ F k` (coprimality) `↔ rank a ∣ k ∧ rank b ∣ k` (law of apparition)
`↔ lcm (rank a) (rank b) ∣ k` (`Nat.lcm_dvd_iff`); while `a*b ∣ F k ↔ rank (a*b) ∣ k`.
Divisibility-equivalence (`nat_eq_of_dvd_iff`) gives equality. -- !--
!-- Insight: CRT factors the stalk at `a*b` into independent stalks at `a` and `b`, and the
join law glues them via lcm — exact, unlike the meet (gcd) direction. -- !--
!-- Failure analysis: coprimality is essential to split `a*b ∣ F k`; without it only `∣` holds. -- !--
!-- End Lab Notebook -- !--

**Coprime gluing.** For coprime `a, b > 0`, `rank (a*b) = lcm (rank a, rank b)`.
-/
theorem fibRank_mul_coprime {a b : ℕ} (ha : 0 < a) (hb : 0 < b) (hab : Nat.Coprime a b) :
    fibRank (a * b) = Nat.lcm (fibRank a) (fibRank b) := by
  apply nat_eq_of_dvd_iff;
  intro k;
  rw [ Nat.lcm_dvd_iff ];
  rw [ ← fib_dvd_iff_fibRank_dvd ( Nat.mul_pos ha hb ) k, ← fib_dvd_iff_fibRank_dvd ha k, ← fib_dvd_iff_fibRank_dvd hb k ];
  exact ⟨ fun h => ⟨ dvd_of_mul_right_dvd h, dvd_of_mul_left_dvd h ⟩, fun h => Nat.Coprime.mul_dvd_of_dvd_of_dvd hab h.1 h.2 ⟩

/-! ## §4. The local-to-global reconstruction -/

/-
!-- Lab Notebook: fibRank_finset_prod_coprime -- !--
!-- Hypothesis: For a finite family of pairwise-coprime positive `f i`,
`rank (∏ i, f i) = lcm_i (rank (f i))`. -- !--
!-- Result: Induct on the finset. The base (empty product `= 1`) gives `rank 1 = 1` and the
empty `Finset.lcm = 1`; the inductive step inserts `a`, uses `Nat.Coprime.prod_right` so that
`f a` is coprime to `∏ rest`, then applies `fibRank_mul_coprime` and `Finset.lcm_insert`. -- !--
!-- Insight: The binary CRT gluing iterates to an arbitrary coprime decomposition — the sheaf
section over a product is the lcm of the sections over the factors. -- !--
!-- Failure analysis: pairwise coprimality (not just coprimality of the inserted element) is
needed so the induction hypothesis applies to the remaining product. -- !--
!-- End Lab Notebook -- !--

Coprime gluing over a finite family: `rank (∏ f) = Finset.lcm (rank ∘ f)`.
-/
theorem fibRank_finset_prod_coprime {ι : Type*} (s : Finset ι) (f : ι → ℕ)
    (hpos : ∀ i ∈ s, 0 < f i)
    (hcop : (s : Set ι).Pairwise (fun i j => Nat.Coprime (f i) (f j))) :
    fibRank (∏ i ∈ s, f i) = s.lcm (fun i => fibRank (f i)) := by
  induction' s using Finset.induction with i s hi ih;
  · unfold fibRank; simp +decide ;
    split_ifs <;> simp_all +decide [ Nat.find_eq_iff ];
    cases ‹∀ x : ℕ, x = 0› 1;
  · rw [ Finset.prod_insert hi, Finset.lcm_insert ];
    rw [ ← ih ( fun j hj => hpos j ( Finset.mem_insert_of_mem hj ) ) ( fun j hj k hk hjk => hcop ( Finset.mem_insert_of_mem hj ) ( Finset.mem_insert_of_mem hk ) hjk ), fibRank_mul_coprime ];
    · rfl;
    · exact hpos i ( Finset.mem_insert_self _ _ );
    · exact Finset.prod_pos fun x hx => hpos x ( Finset.mem_insert_of_mem hx );
    · exact Nat.Coprime.prod_right fun j hj => hcop ( Finset.mem_insert_self _ _ ) ( Finset.mem_insert_of_mem hj ) ( by aesop )

/-
!-- Lab Notebook: fibRank_eq_factorization_lcm -- !--
!-- Hypothesis: `rank n = lcm_{p ∈ supp n} rank (p ^ v_p n)` for `n > 0`. -- !--
!-- Result: Write `n = ∏_{p ∈ primeFactors n} p ^ v_p n`
(`Nat.factorization_prod_pow_eq_self` + `Nat.support_factorization`); the prime powers are
pairwise coprime (distinct primes) and positive; apply `fibRank_finset_prod_coprime`. -- !--
!-- Insight: The global rank is the section glued from the prime-power stalk ranks — the full
local-to-global reconstruction of the apparition sheaf. -- !--
!-- Failure analysis: needs `n ≠ 0` for the prime factorisation; the support equals
`primeFactors n` via `Nat.support_factorization`. -- !--
!-- End Lab Notebook -- !--

**Local-to-global reconstruction.** For `n > 0`, the global rank is the lcm of the
prime-power stalk ranks: `rank n = lcm_{p ∈ primeFactors n} rank (p ^ v_p n)`.
-/
theorem fibRank_eq_factorization_lcm {n : ℕ} (hn : 0 < n) :
    fibRank n = (n.primeFactors).lcm (fun p => fibRank (p ^ (n.factorization p))) := by
  convert fibRank_finset_prod_coprime n.primeFactors ( fun p => p ^ n.factorization p ) _ _ using 1;
  · exact congr_arg _ ( Eq.symm <| Nat.factorization_prod_pow_eq_self hn.ne' );
  · exact fun p hp => pow_pos ( Nat.pos_of_mem_primeFactors hp ) _;
  · exact fun p hp q hq hpq => Nat.coprime_pow_primes _ _ ( Nat.prime_of_mem_primeFactors hp ) ( Nat.prime_of_mem_primeFactors hq ) hpq

end FibonacciApparitionSheaf