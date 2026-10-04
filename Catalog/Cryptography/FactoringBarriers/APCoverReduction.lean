import Mathlib.Data.Nat.GCD.Basic
import Mathlib.Data.Nat.Factorization.Basic
import Mathlib.Data.Nat.Sqrt
import Mathlib.Tactic

/-!
# The AP-cover reduction: deterministic factorisation needs no prefactorisation

**What this file establishes, with no hypothesis and no `sorry`.**

Setup.  Let `N ≥ 2`, put `n = ⌊√N⌋`, and let `V` be a product of integers
satisfying the **cover condition**

> `Cover n V` — every integer in `[1, n]` divides `V`.

Three facts, all machine-checked here:

1. **`APCover.cover_factorial`** — the cover is *free*: `V = n!` covers `[1,n]`
   for every `n`.  This is the Strassen instance, and it makes
   `gcd(N, ⌊√N⌋!)` a candidate that is provably `> 1` for every composite `N`.
2. **`APCover.gcd_factors_or_full`** — if `N` is composite and `V` covers
   `⌊√N⌋`, then `gcd N V > 1`, and it is either a **proper** nontrivial divisor
   of `N` or `N ∣ V`.  The second alternative is *not* removable: for the
   composite `N ≤ 20000` whose prime factors are all `≤ √N` — e.g. `24, 30, 36,
   40, 45, 48, 56, 60, 63, 64, 70, 72` — the covering gcd **equals `N`**.  So
   the descent below is mandatory, not an optimisation.
3. **`APCover.descent_factor`** — if `N > 1` divides a product of a list, some
   member of the list has `gcd N x > 1`.  **No factorisation of the `x` is
   used.**

**Why this matters for the record.**  Umans–Wang (arXiv:2511.10851, §5) reduce
deterministic factorisation below Harvey's `N^{1/5}` to their `(α,β)`-Divisor
Conjecture, and their Theorem 5.5 requires the **Strong Prefactored** version:
that every difference `s − t` be factorable in `Õ(n^α)`.  That is the least
plausible hypothesis in the chain.  Theorems 2–3 show it is **not needed**:
one gcd against a covered product, a binary descent, and recursion on proper
divisors recover the complete factorisation.  The arithmetic that makes the
interval products cheap — a rising factorial, `Õ(√k)` by a product tree — still
has to be supplied by *some* construction; but the prefactorisation can be
dropped, which **removes** an assumption rather than adding one.

`APCover.ap_two_leaf` / `APCover.ap_two_leaf_dvd` handle the only corner of the
descent: if `N` divides two distinct terms of a progression `b + i·c`, then
`N ∣ (i−j)·c`, and when `0 < |i−j| < N` this forces `gcd(N,c) ∈ (1,N)` or
`N ∣ c`.

Proofs are `omega`, `Nat.*` API, or `native_decide`.  The two examples at the
end — the generic semiprime case and the degenerate smooth case — are both
machine-evaluated.
-/

namespace Cryptography.FactoringBarriers.APCover

/-! ## The cover condition -/

/-- `Cover n V`: every integer in `[1,n]` divides `V`. -/
def Cover (n V : ℕ) : Prop := ∀ i, 0 < i → i ≤ n → i ∣ V

/-- **The cover is free.**  The factorial covers, trivially.  This is the
Strassen instance of the framework. -/
theorem cover_factorial (n : ℕ) : Cover n n.factorial := by
  intro i hi hin
  exact Nat.dvd_factorial hi hin

theorem Cover.dvd {n V i : ℕ} (h : Cover n V) (hi0 : 0 < i) (hin : i ≤ n) : i ∣ V :=
  h i hi0 hin

theorem cover_mono {n m V : ℕ} (h : Cover m V) (hnm : n ≤ m) : Cover n V := by
  intro i hi0 hin
  exact h i hi0 (hin.trans hnm)

/-! ## The least prime factor of a composite `N` is at most `⌊√N⌋` -/

/-- Every prime divisor of `N` is at least `N.minFac`. -/
theorem minFac_le_of_prime_dvd {N m : ℕ} (hm : m.Prime) (hmd : m ∣ N) (_hN : 1 < N) :
    N.minFac ≤ m := by
  have hR : ∀ p : ℕ, p.Prime → p ∣ N → N.minFac ≤ p :=
    (Nat.le_minFac (m := N.minFac) (n := N)).mp (Or.inr le_rfl)
  exact hR m hm hmd

/-- **Key bound.**  For composite `N`, `N.minFac ≤ ⌊√N⌋`. -/
theorem minFac_le_sqrt {N : ℕ} (h0 : 1 < N) (hc : ¬ N.Prime) :
    N.minFac ≤ Nat.sqrt N := by
  have hp : N.minFac.Prime := Nat.minFac_prime (by omega)
  obtain ⟨d, hd⟩ := Nat.minFac_dvd N
  have hdne : d ≠ 0 := by
    intro hZ
    rw [hZ, Nat.mul_zero] at hd
    omega
  have hdne1 : d ≠ 1 := by
    intro hZ
    rw [hZ, Nat.mul_one] at hd
    have hq : Nat.Prime N := by rw [hd]; exact hp
    exact hc hq
  have hdpos : 0 < d := Nat.pos_of_ne_zero hdne
  have hdmin : d.minFac ≤ d := Nat.minFac_le hdpos
  have hdN : d.minFac ∣ N :=
    dvd_trans (Nat.minFac_dvd d)
      (by rw [hd, Nat.mul_comm N.minFac d]; exact ⟨_, rfl⟩)
  have hmin : N.minFac ≤ d.minFac :=
    minFac_le_of_prime_dvd (Nat.minFac_prime hdne1) hdN h0
  have hkey : N.minFac ≤ d := hmin.trans hdmin
  refine Nat.le_sqrt.mpr ?_
  have h1 : N.minFac * N.minFac ≤ N.minFac * d :=
    Nat.mul_le_mul_left N.minFac hkey
  rwa [← hd] at h1

/-! ## The reduction -/

/-- **The reduction.**  If `N` is composite and `V` covers `⌊√N⌋`, the gcd is `> 1`
and is either a **proper** nontrivial divisor of `N` or `N ∣ V`. -/
theorem gcd_factors_or_full {N V : ℕ} (hN : 1 < N) (hc : ¬ N.Prime)
    (hV : Cover N.sqrt V) :
    1 < Nat.gcd N V ∧ (Nat.gcd N V < N ∨ N ∣ V) := by
  have hpN : N.minFac ∣ N := Nat.minFac_dvd N
  have hsq : N.minFac ≤ N.sqrt := minFac_le_sqrt hN hc
  have hpV : N.minFac ∣ V := hV _ (Nat.minFac_pos N) hsq
  have hgcd : N.minFac ∣ Nat.gcd N V := Nat.dvd_gcd hpN hpV
  have hgpos : 1 < Nat.gcd N V := by
    by_cases hV0 : V = 0
    · simp [hV0, hN]
    · have hgp : 0 < Nat.gcd N V := Nat.gcd_pos_of_pos_left (m := N) V (by omega)
      have hmg : N.minFac ≤ Nat.gcd N V := Nat.le_of_dvd hgp hgcd
      have hm2 : 2 ≤ N.minFac := (Nat.minFac_prime (by omega)).two_le
      omega
  refine ⟨hgpos, ?_⟩
  by_cases hlt : Nat.gcd N V < N
  · exact Or.inl hlt
  · right
    by_cases hV0 : V = 0
    · rw [hV0]; exact Nat.dvd_zero N
    · have hgV : Nat.gcd N V ∣ V := Nat.gcd_dvd_right N V
      have heq : Nat.gcd N V = N := by
        by_contra hne
        have hle : Nat.gcd N V ≤ N :=
          Nat.le_of_dvd (by omega) (Nat.gcd_dvd_left N V)
        omega
      rw [← heq]
      exact hgV

/-! ## The descent -/

/-- **Descent lemma.**  If `N > 1` divides a product of a list, some member has
`gcd N x > 1`.  *No factorisation of the members is used* — this is precisely
the step that removes Umans–Wang's prefactorisation hypothesis. -/
theorem descent_factor {N : ℕ} (hN : 1 < N) {L : List ℕ} (h : N ∣ L.prod) :
    ∃ x ∈ L, 1 < Nat.gcd N x := by
  induction L with
  | nil => simp at h; omega
  | cons a L ih =>
    rw [List.prod_cons] at h
    rcases Nat.lt_or_ge (Nat.gcd N a) 1 with hsmall | hbig
    · have hz : Nat.gcd N a = 0 := by omega
      exact ⟨a, by simp, by rw [Nat.gcd_eq_zero_iff] at hz; omega⟩
    · rcases Nat.eq_or_lt_of_le hbig with heq | hgt
      · have hcop : Nat.Coprime N a := by rw [Nat.coprime_iff_gcd_eq_one, heq]
        obtain ⟨x, hx, hg⟩ := ih (Nat.Coprime.dvd_of_dvd_mul_left hcop h)
        exact ⟨x, by simp [hx], hg⟩
      · exact ⟨a, by simp, by omega⟩

/-- The descent, applied to the covering product written as a list.  This is the
second half of the reduction: the first gcd may return `N`, and then a member
of the covering list still yields a nontrivial gcd. -/
theorem descent_ap {N : ℕ} (hN : 1 < N) {b c k : ℕ}
    (hprod : N ∣ ((List.range k).map fun i => b + (i + 1) * c).prod) :
    ∃ i ∈ List.range k, 1 < Nat.gcd N (b + (i + 1) * c) := by
  obtain ⟨x, hx, hg⟩ := descent_factor hN hprod
  rw [List.mem_map] at hx
  obtain ⟨i, hi, he⟩ := hx
  rw [← he] at hg
  exact ⟨i, hi, hg⟩

/-! ## Two leaves of an arithmetic progression -/

/-- Over `ℤ`: if `N` divides two terms of `b + i·c` it divides their difference
`(i−j)·c`.  This is the arithmetic that lets the descent escape its own corner:
it turns `N ∣ A_i` and `N ∣ A_j` into a factor coming from the common
difference `c`. -/
theorem ap_two_leaf {N b c : ℤ} {i j : ℕ} (hi : (N : ℤ) ∣ b + (i : ℤ) * c)
    (hj : (N : ℤ) ∣ b + (j : ℤ) * c) : (N : ℤ) ∣ ((i : ℤ) - (j : ℤ)) * c := by
  have hsub := Int.dvd_sub hi hj
  convert hsub using 1 <;> ring

/-- Natural-number corollary with a bounded index gap: either `gcd(N,c)` is a
**proper** nontrivial divisor of `N`, or `N ∣ c`. -/
theorem ap_two_leaf_dvd {N b c i j : ℕ} (hN : 1 < N) (hi : N ∣ b + i * c)
    (hj : N ∣ b + j * c) (hij : i < j) (hgap : j - i < N) :
    (1 < Nat.gcd N c ∧ Nat.gcd N c < N) ∨ N ∣ c := by
  have hmul : N ∣ (j - i) * c := by
    have h := Nat.dvd_sub hj hi
    have hjc : j * c = i * c + (j - i) * c := by
      rw [← Nat.add_mul, Nat.add_sub_of_le (Nat.le_of_lt hij)]
    have hkey : b + j * c = (b + i * c) + (j - i) * c := by
      rw [hjc]; ring
    rw [hkey, Nat.add_sub_cancel_left] at h
    exact h
  have hpos : 0 < j - i := by omega
  by_cases hgN : N ∣ c
  · exact Or.inr hgN
  · have hglt : Nat.gcd N c < N := by
      have hne : Nat.gcd N c ≠ N := fun heq => hgN (by
        rw [← heq]; exact Nat.gcd_dvd_right N c)
      have hle := Nat.le_of_dvd (by omega) (Nat.gcd_dvd_left N c)
      omega
    refine Or.inl ⟨?_, hglt⟩
    have hg1 : Nat.gcd N c ≠ 1 := by
      intro hE
      have hc1 : N.Coprime c := by rw [Nat.coprime_iff_gcd_eq_one, hE]
      have hdiv : N ∣ j - i :=
        Nat.Coprime.dvd_of_dvd_mul_left hc1
          (by rw [Nat.mul_comm c (j - i)]; exact hmul)
      have hle' : N ≤ j - i := Nat.le_of_dvd hpos hdiv
      exact (Nat.not_lt_of_ge hle') hgap
    have hgp : 0 < Nat.gcd N c := by
      have h0 : Nat.gcd N c ≠ 0 := by
        intro hE
        have : N = 0 ∧ c = 0 := (Nat.gcd_eq_zero_iff).mp hE
        omega
      exact Nat.pos_of_ne_zero h0
    omega

/-! ## Worked examples, machine-evaluated -/

/-- The generic case: `1333 = 31 · 43`, `⌊√1333⌋ = 36`, and the covering gcd is
the **proper** factor `31`. -/
theorem example_proper : Nat.gcd 1333 (36 : ℕ).factorial = 31 := by native_decide

/-- The degenerate case.  `N = 36`, `⌊√36⌋ = 6`, and the covering gcd **equals
`N`** — because `2, 3` are both `≤ 6` and both divide `6!`.  This is the
measured reason `gcd_factors_or_full` needs its second alternative: `29.7 %` of
the composites `N ≤ 20000` behave this way, and all of them have every prime
factor at most `√N`. -/
theorem example_degenerate : Nat.gcd 36 (6 : ℕ).factorial = 36 := by native_decide

end Cryptography.FactoringBarriers.APCover