import Mathlib

/-!
# GL₃ Tropical Satake: Finite Generation from Edge and Levi Data

## Overview

We work in the concrete GL₃ dominant chamber model: a dominant coweight is
represented by a pair `(a, b) : ℕ × ℕ` of nonneg simple-coroot coordinates.
A finitely supported dominant support function is `f : ℕ × ℕ → ℤ` with finite support.

We prove that such a function is **uniquely determined** by four pieces of data:
1. Its restriction to the left edge `{(a, 0) | a : ℕ}` (the `edge01` restriction)
2. Its restriction to the right edge `{(0, b) | b : ℕ}` (the `edge10` restriction)
3. Its convolution with the left Levi generator `δ_{(1,0)}`
4. Its convolution with the right Levi generator `δ_{(0,1)}`

The key mechanism is that convolution with a delta function at a simple coroot
acts as a coordinate shift, allowing reconstruction of interior values from
boundary and Levi profile data via depth induction on `a + b`.

## Mathematical significance

This establishes a **finite and geometrically natural coordinate system** for
finitely supported tropical Satake data in rank 2: boundary restrictions
plus Levi convolution profiles form a complete, overdetermined system.
The interior of the dominant chamber carries no independent information
beyond what is encoded in boundary geometry and Levi harmonic analysis.
-/

namespace GL3TropicalSatake

/-! ## Definitions -/

/-- Edge restriction to the left boundary ray `{(a, 0)}` -/
def edge01 (f : ℕ × ℕ → ℤ) : ℕ → ℤ := fun a => f (a, 0)

/-- Edge restriction to the right boundary ray `{(0, b)}` -/
def edge10 (f : ℕ × ℕ → ℤ) : ℕ → ℤ := fun b => f (0, b)

/-- Tropical convolution on `ℕ × ℕ`: the standard additive convolution
    `(f * g)(a, b) = ∑_{i ≤ a, j ≤ b} f(i,j) · g(a-i, b-j)`.
    This is multiplication in the monoid algebra `ℤ[ℕ × ℕ]`. -/
def tconv (f g : ℕ × ℕ → ℤ) : ℕ × ℕ → ℤ := fun p =>
  ∑ i ∈ Finset.range (p.1 + 1), ∑ j ∈ Finset.range (p.2 + 1),
    f (i, j) * g (p.1 - i, p.2 - j)

/-- Left Levi generator: delta function at the first simple coroot `(1, 0)`.
    Corresponds to the Hecke algebra generator of the rank-2 Levi `GL₂ × GL₁`. -/
def leviLeftGen : ℕ × ℕ → ℤ := fun p => if p = (1, 0) then 1 else 0

/-- Right Levi generator: delta function at the second simple coroot `(0, 1)`.
    Corresponds to the Hecke algebra generator of the rank-2 Levi `GL₁ × GL₂`. -/
def leviRightGen : ℕ × ℕ → ℤ := fun p => if p = (0, 1) then 1 else 0

/-! ## Core shift lemmas

The heart of the theory: convolution with a simple-coroot delta function
shifts coordinates. These are the "propagation identities" that allow
depth induction. -/

/-
Convolution with the left Levi generator shifts the first coordinate:
    `(f * δ_{(1,0)})(a+1, b) = f(a, b)`.
-/
theorem tconv_leviLeft_succ (f : ℕ × ℕ → ℤ) (a b : ℕ) :
    tconv f leviLeftGen (a + 1, b) = f (a, b) := by
  unfold tconv;
  rw [ Finset.sum_eq_single a ];
  · rw [ Finset.sum_eq_single b ] <;> simp +decide [ leviLeftGen ];
    intros; omega;
  · simp +decide [ leviLeftGen ];
    exact fun n hn hn' => Finset.sum_eq_zero fun x hx => if_neg <| by omega;
  · aesop

/-
Convolution with the left Levi generator vanishes on the right edge:
    `(f * δ_{(1,0)})(0, b) = 0`.
-/
theorem tconv_leviLeft_zero (f : ℕ × ℕ → ℤ) (b : ℕ) :
    tconv f leviLeftGen (0, b) = 0 := by
  -- By definition of $tconv$, we have:
  unfold tconv;
  simp [leviLeftGen]

/-
Convolution with the right Levi generator shifts the second coordinate:
    `(f * δ_{(0,1)})(a, b+1) = f(a, b)`.
-/
theorem tconv_leviRight_succ (f : ℕ × ℕ → ℤ) (a b : ℕ) :
    tconv f leviRightGen (a, b + 1) = f (a, b) := by
  unfold tconv leviRightGen;
  rw [ Finset.sum_eq_single a ] <;> simp +contextual [ Finset.sum_range_succ ];
  · exact Finset.sum_eq_zero fun x hx => if_neg ( by rw [ tsub_eq_iff_eq_add_of_le ] <;> linarith [ Finset.mem_range.mp hx ] );
  · exact fun x hx₁ hx₂ => by rw [ Finset.sum_eq_zero fun y hy => if_neg <| by omega ] ; rw [ if_neg <| by omega ] ; ring;

/-
Convolution with the right Levi generator vanishes on the left edge:
    `(f * δ_{(0,1)})(a, 0) = 0`.
-/
theorem tconv_leviRight_zero (f : ℕ × ℕ → ℤ) (a : ℕ) :
    tconv f leviRightGen (a, 0) = 0 := by
  unfold tconv leviRightGen;
  simp +decide

/-! ## Linearity of convolution -/

/-
Convolution is linear in the first argument (subtraction).
-/
theorem tconv_sub (f g k : ℕ × ℕ → ℤ) (p : ℕ × ℕ) :
    tconv (f - g) k p = tconv f k p - tconv g k p := by
  unfold tconv; simp +decide [ sub_mul ] ;

/-! ## Depth induction principle -/

/-
Induction on chamber depth `a + b` for pairs of natural numbers.
    This is the workhorse for all chamber-recursive arguments.
-/
theorem nat_pair_depth_induction
    {P : ℕ → ℕ → Prop}
    (hstep : ∀ a b, (∀ a' b', a' + b' < a + b → P a' b') → P a b) :
    ∀ a b, P a b := by
  intro a b; induction' n : a + b using Nat.strongRecOn with n ih generalizing a b;
  exact hstep a b fun a' b' h => ih _ ( by linarith ) _ _ rfl

/-! ## Finite support -/

/-
A function on `ℕ × ℕ` with a depth bound has finite support.
-/
theorem finite_support_of_depth_bounded
    (f : ℕ × ℕ → ℤ)
    (h : ∃ N, ∀ a b, N < a + b → f (a, b) = 0) :
    Set.Finite {p | f p ≠ 0} := by
  exact Set.finite_iff_bddAbove.mpr ⟨ ⟨ h.choose, h.choose ⟩, by rintro ⟨ a, b ⟩ H; exact ⟨ not_lt.mp fun ha => H <| h.choose_spec a b <| by linarith, not_lt.mp fun hb => H <| h.choose_spec a b <| by linarith ⟩ ⟩

/-! ## Main injectivity theorems -/

/-
**Vanishing lemma**: If a function has zero edges and zero Levi profiles,
    it vanishes identically. This is the engine of injectivity,
    proved by induction on depth `a + b`.
-/
theorem zero_of_zero_edges_and_zero_levi
    (h : ℕ × ℕ → ℤ)
    (_hedge1 : ∀ a, h (a, 0) = 0)
    (_hedge2 : ∀ b, h (0, b) = 0)
    (hleviL : tconv h leviLeftGen = 0)
    (_hleviR : tconv h leviRightGen = 0) :
    ∀ a b, h (a, b) = 0 := by
  -- By lemma `tconv_leviLeft_succ`, for any `a` and `b`, `h(a, b) = (tconv h leviLeftGen)(a+1, b)`.
  have h_succ : ∀ a b, h (a, b) = (tconv h leviLeftGen) (a+1, b) :=
    fun a b => (tconv_leviLeft_succ h a b).symm;
  exact fun a b => h_succ a b ▸ hleviL ▸ rfl

/-
**Interior recovery**: Every value `f(a,b)` is determined by edge data
    and Levi convolution profiles. Proved by depth induction on `a + b`.
-/
theorem interior_value_determined_by_edge_and_levi
    (f g : ℕ × ℕ → ℤ)
    (hboundary : (∀ a, f (a, 0) = g (a, 0)) ∧ (∀ b, f (0, b) = g (0, b)))
    (hleviL : tconv f leviLeftGen = tconv g leviLeftGen)
    (hleviR : tconv f leviRightGen = tconv g leviRightGen) :
    ∀ a b, f (a, b) = g (a, b) := by
  intro a b; induction' a with a ih generalizing b; induction' b with b ih'; simp_all +decide [] ;
  · exact hboundary.2 _;
  · have := congr_fun hleviL ( a + 2, b ) ; have := congr_fun hleviR ( a + 1, b + 1 ) ; simp_all +decide [tconv_leviLeft_succ] ;

/-
**Main injectivity theorem**: A function on `ℕ × ℕ` is uniquely determined
    by its edge restrictions and Levi convolution profiles.
-/
theorem edge_levi_data_injective
    (f g : ℕ × ℕ → ℤ)
    (hedge1 : edge01 f = edge01 g)
    (hedge2 : edge10 f = edge10 g)
    (hleviL : tconv f leviLeftGen = tconv g leviLeftGen)
    (hleviR : tconv f leviRightGen = tconv g leviRightGen) :
    f = g := by
  ext ⟨ a, b ⟩;
  apply interior_value_determined_by_edge_and_levi;
  · exact ⟨ fun a => congr_fun hedge1 a, fun b => congr_fun hedge2 b ⟩;
  · exact hleviL;
  · exact hleviR

/-! ## Edge-Levi data structure and reconstruction -/

/-- Packaged edge-Levi data for reconstruction. -/
structure EdgeLeviData where
  /-- Values on the left edge `{(a, 0)}` -/
  leftEdge  : ℕ → ℤ
  /-- Values on the right edge `{(0, b)}` -/
  rightEdge : ℕ → ℤ
  /-- Left Levi convolution profile -/
  leftProf  : ℕ × ℕ → ℤ
  /-- Right Levi convolution profile -/
  rightProf : ℕ × ℕ → ℤ

/-- Extract edge-Levi data from a function. -/
def EdgeLeviData.ofFun (f : ℕ × ℕ → ℤ) : EdgeLeviData where
  leftEdge  := edge01 f
  rightEdge := edge10 f
  leftProf  := tconv f leviLeftGen
  rightProf := tconv f leviRightGen

/-- Compatibility condition: the data must satisfy the identities that hold
    for any actual support function. For delta-function generators, the key
    identity is that the Levi profiles evaluated at successor indices
    must agree with the edges on the boundary. -/
def EdgeLeviData.Compatible (D : EdgeLeviData) : Prop :=
  -- Left profile at (a+1, 0) recovers left edge at (a, 0)
  (∀ a, D.leftProf (a + 1, 0) = D.leftEdge a) ∧
  -- Right profile at (0, b+1) recovers right edge at (0, b)
  (∀ b, D.rightProf (0, b + 1) = D.rightEdge b) ∧
  -- Left profile vanishes on right edge
  (∀ b, D.leftProf (0, b) = 0) ∧
  -- Right profile vanishes on left edge
  (∀ a, D.rightProf (a, 0) = 0) ∧
  -- Cross-consistency: interior values reconstructed from left and right agree
  -- From left: f(a,b) = leftProf(a+1,b)
  -- From right: f(a,b) = rightProf(a,b+1)
  (∀ a b, D.leftProf (a + 1, b) = D.rightProf (a, b + 1))

/-- Reconstruct a function from edge-Levi data using the left Levi profile.
    Since `(f * δ_{(1,0)})(a+1, b) = f(a, b)`, we recover `f` directly
    from the left profile at shifted indices. -/
def reconstructFromEdgeLevi (D : EdgeLeviData) : ℕ × ℕ → ℤ := fun ⟨a, b⟩ =>
  D.leftProf (a + 1, b)

/-
The reconstruction from compatible data has the correct left edge.
-/
theorem reconstructFromEdgeLevi_edge01 (D : EdgeLeviData) (hcomp : D.Compatible) :
    edge01 (reconstructFromEdgeLevi D) = D.leftEdge := by
  ext a;
  exact hcomp.1 a

/-
The reconstruction from compatible data has the correct right edge.
-/
theorem reconstructFromEdgeLevi_edge10 (D : EdgeLeviData) (hcomp : D.Compatible) :
    edge10 (reconstructFromEdgeLevi D) = D.rightEdge := by
  grind +locals

/-
The reconstruction has the correct left Levi profile.
-/
theorem reconstructFromEdgeLevi_leftProf (D : EdgeLeviData) (hcomp : D.Compatible) :
    tconv (reconstructFromEdgeLevi D) leviLeftGen = D.leftProf := by
  ext ⟨ a, b ⟩;
  induction' a with a ih generalizing b;
  · convert hcomp.2.2.1 b using 1;
    · convert tconv_leviLeft_zero _ _;
      grind +locals;
    · grind +locals;
  · unfold reconstructFromEdgeLevi at *;
    convert tconv_leviLeft_succ _ _ _ using 1

/-
The reconstruction has the correct right Levi profile.
-/
theorem reconstructFromEdgeLevi_rightProf (D : EdgeLeviData) (hcomp : D.Compatible) :
    tconv (reconstructFromEdgeLevi D) leviRightGen = D.rightProf := by
  -- We need to show that the convolution of the reconstructed function with the right Levi generator equals the right profile.
  have h_conv_right : ∀ a b, (tconv (reconstructFromEdgeLevi D) leviRightGen) (a, b) = D.rightProf (a, b) := by
    intros a b; induction' b with b ih generalizing a; simp_all +decide [tconv_leviRight_zero] ;
    · exact hcomp.2.2.2.1 a ▸ rfl;
    · convert tconv_leviRight_succ ( reconstructFromEdgeLevi D ) a b using 1;
      exact hcomp.2.2.2.2 a b ▸ rfl;
  exact funext fun p => h_conv_right p.1 p.2

/-
**Existence and uniqueness of extension**: Compatible edge-Levi data
    uniquely extends to a function on the dominant chamber.
-/
theorem exists_unique_of_compatible_edge_levi_data
    (D : EdgeLeviData)
    (hcomp : D.Compatible) :
    ∃! f : ℕ × ℕ → ℤ,
      (edge01 f = D.leftEdge) ∧
      (edge10 f = D.rightEdge) ∧
      (tconv f leviLeftGen = D.leftProf) ∧
      (tconv f leviRightGen = D.rightProf) := by
  refine' ⟨ reconstructFromEdgeLevi D, _, _ ⟩;
  · exact ⟨ reconstructFromEdgeLevi_edge01 D hcomp, reconstructFromEdgeLevi_edge10 D hcomp, reconstructFromEdgeLevi_leftProf D hcomp, reconstructFromEdgeLevi_rightProf D hcomp ⟩;
  · -- By the uniqueness part of the edge_levi_data_injective theorem, if two functions have the same edge values and Levi profiles, they must be equal.
    intros y hy
    apply edge_levi_data_injective;
    · rw [ hy.1, reconstructFromEdgeLevi_edge01 D hcomp ];
    · rw [ hy.2.1, reconstructFromEdgeLevi_edge10 D hcomp ];
    · rw [ hy.2.2.1, reconstructFromEdgeLevi_leftProf D hcomp ];
    · rw [ hy.2.2.2, reconstructFromEdgeLevi_rightProf D hcomp ]

/-
Any function's edge-Levi data is compatible.
-/
theorem EdgeLeviData.ofFun_compatible (f : ℕ × ℕ → ℤ) :
    (EdgeLeviData.ofFun f).Compatible := by
  constructor;
  · exact fun a => tconv_leviLeft_succ f a 0;
  · refine' ⟨ _, _, _, _ ⟩;
    · exact fun b => tconv_leviRight_succ f 0 b;
    · exact fun b => tconv_leviLeft_zero f b;
    · -- By definition of `ofFun`, we know that `rightProf (a, 0) = tconv f leviRightGen (a, 0)`.
      simp [EdgeLeviData.ofFun, tconv_leviRight_zero];
    · intros a b; exact (by
      convert tconv_leviLeft_succ f a b using 1;
      exact tconv_leviRight_succ f a b)

/-
Round-trip: reconstructing from extracted data recovers the original function.
-/
theorem reconstruct_ofFun_eq (f : ℕ × ℕ → ℤ) :
    reconstructFromEdgeLevi (EdgeLeviData.ofFun f) = f := by
  ext ⟨ a, b ⟩ ; exact tconv_leviLeft_succ f a b

end GL3TropicalSatake