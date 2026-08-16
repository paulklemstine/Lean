import Mathlib

/-!
# Amortized model-delta compression, I: the min-plus (tropical) core

This file is part of the research thread *Compression Beyond the Pigeonhole Bound*,
Phase A / Question 1: **separating the decompressor from the data**.

## Modelling decision

A streaming compression protocol with a *shared, adaptable decompressor* is described by
two nonnegative integer cost functions (all costs are in bits):

* a family of **residual costs** `c : M → ℕ`, one function per message in the stream,
  where `c m` is the number of bits needed to code that message when the decoder is in
  model state `m`;
* a **model-delta cost** `dlt : M → M → ℕ`, where `dlt m m'` is the number of bits that
  must be transmitted to move the shared decoder from state `m` to state `m'`
  (a LoRA-style patch, a codebook index, a dictionary, …).

The total number of transmitted bits for a *schedule* (a choice of decoder state for each
message) is the alternating sum of deltas and residuals; the protocol optimum is the
minimum over schedules.  Both operations — "add costs along a path", "take the minimum
over paths" — are exactly multiplication and addition in the **min-plus (tropical)
semiring**, which is why this development lives in the Tropical catalog.  The tropical
semiring bridge itself is `CompressionDelta.TropicalBridge`.

## Main results

* `CompressionDelta.optCost_le_scheduleCost` — the DP value is a lower bound for every
  schedule of the right length.
* `CompressionDelta.exists_schedule_scheduleCost_eq` — the DP value is attained.
* `CompressionDelta.isLeast_optCost` — hence the DP value *is* the protocol optimum
  (Bellman optimality for the model-switching problem).
* `CompressionDelta.optCost_le_stay` — the "pay the delta once, then never switch"
  upper bound; this is the amortized protocol.
* `CompressionDelta.rate_mul_length_le_optCost` — no protocol can beat the per-message
  residual rate: the delta can only ever be amortized *down to* the rate, never below it.
-/

namespace CompressionDelta

variable {M : Type*}

/-! ## Infimum helpers over `ℕ` -/

/-- The infimum of a family of naturals indexed by a nonempty type is a lower bound. -/
theorem natInf_le {ι : Type*} [Nonempty ι] (f : ι → ℕ) (i : ι) : (⨅ j, f j) ≤ f i :=
  ciInf_le (OrderBot.bddBelow _) i

/-- Characterisation of `⨅` over `ℕ` from below. -/
theorem le_natInf {ι : Type*} [Nonempty ι] {a : ℕ} {f : ι → ℕ} (h : ∀ i, a ≤ f i) :
    a ≤ ⨅ j, f j :=
  le_ciInf h

/-- Over a finite nonempty index type, the infimum of a family of naturals is attained. -/
theorem exists_natInf_eq {ι : Type*} [Finite ι] [Nonempty ι] (f : ι → ℕ) :
    ∃ i, (⨅ j, f j) = f i := by
  obtain ⟨i, hi⟩ := Finite.exists_min f
  exact ⟨i, le_antisymm (natInf_le f i) (le_natInf hi)⟩

/-! ## Schedules and their cost -/

/-- `scheduleCost dlt prev cs ms` is the total number of bits transmitted when the decoder
starts in state `prev`, the stream of messages has residual-cost functions `cs`, and the
encoder decides to put the decoder in state `ms.get i` for the `i`-th message.  Each step
pays the model delta `dlt` for the switch and then the residual for the message.

Schedules shorter than the message stream are meaningless; the definition returns the cost
of the common prefix, and every theorem below quantifies over schedules of the correct
length. -/
def scheduleCost (dlt : M → M → ℕ) : M → List (M → ℕ) → List M → ℕ
  | _, [], _ => 0
  | _, _ :: _, [] => 0
  | prev, c :: cs, m :: ms => dlt prev m + c m + scheduleCost dlt m cs ms

@[simp] theorem scheduleCost_nil (dlt : M → M → ℕ) (prev : M) (ms : List M) :
    scheduleCost dlt prev [] ms = 0 := rfl

@[simp] theorem scheduleCost_cons (dlt : M → M → ℕ) (prev m : M) (c : M → ℕ)
    (cs : List (M → ℕ)) (ms : List M) :
    scheduleCost dlt prev (c :: cs) (m :: ms) = dlt prev m + c m + scheduleCost dlt m cs ms :=
  rfl

/-- The min-plus dynamic program: the least number of bits an adaptive protocol can
transmit for the stream `cs`, starting from decoder state `prev`. -/
noncomputable def optCost [Finite M] [Nonempty M] (dlt : M → M → ℕ) :
    M → List (M → ℕ) → ℕ
  | _, [] => 0
  | prev, c :: cs => ⨅ m : M, (dlt prev m + c m + optCost dlt m cs)

variable [Finite M] [Nonempty M]

@[simp] theorem optCost_nil (dlt : M → M → ℕ) (prev : M) : optCost dlt prev [] = 0 := by
  rw [optCost]

theorem optCost_cons (dlt : M → M → ℕ) (prev : M) (c : M → ℕ) (cs : List (M → ℕ)) :
    optCost dlt prev (c :: cs) = ⨅ m : M, (dlt prev m + c m + optCost dlt m cs) := by
  rw [optCost]

/-! ## Bellman optimality -/

/-- The dynamic program is a lower bound for every schedule of matching length. -/
theorem optCost_le_scheduleCost (dlt : M → M → ℕ) :
    ∀ (cs : List (M → ℕ)) (prev : M) (ms : List M), ms.length = cs.length →
      optCost dlt prev cs ≤ scheduleCost dlt prev cs ms := by
  intro cs
  induction cs with
  | nil => intro prev ms _; simp
  | cons c cs ih =>
      intro prev ms hlen
      cases ms with
      | nil => simp at hlen
      | cons m ms =>
          have hlen' : ms.length = cs.length := by simpa using hlen
          rw [optCost_cons, scheduleCost_cons]
          refine le_trans (natInf_le _ m) ?_
          have := ih m ms hlen'
          omega

/-- The dynamic program value is attained by an explicit schedule. -/
theorem exists_schedule_scheduleCost_eq (dlt : M → M → ℕ) :
    ∀ (cs : List (M → ℕ)) (prev : M),
      ∃ ms : List M, ms.length = cs.length ∧
        scheduleCost dlt prev cs ms = optCost dlt prev cs := by
  intro cs
  induction cs with
  | nil => intro prev; exact ⟨[], rfl, by simp⟩
  | cons c cs ih =>
      intro prev
      obtain ⟨m, hm⟩ := exists_natInf_eq (fun m : M => dlt prev m + c m + optCost dlt m cs)
      obtain ⟨ms, hlen, hms⟩ := ih m
      refine ⟨m :: ms, by simp [hlen], ?_⟩
      rw [scheduleCost_cons, hms, optCost_cons, hm]

/-- **Bellman optimality for the model-switching protocol.**  `optCost` is exactly the
minimum, over all decoder-state schedules, of the total transmitted bits. -/
theorem isLeast_optCost (dlt : M → M → ℕ) (prev : M) (cs : List (M → ℕ)) :
    IsLeast {k | ∃ ms : List M, ms.length = cs.length ∧ scheduleCost dlt prev cs ms = k}
      (optCost dlt prev cs) := by
  constructor
  · obtain ⟨ms, hlen, hms⟩ := exists_schedule_scheduleCost_eq dlt cs prev
    exact ⟨ms, hlen, hms⟩
  · rintro k ⟨ms, hlen, rfl⟩
    exact optCost_le_scheduleCost dlt cs prev ms hlen

/-! ## The amortized upper bound: pay the delta once -/

/-- **Pay the delta once.**  If staying in a model is free (`dlt m m = 0`), the protocol
that switches to `m` for the first message and never switches again transmits
`dlt prev m` bits of model delta plus the residuals; hence the optimum is at most that. -/
theorem optCost_le_stay (dlt : M → M → ℕ) (hself : ∀ m : M, dlt m m = 0) (m : M) :
    ∀ (cs : List (M → ℕ)) (prev : M),
      optCost dlt prev cs ≤ dlt prev m + (cs.map (fun c => c m)).sum := by
  intro cs
  induction cs with
  | nil => intro prev; simp
  | cons c cs ih =>
      intro prev
      rw [optCost_cons]
      refine le_trans (natInf_le _ m) ?_
      have h := ih m
      rw [hself m] at h
      simp only [List.map_cons, List.sum_cons]
      omega

/-! ## The matching lower bound: the rate is a hard floor -/

/-- **The residual rate is a floor.**  If every message costs at least `r` bits in every
decoder state, then no adaptive protocol transmits fewer than `r` bits per message,
whatever it does with the model delta. -/
theorem rate_mul_length_le_optCost (dlt : M → M → ℕ) (r : ℕ) :
    ∀ (cs : List (M → ℕ)), (∀ c ∈ cs, ∀ m : M, r ≤ c m) → ∀ prev : M,
      cs.length * r ≤ optCost dlt prev cs := by
  intro cs
  induction cs with
  | nil => intro _ prev; simp
  | cons c cs ih =>
      intro hcs prev
      rw [optCost_cons]
      refine le_natInf ?_
      intro m
      have h1 : r ≤ c m := hcs c (by simp) m
      have h2 : cs.length * r ≤ optCost dlt m cs :=
        ih (fun c' hc' m' => hcs c' (by simp [hc']) m') m
      simp only [List.length_cons]
      have : (cs.length + 1) * r = cs.length * r + r := by ring
      omega

end CompressionDelta