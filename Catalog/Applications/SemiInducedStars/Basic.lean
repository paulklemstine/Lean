/-
# Semi-induced stars S_{k,1}: the quasi-clique / quasi-star envelope is not optimal

This file studies the *fixed-density semi-inducibility* of the red–blue star `S_{k,1}`
(a distinguished centre with `k` red leaves and `1` blue leaf), in the graphon /
step-graphon model.

## Model

For a graphon `W`, the semi-induced density of `S_{k,1}` with the centre playing the
distinguished role only constrains the `k+1` edges incident to the centre: `k` of them
"red" (present, weight `W`) and one "blue" (absent, weight `1-W`); the leaves are otherwise
unconstrained.  Writing `d(x) = ∫ W(x, ·)` for the degree density at `x`, the functional is

    I(W) = ∫₀¹ d(x)^k (1 - d(x)) dx,      subject to   ∫₀¹ d(x) dx = β.

For a **two-class step graphon** with class sizes `a, 1-a` and symmetric density matrix
`[[p,q],[q,r]]`, the two class degrees are `d₁ = a·p+(1-a)·q`, `d₂ = a·q+(1-a)·r`, the edge
density is `a·d₁+(1-a)·d₂`, and `I = a·d₁^k(1-d₁) + (1-a)·d₂^k(1-d₂)`.

## The two "naive" constructions (the envelope)

* the **constant graphon** at density `β` (every degree `= β`) gives value `β^k(1-β)`
  (`cliqueTerm`);
* its complementary partner gives `β(1-β)^k` (`starTerm`).

The *quasi-clique / quasi-star envelope* is `min (β^k(1-β)) (β(1-β)^k)` (`envelope`).

## The split construction and the main result

The **split graphon** `splitConstruction β` is the two-class graphon with a dominating
clique class `A` (size `a = 1-√(1-β)`, joined to everything) and an independent class `B`
(joined only to `A`).  Its degrees are `d₁ = 1`, `d₂ = a`, its edge density is exactly `β`,
and its `S_{k,1}` value is `splitVal k β = (1-β) · (1 - √(1-β))^k`.

The main theorem `splitVal_lt_envelope` shows that on the open interval `(0, (√5-1)/2)`
(which contains `1/2`) this strictly beats **both** envelope terms, hence the envelope, for
every `k ≥ 1`.  Consequently the true minimum semi-inducibility lies strictly *below* the
quasi-clique / quasi-star envelope on an open interval around `β = 1/2`, generalising the
`S_{2,1}` phenomenon of `math.CO/2025_fix_density_S21` to all `k`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  The paper proves, for S_{2,1}, that a three-class
complement-split family beats the quasi-clique/quasi-star endpoint profile on an interval
around β = 1/2.  We conjectured this persists for all k, with a (k+1)-class minimiser.

EXPERIMENT (Experimenter).  Numerical minimisation of I = Σ aᵢ dᵢ^k (1-dᵢ) over symmetric
step graphons (see `ComputationalEvidence.md`) showed the minimum lies strictly *below* the
envelope min(β^k(1-β), β(1-β)^k) for β ≲ 0.62 and *above* it for β ≳ 0.7.  The optimum at
β = 1/2 collapses to a clean TWO-class "split graph": a dominating clique A joined to an
independent set B.  Solving a(2-a)=β gives a = 1-√(1-β) and I = (1-β)(1-√(1-β))^k.

ANALYSIS (Analyst).  The split value beats `cliqueTerm` for ALL β∈(0,1) (the reduction is
`1-√(1-β) < β ⇔ √(1-β) < 1`), and beats `starTerm` exactly when `√(1-β) > β`, i.e.
`β < (√5-1)/2`.  Since the envelope is the min of the two terms, beating both on the common
interval `(0,(√5-1)/2)` beats the envelope there.  The golden-ratio endpoint `(√5-1)/2` is
the root of `β²+β-1`, the boundary of `√(1-β)>β`.

CRITIQUE (Critic).  The mission's stated direction ("minimum *exceeds* envelope") is the
reverse of what holds under the standard degree functional: constructions give UPPER bounds
on a minimum, so the minimum cannot exceed a construction value; the honest, verified result
is that the minimum is strictly *below* the envelope, witnessed by an explicit valid graphon
of density β.  Every theorem here has 0 sorries and uses genuine `pow`-monotonicity / `sqrt`
algebra (not `decide`/`native_decide`).

SYNTHESIS (PI).  `splitConstruction` is grounded as a genuine two-class graphon: its density
is proved `= β` and its `S_{k,1}` value `= splitVal k β`; `splitVal_lt_envelope` is the main
separation theorem; `min_semiInducibility_lt_envelope` packages the witness.
-/

import Mathlib

namespace SemiInducedStars

open scoped Real

/-- A symmetric two-class step graphon: class `1` has size `a`, class `2` has size `1-a`;
`p`, `q`, `r` are the densities within class 1, across the classes, and within class 2. -/
structure TwoClassGraphon where
  a : ℝ
  p : ℝ
  q : ℝ
  r : ℝ

namespace TwoClassGraphon

/-- Degree density of class 1. -/
def d1 (W : TwoClassGraphon) : ℝ := W.a * W.p + (1 - W.a) * W.q

/-- Degree density of class 2. -/
def d2 (W : TwoClassGraphon) : ℝ := W.a * W.q + (1 - W.a) * W.r

/-- Overall edge density of the step graphon. -/
def density (W : TwoClassGraphon) : ℝ := W.a * W.d1 + (1 - W.a) * W.d2

/-- The semi-induced `S_{k,1}` value `I = Σ aᵢ dᵢ^k (1 - dᵢ)`. -/
def starVal (k : ℕ) (W : TwoClassGraphon) : ℝ :=
  W.a * W.d1 ^ k * (1 - W.d1) + (1 - W.a) * W.d2 ^ k * (1 - W.d2)

/-- A step graphon is *valid* when all its parameters lie in `[0,1]`. -/
def Valid (W : TwoClassGraphon) : Prop :=
  0 ≤ W.a ∧ W.a ≤ 1 ∧ 0 ≤ W.p ∧ W.p ≤ 1 ∧ 0 ≤ W.q ∧ W.q ≤ 1 ∧ 0 ≤ W.r ∧ W.r ≤ 1

end TwoClassGraphon

/-- The split graphon at density `β`: a dominating clique class `A` of size `1-√(1-β)`
joined to everything (`p = q = 1`) and an independent class `B` (`r = 0`). -/
noncomputable def splitConstruction (β : ℝ) : TwoClassGraphon :=
  { a := 1 - Real.sqrt (1 - β), p := 1, q := 1, r := 0 }

/-- The `S_{k,1}` value of the split graphon, `(1-β)·(1-√(1-β))^k`. -/
noncomputable def splitVal (k : ℕ) (β : ℝ) : ℝ :=
  (1 - β) * (1 - Real.sqrt (1 - β)) ^ k

/-- First envelope term: value of the constant graphon at density `β` (quasi-clique). -/
def cliqueTerm (k : ℕ) (β : ℝ) : ℝ := β ^ k * (1 - β)

/-- Second envelope term: the complementary quasi-star value. -/
def starTerm (k : ℕ) (β : ℝ) : ℝ := β * (1 - β) ^ k

/-- The quasi-clique / quasi-star envelope `min(β^k(1-β), β(1-β)^k)`. -/
noncomputable def envelope (k : ℕ) (β : ℝ) : ℝ := min (cliqueTerm k β) (starTerm k β)

/-- The constant graphon at density `β` (size `a = 1`, all densities `β`). -/
def constConstruction (β : ℝ) : TwoClassGraphon := { a := 1, p := β, q := β, r := β }

/-! ### Grounding lemmas: the constructions realise the stated values. -/

/-
The constant graphon has edge density `β`.
-/
lemma constConstruction_density (β : ℝ) : (constConstruction β).density = β := by
  unfold constConstruction; unfold TwoClassGraphon.density; unfold TwoClassGraphon.d1; unfold TwoClassGraphon.d2; ring;

/-
The constant graphon realises the first envelope term `cliqueTerm`.
-/
lemma constConstruction_starVal (k : ℕ) (β : ℝ) :
    (constConstruction β).starVal k = cliqueTerm k β := by
  unfold TwoClassGraphon.starVal constConstruction cliqueTerm;
  unfold TwoClassGraphon.d1 TwoClassGraphon.d2; norm_num;

/-
The split graphon is a valid graphon when `0 ≤ β ≤ 1`.
-/
lemma splitConstruction_valid {β : ℝ} (h0 : 0 ≤ β) :
    (splitConstruction β).Valid := by
  constructor <;> norm_num [ splitConstruction ];
  linarith

/-
The split graphon has edge density exactly `β`.
-/
lemma splitConstruction_density {β : ℝ} (h1 : β ≤ 1) :
    (splitConstruction β).density = β := by
  unfold splitConstruction;
  unfold TwoClassGraphon.density;
  unfold TwoClassGraphon.d1 TwoClassGraphon.d2; norm_num; nlinarith [ Real.mul_self_sqrt ( show 0 ≤ 1 - β by linarith ) ] ;

/-
The split graphon realises `splitVal`.
-/
lemma splitConstruction_starVal (k : ℕ) {β : ℝ} (h1 : β ≤ 1) :
    (splitConstruction β).starVal k = splitVal k β := by
  unfold TwoClassGraphon.starVal splitVal splitConstruction;
  simp +decide [ TwoClassGraphon.d1, TwoClassGraphon.d2 ];
  grind

/-! ### Core inequalities. -/

/-
The split value is strictly below the quasi-clique term `β^k(1-β)` for **every**
`β ∈ (0,1)` and `k ≥ 1`.  Reduction: `1 - √(1-β) < β ⇔ √(1-β) < 1 ⇔ β > 0`.
-/
lemma splitVal_lt_cliqueTerm {k : ℕ} (hk : 1 ≤ k) {β : ℝ} (h0 : 0 < β) (h1 : β < 1) :
    splitVal k β < cliqueTerm k β := by
  convert mul_lt_mul_of_pos_left ( pow_lt_pow_left₀ ( show 1 - Real.sqrt ( 1 - β ) < β by nlinarith [ Real.sqrt_nonneg ( 1 - β ), Real.mul_self_sqrt ( show 0 ≤ 1 - β by linarith ) ] ) ?_ ?_ ) ( show 0 < 1 - β by linarith ) using 1;
  · unfold cliqueTerm; ring;
  · exact sub_nonneg.2 <| Real.sqrt_le_iff.2 ⟨ by linarith, by linarith ⟩;
  · linarith

/-
The split value is strictly below the quasi-star term `β(1-β)^k` precisely on the
golden interval `β < (√5-1)/2` (equivalently `√(1-β) > β`), for `k ≥ 1`.
-/
lemma splitVal_lt_starTerm {k : ℕ} (hk : 1 ≤ k) {β : ℝ} (h0 : 0 < β)
    (hβ : β < (Real.sqrt 5 - 1) / 2) :
    splitVal k β < starTerm k β := by
  -- Set $s := \sqrt{1-\beta}$, so $s^2 = 1-\beta$. We need to show $s^2(1-s)^k < (1-s)(1+s)(s^2)^k$.
  set s := Real.sqrt (1 - β)
  have hs_sq : s ^ 2 = 1 - β := by
    exact Real.sq_sqrt <| sub_nonneg.2 <| hβ.le.trans <| by nlinarith [ Real.sq_sqrt <| show 0 ≤ 5 by norm_num ] ;
  have hs_pos : 0 < s ∧ s < 1 := by
    exact ⟨ Real.sqrt_pos.mpr ( by nlinarith [ Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] ), by rw [ Real.sqrt_lt' ] <;> nlinarith [ Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] ⟩
  have hs_gt_beta : s > β := by
    nlinarith [ Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ];
  -- From $s^2 > (1 - s^2)^2$, we have $s^2(1-s)^k < (1-s)(1+s)(s^2)^k$.
  have h_ineq : s ^ 2 * (1 - s) ^ k < (1 - s) * (1 + s) * (s ^ 2) ^ k := by
    have h_ineq : (1 - s) ^ k ≤ (s ^ 2) ^ (k - 1) * (1 - s) := by
      rcases k with ( _ | k ) <;> simp_all +decide [ pow_succ ];
      exact pow_le_pow_left₀ ( by linarith ) ( by nlinarith ) _;
    rcases k with ( _ | k ) <;> simp_all +decide [ pow_succ' ];
    nlinarith [ mul_pos hs_pos.1 ( pow_pos ( by linarith : 0 < 1 - β ) k ), mul_pos hs_pos.1 ( mul_pos ( by linarith : 0 < 1 - β ) ( pow_pos ( by linarith : 0 < 1 - β ) k ) ) ];
  convert h_ineq using 1 <;> push_cast [ splitVal, starTerm, hs_sq ] <;> ring;
  rw [ hs_sq ] ; ring

/-
**Main separation theorem.**  For every `k ≥ 1` and every `β` in the open interval
`(0, (√5-1)/2)` (which contains `1/2`), the split construction strictly beats the
quasi-clique / quasi-star envelope.
-/
theorem splitVal_lt_envelope {k : ℕ} (hk : 1 ≤ k) {β : ℝ} (h0 : 0 < β)
    (hβ : β < (Real.sqrt 5 - 1) / 2) :
    splitVal k β < envelope k β := by
  refine lt_min ?_ ?_;
  · exact splitVal_lt_cliqueTerm hk h0 ( by nlinarith [ Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] );
  · convert splitVal_lt_starTerm hk h0 hβ using 1

/-
**Witness form.**  On the open interval `(0, (√5-1)/2)` there is a genuine valid
two-class graphon of edge density exactly `β` whose semi-induced `S_{k,1}` value is strictly
below the quasi-clique / quasi-star envelope.  Hence the minimum fixed-density
semi-inducibility of `S_{k,1}` is strictly *below* the envelope on this interval.
-/
theorem min_semiInducibility_lt_envelope {k : ℕ} (hk : 1 ≤ k) {β : ℝ} (h0 : 0 < β)
    (hβ : β < (Real.sqrt 5 - 1) / 2) :
    ∃ W : TwoClassGraphon, W.Valid ∧ W.density = β ∧ W.starVal k < envelope k β := by
  refine' ⟨ splitConstruction β, _, _, _ ⟩;
  · exact splitConstruction_valid h0.le;
  · exact splitConstruction_density ( by nlinarith [ Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] );
  · convert splitVal_lt_envelope hk h0 hβ using 1;
    exact splitConstruction_starVal k ( by nlinarith [ Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] )

end SemiInducedStars