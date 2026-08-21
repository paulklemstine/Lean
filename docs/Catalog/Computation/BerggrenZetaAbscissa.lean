import Computation.BerggrenZetaSilver

/-!
# The Berggren tree zeta function and its abscissa of convergence

For a real parameter `s` the **Berggren tree zeta function** is the Dirichlet series

`Z(s) = Σ_{w ∈ {0,1,2}*} c(w)^{-s}`,

the sum being taken over all nodes `w` of the Berggren tree with `c(w)` the hypotenuse of the
primitive Pythagorean triple sitting at `w`.  (By `node_injective` no triple is counted twice,
and by `seed_complete` every primitive triple with odd first leg is counted once.)

The guiding conjecture was that the abscissa of convergence of `Z` should be dictated by the
silver-ratio growth exponent of the tree: the depth-`k` layer has `3^k` nodes and its largest
hypotenuse grows like `λ^k` with `λ = (1+√2)² = 3+2√2`, so the *layer majorant* predicts the
abscissa `σ_silver = log 3 / log(3+2√2) = 0.6232…` (`layer_majorant_summable`).

## Main results

* `summable_zterm` : `Z(s)` converges for every `s > 1`.
* `not_summable_zterm` : `Z(s)` diverges for every `s ≤ 1`.  The proof feeds the *prime seeds*
  `(p, 2j)`, `2j < p`, into the tree (legitimate nodes by Barning–Hall completeness) and uses
  the divergence of the sum of prime reciprocals.
* `summable_zterm_iff`, `zetaAbscissa_eq_one` : **the abscissa of convergence is exactly `1`.**
* `layer_majorant_summable` , `silver_prediction_lt_one` ,
  `zetaAbscissa_gt_silver_prediction` : **the silver-ratio prediction is refuted.**  The
  layer-majorant abscissa `log 3 / log(3+2√2) ≈ 0.6232` is a strict lower bound only; the true
  abscissa is `1`.  The gap is a sharp statement about the tree: within a layer the hypotenuses
  are spread over a huge range (from polynomial growth along the `s₂` spine to `λ^k` along the
  `s₁` spine), so the layer maximum badly overestimates a typical node.
-/

namespace BerggrenZeta

open Real Filter Topology

noncomputable section

/-- The term of the Berggren tree zeta function attached to the node `w`. -/
def zterm (s : ℝ) (w : List (Fin 3)) : ℝ := (chyp w : ℝ) ^ (-s)

/-- The same term, indexed by the Euclid seed of the node. -/
def seedTerm (s : ℝ) (p : ℕ × ℕ) : ℝ := (hyp p : ℝ) ^ (-s)

lemma zterm_eq_seedTerm (s : ℝ) (w : List (Fin 3)) : zterm s w = seedTerm s (node w) := rfl

/-- The Berggren tree zeta function. -/
def treeZeta (s : ℝ) : ℝ := ∑' w : List (Fin 3), zterm s w

lemma seedTerm_nonneg (s : ℝ) (p : ℕ × ℕ) : 0 ≤ seedTerm s p :=
  Real.rpow_nonneg (by positivity) _

lemma one_le_hyp {p : ℕ × ℕ} (hp : IsSeed p) : (1 : ℝ) ≤ (hyp p : ℝ) := by
  have h1 : 1 ≤ p.2 := hp.pos
  have h2 : p.2 < p.1 := hp.lt
  have h : 1 ≤ hyp p := by
    unfold hyp
    nlinarith
  exact_mod_cast h

/-! ## Convergence for `s > 1` -/

/-- The two-dimensional majorant `Σ_{n < m} m^{-2s}` used to bound the zeta function. -/
lemma summable_majorant {s : ℝ} (hs : 1 < s) :
    Summable (fun p : ℕ × ℕ => if p.2 < p.1 then (p.1 : ℝ) ^ (-2 * s) else 0) := by
  set F : ℕ × ℕ → ℝ := fun p => if p.2 < p.1 then (p.1 : ℝ) ^ (-2 * s) else 0 with hFdef
  have hnn : 0 ≤ F := by
    intro p
    simp only [hFdef]
    split
    · positivity
    · exact le_rfl
  rw [summable_prod_of_nonneg hnn]
  constructor
  · intro m
    refine summable_of_ne_finset_zero (s := Finset.range m) ?_
    intro n hn
    simp only [Finset.mem_range, not_lt] at hn
    simp only [hFdef]
    rw [if_neg (by omega)]
  · have key : ∀ m : ℕ, (∑' n : ℕ, F (m, n)) = (m : ℝ) ^ (1 - 2 * s) := by
      intro m
      rw [tsum_eq_sum (s := Finset.range m) (by
        intro n hn
        simp only [Finset.mem_range, not_lt] at hn
        simp only [hFdef]
        rw [if_neg (by omega)])]
      have hcongr : ∀ n ∈ Finset.range m, F (m, n) = (m : ℝ) ^ (-2 * s) := by
        intro n hn
        simp only [Finset.mem_range] at hn
        simp only [hFdef]
        rw [if_pos hn]
      rw [Finset.sum_congr rfl hcongr, Finset.sum_const, Finset.card_range, nsmul_eq_mul]
      rcases Nat.eq_zero_or_pos m with rfl | hm
      · simp
        rw [Real.zero_rpow (by linarith)]
      · rw [show (1 : ℝ) - 2 * s = 1 + (-2 * s) by ring, Real.rpow_add (by exact_mod_cast hm)]
        simp
    rw [funext key]
    exact Real.summable_nat_rpow.mpr (by linarith)

/-- Each seed term is dominated by the majorant. -/
lemma seedTerm_le_majorant {s : ℝ} (hs : 0 < s) {p : ℕ × ℕ} (hp : IsSeed p) :
    seedTerm s p ≤ (if p.2 < p.1 then (p.1 : ℝ) ^ (-2 * s) else 0) := by
  have hlt : p.2 < p.1 := hp.lt
  rw [if_pos hlt]
  have hm1 : (1 : ℝ) ≤ (p.1 : ℝ) := by
    have : 1 ≤ p.1 := by have := hp.pos; omega
    exact_mod_cast this
  have hmpos : (0 : ℝ) < (p.1 : ℝ) := by linarith
  have hle : ((p.1 : ℝ)) ^ 2 ≤ (hyp p : ℝ) := by
    unfold hyp
    push_cast
    nlinarith [sq_nonneg ((p.2 : ℝ))]
  have hpow : ((p.1 : ℝ) ^ 2) ^ (-s) = (p.1 : ℝ) ^ (-2 * s) := by
    rw [show ((p.1 : ℝ) ^ 2) = (p.1 : ℝ) ^ (2 : ℝ) by
      rw [show ((2 : ℝ)) = ((2 : ℕ) : ℝ) by norm_num, Real.rpow_natCast], ← Real.rpow_mul hmpos.le]
    ring_nf
  rw [← hpow]
  exact Real.rpow_le_rpow_of_nonpos (by positivity) hle (by linarith)

/-- **Convergence.**  The Berggren tree zeta function converges for every `s > 1`. -/
theorem summable_zterm {s : ℝ} (hs : 1 < s) : Summable (zterm s) := by
  have hmaj := summable_majorant hs
  have hsub : Summable
      (fun p : {p : ℕ × ℕ // IsSeed p} =>
        (if p.1.2 < p.1.1 then (p.1.1 : ℝ) ^ (-2 * s) else 0)) := hmaj.subtype _
  have hseed : Summable (fun p : {p : ℕ × ℕ // IsSeed p} => seedTerm s p.1) := by
    refine Summable.of_nonneg_of_le (fun p => seedTerm_nonneg s p.1) ?_ hsub
    intro p
    exact seedTerm_le_majorant (by linarith) p.2
  have := (nodeEquiv.summable_iff (f := fun p : {p : ℕ × ℕ // IsSeed p} => seedTerm s p.1)).2 hseed
  exact this

/-! ## Divergence for `s ≤ 1` -/

/-- The prime family: for an odd prime `p` and `1 ≤ j` with `2j < p`, the pair `(p, 2j)` is a
Euclid seed, hence a node of the Berggren tree. -/
def PrimeCond (q : ℕ × ℕ) : Prop := q.1.Prime ∧ 1 ≤ q.2 ∧ 2 * q.2 < q.1

lemma primeCond_isSeed {q : ℕ × ℕ} (h : PrimeCond q) : IsSeed (q.1, 2 * q.2) := by
  obtain ⟨hp, hj, hlt⟩ := h
  refine isSeed_mk (by omega) (by omega) ?_ ?_
  · refine (Nat.Prime.coprime_iff_not_dvd hp).2 ?_
    intro hdvd
    have := Nat.le_of_dvd (by omega) hdvd
    omega
  · have hp2 : q.1 % 2 = 1 := Nat.odd_iff.mp (hp.odd_of_ne_two (by omega))
    omega

lemma seedTerm_one (p : ℕ × ℕ) : seedTerm 1 p = ((hyp p : ℝ))⁻¹ := by
  show ((hyp p : ℝ)) ^ (-(1 : ℝ)) = _
  rw [Real.rpow_neg_one]

/-- The lower-bound family at the critical exponent `s = 1`, as an indicator on `ℕ × ℕ`. -/
def primeFam : ℕ × ℕ → ℝ :=
  Set.indicator {q : ℕ × ℕ | PrimeCond q} (fun q => seedTerm 1 (q.1, 2 * q.2))

lemma primeFam_nonneg : 0 ≤ primeFam := by
  intro q
  show (0 : ℝ) ≤ primeFam q
  unfold primeFam
  by_cases h : q ∈ {q : ℕ × ℕ | PrimeCond q}
  · rw [Set.indicator_of_mem h]
    exact seedTerm_nonneg _ _
  · rw [Set.indicator_of_notMem h]

/-- Every member of the prime family has size at least `1/(2p²)`. -/
lemma primeFam_lower {p j : ℕ} (h : PrimeCond (p, j)) :
    1 / (2 * (p : ℝ) ^ 2) ≤ primeFam (p, j) := by
  obtain ⟨hp, hj, hlt⟩ := h
  have hseed : IsSeed (p, 2 * j) := primeCond_isSeed ⟨hp, hj, hlt⟩
  have hmem : (p, j) ∈ {q : ℕ × ℕ | PrimeCond q} := ⟨hp, hj, hlt⟩
  unfold primeFam
  rw [Set.indicator_of_mem hmem, seedTerm_one]
  have hpos : (0 : ℝ) < (hyp (p, 2 * j) : ℝ) := lt_of_lt_of_le zero_lt_one (one_le_hyp hseed)
  have h2j : ((2 * j : ℕ) : ℝ) ≤ (p : ℝ) := by exact_mod_cast hlt.le
  have h0 : (0 : ℝ) ≤ ((2 * j : ℕ) : ℝ) := Nat.cast_nonneg _
  have hupper : (hyp (p, 2 * j) : ℝ) ≤ 2 * (p : ℝ) ^ 2 := by
    unfold hyp
    push_cast
    push_cast at h2j h0
    nlinarith
  rw [inv_eq_one_div]
  exact one_div_le_one_div_of_le hpos hupper

/-- **Divergence at the critical exponent.**  `Σ_w c(w)^{-1}` diverges. -/
theorem not_summable_zterm_one : ¬ Summable (zterm 1) := by
  intro hsum
  -- transfer the sum to the set of Euclid seeds
  have hseed : Summable (fun p : {p : ℕ × ℕ // IsSeed p} => seedTerm 1 p.1) :=
    (nodeEquiv.summable_iff (f := fun p : {p : ℕ × ℕ // IsSeed p} => seedTerm 1 p.1)).1 hsum
  -- restrict to the prime family
  have hinj : Function.Injective
      (fun q : {q : ℕ × ℕ // PrimeCond q} => (⟨(q.1.1, 2 * q.1.2), primeCond_isSeed q.2⟩ :
        {p : ℕ × ℕ // IsSeed p})) := by
    rintro ⟨⟨p, j⟩, hq⟩ ⟨⟨p', j'⟩, hq'⟩ h
    simp only [Subtype.mk.injEq, Prod.mk.injEq] at h
    obtain ⟨h1, h2⟩ := h
    simp only [Subtype.mk.injEq, Prod.mk.injEq]
    omega
  have hcomp := hseed.comp_injective hinj
  have hind : Summable primeFam := summable_subtype_iff_indicator.1 hcomp
  obtain ⟨hrow, hG⟩ := (summable_prod_of_nonneg primeFam_nonneg).1 hind
  -- the row sums dominate `1/(8p)` for every odd prime `p`
  have hrowlb : ∀ p : ℕ, p.Prime → 3 ≤ p → 1 / (8 * (p : ℝ)) ≤ ∑' j : ℕ, primeFam (p, j) := by
    intro p hp hp3
    have hodd : p % 2 = 1 := Nat.odd_iff.mp (hp.odd_of_ne_two (by omega))
    set t : ℕ := (p - 1) / 2 with ht
    have h2t : 2 * t = p - 1 := by omega
    have hsum : ∑ j ∈ Finset.Icc 1 t, primeFam (p, j) ≤ ∑' j : ℕ, primeFam (p, j) :=
      Summable.sum_le_tsum _ (fun j _ => primeFam_nonneg (p, j)) (hrow p)
    have hterm : ∀ j ∈ Finset.Icc 1 t, 1 / (2 * (p : ℝ) ^ 2) ≤ primeFam (p, j) := by
      intro j hj
      simp only [Finset.mem_Icc] at hj
      exact primeFam_lower ⟨hp, hj.1, by omega⟩
    have hcard : (Finset.Icc 1 t).card = t := by simp
    have hlow : (t : ℝ) * (1 / (2 * (p : ℝ) ^ 2)) ≤ ∑ j ∈ Finset.Icc 1 t, primeFam (p, j) := by
      calc (t : ℝ) * (1 / (2 * (p : ℝ) ^ 2))
          = ∑ _j ∈ Finset.Icc 1 t, 1 / (2 * (p : ℝ) ^ 2) := by
            rw [Finset.sum_const, hcard, nsmul_eq_mul]
        _ ≤ ∑ j ∈ Finset.Icc 1 t, primeFam (p, j) := Finset.sum_le_sum hterm
    have hpR : (3 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp3
    have hppos : (0 : ℝ) < (p : ℝ) := by linarith
    have htR : 2 * (t : ℝ) = (p : ℝ) - 1 := by
      have hcast : ((2 * t : ℕ) : ℝ) = ((p - 1 : ℕ) : ℝ) := by rw [h2t]
      push_cast [Nat.cast_sub (by omega : 1 ≤ p)] at hcast
      linarith
    have hexpand : (t : ℝ) * (1 / (2 * (p : ℝ) ^ 2)) - 1 / (8 * (p : ℝ))
        = (4 * (t : ℝ) - (p : ℝ)) / (8 * (p : ℝ) ^ 2) := by
      field_simp
      ring
    have hnum : 0 ≤ 4 * (t : ℝ) - (p : ℝ) := by linarith
    have hquot : 0 ≤ (4 * (t : ℝ) - (p : ℝ)) / (8 * (p : ℝ) ^ 2) :=
      div_nonneg hnum (by positivity)
    linarith
  -- compare with the divergent sum of prime reciprocals
  refine not_summable_one_div_on_primes ?_
  have hfin : Summable (fun n : ℕ => if n = 2 then (1 : ℝ) / 2 else 0) :=
    summable_of_ne_finset_zero (s := {2}) (by
      intro n hn
      simp only [Finset.mem_singleton] at hn
      rw [if_neg hn])
  refine Summable.of_nonneg_of_le ?_ ?_ ((hG.mul_left 8).add hfin)
  · intro n
    by_cases h : n ∈ {p : ℕ | Nat.Prime p}
    · rw [Set.indicator_of_mem h]
      positivity
    · rw [Set.indicator_of_notMem h]
  · intro n
    have hGnn : 0 ≤ ∑' j : ℕ, primeFam (n, j) := tsum_nonneg (fun j => primeFam_nonneg (n, j))
    have hifnn : (0 : ℝ) ≤ (if n = 2 then (1 : ℝ) / 2 else 0) := by split <;> norm_num
    by_cases h : n ∈ {p : ℕ | Nat.Prime p}
    · rw [Set.indicator_of_mem h]
      have hp : n.Prime := h
      rcases eq_or_lt_of_le hp.two_le with h2 | h2
      · have hn2 : n = 2 := h2.symm
        subst hn2
        rw [if_pos rfl]
        norm_num
        linarith
      · have h3 : 3 ≤ n := by omega
        have hlb := hrowlb n hp h3
        have hn0 : (0 : ℝ) < n := by
          have : (3 : ℝ) ≤ n := by exact_mod_cast h3
          linarith
        have h8 : 1 / (n : ℝ) ≤ 8 * ∑' j : ℕ, primeFam (n, j) := by
          have h1 : 8 * (1 / (8 * (n : ℝ))) = 1 / (n : ℝ) := by field_simp
          linarith [mul_le_mul_of_nonneg_left hlb (by norm_num : (0 : ℝ) ≤ 8)]
        linarith
    · rw [Set.indicator_of_notMem h]
      linarith

/-- The zeta terms increase as `s` decreases. -/
lemma zterm_mono {s : ℝ} (hs : s ≤ 1) (w : List (Fin 3)) : zterm 1 w ≤ zterm s w := by
  have h1 : (1 : ℝ) ≤ (chyp w : ℝ) := one_le_hyp (isSeed_node w)
  exact Real.rpow_le_rpow_of_exponent_le h1 (by linarith)

/-- **Divergence.**  The Berggren tree zeta function diverges for every `s ≤ 1`. -/
theorem not_summable_zterm {s : ℝ} (hs : s ≤ 1) : ¬ Summable (zterm s) := by
  intro hsum
  exact not_summable_zterm_one
    (Summable.of_nonneg_of_le (fun w => Real.rpow_nonneg (by positivity) _)
      (fun w => zterm_mono hs w) hsum)

/-! ## The abscissa of convergence -/

/-- **The abscissa of convergence of the Berggren tree zeta function is `1`.** -/
theorem summable_zterm_iff (s : ℝ) : Summable (zterm s) ↔ 1 < s := by
  constructor
  · intro h
    by_contra hcon
    exact not_summable_zterm (not_lt.1 hcon) h
  · exact summable_zterm

/-- The abscissa of convergence of the tree zeta function. -/
def zetaAbscissa : ℝ := sInf {s : ℝ | Summable (zterm s)}

theorem zeta_domain : {s : ℝ | Summable (zterm s)} = Set.Ioi 1 := by
  ext s
  simpa using summable_zterm_iff s

theorem zetaAbscissa_eq_one : zetaAbscissa = 1 := by
  unfold zetaAbscissa
  rw [zeta_domain, csInf_Ioi]

/-! ## Refutation of the silver-ratio prediction -/

/-- The silver-ratio prediction for the abscissa coming from the layer majorant
`Σ_k 3^k (max hypotenuse at depth k)^{-s}`. -/
def silverPrediction : ℝ := Real.log 3 / Real.log lam

/-- The layer majorant `Σ_k 3^k (2λ^{k+1})^{-s}` converges for every `s > log 3 / log λ`:
the silver-ratio heuristic really does predict the abscissa `log 3 / log(3+2√2)`. -/
theorem layer_majorant_summable {s : ℝ} (hs : silverPrediction < s) :
    Summable (fun k : ℕ => (3 : ℝ) ^ k * (2 * lam ^ (k + 1)) ^ (-s)) := by
  have hlam := one_lt_lam
  have hlog : 0 < Real.log lam := Real.log_pos hlam
  have hr : 3 * lam ^ (-s) < 1 := by
    have hlt : Real.log 3 < s * Real.log lam := by
      rw [silverPrediction, div_lt_iff₀ hlog] at hs
      linarith
    have : lam ^ (-s) = Real.exp (-s * Real.log lam) := by
      rw [Real.rpow_def_of_pos (by linarith)]
      ring_nf
    rw [this]
    have h3 : (3 : ℝ) = Real.exp (Real.log 3) := (Real.exp_log (by norm_num)).symm
    rw [h3, ← Real.exp_add]
    rw [show Real.log 3 + -s * Real.log lam = Real.log 3 - s * Real.log lam by ring]
    calc Real.exp (Real.log 3 - s * Real.log lam) < Real.exp 0 := by
          apply Real.exp_lt_exp.2; linarith
      _ = 1 := Real.exp_zero
  have hrnn : 0 ≤ 3 * lam ^ (-s) := by positivity
  have hgeom : Summable (fun k : ℕ => (3 * lam ^ (-s)) ^ k) :=
    summable_geometric_of_lt_one hrnn hr
  have hEq : ∀ k : ℕ, (3 : ℝ) ^ k * (2 * lam ^ (k + 1)) ^ (-s)
      = ((2 : ℝ) ^ (-s) * lam ^ (-s)) * (3 * lam ^ (-s)) ^ k := by
    intro k
    have hlpos : (0 : ℝ) < lam := lam_pos
    have h1 : (2 * lam ^ (k + 1) : ℝ) ^ (-s) = (2 : ℝ) ^ (-s) * (lam ^ (k + 1) : ℝ) ^ (-s) := by
      rw [Real.mul_rpow (by norm_num) (by positivity)]
    have h2 : ((lam ^ (k + 1) : ℝ)) ^ (-s) = (lam ^ (-s)) ^ (k + 1) := by
      rw [← Real.rpow_natCast lam (k + 1), ← Real.rpow_natCast (lam ^ (-s)) (k + 1),
        ← Real.rpow_mul hlpos.le, ← Real.rpow_mul hlpos.le]
      ring_nf
    rw [h1, h2, mul_pow, pow_succ]
    ring
  rw [funext hEq]
  exact hgeom.mul_left _

/-- The silver-ratio prediction is `log 3 / log(3+2√2) = 0.6232… < 1`. -/
theorem silver_prediction_lt_one : silverPrediction < 1 := by
  have hlam := one_lt_lam
  have hlog : 0 < Real.log lam := Real.log_pos hlam
  rw [silverPrediction, div_lt_one hlog]
  refine Real.log_lt_log (by norm_num) ?_
  unfold lam
  nlinarith [one_lt_sqrt2]

/-- **Refutation of the silver-ratio conjecture for the abscissa.**  The abscissa of
convergence of the Berggren tree zeta function is strictly larger than the value predicted by
the silver-ratio growth of the layers. -/
theorem zetaAbscissa_gt_silver_prediction : silverPrediction < zetaAbscissa := by
  rw [zetaAbscissa_eq_one]
  exact silver_prediction_lt_one

/-- Quantitative form of the refutation: at `s` strictly between the silver prediction and `1`
the layer majorant converges while the zeta function itself diverges. -/
theorem majorant_converges_zeta_diverges {s : ℝ} (h1 : silverPrediction < s) (h2 : s ≤ 1) :
    Summable (fun k : ℕ => (3 : ℝ) ^ k * (2 * lam ^ (k + 1)) ^ (-s)) ∧ ¬ Summable (zterm s) :=
  ⟨layer_majorant_summable h1, not_summable_zterm h2⟩

end

end BerggrenZeta