import Tropical.FundamentalTheorem.Basic

/-!
# Tropical intersection multiplicity and Tropical Bézout (the univariate case)

The **Fundamental Theorem of Tropical Algebra** (the tropical analogue of the Fundamental
Theorem of Algebra, and the one–variable instance of Tropical Bézout) states that a tropical
polynomial of degree `d` has exactly `d` roots, counted with multiplicity, and that these
match the valuations of the `d` classical roots of any lift.

We work in the **min-plus** semiring on `ℝ`.  A *monic linear tropical polynomial* with root
`r` is `tropLinear r t = min t r`.  A monic tropical polynomial of degree `d`, given as a
tropical product of linear factors with roots `r : Fin d → ℝ`, is

`tropProd r t = ∑ k, min t (r k)`   (tropical product = ordinary sum of min-plus factors).

## Main results

* `tropProd_eq_split` : the explicit piecewise-linear formula
  `tropProd r t = (∑ k with r k ≤ t, r k) + (#{k : t < r k}) • t`.
* `tropProd_slope_bot` / `tropProd_slope_top` : the slope is `d` below all roots and `0`
  above all roots — the total slope drop across the real line is exactly the degree `d`.
* `slope_drop_eq_mult` : at each value `ρ`, the drop in slope equals the **multiplicity**
  `tropMult r ρ = #{k : r k = ρ}` (the local tropical intersection multiplicity).
* `tropical_bezout` : the multiset of tropical roots has cardinality `d`; equivalently the
  multiplicities sum to `d`.  This is Tropical Bézout in one variable.
* `tropPolyValue_linearFactor` : the tropicalization of a classical linear factor `X - a`
  is the tropical linear factor `min t (v a)`, so the `d` classical roots `a k` of a degree
  `d` polynomial map under the valuation to the `d` tropical roots — matching multiplicities.
-/

noncomputable section

open scoped BigOperators
open Finset

namespace TropicalFT

/-- A monic linear tropical (min-plus) polynomial with root `r`: `min t r`. -/
def tropLinear (r : ℝ) (t : ℝ) : ℝ := min t r

/-- A monic tropical polynomial of degree `d`, presented as the tropical product of its `d`
linear factors with roots `r k`.  The tropical product is the ordinary sum. -/
def tropProd {d : ℕ} (r : Fin d → ℝ) (t : ℝ) : ℝ := ∑ k, tropLinear (r k) t

/-- The (local) tropical multiplicity of a value `ρ` as a root of `tropProd r`: the number of
linear factors with root `ρ`. -/
def tropMult {d : ℕ} (r : Fin d → ℝ) (ρ : ℝ) : ℕ :=
  (Finset.univ.filter (fun k => r k = ρ)).card

/-- The local slope of `tropProd r` just below `ρ`: the number of factors with root `≥ ρ`. -/
def slopeBelow {d : ℕ} (r : Fin d → ℝ) (ρ : ℝ) : ℕ :=
  (Finset.univ.filter (fun k => ρ ≤ r k)).card

/-- The local slope of `tropProd r` just above `ρ`: the number of factors with root `> ρ`. -/
def slopeAbove {d : ℕ} (r : Fin d → ℝ) (ρ : ℝ) : ℕ :=
  (Finset.univ.filter (fun k => ρ < r k)).card

/-! ### The explicit piecewise-linear formula and slopes -/

/-
Explicit piecewise-linear formula for `tropProd`.
-/
lemma tropProd_eq_split {d : ℕ} (r : Fin d → ℝ) (t : ℝ) :
    tropProd r t =
      (∑ k ∈ Finset.univ.filter (fun k => r k ≤ t), r k)
        + ((Finset.univ.filter (fun k => t < r k)).card : ℝ) * t := by
  convert Finset.sum_congr rfl fun i _ => show tropLinear ( r i ) t = ( if r i ≤ t then r i else 0 ) + ( if t < r i then t else 0 ) from ?_ using 1;
  · simp +decide [ Finset.sum_add_distrib, Finset.sum_ite ];
  · unfold tropLinear; split_ifs <;> cases min_cases ( t ) ( r i ) <;> linarith;

/-
Below all roots the slope is the full degree `d`: `tropProd r t = d • t`.
-/
lemma tropProd_slope_bot {d : ℕ} (r : Fin d → ℝ) {t : ℝ} (ht : ∀ k, t ≤ r k) :
    tropProd r t = (d : ℝ) * t := by
  exact Eq.trans ( Finset.sum_congr rfl fun _ _ => min_eq_left ( ht _ ) ) ( by simp +decide [ mul_comm ] )

/-
Above all roots the slope is `0`: `tropProd r t = ∑ k, r k` is constant.
-/
lemma tropProd_slope_top {d : ℕ} (r : Fin d → ℝ) {t : ℝ} (ht : ∀ k, r k ≤ t) :
    tropProd r t = ∑ k, r k := by
  exact Finset.sum_congr rfl fun _ _ => min_eq_right ( ht _ )

/-! ### Multiplicity = drop in slope (local tropical intersection multiplicity) -/

/-
`slopeAbove ≤ slopeBelow`.
-/
lemma slopeAbove_le_slopeBelow {d : ℕ} (r : Fin d → ℝ) (ρ : ℝ) :
    slopeAbove r ρ ≤ slopeBelow r ρ := by
  exact Finset.card_le_card fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, le_of_lt <| Finset.mem_filter.mp hx |>.2 ⟩

/-
**The local matching of multiplicities.**  The drop in slope of `tropProd r` across the
value `ρ` equals the tropical multiplicity of `ρ` as a root.
-/
lemma slope_drop_eq_mult {d : ℕ} (r : Fin d → ℝ) (ρ : ℝ) :
    slopeBelow r ρ - slopeAbove r ρ = tropMult r ρ := by
  unfold slopeBelow slopeAbove tropMult;
  rw [ show ( Finset.filter ( fun k => ρ ≤ r k ) Finset.univ : Finset ( Fin d ) ) = Finset.filter ( fun k => ρ < r k ) Finset.univ ∪ Finset.filter ( fun k => r k = ρ ) Finset.univ from ?_, Finset.card_union_of_disjoint ];
  · rw [ Nat.add_sub_cancel_left ];
  · exact Finset.disjoint_filter.mpr fun _ _ _ _ => by linarith;
  · grind

/-! ### Tropical Bézout in one variable -/

/-- The multiset of tropical roots of `tropProd r`. -/
def tropRoots {d : ℕ} (r : Fin d → ℝ) : Multiset ℝ := (Finset.univ.val : Multiset (Fin d)).map r

/-
The multiplicity of `ρ` in `tropRoots` is exactly `tropMult r ρ`.
-/
lemma count_tropRoots {d : ℕ} [DecidableEq ℝ] (r : Fin d → ℝ) (ρ : ℝ) :
    (tropRoots r).count ρ = tropMult r ρ := by
  unfold tropRoots tropMult;
  rw [ Multiset.count_map ];
  simp +decide [ eq_comm, Finset.filter ]

/-
**Tropical Bézout (one variable / Fundamental Theorem of Tropical Algebra).**  A tropical
polynomial of degree `d` has exactly `d` roots, counted with multiplicity.
-/
theorem tropical_bezout {d : ℕ} (r : Fin d → ℝ) :
    (tropRoots r).card = d := by
  unfold tropRoots; aesop;

/-
The multiplicities of the distinct roots sum to the degree `d`.
-/
theorem tropical_bezout_sum_mult {d : ℕ} (r : Fin d → ℝ) :
    ∑ ρ ∈ (Finset.univ.image r), tropMult r ρ = d := by
  unfold tropMult;
  rw [ ← Finset.card_eq_sum_card_fiberwise ];
  · simp +decide;
  · exact fun x _ => Finset.mem_image_of_mem _ ( Finset.mem_univ x )

/-! ### Bridge to the classical roots via the valuation -/

variable {K : Type*} [Field K] (v : AddValuation K (WithTop ℝ))

open MvPolynomial in
/-- A classical monic linear factor `X - a` as a univariate polynomial. -/
def linearFactor (a : K) : MvPolynomial (Fin 1) K := X 0 - C a

open MvPolynomial in
/-- **Compatibility of tropicalization with a linear factor.**  The tropicalization (corner
function) of the classical linear factor `X - a` (for `a ≠ 0`) equals the tropical linear
factor `min t (v a)`.  Hence the root `a` of `X - a` tropicalizes to the tropical root `v a`,
matching multiplicities one-for-one; for a degree-`d` product this realises the `d` classical
roots' valuations as the `d` tropical roots of Tropical Bézout. -/
theorem tropPolyValue_linearFactor {a : K} (ha : a ≠ 0) (t : ℝ) :
    tropPolyValue v (linearFactor a) (fun _ => t)
      = ((tropLinear (WithTop.untopD 0 (v a)) t : ℝ) : WithTop ℝ) := by
  unfold tropPolyValue;
  refine' le_antisymm _ _ <;> simp +decide [ tropMonomial, tropLinear ];
  · refine' ⟨ ⟨ Finsupp.single 0 1, _, _ ⟩, ⟨ 0, _, _ ⟩ ⟩ <;> simp +decide [ linearFactor, linForm ];
    · rw [ if_neg ( by exact ne_of_apply_ne ( fun f => f 0 ) ( by simp +decide ) ) ] ; simp +decide;
    · rw [ if_neg ( by exact ne_of_apply_ne ( fun f => f 0 ) ( by simp +decide ) ) ] ; simp +decide;
    · exact ha;
    · cases h : v a <;> simp_all +decide [ WithTop.untopD ];
  · intro b hb; by_cases hb' : b = Finsupp.single 0 1 <;> by_cases hb'' : b = 0 <;> simp_all +decide [ linearFactor ] ;
    · simpa using congr_arg ( fun f => f 0 ) hb';
    · simp +decide [ linForm ];
      simp +decide [ Finsupp.ext_iff, Fin.forall_fin_one ] at hb ⊢;
    · simp +decide [ linForm ];
      cases h : v a <;> aesop;
    · rw [ MvPolynomial.coeff_X' ] at hb ; aesop

end TropicalFT