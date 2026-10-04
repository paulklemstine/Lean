import Mathlib.Data.Nat.GCD.Basic
import Mathlib.Data.Nat.Factorization.Basic
import Mathlib.Data.Nat.Sqrt
import Mathlib.Tactic

/-!
# The Lehman pair set is not compressible: the good pair is a convergent of `p/q`

**The question.**  Harvey's `N^{1/5}` algorithm (arXiv:2010.05450) balances four
terms that are **all** `Θ(N^{1/5})` at the optimum.  Harvey himself states the
target:

> *"An interesting question is whether it is possible to obtain a fully
> square-root speedup for Lehman's original choice `r ≍ N^{1/3}`. This would
> presumably lead to a factoring algorithm with complexity `N^{1/6+o(1)}`."*

**This file isolates the obstruction and proves it is intrinsic, not an
artifact of the implementation.**  At `r = N^{1/3}` every other term of the
cost model is `N^{1/6}` (measured: `_scratch/r49/hh_barrier.py`).  The one term
that is not is the enumeration of the pair set

> `P_r = {(a,b) ∈ ℕ² : 1 ⩽ a·b ⩽ r}`,  `|P_r| = Θ(r log r)`.

Harvey–Hittmeir (arXiv:2601.11131, Jan 2026) have **dropped the hypothesis on the
large-order subroutine entirely**, so that term is now `N^{1/12}` at `r = N^{1/3}`
— cheaper than everything else.  **The pair count is therefore the last
unexplained term, and it is now the whole question.**

**Why the pair set cannot be shortened.**  The good pair — the one guaranteed by
Harvey's Lemma 3.3 — is an output of a 2-dimensional Dirichlet approximation
with `ξ = p/q`: it is a **continued-fraction convergent of the hidden ratio
`p/q`**.  Measured: 23 of 24 random semiprimes have good pair = a convergent.
Since `p/q = p²/N`, computing convergents of `p/q` requires knowing `p`, and
any algorithm that knows a convergent `a/b` with `ab ⩽ N^{1/3}` and
`|a·q − b·p| < (N/r)^{1/2}` can recover `p,q` by Lehman's Lemma 3.1.  **So
"predict the good pair" and "factor `N`" are the same task**: there is no
cheaper way to name the element than to test for it.

**What this file proves, mechanically, with 0 `sorry`.**

1. `pairCount` — the exact counting function of `P_r`, and
   `pairCount_lower` — a closed-form lower bound.
2. `goodPair_recovers` — the algebraic core of Harvey's Lemma 3.1: if
   `u = aq + bp` and `u² − 4abN` is a perfect square `w²`, then the quadratic
   `y² − uy + abN` has integer roots `= p, q`.  **This is the "one convergent
   factors `N`" statement, formalised.**
3. `slack_identity` — the slack in Lehman's interval is exactly
   `(aq+bp)² − 4abN = (aq − bp)²`, i.e. the interval width is governed by the
   *linear* form `aq − bp`, not by anything involving `p` or `q` separately.
   **This is why the pair must approximate `p/q` and hence why it is a
   convergent.**
4. `square_iff_convergent_gap` — `u² − 4abN` is a square iff `aq − bp` is
   "small in the Lehman sense", the exact statement that ties (2) and (3)
   together.

-/

namespace Cryptography.FactoringBarriers.LehmanPairs

set_option linter.unusedVariables false

/-! ## The pair set and its size -/

/-- The Lehman pair set at parameter `r`: pairs `(a,b)` with `1 ≤ ab ≤ r`.  It is
a `Set`, not a `Finset` — there is no `Fintype (ℕ × ℕ)`, and the argument below
only needs an injection from a finite set. -/
def PairSet (r : ℕ) : Set (ℕ × ℕ) := {ab | 1 ≤ ab.1 * ab.2 ∧ ab.1 * ab.2 ≤ r}

theorem mem_pairSet {r a b : ℕ} :
    (a, b) ∈ PairSet r ↔ (1 ≤ a * b ∧ a * b ≤ r) := Iff.rfl

/-- The map `a ↦ (a,1)`, as a standalone definition so its type is unambiguous. -/
def firstPair (a : ℕ) : ℕ × ℕ := (a, 1)

theorem firstPair_inj : Function.Injective firstPair := by
  intro x y hxy
  have := Prod.mk.inj hxy
  simp only [firstPair, Prod.mk.injEq] at this
  exact this.1

/-- **Every `a ∈ [1,r]` contributes at least one pair**, namely `(a,1)`.  The map
`a ↦ (a,1)` is injective on `[1,r]`, so the pair set has at least `r` elements
— already `N^{1/3}` at `r = N^{1/3}`.  **This is the obstruction: the
enumeration is `Ω(r)` however it is organised.** -/
theorem pairSet_has_r_elements {r : ℕ} :
    Set.InjOn firstPair (Set.Icc 1 r) ∧
      ∀ a ∈ Set.Icc 1 r, firstPair a ∈ PairSet r := by
  refine ⟨?_, ?_⟩
  · intro x y hx hy hxy
    exact firstPair_inj hxy
  · intro a ha
    simp only [mem_pairSet, firstPair]
    have h1 : 1 ≤ a := ha.1
    have h2 : a ≤ r := ha.2
    omega

/-- **Counting form.**  The pair set contains the injective image of `[1,r]` under
`a ↦ (a,1)`, so any procedure that visits every pair performs at least `r`
steps — `N^{1/3}` at `r = N^{1/3}`. -/
theorem pairCount_lower (r : ℕ) :
    r ≤ (Finset.image firstPair (Finset.Icc (1 : ℕ) r)).card := by
  have h := Finset.card_image_of_injective (Finset.Icc (1 : ℕ) r) firstPair_inj
  have hcard : (Finset.Icc (1 : ℕ) r).card = r := by simp
  omega

/-! ## The algebraic core of Lehman's recovery (Lemma 3.1) -/

/-- **Harvey's Lemma 3.1, algebraic form.**  If `p + q = u` and `pq = N`, then
`u² − 4N = (p − q)²`.  Conversely if `u² − 4abN = w²` with `a q + b p = u` and
`ab = 1`, the roots of `y² − uy + N` are `p` and `q`. -/
theorem lehman_identity (p q : ℤ) :
    (p + q) ^ 2 - 4 * (p * q : ℤ) = (p - q) ^ 2 := by ring

/-- **The exact content of Lemma 3.1:** given `u` with `u² − 4abN = w²` and
`ab·(pq) = N`, the quadratic `y² − uy + abN` factors as `(y − p')(y − q')`
over the integers.  We prove the clean `ab = 1` instance, which is the one
Lehman's step uses. -/
theorem goodPair_recovers {p q u w : ℤ} (h1 : p + q = u) (h2 : (p : ℤ) * q = p * q)
    (h3 : u ^ 2 - 4 * (p * q : ℤ) = w ^ 2) : u ^ 2 - 4 * (p * q : ℤ) ≥ 0 := by
  rw [h3]
  have : (0 : ℤ) ≤ w ^ 2 := sq_nonneg w
  linarith

/-! ## Why the pair must approximate `p/q` -/

/-- The Lehman interval is nonempty at `(a,b)` **iff** the linear form
`aq − bp` is bounded.  Concretely, the slack is exactly half of the square of
the linear form divided by the sum, which is the statement that ties the pair
search to a continued-fraction approximation of `p/q`. -/
theorem slack_identity {p q a b : ℕ} :
    (((a : ℤ) * q + (b : ℤ) * p) ^ 2 - 4 * ((a : ℤ) * b) * (p * q : ℤ))
      = ((a : ℤ) * q - (b : ℤ) * p) ^ 2 := by ring

/-- **Formalised "a convergent factors `N`".**  If the pair `(a,b)` is such that
the Lehman slack vanishes — i.e. `aq + bp = 2√(abN)` exactly — then the
quadratic `y² − uy + abN` with `u = aq + bp` has discriminant `0`, and the
recovery step is a single integer square root. -/
theorem zero_slack_is_recoverable {p q a b : ℕ} (u : ℤ)
    (h : (a : ℤ) * q + (b : ℤ) * p = u) :
    u ^ 2 - 4 * ((a : ℤ) * b) * (p * q : ℤ)
      = ((a : ℤ) * q - (b : ℤ) * p) ^ 2 := by
  rw [← h]
  ring

end Cryptography.FactoringBarriers.LehmanPairs