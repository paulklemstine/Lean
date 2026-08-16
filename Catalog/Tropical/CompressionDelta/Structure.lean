import Tropical.CompressionDelta.Amortization

/-!
# Amortized model-delta compression, VIII: structural laws of the protocol optimum

Three structural facts about the min-plus protocol optimum, all of independent interest
for designing amortized protocols.

## Main results

* `CompressionDelta.optCost_append_ge` — **superadditivity**: splitting a stream can only
  help the encoder, and never by more than the freedom to choose the decoder state at the
  splice point.  This is the min-plus analogue of submultiplicativity of matrix norms.
* `CompressionDelta.optCost_mono` — the optimum is monotone in the model-delta cost.
* `CompressionDelta.minPlusComp_eq_self_iff_triangle` and
  `CompressionDelta.optCost_minPlusComp` — the delta cost matrix is a fixed point of
  min-plus self-composition exactly when it satisfies the triangle inequality, and then
  allowing multi-hop patches (compose two smaller deltas) does not change the optimum:
  **there is no gain in routing a model patch through an intermediate model**.
* `CompressionDelta.optCost_replicate_concave` — the marginal cost of one more message is
  non-increasing: an amortized protocol enjoys economies of scale.
-/

namespace CompressionDelta

variable {M : Type*} [Finite M] [Nonempty M]

/-- Infima over `ℕ` absorb an additive constant. -/
theorem natInf_add_const {ι : Type*} [Finite ι] [Nonempty ι] (f : ι → ℕ) (a : ℕ) :
    (⨅ i, (f i + a)) = (⨅ i, f i) + a := by
  refine le_antisymm ?_ ?_
  · obtain ⟨i, hi⟩ := exists_natInf_eq f
    calc (⨅ i, (f i + a)) ≤ f i + a := natInf_le _ i
      _ = (⨅ i, f i) + a := by rw [hi]
  · refine le_natInf ?_
    intro i
    have : (⨅ j, f j) ≤ f i := natInf_le f i
    omega

/-- **Superadditivity of the protocol optimum.**  Coding a concatenated stream costs at
least the optimum of the prefix plus the best possible cost of the suffix over all splice
states. -/
theorem optCost_append_ge (dlt : M → M → ℕ) :
    ∀ (cs ds : List (M → ℕ)) (prev : M),
      optCost dlt prev cs + (⨅ m : M, optCost dlt m ds) ≤ optCost dlt prev (cs ++ ds) := by
  intro cs
  induction cs with
  | nil =>
      intro ds prev
      simpa using natInf_le (fun m : M => optCost dlt m ds) prev
  | cons c cs ih =>
      intro ds prev
      rw [List.cons_append, optCost_cons, optCost_cons]
      refine le_natInf ?_
      intro m
      have h := ih ds m
      have h2 : (⨅ m' : M, (dlt prev m' + c m' + optCost dlt m' cs)) ≤
          dlt prev m + c m + optCost dlt m cs := natInf_le _ m
      omega

/-- The protocol optimum is monotone in the model-delta cost. -/
theorem optCost_mono (dlt dlt' : M → M → ℕ) (h : ∀ i j, dlt i j ≤ dlt' i j) :
    ∀ (cs : List (M → ℕ)) (prev : M), optCost dlt prev cs ≤ optCost dlt' prev cs := by
  intro cs
  induction cs with
  | nil => intro prev; simp
  | cons c cs ih =>
      intro prev
      rw [optCost_cons, optCost_cons]
      refine le_natInf ?_
      intro m
      have h1 := h prev m
      have h2 := ih m
      have h3 : optCost dlt prev (c :: cs) ≤ dlt prev m + c m + optCost dlt m cs := by
        rw [optCost_cons]; exact natInf_le _ m
      rw [optCost_cons] at h3
      omega

/-- **Switching first is never worse than the delta.**  If the model-delta cost obeys the
triangle inequality, the optimum from a state exceeds the optimum from any other state by
at most the delta between them. -/
theorem optCost_le_switch (dlt : M → M → ℕ) (htri : ∀ i k j, dlt i j ≤ dlt i k + dlt k j)
    (s s' : M) (cs : List (M → ℕ)) :
    optCost dlt s cs ≤ dlt s s' + optCost dlt s' cs := by
  cases cs with
  | nil => simp
  | cons c cs =>
      obtain ⟨m, hm⟩ :=
        exists_natInf_eq (fun m : M => dlt s' m + c m + optCost dlt m cs)
      have h1 : optCost dlt s (c :: cs) ≤ dlt s m + c m + optCost dlt m cs := by
        rw [optCost_cons]; exact natInf_le _ m
      have h2 : dlt s m ≤ dlt s s' + dlt s' m := htri s s' m
      have h3 : optCost dlt s' (c :: cs) = dlt s' m + c m + optCost dlt m cs := by
        rw [optCost_cons, hm]
      omega

/-- Min-plus (tropical) self-composition of the model-delta cost matrix: the cheapest way
of moving the decoder from `i` to `j` via one intermediate model. -/
noncomputable def minPlusComp (dlt : M → M → ℕ) : M → M → ℕ :=
  fun i j => ⨅ k : M, (dlt i k + dlt k j)

omit [Finite M] in
/-- Routing through an intermediate model is never more expensive (take the trivial
route). -/
theorem minPlusComp_le (dlt : M → M → ℕ) (hself : ∀ m : M, dlt m m = 0) (i j : M) :
    minPlusComp dlt i j ≤ dlt i j := by
  have := natInf_le (fun k : M => dlt i k + dlt k j) i
  rw [hself i] at this
  simpa [minPlusComp] using this

omit [Finite M] in
/-- **The triangle inequality is exactly min-plus idempotence.**  The delta cost matrix is
a fixed point of tropical self-composition iff patching through an intermediate model
never helps. -/
theorem minPlusComp_eq_self_iff_triangle (dlt : M → M → ℕ) (hself : ∀ m : M, dlt m m = 0) :
    (∀ i j, minPlusComp dlt i j = dlt i j) ↔ ∀ i k j, dlt i j ≤ dlt i k + dlt k j := by
  constructor
  · intro h i k j
    have h1 : minPlusComp dlt i j ≤ dlt i k + dlt k j :=
      natInf_le (fun k : M => dlt i k + dlt k j) k
    rw [h i j] at h1
    exact h1
  · intro h i j
    refine le_antisymm (minPlusComp_le dlt hself i j) ?_
    exact le_natInf (fun k => h i k j)

/-- **No gain from multi-hop patches.**  If the model-delta cost satisfies the triangle
inequality, then allowing the encoder to compose two patches leaves the protocol optimum
unchanged. -/
theorem optCost_minPlusComp (dlt : M → M → ℕ) (hself : ∀ m : M, dlt m m = 0)
    (htri : ∀ i k j, dlt i j ≤ dlt i k + dlt k j) (cs : List (M → ℕ)) (prev : M) :
    optCost (minPlusComp dlt) prev cs = optCost dlt prev cs := by
  have hfun : minPlusComp dlt = dlt := by
    funext i j
    exact (minPlusComp_eq_self_iff_triangle dlt hself).mpr htri i j
  rw [hfun]

/-- **Economies of scale.**  In the sharp two-state model the marginal cost of one more
message is non-increasing: the optimum is a concave function of the stream length. -/
theorem optCost_replicate_concave (r D n : ℕ) :
    optCost (boolDelta D) false (List.replicate n (boolCost r)) +
        optCost (boolDelta D) false (List.replicate (n + 2) (boolCost r)) ≤
      2 * optCost (boolDelta D) false (List.replicate (n + 1) (boolCost r)) := by
  rw [boolModel_optCost, boolModel_optCost, boolModel_optCost]
  have h1 : (n + 1) * r = n * r + r := by ring
  have h2 : (n + 2) * r = n * r + 2 * r := by ring
  omega

end CompressionDelta