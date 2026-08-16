import Tropical.CompressionDelta.Amortization

/-!
# Amortized model-delta compression, VI: coherence length beats stream length

`CompressionDelta.tendsto_amortized_rate` shows that on a *coherent* stream (all messages
from one domain) the transmitted model delta is asymptotically free.  This file exhibits
the opposite regime and shows the previous result is not an artefact of the modelling:
on a stream whose domain **alternates at every message**, the optimal protocol never
reaches the specialized rate `r`, no matter how long the stream is, and the gap to the
information-theoretic floor grows *linearly* in the stream length.

The model: two domains, two specialized decoder states (`true` for one domain, `false` for
the other), a message from domain `d` costs `r` bits in state `d` and `r + 1` bits in the
other state, and swapping the decoder state costs `D ≥ 1` bits of model delta.

## Main results

* `CompressionDelta.optCost_altCosts` — an exact closed form for the optimum of the
  alternating stream: `n * r + ⌈n/2⌉` (or `n * r + ⌊n/2⌋` if the decoder happens to start
  in the right state).  Note the answer is *independent of `D`* once `D ≥ 1`: switching
  never pays.
* `CompressionDelta.alternating_gap_unbounded` — the excess over the rate floor `n * r`
  grows like `n / 2`.
* `CompressionDelta.tendsto_alternating_rate` — the amortized rate is exactly `r + 1/2`,
  strictly above the specialized rate `r` of the coherent regime.
-/

namespace CompressionDelta

open Filter Topology

/-- Residual cost of a message from domain `d`: `r` bits in the matching decoder state,
`r + 1` bits otherwise. -/
def domCost (r : ℕ) (d : Bool) : Bool → ℕ := fun m => if m = d then r else r + 1

/-- The stream whose domains alternate at every message, starting with domain `d`. -/
def altCosts (r : ℕ) : Bool → ℕ → List (Bool → ℕ)
  | _, 0 => []
  | d, n + 1 => domCost r d :: altCosts r (!d) n

/-- Model-delta cost: swapping the specialized decoder state costs `D` bits, staying is
free. -/
def swapDelta (D : ℕ) : Bool → Bool → ℕ := fun m m' => if m = m' then 0 else D

@[simp] theorem length_altCosts (r : ℕ) : ∀ (d : Bool) (n : ℕ), (altCosts r d n).length = n := by
  intro d n
  induction n generalizing d with
  | zero => simp [altCosts]
  | succ n ih => simp [altCosts, ih]

/-- The infimum over `Bool` is a binary minimum. -/
theorem natInf_bool (f : Bool → ℕ) : (⨅ b : Bool, f b) = min (f false) (f true) := by
  refine le_antisymm (le_min (natInf_le f false) (natInf_le f true)) (le_natInf ?_)
  intro b
  cases b <;> simp

/-- **Exact optimum for a maximally incoherent stream.**  With a nonzero model delta, the
optimal protocol for the alternating stream never switches: it transmits
`n * r + ⌈n/2⌉` bits (one extra bit on every message of the "wrong" domain).  In
particular the optimum does not depend on `D` at all: the delta is never worth paying. -/
theorem optCost_altCosts (r D : ℕ) (hD : 1 ≤ D) :
    ∀ (n : ℕ) (d prev : Bool),
      optCost (swapDelta D) prev (altCosts r d n) =
        n * r + (if prev = d then n / 2 else (n + 1) / 2) := by
  intro n
  induction n with
  | zero => intro d prev; simp [altCosts]
  | succ n ih =>
      intro d prev
      have hmul : (n + 1) * r = n * r + r := by ring
      rw [altCosts, optCost_cons, natInf_bool, ih (!d) false, ih (!d) true]
      cases d <;> cases prev <;> simp [domCost, swapDelta] <;> omega

/-- **The gap to the rate floor grows linearly.**  On the alternating stream the optimum
exceeds the information-theoretic floor `n * r` by about `n / 2` bits — in sharp contrast
with the coherent regime, where the excess is the one-off delta `min D n ≤ D`. -/
theorem alternating_gap_unbounded (r D : ℕ) (hD : 1 ≤ D) (n : ℕ) (d prev : Bool) :
    2 * (n * r) + n ≤ 2 * optCost (swapDelta D) prev (altCosts r d n) + 1 := by
  rw [optCost_altCosts r D hD n d prev]
  by_cases h : prev = d
  · rw [if_pos h]; omega
  · rw [if_neg h]; omega

/-- Upper companion of `alternating_gap_unbounded`. -/
theorem alternating_gap_le (r D : ℕ) (hD : 1 ≤ D) (n : ℕ) (d prev : Bool) :
    2 * optCost (swapDelta D) prev (altCosts r d n) ≤ 2 * (n * r) + n + 1 := by
  rw [optCost_altCosts r D hD n d prev]
  by_cases h : prev = d
  · rw [if_pos h]; omega
  · rw [if_neg h]; omega

/-- **The amortized rate of an incoherent stream is `r + 1/2`.**  Domain coherence, not
stream length, is what makes the model delta amortizable: here the protocol pays half a
bit per message forever. -/
theorem tendsto_alternating_rate (r D : ℕ) (hD : 1 ≤ D) (d prev : Bool) :
    Tendsto (fun n : ℕ => (optCost (swapDelta D) prev (altCosts r d n) : ℝ) / n) atTop
      (𝓝 ((r : ℝ) + 1 / 2)) := by
  have hzero : Tendsto (fun n : ℕ => (1 : ℝ) / n) atTop (𝓝 0) :=
    tendsto_const_div_atTop_nhds_zero_nat (1 : ℝ)
  have hlow : Tendsto (fun n : ℕ => ((r : ℝ) + 1 / 2) - 1 / n) atTop (𝓝 ((r : ℝ) + 1 / 2)) := by
    simpa using (tendsto_const_nhds (x := (r : ℝ) + 1 / 2)
      (f := (atTop : Filter ℕ))).sub hzero
  have hhigh : Tendsto (fun n : ℕ => ((r : ℝ) + 1 / 2) + 1 / n) atTop (𝓝 ((r : ℝ) + 1 / 2)) := by
    simpa using (tendsto_const_nhds (x := (r : ℝ) + 1 / 2)
      (f := (atTop : Filter ℕ))).add hzero
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow hhigh ?_ ?_
  · filter_upwards [eventually_ge_atTop 1] with n hn
    have hn0 : (0 : ℝ) < n := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hn
    have h := alternating_gap_unbounded r D hD n d prev
    have hR : 2 * ((n : ℝ) * r) + n ≤ 2 * (optCost (swapDelta D) prev (altCosts r d n) : ℝ) + 1 := by
      exact_mod_cast h
    have hne : (n : ℝ) ≠ 0 := ne_of_gt hn0
    rw [le_div_iff₀ hn0]
    have hexp : ((r : ℝ) + 1 / 2 - 1 / n) * n = (r : ℝ) * n + n / 2 - 1 := by
      field_simp
    rw [hexp]
    linarith [hR]
  · filter_upwards [eventually_ge_atTop 1] with n hn
    have hn0 : (0 : ℝ) < n := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hn
    have h := alternating_gap_le r D hD n d prev
    have hR : 2 * (optCost (swapDelta D) prev (altCosts r d n) : ℝ) ≤ 2 * ((n : ℝ) * r) + n + 1 := by
      exact_mod_cast h
    have hne : (n : ℝ) ≠ 0 := ne_of_gt hn0
    rw [div_le_iff₀ hn0]
    have hexp : ((r : ℝ) + 1 / 2 + 1 / n) * n = (r : ℝ) * n + n / 2 + 1 := by
      field_simp
    rw [hexp]
    linarith [hR]

/-- **Coherent versus incoherent, side by side.**  For every `n`, the alternating stream
costs at least `⌊n/2⌋` bits more than the rate floor, while the coherent stream of the same
length costs at most `D` bits more.  Hence for long streams the coherent protocol is
strictly cheaper per message. -/
theorem coherent_beats_incoherent (r D : ℕ) (hD : 1 ≤ D) (n : ℕ) (hn : 2 * D + 2 ≤ n) :
    optCost (boolDelta D) false (List.replicate n (boolCost r)) <
      optCost (swapDelta D) false (altCosts r true n) := by
  have hcoh : optCost (boolDelta D) false (List.replicate n (boolCost r)) = n * r + min D n :=
    boolModel_optCost r D n
  have hincoh := alternating_gap_unbounded r D hD n true false
  omega

end CompressionDelta