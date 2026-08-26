import Physics.StackSquareCoreBasic

/-!
# Stack polyominoes with a square core: the third core layer, exactly

The counting function of square-core stacks decomposes into *core layers*

  `a(n) = Σ_{k² ≤ n} conv (k-1) (n - k²)`,

where `conv b m = Σ_{i+j=m} p_{≤b}(i) p_{≤b}(j)` counts the pairs of slopes with parts
`≤ b`.  The layers `k = 0, 1, 2` are trivial or linear (`conv 0` is a delta, `conv 1 m =
m + 1`).  The first layer with genuine arithmetic content is `k = 3`, governed by
`conv 2`, the self-convolution of the partition counts into parts `≤ 2`.

This file computes that layer **exactly**.  Writing `g(m) = p_{≤2}(m) = ⌊m/2⌋ + 1` we prove
the two-step convolution recurrence

  `conv 2 (m+2) = conv 2 m + g(m) g(m+1) + g(m+1) + g(m+2)`,

and integrate it into the quasi-polynomial closed form

  `24 · conv 2 (2s)     = (2s+2)(2s+3)(2s+4)`,
  `24 · conv 2 (2s+1)   = (2s+2)(2s+4)(2s+6)`,

i.e. `conv 2 m = (m+2)(m+3)(m+4)/24` for even `m` and `(m+1)(m+3)(m+5)/24` for odd `m`.

The closed form has a striking consequence.  The whole development of
`Physics.StackSquareCoreConvexity` shows that every layer — and hence `a` itself — is
**convex**, and it is natural to ask whether the layers are convex to all orders (a
total-positivity property).  They are not: the third forward difference of `conv 2`
*alternates in sign with period two and with linearly growing amplitude*,

  `Δ³ conv 2 (2t)   = -(t+2)`,   `Δ³ conv 2 (2t+1) = t+3`,

so `conv 2` fails to be `3`-convex at **every** even argument.  This is an infinite family
of counterexamples, not an accident of small values, and it propagates to the counting
function itself: `a(10) + 3a(8) = 24 < 25 = 3a(9) + a(7)`.

## Main results

* `pb_one`, `pb_two` : `p_{≤1}(m) = 1` and `p_{≤2}(m) = ⌊m/2⌋ + 1`.
* `sum_pb_two` : `Σ_{j≤m} p_{≤2}(j) = (⌊m/2⌋+1)(⌊(m+1)/2⌋+1)`.
* `conv_two_step` : the two-step recurrence for `conv 2`.
* `conv_two_even`, `conv_two_odd` : the quasi-polynomial closed form.
* `conv_two_third_diff_even`, `conv_two_third_diff_odd` : the exact third differences.
* `conv_two_not_three_convex` : `conv 2` is not `3`-convex at any even argument.
* `stackSC_not_three_convex` : `a` is not `3`-convex.
-/

namespace Physics.StackSquareCore

open Finset

/-! ## The partition counts with parts `≤ 1` and `≤ 2` -/

/-- Only one partition of `m` uses parts of size `≤ 1`. -/
lemma pb_one (m : ℕ) : pb 1 m = 1 := by
  rw [pb_succ_left, Finset.sum_eq_single m]
  · simp
  · intro c hc hcm
    simp only [Finset.mem_range] at hc
    simp only [pb_zero_left]
    rw [if_neg]
    omega
  · intro h
    simp at h

/-- Partitions into parts `≤ 2` are counted by the number of `2`'s used. -/
lemma pb_two (m : ℕ) : pb 2 m = m / 2 + 1 := by
  rw [show (2 : ℕ) = 1 + 1 from rfl, pb_succ_left]
  simp

/-- The partial sums of `p_{≤2}` factor completely. -/
lemma sum_pb_two (m : ℕ) :
    ∑ j ∈ range (m + 1), pb 2 j = (m / 2 + 1) * ((m + 1) / 2 + 1) := by
  simp only [pb_two]
  induction m with
  | zero => simp
  | succ n ih =>
      rw [Finset.sum_range_succ, ih]
      have h : (n + 1 + 1) / 2 = n / 2 + 1 := by omega
      rw [h]; ring

/-! ## The two-step recurrence for the third layer -/

lemma conv_two_eq (m : ℕ) :
    conv 2 m = ∑ j ∈ range (m + 1), (j / 2 + 1) * ((m - j) / 2 + 1) := by
  simp [conv, pb_two]

/-- Peeling the two smallest slopes off a pair of partitions with parts `≤ 2` gives an
exact two-step recurrence: `conv 2 (m+2) = conv 2 m + g(m)g(m+1) + g(m+1) + g(m+2)` with
`g = p_{≤2}`. -/
lemma conv_two_step (m : ℕ) :
    conv 2 (m + 2) =
      conv 2 m + (m / 2 + 1) * ((m + 1) / 2 + 1) + ((m + 1) / 2 + 1) + ((m + 2) / 2 + 1) := by
  rw [conv_two_eq, conv_two_eq, Finset.sum_range_succ', Finset.sum_range_succ']
  have key : ∀ k ∈ range (m + 1),
      ((k + 1 + 1) / 2 + 1) * ((m + 2 - (k + 1 + 1)) / 2 + 1)
        = (k / 2 + 1) * ((m - k) / 2 + 1) + ((m - k) / 2 + 1) := by
    intro k hk
    simp only [Finset.mem_range] at hk
    have h1 : (k + 1 + 1) / 2 = k / 2 + 1 := by omega
    have h2 : m + 2 - (k + 1 + 1) = m - k := by omega
    rw [h1, h2]; ring
  rw [Finset.sum_congr rfl key, Finset.sum_add_distrib]
  have hrefl : ∑ k ∈ range (m + 1), ((m - k) / 2 + 1) = ∑ j ∈ range (m + 1), pb 2 j := by
    rw [← Finset.sum_range_reflect (fun j => pb 2 j) (m + 1)]
    refine Finset.sum_congr rfl (fun k hk => ?_)
    simp only [Finset.mem_range] at hk
    rw [pb_two]
    congr 2
  rw [hrefl, sum_pb_two]
  have h0 : (0 + 1) / 2 = 0 := by omega
  have h1 : m + 2 - (0 + 1) = m + 1 := by omega
  rw [h0, h1]
  simp

/-! ## The quasi-polynomial closed form -/

/-- Closed form at even arguments: `conv 2 (2s) = (2s+2)(2s+3)(2s+4)/24`. -/
theorem conv_two_even (s : ℕ) : 24 * conv 2 (2 * s) = (2 * s + 2) * (2 * s + 3) * (2 * s + 4) := by
  induction s with
  | zero => decide
  | succ t ih =>
      have hstep : conv 2 (2 * (t + 1)) = conv 2 (2 * t) + (t + 1) * (t + 1) + (t + 1) + (t + 2) := by
        have h : 2 * (t + 1) = 2 * t + 2 := by ring
        rw [h, conv_two_step]
        have e1 : (2 * t) / 2 + 1 = t + 1 := by omega
        have e2 : (2 * t + 1) / 2 + 1 = t + 1 := by omega
        have e3 : (2 * t + 2) / 2 + 1 = t + 2 := by omega
        rw [e1, e2, e3]
      have h24 : 24 * conv 2 (2 * (t + 1))
          = 24 * conv 2 (2 * t) + 24 * ((t + 1) * (t + 1) + (t + 1) + (t + 2)) := by
        rw [hstep]; ring
      rw [h24, ih]; ring

/-- Closed form at odd arguments: `conv 2 (2s+1) = (2s+2)(2s+4)(2s+6)/24`. -/
theorem conv_two_odd (s : ℕ) :
    24 * conv 2 (2 * s + 1) = (2 * s + 2) * (2 * s + 4) * (2 * s + 6) := by
  induction s with
  | zero => decide
  | succ t ih =>
      have hstep : conv 2 (2 * (t + 1) + 1)
          = conv 2 (2 * t + 1) + (t + 1) * (t + 2) + (t + 2) + (t + 2) := by
        have h : 2 * (t + 1) + 1 = (2 * t + 1) + 2 := by ring
        rw [h, conv_two_step]
        have e1 : (2 * t + 1) / 2 + 1 = t + 1 := by omega
        have e2 : (2 * t + 1 + 1) / 2 + 1 = t + 2 := by omega
        have e3 : (2 * t + 1 + 2) / 2 + 1 = t + 2 := by omega
        rw [e1, e2, e3]
      have h24 : 24 * conv 2 (2 * (t + 1) + 1)
          = 24 * conv 2 (2 * t + 1) + 24 * ((t + 1) * (t + 2) + (t + 2) + (t + 2)) := by
        rw [hstep]; ring
      rw [h24, ih]; ring

/-! ## Third differences: an infinite family of failures of `3`-convexity -/

/-- The third forward difference of the third layer at an **even** argument equals
`-(t+2)`: `conv 2 (2t+3) + 3 conv 2 (2t+1) + (t+2) = 3 conv 2 (2t+2) + conv 2 (2t)`. -/
theorem conv_two_third_diff_even (t : ℕ) :
    conv 2 (2 * t + 3) + 3 * conv 2 (2 * t + 1) + (t + 2)
      = 3 * conv 2 (2 * t + 2) + conv 2 (2 * t) := by
  refine Nat.eq_of_mul_eq_mul_left (show 0 < 24 by norm_num) ?_
  have h1 : 24 * conv 2 (2 * t + 3) = (2 * t + 4) * (2 * t + 6) * (2 * t + 8) := by
    have e : 2 * t + 3 = 2 * (t + 1) + 1 := by ring
    rw [e, conv_two_odd (t + 1)]; ring
  have h2 : 24 * conv 2 (2 * t + 1) = (2 * t + 2) * (2 * t + 4) * (2 * t + 6) :=
    conv_two_odd t
  have h3 : 24 * conv 2 (2 * t + 2) = (2 * t + 4) * (2 * t + 5) * (2 * t + 6) := by
    have e : 2 * t + 2 = 2 * (t + 1) := by ring
    rw [e, conv_two_even (t + 1)]; ring
  have h4 : 24 * conv 2 (2 * t) = (2 * t + 2) * (2 * t + 3) * (2 * t + 4) :=
    conv_two_even t
  calc 24 * (conv 2 (2 * t + 3) + 3 * conv 2 (2 * t + 1) + (t + 2))
      = 24 * conv 2 (2 * t + 3) + 3 * (24 * conv 2 (2 * t + 1)) + 24 * (t + 2) := by ring
    _ = (2 * t + 4) * (2 * t + 6) * (2 * t + 8)
          + 3 * ((2 * t + 2) * (2 * t + 4) * (2 * t + 6)) + 24 * (t + 2) := by rw [h1, h2]
    _ = 3 * ((2 * t + 4) * (2 * t + 5) * (2 * t + 6))
          + (2 * t + 2) * (2 * t + 3) * (2 * t + 4) := by ring
    _ = 3 * (24 * conv 2 (2 * t + 2)) + 24 * conv 2 (2 * t) := by rw [h3, h4]
    _ = 24 * (3 * conv 2 (2 * t + 2) + conv 2 (2 * t)) := by ring

/-- The third forward difference at an **odd** argument equals `+(t+3)`. -/
theorem conv_two_third_diff_odd (t : ℕ) :
    conv 2 (2 * t + 4) + 3 * conv 2 (2 * t + 2)
      = 3 * conv 2 (2 * t + 3) + conv 2 (2 * t + 1) + (t + 3) := by
  refine Nat.eq_of_mul_eq_mul_left (show 0 < 24 by norm_num) ?_
  have h1 : 24 * conv 2 (2 * t + 4) = (2 * t + 6) * (2 * t + 7) * (2 * t + 8) := by
    have e : 2 * t + 4 = 2 * (t + 2) := by ring
    rw [e, conv_two_even (t + 2)]; ring
  have h2 : 24 * conv 2 (2 * t + 2) = (2 * t + 4) * (2 * t + 5) * (2 * t + 6) := by
    have e : 2 * t + 2 = 2 * (t + 1) := by ring
    rw [e, conv_two_even (t + 1)]; ring
  have h3 : 24 * conv 2 (2 * t + 3) = (2 * t + 4) * (2 * t + 6) * (2 * t + 8) := by
    have e : 2 * t + 3 = 2 * (t + 1) + 1 := by ring
    rw [e, conv_two_odd (t + 1)]; ring
  have h4 : 24 * conv 2 (2 * t + 1) = (2 * t + 2) * (2 * t + 4) * (2 * t + 6) :=
    conv_two_odd t
  calc 24 * (conv 2 (2 * t + 4) + 3 * conv 2 (2 * t + 2))
      = 24 * conv 2 (2 * t + 4) + 3 * (24 * conv 2 (2 * t + 2)) := by ring
    _ = (2 * t + 6) * (2 * t + 7) * (2 * t + 8)
          + 3 * ((2 * t + 4) * (2 * t + 5) * (2 * t + 6)) := by rw [h1, h2]
    _ = 3 * ((2 * t + 4) * (2 * t + 6) * (2 * t + 8))
          + (2 * t + 2) * (2 * t + 4) * (2 * t + 6) + 24 * (t + 3) := by ring
    _ = 3 * (24 * conv 2 (2 * t + 3)) + 24 * conv 2 (2 * t + 1) + 24 * (t + 3) := by rw [h3, h4]
    _ = 24 * (3 * conv 2 (2 * t + 3) + conv 2 (2 * t + 1) + (t + 3)) := by ring

/-- **The layer functions are not convex to all orders.**  The third core layer `conv 2`
has a strictly negative third difference at every even argument, so the natural
"total positivity" strengthening of `conv_convex` is false. -/
theorem conv_two_not_three_convex (t : ℕ) :
    conv 2 (2 * t + 3) + 3 * conv 2 (2 * t + 1) < 3 * conv 2 (2 * t + 2) + conv 2 (2 * t) := by
  have h := conv_two_third_diff_even t
  omega

/-- The failure of `3`-convexity reaches the counting function itself:
`a(10) + 3a(8) = 24 < 25 = 3a(9) + a(7)`. -/
theorem stackSC_not_three_convex :
    ¬ (∀ n : ℕ, 4 ≤ n →
        3 * stackSC (n + 2) + stackSC n ≤ stackSC (n + 3) + 3 * stackSC (n + 1)) := by
  intro h
  have h7 := h 7 (by omega)
  rw [show stackSC 7 = 4 from by decide, show stackSC 8 = 5 from by decide,
    show stackSC 9 = 7 from by decide, show stackSC 10 = 9 from by decide] at h7
  omega

end Physics.StackSquareCore