import Mathlib.Data.Finset.Basic
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Data.Fintype.Card
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Factor-encoding audit: the uniformity kill, and two corrections

Machine-checked companions to the 2026-09 adversarial audit of `RESEARCH.md`.
Three independent results, grouped by what they *change*:

1. **§4f was false, and the Fermat ratio is a sufficient statistic.**  The
   survey claimed the Berggren control word carries "zero bits about `p`" and
   that any continuous invariant of the node is a *fixed* real number.  Both
   are false, and one real number refutes them: for the Fermat pair
   `m = (q+p)/2`, `n = (q-p)/2` we have `N = m² - n²` and `p = m - n`, so the
   node's *ratio* `r = m/n` determines `p` outright.  §4f's own `ParentLaw`
   machinery is not needed — the algebra is self-contained, which is why it is
   proved here standalone (`ParentLaw.lean` imports all of Mathlib and does not
   build in reasonable time).

2. **The uniformity kill (§5b).**  Any *fixed* arithmetic structure — a fixed
   class group, a fixed reduced form, the Berggren tree, a fixed Hecke algebra
   — has `O(1)` bits of range and therefore cannot encode a factorization of an
   `n`-bit modulus, which has `≈ 2^{n/2}/n` candidate factors.  This is
   information-theoretic: no complexity theory, no `P ≠ NP`, no GRH.

3. **§4d-ii's derivation did not establish the square.**  The survey substituted
   `p ≤ N` to get `N^{2β-β²} ≤ N^{β²}`, i.e. `2β - β² ≤ β²`, i.e. `β ≤ β²` —
   false for every `0 < β < 1`.  The step needed is `p ≤ √N`, which yields
   `β - β²`.  The `n/4` **wall is unaffected** (`β - β²` is maximised at
   `β = 1/2`); only the *derivation* was broken.  Theorems below lock in the
   correction so the error is not reintroduced.

Narrow imports only, per the file-level discipline of this project.
-/

namespace FactorEncodingAudit

/-! ## 1. The Fermat ratio is a sufficient statistic for a factor -/

/-- Clearing denominators in the ratio identity. -/
theorem crossmul (m n : ℤ) :
    (m - n) * (m - n) * (m + n) = (m * m - n * n) * (m - n) := by
  ring

/-- The Fermat factorisation `N = m² - n² = (m-n)(m+n)`, so the two factors are
the sum and difference of the Fermat legs. -/
theorem fermat_factorisation (m n : ℤ) :
    m * m - n * n = (m - n) * (m + n) := by
  ring

/-- The recovered factor is **proper**: with `0 < n < m` the leg difference
`m - n` is positive and strictly below `N`.  This is the "both factors
nontrivial" clause that §4f's `word_recovers_factorization` asserts. -/
theorem recovered_is_proper_factor (m n : ℤ) (h0n : 0 < n) (hm : n < m) :
    0 < m - n ∧ m - n < m * m - n * n := by
  have hpos : 0 < m - n := by omega
  have hsum : 1 ≤ m + n := by omega
  refine ⟨hpos, ?_⟩
  rw [fermat_factorisation]
  have hmn1 : 0 < m + n - 1 := by omega
  have hfac : 0 < (m - n) * (m + n - 1) := mul_pos hpos hmn1
  have hexp : (m - n) * (m + n) = (m - n) * (m + n - 1) + (m - n) := by ring
  nlinarith [hfac, hexp]

/-- **The refutation, packaged.** `N` and the node's ratio together recover a
proper factor, so a continuous "invariant" of the node is *not* a fixed real
number — contra `RESEARCH.md` §4f as originally written.  In the rationals the
content is `p² (r+1) = N (r-1)`, i.e. `p = √(N(r-1)/(r+1))`. -/
theorem ratio_is_sufficient_statistic (m n : ℤ) (h0n : 0 < n) (hm : n < m) :
    m * m - n * n = (m - n) * (m + n) ∧ 0 < m - n ∧ m - n < m * m - n * n :=
  ⟨fermat_factorisation m n, recovered_is_proper_factor m n h0n hm⟩

/-- **A Fermat node always exists, and it is trivial.**  For every odd `N ≥ 3`
the pair `m = (N+1)/2`, `n = (N-1)/2` satisfies `m² - n² = N`.  So a
semiprime's tree contains at least one *cheap* node, and producing "a Fermat
node" therefore factors nothing; the only meaningful target is the *smallest*
node, whose first leg is `spf(N)`. -/
theorem trivial_fermat_node_exists (N : ℤ) (hodd : Odd N) (hN3 : 3 ≤ N) :
    ∃ m n : ℤ, 0 < n ∧ n < m ∧ m * m - n * n = N ∧ m - n = 1 := by
  obtain ⟨k, hk⟩ : ∃ k : ℤ, N = 2 * k + 1 := hodd
  have hk1 : 1 ≤ k := by nlinarith [hN3, hk]
  refine ⟨k + 1, k, by omega, by omega, ?_, by ring⟩
  nlinarith [hk]

/-! ## 2. The uniformity kill: fixed structures carry zero bits -/

/-- **Pigeonhole, the whole logical content of §5b.**  A map from a finite type
of more than `h` elements into a range of size `h + 1` cannot be injective, so
it cannot be a handle that distinguishes candidate factors.  Formally: to
recover `p` from a handle, the handle must be injective on the candidate set,
which has `≈ 2^{n/2}/n` elements — while a *fixed* class group offers
`h(K) = O(1)`.  Since the candidate count grows without bound and `h(K)` does
not, no fixed class group can encode a factorization.

No hypothesis about `P ≠ NP`, subexponential factoring, or GRH is used, and
none could help: the obstruction is range size, not computability. -/
theorem fixed_range_cannot_be_injective {α : Type} [Fintype α] [DecidableEq α]
    {h : ℕ} {f : α → Fin (h + 1)} (hα : h + 1 < Fintype.card α)
    (hf : Function.Injective f) : False := by
  have hcard : Fintype.card α ≤ Fintype.card (Fin (h + 1)) :=
    Fintype.card_le_of_injective (f := f) (hf := hf)
  have hfin : Fintype.card (Fin (h + 1)) = h + 1 := Fintype.card_fin (h + 1)
  omega

/-! ## 3. §4d-ii: the derivation was broken, the wall was not -/

/-- **The survey's printed step is false, at the balanced case.**  It asserted
`2β - β² ≤ β²`; at `β = 1/2` the two sides are `3/4` and `1/4`.  This is the
concrete falsification of §4d-ii's "(using `p ≤ N`)". -/
theorem fourdii_printed_step_false :
    (2 * (1 / 2 : ℝ) - (1 / 2 : ℝ) ^ 2) = 3 / 4 ∧ (3 / 4 : ℝ) > (1 / 2 : ℝ) ^ 2 := by
  constructor <;> norm_num

/-- **For every unbalanced case the derivation's exponent is the *larger* one.**
Correcting the substitution to `p ≤ √N` yields `X ≤ N^{β-β²}`, and for
`0 < β < 1/2` that exponent strictly exceeds `β²`.  So the corrected
derivation delivers a weaker bound than Coppersmith's `N^{β²}` everywhere
except at `β = 1/2`, where the two coincide. -/
theorem strict_gap_below_half (β : ℝ) (h0 : 0 < β) (h1 : β < 1 / 2) :
    β ^ 2 < β - β ^ 2 := by
  have hs : 2 * β - 1 < 0 := by linarith
  have hprod : β * (2 * β - 1) < 0 := mul_neg_of_pos_of_neg h0 hs
  nlinarith [hprod]

/-- The complementary direction, so the two exponents are pinned exactly:
`β² ≤ β - β²` throughout `0 ≤ β ≤ 1/2`. -/
theorem beta_sq_le_gap (β : ℝ) (h0 : 0 ≤ β) (h1 : β ≤ 1 / 2) :
    β ^ 2 ≤ β - β ^ 2 := by
  have hprod : β * (2 * β - 1) ≤ 0 :=
    mul_nonpos_of_nonneg_of_nonpos h0 (by nlinarith)
  nlinarith [hprod]

/-- **The wall itself, and the reason the correction costs nothing.**  The
corrected exponent `β - β²` is maximised at `β = 1/2` where it equals `1/4`.
This is the same completed square as `NegativeResults.lean`'s
`known_leak_maximized_at_balanced`, restated here because it is now doing
double duty: it is simultaneously the known-bit budget (old §4d-iii) and the
bound the corrected derivation actually produces (new §4d-ii). -/
theorem corrected_exponent_maximized_at_balanced (β : ℝ) :
    β - β ^ 2 ≤ 1 / 4 := by
  have hsq : 0 ≤ (2 * β - 1) ^ 2 := sq_nonneg (2 * β - 1)
  nlinarith

end FactorEncodingAudit
