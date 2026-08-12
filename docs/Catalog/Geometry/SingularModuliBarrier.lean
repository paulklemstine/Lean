/-
# The √N Barrier for Structured-Set Factoring (abstract layer)

Companion to `SingularModuliCore.lean`.  That file shows that for a semiprime
`N = p q` and an integer polynomial `f` (e.g. a Hilbert class polynomial `H_D`)
the evaluation point `j₀` factors `N` **iff** its CRT coordinates lie in the
"exclusive-or" set

    G = { (a,b) : a ∈ R_p, b ∉ R_q } ∪ { (a,b) : a ∉ R_p, b ∈ R_q },

where `R_m` is the root set of `f` mod `m`.  Here we forget the polynomial
entirely and analyse this configuration for *arbitrary* subsets
`R_p ⊆ ZMod p`, `R_q ⊆ ZMod q` with `|R_p|, |R_q| ≤ d`.  This is the honest
level of generality: the only feature of singular moduli the method exploits is
that `H_D` has few roots (`h(D) = deg H_D`) modulo each prime.

Main results.

* `SqrtBarrier.card_goodPairs` — the exact count `r_p (q - r_q) + (p - r_p) r_q`.
* `SqrtBarrier.expectedTrials_ge` — **lower bound**: for balanced primes
  (`p ≤ q ≤ 2p`) and root counts `≤ d`, the expected number of uniformly random
  evaluation points before a factor is found is at least `√N / (3 d)`.
* `SqrtBarrier.expectedTrials_le` — **matching upper bound**: if both root
  counts equal `h ≥ 1` and `4h ≤ p`, the expectation is at most `√N / h`.
  Hence the method is `Θ(√N / h)` — it *works*, and it is *exponential in the
  bit size of N*, quantified in `SqrtBarrier.expectedTrials_ge_two_pow`.
* `SqrtBarrier.exists_bad_shift` and `SqrtBarrier.exists_bad_shift_of_small`
  — **the circularity barrier**, in an adversarial (not merely probabilistic)
  form: a translation-averaging argument shows that *any* fixed query set of
  size below `√N / (3 d)` is defeated by some translate of the structured set.
  Knowing that the target set is "structured" is worth nothing unless one knows
  *where* it is, which is exactly the information `p` encodes.

Note on the informal claim `√N/(4h)` in the source note: the exact count below
gives expectation `pq / (h (p + q - 2h))`, i.e. `≈ √N / (2h)` for balanced
primes, not `√N/(4h)`.  The heuristic there double-counts the two primes; the
corrected constant is proved in `expectedTrials_balanced_eq`.
-/
import Mathlib

namespace SqrtBarrier

open Finset

variable {p q : ℕ} [NeZero p] [NeZero q]

/-! ## The exclusive-or configuration and its exact size -/

/-- Successful evaluation points, in Chinese-Remainder coordinates: those
lying in the structured set modulo exactly one of the two primes. -/
def goodPairs (Rp : Finset (ZMod p)) (Rq : Finset (ZMod q)) : Finset (ZMod p × ZMod q) :=
  Finset.univ.filter fun z => Xor' (z.1 ∈ Rp) (z.2 ∈ Rq)

/-- **Exact count.** `|G| = r_p (q - r_q) + (p - r_p) r_q`. -/
theorem card_goodPairs (Rp : Finset (ZMod p)) (Rq : Finset (ZMod q)) :
    (goodPairs Rp Rq).card = Rp.card * (q - Rq.card) + (p - Rp.card) * Rq.card := by
  classical
  have h : goodPairs Rp Rq = (Rp ×ˢ Rqᶜ) ∪ (Rpᶜ ×ˢ Rq) := by
    ext ⟨a, b⟩
    simp only [goodPairs, Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_union,
      Finset.mem_product, Finset.mem_compl, Xor']
    tauto
  have hdisj : Disjoint (Rp ×ˢ Rqᶜ) (Rpᶜ ×ˢ Rq) := by
    rw [Finset.disjoint_left]
    rintro ⟨a, b⟩ h1 h2
    simp only [Finset.mem_product, Finset.mem_compl] at h1 h2
    exact h2.1 h1.1
  rw [h, Finset.card_union_of_disjoint hdisj, Finset.card_product, Finset.card_product,
    Finset.card_compl, Finset.card_compl, ZMod.card, ZMod.card]

/-- Few roots ⟹ few successful residues: `|G| ≤ d (p + q)`. -/
theorem card_goodPairs_le (Rp : Finset (ZMod p)) (Rq : Finset (ZMod q)) (d : ℕ)
    (hp : Rp.card ≤ d) (hq : Rq.card ≤ d) :
    (goodPairs Rp Rq).card ≤ d * (p + q) := by
  rw [card_goodPairs]
  calc Rp.card * (q - Rq.card) + (p - Rp.card) * Rq.card
      ≤ Rp.card * q + p * Rq.card := by
        gcongr <;> omega
    _ ≤ d * q + p * d := by gcongr
    _ = d * (p + q) := by ring

/-- Unsymmetrised version of the previous bound. -/
theorem card_goodPairs_le' (Rp : Finset (ZMod p)) (Rq : Finset (ZMod q)) :
    (goodPairs Rp Rq).card ≤ Rp.card * q + p * Rq.card := by
  rw [card_goodPairs]
  gcongr <;> omega

/-- With equal root counts `h` (the class-number case) the count is exactly
`h (p + q - 2h)`. -/
theorem card_goodPairs_balanced (Rp : Finset (ZMod p)) (Rq : Finset (ZMod q)) (h : ℕ)
    (hp : Rp.card = h) (hq : Rq.card = h) (hph : h ≤ p) (hqh : h ≤ q) :
    (goodPairs Rp Rq).card = h * (p + q - 2 * h) := by
  obtain ⟨a, rfl⟩ := Nat.exists_eq_add_of_le hph
  obtain ⟨b, rfl⟩ := Nat.exists_eq_add_of_le hqh
  rw [card_goodPairs, hp, hq]
  have e1 : h + a - h = a := by omega
  have e2 : h + b - h = b := by omega
  have e3 : h + a + (h + b) - 2 * h = a + b := by omega
  rw [e1, e2, e3]
  ring

/-- Lower bound on the count in the equal-root-count case. -/
theorem card_goodPairs_ge (Rp : Finset (ZMod p)) (Rq : Finset (ZMod q)) (h : ℕ)
    (hp : Rp.card = h) (hq : Rq.card = h) (h4p : 4 * h ≤ p) (h4q : 4 * h ≤ q) :
    h * (p + q) ≤ 2 * (goodPairs Rp Rq).card := by
  rw [card_goodPairs_balanced Rp Rq h hp hq (by omega) (by omega)]
  have : p + q ≤ 2 * (p + q - 2 * h) := by omega
  calc h * (p + q) ≤ h * (2 * (p + q - 2 * h)) := Nat.mul_le_mul_left _ this
    _ = 2 * (h * (p + q - 2 * h)) := by ring

/-- **Completeness of the method.**  If the structured set is nonempty mod `p`
and not everything mod `q`, some evaluation point does factor `N`. -/
theorem goodPairs_nonempty (Rp : Finset (ZMod p)) (Rq : Finset (ZMod q))
    (hp : 0 < Rp.card) (hq : Rq.card < q) : 0 < (goodPairs Rp Rq).card := by
  rw [card_goodPairs]
  have : 0 < Rp.card * (q - Rq.card) := Nat.mul_pos hp (by omega)
  omega

/-- **Failure mode.**  If the prime is inert (no roots at all on either side)
the method cannot succeed: not a single evaluation point works.  This really
happens: `N = 8051 = 83 · 97` with `D = -15` (see `ComputationalEvidence.md`). -/
theorem goodPairs_eq_empty (Rp : Finset (ZMod p)) (Rq : Finset (ZMod q))
    (hp : Rp = ∅) (hq : Rq = ∅) : goodPairs Rp Rq = ∅ := by
  rw [← Finset.card_eq_zero, card_goodPairs, hp, hq]
  simp

/-! ## Expected number of evaluations -/

/-- Expected number of independent uniform evaluation points needed to hit the
successful set: the mean `N / |G|` of the geometric distribution with success
probability `|G| / N`. -/
noncomputable def expectedTrials (Rp : Finset (ZMod p)) (Rq : Finset (ZMod q)) : ℝ :=
  (p * q : ℝ) / (goodPairs Rp Rq).card

private lemma sqrt_ge_left {p q : ℝ} (hp : 0 ≤ p) (hpq : p ≤ q) : p ≤ Real.sqrt (p * q) := by
  have h0 : (0:ℝ) ≤ p * q := by nlinarith
  have hs := Real.sq_sqrt h0
  have hnn := Real.sqrt_nonneg (p * q)
  nlinarith [hs, hnn, sq_nonneg (Real.sqrt (p * q) - p)]

private lemma sqrt_le_avg {p q : ℝ} (hp : 0 ≤ p) (hq : 0 ≤ q) :
    Real.sqrt (p * q) ≤ (p + q) / 2 := by
  have h0 : (0:ℝ) ≤ p * q := by nlinarith
  have hs := Real.sq_sqrt h0
  have hnn := Real.sqrt_nonneg (p * q)
  nlinarith [hs, hnn, sq_nonneg (p - q), sq_nonneg (Real.sqrt (p * q) - (p + q) / 2)]

/-- **√N barrier (lower bound).**  For balanced primes and structured sets of
size at most `d`, the expected number of evaluations is at least `√N / (3d)`.
Since `d` is the degree of the class polynomial (a quantity independent of `N`),
this is genuinely `Ω(√N)`. -/
theorem expectedTrials_ge (Rp : Finset (ZMod p)) (Rq : Finset (ZMod q)) (d : ℕ)
    (hdp : Rp.card ≤ d) (hdq : Rq.card ≤ d) (hd : 0 < d)
    (hpq : p ≤ q) (hbal : q ≤ 2 * p) (hG : 0 < (goodPairs Rp Rq).card) :
    Real.sqrt (p * q) / (3 * d) ≤ expectedTrials Rp Rq := by
  have hp0 : (0:ℝ) < p := by
    have := Nat.pos_of_ne_zero (NeZero.ne p); exact_mod_cast this
  have hq0 : (0:ℝ) < q := by
    have := Nat.pos_of_ne_zero (NeZero.ne q); exact_mod_cast this
  have hd0 : (0:ℝ) < d := by exact_mod_cast hd
  have hG0 : (0:ℝ) < (goodPairs Rp Rq).card := by exact_mod_cast hG
  -- |G| ≤ d (p+q) ≤ 3 d p ≤ 3 d √(pq)
  have h1 : ((goodPairs Rp Rq).card : ℝ) ≤ d * (p + q) := by
    exact_mod_cast card_goodPairs_le Rp Rq d hdp hdq
  have h2 : (p : ℝ) + q ≤ 3 * p := by
    have : (q:ℝ) ≤ 2 * p := by exact_mod_cast hbal
    linarith
  have h3 : (p : ℝ) ≤ Real.sqrt (p * q) :=
    sqrt_ge_left (le_of_lt hp0) (by exact_mod_cast hpq)
  have hGle : ((goodPairs Rp Rq).card : ℝ) ≤ 3 * d * Real.sqrt (p * q) := by
    nlinarith
  have hs0 : 0 < Real.sqrt ((p:ℝ) * q) := lt_of_lt_of_le hp0 h3
  rw [expectedTrials, div_le_div_iff₀ (by positivity) hG0]
  have hsq : Real.sqrt ((p:ℝ) * q) * Real.sqrt ((p:ℝ) * q) = (p:ℝ) * q :=
    Real.mul_self_sqrt (by positivity)
  nlinarith [hGle, hs0, hsq]

/-- **Matching upper bound.**  In the class-number case (`|R_p| = |R_q| = h ≥ 1`,
both primes at least `4h`) the expectation is at most `√N / h`: the method does
work, in `Θ(√N/h)` evaluations. -/
theorem expectedTrials_le (Rp : Finset (ZMod p)) (Rq : Finset (ZMod q)) (h : ℕ)
    (hp : Rp.card = h) (hq : Rq.card = h) (hh : 0 < h) (h4p : 4 * h ≤ p) (h4q : 4 * h ≤ q) :
    expectedTrials Rp Rq ≤ Real.sqrt (p * q) / h := by
  have hp0 : (0:ℝ) < p := by
    have : 0 < p := by omega
    exact_mod_cast this
  have hq0 : (0:ℝ) < q := by
    have : 0 < q := by omega
    exact_mod_cast this
  have hh0 : (0:ℝ) < h := by exact_mod_cast hh
  -- 2|G| ≥ h (p+q) ≥ 2 h √(pq)
  have h1 : (h : ℝ) * (p + q) ≤ 2 * (goodPairs Rp Rq).card := by
    exact_mod_cast card_goodPairs_ge Rp Rq h hp hq h4p h4q
  have h2 : Real.sqrt ((p:ℝ) * q) ≤ ((p:ℝ) + q) / 2 :=
    sqrt_le_avg (le_of_lt hp0) (le_of_lt hq0)
  have hGge : (h : ℝ) * Real.sqrt ((p:ℝ) * q) ≤ (goodPairs Rp Rq).card := by nlinarith
  have hs0 : 0 < Real.sqrt ((p:ℝ) * q) := Real.sqrt_pos.mpr (by positivity)
  have hG0 : (0:ℝ) < (goodPairs Rp Rq).card := lt_of_lt_of_le (by positivity) hGge
  rw [expectedTrials, div_le_div_iff₀ hG0 hh0]
  have hsq : Real.sqrt ((p:ℝ) * q) * Real.sqrt ((p:ℝ) * q) = (p:ℝ) * q :=
    Real.mul_self_sqrt (by positivity)
  nlinarith [hGge, hs0, hsq]

/-- The exact expectation in the class-number case: `N / (h (p + q - 2h))`.
For balanced `p ≈ q ≈ √N` this is `≈ √N / (2h)`, correcting the informal
`√N/(4h)`. -/
theorem expectedTrials_balanced_eq (Rp : Finset (ZMod p)) (Rq : Finset (ZMod q)) (h : ℕ)
    (hp : Rp.card = h) (hq : Rq.card = h) (hph : h ≤ p) (hqh : h ≤ q) :
    expectedTrials Rp Rq = (p * q : ℝ) / (h * (p + q - 2 * h) : ℕ) := by
  rw [expectedTrials, card_goodPairs_balanced Rp Rq h hp hq hph hqh]

/-- **Exponential in the bit size.**  If `N ≥ 2^(2k)` then the expected number
of evaluations is at least `2^k / (3d)`. -/
theorem expectedTrials_ge_two_pow (Rp : Finset (ZMod p)) (Rq : Finset (ZMod q)) (d k : ℕ)
    (hdp : Rp.card ≤ d) (hdq : Rq.card ≤ d) (hd : 0 < d)
    (hpq : p ≤ q) (hbal : q ≤ 2 * p) (hG : 0 < (goodPairs Rp Rq).card)
    (hN : 2 ^ (2 * k) ≤ p * q) :
    (2 : ℝ) ^ k / (3 * d) ≤ expectedTrials Rp Rq := by
  have hd0 : (0:ℝ) < d := by exact_mod_cast hd
  have hN' : ((2:ℝ) ^ k) ^ 2 ≤ (p : ℝ) * q := by
    have : ((2:ℝ) ^ (2 * k)) ≤ ((p * q : ℕ) : ℝ) := by exact_mod_cast hN
    calc ((2:ℝ) ^ k) ^ 2 = (2:ℝ) ^ (2 * k) := by ring
      _ ≤ ((p * q : ℕ) : ℝ) := this
      _ = (p : ℝ) * q := by push_cast; ring
  have hsqrt : (2:ℝ) ^ k ≤ Real.sqrt ((p:ℝ) * q) := by
    calc (2:ℝ) ^ k = Real.sqrt (((2:ℝ) ^ k) ^ 2) := by
          rw [Real.sqrt_sq (by positivity)]
      _ ≤ Real.sqrt ((p:ℝ) * q) := Real.sqrt_le_sqrt hN'
  calc (2:ℝ) ^ k / (3 * d) ≤ Real.sqrt ((p:ℝ) * q) / (3 * d) := by
        gcongr
    _ ≤ expectedTrials Rp Rq := expectedTrials_ge Rp Rq d hdp hdq hd hpq hbal hG

/-! ## Random search: a rigorous success-probability bound

`expectedTrials` above is the mean of the geometric distribution.  To avoid
leaning on that interpretation, this section proves the corresponding statement
purely by counting: among all `N^T` sequences of `T` independent uniform
evaluation points, the proportion on which *every* point fails is
`(1 - |G|/N)^T`, and hence the success probability of a `T`-point random search
is at most `3 d T / √N`.  Below `√N/(6d)` points it is less than one half. -/

/-- The number of `T`-term sequences of evaluation points on which every single
evaluation fails is `(N - |G|)^T`. -/
theorem card_all_fail (Rp : Finset (ZMod p)) (Rq : Finset (ZMod q)) (T : ℕ) :
    (Fintype.piFinset fun _ : Fin T => (goodPairs Rp Rq)ᶜ).card
      = (p * q - (goodPairs Rp Rq).card) ^ T := by
  classical
  have hcard : Fintype.card (ZMod p × ZMod q) = p * q := by
    simp [Fintype.card_prod, ZMod.card]
  rw [Fintype.card_piFinset]
  simp [Finset.card_compl, hcard]

/-- **Random search needs `Ω(√N)` points.**  The probability that a search using
`T` independent uniform evaluation points finds a factor is at most
`3 d T / √N`. -/
theorem success_prob_le (Rp : Finset (ZMod p)) (Rq : Finset (ZMod q)) (d T : ℕ)
    (hdp : Rp.card ≤ d) (hdq : Rq.card ≤ d) (hd : 0 < d)
    (hpq : p ≤ q) (hbal : q ≤ 2 * p) :
    1 - (1 - ((goodPairs Rp Rq).card : ℝ) / (p * q)) ^ T
      ≤ (T : ℝ) * (3 * d) / Real.sqrt (p * q) := by
  have hp0 : (0:ℝ) < p := by
    have := Nat.pos_of_ne_zero (NeZero.ne p); exact_mod_cast this
  have hq0 : (0:ℝ) < q := by
    have := Nat.pos_of_ne_zero (NeZero.ne q); exact_mod_cast this
  have hd0 : (0:ℝ) < d := by exact_mod_cast hd
  set x : ℝ := ((goodPairs Rp Rq).card : ℝ) / (p * q) with hx
  have hGle : ((goodPairs Rp Rq).card : ℝ) ≤ d * ((p:ℝ) + q) := by
    exact_mod_cast card_goodPairs_le Rp Rq d hdp hdq
  have h2 : (p : ℝ) + q ≤ 3 * p := by
    have : (q:ℝ) ≤ 2 * p := by exact_mod_cast hbal
    linarith
  have h3 : (p : ℝ) ≤ Real.sqrt (p * q) :=
    sqrt_ge_left (le_of_lt hp0) (by exact_mod_cast hpq)
  have hs0 : 0 < Real.sqrt ((p:ℝ) * q) := lt_of_lt_of_le hp0 h3
  have hsq : Real.sqrt ((p:ℝ) * q) * Real.sqrt ((p:ℝ) * q) = (p:ℝ) * q :=
    Real.mul_self_sqrt (by positivity)
  have hx0 : 0 ≤ x := by rw [hx]; positivity
  have hx1 : x ≤ 1 := by
    have hcard : Fintype.card (ZMod p × ZMod q) = p * q := by
      simp [Fintype.card_prod, ZMod.card]
    have hle := Finset.card_le_univ (goodPairs Rp Rq)
    rw [hcard] at hle
    have : ((goodPairs Rp Rq).card : ℝ) ≤ (p : ℝ) * q := by exact_mod_cast hle
    rw [hx, div_le_one (by positivity)]
    exact this
  -- Bernoulli: 1 - T x ≤ (1 - x)^T
  have hbern : 1 - (T : ℝ) * x ≤ (1 - x) ^ T := by
    have := one_add_mul_le_pow (a := -x) (by linarith) T
    simpa [sub_eq_add_neg, mul_comm] using this
  -- x ≤ 3 d / √N
  have hxle : x ≤ 3 * d / Real.sqrt ((p:ℝ) * q) := by
    have hA : ((goodPairs Rp Rq).card : ℝ) * Real.sqrt ((p:ℝ) * q)
        ≤ (3 * d * p) * Real.sqrt ((p:ℝ) * q) :=
      mul_le_mul_of_nonneg_right (by nlinarith [hGle, h2, hd0]) (le_of_lt hs0)
    have hB : (p : ℝ) * Real.sqrt ((p:ℝ) * q) ≤ (p:ℝ) * q := by nlinarith [h3, hsq, hs0]
    rw [hx, div_le_div_iff₀ (by positivity) hs0]
    nlinarith [hA, hB, hd0]
  have hT0 : (0:ℝ) ≤ T := by positivity
  calc 1 - (1 - x) ^ T ≤ (T : ℝ) * x := by linarith
    _ ≤ (T : ℝ) * (3 * d / Real.sqrt ((p:ℝ) * q)) := by
        exact mul_le_mul_of_nonneg_left hxle hT0
    _ = (T : ℝ) * (3 * d) / Real.sqrt ((p:ℝ) * q) := by ring

/-- Below `√N / (6d)` evaluation points, a random search fails with probability
greater than one half. -/
theorem fail_prob_gt_half (Rp : Finset (ZMod p)) (Rq : Finset (ZMod q)) (d T : ℕ)
    (hdp : Rp.card ≤ d) (hdq : Rq.card ≤ d) (hd : 0 < d)
    (hpq : p ≤ q) (hbal : q ≤ 2 * p)
    (hT : (T : ℝ) * (6 * d) < Real.sqrt (p * q)) :
    1 / 2 < (1 - ((goodPairs Rp Rq).card : ℝ) / (p * q)) ^ T := by
  have hp0 : (0:ℝ) < p := by
    have := Nat.pos_of_ne_zero (NeZero.ne p); exact_mod_cast this
  have hpq' : (p:ℝ) ≤ q := by exact_mod_cast hpq
  have h3 : (p : ℝ) ≤ Real.sqrt (p * q) := sqrt_ge_left (le_of_lt hp0) hpq'
  have hs0 : 0 < Real.sqrt ((p:ℝ) * q) := lt_of_lt_of_le hp0 h3
  have hmain := success_prob_le Rp Rq d T hdp hdq hd hpq hbal
  have hlt : (T : ℝ) * (3 * d) / Real.sqrt ((p:ℝ) * q) < 1 / 2 := by
    rw [div_lt_iff₀ hs0]
    nlinarith [hT, hs0]
  linarith

/-! ## The circularity barrier: averaging over translates -/

/-- Double counting, for an *arbitrary* target set `G`: summing, over all
translations `t`, the number of queries `s ∈ S` with `t + s ∈ G`, gives exactly
`|S| · |G|`.  Nothing about the arithmetic origin of `G` is used. -/
theorem sum_card_translate_general (G S : Finset (ZMod p × ZMod q)) :
    ∑ t : ZMod p × ZMod q, (S.filter fun s => t + s ∈ G).card = S.card * G.card := by
  classical
  have inner : ∀ s : ZMod p × ZMod q,
      (Finset.univ.filter fun t : ZMod p × ZMod q => t + s ∈ G).card = G.card := by
    intro s
    refine Finset.card_equiv (Equiv.addRight s) ?_
    intro t
    simp [Equiv.addRight]
  calc ∑ t : ZMod p × ZMod q, (S.filter fun s => t + s ∈ G).card
      = ∑ t : ZMod p × ZMod q, ∑ s ∈ S, (if t + s ∈ G then 1 else 0) :=
        Finset.sum_congr rfl fun t _ => Finset.card_filter _ _
    _ = ∑ s ∈ S, ∑ t : ZMod p × ZMod q, (if t + s ∈ G then 1 else 0) := Finset.sum_comm
    _ = ∑ _s ∈ S, G.card := by
        refine Finset.sum_congr rfl ?_
        intro s _
        rw [← Finset.card_filter]
        exact inner s
    _ = S.card * G.card := by
        rw [Finset.sum_const, smul_eq_mul]

/-- Specialisation of `sum_card_translate_general` to the success set. -/
theorem sum_card_translate (Rp : Finset (ZMod p)) (Rq : Finset (ZMod q))
    (S : Finset (ZMod p × ZMod q)) :
    ∑ t : ZMod p × ZMod q, (S.filter fun s => t + s ∈ goodPairs Rp Rq).card
      = S.card * (goodPairs Rp Rq).card :=
  sum_card_translate_general (goodPairs Rp Rq) S

/-- **The circularity barrier (adversarial form).**  If a fixed query set `S`
is too small — `|S| · |G| < N` — then some translate of the structured
configuration avoids every query.  Structure alone is useless: the search must
locate the set, and locating it is the unknown-factor problem. -/
theorem exists_bad_shift_general (G S : Finset (ZMod p × ZMod q))
    (hS : S.card * G.card < p * q) :
    ∃ t : ZMod p × ZMod q, ∀ s ∈ S, t + s ∉ G := by
  classical
  by_contra hcon
  push_neg at hcon
  have hpos : ∀ t : ZMod p × ZMod q, 1 ≤ (S.filter fun s => t + s ∈ G).card := by
    intro t
    obtain ⟨s, hs, hmem⟩ := hcon t
    exact Finset.card_pos.mpr ⟨s, Finset.mem_filter.mpr ⟨hs, hmem⟩⟩
  have hsum : (Fintype.card (ZMod p × ZMod q)) ≤
      ∑ t : ZMod p × ZMod q, (S.filter fun s => t + s ∈ G).card := by
    calc (Fintype.card (ZMod p × ZMod q))
        = ∑ _t : ZMod p × ZMod q, 1 := by simp [Finset.card_univ]
      _ ≤ _ := Finset.sum_le_sum fun t _ => hpos t
  rw [sum_card_translate_general] at hsum
  have hcard : Fintype.card (ZMod p × ZMod q) = p * q := by
    simp [Fintype.card_prod, ZMod.card]
  omega

/-- Specialisation of `exists_bad_shift_general` to the success set of a class
polynomial. -/
theorem exists_bad_shift (Rp : Finset (ZMod p)) (Rq : Finset (ZMod q))
    (S : Finset (ZMod p × ZMod q))
    (hS : S.card * (goodPairs Rp Rq).card < p * q) :
    ∃ t : ZMod p × ZMod q, ∀ s ∈ S, t + s ∉ goodPairs Rp Rq :=
  exists_bad_shift_general (goodPairs Rp Rq) S hS

/-- **Rectangle-complexity form of the barrier** (sub-conjecture C1-a of
`FUTURE_DIRECTIONS.md`).  Any target set that is a union of `r` combinatorial
rectangles `A i ×ˢ B i` obeys the same barrier with `|G|` replaced by
`∑ |A i| |B i|`: a query set of size below `N / ∑ |A i| |B i|` is defeated by
some translate.  The success set of a class polynomial is the case `r = 2`. -/
theorem exists_bad_shift_rect {r : ℕ} (A : Fin r → Finset (ZMod p)) (B : Fin r → Finset (ZMod q))
    (S : Finset (ZMod p × ZMod q))
    (hS : S.card * (∑ i, (A i).card * (B i).card) < p * q) :
    ∃ t : ZMod p × ZMod q, ∀ s ∈ S, t + s ∉ Finset.univ.biUnion fun i => A i ×ˢ B i := by
  classical
  refine exists_bad_shift_general _ S (lt_of_le_of_lt ?_ hS)
  have hcard : (Finset.univ.biUnion fun i => A i ×ˢ B i).card
      ≤ ∑ i, (A i).card * (B i).card := by
    calc (Finset.univ.biUnion fun i => A i ×ˢ B i).card
        ≤ ∑ i, (A i ×ˢ B i).card := Finset.card_biUnion_le
      _ = ∑ i, (A i).card * (B i).card :=
        Finset.sum_congr rfl fun i _ => Finset.card_product _ _
  exact Nat.mul_le_mul_left _ hcard

/-- **Quantitative circularity barrier.**  Any query set of size below
`√N / (3d)` is defeated by some translate of the structured set.  Thus the
`Ω(√N)` cost is not an artefact of random sampling: it survives against
arbitrary, adaptively designed but factor-oblivious query sets. -/
theorem exists_bad_shift_of_small (Rp : Finset (ZMod p)) (Rq : Finset (ZMod q))
    (S : Finset (ZMod p × ZMod q)) (d : ℕ)
    (hdp : Rp.card ≤ d) (hdq : Rq.card ≤ d) (hd : 0 < d)
    (hpq : p ≤ q) (hbal : q ≤ 2 * p)
    (hsmall : (S.card : ℝ) * (3 * d) < Real.sqrt (p * q)) :
    ∃ t : ZMod p × ZMod q, ∀ s ∈ S, t + s ∉ goodPairs Rp Rq := by
  refine exists_bad_shift Rp Rq S ?_
  have hp0 : (0:ℝ) < p := by
    have := Nat.pos_of_ne_zero (NeZero.ne p); exact_mod_cast this
  have hd0 : (0:ℝ) < d := by exact_mod_cast hd
  have h1 : ((goodPairs Rp Rq).card : ℝ) ≤ d * (p + q) := by
    exact_mod_cast card_goodPairs_le Rp Rq d hdp hdq
  have h2 : (p : ℝ) + q ≤ 3 * p := by
    have : (q:ℝ) ≤ 2 * p := by exact_mod_cast hbal
    linarith
  have h3 : (p : ℝ) ≤ Real.sqrt (p * q) :=
    sqrt_ge_left (le_of_lt hp0) (by exact_mod_cast hpq)
  have hGle : ((goodPairs Rp Rq).card : ℝ) ≤ 3 * d * Real.sqrt (p * q) := by nlinarith
  have hsq : Real.sqrt ((p:ℝ) * q) * Real.sqrt ((p:ℝ) * q) = (p:ℝ) * q :=
    Real.mul_self_sqrt (by positivity)
  have hS0 : (0:ℝ) ≤ (S.card : ℝ) := by positivity
  have key : ((S.card * (goodPairs Rp Rq).card : ℕ) : ℝ) < ((p * q : ℕ) : ℝ) := by
    push_cast
    calc (S.card : ℝ) * (goodPairs Rp Rq).card
        ≤ (S.card : ℝ) * (3 * d * Real.sqrt (p * q)) := by nlinarith
      _ = ((S.card : ℝ) * (3 * d)) * Real.sqrt (p * q) := by ring
      _ < Real.sqrt ((p:ℝ) * q) * Real.sqrt ((p:ℝ) * q) := by
          have hs0 : 0 < Real.sqrt ((p:ℝ) * q) := lt_of_lt_of_le hp0 h3
          exact (mul_lt_mul_of_pos_right hsmall hs0)
      _ = (p : ℝ) * q := hsq
  exact_mod_cast key

/-- **Adaptivity does not help.**  An adaptive search is a sequence of
evaluation points `a 0, a 1, …` where `a n` may depend on the outcomes of the
earlier queries; but as long as no factor has been found, all those outcomes are
the single answer "failure", so the queried sequence is a *fixed* sequence.
Hence the translation-averaging bound applies verbatim: below `√N / (3d)`
queries, some translate of the structured set defeats the whole run. -/
theorem exists_bad_shift_adaptive (Rp : Finset (ZMod p)) (Rq : Finset (ZMod q))
    (T : ℕ) (a : ℕ → ZMod p × ZMod q) (d : ℕ)
    (hdp : Rp.card ≤ d) (hdq : Rq.card ≤ d) (hd : 0 < d)
    (hpq : p ≤ q) (hbal : q ≤ 2 * p)
    (hsmall : (T : ℝ) * (3 * d) < Real.sqrt (p * q)) :
    ∃ t : ZMod p × ZMod q, ∀ i < T, t + a i ∉ goodPairs Rp Rq := by
  classical
  set S : Finset (ZMod p × ZMod q) := (Finset.range T).image a with hS
  have hcard : (S.card : ℝ) ≤ T := by
    have : S.card ≤ T := le_trans (Finset.card_image_le) (by simp)
    exact_mod_cast this
  have hsmall' : (S.card : ℝ) * (3 * d) < Real.sqrt (p * q) := by
    have hd0 : (0:ℝ) < d := by exact_mod_cast hd
    nlinarith [hcard, hsmall]
  obtain ⟨t, ht⟩ := exists_bad_shift_of_small Rp Rq S d hdp hdq hd hpq hbal hsmall'
  refine ⟨t, fun i hi => ht (a i) ?_⟩
  exact Finset.mem_image.mpr ⟨i, Finset.mem_range.mpr hi, rfl⟩

/-! ## Families of discriminants: the class-number gain is illusory

The informal claim `√N/(4h)` suggests that using class polynomials of large
class number `h` buys a factor `h`.  It does not, once one is honest about
*which* discriminants are useful.  `H_D` has `h(D)` roots mod `p` only when `p`
splits completely in the ring class field, which happens for a proportion
`1/h(D)` of primes (for the other primes there may be no root at all, and then
that discriminant is useless — see `ComputationalEvidence.md`, where
`N = 8051`, `D = -15` gives a *completely empty* success set).  By Chebotarev
the **average** number of roots of an irreducible polynomial modulo `p` is `1`,
independently of its degree; this is the hypothesis `hSp`, `hSq` below with
`c = 1`.  Under it, running a whole family of `k` discriminants costs the same
`Ω(√N)` as a single one: the class number cancels exactly. -/

/-- Union bound for a family of structured configurations. -/
theorem card_biUnion_goodPairs_le {k : ℕ} (Rp : Fin k → Finset (ZMod p))
    (Rq : Fin k → Finset (ZMod q)) (Sp Sq : ℕ)
    (hSp : ∑ i, (Rp i).card ≤ Sp) (hSq : ∑ i, (Rq i).card ≤ Sq) :
    (Finset.univ.biUnion fun i => goodPairs (Rp i) (Rq i)).card ≤ Sp * q + p * Sq := by
  classical
  calc (Finset.univ.biUnion fun i => goodPairs (Rp i) (Rq i)).card
      ≤ ∑ i, (goodPairs (Rp i) (Rq i)).card := Finset.card_biUnion_le
    _ ≤ ∑ i, ((Rp i).card * q + p * (Rq i).card) :=
        Finset.sum_le_sum fun i _ => card_goodPairs_le' (Rp i) (Rq i)
    _ = (∑ i, (Rp i).card) * q + p * (∑ i, (Rq i).card) := by
        rw [Finset.sum_add_distrib, ← Finset.sum_mul, ← Finset.mul_sum]
    _ ≤ Sp * q + p * Sq := by gcongr

/-- Expected number of *polynomial evaluations* of a family search: each trial
point costs `k` evaluations (one per discriminant) and succeeds when the point
lies in the union of the success sets. -/
noncomputable def familyExpectedTrials {k : ℕ} (Rp : Fin k → Finset (ZMod p))
    (Rq : Fin k → Finset (ZMod q)) : ℝ :=
  (k * (p * q) : ℝ) / (Finset.univ.biUnion fun i => goodPairs (Rp i) (Rq i)).card

/-- **No class-number speed-up.**  If the family of `k` structured sets has
average size at most `c` on each side (`c = 1` for class polynomials, by
Chebotarev), then the expected number of evaluations is at least `√N / (3c)`,
*independently of `k` and of the class numbers involved*.  The `1/h` factor in
the informal heuristic is exactly cancelled by the `1/h` density of
discriminants for which the prime splits. -/
theorem familyExpectedTrials_ge {k : ℕ} (Rp : Fin k → Finset (ZMod p))
    (Rq : Fin k → Finset (ZMod q)) (c : ℕ) (hk : 0 < k) (hc : 0 < c)
    (hSp : ∑ i, (Rp i).card ≤ c * k) (hSq : ∑ i, (Rq i).card ≤ c * k)
    (hpq : p ≤ q) (hbal : q ≤ 2 * p)
    (hU : 0 < (Finset.univ.biUnion fun i => goodPairs (Rp i) (Rq i)).card) :
    Real.sqrt (p * q) / (3 * c) ≤ familyExpectedTrials Rp Rq := by
  classical
  set U := (Finset.univ.biUnion fun i => goodPairs (Rp i) (Rq i)).card with hUdef
  have hp0 : (0:ℝ) < p := by
    have := Nat.pos_of_ne_zero (NeZero.ne p); exact_mod_cast this
  have hc0 : (0:ℝ) < c := by exact_mod_cast hc
  have hk0 : (0:ℝ) < k := by exact_mod_cast hk
  have hU0 : (0:ℝ) < U := by exact_mod_cast hU
  have h1 : (U : ℝ) ≤ (c * k : ℕ) * q + p * (c * k : ℕ) := by
    exact_mod_cast card_biUnion_goodPairs_le Rp Rq (c * k) (c * k) hSp hSq
  have h1' : (U : ℝ) ≤ c * k * ((p : ℝ) + q) := by push_cast at h1 ⊢; nlinarith
  have h2 : (p : ℝ) + q ≤ 3 * p := by
    have : (q:ℝ) ≤ 2 * p := by exact_mod_cast hbal
    linarith
  have h3 : (p : ℝ) ≤ Real.sqrt (p * q) :=
    sqrt_ge_left (le_of_lt hp0) (by exact_mod_cast hpq)
  have hUle : (U : ℝ) ≤ 3 * c * k * Real.sqrt ((p:ℝ) * q) := by nlinarith
  have hs0 : 0 < Real.sqrt ((p:ℝ) * q) := lt_of_lt_of_le hp0 h3
  have hsq : Real.sqrt ((p:ℝ) * q) * Real.sqrt ((p:ℝ) * q) = (p:ℝ) * q :=
    Real.mul_self_sqrt (by positivity)
  rw [familyExpectedTrials, ← hUdef, div_le_div_iff₀ (by positivity) hU0]
  nlinarith [hUle, hs0, hsq, hk0]

end SqrtBarrier