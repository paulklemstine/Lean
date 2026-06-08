import Mathlib

/-!
# Tropical Fermat's Last Theorem and Tropical Varieties

## Overview

We formalize the tropical analogue of Fermat's Last Theorem. In classical number theory,
Fermat's Last Theorem states that xⁿ + yⁿ = zⁿ has no non-trivial solutions in positive
integers for n ≥ 3. In tropical geometry, the situation is dramatically different:
the tropical Fermat equation x^n ⊕ y^n = z^n has a rich, fully characterizable
solution set for every n ≥ 1.

## Key Results

* `tropical_pow_eq` — `a^n = trop(n * untrop a)` in any tropical semiring
* `tropical_fermat_reduction` — The tropical Fermat equation x^n ⊕ y^n = z^n
  is equivalent to x ⊕ y = z (i.e., min(x,y) = z) for all n ≥ 1
* `tropical_fermat_solution_iff` — Complete characterization: (x,y,z) solves the
  tropical Fermat equation iff z = min(x,y)
* `tropical_fermat_curve_eq_line` — The tropical Fermat curve of degree n equals
  the tropical line for all n ≥ 1
* `tropical_kapranov_fermat` — A Kapranov-type theorem: the tropical Fermat
  variety is the set where the minimum in x^n ⊕ y^n ⊕ z^n is achieved twice

## Mathematical Significance

Unlike the classical case, tropical Fermat's "Last Theorem" is really a "First Theorem":
it shows that all Fermat curves tropicalize to the same object — the standard tropical
line. This is a concrete instance of the general principle that tropicalization
collapses algebraic complexity while preserving combinatorial structure.
-/

noncomputable section

open Tropical

/-! ## Section 1: Tropical Power Characterization -/

/-
**Tropical power characterization.**
In the tropical semiring, `a^n = trop(n * untrop(a))`, because tropical
multiplication is classical addition, so tropical exponentiation is
classical scalar multiplication.
-/
theorem tropical_pow_eq (a : Tropical ℤ) (n : ℕ) :
    a ^ n = Tropical.trop ((n : ℤ) * Tropical.untrop a) := by
  induction n <;> simp_all +decide [ pow_succ, add_mul ]

/-! ## Section 2: Tropical Fermat Reduction -/

/-
**Tropical Fermat reduction theorem.**
The tropical Fermat equation `x^n ⊕ y^n = z^n` (where ⊕ = tropical addition = min)
reduces to `x ⊕ y = z` for any `n ≥ 1`. This is because:
- `x^n = trop(n * untrop x)`, etc.
- So `x^n ⊕ y^n = trop(min(n*x', n*y'))` and `z^n = trop(n*z')`
- `min(n*x', n*y') = n*z'` iff `n * min(x', y') = n*z'` iff `min(x',y') = z'`
-/
theorem tropical_fermat_reduction (x y z : Tropical ℤ) (n : ℕ) (hn : 1 ≤ n) :
    x ^ n + y ^ n = z ^ n ↔ x + y = z := by
  rw [ tropical_pow_eq, tropical_pow_eq, tropical_pow_eq, Tropical.trop_add_def, Tropical.trop_add_def ];
  simp +decide [ ← mul_min_of_nonneg, hn ];
  rw [ ← Tropical.trop_inj_iff ] ; aesop

/-
**Tropical Fermat solution characterization.**
A triple `(x, y, z)` of tropical integers satisfies `x^n ⊕ y^n = z^n`
if and only if `untrop z = min (untrop x) (untrop y)`.
-/
theorem tropical_fermat_solution_iff (x y z : Tropical ℤ) (n : ℕ) (hn : 1 ≤ n) :
    x ^ n + y ^ n = z ^ n ↔
      Tropical.untrop z = min (Tropical.untrop x) (Tropical.untrop y) := by
  constructor <;> intro H;
  · exact tropical_fermat_reduction x y z n hn |>.mp H |> fun h => h ▸ Tropical.untrop_add x y;
  · convert tropical_fermat_reduction x y z n hn |>.2 _ using 1;
    convert congr_arg Tropical.trop H using 1;
    · rw [ H, Tropical.trop_add_def ];
    · rw [ ← H, Tropical.trop_untrop ]

/-! ## Section 3: Tropical Fermat Curves and Lines -/

/-- The **tropical Fermat curve** of degree `n`: the set of pairs `(a, b)` in `ℤ × ℤ`
such that `trop(a)^n ⊕ trop(b)^n = trop(0)^n` (i.e., the zero-set relative to
the tropical multiplicative identity `trop(0) = 1`). -/
def TropicalFermatCurve (n : ℕ) : Set (ℤ × ℤ) :=
  { p | Tropical.trop p.1 ^ n + Tropical.trop p.2 ^ n =
        (1 : Tropical ℤ) ^ n }

/-- The **tropical line**: the set `{(a, b) : min(a, b) = 0}`, which is the
tropical zero-set of `x ⊕ y ⊕ 1`. This is the fundamental object in tropical
geometry — a tree with three rays emanating from the origin. -/
def TropicalLine : Set (ℤ × ℤ) :=
  { p | min p.1 p.2 = 0 }

/-
**All tropical Fermat curves are tropical lines.**
For any `n ≥ 1`, the tropical Fermat curve of degree `n` equals the tropical line.
This is the tropical analogue of Fermat's Last Theorem, but with the opposite
conclusion: instead of having no solutions, *every* Fermat curve has the same
solution set — the tropical line.
-/
theorem tropical_fermat_curve_eq_line (n : ℕ) (hn : 1 ≤ n) :
    TropicalFermatCurve n = TropicalLine := by
  ext ⟨x, y⟩; simp [TropicalFermatCurve, TropicalLine];
  convert tropical_fermat_solution_iff ( Tropical.trop x ) ( Tropical.trop y ) ( Tropical.trop 0 ) n hn using 1 ; norm_num [ tropical_pow_eq ];
  rw [ eq_comm ]

/-! ## Section 4: Tropical Varieties and the Kapranov Theorem -/

/-- A **tropical monomial** in two variables, represented as a triple `(c, i, j)`
meaning `c + i*x + j*y` in classical arithmetic (which corresponds to
`c ⊗ x^i ⊗ y^j` in tropical arithmetic). -/
structure TropMonomial where
  coeff : ℤ
  xExp : ℕ
  yExp : ℕ

/-- Evaluate a tropical monomial at a point `(x, y)`. In tropical arithmetic,
this computes `coeff ⊗ x^i ⊗ y^j = coeff + i*x + j*y` (classically). -/
def TropMonomial.eval (m : TropMonomial) (x y : ℤ) : ℤ :=
  m.coeff + m.xExp * x + m.yExp * y

/-- A **tropical polynomial** is a finite list of tropical monomials.
The tropical polynomial evaluates as the tropical sum (= min) of its monomials. -/
def TropPoly := List TropMonomial

/-- Evaluate a tropical polynomial at a point. Returns the minimum of all
monomial evaluations. Returns 0 for the empty polynomial. -/
def TropPoly.eval (p : TropPoly) (x y : ℤ) : ℤ :=
  match p.map (fun m => m.eval x y) with
  | [] => 0
  | (v :: vs) => vs.foldl min v

/-- The **tropical variety** of a tropical polynomial: the set of points where
the minimum is achieved by at least two distinct monomials. This is the
tropical analogue of the zero-set of a classical polynomial. -/
def TropicalVariety (p : TropPoly) : Set (ℤ × ℤ) :=
  { pt | ∃ i j : Fin p.length, i ≠ j ∧
    (p.get i).eval pt.1 pt.2 = TropPoly.eval p pt.1 pt.2 ∧
    (p.get j).eval pt.1 pt.2 = TropPoly.eval p pt.1 pt.2 }

/-- The **tropical Fermat polynomial** of degree `n`:
`x^n ⊕ y^n ⊕ 0` = `trop(n*x) + trop(n*y) + trop(0)`.
In classical coordinates, this is `min(n*x, n*y, 0)`. -/
def fermatPoly (n : ℕ) : TropPoly :=
  [⟨0, n, 0⟩, ⟨0, 0, n⟩, ⟨0, 0, 0⟩]

/-- The **tropical Fermat variety**: points where min(n*x, n*y, 0) is achieved
by at least two of the three terms. -/
def TropicalFermatVariety (n : ℕ) : Set (ℤ × ℤ) :=
  TropicalVariety (fermatPoly n)

/-- The **standard tropical line variety**: the set where min(x, y, 0) is
achieved at least twice. This decomposes into three rays:
- Ray 1: `{(0, t) : t ≥ 0}` (where min is achieved by x and the constant)
- Ray 2: `{(t, 0) : t ≥ 0}` (where min is achieved by y and the constant)
- Ray 3: `{(t, t) : t ≤ 0}` (where min is achieved by x and y) -/
def StandardTropicalLineVariety : Set (ℤ × ℤ) :=
  { pt | (pt.1 = pt.2 ∧ pt.1 ≤ 0) ∨
         (pt.1 = 0 ∧ pt.2 ≥ 0) ∨
         (pt.2 = 0 ∧ pt.1 ≥ 0) }

/-
**Kapranov-type theorem for the tropical Fermat curve.**
The tropical Fermat variety of degree `n ≥ 1` equals the standard tropical line variety.
This is a concrete instance of Kapranov's theorem: the tropicalization of the
Fermat curve `x^n + y^n + 1 = 0` is independent of `n` and equals the
standard tropical line.

Proof sketch: A point lies in the Fermat variety iff min(nx, ny, 0) is achieved
at least twice. Since `n ≥ 1`, the function `t ↦ nt` is order-preserving on ℤ,
so `min(nx, ny, 0)` is achieved twice iff `min(x, y, 0)` is achieved twice.
The latter condition decomposes into the three rays.
-/
set_option maxHeartbeats 800000 in
theorem tropical_kapranov_fermat (n : ℕ) (hn : 1 ≤ n) :
    TropicalFermatVariety n = StandardTropicalLineVariety := by
  ext ⟨x, y⟩;
  constructor;
  · unfold TropicalFermatVariety StandardTropicalLineVariety;
    rintro ⟨ i, j, hij, hi, hj ⟩;
    fin_cases i <;> fin_cases j <;> simp_all +decide [ TropMonomial.eval, TropPoly.eval ];
    all_goals unfold fermatPoly at *; simp +decide [ List.map ] at *;
    all_goals rw [ eq_comm, min_def, min_def ] at *; split_ifs at * <;> first | nlinarith | exact Or.inl ⟨ by nlinarith, by nlinarith ⟩ | exact Or.inr <| Or.inl ⟨ by nlinarith, by nlinarith ⟩ | exact Or.inr <| Or.inr ⟨ by nlinarith, by nlinarith ⟩ ;
  · intro h;
    rcases h with ( ⟨ h₁, h₂ ⟩ | ⟨ h₁, h₂ ⟩ | ⟨ h₁, h₂ ⟩ ) <;> simp_all +decide [ StandardTropicalLineVariety, TropicalFermatVariety ];
    · refine' ⟨ ⟨ 0, by simp +decide [ fermatPoly ] ⟩, ⟨ 1, by simp +decide [ fermatPoly ] ⟩, _, _, _ ⟩ <;> simp +decide [ fermatPoly, TropPoly.eval ];
      · unfold TropMonomial.eval; norm_num; nlinarith;
      · unfold TropMonomial.eval; simp +decide [ h₁, h₂ ] ;
        nlinarith;
    · use ⟨ 0, by simp +decide [ fermatPoly ] ⟩, ⟨ 2, by simp +decide [ fermatPoly ] ⟩ ; simp +decide [ fermatPoly ];
      simp +decide [ TropPoly.eval, TropMonomial.eval ];
      positivity;
    · unfold TropicalVariety fermatPoly;
      unfold TropPoly.eval; simp +decide [ TropMonomial.eval ] ;
      refine' ⟨ ⟨ 1, by norm_num ⟩, ⟨ 2, by norm_num ⟩, _, _, _ ⟩ <;> norm_num [ h₁, h₂ ]; all_goals positivity

/-! ## Section 5: Tropical Fermat Has Infinitely Many Solutions -/

/-
**The tropical Fermat curve has infinitely many solutions.**
Unlike the classical case (which has no solutions for n ≥ 3), the tropical
Fermat equation has infinitely many solutions for every n ≥ 1. We prove this
by exhibiting an injection from ℕ into the solution set.
-/
theorem tropical_fermat_infinite_solutions (n : ℕ) (hn : 1 ≤ n) :
    Set.Infinite (TropicalFermatCurve n) := by
  rw [ tropical_fermat_curve_eq_line n hn ];
  -- The map $k \mapsto (k, 0)$ for $k \in \mathbb{N}$ gives infinitely many points in the tropical line.
  have h_inj : Function.Injective (fun k : ℕ => (k, 0) : ℕ → ℤ × ℤ) := by
    aesop_cat;
  exact Set.infinite_of_injective_forall_mem h_inj fun k => by norm_num [ TropicalLine ] ;

/-! ## Section 6: Degree Independence — A Structural Theorem -/

/-
**Tropical Fermat curves are degree-independent.**
For any n, m ≥ 1, the tropical Fermat curves of degree n and m are equal.
This is the strongest form of tropical Fermat's theorem: not only does every
Fermat curve have solutions, but all Fermat curves are the *same* curve.
-/
theorem tropical_fermat_degree_independent (n m : ℕ) (hn : 1 ≤ n) (hm : 1 ≤ m) :
    TropicalFermatCurve n = TropicalFermatCurve m := by
  rw [ tropical_fermat_curve_eq_line n hn, tropical_fermat_curve_eq_line m hm ]

/-! ## Section 7: Tropical Balancing Condition -/

/-- The **weight** of an edge in a tropical curve. In the tropical Fermat variety,
each of the three rays has a natural weight equal to the degree n of the curve.
The balancing condition states that the weighted sum of primitive direction
vectors at any vertex is zero. -/
structure TropicalEdge where
  direction : ℤ × ℤ
  weight : ℕ

/-- The three rays of the tropical Fermat variety of degree n, with their
primitive directions and weights. -/
def fermatRays (n : ℕ) : List TropicalEdge :=
  [⟨(-1, -1), n⟩,   -- Ray 3: going in direction (-1,-1)
   ⟨(1, 0), n⟩,     -- Ray 2: going in direction (1,0)
   ⟨(0, 1), n⟩]

/-
Ray 1: going in direction (0,1)

**Tropical balancing condition for the Fermat curve.**
The weighted sum of primitive direction vectors at the origin (the unique
vertex of the tropical Fermat curve) is zero. This is the fundamental
constraint in tropical geometry ensuring that the curve is the
tropicalization of an actual algebraic curve.
-/
theorem tropical_fermat_balancing (n : ℕ) :
    let rays := fermatRays n
    (rays.map (fun e => ((e.weight : ℤ) * e.direction.1, (e.weight : ℤ) * e.direction.2))).foldl
      (fun acc v => (acc.1 + v.1, acc.2 + v.2)) (0, 0) = (0, 0) := by
  simp +decide [ fermatRays ]

/-! ## Section 8: Conjectures -/

/-- **Conjecture: Tropical Fermat variety genus.**
The genus of the tropical Fermat curve is 0 for all n.
This is a testable prediction: one can compute the first Betti number of
the tropical curve (as a graph) and verify it equals 0.

For computational testing: the tropical Fermat curve is a tree with one vertex
and three unbounded rays. A tree has first Betti number 0, so genus = 0.
This can be verified by checking: edges - vertices + connected_components = 0,
i.e., 3 - 1 + 0 = 2 ≠ 0... but wait, for unbounded rays we need to be more
careful. The graph has 1 vertex and 3 half-edges (rays), so
genus = 1 - 1 = 0 (since genus = 1 - χ where χ = V - E_compact for the
compact part of the curve, which has V=1 and E_compact=0). -/
def tropicalFermatGenus (_n : ℕ) : ℕ := 0

/-
**Conjecture (testable):** The number of bounded edges in the tropical Fermat
variety of degree n is always 0 — the tropical curve is a star graph with no
bounded edges, regardless of degree. This is computationally verifiable for any
specific n by examining the tropical variety structure.
-/
theorem tropical_fermat_no_bounded_edges_conjecture (_n : ℕ) (_hn : 1 ≤ _n) :
    -- The tropical Fermat variety has no bounded connected components
    -- (all edges are rays going to infinity)
    ∀ p ∈ StandardTropicalLineVariety,
      (∃ d : ℤ, d > 0 ∧ (p.1 + d, p.2) ∈ StandardTropicalLineVariety) ∨
      (∃ d : ℤ, d > 0 ∧ (p.1, p.2 + d) ∈ StandardTropicalLineVariety) ∨
      (∃ d : ℤ, d < 0 ∧ (p.1 + d, p.2 + d) ∈ StandardTropicalLineVariety) := by
  unfold StandardTropicalLineVariety;
  simp +zetaDelta at *;
  grind +ring

end