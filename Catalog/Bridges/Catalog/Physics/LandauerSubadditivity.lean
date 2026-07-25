import Mathlib
import Logic.JarzynskiLandauer
import Physics.LandauerRelativeEntropy
import Physics.LandauerSecondLaw

/-!
# Subadditivity of Entropy and Landauer's Cost of Erasing Correlated Memories

**Catalog category: cross-domain bridge (extends the Landauer development).**

Every prior Landauer file in the catalog treats a *single* memory: a one-bit register
(`Logic.JarzynskiLandauer`), the uniform `n`-bit register
(`Physics.LandauerThermodynamicLimit`), or an arbitrary single distribution
(`Physics.LandauerMaxEntropy`). None treats two *correlated* memories. Yet the most
striking nanoscale prediction of Landauer's principle is precisely about correlations:

> erasing two correlated memories jointly is **cheaper** than erasing them separately,
> the saving being exactly `k·T·I(X;Y)` where `I(X;Y)` is the mutual information.

This is the thermodynamic content of subadditivity of entropy and the information-engine
/ Maxwell-demon mechanism.

We develop, over a finite joint sample space `X × Y`:

* the **marginals** `marginalX`, `marginalY` of a joint PMF and the fact that they are
  PMFs;
* a **strengthened Gibbs inequality** `relativeEntropy_nonneg'` allowing the reference
  `q` to vanish wherever `p` does (absolute continuity), needed because product
  marginals are not strictly positive in general;
* the **mutual information** `mutualInfo p = D(p ‖ marginalX p ⊗ marginalY p)` and the
  entropy-decomposition identity `I(X;Y) = H(X) + H(Y) − H(X,Y)`;
* its **nonnegativity** `mutualInfo_nonneg` (Gibbs), hence **subadditivity of Shannon
  entropy** `H(X,Y) ≤ H(X) + H(Y)`, with **equality iff independent**;
* the **Landauer corollaries**: the joint Landauer cost `k·T·H(X,Y)` never exceeds the
  separate cost `k·T·(H(X)+H(Y))`, the gap being `k·T·I(X;Y) ≥ 0`.

## Main results

* `marginalX_isPMF`, `marginalY_isPMF` — marginals of a joint PMF are PMFs.
* `relativeEntropy_nonneg'` — Gibbs' inequality under absolute continuity.
* `prodDist_isPMF` — the product of two PMFs is a PMF.
* `mutualInfo_eq_entropy` — `I(X;Y) = H(X) + H(Y) − H(X,Y)`.
* `mutualInfo_nonneg` — `I(X;Y) ≥ 0`.
* `shannonEntropy_subadditive` — `H(X,Y) ≤ H(X) + H(Y)`.
* `mutualInfo_indep_eq_zero` — independent memories have zero mutual information.
* `landauer_joint_le_separate` — joint erasure cost ≤ separate erasure cost.
* `landauer_correlation_saving` — the saving is exactly `k·T·I(X;Y)`.

## References
- Landauer, R. (1961). Irreversibility and heat generation in the computing process.
- Bennett, C.H. (1982). The thermodynamics of computation — a review.
- Cover, T.M. & Thomas, J.A. (2006). Elements of Information Theory (subadditivity).
- del Rio, L. et al. (2011). The thermodynamic meaning of negative entropy (erasure with
  side information).
-/

noncomputable section

open BigOperators Real Finset
open JarzynskiLandauer LandauerRelativeEntropy

namespace LandauerSubadditivity

/-
!-- Lab Notes -- !--
Hypothesis (Hypothesizer): Correlations should make joint erasure cheaper than separate
erasure, the saving being kT·I(X;Y). Equivalently, Shannon entropy is subadditive,
H(X,Y) ≤ H(X)+H(Y), with equality iff the two memories are independent.
Experiment (Experimenter): Realised mutual information as a relative entropy
I = D(p ‖ marginalX⊗marginalY), so its nonnegativity is just Gibbs. The catalog's Gibbs
(relativeEntropy_nonneg) demands q>0 everywhere, but product marginals can vanish; so we
prove a strengthened Gibbs under absolute continuity (q ω = 0 → p ω = 0). The pointwise
bound p·log(p/q) ≥ p−q still holds: at p=0 it reads 0 ≥ −q (q ≥ 0), elsewhere q>0.
Analysis (Analyst): The decomposition I = H(X)+H(Y)−H(X,Y) comes from marginalising the
log: ∑_{x,y} p(x,y) log marginalX(x) = ∑_x marginalX(x) log marginalX(x), since log is
constant in the summed variable. Subadditivity is then literally I ≥ 0.
Critique (Critic): Must NOT assume strict positivity of the joint (that would exclude the
physically interesting deterministic correlations). The strengthened Gibbs is what buys
full generality. Independence case is an honest identity, not vacuous.
Synthesis (PI): A bipartite/correlation layer on the Landauer development: subadditivity of
entropy and the kT·I(X;Y) erasure saving — the Maxwell-demon / side-information mechanism.
!-- end Lab Notes -- !--

**Strengthened Gibbs' inequality.** The relative entropy `D(p‖q)` of PMFs `p`, `q`
is nonnegative provided `q` vanishes only where `p` does (absolute continuity). This
generalises `LandauerRelativeEntropy.relativeEntropy_nonneg`, which assumed `q > 0`
everywhere.
-/
theorem relativeEntropy_nonneg' {Ω : Type*} [Fintype Ω] (p q : Ω → ℝ)
    (hp : IsPMF p) (hq : IsPMF q) (habs : ∀ ω, q ω = 0 → p ω = 0) :
    0 ≤ relativeEntropy p q := by
  -- By definition of `relativeEntropy`, we know that it is nonnegative.
  have h_nonneg : ∀ ω, p ω * Real.log (p ω / q ω) ≥ p ω - q ω := by
    intro ω; by_cases h : p ω = 0 <;> by_cases h' : q ω = 0 <;> simp_all +decide [ IsPMF ] ;
    have := Real.log_le_sub_one_of_pos ( show 0 < q ω / p ω from div_pos ( lt_of_le_of_ne ( hq.1 ω ) ( Ne.symm h' ) ) ( lt_of_le_of_ne ( hp.1 ω ) ( Ne.symm h ) ) );
    rw [ show p ω / q ω = ( q ω / p ω ) ⁻¹ by rw [ inv_div ], Real.log_inv ] ; nlinarith [ mul_div_cancel₀ ( q ω ) h, hp.1 ω, hq.1 ω ];
  exact le_trans ( by rw [ Finset.sum_sub_distrib, hp.2, hq.2, sub_self ] ) ( Finset.sum_le_sum fun ω _ => h_nonneg ω )

variable {X Y : Type*} [Fintype X] [Fintype Y]

/-- The `X`-marginal of a joint distribution `p` on `X × Y`. -/
def marginalX (p : X × Y → ℝ) : X → ℝ := fun x => ∑ y, p (x, y)

/-- The `Y`-marginal of a joint distribution `p` on `X × Y`. -/
def marginalY (p : X × Y → ℝ) : Y → ℝ := fun y => ∑ x, p (x, y)

/-- The product (independent coupling) of two distributions. -/
def prodDist (pX : X → ℝ) (pY : Y → ℝ) : X × Y → ℝ := fun xy => pX xy.1 * pY xy.2

/-- **Mutual information** of a joint distribution, as the relative entropy of the
joint against the product of its marginals. -/
def mutualInfo (p : X × Y → ℝ) : ℝ :=
  relativeEntropy p (prodDist (marginalX p) (marginalY p))

/-
The `X`-marginal of a joint PMF is a PMF.
-/
theorem marginalX_isPMF (p : X × Y → ℝ) (hp : IsPMF p) : IsPMF (marginalX p) := by
  refine ⟨fun x => Finset.sum_nonneg fun y _ => hp.1 _, ?_⟩
  rw [← hp.2]
  exact (Fintype.sum_prod_type p).symm

/-
The `Y`-marginal of a joint PMF is a PMF.
-/
theorem marginalY_isPMF (p : X × Y → ℝ) (hp : IsPMF p) : IsPMF (marginalY p) := by
  refine ⟨fun y => Finset.sum_nonneg fun x _ => hp.1 _, ?_⟩
  rw [← hp.2, Fintype.sum_prod_type]
  exact Finset.sum_comm

/-
The product of two PMFs is a PMF.
-/
theorem prodDist_isPMF (pX : X → ℝ) (pY : Y → ℝ) (hX : IsPMF pX) (hY : IsPMF pY) :
    IsPMF (prodDist pX pY) := by
  refine ⟨fun xy => mul_nonneg (hX.1 _) (hY.1 _), ?_⟩
  have : ∑ xy : X × Y, prodDist pX pY xy = (∑ x, pX x) * ∑ y, pY y := by
    rw [Fintype.sum_prod_type, Finset.sum_mul_sum]
    rfl
  rw [this, hX.2, hY.2, mul_one]

/-
The product of the marginals is absolutely continuous with respect to the joint:
it vanishes only where the joint does.
-/
theorem prodMarginals_absCont (p : X × Y → ℝ) (hp : IsPMF p) :
    ∀ xy, prodDist (marginalX p) (marginalY p) xy = 0 → p xy = 0 := by
  intro xy hxy
  by_cases hx : marginalX p xy.1 = 0;
  · exact Finset.sum_eq_zero_iff_of_nonneg ( fun _ _ => hp.1 _ ) |>.1 hx _ ( Finset.mem_univ _ );
  · by_cases hy : marginalY p xy.2 = 0 <;> simp_all +decide [ prodDist ];
    exact le_antisymm ( le_trans ( Finset.single_le_sum ( fun x _ => hp.1 ( x, xy.2 ) ) ( Finset.mem_univ xy.1 ) ) hy.le ) ( hp.1 _ )

/-
**Entropy decomposition.** The mutual information equals the sum of the marginal
entropies minus the joint entropy: `I(X;Y) = H(X) + H(Y) − H(X,Y)`.
-/
theorem mutualInfo_eq_entropy (p : X × Y → ℝ) (hp : IsPMF p) :
    mutualInfo p =
      shannonEntropy (marginalX p) + shannonEntropy (marginalY p) - shannonEntropy p := by
  unfold mutualInfo shannonEntropy;
  simp +decide [ relativeEntropy, prodDist ];
  -- Apply the properties of logarithms to split the sum into three parts.
  have h_log_split : ∀ x y, p (x, y) * Real.log (p (x, y) / (marginalX p x * marginalY p y)) =
    p (x, y) * Real.log (p (x, y)) - p (x, y) * Real.log (marginalX p x) - p (x, y) * Real.log (marginalY p y) := by
      intro x y; by_cases h : p ( x, y ) = 0 <;> by_cases h' : marginalX p x = 0 <;> by_cases h'' : marginalY p y = 0 <;> simp +decide [ *, Real.log_div, Real.log_mul ] ; ring;
      · exact absurd h' ( ne_of_gt ( lt_of_lt_of_le ( lt_of_le_of_ne ( hp.1 _ ) ( Ne.symm h ) ) ( Finset.single_le_sum ( fun y _ => hp.1 ( x, y ) ) ( Finset.mem_univ y ) ) ) );
      · exact absurd h' ( ne_of_gt ( lt_of_lt_of_le ( lt_of_le_of_ne ( hp.1 _ ) ( Ne.symm h ) ) ( Finset.single_le_sum ( fun y _ => hp.1 ( x, y ) ) ( Finset.mem_univ y ) ) ) );
      · exact absurd h'' ( ne_of_gt ( lt_of_lt_of_le ( lt_of_le_of_ne ( hp.1 _ ) ( Ne.symm h ) ) ( Finset.single_le_sum ( fun a _ => hp.1 ( a, y ) ) ( Finset.mem_univ x ) ) ) );
      · ring;
  simp +decide only [h_log_split, Fintype.sum_prod_type, negMulLog_def]
  have claim1 : ∑ x : X, ∑ _y : Y, p (x, _y) * Real.log (marginalX p x)
      = ∑ x : X, marginalX p x * Real.log (marginalX p x) := by
    refine Finset.sum_congr rfl ?_
    intro x _
    rw [← Finset.sum_mul]
    rfl
  have claim2 : ∑ x : X, ∑ y : Y, p (x, y) * Real.log (marginalY p y)
      = ∑ y : Y, marginalY p y * Real.log (marginalY p y) := by
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl ?_
    intro y _
    rw [← Finset.sum_mul]
    rfl
  have hsplit : ∀ x : X, ∑ y : Y,
        (p (x, y) * Real.log (p (x, y)) - p (x, y) * Real.log (marginalX p x)
          - p (x, y) * Real.log (marginalY p y))
      = (∑ y : Y, p (x, y) * Real.log (p (x, y)))
          - (∑ y : Y, p (x, y) * Real.log (marginalX p x))
          - (∑ y : Y, p (x, y) * Real.log (marginalY p y)) := by
    intro x
    rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib]
  rw [Finset.sum_congr rfl (fun x _ => hsplit x), Finset.sum_sub_distrib,
      Finset.sum_sub_distrib, claim1, claim2]
  simp only [neg_mul, Finset.sum_neg_distrib]
  ring

/-
**Nonnegativity of mutual information** (Gibbs).
-/
theorem mutualInfo_nonneg (p : X × Y → ℝ) (hp : IsPMF p) : 0 ≤ mutualInfo p := by
  apply relativeEntropy_nonneg' p (prodDist (marginalX p) (marginalY p)) hp (prodDist_isPMF (marginalX p) (marginalY p) (marginalX_isPMF p hp) (marginalY_isPMF p hp)) (prodMarginals_absCont p hp)

/-
**Subadditivity of Shannon entropy.** The joint entropy never exceeds the sum of
the marginal entropies: `H(X,Y) ≤ H(X) + H(Y)`.
-/
theorem shannonEntropy_subadditive (p : X × Y → ℝ) (hp : IsPMF p) :
    shannonEntropy p ≤ shannonEntropy (marginalX p) + shannonEntropy (marginalY p) := by
  linarith [ LandauerSubadditivity.mutualInfo_eq_entropy p hp, LandauerSubadditivity.mutualInfo_nonneg p hp ]

/-
**Independent memories carry no mutual information.** If the joint distribution is
the product of its marginals, the mutual information vanishes.
-/
theorem mutualInfo_indep_eq_zero (pX : X → ℝ) (pY : Y → ℝ)
    (hX : IsPMF pX) (hY : IsPMF pY) :
    mutualInfo (prodDist pX pY) = 0 := by
  unfold mutualInfo;
  unfold relativeEntropy;
  unfold prodDist marginalX marginalY;
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hX.2, hY.2 ]

/-
**Landauer cost of correlated erasure ≤ separate erasure.** For `k, T ≥ 0`, the
joint Landauer free-energy cost `k·T·H(X,Y)` of erasing two correlated memories is at
most the cost `k·T·(H(X)+H(Y))` of erasing them separately.
-/
theorem landauer_joint_le_separate (p : X × Y → ℝ) (hp : IsPMF p) (k T : ℝ)
    (hk : 0 ≤ k) (hT : 0 ≤ T) :
    k * T * shannonEntropy p ≤
      k * T * (shannonEntropy (marginalX p) + shannonEntropy (marginalY p)) := by
  exact mul_le_mul_of_nonneg_left ( shannonEntropy_subadditive p hp ) ( mul_nonneg hk hT )

/-
**The correlation saving is exactly `k·T·I(X;Y)`.** The difference between the
separate and joint Landauer costs equals `k·T` times the mutual information, which is
nonnegative.
-/
theorem landauer_correlation_saving (p : X × Y → ℝ) (hp : IsPMF p) (k T : ℝ) :
    k * T * (shannonEntropy (marginalX p) + shannonEntropy (marginalY p))
      - k * T * shannonEntropy p = k * T * mutualInfo p := by
  rw [ mutualInfo_eq_entropy p hp ];
  ring

/-! ### A concrete two-bit example: perfectly correlated memories -/

/-- A **perfectly correlated** two-bit memory: the two bits are always equal, each of the
two diagonal outcomes carrying probability `1/2`. This is the elementary nanoscale model
of a copied bit / a measured Maxwell-demon memory. -/
def perfectlyCorrelated : Bool × Bool → ℝ := fun b => if b.1 = b.2 then 1 / 2 else 0

/-
The perfectly correlated memory is a probability mass function.
-/
theorem perfectlyCorrelated_isPMF : IsPMF perfectlyCorrelated := by
  constructor;
  · exact fun ω => by unfold perfectlyCorrelated; split_ifs <;> norm_num;
  · unfold perfectlyCorrelated;
    erw [ Finset.sum_product ] ; norm_num [ Finset.sum_ite ]

/-
Both marginals of the perfectly correlated memory are uniform on a bit.
-/
theorem marginalX_perfectlyCorrelated :
    marginalX perfectlyCorrelated = uniformBool := by
  ext x; simp [marginalX, perfectlyCorrelated, uniformBool]

theorem marginalY_perfectlyCorrelated :
    marginalY perfectlyCorrelated = uniformBool := by
  funext y; cases y <;> simp [marginalY, perfectlyCorrelated, uniformBool]

/-
**Mutual information of a perfectly correlated bit pair is `log 2`** — a full bit of
shared information.
-/
theorem mutualInfo_perfectlyCorrelated :
    mutualInfo perfectlyCorrelated = Real.log 2 := by
  unfold mutualInfo;
  unfold relativeEntropy; norm_num [ perfectlyCorrelated, marginalX, marginalY, prodDist ] ; ring;
  erw [ Finset.sum_product ] ; norm_num [ Finset.sum ] ; ring

/-
**Strict correlation saving.** Erasing a perfectly correlated two-bit memory jointly
costs *strictly less* than erasing the two bits separately; the gap is exactly the
one-bit Landauer quantum `k·T·log 2`. This shows the subadditivity bound is genuinely
strict for correlated memories (the demon's recorded bit is free to erase given its copy).
-/
theorem landauer_perfectlyCorrelated_strict_saving (k T : ℝ) (hk : 0 < k) (hT : 0 < T) :
    k * T * shannonEntropy perfectlyCorrelated <
      k * T * (shannonEntropy (marginalX perfectlyCorrelated)
        + shannonEntropy (marginalY perfectlyCorrelated)) := by
  convert lt_add_of_pos_left _ ( mul_pos ( mul_pos hk hT ) ( Real.log_pos ( show ( 2 : ℝ ) > 1 by norm_num ) ) ) using 1;
  rw [ ← mul_add, ← entropy_uniformBool, marginalX_perfectlyCorrelated, marginalY_perfectlyCorrelated ];
  unfold shannonEntropy perfectlyCorrelated; norm_num [ Finset.sum_add_distrib ] ;
  rw [ Finset.sum_eq_add ( ( Bool.true, Bool.true ) ) ( ( Bool.false, Bool.false ) ) ] <;> norm_num [ uniformBool ]

end LandauerSubadditivity

end