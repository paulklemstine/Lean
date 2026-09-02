import Probability.NET59HybridEpistasis

/-!
# NET-59: the solo profile identifies nothing

NET-59 measured, for each of the `24` layers of a transformer, the damage caused
by pruning **that layer alone**, and found the profile flat: every layer within
`0.6` points, the tail layer `L23` the *best* one in the stack.  The reported
verdict was `NO-SINGLE-LAYER-IS-THE-BOTTLENECK`, and two structural hypotheses
(`TAIL-IS-CRITICAL`, `NON-UNIFORM-MAP`) were declared refuted.

This file shows, inside the exact probabilistic model of
`Probability.NET59TVCore`, that **a flat solo profile carries no information
whatsoever about joint pruning damage** — in either direction.

* `soloCost_eq_zero` : for every depth `n+1`, every target `t ∈ [0,1]` and every
  layer `j`, the explicit stack `fullStack n` / `prunedStack n t` has solo cost
  exactly `0` at layer `j`.  The profile is *perfectly* flat, flatter than the
  measured one.
* `jointCost_eq_target` : the joint cost of the very same stack is exactly `t`.
* `pointCost_eq_target` : the *point* cost of each non-final layer is exactly
  `t`, so the true per-layer damage profile is flat at `t`, not at `0`;
  `solo_le_point` of the previous file is saturated in the worst possible way.
* `net59_nonidentifiability` : two depth-`24` stacks with **identical** solo
  profiles (identically zero) whose joint costs are the measured `0.017` and the
  catastrophic `1`.  No inference from the solo profile to the joint cost is
  valid.
* `cancellation_joint_zero` and `no_two_sided_solo_law` : the failure is
  two-sided.  A depth-`2` stack whose two solo costs are both `1` can have joint
  cost `0`.  So joint damage is neither bounded below by the largest solo cost
  nor above by their sum.

Together with `chain_tv_le_depth_mul` this isolates exactly what a per-layer
budget must be for depth-additivity to hold: a bound on the layer perturbation
that is *uniform over upstream states*.  Solo ablation measures the perturbation
at one single state, and `soloCost_eq_zero` shows that measurement can be
arbitrarily far from uniform.
-/

namespace Catalog.Probability.NET59

open Finset

/-! ## 1. The two-state alphabet -/

/-- The Bernoulli law `(1-t, t)` on `Fin 2`. -/
def bern (t : ℚ) (h0 : 0 ≤ t) (h1 : t ≤ 1) : Dist (Fin 2) where
  p i := if i = 0 then 1 - t else t
  nonneg i := by split <;> linarith
  sum_one := by simp [Fin.sum_univ_two]

/-- The point mass at `0`. -/
def d0 : Dist (Fin 2) := bern 0 le_rfl zero_le_one

/-- The point mass at `1`. -/
def d1 : Dist (Fin 2) := bern 1 zero_le_one le_rfl

theorem tv_bern (s t : ℚ) (hs0 hs1 ht0 ht1) :
    tv (bern s hs0 hs1) (bern t ht0 ht1) = |s - t| := by
  have hne : ((1 : Fin 2) = 0) = False := by simp
  simp only [tv, bern, Fin.sum_univ_two, if_true, hne, if_false]
  rw [show (1 : ℚ) - s - (1 - t) = -(s - t) by ring, abs_neg]
  ring

@[simp] theorem tv_d0_d1 : tv d0 d1 = 1 := by
  rw [d0, d1, tv_bern]; norm_num

/-- The flip channel `0 ↦ 1`, `1 ↦ 0`. -/
def flipK : Kern (Fin 2) (Fin 2) := fun a => dirac (if a = 0 then 1 else 0)

instance : Inhabited (Kern (Fin 2) (Fin 2)) := ⟨idK⟩

theorem push_flipK (t : ℚ) (h0 : 0 ≤ t) (h1 : t ≤ 1) :
    push flipK (bern t h0 h1) = bern (1 - t) (by linarith) (by linarith) := by
  refine Dist.ext' fun b => ?_
  fin_cases b <;>
    simp [push, flipK, bern, dirac, Fin.sum_univ_two]

/-! ## 2. The witness family

`fullStack n` is a stack of `n` transparent layers followed by one totally
forgetful layer.  `prunedStack n t` prunes each transparent layer into a
constant `Bernoulli(t)` layer and prunes the forgetful layer into a transparent
one.  Every solo ablation is invisible, the joint ablation costs exactly `t`. -/

/-- The intact stack: `n` identity layers, then a layer that outputs `d0`. -/
def fullStack (n : ℕ) : List (Kern (Fin 2) (Fin 2)) :=
  List.replicate n idK ++ [constK d0]

/-- The pruned stack: `n` constant `Bernoulli(t)` layers, then an identity. -/
def prunedStack (n : ℕ) (t : ℚ) (h0 : 0 ≤ t) (h1 : t ≤ 1) : List (Kern (Fin 2) (Fin 2)) :=
  List.replicate n (constK (bern t h0 h1)) ++ [idK]

/-- The pruned version of layer `j`. -/
def prunedLayer (n : ℕ) (t : ℚ) (h0 : 0 ≤ t) (h1 : t ≤ 1) (j : ℕ) : Kern (Fin 2) (Fin 2) :=
  if j < n then constK (bern t h0 h1) else idK

@[simp] theorem length_fullStack (n : ℕ) : (fullStack n).length = n + 1 := by
  simp [fullStack]

@[simp] theorem length_prunedStack (n : ℕ) (t : ℚ) (h0 h1) :
    (prunedStack n t h0 h1).length = n + 1 := by simp [prunedStack]

theorem prunedStack_getElem (n : ℕ) (t : ℚ) (h0 h1) (j : ℕ) (hj : j < n + 1) :
    (prunedStack n t h0 h1)[j]'(by simpa using hj) = prunedLayer n t h0 h1 j := by
  unfold prunedStack prunedLayer
  rcases lt_or_ge j n with h | h
  · rw [List.getElem_append_left (by simpa using h)]
    simp [h]
  · have hjn : j = n := le_antisymm (by omega) h
    subst hjn
    rw [List.getElem_append_right (by simp)]
    simp

/-! ### Chain evaluations -/

theorem chain_replicate_idK (n : ℕ) (μ : Dist (Fin 2)) :
    chain (List.replicate n (idK : Kern (Fin 2) (Fin 2))) μ = μ := by
  induction n generalizing μ with
  | zero => simp
  | succ n ih => rw [List.replicate_succ, chain_cons, push_idK, ih]

theorem chain_snoc_constK {α : Type*} [Fintype α] (L : List (Kern α α)) (c : Dist α)
    (μ : Dist α) : chain (L ++ [constK c]) μ = c := by
  rw [chain_append, chain_cons, chain_nil, push_constK]

theorem chain_replicate_constK {α : Type*} [Fintype α] (n : ℕ) (c : Dist α) (μ : Dist α) :
    chain (List.replicate (n + 1) (constK c)) μ = c := by
  induction n generalizing μ with
  | zero => simp [List.replicate_succ, push_constK]
  | succ n ih => rw [List.replicate_succ, chain_cons, ih]

/-- The intact stack outputs `d0` on every input. -/
@[simp] theorem chain_fullStack (n : ℕ) (μ : Dist (Fin 2)) : chain (fullStack n) μ = d0 :=
  chain_snoc_constK _ _ _

/-- The fully pruned stack outputs `Bernoulli(t)`. -/
theorem chain_prunedStack (n : ℕ) (t : ℚ) (h0 h1) (μ : Dist (Fin 2)) :
    chain (prunedStack (n + 1) t h0 h1) μ = bern t h0 h1 := by
  rw [prunedStack, chain_append, chain_replicate_constK, chain_cons, chain_nil, push_idK]

/-! ## 3. Every solo cost vanishes -/

/-- **The solo profile of the witness family is identically zero.**

For every depth, every pruning strength `t` and every layer `j`, ablating layer
`j` alone leaves the output law of the stack exactly unchanged. -/
theorem soloCost_eq_zero (n : ℕ) (t : ℚ) (h0 : 0 ≤ t) (h1 : t ≤ 1) (j : ℕ) (hj : j < n + 1) :
    tv (chain (fullStack n) d0)
       (chain ((fullStack n).set j (prunedLayer n t h0 h1 j)) d0) = 0 := by
  rcases lt_or_ge j n with h | h
  · -- an early layer: the final forgetful layer erases the damage
    have hset : (fullStack n).set j (prunedLayer n t h0 h1 j)
        = (List.replicate n idK).set j (prunedLayer n t h0 h1 j) ++ [constK d0] := by
      rw [fullStack, List.set_append_left]
      simpa using h
    rw [hset, chain_snoc_constK, chain_fullStack, tv_self]
  · -- the final layer: upstream is intact, and pruning it to the identity
    -- reproduces the input `d0`
    have hjn : j = n := le_antisymm (by omega) h
    subst hjn
    have hlayer : prunedLayer j t h0 h1 j = idK := by simp [prunedLayer]
    have hset : (fullStack j).set j (prunedLayer j t h0 h1 j) = List.replicate j idK ++ [idK] := by
      rw [hlayer, fullStack, List.set_append_right _ _ (by simp)]
      simp
    rw [hset, chain_fullStack, chain_append, chain_replicate_idK, chain_cons, chain_nil,
      push_idK, tv_self]

/-! ## 4. …while the joint cost is whatever you like -/

/-- **The joint cost of the witness family is exactly `t`.** -/
theorem jointCost_eq_target (n : ℕ) (t : ℚ) (h0 : 0 ≤ t) (h1 : t ≤ 1) :
    tv (chain (fullStack (n + 1)) d0) (chain (prunedStack (n + 1) t h0 h1) d0) = t := by
  rw [chain_fullStack, chain_prunedStack, d0, tv_bern]
  rw [zero_sub, abs_neg, abs_of_nonneg h0]

/-- The *point* cost of every transparent layer is exactly `t`: the true
per-layer perturbation profile is flat at `t`, while the measured solo profile
is flat at `0`.  The inequality `solo_le_point` is therefore saturated at its
most misleading extreme. -/
theorem pointCost_eq_target (n : ℕ) (t : ℚ) (h0 : 0 ≤ t) (h1 : t ≤ 1) (j : ℕ) (hj : j < n) :
    tv (push idK (upstream (fullStack n) j d0))
       (push (prunedLayer n t h0 h1 j) (upstream (fullStack n) j d0)) = t := by
  have hup : upstream (fullStack n) j d0 = d0 := by
    unfold upstream fullStack
    rw [List.take_append_of_le_length (by simpa using hj.le), List.take_replicate,
      chain_replicate_idK]
  have hlayer : prunedLayer n t h0 h1 j = constK (bern t h0 h1) := by simp [prunedLayer, hj]
  rw [hup, hlayer, push_idK, push_constK, d0, tv_bern]
  rw [zero_sub, abs_neg, abs_of_nonneg h0]

/-! ## 5. Non-identifiability at the measured depth -/

/-- The joint cost measured in NET-50/NET-59 for all-layer top-`k` pruning:
`1.7%`. -/
def net59JointMeasured : ℚ := 17 / 1000

/-- **Non-identifiability.**  Two stacks of the measured depth `24` whose solo
profiles agree at every one of the `24` layers (both identically `0`, i.e.
flatter than the measured profile) but whose joint costs are `0.017` and `1`.

Hence the NET-59 experiment — however clean — cannot distinguish a stack in
which joint pruning is harmless from one in which it is maximally destructive.
`NO-SINGLE-LAYER-IS-THE-BOTTLENECK` is a statement about the measurement, not
about the network. -/
theorem net59_nonidentifiability :
    ∃ (F P Q : List (Kern (Fin 2) (Fin 2))),
      F.length = 24 ∧ P.length = 24 ∧ Q.length = 24 ∧
      (∀ j, j < 24 → tv (chain F d0) (chain (F.set j (P[j]!)) d0) = 0) ∧
      (∀ j, j < 24 → tv (chain F d0) (chain (F.set j (Q[j]!)) d0) = 0) ∧
      tv (chain F d0) (chain P d0) = net59JointMeasured ∧
      tv (chain F d0) (chain Q d0) = 1 := by
  classical
  have h0 : (0 : ℚ) ≤ net59JointMeasured := by norm_num [net59JointMeasured]
  have h1 : net59JointMeasured ≤ 1 := by norm_num [net59JointMeasured]
  refine ⟨fullStack 23, prunedStack 23 net59JointMeasured h0 h1,
    prunedStack 23 1 zero_le_one le_rfl, by simp, by simp, by simp, ?_, ?_, ?_, ?_⟩
  · intro j hj
    have hget : (prunedStack 23 net59JointMeasured h0 h1)[j]!
        = prunedLayer 23 net59JointMeasured h0 h1 j := by
      rw [List.getElem!_eq_getElem?_getD,
        List.getElem?_eq_getElem (by simpa using hj)]
      simpa using prunedStack_getElem 23 net59JointMeasured h0 h1 j (by omega)
    rw [hget]
    exact soloCost_eq_zero 23 net59JointMeasured h0 h1 j (by omega)
  · intro j hj
    have hget : (prunedStack 23 1 zero_le_one le_rfl)[j]!
        = prunedLayer 23 1 zero_le_one le_rfl j := by
      rw [List.getElem!_eq_getElem?_getD,
        List.getElem?_eq_getElem (by simpa using hj)]
      simpa using prunedStack_getElem 23 1 zero_le_one le_rfl j (by omega)
    rw [hget]
    exact soloCost_eq_zero 23 1 zero_le_one le_rfl j (by omega)
  · exact jointCost_eq_target 22 net59JointMeasured h0 h1
  · exact jointCost_eq_target 22 1 zero_le_one le_rfl

/-- No inequality of the form `joint ≤ Σ solo` can hold: the joint cost can be
maximal while every solo cost vanishes.  The empirically observed
sub-additivity of NET-50/NET-59 is therefore a contingent property of the
measured network, not a law of pruning. -/
theorem no_subadditivity_law :
    ∃ (F P : List (Kern (Fin 2) (Fin 2))),
      F.length = 24 ∧ P.length = 24 ∧
      (∀ j, j < 24 → tv (chain F d0) (chain (F.set j (prunedLayer 23 1 zero_le_one le_rfl j)) d0)
        = 0) ∧
      tv (chain F d0) (chain P d0) = 1 :=
  ⟨fullStack 23, prunedStack 23 1 zero_le_one le_rfl, by simp, by simp,
    fun j hj => soloCost_eq_zero 23 1 zero_le_one le_rfl j (by omega),
    jointCost_eq_target 22 1 zero_le_one le_rfl⟩

/-! ## 6. The other side: solo damage that cancels -/

/-- A depth-two stack of transparent layers, pruned into two flips.  Each solo
ablation is maximally damaging; the joint ablation is invisible. -/
theorem cancellation_joint_zero :
    tv (chain [idK, idK] d0) (chain [flipK, flipK] d0) = 0 ∧
    tv (chain [idK, idK] d0) (chain ([idK, idK].set 0 flipK) d0) = 1 ∧
    tv (chain [idK, idK] d0) (chain ([idK, idK].set 1 flipK) d0) = 1 := by
  have hflip0 : push flipK d0 = d1 := by
    refine Dist.ext' fun b => ?_
    fin_cases b <;> simp [push, flipK, dirac, d0, d1, bern, Fin.sum_univ_two]
  have hflip1 : push flipK d1 = d0 := by
    refine Dist.ext' fun b => ?_
    fin_cases b <;> simp [push, flipK, dirac, d0, d1, bern, Fin.sum_univ_two]
  refine ⟨?_, ?_, ?_⟩
  · simp [chain, hflip0, hflip1]
  · show tv (chain [idK, idK] d0) (chain [flipK, idK] d0) = 1
    simp [chain, hflip0]
  · show tv (chain [idK, idK] d0) (chain [idK, flipK] d0) = 1
    simp [chain, hflip0]

/-- **Two-sided failure of the solo profile.**  There are stacks whose joint
cost strictly exceeds the sum of the solo costs, and stacks whose joint cost is
strictly below the largest solo cost.  The solo profile therefore bounds the
joint cost neither from above nor from below. -/
theorem no_two_sided_solo_law :
    (∃ (F P : List (Kern (Fin 2) (Fin 2))),
        (∀ j, j < F.length → tv (chain F d0) (chain (F.set j (P[j]!)) d0) = 0) ∧
        0 < tv (chain F d0) (chain P d0)) ∧
    (∃ (F P : List (Kern (Fin 2) (Fin 2))),
        (∀ j, j < F.length → tv (chain F d0) (chain (F.set j (P[j]!)) d0) = 1) ∧
        tv (chain F d0) (chain P d0) = 0) := by
  classical
  constructor
  · refine ⟨fullStack 23, prunedStack 23 1 zero_le_one le_rfl, ?_, ?_⟩
    · intro j hj
      have hj' : j < 24 := by simpa using hj
      have hget : (prunedStack 23 1 zero_le_one le_rfl)[j]!
          = prunedLayer 23 1 zero_le_one le_rfl j := by
        rw [List.getElem!_eq_getElem?_getD,
          List.getElem?_eq_getElem (by simpa using hj')]
        simpa using prunedStack_getElem 23 1 zero_le_one le_rfl j (by omega)
      rw [hget]
      exact soloCost_eq_zero 23 1 zero_le_one le_rfl j (by omega)
    · rw [jointCost_eq_target 22 1 zero_le_one le_rfl]; norm_num
  · obtain ⟨hjoint, h0, h1⟩ := cancellation_joint_zero
    refine ⟨[idK, idK], [flipK, flipK], ?_, hjoint⟩
    intro j hj
    have hj' : j < 2 := by simpa using hj
    interval_cases j
    · simpa using h0
    · simpa using h1


/-! ## 7. Lab notes

Exact evaluations of the witness family at depth `11` (the naive evaluator is
exponential in the depth, so the measured depth `24` is checked by the theorems
above rather than by evaluation).  The numbers reproduce, symbolically, the
qualitative shape of the NET-59 table: a perfectly flat solo profile, a nonzero
joint cost, and a per-layer point profile flat at the joint value.

```
solo profile (11 layers, t = 0.017) : [0,0,0,0,0,0,0,0,0,0,0]
joint cost   (t = 0.017)            : 17/1000
joint cost   (t = 1)                : 1
point profile (10 prunable layers)  : [17/1000, ..., 17/1000]
cancellation stack, joint           : 0
cancellation stack, solo 0 and 1    : 1, 1
```
-/

section LabNotes

/-- The measured NET-50/NET-59 joint pruning cost, as a pruning strength. -/
def labT : ℚ := 17 / 1000

theorem labT_nonneg : (0 : ℚ) ≤ labT := by norm_num [labT]

theorem labT_le_one : labT ≤ 1 := by norm_num [labT]

/-- Solo profile of the depth-`11` witness: identically zero. -/
example : (List.range 11).map (fun j =>
    tv (chain (fullStack 10) d0)
      (chain ((fullStack 10).set j (prunedLayer 10 labT labT_nonneg labT_le_one j)) d0))
    = List.replicate 11 0 := by
  refine List.ext_getElem (by simp) fun j h1 h2 => ?_
  simp only [List.getElem_map, List.getElem_range, List.getElem_replicate]
  exact soloCost_eq_zero 10 labT labT_nonneg labT_le_one j (by simpa using h1)

/-- Joint cost of the depth-`11` witness: exactly the measured `0.017`. -/
example : tv (chain (fullStack 10) d0) (chain (prunedStack 10 labT labT_nonneg labT_le_one) d0)
    = labT := jointCost_eq_target 9 labT labT_nonneg labT_le_one

/-- Point profile of the depth-`11` witness: flat at `0.017`, not at `0`. -/
example (j : ℕ) (hj : j < 10) :
    tv (push idK (upstream (fullStack 10) j d0))
      (push (prunedLayer 10 labT labT_nonneg labT_le_one j) (upstream (fullStack 10) j d0))
    = labT := pointCost_eq_target 10 labT labT_nonneg labT_le_one j hj

end LabNotes

end Catalog.Probability.NET59