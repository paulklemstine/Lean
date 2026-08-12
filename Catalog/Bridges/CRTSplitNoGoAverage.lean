import Bridges.CRTSplitNoGoBirthdayTail

/-!
# The CRT-Split No-Go, Part VIII: the average-case birthday barrier

Parts VI and VII count the maps whose orbit prefix is collision-free.  This file converts that
counting law into a statement about the *first closure time itself*, averaged over all maps —
the quantity that actually governs the running time of a rho-type factoring iteration.

For a map `f : α → α` and a seed `a`, `closureTime a f` is the least `T` at which the orbit
prefix `a, f a, …, f^[T] a` collides (it exists by pigeonhole, `not_injPrefix_card`).

**Main results.**

* `closureTime_spec` / `lt_closureTime_of_injPrefix` — `closureTime` is well defined and is a
  genuine first-collision time.
* `average_closureTime_ge` — for every `T` with `T (T+1) ≤ n = card α` the sum of the closure
  times over all `n ^ n` maps is at least `(T + 1) · n ^ n / 2`; equivalently, the *average*
  first closure time is at least `(T + 1)/2`.
* `average_closureTime_ge_sqrt` — taking `T + 1 = ⌊√n⌋` this gives an average first closure
  time of at least `√n / 2`: the birthday barrier holds on average, not merely with probability
  `1/2`.
* `average_closureTime_zmod` — on the reduced state space `ZMod p` of an `N`-explicit iteration
  (Fact 2), the average first closure time is at least `√p / 2`.  Since a factor of `N = p q`
  can be revealed only at a closure (Parts I–IV), a *typical* `N`-explicit iteration needs
  `≳ √p ≈ N^{1/4}/2` steps: exponential in `log N`.
-/

namespace CRTSplitNoGo

open Finset

variable {α : Type*} [Fintype α] [DecidableEq α]

omit [Fintype α] [DecidableEq α] in
/-- Collision-freeness of a prefix is inherited by shorter prefixes. -/
lemma InjPrefix.mono_le {f : α → α} {a : α} {S T : ℕ} (h : InjPrefix f a T) (hST : S ≤ T) :
    InjPrefix f a S := fun i hi j hj hij => h i (by omega) j (by omega) hij

omit [DecidableEq α] in
/-- **Pigeonhole.**  A prefix of length `n + 1` in an `n`-element type always collides. -/
lemma not_injPrefix_card (f : α → α) (a : α) : ¬ InjPrefix f a (Fintype.card α) := by
  intro h
  have hcard : Fintype.card α < Fintype.card (Fin (Fintype.card α + 1)) := by
    simp
  obtain ⟨i, j, hij, hfij⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt (fun i : Fin (Fintype.card α + 1) => orb f a (i : ℕ))
      hcard
  exact hij (Fin.ext (h i (by omega) j (by omega) hfij))

/-- The first time at which the orbit prefix from `a` collides. -/
noncomputable def closureTime (a : α) (f : α → α) : ℕ :=
  sInf {T : ℕ | ¬ InjPrefix f a T}

omit [DecidableEq α] in
lemma closureTime_spec (a : α) (f : α → α) : ¬ InjPrefix f a (closureTime a f) := by
  have : closureTime a f ∈ {T : ℕ | ¬ InjPrefix f a T} :=
    Nat.sInf_mem ⟨Fintype.card α, not_injPrefix_card f a⟩
  simpa [Set.mem_setOf_eq] using this

omit [DecidableEq α] in
/-- A collision-free prefix of length `T + 1` certifies that the closure time exceeds `T`. -/
lemma lt_closureTime_of_injPrefix {a : α} {f : α → α} {T : ℕ} (h : InjPrefix f a T) :
    T < closureTime a f := by
  by_contra hle
  push_neg at hle
  exact closureTime_spec a f (h.mono_le hle)

/-- Every map in the collision-free set at level `T` has closure time at least `T + 1`. -/
lemma closureTime_ge_of_mem {a : α} {T : ℕ} {f : α → α} (hf : f ∈ injPrefixFinset a T) :
    T + 1 ≤ closureTime a f := by
  have : InjPrefix f a T := by simpa [injPrefixFinset] using hf
  exact lt_closureTime_of_injPrefix this

/-- **The average-case birthday barrier.**  For every `T` with `T (T+1) ≤ n = card α`, the total
closure time over all `n ^ n` maps is at least `(T + 1) · n ^ n / 2`; i.e. the average first
closure time of a uniformly random map is at least `(T + 1)/2`. -/
theorem average_closureTime_ge (a : α) (T : ℕ) (hT : T < Fintype.card α)
    (h : T * (T + 1) ≤ Fintype.card α) :
    ((T : ℝ) + 1) * ((Fintype.card α : ℝ) ^ (Fintype.card α) / 2)
      ≤ ∑ f : α → α, (closureTime a f : ℝ) := by
  classical
  set n := Fintype.card α with hn
  have hsubset : injPrefixFinset a T ⊆ (Finset.univ : Finset (α → α)) := Finset.subset_univ _
  have hsum1 : ∑ f ∈ injPrefixFinset a T, ((T : ℝ) + 1)
      ≤ ∑ f ∈ injPrefixFinset a T, (closureTime a f : ℝ) := by
    refine Finset.sum_le_sum (fun f hf => ?_)
    have := closureTime_ge_of_mem hf
    have : ((T + 1 : ℕ) : ℝ) ≤ (closureTime a f : ℝ) := by exact_mod_cast this
    push_cast at this
    linarith
  have hsum2 : ∑ f ∈ injPrefixFinset a T, (closureTime a f : ℝ)
      ≤ ∑ f : α → α, (closureTime a f : ℝ) :=
    Finset.sum_le_sum_of_subset_of_nonneg hsubset (fun f _ _ => by positivity)
  have hconst : ∑ f ∈ injPrefixFinset a T, ((T : ℝ) + 1)
      = ((injPrefixFinset a T).card : ℝ) * ((T : ℝ) + 1) := by
    rw [Finset.sum_const, nsmul_eq_mul]
  have hcard := majority_collision_free a T hT h
  have hT1 : (0 : ℝ) ≤ (T : ℝ) + 1 := by positivity
  calc ((T : ℝ) + 1) * ((n : ℝ) ^ n / 2)
      ≤ ((T : ℝ) + 1) * ((injPrefixFinset a T).card : ℝ) := by
        exact mul_le_mul_of_nonneg_left hcard hT1
    _ = ∑ f ∈ injPrefixFinset a T, ((T : ℝ) + 1) := by rw [hconst]; ring
    _ ≤ ∑ f ∈ injPrefixFinset a T, (closureTime a f : ℝ) := hsum1
    _ ≤ ∑ f : α → α, (closureTime a f : ℝ) := hsum2

/-- **The average first closure time is at least `√n / 2`.**  Specialising
`average_closureTime_ge` to `T + 1 = ⌊√n⌋`. -/
theorem average_closureTime_ge_sqrt (a : α) :
    (Nat.sqrt (Fintype.card α) : ℝ) * ((Fintype.card α : ℝ) ^ (Fintype.card α) / 2)
      ≤ ∑ f : α → α, (closureTime a f : ℝ) := by
  set n := Fintype.card α with hn
  set s := Nat.sqrt n with hs
  have hsle : s * s ≤ n := by
    have := Nat.sqrt_le' n
    rw [← hs] at this
    nlinarith [this]
  have hsn : s ≤ n := Nat.sqrt_le_self n
  rcases Nat.eq_zero_or_pos s with hs0 | hs0
  · have : (Nat.sqrt n : ℝ) = 0 := by rw [← hs, hs0]; norm_num
    rw [this]
    have : (0 : ℝ) ≤ ∑ f : α → α, (closureTime a f : ℝ) :=
      Finset.sum_nonneg (fun f _ => by positivity)
    linarith
  · -- take `T = s - 1`
    have hTlt : s - 1 < n := by omega
    have hTmul : (s - 1) * ((s - 1) + 1) ≤ n := by
      have : (s - 1) + 1 = s := by omega
      rw [this]
      calc (s - 1) * s ≤ s * s := Nat.mul_le_mul_right s (by omega)
        _ ≤ n := hsle
    have := average_closureTime_ge a (s - 1) hTlt hTmul
    have hcast : ((s - 1 : ℕ) : ℝ) + 1 = (s : ℝ) := by
      have : ((s - 1 : ℕ) : ℝ) = (s : ℝ) - 1 := by
        have : (1 : ℕ) ≤ s := hs0
        push_cast [Nat.cast_sub this]
        ring
      rw [this]; ring
    rwa [hcast] at this

/-- **The average-case barrier on the reduced state space.**  For the mod-`p` reduction of an
`N`-explicit iteration the average first cycle closure time over all maps of `ZMod p` is at
least `√p / 2`.  Combined with Parts I–IV (a factor can appear *only* at a closure) this is the
average-case form of the `N^{1/4}` barrier for the generic regime. -/
theorem average_closureTime_zmod (p : ℕ) [NeZero p] :
    (Nat.sqrt p : ℝ) * ((p : ℝ) ^ p / 2)
      ≤ ∑ f : ZMod p → ZMod p, (closureTime (0 : ZMod p) f : ℝ) := by
  have hcard : Fintype.card (ZMod p) = p := ZMod.card p
  have := average_closureTime_ge_sqrt (0 : ZMod p)
  rwa [hcard] at this

end CRTSplitNoGo