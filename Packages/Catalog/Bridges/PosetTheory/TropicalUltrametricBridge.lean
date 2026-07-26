import Mathlib

/-!
# Tropical Valuation → Ultrametric Filtration Bridge for Arithmetic

This file builds an explicit bridge between two halves already present, conceptually,
in the catalog:

* **Tropical valuations** (min-plus / non-archimedean valuations valued in `ℝ`), and
* **Arithmetic height measures** on rational points (the `padicNorm` family).

The unifying object is the **non-archimedean norm** `NonArchNorm`, whose induced
distance is a (pseudo-)ultrametric.  We prove the structural ultrametric theorems
abstractly (strong triangle inequality, "all triangles are isosceles"), then show
that a tropical valuation induces such a norm via `x ↦ exp(-v x)` (patched at `0`),
and finally close the loop with the *exact arithmetic identity*

  `padicNorm p q = exp(-(v_p q)·log p)`  for `q ≠ 0`,

which exhibits the `p`-adic arithmetic height as the exponential of the (tropical)
`p`-adic valuation.
-/

-- !-- Lab Notebook -- !--
-- Hypothesis:  A min-plus (tropical) valuation `v : G → ℝ` and an arithmetic height
--   measure (`padicNorm`) are two presentations of *the same* ultrametric structure,
--   linked by the monotone bijection `t ↦ exp(-t)` between `(ℝ, min, +)` and
--   `(ℝ_{>0}, max, ·)`.
-- Result:  Confirmed.  `NonArchNorm` packages the ultrametric core; `dist_strong_triangle`
--   and `dist_isosceles` are the structural payoff; `TropicalValuation.toNorm` realises
--   the bridge map; `padic_norm_eq_exp` is the exact arithmetic identity.
-- Insight:  The strong triangle inequality on norms is *equivalent* to min-superadditivity
--   of the valuation precisely because `exp` is an order isomorphism turning `min` into `max`.
--   The "isosceles" theorem is purely order-theoretic: it needs only the strong triangle
--   inequality plus symmetry, not positive-definiteness — so it survives the pseudometric
--   (height-`0` baseline) setting.
-- Failure analysis:  A naive valuation axiom `∀ x y, min (v x) (v y) ≤ v (x+y)` is FALSE
--   for `padicValRat` at the zero locus (e.g. `q = p`, `r = -p`: `min = 1`, `v 0 = 0`).
--   The fix is to guard the axiom with `x + y ≠ 0` and patch the induced norm to `0` at `0`;
--   this is exactly where the arithmetic content lives.
-- !-- Lab Notebook -- !--

namespace TropUltra

open Real

variable {G : Type*} [AddCommGroup G]

/-- A non-archimedean (ultrametric) norm valued in `ℝ` on an additive group. -/
structure NonArchNorm (G : Type*) [AddCommGroup G] where
  /-- The underlying norm function. -/
  N : G → ℝ
  /-- Nonnegativity. -/
  nonneg : ∀ x, 0 ≤ N x
  /-- The norm of the identity is `0`. -/
  map_zero : N 0 = 0
  /-- Symmetry under negation. -/
  map_neg : ∀ x, N (-x) = N x
  /-- Strong (ultrametric) triangle inequality. -/
  ultra : ∀ x y, N (x + y) ≤ max (N x) (N y)

namespace NonArchNorm

variable (μ : NonArchNorm G)

/-- The distance induced by a non-archimedean norm. -/
def dist (x y : G) : ℝ := μ.N (x - y)

-- !-- `dist x x = N (x - x) = N 0 = 0`. -- !--
theorem dist_self (x : G) : μ.dist x x = 0 := by
  simp +decide [ NonArchNorm.dist, μ.map_zero ]

-- !-- Immediate from `NonArchNorm.nonneg`. -- !--
theorem dist_nonneg (x y : G) : 0 ≤ μ.dist x y := by
  exact μ.nonneg _

-- !-- `y - x = -(x - y)`, then `map_neg`. -- !--
theorem dist_comm (x y : G) : μ.dist x y = μ.dist y x := by
  unfold TropUltra.NonArchNorm.dist
  rw [ ← neg_sub, μ.map_neg ]

/-- **Main theorem 1 (ultrametric inequality).** The induced distance satisfies the
strong triangle inequality. -/
-- !-- Write `x - z = (x - y) + (y - z)` and apply `ultra`. -- !--
theorem dist_strong_triangle (x y z : G) :
    μ.dist x z ≤ max (μ.dist x y) (μ.dist y z) := by
  convert μ.ultra ( x - y ) ( y - z ) using 1
  rw [ sub_add_sub_cancel, NonArchNorm.dist ]

/-- If two norms differ, the norm of the sum equals their max (sharp ultrametric). -/
-- !-- WLOG `N x < N y`; then `N (x+y) ≤ N y` and `N y = N ((x+y) + (-x)) ≤ max (N (x+y)) (N x)`
--     forces `N (x+y) ≥ N y`, hence equality. -- !--
theorem norm_add_eq_max_of_ne {x y : G} (h : μ.N x ≠ μ.N y) :
    μ.N (x + y) = max (μ.N x) (μ.N y) := by
  cases max_cases ( μ.N x ) ( μ.N y ) <;> simp_all +decide
  · have := μ.ultra ( x + y ) ( -y ) ; simp_all +decide
    cases this <;> have := μ.ultra x y <;> simp_all +decide [ NonArchNorm.map_neg ]
    · linarith
    · exact False.elim ( h ( le_antisymm ‹_› ‹_› ) )
  · refine' le_antisymm _ _
    · exact le_trans ( μ.ultra _ _ ) ( max_le ( by linarith ) ( by linarith ) )
    · have := μ.ultra ( x + y ) ( -x ) ; simp_all +decide
      exact this.resolve_right ( by linarith [ μ.map_neg x ] )

/-- **Main theorem 2 (all triangles are isosceles).** In an ultrametric space, if two of
the side lengths differ then the third equals their maximum. -/
-- !-- Apply `norm_add_eq_max_of_ne` to `x - y` and `y - z`, since `(x-y)+(y-z) = x - z`. -- !--
theorem dist_isosceles {x y z : G} (h : μ.dist x y ≠ μ.dist y z) :
    μ.dist x z = max (μ.dist x y) (μ.dist y z) := by
  have h_max : μ.N (x - z) = max (μ.N (x - y)) (μ.N (y - z)) := by
    convert μ.norm_add_eq_max_of_ne _ using 1
    · rw [ sub_add_sub_cancel ]
    · exact h
  exact h_max

end NonArchNorm

/-- A tropical (min-plus, non-archimedean) valuation valued in `ℝ`.  The ultrametric
axiom is guarded away from the zero locus, where genuine `ℝ`-valued valuations break
down (a true valuation would send `0 ↦ +∞`). -/
structure TropicalValuation (G : Type*) [AddCommGroup G] where
  /-- The valuation function. -/
  v : G → ℝ
  /-- Min-superadditivity away from the kernel. -/
  ultra : ∀ x y, x + y ≠ 0 → min (v x) (v y) ≤ v (x + y)
  /-- Symmetry under negation. -/
  neg_eq : ∀ x, v (-x) = v x

/-- The norm induced by a tropical valuation: `exp(-v)` away from `0`, patched to `0`. -/
noncomputable def tvNorm (tv : TropicalValuation G) (x : G) : ℝ :=
  open Classical in if x = 0 then 0 else Real.exp (- tv.v x)

-- !-- `exp > 0` and the patched value is `0`. -- !--
theorem tvNorm_nonneg (tv : TropicalValuation G) (x : G) : 0 ≤ tvNorm tv x := by
  unfold tvNorm; split_ifs <;> positivity

-- !-- Definitional: the `if` picks the `0` branch. -- !--
theorem tvNorm_map_zero (tv : TropicalValuation G) : tvNorm tv 0 = 0 := by
  exact if_pos rfl

-- !-- `-x = 0 ↔ x = 0`, and `tv.neg_eq` handles the nonzero branch. -- !--
theorem tvNorm_map_neg (tv : TropicalValuation G) (x : G) :
    tvNorm tv (-x) = tvNorm tv x := by
  by_cases hx : x = 0 <;> simp +decide [ hx, tvNorm, tv.neg_eq ]

/-- The induced norm satisfies the strong triangle inequality. -/
-- !-- Case split on `x = 0`, `y = 0`, `x + y = 0`; in the all-nonzero case use `tv.ultra`
--     and monotonicity of `exp`, which turns `min` into `max`. -- !--
theorem tvNorm_ultra (tv : TropicalValuation G) (x y : G) :
    tvNorm tv (x + y) ≤ max (tvNorm tv x) (tvNorm tv y) := by
  simp [tvNorm]
  split_ifs
  all_goals simp_all +decide [ Real.exp_nonneg ]
  have := tv.ultra x y ‹_›; cases le_total ( tv.v x ) ( tv.v y ) <;> aesop

/-- **Main theorem 3 (the bridge map).** A tropical valuation induces a non-archimedean
norm via `x ↦ exp(-v x)`, patched to `0` at the identity. -/
noncomputable def TropicalValuation.toNorm (tv : TropicalValuation G) : NonArchNorm G where
  N := tvNorm tv
  nonneg := tvNorm_nonneg tv
  map_zero := tvNorm_map_zero tv
  map_neg := tvNorm_map_neg tv
  ultra := tvNorm_ultra tv

-- !-- `padicValRat.min_le_padicValRat_add` (cast `ℤ → ℝ`) gives the inequality. -- !--
theorem padicValRat_tropical_ultra (p : ℕ) [Fact p.Prime] (q r : ℚ) (h : q + r ≠ 0) :
    min ((padicValRat p q : ℝ)) ((padicValRat p r : ℝ)) ≤ (padicValRat p (q + r) : ℝ) := by
  convert padicValRat.min_le_padicValRat_add h using 1
  rw [ ← @Int.cast_le ℝ ] ; norm_cast
  exact ⟨ Fact.out ⟩

/-- The `p`-adic valuation, packaged as a tropical valuation on `ℚ`. -/
noncomputable def padicTropicalValuation (p : ℕ) [Fact p.Prime] : TropicalValuation ℚ where
  v q := (padicValRat p q : ℝ)
  ultra := fun q r h => padicValRat_tropical_ultra p q r h
  neg_eq := fun q => by simp [padicValRat.neg]

/-- **Main theorem 4 (arithmetic height as an ultrametric).** The `p`-adic norm is a
non-archimedean norm on `ℚ`; its induced distance is therefore an ultrametric (via
`NonArchNorm.dist_strong_triangle`). -/
noncomputable def padicHeightNorm (p : ℕ) [Fact p.Prime] : NonArchNorm ℚ where
  N q := (padicNorm p q : ℝ)
  nonneg := fun q => by exact_mod_cast padicNorm.nonneg q
  map_zero := by simp [padicNorm.zero]
  map_neg := fun q => by exact_mod_cast padicNorm.neg q
  ultra := fun q r => by exact_mod_cast padicNorm.nonarchimedean (p := p) (q := q) (r := r)

/-- **Capstone identity.** The arithmetic height `padicNorm p q` is the exponential of the
negative tropical valuation (scaled by `log p`).  This is the exact, pointwise bridge:
arithmetic height ↔ tropical valuation. -/
-- !-- `padicNorm p q = p^(-v_p q)` for `q ≠ 0` (`padicNorm.eq_zpow_of_nonzero`), and
--     `p^(z:ℤ) = exp(z · log p)` in `ℝ`. -- !--
theorem padic_norm_eq_exp (p : ℕ) [Fact p.Prime] (q : ℚ) (hq : q ≠ 0) :
    (padicNorm p q : ℝ) = Real.exp (-(padicValRat p q : ℝ) * Real.log p) := by
  simp +decide [ hq ]
  rw [ show ( p : ℝ ) ^ padicValRat p q = ( p : ℝ ) ^ ( padicValRat p q : ℝ ) by norm_cast,
    Real.rpow_def_of_pos ( Nat.cast_pos.mpr <| Nat.Prime.pos Fact.out ) ] ; ring
  rw [ Real.exp_neg ]

end TropUltra