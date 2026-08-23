import Mathlib

/-!
# A radix-growth threshold: when is the weight-tower height `O(log* n)`?

Fix a *radix schedule* `r : ℕ → ℕ` and build the generalized positional weights

```
V r 0       = 1
V r (k + 1) = r (V r k) * V r k
```

so that the `k`-th digit of a mixed-radix numeral system with radices
`r (V r 0), r (V r 1), …` carries weight `V r k`.  The number of digits needed to
represent `n` is the least `k` with `n < V r k`; we call it `K r n`.

The file establishes a sharp **growth threshold** for the asymptotics of `K r n`
measured against the iterated binary logarithm `logStar`:

* **Exponential regime** (`radixHeight_le_logStar_add`): if `2 ^ x ≤ r x` for all
  `x ≥ x₀`, then `K r n ≤ x₀ + logStar n + 1` for *every* `n`.  So `K r ·` is
  `O(log* n)` with an additive constant only.
* **Polynomial regime** (`radixHeight_not_bigO_logStar`): if `r x ≤ x ^ C` for all
  `x ≥ x₀` (and `r` is monotone with `r ≥ 2`), then for every constant `c` there is
  an `n` with `c * (logStar n + 1) < K r n`.  Hence `K r ·` is *not* `O(log* n)`.

The two regimes are combined in `radix_growth_threshold`, and instantiated on the
concrete schedules `expSchedule x = max 2 (2 ^ x)`, `r x = 2 ^ (x + 1)`, and the whole
polynomial family `polySchedule C x = x ^ C + 2`.

Three refinements go beyond the plain dichotomy:

* `expSchedule_radixHeight_theta`: for the canonical exponential schedule the bounds
  `log* n ≤ 2 * radixHeight` and `radixHeight ≤ log* n + 1` hold simultaneously, so there
  the radix height really is `Θ (log* n)`.
* `not_bigO_of_iterated_exponential_bound`: weights bounded by *any fixed height* of
  iterated exponentials of a linear function of `k` already fail `O(log* n)`.  What matters
  is not polynomiality of `r` but boundedness of the tower height.
* `bigO_logStar_iff_tower_le`: an intrinsic characterization — the radix height is
  `O(log* n)` **iff** the weights overtake the tower of twos along an arithmetic
  subsequence.

## Structure of the argument

1. `two_pow_le_V`, `V_monotone`, `lt_V_radixHeight`, `lt_radixHeight` — basic control on `V` and `K`.
2. `logStar_tower_eq` and `lt_tower_logStar` — `log*` inverts the tower: `log* (tower j) = j`
   and `n < tower (logStar n + 1)`.
3. `tower_le_V` — in the exponential regime `V` dominates a shifted tower; conversely
   `V_le_tower_two_mul` bounds `V` by a tower of doubled height.
4. `V_le_pow_pow` — in the polynomial regime `V r k ≤ M ^ (E ^ k)`: doubly exponential
   in `k`, i.e. only *one* exponential slower than a tower.
5. `not_bigO_of_slow_logStar` — the master transfer lemma: whenever `log* (V r k)` grows
   sublinearly in `k`, the radix height beats any constant multiple of `log*`, on
   arbitrarily large inputs.

All of this is elementary arithmetic on `ℕ`, but the interplay of the three
different growth scales (tower / iterated exponential / iterated logarithm) is what
makes the threshold sharp.
-/

namespace RadixGrowth

/-! ## Definitions -/

/-- Generalized positional weights: `V r 0 = 1` and `V r (k+1) = r (V r k) * V r k`. -/
def V (r : ℕ → ℕ) : ℕ → ℕ
  | 0 => 1
  | k + 1 => r (V r k) * V r k

@[simp] theorem V_zero (r : ℕ → ℕ) : V r 0 = 1 := rfl

@[simp] theorem V_succ (r : ℕ → ℕ) (k : ℕ) : V r (k + 1) = r (V r k) * V r k := rfl

/-- The tower of twos: `tower 0 = 1`, `tower (k+1) = 2 ^ tower k`. -/
def tower : ℕ → ℕ
  | 0 => 1
  | k + 1 => 2 ^ tower k

@[simp] theorem tower_zero : tower 0 = 1 := rfl

@[simp] theorem tower_succ (k : ℕ) : tower (k + 1) = 2 ^ tower k := rfl

/-- The iterated exponential of fixed height `h`: `expIter 0 x = x`,
`expIter (h+1) x = 2 ^ expIter h x`.  (`tower k = expIter k 1`.) -/
def expIter : ℕ → ℕ → ℕ
  | 0, x => x
  | h + 1, x => 2 ^ expIter h x

@[simp] theorem expIter_zero (x : ℕ) : expIter 0 x = x := rfl

@[simp] theorem expIter_succ (h x : ℕ) : expIter (h + 1) x = 2 ^ expIter h x := rfl

/-- The iterated binary logarithm `log*`. -/
def logStar : ℕ → ℕ
  | n => if h : 1 < n then 1 + logStar (Nat.log 2 n) else 0
decreasing_by exact Nat.log_lt_self 2 (by omega)

/-- The **radix height** of `n`: the least `k` with `n < V r k`
(`0` if no such `k` exists, which never happens under `2 ≤ r`). -/
noncomputable def radixHeight (r : ℕ → ℕ) (n : ℕ) : ℕ := sInf {k | n < V r k}

/-! ## Elementary properties of `logStar` -/

private theorem le_one_or_one_lt (n : ℕ) : n ≤ 1 ∨ 1 < n := (Nat.lt_or_ge 1 n).symm

theorem logStar_of_le_one {n : ℕ} (h : n ≤ 1) : logStar n = 0 := by
  rw [logStar]; simp [Nat.not_lt.mpr h]

theorem logStar_of_one_lt {n : ℕ} (h : 1 < n) :
    logStar n = 1 + logStar (Nat.log 2 n) := by
  rw [logStar]; simp [h]

@[simp] theorem logStar_zero : logStar 0 = 0 := logStar_of_le_one (by norm_num)

@[simp] theorem logStar_one : logStar 1 = 0 := logStar_of_le_one le_rfl

/-- `log*` is monotone. -/
theorem logStar_mono : Monotone logStar := by
  have key : ∀ n m : ℕ, m ≤ n → logStar m ≤ logStar n := by
    intro n
    induction n using Nat.strong_induction_on with
    | _ n ih =>
      intro m hmn
      rcases le_one_or_one_lt m with h | h
      · simp [logStar_of_le_one h]
      · have hn : 1 < n := lt_of_lt_of_le h hmn
        have hlt : Nat.log 2 n < n := Nat.log_lt_self 2 (by omega)
        rw [logStar_of_one_lt h, logStar_of_one_lt hn]
        exact Nat.add_le_add_left (ih _ hlt _ (Nat.log_mono_right hmn)) 1
  exact fun m n hmn => key n m hmn

/-- `log*` never exceeds a single binary logarithm. -/
theorem logStar_le_log (n : ℕ) : logStar n ≤ Nat.log 2 n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    rcases le_one_or_one_lt n with h | h
    · simp [logStar_of_le_one h]
    · have hlt : Nat.log 2 n < n := Nat.log_lt_self 2 (by omega)
      have hpos : 0 < Nat.log 2 n := Nat.log_pos (by norm_num) (by omega)
      have hlt2 : Nat.log 2 (Nat.log 2 n) < Nat.log 2 n :=
        Nat.log_lt_self 2 (by omega)
      have := ih _ hlt
      rw [logStar_of_one_lt h]
      omega

/-- Exact peeling law for `log*` at powers of two. -/
theorem logStar_two_pow_eq {a : ℕ} (ha : 1 ≤ a) : logStar (2 ^ a) = 1 + logStar a := by
  have h1 : 1 < 2 ^ a := by
    calc (1 : ℕ) < 2 := by norm_num
      _ = 2 ^ 1 := (pow_one 2).symm
      _ ≤ 2 ^ a := Nat.pow_le_pow_right (by norm_num) ha
  rw [logStar_of_one_lt h1, Nat.log_pow (by norm_num)]

theorem logStar_two_pow (a : ℕ) : logStar (2 ^ a) ≤ 1 + logStar a := by
  rcases Nat.eq_zero_or_pos a with rfl | ha
  · simp
  · exact le_of_eq (logStar_two_pow_eq ha)

/-- If `n` is at most `2 ^ a` then `log* n ≤ 1 + log* a`. -/
theorem logStar_le_of_le_two_pow {n a : ℕ} (h : n ≤ 2 ^ a) :
    logStar n ≤ 1 + logStar a :=
  le_trans (logStar_mono h) (logStar_two_pow a)

/-- A fixed number of exponentiations only shifts `log*` by that fixed amount. -/
theorem logStar_expIter_le (h y : ℕ) : logStar (expIter h y) ≤ h + logStar y := by
  induction h with
  | zero => simp
  | succ h ih =>
    calc logStar (expIter (h + 1) y) = logStar (2 ^ expIter h y) := by rw [expIter_succ]
      _ ≤ 1 + logStar (expIter h y) := logStar_two_pow _
      _ ≤ 1 + (h + logStar y) := by omega
      _ = h + 1 + logStar y := by omega

theorem tower_pos (j : ℕ) : 1 ≤ tower j := by
  induction j with
  | zero => simp
  | succ j _ => simpa using Nat.one_le_two_pow

/-- **`log*` inverts the tower exactly**: `log* (tower j) = j`.  In particular `log*` is
unbounded, so none of the statements below is vacuous. -/
theorem logStar_tower_eq (j : ℕ) : logStar (tower j) = j := by
  induction j with
  | zero => simp
  | succ j ih =>
    rw [tower_succ, logStar_two_pow_eq (tower_pos j), ih]
    omega

theorem logStar_tower (j : ℕ) : logStar (tower j) ≤ j := (logStar_tower_eq j).le

/-- `log*` takes arbitrarily large values. -/
theorem logStar_unbounded (B : ℕ) : ∃ n, B ≤ logStar n :=
  ⟨tower B, (logStar_tower_eq B).ge⟩

/-- The defining property of `log*`: `n` is below the tower of height `log* n + 1`. -/
theorem lt_tower_logStar (n : ℕ) : n < tower (logStar n + 1) := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    rcases le_one_or_one_lt n with h | h
    · rw [logStar_of_le_one h]; simpa using by omega
    · have hlt : Nat.log 2 n < n := Nat.log_lt_self 2 (by omega)
      have IH := ih _ hlt
      rw [logStar_of_one_lt h]
      have h1 : Nat.log 2 n + 1 ≤ tower (logStar (Nat.log 2 n) + 1) := IH
      have h2 : n < 2 ^ (Nat.log 2 n + 1) := Nat.lt_pow_succ_log_self (by norm_num) n
      have h3 : (2 : ℕ) ^ (Nat.log 2 n + 1) ≤ 2 ^ tower (logStar (Nat.log 2 n) + 1) :=
        Nat.pow_le_pow_right (by norm_num) h1
      have h4 : (1 : ℕ) + logStar (Nat.log 2 n) + 1 = logStar (Nat.log 2 n) + 1 + 1 := by
        omega
      rw [h4, tower_succ]
      omega

/-! ## Basic control on the weights and on the radix height -/

section Basic

variable {r : ℕ → ℕ}

theorem one_le_V (hr2 : ∀ x, 2 ≤ r x) (k : ℕ) : 1 ≤ V r k := by
  induction k with
  | zero => simp
  | succ k ih =>
    have h2 := hr2 (V r k)
    have : 1 * 1 ≤ r (V r k) * V r k := Nat.mul_le_mul (by omega) ih
    simpa using this

theorem two_pow_le_V (hr2 : ∀ x, 2 ≤ r x) (k : ℕ) : 2 ^ k ≤ V r k := by
  induction k with
  | zero => simp
  | succ k ih =>
    have h2 := hr2 (V r k)
    calc (2 : ℕ) ^ (k + 1) = 2 * 2 ^ k := by ring
      _ ≤ r (V r k) * V r k := Nat.mul_le_mul h2 ih
      _ = V r (k + 1) := rfl

theorem V_monotone (hr2 : ∀ x, 2 ≤ r x) : Monotone (V r) := by
  refine monotone_nat_of_le_succ (fun k => ?_)
  have h2 := hr2 (V r k)
  have : 1 * V r k ≤ r (V r k) * V r k := Nat.mul_le_mul_right _ (by omega)
  simpa using this

/-- `2 * v ≤ 2 ^ v` for `v ≥ 1`. -/
theorem two_mul_le_two_pow : ∀ v : ℕ, 1 ≤ v → 2 * v ≤ 2 ^ v := by
  intro v
  induction v with
  | zero => omega
  | succ n ih =>
    intro _
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · norm_num
    · have h2 : (2 : ℕ) ≤ 2 ^ n := by
        calc (2 : ℕ) = 2 ^ 1 := (pow_one 2).symm
          _ ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
      have h3 := ih hn
      have h4 : (2 : ℕ) ^ (n + 1) = 2 ^ n + 2 ^ n := by ring
      omega

theorem exists_lt_V (hr2 : ∀ x, 2 ≤ r x) (n : ℕ) : ∃ k, n < V r k :=
  ⟨n, lt_of_lt_of_le Nat.lt_two_pow_self (two_pow_le_V hr2 n)⟩

/-- The radix height really is a representation length: `n < V r (radixHeight r n)`. -/
theorem lt_V_radixHeight (hr2 : ∀ x, 2 ≤ r x) (n : ℕ) : n < V r (radixHeight r n) :=
  Nat.sInf_mem (exists_lt_V hr2 n)

/-- Minimality of the radix height. -/
theorem radixHeight_le {n k : ℕ} (h : n < V r k) : radixHeight r n ≤ k :=
  Nat.sInf_le h

/-- If the `k`-th weight is still at most `n`, the radix height exceeds `k`. -/
theorem lt_radixHeight (hr2 : ∀ x, 2 ≤ r x) {n k : ℕ} (h : V r k ≤ n) :
    k < radixHeight r n := by
  by_contra hc
  push_neg at hc
  have h1 := lt_V_radixHeight hr2 (r := r) n
  have h2 : V r (radixHeight r n) ≤ V r k := V_monotone hr2 hc
  omega

end Basic

/-! ## The exponential regime: `K r n ≤ x₀ + log* n + 1` -/

section Exponential

variable {r : ℕ → ℕ} {x₀ : ℕ}

/-- Once the weights have passed the threshold `x₀`, they dominate a tower of twos. -/
theorem tower_le_V (hr2 : ∀ x, 2 ≤ r x) (hbig : ∀ x, x₀ ≤ x → 2 ^ x ≤ r x) (j : ℕ) :
    tower j ≤ V r (x₀ + j) := by
  induction j with
  | zero => simpa using one_le_V hr2 x₀
  | succ j ih =>
    have h1 : x₀ + j < 2 ^ (x₀ + j) := Nat.lt_two_pow_self
    have h2 := two_pow_le_V hr2 (r := r) (x₀ + j)
    have hge : x₀ ≤ V r (x₀ + j) := by omega
    have hbg := hbig _ hge
    have hpos : 1 ≤ V r (x₀ + j) := one_le_V hr2 _
    calc tower (j + 1) = 2 ^ tower j := rfl
      _ ≤ 2 ^ V r (x₀ + j) := Nat.pow_le_pow_right (by norm_num) ih
      _ ≤ r (V r (x₀ + j)) := hbg
      _ ≤ r (V r (x₀ + j)) * V r (x₀ + j) := Nat.le_mul_of_pos_right _ hpos
      _ = V r (x₀ + (j + 1)) := by rw [← Nat.add_assoc]; rfl

/-- **Exponential regime.**  If `2 ^ x ≤ r x` for all `x ≥ x₀`, the radix height is
bounded by `log* n` plus the additive constant `x₀ + 1`; in particular it is
`O(log* n)`. -/
theorem radixHeight_le_logStar_add (hr2 : ∀ x, 2 ≤ r x)
    (hbig : ∀ x, x₀ ≤ x → 2 ^ x ≤ r x) (n : ℕ) :
    radixHeight r n ≤ x₀ + logStar n + 1 := by
  have h1 : n < tower (logStar n + 1) := lt_tower_logStar n
  have h2 : tower (logStar n + 1) ≤ V r (x₀ + (logStar n + 1)) :=
    tower_le_V hr2 hbig _
  have he : x₀ + (logStar n + 1) = x₀ + logStar n + 1 := by omega
  rw [he] at h2
  exact radixHeight_le (lt_of_lt_of_le h1 h2)

/-! ### Sharpness: a matching lower bound -/

/-- If the schedule is at most exponential (`r x ≤ 2 ^ x`), the weights are dominated by a
tower of *twice* the height. -/
theorem V_le_tower_two_mul (hr2 : ∀ x, 2 ≤ r x) (hsmall : ∀ x, 1 ≤ x → r x ≤ 2 ^ x) (k : ℕ) :
    V r k ≤ tower (2 * k) := by
  induction k with
  | zero => simp
  | succ k ih =>
    have hV1 : 1 ≤ V r k := one_le_V hr2 k
    have e1 : r (V r k) ≤ 2 ^ V r k := hsmall _ hV1
    have e2 : V r k ≤ 2 ^ V r k := le_of_lt Nat.lt_two_pow_self
    calc V r (k + 1) = r (V r k) * V r k := rfl
      _ ≤ 2 ^ V r k * 2 ^ V r k := Nat.mul_le_mul e1 e2
      _ = 2 ^ (2 * V r k) := by rw [← pow_add]; ring_nf
      _ ≤ 2 ^ 2 ^ V r k :=
          Nat.pow_le_pow_right (by norm_num) (two_mul_le_two_pow _ hV1)
      _ ≤ 2 ^ 2 ^ tower (2 * k) :=
          Nat.pow_le_pow_right (by norm_num)
            (Nat.pow_le_pow_right (by norm_num) ih)
      _ = tower (2 * k + 2) := by rw [tower_succ, tower_succ]
      _ = tower (2 * (k + 1)) := by ring_nf

/-- **Matching lower bound.**  For an at-most-exponential schedule the radix height is at
least `log* n / 2`, so in the exponential regime `radixHeight r n = Θ (log* n)`. -/
theorem logStar_le_two_mul_radixHeight (hr2 : ∀ x, 2 ≤ r x)
    (hsmall : ∀ x, 1 ≤ x → r x ≤ 2 ^ x) (n : ℕ) :
    logStar n ≤ 2 * radixHeight r n := by
  have h1 : n < V r (radixHeight r n) := lt_V_radixHeight hr2 n
  have h2 : V r (radixHeight r n) ≤ tower (2 * radixHeight r n) :=
    V_le_tower_two_mul hr2 hsmall _
  calc logStar n ≤ logStar (tower (2 * radixHeight r n)) :=
        logStar_mono (by omega)
    _ ≤ 2 * radixHeight r n := logStar_tower _

end Exponential

/-! ## The master transfer lemma: slow `log*`-growth of the weights is fatal -/

section Transfer

variable {r : ℕ → ℕ}

/-- Two numbers `≥ 2` have sum at most their product. -/
private theorem add_le_mul_of_two_le {a b : ℕ} (ha : 2 ≤ a) (hb : 2 ≤ b) :
    a + b ≤ a * b := by nlinarith

/-- **Master transfer lemma.**  Only one feature of the weight sequence matters: the growth
of `log* (V r k)` as a function of `k`.  If it is dominated by some `h` that is sublinear in
the weak sense `∀ c N, ∃ k ≥ N, c * (h k + 1) < k + 1`, then the radix height beats every
constant multiple of `log*`, on arbitrarily large inputs. -/
theorem not_bigO_of_slow_logStar (hr2 : ∀ x, 2 ≤ r x) {h : ℕ → ℕ}
    (hVh : ∀ k, logStar (V r k) ≤ h k)
    (hslow : ∀ c N : ℕ, ∃ k, N ≤ k ∧ c * (h k + 1) < k + 1) (c N : ℕ) :
    ∃ n, N ≤ n ∧ c * (logStar n + 1) < radixHeight r n := by
  obtain ⟨k, hkN, hk⟩ := hslow c N
  refine ⟨V r k, ?_, ?_⟩
  · have h1 : 2 ^ k ≤ V r k := two_pow_le_V hr2 k
    have h2 : k < 2 ^ k := Nat.lt_two_pow_self
    omega
  · have h1 : k < radixHeight r (V r k) := lt_radixHeight hr2 (le_refl (V r k))
    have h2 : c * (logStar (V r k) + 1) ≤ c * (h k + 1) :=
      Nat.mul_le_mul_left _ (by have := hVh k; omega)
    omega

/-- A doubly exponential quantity is dominated by two exponentiations of a linear function
of `k`: `M ^ (E ^ k) ≤ expIter 2 (M + E k)`. -/
theorem pow_pow_le_expIter_two (M E k : ℕ) : M ^ E ^ k ≤ expIter 2 (M + E * k) := by
  have hb1 : M ^ E ^ k ≤ 2 ^ (M * E ^ k) := by
    calc M ^ E ^ k ≤ (2 ^ M) ^ E ^ k :=
          Nat.pow_le_pow_left (le_of_lt Nat.lt_two_pow_self) _
      _ = 2 ^ (M * E ^ k) := by rw [← pow_mul]
  have hb2 : M * E ^ k ≤ 2 ^ (M + E * k) := by
    calc M * E ^ k ≤ 2 ^ M * (2 ^ E) ^ k :=
          Nat.mul_le_mul (le_of_lt Nat.lt_two_pow_self)
            (Nat.pow_le_pow_left (le_of_lt Nat.lt_two_pow_self) k)
      _ = 2 ^ (M + E * k) := by rw [← pow_mul, ← pow_add]
  calc M ^ E ^ k ≤ 2 ^ (M * E ^ k) := hb1
    _ ≤ 2 ^ 2 ^ (M + E * k) := Nat.pow_le_pow_right (by norm_num) hb2
    _ = expIter 2 (M + E * k) := by simp

/-- The bound `a + log₂ (M + E k)` is sublinear in the sense demanded by the master lemma:
at `k = 2 ^ (2 t)` it is `O(t)` while `k` itself is `2 ^ (2 t)`. -/
theorem slow_log_bound (a M E : ℕ) (hM : 2 ≤ M) (hE : 2 ≤ E) (c N : ℕ) :
    ∃ k, N ≤ k ∧ c * ((a + Nat.log 2 (M + E * k)) + 1) < k + 1 := by
  obtain ⟨t, ht4c, ht4S, ht0, htN⟩ :
      ∃ t : ℕ, 4 * c ≤ t ∧ 4 * (M + E + a + 1) ≤ t ∧ 0 < t ∧ N ≤ t :=
    ⟨4 * (c + (M + E + a + 1) + N + 1), by omega, by omega, by omega, by omega⟩
  set m := 2 * t with hm
  set k := 2 ^ m with hk
  have hmk : m < k := by rw [hk]; exact Nat.lt_two_pow_self
  refine ⟨k, by omega, ?_⟩
  -- `M + E * k` is at most `2 ^ (M + E + m)`, so its logarithm is at most `M + E + m`
  have hb3 : M + E * k ≤ 2 ^ (M + E + m) := by
    have hMle : M ≤ 2 ^ M := le_of_lt Nat.lt_two_pow_self
    have hEle : E ≤ 2 ^ E := le_of_lt Nat.lt_two_pow_self
    have h1 : M + E * k ≤ 2 ^ M + 2 ^ E * 2 ^ m := by
      have : E * k ≤ 2 ^ E * 2 ^ m := by
        rw [hk]; exact Nat.mul_le_mul_right _ hEle
      omega
    have h2 : (2 : ℕ) ^ M + 2 ^ E * 2 ^ m ≤ 2 ^ M * (2 ^ E * 2 ^ m) := by
      refine add_le_mul_of_two_le ?_ ?_
      · calc (2 : ℕ) = 2 ^ 1 := (pow_one 2).symm
          _ ≤ 2 ^ M := Nat.pow_le_pow_right (by norm_num) (by omega)
      · have h5 : (2 : ℕ) ^ 1 ≤ 2 ^ E := Nat.pow_le_pow_right (by norm_num) (by omega)
        have hpos : 1 ≤ (2 : ℕ) ^ m := Nat.one_le_two_pow
        nlinarith [h5, hpos]
    have h3 : (2 : ℕ) ^ M * (2 ^ E * 2 ^ m) = 2 ^ (M + E + m) := by
      rw [← pow_add, ← pow_add, Nat.add_assoc]
    omega
  have hlog : Nat.log 2 (M + E * k) ≤ M + E + m := by
    calc Nat.log 2 (M + E * k) ≤ Nat.log 2 (2 ^ (M + E + m)) := Nat.log_mono_right hb3
      _ = M + E + m := Nat.log_pow (by norm_num) _
  -- arithmetic: `c * ((M + E + a + 1) + m) ≤ t * t < 2 ^ m = k`
  have harith : c * ((M + E + a + 1) + m) ≤ t * t := by
    have h1 : (4 * c) * (4 * (M + E + a + 1)) ≤ t * t := Nat.mul_le_mul ht4c ht4S
    have h2 : (4 * c) * t ≤ t * t := Nat.mul_le_mul_right _ ht4c
    have hm' : m = 2 * t := hm
    nlinarith [h1, h2]
  have htt : t * t < k := by
    have ht : t < 2 ^ t := Nat.lt_two_pow_self
    have hpow : k = 2 ^ t * 2 ^ t := by rw [hk, hm, ← pow_add]; ring_nf
    nlinarith [ht, Nat.one_le_two_pow (n := t)]
  have hmono : c * ((a + Nat.log 2 (M + E * k)) + 1) ≤ c * ((M + E + a + 1) + m) :=
    Nat.mul_le_mul_left _ (by omega)
  omega

/-- **Fixed-height transfer theorem.**  If the weights are dominated by *any fixed number*
`hgt` of exponentiations applied to a linear function of `k`, the radix height already beats
every constant multiple of `log* n`, on arbitrarily large inputs.  Only a tower whose height
grows with `k` can keep up with `log*`. -/
theorem not_bigO_of_iterated_exponential_bound (hr2 : ∀ x, 2 ≤ r x) {hgt M E : ℕ}
    (hM : 2 ≤ M) (hE : 2 ≤ E) (hV : ∀ k, V r k ≤ expIter hgt (M + E * k)) (c N : ℕ) :
    ∃ n, N ≤ n ∧ c * (logStar n + 1) < radixHeight r n :=
  not_bigO_of_slow_logStar hr2
    (fun k =>
      le_trans (logStar_mono (hV k))
        (le_trans (logStar_expIter_le hgt (M + E * k))
          (Nat.add_le_add_left (logStar_le_log _) hgt)))
    (slow_log_bound hgt M E hM hE) c N

/-- **Transfer lemma.**  If the weights obey a doubly exponential upper bound
`V r k ≤ M ^ (E ^ k)`, then the radix height beats every constant multiple of `log* n`,
on arbitrarily large inputs.  This is the height-`2` case of
`not_bigO_of_iterated_exponential_bound`. -/
theorem not_bigO_of_doubly_exponential_bound (hr2 : ∀ x, 2 ≤ r x) {M E : ℕ}
    (hM : 2 ≤ M) (hE : 2 ≤ E) (hV : ∀ k, V r k ≤ M ^ E ^ k) (c N : ℕ) :
    ∃ n, N ≤ n ∧ c * (logStar n + 1) < radixHeight r n :=
  not_bigO_of_iterated_exponential_bound hr2 hM hE
    (fun k => le_trans (hV k) (pow_pow_le_expIter_two M E k)) c N

end Transfer

/-! ## The polynomial regime: `K r n` is not `O(log* n)` -/

section Polynomial

variable {r : ℕ → ℕ} {x₀ C : ℕ}

/-- A polynomial bound valid beyond a threshold globalizes, for monotone `r`. -/
theorem r_le_global (hmono : Monotone r) (hr2 : ∀ x, 2 ≤ r x)
    (hpoly : ∀ x, x₀ ≤ x → r x ≤ x ^ C) (x : ℕ) :
    r x ≤ r x₀ * (x + 1) ^ C := by
  have hA : 0 < r x₀ := lt_of_lt_of_le (by norm_num) (hr2 x₀)
  rcases Nat.lt_or_ge x x₀ with h | h
  · calc r x ≤ r x₀ := hmono h.le
      _ ≤ r x₀ * (x + 1) ^ C := Nat.le_mul_of_pos_right _ (Nat.pow_pos (by omega))
  · calc r x ≤ x ^ C := hpoly x h
      _ ≤ (x + 1) ^ C := Nat.pow_le_pow_left (by omega) _
      _ ≤ r x₀ * (x + 1) ^ C := Nat.le_mul_of_pos_left _ hA

/-- One step of the polynomial recursion. -/
theorem V_succ_le (hmono : Monotone r) (hr2 : ∀ x, 2 ≤ r x)
    (hpoly : ∀ x, x₀ ≤ x → r x ≤ x ^ C) (k : ℕ) :
    V r (k + 1) ≤ (r x₀ * 2 ^ C) * V r k ^ (C + 1) := by
  have hV1 : 1 ≤ V r k := one_le_V hr2 k
  have h1 : r (V r k) ≤ r x₀ * (V r k + 1) ^ C := r_le_global hmono hr2 hpoly _
  have h2 : (V r k + 1) ^ C ≤ (2 * V r k) ^ C := Nat.pow_le_pow_left (by omega) _
  have h3 : (2 * V r k) ^ C = 2 ^ C * V r k ^ C := by rw [mul_pow]
  have h4 : r (V r k) ≤ (r x₀ * 2 ^ C) * V r k ^ C := by
    calc r (V r k) ≤ r x₀ * (V r k + 1) ^ C := h1
      _ ≤ r x₀ * ((2 * V r k) ^ C) := Nat.mul_le_mul_left _ h2
      _ = (r x₀ * 2 ^ C) * V r k ^ C := by rw [h3]; ring
  calc V r (k + 1) = r (V r k) * V r k := rfl
    _ ≤ ((r x₀ * 2 ^ C) * V r k ^ C) * V r k := Nat.mul_le_mul_right _ h4
    _ = (r x₀ * 2 ^ C) * V r k ^ (C + 1) := by ring

/-- **Polynomial regime, growth bound.**  The weights are only doubly exponential:
`V r k ≤ M ^ (E ^ k)` with `M = r x₀ * 2 ^ C` and `E = C + 2`. -/
theorem V_le_pow_pow (hmono : Monotone r) (hr2 : ∀ x, 2 ≤ r x)
    (hpoly : ∀ x, x₀ ≤ x → r x ≤ x ^ C) (k : ℕ) :
    V r k ≤ (r x₀ * 2 ^ C) ^ (C + 2) ^ k := by
  set M := r x₀ * 2 ^ C with hMdef
  have hM2 : 2 ≤ M := by
    have h1 : 2 ≤ r x₀ := hr2 x₀
    have h2 : 1 ≤ (2 : ℕ) ^ C := Nat.one_le_two_pow
    calc (2 : ℕ) = 2 * 1 := by ring
      _ ≤ r x₀ * 2 ^ C := Nat.mul_le_mul h1 h2
  have key : ∀ j, M * V r j ≤ M ^ (C + 2) ^ j := by
    intro j
    induction j with
    | zero => simp
    | succ j ih =>
      have hV1 : 1 ≤ V r j := one_le_V hr2 j
      have hstep : V r (j + 1) ≤ M * V r j ^ (C + 1) := V_succ_le hmono hr2 hpoly j
      have h1 : M * V r (j + 1) ≤ (M * M) * V r j ^ (C + 1) := by
        calc M * V r (j + 1) ≤ M * (M * V r j ^ (C + 1)) := Nat.mul_le_mul_left _ hstep
          _ = (M * M) * V r j ^ (C + 1) := by ring
      have h2 : M * M ≤ M ^ (C + 2) := by
        calc M * M = M ^ 2 := by ring
          _ ≤ M ^ (C + 2) := Nat.pow_le_pow_right (by omega) (by omega)
      have h3 : V r j ^ (C + 1) ≤ V r j ^ (C + 2) :=
        Nat.pow_le_pow_right hV1 (by omega)
      have h4 : M * V r (j + 1) ≤ (M * V r j) ^ (C + 2) := by
        calc M * V r (j + 1) ≤ (M * M) * V r j ^ (C + 1) := h1
          _ ≤ M ^ (C + 2) * V r j ^ (C + 2) := Nat.mul_le_mul h2 h3
          _ = (M * V r j) ^ (C + 2) := (mul_pow M (V r j) (C + 2)).symm
      calc M * V r (j + 1) ≤ (M * V r j) ^ (C + 2) := h4
        _ ≤ (M ^ (C + 2) ^ j) ^ (C + 2) := Nat.pow_le_pow_left ih _
        _ = M ^ ((C + 2) ^ j * (C + 2)) := by rw [← pow_mul]
        _ = M ^ (C + 2) ^ (j + 1) := by rw [pow_succ]
  exact le_trans (Nat.le_mul_of_pos_left _ (by omega)) (key k)

/-- **Polynomial regime.**  If `r` is monotone, `r ≥ 2`, and `r x ≤ x ^ C` for all
large `x`, then for every constant `c` there is an `n` with
`c * (log* n + 1) < radixHeight r n`: the radix height is *not* `O(log* n)`. -/
theorem radixHeight_not_bigO_logStar (hmono : Monotone r) (hr2 : ∀ x, 2 ≤ r x)
    (hpoly : ∀ x, x₀ ≤ x → r x ≤ x ^ C) (c : ℕ) :
    ∃ n, c * (logStar n + 1) < radixHeight r n := by
  have hM2 : 2 ≤ r x₀ * 2 ^ C := by
    have h1 : 2 ≤ r x₀ := hr2 x₀
    have h2 : 1 ≤ (2 : ℕ) ^ C := Nat.one_le_two_pow
    calc (2 : ℕ) = 2 * 1 := by ring
      _ ≤ r x₀ * 2 ^ C := Nat.mul_le_mul h1 h2
  obtain ⟨n, -, hn⟩ := not_bigO_of_doubly_exponential_bound hr2 hM2 (by omega)
    (V_le_pow_pow hmono hr2 hpoly) c 0
  exact ⟨n, hn⟩

/-- **Polynomial regime, with arbitrarily large witnesses.**  The failure of `O(log* n)` is
not caused by finitely many exceptional `n`: for every `c` and every `N` there is a witness
`n ≥ N`. -/
theorem radixHeight_not_bigO_logStar_large (hmono : Monotone r) (hr2 : ∀ x, 2 ≤ r x)
    (hpoly : ∀ x, x₀ ≤ x → r x ≤ x ^ C) (c N : ℕ) :
    ∃ n, N ≤ n ∧ c * (logStar n + 1) < radixHeight r n := by
  have hM2 : 2 ≤ r x₀ * 2 ^ C := by
    have h1 : 2 ≤ r x₀ := hr2 x₀
    have h2 : 1 ≤ (2 : ℕ) ^ C := Nat.one_le_two_pow
    calc (2 : ℕ) = 2 * 1 := by ring
      _ ≤ r x₀ * 2 ^ C := Nat.mul_le_mul h1 h2
  exact not_bigO_of_doubly_exponential_bound hr2 hM2 (by omega)
    (V_le_pow_pow hmono hr2 hpoly) c N

/-- Contrapositive packaging: no constant `c` can dominate. -/
theorem radixHeight_no_constant (hmono : Monotone r) (hr2 : ∀ x, 2 ≤ r x)
    (hpoly : ∀ x, x₀ ≤ x → r x ≤ x ^ C) :
    ¬ ∃ c, ∀ n, radixHeight r n ≤ c * (logStar n + 1) := by
  rintro ⟨c, hc⟩
  obtain ⟨n, hn⟩ := radixHeight_not_bigO_logStar hmono hr2 hpoly c
  exact absurd (hc n) (by omega)

end Polynomial

/-! ## A structural characterization of the `O(log*)` regime -/

section Characterization

variable {r : ℕ → ℕ}

/-- The weights are strictly increasing. -/
theorem V_lt_V_succ (hr2 : ∀ x, 2 ≤ r x) (k : ℕ) : V r k < V r (k + 1) := by
  have h1 : 1 ≤ V r k := one_le_V hr2 k
  have h2 := hr2 (V r k)
  have h3 : 2 * V r k ≤ r (V r k) * V r k := Nat.mul_le_mul_right _ h2
  have : V r (k + 1) = r (V r k) * V r k := rfl
  omega

/-- The radix height is monotone. -/
theorem radixHeight_mono (hr2 : ∀ x, 2 ≤ r x) : Monotone (radixHeight r) := by
  intro m n hmn
  exact radixHeight_le (lt_of_le_of_lt hmn (lt_V_radixHeight hr2 n))

/-- The weights are exactly the jump points of the radix height. -/
theorem radixHeight_V (hr2 : ∀ x, 2 ≤ r x) (k : ℕ) : radixHeight r (V r k) = k + 1 := by
  have h1 : radixHeight r (V r k) ≤ k + 1 := radixHeight_le (V_lt_V_succ hr2 k)
  have h2 : k < radixHeight r (V r k) := lt_radixHeight hr2 (le_refl (V r k))
  omega

/-- **Characterization of the `O(log*)` regime.**  The radix height is `O(log* n)` exactly
when the weight sequence overtakes the tower of twos along an arithmetic subsequence.  This
locates the threshold intrinsically, in terms of the weights rather than of the schedule. -/
theorem bigO_logStar_iff_tower_le (hr2 : ∀ x, 2 ≤ r x) :
    (∃ c, ∀ n, radixHeight r n ≤ c * (logStar n + 1)) ↔
      (∃ c, ∀ k, tower k ≤ V r (c * (k + 1))) := by
  constructor
  · rintro ⟨c, hc⟩
    refine ⟨c, fun k => ?_⟩
    have h1 : radixHeight r (tower k) ≤ c * (logStar (tower k) + 1) := hc _
    have h2 : logStar (tower k) ≤ k := logStar_tower k
    have h3 : radixHeight r (tower k) ≤ c * (k + 1) :=
      le_trans h1 (Nat.mul_le_mul_left _ (by omega))
    have h4 : tower k < V r (radixHeight r (tower k)) := lt_V_radixHeight hr2 _
    have h5 : V r (radixHeight r (tower k)) ≤ V r (c * (k + 1)) := V_monotone hr2 h3
    omega
  · rintro ⟨c, hc⟩
    refine ⟨2 * c, fun n => ?_⟩
    have h1 : n < tower (logStar n + 1) := lt_tower_logStar n
    have h2 : tower (logStar n + 1) ≤ V r (c * (logStar n + 1 + 1)) := hc _
    have h3 : radixHeight r n ≤ c * (logStar n + 1 + 1) :=
      radixHeight_le (lt_of_lt_of_le h1 h2)
    have h4 : c * (logStar n + 1 + 1) + c * logStar n = 2 * c * (logStar n + 1) := by
      ring
    omega

end Characterization

/-! ## The threshold theorem and concrete instances -/

/-- **Radix-growth threshold.**  For monotone radix schedules bounded below by `2`,
super-exponential growth of `r` gives `O(log* n)` radix height, whereas polynomial
growth provably does not. -/
theorem radix_growth_threshold {r s : ℕ → ℕ} {x₀ y₀ C : ℕ}
    (hr2 : ∀ x, 2 ≤ r x) (hbig : ∀ x, x₀ ≤ x → 2 ^ x ≤ r x)
    (hsmono : Monotone s) (hs2 : ∀ x, 2 ≤ s x) (hspoly : ∀ x, y₀ ≤ x → s x ≤ x ^ C) :
    (∀ n, radixHeight r n ≤ x₀ + logStar n + 1) ∧
      ¬ ∃ c, ∀ n, radixHeight s n ≤ c * (logStar n + 1) :=
  ⟨radixHeight_le_logStar_add hr2 hbig, radixHeight_no_constant hsmono hs2 hspoly⟩

/-- The canonical exponential schedule `expSchedule x = max 2 (2 ^ x)`. -/
def expSchedule (x : ℕ) : ℕ := max 2 (2 ^ x)

theorem expSchedule_ge_two (x : ℕ) : 2 ≤ expSchedule x := le_max_left _ _

theorem expSchedule_ge_pow (x : ℕ) : 2 ^ x ≤ expSchedule x := le_max_right _ _

theorem expSchedule_le_pow (x : ℕ) (hx : 1 ≤ x) : expSchedule x ≤ 2 ^ x := by
  refine max_le ?_ le_rfl
  calc (2 : ℕ) = 2 ^ 1 := (pow_one 2).symm
    _ ≤ 2 ^ x := Nat.pow_le_pow_right (by norm_num) hx

/-- **Θ(log*) for the canonical exponential schedule.**  Both bounds hold simultaneously,
so the radix height of `expSchedule` is exactly of order `log* n`. -/
theorem expSchedule_radixHeight_theta (n : ℕ) :
    logStar n ≤ 2 * radixHeight expSchedule n ∧
      radixHeight expSchedule n ≤ logStar n + 1 := by
  constructor
  · exact logStar_le_two_mul_radixHeight expSchedule_ge_two expSchedule_le_pow n
  · have h := radixHeight_le_logStar_add (r := expSchedule) (x₀ := 0)
      expSchedule_ge_two (fun x _ => expSchedule_ge_pow x) n
    simpa using h

/-- Concrete fast schedule `r x = 2 ^ (x + 1)`. -/
theorem radixHeight_two_pow_succ (n : ℕ) :
    radixHeight (fun x => 2 ^ (x + 1)) n ≤ logStar n + 1 := by
  have h := radixHeight_le_logStar_add (r := fun x => 2 ^ (x + 1)) (x₀ := 0)
    (fun x => by
      have : (2 : ℕ) ^ 1 ≤ 2 ^ (x + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
      simpa using this)
    (fun x _ => Nat.pow_le_pow_right (by norm_num) (by omega)) n
  simpa using h

/-- The polynomial family of schedules `polySchedule C x = x ^ C + 2`. -/
def polySchedule (C x : ℕ) : ℕ := x ^ C + 2

/-- **The whole polynomial family sits on the slow side of the threshold.**  For every
exponent `C` the schedule `x ↦ x ^ C + 2` has radix height that is not `O(log* n)`. -/
theorem polySchedule_not_bigO (C : ℕ) :
    ¬ ∃ c, ∀ n, radixHeight (polySchedule C) n ≤ c * (logStar n + 1) := by
  refine radixHeight_no_constant (r := polySchedule C) (x₀ := 3) (C := C + 1)
    (fun a b hab => Nat.add_le_add_right (Nat.pow_le_pow_left hab C) 2)
    (fun x => Nat.le_add_left 2 (x ^ C))
    (fun x hx => ?_)
  have h1 : 1 ≤ x ^ C := Nat.one_le_pow _ _ (by omega)
  have h2 : 3 * x ^ C ≤ x * x ^ C := Nat.mul_le_mul_right _ hx
  have h3 : x ^ (C + 1) = x * x ^ C := by ring
  have h4 : polySchedule C x = x ^ C + 2 := rfl
  omega

/-- Concrete slow schedule `s x = x ^ 2 + 2`: its radix height is not `O(log* n)`. -/
theorem radixHeight_sq_not_bigO :
    ¬ ∃ c, ∀ n, radixHeight (fun x => x ^ 2 + 2) n ≤ c * (logStar n + 1) :=
  polySchedule_not_bigO 2

end RadixGrowth