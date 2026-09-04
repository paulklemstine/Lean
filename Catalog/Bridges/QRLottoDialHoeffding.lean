import Mathlib
import Bridges.QRLottoDialConcentration

/-!
# Sub-Gaussian concentration of the zero-fit QR lottery dial

`Bridges.QRLottoDialIndependence` shows that, over the CRT sample space of residue vectors
coprime to a factor base of odd primes, the zero-fit dial `T(N) = ∑ 2/p` is a sum of
*exactly independent fair coins* of amplitude `2/p`; `Bridges.QRLottoDialConcentration`
turns the resulting exact variance `∑ 1/p²` into a Chebyshev bound `1/(2t²)` on the
deviating fraction.

This file upgrades the polynomial tail to an **exponential** one, closing the open half of
the cycle's concentration conjecture.  The route is the classical Chernoff/Hoeffding
argument, carried out entirely with finite sums:

1. `sum_exp_coin` — the moment generating function of a single centred coin is exactly
   `#nzZ p · cosh (s w / 2)` (the lottery is *fair*, so no first-order term survives);
2. `sum_exp_weightedDial_centred` — the MGF of the whole read-out **factorises** over the
   factor base, by the same product-Finset decoupling used for the variance;
3. `sum_exp_dial_le` — `cosh u ≤ exp (u²/2)` gives the sub-Gaussian MGF bound with variance
   proxy `∑ 1/p²`;
4. `dial_upper_tail`, `dial_lower_tail`, `dial_tail` — Markov's inequality at the optimal
   parameter `s = t/V` gives `exp(−t²/(2V))` tails, with `V = ∑ 1/p²`;
5. `dial_tail_uniform` — combined with `sum_inv_sq_le_half` (`V ≤ 1/2` for distinct odd
   primes) this yields the **factor-base-free** bound: at most a fraction `2 exp(−t²)` of
   the residue classes read more than `t` from the Mertens weight, for every factor base
   and every `t ≥ 0`.  For `t = 2` this is already stronger than the Chebyshev bound
   `1/(2t²)`, and `chernoff_beats_chebyshev` records that comparison.

## Main results

* `QRLotto.sum_exp_dial_le` — sub-Gaussian moment generating function bound.
* `QRLotto.dial_tail` — two-sided Hoeffding tail with the exact variance proxy `∑ 1/p²`.
* `QRLotto.dial_tail_uniform` — uniform sub-Gaussian tail `2 exp(−t²)`.
* `QRLotto.exists_dial_close_to_mean_of_lt` — whenever `2 exp(−t²) < 1`, some residue
  vector reads within `t` of the Mertens weight.
-/

open Finset

namespace QRLotto

/-! ## A finite Chernoff/Markov step -/

/-- **Markov's inequality in exponential form.**  If the exponential sum of `h` over `s` is
at most `C`, then the number of points where `h` is at least `r`, weighted by `exp r`, is at
most `C`. -/
theorem card_filter_le_of_sum_exp_le {α : Type*} (s : Finset α) (h : α → ℝ) (r C : ℝ)
    (hsum : ∑ x ∈ s, Real.exp (h x) ≤ C) :
    (#(s.filter (fun x => r ≤ h x)) : ℝ) * Real.exp r ≤ C := by
  classical
  have h1 : (#(s.filter (fun x => r ≤ h x)) : ℝ) * Real.exp r
      = ∑ _x ∈ s.filter (fun x => r ≤ h x), Real.exp r := by
    rw [Finset.sum_const, nsmul_eq_mul]
  have h2 : ∑ _x ∈ s.filter (fun x => r ≤ h x), Real.exp r
      ≤ ∑ x ∈ s.filter (fun x => r ≤ h x), Real.exp (h x) :=
    Finset.sum_le_sum (fun x hx => Real.exp_le_exp.2 (Finset.mem_filter.1 hx).2)
  have h3 : ∑ x ∈ s.filter (fun x => r ≤ h x), Real.exp (h x) ≤ ∑ x ∈ s, Real.exp (h x) :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
      (fun x _ _ => (Real.exp_pos _).le)
  linarith

/-- **Chernoff bound at a fixed parameter.**  From a sub-Gaussian MGF bound at `s ≥ 0` one
reads off the exponential tail `exp (s²V/2 − s t)`. -/
theorem chernoff_card_le_param {α : Type*} (S : Finset α) (g : α → ℝ) {t s V : ℝ}
    (hs0 : 0 ≤ s)
    (hmgf : ∑ x ∈ S, Real.exp (s * g x) ≤ (#S : ℝ) * Real.exp (s ^ 2 / 2 * V)) :
    (#(S.filter (fun x => t ≤ g x)) : ℝ) ≤ (#S : ℝ) * Real.exp (s ^ 2 / 2 * V - s * t) := by
  classical
  have hsub : S.filter (fun x => t ≤ g x) ⊆ S.filter (fun x => s * t ≤ s * g x) := by
    intro x hx
    rw [Finset.mem_filter] at hx ⊢
    exact ⟨hx.1, mul_le_mul_of_nonneg_left hx.2 hs0⟩
  have hcardR : (#(S.filter (fun x => t ≤ g x)) : ℝ)
      ≤ (#(S.filter (fun x => s * t ≤ s * g x)) : ℝ) := by
    exact_mod_cast Finset.card_le_card hsub
  have hmarkov : (#(S.filter (fun x => s * t ≤ s * g x)) : ℝ) * Real.exp (s * t)
      ≤ (#S : ℝ) * Real.exp (s ^ 2 / 2 * V) :=
    card_filter_le_of_sum_exp_le S (fun x => s * g x) (s * t)
      ((#S : ℝ) * Real.exp (s ^ 2 / 2 * V)) hmgf
  have hrw : (#S : ℝ) * Real.exp (s ^ 2 / 2 * V)
      = ((#S : ℝ) * Real.exp (s ^ 2 / 2 * V - s * t)) * Real.exp (s * t) := by
    rw [mul_assoc, ← Real.exp_add]
    ring_nf
  rw [hrw] at hmarkov
  have hkey : (#(S.filter (fun x => s * t ≤ s * g x)) : ℝ)
      ≤ (#S : ℝ) * Real.exp (s ^ 2 / 2 * V - s * t) :=
    le_of_mul_le_mul_right hmarkov (Real.exp_pos _)
  linarith

/-- **Chernoff bound at the optimal parameter.**  Optimising `s = t/V` in
`chernoff_card_le_param` gives the Gaussian-shaped tail `exp(−t²/(2V))`. -/
theorem chernoff_card_le {α : Type*} (S : Finset α) (g : α → ℝ) {t V : ℝ}
    (hV : 0 < V) (ht : 0 ≤ t)
    (hmgf : ∀ u : ℝ, ∑ x ∈ S, Real.exp (u * g x) ≤ (#S : ℝ) * Real.exp (u ^ 2 / 2 * V)) :
    (#(S.filter (fun x => t ≤ g x)) : ℝ) ≤ (#S : ℝ) * Real.exp (-(t ^ 2 / (2 * V))) := by
  have hs0 : (0 : ℝ) ≤ t / V := div_nonneg ht hV.le
  have hbase := chernoff_card_le_param S g (t := t) (s := t / V) (V := V) hs0 (hmgf (t / V))
  have hexp : (t / V) ^ 2 / 2 * V - (t / V) * t = -(t ^ 2 / (2 * V)) := by
    field_simp
    ring
  rwa [hexp] at hbase

/-! ## The moment generating function of the dial -/

variable {k : ℕ}

/-- **MGF of a single centred coin.**  Because the two tickets at an odd prime are
equinumerous, the exponential average of the centred coin is exactly a hyperbolic cosine —
no first-order term survives. -/
theorem sum_exp_coin (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) (s w : ℝ) :
    ∑ y ∈ nzZ p, Real.exp (s * coin p w y) = (#(nzZ p) : ℝ) * Real.cosh (s * w / 2) := by
  classical
  have hw : ∀ y ∈ winZ p, Real.exp (s * coin p w y) = Real.exp (s * w / 2) := by
    intro y hy
    rw [coin_of_win hy]
    ring_nf
  have hl : ∀ y ∈ loseZ p, Real.exp (s * coin p w y) = Real.exp (-(s * w / 2)) := by
    intro y hy
    rw [coin_of_not_win ((Finset.disjoint_right.1 (disjoint_winZ_loseZ p)) hy)]
    ring_nf
  have hcards : (#(loseZ p) : ℝ) = (#(winZ p) : ℝ) := by
    exact_mod_cast (card_winZ_eq_card_loseZ p hp).symm
  have hnz : (#(nzZ p) : ℝ) = 2 * (#(winZ p) : ℝ) := by
    exact_mod_cast (two_mul_card_winZ p hp).symm
  rw [show (nzZ p) = winZ p ∪ loseZ p from rfl, Finset.sum_union (disjoint_winZ_loseZ p),
    Finset.sum_congr rfl hw, Finset.sum_congr rfl hl, Finset.sum_const, Finset.sum_const,
    nsmul_eq_mul, nsmul_eq_mul, hcards]
  rw [show ((#(winZ p ∪ loseZ p) : ℕ) : ℝ) = 2 * (#(winZ p) : ℝ) from hnz, Real.cosh_eq]
  ring

/-- **The MGF factorises over the factor base.**  Exactly independent coordinates make the
exponential sum a product of one-prime factors. -/
theorem sum_exp_weightedDial_centred (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime)
    (h2 : ∀ i, q i ≠ 2) (w : Fin k → ℝ) (s : ℝ) :
    ∑ x ∈ sampleSpace q, Real.exp (s * (weightedDial q w x - ∑ i, w i / 2))
      = (#(sampleSpace q) : ℝ) * ∏ i, Real.cosh (s * w i / 2) := by
  classical
  have hcentre : ∀ x : ∀ i, ZMod (q i),
      weightedDial q w x - ∑ i, w i / 2 = ∑ i, coin (q i) (w i) (x i) := by
    intro x
    rw [weightedDial, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl (fun i _ => rfl)
  have hprod : ∀ x : ∀ i, ZMod (q i),
      Real.exp (s * (weightedDial q w x - ∑ i, w i / 2))
        = ∏ i, Real.exp (s * coin (q i) (w i) (x i)) := by
    intro x
    rw [hcentre x, Finset.mul_sum, Real.exp_sum]
  have hkey := Finset.prod_univ_sum (fun i => nzZ (q i))
    (fun i (y : ZMod (q i)) => Real.exp (s * coin (q i) (w i) y))
  have hcard : (#(sampleSpace q) : ℝ) = ∏ i, (#(nzZ (q i)) : ℝ) := by
    rw [sampleSpace, Fintype.card_piFinset, Nat.cast_prod]
  calc ∑ x ∈ sampleSpace q, Real.exp (s * (weightedDial q w x - ∑ i, w i / 2))
      = ∑ x ∈ Fintype.piFinset (fun i => nzZ (q i)),
          ∏ i, Real.exp (s * coin (q i) (w i) (x i)) :=
        Finset.sum_congr rfl (fun x _ => hprod x)
    _ = ∏ i, ∑ y ∈ nzZ (q i), Real.exp (s * coin (q i) (w i) y) := hkey.symm
    _ = ∏ i, ((#(nzZ (q i)) : ℝ) * Real.cosh (s * w i / 2)) := by
        refine Finset.prod_congr rfl (fun i _ => ?_)
        haveI : Fact (q i).Prime := ⟨hq i⟩
        exact sum_exp_coin (q i) (h2 i) s (w i)
    _ = (#(sampleSpace q) : ℝ) * ∏ i, Real.cosh (s * w i / 2) := by
        rw [Finset.prod_mul_distrib, hcard]

/-- **Sub-Gaussian MGF bound for the zero-fit dial.**  For every real `s`, the exponential
average of the centred dial is at most `exp (s² V / 2)` with the *exact* variance proxy
`V = ∑ 1/p²`; the only analytic input is `cosh u ≤ exp (u²/2)`. -/
theorem sum_exp_dial_le (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2)
    (s : ℝ) :
    ∑ x ∈ sampleSpace q, Real.exp (s * (dialOf q x - ∑ i, 1 / (q i : ℝ)))
      ≤ (#(sampleSpace q) : ℝ) * Real.exp (s ^ 2 / 2 * ∑ i, 1 / (q i : ℝ) ^ 2) := by
  classical
  have hmean : ∑ i, (2 : ℝ) / (q i : ℝ) / 2 = ∑ i, 1 / (q i : ℝ) :=
    Finset.sum_congr rfl (fun i _ => by ring)
  have hexact := sum_exp_weightedDial_centred q hq h2 (fun i => 2 / (q i : ℝ)) s
  rw [hmean] at hexact
  have hdial : ∑ x ∈ sampleSpace q, Real.exp (s * (dialOf q x - ∑ i, 1 / (q i : ℝ)))
      = (#(sampleSpace q) : ℝ) * ∏ i, Real.cosh (s * (2 / (q i : ℝ)) / 2) := hexact
  have hcosh : ∏ i, Real.cosh (s * (2 / (q i : ℝ)) / 2)
      ≤ ∏ i, Real.exp (s ^ 2 / 2 * (1 / (q i : ℝ) ^ 2)) := by
    refine Finset.prod_le_prod (fun i _ => (Real.cosh_pos _).le) (fun i _ => ?_)
    refine (Real.cosh_le_exp_half_sq (s * (2 / (q i : ℝ)) / 2)).trans (Real.exp_le_exp.2 ?_)
    have hsq : (s * (2 / (q i : ℝ)) / 2) ^ 2 = s ^ 2 * (1 / (q i : ℝ) ^ 2) := by
      field_simp
    rw [hsq]
    exact le_of_eq (by ring)
  have hexp : ∏ i, Real.exp (s ^ 2 / 2 * (1 / (q i : ℝ) ^ 2))
      = Real.exp (s ^ 2 / 2 * ∑ i, 1 / (q i : ℝ) ^ 2) := by
    rw [← Real.exp_sum, Finset.mul_sum]
  rw [hdial]
  refine mul_le_mul_of_nonneg_left ?_ (Nat.cast_nonneg _)
  rw [← hexp]
  exact hcosh

/-! ## Hoeffding tails for the dial -/

/-- **Upper Hoeffding tail.**  At most a fraction `exp(−t²/(2V))` of the residue classes
read more than `t` *above* the Mertens weight, with `V = ∑ 1/p²` the exact variance. -/
theorem dial_upper_tail (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2)
    {t : ℝ} (ht : 0 ≤ t) (hV : 0 < ∑ i, 1 / (q i : ℝ) ^ 2) :
    (#((sampleSpace q).filter (fun x => t ≤ dialOf q x - ∑ i, 1 / (q i : ℝ))) : ℝ)
      ≤ (#(sampleSpace q) : ℝ)
          * Real.exp (-(t ^ 2 / (2 * ∑ i, 1 / (q i : ℝ) ^ 2))) :=
  chernoff_card_le (sampleSpace q) (fun x => dialOf q x - ∑ i, 1 / (q i : ℝ)) hV ht
    (fun u => sum_exp_dial_le q hq h2 u)

/-- **Lower Hoeffding tail.**  The symmetric statement for readings *below* the Mertens
weight: the same MGF bound applied to the negated read-out. -/
theorem dial_lower_tail (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2)
    {t : ℝ} (ht : 0 ≤ t) (hV : 0 < ∑ i, 1 / (q i : ℝ) ^ 2) :
    (#((sampleSpace q).filter (fun x => t ≤ (∑ i, 1 / (q i : ℝ)) - dialOf q x)) : ℝ)
      ≤ (#(sampleSpace q) : ℝ)
          * Real.exp (-(t ^ 2 / (2 * ∑ i, 1 / (q i : ℝ) ^ 2))) := by
  refine chernoff_card_le (sampleSpace q) (fun x => (∑ i, 1 / (q i : ℝ)) - dialOf q x) hV ht
    (fun u => ?_)
  have hneg := sum_exp_dial_le q hq h2 (-u)
  have hrw : ∀ x : ∀ i, ZMod (q i),
      Real.exp (u * ((∑ i, 1 / (q i : ℝ)) - dialOf q x))
        = Real.exp (-u * (dialOf q x - ∑ i, 1 / (q i : ℝ))) := by
    intro x
    congr 1
    ring
  rw [Finset.sum_congr rfl (fun x _ => hrw x)]
  have hsq : (-u) ^ 2 = u ^ 2 := by ring
  rwa [hsq] at hneg

/-- **Two-sided Hoeffding tail for the zero-fit dial.**  At most a fraction
`2 exp(−t²/(2 ∑ 1/p²))` of the residue classes coprime to the factor base read more than
`t` away from the Mertens weight `∑ 1/p`. -/
theorem dial_tail (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2)
    {t : ℝ} (ht : 0 ≤ t) (hV : 0 < ∑ i, 1 / (q i : ℝ) ^ 2) :
    (#((sampleSpace q).filter (fun x => t ≤ |dialOf q x - ∑ i, 1 / (q i : ℝ)|)) : ℝ)
      ≤ 2 * (#(sampleSpace q) : ℝ)
          * Real.exp (-(t ^ 2 / (2 * ∑ i, 1 / (q i : ℝ) ^ 2))) := by
  classical
  set μ : ℝ := ∑ i, 1 / (q i : ℝ) with hμ
  have hsplit : (sampleSpace q).filter (fun x => t ≤ |dialOf q x - μ|)
      ⊆ (sampleSpace q).filter (fun x => t ≤ dialOf q x - μ)
        ∪ (sampleSpace q).filter (fun x => t ≤ μ - dialOf q x) := by
    intro x hx
    rw [Finset.mem_filter] at hx
    rcases abs_cases (dialOf q x - μ) with ⟨habs, _⟩ | ⟨habs, _⟩
    · refine Finset.mem_union_left _ (Finset.mem_filter.2 ⟨hx.1, ?_⟩)
      rw [habs] at hx
      exact hx.2
    · refine Finset.mem_union_right _ (Finset.mem_filter.2 ⟨hx.1, ?_⟩)
      rw [habs] at hx
      linarith [hx.2]
  have hcard : (#((sampleSpace q).filter (fun x => t ≤ |dialOf q x - μ|)) : ℝ)
      ≤ (#((sampleSpace q).filter (fun x => t ≤ dialOf q x - μ)) : ℝ)
        + (#((sampleSpace q).filter (fun x => t ≤ μ - dialOf q x)) : ℝ) := by
    have hchain : #((sampleSpace q).filter (fun x => t ≤ |dialOf q x - μ|))
        ≤ #((sampleSpace q).filter (fun x => t ≤ dialOf q x - μ))
          + #((sampleSpace q).filter (fun x => t ≤ μ - dialOf q x)) :=
      le_trans (Finset.card_le_card hsplit) (Finset.card_union_le _ _)
    exact_mod_cast hchain
  have hup := dial_upper_tail q hq h2 ht hV
  have hlow := dial_lower_tail q hq h2 ht hV
  rw [← hμ] at hup hlow
  linarith

/-- **Uniform sub-Gaussian concentration.**  For a factor base of *distinct* odd primes the
tail is bounded by `2 exp(−t²)` — no dependence at all on the primes or on how many there
are, even though the mean `∑ 1/p` diverges.  This closes the exponential half of the
concentration conjecture. -/
theorem dial_tail_uniform (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2)
    (hinj : Function.Injective q) {t : ℝ} (ht : 0 ≤ t) :
    (#((sampleSpace q).filter (fun x => t ≤ |dialOf q x - ∑ i, 1 / (q i : ℝ)|)) : ℝ)
      ≤ 2 * (#(sampleSpace q) : ℝ) * Real.exp (-(t ^ 2)) := by
  classical
  rcases Nat.eq_zero_or_pos k with hk | hk
  · -- with an empty factor base the dial and the mean are both `0`
    subst hk
    rcases eq_or_lt_of_le ht with ht0 | htpos
    · -- `t = 0`: the bound is just the trivial cardinality bound
      have hle : (#((sampleSpace q).filter
          (fun x => t ≤ |dialOf q x - ∑ i, 1 / (q i : ℝ)|)) : ℝ)
            ≤ (#(sampleSpace q) : ℝ) := by
        exact_mod_cast Finset.card_filter_le _ _
      have hcard : (0 : ℝ) ≤ (#(sampleSpace q) : ℝ) := Nat.cast_nonneg _
      rw [← ht0]
      simp only [ne_eq, OfNat.ofNat_ne_zero, not_false_eq_true, zero_pow, neg_zero,
        Real.exp_zero, mul_one]
      rw [← ht0] at hle
      linarith
    · -- `t > 0`: the filter is empty, since every reading is exactly `0`
      have hempty : (sampleSpace q).filter
          (fun x => t ≤ |dialOf q x - ∑ i, 1 / (q i : ℝ)|) = ∅ := by
        refine Finset.filter_eq_empty_iff.2 (fun x _ => ?_)
        simp only [dialOf, weightedDial, Finset.univ_eq_empty, Finset.sum_empty, sub_zero,
          abs_zero]
        exact not_le.2 htpos
      rw [hempty]
      simp only [Finset.card_empty, Nat.cast_zero]
      positivity
  · have hVpos : 0 < ∑ i, 1 / (q i : ℝ) ^ 2 := by
      refine Finset.sum_pos (fun i _ => ?_) ?_
      · have hqi : (0 : ℝ) < (q i : ℝ) := by exact_mod_cast (hq i).pos
        positivity
      · exact Finset.univ_nonempty_iff.2 (Fin.pos_iff_nonempty.1 hk)
    have hVle : ∑ i, (1 : ℝ) / (q i : ℝ) ^ 2 ≤ 1 / 2 :=
      sum_inv_sq_le_half q hinj (fun i => three_le_of_prime_ne_two (hq i) (h2 i))
    refine (dial_tail q hq h2 ht hVpos).trans ?_
    have hmono : Real.exp (-(t ^ 2 / (2 * ∑ i, 1 / (q i : ℝ) ^ 2))) ≤ Real.exp (-(t ^ 2)) := by
      refine Real.exp_le_exp.2 ?_
      have hden : 0 < 2 * ∑ i, 1 / (q i : ℝ) ^ 2 := by linarith
      have hdle : 2 * ∑ i, 1 / (q i : ℝ) ^ 2 ≤ 1 := by linarith
      have ht2 : 0 ≤ t ^ 2 := sq_nonneg t
      have hkey : t ^ 2 ≤ t ^ 2 / (2 * ∑ i, 1 / (q i : ℝ) ^ 2) := by
        rw [le_div_iff₀ hden]
        nlinarith
      linarith
    have hcard : (0 : ℝ) ≤ 2 * (#(sampleSpace q) : ℝ) := by positivity
    exact mul_le_mul_of_nonneg_left hmono hcard

/-- **The exponential bound beats the Chebyshev bound already at `t = 2`.**  The polynomial
bound gives a deviating fraction `1/8`, while the sub-Gaussian bound gives `2 e^{−4}`. -/
theorem chernoff_beats_chebyshev : 2 * Real.exp (-(2 : ℝ) ^ 2) < 1 / (2 * (2 : ℝ) ^ 2) := by
  have hexp1 : (2 : ℝ) < Real.exp 1 := by
    have := Real.exp_one_gt_d9
    linarith
  have hpow : Real.exp 4 = Real.exp 1 * Real.exp 1 * (Real.exp 1 * Real.exp 1) := by
    rw [show (4 : ℝ) = 1 + 1 + (1 + 1) by norm_num, Real.exp_add, Real.exp_add]
  have hsq2 : (4 : ℝ) < Real.exp 1 * Real.exp 1 := by nlinarith [Real.exp_pos 1]
  have hexp : (16 : ℝ) < Real.exp 4 := by
    rw [hpow]
    nlinarith [Real.exp_pos 1]
  have hpos : (0 : ℝ) < Real.exp 4 := Real.exp_pos 4
  have hval : Real.exp (-(2 : ℝ) ^ 2) = (Real.exp 4)⁻¹ := by
    rw [show -(2 : ℝ) ^ 2 = -(4 : ℝ) by norm_num, Real.exp_neg]
  have hinv : (Real.exp 4)⁻¹ * Real.exp 4 = 1 := inv_mul_cancel₀ hpos.ne'
  have hinvpos : (0 : ℝ) < (Real.exp 4)⁻¹ := inv_pos.2 hpos
  rw [hval]
  nlinarith

/-- **No forced deviation.**  Whenever `2 exp(−t²) < 1` — in particular for every `t ≥ 1` —
some residue vector coprime to the factor base reads within `t` of the Mertens weight. -/
theorem exists_dial_close_to_mean_of_lt (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime)
    (h2 : ∀ i, q i ≠ 2) (hinj : Function.Injective q) {t : ℝ} (ht : 0 ≤ t)
    (hsmall : 2 * Real.exp (-(t ^ 2)) < 1) :
    ∃ x ∈ sampleSpace q, |dialOf q x - ∑ i, 1 / (q i : ℝ)| < t := by
  classical
  by_contra hcon
  push_neg at hcon
  have hfilter : (sampleSpace q).filter
      (fun x => t ≤ |dialOf q x - ∑ i, 1 / (q i : ℝ)|) = sampleSpace q :=
    Finset.filter_true_of_mem (fun x hx => hcon x hx)
  have h := dial_tail_uniform q hq h2 hinj ht
  rw [hfilter] at h
  have hpos : 0 < #(sampleSpace q) := card_sampleSpace_pos q hq h2
  have hposR : (0 : ℝ) < (#(sampleSpace q) : ℝ) := by exact_mod_cast hpos
  nlinarith

end QRLotto