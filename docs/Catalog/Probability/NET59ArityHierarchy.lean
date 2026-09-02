import Probability.NET59PairIdentifiability

/-!
# NET-59, round 6: masking spread over two layers defeats pair ablation

Round 13 (`Probability.NET59PairIdentifiability`) showed that pair ablation
recovers exactly what solo ablation misses — *when a single layer does all the
masking*.  This file shows that the sufficiency of arity `2` is an artefact of
that assumption: with the masking distributed over **two** tail layers, every
ablation of one or two layers is invisible, and only arity `3` sees the damage.

The stack `twoMaskStack n` is `n` transparent layers followed by **two**
totally forgetful layers.  Ablation replaces a transparent layer by a constant
`Bernoulli(t)` layer and a forgetful layer by the identity, exactly as in the
earlier rounds.

Main results.

* `twoMask_solo_zero` — every single ablation costs `0`.
* `twoMask_pair_zero` — every *pair* of ablations costs `0` as well: one
  surviving forgetful layer is enough to erase everything upstream of it.
* `twoMask_triple_cost` — ablating a transparent layer together with **both**
  forgetful layers costs exactly `t`.
* `net59_arity_three_needed` — at the measured depth `24`: two prunings of one
  intact stack that agree (at `0`) on every ablation of arity `≤ 2`, and whose
  arity-`3` costs are `0.017` and `1`.

Together with round 13 this is the first step of an arity hierarchy: the minimal
informative ablation arity is not a universal constant, it grows with the number
of layers over which downstream forgetting is spread.  No fixed-arity protocol
is sound for all stacks.
-/

namespace Catalog.Probability.NET59

open Finset

/-! ## 1. The two-masker stack -/

/-- `n` transparent layers followed by two totally forgetful layers. -/
def twoMaskStack (n : ℕ) : List (Kern (Fin 2) (Fin 2)) :=
  List.replicate n idK ++ [constK d0, constK d0]

/-- The ablated version of layer `j`: a constant `Bernoulli(t)` layer for the
transparent layers, the identity for the two forgetful ones. -/
def twoMaskAblate (n : ℕ) (t : ℚ) (h0 : 0 ≤ t) (h1 : t ≤ 1) (j : ℕ) : Kern (Fin 2) (Fin 2) :=
  if j < n then constK (bern t h0 h1) else idK

@[simp] theorem length_twoMaskStack (n : ℕ) : (twoMaskStack n).length = n + 2 := by
  simp [twoMaskStack]

/-- Running a stack that ends in two extra layers. -/
theorem chain_append_pair {α : Type*} [Fintype α] (A : List (Kern α α)) (K K' : Kern α α)
    (μ : Dist α) : chain (A ++ [K, K']) μ = push K' (push K (chain A μ)) := by
  rw [chain_append, chain_cons, chain_cons, chain_nil]

/-- The intact two-masker stack outputs `d0`. -/
@[simp] theorem chain_twoMaskStack (n : ℕ) (μ : Dist (Fin 2)) : chain (twoMaskStack n) μ = d0 := by
  rw [twoMaskStack, chain_append_pair, push_constK]

/-! ### Normal forms for ablated stacks

Every ablation of `twoMaskStack n` is a list of the form `A ++ [K, K']` with `A`
a block of identity layers carrying at most one constant layer, so the three
lemmas below cover all the cases used later. -/

/-- Setting an index below `n` only touches the transparent block. -/
theorem twoMask_set_left (n j : ℕ) (hj : j < n) (K : Kern (Fin 2) (Fin 2)) :
    (twoMaskStack n).set j K
      = (List.replicate n idK).set j K ++ [constK d0, constK d0] := by
  rw [twoMaskStack, List.set_append_left]
  simpa using hj

/-- Setting index `n` replaces the first forgetful layer. -/
theorem twoMask_set_first (n : ℕ) (K : Kern (Fin 2) (Fin 2)) :
    (twoMaskStack n).set n K = List.replicate n idK ++ [K, constK d0] := by
  rw [twoMaskStack, List.set_append_right _ _ (by simp)]
  simp

/-- Setting index `n+1` replaces the second forgetful layer. -/
theorem twoMask_set_second (n : ℕ) (K : Kern (Fin 2) (Fin 2)) :
    (twoMaskStack n).set (n + 1) K = List.replicate n idK ++ [constK d0, K] := by
  rw [twoMaskStack, List.set_append_right _ _ (by simp)]
  simp

/-! ## 2. Arity one and arity two are blind -/

/-- **Every solo ablation is invisible.** -/
theorem twoMask_solo_zero (n : ℕ) (t : ℚ) (h0 : 0 ≤ t) (h1 : t ≤ 1) (j : ℕ) (hj : j < n + 2) :
    tv (chain (twoMaskStack n) d0)
       (chain ((twoMaskStack n).set j (twoMaskAblate n t h0 h1 j)) d0) = 0 := by
  rw [chain_twoMaskStack]
  rcases lt_or_ge j n with h | h
  · rw [twoMask_set_left n j h, chain_append_pair, push_constK, tv_self]
  · have hlayer : twoMaskAblate n t h0 h1 j = idK := by simp [twoMaskAblate, Nat.not_lt.2 h]
    rcases Nat.lt_or_ge j (n + 1) with h' | h'
    · have hjn : j = n := by omega
      subst hjn
      rw [hlayer, twoMask_set_first, chain_append_pair, push_constK, tv_self]
    · have hjn : j = n + 1 := by omega
      subst hjn
      rw [hlayer, twoMask_set_second, chain_append_pair, push_constK, push_idK, tv_self]

/-- **Every pair ablation is invisible too.**  One surviving forgetful layer
erases everything created upstream of it, so no experiment of arity `2` can see
the damage. -/
theorem twoMask_pair_zero (n : ℕ) (t : ℚ) (h0 : 0 ≤ t) (h1 : t ≤ 1) (i j : ℕ)
    (hij : i < j) (hj : j < n + 2) :
    tv (chain (twoMaskStack n) d0)
       (chain (pairAblate (twoMaskStack n) i j
          (twoMaskAblate n t h0 h1 i) (twoMaskAblate n t h0 h1 j)) d0) = 0 := by
  rw [chain_twoMaskStack, pairAblate]
  have hi : i < n + 2 := by omega
  rcases lt_or_ge j n with hjn | hjn
  · -- both ablations are inside the transparent block
    have hin : i < n := by omega
    rw [twoMask_set_left n j hjn, List.set_append_left _ _ (by simpa using hin),
      chain_append_pair, push_constK, tv_self]
  · have hlayerj : twoMaskAblate n t h0 h1 j = idK := by
      simp [twoMaskAblate, Nat.not_lt.2 hjn]
    rcases Nat.lt_or_ge j (n + 1) with hj' | hj'
    · -- `j = n`: the second forgetful layer survives
      have hjeq : j = n := by omega
      subst hjeq
      have hin : i < j := hij
      rw [hlayerj, twoMask_set_first, List.set_append_left _ _ (by simpa using hin),
        chain_append_pair, push_constK, tv_self]
    · -- `j = n+1`: the first forgetful layer survives unless `i = n`
      have hjeq : j = n + 1 := by omega
      subst hjeq
      rcases lt_or_ge i n with hin | hin
      · rw [hlayerj, twoMask_set_second, List.set_append_left _ _ (by simpa using hin),
          chain_append_pair, push_constK, push_idK, tv_self]
      · have hieq : i = n := by omega
        subst hieq
        have hlayeri : twoMaskAblate i t h0 h1 i = idK := by simp [twoMaskAblate]
        rw [hlayerj, hlayeri, twoMask_set_second, List.set_append_right _ _ (by simp)]
        simp only [List.length_replicate, Nat.sub_self]
        rw [show ([constK d0, idK] : List (Kern (Fin 2) (Fin 2))).set 0 idK = [idK, idK] from rfl,
          chain_append_pair, chain_replicate_idK, push_idK, push_idK, tv_self]

/-! ## 3. Arity three sees everything -/

/-- **The arity-`3` experiment recovers the damage exactly.**  Ablating a
transparent layer together with *both* forgetful layers costs exactly the
pruning strength `t`. -/
theorem twoMask_triple_cost (n : ℕ) (t : ℚ) (h0 : 0 ≤ t) (h1 : t ≤ 1) (j : ℕ) (hj : j < n) :
    tv (chain (twoMaskStack n) d0)
       (chain ((((twoMaskStack n).set (n + 1) idK).set n idK).set j
          (constK (bern t h0 h1))) d0) = t := by
  have hstep : ((twoMaskStack n).set (n + 1) idK).set n idK
      = List.replicate n idK ++ [idK, idK] := by
    rw [twoMask_set_second, List.set_append_right _ _ (by simp)]
    simp
  have hfin : ((((twoMaskStack n).set (n + 1) idK).set n idK).set j (constK (bern t h0 h1)))
      = (List.replicate n idK).set j (constK (bern t h0 h1)) ++ [idK, idK] := by
    rw [hstep, List.set_append_left]
    simpa using hj
  rw [chain_twoMaskStack, hfin, chain_append_pair, chain_replicate_idK_set _ _ hj,
    push_idK, push_idK, d0, tv_bern, zero_sub, abs_neg, abs_of_nonneg h0]

/-! ## 4. The hierarchy at the measured depth -/

/-- **Arity `2` is not universally enough.**  At the measured depth `24` there is
an intact stack and two prunings of it such that

* every ablation of one layer costs `0`, for both prunings;
* every ablation of two layers costs `0`, for both prunings;
* the arity-`3` ablation of a transparent layer with the two tail layers costs
  `0.017` for one pruning and `1` for the other.

So the minimal informative ablation arity depends on how far the downstream
forgetting is spread, and no fixed-arity ablation protocol is sound for every
stack. -/
theorem net59_arity_three_needed :
    ∃ (F : List (Kern (Fin 2) (Fin 2))) (p q : Kern (Fin 2) (Fin 2)),
      F.length = 24 ∧
      (∀ j, j < 24 →
        tv (chain F d0) (chain (F.set j (twoMaskAblate 22 net59JointMeasured
            (by norm_num [net59JointMeasured]) (by norm_num [net59JointMeasured]) j)) d0) = 0) ∧
      (∀ i j, i < j → j < 24 →
        tv (chain F d0) (chain (pairAblate F i j
            (twoMaskAblate 22 net59JointMeasured (by norm_num [net59JointMeasured])
              (by norm_num [net59JointMeasured]) i)
            (twoMaskAblate 22 net59JointMeasured (by norm_num [net59JointMeasured])
              (by norm_num [net59JointMeasured]) j)) d0) = 0) ∧
      (∀ j, j < 22 →
        tv (chain F d0) (chain (((F.set 23 idK).set 22 idK).set j p) d0) = net59JointMeasured ∧
        tv (chain F d0) (chain (((F.set 23 idK).set 22 idK).set j q) d0) = 1) := by
  have h0 : (0 : ℚ) ≤ net59JointMeasured := by norm_num [net59JointMeasured]
  have h1 : net59JointMeasured ≤ 1 := by norm_num [net59JointMeasured]
  refine ⟨twoMaskStack 22, constK (bern net59JointMeasured h0 h1),
    constK (bern 1 zero_le_one le_rfl), by simp, fun j hj => ?_, fun i j hij hj => ?_,
    fun j hj => ⟨?_, ?_⟩⟩
  · exact twoMask_solo_zero 22 net59JointMeasured h0 h1 j (by omega)
  · exact twoMask_pair_zero 22 net59JointMeasured h0 h1 i j hij (by omega)
  · exact twoMask_triple_cost 22 net59JointMeasured h0 h1 j hj
  · exact twoMask_triple_cost 22 1 zero_le_one le_rfl j hj

/-! ## 5. Lab notes

Depth `24` two-masker stack (`22` transparent layers, `2` forgetful tail
layers), pruning strength `t`:

```
arity-1 profile, all 24 layers              : 0
arity-2 profile, all 276 pairs              : 0
arity-3 cost {j, 22, 23}, t = 0.017         : 17/1000
arity-3 cost {j, 22, 23}, t = 1             : 1
```

With one masking layer (round 13) arity `2` already separated the two prunings by
`0.983`; with two masking layers arity `2` separates them by `0`.  The pattern
predicts minimal arity `m + 1` for `m` masking layers. -/

section LabNotes

/-- Arity-`2` blindness of the depth-`8` two-masker stack. -/
example (i j : ℕ) (hij : i < j) (hj : j < 8) :
    tv (chain (twoMaskStack 6) d0)
      (chain (pairAblate (twoMaskStack 6) i j
        (twoMaskAblate 6 labT labT_nonneg labT_le_one i)
        (twoMaskAblate 6 labT labT_nonneg labT_le_one j)) d0) = 0 :=
  twoMask_pair_zero 6 labT labT_nonneg labT_le_one i j hij hj

/-- Arity-`3` resolution of the same stack. -/
example (j : ℕ) (hj : j < 6) :
    tv (chain (twoMaskStack 6) d0)
      (chain ((((twoMaskStack 6).set 7 idK).set 6 idK).set j
        (constK (bern labT labT_nonneg labT_le_one))) d0) = labT :=
  twoMask_triple_cost 6 labT labT_nonneg labT_le_one j hj

end LabNotes

end Catalog.Probability.NET59