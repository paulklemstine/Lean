import Mathlib

/-! # Reconstructing the Fibonacci entry point from divisibility structure

This file extends the **entry-point characterization** developed in
`Speculative/AutoResearch/FibonacciEntryPointCharacterization.lean`
(`fibEntryPt`, `fib_dvd_iff_entryPt_dvd`, `entryPt_eq_iff_primitive`,
`fibEntryPt_mul_coprime`).  To stay self-contained — the convention used by every
file in this catalog — we re-establish the small entry-point API under the fresh
namespace `FibEntryRecon` and then prove the genuinely new results:

* `fibEntryPt_dvd_of_dvd` — **monotonicity**: if `a ∣ b` and `b` has an entry
  point then `α(a) ∣ α(b)`.  This is the structural fact behind the lcm law and
  needs no coprimality.
* `fibEntryPt_fib` — **fixed-point law**: for `n ≥ 3`, `α(F n) = n`.  The rank of
  apparition of a Fibonacci number is its own index; equivalently `α` is a left
  inverse of `F` on `[3, ∞)`, hence surjective onto `{n | 3 ≤ n}`.
* `fibEntryPt_lcm_dvd` — **general lower bound**: whenever `a·b` has an entry
  point, `lcm(α a, α b) ∣ α(a·b)` *without* any coprimality hypothesis.
* `fibEntryPt_two` / `fibEntryPt_four` / `fibEntryPt_lcm_strict` — the **sharp
  boundary**: `α(2·2) = α(4) = 6` while `lcm(α 2, α 2) = 3`, so the lcm law genuinely
  fails without coprimality, and (correcting the heuristic in the parent file)
  `α(a·b)` comes out a strict *multiple* — strictly **larger** — not smaller.

## Catalog synthesis

Re-derives and builds on the entry-point engine of
`FibonacciEntryPointCharacterization.lean` (`fib_dvd_iff_entryPt_dvd`,
`fib_dvd_fibEntryPt`, `fibEntryPt_pos`, `entryPt_eq_iff_primitive`) and connects to
`Shared/CarmichaelProof.lean`'s `bridge_lemma` and `CarmichaelComposite.lean`'s
one-directional apparition lemmas.  The monotonicity result generalizes those
one-directional lemmas, and the fixed-point law `α(F n) = n` is the converse
viewpoint to the catalog's "primitive divisor of `F n`" search: `F n` is *itself*
the canonical witness whose apparition index is exactly `n`.

## Theorem declarations (Step 1)

1. `fibEntryPt_dvd_of_dvd`: `a ∣ b ⟹ α(a) ∣ α(b)` — proved — entry point is
   monotone under divisibility of the modulus; if false, `α` would not respect the
   divisibility lattice.
2. `fibEntryPt_fib`: `α(F n) = n` for `n ≥ 3` — proved — `α` left-inverts `F`;
   shows `α` is surjective onto `[3,∞)`.
3. `fibEntryPt_lcm_dvd`: `lcm(α a, α b) ∣ α(a·b)` unconditionally — proved — the
   always-valid half of the lcm law.
4. `fibEntryPt_two` / `fibEntryPt_four`: `α(2)=3`, `α(4)=6` — proved — explicit
   apparition indices.
5. `fibEntryPt_lcm_strict`: `α(2·2) ≠ lcm(α 2, α 2)` — disproved (counterexample to
   the naive lcm law) — pins the boundary of `fibEntryPt_mul_coprime`.
-/

namespace FibEntryRecon

open Classical in
/-- The Fibonacci **entry point** of `m`: the least `k > 0` with `m ∣ F(k)`,
or `0` if no such `k` exists. -/
noncomputable def fibEntryPt (m : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ m ∣ Nat.fib k then Nat.find h else 0

/-! ## Re-derived entry-point API (self-contained) -/

lemma fib_dvd_gcd_of_dvd {p n k : ℕ} (hn : p ∣ Nat.fib n) (hk : p ∣ Nat.fib k) :
    p ∣ Nat.fib (Nat.gcd n k) := by
  have h_gcd : Nat.fib (Nat.gcd n k) = Nat.gcd (Nat.fib n) (Nat.fib k) :=
    Nat.fib_gcd n k
  exact h_gcd ▸ Nat.dvd_gcd hn hk

lemma fibEntryPt_pos {p : ℕ} (h : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
    0 < fibEntryPt p := by
  unfold fibEntryPt; aesop

lemma fib_dvd_fibEntryPt {p : ℕ} (h : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
    p ∣ Nat.fib (fibEntryPt p) := by
  unfold fibEntryPt; grind

lemma fibEntryPt_min {p : ℕ} (h : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
    ∀ m, 0 < m → m < fibEntryPt p → ¬ p ∣ Nat.fib m := by
  unfold fibEntryPt; grind +suggestions

theorem fib_dvd_iff_entryPt_dvd {p : ℕ} (h : ∃ k, 0 < k ∧ p ∣ Nat.fib k) (k : ℕ) :
    p ∣ Nat.fib k ↔ fibEntryPt p ∣ k := by
  use fun h => ?_
  · intro hk
    exact dvd_trans (fib_dvd_fibEntryPt h) (Nat.fib_dvd _ _ hk)
  · by_contra h_contra
    have h_gcd_lt : Nat.gcd (fibEntryPt p) k < fibEntryPt p := by
      exact lt_of_le_of_ne (Nat.le_of_dvd (fibEntryPt_pos ‹_›) (Nat.gcd_dvd_left _ _))
        fun con => h_contra <| con ▸ Nat.gcd_dvd_right _ _
    exact h_gcd_lt.not_ge (Nat.le_of_not_gt fun h_l =>
      fibEntryPt_min ‹_› _ (Nat.gcd_pos_of_pos_left _ (fibEntryPt_pos ‹_›)) h_l <|
        fib_dvd_gcd_of_dvd (fib_dvd_fibEntryPt ‹_›) h)

theorem entryPt_eq_iff_primitive {p n : ℕ} (hn : 0 < n) (hpn : p ∣ Nat.fib n) :
    fibEntryPt p = n ↔ ∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k := by
  constructor <;> intro h
  · intro k hk hk'
    have := fibEntryPt_min (show ∃ k, 0 < k ∧ p ∣ Nat.fib k from ⟨n, hn, hpn⟩) k hk; aesop
  · refine' le_antisymm _ _ <;> contrapose! h
    · exact absurd (fibEntryPt_min (show ∃ k, 0 < k ∧ p ∣ Nat.fib k from ⟨n, hn, hpn⟩) n hn h)
        (by aesop)
    · exact ⟨fibEntryPt p, fibEntryPt_pos ⟨n, hn, hpn⟩, h, fib_dvd_fibEntryPt ⟨n, hn, hpn⟩⟩

/-! ## Monotonicity of the entry point under divisibility -/

/-
!-- Lab Notebook: fibEntryPt_dvd_of_dvd -- !--
!-- Hypothesis: divisibility of moduli should be reflected by divisibility of entry points: a ∣ b ⟹ α(a) ∣ α(b). -- !--
!-- Result: Proved (sorry = 0), with no coprimality hypothesis. -- !--
!-- Insight: a ∣ b together with b ∣ F(α b) gives a ∣ F(α b), so a inherits an entry point, and the characterization theorem turns "a ∣ F(α b)" directly into "α a ∣ α b". -- !--
!-- Failure analysis: The only thing to supply is the existence witness for a's entry point, which is forced (α b itself witnesses it). -- !--
!-- End Lab Notebook -- !--

**Monotonicity.** If `a ∣ b` and `b` admits a positive index of apparition, then
`α(a) ∣ α(b)`.
-/
theorem fibEntryPt_dvd_of_dvd {a b : ℕ} (hab : a ∣ b)
    (hb : ∃ k, 0 < k ∧ b ∣ Nat.fib k) :
    fibEntryPt a ∣ fibEntryPt b := by
  -- By (fib_dvd_iff_entryPt_dvd hab' hb'), we get hb' ∣ hb.
  have h_div : a ∣ Nat.fib (fibEntryPt b) := by
    exact dvd_trans hab ( fib_dvd_fibEntryPt hb );
  apply (fib_dvd_iff_entryPt_dvd _ _).mp h_div;
  exact ⟨ _, fibEntryPt_pos hb, h_div ⟩

/-! ## The fixed-point law: `α(F n) = n` -/

/-
!-- Lab Notebook: fibEntryPt_fib -- !--
!-- Hypothesis: the rank of apparition of a Fibonacci number F(n) is n itself, for n ≥ 3. -- !--
!-- Result: Proved (sorry = 0) for n ≥ 3. -- !--
!-- Insight: F(n) ∣ F(n) trivially, and for 0 < k < n we have 0 < F(k) ≤ F(n-1) < F(n) (strict monotonicity from index 2 on), so a positive number strictly below F(n) cannot be a multiple of F(n); primitivity then forces α = n via entryPt_eq_iff_primitive. -- !--
!-- Failure analysis: n = 2 is excluded because F(2) = 1 = F(1) so α(1) = 1 ≠ 2; the strict-monotonicity step is exactly what needs n ≥ 3. -- !--
!-- End Lab Notebook -- !--

**Fixed-point law.** For `n ≥ 3`, the entry point of `F n` equals `n`.
Equivalently, `α` is a left inverse of `F` on `[3, ∞)`, so `α` is surjective onto
`{n | 3 ≤ n}`.
-/
theorem fibEntryPt_fib {n : ℕ} (hn : 3 ≤ n) :
    fibEntryPt (Nat.fib n) = n := by
  apply (entryPt_eq_iff_primitive (by linarith) (dvd_refl (Nat.fib n))).mpr;
  intro k hk hk';
  -- Since $k < n$, we have $F(k) < F(n)$ by the strict monotonicity of the Fibonacci sequence.
  have h_fib_lt : Nat.fib k < Nat.fib n := by
    grind +suggestions;
  exact Nat.not_dvd_of_pos_of_lt ( Nat.fib_pos.mpr hk ) h_fib_lt

/-! ## General lower bound for the entry point of a product -/

/-
!-- Lab Notebook: fibEntryPt_lcm_dvd -- !--
!-- Hypothesis: even without coprimality, lcm(α a, α b) divides α(a·b) whenever a·b has an entry point. -- !--
!-- Result: Proved (sorry = 0). -- !--
!-- Insight: a ∣ a·b and b ∣ a·b, so monotonicity gives α a ∣ α(ab) and α b ∣ α(ab); Nat.lcm_dvd then combines them. This is exactly the "≥" half of the lcm law and is unconditional. -- !--
!-- Failure analysis: the reverse divisibility α(ab) ∣ lcm is what genuinely needs coprimality (see fibEntryPt_lcm_strict). -- !--
!-- End Lab Notebook -- !--

**Unconditional lower bound.** If `a·b` admits a positive index of apparition then
`lcm(α a, α b) ∣ α(a·b)`.  No coprimality is required; this is the always-valid
half of the lcm law.
-/
theorem fibEntryPt_lcm_dvd {a b : ℕ}
    (hab : ∃ k, 0 < k ∧ a * b ∣ Nat.fib k) :
    Nat.lcm (fibEntryPt a) (fibEntryPt b) ∣ fibEntryPt (a * b) := by
  exact Nat.lcm_dvd ( fibEntryPt_dvd_of_dvd ( dvd_mul_right a b ) hab ) ( fibEntryPt_dvd_of_dvd ( dvd_mul_left b a ) hab )

/-! ## The sharp boundary: the lcm law fails without coprimality -/

/-
`α(2) = 3`: the rank of apparition of `2` is `3` (`2 ∣ F 3 = 2`).
-/
theorem fibEntryPt_two : fibEntryPt 2 = 3 := by
  rw [ entryPt_eq_iff_primitive ] <;> norm_num;
  intro k hk hk'; interval_cases k <;> trivial;

/-
`α(4) = 6`: the rank of apparition of `4` is `6` (`4 ∣ F 6 = 8`).
-/
theorem fibEntryPt_four : fibEntryPt 4 = 6 := by
  apply (entryPt_eq_iff_primitive (by decide) (by decide)).mpr;
  intro k hk hk'; interval_cases k <;> trivial;

/-
!-- Lab Notebook: fibEntryPt_lcm_strict -- !--
!-- Hypothesis (Critic): the coprimality hypothesis in the lcm law is necessary, and the parent file's heuristic that α(a·b) can be "strictly smaller" than the lcm is wrong. -- !--
!-- Result: Disproof of the naive (non-coprime) lcm law: α(2·2) = α(4) = 6 ≠ 3 = lcm(α 2, α 2). Moreover 3 ∣ 6, so α(a·b) is a strict MULTIPLE (larger), consistent with fibEntryPt_lcm_dvd. -- !--
!-- Insight: dropping coprimality can only make α(a·b) a proper multiple of the lcm, never smaller, because fibEntryPt_lcm_dvd gives lcm ∣ α(a·b) unconditionally. -- !--
!-- Failure analysis: the explicit pair (2,2) is the minimal witness; it pins the boundary of the lcm law precisely. -- !--
!-- End Lab Notebook -- !--

**Boundary counterexample.** Without coprimality the lcm law fails:
`α(2·2) = 6` but `lcm(α 2, α 2) = 3`.  Combined with `fibEntryPt_lcm_dvd` this shows
the failure is always in the direction of `α(a·b)` being a strict *multiple* of the
lcm.
-/
theorem fibEntryPt_lcm_strict :
    fibEntryPt (2 * 2) ≠ Nat.lcm (fibEntryPt 2) (fibEntryPt 2) := by
  rw [ show ( 2 * 2 : ℕ ) = 4 by norm_num, fibEntryPt_four, fibEntryPt_two ] ; norm_num

end FibEntryRecon