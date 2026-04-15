/-! # CatalogBuild.Bridges.ChipFiring

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 19
-/

import Mathlib

noncomputable section

/-- A graph divisor is an integer-valued function on vertices. -/
abbrev GraphDivisor (n : ℕ) := Fin n → ℤ

/-- The degree of a divisor. -/

def divisorDeg (D : GraphDivisor n) : ℤ := ∑ i : Fin n, D i

/-- A graph Laplacian for divisor theory. -/

structure GraphLapl (n : ℕ) where
  L : Matrix (Fin n) (Fin n) ℤ
  symmetric : L.IsSymm
  row_sum_zero : ∀ i : Fin n, ∑ j : Fin n, L i j = 0

/-- A principal divisor. -/

def IsPrincipal (grL : GraphLapl n) (D : GraphDivisor n) : Prop :=
  ∃ f : Fin n → ℤ, ∀ i, D i = ∑ j : Fin n, grL.L i j * f j

/-- Linear equivalence: D₁ ~ D₂ iff D₁ - D₂ is principal. -/

def GraphLinEquiv (grL : GraphLapl n) (D₁ D₂ : GraphDivisor n) : Prop :=
  IsPrincipal grL (D₁ - D₂)

/-- Linear equivalence is reflexive. -/

theorem lin_equiv_refl (grL : GraphLapl n) (D : GraphDivisor n) :
    GraphLinEquiv grL D D := ⟨0, by simp⟩

/-
Linear equivalence is symmetric.
-/

theorem lin_equiv_symm (grL : GraphLapl n) (D₁ D₂ : GraphDivisor n) :
    GraphLinEquiv grL D₁ D₂ → GraphLinEquiv grL D₂ D₁ := by
  rintro ⟨ f, hf ⟩;
  use -f;
  simp_all +decide [ sub_eq_iff_eq_add ]

/-
Linear equivalence is transitive.
-/

theorem lin_equiv_trans (grL : GraphLapl n) (D₁ D₂ D₃ : GraphDivisor n) :
    GraphLinEquiv grL D₁ D₂ → GraphLinEquiv grL D₂ D₃ → GraphLinEquiv grL D₁ D₃ := by
  intro h₁ h₂;
  obtain ⟨ f₁, hf₁ ⟩ := h₁
  obtain ⟨ f₂, hf₂ ⟩ := h₂
  use fun i => f₁ i + f₂ i;
  simp_all +decide [ mul_add, Finset.sum_add_distrib ];
  exact fun i => by linear_combination' hf₁ i + hf₂ i;

/-- Linear equivalence is an equivalence relation. -/

theorem lin_equiv_is_equivalence (grL : GraphLapl n) :
    Equivalence (GraphLinEquiv grL) :=
  ⟨lin_equiv_refl grL, fun h => lin_equiv_symm grL _ _ h,
   fun h₁ h₂ => lin_equiv_trans grL _ _ _ h₁ h₂⟩

/-
The degree of a principal divisor is zero.
-/

theorem principal_divisor_degree_zero (grL : GraphLapl n) (D : GraphDivisor n)
    (hP : IsPrincipal grL D) : divisorDeg D = 0 := by
  obtain ⟨ f, hf ⟩ := hP
  have h_deg : ∑ i, ∑ j, grL.L i j * f j = 0 := by
    rw [ Finset.sum_comm, Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by rw [ mul_comm ] ];
    -- Since $\sum_{x_1} grL.L x_1 x = 0$ for all $x$, we can simplify the expression.
    have h_sum_zero : ∀ x, ∑ x_1, grL.L x_1 x = 0 := by
      exact fun i => by simpa [ grL.symmetric.apply ] using grL.row_sum_zero i;
    simp +decide [ ← Finset.mul_sum _ _ _, h_sum_zero ]
  exact (by
  unfold divisorDeg; aesop;)

/-
Linear equivalence preserves degree.
-/

theorem lin_equiv_preserves_degree (grL : GraphLapl n) (D₁ D₂ : GraphDivisor n)
    (h : GraphLinEquiv grL D₁ D₂) : divisorDeg D₁ = divisorDeg D₂ := by
  -- Factor out the common degree term from the numerator and denominator of the fraction.
  have hfnum : divisorDeg D₁ - divisorDeg D₂ = divisorDeg (D₁ - D₂) := by
    unfold divisorDeg; aesop;
  exact eq_of_sub_eq_zero ( hfnum.trans ( principal_divisor_degree_zero _ _ h ) )

/-- Chip-firing at vertex v. -/

def chipFire (grL : GraphLapl n) (D : GraphDivisor n) (v : Fin n) : GraphDivisor n :=
  fun i => D i - grL.L v i

/-
Chip-firing preserves divisor class.
-/

theorem chip_fire_preserves_class (grL : GraphLapl n) (D : GraphDivisor n) (v : Fin n) :
    GraphLinEquiv grL D (chipFire grL D v) := by
  use fun i => if i = v then 1 else 0;
  simp +decide [ chipFire ];
  exact fun i => grL.symmetric.apply i v

/-- The graph genus: g = |E| - |V| + 1. -/

def graphGenus (numEdges numVertices : ℕ) : ℤ :=
  (numEdges : ℤ) - (numVertices : ℤ) + 1

/-- The degree of vertex i: deg(i) = -L(i,i). -/

def vertexDegree (grL : GraphLapl n) (i : Fin n) : ℤ := -grL.L i i

/-- The canonical divisor K(v) = deg(v) - 2. -/

def canonicalDivisor (grL : GraphLapl n) : GraphDivisor n :=
  fun i => vertexDegree grL i - 2

/-
For a graph with genus g, deg(K) = 2g - 2.
-/

theorem canonical_divisor_degree (grL : GraphLapl n) (numEdges : ℕ)
    (hn : n > 0)
    (hedge : ∑ i : Fin n, vertexDegree grL i = 2 * (numEdges : ℤ)) :
    divisorDeg (canonicalDivisor grL) = 2 * graphGenus numEdges n - 2 := by
  unfold divisorDeg canonicalDivisor graphGenus;
  simpa [ Finset.sum_sub_distrib, hedge ] using by ring;

/-- Analogies between number theory, algebraic geometry, and graph theory. -/

structure LanglandsAnalogy where
  numberTheory : String
  algebraicGeometry : String
  graphTheory : String


def jacobianAnalogy : LanglandsAnalogy :=
  { numberTheory := "Ideal class group Cl(K)"
    algebraicGeometry := "Jacobian variety Jac(C)"
    graphTheory := "Tropical Jacobian Jac(G)" }


end
