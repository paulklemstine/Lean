import Mathlib

/-!
# A rigorous finite-orbit shadow of the tropical–F₁/toric correspondence

The proposed equivalence of whole categories is not a settled theorem without first choosing
specific definitions of tropical and F₁-schemes.  This file isolates a precise theorem behind
its most robust numerical prediction.  A finite toric orbit decomposition is represented by
its finite set of cones, with orbit dimension `ambientDim - coneDim`.  An additive Euler
measure assigns value zero to every positive-dimensional torus and one to a point.  Hence its
total is exactly the number of full-dimensional cones, i.e. torus fixed points.  If vertices of
a polytope are identified with those cones, this is the claimed F₁-point count.
-/

namespace TropicalFOne

/-- Extended real numbers with tropical addition (`min`) and multiplication (`+`). -/
abbrev Trop := Tropical (WithTop ℝ)

/-- The underlying value of a tropical element. -/
def value (x : Trop) : WithTop ℝ := Tropical.untrop x

/-
Tropical addition really is minimum.
-/
theorem value_add (x y : Trop) : value (x + y) = min (value x) (value y) := by
  convert rfl

/-
Tropical multiplication really is ordinary addition (including `∞`).
-/
theorem value_mul (x y : Trop) : value (x * y) = value x + value y := by
  rfl

/-
Translation distributes over tropical addition: the elementary min-plus law.
-/
theorem tropical_translate_min (a x y : WithTop ℝ) :
    a + min x y = min (a + x) (a + y) := by
  cases a <;> cases x <;> cases y <;> norm_cast;
  rw [ min_def, min_def ] ; split_ifs <;> linarith

/-- Finite combinatorial data of a complete toric orbit decomposition. -/
structure ToricOrbitData where
  ambientDim : ℕ
  cone : Type
  finiteCone : Fintype cone
  coneDim : cone → ℕ
  coneDim_le : ∀ c, coneDim c ≤ ambientDim

attribute [instance] ToricOrbitData.finiteCone

namespace ToricOrbitData

variable (D : ToricOrbitData)

/-- Dimension of the torus orbit corresponding to a cone. -/
def orbitDim (c : D.cone) : ℕ := D.ambientDim - D.coneDim c

/-- Full-dimensional cones, equivalently zero-dimensional torus orbits. -/
def fixedCones : Finset D.cone := Finset.univ.filter fun c => D.coneDim c = D.ambientDim

/-- The compactly supported Euler value of `(Gₘ)^d`: one for a point and zero otherwise. -/
def torusEuler (d : ℕ) : ℤ := if d = 0 then 1 else 0

/-- Euler characteristic obtained additively from the finite orbit decomposition. -/
def euler : ℤ := ∑ c : D.cone, torusEuler (D.orbitDim c)

/-
A cone gives a fixed point exactly when its corresponding orbit has dimension zero.
-/
theorem orbitDim_eq_zero_iff (c : D.cone) :
    D.orbitDim c = 0 ↔ D.coneDim c = D.ambientDim := by
  -- Unfold orbitDim. Nat.sub_eq_iff_eq_add says ambient-coneDim=0 iff ambient=coneDim.
  simp [orbitDim];
  exact ⟨ fun h => by linarith [ Nat.sub_add_cancel ( D.coneDim_le c ) ], fun h => by rw [ h, Nat.sub_self ] ⟩

/-
**Toric fixed-point formula.** The additive Euler characteristic of a finite toric orbit
stratification is the number of torus fixed points.
-/
theorem euler_eq_card_fixedCones : D.euler = (D.fixedCones.card : ℤ) := by
  unfold ToricOrbitData.euler ToricOrbitData.fixedCones;
  simp +decide [torusEuler];
  exact congr_arg Finset.card ( Finset.ext fun x => by simp +decide [ orbitDim_eq_zero_iff ] )

/-
Euler values of torus factors multiply under products.
-/
theorem torusEuler_add (m n : ℕ) :
    torusEuler (m + n) = torusEuler m * torusEuler n := by
  unfold torusEuler; aesop;

/-- Product orbit data: cones and orbit dimensions combine componentwise. -/
def product (E : ToricOrbitData) : ToricOrbitData where
  ambientDim := D.ambientDim + E.ambientDim
  cone := D.cone × E.cone
  finiteCone := inferInstance
  coneDim := fun c => D.coneDim c.1 + E.coneDim c.2
  coneDim_le := fun c => Nat.add_le_add (D.coneDim_le c.1) (E.coneDim_le c.2)

/-
Euler point counts are multiplicative for products of finite toric orbit models.
-/
theorem euler_product (E : ToricOrbitData) :
    (D.product E).euler = D.euler * E.euler := by
  unfold ToricOrbitData.euler;
  rw [ Finset.sum_mul _ _ _ ];
  simp +decide only [Finset.mul_sum _ _ _];
  rw [ ← Finset.sum_product' ];
  refine' Finset.sum_congr rfl fun x hx => _;
  convert torusEuler_add _ _ using 2;
  unfold ToricOrbitData.orbitDim; simp +decide [ ToricOrbitData.product ] ;
  rw [ tsub_add_tsub_comm ] <;> linarith [ D.coneDim_le x.1, E.coneDim_le x.2 ]

end ToricOrbitData

/-- Data expressing the polytope/fan dictionary at the level needed for point counting. -/
structure PolytopeToricCorrespondence where
  vertices : Type
  finiteVertices : Fintype vertices
  toric : ToricOrbitData
  vertexToFixedCone : vertices ≃ {c // c ∈ toric.fixedCones}

attribute [instance] PolytopeToricCorrespondence.finiteVertices

namespace PolytopeToricCorrespondence

variable (P : PolytopeToricCorrespondence)

/-- The F₁-points in this finite combinatorial model are the vertices. -/
def fOnePointCount : ℕ := Fintype.card P.vertices

/-
The central test proposed in the prompt: Euler characteristic after toric realization equals
the number of vertices, hence the number of F₁-points.
-/
theorem euler_eq_fOnePointCount :
    P.toric.euler = (P.fOnePointCount : ℤ) := by
  convert P.toric.euler_eq_card_fixedCones;
  convert Fintype.card_congr P.vertexToFixedCone;
  rw [ Fintype.card_coe ]

end PolytopeToricCorrespondence

/-- The fixed-orbit sector of projective `n`-space's standard-simplex fan.  Since the Euler
sum receives zero from every positive-dimensional orbit, this compressed model retains exactly
the `n+1` maximal cones and loses no Euler information. -/
def projectiveSimplexOrbitData (n : ℕ) : ToricOrbitData where
  ambientDim := n
  cone := Fin (n + 1)
  finiteCone := inferInstance
  coneDim := fun _ => n
  coneDim_le := by simp

/-
The fixed-point/Euler count for projective `n`-space is `n+1`.
-/
theorem projectiveSimplex_euler (n : ℕ) :
    (projectiveSimplexOrbitData n).euler = (n + 1 : ℕ) := by
  convert ( projectiveSimplexOrbitData n ).euler_eq_card_fixedCones using 1 ; norm_cast;
  convert ( Fintype.card_fin ( n + 1 ) ) |> Eq.symm using 2 ; unfold projectiveSimplexOrbitData ToricOrbitData.fixedCones ; aesop;

/-- The standard simplex realizes its vertices as the fixed cones of projective space. -/
def projectiveSimplexCorrespondence (n : ℕ) : PolytopeToricCorrespondence where
  vertices := Fin (n + 1)
  finiteVertices := inferInstance
  toric := projectiveSimplexOrbitData n
  vertexToFixedCone := by
    exact (Equiv.subtypeUnivEquiv (fun c => by
      simp [ToricOrbitData.fixedCones, projectiveSimplexOrbitData])).symm

/-- The formal F₁-point count of the standard `n`-simplex is `n+1`. -/
theorem projectiveSimplex_fOnePointCount (n : ℕ) :
    (projectiveSimplexCorrespondence n).fOnePointCount = n + 1 := by
  simp [projectiveSimplexCorrespondence, PolytopeToricCorrespondence.fOnePointCount]

/-- A family of nontrivial finite tests: the product model for projective `m`-space and
projective `n`-space has Euler/F₁-point count `(m+1)(n+1)`. -/
theorem projectiveProduct_euler (m n : ℕ) :
    ((projectiveSimplexOrbitData m).product (projectiveSimplexOrbitData n)).euler =
      ((m + 1) * (n + 1) : ℕ) := by
  rw [ToricOrbitData.euler_product, projectiveSimplex_euler, projectiveSimplex_euler]
  norm_cast

end TropicalFOne