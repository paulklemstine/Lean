import Shared.BerggrenTQC.SilverSpectrum

/-!
# Circuit depth in the Berggren tree

If the Berggren tree is to be read as a computational device, the natural complexity measure
is the *depth* of a word in the generators: how many Berggren steps are needed to reach a given
Pythagorean triple.  This file bounds that depth from both sides in terms of the hypotenuse `c`
of the target triple, using the `GL(2, ℤ)` lift.

Main results.

* `euclid_paramPath`: the Euclid lift is compatible with whole words — the triple reached by a
  word `p` of Berggren steps is the Euclid image of the parameter pair reached by the
  corresponding word of `2 × 2` matrices.
* `paramPath_lower`: after `d` steps the Euclid parameters satisfy `m ≥ d + 2`, `n ≥ 1`,
  `m > n`.
* `hyp_lower_depth`: hence the hypotenuse obeys `(d + 2)² < c`, i.e. **depth `≤ √c - 2`**: a
  Berggren circuit of depth `d` needs a target of hypotenuse at least quadratic in `d`.
* `paramPath_upper`, `hyp_upper_depth`: conversely `c ≤ 5 · 9^d`, i.e. **depth
  `≥ log₉(c/5)`**.
* `depth_bounds`: the two-sided statement.
* `aSpine_param`, `aSpine_hyp`: the `A`-spine `(3,4,5) → (5,12,13) → (7,24,25) → …` saturates
  the quadratic lower bound, while `bHyp_lower`/`bHyp_upper` (previous file) show the `B`-spine
  saturates the exponential upper bound.  So the depth of a Berggren word is genuinely between
  `log c` and `√c`, and both extremes are realised inside the tree.
-/

namespace BerggrenTQC

open Matrix

/-- The Euclid parameters reached by a word of Berggren steps, starting from the root `(2,1)`
(which is the triple `(3,4,5)`). -/
def paramPath (p : List BerggrenStep) : ℤ × ℤ :=
  p.foldl (fun v s => act (lift s) v) (2, 1)

@[simp] theorem paramPath_nil : paramPath [] = (2, 1) := rfl

theorem paramPath_concat (p : List BerggrenStep) (s : BerggrenStep) :
    paramPath (p ++ [s]) = act (lift s) (paramPath p) := by
  simp [paramPath]

/-- **The Euclid lift computes the whole tree.**  Every node of the Berggren tree is the Euclid
image of the corresponding word in `U₁, U₂, U₃`. -/
theorem euclid_paramPath (p : List BerggrenStep) :
    euclid (paramPath p).1 (paramPath p).2 = applyPath p := by
  induction p using List.reverseRecOn with
  | nil => rfl
  | append_singleton p s ih =>
      rw [paramPath_concat, applyPath_concat, ← ih]
      exact euclid_step s (paramPath p).1 (paramPath p).2

/-! ## Lower bound: parameters grow at least linearly, hypotenuse at least quadratically -/

theorem paramPath_lower (p : List BerggrenStep) :
    (p.length : ℤ) + 2 ≤ (paramPath p).1 ∧ 1 ≤ (paramPath p).2 ∧
      (paramPath p).2 < (paramPath p).1 := by
  induction p using List.reverseRecOn with
  | nil => exact ⟨by norm_num, by norm_num, by norm_num⟩
  | append_singleton p s ih =>
      obtain ⟨h1, h2, h3⟩ := ih
      rcases hv : paramPath p with ⟨m, k⟩
      rw [hv] at h1 h2 h3
      rw [paramPath_concat, hv]
      cases s <;> simp only [lift, act_U₁, act_U₂, act_U₃, List.length_append,
        List.length_cons, List.length_nil] <;>
        refine ⟨by push_cast; omega, by omega, by omega⟩

/-- **Depth is at most `√c`.**  A word of `d` Berggren steps reaches a triple whose hypotenuse
exceeds `(d + 2)²`. -/
theorem hyp_lower_depth (p : List BerggrenStep) :
    ((p.length : ℤ) + 2) ^ 2 < (applyPath p).2.2 := by
  obtain ⟨h1, h2, h3⟩ := paramPath_lower p
  rw [← euclid_paramPath p]
  have hm : 0 ≤ (p.length : ℤ) + 2 := by positivity
  simp only [euclid]
  nlinarith [h1, h2, hm]

/-! ## Upper bound: parameters grow at most geometrically -/

theorem paramPath_upper (p : List BerggrenStep) :
    (paramPath p).2 ≤ 3 ^ p.length ∧ (paramPath p).1 ≤ 2 * 3 ^ p.length := by
  induction p using List.reverseRecOn with
  | nil => exact ⟨by norm_num, by norm_num⟩
  | append_singleton p s ih =>
      obtain ⟨h2, h1⟩ := ih
      obtain ⟨hl1, hl2, hl3⟩ := paramPath_lower p
      rcases hv : paramPath p with ⟨m, k⟩
      rw [hv] at h1 h2 hl1 hl2 hl3
      have hpow : (3 : ℤ) ^ (p.length + 1) = 3 * 3 ^ p.length := by ring
      have hm : (0 : ℤ) ≤ m := by
        have : (0 : ℤ) ≤ (p.length : ℤ) + 2 := by positivity
        linarith
      rw [paramPath_concat, hv]
      cases s <;>
        simp only [lift, act_U₁, act_U₂, act_U₃, List.length_append, List.length_cons,
          List.length_nil, zero_add] <;>
        exact ⟨by omega, by omega⟩

/-- **Depth is at least `log₉(c/5)`.**  A word of `d` Berggren steps cannot reach a hypotenuse
larger than `5 · 9^d`. -/
theorem hyp_upper_depth (p : List BerggrenStep) :
    (applyPath p).2.2 ≤ 5 * 9 ^ p.length := by
  obtain ⟨h2, h1⟩ := paramPath_upper p
  obtain ⟨hl1, hl2, hl3⟩ := paramPath_lower p
  rw [← euclid_paramPath p]
  have hm : (0 : ℤ) ≤ (paramPath p).1 := by
    have : (0 : ℤ) ≤ (p.length : ℤ) + 2 := by positivity
    linarith
  have h9 : (9 : ℤ) ^ p.length = 3 ^ p.length * 3 ^ p.length := by
    rw [← mul_pow]; norm_num
  simp only [euclid]
  nlinarith [h1, h2, hm, hl2, h9]

/-- **Two-sided depth bound for Berggren circuits.**  Writing `d` for the depth of the word and
`c` for the hypotenuse of the triple it reaches, `(d+2)² < c ≤ 5 · 9^d`.  Equivalently
`log₉(c/5) ≤ d < √c - 2`: the computational depth of a Berggren "braid word" is pinned between
a logarithm and a square root of the arithmetic size of its output. -/
theorem depth_bounds (p : List BerggrenStep) :
    ((p.length : ℤ) + 2) ^ 2 < (applyPath p).2.2 ∧ (applyPath p).2.2 ≤ 5 * 9 ^ p.length :=
  ⟨hyp_lower_depth p, hyp_upper_depth p⟩

/-! ## Both extremes are attained -/

/-- The `A`-spine has Euclid parameters `(d+2, d+1)`. -/
theorem aSpine_param (d : ℕ) :
    paramPath (List.replicate d BerggrenStep.A) = ((d : ℤ) + 2, (d : ℤ) + 1) := by
  induction d with
  | zero => norm_num
  | succ d ih =>
      rw [List.replicate_succ', paramPath_concat, ih]
      simp only [lift, act_U₁, Prod.mk.injEq]
      constructor <;> push_cast <;> ring

/-- Along the `A`-spine the hypotenuse is exactly `(d+2)² + (d+1)²`: the quadratic lower bound
of `hyp_lower_depth` is sharp, so some Berggren circuits really do have depth `Θ(√c)`. -/
theorem aSpine_hyp (d : ℕ) :
    (applyPath (List.replicate d BerggrenStep.A)).2.2 = ((d : ℤ) + 2) ^ 2 + ((d : ℤ) + 1) ^ 2 := by
  rw [← euclid_paramPath, aSpine_param]
  simp [euclid]

/-- Concretely: `(3,4,5) → (5,12,13) → (7,24,25)` along the `A`-spine, of hypotenuse `5, 13, 25`,
matching `(d+2)² + (d+1)²`. -/
theorem aSpine_examples :
    (applyPath (List.replicate 0 BerggrenStep.A)).2.2 = 5 ∧
    (applyPath (List.replicate 1 BerggrenStep.A)).2.2 = 13 ∧
    (applyPath (List.replicate 2 BerggrenStep.A)).2.2 = 25 := by
  refine ⟨by rw [aSpine_hyp]; norm_num, by rw [aSpine_hyp]; norm_num,
    by rw [aSpine_hyp]; norm_num⟩

end BerggrenTQC