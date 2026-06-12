/-
Copyright (c) 2025. All rights reserved.

# The Gilbert–Varshamov Bound and Covering Numbers for Block Codes

## Overview

This file formalizes the **Gilbert–Varshamov (GV) lower bound** of algebraic
coding theory, the natural dual of the sphere-packing (Hamming) *upper* bound
proved in `Catalog/Tropical/SpherePackingBound.lean`.  Where the Hamming bound
says that disjoint radius-`t` balls cannot overpack the space
(`|C| · V(t) ≤ qⁿ`), the GV bound says that a *maximal* code's radius-`(d-1)`
balls must *cover* the whole space, giving the lower bound

    qⁿ ≤ |C| · V(d-1).

Together with `sphere_packing_bound` this brackets the optimal code size between
two volume estimates — the classical packing/covering duality.

The same covering argument computes the **`r`-covering number** of the Hamming
space (metric-entropy direction): any family of radius-`r` balls covering the
space has at least `qⁿ / V(r)` members.

## Main Results

* `covering_lower_bound` — any `r`-covering code `C` satisfies `qⁿ ≤ |C| · V(r)`
  (the covering-number / metric-entropy lower bound).
* `exists_max_minDist_code` — a code of maximum cardinality among those with
  minimum distance `≥ d` exists (greedy/extremal selection).
* `maxDist_code_covers` — such a maximum code is `(d-1)`-covering: maximality
  forbids any uncovered word.
* `gilbert_varshamov` — there exists a code `C` of minimum distance `≥ d` with
  `qⁿ ≤ |C| · V(d-1)` (the GV bound).
* `gilbert_varshamov_formula` — the closed-form GV bound using the explicit
  ball volume `V(d-1) = ∑_{i<d} C(n,i)(q-1)ⁱ`.

## Catalog Synthesis

This directly extends `Catalog/Tropical/SpherePackingBound.lean`: it reuses that
file's `hammingBall`, `hammingBall_card_translation` (all balls are equicardinal)
and `hammingBall_card_formula` (the closed-form volume), turning the *packing*
(disjointness) viewpoint into the *covering* (union) viewpoint.  The pairing of
the two files realizes the packing/covering duality that underlies both coding
theory and the metric-entropy estimates of approximation theory.
-/
import Tropical.SpherePackingBound

open Finset BigOperators
open SpherePackingBound

noncomputable section

namespace GilbertVarshamov

variable {ι : Type*} [Fintype ι] [DecidableEq ι]
variable {G : Type*} [Fintype G] [DecidableEq G] [AddCommGroup G]

/-! ## Minimum distance and covering predicates -/

/-- A code `C` has **minimum distance at least `d`** if every pair of distinct
codewords is at Hamming distance at least `d`. -/
def MinDistAtLeast (C : Finset (ι → G)) (d : ℕ) : Prop :=
  ∀ x ∈ C, ∀ y ∈ C, x ≠ y → d ≤ hammingDist x y

/-- A code `C` is **`r`-covering** if every word of the space lies within Hamming
distance `r` of some codeword. -/
def Covers (C : Finset (ι → G)) (r : ℕ) : Prop :=
  ∀ y : ι → G, ∃ c ∈ C, hammingDist c y ≤ r

instance (C : Finset (ι → G)) (d : ℕ) : Decidable (MinDistAtLeast C d) := by
  unfold MinDistAtLeast; infer_instance

/-! ## The covering lower bound (metric entropy) -/

/-
!-- The space is the union of the codewords' radius-`r` balls (by `Covers`),
so `qⁿ = |univ| ≤ ∑_{c} |ball c r| = |C| · V(r)` using `card_biUnion_le` and
`hammingBall_card_translation` (all balls equicardinal). -- !--

**Covering-number lower bound.**  If the radius-`r` balls about the codewords
of `C` cover the whole space, then `qⁿ ≤ |C| · V(r)`, where `V(r)` is the volume
of a radius-`r` Hamming ball.  Equivalently the `r`-covering number is at least
`qⁿ / V(r)`.
-/
theorem covering_lower_bound (C : Finset (ι → G)) (r : ℕ) (hC : Covers C r) :
    Fintype.card (ι → G) ≤ C.card * (hammingBall (0 : ι → G) r).card := by
  have h_union : Finset.univ ⊆ Finset.biUnion C (fun c => hammingBall c r) := by
    intro y hy; specialize hC y; aesop;
  exact le_trans ( by simp ) ( le_trans ( Finset.card_mono h_union ) ( Finset.card_biUnion_le.trans ( Finset.sum_le_card_nsmul _ _ _ fun x hx => hammingBall_card_translation x r ▸ le_rfl ) ) )

/-! ## Existence of a maximum-cardinality code -/

/-
!-- The family of codes with minimum distance `≥ d` is a finite, nonempty
(it contains `∅`) set of finsets; apply `Finset.exists_max_image` to the
cardinality function to extract a maximizer. -- !--

**Extremal selection.**  Among all codes with minimum distance at least `d`
there is one, `C`, of maximum cardinality.
-/
omit [AddCommGroup G] in
theorem exists_max_minDist_code (d : ℕ) :
    ∃ C : Finset (ι → G), MinDistAtLeast C d ∧
      ∀ C' : Finset (ι → G), MinDistAtLeast C' d → C'.card ≤ C.card := by
  have h_nonempty : ∃ C : Finset (ι → G), MinDistAtLeast C d := by
    exact ⟨ ∅, by simp +decide [ MinDistAtLeast ] ⟩;
  apply_rules [ Set.exists_max_image ];
  exact Set.toFinite _

/-! ## A maximal code covers the space -/

/-
!-- If some word `y` were at distance `≥ d` from every codeword then `insert y C`
would still have minimum distance `≥ d` but strictly larger cardinality,
contradicting maximality; hence `y` is within `d-1` of a codeword. -- !--

**Maximality forces covering.**  A code of maximum cardinality among those of
minimum distance at least `d` is `(d-1)`-covering.  (No `d ≥ 1` hypothesis is
needed: the argument is uniform in `d`.)
-/
omit [DecidableEq ι] [Fintype G] [AddCommGroup G] in
theorem maxDist_code_covers (d : ℕ) (C : Finset (ι → G))
    (hmin : MinDistAtLeast C d)
    (hmax : ∀ C' : Finset (ι → G), MinDistAtLeast C' d → C'.card ≤ C.card) :
    Covers C (d - 1) := by
  intro y
  by_contra h_contra;
  refine' not_lt_of_ge ( hmax ( Insert.insert y C ) _ ) _;
  · intro x hx y hy hxy;
    cases' Finset.mem_insert.mp hx with hx hx <;> cases' Finset.mem_insert.mp hy with hy hy <;> simp_all +decide [ hammingDist_comm ];
    · exact Nat.le_of_pred_lt ( h_contra y hy );
    · exact Nat.le_of_pred_lt ( h_contra x hx );
    · exact hmin x hx y hy hxy;
  · rw [ Finset.card_insert_of_notMem ] ; aesop;
    exact fun hy => h_contra ⟨ y, hy, by simp +decide ⟩

/-! ## The Gilbert–Varshamov bound -/

/-
!-- Combine `exists_max_minDist_code` (a maximizer `C`), `maxDist_code_covers`
(it is `(d-1)`-covering) and `covering_lower_bound` (covering gives the volume
inequality) to produce the desired code. -- !--

**Gilbert–Varshamov bound.**  For every `d` there exists a code `C` with
minimum distance at least `d` such that `qⁿ ≤ |C| · V(d-1)`.  Equivalently there
is a code of size at least `qⁿ / V(d-1)` with minimum distance `≥ d`.
-/
theorem gilbert_varshamov (d : ℕ) :
    ∃ C : Finset (ι → G), MinDistAtLeast C d ∧
      Fintype.card (ι → G) ≤ C.card * (hammingBall (0 : ι → G) (d - 1)).card := by
  obtain ⟨C, hmin, hmax⟩ := exists_max_minDist_code (ι := ι) (G := G) d
  exact ⟨C, hmin, covering_lower_bound C (d - 1) (maxDist_code_covers d C hmin hmax)⟩

/-
!-- Substitute the closed-form `hammingBall_card_formula` for `V(d-1)` and
rewrite `|ι → G| = qⁿ` via `Fintype.card_fun` in `gilbert_varshamov`. -- !--

**Closed-form Gilbert–Varshamov bound.**  There is a code `C` of minimum
distance at least `d` with
`qⁿ ≤ |C| · ∑_{i<d} C(n,i)(q-1)ⁱ`.
-/
theorem gilbert_varshamov_formula (d : ℕ) (hd : 1 ≤ d) :
    ∃ C : Finset (ι → G), MinDistAtLeast C d ∧
      (Fintype.card G) ^ (Fintype.card ι) ≤
        C.card *
          ∑ i ∈ Finset.range d,
            (Fintype.card ι).choose i * (Fintype.card G - 1) ^ i := by
  convert gilbert_varshamov (ι := ι) (G := G) d using 8;
  · simp +decide [ Fintype.card_pi ];
  · rw [ hammingBall_card_formula ] ; cases d <;> simp_all +decide [ Finset.sum_range_succ ]

end GilbertVarshamov

/-
!-- Lab Notebook -- !--

* Hypothesis.  The sphere-packing (Hamming) *upper* bound already proved in
  `SpherePackingBound.lean` is one half of a packing/covering duality.  We
  hypothesized that the *same* ball-volume machinery (equicardinality of
  Hamming balls + the closed-form volume) yields the dual Gilbert–Varshamov
  *lower* bound via a covering, rather than a packing, argument.

* Result.  Confirmed.  We proved (sorry-free):
  - `covering_lower_bound`: any `r`-covering code obeys `qⁿ ≤ |C|·V(r)`;
  - `exists_max_minDist_code`: an extremal (max-cardinality) code of minimum
    distance `≥ d` exists;
  - `maxDist_code_covers`: extremality forces `(d-1)`-covering;
  - `gilbert_varshamov` and `gilbert_varshamov_formula`: `qⁿ ≤ |C|·V(d-1)`,
    in abstract and closed form.
  No Turing machines, fields, or asymptotics were needed — only finiteness.

* Insight.  Packing and covering are dual extremal principles over the *same*
  volume functional `V`: packing makes the balls disjoint (sum ≤ whole),
  covering makes them exhaust (whole ≤ sum).  The Hamming bound and the GV
  bound are therefore two readings of one inequality
  `|C|·V(t)  ⋚  qⁿ`, bracketing the optimal code size.  Maximality is exactly
  the bridge that converts "min-distance `≥ d`" into "`(d-1)`-covering".

* Failure analysis.  Stating GV as "there exists a code of size `≥ qⁿ/V`"
  with natural-number division loses information (floor); we instead keep the
  multiplicative form `qⁿ ≤ |C|·V`, which is both cleaner and strictly stronger.
  Selecting the extremal code via `Finset.max'` over an explicit filtered
  family was the brittle step; phrasing existence through a finiteness/maximum
  lemma on the predicate avoided heavy `Finset` bookkeeping.  The project's
  `lakefile.toml` was missing `srcDir = "Catalog"`, so nothing built until that
  was supplied — a build-config, not a mathematical, obstruction.
-/

end