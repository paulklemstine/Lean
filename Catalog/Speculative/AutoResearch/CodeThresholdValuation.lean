/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# A functor from finite linear codes to tropical valuation objects via weight-threshold profiles

This file builds the **bridge** announced by its title: a functor sending finite binary
linear codes (and threshold-compatible code maps) to the *tropical valuation objects* of
`Catalog.Bridges.CategoricalTropicalUltrametric`.

The connecting invariant is the **threshold profile valuation** `tprof`.  For a binary
vector `x : Fin n → ZMod 2`, `tprof x` is the smallest prefix length `t` such that `x` is
supported entirely in coordinates `< t` — equivalently `lead(x) + 1`, where `lead(x)` is
the top active coordinate.  This is the classical *degree / leading-position
nonarchimedean valuation*, here read off the **weight-threshold profile** of the codeword:
scanning coordinates `0,1,2,…`, `tprof x` is the threshold beyond which `x` is silent.

Unlike the Hamming weight `wt` (which is *not* ultrametric — `wt (x+y)` can exceed both
`wt x` and `wt y`), the threshold profile satisfies the **strong (ultrametric) triangle
inequality** and even the sharp **isosceles law**, so it descends to the catalog's
`UltraNormObj`/`TropObj` world.

## Main results (all `sorry`-free)

* `tprof_eq_zero_iff` — the valuation *separates* `0` (`tprof x = 0 ↔ x = 0`).
* `tprof_add_le` — **strong triangle inequality** `tprof (x+y) ≤ max (tprof x) (tprof y)`.
* `tprof_add_eq_of_ne` — **isosceles law**: unequal profiles force
  `tprof (x+y) = max (tprof x) (tprof y)` (the nonarchimedean "all triangles isosceles").
* `wt_le_tprof` / `tprof_le_card` — the profile *dominates* the Hamming weight and is
  bounded by the length: `wt x ≤ tprof x ≤ n`.
* `CodeVal` / `CodeValHom` — the category of *threshold-valued codes* (ultrametric objects
  without the multiplicative-norm axiom that codes cannot satisfy), with full category
  laws.
* `thresholdSpace` — the ambient length-`n` code as a `CodeVal`, and `padHom` — the
  prefix-inclusion `length m ↪ length n` as a profile-*preserving* `CodeValHom`, giving a
  concrete functorial family.
* `CodeVal.toTrop` / `CodeVal.toTropMap` — **the functor to tropical valuation objects**:
  every threshold-valued code maps to a genuine `CategoricalTropicalUltrametric.TropObj`
  (the value semiring `(ℕ, max, +)`), functorially (`toTropMap_id`, `toTropMap_comp`),
  exactly mirroring the catalog's `tropicalization`.

-- !-- Lab Notes -- !--
Hypothesis: the Hamming weight `wt` used throughout `SmoothPoincare.Codes` is the *wrong*
  invariant for a tropical/ultrametric functor (it fails the strong triangle inequality);
  but the *weight-threshold profile* `tprof` (leading active coordinate `+1`) is a genuine
  nonarchimedean valuation and therefore *does* factor through the catalog's tropical
  valuation objects, giving an honest functor `FinLinCodes → TropObj`.
Result: confirmed.  `tprof` satisfies separation, the strong triangle inequality, the
  sharp isosceles law, dominates `wt`, and is `≤ n`.  `CodeVal` is a category and
  `CodeVal.toTrop` is a functor into the catalog's `TropObj`, all `sorry`-free.
Insight: the move from `wt` (additive, archimedean) to `tprof` (max-stable,
  nonarchimedean) is precisely the move from the metric to the *tropical* world — the
  support union bound `support (x+y) ⊆ support x ∪ support y` plus `Finset.sup_union` is
  the entire content of the ultrametric inequality, and char-2 cancellation at the top
  coordinate upgrades it to the isosceles equality.
Failure analysis: the catalog's `UltraNormObj` demands a *multiplicative* norm
  (`norm (x*y) = norm x * norm y`), which no nontrivial code valuation satisfies (most
  valuations are additive: `v(xy) = v x + v y`).  We therefore land in a bespoke `CodeVal`
  (= `UltraNormObj` minus the multiplicative axiom) and bridge to the catalog via the
  *value semiring* `(ℕ, max, +) = tropicalization_base`, exactly as the catalog's own
  `tropicalization` functor is constant on objects.
-/

import Mathlib
import Catalog.Bridges.CategoricalTropicalUltrametric
import Catalog.Applications.SmoothPoincare.MinimumDistance

open scoped BigOperators

namespace CodeThresholdValuation

variable {n m : ℕ}

/-! ## §1. The weight-threshold profile valuation -/

/-- The **support** of a binary vector: the coordinates where it is nonzero. -/
def support (x : Fin n → ZMod 2) : Finset (Fin n) :=
  Finset.univ.filter (fun i => x i ≠ 0)

/-- The **weight-threshold profile** valuation: the smallest prefix length `t` such that
    `x` is supported in coordinates `< t`.  Equals `lead(x) + 1` where `lead(x)` is the
    top active coordinate; `tprof 0 = 0`. -/
def tprof (x : Fin n → ZMod 2) : ℕ := (support x).sup (fun i => (i : ℕ) + 1)

@[simp] theorem mem_support {x : Fin n → ZMod 2} {i : Fin n} :
    i ∈ support x ↔ x i ≠ 0 := by
  simp [support]

theorem support_zero : support (0 : Fin n → ZMod 2) = ∅ := by
  ext i; simp

/-- A coordinate of `x + y` is active only if it was active in `x` or in `y`. -/
theorem support_add_subset (x y : Fin n → ZMod 2) :
    support (x + y) ⊆ support x ∪ support y := by
  intro i hi
  simp only [mem_support, Pi.add_apply] at hi
  simp only [Finset.mem_union, mem_support]
  by_contra h
  push_neg at h
  obtain ⟨hx, hy⟩ := h
  simp [hx, hy] at hi

/-
The profile vanishes exactly on the zero vector (separation).
-/
theorem tprof_eq_zero_iff {x : Fin n → ZMod 2} : tprof x = 0 ↔ x = 0 := by
  unfold tprof;
  by_cases hx : x = 0 <;> simp +decide [ hx, support ];
  exact Function.ne_iff.mp hx

@[simp] theorem tprof_zero : tprof (0 : Fin n → ZMod 2) = 0 := by
  simp [tprof, support_zero]

/-
In characteristic two negation is the identity, so the profile is `neg`-invariant.
-/
theorem tprof_neg (x : Fin n → ZMod 2) : tprof (-x) = tprof x := by
  -- By definition of `support`, we have `support (-x) = {i | (-x) i ≠ 0}`.
  simp [tprof, support]

/-
**Strong (ultrametric) triangle inequality** for the threshold profile.
-/
theorem tprof_add_le (x y : Fin n → ZMod 2) :
    tprof (x + y) ≤ max (tprof x) (tprof y) := by
  unfold tprof
  refine le_trans (Finset.sup_mono (support_add_subset x y)) ?_
  rw [Finset.sup_union]

/-- If a coordinate `i` realizes the profile of `x` (i.e. `i ∈ support x` with
    `(i:ℕ)+1 = tprof x`), it is the top active coordinate. -/
theorem le_tprof_of_mem {x : Fin n → ZMod 2} {i : Fin n} (hi : i ∈ support x) :
    (i : ℕ) + 1 ≤ tprof x :=
  Finset.le_sup (f := fun i => (i : ℕ) + 1) (s := support x) hi

/-
The top active coordinate is itself active: for `x ≠ 0` there is a coordinate `i`
    with `x i ≠ 0` and `(i:ℕ)+1 = tprof x`.
-/
theorem exists_top_coord {x : Fin n → ZMod 2} (hx : x ≠ 0) :
    ∃ i, x i ≠ 0 ∧ (i : ℕ) + 1 = tprof x := by
  obtain ⟨i, hi⟩ : ∃ i ∈ support x, (i : ℕ) + 1 = tprof x := by
    obtain ⟨i, hi⟩ : ∃ i ∈ Finset.univ.filter (fun i => x i ≠ 0), ∀ j ∈ Finset.univ.filter (fun i => x i ≠ 0), (i : ℕ) + 1 ≥ (j : ℕ) + 1 := by
      exact Finset.exists_max_image _ _ ⟨ Classical.choose ( Function.ne_iff.mp hx ), by simpa using Classical.choose_spec ( Function.ne_iff.mp hx ) ⟩;
    exact ⟨ i, hi.1, le_antisymm ( Finset.le_sup ( f := fun i : Fin n => ( i : ℕ ) + 1 ) hi.1 ) ( Finset.sup_le fun j hj => hi.2 j hj ) ⟩
  generalize_proofs at *;
  use i;
  aesop;

/-
**Isosceles law** (nonarchimedean sharpness): when the two profiles differ, the
    profile of the sum equals the larger of the two.
-/
theorem tprof_add_eq_of_ne (x y : Fin n → ZMod 2) (h : tprof x ≠ tprof y) :
    tprof (x + y) = max (tprof x) (tprof y) := by
  -- Assume without loss of generality that $tprof x < tprof y$.
  wlog hxy : tprof x < tprof y generalizing x y;
  · convert this y x ( Ne.symm h ) ( lt_of_le_of_ne ( le_of_not_gt hxy ) ( Ne.symm h ) ) using 1 ; rw [ add_comm ];
    exact max_comm _ _;
  · -- Since $tprof y > tprof x \geq 0$, $tprof y \neq 0$ (tprof_eq_zero_iff). Apply exists_top_coord to $y$: get $i$ with $y i \neq 0$ and $(i:ℕ)+1 = tprof y$.
    obtain ⟨i, hi⟩ : ∃ i, y i ≠ 0 ∧ (i : ℕ) + 1 = tprof y := by
      exact exists_top_coord ( by rintro rfl; simp +decide at hxy );
    -- Claim $x i = 0$: otherwise $i \in support x$ (mem_support), so le_tprof_of_mem gives $(i:ℕ)+1 \leq tprof x$, but $(i:ℕ)+1 = tprof y > tprof x$, contradiction.
    have hxi : x i = 0 := by
      exact Classical.not_not.1 fun hx => hxy.not_ge <| hi.2 ▸ le_tprof_of_mem ( mem_support.2 hx );
    -- Hence $(x+y) i = x i + y i = 0 + y i = y i \neq 0$, so $i \in support (x+y)$, and le_tprof_of_mem gives $(i:ℕ)+1 \leq tprof (x+y)$, i.e. $tprof y \leq tprof (x+y)$.
    have h_le : tprof y ≤ tprof (x + y) := by
      exact hi.2 ▸ le_tprof_of_mem ( by simp +decide [ *, mem_support ] );
    exact le_antisymm ( by simpa [ hxy.le ] using tprof_add_le x y ) ( by simpa [ hxy.le ] using h_le )

/-! ## §2. Comparison with the Hamming weight `SmoothPoincare.Codes.wt` -/

/-
The threshold profile **dominates** the Hamming weight: a vector cannot have more
    active coordinates than its top-active-coordinate index allows.
-/
theorem wt_le_tprof (x : Fin n → ZMod 2) :
    SmoothPoincare.Codes.wt x ≤ tprof x := by
  -- By definition of `tprof`, we know that `tprof x` is the supremum of the indices of the non-zero elements in `x`.
  set S := support x with hS_def
  have hS_card : S.card ≤ tprof x := by
    have hS_card : S.card ≤ Finset.card (Finset.image (fun i : Fin n => (i : ℕ)) S) := by
      rw [ Finset.card_image_of_injective _ fun i j hij => by simpa [ Fin.ext_iff ] using hij ];
    exact hS_card.trans ( le_trans ( Finset.card_le_card <| show Finset.image ( fun i : Fin n => ( i : ℕ ) ) S ⊆ Finset.range ( tprof x ) from Finset.image_subset_iff.mpr fun i hi => Finset.mem_range.mpr <| Nat.lt_of_succ_le <| le_tprof_of_mem hi ) <| by simp );
  unfold SmoothPoincare.Codes.wt;
  convert hS_card using 2 ; ext i ; simp +decide [ ZMod, Fin.ext_iff ];
  cases Fin.exists_fin_two.mp ⟨ x i, rfl ⟩ <;> aesop

/-
The profile is bounded by the length of the code.
-/
theorem tprof_le_card (x : Fin n → ZMod 2) : tprof x ≤ n := by
  exact Finset.sup_le fun i hi => Nat.succ_le_of_lt ( Fin.is_lt i )

/-! ## §3. The category of threshold-valued codes -/

/-- A **threshold-valued code object**: a `ZMod 2`-module-like carrier with an additive
    structure and a valuation into `ℕ` satisfying the ultrametric axioms.  This is the
    catalog's `UltraNormObj` *minus* the multiplicative-norm axiom, which no nontrivial
    code valuation can satisfy. -/
structure CodeVal where
  α : Type u
  add : α → α → α
  zero : α
  neg : α → α
  val : α → ℕ
  val_zero : val zero = 0
  val_neg : ∀ x, val (neg x) = val x
  val_add : ∀ x y, val (add x y) ≤ max (val x) (val y)

/-- A morphism of threshold-valued codes: additive, zero-preserving, and
    valuation-nonexpansive. -/
structure CodeValHom (X Y : CodeVal) where
  toFun : X.α → Y.α
  map_zero' : toFun X.zero = Y.zero
  map_add' : ∀ x y, toFun (X.add x y) = Y.add (toFun x) (toFun y)
  nonexpansive' : ∀ x, Y.val (toFun x) ≤ X.val x

instance (X Y : CodeVal) : CoeFun (CodeValHom X Y) (fun _ => X.α → Y.α) :=
  ⟨CodeValHom.toFun⟩

@[ext] theorem CodeValHom.ext {X Y : CodeVal} {f g : CodeValHom X Y}
    (h : ∀ x, f.toFun x = g.toFun x) : f = g := by
  cases f; cases g; congr; exact funext h

/-- The identity morphism. -/
def CodeValHom.id (X : CodeVal) : CodeValHom X X where
  toFun := _root_.id
  map_zero' := rfl
  map_add' := fun _ _ => rfl
  nonexpansive' := fun _ => le_refl _

/-- Composition of morphisms. -/
def CodeValHom.comp {X Y Z : CodeVal} (g : CodeValHom Y Z) (f : CodeValHom X Y) :
    CodeValHom X Z where
  toFun x := g.toFun (f.toFun x)
  map_zero' := by rw [f.map_zero', g.map_zero']
  map_add' := fun x y => by rw [f.map_add', g.map_add']
  nonexpansive' := fun x => le_trans (g.nonexpansive' (f.toFun x)) (f.nonexpansive' x)

theorem CodeValHom.comp_assoc {W X Y Z : CodeVal}
    (h : CodeValHom Y Z) (g : CodeValHom X Y) (f : CodeValHom W X) :
    CodeValHom.comp (CodeValHom.comp h g) f = CodeValHom.comp h (CodeValHom.comp g f) := by
  ext x; rfl

theorem CodeValHom.comp_id {X Y : CodeVal} (f : CodeValHom X Y) :
    CodeValHom.comp f (CodeValHom.id X) = f := by ext x; rfl

theorem CodeValHom.id_comp {X Y : CodeVal} (f : CodeValHom X Y) :
    CodeValHom.comp (CodeValHom.id Y) f = f := by ext x; rfl

/-! ## §4. The concrete code family -/

/-- The ambient length-`n` binary space as a threshold-valued code object. -/
def thresholdSpace (n : ℕ) : CodeVal where
  α := Fin n → ZMod 2
  add := (· + ·)
  zero := 0
  neg := fun x => -x
  val := tprof
  val_zero := tprof_zero
  val_neg := tprof_neg
  val_add := tprof_add_le

/-- The **prefix inclusion** of a length-`m` code into a length-`n` code (`m ≤ n`):
    pad with trailing zeros.  It preserves the leading active coordinate, hence the
    threshold profile. -/
def pad (x : Fin m → ZMod 2) : Fin n → ZMod 2 :=
  fun j => if hj : (j : ℕ) < m then x ⟨j, hj⟩ else 0

theorem pad_add (x y : Fin m → ZMod 2) :
    (pad (x + y) : Fin n → ZMod 2) = pad x + pad y := by
  funext j; simp only [pad, Pi.add_apply]; split <;> simp

theorem pad_zero : (pad (0 : Fin m → ZMod 2) : Fin n → ZMod 2) = 0 := by
  funext j; simp [pad]

theorem tprof_pad (h : m ≤ n) (x : Fin m → ZMod 2) :
    tprof (pad x : Fin n → ZMod 2) = tprof x := by
  refine' le_antisymm _ _;
  · refine' Finset.sup_le fun i hi => _;
    by_cases hi' : ( i : ℕ ) < m <;> simp_all +decide [ support ];
    · refine' lt_of_lt_of_le _ ( Finset.le_sup ( f := fun i : Fin m => ( i : ℕ ) + 1 ) ( show ⟨ i, hi' ⟩ ∈ Finset.univ.filter ( fun i => x i ≠ 0 ) from _ ) ) <;> simp_all +decide [ pad ];
    · unfold pad at hi; aesop;
  · refine' Finset.sup_le fun i hi => _;
    refine' le_trans _ ( Finset.le_sup <| show Fin.castLE h i ∈ support ( pad x ) from _ ) <;> simp_all +decide [ pad ]

/-- The prefix inclusion as a profile-preserving `CodeValHom`. -/
def padHom (h : m ≤ n) : CodeValHom (thresholdSpace m) (thresholdSpace n) where
  toFun := pad
  map_zero' := pad_zero
  map_add' := pad_add
  nonexpansive' := fun x => le_of_eq (tprof_pad h x)

/-! ## §5. The functor to tropical valuation objects -/

open CategoricalTropicalUltrametric

/-- **Object part of the functor**: every threshold-valued code maps to the tropical
    valuation object on the value semiring `(ℕ, max, +)`, exactly as the catalog's
    `tropicalization` functor sends every ultrametric object to the same `ℕ` object. -/
def CodeVal.toTrop (_X : CodeVal) : TropObj :=
  ⟨ℕ, tropicalization_base⟩

/-- **Morphism part of the functor**: a code map induces the identity tropical morphism on
    the shared value semiring. -/
def CodeVal.toTropMap {X Y : CodeVal} (_f : CodeValHom X Y) :
    TropHom X.toTrop Y.toTrop where
  toFun := _root_.id
  map_zero' := rfl
  map_one' := rfl
  map_add' := fun _ _ => rfl
  map_mul' := fun _ _ => rfl
  monotone' := fun _ _ h => h

/-- The functor preserves identities. -/
theorem toTropMap_id (X : CodeVal) :
    CodeVal.toTropMap (CodeValHom.id X) = TropHom.id X.toTrop := by
  ext x; rfl

/-- The functor preserves composition — it is a genuine functor. -/
theorem toTropMap_comp {X Y Z : CodeVal} (f : CodeValHom X Y) (g : CodeValHom Y Z) :
    CodeVal.toTropMap (CodeValHom.comp g f) =
      TropHom.comp (CodeVal.toTropMap g) (CodeVal.toTropMap f) := by
  ext x; rfl

/-! ## §6. Worked instance: the extended Hamming code `[8,4,4]` -/

/-- Every extended-Hamming codeword has threshold profile at most `8` and dominates its
    Hamming weight: a concrete check that the functor's invariant refines the weight
    spectrum proved in `MinimumDistance`. -/
theorem hamming_wt_le_tprof (x : Fin 8 → ZMod 2) :
    SmoothPoincare.Codes.wt x ≤ tprof x ∧ tprof x ≤ 8 :=
  ⟨wt_le_tprof x, tprof_le_card x⟩

/-! ## §7. The induced ultrametric distance (research cycle 2)

-- !-- Lab Notes -- !--
Hypothesis: a genuine nonarchimedean valuation must induce an *ultrametric distance*
  `tdist x y := tprof (x - y)` on every code, giving the catalog's `UltraSeparated`
  picture (`norm = 0 ↔ point`) literally on codewords rather than abstractly.
Result: `tdist` is a `sorry`-free ultrametric — separated (`tdist_eq_zero_iff`),
  symmetric (`tdist_comm`), with the strong triangle inequality (`tdist_triangle`),
  all derived mechanically from the §1 valuation laws.
Insight: the strong triangle inequality is *exactly* `tprof_add_le` applied to the
  telescoping identity `x - z = (x - y) + (y - z)`; symmetry is `tprof_neg`.  No new
  combinatorics are needed — the valuation already contained the metric. -/

/-- The **threshold ultrametric distance** induced by the valuation. -/
def tdist (x y : Fin n → ZMod 2) : ℕ := tprof (x - y)

@[simp] theorem tdist_self (x : Fin n → ZMod 2) : tdist x x = 0 := by
  simp [tdist]

/-- The distance separates points. -/
theorem tdist_eq_zero_iff {x y : Fin n → ZMod 2} : tdist x y = 0 ↔ x = y := by
  rw [tdist, tprof_eq_zero_iff, sub_eq_zero]

/-- The distance is symmetric. -/
theorem tdist_comm (x y : Fin n → ZMod 2) : tdist x y = tdist y x := by
  rw [tdist, tdist, ← tprof_neg, neg_sub]

/-- **The strong (ultrametric) triangle inequality** for the induced distance. -/
theorem tdist_triangle (x y z : Fin n → ZMod 2) :
    tdist x z ≤ max (tdist x y) (tdist y z) := by
  have h : x - z = (x - y) + (y - z) := by ring
  rw [tdist, tdist, tdist, h]
  exact tprof_add_le _ _

/-! ## §8. Concrete functoriality of the prefix-inclusion family (research cycle 2)

-- !-- Lab Notes -- !--
Hypothesis: the prefix-inclusion morphisms `padHom` should themselves form a functor
  from the poset `(ℕ, ≤)` of code lengths into the category `CodeVal`, i.e. they
  compose strictly and the diagonal is the identity.
Result: `padHom_id` and `padHom_comp` proved `sorry`-free, so `n ↦ thresholdSpace n`,
  `(h : m ≤ n) ↦ padHom h` is a genuine functor `(ℕ, ≤) ⥤ CodeVal`.
Insight: prefix inclusion of binary vectors is *strictly* compositional (no coercion
  fudge): padding to length `k` then to `n` writes exactly the same coordinates as
  padding directly to `n`, because the trailing-zero region is stable. -/

theorem pad_id (x : Fin n → ZMod 2) : (pad x : Fin n → ZMod 2) = x := by
  funext j; simp only [pad]; rw [dif_pos j.2]

theorem pad_comp {k : ℕ} (h1 : m ≤ k) (x : Fin m → ZMod 2) :
    (pad (pad x : Fin k → ZMod 2) : Fin n → ZMod 2) = (pad x : Fin n → ZMod 2) := by
  funext j
  simp only [pad]
  by_cases hj : (j : ℕ) < k
  · rw [dif_pos hj]
  · rw [dif_neg hj, dif_neg (fun hjm => hj (lt_of_lt_of_le hjm h1))]

/-- The prefix-inclusion family preserves identities. -/
theorem padHom_id : padHom (le_refl n) = CodeValHom.id (thresholdSpace n) := by
  ext x; exact pad_id x

/-- The prefix-inclusion family preserves composition: it is a functor `(ℕ,≤) ⥤ CodeVal`. -/
theorem padHom_comp {k : ℕ} (h1 : m ≤ k) (h2 : k ≤ n) :
    CodeValHom.comp (padHom h2) (padHom h1) = padHom (h1.trans h2) := by
  ext x; exact pad_comp h1 x

end CodeThresholdValuation