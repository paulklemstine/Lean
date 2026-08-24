import Novelty.ProbeHybridStability

/-!
# The knee is a lower bound for *every* eviction policy (NET-67 ⋈ NET-69)

`Novelty.AttentionRetentionKnee` (round 21, NET-67) studies the knee
`knee p τ = sInf {k | τ ≤ ∑_{i<k} p i}` of a *sorted* attention profile: the
number of keys the top-`k` policy needs in order to reach the drift-assert
threshold `τ`.  `Novelty.ProbeRetentionLimits` (round 22, NET-69) studies
arbitrary budget-`B` selection rules driven by a score.  This file joins them.

The bridge is the observation that, for a sorted profile, the **prefix is a top
set** in the sense of NET-69 (`isTopSet_prefixSel`).  Everything follows:

* `retained_le_retained_prefix` — no budget-`B` policy, however clever, retains
  more mass than the prefix of length `B`.  The NET-67 retention curve is thus
  not merely the curve of one heuristic; it is the *envelope* of all policies.
* `retained_lt_of_card_lt_knee` — below the knee **every** policy misses the
  threshold.  The knee is therefore a hard budget floor, not an artefact of
  top-`k` eviction: reporting `12/16` keys for code (NET-68) is reporting a
  quantity no scoring rule can beat.
* `knee_le_of_reaches` — the contrapositive, in the form used experimentally:
  an arm that passes the drift assert at budget `B` certifies `knee ≤ B`.
* `probe_at_knee_budget` — the NET-69 arms re-enter: a score with `L∞` error `ε`
  run at any budget `B ≥ knee p τ` still retains at least `τ - 2Bε`.  Combined
  with the sharpness instance `sup_transfer_bound_is_sharp`, this is the exact
  price of content-blindness: a weak probe costs mass at most linearly in the
  budget and its error, and that linear rate is attained.
-/

namespace Catalog.Novelty.ProbeKneeBridge

open Finset Catalog.Novelty.ProbeRetentionLimits

variable {n k B : ℕ} {p : ℕ → ℝ} {tau : ℝ}

/-- The importance vector that a sorted profile `p` induces on a context of `n`
keys. -/
def keyMass (p : ℕ → ℝ) (n : ℕ) : Fin n → ℝ := fun i => p (i : ℕ)

/-- The prefix selection: the `k` best-ranked keys of an `n`-key context. -/
def prefixSel (n k : ℕ) (h : k ≤ n) : Finset (Fin n) :=
  (Finset.range k).attachFin fun _ hm => lt_of_lt_of_le (Finset.mem_range.mp hm) h

@[simp] lemma card_prefixSel (h : k ≤ n) : (prefixSel n k h).card = k := by
  simp [prefixSel, Finset.card_attachFin]

lemma mem_prefixSel {h : k ≤ n} {i : Fin n} : i ∈ prefixSel n k h ↔ (i : ℕ) < k := by
  simp [prefixSel, Finset.mem_attachFin]

/-- The two notions of retained mass agree on prefixes: the NET-67 retention
curve is the NET-69 retained mass of the prefix selection. -/
lemma retained_prefixSel (h : k ≤ n) :
    retained (keyMass p n) (prefixSel n k h)
      = Catalog.Novelty.AttentionRetentionKnee.retained p k := by
  refine Finset.sum_bij' (fun (i : Fin n) _ => (i : ℕ))
    (fun m hm => (⟨m, lt_of_lt_of_le (Finset.mem_range.mp hm) h⟩ : Fin n)) ?_ ?_ ?_ ?_ ?_
  · intro a ha; exact (Finset.mem_attachFin _).mp ha
  · intro m hm; exact (Finset.mem_attachFin _).mpr (by simpa using hm)
  · intro a _; rfl
  · intro m _; rfl
  · intro a _; rfl

/-- **The prefix of a sorted profile is a top set.**  This is the bridge: the
NET-67 top-`k` policy is exactly the oracle policy of NET-69. -/
theorem isTopSet_prefixSel (hp : Antitone p) (h : k ≤ n) :
    IsTopSet (keyMass p n) k (prefixSel n k h) := by
  refine ⟨card_prefixSel h, fun i hi j hj => ?_⟩
  have hik : (i : ℕ) < k := mem_prefixSel.mp hi
  have hjk : ¬ ((j : ℕ) < k) := fun hc => hj (mem_prefixSel.mpr hc)
  exact hp (le_of_lt (lt_of_lt_of_le hik (not_lt.mp hjk)))

/-- **The retention curve is the envelope of all policies.**  No budget-`k`
selection retains more mass than the prefix of length `k`. -/
theorem retained_le_retained_prefix (hp : Antitone p) (h : k ≤ n) {S : Finset (Fin n)}
    (hS : S.card = k) :
    retained (keyMass p n) S ≤ Catalog.Novelty.AttentionRetentionKnee.retained p k := by
  rw [← retained_prefixSel (p := p) h]
  exact retained_le_of_isTopSet_true (isTopSet_prefixSel hp h) hS

/-- **Below the knee every policy fails.**  If the budget is smaller than the
knee then no scoring rule whatsoever reaches the drift-assert threshold: the
knee is a hard floor on the key budget, not a property of top-`k` eviction. -/
theorem retained_lt_of_card_lt_knee (hp : Antitone p) (hB : B ≤ n)
    (hlt : B < Catalog.Novelty.AttentionRetentionKnee.knee p tau) {S : Finset (Fin n)}
    (hS : S.card = B) : retained (keyMass p n) S < tau :=
  lt_of_le_of_lt (retained_le_retained_prefix hp hB hS)
    (Catalog.Novelty.AttentionRetentionKnee.lt_knee hlt)

/-- The experimentally used contrapositive: an arm that passes the drift assert
at budget `B` certifies that the knee is at most `B`. -/
theorem knee_le_of_reaches (hp : Antitone p) (hB : B ≤ n) {S : Finset (Fin n)}
    (hS : S.card = B) (hreach : tau ≤ retained (keyMass p n) S) :
    Catalog.Novelty.AttentionRetentionKnee.knee p tau ≤ B := by
  by_contra hc
  exact absurd hreach (not_le.mpr (retained_lt_of_card_lt_knee hp hB (not_le.mp hc) hS))

/-- **The price of content-blindness.**  A score with `L∞` error `ε`, run at any
budget at least the knee, still reaches the threshold up to `2Bε`.  With
`sup_transfer_bound_is_sharp` (which attains `2Bε`) this pins the cost of a weak
probe exactly: linear in the budget and in the error, and no better.  Note that
sortedness of the profile is *not* needed here — only the threshold reachability
supplied by the knee. -/
theorem probe_at_knee_budget {s : Fin n → ℝ} {ε : ℝ}
    (hnn : ∀ i, 0 ≤ p i) (hB : B ≤ n)
    (hknee : Catalog.Novelty.AttentionRetentionKnee.knee p tau ≤ B)
    (hex : ∃ m, tau ≤ Catalog.Novelty.AttentionRetentionKnee.retained p m)
    {S : Finset (Fin n)} (hS : IsTopSet s B S) (hε : ∀ i, |keyMass p n i - s i| ≤ ε) :
    tau - 2 * B * ε ≤ retained (keyMass p n) S := by
  have hthr : tau ≤ Catalog.Novelty.AttentionRetentionKnee.retained p B :=
    le_trans (Catalog.Novelty.AttentionRetentionKnee.knee_spec hex)
      (Catalog.Novelty.AttentionRetentionKnee.retained_mono hnn hknee)
  have htrans := retained_ge_of_isTopSet_sup (a := keyMass p n) (s := s)
    hS (card_prefixSel (n := n) (k := B) hB) hε
  rw [retained_prefixSel (p := p) hB] at htrans
  linarith

end Catalog.Novelty.ProbeKneeBridge