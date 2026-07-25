import Mathlib
import Catalog.Novelty.NeuralCoding

/-!
# Neural Coding III: the Weight Distribution and Energy Concentration

This file deepens the neural-coding theory of `Catalog/Novelty/NeuralCoding.lean`.
That file computed the *first moment* of the metabolic weight (energy) of a
dense code — the average number of active neurons is `N / 2`.  Here we compute
the **full concentration profile** of the weight, bridging the exact
combinatorics of binary patterns with a probabilistic (measure-concentration)
conclusion.

## Model

We reuse the type `NeuralCode N = Fin N → Bool` and the `weight` (= metabolic
energy) of a code, the number of active neurons.  Regarding all `2 ^ N` codes as
equally likely, `weight` is a random variable and we study its spread.

## Results (the chain)

1. `card_active_pair` — a *fixed pair* of distinct neurons `i ≠ j` is jointly
   active in exactly `2 ^ (N - 2)` codes (a second-order refinement of the
   first-order symmetry `NeuralCoding.card_active_coord`).
2. `sum_weight_sq` — the exact **second moment**: summed over all codes,
   `∑ (weight c)² = 2 ^ N · N (N+1) / 4` (uses 1 and `card_active_coord`).
3. `sum_weight_centered_sq` — the exact **total squared deviation** from the
   mean `N / 2`: `∑ (weight c − N/2)² = N · 2 ^ N / 4` (uses 2 and the first
   moment `NeuralCoding.total_weight`).
4. `weight_variance` — the **variance** of a dense code's weight is exactly
   `N / 4` (the binomial variance `N p (1-p)` at `p = 1/2`) (uses 3).
5. `weight_concentration` — a **Chebyshev concentration bound**: the fraction of
   codes whose weight deviates from `N / 2` by at least `t` is at most
   `N / (4 t²)` (uses 3).
6. `most_codes_near_half` — a concrete corollary: at least three quarters of all
   codes have weight within `√N` of `N / 2`.  Dense neural activity concentrates
   sharply around the half-active state (uses 5).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the average energy `N / 2` established earlier hides
the more interesting fact that *almost all* codes are close to it — the
population energy is sharply concentrated.  We conjectured the weight behaves
like a Binomial(N, 1/2), so its variance should be exactly `N / 4` and Chebyshev
should give `O(1/t²)` tails, with a `√N`-window capturing a constant fraction.

Experiment (Experimenter): the crux is the exact second moment.  Writing
`weight = ∑_i 1[c i]`, we have `weight² = ∑_i ∑_j 1[c i] 1[c j]`; summing over
codes turns each term into a *joint* activity count.  The diagonal contributes
`2^(N-1)` (single-neuron symmetry, imported from the capacity file) and each of
the `N (N-1)` off-diagonal terms contributes `2^(N-2)` (`card_active_pair`).
Small cases `N = 0, 1` were checked to confirm the closed form has no boundary
defect.  Chebyshev then follows by discarding the codes inside the window and
bounding each retained squared deviation below by `t²`.

Analysis (Analyst): the identity `4 ∑ (weight)² = 2^N N (N+1)` is boundary-clean
(true for every `N`, including the degenerate `N = 0, 1`) precisely because the
`N (N-1)` prefactor annihilates the pair term exactly when no pair exists.  The
variance `N / 4` is the algebraic fingerprint of independence of the `N`
coordinates; the concentration bound is the probabilistic shadow of that
algebra.

Critique (Critic): the concentration statement is non-vacuous — the `√N`-window
corollary exhibits an explicit constant fraction (`3/4`), so the tail bound is
not hollow.  The hypothesis `0 < t` in Chebyshev is load-bearing (division by
`t²`), and `1 ≤ N` in the corollary guarantees the window `√N` is positive.

Synthesis (PI): the weight of a dense code is a Binomial(N, 1/2) in disguise;
its first two moments (`N/2`, variance `N/4`) and the resulting `1/√N`-scale
concentration mean that dense coding not only *spends* `N/2` spikes on average
but does so with vanishing relative fluctuation — a metabolic law of large
numbers for neural populations.
-/

namespace NeuralWeightConcentration

open Finset NeuralCoding

/-! ## 0. Weight as a sum of indicators -/

/--
The weight of a code is the sum over neurons of the `0/1` activity indicator.
-/
theorem weight_eq_sum_indicator {N : ℕ} (c : NeuralCode N) :
    weight c = ∑ i : Fin N, (if c i = true then 1 else 0) := by
  convert Finset.card_filter ( fun i => c i = true ) Finset.univ using 1

/-! ## 1. Joint activity of a pair of neurons -/

/--
**Second-order symmetry.**  Two distinct neurons `i ≠ j` are simultaneously
active in exactly `2 ^ (N - 2)` of the `2 ^ N` codes: fixing two coordinates to
`true` leaves the other `N - 2` free.
-/
theorem card_active_pair {N : ℕ} (i j : Fin N) (hij : i ≠ j) :
    (Finset.univ.filter (fun c : NeuralCode N => c i = true ∧ c j = true)).card
      = 2 ^ (N - 2) := by
  have h_card : Finset.card (Finset.univ.filter fun c : Fin N → Bool => c i = true ∧ c j = true) = Finset.card (Finset.univ.filter fun c : Fin N → Bool => c i = true) / 2 := by
    rw [ Nat.div_eq_of_eq_mul_left ];
    · norm_num;
    · have h_card : Finset.card (Finset.univ.filter fun c : Fin N → Bool => c i = true) = Finset.card (Finset.univ.filter fun c : Fin N → Bool => c i = true ∧ c j = true) + Finset.card (Finset.univ.filter fun c : Fin N → Bool => c i = true ∧ c j = false) := by
        rw [ ← Finset.card_union_of_disjoint ];
        · congr with c ; by_cases hj : c j <;> aesop;
        · exact Finset.disjoint_filter.mpr ( by aesop );
      rw [ h_card, mul_two ];
      rw [ Finset.card_filter, Finset.card_filter ];
      rw [ ← Equiv.sum_comp ( Equiv.addRight ( Pi.single j Bool.true ) ) ] ; aesop;
  rw [ h_card, card_active_coord ];
  · rcases N with ( _ | _ | N ) <;> simp_all +decide [ pow_succ' ];
    · fin_cases i;
    · fin_cases i ; fin_cases j ; contradiction;
  · exact Fin.pos i

/-! ## 2. The exact second moment -/

/--
**Second moment.**  Summed over all `2 ^ N` codes, the squared weight totals
`2 ^ N · N (N+1) / 4`.  Equivalently `E[weight²] = N (N+1) / 4`.
-/
theorem sum_weight_sq (N : ℕ) :
    ∑ c : NeuralCode N, ((weight c : ℝ)) ^ 2
      = 2 ^ N * ((N : ℝ) * ((N : ℝ) + 1)) / 4 := by
  -- Rewrite the sum as a double sum over all pairs of neurons.
  have h_double_sum : ∑ c : NeuralCode N, (weight c : ℝ) ^ 2 = ∑ i : Fin N, ∑ j : Fin N, ∑ c : NeuralCode N, (if c i then 1 else 0) * (if c j then 1 else 0) := by
    have h_expand : ∀ c : NeuralCode N, (weight c : ℝ) ^ 2 = ∑ i : Fin N, ∑ j : Fin N, (if c i then 1 else 0) * (if c j then 1 else 0) := by
      intro c; rw [ show ( weight c : ℝ ) = ∑ i, ( if c i = true then 1 else 0 ) from mod_cast weight_eq_sum_indicator c ] ; rw [ sq, Finset.sum_mul ] ;
      simp +decide only [Finset.mul_sum _ _ _];
    rw [ Finset.sum_congr rfl fun c hc => h_expand c, Finset.sum_comm, Finset.sum_congr rfl fun i hi => Finset.sum_comm ];
  -- Evaluate the inner sum $\sum_{c} (if c i then 1 else 0) * (if c j then 1 else 0)$.
  have h_inner_sum : ∀ i j : Fin N, ∑ c : NeuralCode N, (if c i then 1 else 0) * (if c j then 1 else 0) = if i = j then 2 ^ (N - 1) else 2 ^ (N - 2) := by
    intro i j; split_ifs <;> simp_all +decide [ Finset.sum_ite ] ;
    · convert NeuralCoding.card_active_coord ( show 1 ≤ N from Fin.pos j ) j using 1;
    · convert card_active_pair i j ‹_› using 2 ; ext ; aesop;
  rcases N with ( _ | _ | N ) <;> simp_all +decide [ Finset.sum_ite, Finset.filter_eq, Finset.filter_ne ];
  · rw [ eq_div_iff ] <;> norm_cast;
  · ring

/-! ## 3. The total squared deviation about the mean -/

/--
**Total squared deviation.**  The sum of squared deviations of the weight
from its mean `N / 2` equals `N · 2 ^ N / 4`.
-/
theorem sum_weight_centered_sq (N : ℕ) :
    ∑ c : NeuralCode N, ((weight c : ℝ) - (N : ℝ) / 2) ^ 2
      = (N : ℝ) * 2 ^ N / 4 := by
  convert congr_arg ( fun x : ℝ => x - N ^ 2 * 2 ^ N / 4 ) ( sum_weight_sq N ) using 1;
  · norm_num [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul ] ; ring;
    rw [ ← Finset.sum_mul _ _ _ ] ; rw [ show ( ∑ x : NeuralCode N, ( weight x : ℝ ) ) = N * 2 ^ ( N - 1 ) by exact mod_cast NeuralCoding.total_weight N ] ; cases N <;> norm_num [ pow_succ' ] at * ; ring;
  · ring

/-! ## 4. The variance -/

/--
**Variance of a dense code's weight is `N / 4`.**  This is the Binomial
`N p (1-p)` variance at `p = 1/2`, the algebraic signature of the independence of
the `N` neurons.
-/
theorem weight_variance (N : ℕ) :
    (∑ c : NeuralCode N, ((weight c : ℝ) - (N : ℝ) / 2) ^ 2) / (2 ^ N : ℝ)
      = (N : ℝ) / 4 := by
  rw [ div_eq_iff ] <;> first | positivity | rw [ sum_weight_centered_sq ] ; ring;

/-! ## 5. Chebyshev concentration -/

/--
**Chebyshev concentration.**  For any threshold `t > 0`, the number of codes
whose weight deviates from the mean `N / 2` by at least `t` is at most
`N · 2 ^ N / (4 t²)`; equivalently the *fraction* of such codes is at most
`N / (4 t²)`.  Dense neural energy concentrates around `N / 2`.
-/
theorem weight_concentration (N : ℕ) {t : ℝ} (ht : 0 < t) :
    ((Finset.univ.filter
        (fun c : NeuralCode N => t ≤ |(weight c : ℝ) - (N : ℝ) / 2|)).card : ℝ)
      ≤ (N : ℝ) * 2 ^ N / (4 * t ^ 2) := by
  rw [ le_div_iff₀ ( by positivity ) ];
  convert mul_le_mul_of_nonneg_right ( show ( ∑ c : NeuralCode N, ( ( weight c : ℝ ) - N / 2 ) ^ 2 ) ≥ ( Finset.card ( Finset.filter ( fun c : NeuralCode N => t ≤ |( weight c : ℝ ) - N / 2| ) Finset.univ ) : ℝ ) * t ^ 2 from ?_ ) zero_le_four using 1 ; ring;
  · rw [ sum_weight_centered_sq ] ; ring;
  · rw [ Finset.card_filter ];
    push_cast;
    rw [ Finset.sum_mul _ _ _ ] ; exact Finset.sum_le_sum fun x _ => by split_ifs <;> nlinarith [ abs_mul_abs_self ( ( weight x : ℝ ) - N / 2 ) ] ;

/-! ## 6. Concentration in a `√N` window -/

/--
**Most codes are near half-active.**  At least three quarters of all `2 ^ N`
codes have weight within `√N` of the mean `N / 2`.  Dense coding concentrates
sharply on the half-active state, with fluctuations of order `√N`.
-/
theorem most_codes_near_half (N : ℕ) (hN : 1 ≤ N) :
    (3 : ℝ) * 2 ^ N / 4
      ≤ ((Finset.univ.filter
          (fun c : NeuralCode N =>
            |(weight c : ℝ) - (N : ℝ) / 2| < Real.sqrt N)).card : ℝ) := by
  -- Let `A := univ.filter (fun c => t ≤ |(weight c:ℝ) - N/2|)` (the deviating codes) and
  -- `B := univ.filter (fun c => |(weight c:ℝ) - N/2| < t)` (the near codes, the goal set).
  set A := Finset.univ.filter (fun c : NeuralCode N => Real.sqrt N ≤ |(weight c : ℝ) - N / 2|)
  set B := Finset.univ.filter (fun c : NeuralCode N => |(weight c : ℝ) - N / 2| < Real.sqrt N);
  -- By `weight_concentration N (t := Real.sqrt N) (show 0 < Real.sqrt N)`, `(A.card:ℝ) ≤ N * 2^N / (4 * (Real.sqrt N)^2)`.
  have hA_card : (A.card : ℝ) ≤ N * 2 ^ N / (4 * (Real.sqrt N) ^ 2) := by
    convert weight_concentration N ( Real.sqrt_pos.mpr ( Nat.cast_pos.mpr hN ) ) using 1;
  -- Since `¬ (t ≤ x) ↔ x < t`, the predicates of `A` and `B` are negations of each other, so
  -- `B.card + A.card = (univ : Finset (NeuralCode N)).card = 2^N`.
  have hB_card : (B.card : ℝ) + (A.card : ℝ) = 2 ^ N := by
    rw_mod_cast [ ← Finset.card_union_of_disjoint ( Finset.disjoint_filter.mpr fun _ _ _ => by linarith ), Finset.filter_union_right ];
    rw [ Finset.filter_true_of_mem fun x _ => lt_or_ge _ _, Finset.card_univ ] ; norm_num [ card_neuralCode ];
  rw [ Real.sq_sqrt ( Nat.cast_nonneg _ ) ] at hA_card ; rw [ le_div_iff₀ ] at hA_card <;> nlinarith [ show ( N : ℝ ) ≥ 1 by norm_cast, pow_pos ( zero_lt_two' ℝ ) N ] ;

end NeuralWeightConcentration