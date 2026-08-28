import Mathlib

/-!
# Sequential hint pricing I: non-adaptive batteries price *linearly*

This file is the first of a group formalising the pricing structure behind the
`SEQHINT-COMPOUND-LAW` experiment (exp 563 / paper 212).  The scenario is the
standard one for *hinted factoring*: a semiprime `N = p q` is given, the smaller
factor `p` is known to lie in a search window `W ⊆ ℕ`, and an external oracle
answers truthful comparison queries `p ≤ t?`.  A *hint battery* is a finite set
`T` of thresholds asked **non-adaptively** (all at once, before any answer is
seen).  This is the arm called `NONADAPT` in the experiment.

The mathematical content of this file:

* `Pythagorean.SeqHint.sig` — the *signature* of a candidate under a battery,
  i.e. how many thresholds it lies below.  `sig_determines_answers` shows the
  signature is a **complete invariant** for the answer vector, because the
  answer sets of a comparison battery are nested.  Consequently a battery of
  `k` thresholds can distinguish at most `k + 1` candidates, not `2 ^ k`.

* `nonadapt_linear_pricing` — the linear pricing law: for **every** battery `T`
  with `#T = k` there is a surviving class `C ⊆ W` of pairwise
  indistinguishable candidates with `#C ≥ #W / (k + 1)`.  So the achievable
  speedup of a fixed battery is at most `k + 1`: hints bought in a fixed batch
  price *linearly*, which is exactly the no-synergy law of paper 138.

* `battery_sharp_uniform` — sharpness: a single threshold placed at the lower
  median really does cut the window in half, so the bound `k + 1` is attained at
  `k = 1`.  This is the `r(1) = 1.00 EXACTLY` entry of the experiment: with one
  query there is nothing to adapt to, and adaptivity buys nothing.

* `zero_bit_collapse` / `zero_bit_collapse_class` — the *balanced-stratum
  collapse* (ledger catch A5).  If no threshold of the battery falls strictly
  inside the true support window, then all candidates in the support share the
  same answer vector: the battery carries **literally zero bits** and the
  speedup is exactly `1`, no matter how large `k` is.  For balanced semiprimes
  (`ρ = q / p ∈ [1, 1.01]`) the support of `min (p, q)` is pinned in a window of
  relative width `≈ 0.5 %` around `√N`, which a uniform battery of `k ≤ 24`
  thresholds misses entirely; `uniform_battery_zero_bits_balanced` is a
  machine-checked instance of exactly that configuration at bit length `40`.
-/

namespace Pythagorean.SeqHint

open Finset

/-! ## Signatures of a non-adaptive battery -/

/-- The **signature** of a candidate `x` under the threshold battery `T`:
the number of thresholds of `T` that `x` lies below (weakly). -/
def sig (T : Finset ℕ) (x : ℕ) : ℕ := (T.filter (fun t => x ≤ t)).card

lemma sig_le_card (T : Finset ℕ) (x : ℕ) : sig T x ≤ T.card :=
  card_filter_le _ _

lemma answerSet_subset_of_le {x y : ℕ} (h : x ≤ y) (T : Finset ℕ) :
    T.filter (fun t => y ≤ t) ⊆ T.filter (fun t => x ≤ t) := by
  intro t ht
  rw [mem_filter] at ht ⊢
  exact ⟨ht.1, h.trans ht.2⟩

/-- The answer sets of a comparison battery are **nested**, hence the signature
determines the whole answer vector.  This is the structural reason a fixed
battery of `k` comparison queries carries `log₂ (k+1)` bits and not `k` bits. -/
lemma sig_determines_answers {T : Finset ℕ} {x y : ℕ} (hs : sig T x = sig T y) :
    ∀ t ∈ T, (x ≤ t ↔ y ≤ t) := by
  suffices H : ∀ a b : ℕ, a ≤ b → sig T a = sig T b → ∀ t ∈ T, (a ≤ t ↔ b ≤ t) by
    rcases le_total x y with h | h
    · exact H x y h hs
    · intro t ht; exact (H y x h hs.symm t ht).symm
  intro a b hab hsab t ht
  have hsub := answerSet_subset_of_le hab T
  have hcard : (T.filter (fun t => a ≤ t)).card ≤ (T.filter (fun t => b ≤ t)).card :=
    le_of_eq hsab
  have hEq : T.filter (fun t => b ≤ t) = T.filter (fun t => a ≤ t) :=
    eq_of_subset_of_card_le hsub hcard
  constructor
  · intro hat
    have hmem : t ∈ T.filter (fun t => a ≤ t) := mem_filter.2 ⟨ht, hat⟩
    rw [← hEq] at hmem
    exact (mem_filter.1 hmem).2
  · intro hbt
    exact hab.trans hbt

/-- The indistinguishability class of signature `v` inside the window `W`. -/
def cls (T W : Finset ℕ) (v : ℕ) : Finset ℕ := W.filter (fun x => sig T x = v)

lemma cls_subset (T W : Finset ℕ) (v : ℕ) : cls T W v ⊆ W := filter_subset _ _

/-- Any two candidates in the same class produce **identical** oracle answers,
so no downstream algorithm can tell them apart. -/
lemma indistinguishable_of_mem_cls {T W : Finset ℕ} {v x y : ℕ}
    (hx : x ∈ cls T W v) (hy : y ∈ cls T W v) : ∀ t ∈ T, (x ≤ t ↔ y ≤ t) := by
  have hx' := (mem_filter.1 hx).2
  have hy' := (mem_filter.1 hy).2
  exact sig_determines_answers (hx'.trans hy'.symm)

/-! ## The linear pricing law for fixed batteries -/

/-- **Pigeonhole for comparison batteries.**  A battery of `k = #T` thresholds
splits the window into at most `k + 1` classes, so some class retains at least a
`1 / (k + 1)` fraction of the window. -/
theorem exists_large_cls (T W : Finset ℕ) :
    ∃ v, W.card / (T.card + 1) ≤ (cls T W v).card := by
  obtain ⟨v, -, hv⟩ :=
    Finset.exists_le_card_fiber_of_mul_le_card_of_maps_to
      (s := W) (t := range (T.card + 1)) (f := sig T) (n := W.card / (T.card + 1))
      (fun a _ => mem_range.2 (Nat.lt_succ_of_le (sig_le_card T a)))
      ⟨0, mem_range.2 (Nat.succ_pos _)⟩
      (by
        rw [card_range, mul_comm]
        exact Nat.div_mul_le_self _ _)
  exact ⟨v, hv⟩

/-- **Non-adaptive hints price linearly (paper-138 no-synergy law).**
For *every* fixed battery `T` of `k` thresholds there is a set `C` of candidates
of size at least `#W / (k + 1)` that the battery cannot separate at all.  Hence
the speedup a fixed battery can buy is at most `k + 1`: linear in the number of
hints, never geometric. -/
theorem nonadapt_linear_pricing (T W : Finset ℕ) :
    ∃ C ⊆ W, W.card / (T.card + 1) ≤ C.card ∧
      ∀ x ∈ C, ∀ y ∈ C, ∀ t ∈ T, (x ≤ t ↔ y ≤ t) := by
  obtain ⟨v, hv⟩ := exists_large_cls T W
  refine ⟨cls T W v, cls_subset T W v, hv, ?_⟩
  intro x hx y hy
  exact indistinguishable_of_mem_cls hx hy

/-- Restated as a bound on the achievable speedup: the residual search space
after a `k`-threshold fixed battery is at least `(#W - k) / (k + 1)`. -/
theorem nonadapt_speedup_le (T W : Finset ℕ) :
    ∃ C ⊆ W, W.card - T.card ≤ (T.card + 1) * C.card := by
  obtain ⟨C, hCW, hcard, -⟩ := nonadapt_linear_pricing T W
  refine ⟨C, hCW, ?_⟩
  have h1 : (T.card + 1) * (W.card / (T.card + 1)) ≤ (T.card + 1) * C.card :=
    Nat.mul_le_mul_left _ hcard
  have hmod : (T.card + 1) * (W.card / (T.card + 1)) + W.card % (T.card + 1) = W.card :=
    Nat.div_add_mod W.card (T.card + 1)
  have hlt : W.card % (T.card + 1) ≤ T.card :=
    Nat.lt_succ_iff.1 (Nat.mod_lt _ (Nat.succ_pos T.card))
  calc W.card - T.card ≤ (T.card + 1) * (W.card / (T.card + 1)) := by omega
    _ ≤ (T.card + 1) * C.card := h1

/-! ## Sharpness at `k = 1`: one query has no adaptivity premium -/

/-- With a single threshold at the lower median, both classes have size at most
`⌈w / 2⌉` — exactly what one bisection step achieves.  Hence the adaptivity
premium at `k = 1` is exactly `1`: there is nothing to condition on yet. -/
theorem battery_sharp_uniform (lo hi : ℕ) (h : lo < hi) (v : ℕ) :
    (cls {lo + (hi - lo - 1) / 2} (Ico lo hi) v).card ≤ (hi - lo + 1) / 2 := by
  set m := lo + (hi - lo - 1) / 2 with hm
  have hml : lo ≤ m := Nat.le_add_right _ _
  have hdiv : (hi - lo - 1) / 2 ≤ hi - lo - 1 := Nat.div_le_self _ _
  have hmh : m < hi := by omega
  by_cases hv : v = 0
  · have hsub : cls {m} (Ico lo hi) v ⊆ Ico (m + 1) hi := by
      intro x hx
      rw [cls, mem_filter, mem_Ico] at hx
      obtain ⟨⟨hx1, hx2⟩, hx3⟩ := hx
      rw [mem_Ico]
      refine ⟨?_, hx2⟩
      by_contra hcon
      have hxm : x ≤ m := by omega
      have hs1 : sig {m} x = 1 := by
        rw [sig, Finset.filter_singleton, if_pos hxm, Finset.card_singleton]
      omega
    calc (cls {m} (Ico lo hi) v).card ≤ (Ico (m + 1) hi).card := card_le_card hsub
      _ = hi - (m + 1) := Nat.card_Ico _ _
      _ ≤ (hi - lo + 1) / 2 := by omega
  · have hsub : cls {m} (Ico lo hi) v ⊆ Ico lo (m + 1) := by
      intro x hx
      rw [cls, mem_filter, mem_Ico] at hx
      obtain ⟨⟨hx1, hx2⟩, hx3⟩ := hx
      rw [mem_Ico]
      refine ⟨hx1, ?_⟩
      by_contra hcon
      have hxm : ¬ x ≤ m := by omega
      have hs0 : sig {m} x = 0 := by
        rw [sig, Finset.filter_singleton, if_neg hxm, Finset.card_empty]
      omega
    calc (cls {m} (Ico lo hi) v).card ≤ (Ico lo (m + 1)).card := card_le_card hsub
      _ = m + 1 - lo := Nat.card_Ico _ _
      _ ≤ (hi - lo + 1) / 2 := by omega

/-! ## The balanced-stratum zero-bit collapse -/

/-- **Zero-bit collapse.**  If no threshold of the battery falls strictly inside
the support window `[lo, hi)` — every `t` is either below the window or at/above
its top element — then all candidates in the support give the *same* answers.
The battery carries zero bits and buys a speedup of exactly `1`. -/
theorem zero_bit_collapse (T : Finset ℕ) (lo hi : ℕ)
    (h : ∀ t ∈ T, t < lo ∨ hi ≤ t + 1) :
    ∀ x ∈ Ico lo hi, ∀ y ∈ Ico lo hi, ∀ t ∈ T, (x ≤ t ↔ y ≤ t) := by
  intro x hx y hy t ht
  rw [mem_Ico] at hx hy
  rcases h t ht with hlt | hge
  · constructor
    · intro _; omega
    · intro _; omega
  · constructor
    · intro _; omega
    · intro _; omega

/-- The collapse, stated as: the whole support is a single indistinguishability
class, i.e. the residual search space is the full support (speedup `= 1`). -/
theorem zero_bit_collapse_class (T : Finset ℕ) (lo hi : ℕ) (hlo : lo < hi)
    (h : ∀ t ∈ T, t < lo ∨ hi ≤ t + 1) :
    cls T (Ico lo hi) (sig T lo) = Ico lo hi := by
  apply Subset.antisymm (cls_subset _ _ _)
  intro x hx
  rw [cls, mem_filter]
  refine ⟨hx, ?_⟩
  have hlomem : lo ∈ Ico lo hi := mem_Ico.2 ⟨le_rfl, hlo⟩
  have hans := zero_bit_collapse T lo hi h x hx lo hlomem
  unfold sig
  congr 1
  apply filter_congr
  intro t ht
  exact hans t ht

/-! ### A machine-checked balanced instance at bit length 40

`N ≈ 2 ^ 40` balanced with `ρ = q / p ≤ 1.01` pins `p = min (p, q)` into the
window `[720000, 723600)` (relative width `0.5 %`) inside the full search window
`[2, 2 ^ 20)`.  The uniform `24`-threshold battery `t_i = i * 2 ^ 20 / 25`,
`i = 1, …, 24`, misses that window entirely, so it carries zero bits. -/

/-- The uniform battery of `k` thresholds spread over `[0, B)`. -/
def uniformBattery (B k : ℕ) : Finset ℕ := (Icc 1 k).image (fun i => i * B / (k + 1))

/-- The `24`-threshold uniform battery over the bit-length-40 balanced window
carries **literally zero bits**: all `3600` candidates of the support window
answer every one of the `24` queries identically. -/
theorem uniform_battery_zero_bits_balanced :
    ∀ x ∈ Ico 720000 723600, ∀ y ∈ Ico 720000 723600,
      ∀ t ∈ uniformBattery 1048576 24, (x ≤ t ↔ y ≤ t) := by
  apply zero_bit_collapse
  decide

/-- Consequently the residual uncertainty after the whole `24`-query fixed
battery is the *entire* support: speedup exactly `1.00`. -/
theorem uniform_battery_residual_full :
    cls (uniformBattery 1048576 24) (Ico 720000 723600)
        (sig (uniformBattery 1048576 24) 720000) = Ico 720000 723600 := by
  apply zero_bit_collapse_class _ _ _ (by norm_num)
  decide

end Pythagorean.SeqHint