import Mathlib

/-!
# The birthday-bound hierarchy and its collapse

Collision-based factoring methods (sumset collisions `a + b ≡ c + d`, 3SUM
collisions `a + b + c ≡ d + e + f`, and more generally `r`-SUM collisions) all
consist of evaluating a residue map on a search space and waiting for a
repeated value.  Increasing the arity `r` makes the search space grow like
`k^r`, so the *number of stored elements* `k` needed for a guaranteed collision
drops from `p^{1/2}` (`r = 2`) to `p^{1/3}` (`r = 3`) and beyond.

The main theorem of this file, `collision_threshold_iff`, says that this is an
illusion as far as *work* is concerned: for a search space `S` and modulus `p`,
a collision is guaranteed **iff** `p < S.card`, a criterion that mentions only
the cardinality of the search space — i.e. the number of tuples inspected —
and never the arity `r`.  The threshold is exactly `p + 1` for every scheme.

Combined with `p ≥ √N` for the larger factor of `N = p * q`, every member of
the hierarchy must inspect more than `√N` tuples: the exponent improves, the
barrier does not move.

Main results:

* `exists_collision_of_card_lt` — pigeonhole (upper bound side).
* `exists_injOn_of_card_le` — adversarial residue map (lower bound side).
* `collision_threshold_iff` — the threshold is `p + 1`, independent of arity.
* `exists_tuple_sum_collision` — the `r`-SUM instance: `p < k ^ r` suffices.
* `tuple_scheme_cost_gt_sqrt` — every scheme must inspect more than `√N` tuples.
* `cube_threshold_997`, `square_threshold_997`, `exponent_gap_997` — the
  quantitative `p^{1/2} → p^{1/3}` improvement in stored elements at `p = 997`.
-/

namespace BirthdayHierarchy

open Finset

variable {α : Type*}

/-! ## Pigeonhole: large search spaces always collide -/

/-- **Birthday bound (upper side).**  If the search space `S` has more than `p`
elements, then *every* residue map `f` with values in `{0, …, p-1}` has a
collision on `S`. -/
theorem exists_collision_of_card_lt {p : ℕ} {S : Finset α} (hS : p < S.card)
    (f : α → ℕ) (hf : ∀ x, f x < p) :
    ∃ x ∈ S, ∃ y ∈ S, x ≠ y ∧ f x = f y := by
  refine Finset.exists_ne_map_eq_of_card_lt_of_maps_to (t := Finset.range p) ?_ ?_
  · simpa using hS
  · intro x _
    simp [hf x]

/-- **Structured-image collisions (the "singular moduli" row).**  If the values
of the scheme are known to lie in a structured subset `B` of the residues — for
instance the `h`-element image of a class-group-indexed evaluation, so
`|B| ≈ p / h` — then a collision appears already after `|B| + 1` evaluations
rather than `p + 1`.  The threshold is always the size of the *value set*, and
this is the general form of every row of the birthday-bound hierarchy. -/
theorem exists_collision_of_image_card_lt {S : Finset α} {B : Finset ℕ}
    (f : α → ℕ) (hmaps : ∀ x ∈ S, f x ∈ B) (h : B.card < S.card) :
    ∃ x ∈ S, ∃ y ∈ S, x ≠ y ∧ f x = f y :=
  Finset.exists_ne_map_eq_of_card_lt_of_maps_to h (fun x hx => hmaps x hx)

/-! ## Adversary: small search spaces need not collide -/

/-- **Birthday bound (lower side).**  If the search space has at most `p`
elements, an adversary can choose a residue map with values in `{0, …, p-1}`
that is injective on it: no collision-based scheme can be *guaranteed* to
succeed. -/
theorem exists_injOn_of_card_le {p : ℕ} {S : Finset α} (hp : 0 < p)
    (hS : S.card ≤ p) :
    ∃ f : α → ℕ, (∀ x, f x < p) ∧ ∀ x ∈ S, ∀ y ∈ S, f x = f y → x = y := by
  classical
  have hcard : Fintype.card {x // x ∈ S} ≤ Fintype.card (Fin p) := by
    simpa using hS
  obtain ⟨e⟩ := Function.Embedding.nonempty_of_card_le hcard
  refine ⟨fun x => if h : x ∈ S then (e ⟨x, h⟩ : ℕ) else 0, ?_, ?_⟩
  · intro x
    by_cases h : x ∈ S
    · simp only [h, dif_pos]; exact (e ⟨x, h⟩).isLt
    · simpa [h] using hp
  · intro x hx y hy hxy
    simp only [hx, hy, dif_pos] at hxy
    have : e ⟨x, hx⟩ = e ⟨y, hy⟩ := Fin.val_injective hxy
    exact congrArg Subtype.val (e.injective this)

/-! ## The collapse: the threshold is the *size of the search space* -/

/-- **Birthday-bound hierarchy collapse.**  A collision is guaranteed on a
search space `S` (against every residue map modulo `p`) if and only if
`p < S.card`.  The criterion involves only the number of inspected objects, so
all members of the hierarchy — sumset, 3SUM, `r`-SUM, or any other collision
scheme — have exactly the same threshold `p + 1` on total work; only the way
the search space is *generated* from `k` stored elements differs. -/
theorem collision_threshold_iff {p : ℕ} (hp : 0 < p) (S : Finset α) :
    ((∀ f : α → ℕ, (∀ x, f x < p) → ∃ x ∈ S, ∃ y ∈ S, x ≠ y ∧ f x = f y) ↔
      p < S.card) := by
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    obtain ⟨f, hf, hinj⟩ := exists_injOn_of_card_le hp hcon
    obtain ⟨x, hx, y, hy, hne, heq⟩ := h f hf
    exact hne (hinj x hx y hy heq)
  · intro h f hf
    exact exists_collision_of_card_lt h f hf

/-- The exact work threshold: `p + 1` inspected objects are necessary and
sufficient, whatever the collision scheme. -/
theorem collision_threshold_eq_succ {p : ℕ} (hp : 0 < p) (S : Finset α) :
    ((∀ f : α → ℕ, (∀ x, f x < p) → ∃ x ∈ S, ∃ y ∈ S, x ≠ y ∧ f x = f y) ↔
      p + 1 ≤ S.card) := collision_threshold_iff hp S

/-! ## The `r`-SUM instance of the hierarchy -/

/-- The search space of the `r`-SUM scheme built from a set `A`: all functions
`Fin r → A`, i.e. all `r`-tuples of elements of `A`. -/
noncomputable def tupleSpace (r : ℕ) (A : Finset ℕ) : Finset (Fin r → ℕ) :=
  Fintype.piFinset (fun _ : Fin r => A)

@[simp] theorem card_tupleSpace (r : ℕ) (A : Finset ℕ) :
    (tupleSpace r A).card = A.card ^ r := by
  simp [tupleSpace]

/-- **`r`-SUM collision.**  If `p < k ^ r` where `k = |A|`, then two distinct
`r`-tuples over `A` have congruent sums modulo `p`.  For `r = 2` this is the
sumset collision `a + b ≡ c + d`, for `r = 3` the 3SUM collision
`a + b + c ≡ d + e + f`. -/
theorem exists_tuple_sum_collision {p r : ℕ} (hp : 0 < p) (A : Finset ℕ)
    (h : p < A.card ^ r) :
    ∃ u ∈ tupleSpace r A, ∃ v ∈ tupleSpace r A, u ≠ v ∧
      (∑ i, u i) % p = (∑ i, v i) % p := by
  refine exists_collision_of_card_lt (S := tupleSpace r A) (by simpa using h)
    (fun u => (∑ i, u i) % p) (fun u => Nat.mod_lt _ hp)

/-- **Stored elements needed at arity `r`.**  Guaranteeing an `r`-SUM collision
requires `k ^ r > p`, i.e. `k` of order `p^{1/r}`: the exponent improves with
the arity.  Contrapositive form: if `k ^ r ≤ p` an adversary defeats the
scheme. -/
theorem rsum_adversary {p r : ℕ} (hp : 0 < p) (A : Finset ℕ)
    (h : A.card ^ r ≤ p) :
    ∃ f : (Fin r → ℕ) → ℕ, (∀ u, f u < p) ∧
      ∀ u ∈ tupleSpace r A, ∀ v ∈ tupleSpace r A, f u = f v → u = v :=
  exists_injOn_of_card_le hp (by simpa using h)

/-! ## The `√N` barrier -/

/-- For a semiprime `N = p * q` with `q ≤ p`, the larger factor is at least
`√N`. -/
theorem sqrt_le_of_semiprime {p q : ℕ} (hqp : q ≤ p) :
    Nat.sqrt (p * q) ≤ p := by
  have : p * q ≤ p * p := Nat.mul_le_mul_left p hqp
  calc Nat.sqrt (p * q) ≤ Nat.sqrt (p * p) := Nat.sqrt_le_sqrt this
    _ = p := by rw [← Nat.pow_two, Nat.sqrt_eq']

/-- **The barrier is arity-independent.**  Any collision scheme whose search
space `S` is guaranteed to produce a collision modulo the larger prime factor
`p` of `N = p * q` must inspect more than `√N` objects. -/
theorem cost_gt_sqrt {p q : ℕ} {S : Finset α} (hp : 0 < p) (hqp : q ≤ p)
    (h : ∀ f : α → ℕ, (∀ x, f x < p) → ∃ x ∈ S, ∃ y ∈ S, x ≠ y ∧ f x = f y) :
    Nat.sqrt (p * q) < S.card :=
  lt_of_le_of_lt (sqrt_le_of_semiprime hqp) ((collision_threshold_iff hp S).mp h)

/-- **`r`-SUM version of the barrier.**  Whatever the arity `r`, a guaranteed
`r`-SUM scheme over `A` inspects `|A| ^ r > √N` tuples. -/
theorem tuple_scheme_cost_gt_sqrt {p q r : ℕ} {A : Finset ℕ}
    (hqp : q ≤ p) (h : p < A.card ^ r) :
    Nat.sqrt (p * q) < A.card ^ r :=
  lt_of_le_of_lt (sqrt_le_of_semiprime hqp) h

/-! ## The exponent really does improve (stored elements) -/

/-- Enlarging the arity can only help the *storage* requirement: a value of `k`
that suffices at arity `r` also suffices at any larger arity. -/
theorem storage_monotone {p k r r' : ℕ} (hk : 1 ≤ k) (hrr : r ≤ r')
    (h : p < k ^ r) : p < k ^ r' :=
  lt_of_lt_of_le h (Nat.pow_le_pow_right hk hrr)

/-- At `p = 997`, a 3SUM scheme needs `k ≥ 10` stored elements. -/
theorem cube_threshold_997 (k : ℕ) : 997 < k ^ 3 ↔ 10 ≤ k := by
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    have : k ^ 3 ≤ 9 ^ 3 := Nat.pow_le_pow_left (by omega) 3
    omega
  · intro h
    have : (10 : ℕ) ^ 3 ≤ k ^ 3 := Nat.pow_le_pow_left h 3
    omega

/-- At `p = 997`, a sumset scheme needs `k ≥ 32` stored elements. -/
theorem square_threshold_997 (k : ℕ) : 997 < k ^ 2 ↔ 32 ≤ k := by
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    have : k ^ 2 ≤ 31 ^ 2 := Nat.pow_le_pow_left (by omega) 2
    omega
  · intro h
    have : (32 : ℕ) ^ 2 ≤ k ^ 2 := Nat.pow_le_pow_left h 2
    omega

/-- **Exponent gap.**  At `p = 997` the 3SUM scheme stores `10` elements where
the sumset scheme needs `32` — the `p^{1/2} → p^{1/3}` improvement — yet both
inspect more than `997` tuples, and `10 ^ 3 = 1000 > 997` shows the work is the
*same* order. -/
theorem exponent_gap_997 :
    (∀ k, 997 < k ^ 3 ↔ 10 ≤ k) ∧ (∀ k, 997 < k ^ 2 ↔ 32 ≤ k) ∧
      10 < 32 ∧ 997 < 10 ^ 3 ∧ 997 < 32 ^ 2 :=
  ⟨cube_threshold_997, square_threshold_997, by norm_num, by norm_num, by norm_num⟩

end BirthdayHierarchy