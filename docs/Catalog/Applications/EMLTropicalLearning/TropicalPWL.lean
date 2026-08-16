import Mathlib
import Shared.NeuralCoding.Relu

/-!
# Tropical piecewise-linear models and their exact ReLU realization

This file develops the *function-level* algebra of one-variable max-plus (tropical)
polynomials and tropical rational functions, and proves that the class of tropical
rational functions coincides **exactly** with the class of functions computed by
one-dimensional feed-forward ReLU expressions (arbitrary depth, real weights).

The concrete carrier is a `tmax`-fold over a list of affine terms:
`tpEval b l x = max (b.1 * x + b.2) (max over t ∈ l of (t.1 * x + t.2))`.

Main results:

* `tmax_add_tmax` — the tropical *product* rule: a sum of two max-plus expressions is
  again a max-plus expression, over the list of pairwise sums.
* `IsTropPoly.add`, `IsTropPoly.max`, `IsTropPoly.smul_nonneg` — closure of tropical
  polynomials under tropical multiplication (ordinary `+`), tropical addition
  (`max`) and nonnegative scaling.
* `IsTropRat.add`, `IsTropRat.neg`, `IsTropRat.smul`, `IsTropRat.max`,
  `IsTropRat.min`, `IsTropRat.relu` — the tropical rational functions form a lattice
  ordered vector space closed under `relu`.
* `ReluExpr.eval_isTropRat` and `IsTropRat.exists_reluExpr` combine into
  `isTropRat_iff_reluExpr`: *a one-variable function is tropical rational iff it is
  computed by a ReLU expression.*  This is the one-dimensional form of the
  tropical-geometry description of ReLU networks, here with both inclusions given by
  explicit, verified constructions.

Everything is used downstream in `TropicalERM.lean`, where the trained model of
tropical gradient descent is shown to be a tropical rational minimizer of the
tropical loss.
-/

noncomputable section

namespace EMLTropicalPWL

/-! ## The max-plus fold -/

/-- `tmax b l` is the maximum of the base value `b` and all entries of `l`.
This is the tropical sum (`⊕ = max`) of a nonempty finite family. -/
def tmax (b : ℝ) : List ℝ → ℝ
  | [] => b
  | y :: ys => max y (tmax b ys)

@[simp] theorem tmax_nil (b : ℝ) : tmax b [] = b := rfl

@[simp] theorem tmax_cons (b y : ℝ) (ys : List ℝ) :
    tmax b (y :: ys) = max y (tmax b ys) := rfl

theorem tmax_base_le (b : ℝ) (l : List ℝ) : b ≤ tmax b l := by
  induction l with
  | nil => exact le_rfl
  | cons y ys ih => exact le_trans ih (le_max_right _ _)

theorem le_tmax_of_mem {b y : ℝ} {l : List ℝ} (hy : y ∈ l) : y ≤ tmax b l := by
  induction l with
  | nil => cases hy
  | cons z zs ih =>
      rcases List.mem_cons.mp hy with h | h
      · exact h ▸ le_max_left _ _
      · exact le_trans (ih h) (le_max_right _ _)

theorem tmax_le {b M : ℝ} {l : List ℝ} (hb : b ≤ M) (hl : ∀ y ∈ l, y ≤ M) :
    tmax b l ≤ M := by
  induction l with
  | nil => exact hb
  | cons y ys ih =>
      exact max_le (hl y (List.mem_cons_self ..))
        (ih fun z hz => hl z (List.mem_cons_of_mem _ hz))

/-- A max-plus fold is always attained: either at the base or at a list entry. -/
theorem tmax_attained (b : ℝ) (l : List ℝ) : tmax b l = b ∨ tmax b l ∈ l := by
  induction l with
  | nil => exact Or.inl rfl
  | cons y ys ih =>
      rcases le_total y (tmax b ys) with h | h
      · rw [tmax_cons, max_eq_right h]
        rcases ih with h' | h'
        · exact Or.inl h'
        · exact Or.inr (List.mem_cons_of_mem _ h')
      · rw [tmax_cons, max_eq_left h]
        exact Or.inr (List.mem_cons_self ..)

theorem tmax_append_cons (b b' : ℝ) (l l' : List ℝ) :
    tmax b (l ++ b' :: l') = max (tmax b l) (tmax b' l') := by
  apply le_antisymm
  · refine tmax_le (le_trans (tmax_base_le b l) (le_max_left _ _)) ?_
    intro y hy
    rcases List.mem_append.mp hy with h | h
    · exact le_trans (le_tmax_of_mem h) (le_max_left _ _)
    · rcases List.mem_cons.mp h with h | h
      · rw [h]; exact le_trans (tmax_base_le b' l') (le_max_right _ _)
      · exact le_trans (le_tmax_of_mem h) (le_max_right _ _)
  · apply max_le
    · exact tmax_le (tmax_base_le _ _) fun y hy =>
        le_tmax_of_mem (List.mem_append.mpr (Or.inl hy))
    · refine tmax_le (le_tmax_of_mem (List.mem_append.mpr (Or.inr (List.mem_cons_self ..)))) ?_
      intro y hy
      exact le_tmax_of_mem (List.mem_append.mpr (Or.inr (List.mem_cons_of_mem _ hy)))

/-- The list of pairwise sums of the two max-plus expressions `(b, l)` and `(b', l')`,
excluding the base pair `b + b'`. -/
def pairSums (b : ℝ) (l : List ℝ) (b' : ℝ) (l' : List ℝ) : List ℝ :=
  l.map (· + b') ++ l'.map (b + ·) ++ l.flatMap fun u => l'.map (u + ·)

theorem mem_pairSums_le {b b' M M' : ℝ} {l l' : List ℝ}
    (hb : b ≤ M) (hl : ∀ y ∈ l, y ≤ M) (hb' : b' ≤ M') (hl' : ∀ y ∈ l', y ≤ M') :
    ∀ z ∈ pairSums b l b' l', z ≤ M + M' := by
  intro z hz
  simp only [pairSums, List.mem_append, List.mem_map, List.mem_flatMap] at hz
  rcases hz with (⟨u, hu, rfl⟩ | ⟨v, hv, rfl⟩) | ⟨u, hu, v, hv, rfl⟩
  · exact add_le_add (hl u hu) hb'
  · exact add_le_add hb (hl' v hv)
  · exact add_le_add (hl u hu) (hl' v hv)

/-- **Tropical product rule.**  The ordinary sum of two max-plus folds is the max-plus
fold over the list of pairwise sums.  (Tropical multiplication is ordinary addition.) -/
theorem tmax_add_tmax (b b' : ℝ) (l l' : List ℝ) :
    tmax b l + tmax b' l' = tmax (b + b') (pairSums b l b' l') := by
  apply le_antisymm
  · rcases tmax_attained b l with h | h <;> rcases tmax_attained b' l' with h' | h'
    · rw [h, h']; exact tmax_base_le _ _
    · refine le_tmax_of_mem (b := b + b') (l := pairSums b l b' l') ?_
      simp only [pairSums, List.mem_append, List.mem_map]
      exact Or.inl (Or.inr ⟨tmax b' l', h', by rw [h]⟩)
    · refine le_tmax_of_mem (b := b + b') (l := pairSums b l b' l') ?_
      simp only [pairSums, List.mem_append, List.mem_map]
      exact Or.inl (Or.inl ⟨tmax b l, h, by rw [h']⟩)
    · refine le_tmax_of_mem (b := b + b') (l := pairSums b l b' l') ?_
      simp only [pairSums, List.mem_append, List.mem_flatMap, List.mem_map]
      exact Or.inr ⟨tmax b l, h, tmax b' l', h', rfl⟩
  · exact tmax_le (add_le_add (tmax_base_le _ _) (tmax_base_le _ _))
      (mem_pairSums_le (tmax_base_le _ _) (fun _ hy => le_tmax_of_mem hy)
        (tmax_base_le _ _) fun _ hy => le_tmax_of_mem hy)

theorem smul_tmax {c : ℝ} (hc : 0 ≤ c) (b : ℝ) (l : List ℝ) :
    c * tmax b l = tmax (c * b) (l.map (c * ·)) := by
  induction l with
  | nil => simp
  | cons y ys ih =>
      simp only [tmax_cons, List.map_cons]
      rw [← ih, mul_max_of_nonneg _ _ hc]

/-! ## Tropical polynomials and tropical rational functions -/

/-- Evaluation of the max-plus polynomial with base term `b` and further terms `l`
(each term is a pair `(slope, coefficient)` describing a tropical monomial). -/
def tpEval (b : ℝ × ℝ) (l : List (ℝ × ℝ)) (x : ℝ) : ℝ :=
  tmax (b.1 * x + b.2) (l.map fun t => t.1 * x + t.2)

/-- A function is a *tropical polynomial* if it is a finite max of affine functions. -/
def IsTropPoly (f : ℝ → ℝ) : Prop :=
  ∃ (b : ℝ × ℝ) (l : List (ℝ × ℝ)), ∀ x, f x = tpEval b l x

/-- A function is a *tropical rational function* if it is a difference of two tropical
polynomials. -/
def IsTropRat (f : ℝ → ℝ) : Prop :=
  ∃ P Q : ℝ → ℝ, IsTropPoly P ∧ IsTropPoly Q ∧ ∀ x, f x = P x - Q x

theorem isTropPoly_affine (a c : ℝ) : IsTropPoly fun x => a * x + c :=
  ⟨(a, c), [], fun _ => rfl⟩

theorem isTropPoly_const (c : ℝ) : IsTropPoly fun _ => c := by
  refine ⟨(0, c), [], fun x => ?_⟩
  simp [tpEval]

/-- Term list of the tropical product of two tropical polynomials. -/
def tpMulTerms (b : ℝ × ℝ) (l : List (ℝ × ℝ)) (b' : ℝ × ℝ) (l' : List (ℝ × ℝ)) :
    List (ℝ × ℝ) :=
  l.map (fun t => (t.1 + b'.1, t.2 + b'.2)) ++ l'.map (fun t => (b.1 + t.1, b.2 + t.2))
    ++ l.flatMap fun u => l'.map fun t => (u.1 + t.1, u.2 + t.2)

theorem tpEval_mul (b b' : ℝ × ℝ) (l l' : List (ℝ × ℝ)) (x : ℝ) :
    tpEval (b.1 + b'.1, b.2 + b'.2) (tpMulTerms b l b' l') x
      = tpEval b l x + tpEval b' l' x := by
  have hmap : ((tpMulTerms b l b' l').map fun t => t.1 * x + t.2)
      = pairSums (b.1 * x + b.2) (l.map fun t => t.1 * x + t.2)
          (b'.1 * x + b'.2) (l'.map fun t => t.1 * x + t.2) := by
    simp only [tpMulTerms, pairSums, List.map_append, List.map_map, List.flatMap_map,
      List.map_flatMap, Function.comp_def]
    refine congrArg₂ (· ++ ·) (congrArg₂ (· ++ ·) ?_ ?_) ?_
    · exact List.map_congr_left fun t _ => by ring
    · exact List.map_congr_left fun t _ => by ring
    · refine List.flatMap_congr fun u _ => ?_
      exact List.map_congr_left fun t _ => by ring
  simp only [tpEval, hmap]
  rw [tmax_add_tmax]
  congr 1
  ring

/-- Tropical polynomials are closed under ordinary addition (tropical multiplication). -/
theorem IsTropPoly.add {P Q : ℝ → ℝ} (hP : IsTropPoly P) (hQ : IsTropPoly Q) :
    IsTropPoly fun x => P x + Q x := by
  obtain ⟨b, l, hb⟩ := hP
  obtain ⟨b', l', hb'⟩ := hQ
  refine ⟨(b.1 + b'.1, b.2 + b'.2), tpMulTerms b l b' l', fun x => ?_⟩
  show P x + Q x = _
  rw [hb x, hb' x, tpEval_mul]

/-- Tropical polynomials are closed under `max` (tropical addition). -/
theorem IsTropPoly.max {P Q : ℝ → ℝ} (hP : IsTropPoly P) (hQ : IsTropPoly Q) :
    IsTropPoly fun x => max (P x) (Q x) := by
  obtain ⟨b, l, hb⟩ := hP
  obtain ⟨b', l', hb'⟩ := hQ
  refine ⟨b, l ++ (b'.1, b'.2) :: l', fun x => ?_⟩
  show Max.max (P x) (Q x) = _
  rw [hb x, hb' x]
  simp only [tpEval, List.map_append, List.map_cons]
  exact (tmax_append_cons _ _ _ _).symm

/-- Tropical polynomials are closed under scaling by a nonnegative constant. -/
theorem IsTropPoly.smul_nonneg {P : ℝ → ℝ} (hP : IsTropPoly P) {c : ℝ} (hc : 0 ≤ c) :
    IsTropPoly fun x => c * P x := by
  obtain ⟨b, l, hb⟩ := hP
  refine ⟨(c * b.1, c * b.2), l.map fun t => (c * t.1, c * t.2), fun x => ?_⟩
  show c * P x = _
  rw [hb x]
  simp only [tpEval, List.map_map, Function.comp_def]
  rw [smul_tmax hc]
  congr 1
  · ring
  · simp only [List.map_map, Function.comp_def]
    exact (List.map_congr_left fun t _ => by ring).symm

theorem IsTropPoly.congr {P Q : ℝ → ℝ} (hP : IsTropPoly P) (h : ∀ x, Q x = P x) :
    IsTropPoly Q := by
  obtain ⟨b, l, hb⟩ := hP
  exact ⟨b, l, fun x => (h x).trans (hb x)⟩

theorem IsTropPoly.isTropRat {P : ℝ → ℝ} (hP : IsTropPoly P) : IsTropRat P :=
  ⟨P, fun _ => 0, hP, isTropPoly_const 0, fun x => by simp⟩

theorem isTropRat_affine (a c : ℝ) : IsTropRat fun x => a * x + c :=
  (isTropPoly_affine a c).isTropRat

theorem IsTropRat.congr {f g : ℝ → ℝ} (hf : IsTropRat f) (h : ∀ x, g x = f x) :
    IsTropRat g := by
  obtain ⟨P, Q, hP, hQ, hPQ⟩ := hf
  exact ⟨P, Q, hP, hQ, fun x => (h x).trans (hPQ x)⟩

theorem IsTropRat.add {f g : ℝ → ℝ} (hf : IsTropRat f) (hg : IsTropRat g) :
    IsTropRat fun x => f x + g x := by
  obtain ⟨P₁, Q₁, hP₁, hQ₁, h₁⟩ := hf
  obtain ⟨P₂, Q₂, hP₂, hQ₂, h₂⟩ := hg
  refine ⟨fun x => P₁ x + P₂ x, fun x => Q₁ x + Q₂ x, hP₁.add hP₂, hQ₁.add hQ₂, fun x => ?_⟩
  show f x + g x = (P₁ x + P₂ x) - (Q₁ x + Q₂ x)
  rw [h₁ x, h₂ x]; ring

theorem IsTropRat.neg {f : ℝ → ℝ} (hf : IsTropRat f) : IsTropRat fun x => -f x := by
  obtain ⟨P, Q, hP, hQ, h⟩ := hf
  refine ⟨Q, P, hQ, hP, fun x => ?_⟩
  show -f x = Q x - P x
  rw [h x]; ring

theorem IsTropRat.smul {f : ℝ → ℝ} (hf : IsTropRat f) (c : ℝ) :
    IsTropRat fun x => c * f x := by
  obtain ⟨P, Q, hP, hQ, h⟩ := hf
  rcases le_total 0 c with hc | hc
  · refine ⟨fun x => c * P x, fun x => c * Q x, hP.smul_nonneg hc, hQ.smul_nonneg hc,
      fun x => ?_⟩
    show c * f x = c * P x - c * Q x
    rw [h x]; ring
  · have hc' : (0:ℝ) ≤ -c := by linarith
    refine ⟨fun x => (-c) * Q x, fun x => (-c) * P x, hQ.smul_nonneg hc', hP.smul_nonneg hc',
      fun x => ?_⟩
    show c * f x = -c * Q x - -c * P x
    rw [h x]; ring

theorem IsTropRat.sub {f g : ℝ → ℝ} (hf : IsTropRat f) (hg : IsTropRat g) :
    IsTropRat fun x => f x - g x := by
  refine (hf.add hg.neg).congr fun x => by ring

/-- The lattice operation `max` preserves tropical rationality; the key identity is
`(P₁ - Q₁) ⊔ (P₂ - Q₂) = ((P₁ ⊙ Q₂) ⊕ (P₂ ⊙ Q₁)) ⊘ (Q₁ ⊙ Q₂)`. -/
theorem IsTropRat.max {f g : ℝ → ℝ} (hf : IsTropRat f) (hg : IsTropRat g) :
    IsTropRat fun x => max (f x) (g x) := by
  obtain ⟨P₁, Q₁, hP₁, hQ₁, h₁⟩ := hf
  obtain ⟨P₂, Q₂, hP₂, hQ₂, h₂⟩ := hg
  refine ⟨fun x => Max.max (P₁ x + Q₂ x) (P₂ x + Q₁ x), fun x => Q₁ x + Q₂ x,
    IsTropPoly.max (hP₁.add hQ₂) (hP₂.add hQ₁), hQ₁.add hQ₂, fun x => ?_⟩
  show Max.max (f x) (g x) = Max.max (P₁ x + Q₂ x) (P₂ x + Q₁ x) - (Q₁ x + Q₂ x)
  rw [h₁ x, h₂ x, ← max_sub_sub_right]
  congr 1 <;> ring

theorem IsTropRat.min {f g : ℝ → ℝ} (hf : IsTropRat f) (hg : IsTropRat g) :
    IsTropRat fun x => min (f x) (g x) := by
  refine ((IsTropRat.max hf.neg hg.neg).neg).congr fun x => ?_
  show Min.min (f x) (g x) = -Max.max (-f x) (-g x)
  rw [← min_neg_neg]
  simp

theorem IsTropRat.relu {f : ℝ → ℝ} (hf : IsTropRat f) : IsTropRat fun x => relu (f x) :=
  (IsTropRat.max hf (isTropPoly_const 0).isTropRat).congr fun _ => rfl

/-! ## ReLU expressions and the exact correspondence -/

/-- Syntax of one-dimensional feed-forward ReLU networks: affine units, additions,
scalar multiples and ReLU activations, of arbitrary depth. -/
inductive ReluExpr : Type
  | affine (a b : ℝ) : ReluExpr
  | add (f g : ReluExpr) : ReluExpr
  | smul (c : ℝ) (f : ReluExpr) : ReluExpr
  | act (f : ReluExpr) : ReluExpr

/-- Semantics of a ReLU expression. -/
def ReluExpr.eval : ReluExpr → ℝ → ℝ
  | .affine a b, x => a * x + b
  | .add f g, x => f.eval x + g.eval x
  | .smul c f, x => c * f.eval x
  | .act f, x => relu (f.eval x)

/-- **Every ReLU network computes a tropical rational function.** -/
theorem ReluExpr.eval_isTropRat : ∀ e : ReluExpr, IsTropRat e.eval := by
  intro e
  induction e with
  | affine a b => exact isTropRat_affine a b
  | add f g hf hg => exact hf.add hg
  | smul c f hf => exact hf.smul c
  | act f hf => exact hf.relu

theorem max_eq_add_relu (u v : ℝ) : max u v = v + relu (u - v) := by
  unfold relu
  rcases le_total u v with h | h
  · rw [max_eq_right h, max_eq_right (by linarith : u - v ≤ 0)]; ring
  · rw [max_eq_left h, max_eq_left (by linarith : 0 ≤ u - v)]; ring

/-- The ReLU expression realizing the tropical polynomial with base `b` and terms `l`.
Each extra tropical monomial costs exactly one ReLU unit, via `max u v = v + relu (u - v)`. -/
def tpExpr (b : ℝ × ℝ) : List (ℝ × ℝ) → ReluExpr
  | [] => .affine b.1 b.2
  | t :: ts =>
      .add (tpExpr b ts)
        (.act (.add (.affine t.1 t.2) (.smul (-1) (tpExpr b ts))))

theorem tpExpr_eval (b : ℝ × ℝ) (l : List (ℝ × ℝ)) (x : ℝ) :
    (tpExpr b l).eval x = tpEval b l x := by
  induction l with
  | nil => rfl
  | cons t ts ih =>
      have hrec : (tpExpr b ts).eval x = tmax (b.1 * x + b.2) (ts.map fun t => t.1 * x + t.2) :=
        ih
      simp only [tpExpr, ReluExpr.eval, hrec, tpEval, List.map_cons, tmax_cons]
      rw [max_eq_add_relu (t.1 * x + t.2)
        (tmax (b.1 * x + b.2) (ts.map fun t => t.1 * x + t.2))]
      ring_nf

/-- **Every tropical rational function is computed by a ReLU network**, with an explicit
expression whose ReLU count is the number of tropical monomials. -/
theorem IsTropRat.exists_reluExpr {f : ℝ → ℝ} (hf : IsTropRat f) :
    ∃ e : ReluExpr, ∀ x, e.eval x = f x := by
  obtain ⟨P, Q, ⟨b, l, hb⟩, ⟨b', l', hb'⟩, h⟩ := hf
  refine ⟨.add (tpExpr b l) (.smul (-1) (tpExpr b' l')), fun x => ?_⟩
  simp only [ReluExpr.eval, tpExpr_eval, h x, hb x, hb' x]
  ring

/-- **Tropical/ReLU dictionary (one variable).**  A function `ℝ → ℝ` is tropical
rational precisely when some feed-forward ReLU expression computes it. -/
theorem isTropRat_iff_reluExpr (f : ℝ → ℝ) :
    IsTropRat f ↔ ∃ e : ReluExpr, ∀ x, e.eval x = f x := by
  refine ⟨IsTropRat.exists_reluExpr, ?_⟩
  rintro ⟨e, he⟩
  exact e.eval_isTropRat.congr fun x => (he x).symm

/-! ## Quantitative structure: Lipschitz control by tropical slopes -/

theorem tpEval_sub_le {b : ℝ × ℝ} {l : List (ℝ × ℝ)} {L : ℝ}
    (hb : |b.1| ≤ L) (hl : ∀ t ∈ l, |t.1| ≤ L) (x y : ℝ) :
    tpEval b l x - tpEval b l y ≤ L * |x - y| := by
  have hbound : ∀ s c : ℝ, |s| ≤ L → s * x + c ≤ (s * y + c) + L * |x - y| := by
    intro s c hs
    have h1 : s * x - s * y ≤ |s| * |x - y| := by
      have hrw : s * x - s * y = s * (x - y) := by ring
      rw [hrw, ← abs_mul]
      exact le_abs_self _
    nlinarith [abs_nonneg (x - y)]
  rcases tmax_attained (b.1 * x + b.2) (l.map fun t => t.1 * x + t.2) with h | h
  · have h1 : b.1 * x + b.2 ≤ (b.1 * y + b.2) + L * |x - y| := hbound _ _ hb
    have h2 : b.1 * y + b.2 ≤ tpEval b l y := tmax_base_le _ _
    simp only [tpEval] at h2 ⊢
    rw [h]
    linarith
  · obtain ⟨t, ht, hval⟩ := List.mem_map.mp h
    have h1 : t.1 * x + t.2 ≤ (t.1 * y + t.2) + L * |x - y| := hbound _ _ (hl t ht)
    have h2 : t.1 * y + t.2 ≤ tpEval b l y :=
      le_tmax_of_mem (List.mem_map.mpr ⟨t, ht, rfl⟩)
    simp only [tpEval] at h2 ⊢
    rw [← hval]
    linarith

/-- A tropical polynomial is Lipschitz with constant the largest absolute slope of its
tropical monomials. -/
theorem tpEval_lipschitz {b : ℝ × ℝ} {l : List (ℝ × ℝ)} {L : ℝ}
    (hb : |b.1| ≤ L) (hl : ∀ t ∈ l, |t.1| ≤ L) (x y : ℝ) :
    |tpEval b l x - tpEval b l y| ≤ L * |x - y| := by
  rw [abs_sub_le_iff]
  refine ⟨tpEval_sub_le hb hl x y, ?_⟩
  have h := tpEval_sub_le hb hl y x
  rwa [abs_sub_comm] at h

/-- Tropical polynomials are convex: they are finite maxima of affine functions.  This
is what places tropical EML training inside convex nonsmooth optimization. -/
theorem tpEval_convexOn (b : ℝ × ℝ) (l : List (ℝ × ℝ)) :
    ConvexOn ℝ Set.univ (tpEval b l) := by
  refine ⟨convex_univ, ?_⟩
  intro x _ y _ α β hα hβ hαβ
  have hkey : ∀ c₁ c₂ : ℝ, c₁ * (α * x + β * y) + c₂
      = α * (c₁ * x + c₂) + β * (c₁ * y + c₂) := by
    intro c₁ c₂
    have hβ' : β = 1 - α := by linarith
    subst hβ'
    ring
  simp only [smul_eq_mul]
  refine tmax_le ?_ ?_
  · rw [hkey b.1 b.2]
    have hx : b.1 * x + b.2 ≤ tpEval b l x := tmax_base_le _ _
    have hy : b.1 * y + b.2 ≤ tpEval b l y := tmax_base_le _ _
    exact add_le_add (mul_le_mul_of_nonneg_left hx hα) (mul_le_mul_of_nonneg_left hy hβ)
  · intro v hv
    obtain ⟨u, hu, rfl⟩ := List.mem_map.mp hv
    rw [hkey u.1 u.2]
    have hx : u.1 * x + u.2 ≤ tpEval b l x := le_tmax_of_mem (List.mem_map.mpr ⟨u, hu, rfl⟩)
    have hy : u.1 * y + u.2 ≤ tpEval b l y := le_tmax_of_mem (List.mem_map.mpr ⟨u, hu, rfl⟩)
    exact add_le_add (mul_le_mul_of_nonneg_left hx hα) (mul_le_mul_of_nonneg_left hy hβ)

/-! ## Kernel-checked instances -/

example : tmax 0 [3, -1, 2] = 3 := by norm_num [tmax]
example : tpEval (1, 0) [(-1, 0)] 2 = 2 := by norm_num [tpEval, tmax]
example : tpEval (1, 0) [(-1, 0)] (-3) = 3 := by norm_num [tpEval, tmax]
example : (tpExpr (1, 0) [(-1, 0)]).eval (-3) = 3 := by
  norm_num [tpExpr, ReluExpr.eval, relu]

end EMLTropicalPWL