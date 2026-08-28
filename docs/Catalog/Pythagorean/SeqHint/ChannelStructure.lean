import Pythagorean.SeqHint.Battery
import Pythagorean.SeqHint.Adaptive

/-!
# Sequential hint pricing VI: what adaptivity actually buys

Files I–V established the dichotomy: fixed **comparison** batteries price
linearly (`k + 1`), adaptive comparison queries price geometrically (`2 ^ k`),
and `2 ^ k` is a hard ceiling.  A natural reading of that is "adaptivity creates
bits".  This file shows that reading is wrong, and replaces it with a sharper
one.

* `bitBattery_isolates` — a **non-adaptive** battery of `k` *general* Boolean
  predicates (the bit tests `x ↦ x.testBit i`) already separates all `2 ^ k`
  candidates of the window `[0, 2 ^ k)`.  No adaptivity, full geometric
  resolution.

* `general_battery_ceiling` — and it cannot do better: any `k` fixed predicates
  leave two candidates tied once `2 ^ k < #W`.

So the full Boolean channel prices at `2 ^ k` whether or not it is used
adaptively, and the comparison channel prices at `k + 1` non-adaptively and
`2 ^ k` adaptively.  The conclusion, `adaptivity_repairs_the_channel`:

> Adaptivity does not create information.  It exactly repairs the deficit of the
> **comparison** channel, whose non-adaptive answer vectors are order-determined
> (`sig_determines_answers`), and it repairs nothing in a channel that is
> already unrestricted.

Finally `card_image_transcriptG_le` generalises the ceiling to an arbitrary
finite answer alphabet: an `r`-ary hint oracle prices at `r ^ k`, i.e. at exactly
`log₂ r` bits per query — the general form of the isolation cost.
-/

namespace Pythagorean.SeqHint

open Finset

/-! ## The comparison channel is order-limited -/

/-- The comparison channel: `k` fixed thresholds produce at most `k + 1`
distinct answer vectors on any window, whatever the thresholds are. -/
theorem comparison_battery_class_bound (T W : Finset ℕ) :
    (W.image (sig T)).card ≤ T.card + 1 := by
  have hsub : W.image (sig T) ⊆ range (T.card + 1) := by
    intro v hv
    rw [mem_image] at hv
    obtain ⟨x, -, rfl⟩ := hv
    exact mem_range.2 (Nat.lt_succ_of_le (sig_le_card T x))
  calc (W.image (sig T)).card ≤ (range (T.card + 1)).card := card_le_card hsub
    _ = T.card + 1 := card_range _

/-! ## The unrestricted Boolean channel, used non-adaptively -/

/-- The answer vector of a fixed battery of `k` arbitrary Boolean predicates. -/
def answerVec {k : ℕ} (P : Fin k → ℕ → Bool) (x : ℕ) : Fin k → Bool := fun i => P i x

/-- **A fixed battery of general predicates already resolves `2 ^ k`
candidates.**  The bit tests `x ↦ x.testBit i`, `i < k`, separate every pair of
candidates below `2 ^ k` — no adaptivity involved. -/
theorem bitBattery_isolates (k : ℕ) {x y : ℕ} (hx : x < 2 ^ k) (hy : y < 2 ^ k)
    (h : answerVec (fun i : Fin k => fun n : ℕ => n.testBit i.val) x
       = answerVec (fun i : Fin k => fun n : ℕ => n.testBit i.val) y) : x = y := by
  apply Nat.eq_of_testBit_eq
  intro i
  by_cases hi : i < k
  · exact congrFun h ⟨i, hi⟩
  · have hxk : x < 2 ^ i := lt_of_lt_of_le hx (Nat.pow_le_pow_right (by norm_num) (by omega))
    have hyk : y < 2 ^ i := lt_of_lt_of_le hy (Nat.pow_le_pow_right (by norm_num) (by omega))
    rw [Nat.testBit_eq_false_of_lt hxk, Nat.testBit_eq_false_of_lt hyk]

/-- The bit battery is a genuine `k`-query fixed battery that isolates every
candidate of the window `[0, 2 ^ k)`. -/
theorem bitBattery_injOn (k : ℕ) :
    Set.InjOn (answerVec (fun i : Fin k => fun n : ℕ => n.testBit i.val))
      (Finset.Ico 0 (2 ^ k) : Finset ℕ) := by
  intro x hx y hy h
  rw [Finset.coe_Ico, Set.mem_Ico] at hx hy
  exact bitBattery_isolates k hx.2 hy.2 h

/-- **…and no fixed battery of general predicates does better.**  Once the
window exceeds `2 ^ k` candidates, any `k` predicates tie two of them. -/
theorem general_battery_ceiling {k : ℕ} (P : Fin k → ℕ → Bool) (W : Finset ℕ)
    (hW : 2 ^ k < W.card) :
    ∃ x ∈ W, ∃ y ∈ W, x ≠ y ∧ answerVec P x = answerVec P y := by
  have hcard : Fintype.card (Fin k → Bool) = 2 ^ k := by simp
  refine Finset.exists_ne_map_eq_of_card_lt_of_maps_to (t := (Finset.univ : Finset (Fin k → Bool)))
    ?_ (fun x _ => Finset.mem_coe.2 (Finset.mem_univ _))
  rw [Finset.card_univ, hcard]
  exact hW

/-- **Adaptivity repairs the channel; it does not create bits.**

1. Non-adaptive *comparison* hints: at most `k + 1` distinguishable candidates.
2. Non-adaptive *general* hints: exactly `2 ^ k` — already the ceiling.
3. Adaptive comparison hints: `2 ^ k` (`bisection_isolates`) — the same ceiling,
   and no strategy in any of the three settings exceeds it.

So the adaptivity premium `2 ^ k / (k + 1)` measures the deficit of the
comparison channel, not a gain produced by conditioning. -/
theorem adaptivity_repairs_the_channel (k : ℕ) :
    -- (1) the comparison channel, non-adaptively: at most `k + 1` classes
    (∀ T W : Finset ℕ, T.card = k → (W.image (sig T)).card ≤ k + 1) ∧
    -- (2) the general channel, non-adaptively: `2 ^ k` classes, and no more
    (Set.InjOn (answerVec (fun i : Fin k => fun n : ℕ => n.testBit i.val))
        (Finset.Ico 0 (2 ^ k) : Finset ℕ) ∧
      ∀ (P : Fin k → ℕ → Bool) (W : Finset ℕ), 2 ^ k < W.card →
        ∃ x ∈ W, ∃ y ∈ W, x ≠ y ∧ answerVec P x = answerVec P y) ∧
    -- (3) the comparison channel, adaptively: `2 ^ k`, and no more
    ((∀ x ∈ (Window.mk 0 (2 ^ k)).carrier, (bisect x k ⟨0, 2 ^ k⟩).carrier = {x}) ∧
      ∀ (S : Strategy) (W : Finset ℕ), 2 ^ k < W.card →
        ∃ x ∈ W, ∃ y ∈ W, x ≠ y ∧ transcript S x k = transcript S y k) := by
  refine ⟨?_, ⟨bitBattery_injOn k, fun P W hW => general_battery_ceiling P W hW⟩,
    ⟨(ceiling_is_exact k).1, fun S W hW => isolation_ceiling S W k hW⟩⟩
  intro T W hT
  have := comparison_battery_class_bound T W
  omega

/-! ## The general isolation cost: `r`-ary hint oracles -/

/-- An adaptive strategy over an arbitrary finite answer alphabet `A`: given the
answers so far, it selects a question, i.e. a map `ℕ → A` read at the hidden
value. -/
def transcriptG {A : Type} (S : List A → ℕ → A) (x : ℕ) : ℕ → List A
  | 0 => []
  | (k + 1) => (transcriptG S x k) ++ [S (transcriptG S x k) x]

/-- **The general isolation cost.**  A `k`-query adaptive strategy whose oracle
answers in an alphabet of size `r` produces at most `r ^ k` transcripts: each
query is worth exactly `log₂ r` bits, never more.  (`r = 2` recovers
`card_image_transcript_le`.) -/
theorem card_image_transcriptG_le {A : Type} [Fintype A] [DecidableEq A]
    (S : List A → ℕ → A) (W : Finset ℕ) :
    ∀ k : ℕ, (W.image (fun x => transcriptG S x k)).card ≤ (Fintype.card A) ^ k := by
  intro k
  induction k with
  | zero =>
      simp only [transcriptG, pow_zero]
      exact card_le_one.2 (by intro a ha b hb; simp_all)
  | succ k ih =>
      have hsub : W.image (fun x => transcriptG S x (k + 1)) ⊆
          (W.image (fun x => transcriptG S x k)).biUnion
            (fun l => (Finset.univ : Finset A).image (fun a => l ++ [a])) := by
        intro l hl
        rw [mem_image] at hl
        obtain ⟨x, hx, rfl⟩ := hl
        rw [mem_biUnion]
        exact ⟨transcriptG S x k, mem_image_of_mem _ hx,
          mem_image.2 ⟨S (transcriptG S x k) x, mem_univ _, rfl⟩⟩
      calc (W.image (fun x => transcriptG S x (k + 1))).card
          ≤ ((W.image (fun x => transcriptG S x k)).biUnion
              (fun l => (Finset.univ : Finset A).image (fun a => l ++ [a]))).card :=
            card_le_card hsub
        _ ≤ ∑ _l ∈ W.image (fun x => transcriptG S x k), Fintype.card A := by
              refine le_trans card_biUnion_le (sum_le_sum ?_)
              intro l _
              exact le_trans (card_image_le) (by simp)
        _ = (W.image (fun x => transcriptG S x k)).card * Fintype.card A := by
              rw [sum_const, smul_eq_mul]
        _ ≤ Fintype.card A ^ k * Fintype.card A := Nat.mul_le_mul_right _ ih
        _ = Fintype.card A ^ (k + 1) := by ring

/-- The `r`-ary isolation ceiling: with an `r`-valued oracle, `k` queries cannot
separate more than `r ^ k` candidates. -/
theorem isolation_ceiling_general {A : Type} [Fintype A] [DecidableEq A]
    (S : List A → ℕ → A) (W : Finset ℕ) (k : ℕ) (hk : (Fintype.card A) ^ k < W.card) :
    ∃ x ∈ W, ∃ y ∈ W, x ≠ y ∧ transcriptG S x k = transcriptG S y k := by
  refine Finset.exists_ne_map_eq_of_card_lt_of_maps_to
    (t := W.image (fun x => transcriptG S x k))
    (lt_of_le_of_lt (card_image_transcriptG_le S W k) hk) ?_
  intro x hx
  exact mem_coe.2 (mem_image_of_mem _ hx)

end Pythagorean.SeqHint