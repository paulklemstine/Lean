/-
# Sprinkling, thinning, and exponential threshold sharpening

This file deepens `Catalog/Combinatorics/BernoulliThresholdCoupling.lean`,
`Catalog/Combinatorics/FiniteRussoFormula.lean` and
`Catalog/Combinatorics/HarrisFKGThresholdCoupling.lean` by adding the *two
source* (sprinkling / thinning) structure of the Bernoulli site measure on a
finite site set.

The engine is a completely general **coordinatewise pushforward formula for
product weights** (`sum_prod_pushforward`): if independent coordinates with
weights `W v` are mapped by a fixed map `g` on the alphabet, the image is again
a product measure whose one-site weights are the `g`-fibre sums of `W v`.

Two instances of the formula drive everything:

* `sum_weight_or`: superposing a `p`-configuration and an independent
  `r`-configuration coordinatewise by `||` gives a Bernoulli configuration of
  density `p + r - p*r` (**sprinkling**);
* `sum_weight_and`: intersecting them by `&&` gives density `p*r`
  (**thinning**).

Combining these with monotonicity of an increasing event yields the two dual
sub/supermultiplicativity laws

* `bernProb_and_le`:  `bernProb (p*r) A ≤ bernProb p A * bernProb r A`,
* `bernProb_or_ge`:  `1 - bernProb (p + r - p*r) A ≤ (1 - bernProb p A) * (1 - bernProb r A)`,

which iterate to the exponential laws `bernProb_pow_le` and
`one_sub_bernProb_sprinkle_pow`, i.e. the classical "`k`-th root trick" of
percolation theory in both directions.  Finally these are applied to horizontal
crossings of the `n × n` grid, giving explicit exponential decay
(`crossing_prob_pow_decay`) and exponential convergence to one
(`crossing_prob_sprinkle_to_one`).

## Main results

* `sum_prod_pushforward`: coordinatewise pushforward of a finite product weight.
* `sum_weight_or`, `sum_weight_and`: sprinkling and thinning identities.
* `bernProb_and_le`, `bernProb_or_ge`: the dual correlation-free product bounds.
* `bernProb_pow_le`, `one_sub_bernProb_sprinkle_pow`: their `k`-fold iterates.
* `bernProb_le_one_sub_pow`, `pow_le_bernProb`: two-sided a priori bounds.
* `crossing_prob_pow_decay`, `crossing_prob_sprinkle_to_one`: quantitative
  consequences for grid crossings.
* `keyMeasure_and_le`, `keyMeasure_or_ge`: the measure-theoretic forms on the
  independent uniform key space.
-/

import Combinatorics.HarrisFKGThresholdCoupling

open Finset MeasureTheory

namespace BernoulliThresholdCoupling

/-! ## A general coordinatewise pushforward formula -/

/-- **Coordinatewise pushforward of a product weight.**  Summing a product
weight `∏ v, W v (c v)` against a function of the coordinatewise image
`g ∘ c` is the same as summing against the pushed-forward product weight, whose
one-coordinate weights are the `g`-fibre sums of `W v`. -/
theorem sum_prod_pushforward {ι K L : Type*} [Fintype ι] [DecidableEq ι]
    [Fintype K] [DecidableEq K] [Fintype L] [DecidableEq L]
    (W : ι → K → ℝ) (g : K → L) (f : (ι → L) → ℝ) :
    ∑ c : ι → K, (∏ v, W v (c v)) * f (fun v => g (c v))
      = ∑ η : ι → L, (∏ v, ∑ k ∈ univ.filter (fun k => g k = η v), W v k) * f η := by
  classical
  rw [← Finset.sum_fiberwise (s := (univ : Finset (ι → K))) (g := fun c => fun v => g (c v))
      (f := fun c => (∏ v, W v (c v)) * f (fun v => g (c v)))]
  refine Finset.sum_congr rfl fun η _ => ?_
  have hfib : (univ.filter fun c : ι → K => (fun v => g (c v)) = η)
      = Fintype.piFinset (fun v => univ.filter (fun k => g k = η v)) := by
    ext c
    simp [Fintype.mem_piFinset, funext_iff]
  rw [hfib, Finset.prod_univ_sum, Finset.sum_mul]
  refine Finset.sum_congr rfl fun c hc => ?_
  rw [Fintype.mem_piFinset] at hc
  have hce : (fun v => g (c v)) = η := funext fun v => by simpa using hc v
  rw [hce]

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The weight of a pair of independent site states, of densities `p` and `r`. -/
def pairWeight (p r : ℝ) : Bool × Bool → ℝ :=
  fun k => (if k.1 then p else 1 - p) * (if k.2 then r else 1 - r)

omit [DecidableEq ι] in
/-- The joint weight of two independent configurations is the product weight of
the pair configuration. -/
theorem weight_mul_weight_eq_prod (p r : ℝ) (η ξ : ι → Bool) :
    weight p η * weight r ξ = ∏ v, pairWeight p r (η v, ξ v) := by
  rw [weight_eq_prod, weight_eq_prod, ← Finset.prod_mul_distrib]
  rfl

/-- Reindexing a double sum over configurations as a single sum over pair
configurations. -/
theorem sum_sum_eq_sum_pair (W : ι → (Bool × Bool) → ℝ) (F : (ι → Bool × Bool) → ℝ) :
    ∑ η : ι → Bool, ∑ ξ : ι → Bool, (∏ v, W v (η v, ξ v)) * F (fun v => (η v, ξ v))
      = ∑ c : ι → Bool × Bool, (∏ v, W v (c v)) * F c := by
  classical
  have h : ∑ q : (ι → Bool) × (ι → Bool),
      (∏ v, W v (q.1 v, q.2 v)) * F (fun v => (q.1 v, q.2 v))
      = ∑ c : ι → Bool × Bool, (∏ v, W v (c v)) * F c := by
    refine (Fintype.sum_equiv
      (Equiv.arrowProdEquivProdArrow ι (fun _ => Bool) (fun _ => Bool)) _ _ ?_).symm
    intro c
    simp [Equiv.arrowProdEquivProdArrow]
  rw [← h, Fintype.sum_prod_type]

/-- **Two-source superposition formula.**  If combining the two site states by
`g` turns the pair weight into the Bernoulli weight of density `q`, then a
`p`-configuration and an independent `r`-configuration combine coordinatewise
into a `q`-configuration. -/
theorem sum_weight_pair (p r q : ℝ) (g : Bool → Bool → Bool)
    (hg : ∀ b : Bool,
      (∑ k ∈ univ.filter (fun k : Bool × Bool => g k.1 k.2 = b), pairWeight p r k)
        = if b then q else 1 - q)
    (f : (ι → Bool) → ℝ) :
    ∑ η : ι → Bool, ∑ ξ : ι → Bool,
        weight p η * weight r ξ * f (fun v => g (η v) (ξ v))
      = ∑ ζ : ι → Bool, weight q ζ * f ζ := by
  classical
  have h1 : ∑ η : ι → Bool, ∑ ξ : ι → Bool,
      weight p η * weight r ξ * f (fun v => g (η v) (ξ v))
      = ∑ c : ι → Bool × Bool, (∏ v, pairWeight p r (c v)) *
          f (fun v => g (c v).1 (c v).2) := by
    rw [← sum_sum_eq_sum_pair (fun _ => pairWeight p r)
      (fun c => f (fun v => g (c v).1 (c v).2))]
    exact Finset.sum_congr rfl fun η _ => Finset.sum_congr rfl fun ξ _ => by
      rw [weight_mul_weight_eq_prod]
  rw [h1, sum_prod_pushforward (fun _ => pairWeight p r) (fun k => g k.1 k.2) f]
  refine Finset.sum_congr rfl fun ζ _ => ?_
  congr 1
  rw [weight_eq_prod]
  exact Finset.prod_congr rfl fun v _ => hg (ζ v)

/-! ## Sprinkling and thinning -/

/-- **Sprinkling identity.**  Superposing an independent `p`-configuration and
`r`-configuration gives a Bernoulli configuration of density `p + r - p*r`. -/
theorem sum_weight_or (p r : ℝ) (f : (ι → Bool) → ℝ) :
    ∑ η : ι → Bool, ∑ ξ : ι → Bool,
        weight p η * weight r ξ * f (fun v => η v || ξ v)
      = ∑ ζ : ι → Bool, weight (p + r - p * r) ζ * f ζ := by
  refine sum_weight_pair p r (p + r - p * r) (fun a b => a || b) (fun b => ?_) f
  cases b <;>
    · simp [Finset.sum_filter, Fintype.sum_prod_type, pairWeight]
      ring

/-- **Thinning identity.**  Intersecting an independent `p`-configuration and
`r`-configuration gives a Bernoulli configuration of density `p*r`. -/
theorem sum_weight_and (p r : ℝ) (f : (ι → Bool) → ℝ) :
    ∑ η : ι → Bool, ∑ ξ : ι → Bool,
        weight p η * weight r ξ * f (fun v => η v && ξ v)
      = ∑ ζ : ι → Bool, weight (p * r) ζ * f ζ := by
  refine sum_weight_pair p r (p * r) (fun a b => a && b) (fun b => ?_) f
  cases b
  · simp [Finset.sum_filter, Fintype.sum_prod_type, pairWeight]
    ring
  · simp [Finset.sum_filter, Fintype.sum_prod_type, pairWeight]

/-! ## The two dual product bounds -/

omit [Fintype ι] [DecidableEq ι] in
/-- For an increasing event, the indicator of the superposition is dominated by
one minus the product of the complementary indicators: if the superposition
fails, both sources fail. -/
theorem indicator_compl_or_le {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (η ξ : ι → Bool) :
    Aᶜ.indicator (fun _ => (1 : ℝ)) (fun v => η v || ξ v) ≤
      Aᶜ.indicator (fun _ => (1 : ℝ)) η * Aᶜ.indicator (fun _ => (1 : ℝ)) ξ := by
  by_cases h : (fun v => η v || ξ v) ∈ Aᶜ
  · have hη : η ∈ Aᶜ := fun hmem =>
      h (hA η _ (fun v hv => by simp [hv]) hmem)
    have hξ : ξ ∈ Aᶜ := fun hmem =>
      h (hA ξ _ (fun v hv => by simp [hv]) hmem)
    rw [Set.indicator_of_mem h, Set.indicator_of_mem hη, Set.indicator_of_mem hξ,
      mul_one]
  · rw [Set.indicator_of_notMem h]
    exact mul_nonneg (Set.indicator_nonneg (fun _ _ => zero_le_one) η)
      (Set.indicator_nonneg (fun _ _ => zero_le_one) ξ)

omit [Fintype ι] [DecidableEq ι] in
/-- For an increasing event, the indicator of the intersection is dominated by
the product of the indicators: if the intersection succeeds, both sources
succeed. -/
theorem indicator_and_le {A : Set (ι → Bool)} (hA : IsIncreasing A) (η ξ : ι → Bool) :
    A.indicator (fun _ => (1 : ℝ)) (fun v => η v && ξ v) ≤
      A.indicator (fun _ => (1 : ℝ)) η * A.indicator (fun _ => (1 : ℝ)) ξ := by
  by_cases h : (fun v => η v && ξ v) ∈ A
  · have hη : η ∈ A := hA _ η (fun v hv => by simpa using (Bool.and_eq_true .. |>.mp hv).1) h
    have hξ : ξ ∈ A := hA _ ξ (fun v hv => by simpa using (Bool.and_eq_true .. |>.mp hv).2) h
    rw [Set.indicator_of_mem h, Set.indicator_of_mem hη, Set.indicator_of_mem hξ,
      mul_one]
  · rw [Set.indicator_of_notMem h]
    exact mul_nonneg (Set.indicator_nonneg (fun _ _ => zero_le_one) η)
      (Set.indicator_nonneg (fun _ _ => zero_le_one) ξ)

/-- A weighted double sum of a product factorizes. -/
theorem sum_sum_mul_factor (p r : ℝ) (u w : (ι → Bool) → ℝ) :
    ∑ η : ι → Bool, ∑ ξ : ι → Bool, weight p η * weight r ξ * (u η * w ξ)
      = (∑ η : ι → Bool, weight p η * u η) * (∑ ξ : ι → Bool, weight r ξ * w ξ) := by
  rw [Finset.sum_mul_sum]
  exact Finset.sum_congr rfl fun η _ => Finset.sum_congr rfl fun ξ _ => by ring

/-- **Thinning bound.**  For an increasing event the Bernoulli probability is
submultiplicative in the density: `bernProb (p*r) A ≤ bernProb p A * bernProb r A`.
Equivalently, an increasing event realized at density `p*r` forces two
independent realizations at densities `p` and `r`. -/
theorem bernProb_and_le {p r : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (hr0 : 0 ≤ r)
    (hr1 : r ≤ 1) {A : Set (ι → Bool)} (hA : IsIncreasing A) :
    bernProb (p * r) A ≤ bernProb p A * bernProb r A := by
  classical
  have hkey := sum_weight_and (ι := ι) p r (A.indicator (fun _ => (1 : ℝ)))
  have hle : ∑ η : ι → Bool, ∑ ξ : ι → Bool,
      weight p η * weight r ξ *
        A.indicator (fun _ => (1 : ℝ)) (fun v => η v && ξ v)
      ≤ ∑ η : ι → Bool, ∑ ξ : ι → Bool, weight p η * weight r ξ *
        (A.indicator (fun _ => (1 : ℝ)) η * A.indicator (fun _ => (1 : ℝ)) ξ) := by
    refine Finset.sum_le_sum fun η _ => Finset.sum_le_sum fun ξ _ => ?_
    exact mul_le_mul_of_nonneg_left (indicator_and_le hA η ξ)
      (mul_nonneg (weight_nonneg hp0 hp1 η) (weight_nonneg hr0 hr1 ξ))
  rw [hkey, sum_sum_mul_factor] at hle
  rw [bernProb_eq_sum_mul_indicator, bernProb_eq_sum_mul_indicator,
    bernProb_eq_sum_mul_indicator]
  exact hle

/-- **Sprinkling bound.**  For an increasing event the failure probability is
submultiplicative under superposition of densities:
`1 - bernProb (p + r - p*r) A ≤ (1 - bernProb p A) * (1 - bernProb r A)`. -/
theorem bernProb_or_ge {p r : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (hr0 : 0 ≤ r)
    (hr1 : r ≤ 1) {A : Set (ι → Bool)} (hA : IsIncreasing A) :
    1 - bernProb (p + r - p * r) A ≤ (1 - bernProb p A) * (1 - bernProb r A) := by
  classical
  have hkey := sum_weight_or (ι := ι) p r (Aᶜ.indicator (fun _ => (1 : ℝ)))
  have hle : ∑ η : ι → Bool, ∑ ξ : ι → Bool,
      weight p η * weight r ξ *
        Aᶜ.indicator (fun _ => (1 : ℝ)) (fun v => η v || ξ v)
      ≤ ∑ η : ι → Bool, ∑ ξ : ι → Bool, weight p η * weight r ξ *
        (Aᶜ.indicator (fun _ => (1 : ℝ)) η * Aᶜ.indicator (fun _ => (1 : ℝ)) ξ) := by
    refine Finset.sum_le_sum fun η _ => Finset.sum_le_sum fun ξ _ => ?_
    exact mul_le_mul_of_nonneg_left (indicator_compl_or_le hA η ξ)
      (mul_nonneg (weight_nonneg hp0 hp1 η) (weight_nonneg hr0 hr1 ξ))
  rw [hkey, sum_sum_mul_factor] at hle
  rw [← bernProb_eq_sum_mul_indicator, ← bernProb_eq_sum_mul_indicator,
    ← bernProb_eq_sum_mul_indicator] at hle
  have e1 : bernProb (p + r - p * r) Aᶜ = 1 - bernProb (p + r - p * r) A := by
    have := bernProb_add_bernProb_compl (ι := ι) (p + r - p * r) A; linarith
  have e2 : bernProb p Aᶜ = 1 - bernProb p A := by
    have := bernProb_add_bernProb_compl (ι := ι) p A; linarith
  have e3 : bernProb r Aᶜ = 1 - bernProb r A := by
    have := bernProb_add_bernProb_compl (ι := ι) r A; linarith
  rwa [e1, e2, e3] at hle

/-- Bernoulli probabilities never exceed one. -/
theorem bernProb_le_one {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (A : Set (ι → Bool)) :
    bernProb p A ≤ 1 := by
  have h := bernProb_add_bernProb_compl (ι := ι) p A
  have := bernProb_nonneg hp0 hp1 Aᶜ
  linarith

/-! ## Iterating: the two exponential laws -/

/-- **Exponential thinning law.**  For an increasing event,
`bernProb (p^k) A ≤ (bernProb p A)^k`.  In a subcritical regime, where
`bernProb p A < 1`, this forces exponential decay along the geometric sequence
of densities. -/
theorem bernProb_pow_le {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {A : Set (ι → Bool)}
    (hA : IsIncreasing A) (k : ℕ) :
    bernProb (p ^ k) A ≤ (bernProb p A) ^ k := by
  induction k with
  | zero =>
    simpa using bernProb_le_one (ι := ι) zero_le_one le_rfl A
  | succ m ih =>
    have hpm0 : 0 ≤ p ^ m := pow_nonneg hp0 m
    have hpm1 : p ^ m ≤ 1 := pow_le_one₀ hp0 hp1
    have hstep := bernProb_and_le (ι := ι) hp0 hp1 hpm0 hpm1 hA
    have hnn : 0 ≤ bernProb p A := bernProb_nonneg hp0 hp1 A
    calc bernProb (p ^ (m + 1)) A = bernProb (p * p ^ m) A := by rw [pow_succ, mul_comm]
      _ ≤ bernProb p A * bernProb (p ^ m) A := hstep
      _ ≤ bernProb p A * (bernProb p A) ^ m := by
          exact mul_le_mul_of_nonneg_left ih hnn
      _ = (bernProb p A) ^ (m + 1) := by ring

/-- **Exponential sprinkling law** (the `k`-th root trick).  For an increasing
event, superposing `k` independent copies at density `p` gives density
`1 - (1-p)^k`, at which the failure probability is at most the `k`-th power of
the failure probability at density `p`. -/
theorem one_sub_bernProb_sprinkle_pow {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {A : Set (ι → Bool)} (hA : IsIncreasing A) (k : ℕ) :
    1 - bernProb (1 - (1 - p) ^ k) A ≤ (1 - bernProb p A) ^ k := by
  induction k with
  | zero =>
    simp only [pow_zero, sub_self]
    have := bernProb_nonneg (ι := ι) (le_refl (0:ℝ)) zero_le_one A
    linarith
  | succ m ih =>
    set q := 1 - (1 - p) ^ m with hq
    have hq0 : 0 ≤ q := by
      have : (1 - p) ^ m ≤ 1 := pow_le_one₀ (by linarith) (by linarith)
      simp only [hq]; linarith
    have hq1 : q ≤ 1 := by
      have : 0 ≤ (1 - p) ^ m := pow_nonneg (by linarith) m
      simp only [hq]; linarith
    have hstep := bernProb_or_ge (ι := ι) hp0 hp1 hq0 hq1 hA
    have hsum : p + q - p * q = 1 - (1 - p) ^ (m + 1) := by
      simp only [hq]; ring
    rw [hsum] at hstep
    have hnn : 0 ≤ 1 - bernProb p A := by
      have h := bernProb_add_bernProb_compl (ι := ι) p A
      have := bernProb_nonneg hp0 hp1 Aᶜ
      linarith
    calc 1 - bernProb (1 - (1 - p) ^ (m + 1)) A
        ≤ (1 - bernProb p A) * (1 - bernProb q A) := hstep
      _ ≤ (1 - bernProb p A) * (1 - bernProb p A) ^ m :=
          mul_le_mul_of_nonneg_left ih hnn
      _ = (1 - bernProb p A) ^ (m + 1) := by ring

/-! ## A priori two-sided bounds -/

omit [DecidableEq ι] in
/-- The all-open configuration has weight `p ^ |ι|`. -/
theorem weight_all_true (p : ℝ) : weight p (fun _ : ι => true) = p ^ Fintype.card ι := by
  rw [weight_eq_prod]
  simp [Finset.prod_const, Finset.card_univ]

omit [DecidableEq ι] in
/-- The all-closed configuration has weight `(1-p) ^ |ι|`. -/
theorem weight_all_false (p : ℝ) :
    weight p (fun _ : ι => false) = (1 - p) ^ Fintype.card ι := by
  rw [weight_eq_prod]
  simp [Finset.prod_const, Finset.card_univ]

/-- **A priori lower bound.**  An event containing the all-open configuration has
probability at least `p ^ |ι|`. -/
theorem pow_le_bernProb {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {A : Set (ι → Bool)}
    (htrue : (fun _ => true) ∈ A) : p ^ Fintype.card ι ≤ bernProb p A := by
  classical
  have h1 : A.indicator (weight p) (fun _ => true) ≤
      ∑ η : ι → Bool, A.indicator (weight p) η :=
    Finset.single_le_sum (f := fun η => A.indicator (weight p) η)
      (fun η _ => Set.indicator_nonneg (fun x _ => weight_nonneg hp0 hp1 x) η)
      (Finset.mem_univ _)
  rwa [Set.indicator_of_mem htrue, weight_all_true] at h1

/-- **A priori upper bound.**  An event missing the all-closed configuration has
probability at most `1 - (1-p) ^ |ι|`. -/
theorem bernProb_le_one_sub_pow {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {A : Set (ι → Bool)} (hfalse : (fun _ => false) ∉ A) :
    bernProb p A ≤ 1 - (1 - p) ^ Fintype.card ι := by
  have hmem : (fun _ : ι => false) ∈ Aᶜ := hfalse
  have hlow : (1 - p) ^ Fintype.card ι ≤ bernProb p Aᶜ := by
    classical
    have h1 : Aᶜ.indicator (weight p) (fun _ => false) ≤
        ∑ η : ι → Bool, Aᶜ.indicator (weight p) η :=
      Finset.single_le_sum (f := fun η => Aᶜ.indicator (weight p) η)
        (fun η _ => Set.indicator_nonneg (fun x _ => weight_nonneg hp0 hp1 x) η)
        (Finset.mem_univ _)
    rwa [Set.indicator_of_mem hmem, weight_all_false] at h1
  have h := bernProb_add_bernProb_compl (ι := ι) p A
  linarith

/-! ## Quantitative consequences for grid crossings -/

/-- **Exponential decay of the crossing probability along geometric densities.**
For the `n × n` grid the horizontal crossing probability at density `p ^ k` is at
most `(1 - (1-p) ^ (n*n)) ^ k`, a quantity that tends to `0` geometrically for
every fixed `p < 1`. -/
theorem crossing_prob_pow_decay (n : ℕ) (hn : 0 < n) {p : ℝ} (hp0 : 0 ≤ p)
    (hp1 : p ≤ 1) (k : ℕ) :
    bernProb (p ^ k) (crossingEvent n hn) ≤
      (1 - (1 - p) ^ (n * n)) ^ k := by
  have hcard : Fintype.card (Fin n × Fin n) = n * n := by simp
  have hupper : bernProb p (crossingEvent n hn) ≤ 1 - (1 - p) ^ (n * n) := by
    have := bernProb_le_one_sub_pow (ι := Fin n × Fin n) hp0 hp1
      (crossingEvent_false_notMem n hn)
    rwa [hcard] at this
  refine le_trans (bernProb_pow_le hp0 hp1 (crossingEvent_isIncreasing n hn) k) ?_
  refine pow_le_pow_left₀ ?_ hupper k
  exact bernProb_nonneg hp0 hp1 _

/-- **Exponential convergence of the crossing probability to one under
sprinkling.**  Superposing `k` independent copies of density `p` on the `n × n`
grid gives crossing failure probability at most `(1 - p ^ (n*n)) ^ k`. -/
theorem crossing_prob_sprinkle_to_one (n : ℕ) (hn : 0 < n) {p : ℝ} (hp0 : 0 ≤ p)
    (hp1 : p ≤ 1) (k : ℕ) :
    1 - bernProb (1 - (1 - p) ^ k) (crossingEvent n hn) ≤
      (1 - p ^ (n * n)) ^ k := by
  have hcard : Fintype.card (Fin n × Fin n) = n * n := by simp
  have htrue : (fun _ : Fin n × Fin n => true) ∈ crossingEvent n hn := by
    obtain ⟨η, hη⟩ := crossingEvent_nonempty n hn
    exact crossingEvent_isIncreasing n hn η _ (fun _ _ => rfl) hη
  have hlow : p ^ (n * n) ≤ bernProb p (crossingEvent n hn) := by
    have := pow_le_bernProb (ι := Fin n × Fin n) hp0 hp1 htrue
    rwa [hcard] at this
  refine le_trans (one_sub_bernProb_sprinkle_pow hp0 hp1
    (crossingEvent_isIncreasing n hn) k) ?_
  refine pow_le_pow_left₀ ?_ (by linarith) k
  have h := bernProb_add_bernProb_compl (ι := Fin n × Fin n) p (crossingEvent n hn)
  have := bernProb_nonneg (ι := Fin n × Fin n) hp0 hp1 (crossingEvent n hn)ᶜ
  linarith

/-! ## The key-measure forms -/

/-- **Thinning bound on the key probability space.** -/
theorem keyMeasure_and_le {p r : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (hr0 : 0 ≤ r)
    (hr1 : r ≤ 1) {A : Set (ι → Bool)} (hA : IsIncreasing A) :
    keyMeasure ι (eventKeys (p * r) A) ≤
      ENNReal.ofReal (bernProb p A) * ENNReal.ofReal (bernProb r A) := by
  rw [keyMeasure_eventKeys (mul_nonneg hp0 hr0) (by nlinarith) A,
    ← ENNReal.ofReal_mul (bernProb_nonneg hp0 hp1 A)]
  exact ENNReal.ofReal_le_ofReal (bernProb_and_le hp0 hp1 hr0 hr1 hA)

/-- **Sprinkling bound on the key probability space**: the failure probability at
the superposed density is at most the product of the failure probabilities. -/
theorem keyMeasure_or_ge {p r : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (hr0 : 0 ≤ r)
    (hr1 : r ≤ 1) {A : Set (ι → Bool)} (hA : IsIncreasing A) :
    1 - ENNReal.toReal (keyMeasure ι (eventKeys (p + r - p * r) A)) ≤
      (1 - bernProb p A) * (1 - bernProb r A) := by
  have hq0 : 0 ≤ p + r - p * r := by nlinarith
  have hq1 : p + r - p * r ≤ 1 := by nlinarith
  rw [keyMeasure_eventKeys hq0 hq1 A,
    ENNReal.toReal_ofReal (bernProb_nonneg hq0 hq1 A)]
  exact bernProb_or_ge hp0 hp1 hr0 hr1 hA

end BernoulliThresholdCoupling