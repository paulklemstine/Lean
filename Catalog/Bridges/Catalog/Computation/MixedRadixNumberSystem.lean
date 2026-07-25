import Mathlib

/-!
# Mixed-Radix Number Systems ("Beyond Base-N")

This file generalizes the factorial number system (see
`Catalog/Computation/FactorialNumberSystem.lean`) to **arbitrary mixed-radix
positional systems**.  Fix a sequence of *bases* `b : ℕ → ℕ`.  A length-`k`
mixed-radix value of a digit function `c : ℕ → ℕ` is

`value b c k = ∑_{i < k} c i * (∏_{j < i} b j)`

subject to the validity condition `c i < b i` (each digit is below its local base).

Two classical systems are special cases:
* the **base-`N`** system is `b i = N` (then `∏_{j<i} b j = N^i`);
* the **factorial** system is `b i = i + 1` (then `∏_{j<i} b j = i!`).

The development is **self-contained and non-circular**, mirroring the factorial
file: uniqueness (`value_unique`) is proved directly from
* the digit-bound estimate `value_lt : Valid b c k → value b c k < radixProd b k`, and
* the mixed-radix splitting identities `splitting_div` / `splitting_mod`,
without going through cardinality, surjectivity or any bijection theorem.  The
existence result `value_digit` comes afterwards.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  The entire uniqueness/existence machinery of the
  factorial number system depends only on the *running product of bases*, not on
  the specific choice `b i = i+1`.  Conjecture: replacing `i!` by an arbitrary
  running product `∏_{j<i} b j` and the bound `c i ≤ i` by `c i < b i` preserves
  uniqueness and existence verbatim.
* **Experiment (Experimenter).**  Generalized `value_lt`, `splitting_div`,
  `splitting_mod`, `value_unique`, `value_digit` to arbitrary `b`.  The only place
  positivity of the base is needed is the Euclidean-division step; this is supplied
  by `radixProd_pos_of_valid`, derived *from* `Valid` (a valid digit forces
  `b i ≥ c i + 1 ≥ 1`), so no extra hypothesis on `b` is required.
* **Analysis (Analyst).**  "True and clean": the factorial proof survives the
  generalization unchanged in structure.  The factorial bound `c i ≤ i` is exactly
  `c i < i+1`, and `i! = ∏_{j<i}(j+1)`, so the factorial file is the instance
  `b = (· + 1)` (`Factorial.value_eq`).  The base-`N` system is the instance
  `b = fun _ => N` (`baseN_radixProd`).
* **Critique (Critic).**  Edge case `b i = 0`: then no digit is valid at position
  `i`, so `Valid b c k` (for `k > i`) is unsatisfiable and every implication with
  that hypothesis holds vacuously — the theorems remain true, not vacuous lies,
  because they are *universally* quantified statements about valid representations.
* **Synthesis (PI).**  A single parameterized theory recovers both the factorial
  number system and ordinary base-`N` numerals, exhibiting them as two points in
  one family of "alien number systems".
-/

namespace MixedRadix

open Finset

/-- The running product of the first `k` bases, `∏_{i<k} b i`. -/
def radixProd (b : Nat → Nat) (k : Nat) : Nat :=
  ∏ i ∈ Finset.range k, b i

/-- The length-`k` mixed-radix value of a digit function `c` under bases `b`. -/
def value (b c : Nat → Nat) (k : Nat) : Nat :=
  ∑ i ∈ Finset.range k, c i * radixProd b i

/-- A digit function is valid up to length `k` if every digit `c i` (for `i < k`)
is strictly below its local base `b i`. -/
def Valid (b c : Nat → Nat) (k : Nat) : Prop := ∀ i < k, c i < b i

@[simp] theorem radixProd_zero (b : Nat → Nat) : radixProd b 0 = 1 := by
  simp [radixProd]

theorem radixProd_succ (b : Nat → Nat) (k : Nat) :
    radixProd b (k + 1) = radixProd b k * b k := by
  simp [radixProd, Finset.prod_range_succ]

@[simp] theorem value_zero (b c : Nat → Nat) : value b c 0 = 0 := by
  simp [value]

/-- The defining recurrence: peeling off the top digit. -/
theorem value_succ (b c : Nat → Nat) (k : Nat) :
    value b c (k + 1) = value b c k + c k * radixProd b k := by
  simp [value, Finset.sum_range_succ]

/-- `Valid` is monotone in the length. -/
theorem Valid.of_succ {b c : Nat → Nat} {k : Nat} (h : Valid b c (k + 1)) :
    Valid b c k := fun i hi => h i (Nat.lt_succ_of_lt hi)

/-
If a length-`(k+1)` representation is valid then the running product
`∏_{i<k} b i` is positive (each factor is at least `c i + 1 ≥ 1`).
-/
theorem radixProd_pos_of_valid {b c : Nat → Nat} {k : Nat} (h : Valid b c (k + 1)) :
    0 < radixProd b k := by
      exact Finset.prod_pos fun i hi => by linarith [ h i ( by linarith [ Finset.mem_range.mp hi ] ) ] ;

/-! ## 1. The digit-bound estimate -/

/-
A valid length-`k` mixed-radix value is strictly less than the running product
`∏_{i<k} b i`.
-/
theorem value_lt {b c : Nat → Nat} {k : Nat} :
    Valid b c k → value b c k < radixProd b k := by
      induction' k with k ih;
      · aesop;
      · -- By the induction hypothesis, we have `value b c k < radixProd b k`.
        intro h_valid
        have h_ind : value b c k < radixProd b k := by
          exact ih fun i hi => h_valid i ( Nat.lt_succ_of_lt hi );
        nlinarith! [ h_valid k ( Nat.lt_succ_self k ), value_succ b c k, radixProd_succ b k ]

/-! ## 2. The mixed-radix splitting identities -/

/-
Dividing a valid length-`(k+1)` value by `∏_{i<k} b i` recovers the top digit `c k`.
-/
theorem splitting_div {b c : Nat → Nat} {k : Nat} :
    Valid b c (k + 1) → value b c (k + 1) / radixProd b k = c k := by
      intro h;
      convert Nat.add_mul_div_right _ _ ( radixProd_pos_of_valid h ) using 1;
      rw [ value_succ ];
      rw [ Nat.div_eq_of_lt ( value_lt ( Valid.of_succ h ) ), zero_add ]

/-
Reducing a valid length-`(k+1)` value mod `∏_{i<k} b i` recovers the lower part.
-/
theorem splitting_mod {b c : Nat → Nat} {k : Nat} :
    Valid b c (k + 1) → value b c (k + 1) % radixProd b k = value b c k := by
      intro h;
      convert Nat.mod_eq_of_lt ( value_lt ( Valid.of_succ h ) ) using 1;
      norm_num [ value_succ, Nat.add_mod, Nat.mul_mod ]

/-! ## 3. Uniqueness (direct, via splitting) -/

/-
**Uniqueness of valid mixed-radix representations.**  If two valid digit
functions have the same length-`k` value, they agree on all digits below `k`.
-/
theorem value_unique {b c d : Nat → Nat} {k : Nat} :
    Valid b c k → Valid b d k → value b c k = value b d k → ∀ i < k, c i = d i := by
      -- By the splitting lemma, we have that $c k = d k$.
      intros hc hd hv
      induction' k with k ih;
      · tauto;
      · -- By the splitting lemma, we have that $c k = d k$ and $value b c k = value b d k$.
        have h_top : c k = d k := by
          rw [ ← splitting_div hc, ← splitting_div hd, hv ]
        have h_tail : value b c k = value b d k := by
          simp_all +decide [ value_succ ];
        exact fun i hi => if hi' : i = k then hi'.symm ▸ h_top else ih ( fun i hi => hc i ( Nat.lt_succ_of_lt hi ) ) ( fun i hi => hd i ( Nat.lt_succ_of_lt hi ) ) h_tail i ( lt_of_le_of_ne ( Nat.le_of_lt_succ hi ) hi' )

/-! ## 4. Existence (explicit digit extraction) -/

/-- Explicit mixed-radix digit extraction for a natural number `n`. -/
def digit (b : Nat → Nat) (n : Nat) (i : Nat) : Nat := (n / radixProd b i) % (b i)

/-
The extracted digits are valid, provided every base is positive.
-/
theorem digit_valid {b : Nat → Nat} (hb : ∀ i, 0 < b i) (n k : Nat) :
    Valid b (digit b n) k := by
      exact fun i hi => Nat.mod_lt _ ( hb i )

/-
**Existence / surjectivity**: every `n < ∏_{i<k} b i` is the mixed-radix value
of its own extracted digits.  No separate positivity hypothesis on the bases is
needed: `n < radixProd b k` already forces `radixProd b k > 0`.
-/
theorem value_digit {b : Nat → Nat} {n k : Nat}
    (hn : n < radixProd b k) : value b (digit b n) k = n := by
      -- Prove the general splitting identity by induction on `m`.
      have key (m : ℕ) : n = (∑ i ∈ Finset.range m, (n / radixProd b i) % (b i) * radixProd b i) + (n / radixProd b m) * radixProd b m := by
        induction' m with m ih;
        · simp +decide [ radixProd ];
        · rw [ Finset.sum_range_succ, radixProd_succ ];
          convert ih using 1;
          rw [ ← Nat.div_add_mod ( n / radixProd b m ) ( b m ) ] ; ring_nf;
          norm_num [ Nat.div_div_eq_div_mul, mul_assoc, mul_comm, mul_left_comm ];
      unfold value digit;
      nlinarith [ key k, Nat.div_eq_of_lt hn ]

/-! ## 5. Bridges: factorial and base-`N` systems as instances -/

/-
For the factorial system `b i = i + 1`, the running product is `k!`.
-/
theorem factorial_radixProd (k : Nat) :
    radixProd (fun i => i + 1) k = k.factorial := by
  induction k with
  | zero => rfl
  | succ k ih => rw [radixProd_succ, ih, Nat.factorial_succ, Nat.mul_comm]

/-
For the base-`N` system `b i = N`, the running product is `N^k`.
-/
theorem baseN_radixProd (N k : Nat) :
    radixProd (fun _ => N) k = N ^ k := by
      unfold radixProd; aesop;

/-
The factorial validity condition `c i ≤ i` is exactly mixed-radix validity for
`b i = i + 1`.
-/
theorem factorial_valid_iff (c : Nat → Nat) (k : Nat) :
    Valid (fun i => i + 1) c k ↔ ∀ i < k, c i ≤ i := by
      exact ⟨ fun h i hi => Nat.le_of_lt_succ ( h i hi ), fun h i hi => Nat.lt_succ_of_le ( h i hi ) ⟩

end MixedRadix