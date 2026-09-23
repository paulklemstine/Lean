/-
# Structural theory of Shtarkov sums

Third research cycle.  Having computed the finite-state Shtarkov sum from above
(`shtarkovSum_fsmClass_le`) and below (`shtarkovSum_counter_eq`), we isolate the
structural laws that the invariant obeys.

* `shtarkovSum_eq_of_attained` — when the tropical envelope is attained, the
  Shtarkov sum is the total mass of the maximum-likelihood plug-in;
* `shtarkovSum_prodClass` — **tensorisation**: the Shtarkov sum is
  multiplicative under independent composition of classes, so minimax regret is
  additive.  (Tropically: the envelope of a product is the max-plus product of
  the envelopes.)
* `shtarkovSum_le_of_simulates` — **functoriality**: a state-refinement of
  machines can only increase the Shtarkov sum, so regret is monotone along the
  simulation preorder of automata;
* `card_le_of_memorises` and `exists_not_memorisable` — **a pigeonhole for
  automata**: a `k`-state machine can memorise at most `((n+1)^2)^k` words of
  length `n`, hence, as soon as `((n+1)^2)^k < 2^n`, some word of length `n` is
  not memorisable by *any* parameterisation of the machine.
-/

import Catalog.Tropical.Shtarkov.FiniteState

open Finset

namespace TropicalShtarkov

/-! ## Attained envelopes -/

section Attained

variable {X ι : Type*} [Fintype X] [Nonempty ι]

/-- If the pointwise supremum is attained at `f x`, the Shtarkov sum is the total
mass of the plug-in. -/
theorem shtarkovSum_eq_of_attained (P : ι → X → ℝ) (f : X → ι)
    (hbd : ∀ i x, P i x ≤ 1) (hatt : ∀ i x, P i x ≤ P (f x) x) :
    shtarkovSum P = ∑ x : X, P (f x) x := by
  refine Finset.sum_congr rfl fun x _ => ?_
  exact le_antisymm (ciSup_le fun i => hatt i x)
    (le_ciSup (bddAbove_of_le_one hbd x) (f x))

end Attained

/-! ## Tensorisation -/

section Tensor

variable {X Y ι κ : Type*} [Fintype X] [Fintype Y] [Nonempty ι] [Nonempty κ]

/-- The independent product of two model classes. -/
def prodClass (P : ι → X → ℝ) (Q : κ → Y → ℝ) : ι × κ → X × Y → ℝ :=
  fun ij xy => P ij.1 xy.1 * Q ij.2 xy.2

/-- **Tensorisation of the Shtarkov sum.**  For classes whose tropical envelope
is attained, the Shtarkov sum of the independent product is the product of the
Shtarkov sums; equivalently, minimax regret is additive over independent
components. -/
theorem shtarkovSum_prodClass (P : ι → X → ℝ) (Q : κ → Y → ℝ)
    (fP : X → ι) (fQ : Y → κ)
    (hP0 : ∀ i x, 0 ≤ P i x) (hP1 : ∀ i x, P i x ≤ 1) (hPa : ∀ i x, P i x ≤ P (fP x) x)
    (hQ0 : ∀ j y, 0 ≤ Q j y) (hQ1 : ∀ j y, Q j y ≤ 1) (hQa : ∀ j y, Q j y ≤ Q (fQ y) y) :
    shtarkovSum (prodClass P Q) = shtarkovSum P * shtarkovSum Q := by
  have hbd : ∀ (ij : ι × κ) (xy : X × Y), prodClass P Q ij xy ≤ 1 := by
    intro ij xy
    have h1 := hP1 ij.1 xy.1
    have h2 := hQ1 ij.2 xy.2
    have h3 := hP0 ij.1 xy.1
    have h4 := hQ0 ij.2 xy.2
    calc P ij.1 xy.1 * Q ij.2 xy.2 ≤ 1 * 1 := by nlinarith
      _ = 1 := by ring
  have hatt : ∀ (ij : ι × κ) (xy : X × Y),
      prodClass P Q ij xy ≤ prodClass P Q (fP xy.1, fQ xy.2) xy := by
    intro ij xy
    exact mul_le_mul (hPa ij.1 xy.1) (hQa ij.2 xy.2) (hQ0 _ _) (hP0 _ _)
  rw [shtarkovSum_eq_of_attained (prodClass P Q) (fun xy => (fP xy.1, fQ xy.2)) hbd hatt,
    shtarkovSum_eq_of_attained P fP hP1 hPa, shtarkovSum_eq_of_attained Q fQ hQ1 hQa,
    Fintype.sum_prod_type, Finset.sum_mul_sum]
  rfl

end Tensor

/-! ## Functoriality along simulations -/

variable {k k' : ℕ}

/-- A state map exhibiting `M'` as a refinement of `M`: it intertwines initial
states and transitions. -/
structure Simulates (M' : FSM k') (M : FSM k) where
  /-- The state collapsing map. -/
  toFun : Fin k' → Fin k
  /-- Initial states correspond. -/
  map_init : toFun M'.init = M.init
  /-- Transitions correspond. -/
  map_step : ∀ s b, toFun (M'.step s b) = M.step (toFun s) b

theorem Simulates.state_eq {M' : FSM k'} {M : FSM k} (h : Simulates M' M)
    (u : ℕ → Bool) (i : ℕ) :
    h.toFun (stAux M' M'.init u i) = stAux M M.init u i := by
  induction i with
  | zero => exact h.map_init
  | succ i ih =>
      show h.toFun (M'.step (stAux M' M'.init u i) (u i)) = _
      rw [h.map_step, ih]
      rfl

/-- A refinement realises every source of the coarser machine. -/
theorem Simulates.prob_eq {M' : FSM k'} {M : FSM k} (h : Simulates M' M)
    (θ : Fin k → ℝ) (n : ℕ) (x : Word n) :
    prob M θ n x = prob M' (fun s => θ (h.toFun s)) n x := by
  unfold prob probFrom
  refine Finset.prod_congr rfl fun i _ => ?_
  rw [← h.state_eq (pad x) i]
  rfl

/-- **Monotonicity along simulations.**  Refining the state space can only
increase the Shtarkov sum: minimax regret is monotone in the automaton. -/
theorem shtarkovSum_le_of_simulates {M' : FSM k'} {M : FSM k} (h : Simulates M' M) (n : ℕ) :
    shtarkovSum (fsmClass M n) ≤ shtarkovSum (fsmClass M' n) := by
  refine Finset.sum_le_sum fun x _ => ?_
  refine ciSup_le fun θ => ?_
  have hmem : ∀ s, 0 ≤ θ.1 (h.toFun s) ∧ θ.1 (h.toFun s) ≤ 1 := fun s => θ.2 (h.toFun s)
  have hval : fsmClass M n θ x
      = fsmClass M' n ⟨fun s => θ.1 (h.toFun s), hmem⟩ x := h.prob_eq θ.1 n x
  rw [hval]
  exact le_ciSup (bddAbove_of_le_one (fsmClass_le_one M' n) x) _

/-! ## A pigeonhole for automata -/

/-- **Memorisation capacity.**  A `k`-state machine can give probability `1` to
at most `((n+1)^2)^k` words of length `n`. -/
theorem card_le_of_memorises (M : FSM k) (n : ℕ) (A : Finset (Word n)) (f : Word n → Params k)
    (hf : ∀ x ∈ A, 1 ≤ fsmClass M n (f x) x) :
    (A.card : ℝ) ≤ (((n : ℝ) + 1) * ((n : ℝ) + 1)) ^ k := by
  have hpack := shtarkovSum_ge_packing (fsmClass M n) (fsmClass_nonneg M n)
    (fsmClass_le_one M n) A f
  have hcard : (A.card : ℝ) ≤ ∑ a ∈ A, fsmClass M n (f a) a := by
    calc (A.card : ℝ) = ∑ _a ∈ A, (1:ℝ) := by simp
      _ ≤ ∑ a ∈ A, fsmClass M n (f a) a := Finset.sum_le_sum hf
  exact hcard.trans (hpack.trans (shtarkovSum_fsmClass_le M n))

/-- **Automata cannot memorise.**  If the counting bound beats the number of
words, some word of length `n` is assigned probability `< 1` by *every*
parameterisation of the machine. -/
theorem exists_not_memorisable (M : FSM k) (n : ℕ)
    (h : (((n : ℝ) + 1) * ((n : ℝ) + 1)) ^ k < 2 ^ n) :
    ∃ x : Word n, ∀ θ : Params k, fsmClass M n θ x < 1 := by
  by_contra hc
  push_neg at hc
  choose f hf using hc
  have hbound := card_le_of_memorises M n univ f (fun x _ => hf x)
  have hcard : ((univ : Finset (Word n)).card : ℝ) = 2 ^ n := by simp
  rw [hcard] at hbound
  linarith

/-- Concretely: a single-state (memoryless) machine cannot memorise all words of
length `n` once `n ≥ 6`. -/
theorem memoryless_not_memorisable (M : FSM 1) (n : ℕ) (hn : 6 ≤ n) :
    ∃ x : Word n, ∀ θ : Params 1, fsmClass M n θ x < 1 := by
  refine exists_not_memorisable M n ?_
  have hnat : (n + 1) * (n + 1) < 2 ^ n := by
    induction n with
    | zero => omega
    | succ m ih =>
        rcases Nat.lt_or_ge m 6 with hm | hm
        · interval_cases m <;> simp_all
        · have := ih (by omega)
          have h2 : 2 ^ (m + 1) = 2 * 2 ^ m := by ring
          have hm2 : m + 2 ≤ 2 * (m + 1) := by omega
          nlinarith [this]
  have : ((n : ℝ) + 1) * ((n : ℝ) + 1) < 2 ^ n := by exact_mod_cast hnat
  simpa using this

end TropicalShtarkov