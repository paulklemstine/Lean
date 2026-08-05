import Mathlib

/-!
# Impossible Figures VI: non-abelian holonomy and rotational developability

The previous files in this thread
(`Geometry.CellularDevelopability`, `Geometry.CycleCertificates`,
`Geometry.GridCertificates`, `Geometry.TwistedDevelopability`) classify *additive*
increment fields: an increment field `ω : E → A` with values in an abelian group is
developable iff its cellular curvature vanishes and its periods vanish on a
generating family of one-cycles.

Direction 5 of the previous cycle observed that additive height integrability is only
the "shadow" of a genuinely geometric realisation problem: for a piecewise linear
developable realisation in three-space the increments are *rotations*, and they
compose non-commutatively.  This file carries out the first testable step listed
there: the **non-abelian Poincaré lemma**.

## Setup

* A combinatorial one-skeleton is a pair of maps `s t : E → V` (source, target).
* A *step* is a pair `(b, e) : Bool × E`: the edge `e` traversed forwards (`b = true`)
  or backwards (`b = false`).
* A *walk* from `a` to `b` is a list of steps, chained by `IsWalk`.
* An increment field with values in a (possibly non-abelian) group `G` is a map
  `ω : E → G`; its **holonomy** `hol ω l` along a walk is the ordered product of the
  steps, later steps multiplying on the left.
* `Developable s t ω` means `ω` is a coboundary: `ω e = H (t e) * (H (s e))⁻¹`.

## Main results

* `hol_of_coboundary` — discrete Stokes: the holonomy of a coboundary along a walk
  from `a` to `b` is `H b * (H a)⁻¹`; in particular closed walks have trivial
  holonomy (`hol_eq_one_of_developable`).
* `developable_iff_holonomy_trivial` — the non-abelian Poincaré lemma: on a connected
  one-skeleton, `ω` is developable **iff** every closed walk based at a fixed vertex
  has trivial holonomy.
* `hol_gauge` / `holonomy_conj_of_gauge` — the holonomy of a gauge-transformed field
  is conjugate to the original; so the *conjugacy class* of the holonomy of a closed
  walk is a gauge invariant, the non-abelian replacement for `period_gauge_invariant`.
* `hol_map` — a group homomorphism `φ : G →* G'` transports holonomy; hence an
  additive obstruction (a nonzero period after abelianisation) is a special case of a
  non-abelian one (`not_developable_of_map_holonomy_ne_one`).
* `triangle_developable_iff` and `penrose_rotational_not_developable`: on the
  three-cycle (the underlying loop of the Penrose triangle) developability is
  equivalent to the triviality of the single product `ω 2 * ω 1 * ω 0`, and the field
  which turns each beam by one and the same transposition of `Equiv.Perm (Fin 3)`
  is not developable — an impossible figure whose obstruction is purely rotational
  and invisible to any abelian period.
-/

namespace ImpossibleFigures.NonAbelian

variable {V E G G' : Type*} [Group G] [Group G']

/-! ## Steps and walks -/

/-- The initial vertex of a step: `(true, e)` starts at `s e`, `(false, e)` at `t e`. -/
def stepStart (s t : E → V) (p : Bool × E) : V := cond p.1 (s p.2) (t p.2)

/-- The terminal vertex of a step. -/
def stepEnd (s t : E → V) (p : Bool × E) : V := cond p.1 (t p.2) (s p.2)

/-- The group element contributed by a step: `ω e` forwards, `(ω e)⁻¹` backwards. -/
def stepHol (ω : E → G) (p : Bool × E) : G := cond p.1 (ω p.2) (ω p.2)⁻¹

@[simp] lemma stepStart_true (s t : E → V) (e : E) : stepStart s t (true, e) = s e := rfl
@[simp] lemma stepStart_false (s t : E → V) (e : E) : stepStart s t (false, e) = t e := rfl
@[simp] lemma stepEnd_true (s t : E → V) (e : E) : stepEnd s t (true, e) = t e := rfl
@[simp] lemma stepEnd_false (s t : E → V) (e : E) : stepEnd s t (false, e) = s e := rfl
@[simp] lemma stepHol_true (ω : E → G) (e : E) : stepHol ω (true, e) = ω e := rfl
@[simp] lemma stepHol_false (ω : E → G) (e : E) : stepHol ω (false, e) = (ω e)⁻¹ := rfl

/-- Reversing a single step. -/
def revStep (p : Bool × E) : Bool × E := (!p.1, p.2)

@[simp] lemma stepStart_revStep (s t : E → V) (p : Bool × E) :
    stepStart s t (revStep p) = stepEnd s t p := by
  cases p with | mk b e => cases b <;> rfl

@[simp] lemma stepEnd_revStep (s t : E → V) (p : Bool × E) :
    stepEnd s t (revStep p) = stepStart s t p := by
  cases p with | mk b e => cases b <;> rfl

@[simp] lemma stepHol_revStep (ω : E → G) (p : Bool × E) :
    stepHol ω (revStep p) = (stepHol ω p)⁻¹ := by
  cases p with | mk b e => cases b <;> simp [revStep, stepHol]

/-- `IsWalk s t a b l`: the list of steps `l` is a walk from `a` to `b`. -/
inductive IsWalk (s t : E → V) : V → V → List (Bool × E) → Prop
  | nil (v : V) : IsWalk s t v v []
  | cons {a b : V} {p : Bool × E} {l : List (Bool × E)} (h : stepStart s t p = a)
      (hw : IsWalk s t (stepEnd s t p) b l) : IsWalk s t a b (p :: l)

/-- The holonomy of `ω` along a walk: later steps multiply on the left. -/
def hol (ω : E → G) : List (Bool × E) → G
  | [] => 1
  | p :: l => hol ω l * stepHol ω p

@[simp] lemma hol_nil (ω : E → G) : hol ω ([] : List (Bool × E)) = 1 := rfl

@[simp] lemma hol_cons (ω : E → G) (p : Bool × E) (l : List (Bool × E)) :
    hol ω (p :: l) = hol ω l * stepHol ω p := rfl

@[simp] lemma hol_singleton (ω : E → G) (p : Bool × E) : hol ω [p] = stepHol ω p := by
  simp [hol]

lemma hol_append (ω : E → G) (l₁ l₂ : List (Bool × E)) :
    hol ω (l₁ ++ l₂) = hol ω l₂ * hol ω l₁ := by
  induction l₁ with
  | nil => simp
  | cons p l ih => simp [ih, mul_assoc]

lemma IsWalk.append {s t : E → V} {a b c : V} {l₁ l₂ : List (Bool × E)}
    (h₁ : IsWalk s t a b l₁) (h₂ : IsWalk s t b c l₂) : IsWalk s t a c (l₁ ++ l₂) := by
  induction h₁ with
  | nil v => simpa using h₂
  | cons h hw ih => exact IsWalk.cons h (ih h₂)

/-- The reverse walk. -/
def revWalk (l : List (Bool × E)) : List (Bool × E) := (l.map revStep).reverse

@[simp] lemma revWalk_nil : revWalk ([] : List (Bool × E)) = [] := rfl

lemma revWalk_cons (p : Bool × E) (l : List (Bool × E)) :
    revWalk (p :: l) = revWalk l ++ [revStep p] := by
  simp [revWalk]

lemma IsWalk.rev {s t : E → V} {a b : V} {l : List (Bool × E)} (h : IsWalk s t a b l) :
    IsWalk s t b a (revWalk l) := by
  induction h with
  | nil v => exact IsWalk.nil v
  | @cons a b p l hp _ ih =>
      rw [revWalk_cons]
      refine ih.append (IsWalk.cons ?_ ?_)
      · simp
      · simpa [hp] using IsWalk.nil (stepStart s t p)

lemma hol_revWalk (ω : E → G) (l : List (Bool × E)) : hol ω (revWalk l) = (hol ω l)⁻¹ := by
  induction l with
  | nil => simp
  | cons p l ih => rw [revWalk_cons, hol_append]; simp [ih]

/-! ## Developability and discrete Stokes -/

/-- `ω` is *developable* if it is the coboundary of a height (frame) field
`H : V → G`. -/
def Developable (s t : E → V) (ω : E → G) : Prop :=
  ∃ H : V → G, ∀ e, ω e = H (t e) * (H (s e))⁻¹

/-- **Discrete Stokes, non-abelian form.**  The holonomy of a coboundary along a walk
depends only on the endpoints. -/
lemma hol_of_coboundary {s t : E → V} {ω : E → G} (H : V → G)
    (hω : ∀ e, ω e = H (t e) * (H (s e))⁻¹) {a b : V} {l : List (Bool × E)}
    (h : IsWalk s t a b l) : hol ω l = H b * (H a)⁻¹ := by
  induction h with
  | nil v => simp
  | @cons a b p l hp _ ih =>
      obtain ⟨d, e⟩ := p
      cases d
      · simp only [stepStart_false] at hp
        simp only [stepEnd_false] at ih
        rw [hol_cons, ih, stepHol_false, hω e, ← hp]
        group
      · simp only [stepStart_true] at hp
        simp only [stepEnd_true] at ih
        rw [hol_cons, ih, stepHol_true, hω e, ← hp]
        group

/-- A developable field has trivial holonomy on every closed walk. -/
theorem hol_eq_one_of_developable {s t : E → V} {ω : E → G} (hd : Developable s t ω)
    {a : V} {l : List (Bool × E)} (h : IsWalk s t a a l) : hol ω l = 1 := by
  obtain ⟨H, hH⟩ := hd
  simpa using hol_of_coboundary H hH h

/-- Contrapositive: a closed walk with nontrivial holonomy certifies impossibility. -/
theorem not_developable_of_hol_ne_one {s t : E → V} {ω : E → G} {a : V}
    {l : List (Bool × E)} (h : IsWalk s t a a l) (hne : hol ω l ≠ 1) :
    ¬ Developable s t ω := fun hd => hne (hol_eq_one_of_developable hd h)

/-- **Non-abelian Poincaré lemma.**  On a connected one-skeleton (every vertex is
reachable from `base`), an increment field with values in an arbitrary group is
developable iff every closed walk based at `base` has trivial holonomy. -/
theorem developable_iff_holonomy_trivial {s t : E → V} (ω : E → G) (base : V)
    (hconn : ∀ v : V, ∃ l, IsWalk s t base v l) :
    Developable s t ω ↔ ∀ l, IsWalk s t base base l → hol ω l = 1 := by
  constructor
  · intro hd l hl
    exact hol_eq_one_of_developable hd hl
  · intro hcl
    choose c hc using hconn
    refine ⟨fun v => hol ω (c v), fun e => ?_⟩
    have hstep : IsWalk s t (s e) (t e) [(true, e)] := by
      refine IsWalk.cons rfl ?_
      simpa using IsWalk.nil (t e)
    have hloop : IsWalk s t base base (c (s e) ++ ([(true, e)] ++ revWalk (c (t e)))) :=
      (hc (s e)).append (hstep.append (hc (t e)).rev)
    have h1 := hcl _ hloop
    rw [hol_append, hol_append, hol_revWalk, hol_singleton, stepHol_true] at h1
    -- `h1 : (hol ω (c (t e)))⁻¹ * ω e * hol ω (c (s e)) = 1`
    have h2 : (hol ω (c (t e)))⁻¹ * ω e * hol ω (c (s e)) = 1 := by
      simpa [mul_assoc] using h1
    have := congrArg (fun g => hol ω (c (t e)) * g * (hol ω (c (s e)))⁻¹) h2
    simpa [mul_assoc] using this

/-! ## Gauge invariance -/

/-- A gauge transformation of an increment field. -/
def gauge (s t : E → V) (H : V → G) (ω : E → G) : E → G :=
  fun e => H (t e) * ω e * (H (s e))⁻¹

/-- The holonomy of a gauge-transformed field along a walk from `a` to `b` is the
original holonomy conjugated by the gauge at the endpoints. -/
lemma hol_gauge {s t : E → V} (H : V → G) (ω : E → G) {a b : V} {l : List (Bool × E)}
    (h : IsWalk s t a b l) : hol (gauge s t H ω) l = H b * hol ω l * (H a)⁻¹ := by
  induction h with
  | nil v => simp
  | @cons a b p l hp _ ih =>
      obtain ⟨d, e⟩ := p
      cases d
      · simp only [stepStart_false] at hp
        simp only [stepEnd_false] at ih
        rw [hol_cons, hol_cons, ih, stepHol_false, stepHol_false, gauge, ← hp]
        group
      · simp only [stepStart_true] at hp
        simp only [stepEnd_true] at ih
        rw [hol_cons, hol_cons, ih, stepHol_true, stepHol_true, gauge, ← hp]
        group

/-- **Gauge invariance of the rotational holonomy.**  On a closed walk the holonomy of
a gauge-transformed field is conjugate to the original holonomy; in particular
"holonomy `= 1`" is a gauge-invariant condition. -/
theorem holonomy_conj_of_gauge {s t : E → V} (H : V → G) (ω : E → G) {a : V}
    {l : List (Bool × E)} (h : IsWalk s t a a l) :
    hol (gauge s t H ω) l = H a * hol ω l * (H a)⁻¹ := hol_gauge H ω h

theorem developable_gauge_iff {s t : E → V} (H : V → G) (ω : E → G) (base : V)
    (hconn : ∀ v : V, ∃ l, IsWalk s t base v l) :
    Developable s t (gauge s t H ω) ↔ Developable s t ω := by
  rw [developable_iff_holonomy_trivial _ base hconn,
    developable_iff_holonomy_trivial _ base hconn]
  constructor
  · intro h l hl
    have := h l hl
    rw [holonomy_conj_of_gauge H ω hl] at this
    have h2 := congrArg (fun g => (H base)⁻¹ * g * H base) this
    simpa [mul_assoc] using h2
  · intro h l hl
    rw [holonomy_conj_of_gauge H ω hl, h l hl]
    simp

/-! ## Comparison with the additive theory -/

/-- Holonomy is natural in the coefficient group. -/
lemma hol_map (φ : G →* G') (ω : E → G) (l : List (Bool × E)) :
    hol (fun e => φ (ω e)) l = φ (hol ω l) := by
  induction l with
  | nil => simp
  | cons p l ih =>
      obtain ⟨d, e⟩ := p
      cases d <;> simp [ih]

/-- Any abelian shadow of the obstruction is an obstruction: if some homomorphic image
of the holonomy of a closed walk is nontrivial, the field is not developable.  Taking
`φ` the abelianisation recovers the period criterion of the additive theory. -/
theorem not_developable_of_map_holonomy_ne_one {s t : E → V} {ω : E → G} (φ : G →* G')
    {a : V} {l : List (Bool × E)} (h : IsWalk s t a a l) (hne : φ (hol ω l) ≠ 1) :
    ¬ Developable s t ω := by
  refine not_developable_of_hol_ne_one h ?_
  intro h0
  exact hne (by rw [h0, map_one])

/-- Developability transports along a group homomorphism. -/
lemma Developable.map {s t : E → V} {ω : E → G} (φ : G →* G') (hd : Developable s t ω) :
    Developable s t (fun e => φ (ω e)) := by
  obtain ⟨H, hH⟩ := hd
  refine ⟨fun v => φ (H v), fun e => ?_⟩
  show φ (ω e) = φ (H (t e)) * (φ (H (s e)))⁻¹
  rw [hH e]; simp

/-! ## The Penrose triangle with rotational increments

`V = E = Fin 3`, `s i = i`, `t i = i + 1`: the three-cycle, the underlying loop of the
Penrose triangle.  The increments are now arbitrary group elements ("the rotation
carrying one beam to the next"). -/

/-- Source map of the three-cycle. -/
def triS : Fin 3 → Fin 3 := id

/-- Target map of the three-cycle. -/
def triT : Fin 3 → Fin 3 := fun i => i + 1

/-- The fundamental loop of the three-cycle, based at `0`. -/
def triLoop : List (Bool × Fin 3) := [(true, 0), (true, 1), (true, 2)]

lemma triLoop_isWalk : IsWalk triS triT 0 0 triLoop := by
  refine IsWalk.cons rfl (IsWalk.cons rfl (IsWalk.cons rfl ?_))
  simpa using IsWalk.nil (0 : Fin 3)

lemma hol_triLoop (ω : Fin 3 → G) : hol ω triLoop = ω 2 * ω 1 * ω 0 := by
  simp [triLoop, hol, mul_assoc]

lemma triConn : ∀ v : Fin 3, ∃ l, IsWalk triS triT 0 v l := by
  intro v
  fin_cases v
  · exact ⟨[], IsWalk.nil 0⟩
  · refine ⟨[(true, 0)], IsWalk.cons rfl ?_⟩
    simpa [triT] using IsWalk.nil (1 : Fin 3)
  · refine ⟨[(true, 0), (true, 1)], IsWalk.cons rfl (IsWalk.cons rfl ?_)⟩
    simpa [triT] using IsWalk.nil (2 : Fin 3)

/-- Every closed walk of the three-cycle based at `0` has holonomy a power of the
fundamental one; hence developability is decided by the single product
`ω 2 * ω 1 * ω 0`. -/
theorem triangle_developable_iff (ω : Fin 3 → G) :
    Developable triS triT ω ↔ ω 2 * ω 1 * ω 0 = 1 := by
  constructor
  · intro hd
    rw [← hol_triLoop]
    exact hol_eq_one_of_developable hd triLoop_isWalk
  · intro h
    -- explicit frame field: integrate along the tree `0 → 1 → 2`
    refine ⟨![1, ω 0, ω 1 * ω 0], fun e => ?_⟩
    have h2 : ω 2 = (ω 1 * ω 0)⁻¹ := by
      rw [eq_inv_iff_mul_eq_one, ← mul_assoc, h]
    fin_cases e
    · show ω 0 = ω 0 * (1 : G)⁻¹
      group
    · show ω 1 = ω 1 * ω 0 * (ω 0)⁻¹
      group
    · show ω 2 = (1 : G) * (ω 1 * ω 0)⁻¹
      rw [h2]
      group

/-- **A purely rotational impossible figure.**  Give each of the three beams of the
Penrose triangle the same nontrivial involution as its "turn".  The total holonomy is
that involution, not the identity, so no frame field exists — even though *every*
abelian period of the configuration (the image under any homomorphism to an abelian
group, e.g. the sign) may be computed and the obstruction persists in
`Equiv.Perm (Fin 3)` itself. -/
theorem penrose_rotational_not_developable :
    ¬ Developable triS triT (fun _ : Fin 3 => Equiv.swap (0 : Fin 3) 1) := by
  rw [triangle_developable_iff]
  intro h
  have : Equiv.swap (0 : Fin 3) 1 = 1 := by
    rw [← h]
    simp [Equiv.swap_mul_self]
  exact absurd this (by decide)

/-- The same configuration is detected by an abelian shadow as well: the sign
homomorphism sends the holonomy to `-1`. -/
theorem penrose_rotational_sign_certificate :
    Equiv.Perm.sign (hol (fun _ : Fin 3 => Equiv.swap (0 : Fin 3) 1) triLoop) = -1 := by
  rw [hol_triLoop]
  simp [Equiv.swap_mul_self]

/-- By contrast, turning each beam by a *three*-cycle closes up: the rotational
holonomy is trivial and the figure is realisable. -/
theorem three_cycle_developable :
    Developable triS triT (fun _ : Fin 3 => (⟨![1, 2, 0], ![2, 0, 1], by decide, by decide⟩ :
      Equiv.Perm (Fin 3))) := by
  rw [triangle_developable_iff]
  decide

end ImpossibleFigures.NonAbelian