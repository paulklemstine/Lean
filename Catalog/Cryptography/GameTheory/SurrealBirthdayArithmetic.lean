import Mathlib

/-!
# Surreal Birthday Arithmetic: Dyadic Valuations and Game Complexity

This file establishes a formally verified foundation for **birthday-stratified surreal
arithmetic**, connecting three domains:

1. **Combinatorial Game Theory** — PGame birthday as construction day
2. **Number Theory** — 2-adic valuations and dyadic rationals
3. **Analysis** — Density and approximation properties of dyadics

## Main Definitions

* `dyadicVal` — the dyadic valuation (2-adic valuation of the denominator) of a rational
* `IsDyadic` — predicate for rationals whose denominator is a power of 2
* `GameComplexity` — a novel two-dimensional complexity measure on PGames combining
  birthday (construction depth) with game depth (strategic depth)
* `BirthdayFiltration` — the monotone filtration of PGames by birthday

## Main Results

* `DyadicSubring` — dyadic rationals form a subring of ℚ
* `dyadic_dense_between` — between any two distinct rationals lies a dyadic rational
* `birthday_denomination_principle` — irreducible dyadics can't simplify (2-adic obstruction)
* `birthday_add_nadd` — birthday of sum = Hessenberg sum of birthdays
* `gameComplexity_neg` — game complexity is invariant under negation
* `dyadicVal_add_le` — dyadic valuation is subadditive
* `surreal_count_as_sum` — closed form for counting surreals by birthday

## References

* J.H. Conway, *On Numbers and Games*, Academic Press, 1976
* D.E. Knuth, *Surreal Numbers*, Addison-Wesley, 1974
-/

open SetTheory Finset BigOperators

namespace SurrealBirthdayArithmetic

/-! ## Part I: The Dyadic Subring of ℚ -/

/-- A rational number is **dyadic** if its denominator is a power of 2. -/
def IsDyadic (q : ℚ) : Prop :=
  ∃ n : ℕ, q.den ∣ 2 ^ n

theorem isDyadic_zero : IsDyadic 0 := ⟨0, by simp⟩

theorem isDyadic_one : IsDyadic 1 := ⟨0, by simp⟩

theorem isDyadic_intCast (a : ℤ) : IsDyadic (a : ℚ) :=
  ⟨0, by simp⟩

theorem isDyadic_neg {q : ℚ} (hq : IsDyadic q) : IsDyadic (-q) := by
  obtain ⟨n, hn⟩ := hq; exact ⟨n, by rwa [Rat.neg_den]⟩

theorem isDyadic_add {p q : ℚ} (hp : IsDyadic p) (hq : IsDyadic q) :
    IsDyadic (p + q) := by
  obtain ⟨m, hm⟩ := hp; obtain ⟨n, hn⟩ := hq
  refine ⟨m + n, dvd_trans (Rat.add_den_dvd p q) ?_⟩
  rw [pow_add]
  exact mul_dvd_mul (dvd_trans hm (Nat.pow_dvd_pow 2 (by omega)))
                     (dvd_trans hn (Nat.pow_dvd_pow 2 (by omega)))

theorem isDyadic_mul {p q : ℚ} (hp : IsDyadic p) (hq : IsDyadic q) :
    IsDyadic (p * q) := by
  obtain ⟨m, hm⟩ := hp; obtain ⟨n, hn⟩ := hq
  exact ⟨m + n, dvd_trans (Rat.mul_den_dvd p q) (by rw [pow_add]; exact mul_dvd_mul hm hn)⟩

theorem isDyadic_sub {p q : ℚ} (hp : IsDyadic p) (hq : IsDyadic q) :
    IsDyadic (p - q) := by
  rw [sub_eq_add_neg]; exact isDyadic_add hp (isDyadic_neg hq)

/-- The **dyadic subring** ℤ[1/2] ⊆ ℚ. -/
noncomputable def DyadicSubring : Subring ℚ where
  carrier := {q | IsDyadic q}
  mul_mem' := isDyadic_mul
  one_mem' := isDyadic_one
  add_mem' := isDyadic_add
  zero_mem' := isDyadic_zero
  neg_mem' := isDyadic_neg

theorem isDyadic_half : IsDyadic (1/2 : ℚ) := ⟨1, by norm_num⟩

/-! ## Part II: The Dyadic Valuation -/

/-- The dyadic valuation: the 2-adic valuation of the denominator. -/
noncomputable def dyadicVal (q : ℚ) : ℕ := padicValNat 2 q.den

theorem dyadicVal_intCast (a : ℤ) : dyadicVal (a : ℚ) = 0 := by
  simp [dyadicVal, Rat.den_intCast]

theorem dyadicVal_zero : dyadicVal 0 = 0 := by
  simp [dyadicVal]

/-! ## Part III: Dyadic Approximation and Density -/

/-
**Dyadic Approximation**: Every rational can be approximated by a dyadic
rational to within `1/2^n`.
-/
theorem dyadic_approx_bound (q : ℚ) (n : ℕ) :
    ∃ d : ℚ, IsDyadic d ∧ |q - d| ≤ 1 / (2 ^ n : ℚ) := by
      by_contra h;
      refine' h ⟨ ⌊q * 2 ^ n⌋ / 2 ^ n, _, _ ⟩;
      · use n;
        norm_num [ div_eq_mul_inv, Rat.mul_den ];
        exact Nat.div_dvd_of_dvd <| Nat.gcd_dvd_right _ _;
      · rw [ abs_le ];
        field_simp;
        constructor <;> linarith [ Int.floor_le ( 2 ^ n * q ), Int.lt_floor_add_one ( 2 ^ n * q ) ]

/-
**Dyadic Density**: Between any two distinct rationals lies a dyadic rational.
-/
theorem dyadic_dense_between {a b : ℚ} (hab : a < b) :
    ∃ d : ℚ, IsDyadic d ∧ a < d ∧ d < b := by
      -- Choose n large enough that 1/2^n < b - a.
      obtain ⟨n, hn⟩ : ∃ n : ℕ, (1 / 2 ^ n : ℚ) < b - a := by
        simpa using exists_pow_lt_of_lt_one ( sub_pos.mpr hab ) one_half_lt_one;
      -- Let $d = \frac{\lfloor a \cdot 2^n \rfloor + 1}{2^n}$.
      use (⌊a * 2 ^ n⌋ + 1) / 2 ^ n;
      refine' ⟨ ⟨ n, _ ⟩, _, _ ⟩;
      · norm_num [ div_eq_mul_inv, Rat.mul_den ];
        exact Nat.div_dvd_of_dvd <| Nat.gcd_dvd_right _ _;
      · rw [ lt_div_iff₀ ] <;> first | positivity | linarith [ Int.lt_floor_add_one ( a * 2 ^ n ) ] ;
      · rw [ div_lt_iff₀ ] at * <;> first | positivity | linarith [ Int.floor_le ( a * 2 ^ n ), Int.lt_floor_add_one ( a * 2 ^ n ) ] ;

/-! ## Part IV: Birthday Arithmetic -/

/-- Birthday of a sum = Hessenberg sum of birthdays. -/
theorem birthday_add_nadd (x y : PGame) :
    (x + y).birthday = x.birthday.nadd y.birthday :=
  PGame.birthday_add x y

/-- Negation preserves birthday. -/
theorem birthday_neg_eq (x : PGame) : (-x).birthday = x.birthday :=
  PGame.birthday_neg x

/-
For natural number birthdays, birthday of sum ≤ sum of birthdays.
-/
theorem birthday_add_le_of_nat {x y : PGame} {m n : ℕ}
    (hx : x.birthday ≤ m) (hy : y.birthday ≤ n) :
    (x + y).birthday ≤ ↑(m + n) := by
      rw [ PGame.birthday_add ];
      refine' le_trans ( Ordinal.nadd_le_nadd hx hy ) _;
      norm_num [ Ordinal.nadd ]

/-! ## Part V: Game Complexity — A Novel Two-Dimensional Measure -/

/-- **Game Depth**: The height of the game tree. -/
noncomputable def gameDepth : PGame → Ordinal
  | PGame.mk _α _β L R =>
    max
      (Ordinal.lsub fun a => gameDepth (L a) + 1)
      (Ordinal.lsub fun b => gameDepth (R b) + 1)

/-- **Game Complexity**: `(birthday, depth)` — a two-dimensional invariant. -/
noncomputable def GameComplexity (x : PGame) : Ordinal × Ordinal :=
  (x.birthday, gameDepth x)

theorem gameDepth_zero : gameDepth 0 = 0 := by
  change gameDepth (PGame.mk PEmpty PEmpty PEmpty.elim PEmpty.elim) = 0
  unfold gameDepth
  simp [Ordinal.lsub]

theorem gameComplexity_zero : GameComplexity (0 : PGame) = (0, 0) := by
  simp [GameComplexity, PGame.birthday_zero, gameDepth_zero]

/-
Game depth is invariant under negation.
-/
theorem gameDepth_neg (x : PGame) : gameDepth (-x) = gameDepth x := by
  induction' x with x;
  -- By definition of game depth, we can write
  simp [gameDepth];
  grind

/-- Both complexity axes are preserved under negation. -/
theorem gameComplexity_neg (x : PGame) : GameComplexity (-x) = GameComplexity x := by
  simp [GameComplexity, PGame.birthday_neg, gameDepth_neg]

/-! ## Part VI: Birthday Filtration -/

/-- The set of all PGames born by ordinal `α`. -/
def BirthdayFiltration (α : Ordinal) : Set PGame :=
  {x : PGame | x.birthday ≤ α}

theorem birthdayFiltration_mono {α β : Ordinal} (h : α ≤ β) :
    BirthdayFiltration α ⊆ BirthdayFiltration β :=
  fun _ hx => le_trans hx h

theorem zero_mem_birthdayFiltration (α : Ordinal) :
    (0 : PGame) ∈ BirthdayFiltration α := by
  simp [BirthdayFiltration, PGame.birthday_zero]

theorem neg_mem_birthdayFiltration {α : Ordinal} {x : PGame}
    (hx : x ∈ BirthdayFiltration α) : -x ∈ BirthdayFiltration α := by
  simp [BirthdayFiltration, PGame.birthday_neg]; exact hx

/-- The filtration is closed under addition (with Hessenberg sum bound). -/
theorem add_mem_birthdayFiltration {α β : Ordinal} {x y : PGame}
    (hx : x ∈ BirthdayFiltration α) (hy : y ∈ BirthdayFiltration β) :
    x + y ∈ BirthdayFiltration (α.nadd β) := by
  simp only [BirthdayFiltration, Set.mem_setOf_eq, PGame.birthday_add]
  exact Ordinal.nadd_le_nadd hx hy

/-! ## Part VII: The Surreal Counting Function -/

def surreal_count (n : ℕ) : ℕ := 2 ^ (n + 1) - 1

def new_surreals (n : ℕ) : ℕ := if n = 0 then 1 else 2 ^ n

theorem surreal_count_recurrence (n : ℕ) :
    surreal_count (n + 1) = 2 * surreal_count n + 1 := by
  unfold surreal_count
  have h : 1 ≤ 2 ^ (n + 1) := Nat.one_le_pow _ _ (by norm_num)
  omega

/-- The total count equals the sum of new surreals at each level. -/
theorem surreal_count_as_sum (n : ℕ) :
    surreal_count n = ∑ k ∈ Finset.range (n + 1), new_surreals k := by
  induction n with
  | zero => simp [surreal_count, new_surreals]
  | succ n ih =>
    rw [Finset.sum_range_succ, ← ih, surreal_count, surreal_count, new_surreals]
    simp only [Nat.succ_ne_zero, ↓reduceIte]
    have h1 : 1 ≤ 2 ^ (n + 1) := Nat.one_le_pow _ _ (by norm_num)
    omega

theorem surreal_count_strictly_increasing (n : ℕ) :
    surreal_count n < surreal_count (n + 1) := by
  rw [surreal_count_recurrence]
  unfold surreal_count
  have h : 1 ≤ 2 ^ (n + 1) := Nat.one_le_pow _ _ (by norm_num)
  omega

/-! ## Part VIII: The Birthday–Denomination Correspondence -/

/-
**Birthday–Denomination Principle**: If `m` is odd, then `m/2^n` cannot be
written as `a/2^k` for any `k < n`.
-/
theorem birthday_denomination_principle (m : ℤ) (n : ℕ) (hodd : ¬ (2 : ℤ) ∣ m) :
    ∀ k : ℕ, k < n → ¬(∃ a : ℤ, (m : ℚ) / 2 ^ n = (a : ℚ) / 2 ^ k) := by
      intro k hk_lt_n
      rintro ⟨a, h_eq⟩
      have h_cross : m * 2 ^ k = a * 2 ^ n := by
        rw [ div_eq_div_iff ] at h_eq <;> norm_cast at * <;> aesop;
      -- Since $k < n$, we can divide both sides by $2^k$ to get $m = a * 2^{n-k}$.
      have h_div : m = a * 2 ^ (n - k) := by
        exact mul_left_cancel₀ ( pow_ne_zero k two_ne_zero ) ( by rw [ show ( 2 : ℤ ) ^ n = 2 ^ ( n - k ) * 2 ^ k by rw [ ← pow_add, Nat.sub_add_cancel hk_lt_n.le ] ] at h_cross; linarith );
      exact hodd ( h_div.symm ▸ dvd_mul_of_dvd_right ( dvd_pow_self _ ( Nat.sub_ne_zero_of_lt hk_lt_n ) ) _ )

/-
If `m` is even, then `m/2^(n+1)` simplifies.
-/
theorem even_numerator_simplifies (m : ℤ) (n : ℕ) (heven : (2 : ℤ) ∣ m) :
    ∃ a : ℤ, (m : ℚ) / 2 ^ (n + 1) = (a : ℚ) / 2 ^ n := by
      obtain ⟨ k, hk ⟩ := heven; use k; push_cast [ hk ] ; ring;

/-! ## Part IX: Dyadic Valuation Subadditivity -/

/-
The dyadic valuation is subadditive.
-/
theorem dyadicVal_add_le (p q : ℚ) :
    dyadicVal (p + q) ≤ dyadicVal p + dyadicVal q := by
      unfold dyadicVal;
      rw [ ← padicValNat.mul ];
      · exact Nat.factorization_le_iff_dvd ( by aesop ) ( by aesop ) |>.2 ( Rat.add_den_dvd _ _ ) 2;
      · exact p.pos.ne';
      · exact q.pos.ne'

/-
The dyadic valuation of a product is bounded.
-/
theorem dyadicVal_mul_le (p q : ℚ) :
    dyadicVal (p * q) ≤ dyadicVal p + dyadicVal q := by
      -- By definition of dyadic valuation, we know that
      unfold dyadicVal;
      rw [ ← padicValNat.mul ];
      · refine' Nat.factorization_le_iff_dvd _ _ |>.2 _ 2;
        · exact Rat.den_nz _;
        · exact mul_ne_zero p.den_nz q.den_nz;
        · exact Rat.mul_den_dvd p q;
      · exact p.pos.ne';
      · exact q.pos.ne'

/-! ## Part X: The Dyadic Approximation Sequence -/

def dyadicSeq (n : ℕ) : ℚ := 1 / (2 ^ n : ℕ)

theorem dyadicSeq_pos (n : ℕ) : 0 < dyadicSeq n := by
  simp [dyadicSeq]

/-
The dyadic approximation sequence converges to 0 in ℝ.
-/
theorem dyadicSeq_tendsto_zero :
    Filter.Tendsto (fun n => ((dyadicSeq n : ℚ) : ℝ)) Filter.atTop (nhds 0) := by
      convert tendsto_inv_atTop_zero.comp ( tendsto_pow_atTop_atTop_of_one_lt one_lt_two ) using 1;
      all_goals try infer_instance;
      ext; norm_num [ dyadicSeq ] ;

/-! ## Part XI: Conjecture -/

/-- The birthday hierarchy conjecture: every dyadic rational can be realized as a
numeric PGame with finite birthday equal to its dyadic valuation. -/
def BirthdayValuationConjecture : Prop :=
  ∀ (q : ℚ), IsDyadic q →
    ∃ (x : PGame.{0}), x.Numeric ∧ x.birthday = ↑(dyadicVal q)

end SurrealBirthdayArithmetic