import Mathlib

/-! # The Fibonacci Entry-Point Characterization Theorem

This file develops, from scratch and self-contained, the *complete* divisibility
characterization for Fibonacci numbers via the **entry point** (a.k.a. rank of
apparition) of a prime.

For a prime `p`, the *entry point* `α(p)` is the least positive index `k` with
`p ∣ F(k)`.  The central result (`fib_dvd_iff_entryPt_dvd`) is that, once `p` has
*any* entry point at all,
$$ p \mid F(k) \iff \alpha(p) \mid k \qquad (\forall k \ge 0). $$
That is, the index set `{k | p ∣ F(k)}` is exactly the principal ideal `(α(p))`
of `ℕ`.  From this we read off:

* a clean characterization of **primitive prime divisors** of `F(n)` as the
  primes whose entry point equals `n` (`entryPt_eq_iff_primitive`);
* the set-level statement that `{k | p ∣ F(k)} = {k | α(p) ∣ k}`
  (`fib_dvd_setOf_eq_multiples`);
* the *boundary counterexample* `F(12) = 144` which has **no** primitive prime
  divisor — the structural reason Carmichael's theorem must exclude `n = 12`.

## Catalog synthesis

This extends the entry-point lemmas appearing in
`Speculative/AutoResearch/CarmichaelComposite.lean`
(`fibEntryPt`, `fibEntryPt_dvd_of_fib_dvd`, `primitive_of_entryPt_eq`) and
`Shared/CarmichaelProof.lean` (`bridge_lemma`), promoting their one-directional
statements to a full *iff* characterization and isolating the `n = 12` boundary
case that those files' computational range silently steps over.  The key engine
is Mathlib's `Nat.fib_gcd` and `Nat.fib_dvd`, mirroring `fib_dvd_gcd_of_dvd` in
the catalog.

-- !-- Lab Notebook: fib_dvd_iff_entryPt_dvd -- !--
-- !-- Hypothesis: divisibility p ∣ F(k) is governed *entirely* by the entry point, so the index set should be a principal ideal of ℕ. -- !--
-- !-- Result: Proved the full iff for all k (incl. k = 0) under the sole hypothesis that p has an entry point. -- !--
-- !-- Insight: The forward direction is a `gcd` minimality argument (p ∣ F(α) and p ∣ F(k) ⟹ p ∣ F(gcd α k), then gcd α k = α); the backward direction is pure `Nat.fib_dvd`. The k = 0 edge case is free since F 0 = 0. -- !--
-- !-- Failure analysis: Catalog files only ever proved `entryPt ∣ n` (forward, k > 0). Upgrading to an iff over all k removes the awkward positivity side-conditions that those proofs carried around. -- !--
-- !-- End Lab Notebook -- !--

## Theorem declarations (Step 1)

1. `fib_dvd_gcd_of_dvd`: `p ∣ F n` and `p ∣ F k` give `p ∣ F (gcd n k)` — proved —
   the gcd backbone — confirms `F` respects gcd-divisibility.
2. `fibEntryPt_pos` / `fib_dvd_fibEntryPt` / `fibEntryPt_min`: the entry point is a
   positive apparition index with the minimality property — proved — basic API.
3. `fib_dvd_iff_entryPt_dvd`: `p ∣ F k ↔ α(p) ∣ k` for all `k` — proved — shows the
   index set is the principal ideal `(α(p))`; if false, divisibility would not be
   ideal-structured.
4. `fib_dvd_setOf_eq_multiples`: set form `{k | p ∣ F k} = {k | α(p) ∣ k}` — proved.
5. `entryPt_eq_iff_primitive`: `p` primitive divisor of `F n` ↔ `α(p) = n` — proved —
   recasts Carmichael's theorem as surjectivity of `α`.
6. `fib_twelve_no_primitive`: `F 12` has no primitive prime divisor — proved —
   the `n = 12` boundary; teaches why Carmichael must exclude it.
7. `fibEntryPt_mul_coprime`: `α(a·b) = lcm(α a, α b)` for coprime `a,b` — proved —
   lets `α` be reconstructed from the factorization.
-/

namespace FibEntryChar

open Classical in
/-- The Fibonacci **entry point** of `p`: the least `k > 0` with `p ∣ F(k)`,
or `0` if no such `k` exists. -/
noncomputable def fibEntryPt (p : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ p ∣ Nat.fib k then Nat.find h else 0

/-
If `p ∣ F(n)` and `p ∣ F(k)` then `p ∣ F(gcd n k)` (mirrors the catalog's
`fib_dvd_gcd_of_dvd`).
-/
lemma fib_dvd_gcd_of_dvd {p n k : ℕ} (hn : p ∣ Nat.fib n) (hk : p ∣ Nat.fib k) :
    p ∣ Nat.fib (Nat.gcd n k) := by
  have h_gcd : Nat.fib (Nat.gcd n k) = Nat.gcd (Nat.fib n) (Nat.fib k) :=
    Nat.fib_gcd n k
  exact h_gcd ▸ Nat.dvd_gcd hn hk

/-
Under the existence hypothesis, the entry point is positive.
-/
lemma fibEntryPt_pos {p : ℕ} (h : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
    0 < fibEntryPt p := by
  unfold fibEntryPt; aesop;

/-
Under the existence hypothesis, `p ∣ F(α(p))`.
-/
lemma fib_dvd_fibEntryPt {p : ℕ} (h : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
    p ∣ Nat.fib (fibEntryPt p) := by
  unfold fibEntryPt;
  grind

/-
Minimality of the entry point: no smaller positive index works.
-/
lemma fibEntryPt_min {p : ℕ} (h : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
    ∀ m, 0 < m → m < fibEntryPt p → ¬ p ∣ Nat.fib m := by
  unfold fibEntryPt;
  grind +suggestions

/-! ## The characterization theorem -/

/-
!-- Lab Notebook: fib_dvd_iff_entryPt_dvd (main) -- !--
!-- Hypothesis: {k | p ∣ F k} = multiples of α(p). -- !--
!-- Result: full iff for all k. -- !--
!-- Insight: gcd-minimality (forward) + Nat.fib_dvd (backward). -- !--
!-- Failure analysis: none; decomposition into the four helper lemmas above made it routine. -- !--
!-- End Lab Notebook -- !--

**Entry-Point Characterization Theorem.**  If the prime-power `p` divides some
positive-index Fibonacci number, then for *every* `k`,
`p ∣ F(k) ↔ α(p) ∣ k`.
-/
theorem fib_dvd_iff_entryPt_dvd {p : ℕ} (h : ∃ k, 0 < k ∧ p ∣ Nat.fib k) (k : ℕ) :
    p ∣ Nat.fib k ↔ fibEntryPt p ∣ k := by
  use fun h => ?_;
  · intro hk;
    exact dvd_trans ( fib_dvd_fibEntryPt h ) ( Nat.fib_dvd _ _ hk );
  · by_contra h_contra;
    -- By definition of gcd, we know that gcd(fibEntryPt p, k) < fibEntryPt p.
    have h_gcd_lt : Nat.gcd (fibEntryPt p) k < fibEntryPt p := by
      exact lt_of_le_of_ne ( Nat.le_of_dvd ( fibEntryPt_pos ‹_› ) ( Nat.gcd_dvd_left _ _ ) ) fun con => h_contra <| con ▸ Nat.gcd_dvd_right _ _;
    exact h_gcd_lt.not_ge ( Nat.le_of_not_gt fun h_l => fibEntryPt_min ‹_› _ ( Nat.gcd_pos_of_pos_left _ ( fibEntryPt_pos ‹_› ) ) h_l <| fib_dvd_gcd_of_dvd ( fib_dvd_fibEntryPt ‹_› ) h )

/-
Set-level form: the index set of `p` is exactly the principal ideal
`(α(p))`.
-/
theorem fib_dvd_setOf_eq_multiples {p : ℕ} (h : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
    {k | p ∣ Nat.fib k} = {k | fibEntryPt p ∣ k} := by
  ext k; exact fib_dvd_iff_entryPt_dvd h k;

/-! ## Primitive prime divisors -/

/-
!-- Lab Notebook: entryPt_eq_iff_primitive -- !--
!-- Hypothesis: p is a primitive prime divisor of F(n) iff α(p) = n. -- !--
!-- Result: proved as an iff using the characterization theorem. -- !--
!-- Insight: primitivity = "no smaller positive index divides", which is exactly the statement that the least multiple of α(p) in range is n itself, forcing α(p) = n. -- !--
!-- Failure analysis: needed the existence hypothesis to be derivable from p ∣ F(n) with n > 0, which it is (n witnesses it). -- !--
!-- End Lab Notebook -- !--

A prime divisor `p ∣ F(n)` (with `n > 0`) is **primitive** — meaning it divides
no earlier positive-index Fibonacci number — **iff** its entry point is exactly `n`.
-/
theorem entryPt_eq_iff_primitive {p n : ℕ} (hn : 0 < n)
    (hpn : p ∣ Nat.fib n) :
    fibEntryPt p = n ↔ ∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k := by
  constructor <;> intro h;
  · intro k hk hk'; have := fibEntryPt_min ( show ∃ k, 0 < k ∧ p ∣ Nat.fib k from ⟨ n, hn, hpn ⟩ ) k hk; aesop;
  · refine' le_antisymm _ _ <;> contrapose! h;
    · exact absurd ( fibEntryPt_min ( show ∃ k, 0 < k ∧ p ∣ Nat.fib k from ⟨ n, hn, hpn ⟩ ) n hn h ) ( by aesop );
    · exact ⟨ fibEntryPt p, fibEntryPt_pos ⟨ n, hn, hpn ⟩, h, fib_dvd_fibEntryPt ⟨ n, hn, hpn ⟩ ⟩

/-! ## Boundary case: `F(12) = 144` has no primitive prime divisor

This is the structural obstruction that forces Carmichael's primitive-divisor
theorem to exclude `n = 12`.  The only primes dividing `F(12) = 144 = 2^4·3^2`
are `2` (with `2 ∣ F(3)`) and `3` (with `3 ∣ F(4)`); both have entry point `< 12`.
-/

/-
!-- Lab Notebook: fib_twelve_no_primitive -- !--
!-- Hypothesis: F(12) breaks the "every F(n) has a primitive divisor" pattern. -- !--
!-- Result: proved no prime is a primitive divisor of F(12). -- !--
!-- Insight: F(12)=144 has prime support {2,3}; 2∣F(3) and 3∣F(4) kill primitivity. A finite, fully explicit obstruction. -- !--
!-- Failure analysis: a counterexample, not a proof of the general theorem — it pins down *why* the general theorem needs n ∉ {1,2,6,12}. -- !--
!-- End Lab Notebook -- !--

**Boundary counterexample.** `F(12) = 144` has no primitive prime divisor.
This is exactly the case Carmichael's theorem must exclude.
-/
theorem fib_twelve_no_primitive :
    ¬ ∃ p, Nat.Prime p ∧ p ∣ Nat.fib 12 ∧ ∀ k, 0 < k → k < 12 → ¬ p ∣ Nat.fib k := by
  norm_num at *;
  intro x hx hx'; have := Nat.le_of_dvd ( by decide ) hx'; interval_cases x <;> norm_num at *;
  · exists 3;
  · exists 4

/-! ## A generalization (now proved): the lcm law for entry points

The characterization theorem `fib_dvd_iff_entryPt_dvd` already holds for an
*arbitrary* modulus `m` (its proof never uses primality of `p`), so the index set
of any `m` with an entry point is the principal ideal `(α(m))`.  The natural next
step is to compute `α` for composite moduli.  We conjecture the **lcm law**: for
coprime `a, b` each admitting an entry point,
`α(a·b) = lcm(α(a), α(b))`.  This is the engine behind reconstructing `α(m)` from
the entry points of the prime powers in `m`'s factorization.  The boundary is the
coprimality hypothesis: without it `α(a·b)` can be strictly smaller than the lcm
(shared prime factors collapse). -/

/-
!-- Lab Notebook: fibEntryPt_mul_coprime -- !--
!-- Hypothesis: for coprime a,b the apparition index of a*b is lcm(α a, α b). -- !--
!-- Result: proved. -- !--
!-- Insight: (a*b) ∣ F(k) ↔ (a∣F(k) ∧ b∣F(k)) by coprimality, which by the characterization theorem is ↔ (α a ∣ k ∧ α b ∣ k) ↔ lcm ∣ k. Two principal ideals of ℕ coincide ⟹ generators equal. -- !--
!-- Failure analysis: the product needs its own entry-point existence witness; k = lcm(α a, α b) supplies it. -- !--
!-- End Lab Notebook -- !--

**Theorem (lcm law for entry points).** For coprime `a, b` each admitting a
positive index of apparition, the entry point of the product is the lcm of the
entry points.  Proved via the characterization theorem `fib_dvd_iff_entryPt_dvd`.
-/
theorem fibEntryPt_mul_coprime {a b : ℕ}
    (hab : Nat.Coprime a b)
    (ha : ∃ k, 0 < k ∧ a ∣ Nat.fib k) (hb : ∃ k, 0 < k ∧ b ∣ Nat.fib k) :
    fibEntryPt (a * b) = Nat.lcm (fibEntryPt a) (fibEntryPt b) := by
  obtain ⟨ k₁, hk₁ ⟩ := ha
  obtain ⟨ k₂, hk₂ ⟩ := hb
  set L := Nat.lcm (fibEntryPt a) (fibEntryPt b)
  have hL_pos : 0 < L := by
    exact Nat.lcm_pos ( fibEntryPt_pos ⟨ k₁, hk₁ ⟩ ) ( fibEntryPt_pos ⟨ k₂, hk₂ ⟩ )
  have hL_dvd : a * b ∣ Nat.fib L := by
    have hL_dvd : a ∣ Nat.fib L ∧ b ∣ Nat.fib L := by
      exact ⟨ fib_dvd_iff_entryPt_dvd ( show ∃ k, 0 < k ∧ a ∣ Nat.fib k from ⟨ k₁, hk₁ ⟩ ) L |>.2 ( Nat.dvd_lcm_left _ _ ), fib_dvd_iff_entryPt_dvd ( show ∃ k, 0 < k ∧ b ∣ Nat.fib k from ⟨ k₂, hk₂ ⟩ ) L |>.2 ( Nat.dvd_lcm_right _ _ ) ⟩;
    exact Nat.Coprime.mul_dvd_of_dvd_of_dvd hab hL_dvd.1 hL_dvd.2
  have hL : fibEntryPt (a * b) ∣ L := by
    exact fib_dvd_iff_entryPt_dvd ⟨ L, hL_pos, hL_dvd ⟩ L |>.1 hL_dvd
  have hL' : L ∣ fibEntryPt (a * b) := by
    have hL' : a ∣ Nat.fib (fibEntryPt (a * b)) ∧ b ∣ Nat.fib (fibEntryPt (a * b)) := by
      exact ⟨ Nat.dvd_trans ( dvd_mul_right _ _ ) ( fib_dvd_fibEntryPt ⟨ L, hL_pos, hL_dvd ⟩ ), Nat.dvd_trans ( dvd_mul_left _ _ ) ( fib_dvd_fibEntryPt ⟨ L, hL_pos, hL_dvd ⟩ ) ⟩;
    exact Nat.lcm_dvd ( fib_dvd_iff_entryPt_dvd ( show ∃ k, 0 < k ∧ a ∣ Nat.fib k from ⟨ k₁, hk₁ ⟩ ) _ |>.1 hL'.1 ) ( fib_dvd_iff_entryPt_dvd ( show ∃ k, 0 < k ∧ b ∣ Nat.fib k from ⟨ k₂, hk₂ ⟩ ) _ |>.1 hL'.2 )
  exact Nat.dvd_antisymm hL hL' ▸ rfl

end FibEntryChar