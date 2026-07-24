import Computation.BinarySearchVerified
import Computation.FactorialNumberSystem

/-!
# Bridge: Binary Search over the Factoradic Index Space

This file connects the verified binary search of `BinarySearchVerified` with the
verified **factorial number system** of `FactorialNumberSystem` (an existing
catalog file).  The factoradic system gives a bijection between `[0, k!)` and the
valid factoradic digit tuples; binary search locates any target in that index
space in `⌈log₂ k!⌉` comparisons.

`factoradic_search` packages three facts:

1. **Density / surjectivity of the search domain** — every `n < k!` is realised as
   the factoradic value of its own extracted digits
   (`FactorialNumberSystem.value_digit`).
2. **Well-posedness / injectivity** — distinct targets have distinct factoradic
   codes, so binary search keys are unambiguous.
3. **Complexity** — binary search over `[0, k!)` performs at most
   `Nat.clog 2 (k!)` iterations (`BinarySearchVerified.bsearch_steps_le`).

-- !-- Lab Notes -- !--

* Hypothesis (Hypothesizer): the worst-case binary-search cost over the factoradic
  index space `[0, k!)` is `⌈log₂ k!⌉`, and the domain is a genuine size-`k!`
  bijective image of the factoradic digit tuples (so the bound is not over a
  padded/sparse range).
* Experiment (Experimenter): conjunct (1) is exactly the catalog's
  `value_digit`; conjunct (3) is `bsearch_steps_le` with `hi - lo = k! - 0 = k!`.
  Conjunct (2) needed a short argument: from digit-agreement on `[0,k)` the
  values agree (the value is a `range k` sum of the digits), and `value (digit n) k = n`
  collapses value-equality to `m = n`.
* Analysis (Analyst): the bridge is *non-circular* — `bsearch_steps_le` is purely
  combinatorial (no factoradic content), and the factoradic lemmas are purely
  number-theoretic (no search content); they compose only at the index-space level.
* Critique (Critic): conjunct (2) is not a tautology — it genuinely uses
  surjectivity (1) to turn value-equality into index-equality; dropping (1) would
  leave it unprovable from digit-agreement alone for arbitrary `n ≥ k!`.
* Synthesis (PI): one statement ties algorithmic complexity (`Nat.clog`) to a
  verified positional number system.
-/

namespace BinarySearchFactoradicBridge

open FactorialNumberSystem BinarySearchVerified

/-- **Binary search over the factoradic index space.** For every length `k` and
every Boolean key `p`:
1. every `n < k!` is the factoradic value of its extracted digits;
2. distinct targets below `k!` have distinct factoradic digit codes;
3. binary search over `[0, k!)` costs at most `⌈log₂ k!⌉` comparisons. -/
theorem factoradic_search (k : ℕ) (p : ℕ → Bool) :
    (∀ n, n < k.factorial → value (digit n) k = n) ∧
    (∀ m n, m < k.factorial → n < k.factorial →
        (∀ i < k, digit m i = digit n i) → m = n) ∧
    bsearchSteps p 0 k.factorial ≤ Nat.clog 2 k.factorial := by
  refine ⟨fun n hn => value_digit hn, ?_, ?_⟩
  · intro m n hm hn hdig
    have hv : value (digit m) k = value (digit n) k := by
      unfold value
      exact Finset.sum_congr rfl (fun i hi => by rw [hdig i (Finset.mem_range.mp hi)])
    rw [value_digit hm, value_digit hn] at hv
    exact hv
  · have h := bsearch_steps_le p 0 k.factorial
    simpa using h

end BinarySearchFactoradicBridge