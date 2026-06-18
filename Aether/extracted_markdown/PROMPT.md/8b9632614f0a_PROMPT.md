Prove the composite case of Carmichael's theorem, establishing unconditionally that every Fibonacci number with composite index n > 12 possesses a primitive prime divisor.

**Theorem Statement:**

```lean
import Mathlib

open Nat

/-- Carmichael's Theorem, composite case. For every composite n > 12,
the n-th Fibonacci number admits a primitive prime divisor. -/
theorem carmichael_composite_primitive_prime_divisor
    {n : ℕ} (hn : n > 12) (hcomp : ¬ n.Prime) :
    ∃ p : ℕ, p.Prime ∧ p ∣ fib n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ fib k := by
```

**Proof Strategy:**

1. **Entry-point reduction via proper divisors.** Argue by contraposition: assume `fib n` has no primitive prime divisor. Then every prime `p ∣ fib n` is non-primitive. Invoke the existing catalog lemma `non_primitive_to_proper_divisor` from `Speculative/AutoResearch/CarmichaelPrimitiveDivisor.lean` to obtain, for each such prime, a proper divisor `d ∣ n` with `p ∣ fib d`. Use `Nat.fib_gcd` and `Nat.fib_dvd` to confirm that the rank of apparition `z(p)` is a proper divisor of `n`. Consequently, every non-primitive prime is captured by the proper-divisor lattice.

2. **Lifting-the-Exponent for Fibonacci valuations.** For each odd prime `p` with entry point `z(p) = d`, establish the p-adic valuation identity
   ```
   padicValNat p (fib n) = padicValNat p (fib d) + padicValNat p (n / d)
   ```
   by induction on `n/d` using the recurrence `Nat.fib_add_two` together with the strong divisibility property `Nat.fib_gcd`. Apply `padicValNat.mul` and `padicValNat.pow` to propagate these bounds across the prime factorization of the non-primitive part of `fib n`, showing that the total non-primitive contribution is dominated by a product of proper-divisor Fibonacci terms scaled by an explicit subexponential factor in `n` (at most `n` raised to the number of distinct prime factors, bounded via `n.primeFactors.length`).

3. **Asymptotic gap and finite discharge.** Prove an exponential lower bound `fib n ≥ 2^(n-2)` by induction with `Nat.fib_add_two` and `Nat.pow_le_pow_of_le_left`. Combine this with Step 2 to show that for every composite `n` larger than the explicit computable threshold `N₀ = 10000`, the primitive part `P := fib n / Q` exceeds 1, where `Q` is the aggregate non-primitive contribution. Any prime divisor of `P` is primitive for `fib n` by the existing catalog lemma `primitive_of_not_dvd_proper_divisors` from `Speculative/AutoResearch/CarmichaelComposite.lean`. For the finitely many remaining composite indices `13 ≤ n ≤ 10000`, discharge the goal by direct appeal to the existing `native_decide` verification database. Use `interval_cases` and `norm_num` to handle the bounded range, and `Nat.le_of_dvd` together with `fib_pos` to formalize the asymptotic contradiction in the infinite regime.

**Why this matters:** This closes the final gap in Carmichael's theorem, upgrading the finite computational verification on `[13, 10000]` into an unconditional proof valid for all composite indices. The argument validates the LTE–entry-point framework as a systematic method for primitive divisor problems over Lucas sequences, providing a direct on-ramp to the full primitive divisor theory and, ultimately, a formalized proof of Zsigmondy's theorem in Mathlib.

### Catalog Reference Files
            @Speculative/AutoResearch/CarmichaelComposite.lean
```lean
import Mathlib
import Shared.CarmichaelHelper

/-! # Carmichael's theorem for composite n

We prove that for composite n ≥ 14, F(n) has a primitive prime divisor.

Key idea: We use entry point theory combined with a computational verification
of the "coprime part" of F(n) with respect to F(d) for proper divisors d | n.

The coprime part removes all prime factors of F(d) from F(n). If the result is > 1,
there exists a prime factor of F(n) coprime to all F(d), which by entry point theory
must be a primitive prime divisor.
-/

open Classical in
/-- The "Fibonacci entry point" of p: smallest k > 0 with p | F(k), or 0 if none. -/
noncomputable def fibEntryPt (p : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ p ∣ Nat.fib k then
    Nat.find h
  else 0

/-
If p | F(n) and p | F(k), then p | F(gcd(n,k)).
-/
lemma fib_dvd_gcd_of_dvd (p n k : ℕ) (hn : p ∣ Nat.fib n) (hk : p ∣ Nat.fib k) :
    p ∣ Nat.fib (Nat.gcd n k) := by
  exact Nat.dvd_gcd hn hk |> fun h => by simpa [ Nat.fib_gcd ] using h;

/-
The entry point divides n whenever p | F(n) and n > 0.
-/
lemma fibEntryPt_dvd_of_fib_dvd (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
    (hpn : p ∣ Nat.fib n) : fibEntryPt p ∣ n := by
  set α := fibEntryPt p
  have hα_pos : 0 < α := by
    unfold α fibEntryPt;
    split_ifs <;> simp_all +decide [ Nat.find_eq_iff ]
  have hα_div : p ∣ Nat.fib α := by
    simp +zetaDelta at *;
    unfold fibEntryPt at *;
    split_ifs at * <;> simp_all +decide [ Nat.find_spec ( _ : ∃ k, 0 < k ∧ p ∣ Nat.fib k ) ]
  have hα_min : ∀ m, 0 < m → m < α → ¬(p ∣ Nat.fib m) := by
    simp +zetaDelta at *;
    unfold fibEntryPt at *; aesop;
  have h_gcd_eq : Nat.gcd n α = α := by
    exact le_antisymm ( Nat.le_of_dvd hα_pos ( Nat.gcd_dvd_right _ _ ) ) ( Nat.le_of_not_gt fun h => hα_min _ ( Nat.gcd_pos_of_pos_left _ hn ) h <| fib_dvd_gcd_of_dvd _ _ _ hpn hα_div );
  exact h_gcd_eq ▸ Nat.gcd_dvd_left _ _

/-
Entry point is positive for any prime p | F(n) with n > 0.
-/
lemma fibEntryPt_pos (p : ℕ) (hp : Nat.Prime p) (hn : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
    0 < fibEntryPt p := by
  unfold fibEntryPt; aesop;

/-
If the entry point of p equals n, then p is a primitive prime divisor of F(n).
-/
lemma primitive_of_entryPt_eq (p n : ℕ) (hp : Nat.Prime p) (hpn : p ∣ Nat.fib n)
    (heq : fibEntryPt p = n) (hn : 0 < n) :
    ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  intro k hk hk' hk''; have := fibEntryPt_dvd_of_fib_dvd p k ( by assumption ) ( by linarith ) hk''; simp_all +decide [ Nat.dvd_iff_mod_eq_zero ] ;
  rw [ Nat.mod_eq_of_lt ] at this <;> linarith

/-! ## Computational infrastructure for primitive divisor verification -/

/-- Remove all prime factors of b from a. -/
def removePrimesOf (a b : ℕ) : ℕ :=
  if ha : a = 0 then 0
  else
    let g := Nat.gcd a b
    if hg : g ≤ 1 then a
    else
      have : a / g < a := Nat.div_lt_self (Nat.pos_of_ne_zero ha) (by omega)
      removePrimesOf (a / g) b
termination_by a

/-- The coprime part of F(n) with respect to F(d) for all proper divisors d | n.
    If this is > 1, F(n) has a prime factor not appearing in any F(d) for proper d | n. -/
def fibCoprimePart (n : ℕ) : ℕ :=
  let fn := Nat.fib n
  let properDivs := (List.range n).filter (fun d => 0 < d && n % d == 0)
  properDivs.foldl (fun acc d => removePrimesOf acc (Nat.fib d)) fn

/-
removePrimesOf a b divides a.
-/
lemma removePrimesOf_dvd (a b : ℕ) : removePrimesOf a b ∣ a := by
  induction' a using Nat.strong_induction_on with a ih generalizing b;
  unfold removePrimesOf;
  split_ifs <;> simp_all +decide [ Nat.div_dvd_of_dvd ];
  split_ifs;
  · norm_num;
  · exact dvd_trans ( ih _ ( Nat.div_lt_self ( Nat.pos_of_ne_zero ‹_› ) ( lt_of_not_ge ‹_› ) ) _ ) ( Nat.div_dvd_of_dvd ( Nat.gcd_dvd_left _ _ ) )

/-
removePrimesOf a b is coprime to b when a > 0.
-/
lemma removePrimesOf_coprime (a b : ℕ) (ha : 0 < a) :
    Nat.Coprime (removePrimesOf a b) b := by
  induction' a using Nat.strong_induction_on with a ih generalizing b;
  unfold removePrimesOf;
  split_ifs <;> simp_all +decide [ Nat.Coprime, Nat.gcd_comm ];
  split_ifs;
  · exact Nat.Coprime.symm ( Nat.le_antisymm ‹_› ( Nat.gcd_pos_of_pos_left _ ha ) );
  · exact ih _ ( Nat.div_lt_self ha ( lt_of_not_ge ‹_› ) ) _ ( Nat.div_pos ( Nat.le_of_dvd ha ( Nat.gcd_dvd_left _ _ ) ) ( Nat.gcd_pos_of_pos_left _ ha ) )

/-
If p | F(n) and p doesn't divide F(d) for any proper divisor d of n,
    then p is a primitive prime divisor of F(n).
-/
lemma primitive_of_not_dvd_proper_divisors (p n : ℕ) (hp : Nat.Prime p)
    (hn : 0 < n) (hpn : p ∣ Nat.fib n)
    (hnd : ∀ d, d ∣ n → 0 < d → d < n → ¬(p ∣ Nat.fib d)) :
    ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  intro k hk hk'; specialize hnd ( Nat.gcd n k ) ; simp_all +decide [ Nat.gcd_pos_of_pos_right ] ;
  exact fun h => hnd ( Nat.gcd_dvd_left _ _ ) ( Nat.lt_of_le_of_lt ( Nat.le_of_dvd hk ( Nat.gcd_dvd_right _ _ ) ) hk' ) ( fib_dvd_gcd_of_dvd p n k hpn h )

/-
If fibCoprimePart n > 1, then F(n) has a primitive prime divisor.
-/
lemma primitive_of_fibCoprimePart_pos (n : ℕ) (hn : 0 < n)
    (hcp : 1 < fibCoprimePart n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  -- By definition of `fibCoprimePart`, it is coprime to `fib d` for each proper divisor `d | n`.
  have h_coprime : ∀ d, d ∣ n → 0 < d → d < n → Nat.Coprime (fibCoprimePart n) (Nat.fib d) := by
    intros d hd hdn hdn';
    have h_fold_coprime : ∀ (ds : List ℕ), d ∈ ds → Nat.Coprime (List.foldl (fun acc d => removePrimesOf acc (Nat.fib d)) (Nat.fib n) ds) (Nat.fib d) := by
      intros ds hds;
      induction' ds using List.reverseRecOn with ds ih <;> simp_all +decide [ Nat.coprime_mul_iff_left, Nat.coprime_mul_iff_right ];
      by_cases h : d ∈ ds <;> simp_all +decide [ Nat.Coprime ];
      · refine' Nat.Coprime.coprime_dvd_left ( removePrimesOf_dvd _ _ ) ‹_›;
      · apply removePrimesOf_coprime;
        induction' ds using List.reverseRecOn with ds ih <;> simp_all +decide [ Nat.fib_pos ];
        exact Nat.pos_of_dvd_of_pos ( removePrimesOf_dvd _ _ ) ‹_›;
    apply h_fold_coprime;
    simp +decide [ List.mem_filter, List.mem_range, hdn, hdn', Nat.dvd_iff_mod_eq_zero.mp hd ];
  -- Let `p` be a prime factor of `fibCoprimePart n`.
  obtain ⟨p, hp_prime, hp_dvd⟩ : ∃ p, Nat.Prime p ∧ p ∣ fibCoprimePart n := by
    exact Nat.exists_prime_and_dvd hcp.ne';
  -- Since `p` divides `fibCoprimePart n`, it follows that `p` divides `Nat.fib n`.
  have hp_dvd_fib : p ∣ Nat.fib n := by
    refine dvd_trans hp_dvd ?_;
    unfold fibCoprimePart;
    induction' ( List.filter ( fun d => decide ( 0 < d ) && n % d == 0 ) ( List.range n ) ) using List.reverseRecOn with d l ih <;> simp_all +decide [ Nat.dvd_trans ];
    exact dvd_trans ( removePrimesOf_dvd _ _ ) ih;
  refine' ⟨ p, hp_prime, hp_dvd_fib, fun k hk₁ hk₂ hk₃ => _ ⟩;
  contrapose! h_coprime;
  refine' ⟨ Nat.gcd n k, Nat.gcd_dvd_left _ _, Nat.gcd_pos_of_pos_left _ hn, _, _ ⟩;
-- ... (truncated, full file has 181 lines)
```

@Speculative/AutoResearch/Primitive_Prime_Divisors_of_Composite_Index_Fibonacci_Numbers_via_LTE_and_Entry_Point_Theory.lean
```lean
import Mathlib

/-!
# Carmichael's Primitive Divisor Theorem for Fibonacci Numbers (Composite Index Case)

This file proves structural results toward Carmichael's theorem that for every
composite natural number `n > 10000`, the Fibonacci number `F_n` has a
**primitive prime divisor**: a prime `p` that divides `F_n` but does not
divide `F_k` for any `0 < k < n`.

## Main results

* `entry_point_dvd_of_fib_dvd`: The entry point (rank of apparition) of a prime
  in the Fibonacci sequence divides `n` whenever `p ∣ F_n`.
* `fib_dvd_iff_entry_dvd`: A prime `p` divides `F_k` if and only if its entry
  point divides `k`.
* `fib_composite_has_primitive`: The main theorem (composite case of Carmichael's
  theorem). Uses a sorry for the core number-theoretic step.

## Implementation notes

The full proof of Carmichael's theorem requires the theory of cyclotomic Fibonacci
numbers Φ_n (primitive parts), specifically:
1. The multiplicative identity `F_n = ∏_{d|n} Φ_d`
2. The lower bound `Φ_n ≈ φ^{φ(n)}` (Euler's totient function)
3. The intrinsic factor theorem: primes dividing Φ_n and Φ_d (for d | n, d < n)
   must divide n

This infrastructure is not currently available in Mathlib. The entry point theory
and supporting lemmas are fully proved; only the core growth/cyclotomic step
remains as a sorry.
-/

open scoped BigOperators
open Finset Nat

set_option maxHeartbeats 1600000

/-! ## Entry point theory for Fibonacci primes -/

/-- If `p ∣ F_m` and `p ∣ F_n`, then `p ∣ F_{gcd m n}`.
This follows from the strong divisibility property `gcd(F_m, F_n) = F_{gcd(m,n)}`. -/
lemma prime_dvd_fib_gcd (p m n : ℕ) (hp : Nat.Prime p)
    (hm : p ∣ Nat.fib m) (hn : p ∣ Nat.fib n) :
    p ∣ Nat.fib (Nat.gcd m n) := by
  exact Nat.dvd_gcd hm hn |> fun h => by simpa [fib_gcd] using h

/-- Every prime divides some positive Fibonacci number.
This follows from the Pisano period: the Fibonacci sequence mod `p` is periodic,
so the pair `(0, 1)` must recur, giving `F_k ≡ 0 (mod p)` for some `k > 0`. -/
lemma prime_dvd_some_fib (p : ℕ) (hp : Nat.Prime p) :
    ∃ k, 0 < k ∧ p ∣ Nat.fib k := by
  have h_pigeonhole : ∃ i j : ℕ, i < j ∧ (fib i % p = fib j % p) ∧
      (fib (i + 1) % p = fib (j + 1) % p) := by
    have h_finite : Set.Finite ((fun k => (fib k % p, fib (k + 1) % p)) '' Set.Ici 0) := by
      exact Set.finite_iff_bddAbove.mpr ⟨⟨p - 1, p - 1⟩, by
        rintro a ⟨k, -, rfl⟩
        exact ⟨Nat.le_sub_one_of_lt (Nat.mod_lt _ hp.pos),
               Nat.le_sub_one_of_lt (Nat.mod_lt _ hp.pos)⟩⟩
    contrapose! h_finite
    exact Set.infinite_of_injective_forall_mem
      (fun i j hij => le_antisymm
        (not_lt.1 fun hi => h_finite _ _ hi (by aesop) (by aesop))
        (not_lt.1 fun hj => h_finite _ _ hj (by aesop) (by aesop)))
      fun i => ⟨i, by norm_num, rfl⟩
  obtain ⟨i, j, hij, hi, hj⟩ := h_pigeonhole
  induction' i with i ih generalizing j
  · induction' j with j ih' <;> simp_all +decide [Nat.fib_add_two, Nat.dvd_iff_mod_eq_zero]
    exact ⟨j + 1, by linarith, by simp +decide [← hi]⟩
  · specialize ih (j - 1) (Nat.lt_pred_iff.mpr hij)
    rcases j <;> simp_all +decide [Nat.fib_add_two, Nat.add_mod]
    simp_all +decide [← ZMod.natCast_eq_natCast_iff']

/-- The entry point (rank of apparition) of a prime divides `n` whenever `p ∣ F_n`.
Returns the minimal positive `d` such that `d ∣ n`, `p ∣ F_d`, and `p ∤ F_k`
for all `0 < k < d`. -/
lemma entry_point_dvd_of_fib_dvd (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
    (hpn : p ∣ Nat.fib n) :
    ∃ d, 0 < d ∧ d ∣ n ∧ p ∣ Nat.fib d ∧ ∀ k, 0 < k → k < d → ¬(p ∣ Nat.fib k) := by
  obtain ⟨d, hd1, hd2, hd3⟩ : ∃ d, 0 < d ∧ p ∣ fib d ∧ ∀ k, 0 < k → k < d → ¬p ∣ fib k := by
    have := prime_dvd_some_fib p hp
    exact ⟨Nat.find this, Nat.find_spec this |>.1, Nat.find_spec this |>.2, by aesop⟩
  refine ⟨d, hd1, ?_, hd2, hd3⟩
  contrapose! hd3
  exact ⟨Nat.gcd d n, Nat.gcd_pos_of_pos_left _ hd1,
    lt_of_le_of_ne (Nat.le_of_dvd hd1 (Nat.gcd_dvd_left _ _))
      fun con => hd3 <| con ▸ Nat.gcd_dvd_right _ _,
    prime_dvd_fib_gcd p d n hp hd2 hpn⟩

/-- A prime `p` divides `F_k` if and only if its entry point `d` divides `k`.
This is the fundamental characterization of divisibility in the Fibonacci sequence. -/
lemma fib_dvd_iff_entry_dvd (p d k : ℕ) (hp : Nat.Prime p) (hd : 0 < d)
    (hpd : p ∣ Nat.fib d) (hmin : ∀ j, 0 < j → j < d → ¬(p ∣ Nat.fib j))
    (hk : 0 < k) : p ∣ Nat.fib k ↔ d ∣ k := by
  constructor
  · contrapose! hmin
    use Nat.gcd d k
    exact ⟨Nat.gcd_pos_of_pos_left _ hd,
      lt_of_le_of_ne (Nat.le_of_dvd hd (Nat.gcd_dvd_left _ _))
        fun con => hmin.2 <| con ▸ Nat.gcd_dvd_right _ _,
      prime_dvd_fib_gcd _ _ _ hp hpd hmin.1⟩
  · exact fun h => dvd_trans hpd (Nat.fib_dvd _ _ h)

/-! ## Fibonacci growth bounds -/

/-- For composite `n > 1`, every proper divisor is at most `n / 2`. -/
lemma composite_proper_div_le_half (n : ℕ) (hn : n > 1) (hcomp : ¬Nat.Prime n)
    (d : ℕ) (hd : d ∣ n) (hdn : d < n) : d ≤ n / 2 := by
  rw [Nat.le_div_iff_mul_le (by norm_num : (0:ℕ) < 2)]
  obtain ⟨k, rfl⟩ := hd
  have hk : k > 1 := by
    rcases k with _ | _ | k
    · omega
    · simp at hcomp; exact absurd (by omega : d * 1 < d * 1 + d) (by omega)
    · omega
  nlinarith

/-- `F_n ≥ 2` for `n ≥ 3`. -/
lemma fib_ge_two (n : ℕ) (hn : n ≥ 3) : Nat.fib n ≥ 2 :=
  Nat.le_trans (by decide) (Nat.fib_mono hn)

/-- `F_n ≠ 1` for `n ≥ 3`. -/
lemma fib_ne_one (n : ℕ) (hn : n ≥ 3) : Nat.fib n ≠ 1 :=
  Nat.ne_of_gt (fib_ge_two n hn)

/-- Fibonacci is strictly monotone for indices ≥ 2. -/
lemma fib_strict_mono {a b : ℕ} (ha : 2 ≤ a) (hab : a < b) : Nat.fib a < Nat.fib b := by
  induction hab <;> simp_all +arith +decide [Nat.fib_add_two]
  · rcases a with _ | _ | a <;> simp_all +arith +decide [Nat.fib_add_two]
  · exact lt_of_lt_of_le ‹_› (Nat.fib_mono (Nat.le_succ _))

/-- `F_n ≤ 2^n` for all `n`. -/
lemma fib_le_two_pow (n : ℕ) : Nat.fib n ≤ 2 ^ n := by
  induction' n using Nat.strong_induction_on with n ih
  rcases n with _ | _ | _ | n <;> simp +arith +decide [Nat.fib_add_two, *]
  grind

/-- `F_n ≥ n` for `n ≥ 5`. -/
lemma fib_ge_id (n : ℕ) (hn : n ≥ 5) : Nat.fib n ≥ n := by
  induction hn <;> simp +arith +decide [Nat.fib_add_two, *]
  rename_i m hm ih
  rcases m with _ | _ | _ | _ | _ | m <;> simp_all +arith +decide [Nat.fib_add_two]
  grind +splitIndPred

/-! ## Main theorem -/

/-- **Carmichael's Primitive Divisor Theorem (composite index case)**.

For composite `n > 10000`, the Fibonacci number `F_n` has a primitive prime divisor:
a prime `p` such that `p ∣ F_n` but `p ∤ F_k` for every `0 < k < n`.
-- ... (truncated, full file has 169 lines)
```

@Speculative/AutoResearch/Carmichael_Primitive_Divisors_for_Composite_Indices_via_Fibonacci_Entry_Points_and_LTE.lean
```lean
import Mathlib

set_option maxHeartbeats 800000
set_option maxRecDepth 4000

/-!
# Carmichael's Theorem for Fibonacci Numbers (Computational)

Carmichael's theorem states that for every composite n ≥ 13, the Fibonacci number F(n)
has a primitive prime divisor: a prime p such that p ∣ F(n) but p ∤ F(k) for all 0 < k < n.

## Proof Strategy

1. **Computational kernel**: Define `fibPrimPart n`, the largest divisor of F(n) coprime to
   F(d) for every proper positive divisor d of n. Show that `fibPrimPart n > 1` implies
   existence of a primitive prime (via `Nat.fib_gcd`).

2. **Finite verification**: Use `native_decide` to check `fibPrimPart n > 1` for all
   composite n ∈ [13, 100000].

3. **Entry point theory**: For n > 100000, define the Fibonacci entry point and prove
   `p ∣ F(n) ↔ entryPt(p) ∣ n`. Use the Lifting-the-Exponent congruence to prove the
   prime-power and multi-prime cases.
-/

open Nat in
/-! ### Computable Primitive Part -/

/-- Remove all prime factors that `n` shares with `g`. -/
def removeFactors (n g : ℕ) : ℕ :=
  if hn : n ≤ 1 then n
  else if hg : g ≤ 1 then n
  else
    if hd : Nat.gcd n g ≤ 1 then n
    else
      have : n / Nat.gcd n g < n := Nat.div_lt_self (by omega) (not_le.mp hd)
      removeFactors (n / Nat.gcd n g) g
termination_by n

/-- The proper positive divisors of `n` as a list. -/
def properDivisors (n : ℕ) : List ℕ :=
  (List.range n).filter (fun d => d > 0 && (n % d == 0))

/-- The primitive part of F(n): the largest factor of F(n) coprime to F(d)
    for every proper positive divisor d of n. -/
def fibPrimPart (n : ℕ) : ℕ :=
  let fn := Nat.fib n
  let divs := properDivisors n
  divs.foldl (fun acc d => removeFactors acc (Nat.fib d)) fn

/-- Boolean check that all composite n in [lo, hi] have fibPrimPart > 1. -/
def checkCompositeRange (lo hi : ℕ) : Bool :=
  (List.range (hi - lo + 1)).all fun i =>
    let n := lo + i
    n.Prime || fibPrimPart n > 1

/-! ### Key Properties of removeFactors -/

/-
removeFactors always returns a divisor of the input.
-/
lemma removeFactors_dvd (n g : ℕ) : removeFactors n g ∣ n := by
  -- We'll use induction on $n$. The base case is when $n \leq 1$.
  induction' n using Nat.strong_induction_on with n ih generalizing g;
  unfold removeFactors;
  split_ifs <;> simp_all +decide [ Nat.gcd_dvd_left, Nat.gcd_dvd_right ];
  exact dvd_trans ( ih _ ( Nat.div_lt_self ( by linarith ) ( by linarith ) ) _ ) ( Nat.div_dvd_of_dvd ( Nat.gcd_dvd_left _ _ ) )

/-
removeFactors produces a result coprime to g (for positive inputs).
-/
lemma removeFactors_coprime (n g : ℕ) (hn : 0 < n) (hg : g > 0) :
    Nat.Coprime (removeFactors n g) g := by
  induction' n using Nat.strongRecOn with n ih;
  -- We consider three cases for the gcd of n and g.
  by_cases h_gcd : Nat.gcd n g ≤ 1;
  · unfold removeFactors;
    cases h_gcd.eq_or_lt <;> simp_all +decide [ Nat.Coprime, Nat.gcd_eq_left_iff_dvd ];
  · unfold removeFactors;
    split_ifs <;> simp_all +decide [ Nat.gcd_eq_left_iff_dvd ];
    · interval_cases n ; aesop;
    · interval_cases g ; aesop;
    · exact ih _ ( Nat.div_lt_self hn ( lt_of_not_ge h_gcd ) ) ( Nat.div_pos ( Nat.le_of_dvd hn ( Nat.gcd_dvd_left _ _ ) ) ( Nat.gcd_pos_of_pos_left _ hn ) )

/-
removeFactors is monotone: if a ∣ b, then removeFactors a g ∣ removeFactors b g.
-/
lemma removeFactors_le (n g : ℕ) : removeFactors n g ≤ n := by
  unfold removeFactors;
  split_ifs <;> norm_num;
  exact le_trans ( show _ ≤ n / n.gcd g from Nat.le_of_dvd ( Nat.div_pos ( Nat.le_of_dvd ( by linarith ) ( Nat.gcd_dvd_left _ _ ) ) ( Nat.gcd_pos_of_pos_left _ ( by linarith ) ) ) ( removeFactors_dvd _ _ ) ) ( Nat.div_le_self _ _ )

/-! ### fibPrimPart Properties -/

/-
fibPrimPart n divides fib n.
-/
lemma fibPrimPart_dvd_fib (n : ℕ) : fibPrimPart n ∣ Nat.fib n := by
  -- By definition of `fibPrimPart`, we know that `fibPrimPart n` is the result of repeatedly applying `removeFactors` to `Nat.fib n`.
  simp [fibPrimPart];
  induction' ( properDivisors n ) using List.reverseRecOn with d l ih <;> simp_all +decide [ Nat.dvd_trans ];
  exact dvd_trans ( removeFactors_dvd _ _ ) ih

/-
fibPrimPart n is coprime to fib d for every proper positive divisor d of n.
-/
lemma fibPrimPart_coprime_proper_div (n d : ℕ) (hd : d ∣ n) (hd0 : 0 < d)
    (hdn : d < n) : Nat.Coprime (fibPrimPart n) (Nat.fib d) := by
  -- By definition of `properDivisors`, `d` appears in the list `properDivisors n`.
  have h_d_in_divs : d ∈ properDivisors n := by
    unfold properDivisors;
    simp +decide [ List.mem_filter, List.mem_range, Nat.mod_eq_zero_of_dvd hd, hd0, hdn ];
  have h_foldl_coprime : ∀ {l : List ℕ}, d ∈ l → Nat.Coprime (List.foldl (fun acc d => removeFactors acc (Nat.fib d)) (Nat.fib n) l) (Nat.fib d) := by
    intros l hl; induction' l using List.reverseRecOn with l ih <;> simp_all +decide [ Nat.Coprime ] ;
    by_cases h : 0 < List.foldl ( fun acc d => removeFactors acc ( Nat.fib d ) ) ( Nat.fib n ) l <;> by_cases h' : 0 < Nat.fib ih <;> simp_all +decide [ Nat.Coprime, Nat.gcd_comm ];
    · have := removeFactors_coprime ( List.foldl ( fun acc d => removeFactors acc ( Nat.fib d ) ) ( Nat.fib n ) l ) ( Nat.fib ih ) h ( Nat.fib_pos.mpr h' ) ; simp_all +decide [ Nat.Coprime, Nat.Coprime.symm ] ;
      cases hl <;> simp_all +decide [ Nat.Coprime, Nat.Coprime.symm ];
      exact Nat.Coprime.coprime_dvd_right ( removeFactors_dvd _ _ ) ‹_›;
    · unfold removeFactors; aesop;
    · have h_contra : ∀ {l : List ℕ}, List.foldl (fun acc d => removeFactors acc (Nat.fib d)) (Nat.fib n) l = 0 → False := by
        intros l hl; induction' l using List.reverseRecOn with l ih <;> simp_all +decide [ Nat.Coprime ] ;
        have := removeFactors_dvd ( List.foldl ( fun acc d => removeFactors acc ( Nat.fib d ) ) ( Nat.fib n ) l ) ( Nat.fib ih ) ; simp_all +decide [ Nat.Coprime ] ;
      exact False.elim <| h_contra h;
    · unfold removeFactors; aesop;
  exact h_foldl_coprime h_d_in_divs

/-! ### Bridge Lemma: fibPrimPart > 1 implies primitive prime exists -/

/-
If fibPrimPart n > 1, then F(n) has a primitive prime divisor.
-/
theorem fibPrimPart_gt_one_implies_primitive (n : ℕ) (hn : 1 < n)
    (hfp : 1 < fibPrimPart n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  -- Since fibPrimPart n > 1, it has a prime factor p (by Nat.exists_prime_and_dvd).
  obtain ⟨p, hp_prime, hp_div⟩ : ∃ p, Nat.Prime p ∧ p ∣ fibPrimPart n := by
    exact Nat.exists_prime_and_dvd hfp.ne';
  refine' ⟨ p, hp_prime, dvd_trans hp_div ( fibPrimPart_dvd_fib n ), _ ⟩;
  intros k hk_pos hk_lt_n hp_div_k
  have h_div_d : p ∣ Nat.fib (Nat.gcd k n) := by
    have h_div_d : p ∣ Nat.gcd (Nat.fib k) (Nat.fib n) := by
      exact Nat.dvd_gcd hp_div_k ( dvd_trans hp_div ( fibPrimPart_dvd_fib n ) );
    rw [ Nat.gcd_comm ] at h_div_d; simp_all +decide [ Nat.fib_gcd ] ;
    rwa [ Nat.gcd_comm ];
  have := fibPrimPart_coprime_proper_div n ( Nat.gcd k n ) ( Nat.gcd_dvd_right _ _ ) ( Nat.gcd_pos_of_pos_left _ hk_pos ) ( lt_of_le_of_lt ( Nat.le_of_dvd hk_pos ( Nat.gcd_dvd_left _ _ ) ) hk_lt_n ) ; have := Nat.dvd_gcd hp_div h_div_d ; aesop;

/-! ### Finite Verification via native_decide -/

/-- Computational check: fibPrimPart n > 1 for all composite n ∈ [13, 100000]. -/
-- ... (truncated, full file has 261 lines)
```

@Shared/CarmichaelProof.lean
```lean
import Mathlib
import Shared.CarmichaelHelper

/-! # Complete proof of Carmichael's theorem (composite case)

We prove that for composite n ≥ 13, F(n) has a primitive prime divisor.
-/

set_option maxHeartbeats 800000

/-! ## Bridge Lemma -/

lemma bridge_lemma (n : ℕ) (hn : 0 < n) (p : ℕ)
    (hpn : p ∣ Nat.fib n)
    (hdiv : ∀ d, d ∣ n → 0 < d → d < n → ¬(p ∣ Nat.fib d)) :
    ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  intro k hk hkn hpk
  have h_gcd_dvd : p ∣ Nat.fib (Nat.gcd n k) := by
    rw [Nat.fib_gcd]; exact Nat.dvd_gcd hpn hpk
  exact hdiv (Nat.gcd n k) (Nat.gcd_dvd_left n k)
    (Nat.gcd_pos_of_pos_left k hn)
    (lt_of_le_of_lt (Nat.gcd_le_right n hk) hkn) h_gcd_dvd

/-! ## Computational verification infrastructure -/

/-- Strip all factors of m from r, with bounded fuel -/
def stripAllAux (r : ℕ) (m : ℕ) : ℕ → ℕ
  | 0 => r
  | fuel + 1 =>
    if m ≤ 1 then r
    else
      let g := Nat.gcd r m
      if g ≤ 1 then r
      else stripAllAux (r / g) m fuel

/-- List of proper divisors of n (d with 0 < d < n and d | n) -/
def propDivs (n : ℕ) : List ℕ :=
  (List.range n).filter fun d => 0 < d && d < n && n % d == 0

/-- The primitive part of F(n) -/
def primPart (n : ℕ) : ℕ :=
  let fn := Nat.fib n
  (propDivs n).foldl (fun r d => stripAllAux r (Nat.fib d) r) fn

/-! ## Correctness lemmas -/

lemma stripAllAux_dvd (r m fuel : ℕ) : stripAllAux r m fuel ∣ r := by
  induction fuel generalizing r with
  | zero => exact dvd_refl r
  | succ fuel ih =>
    simp only [stripAllAux]
    split_ifs with h1 h2
    · exact dvd_refl r
    · exact dvd_refl r
    · exact dvd_trans (ih (r / Nat.gcd r m)) (Nat.div_dvd_of_dvd (Nat.gcd_dvd_left r m))

lemma stripAllAux_coprime (r m fuel : ℕ) (hm : 1 < m) (hr : 0 < r) (hfuel : r ≤ fuel) :
    Nat.gcd (stripAllAux r m fuel) m = 1 := by
  induction' fuel with fuel ih generalizing r m;
  · grind +qlia;
  · by_cases hgr : Nat.gcd r m > 1;
    · convert ih ( r / Nat.gcd r m ) m hm ( Nat.div_pos ( Nat.le_of_dvd hr ( Nat.gcd_dvd_left _ _ ) ) hgr.le ) _ using 1;
      · grind +locals;
      · exact Nat.le_of_lt_succ ( Nat.div_lt_of_lt_mul <| by nlinarith [ Nat.div_mul_cancel ( Nat.gcd_dvd_left r m ) ] );
    · interval_cases _ : Nat.gcd r m <;> simp_all +decide [ stripAllAux ]

lemma primPart_dvd (n : ℕ) : primPart n ∣ Nat.fib n := by
  simp [primPart];
  induction' ( propDivs n ) using List.reverseRecOn with d l ih <;> simp_all +decide [ List.foldl ];
  exact dvd_trans ( stripAllAux_dvd _ _ _ ) ih

lemma primPart_coprime_proper_divs (n : ℕ) (hpp : 1 < primPart n) (d : ℕ)
    (hd : d ∈ propDivs n) : ¬((primPart n).minFac ∣ Nat.fib d) := by
  have h_coprime : Nat.gcd (primPart n) (Nat.fib d) = 1 := by
    have h_coprime : ∀ l : List ℕ, d ∈ l → Nat.gcd (List.foldl (fun r d => stripAllAux r (Nat.fib d) r) (Nat.fib n) l) (Nat.fib d) = 1 := by
      intros l hl; induction' l using List.reverseRecOn with l ih <;> simp_all +decide [ Nat.gcd_comm ] ;
      by_cases h : Nat.fib ih > 1 <;> by_cases h' : 0 < List.foldl ( fun r d => stripAllAux r ( Nat.fib d ) r ) ( Nat.fib n ) l <;> simp_all +decide [ Nat.gcd_comm ];
      · have := stripAllAux_coprime ( List.foldl ( fun r d => stripAllAux r ( Nat.fib d ) r ) ( Nat.fib n ) l ) ( Nat.fib ih ) ( List.foldl ( fun r d => stripAllAux r ( Nat.fib d ) r ) ( Nat.fib n ) l ) h h' ( by linarith ) ; simp_all +decide [ Nat.gcd_comm ] ;
        cases hl <;> simp_all +decide [ Nat.gcd_comm ];
        exact Nat.Coprime.coprime_dvd_right ( stripAllAux_dvd _ _ _ ) ‹_›;
      · have h_contra : ∀ l : List ℕ, List.foldl (fun r d => stripAllAux r (Nat.fib d) r) (Nat.fib n) l = 0 → False := by
          intros l hl; induction' l using List.reverseRecOn with l ih <;> simp_all +decide [ Nat.gcd_comm ] ;
          have := stripAllAux_dvd ( List.foldl ( fun r d => stripAllAux r ( Nat.fib d ) r ) ( Nat.fib n ) l ) ( Nat.fib ih ) ( List.foldl ( fun r d => stripAllAux r ( Nat.fib d ) r ) ( Nat.fib n ) l ) ; simp_all +decide [ Nat.gcd_comm ] ;
        exact False.elim <| h_contra l h';
      · rcases ih with ( _ | _ | ih ) <;> simp_all +arith +decide [ Nat.fib_add_two ];
        · cases hl <;> simp_all +decide [ propDivs ];
          unfold stripAllAux; aesop;
        · unfold stripAllAux; aesop;
        · rcases ih with ( _ | _ | ih ) <;> simp_all +arith +decide [ Nat.fib_add_two ];
          · unfold stripAllAux; aesop;
          · linarith [ Nat.fib_pos.2 ( Nat.succ_pos ih ) ];
      · have h_contra : List.foldl (fun r d => stripAllAux r (Nat.fib d) r) (Nat.fib n) l ∣ Nat.fib n := by
          have h_contra : ∀ l : List ℕ, List.foldl (fun r d => stripAllAux r (Nat.fib d) r) (Nat.fib n) l ∣ Nat.fib n := by
            intro l; induction' l using List.reverseRecOn with l ih <;> simp_all +decide [ Nat.gcd_comm ] ;
            exact dvd_trans ( stripAllAux_dvd _ _ _ ) ‹_›;
          exact h_contra l;
        rcases n with ( _ | _ | n ) <;> simp_all +decide [ Nat.fib_add_two ];
    exact h_coprime _ hd;
  exact fun h => Nat.Prime.not_dvd_one ( Nat.minFac_prime hpp.ne' ) ( h_coprime ▸ Nat.dvd_gcd ( Nat.minFac_dvd _ ) h )

lemma primPart_implies_primitive (n : ℕ) (hn : 3 ≤ n) (hpp : 1 < primPart n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  have h_div : primPart n ∣ Nat.fib n := primPart_dvd n
  refine' ⟨ Nat.minFac ( primPart n ), Nat.minFac_prime hpp.ne', dvd_trans ( Nat.minFac_dvd _ ) h_div, _ ⟩;
  intro k hk hk';
  by_cases h_div_k : Nat.minFac (primPart n) ∣ Nat.fib (Nat.gcd k n);
  · have h_div_k : Nat.gcd k n ∈ propDivs n := by
      simp +decide [ propDivs ];
      exact ⟨ lt_of_le_of_lt ( Nat.le_of_dvd hk ( Nat.gcd_dvd_left _ _ ) ) hk', ⟨ Or.inl hk, lt_of_le_of_lt ( Nat.le_of_dvd hk ( Nat.gcd_dvd_left _ _ ) ) hk' ⟩, Nat.mod_eq_zero_of_dvd ( Nat.gcd_dvd_right _ _ ) ⟩;
    exact absurd ( primPart_coprime_proper_divs n hpp _ h_div_k ) ( by aesop );
  · exact fun h => h_div_k <| Nat.dvd_gcd h ( Nat.dvd_trans ( Nat.minFac_dvd _ ) h_div ) |> fun x => by simpa [ Nat.fib_gcd ] using x;

/-! ## Computational verification -/

/-- Verified: for all n ∈ [13, 10000], either n is prime or primPart n > 1 -/
theorem primPart_check : ∀ n ∈ Finset.Icc 13 10000, Nat.Prime n ∨ 1 < primPart n := by
  native_decide

/-! ## The composite case -/

theorem fib_carmichael_composite (n : ℕ) (hn : 13 ≤ n) (hnp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  by_cases h : n ≤ 10000
  · -- Finite case: extract from computational verification
    have := primPart_check n (Finset.mem_Icc.mpr ⟨hn, h⟩)
    exact primPart_implies_primitive n (by omega) (this.resolve_left hnp)
  · -- Infinite tail: composite n > 10000
    -- This is the deep case requiring growth bounds on Fibonacci cyclotomic factors.
    -- For n > 10000 composite, the primitive part Φ_n ≈ φ^{φ(n)} >> 1.
    sorry

```

@Speculative/AutoResearch/FibPrimitive.lean
```lean
/-
# Carmichael's Theorem: Primitive Prime Divisors of Fibonacci Numbers

For every composite n ≥ 13, the Fibonacci number F(n) has at least one
primitive prime divisor — a prime p dividing F(n) that does not divide
F(k) for any 0 < k < n.

The bound n ≥ 13 is sharp: F(12) = 144 = 2⁴·3², and both 2 | F(3)
and 3 | F(4), so no primitive divisor exists for n = 12.

## Proof Structure
- **Entry point theory:** We prove that checking primitivity reduces to
  checking proper divisors of n, using the strong divisibility property
  `gcd(F(m), F(n)) = F(gcd(m,n))` (Nat.fib_gcd in Mathlib).
- **Computational verification:** A verified GCD-based algorithm checks
  all composite n ∈ [13, 50000] via `native_decide`.
- **Asymptotic case:** For n > 50000, the primitive part Φ_n ≈ φ^{φ(n)}
  grows exponentially faster than n, guaranteeing a primitive prime divisor.
  This case requires the Lifting-the-Exponent Lemma for Fibonacci sequences
  (Carmichael 1913), which is stated but not yet formally verified.
-/
import Mathlib

set_option maxHeartbeats 1600000

/-! ## Entry Point Theory -/

/-- If p divides both F(k) and F(n), then p divides F(gcd(k,n)).
    Follows from the strong divisibility `F(gcd(m,n)) = gcd(F(m), F(n))`. -/
lemma prime_dvd_fib_gcd {p k n : ℕ} (hp : Nat.Prime p)
    (hk : p ∣ Nat.fib k) (hn : p ∣ Nat.fib n) :
    p ∣ Nat.fib (Nat.gcd k n) := by
  exact Nat.dvd_gcd hk hn |> fun h => by simpa [Nat.fib_gcd] using h

/-- Checking primitivity over all 0 < k < n is equivalent to
    checking only proper divisors d | n with 0 < d < n.
    This uses `Nat.fib_gcd` to show that if p | F(k) and p | F(n),
    then p | F(gcd(k,n)), and gcd(k,n) is a proper divisor of n. -/
lemma fib_primitive_iff_divisors {n : ℕ} (hn : 0 < n) {p : ℕ} (hp : Nat.Prime p)
    (hpn : p ∣ Nat.fib n) :
    (∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k)) ↔
    (∀ d, d ∣ n → 0 < d → d < n → ¬(p ∣ Nat.fib d)) := by
  refine ⟨fun h d hd _ _ ↦ h d ‹_› ‹_›, fun h k hk hk' ↦ ?_⟩
  exact fun hk'' => h (Nat.gcd k n) (Nat.gcd_dvd_right _ _)
    (Nat.gcd_pos_of_pos_left _ hk)
    (lt_of_le_of_lt (Nat.le_of_dvd hk (Nat.gcd_dvd_left _ _)) hk')
    (prime_dvd_fib_gcd hp hk'' hpn)

/-! ## Verified Computational Checker -/

/-- List of proper divisors of n (d with 0 < d < n and d | n). -/
def properDivs (n : ℕ) : List ℕ :=
  (List.range n).filter (fun d => 0 < d ∧ n % d = 0)

lemma mem_properDivs {n d : ℕ} :
    d ∈ properDivs n ↔ d < n ∧ 0 < d ∧ d ∣ n := by
  simp +decide [properDivs, Nat.dvd_iff_mod_eq_zero]

/-- Compute the "primitive residual" of F(n): iteratively divide out
    gcd with F(d) for each proper divisor d of n.
    If the result R > 1, then R has a prime factor that is primitive. -/
def primitiveResidual (n : ℕ) : ℕ :=
  let fn := Nat.fib n
  if fn ≤ 1 then 0
  else
    let divs := properDivs n
    Id.run do
      let mut rem := fn
      for _ in List.range 200 do
        let mut changed := false
        for d in divs do
          let g := Nat.gcd rem (Nat.fib d)
          if g > 1 then
            rem := rem / g
            changed := true
        if !changed then break
      return rem

/-- Verify that R certifies a primitive prime divisor:
    R > 1, R | F(n), and gcd(R, F(d)) = 1 for all proper divisors d. -/
def verifyResidual (n R : ℕ) : Bool :=
  (R > 1) &&
  (Nat.fib n % R == 0) &&
  (properDivs n).all (fun d => Nat.gcd R (Nat.fib d) == 1)

/-- Combined check: compute residual and verify. -/
def checkPrimitiveExistence (n : ℕ) : Bool :=
  verifyResidual n (primitiveResidual n)

/-- Range check for all composite n in [lo, hi]. -/
def checkRangePrimitive (lo hi : ℕ) : Bool :=
  (List.range (hi - lo + 1)).all (fun i =>
    let n := lo + i
    Nat.Prime n || checkPrimitiveExistence n)

/-! ## Soundness -/

/-- If `verifyResidual` returns true, then F(n) has a primitive prime divisor.
    The proof: R > 1 gives a prime factor p of R. Since R | F(n), p | F(n).
    Since gcd(R, F(d)) = 1 for proper divisors d, p ∤ F(d).
    By `fib_primitive_iff_divisors`, p is a primitive prime divisor. -/
lemma verifyResidual_sound {n R : ℕ} (hn : 0 < n)
    (h : verifyResidual n R = true) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  obtain ⟨p, hp_prime, hp_div_R⟩ : ∃ p : ℕ, Nat.Prime p ∧ p ∣ R := by
    exact Nat.exists_prime_and_dvd (by unfold verifyResidual at h; aesop)
  refine' ⟨p, hp_prime, _, _⟩
  · exact dvd_trans hp_div_R (Nat.dvd_of_mod_eq_zero (by unfold verifyResidual at h; aesop))
  · intro k hk hk'; simp_all +decide [verifyResidual]
    contrapose! h
    refine' fun h => ⟨Nat.gcd k n, _, _⟩ <;> simp_all +decide [mem_properDivs]
    · exact ⟨lt_of_le_of_lt (Nat.le_of_dvd hk (Nat.gcd_dvd_left _ _)) hk', Nat.gcd_dvd_right _ _⟩
    · rw [Nat.Prime.not_coprime_iff_dvd]
      exact ⟨p, hp_prime, hp_div_R, prime_dvd_fib_gcd hp_prime ‹p ∣ Nat.fib k›
        (hp_div_R.trans (Nat.dvd_of_mod_eq_zero h.2))⟩

/-- If `checkPrimitiveExistence` returns true, F(n) has a primitive prime divisor. -/
lemma checkPrimitiveExistence_sound {n : ℕ} (hn : 0 < n)
    (h : checkPrimitiveExistence n = true) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) :=
  verifyResidual_sound hn h

/-- Soundness of the range checker. -/
lemma checkRangePrimitive_sound {lo hi : ℕ} (hlo : 0 < lo)
    (h : checkRangePrimitive lo hi = true) :
    ∀ n, lo ≤ n → n ≤ hi → ¬Nat.Prime n →
      ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  unfold checkRangePrimitive at h
  simp_all +decide [List.all_eq_true]
  intro n hn₁ hn₂ hn₃
  specialize h (n - lo) (Nat.sub_le_sub_right hn₂ _)
  rcases h with (h | h) <;> simp_all +decide [add_tsub_cancel_of_le hn₁]
  exact checkPrimitiveExistence_sound (by linarith) h

/-! ## Computational Verification

The GCD-based primitive residual algorithm is efficient enough that
`native_decide` can verify all composite n in [13, 50000].
-/

/-- Verified: all composite n ∈ [13, 50000] have a primitive prime divisor of F(n). -/
theorem fib_primitive_le_50000 : checkRangePrimitive 13 50000 = true := by native_decide

/-! ## Asymptotic case (n > 50000)

For composite n > 50000, the existence of a primitive prime divisor
follows from the Lifting-the-Exponent Lemma (LTE) for Fibonacci numbers:
for odd prime p with p | F(m) and entry point z(p) = m,

  v_p(F(m·k)) = v_p(F(m)) + v_p(k)
-- ... (truncated, full file has 184 lines)
```


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Speculative
Research mode: sorry_fill
