import Mathlib

/-!
# Existence and characterization of the Fibonacci rank of apparition

For a modulus `m ≥ 1`, the *rank of apparition* `z(m)` is the least positive index `k`
with `m ∣ F k`.  The catalog already contains the *one-directional* divisibility lemma
(`fibEntryPt_dvd_of_fib_dvd` in `Speculative.AutoResearch.CarmichaelComposite`),
which assumes the apparition exists and requires `m` to be prime.

This file **extends** that work in two directions:

* `fib_apparition_exists` — for *every* modulus `m ≥ 1` (not just primes) the rank of
  apparition exists.  This is the genuinely new, harder ingredient: it is proved by a
  finiteness / pigeonhole argument on the Fibonacci shift map over `ZMod m`, which is the
  abstract reason behind the Pisano period.  Mathlib has no Pisano-period theory, so this
  is built from scratch.
* `fib_dvd_iff_apparition_dvd` — the full **biconditional** `m ∣ F n ↔ z ∣ n`, valid for
  any modulus, strengthening the catalog's single implication.

Combining them, `fib_dvd_iff_apparitionRank_dvd` gives, for every `m ≥ 1`, a clean
characterization `m ∣ F n ↔ z(m) ∣ n` where `z(m)` is defined unconditionally.
-/

namespace FibApparition

open scoped Classical

/-- The Fibonacci "shift" permutation on pairs over `ZMod m`:
`(a, b) ↦ (b, a + b)`, with inverse `(a, b) ↦ (b - a, a)`. -/
def fibStep (m : ℕ) : ZMod m × ZMod m ≃ ZMod m × ZMod m where
  toFun p := (p.2, p.1 + p.2)
  invFun p := (p.2 - p.1, p.1)
  left_inv := by intro p; simp
  right_inv := by intro p; simp [add_comm]

-- !-- Iterating the shift map from `(0,1)` produces consecutive Fibonacci pairs;
-- proved by induction on `k` using the recurrence `F (k+2) = F k + F (k+1)`. -- !--
theorem fibStep_iterate (m k : ℕ) :
    (fibStep m)^[k] (0, 1) = ((Nat.fib k : ZMod m), (Nat.fib (k + 1) : ZMod m)) := by
  induction k <;> simp_all +decide [ Function.iterate_succ_apply' ];
  simp +decide [ fibStep, Nat.fib_add_two ]

-- !-- The shift map is a permutation of the finite set `ZMod m × ZMod m`, so its orbit
-- through `(0,1)` repeats: pigeonhole gives `i < j` with equal iterates, and injectivity
-- of the iterates yields a positive `k = j - i` with `(F k, F (k+1)) ≡ (0,1)`, i.e. `m ∣ F k`. -- !--
theorem fib_apparition_exists (m : ℕ) (hm : 0 < m) :
    ∃ k, 0 < k ∧ m ∣ Nat.fib k := by
  -- By the pigeonhole principle, since there are only $m^2$ possible pairs $(F_k \mod m, F_{k+1} \mod m)$, there must exist indices $i < j$ such that $(F_i \mod m, F_{i+1} \mod m) = (F_j \mod m, F_{j+1} \mod m)$.
  obtain ⟨i, j, hij, h_pair⟩ : ∃ i j : ℕ, i < j ∧ ((Nat.fib i : ZMod m) = (Nat.fib j : ZMod m) ∧ (Nat.fib (i + 1) : ZMod m) = (Nat.fib (j + 1) : ZMod m)) := by
    have h_pigeonhole : ∃ i j : ℕ, i < j ∧ ((Nat.fib i : ZMod m), (Nat.fib (i + 1) : ZMod m)) = ((Nat.fib j : ZMod m), (Nat.fib (j + 1) : ZMod m)) := by
      by_contra! h;
      have h_finite : Set.Finite (Set.range (fun n : ℕ => ((Nat.fib n : ZMod m), (Nat.fib (n + 1) : ZMod m)))) := by
        cases m <;> [ aesop; exact Set.toFinite _ ];
      exact h_finite.not_infinite <| Set.infinite_range_of_injective fun i j hij => le_antisymm ( le_of_not_gt fun hi => h _ _ hi hij.symm ) ( le_of_not_gt fun hj => h _ _ hj hij );
    aesop;
  induction' i with i ih generalizing j;
  · exact ⟨ j, hij, by simpa [ ← ZMod.natCast_eq_zero_iff ] using h_pair.1.symm ⟩;
  · specialize ih ( j - 1 ) ( Nat.lt_pred_iff.mpr hij ) ; rcases j <;> simp_all +decide [ Nat.fib_add_two ] ;
    grind

-- !-- Biconditional rank-of-apparition law.  Backward: `z ∣ n → F z ∣ F n → m ∣ F n`
-- via `Nat.fib_dvd`.  Forward: `m ∣ gcd (F z) (F n) = F (gcd z n)` by `Nat.fib_gcd`;
-- minimality of `z` forces `gcd z n = z`, hence `z ∣ n`. -- !--
theorem fib_dvd_iff_apparition_dvd
    (m z : ℕ) (hz : 0 < z) (hmz : m ∣ Nat.fib z)
    (hmin : ∀ k, 0 < k → m ∣ Nat.fib k → z ≤ k) (n : ℕ) :
    m ∣ Nat.fib n ↔ z ∣ n := by
  constructor <;> intro hn;
  · contrapose! hmin;
    refine' ⟨ Nat.gcd z n, Nat.pos_of_dvd_of_pos ( Nat.gcd_dvd_left _ _ ) hz, _, lt_of_le_of_ne ( Nat.le_of_dvd hz ( Nat.gcd_dvd_left _ _ ) ) _ ⟩;
    · have := Nat.dvd_gcd hmz hn; simp_all +decide [ Nat.fib_gcd ] ;
    · exact fun h => hmin <| h ▸ Nat.gcd_dvd_right _ _;
  · exact dvd_trans hmz ( by obtain ⟨ k, rfl ⟩ := hn; simp [ Nat.fib_dvd ] )

/-- The Fibonacci rank of apparition of `m`: the least positive `k` with `m ∣ F k`
(or `0` if none exists; for `m ≥ 1` existence is guaranteed by `fib_apparition_exists`). -/
noncomputable def apparitionRank (m : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ m ∣ Nat.fib k then Nat.find h else 0

theorem apparitionRank_pos {m : ℕ} (hm : 0 < m) : 0 < apparitionRank m := by
  obtain ⟨ k, hk ⟩ := fib_apparition_exists m hm;
  unfold apparitionRank; aesop;

theorem apparitionRank_dvd_fib {m : ℕ} (hm : 0 < m) : m ∣ Nat.fib (apparitionRank m) := by
  unfold apparitionRank;
  split_ifs <;> simp_all +decide [ Nat.find_spec ( fib_apparition_exists m hm ) ]

-- !-- Capstone: combine unconditional existence with the biconditional law to obtain a
-- clean divisibility characterization for every modulus `m ≥ 1`. -- !--
theorem fib_dvd_iff_apparitionRank_dvd (m : ℕ) (hm : 0 < m) (n : ℕ) :
    m ∣ Nat.fib n ↔ apparitionRank m ∣ n := by
  have := apparitionRank_dvd_fib hm;
  apply fib_dvd_iff_apparition_dvd m (apparitionRank m) (apparitionRank_pos hm) this (by
  unfold apparitionRank; aesop;) n

end FibApparition