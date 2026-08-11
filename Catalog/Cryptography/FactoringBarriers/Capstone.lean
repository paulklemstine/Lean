import Cryptography.FactoringBarriers.ResourceClassification
import Cryptography.FactoringBarriers.CongruenceOfSquares
import Cryptography.FactoringBarriers.DFTSampleBound

/-!
# Capstone: A Conditional-Impossibility Schema for Classical Factoring

This file assembles the framework and — crucially — keeps its three logical
levels apart.

**Level 1 (unconditional theorems).**
* `barrierCost_superpoly` (imported): each of the four classified barriers is
  superpolynomial in `log N`.
* `congruence_of_squares` (imported): the structural core reduction is
  unconditional.
* `dft_sample_count_ge_period` (imported): the Fourier sample bound `K ≥ r` is
  information-theoretic and unconditional.
* `tradeoff_lower_bound` and `arithmetic_trajectory_blind` (in
  `TradeoffBarrier.lean` and `RandomnessBarrier.lean`): the sieve exponent `1/k`
  is forced by AM–GM, and collision-based methods are provably blind for
  `min p q` steps in the worst case.

**Level 2 (conditional impossibility — proved here).**
`conditional_impossibility`: *if* a classical algorithm factors in
`poly(log N)`, *then* its cost is not bounded below by any classified barrier;
equivalently, the resource it exploits is outside the classified set
`{randomness, smoothness, iteration, analog}`.  This is a logical consequence of
the classification, **not** an unconditional lower bound on factoring.

**Level 3 (scope — a definition, not a theorem).**
`ClassifiedResourceHypothesis`: the assertion that every classical algorithm is
limited by one of the four classified barriers.  We *do not* prove it — it is a
statement about the unknown.  What we do prove is `no_poly_under_CRH`: it
implies no polynomial-time classical factoring algorithm exists, and
`CRH_falsified_by_poly`: any polynomial-time algorithm falsifies it.  The
framework is therefore a genuine classification of the known plus an honest
conditional, never a proof that the unknown is empty.
-/

namespace FactoringBarriers

open Filter Real
open scoped Topology

/-! ## Abstract classical algorithms -/

/-- A classical factoring algorithm, abstracted to its running-time profile
`cost x` as a function of the bit-size parameter `x = log N`. -/
structure ClassicalAlgorithm where
  /-- Running time as a function of `x = log N`. -/
  cost : ℝ → ℝ
  /-- Any algorithm performs at least one step. -/
  one_le_cost : ∀ᶠ x in atTop, 1 ≤ cost x

/-- `A` runs in polynomial time in the bit-size. -/
def PolyTime (A : ClassicalAlgorithm) : Prop := PolyBounded A.cost

/-- `A` is *limited by* the classified resource `rho`: its cost is eventually at
least the barrier documented for `rho`. -/
def LimitedBy (A : ClassicalAlgorithm) (rho : ClassicalResource) : Prop :=
  ∀ᶠ x in atTop, barrierCost rho x ≤ A.cost x

/-- The algorithm's resource lies inside the classified set. -/
def UsesClassifiedResource (A : ClassicalAlgorithm) : Prop :=
  ∃ rho : ClassicalResource, LimitedBy A rho

/-! ## Positivity of the barriers -/

theorem barrierCost_pos (rho : ClassicalResource) (x : ℝ) : 0 < barrierCost rho x := by
  cases rho <;> simp [barrierCost, Lfun, Real.exp_pos]

/-! ## Level 2: the conditional-impossibility chain -/

/-- **Step 1 of the chain.** A polynomially bounded algorithm is eventually
*strictly faster* than every classified barrier. -/
theorem cost_eventually_lt_barrier {A : ClassicalAlgorithm} (h : PolyTime A)
    (rho : ClassicalResource) : ∀ᶠ x in atTop, A.cost x < barrierCost rho x := by
  obtain ⟨C, d, hCd⟩ := h
  have hsuper := barrierCost_superpoly rho d
  have hbig : ∀ᶠ x : ℝ in atTop, C + 1 < barrierCost rho x / x ^ d :=
    hsuper.eventually (eventually_gt_atTop (C + 1))
  filter_upwards [hCd, hbig, eventually_gt_atTop (1 : ℝ)] with x hx hb hx1
  have hx0 : (0:ℝ) < x := lt_trans one_pos hx1
  have hxd : (0:ℝ) < x ^ d := Real.rpow_pos_of_pos hx0 d
  have h1 : (C + 1) * x ^ d < barrierCost rho x := by
    rw [← lt_div_iff₀ hxd]; exact hb
  nlinarith [hx, h1, hxd]

/-- **Step 2 of the chain.** Hence a polynomially bounded algorithm cannot be
limited by any classified barrier. -/
theorem not_limitedBy_of_polyTime {A : ClassicalAlgorithm} (h : PolyTime A)
    (rho : ClassicalResource) : ¬ LimitedBy A rho := by
  intro hlim
  obtain ⟨x, h1, h2⟩ := ((cost_eventually_lt_barrier h rho).and hlim).exists
  linarith

/-- **Conditional impossibility (main theorem).**
IF a classical algorithm factors semiprimes in `poly(log N)` time,
THEN it is not limited by any of the classified barriers, i.e. the resource it
exploits lies *outside* `{randomness, smoothness, iteration, analog}`.

This is a logical consequence of the classification; it is **not** an
unconditional lower bound on factoring. -/
theorem conditional_impossibility (A : ClassicalAlgorithm) (h : PolyTime A) :
    ¬ UsesClassifiedResource A := by
  rintro ⟨rho, hrho⟩
  exact not_limitedBy_of_polyTime h rho hrho

/-- Contrapositive form: an algorithm confined to the classified resources
cannot be polynomial time. -/
theorem no_polyTime_of_classified (A : ClassicalAlgorithm) (h : UsesClassifiedResource A) :
    ¬ PolyTime A := fun hp => conditional_impossibility A hp h

/-- **Quantitative form.** For a polynomial-time algorithm the gap to every
classified barrier is not merely positive but unbounded: the barrier exceeds the
cost by an arbitrarily large factor. -/
theorem barrier_over_cost_atTop {A : ClassicalAlgorithm} (h : PolyTime A)
    (rho : ClassicalResource) :
    Tendsto (fun x => barrierCost rho x / A.cost x) atTop atTop := by
  obtain ⟨C, d, hCd⟩ := h
  have hC : 0 < C := by
    obtain ⟨x, hx, h1, hx1⟩ :=
      (hCd.and (A.one_le_cost.and (eventually_gt_atTop (1 : ℝ)))).exists
    have hx0 : (0:ℝ) < x := lt_trans one_pos hx1
    have hxd : (0:ℝ) < x ^ d := Real.rpow_pos_of_pos hx0 d
    nlinarith
  have hsuper := barrierCost_superpoly rho d
  have hmain : Tendsto (fun x => (barrierCost rho x / x ^ d) / C) atTop atTop :=
    Filter.Tendsto.atTop_div_const hC hsuper
  refine tendsto_atTop_mono' atTop ?_ hmain
  filter_upwards [hCd, A.one_le_cost, eventually_gt_atTop (1 : ℝ)] with x hx h1 hx1
  have hx0 : (0:ℝ) < x := lt_trans one_pos hx1
  have hxd : (0:ℝ) < x ^ d := Real.rpow_pos_of_pos hx0 d
  have hcpos : 0 < A.cost x := lt_of_lt_of_le one_pos h1
  have hb := barrierCost_pos rho x
  rw [div_div, div_le_div_iff_of_pos_left hb (by positivity) hcpos]
  linarith [hx]

/-! ## Level 3: the scope of the framework, stated honestly -/

/-- The **Classified Resource Hypothesis**: every classical factoring algorithm
is limited by one of the four classified barriers.  This is a hypothesis about
the *unknown*; the framework does not prove it, and the capstone theorems below
are explicitly conditional on it. -/
def ClassifiedResourceHypothesis : Prop :=
  ∀ A : ClassicalAlgorithm, UsesClassifiedResource A

/-- Under the Classified Resource Hypothesis there is no polynomial-time
classical factoring algorithm. -/
theorem no_poly_under_CRH (hCRH : ClassifiedResourceHypothesis) :
    ∀ A : ClassicalAlgorithm, ¬ PolyTime A :=
  fun A => no_polyTime_of_classified A (hCRH A)

/-- Conversely, exhibiting a polynomial-time classical factoring algorithm
*falsifies* the Classified Resource Hypothesis: its resource would have to be
genuinely novel. -/
theorem CRH_falsified_by_poly (A : ClassicalAlgorithm) (h : PolyTime A) :
    ¬ ClassifiedResourceHypothesis :=
  fun hCRH => conditional_impossibility A h (hCRH A)

/-! ## The schema is not vacuous

Both sides of the conditional are inhabited, so neither `PolyTime` nor
`UsesClassifiedResource` is an empty predicate and the implication has content. -/

/-- The abstract algorithm whose cost profile *is* the barrier for `rho`. -/
noncomputable def barrierAlgorithm (rho : ClassicalResource) : ClassicalAlgorithm where
  cost := barrierCost rho
  one_le_cost := by
    filter_upwards [(barrierCost_superpoly rho 0).eventually (eventually_ge_atTop (1:ℝ)),
      eventually_gt_atTop (0:ℝ)] with x hx hx0
    simpa [Real.rpow_zero] using hx

/-- A polynomial cost profile, e.g. `x ↦ x²`. -/
noncomputable def quadraticAlgorithm : ClassicalAlgorithm where
  cost := fun x => x ^ (2 : ℝ)
  one_le_cost := by
    filter_upwards [eventually_ge_atTop (1:ℝ)] with x hx
    exact Real.one_le_rpow hx (by norm_num)

theorem barrierAlgorithm_usesClassified (rho : ClassicalResource) :
    UsesClassifiedResource (barrierAlgorithm rho) :=
  ⟨rho, Filter.Eventually.of_forall (fun _ => le_refl _)⟩

theorem barrierAlgorithm_not_polyTime (rho : ClassicalResource) :
    ¬ PolyTime (barrierAlgorithm rho) :=
  no_polyTime_of_classified _ (barrierAlgorithm_usesClassified rho)

theorem quadraticAlgorithm_polyTime : PolyTime quadraticAlgorithm :=
  ⟨1, 2, Filter.Eventually.of_forall (fun x => by simp [quadraticAlgorithm])⟩

/-- Non-vacuity: the classified side and the polynomial side are both inhabited,
and they are disjoint. -/
theorem schema_nonvacuous :
    (∃ A : ClassicalAlgorithm, UsesClassifiedResource A ∧ ¬ PolyTime A) ∧
    (∃ A : ClassicalAlgorithm, PolyTime A ∧ ¬ UsesClassifiedResource A) :=
  ⟨⟨barrierAlgorithm .smoothness, barrierAlgorithm_usesClassified _,
      barrierAlgorithm_not_polyTime _⟩,
   ⟨quadraticAlgorithm, quadraticAlgorithm_polyTime,
      conditional_impossibility _ quadraticAlgorithm_polyTime⟩⟩

/-! ## The capstone statement -/

/-- **Capstone.** For every classical factoring algorithm running in polynomial
time in `log N`:

1. it beats every classified barrier by an unbounded factor
   (`barrier_over_cost_atTop`);
2. it is limited by none of `{randomness, smoothness, iteration, analog}`
   (`conditional_impossibility`);
3. consequently the Classified Resource Hypothesis fails, i.e. the resource it
   exploits is genuinely outside the classified catalogue.

The theorem is a rigorous *conditional*: it derives strong structural
consequences from the hypothetical existence of a fast classical algorithm,
without asserting that no such algorithm exists. -/
theorem capstone (A : ClassicalAlgorithm) (h : PolyTime A) :
    (∀ rho : ClassicalResource, Tendsto (fun x => barrierCost rho x / A.cost x) atTop atTop) ∧
    (∀ rho : ClassicalResource, ¬ LimitedBy A rho) ∧
    ¬ UsesClassifiedResource A ∧
    ¬ ClassifiedResourceHypothesis :=
  ⟨fun rho => barrier_over_cost_atTop h rho,
   fun rho => not_limitedBy_of_polyTime h rho,
   conditional_impossibility A h,
   CRH_falsified_by_poly A h⟩

/-! ## Where the quantum resource sits

The framework does not classify quantum resources, and indeed the two
unconditional facts we proved about the quantum route point in the opposite
direction: the structural reduction `order_finding_yields_factor` is free, and
the only information-theoretic obstruction we could establish for Fourier
sampling, `dft_sample_count_ge_period`, is a bound on the number of *samples*
(`K ≥ r`), which superposition supplies in one shot.  We record the combination
as a single statement to make the boundary of the framework explicit. -/

/-- Boundary statement: the classical reduction from order finding to
factorization is unconditional, while any *sampling-based* determination of the
period needs at least `r` Fourier samples. -/
theorem quantum_boundary {N : ℕ} (hN : 1 < N) {a : ℤ} {s : ℕ}
    (hord : (N : ℤ) ∣ a ^ (2 * s) - 1)
    (hm : ¬ (N : ℤ) ∣ (a ^ s - 1)) (hp : ¬ (N : ℤ) ∣ (a ^ s + 1))
    {r K : ℕ} [NeZero r] (idx : Fin K → ZMod r)
    (hdet : ∀ v w : ZMod r → ℂ, (∀ j : Fin K, ZMod.dft v (idx j) = ZMod.dft w (idx j)) → v = w) :
    NontrivialDivisor N (Int.gcd (a ^ s - 1) (N : ℤ)) ∧ r ≤ K :=
  ⟨order_finding_yields_factor hN hord hm hp, dft_sample_count_ge_period idx hdet⟩

end FactoringBarriers