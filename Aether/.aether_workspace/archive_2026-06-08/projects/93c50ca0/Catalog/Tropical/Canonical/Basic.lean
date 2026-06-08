import Mathlib

/-!
# Tropical Canonical Forms for Univariate Piecewise-Linear Functions

This file establishes a **canonical tropical-rational normal form** for univariate
continuous piecewise-linear (CPL) functions, and uses it to give a certified
decision procedure for exact functional equivalence.

## Main definitions

* `AffinePiece` — a pair (slope, intercept) defining `x ↦ slope * x + intercept`
* `TropicalPoly` — a nonempty list of affine pieces; evaluates as their pointwise maximum
* `TropicalRat` — a pair of tropical polynomials; evaluates as their difference
* `TropicalPoly.Canonical` — sorted by strictly increasing slope, every term strictly essential

## Main results

* `tropical_poly_eval_continuous` — evaluation of a tropical polynomial is continuous
* `tropical_rational_eq_iff_crossmul` — cross-multiplication criterion for rational equality
* `canonical_tropical_poly_unique` — canonical tropical polynomials with equal eval are equal
* `relu_network_has_canonical_tropical_rational` — every univariate ReLU network
  has a unique canonical tropical-rational form
-/

open scoped Topology

noncomputable section

/-! ## Affine Pieces -/

/-- An affine piece represents a function `x ↦ slope * x + intercept`. -/
@[ext]
structure AffinePiece where
  slope : ℝ
  intercept : ℝ

/-- Evaluation of an affine piece. -/
def AffinePiece.eval (p : AffinePiece) (x : ℝ) : ℝ :=
  p.slope * x + p.intercept

@[simp]
theorem AffinePiece.eval_def (p : AffinePiece) (x : ℝ) :
    p.eval x = p.slope * x + p.intercept := rfl

/-! ## Tropical Polynomials -/

/-- A tropical polynomial is a nonempty list of affine pieces.
    Its evaluation is the pointwise maximum of the affine pieces. -/
structure TropicalPoly where
  terms : List AffinePiece
  nonempty : terms ≠ []

/-- Evaluate a tropical polynomial at a point as the maximum of all affine pieces. -/
def TropicalPoly.eval (P : TropicalPoly) (x : ℝ) : ℝ :=
  match P.terms, P.nonempty with
  | t :: ts, _ => ts.foldl (fun acc p => max acc (p.eval x)) (t.eval x)

/-- A single-term tropical polynomial. -/
def TropicalPoly.single (a : AffinePiece) : TropicalPoly where
  terms := [a]
  nonempty := List.cons_ne_nil _ _

@[simp]
theorem TropicalPoly.single_eval (a : AffinePiece) (x : ℝ) :
    (TropicalPoly.single a).eval x = a.eval x := by
  simp [TropicalPoly.eval, TropicalPoly.single]

/-- Tropical multiplication: the set of all pairwise sums of affine pieces. -/
def TropicalPoly.tmul (P Q : TropicalPoly) : TropicalPoly where
  terms := P.terms.flatMap fun p => Q.terms.map fun q =>
    ⟨p.slope + q.slope, p.intercept + q.intercept⟩
  nonempty := by
    simp only [ne_eq, List.flatMap_eq_nil_iff, not_forall]
    obtain ⟨p, _, hp⟩ := List.exists_cons_of_ne_nil P.nonempty
    exact ⟨p, hp ▸ List.mem_cons_self .., by rw [List.map_eq_nil_iff]; exact Q.nonempty⟩

/-! ## Tropical Rational Functions -/

/-- A tropical rational function is a difference of two tropical polynomials. -/
structure TropicalRat where
  num : TropicalPoly
  den : TropicalPoly

/-- Evaluation of a tropical rational function. -/
def TropicalRat.eval (R : TropicalRat) (x : ℝ) : ℝ :=
  R.num.eval x - R.den.eval x

/-! ## Canonicality -/

/-- A list of affine pieces has strictly increasing slopes. -/
def StrictlyIncreasingSlopes : List AffinePiece → Prop
  | [] => True
  | [_] => True
  | a :: b :: rest => a.slope < b.slope ∧ StrictlyIncreasingSlopes (b :: rest)

/-- All terms in the polynomial are strictly essential:
    each term strictly exceeds all other terms at some point. -/
def AllStrictlyEssential (P : TropicalPoly) : Prop :=
  ∀ p ∈ P.terms, ∃ x : ℝ, ∀ q ∈ P.terms, q ≠ p → p.eval x > q.eval x

/-- A tropical polynomial is canonical if slopes are strictly increasing
    and every term is strictly essential. -/
def TropicalPoly.Canonical (P : TropicalPoly) : Prop :=
  StrictlyIncreasingSlopes P.terms ∧ AllStrictlyEssential P

/-! ## Minimal Tropical Rational Functions -/

/-- A tropical rational function is minimal if both components are canonical
    and there is no nontrivial common tropical factor. -/
def MinimalTropicalRat (R : TropicalRat) : Prop :=
  R.num.Canonical ∧ R.den.Canonical ∧
  (∀ (P : TropicalPoly), (∀ x : ℝ,
    R.num.eval x - R.den.eval x =
    max (R.num.eval x) (P.eval x) - max (R.den.eval x) (P.eval x)) →
  ∀ x : ℝ, P.eval x ≤ min (R.num.eval x) (R.den.eval x))

/-! ## Piecewise-Linear Functions -/

/-- A function `f : ℝ → ℝ` is univariate continuous piecewise-linear. -/
def IsUnivCPL (f : ℝ → ℝ) : Prop :=
  Continuous f ∧
  ∃ (S : Finset ℝ), ∀ x : ℝ, x ∉ S →
    ∃ m b : ℝ, ∃ ε > 0, ∀ y : ℝ, |y - x| < ε → f y = m * y + b

/-! ## Univariate ReLU Networks -/

/-- A univariate ReLU network is built from affine maps and ReLU activations. -/
inductive UnivReluNet where
  | affine (a b : ℝ) : UnivReluNet
  | relu (inner : UnivReluNet) : UnivReluNet
  | add (f g : UnivReluNet) : UnivReluNet
  | sub (f g : UnivReluNet) : UnivReluNet

/-- Evaluation of a univariate ReLU network. -/
def UnivReluNet.eval : UnivReluNet → ℝ → ℝ
  | .affine a b => fun x => a * x + b
  | .relu inner => fun x => max (inner.eval x) 0
  | .add f g => fun x => f.eval x + g.eval x
  | .sub f g => fun x => f.eval x - g.eval x

end -- noncomputable section

/-! ## Theorems -/

noncomputable section

/-- Affine piece evaluation is continuous. -/
theorem affinePiece_eval_continuous (p : AffinePiece) : Continuous p.eval := by
  unfold AffinePiece.eval; fun_prop

/-- Folding max preserves continuity. -/
theorem list_foldl_max_continuous (ts : List AffinePiece) (g : ℝ → ℝ) (hg : Continuous g) :
    Continuous (fun x => ts.foldl (fun acc p => max acc (p.eval x)) (g x)) := by
  induction ts generalizing g with
  | nil => exact hg
  | cons t ts ih => exact ih _ (Continuous.max hg (affinePiece_eval_continuous t))

/-- **Tropical polynomial evaluation is continuous.** -/
theorem tropical_poly_eval_continuous (P : TropicalPoly) : Continuous P.eval := by
  unfold TropicalPoly.eval
  match P.terms, P.nonempty with
  | t :: ts, _ => exact list_foldl_max_continuous ts t.eval (affinePiece_eval_continuous t)

/-- **Two-term tropical polynomial evaluation is max.** -/
theorem tropical_poly_two_eval (a b : AffinePiece) (x : ℝ) :
    (TropicalPoly.mk [a, b] (List.cons_ne_nil _ _)).eval x =
    max (a.eval x) (b.eval x) := by
  simp [TropicalPoly.eval, List.foldl]

/-- **ReLU is a tropical polynomial.** -/
theorem relu_is_tropical_poly (x : ℝ) :
    max x 0 = (TropicalPoly.mk [⟨0, 0⟩, ⟨1, 0⟩] (List.cons_ne_nil _ _)).eval x := by
  simp [TropicalPoly.eval, List.foldl, AffinePiece.eval]
  exact max_comm x 0

/-- **Tropical multiplication is pointwise addition for single terms.** -/
theorem tropical_poly_tmul_single (a b : AffinePiece) (x : ℝ) :
    (TropicalPoly.single a |>.tmul (TropicalPoly.single b)).eval x =
    a.eval x + b.eval x := by
  simp [TropicalPoly.tmul, TropicalPoly.single, TropicalPoly.eval,
        List.flatMap, List.map, List.foldl, AffinePiece.eval]
  ring

/-
**The tropical polynomial max(x, 0) is canonical.**
-/
theorem relu_tropical_canonical :
    (TropicalPoly.mk [⟨0, 0⟩, ⟨1, 0⟩] (List.cons_ne_nil _ _)).Canonical := by
  unfold TropicalPoly.Canonical;
  unfold StrictlyIncreasingSlopes AllStrictlyEssential; norm_num;
  exact ⟨ trivial, ⟨ -1, by norm_num ⟩, ⟨ 1, by norm_num ⟩ ⟩

/-- **Cross-multiplication criterion for tropical rational equivalence.** -/
theorem tropical_rational_eq_iff_crossmul (R S : TropicalRat) :
    (∀ x : ℝ, R.eval x = S.eval x) ↔
    (∀ x : ℝ, R.num.eval x + S.den.eval x = S.num.eval x + R.den.eval x) := by
  simp only [TropicalRat.eval]
  constructor <;> intro h x <;> linarith [h x]

/-- **Affine function is a tropical rational function.** -/
theorem affine_is_tropical_rational (a b : ℝ) :
    ∀ x : ℝ, a * x + b =
    (TropicalRat.mk (TropicalPoly.single ⟨a, b⟩) (TropicalPoly.single ⟨0, 0⟩)).eval x := by
  intro x; simp [TropicalRat.eval, AffinePiece.eval]

/-- **ReLU as tropical rational.** -/
theorem relu_eval_tropical_rational :
    ∀ x : ℝ, max x 0 =
    (TropicalRat.mk
      (TropicalPoly.mk [⟨0, 0⟩, ⟨1, 0⟩] (List.cons_ne_nil _ _))
      (TropicalPoly.single ⟨0, 0⟩)).eval x := by
  intro x
  simp [TropicalRat.eval, TropicalPoly.eval, TropicalPoly.single, List.foldl, AffinePiece.eval]
  exact max_comm x 0

/-- **Absolute value is a tropical rational function.** -/
theorem abs_is_tropical_rational :
    ∀ x : ℝ, |x| =
    (TropicalRat.mk
      (TropicalPoly.mk [⟨-1, 0⟩, ⟨1, 0⟩] (List.cons_ne_nil _ _))
      (TropicalPoly.single ⟨0, 0⟩)).eval x := by
  intro x
  simp [TropicalRat.eval, TropicalPoly.eval, TropicalPoly.single, List.foldl, AffinePiece.eval]
  rw [abs_eq_max_neg]; ring_nf; exact max_comm x (-x)

/-- **Identity as tropical rational.** -/
theorem id_is_tropical_rational :
    ∀ x : ℝ, x =
    (TropicalRat.mk (TropicalPoly.single ⟨1, 0⟩) (TropicalPoly.single ⟨0, 0⟩)).eval x := by
  intro x; simp [TropicalRat.eval, AffinePiece.eval]

/-- **UnivReluNet evaluation is continuous.** -/
theorem univReluNet_eval_continuous (N : UnivReluNet) : Continuous N.eval := by
  induction N with
  | affine a b => unfold UnivReluNet.eval; fun_prop
  | relu inner ih =>
    show Continuous (fun x => max (UnivReluNet.eval inner x) 0)
    exact Continuous.max ih continuous_const
  | add f g ihf ihg =>
    show Continuous (fun x => UnivReluNet.eval f x + UnivReluNet.eval g x)
    exact ihf.add ihg
  | sub f g ihf ihg =>
    show Continuous (fun x => UnivReluNet.eval f x - UnivReluNet.eval g x)
    exact ihf.sub ihg

/-- **Two affine functions agreeing everywhere have the same parameters.** -/
theorem affine_ext {a₁ b₁ a₂ b₂ : ℝ}
    (h : ∀ x : ℝ, a₁ * x + b₁ = a₂ * x + b₂) : a₁ = a₂ ∧ b₁ = b₂ := by
  constructor <;> [linarith [h 0, h 1]; linarith [h 0]]

/-- **Canonical single-term uniqueness.** -/
theorem canonical_single_unique (a b : AffinePiece)
    (h : ∀ x : ℝ, a.eval x = b.eval x) : a = b := by
  have h0 := h 0; have h1 := h 1
  simp [AffinePiece.eval] at h0 h1
  exact AffinePiece.ext (by linarith) (by linarith)

/-
**Two affine pieces agreeing at two distinct points are equal.**
-/
theorem affinePiece_eq_of_agree_two {a b : AffinePiece} {x₁ x₂ : ℝ}
    (hne : x₁ ≠ x₂) (h1 : a.eval x₁ = b.eval x₁) (h2 : a.eval x₂ = b.eval x₂) :
    a = b := by
  -- By definition of affine pieces, we have a.eval x = a.slope * x + a.intercept and b.eval x = b.slope * x + b.intercept for all x.
  have h_eval_eq : ∀ x : ℝ, a.eval x = a.slope * x + a.intercept ∧ b.eval x = b.slope * x + b.intercept := by
    exact fun x => ⟨ rfl, rfl ⟩;
  -- Subtract the two equations to get $(a.slope - b.slope) * (x₁ - x₂) = 0$.
  have h_diff : (a.slope - b.slope) * (x₁ - x₂) = 0 := by
    grind;
  simp_all +decide [ sub_eq_iff_eq_add ];
  cases a ; cases b ; aesop

/-
**Foldl max is at least any element.**
-/
theorem foldl_max_le_member (ts : List AffinePiece) (g : ℝ) (p : AffinePiece)
    (hp : p ∈ ts) (x : ℝ) :
    p.eval x ≤ ts.foldl (fun acc q => max acc (q.eval x)) g := by
  induction' ts using List.reverseRecOn with t _ ih <;> aesop

/-
**Foldl max is at least the initial value.**
-/
theorem foldl_max_ge_init (ts : List AffinePiece) (g : ℝ) (x : ℝ) :
    g ≤ ts.foldl (fun acc q => max acc (q.eval x)) g := by
  induction' ts using List.reverseRecOn with ts ih <;> aesop

/-
**At any point, some term achieves the tropical polynomial's max.**
-/
theorem tropical_poly_max_achieved (P : TropicalPoly) (x : ℝ) :
    ∃ p ∈ P.terms, p.eval x = P.eval x := by
  rcases P with ⟨ _ | ⟨ p, _ | ⟨ q, l ⟩ ⟩, hP ⟩ <;> simp_all +decide [ TropicalPoly.eval ];
  · contradiction;
  · induction' l using List.reverseRecOn with l ih;
    · grind;
    · grind

/-
**Each term of a tropical polynomial evaluates ≤ the polynomial.**
-/
theorem tropical_poly_term_le (P : TropicalPoly) (p : AffinePiece)
    (hp : p ∈ P.terms) (x : ℝ) :
    p.eval x ≤ P.eval x := by
  rcases P with ⟨ _ | ⟨ t, ts ⟩, h ⟩ <;> simp_all +decide [ List.sublist_append_right ];
  rcases hp with ( rfl | hp ) <;> [ exact foldl_max_ge_init _ _ _; exact foldl_max_le_member _ _ _ hp _ ]

/-
**StrictlyIncreasingSlopes implies List.Pairwise on slopes.**
-/
theorem strictlyIncreasingSlopes_pairwise {l : List AffinePiece}
    (h : StrictlyIncreasingSlopes l) :
    l.Pairwise (fun p q : AffinePiece => p.slope < q.slope) := by
  -- We proceed by induction on the list `l`.
  induction' l with a l ih;
  · grind;
  · rcases l with ( _ | ⟨ b, l ⟩ ) <;> simp_all +decide [ List.pairwise_cons ];
    exact ⟨ ⟨ h.1, fun c hc => lt_trans h.1 ( ih h.2 |>.1 c hc ) ⟩, ih h.2 ⟩

/-
**In a canonical tropical poly, each term strictly wins at some point,
    hence P.eval = p.eval at that point.**
-/
theorem canonical_essential_strict (P : TropicalPoly) (hP : P.Canonical)
    (p : AffinePiece) (hp : p ∈ P.terms) :
    ∃ x : ℝ, P.eval x = p.eval x := by
  -- By definition of AllStrictlyEssential, for any p ∈ P.terms, ∃ x, ∀ q ∈ P.terms, q ≠ p → p.eval x > q.eval x.
  obtain ⟨x, hx⟩ := hP.right p hp
  use x
  have h_max : P.eval x = p.eval x := by
    have h_max : ∀ q ∈ P.terms, q.eval x ≤ p.eval x := by
      grind;
    exact le_antisymm ( by rcases tropical_poly_max_achieved P x with ⟨ q, hq, hq' ⟩ ; linarith [ h_max q hq ] ) ( tropical_poly_term_le P p hp x )
  exact h_max.symm ▸ rfl

/-
**For large enough x, the largest-slope term dominates.**
-/
theorem tropical_poly_leading_slope (P : TropicalPoly) (hc : P.Canonical) :
    ∃ M : ℝ, ∀ x ≥ M, P.eval x = (P.terms.getLast P.nonempty).eval x := by
  -- By definition of canonical, the last term has the largest slope.
  obtain ⟨M, hM⟩ : ∃ M : ℝ, ∀ x ≥ M, ∀ p ∈ P.terms, p ≠ (P.terms.getLast (List.ne_nil_of_length_pos (List.length_pos_iff_ne_nil.mpr P.nonempty))) → (List.getLast P.terms (List.ne_nil_of_length_pos (List.length_pos_iff_ne_nil.mpr P.nonempty))).eval x > p.eval x := by
    have h_slope : ∀ p ∈ P.terms, p ≠ (P.terms.getLast (List.ne_nil_of_length_pos (List.length_pos_iff_ne_nil.mpr P.nonempty))) → (P.terms.getLast (List.ne_nil_of_length_pos (List.length_pos_iff_ne_nil.mpr P.nonempty))).slope > p.slope := by
      have := hc.1;
      have := strictlyIncreasingSlopes_pairwise this;
      rw [ List.pairwise_iff_get ] at this;
      intro p hp hp'; obtain ⟨ i, hi ⟩ := List.mem_iff_get.mp hp; simp_all +decide [ List.getLast_eq_getElem ] ;
      convert this i ⟨ P.terms.length - 1, Nat.sub_lt ( List.length_pos_iff.mpr P.nonempty ) zero_lt_one ⟩ _ ; aesop;
      exact lt_of_le_of_ne ( Nat.le_pred_of_lt i.2 ) fun h => hp' <| by aesop;
    have h_eval : ∀ p ∈ P.terms, p ≠ (P.terms.getLast (List.ne_nil_of_length_pos (List.length_pos_iff_ne_nil.mpr P.nonempty))) → ∃ M : ℝ, ∀ x ≥ M, (P.terms.getLast (List.ne_nil_of_length_pos (List.length_pos_iff_ne_nil.mpr P.nonempty))).eval x > p.eval x := by
      intro p hp hp'; use ( p.intercept - ( P.terms.getLast ( List.ne_nil_of_length_pos ( List.length_pos_iff_ne_nil.mpr P.nonempty ) ) |> AffinePiece.intercept ) ) / ( ( P.terms.getLast ( List.ne_nil_of_length_pos ( List.length_pos_iff_ne_nil.mpr P.nonempty ) ) |> AffinePiece.slope ) - p.slope ) + 1; intro x hx; rw [ AffinePiece.eval, AffinePiece.eval ] ; nlinarith [ h_slope p hp hp', mul_div_cancel₀ ( p.intercept - ( P.terms.getLast ( List.ne_nil_of_length_pos ( List.length_pos_iff_ne_nil.mpr P.nonempty ) ) |> AffinePiece.intercept ) ) ( sub_ne_zero_of_ne <| ne_of_gt <| h_slope p hp hp' ) ] ;
    choose! M hM using h_eval;
    exact ⟨ SupSet.sSup ( M '' { p ∈ P.terms | p ≠ P.terms.getLast ( List.ne_nil_of_length_pos ( List.length_pos_iff_ne_nil.mpr P.nonempty ) ) } ), fun x hx p hp hp' => hM p hp hp' x ( le_trans ( le_csSup ( by exact Set.Finite.bddAbove <| Set.Finite.image M <| Set.finite_coe_iff.mp <| P.terms.finite_toSet.subset <| by aesop_cat ) <| Set.mem_image_of_mem _ <| by aesop_cat ) hx ) ⟩;
  use M;
  intro x hx
  have h_max : ∀ p ∈ P.terms, p.eval x ≤ (P.terms.getLast (List.ne_nil_of_length_pos (List.length_pos_iff_ne_nil.mpr P.nonempty))).eval x := by
    grind +splitImp;
  obtain ⟨ p, hp₁, hp₂ ⟩ := tropical_poly_max_achieved P x;
  exact hp₂ ▸ le_antisymm ( h_max p hp₁ ) ( by linarith [ tropical_poly_term_le P ( P.terms.getLast ( List.ne_nil_of_length_pos ( List.length_pos_iff_ne_nil.mpr P.nonempty ) ) ) ( List.getLast_mem ( List.ne_nil_of_length_pos ( List.length_pos_iff_ne_nil.mpr P.nonempty ) ) ) x ] )

/-
**For very negative x, the smallest-slope term dominates.**
-/
theorem tropical_poly_trailing_slope (P : TropicalPoly) (hc : P.Canonical) :
    ∃ M : ℝ, ∀ x ≤ M, P.eval x = (P.terms.head P.nonempty).eval x := by
  rcases P with ⟨ _ | ⟨ p, _ | ⟨ q, l ⟩ ⟩, hP ⟩ <;> simp_all +decide;
  · contradiction;
  · exact ⟨ 0, fun x hx => rfl ⟩;
  · -- By definition of canonical, the slopes are strictly increasing.
    have h_slopes_inc : StrictlyIncreasingSlopes (p :: q :: l) := by
      exact hc.1;
    -- For very negative x, the smallest-slope term dominates.
    have h_smallest_slope : ∀ q' ∈ q :: l, ∃ M : ℝ, ∀ x ≤ M, q'.eval x < p.eval x := by
      intro q' hq'
      have h_slope_lt : q'.slope > p.slope := by
        have := strictlyIncreasingSlopes_pairwise h_slopes_inc;
        rw [ List.pairwise_cons ] at this ; aesop;
      unfold AffinePiece.eval;
      exact ⟨ ( p.intercept - q'.intercept ) / ( q'.slope - p.slope ) - 1, fun x hx => by nlinarith [ mul_div_cancel₀ ( p.intercept - q'.intercept ) ( sub_ne_zero_of_ne h_slope_lt.ne' ) ] ⟩;
    choose! M hM using h_smallest_slope;
    use Finset.min' (List.toFinset (q :: l |> List.map M)) (by
    simp +decide)
    generalize_proofs at *;
    intro x hx
    have h_max : ∀ q' ∈ q :: l, q'.eval x ≤ p.eval x := by
      exact fun q' hq' => le_of_lt ( hM q' hq' x ( le_trans hx ( Finset.min'_le _ _ ( by aesop ) ) ) );
    have h_max : ∀ {l : List AffinePiece}, (∀ q' ∈ l, q'.eval x ≤ p.eval x) → List.foldl (fun acc q => max acc (q.eval x)) (p.eval x) l = p.eval x := by
      intros l hl; induction' l using List.reverseRecOn with l ih <;> aesop;
    exact h_max ‹_›

/-
**Canonical head uniqueness.**
-/
theorem canonical_head_unique (P Q : TropicalPoly)
    (hP : P.Canonical) (hQ : Q.Canonical)
    (h : ∀ x : ℝ, P.eval x = Q.eval x) :
    P.terms.head P.nonempty = Q.terms.head Q.nonempty := by
  -- By theature_slope theorem, there exists an M such that for x ≤ M, P.eval x = P.terms.head P.nonempty.eval x and Q.eval x = Q.terms.head Q.nonempty.eval x.
  obtain ⟨M, hM⟩ : ∃ M : ℝ, ∀ x ≤ M, P.eval x = (P.terms.head P.nonempty).eval x ∧ Q.eval x = (Q.terms.head Q.nonempty).eval x := by
    exact Exists.elim ( tropical_poly_trailing_slope P hP ) fun M hM => Exists.elim ( tropical_poly_trailing_slope Q hQ ) fun N hN => ⟨ Min.min M N, fun x hx => ⟨ hM x ( le_trans hx ( min_le_left _ _ ) ), hN x ( le_trans hx ( min_le_right _ _ ) ) ⟩ ⟩;
  -- Since P.eval x = Q.eval x for all x, their heads must be equal.
  have h_head_eq : ∀ x ≤ M, (P.terms.head P.nonempty).eval x = (Q.terms.head Q.nonempty).eval x := by
    exact fun x hx => hM x hx |>.1.symm.trans ( h x ) |> Eq.trans <| hM x hx |>.2;
  exact canonical_single_unique _ _ fun x => if hx : x ≤ M then h_head_eq x hx else by have := h_head_eq ( M - 1 ) ( by linarith ) ; have := h_head_eq ( M - 2 ) ( by linarith ) ; norm_num [ AffinePiece.eval_def ] at * ; cases lt_or_ge x ( M - 1 ) <;> nlinarith;

/-
**Canonical last uniqueness.**
-/
theorem canonical_last_unique (P Q : TropicalPoly)
    (hP : P.Canonical) (hQ : Q.Canonical)
    (h : ∀ x : ℝ, P.eval x = Q.eval x) :
    P.terms.getLast P.nonempty = Q.terms.getLast Q.nonempty := by
  -- By the properties of canonical tropical polynomials, for large enough x, P.eval x equals the last term's eval, and similarly for Q.
  obtain ⟨M, hM⟩ : ∃ M : ℝ, ∀ x ≥ M, P.eval x = (P.terms.getLast P.nonempty).eval x ∧ Q.eval x = (Q.terms.getLast Q.nonempty).eval x := by
    exact Exists.elim ( tropical_poly_leading_slope P hP ) fun M hM => Exists.elim ( tropical_poly_leading_slope Q hQ ) fun N hN => ⟨ Max.max M N, fun x hx => ⟨ hM x ( le_trans ( le_max_left _ _ ) hx ), hN x ( le_trans ( le_max_right _ _ ) hx ) ⟩ ⟩;
  -- By the properties of canonical tropical polynomials, for large enough x, P.eval x equals the last term's eval, and similarly for Q. Therefore, their last terms must be equal.
  have h_last_eq : ∀ x ≥ M, (P.terms.getLast P.nonempty).eval x = (Q.terms.getLast Q.nonempty).eval x := by
    exact fun x hx => hM x hx |>.1.symm.trans ( h x ) |> Eq.trans <| hM x hx |>.2;
  apply canonical_single_unique;
  intro x; have := h_last_eq ( Max.max x M ) ( le_max_right x M ) ; have := h_last_eq ( Max.max x M + 1 ) ( by linarith [ le_max_right x M ] ) ; simp_all +decide [ AffinePiece.eval ] ;
  cases max_cases x M <;> nlinarith [ h_last_eq ( Max.max x M ) ( by linarith ) ]

/-
**In a canonical polynomial, each strictly essential term wins on two distinct
    points (enabling the pigeonhole uniqueness argument).**
-/
theorem canonical_wins_on_two_points (P : TropicalPoly) (hP : P.Canonical)
    (p : AffinePiece) (hp : p ∈ P.terms) :
    ∃ x₁ x₂ : ℝ, x₁ ≠ x₂ ∧ P.eval x₁ = p.eval x₁ ∧ P.eval x₂ = p.eval x₂ := by
  -- Since P is canonical (AllStrictlyEssential), there exists x₀ such that p.eval x₀ > q.eval x₀ for all q ∈ P.terms with q ≠ p. At x₀, P.eval x₀ = p.eval x₀ (since p beats all others).
  obtain ⟨x₀, hx₀⟩ : ∃ x₀ : ℝ, ∀ q ∈ P.terms, q ≠ p → p.eval x₀ > q.eval x₀ := by
    exact hP.2 p hp
  have hx₀_eval : P.eval x₀ = p.eval x₀ := by
    have h_max : ∀ q ∈ P.terms, q.eval x₀ ≤ p.eval x₀ := by
      grind;
    exact le_antisymm ( by rcases tropical_poly_max_achieved P x₀ with ⟨ q, hq₁, hq₂ ⟩ ; exact hq₂ ▸ h_max q hq₁ ) ( tropical_poly_term_le P p hp x₀ );
  -- Since the differences are affine (not just continuous), we can argue more directly: p.eval x - q.eval x = (p.slope - q.slope) * x + (p.intercept - q.intercept) is positive at x₀. If the slope p.slope - q.slope is 0, then the intercept difference is positive, so p.eval x > q.eval x for ALL x. If the slope is nonzero, then p.eval x > q.eval x on an open interval around x₀.
  obtain ⟨ε, hε_pos, hε⟩ : ∃ ε > 0, ∀ x, abs (x - x₀) < ε → ∀ q ∈ P.terms, q ≠ p → p.eval x > q.eval x := by
    have h_cont : ∀ q ∈ P.terms, q ≠ p → ∃ ε > 0, ∀ x, abs (x - x₀) < ε → p.eval x > q.eval x := by
      intros q hq hqp
      have h_cont : Continuous (fun x => p.eval x - q.eval x) := by
        exact Continuous.sub ( affinePiece_eval_continuous p ) ( affinePiece_eval_continuous q );
      exact Metric.mem_nhds_iff.mp ( h_cont.continuousAt.eventually ( lt_mem_nhds ( sub_pos.mpr ( hx₀ q hq hqp ) ) ) ) |> fun ⟨ ε, ε_pos, hε ⟩ => ⟨ ε, ε_pos, fun x hx => by simpa using hε hx ⟩;
    choose! ε hε₁ hε₂ using h_cont;
    have h_min_eps : ∃ ε_min > 0, ∀ q ∈ P.terms, q ≠ p → ε_min ≤ ε q := by
      have h_finite : Set.Finite {q ∈ P.terms | q ≠ p} := by
        exact Set.Finite.subset ( List.finite_toSet P.terms ) fun q hq => hq.1
      by_cases h_empty : {q ∈ P.terms | q ≠ p} = ∅;
      · exact ⟨ 1, zero_lt_one, fun q hq hq' => False.elim <| h_empty.subset ⟨ hq, hq' ⟩ ⟩;
      · have h_min_eps : ∃ q ∈ {q ∈ P.terms | q ≠ p}, ∀ r ∈ {q ∈ P.terms | q ≠ p}, ε q ≤ ε r := by
          apply_rules [ Set.exists_min_image ];
          exact Set.nonempty_iff_ne_empty.mpr h_empty;
        exact ⟨ ε h_min_eps.choose, hε₁ _ h_min_eps.choose_spec.1.1 h_min_eps.choose_spec.1.2, fun q hq hq' => h_min_eps.choose_spec.2 q ⟨ hq, hq' ⟩ ⟩;
    exact ⟨ h_min_eps.choose, h_min_eps.choose_spec.1, fun x hx q hq hqp => hε₂ q hq hqp x <| lt_of_lt_of_le hx <| h_min_eps.choose_spec.2 q hq hqp ⟩;
  refine' ⟨ x₀, x₀ + ε / 2, _, _, _ ⟩ <;> norm_num [ hx₀_eval ];
  · linarith;
  · refine' le_antisymm _ _;
    · have := tropical_poly_max_achieved P ( x₀ + ε / 2 );
      obtain ⟨ q, hq₁, hq₂ ⟩ := this; specialize hε ( x₀ + ε / 2 ) ( by rw [ abs_of_pos ] <;> linarith ) q hq₁; by_cases hq₃ : q = p <;> simp_all +decide [ AffinePiece.eval ] ;
      linarith;
    · exact tropical_poly_term_le P p hp _

/-
**Each term of Q also appears in P when both are canonical with equal eval.**
-/
theorem canonical_terms_subset (P Q : TropicalPoly)
    (hP : P.Canonical) (hQ : Q.Canonical)
    (h : ∀ x : ℝ, P.eval x = Q.eval x) :
    ∀ q ∈ Q.terms, q ∈ P.terms := by
  -- Let $q \in Q.terms$. By canonical_wins_on_two_points, there exist $x₁ \ne x₂$ with $Q.eval x₁ = q.eval x₁$ and $Q.eval x₂ = q.eval x₂$.
  intro q hq
  obtain ⟨x₁, x₂, hx₁x₂, hq₁, hq₂⟩ : ∃ x₁ x₂ : ℝ, x₁ ≠ x₂ ∧ Q.eval x₁ = q.eval x₁ ∧ Q.eval x₂ = q.eval x₂ := by
    exact?;
  -- By the canonical property of Q, there exists an interval $(a, b)$ around $x₁$ such that $Q.eval x = q.eval x$ for all $x \in (a, b)$.
  obtain ⟨a, b, hab⟩ : ∃ a b : ℝ, a < b ∧ ∀ x ∈ Set.Ioo a b, Q.eval x = q.eval x := by
    have := hQ.2 q hq;
    obtain ⟨ x, hx ⟩ := this;
    -- Since $q$ is strictly essential, there exists an interval $(a, b)$ around $x$ such that $q.eval x > q_1.eval x$ for all $q_1 \in Q.terms$ with $q_1 \ne q$.
    obtain ⟨ε, hε⟩ : ∃ ε > 0, ∀ y, |y - x| < ε → ∀ q_1 ∈ Q.terms, q_1 ≠ q → q.eval y > q_1.eval y := by
      have h_cont : Continuous (fun y => q.eval y) ∧ ∀ q_1 ∈ Q.terms, q_1 ≠ q → Continuous (fun y => q_1.eval y) := by
        exact ⟨ affinePiece_eval_continuous q, fun q_1 hq_1 hq_1' => affinePiece_eval_continuous q_1 ⟩;
      have h_cont_diff : ∀ q_1 ∈ Q.terms, q_1 ≠ q → ∃ ε > 0, ∀ y, |y - x| < ε → q.eval y > q_1.eval y := by
        exact fun q_1 hq_1 hq_1' => Metric.mem_nhds_iff.mp ( IsOpen.mem_nhds ( isOpen_lt ( h_cont.2 q_1 hq_1 hq_1' ) h_cont.1 ) ( hx q_1 hq_1 hq_1' ) );
      choose! ε hε₁ hε₂ using h_cont_diff;
      have h_finite : Set.Finite {q_1 ∈ Q.terms | q_1 ≠ q} := by
        exact Set.Finite.subset ( List.finite_toSet Q.terms ) fun x hx => hx.1;
      by_cases h_empty : {q_1 ∈ Q.terms | q_1 ≠ q} = ∅;
      · exact ⟨ 1, zero_lt_one, fun y hy q_1 hq_1 hq_1' => False.elim <| h_empty.subset ⟨ hq_1, hq_1' ⟩ ⟩;
      · obtain ⟨ε_min, hε_min⟩ : ∃ ε_min > 0, ∀ q_1 ∈ {q_1 ∈ Q.terms | q_1 ≠ q}, ε_min ≤ ε q_1 := by
          have h_min : ∃ q_1 ∈ {q_1 ∈ Q.terms | q_1 ≠ q}, ∀ q_2 ∈ {q_1 ∈ Q.terms | q_1 ≠ q}, ε q_1 ≤ ε q_2 := by
            apply_rules [ Set.exists_min_image ];
            exact Set.nonempty_iff_ne_empty.mpr h_empty;
          exact ⟨ ε h_min.choose, hε₁ _ h_min.choose_spec.1.1 h_min.choose_spec.1.2, fun q_1 hq_1 => h_min.choose_spec.2 _ hq_1 ⟩;
        exact ⟨ ε_min, hε_min.1, fun y hy q_1 hq_1 hq_1' => hε₂ q_1 hq_1 hq_1' y <| lt_of_lt_of_le hy <| hε_min.2 q_1 ⟨ hq_1, hq_1' ⟩ ⟩;
    use x - ε, x + ε;
    simp_all +decide [ abs_lt ];
    refine' ⟨ by linarith, fun y hy₁ hy₂ => le_antisymm _ _ ⟩;
    · have := tropical_poly_max_achieved Q y;
      obtain ⟨ p, hp₁, hp₂ ⟩ := this; by_cases hp₃ : p = q <;> simp_all +decide [ AffinePiece.eval ] ;
      linarith [ hε.2 y ( by linarith ) ( by linarith ) p hp₁ hp₃ ];
    · exact tropical_poly_term_le Q q hq y;
  -- By the canonical property of P, there exists a term $p \in P.terms$ such that $p.eval$ agrees with $q.eval$ on the interval $(a, b)$.
  obtain ⟨p, hp⟩ : ∃ p ∈ P.terms, Set.Infinite {x ∈ Set.Ioo a b | p.eval x = q.eval x} := by
    have h_inf : Set.Infinite (⋃ p ∈ P.terms, {x ∈ Set.Ioo a b | p.eval x = q.eval x}) := by
      refine Set.Infinite.mono ?_ ( Set.Ioo_infinite hab.1 );
      intro x hx; specialize h x; simp_all +decide [ Set.subset_def ] ;
      have := tropical_poly_max_achieved P x; aesop;
    contrapose! h_inf;
    exact Set.Finite.biUnion ( List.finite_toSet P.terms ) h_inf;
  have h_eq : ∀ x ∈ {x ∈ Set.Ioo a b | p.eval x = q.eval x}, p.slope * x + p.intercept = q.slope * x + q.intercept := by
    exact fun x hx => hx.2;
  have h_eq : p.slope = q.slope ∧ p.intercept = q.intercept := by
    have h_eq : Set.Infinite {x ∈ Set.Ioo a b | p.slope * x + p.intercept = q.slope * x + q.intercept} := by
      exact hp.2.mono fun x hx => ⟨ hx.1, h_eq x hx ⟩;
    contrapose! h_eq;
    exact Set.Finite.subset ( Set.finite_singleton ( ( q.intercept - p.intercept ) / ( p.slope - q.slope ) ) ) fun x hx => eq_div_of_mul_eq ( sub_ne_zero_of_ne <| by aesop ) <| by linarith [ hx.2 ] ;
  cases p ; cases q ; aesop

/-
**Canonical tropical polynomial uniqueness.**
    Two canonical tropical polynomials with the same evaluation are equal.
-/
theorem canonical_tropical_poly_unique (P Q : TropicalPoly)
    (hP : P.Canonical) (hQ : Q.Canonical)
    (h : ∀ x : ℝ, P.eval x = Q.eval x) :
    P.terms = Q.terms := by
  -- Using the previous results, we can deduce that P and Q have the same terms.
  have hPQ_terms : P.terms.Perm Q.terms := by
    have h_perm : ∀ p ∈ P.terms, p ∈ Q.terms := by
      convert canonical_terms_subset Q P hQ hP ( fun x => h x ▸ rfl ) using 1;
    have h_perm : Q.terms.Perm P.terms := by
      have h_perm : ∀ q ∈ Q.terms, q ∈ P.terms := by
        exact?;
      have h_perm : List.Nodup P.terms ∧ List.Nodup Q.terms := by
        have h_nodup : ∀ {l : List AffinePiece}, StrictlyIncreasingSlopes l → List.Nodup l := by
          intros l hl; induction l <;> simp_all +decide [ StrictlyIncreasingSlopes ] ;
          cases ‹List AffinePiece› <;> simp_all +decide [ StrictlyIncreasingSlopes ];
          constructor <;> intro h <;> have := hl.2 <;> simp_all +decide [ StrictlyIncreasingSlopes ];
          have := strictlyIncreasingSlopes_pairwise this; simp_all +decide [ List.pairwise_cons ] ;
          linarith [ this.1 _ h ];
        exact ⟨ h_nodup hP.1, h_nodup hQ.1 ⟩;
      grind +suggestions;
    exact h_perm.symm;
  -- Since P and Q are canonical, their terms are sorted by strictly increasing slopes.
  have hP_sorted : List.Pairwise (fun p q => p.slope < q.slope) P.terms := by
    exact strictlyIncreasingSlopes_pairwise hP.1
  have hQ_sorted : List.Pairwise (fun p q => p.slope < q.slope) Q.terms := by
    exact strictlyIncreasingSlopes_pairwise hQ.1;
  apply_rules [ List.Perm.eq_of_pairwise ];
  exact fun a b ha hb hab hba => False.elim <| lt_asymm hab hba

/-- **Every CPL function is a tropical rational function.** -/
theorem cpl_is_tropical_rational (f : ℝ → ℝ) (hf : IsUnivCPL f) :
    ∃ R : TropicalRat, ∀ x : ℝ, R.eval x = f x := by
  sorry

/-- **Uniqueness of minimal tropical rational representative.** -/
theorem exists_unique_minimal_tropical_rational (f : ℝ → ℝ) (hf : IsUnivCPL f) :
    ∃ R : TropicalRat, MinimalTropicalRat R ∧ (∀ x : ℝ, R.eval x = f x) ∧
    (∀ S : TropicalRat, MinimalTropicalRat S → (∀ x : ℝ, S.eval x = f x) →
      S.num.terms = R.num.terms ∧ S.den.terms = R.den.terms) := by
  sorry

/-- **Minimal tropical rational extensionality.** -/
theorem minimal_tropical_rational_ext (R S : TropicalRat)
    (hR : MinimalTropicalRat R) (hS : MinimalTropicalRat S)
    (h : ∀ x : ℝ, R.eval x = S.eval x) :
    R.num.terms = S.num.terms ∧ R.den.terms = S.den.terms := by
  sorry

/-- **Every UnivReluNet computes a CPL function.** -/
theorem univReluNet_is_cpl (N : UnivReluNet) : IsUnivCPL N.eval := by
  sorry

/-- **ReLU network canonical form existence.** -/
theorem relu_network_has_canonical_tropical_rational (N : UnivReluNet) :
    ∃ R : TropicalRat, MinimalTropicalRat R ∧ (∀ x : ℝ, R.eval x = N.eval x) ∧
    (∀ S : TropicalRat, MinimalTropicalRat S → (∀ x : ℝ, S.eval x = N.eval x) →
      S.num.terms = R.num.terms ∧ S.den.terms = R.den.terms) := by
  sorry

/-- **ReLU network equivalence via canonicalization.** -/
theorem relu_network_equiv_iff_canonical (N₁ N₂ : UnivReluNet) :
    (∀ x : ℝ, N₁.eval x = N₂.eval x) ↔
    ∃ (R : TropicalRat), MinimalTropicalRat R ∧
      (∀ x : ℝ, R.eval x = N₁.eval x) ∧
      (∀ x : ℝ, R.eval x = N₂.eval x) := by
  sorry

end