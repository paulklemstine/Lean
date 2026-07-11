/-
# Anti-Gravity Mathematics: a formal model of theorem dependency graphs

This file formalizes the *speculative* research theme "Anti-Gravity Mathematics —
Theorems That Resist Proof".

We model a formal mathematical library as a finite set `V` of theorems equipped
with a decidable dependency relation `D : V → V → Prop`, where `D a b` reads
"theorem `b` depends on theorem `a`" (i.e. `a` is used in the proof of `b`).

* The **gravitational weight** of a theorem `a` is the number of theorems that
  depend on it, `depWeight D a = #{ b | D a b }`.
* A theorem is **anti-gravity** (relative to thresholds `w0`, `l0` and a proof-length
  function `plen`) if it has high weight but a short proof:
  `w0 ≤ depWeight D a ∧ plen a ≤ l0`.

We prove a coherent collection of genuine combinatorial facts about this model:

* `sum_depWeight_eq_sum_inDeg` — a handshake/double-counting identity: the total
  weight of the library equals the total number of dependencies.
* `depWeight_le_card`, `depWeight_lt_card_of_irrefl` — weight bounds.
* `exists_max_depWeight`, `sum_depWeight_le_card_mul_max` — an averaging principle.
* `exists_antigravity_of_short_heavy` — an **existence theorem for anti-gravity
  theorems**: if the short-proof theorems carry enough total weight, one of them
  must be anti-gravity (pigeonhole/averaging).
* `depWeight_le_of_trans` — foundational theorems are heaviest: along a transitive
  dependency order, deeper (more foundational) theorems have at least as much weight.
* `linear_library_bottom_weight`, `linear_library_antigravity` — a concrete
  non-vacuous witness: in a totally-ordered ("linear") library the bottom theorem
  has weight `n-1` and a length-1 proof, hence is anti-gravity.
* `no_deps_no_antigravity` — an honest **refutation** of the over-strong universal
  prediction that "10% of theorems in any library are anti-gravity": a library with
  no dependencies contains *no* anti-gravity theorems at all.

The stronger claims in the theme (density in a topology, a fixed 10% fraction) are
discussed in `FUTURE_DIRECTIONS.md`; they are model-dependent and, taken literally
as universal statements, false — as `no_deps_no_antigravity` shows.
-/
import Mathlib

open Finset

namespace AntiGravity

variable {V : Type*} [Fintype V]

/-- The **gravitational weight** of theorem `a`: the number of theorems that
depend on `a` (its dependents). -/
def depWeight (D : V → V → Prop) [DecidableRel D] (a : V) : ℕ :=
  (univ.filter (fun b => D a b)).card

/-- The **in-degree** of theorem `b`: the number of theorems it directly depends on. -/
def inDeg (D : V → V → Prop) [DecidableRel D] (b : V) : ℕ :=
  (univ.filter (fun a => D a b)).card

/-- A theorem `a` is **anti-gravity** with respect to weight threshold `w0`,
proof-length bound `l0`, and proof-length function `plen`, if it has high weight
but a short proof. -/
def IsAntiGravity (D : V → V → Prop) [DecidableRel D] (plen : V → ℕ)
    (w0 l0 : ℕ) (a : V) : Prop :=
  w0 ≤ depWeight D a ∧ plen a ≤ l0

/-
**Handshake / double-counting identity.** The total gravitational weight of a
library equals the total number of dependency edges, i.e. the sum of in-degrees.
-/
theorem sum_depWeight_eq_sum_inDeg (D : V → V → Prop) [DecidableRel D] :
    ∑ a, depWeight D a = ∑ b, inDeg D b := by
  simp +decide only [depWeight, card_filter, inDeg];
  exact Finset.sum_comm

/-
The weight of any theorem is at most the size of the library.
-/
theorem depWeight_le_card (D : V → V → Prop) [DecidableRel D] (a : V) :
    depWeight D a ≤ Fintype.card V := by
  exact Finset.card_le_univ _

/-
If the dependency relation is irreflexive (no theorem depends on itself), the
weight of any theorem is *strictly* less than the size of the library.
-/
theorem depWeight_lt_card_of_irrefl [Nonempty V] (D : V → V → Prop) [DecidableRel D]
    (hirr : ∀ a, ¬ D a a) (a : V) : depWeight D a < Fintype.card V := by
  exact Finset.card_lt_card ( Finset.filter_ssubset.mpr ⟨ a, by aesop ⟩ )

/-
There is a theorem of maximal weight (a "most foundational" theorem).
-/
theorem exists_max_depWeight [Nonempty V] (D : V → V → Prop) [DecidableRel D] :
    ∃ a, ∀ b, depWeight D b ≤ depWeight D a := by
  simpa using Finset.exists_max_image Finset.univ ( fun b => depWeight D b ) ( Finset.univ_nonempty )

/-
**Averaging bound.** The total weight is at most `card V` times the maximum
weight; hence the maximum weight is at least the average.
-/
theorem sum_depWeight_le_card_mul_max (D : V → V → Prop) [DecidableRel D] {a : V}
    (ha : ∀ b, depWeight D b ≤ depWeight D a) :
    ∑ b, depWeight D b ≤ Fintype.card V * depWeight D a := by
  exact le_trans ( Finset.sum_le_sum fun _ _ => ha _ ) ( by simp +decide )

/-
**Existence of anti-gravity theorems (pigeonhole).** Let `S` be the set of
theorems with short proofs (`plen a ≤ l0`). If the short-proof theorems together
carry at least `w0 * |S|` total weight, then some short-proof theorem has weight
`≥ w0`, i.e. an anti-gravity theorem exists.
-/
theorem exists_antigravity_of_short_heavy (D : V → V → Prop) [DecidableRel D]
    (plen : V → ℕ) (w0 l0 : ℕ)
    (hne : (univ.filter (fun a => plen a ≤ l0)).Nonempty)
    (hsum : (univ.filter (fun a => plen a ≤ l0)).card * w0
        ≤ ∑ a ∈ univ.filter (fun a => plen a ≤ l0), depWeight D a) :
    ∃ a, IsAntiGravity D plen w0 l0 a := by
  obtain ⟨a, ha⟩ : ∃ a ∈ Finset.filter (fun a => plen a ≤ l0) Finset.univ, ∀ b ∈ Finset.filter (fun a => plen a ≤ l0) Finset.univ, depWeight D b ≤ depWeight D a := by
    exact Finset.exists_max_image _ _ hne;
  refine' ⟨ a, _, _ ⟩ <;> simp_all;
  contrapose! hsum;
  exact lt_of_le_of_lt ( Finset.sum_le_sum fun x hx => ha.2 x <| Finset.mem_filter.mp hx |>.2 ) ( by simpa using mul_lt_mul_of_pos_left hsum <| Finset.card_pos.mpr hne )

/-
**Foundational theorems are heaviest.** Along a transitive dependency relation,
if `b` depends on `a` then every dependent of `b` is a dependent of `a`, so the
more foundational theorem `a` has at least as much weight as `b`.
-/
theorem depWeight_le_of_trans (D : V → V → Prop) [DecidableRel D]
    (htrans : Transitive D) {a b : V} (hab : D a b) :
    depWeight D b ≤ depWeight D a := by
  exact Finset.card_mono fun x hx => by aesop;

/-
The "linear library" on `Fin n`: theorem `j` depends on theorem `i` iff `i < j`.
The bottom theorem `0` is depended on by all `n - 1` later theorems.
-/
theorem linear_library_bottom_weight {n : ℕ} (hn : 0 < n) :
    depWeight (fun i j : Fin n => (i : ℕ) < (j : ℕ)) ⟨0, hn⟩ = n - 1 := by
  convert Finset.card_erase_of_mem ( Finset.mem_univ ( ⟨ 0, hn ⟩ : Fin n ) ) using 2;
  · convert rfl;
    refine' Finset.card_bij ( fun x hx => x ) _ _ _ <;> simp +decide;
    · exact fun a ha => Nat.pos_of_ne_zero fun h => ha <| Fin.ext h;
    · exact fun b hb => ne_of_gt hb;
  · simp +decide [ Finset.card_univ ]

/-
**Concrete non-vacuous witness.** In the linear library on `Fin n` with all
proofs of length `1`, the bottom theorem is anti-gravity for weight threshold
`n - 1` and length bound `1`. Anti-gravity theorems really do exist.
-/
theorem linear_library_antigravity {n : ℕ} (hn : 0 < n) :
    ∃ a, IsAntiGravity (fun i j : Fin n => (i : ℕ) < (j : ℕ))
      (fun _ => 1) (n - 1) 1 a := by
  exact ⟨ ⟨ 0, hn ⟩, by rw [ linear_library_bottom_weight hn ], by norm_num ⟩

/-
**Refutation of the universal "10%" prediction.** A library with no
dependencies at all contains *no* anti-gravity theorems (for any positive weight
threshold). Hence the prediction that a fixed positive fraction of theorems in
*any* library is anti-gravity is false in general.
-/
theorem no_deps_no_antigravity (plen : V → ℕ) {w0 l0 : ℕ} (hw : 1 ≤ w0) :
    ¬ ∃ a : V, IsAntiGravity (fun _ _ : V => False) plen w0 l0 a := by
  rintro ⟨ a, ha₁, ha₂ ⟩;
  contrapose! ha₁; unfold depWeight at *; aesop;

/-
The "grid library" on `Fin n × Fin m`: node `q` depends on node `p` iff `p` lies in
an earlier row (`p.1 < q.1`). A bottom-row node is depended on by every node in a
later row, i.e. by `(n-1) * m` nodes. This realizes the theme's `O(n^2)` weight with
`O(1)` proof length: a single foundational theorem supporting a two-dimensional grid
of downstream results.
-/
theorem grid_library_bottom_weight {n m : ℕ} (hn : 0 < n) (k : Fin m) :
    depWeight (fun p q : Fin n × Fin m => (p.1 : ℕ) < (q.1 : ℕ)) (⟨0, hn⟩, k)
      = (n - 1) * m := by
  unfold depWeight; simp +decide ;
  rw [ Finset.card_filter ];
  erw [ Finset.sum_product ] ; norm_num [ Finset.sum_ite ];
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ Fin.sum_univ_succ ]

/-
**Quadratic-weight anti-gravity witness.** In the grid library on `Fin n × Fin m`
with all proofs of length `1`, a bottom-row node is anti-gravity for the weight
threshold `(n-1) * m`, which is quadratic in the grid dimension while the proof
length stays `1`.
-/
theorem grid_library_antigravity {n m : ℕ} (hn : 0 < n) (hm : 0 < m) :
    ∃ a, IsAntiGravity (fun p q : Fin n × Fin m => (p.1 : ℕ) < (q.1 : ℕ))
      (fun _ => 1) ((n - 1) * m) 1 a := by
  refine' ⟨ ( ⟨ 0, hn ⟩, ⟨ 0, hm ⟩ ), _, _ ⟩ <;> simp_all +decide;
  convert grid_library_bottom_weight hn ⟨ 0, hm ⟩ |> le_of_eq;
  · convert grid_library_bottom_weight hn ⟨ 0, hm ⟩ |> Eq.symm;
  · convert grid_library_bottom_weight hn ⟨ 0, hm ⟩ using 1

end AntiGravity