/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Cut bounds and the supercritical half of the connectivity threshold

This file complements `Probability.ErdosRenyiConnectivityLower` (which proves that
`G(n, c·log n/n)` is a.a.s. *disconnected* for `c < 1`) with the *upper* half of the
threshold picture.

The mechanism is the classical **cut union bound**: a disconnected graph has a vertex
set `S` with `1 ≤ |S| ≤ n/2` across whose boundary no edge is present; the boundary of
`S` consists of `|S|·(n-|S|)` potential edges, each absent with probability `1-p`
independently.  Hence

`P(G(n,p) disconnected) ≤ ∑_{1 ≤ |S| ≤ n/2} (1-p)^{|S|(n-|S|)}`.

Feeding this into an entropy bound for binomial coefficients (`C(n,k) ≤ (e n/k)^k`,
via Stirling) and a geometric-series estimate gives the asymptotic statement: for
`p = c·log n/n` with `c > 1` the graph `G(n,p)` is a.a.s. **connected**.  Together with
`ErdosRenyi.prob_connected_log_tendsto_zero` (a.a.s. disconnected for `c < 1`) this
establishes the **sharp connectivity threshold at `p = log n / n`**, recorded in
`ErdosRenyi.connectivity_sharp_threshold`.
-/
import Probability.ErdosRenyiConnectivityLower

open Finset BigOperators Filter Topology
open scoped Classical

namespace ErdosRenyi

/-! ## 1. Boundary (cut) edge sets -/

/-- The set of potential edges crossing the cut `(S, Sᶜ)`. -/
noncomputable def cutEdges {n : ℕ} (S : Finset (Fin n)) : Finset (Edge n) :=
  Finset.univ.filter (fun e => ∃ a ∈ S, ∃ b ∉ S, (e : Sym2 (Fin n)) = s(a, b))

/-- The cut is symmetric under complementation. -/
lemma cutEdges_compl {n : ℕ} (S : Finset (Fin n)) : cutEdges Sᶜ = cutEdges S := by
  ext e
  simp only [cutEdges, Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_compl,
    not_not]
  constructor
  · rintro ⟨a, ha, b, hb, hab⟩
    exact ⟨b, hb, a, ha, by rw [hab, Sym2.eq_swap]⟩
  · rintro ⟨a, ha, b, hb, hab⟩
    exact ⟨b, hb, a, ha, by rw [hab, Sym2.eq_swap]⟩

/-- The cut across `S` contains at least `|S|·|Sᶜ|` potential edges (in fact exactly
that many). -/
lemma card_cutEdges_ge {n : ℕ} (S : Finset (Fin n)) :
    S.card * Sᶜ.card ≤ (cutEdges S).card := by
  classical
  have hinj : Function.Injective (fun e : Edge n => (e : Sym2 (Fin n))) := Subtype.val_injective
  have h1 : (cutEdges S).card
      = ((cutEdges S).image (fun e : Edge n => (e : Sym2 (Fin n)))).card :=
    (Finset.card_image_of_injective _ hinj).symm
  rw [← Finset.card_product, h1]
  apply Finset.card_le_card_of_injOn (fun ab : Fin n × Fin n => s(ab.1, ab.2))
  · rintro ⟨a, b⟩ hab
    rw [Finset.mem_coe, Finset.mem_product, Finset.mem_compl] at hab
    simp only [Finset.mem_coe, Finset.mem_image]
    refine ⟨⟨s(a, b), ?_⟩, ?_, rfl⟩
    · simp only [Sym2.isDiag_iff_proj_eq]
      rintro rfl
      exact hab.2 hab.1
    · simp only [cutEdges, Finset.mem_filter, Finset.mem_univ, true_and]
      exact ⟨a, hab.1, b, hab.2, rfl⟩
  · rintro ⟨a, b⟩ hab ⟨a', b'⟩ hab' heq
    rw [Finset.mem_coe, Finset.mem_product, Finset.mem_compl] at hab hab'
    simp only [Sym2.eq_iff] at heq
    rcases heq with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
    · rfl
    · exact absurd hab.1 hab'.2

/-- **The cut across `S` has exactly `|S|·|Sᶜ|` potential edges.** -/
lemma card_cutEdges {n : ℕ} (S : Finset (Fin n)) :
    (cutEdges S).card = S.card * Sᶜ.card := by
  classical
  refine le_antisymm ?_ (card_cutEdges_ge S)
  have hinj : Function.Injective (fun e : Edge n => (e : Sym2 (Fin n))) := Subtype.val_injective
  have h1 : (cutEdges S).card
      = ((cutEdges S).image (fun e : Edge n => (e : Sym2 (Fin n)))).card :=
    (Finset.card_image_of_injective _ hinj).symm
  have hsub : (cutEdges S).image (fun e : Edge n => (e : Sym2 (Fin n)))
      ⊆ (S ×ˢ Sᶜ).image (fun ab : Fin n × Fin n => s(ab.1, ab.2)) := by
    intro x hx
    rw [Finset.mem_image] at hx
    obtain ⟨e, he, rfl⟩ := hx
    simp only [cutEdges, Finset.mem_filter, Finset.mem_univ, true_and] at he
    obtain ⟨a, ha, b, hb, hab⟩ := he
    exact Finset.mem_image.mpr
      ⟨(a, b), Finset.mem_product.mpr ⟨ha, Finset.mem_compl.mpr hb⟩, hab.symm⟩
  calc (cutEdges S).card
      = ((cutEdges S).image (fun e : Edge n => (e : Sym2 (Fin n)))).card := h1
    _ ≤ ((S ×ˢ Sᶜ).image (fun ab : Fin n × Fin n => s(ab.1, ab.2))).card :=
        Finset.card_le_card hsub
    _ ≤ (S ×ˢ Sᶜ).card := Finset.card_image_le
    _ = S.card * Sᶜ.card := Finset.card_product S Sᶜ

/-! ## 2. A disconnected graph has an empty small cut -/

/-- If `graphOf s` is disconnected then some vertex set `S` with `1 ≤ |S| ≤ n/2` has no
present edge across its boundary. -/
lemma exists_small_empty_cut {n : ℕ} (hn : 1 ≤ n) {s : Finset (Edge n)}
    (h : ¬ (graphOf s).Connected) :
    ∃ S : Finset (Fin n), S.Nonempty ∧ S.card ≤ n / 2 ∧ Disjoint s (cutEdges S) := by
  classical
  have hne : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  have hpre : ¬ (graphOf s).Preconnected := fun hp => h ⟨hp⟩
  rw [SimpleGraph.Preconnected] at hpre
  push_neg at hpre
  obtain ⟨u, v, huv⟩ := hpre
  set T : Finset (Fin n) := Finset.univ.filter (fun w => (graphOf s).Reachable u w) with hT
  have huT : u ∈ T := by simp [hT]
  have hvT : v ∉ T := by simp [hT, huv]
  have hcut : Disjoint s (cutEdges T) := by
    rw [Finset.disjoint_right]
    intro e he hes
    obtain ⟨a, ha, b, hb, hab⟩ := (Finset.mem_filter.mp he).2
    have hab' : a ≠ b := by rintro rfl; exact hb ha
    have hadj : (graphOf s).Adj a b := by
      rw [graphOf, SimpleGraph.fromEdgeSet_adj]
      exact ⟨⟨e, hes, hab⟩, hab'⟩
    have hua : (graphOf s).Reachable u a := by
      have h2 := Finset.mem_filter.mp ha
      simpa [hT] using h2.2
    exact hb (by simp only [hT, Finset.mem_filter, Finset.mem_univ, true_and]
                 exact hua.trans hadj.reachable)
  by_cases hTsize : T.card ≤ n / 2
  · exact ⟨T, ⟨u, huT⟩, hTsize, hcut⟩
  · refine ⟨Tᶜ, ⟨v, by simpa using hvT⟩, ?_, by rwa [cutEdges_compl]⟩
    have hc : Tᶜ.card = n - T.card := by simp [Finset.card_compl]
    have hle : T.card ≤ n := by simpa using Finset.card_le_univ T
    omega

/-! ## 3. The cut union bound -/

/-- Monotonicity of `Prob`. -/
lemma Prob_mono {α : Type*} [Fintype α] [DecidableEq α] {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {E F : Finset (Finset α)} (h : E ⊆ F) : Prob p E ≤ Prob p F :=
  Finset.sum_le_sum_of_subset_of_nonneg h (fun s _ _ => mass_nonneg hp0 hp1 s)

/-- **Cut union bound.**  The probability that `G(n,p)` is disconnected is at most the
sum, over all vertex sets `S` with `1 ≤ |S| ≤ n/2`, of `(1-p)^{|S|(n-|S|)}`. -/
theorem prob_disconnected_le {n : ℕ} (hn : 1 ≤ n) {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    Prob p (Finset.univ.filter (fun s : Finset (Edge n) => ¬ (graphOf s).Connected))
      ≤ ∑ S ∈ (Finset.univ : Finset (Finset (Fin n))).filter
            (fun S => S.Nonempty ∧ S.card ≤ n / 2),
          (1 - p) ^ (S.card * (n - S.card)) := by
  classical
  set F := (Finset.univ : Finset (Finset (Fin n))).filter
    (fun S => S.Nonempty ∧ S.card ≤ n / 2) with hF
  have hsub : Finset.univ.filter (fun s : Finset (Edge n) => ¬ (graphOf s).Connected)
      ⊆ F.biUnion (fun S => Finset.univ.filter (fun s => Disjoint s (cutEdges S))) := by
    intro s hs
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hs
    obtain ⟨S, hS1, hS2, hS3⟩ := exists_small_empty_cut hn hs
    exact Finset.mem_biUnion.mpr
      ⟨S, by simp only [hF, Finset.mem_filter, Finset.mem_univ, true_and]; exact ⟨hS1, hS2⟩,
        by simp only [Finset.mem_filter, Finset.mem_univ, true_and]; exact hS3⟩
  calc Prob p (Finset.univ.filter (fun s : Finset (Edge n) => ¬ (graphOf s).Connected))
      ≤ Prob p (F.biUnion (fun S => Finset.univ.filter (fun s => Disjoint s (cutEdges S)))) :=
        Prob_mono hp0 hp1 hsub
    _ ≤ ∑ S ∈ F, Prob p (Finset.univ.filter (fun s => Disjoint s (cutEdges S))) :=
        union_bound hp0 hp1 F _
    _ = ∑ S ∈ F, (1 - p) ^ (cutEdges S).card := by
        exact Finset.sum_congr rfl fun S _ => prob_avoids p (cutEdges S)
    _ ≤ ∑ S ∈ F, (1 - p) ^ (S.card * (n - S.card)) := by
        refine Finset.sum_le_sum fun S _ => ?_
        have hcard : S.card * (n - S.card) ≤ (cutEdges S).card := by
          have h := card_cutEdges_ge S
          have hc : Sᶜ.card = n - S.card := by simp [Finset.card_compl]
          rwa [hc] at h
        exact pow_le_pow_of_le_one (by linarith) (by linarith) hcard

/-! ## 4. Summing the cut bound -/

/-- Grouping the cut bound by the size of the cut side. -/
lemma sum_over_small_sets (n : ℕ) (f : ℕ → ℝ) :
    ∑ S ∈ (Finset.univ : Finset (Finset (Fin n))).filter
        (fun S => S.Nonempty ∧ S.card ≤ n / 2), f S.card
      = ∑ k ∈ Finset.Icc 1 (n / 2), (n.choose k : ℝ) * f k := by
  classical
  have hset : (Finset.univ : Finset (Finset (Fin n))).filter
        (fun S => S.Nonempty ∧ S.card ≤ n / 2)
      = (Finset.Icc 1 (n / 2)).biUnion (fun k => (Finset.univ : Finset (Fin n)).powersetCard k) := by
    ext S
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_biUnion,
      Finset.mem_Icc, Finset.mem_powersetCard, Finset.subset_univ]
    constructor
    · rintro ⟨h1, h2⟩
      exact ⟨S.card, ⟨Finset.card_pos.mpr h1, h2⟩, rfl⟩
    · rintro ⟨k, ⟨hk1, hk2⟩, rfl⟩
      exact ⟨Finset.card_pos.mp (by omega), hk2⟩
  rw [hset, Finset.sum_biUnion]
  · refine Finset.sum_congr rfl fun k _ => ?_
    rw [Finset.sum_congr rfl (fun S hS => by rw [(Finset.mem_powersetCard.mp hS).2]),
      Finset.sum_const, Finset.card_powersetCard, Finset.card_univ, Fintype.card_fin,
      nsmul_eq_mul]
  · intro a _ b _ hab
    simp only [Function.onFun, Finset.disjoint_left]
    intro S hSa hSb
    exact hab (((Finset.mem_powersetCard.mp hSa).2).symm.trans (Finset.mem_powersetCard.mp hSb).2)

/-- Geometric bound for a partial geometric series. -/
lemma geom_partial_le {r : ℝ} (h0 : 0 ≤ r) (h1 : r < 1) (m : ℕ) :
    ∑ i ∈ Finset.range m, r ^ i ≤ (1 - r)⁻¹ := by
  have h := geom_sum_mul r m
  have hr : 0 ≤ r ^ m := by positivity
  rw [inv_eq_one_div, le_div_iff₀ (by linarith : (0 : ℝ) < 1 - r)]
  nlinarith [h]

/-- Geometric bound for the tail sum `∑_{k=1}^m r^k`. -/
lemma geom_Icc_le {r : ℝ} (h0 : 0 ≤ r) (h1 : r < 1) (m : ℕ) :
    ∑ k ∈ Finset.Icc 1 m, r ^ k ≤ r / (1 - r) := by
  have h : ∑ k ∈ Finset.Icc 1 m, r ^ k = r * ∑ k ∈ Finset.range m, r ^ k := by
    rw [Finset.mul_sum, ← Finset.Ico_add_one_right_eq_Icc, Finset.sum_Ico_eq_sum_range]
    exact Finset.sum_congr rfl fun i _ => by ring
  rw [h, div_eq_mul_inv]
  exact mul_le_mul_of_nonneg_left (geom_partial_le h0 h1 m) h0

/-- **Entropy bound for binomial coefficients**: `C(n,k) ≤ (e·n/k)^k`, in exponential
form.  Proved from `Nat.choose_le_pow_div` together with the Stirling lower bound for
`log k!`. -/
lemma choose_le_exp (n k : ℕ) (hk : 1 ≤ k) (hn : 1 ≤ n) :
    (n.choose k : ℝ) ≤ Real.exp (k * (1 + Real.log n - Real.log k)) := by
  have hkR : (0 : ℝ) < k := by exact_mod_cast hk
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hfac : Real.exp ((k : ℝ) * Real.log k - k) ≤ (k.factorial : ℝ) := by
    have h := Stirling.le_log_factorial_stirling (n := k) (by omega)
    have hlogk : 0 ≤ Real.log k := Real.log_nonneg (by exact_mod_cast hk)
    have hpi : 0 ≤ Real.log (2 * Real.pi) := Real.log_nonneg (by nlinarith [Real.pi_gt_three])
    have hle : (k : ℝ) * Real.log k - k ≤ Real.log (k.factorial) := by linarith
    calc Real.exp ((k : ℝ) * Real.log k - k) ≤ Real.exp (Real.log (k.factorial)) :=
          Real.exp_le_exp.mpr hle
      _ = (k.factorial : ℝ) := Real.exp_log (by positivity)
  have h1 : (n.choose k : ℝ) ≤ (n : ℝ) ^ k / (k.factorial : ℝ) := Nat.choose_le_pow_div k n
  refine le_trans h1 ?_
  rw [div_le_iff₀ (by positivity)]
  have h2 : (n : ℝ) ^ k = Real.exp ((k : ℝ) * Real.log n) := by
    rw [Real.exp_nat_mul, Real.exp_log hnR]
  rw [h2]
  calc Real.exp ((k : ℝ) * Real.log n)
      = Real.exp ((k : ℝ) * (1 + Real.log n - Real.log k))
          * Real.exp ((k : ℝ) * Real.log k - k) := by
        rw [← Real.exp_add]; ring_nf
    _ ≤ Real.exp ((k : ℝ) * (1 + Real.log n - Real.log k)) * (k.factorial : ℝ) :=
        mul_le_mul_of_nonneg_left hfac (le_of_lt (Real.exp_pos _))

/-- The heart of the sharp cut estimate: for `1 ≤ k ≤ n/2` the exponent

`1 + log n - log k - p(n-k)`  (with `p = c·log n/n`)

is at most `1 - δ·log n` where `δ = (c-1)/4 > 0`.  The two regimes `k ≤ ε n` and
`k > ε n`, with `ε = 3(c-1)/(4c)`, are treated separately: in the first the term
`c·k·log n/n` is small, in the second `log k` is already of order `log n`. -/
lemma cut_bracket_le {c : ℝ} (hc : 1 < c) {n k : ℕ} (hn2 : 2 ≤ n) (hk1 : 1 ≤ k)
    (hk2 : 2 * k ≤ n)
    (hbig : -Real.log (3 * (c - 1) / (4 * c)) ≤ (c + 1) / 4 * Real.log n) :
    1 + Real.log n - Real.log k - (c * Real.log n / n) * ((n : ℝ) - (k : ℝ))
      ≤ 1 - (c - 1) / 4 * Real.log n := by
  have hn2' : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn2
  have hnpos : (0 : ℝ) < n := by linarith
  have hlogn : 0 < Real.log n := Real.log_pos (by linarith)
  have hkR : (0 : ℝ) < k := by exact_mod_cast hk1
  have hlogk : 0 ≤ Real.log k := Real.log_nonneg (by exact_mod_cast hk1)
  have hkR2 : (2 : ℝ) * k ≤ n := by exact_mod_cast hk2
  set p : ℝ := c * Real.log n / n with hp
  have hpn : p * (n : ℝ) = c * Real.log n := by rw [hp]; field_simp
  set ε : ℝ := 3 * (c - 1) / (4 * c) with hε
  have hcpos : 0 < c := by linarith
  have hεpos : 0 < ε := by rw [hε]; apply div_pos <;> linarith
  have hpk : p * ((n : ℝ) - (k : ℝ)) = c * Real.log n - c * (k : ℝ) * Real.log n / n := by
    have hsplit : p * ((n : ℝ) - (k : ℝ)) = p * n - p * k := by ring
    rw [hsplit, hpn, hp]
    field_simp
  rw [hpk]
  rcases le_or_gt (k : ℝ) (ε * n) with hcase | hcase
  · have hkey : c * (k : ℝ) * Real.log n / n ≤ 3 * (c - 1) / 4 * Real.log n := by
      rw [div_le_iff₀ hnpos]
      have hck : c * (k : ℝ) ≤ c * (ε * n) := by nlinarith
      have hεn : c * (ε * n) = 3 * (c - 1) / 4 * n := by rw [hε]; field_simp
      have h9 : 0 ≤ (3 * (c - 1) / 4 * n - c * k) * Real.log n :=
        mul_nonneg (by linarith) hlogn.le
      nlinarith [h9]
    nlinarith [hlogk]
  · have hlogkge : Real.log ε + Real.log n ≤ Real.log k := by
      have h1' : Real.log (ε * n) ≤ Real.log k :=
        Real.log_le_log (by positivity) (le_of_lt hcase)
      rwa [Real.log_mul (ne_of_gt hεpos) (ne_of_gt hnpos)] at h1'
    have hkhalf : c * (k : ℝ) * Real.log n / n ≤ c / 2 * Real.log n := by
      rw [div_le_iff₀ hnpos]
      have h9 : 0 ≤ (c * Real.log n) * ((n : ℝ) / 2 - k) :=
        mul_nonneg (mul_pos hcpos hlogn).le (by linarith)
      nlinarith [h9]
    nlinarith

/-- **Sharp per-term cut estimate.**  For `1 < c`, `1 ≤ k ≤ n/2` and `n` large enough,
the `k`-th cut term is dominated by `ρ^k` with `ρ = e·n^{-(c-1)/4}`. -/
lemma sharp_cut_term_le {c : ℝ} (hc : 1 < c) {n k : ℕ} (hn2 : 2 ≤ n) (hk1 : 1 ≤ k)
    (hk2 : 2 * k ≤ n) (hp1 : c * Real.log n / n ≤ 1)
    (hbig : -Real.log (3 * (c - 1) / (4 * c)) ≤ (c + 1) / 4 * Real.log n) :
    (n.choose k : ℝ) * (1 - c * Real.log n / n) ^ (k * (n - k))
      ≤ (Real.exp (1 - (c - 1) / 4 * Real.log n)) ^ k := by
  have hn2' : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn2
  have hnpos : (0 : ℝ) < n := by linarith
  have hkR : (0 : ℝ) < k := by exact_mod_cast hk1
  have hkn : k ≤ n := by omega
  set p : ℝ := c * Real.log n / n with hp
  have hlog : 0 ≤ Real.log n := Real.log_nonneg (by linarith)
  have hp0 : 0 ≤ p := by rw [hp]; positivity
  have hq0 : 0 ≤ 1 - p := by linarith
  have hcast : ((k * (n - k) : ℕ) : ℝ) = (k : ℝ) * ((n : ℝ) - (k : ℝ)) := by
    push_cast [Nat.cast_sub hkn]; ring
  have h1 : (1 - p) ^ (k * (n - k)) ≤ Real.exp (-(p * ((k : ℝ) * ((n : ℝ) - (k : ℝ))))) := by
    have hq_exp : 1 - p ≤ Real.exp (-p) := by
      have := Real.add_one_le_exp (-p); linarith
    calc (1 - p) ^ (k * (n - k)) ≤ (Real.exp (-p)) ^ (k * (n - k)) :=
          pow_le_pow_left₀ hq0 hq_exp _
      _ = Real.exp (-(p * ((k : ℝ) * ((n : ℝ) - (k : ℝ))))) := by
          rw [← Real.exp_nat_mul, ← hcast]; ring_nf
  have hbracket := cut_bracket_le hc hn2 hk1 hk2 hbig
  have hchoose := choose_le_exp n k hk1 (by omega)
  calc (n.choose k : ℝ) * (1 - p) ^ (k * (n - k))
      ≤ Real.exp ((k : ℝ) * (1 + Real.log n - Real.log k))
          * Real.exp (-(p * ((k : ℝ) * ((n : ℝ) - (k : ℝ))))) :=
        mul_le_mul hchoose h1 (by positivity) (by positivity)
    _ = Real.exp ((k : ℝ) * (1 + Real.log n - Real.log k - p * ((n : ℝ) - (k : ℝ)))) := by
        rw [← Real.exp_add]; ring_nf
    _ ≤ Real.exp ((k : ℝ) * (1 - (c - 1) / 4 * Real.log n)) :=
        Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_left hbracket (le_of_lt hkR))
    _ = (Real.exp (1 - (c - 1) / 4 * Real.log n)) ^ k := by rw [Real.exp_nat_mul]

/-! ## 5. The supercritical half of the threshold -/

/-- If `δ > 0` then `ρ_n = exp(a - δ log n) → 0`, hence `ρ_n/(1-ρ_n) → 0`. -/
lemma tendsto_exp_ratio_zero (a : ℝ) {δ : ℝ} (hδ : 0 < δ) :
    Tendsto (fun n : ℕ => Real.exp (a - δ * Real.log n)
      / (1 - Real.exp (a - δ * Real.log n))) atTop (𝓝 0) := by
  have hr : Tendsto (fun n : ℕ => Real.exp (a - δ * Real.log n)) atTop (𝓝 0) := by
    refine Real.tendsto_exp_atBot.comp ?_
    have h1 : Tendsto (fun n : ℕ => -δ * Real.log n) atTop atBot :=
      Filter.Tendsto.const_mul_atTop_of_neg (by linarith)
        (Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop)
    have h2 := tendsto_atBot_add_const_left atTop a h1
    refine h2.congr (fun n => by ring)
  have hden : Tendsto (fun n : ℕ => 1 - Real.exp (a - δ * Real.log n)) atTop (𝓝 1) := by
    simpa using (tendsto_const_nhds (x := (1 : ℝ)) (f := atTop (α := ℕ))).sub hr
  simpa using hr.div hden one_ne_zero

/-- **Connectivity above the threshold.**  For every `c > 1` the probability that
`G(n, c·log n/n)` is disconnected tends to `0`.  This is the sharp complement of
`ErdosRenyi.prob_connected_log_tendsto_zero`. -/
theorem prob_disconnected_log_tendsto_zero {c : ℝ} (hc : 1 < c) :
    Tendsto
      (fun n : ℕ => Prob (c * Real.log n / n)
        (Finset.univ.filter (fun s : Finset (Edge n) => ¬ (graphOf s).Connected)))
      atTop (𝓝 0) := by
  classical
  have hδ : 0 < (c - 1) / 4 := by linarith
  have hp0 : ∀ n : ℕ, 0 ≤ c * Real.log n / n := by
    intro n
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · simp
    · have h1 : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
      have : 0 ≤ Real.log n := Real.log_nonneg h1
      have hc0 : 0 < c := by linarith
      positivity
  have hple : ∀ᶠ n : ℕ in atTop, c * Real.log n / n ≤ 1 :=
    (tendsto_c_log_div c).eventually (eventually_le_nhds one_pos)
  have hlogtop : Tendsto (fun n : ℕ => Real.log n) atTop atTop :=
    Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop
  have hbig : ∀ᶠ n : ℕ in atTop,
      -Real.log (3 * (c - 1) / (4 * c)) ≤ (c + 1) / 4 * Real.log n := by
    have : Tendsto (fun n : ℕ => (c + 1) / 4 * Real.log n) atTop atTop :=
      Filter.Tendsto.const_mul_atTop (by linarith) hlogtop
    exact this.eventually_ge_atTop _
  have hsmall : ∀ᶠ n : ℕ in atTop, 1 - (c - 1) / 4 * Real.log n < 0 := by
    have : Tendsto (fun n : ℕ => (c - 1) / 4 * Real.log n) atTop atTop :=
      Filter.Tendsto.const_mul_atTop hδ hlogtop
    filter_upwards [this.eventually_gt_atTop 1] with n hn using by linarith
  refine squeeze_zero' ?_ ?_ (tendsto_exp_ratio_zero 1 hδ)
  · filter_upwards [hple] with n hp1
    exact Prob_nonneg (hp0 n) hp1 _
  · filter_upwards [hple, hbig, hsmall, Filter.eventually_ge_atTop 2] with n hp1 hb hs hn2
    set r : ℝ := Real.exp (1 - (c - 1) / 4 * Real.log n) with hrdef
    have hr0 : 0 < r := Real.exp_pos _
    have hr1 : r < 1 := by rw [hrdef, Real.exp_lt_one_iff]; exact hs
    calc Prob (c * Real.log n / n)
          (Finset.univ.filter (fun s : Finset (Edge n) => ¬ (graphOf s).Connected))
        ≤ ∑ S ∈ (Finset.univ : Finset (Finset (Fin n))).filter
            (fun S => S.Nonempty ∧ S.card ≤ n / 2),
            (1 - c * Real.log n / n) ^ (S.card * (n - S.card)) :=
          prob_disconnected_le (by omega) (hp0 n) hp1
      _ = ∑ k ∈ Finset.Icc 1 (n / 2),
            (n.choose k : ℝ) * (1 - c * Real.log n / n) ^ (k * (n - k)) :=
          sum_over_small_sets n (fun k => (1 - c * Real.log n / n) ^ (k * (n - k)))
      _ ≤ ∑ k ∈ Finset.Icc 1 (n / 2), r ^ k := by
          refine Finset.sum_le_sum fun k hk => ?_
          rw [Finset.mem_Icc] at hk
          exact sharp_cut_term_le hc hn2 hk.1 (by omega) hp1 hb
      _ ≤ r / (1 - r) := geom_Icc_le (le_of_lt hr0) hr1 _


/-- **Sharp connectivity threshold, upper half: `G(n, c·log n/n)` is a.a.s. connected
for every `c > 1`.**  Together with `ErdosRenyi.prob_connected_log_tendsto_zero`
(a.a.s. *disconnected* for `c < 1`) this locates the connectivity threshold of the
Erdős–Rényi random graph exactly at `p = log n / n`. -/
theorem prob_connected_log_tendsto_one {c : ℝ} (hc : 1 < c) :
    Tendsto
      (fun n : ℕ => Prob (c * Real.log n / n)
        (Finset.univ.filter (fun s : Finset (Edge n) => (graphOf s).Connected)))
      atTop (𝓝 1) := by
  classical
  have hsplit : ∀ n : ℕ,
      Prob (c * Real.log n / n)
        (Finset.univ.filter (fun s : Finset (Edge n) => (graphOf s).Connected))
      = 1 - Prob (c * Real.log n / n)
        (Finset.univ.filter (fun s : Finset (Edge n) => ¬ (graphOf s).Connected)) := by
    intro n
    have := Prob_add_Prob_not (α := Edge n) (c * Real.log n / n)
      (fun s : Finset (Edge n) => (graphOf s).Connected)
    linarith
  simp only [hsplit]
  simpa using (tendsto_const_nhds (x := (1 : ℝ)) (f := atTop (α := ℕ))).sub
    (prob_disconnected_log_tendsto_zero hc)

/-- **The sharp connectivity threshold for `G(n,p)` at `p = log n / n`.**

Writing `p = c·log n/n`, the probability that the Erdős–Rényi graph `G(n,p)` is
connected tends to `0` when `c < 1` and to `1` when `c > 1`.  The subcritical half is
the second-moment argument for the isolated-vertex count
(`ErdosRenyi.prob_connected_log_tendsto_zero`); the supercritical half is the cut union
bound (`ErdosRenyi.prob_connected_log_tendsto_one`). -/
theorem connectivity_sharp_threshold :
    (∀ c : ℝ, 0 < c → c < 1 →
        Tendsto (fun n : ℕ => Prob (c * Real.log n / n)
          (Finset.univ.filter (fun s : Finset (Edge n) => (graphOf s).Connected)))
          atTop (𝓝 0))
      ∧ (∀ c : ℝ, 1 < c →
        Tendsto (fun n : ℕ => Prob (c * Real.log n / n)
          (Finset.univ.filter (fun s : Finset (Edge n) => (graphOf s).Connected)))
          atTop (𝓝 1)) :=
  ⟨fun _ hc0 hc1 => prob_connected_log_tendsto_zero hc0 hc1,
   fun _ hc => prob_connected_log_tendsto_one hc⟩

end ErdosRenyi