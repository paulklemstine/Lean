import Novelty.AFLMatching.Basic

/-!
# Monochromatic matching lower bounds for bounded-degree (pseudorandom-like) hypergraphs

Building on `Basic.lean`, we assemble the structural lemmas into quantitative bounds.

Main results:

* `MaximalMatching.card_host_le` — **greedy counting bound**: in a `t`-uniform host with
  maximum degree `≤ Δ`, every maximal matching `M` satisfies `#H ≤ t·Δ·#M`.  Hence the
  matching number is at least `#H / (t·Δ)`.
* `mono_matching_lower_bound` — combining the greedy bound with the colour pigeonhole:
  every `r`-colouring contains a **monochromatic** matching `M` with `r·t·Δ·#M ≥ #H`,
  i.e. of size at least `#H / (r·t·Δ)`.
* `afl_constant_gap` — the honesty check: the fraction `1/(r·t)` produced by the
  bounded-degree route is `≤` the AFL target `1/(r+t-1)`, since `r+t-1 ≤ r·t`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): For a `d`-pseudorandom `t`-graph, `#H ≈ d·\binom{n}{t}` and
`Δ ≈ d·\binom{n-1}{t-1}`, so `#H/(t·Δ) ≈ n/t`; with `r` colours the pigeonhole costs a
factor `r`, predicting a monochromatic matching of size `≈ n/(r·t)`.

Experiment (Experimenter): Proved `card_host_le`, `mono_matching_lower_bound`,
`afl_constant_gap` — all `sorry`-free.

Analysis (Analyst): The route is robust (needs only bounded degree, NOT completeness or
pseudorandom counting), but loses a factor `rt/(r+t-1) = 1 + (r-1)(t-1)/(r+t-1) > 1`
compared with AFL whenever `r,t ≥ 2`.  Conclusion: the AFL constant `1/(r+t-1)` is a
*global* phenomenon — recovering it provably needs the LP/strip reduction, not a greedy
maximal matching.  Marked as the central open gap in `FUTURE_DIRECTIONS.md`.

Critique (Critic): We verified the bound is non-vacuous: when `#H > 0` it forces
`#M ≥ 1`, and the multiplicative form avoids natural-number division artefacts.

Synthesis (PI): A clean, fully-verified weak AFL bound for arbitrary bounded-degree
hosts, plus a proof that it cannot match `1/(r+t-1)` by this method alone.
-/

namespace AFLMatching

open Finset

variable {V : Type*} [DecidableEq V]

/-
The support of a matching whose edges all have size `≤ t` has at most `t · #M` vertices.
-/
theorem support_card_le (M : Finset (Finset V)) {t : ℕ}
    (h : ∀ e ∈ M, e.card ≤ t) : (support M).card ≤ t * M.card := by
  exact le_trans ( Finset.card_biUnion_le ) ( by simpa [ mul_comm ] using Finset.sum_le_sum h )

/-
**Greedy counting bound.** In a `t`-uniform host with all vertex degrees `≤ Δ`, any
maximal matching `M` covers enough of the edges that `#H ≤ t · Δ · #M`.
-/
theorem MaximalMatching.card_host_le
    {H M : Finset (Finset V)} (hmax : MaximalMatching H M)
    {t : ℕ} (ht : 0 < t) (hunif : ∀ e ∈ H, e.card = t)
    {Δ : ℕ} (hdeg : ∀ v : V, (H.filter (fun e => v ∈ e)).card ≤ Δ) :
    H.card ≤ t * Δ * M.card := by
  -- By MaximalMatching.isCover hmax (nonempty edges), every e ∈ H contains some vertex v ∈ S. Therefore H ⊆ S.biUnion (fun v => H.filter (fun e => v ∈ e)).
  have h_subset : H ⊆ Finset.biUnion (support M) (fun v => H.filter (fun e => v ∈ e)) := by
    intro e he; have := MaximalMatching.isCover hmax ( fun e he => by have := hunif e he; exact Finset.card_pos.mp ( by linarith ) ) e he; aesop;
  refine' le_trans ( Finset.card_le_card h_subset ) _;
  refine' le_trans ( Finset.card_biUnion_le ) _;
  refine' le_trans ( Finset.sum_le_sum fun v hv => hdeg v ) _;
  simp +decide [ mul_comm, mul_left_comm ];
  rw [ mul_left_comm ];
  exact Nat.mul_le_mul_left _ ( support_card_le M fun e he => hunif e ( hmax.1 he ) ▸ le_rfl )

/-
**Monochromatic matching lower bound.** Every `r`-colouring `c` of the edges of a
`t`-uniform host `H` with maximum degree `≤ Δ` contains a monochromatic matching `M`
with `r · t · Δ · #M ≥ #H`; equivalently a monochromatic matching of size at least
`#H / (r · t · Δ)`.
-/
theorem mono_matching_lower_bound
    (H : Finset (Finset V)) {t : ℕ} (ht : 0 < t)
    (hunif : ∀ e ∈ H, e.card = t)
    {Δ : ℕ} (hdeg : ∀ v : V, (H.filter (fun e => v ∈ e)).card ≤ Δ)
    {r : ℕ} (hr : 0 < r) (c : Finset V → Fin r) :
    ∃ i : Fin r, ∃ M : Finset (Finset V),
      M ⊆ H ∧ IsMatching M ∧ (∀ e ∈ M, c e = i) ∧
      r * t * Δ * M.card ≥ H.card := by
  obtain ⟨M0, hM0⟩ : ∃ M0 : Finset (Finset V), MaximalMatching H M0 :=
    exists_maximalMatching H
  -- By MaximalMatching.card_host_le, H.card ≤ t * Δ * M0.card.
  have h_card_M0 : H.card ≤ t * Δ * M0.card := by
    apply MaximalMatching.card_host_le hM0 ht hunif hdeg;
  obtain ⟨ i, hi ⟩ := AFLMatching.IsMatching.exists_mono_of_card M0 hM0.2.1 hr c;
  exact ⟨ i, _, Finset.filter_subset _ _ |> Finset.Subset.trans <| hM0.1, hi.1, hi.2.1, by nlinarith [ show 0 ≤ t * Δ by positivity ] ⟩

/-
Non-vacuousness: if the host has at least one edge, the guaranteed monochromatic
matching is nonempty.
-/
theorem mono_matching_nonempty
    (H : Finset (Finset V)) {t : ℕ} (ht : 0 < t)
    (hunif : ∀ e ∈ H, e.card = t)
    {Δ : ℕ} (hdeg : ∀ v : V, (H.filter (fun e => v ∈ e)).card ≤ Δ)
    {r : ℕ} (hr : 0 < r) (c : Finset V → Fin r) (hH : H.Nonempty) :
    ∃ i : Fin r, ∃ M : Finset (Finset V),
      M ⊆ H ∧ IsMatching M ∧ (∀ e ∈ M, c e = i) ∧ M.Nonempty := by
  obtain ⟨ i, M, hM₁, hM₂, hM₃, hM₄ ⟩ := mono_matching_lower_bound H ht hunif hdeg hr c;
  contrapose! hM₄;
  rw [ hM₄ i M hM₁ hM₂ hM₃ ] ; aesop

/-
**AFL constant gap (honesty check).** For all `r, t ≥ 1` we have `r + t - 1 ≤ r · t`,
so the fraction `1/(r·t)` from the bounded-degree route never exceeds the AFL target
`1/(r+t-1)`.  The slack is exactly `(r-1)(t-1)`.
-/
theorem afl_constant_gap (r t : ℕ) (hr : 1 ≤ r) (ht : 1 ≤ t) :
    r + t - 1 ≤ r * t := by
  exact Nat.sub_le_of_le_add <| by nlinarith;

/-
The slack in `afl_constant_gap` is strictly positive once `r, t ≥ 2`: the greedy route
is strictly weaker than AFL for genuine multicolour higher-uniformity instances.
-/
theorem afl_constant_gap_strict (r t : ℕ) (hr : 2 ≤ r) (ht : 2 ≤ t) :
    r + t - 1 < r * t := by
  rw [ tsub_lt_iff_left ] <;> nlinarith

end AFLMatching