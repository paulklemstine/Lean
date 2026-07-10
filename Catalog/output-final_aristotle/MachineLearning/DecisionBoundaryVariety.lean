/-
Copyright (c) 2026 Tropical Neural Geometry Research Team. All rights reserved.
Released under Apache 2.0 license.

# Decision boundaries of ReLU networks: tropical rationality and algebraic varieties

This file *deepens* the Zhang–Naitzat–Lim correspondence between feed-forward
ReLU networks and tropical (max-plus) rational functions in two directions.

1. **From one hidden layer to arbitrary depth.**  A *single* hidden ReLU layer
   computes a tropical rational function.  Here we prove the sharp structural
   statement: a real-valued function on `ℝ^d` is computable by a feed-forward
   ReLU network **of any depth** if and only if it is a tropical rational
   function.  We model "computable by a ReLU network" by the class
   `ReLUComputable`, the smallest class containing all affine functionals and
   closed under pointwise addition, scalar multiplication, and the rectifier
   `ReLU`.  These are exactly the operations a feed-forward ReLU network
   performs, iterated to any depth.  The headline theorem is

       `ReLUComputable f ↔ IsTropRational f`.

   The forward direction is a closure argument: tropical rational functions are
   closed under `+`, real scaling, and `ReLU`.  The converse rests on the
   identity `max a b = a + ReLU (b - a)`, which shows every finite max of affine
   pieces is realized by a shallow network.

2. **From tropical hypersurfaces to genuine algebraic varieties.**  The
   decision boundary of a tropical rational classifier `f = p - q` is a
   piecewise-linear hypersurface.  We show it is contained in the real zero
   locus of an **explicit multivariate polynomial**: the product, over all pairs
   of affine pieces `(A, B)` of `p` and `q`, of the affine differences `A - B`.
   Thus the piecewise-linear decision boundary always lies inside a bona fide
   algebraic hypersurface, making precise the phrase "the algebraic variety of
   the decision boundary".

Together these results place ReLU decision boundaries at the confluence of three
areas: neural network theory, tropical (max-plus) geometry, and classical
algebraic geometry.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): "single hidden layer ⇒ tropical rational" should
upgrade to a two-sided characterization for networks of unbounded depth, and the
tropical hypersurface carrying the decision boundary should refine to an honest
algebraic variety cut out by one polynomial.
Experiment (Experimenter): encode ReLU networks as an inductive closure class
`ReLUComputable`; prove closure of the tropical rational class under `+`, `·`,
`ReLU`; realize `max` by `a + ReLU (b - a)`; build the boundary polynomial as a
product of affine differences over the two piece families.
Analysis (Analyst): the equivalence is tight — no depth or width hypothesis is
needed, because the generating operations already coincide with the algebraic
closure operations of the max-plus semiring difference structure.
Critique (Critic): the algebraic containment is one-directional (boundary ⊆
variety) and cannot be an equality in general, since the variety includes the
non-attained crossings of pieces; this is recorded honestly in the statement.
Synthesis (PI): the depth-free characterization plus the algebraic-variety
containment form a self-contained bridge across the three fields.
-/

import Mathlib

open scoped BigOperators
open Finset

namespace DecisionBoundaryVariety

variable {d : ℕ}

/-! ## Prerequisites: tropical polynomials and rational functions

These reproduce the core definitions and closure lemmas of the ReLU / tropical
correspondence, on which the new results below build. -/

/-- An affine functional `(a, b)` evaluated at `x`: `⟨a, x⟩ + b`. -/
def affEval (ab : (Fin d → ℝ) × ℝ) (x : Fin d → ℝ) : ℝ :=
  (∑ j, ab.1 j * x j) + ab.2

/-- `f` is a **tropical polynomial**: a finite (nonempty) max of affine functions. -/
def IsTropPoly (f : (Fin d → ℝ) → ℝ) : Prop :=
  ∃ (S : Finset ((Fin d → ℝ) × ℝ)) (h : S.Nonempty),
    ∀ x, f x = S.sup' h (fun ab => affEval ab x)

/-- `f` is a **tropical rational function**: a difference of two tropical
polynomials.  This is the class computed by ReLU networks. -/
def IsTropRational (f : (Fin d → ℝ) → ℝ) : Prop :=
  ∃ p q : (Fin d → ℝ) → ℝ, IsTropPoly p ∧ IsTropPoly q ∧ ∀ x, f x = p x - q x

/-- The rectifier `ReLU t = max t 0`. -/
def relu (t : ℝ) : ℝ := max t 0

/-- The **decision boundary** of a real-valued classifier `f`: the locus where
`f` vanishes. -/
def decisionBoundary (f : (Fin d → ℝ) → ℝ) : Set (Fin d → ℝ) := {x | f x = 0}

/-- A single affine function is a (one-term) tropical polynomial. -/
theorem affine_isTropPoly (a : Fin d → ℝ) (b : ℝ) :
    IsTropPoly (fun x => affEval (a, b) x) := by
  refine ⟨{(a, b)}, Finset.singleton_nonempty _, ?_⟩
  intro x
  rw [Finset.sup'_singleton]

/-- Tropical addition: max of two tropical polynomials is a tropical polynomial. -/
theorem IsTropPoly.sup {f g : (Fin d → ℝ) → ℝ}
    (hf : IsTropPoly f) (hg : IsTropPoly g) :
    IsTropPoly (fun x => max (f x) (g x)) := by
  obtain ⟨S, hS, hfS⟩ := hf
  obtain ⟨T, hT, hgT⟩ := hg
  refine ⟨S ∪ T, hS.mono Finset.subset_union_left, ?_⟩
  intro x
  show max (f x) (g x) = _
  rw [hfS x, hgT x, Finset.sup'_union hS hT]

/-- Key max-plus distributive law: `(sup' over S) + (sup' over T)` ranges over
`S ×ˢ T`. -/
theorem sup'_add_sup' {α : Type*} (S T : Finset α) (hS : S.Nonempty) (hT : T.Nonempty)
    (u v : α → ℝ) :
    S.sup' hS u + T.sup' hT v
      = (S ×ˢ T).sup' (hS.product hT) (fun p => u p.1 + v p.2) := by
  refine' le_antisymm _ _ <;> simp_all +decide [ Finset.sup'_le_iff ];
  · rcases Finset.exists_mem_eq_sup' hS u with ⟨ a, ha, ha' ⟩ ; rcases Finset.exists_mem_eq_sup' hT v with ⟨ b, hb, hb' ⟩ ; use a, b ; aesop;
  · exact fun a b ha hb => add_le_add ( Finset.le_sup' u ha ) ( Finset.le_sup' v hb )

/-- Tropical multiplication: the sum of two tropical polynomials is a tropical
polynomial. -/
theorem IsTropPoly.add {f g : (Fin d → ℝ) → ℝ}
    (hf : IsTropPoly f) (hg : IsTropPoly g) :
    IsTropPoly (fun x => f x + g x) := by
  obtain ⟨S, hS, hfS⟩ := hf
  obtain ⟨T, hT, hgT⟩ := hg
  refine ⟨(S ×ˢ T).image (fun p => (p.1.1 + p.2.1, p.1.2 + p.2.2)),
    (hS.product hT).image _, ?_⟩
  intro x; simp +decide [ hfS, hgT, sup'_add_sup' _ _ hS hT ] ;
  unfold affEval; norm_num [ Finset.sum_add_distrib ] ;
  simp +decide only [add_assoc, add_left_comm, add_mul, sum_add_distrib]

/-- Nonnegative scaling preserves tropical polynomials. -/
theorem IsTropPoly.smul_nonneg {f : (Fin d → ℝ) → ℝ} (hf : IsTropPoly f)
    {c : ℝ} (hc : 0 ≤ c) :
    IsTropPoly (fun x => c * f x) := by
  obtain ⟨S, hS, hfS⟩ := hf
  refine ⟨S.image (fun ab => (fun j => c * ab.1 j, c * ab.2)), hS.image _, ?_⟩
  simp_all +decide [ Finset.sup'_eq_csSup_image, affEval ];
  intro x; rw [ ← smul_eq_mul, ← Real.sSup_smul_of_nonneg hc ] ; congr; ext; simp +decide [ mul_add, mul_assoc, mul_left_comm, Finset.mul_sum _ _ _ ] ; ring;
  simp +decide [ Set.mem_smul_set, mul_assoc, Finset.mul_sum _ _ _, mul_add, add_comm, add_left_comm, add_assoc ]

/-- ReLU of a tropical polynomial is a tropical polynomial. -/
theorem IsTropPoly.relu {f : (Fin d → ℝ) → ℝ} (hf : IsTropPoly f) :
    IsTropPoly (fun x => relu (f x)) := by
  have hzero : IsTropPoly (fun _ : Fin d → ℝ => (0 : ℝ)) := by
    have := affine_isTropPoly (d := d) (fun _ => 0) 0
    simpa [affEval] using this
  simpa [relu] using hf.sup hzero

/-- A constant function is a tropical polynomial. -/
theorem const_isTropPoly (b : ℝ) : IsTropPoly (fun _ : Fin d → ℝ => b) := by
  have := affine_isTropPoly (d := d) (fun _ => 0) b
  simpa [affEval] using this

/-- On the decision boundary `{p = q}` of a tropical-rational classifier, the
combined tropical polynomial `max(p,q)` is attained simultaneously by a
maximizing affine piece of `p` and of `q`. -/
theorem exists_pieces_eq_on_boundary
    {p q : (Fin d → ℝ) → ℝ}
    {Sp : Finset ((Fin d → ℝ) × ℝ)} {hSp : Sp.Nonempty}
    {Sq : Finset ((Fin d → ℝ) × ℝ)} {hSq : Sq.Nonempty}
    (hp : ∀ x, p x = Sp.sup' hSp (fun ab => affEval ab x))
    (hq : ∀ x, q x = Sq.sup' hSq (fun ab => affEval ab x))
    {x : Fin d → ℝ} (hx : p x = q x) :
    ∃ abp ∈ Sp, ∃ abq ∈ Sq,
      affEval abp x = max (p x) (q x) ∧ affEval abq x = max (p x) (q x) := by
  have := Finset.exists_mem_eq_sup' hSp ( fun ab => affEval ab x )
  have := Finset.exists_mem_eq_sup' hSq ( fun ab => affEval ab x )
  aesop

/-! ## Part 1 — Closure of the tropical rational class under network operations -/

/-
!-- Sum of two tropical rational functions is tropical rational. -- !--
-/
theorem IsTropRational.add {f g : (Fin d → ℝ) → ℝ}
    (hf : IsTropRational f) (hg : IsTropRational g) :
    IsTropRational (fun x => f x + g x) := by
  obtain ⟨ p1, q1, hp1, hq1, hf ⟩ := hf; obtain ⟨ p2, q2, hp2, hq2, hg ⟩ := hg; exact ⟨ p1 + p2, q1 + q2, by exact IsTropPoly.add hp1 hp2, by exact IsTropPoly.add hq1 hq2, fun x => by simp +decide [ hf, hg ] ; ring ⟩ ;

/-
!-- Negation of a tropical rational function is tropical rational. -- !--
-/
theorem IsTropRational.neg {f : (Fin d → ℝ) → ℝ} (hf : IsTropRational f) :
    IsTropRational (fun x => - f x) := by
  obtain ⟨p, q, hp, hq, hf⟩ := hf; exact ⟨q, p, hq, hp, fun x => by simp [hf]⟩;

/-
!-- Scaling by an arbitrary real preserves tropical rationality. -- !--
-/
theorem IsTropRational.smul {f : (Fin d → ℝ) → ℝ} (hf : IsTropRational f) (c : ℝ) :
    IsTropRational (fun x => c * f x) := by
  obtain ⟨ S, hS, hS' ⟩ := hf;
  by_cases hc : 0 ≤ c;
  · exact ⟨ fun x => c * S x, fun x => c * hS x, by simpa [ hS'.2.2, mul_sub ] using IsTropPoly.smul_nonneg hS'.1 hc, by simpa [ hS'.2.2, mul_sub ] using IsTropPoly.smul_nonneg hS'.2.1 hc, fun x => by simp +decide [ hS'.2.2, mul_sub ] ⟩;
  · -- Since $c < 0$, we can write $c = -d$ where $d > 0$.
    obtain ⟨d, hd_pos, rfl⟩ : ∃ d > 0, c = -d := by
      exact ⟨ -c, by linarith, by ring ⟩;
    exact ⟨ fun x => d * hS x, fun x => d * S x, by exact IsTropPoly.smul_nonneg hS'.2.1 hd_pos.le, by exact IsTropPoly.smul_nonneg hS'.1 hd_pos.le, fun x => by simp +decide [ hS'.2.2 ] ; ring ⟩

/-
!-- A constant function is tropical rational. -- !--
-/
theorem IsTropRational.const (b : ℝ) : IsTropRational (fun _ : Fin d → ℝ => b) := by
  use fun _ => b, fun _ => 0;
  exact ⟨ const_isTropPoly b, const_isTropPoly 0, fun x => by ring ⟩

/-
!-- An affine functional is tropical rational. -- !--
-/
theorem IsTropRational.affine (a : Fin d → ℝ) (b : ℝ) :
    IsTropRational (fun x => affEval (a, b) x) := by
  exact ⟨ _, _, affine_isTropPoly a b, const_isTropPoly 0, by simp +decide [ sub_eq_add_neg ] ⟩

-- !-- ReLU of a tropical rational function is tropical rational: -- !--
-- !-- relu (p - q) = max p q - q, and max p q, q are tropical polynomials. -- !--
theorem IsTropRational.reluClosed {f : (Fin d → ℝ) → ℝ} (hf : IsTropRational f) :
    IsTropRational (fun x => relu (f x)) := by
  obtain ⟨p, q, hp, hq, hf⟩ := hf
  have h_relu : ∀ x, relu (f x) = max (p x) (q x) - q x := by
    intro x
    rw [hf x, relu]
    rcases le_total (p x) (q x) with h | h <;> simp_all [max_eq_left, max_eq_right] <;> linarith
  exact ⟨fun x => max (p x) (q x), q, IsTropPoly.sup hp hq, hq, fun x => h_relu x⟩

/-! ## Part 2 — ReLU-computable functions are exactly the tropical rationals -/

/-- `ReLUComputable` is the smallest class of real-valued functions on `ℝ^d`
that contains all affine functionals and is closed under pointwise addition,
scalar multiplication, and the rectifier.  These are precisely the operations a
feed-forward ReLU network performs, so `ReLUComputable f` means exactly that `f`
is computed by some ReLU network of finite (but arbitrary) depth and width. -/
inductive ReLUComputable : ((Fin d → ℝ) → ℝ) → Prop
  | affine (a : Fin d → ℝ) (b : ℝ) : ReLUComputable (fun x => affEval (a, b) x)
  | add {f g : (Fin d → ℝ) → ℝ} : ReLUComputable f → ReLUComputable g →
      ReLUComputable (fun x => f x + g x)
  | smul {f : (Fin d → ℝ) → ℝ} (c : ℝ) : ReLUComputable f →
      ReLUComputable (fun x => c * f x)
  | relu {f : (Fin d → ℝ) → ℝ} : ReLUComputable f →
      ReLUComputable (fun x => relu (f x))

/-
!-- Forward direction: every ReLU-computable function is tropical rational. -- !--
-/
theorem ReLUComputable.isTropRational {f : (Fin d → ℝ) → ℝ}
    (hf : ReLUComputable f) : IsTropRational f := by
  induction hf with
  | affine a b => exact IsTropRational.affine a b
  | add _ _ ih1 ih2 => exact ih1.add ih2
  | smul c _ ih => exact ih.smul c
  | relu _ ih => exact ih.reluClosed

/-
!-- The pointwise max of two ReLU-computable functions is ReLU-computable, -- !--
!-- via the identity `max a b = a + ReLU (b - a)`. -- !--
-/
theorem ReLUComputable.max {f g : (Fin d → ℝ) → ℝ}
    (hf : ReLUComputable f) (hg : ReLUComputable g) :
    ReLUComputable (fun x => max (f x) (g x)) := by
  convert ReLUComputable.add hf ( ReLUComputable.relu ( hg.add ( hf.smul ( -1 ) ) ) ) using 1;
  ext x; unfold DecisionBoundaryVariety.relu; cases max_cases ( f x ) ( g x ) <;> cases max_cases ( g x + -1 * f x ) 0 <;> linarith;

/-
!-- Every tropical polynomial (finite max of affine pieces) is ReLU-computable. -- !--
-/
theorem IsTropPoly.reLUComputable {f : (Fin d → ℝ) → ℝ}
    (hf : IsTropPoly f) : ReLUComputable f := by
  -- By definition of $IsTropPoly$, we know that $f$ can be written as a finite max of affine functions.
  obtain ⟨S, hS⟩ := hf;
  cases' hS with h hS;
  have h_ind : ∀ (s : Finset ((Fin d → ℝ) × ℝ)) (hs : s.Nonempty), ReLUComputable (fun x => s.sup' hs (fun ab => affEval ab x)) := by
    intro s hs; induction hs using Finset.Nonempty.cons_induction <;> simp_all +decide [ Finset.sup'_insert ] ;
    · exact ReLUComputable.affine _ _;
    · apply ReLUComputable.max; exact ReLUComputable.affine _ _; assumption;
  simpa only [ ← hS ] using h_ind S h

/-
!-- Converse direction: every tropical rational function is ReLU-computable, -- !--
!-- since `f = p - q = p + (-1) · q` with `p`, `q` tropical polynomials. -- !--
-/
theorem IsTropRational.reLUComputable {f : (Fin d → ℝ) → ℝ}
    (hf : IsTropRational f) : ReLUComputable f := by
  obtain ⟨ p, q, hp, hq, hf ⟩ := hf;
  convert ReLUComputable.add ( IsTropPoly.reLUComputable hp ) ( ReLUComputable.smul ( -1 ) ( IsTropPoly.reLUComputable hq ) ) using 1 ; ext x ; simp +decide [ hf ] ; ring

/-- **Depth-free characterization.**  A real-valued function on `ℝ^d` is
computable by a feed-forward ReLU network of arbitrary depth and width if and
only if it is a tropical rational function.  This sharpens the one-hidden-layer
bridge theorem to networks of any depth. -/
theorem reLUComputable_iff_isTropRational {f : (Fin d → ℝ) → ℝ} :
    ReLUComputable f ↔ IsTropRational f :=
  ⟨ReLUComputable.isTropRational, IsTropRational.reLUComputable⟩

/-! ## Part 3 — The decision boundary lies on an algebraic hypersurface -/

/-- The multivariate polynomial representing an affine functional `(a, b)`:
`x ↦ ⟨a, x⟩ + b`. -/
noncomputable def affPoly (ab : (Fin d → ℝ) × ℝ) : MvPolynomial (Fin d) ℝ :=
  MvPolynomial.C ab.2 + ∑ j, MvPolynomial.C (ab.1 j) * MvPolynomial.X j

/-
!-- Evaluating `affPoly ab` recovers the affine functional `affEval ab`. -- !--
-/
theorem affPoly_eval (ab : (Fin d → ℝ) × ℝ) (x : Fin d → ℝ) :
    MvPolynomial.eval x (affPoly ab) = affEval ab x := by
  unfold affPoly; simp +decide [ affEval ] ;
  ring

/-- The **boundary polynomial** of a tropical rational classifier whose two
tropical-polynomial parts have affine-piece families `Sp` and `Sq`: the product
over all pairs of pieces of their affine differences.  Its real zero locus is an
algebraic hypersurface containing the decision boundary. -/
noncomputable def boundaryPoly (Sp Sq : Finset ((Fin d → ℝ) × ℝ)) :
    MvPolynomial (Fin d) ℝ :=
  ∏ ab ∈ Sp, ∏ cd ∈ Sq, (affPoly ab - affPoly cd)

/-
!-- Evaluating the boundary polynomial gives the product of all pairwise -- !--
!-- affine differences of the two piece families. -- !--
-/
theorem boundaryPoly_eval (Sp Sq : Finset ((Fin d → ℝ) × ℝ)) (x : Fin d → ℝ) :
    MvPolynomial.eval x (boundaryPoly Sp Sq)
      = ∏ ab ∈ Sp, ∏ cd ∈ Sq, (affEval ab x - affEval cd x) := by
  unfold boundaryPoly; simp +decide [ ← affPoly_eval ] ;

/-
**The decision boundary lies inside an algebraic variety.**  For a tropical
rational classifier `f = p - q` with `p`, `q` presented as finite maxima over
affine-piece families `Sp`, `Sq`, every point of the decision boundary is a real
zero of the boundary polynomial.  Hence the piecewise-linear decision boundary
is contained in the algebraic hypersurface `{ x | boundaryPoly Sp Sq (x) = 0 }`.
-/
theorem decisionBoundary_subset_algebraicVariety
    {p q : (Fin d → ℝ) → ℝ}
    {Sp : Finset ((Fin d → ℝ) × ℝ)} {hSp : Sp.Nonempty}
    {Sq : Finset ((Fin d → ℝ) × ℝ)} {hSq : Sq.Nonempty}
    (hp : ∀ x, p x = Sp.sup' hSp (fun ab => affEval ab x))
    (hq : ∀ x, q x = Sq.sup' hSq (fun ab => affEval ab x)) :
    decisionBoundary (fun x => p x - q x)
      ⊆ {x | MvPolynomial.eval x (boundaryPoly Sp Sq) = 0} := by
  intro x;
  simp +zetaDelta at *;
  intro hx
  rw [boundaryPoly_eval];
  obtain ⟨ abp, habp, abq, habq, h₁, h₂ ⟩ := exists_pieces_eq_on_boundary hp hq ( show p x = q x from sub_eq_zero.mp hx ) ; exact Finset.prod_eq_zero habp ( Finset.prod_eq_zero habq <| by linarith ) ;

/-! ## Worked corollaries -/

-- A deep composition (ReLU of an affine map, scaled, plus another ReLU) is
-- tropical rational — an instance of the depth-free characterization.
example (a₁ a₂ : Fin d → ℝ) (b₁ b₂ c : ℝ) :
    IsTropRational (fun x => c * relu (affEval (a₁, b₁) x) + relu (affEval (a₂, b₂) x)) := by
  have h : ReLUComputable
      (fun x => c * relu (affEval (a₁, b₁) x) + relu (affEval (a₂, b₂) x)) :=
    (((ReLUComputable.affine a₁ b₁).relu).smul c).add ((ReLUComputable.affine a₂ b₂).relu)
  exact h.isTropRational

end DecisionBoundaryVariety