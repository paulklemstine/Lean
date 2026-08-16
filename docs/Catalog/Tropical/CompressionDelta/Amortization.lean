import Tropical.CompressionDelta.Core

/-!
# Amortized model-delta compression, II: *the model is free, the model delta is not*

Continuation of `CompressionDelta.Core`.  We analyse a stream of `n` statistically
identical messages, a *generic* decoder state `prev` (the pretrained model out of the box,
costing `r + 1` bits per message) and a *specialized* state `g` (the domain-adapted model,
costing `r` bits per message) which can only be entered by transmitting a model delta of
`D` bits.

The results below make the slogan of this research thread precise.

* `CompressionDelta.optCost_replicate_le_delta` — the amortized protocol: pay `D` once.
* `CompressionDelta.delta_lower_bound` — you cannot cheat: any protocol that ever uses a
  specialized state pays the delta, and any protocol that does not pays one extra bit per
  message.  Hence `n * r + min D n` bits are always needed.
* `CompressionDelta.optCost_replicate_eq` — **sharp**: the optimum is *exactly*
  `n * r + min D n`.
* `CompressionDelta.beats_generic_iff` — the break-even point is exactly at `n = D`
  messages: the delta pays for itself iff the stream is longer than the delta.
* `CompressionDelta.tendsto_amortized_rate` — asymptotically the model delta is free:
  the amortized bits-per-message tends to the residual rate `r`.
* `CompressionDelta.boolModel_optCost` — the hypotheses are satisfiable (non-vacuity),
  witnessed by an explicit two-state model.
-/

namespace CompressionDelta

open Filter Topology

variable {M : Type*} [Finite M] [Nonempty M]

/-! ## The amortized upper bound -/

/-- Cost of the "switch once to `m`, then stay" protocol on a stream of `n` identical
messages. -/
theorem optCost_replicate_le (dlt : M → M → ℕ) (hself : ∀ m : M, dlt m m = 0)
    (c : M → ℕ) (m prev : M) (n : ℕ) :
    optCost dlt prev (List.replicate n c) ≤ dlt prev m + n * c m := by
  have h := optCost_le_stay dlt hself m (List.replicate n c) prev
  simpa [List.map_replicate, List.sum_replicate, smul_eq_mul] using h

/-- **The amortized protocol.**  Transmitting the `D`-bit model delta once and then coding
every message at the specialized rate `r` costs `D + n * r` bits. -/
theorem optCost_replicate_le_delta (dlt : M → M → ℕ) (hself : ∀ m : M, dlt m m = 0)
    (c : M → ℕ) (r D : ℕ) (g prev : M) (hg : c g = r) (hgD : dlt prev g ≤ D) (n : ℕ) :
    optCost dlt prev (List.replicate n c) ≤ D + n * r := by
  have h := optCost_replicate_le dlt hself c g prev n
  rw [hg] at h
  omega

/-! ## The rate floor -/

/-- Specialisation of `rate_mul_length_le_optCost` to a stream of identical messages. -/
theorem rate_le_optCost_replicate (dlt : M → M → ℕ) (c : M → ℕ) (r : ℕ)
    (hr : ∀ m : M, r ≤ c m) (prev : M) (n : ℕ) :
    n * r ≤ optCost dlt prev (List.replicate n c) := by
  have h := rate_mul_length_le_optCost dlt r (List.replicate n c)
    (by
      intro c' hc' m
      rw [List.eq_of_mem_replicate hc']
      exact hr m) prev
  simpa using h

/-! ## The delta lower bound -/

/-- **The model delta is not free.**  Assume every message costs at least `r` bits, and
that entering a *specialized* state (one achieving the optimal rate `r`) from a
non-specialized state costs at least `D` bits of model delta.  Then, starting from a
non-specialized decoder state, every protocol on a stream of `n` messages transmits at
least `n * r + min D n` bits: either it pays the delta, or it pays one extra bit on every
message. -/
theorem delta_lower_bound (dlt : M → M → ℕ) (c : M → ℕ) (r D : ℕ)
    (hr : ∀ m : M, r ≤ c m)
    (hD : ∀ m m' : M, c m' = r → c m ≠ r → D ≤ dlt m m') :
    ∀ (n : ℕ) (prev : M), c prev ≠ r →
      n * r + min D n ≤ optCost dlt prev (List.replicate n c) := by
  intro n
  induction n with
  | zero => intro prev _; simp
  | succ n ih =>
      intro prev hprev
      rw [List.replicate_succ, optCost_cons]
      refine le_natInf ?_
      intro m
      have hnr : (n + 1) * r = n * r + r := by ring
      by_cases hm : c m = r
      · have h1 : D ≤ dlt prev m := hD prev m hm hprev
        have h2 : n * r ≤ optCost dlt m (List.replicate n c) :=
          rate_le_optCost_replicate dlt c r hr m n
        rw [hm]
        omega
      · have h1 : r + 1 ≤ c m := by
          have := hr m
          omega
        have h2 : n * r + min D n ≤ optCost dlt m (List.replicate n c) := ih m hm
        omega

/-! ## Sharpness -/

/-- **Exact value of the amortized optimum.**  Under the hypotheses of `delta_lower_bound`,
together with a free "stay" move, a specialized state `g` reachable for exactly `D` bits
and a generic starting state costing `r + 1` bits per message, the optimal number of
transmitted bits for a stream of `n` messages is *exactly* `n * r + min D n`. -/
theorem optCost_replicate_eq (dlt : M → M → ℕ) (c : M → ℕ) (r D : ℕ) (g prev : M)
    (hself : ∀ m : M, dlt m m = 0)
    (hr : ∀ m : M, r ≤ c m)
    (hD : ∀ m m' : M, c m' = r → c m ≠ r → D ≤ dlt m m')
    (hg : c g = r) (hgD : dlt prev g ≤ D) (hprev : c prev = r + 1) (n : ℕ) :
    optCost dlt prev (List.replicate n c) = n * r + min D n := by
  have hne : c prev ≠ r := by omega
  refine le_antisymm ?_ (delta_lower_bound dlt c r D hr hD n prev hne)
  have hspec : optCost dlt prev (List.replicate n c) ≤ D + n * r :=
    optCost_replicate_le_delta dlt hself c r D g prev hg hgD n
  have hgen : optCost dlt prev (List.replicate n c) ≤ dlt prev prev + n * c prev :=
    optCost_replicate_le dlt hself c prev prev n
  rw [hself prev, hprev] at hgen
  have : n * (r + 1) = n * r + n := by ring
  omega

/-- **Break-even is exactly at `n = D`.**  The adaptive protocol strictly beats the
delta-free generic protocol (which costs `n * (r + 1)` bits) precisely when the stream is
longer than the model delta. -/
theorem beats_generic_iff (dlt : M → M → ℕ) (c : M → ℕ) (r D : ℕ) (g prev : M)
    (hself : ∀ m : M, dlt m m = 0)
    (hr : ∀ m : M, r ≤ c m)
    (hD : ∀ m m' : M, c m' = r → c m ≠ r → D ≤ dlt m m')
    (hg : c g = r) (hgD : dlt prev g ≤ D) (hprev : c prev = r + 1) (n : ℕ) :
    optCost dlt prev (List.replicate n c) < n * (r + 1) ↔ D < n := by
  rw [optCost_replicate_eq dlt c r D g prev hself hr hD hg hgD hprev n]
  have : n * (r + 1) = n * r + n := by ring
  omega

/-- For short streams (`n ≤ D`) the model delta is *never* worth transmitting: the optimum
coincides with the delta-free generic protocol. -/
theorem short_stream_no_gain (dlt : M → M → ℕ) (c : M → ℕ) (r D : ℕ) (g prev : M)
    (hself : ∀ m : M, dlt m m = 0)
    (hr : ∀ m : M, r ≤ c m)
    (hD : ∀ m m' : M, c m' = r → c m ≠ r → D ≤ dlt m m')
    (hg : c g = r) (hgD : dlt prev g ≤ D) (hprev : c prev = r + 1) (n : ℕ) (hn : n ≤ D) :
    optCost dlt prev (List.replicate n c) = n * (r + 1) := by
  rw [optCost_replicate_eq dlt c r D g prev hself hr hD hg hgD hprev n]
  have : n * (r + 1) = n * r + n := by ring
  omega

/-! ## Asymptotics: the model is free -/

/-- **The model is free in the limit.**  The amortized number of transmitted bits per
message converges to the specialized residual rate `r`: the one-off model delta washes
out, no matter how large it is. -/
theorem tendsto_amortized_rate (dlt : M → M → ℕ) (c : M → ℕ) (r D : ℕ) (g prev : M)
    (hself : ∀ m : M, dlt m m = 0)
    (hr : ∀ m : M, r ≤ c m) (hg : c g = r) (hgD : dlt prev g ≤ D) :
    Tendsto (fun n : ℕ => (optCost dlt prev (List.replicate n c) : ℝ) / n) atTop
      (𝓝 (r : ℝ)) := by
  have hupper : Tendsto (fun n : ℕ => (r : ℝ) + (D : ℝ) / n) atTop (𝓝 (r : ℝ)) := by
    simpa using (tendsto_const_nhds (x := (r : ℝ)) (f := (atTop : Filter ℕ))).add
      (tendsto_const_div_atTop_nhds_zero_nat (D : ℝ))
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hupper ?_ ?_
  · filter_upwards [eventually_ge_atTop 1] with n hn
    have hn0 : (0 : ℝ) < n := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hn
    have h := rate_le_optCost_replicate dlt c r hr prev n
    rw [le_div_iff₀ hn0]
    calc (r : ℝ) * n = ((n * r : ℕ) : ℝ) := by push_cast; ring
      _ ≤ _ := by exact_mod_cast h
  · filter_upwards [eventually_ge_atTop 1] with n hn
    have hn0 : (0 : ℝ) < n := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hn
    have h := optCost_replicate_le_delta dlt hself c r D g prev hg hgD n
    rw [div_le_iff₀ hn0]
    have h' : ((optCost dlt prev (List.replicate n c) : ℕ) : ℝ) ≤ ((D + n * r : ℕ) : ℝ) := by
      exact_mod_cast h
    calc ((optCost dlt prev (List.replicate n c) : ℕ) : ℝ) ≤ ((D + n * r : ℕ) : ℝ) := h'
      _ = (D : ℝ) + n * r := by push_cast; ring
      _ = ((r : ℝ) + (D : ℝ) / n) * n := by field_simp; ring

/-! ## Non-vacuity: an explicit two-state model -/

section BoolModel

variable (r D : ℕ)

/-- Residual cost in the explicit two-state model: the specialized state `true` codes a
message in `r` bits, the generic pretrained state `false` needs `r + 1`. -/
def boolCost : Bool → ℕ := fun m => if m then r else r + 1

/-- Model-delta cost in the explicit two-state model: entering the specialized state from
the generic one costs `D` bits; staying put, or falling back to the generic state, is
free. -/
def boolDelta : Bool → Bool → ℕ := fun m m' => if m' = true ∧ m = false then D else 0

/-- The hypotheses of `optCost_replicate_eq` are satisfiable, and there the optimum is
exactly `n * r + min D n`: for `n ≤ D` messages the specialized model is not worth its
delta, and beyond that it is. -/
theorem boolModel_optCost (n : ℕ) :
    optCost (boolDelta D) false (List.replicate n (boolCost r)) = n * r + min D n := by
  refine optCost_replicate_eq (boolDelta D) (boolCost r) r D true false ?_ ?_ ?_ ?_ ?_ ?_ n
  · intro m; cases m <;> simp [boolDelta]
  · intro m; cases m <;> simp [boolCost]
  · intro m m' hm' hm
    have hm'true : m' = true := by
      cases m' with
      | false => simp [boolCost] at hm'
      | true => rfl
    have hmfalse : m = false := by
      cases m with
      | false => rfl
      | true => simp [boolCost] at hm
    simp [boolDelta, hm'true, hmfalse]
  · simp [boolCost]
  · simp [boolDelta]
  · simp [boolCost]

/-- In the explicit two-state model the delta only pays off past the break-even point. -/
theorem boolModel_break_even (n : ℕ) :
    optCost (boolDelta D) false (List.replicate n (boolCost r)) < n * (r + 1) ↔ D < n := by
  rw [boolModel_optCost r D n]
  have : n * (r + 1) = n * r + n := by ring
  omega

end BoolModel

end CompressionDelta