import Probability.NET59ArityHierarchy

/-!
# NET-59, round 7: no bounded-arity ablation protocol is sound

Round 13 proved that ablation arity `2` recovers what arity `1` cannot, and
round 15 proved that with the masking spread over *two* tail layers even arity
`2` is blind.  This file proves the general statement: for **every** number `m`
of masking layers, every ablation experiment of arity `≤ m` returns exactly `0`,
while a single experiment of arity `m+1` returns the true per-layer damage.

To handle ablation sets of arbitrary size the stack is presented as a function
`ℕ → Kern` truncated to a window (`stackFrom`), which makes an ablation set a
`Finset ℕ` and an ablation a pointwise modification of the layer function.

Main results.

* `chain_stackFrom_stable` — a block of layers each of which is either the
  identity or the constant channel `c` maps `c` to `c`.
* `chain_stackFrom_of_const` — a stack containing a constant layer `constK c`
  after which every layer is identity-or-`constK c` outputs `c`, whatever the
  input and whatever the layers before it do.  This is the *reset* mechanism
  that hides upstream damage.
* `masker_arity_blind` — with `m` masking layers, **every** ablation set of size
  at most `m` leaves the output law exactly unchanged.  The pigeonhole is the
  whole content: either a masker survives and resets the state, or the ablation
  set is exactly the set of maskers and no transparent layer was touched at all.
* `masker_arity_recovers` — ablating all `m` maskers together with one
  transparent layer (arity `m+1`) returns exactly the pruning strength `t`.
* `net59_arity_hierarchy` — both statements at the measured depth `24`, for any
  split `n + m = 24`.  Since `m` is arbitrary, no fixed-arity ablation protocol
  is sound for all stacks, and `NET59ArityHierarchy` is the case `m = 2`.
-/

namespace Catalog.Probability.NET59

open Finset

/-! ## 1. Stacks presented as layer functions -/

/-- The stack consisting of layers `f s, f (s+1), …, f (s+l-1)`. -/
def stackFrom (f : ℕ → Kern (Fin 2) (Fin 2)) : ℕ → ℕ → List (Kern (Fin 2) (Fin 2))
  | _, 0 => []
  | s, l + 1 => f s :: stackFrom f (s + 1) l

@[simp] theorem stackFrom_zero (f : ℕ → Kern (Fin 2) (Fin 2)) (s : ℕ) :
    stackFrom f s 0 = [] := rfl

@[simp] theorem stackFrom_succ (f : ℕ → Kern (Fin 2) (Fin 2)) (s l : ℕ) :
    stackFrom f s (l + 1) = f s :: stackFrom f (s + 1) l := rfl

/-- **Stability.**  A block of layers, each of which is either the identity or
the constant channel with law `c`, fixes `c`. -/
theorem chain_stackFrom_stable (f : ℕ → Kern (Fin 2) (Fin 2)) (c : Dist (Fin 2)) :
    ∀ (l s : ℕ), (∀ i, s ≤ i → i < s + l → f i = idK ∨ f i = constK c) →
      chain (stackFrom f s l) c = c := by
  intro l
  induction l with
  | zero => intro s _; simp
  | succ l ih =>
      intro s h
      have hs : f s = idK ∨ f s = constK c := h s le_rfl (by omega)
      have hpush : push (f s) c = c := by
        rcases hs with hs | hs <;> rw [hs] <;> simp
      rw [stackFrom_succ, chain_cons, hpush]
      exact ih (s + 1) fun i hi hi' => h i (by omega) (by omega)

/-- **Reset.**  If some layer of the block is the constant channel `constK c`
and every later layer is the identity or `constK c`, the block outputs `c` —
whatever its input and whatever the earlier layers do.  This is exactly how a
forgetful layer hides upstream ablation damage. -/
theorem chain_stackFrom_of_const (f : ℕ → Kern (Fin 2) (Fin 2)) (c : Dist (Fin 2)) :
    ∀ (l s k : ℕ) (μ : Dist (Fin 2)), s ≤ k → k < s + l → f k = constK c →
      (∀ i, k < i → i < s + l → f i = idK ∨ f i = constK c) →
      chain (stackFrom f s l) μ = c := by
  intro l
  induction l with
  | zero => intro s k μ _ hk _ _; omega
  | succ l ih =>
      intro s k μ hsk hk hfk htail
      rcases eq_or_lt_of_le hsk with rfl | hlt
      · rw [stackFrom_succ, chain_cons, hfk, push_constK]
        exact chain_stackFrom_stable f c l (s + 1)
          fun i hi hi' => htail i (by omega) (by omega)
      · rw [stackFrom_succ, chain_cons]
        exact ih (s + 1) k _ (by omega) (by omega) hfk
          fun i hi hi' => htail i hi (by omega)

/-! ## 2. The `m`-masker stack and its ablations -/

/-- The intact layer function: `n` transparent layers, then forgetful layers. -/
def baseLayer (n : ℕ) : ℕ → Kern (Fin 2) (Fin 2) := fun j => if j < n then idK else constK d0

/-- The ablated form of a layer: a transparent layer becomes a constant
`Bernoulli(t)` layer, a forgetful layer becomes transparent. -/
def ablLayer (n : ℕ) (t : ℚ) (h0 : 0 ≤ t) (h1 : t ≤ 1) : ℕ → Kern (Fin 2) (Fin 2) :=
  fun j => if j < n then constK (bern t h0 h1) else idK

/-- The layer function of the stack ablated on the set `S`. -/
def ablStack (n : ℕ) (t : ℚ) (h0 : 0 ≤ t) (h1 : t ≤ 1) (S : Finset ℕ) :
    ℕ → Kern (Fin 2) (Fin 2) :=
  fun j => if j ∈ S then ablLayer n t h0 h1 j else baseLayer n j

/-- The intact stack outputs `d0`. -/
theorem chain_base (n m : ℕ) (hm : 0 < m) (μ : Dist (Fin 2)) :
    chain (stackFrom (baseLayer n) 0 (n + m)) μ = d0 := by
  refine chain_stackFrom_of_const (baseLayer n) d0 (n + m) 0 n μ (Nat.zero_le _) (by omega)
    (by simp [baseLayer]) ?_
  intro i hi _
  right
  simp [baseLayer, Nat.not_lt.2 (by omega : n ≤ i)]

/-! ## 3. Every experiment of arity at most `m` is blind -/

/-- **Blindness below arity `m+1`.**  With `m` forgetful layers at the end of the
stack, *every* ablation of at most `m` layers leaves the output law exactly
unchanged.

Two cases, and the pigeonhole between them is the whole argument: if the
ablation set misses one masker, that masker resets the state and erases all the
damage created upstream; if it hits all `m` maskers then, having size at most
`m`, it can touch no transparent layer at all, and the ablated stack is the
identity. -/
theorem masker_arity_blind (n m : ℕ) (t : ℚ) (h0 : 0 ≤ t) (h1 : t ≤ 1)
    (S : Finset ℕ) (hcard : S.card ≤ m) :
    chain (stackFrom (ablStack n t h0 h1 S) 0 (n + m)) d0 = d0 := by
  by_cases hall : ∀ k, n ≤ k → k < n + m → k ∈ S
  · -- every masker is ablated, so `S` is exactly the set of maskers
    have hsub : Finset.Ico n (n + m) ⊆ S := by
      intro k hk
      rw [Finset.mem_Ico] at hk
      exact hall k hk.1 hk.2
    have hcards : S.card ≤ (Finset.Ico n (n + m)).card := by
      rw [Nat.card_Ico]
      simpa using hcard
    have hEq : Finset.Ico n (n + m) = S := Finset.eq_of_subset_of_card_le hsub hcards
    have hidK : ∀ i, 0 ≤ i → i < 0 + (n + m) → ablStack n t h0 h1 S i = idK := by
      intro i _ hi
      by_cases hiS : i ∈ S
      · have hin : n ≤ i := by
          rw [← hEq, Finset.mem_Ico] at hiS
          exact hiS.1
        simp [ablStack, hiS, ablLayer, Nat.not_lt.2 hin]
      · have hin : i < n := by
          by_contra hcon
          exact hiS (hEq ▸ Finset.mem_Ico.2 ⟨by omega, by omega⟩)
        simp [ablStack, hiS, baseLayer, hin]
    -- the whole stack is the identity, so it fixes its input `d0`
    have hstack : ∀ (l s : ℕ) (ν : Dist (Fin 2)),
        (∀ i, s ≤ i → i < s + l → ablStack n t h0 h1 S i = idK) →
        chain (stackFrom (ablStack n t h0 h1 S) s l) ν = ν := by
      intro l
      induction l with
      | zero => intro s ν _; simp
      | succ l ih =>
          intro s ν h
          rw [stackFrom_succ, chain_cons, h s le_rfl (by omega), push_idK]
          exact ih (s + 1) ν fun i hi hi' => h i (by omega) (by omega)
    exact hstack (n + m) 0 d0 hidK
  · -- some masker survives and resets the state
    push_neg at hall
    obtain ⟨k, hk1, hk2, hkS⟩ := hall
    refine chain_stackFrom_of_const (ablStack n t h0 h1 S) d0 (n + m) 0 k d0 (Nat.zero_le _)
      (by omega) ?_ ?_
    · simp [ablStack, hkS, baseLayer, Nat.not_lt.2 hk1]
    · intro i hi hi'
      by_cases hiS : i ∈ S
      · left; simp [ablStack, hiS, ablLayer, Nat.not_lt.2 (by omega : n ≤ i)]
      · right; simp [ablStack, hiS, baseLayer, Nat.not_lt.2 (by omega : n ≤ i)]

/-! ## 4. Arity `m+1` recovers the damage exactly -/

/-- **Recovery at arity `m+1`.**  Ablating all `m` maskers together with a single
transparent layer `j` makes the stack output `Bernoulli(t)`: the hidden per-layer
damage becomes visible in full. -/
theorem masker_arity_recovers (n m j : ℕ) (t : ℚ) (h0 : 0 ≤ t) (h1 : t ≤ 1) (hj : j < n)
    (μ : Dist (Fin 2)) :
    chain (stackFrom (ablStack n t h0 h1 (insert j (Finset.Ico n (n + m)))) 0 (n + m)) μ
      = bern t h0 h1 := by
  set S := insert j (Finset.Ico n (n + m)) with hS
  have hjS : j ∈ S := Finset.mem_insert_self _ _
  refine chain_stackFrom_of_const (ablStack n t h0 h1 S) (bern t h0 h1) (n + m) 0 j μ
    (Nat.zero_le _) (by omega) ?_ ?_
  · simp [ablStack, hjS, ablLayer, hj]
  · intro i hi hi'
    left
    by_cases hiS : i ∈ S
    · have hin : n ≤ i := by
        rcases Finset.mem_insert.1 hiS with rfl | hmem
        · omega
        · exact (Finset.mem_Ico.1 hmem).1
      simp [ablStack, hiS, ablLayer, Nat.not_lt.2 hin]
    · have hin : i < n := by
        by_contra hcon
        exact hiS (Finset.mem_insert_of_mem (Finset.mem_Ico.2 ⟨by omega, by omega⟩))
      simp [ablStack, hiS, baseLayer, hin]

/-! ## 5. The hierarchy at the measured depth -/

/-- **No bounded-arity protocol is sound.**  Fix any split `n + m = 24` of the
measured depth with at least one transparent and at least one forgetful layer.
Then, for the `m`-masker stack:

* every ablation experiment of arity at most `m` returns exactly `0`, for every
  pruning strength `t`;
* the arity-`m+1` experiment that ablates all maskers and one transparent layer
  returns exactly `t`.

Taking `t = 0.017` and `t = 1` gives two prunings that agree on all experiments
of arity `≤ m` and differ by `0.983` at arity `m+1`.  Since `m` is arbitrary,
raising the arity of the NET-59 protocol by any fixed amount does not make it
sound. -/
theorem net59_arity_hierarchy (n m : ℕ) (hm : 0 < m) (hnm : n + m = 24) (t : ℚ)
    (h0 : 0 ≤ t) (h1 : t ≤ 1) :
    (∀ S : Finset ℕ, S.card ≤ m →
        tv (chain (stackFrom (baseLayer n) 0 24) d0)
           (chain (stackFrom (ablStack n t h0 h1 S) 0 24) d0) = 0) ∧
    (∀ j, j < n →
        tv (chain (stackFrom (baseLayer n) 0 24) d0)
           (chain (stackFrom (ablStack n t h0 h1 (insert j (Finset.Ico n 24))) 0 24) d0) = t) := by
  rw [← hnm]
  constructor
  · intro S hS
    rw [chain_base n m hm, masker_arity_blind n m t h0 h1 S hS, tv_self]
  · intro j hj
    rw [chain_base n m hm, masker_arity_recovers n m j t h0 h1 hj, d0, tv_bern, zero_sub, abs_neg,
      abs_of_nonneg h0]

end Catalog.Probability.NET59