import Computation.BerggrenZetaAbscissa

/-!
# Leg zeta functions of the Berggren tree

Besides the hypotenuse `c(w)` each node `w` of the Berggren tree carries two legs,
`a(w) = m² − n²` (odd) and `b(w) = 2mn` (even), where `(m,n)` is the Euclid seed of the node.
This file defines the two companion Dirichlet series

`Z_a(s) = Σ_w a(w)^{-s}`,  `Z_b(s) = Σ_w b(w)^{-s}`

and proves that **both have abscissa of convergence exactly `1`**, the same as the hypotenuse
zeta function `Z(s)`.

The two directions come from genuinely different mechanisms.

* Divergence for `s ≤ 1` is a comparison: `a(w) ≤ c(w)` and `b(w) ≤ c(w)`, so the leg series
  dominate the hypotenuse series termwise at `s = 1` and `not_summable_zterm_one` applies.
* Convergence for `s > 1` cannot use the hypotenuse bound in reverse (the legs are *not*
  comparable to `c` from below: `b/c → 0` along the `s₂`-spine, `a/c → 0` along the `s₀`-spine).
  Instead we use the *multiplicative* structure of the legs: `b = 2mn ≥ m·n` and
  `a = (m−n)(m+n) ≥ (m−n)·m`, so in both cases the term is dominated by a product
  `u^{-s} v^{-s}` along an injective reindexing of the seeds, and `Σ_{u,v ≥ 1} u^{-s} v^{-s}
  = ζ(s)²` converges.  This is a genuinely two-dimensional argument, and it is the reason the
  legs have the same abscissa as the hypotenuse even though their counting functions differ (the
  even leg has `≍ B log B` values below `B`).
-/

namespace BerggrenZeta

open Real

noncomputable section

/-- The odd leg of the triple at a node. -/
def aleg (p : ℕ × ℕ) : ℕ := p.1 ^ 2 - p.2 ^ 2

/-- The even leg of the triple at a node. -/
def bleg (p : ℕ × ℕ) : ℕ := 2 * p.1 * p.2

lemma aleg_eq_tri (p : ℕ × ℕ) : aleg p = (tri p).1 := rfl

lemma bleg_eq_tri (p : ℕ × ℕ) : bleg p = (tri p).2.1 := rfl

/-- Term of the odd-leg zeta function. -/
def aterm (s : ℝ) (w : List (Fin 3)) : ℝ := (aleg (node w) : ℝ) ^ (-s)

/-- Term of the even-leg zeta function. -/
def bterm (s : ℝ) (w : List (Fin 3)) : ℝ := (bleg (node w) : ℝ) ^ (-s)

/-! ## Elementary size comparisons -/

lemma one_le_aleg {p : ℕ × ℕ} (hp : IsSeed p) : 1 ≤ aleg p := by
  have h1 := hp.pos
  have h2 := hp.lt
  unfold aleg
  have : p.2 ^ 2 + 1 ≤ p.1 ^ 2 := by nlinarith
  omega

lemma one_le_bleg {p : ℕ × ℕ} (hp : IsSeed p) : 1 ≤ bleg p := by
  have h1 := hp.pos
  have h2 := hp.lt
  unfold bleg
  nlinarith

lemma aleg_le_hyp (p : ℕ × ℕ) : aleg p ≤ hyp p := by
  unfold aleg hyp
  omega

lemma bleg_le_hyp (p : ℕ × ℕ) : bleg p ≤ hyp p := by
  unfold bleg hyp
  nlinarith [sq_nonneg ((p.1 : ℤ) - (p.2 : ℤ))]

/-- `a = (m−n)(m+n) ≥ (m−n)·m`: the odd leg dominates a product of two independent parameters. -/
lemma aleg_ge_prod {p : ℕ × ℕ} (hp : IsSeed p) : (p.1 - p.2) * p.1 ≤ aleg p := by
  have h1 := hp.pos
  have h2 := hp.lt
  unfold aleg
  have hexp : p.1 ^ 2 - p.2 ^ 2 = (p.1 - p.2) * (p.1 + p.2) := by
    rw [Nat.sq_sub_sq]; ring
  rw [hexp]
  exact Nat.mul_le_mul_left _ (by omega)

/-- `b = 2mn ≥ m·n`. -/
lemma bleg_ge_prod (p : ℕ × ℕ) : p.1 * p.2 ≤ bleg p := by
  unfold bleg
  nlinarith

/-! ## Convergence for `s > 1` -/

/-- The product majorant `Σ_{u,v} u^{-s} v^{-s} = ζ(s)²`. -/
lemma summable_prod_majorant {s : ℝ} (hs : 1 < s) :
    Summable (fun q : ℕ × ℕ => (q.1 : ℝ) ^ (-s) * (q.2 : ℝ) ^ (-s)) := by
  have h : Summable (fun n : ℕ => (n : ℝ) ^ (-s)) := Real.summable_nat_rpow.mpr (by linarith)
  exact h.mul_of_nonneg h (fun n => Real.rpow_nonneg (Nat.cast_nonneg n) _)
    (fun n => Real.rpow_nonneg (Nat.cast_nonneg n) _)

/-- If a positive natural number `N` dominates the product `u·v` with `u, v ≥ 1`, then
`N^{-s} ≤ u^{-s} v^{-s}` for `s > 0`. -/
lemma rpow_le_prod_rpow {s : ℝ} (hs : 0 < s) {u v N : ℕ} (hu : 1 ≤ u) (hv : 1 ≤ v)
    (h : u * v ≤ N) : (N : ℝ) ^ (-s) ≤ (u : ℝ) ^ (-s) * (v : ℝ) ^ (-s) := by
  have huR : (1 : ℝ) ≤ (u : ℝ) := by exact_mod_cast hu
  have hvR : (1 : ℝ) ≤ (v : ℝ) := by exact_mod_cast hv
  have hprod : ((u : ℝ)) * (v : ℝ) ≤ (N : ℝ) := by exact_mod_cast h
  have hmul : ((u : ℝ) * (v : ℝ)) ^ (-s) = (u : ℝ) ^ (-s) * (v : ℝ) ^ (-s) :=
    Real.mul_rpow (by linarith) (by linarith)
  rw [← hmul]
  exact Real.rpow_le_rpow_of_nonpos (by nlinarith) hprod (by linarith)

/-- **Convergence of the even-leg zeta function** for `s > 1`. -/
theorem summable_bterm {s : ℝ} (hs : 1 < s) : Summable (bterm s) := by
  have hmaj := summable_prod_majorant hs
  -- reindex the seeds by `(m, n)` itself
  have hcomp : Summable ((fun q : ℕ × ℕ => (q.1 : ℝ) ^ (-s) * (q.2 : ℝ) ^ (-s)) ∘
      (fun p : {p : ℕ × ℕ // IsSeed p} => p.1)) :=
    hmaj.comp_injective (fun x y h => Subtype.ext h)
  have hseed : Summable (fun p : {p : ℕ × ℕ // IsSeed p} => (bleg p.1 : ℝ) ^ (-s)) := by
    refine Summable.of_nonneg_of_le (fun p => Real.rpow_nonneg (by positivity) _) ?_ hcomp
    intro p
    have h1 : 1 ≤ p.1.1 := by have := p.2.pos; have := p.2.lt; omega
    have h2 : 1 ≤ p.1.2 := p.2.pos
    exact rpow_le_prod_rpow (by linarith) h1 h2 (bleg_ge_prod p.1)
  exact (nodeEquiv.summable_iff
    (f := fun p : {p : ℕ × ℕ // IsSeed p} => (bleg p.1 : ℝ) ^ (-s))).2 hseed

/-- **Convergence of the odd-leg zeta function** for `s > 1`.  Here the reindexing
`(m,n) ↦ (m−n, m)` is what makes the two-dimensional majorant applicable. -/
theorem summable_aterm {s : ℝ} (hs : 1 < s) : Summable (aterm s) := by
  have hmaj := summable_prod_majorant hs
  have hinj : Function.Injective
      (fun p : {p : ℕ × ℕ // IsSeed p} => ((p.1.1 - p.1.2, p.1.1) : ℕ × ℕ)) := by
    intro x y h
    simp only [Prod.mk.injEq] at h
    have hx := x.2.lt
    have hy := y.2.lt
    refine Subtype.ext (Prod.ext h.2 ?_)
    omega
  have hcomp : Summable ((fun q : ℕ × ℕ => (q.1 : ℝ) ^ (-s) * (q.2 : ℝ) ^ (-s)) ∘
      (fun p : {p : ℕ × ℕ // IsSeed p} => ((p.1.1 - p.1.2, p.1.1) : ℕ × ℕ))) :=
    hmaj.comp_injective hinj
  have hseed : Summable (fun p : {p : ℕ × ℕ // IsSeed p} => (aleg p.1 : ℝ) ^ (-s)) := by
    refine Summable.of_nonneg_of_le (fun p => Real.rpow_nonneg (by positivity) _) ?_ hcomp
    intro p
    have hlt := p.2.lt
    have hpos := p.2.pos
    have h1 : 1 ≤ p.1.1 - p.1.2 := by omega
    have h2 : 1 ≤ p.1.1 := by omega
    exact rpow_le_prod_rpow (by linarith) h1 h2 (aleg_ge_prod p.2)
  exact (nodeEquiv.summable_iff
    (f := fun p : {p : ℕ × ℕ // IsSeed p} => (aleg p.1 : ℝ) ^ (-s))).2 hseed

/-! ## Divergence for `s ≤ 1` -/

lemma aterm_mono {s : ℝ} (hs : s ≤ 1) (w : List (Fin 3)) : aterm 1 w ≤ aterm s w := by
  have h1 : (1 : ℝ) ≤ (aleg (node w) : ℝ) := by
    exact_mod_cast one_le_aleg (isSeed_node w)
  exact Real.rpow_le_rpow_of_exponent_le h1 (by linarith)

lemma bterm_mono {s : ℝ} (hs : s ≤ 1) (w : List (Fin 3)) : bterm 1 w ≤ bterm s w := by
  have h1 : (1 : ℝ) ≤ (bleg (node w) : ℝ) := by
    exact_mod_cast one_le_bleg (isSeed_node w)
  exact Real.rpow_le_rpow_of_exponent_le h1 (by linarith)

lemma zterm_le_aterm_one (w : List (Fin 3)) : zterm 1 w ≤ aterm 1 w := by
  have h0 : (1 : ℝ) ≤ (aleg (node w) : ℝ) := by exact_mod_cast one_le_aleg (isSeed_node w)
  have hle : (aleg (node w) : ℝ) ≤ (chyp w : ℝ) := by
    exact_mod_cast aleg_le_hyp (node w)
  show (chyp w : ℝ) ^ (-(1 : ℝ)) ≤ (aleg (node w) : ℝ) ^ (-(1 : ℝ))
  exact Real.rpow_le_rpow_of_nonpos (by linarith) hle (by norm_num)

lemma zterm_le_bterm_one (w : List (Fin 3)) : zterm 1 w ≤ bterm 1 w := by
  have h0 : (1 : ℝ) ≤ (bleg (node w) : ℝ) := by exact_mod_cast one_le_bleg (isSeed_node w)
  have hle : (bleg (node w) : ℝ) ≤ (chyp w : ℝ) := by
    exact_mod_cast bleg_le_hyp (node w)
  show (chyp w : ℝ) ^ (-(1 : ℝ)) ≤ (bleg (node w) : ℝ) ^ (-(1 : ℝ))
  exact Real.rpow_le_rpow_of_nonpos (by linarith) hle (by norm_num)

/-- **Divergence of the odd-leg zeta function** for every `s ≤ 1`. -/
theorem not_summable_aterm {s : ℝ} (hs : s ≤ 1) : ¬ Summable (aterm s) := by
  intro hsum
  have h1 : Summable (aterm 1) :=
    Summable.of_nonneg_of_le (fun w => Real.rpow_nonneg (by positivity) _)
      (fun w => aterm_mono hs w) hsum
  exact not_summable_zterm_one
    (Summable.of_nonneg_of_le (fun w => Real.rpow_nonneg (by positivity) _)
      (fun w => zterm_le_aterm_one w) h1)

/-- **Divergence of the even-leg zeta function** for every `s ≤ 1`. -/
theorem not_summable_bterm {s : ℝ} (hs : s ≤ 1) : ¬ Summable (bterm s) := by
  intro hsum
  have h1 : Summable (bterm 1) :=
    Summable.of_nonneg_of_le (fun w => Real.rpow_nonneg (by positivity) _)
      (fun w => bterm_mono hs w) hsum
  exact not_summable_zterm_one
    (Summable.of_nonneg_of_le (fun w => Real.rpow_nonneg (by positivity) _)
      (fun w => zterm_le_bterm_one w) h1)

/-! ## The abscissae -/

/-- Abscissa of convergence of the odd-leg zeta function. -/
def aAbscissa : ℝ := sInf {s : ℝ | Summable (aterm s)}

/-- Abscissa of convergence of the even-leg zeta function. -/
def bAbscissa : ℝ := sInf {s : ℝ | Summable (bterm s)}

theorem summable_aterm_iff (s : ℝ) : Summable (aterm s) ↔ 1 < s := by
  refine ⟨fun h => ?_, summable_aterm⟩
  by_contra hcon
  exact not_summable_aterm (not_lt.1 hcon) h

theorem summable_bterm_iff (s : ℝ) : Summable (bterm s) ↔ 1 < s := by
  refine ⟨fun h => ?_, summable_bterm⟩
  by_contra hcon
  exact not_summable_bterm (not_lt.1 hcon) h

/-- **The odd-leg zeta function has abscissa of convergence `1`.** -/
theorem aAbscissa_eq_one : aAbscissa = 1 := by
  unfold aAbscissa
  have : {s : ℝ | Summable (aterm s)} = Set.Ioi 1 := by
    ext s; simpa using summable_aterm_iff s
  rw [this, csInf_Ioi]

/-- **The even-leg zeta function has abscissa of convergence `1`.** -/
theorem bAbscissa_eq_one : bAbscissa = 1 := by
  unfold bAbscissa
  have : {s : ℝ | Summable (bterm s)} = Set.Ioi 1 := by
    ext s; simpa using summable_bterm_iff s
  rw [this, csInf_Ioi]

/-- **All three zeta functions of the Berggren tree share the abscissa `1`.** -/
theorem abscissae_agree : zetaAbscissa = 1 ∧ aAbscissa = 1 ∧ bAbscissa = 1 :=
  ⟨zetaAbscissa_eq_one, aAbscissa_eq_one, bAbscissa_eq_one⟩

end

end BerggrenZeta