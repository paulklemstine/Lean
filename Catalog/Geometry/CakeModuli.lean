/-
# Cake Moduli: Combinatorial Framework for Stratified Surfaces

This file develops a rigorous combinatorial framework for "cakes" — stratified
surfaces characterized by genus, boundary count, marked points, and layer
decompositions. The central results connect surface topology (Euler characteristics)
to moduli theory (Teichmüller dimension formulas) and prove superadditivity of
moduli dimensions under handle gluing.

## Main results

* `Cake.euler_char_handle_glue` — Euler characteristic transforms as χ₁+χ₂-2 under handle gluing
* `Cake.moduli_superadditive` — Moduli dimension satisfies dim(C₁⊕C₂) = dim(C₁)+dim(C₂)+6
* `Cake.moduli_euler_relation` — dim = -3χ + 2n connects moduli to topology
* `Cake.hyperbolic_iff_moduli_pos` — Characterization of hyperbolic cakes
* `Cake.tropical_trivalent_moduli` — Tropical analogue of the dimension formula
-/
import Mathlib

/-- A `Cake` models a compact oriented surface with combinatorial stratification data.
  * `genus`: the genus of the underlying topological surface
  * `boundary`: the number of boundary components
  * `marked`: the number of interior marked points
  * `layers`: the number of stratification layers (≥ 1)

The key invariants are the Euler characteristic χ = 2 - 2g - b and the
moduli dimension dim = 6g - 6 + 2n + 3b, which measures the dimension
of the Teichmüller space parametrizing conformal structures. -/
structure Cake where
  genus : ℕ
  boundary : ℕ
  marked : ℕ
  layers : ℕ
  layers_pos : 0 < layers

namespace Cake

/-- The Euler characteristic of a cake: χ = 2 - 2g - b. -/
def eulerChar (C : Cake) : ℤ :=
  2 - 2 * (C.genus : ℤ) - C.boundary

/-- The moduli dimension (Teichmüller space dimension): 6g - 6 + 2n + 3b.
This counts the real dimension of the space of conformal structures on the surface,
incorporating both interior moduli and boundary parameters. -/
def moduliDim (C : Cake) : ℤ :=
  6 * (C.genus : ℤ) - 6 + 2 * C.marked + 3 * C.boundary

/-- The complexity of a cake: 2g + b + n.
This is an additive measure of topological complexity. -/
def complexity (C : Cake) : ℕ :=
  2 * C.genus + C.boundary + C.marked

/-- The geometric type of a surface, determined by the sign of the Euler characteristic. -/
inductive GeomType
  | spherical   -- χ > 0: sphere, disk, annulus
  | flat        -- χ = 0: torus, cylinder
  | hyperbolic  -- χ < 0: higher genus, many punctures

/-- Classify a cake by the sign of its Euler characteristic. -/
def geomType (C : Cake) : GeomType :=
  if C.eulerChar > 0 then GeomType.spherical
  else if C.eulerChar = 0 then GeomType.flat
  else GeomType.hyperbolic

/-- Handle gluing of two cakes: connect C₁ and C₂ by a handle (tube) consuming
one boundary component from each. This models the topological operation of
cutting open a boundary circle on each surface and connecting them with an
annular tube, which increases the genus by 1.

Topologically: g_new = g₁ + g₂ + 1, b_new = b₁ + b₂ - 2, n_new = n₁ + n₂. -/
def handleGlue (C₁ C₂ : Cake) (_h₁ : 0 < C₁.boundary) (_h₂ : 0 < C₂.boundary) : Cake where
  genus := C₁.genus + C₂.genus + 1
  boundary := C₁.boundary + C₂.boundary - 2
  marked := C₁.marked + C₂.marked
  layers := C₁.layers + C₂.layers
  layers_pos := Nat.add_pos_left C₁.layers_pos _

/-- Simple boundary identification gluing: identify one boundary component from
each cake without adding a handle. This is the operation used in pants decomposition.

Topologically: g_new = g₁ + g₂, b_new = b₁ + b₂ - 2, n_new = n₁ + n₂. -/
def boundaryGlue (C₁ C₂ : Cake) (_h₁ : 0 < C₁.boundary) (_h₂ : 0 < C₂.boundary) : Cake where
  genus := C₁.genus + C₂.genus
  boundary := C₁.boundary + C₂.boundary - 2
  marked := C₁.marked + C₂.marked
  layers := C₁.layers + C₂.layers
  layers_pos := Nat.add_pos_left C₁.layers_pos _

/-- A disk: the simplest cake with genus 0, one boundary component, no marked points. -/
def disk : Cake where
  genus := 0
  boundary := 1
  marked := 0
  layers := 1
  layers_pos := by omega

/-- A pair of pants: genus 0 with 3 boundary components. The fundamental
building block in the pants decomposition of surfaces. -/
def pants : Cake where
  genus := 0
  boundary := 3
  marked := 0
  layers := 1
  layers_pos := by omega

/-- A torus with one boundary component removed. -/
def puncturedTorus : Cake where
  genus := 1
  boundary := 1
  marked := 0
  layers := 1
  layers_pos := by omega

/-
============================================================
§ 1. Euler Characteristic and Moduli-Topology Bridge
============================================================

The moduli dimension and Euler characteristic are related by a linear formula:
    moduliDim = -3 · eulerChar + 2n. This connects topology to moduli theory
    and shows that moduli dimension is determined by Euler characteristic up to
    marked point corrections.
-/
theorem moduli_euler_relation (C : Cake) :
    C.moduliDim = -3 * C.eulerChar + 2 * (C.marked : ℤ) := by
  simp +decide [ Cake.moduliDim, Cake.eulerChar ] ; ring;

/-
Handle gluing transforms the Euler characteristic as χ(C₁⊕C₂) = χ(C₁) + χ(C₂) - 2.
The deficit of 2 comes from the added handle, which contributes -2 to χ via genus increase.
-/
theorem euler_char_handle_glue (C₁ C₂ : Cake) (h₁ : 0 < C₁.boundary) (h₂ : 0 < C₂.boundary) :
    (handleGlue C₁ C₂ h₁ h₂).eulerChar = C₁.eulerChar + C₂.eulerChar - 2 := by
  unfold Cake.eulerChar Cake.handleGlue;
  grind

/-
Boundary gluing preserves the Euler characteristic: χ(C₁∪C₂) = χ(C₁) + χ(C₂).
This follows from the Mayer-Vietoris sequence since the gluing circle has χ = 0.
-/
theorem euler_char_boundary_glue (C₁ C₂ : Cake) (h₁ : 0 < C₁.boundary) (h₂ : 0 < C₂.boundary) :
    (boundaryGlue C₁ C₂ h₁ h₂).eulerChar = C₁.eulerChar + C₂.eulerChar := by
  unfold Cake.eulerChar Cake.boundaryGlue;
  grind

/-
============================================================
§ 2. Superadditivity of Moduli Dimensions
============================================================

**Key theorem**: Handle gluing is superadditive for moduli dimension.
When two surfaces are connected by adding a handle, the resulting moduli dimension
exceeds the sum by exactly 6. This "bonus dimension" of 6 = dim(SL₂(ℝ)) represents
the 6 real parameters (3 for each boundary gluing) contributed by the new handle.

    dim(C₁ ⊕ C₂) = dim(C₁) + dim(C₂) + 6
-/
theorem moduli_superadditive (C₁ C₂ : Cake) (h₁ : 0 < C₁.boundary) (h₂ : 0 < C₂.boundary) :
    (handleGlue C₁ C₂ h₁ h₂).moduliDim = C₁.moduliDim + C₂.moduliDim + 6 := by
  unfold Cake.moduliDim;
  simp +arith +decide [ Cake.handleGlue ];
  omega

/-
Boundary gluing is additive for moduli dimension:
    dim(C₁ ∪ C₂) = dim(C₁) + dim(C₂).
Contrast with handle gluing which gains +6.
-/
theorem moduli_additive_boundary_glue (C₁ C₂ : Cake)
    (h₁ : 0 < C₁.boundary) (h₂ : 0 < C₂.boundary) :
    (boundaryGlue C₁ C₂ h₁ h₂).moduliDim = C₁.moduliDim + C₂.moduliDim := by
  unfold Cake.moduliDim;
  unfold Cake.boundaryGlue;
  grind

/-
The moduli dimension gap between handle gluing and boundary gluing is exactly 6,
regardless of the input surfaces. This is the "handle cost" in moduli theory.
-/
theorem moduli_handle_gap (C₁ C₂ : Cake) (h₁ : 0 < C₁.boundary) (h₂ : 0 < C₂.boundary) :
    (handleGlue C₁ C₂ h₁ h₂).moduliDim - (boundaryGlue C₁ C₂ h₁ h₂).moduliDim = 6 := by
  convert sub_eq_iff_eq_add'.mpr ( moduli_superadditive C₁ C₂ h₁ h₂ ) using 1;
  rw [ moduli_additive_boundary_glue ]

/-
============================================================
§ 3. Classification by Euler Characteristic
============================================================

A cake is hyperbolic if and only if its Euler characteristic is negative.
-/
theorem hyperbolic_iff_euler_neg (C : Cake) :
    C.geomType = GeomType.hyperbolic ↔ C.eulerChar < 0 := by
  unfold Cake.geomType;
  grind +ring

/-
For cakes with no marked points, hyperbolicity is equivalent to positive moduli dimension.
This connects the topological classification to the algebro-geometric structure of the
moduli space: M_{g,b} is nonempty iff χ < 0 iff dim > 0.
-/
theorem hyperbolic_iff_moduli_pos (C : Cake) (hn : C.marked = 0) :
    C.geomType = GeomType.hyperbolic ↔ 0 < C.moduliDim := by
  grind +locals

/-
The disk has spherical type.
-/
theorem disk_spherical : disk.geomType = GeomType.spherical := by
  grind +locals

/-
Pants have hyperbolic type (χ = -1 < 0).
-/
theorem pants_hyperbolic : pants.geomType = GeomType.hyperbolic := by
  exact if_neg ( by decide ) |> fun h => h.trans ( if_neg ( by decide ) )

/-
============================================================
§ 4. Monotonicity Under Morphisms
============================================================

Moduli dimension is monotone: if genus, boundary, and marked points
all increase, so does the moduli dimension. This is the key monotonicity
property that makes moduli dimension a valid complexity measure on the
category of cakes.
-/
theorem moduli_monotone_of_le (C₁ C₂ : Cake)
    (hg : C₁.genus ≤ C₂.genus)
    (hb : C₁.boundary ≤ C₂.boundary)
    (hn : C₁.marked ≤ C₂.marked) :
    C₁.moduliDim ≤ C₂.moduliDim := by
  exact Int.le_of_lt_add_one ( by rw [ show C₁.moduliDim = 6 * ( C₁.genus : ℤ ) - 6 + 2 * C₁.marked + 3 * C₁.boundary by rfl ] ; rw [ show C₂.moduliDim = 6 * ( C₂.genus : ℤ ) - 6 + 2 * C₂.marked + 3 * C₂.boundary by rfl ] ; omega )

-- ============================================================
-- § 5. Tropical Cake Combinatorics
-- ============================================================

/-- A tropical cake replaces conformal structure with metric graph data.
The `edge_count` replaces genus (via first Betti number), `leaves` replace
boundary components, and `interior_vertices` replace marked points. -/
structure TropicalCake where
  edge_count : ℕ
  leaves : ℕ
  interior_vertices : ℕ
  depth : ℕ

/-- The first Betti number of a tropical cake, analogous to genus.
    β₁ = e - v + 1 where v = leaves + interior_vertices is the total vertex count. -/
def TropicalCake.betti (T : TropicalCake) : ℤ :=
  (T.edge_count : ℤ) - (T.leaves : ℤ) - (T.interior_vertices : ℤ) + 1

/-- The tropical moduli dimension: the number of internal edges = e - leaves. -/
def TropicalCake.tropModuliDim (T : TropicalCake) : ℤ :=
  (T.edge_count : ℤ) - T.leaves

/-
**Tropical-classical correspondence**: For a trivalent tropical cake (where all
interior vertices have valence 3), the tropical moduli dimension equals
3β₁ - 3 + n (where n = leaves). This is the tropical analogue of the classical
formula dim M_{g,n} = 3g - 3 + n.

The proof uses the handshaking lemma for trivalent graphs:
  2e = 3·v_int + leaves (half-edge counting at interior vs leaf vertices)
combined with β₁ = e - v_int - leaves + 1. Solving:
  e - leaves = (3·v_int + leaves)/2 - leaves = (3·v_int - leaves)/2
  3β₁ - 3 + leaves = 3(e - v_int - leaves + 1) - 3 + leaves
                    = 3e - 3v_int - 3leaves + 3 - 3 + leaves
                    = 3e - 3v_int - 2leaves
With 2e = 3v_int + leaves → 3e = (9v_int + 3leaves)/2:
  = (9v_int + 3leaves)/2 - 3v_int - 2leaves
  = (9v_int + 3leaves - 6v_int - 4leaves)/2
  = (3v_int - leaves)/2 = e - leaves ✓
-/
theorem tropical_trivalent_moduli
    (T : TropicalCake)
    (h_trivalent : 2 * T.edge_count = 3 * T.interior_vertices + T.leaves) :
    T.tropModuliDim = 3 * T.betti - 3 + T.leaves := by
  unfold TropicalCake.tropModuliDim TropicalCake.betti; linarith;

/-
Handle gluing always makes the result hyperbolic (for unmarked surfaces with boundary).
If C₁ and C₂ each have at least one boundary component, then gluing them with a handle
produces a surface with χ ≤ χ(C₁) + χ(C₂) - 2 < 0, which is necessarily hyperbolic
whenever the summands aren't too positive. In particular, if at least one has non-positive
Euler characteristic, the result is hyperbolic.
-/
theorem handle_glue_hyperbolic (C₁ C₂ : Cake)
    (h₁ : 0 < C₁.boundary) (h₂ : 0 < C₂.boundary)
    (hχ : C₁.eulerChar + C₂.eulerChar < 2) :
    (handleGlue C₁ C₂ h₁ h₂).geomType = GeomType.hyperbolic := by
  convert hyperbolic_iff_euler_neg _ |>.2 _;
  rw [ euler_char_handle_glue ] ; omega

end Cake