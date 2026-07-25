import Catalog.Novelty.PermutationAgreement

/-!
# A large extremal `t`-intersecting family of permutations

Building on the fixed-point bridge of `PermutationAgreement`, this file proves
the **lower-bound half** of the permutation Complete Intersection Theorem
(Deza–Frankl 1977, Kupavskii 2022): for every `t` and `m` there is a
`t`-intersecting family of permutations of `Fin (t + m)` of size `m! = (t+m-t)!`.

A family is `t`-**intersecting** when every two members agree in at least `t`
coordinates.  The canonical extremal witness is the **prefix stabilizer**
`fixPrefix t m`, the permutations fixing each of the first `t` points; any two of
its members agree on all of `0, 1, …, t-1`, so it is `t`-intersecting, and it has
exactly `m!` elements because a permutation fixing the first `t` points is the
same data as a permutation of the remaining `m` points.

The cardinality is computed via `DomMulAct.stabilizer_card`, which expresses the
number of permutations preserving a function as the product of factorials of its
fiber sizes.

## Main results
* `PermIntersecting.card_fixPrefix` — `|fixPrefix t m| = m!`.
* `PermIntersecting.fixPrefix_tIntersecting` — `fixPrefix t m` is `t`-intersecting.
* `PermIntersecting.exists_extremal_tIntersecting` — existence of a
  `t`-intersecting family of permutations of `Fin (t+m)` of size `m!`.
* `PermIntersecting.exists_extremal_intersecting` — the `t = 1` corollary:
  an intersecting family of permutations of `Fin (1+m)` of size `m!` (the
  Deza–Frankl `(n-1)!` lower bound).

-- !-- Lab Notes -- !--
## Hypothesis (Hypothesizer)
The `t`-intersecting extremal family should be a "dictatorship"-type object: fix
`t` coordinates.  Conjecture its size is exactly `(n-t)!` and it is genuinely
`t`-intersecting, matching the Complete Intersection Theorem prediction.

## Experiment (Experimenter)
`t=1, n=3`: permutations fixing `0` are `id` and `(1 2)`, i.e. `2! = 2`.  ✓
`t=2, n=4`: permutations fixing `0,1` are `id` and `(2 3)`, i.e. `2! = 2`.  ✓
`t=3, n=3`: only `id`, i.e. `0! = 1`.  ✓  The pattern `(n-t)!` holds.

## Analysis (Analyst)
Counting reduces to `DomMulAct.stabilizer_card` applied to the "collapse" map
`collapse t m : Fin (t+m) → Fin (t+1)`, identity below `t` and constant `t`
above.  Its fibers are `t` singletons and one block of size `m`, giving product
`1^t · m! = m!`.  The subtle step is that fixing the first `t` points is
*equivalent* to preserving `collapse` — the reverse direction needs
injectivity of `σ`.

## Critique (Critic)
Non-triviality: the theorem is not vacuous — `fixPrefix t m` is exhibited
explicitly and shown both large (`m!`) and `t`-intersecting.  Edge cases `m=0`
(family `= {id}`, size `1 = 0!`) and `t=0` (all permutations, size `(t+m)!`)
are covered by the same proof.

## Synthesis (Principal Investigator)
The lower-bound half of the permutation Complete Intersection Theorem is fully
constructive: `fixPrefix t m` witnesses `(n-t)!` and is provably `t`-intersecting.
Counting via `DomMulAct.stabilizer_card` (fiber factorials) is a clean, reusable
template for future extremal constructions where the family is the stabilizer of
a labelling.  The matching *upper* bound `(n-t)!` (Deza–Frankl / Ellis–Friedgut–
Pilpel) remains the deep open target, recorded in FUTURE_DIRECTIONS.
-/

open Equiv Function Finset

namespace PermIntersecting

variable {n : ℕ}

/-- A family of permutations is `t`-**intersecting** if any two members agree in
at least `t` coordinates. -/
def IsTIntersecting (t : ℕ) (F : Finset (Perm (Fin n))) : Prop :=
  ∀ σ ∈ F, ∀ τ ∈ F, t ≤ (agreements σ τ).card

/-- The **prefix stabilizer**: permutations of `Fin (t+m)` fixing each of the
first `t` points. -/
def fixPrefix (t m : ℕ) : Finset (Perm (Fin (t + m))) :=
  Finset.univ.filter (fun σ => ∀ i : Fin (t + m), (i : ℕ) < t → σ i = i)

/-- The **collapse map**: identity on the first `t` points, constant `t`
elsewhere.  Used to count `fixPrefix` via `DomMulAct.stabilizer_card`. -/
def collapse (t m : ℕ) : Fin (t + m) → Fin (t + 1) :=
  fun i => ⟨min (i : ℕ) t, Nat.lt_succ_of_le (min_le_right _ _)⟩

lemma collapse_coe (t m : ℕ) (i : Fin (t + m)) :
    (collapse t m i : ℕ) = min (i : ℕ) t := rfl

/-
Fixing the first `t` points is equivalent to preserving the collapse map.
-/
lemma fixPrefix_iff_collapse (t m : ℕ) (σ : Perm (Fin (t + m))) :
    (∀ i : Fin (t + m), (i : ℕ) < t → σ i = i) ↔ collapse t m ∘ σ = collapse t m := by
  constructor <;> intro h <;> simp_all +decide [ funext_iff, Fin.ext_iff ];
  · intro i; by_cases hi : ( i : ℕ ) < t <;> simp_all +decide [ collapse ] ;
    contrapose! hi;
    have := σ.injective ( show σ ( σ i ) = σ i from by { exact Fin.ext <| by { by_cases hi' : ( σ i : ℕ ) < t <;> aesop } } ) ; aesop;
  · grind +locals

/-
Each fiber of `collapse` over a value `< t` is a singleton.
-/
lemma card_fiber_castSucc (t m : ℕ) (j : Fin t) :
    Fintype.card {a : Fin (t + m) // collapse t m a = j.castSucc} = 1 := by
  -- Since `j < t`, we have `(collapse t m a : ℕ) = min (a : ℕ) t = j` iff `a = j`.
  have h_fiber : ∀ a : Fin (t + m), collapse t m a = j.castSucc ↔ a = ⟨(j : ℕ), by omega⟩ := by
    simp +decide [ Fin.ext_iff, collapse ];
    grind;
  aesop

/-
The fiber of `collapse` over the top value `t` has `m` elements.
-/
lemma card_fiber_last (t m : ℕ) :
    Fintype.card {a : Fin (t + m) // collapse t m a = Fin.last t} = m := by
  rw [ Fintype.card_subtype ];
  rw [ Finset.card_eq_of_bijective ];
  use fun i hi => ⟨ t + i, by linarith ⟩;
  · intro a ha
    use a.val - t
    simp [collapse] at ha;
    grind +qlia;
  · unfold collapse; aesop;
  · aesop

/-
**The prefix stabilizer has exactly `m!` members.**
-/
theorem card_fixPrefix (t m : ℕ) : (fixPrefix t m).card = m.factorial := by
  convert DomMulAct.stabilizer_card ( collapse t m ) using 1;
  · convert Fintype.card_subtype ( fun g : Perm ( Fin ( t + m ) ) => ∀ i : Fin ( t + m ), ( i : ℕ ) < t → g i = i ) using 1;
    · rw [ Fintype.subtype_card ];
      congr! 1;
    · rw [ Fintype.card_subtype ];
      convert rfl;
      convert fixPrefix_iff_collapse t m _;
  · rw [ Fin.prod_univ_castSucc ];
    simp +decide [ card_fiber_castSucc, card_fiber_last ]

/-
The set of the first `t` coordinates, as a finset of `Fin (t+m)`.
-/
lemma card_prefix_filter (t m : ℕ) :
    (Finset.univ.filter (fun i : Fin (t + m) => (i : ℕ) < t)).card = t := by
  rw [ Finset.card_eq_of_bijective ];
  exacts [ fun i hi => ⟨ i, by linarith ⟩, fun a ha => ⟨ a, by simpa using ha, rfl ⟩, fun i hi => by simpa using hi, fun i j hi hj h => by simpa [ Fin.ext_iff ] using h ]

/-
**The prefix stabilizer is `t`-intersecting.**
-/
lemma fixPrefix_tIntersecting (t m : ℕ) : IsTIntersecting t (fixPrefix t m) := by
  intro σ hσ τ hτ;
  refine' le_trans _ ( Finset.card_le_card _ );
  convert card_prefix_filter t m |> ge_of_eq;
  intro i hi; simp_all +decide [ fixPrefix, agreements ] ;

/-- **Existence of a large extremal `t`-intersecting family.** For every `t` and
`m` there is a `t`-intersecting family of permutations of `Fin (t + m)` of size
`m!`, the permutation Complete Intersection lower bound `(n - t)!`. -/
theorem exists_extremal_tIntersecting (t m : ℕ) :
    ∃ F : Finset (Perm (Fin (t + m))), IsTIntersecting t F ∧ F.card = m.factorial :=
  ⟨fixPrefix t m, fixPrefix_tIntersecting t m, card_fixPrefix t m⟩

/-- **Existence of an extremal intersecting family (Deza–Frankl `(n-1)!` lower
bound).** There is an intersecting family of permutations of `Fin (1 + m)` of
size `m!`. -/
theorem exists_extremal_intersecting (m : ℕ) :
    ∃ F : Finset (Perm (Fin (1 + m))), IsIntersecting F ∧ F.card = m.factorial := by
  refine ⟨fixPrefix 1 m, ?_, card_fixPrefix 1 m⟩
  intro σ hσ τ hτ
  have h := fixPrefix_tIntersecting 1 m σ hσ τ hτ
  exact Finset.card_pos.mp (lt_of_lt_of_le Nat.one_pos h)

end PermIntersecting