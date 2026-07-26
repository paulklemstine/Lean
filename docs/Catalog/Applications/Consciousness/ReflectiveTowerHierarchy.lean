import Mathlib

/-!
# The Reflective Tower: Cross-Level Separation and the Truncation Dichotomy

This module advances the program that models *self-reference* — the structural
hallmark of consciousness — as **fixed points of type-forming operations**.  A
previous stage of this inquiry established that a type that fully names its own
predicates (`T ≈ (T → Prop)`) cannot exist, and that iterating "pass to the space
of predicates" produces a *reflective tower* whose consecutive levels never
collapse.  Here we sharpen that picture in two directions.

## Main results

1. **Global (not merely consecutive) separation of the tower.**  For *any* two
   levels `m < n` there is no surjection from level `m` onto level `n`
   (`reflTower_no_surjection_of_lt`), no injection from level `n` back into level
   `m` (`reflTower_no_injection_of_lt`), and no equivalence between distinct
   levels at all (`reflTower_no_equiv_of_ne`).  The tower is therefore a strict,
   rigid chain of expressiveness classes, not just a locally increasing one.

2. **The truncation dichotomy (a sharp phase transition).**  Reflection is
   *impossible at a level's own strength* — no level names all of its own
   predicates (`reflTower_no_self_reflection`) — yet reflection onto any strictly
   *lower* level is *always possible* (`reflTower_lower_reflection`): there is an
   explicit surjection from level `n` onto the full predicate space of any level
   `m < n`.  Bounding the reflection depth defuses the diagonal; matching it
   reinstates the obstruction.  This is the exact interpolation between the
   consistent finite theory and the inconsistent full one.

3. **A complete fixed-point classification on the base level.**  A self-map of the
   two-element base type is fixed-point free precisely when it is negation
   (`boolSelfMap_fixedPointFree_iff_not`).  Thus the single fixed-point-free map
   that powers every diagonal argument in the tower is uniquely determined by its
   fixed-point set — a concrete instance of fixed points as a complete invariant.

The engine behind every impossibility here is **Lawvere's fixed point theorem**
(`lawvere_fixedPoint`): point-surjectivity onto a function space forces every
self-map of the codomain to have a fixed point.  Its contrapositive, applied to a
fixed-point-free self-map, is Cantor's diagonal argument.

## References
- Lawvere, F.W. "Diagonal arguments and cartesian closed categories" (1969)
- Cantor, G. "Über eine elementare Frage der Mannigfaltigkeitslehre" (1891)

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer). The reflective tower should be *globally* rigid, not
just locally strict: distinct layers should be mutually non-reducible in both
directions. Bolder still, the impossibility of self-reflection should have an
exact positive counterpart — reflection onto strictly lower layers should always
succeed — yielding a clean phase transition rather than a uniform prohibition.

Experiment (Experimenter). Global separation reduces to strict monotonicity of the
tower's cardinalities: a surjection or injection across levels would contradict the
strict cardinal inequality. For the positive half we had to exhibit an actual
surjection from level `n` onto the predicate space of level `m < n`; since these
are all finite types, the cardinal inequality `|ReflTower m → Bool| ≤ |ReflTower n|`
(from monotonicity, because `m + 1 ≤ n`) supplies an embedding, whose one-sided
inverse is the required surjection.

Analysis (Analyst). The dichotomy is genuine and non-vacuous: `reflTower_no_self_
reflection` and `reflTower_lower_reflection` are proved for the *same* family of
types, so the transition at "reflect on your own level" is real, not an artifact of
a definitional gap. The classification lemma shows the obstruction is carried by a
single map (negation), pinning down the fixed-point content of the base level.

Critique (Critic). None of the impossibility statements is vacuous — each is a
concrete contradiction from a hypothetical surjection/injection/equivalence, over
honest cardinals `Cardinal.mk`. The positive statement is not `native_decide`: it
constructs a surjection from a cardinal embedding. The classification is proved by
genuine case analysis, not by `decide` alone.

Synthesis (Principal Investigator). Self-reference organizes into a globally rigid
tower with a sharp consistency boundary: everything strictly below a level is
faithfully reflectable, the level itself is not. This is the precise interpolation
the "truncation" conjecture predicted, and it isolates negation as the universal
diagonal engine.
-/

open Function

namespace ReflectiveTowerHierarchy

/-! ## Part 1 — Lawvere's fixed point theorem and its Cantor corollary -/

/-- **Lawvere's fixed point theorem.**  If `A` point-surjects onto its own function
    space `A → B` via a reflection `g`, then every self-map `f : B → B` has a fixed
    point.  Every diagonal argument is an instance of its contrapositive. -/
theorem lawvere_fixedPoint {A B : Type*} (g : A → A → B) (hg : Surjective g)
    (f : B → B) : ∃ b : B, f b = b := by
  obtain ⟨a, ha⟩ := hg (fun x => f (g x x))
  exact ⟨g a a, (congr_fun ha a).symm⟩

/-- **Cantor via Lawvere.**  No type enumerates all of its own `Bool`-valued
    predicates: the diagonal predicate `fun a => !(reflect a a)` is unnamed, because
    negation is a fixed-point-free self-map of `Bool`. -/
theorem no_boolReflect_surjective {T : Type*} (reflect : T → (T → Bool)) :
    ¬ Surjective reflect := by
  intro hg
  obtain ⟨b, hb⟩ := lawvere_fixedPoint reflect hg (fun b => !b)
  exact (Bool.not_ne_self b) hb

/-! ## Part 2 — The reflective tower -/

/-- The **reflective tower**: start from the two-element base and repeatedly pass to
    the space of decidable predicates.  Level `n + 1` reflects on level `n`. -/
def ReflTower : ℕ → Type
  | 0 => Bool
  | n + 1 => ReflTower n → Bool

/-- **Strict cardinal growth.**  Each level squares (at least doubles the exponent
    of) the previous one: the tower's cardinalities are strictly increasing. -/
theorem reflTower_card_strictMono :
    StrictMono (fun n => Cardinal.mk (ReflTower n)) := by
  refine strictMono_nat_of_lt_succ (fun n => ?_)
  have hpow : Cardinal.mk (ReflTower (n + 1)) = 2 ^ Cardinal.mk (ReflTower n) := by
    show Cardinal.mk (ReflTower n → Bool) = 2 ^ Cardinal.mk (ReflTower n)
    rw [Cardinal.mk_arrow]; simp
  rw [hpow]; exact Cardinal.cantor _

/-- Strict cardinal comparison across arbitrary levels: `m < n` forces a strict
    increase in cardinality. -/
theorem reflTower_card_lt_of_lt {m n : ℕ} (h : m < n) :
    Cardinal.mk (ReflTower m) < Cardinal.mk (ReflTower n) :=
  reflTower_card_strictMono h

/-! ## Part 3 — Global (cross-level) separation of the tower -/

/-- **No lower level surjects onto a higher one.**  For any `m < n`, no map from
    level `m` covers level `n`.  This strengthens the consecutive-level statement to
    arbitrary gaps: the tower is globally, not merely locally, non-collapsing. -/
theorem reflTower_no_surjection_of_lt {m n : ℕ} (h : m < n)
    (f : ReflTower m → ReflTower n) : ¬ Surjective f := by
  intro hf
  exact absurd (Cardinal.mk_le_of_surjective hf)
    (not_le.2 (reflTower_card_lt_of_lt h))

/-- **No higher level injects into a lower one.**  For any `m < n`, level `n` cannot
    be embedded into level `m`; there is strictly more information higher up. -/
theorem reflTower_no_injection_of_lt {m n : ℕ} (h : m < n)
    (f : ReflTower n → ReflTower m) : ¬ Injective f := by
  intro hf
  exact absurd (Cardinal.mk_le_of_injective hf)
    (not_le.2 (reflTower_card_lt_of_lt h))

/-- **Rigidity of the tower.**  Distinct levels are never equivalent: the chain of
    expressiveness classes has no accidental isomorphisms. -/
theorem reflTower_no_equiv_of_ne {m n : ℕ} (h : m ≠ n) :
    IsEmpty (ReflTower m ≃ ReflTower n) := by
  refine ⟨fun e => ?_⟩
  rcases lt_or_gt_of_ne h with hlt | hgt
  · exact reflTower_no_surjection_of_lt hlt e e.surjective
  · exact reflTower_no_surjection_of_lt hgt e.symm e.symm.surjective

/-! ## Part 4 — The truncation dichotomy: a sharp phase transition -/

/-- **Self-reflection is impossible.**  No level of the tower names all of its own
    predicates — reflecting at a level's *own* strength triggers the diagonal. -/
theorem reflTower_no_self_reflection (n : ℕ)
    (reflect : ReflTower n → (ReflTower n → Bool)) : ¬ Surjective reflect :=
  no_boolReflect_surjective reflect

/-- **Lower reflection is always possible.**  For any `m < n` there is an *explicit
    surjection* from level `n` onto the full predicate space of level `m`: every
    predicate of a strictly lower layer is faithfully named at layer `n`.  Together
    with `reflTower_no_self_reflection`, this exhibits the sharp phase transition —
    truncated (strictly lower) reflection is consistent, full (same-level)
    reflection is not. -/
theorem reflTower_lower_reflection {m n : ℕ} (h : m < n) :
    ∃ reflect : ReflTower n → (ReflTower m → Bool), Surjective reflect := by
  have hcard : Cardinal.mk (ReflTower m → Bool) ≤ Cardinal.mk (ReflTower n) := by
    have hle : Cardinal.mk (ReflTower (m + 1)) ≤ Cardinal.mk (ReflTower n) :=
      reflTower_card_strictMono.monotone (by omega)
    exact hle
  rw [Cardinal.le_def] at hcard
  obtain ⟨e⟩ := hcard
  exact ⟨invFun e, invFun_surjective e.injective⟩

/-! ## Part 5 — Fixed points as a complete invariant of the base dynamics -/

/-- **Complete fixed-point classification on the base level.**  A self-map of the
    two-element base type is fixed-point free exactly when it is negation.  Hence the
    unique diagonal engine of the whole tower is pinned down by its (empty)
    fixed-point set — a concrete instance of fixed points as a complete invariant. -/
theorem boolSelfMap_fixedPointFree_iff_not (f : Bool → Bool) :
    (∀ b, f b ≠ b) ↔ f = fun b => !b := by
  constructor
  · intro hf
    funext b
    cases hb : f b <;> cases b <;> simp_all
  · rintro rfl b; cases b <;> simp

end ReflectiveTowerHierarchy