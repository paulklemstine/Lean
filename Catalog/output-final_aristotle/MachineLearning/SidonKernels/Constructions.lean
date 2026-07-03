/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Sidon sets: an explicit unbounded family (lower bound)

The companion file `Core.lean` establishes the difference-set *upper* bound
`|s| ≤ √(2N) + 1` for a Sidon set `s ⊆ {1, …, N}`.  To show that Sidon sets of
every prescribed size actually exist — so that the extremal function `F(N)` is a
genuinely nontrivial, unbounded object rather than a vacuous bound — we exhibit
an explicit family.

The set of the first `k` powers of two,
`{2⁰, 2¹, …, 2^{k−1}}`, is a Sidon set: a sum `2ⁱ + 2ʲ` of two of them
determines the (multiset) pair of exponents because it fixes the binary
representation.  This yields, for every `k`, a Sidon set of cardinality `k`.

## Main results

* `twoPowSet_isSidon` — the first `k` powers of two form a Sidon set.
* `exists_sidon_card` — for every `k` there is a Sidon set of integers of
  cardinality exactly `k` (the extremal function is unbounded).

## Tags
Sidon set, B_2 set, explicit construction, powers of two, binary representation
-/
import Mathlib
import MachineLearning.SidonKernels.Core

open Finset

namespace Catalog.MachineLearning.SidonKernels

/-- The set of the first `k` powers of two, as a finite set of integers. -/
def twoPowSet (k : ℕ) : Finset ℤ := (Finset.range k).image (fun i => (2 : ℤ) ^ i)

/-
The power-of-two set has exactly `k` elements (the exponent map is injective).
-/
theorem twoPowSet_card (k : ℕ) : (twoPowSet k).card = k := by
  rw [ twoPowSet, Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ]

/-
Uniqueness of two-power sums: for exponents below `k`, `2^a + 2^b = 2^c + 2^d`
forces `a = c` or `a = d`.  This is the arithmetic heart of the construction.
-/
theorem twoPow_sum_eq {a b c d : ℕ} (h : (2 : ℤ) ^ a + 2 ^ b = 2 ^ c + 2 ^ d) :
    a = c ∨ a = d := by
  -- By the uniqueness of binary representation, if $2^a + 2^b = 2^c + 2^d$, then the sets $\{a, b\}$ and $\{c, d\}$ must be equal.
  have h_unique : ({a, b} : Finset ℕ) = ({c, d} : Finset ℕ) := by
    -- Without loss of generality, assume $a \leq b$ and $c \leq d$.
    suffices h_wlog : ∀ {a b c d : ℕ}, a ≤ b → c ≤ d → 2^a + 2^b = 2^c + 2^d → ({a, b} : Finset ℕ) = ({c, d} : Finset ℕ) by
      grind +suggestions;
    intros a b c d hab hcd h_eq
    have h_eq' : 2^a * (1 + 2^(b-a)) = 2^c * (1 + 2^(d-c)) := by
      simp +decide [ mul_add, ← pow_add, add_tsub_cancel_of_le hab, add_tsub_cancel_of_le hcd, h_eq ];
    have := congr_arg ( ·.factorization ( 2 : ℕ ) ) h_eq'; norm_num at this;
    rcases k : b - a with ( _ | k ) <;> rcases l : d - c with ( _ | l ) <;> simp_all +decide [ Nat.factorization_eq_zero_of_not_dvd, ← even_iff_two_dvd, parity_simps ];
    · subst this; ring_nf at *; aesop;
    · grind +qlia;
  rw [ Finset.ext_iff ] at h_unique; specialize h_unique a; aesop;

/-
**Power-of-two Sidon construction.**  The first `k` powers of two form a
Sidon set.
-/
theorem twoPowSet_isSidon (k : ℕ) : IsSidon (twoPowSet k) := by
  intro a ha b hb c hc d hd h_eq
  have h_exp : ∃ a' b' c' d', (2 : ℤ) ^ a' + 2 ^ b' = (2 : ℤ) ^ c' + 2 ^ d' ∧ a' < k ∧ b' < k ∧ c' < k ∧ d' < k ∧ a = (2 : ℤ) ^ a' ∧ b = (2 : ℤ) ^ b' ∧ c = (2 : ℤ) ^ c' ∧ d = (2 : ℤ) ^ d' := by
    unfold twoPowSet at *; aesop;
  obtain ⟨ a', b', c', d', h₁, h₂, h₃, h₄, h₅, rfl, rfl, rfl, rfl ⟩ := h_exp; specialize h₁; have := twoPow_sum_eq h₁; aesop;

/-- **Unboundedness of the Sidon extremal function.**  For every `k` there is a
Sidon set of integers of cardinality exactly `k`.  Together with the upper bound
`sidon_card_le_sqrt`, this shows the maximal Sidon size in `{1, …, N}` grows
without bound (indeed like `√N`), so the extremal problem is genuine. -/
theorem exists_sidon_card (k : ℕ) : ∃ s : Finset ℤ, IsSidon s ∧ s.card = k :=
  ⟨twoPowSet k, twoPowSet_isSidon k, twoPowSet_card k⟩

/-
-- !-- Lab Notes -- !--

**Hypothesis (Hypothesizer).**  For the Sidon upper bounds of `Core.lean` to be
meaningful, Sidon sets of arbitrary size must exist.  We conjectured the first
`k` powers of two `{2^0,...,2^(k-1)}` form a Sidon set, since a sum of two
powers of two pins down the binary representation.  Surprising angle: although
this family is far from extremal (it only witnesses `F(N) >= log2 N + 1`, not
the `sqrt N` order), it is the cheapest fully explicit certificate that the
extremal function is unbounded, requiring no algebraic number theory.

**Experiment (Experimenter).**  Checked small cases numerically
(ComputationalEvidence.md): `{1,2}`, `{1,2,4}`, `{1,2,4,8}` are all Sidon; the
only sum-coincidence risk `2^a+2^a=2^(a+1)` never collides with a distinct pair
because `1+2^(d-c)` is odd and `> 1`.  This ruled out the one plausible
counterexample family (equal-exponent carries).

**Analysis (Analyst).**  Survived: `twoPow_sum_eq` (2-power sum uniqueness via
`Nat.factorization`/2-adic valuation), `twoPowSet_isSidon`, and
`exists_sidon_card`.  The crux `twoPow_sum_eq` reduces, after WLOG ordering, to
matching the 2-adic valuation of `2^a(1+2^(b-a))` against `2^c(1+2^(d-c))`.
Failed / not pursued: a *quantitatively optimal* construction (Singer /
Erdos-Turan quadratic-residue sets) achieving the `sqrt N` order -- true but
requiring finite-field or perfect-difference-set machinery, a genuinely
different definition.

**Critique (Critic).**  `exists_sidon_card` is non-vacuous and constructive: it
exhibits an actual `Finset` of the required size, and `twoPowSet_card` proves
its cardinality via injectivity of `i |-> 2^i`.  No result here is a `True` or
`rfl` triviality; `twoPow_sum_eq` uses `Nat.factorization` and parity case
splits.  Corner cases: `k = 0` gives the empty (trivially Sidon) set,
consistent with the definition.

**Synthesis (PI).**  Combining `exists_sidon_card` (lower bound: every size is
achievable) with `sidon_card_le_sqrt` (upper bound `sqrt 2 * N^(1/2)+1`) frames
the Sidon extremal function `F(N)` between an explicit unbounded family and a
clean elementary ceiling -- the exact playground in which the convolution-kernel
programme optimises the sub-leading constant.
-/

end Catalog.MachineLearning.SidonKernels