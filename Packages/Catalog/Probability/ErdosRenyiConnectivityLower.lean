/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The subcritical half of the connectivity threshold for `G(n,p)`

This file proves the "zero side" of the sharp connectivity threshold for the
Erdős–Rényi random graph: **below** the density `log n / n` the random graph
`G(n,p)` is a.a.s. *disconnected*.

We build directly on the finite `G(n,p)` model of `Probability.ErdosRenyiThreshold`
(configurations are finsets of potential edges, `mass`/`Prob`/`Expect`/`Variance`),
adding the two ingredients that were missing there:

* the **avoidance** (all-absent) probability `Prob p {s | Disjoint s T} = (1-p)^|T|`,
  obtained from the already-proved containment probability by the complementation
  duality `mass p sᶜ = mass (1-p) s`;
* the **exact second moment** of a count of avoided edge-blocks,
  `E[X²] = ∑ i ∑ j (1-p)^{|Bᵢ ∪ Bⱼ|}`.

Specialising the blocks `B v` to the stars `incident v` (all edges at a vertex `v`)
turns `X` into the number of **isolated vertices**, whose first two moments are
`E X = n (1-p)^{n-1}` and `E X² = n (1-p)^{n-1} + n(n-1)(1-p)^{2n-3}`.  Chebyshev's
inequality (`prob_eq_zero_le_variance_div_sq`, already available) then gives the
clean quantitative bound

`P(G(n,p) is connected) ≤ 1 / (n (1-p)^{n-1}) + p/(1-p)`,

and hence `P(connected) → 0` whenever `p → 0` and the expected number of isolated
vertices `n (1-p)^{n-1} → ∞`.  Both hypotheses hold for `p = c·log n / n` with
`0 < c < 1`, which is the classical statement that `log n / n` is the connectivity
threshold from below.
-/
import Probability.ErdosRenyiThreshold

open Finset BigOperators Filter Topology
open scoped Classical

namespace ErdosRenyi

variable {α : Type*} [Fintype α] [DecidableEq α]

/-! ## 1. Avoidance probabilities -/

/-- **Complementation duality.** Complementing a configuration exchanges the roles of
`p` and `1 - p`. -/
lemma mass_compl (p : ℝ) (s : Finset α) : mass p sᶜ = mass (1 - p) s := by
  simp only [mass, Finset.card_compl, sub_sub_cancel]
  rw [Nat.sub_sub_self (Finset.card_le_univ s)]
  ring_nf

/-- **Avoidance probability (independence, dual form).** The probability that the
random graph contains *no* edge of a fixed set `T` equals `(1-p)^{|T|}`. -/
lemma prob_avoids (p : ℝ) (T : Finset α) :
    Prob p (Finset.univ.filter (fun s => Disjoint s T)) = (1 - p) ^ T.card := by
  rw [← prob_contains_subset (1 - p) T]
  unfold Prob
  refine Finset.sum_nbij' (fun s => sᶜ) (fun u => uᶜ) ?_ ?_ ?_ ?_ ?_
  · intro a ha
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at *
    exact fun x hxT => Finset.mem_compl.mpr (Finset.disjoint_right.mp ha hxT)
  · intro a ha
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at *
    exact Finset.disjoint_left.mpr (fun x hx hxT => (Finset.mem_compl.mp hx) (ha hxT))
  · intro a _; simp
  · intro a _; simp
  · intro a _; simpa using (mass_compl (1 - p) a).symm

/-- Expectation form of `prob_avoids`. -/
lemma Expect_indicator_avoids (p : ℝ) (T : Finset α) :
    Expect p (fun s => if Disjoint s T then (1 : ℝ) else 0) = (1 - p) ^ T.card := by
  rw [← prob_avoids p T]
  simp only [Expect, Prob, Finset.sum_filter]
  exact Finset.sum_congr rfl fun s _ => by split_ifs <;> simp

/-! ## 2. Counting avoided blocks and its second moment -/

/-- The number of blocks `B i` that are entirely absent from the configuration `s`. -/
noncomputable def avoidCount {ι : Type*} [Fintype ι] (B : ι → Finset α) (s : Finset α) : ℝ :=
  ∑ i : ι, if Disjoint s (B i) then (1 : ℝ) else 0

/-- **First moment of an avoided-block count.** -/
lemma expect_avoidCount (p : ℝ) {ι : Type*} [Fintype ι] (B : ι → Finset α) :
    Expect p (avoidCount B) = ∑ i : ι, (1 - p) ^ (B i).card := by
  have h := Expect_sum p (Finset.univ : Finset ι)
    (fun i s => if Disjoint s (B i) then (1 : ℝ) else 0)
  show Expect p (fun s => ∑ i : ι, if Disjoint s (B i) then (1 : ℝ) else 0) = _
  rw [h]
  exact Finset.sum_congr rfl fun i _ => Expect_indicator_avoids p (B i)

/-- **Exact second moment of an avoided-block count**: the double sum records the
overlaps `Bᵢ ∪ Bⱼ` exactly. -/
lemma expect_avoidCount_sq (p : ℝ) {ι : Type*} [Fintype ι] (B : ι → Finset α) :
    Expect p (fun s => (avoidCount B s) ^ 2)
      = ∑ i : ι, ∑ j : ι, (1 - p) ^ (B i ∪ B j).card := by
  have hsq : ∀ s : Finset α, (avoidCount B s) ^ 2 =
      ∑ i : ι, ∑ j : ι, (if Disjoint s (B i ∪ B j) then (1 : ℝ) else 0) := by
    intro s
    simp only [avoidCount, sq, Finset.sum_mul, Finset.mul_sum]
    refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => ?_
    by_cases h1 : Disjoint s (B i) <;> by_cases h2 : Disjoint s (B j) <;>
      simp [h1, h2, Finset.disjoint_union_right]
  simp only [hsq]
  rw [Expect_sum p (Finset.univ : Finset ι)
    (fun i s => ∑ j : ι, if Disjoint s (B i ∪ B j) then (1 : ℝ) else 0)]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [Expect_sum p (Finset.univ : Finset ι)
    (fun j s => if Disjoint s (B i ∪ B j) then (1 : ℝ) else 0)]
  exact Finset.sum_congr rfl fun j _ => Expect_indicator_avoids p (B i ∪ B j)

omit [DecidableEq α] in
/-- Variance through the first two moments. -/
lemma variance_eq_sub (p : ℝ) (X : Finset α → ℝ) :
    Variance p X = Expect p (fun s => (X s) ^ 2) - (Expect p X) ^ 2 := by
  have h1 : ∑ s : Finset α, mass p s = 1 := total_mass p
  simp only [Variance, Expect]
  have hexp : ∀ s : Finset α,
      mass p s * (X s - ∑ t : Finset α, mass p t * X t) ^ 2 =
        mass p s * (X s) ^ 2 - 2 * (∑ t : Finset α, mass p t * X t) * (mass p s * X s)
          + (∑ t : Finset α, mass p t * X t) ^ 2 * mass p s := by
    intro s; ring
  have h2 : ∑ x : Finset α, (∑ t : Finset α, mass p t * X t) ^ 2 * mass p x
      = (∑ t : Finset α, mass p t * X t) ^ 2 := by
    rw [← Finset.mul_sum, h1, mul_one]
  simp only [hexp]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, h2, ← Finset.mul_sum]
  ring

/-! ## 3. The isolated-vertex count in `G(n,p)` -/

/-- The star at `v`: all potential edges incident to the vertex `v`. -/
noncomputable def incident {n : ℕ} (v : Fin n) : Finset (Edge n) :=
  Finset.univ.filter (fun e => v ∈ (e : Sym2 (Fin n)))

/-- A star has `n - 1` edges. -/
lemma card_incident {n : ℕ} (v : Fin n) : (incident v).card = n - 1 := by
  classical
  have hcard : (incident v).card = (Finset.univ.filter (fun u : Fin n => u ≠ v)).card := by
    refine Finset.card_bij' (fun e he => (Sym2.Mem.other' (by simpa [incident] using he)))
      (fun u hu => ⟨s(v, u), by
        simp only [Sym2.isDiag_iff_proj_eq]
        simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hu
        exact fun h => hu h.symm⟩) ?_ ?_ ?_ ?_
    · intro a ha
      simp only [Finset.mem_filter, Finset.mem_univ, true_and]
      have h := Sym2.other_spec' (a := v) (z := (a : Sym2 (Fin n))) (by simpa [incident] using ha)
      intro hcon
      exact a.2 (by rw [← h, hcon]; simp)
    · intro u _
      simp [incident]
    · intro a ha
      have h := Sym2.other_spec' (a := v) (z := (a : Sym2 (Fin n))) (by simpa [incident] using ha)
      exact Subtype.ext h
    · intro u hu
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hu
      have h := Sym2.other_spec' (a := v) (z := s(v, u)) (by simp)
      exact (Sym2.congr_right.mp h)
  rw [hcard, Finset.filter_ne']
  simp

/-- Two distinct stars meet exactly in the edge joining their centres. -/
lemma incident_inter {n : ℕ} {v w : Fin n} (hvw : v ≠ w) :
    incident v ∩ incident w = {⟨s(v, w), by simpa [Sym2.isDiag_iff_proj_eq] using hvw⟩} := by
  classical
  ext e
  simp only [Finset.mem_inter, incident, Finset.mem_filter, Finset.mem_univ, true_and,
    Finset.mem_singleton]
  constructor
  · rintro ⟨hv, hw⟩
    exact Subtype.ext ((Sym2.mem_and_mem_iff hvw).mp ⟨hv, hw⟩)
  · rintro rfl
    constructor <;> simp

/-- Two distinct stars cover `2n - 3` edges. -/
lemma card_incident_union {n : ℕ} (hn : 2 ≤ n) {v w : Fin n} (hvw : v ≠ w) :
    (incident v ∪ incident w).card = 2 * n - 3 := by
  classical
  have hunion := Finset.card_union_add_card_inter (incident v) (incident w)
  rw [incident_inter hvw, card_incident v, card_incident w] at hunion
  simp only [Finset.card_singleton] at hunion
  omega

/-- If no edge at `v` is present then `v` is isolated in `graphOf s`. -/
lemma not_adj_of_disjoint {n : ℕ} {s : Finset (Edge n)} {v : Fin n}
    (h : Disjoint s (incident v)) (u : Fin n) : ¬ (graphOf s).Adj v u := by
  rw [graphOf, SimpleGraph.fromEdgeSet_adj]
  rintro ⟨⟨e, he, hev⟩, -⟩
  have h1 : e ∈ incident v := by
    simp only [incident, Finset.mem_filter, Finset.mem_univ, true_and, hev]
    simp
  exact (Finset.disjoint_left.mp h he) h1

/-- A connected graph on at least two vertices has no isolated vertex, i.e. the
isolated-vertex count vanishes. -/
lemma avoidCount_incident_eq_zero_of_connected {n : ℕ} (hn : 2 ≤ n) {s : Finset (Edge n)}
    (hconn : (graphOf s).Connected) : avoidCount (fun v : Fin n => incident v) s = 0 := by
  classical
  refine Finset.sum_eq_zero fun v _ => ?_
  have hne : ∃ w : Fin n, w ≠ v := by
    have : 1 < Fintype.card (Fin n) := by simpa using hn
    exact Fintype.exists_ne_of_one_lt_card this v
  obtain ⟨w, hw⟩ := hne
  have hadj : ∃ u, (graphOf s).Adj v u := by
    obtain ⟨q⟩ := hconn.preconnected v w
    cases q with
    | nil => exact absurd rfl hw.symm
    | cons hadj q => exact ⟨_, hadj⟩
  rw [if_neg]
  intro hdis
  obtain ⟨u, hu⟩ := hadj
  exact not_adj_of_disjoint hdis u hu

/-! ## 4. Exact moments of the isolated-vertex count -/

omit [DecidableEq α] in
/-- Linearity of expectation for differences. -/
lemma Expect_sub (p : ℝ) (X Y : Finset α → ℝ) :
    Expect p (fun s => X s - Y s) = Expect p X - Expect p Y := by
  simp only [Expect, mul_sub, Finset.sum_sub_distrib]

/-- **First moment of the isolated-vertex count**: `E[I_n] = n (1-p)^{n-1}`. -/
lemma expect_isolated_count (n : ℕ) (p : ℝ) :
    Expect p (avoidCount (fun v : Fin n => incident v)) = (n : ℝ) * (1 - p) ^ (n - 1) := by
  rw [expect_avoidCount]
  simp only [card_incident]
  rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]

/-- **Second moment of the isolated-vertex count**:
`E[I_n²] = n (1-p)^{n-1} + n(n-1)(1-p)^{2n-3}`.  The diagonal contributes the first
term; each of the `n(n-1)` ordered pairs of distinct vertices contributes
`(1-p)^{|star(v) ∪ star(w)|} = (1-p)^{2n-3}`. -/
lemma expect_isolated_count_sq {n : ℕ} (hn : 2 ≤ n) (p : ℝ) :
    Expect p (fun s => (avoidCount (fun v : Fin n => incident v) s) ^ 2)
      = (n : ℝ) * (1 - p) ^ (n - 1)
        + (n : ℝ) * ((n : ℝ) - 1) * (1 - p) ^ (2 * n - 3) := by
  rw [expect_avoidCount_sq]
  have hcast : ((n - 1 : ℕ) : ℝ) = (n : ℝ) - 1 := by
    have h1 : (1 : ℕ) ≤ n := by omega
    push_cast [Nat.cast_sub h1]; ring
  have hinner : ∀ v : Fin n,
      ∑ w : Fin n, (1 - p) ^ (incident v ∪ incident w).card
        = (1 - p) ^ (n - 1) + ((n : ℝ) - 1) * (1 - p) ^ (2 * n - 3) := by
    intro v
    rw [← Finset.add_sum_erase _ _ (Finset.mem_univ v)]
    congr 1
    · rw [Finset.union_self, card_incident]
    · rw [Finset.sum_congr rfl (fun w hw => by
        rw [card_incident_union hn (Ne.symm (Finset.ne_of_mem_erase hw))])]
      rw [Finset.sum_const, Finset.card_erase_of_mem (Finset.mem_univ v), Finset.card_univ,
        Fintype.card_fin, nsmul_eq_mul, hcast]
  rw [Finset.sum_congr rfl (fun v _ => hinner v), Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul]
  ring

/-- **Second factorial moment of the isolated-vertex count**:
`E[I_n(I_n-1)] = n(n-1)(1-p)^{2n-3}`.  This is the `r = 2` case of the factorial-moment
formula feeding a Poisson limit theorem via the method of moments. -/
lemma expect_isolated_count_factorial_two {n : ℕ} (hn : 2 ≤ n) (p : ℝ) :
    Expect p (fun s => (avoidCount (fun v : Fin n => incident v) s)
        * (avoidCount (fun v : Fin n => incident v) s - 1))
      = (n : ℝ) * ((n : ℝ) - 1) * (1 - p) ^ (2 * n - 3) := by
  have hrw : (fun s : Finset (Edge n) => (avoidCount (fun v : Fin n => incident v) s)
        * (avoidCount (fun v : Fin n => incident v) s - 1))
      = fun s => (avoidCount (fun v : Fin n => incident v) s) ^ 2
          - avoidCount (fun v : Fin n => incident v) s := by
    funext s; ring
  rw [hrw, Expect_sub, expect_isolated_count_sq hn, expect_isolated_count]
  ring

/-! ## 5. The quantitative bound and the threshold -/

/-- Connectivity is contained in the event that the isolated-vertex count vanishes. -/
lemma prob_connected_le_probZero {n : ℕ} (hn : 2 ≤ n) {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    Prob p (Finset.univ.filter (fun s : Finset (Edge n) => (graphOf s).Connected))
      ≤ probZero p (avoidCount (fun v : Fin n => incident v)) := by
  classical
  unfold Prob probZero
  refine Finset.sum_le_sum_of_subset_of_nonneg ?_ (fun s _ _ => mass_nonneg hp0 hp1 s)
  intro s hs
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hs ⊢
  exact avoidCount_incident_eq_zero_of_connected hn hs

/-- **Chebyshev bound for the absence of isolated vertices.**  For `0 ≤ p < 1` and
`n ≥ 2`, the probability that `G(n,p)` has *no* isolated vertex is at most
`1/(n (1-p)^{n-1}) + p/(1-p)`, where `n (1-p)^{n-1}` is exactly the expected number of
isolated vertices. -/
theorem probZero_isolated_le {n : ℕ} (hn : 2 ≤ n) {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p < 1) :
    probZero p (avoidCount (fun v : Fin n => incident v))
      ≤ 1 / ((n : ℝ) * (1 - p) ^ (n - 1)) + p / (1 - p) := by
  classical
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 2 := ⟨n - 2, by omega⟩
  set q : ℝ := 1 - p with hqdef
  have hq0 : 0 < q := by simp only [hqdef]; linarith
  have hn1 : m + 2 - 1 = m + 1 := by omega
  have hn2 : 2 * (m + 2) - 3 = 2 * m + 1 := by omega
  set X : Finset (Edge (m + 2)) → ℝ :=
    avoidCount (fun v : Fin (m + 2) => incident v) with hXdef
  have hq1 : q ^ (m + 1) = q * q ^ m := by rw [pow_succ]; ring
  have hq2 : q ^ (2 * m + 1) = q * (q ^ m) ^ 2 := by rw [pow_succ, pow_mul]; ring
  -- first moment: the expected number of isolated vertices
  have hEX : Expect p X = ((m : ℝ) + 2) * (q * q ^ m) := by
    rw [hXdef, expect_isolated_count, hn1, hq1]
    push_cast
    ring
  -- second moment: diagonal plus off-diagonal overlap terms
  have hEX2 : Expect p (fun s => (X s) ^ 2)
      = ((m : ℝ) + 2) * (q * q ^ m) + ((m : ℝ) + 2) * ((m : ℝ) + 1) * (q * (q ^ m) ^ 2) := by
    rw [hXdef, expect_isolated_count_sq (by omega), hn1, hn2, hq1, hq2]
    push_cast
    ring
  have hQ0 : (0 : ℝ) < q ^ m := pow_pos hq0 m
  have hEXpos : 0 < Expect p X := by
    rw [hEX]; positivity
  have hcheb := prob_eq_zero_le_variance_div_sq (p := p) hp0 (le_of_lt hp1) X (ne_of_gt hEXpos)
  rw [hXdef]
  refine le_trans hcheb ?_
  rw [variance_eq_sub, hEX, hEX2, div_le_iff₀ (by positivity)]
  have hcast : ((m + 2 : ℕ) : ℝ) = (m : ℝ) + 2 := by push_cast; ring
  rw [hn1, hcast]
  have hp : p = 1 - q := by simp [hqdef]
  rw [hp]
  have hexp : (1 : ℝ) / (((m : ℝ) + 2) * q ^ (m + 1)) = 1 / (((m : ℝ) + 2) * (q * q ^ m)) := by
    rw [pow_succ]; ring_nf
  rw [hexp]
  rw [div_add_div _ _ (by positivity) (by positivity), div_mul_eq_mul_div, le_div_iff₀ (by positivity)]
  nlinarith [sq_nonneg (q ^ m), mul_pos hq0 hQ0, sq_nonneg q, hQ0, hq0,
    mul_pos (mul_pos hq0 hQ0) hQ0, Nat.cast_nonneg (α := ℝ) m]

/-- **Chebyshev bound for connectivity.**  Connectivity forces the absence of isolated
vertices, so the bound of `probZero_isolated_le` applies verbatim. -/
theorem prob_connected_le {n : ℕ} (hn : 2 ≤ n) {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p < 1) :
    Prob p (Finset.univ.filter (fun s : Finset (Edge n) => (graphOf s).Connected))
      ≤ 1 / ((n : ℝ) * (1 - p) ^ (n - 1)) + p / (1 - p) :=
  le_trans (prob_connected_le_probZero hn hp0 (le_of_lt hp1)) (probZero_isolated_le hn hp0 hp1)

/-- Nonnegativity of `probZero`. -/
lemma probZero_nonneg {α : Type*} [Fintype α] [DecidableEq α] {p : ℝ} (hp0 : 0 ≤ p)
    (hp1 : p ≤ 1) (X : Finset α → ℝ) : 0 ≤ probZero p X :=
  Finset.sum_nonneg fun s _ => mass_nonneg hp0 hp1 s

/-- **Subcritical threshold for isolated vertices.**  If the edge probability tends to
`0` while the expected number of isolated vertices `n (1-p)^{n-1}` tends to `∞`, then
a.a.s. `G(n, pₙ)` *has* an isolated vertex: the probability of having none tends to
`0`. -/
theorem probZero_isolated_tendsto_zero (p : ℕ → ℝ) (hp0 : ∀ n, 0 ≤ p n) (hp1 : ∀ n, p n < 1)
    (hp : Tendsto p atTop (𝓝 0))
    (hE : Tendsto (fun n : ℕ => (n : ℝ) * (1 - p n) ^ (n - 1)) atTop atTop) :
    Tendsto
      (fun n : ℕ => probZero (p n) (avoidCount (fun v : Fin n => incident v)))
      atTop (𝓝 0) := by
  classical
  have hinv : Tendsto (fun n : ℕ => 1 / ((n : ℝ) * (1 - p n) ^ (n - 1))) atTop (𝓝 0) := by
    simpa only [one_div] using hE.inv_tendsto_atTop
  have hratio : Tendsto (fun n : ℕ => p n / (1 - p n)) atTop (𝓝 0) := by
    have hden : Tendsto (fun n : ℕ => 1 - p n) atTop (𝓝 1) := by
      simpa using (tendsto_const_nhds (x := (1 : ℝ)) (f := atTop (α := ℕ))).sub hp
    simpa using hp.div hden one_ne_zero
  have hsum := hinv.add hratio
  rw [add_zero] at hsum
  refine squeeze_zero' (Filter.Eventually.of_forall fun n => ?_) ?_ hsum
  · exact probZero_nonneg (hp0 n) (le_of_lt (hp1 n)) _
  · filter_upwards [Filter.eventually_ge_atTop 2] with n hn
    exact probZero_isolated_le hn (hp0 n) (hp1 n)

/-- **Subcritical connectivity threshold.**  Under the same hypotheses `G(n, pₙ)` is
a.a.s. disconnected, since connectivity forbids isolated vertices. -/
theorem prob_connected_tendsto_zero (p : ℕ → ℝ) (hp0 : ∀ n, 0 ≤ p n) (hp1 : ∀ n, p n < 1)
    (hp : Tendsto p atTop (𝓝 0))
    (hE : Tendsto (fun n : ℕ => (n : ℝ) * (1 - p n) ^ (n - 1)) atTop atTop) :
    Tendsto
      (fun n : ℕ => Prob (p n)
        (Finset.univ.filter (fun s : Finset (Edge n) => (graphOf s).Connected)))
      atTop (𝓝 0) := by
  classical
  refine squeeze_zero' (Filter.Eventually.of_forall fun n => ?_) ?_
    (probZero_isolated_tendsto_zero p hp0 hp1 hp hE)
  · exact Prob_nonneg (hp0 n) (le_of_lt (hp1 n)) _
  · filter_upwards [Filter.eventually_ge_atTop 2] with n hn
    exact prob_connected_le_probZero hn (hp0 n) (le_of_lt (hp1 n))

/-! ## 6. The classical regime `p = c·log n / n` with `0 < c < 1` -/

/-- `c·log n / n → 0`: the connectivity scale is `o(1)`. -/
lemma tendsto_c_log_div (c : ℝ) :
    Tendsto (fun n : ℕ => c * Real.log n / n) atTop (𝓝 0) := by
  have h := Real.tendsto_pow_log_div_mul_add_atTop 1 0 1 one_ne_zero
  simp only [pow_one, one_mul, add_zero] at h
  have := (h.comp tendsto_natCast_atTop_atTop).const_mul c
  simpa [mul_div_assoc] using this

/-- **Divergence of the expected number of isolated vertices below the threshold.**
For `p = c·log n / n` with `0 < c < 1` the expectation `n (1-p)^{n-1}` tends to `∞`
(indeed it is eventually at least `n^{(1-c)/2}`). -/
lemma tendsto_expected_isolated_atTop {c : ℝ} (hc0 : 0 < c) (hc1 : c < 1) :
    Tendsto (fun n : ℕ => (n : ℝ) * (1 - c * Real.log n / n) ^ (n - 1)) atTop atTop := by
  set d : ℝ := (1 - c) / 2 with hd
  have hd0 : 0 < d := by simp only [hd]; linarith
  have hcd : c + d = 1 - d := by simp only [hd]; ring
  have hx0 : Tendsto (fun n : ℕ => c * Real.log n / n) atTop (𝓝 0) := tendsto_c_log_div c
  have hcdpos : 0 < c + d := by linarith
  have hsmall : ∀ᶠ n : ℕ in atTop, c * Real.log n / n ≤ d / (c + d) := by
    have hpos : 0 < d / (c + d) := by positivity
    exact (hx0.eventually (eventually_le_nhds hpos)).mono (fun n hn => hn)
  have key : ∀ᶠ n : ℕ in atTop,
      Real.exp (d * Real.log n) ≤ (n : ℝ) * (1 - c * Real.log n / n) ^ (n - 1) := by
    filter_upwards [hsmall, Filter.eventually_ge_atTop 2] with n hn hn2
    have hn2' : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn2
    have hnpos : (0 : ℝ) < n := by linarith
    have hlogn : 0 ≤ Real.log n := Real.log_nonneg (by linarith)
    set x : ℝ := c * Real.log n / n with hxdef
    have hx_nonneg : 0 ≤ x := by positivity
    have hxlt : x < 1 := by
      refine lt_of_le_of_lt hn ?_
      rw [div_lt_one hcdpos]; linarith
    have hq0 : 0 < 1 - x := by linarith
    have hne : (1 : ℝ) - x ≠ 0 := ne_of_gt hq0
    -- `log (1-x) ≥ -x/(1-x)`, the sharp elementary logarithm bound
    have hlogq : -(x / (1 - x)) ≤ Real.log (1 - x) := by
      have h := Real.log_le_sub_one_of_pos (x := (1 - x)⁻¹) (by positivity)
      rw [Real.log_inv] at h
      have he : (1 - x)⁻¹ - 1 = x / (1 - x) := by field_simp; ring
      rw [he] at h
      linarith
    have hlogq_nonpos : Real.log (1 - x) ≤ 0 := Real.log_nonpos (by linarith) (by linarith)
    have hcq : c ≤ (1 - d) * (1 - x) := by
      have hxle : (c + d) * x ≤ d := by
        have h5 := mul_le_mul_of_nonneg_left hn (le_of_lt hcdpos)
        have h6 : (c + d) * (d / (c + d)) = d := by field_simp
        linarith
      nlinarith
    have hnx : (n : ℝ) * x = c * Real.log n := by
      rw [hxdef]; field_simp
    have hkey : -((1 - d) * Real.log n) ≤ ((n : ℝ) - 1) * Real.log (1 - x) := by
      have h1 : (n : ℝ) * Real.log (1 - x) ≤ ((n : ℝ) - 1) * Real.log (1 - x) := by nlinarith
      have h3 : (n : ℝ) * (-(x / (1 - x))) ≤ (n : ℝ) * Real.log (1 - x) :=
        mul_le_mul_of_nonneg_left hlogq (le_of_lt hnpos)
      have h4 : -((1 - d) * Real.log n) ≤ (n : ℝ) * (-(x / (1 - x))) := by
        rw [mul_neg, ← mul_div_assoc, hnx, neg_le_neg_iff, div_le_iff₀ hq0]
        nlinarith
      linarith
    have hcast : ((n : ℝ) - 1) = ((n - 1 : ℕ) : ℝ) := by
      have h1n : (1 : ℕ) ≤ n := by omega
      push_cast [Nat.cast_sub h1n]; ring
    have hpow : (1 - x) ^ (n - 1) = Real.exp (((n : ℝ) - 1) * Real.log (1 - x)) := by
      rw [hcast, Real.exp_nat_mul, Real.exp_log hq0]
    have hprod : (n : ℝ) * Real.exp (((n : ℝ) - 1) * Real.log (1 - x))
        = Real.exp (Real.log n + ((n : ℝ) - 1) * Real.log (1 - x)) := by
      rw [Real.exp_add, Real.exp_log hnpos]
    rw [hpow, hprod]
    exact Real.exp_le_exp.mpr (by linarith)
  exact tendsto_atTop_mono' atTop key
    (Real.tendsto_exp_atTop.comp
      (Filter.Tendsto.const_mul_atTop hd0
        (Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop)))

/-- **The connectivity threshold from below.**  For every `0 < c < 1`, the
Erdős–Rényi graph `G(n, c·log n/n)` is asymptotically almost surely *disconnected*:
the probability of connectivity tends to `0`.  Together with the classical
upper-threshold statement this pins the connectivity threshold at `log n / n`. -/
theorem prob_connected_log_tendsto_zero {c : ℝ} (hc0 : 0 < c) (hc1 : c < 1) :
    Tendsto
      (fun n : ℕ => Prob (c * Real.log n / n)
        (Finset.univ.filter (fun s : Finset (Edge n) => (graphOf s).Connected)))
      atTop (𝓝 0) := by
  have hp0 : ∀ n : ℕ, 0 ≤ c * Real.log n / n := by
    intro n
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · simp
    · have h1 : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
      have : 0 ≤ Real.log n := Real.log_nonneg h1
      positivity
  have hp1 : ∀ n : ℕ, c * Real.log n / n < 1 := by
    intro n
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · simp
    · have hnpos : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
      have hlog : Real.log n ≤ (n : ℝ) - 1 := Real.log_le_sub_one_of_pos hnpos
      have hlog0 : 0 ≤ Real.log n := Real.log_nonneg (by exact_mod_cast hn)
      rw [div_lt_one hnpos]
      nlinarith
  exact prob_connected_tendsto_zero _ hp0 hp1 (tendsto_c_log_div c)
    (tendsto_expected_isolated_atTop hc0 hc1)

/-! ## 7. Above the threshold: the isolated-vertex obstruction disappears

The matching *first-moment* half.  For `p = c·log n/n` with `c > 1` the expected number
of isolated vertices tends to `0`, so a.a.s. `G(n,p)` has **no** isolated vertex — the
unique obstruction to connectivity at this density. -/

omit [DecidableEq α] in
/-- **Markov's inequality** in the finite `G(n,p)` model: an event on which a
nonnegative random variable is at least `1` has probability at most its expectation. -/
lemma prob_le_expect_of_one_le {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (X : Finset α → ℝ)
    (hX : ∀ s, 0 ≤ X s) (E : Finset (Finset α)) (hE : ∀ s ∈ E, 1 ≤ X s) :
    Prob p E ≤ Expect p X := by
  unfold Prob Expect
  calc ∑ s ∈ E, mass p s
      ≤ ∑ s ∈ E, mass p s * X s :=
        Finset.sum_le_sum fun s hs =>
          le_mul_of_one_le_right (mass_nonneg hp0 hp1 s) (hE s hs)
    _ ≤ ∑ s : Finset α, mass p s * X s :=
        Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ E)
          (fun s _ _ => mul_nonneg (mass_nonneg hp0 hp1 s) (hX s))

/-- **First moment bound for isolated vertices.**  The probability that `G(n,p)` has an
isolated vertex is at most `n (1-p)^{n-1}`. -/
theorem prob_exists_isolated_le {n : ℕ} {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    Prob p (Finset.univ.filter
        (fun s : Finset (Edge n) => ∃ v : Fin n, Disjoint s (incident v)))
      ≤ (n : ℝ) * (1 - p) ^ (n - 1) := by
  classical
  have hXnonneg : ∀ s : Finset (Edge n),
      0 ≤ avoidCount (fun v : Fin n => incident v) s :=
    fun s => Finset.sum_nonneg fun v _ => by positivity
  have hE : ∀ s ∈ Finset.univ.filter
      (fun s : Finset (Edge n) => ∃ v : Fin n, Disjoint s (incident v)),
      1 ≤ avoidCount (fun v : Fin n => incident v) s := by
    intro s hs
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hs
    obtain ⟨v, hv⟩ := hs
    have hterm : (if Disjoint s (incident v) then (1 : ℝ) else 0) = 1 := if_pos hv
    calc (1 : ℝ) = (if Disjoint s (incident v) then (1 : ℝ) else 0) := hterm.symm
      _ ≤ avoidCount (fun v : Fin n => incident v) s :=
        Finset.single_le_sum (f := fun v : Fin n =>
          if Disjoint s (incident v) then (1 : ℝ) else 0)
          (fun w _ => by positivity) (Finset.mem_univ v)
  refine le_trans (prob_le_expect_of_one_le hp0 hp1 _ hXnonneg _ hE) ?_
  rw [expect_avoidCount]
  simp only [card_incident]
  rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]

/-- For `p = c·log n/n` with `c > 1` the expected number of isolated vertices vanishes
asymptotically. -/
lemma tendsto_expected_isolated_zero {c : ℝ} (hc : 1 < c) :
    Tendsto (fun n : ℕ => (n : ℝ) * (1 - c * Real.log n / n) ^ (n - 1)) atTop (𝓝 0) := by
  have hgoal : Tendsto (fun n : ℕ => Real.exp (1 + (1 - c) * Real.log n)) atTop (𝓝 0) := by
    refine Real.tendsto_exp_atBot.comp ?_
    have h1 : Tendsto (fun n : ℕ => (1 - c) * Real.log n) atTop atBot :=
      Filter.Tendsto.const_mul_atTop_of_neg (by linarith)
        (Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop)
    exact tendsto_atBot_add_const_left _ 1 h1
  have hple : ∀ᶠ n : ℕ in atTop, c * Real.log n / n ≤ 1 :=
    (tendsto_c_log_div c).eventually (eventually_le_nhds one_pos)
  refine squeeze_zero' ?_ ?_ hgoal
  · filter_upwards [Filter.eventually_ge_atTop 2, hple] with n hn2 hx
    have hn2' : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn2
    have hlog : 0 ≤ Real.log n := Real.log_nonneg (by linarith)
    have : 0 ≤ 1 - c * Real.log n / n := by linarith
    positivity
  · filter_upwards [Filter.eventually_ge_atTop 2, hple] with n hn2 hx1'
    have hn2' : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn2
    have hnpos : (0 : ℝ) < n := by linarith
    have hlog : 0 ≤ Real.log n := Real.log_nonneg (by linarith)
    set x : ℝ := c * Real.log n / n with hxdef
    have hx0 : 0 ≤ x := by positivity
    have hx1 : x ≤ 1 := hx1'
    have hnx : (n : ℝ) * x = c * Real.log n := by rw [hxdef]; field_simp
    rcases eq_or_lt_of_le hx1 with hxe | hxlt
    · -- degenerate case `x = 1`: the power is `0`, the bound is positive
      have : (1 : ℝ) - x = 0 := by rw [hxe]; ring
      rw [this, zero_pow (by omega)]
      simp only [mul_zero]
      positivity
    · have hq0 : 0 < 1 - x := by linarith
      have hlogq : Real.log (1 - x) ≤ -x := by
        have h := Real.log_le_sub_one_of_pos hq0
        linarith
      have hcast : ((n : ℝ) - 1) = ((n - 1 : ℕ) : ℝ) := by
        have h1n : (1 : ℕ) ≤ n := by omega
        push_cast [Nat.cast_sub h1n]; ring
      have hpow : (1 - x) ^ (n - 1) = Real.exp (((n : ℝ) - 1) * Real.log (1 - x)) := by
        rw [hcast, Real.exp_nat_mul, Real.exp_log hq0]
      have hprod : (n : ℝ) * Real.exp (((n : ℝ) - 1) * Real.log (1 - x))
          = Real.exp (Real.log n + ((n : ℝ) - 1) * Real.log (1 - x)) := by
        rw [Real.exp_add, Real.exp_log hnpos]
      rw [hpow, hprod]
      refine Real.exp_le_exp.mpr ?_
      have hstep : ((n : ℝ) - 1) * Real.log (1 - x) ≤ ((n : ℝ) - 1) * (-x) :=
        mul_le_mul_of_nonneg_left hlogq (by linarith)
      have : ((n : ℝ) - 1) * (-x) = -(c * Real.log n) + x := by
        rw [← hnx]; ring
      linarith [hstep, this]

/-- **No isolated vertices above the threshold.**  For every `c > 1` the probability
that `G(n, c·log n/n)` contains an isolated vertex tends to `0`.  Combined with
`prob_connected_log_tendsto_zero`, this identifies `log n / n` as the location where the
isolated-vertex obstruction to connectivity disappears. -/
theorem prob_exists_isolated_tendsto_zero {c : ℝ} (hc : 1 < c) :
    Tendsto
      (fun n : ℕ => Prob (c * Real.log n / n)
        (Finset.univ.filter
          (fun s : Finset (Edge n) => ∃ v : Fin n, Disjoint s (incident v))))
      atTop (𝓝 0) := by
  have hp0 : ∀ n : ℕ, 0 ≤ c * Real.log n / n := by
    intro n
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · simp
    · have h1 : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
      have : 0 ≤ Real.log n := Real.log_nonneg h1
      positivity
  have hple : ∀ᶠ n : ℕ in atTop, c * Real.log n / n ≤ 1 :=
    (tendsto_c_log_div c).eventually (eventually_le_nhds one_pos)
  refine squeeze_zero' ?_ ?_ (tendsto_expected_isolated_zero hc)
  · filter_upwards [hple] with n hp1
    exact Prob_nonneg (hp0 n) hp1 _
  · filter_upwards [hple] with n hp1
    exact prob_exists_isolated_le (hp0 n) hp1

/-! ## 8. The sharp threshold for isolated vertices at `log n / n` -/

omit [DecidableEq α] in
/-- Complementary events have complementary probabilities. -/
lemma Prob_add_Prob_not (p : ℝ) (P : Finset α → Prop) [DecidablePred P] :
    Prob p (Finset.univ.filter P) + Prob p (Finset.univ.filter (fun s => ¬ P s)) = 1 := by
  unfold Prob
  rw [Finset.sum_filter_add_sum_filter_not]
  exact total_mass p

omit [Fintype α] in
/-- A count of avoided blocks vanishes exactly when no block is avoided. -/
lemma avoidCount_eq_zero_iff {ι : Type*} [Fintype ι] (B : ι → Finset α) (s : Finset α) :
    avoidCount B s = 0 ↔ ∀ i, ¬ Disjoint s (B i) := by
  rw [avoidCount, Finset.sum_eq_zero_iff_of_nonneg (fun i _ => by positivity)]
  constructor
  · intro h i hdis
    have hi := h i (Finset.mem_univ i)
    rw [if_pos hdis] at hi
    exact one_ne_zero hi
  · intro h i _
    exact if_neg (h i)

/-- The probability of having an isolated vertex is `1 - P(no isolated vertex)`. -/
theorem prob_exists_isolated_eq (n : ℕ) (p : ℝ) :
    Prob p (Finset.univ.filter
        (fun s : Finset (Edge n) => ∃ v : Fin n, Disjoint s (incident v)))
      = 1 - probZero p (avoidCount (fun v : Fin n => incident v)) := by
  classical
  have h := Prob_add_Prob_not (α := Edge n) p
    (fun s : Finset (Edge n) => ∃ v : Fin n, Disjoint s (incident v))
  have hset : (Finset.univ.filter
        (fun s : Finset (Edge n) => ¬ ∃ v : Fin n, Disjoint s (incident v)))
      = Finset.univ.filter
        (fun s : Finset (Edge n) => avoidCount (fun v : Fin n => incident v) s = 0) := by
    ext s
    simp only [Finset.mem_filter, Finset.mem_univ, true_and,
      avoidCount_eq_zero_iff, not_exists]
  rw [hset] at h
  have hpz : probZero p (avoidCount (fun v : Fin n => incident v))
      = Prob p (Finset.univ.filter
          (fun s : Finset (Edge n) => avoidCount (fun v : Fin n => incident v) s = 0)) := rfl
  rw [hpz]
  linarith

/-- **Isolated vertices below the threshold.**  For `0 < c < 1` the graph
`G(n, c·log n/n)` a.a.s. *has* an isolated vertex. -/
theorem prob_exists_isolated_tendsto_one {c : ℝ} (hc0 : 0 < c) (hc1 : c < 1) :
    Tendsto
      (fun n : ℕ => Prob (c * Real.log n / n)
        (Finset.univ.filter
          (fun s : Finset (Edge n) => ∃ v : Fin n, Disjoint s (incident v))))
      atTop (𝓝 1) := by
  have hp0 : ∀ n : ℕ, 0 ≤ c * Real.log n / n := by
    intro n
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · simp
    · have h1 : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
      have : 0 ≤ Real.log n := Real.log_nonneg h1
      positivity
  have hp1 : ∀ n : ℕ, c * Real.log n / n < 1 := by
    intro n
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · simp
    · have hnpos : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
      have hlog : Real.log n ≤ (n : ℝ) - 1 := Real.log_le_sub_one_of_pos hnpos
      have hlog0 : 0 ≤ Real.log n := Real.log_nonneg (by exact_mod_cast hn)
      rw [div_lt_one hnpos]
      nlinarith
  have hzero := probZero_isolated_tendsto_zero _ hp0 hp1 (tendsto_c_log_div c)
    (tendsto_expected_isolated_atTop hc0 hc1)
  have hlim := (tendsto_const_nhds (x := (1 : ℝ)) (f := atTop (α := ℕ))).sub hzero
  rw [sub_zero] at hlim
  exact hlim.congr (fun n => (prob_exists_isolated_eq n (c * Real.log n / n)).symm)

/-- **The sharp threshold for isolated vertices at `p = log n / n`.**  For
`p = c·log n/n`, the probability that `G(n,p)` has an isolated vertex tends to `1` when
`c < 1` and to `0` when `c > 1`.  Isolated vertices are the obstruction that drives the
connectivity threshold. -/
theorem isolated_vertex_sharp_threshold :
    (∀ c : ℝ, 0 < c → c < 1 →
        Tendsto (fun n : ℕ => Prob (c * Real.log n / n)
          (Finset.univ.filter
            (fun s : Finset (Edge n) => ∃ v : Fin n, Disjoint s (incident v))))
          atTop (𝓝 1))
      ∧ (∀ c : ℝ, 1 < c →
        Tendsto (fun n : ℕ => Prob (c * Real.log n / n)
          (Finset.univ.filter
            (fun s : Finset (Edge n) => ∃ v : Fin n, Disjoint s (incident v))))
          atTop (𝓝 0)) :=
  ⟨fun _ hc0 hc1 => prob_exists_isolated_tendsto_one hc0 hc1,
   fun _ hc => prob_exists_isolated_tendsto_zero hc⟩

end ErdosRenyi