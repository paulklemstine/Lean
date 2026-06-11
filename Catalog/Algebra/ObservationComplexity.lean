import Mathlib
import Algebra.ObservationGap
import Algebra.AdaptiveObservationGap

/-!
# The Observation Complexity Theorem: Exact Query Cost of Indistinguishability

This file closes the **information-theoretic gap** left open by
`Catalog/Algebra/ObservationGap.lean` and
`Catalog/Algebra/AdaptiveObservationGap.lean`.

Those files prove the *one-sided* counting bound: an observation system of depth
`n` can distinguish at most `2 ^ n` elements
(`ObservationGap.observation_pigeonhole`,
`AdaptiveObservationGap.adaptive_card_le_of_distinguishes`), and that the bound is
*achievable* on `Fin (2 ^ n)` (`ObservationGap.observation_can_suffice`,
`AdaptiveObservationGap.adaptive_can_suffice`).

What was missing is the **exact query complexity** for an *arbitrary* finite type:
how many Boolean observations are *necessary and sufficient* to tell apart every
element of a type `α` with `|α|` elements?  The answer is Shannon's bound made
precise:

> the minimal depth of a distinguishing observation system equals
> `⌈log₂ |α|⌉ = Nat.clog 2 |α|`,

and — crucially — adaptivity (a decision tree whose queries may depend on earlier
answers) gives **no speedup** over a fixed family of predicates: the same number
`Nat.clog 2 |α|` is optimal for both models.

## Main results

* `distinguish_depth_ge_clog` — **lower bound**: any *adaptive* system that
  distinguishes all of `α` has depth `≥ Nat.clog 2 |α|`.  (Sharpens
  `adaptive_card_le_of_distinguishes` from a cardinality bound to a depth bound.)
* `exists_distinguishing_static` — **upper bound**: there is a *static* system of
  depth exactly `Nat.clog 2 |α|` distinguishing all of `α`.  (Generalizes
  `observation_can_suffice` from `Fin (2 ^ n)` to every finite type.)
* `min_distinguishing_depth` — **the exact complexity**: `Nat.clog 2 |α|` is the
  *least* depth admitting a distinguishing adaptive system (`IsLeast`).  This is
  the flagship theorem: lower bound (adaptive) meets upper bound (static).
* `min_distinguishing_depth_fin100` — a concrete corollary: distinguishing the
  100 elements of `Fin 100` costs exactly `7` observations.
* `generalized_observation_complexity` — the `k`-ary lower bound: for observations
  valued in a `k`-element type the cost is `≥ Nat.clog k |α|`.

## References
* C. E. Shannon, *A mathematical theory of communication* (1948) — the "1 bit per
  query" decision-tree lower bound.
-/

namespace ObservationComplexity

open ObservationGap AdaptiveObservationGap

universe u

-- !-- Lab Notebook: distinguish_depth_ge_clog -- !--
-- !-- Hypothesis: the pigeonhole cardinality bound |α| ≤ 2^n should sharpen into a
--     query lower bound n ≥ clog₂|α| by applying clog monotonicity. -- !--
-- !-- Result: Proved. From adaptive_card_le_of_distinguishes we get |α| ≤ 2^n; apply
--     Nat.clog_mono_right and Nat.clog_pow to conclude clog 2 |α| ≤ clog 2 (2^n) = n. -- !--
-- !-- Insight: clog is the exact inverse of (2 ^ ·) on powers, so the counting bound
--     and the depth bound are literally the same statement transported through clog. -- !--
-- !-- Failure analysis: A direct induction on the tree depth is unnecessary; reusing the
--     already-proven cardinality bound is far cleaner. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Sketch: |α| ≤ 2^n (adaptive_card_le_of_distinguishes); clog 2 (·) is monotone
--     and clog 2 (2^n) = n, hence clog 2 |α| ≤ n. -- !--
/-- **Information-theoretic lower bound.**  Any adaptive observation system of depth
`n` that distinguishes every element of a finite type `α` must satisfy
`Nat.clog 2 |α| ≤ n`.  Equivalently: at least `⌈log₂ |α|⌉` Boolean queries are
necessary, even with full adaptivity. -/
theorem distinguish_depth_ge_clog {α : Type u} [Fintype α] {n : ℕ}
    (O : AdaptiveObs α n) (hinj : Function.Injective O.transcript) :
    Nat.clog 2 (Fintype.card α) ≤ n := by
  have h := adaptive_card_le_of_distinguishes O hinj
  calc Nat.clog 2 (Fintype.card α) ≤ Nat.clog 2 (2 ^ n) := Nat.clog_mono_right 2 h
    _ = n := Nat.clog_pow 2 n (by norm_num)

-- !-- Lab Notebook: exists_distinguishing_static -- !--
-- !-- Hypothesis: observation_can_suffice handles Fin (2^n); a general α with |α| ≤ 2^n
--     should inherit a distinguishing system by pulling predicates back along an
--     embedding α ↪ Fin (2^n). -- !--
-- !-- Result: Proved. Take n = clog 2 |α|; then |α| ≤ 2^n (Nat.le_pow_clog), giving an
--     embedding e; pull back the bit-extraction system from observation_can_suffice. -- !--
-- !-- Insight: The optimal *static* construction is just "binary-encode an injection into
--     Fin (2^n)", so the catalog's Fin (2^n) result is genuinely the universal case. -- !--
-- !-- Failure analysis: First considered a bespoke testBit system on α directly, but
--     reusing observation_can_suffice through the embedding avoids re-deriving bit lemmas. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Sketch: |α| ≤ 2^(clog 2 |α|) (Nat.le_pow_clog), so ∃ embedding e : α ↪ Fin(2^n);
--     pull back observation_can_suffice's system: pred i a := O'.pred i (e a). -- !--
/-- **Matching upper bound (static, hence adaptive).**  Every finite type `α` admits
a *static* observation system of depth exactly `Nat.clog 2 |α|` that distinguishes
all of its elements.  Generalizes `ObservationGap.observation_can_suffice` from
`Fin (2 ^ n)` to an arbitrary finite type. -/
theorem exists_distinguishing_static {α : Type u} [Fintype α] [DecidableEq α] :
    ∃ O : ObsSys α (Nat.clog 2 (Fintype.card α)),
      ∀ a b : α, O.twins a b → a = b := by
  set n := Nat.clog 2 (Fintype.card α) with hn
  have hcard : Fintype.card α ≤ Fintype.card (Fin (2 ^ n)) := by
    simpa using Nat.le_pow_clog (by norm_num) (Fintype.card α)
  obtain ⟨e⟩ := Function.Embedding.nonempty_of_card_le hcard
  obtain ⟨O', hO'⟩ := ObservationGap.observation_can_suffice n
  exact ⟨⟨fun i a => O'.pred i (e a)⟩, fun a b h => e.injective (hO' _ _ h)⟩

-- !-- Lab Notebook: min_distinguishing_depth -- !--
-- !-- Hypothesis: clog 2 |α| is simultaneously a lower bound (adaptive) and achievable
--     (static), hence it is the exact least distinguishing depth. -- !--
-- !-- Result: Proved as IsLeast. Membership from exists_distinguishing_static converted
--     to an adaptive system via AdaptiveObs.ofStatic + twins_ofStatic; the lower-bound
--     half is distinguish_depth_ge_clog. -- !--
-- !-- Insight: The least element of the achievable-depth set is identical for the static
--     and adaptive models — a precise statement that *adaptivity buys no speedup*. -- !--
-- !-- Failure analysis: Stating it as IsLeast (rather than an sInf equality) sidesteps the
--     need to pad small trees up to larger depths. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Sketch: lower half = distinguish_depth_ge_clog; membership: turn the static system
--     of exists_distinguishing_static into AdaptiveObs.ofStatic, whose transcript equals
--     the static profile (twins_ofStatic), so injectivity = the distinguishing property. -- !--
/-- **The Observation Complexity Theorem.**  `Nat.clog 2 |α|` is the *least* depth `n`
for which some adaptive observation system of depth `n` distinguishes every element
of `α`.  The lower bound holds for adaptive systems and is met by a static one, so
the exact Boolean query complexity of distinguishability is `⌈log₂ |α|⌉` and
adaptivity provides no advantage. -/
theorem min_distinguishing_depth (α : Type u) [Fintype α] [DecidableEq α] :
    IsLeast {n : ℕ | ∃ O : AdaptiveObs α n, Function.Injective O.transcript}
      (Nat.clog 2 (Fintype.card α)) := by
  refine ⟨?_, ?_⟩
  · obtain ⟨O, hO⟩ := exists_distinguishing_static (α := α)
    exact ⟨AdaptiveObs.ofStatic O, fun a b h => hO a b ((twins_ofStatic O a b).1 h)⟩
  · rintro n ⟨O, hinj⟩
    exact distinguish_depth_ge_clog O hinj

-- !-- Lab Notebook: min_distinguishing_depth_fin100 -- !--
-- !-- Hypothesis: instantiating the complexity theorem at Fin 100 should give the clean
--     numeric answer 7 = ⌈log₂ 100⌉. -- !--
-- !-- Result: Proved. Fintype.card (Fin 100) = 100 and Nat.clog 2 100 = 7. -- !--
-- !-- Insight: 2^6 = 64 < 100 ≤ 128 = 2^7, so 6 observations are provably insufficient
--     while 7 suffice — the gap is realized by a concrete object. -- !--
-- !-- Failure analysis: none; a direct specialization of min_distinguishing_depth. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Sketch: rewrite card (Fin 100) = 100 and the genuine numeric fact clog 2 100 = 7,
--     then apply min_distinguishing_depth. -- !--
/-- **Concrete instance.**  Distinguishing all `100` elements of `Fin 100` requires
exactly `7` Boolean observations: `IsLeast` of the achievable-depth set is `7`. -/
theorem min_distinguishing_depth_fin100 :
    IsLeast {n : ℕ | ∃ O : AdaptiveObs (Fin 100) n, Function.Injective O.transcript} 7 := by
  have h := min_distinguishing_depth (Fin 100)
  rw [Fintype.card_fin, show Nat.clog 2 100 = 7 from by decide] at h
  exact h

-- ============================================================================
-- Generalization loop (Step 7): k-ary observations
-- ============================================================================

-- !-- Lab Notebook: generalized_observation_complexity -- !--
-- !-- Hypothesis: the Boolean lower bound should lift to k-ary observations valued in any
--     finite type β, with base 2 replaced by |β| = k throughout. -- !--
-- !-- Result: Proved. Injectivity of the profile gives |α| ≤ |β|^n (Fintype.card_pi);
--     clog monotonicity + clog_pow finish when |β| ≥ 2, and the base ≤ 1 case is
--     handled by Nat.clog_of_left_le_one (clog with base ≤ 1 is 0). -- !--
-- !-- Insight: The counting → complexity transport is base-agnostic; only the base ≥ 2
--     hypothesis of clog_pow needs a separate (degenerate) case split. -- !--
-- !-- Failure analysis: Forgetting the |β| ≤ 1 boundary case left a non-closing goal;
--     the case split on lt_or_ge 1 |β| repairs it. This boundary is exactly why the
--     formula `Nat.clog k` is only *sharp* for k ≥ 2. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Sketch: |α| ≤ |β|^n via Fintype.card_le_of_injective on the profile map; then
--     clog |β| is monotone with clog |β| (|β|^n) = n for |β| ≥ 2; degenerate |β| ≤ 1
--     gives clog = 0. -- !--
/-- **Generalized (k-ary) lower bound.**  For observations valued in a finite type `β`
of size `k`, any system whose profile distinguishes all of `α` has depth
`≥ Nat.clog k |α|`.  This is the base-`k` analogue of `distinguish_depth_ge_clog`;
it is sharp precisely when `k ≥ 2` (for `k ≤ 1` no positive depth can separate a
type with `≥ 2` elements, and `Nat.clog k = 0` reflects the vacuity). -/
theorem generalized_observation_complexity {α β : Type u}
    [Fintype α] [Fintype β] [DecidableEq α] {n : ℕ}
    (O : GenObsSys α β n) (hinj : Function.Injective O.profile) :
    Nat.clog (Fintype.card β) (Fintype.card α) ≤ n := by
  have hle : Fintype.card α ≤ Fintype.card β ^ n := by
    have := Fintype.card_le_of_injective O.profile hinj
    simpa [Fintype.card_pi] using this
  rcases lt_or_ge 1 (Fintype.card β) with hb | hb
  · calc Nat.clog (Fintype.card β) (Fintype.card α)
        ≤ Nat.clog (Fintype.card β) (Fintype.card β ^ n) := Nat.clog_mono_right _ hle
      _ = n := Nat.clog_pow _ n hb
  · rw [Nat.clog_of_left_le_one hb]
    exact Nat.zero_le n

end ObservationComplexity