import Mathlib

/-!
# Sequential eviction: every deterministic cheap-signal policy is a factor `B` from offline

Companion to `Catalog.Combinatorics.HybridEvictionAdditiveLaw`.  There the model
is *static* (one selection of `B` slots) and the conclusion is that the whole
additive-hybrid family sits below the oracle.  Here the model is *sequential*
(a request stream served out of a `B`-slot cache) and we prove the structural
reason a cheap online signal cannot close the gap: with `B + 1` live items an
adversary makes **any** deterministic eviction rule fault on *every* request,
while an offline schedule for the very same stream faults at most `⌈m / B⌉`
times.

Main results:

* `Serves` — the nondeterministic "some eviction schedule serves this stream
  with `k` faults" relation (demand paging: only a faulting request changes the
  cache, and it evicts exactly one resident item).
* `runCost` — the cost of the deterministic policy given by an eviction rule
  `A : Finset α → α → α`, and `serves_runCost`: that run *is* a legal schedule.
* `offline_cost_bound` — **offline upper bound**: on `B + 1` items, for every
  stream `σ` there is a schedule with `k` faults where `k * B < σ.length + B`
  (i.e. `k ≤ ⌈σ.length / B⌉`).
* `runCost_advSeq` — **online lower bound**: the adaptive adversary
  `advSeq A` forces the rule `A` to fault on all `m` requests.
* `online_lower_bound_factor_budget` — the two combined: for every rule `A`
  there is a stream of length `m` on which `A` faults `m` times while some
  offline schedule faults `k` times with `k * B < m + B`.
* `hybrid_online_lower_bound` — the specialisation to the NET-61 family: the
  rule "evict the resident item of least `a + λ·p`" is such a rule for *every*
  `λ`, so no probe weight — indeed no cheap score whatsoever — escapes the
  factor-`B` worst case.
-/

namespace Catalog.Combinatorics.EvictionOnlineLowerBound

open Finset

variable {α : Type*} [DecidableEq α]

/-! ### Demand-paging schedules -/

/-- `Serves C σ k`: starting from cache `C`, the request stream `σ` can be
served with exactly `k` faults by *some* eviction schedule.  A hit leaves the
cache unchanged; a fault brings the requested item in and evicts one resident
item. -/
inductive Serves : Finset α → List α → ℕ → Prop
  | nil (C : Finset α) : Serves C [] 0
  | hit {C : Finset α} {r : α} {rest : List α} {k : ℕ} (h : r ∈ C)
      (hs : Serves C rest k) : Serves C (r :: rest) k
  | miss {C : Finset α} {r e : α} {rest : List α} {k : ℕ} (hr : r ∉ C) (he : e ∈ C)
      (hs : Serves (insert r (C.erase e)) rest k) : Serves C (r :: rest) (k + 1)

/-- If the first `n` requests are all resident, they can be skipped. -/
theorem serves_of_take {C : Finset α} {σ : List α} {n k : ℕ}
    (hmem : ∀ x ∈ σ.take n, x ∈ C) (hs : Serves C (σ.drop n) k) : Serves C σ k := by
  induction n generalizing σ with
  | zero => simpa using hs
  | succ n ih =>
      cases σ with
      | nil => simpa using hs
      | cons r rest =>
          have hr : r ∈ C := hmem r (by simp)
          refine Serves.hit hr (ih (fun x hx => hmem x ?_) (by simpa using hs))
          simp only [List.take_succ_cons, List.mem_cons]
          exact Or.inr hx

/-- The cache size is preserved by a fault. -/
theorem card_insert_erase {C : Finset α} {r e : α} (hr : r ∉ C) (he : e ∈ C) :
    (insert r (C.erase e)).card = C.card := by
  rw [Finset.card_insert_of_notMem (by simp [Finset.mem_erase, hr]),
    Finset.card_erase_of_mem he]
  have : 1 ≤ C.card := Finset.card_pos.2 ⟨e, he⟩
  omega

/-! ### The offline upper bound on `B + 1` items -/

variable [Fintype α]

/-- On a universe of `B + 1` items with a full `B`-slot cache, a fault turns the
cache into "everything except the evicted item". -/
theorem cache_after_miss {B : ℕ} (hcard : Fintype.card α = B + 1) {C : Finset α}
    (hC : C.card = B) {r e : α} (hr : r ∉ C) (he : e ∈ C) :
    insert r (C.erase e) = Finset.univ.erase e := by
  have huniv : insert r C = Finset.univ := by
    apply Finset.eq_univ_of_card
    rw [Finset.card_insert_of_notMem hr, hC, hcard]
  ext x
  simp only [Finset.mem_insert, Finset.mem_erase, Finset.mem_univ, and_true]
  constructor
  · rintro (rfl | hx)
    · intro hre
      subst hre
      exact hr he
    · exact hx.1
  · intro hxe
    have hx : x ∈ insert r C := by rw [huniv]; exact Finset.mem_univ x
    rcases Finset.mem_insert.1 hx with rfl | hx'
    · exact Or.inl rfl
    · exact Or.inr ⟨hxe, hx'⟩

/-- **Offline upper bound.**  With `B + 1` live items and a `B`-slot cache,
every request stream can be served with at most `⌈length / B⌉` faults: evicting
an item that is not requested in the next `B - 1` steps buys `B` fault-free
steps. -/
theorem offline_cost_bound {B : ℕ} (hB : 1 ≤ B) (hcard : Fintype.card α = B + 1) :
    ∀ (σ : List α) (C : Finset α), C.card = B → ∃ k, Serves C σ k ∧ k * B < σ.length + B := by
  intro σ
  induction hn : σ.length using Nat.strong_induction_on generalizing σ with
  | _ n ih =>
    subst hn
    intro C hC
    cases σ with
    | nil => exact ⟨0, Serves.nil C, by simpa using hB⟩
    | cons r rest =>
        by_cases hr : r ∈ C
        · obtain ⟨k, hk, hlt⟩ := ih rest.length (by simp) rest rfl C hC
          exact ⟨k, Serves.hit hr hk, by simp only [List.length_cons]; omega⟩
        · -- choose a victim not requested during the next `B - 1` steps
          have hsmall : (rest.take (B - 1)).toFinset.card < C.card := by
            have h1 : (rest.take (B - 1)).toFinset.card ≤ (rest.take (B - 1)).length :=
              List.toFinset_card_le _
            have h2 : (rest.take (B - 1)).length ≤ B - 1 := by
              simp
            omega
          obtain ⟨e, he, hein⟩ : ∃ e ∈ C, e ∉ (rest.take (B - 1)).toFinset := by
            by_contra hcon
            push_neg at hcon
            exact absurd (Finset.card_le_card hcon) (by omega)
          have hC' : (insert r (C.erase e)).card = B := by
            rw [card_insert_erase hr he, hC]
          have hEq : insert r (C.erase e) = Finset.univ.erase e :=
            cache_after_miss hcard hC hr he
          -- the next `B - 1` requests are hits
          have hhits : ∀ x ∈ rest.take (B - 1), x ∈ insert r (C.erase e) := by
            intro x hx
            rw [hEq, Finset.mem_erase]
            refine ⟨?_, Finset.mem_univ x⟩
            rintro rfl
            exact hein (List.mem_toFinset.2 hx)
          have hlen : (rest.drop (B - 1)).length < (r :: rest).length := by
            simp only [List.length_drop, List.length_cons]
            omega
          obtain ⟨k, hk, hlt⟩ :=
            ih (rest.drop (B - 1)).length hlen (rest.drop (B - 1)) rfl _ hC'
          refine ⟨k + 1, Serves.miss hr he (serves_of_take hhits hk), ?_⟩
          have hdl : (rest.drop (B - 1)).length = rest.length - (B - 1) := by
            simp [List.length_drop]
          rcases Nat.eq_zero_or_pos k with rfl | hk0
          · simp only [List.length_cons, zero_add, one_mul]
            omega
          · have hkb : B ≤ k * B := Nat.le_mul_of_pos_left B hk0
            have hexp : (k + 1) * B = k * B + B := by ring
            simp only [List.length_cons]
            omega

/-! ### The deterministic online policy and its adversary -/

/-- The cost of the deterministic policy that, on a fault, evicts `A C r`. -/
def runCost (A : Finset α → α → α) : List α → Finset α → ℕ
  | [], _ => 0
  | r :: rest, C =>
      if r ∈ C then runCost A rest C
      else runCost A rest (insert r (C.erase (A C r))) + 1

omit [Fintype α] in
/-- A deterministic policy's run is a legal schedule, so the offline bound
really is a bound on the *same* model. -/
theorem serves_runCost {B : ℕ} (A : Finset α → α → α)
    (hA : ∀ C : Finset α, C.card = B → ∀ r, A C r ∈ C) :
    ∀ (σ : List α) (C : Finset α), C.card = B → Serves C σ (runCost A σ C) := by
  intro σ
  induction σ with
  | nil => intro C _; exact Serves.nil C
  | cons r rest ih =>
      intro C hC
      by_cases hr : r ∈ C
      · rw [runCost, if_pos hr]
        exact Serves.hit hr (ih C hC)
      · rw [runCost, if_neg hr]
        have he : A C r ∈ C := hA C hC r
        exact Serves.miss hr he (ih _ (by rw [card_insert_erase hr he, hC]))

variable [Nonempty α]

/-- The item currently outside the cache (well defined as soon as the cache is
not everything). -/
noncomputable def missing (C : Finset α) : α :=
  if h : (Finset.univ \ C).Nonempty then h.choose else Classical.arbitrary α

theorem missing_notMem {B : ℕ} (hcard : Fintype.card α = B + 1) {C : Finset α}
    (hC : C.card = B) : missing C ∉ C := by
  have hne : (Finset.univ \ C).Nonempty := by
    rcases Finset.eq_empty_or_nonempty (Finset.univ \ C) with h | h
    · exfalso
      have hsub : (Finset.univ : Finset α) ⊆ C := Finset.sdiff_eq_empty_iff_subset.1 h
      have hle : Fintype.card α ≤ C.card := by
        simpa [Finset.card_univ] using Finset.card_le_card hsub
      rw [hcard, hC] at hle
      omega
    · exact h
  rw [missing, dif_pos hne]
  have := hne.choose_spec
  rw [Finset.mem_sdiff] at this
  exact this.2

/-- The adaptive adversary: always request the one item the policy just threw
away. -/
noncomputable def advSeq (A : Finset α → α → α) : ℕ → Finset α → List α
  | 0, _ => []
  | m + 1, C =>
      missing C :: advSeq A m (insert (missing C) (C.erase (A C (missing C))))

theorem advSeq_length (A : Finset α → α → α) (m : ℕ) (C : Finset α) :
    (advSeq A m C).length = m := by
  induction m generalizing C with
  | zero => simp [advSeq]
  | succ m ih => simp [advSeq, ih]

/-- **Online lower bound.**  Against the adaptive adversary every request is a
fault: a deterministic rule pays `m` on a stream of length `m`. -/
theorem runCost_advSeq {B : ℕ} (hcard : Fintype.card α = B + 1)
    (A : Finset α → α → α) (hA : ∀ C : Finset α, C.card = B → ∀ r, A C r ∈ C) :
    ∀ (m : ℕ) (C : Finset α), C.card = B → runCost A (advSeq A m C) C = m := by
  intro m
  induction m with
  | zero => intro C _; simp [advSeq, runCost]
  | succ m ih =>
      intro C hC
      have hmiss : missing C ∉ C := missing_notMem hcard hC
      have he : A C (missing C) ∈ C := hA C hC (missing C)
      have hC' : (insert (missing C) (C.erase (A C (missing C)))).card = B := by
        rw [card_insert_erase hmiss he, hC]
      rw [advSeq, runCost, if_neg hmiss, ih _ hC']

/-! ### The factor-`B` separation -/

/-- **No deterministic cheap-signal eviction rule is better than `B` times
offline.**  For every eviction rule `A` and every horizon `m` there is a request
stream of length `m` on which `A` faults on *every* request, while some offline
schedule for the same stream faults only `k` times with `k * B < m + B`. -/
theorem online_lower_bound_factor_budget {B : ℕ} (hB : 1 ≤ B)
    (hcard : Fintype.card α = B + 1) (A : Finset α → α → α)
    (hA : ∀ C : Finset α, C.card = B → ∀ r, A C r ∈ C) (m : ℕ) (C : Finset α)
    (hC : C.card = B) :
    ∃ (σ : List α) (k : ℕ), σ.length = m ∧ runCost A σ C = m ∧
      Serves C σ (runCost A σ C) ∧ Serves C σ k ∧ k * B < m + B := by
  refine ⟨advSeq A m C, ?_⟩
  obtain ⟨k, hk, hlt⟩ := offline_cost_bound hB hcard (advSeq A m C) C hC
  refine ⟨k, advSeq_length A m C, runCost_advSeq hcard A hA m C hC,
    serves_runCost A hA _ C hC, hk, ?_⟩
  rwa [advSeq_length] at hlt

/-! ### The NET-61 family is one of these rules -/

/-- The eviction rule of the additive hybrid: evict the resident slot of least
`a + λ·p`. -/
noncomputable def hybridEvictor (a p : α → ℝ) (lam : ℝ) : Finset α → α → α :=
  fun C _ =>
    if h : C.Nonempty then
      (Finset.exists_min_image C (fun i => a i + lam * p i) h).choose
    else Classical.arbitrary α

omit [DecidableEq α] [Fintype α] in
theorem hybridEvictor_mem {B : ℕ} (hB : 1 ≤ B) (a p : α → ℝ) (lam : ℝ) (C : Finset α)
    (hC : C.card = B) (r : α) : hybridEvictor a p lam C r ∈ C := by
  have h : C.Nonempty := Finset.card_pos.1 (by omega)
  rw [hybridEvictor, dif_pos h]
  exact (Finset.exists_min_image C (fun i => a i + lam * p i) h).choose_spec.1

/-- **The NET-61 conclusion in the sequential model.**  For *every* probe weight
`λ` — including `λ = 0`, the pure accumulation arm — the additive-hybrid
eviction rule is forced to fault on every request of an adversarial stream that
an offline schedule serves with a factor `B` fewer faults.  Enriching the score
with content cannot help, because the bound is uniform over all rules. -/
theorem hybrid_online_lower_bound {B : ℕ} (hB : 1 ≤ B) (hcard : Fintype.card α = B + 1)
    (a p : α → ℝ) (lam : ℝ) (m : ℕ) (C : Finset α) (hC : C.card = B) :
    ∃ (σ : List α) (k : ℕ), σ.length = m ∧ runCost (hybridEvictor a p lam) σ C = m ∧
      Serves C σ k ∧ k * B < m + B := by
  obtain ⟨σ, k, hlen, hrun, _, hk, hlt⟩ :=
    online_lower_bound_factor_budget hB hcard (hybridEvictor a p lam)
      (fun C hC r => hybridEvictor_mem hB a p lam C hC r) m C hC
  exact ⟨σ, k, hlen, hrun, hk, hlt⟩

/-! ### Non-vacuity: the separation is realised on `Fin (B+1)` -/

/-- The hypotheses above are satisfiable: on the concrete universe `Fin (B+1)`
there really is an initial cache and, for every eviction rule, a stream forcing
`m` faults that is served offline with at most `⌈m / B⌉` faults. -/
theorem exists_stream_forcing_all_faults (B : ℕ) (hB : 1 ≤ B)
    (A : Finset (Fin (B + 1)) → Fin (B + 1) → Fin (B + 1))
    (hA : ∀ C : Finset (Fin (B + 1)), C.card = B → ∀ r, A C r ∈ C) (m : ℕ) :
    ∃ (C : Finset (Fin (B + 1))) (σ : List (Fin (B + 1))) (k : ℕ),
      C.card = B ∧ σ.length = m ∧ runCost A σ C = m ∧ Serves C σ k ∧ k * B < m + B := by
  have hcard : Fintype.card (Fin (B + 1)) = B + 1 := by simp
  obtain ⟨C, -, hC⟩ :=
    Finset.exists_subset_card_eq (s := (Finset.univ : Finset (Fin (B + 1)))) (n := B)
      (by simp)
  obtain ⟨σ, k, hlen, hrun, -, hk, hlt⟩ :=
    online_lower_bound_factor_budget hB hcard A hA m C hC
  exact ⟨C, σ, k, hC, hlen, hrun, hk, hlt⟩

end Catalog.Combinatorics.EvictionOnlineLowerBound