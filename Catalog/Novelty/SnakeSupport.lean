/-
# Strict monotonicity of `maxLen`, and full support of maximal snakes

`Novelty/SnakeSymmetry.lean` introduced the **support** `Snake.dirs` of a snake
(the set of coordinates it ever flips) and the dimension-reduction theorem
`Snake.restrict`, which turns a snake of support size `k` into a snake of the
cube `Q k`; hence `Snake.length_le_maxLen_dirs : L ≤ maxLen (#s.dirs)`.

That cycle left open the question (Conjecture 4 of `FUTURE_DIRECTIONS.md`)
whether a *maximal* snake must use every coordinate, and recorded that this is
equivalent to `maxLen` being **strictly** monotone.  This file proves both.

The two missing ingredients were the degenerate dimensions:

* `maxLen 0 = 0`, because `Q 0` is a single vertex with no edges, and
* `maxLen 1 = 1`, from the explicit one-edge snake `snake1` of `Q 1` together
  with the cardinality ceiling `L + 1 ≤ 2 ^ n`.

With `maxLen 2 = 2`, `maxLen 3 = 4` from the catalog and
`maxLen_succ_ge_two : 3 ≤ n → maxLen n + 2 ≤ maxLen (n + 1)`, every consecutive
pair is strict, so `maxLen` is strictly monotone (`maxLen_strictMono`) and in
particular injective: the maximal snake length *determines* the dimension.

Full support then follows with no further combinatorics: a snake of length
`maxLen n` with support of size `k` would satisfy
`maxLen n ≤ maxLen k ≤ maxLen n`, forcing `maxLen k = maxLen n` and hence
`k = n` by injectivity.  More generally any snake longer than `maxLen (n - 1)`
already has full support (`Snake.dirs_eq_univ_of_long`).
-/
import Mathlib
import Computation.SnakeInTheBox
import Computation.SnakeMax
import Novelty.SnakeSymmetry

namespace SnakeInTheBox

open Finset

variable {n L : ℕ}

/-! ## Step 1: the two degenerate dimensions -/

/-- `Q 0` is a single vertex and has no edges, so the only snake has length zero. -/
theorem maxLen_zero : maxLen 0 = 0 := by
  obtain ⟨s⟩ := exists_snake_maxLen 0
  have h := s.card_le_pow
  have h2 : (2 : ℕ) ^ 0 = 1 := rfl
  omega

/-- The single edge of `Q 1`. -/
def snake1 : Snake 1 1 where
  v := fun i => fun _ => decide (i = 1)
  step := by
    intro i hi
    have hi0 : i = 0 := by omega
    subst hi0
    refine ⟨0, ?_⟩
    funext j
    fin_cases j
    simp [flipAt]
  chord := by
    intro i j hj hij
    exact absurd hj (by omega)

/-- `Q 1` is a single edge: the longest snake has one edge. -/
theorem maxLen_one : maxLen 1 = 1 := by
  have hle : maxLen 1 ≤ 1 := by
    obtain ⟨s⟩ := exists_snake_maxLen 1
    have h := s.card_le_pow
    have h2 : (2 : ℕ) ^ 1 = 2 := rfl
    omega
  have hge : 1 ≤ maxLen 1 := le_maxLen snake1
  omega

/-! ## Step 2: strict monotonicity -/

/-- Every extra dimension gives a strictly longer maximal snake.  For `n ≥ 3`
this is the two-edge lift `maxLen_succ_ge_two`; the three remaining cases are the
exact values `maxLen 0 = 0`, `maxLen 1 = 1`, `maxLen 2 = 2`, `maxLen 3 = 4`. -/
theorem maxLen_lt_succ (n : ℕ) : maxLen n < maxLen (n + 1) := by
  rcases le_or_gt 3 n with h | h
  · have := maxLen_succ_ge_two h
    omega
  · interval_cases n
    · rw [maxLen_zero, maxLen_one]; norm_num
    · rw [maxLen_one, maxLen_two]; norm_num
    · rw [maxLen_two, maxLen_three]; norm_num

/-- **The maximal snake length is strictly monotone in the dimension.**  There is
no plateau: `Q (n+1)` always admits a strictly longer chordless induced path than
`Q n`. -/
theorem maxLen_strictMono : StrictMono maxLen :=
  strictMono_nat_of_lt_succ maxLen_lt_succ

/-- The maximal snake length determines the dimension. -/
theorem maxLen_injective : Function.Injective maxLen :=
  maxLen_strictMono.injective

/-- Comparison of maximal lengths detects comparison of dimensions. -/
theorem maxLen_lt_maxLen_iff {m k : ℕ} : maxLen m < maxLen k ↔ m < k :=
  maxLen_strictMono.lt_iff_lt

/-- Every dimension is used: the dimension is at most the maximal snake length. -/
theorem dim_le_maxLen (n : ℕ) : n ≤ maxLen n := by
  induction n with
  | zero => simp [maxLen_zero]
  | succ m ih =>
      have := maxLen_lt_succ m
      omega

/-! ## Step 3: full support -/

/-- A snake longer than the maximal length available in `k` dimensions must move
in more than `k` directions. -/
theorem Snake.lt_card_dirs (s : Snake n L) {k : ℕ} (h : maxLen k < L) : k < #s.dirs := by
  by_contra hk
  have hk' : #s.dirs ≤ k := by omega
  have h1 : L ≤ maxLen (#s.dirs) := s.length_le_maxLen_dirs
  have h2 : maxLen (#s.dirs) ≤ maxLen k := maxLen_strictMono.monotone hk'
  omega

/-- **Long snakes have full support.**  A snake of `Q n` longer than the maximal
snake of `Q (n-1)` flips every one of the `n` coordinates. -/
theorem Snake.dirs_eq_univ_of_long (s : Snake n L) (h : maxLen (n - 1) < L) :
    s.dirs = univ := by
  have hlt : n - 1 < #s.dirs := s.lt_card_dirs h
  have hle : #s.dirs ≤ n := s.card_dirs_le
  have hn : 1 ≤ n := by
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · have h0 : L ≤ maxLen 0 := le_maxLen s
      have hz : (0 : ℕ) - 1 = 0 := rfl
      rw [hz, maxLen_zero] at h
      rw [maxLen_zero] at h0
      omega
    · exact hn
  have hcard : #s.dirs = Fintype.card (Fin n) := by
    simp only [Fintype.card_fin]
    omega
  exact Finset.eq_univ_of_card _ hcard

/-- **Maximal snakes have full support** (Conjecture 4 of the previous cycle).
Every snake of `Q n` attaining the maximal length `maxLen n` flips all `n`
coordinates; equivalently, it does not live inside any proper subcube. -/
theorem Snake.dirs_eq_univ_of_maxLen (s : Snake n (maxLen n)) : s.dirs = univ := by
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · exact Finset.eq_univ_of_forall (fun c => c.elim0)
  · refine s.dirs_eq_univ_of_long ?_
    have : n - 1 < n := by omega
    exact maxLen_strictMono this

/-- The support size of a maximal snake is the ambient dimension. -/
theorem Snake.card_dirs_eq_of_maxLen (s : Snake n (maxLen n)) : #s.dirs = n := by
  rw [s.dirs_eq_univ_of_maxLen]
  simp

/-- **Existence form.**  Every cube carries a maximal snake that genuinely uses
all of its coordinates. -/
theorem exists_snake_full_support (n : ℕ) :
    ∃ s : Snake n (maxLen n), s.dirs = univ := by
  obtain ⟨s⟩ := exists_snake_maxLen n
  exact ⟨s, s.dirs_eq_univ_of_maxLen⟩

/-! ## Step 4: the converse, and the equivalence -/

/-- An embedded snake only ever flips the coordinates of the smaller cube. -/
theorem Snake.dirs_embed_lt {m : ℕ} (s : Snake m L) (hmn : m ≤ n) :
    ∀ c ∈ (s.embed hmn).dirs, (c : ℕ) < m := by
  intro c hc
  obtain ⟨i, hi, hne⟩ := Snake.mem_dirs.1 hc
  by_contra hcm
  apply hne
  show extend m n (s.v i) c = extend m n (s.v (i + 1)) c
  simp [extend, hcm]

/-- Hence the support of an embedded snake has at most `m` elements. -/
theorem Snake.card_dirs_embed_le {m : ℕ} (s : Snake m L) (hmn : m ≤ n) :
    #(s.embed hmn).dirs ≤ m := by
  have h : #(s.embed hmn).dirs ≤ #(Finset.range m) :=
    Finset.card_le_card_of_injOn (fun c : Fin n => (c : ℕ))
      (fun c hc => Finset.mem_range.2 (s.dirs_embed_lt hmn c hc))
      (fun a _ b _ hab => Fin.ext hab)
  simpa using h

/-- The converse direction of the equivalence recorded in the previous cycle: if
every maximal snake has full support, then `maxLen` is strictly monotone.  A
plateau `maxLen (k+1) = maxLen k` would be witnessed by a maximal snake of
`Q (k+1)` obtained by embedding a maximal snake of `Q k`, and such a snake never
flips the last coordinate. -/
theorem maxLen_lt_succ_of_full_support
    (H : ∀ (N M : ℕ) (s : Snake N M), M = maxLen N → #s.dirs = N) (k : ℕ) :
    maxLen k < maxLen (k + 1) := by
  have hmono : maxLen k ≤ maxLen (k + 1) := maxLen_mono (by omega)
  rcases lt_or_eq_of_le hmono with h | h
  · exact h
  · exfalso
    obtain ⟨t⟩ := exists_snake_maxLen k
    have hk1 : k ≤ k + 1 := by omega
    have hcard := H (k + 1) (maxLen k) (t.embed hk1) h
    have hle : #(t.embed hk1).dirs ≤ k := t.card_dirs_embed_le hk1
    omega

/-- **The equivalence.**  "Every maximal snake has full support" and "`maxLen` is
strictly monotone" are the same statement — and both are true. -/
theorem full_support_iff_strictMono :
    (∀ (N M : ℕ) (s : Snake N M), M = maxLen N → #s.dirs = N) ↔ StrictMono maxLen := by
  constructor
  · intro H
    exact strictMono_nat_of_lt_succ (maxLen_lt_succ_of_full_support H)
  · intro _ N M s hM
    subst hM
    exact s.card_dirs_eq_of_maxLen

/-- **Summary.**  `maxLen` is strictly monotone, hence injective, and every
maximal snake uses every coordinate of its cube. -/
theorem maxLen_support_summary (n : ℕ) :
    StrictMono maxLen ∧ Function.Injective maxLen ∧
      ∀ s : Snake n (maxLen n), #s.dirs = n :=
  ⟨maxLen_strictMono, maxLen_injective, fun s => s.card_dirs_eq_of_maxLen⟩

end SnakeInTheBox