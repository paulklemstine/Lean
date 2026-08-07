import Mathlib

/-!
# Primitive prime divisors for composite-index Fibonacci numbers

## Provenance

The file that previously occupied this slot in the catalog was not a Lean file at
all: it was a stray fragment of a *unified diff* against a module that does not
exist in the project.  It is preserved verbatim in the comment block below so that
no user-supplied content is lost.  Its mathematical content was a single
unfinished statement, `wall_base`, asserting that

  `v_p (F(np) / F(n)) = 1`  for an odd prime `p` with `p ∣ F(n)`,

together with a proof sketch.  That statement (a form of the "Wall base case" in
the theory of the Fibonacci `p`-adic valuation) is *not* proved here: it depends on
a lifting-the-exponent computation modulo `p²` for which the catalog has no
supporting API.  Instead, this file develops, with complete proofs, the part of the
primitive-divisor theory that the `wall_base` lemma was meant to feed into: the
*rank of apparition* and its interaction with composite indices.

Original fragment (not valid Lean, retained for reference):

```
--- a/Speculative/AutoResearch/Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers.lean
+++ b/Speculative/AutoResearch/Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers.lean
@@ -99,6 +99,9 @@
     (show p ∣ Nat.fib (n + 1) from by rwa [← ZMod.natCast_eq_zero_iff]))
     (by aesop)

+/-- Key helper: F(np)/F(n) ≡ p · F(n+1)^{p-1} (mod p²).
+    Since gcd(F(n+1), p) = 1, Fermat gives F(n+1)^{p-1} ≡ 1 (mod p),
+    so F(np)/F(n) ≡ p (mod p²), hence v_p(F(np)/F(n)) = 1. -/
 -- Wall base case: v_p(F(np)/F(n)) = 1 for odd prime p | F(n)
 lemma wall_base (n p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2)
     (hpn : p ∣ Nat.fib n) (hn : 2 ≤ n) :
```

## Main results

* `FibPrimitive.exists_pos_dvd_fib` — every `m ≥ 1` divides some positive-index
  Fibonacci number (existence of the rank of apparition), proved by a pigeonhole
  argument on the state pairs `(F k, F (k+1))` in `ZMod m`.
* `FibPrimitive.dvd_fib_iff_fibRank_dvd` — `m ∣ F n ↔ rank(m) ∣ n`.
* `FibPrimitive.isPrimitiveDivisor_iff_fibRank_eq` — `m` is a primitive divisor of
  `F n` exactly when `n` is the rank of apparition of `m`.
* `FibPrimitive.fibRank_fib` — the rank of apparition of `F n` is `n` (for `n ≥ 3`).
* `FibPrimitive.not_isPrimitiveDivisor_of_dvd_proper_divisor` and
  `FibPrimitive.primitive_divisor_composite_coprime` — the composite-index
  obstruction: at a composite index `n = a * b` a primitive divisor must be coprime
  to `F a` and to `F b`.
-/

namespace FibPrimitive

open Nat

/-! ## The state pair sequence modulo `m` -/

/-- The state of the Fibonacci recursion at time `k`, read modulo `m`. -/
private def fibState (m k : ℕ) : ZMod m × ZMod m := ((Nat.fib k : ZMod m), (Nat.fib (k + 1) : ZMod m))

/-- The Fibonacci recursion is *reversible*: equal states at times `i+1` and `j+1`
force equal states at times `i` and `j`. -/
private lemma fibState_step_inj (m i j : ℕ) (h : fibState m (i + 1) = fibState m (j + 1)) :
    fibState m i = fibState m j := by
  obtain ⟨h1, h2⟩ := Prod.mk.injEq .. ▸ h
  have h1' : (Nat.fib (i + 1) : ZMod m) = (Nat.fib (j + 1) : ZMod m) := h1
  have h2' : (Nat.fib (i + 2) : ZMod m) = (Nat.fib (j + 2) : ZMod m) := h2
  have hi : (Nat.fib (i + 2) : ZMod m) = (Nat.fib i : ZMod m) + (Nat.fib (i + 1) : ZMod m) := by
    rw [Nat.fib_add_two]; push_cast; ring
  have hj : (Nat.fib (j + 2) : ZMod m) = (Nat.fib j : ZMod m) + (Nat.fib (j + 1) : ZMod m) := by
    rw [Nat.fib_add_two]; push_cast; ring
  have : (Nat.fib i : ZMod m) = (Nat.fib j : ZMod m) := by
    have := h2'
    rw [hi, hj, h1'] at this
    exact add_right_cancel this
  exact Prod.ext this h1'

/-- Rewinding a coincidence of states all the way to time `0`. -/
private lemma fibState_zero_eq (m d : ℕ) : ∀ i, fibState m i = fibState m (i + d) →
    fibState m 0 = fibState m d := by
  intro i
  induction i with
  | zero => intro h; simpa using h
  | succ k ih =>
      intro h
      refine ih (fibState_step_inj m k (k + d) ?_)
      simpa [Nat.add_right_comm] using h

/-- **Existence of the rank of apparition.** Every positive `m` divides a Fibonacci
number of positive index.  The proof is a pigeonhole argument: the state map
`k ↦ (F k, F (k+1))` from `ℕ` to the finite set `ZMod m × ZMod m` cannot be
injective, and the recursion can be run backwards, so the coincidence propagates
down to index `0`, where `F 0 = 0`. -/
theorem exists_pos_dvd_fib (m : ℕ) (hm : 0 < m) : ∃ n, 0 < n ∧ m ∣ Nat.fib n := by
  haveI : NeZero m := ⟨by omega⟩
  obtain ⟨i, j, hij, hfe⟩ :=
    Finite.exists_ne_map_eq_of_infinite (fibState m)
  -- reduce to the case `i < j`
  rcases lt_or_gt_of_ne hij with hlt | hlt
  · refine ⟨j - i, by omega, ?_⟩
    have h : fibState m i = fibState m (i + (j - i)) := by
      rw [show i + (j - i) = j by omega]; exact hfe
    have h0 := fibState_zero_eq m (j - i) i h
    have : ((Nat.fib (j - i) : ℕ) : ZMod m) = 0 := by
      have := congrArg Prod.fst h0
      simpa [fibState] using this.symm
    exact (ZMod.natCast_eq_zero_iff _ m).mp this
  · refine ⟨i - j, by omega, ?_⟩
    have h : fibState m j = fibState m (j + (i - j)) := by
      rw [show j + (i - j) = i by omega]; exact hfe.symm
    have h0 := fibState_zero_eq m (i - j) j h
    have : ((Nat.fib (i - j) : ℕ) : ZMod m) = 0 := by
      have := congrArg Prod.fst h0
      simpa [fibState] using this.symm
    exact (ZMod.natCast_eq_zero_iff _ m).mp this

/-! ## The rank of apparition -/

/-- The **rank of apparition** of `m`: the least positive index `n` with `m ∣ F n`
(and `0` if no such index exists, which by `exists_pos_dvd_fib` happens only for
`m = 0`). -/
noncomputable def fibRank (m : ℕ) : ℕ := sInf {n | 0 < n ∧ m ∣ Nat.fib n}

lemma fibRank_mem (m : ℕ) (hm : 0 < m) : 0 < fibRank m ∧ m ∣ Nat.fib (fibRank m) :=
  Nat.sInf_mem (exists_pos_dvd_fib m hm)

lemma fibRank_pos (m : ℕ) (hm : 0 < m) : 0 < fibRank m := (fibRank_mem m hm).1

lemma dvd_fib_fibRank (m : ℕ) (hm : 0 < m) : m ∣ Nat.fib (fibRank m) := (fibRank_mem m hm).2

lemma fibRank_le {m n : ℕ} (hn : 0 < n) (h : m ∣ Nat.fib n) : fibRank m ≤ n :=
  Nat.sInf_le ⟨hn, h⟩

/-- **The divisibility criterion.** `m` divides `F n` exactly when the rank of
apparition of `m` divides `n`.  The forward direction uses the strong divisibility
law `gcd (F a) (F b) = F (gcd a b)`. -/
theorem dvd_fib_iff_fibRank_dvd (m : ℕ) (hm : 0 < m) (n : ℕ) :
    m ∣ Nat.fib n ↔ fibRank m ∣ n := by
  constructor
  · intro h
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · exact dvd_zero _
    have hg : m ∣ Nat.fib (Nat.gcd n (fibRank m)) := by
      rw [Nat.fib_gcd]
      exact Nat.dvd_gcd h (dvd_fib_fibRank m hm)
    have hgpos : 0 < Nat.gcd n (fibRank m) := Nat.gcd_pos_of_pos_left _ hn
    have hle : fibRank m ≤ Nat.gcd n (fibRank m) := fibRank_le hgpos hg
    have hge : Nat.gcd n (fibRank m) ≤ fibRank m :=
      Nat.le_of_dvd (fibRank_pos m hm) (Nat.gcd_dvd_right _ _)
    have : Nat.gcd n (fibRank m) = fibRank m := le_antisymm hge hle
    exact this ▸ Nat.gcd_dvd_left n (fibRank m)
  · intro h
    exact dvd_trans (dvd_fib_fibRank m hm) (Nat.fib_dvd _ _ h)

/-! ## Primitive divisors -/

/-- `m` is a **primitive divisor** of `F n` if it divides `F n` but no earlier
Fibonacci number of positive index. -/
def IsPrimitiveDivisor (m n : ℕ) : Prop :=
  m ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬ m ∣ Nat.fib k

/-- Primitive divisors of `F n` are exactly the numbers of rank of apparition `n`. -/
theorem isPrimitiveDivisor_iff_fibRank_eq (m n : ℕ) (hm : 0 < m) (hn : 0 < n) :
    IsPrimitiveDivisor m n ↔ fibRank m = n := by
  constructor
  · rintro ⟨hdvd, hmin⟩
    have hle : fibRank m ≤ n := fibRank_le hn hdvd
    by_contra hne
    exact hmin (fibRank m) (fibRank_pos m hm) (lt_of_le_of_ne hle hne)
      (dvd_fib_fibRank m hm)
  · intro h
    refine ⟨h ▸ dvd_fib_fibRank m hm, fun k hk hkn hdvd => ?_⟩
    have := fibRank_le hk hdvd
    omega

/-- The rank of apparition of `F n` is `n` itself, for `n ≥ 3`.  (The hypothesis is
needed: `F 1 = F 2 = 1` has rank `1`.) -/
theorem fibRank_fib (n : ℕ) (hn : 3 ≤ n) : fibRank (Nat.fib n) = n := by
  have hpos : 0 < Nat.fib n := Nat.fib_pos.mpr (by omega)
  refine ((isPrimitiveDivisor_iff_fibRank_eq _ n hpos (by omega)).mp ⟨dvd_rfl, ?_⟩)
  intro k hk hkn hdvd
  have hkpos : 0 < Nat.fib k := Nat.fib_pos.mpr hk
  have hle : Nat.fib n ≤ Nat.fib k := Nat.le_of_dvd hkpos hdvd
  have hmono : Nat.fib k ≤ Nat.fib (n - 1) := Nat.fib_mono (by omega)
  have hlt : Nat.fib (n - 1) < Nat.fib n := by
    have := Nat.fib_lt_fib_succ (n := n - 1) (by omega)
    rwa [show n - 1 + 1 = n by omega] at this
  omega

/-! ## The composite-index obstruction -/

/-- At index `n`, no divisor of `F a` for a proper positive divisor `a` of `n` can be
a primitive divisor. -/
theorem not_isPrimitiveDivisor_of_dvd_proper_divisor {m n a : ℕ}
    (ha : 0 < a) (han : a < n) (hdvd : m ∣ Nat.fib a) : ¬ IsPrimitiveDivisor m n := by
  rintro ⟨-, hmin⟩
  exact hmin a ha han hdvd

/-- **Composite index.** If `n = a * b` with `1 < a` and `1 < b`, then any primitive
divisor `m > 1` of `F n` is coprime to both `F a` and `F b`. -/
theorem primitive_divisor_composite_coprime {m n a b : ℕ}
    (hprime : Nat.Prime m) (hn : n = a * b) (ha : 1 < a) (hb : 1 < b)
    (hP : IsPrimitiveDivisor m n) :
    Nat.Coprime m (Nat.fib a) ∧ Nat.Coprime m (Nat.fib b) := by
  subst hn
  have halt : a < a * b := by nlinarith
  have hblt : b < a * b := by nlinarith
  constructor
  · rw [Nat.Prime.coprime_iff_not_dvd hprime]
    exact fun hd => hP.2 a (by omega) halt hd
  · rw [Nat.Prime.coprime_iff_not_dvd hprime]
    exact fun hd => hP.2 b (by omega) hblt hd

/-- Consequently a prime primitive divisor of a composite-index Fibonacci number has
rank of apparition equal to that composite index — in particular its rank is *not*
prime. -/
theorem fibRank_eq_of_primitive_composite {m a b : ℕ} (hm : 0 < m)
    (ha : 1 < a) (hb : 1 < b) (hP : IsPrimitiveDivisor m (a * b)) :
    fibRank m = a * b :=
  (isPrimitiveDivisor_iff_fibRank_eq m (a * b) hm (by positivity)).mp hP

/-- A concrete instance: `F 12 = 144` and `m = 144` is a primitive divisor of it, so
its rank of apparition is the composite index `12`. -/
example : fibRank 144 = 12 := by
  have : Nat.fib 12 = 144 := by decide
  simpa [this] using fibRank_fib 12 (by norm_num)

end FibPrimitive