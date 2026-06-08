/-
# Impossible Figures: Main Theorems

The central results connecting cocycles, coboundaries, and monodromy on cycle graphs.

## Main Results

* `coboundary_implies_zero_monodromy`: If a cocycle is a coboundary, its monodromy is zero.
* `zero_monodromy_implies_coboundary`: If the monodromy is zero, the cocycle is a coboundary.
* `monodromy_classification`: A cocycle is a coboundary if and only if its monodromy is zero.
* `monodromy_additive`: Monodromy is additive on cocycles.
* `cohomologous_iff_same_monodromy`: Two cocycles are cohomologous iff they have equal monodromy.
* `orientation_monodromy_pm_one`: The orientation monodromy is always ±1.
* `impossibility_index_zero_iff`: The impossibility index is zero iff the cocycle is a coboundary.
-/
import Algebra.ImpossibleFigures.Defs

open Finset BigOperators

noncomputable section

/-! ## Telescoping Sums on Cycles

The key technical lemma: for any function `h : Fin n → ℝ`, the sum of differences
`h(succ i) - h(i)` around the cycle telescopes to zero. -/

/-
Telescoping sum around a cycle: ∑ᵢ (h(i+1 mod n) - h(i)) = 0 for any h.
    This is the discrete analogue of ∮ df = 0 for exact forms.
-/
theorem telescoping_sum_cycle {n : ℕ} (hn : 0 < n) (h : Fin n → ℝ) :
    ∑ i : Fin n, (h (Fin.cycSucc hn i) - h i) = 0 := by
  rcases n with ( _ | _ | n ) <;> norm_num at *;
  · simp +decide [ Fin.eq_zero ];
  · convert sub_eq_zero_of_eq ( Equiv.sum_comp ( Equiv.addRight 1 ) h )

/-! ## Forward Direction: Coboundary → Zero Monodromy -/

/-
If a cocycle is a coboundary (realizable), then its monodromy is zero.
    This is the "if it can be built in 3D, there's no height discrepancy" direction.
-/
theorem coboundary_implies_zero_monodromy {n : ℕ} {hn : 0 < n}
    (ω : CycleCocycle n hn) (hcb : ω.IsCoboundary) :
    ω.monodromy = 0 := by
  obtain ⟨ h, hh ⟩ := hcb;
  simpa [ hh, CycleCocycle.monodromy ] using telescoping_sum_cycle hn h

/-! ## Backward Direction: Zero Monodromy → Coboundary -/

/-- Partial sums define a height function from a cocycle.
    h(k) = ∑_{i < k} ω(i) gives the accumulated height at vertex k. -/
def partialSumHeight {n : ℕ} {hn : 0 < n} (ω : CycleCocycle n hn) (k : Fin n) : ℝ :=
  ∑ i ∈ Finset.univ.filter (fun j : Fin n => j.val < k.val), ω.edgeWeight i

/-
If the monodromy is zero, the cocycle is a coboundary.
    The witness height function is the partial sum of edge weights.
    This is the constructive direction of the classification theorem.
-/
theorem zero_monodromy_implies_coboundary {n : ℕ} {hn : 0 < n}
    (ω : CycleCocycle n hn) (hm : ω.monodromy = 0) :
    ω.IsCoboundary := by
  -- Define � the� height function h as the partial sum of the edge weights.
  use fun k => ∑ i ∈ Finset.univ.filter (fun j => j.val < k.val), ω.edgeWeight i;
  intro i
  by_cases h_last : i.val = n - 1;
  · rcases n with ( _ | _ | n ) <;> simp_all +decide [ Fin.cycSucc ];
    · contradiction;
    · fin_cases i ; unfold CycleCocycle.monodromy at hm ; aesop;
    · simp_all +decide [ Finset.sum_filter, Finset.sum_range, Fin.sum_univ_castSucc, CycleCocycle.monodromy ];
      rw [ show i = Fin.last _ from Fin.ext h_last ] ; linarith!;
  · simp +decide [ Fin.cycSucc, Finset.sum_filter, Finset.sum_range_succ ];
    rw [ ← Finset.sum_sub_distrib ];
    rw [ Finset.sum_eq_single i ] <;> simp +contextual [ Fin.ext_iff, Nat.mod_eq_of_lt ];
    · exact fun h => absurd h ( by rw [ Nat.mod_eq_of_lt ] <;> omega );
    · intro j hj; split_ifs <;> simp_all +decide [ Nat.mod_eq_of_lt ] ;
      · rw [ Nat.mod_eq_of_lt ] at *;
        · grind;
        · exact Nat.lt_of_le_of_ne ( Nat.succ_le_of_lt i.2 ) ( by omega );
      · rw [ Nat.mod_eq_of_lt ] at * <;> omega

/-! ## The Monodromy Classification Theorem -/

/-- **The Monodromy Classification Theorem**: A cocycle on the cycle graph Cₙ
    is a coboundary if and only if its monodromy (total height discrepancy) is zero.

    This is the discrete analogue of the de Rham theorem for the circle:
    a closed 1-form on S¹ is exact iff its integral over S¹ is zero.

    Equivalently: an impossible figure is realizable iff the total height
    discrepancy around every cycle vanishes. -/
theorem monodromy_classification {n : ℕ} {hn : 0 < n}
    (ω : CycleCocycle n hn) :
    ω.IsCoboundary ↔ ω.monodromy = 0 := by
  constructor
  · exact coboundary_implies_zero_monodromy ω
  · exact zero_monodromy_implies_coboundary ω

/-! ## Algebraic Properties of Monodromy -/

/-
Monodromy is additive: the monodromy of a sum of cocycles is the sum of monodromies.
-/
theorem monodromy_additive {n : ℕ} {hn : 0 < n}
    (ω₁ ω₂ : CycleCocycle n hn) :
    (ω₁ + ω₂).monodromy = ω₁.monodromy + ω₂.monodromy := by
  exact Finset.sum_add_distrib

/-
Monodromy is homogeneous: scaling a cocycle scales the monodromy.
-/
theorem monodromy_smul {n : ℕ} {hn : 0 < n}
    (c : ℝ) (ω : CycleCocycle n hn) :
    (c • ω).monodromy = c * ω.monodromy := by
  unfold CycleCocycle.monodromy;
  rw [ Finset.mul_sum _ _ _ ];
  rfl

/-
Monodromy of the zero cocycle is zero.
-/
theorem monodromy_zero {n : ℕ} {hn : 0 < n} :
    (0 : CycleCocycle n hn).monodromy = 0 := by
  exact Finset.sum_const_zero

/-
Monodromy of a negated cocycle is the negation of the monodromy.
-/
theorem monodromy_neg {n : ℕ} {hn : 0 < n}
    (ω : CycleCocycle n hn) :
    (-ω).monodromy = -(ω.monodromy) := by
  unfold CycleCocycle.monodromy;
  rw [ ← Finset.sum_neg_distrib ];
  rfl

/-! ## Cohomological Characterization -/

/-
Two cocycles are cohomologous if and only if they have the same monodromy.
    This shows that monodromy provides a complete invariant of the cohomology class,
    establishing an isomorphism H¹(Cₙ; ℝ) ≅ ℝ.
-/
theorem cohomologous_iff_same_monodromy {n : ℕ} {hn : 0 < n}
    (ω₁ ω₂ : CycleCocycle n hn) :
    ω₁.Cohomologous ω₂ ↔ ω₁.monodromy = ω₂.monodromy := by
  constructor;
  · exact fun h => by linarith [ monodromy_additive ω₁ ( -ω₂ ), monodromy_neg ω₂, monodromy_classification ( ω₁ + -ω₂ ) |>.1 h ] ;
  · intro h;
    apply zero_monodromy_implies_coboundary;
    rw [ monodromy_additive, monodromy_neg, h, add_neg_cancel ]

/-! ## Impossibility Index -/

/-
The impossibility index is zero if and only if the figure is realizable.
-/
theorem impossibility_index_zero_iff {n : ℕ} {hn : 0 < n}
    (ω : CycleCocycle n hn) :
    ω.impossibilityIndex = 0 ↔ ω.IsCoboundary := by
  rw [ CycleCocycle.impossibilityIndex, abs_eq_zero, monodromy_classification ]

/-! ## Orientation Cocycle Theorems -/

/-
The orientation monodromy (product of ±1 values) is always ±1.
    This classifies the configuration as orientable (+1) or non-orientable (-1).
-/
theorem orientation_monodromy_pm_one {n : ℕ} {hn : 0 < n}
    (σ : OrientationCocycle n hn) :
    σ.monodromy = 1 ∨ σ.monodromy = -1 := by
  unfold OrientationCocycle.monodromy;
  exact eq_or_eq_neg_of_abs_eq ( by rw [ Finset.abs_prod ] ; exact Finset.prod_eq_one fun i _ => by cases σ.values_pm_one i <;> simp +decide [ * ] )

/-
Flipping one orientation in a non-orientable cocycle with an odd number of
    -1 edges preserves non-orientability (parity argument).
-/
theorem odd_neg_ones_non_orientable {n : ℕ} {hn : 0 < n}
    (σ : OrientationCocycle n hn)
    (hodd : Odd (Finset.univ.filter (fun i => σ.orientation i = -1)).card) :
    σ.isNonOrientable := by
  -- The product of σ.orientation i is equal to (-1) raised to the power of the number of -1s.
  have h_prod : ∏ i : Fin n, σ.orientation i = (-1) ^ (Finset.card (Finset.filter (fun i => σ.orientation i = -1) Finset.univ)) := by
    rw [ Finset.prod_congr rfl fun x hx => show σ.orientation x = if σ.orientation x = -1 then -1 else 1 from by rcases σ.values_pm_one x with h | h <;> norm_num [ h ], Finset.prod_ite ] ; aesop;
  exact h_prod.trans ( by rw [ hodd.neg_one_pow ] )

/-! ## The Penrose Triangle -/

/-
The Penrose triangle as a concrete impossible figure on C₃.
    Each edge contributes a height difference of 1, giving monodromy 3.
-/
def penroseTriangle : ImpossibleFigure where
  numEdges := 3
  numEdges_pos := by omega
  cocycle := ⟨fun _ => 1⟩
  impossible := by
    norm_num [ CycleCocycle.monodromy ]

/-! ## Perturbation Stability -/

/-
Impossibility is stable under small perturbations: if the monodromy is nonzero,
    sufficiently small perturbations preserve impossibility.
-/
theorem impossibility_stable_perturbation {n : ℕ} {hn : 0 < n}
    (ω : CycleCocycle n hn) (hω : ω.monodromy ≠ 0)
    (ε : CycleCocycle n hn) (hε : |ε.monodromy| < |ω.monodromy|) :
    (ω + ε).monodromy ≠ 0 := by
  -- By monod �rom�y_additive, (ω + ε).monodromy =.monodromy + ε �.mon�odromy.
  have h_add : (ω + ε).monodromy = ω.monodromy + ε.monodromy := by
    exact monodromy_additive ω ε
  grind

/-! ## Conjecture: Rational Rigidity -/

/-
**Conjecture (Rational Rigidity)**: For any impossible figure with rational edge weights,
    the impossibility index is a positive rational number.

    More precisely: if all edge weights are rational, the monodromy is rational,
    so the impossibility index is rational.

    This is testable: for any finite set of rational edge weights on Cₙ,
    compute the monodromy and check rationality.
-/
theorem rational_cocycle_rational_monodromy {n : ℕ} {hn : 0 < n}
    (ω : CycleCocycle n hn)
    (hrat : ∀ i, ∃ q : ℚ, ω.edgeWeight i = (q : ℝ)) :
    ∃ q : ℚ, ω.monodromy = (q : ℝ) := by
  choose q hq using hrat; use ∑ i, q i; push_cast; rw [ ← funext hq ] ; rfl;

/-! ## Open Conjecture: Spectral Gap Bound -/

/-
**Conjecture (Spectral Gap Bound)**: For the cycle graph Cₙ with n ≥ 3,
    the minimum impossibility index among all impossible figures is
    achievable by a cocycle with at most 2 distinct edge weight values.

    **Computational test**: For each n from 3 to 20, enumerate cocycles with
    2 distinct values and check whether all cohomology classes are represented.
    If any class requires 3+ distinct values, the conjecture is false.

    This is a testable prediction about the structure of the cohomology
    representatives on cycle graphs.
-/
theorem spectral_gap_conjecture_partial {n : ℕ} {hn : 0 < n}
    (ω : CycleCocycle n hn) (hω : ω.monodromy ≠ 0) :
    ∃ ω' : CycleCocycle n hn,
      ω'.monodromy = ω.monodromy ∧
      (∀ i j : Fin n, ω'.edgeWeight i = ω'.edgeWeight j) := by
  -- The harmonic representative (constant cocycle) achieves any monodromy
  -- with just 1 distinct value: m/n on every edge.
  use ⟨fun _ => ω.monodromy / n⟩;
  unfold CycleCocycle.monodromy; norm_num [ mul_div_cancel₀, hn.ne' ] ;

end